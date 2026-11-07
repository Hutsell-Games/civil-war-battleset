' Unit tests of the game's rules that draw nothing.
' Run from the repo's folder:  qb64rust test tests
'
' Each test runs in a program of its own, so every shared array starts at
' zero. A test sets the few values the SUB reads, calls it and checks what
' the code gives today. These tests record behavior; they do not judge it.
' The units of the Confederate side are 1 to 40 (m1), the Union's 41 to 80.

'$INCLUDE: '../civ20.bi'
'$INCLUDE: '../civwar25.bi'

' menufile (CIVWAR2A.BM) names this handler of the game's main module. No
' test reaches it.
GOTO endhandlers
caterr:
RESUME NEXT
endhandlers:

' ------------------------------------------------------------------ YouorMe
' F is 1 when the unit belongs to the player's side, else 0.

SUB TestYouorMeConfederatePlayer
side = 1
CALL YouorMe(40, F)
AssertEqualInt 1, F, "unit 40, the last Confederate"
CALL YouorMe(41, F)
AssertEqualInt 0, F, "unit 41, the first Union"
END SUB

SUB TestYouorMeUnionPlayer
side = 2
CALL YouorMe(41, F)
AssertEqualInt 1, F, "unit 41"
CALL YouorMe(1, F)
AssertEqualInt 0, F, "unit 1"
END SUB

' ------------------------------------------------------------------- LEFTY$
' The first letter of a unit's type: L (limbered) and w (waiting) come
' before the type itself.

SUB TestLeftyGivesTheFirstLetter
unit$(3) = "LA"
AssertEqualStr "L", LEFTY$(3), "limbered artillery"
unit$(4) = "wI"
AssertEqualStr "w", LEFTY$(4), "waiting infantry"
AssertEqualStr "", LEFTY$(5), "no unit"
END SUB

' -------------------------------------------------------------------- valid
' Morale and leadership are kept between 10 and 110.

SUB TestValidClampsMoraleAndLeader
morale(1) = 5: leader(1) = 200
CALL valid(1)
AssertEqualInt 10, morale(1), "morale 5"
AssertEqualInt 110, leader(1), "leader 200"
morale(2) = 75: leader(2) = 110
CALL valid(2)
AssertEqualInt 75, morale(2), "morale 75 stays"
AssertEqualInt 110, leader(2), "leader 110 stays"
END SUB

' ------------------------------------------------------------------- ranger
' A unit sees seelimit hexes, more from hills (94) and mountains (239), less
' from trees (42) and swamps (61).

SUB TestRangerByTerrain
seelimit = 18
terrain(1) = 46: CALL ranger(1, v): AssertEqualInt 18, v, "clearing"
terrain(1) = 94: CALL ranger(1, v): AssertEqualInt 20, v, "hill"
terrain(1) = 239: CALL ranger(1, v): AssertEqualInt 22, v, "mountain"
terrain(1) = 42: CALL ranger(1, v): AssertEqualInt 16, v, "trees"
terrain(1) = 61: CALL ranger(1, v): AssertEqualInt 14, v, "swamp"
END SUB

' --------------------------------------------------------------------- rank
' rank names a general by his average score dx (in tenths of a percent).
' With fewer than 15 games the score counts 90%.

SUB TestRankThresholds
CALL rank(20, 199, t$): AssertEqualStr "(civilian)", t$, "19.9%"
CALL rank(20, 200, t$): AssertEqualStr "Private", t$, "20%"
CALL rank(20, 500, t$): AssertEqualStr "Captain", t$, "50%"
CALL rank(20, 699, t$): AssertEqualStr "Lieutenant General", t$, "69.9%"
CALL rank(20, 700, t$): AssertEqualStr "General of the Army", t$, "70%"
END SUB

SUB TestRankFewGamesCountLess
dx = 500
CALL rank(3, dx, t$)
AssertEqualStr "Lieutenant", t$, "50% after 3 games counts as 45%, not Captain"
AssertEqualInt 450, dx, "dx is changed"
END SUB

' -------------------------------------------------------------------- intel
' What the report says of a unit's morale and leadership.

SUB TestIntelWords
morale(1) = 95: leader(1) = 95
CALL intel(1, m$, l$)
AssertEqualStr "Excellent", m$, "morale 95"
AssertEqualStr "Brilliant", l$, "leader 95"
morale(1) = 30: leader(1) = 30
CALL intel(1, m$, l$)
AssertEqualStr "TERRIBLE", m$, "morale 30"
AssertEqualStr "INEPT", l$, "leader 30"
morale(1) = 85: leader(1) = 85
CALL intel(1, m$, l$)
AssertEqualStr "Good", m$, "morale 85"
AssertEqualStr "Outstanding", l$, "leader 85"
END SUB

' ------------------------------------------------------------------- Bubble
' Bubble sorts mtx$(1 TO limit) and moves array() with it: the campaign's
' list of regions to attack, sorted by name.

SUB TestBubbleSortsNamesAndTheirIndexes
mtx$(1) = "Virginia": array(1) = 7
mtx$(2) = "Georgia": array(2) = 3
mtx$(3) = "Missouri": array(3) = 12
mtx$(4) = "Zulu": array(4) = 1
CALL Bubble(3)
AssertEqualStr "Georgia", mtx$(1), "first"
AssertEqualStr "Missouri", mtx$(2), "second"
AssertEqualStr "Virginia", mtx$(3), "third"
AssertEqualInt 3, array(1), "Georgia's region"
AssertEqualInt 12, array(2), "Missouri's region"
AssertEqualInt 7, array(3), "Virginia's region"
AssertEqualStr "Zulu", mtx$(4), "beyond the limit"
END SUB

' -------------------------------------------------------------------- codex
' codex codes the lines of a play-by-mail file: each character is shifted by
' timelimit MOD 7, its position and index MOD 9, and wraps at 255 (not 256).
' Both ways add the coded characters to chksum&, which the file stores.

SUB TestCodexRoundTrip
timelimit = 100
q$ = CHR$(34)
a$ = "3," + q$ + "Jackson" + q$ + "," + q$ + "I" + q$ + ",80,95,1200,20,7,46,0,0"
chksum& = 0
CALL codex(1, 3, a$, coded$)
sent& = chksum&
chksum& = 0
CALL codex(2, 3, coded$, back$)
AssertEqualStr a$, back$, "decoded"
AssertEqualInt sent&, chksum&, "the same checksum both ways"
AssertTrue coded$ <> a$, "coded differs"
END SUB

SUB TestCodexShift
timelimit = 100
CALL codex(1, 12, "AA", coded$)
' 100 MOD 7 = 2 and 12 MOD 9 = 3: "A" (65) + 2 + 1 + 3, then + 2 + 2 + 3.
AssertEqualInt 71, ASC(coded$, 1), "first character"
AssertEqualInt 72, ASC(coded$, 2), "second character"
END SUB

SUB TestCodexCharacter255DoesNotComeBack
' CHR$(255) codes to the shift itself, which decodes to CHR$(0). The game
' writes no such character: its lines are digits, letters and quotes.
timelimit = 100
CALL codex(1, 0, CHR$(255), coded$)
AssertEqualInt 3, ASC(coded$), "255 + 2 + 1 wraps to 3"
CALL codex(2, 0, coded$, back$)
AssertEqualInt 0, ASC(back$), "decoded"
END SUB

' ------------------------------------------------------------------ Compact
' Compact moves each side's units down over the empty slots and sets Bigg()
' to the side's last unit.

SUB TestCompactClosesGaps
strength(1) = 500: name$(1) = "Lee"
strength(3) = 300: name$(3) = "Hill": unitx(3) = 9
strength(4) = 200: name$(4) = "Ewell"
CALL Compact(1)
AssertEqualInt 3, Bigg(1), "three Confederate units"
AssertEqualStr "Hill", name$(2), "Hill moved to slot 2"
AssertEqualInt 9, unitx(2), "with his position"
AssertEqualStr "Ewell", name$(3), "Ewell moved to slot 3"
AssertEqualInt 0, strength(4), "slot 4 is empty"
END SUB

SUB TestCompactUnionSide
strength(41) = 100
strength(43) = 100
CALL Compact(2)
AssertEqualInt 42, Bigg(2), "two Union units"
END SUB

' ------------------------------------------------------------------ lowtime
' timex becomes the time of the next action: the lowest toa() of a living
' unit.

SUB TestLowtimeSkipsDeadUnits
Bigg(2) = 45
strength(2) = 100: toa(2) = 9
strength(3) = 0: toa(3) = 1
strength(44) = 100: toa(44) = 6
CALL lowtime
AssertEqualInt 6, timex, "unit 3 is dead"
END SUB

' ------------------------------------------------------------------- whois
' The first living, placed unit on a hex, other than index.

SUB TestWhoisFindsTheUnitOnAHex
Bigg(2) = 45
strength(5) = 100: unitx(5) = 10: unity(5) = 4
strength(42) = 100: unitx(42) = 10: unity(42) = 4
CALL whois(10, 4, e, 0)
AssertEqualInt 5, e, "the first unit there"
CALL whois(10, 4, e, 5)
AssertEqualInt 42, e, "not unit 5 itself"
uorder(42) = 99
CALL whois(10, 4, e, 5)
AssertEqualInt 0, e, "a unit that has not arrived (order 99)"
END SUB

' ---------------------------------------------------------------- proximity
' A unit's bonus from friends within 3 (2 per row, 1 per column): 1 each,
' 2 more for morale above 80, 1 more for leadership above 80, and for a
' general 15% of his leadership plus what it has above 90.

SUB TestProximityCountsNearbyFriends
Bigg(1) = 4
unitx(1) = 10: unity(1) = 5
unitx(2) = 12: unity(2) = 5: morale(2) = 85: leader(2) = 70: unit$(2) = "I"
unitx(3) = 11: unity(3) = 6: morale(3) = 70: leader(3) = 95: unit$(3) = "G"
unitx(4) = 20: unity(4) = 5: morale(4) = 90: leader(4) = 90: unit$(4) = "I"
CALL proximity(1, 0, 0, bonus)
' Unit 2: 1 + 2. Unit 3: 1 + 1 + 14.25 + 5. Unit 4 is 10 away.
AssertEqualInt 24, bonus, "units 2 and 3"
END SUB

' ------------------------------------------------------------------- normal
' normal adds 12 RNDs and subtracts 5.5, though their sum averages 6, so its
' draws center on xbar + SQR(vary) / 2, as in World War 2 (the same code).

SUB TestNormalWithoutVarianceIsTheMean
CALL normal(250, 0, r)
AssertEqualInt 250, r, "variance 0"
END SUB

SUB TestNormalDrawsHigh
RANDOMIZE 1
total& = 0
FOR i = 1 TO 2000
	CALL normal(100, 100, r)
	total& = total& + r
NEXT i
avg! = total& / 2000
AssertTrue avg! > 103 AND avg! < 107, "the average of 2000 draws is near 105, not 100:" + STR$(avg!)
END SUB

SUB TestNormalIsNeverNegative
RANDOMIZE 2
FOR i = 1 TO 500
	CALL normal(1, 400, r)
	IF r < 0 THEN Fail "a negative draw"
NEXT i
END SUB

' ------------------------------------------------------------------- curser
' curser moves a map position by a key: the keypad keys G, I, K, M, O, Q
' (Home, PgUp, Left, Right, End, PgDn) and the digits that jump to edges.
' A position is kept on the hex grid (x + y even) and inside 2..54, 1..20.

SUB TestCurserMoves
x = 10: y = 6
CALL curser("M", x, y): AssertEqualInt 12, x, "right moves 2 columns"
CALL curser("K", x, y): AssertEqualInt 10, x, "left"
CALL curser("G", x, y)
AssertEqualInt 9, x, "Home: up left, x"
AssertEqualInt 5, y, "Home: up left, y"
CALL curser("Q", x, y)
AssertEqualInt 10, x, "PgDn: down right, x"
AssertEqualInt 6, y, "PgDn: down right, y"
END SUB

SUB TestCurserJumpsAndEdges
x = 10: y = 6
CALL curser("5", x, y)
AssertEqualInt 28, x, "5: the center, x"
AssertEqualInt 10, y, "5: the center, y"
CALL curser("3", x, y)
AssertEqualInt 54, x, "3: bottom right, x"
AssertEqualInt 20, y, "3: bottom right, y"
CALL curser("M", x, y)
AssertEqualInt 54, x, "no further right than 54"
x = 2: y = 1
CALL curser("I", x, y)
AssertEqualInt 2, x, "PgUp on the top row does nothing, x"
AssertEqualInt 1, y, "PgUp on the top row does nothing, y"
END SUB

' --------------------------------------------------------- QB64.BM, SCRIPT.BM
' CURDIR$ is QB64's _CWD$ without the separator at its end. Not scripted,
' scriptfolder$ and scripttick% change nothing.

SUB TestCurdirIsTheCurrentFolder
AssertEqualStr _CWD$, CURDIR$ + RIGHT$(_CWD$, 1), "CURDIR$ and _CWD$"
END SUB

SUB TestScriptHooksDoNothingUnlessScripted
AssertEqualStr "D:\GAMES", scriptfolder$("D:\GAMES"), "scriptfolder$"
AssertEqualInt 0, scripttick%(5), "scripttick%"
END SUB

SUB TestScriptfolderWhenScripted
scripted = 1: scriptdir$ = "D:\RUN\GAME"
AssertEqualStr "C:\CWB", scriptfolder$("D:\RUN\GAME"), "the folder it started in"
AssertEqualStr "C:\CWB\SUB", scriptfolder$("d:\run\game\SUB"), "a folder inside it"
AssertEqualStr "E:\", scriptfolder$("E:\"), "another drive"
AssertEqualStr "01-01-2000 12:00", scriptdate$, "scriptdate$"
AssertEqualInt -1, scripttick%(5), "a short TICK returns at once"
END SUB

' Under a script, scriptshell copies and renames in BASIC instead of SHELL,
' whose cmd.exe would show a console window. The test sets CWB_SEED first,
' so it never runs a SHELL.
SUB TestScriptshellCopiesAndRenames
ENVIRON "CWB_SEED=1"
d$ = TestTempDir$ + "/"
f = FREEFILE: OPEN d$ + "maxskors" FOR OUTPUT AS #f: PRINT #f, "best": CLOSE #f
CALL scriptshell("copy", d$ + "maxskors", d$ + "temp.$$$")
AssertTrue _FILEEXISTS(d$ + "temp.$$$"), "copied"
f = FREEFILE: OPEN d$ + "temp.$$$" FOR INPUT AS #f: LINE INPUT #f, a$: CLOSE #f
AssertEqualStr "best", a$, "the copy's text"
CALL scriptshell("rename", d$ + "temp.$$$", d$ + "savegame.old")
AssertTrue _FILEEXISTS(d$ + "savegame.old"), "renamed"
AssertFalse _FILEEXISTS(d$ + "temp.$$$"), "the old name is gone"
CALL scriptshell("rename", d$ + "maxskors", d$ + "savegame.old")
AssertTrue _FILEEXISTS(d$ + "maxskors"), "no rename over an existing file"
END SUB

'$INCLUDE: '../civwar2a.bm'
'$INCLUDE: '../civwar2b.bm'
'$INCLUDE: '../civwar2c.bm'
'$INCLUDE: '../qb64.bm'
'$INCLUDE: '../script.bm'
