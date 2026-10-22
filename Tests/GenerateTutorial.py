"""Regenerate the blocks of the in-game tutorial (WeakAuras/ForeverTutorial.lua) from TUTORIAL.md.

Usage: python Tests/GenerateTutorial.py [--check]

TUTORIAL.md is the only source. Bold becomes yellow, code becomes blue, tables become "- A: B (C)" lists, an
"!WA:2!" code block becomes an import button, and a line that ends with a backslash keeps its line break.
Text shown only in game sits in "<!-- game: ... -->" comments, and the import button label in an
"<!-- import label: ... -->" comment before the code block.
With --check, nothing is written and the exit code is 1 when ForeverTutorial.lua is not up to date.
The texts are locale keys: a changed text needs its enUS and frFR entries in WeakAuras/Locales/ updated too.
"""
import os
import re
import sys

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MARKDOWN = os.path.join(REPOSITORY, "TUTORIAL.md")
LUA = os.path.join(REPOSITORY, "WeakAuras", "ForeverTutorial.lua")
OPENING = "local blocks = {\n"
CLOSING = "}\n\nPrivate.ForeverTutorialBlocks = blocks"
IMPORT_SENTENCE = ("Copy this text, then `/wa`, **Import**:", "Click the import button below.")


def read_text(path):
    with open(path, encoding="utf-8", newline="") as handle:
        text = handle.read()
    return text.replace("\r\n", "\n"), "\r\n" if "\r\n" in text else "\n"


def write_text(path, text, eol):
    with open(path, "w", encoding="utf-8", newline="") as handle:
        handle.write(text.replace("\n", eol))


def inline(text):
    text = re.sub(r"`([^`]+)`", r"|cff99ccff\1|r", text)
    return re.sub(r"\*\*(.+?)\*\*", r"|cffffd100\1|r", text)


def is_item(stripped):
    return stripped.startswith("- ") or re.match(r"\d+\. ", stripped) is not None


def convert(lines):
    """Markdown lines of one block to its in-game text: paragraphs apart by a blank line, list items one per line."""
    paragraphs, current, hard_break = [], "", False
    code_indent = None
    for index, line in enumerate(lines):
        stripped = line.strip()
        if code_indent is not None:
            if stripped.startswith("```"):
                code_indent = None
            else:
                prefix = "    " if code_indent else ""
                current += ("\n" if current else "") + "|cff99ccff" + prefix + line[code_indent:] + "|r"
            continue
        if stripped.startswith("```"):
            code_indent = len(line) - len(line.lstrip())
            continue
        if not stripped:
            if current:
                paragraphs.append(current)
            current, hard_break = "", False
            continue
        if stripped.startswith("|"):
            following = lines[index + 1].strip() if index + 1 < len(lines) else ""
            if re.match(r"\|\s*-", stripped) or following.startswith("| -"):
                continue
            cells = [cell.strip() for cell in stripped.strip("|").split("|")]
            row = "- " + cells[0] + ": " + cells[1] + "".join(" (" + cell + ")" for cell in cells[2:])
            current += ("\n" if current else "") + row
            continue
        breaks = stripped.endswith("\\")
        stripped = stripped.rstrip("\\")
        if is_item(stripped):
            stripped = ("    " if line[0] == " " else "") + stripped
        if not current:
            current = stripped
        elif is_item(stripped.lstrip()):
            current += "\n" + stripped
        else:
            current += ("\n" if hard_break else " ") + stripped
        hard_break = breaks
    if current:
        paragraphs.append(current)
    # Inline marks last: a code span can be wrapped over two lines.
    return inline("\n\n".join(paragraphs))


def blocks_of(markdown):
    blocks, pending, label = [], [], None

    def flush():
        text = convert(pending)
        if text:
            blocks.append(("text", text))
        del pending[:]

    lines = markdown.replace(*IMPORT_SENTENCE).split("\n")
    index = 0
    while index < len(lines):
        line = lines[index]
        stripped = line.strip()
        if line.startswith("# ") or stripped == "---":
            pass
        elif line.startswith("## ") or line.startswith("### "):
            flush()
            blocks.append(("title" if line.startswith("## ") else "subtitle", line.split(" ", 1)[1]))
        elif stripped.startswith("<!-- import label:"):
            label = stripped[len("<!-- import label:"):-len("-->")].strip()
        elif stripped.startswith("<!-- game:"):
            flush()
            comment = [line.split("<!-- game:", 1)[1].lstrip()]
            while not comment[-1].rstrip().endswith("-->"):
                index += 1
                comment.append(lines[index])
            comment[-1] = comment[-1].rstrip()[:-len("-->")].rstrip()
            blocks.append(("text", convert(comment)))
        elif stripped.startswith("```") and index + 1 < len(lines) and lines[index + 1].strip().startswith("!WA:"):
            if label is None:
                sys.exit("import string without an <!-- import label: ... --> comment before it")
            flush()
            blocks.append(("import", lines[index + 1].strip(), label))
            label = None
            index += 2
        else:
            pending.append(line)
        index += 1
    flush()
    return blocks


def lua_string(text):
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'


def lua_body(blocks):
    lines = []
    for block in blocks:
        if block[0] == "import":
            lines.append("  { import = %s, label = L[%s] }," % (lua_string(block[1]), lua_string(block[2])))
        else:
            lines.append("  { %s = L[%s] }," % (block[0], lua_string(block[1])))
    return "\n".join(lines) + "\n"


def main():
    check = "--check" in sys.argv[1:]
    markdown, _ = read_text(MARKDOWN)
    lua, eol = read_text(LUA)
    start = lua.index(OPENING) + len(OPENING)
    end = lua.index(CLOSING, start)
    updated = lua[:start] + lua_body(blocks_of(markdown)) + lua[end:]
    if updated == lua:
        print("ForeverTutorial.lua is up to date")
        return
    if check:
        sys.exit("ForeverTutorial.lua differs from TUTORIAL.md: run python Tests/GenerateTutorial.py")
    write_text(LUA, updated, eol)
    print("ForeverTutorial.lua rewritten")


if __name__ == "__main__":
    main()
