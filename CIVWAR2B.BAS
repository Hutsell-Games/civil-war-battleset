DEFINT A-Z
DECLARE SUB Bubble (limit%)
DECLARE SUB codex (flag%, index%, a$, t$)
DECLARE SUB commander (x%)
DECLARE SUB dirge ()
DECLARE SUB ishi (x%)
DECLARE SUB rank (k%, dx%, t$)
REM $INCLUDE: 'civ20.bi'

SUB area (F%)
IF F = 0 THEN F = 19
SCREEN 9
CLOSE #1
OPEN "I", 1, "campaign.ini"
FOR k = 1 TO F
INPUT #1, a
	FOR j = 1 TO 6
	INPUT #1, matrix(k, j)
	NEXT j
INPUT #1, ry(k), rx(k), region$(k)
'...........................................................................
	c = 8
	IF region(k) > 0 THEN
		c = 4
		IF region(k) = 2 THEN c = 9
		PAINT (rx(k) * 8, ry(k) * 14), c, 10
	END IF
	COLOR c
	LOCATE ry(k), rx(k): PRINT region$(k);
	IF k = 2 OR k = 6 THEN PRINT "*"
'...........................................................................
INPUT #1, x
mtx$(0) = STR$(x)
	IF x > 0 THEN
		IF x > 6 THEN PRINT "ERROR IN CAMPAIGN.INI-" + region$(k) + " has more than the maximum 6 battle scenarios": END
		FOR j = 1 TO x
		INPUT #1, mtx$(j)
		NEXT j
	END IF
NEXT k
CLOSE #1
END SUB

SUB ATTENTION (index, c)
IF (recon = 0 AND Visible(index) = 0) OR uorder(index) = 99 THEN EXIT SUB
y = 14 * unity(index): x = 8 * unitx(index)
LINE (x, y)-(x + 15, y + 13), c, BF: TICK .1
CALL SHOWUNIT(index): TICK .05
END SUB

SUB Bubble (limit)
DO
	swaps% = FALSE
	FOR i = 1 TO limit - 1
	IF mtx$(i) > mtx$(i + 1) THEN
		SWAP mtx$(i), mtx$(i + 1)
		SWAP array(i), array(i + 1)
		swaps% = i
	END IF
	NEXT i
LOOP WHILE swaps%
END SUB

SUB BuffClear
DEF SEG = 0
POKE 1050, 30: POKE 1052, 30
END SUB

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

SUB camess (s, y)
y = 0: IF campane < 13 THEN y = 12
COLOR 7, 0: LOCATE 11 + y, 13: PRINT SPACE$(60)
FOR k = 8 TO 10: LOCATE k + y, 70: PRINT "   ": NEXT k
COLOR 4: IF s = 2 THEN COLOR 9
FOR k = 7 TO 10
LOCATE k + y, 10: PRINT STRING$(60, "°")
NEXT k
LOCATE 8 + y
END SUB

SUB campaign
COLOR 7: IF camwin = 2 THEN COLOR 9
CALL cmap: CALL area(0)
IF campane > 0 GOTO cmp
IF choose = 99 THEN choose = 1: GOTO cmp
mtx$(0) = "CAMPAIGN"
mtx$(1) = "Continue OLD": IF LEN(DIR$("regions.sav")) = 0 THEN choose = 2: GOTO cmp
mtx$(2) = "Begin NEW"
tlx = 60: tly = 18
size = 2: CALL menu
IF choose < 0 THEN EXIT SUB
cmp:
x = 44 + 3 * difficult
LINE (515, 265)-(635, 325), 0, BF
LINE (515, 265)-(635, 325), 5, B
COLOR 11
LOCATE 20, 66: PRINT "VICTORY SCORES"
LOCATE 21, 66: PRINT "Neutral  50%"
LOCATE 22, 66: PRINT "Occupied"; x; "%";
LOCATE 23, 66: PRINT "Capitals"; x + 5; "%"
'...........................................................................
t$ = "regions.ini": IF choose = 1 THEN a$ = "regions.sav": IF LEN(DIR$(a$)) > 0 THEN t$ = a$
CLOSE #1
OPEN "I", 1, t$
z = 0: y = 0
INPUT #1, camwin
FOR k = 1 TO 19
INPUT #1, region(k)
IF region(k) = 1 THEN z = z + 1
IF region(k) = 2 THEN y = y + 1
NEXT k
CLOSE #1
IF z > 9 OR y > 9 THEN
SCREEN 0
DEF SEG = &HB800
BLOAD "victory.scr", 0
DEF SEG
c = 4: s = 1: IF y > 9 THEN s = 2: c = 1
COLOR 15, c: FOR k = 7 TO 12: LOCATE k, 20: PRINT SPACE$(40): NEXT k
LOCATE 7, 21: PRINT STRING$(38, "Í")
LOCATE 12, 21: PRINT STRING$(38, "Í")
LOCATE 9: center (sname$(s) + " side has won the war !")
COLOR 7, 0: LOCATE 13, 21: PRINT SPACE$(40)
FOR k = 8 TO 12: LOCATE k, 60: PRINT " ": NEXT k
campane = 0
IF quiet > 0 THEN
	IF sblast$ = "" THEN
		PLAY "T140O3L8C;FCFG;A4GMLA16mnB-16;O4CO3FL16MLAMNGMLFMNEL8;F4.C"
		PLAY "FCFG;A4GMLA16MNB-16;O4CO3FMLA16MNG16MLF16MNE16;F4P8MLA16MNB-16"
		PLAY "O4C.D16CO3B-;MLA.MNB-16O4CO3F;O4D.D16MLC16MNO3B-16MLA16MNG16;MLF4MNEC16C16"
		PLAY "FCFG;A4GMLA16MNB-16;O4CO3FMLA16MNG16MLF16MNE16;F4P2"
	ELSE
		CALL trumpet(1 + m1 * (s - 1))
	END IF
END IF
TICK 999
KILL "regions.sav"
SCREEN 9
EXIT SUB
END IF
'...........................................................................
CALL area(0)
COLOR 4: IF side = 2 THEN COLOR 9
x = INT(52.632 * z + .5) * .1

LINE (518, 206)-(628, 260), 0, BF
LINE (518, 206)-(628, 260), 15, B
COLOR 15
a = z: IF camwin = 2 THEN a = y
LOCATE 16, 69: PRINT "CONTROL"
LOCATE 17, 66: PRINT a; "Regions"
LOCATE 18, 69: PRINT "("; x; "%)"
'...........................................................................
batreg:
IF difficult > 3 THEN camwin = 0
IF camwin = 0 THEN camwin = 1: IF RND > .5 THEN camwin = 2
CALL icon(70, 10, camwin)

tlx = 2: tly = 1: size = 0
FOR k = 1 TO 19
	IF region(k) <> camwin THEN
		FOR j = 1 TO 6
		ndx = matrix(k, j)
		IF ndx > 0 THEN
			IF region(ndx) = camwin THEN
				FOR i = 1 TO size
				IF mtx$(i) = region$(k) GOTO dupe
				NEXT i
			size = size + 1
			mtx$(size) = region$(k)
			array(size) = k
			END IF
		END IF
dupe:
		NEXT j
	END IF
NEXT k
mtx$(0) = sname$(camwin) + " Move"
'............................................................................
'                               computer move
'............................................................................
IF nplayer = 0 AND camwin <> side THEN
rhett:
	choose = 1 + INT(RND * size)
	IF region(array(choose)) = 3 - side GOTO rhett
	CALL camess(camwin, y)
	COLOR 15

	campane = array(choose)
	CALL center("COMPUTER " + sname$(camwin) + " forces are moving into " + region$(array(choose)))
	TICK 99
	CALL cmap
	GOTO horses
END IF
'............................................................................
'                               human move
'............................................................................
CALL Bubble(size)
colour = 7: IF camwin = 2 THEN colour = 9
CALL icon(585, 140, camwin)
TICK 3
CALL menu
IF choose < 1 THEN campane = 0: EXIT SUB
horses:
	campane = array(choose)
	IF campane < 1 OR campane > 19 GOTO batreg
	IF region(campane) = 0 THEN
		cscore = 50
	ELSE
		x = 0: IF (campane = 2 AND region(campane) = 2) OR (campane = 6 AND region(campane) = 1) THEN x = 5
		cscore = 44 + 3 * difficult + x
	END IF

CALL area(campane)
x = VAL(mtx$(0))
IF x = 0 OR RND > .95 THEN
randfile:
	a$ = ""
	FOR k = 1 TO 25
	t$ = "camp0" + LTRIM$(RTRIM$(STR$(INT(10 * RND)))) + ".civ"
	IF LEN(DIR$(t$)) > 0 THEN a$ = t$: EXIT FOR
	NEXT k
	IF LEN(a$) = 0 THEN a$ = "$ave1.civ"
	file$ = a$
ELSE
    x = RND * x + .5
    file$ = mtx$(x)
    IF LEN(file$) < 4 OR UCASE$(RIGHT$(file$, 4)) <> ".CIV" GOTO randfile
    IF LEN(DIR$(file$)) = 0 THEN GOTO randfile
END IF
CLOSE #1
EXIT SUB
END SUB

SUB campy (campane, flag)
	CIRCLE (8 * rx(campane) + 28, 14 * ry(campane) - 8), 45, 15, , , .3
	LOCATE ry(campane), rx(campane) + 1: COLOR 15
	a$ = "W A R !": IF flag > 0 THEN a$ = "VICTORY"
	PRINT a$
	c = 8: IF camwin = 2 THEN c = 1
	PAINT (8 * rx(campane) + 30, 14 * ry(campane)), c, 15
END SUB

SUB center (a$)
x = 40 - .5 * LEN(a$)
LOCATE , x: PRINT a$
END SUB

SUB clrbot
LOCATE 23, 1: PRINT SPACE$(80); : LOCATE 23, 1
END SUB

SUB cmap
	LINE (0, 0)-(639, 349), 2, BF
	LINE (0, 0)-(638, 349), 10, B
	COLOR 10
	LINE (410, 349)-(389, 320): LINE -(338, 322): LINE -(333, 330): LINE -(272, 334)
	LINE -(266, 329): LINE -(265, 328): LINE -(210, 322): LINE -(98, 326)
	LINE -(81, 338): LINE -(106, 343): LINE -(113, 338): LINE -(118, 338)
	LINE -(118, 343): LINE -(123, 342): LINE -(123, 349)
	LINE (619, 0)-(609, 28): LINE -(602, 27): LINE -(603, 21): LINE -(591, 13)
	LINE -(589, 6): LINE -(588, 25): LINE -(594, 30): LINE -(604, 35)
	LINE -(602, 57): LINE -(589, 66): LINE -(577, 76): LINE -(578, 76)
	LINE -(581, 59): LINE -(574, 48): LINE -(574, 34): LINE -(579, 28)
	LINE -(579, 22): LINE -(566, 24): LINE -(562, 38): LINE -(567, 64)
	LINE -(553, 61): LINE -(554, 61): LINE -(566, 67): LINE -(568, 74)
	LINE -(551, 71): LINE -(566, 78): LINE -(566, 86): LINE -(553, 87)
	LINE -(566, 91): LINE -(581, 94): LINE -(584, 112): LINE -(567, 115)
	LINE -(582, 119): LINE -(583, 129): LINE -(570, 132): LINE -(568, 127)
	LINE -(565, 130): LINE -(564, 130): LINE -(573, 138): LINE -(573, 143)
	LINE -(551, 150): LINE -(537, 175): LINE -(509, 199): LINE -(498, 235)
	LINE -(487, 239): LINE -(497, 246): LINE -(491, 279): LINE -(509, 322)
	LINE -(506, 327): LINE -(508, 335): LINE -(510, 325): LINE -(517, 340)
	LINE -(525, 349)
	PAINT (600, 250), 1, 10
	PAINT (300, 340), 1, 10
	COLOR 10
	LINE (150, 324)-(150, 240): LINE -(0, 240): LINE (0, 280)-(150, 280)
	LINE (150, 290)-(290, 290): LINE -(300, 331)
	LINE (150, 240)-(290, 240): LINE -(290, 290)
	LINE (390, 320)-(390, 230): LINE -(290, 230): LINE -(290, 240)
	LINE (390, 270)-(492, 270)
	LINE (390, 230)-(390, 185): LINE -(420, 185): LINE -(420, 175): LINE -(538, 175)
	LINE (140, 240)-(140, 190): LINE -(290, 190): LINE -(290, 240)
	LINE (290, 210)-(290, 140): LINE -(420, 140): LINE -(420, 175)
	LINE (420, 140)-(430, 110): LINE -(583, 110)
	LINE (430, 110)-(430, 60): LINE -(553, 60)
	LINE (140, 190)-(140, 140): LINE -(160, 120): LINE -(290, 120): LINE -(290, 140)
	LINE (0, 180)-(140, 180)
	LINE (0, 100)-(160, 100): LINE -(160, 120)
	LINE (430, 60)-(310, 60): LINE -(290, 80): LINE -(290, 120)
	LINE (160, 100)-(160, 0)
	LINE (450, 60)-(450, 30), 10: LINE -(565, 30)
	LINE (450, 30)-(390, 30): LINE -(390, 0)
	LINE (310, 0)-(310, 60)
	PAINT (50, 50), 8, 10
	COLOR 15: LOCATE 7, 5: PRINT "CAMPAIGN GAME"
END SUB

SUB codex (flag, index, a$, t$)
SELECT CASE flag
CASE 1                  '....... encode
	t$ = ""
FOR k = 1 TO LEN(a$)
	x = ASC(MID$(a$, k, 1))
	x = x + timelimit MOD 7 + k + index MOD 9
	IF x > 255 THEN x = x - 255
	chksum& = chksum& + x
	t$ = t$ + CHR$(x)
NEXT k

CASE 2                  '........ decode
	t$ = ""
FOR k = 1 TO LEN(a$)
	x = ASC(MID$(a$, k, 1))
	chksum& = chksum& + x
	x = x - timelimit MOD 7 - k - index MOD 9
	IF x < 0 THEN x = x + 255
	t$ = t$ + CHR$(x)
NEXT k
END SELECT

END SUB

SUB combat (index, Enemy)
IF Enemy = 0 OR uorder(index) = 99 OR index = Enemy THEN GOTO cancel2
tlx = 60: tly = 3: colour = 12
mtx$(0) = "COMBAT MENU"
mtx$(1) = "Light Skirmish"
mtx$(2) = "Medium Fight"
mtx$(3) = "Heavy Attack"
mtx$(4) = "All-out Assault"
a$ = LEFTY$(index)

IF Visible(index) < 1 THEN Visible(index) = 1: SHOWUNIT (index)
CALL YouorMe(index, flag): IF flag > 0 AND automatic = 0 GOTO manual

roll! = mdly!
pct# = strength(index) / strength(Enemy) + .1 * bold - .3
IF terrain(Enemy) = 94 THEN pct# = .6 * pct#
IF terrain(Enemy) = 239 THEN pct# = .4 * pct#
IF terrain(Enemy) = 61 THEN pct# = 1.2 * pct#
IF terrain(Enemy) = 42 THEN pct# = .8 * pct#
IF terrain(Enemy) = 254 THEN pct# = .8 * pct#
IF terrain(Enemy) = 35 OR terrain(index) = 35 THEN pct# = .5 * pct#
IF terrain(Enemy) = 233 THEN pct# = 2 * pct#
CALL valid(Enemy)
pct# = pct# * (morale(index) / morale(Enemy)) * (leader(index) / leader(Enemy))
d = 2 * ABS(unity(index) - objy) + ABS(unitx(index) - objx)
IF possess <> 3 - side AND d < seelimit THEN IF pct# < 1 THEN pct# = pct# + .3
CALL proximity(attack, 0, 0, bonus): IF bonus > 5 THEN pct# = pct# + .1

SELECT CASE pct#
	CASE IS > 2
	choose = 4
	CASE IS > 1.5
	choose = 3
	CASE IS > 1
	choose = 2
	CASE IS > .4
	choose = 1
	CASE ELSE
	dxs = SGN(unitx(index) - unitx(Enemy)): dys = SGN(unity(index) - unity(Enemy))
	uorder(index) = 100 * (unity(index) + dys) + unitx(index) + dxs
	GOTO cancel2
END SELECT

IF terrain(Enemy) = 233 THEN choose = choose + 1: IF timelimit - timex < 10 THEN choose = 4
IF leader(index) < 60 THEN choose = 3 - INT(2 * RND)
IF morale(index) < 60 THEN choose = choose - 1
IF RND > .9 THEN choose = choose - 1: IF RND < .5 THEN choose = choose + 2
IF bold > 3 AND RND > .7 THEN choose = choose + 1: IF bold = 5 AND RND > .5 THEN choose = 4
IF bold < 3 AND RND > .5 THEN choose = choose - 1: IF bold = 1 AND RND > .5 THEN choose = 1
IF a$ = "G" THEN choose = choose - 1
IF INSTR("AEHNB", a$) THEN CALL cannon(index, Enemy): GOTO cancel2
IF d < .3 * seelimit THEN choose = choose + 1
IF timelimit - timex < 20 AND possess <> 3 - side THEN choose = choose + 1

IF choose > 4 THEN choose = 4
IF choose < 1 THEN GOTO cancel2
CALL inspect(Enemy)
CALL sndblst("drums3")
GOTO tally

manual:
IF automatic = 1 GOTO tally
LITEUP 8 * unitx(index), 14 * unity(index), 14
LITEUP 8 * unitx(Enemy), 14 * unity(Enemy), 12

roll! = .1

x = INT(strength(Enemy) / 100) - 1 + 2 * RND
x = x * 100: IF x < 100 THEN x = 50
r! = strength(index) / x
COLOR 11: CALL clrbot: PRINT name$(index); " vs."; name$(Enemy); "  Str:"; x;
COLOR 10: IF r! < 1 THEN COLOR 12
SELECT CASE r!
	CASE IS < .67: x = 1: y = 1 / r!
	CASE IS < .8: x = 2: y = 3
	CASE IS < .9: x = 4: y = 5
	CASE IS < 1.3: x = 1: y = 1
	CASE IS < 1.6: x = 3: y = 2
	CASE ELSE: x = r!: y = 1
END SELECT
PRINT "  Ratio ="; x; ":"; y; " ";
COLOR 11: PRINT "  Terrain ="; : x = POS(0)
CALL Tara(x, 23, terrain(Enemy))
size = 4
CALL menu
CALL scrcol(1)
CALL inspect(index)

tally:
IF choose = -1 XOR choose = 99 THEN GOTO cancel2
LITEUP 8 * unitx(index), 14 * unity(index), 14
LITEUP 8 * unitx(Enemy), 14 * unity(Enemy), 12

s = 1: IF index > m1 THEN s = 2

CALL clrbot: COLOR 12
IF LEFTY$(index) = "C" AND (terrain(index) = 46 OR terrain(index) = 43) AND (terrain(Enemy) = 46 OR terrain(Enemy) = 43) THEN
	COLOR 14
	PRINT sname$(s); " "; name$(index); " CALVARY CHARGE vs. "; name$(Enemy)
	IF quiet > 0 THEN
		IF sblast$ = "" THEN
		PLAY "MBMST170o3c16.c16c16.c16c16.c16g16.e16g16.e16g16.e16c1MN"
		ELSE
		CALL sndblst("charge")
		END IF
	END IF
ELSE
  PRINT sname$(s); " Unit : "; name$(index); " => "; RTRIM$(mtx$(choose)); " vs. "; name$(Enemy);
END IF
IF quiet = 0 THEN TICK mdly!

pct# = .25 * choose
IF LEFTY$(Enemy) = "è" THEN unit$(Enemy) = "Infantry"
CALL musket(index, Enemy, pct#)
GOTO cancel2

cancel2:
CALL SHOWUNIT(Enemy)
IF RND > .05 + .15 * difficult THEN uorder(index) = 0
END SUB

SUB commander (x)
	IF LEN(file$) < 4 THEN EXIT SUB
	IF history = 0 OR nplayer = 2 THEN EXIT SUB
	SCREEN 9
	CLS
	LINE (0, 0)-(639, 14), 4, BF
	LOCATE 1, 20: PRINT "CIVILWAR BATTLESET HALL OF FAME"
	LOCATE 1, 68: PRINT .1 * x; "%"
	COLOR 14: LOCATE 3, 1: PRINT "ESC to enter NEW GENERAL"
	OPEN "I", 1, "generalz"
	LINE INPUT #1, u$
	k = 0
	DO WHILE NOT EOF(1)
	k = k + 1
	INPUT #1, mtx$(k), dx, x1, dy, z

	IF side = 1 THEN
		IF dx > 0 THEN pct# = (.1 * dx * x1) / dx * 10
		x1 = CINT(pct#)
	ELSE
		IF dy > 0 THEN pct# = (.1 * dy * z) / dy * 10
		z = CINT(pct#)
	END IF
	IF LEN(mtx$(k)) < 12 THEN a$ = SPACE$(12 - LEN(mtx$(k)))
	mtx$(k) = mtx$(k) + a$ + STR$(CINT(pct#) * .1) + "%"

	IF k > 19 THEN EXIT DO
	LOOP
	CLOSE #1
	colour = 7: a$ = "Rebel": IF side = 2 THEN a$ = "Union": colour = 9
	mtx$(0) = a$ + " Generals of Merit"
	size = k: IF size = 0 GOTO idhim
	CALL menu
	IF choose > 0 THEN
		a = INSTR(mtx$(choose), " ")
		t$ = LTRIM$(LEFT$((RTRIM$(UCASE$(mtx$(choose)))), a - 1))
		GOTO bingo
	END IF
idhim:
	COLOR 11: LOCATE 3, 1: PRINT "Your name >"
	t$ = ""
validid:
	COLOR 14
	CALL Enput(t$, 12, 3, 30, "")
	COLOR 11, 1: LOCATE 5, 1
	t$ = LTRIM$(RTRIM$(UCASE$(t$)))
	IF t$ = "" GOTO validid
	CLOSE #1
bingo:
	OPEN "I", 1, "generalz"
	LINE INPUT #1, u$
	DO WHILE NOT EOF(1)
	INPUT #1, a$, dx, x1, dy, z
	IF a$ = t$ GOTO matched
	LOOP
	a$ = t$
	PRINT "Welcome New General "; a$; " to the CWBS Hall of Fame !"
	dx = 0: dy = 0: x1 = 0: z = 0: flag = 1
matched:
	CLOSE #1

	IF side = 1 THEN
		pct# = (.1 * dx * x1 + .1 * x) / (dx + 1) * 10
		x1 = CINT(pct#)
	ELSE
		pct# = (.1 * dy * z + .1 * x) / (dy + 1) * 10
		z = CINT(pct#)
	END IF

	IF side = 1 THEN
		dx = dx + 1
	ELSE
		dy = dy + 1
	END IF

	COLOR 14: LOCATE 7, 1: PRINT STRING$(80, "Í")
	LINE (400, 120)-(610, 220), 4, BF
	LINE (400, 120)-(610, 220), 15, B
	LINE (410, 130)-(600, 168), 1, BF
	LINE (410, 172)-(600, 210), 7, BF
	LOCATE 7, 35: PRINT "   "; a$; "    "
	COLOR 11: LOCATE 10, 1
	PRINT "	Games played - Union side :"; dy
	PRINT "	Average Union Game Score  :"; .1 * z; "%"; : y = CSRLIN
	LOCATE y, 55
	CALL rank(dy, (z), t$): PRINT t$

	COLOR 15: LOCATE 13, 1
	PRINT "	Games played - Rebel side :"; dx
	PRINT "	Average Rebel Game Score  :"; .1 * x1; "%"; : y = CSRLIN
	LOCATE y, 55
	CALL rank(dx, (x1), t$): PRINT t$

	COLOR 14: LOCATE 16, 1
	PRINT "	Total Games Played        :"; dx + dy

	r! = (.1 * dx * x1 + .1 * dy * z) / (dx + dy) * 10
	a = r!
	PRINT "	Average Overall Game Score:"; .1 * a; "%"
	IF sblast$ <> "" THEN CALL sndblst("drums3")

	LOCATE 20, 1: PRINT "press a key"; : TICK 99

	IF flag = 1 THEN OPEN "A", 1, "generalz": WRITE #1, a$, dx, x1, dy, z: CLOSE #1: EXIT SUB
	SHELL "copy generalz temp.$$$"
	OPEN "I", 1, "temp.$$$"
	OPEN "O", 2, "generalz"
	LINE INPUT #1, u$
	PRINT #2, u$

	DO WHILE NOT EOF(1)
	INPUT #1, t$, dxs, a, dys, c
	IF t$ <> a$ THEN
		WRITE #2, t$, dxs, a, dys, c
	ELSE
		WRITE #2, a$, dx, x1, dy, z
	END IF
	LOOP

	CLOSE #1: CLOSE #2
	KILL "temp.$$$"
	EXIT SUB
END SUB

SUB Compact (flag)
s = 1: F = m1: IF flag = 2 THEN s = m2: F = most
	FOR k = s TO F - 1
IF strength(k) > 0 GOTO occupy
	FOR j = k + 1 TO F
	IF strength(j) = 0 GOTO slider
	name$(k) = name$(j)
	unit$(k) = unit$(j)
	morale(k) = morale(j)
	leader(k) = leader(j)
	strength(k) = strength(j)
	unitx(k) = unitx(j)
	unity(k) = unity(j)
	terrain(k) = terrain(j)
	toa(k) = toa(j)
	uorder(k) = uorder(j)
	Visible(k) = Visible(j)
	strength(j) = 0: GOTO occupy
slider:
	NEXT j
occupy:
	NEXT k
FOR k = s TO F: IF strength(k) = 0 THEN Bigg(flag) = k - 1: EXIT SUB
NEXT k
Bigg(flag) = F
END SUB

SUB cupdate (index)
IF strength(index) < 1 OR uorder(index) = 99 OR uorder(index) < 1 THEN EXIT SUB
	t$ = LEFTY$(index)
	IF limber = 1 AND INSTR("ANH", t$) THEN uorder(index) = 0: EXIT SUB
	y = INT(uorder(index) / 100): x = uorder(index) - 100 * y
	ynew = unity(index): xnew = unitx(index)
	dx = ABS(x - unitx(index)): dy = ABS(y - unity(index))
	IF dx + dy <> 0 GOTO notdone
	CALL YouorMe(index, F): IF F > 0 THEN CALL flash(index, 1)
	uorder(index) = 0: GOTO slide
notdone:
'..............................method 1 (direct route)......................
	IF ABS(unitx(index) - objx) + ABS(unity(index) - objy) > seelimit AND RND > .2 GOTO method2
	CALL Near2(index, Enemy, d)
	IF d > 7 AND RND > .5 GOTO method2
	dxs = SGN(x - unitx(index)): dys = SGN(y - unity(index))
	IF dy > 0 THEN ynew = unity(index) + dys: xnew = unitx(index) + dxs: z = SCREEN(ynew + 1, xnew): IF z = 43 OR z = 46 OR z = 233 OR z = 254 THEN GOTO slide
	IF t$ = "B" AND z = 176 GOTO slide
	IF dy = 0 THEN xnew = unitx(index) + 2 * dxs: z = SCREEN(ynew + 1, xnew): IF z = 35 OR z = 43 OR z = 46 OR z = 233 OR z = 254 THEN GOTO slide
	IF t$ = "B" AND z = 176 GOTO slide
	ynew = unity(index): xnew = unitx(index)
	IF RND > .4 AND dx > dy THEN xnew = unitx(index) + 2 * dxs: GOTO slide
	IF dy > 0 AND dx > 0 THEN ynew = unity(index) + dys: xnew = unitx(index) + dxs: GOTO slide
	IF dx > 1 THEN xnew = unitx(index) + 2 * dxs
	IF dy > 0 THEN ynew = unity(index) + dys: xnew = unitx(index) - 1: IF xnew < 2 THEN xnew = xnew + 2
	GOTO slide
'...............................method 2 (use roads).........................
method2:
	dxs = SGN(x - unitx(index)): dys = SGN(y - unity(index))
	flag = 10 * dys + dxs
	xnew = unitx(index): ynew = unity(index)
	tlx = 0: tly = 0

	SELECT CASE flag
	CASE -11
	a$ = "GKI"
	CASE -10
	a$ = "GI"
	CASE -9
	a$ = "IGM"
	CASE -1
	a$ = "KOG"
	CASE 1
	a$ = "MIQ"
	CASE 9
	a$ = "OKQ"
	CASE 11
	a$ = "QOM"
	CASE 10
	a$ = "OQ"
	CASE ELSE
END SELECT
'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
blox = -1
dx = LEN(a$)
FOR k = 1 TO dx
xnew = unitx(index): ynew = unity(index)
CALL curser(MID$(a$, k, 1), xnew, ynew)
GOSUB isblox
NEXT k
IF blox > 0 THEN xnew = tlx: ynew = tly: GOTO slide
uorder(index) = 0
EXIT SUB
'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
isblox:
IF xnew < 1 XOR xnew > 55 THEN RETURN
IF ynew < 1 XOR ynew > 20 THEN RETURN
z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
IF t$ = "B" THEN IF z <> 176 THEN RETURN
SELECT CASE z
	CASE 43, 91
	bonus = 4
	CASE 46
	bonus = 3
	CASE 58, 94
	bonus = 2
	CASE 176
	IF LEFTY$(index) <> "B" THEN RETURN
	CASE 239
	bonus = 1
	CASE 233
	bonus = 9
	CASE ELSE
	bonus = 2
END SELECT
CALL whois(xnew, ynew, Enemy, index)
	IF Enemy > 0 THEN bonus = 1
	IF strength(index) > strength(Enemy) THEN bonus = 3

	IF bonus > 0 THEN bonus = bonus + 3 * RND
	IF bonus > blox THEN blox = bonus: tlx = xnew: tly = ynew
RETURN
'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
slide:
	IF t$ = "G" THEN CALL proximity(index, xnew, ynew, plus): IF plus > 0 THEN uorder(index) = 0: EXIT SUB
	CALL placeunit(xnew, ynew, index)
END SUB

SUB curser (a$, xloc, yloc)
SELECT CASE a$
	CASE "G"
gee:
	IF yloc = 1 THEN EXIT SUB
	xloc = xloc - 1
	yloc = yloc - 1
	CASE "H"
	IF RND > .5 GOTO gee ELSE GOTO eye
	CASE "I"
eye:
	IF yloc = 1 THEN EXIT SUB
	xloc = xloc + 1
	yloc = yloc - 1
	CASE "K"
	xloc = xloc - 2
	yloc = yloc
	CASE "M"
	xloc = xloc + 2
	yloc = yloc
	CASE "O"
oh:
	IF yloc = 20 THEN EXIT SUB
	xloc = xloc - 1
	yloc = yloc + 1
	CASE "P"
	IF RND > .5 GOTO oh ELSE GOTO que
	CASE "Q"
que:
	IF yloc = 20 THEN EXIT SUB
	yloc = yloc + 1
	xloc = xloc + 1

	CASE "1"
	yloc = 20: xloc = 2
	CASE "2"
	yloc = 20
	CASE "3"
	yloc = 20: xloc = 54
	CASE "4"
	xloc = 2
	CASE "5"
	yloc = 10: xloc = 28
	CASE "6"
	xloc = 54
	CASE "7"
	yloc = 1: xloc = 1
	CASE "8"
	yloc = 1
	CASE "9"
	yloc = 1: xloc = 54
	CASE ";"
	CALL regorders
	CASE ELSE
END SELECT
IF xloc > 53 THEN xloc = 54
IF xloc < 2 THEN xloc = 2
IF yloc < 1 THEN yloc = 1
IF yloc > 20 THEN yloc = 20
z = INT(.5 * (xloc + yloc)) * 2 - xloc - yloc
IF z <> 0 AND xloc < 41 THEN xloc = xloc + 1
IF z <> 0 AND xloc > 40 THEN xloc = xloc - 1
END SUB

SUB customize (flag)
SCREEN 9
flag = 0
menup:
COLOR 3: CLS
LINE (0, 0)-(639, 336), 1, BF
mtx$(0) = "Game Options"
mtx$(1) = "Difficulty :" + STR$(difficult)
mtx$(2) = "Adjust Start Position"
mtx$(3) = "Visibility :" + STR$(seelimit)
mtx$(4) = "Enemy Aggression :" + STR$(bold)
mdsp = .5 * mdly! + 1: IF mdly! = 15 THEN mdsp = 5
mtx$(5) = "Display Speed :" + STR$(mdsp)
mtx$(6) = "SOUND": IF quiet = 0 THEN mtx$(6) = "QUIET"
mtx$(7) = "Scoring Factors"
mtx$(8) = "Unit Reliability :" + STR$(rely)
a$ = " ": IF automatic = 1 THEN a$ = "û"
mtx$(9) = "Computer vs. Computer " + a$
mtx$(10) = "Stack Limit :" + STR$(500 * (stakk - 1))
a$ = "OFF": IF limber = 1 THEN a$ = "ON"
mtx$(11) = "Limber : " + a$
a$ = "OFF": IF lineofsight > 0 THEN a$ = "ON"
mtx$(12) = "Line of Sight : " + a$
a$ = "OFF": IF artcap = 1 THEN a$ = "ON"
mtx$(13) = "Capture Artillery : " + a$
a$ = "OFF": IF history = 1 THEN a$ = "ON"
mtx$(14) = "History : " + a$
mtx$(15) = "Artillery fire rate :" + STR$(6 - artdelay)
mtx$(16) = "CLEAR History Files"
mtx$(17) = "Battle Intensity"
mtx$(18) = "SAVE Settings"

tly = 2: colour = 3: size = 18: CALL menu: COLOR 7, 0
	SELECT CASE choose
		CASE -1
		GOTO isthru
'----------------------------------------------------------------------------
'                                    Difficulty
'----------------------------------------------------------------------------
		CASE 1
	choose = 21 + difficult: tly = 13
	mtx$(0) = "Difficulty"
	FOR k = 1 TO 5: mtx$(k) = adj2$(k): NEXT k
	mtx$(difficult) = mtx$(difficult) + " û"
	size = 5
	CALL menu
	IF choose = -1 XOR choose = 99 GOTO menup
	difficult = choose
	GOTO menup
'----------------------------------------------------------------------------
'                             Adjust Starting Location
'----------------------------------------------------------------------------
	CASE 2
	COLOR 14
	CALL variety
	GOTO menup
'----------------------------------------------------------------------------
'                            Set Visibility Limit
'----------------------------------------------------------------------------
		CASE 3
	CLS
	COLOR 14: PRINT "LINE OF SIGHT RANGE": COLOR 11: LOCATE 4, 1
	PRINT "MIN.³...1º0...³...2º0...³...3º0...³...4º0...³...5º0"
	COLOR 11: LOCATE 6, 1: PRINT "{right arrow} or {+} to increase"
	PRINT "{left arrow} or {-} to decrease": PRINT "ENTER when done"
sight:
	COLOR 4: LOCATE 5, seelimit: PRINT SPACE$(51 - seelimit)
	LOCATE 5, 1: FOR k = 1 TO seelimit: PRINT "Û"; : NEXT k: COLOR 14: LOCATE 5, 51: PRINT seelimit; " ";
noth:   a$ = INKEY$: IF a$ = "" GOTO noth
	IF ASC(a$) = 13 GOTO menup
	IF LEN(a$) > 1 THEN a$ = RIGHT$(a$, 1)
	IF a$ = "+" OR a$ = "M" THEN seelimit = seelimit + 1
	IF a$ = "-" OR a$ = "K" THEN seelimit = seelimit - 1
	IF seelimit < 3 THEN seelimit = 3
	IF seelimit > 50 THEN seelimit = 50
	IF quiet = 1 THEN SOUND 800 + 20 * seelimit, 1
	GOTO sight
'----------------------------------------------------------------------------
'                            Enemy Aggressiveness
'----------------------------------------------------------------------------
		CASE 4
	choose = 21 + bold
	mtx$(0) = "Enemy Aggression"
	FOR k = 1 TO 5: mtx$(k) = adj1$(k): NEXT k
	colour = 5: size = 5
	mtx$(bold) = mtx$(bold) + " û"
	CALL menu: IF choose = -1 GOTO menup
	bold = choose
	GOTO menup
'----------------------------------------------------------------------------
'                            Message Speed
'----------------------------------------------------------------------------
		CASE 5
	mtx$(0) = "Display Speed"
	choose = 21 + mdsp
	FOR k = 1 TO 5: mtx$(k) = adj3$(k): NEXT k
	colour = 5: size = 5
	mtx$(mdsp) = mtx$(mdsp) + " û"
	CALL menu: IF choose = -1 GOTO menup
	mdsp = choose
	mdly! = 2 * mdsp - 2: IF mdsp = 5 THEN mdly! = 15
	GOTO menup
'----------------------------------------------------------------------------
'                       Sound Toggle
'----------------------------------------------------------------------------
		CASE 6
	quiet = 1 - quiet: GOTO menup
'----------------------------------------------------------------------------
'                        Set Game Scoring Factors
'----------------------------------------------------------------------------
		CASE 7
	COLOR 11, 3: LOCATE 19, 1
	COLOR 14: PRINT "Game Scoring Factors": COLOR 11, 1
	LOCATE 20, 1: PRINT "Points per enemy unit destroyed ["; factor(1); "]"; : INPUT x
	IF x > 0 AND x < 51 THEN factor(1) = x ELSE GOSUB dorko
	LOCATE 21, 1: PRINT "Points per turn objective controlled ["; factor(2); "]"; : INPUT x
	IF x > 0 AND x < 101 THEN factor(2) = x ELSE GOSUB dorko
	LOCATE 22, 1: PRINT "Points for controlling objective on last turn ["; factor(3); "]"; : INPUT x
	IF x > 0 AND x < 5001 THEN factor(3) = x ELSE GOSUB dorko
	GOTO menup
dorko:
	SOUND 100, 2: LOCATE 23, 1: COLOR 14: PRINT "VALUE OUTSIDE VALID LIMITS - FACTOR NOT CHANGED !";
	COLOR 11: TICK 99: clrbot: RETURN
'----------------------------------------------------------------------------
'                       Unit Reliability
'----------------------------------------------------------------------------
		CASE 8
	mtx$(0) = "Unit Reliability"
	choose = 21 + rely
	mtx$(1) = "Extremely reliable"
	mtx$(2) = "Very reliable"
	mtx$(3) = "Usually reliable"
	mtx$(4) = "Sometimes unreliable"
	mtx$(5) = "Very unreliable"
	mtx$(rely) = mtx$(rely) + " û"
	size = 5: CALL menu
	IF choose > 0 THEN rely = choose
	GOTO menup
'----------------------------------------------------------------------------
'                             Auto Play Option
'----------------------------------------------------------------------------
		CASE 9
	quiet = 0: recon = 1: mdly! = 0: automatic = 1 - automatic: CALL BuffClear: GOTO menup
'----------------------------------------------------------------------------
'                             Stack Limit
'----------------------------------------------------------------------------
		CASE 10
	mtx$(0) = "Stack Limit"
	FOR k = 1 TO 5: mtx$(k) = STR$(500 * (k - 1)): NEXT k
	mtx$(1) = mtx$(1) + " (No Stacking)"
	mtx$(stakk) = mtx$(stakk) + " û"
	choose = 21 + stakk
	size = 5: CALL menu
	IF choose > 0 THEN stakk = choose
	GOTO menup
'----------------------------------------------------------------------------
'                       Toggle Limber Option
'----------------------------------------------------------------------------
		CASE 11
	limber = 1 - limber
	GOTO menup
'----------------------------------------------------------------------------
'                       Toggle Line of Sight Option
'----------------------------------------------------------------------------
		CASE 12
	lineofsight = 1 - lineofsight
	GOTO menup
'----------------------------------------------------------------------------
'                    Toggle Artillery Capture Option
'----------------------------------------------------------------------------
		CASE 13
	artcap = 1 - artcap
	GOTO menup
'----------------------------------------------------------------------------
'                                  Set History Flag
'----------------------------------------------------------------------------
		CASE 14
	history = 1 - history
	GOTO menup
'----------------------------------------------------------------------------
'                       Sound Blaster Toggle
'----------------------------------------------------------------------------
		CASE 15
	mtx$(0) = "Artillery Fire Rate"
	mtx$(1) = "Very FAST"
	mtx$(2) = "FAST"
	mtx$(3) = "MODERATE"
	mtx$(4) = "SLOW"
	mtx$(5) = "Very SLOW"
	mtx$(artdelay) = mtx$(artdelay) + " û"
	choose = 21 + artdelay
	size = 5: CALL menu
	IF choose > 0 THEN artdelay = choose
	GOTO menup
'----------------------------------------------------------------------------
'                       Clear History Files
'----------------------------------------------------------------------------
			CASE 16
	OPEN "O", 1, "generalz"
	PRINT #1, "HALL OF FAME"
	CLOSE #1
	OPEN "O", 1, "maxskors"
	WRITE #1, "PREVIOUS BEST SCORE FILE", 0, 0
	CLOSE #1
	LOCATE 22, 1: PRINT "History files cleared": TICK 2
	GOTO menup
'----------------------------------------------------------------------------
'                       Battle Intensity
'----------------------------------------------------------------------------
			CASE 17
	mtx$(0) = "Battle Intensity"
	mtx$(1) = "Normal"
	mtx$(2) = "Low"
	mtx$(3) = "Very Low"
	x = (1.2 - intense!) / .2
	mtx$(x) = mtx$(x) + " û"
	size = 3: CALL menu
	IF choose < 0 GOTO menup
	intense! = 1.2 - .2 * choose
	GOTO menup
'----------------------------------------------------------------------------
'                       Parameter Setting Configuration File
'----------------------------------------------------------------------------
		CASE 18
	flag = 1
	GOTO isthru
'----------------------------------------------------------------------------
	CASE ELSE
	GOTO menup
	END SELECT
isthru:
IF limber > 0 THEN EXIT SUB

FOR k = 1 TO 2: CALL Compact(k): NEXT k

FOR k = 1 TO Bigg(1)
IF LEFTY$(k) = "L" THEN unit$(k) = MID$(unit$(k), 2)
NEXT k

FOR k = m2 TO Bigg(2)
IF LEFTY$(k) = "L" THEN unit$(k) = MID$(unit$(k), 2)
NEXT k

END SUB

SUB deadlead (index)
s = 1: COLOR 7: IF index > m1 THEN COLOR 9: s = 2
clrbot
unit$(0) = "X": Visible(0) = 1
unitx(0) = 1: unity(0) = 22
PRINT "    "; sname$(s); " LEADER KILLED! UNIT :"; name$(index);
CALL SHOWUNIT(0)
leader(index) = (.5 + .5 * RND) * leader(index)
COLOR 11: LOCATE 23, 55: PRINT "New Leader Ability ="; leader(index); : CALL dirge
TICK mdly!
Visible(0) = 0: unit$(0) = "": strength(0) = 0
END SUB

SUB DESCRIBE (k)
t$ = LEFT$(unit$(k), 1)
strip2:
SELECT CASE t$
	CASE "I"
	PRINT "Infantry";
	CASE "è"
	PRINT "ènfantry";
	CASE "C"
	PRINT "Cavalry";
	CASE "G"
	PRINT "General";
	CASE "A"
	PRINT "Artillery";
	CASE "N"
	PRINT "Napoleon";
	CASE "H"
	PRINT "Horse Art";
	CASE "B"
	PRINT "Boat";
	CASE "L"
	t$ = MID$(unit$(k), 2, 1): PRINT "L";
	GOTO strip2
	CASE "E"
	PRINT "Emplaced Gun"
	CASE "w"
	t$ = MID$(unit$(k), 2): PRINT "w";
	GOTO strip2
	CASE ELSE
END SELECT
END SUB

SUB dirge
IF quiet = 1 THEN
	IF sblast$ = "" THEN
		PLAY "MBt120l16o1mna4a8.aa2a4a8.aa2"
	ELSE
		CALL sndblst("sad1")
	END IF
END IF
END SUB

SUB email
	CLS
	LINE (0, 0)-(639, 116), 4, BF
	LINE (0, 117)-(639, 232), 15, BF
	LINE (0, 233)-(639, 349), 1, BF
	chksum& = 0
	OPEN "O", 1, "savegame.pbm"
	PRINT #1, SCENARIO$
	WRITE #1, timelimit, possess, vp&(1), vp&(2), score&(1), score&(2)
	IF altobj$ <> "" THEN
		a$ = RIGHT$(altobj$, 1)
		sdtext$(24) = LTRIM$(RTRIM$(STR$(alt(1)))) + "/" + LTRIM$(RTRIM$(STR$(alt(2)))) + "/" + LTRIM$(RTRIM$(STR$(alt(3)))) + "/" + a$
	END IF
	FOR k = 1 TO 24: WRITE #1, sdtext$(k): NEXT k
	FOR k = 1 TO most
	IF unit$(k) <> "" THEN
		IF LEFTY$(k) = "G" AND uorder(k) <> 99 THEN uorder(k) = 0
	END IF
	t$ = LEFT$(unit$(k), 1)
	IF t$ = "L" OR t$ = "w" THEN t$ = LEFT$(unit$(k), 2)
	a$ = LTRIM$(RTRIM$(STR$(k))) + "," + CHR$(34) + name$(k) + CHR$(34) + "," + CHR$(34) + t$ + CHR$(34)
	a$ = a$ + "," + LTRIM$(RTRIM$(STR$(morale(k)))) + "," + LTRIM$(RTRIM$(STR$(leader(k))))
	a$ = a$ + "," + LTRIM$(RTRIM$(STR$(strength(k)))) + "," + LTRIM$(RTRIM$(STR$(unitx(k))))
	a$ = a$ + "," + LTRIM$(RTRIM$(STR$(unity(k)))) + "," + LTRIM$(RTRIM$(STR$(terrain(k))))
	a$ = a$ + "," + LTRIM$(RTRIM$(STR$(toa(k)))) + "," + LTRIM$(RTRIM$(STR$(uorder(k))))
	CALL codex(1, k, a$, t$)
	PRINT #1, t$
	NEXT k
'.................................... configuration insert ..................
	WRITE #1, bold, seelimit, difficult, quiet, mdsp
	FOR k = 1 TO 3: WRITE #1, factor(k): NEXT k
	WRITE #1, rely, stakk, limber, lineofsight, artcap, artdelay, intense!
	chksum& = chksum& + bold + seelimit + stakk + limber + lineofsight + artcap + artdelay
'................................ checksum .................................
	WRITE #1, chksum&, 3 - side
	
	FOR k = 1 TO 22: PRINT #1, stex$(k): NEXT k
	CLOSE #1
	GOSUB emess
	CALL clrbot: COLOR 2: PRINT "SUCCESSFUL SAVE": TICK 2
	pbm = 0
EXIT SUB
emess:
	LINE (120, 120)-(520, 320), 0, BF
	LINE (100, 100)-(500, 300), 7, BF
	LINE (440, 110)-(480, 160), 5, BF
	COLOR 15: LOCATE 14, 25: PRINT "PBM File has been saved"
	LOCATE 16, 25: PRINT "to send to your "; sname$(3 - side); " Opponent"
	COLOR 9: IF side = 1 THEN COLOR 15
	LOCATE 9, 15: PRINT sname$(side); " Player"
	LOCATE 10, 15: PRINT "Turns left: "; timelimit - timex
	PSET (450, 150), 0
	DRAW "C3U4R2E3U3H3U1H2U7E8R8F5D3F2D2L2D3L1D1F1G2L1H1G2D2F4D5L18BE4"
	x = POINT(0): y = POINT(1): PAINT (x, y), 3
RETURN
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
	 text$ = "": EXIT DO

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

SUB expire
COLOR 11
CLS
PRINT " Scenario :"; SCENARIO$
PRINT " Player :";
COLOR 15: IF side = 2 THEN COLOR 9
PRINT " "; sname$(side): COLOR 11
PRINT " Difficulty :"; adj2$(difficult)
PRINT " Visibility Range :"; seelimit
PRINT " Enemy Aggressiveness :"; adj1$(bold)
PRINT " Turns Left :"; timelimit - timex
COLOR 9
LOCATE 8, 20: PRINT sname$(2): COLOR 15: LOCATE 8, 30: PRINT sname$(1)
COLOR 11: PRINT " ENEMY KILLS";
CALL icon(300, 20, side)

total& = 0
FOR k = 1 TO 2
total& = total& + .1 * (score&(k) + vp&(k))
NEXT k
total& = 10 * total&

COLOR 9: LOCATE 9, 19: PRINT score&(1)
COLOR 15: LOCATE 9, 29: PRINT score&(2)
COLOR 11: LOCATE 10, 1: PRINT " OBJECTIVES"
COLOR 9: LOCATE 10, 19: PRINT vp&(2)
COLOR 15: LOCATE 10, 29: PRINT vp&(1)
COLOR 14: PRINT " END GAME BONUS"
x = 0: y = 0
IF possess = 2 AND timelimit - timex < 1 THEN LOCATE 11, 19: x = factor(3): PRINT x
IF possess = 1 AND timelimit - timex < 1 THEN LOCATE 11, 29: y = factor(3): PRINT y
COLOR 11
LOCATE 13, 2: PRINT "TOTAL SCORE"
LINE (1, 96)-(400, 185), 3, B
LINE (1, 161)-(400, 220), 3, B
LINE (1, 220)-(600, 240), 3, B
LINE (1, 240)-(400, 280), 3, B
			
LOCATE 13, 19: COLOR 9: PRINT score&(1) + vp&(2) + x
COLOR 15: LOCATE 13, 29: PRINT score&(2) + vp&(1) + y
'---------------------------------------------------------------------------
x = 0: IF timelimit - timex < 1 AND possess = side THEN x = factor(3)
IF total& < 1 GOTO noresult
a = 100: IF possess = 0 OR timelimit - timex > 0 THEN a = 0
skor# = (score&(3 - side) + vp&(side) + x) / (total& + a) * 100

LOCATE 15, 2: COLOR 15: IF side = 2 THEN COLOR 9
PRINT sname$(side); " OUTCOME  "; : COLOR 14
	SELECT CASE skor#
		CASE IS < 30
		COLOR 12: PRINT "Bloody Massacre "
		CASE IS < 35
		PRINT "Debacle"
		CASE IS < 40
		PRINT "Crushing Defeat"
		CASE IS < 42
		PRINT "Decisive Defeat"
		CASE IS < 44
		PRINT "Defeat"
		CASE IS < 48
		PRINT "Marginal Loss"
		CASE IS < 52
		PRINT "Standoff"
		CASE IS < 54
		PRINT "Advantage"
		CASE IS < 58
		PRINT "Marginal Victory"
		CASE IS < 62
		PRINT "Clear-cut Victory"
		CASE IS < 66
		COLOR 10: PRINT "Decisive Victory"
		CASE IS < 70
		COLOR 10: PRINT "SMASHING Victory"
		CASE ELSE
		PRINT "Overwhelming Victory"
	END SELECT

skor# = skor# + 4 * difficult - 12
LOCATE 17, 2: COLOR 11: PRINT "DIFFICULTY-ADJUSTED PERCENT  "; : x = INT(10 * skor#): COLOR 14: PRINT .1 * x; "%"
LOCATE 19, 2: COLOR 11: PRINT "YOUR PERFORMANCE  "; : COLOR 14
	SELECT CASE skor#
		CASE IS < 30
		COLOR 12: PRINT "INEPT"
		CASE IS < 40
		PRINT "POOR"
		CASE IS < 44
		PRINT "WEAK"
		CASE IS < 47
		PRINT "STRUGGLING"
		CASE IS < 53
		PRINT "AVERAGE"
		CASE IS < 60
		PRINT "GOOD"
		CASE IS < 65
		PRINT "VERY GOOD"
		CASE IS < 95
		COLOR 10: PRINT "OUTSTANDING"
		CASE IS < 120
		COLOR 10: PRINT "MASTERFUL"
		CASE ELSE
		COLOR 10: PRINT "BRILLIANT"
	END SELECT
noresult:
IF nplayer < 2 THEN
	LINE (400, 183)-(600, 220), 14, B
	LINE (400, 161)-(600, 185), 14, B
	LINE (500, 185)-(500, 240), 14
	LINE (400, 220)-(600, 240), 14, B
	COLOR 14: LOCATE 13, 57: PRINT "PREVIOUS BEST"
	COLOR 9: LOCATE 17, 55: PRINT .1 * highscore(2); " %"
	LOCATE 15, 55: PRINT sname$(2)
	COLOR 15: LOCATE 17, 67: PRINT .1 * highscore(1); " %"
	LOCATE 15, 64: PRINT sname$(1)
END IF
	COLOR 12: LOCATE 23, 3: PRINT "hit a key";
	LINE (1, 305)-(100, 325), 12, B: TICK 99
	IF timelimit - timex <= 0 THEN
		IF pbm = 0 THEN
			CALL ishi(x)
			CALL commander(x)
			COLOR 11, 0
		END IF
	END IF
END SUB

SUB flee (defend, index)
index = 0
IF INSTR("GL", LEFTY$(defend)) = 0 AND strength(defend) + morale(defend) > 70 THEN EXIT SUB
CALL ranger(defend, vantage)
IF uorder(index) > 0 GOTO avoid
s = m2: F = Bigg(2): IF defend < m2 THEN s = 1: F = Bigg(1)
FOR i = s TO F
IF i = defend GOTO fly
d = 2 * ABS(unity(i) - unity(defend)) + ABS((unitx(i) - unitx(defend)))
IF d > vantage GOTO fly
IF LEFTY$(i) = "G" AND strength(i) > 0 AND RND > .5 THEN index = i
IF index = 0 AND strength(i) > 0 THEN index = i
fly:
NEXT i
avoid:
END SUB

SUB general (index)
IF strength(index) < 1 THEN EXIT SUB    ' unit is DEAD
IF strength(index) + morale(index) < 70 GOTO afraid ' unit is Weak
t$ = LEFTY$(index)
IF uorder(index) < 0 THEN EXIT SUB      ' unit is DUG IN
IF uorder(index) = 99 THEN EXIT SUB     ' unit is DELAYED
s = 1: IF index > m1 THEN s = 2
SELECT CASE possess
	CASE 0
	pct# = .8
	CASE 3 - s
	pct# = .2
	CASE ELSE
	pct# = 2
END SELECT
IF possess <> s AND RND > pct# THEN uorder(index) = 100 * objy + objx: EXIT SUB
IF uorder(index) > 0 AND RND < .15 * bold GOTO mine
	IF INSTR("ANHB", t$) > 0 AND RND > .03 + .01 * bold GOTO mine
	IF t$ = "G" AND RND > .03 * bold GOTO mine
	d = ABS(unity(index) - objy) + ABS(unitx(index) - objx)
	CALL ranger(index, vantage): IF d > vantage AND RND < .1 * bold GOTO mine
	IF possess <> 3 - side THEN uorder(index) = 100 * objy + objx: EXIT SUB
	CALL Near2(index, Enemy, near): IF Enemy > 0 THEN uorder(index) = 100 * unity(Enemy) + unitx(Enemy): EXIT SUB
mine:
CALL see(index)
IF uorder(index) > 0 THEN EXIT SUB
a = terrain(index): IF a = 239 THEN EXIT SUB
IF (a = 94 OR a = 35) AND RND < .99 THEN EXIT SUB
IF INSTR("ANHL", t$) > 0 AND a = 42 GOTO art
IF a = 42 AND RND < .95 THEN EXIT SUB

art:
IF y > 1 THEN
	y = unity(index) - 1: x = unitx(index) - 1: GOSUB eval
	y = unity(index) - 1: x = unitx(index) + 1: GOSUB eval
END IF
IF y < 22 THEN
	y = unity(index) + 1: x = unitx(index) - 1: GOSUB eval
	y = unity(index) + 1: x = unitx(index) + 1: GOSUB eval
END IF
IF x > 1 THEN x = unitx(index) - 2: GOSUB eval
IF x < 59 THEN x = unitx(index) + 2: GOSUB eval

a = 1 + INT(Bigg(1) * RND)
IF side = 2 THEN a = 1 + m1 + INT((Bigg(2) - m1) * RND)
IF (strength(a) > 0 AND uorder(a) <> 99) THEN uorder(index) = 100 * unity(a) + unitx(a)
EXIT SUB

eval:
IF x < 1 THEN x = 1
IF x > 59 THEN x = 59
IF y < 1 THEN y = 1
IF y > 22 THEN y = 22
z = SCREEN(y + 1, x): IF z = 35 OR z = 42 XOR z = 94 XOR z = 239 GOTO improve
RETURN

afraid:
CALL flee(index, a)
IF a > 0 AND strength(a) > 0 THEN uorder(index) = 100 * unity(a) + unitx(a)
EXIT SUB

improve:
uorder(index) = 100 * y + x

END SUB

SUB inspect (index)
	IF index < 1 THEN EXIT SUB
	LINE (454, 154)-(629, 265), 0, BF
	c = 7: IF index > 40 THEN c = 9
	COLOR c
	CALL YouorMe(index, F): IF F = 0 THEN LOCATE 12, 67: COLOR 11: PRINT sname$(3 - side)
	LOCATE 12, 58: PRINT "Unit "; index; : IF F > 0 THEN IF uorder(index) > 0 THEN COLOR 3, 0: LOCATE 12, 67: PRINT "UNDER ORDERS";
	IF F > 0 THEN IF uorder(index) < 0 THEN COLOR 3, 0: LOCATE 12, 67: PRINT "DUG-IN";
	COLOR c: LOCATE 13, 58: PRINT name$(index);
	LOCATE 14, 58: CALL DESCRIBE(index)
	CALL YouorMe(index, F): x = strength(index): IF F = 0 THEN x = INT(strength(index) / 100 - 2 + 4 * RND) * 100: IF x < 10 THEN x = 50
	COLOR c: IF F = 1 AND strength(index) < 200 THEN COLOR 5: IF strength(index) < 100 THEN COLOR 12
	LOCATE 15, 58: PRINT "Strength:" + STR$(x)
	COLOR c: IF morale(index) < 61 THEN COLOR 5: IF morale(index) < 40 THEN COLOR 12
	IF F = 1 THEN LOCATE 16, 58: PRINT "Morale  :" + STR$(morale(index))
	COLOR c: IF leader(index) < 61 THEN COLOR 5: IF leader(index) < 40 THEN COLOR 12
	IF F > 0 THEN LOCATE 17, 58: PRINT "Leader  :" + STR$(leader(index))

	LOCATE 19, 58: PRINT "Terrain : ": CALL Tara(68, 19, terrain(index))
	IF F = 1 THEN COLOR c: LOCATE 18, 58: PRINT "Next Move : "; timelimit - toa(index)
	END SUB

SUB intel (i, a1$, a2$)
COLOR 7: IF i > m1 THEN COLOR 9
a2$ = "Outstanding"
IF leader(i) > 90 THEN a2$ = "Brilliant"
IF leader(i) < 81 THEN a2$ = "Average"
IF leader(i) < 51 THEN a2$ = "Weak": COLOR 4, 0
IF leader(i) < 31 THEN a2$ = "INEPT": COLOR 4, 0

a1$ = "Good"
IF morale(i) > 90 THEN a1$ = "Excellent"
IF morale(i) < 81 THEN a1$ = "Fair"
IF morale(i) < 51 THEN a1$ = "POOR": COLOR 4, 0
IF morale(i) < 31 THEN a1$ = "TERRIBLE": COLOR 4, 0
END SUB

SUB ishi (x)
IF history = 0 OR x < highscore(side) THEN EXIT SUB
IF file$ = "" THEN file$ = sdtext$(23): IF LEN(file$) < 4 THEN EXIT SUB
IF LEFT$(file$, 1) = "$" THEN file$ = sdtext$(23)
IF LEN(file$) < 4 THEN EXIT SUB
IF campane > 0 THEN EXIT SUB
'...........................................................................
SCREEN 0
SHELL "copy maxskors temp.$$$"
CALL scrnload("newhi.scr")
COLOR 14: LOCATE 13, 25: PRINT "Scenario :"; file$; " "; .1 * x; "%"
highscore(side) = x
OPEN "I", 1, "temp.$$$"
OPEN "O", 2, "maxskors"
z = 0
DO WHILE NOT EOF(1)
INPUT #1, a$, dx, dy
IF file$ = a$ THEN dx = highscore(1): dy = highscore(2): z = 1
WRITE #2, a$, dx, dy
LOOP
IF z = 0 THEN WRITE #2, file$, highscore(1), highscore(2)
CLOSE #1
CLOSE #2
KILL "temp.$$$"
IF quiet = 1 THEN
	IF sblast$ = "" THEN
	PLAY "T140O3L8C;FCFG;A4GMLA16mnB-16;O4CO3FL16MLAMNGMLFMNEL8;F4.C"
	PLAY "FCFG;A4GMLA16MNB-16;O4CO3FMLA16MNG16MLF16MNE16;F4P8MLA16MNB-16"
	PLAY "O4C.D16CO3B-;MLA.MNB-16O4CO3F;O4D.D16MLC16MNO3B-16MLA16MNG16;MLF4MNEC16C16"
	PLAY "FCFG;A4GMLA16MNB-16;O4CO3FMLA16MNG16MLF16MNE16;F4P2"
	ELSE
	a$ = "hymn": IF side = 1 THEN a$ = "dixie"
	CALL sndblst(a$)
	END IF
END IF
COLOR 14: LOCATE 25, 3: PRINT "hit a key";
TICK 99
END SUB

SUB kleer
LINE (454, 153)-(630, 266), 0, BF
END SUB

FUNCTION LEFTY$ (index)
LEFTY$ = LEFT$(unit$(index), 1)
END FUNCTION

SUB limbo (index, flag)
IF limber = 0 THEN EXIT SUB
t$ = LEFTY$(index)
IF flag < 2 GOTO limb1
IF t$ <> "L" GOTO stuck
	COLOR 11: clrbot: PRINT "Artillery units must be UNIMBERED to fire";
	mtx$(0) = "UNLIMBER ?"
	GOTO hitch
stuck:
	COLOR 11: clrbot: PRINT "Artillery units must be LIMBERED to move";
	mtx$(0) = "Limber ?"
hitch:
	CALL YesNo(a$)
	CALL scrcol(1)
	IF LEFT$(a$, 1) <> "Y" THEN
		IF t$ <> "L" THEN mtx$(0) = "@"
		EXIT SUB
	END IF
limb1:
	IF INSTR("ANH", t$) > 0 THEN unit$(index) = "L" + unit$(index): a$ = "LIMBERED": GOTO rollon
	IF t$ = "L" THEN unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1): a$ = "UNLIMBERED": GOTO rollon
	EXIT SUB
rollon:
	toa(index) = toa(index) + 2 + RND
	IF morale(index) < 60 THEN toa(index) = toa(index) + 1
	IF leader(index) < 60 THEN toa(index) = toa(index) + 2
	IF t$ = "H" OR t$ = "L" AND MID$(unit$(index), 2, 1) = "H" THEN toa(index) = toa(index) - 2
	CALL YouorMe(index, F)
	IF F = 0 THEN
		IF t$ = "L" THEN
			uorder(index) = 100 * objy + objx
			IF Visible(index) > 0 THEN CALL SHOWUNIT(index): EXIT SUB
			ELSE EXIT SUB
		END IF
	END IF
	IF quiet = 1 THEN
		IF sblast$ = "" THEN
			SOUND 1600, .5: TICK .05: SOUND 1700, .5
		ELSE
			CALL sndblst("limber")
		END IF
	END IF
	IF (side = 1 AND index > m1) OR (side = 2 AND index < m2) THEN EXIT SUB
	CALL ATTENTION(index, 13)
	CALL inspect(index)
	COLOR 11: CALL clrbot: PRINT "Artillery Unit "; name$(index); " is "; a$; : TICK .3 * mdly!
END SUB

SUB LITEUP (x0, y0, c)
LINE (x0, y0)-(x0 + 14, y0 + 13), c, B
LINE (x0 + 1, y0 + 1)-(x0 + 13, y0 + 12), c, B
END SUB

SUB lowtime
	timex = 32767
	FOR k = 1 TO Bigg(2)
	IF strength(k) > 0 AND toa(k) < timex THEN timex = toa(k)
	NEXT k
END SUB

SUB minsec
a = TIMER - startit!: x = INT(a / 60): y = a - 60 * x
B$ = RTRIM$(STR$(x)): a$ = LTRIM$(STR$(y)): IF y < 10 THEN a$ = "0" + a$
LOCATE 1, 58: PRINT "Elapsed Time "; B$; ":"; a$
END SUB

SUB Near2 (index, Enemy, near)
	t$ = LEFTY$(index)
	CALL ranger(index, vantage)
	near = 32767: Enemy = 0
	s = 1: F = Bigg(1): IF index < m2 THEN s = m2: F = Bigg(2)
	flag = 0

	FOR i = s TO F

	IF strength(i) < 1 OR uorder(i) = 99 GOTO deadog
	d = 2 * ABS(unity(index) - unity(i)) + ABS(unitx(index) - unitx(i))
	IF d > vantage GOTO deadog

	dx = 100 - d
'.............................................................................
	IF INSTR("AENHL", t$) = 0 THEN
		IF strength(i) > 1.2 * strength(index) THEN dx = dx - 20
		IF strength(index) > 1.2 * strength(i) THEN dx = dx + 20
		IF strength(index) > 2 * strength(i) THEN dx = dx + 50
	ELSE
		CALL los(index, i, F, 0)
		IF Visible(i) = 0 THEN Visible(i) = 1
		IF F = 0 THEN dx = -9999
	END IF
'.............................................................................
	IF d < near THEN dx = dx + 20
	a$ = LEFTY$(i): IF a$ = "w" THEN a$ = MID$(unit$(i), 2, 1)
	IF INSTR("AENHL", a$) > 0 THEN dx = dx + 100 + 50 * RND
	IF t$ = "B" AND a$ = "B" THEN dx = dx + 30 + 20 * RND
	IF d < 8 THEN dx = dx + 20
	IF d < 6 THEN dx = dx + 50
	IF d < 4 THEN dx = dx + 100: : IF INSTR("AENHLB", t$) THEN dx = dx + 200 + 20 * RND

	SELECT CASE terrain(i)
		CASE 233: dx = dx + 150
		CASE 94: dx = dx + 10
		CASE 239: dx = dx + 20
		CASE 61: dx = dx + 30
	END SELECT

	IF t$ = "G" AND d > 7 AND dx < 150 THEN dx = 0
	IF (d < 4 AND near > d) OR dx > flag THEN near = d: flag = dx: Enemy = i
deadog: NEXT i
END SUB

SUB noise (x, y, t$)
IF quiet = 1 THEN
IF x = 0 AND t$ = "" THEN x = 1900: y = 1: t$ = "ding"
	IF sblast$ = "" THEN
		SOUND x, y
	ELSE
		CALL sndblst(t$)
	END IF
END IF
END SUB

SUB normal (xbar, vary, result)
' NOTE : vary is VARIANCE
IF vary < 0 THEN vary = 0
pct# = 0
FOR k = 1 TO 12: pct# = pct# + RND: NEXT k
pct# = pct# - 5.5
result = xbar + pct# * SQR(vary)
IF result < 0 THEN result = 0
END SUB

SUB proximity (index, x, y, bonus)
	s = 1: F = Bigg(1): IF index < m2 THEN s = m2: F = Bigg(2)
IF x = 0 THEN                           'default: check for friendlies
	x = unitx(index): y = unity(index)
	s = 1: F = Bigg(1): IF index > m1 THEN s = m2: F = Bigg(2)
END IF
bonus = 0
FOR k = s TO F
	IF index = k OR uorder(k) = 99 GOTO toofar4
	IF 2 * ABS(y - unity(k)) + ABS(x - unitx(k)) > 3 GOTO toofar4
	bonus = bonus + 1
	IF morale(k) > 80 THEN bonus = bonus + 2
	IF leader(k) > 80 THEN bonus = bonus + 1
	IF LEFTY$(k) = "G" THEN bonus = bonus + .15 * leader(k): IF leader(k) > 90 THEN bonus = bonus + leader(k) - 90
toofar4: NEXT k
END SUB

SUB pursue (index, x, y, flag)
IF uorder(index) = 99 THEN EXIT SUB
IF uorder(index) < 0 AND leader(index) < 120 - 10 * bold THEN EXIT SUB
z = ASC(MID$(sdtext$(y + 1), x, 1))
CALL whois(x, y, Enemy, index): IF Enemy > 0 THEN EXIT SUB

	CALL YouorMe(index, F)
	IF automatic = 1 OR F = 0 OR rely = 5 GOTO blindly
	BuffClear
	mtx$(0) = "Pursue ?"
	LITEUP 8 * unitx(index), 14 * unity(index), 14
	CALL YesNo(a$): CALL scrcol(1): IF a$ = "Y" GOTO runn ELSE EXIT SUB

blindly:
IF unity(index) = objy AND unitx(index) = objx THEN EXIT SUB

IF flag > 0 GOTO runn
a = terrain(index)
IF (a <> z) AND (z = 233 OR z = 239 OR z = 35) GOTO runn

IF ((a = 94 OR a = 239 OR a = 35)) AND RND < .9 THEN EXIT SUB
IF a = 42 AND RND < .7 THEN EXIT SUB

IF z = 61 AND RND < .7 THEN EXIT SUB
IF z = 43 OR z = 46 AND RND < .15 * bold GOTO runn
IF morale(index) < 20 THEN EXIT SUB


runn:
IF flag = 0 GOTO runn2
'============================================================================
'                             Artillery Capture
'============================================================================
 s = 1: IF index > m1 THEN s = 2
	id = 0
	IF s = 1 AND Bigg(1) < m1 THEN id = Bigg(1) + 1
	IF s = 2 AND Bigg(2) < most THEN id = Bigg(2) + 1
	IF id = 0 GOTO runn2
	IF strength(id) <> 0 GOTO runn2
IF flag > .025 * strength(index) THEN flag = .025 * strength(index)
IF flag < 1 GOTO runn2
strength(id) = 20 * flag
strength(index) = strength(index) - strength(id)
unitx(id) = x: unity(id) = y: terrain(id) = z: uorder(id) = 0
morale(id) = morale(index): leader(id) = leader(index)
name$(id) = "CAPTURED": unit$(id) = "N": Visible(id) = 1
toa(id) = timex + 5
IF strength(id) < 1 THEN strength(id) = 0: Visible(id) = 0: GOTO runn2
CALL clrbot: COLOR 14: PRINT flag; sname$(3 - s); " artillery pieces CAPTURED ";
FOR k = 1 TO mdly!: CALL ATTENTION(id, 14): NEXT k
CALL SHOWUNIT(id)
CALL SHOWUNIT(index)
IF (side = 1 AND index < m2) OR (side = 2 AND index > m1) THEN CALL trumpet(index)
IF terrain(id) = 233 THEN CALL victory(id)
CALL Compact(s)
TICK 9
GOTO runn3
'.........................................................................
runn2:
CALL Tara(unitx(index), unity(index) + 1, 0)
unity(index) = y: unitx(index) = x: terrain(index) = z
CALL SHOWUNIT(index)
IF sblast$ <> "" THEN SHELL "yell.exe"
IF (side = 1 AND index < m2) OR (side = 2 AND index > m1) THEN CALL trumpet(index)
runn3:
morale(index) = morale(index) + 9
IF RND > .8 THEN leader(index) = leader(index) + 5
IF z = 233 THEN SHOWUNIT (index): CALL victory(index)
END SUB

SUB Rally (xloc, yloc, index, active, flag)
s = 1: IF active > m1 THEN s = 2
flag = 0: plus = 0
CALL whois(xloc, yloc, index, active)
IF index = 0 OR (s = 1 AND index > m1) OR (s = 2 AND index < m2) THEN EXIT SUB
IF LEFTY$(index) = "w" THEN unit$(index) = MID$(unit$(index), 2): CALL SHOWUNIT(index): EXIT SUB
CALL ranger(active, vantage)
d = 2 * ABS(unity(active) - unity(index)) + ABS(unitx(active) - unitx(index))
IF d > vantage THEN
	IF s = side THEN COLOR 12: clrbot: PRINT "Too far to communicate"; : TICK mdly!: EXIT SUB
	EXIT SUB
ELSE
	IF d < 4 THEN plus = 10 + 10 * RND
END IF
	clrbot
	IF toa(active) > timex + 10 THEN
		IF s = side THEN COLOR 12: PRINT name$(index); " not ready to move";
		GOTO payit
	END IF
	IF leader(active) + morale(active) + 10 * RND + plus < leader(index) + morale(index) THEN
		IF s = side THEN COLOR 12: PRINT name$(active); " cannot rally "; : CALL DESCRIBE(index): leader(active) = leader(active) - 5
		 GOTO payit
	END IF
	COLOR 11: CALL DESCRIBE(index): PRINT " is rallying...";
	IF Visible(index) > 0 THEN
		FOR k = 1 TO 4
		ATTENTION index, 14
		IF quiet = 1 THEN
			IF sblast$ = "" THEN
				SOUND 900, 1: SOUND 999, .7
			ELSE
				CALL sndblst("drums3"): EXIT FOR
			END IF
		END IF
		NEXT k
	END IF
	toa(active) = toa(index): toa(index) = timex
	morale(index) = morale(index) + 5
	uorder(index) = 0
payit:
	morale(active) = morale(active) - 7
	CALL SHOWUNIT(active)
	CALL valid(active)
	TICK .2 * mdly!
	flag = 1
END SUB

SUB ranger (attack, vantage)
vantage = seelimit: IF terrain(attack) = 94 THEN vantage = seelimit + 2
IF terrain(attack) = 239 THEN vantage = seelimit + 4
IF terrain(attack) = 42 THEN vantage = seelimit - 2
IF terrain(attack) = 61 THEN vantage = seelimit - 4
END SUB

SUB rank (k, dx, t$)
IF k < 15 THEN dx = .9 * dx
SELECT CASE .1 * dx
	CASE IS < 20
	t$ = "(civilian)"
	CASE IS < 35
	t$ = "Private"
	CASE IS < 45
	t$ = "Sergeant"
	CASE IS < 50
	t$ = "Lieutenant"
	CASE IS < 52
	t$ = "Captain"
	CASE IS < 54
	t$ = "Major"
	CASE IS < 56
	t$ = "Colonel"
	CASE IS < 58
	t$ = "Brigadier General"
	CASE IS < 60
	t$ = "Major-General"
	CASE IS < 70
	t$ = "Lieutenant General"
	CASE ELSE
	t$ = "General of the Army"
END SELECT
END SUB

SUB regorders
topp:
tlx = 61: tly = 3: colour = 11
mtx$(0) = "GAME OPTIONS"
mtx$(1) = "Order of Battle"
mtx$(2) = "Game Score"
mtx$(3) = "Screen Redraw"
mtx$(4) = "Briefing"
size = 4
CALL menu
CALL scrcol(1)

SELECT CASE choose
	CASE -1
	CASE 1
	CALL report
	CASE 2
	CALL expire
	CALL mainmap: CALL refresh
	CASE 3
	CALL mainmap: CALL refresh
	CASE 4
	CALL scentex
	CALL mainmap
	CALL refresh
	CASE ELSE
END SELECT
END SUB

SUB report
SCREEN 9, 0, 1, 1

FOR i = 1 TO 2
COLOR 7
s = 1: F = Bigg(1): IF i = 2 THEN s = m2: F = Bigg(2)

total& = 0
x = 0
GOSUB head
FOR k = s TO F
	IF flag = 0 AND Visible(k) = 0 THEN
		IF k <> F GOTO hide1
	END IF
	COLOR 7: IF i = 2 THEN COLOR 3
	GOSUB fog
	IF strength(k) > 0 THEN
		PRINT k; TAB(9); name$(k); TAB(25); a; TAB(32); : CALL DESCRIBE(k)
		PRINT TAB(44); a$; TAB(57); B$: x = x + 1: total& = total& + strength(k)
	END IF

	IF (x = 20 OR k = F) THEN
		COLOR 11: PRINT "Cumulative Totals :  Units ="; x; "   Forces ="; total&
		GOSUB hold8: CLS
		IF k <> F THEN GOSUB head
	END IF
hide1:
	NEXT k
NEXT i
SCREEN 9, 0, 0, 0
EXIT SUB

hold8:
COLOR 14: LOCATE 25, 1: PRINT "hit a key";
DO WHILE INKEY$ = "": LOOP
RETURN

fog:
CALL intel(k, a$, B$)
CALL YouorMe(k, flag)
IF flag = 1 THEN a = strength(k): RETURN
a = .7 * strength(k) + .6 * RND * strength(k): IF RND > .7 THEN a$ = "Excellent": IF RND > .5 THEN a$ = "  ?"
IF RND > .7 THEN B$ = "?"
RETURN

head:
CLS
COLOR 15
PRINT SPACE$(80)
LOCATE 1, 1: PRINT sname$(i); " Forces	   "; SCENARIO$
COLOR 11
PRINT "Unit #   Name         Strength  Type       Morale       Leadership"
RETURN

END SUB

SUB rest (k)
	IF morale(k) < leader(k) THEN morale(k) = morale(k) + 1
	IF morale(k) < 60 THEN morale(k) = morale(k) + 2
	IF RND < leader(k) AND morale(k) < 77 THEN morale(k) = morale(k) + 3
	CALL proximity(k, 0, 0, bonus): IF bonus > 10 THEN bonus = 10
	IF morale(k) < 80 + bonus THEN morale(k) = morale(k) + bonus
	toa(k) = timex + 3 + 2 * RND: IF bonus > 5 THEN toa(k) = toa(k) - 1
	CALL SHOWUNIT(k)
	CALL YouorMe(k, F): IF F = 0 THEN EXIT SUB
	IF LEFTY$(k) <> "w" THEN
		clrbot
		PRINT name$(k); " is resting and recovering...";
		CALL TICK(.2 * mdly!)
	END IF
	IF LEFTY$(k) = "è" THEN unit$(k) = "I": SHOWUNIT (k)
END SUB

SUB retreat (index, defend)
IF uorder(index) = 99 GOTO rip
IF limber = 1 AND INSTR("ANH", LEFTY$(index)) > 0 THEN EXIT SUB
IF LEFTY$(index) = "E" THEN EXIT SUB
rflag = 0
id = 1: IF index > m1 THEN id = 2
IF strength(index) < 1 GOTO rip

FOR k = 1 TO mdly!
ATTENTION index, 13
NEXT k

clrbot
s = 1: IF index > m1 THEN s = 2
COLOR 13: PRINT sname$(s); " unit "; name$(index); " must pull back ";
rout = 0: uorder(index) = 0

dxs = SGN(unitx(defend) - unitx(index)): dys = SGN(unity(defend) - unity(index))
flag = 10 * dys + dxs
xnew = unitx(index): ynew = unity(index)

SELECT CASE flag
CASE -11
a$ = "QOM"
CASE -9
a$ = "OKQ"
CASE -1
a$ = "MIQ"
CASE 1
a$ = "KOG"
CASE 9
a$ = "IGM"
CASE 11
a$ = "GKI"
CASE -10
a$ = "OQ"
CASE 10
a$ = "GI"
CASE ELSE
END SELECT
'============================================================================
dx = LEN(a$)
FOR k = 1 TO dx
xnew = unitx(index): ynew = unity(index)
CALL curser(MID$(a$, k, 1), xnew, ynew)
GOSUB run1: IF blox = 0 GOTO woe
NEXT k
'============================================================================
rout = 1 + .05 * strength(index): IF RND > .5 THEN rout = rout * 2
score&(id) = score&(id) + rout
CALL scrcol(2)
CALL flash(index, 2)
COLOR 15: IF index > m1 THEN COLOR 9
clrbot
PRINT "EXTRA DAMAGE TAKEN :"; rout; " ";
SHOWUNIT (index)
morale(index) = morale(index) - 5: morale(defend) = morale(defend) + 3
morale(defend) = morale(defend) + 3
leader(index) = leader(index) - 5: leader(defend) = leader(defend) + 3
CALL flee(index, a): IF a > 0 AND strength(a) > 0 THEN uorder(index) = 100 * unity(a) + unitx(a)
GOTO woe

run1:
blox = 0
IF xnew < 1 XOR xnew > 55 THEN blox = 1: RETURN
IF ynew < 1 XOR ynew > 20 THEN blox = 1: RETURN
z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
IF LEFTY$(index) = "B" THEN IF z <> 176 THEN blox = 1
IF z = 176 AND LEFTY$(index) <> "B" THEN blox = 1
IF z = 233 THEN
	IF possess = 3 - id THEN blox = 1
END IF
CALL whois(xnew, ynew, Enemy, 0): IF Enemy > 0 THEN blox = 1
RETURN

woe:
IF blox > 0 GOTO steady
CALL Tara(unitx(index), unity(index) + 1, 0)

COLOR 7: IF index > m1 THEN COLOR 9
	unitx(index) = xnew: unity(index) = ynew
       
	FOR k = 1 TO mdly!
	ATTENTION index, 13
	NEXT k
       
	CALL YouorMe(defend, F)
	u$ = LEFTY$(defend)

	IF F = 0 THEN
		uorder(defend) = 100 * ynew + xnew
	ELSE
		IF rely > 2 AND INSTR("ANH", u$) = 0 THEN uorder(defend) = 100 * ynew + xnew
	END IF
	IF u$ = "E" THEN uorder(defend) = 0
	
	terrain(index) = z
	IF z = 233 THEN CALL TICK(mdly!): CALL victory(index)

steady: IF rout = 0 THEN TICK .2 * mdly!
	morale(index) = morale(index) - 10: IF morale(index) < 0 THEN morale(index) = 1
	killed = 1 + .02 * strength(index) + rout: IF killed > strength(index) THEN killed = strength(index)

score&(id) = score&(id) + killed
strength(index) = strength(index) - killed
CALL scrcol(2)
IF RND > .2 THEN leader(index) = leader(index) - 2: IF rout > 0 THEN leader(index) = leader(index) - INT(10 * RND)
	IF rout = 0 GOTO rip
	c = 2: IF LEFTY$(index) = "B" THEN c = 9
	x = 8 * unitx(index): y = 14 * unity(index)
	LINE (x, y)-(x + 15, y + 13), c, BF
	LINE (x + 3, y + 3)-(x + 12, y + 10), 13, BF
	LINE (x + 3, y + 3)-(x + 12, y + 10), 0, B
	LINE (x + 3, y + 3)-(x + 12, y + 10), 0
	LINE (x + 3, y + 10)-(x + 12, y + 3), 0

	a$ = "MFL16o2T140dd.dd.co1b.o2do3g.ab.bb.ag"
	IF index > m1 THEN a$ = "MFT170o2L16geL8ccL16cdefL8ggge"
	IF quiet = 1 THEN
		IF sblast$ = "" THEN
			PLAY a$
		ELSE
			SHELL "yell.exe"
		END IF
	ELSE
	TICK .5 * mdly!
	END IF
rip:
	CALL wipeout(index)
	CALL YouorMe(index, F): IF F > 0 THEN CALL inspect(index)
	CALL SHOWUNIT(index)
END SUB

SUB scentex
SCREEN 9, , 1, 1
CLS
x = 40 - .5 * LEN(SCENARIO$)
COLOR 14: LOCATE 1, x: PRINT SCENARIO$
COLOR 11
FOR k = 1 TO 22: IF LEN(stex$(k)) > 0 GOTO briefs
NEXT k
COLOR 14
stex$(11) = SPACE$(11) + "N O    B R I E F I N G    A V A I L A B L E"
briefs:
	FOR k = 1 TO 22: PRINT "  "; stex$(k)
NEXT k
COLOR 14
LINE (501, 318)-(635, 338), 4, BF
LOCATE 24, 65: PRINT "( press a key )";
COLOR 15: LOCATE 1, 2: PRINT "BRIEFING:"
LINE (1, 1)-(639, 14), 4, B
LINE (1, 1)-(639, 349), 4, B
CALL TICK(99)
SCREEN 9, , 0, 0
END SUB

SUB scrcol (flag)            '0=full draw  1=menu clear   2 or more =update info only
IF flag = 1 THEN LINE (454, 30)-(631, 152), 8, BF
IF flag < 2 THEN
	LINE (453, 152)-(631, 267), 4, B
	LINE (449, 2)-(449, 299), 4
	LINE (453, 13)-(631, 28), 4, B
	LINE (454, 14)-(630, 27), 0, BF
	LINE (454, 40)-(631, 86), 9, B
	LINE (455, 41)-(630, 85), 0, BF

	COLOR 9: LOCATE 4, 65: PRINT " "; UCASE$(sname$(2)): IF side = 2 THEN LOCATE 4, 60: PRINT ""
	LOCATE 5, 59: PRINT "LOSSES     :"; score&(2)
	LOCATE 6, 59: PRINT "OBJECTIVES :"; vp&(2): IF possess = 2 THEN LOCATE 6, 69: PRINT ""
     
	LINE (454, 95)-(631, 141), 7, B
	LINE (455, 96)-(630, 140), 0, BF
	COLOR 7: LOCATE 8, 62: PRINT " "; UCASE$(sname$(1)): IF side = 1 THEN LOCATE 8, 60: PRINT ""
	LOCATE 9, 59: PRINT "LOSSES     :"; score&(1)
	LOCATE 10, 59: PRINT "OBJECTIVES :"; vp&(1): IF possess = 1 THEN LOCATE 10, 69: PRINT ""
	LOCATE 2, 59: PRINT "Time Left :";
	COLOR 4: LOCATE 21, 61: PRINT "uiet": LOCATE 21, 71: PRINT "econ"
	IF campane > 0 THEN
		COLOR 13: LOCATE 24, 45: PRINT sname$(camwin); " "; region$(campane); " Campaign";
		LINE (350, 322)-(638, 335), 15, B
	END IF
	GOSUB tim1
ELSE
	IF flag > 10 THEN GOSUB tim1: EXIT SUB
	COLOR 9
	IF side = 2 THEN LOCATE 4, 60: PRINT ""
	LOCATE 5, 71: PRINT score&(2)
	LOCATE 6, 71: PRINT vp&(2)
	COLOR 7
	IF side = 1 THEN LOCATE 8, 60: PRINT ""
	LOCATE 9, 71: PRINT score&(1)
	LOCATE 10, 71: PRINT vp&(1)
	COLOR 14
	IF possess = 1 THEN LOCATE 10, 69: PRINT ""
	IF possess = 2 THEN LOCATE 6, 69: PRINT ""
	GOSUB tim1
END IF
EXIT SUB
tim1:
IF flag = 0 OR flag = 11 THEN CALL BUTTON(69, 21, 4, "R", recon): PAINT (69 * 8 - 4, 21 * 14 - 10), 7, 4
IF flag = 0 OR flag = 12 THEN CALL BUTTON(59, 21, 4, "Q", 1 - quiet): PAINT (59 * 8 - 4, 21 * 14 - 10), 7, 4
IF timex = 32767 THEN RETURN
COLOR 15: IF timelimit - timex < 21 THEN COLOR 12
LOCATE 2, 70: PRINT timelimit - timex
RETURN
END SUB

SUB scrnload (t$)
DEF SEG = &HB800
BLOAD t$, 0
DEF SEG
END SUB

SUB see (attack)
IF strength(attack) < 1 OR uorder(attack) = 99 GOTO nosee
CALL YouorMe(attack, dx)

seehim:
	CALL ranger(attack, vantage)
	s = m2: F = Bigg(2): IF attack > m1 THEN s = 1: F = Bigg(1)
	FOR defend = s TO F
	IF strength(defend) < 1 OR uorder(defend) = 99 GOTO ourboy
	IF defend = attack GOTO ourboy
	IF attack < m2 AND defend < m2 GOTO ourboy
	IF attack > m1 AND defend > m1 GOTO ourboy
	d = 2 * ABS(unity(attack) - unity(defend)) + ABS((unitx(attack) - unitx(defend)))
	IF d < 4 THEN
		GOTO suresee
	END IF

	IF d > vantage GOTO ourboy
	IF lineofsight > 0 THEN
		CALL los(attack, defend, F, 0)
		IF F = 0 GOTO ourboy
	END IF
'============================================================================
'                               Reveal Unit
'============================================================================
suresee:
	Visible(attack) = 1: Visible(defend) = 1
	CALL SHOWUNIT(defend): CALL SHOWUNIT(attack)
	IF terrain(defend) = 42 AND d > 4 GOTO ourboy
	u$ = LEFTY$(attack)
	IF INSTR("ANHBEG", u$) > 0 GOTO ourboy
	IF RND > .05 * bold GOTO ourboy

	pct# = strength(attack) / strength(defend)
	pct# = pct# * .001 * leader(attack) * morale(attack) / d
	IF pct# < 1.7 - .1 * bold GOTO ourboy
	IF uorder(attack) > 0 AND RND > .14 * bold GOTO ourboy
	IF uorder(attack) < 0 AND leader(attack) < 80 AND RND > .03 * bold GOTO ourboy
	IF uorder(attack) = 100 * objy + objx AND RND < .95 GOTO ourboy
	IF dx = 0 THEN IF RND > 1 - .1 * bold THEN uorder(attack) = 100 * objy + objx: EXIT SUB
	uorder(attack) = 100 * unity(defend) + unitx(defend)
	IF strength(defend) < 50 OR morale(defend) < 50 THEN CALL flee(defend, index): IF index > 0 THEN uorder(defend) = 100 * unity(index) + unitx(index)
	IF INSTR("ANHBG", LEFTY$(defend)) > 0 GOTO ourboy

	uorder(defend) = 100 * unity(attack) + unitx(attack): GOTO brave
	GOTO ourboy
brave:
	IF dx > 0 THEN index = attack: GOTO me1
	CALL YouorMe(defend, flag): IF flag > 0 THEN index = defend: GOTO me1
	GOTO ourboy
me1:
	IF RND < .01 * leader(index) - .1 * rely THEN uorder(index) = 0
	IF rely = 1 THEN uorder(index) = 0
	CALL proximity(index, 0, 0, bonus): IF bonus > 10 THEN uorder(index) = 0
	t$ = LEFTY$(index)
	IF INSTR("GANB", t$) > 0 THEN uorder(index) = 0
	IF t$ = "H" AND RND > .3 THEN uorder(index) = 0
ourboy:
	NEXT defend
	IF unity(attack) = objy AND unitx(attack) = objx THEN uorder(attack) = 0
nosee:
END SUB

SUB sndblst (mask$)
ON LOCAL ERROR GOTO nosound
IF sblast$ = "" OR quiet = 0 THEN EXIT SUB
CALL BuffClear
SELECT CASE mask$
	CASE "cannon1"
		IF RND > .7 THEN mask$ = "cannon2"
	CASE "cannon2"
		IF RND > .7 THEN mask$ = "cannon1"
	CASE "musket"
		IF RND > .4 THEN mask$ = "volly"
		IF RND > .7 THEN mask$ = "spenser"
END SELECT
SHELL "plany " + mask$ + ".wav": EXIT SUB
nosound:
RESUME sounder
sounder:
CALL clrbot: PRINT "Sound Driver Error Encountered": TICK 1
ON ERROR GOTO 0
END SUB

SUB TICK (sec!)
start! = TIMER
DO WHILE TIMER - start! < sec! AND INKEY$ = "": LOOP
END SUB

SUB trumpet (index)
IF quiet = 1 THEN
	IF sblast$ = "" THEN
		PLAY "MST220o3e4g8g2.g8g8g8o4c2MN"
	ELSE
		a$ = "dixie": IF index > m1 THEN a$ = "hymn"
		CALL sndblst(a$)
	END IF
END IF
END SUB

SUB valid (index)
IF morale(index) < 10 THEN morale(index) = 10
IF leader(index) < 10 THEN leader(index) = 10
IF morale(index) > 110 THEN morale(index) = 110
IF leader(index) > 110 THEN leader(index) = 110
END SUB

SUB variety
COLOR 11
IF file$ = "" AND SCENARIO$ = "" THEN EXIT SUB
FOR i = 1 TO 2: CALL Compact(i): NEXT i
COLOR 15
FOR k = 1 TO Bigg(2)
	IF strength(k) < 1 OR uorder(k) < 0 GOTO meat
	IF terrain(k) = 176 OR terrain(k) = 233 GOTO meat
	xold = unitx(k): yold = unity(k)
	unitx(k) = unitx(k) + 2: IF RND > .5 THEN unitx(k) = unitx(k) - 4
	unity(k) = unity(k) + 2: IF RND > .5 THEN unity(k) = unity(k) - 4
	IF unitx(k) < 2 OR unitx(k) > 54 OR unity(k) < 1 OR unity(k) > 20 THEN GOSUB cancelit: GOTO meat
	z = (unitx(k) + unity(k)) MOD 2
	IF z <> 0 THEN unitx(k) = unitx(k) + 1: IF unitx(k) > 28 THEN unitx(k) = unitx(k) - 2
	CALL whois(unitx(k), unity(k), Enemy, 0)
	IF Enemy > 0 THEN
		IF RND > .9 THEN uorder(k) = 99: toa(k) = 1 + .8 * RND * timelimit: GOTO meat
		GOSUB cancelit
		IF RND > .5 THEN strength(k) = strength(k) * (.5 + 1 * RND)
		GOTO meat
	ELSE
		z = ASC(MID$(sdtext$(unity(k) + 1), unitx(k), 1))
		IF z = 176 THEN GOSUB cancelit: GOTO meat
		terrain(k) = z
		x = x + 1: LOCATE 23, 14: PRINT x;
	END IF
meat: NEXT k
	EXIT SUB
cancelit:
	unity(k) = yold: unitx(k) = xold: RETURN
END SUB

SUB victory (index)
IF index < 1 OR terrain(index) <> 233 THEN EXIT SUB
COLOR 7: IF index > 40 THEN COLOR 9
a$ = ""
IF index < m2 AND possess <> 1 THEN possess = 1: GOSUB rebs: s = m2: F = Bigg(2)
IF index > m1 AND possess <> 2 THEN possess = 2: GOSUB yanks: s = 1: F = Bigg(1)
IF possess = side THEN closest = 32767 ELSE closest = 0
IF a$ = "" THEN EXIT SUB
CALL clrbot: COLOR 15: PRINT name$(index); " has taken the objective !";
IF quiet = 1 THEN
	IF sblast$ = "" THEN
		PLAY a$
	ELSE
		a$ = "dixie": IF index > m1 THEN a$ = "hymn"
		CALL sndblst(a$)
	END IF
END IF
CALL YouorMe(index, flag)
IF flag > 0 AND nplayer < 2 THEN
	FOR k = s TO F
		IF INSTR("GAHNB", LEFTY$(k)) = 0 AND uorder(k) <> 99 THEN uorder(k) = 100 * objy + objx
	NEXT k
		IF possess = 1 THEN
			s = 1: F = Bigg(1)
		ELSE
			s = m2: F = Bigg(2)
		END IF
	FOR k = s TO F
		IF uorder(k) = 100 * objy + objx THEN uorder(k) = 0
	NEXT k
END IF
CALL scrcol(1)
EXIT SUB
rebs: a$ = "MFT160o2L16geL8ccL16cdefL8ggge": RETURN
yanks: a$ = "MFL16o2T120dd.dd.co1b.o2do3g.ab.bb.ag": RETURN
END SUB

SUB whois (x, y, Enemy, index)
Enemy = 0
FOR k = 1 TO Bigg(2)
IF strength(k) < 1 OR uorder(k) = 99 OR index = k GOTO nobody
IF unitx(k) <> x GOTO nobody
IF unity(k) <> y GOTO nobody
Enemy = k: EXIT SUB
nobody:
NEXT k
END SUB

SUB wipeout (index)
IF index < 1 OR strength(index) > 0 OR unitx(index) = 1 THEN EXIT SUB
COLOR 9: a$ = sname$(2): x = 1
IF index < m2 THEN COLOR 7: a$ = sname$(1): x = 2
CALL clrbot: LOCATE 23, 15: PRINT a$; " unit "; name$(index); " has been eliminated";
vp&(x) = vp&(x) + factor(1): CALL scrcol(2)
uorder(index) = 0: strength(index) = 0
unit$(index) = "X"
CALL SHOWUNIT(index)
unit$(index) = ""
CALL dirge
CALL TICK(mdly!)
CALL Tara(unitx(index), unity(index) + 1, 0)

s = 1: IF index > m1 THEN s = 2
CALL Compact(s): index = 0: IF strength(1) > 0 AND strength(41) > 0 THEN EXIT SUB

dx = 0: FOR k = 1 TO Bigg(1): IF strength(k) > 0 THEN dx = 1: EXIT FOR
NEXT k
dy = 0: FOR k = m2 TO Bigg(2): IF strength(k) > 0 THEN dy = 1: EXIT FOR
NEXT k

IF dx > 0 AND dy > 0 THEN EXIT SUB
s = 2: IF dx = 0 THEN s = 1
plus = .1 * (vp&(3 - s) + score&(s))
COLOR 14: CALL clrbot: PRINT sname$(s); " forces ANNIHILATED :"; plus; " Bonus Points!";
vp&(3 - s) = vp&(3 - s) + plus
timex = timelimit: TICK 99
END SUB

SUB YesNo (a$)
tly = 2: colour = 4
tlx = 62 - .5 * LEN(mtx$(0))
mtx$(1) = "No"
mtx$(2) = "Yes"
size = 2: CALL menu
IF choose < 1 OR choose > 2 THEN a$ = "X" ELSE a$ = LEFT$(LTRIM$(mtx$(choose)), 1)
END SUB

SUB YouorMe (index, F)
F = 0: IF side = 1 AND index < m2 THEN F = 1
IF side = 2 AND index > m1 THEN F = 1
END SUB

