"""Generate Classes/Talents/<Class>.md from wow-forever.gg #trait-data JSON.

1. Download the pages (one HTML per class, lowercase name):
   for c in druid hunter mage paladin priest rogue shaman warlock warrior; do
     curl -s -o "$DIR/$c.html" "https://wow-forever.gg/talents/$c/"; done
2. Run: python3 -I generate_talent_trees.py "$DIR" Classes
Rank IDs come from the "## Talents" section of Classes/<Class>.md (the JSON has none)."""
import html, json, re, sys
from datetime import date
from pathlib import Path

CLASSES = ["Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"]
KIND = {"renamed": "renommé", "reworded": "reformulé", "ranks": "rangs", "requires": "prérequis", "added": "ajouté", "removed": "retiré", "changed": "modifié", "moved": "déplacé", "new": "nouveau"}


def plain(s):
    s = re.sub(r"<s>(.*?)</s>", r"~~\1~~", s)
    s = re.sub(r"<b>(.*?)</b>", r"**\1**", s)
    return re.sub(r"\s*\n\s*", " ", html.unescape(re.sub(r"<[^>]+>", "", s))).replace("|", "/").strip()


def describe(rh):
    """Rank 1 text with each value replaced by its per-rank series (0.1/0.2/...)."""
    vals = [re.findall(r'<em class="tv">(.*?)</em>', r) for r in rh]
    if len(rh) > 1 and all(len(v) == len(vals[0]) for v in vals) and vals[0]:
        it = iter(range(len(vals[0])))
        def series(_):
            i = next(it)
            seq = [v[i] for v in vals]
            return seq[0] if len(set(seq)) == 1 else "/".join(seq)
        return plain(re.sub(r'<em class="tv">.*?</em>', series, rh[0]))
    return " ‖ ".join(f"R{i + 1} : {plain(r)}" for i, r in enumerate(rh)) if len(set(rh)) > 1 else plain(rh[0]) if rh else ""


def changes(cmp):
    if cmp.get("s") == "new":
        return "nouveau dans Forever"
    items = cmp.get("r", [[]])[-1]
    return " ; ".join(f"{KIND.get(k, k)} : {plain(t)}" for k, t in items if k != "same") or "identique à Classic"


def class_ids(md):
    """name -> (ids, flagged) from the Talents section of Classes/<Class>.md."""
    sec = md.split("## Talents", 1)[1].split("\n## ", 1)[0]
    out, effect_last = {}, False
    for line in sec.splitlines():
        if line.startswith("|"):
            cells = [c.strip() for c in line.strip("|").split("|")]
            if cells[0] in ("Nom", "Talent"):
                effect_last = cells[-1].startswith("Effet")
                continue
            body = cells[1:-1] if effect_last else cells[1:]
            out.setdefault(cells[0], (list(dict.fromkeys(re.findall(r"(?<!DB2 )(?<!build )\b\d{4,}\b", " ".join(body)))), " ".join(body)))
        else:  # Shaman inline: "Name N (ids ; note)"
            for name, inner in re.findall(r"(?:^|; )([^;(]+?) \d+ \(([^)]*)\)", line):
                out.setdefault(name.strip(), (list(dict.fromkeys(re.findall(r"(?<!DB2 )(?<!build )\b\d{4,}\b", inner))), inner))
            # Hunter prose: "Name (note) : IDs 1 / 2 / 3" or "Name : 1 / 2"
            for m in re.finditer(r"(?:^|\. )([A-Z][A-Za-z' ]+?) (\([^)]*\) )?: (?:IDs )?(\d{4,}(?: / \d{4,})*)", line):
                out.setdefault(m.group(1), (m.group(3).split(" / "), (m.group(2) or "") + "prose"))
    return out


def id_cell(node, ids):
    name, old = node["name"], None
    for k, t in node["cmp"].get("r", [[]])[0]:
        if k == "renamed":
            old = re.search(r"<s>(.*?)</s>", t).group(1)
    if name not in ids and old in ids:
        found, raw = ids[old]
        return (", ".join(found) or "aucun") + f" ⚠ (sous l'ancien nom {old})"
    if name not in ids:
        return "absent de la section Talents du fichier de classe"
    found, raw = ids[name]
    if not found:
        return "aucun ⚠"
    txt = ", ".join(found)
    if re.search(r"absent|candidat|SpellName|nommé|«", raw) or len(found) != node["max"]:
        txt += " ⚠"
    return txt


def render(cls, d, ids, url, build):
    lines = [f"# {cls} : arbres de talents (WoW Forever)", "",
             f"Source : {url} (build {build}, JSON `#trait-data`, lu le {date.today()}). "
             f"Plafond {d['cap']} points ; bêta : niveau max {d['betaCap']}, soit {d['betaCap'] - d['levels'][0] + 1} points (1 point par niveau dès le niveau {d['levels'][0]}).",
             "Palier = points requis dans l'arbre. Colonne 1 à 4 de gauche à droite. Valeurs `a/b/c` = rang 1/2/3.",
             f"IDs de rang : repris de `Classes/{cls}.md`, pas de wow-forever.gg. « ⚠ » = ID absent du DB2 Talent, candidat, "
             "nombre d'IDs différent du nombre de rangs, ID annexe (aura déclenchée, homonyme) ou talent renommé : voir le fichier de classe.", ""]
    for t in d["trees"]:
        byid = {n["id"]: n for n in t["nodes"]}
        nodes = sorted(t["nodes"], key=lambda n: (n["row"], n["col"]))
        lines += [f"## {t['name']} ({len(nodes)} talents, {sum(n['max'] for n in nodes)} points)", "",
                  "| Palier | Col. | Talent | Rangs | Prérequis | IDs de rang | Effet | Changement vs Classic |",
                  "|---|---|---|---|---|---|---|---|"]
        for n in nodes:
            req = (" ou " if n["any"] else " et ").join(byid[r]["name"] for r in n["req"] if r in byid) or ""
            name = n["name"] + (" (verrouillé)" if n["locked"] else "")
            lines.append(f"| {n['gate']} | {n['col'] + 1} | {name} | {n['max']} | {req} | "
                         f"{id_cell(n, ids)} | {describe(n['rh'])} | {changes(n['cmp'])} |")
        lines.append("")
    return "\n".join(lines)


def main(src, classes_dir):
    out = Path(classes_dir) / "Talents"
    out.mkdir(exist_ok=True)
    for cls in CLASSES:
        g = (Path(src) / f"{cls.lower()}.html").read_text()
        d = json.loads(re.search(r'id="trait-data">(.*?)</script>', g, re.S).group(1))
        build = re.search(r'data-build="([\d.]+)"', g) or re.search(r"build ([\d.]+\d)", g)
        ids = class_ids((Path(classes_dir) / f"{cls}.md").read_text())
        (out / f"{cls}.md").write_text(render(cls, d, ids, d["page"], build.group(1)))
        miss = [n["name"] for t in d["trees"] for n in t["nodes"] if n["name"] not in ids]
        print(cls, [len(t["nodes"]) for t in d["trees"]], "IDs non trouvés:", miss)


if __name__ == "__main__":
    assert describe(['a <em class="tv">1</em> b <em class="tv">5</em>', 'a <em class="tv">2</em> b <em class="tv">5</em>']) == "a 1/2 b 5"
    main(*sys.argv[1:])
