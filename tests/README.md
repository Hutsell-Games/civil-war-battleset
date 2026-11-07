# Tests

Two kinds of test live here:

- **Unit tests** (`rules_test.bas`) call the SUBs that draw nothing and check what they return. Run them with
  `qb64rust test tests`.
- **Whole-game scripts** (`scripts\*.keys`) play the game, the scenario editor or `pbmfix` from start to end,
  with a fixed random seed, and compare their screens with the screens recorded earlier. They are what makes a
  change safe: a change that alters any screen of any script fails.

The scripts use QB64Rust's screen-state check. That is a C++ file linked into the program. It gives the program
keys from a file and writes the screen out at the points the file asks for. Its manual is QB64Rust's
`tools\screen\README.md`, which this file does not repeat. `play.py`, `make_scripts.py` and `test_play.py` were
adapted from the World War 2 port (`Hutsell-Games/world-war-2`, branch `qb64rust`).

## Running them

From the repo's folder, with QB64Rust's repo beside it (`..\QB64Rust`, built in release) and QB64pe beside
that (`..\QB64pe\qb64pe.exe`):

```
python tests\play.py check                       # every script with the QB64Rust build, against the recorded screens
python tests\play.py check rest-bullrun1-union   # one script
python tests\play.py compare                     # the QB64pe and QB64Rust builds against each other
python tests\play.py record [script ...]         # both builds, twice each; writes scripts\<name>.screen
python tests\play.py coverage                    # the lines and the SUBs the scripts and unit tests reach
python tests\play.py explore <keys file>         # one run, a PNG of every screen; for writing a script
python tests\make_scripts.py                     # writes the generated scripts again (below)
python -m unittest discover -s tests -p "test_*.py"   # the tests of play.py and make_scripts.py
```

`--jobs N` (before the command) sets how many runs go at once (default 4). `CWB_SHOW_WINDOWS=1` shows the
program's window. Otherwise it runs on a desktop of its own that is never shown, and your keys and mouse cannot
reach it. Everything a run makes goes into `tests\out\`, which git ignores. A build is made again only when a
source file, the compiler or the screen hook changed. What a command prints also goes to
`tests\out\last-<command>.txt`.

Each run starts in a fresh copy of the game's data files in `tests\out\run\`, so the files in the repo are never
changed. The copy takes the files at the top of the repo's folder but the sources, documents and DOS programs,
and the four data folders `graphics\`, `sound\`, `data\` and `scenarios\` (`docs\devnotes.md`, item 13). Then
it copies the tree of `tests\data\` over it: the history files (`GENERALZ`, `MAXSKORS`), the campaign under way
(`REGIONS.SAV`), and in `tests\data\scenarios\` the five saved games and `SAVEGAME.PBM`. The files that playing
writes in the repo's folder are not copied: the names in `.gitignore`, which `PLAYED_FILES` in `play.py` repeats.
A scenario the editor saved in `scenarios\` is copied, though. It adds a file to the Load File list and moves the
keys of every generated script, so do not keep one there.

### When a check fails

`check` names the first checkpoint that differs and the line of the keys file that took it:

```
FAIL  rest-bullrun1-union [rust]: differs at checkpoint 40, tests/scripts/rest-bullrun1-union.keys line 37
    recorded: digest 8E575CF04FCA4E58
    now:      digest 52B151F891A7FB5A
    the screen now:      tests/out/fail/rest-bullrun1-union-now-40.png
    the screen recorded: tests/out/fail/rest-bullrun1-union-recorded-40.png
```

A checkpoint is usually a digest, a hash of the screen. To show the screen, `check` plays the script again with
full screens and writes a PNG of the one that differs. The recorded screen gets a PNG too when `record` ran on
this machine: it keeps a copy with full screens in `tests\out\recorded\`.

A difference is either a mistake in the change or a change of behavior that was meant. If it was meant, record
the script again (`record <name>`) and say so in the commit message.

A run that hangs in `SHELL` is killed after the script's timeout. This happened once while recording, to
`pbmfix` built by QB64pe, with other runs going at the same time, and not again when it was recorded alone.
QB64Rust's Civil War Strategy scripts see the same in `SHELL "copy ..."` under load. A script that times out
is run again alone before it is taken as a failure.

## How the game takes part

The game and the editor have hooks for the scripts, all in `SCRIPT.BM`. They do nothing unless the program is
started with the environment variable `CWB_SEED` set, as `play.py` does:

1. **A fixed seed.** `RANDOMIZE` takes `CWB_SEED` instead of `TIMER`, so every run of a script is the same
   battle. The editor takes it too, for its random maps and armies.
2. **Announced waits.** Before each wait for a key, the program says what kind of wait it is (`announce place,
   letter$`). The keys file then gives each key only when the program waits for it, and can answer waits by
   rules.
3. **Pauses.** `TICK` with less than 99 seconds (a message shown for a moment, which a key may cut short)
   returns at once. A battle then takes seconds, not hours, and nothing depends on how fast the machine is. A
   message shown during such a pause is drawn and gone before the next checkpoint, so no script sees it.
   `TICK 99` and `TICK 999` are how the game says "press a key" (the results, the help, a victory): under a
   script they wait for a key, as place 1.
4. **A fixed clock.** A saved game holds the date and time 01-01-2000 12:00 instead of now. The elapsed time of a
   computer-against-computer game, and of the editor's placing of armies, stays at 0.
5. **A fixed folder.** `CURDIR$` shows the folder the program started in as `C:\CWB`, and a folder inside it as
   `C:\CWB\<name>`. The main menus show it in their Directory entry, so without this every folder the scripts
   run in would draw another menu.
6. **No `SHELL`.** The game copies its history files with `SHELL "copy ..."`, and `pbmfix` renames with
   `SHELL "rename ..."`. Under a script `scriptshell` does the same in BASIC. A `SHELL` starts a `cmd.exe`, and
   its console window shows on your desktop even though the program runs on a hidden one.

The places a script can name (`play until <place>[:<letter>]`, `rule <place>[:<letter>] <keys>`):

| Place | Wait | Where |
|---|---|---|
| 1 | A pause that any key ends: `TICK` of 99 seconds or more, "hit a key", "press any key to switch" | `TICK` and others |
| 2 | A menu. The letter is the first letter of the menu's title | `menu`, `CIVWAR2C.BM` |
| 3 | The list of `.civ` files | `menufile`, `CIVWAR2A.BM` and `CIVSET24.BAS` |
| 4 | A line of text: `Enput` (a name, a folder, a description), the scoring factors' `INPUT`s, the editor's unit name and delay | `Enput`, `CIVWAR2B.BM` and `CIVSET24.BAS` |
| 5 | The game: the command for a unit. The letter is the side that gives it: `C` or `U` | `order`, `CIVWAR2A.BM` |
| 6 | The game: the cursor on the map, for a move, a target, intelligence or inspire | `order` |
| 7 | The game: the boss screen (Ctrl+B), which only Ctrl+B ends | `order` |
| 8 | The game: the line of sight bar of Game Options | `customize`, `CIVWAR2B.BM` |
| 9 | The editor: the cursor of Map Edit | `drawmap`, `CIVSET24.BAS` |
| 10 | The editor: the cursor of Army Edit | `placearmy` |
| 11 | The editor: a unit's strength, morale or leadership | `attribute` |
| 12 | The editor: a one-key answer (a terrain, Y or N, a unit type) | `drawmap`, `placearmy` |

Menu letters seen so far, in the game: `2:M` the main menu (and the PBM menu, which has no title of its own and
shows the main menu's), `2:S` SAVEGAME FILE TO LOAD or SAVE and Stack Units, `2:Q` Quit, `2:T` Time Limit
Reached, `2:C` the combat menu, CAMPAIGN and Confederate Move, `2:U` UNIT COMMAND and Union Move, `2:G` GAME
OPTIONS (F3) and Game Options (Parameters), `2:P` Pursue ?, `2:L` Leave Trench and Limber ?, `2:O` Options (after
a campaign battle), `2:R` and `2:U` the Hall of Fame's generals. In the editor: `2:O` its main menu and the
random map's Map OK, `2:B` Battle Size and Balance, `2:W` Water Hexes, `2:Q` QUIT THE EDITOR ?, `2:A` Alt
Objective, `2:R` or `2:U` a unit's menu in Army Edit.

A rule for a letter answers every menu with that letter. A script that must tell them apart uses `prompt` and
plain keys, or `play until` that menu.

A menu takes Up, Down, PgUp, PgDn, Home and End, and the first letter of an entry, which chooses it at once.
A letter that matches no entry is ignored, and the menu announces its wait again. A menu highlights its first
entry, except where the game asks for another: the main menu highlights Load File, and Fight after a load; the
saved games' menu highlights the slot of the file chosen in the list.

**The list of files.** QB64's `FILES` scrolls the list up by one line. Its title row is lost, the folder ends up
on the first row and the files start on the second. The list's code expects them on the third, so the first
file it highlights is the fifth, `$AVE5.CIV`, and the first four cannot be chosen. A file is reached from there
by Down (four files a row) and Right. `make_scripts.py` works the keys out from the order of the files in the
folder (`pick_keys`). No script takes a digest at the list: it shows the full path of the folder and the free
space of the disk.

## The scripts

Each script is a keys file with lines that set up its run, which `play.py` reads:

```
#! seed 1861             the random seed (default 1)
#! cfg side=2 history=0  fields of the PREFER.CFG the program starts with
#! timeout 600           the longest the run may take, in seconds
#! program cs            the program the script plays: cw (the game, the default), cs (the editor) or pbmfix
#! files SAVEGAME.PBM    files to check after the run, by their hashes
```

Each file a `#! files` line names becomes a last checkpoint, `file <name> <hash>`, or `file <name> missing`.
The hash takes CRLF line ends as LF. A name may start with a folder, written with `/`. Each part of the name
matches whatever its case.

The `PREFER.CFG` of a run is written fresh. By default it is the Confederate side, no sound, and the game's own
defaults otherwise: difficulty 3, visibility 18, aggression 3, limber, line of sight, captured artillery and
history on. The fields are `CFG_FIELDS` in `play.py`.

A script ends the program the way a player does: Quit and Yes, then `repeat space` for END's "Press any key to
continue". A run that ends any other way (a `prompt` that times out, no rule for a wait, a crash) fails, and the
last line of its state file says why. `play.py` sets `QB64PE_NOPROMPT`, so a runtime error ends the program at
once instead of waiting for an answer to "Continue?" on a desktop nobody sees.

### Generated scripts

`make_scripts.py` writes two styles:

| Script | How the battle is played |
|---|---|
| `rest-<scenario>-<side>` | Every scenario (the 77 `.civ` files but the five saved games), as each side, but three whose battle stops with a runtime error (`TODO.md`): `rest-bold-confederate` and both `rest-antietm2` scripts. The player rests every unit at its first command (Space), so only the computer's side acts: its moves, its fire, the battles and retreats. A digest at every command of a unit |
| `auto-<scenario>` | Eight scenarios: `BULLRUN1`, `ANTIETAM`, `GETTY1`, `SHILOH`, `CRATER`, `MOBILE`, `CAMP04` and `&STONES`. Parameters, Computer vs. Computer: the computer plays both sides. A digest at the start and at the end |

Each loads its scenario from the list of files, plays it to its end, names the commander "Tester" for the Hall of
Fame and quits. The rules answer the combat menu with Light Skirmish and Pursue ? and Stack Units with No. How
many commands a battle has, and whether it ends at the time limit or because one side is wiped out, depends on
the battle. So `make_scripts.py` first plays each battle with probes, then writes what they found. Run it again
only when a change is meant to change how the battles go, then `record`. It takes about an hour and a half with
four jobs.

### Scripts written by hand

| Script | What it plays |
|---|---|
| `commands-bullrun1` | The commands of a battle: F1, F3's Game Options, the hot keys, the Unit Command menu, a move order with the cursor, Charge, an artillery battery's Fire, Limber and Unlimber, Wait, a move by an arrow key, and F10 back to the main menu |
| `parameters` | Every entry of Parameters, with Save Settings. Checks `PREFER.CFG`, `GENERALZ` and `MAXSKORS` |
| `saves-gosub` | Esc and a letter at the saved games' menu, a battle saved and loaded again, Quit answered by Esc and by a letter: the menus that left a `GOSUB` routine (`docs\devnotes.md`, item 9). Checks `$AVE2.CIV` |
| `directory` | The Directory menu: Esc, and a folder that does not exist |
| `twoplayer-bullrun1` | Two players: the side switch between them (`otherside`, item 9) and both sides' results |
| `campaign` | A campaign begun new: the map, a battle, the Hall of Fame, the campaign's result. Checks `REGIONS.SAV` |
| `pbm-bullrun1` | A play-by-mail game: begun, written, continued as the other side and written again. Checks `SAVEGAME.PBM` |
| `pbmfix` | `pbmfix.exe` on the repo's `SAVEGAME.PBM`, which git stores with LF line ends: the fixed file is empty |
| `edit-bullrun1` | The editor: Load, Map Edit, Army Edit (a unit placed, changed, delayed, zapped and unzapped, and F10, item 9), Description, Save, Quit by a letter. Checks the saved scenario |
| `edit-random` | The editor's Random Scenario, saved, and Quit answered by Esc and by a letter. Checks the saved scenario |

### Writing a script by hand

Start from a few lines and let `explore` show where they lead:

```
python tests\play.py explore my.keys
```

It plays the keys, then writes a state at the next wait and stops there. Each screen of the run becomes a PNG in
`tests\out\explore\` (a text-mode screen is printed instead). Add a few lines, look, repeat. When the script ends
the program, put it in `scripts\`, run `record <name>`, and check that `record` says the four runs were the
same.

Points that matter:

- **Look at every screen before recording.** A step that lands on another wait than the one meant puts the
  following keys out of step, and the game often still reaches the end.
- **A wait that `play until` stops at is the script's to answer.** The next step after it must be its key.
- **No digest at the list of files**, which shows the folder's full path and the disk's free space.
- **`prompt` before every key** that a plain step gives. Each unit's turn starts with `BuffClear`, which throws
  away a key that came too early.
- **`Enput` announces once**, when it starts, not for each key. After `play until 4`, a `text` step and
  `key enter` give the whole line.
- **Choose menu entries by letter where you can**, but check the menu: the main menu's Parameters and Player
  share a letter, and the first entry with the letter wins.

## What the scripts do not cover

`play.py coverage` writes the lines that no script and no unit test reaches (`tests\out\coverage\report.txt`) and
a table per SUB, the least covered first (`tests\out\coverage\subs.txt`). The editor's are `report-cs.txt` and
`subs-cs.txt`.

Not covered:

- **Sound.** The scripts run with sound off and without the `s` option, so `sndblst`, `playsound` and the
  `PLAY` tunes do not run.
- **The boss screen.** It ends only with Ctrl+B, which a keys file cannot give.
- **The real `SHELL "copy ..."` and `SHELL "rename ..."`**, which `scriptshell` replaces under a script.
- **`RUN "cs.exe"` and `RUN "CW.EXE"`**, from the game to the editor and back. The program started by `RUN`
  would read the same keys file from its start.
- **Linux.** The scripts use Windows commands (`copy`, `rename`) through the game's `SHELL`, and file names of
  another case than the files.
