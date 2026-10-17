"""Measure how many code lines of Musca Auras files are also found in a ForeverAuras release.

Usage: python Tests/CompareWithForeverAuras.py <ForeverAuras folder> <file>... [--show] [--base <WeakAuras folder>]

The ForeverAuras folder is an unpacked release (it holds ForeverAuras/ and ForeverAurasOptions/).
A line counts when it is longer than MIN_LENGTH once comments and blanks are removed, so short generic
lines (end, else, return) do not hide or inflate the result. --show prints the shared lines.
--base takes an upstream WeakAuras 5.22.0 folder: lines also found there are upstream code and are not counted.
"""
import os
import re
import sys

MIN_LENGTH = 25


def code_lines(path):
    with open(path, encoding="utf-8", errors="replace") as file:
        text = re.sub(r"--\[(=*)\[.*?\]\1\]", "", file.read(), flags=re.S)
    lines = []
    for number, line in enumerate(text.split("\n"), 1):
        line = re.sub(r"\s+", "", re.sub(r"--.*", "", line))
        if len(line) > MIN_LENGTH:
            lines.append((number, line))
    return lines


def release_lines(folder):
    found = set()
    for root, _, names in os.walk(folder):
        if os.sep + "Libs" in root:
            continue
        for name in names:
            if name.endswith(".lua"):
                found.update(line for _, line in code_lines(os.path.join(root, name)))
    return found


def main(arguments):
    show = "--show" in arguments
    arguments = [argument for argument in arguments if argument != "--show"]
    upstream = set()
    if "--base" in arguments:
        at = arguments.index("--base")
        if at + 1 >= len(arguments):
            sys.exit(__doc__)
        upstream = release_lines(arguments[at + 1])
        del arguments[at:at + 2]
    if len(arguments) < 2:
        sys.exit(__doc__)
    release = release_lines(arguments[0]) - upstream
    for path in arguments[1:]:
        lines = code_lines(path)
        shared = [(number, line) for number, line in lines if line in release]
        print(f"{len(shared):5d} / {len(lines):5d}  {path}")
        if show:
            for number, line in shared:
                print(f"      {number}: {line}")


if __name__ == "__main__":
    main(sys.argv[1:])
