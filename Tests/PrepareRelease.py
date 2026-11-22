"""Write the version of a release in every place that holds it, and the in-game changelog of that release.

Usage: python Tests/PrepareRelease.py <version> [--date YYYY-MM-DD] [--check]

Written places: the "## Version" line of the five TOC files, the first heading of WeakAuras/CHANGELOG.md, and
versionString, dateString and the first entry of commitText in WeakAurasOptions/Changelog.lua.
WeakAuras/CHANGELOG.md is the source of the release notes. When its first heading is for another version, a new
section is added on top with the date (today unless --date is given): write the notes there, then run again.
The in-game entry is that section as plain text: "## New" becomes "New:", wrapped lines are joined, backticks and
link targets are dropped, and so is the dot at the end of a list item.
highlightText in Changelog.lua stays hand-written. No git command is run.
With --check, nothing is written and the exit code is 1 when a file is not what this script would write.
"""
import datetime
import os
import re
import sys

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOC_FILES = [os.path.join(REPOSITORY, addon, addon + ".toc") for addon in (
    "WeakAuras", "WeakAurasArchive", "WeakAurasModelPaths", "WeakAurasOptions", "WeakAurasTemplates")]
MARKDOWN = os.path.join(REPOSITORY, "WeakAuras", "CHANGELOG.md")
LUA = os.path.join(REPOSITORY, "WeakAurasOptions", "Changelog.lua")
HEADING = re.compile(r"# Musca Auras (\S+) \((\d{4}-\d{2}-\d{2})\)$")
BASED_ON = "Based on WeakAuras"
COMMIT_OPENING = "commitText = [==["
ENTRY_HEADING = re.compile(r"\n\n(?=\S+ \(\d{4}-\d{2}-\d{2}\):\n)")


def read_text(path):
    with open(path, encoding="utf-8", newline="") as handle:
        text = handle.read()
    return text.replace("\r\n", "\n"), "\r\n" if "\r\n" in text else "\n"


def write_text(path, text, eol):
    with open(path, "w", encoding="utf-8", newline="") as handle:
        handle.write(text.replace("\n", eol))


def plain(text):
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    return text.replace("`", "").replace("**", "")


def markdown_with_heading(markdown, version, date):
    """The changelog with its first heading set for the version, and the date of that heading."""
    first_line, _, rest = markdown.partition("\n")
    match = HEADING.match(first_line)
    if not match:
        sys.exit("unexpected first heading of WeakAuras/CHANGELOG.md: " + first_line)
    if match.group(1) == version:
        date = date or match.group(2)
        return "# Musca Auras %s (%s)\n%s" % (version, date, rest), date
    date = date or datetime.date.today().isoformat()
    based_on = next((line for line in rest.split("\n") if line.startswith(BASED_ON)), None)
    section = "# Musca Auras %s (%s)\n\n" % (version, date) + (based_on + "\n\n" if based_on else "")
    return section + markdown, date


def game_entry(markdown, version, date):
    """The first section of the changelog as the plain text shown in game."""
    blocks, current = [], None
    for line in markdown.split("\n")[1:]:
        if line.startswith("# "):
            break
        stripped = line.strip()
        if not stripped or line.startswith("## "):
            current = None
            if line.startswith("## "):
                blocks.append(("heading", stripped[3:] + ":"))
        elif line.startswith("- "):
            current = ["item", stripped]
            blocks.append(current)
        elif current is not None:
            current[1] += " " + stripped.lstrip("> ").strip()
        elif not line.startswith(BASED_ON):
            current = ["paragraph", stripped.lstrip("> ").strip()]
            blocks.append(current)
    if not blocks:
        return None
    text, previous = "%s (%s):" % (version, date), "heading"
    for kind, content in blocks:
        content = plain(content)
        if kind == "item":
            content = content.rstrip(".")
        text += ("\n" if kind == "item" and previous == "item" else "\n\n") + content
        previous = kind
    return text


def lua_with_release(lua, version, date, entry):
    lua, count = re.subn(r"versionString = '[^']*'", "versionString = '%s'" % version, lua, count=1)
    lua, dates = re.subn(r"dateString = '[^']*'", "dateString = '%s'" % date, lua, count=1)
    start = lua.find(COMMIT_OPENING)
    if count != 1 or dates != 1 or start < 0:
        sys.exit("unexpected layout of WeakAurasOptions/Changelog.lua")
    start += len(COMMIT_OPENING)
    entries = ENTRY_HEADING.split(lua[start:], maxsplit=1)
    if len(entries) != 2:
        sys.exit("no earlier release found in commitText of WeakAurasOptions/Changelog.lua")
    first, older = entries
    if not first.startswith(version + " ("):
        older = first + "\n\n" + older
    return lua[:start] + entry + "\n\n" + older


def toc_with_version(toc, path, version):
    toc, count = re.subn(r"(?m)^## Version: .*$", "## Version: " + version, toc, count=1)
    if count != 1:
        sys.exit("no ## Version line in " + os.path.relpath(path, REPOSITORY))
    return toc


def main():
    arguments = sys.argv[1:]
    check = "--check" in arguments
    arguments = [argument for argument in arguments if argument != "--check"]
    date = None
    if "--date" in arguments:
        position = arguments.index("--date")
        if position + 1 >= len(arguments) or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", arguments[position + 1]):
            sys.exit("--date needs a YYYY-MM-DD value")
        date = arguments[position + 1]
        del arguments[position:position + 2]
    if len(arguments) != 1 or not re.fullmatch(r"\d+\.\d+\.\d+(-\w+)?", arguments[0]):
        sys.exit(__doc__)
    version = arguments[0]

    markdown, markdown_eol = read_text(MARKDOWN)
    new_markdown, date = markdown_with_heading(markdown, version, date)
    lua, lua_eol = read_text(LUA)
    entry = game_entry(new_markdown, version, date)
    if entry is None:
        if not check and new_markdown != markdown:
            write_text(MARKDOWN, new_markdown, markdown_eol)
            sys.exit("written: WeakAuras/CHANGELOG.md, new section for %s. Write its notes, then run again."
                     % version)
        sys.exit("the first section of WeakAuras/CHANGELOG.md has no notes")
    planned = [
        (MARKDOWN, markdown, new_markdown, markdown_eol),
        (LUA, lua, lua_with_release(lua, version, date, entry), lua_eol),
    ]
    for path in TOC_FILES:
        toc, eol = read_text(path)
        planned.append((path, toc, toc_with_version(toc, path, version), eol))

    changed = [(path, new, eol) for path, old, new, eol in planned if old != new]
    for path, new, eol in changed:
        if not check:
            write_text(path, new, eol)
        print(("not up to date: " if check else "written: ") + os.path.relpath(path, REPOSITORY))
    if not changed:
        print("Every file is up to date for %s (%s)." % (version, date))
    sys.exit(1 if check and changed else 0)


if __name__ == "__main__":
    main()
