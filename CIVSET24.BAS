DEFINT A-Z
DECLARE SUB BuffClear ()
DECLARE SUB menu ()
DECLARE SUB attribute (choose%, index%)
DECLARE SUB autoname (index%, who$)
DECLARE SUB clrlin (x%)
DECLARE SUB DESCRIBE (k%)
DECLARE SUB drawmap ()
DECLARE SUB helpme ()
DECLARE SUB namer (file$, a$)
DECLARE SUB placearmy ()
DECLARE SUB randarm (allarm%, x%)
DECLARE SUB randmap ()
DECLARE SUB repair ()
DECLARE SUB replace (yloc%, xloc%, z%)
DECLARE SUB runto (z%)
DECLARE SUB scoreboard (flag%)
DECLARE SUB startmap ()
DECLARE SUB terrane (r!, z%)
DECLARE SUB title ()
REM $INCLUDE: 'civ20.bi'
DIM SHARED killed(2), score(2), repeat
DIM SHARED Image(1 TO 1564), Iunion(60), Cunion(60), Aunion(60), Gunion(60)
DIM SHARED Ireb(60), Creb(60), Areb(60), Greb(60)
DIM SHARED Cterr(60), Hterr(60), Sterr(60), Fterr(60)
DIM SHARED Tterr(60), Mterr(60), Oterr(60), Rterr(60)
DIM SHARED Wterr(60), Vterr(60), bridge(60), Xhair(60)
DIM SHARED Explo(60), Death(60), Boat(60), Pfield(60), tldr(15)
'============================================================================
'                       CIVILSET    v2.4 - EGA VERSION
'============================================================================
OPEN "I", 1, "prefer.cfg"
	FOR k = 1 TO 5
		INPUT #1, quiet
	NEXT k
CLOSE #1
'...........................................................................
timelimit = 100: RANDOMIZE TIMER
CLS
CALL title
SCREEN 9
CALL iconload
GOTO menu8
menu7:
SCREEN 0
COLOR 7, 0: CLS
menu8:
SCREEN 0
IF quiet > 0 THEN SOUND 2900, 1: SOUND 3000, 1
IF flag = 0 THEN choose = 23
IF flag = 1 THEN choose = 25
IF flag = 2 THEN choose = 26
IF flag = 3 THEN choose = 27
tly = 6: tlx = 27
mtx$(0) = "Options"
mtx$(1) = "Initial Scenario"
mtx$(2) = "Load Scenario"
mtx$(3) = "Save Scenario"
mtx$(4) = "MAP Edit"
mtx$(5) = "ARMY Edit"
mtx$(6) = "Description"
mtx$(7) = "Briefing"
mtx$(8) = "[ convert old format ]"
mtx$(9) = "Directory " + CURDIR$
mtx$(10) = "Random Scenario"
mtx$(11) = "CIVILWAR 2.4 Game"
mtx$(12) = "Quit"
size = 12
wtype = 2: colour = 3: hilite = 14
CALL menu

SELECT CASE choose
	CASE -1
	GOTO menu7
	CASE 1
	CALL startmap
	COLOR 11, 1: CLS : LOCATE 12, 30: PRINT "Base scenario is loaded";
	IF quiet > 0 THEN SOUND 2999, .5
	FOR k = 1 TO most: strength(k) = 0: NEXT k
	scenario$ = "BASE SCENARIO"
	flag = 1: TICK 1
	CASE 2 '                 Look for "*.civ" files and List Them
	ON ERROR GOTO caterr
	CALL menufile(file$)
	ON ERROR GOTO 0
	IF file$ = "" GOTO menu8
	ON ERROR GOTO filerr
	OPEN "I", 1, file$
	ON ERROR GOTO 0
	LINE INPUT #1, scenario$
	INPUT #1, timelimit, possess, vp&(1), vp&(2), score(1), score(2)

	FOR k = 1 TO 24
	INPUT #1, sdtext$(k)
	  IF LEN(sdtext$(k)) < 55 GOTO short
		a$ = MID$(sdtext$(k), 55, 1)
			t1$ = MID$(sdtext$(k), 56, 1)
			IF t1$ = " " THEN
				IF k < 22 THEN t1$ = "�"
			ELSE
				IF t1$ = "�" THEN t1$ = "�"
				IF k = 1 THEN t1$ = "�"
				IF k = 22 THEN t1$ = "�"
			END IF
			t2$ = MID$(sdtext$(k), 57, 1)
			l = LEN(sdtext$(k)) - 56: IF l > 0 THEN sdtext$(k) = LEFT$(sdtext$(k), 54) + t1$ + t2$ + MID$(sdtext$(k), 57, l)
short:
	NEXT k
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
	COLOR 5, 3: PRINT "۰";

	FOR k = 1 TO most: a = k MOD 2: IF a = 1 THEN PRINT "�";
	INPUT #1, a, name$(k), unit$(k), morale(k), leader(k), strength(k), unitx(k), unity(k), terrain(k), toa(k), uorder(k)
	      IF strength(k) > 0 THEN
		terrain(k) = ASC(MID$(sdtext$(unity(k) + 1), unitx(k)))
		IF INT(yloc / 2) * 2 = yloc THEN IF INT(xloc / 2) * 2 <> xloc THEN xloc = xloc + 1
		IF INT(yloc / 2) * 2 <> yloc THEN IF INT(xloc / 2) * 2 = xloc THEN xloc = xloc + 1
		IF unitx(k) < 1 THEN unitx(k) = unitx(k) + 2
		IF unitx(k) > 54 THEN unitx(k) = unitx(k) - 2
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
	IF INSTR("ABCEGHI�NL", t$) = 0 THEN LOCATE 20, 1: PRINT "WARNING : UNIT"; k; unit$(k); " TYPE is UNKNOWN - CHECK FILE": BEEP: TICK 9
	unit$(k) = u$ + t$
	      ELSE
	      END IF
	NEXT k

	FOR k = 1 TO 22: stex$(k) = "": NEXT k
	ON ERROR GOTO filend
	FOR k = 1 TO 22
	LINE INPUT #1, stex$(k)
	NEXT k
filend:
	RESUME tidy1
tidy1:
	ON ERROR GOTO 0
	CLOSE #1
	COLOR 1, 3: LOCATE 23, 1: PRINT SPACE$(80): LOCATE 23, 1: PRINT file$; " file loaded"
	TICK 2
	flag = 1: ON ERROR GOTO 0
	GOTO menu7
	CASE 3 '                            Save File
	IF flag = 0 THEN GOSUB dork: GOTO menu7
	IF scenario$ = "" THEN GOSUB battle
	CLS
	GOSUB fname: IF t$ = "" GOTO menu7
	LOCATE 22, 1: COLOR 14, 0: PRINT "SAVING "; file$
	OPEN "O", 1, file$
	PRINT #1, scenario$: PRINT "�";
	WRITE #1, timelimit, possess, vp&(1), vp&(2), killed(1), killed(2)

	IF altobj$ <> "" THEN
		a$ = RIGHT$(altobj$, 1)
		sdtext$(24) = LTRIM$(RTRIM$(STR$(alt(1)))) + "/" + LTRIM$(RTRIM$(STR$(alt(2)))) + "/" + LTRIM$(RTRIM$(STR$(alt(3)))) + "/" + a$
	END IF
	FOR k = 1 TO 24
	WRITE #1, sdtext$(k): IF k MOD 10 = 0 THEN PRINT "�";
	NEXT k
	FOR k = 1 TO most
	WRITE #1, k, name$(k), unit$(k), morale(k), leader(k), strength(k), unitx(k), unity(k), terrain(k), toa(k), uorder(k)
	IF INT(.5 * k) * 2 = k THEN PRINT "�";
	NEXT k

	FOR k = 1 TO 22
	PRINT #1, stex$(k)
	NEXT k: PRINT " Done ";

	CLOSE #1
	COLOR 15, 0: PRINT "Successful Update"
	TICK 9: GOTO menu7
	CASE 4 '                            Map Edit
	SCREEN 9, , 0, 0
	IF flag = 0 THEN GOSUB dork: GOTO menu7
	CALL drawmap
	CLS
	flag = 1
	CASE 5 '                            Army Edit
	IF flag = 0 THEN GOSUB dork: GOTO menu7
	CALL placearmy
	CLS
	flag = 2
	CASE 6 '                           Scenario Description
	GOSUB battle: GOTO menu7
battle:
	CLS
	COLOR 4, 3: LOCATE 22, 2: PRINT SPACE$(79)
	LOCATE 22, 24: PRINT "["; scenario$; "]"
	CALL clrlin(23): COLOR 11, 1: PRINT "Scenario description  >";
	s$ = scenario$
	CALL Enput(s$, 25, 23, 75, "")
	IF s$ <> "" AND ASC(s$) = 27 THEN s$ = ""
	IF s$ = "" AND scenario$ = "" GOTO battle
	IF s$ <> "" THEN scenario$ = s$
	COLOR 11, 1: LOCATE 22, 1: PRINT SPACE$(80)
newtime:
	COLOR 4, 3: LOCATE 22, 1: PRINT SPACE$(80)
	LOCATE 22, 28: PRINT "["; timelimit; "]"
	a$ = LTRIM$(RTRIM$(STR$(timelimit)))
	COLOR 11, 1: LOCATE 23, 1: PRINT SPACE$(80);
	LOCATE 23, 1: PRINT "What is time limit (turns)";
	CALL Enput(a$, 29, 23, 34, "")
	IF a$ <> "" AND ASC(a$) = 27 THEN a$ = ""
	IF a$ <> "" THEN x = VAL(a$)
	IF x > 0 THEN timelimit = x ELSE IF timelimit = 0 THEN CALL clrlin(23): COLOR 15: PRINT "Time Limit Must Be More Than ZERO"; : TICK 2: GOTO newtime
	CLS : GOTO menu7
	CASE 7 '                            Briefing
	COLOR 0, 3: CLS
	LOCATE 1, 1: PRINT "Briefing for "; : COLOR 4, 3: PRINT scenario$
	LOCATE 24, 30: PRINT "esc to QUIT";
	COLOR 11, 1
	FOR k = 1 TO 22
	CALL Enput(stex$(k), 1, k + 1, 66, "")
	IF LEN(stex$(k)) > 0 THEN IF ASC(stex$(k)) = 27 THEN stex$(k) = "": GOTO menu7
	NEXT k
	GOTO menu7
	CASE 8 '                            Convert Old Format
	IF LEN(DIR$("*.civ")) = 0 GOTO menu7
	COLOR 7, 0: CLS : LOCATE 2, 1
	FILES "*.civ"
	t$ = ""
	LOCATE 1, 1: COLOR 11, 1: PRINT SPACE$(80)
	LOCATE 1, 1: PRINT "Older Format File To Load >";
	CALL Enput(t$, 27, 1, 39, "")
	IF t$ <> "" AND ASC(t$) = 27 THEN t$ = ""
	IF t$ = "" GOTO menu7
	x = INSTR(t$, ".")
	IF x > 0 THEN t$ = LEFT$(t$, x - 1)
	t$ = t$ + ".civ"
	IF LEN(DIR$(t$)) = 0 THEN COLOR 14, 4: LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 1: PRINT "FILE NOT FOUND - "; t$: CALL TICK(9): GOTO menu7

	OPEN "I", 1, t$
	a$ = ""
	IF LOF(1) < 4000 THEN a$ = "version 1.1 - 1.3"
	CLOSE #1
	IF a$ = "" THEN
		COLOR 14, 4: LOCATE 1, 1
		PRINT SPACE$(80)
		LOCATE 1, 1: PRINT "CANNOT CONVERT FILE "; t$;
		TICK (9)
		GOTO menu7
	END IF
	file$ = t$: COLOR 11, 0: LOCATE 1, 1, 0

	CALL clrlin(1): COLOR 11, 0: PRINT "Loading OLD FORMAT file -"; a$; "- "; file$;
	INPUT #1, scenario$: PRINT "+";
	INPUT #1, timelimit, possess, vp&(1), vp&(2), killed(1), killed(2)
	FOR k = 1 TO 24
	INPUT #1, sdtext$(k)
	NEXT k: PRINT "+";
	FOR k = 1 TO 20
	INPUT #1, a, name$(k), unit$(k), morale(k), leader(k), strength(k), unitx(k), unity(k), terrain(k), toa(k), uorder(k): PRINT "+";
	NEXT k
	FOR k = 41 TO 60
	INPUT #1, a, name$(k), unit$(k), morale(k), leader(k), strength(k), unitx(k), unity(k), terrain(k), toa(k), uorder(k): PRINT "+";
	NEXT k
	CLOSE #1
	FOR k = 21 TO 40: name$(k) = "": strength(k) = 0: unitx(k) = 0: unity(k) = 0: uorder(k) = 0: NEXT k
	FOR k = 61 TO 80: name$(k) = "": strength(k) = 0: unitx(k) = 0: unity(k) = 0: uorder(k) = 0: NEXT k
	ON ERROR GOTO 0
	CALL clrlin(23): COLOR 3, 4: PRINT "OLD FORMAT FILE "; file$; " LOADED"
	flag = 1
	CASE 9 '                            Change Directory
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
	GOTO menu7
	CASE 10 '                            Random Scenario
	CLS : PRINT
	COLOR 4, 3: PRINT " Random Scenario Generator "
	COLOR 11, 0
		choose = 24
		mtx$(0) = "Battle Size"
		mtx$(1) = "Minor"
		mtx$(2) = "Small"
		mtx$(3) = "Moderate"
		mtx$(4) = "Large"
		mtx$(5) = "Epic"
		size = 5: colour = 11: CALL menu: CLS
		IF choose < 1 GOTO menu7
		allarm = 8 * choose
		timelimit = 25 + 25 * choose

		CALL namer("pnames1.dat", a$)
		scenario$ = a$
		CALL namer("pnames2.dat", a$)
		scenario$ = scenario$ + " " + a$
		CALL namer("months.dat", a$)
		scenario$ = scenario$ + " " + a$
		a = 1861 + 3 * RND: scenario$ = scenario$ + STR$(a)
mapp:
		CALL randmap
		colour = 4
		mtx$(0) = "Options"
		mtx$(1) = "Map OK"
		mtx$(2) = "Try Again"
		tlx = 59: size = 2: CALL menu
		IF choose < 0 OR choose = 2 GOTO mapp
		choose = 24
		mtx$(0) = "Balance"
		mtx$(1) = "Union  ++"
		mtx$(2) = "Union  +"
		mtx$(3) = "Equal"
		mtx$(4) = "Rebel +"
		mtx$(5) = "Rebel ++"
		size = 5: colour = 7: tlx = 59: CALL menu
		IF choose < 1 GOTO menu7

		CALL randarm(allarm, choose)
		flag = 1: choose = 23
		file$ = "random.civ"
	CASE 11 '                            Run Game
		GOSUB yorn
		IF choose <> 2 THEN GOTO menu7
		RUN "CW.EXE"
	CASE 12 '                            Quit Editor
		GOSUB yorn
		IF choose <> 2 THEN GOTO menu7
		CLS : END
	CASE ELSE
END SELECT
	GOTO menu7
'............................................................................
yorn:
	CLS
		mtx$(0) = "QUIT THE EDITOR ?"
		mtx$(1) = "NO"
		mtx$(2) = "Yes"
		size = 2
		CALL menu
		RETURN
'============================================================================
'                            File Name
'============================================================================
fname:
	COLOR 7, 0: CLS : LOCATE 3, 1: PRINT "CURRENT FILES"
	IF LEN(DIR$("*.civ")) > 0 THEN FILES "*.civ"
	tlx = 13
	brx = 54
	LOCATE 1, 1: COLOR 11, 1: PRINT SPACE$(80)
	t$ = file$
	COLOR 11, 5: LOCATE 2, 1: PRINT SPACE$(80)
	LOCATE 2, 1: PRINT "Description :"; scenario$
	COLOR 11, 1: LOCATE 1, 1: PRINT "File Name >";
	CALL Enput(t$, 14, 1, 25, "")
	IF t$ <> "" AND ASC(t$) = 27 THEN RETURN
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
	IF INSTR(file$, ".civ") = 0 THEN file$ = file$ + ".civ"
RETURN

dork:
CALL clrlin(23): COLOR 0, 4: PRINT " NO MAP IN MEMORY "; : BEEP
RETURN
'============================================================================
'                            ERROR ROUTINES
'============================================================================
filerr:
	PRINT : COLOR 15, 4: PRINT "ERROR :"; ERR: IF ERR = 53 THEN PRINT file$; " Not On This Drive": END
	IF ERR = 62 THEN PRINT "Read Beyond End of "; file$; : END
	PRINT "Data Input Error - Scenario "; file$; " File": END
cater3:
	COLOR 15, 4: PRINT "FILE ERROR : Check files UNION.LDR and REBEL.LDR": END
caterr:
	PRINT : COLOR 15, 4: PRINT "ERROR :"; ERR: IF ERR = 53 THEN PRINT "NO *.civ FILES On This Drive"
	END

SUB attribute (choose, index)
IF choose = 1 THEN t$ = "Strength"
IF choose = 2 THEN t$ = "Morale"
IF choose = 3 THEN t$ = "Leader"
CALL clrlin(23): COLOR 11: PRINT "  = increase "; t$; "    = decrease "; t$; "   ENTER = accept";

plus:
COLOR 11: LOCATE 2, 58: PRINT SPACE$(21): LOCATE 2, 60: PRINT t$;

IF choose = 1 THEN PRINT strength(index)
IF choose = 2 THEN PRINT morale(index)
IF choose = 3 THEN PRINT leader(index)
pluskey: a$ = INKEY$: IF a$ = "" GOTO pluskey
a$ = RIGHT$(a$, 1)
IF quiet > 0 THEN SOUND 4000, .7
IF ASC(a$) = 27 XOR ASC(a$) = 13 GOTO done4
mult = 0
SELECT CASE a$
CASE "+", "H": mult = 10
CASE "-", "P": mult = -10
CASE "G": mult = 3000
CASE "K": mult = -1
CASE "M": mult = 1
CASE "I": mult = 100
CASE "O": mult = -3000
CASE "Q": mult = -100
CASE ELSE
END SELECT
SELECT CASE choose
	CASE 1: strength(index) = strength(index) + mult
	CASE 2: morale(index) = morale(index) + mult
	CASE 3: leader(index) = leader(index) + mult
END SELECT
IF strength(index) > 500 AND INSTR("H", unit$(index)) > 0 THEN strength(index) = 500
IF strength(index) > 1000 AND INSTR("AN", unit$(index)) > 0 THEN strength(index) = 1000
IF strength(index) > 2000 AND INSTR("C", unit$(index)) > 0 THEN strength(index) = 2000
IF strength(index) > 3000 THEN strength(index) = 3000
IF strength(index) < 10 THEN strength(index) = 10
IF morale(index) > 110 THEN morale(index) = 110
IF morale(index) < 10 THEN morale(index) = 10
IF leader(index) > 110 THEN leader(index) = 110
IF leader(index) < 10 THEN leader(index) = 10
GOTO plus

done4:
LOCATE 2, 58: PRINT SPACE$(21);
IF quiet > 0 THEN SOUND 3200, 1
CALL clrlin(23)
END SUB

SUB autoname (index, who$)
a$ = "Rebel.ldr": IF LEFT$(who$, 1) = "U" THEN a$ = "Union.ldr"
name$(index) = ""
IF LEN(DIR$(a$)) = 0 THEN who$ = "": EXIT SUB
OPEN "I", 1, a$
FOR k = 1 TO 15: INPUT #1, mtx$(k), tldr(k): NEXT k
mtx$(0) = who$
size = 15: tlx = 58: tly = 3: colour = 3: hilite = 14
CALL menu
CLOSE #1

ON ERROR GOTO 0
CALL repair
CALL scoreboard(0)

IF choose > 0 THEN name$(index) = LTRIM$(RTRIM$(mtx$(choose))): leader(index) = tldr(choose): morale(index) = tldr(choose)
END SUB

DEFSNG A-Z
SUB BuffClear
DEF SEG = 0
POKE 1050, 30: POKE 1052, 30
END SUB

DEFINT A-Z
SUB BUTTON (x, y, c, a$, z)
xc = 8 * (x - 1) - 4: yc = 14 * (y - 1) - 2
LINE (xc, yc)-(xc + 16, yc + 18), c, B
COLOR c: LOCATE y, x: PRINT a$
PAINT (xc + 4, yc + 2), 7, c
dx = 15: dy = 0: IF z > 0 THEN dx = 0: dy = 15
FOR k = 0 TO 2
LINE (xc - k, yc - k)-(xc + 16 + k, yc - k), dx
LINE (xc - k, yc - k)-(xc - k, yc + k + 18), dx
LINE (xc - k, yc + k + 18)-(xc + 16 + k, yc + k + 18), dy
LINE (xc + k + 16, yc - k)-(xc + k + 16, yc + k + 18), dy
NEXT k
END SUB

SUB clrlin (x)
COLOR 15
LOCATE x, 1: PRINT SPACE$(80); : LOCATE x, 2
END SUB

SUB curser (a$, xloc, yloc)
a$ = RIGHT$(a$, 1)
SELECT CASE a$
	CASE "G"
gee:
	IF yloc = 1 GOTO cross
	xloc = xloc - 1
	yloc = yloc - 1
	CASE "H"
	IF xloc = 1 GOTO eye
	IF xloc = 54 GOTO gee
	IF RND > .5 GOTO gee ELSE GOTO eye
	CASE "I"
eye:
	IF yloc = 1 GOTO cross
	xloc = xloc + 1
	yloc = yloc - 1
	CASE "K"
	xloc = xloc - 2
	CASE "M"
	xloc = xloc + 2
	CASE "O"
oh:
	IF yloc = 20 GOTO cross
	xloc = xloc - 1
	yloc = yloc + 1
	CASE "P"
	IF xloc = 1 GOTO que
	IF xloc = 54 GOTO oh
	IF RND > .5 GOTO oh ELSE GOTO que
	CASE "Q"
que:
	IF yloc = 20 GOTO cross
	yloc = yloc + 1
	xloc = xloc + 1
	CASE "1"
	yloc = 20: xloc = 2
	CASE "2"
	yloc = 20: xloc = 28
	CASE "3"
	yloc = 20: xloc = 54
	CASE "4"
	yloc = 10: xloc = 2
	CASE "5"
	yloc = 10: xloc = 28
	CASE "6"
	yloc = 10: xloc = 54
	CASE "7"
	yloc = 1: xloc = 1
	CASE "8"
	yloc = 1: xloc = 27
	CASE "9"
	yloc = 1: xloc = 54
	CASE ELSE
END SELECT
IF xloc > 53 THEN xloc = 54
IF xloc < 2 THEN xloc = 2
IF yloc < 1 THEN yloc = 1
IF yloc > 20 THEN yloc = 20
IF INT((xloc + yloc) / 2) * 2 <> xloc + yloc THEN xloc = xloc + 1
IF xloc = 55 AND INT(yloc / 2) * 2 <> yloc THEN xloc = 53
cross:
END SUB

SUB DESCRIBE (k)
t$ = LEFT$(unit$(k), 1)
strip2:
SELECT CASE t$
	CASE "I"
	PRINT "Infantry";
	CASE "�"
	PRINT "CHARGING Infantry";
	CASE "C"
	PRINT "Cavalry";
	CASE "G"
	PRINT "General";
	CASE "A"
	PRINT "Rifled Artillery";
	CASE "N"
	PRINT "Napoleon";
	CASE "H"
	PRINT "Horse Artillery";
	CASE "B"
	PRINT "Boat"
	CASE "L"
	t$ = MID$(unit$(k), 2): PRINT "L";
	GOTO strip2
	CASE "E"
	PRINT "Emplaced Gun";
	CASE "w"
	t$ = MID$(unit$(k), 2): PRINT "w";
	GOTO strip2
	CASE ELSE
END SELECT
END SUB

SUB drawmap
	toggle = 1
	repeat = 0
	GOSUB freshmap
	yloc = 10: xloc = 28: repeat = 0
	y = yloc: x = xloc
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
'============================================================================
'                            MAP EDIT
'============================================================================
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
'============================================================================
movec:
	COLOR 2: CALL terra(z, a$)
	y = yloc: x = xloc
	GOSUB showt
	GOSUB wait4: IF LEN(commnd$) > 1 GOTO com2
	a$ = UCASE$(RIGHT$(commnd$, 1))
	SELECT CASE a$
		CASE "A": PUT (8 * x, 14 * y), Xhair, XOR: GOSUB armies: PUT (8 * x, 14 * y), Xhair, XOR: GOTO movec
		CASE "B": z = 91: CALL replace(yloc, xloc, z): GOTO movec
		CASE "C": z = 46: CALL replace(yloc, xloc, z): GOTO movec
		CASE "F": z = 35: CALL replace(yloc, xloc, z): GOTO movec
		CASE "H": z = 94: CALL replace(yloc, xloc, z): GOTO movec
		CASE "M": z = 239: CALL replace(yloc, xloc, z): GOTO movec
		CASE "P": z = 58: CALL replace(yloc, xloc, z): GOTO movec
		CASE "R": z = 43: CALL replace(yloc, xloc, z): GOTO movec
		CASE "S": z = 61: CALL replace(yloc, xloc, z): GOTO movec
		CASE "T": z = 42: CALL replace(yloc, xloc, z): GOTO movec
		CASE "V": z = 254: CALL replace(yloc, xloc, z): GOTO movec
		CASE "W": z = 176: CALL replace(yloc, xloc, z): GOTO movec
		CASE "D": GOSUB rep1: GOTO movec
		CASE "Z"
			IF toggle = 1 THEN GOSUB allterr: toggle = 0: GOTO movec
			toggle = 1
			PUT (8 * x, 14 * y), Xhair, XOR: GOSUB armies
			PUT (8 * x, 14 * y), Xhair, XOR: GOTO movec
		CASE "O": GOTO keyo
		CASE "L"
			a = 0: z = 0: a$ = "ALTERNATE OBJECTIVE"
moro:
			mtx$(0) = "Alt Objective"
			mtx$(1) = "Set Time": IF a > 0 THEN mtx$(1) = " {ok}"
			mtx$(2) = "Set Terrain": IF z > 0 THEN mtx$(1) = " {ok}"
			mtx$(3) = "Remove Alt Obj"
			size = 3: tlx = 57: tly = 6
			colour = 5
			CALL menu
			SELECT CASE choose
				CASE 1
					CALL clrlin(23)
					PRINT "Number of turns into game when objective will change";
					CALL Enput(s$, 55, 23, 60, "0123456789")
					IF s$ = "" THEN GOSUB bbar: GOTO movec
					a = VAL(s$)
					CALL clrlin(23)
				CASE 2
					CALL clrlin(23)
					PRINT "Terrain to replace ORIGINAL objective (BCFHMPRSTVW) :";
					DO: s$ = INKEY$: LOOP WHILE s$ = ""
					s$ = UCASE$(s$): PRINT s$;
					SELECT CASE s$
						CASE "B": z = 91
						CASE "C": z = 46
						CASE "F": z = 35
						CASE "H": z = 94
						CASE "M": z = 239
						CASE "P": z = 58
						CASE "R": z = 43
						CASE "S": z = 61
						CASE "T": z = 42
						CASE "V": z = 254
						CASE "W": z = 176
						CASE ELSE
							GOSUB bbar: GOTO movec
					END SELECT
				CASE 3
					altobj$ = ""
					PUT (8 * alt(2), 14 * alt(3)), Oterr, XOR
					CALL clrlin(23)
					PRINT a$; " REMOVED";
					TICK 99
					GOSUB bbar
					GOTO movec
			END SELECT
			IF a * z = 0 GOTO moro
			IF altobj$ <> "" THEN PUT (8 * alt(2), 14 * alt(3)), Oterr, XOR
			alt(1) = a: alt(2) = x: alt(3) = y
			altobj$ = LTRIM$(RTRIM$(STR$(alt(1)))) + "/" + LTRIM$(RTRIM$(STR$(alt(2)))) + "/" + LTRIM$(RTRIM$(STR$(alt(3)))) + "/" + CHR$(z)
			PUT (8 * alt(2), 14 * alt(3)), Oterr, XOR
			CALL clrlin(23): PRINT a$; " ESTABLISHED : "; altobj$;
			TICK 99
			GOSUB bbar
	END SELECT
com2:
	IF RIGHT$(commnd$, 1) = ";" THEN CALL help: GOTO movec
	IF RIGHT$(commnd$, 1) = "D" THEN EXIT SUB
	CALL curser(commnd$, xloc, yloc)

	PUT (8 * x, 14 * y), Xhair, XOR
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	IF repeat > 0 THEN CALL replace(yloc, xloc, repeat): GOTO movec
	GOTO movec
'============================================================================
'                           Keyboard Commands
'============================================================================
wait4:
	DO: commnd$ = INKEY$: LOOP UNTIL commnd$ <> ""
wait1:
	a = ASC(LEFT$(commnd$, 1))
	IF a = 13 THEN SOUND 400, .7: RETURN
	IF a = 27 OR a = 32 THEN RETURN

	IF commnd$ = "/" THEN RETURN
	RETURN
'============================================================================
'                         Show Underneath Terrain
'============================================================================
showt:
	z = ASC(MID$(sdtext$(y + 1), x, 1))
	CALL Tara(74, 19, z)
	RETURN
'============================================================================
'                              Redraw Map
'============================================================================
freshmap:
CALL mainmap
LINE (453, 10)-(627, 33), 0, BF
LINE (453, 10)-(627, 33), 15, B
COLOR 15: LOCATE 2, 58: PRINT "F1 = Help  F10 = menu"
LINE (460, 37)-(620, 60), 0, BF
LINE (460, 37)-(620, 60), 11, B
COLOR 11: LOCATE 4, 64: PRINT "MAP EDITOR"
LINE (453, 90)-(637, 115), 0, BF
LINE (453, 90)-(637, 115), 4, B

LINE (461, 191)-(619, 214), 0, BF
LINE (460, 190)-(620, 215), 14, B
COLOR 12: LOCATE 15, 60: PRINT "Z"; : COLOR 7: PRINT " = Armies Toggle"

LINE (461, 236)-(619, 269), 0, BF
LINE (460, 235)-(620, 270), 13, B
LINE (580, 235)-(580, 270), 13
COLOR 13
LOCATE 18, 63: PRINT "Terrain"
LOCATE 19, 60: PRINT "Under Cursor"
bbar:
CALL clrlin(23): PRINT "ridge  lear  ort  ill  tn  bj'tiv  lowd  oad  wamp  rees  illage  ater";
COLOR 14: LOCATE 23, 1: PRINT "B": LOCATE 23, 8: PRINT "C";
LOCATE 23, 14: PRINT "F"; : LOCATE 23, 19: PRINT "H";
LOCATE 23, 24: PRINT "M"; : LOCATE 23, 28: PRINT "O";
LOCATE 23, 36: PRINT "P"; : LOCATE 23, 42: PRINT "R";
LOCATE 23, 47: PRINT "S"; : LOCATE 23, 53: PRINT "T"; : LOCATE 23, 59: PRINT "V";
LOCATE 23, 67: PRINT "W";

armies:
FOR k = 1 TO most
IF strength(k) > 0 THEN CALL SHOWUNIT(k)
NEXT k
CALL BUTTON(68, 10, 14, "D", repeat)
PAINT (540, 130), 7, 14      'PAINT (68 * 8 - 4, 10 * 14 - 10), 7, 14
RETURN
'============================================================================
rep1:
	IF repeat > 0 THEN
		repeat = 0
	ELSE z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
		IF z = 233 THEN repeat = 0 ELSE repeat = z
	END IF
	CALL BUTTON(68, 10, 14, "D", repeat)
	PAINT (68 * 8 - 4, 10 * 14 - 10), 7, 14
	IF repeat = 0 THEN
		LINE (454, 91)-(636, 114), 0, BF
		IF quiet > 0 THEN SOUND 99, 1
		RETURN
	END IF

	COLOR 12: LOCATE 8, 62: PRINT "DUPLICATE ": CALL Tara(72, 8, z)
		  IF quiet > 0 THEN SOUND 3100, .7
	RETURN
'============================================================================
'                              Set Objective
'============================================================================
keyo:
FOR k = 1 TO 24: flag = INSTR(sdtext$(k), "�"): IF flag > 0 GOTO movec
NEXT k
mtx$(0) = "Objective Control"
mtx$(1) = "None"
mtx$(2) = "Rebel"
mtx$(3) = "Union"
size = 3: CALL menu
SELECT CASE choose
	CASE 2, 3
	possess = choose - 1
	CASE ELSE
	possess = 0
END SELECT
z = 233: CALL replace(yloc, xloc, z): GOTO movec
'============================================================================
'                              Clear Terrain
'============================================================================
allterr:
FOR k = 1 TO most
IF strength(k) > 0 THEN CALL Tara(unitx(k), unity(k) + 1, 0)
NEXT k
RETURN

march:
END SUB

SUB Enput (t$, tlx, tly, brx, mask$)
'===========================================================================
'                               Initialize
'===========================================================================
  x1 = 1
  text$ = t$ + SPACE$(brx - tlx + 1 - LEN(t$))
  LOCATE tly, tlx: PRINT text$;

'===========================================================================
'                               MAIN LOOP
'===========================================================================
DO
'...........................................................................
  DO
     LINE (8 * (tlx + x1 - 2), 14 * (tly - 1))-(8 * (tlx + x1 - 2) + 8, 14 * tly), 15, B
     LOCATE tly, tlx + x1 - 1, 1
'===========================================================================
'                               Get Key
'===========================================================================
	Ky$ = ""
	DO WHILE Ky$ = "": Ky$ = INKEY$: LOOP
     LINE (8 * (tlx + x1 - 2), 14 * (tly - 1))-(8 * (tlx + x1 - 2) + 8, 14 * tly), 0, B

	IF LEN(Ky$) > 1 THEN
		choose = -1 * ASC(RIGHT$(Ky$, 1))
	ELSE
		choose = ASC(Ky$)
	END IF
'===========================================================================
'                               Key Actions
'===========================================================================
SELECT CASE choose
	CASE -83                          'delete key
	 MID$(text$, x1) = MID$(text$, x1 + 1) + " "
	 LOCATE , , 0
	 PRINT MID$(text$, x1);

	CASE -82                         'Insert
	 Insrt = 1 - Insrt
	 IF Insrt = 0 THEN
		LOCATE , , , 6, 7
	 ELSE
		LOCATE , , , 1, 6
	 END IF

	CASE -79                         'end key
	 a$ = RTRIM$(text$): x1 = LEN(a$) + 1
	 IF x1 > LEN(text$) THEN x1 = LEN(text$)


	CASE -77                         'right arrow
	 IF tlx + x1 < brx + 1 THEN x1 = x1 + 1

	CASE -75                         'left arrow
	 IF x1 > 1 THEN x1 = x1 - 1

	CASE -71                         'home key
	 x1 = 1

	CASE 8                           'backspace
	 IF x1 > 1 THEN x1 = x1 - 1
	 LOCATE , tlx + x1 - 1, 0
	 IF x1 > 0 THEN
		IF Insrt THEN
		MID$(text$, x1) = MID$(text$, x1 + 1) + " "
	   ELSE
		MID$(text$, x1) = " "
	   END IF
		PRINT MID$(text$, x1);
	 END IF

	CASE 13                          'enter
	 EXIT DO

	CASE 27                          'escape : blanks the text
	 text$ = CHR$(27): EXIT DO

	CASE 32 TO 122                   'other keys : check vs. mask
	 IF LEN(mask$) > 0 THEN IF INSTR(mask$, CHR$(choose)) = 0 GOTO illegalk
	 IF x1 > brx - tlx + 1 GOTO illegalk
	 LOCATE , , 0
	 IF Insrt THEN
	   MID$(text$, x1) = Ky$ + MID$(text$, x1)
	   PRINT MID$(text$, x1);
	 ELSE
	   MID$(text$, x1) = Ky$
	   PRINT Ky$;
	 END IF
	 IF x1 <= brx - tlx + 1 THEN x1 = x1 + 1

	CASE ELSE
illegalk:
	 SOUND 200, .3
	 EXIT DO
END SELECT

  LOOP UNTIL x1 < 1 OR x1 > LEN(text$)
  t$ = RTRIM$(text$)
LOOP UNTIL choose = 13 OR choose = 27
END SUB

SUB help
SCREEN 9, , 1, 1
CLS
COLOR 11
LOCATE 3, 9: PRINT "CURSOR MOVES": PRINT "	���������������"
PRINT "	<arrow keys>       = move cursor"
PRINT "	<shft>+<arrow keys>= jump moves (corners, top, bottom, center)"
COLOR 10
PRINT : PRINT "	TERRAIN FEATURES": PRINT "	���������������"
PRINT "	B  = bridge"; TAB(40); "R  = road"
PRINT "	C  = clearing"; TAB(40); "S  = swamp"
PRINT "	F  = fort"; TAB(40); "T  = trees"
PRINT "	H  = hills"; TAB(40); "V  = village"
PRINT "	M  = mountain"; TAB(40); "W  = water"
PRINT "	P =  plowed field"
PRINT : COLOR 13, 0
PRINT "	D  = DUPLICATE MODE TOGGLE"
PRINT "	O  = SET PRIMARY OBJECTIVE (exactly 1 is REQUIRED for each scenario)"
PRINT "	L  = SET ALTERNATE OBJECTIVE (optional; at most 1 alt obj)"
COLOR 15: LOCATE 23, 9: PRINT "(hit a key)";
COLOR 14: LOCATE 1, 35: PRINT "MAP EDIT HELP"
LINE (0, 0)-(639, 340), 11, B
DO WHILE INKEY$ = "": LOOP
SCREEN 9, , 0, 0
END SUB

SUB helpme
SCREEN 9, , 1, 1
CLS
COLOR 11
PRINT "		To select which side to place/edit"
COLOR 9: PRINT "	'U'  = Union (USA)"
PRINT "	'R' =  Rebel"
PRINT "	(or move cursor over location/unit and press ENTER for menu)"
LINE (0, 0)-(639, 60), 9, B
COLOR 11
PRINT : PRINT "		Short cut keys to PLACE units"
COLOR 15
PRINT "	'A' = ARTILLERY (RIFLED)       'B' = BOAT"
PRINT "	'C' =  CAVALRY                 'E' = EMPLACED ARTILLERY"
PRINT "	'G' = GENERAL                  'H' =  HORSE ARTILLERY"
PRINT "	'I' = INFANTRY                 'N' = NAPOLEON ARTILLERY"
LINE (0, 66)-(639, 145), 15, B
COLOR 11
PRINT : PRINT "		Short cut keys to EDIT units"
COLOR 14
PRINT "	'S' = STRENGTH                 'P' = move to new POSITION"
PRINT "	'M' = MORALE                   'T' = change unit TYPE"
PRINT "	'L' = LEADER                   'Z' = ZAP UNIT"
PRINT "	'D' = DELAY UNIT ENTRY         '!' = WHOOPS! (UNZAP UNIT)"
PRINT "	'E' = ENTRENCH                 '+' = OVERRIDE NO STACKING"
PRINT "	'W =  UNIT IN WAITED STATUS"
LINE (0, 150)-(639, 261), 4, B
COLOR 14: LOCATE 24, 1: PRINT "(hit a key)";
TICK 999
SCREEN 9, , 0, 0
END SUB

SUB iconload
SCREEN 9
LOCATE 1, 1: COLOR 11: PRINT "Loading Icons"
'----------------------------------------------------------------------------
'                            UNIT Icons
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
	GET (300, 143)-(315, 156), bridge
	GET (317, 101)-(332, 114), Xhair
	GET (317, 115)-(332, 128), Death
	GET (317, 129)-(332, 142), Boat
	GET (317, 143)-(332, 156), Pfield
END SUB

SUB mainmap
COLOR 2: SCREEN 9: CLS
LINE (5, 1)-(639, 300), 8, BF
COLOR 15: x = 55 - LEN(scenario$): x = .5 * x + .5: LOCATE 1, x: PRINT scenario$
LINE (5, 1)-(639, 300), 4, B
FOR k = 2 TO 21
	s = 2: IF INT(.5 * k) * 2 = k THEN s = 1
	FOR j = s TO 54 STEP 2
	CALL Tara(j, k, 0)
	NEXT j
NEXT k
	LINE (450, 1)-(450, 300), 4
	IF altobj$ <> "" THEN PUT (8 * alt(2), 14 * alt(3)), Oterr, XOR
END SUB

SUB menufile (t$)
SCREEN 0: COLOR 0, 1: CLS
LOCATE 1, 1: COLOR 4, 3: PRINT SPACE$(80)
LOCATE 1, 1: PRINT "{arrow keys} TO SELECT FILE              {ENTER} TO LOAD"
COLOR 11, 1
FILES "*.civ"
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
COLOR 11, 1
LOCATE 23, 2: PRINT "Loading "; t$; " ";
END SUB

SUB namer (file$, a$)
newname:
CLOSE #1: OPEN "i", 1, file$
INPUT #1, x
x = x * RND
FOR i = 1 TO x: INPUT #1, a$: NEXT i
CLOSE #1
FOR k = 1 TO most
IF a$ = name$(k) THEN
	IF RND > .01 THEN
		GOTO newname
		ELSE
		x = 1 + 25 * RND
		a$ = CHR$(64 + x) + "." + a$
		EXIT SUB
	END IF
END IF
NEXT k
END SUB

SUB placearmy
	who$ = "Rebel (CSA)": zapflag = 0
	GOSUB fresh: CALL scoreboard(0)
	yloc = 10: xloc = 28
	stax = 0
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	GOSUB sequence
'============================================================================
'                            ARMY PLACEMENT
'============================================================================
movea:
	y = yloc: x = xloc
	GOSUB wait8
	a = ASC(commnd$)
	IF stax > 0 AND a = 13 THEN GOSUB newloc: GOTO movea
	IF a = 13 THEN GOSUB soldier: GOTO movea

	IF stax > 0 THEN
		CALL Tara(xloc, yloc + 1, ASC(MID$(sdtext$(yloc + 1), xloc, 1)))
		IF stackflag > 0 THEN GOSUB frash
	ELSE
		PUT (8 * x, 14 * y), Xhair, XOR
	END IF

	CALL curser(commnd$, xloc, yloc)

	IF stax > 0 THEN GOSUB iconx ELSE PUT (8 * xloc, 14 * yloc), Xhair, XOR
	GOSUB statlin

	GOTO movea
'============================================================================
attn:
	CALL whois(xloc, yloc, index, 0)
	IF index > 0 THEN who$ = "Rebel (CSA)": IF index > .5 * most THEN who$ = "Union (USA)"
	GOSUB side: RETURN
'============================================================================
'                           Keyboard Commands
'============================================================================
wait8:
	commnd$ = INKEY$: IF commnd$ = "" GOTO wait8
	IF commnd$ = CHR$(0) + "D" THEN IF stax = 0 THEN EXIT SUB ELSE CALL clrlin(23): COLOR 12: PRINT "MUST PLACE UNIT BEFORE RETURNING TO MAIN MENU": BEEP: GOTO wait8

	IF RIGHT$(commnd$, 1) = ";" THEN CALL helpme: RETURN
	IF RIGHT$(commnd$, 1) = "=" THEN
		GOSUB fresh: CALL scoreboard(0)
		GOSUB frosh
		PUT (8 * xloc, 14 * yloc), Xhair, XOR
		COLOR 14
		IF stackflag > 0 THEN
			LINE (460, 95)-(620, 115), 4, BF
			LINE (460, 95)-(620, 115), 0, B
			LOCATE 8, 62: PRINT "STACK FLAG ON"
		END IF
		IF stax > 0 THEN
			LINE (461, 126)-(590, 139), 0, BF
			LOCATE 10, 59: PRINT "MOVING Unit"; stax
			LINE (461, 126)-(619, 139), 14, B
		END IF
		GOSUB sequence
	END IF
	IF LEN(commnd$) > 1 THEN commnd$ = RIGHT$(commnd$, 1): RETURN

	IF ASC(commnd$) = 13 THEN
		IF quiet > 0 THEN SOUND 400, .7
		RETURN
	END IF
	IF ASC(commnd$) = 27 THEN RETURN
	IF ASC(commnd$) = 32 THEN RETURN

	SELECT CASE UCASE$(commnd$)
	CASE "A": GOSUB sequence: IF index > 0 THEN GOSUB rart
	CASE "B": GOSUB sequence: IF index > 0 THEN GOSUB ship
	CASE "C": GOSUB sequence: IF index > 0 THEN GOSUB cav
	CASE "D": GOSUB attn: IF index > 0 THEN GOSUB delay
	CASE "E": GOSUB attn
		IF index > 0 THEN
			GOSUB entr
		ELSE
			GOSUB sequence: GOSUB emplace
		END IF
	CASE "G": GOSUB sequence: IF index > 0 THEN GOSUB gen
	CASE "H": GOSUB sequence: IF index > 0 THEN GOSUB hart
	CASE "I": GOSUB sequence: IF index > 0 THEN GOSUB infant
	CASE "L": GOSUB attn: IF index > 0 THEN choose = 3: GOSUB attrib
	CASE "M": GOSUB attn: IF index > 0 THEN choose = 2: GOSUB attrib
	CASE "N": GOSUB sequence: IF index > 0 THEN GOSUB nart
	CASE "P":
		  CALL whois(xloc, yloc, index, 0)
		  IF index > 0 THEN
			stax = index
			GOSUB movem
			IF INSTR(who$, "R") AND index > 40 THEN
				who$ = "Union (USA)": GOSUB side
			END IF
			IF INSTR(who$, "U") AND index < 41 THEN
				who$ = "Rebel (CSA)": GOSUB side
			END IF
			RETURN
		  END IF
	CASE "R": who$ = "Rebel (CSA)": GOSUB side
		  IF quiet > 0 THEN SOUND 3100, .7
	CASE "S": GOSUB attn: IF index > 0 THEN choose = 1: GOSUB attrib
	CASE "T": GOSUB attn: IF index > 0 THEN GOSUB newtype
	CASE "U": who$ = "Union (USA)": GOSUB side
		  IF quiet > 0 THEN SOUND 2999, .7
	CASE "W"
		  GOSUB attn
		  IF uorder(index) = 99 GOTO wait8
		  IF index > 0 THEN
			IF LEFT$(unit$(index), 1) <> "w" THEN
				unit$(index) = "w" + unit$(index)
			ELSE
				unit$(index) = RIGHT$(unit$(index), 1)
			END IF
				SHOWUNIT (index)
				SOUND 99, .7
				PUT (8 * xloc, 14 * yloc), Xhair, XOR
		  END IF
	CASE "Z": GOSUB attn: IF index > 0 THEN GOSUB zap
	CASE "!": IF zapflag > 0 THEN GOSUB unzap
	CASE "+"
		  IF stax > 0 THEN
			stackflag = 1
			LINE (460, 95)-(620, 115), 4, BF
			LINE (460, 95)-(620, 115), 0, B
			COLOR 14: LOCATE 8, 62: PRINT "STACK FLAG ON"
			SOUND 1999, .7: SOUND 999, .7
		  END IF
	CASE "1", "2", "3", "4", "5", "6", "7", "8", "9": RETURN
	CASE ELSE
	END SELECT

	GOTO wait8
'============================================================================
'                              Redraw Entire Map
'============================================================================
fresh:
	CALL mainmap
frash:
	FOR k = 1 TO most
	IF strength(k) > 0 THEN CALL SHOWUNIT(k)
	NEXT k
	IF stackflag > 0 THEN RETURN
frosh:
	LINE (460, 37)-(620, 60), 0, BF
	LINE (460, 37)-(620, 60), 11, B
	COLOR 11: LOCATE 4, 64: PRINT "ARMY EDITOR"
	LINE (453, 10)-(627, 33), 0, BF
	LINE (453, 10)-(627, 33), 15, B
	LOCATE 2, 60: PRINT "F3:Redraw F10:Menu"
	GOSUB side
RETURN
'============================================================================
'                              Which Side is Being Edited
'============================================================================
side:
	c = 7: dx = 0: IF LEFT$(who$, 1) = "U" THEN dx = 1: c = 9
	CALL BUTTON(65, 6, 9, "U", dx)
	CALL BUTTON(70, 6, 4, "R", 1 - dx): PAINT (556, 74), 7, 4   'PAINT (70 * 8 - 4, 6 * 14 - 10), 7, 4
	LINE (460, 95)-(620, 115), 0, BF
	LINE (460, 95)-(620, 115), c, B
	COLOR c: LOCATE 8, 63: PRINT who$
	RETURN
'============================================================================
'                              Army Status Line
'============================================================================
statlin:
CALL whois(xloc, yloc, index, 0)
IF index = 0 OR stackflag > 0 THEN
	GOSUB butt1: LOCATE 24, 1: PRINT SPACE$(40);
	CALL clrlin(23)
	RETURN
END IF
IF stax > 0 THEN
	xloc = x
	yloc = y
	GOSUB iconx
	CALL SHOWUNIT(index)
	SOUND 400, 1: RETURN
END IF
CALL clrlin(23): COLOR 7: IF index > .5 * most THEN COLOR 9
PRINT "Unit "; index; "  "; name$(index); " "; : CALL DESCRIBE(index)
PRINT " Str:"; strength(index); " Mor:"; morale(index);
PRINT " Ldr:"; leader(index);
IF uorder(index) <> 99 THEN PRINT "  ";  ELSE PRINT " *";
PRINT "Dly:"; toa(index);
IF uorder(index) < 0 THEN COLOR 4: PRINT " ENTRENCH";
GOSUB butt2
RETURN
butt1:
IF stax > 0 THEN RETURN
LINE (460, 125)-(620, 140), 0, BF
LINE (460, 125)-(620, 140), 14, B
COLOR 14: LOCATE 10, 61: PRINT "I A E H N C G B"
GOSUB zapline
RETURN
butt2:
IF stax > 0 THEN RETURN
LINE (460, 125)-(620, 140), 0, BF
LINE (460, 125)-(620, 140), 14, B
COLOR 14: LOCATE 10, 61: PRINT "D E L M P S T Z"
GOSUB zapline
RETURN
zapline:
IF strength(zapflag) > 0 THEN zapflag = 0
IF zapflag > 0 THEN COLOR 12: LOCATE 10, 76: PRINT "!"
RETURN
'============================================================================
'                             Menu
'============================================================================
soldier:
GOSUB side
tlx = 59: tly = 7
CALL whois(xloc, yloc, index, 0): IF index > 0 GOTO adjust1
choose = 23
GOSUB sequence: IF index = 0 THEN RETURN
mtx$(0) = "PLACE ARMY " + STR$(index)

mtx$(1) = who$
mtx$(2) = "Infantry"
mtx$(3) = "Cavalry"
mtx$(4) = "Napoleon Artil'ry"
mtx$(5) = "Artillery - Rifle"
mtx$(6) = "Horse Artillery"
mtx$(7) = "Emplaced Gun"
mtx$(8) = "General"
mtx$(9) = "Boat"
mtx$(10) = "REDRAW SCREEN"
size = 10: colour = 11: tlx = 59
IF index = 0 THEN GOTO soldier
CALL menu

LINE (452, 80)-(630, 299), 8, BF
CALL scoreboard(0)
GOSUB frosh

IF choose = -1 THEN RETURN
morale(index) = 80: leader(index) = 80

SELECT CASE choose
CASE 1           ' toggle to other side
	IF LEFT$(who$, 1) = "R" THEN who$ = "Union (USA)": GOSUB sequence: GOTO soldier
	IF LEFT$(who$, 1) = "U" THEN who$ = "Rebel (CSA)": GOSUB sequence: GOTO soldier
CASE 2
infant:
	GOSUB room: IF flag = 1 THEN RETURN
	unit$(index) = "I": strength(index) = 750
	GOTO set1
CASE 3
cav:
	GOSUB room: IF flag = 1 THEN RETURN
	unit$(index) = "C": strength(index) = 500
	GOTO set1
CASE 4
nart:
	GOSUB room: IF flag = 1 THEN RETURN
	unit$(index) = "N": strength(index) = 300
	GOTO set1
CASE 5
rart:
	GOSUB room: IF flag = 1 THEN RETURN
	unit$(index) = "A": strength(index) = 300
	GOTO set1
CASE 6
hart:
	GOSUB room: IF flag = 1 THEN RETURN
	unit$(index) = "H":
	strength(index) = 100
	GOTO set1
CASE 7
emplace:
	GOSUB room: IF flag = 1 THEN RETURN
	unit$(index) = "E"
	strength(index) = 300
	GOTO set1
CASE 8
gen:
	GOSUB room: IF flag = 1 THEN RETURN
	unit$(index) = "G": strength(index) = 200
	GOTO set1
CASE 9
ship:
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1)): IF z <> 176 THEN RETURN
	GOSUB room: IF flag = 1 THEN RETURN
	unit$(index) = "B": strength(index) = 300
	GOTO set1
CASE 10
	GOSUB fresh
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
CASE ELSE
END SELECT
RETURN
'============================================================================
'                             Show Unit Just Placed
'============================================================================
set1:
z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
unity(index) = y: unitx(index) = x: terrain(index) = z
morale(index) = 80: leader(index) = 80
CALL SHOWUNIT(index)
PUT (8 * xloc, 14 * yloc), Xhair, XOR
z = ASC(LEFT$(unit$(index), 1))
CALL scoreboard(1)
tell:
CALL clrlin(23)
COLOR 11: PRINT "Enter Name of Unit "; index;
INPUT name$(index)
IF name$(index) = "" THEN
	ON ERROR GOTO cater3
	CALL autoname(index, who$)
	ON ERROR GOTO 0
END IF
IF LEN(name$(index)) > 16 THEN name$(index) = LEFT$(name$(index), 16)
IF name$(index) = "" GOTO tell
IF quiet > 0 THEN SOUND 2700, 1
CALL clrlin(23)
GOSUB frosh
RETURN

'============================================================================
'                             Get Index Sequence
'============================================================================
sequence:
s = 1: F = .5 * most: IF LEFT$(who$, 1) = "U" THEN s = .5 * most + 1: F = most

FOR index = s TO F
IF strength(index) < 1 THEN RETURN
NEXT index

CALL clrlin(23)
BEEP
COLOR 12: PRINT "NO MORE SLOTS FOR "; who$; " ARMIES";
    IF LEFT$(who$, 1) = "R" THEN who$ = "Union (USA)": GOTO dl
    IF LEFT$(who$, 1) = "U" THEN who$ = "Rebel (CSA)"
dl: DO WHILE INKEY$ = "": LOOP: CALL clrlin(23)
    GOSUB side
    index = 0
RETURN

room:
flag = 0
CALL whois(x, y, ndx, 0): IF ndx = 0 THEN RETURN
CALL clrlin(23): BEEP: flag = 1
COLOR 12: PRINT "Cannot Stack Units";
TICK 99: CALL clrlin(23)
RETURN
'============================================================================
'                             Edit Unit
'============================================================================
adjust1:
CALL whois(xloc, yloc, index, 0): IF index = 0 GOTO err5
GOSUB statlin
tlx = 59
tly = 2: IF yloc < 10 THEN tly = 9
who$ = "Rebel (CSA)": IF index > .5 * most THEN who$ = "Union (USA)"
GOSUB side
mtx$(0) = who$ + STR$(index)
mtx$(1) = "Strength " + STR$(strength(index))
mtx$(2) = "Morale " + STR$(morale(index))
mtx$(3) = "Leader " + STR$(leader(index))
mtx$(4) = name$(index)
mtx$(5) = "DELAY" + STR$(toa(index))
IF uorder(index) = 99 THEN mtx$(5) = mtx$(5) + " *"
mtx$(6) = "Unit Normal": IF uorder(index) < 0 THEN mtx$(6) = "Unit ENTRENCHED"
mtx$(7) = "ZAP UNIT (Z)"
mtx$(8) = "POSITION UNIT": IF stax > 0 THEN mtx$(8) = "* * * *"
mtx$(9) = "CANCEL"
size = 9: colour = 5
CALL menu
CALL repair
CALL scoreboard(0)
GOSUB frosh

SELECT CASE choose
CASE -1
GOSUB side
RETURN
CASE 1 TO 3
attrib:
CALL attribute(choose, index)
CALL scoreboard(1)
GOSUB side

CASE 4
CALL clrlin(23): PRINT "New name for unit "; : INPUT name$(index)
SOUND 2700, 1: CALL clrlin(23)
RETURN
CASE 5
delay:
	CALL clrlin(23): COLOR 11
	PRINT "Delay how many time units "; : INPUT a$
	CALL scoreboard(1)
	toa(index) = VAL(a$)
	IF toa(index) = 0 THEN uorder(index) = 0: CALL SHOWUNIT(index): SOUND 2300, .5: RETURN
	CALL clrlin(23): COLOR 11
	PRINT "Unit off screen during delay [Y/n] ?";
	DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
	a$ = UCASE$(a$)
	IF a$ <> "N" AND toa(index) > 0 THEN
		uorder(index) = 99
	ELSE
		uorder(index) = 0
	END IF
	CALL SHOWUNIT(index)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	SOUND 2700, .5
	RETURN
CASE 6
entr:
	IF uorder(index) = 0 THEN uorder(index) = -1: CALL clrlin(23): PRINT "Unit is entrenched": SOUND 1700, 2: RETURN
	IF uorder(index) = -1 THEN uorder(index) = 0: CALL clrlin(23): PRINT "Unit is NORMAL": SOUND 1200, 2: RETURN
CASE 7
zap:
strength(0) = strength(index)
name$(0) = name$(index): toa(0) = toa(index): uorder(0) = uorder(index)
leader(0) = leader(index): morale(0) = morale(index)
unit$(0) = unit$(index): zapflag = index

strength(index) = 0
PUT (8 * xloc, 14 * yloc), Xhair, XOR
CALL Tara(xloc, yloc + 1, 0)
PUT (8 * xloc, 14 * yloc), Xhair, XOR
z = terrain(index)
unitx(index) = 0: unity(index) = 0: name$(index) = "": toa(index) = 0: uorder(index) = 0
leader(index) = 0: morale(index) = 0: terrain(index) = 0: unit$(index) = ""

IF quiet > 0 THEN SOUND 2500, 1: SOUND 2700, 1
CALL clrlin(23): COLOR 13: PRINT name$(0); " ZAPPED!";
CALL scoreboard(0)
CASE 8
CALL scoreboard(1)
IF stax > 0 THEN RETURN
stax = 1: GOSUB movem: RETURN
CASE ELSE
END SELECT
RETURN

err5:
CALL clrlin(23): COLOR 12: PRINT "NO UNIT AT THAT LOCATION"; : BEEP
DO WHILE INKEY$ = "": LOOP: CALL clrlin(23)
RETURN
'============================================================================
'                            Change Unit Type
'============================================================================
newtype:
CALL clrlin(23): COLOR 11: PRINT "Enter New Unit Type ( A B C E G H I N )";
DO: t$ = INKEY$: LOOP WHILE t$ = ""
t$ = UCASE$(t$)
IF INSTR("ABCEGHIN", t$) = 0 THEN CALL clrlin(23): RETURN
SELECT CASE t$
CASE "A"
	unit$(index) = "A": GOSUB maxa
CASE "B"
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1)): IF z <> 176 THEN RETURN
	unit$(index) = "B"
CASE "C"
	unit$(index) = "C"
CASE "E"
	unit$(index) = "E"
CASE "G"
	unit$(index) = "G"
CASE "H"
	unit$(index) = "H": GOSUB maxa
CASE "I"
	unit$(index) = "I"
CASE "N"
	unit$(index) = "N": GOSUB maxa
CASE ELSE
END SELECT
CALL clrlin(23): COLOR 11: PRINT "Unit "; index; " changed to "; : CALL DESCRIBE(index)
SHOWUNIT (index)
PUT (8 * xloc, 14 * yloc), Xhair, XOR
IF quiet > 0 THEN FOR k = 1 TO 3: SOUND 900, 1: SOUND 1900, .5: NEXT k
TICK 1
RETURN
maxa:
IF strength(index) > 1000 THEN strength(index) = 1000
RETURN
'============================================================================
'                            Move Unit Selected
'============================================================================
iconx:
		y1 = y: x1 = x
		y = 14 * yloc: x = 8 * xloc
		a = ASC(LEFT$(unit$(stax), 1))
		SELECT CASE a
		CASE 65   'Artillery
		IF stax > 40 THEN PUT (x, y), Aunion, PSET ELSE PUT (x, y), Areb, PSET
		CIRCLE (x + 6, y + 6), 3, 0
		CIRCLE (x + 6, y + 6), 4, 0
		CASE 66   'Boat
		PUT (x, y), Boat, PSET
		CASE 67   'Cavalry
		IF stax > 40 THEN PUT (x, y), Cunion, PSET ELSE PUT (x, y), Creb, PSET
		CASE 69  'Emplaced
		LINE (x, y)-(x + 14, y + 13), 0, BF
		IF stax < 41 THEN
			LINE (x, y)-(x + 12, y + 12), 7, BF
			LINE (x, y)-(x + 12, y + 12), 4, B
			c = 4
		ELSE
			LINE (x, y)-(x + 12, y + 12), 1, BF
			LINE (x, y)-(x + 12, y + 12), 9, B
			c = 9
		END IF
		LINE (x + 3, y + 4)-(x + 9, y + 9), 0, B
		LINE (x + 4, y + 5)-(x + 8, y + 8), c, BF
		CASE 71   'General
		IF stax > 40 THEN PUT (x, y), Gunion, PSET ELSE PUT (x, y), Greb, PSET
		CASE 72   'Horse Artillery
		IF stax > 40 THEN PUT (x, y), Aunion, PSET ELSE PUT (x, y), Areb, PSET
		c = 4: IF stax > 40 THEN c = 15
		LINE (x, y + 12)-(x + 12, y), c
		CASE 73   'Infantry
		IF stax > 40 THEN PUT (x, y), Iunion, PSET ELSE PUT (x, y), Ireb, PSET
		CASE 76 'Limbered Artillery
		IF stax > 40 THEN PUT (x, y), Aunion, PSET: c = 9 ELSE PUT (x, y), Areb, PSET: c = 7
		CIRCLE (x + 6, y + 6), 5, 0
		PAINT (x + 6, y + 6), c, 0
		CASE 78   'Napoleon Artillery
		IF stax > 40 THEN PUT (x, y), Aunion, PSET ELSE PUT (x, y), Areb, PSET
		CASE 119  'wait
		IF stax < 41 THEN
			LINE (x, y)-(x + 15, y + 13), 4, BF
			LINE (x, y)-(x + 15, y + 13), 7, B
		ELSE
			LINE (x, y)-(x + 15, y + 13), 9, BF
			LINE (x, y)-(x + 15, y + 13), 1, B
		END IF
		CASE 232   'Charge Infantry
		IF stax > 40 THEN PUT (x, y), Iunion, PSET: c = 15:                          ELSE PUT (x, y), Ireb, PSET: c = 4
		CIRCLE (x + 6, y + 6), 4, c
		CASE ELSE
		END SELECT
		x = x1: y = y1
RETURN
unzap:
index = zapflag: zapflag = 0
IF strength(index) > 0 THEN RETURN
unity(index) = yloc: unitx(index) = xloc
terrain(index) = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
toa(index) = toa(0): uorder(index) = uorder(0)

strength(index) = strength(0)
name$(index) = name$(0): leader(index) = leader(0): morale(index) = morale(0)
unit$(index) = unit$(0)
strength(0) = 0

CALL SHOWUNIT(index)
GOSUB butt2
CALL clrlin(23): COLOR 13: PRINT name$(index); " UNZAPPED";

IF quiet > 0 THEN SOUND 2222, 1: SOUND 2000, 1: SOUND 2222, 1

PUT (8 * xloc, 14 * yloc), Xhair, XOR
CALL scoreboard(0)
RETURN

movem:
COLOR 13
LINE (461, 126)-(619, 139), 0, BF
unitx(index) = 74: unity(index) = 9
CALL clrlin(23)
COLOR 11: PRINT "Select new location for ";
COLOR 14: PRINT name$(index);
COLOR 11: PRINT " and press [ ENTER ]"
COLOR 14: LOCATE 10, 59: PRINT "MOVING Unit"; index
TICK 2
CALL SHOWUNIT(index)
CALL Tara(x, y + 1, terrain(index))
PUT (8 * xloc, 14 * yloc), Xhair, XOR
GOSUB iconx
GOSUB frash
IF quiet > 0 THEN SOUND 3000, .5
RETURN
newloc:
unity(stax) = yloc: unitx(stax) = xloc
CALL SHOWUNIT(stax)
CALL clrlin(23): COLOR 13: PRINT name$(stax); " moved to new location";
CALL repair
terrain(stax) = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
CALL scoreboard(0): stax = 0
stackflag = 0
IF quiet > 0 THEN SOUND 1999, .1
GOSUB frash
PUT (8 * xloc, 14 * yloc), Xhair, XOR
RETURN
END SUB

SUB randarm (allarm, rx)
COLOR 4: LOCATE 23, 1: PRINT "Placing armies ... "
CALL scoreboard(-1)
ratio! = TIMER
FOR side = 1 TO 2
IF side = 1 THEN xloc = 10: IF RND > .3 THEN xloc = 28: IF RND > .5 THEN xloc = 45
IF side = 1 THEN yloc = 6: IF RND > .3 THEN yloc = 10: IF RND > .5 THEN yloc = 14
IF xloc = 28 THEN yloc = 2: IF RND > .5 THEN yloc = 18
F$ = "rnames.dat": IF side = 2 THEN F$ = "ynames.dat"

IF side = 2 THEN xloc = 54 - xloc: yloc = 21 - yloc
IF side = 2 AND xloc = 28 GOTO not4
IF yloc = 11 AND RND > .5 THEN yloc = 4: IF RND > .5 THEN yloc = 17
COLOR 11: LOCATE 9, 58: PRINT " ELAPSED TIME (sec)  "
LOCATE 10, 58: PRINT SPACE$(21)
LINE (455, 110)-(622, 140), 4, B
not4:
FOR i = 1 TO allarm
	COLOR 15: LOCATE 10, 65: PRINT INT(TIMER - ratio!)
	IF INKEY$ <> "" GOTO walk
	spin = 0
	index = 40 * (side - 1) + i
coord:
	spin = spin + 1: IF spin > 99 GOTO walk
	unitx(index) = xloc - 10 + 20 * RND
	unity(index) = yloc - 8 + 16 * RND: IF xloc = 28 THEN unity(index) = yloc - 3 + 6 * RND
	IF unitx(index) < 2 THEN unitx(index) = 2
	IF unitx(index) > 54 THEN unitx(index) = 54
	IF unity(index) < 2 THEN unity(index) = 1
	IF unity(index) > 20 THEN unity(index) = 20

	GOSUB odd: IF flag = 0 GOTO chek2
	IF unitx(index) < 54 THEN unitx(index) = unitx(index) + 1: GOTO chek2
	IF unitx(index) > 2 THEN unitx(index) = unitx(index) - 1: GOTO chek2
	IF unity(index) < 20 THEN unity(index) = unity(index) + 1: GOTO chek2
	IF unity(index) > 1 THEN unity(index) = unity(index) - 1
chek2:
	z = ASC(MID$(sdtext$((unity(index) + 1)), unitx(index), 1))
	IF z = 32 OR z = 176 GOTO coord
	CALL whois(unitx(index), unity(index), Enemy, 0)
	IF Enemy > 0 GOTO coord

	armx = INT(7 * RND)

	IF side = 2 AND armx = 3 AND RND > .5 THEN armx = 4
	IF side = 1 AND armx = 4 AND RND > .5 THEN armx = 3
	IF armx = 5 AND RND > .2 THEN armx = 1
	IF (armx = 3 OR armx = 4) AND RND > .5 THEN armx = 1

	IF i = 1 THEN armx = 6
SELECT CASE armx
CASE IS < 2
	unit$(index) = "I":
	strength(index) = 450 + 100 * rx
	IF RND > .9 THEN strength(index) = 850 + 100 * rx: GOTO att1
	IF RND > .9 THEN strength(index) = 650 + 100 * rx
CASE 2
	unit$(index) = "C": strength(index) = 350 + 50 * rx
CASE 3
	unit$(index) = "N": strength(index) = 150 + 50 * rx
CASE 4
	unit$(index) = "A": strength(index) = 150 + 50 * rx
CASE 5
	unit$(index) = "H": strength(index) = 70 + 10 * rx
CASE 6
	unit$(index) = "G": strength(index) = 50 + 50 * rx
CASE ELSE
END SELECT

att1:

IF side = 1 THEN strength(index) = strength(index) - 150 + 50 * rx
IF side = 2 THEN strength(index) = strength(index) + 150 - 50 * rx
name$(index) = name$(index) + " " + STR$(index)
CALL namer(F$, a$): name$(index) = a$

z = ASC(MID$(sdtext$((unity(index) + 1)), unitx(index), 1))
terrain(index) = z
morale(index) = 70 + 20 * RND: leader(index) = 65 + 30 * RND
IF side = 1 AND RND > .5 THEN leader(index) = 80 + 30 * RND
IF LEFT$(unit$(index), 1) = "C" AND leader(index) < 80 THEN leader(index) = 80
uorder(index) = 0: toa(index) = 0
	IF RND > .9 AND LEFT$(unit$(index), 1) = "I" THEN uorder(index) = -1: GOTO count
	IF RND > .8 THEN toa(index) = 5 + 50 * RND: IF RND > .5 OR toa(index) > 15 THEN uorder(index) = 99
count:
CALL SHOWUNIT(index)
CALL scoreboard(1)
NEXT i

NEXT side
GOTO walk

odd:    flag = 0
	IF (unitx(index) + unity(index)) <> INT(.5 * (unitx(index) + unity(index))) * 2 THEN flag = 1
	RETURN

walk:
COLOR 14: LOCATE 23, 1: PRINT "Press Any Key ...  "
DO WHILE INKEY$ = "": LOOP: CLS
END SUB

SUB randmap
CLS
CALL startmap
CALL mainmap

mtx$(0) = "Water Hexes"
mtx$(1) = "NONE"
mtx$(2) = "Perhaps"
mtx$(3) = "YES"
tlx = 59: choose = 23: size = 3: CALL menu
r! = 0: IF choose = 2 THEN r! = .5
IF choose = 3 THEN r! = 1!
FOR k = 1 TO most: strength(k) = 0: NEXT k
CALL clrlin(23): PRINT "Creating Map ";
'============================================================================
'                            Place Terrain Features
'============================================================================
	IF RND < r! THEN
	rx = 1
	r! = .5 + .3 * RND
	CALL runto(176)
	END IF

	DO
	r! = .3 + .2 * RND * rx
	CALL terrane(r!, 61)
	LOOP UNTIL RND > .9 - .5 * rx

	DO
	r! = .8 + .2 * RND
	CALL terrane(r!, 42)
	LOOP UNTIL RND > .8

	r! = .8 + .2 * RND
	CALL terrane(r!, 94)
	r! = .3 + .2 * RND
	IF RND > .5 THEN CALL terrane(r!, 239): IF RND > .2 THEN CALL terrane(r!, 239)
	r! = .3 + .2 * RND

	DO
	IF RND > .2 THEN CALL terrane(r!, 254)
	LOOP UNTIL RND > .3

	DO
	r! = .6 + .2 * RND
	CALL terrane(r!, 58)
	LOOP UNTIL RND > .6
	IF RND > .5 THEN CALL terrane(.1, 35)

	tries = 0: x = 2 + INT(3 * RND)
	DO
	tries = tries + 1
	r! = .5 + .2 * RND
	CALL runto(43)
	LOOP UNTIL RND > .4 OR tries > x

	xloc = 4 + 50 * RND: yloc = 4 + 16 * RND
	IF (xloc + yloc) MOD 2 <> 0 THEN yloc = yloc + 1: IF yloc > 20 THEN yloc = yloc - 2

	CALL replace(yloc, xloc, 233)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR

	EXIT SUB
lim1:
	flag = 0
	IF xloc > 54 OR xloc < 2 THEN flag = 1
	IF yloc > 20 OR yloc < 1 THEN flag = 1
	RETURN
END SUB

SUB repair
LINE (453, 2)-(635, 299), 8, BF
END SUB

SUB replace (y, x, z)
CALL Tara(x, y + 1, z)
PUT (8 * x, 14 * y), Xhair, XOR
IF quiet > 0 THEN SOUND 1200, .1
a1$ = LEFT$(sdtext$(y + 1), x - 1)
a2$ = RIGHT$(sdtext$(y + 1), LEN(sdtext$(y + 1)) - x)
sdtext$(y + 1) = a1$ + CHR$(z) + a2$
CALL terra(z, a$)
CALL whois(x, y, Enemy, 0): IF Enemy > 0 THEN terrain(Enemy) = z: TICK .2: CALL SHOWUNIT(Enemy): PUT (8 * x, 14 * y), Xhair, XOR
IF repeat > 0 AND repeat <> z THEN repeat = z: COLOR 12: LOCATE 8, 62: PRINT "DUPLICATE ": CALL Tara(72, 8, z): SOUND 3100, .5
END SUB

SUB runto (z)
bridge = 0
IF RND > .5 THEN
	xloc = 2: yloc = 1 + 18 * RND
	IF RND > .5 THEN xloc = 54
	IF (xloc + yloc) MOD 2 <> 0 THEN yloc = yloc + 1
	x = 56 - xloc: y = 1 + 19 * RND
	IF (x + y) MOD 2 <> 0 THEN y = y + 1: IF y > 20 THEN y = y - 2
ELSE
	yloc = 1: xloc = 1 + 53 * RND
	IF RND > .5 THEN yloc = 20
	IF (xloc + yloc) MOD 2 <> 0 THEN xloc = xloc + 1
	x = 2 + 52 * RND: y = 21 - yloc
	IF (x + y) MOD 2 <> 0 THEN x = x + 1
END IF
runner:
	IF xloc < 2 OR xloc > 54 OR yloc < 1 OR yloc > 20 THEN EXIT SUB
	CALL replace(yloc, xloc, z)
	IF z = 176 AND RND > .995 + .2 * (bridge = 0) THEN CALL replace(yloc, xloc, 91): bridge = 1
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	dx = SGN(x - xloc): dy = SGN(y - yloc)
SELECT CASE dx
	CASE 0
		IF dy = 0 THEN EXIT SUB
		IF dx > 0 THEN
			xloc = xloc + dx: yloc = yloc + dy
		ELSE
			xloc = xloc + 1: IF xloc > 28 THEN xloc = xloc - 2
			yloc = yloc + dy
		END IF
	CASE ELSE
		IF dy = 0 OR RND > .6 THEN
			xloc = xloc + 2 * dx
		ELSE
			xloc = xloc + dx: yloc = yloc + dy
		END IF
END SELECT
GOTO runner
END SUB

SUB scoreboard (flag)
DIM numb(4)
s = 1: F = .5 * most
IF flag < 1 THEN
	LINE (453, 152)-(624, 280), 0, BF
	LINE (453, 152)-(624, 280), 4, B
	LINE (453, 230)-(624, 230), 4
END IF

recount:
total = 0: pow& = 0
FOR k = 1 TO 4: numb(k) = 0: NEXT k
FOR k = s TO F
IF strength(k) < 1 GOTO dead
	total = total + 1
	IF INSTR("I", unit$(k)) > 0 THEN numb(1) = numb(1) + 1
	IF INSTR("C", unit$(k)) > 0 THEN numb(2) = numb(2) + 1
	IF INSTR("AEBHNL", unit$(k)) > 0 THEN numb(3) = numb(3) + 1
	IF INSTR("G", unit$(k)) > 0 THEN numb(4) = numb(4) + 1
	pow& = pow& + strength(k)
dead:
NEXT k

IF s = .5 * most + 1 GOTO done5
COLOR 7: LOCATE 12, 63: PRINT "Rebel";
COLOR 11: LOCATE 13, 58: PRINT "INFNT ";
COLOR 7: PRINT numb(1);
COLOR 11: LOCATE 14, 58: PRINT "CAVLY ";
COLOR 7: PRINT numb(2);
COLOR 11: LOCATE 15, 58: PRINT "ARTLL ";
COLOR 7: PRINT numb(3);
COLOR 11: LOCATE 16, 58: PRINT "GENRL ";
COLOR 7: PRINT numb(4);
COLOR 11: LOCATE 18, 58: PRINT "UNITS ";
COLOR 7: IF total = 40 THEN COLOR 12
LOCATE 18, 64: PRINT total;
COLOR 11: LOCATE 19, 58: PRINT "STRNG ";
COLOR 7: PRINT pow&; : ratio! = pow&


s = .5 * most + 1: F = most: GOTO recount

done5:
COLOR 9: LOCATE 12, 71: PRINT "Union";
LOCATE 13, 72: PRINT numb(1);
LOCATE 14, 72: PRINT numb(2);
LOCATE 15, 72: PRINT numb(3);
LOCATE 16, 72: PRINT numb(4);
IF total = 40 THEN COLOR 12
LOCATE 18, 72: PRINT total;
COLOR 9: LOCATE 19, 72: PRINT pow&;
IF ratio! > 0 THEN ratio! = INT(10 * pow& / ratio!) * .1
IF ratio! > 999 THEN ratio! = 999
COLOR 14: LOCATE 20, 58: PRINT "Strength Ratio       ";
a$ = STR$(ratio!): IF LEN(a$) > 5 THEN a$ = LEFT$(a$, 5)
LOCATE 20, 72: PRINT a$
END SUB

SUB SHOWUNIT (index)
	IF strength(index) < 1 THEN EXIT SUB
		y = 14 * unity(index): x = 8 * unitx(index)
		a = ASC(LEFT$(unit$(index), 1))
		IF uorder(index) = 99 THEN a = 120

		SELECT CASE a
		CASE 65   'Artillery
		IF index > 40 THEN PUT (x, y), Aunion, PSET ELSE PUT (x, y), Areb, PSET
		CIRCLE (x + 6, y + 6), 3, 0
		CIRCLE (x + 6, y + 6), 4, 0
		CASE 66   'Boat
		PUT (x, y), Boat, PSET
		CASE 67   'Cavalry
		IF index > 40 THEN PUT (x, y), Cunion, PSET ELSE PUT (x, y), Creb, PSET
		CASE 69   'Emplacement (Gun)
		LINE (x, y)-(x + 14, y + 13), 0, BF
		IF index < 41 THEN
			LINE (x, y)-(x + 12, y + 12), 7, BF
			LINE (x, y)-(x + 12, y + 12), 4, B
			c = 4
		ELSE
			LINE (x, y)-(x + 12, y + 12), 1, BF
			LINE (x, y)-(x + 12, y + 12), 9, B
			c = 9
		END IF
		LINE (x + 3, y + 4)-(x + 9, y + 9), 0, B
		LINE (x + 4, y + 5)-(x + 8, y + 8), c, BF
		CASE 71   'General
		IF index > 40 THEN PUT (x, y), Gunion, PSET ELSE PUT (x, y), Greb, PSET
		CASE 72   'Horse Artillery
		IF index > 40 THEN PUT (x, y), Aunion, PSET ELSE PUT (x, y), Areb, PSET
		c = 4: IF index > 40 THEN c = 15
		LINE (x + 1, y + 11)-(x + 11, y + 1), c
		CASE 73   'Infantry
		IF index > 40 THEN PUT (x, y), Iunion, PSET ELSE PUT (x, y), Ireb, PSET
		CASE 76 'Limbered Artillery
		IF index > 40 THEN PUT (x, y), Aunion, PSET: c = 9 ELSE PUT (x, y), Areb, PSET: c = 7
		CIRCLE (x + 6, y + 6), 5, 0
		PAINT (x + 6, y + 6), c, 0
		CASE 78   'Napoleon Artillery
		IF index > 40 THEN PUT (x, y), Aunion, PSET ELSE PUT (x, y), Areb, PSET
		CASE 88   'Death
		PUT (x, y), Death, PSET: unit$(index) = "DEAD"
		CASE 119   'wait
		IF index < 41 THEN
			LINE (x, y)-(x + 15, y + 13), 4, BF
			LINE (x, y)-(x + 15, y + 13), 7, B
		ELSE
			LINE (x, y)-(x + 15, y + 13), 9, BF
			LINE (x, y)-(x + 15, y + 13), 1, B
		END IF
		CASE 120 'delayed
		c = 4: IF index > 40 THEN c = 9
		LINE (x, y)-(x + 15, y + 13), 0, BF
		LINE (x, y)-(x + 15, y + 13), 2, B
		LINE (x + 3, y + 3)-(x + 11, y + 10), c, BF
		CASE 232   'Charge Infantry
		IF index > 40 THEN PUT (x, y), Iunion, PSET: c = 15:                          ELSE PUT (x, y), Ireb, PSET: c = 4
		CIRCLE (x + 6, y + 6), 4, c
		CASE ELSE
		END SELECT
END SUB

SUB startmap
	sdtext$(1) = "�" + STRING$(53, "�") + "�"
	sdtext$(2) = "� . . . . . . . . . . . . . . . . . . . . . . . . . . �"
	sdtext$(3) = "�. . . . . . . . . . . . . . . . . . . . . . . . . . .�"
	sdtext$(22) = "�" + STRING$(53, "�") + "�"
	sdtext$(23) = ""
	sdtext$(24) = ""
	FOR k = 4 TO 20 STEP 2
	sdtext$(k) = sdtext$(2)
	sdtext$(k + 1) = sdtext$(3)
	NEXT k
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
	CASE 91
	PUT (z, c), bridge, PSET
	CASE 94
	PUT (z, c), Hterr, PSET
	CASE 126
	PUT (z, c), Cterr, PSET
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

SUB terra (k, a$)
		SELECT CASE k
		CASE 35
		a$ = "Fort"
		CASE 42
		a$ = "trees"
		CASE 43
		a$ = "road "
		CASE 46
		a$ = "clear"
		CASE 61
		a$ = "swamp"
		CASE 91
		a$ = "Bridge"
		CASE 94
		a$ = "hill"
		CASE 176
		a$ = "water"
		CASE 233
		a$ = "OBJCTV"
		CASE 239
		a$ = "mtn"
		CASE 254
		a$ = "village"
		CASE ELSE
		a$ = CHR$(k) + "Unknown"
		END SELECT
END SUB

SUB terrane (r!, rx)
morefeat:
	tries = 0
	GOSUB rloc
moreterr:
	tries = tries + 1: IF tries > 20 GOTO endterr
	GOSUB nearhere: GOSUB lim2: IF flag = 1 GOTO endterr
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1)): IF z <> 46 GOTO moreterr
	CALL replace(yloc, xloc, rx)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	IF RND < r! GOTO moreterr
endterr:
	IF tries < 20 AND RND < r! GOTO morefeat
	EXIT SUB
'............................................................................
rloc:
	xloc = 4 + 50 * RND: yloc = 4 + 16 * RND
	IF (xloc + yloc) MOD 2 <> 0 THEN GOSUB adjx
	RETURN
nearhere:
x = 8 * RND
SELECT CASE x
	CASE 1
	xloc = xloc - 1: yloc = yloc - 1
	CASE 2
	yloc = yloc - 1
	CASE 3
	xloc = xloc - 1: yloc = yloc - 1
	CASE 4
	xloc = xloc - 2
	CASE 5
	xloc = xloc + 2
	CASE 6
	xloc = xloc - 1: yloc = yloc + 1
	CASE 7
	yloc = yloc + 1
	CASE 8
	xloc = xloc - 1: yloc = yloc + 1
	CASE ELSE
	xloc = 54
	IF RND < r! THEN GOSUB rloc
END SELECT
	IF xloc < 1 THEN xloc = 1
	IF yloc > 21 THEN yloc = 21
	IF xloc > 54 THEN xloc = 54
	IF yloc < 1 THEN yloc = 1
	GOSUB adjx
	RETURN
adjx:
	IF (xloc + yloc) MOD 2 = 0 THEN RETURN
	IF xloc > 2 THEN xloc = xloc - 1: RETURN
	IF xloc < 54 THEN xloc = xloc + 1: RETURN
lim2:
	flag = 0
	IF xloc > 54 OR xloc < 2 THEN flag = 1
	IF yloc > 20 OR yloc < 1 THEN flag = 1
	RETURN

END SUB

SUB TICK (r!)
t! = TIMER
DO WHILE TIMER - t! < r! AND INKEY$ = "": LOOP
END SUB

SUB title
COLOR 0, 5: CLS
COLOR 15, 5: LOCATE 8, 12: PRINT "�"; : COLOR 7, 0: PRINT STRING$(55, "�"); : PRINT "  "
FOR k = 9 TO 15: COLOR 15, 5: LOCATE k, 12: PRINT "�"; : COLOR 7, 0: PRINT "�  ": LOCATE k, 67: PRINT "�  ": NEXT k
COLOR 15, 5: LOCATE 16, 12: PRINT "�"; : COLOR 7, 0: PRINT STRING$(55, "�"); : PRINT "  "

COLOR 5, 0
LOCATE 9, 15: PRINT STRING$(52, "  ")
LOCATE 17, 13: PRINT STRING$(57, "  ")
COLOR 15, 5
LOCATE 7, 12: PRINT STRING$(56, "�")
LOCATE 15, 16: PRINT STRING$(51, "�")
FOR k = 10 TO 15: LOCATE k, 66: PRINT "�": NEXT k

COLOR 15, 1: LOCATE 11, 27: PRINT "�  the AMERICAN CIVIL WAR  �": PRINT
COLOR 15, 4: LOCATE 13, 30
PRINT " Editor MODULE  v2.4"
LOCATE 22, 60: PRINT "(c) 1995 W.R Hutsell";
LOCATE 20, 33: COLOR 11, 0: PRINT "(REQUIRES EGA)"
LOCATE
TICK 99
END SUB

SUB whois (x, y, Enemy, index)
Enemy = 0
FOR k = 1 TO most
IF strength(k) > 0 AND x = unitx(k) AND y = unity(k) THEN Enemy = k: EXIT SUB
NEXT k
END SUB

