# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is QB64Rust's
`study\44-civil-war-battleset-port.md`; steps 8 to 10 of it are not repeated here.

## The tests

- **`pbmfix` on a real PBM file.** The script `pbmfix` runs on the repo's `SAVEGAME.PBM`, which git stores with
  LF line ends, so the fixed file is empty. Once step 8 makes `tests\data\`, add a PBM file with CR LF line ends
  and doubled line ends there, marked `-text` in `.gitattributes`, and a script that fixes it (study 44, D15).
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

## The game

- **`SCREEN(row, 0)` in `cupdate` stops the game.** The direct move of `cupdate` (`CIVWAR2B.BM`) reads
  `SCREEN(ynew + 1, xnew)` with `xnew = unitx(index) + 2 * dxs`, which is 0 for a unit in column 2 moving left: an
  illegal function call. `rest-bold-confederate` reaches it, and probably both `rest-antietm2` scripts, so those
  three are not written (`docs\devnotes.md`, "Step 7", "Found"). Decide whether to fix it (study 44, D16). A fix
  changes how battles go only where the game stopped before, so the other scripts would not change.
- **QB64's `FILES` scrolls the list of files by one line**, so `$AVE1.CIV` to `$AVE4.CIV` cannot be chosen in the
  list (`docs\devnotes.md`, "Step 7"). Measure whether DOS scrolled too (study 44, D14). If it did not, make the
  list fit, and run `make_scripts.py` again, as every generated script's keys move.
- **The editor stops with error 62 on an unused saved game.** Load Scenario of a `$AVE` file that holds only
  "UNUSED" reads past its end. The game checks for "UNUSED"; the editor does not. Decide whether to change it.
- **The PBM game's second session starts with 96 turns left**, after a first session that began at 98 and wrote
  the file once more than 8 turns had passed (`pbm-bullrun1`). Check how many turns the first session played,
  and whether that is what the game means to do.
- **`normal` draws high.** It sums 12 RNDs and subtracts 5.5, though the sum averages 6, so every draw centers on
  `xbar + SQR(vary) / 2` (`TestNormalDrawsHigh` in `tests\rules_test.bas`), as in World War 2. Decide whether it is
  a bug. A fix changes the battles, so every script would need `record` again.
- **`codex` does not give back `CHR$(255)`**: it codes to the shift and decodes to `CHR$(0)`
  (`TestCodexCharacter255DoesNotComeBack`). The PBM lines hold no such character, so nothing is known to depend on
  it.
