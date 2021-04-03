DEFINT A-Z
DECLARE SUB campaign ()
DECLARE SUB codex (flag%, index%, a$, t$)
DECLARE SUB campy (campane%, flag%)
DECLARE SUB email ()
DECLARE SUB noise (x%, y%, t$)
DECLARE SUB vistarg (active%, flag%)
REM $INCLUDE: 'civ20.bi'
RANDOMIZE TIMER: CLS

DIM SHARED Image(1 TO 1564), Iunion(60), Cunion(60), Aunion(60), Gunion(60)
DIM SHARED Ireb(60), Creb(60), Areb(60), Greb(60), Rmage(1 TO 1564)
DIM SHARED Cterr(60), Hterr(60), Sterr(60), Fterr(60)
DIM SHARED Tterr(60), Mterr(60), Oterr(60), Rterr(60)
DIM SHARED Wterr(60), Vterr(60), Bridge(60), Xhair(60)
DIM SHARED Explo(60), Death(60), Boat(60), Pfield(60)
DIM SHARED HAunion(60), HAreb(60), EGunion(60), EGreb(60), LAunion(60), LAreb(60)

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
	a$ = SCENARIO$ + " | " + DATE$ + " " + LEFT$(TIME$, LEN(TIME$) - 3)
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
	IF flag = 0 THEN CALL clrbot: COLOR 4: PRINT "Must LOAD Scenario First"; : BEEP: DO WHILE INKEY$ = "": LOOP: CALL clrbot: GOTO menu7
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

	startit! = TIMER
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
		DO WHILE INKEY$ = "": LOOP
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

SUB cannon (attack, defend)
	IF toa(attack) > timex THEN EXIT SUB
	IF defend = 0 THEN uorder(attack) = 0: EXIT SUB
	IF Visible(defend) = 0 OR uorder(defend) = 99 THEN EXIT SUB

	spin = 0
	CALL YouorMe(attack, a)
aimless:
	CALL los(attack, defend, F, 0)
	IF a = 0 AND F = 0 THEN
	spin = spin + 1
	s = 1: F = Bigg(1): IF attack = 1 THEN s = m2: F = Bigg(2)
	defend = s + INT(RND * (F - s))
	IF spin < 20 GOTO aimless ELSE EXIT SUB
	END IF

	SELECT CASE F
	CASE IS < 0
		EXIT SUB
	CASE 0
			y = 14 * unity(attack): x = 8 * unitx(attack)
			CALL clrbot: COLOR 14: PRINT "NOT IN LINE OF SIGHT !";
			CALL sndblst("bump")
			TICK mdly!
			CALL clrbot
			EXIT SUB
	CASE ELSE
	END SELECT

	CALL ranger(attack, vantage)
	u$ = LEFTY$(attack)
	IF u$ = "I" THEN vantage = 2
	PLAY "MF"
	d = 1.5 * ABS(unity(attack) - unity(defend)) + ABS(unitx(attack) - unitx(defend))
	IF d > vantage THEN EXIT SUB

	bonus = 2 * difficult - 6: IF difficult > 3 AND attack > m1 THEN bonus = bonus + 2
	CALL YouorMe(attack, F): IF F > 0 THEN bonus = 0
	CALL YouorMe(defend, F): IF F > 0 THEN CALL inspect(defend)

	plus = 0: IF u$ = "A" OR u$ = "B" THEN plus = 2
	IF u$ = "E" THEN plus = 3
	IF u$ = "H" THEN plus = -2
	IF u$ = "I" THEN plus = -3

	COLOR 7: IF attack > m1 THEN COLOR 9
	clrbot
	PRINT name$(attack);
	COLOR 11: PRINT " cannons fired at "; name$(defend); " "; : c = POS(0)
	y = 14 * unity(attack): x = 8 * unitx(attack)
	CIRCLE (x + 6, y + 6), 4, 14
	PAINT (x + 6, y + 6), 12, 14
	IF quiet = 1 THEN
		IF sblast$ <> "" THEN
			CALL sndblst("cannon1"): TICK .1
		ELSE
			FOR k = 1 TO 6: SOUND 37 + 40 * RND, 1: NEXT k
		END IF
	END IF

	CALL los(attack, defend, F, 1)

	IF uorder(attack) > -1 THEN uorder(attack) = 0
	flag = 5 + bonus + plus: IF RND > .8 THEN flag = flag + 3
	IF d > .5 * vantage + plus THEN flag = .7 * flag: IF d > .7 * vantage + plus THEN flag = .6 * flag
	IF RND > .9 THEN flag = flag + 3
	IF d < 3.5 + plus THEN flag = flag * 2 + 10 * RND + 1: IF u$ = "N" THEN flag = flag + 5
	t$ = LEFTY$(defend)
	IF t$ = "่" THEN unit$(defend) = "I": flag = flag + 2
	flag = (flag + 5 * RND) * intense!
	IF t$ = "L" THEN flag = flag + 2
	IF t$ = "w" THEN unit$(defend) = RIGHT$(unit$(defend), LEN(unit$(defend)) - 1): CALL SHOWUNIT(defend)

	IF quiet > 0 AND sblast$ = "" THEN FOR k = 3800 TO 3200 STEP -100: SOUND k, 1: NEXT k
	FOR i = 1 TO 5
	IF quiet = 1 AND sblast$ = "" THEN
		SOUND 50 * RND + 37, .05
	END IF
	CALL SHOWUNIT(defend): TICK .01
	PUT (8 * unitx(defend), 14 * unity(defend)), Explo, PSET: TICK .02
	NEXT i
	IF quiet = 1 AND sblast$ <> "" THEN TICK .03: CALL sndblst("cannon2")
	dx = .01 * flag * strength(attack): killed = dx
	killed2 = .01 * flag * strength(defend): a = terrain(defend): IF a = 42 OR a = 254 THEN killed2 = .5 * killed2
	IF a = 46 OR a = 61 THEN killed2 = 2 * killed2
	IF a = 35 THEN killed2 = .3 * killed2
	IF killed2 < killed THEN killed = killed2
	IF t$ = "B" THEN IF dx > .5 * strength(defend) THEN IF RND > .5 THEN killed = strength(defend)
	IF killed < 1 THEN killed = 1 + 10 * RND: IF killed > strength(defend) THEN killed = strength(defend)
	LOCATE 23, c: PRINT "... killing "; killed; : TICK mdly!
	Visible(attack) = 1
	CALL SHOWUNIT(defend)
	CALL SHOWUNIT(attack)

	morale(defend) = morale(defend) - 2: IF killed > 30 THEN morale(defend) = morale(defend) - 5

	IF RND + pct# > .99 THEN CALL deadlead(defend)

	dx = .05 * strength(defend): IF uorder(defend) < 0 THEN dx = .07 * strength(defend)
	IF t$ = "B" THEN dx = dx + .2 * strength(defend)
	IF terrain(defend) = 35 THEN dx = .1 * strength(defend)
	strength(defend) = strength(defend) - killed
	IF strength(defend) < 1 THEN CALL wipeout(defend): IF defend = 0 THEN morale(attack) = morale(attack) + 10: EXIT SUB
	IF killed > dx THEN CALL retreat(defend, attack)
	i = 1: IF defend > m1 THEN i = 2
	score&(i) = score&(i) + killed
sunk:
	toa(attack) = timex + artdelay - 1 + 2 * RND
	IF u$ = "E" THEN timex = timex + 1
	IF morale(attack) < 50 THEN toa(attack) = toa(attack) + 1: IF morale(attack) < 60 THEN toa(attack) = toa(attack) + 3
	IF leader(attack) < 70 THEN toa(attack) = toa(attack) + 2
	toa(defend) = timex + 2 + 6 * RND: IF RND > .7 THEN toa(defend) = toa(defend) + 3
	CALL scrcol(2)
	IF unity(attack) = objy AND unitx(attack) = objx GOTO Explode
	CALL YouorMe(attack, F): IF F > 0 THEN uorder(defend) = 0: GOTO Explode
	IF uorder(defend) = 0 THEN
		IF rely > 1 AND RND > .4 + .1 * bold AND morale(defend) > 70 THEN
			IF (t$ = "B" AND u$ = "B") OR (t$ <> "B" AND u$ <> "B") THEN uorder(defend) = 100 * unity(attack) + unitx(attack)
		END IF
	END IF
	CALL flee(defend, index)
	IF index > 0 AND uorder(defend) > -1 THEN uorder(defend) = 100 * unity(index) + unitx(index)
Explode:
	pct# = 0: IF u$ = "A" THEN pct# = .01
	IF RND < 1 - .003 * difficult - pct# THEN EXIT SUB
	COLOR 7: IF attack > m1 THEN COLOR 9

	x = .05 * strength(attack) + .1 * RND * strength(attack)
	FOR k = 1 TO 5
	ATTENTION attack, 12
		IF quiet = 1 THEN
			IF sblast$ = "" THEN
				SOUND 40, 1: SOUND 50, .7
			ELSE
			CALL sndblst("cannon1")
			END IF
		END IF
	PUT (8 * unitx(attack), 14 * unity(attack)), Explo, PSET
	NEXT k
	CALL clrbot: COLOR 12: PRINT "CANNON EXPLODED !"; x; " of "; name$(attack); "'s men killed";
	toa(attack) = toa(attack) + 3: score&(3 - i) = score&(3 - i) + x: CALL scrcol(2)
	strength(attack) = strength(attack) - x
	morale(attack) = .9 * morale(attack)
	TICK mdly!: CALL SHOWUNIT(attack)
END SUB

SUB flash (index, flag)
IF strength(index) < 1 OR uorder(index) = 99 THEN EXIT SUB
IF flag = 2 GOTO flick
	COLOR 14: IF quiet = 1 AND sblast$ = "" THEN SOUND 1200, 1
	clrbot
	PRINT name$(index); " has reached his destination"; : uorder(index) = 0
	FOR k = 1 TO 3: ATTENTION index, 14: NEXT k
	TICK .7
regular:
	CALL SHOWUNIT(index)
	EXIT SUB
flick:
	y = 14 * unity(index): x = 8 * unitx(index)
	LINE (x, y)-(x + 12, y + 12), 12, B
	PUT (x, y), Explo, PSET
	IF sblast$ = "" THEN TICK .01
	IF quiet = 1 THEN
		IF sblast$ = "" THEN
			SOUND 300, .15
		ELSE
			CALL sndblst("musket")
		END IF
	END IF
	IF sblast$ = "" THEN CALL Tara(unitx(index), unity(index) + 1, 0)
	CALL SHOWUNIT(index): TICK .01
END SUB

SUB help
CLS
LINE (1, 321)-(639, 336), 3, BF
COLOR 11: LOCATE 24, 35: PRINT " press any key ";
COLOR 15: LOCATE 1, 1
PRINT "ICON  Unit Type"
a$ = "I่CGANHBLEw": unitx(0) = 1: strength(0) = 1
FOR k = 1 TO 11
unity(0) = k: Visible(0) = 1
unit$(0) = MID$(a$, k, 1): CALL SHOWUNIT(0)
COLOR 3: LOCATE k + 1, 6
	SELECT CASE k
	CASE 1
	PRINT "Infantry"
	CASE 2
	PRINT "Charging Infantry"
	CASE 3
	PRINT "Cavalry"
	CASE 4
	PRINT "General"
	CASE 5
	PRINT "Rifled Artillery"
	CASE 6
	PRINT "Smooth Bore (Napoleon)"
	CASE 7
	PRINT "Horse Artillery"
	CASE 8
	PRINT "Boat"
	CASE 9
	PRINT "Limbered Artillery"
	CASE 10
	PRINT "Emplaced Gun (Stationary)"
	CASE 11
	PRINT "WAITING Unit"
	CASE ELSE
	END SELECT
NEXT k
LOCATE 1, 40: COLOR 15: PRINT "ICON Terrain ";
COLOR 4: PRINT "Move Turns ";
COLOR 2: PRINT "Defend Bonus"
x = 320
PUT (x, 14), Tterr, PSET
PUT (x, 28), Fterr, PSET
PUT (x, 42), Rterr, PSET
PUT (x, 56), Cterr, PSET
PUT (x, 70), Sterr, PSET
PUT (x, 84), Bridge, PSET
PUT (x, 98), Hterr, PSET
PUT (x, 112), Wterr, PSET
PUT (x, 126), Oterr, PSET
PUT (x, 140), Mterr, PSET
PUT (x, 154), Vterr, PSET
PUT (x, 168), Pfield, PSET
COLOR 3
a$ = "Trees Fort Road Clear Swamp Bridge Hill Water OBJCTV Mtn Village Plowd "

FOR k = 1 TO 12
x = INSTR(a$, " ")
t$ = LEFT$(a$, x - 1)
a$ = MID$(a$, x + 1)
LOCATE k + 1, 45: PRINT t$
NEXT k
COLOR 14
LOCATE 2, 57: PRINT "3 	  +5%" '*
LOCATE 3, 57: PRINT "2 	  +10%"'#
LOCATE 4, 57: PRINT "1 	   0"  '+
LOCATE 5, 57: PRINT "2 	   0"  '.
LOCATE 6, 57: PRINT "6 	  -5%" '=
LOCATE 7, 57: PRINT "1 	   0"  '[
LOCATE 8, 57: PRINT "4 	  +6%" '^
LOCATE 9, 57: PRINT "X 	   X"  'ฐ
LOCATE 10, 57: PRINT "2 	   0" '้
LOCATE 11, 57: PRINT "6 	  +9%"'๏
LOCATE 12, 57: PRINT "2 	  +3%" 'þ
LOCATE 13, 57: PRINT "3 	  +3%" ':
COLOR 4: LOCATE 4, 70: PRINT "*": LOCATE 5, 70: PRINT "*"
LOCATE 14, 45: PRINT "* Defend is -15% vs. Attack Cav"
LOCATE 9, 57: PRINT "X"
LINE (420, 14)-(480, 181), 4, B
LINE (510, 14)-(580, 181), 2, B
COLOR 15: LOCATE 14, 2: PRINT "HOT KEYS": COLOR 3
LINE (1, 183)-(639, 195), 4, B
PRINT " ire (ARTILLERY)"; TAB(40); "imber/Unlimber (ARTILLERY)"
PRINT "i spire unit (GENERAL)"; TAB(40); " cancel unit orders (GENERAL)"
PRINT " harge (INFANTRY)"; TAB(40); "ntelligence"
PRINT " oin (see eligible units)"; TAB(40); "ove to destination"
PRINT " iew (line of sight)"; TAB(40); "ait Unit";
PRINT : PRINT " AME SCORE"; TAB(40); "RDER OF BATTLE REPORT"
PRINT " UIET SOUND TOGGLE"; TAB(40); "ECON MODE TOGGLE"
PRINT " CREEN REDRAW"; TAB(40); "ERRAIN ONLY"
PRINT "        Blank Screen"
COLOR 14
LOCATE 15, 1: PRINT "F": LOCATE 15, 39: PRINT "L"
LOCATE 16, 2: PRINT "N": LOCATE 16, 39: PRINT "X"
PRINT "C": LOCATE 17, 39: PRINT "I"
PRINT "J": LOCATE 18, 39: PRINT "M"
PRINT "V": LOCATE 19, 39: PRINT "W"
LINE (0, 265)-(639, 265), 10, , &HFF00
COLOR 15: LOCATE 20, 1: PRINT "G": LOCATE 20, 39: PRINT "O"
PRINT "Q": LOCATE 21, 39: PRINT "R"
PRINT "S": LOCATE 22, 39: PRINT "T"
PRINT "ctrl-B"
TICK 99: strength(0) = 0: Visible(0) = 0
END SUB

SUB icon (x, y, s)
IF sideicon < 1 THEN EXIT SUB
SELECT CASE s
	CASE 1
	PUT (x, y), Rmage, PSET
	CASE 2
	PUT (x, y), Image, PSET
END SELECT
END SUB

SUB iconload
LINE (0, 0)-(639, 349), 5, BF
LOCATE 24, 1: COLOR 11: PRINT "Loading Icons...";
SCREEN 9, 0, 1, 0
'----------------------------------------------------------------------------
'                            UNIT Icons..... STDICON
'----------------------------------------------------------------------------
	DEF SEG = VARSEG(Image(1))
	BLOAD "stdicon.ega", VARPTR(Image(1))
	DEF SEG

	PUT (100, 100), Image, PSET
	GET (101, 101)-(116, 114), Iunion
	GET (101, 115)-(116, 128), Cunion
	GET (101, 129)-(116, 142), Aunion
	GET (101, 143)-(116, 156), Gunion
       
	GET (117, 101)-(132, 114), Ireb
	GET (117, 115)-(132, 128), Creb
	GET (117, 129)-(132, 142), Areb
	GET (117, 143)-(132, 156), Greb
'----------------------------------------------------------------------------
'                            UNIT Icons..... ALTICON
'----------------------------------------------------------------------------
	DEF SEG = VARSEG(Image(1))
	BLOAD "alticon.ega", VARPTR(Image(1))
	DEF SEG

	PUT (100, 100), Image, PSET
	GET (101, 101)-(116, 114), LAunion
	GET (101, 115)-(116, 128), EGunion
	GET (101, 129)-(116, 142), HAunion

	GET (117, 101)-(132, 114), LAreb
	GET (117, 115)-(132, 128), EGreb
	GET (117, 129)-(132, 142), HAreb
'----------------------------------------------------------------------------
'                            Terrain Icons
'----------------------------------------------------------------------------
	DEF SEG = VARSEG(Image(1))
	BLOAD "terrain.ega", VARPTR(Image(1))
	DEF SEG
	PUT (200, 100), Image, PSET
	GET (200, 101)-(215, 114), Cterr
	GET (200, 115)-(215, 128), Hterr
	GET (200, 129)-(215, 142), Sterr
	GET (200, 143)-(215, 156), Fterr

	GET (217, 101)-(232, 114), Tterr
	GET (217, 115)-(232, 128), Mterr
	GET (217, 129)-(232, 142), Oterr
	GET (217, 143)-(232, 156), Rterr
'----------------------------------------------------------------------------
'                         Miscellaneous Icons
'----------------------------------------------------------------------------
	DEF SEG = VARSEG(Image(1))
	BLOAD "misc.ega", VARPTR(Image(1))
	DEF SEG
	PUT (300, 100), Image, PSET
	GET (300, 101)-(315, 114), Wterr
	GET (300, 115)-(315, 128), Vterr
	GET (300, 129)-(315, 142), Explo
	GET (300, 143)-(315, 156), Bridge

	GET (317, 101)-(332, 114), Xhair
	GET (317, 115)-(332, 128), Death
	GET (317, 129)-(332, 142), Boat
	GET (317, 143)-(332, 156), Pfield
'----------------------------------------------------------------------------
'                         Side Identifier Icons
'----------------------------------------------------------------------------
sideicon = 0
IF LEN(DIR$("yank.ega")) = 0 GOTO noside
DEF SEG = VARSEG(Image(1))
BLOAD "yank.ega", VARPTR(Image(1))
DEF SEG
DEF SEG = VARSEG(Rmage(1))
BLOAD "reb.ega", VARPTR(Rmage(1))
DEF SEG
sideicon = 1
noside:
SCREEN 9, 0, 0, 0
END SUB

SUB los (index, Enemy, F, flag)
'  F=-1 : friendly  F=0 : no LOS    F=1 : Enemy in LOS
' flag=cursor flag   0=invisible  1=visible
	IF lineofsight = 0 THEN F = 1: EXIT SUB
	F = 0
	IF index = Enemy THEN F = -1: EXIT SUB

	plus = 1
	SELECT CASE terrain(index)
		CASE 42, 58, 61
		plus = 0
		CASE 94
		plus = 2
		CASE 176
		plus = 5
		CASE 239
		plus = 3
	END SELECT
	a = 0
	SELECT CASE terrain(Enemy)
		CASE 94
		a = 1
		CASE 239
		a = 2
	END SELECT
	plus = plus + a

	xnew = unitx(index): ynew = unity(index)
	bonus = 0
	j = 3800 + 100 * seelimit
DO
	bonus = bonus + 1
	dxs = SGN(unitx(Enemy) - xnew)
	dys = SGN(unity(Enemy) - ynew)
	dx = ABS(unitx(Enemy) - xnew)
	dy = ABS(unity(Enemy) - ynew)
	IF dx > 4 * dy THEN xnew = xnew + 2 * dxs: GOTO hilit
	IF dxs = 0 THEN dxs = 1: IF xnew > 28 THEN dxs = -1
	xnew = xnew + dxs: ynew = ynew + dys
hilit:
	IF xnew > 0 THEN
		z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
		IF (z = 42 OR z = 254) THEN plus = plus - 1
		IF z = 94 THEN plus = plus - 2
		IF z = 239 THEN plus = plus - 5
		IF xnew = unitx(Enemy) AND ynew = unity(Enemy) THEN F = 1: EXIT SUB
		IF plus < 1 THEN F = 0: EXIT SUB
	 
	IF flag > 0 THEN
		PUT (8 * xnew, 14 * ynew), Xhair, XOR
		IF sblast$ = "" THEN
			IF quiet > 0 THEN
				j = j - 100
				SOUND j, 1
			ELSE
				TICK .015
			END IF
		END IF
		PUT (8 * xnew, 14 * ynew), Xhair, XOR
	END IF
	END IF

LOOP WHILE bonus < 50
END SUB

SUB mainmap
COLOR 2, 0: SCREEN 9: CLS
count = 0
LINE (10, 1)-(639, 300), 8, BF
x = INSTR(SCENARIO$, "|"): IF x > 0 THEN SCENARIO$ = LEFT$(SCENARIO$, x - 1)
IF LEN(SCENARIO$) > 55 THEN SCENARIO$ = LEFT$(SCENARIO$, 55)
COLOR 15: x = 55 - LEN(SCENARIO$): x = .5 * x + 1: LOCATE 1, x: PRINT SCENARIO$
LINE (10, 0)-(639, 300), 4, B
FOR k = 2 TO 21
	s = 2: IF INT(.5 * k) * 2 = k THEN s = 1
	FOR j = s TO 54 STEP 2
	CALL Tara(j, k, 0)
	NEXT j
x = INSTR(sdtext$(k), "้"): IF x > 0 THEN objx = x: objy = k - 1: count = count + 1
NEXT k
	CALL scrcol(0)
	IF count = 1 GOTO dork2
dork1:
	CLS
	colour = 14: hilite = 14
	colour = 6
	mtx$(0) = " MAP FILE ERROR : " + file$
	mtx$(1) = " MAP HAS " + STR$(count) + " OBJECTIVES"
	mtx$(2) = " hit any key"
	file$ = "ERROR"
	size = 2
	FOR k = 1 TO 24: sdtext$(k) = SPACE$(78): NEXT k
	CALL menu
dork2:
END SUB

SUB menufile (t$)
SCREEN 0: COLOR 0, 1: CLS
LOCATE 1, 1: COLOR 4, 3: PRINT SPACE$(80)
LOCATE 1, 1: PRINT "{arrow keys} TO SELECT FILE      {ENTER} TO LOAD    CURRENT ="
IF t$ <> "" THEN COLOR 0, 3: LOCATE 1, 63: PRINT t$
COLOR 4, 3
LOCATE 25, 1: PRINT SPACE$(79);
LOCATE 25, 1: COLOR 15, 3: PRINT TAB(27); "CIVILWAR BATTLESET "; .01 * version;
COLOR 11, 1: LOCATE 2, 1
ON ERROR GOTO caterr
a$ = "*.civ"
FILES a$
ON ERROR GOTO 0
maxy = CSRLIN - 2
y = 3: x = 1: x0 = 1: y0 = 3
FOR k = 1 TO 12: t0$ = t0$ + CHR$(SCREEN(y, 18 * (x - 1) + k)): NEXT k

ff0:
LOCATE y, 10 * (x - 1) + 1
t$ = ""
FOR k = 1 TO 12
a = SCREEN(y, 18 * (x - 1) + k)
t$ = t$ + CHR$(a)
NEXT k
LOCATE y, 18 * (x - 1) + 1
COLOR 0, 5: PRINT t$
t0$ = t$

a$ = ""
DO WHILE a$ = "": a$ = INKEY$: LOOP
q = ASC(UCASE$(RIGHT$(a$, 1)))
SELECT CASE q
	CASE 27
	t$ = "": COLOR 11, 1: CLS : EXIT SUB
	CASE 13
	GOTO ff7
	CASE 71
	x = x - 1: y = y - 1
	CASE 72
	y = y - 1
	CASE 73
	x = x + 1: y = y - 1
	CASE 75
	x = x - 1
	CASE 77
	x = x + 1
	CASE 79
	x = x - 1: y = y + 1
	CASE 80
	y = y + 1
	CASE 81
	x = x + 1: y = y + 1
	CASE ELSE
END SELECT
IF x < 1 THEN x = 1
IF y < 3 THEN y = 3
IF y > maxy THEN y = maxy
IF x > 4 THEN x = 4
LOCATE y0, 18 * (x0 - 1) + 1
COLOR 11, 1: PRINT t0$
x0 = x: y0 = y
GOTO ff0

ff7:
COLOR 4, 3: LOCATE 25, 1: PRINT SPACE$(79);
x = INSTR(t$, "."): a$ = RTRIM$(LEFT$(t$, x - 1)): t$ = a$ + ".civ"
LOCATE 25, 2: PRINT "Loading "; t$; " ";
COLOR 11, 0
END SUB

SUB musket (attack, defend, pct#)
'============================================================================
'                                Attacker fires first
'============================================================================
CALL YouorMe(attack, F)
PUT (8 * unitx(defend), 14 * unity(defend)), Explo, PSET
IF F = 0 THEN
	roll! = .05 * difficult: IF difficult > 3 THEN roll! = roll! + .02 * difficult
ELSE
	roll! = .15
END IF
IF LEFTY$(defend) = "w" THEN unit$(defend) = MID$(unit$(defend), 2): CALL SHOWUNIT(defend)

CALL proximity(attack, 0, 0, bonus)
fbase = pct# * strength(attack)
SELECT CASE terrain(defend)
	CASE 94: roll! = .09
	CASE 239: roll! = .06
	CASE 61: roll! = .2
	CASE 42: roll! = .1
	CASE 58, 254: roll! = .12
	CASE 35: roll! = .05
	CASE ELSE
END SELECT

IF morale(attack) > 80 THEN roll! = roll! + .05: IF morale(attack) > 90 THEN roll! = roll! + .05
IF leader(attack) > 80 THEN roll! = roll! + .05: IF leader(attack) > 90 THEN roll! = roll! + .05
IF morale(attack) < 60 THEN roll! = roll! - .1
IF leader(attack) < 60 THEN roll! = roll! - .1
IF uorder(defend) < 0 THEN roll! = roll! - .2              'Enemy dug in
u$ = LEFTY$(attack): IF u$ = "G" THEN roll! = roll! - .2  'General Unit
IF u$ = "L" THEN roll! = .2 * roll!   'Limbered
roll! = intense! * roll!
IF pct# < .8 THEN roll! = .5 * roll!                       'scale down light attacks
IF roll! < .01 THEN roll! = .01                            'Minimum
'============================================================================
'                      Bonus for Cavalry Charge & Charging Infantry
'============================================================================
flag = 0
IF (terrain(defend) = 43) OR (terrain(defend) = 46) AND LEFTY$(attack) = "C" THEN roll! = roll! + .15: bonus = bonus + .1 * leader(attack): flag = 1
IF LEFTY$(attack) = "่" THEN roll! = roll! + .02: bonus = bonus + .05 * leader(attack)

index = 2: IF attack > m1 THEN index = 1

CALL normal(fbase * roll!, fbase * roll! * (1 - roll!), killed)
killed = killed + bonus
IF killed < 1 THEN killed = 1
IF killed > strength(defend) THEN killed = strength(defend)
dx = killed
CALL flash(defend, 2)
FOR k = 1 TO .02 * killed
IF killed > 49 THEN score&(index) = score&(index) + 50: CALL scrcol(2): dx = dx - 50
CALL flash(defend, 2)
NEXT k
score&(index) = score&(index) + dx
CALL scrcol(2)
CALL SHOWUNIT(defend)

IF RND > .99 THEN CALL deadlead(defend)
'============================================================================
'                                Defender returns fire
'============================================================================
CALL YouorMe(defend, F)
IF F = 0 THEN
	roll! = .053 * difficult: IF difficult > 3 THEN roll! = roll! + .02 * difficult
ELSE
	roll! = .16
END IF

fbase = pct# * strength(defend)
CALL proximity(defend, 0, 0, bonus)
SELECT CASE terrain(attack)
	CASE 94: roll! = .1
	CASE 239: roll! = .07
	CASE 61: roll! = .21
	CASE 42: roll! = .11
	CASE 58, 254: roll! = .13
	CASE 35: roll! = .06
	CASE ELSE
END SELECT
IF morale(defend) > 80 THEN roll! = roll! + .05: IF morale(defend) > 90 THEN roll! = roll! + .05
IF leader(defend) > 80 THEN roll! = roll! + .05: IF leader(defend) > 90 THEN roll! = roll! + .05
IF morale(defend) < 60 THEN roll! = roll! - .1
IF leader(defend) < 60 THEN roll! = roll! - .1
t$ = LEFTY$(defend): IF t$ = "G" THEN roll! = roll! - .1
IF t$ = "L" THEN roll! = .05
IF u$ = "L" THEN roll! = 5 * roll!: IF roll! > 1 THEN roll! = 1

roll! = intense! * roll!
IF pct# < .8 THEN roll! = .5 * roll!
IF roll! < .02 THEN roll! = .02
IF bonus < .05 * killed THEN bonus = .05 * killed

CALL normal(fbase * roll!, fbase * roll! * (1 - roll!), killed2)
killed2 = killed2 + bonus
IF killed2 < 1 THEN killed2 = 1
IF killed2 > strength(attack) THEN killed2 = strength(attack)
dx = killed2
CALL flash(attack, 2)
FOR k = 1 TO .02 * killed2
IF killed2 > 49 THEN score&(3 - index) = score&(3 - index) + 50: CALL scrcol(2): dx = dx - 50
CALL flash(attack, 2)
NEXT k
score&(3 - index) = score&(3 - index) + dx
CALL scrcol(2)
CALL SHOWUNIT(attack)

toa(attack) = timex + 4: IF leader(attack) < 70 THEN toa(attack) = timex + 6
IF LEFTY$(defend) <> "C" OR morale(defend) < 50 THEN
	toa(defend) = timex + 3
	IF RND > .6 THEN toa(defend) = toa(attack) + 1
	IF leader(defend) < 60 THEN toa(defend) = timex + 6
END IF

IF RND > .99 THEN deadlead (attack)
safe:
	clrbot
	COLOR 12: PRINT " CASUALTIES ";
	a$ = sname$(1): COLOR 7: IF attack > m1 THEN COLOR 9: a$ = sname$(2)
	LOCATE 23, 20: PRINT " "; a$; killed2;
	a$ = sname$(1): COLOR 7: IF defend > m1 THEN COLOR 9: a$ = sname$(2)
	LOCATE 23, 50: PRINT " "; a$; killed;
	TICK mdly!

	pra! = killed2 / (strength(attack) + 1) - .00004 * (morale(attack) + leader(attack))
	prd! = killed / (strength(defend) + 1) - .00004 * (morale(defend) + leader(defend))
	xold = unitx(attack): yold = unity(attack): x2 = unitx(defend): y2 = unity(defend)
       
	strength(attack) = strength(attack) - killed2
	CALL wipeout(attack): IF attack = 0 THEN morale(defend) = morale(defend) + 10

	strength(defend) = strength(defend) - killed: CALL wipeout(defend): IF defend = 0 THEN morale(attack) = morale(attack) + 10

	x0 = 0
	IF INSTR("AENHL", t$) > 0 AND INSTR("ANHL", u$) = 0 AND artcap > 0 THEN x0 = INT(killed / 20): IF strength(defend) < 1 THEN IF strength(attack) > 0 THEN CALL pursue(attack, x2, y2, x0): GOTO seeme
	IF strength(defend) < 1 THEN IF strength(attack) > 0 THEN CALL pursue(attack, x2, y2, x0): GOTO seeme
'...........................................................................
'                       check for attacker retreat
'...........................................................................
	IF attack = 0 GOTO coffin
	CALL proximity(attack, 0, 0, bonus)
	R! = .02: IF bonus < 10 THEN R! = .01
	IF pra! >= R! THEN uorder(attack) = 0
	rflag = 0
	pct# = .02 * difficult: IF bonus > 9 THEN pct# = pct# + .03
	IF LEFTY$(attack) = "C" AND flag = 0 THEN pct# = pct# - .01
	IF pra! >= pct# THEN CALL retreat(attack, defend): rflag = 1
	IF prd! < pct# AND INSTR("AENHL", t$) = 0 THEN CALL pursue(defend, xold, yold, 0)
'...........................................................................
'                       check for defender retreat
'...........................................................................
coffin:
	IF defend = 0 THEN toa(attack) = timex + 1: GOTO seeme

	CALL proximity(defend, 0, 0, bonus)
	R! = .02: IF bonus < 10 THEN R! = .01
	IF prd! >= R! AND uorder(defend) > -1 THEN uorder(defend) = 0
	pct# = .05: IF bonus > 9 THEN pct# = pct# + .03

	IF morale(defend) > 80 THEN pct# = pct# + .02
	IF flag = 1 THEN pct# = pct# - .05                      'cavalry charge
	IF LEFTY$(attack) = "่" THEN pct# = pct# - .02

	IF uorder(defend) < 0 THEN pct# = pct# + .02
	IF prd! >= .07 THEN uorder(defend) = 0
	IF terrain(defend) = 35 THEN pct# = pct# + .03
	IF prd! >= pct# THEN CALL retreat(defend, attack)

	IF rflag = 0 AND pra! < pct# - .01 AND INSTR("ANHL", u$) = 0 THEN CALL pursue(attack, x2, y2, 0)
seeme:
	IF LEFTY$(attack) = "่" THEN unit$(attack) = "I"
	CALL SHOWUNIT(attack): CALL SHOWUNIT(defend)
END SUB

SUB order
	flag = 0
	CALL BuffClear
	IF nplayer = 2 THEN GOSUB aque
'============================================================================
'                      Find Time of Next Action
'============================================================================
	told = timex
	CALL lowtime
	IF possess > 0 THEN vp&(possess) = vp&(possess) + factor(2) * (timex - told)
	IF altobj$ <> "" THEN
		IF timex >= alt(1) THEN
			sdtext$(objy + 1) = LEFT$(sdtext$(objy + 1), objx - 1) + altobj$ + MID$(sdtext$(objy + 1), objx + 1)
			CALL Tara(objx, objy + 1, 0)
			PCOPY 0, 1
			SCREEN 9, , 1, 1
			COLOR 15
			LINE (80, 140)-(400, 180), 4, BF
			LINE (80, 140)-(400, 180), 15, B
			LOCATE 12, 15: PRINT "The battle objective has shifted"
			TICK mdly!
			SCREEN 9, , 0, 0
			CALL whois(objx, objy, Enemy, 0)
			objx = alt(2)
			objy = alt(3)
			terrain(Enemy) = ASC(altobj$)
			altobj$ = ""
			sdtext$(objy + 1) = LEFT$(sdtext$(objy + 1), objx - 1) + "้" + MID$(sdtext$(objy + 1), objx + 1)
			possess = 0
			CALL whois(objx, objy, Enemy, 0)
			IF Enemy > 0 AND uorder(Enemy) <> 99 THEN
				s = 1: IF Enemy > m1 THEN s = 2
				possess = s
			END IF
			CALL Tara(objx, objy + 1, 0)
		END IF
	END IF
notime:
	IF timelimit - timex <= 0 THEN
		CALL clrbot
		COLOR 14
		PRINT "Time expired - game is over ";
		mtx$(0) = "Time Limit Reached (" + STR$(timelimit) + ")"
		mtx$(1) = "End Game & See Results"
		mtx$(2) = "Play 10 More Turns"
		tlx = 25: tly = 5
		size = 2: colour = 13
		IF campane = 0 AND pbm = 0 THEN CALL menu ELSE choose = 1: TICK 9
		IF choose = 2 THEN
			CALL mainmap
			CALL refresh
			timelimit = timelimit + 10
			IF possess <> 0 THEN vp&(possess) = vp&(possess) + factor(3)
			history = 0
			GOTO playon
		END IF
endgame:
		IF nplayer = 2 OR pbm <> 0 THEN
			history = 0
			FOR k = 1 TO 2
			side = k: CALL expire
			NEXT k
		ELSE
			CALL expire
		END IF
		file$ = "๕"
		CLS
		EXIT SUB
	END IF
playon:
	CALL scrcol(2)

	IF automatic = 1 THEN CALL minsec: IF PEEK(1052) > 30 THEN file$ = "๔": automatic = 0: EXIT SUB
	IF nplayer = 2 THEN
		queue(1) = 0: queue(2) = 0
		FOR k = 1 TO Bigg(2)
			x = 1: IF k > m1 THEN x = 2
			IF strength(k) > 0 AND toa(k) = timex THEN
			queue(x) = queue(x) + 1
			END IF
		NEXT k
	END IF
	FOR active = 1 TO Bigg(2): CALL BuffClear
	IF strength(active) < 1 OR toa(active) > timex GOTO snore
	IF uorder(active) = 99 THEN GOSUB canplace: IF uorder(active) = 99 GOTO sleep2
	IF nplayer = 2 THEN
		COLOR 14
		queue(side) = queue(side) - 1
		IF queue(side) > -1 THEN LOCATE 1, 75: PRINT queue(side); : LINE (453, 0)-(631, 13), 4, B
	END IF
	t$ = LEFTY$(active)
	IF t$ = "w" THEN CALL rest(active): GOTO sleep2
	IF t$ = "E" THEN uorder(active) = 0
      
	IF automatic = 1 THEN GOSUB otherside: GOTO asleep
	CALL YouorMe(active, F): IF F = 0 THEN GOSUB otherside: IF recon = 0 GOTO sleep2 ELSE GOTO asleep
'============================================================================
human:
	y0 = 14 * unity(active): x0 = 8 * unitx(active)
	IF rely = 1 OR INSTR("ANH", t$) > 0 THEN IF uorder(active) > 99 THEN uorder(active) = 0

	clrbot
	IF uorder(active) > 0 THEN CALL cupdate(active): GOTO asleep
'............................................................................
IF lineofsight = 2 THEN CALL vistarg(active, 0)
'............................................................................
	CALL inspect(active)
	ATTENTION active, 14

	IF quiet = 1 THEN
		IF sblast$ = "" THEN
			SOUND 1600, .3
		ELSE
			CALL sndblst("ready")
		END IF
	END IF
wait2:
	LITEUP x0, y0, 14
	clrbot
	GOSUB cline
'============================================================================
'                     Get Keyboard Command
'============================================================================
wait3:
	commnd$ = INKEY$: IF commnd$ = "" GOTO wait3
	IF ASC(commnd$) = 2 GOTO noboss
	a = LEN(commnd$): commnd$ = RIGHT$(commnd$, 1)
	z = ASC(UCASE$(commnd$))
SELECT CASE z
	CASE 13: CALL noise(400, 1, "bump"): GOTO Options
	CASE 27, 42: CALL noise(0, 0, ""): GOTO wait2
	CASE 32: CALL rest(active): GOTO asleep
	CASE 43: IF INSTR("AENHBL", t$) > 0 THEN dx = 1: GOTO fodder
	CASE 59  'F1
		CALL help: CALL mainmap
		CALL refresh: CALL inspect(active): GOTO wait2
	CASE 60  'F2
		GOTO Options
	CASE 61  'F3
		CALL regorders
		CALL inspect(active)
	CASE 64: IF t$ = "G" THEN dx = 5: GOTO fodder
	CASE 66: CALL scentex
	CASE 67
	  IF uorder(active) < 0 GOTO wait2
	  IF LEFTY$(active) = "I" AND morale(active) > 60 AND (terrain(active) = 43 OR terrain(active) = 46) THEN
		unit$(active) = "่"
		toa(active) = timex + 1
		CALL noise(1900, 1, "drums3")
		GOTO asleep
	  END IF
	CASE 68
		IF a = 2 AND pbm = 0 THEN CLS : file$ = "๔": EXIT SUB
	CASE 70
	IF INSTR("AENHBL", t$) > 0 THEN dx = 1: GOTO fodder
	CASE 71: IF a = 2 GOTO moven
		GOSUB ahead
	CASE 72: IF a = 2 GOTO moven
	CASE 73: IF a = 2 GOTO moven
		dx = 3: GOTO fodder
	CASE 74
		 s = 1: F = Bigg(1): IF side = 2 THEN s = m2: F = Bigg(2)
		 FOR k = s TO F
			IF strength(k) + strength(active) > 500 * (stakk - 1) AND k <> active THEN CALL Tara(unitx(k), unity(k) + 1, 0)
			a$ = LEFTY$(k)
			IF INSTR("BE", a$) > 0 THEN CALL Tara(unitx(k), unity(k) + 1, 0)
		 NEXT k
		 CALL clrbot: PRINT "Possible units to stack with "; name$(active); "   (limit="; 500 * (stakk - 1); ")";
		 TICK 9
		 CALL refresh
	CASE 75: IF a = 2 GOTO moven
	CASE 76: IF a = 2 GOTO wait2
		 IF t$ = "E" GOTO wait2
		 IF INSTR("AHNL", LEFTY$(active)) > 0 THEN CALL limbo(active, 1): GOTO asleep
	CASE 77: IF a = 2 GOTO moven
		dx = 2: GOTO fodder
	CASE 78: dx = 4: GOTO fodder
	CASE 79: IF a = 2 GOTO moven
		CALL report: CALL inspect(active): GOTO wait2
	CASE 80: IF a = 2 GOTO moven
	CASE 81: IF a = 2 GOTO moven
		quiet = 1 - quiet: CALL scrcol(12): GOTO wait3
	CASE 82
		recon = 1 - recon
		IF quiet = 1 THEN
			IF sblast$ = "" THEN
				SOUND 1200, .3
			ELSE
				CALL sndblst("combo")
			END IF
		END IF
		CALL scrcol(11): CALL refresh
		LITEUP x0, y0, 14
		GOTO wait3
	CASE 84
		GOSUB allterr
		CALL clrbot: PRINT "Terrain"; TAB(60); "(press a key)...";
		TICK 5
		CALL refresh
	CASE 86
		PCOPY 0, 1
		SCREEN 9, , 1, 1
		CALL vistarg(active, 1)
		CALL ranger(active, vantage)
		FOR k = 2 TO 21
			s = 2: IF INT(.5 * k) * 2 = k THEN s = 3
			FOR j = s TO 54 STEP 2
				unitx(0) = j: unity(0) = k - 1
				terrain(0) = ASC(MID$(sdtext$(unity(0) + 1), unitx(0)))
				d = 2 * ABS(unity(active) - unity(0)) + ABS(unitx(active) - unitx(0))
				IF d <= vantage THEN
					CALL los(active, 0, F, 0)
					IF F <> 0 THEN PUT (8 * j, 14 * (k - 1)), Xhair, XOR
				END IF
			NEXT j
		NEXT k
		CALL clrbot: PRINT "Visible Enemy Units and Terrain"; TAB(60); "(press a key)...";
		TICK 99
		SCREEN 9, , 0, 0
	CASE 83:
cartog:
		 CALL mainmap: CALL refresh: CALL inspect(active)
	CASE 87: GOSUB whoa1: GOTO asleep
	CASE 88: IF t$ = "G" THEN GOSUB cancel: IF y > 0 GOTO asleep ELSE GOTO wait2
	CASE ELSE
		IF a < 2 THEN clrbot: COLOR 11: PRINT "Cannot execute that command"; : CALL TICK(mdly!): clrbot: BuffClear
END SELECT
GOTO wait2
'============================================================================
' orders:   <0=dug in   0=none   1=blocked  99=hidden  >99=moveto destination
'============================================================================
'                     Move Unit & Check for Sighting
'============================================================================
moven:
IF uorder(active) < 0 AND leader(active) < 70 THEN dx = 2: GOTO fodder
IF t$ = "E" THEN COLOR 12: clrbot: PRINT "Emplaced Gun -- Cannot Move"; : CALL noise(400, 1, "bump"): CALL TICK(1): GOTO wait2
	IF limber = 1 AND INSTR("ANH", t$) > 0 THEN
		CALL limbo(active, 2)
		IF mtx$(0) = "@" GOTO fodder
		IF LEFTY$(active) <> "L" GOTO wait2 ELSE GOTO asleep
	END IF
	xloc = unitx(active): yloc = unity(active)
	CALL curser(commnd$, xloc, yloc)
	IF yloc = unity(active) AND xloc = unitx(active) THEN CALL noise(0, 0, ""): GOTO wait3
	IF uorder(active) < 0 THEN GOSUB earth: IF choose = 2 GOTO asleep ELSE CALL rest(active): GOTO asleep
	CALL placeunit(xloc, yloc, active)
	IF uorder(active) = 1 THEN COLOR 14: clrbot: PRINT "Cannot move in that direction "; : CALL noise(400, 1, "bump"): CALL TICK(1): uorder(active) = 0: GOTO wait2
	CALL inspect(active)
asleep:
	CALL SHOWUNIT(active)
sleep2:
	IF strength(active) > 0 AND uorder(active) <> 99 THEN CALL see(active)
snore:
	IF toa(active) <= timex THEN toa(active) = timex + 1
	IF uorder(active) = 1 THEN uorder(active) = 0
	CALL valid(active)
	IF timex = timelimit GOTO endgame
NEXT active
EXIT SUB
'============================================================================
'                               Enemy Update Logic
'============================================================================
otherside:
IF nplayer = 2 THEN
	IF queue(3 - side) = 0 THEN EXIT SUB
	c = 7: IF side = 1 THEN c = 1
	GOSUB sidechange
	LOCATE 12, 58: PRINT "("; queue(3 - side); "Possible Moves)"
	IF quiet > 0 AND sblast$ <> "" THEN CALL sndblst("drums3")
	IF sblast$ = "" OR quiet = 0 THEN
		CALL clrbot
		PCOPY 0, 1
		SCREEN 9, , 1, 1
		COLOR 15
		c = 4: IF side = 1 THEN c = 1
		LINE (88, 92)-(528, 142), c, BF
		LINE (88, 92)-(528, 142), 15, B
		LOCATE 9
		center ("press any key to switch to " + sname$(3 - side) + " side")
		DO WHILE INKEY$ = "": LOOP
		SCREEN 9, , 0, 0
	END IF
	side = 3 - side
	GOSUB aque
	CALL clrbot
	GOTO human
END IF
IF flag = 0 THEN GOSUB sidechange: IF quiet > 0 AND sblast$ <> "" THEN CALL sndblst("drums3")
COLOR 11: CALL clrbot: LOCATE 23, 50: PRINT name$(active); "'s TURN";
IF strength(active) < 1 THEN RETURN
queue(0) = queue(0) + 1
'............................................................................
a$ = LEFTY$(active)
IF a$ = "I" THEN IF morale(active) > 60 AND (terrain(active) = 43 OR terrain(active) = 46) THEN unit$(active) = "่": CALL SHOWUNIT(active): toa(active) = timex + 1: RETURN
'............................................................................
IF INSTR("AEHNBL", a$) THEN
	CALL Near2(active, Enemy, d)
	IF a$ = "B" AND Enemy > 0 AND d < .8 * seelimit THEN CALL cannon(active, Enemy): RETURN
	IF INSTR("AHN", a$) > 0 THEN
		IF Enemy > 0 THEN
			CALL los(active, Enemy, F, 0)
			IF F = 1 THEN
				IF d < .7 * seelimit THEN CALL cannon(active, Enemy): flag = 0: RETURN
				IF INSTR("ANHLB", LEFTY$(Enemy)) > 0 OR terrain(Enemy) = 233 THEN CALL cannon(active, Enemy): flag = 0: RETURN
				IF d < seelimit AND RND > .7 THEN CALL cannon(active, Enemy): flag = 0: RETURN
			ELSE
				IF d > 6 AND RND > .5 THEN CALL limbo(active, 0): RETURN
			END IF
		ELSE
			CALL limbo(active, 0): RETURN
		END IF
	END IF
	
	IF a$ = "E" THEN
		IF Enemy > 0 THEN CALL cannon(active, Enemy)
		RETURN
	END IF

	IF Enemy > 0 AND a$ = "L" THEN
		x1 = .6 * seelimit: IF x1 < 6 THEN x1 = 6
		u$ = LEFTY$(Enemy)
		IF u$ = "C" OR u$ = "่" THEN x1 = seelimit
		IF INSTR("AEHNL", u$) > 0 THEN CALL limbo(active, 0): RETURN
		CALL proximity(active, 0, 0, bonus)
		IF bonus > 4 THEN x1 = .9 * seelimit
		IF d < x1 THEN CALL limbo(active, 0): RETURN
		IF INSTR("AEHNL", u$) = 0 AND RND > .2 THEN uorder(active) = 100 * unity(Enemy) + unitx(Enemy)
	END IF
END IF
'............................................................................
IF possess = side AND uorder(active) = 100 * objy + objx THEN CALL cupdate(active): RETURN
CALL Near2(active, Enemy, d)
IF d < 4 AND a$ <> "G" THEN uorder(active) = 100 * unity(Enemy) + unitx(Enemy): CALL cupdate(active): RETURN
'............................................................................
IF a$ = "G" THEN
	CALL proximity(active, (unitx(active)), (unity(active)), plus)
	IF plus > 0 THEN CALL flee(active, index)
	IF index > 0 THEN
		uorder(active) = 100 * unity(index) + unitx(index)
	ELSE
		near = 32767: index = 0
		s = 1: F = Bigg(1): IF active > m2 THEN s = m2: F = Bigg(2)
		FOR i = s TO F
		IF strength(i) > 0 AND uorder(i) <> 99 THEN
			d = 2 * ABS(unity(active) - unity(i)) + ABS(unitx(active) - unitx(i))
			IF d < near AND i <> active THEN near = d: index = i
		END IF
		NEXT i
	IF index > 0 AND near < 7 AND RND > .8 AND LEFTY$(index) <> "G" AND toa(index) > timex THEN CALL Rally(unitx(index), unity(index), index, active, flag): IF flag > 0 THEN RETURN
	END IF
	CALL general(active)
	IF uorder(active) > 0 THEN CALL cupdate(active): RETURN
END IF
'............................................................................
d = 2 * ABS(unity(active) - objy) + ABS(unitx(active) - objx)
IF d < seelimit AND possess <> 3 - side THEN
	IF d < closest THEN
		uorder(active) = 100 * objy + objx
		closest = d
	END IF
END IF

IF uorder(active) > 0 THEN CALL cupdate(active): RETURN
x = 80: IF possess <> 3 - side THEN x = 50
IF morale(active) < x THEN CALL rest(active): RETURN
CALL general(active)
CALL valid(active)
CALL cupdate(active)
RETURN
'............................................................................
sidechange:
CALL kleer: flag = 1

CALL icon(470, 190, 3 - side)

COLOR 7: IF side = 1 THEN COLOR 9
LOCATE 13, 58: PRINT sname$(3 - side); " Turn"
RETURN
'============================================================================
'                               Stats on Unit Under Cursor
'============================================================================
stats:
CALL inspect(id)
CALL YouorMe(id, F)
IF F > 0 THEN IF uorder(id) > 99 AND dx <> 4 THEN CALL target(id): GOSUB inlin
RETURN
'============================================================================
cline:
	clrbot
	a$ = "[ " + sname$(side) + " COMMANDS ]"
	COLOR 9: IF side = 1 THEN COLOR 15
	COLOR 15: PRINT a$; : COLOR 14: PRINT " F1:Help F2:Unit Command F3:Game Options F10:Main Menu";
	RETURN
wait5:
	commnd$ = INKEY$: IF commnd$ = "" GOTO wait5
	dxs = ASC(UCASE$(commnd$)): dys = LEN(commnd$)
	SELECT CASE dxs
		CASE 13, 27, 32, 42, 76, 88: RETURN
		CASE 49 TO 57: RETURN
	END SELECT
	IF dys < 2 GOTO wait5
	commnd$ = RIGHT$(commnd$, 1)
	RETURN
'============================================================================
'                            Leave Entrenchments
'============================================================================
earth:
CALL clrbot: COLOR 15: PRINT name$(active); " is entrenched"
mtx$(0) = "Leave Trench"
CALL YesNo(a$)
CALL scrcol(1)
CALL inspect(active)
IF a$ <> "Y" THEN RETURN
uorder(active) = 100 * yloc + xloc
toa(active) = timex + 5
CALL clrbot: COLOR 14: PRINT name$(active); "'s men will leave their entrenchments on turn "; timelimit - toa(active);
TICK mdly!
RETURN
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                             Late Arrivals                          บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
canplace:
	CALL whois(unitx(active), unity(active), id, active)
	IF id > 0 THEN RETURN
	s = 1: IF active > m1 THEN s = 2
	uorder(active) = 0: t$ = ""
	CALL YouorMe(active, F): IF F > 0 THEN Visible(active) = 1: t$ = name$(active)
	clrbot
	COLOR 15: PRINT sname$(s); " "; : CALL DESCRIBE(active): PRINT " "; t$; " is joining the battle";
	CALL see(active)
	t$ = LEFTY$(active)
	IF t$ = "E" THEN RETURN
	IF limber > 0 AND INSTR("AHN", t$) > 0 THEN unit$(active) = "L" + unit$(active): t$ = LEFTY$(active)
	y = 14 * unity(active): x = 8 * unitx(active)

	IF Visible(active) > 0 THEN
		FOR k = 1 TO 2
		ATTENTION active, 15
		IF quiet THEN CALL noise(1900, 1, "drums3")
		IF sblast$ <> "" THEN EXIT FOR
		NEXT k
	END IF

	IF quiet = 0 THEN TICK .5 * mdly!

	CALL YouorMe(active, F): IF F > 0 THEN RETURN
	CALL Near2(active, Enemy, d)
	IF Enemy = 0 AND RND > .5 THEN uorder(active) = 100 * objy + objx: RETURN
	IF INSTR("ANHB", t$) THEN CALL cannon(active, Enemy): RETURN
	uorder(active) = 100 * unity(Enemy) + unitx(Enemy)
	RETURN
'============================================================================
'                               cancel orders
'============================================================================
cancel:
CALL clrbot: PRINT " General "; name$(active); " cancelling orders : ";
x = 0: y = 0: s = 1: F = Bigg(side): IF side = 2 THEN s = m2
FOR i = s TO F: IF strength(i) = 0 OR uorder(i) < 1 OR uorder(i) = 99 GOTO corpse
y = y + 1
IF RND < .01 * leader(active) THEN
	uorder(i) = 0
	dx = 8 * unitx(i): dy = 14 * unity(i)
	LINE (dx, dy)-(dx + 15, dy + 13), 13, BF
	TICK .1
	   IF quiet = 1 THEN
		  IF sblast$ = "" THEN
		       SOUND 2900, .2
		  ELSE
		       CALL sndblst("ding")
		  END IF
	   END IF
	SHOWUNIT (i)
	GOTO corpse
ELSE
x = x + 1: leader(i) = leader(i) - 3: morale(i) = morale(i) - 5
END IF
corpse:
NEXT i
IF y = 0 THEN PRINT "NO UNITS UNDER ORDERS"; : TICK .2 * mdly!: CALL clrbot: RETURN
PRINT y - x; " of "; y; " units obeyed"; : TICK .2 * mdly!
CALL clrbot
RETURN
'============================================================================
'                               Score Hot Key
'============================================================================
ahead:
	CALL expire
	CALL mainmap: CALL refresh: CALL inspect(active)
	RETURN
'============================================================================
'                               Command Menu
'============================================================================
Options:
tlx = 60: tly = 3: colour = 9
mtx$(0) = "UNIT COMMAND"
mtx$(1) = "Move to location"
mtx$(2) = "Intelligence"
mtx$(3) = "Rest"
mtx$(4) = "{not available}"
t$ = LEFTY$(active)
IF t$ = "I" THEN mtx$(4) = "Charge"
IF INSTR("ANHB", t$) > 0 THEN mtx$(4) = "Fire (Artillery)"
IF INSTR("E", t$) > 0 THEN mtx$(4) = "Fire (Artillery)": mtx$(1) = "{not available}"
size = 4
IF t$ = "G" THEN mtx$(4) = "Cancel Orders": mtx$(5) = "Inspire": size = 5

CALL menu
CALL scrcol(1)
CALL inspect(active)

SELECT CASE choose
	CASE 1
	IF t$ <> "E" THEN dx = 2: GOTO fodder
	CASE 2
	dx = 3: GOTO fodder
	CASE 3
	CALL rest(active): GOTO asleep
	CASE 4
	IF t$ = "G" THEN GOSUB cancel: GOTO asleep
	IF t$ = "I" AND morale(active) > 60 AND (terrain(active) = 43 OR terrain(active) = 46) THEN unit$(active) = "่": toa(active) = timex + 1: GOTO asleep
	IF INSTR("AENHB", t$) > 0 THEN dx = 1: GOTO fodder
	CASE 5
	dx = 4: GOTO fodder
	CASE ELSE
	GOTO wait2
END SELECT
GOTO wait2
'============================================================================
'                                  Move order
'============================================================================
here:
	COLOR 14: CALL clrbot
	IF dx = 5 THEN PRINT unit$(active); " "; name$(active); " has given orders to move to ("; xloc; ","; yloc; ") and";
	uorder(active) = 100 * yloc + xloc
	IF toa(active) <= timex THEN toa(active) = timex + 1
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	IF dx = 2 THEN CALL target(active): CALL clrbot: GOTO asleep
	IF dx = 5 THEN
		s = 1: F = Bigg(1): IF side = 2 THEN s = m2: F = Bigg(2)
		CALL ranger(active, vantage)
		dy = 0: FOR k = s TO F
			d = 2 * ABS(unity(active) - unity(k)) + ABS(unitx(active) - unitx(k))
			IF d <= .5 * vantage THEN
				IF strength(k) > 0 AND uorder(k) > -1 AND uorder(k) < 99 THEN uorder(k) = uorder(active): dy = dy + 1
			END IF
		NEXT k
		uorder(active) = 0: PRINT dy; "units obeyed";
	END IF
	IF quiet = 1 AND sblast$ = "" THEN SOUND 500, 1
	TICK mdly!
	clrbot
	GOTO asleep
'============================================================================
'           Cursor Controlled Movements  1=cannon  2=move  3=spy
'============================================================================
fodder:
SELECT CASE dx
      CASE 1  'cannon
	IF limber = 1 AND LEFTY$(active) = "L" THEN CALL limbo(active, 2): IF LEFTY$(active) = "L" GOTO wait2 ELSE GOTO asleep
	CALL ranger(active, vantage)
	CALL vistarg(active, 0)
	COLOR 11: clrbot: PRINT "CANNONADE > RANGE:"; vantage; TAB(25); "DISTANCE:"; TAB(60); "TERRAIN:";
     
      CASE 2, 5 'move
	IF rely = 1 THEN COLOR 12: CALL clrbot: PRINT "MAXIMUM RELIABILITY : Move Orders Not Allowed": TICK 2: GOTO wait2
	IF uorder(active) < 0 AND leader(active) < 70 AND RND > .1 THEN clrbot: PRINT name$(active); " refuses to move from dug-in position"; : toa(active) = toa(active) + 7: TICK mdly!: GOTO asleep
	COLOR 11: clrbot
	IF dx = 2 THEN PRINT "Hit ENTER to order unit to move to cursor position";
	IF dx = 5 THEN PRINT "GROUP MOVE ORDERS : Hit ENTER to order group to move to cursor position";
     
      CASE 3  'intelligence
	GOSUB inlin

      CASE 4  'inspire
	IF LEFTY$(active) <> "G" THEN GOTO wait2
	COLOR 11: clrbot: PRINT "INSPIRE : move cursor over friendly unit and press ENTER"; : COLOR 13: PRINT " Range ";
      CASE ELSE
END SELECT
	yloc = unity(active): xloc = unitx(active): y = yloc: x = xloc

	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
	PUT (8 * x, 14 * y), Xhair, XOR

movex:
	y = yloc: x = xloc: id = 0
	d = 2 * ABS(unity(active) - yloc) + ABS(unitx(active) - xloc)
SELECT CASE dx
      CASE 1  'cannon
	COLOR 11: LOCATE 23, 40: PRINT SPACE$(19);
	CALL whois(xloc, yloc, id, 0)
	COLOR 14: CALL ranger(active, vantage): IF d > vantage THEN COLOR 12
	LOCATE 23, 35: PRINT d; " ";
	CALL Tara(69, 23, z)

	IF d <= vantage AND id > 0 AND Visible(id) > 0 THEN
		LOCATE 23, 40: COLOR 11: PRINT name$(id);
	END IF

      CASE 2, 5  'move
      CASE 3, 4 'intelligence & inspire
	CALL whois(xloc, yloc, id, 0)
	IF id > 0 THEN
		GOSUB stats
		IF LEFTY$(id) = "w" THEN
			IF (side = 1 AND id < m2) OR (side = 2 AND id > m1) THEN unit$(id) = MID$(unit$(id), 2)
			CALL SHOWUNIT(id)
			PUT (8 * xloc, 14 * yloc), Xhair, XOR
		END IF
	END IF
	COLOR 13: LOCATE 23, 67: PRINT d;
	CASE ELSE
END SELECT
       
	GOSUB wait5
	IF ASC(commnd$) = 13 GOTO here2
	CALL curser(commnd$, xloc, yloc)

	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	PUT (8 * x, 14 * y), Xhair, XOR
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))

	SELECT CASE dxs
	CASE 27, 42
	CALL refresh: GOSUB newcurs: GOTO wait2
	CASE 32
	CALL refresh: GOSUB newcurs: CALL rest(active): GOTO asleep
	CASE 76
	IF LEFTY$(active) <> "E" THEN CALL refresh: GOSUB newcurs: CALL limbo(active, 1): GOTO asleep
	CASE 87
	GOSUB whoa1: GOTO asleep
	CASE ELSE
	END SELECT
	GOTO movex
'...........................................................................
here2:
	IF dx = 2 OR dx = 5 GOTO here
	IF dx = 3 THEN PUT (8 * xloc, 14 * yloc), Xhair, XOR: GOTO wait2
	IF dx = 4 THEN
		PUT (8 * xloc, 14 * yloc), Xhair, XOR
		CALL Rally(xloc, yloc, index, active, flag)
		IF flag = 1 GOTO asleep ELSE GOTO wait2
	END IF
	CALL whois(xloc, yloc, Enemy, active)
	IF Enemy = 0 OR Visible(Enemy) = 0 THEN PUT (8 * xloc, 14 * yloc), Xhair, XOR: CALL noise(700, 1, "bump"): CALL clrbot: PRINT "NO ENEMY AT THAT LOCATION !": TICK mdly!: CALL refresh: GOTO fodder
	CALL ranger(active, vantage)

	CALL los(active, Enemy, F, 0)
	IF Visible(Enemy) = 0 THEN Visible(Enemy) = 1
	IF F < 1 THEN
		PUT (8 * xloc, 14 * yloc), Xhair, XOR
		CALL noise(700, 1, "bump")
		CALL clrbot
		PRINT "NOT IN LINE OF SIGHT !"
		TICK mdly!
		GOTO fodder
	END IF

	IF d > vantage THEN PUT (8 * xloc, 14 * yloc), Xhair, XOR: CALL noise(700, 1, "bump"): CALL clrbot: PRINT "ENEMY IS OUT OF RANGE !": TICK mdly!: GOTO fodder

	CALL refresh
	CALL cannon(active, Enemy)
dudd:
	CALL refresh
	GOTO asleep
'============================================================================
newcurs:
	CALL whois(x, y, Enemy, active)
	IF Enemy <> 0 THEN RETURN
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	RETURN
inlin:
	COLOR 11: clrbot: PRINT "INTELLIGENCE: move cursor over enemy units"; : COLOR 15: PRINT "  (ESC when done) ";
	COLOR 11: PRINT "Range :";
	RETURN
whoa1:
	unit$(active) = "w" + unit$(active): clrbot
	PRINT name$(active); " is WAITING...";
	TICK .1 * mdly!
	CALL rest(active)
	IF uorder(active) > 0 THEN uorder(active) = 0
	RETURN
noboss:
	CLS : COLOR 7, 0: LOCATE 1, 1: PRINT "C:>";
	TICK .5
	DO: commnd$ = INKEY$: LOOP WHILE commnd$ = ""
	IF ASC(commnd$) <> 2 GOTO noboss
	GOTO cartog
'...........................................................................
allterr:
FOR k = 1 TO Bigg(2)
IF strength(k) > 0 AND uorder(k) <> 99 THEN CALL Tara(unitx(k), unity(k) + 1, 0)
NEXT k
RETURN
aque:
	LINE (453, 0)-(631, 13), 0, BF
	COLOR 14: LOCATE 1, 59: PRINT sname$(side); TAB(74); "("; queue(side); TAB(79); ")"
	LINE (453, 0)-(631, 13), 4, B
RETURN

END SUB

SUB placeunit (xloc, yloc, index)
COLOR 7: IF index > 10 THEN COLOR 9
t$ = LEFTY$(index)
IF strength(index) < 1 OR uorder(index) = 99 THEN EXIT SUB
CALL YouorMe(index, flag): IF flag > 0 AND automatic = 0 GOTO ours
IF unity(index) = objy AND unitx(index) = objx THEN uorder(index) = 0: xloc = unitx(index): yloc = unity(index): GOTO ours
IF possess <> 3 - side AND uorder(index) = 100 * objy + objx GOTO ours
IF uorder(index) > -1 AND morale(index) < 80 THEN
	IF 100 * RND > morale(index) + leader(index) THEN uorder(index) = 0: CALL rest(index): EXIT SUB
END IF
'============================================================================
'                    Enemy Checks for Proximity of Our Units
'============================================================================
	s = 1: F = Bigg(1): IF index < m2 THEN s = m2: F = Bigg(2)
	CALL Near2(index, Enemy, near)
	IF Enemy = 0 GOTO ours
	IF INSTR("ANHB", t$) = 0 GOTO notart

	IF a$ = "B" THEN
		IF (near < .4 * seelimit OR RND > .7) THEN CALL cannon(active, Enemy): EXIT SUB
	ELSE
		GOTO ours
	END IF

	CALL cannon(index, Enemy)
	EXIT SUB
notart:
	IF INSTR("GL", t$) > 0 GOTO ours

	IF uorder(index) > 0 AND RND > .1 * bold GOTO ours
	IF uorder(index) < 0 THEN EXIT SUB

	pct# = strength(index) / strength(Enemy)
	pct# = pct# * .002 * RND * leader(index) * morale(index)
	t$ = LEFTY$(Enemy)
	IF INSTR("ANHBGL", t$) > 0 THEN pct# = pct# + 1
	IF Visible(Enemy) > 0 AND near > 3 AND pct# > 1.8 - .2 * bold THEN uorder(index) = 100 * unity(Enemy) + unitx(Enemy): GOTO try2

	IF near > 3 GOTO try2
	uorder(index) = 0
	xloc = unitx(Enemy): yloc = unity(Enemy)
	IF pct# > 2 + .1 * bold GOTO fire1
	IF pct# > .5 + .1 * bold GOTO ours
       
	uorder(index) = 0: dxs = SGN(unitx(index) - unitx(Enemy)): dxy = SGN(unity(index) - unity(Enemy)): xloc = unitx(index) + 2 * dxs: yloc = unity(index) + 2 * dys
	GOTO ours
fire1:
	IF LEFTY$(Enemy) = "่" THEN unit$(Enemy) = "I"
	GOTO rumble
try2:
	IF LEFTY$(index) = "I" AND morale(index) > 60 AND (terrain(index) = 43 OR terrain(index) = 46) THEN
		unit$(index) = "่"
		toa(index) = timex + 1
		EXIT SUB
	END IF
	IF morale(index) < 70 THEN CALL rest(index)
'============================================================================
'                    Continue with Move Orders
'============================================================================
ours:
told = terrain(index)
IF xloc > 55 THEN xloc = 55: EXIT SUB
IF xloc < 2 THEN xloc = 2: EXIT SUB
IF yloc > 20 THEN yloc = 20: EXIT SUB
IF yloc < 1 THEN yloc = 1: EXIT SUB
z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
'============================================================================
'                    Check for presence of Invisible Units
'============================================================================
CALL whois(xloc, yloc, Enemy, index)
IF Enemy = 0 GOTO rechex
IF index < m2 AND Enemy < m2 GOTO special
IF index > m1 AND Enemy > m1 GOTO special
IF Enemy > 0 THEN CALL SHOWUNIT(Enemy): GOTO rumble
GOTO rechex
'============================================================================
'                            Engage if enemy is present
'============================================================================
rumble:
COLOR 14
IF side = 1 AND index > m1 THEN COLOR 15
IF side = 2 AND index < m2 THEN COLOR 14
IF LEFTY$(index) = "B" AND LEFTY$(Enemy) <> "B" THEN uorder(index) = 1: EXIT SUB
IF LEFTY$(index) <> "B" AND LEFTY$(Enemy) = "B" THEN uorder(index) = 1: EXIT SUB
'============================================================================
'                              Engage in Combat
'============================================================================
CALL YouorMe(index, F): IF F > 0 THEN CALL inspect(index)
CALL combat(index, Enemy)
IF F > 0 THEN CALL inspect(index)
CALL SHOWUNIT(index)
IF toa(index) < timex + 2 THEN toa(index) = timex + 2
'============================================================================
IF F > 0 OR difficult < 4 THEN EXIT SUB
toa(index) = toa(index) - 2
IF toa(index) <= timex THEN toa(index) = timex + 1
EXIT SUB

rechex:
IF LEFTY$(index) = "B" THEN IF z <> 176 THEN GOSUB route: IF uorder(index) > 0 THEN uorder(index) = 1: EXIT SUB
IF LEFTY$(index) <> "B" THEN IF z = 176 THEN GOSUB route: IF uorder(index) > 0 THEN uorder(index) = 1: EXIT SUB
terrain(index) = z
IF recon = 1 THEN Visible(index) = 1
IF Visible(index) > 0 THEN CALL SHOWUNIT(index)
'============================================================================
'       calculate time of action penalty from unittype
'============================================================================
	u$ = LEFTY$(index)
	SELECT CASE u$
	CASE "I"
	plus = 2
	CASE "่"
	plus = 0
	CASE "C"
	plus = 0
	CASE "A", "N"
	plus = 4 + 4 * limber
	CASE "G"
	plus = 1
	CASE "H"
	plus = 1 + 4 * limber
	CASE "B"
	plus = 0
	CASE ELSE
	plus = 1
	END SELECT
'============================================================================
'       calculate time of action penalty from terrain
'============================================================================
	dx = 2 * limber
	SELECT CASE terrain(index)
	CASE 35  'fort
	Pnlty = 2
	CASE 42, 58 'forest or plowed field
	Pnlty = 3
	IF u$ = "C" OR INSTR("ANHL", u$) > 0 THEN Pnlty = 4 + dx
	CASE 43, 91 'road or bridge
	Pnlty = 1
	CASE 46  'clear
	Pnlty = 2: IF u$ = "C" THEN Pnlty = 1
	CASE 94  'hill
	Pnlty = 4
	IF u$ = "C" OR INSTR("ANHL", u$) > 0 THEN Pnlty = 5 + dx
	CASE 61  'swamp
	Pnlty = 6
	IF INSTR("ANHL", u$) > 0 THEN Pnlty = 8 + dx
	IF u$ = "C" THEN Pnlty = 6
	CASE 176 'water
	Pnlty = 0
	CASE 233 'objective
	Pnlty = 2
	CASE 239 'mountain
	Pnlty = 6
	IF INSTR("AN", u$) > 0 THEN Pnlty = 8 + dx
	IF u$ = "H" THEN Pnlty = 4 + dx
	IF u$ = "C" THEN Pnlty = 6
	CASE 254 'village
	Pnlty = 2
	IF u$ = "I" OR u$ = "G" THEN Pnlty = 1
	CASE ELSE
	Pnlty = 2
	END SELECT
'============================================================================
'           modify time of action penalty based on unit morale & leader
'============================================================================
	IF morale(index) < 60 THEN Pnlty = Pnlty + 1
	IF leader(index) < 70 THEN Pnlty = Pnlty + 1: IF leader(index) < 50 THEN Pnlty = Pnlty + 1
'============================================================================
'                        Update Time of Action
'============================================================================
	toa(index) = timex + Pnlty + plus
	CALL YouorMe(active, F)
	IF F = 0 THEN
		IF toa(index) > timex + 1 AND difficult > 3 THEN
			IF RND < .05 * (difficult - 3) THEN toa(active) = timex + 1
		END IF
	END IF
	IF LEFTY$(index) = "่" AND (RND > .97 OR (terrain(index) <> 43 AND terrain(index) <> 46)) THEN unit$(index) = "Infantry": toa(index) = timex + 2 + 3 * RND

IF unitx(index) = xloc AND unity(index) = yloc THEN EXIT SUB

IF strength(index) > 0 THEN CALL Tara(unitx(index), unity(index) + 1, 0)
unitx(index) = xloc: unity(index) = yloc
CALL SHOWUNIT(index)
IF terrain(index) = 233 THEN CALL victory(index)
EXIT SUB
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                    Check Alternate Routes If Blocked               บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
route:
CALL YouorMe(index, F): IF F > 0 THEN uorder(index) = 1: RETURN
a$ = "GIKMOQ": IF RND > .5 THEN a$ = "QOMKIG"
dx = 2 * ABS(unity(index) - objy) + ABS(unitx(index) - objx)
FOR k = 1 TO 6
xnew = unitx(index): ynew = unity(index)
CALL curser(MID$(a$, k, 1), xnew, ynew)
dy = 2 * ABS(ynew - objy) + ABS(xnew - objx) - 1
IF dy <= dx THEN
 GOSUB newroute: IF blox = 0 THEN xloc = xnew: yloc = ynew: uorder(index) = 0: RETURN
END IF

NEXT k
xloc = unitx(index): yloc = unity(index): uorder(index) = 1
RETURN

newroute:
blox = 0
CALL whois(xnew, ynew, Enemy, index): IF Enemy > 0 THEN blox = 1: RETURN
z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
IF LEFTY$(index) = "B" THEN
	IF z <> 176 THEN blox = 1: RETURN
ELSE
	IF z = 176 THEN blox = 1: RETURN
END IF
RETURN
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                    Special Cleanup -Contacted Units                บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
special:
GOSUB route
	IF uorder(index) = 0 THEN
		z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
		CALL whois(xloc, yloc, Enemy, index)
		IF Enemy = 0 GOTO rechex
	END IF
uorder(index) = 1
IF quiet = 1 THEN
	CALL YouorMe(index, F)
	IF F > 0 THEN
		IF sblast$ = "" THEN
			SOUND 200, 1
		ELSE
			CALL sndblst("bump")
		END IF
	END IF
END IF
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                            Combine Units                           บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
CALL whois(xloc, yloc, Enemy, index)
IF Enemy = 0 THEN EXIT SUB
CALL YouorMe(Enemy, F)
t$ = LEFTY$(Enemy)
IF t$ = "w" THEN unit$(Enemy) = MID$(unit$(Enemy), 2): CALL SHOWUNIT(Enemy): t$ = LEFTY$(Enemy)
IF strength(index) + strength(Enemy) > 500 * (stakk - 1) THEN
	IF F > 0 THEN
		uorder(index) = 1
		EXIT SUB
		ELSE
		EXIT SUB
	END IF
END IF
'...........................................................................
IF t$ = "L" THEN unit$(Enemy) = MID$(unit$(Enemy), 2): CALL SHOWUNIT(Enemy)
a$ = LEFTY$(index)
IF t$ = "E" OR a$ = "B" OR t$ = "B" THEN uorder(index) = 0: CALL clrbot: PRINT "Illegal unit type to stack"; : TICK (.3 * mdly!): EXIT SUB
IF (F = 0 OR automatic = 1) AND (a$ <> t$) THEN EXIT SUB

IF F > 0 THEN
	LITEUP 8 * unitx(Enemy), 14 * unity(Enemy), 11
	LITEUP 8 * unitx(index), 14 * unity(index), 14
END IF

IF uorder(index) > 1 THEN EXIT SUB
uorder(index) = 0
IF quiet = 1 THEN
	IF sblast$ = "" THEN
		SOUND 300, .3
	ELSE
		CALL sndblst("bump")
	END IF
END IF
CALL kleer
COLOR 14: LOCATE 12, 58: PRINT "Unit "; index;
LOCATE 13, 58: PRINT name$(index)
LOCATE 14, 58: CALL DESCRIBE(index)
COLOR 15: LOCATE 15, 63: PRINT ""
COLOR 11: LOCATE 16, 58: PRINT "Unit "; Enemy;
LOCATE 17, 58: PRINT name$(Enemy)
LOCATE 18, 58: CALL DESCRIBE(Enemy)
IF (F = 0 OR automatic = 1) GOTO cluster

mtx$(0) = "Stack Units"
CALL YesNo(u$)
CALL scrcol(1)
IF u$ <> "Y" THEN CALL SHOWUNIT(Enemy): EXIT SUB
'...........................................................................
cluster:
IF automatic = 0 AND Visible(index) > 0 THEN clrbot: COLOR 11: PRINT name$(index); " stacking with "; name$(Enemy);
IF quiet = 1 THEN
	IF sblast$ = "" THEN
		SOUND 3000, 2
	ELSE
		CALL sndblst("combo")
	END IF
END IF
x = index
IF t$ = "G" AND a$ <> "G" THEN x = Enemy: GOTO how2
IF strength(Enemy) > strength(index) THEN x = Enemy
how2:
R! = strength(index) / (strength(index) + strength(Enemy))
morale(index) = R! * morale(index) + (1 - R!) * morale(Enemy)
leader(index) = R! * leader(index) + (1 - R!) * leader(Enemy)
toa(index) = timex + 10: IF leader(index) > 90 THEN toa(index) = timex + 5
strength(index) = strength(index) + strength(Enemy)
CALL Tara(unitx(index), unity(index) + 1, 0)
unitx(index) = unitx(Enemy): unity(index) = unity(Enemy)
terrain(index) = terrain(Enemy): name$(index) = name$(x)
IF t$ = a$ AND morale(x) < 100 THEN morale(index) = morale(index) + 10: GOTO alike
IF a$ = t$ GOTO alike
IF INSTR("ANHL", a$) > 0 AND INSTR("ANHL", t$) > 0 THEN unit$(index) = "N": GOTO alike
IF a$ = "G" OR t$ = "G" THEN unit$(index) = "G": GOTO alike
unit$(index) = "I": IF leader(index) < 80 THEN morale(index) = morale(index) - 5

alike:
strength(Enemy) = 0: leader(Enemy) = 0: unit$(Enemy) = "": toa(Enemy) = 0
IF automatic = 1 THEN EXIT SUB
IF F = 0 AND Visible(index) > 0 THEN FOR k = 1 TO mdly!: ATTENTION index, 13: NEXT k: TICK mdly!: EXIT SUB
IF Visible(index) > 0 THEN COLOR 14: ATTENTION index, 14
CALL YouorMe(index, F)
CALL clrbot
IF F = 1 THEN
PRINT "STACKED UNIT is "; unit$(index); index; " named "; name$(index); " Strength:"; strength(index);
ELSE
PRINT sname$(3 - side); " units are stacking";
END IF
TICK mdly!
END SUB

SUB refresh
	FOR k = 1 TO Bigg(2)
	IF uorder(k) = 99 GOTO leave1
	IF recon = 1 GOTO showit
	CALL YouorMe(k, F): IF F > 0 THEN Visible(k) = 1: GOTO showit
	IF Visible(k) > 0 GOTO showit
	IF strength(k) > 0 THEN CALL Tara(unitx(k), unity(k) + 1, 0)
	GOTO leave1
showit:
	IF strength(k) > 0 THEN CALL SHOWUNIT(k)
leave1: NEXT k
END SUB

SUB SHOWUNIT (index)
		IF recon = 0 AND Visible(index) = 0 THEN EXIT SUB
		IF strength(index) < 1 AND unit$(index) <> "X" THEN EXIT SUB

		IF uorder(index) = 99 THEN EXIT SUB
		IF LEN(unit$(index)) < 1 THEN EXIT SUB

		y = 14 * unity(index): x = 8 * unitx(index)
		a = ASC(LEFTY$(index))
	       
		SELECT CASE a
		CASE 65   'Artillery
		IF index > 40 THEN PUT (x, y), Aunion, PSET ELSE PUT (x, y), Areb, PSET
		CIRCLE (x + 6, y + 6), 3, 0
		CIRCLE (x + 6, y + 6), 4, 0
		CASE 66   'Boat
		PUT (x, y), Boat, PSET
		c = 12: IF index > 40 THEN c = 11
		LINE (x, y)-(x + 15, y + 13), c, B
		CASE 67   'Cavalry
		IF index > 40 THEN PUT (x, y), Cunion, PSET ELSE PUT (x, y), Creb, PSET
		CASE 69   'Emplacement (Gun)
		IF index > 40 THEN PUT (x, y), EGunion, PSET ELSE PUT (x, y), EGreb, PSET
		CASE 71   'General
		IF index > 40 THEN PUT (x, y), Gunion, PSET ELSE PUT (x, y), Greb, PSET
		CASE 72   'Horse Artillery
		IF index > 40 THEN PUT (x, y), HAunion, PSET ELSE PUT (x, y), HAreb, PSET
		CASE 73   'Infantry
		IF index > 40 THEN PUT (x, y), Iunion, PSET ELSE PUT (x, y), Ireb, PSET
		CASE 76 'Limbered Artillery
		IF index > 40 THEN PUT (x, y), LAunion, PSET ELSE PUT (x, y), LAreb, PSET
		CASE 78   'Napoleon Artillery
		IF index > 40 THEN PUT (x, y), Aunion, PSET ELSE PUT (x, y), Areb, PSET
		CASE 88   'Death
		PUT (x, y), Death, PSET: unit$(index) = "DEAD"
		CASE 119  'wait
		IF index < m2 THEN
			LINE (x, y)-(x + 15, y + 13), 4, BF
			LINE (x, y)-(x + 15, y + 13), 7, B
		ELSE
			LINE (x, y)-(x + 15, y + 13), 9, BF
			LINE (x, y)-(x + 15, y + 13), 1, B
			IF uorder(index) > 0 THEN uorder(index) = 0
		END IF
		CASE 232   'Charge Infantry
		IF index > m1 THEN
			PUT (x, y), Iunion, PSET: c = 15
		ELSE
			PUT (x, y), Ireb, PSET: c = 4
		END IF
		CIRCLE (x + 6, y + 6), 4, c
		CASE 238
		PUT (x, y), Death
		CASE ELSE
		END SELECT
IF (side = 1 AND index > m1) OR (side = 2 AND index < m2) THEN EXIT SUB
IF LEFTY$(index) = "B" THEN EXIT SUB
c = 7: IF side = 2 THEN c = 1
IF uorder(index) > 0 AND LEFTY$(index) <> "w" THEN LINE (x, y)-(x + 12, y + 12), c, B
IF uorder(index) < 0 THEN LINE (x, y + 9)-(x + 12, y + 12), 6, BF
END SUB

SUB Tara (x, y, a)
IF a = 0 THEN t$ = MID$(sdtext$(y), x, 1): a = ASC(t$)
z = 8 * x: c = 14 * (y - 1)
	SELECT CASE a
	CASE 35
	PUT (z, c), Fterr, PSET
	CASE 42
	PUT (z, c), Tterr, PSET
	CASE 43
	PUT (z, c), Rterr, PSET
	CASE 46
	PUT (z, c), Cterr, PSET
	CASE 58
	PUT (z, c), Pfield, PSET
	CASE 61
	PUT (z, c), Sterr, PSET
	CASE 76
	IF x > 3 THEN
		t$ = MID$(sdtext$(y), x - 2, 1): a = ASC(t$)
		IF a <> 176 THEN CALL Tara(x, y, a)
	ELSE
		IF y > 2 THEN
			t$ = MID$(sdtext$(y - 2), x, 1): a = ASC(t$)
			IF a <> 176 THEN CALL Tara(x, y, a)
		ELSE
			PUT (z, c), Cterr, PSET
		END IF
	END IF
	CASE 91
	PUT (z, c), Bridge, PSET
	CASE 94
	PUT (z, c), Hterr, PSET
	CASE 176
	PUT (z, c), Wterr, PSET
	CASE 233
	PUT (z, c), Oterr, PSET
	IF possess = 1 THEN PAINT (z + 4, c + 4), 7, 15
	IF possess = 2 THEN PAINT (z + 4, c + 4), 9, 15
	CASE 239
	PUT (z, c), Mterr, PSET
	CASE 254
	PUT (z, c), Vterr, PSET
	CASE ELSE
	END SELECT
dirt:
END SUB

SUB target (index)
PCOPY 0, 1
SCREEN 9, , 1, 1
y = INT(uorder(index) / 100): x = uorder(index) - 100 * y
clrbot
COLOR 11: PRINT name$(index); " is moving to location at "; x; ","; y;
LINE (8 * unitx(index) + 8, 14 * unity(index) + 6)-(8 * x + 8, 14 * y + 6), 15
CIRCLE (8 * x + 8, 14 * y + 6), 3, 15
TICK .5 * mdly!
IF quiet AND sblast$ = "" THEN SOUND 3000, .2
SCREEN 9, , 0, 0
END SUB

SUB vistarg (active, flag)
CALL ranger(active, vantage)
s = 1: a = Bigg(1): IF side = 1 THEN s = m2: a = Bigg(2): c = 0
FOR k = s TO a
	IF Visible(k) > 0 THEN
		d = 2 * ABS(unity(active) - unity(k)) + ABS(unitx(active) - unitx(k))
		IF d > vantage THEN
			c = 1
			ELSE
			c = 0: F = 0
			IF lineofsight > 0 THEN CALL los(active, k, F, 0)
			IF flag > 0 AND F > 0 THEN PUT (8 * unitx(k), 14 * unity(k)), Xhair, XOR
		END IF
		IF F < 1 OR c > 0 THEN
			CALL Tara(unitx(k), unity(k) + 1, terrain(k))
		END IF
	END IF
NEXT k
END SUB

