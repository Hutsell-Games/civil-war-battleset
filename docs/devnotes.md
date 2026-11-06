# Developer notes: branch `qb64rust`

This branch starts from `main`, the original BASIC PDS 7.1 source. It will change as little as possible so that
the game builds with QB64Rust and with QB64pe, and so that its SUBs can be tested. The plan is QB64Rust's
`study\44-civil-war-battleset-port.md`. It follows the port of World War 2 (`Hutsell-Games/world-war-2`, branch
`qb64rust`) and the principles in QB64Rust's `docs\PORTING-PDS.md`, section 0.

This file holds what was changed from `main` and why, and the results of the plan's steps: the searches made before
any edit (step 2), the measurements of what the searches left in doubt (step 3), and the first builds (step 4).

## Build

```
qb64rust -x CIVWAR25.BAS -o cw.exe
qb64rust -x CIVSET24.BAS -o cs.exe
qb64rust -x PBMFIX.BAS -o pbmfix.exe
```

Keep the names `cw.exe` and `cs.exe`: the game's Scenario Editor entry runs `cs.exe`, and the editor's game entry
runs `CW.EXE`. Until the DOS programs `CS.EXE` and `PBMFIX.EXE` are removed from this branch (step 8 of the plan),
a build of those names in this folder overwrites them, so build elsewhere and copy the data files beside it.

**Do not start the game with an option (`cw s`) yet.** Any option turns the sounds on, and then the game runs the
DOS program `YELL.EXE` in a battle (`CIVWAR2B.BM` lines 1724 and 2038). 64-bit Windows cannot run it, and is
expected to say so in a dialog box. Step 5 of the plan replaces it.

## What was changed from `main`, and why

1. **One program for the game, instead of three linked modules.** QB64 builds one source file. `CIVWAR2B.BAS` and
   `CIVWAR2C.BAS` were renamed to `.BM` (with `git mv`) and are included at the end of `CIVWAR25.BAS`. Their headers
   were removed: `DEFINT A-Z`, their `DECLARE` lines and the include of `civ20.bi`. The main module already has
   `DEFINT A-Z` and the include, and QB64 does not need a `DECLARE` for a SUB the program defines.
2. **The 16 SUBs of `CIVWAR25.BAS` moved to `CIVWAR2A.BM`, unchanged.** A test file can then include the `.BI`
   and `.BM` files and get every SUB without the main module's code. Put back together, `CIVWAR25.BAS`,
   `CIVWAR25.BI` and `CIVWAR2A.BM` give the original `CIVWAR25.BAS` byte for byte.
3. **The 7 `DIM SHARED` lines of `CIVWAR25.BAS` moved to `CIVWAR25.BI`**, which the main module includes where
   they were. They are the icon arrays. A test file needs them too. They are not in `CIV20.BI`, because the editor
   includes `CIV20.BI` and declares its own icon arrays.
4. **The editor includes the menu module.** `CIVSET24.BAS` calls `menu`, which is in `CIVWAR2C.BM`, so PDS linked
   the two. It now includes `CIVWAR2C.BM` at its end, and `QB64.BM`.
5. **`DIR$`, `CURDIR$` and `CHDRIVE` are written in `QB64.BM`** with QB64's `_FILES$`, `_CWD$` and `CHDIR`. `DIR$`
   and `CURDIR$` are World War 2's. No call changed: every `DIR$` call has an argument. Without these, both
   compilers read `DIR$("*.civ")` as an array, build `CURDIR$` as an empty string variable, and reject `CHDRIVE`.
6. **The sounds play through QB64's own sound** (`playsound` in `QB64.BM`). The DOS game ran
   `SHELL "plany " + mask$ + ".wav"` in `sndblst` (`CIVWAR2B.BM`), under `ON LOCAL ERROR GOTO nosound`, which QB64
   does not have. The handler printed "Sound Driver Error Encountered" when `PLANY.EXE` could not run. The `SHELL`,
   the `ON LOCAL ERROR` and the handler are gone, and `sndblst` calls `playsound`. As with `PLANY` ("Press any key
   during playback to terminate output", `PLANY.DOC`), a key ends the sound. The key stays for the game to read;
   whether `PLANY` also took the key is not known. A missing file is silent. As in DOS, `cw s` turns the sounds
   on. `SHELL "yell.exe"` is not changed yet (decision D4, step 5).
7. **`FRE(-1)` is commented out** (`menu`, `CIVWAR2C.BM`). QB64pe has no `FRE`. In DOS, Alt+= at a menu printed the
   free memory at the top left; now Alt+= does nothing, as any other key the menu does not use.

## The searches before the port (2026-11-06)

The sources searched: `CIVWAR25.BAS`, `CIVWAR2B.BAS`, `CIVWAR2C.BAS`, `CIV20.BI` (the game), `CIVSET24.BAS` (the
editor, which also uses `CIVWAR2C.BAS`) and `PBMFIX.BAS`. Comments and string literals were left out.

### 1. Names that BASIC PDS 7.1 has and QB64 does not

The names searched for are the list "Popular BASIC PDS 7.1 features" in QB64Rust's `docs\SOMEDAY.md`, the
PDS-only statements and functions that list leaves off (ISAM, far strings, `STACK`, `UEVENT`), and the QB 4.5
forms that QB64 lacks or treats differently (`FRE`, `COMMON`, `SETMEM`, `ERDEV`, `IOCTL`, `INTERRUPT`,
`ABSOLUTE`, `SADD`, `PEN`, `STRIG`, `CHAIN`, `$DYNAMIC`, `$STATIC`). A name ending in `@` (the currency type) was
looked for too.

| Name | Where | What the port does |
|---|---|---|
| `DIR$` | 12 calls. `CIVWAR25.BAS` lines 314, 629, 634, 1024; `CIVWAR2B.BAS` lines 100, 115, 234, 242; `CIVSET24.BAS` lines 252, 264, 406, 498 | A `FUNCTION DIR$` with QB64's `_FILES$`, as in World War 2. Every call passes an argument, so no call changes. Without the FUNCTION, both compilers read `DIR$("*.civ")` as an array with a string index |
| `CURDIR$` | 8 calls. `CIVWAR25.BAS` lines 72, 342, 347, 353; `CIVSET24.BAS` lines 61, 302, 307, 313 | A `FUNCTION CURDIR$` with `_CWD$`, as in World War 2. Without it, both compilers build `CURDIR$` as a string variable that is always `""`, with no message |
| `CHDRIVE` | 2 calls, in the Change Directory menus: `CIVWAR25.BAS` line 353, `CIVSET24.BAS` line 313 | A `SUB CHDRIVE` with `CHDIR`. The data folders (decision D2 of the plan) also change what this menu does |
| `ON LOCAL ERROR GOTO nosound` | 1, `CIVWAR2B.BAS` line 2202, in `sndblst` | Removed with the `SHELL "plany …"` it guards (section 3) |
| `FRE(-1)` | 1, `CIVWAR2C.BAS` line 99, in `menu`: Alt+= (the extended key with scan code 131) prints the free memory at the top left | QB64pe has no `FRE`. The line is commented out (item 7 above) |
| `COMMON SHARED` | 10 lines, `CIV20.BI` lines 78 and 80 to 88. No named blocks | Kept: in one program it acts as `DIM SHARED` (measured, "The measurements" below) |

None of the other names was found: no currency type, no `BYVAL`, no `REDIM PRESERVE`, no `FORMAT$` or date and
financial functions, no ISAM, no far strings. There is no `TYPE` and no `$DYNAMIC` or `$STATIC`.

### 2. `GOSUB` routines that can leave their SUB before `RETURN`

QB64pe and QB64Rust keep one `GOSUB` stack for the whole program. When a SUB ends while one of its own `GOSUB`
routines is still pending, the routine's entry stays on the stack. The next `RETURN` outside the SUB takes that
entry and stops the program with "RETURN without GOSUB". QB 4.5 and PDS 7.1 drop the entry when the SUB ends, so
the original worked. World War 2's editor stopped this way (its `docs\devnotes.md`, items 11 and 12; QB64Rust's
`DIVERGENCES-QB45.md` Q-018).

**How the routines were found.** A script built the control-flow graph of each SUB, line by line. It follows
`GOTO`, `ON … GOTO`, single-line and block `IF`, `SELECT CASE`, loops, `EXIT DO` and `EXIT FOR`, and counts any
branch of a block as possibly taken. For each `GOSUB` routine, it looked for a way from the routine's label to
`EXIT SUB` or `END SUB` that passes no `RETURN`. Each routine it named was then read by hand.

There are 75 `GOSUB` routines in 16 SUBs: 14 in `order`, 2 in `placeunit`, 1 each in `cupdate`, `customize`,
`email`, `general`, `retreat`, `scrcol` and `variety`, 3 in `report`, 2 in `victory`, 4 in `menu`, 7 in
`drawmap`, 31 in `placearmy`, 1 in `randarm` and 4 in `terrane`. Four of them can leave their SUB:

| Routine | SUB | How it leaves | When |
|---|---|---|---|
| `crsr` | `menu` (`CIVWAR2C.BAS` line 77) | `GOTO called` when an entry is chosen by its first letter (line 87) or with Esc (line 82). `called` runs on to `END SUB` | At any menu of the game or the editor. Enter and the arrow keys return normally |
| `otherside` | `order` (`CIVWAR25.BAS` line 1638) | `EXIT SUB` when the other side has no moves left (line 1640). `GOTO human` when play passes to the other player (line 1661); from there the SUB goes on to `EXIT SUB` (line 1634) | In a two-player game, at each change of side |
| `eval` | `general` (`CIVWAR2B.BAS` line 1420) | `GOTO improve` (line 1425), which runs on to `END SUB` | When a square beside the unit holds one of the characters the line tests. The computer's play calls `general` |
| `wait8` | `placearmy` (`CIVSET24.BAS` line 1192) | `EXIT SUB` on F10 with no unit in hand (line 1194) | In the editor, each time F10 ends the placing of armies, which is the usual way back to the main menu |

**Where a stale entry is taken.** These are the `RETURN`s that would take one of the stale entries:

- `general` is called only from `otherside` (`CIVWAR25.BAS` lines 1726 and 1741), and each call is followed by a
  `RETURN` of `otherside` (lines 1727 and 1744). So once `eval` leaves by `GOTO improve`, that `RETURN` is
  expected to stop the game with "RETURN without GOSUB", during the computer's turn.
- In the game's main module, `whichsave` (lines 256 to 277) calls `menu`. A saved game chosen by its letter, or
  Esc, leaves `crsr`'s entry, and `whichsave`'s `RETURN` takes it.
- In the editor's main module, `yorn` (lines 393 to 400) and the routine `battle` (from line 213) call `menu`.
  This is World War 2's case: there, "Leave Edit" answered with `y` stopped the editor.

These are expected from the code and from World War 2's measurements. They have not been seen yet, because the
port does not build yet (step 4 of the plan). The fix will be World War 2's: the routine sets a flag and
returns, and the line after the `GOSUB` makes the jump.

The main modules' own routines (6 in the game, 4 in the editor) were not searched in the same way. A main-module
routine that leaves by `GOTO` leaves an entry too, but no SUB ends over it, so it cannot cause this error.

### 3. Memory, `BLOAD`, `SHELL` and `RUN`

What each one did in DOS:

| Statement | Where | What it did in DOS | What the port does |
|---|---|---|---|
| `DEF SEG = VARSEG(Image(1))`, `BLOAD "<name>.ega", VARPTR(Image(1))` | `iconload`: `CIVWAR25.BAS` lines 959 to 1030 (6 files: `STDICON`, `ALTICON`, `TERRAIN`, `MISC`, `YANK`, `REB`); `CIVSET24.BAS` lines 1010 to 1045 (3 files) | Loaded a picture saved by `BSAVE` into an array, as a QB `GET` array. `PUT` then drew it, and `GET` cut the icons out of it | Expected to work unchanged: QB64Rust draws Civil War Strategy's `MTN.VGA` the same way. The screens are compared with QB64pe's |
| `DEF SEG = &HB800`, `BLOAD "victory.scr", 0` | `CIVWAR2B.BAS` lines 128 to 130 | Loaded a whole text screen (80 × 25 characters and colors) straight into the text memory of `SCREEN 0` | Kept: it works in both compilers (measured, "The measurements" below) |
| `DEF SEG = &HB800`, `BLOAD t$, 0` | `scrnload`, `CIVWAR2B.BAS` lines 2133 to 2135, called once with `newhi.scr` (line 1484) | The same, for the high-score screen | Kept, as the row above |
| `DEF SEG = 0`, `POKE 1050, 30`, `POKE 1052, 30` | `BuffClear`, `CIVWAR2B.BAS` lines 65 and 66; `CIVSET24.BAS` lines 515 and 516 | Set the head and the tail of the BIOS keyboard buffer (bytes `&H41A` and `&H41C`) to its start, so that keys typed ahead were thrown away. It leaves `DEF SEG` at 0 | Kept: libqb emulates the buffer, and the `POKE`s throw a waiting key away (measured, "The measurements" below) |
| `PEEK(1052) > 30` | `order`, `CIVWAR25.BAS` line 1448 | During automatic play, true when a key was waiting: the tail of the buffer had moved. Then automatic play stopped. It reads segment 0 because `BuffClear` ran first and left `DEF SEG` at 0 | Kept: a waiting key moves the tail from 30 to 32 (measured, "The measurements" below) |
| `SHELL "copy generalz temp.$$$"`, `SHELL "copy maxskors temp.$$$"` | `CIVWAR2B.BAS` lines 563 and 1483 | Copied the generals' records and the high scores to a temporary file, which the code then reads and deletes | Kept: `copy` works on Windows. A `TODO.md` row for Linux |
| `SHELL "yell.exe"` | `CIVWAR2B.BAS` lines 1733 and 2047 | Played the rebel yell. The program has no source | Decision D4: the yell recorded in DOSBox to a WAV, played with QB64's sound |
| `SHELL "plany " + mask$ + ".wav"` | `sndblst`, `CIVWAR2B.BAS` line 2214, called from 26 lines | Played a sound file with the DOS player `PLANY.EXE` | QB64's own sound plays the WAV. `CW s` still turns sound on |
| `RUN "cs.exe"` | `CIVWAR25.BAS` line 372, the game's Editor entry | Ended the game and started the editor | Kept: `RUN` of an `.exe` starts it in both compilers (measured, "The measurements" below). The editor is built as `cs.exe` |
| `RUN "CW.EXE"` | `CIVSET24.BAS` line 381, the editor's Run Game entry | Ended the editor and started the game | Kept, as the row above. The game is built as `cw.exe` |
| `SHELL "rename savegame.pbm savegame.old"`, `SHELL "rename savegame.fix savegame.pbm"` | `PBMFIX.BAS` lines 20 and 21 | Kept the old play-by-mail file and put the fixed one in its place | Kept: `rename` works on Windows. A `TODO.md` row for Linux |

There is no other `PEEK`, `POKE`, `VARPTR`, `CALL ABSOLUTE` or `CALL INTERRUPT`.

## The measurements (2026-11-06)

Each question left open by the searches was answered with a small program. Each was built with QB64Rust 0.3.0
and with QB64pe 4.7.0, and run alone on Windows. The keys were given by QB64Rust's screen-state check
(`tools\screen\README.md`), and the screens it wrote were compared. **Both compilers gave the same result every
time, and none of these forms needs a change.**

| Question | The program | Result in both compilers | What the port does |
|---|---|---|---|
| Does `CIV20.BI`'s unnamed `COMMON SHARED` work in one program? | Its 10 `COMMON SHARED` lines and 5 `DIM SHARED` lines, copied as they are, and a SUB that sets a number, a single, a double, a long, a string array element, an array of 81 elements and one of two dimensions | The main module reads every value back. The bounds are those of the `DIM SHARED` lines (`mtx$` 0 to 20, `unitx` 0 to 80) | `CIV20.BI` stays as it is |
| Does `_FILEEXISTS("*.civ")` find a file? The earlier branch `canonical+1` replaced `LEN(DIR$("*.civ"))` by it | `_FILEEXISTS` with a pattern and with a name, in a folder holding `BULLRUN1.CIV` | `_FILEEXISTS("*.civ")` gives 0, and `_FILEEXISTS("bullrun1.civ")` gives -1. `_FILES$("*.civ")` gives `BULLRUN1.CIV` | `DIR$` is written with `_FILES$`, as in World War 2 |
| Does `BLOAD` into `&HB800` show a text screen? | `SCREEN 0`, `DEF SEG = &HB800`, `BLOAD "victory.scr", 0`, then each of the 2,000 cells compared with the file through `SCREEN(r, c)`, `SCREEN(r, c, 1)` and `PEEK`; the same for `newhi.scr` | All 2,000 cells match each time, character and color: 1,309 cells that are not blank in `VICTORY.SCR`, 1,488 in `NEWHI.SCR` | `scrnload` and the victory screen stay as they are |
| Do the `POKE`s of `BuffClear` and the `PEEK(1052)` of automatic play work? | `DEF SEG = 0`. A key is typed and left waiting for 3 seconds while `PEEK(1052)` is watched. Then `POKE 1050, 30: POKE 1052, 30` and `INKEY$`. Then a second key, read with no `POKE` | Both bytes are 30 at the start. `PEEK(1052)` is 32 while the key waits. After the two `POKE`s, `INKEY$` gives nothing: the key is thrown away. Without them, `INKEY$` gives the key | `BuffClear` and the test in `order` stay as they are. Their emulation of the BIOS buffer is libqb's |
| Do the icons load and draw? | `iconload`'s code for `STDICON.EGA` and `TERRAIN.EGA`: `BLOAD` into `Image(1 TO 1564)`, `PUT`, `GET` of five icons, which are then put in a row | The two screens are the same byte for byte. The icons show as they should: Union infantry and cavalry in blue, Rebel infantry in red, and two kinds of terrain. `Image(1)` and `Image(2)` are 41 and 65; a cut icon starts with 16 and 14, its width and height | `iconload` stays as it is |
| Does `RUN "cs.exe"` start another program? | A program that runs `RUN "m4child.exe"`, and once more with `RUN "M4CHILD.EXE"`. The child writes a line to a log | The child starts both times. The line after `RUN` never runs, because the first program has ended. The child's `COMMAND$` is empty | The two `RUN`s stay as they are. The builds must be named `cw.exe` and `cs.exe` |

Two of these results were new to QB64Rust, so they are now programs of its test corpus, recorded with QB64pe:
`tests\corpus\screen\d20_bload_text_memory` (a text screen loaded into `&HB800`) and
`tests\corpus\screen\k05_bios_keyboard_buffer` (the BIOS keyboard buffer). `RUN` of an `.exe` will be covered by
this game's own scripts, which go from the game to the editor and back.

One more thing the first program showed, in both compilers: `timex = 40000`, an INTEGER of `COMMON`, gives
-25536 and no error. QB 4.5 raises error 6, "Overflow", in such cases (QB64Rust's `DIVERGENCES-QB45.md` Q-004,
measured; PDS 7.1 is not measured). QB64 does this for every INTEGER, so it is not particular to `COMMON`. No
place in the game is known to depend on it.

## The first builds (2026-11-06)

QB64Rust 0.3.0 and QB64pe 4.7.0 both build `cw.exe`, `cs.exe` and `pbmfix.exe` with no error. Each build was played
with the same timed keys, in turn, from the same folder, on a desktop of its own, and its screens were taken with
QB64Rust's screen-state check. There are no test hooks yet (step 6 of the plan), so the keys are given by time.

- **The game.** The "Please Note" box over the loading of the icons, the main menu, Load File's list of the
  `.civ` files, Esc back to the main menu, Quit, and QB64's "Press any key to continue" at the end. The two builds
  show the same screens, except one number: the list of files ends with the free space of the disk ("122536693760
  Bytes free"), which changed between the runs. A script must leave that line out of its digests.
- **The editor.** Its title screen, and after Enter its Options menu. The same in both builds.
- **`pbmfix.exe`.** Its messages, the same in both builds. See "Found" below for what it did to the file.

### Found

- **"RETURN without GOSUB" in the game, as section 2 expected.** Load File, a saved game (`$ave1.civ` and the
  others) chosen in the file list, then Esc at the "SAVEGAME FILE TO LOAD" menu: `crsr` leaves `menu` by
  `GOTO called`, and `whichsave`'s `RETURN` (`CIVWAR25.BAS` line 271) takes `crsr`'s entry. QB64Rust's build,
  made with `$CONSOLE` in a copy so that the message could be read, stops with "Runtime error: Line: 272 (in
  main module) RETURN without GOSUB": 272 because of the added first line. Both builds stop at the same screen
  (QB64Rust with exit code 1 and QB64pe with 0, as QB64Rust's `QB64PE-DIVERGENCES.md` D-012 records). Without
  `QB64PE_NOPROMPT`, both builds stopped drawing at that screen and waited until the run's timeout of 90 seconds.
  That is expected of libqb's error dialog, which a desktop that is never shown does not let anyone see or close.
  The fix is step 5 of the plan.
- **`pbmfix.exe` empties the play-by-mail file in this repo.** It writes a line only when it reads a carriage
  return, `CHR$(13)`. The repo's `SAVEGAME.PBM` has LF line ends only: git stored it that way in the first commit
  (`.gitattributes` has `* text=auto`), so the CR LF ends that DOS wrote were lost before the port. Run on it,
  `pbmfix` renames it to `savegame.old` and writes an empty `SAVEGAME.PBM`, in both builds. A file that the
  QB64 build of the game writes has CR LF ends on Windows, where `PRINT #` writes them, so `pbmfix` should work
  on it. That is to be checked when a script plays a PBM game (step 7). The other data files are stored with LF
  too, and the game reads them with `INPUT #` and `LINE INPUT #`, which take either.
- **QB64Rust's warnings** (`-w`) name 10 places in the main files: 2 in `CIVWAR25.BAS`, 8 in `CIVSET24.BAS`. The
  included `.BM` files get none, by design. None is a bug of the game. `closest = 32767` (`CIVWAR25.BAS` line
  217) sets a main-module variable that no SUB sees, because the SUBs that use `closest` have their own.
  `wtype` (`CIVSET24.BAS` line 66) is set and never read. `a$` (line 1925) is an output argument of
  `CALL terra(z, a$)` that the caller does not use. The others are labels no jump names, a SUB never called
  (`BuffClear`, in the editor) and an unused parameter.
