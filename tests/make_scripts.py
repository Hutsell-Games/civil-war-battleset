#!/usr/bin/env python3
"""Writes the generated scripts of tests/scripts (tests/README.md, "Generated scripts").

    python tests/make_scripts.py [--only <name> ...]

Each generated script loads one scenario from the Load File list and plays it to its end, then
names a commander for the Hall of Fame and quits. Two styles:

    rest-<scenario>-<side>   the player rests every unit at its first command (Space), so only
                             the computer's side acts. One for every scenario and both sides
    auto-<scenario>          Parameters, Computer vs. Computer: the computer plays both sides.
                             For the scenarios of AUTO_SCENARIOS

A rest script takes a digest at every command of a unit, so a difference shows at the unit where
it starts. How many commands a battle has, and whether it ends at the time limit or because one
side is wiped out, depends on the battle, so this tool plays each one first with probes and
writes what they found. Run it again only when a change of the game is meant to change how its
battles go; then record.
"""

from __future__ import annotations

import argparse
import os
import sys
import tempfile
import zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import play  # noqa: E402

SIDES = {1: ("confederate", "Confederate", "Union"), 2: ("union", "Union", "Confederate")}
# The scenarios the auto style plays: battles of different sizes and kinds.
AUTO_SCENARIOS = ["BULLRUN1", "ANTIETAM", "GETTY1", "SHILOH", "CRATER", "MOBILE", "CAMP04", "&STONES"]
# The first file the Load File list highlights is the fifth: QB64's FILES scrolls the list up by
# one line, so its first row is the folder and the files start on the second (tests/README.md).
FIRST_HIGHLIGHT = 4
COLUMNS = 4
PROBE_UNITS = 3000
PROBE_PROMPT_MS = "20000"


def civ_files(game: Path = play.GAME, test_data: Path = play.TEST_DATA) -> list[str]:
    """The .civ files of a run's scenarios folder in the order FILES lists them: the repo's
    scenarios and the saved games of tests/data, put together as play.copy_data puts them. On
    Windows, os.listdir gives the order of the file system, which is the order FILES gives."""
    with tempfile.TemporaryDirectory() as d:
        play.copy_data(Path(d), game, test_data)
        folder = Path(d) / "scenarios"
        return [n for n in os.listdir(folder) if n.lower().endswith(".civ")]


def scenarios(game: Path = play.GAME) -> list[str]:
    """The scenarios a script can load: the .civ files of the repo's scenarios folder, which
    leaves out the five saved games."""
    return [n for n in civ_files(game) if (game / "scenarios" / n).is_file()]


def pick_keys(name: str, files: list[str]) -> list[str]:
    """The steps that move the Load File list's highlight from where it starts to the file."""
    i = files.index(name)
    if i < FIRST_HIGHLIGHT:
        raise ValueError(f"{name} is on the list's first row, which the highlight cannot reach")
    downs = i // COLUMNS - FIRST_HIGHLIGHT // COLUMNS
    rights = i % COLUMNS
    steps: list[str] = []
    for key in ["down"] * downs + ["right"] * rights:
        steps += [f"key {key}", "prompt"]
    return steps


def stem(name: str) -> str:
    return name.rsplit(".", 1)[0].upper()


def script_name(style: str, scenario: str, side: int) -> str:
    tag = stem(scenario).lower().replace("&", "and-")
    return f"{style}-{tag}" if style == "auto" else f"{style}-{tag}-{SIDES[side][0]}"


def title(scenario: str, game: Path = play.GAME) -> str:
    first = (game / "scenarios" / scenario).read_bytes().split(b"\n", 1)[0].strip()
    return first.decode("cp437").split("|")[0].strip()


def seed(scenario: str) -> int:
    return zlib.crc32(stem(scenario).encode()) % 100000


def header(style: str, scenario: str, side: int, files: list[str], about: str) -> list[str]:
    _, player, computer = SIDES[side]
    if style == "auto":
        what = "with the computer playing both sides (Parameters, Computer vs. Computer)."
    else:
        what = f"as the {player} side, resting every unit; the computer plays the {computer} side."
    return [
        f"# {title(scenario)} ({scenario}) {what}",
        f"# {about}",
        "# Written by tests/make_scripts.py.",
        f"#! seed {seed(scenario)}",
        f"#! cfg side={side}",
        "",
        "# Pauses that any key ends; a unit's command: rest; the combat menu: Light Skirmish;",
        "# Pursue ? and Stack Units: No; the time limit: End Game & See Results.",
        "rule 1 key space",
        "rule 5 key space",
        "rule 2:C key enter",
        "rule 2:P key enter",
        "rule 2:S key enter",
        "rule 2:T key enter",
        "",
        f"# Main menu, Load File; {scenario} in the list.",
        "play until 2:M",
        "digest",
        "key enter",
        "prompt",
        *pick_keys(scenario, files),
        "key enter",
        "play until 2:M",
        "digest",
    ]


def start(style: str) -> list[str]:
    if style == "auto":
        return [
            "",
            "# Parameters (three down from Fight, which the menu highlights after a load; its",
            "# letter would choose Player), Computer vs. Computer, Esc: the battle starts at once.",
            "key down",
            "prompt",
            "key down",
            "prompt",
            "key down",
            "prompt",
            "key enter",
            "play until 2:G",
            "digest",
            "text c",
            "prompt",
            "digest",
            "key esc",
        ]
    return ["", "# Fight.", "key enter"]


def units(count: int) -> list[str]:
    if count == 0:
        return []
    return ["", "# Each command of a unit: a digest, then rest.",
            f"repeat {count}", "play until 5", "digest", "key space", "end"]


def ending(time_limit: bool) -> list[str]:
    lines = [""]
    if time_limit:
        lines += [
            "# The time limit: End Game. The results, then a digest at each pause until the",
            "# Hall of Fame asks for a name.",
            "play until 2:T",
            "digest",
            "key enter",
            "prompt",
            "digest",
            "key space",
        ]
    else:
        lines += ["# One side is wiped out: the results and the pauses until the Hall of Fame asks",
                  "# for a name."]
    return lines + [
        "play until 4",
        "text Tester",
        "key enter",
        "prompt",
        "digest",
        "key space",
        "",
        "# The main menu: Quit, Yes, and a key for END's \"Press any key to continue\".",
        "play until 2:M",
        "digest",
        "text q",
        "prompt",
        "digest",
        "text y",
        "repeat space",
    ]


def probe_run(tools: play.Tools, exe: Path, name: str, lines: list[str]) -> tuple[list[bytes], str, int | None]:
    """Runs a probe: its digests, the last line of its state file and its exit code."""
    keys = play.OUT / "probe" / f"{name}.keys"
    keys.parent.mkdir(parents=True, exist_ok=True)
    keys.write_text("\n".join(lines) + "\n")
    run = play.run_script(tools, exe, play.load_script(keys), "rust",
                          extra_env={"QB64_SCREEN_PROMPT_MS": PROBE_PROMPT_MS})
    found = play.entries(run.state)
    last = play.short(found[-1]) if found else f"exit code {run.rc}, no state"
    if run.rc is None:
        last = f"killed after {run.script.timeout} s; " + last
    return [e for e in found if e.startswith(b"digest ")], last, run.rc


def probe(tools: play.Tools, exe: Path, style: str, scenario: str, side: int,
          files: list[str]) -> list[str] | str:
    """The script's lines, or why the probes could not play the battle to its end."""
    name = "probe-" + script_name(style, scenario, side)
    head = header(style, scenario, side, files, "") + start(style)
    count = 0
    if style == "rest":
        # Every command of a unit until the Hall of Fame asks for a name.
        lines = head + [f"repeat {PROBE_UNITS}", "play until 5", "digest", "key space", "end"]
        digests, last, _ = probe_run(tools, exe, name, lines)
        if not last.endswith("no rule for the wait at place 4"):
            return f"the battle did not end: {last}"
        count = len(digests) - 2  # the two at the main menu come first
    # Whether the battle ends at the time limit: a digest there, then the results' pause, then
    # a prompt that no wait answers.
    lines = head + units(count) + ["play until 2:T", "digest", "key enter", "prompt", "prompt"]
    _, last, _ = probe_run(tools, exe, name, lines)
    time_limit = last.endswith("no prompt in time")
    if not time_limit and not last.endswith("no rule for the wait at place 4"):
        return f"the end of the battle was not found: {last}"
    about = (f"A digest at each of the {count} commands of a unit, at the end and at the pauses after it."
             if style == "rest" else "A digest at the end of the battle and at the pauses after it.")
    lines = header(style, scenario, side, files, about) + start(style) + units(count) + ending(time_limit)
    keys = play.OUT / "probe" / f"{name}.keys"
    keys.write_text("\n".join(lines) + "\n")
    _, last, rc = probe_run(tools, exe, name, lines)
    if rc != 0:
        return f"the script does not end the game: exit code {rc}, {last}"
    return lines


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--qb64rust-repo")
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument("--only", nargs="*", help="names of the scripts to write (default: all)")
    args = parser.parse_args(argv)
    tools = play.find_tools(args)
    exe = play.build(tools, "rust")
    files = civ_files()
    autos = {f"{s}.CIV".upper() for s in AUTO_SCENARIOS}
    games = [("rest", s, side) for s in scenarios() for side in SIDES]
    games += [("auto", s, 1) for s in scenarios() if s.upper() in autos]
    games = [g for g in games if not args.only or script_name(*g) in args.only]
    found = play.parallel(args.jobs, [lambda g=g: probe(tools, exe, *g, files) for g in games])
    failed = 0
    for game, lines in zip(games, found):
        name = script_name(*game)
        if isinstance(lines, str):
            failed += 1
            print(f"FAIL  {name}: {lines}")
            continue
        (play.SCRIPTS / f"{name}.keys").write_text("\n".join(lines) + "\n")
        print(f"wrote {name}.keys: {sum(1 for x in lines if x == 'digest')} digest steps")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
