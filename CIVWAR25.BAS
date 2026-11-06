DEFINT A-Z
DECLARE SUB campaign ()
DECLARE SUB codex (flag%, index%, a$, t$)
DECLARE SUB campy (campane%, flag%)
DECLARE SUB email ()
DECLARE SUB noise (x%, y%, t$)
DECLARE SUB vistarg (active%, flag%)
REM $INCLUDE: 'civ20.bi'
CALL scriptstart: CLS

REM $INCLUDE: 'civwar25.bi'

version = 258
IF COMMAND$ <> "" THEN sblast$ = UCASE$(RIGHT$(COMMAND$, 1))
	choose = 22
	GOSUB lodecfg
	SCREEN 9, , 0, 0
ON ERROR GOTO noicon
	CALL iconload
'............................................................................
	LINE (70, 210)-(563, 286), 4, BF
	LINE (71, 212)-(561, 284), 15, B
	COLOR 15
	LOCATE 17: CALL center("Please Note")
	LOCATE 18: CALL center("This is your registered copy of the game.")
	LOCATE 19: CALL center("It is NOT Shareware and should not be further distributed.")
':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	IF sblast$ <> "" THEN
	t$ = "dixie": IF side = 2 THEN t$ = "hymn"
		CALL sndblst(t$)
	END IF
':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	TICK 2
'............................................................................
GOSUB testgen
GOSUB saveg
menu6:
	ON ERROR GOTO 0
	choose = 23
menu7:
	IF quiet = 1 THEN
		IF sblast$ = "" THEN
		       SOUND 1900, 1: SOUND 2000, 1
		ELSE
			CALL sndblst("ready")
		END IF
	END IF
	SCREEN 9
	COLOR 7, 0: CLS
	x = 8: IF side = 2 THEN x = 1
	IF nplayer = 2 THEN x = 5
	LINE (0, 0)-(639, 336), x, BF
	LINE (0, 336)-(639, 349), 4, BF
	LOCATE 25, 26: COLOR 15: PRINT " CIVILWAR BATTLESET "; .01 * version;
	tly = 9: tlx = 30
	choose = 23: IF flag = 1 THEN choose = 25
	mtx$(0) = "MAIN MENU"
	a$ = "Player :" + sname$(side): IF nplayer = 2 THEN a$ = "BOTH SIDES"
	mtx$(1) = a$
	mtx$(2) = "Load File": IF fold$ <> "" THEN mtx$(2) = fold$ + " LOADED"
	mtx$(3) = "Save File"
	mtx$(4) = "Fight"
	mtx$(5) = "Campaign Game": IF campane > 0 THEN mtx$(5) = "*CAMPAIGN UNDERWAY*"
	mtx$(6) = "PBM Game"
	mtx$(7) = "Parameters": IF pbm <> 0 THEN mtx$(7) = ""
	mtx$(8) = "Directory " + CURDIR$
	mtx$(9) = "Scenario Editor"
	mtx$(10) = "Quit"
	size = 10
hilite = 14
colour = 9: IF side = 1 THEN colour = 7
IF campane < 0 THEN choose = 25
CALL menu

SELECT CASE choose
	CASE 1
	IF nplayer = 0 THEN
		side = side + 1
		IF side > 2 THEN side = 1: nplayer = 2
	 ELSE
	nplayer = nplayer + 2: IF nplayer > 2 THEN nplayer = 0: side = 1
	END IF
	GOTO menu7
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                 Look for "*.civ" files and List Them               บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	CASE 2
regfile:
	IF fold$ <> "" THEN file$ = fold$
	campane = 0
	CALL menufile(t$)
	file$ = t$
	IF file$ = "" GOTO menu6
	IF LEFT$(file$, 1) = "$" THEN
		GOSUB ritefile
		u$ = "LOAD"
		GOSUB whichsave
	END IF
	IF file$ = "" GOTO menu7
	flag = 1
	ON ERROR GOTO filerr
camp:
	IF pbm > 0 THEN ON ERROR GOTO filerr
	OPEN "I", 1, file$
	LINE INPUT #1, SCENARIO$
	IF SCENARIO$ = "UNUSED" THEN file$ = "": flag = 0: CALL clrbot: PRINT "UNUSED savegame file": CLOSE #1: TICK 2: GOTO menu7
	flag = 2
	INPUT #1, timelimit, possess, vp&(1), vp&(2), score&(1), score&(2)
	flag = 3
	IF pbm > 0 THEN
		LINE (140, 100)-(480, 190), 15, B
		CALL icon(180, 110, 1)
		CALL icon(400, 110, 2)
	END IF
	FOR k = 1 TO 24
	IF pbm > 0 THEN LOCATE 25, 3: COLOR 4: PRINT "Decoding PBM Game ...";
	INPUT #1, sdtext$(k)
	NEXT k
	IF LEFT$(sdtext$(23), 1) = "|" THEN sdtext$(23) = ""
	altobj$ = ""
	x = INSTR(sdtext$(24), "/")
	IF x > 0 THEN
		altobj$ = sdtext$(24)
		FOR k = 1 TO 3
			x = INSTR(altobj$, "/")
			alt(k) = VAL(LEFT$(altobj$, x - 1))
			altobj$ = MID$(altobj$, x + 1)
		NEXT k
	END IF
	LOCATE 25, 23: COLOR 4: PRINT "ฒฐ"; : dx = 25
	flag = 4
		dx = POS(0)
	FOR k = 1 TO most: IF k MOD 2 = 1 THEN COLOR 9 + 5 * (k < m2): LOCATE 25, dx: PRINT "ฐ"; : dx = dx + 1
IF pbm < 1 THEN
		INPUT #1, a, name$(k), unit$(k), morale(k), leader(k), strength(k), unitx(k), unity(k), terrain(k), toa(k), uorder(k)
ELSE
		LINE INPUT #1, a$
		CALL codex(2, k, a$, t$)
		OPEN "O", 2, "temp.&&&"
		PRINT #2, t$
		CLOSE #2
		OPEN "I", 2, "temp.&&&"
		INPUT #2, a, name$(k), unit$(k), morale(k), leader(k), strength(k), unitx(k), unity(k), terrain(k), toa(k), uorder(k)
		CLOSE #2
		COLOR 14: LOCATE 16, 37: PRINT INT(k * 1.25); "%"
END IF
	IF unitx(k) > 54 THEN unitx(k) = 54
	IF unitx(k) < 2 THEN unitx(k) = 2
	IF unity(k) < 1 THEN unity(k) = 1
	IF unity(k) > 20 THEN unity(k) = 20
	IF (unitx(k) + unity(k)) MOD 2 <> 0 THEN
		IF unitx(k) > 2 THEN unitx(k) = unitx(k) - 1 ELSE unitx(k) = unitx(k) + 1
	END IF

	t$ = unit$(k)
	u$ = ""
strip:
	a$ = LEFT$(t$, 1)
	IF a$ = "w" OR a$ = "L" THEN
		t$ = MID$(t$, 2)
		IF a$ <> u$ THEN u$ = u$ + a$
		GOTO strip
	END IF
	t$ = LEFT$(t$, 1)
	IF INSTR("ABCEGHI่NL", t$) = 0 THEN LOCATE 20, 1: PRINT "WARNING : UNIT"; k; unit$(k); " TYPE is UNKNOWN - CHECK FILE": BEEP: TICK 9
	unit$(k) = u$ + t$
	IF strength(k) > 0 THEN terrain(k) = ASC(MID$(sdtext$(unity(k) + 1), unitx(k)))
NEXT k
IF pbm > 0 THEN
	KILL "temp.&&&"
	INPUT #1, bold, seelimit, difficult, quiet, mdsp
	FOR k = 1 TO 3: INPUT #1, factor(k): NEXT k
	INPUT #1, rely, stakk, limber, lineofsight, artcap, artdelay, intense!
	chksum& = chksum& + bold + seelimit + stakk + limber + lineofsight + artcap + artdelay
'................................ checksum .................................
		INPUT #1, temp&, side
		LOCATE 12
	IF temp& - chksum& = 0 THEN
		COLOR 15
		CALL center("File Checksum is OK")
		TICK 1
	ELSE
		COLOR 14
		CALL center("WARNING - Possible File Problem : Checksum Does Not Match !")
		TICK 4
	END IF
END IF
	IF LEFT$(file$, 1) <> "$" THEN sdtext$(23) = file$
	FOR k = 1 TO 22: stex$(k) = "": NEXT k
	k = 0
	DO WHILE NOT EOF(1) AND k < 22
	k = k + 1
	LINE INPUT #1, stex$(k)
	LOOP
tidy1:
	ON ERROR GOTO 0
	CLOSE #1
	CLOSE #2
	fold$ = file$
'...........................................................................
	highscore(1) = 0: highscore(2) = 0
	ON ERROR GOTO nomax
getmax:
	CLOSE #1: OPEN "I", 1, "maxskors"
	a$ = file$: IF LEFT$(file$, 1) = "$" THEN a$ = sdtext$(23)
	DO WHILE NOT EOF(1)
	z = z + 1
	INPUT #1, t$, x, y
	IF t$ = a$ THEN highscore(1) = x: highscore(2) = y
	LOOP
	CLOSE #1
'...........................................................................
	LOCATE 25, 1: PRINT SPACE$(79); : LOCATE 25, 1
	COLOR 14: PRINT file$; " file loaded";
	IF quiet = 1 AND sblast$ <> "" THEN LOCATE 1, 1: CALL sndblst("ding")
	TICK 2: flag = 1
	closest = 32767
	IF pbm <> 0 THEN pbm = 1
	IF campane > 0 GOTO cont1
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                               Save File                            บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	CASE 3
	IF flag < 1 THEN BEEP: CLS : CALL clrbot: COLOR 4: PRINT "NO FILE TO SAVE": TICK 2: GOTO menu7
	CLS
	u$ = "SAVE": GOSUB whichsave
	IF file$ = "" GOTO menu7
	IF sdtext$(23) = "" OR LEFT$(sdtext$(23), 1) = "$" THEN sdtext$(23) = "UNKNOWN"
	CLS : CALL clrbot: COLOR 11: PRINT "Saving file "; file$; " ";
	OPEN "O", 1, file$
	x = INSTR(SCENARIO$, "|"): IF x > 0 THEN SCENARIO$ = LEFT$(SCENARIO$, x - 1)
	a$ = SCENARIO$ + " | " + scriptdate$
	PRINT #1, a$
	WRITE #1, timelimit, possess, vp&(1), vp&(2), score&(1), score&(2)
	IF altobj$ <> "" THEN
		a$ = RIGHT$(altobj$, 1)
		sdtext$(24) = LTRIM$(RTRIM$(STR$(alt(1)))) + "/" + LTRIM$(RTRIM$(STR$(alt(2)))) + "/" + LTRIM$(RTRIM$(STR$(alt(3)))) + "/" + a$
	END IF
	FOR k = 1 TO 24: WRITE #1, sdtext$(k): PRINT "."; : NEXT k
	FOR k = 1 TO most
	WRITE #1, k, name$(k), unit$(k), morale(k), leader(k), strength(k), unitx(k), unity(k), terrain(k), toa(k), uorder(k)
	NEXT k
	FOR k = 1 TO 22: PRINT #1, stex$(k): NEXT k
	CLOSE #1
	CALL clrbot: COLOR 2: PRINT "SUCCESSFUL SAVE": TICK 2
	GOTO menu7
'...........................................................................
'                            choose save file
'...........................................................................
whichsave:
	CLS
	mtx$(0) = "SAVEGAME FILE TO " + u$
	FOR k = 1 TO 5
	a$ = LTRIM$(RTRIM$(STR$(k)))
	mtx$(k) = "$ave" + a$ + ".civ"
	CLOSE #1
	OPEN "I", 1, mtx$(k)
	LINE INPUT #1, t$
	x = INSTR(t$, "|"): IF x > 0 THEN a$ = MID$(t$, x - 1) ELSE a$ = ""
	IF LEN(t$) > 20 THEN t$ = LEFT$(t$, 20)
	IF LEN(t$) < 20 THEN t$ = t$ + SPACE$(20 - LEN(t$))
	mtx$(k) = mtx$(k) + " " + t$ + a$
	NEXT k
	CLOSE #1
	size = 5: tlx = 0
	hilite = 14
	colour = 3
	CALL menu
	file$ = "$ave" + LTRIM$(RTRIM$(STR$(choose))) + ".civ"
	IF choose < 1 OR choose > 5 THEN file$ = ""
RETURN
ritefile:
	x = INSTR(file$, "."): IF x > 0 THEN a$ = MID$(file$, x - 1, 1)
	choose = 21 + VAL(a$)
	RETURN
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                             Run Scenario                           บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	CASE 4
	IF flag = 0 THEN CALL clrbot: COLOR 4: PRINT "Must LOAD Scenario First"; : BEEP: CALL announce(1, ""): DO WHILE INKEY$ = "": LOOP: CALL clrbot: GOTO menu7
	GOTO cont1
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                              Campaign Map                          บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	CASE 5
	IF campane > 0 GOTO menu7
pane:
	CALL campaign
	vf = 1
	IF campane = 0 GOTO menu7
	CALL camess(camwin, y)
	COLOR 15: CALL center("Setting up battle in " + region$(campane) + " Region")
	LOCATE y + 9: CALL center("Score needed for " + sname$(camwin) + " Victory : " + STR$(cscore) + "%")
	CALL campy(campane, 0)
	ON ERROR GOTO fant
	GOTO camp
fant:
	RESUME fant1
fant1:
	ON ERROR GOTO 0
	file$ = "$ave1.civ"
	GOTO camp
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                         PBM Game                                   บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	CASE 6
	size = 1: mtx$(1) = "Begin NEW PBM Game"
	IF LEN(DIR$("*.pbm")) > 0 THEN size = 2: mtx$(2) = "Continue PBM Game"
	CALL menu
	SELECT CASE choose
		CASE 1
			pbm = -1
			nplayer = 1
			GOTO regfile
		CASE 2
			file$ = "savegame.pbm"
			pbm = 1
			nplayer = 1
			chksum& = 0
			GOTO camp
	END SELECT
	GOTO menu7
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                         Configure Game Parameters                  บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	CASE 7
	IF pbm <> 0 GOTO menu7
	CALL customize(x): IF x = 1 THEN GOSUB savecfg
	IF automatic > 0 GOTO cont1
	GOTO menu7
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                            Change Directory                        บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	CASE 8
	COLOR 7, 0: CLS
	t$ = CURDIR$
	tlx = 30
	brx = 54
	COLOR 11: LOCATE 1, 1: PRINT SPACE$(80)
	LOCATE 2, 1: PRINT SPACE$(80)
	LOCATE 2, 1: PRINT "Current Directory "; CURDIR$
	COLOR 14: LOCATE 1, 1: PRINT "New Directory >";
	CALL Enput(t$, 17, 1, 80, "")
	IF t$ = "" GOTO menu7
	ON ERROR GOTO aint1
	a$ = LEFT$(t$, 1)
	IF a$ <> LEFT$(CURDIR$, 1) THEN CHDRIVE a$: IF LEN(t$) < 3 GOTO menu7
	CHDIR t$
	ON ERROR GOTO 0
	GOTO menu7
aint1:
	COLOR 0, 4: CLS : COLOR 14: LOCATE 22, 20
	PRINT "Error "; ERR;
	IF ERR = 76 THEN
		PRINT "PATH '"; t$; "' NOT FOUND"
		ELSE PRINT "- CHECK DRIVE & DIRECTORY"
	END IF
	RESUME oldd
oldd:
	CALL TICK(9)
	GOTO menu6
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                             Run Editor                             บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	CASE 9
	RUN "cs.exe"
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                             Quit                                   บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	CASE 10
	COLOR 11, 0: CLS
	IF campane > 0 AND file$ <> "" THEN
		COLOR 15
		LINE (130, 20)-(490, 110), 4, BF
		LINE (135, 25)-(485, 105), 15, B
		LOCATE 4, 33: PRINT "W A R N I N G"
		LOCATE 5, 21: PRINT "Campaign Game: Battle in progress"
		LOCATE 6, 21: PRINT "must be completed or it will be lost"
	END IF
	mtx$(0) = "Quit CIVILWAR ?"
	mtx$(1) = "Not Yet"
	mtx$(2) = "Yes"
	size = 2: colour = 4
	CALL menu
	IF choose = 2 THEN CLS : END
	GOTO menu7
	CASE ELSE
	CLS
	GOTO menu6
END SELECT
GOTO menu7
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ  ******************    BEGIN MAIN GAME LOOP    ******************  บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
cont1:
ON ERROR GOTO 0
CALL mainmap
	CALL clrbot: COLOR 4: PRINT "Initializing";
	FOR i = 1 TO 2
		s = 1: IF i = 2 THEN s = m1
		CALL Compact(i)
		IF campane > 0 AND vf = 1 THEN
		bonus = 0: vf = 0
		FOR k = 1 TO 19
			z = 0
			IF region(k) = i THEN
				bonus = bonus + 1
				IF bonus > 1 THEN
muscle:
					x = s + RND * m1: z = z + 1
					IF strength(x) < 1 AND z < 9 GOTO muscle
					strength(x) = 1.5 * strength(x): IF strength(x) > 3000 THEN strength(x) = 3000
					IF RND > .5 THEN morale(x) = 110
					IF RND > .5 THEN leader(x) = 110
					IF toa(x) > 0 AND RND > .5 THEN toa(x) = 0
				END IF
			END IF
		NEXT k
		IF LEN(file$) > 3 THEN IF UCASE$(LEFT$(file$, 4)) = "CAMP" THEN CALL variety
		END IF
	NEXT i
	CALL lowtime
	IF pbm <> 0 AND timex <> 0 THEN pbm = timex
	FOR k = 1 TO Bigg(2): Visible(k) = 0
	IF strength(k) > 0 AND uorder(k) <> 99 AND terrain(k) = 233 THEN CALL victory(k)
	NEXT k

	s = 1: F = Bigg(side): IF side = 2 THEN s = m2
	IF nplayer = 2 THEN s = 1: F = Bigg(2): recon = 1: side = 1
	FOR active = s TO F: IF strength(active) > 0 AND uorder(active) <> 99 THEN Visible(active) = 1: CALL see(active)
	NEXT active

	startit! = scripttime!
IF file$ = "ERROR" GOTO menu7
CALL refresh
nother:
	CALL order
	IF pbm <> 0 THEN IF timex - pbm > 8 GOTO endpbm

IF LEN(file$) > 1 GOTO nother
IF file$ = "๔" THEN
    file$ = ""
    IF campane > 0 THEN file$ = fold$
    GOTO menu7
END IF
IF file$ = "๕" THEN
	IF pbm <> 0 GOTO endpbm
	file$ = ""
	IF automatic = 0 THEN flag = 0 ELSE automatic = 0: mdly! = mdsp + 1
	IF campane > 0 THEN
			t$ = sname$(camwin)
			R! = CINT(10 * skor#) / 10
			CALL cmap
			CALL area(0)
			IF camwin <> side THEN R! = 100 - R!: R! = CINT(10 * R!) / 10

			IF R! < cscore THEN
				camwin = 3 - camwin
			END IF

			CALL camess(camwin, y)
			COLOR 15
			a$ = "now": IF region(campane) = camwin THEN a$ = "STILL"
			CALL center(sname$(camwin) + " forces " + a$ + " control the " + region$(campane) + " Region")
			LOCATE y + 9: CALL center(t$ + " Score :" + STR$(R!) + "%" + "  Needed Score :" + STR$(cscore) + "%")
			CALL campy(campane, 1)

		IF camwin = side AND quiet > 0 THEN
			IF sblast$ <> "" THEN
				CALL trumpet(1 + m1 * (side - 1))
			ELSE
				IF side = 1 THEN
					PLAY "MFT110o2L16geL8ccL16cdefL8gggeMN"
				ELSE
					PLAY "MFL16o2T70dd.dd.co1b.o2do3g.ab.bb.agMN"
				END IF
			END IF
		END IF
			region(campane) = camwin
			campane = -1
			CLOSE #1
			file$ = "regions.sav"
			OPEN "O", 1, file$
			WRITE #1, camwin
			FOR k = 1 TO 19: WRITE #1, region(k): NEXT k
			CLOSE #1
			TICK 99
			tly = 10
			colour = 7: IF side = 2 THEN colour = 9
			mtx$(0) = "Options"
			mtx$(1) = "Continue Campaign"
			mtx$(2) = "Main Menu"
			size = 2
			CALL menu
			IF choose = 1 THEN
				choose = 99
				GOTO pane
			ELSE
				campane = 0
				file$ = ""
			END IF
	END IF
	GOTO menu7
END IF
GOTO nother
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ    END   MAIN GAME LOOP    ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
'                             GET FILE NAME
'============================================================================
fname:
	COLOR 7, 0: CLS : LOCATE 3, 1: PRINT "CURRENT FILES"
	FILES "*.civ"
	tlx = 13
	brx = 54
	LOCATE 1, 1: COLOR 11, 1: PRINT SPACE$(80)
	t$ = file$
	COLOR 11: LOCATE 2, 1: PRINT SPACE$(80)
	COLOR 14: LOCATE 2, 1: PRINT "Description :"; SCENARIO$
	LOCATE 1, 1: PRINT "File Name >";
	CALL Enput(t$, 14, 1, 25, "")
	IF LEN(t$) = 0 THEN
		IF file$ = "" THEN
			GOTO fname
			ELSE t$ = file$
		END IF
	END IF
	IF LEN(t$) < 1 GOTO fname
	x = INSTR(t$, "."): IF x > 0 THEN t$ = LEFT$(t$, x - 1)
	IF LEN(t$) > 8 THEN t$ = LEFT$(t$, 8)
	file$ = UCASE$(t$)
	IF INSTR(file$, ".") = 0 THEN file$ = file$ + ".civ"
RETURN
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                    Load Configuration File                         บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
lodecfg:
	intense! = 1
	RESTORE
	FOR k = 1 TO 5: READ adj1$(k): NEXT k
	FOR k = 1 TO 5: READ adj2$(k): NEXT k
	FOR k = 1 TO 5: READ adj3$(k): NEXT k
	FOR k = 1 TO 2: READ sname$(k): NEXT k
	ON ERROR GOTO nocfg
pref:
	OPEN "I", 1, "Prefer.cfg"
	INPUT #1, side, bold, seelimit, difficult, quiet, mdsp
	FOR k = 1 TO 3: INPUT #1, factor(k): NEXT k
	INPUT #1, rely, stakk, limber, lineofsight, artcap, history, artdelay, intense!
	CLOSE #1

	mdly! = 2 * mdsp - 2: IF mdsp = 5 THEN mdly! = 15
	ON ERROR GOTO 0
	RETURN
nocfg:
	CLOSE #1: RESUME scfg1
scfg1:
	bold = 3: seelimit = 18: difficult = 3: side = 1: quiet = 1: mdsp = 3
	factor(1) = 5: factor(2) = 10: factor(3) = 100: limber = 1
	rely = 3: stakk = 2: lineofsight = 1: artcap = 1: history = 1: artdelay = 3
	GOSUB savecfg
	ON ERROR GOTO 0
	GOTO pref
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                    Write New Configuration File                    บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
savecfg:
	OPEN "O", 1, "Prefer.cfg"
	COLOR 14: LOCATE 23, 1: PRINT "Saving configuration .";
	WRITE #1, side, bold, seelimit, difficult, quiet, mdsp: PRINT ".";
	WRITE #1, factor(1), factor(2), factor(3)
	WRITE #1, rely, stakk, limber, lineofsight, artcap, history, artdelay, intense!
	CLOSE #1
	PRINT " DONE": TICK 2
	RETURN

DATA Timid,Cautious,Normal,Bold,Reckless
DATA Very Easy,Easy,Normal,Hard,Very Hard
DATA VERY Fast,Fast,Normal,Slow,VERY Slow
DATA Confederate,Union

filerr:
	PRINT : PRINT "ERROR: "; ERR; " - ";
	IF ERR = 62 THEN
		PRINT "Input past end of file "; file$
		IF pbm > 0 THEN
			 COLOR 15: PRINT "PBM file may have extra carriage return /line feed characters": PRINT "Try running PBMFIX first"
		END IF
		GOTO softend
	END IF
	IF ERR = 53 THEN PRINT file$; " file not found": GOTO softend
	PRINT "ERROR :"; ERR; "Input File "; file$; " has something wrong with it"
	SELECT CASE flag
		CASE 1
		PRINT "Check the scenario description line"
		CASE 2
		PRINT "Check the timelimit and score line"
		CASE 3
		PRINT "Map has an error at line "; k
		PRINT sdtext$(k - 1)
		PRINT sdtext$(k)
		CASE 4
		PRINT "Unit "; k; " named '"; name$(k); "' has an error"
		CASE ELSE
	END SELECT
softend:
		CALL announce(1, ""): DO WHILE INKEY$ = "": LOOP
		END
caterr:
	LOCATE 22, 1: COLOR 14: PRINT "ERROR: "; ERR; " - ";
	IF ERR = 53 THEN PRINT "No *.civ files found": BEEP: RESUME retry
	END
retry:
	GOTO menu6
noicon:
	LOCATE 22, 1: COLOR 14: PRINT "ERROR: "; ERR; " - ";
	IF ERR = 53 THEN PRINT "BAD OR MISSING ICON FILES"
	END
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                       Set Up 5 Save Game Files                     บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
saveg:
	IF LEN(DIR$("$ave1.civ")) > 0 THEN RETURN
	LOCATE 22, 1: PRINT "Creating Save Game files...";
	FOR k = 1 TO 5
	a$ = LTRIM$(RTRIM$(STR$(k)))
	a$ = "$ave" + a$ + ".civ"
	IF LEN(DIR$(a$)) = 0 THEN OPEN "O", 1, a$: PRINT #1, "UNUSED": PRINT #1, "0": CLOSE #1
	NEXT k
	RETURN
nomax:
	RESUME savemax1
savemax1:
	ON ERROR GOTO 0
	CLOSE #1: OPEN "O", 1, "maxskors"
	WRITE #1, "PREVIOUS BEST SCORE FILE", 0, 0
	GOTO getmax

testgen:
	ON ERROR GOTO nogen
	CLOSE #1: OPEN "I", 1, "generalz"
getgen:
	CLOSE #1
	RETURN
nogen:
	RESUME savegen1
savegen1:
	ON ERROR GOTO 0
	CLOSE #1: OPEN "O", 1, "generalz"
	WRITE #1, "HALL OF FAME"
	CLOSE #1
	GOTO getgen
endpbm:
	CALL email
	file$ = "": fold$ = "": flag = 0
	GOTO menu6

REM $INCLUDE: 'civwar2a.bm'
REM $INCLUDE: 'civwar2b.bm'
REM $INCLUDE: 'civwar2c.bm'
REM $INCLUDE: 'qb64.bm'
REM $INCLUDE: 'script.bm'
