# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is
`docs\port-study.md`; its steps 1 to 10 are done.

## The tests

- **`RUN "cs.exe"` and `RUN "CW.EXE"`.** No script goes from the game to the editor or back: the program that
  `RUN` starts would read the same keys file from its start. It needs a keys file per program, or a script that
  checks only that the other program starts.
- **The real `SHELL`.** Under a script, `scriptshell` (`SCRIPT.BM`) copies and renames in BASIC, because a
  `SHELL` opens a console window on the user's desktop. So no test runs the game's `SHELL "copy ..."` or
  `pbmfix`'s `SHELL "rename ..."`. A test of them must run where a window does no harm: in QB64Rust's suites VM,
  or by hand.
- **Sound.** No script runs with sound on (`quiet` 1) or with the `s` option, so `sndblst`, `playsound`, the yell
  and the `PLAY` tunes are not run by any test. A script with sound on would also check that `playsound` reads
  the key that ends a sound.
- **The boss screen** ends only with Ctrl+B, which a keys file cannot give.
- **Linux.** The game copies and renames files with `SHELL "copy ..."` and `SHELL "rename ..."`, which are Windows
  commands, and opens lower-case names of upper-case files (`'civ20.bi'`, `"generalz"`). Then `play.py` would need
  its Linux branches checked, as for World War 2.
- **The QB64pe build of `campaign` crashed once at its end** (2026-11-06), with an access violation (exit code
  0xC0000005). Its screens before the end matched. It ran during `play.py compare` of nine scripts, while QB64pe
  was building the other programs. Run alone three times, it passed each time. The run's log was overwritten, so
  the cause is not known. If it comes back, keep the run's folder (`tests\out\run\campaign-pe`) and read its log.

## The game

- **A list of more than 84 files still loses its first rows.** `menufile` now finds the first file when `FILES`
  scrolled by one line (`docs\devnotes.md`, item 16), but a folder of 85 or more `.civ` files needs more rows
  than the screen has. The game has 82 with the saved games. A player who adds scenarios with the editor could
  pass 84; the list would then need pages.
- **Enter on an empty cell of the file list.** Right moves past the last file of a short last row, and Enter
  there computes `LEFT$(t$, -1)` in the game's `menufile` (`CIVWAR2A.BM`; the editor's checks for the dot
  first). DOS stopped
  with "Illegal function call"; QB64 gives `""`, and the game reports ".civ file not found" and goes on
  (`docs\devnotes.md`, item 16). Decide whether to keep the highlight on files.
- **The editor stops with error 62 on an unused saved game.** Load Scenario of a `$AVE` file that holds only
  "UNUSED" reads past its end. The game checks for "UNUSED"; the editor does not. Decide whether to change it.
- **The PBM game's second session starts with 96 turns left**, after a first session that began at 98 and wrote
  the file once more than 8 turns had passed (`pbm-bullrun1`). Check how many turns the first session played,
  and whether that is what the game means to do.
- **`normal` draws high.** It sums 12 RNDs and subtracts 5.5, though the sum averages 6, so every draw centers on
  `xbar + SQR(vary) / 2` (`TestNormalDrawsHigh` in `tests\rules_test.bas`), as in World War 2. Decide whether it is
  a bug. A fix changes the battles, so every script would need `record` again.
- **A long folder stops the main menu.** The main menu's Directory entry is `Directory ` and the current folder,
  which is `scenarios\` at the start (`docs\devnotes.md`, item 13). `menu` (`CIVWAR2C.BM`) centers a box that is
  too wide with `tlx = INT(39 - .5 * wide)`. With an entry of about 80 characters, the box's text starts at column
  0 or less, and `LOCATE` stops the game with "Illegal function call". Shorter entries wrap past the right edge
  first. That is a start folder whose path has about 60 characters, such as
  `C:\Users\<name>\Documents\Games\civil-war-battleset`. Before item 13, the limit was about 70 characters. The
  scripts cannot reach it, since they show the folder as `C:\CWB`. A fix changes how the game draws its menus.
- **`codex` does not give back `CHR$(255)`**: it codes to the shift and decodes to `CHR$(0)`
  (`TestCodexCharacter255DoesNotComeBack`). The PBM lines hold no such character, so nothing is known to depend on
  it.
