# W.R. Hutsell's Civil War Battleset
A tactical level, one or two player wargame simulating the American Civil War (1861-1865).

## The Canonical Source
The branch `main` contains the original source code as provided by W.R. Hutsell to Dave Mackey. That branch
should not be edited; it is there for historical purposes.

## This branch: the QB64 port
W.R. Hutsell wrote the game in Microsoft BASIC PDS 7.1 for DOS. This branch, `qb64rust`, changes that source as
little as possible so that the game builds with QB64Rust and QB64pe, and so that its SUBs can be tested. It
builds three programs:

```
qb64rust -x CIVWAR25.BAS -o cw.exe       the game
qb64rust -x CIVSET24.BAS -o cs.exe       the scenario editor
qb64rust -x PBMFIX.BAS -o pbmfix.exe     repairs a play-by-mail file that mail has changed
```

`CIVWAR25.BAS` includes the other source files of the game (`CIV20.BI`, `CIVWAR25.BI`, `CIVWAR2A.BM`,
`CIVWAR2B.BM`, `CIVWAR2C.BM`, `QB64.BM`, `FOLDERS.BM`, `SCRIPT.BM`). Keep the names `cw.exe` and `cs.exe`: the
game's Scenario Editor entry runs `cs.exe`, and the editor's game entry runs `CW.EXE`.

The builds are not committed (`.gitignore`). The original DOS programs, the sound player, the batch files and
the PDS build files are not on this branch; they are on `main`. Each push to `main` or `qb64rust` also builds
the three programs on GitHub Actions (it can be started by hand too, under Actions, Build, Run workflow). The
run's artifact `civil-war-battleset` holds them with the data folders, ready to play.

Run the programs from this folder. The game reads its pictures from `graphics`, its sounds from `sound`, its
campaign and name lists from `data`, and its scenarios from `scenarios`. It writes saved games and the PBM file
in `scenarios`. Its settings (`PREFER.CFG`), its history files (`generalz`, `maxskors`) and a campaign under way
(`regions.sav`) stay beside the program. With no option the game is silent; `cw s` plays its sounds.

The tests are described in [tests/README.md](tests/README.md). Work still to do is in [TODO.md](TODO.md).

The original documentation of the game is in `docs`: the manual of the game (`CW.DOC`) and of the editor
(`CS.DOC`), `SOUNDS.DOC`, `WRHGAMES.DOC`, `README.TXT` and `PLANY.DOC`, and the DOS title screen as a picture,
`CWBSTITL.png`. The notes on the port are in [docs/devnotes.md](docs/devnotes.md), and its plan in
[docs/port-study.md](docs/port-study.md).
