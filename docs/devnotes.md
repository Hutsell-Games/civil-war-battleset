# Developer notes: branch `qb64rust`

This branch starts from `main`, the original BASIC PDS 7.1 source. It will change as little as possible so that
the game builds with QB64Rust and with QB64pe, and so that its SUBs can be tested. The plan is
`docs\port-study.md` (QB64Rust's study 44 until 2026-11-06). It follows the port of World War 2 (`Hutsell-Games/world-war-2`, branch
`qb64rust`) and the principles in QB64Rust's `docs\PORTING-PDS.md`, section 0.

This file holds what was changed from `main` and why, and the results of the plan's steps: the searches made before
any edit (step 2), the measurements of what the searches left in doubt (step 3), the first builds (step 4), what
DOS did that QB64 does not (step 5), the test hooks (step 6), the tests (step 7), and what was done after the
files moved (step 8): the user's rulings of 2026-11-07, the build on GitHub Actions (step 9) and the documents
(step 10).

## Build

```
qb64rust -x CIVWAR25.BAS -o cw.exe
qb64rust -x CIVSET24.BAS -o cs.exe
qb64rust -x PBMFIX.BAS -o pbmfix.exe
```

Keep the names `cw.exe` and `cs.exe`: the game's Scenario Editor entry runs `cs.exe`, and the editor's game entry
runs `CW.EXE`. Build them in the repo's folder, beside `PREFER.CFG` and the four data folders (item 13), and run
them from there. `.gitignore` leaves the builds out.

## What was changed from `main`, and why

1. **One program for the game, instead of three linked modules.** QB64 builds one source file. `CIVWAR2B.BAS` and
   `CIVWAR2C.BAS` were renamed to `.BM` (with `git mv`) and are included at the end of `CIVWAR25.BAS`. Their headers
   were removed: `DEFINT A-Z`, their `DECLARE` lines and the include of `civ20.bi`. The main module already has
   `DEFINT A-Z` and the include, and QB64 does not need a `DECLARE` for a SUB the program defines.
2. **The 16 SUBs of `CIVWAR25.BAS` moved to `CIVWAR2A.BM`.** A test file can then include the `.BI` and `.BM`
   files and get every SUB without the main module's code. They moved unchanged: at the commit that moved them,
   `CIVWAR25.BAS`, `CIVWAR25.BI` and `CIVWAR2A.BM` put back together gave the original `CIVWAR25.BAS` byte for
   byte. Since then, `order` has the `GOSUB` fix of item 9.
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
   during playback to terminate output", `PLANY.DOC`), a key ends the sound, and `playsound` reads that key, so
   the game does not see it. `PLANY` did the same (measured in step 5, below). A missing file is silent. As in
   DOS, `cw s` turns the sounds on.
7. **`FRE(-1)` is commented out** (`menu`, `CIVWAR2C.BM`). QB64pe has no `FRE`. In DOS, Alt+= at a menu printed the
   free memory at the top left; now Alt+= does nothing, as any other key the menu does not use.
8. **The rebel yell is `YELL.WAV`, played by `playsound`.** `YELL.EXE` is `PLANY.EXE` with a WAV file added at its
   end, as `PLANY.DOC` describes for "self playing sound files": its first 32,262 bytes are `PLANY.EXE` byte for
   byte, and its last 25,560 bytes are a whole WAV file (8-bit mono, 11,025 Hz, 2.31 s), the same format as the
   game's other sounds. `YELL.WAV` is those bytes, taken out unchanged. The two `SHELL "yell.exe"` lines (`pursue`
   and `retreat`, `CIVWAR2B.BM`) are now `played = playsound("yell.wav")`, under the same conditions as before. They
   do not go through `sndblst`, which would add its own test of `quiet` and a `BuffClear`.
9. **Every `GOSUB` routine in a SUB ends by `RETURN`.** These are the four routines of "The searches", section 2.
   Each now sets `leave` and returns, and the line after the `GOSUB` makes the jump the routine made. This is
   World War 2's fix.
   - `crsr` in `menu` (`CIVWAR2C.BM`): Esc, and an entry chosen by its first letter, set `leave` to 1. The line
     after `GOSUB crsr` goes to `called`.
   - `otherside` in `order` (`CIVWAR2A.BM`): `leave` is 1 for the `EXIT SUB` (the other side has no moves left)
     and 2 for the `GOTO human` (play passes to the other player). The two lines that call it are now `IF`
     blocks that make those jumps. `otherside` sets `leave` to 0 first, because after `GOTO human` the loop
     comes back to it.
   - `eval` in `general` (`CIVWAR2B.BM`): the `GOTO improve` sets `leave` to 1. Each of the six `GOSUB eval`
     lines is followed by `IF leave GOTO improve`.
   - `wait8` in `placearmy` (`CIVSET24.BAS`): F10 with no unit in hand sets `leave` to 1, and the line after
     `GOSUB wait8` ends the SUB. The F10 line became two lines, one for each case, because QB64Rust did not
     accept `RETURN` just before `ELSE` in a one-line `IF` when the fix was written (step 5, below).

   The script of section 2 now finds no routine that can leave its SUB. Before the fix, it found these four.
10. **The title screen is a picture in `docs\`.** The DOS game showed it by running `CWBSTITL.EXE` from `CW.BAT`,
    before the game started; the game's code never runs it. Run in DOSBox on 2026-11-06, it drew
    [CWBSTITL.png](CWBSTITL.png) in less than 10 seconds and then waited for a key. The QB64 builds start without
    it.
11. **The editor's list of files trims the name it gives.** `FILES` shows a name shorter than 8 characters padded
    with blanks, as `$AVE5   .CIV`, and the editor's `menufile` (`CIVSET24.BAS`) read the name back from the
    screen and opened it as it was. DOS stores names padded to 8 characters, so it ignored the blanks before the
    dot. Windows does not: the editor stopped with "ERROR : 53 ... Not On This Drive" (step 7). The game's own
    `menufile` (`CIVWAR2A.BM`) already removed the blanks, and the editor's now does the same, in one added line.
    Names of 8 characters, such as `BULLRUN1.CIV`, worked before. That DOS ignored the blanks is not measured.
12. **The test hooks** (step 6): `SCRIPT.BM`, included at the end of `CIVWAR25.BAS` and `CIVSET24.BAS`, and calls
    to it in the sources. When the environment variable `CWB_SEED` is not set, the programs behave as before.
    Each changed line is listed in "Step 6", below.
13. **The data files are in folders** (step 8, decision D2 (a) of the plan). The DOS game kept its 155 files beside
    the program. Now the folder the program starts in holds the sources, `PREFER.CFG` and these folders:

    | Folder | What |
    |---|---|
    | `graphics\` | The 7 icon files (`.EGA`) and the 2 text screens (`VICTORY.SCR`, `NEWHI.SCR`) |
    | `sound\` | The 17 sounds (`.WAV`) |
    | `data\` | The campaign (`CAMPAIGN.INI`, `REGIONS.INI`) and the name lists (`MONTHS.DAT`, `PNAMES1.DAT`, `PNAMES2.DAT`, `RNAMES.DAT`, `YNAMES.DAT`, `UNION.LDR`, `REBEL.LDR`) |
    | `scenarios\` | The 77 scenarios (`.CIV`). The game writes the saved games and the PBM file here, and the editor its new scenarios |
    | `docs\` | The original documents: `CW.DOC`, `CS.DOC`, `SOUNDS.DOC`, `WRHGAMES.DOC`, `PLANY.DOC`, `README.TXT` |

    The Directory menu of both programs changes the current folder with `CHDIR`. The game reads and writes the
    `.civ` files, the PBM file and its `temp.&&&` there, by bare names. So these stay bare names, and the new
    `SUB setfolders` (`FOLDERS.BM`) makes `scenarios\` the current folder at the start. Every other file is opened
    by its full path, made from the folder the program started in: `homedir$`, `gfxdir$`, `snddir$` and `datdir$`
    in `CIV20.BI`. So the Directory menu changes where the scenarios and saved games are, and nothing else. In DOS
    it changed where every file was looked for, so after a change of folder the game no longer found its sounds,
    its settings or its history files.

    The settings (`PREFER.CFG`), the history files (`generalz`, `maxskors`) and the campaign under way
    (`regions.sav`) are written beside the program. The game makes the saved games and the history files when they
    are missing, so they are no longer in the repo's folder. The scripts' copies are in `tests\data\`, with the
    saved games and `SAVEGAME.PBM` in `tests\data\scenarios\`. `.gitignore` leaves out the copies that playing
    writes. `PREFER.CFG` stays in the repo, so playing with Save Settings changes a tracked file.

    The 20 DOS-only files are removed; they are still on `main`. They are the DOS builds (`CIVWAR25.EXE`,
    `CW25.EXE`, `CS.EXE`, `PBMFIX.EXE`), the programs with no source (`CWBSTITL.EXE`, `YELL.EXE`, `PLANY.EXE`,
    `SOUND.EXE`), the batch files and their settings (`CW.BAT`, `GO.BAT`, `INSTALL.BAT`, `PRINTDOC.BAT`, `CW.PIF`,
    `CWSND.CFG`), the DOS build's files (`CIVWAR24.MAK`, `CIVWAR25.MAK`, `CIVWAR25.LNK`, `CIVWAR2C.OBJ`,
    `CW25MAKE.BTM`) and `SOUNDS.ZIP`, which holds the 16 WAV files of `sound\` other than `YELL.WAV`. No line of the port opens or
    runs any of them. `PLANY.DOC` stays in `docs\`, because items 6 and 8 cite it.

    The other lines that changed:
    - The two `RUN` lines run `CHDIR homedir$` first: the other program is beside this one, not in `scenarios\`.
    - `pbmfix` makes `scenarios\` the current folder before it opens `savegame.pbm`, which is where the game wrote
      it. As in DOS, a PBM file that the Directory menu put elsewhere needs `pbmfix` run there.
    - `scriptshell` (`SCRIPT.BM`) takes the command and its two names apart. The real `SHELL` puts each name in
      quotes, because a full path may hold blanks: `copy "<home>generalz" "<home>temp.$$$"`. The DOS game ran
      `copy generalz temp.$$$`.
    - `playsound` (`QB64.BM`) takes a bare name, such as `ding.wav`, and plays it from `sound\`.

    Under a script, `CURDIR$` still shows `C:\CWB`: `scriptstart` runs after `setfolders`, so it takes
    `scenarios\` as the folder to show that way. `play.py check` gave the recorded screens for every script. The
    only change to them is the name of five checked files, which now start with `scenarios/`.
14. **The computer's direct move no longer reads column 0 of the screen** (`cupdate`, `CIVWAR2B.BM`; decision
    D16 (b) of the plan, user, 2026-11-07). The direct move looks at the square it moves to with
    `SCREEN(ynew + 1, xnew)`. For a unit in column 2 moving left two columns, `xnew` was 0, and `SCREEN` with
    column 0 stops the game with "Illegal function call". DOS would stop there too, so this is a fix of the game's
    own bug, not of a port difference. Each of the two lines that read the square (one for a move with a change of
    row, one without) is now two lines: the first sets `xnew` and adds 2 to it when it is below 1. The game does the
    same a few lines further on for another move, there when `xnew` is below 2. The second line reads the square. So `xnew` changes only where
    the game used to stop. `play.py check` of every other script gave its recorded screens. The script
    `rest-bold-confederate` reached the crash, and it is now written.
15. **`ANTIETM2.CIV` starts with its objective held by no side** (user, 2026-11-07). The second line of the file was
    `250,20,120,0,0,0`, and its second number is `possess`, the side that holds the objective at the start: 0 for
    none, 1 for the Rebels, 2 for the Union. The editor writes only those three. With 20, `order` added to
    `vp&(20)` of `vp&(2)`, and QB64 stopped with "Subscript out of range" on the first turn ("After step 8",
    below). The line is now `250,0,120,0,0,0`. That is how the DOS game played it: 20 is neither 1 nor 2, so no
    side was shown or scored as holding the objective until a unit moved onto it. The Confederates still start
    with the file's 120 objective points. The history and the file's own 120 suggest the author meant 1 (the
    Confederates held Sharpsburg), but the user chose to keep what DOS players saw. The scripts
    `rest-antietm2-confederate` and `rest-antietm2-union` are now written. No other script loads this scenario.
16. **The list of files fits on the screen** (`menufile`, in `CIVWAR2A.BM` and in `CIVSET24.BAS`; decision D14
    of the plan, user, 2026-11-07). With more than 80 `.civ` files, `FILES` scrolled the screen up by one line,
    in DOS too ("After step 8", below). The title row was lost and the files started on row 2, while `menufile`
    took row 3 as the first. So the first file it highlighted was the fifth, and `$AVE1.CIV` to `$AVE4.CIV`
    could not be chosen. Now `menufile` counts the files with `_FILES$`, works out the row of the first file from
    the row of the last (`maxy`, which it already had), and starts there. It counts with `_FILES$`, not the
    port's `DIR$`, because `FILES` lists a folder whose name matches `*.civ` and `DIR$` skips it. libqb's
    `FILES` prints every name as an 8.3 short name in 18 columns, four to a row, so the count gives the rows. When the list scrolled, it draws the
    title row again over the folder's line. The list then shows every file of a folder of up to 84, and
    highlights `$AVE1.CIV` first. With more than 84, the first rows still scroll away, as before.

    Every script that uses a list needed one more Down to reach the same file. The battles and the screens did
    not change. No script takes a digest at the list, and `play.py check` gave the recorded screens for every
    script. `make_scripts.py`'s `pick_keys` now counts from the first file. `play.py compare` of
    `edit-bullrun1`, `rest-bullrun1-union` and `saves-gosub` gave the same screens in both builds.

    **Found while checking it: Enter on an empty cell of the list.** The last row of the list may hold fewer than
    four files, but Right still moves to its empty cells. Enter there reads blanks, so the game's `ff7` computes
    `LEFT$(t$, -1)`. QB64 gives `""` for that, and the game goes on to open `.civ`: "ERROR: 53 - .civ file not
    found", then a key goes back to the menu. QB 4.5 and PDS 7.1 raise error 5, "Illegal function call", for a
    negative length (measured with QB64Rust's `verification\qb45\q45_left_negative`). `menufile` turns error
    trapping off right after `FILES`, so in DOS the game stopped there. The editor's `ff7` looks for the dot first (item 11), so it does not reach
    this. Not changed; a `TODO.md` row.

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

These were expected from the code and from World War 2's measurements. The first builds showed the second one
(step 4, "Found" below). The fix is item 9 of the changes above.

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
| `SHELL "yell.exe"` | `CIVWAR2B.BAS` lines 1733 and 2047 | Played the rebel yell. The program has no source | `YELL.WAV`, taken out of `YELL.EXE`, played with QB64's sound (item 8 above) |
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
  Fixed in step 5 (item 9 of the changes).
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

## Step 5: what DOS did that QB64 does not (2026-11-06)

The changes are items 8 to 10 above, and the key that ends a sound in item 6.

### Does `PLANY` take the key that ends a sound?

Yes. A PDS 7.1 program, built with `BC /O /E /X /D` and run in DOSBox 0.74-3, put the key `x` in the BIOS keyboard
buffer with `POKE` (as `BuffClear` does), ran `SHELL`, and then read the buffer's head and tail and `INKEY$`.
`YELL.EXE` and `PLANY` behave the same, since `YELL.EXE` is `PLANY` (item 8).

| `SHELL` of | Key waiting | Time | Head, tail after | `INKEY$` after |
|---|---|---|---|---|
| a 15-byte program that waits 3 s and reads no key (the control) | yes | 2.96 s | 30, 32 | `x` |
| `yell.exe` | no | 2.30 s | 30, 30 | empty |
| `yell.exe` | yes | 0.06 s | 32, 32 | empty |
| `plany yell.wav` | yes | 0 s | 32, 32 | empty |

The control shows that a key survives `SHELL`. `PLANY` stops at once when a key waits, and reads exactly that key
from the buffer. So `playsound` reads the key too: it watches `INKEY$`, not `_KEYHIT` as at first. Like `PLANY`,
it then ends only for a key that puts something in the buffer, not for Shift, Ctrl or Alt alone.

A key pressed at DOSBox's prompt cannot answer this question. DOSBox's shell empties the keyboard buffer before
its prompt: a key pressed while the 3-second program ran did not show at the prompt either.

### How the yell was checked

Played in DOSBox, `YELL.EXE` gave 2.3208 s of sound. DOSBox's own recorder (Ctrl+F6) and a recording through SDL's
disk audio driver gave the same 102,350 samples at 44,100 Hz. The Sound Blaster cannot play at 11,025 Hz exactly:
the nearest rate its time constant gives is 10,989 Hz, and 25,502 samples at that rate last 2.3207 s. This agrees
with `YELL.WAV`, so the file taken out of `YELL.EXE` is the whole yell.

The yell has not been heard in the QB64 builds yet: a battle with sound on is needed, and a script of step 7
can reach one.

### Checks of the `GOSUB` fixes

- The script of "The searches", section 2, run again on the changed sources: every routine of every SUB ends by
  `RETURN`. Run on the commit before step 5, it names the four routines of item 9.
- Step 4's failure played again with the screen-state check (Load File, `$ave1.civ` chosen in the list, Esc at
  "SAVEGAME FILE TO LOAD"). Both builds now go back to the main menu instead of stopping with "RETURN without
  GOSUB". Their screens are the same, except the width of the menu box: the Directory entry shows the folder
  each build ran in, and the two folders' names differ in length.
- Both compilers build `cw.exe` and `cs.exe`. QB64Rust's warnings (`-w`) are the same 10 as in step 4.

### Found in QB64Rust

- **`RETURN` just before `ELSE` in a one-line `IF` is rejected.** `IF a = 0 THEN RETURN ELSE CALL s` gives
  "not supported yet: word `CALL` (expected the end of the statement)". QB64pe 4.7.0 builds it. The first
  form of the `wait8` fix had it; item 9 uses two lines instead. QB64Rust fixed it the same day
  (`verification\v17_d_return_before_else`); the two lines stay, as they work in both compilers.

## Step 6: the test hooks (2026-11-06)

`SCRIPT.BM` holds the hooks, as World War 2's does. `tests\README.md` ("How the game takes part") says what each
does for a script and lists the places of the waits. The hooks act only when `CWB_SEED` is set. Two shared
variables, `scripted` and `scriptdir$`, are added at the end of `CIV20.BI`, which both programs include.

The lines changed for them:

| Where | Before | Now |
|---|---|---|
| `CIVWAR25.BAS`, start | `RANDOMIZE TIMER` | `CALL scriptstart` |
| `CIVSET24.BAS`, start | `RANDOMIZE TIMER` | `CALL scriptstart` |
| `TICK`, `CIVWAR2B.BM` and `CIVSET24.BAS` | | first line `IF scripttick(sec!) THEN EXIT SUB` |
| `CIVWAR25.BAS`, Save File | `DATE$ + " " + LEFT$(TIME$, LEN(TIME$) - 3)` | `scriptdate$` |
| `CIVWAR25.BAS`, the start of a battle, and `minsec`, `CIVWAR2B.BM` | `TIMER` | `scripttime!` |
| `randarm`, `CIVSET24.BAS` (two lines) | `TIMER` | `scripttime!` |
| `CURDIR$`, `QB64.BM` | `CURDIR$ = c$` | `CURDIR$ = scriptfolder$(c$)` |
| `commander` and `ishi`, `CIVWAR2B.BM`; `PBMFIX.BAS` (two lines) | `SHELL "copy ..."`, `SHELL "rename ..."` | `CALL scriptshell("copy ...")`, `CALL scriptshell("rename ...")`; `PBMFIX.BAS` now includes `SCRIPT.BM` |
| 29 waits for a key: 14 in the game, 15 in the editor | | `CALL announce(place, letter$)` before the wait |

Where a wait was a loop of the form `label: k$ = INKEY$: IF k$ = "" GOTO label`, the line became
`CALL announce(...): DO: k$ = INKEY$: LOOP WHILE k$ = ""`, which reads keys the same way. The label stays where
other lines jump to it, so the wait is announced again after a key that the game ignores. The announced waits:

- the game: the menu (`crsr` in `menu`, `CIVWAR2C.BM`), the list of files (`menufile`), `Enput`, the three
  `INPUT`s of the scoring factors, a unit's command (`wait3` in `order`), the map cursor (`wait5`), the boss screen,
  the line of sight bar, and the four "press a key" loops (Fight without a scenario, the end after a file error,
  the side switch of two players, the pages of the order of battle);
- the editor: its list of files, `Enput`, the Map Edit cursor (`wait4`), the Army Edit cursor (`wait8`), the
  attribute keys (`pluskey`), the three one-key answers (the alternate objective's terrain, "off screen during
  delay [Y/n]", a new unit type), the three `INPUT`s (a unit's name twice, a delay), and the four "press a key"
  loops (the map help, "NO MORE SLOTS", "NO UNIT AT THAT LOCATION", the end of placing random armies).

Choices made here, which the user has not ruled on yet (`docs\port-study.md`, section 5):

- **`TICK` of 99 seconds or more waits for a key** under a script, instead of returning at once as World War 2's
  timed pauses do. The game uses `TICK 99` and `TICK 999` for "hit a key" (the results, the help, the Hall of
  Fame, a victory). Returning at once would leave those screens unseen by any script.
- **`CURDIR$` shows the folder the program started in as `C:\CWB`** under a script. Both main menus show the
  folder in their Directory entry, so its full path would be in every digest of the main menu, different in each
  folder a script runs in and on each machine. The real folder is used for everything else.
- **`announce` leaves `DEF SEG` at 0**, as `BuffClear` does. During a computer-against-computer game, `order`
  reads `PEEK(1052)` after `BuffClear` without setting `DEF SEG` again. World War 2's `announce` ends with a plain
  `DEF SEG`, which here could make that `PEEK` read another segment.
- **`Enput` announces once**, when it starts, so that a script gives a whole line after one `play until 4`.
- **Under a script, the four `SHELL` lines copy and rename in BASIC** (`scriptshell`). Each `SHELL` starts a
  `cmd.exe`, whose console window showed on the user's desktop although the program ran on a hidden one. The
  first runs of `make_scripts.py` and `play.py record` flashed such a window at nearly every battle's end, for
  about two and a half hours, before this was found. With the hook, a check of one battle and of `pbmfix` started
  no `cmd.exe`. The scripts no longer run the real `SHELL`; a `TODO.md` row.

## Step 7: the tests (2026-11-06)

`tests\play.py`, `tests\make_scripts.py` and `tests\test_play.py` are World War 2's, changed for this game: the
three programs `cw`, `cs` and `pbmfix`, `PREFER.CFG` instead of `WW2.CFG`, `CWB_SEED`, and data files beside the
program instead of in folders. `tests\README.md` is their manual. `tests\rules_test.bas` has 26 unit tests of 19
SUBs and FUNCTIONs that draw nothing.

The scripts: two generated styles, `rest-<scenario>-<side>` for each of the 77 scenarios and both sides, but
three whose battle stops with a runtime error ("Found", below), and `auto-<scenario>` (Computer vs. Computer)
for eight scenarios, 159 in all; and ten written by hand (`tests\README.md`, "The
scripts"). QB64pe 4.7.0 and QB64Rust gave the same screens in every recording. The coverage is in
`tests\README.md`, "What the scripts do not cover".

### Found

- **The computer's move can stop the game with a runtime error.** In three generated scripts the battle never
  ended: `rest-bold-confederate` (`BOLD.CIV`, "Beauregard's Plan", 15 turns left, "Couch's TURN"),
  `rest-antietm2-confederate` and `rest-antietm2-union`. For `BOLD.CIV` both compilers stopped at the same screen,
  and a coverage build shows where: the last statement started and never finished is `z = SCREEN(ynew + 1, xnew)`
  in `cupdate` (`CIVWAR2B.BM`, the line after `IF dy = 0 THEN xnew = unitx(index) + 2 * dxs`). A unit in column 2
  that moves left gives `xnew` 0, and `SCREEN` with column 0 is an illegal function call, which DOS would stop on
  too. The `ANTIETM2.CIV` scripts were not looked into; they stopped the same way. Until then each run waited for
  the "Continue?" dialog on a desktop nobody sees; `play.py` now sets `QB64PE_NOPROMPT`, so such a run ends at
  once with exit code 1. The three scripts are not written. A `TODO.md` row, and D16 of `docs\port-study.md`.
- **QB64's `FILES` scrolls the list of files up by one line**, in both compilers. The list has 82 files in 21 rows.
  With the folder's line before them and the free space after them, the last line printed goes past the bottom
  row. The list's title row is lost, and the files start on the second row, where `menufile` expects them on the
  third. So the first file highlighted is the fifth, `$AVE5.CIV`, and `$AVE1.CIV` to `$AVE4.CIV` cannot be chosen
  in the list. Saved games are still loaded by choosing `$AVE5.CIV` and then the slot in the menu that follows.
  Whether DOS also scrolled is not measured; a `TODO.md` row.
- **The editor could not load a file whose name is shorter than 8 characters** (item 11, fixed).
- **The editor stops with error 62 on an unused saved game.** Load Scenario of `$AVE5.CIV`, which holds only
  "UNUSED", reads past the end of the file. The game checks for "UNUSED"; the editor does not. This is the game's
  own behavior and is not changed; a `TODO.md` row.
- **A `SHELL` hung once.** While `play.py record` ran three scripts at once, one of the four runs of `pbmfix`,
  built by QB64pe, did not end within 300 seconds. `pbmfix` ends with two `SHELL "rename ..."` lines. Recorded
  alone, all four runs passed. QB64Rust's Civil War Strategy scripts see the same under load in
  `SHELL "copy ..."` (QB64Rust's `STATUS.md`, known bugs), so it is not particular to either compiler.
- **The PBM game's second session starts with 96 turns left** (`pbm-bullrun1`). The first session's first command
  showed 98, and the game writes the file when more than 8 turns have passed. How many turns the first session
  played is not checked; a `TODO.md` row.

## After step 8 (2026-11-07)

On 2026-11-07 the user took the recommendations of D10 to D16 in `docs\port-study.md`. D10 to D13 were already
built. This section holds what D14 to D16 found, and steps 9 and 10.

### D14: DOS scrolls the list of files too

The question was whether DOS also scrolled the Load File list by one line (step 7, "Found"). A small program drew
the same screen as `menufile` (`CIVWAR2A.BM`): the title on row 1, the bottom line on row 25, then `LOCATE 2, 1`
and `FILES "*.civ"`, in a folder holding the 82 files of the scripts' `scenarios\`. It then wrote all 25 rows to a
file. It was built with PDS 7.1 and with QB 4.5 (`BC /O /E /X /D`) and run in DOSBox 0.74-3, through QB64Rust's
`tools\qb45\qb45.py`.

Both scroll in the same way as QB64. The folder (`D:\T`) is on row 1, where the title was. The 82 names fill
rows 2 to 22, four to a row. "Bytes free" is on row 23, row 24 is empty, and `CSRLIN` is 24. The title row is
gone. So in DOS too, `menufile` highlights `$AVE5.CIV` first, and `$AVE1.CIV` to `$AVE4.CIV` cannot be chosen.

The list scrolls whenever it has more than 80 files (20 rows). `main` has 77 scenarios and 5 saved games, 82 in
all, so the game as shipped had this bug. It is the game's own bug, not a QB64 difference. The user asked for the
list to fit; that is item 16.

### D15: `pbmfix` on a file as mail leaves it

`tests\data\scenarios\SAVEGAME.PBM` now has CR LF line ends, each one doubled (`CR LF CR LF`), as a mail program
could leave a PBM file. It is the repo's 133-line file with its line ends changed, 5,703 bytes.
`.gitattributes` marks it `-text`, so git keeps those bytes. The script `pbmfix` fixes it. The fixed
`SAVEGAME.PBM` has one CR LF per line, and its hash is that of the 133 lines as they were. `SAVEGAME.OLD` is the
file as given, and `SAVEGAME.FIX` is gone. Both builds gave the same result in all four runs of `record`.

The script `pbm-bullrun1` does not read this file: it begins a new PBM game, which writes `SAVEGAME.PBM` afresh.

### D16: one more crash, in `ANTIETM2.CIV`'s data

With item 14 built, `make_scripts.py` wrote `rest-bold-confederate`. Both `ANTIETM2.CIV` scripts still stopped,
but for another reason, which item 15 fixed. The game ends with exit code 1 at "Initializing", before the first unit's command. A
coverage build shows that `order` (`CIVWAR2A.BM`) ran 7 statements and stopped at line 726:
`IF possess > 0 THEN vp&(possess) = vp&(possess) + factor(2) * (timex - told)`.

The second line of `ANTIETM2.CIV` is `250,20,120,0,0,0`, read as `timelimit, possess, vp&(1), vp&(2), score&(1),
score&(2)`. So `possess` is 20, and `vp&` is `DIM SHARED vp&(2)` (`CIV20.BI`). QB64 checks every array index, and
stops with "Subscript out of range". The DOS game did not check: `CW25MAKE.BTM` (on `main`) built it with
`bc/o/e`, without `/D`. So in DOS the line wrote past the end of `vp&` into some other variable, and the battle
went on. What it overwrote is not known. The file is the same on `main`. Every other scenario has 0, 1 or 2 there.

This is a fault in the scenario's data. The editor's "Objective Control" menu gives only 0, 1 or 2, so the value
was probably typed by hand: the scenario is "courtesy of Grant Richards". The objective is at column 26, row 11,
inside the Confederate line between D.H. Hill's and D.R. Jones's divisions, where Sharpsburg was. The fix is
item 15: the user chose 0, as the DOS game behaved.

### Step 9: the build on GitHub Actions

`.github\workflows\build.yml` is World War 2's, changed for this game. It builds `cw.exe`, `cs.exe` and
`pbmfix.exe` with QB64Rust and uploads the artifact `civil-war-battleset`. The artifact holds the three programs,
`PREFER.CFG`, `LICENSE`, `README.md`, the four data folders and the game's original documents. It runs on a push
to `main` or `qb64rust`, and by hand. World War 2's runs only for `main`. This game's port stays on `qb64rust`
for now, so a run there checks the build. Its packaging step was run locally on 2026-11-07. The workflow itself
first runs when the branch is pushed.
