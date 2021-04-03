DEFINT A-Z
SCREEN 0: CLS
PRINT "PBMFIX removes extra carriage return/line feeds from PBM files"
PRINT "Working";
        OPEN "I", 1, "savegame.pbm"
        OPEN "O", 2, "savegame.fix"
        a$ = ""
        DO WHILE NOT EOF(1)
                sv$ = INPUT$(1, #1)
                IF sv$ <> CHR$(13) THEN
                        IF ASC(sv$) <> 10 THEN a$ = a$ + sv$: ff = 0
                ELSE
                        IF ff < 1 THEN PRINT #2, a$: ff = ff + 1: a$ = "": PRINT ".";
                END IF
        LOOP
        CLOSE #2
        CLOSE #1
PRINT "Done"
PRINT "Your original SAVEGAME.PBM has been renamed SAVEGAME.OLD"
SHELL "rename savegame.pbm savegame.old"
SHELL "rename savegame.fix savegame.pbm"

