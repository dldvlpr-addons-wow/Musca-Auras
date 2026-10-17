"""Regenerate the spell rank families and the specialization talents of Musca Auras.

Usage: python Tests/GenerateSpellData.py <data folder> [<output folder>]

The data folder holds data.json from https://talentsforever.com/data.json and SpellName.csv from
https://wago.tools/db2/SpellName/csv?build=<build>. The output folder defaults to WeakAuras/ of this repository.
Only the families and specializations tables, the source date and the license notes are rewritten.
"""
import csv
import json
import os
import re
import sys

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LINE_WIDTH = 90
CONSUMABLES = (("Food", "Nutritious Food"), ("Drink", "Nutritious Drink"))


def read_text(path):
    with open(path, encoding="utf-8", newline="") as handle:
        text = handle.read()
    return text.replace("\r\n", "\n"), "\r\n" if "\r\n" in text else "\n"


def write_text(path, text, eol):
    with open(path, "w", encoding="utf-8", newline="") as handle:
        handle.write(text.replace("\n", eol))


def wrap_ids(ids, label, key):
    if not ids:
        sys.exit("empty spell family: " + label)
    lines, line = [], '  ["%s"] = {' % key
    for index, spell_id in enumerate(ids):
        item = str(spell_id) + ("}," if index == len(ids) - 1 else ",")
        candidate = line + ("" if line.endswith("{") else " ") + item
        if len(candidate) > LINE_WIDTH and not line.endswith("{"):
            lines.append(line)
            line = "      " + item
        else:
            line = candidate
    lines.append(line)
    return "\n".join(lines)


def rank_families(data, spell_names):
    general = {(class_name, spell[0]) for class_name, book in data["spellbooks"].items() for spell in book["general"]}
    families = {}
    for key, entry in data["spell_desc"].items():
        class_name, spell_name, subtext = key.split("|")
        if "id" not in entry or (class_name, spell_name) in general:
            continue
        variant = "" if subtext == "" or re.fullmatch(r"Rank \d+", subtext) else subtext
        families.setdefault((class_name, spell_name, variant), []).append(entry["id"])
    blocks = []
    for key in sorted(families):
        label = " / ".join(part for part in key if part)
        blocks.append(wrap_ids(families[key], label, label))
    consumables = {}
    for names in CONSUMABLES:
        consumables[names[0]] = sorted(i for i, n in spell_names.items() if n in names)
        blocks.append(wrap_ids(consumables[names[0]], names[0], names[0]))
    return families, consumables, "\n".join(blocks)


def specializations(data, spell_names):
    lines, fallbacks, entries = [], [], {}
    for class_name, classes in data["talents"].items():
        for tree in classes["trees"]:
            last_row = max(talent["row"] for talent in tree["talents"])
            talent = min((t for t in tree["talents"] if t["row"] == last_row), key=lambda t: t["col"])
            ids = [entry["id"] for key, entry in data["spell_desc"].items()
                   if key.split("|")[:2] == [class_name, talent["name"]] and "id" in entry]
            if not ids:
                candidates = [i for i, n in spell_names.items() if n == talent["name"]]
                if not candidates:
                    sys.exit("no spell ID for %s / %s / %s" % (class_name, tree["name"], talent["name"]))
                ids = [min(candidates)]
                fallbacks.append("%s / %s / %s: %d" % (class_name, tree["name"], talent["name"], ids[0]))
            token = class_name.upper()
            key = "%s_%s" % (token, tree["name"].upper().replace(" ", "_"))
            line = '  {"%s", "%s", "%s", "%s", {%s}},' % (
                key, token, tree["name"], tree["icon"], ", ".join(str(i) for i in ids))
            entries[key] = line.strip().rstrip(",")
            lines.append(line)
    return fallbacks, entries, "\n".join(lines)


def replace_table(text, opening, body):
    start = text.index(opening) + len(opening)
    end = text.index("\n}\n", start)
    return text[:start] + "\n" + body + text[end:]


def table_body(text, opening):
    start = text.index(opening)
    return text[start:text.index("\n}\n", start)]


def current_families(text):
    labelled = {}
    for label, ids in re.findall(r'\["([^"]+)"\]\s*=\s*\{([\d,\s]+)\}', table_body(text, "local rankTables = {")):
        labelled[label] = [int(i) for i in re.findall(r"\d+", ids)]
    return labelled, [labelled.pop(name, []) for name, _ in CONSUMABLES]


def current_specializations(text):
    body = table_body(text, "local specializations = {")
    return {key: line.rstrip(",") for line, key in re.findall(r'^\s*(\{"(\w+)", .*\},?)$', body, re.M)}


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    data_folder = sys.argv[1]
    output = sys.argv[2] if len(sys.argv) > 2 else os.path.join(REPOSITORY, "WeakAuras")
    source = os.path.join(REPOSITORY, "WeakAuras")
    data = json.loads(read_text(os.path.join(data_folder, "data.json"))[0])
    with open(os.path.join(data_folder, "SpellName.csv"), encoding="utf-8", newline="") as handle:
        spell_names = {int(row["ID"]): row["Name_lang"] for row in csv.DictReader(handle)}
    generated = data["generated"]

    outputs = {}
    ranks_text, ranks_eol = read_text(os.path.join(source, "SecretAuraRanks.lua"))
    before, before_consumables = current_families(ranks_text)
    families, consumables, body = rank_families(data, spell_names)
    ranks_text = replace_table(ranks_text, "local rankTables = {", body)
    ranks_text = re.sub(r"data\.json, generated \d{4}-\d{2}-\d{2}", "data.json, generated " + generated, ranks_text)
    outputs["SecretAuraRanks.lua"] = ranks_text, ranks_eol

    spec_text, spec_eol = read_text(os.path.join(source, "PlayerSpecialization.lua"))
    before_specs = current_specializations(spec_text)
    fallbacks, specs, body = specializations(data, spell_names)
    spec_text = replace_table(spec_text, "local specializations = {", body)
    spec_text = re.sub(r"data\.json, generated \d{4}-\d{2}-\d{2}", "data.json, generated " + generated, spec_text)
    outputs["PlayerSpecialization.lua"] = spec_text, spec_eol

    for name in ("SpellRankData-LICENSE.txt", "SpecializationData-LICENSE.txt"):
        text, eol = read_text(os.path.join(source, name))
        text = re.sub(r"Source generated: \d{4}-\d{2}-\d{2}", "Source generated: " + generated, text)
        outputs[name] = text.replace("Modified for ForeverAuras", "Modified for Musca Auras"), eol

    for name, (text, eol) in outputs.items():
        write_text(os.path.join(output, name), text, eol)

    after = {" / ".join(p for p in key if p): ids for key, ids in families.items()}
    print("data.json generated %s, %d families" % (generated, len(after)))
    for label in sorted(set(before) - set(after)):
        print("removed  %s %s" % (label, before[label]))
    for label in sorted(set(after) - set(before)):
        print("added    %s %s" % (label, after[label]))
    for label in sorted(set(before) & set(after)):
        if before[label] != after[label]:
            print("changed  %s %s -> %s" % (label, before[label], after[label]))
    for index, (name, ids) in enumerate(consumables.items()):
        previous = before_consumables[index] if index < len(before_consumables) else []
        print("%s: %d IDs (was %d)%s" % (name, len(ids), len(previous), "" if ids == previous else ", changed"))
    for key in sorted(set(before_specs) - set(specs)):
        print("removed  %s" % before_specs[key])
    for key in sorted(set(specs) - set(before_specs)):
        print("added    %s" % specs[key])
    for key in sorted(set(before_specs) & set(specs)):
        if before_specs[key] != specs[key]:
            print("changed  %s -> %s" % (before_specs[key], specs[key]))
    spec_ids = [int(i) for line in specs.values() for i in re.findall(r"\d+", line.rsplit("{", 1)[1])]
    for spell_id in sorted({i for ids in after.values() for i in ids} | set(spec_ids)):
        if spell_id not in spell_names:
            print("missing from SpellName.csv: %d" % spell_id)
    for line in fallbacks:
        print("talent ID from SpellName.csv, lowest ID with that name: " + line)


if __name__ == "__main__":
    main()
