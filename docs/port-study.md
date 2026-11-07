# 44. Porting Civil War Battleset to QB64Rust: the plan

> **Moved from QB64Rust on 2026-11-06.** This study was `study\44-civil-war-battleset-port.md` in QB64Rust
> (`davidshq/QB64Rust`), whose history holds its earlier versions. Paths such as `DECISIONS.md`,
> `PORTING-PDS.md`, `SOMEDAY.md`, `DIVERGENCES-QB45.md`, `CLAUDE.md`, `verification\...` and
> `tools\qb45\...` are QB64Rust's.
> The decisions it led to were rows of QB64Rust's `DECISIONS.md`. They are copied in the
> section "Decisions recorded in QB64Rust".

> A bare `study\44`, `study\45` or `study\46` names one of the three moved studies:
>
> - `study\44` is Civil War Battleset's `docs\port-study.md` (`Hutsell-Games/civil-war-battleset`, branch
>   `qb64rust`);
> - `study\45` is Wars of Napoleon's `docs\won-source-study.md` (`Hutsell-Games/wars-of-napoleon`, branch
>   `won-source`);
> - `study\46` is Civil War Strategy's `docs\port-study.md` (`Hutsell-Games/civil-war-strategy`, branch
>   `qb64rust`).

Written 2026-11-06, for the user's review. The user answered the nine decisions of section 5 the same day, taking
every recommendation (`DECISIONS.md` 2026-11-06). The study stays open until the port is built (`CLAUDE.md`
working rule 7). Nothing in the game's repo has been changed yet.

The game is W.R. Hutsell's *Civil War Battleset* (`Hutsell-Games/civil-war-battleset`), cloned beside this repo
as `..\civil-war-battleset`. It is a tactical wargame of the American Civil War, written for BASIC PDS 7.1 and EGA.
The plan follows the World War 2 port (`Hutsell-Games/world-war-2`, branch `qb64rust`, 2026-11-04 to 2026-11-05).
The rules that port followed are now written down as section 0 of `docs\PORTING-PDS.md`. This plan applies them
and says where this game differs.

## 1. How the World War 2 port went

Taken from that port's commits, its `docs\devnotes.md`, `tests\README.md` and `TODO.md`, and the user's messages in
the sessions of 2026-11-04 and 2026-11-05.

1. The first port made `WW2.BAS` build as one program with QB64Rust and QB64pe. It merged the linked modules into
   `.BM` includes, wrote `DIR$` and the mouse with QB64 statements, and added `SCRIPT.BM` for the test hooks. It
   added `tests\play.py`, the whole-game scripts and a unit-test file (commit `19ba155`).
2. The user then asked for reviews, and for the pragmatic engineer's view after each review. Most of the later
   work came from those reviews:
   - the editor `EDIT.BAS` ported and given scripts;
   - sound played with QB64's own sound in place of the DOS players;
   - every `GOSUB` routine made to end by `RETURN`, after "Leave Edit" stopped the editor with "RETURN without
     GOSUB";
   - `CURDIR$` written as a FUNCTION, after a review found that both compilers built it silently as an empty
     variable;
   - the mouse rewritten to look at every mouse event, after the mouse script failed in 3 of 6 runs.
3. The user corrected two things on the way:
   - The builds take the DOS programs' names (`ww2.exe`, `edit.exe`), not new ones. The DOS programs leave the
     branch, and the builds are not committed.
   - A GitHub Actions workflow builds the game on each merge into `main`, and by hand.
4. Last came the cleanup: DOS-only files removed, the title screens captured in DOSBox, saved games and high
   scores moved to `tests\data\`, the data files moved into `graphics\`, `sound\` and `scenarios\`, and the
   documents into `docs\`.

Two things were found late and cost a second pass: the silent `CURDIR$`, and the `GOSUB` routines left by `GOTO`.
This plan does both searches first (step 2).

What it found in QB64Rust is in `docs\PORTING-PDS.md` section 5: the misleading message for `ON LOCAL ERROR`, the
silent `CURDIR$`, and the single `GOSUB` stack, which QB 4.5 and PDS 7.1 do not have (`DIVERGENCES-QB45.md`
Q-018).

## 2. The game

### Sources and programs

| File | Lines | What |
|---|---|---|
| `CIVWAR25.BAS` | 2,560 | The game's main module: 664 lines of module code, then 16 SUBs |
| `CIVWAR2B.BAS` | 2,368 | A linked module of 61 SUBs, with 10 lines of header |
| `CIVWAR2C.BAS` | 129 | The menu (`choices`, `menu`), linked into both the game and the editor |
| `CIV20.BI` | 96 | The shared declarations, mostly `COMMON SHARED` |
| `CIVSET24.BAS` | 2,265 | The scenario editor, one module. It calls `menu`, so it is linked with `CIVWAR2C` (measured: alone, it gives 11 errors "`CALL menu`: no SUB of this name") |
| `PBMFIX.BAS` | 22 | A small tool that removes extra line ends from a play-by-mail file |

`CW25MAKE.BTM` and `CIVWAR25.LNK` build the game as `CW.EXE`. The game starts the editor with `RUN "cs.exe"`
(`CIVWAR25.BAS` line 372), and the editor starts the game with `RUN "CW.EXE"` (`CIVSET24.BAS` line 381). So the
builds are `cw.exe` and `cs.exe`. The folder also holds `CIVWAR25.EXE` and `CW25.EXE`, older builds, and
`CIVWAR24.MAK`, which names a `CIVWAR24.BAS` that is not there.

### Data

- 82 `.CIV` files: about 61 scenarios, 9 campaign files (`CAMP00.CIV` to `CAMP08.CIV`), 7 `&*.CIV` files and 5
  saved games (`$AVE1.CIV` to `$AVE5.CIV`). The Load menu lists `*.civ`, so saved games and scenarios are listed
  together.
- 7 icon files (`*.EGA`, 3,135 bytes each). Each is a QB `GET` array, loaded by `BLOAD` into `Image(1 TO 1564)`
  and drawn with `PUT` (`iconload`, `CIVWAR25.BAS` line 952).
- 2 text screens, `VICTORY.SCR` and `NEWHI.SCR` (4,007 bytes: a 7-byte header and 80 × 25 characters with their
  colors). They are loaded by `BLOAD` into text memory at `&HB800` in `SCREEN 0` (`CIVWAR2B.BAS` lines 128 and
  2133).
- 16 `.WAV` files, the same ones that are in `SOUNDS.ZIP`.
- Name lists and settings: `MONTHS.DAT`, `PNAMES1.DAT`, `PNAMES2.DAT`, `RNAMES.DAT`, `YNAMES.DAT`, `UNION.LDR`,
  `REBEL.LDR`, `CAMPAIGN.INI`, `REGIONS.INI`, `PREFER.CFG`.
- Files that playing writes: `GENERALZ` and `MAXSKORS` (the generals' records and high scores), `REGIONS.SAV`,
  `SAVEGAME.PBM`, and the saved games.

### DOS programs with no source

- `CWBSTITL.EXE`, the title screen, which `CW.BAT` runs before the game.
- `YELL.EXE`, the rebel yell, which the game runs twice by `SHELL`.
- `PLANY.EXE` and `SOUND.EXE`, the sound players.
- The DOS builds of the sources: `CIVWAR25.EXE`, `CW25.EXE`, `CS.EXE` and `PBMFIX.EXE`.

### No mouse

The game has no mouse code. `Mighty` is declared in `CIV20.BI` but never used. So there is no `Mickey` to
rewrite, and no mouse scripts.

## 3. What was measured today

On a copy of the sources in a scratch folder outside both repos, with the release build of QB64Rust 0.3.0:

- Each file alone, `qb64rust --report unsupported` finds errors in four of the five programs (319 in
  `CIVWAR25.BAS`, mostly SUBs that are in the other modules).
- Merged the way World War 2 was (game: `CIVWAR25` + `CIVWAR2B` + `CIVWAR2C`; editor: `CIVSET24` + `CIVWAR2C`),
  with stand-in `DIR$` and `CURDIR$` FUNCTIONs, only these errors are left:
  - the game: `CHDRIVE` (`CIVWAR25.BAS` line 353), `ON LOCAL ERROR GOTO nosound` (`CIVWAR2B.BAS` line 2202)
    and `FRE(-1)` (`CIVWAR2C.BAS` line 99);
  - the editor: `CHDRIVE` (`CIVSET24.BAS` line 313) and `FRE(-1)`.
- No duplicate SUB names between the merged modules. Every `ON ERROR GOTO` label is in a main module, as QB64
  wants.

Nothing was built or run.

## 4. Where this game differs from World War 2

Each row says what the port does. "Measure first" means the behavior is not yet known in QB64Rust or QB64pe. It is
then measured with a small program before the game is changed.

**Steps 6 and 7 (2026-11-06), done and not yet committed:** the test hooks are in the game's `SCRIPT.BM`, and
the tests in its `tests\`: 26 unit tests, 159 generated scripts and 10 written by hand. QB64pe and QB64Rust gave
the same screens in every recording. Choices made in steps 6 and 7 wait for the user: D10 to D16 below. What
the tests found is in the game's `docs\devnotes.md`, "Step 7", "Found": three battles stop with an illegal
function call in the game's `cupdate` (D16), QB64's `FILES` scrolls the game's list of files by one line, the
editor could not load a short file name (fixed, item 11), and one `SHELL` hung once under load in a QB64pe
build.

**Step 4 (2026-11-06):** the game, the editor and `pbmfix` build with both compilers, and their first screens
are the same in both. The `whichsave` case of row 16 is confirmed: "RETURN without GOSUB" at `CIVWAR25.BAS` line
271, in both builds. `pbmfix` empties the repo's `SAVEGAME.PBM`, whose CR LF line ends git dropped in the first
commit (the game's `docs\devnotes.md`, "The first builds").

**Step 3 measured rows 3, 4, 9, 10, 11 and 14 (2026-11-06).** QB64Rust and QB64pe gave the same result every time,
and each form works as it did in DOS, so none needs a change. `COMMON SHARED` works in one program. `BLOAD` into
`&HB800` shows the text screen, with all 2,000 cells right. libqb emulates the BIOS keyboard buffer, so
`BuffClear` throws keys away and `PEEK(1052)` sees a waiting key. The icons draw identically. `RUN "cs.exe"` starts
the program. `_FILEEXISTS("*.civ")` gives 0, as row 4 expected. The details are in the game's `docs\devnotes.md`,
"The measurements". Rows 10 and 11 below are left as written in the plan. The two results that QB64Rust had not
recorded before are now corpus programs: `screen\d20_bload_text_memory` and `screen\k05_bios_keyboard_buffer`
(`DECISIONS-SMALL.md` 2026-11-06). `RUN` of an `.exe` is left to the game's scripts.

| # | What | Where, how many | What the port does |
|---|---|---|---|
| 1 | Three linked modules and one shared menu module | `CIVWAR2B`, `CIVWAR2C` | As World War 2: `git mv` to `.BM`, remove the headers, include them. `CIVWAR2C.BM` is included by both the game and the editor |
| 2 | The main module's `DIM SHARED` lines | `CIVWAR25.BAS` lines 11–17 | Move them to a game-only include, not to `CIV20.BI`: the editor declares the same icon arrays in its own main module (`CIVSET24.BAS` lines 23–28) |
| 3 | `COMMON SHARED` | `CIV20.BI`, 10 lines | Measure first. In one program, unnamed `COMMON SHARED` should act as `DIM SHARED`. If both compilers accept it, leave it |
| 4 | `DIR$` | 12 calls, 4 in each of `CIVWAR25`, `CIVWAR2B` and `CIVSET24` | Take `DIR$` from World War 2's `QB64.BM`. The earlier branch `canonical+1` used `_FILEEXISTS("*.civ")`; that is not taken, because `_FILEEXISTS` checks one name, not a pattern (to confirm) |
| 5 | `CURDIR$` | 8 calls: 4 in `CIVWAR25`, 4 in `CIVSET24` | Take `CURDIR$` from World War 2's `QB64.BM` |
| 6 | `CHDRIVE` | 2 calls, in the Change Directory menus | Write a `SUB CHDRIVE (d$)` with `CHDIR`. But see decision D2: changing the folder breaks data folders |
| 7 | `ON LOCAL ERROR` | 1, in `sndblst` | Removed together with the `SHELL "plany …"` it guards (row 12) |
| 8 | `FRE(-1)` | 1, in `menu`: a hidden key prints the free memory | QB64pe has no `FRE`. The line is commented out and noted in `devnotes.md` (done in step 4) |
| 9 | `BLOAD` of the icons into an array, then `PUT` | `iconload`, in both programs | Expected to work: QB64Rust already draws Civil War Strategy's `MTN.VGA` the same way, as the old compiler does (spec `language/conventional-memory`). Check the screens against QB64pe |
| 10 | `BLOAD` of a text screen into `&HB800` | `VICTORY.SCR`, `NEWHI.SCR`, and `scrnload` | Measure first. If it does not work, write a loader that reads the file and prints each character with its color |
| 11 | The BIOS keyboard buffer: `POKE 1050, 30: POKE 1052, 30` empties it, and `PEEK(1052) > 30` asks whether a key waits | `BuffClear` (both programs); `CIVWAR25.BAS` line 1448 (a key stops automatic play) | Measure first. If QB64 does not keep the buffer there, `BuffClear` empties nothing and automatic play cannot be stopped. Then write `BuffClear` with `INKEY$`, and the test with a QB64 statement that does not eat the key |
| 12 | Sound: `SHELL "plany " + mask$ + ".wav"` | `sndblst`, called from 26 lines | Play the WAV with `_SNDOPEN` and `_SNDPLAY`, as World War 2's `playsound`. QB64 opens WAV files, so no conversion is needed. `CW s` still turns sound on (`COMMAND$`, `CIVWAR25.BAS` line 20) |
| 13 | `SHELL "yell.exe"` | 2 places in `CIVWAR2B` | No source. Decision D4 |
| 14 | `RUN "cs.exe"` and `RUN "CW.EXE"` | 1 each | Measure first: whether `RUN` of an `.exe` starts it in both compilers (`verification\v57_r*` measured only a missing file and a `.bas` name) |
| 15 | `SHELL "copy generalz temp.$$$"` and `SHELL "copy maxskors temp.$$$"` | 2 in `CIVWAR2B` | Keep: `copy` works on Windows. A `TODO.md` row for Linux, as in World War 2 |
| 16 | A `GOSUB` routine that leaves its SUB before `RETURN` | Found so far: `crsr` in `menu` (`CIVWAR2C.BAS`: Esc or a letter does `GOTO called`, the World War 2 bug in the menu both programs use); `otherside` in `order` (`CIVWAR25.BAS` line 1640, `EXIT SUB`); `eval` in `general` (`CIVWAR2B.BAS` line 1425, `GOTO improve`); `wait8` in the editor's `placearmy` (`CIVSET24.BAS` line 1193, F10 does `EXIT SUB`) | Read every `GOSUB` routine in a SUB: there are 110 `GOSUB`s in the editor and 68 in the game. Fix each as World War 2 did: the routine sets a flag and returns, and the line after the `GOSUB` makes the jump. **Done in step 2 (2026-11-06):** of 75 routines in 16 SUBs, these four are all that can leave. Expected to stop the programs: `otherside`'s `RETURN` after `general` (the computer's turn), the game's `whichsave` and the editor's `yorn` and `battle` after `menu` (the game's `docs\devnotes.md`, "The searches before the port") |
| 17 | The clock on the screen | `DATE$` and `TIME$` in a saved game's description (`CIVWAR25.BAS` line 238); the time played on the final report (`CIVWAR2B.BAS` line 1583); a timer in the editor (`CIVSET24.BAS` lines 1746–1761) | Test hooks: a fixed date, time and time played when the game is scripted |
| 18 | Random numbers in the editor | `RANDOMIZE TIMER`, `CIVSET24.BAS` line 36; random maps and armies (`randmap`, `randarm`) | Unlike World War 2's editor, this one takes the scripts' seed too |
| 19 | The waits for a key | 26 lines with `INKEY$` (14 in the editor), `TICK`, `Enput`, `curser`, `menu`, and 6 `INPUT`s of a number or a name | Each gets an `announce` call, as in World War 2 |
| 20 | Play by mail | `SAVEGAME.PBM` (coded with `codex`), the file `temp.&&&`, `PBMFIX.BAS` | Port `PBMFIX.BAS` as a third program (decision D5). A script plays a PBM game: World War 2 never did |
| 21 | Names of different case | `'civ20.bi'` against `CIV20.BI`; the code opens lower-case names, the files are upper case | Works on Windows. A `TODO.md` row for Linux, as in World War 2 |

## 5. Decisions for the user

The panel for these decisions: the pragmatic engineer, the QB64 engineer, the compiler engineer, the Rust engineer,
the test engineer, and one more role, a QB64 user porting an old program, since this port is the second real test
of what such a user meets (as in `study\43`).

**D1. Start from `main`, on a new branch `qb64rust`.** The earlier branches (`canonical+1`, `canonical+2`,
`carried-away`, `basic-runs`, December 2024) moved files into eight folders, reformatted the code and removed the
registration box. They are not used. Their folder names may still help with D2.
*Panel:* all agree. The QB64 engineer adds that `canonical+1` replaced `DIR$` by `_FILEEXISTS` with a pattern,
which would quietly find nothing (row 4). **Recommended: yes.**
**User (2026-11-06): yes.**

**D2. Data folders, and the Change Directory menu.** Both programs have a menu entry "Directory" that runs
`CHDRIVE` and `CHDIR`. It lets a player keep scenarios in another folder. After it, every file the game opens is
looked for in the new folder: the sounds, `GENERALZ`, `MAXSKORS` and `PREFER.CFG`. With data folders the game
would no longer find them.
- (a) Folders as in World War 2 (`graphics\`, `sound\`, `scenarios\`), with every data folder's name made from
  the folder the program started in. The Directory menu then changes only where `.civ` files are read and
  written. This changes more lines.
- (b) Folders, and the Directory menu kept as it is, with a `TODO.md` row: after a change of folder, sounds and
  records are not found.
- (c) No folders: everything stays beside the program, as in DOS.

*Panel:* the pragmatic engineer prefers (c) for the first pass and (a) later, since folders change many lines
and the screens would not show it. The QB64 user wants folders: a folder of 155 files is hard to work in, and the
user chose folders for World War 2. The test engineer notes that scripts can check the Directory menu in any of
the three. The compiler and Rust engineers have no view. **Recommended: (a), done in step 8, after the scripts
exist,** so that the scripts show it changed nothing. Saved games stay with the scenarios, because the Load menu
lists them together.
**User (2026-11-06): (a).**

**D3. Program names `cw.exe` and `cs.exe`.** These are what the code runs. `CIVWAR25.EXE`, `CW25.EXE` and `CS.EXE`
leave the branch. *Panel:* all agree; the user set this rule for World War 2. **Recommended: yes.**
**User (2026-11-06): yes.**

**D4. The rebel yell.** `YELL.EXE` has no source and is the only place the yell is.
- (a) Drop it, and note the loss in `devnotes.md`.
- (b) Run it in DOSBox, record its sound to a WAV with DOSBox's audio capture, and play that WAV where the game ran
  `yell.exe`. The DOS program leaves the branch either way.

*Panel:* the QB64 user and the QB64 engineer prefer (b): the yell is part of the game, and a player hears it each
battle. The pragmatic engineer accepts (b) if the capture works the first time; if it does not, (a) with a
`TODO.md` row. The test engineer notes that scripts run without sound, so neither choice changes a test.
**Recommended: (b), falling back to (a).**
**User (2026-11-06): (b).**

**D5. `PBMFIX.BAS`.** Port it as a third program, `pbmfix.exe`, or leave it on `main` only. It is 22 lines of plain
file reading. *Panel:* port it. It probably builds unchanged, and a player of a PBM game may need it. The test
engineer wants one unit test or script for it. **Recommended: port it.**
**User (2026-11-06): port it.**

**D6. The title screen `CWBSTITL.EXE`.** As in World War 2: run it in DOSBox, keep a screenshot in `docs\`, and do
not run it. *Panel:* agreed; redrawing it in BASIC is a later `TODO.md` row, as in World War 2.
**Recommended: yes.**
**User (2026-11-06): yes.**

**D7. Where the large script runs go.** `CLAUDE.md` working rule 6 sends a run of more than about 20 programs to
the suites VM. With about 61 scenarios × 2 sides, this game will have more than 120 scripts, and `record` plays
each one five times. World War 2's `play.py` ran its 40 scripts on the host, on a desktop of their own that the
user never sees.
- (a) `play.py check` of all scripts on the host, as for World War 2. It shows nothing and asks nothing.
- (b) Whole runs (`check` of all, `record` of all, `make_scripts.py`) in the suites VM. On the host only a few
  scripts named one by one.

*Panel:* the pragmatic engineer and the test engineer prefer (a): `play.py` runs no network program and opens no
window the user sees, which are the two reasons for the rule. The QB64 engineer notes that eight jobs at once
still slow the user's machine, so the default stays at 4. **Recommended: (a), with `--jobs 4`.** If the user
wants (b), the VM needs the game's repo and `play.py` support first, which is more work than this plan counts.
**User (2026-11-06): (a).** `CLAUDE.md` working rule 6 now says so.
**Found later the same day:** the game's `SHELL` commands open console windows on the user's desktop, which the
hidden desktop does not cover. The runs of steps 6 and 7 did so for about two and a half hours. The recording
was stopped. Rule 6 now asks that no `SHELL` can run under a port's scripts before they run on the host.

**D8. Which scenarios get scripts.** World War 2 had 7 scenarios, each played by both sides in two styles. Here
there are about 61.
- (a) Every scenario, both sides, one style (end each turn at once, so the computer plays). Then the `enter`
  style for 6 to 8 scenarios of different kinds, plus hand-written scripts.
- (b) Every scenario in both styles.

*Panel:* the test engineer prefers (a): the end-turn style already runs the computer's play and the battle rules
in every scenario. The second style adds most for the menus, which are the same in every scenario. The pragmatic
engineer agrees and asks for the coverage numbers to decide whether more are needed. **Recommended: (a).**
**User (2026-11-06): (a).**

**D9. A QB64Rust warning for a `GOSUB` left inside a SUB (optional, not part of the port).** Two games by the same
author now have the pattern of row 16. QB64Rust could warn when a `GOSUB` routine can reach `EXIT SUB`, `END SUB`
or a `GOTO` out of the routine. *Panel:* the compiler engineer says it fits the open change `lints`. The Rust
engineer notes that it needs the control-flow graph of the SUB, which `unreachable` in that change also needs.
The pragmatic engineer wants it as a `SOMEDAY.md` row now and built only with `lints`. **Recommended: a
`SOMEDAY.md` row, and a mention in `openspec\changes\lints`, both done when the user agrees.**
**User (2026-11-06): a `SOMEDAY.md` row** ("Other ideas raised during the study"). The change `lints` is not
changed.

### Choices made in steps 6 and 7, for the user to rule on (2026-11-06)

Steps 6 and 7 were done while the user was away, so these were decided by Claude and are built that way. Each can
still be changed. The game's `docs\devnotes.md` ("Step 6", "Step 7") and `tests\README.md` describe what was
built. The panel is the same as above.

**D10. Under a script, `TICK` of 99 seconds or more waits for a key.** World War 2's hook made every timed pause
return at once. This game uses `TICK 99` and `TICK 999` as "hit a key": the results of a battle, the help, the Hall
of Fame, a new high score, a campaign victory. Shorter pauses still return at once.
- (a) As built: 99 seconds or more is a wait for a key (place 1), so scripts see and digest those screens.
- (b) Every pause returns at once, as in World War 2. Scripts would not see those screens.

*Panel:* the test engineer wants (a): the results screen is the best single check of a whole battle. The QB64
engineer notes that no shorter `TICK` is used as "press a key", so the line at 99 is clean. The pragmatic engineer
agrees. **Recommended: (a).**

**D11. Under a script, `CURDIR$` shows the folder the program started in as `C:\CWB`.** Both main menus show the
folder in their Directory entry. Without a hook, the full path would be in every digest of the main menu. It
would differ for QB64pe and QB64Rust, whose runs go in different folders, and on every machine.
- (a) As built: `CURDIR$` itself maps the start folder to `C:\CWB` when the program is scripted (`scriptfolder$`
  in `SCRIPT.BM`, called from `QB64.BM`). No line of the game changes. Under a script, the Directory menu's field
  starts with `C:\CWB` too, so Enter there would try that folder.
- (b) Map only the shown text: four lines of the game and the editor call a display function, and `CURDIR$`
  stays true. Four more changed lines.
- (c) No hook: no script takes a digest of a main menu. Most scripts lose their first and last checks.

*Panel:* the pragmatic engineer prefers (a): no game line changes, and only a script can see the difference. The
test engineer accepts (a) and notes that the `directory` script uses a path on drive C that does not exist, so it
gives the same error everywhere. The QB64 user would rather keep `CURDIR$` true, (b). **Recommended: (a).**

**D12. The second generated style is Computer vs. Computer, not "Enter at every command".** D8 (a) named an
`enter` style for 6 to 8 scenarios. Here Enter at a unit's command opens the Unit Command menu, whose first entry
is Move to location. For an emplaced gun that entry is "{not available}": Enter goes back to the same command,
so the battle never ends. So the second style is `auto-<scenario>`: Parameters, Computer vs. Computer, for eight
scenarios. It runs the computer's play for both sides and the code of automatic play (`minsec`, the check of
the keyboard buffer).
- (a) As built: `auto` for eight scenarios.
- (b) An `enter` style that rests the units Enter cannot move. It needs to know each unit's type from the screen,
  which the rules cannot see.

*Panel:* the test engineer wants (a), with the hand-written `commands-bullrun1` covering the Unit Command menu
and the cursor. The pragmatic engineer agrees. **Recommended: (a).**

**D13. The editor's list of files now trims the name it gives** (the game's `docs\devnotes.md`, item 11). The
editor could not load a scenario whose name is shorter than 8 characters, because `FILES` pads the name with
blanks and Windows does not ignore them. DOS did. This is one added line, copied from the game's own list, and
it changes how the editor behaves.
- (a) Keep it, as built.
- (b) First measure in DOSBox that the original `CS.EXE` loads such a file, then keep it.
- (c) Take it out, and leave short names unloadable in the editor (a `TODO.md` row).

*Panel:* the QB64 engineer is confident that DOS ignored the blanks (names are stored padded to 8 characters), so
the fix restores what DOS did. The pragmatic engineer wants (a) now and (b) only if the user wants proof. The
test engineer notes that `edit-bullrun1` uses `BULLRUN1.CIV`, which worked before. **Recommended: (a).**

**D14. QB64's `FILES` scrolls the game's list of files by one line** (`docs\devnotes.md`, "Step 7", "Found"). The
first four files of the list, `$AVE1.CIV` to `$AVE4.CIV`, cannot be chosen there. Saved games still load
through `$AVE5.CIV` and the slot menu after it. Both compilers do the same, as both use libqb's `FILES`.
- (a) Leave it, as built: the scripts work with it, and `make_scripts.py` counts from the fifth file.
- (b) Measure in DOSBox whether QB 4.5 or PDS 7.1 `FILES` also ends with a line that scrolls. If DOS did not
  scroll, it is a QB64 divergence for QB64Rust's `QB64PE-DIVERGENCES.md` and a QB64Rust question, and the game
  could be changed so that the list fits.

*Panel:* the QB64 engineer wants (b), as it may be a libqb divergence that QB64Rust should know about. The
pragmatic engineer agrees but not before step 8, since a fix would move every generated script's keys.
**Recommended: (b), after step 8, with a `TODO.md` row now.**

**D15. `pbmfix` is tested only on the repo's `SAVEGAME.PBM`**, which git stores with LF line ends, so its fixed
file is empty. A test of what `pbmfix` is for needs a PBM file with CR LF line ends and extra line ends.
- (a) Leave it until step 8, which makes `tests\data\`. Then add such a file there, marked `-text` in
  `.gitattributes` so git keeps its CR LF, and a script that runs `pbmfix` on it.
- (b) Do it now.

*Panel:* the test engineer wants the real case tested. The pragmatic engineer prefers (a): step 8 makes the
folder anyway, and `play.py` already copies `tests\data\` over the repo's files. **Recommended: (a).**

**D16. The computer's move can stop the game with "Illegal function call"** (the game's `docs\devnotes.md`, "Step
7", "Found"). `cupdate` reads `SCREEN(ynew + 1, xnew)` with `xnew` 0 when a unit in column 2 moves left. DOS would
stop on it too, so it is the game's own bug. Three generated scripts reach it (`BOLD.CIV` as the Confederates,
`ANTIETM2.CIV` as either side) and are not written.
- (a) Leave the game as it is; the three scripts stay unwritten, with a `TODO.md` row (as built).
- (b) Fix it: keep `xnew` at 2 or more before the `SCREEN`, one line. Then write the three scripts. The other
  scripts do not change, as the line only ran where the game stopped.
- (c) Leave the game, and give the three scripts another seed.

*Panel:* the QB64 user wants (b): a player meets the crash too. The pragmatic engineer notes that the plan
excludes "a fix to how the game plays", and that (b) is a fix to a crash, not to the play; it is the user's
call. The test engineer prefers (b) over (c), as (c) hides a crash the tests found. **Recommended: (b), as a
numbered change in `devnotes.md`, if the user agrees that a crash fix is in scope.**

## 6. The plan

Each step ends with a review of its changes, the user staging them, and one commit. Claude never stages
(`CLAUDE.md` rule 1). From step 6 on, each step also runs `play.py check`, and any screen that changes is either a
mistake or is named in the commit message.

1. **The branch.** Make `qb64rust` from `main` in `..\civil-war-battleset`.
2. **The searches, before any edit.** Write the results into the new `docs\devnotes.md`:
   - every PDS-only name of `SOMEDAY.md`'s list "Popular BASIC PDS 7.1 features", and `CHDRIVE`, `FRE`,
     `CURDIR$`, `DIR$`, `ON LOCAL ERROR`, `COMMON`;
   - every `GOSUB` routine in a SUB, read one by one, with the ones that can leave before `RETURN` (row 16);
   - every `PEEK`, `POKE`, `DEF SEG`, `BLOAD` and `SHELL`, with what each one did in DOS.
3. **The measurements.** Small programs for rows 3, 10, 11 and 14, built with both compilers and run on the host
   one by one. Where QB64Rust differs from QB64pe, or a result is new, the program goes into QB64Rust's
   `verification\` with its recorded output.
4. **One program each, building.** Rows 1, 2, 4–8 and 12. The game is `CIVWAR25.BAS`, including `CIV20.BI`, a
   game-only include for its `DIM SHARED` lines, `CIVWAR2A.BM` (the main module's 16 SUBs, unchanged),
   `CIVWAR2B.BM`, `CIVWAR2C.BM` and `QB64.BM`. The editor is `CIVSET24.BAS`, including `CIVWAR2C.BM` and
   `QB64.BM`. Build `cw.exe` and `cs.exe` with both compilers, and `pbmfix.exe` (D5). Play the first screens by
   hand and compare the two builds.
5. **What DOS did that QB64 does not.** Rows 10, 11, 13 and 14, as the measurements found. The `GOSUB` fixes of
   row 16. The DOSBox screenshot (D6) and the yell (D4). From the review of step 4 (2026-11-06, the pragmatic
   engineer's recommendation, user: "do prag recs"):
   - **The yell comes first.** Until it replaces `SHELL "yell.exe"`, a game started with an option (`cw s`)
     runs a DOS program that 64-bit Windows cannot run, and is expected to show a dialog box. The game's
     `docs\devnotes.md` says not to start it that way until then.
   - **In the same DOSBox session, measure whether `PLANY` takes the key that ends a sound.** Its document says
     only that a key ends the playback. `playsound` now leaves the key for the game to read. If `PLANY` took it,
     `playsound` must take it too. This is settled before steps 6 and 7 record any screens, so that no
     recording has to be made again.
6. **The test hooks** (`SCRIPT.BM`): the seed from an environment variable (`CWB_SEED`), an `announce` before
   each wait (row 19), `TICK` returning at once, and the fixed date, time and time played (row 17). The editor
   takes the seed too (row 18). The game plays as before when the variable is not set.
7. **The tests.**
   - `tests\play.py`, `tests\make_scripts.py` and `tests\test_play.py`, adapted from World War 2's (the user's
     own code).
   - Unit tests in `tests\rules_test.bas` for SUBs that draw nothing. Candidates, to check one by one: `Bubble`
     (a sort), `codex` (the PBM coding: a round trip), `YouorMe`, `rank`, `commander`.
   - Generated scripts (D8), and hand-written scripts for: the menus and options, a saved game loaded again, a
     campaign, a two-player game, a PBM game and `pbmfix.exe`, the Directory menu, each `GOSUB` fix of row 16,
     and the editor (load, change, random map, save, load again, with the saved files' hashes).
   - `record` with both builds, then `play.py coverage`. World War 2 reached 81% of its lines; the aim here is
     the same order, and the uncovered SUBs go into `TODO.md`.
8. **The files.** Remove what the port does not use, as listed in section 2 (DOS programs, `.BAT`, `.PIF`,
   `.MAK`, `.LNK`, `.OBJ`, `.BTM`, `CWSND.CFG`, `SOUNDS.ZIP`). Check before each one that the game does not need it
   to exist. Move the saved games, `GENERALZ`, `MAXSKORS`, `REGIONS.SAV` and `SAVEGAME.PBM` to `tests\data\`, and
   ignore the copies that playing makes. Then the folders of D2, and the documents (`CW.DOC`, `CS.DOC`,
   `SOUNDS.DOC`, `WRHGAMES.DOC`, `README.TXT`) into `docs\`. `play.py check` shows that the screens did not
   change.
9. **The build on GitHub Actions.** World War 2's `build.yml`, with the artifact `civil-war-battleset`: `cw.exe`,
   `cs.exe`, `pbmfix.exe` and the data folders.
10. **The documents.**
    - In the game's repo: `README.md` (a section for the branch, as World War 2's), `docs\devnotes.md` (the
      numbered changes, what was checked, what it found in QB64Rust), `tests\README.md`, and `TODO.md`.
    - In QB64Rust: what the port found goes into `docs\PORTING-PDS.md` (sections 2, 3 and 5), and new rows into
      `DECISIONS.md` and `SOMEDAY.md` where the user decides something.

Not in the plan: any refactoring, reformatting, a fix to how the game plays, and removing the shareware or
registration text. Each of these is a `TODO.md` row if it comes up.

## 7. Risks

- **Rows 10 and 11, the text screens and the keyboard buffer.** No longer risks: both work unchanged in both
  compilers (step 3).
- **Row 16, the `GOSUB` routines.** The menu that both programs use has the World War 2 bug. Until it is fixed, a
  script that picks a menu entry by its letter may stop with "RETURN without GOSUB". The fix comes in step 5,
  before the scripts.
- **Row 15, `SHELL "copy …"` under load.** Civil War Strategy's script `screen/g12_game.files` hangs in
  `SHELL "copy cws.his oldhist.ory"` late in long runs at `--jobs 8`, and passes alone (`STATUS.md`, known bugs).
  This game copies `GENERALZ` and `MAXSKORS` the same way, so a whole `check` may see the same timeouts. If it
  does, a script that times out is run again alone before it is taken as a failure.
- **Run time.** World War 2's 40 scripts take about 35 seconds with 6 jobs. More than 120 scripts would take a
  few minutes for `check`, and `record` plays each five times. `make_scripts.py` took 15 minutes for World War 2
  and may take an hour here. Both run in the background.

## Decisions recorded in QB64Rust

Copied from QB64Rust's `docs\DECISIONS.md` when the study moved here (2026-11-06). The rows are no longer
kept there.

| Date | Decision | Where the details are |
|---|---|---|
| 2026-11-06 | **Civil War Battleset is ported to QB64Rust the way World War 2 was** (user answered the nine decisions of `study\44`, taking every recommendation). The port starts from `main` on a new branch `qb64rust`; the earlier branches `canonical+1`, `canonical+2`, `carried-away` and `basic-runs` are not used. The builds are `cw.exe`, `cs.exe` and `pbmfix.exe`, the names the programs start each other by. Data goes into `graphics\`, `sound\` and `scenarios\`, each named from the folder the program started in, so that the Change Directory menu changes only where `.civ` files are read and written; this is done after the scripts exist. The rebel yell of `YELL.EXE`, which has no source, is recorded to a WAV in DOSBox and played where the game ran it; if the capture fails, it is dropped and noted. The title screen `CWBSTITL.EXE` is kept as a DOSBox screenshot. Every scenario gets an end-turn script for each side, and 6 to 8 scenarios get the `enter` style. The game's `tests\play.py` runs all its scripts on the host, on its hidden desktop, with 4 jobs: it opens no window the user sees and runs no network program. A warning for a `GOSUB` routine that leaves its SUB is a `SOMEDAY.md` row | `study\44`; `docs\PORTING-PDS.md` section 0; `CLAUDE.md` working rule 6; `SOMEDAY.md`, "Other ideas raised during the study" |
