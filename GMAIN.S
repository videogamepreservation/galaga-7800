;*******************************************************************************
;GMAIN.S
          ORG     $8000
BEGIN
          LDX     #71                     ;ZERO OUT ENMYLIST (TYPE)
XZERO     LDA     #0
          STA     TYPE,X
          LDA     #1
          STA     ANGLE,X
          DEX
          BPL     XZERO
          LDX     #40
XAVIDSUX  LDA     #0
          STA     NEWTYPE,X
          DEX
          BPL     XAVIDSUX
          LDA     RSTRTREG               ;SEE IF A RESTART HAS OCCURED
          BEQ     LOGO
          LDA     #0
          STA     RSTRTREG               ;CLEAR FLAG
          JMP     GOTORES
LOGO      JSR     SETLOGO
          JSR     SCRAPALL
          JMP     TITLPPP
SETLOGO   LDA     #1
          STA     TEMP1
          LDA     #$F0
          STA     TEMP2
          LDX     #18
          LDY     #65                    ;START WITH 2ND PAGE GRAPHICS
LLOGO     TXA
          STA     TYPE,Y
          INX
          INY
          CPX     #24
          BNE     LLOGO
          LDA     #30
          STA     XCORD+65
          STA     XCORD+66
          LDA     #82
          STA     XCORD+67
          STA     XCORD+68
          LDA     #70
          STA     XCORD+69
          STA     XCORD+70
          LDA     #72
          STA     YCORD+65
          STA     YCORD+67
          LDA     #84
          STA     YCORD+66
          STA     YCORD+68
          LDA     #96
          STA     YCORD+69
          LDA     #108
          STA     YCORD+70
          LDA     #0
          STA     ANGLE
          STA     TEMP3                  ;INITIALLY POSITIVE
          LDA     #$48
          STA     YCORD
          LDA     #$50
          STA     XCORD
;THIS SECTION SETS UP THE TWINKLE
          LDA     #35
          STA     TYPE
          LDA     #7                     ;USE Y AS A LOCATION VARIABLE
          STA     BOZO0                  ;THIS SAVES THE Y VALUE
          RTS                            ;END OF LOGO SETUP SUBROUTINE

TITLPPP   LDA     #0
          STA     FRAME                  ;SET UP FRAME
TITLOOP   DEC     FRAME
TITLP1    LDA     FRAME
          BMI     TITLP1
          JSR     TWINKEL                ;TWINKLE SUBROUTINE
          LDA     SELECT                 ;SEE IF IN SELECT MODE
          BEQ     NOTOSEL
          JMP     GOTOSEL
NOTOSEL   LDA     TEMP2
          BEQ     DOHSC                  ;DO HSC AFTER TITLE PAGE

ATIT      LDA     SWCHB                  ;GET LOCAL INPUTS
          LSR     A
          BCS     ATIT2
          JMP     GOTORES
ATIT2     LSR     A
          BCS     ATIT3
          JMP     GOTOSEL
ATIT3     LDA     SWCHA                  ;LOOK AT JOYSTICK INPUT
          ORA     #$0F                   ;BOOT PLAYER 2 INPUT
          CMP     #$FF                   ;SEE IF ANY INPUT
          BEQ     FUCKYOU
          JMP     GOTOSEL                ;GO TO SELECT MODE
FUCKYOU   BIT     INPT4                  ;LOOK AT FIRE BUTTON INPUT
          BMI     ATIT4
          JMP     GOTORES
ATIT4     LDA     #0
          STA     FLAP                   ;PREVENT FLAPPING IN LOADER
          JMP     TITLOOP

DOHSC     LDA     #0
          STA     DIFCULTY               ;SET DIFFICULTY FOR NOVICE
          JSR     SETLOGO                ;SETS UP THE LOGO DISPLAY
          LDA     #1
          STA     INHSC                  ;INDICATE IN HSC MODE
          JSR     HSCTEST                SEE IF THERE IS A DISPLAY FOR THIS
          BMI     NONOVICE
          LDA     #1
          STA     INHSC
          JSR     HSCDSPLY               ;DISPLAY HISCORECART
          JSR     GAMEPOLL               SEE IF ANY INPUT
          BCS     NOEXPERT
NONOVICE  INC     DIFCULTY
          JSR     HSCTEST                SEE IF ADVANCED TABLE
          BMI     NOADVNCD
          LDA     #1
          STA     INHSC
          JSR     HSCDSPLY
          JSR     GAMEPOLL               SEE IF ANY INPUT
          BCS     NOEXPERT
NOADVNCD  INC     DIFCULTY
          JSR     HSCTEST                SEE IF EXPERT TABLE
          BMI     NOEXPERT
          LDA     #1
          STA     INHSC
          JSR     HSCDSPLY
NOEXPERT  LDA     #$40
          STA     CTRLWT                 RESET THE CORRECT CONTROL WORD
          JSR     CLEARDL1
          JMP     ENDCLEAR

CLEARDL1                                 ;THIS SUBROUTINE CLEARS THE FIRST DLIST
          LDA     #$18
          STA     TEMP1+1                TEMP1 NOW HAS THE ADDRESS 1801
          LDX     #15                    LOOP 16 TIMES
          LDA     #0
          STA     TEMP1
DLST1CLR  LDY     #0
          TYA
          STA     (TEMP1),Y
          INY
          STA     (TEMP1),Y
          LDA     TEMP1
          CLC
          ADC     #82                    INC TO NEXT DLST
          STA     TEMP1
          LDA     TEMP1+1
          ADC     #0
          STA     TEMP1+1
          DEX
          BPL     DLST1CLR
          RTS

ENDCLEAR  LDA     #L(DLSTLST1)
          STA     DPPL
          LDA     #H(DLSTLST1)
          STA     DPPH
          LDA     #0
          STA     DLSPTR                 ;NEXT DLI WILL BUILD DISPLAY LIST 2
;         STA     TWOPLAYR               ;SET TO ONE PLAYER MODE FOR AUTOPLAY
          STA     INHSC
          STA     AUTOPLAY               ;THIS JUST SETS UP AUTOPLAY NOW
          LDA     #9
          STA     AUTOPLAZ               ;ADDITIONAL COUNTER
          STA     AUTOPLAY               ;NEEDS A NON-ZERO VALUE
          JMP     ATITOUT                ;GO INTO GAME LOOP
GOTOSEL
          LDA     #$20
          STA     MISTIMER               ;DONT ALLOW SHOT TO BE FIRED
          STA     TEMP2                  ;KEEP STAR TWINKLING
          STA     SELECT                 ;INDICATE IN SELECT MODE
          LDA     #0
          STA     AUTOPLAY               ;CLEAR AUTOPLAY MODE
          STA     AUTOPLAZ
          STA     FLAP                   ;PREVENT FLAPPING IN LOADER
          BIT     INPT4                  ;SEE IF FIRE BUTTON HIT
          BMI     CONTSEL                ;IF HIT, START GAME
SELRES    JMP     GOTORES
CONTSEL   LDA     SWCHB
          LSR     A
          BCC     SELRES                 ;SEE IF RESET HIT DURING SELECT
*THIS SECTION KEEPS UP THE SELECTION DISPLAY
          LDA     #47                    ;PLAYERS TYPE
          STA     TYPE+71                ;STORE IN TYPE LIST
          LDA     #40
          STA     XCORD+71
          LDA     #132
          STA     YCORD+71
          STA     YCORD+1
          LDA     #1
          STA     ANGLE+71
          STA     ANGLE+1
          LDY     #48
          LDA     TWOPLAYR               ;GET TWOPLAYER REGISTER
          BEQ     SHOWONE
          INY
SHOWONE                                  ;'1' TYPE
          STY     TYPE+1
          LDA     #90
          STA     XCORD+1
;THIS SECTION PUTS UP THE PLAY LEVEL
          LDA     #46                    ;'LEVEL' TYPE
          STA     TYPE+2
          LDA     #40
          STA     XCORD+2
          LDA     #144
          STA     YCORD+2
          STA     YCORD+3
          LDA     #1
          STA     ANGLE+2
          STA     ANGLE+3
          LDY     #44
          LDA     LEVELSEL               ;GET LEVEL SELECTION REGISTER
          BMI     DONOVICE               ;$FF IS NOVICE
          BNE     FINLEVEL               ;1 IS EXPERT, 0 IS ADVANCED
          DEY
          DEY                            ;43 IS ADVANCED
DONOVICE  INY                            ;45 IS NOVICE
FINLEVEL  STY     TYPE+3                 ;44 IS EXPERT
          LDA     #80
          STA     XCORD+3
;THIS SECTION DOES THE SELECTION ADVANCE
          DEC     SELTIMER               ;SEE IF TIME TO LOOK AT JOYSTICK
          BNE     ENDSEL
          LDA     #20
          STA     SELTIMER               ;RESET SELTIMER
          LDA     SWCHA                  ;GET JOYSTICK INPUT
          ORA     #$0F                   ;BOOT PLAYER 2 INPUT
          CMP     #$FF
          BEQ     CHKSWB                 ;LOOK AT LOCAL INPUT
          ASL     A
          BCC     INCDIFF                ;INC DIFFICULTY
          ASL     A
          BCC     DECDIFF                ;DEC DIFFICULTY
          ASL     A
          BCS     INCPLYR
          LDA     #0
          STA     TWOPLAYR               ;SET PLAYERS TO 1
          BEQ     ENDSEL
INCPLYR   LDA     #1
          STA     TWOPLAYR               ;SET PLAYERS TO 2
          BNE     ENDSEL
INCDIFF   LDA     LEVELSEL               ;GET LEVEL SELECTION REG
          CMP     #1
          BEQ     ENDSEL
          INC     LEVELSEL
          JMP     TITLOOP
DECDIFF   LDA     LEVELSEL
          BMI     ENDSEL
          DEC     LEVELSEL
ENDSEL
          DEC     BOZO2
          BNE     ENDSELL
          DEC     BOZO3
          BNE     ENDSELL
          LDA     #0
          STA     SELECT                 GO BACK TO GAME LOOP
ENDSELL   JMP     TITLOOP
CHKSWB    LDA     SWCHB
          LSR     A
          LSR     A                      ;LOOK AT SELECT INPUT
          BCS     NOSEL
;SELECT ACTIVE, NEED TO SEE IF WAS ACTIVE BEFORE
          LDA     SELTGL
          BNE     CHKTIMER               ;WAS ON, CHECK IF TIME TO INC OPTIONS
          INC     SELTGL                 ;SET TOGGLE TO ON
          LDA     #5
          STA     SELDELAY               ;INITIALIZE SELECT DELAY
          JMP     INCOPTNS               ;WASN'T ON, MUST INC OPTIONS
NOSEL     LDA     #0
          STA     SELTGL                 ;SET SELECT TOGGLE TO OFF
          BEQ     ENDSEL
CHKTIMER  DEC     SELDELAY
          BPL     ENDSEL                 ;NOT LONG ENOUGH BETWEEN OPTION CHNG
          LDA     #05
          STA     SELDELAY
INCOPTNS  LDA     LEVELSEL
          CMP     #1                     ;SEE IF HIGHEST LEVEL
          BEQ     CHPLYER                ;IF HIGHEST LEVEL, CHANGE PLAYER #
          INC     LEVELSEL
          JMP     ENDSEL
CHPLYER   LDA     #$FF
          STA     LEVELSEL               ;RESET LEVEL TO LOWEST SETTING
          LDA     TWOPLAYR
          BEQ     CHPLYER1
          LDA     #0
          STA     TWOPLAYR               ;SET TO ONE PLAYER
          BEQ     ENDSEL
CHPLYER1  INC     TWOPLAYR               ;SET TO TWO PLAYERS
          JMP     ENDSEL
GOTORES
;CALL GALAGA TUNE HERE
          JSR     SCRAPALL
          LDA     #0
          JSR     TUNIN
          LDA     #1
          JSR     TUNIN
          LDA     #$20                   ;PREVENT SHOT FIRE
          STA     MISTIMER
          LDA     #0
          STA     AUTOPLAY               ;CLEAR AUTOPLAY MODE
          STA     SELECT                 ;CLEAR SELECT MODE
          JSR     CLRSCORE
          BMI     ATITOUT                ;CLRSCORE RETURNS MINUS
CLRSCORE  LDX     #5
ZZLOP     STA     P1SCORE,X              ;ZERO OUT THE SCORES
          DEX
          BPL     ZZLOP
          LDA     #$A
          LDX     #15
ZZZLOP    STA     SCORE,X                ;BLANK OUT THE SCORE DISPLAY
          DEX
          BPL     ZZZLOP
          RTS
ATITOUT   LDA     #4
          STA     LIVES
          LDX     TWOPLAYR
          BEQ     ZILOUT
          STA     LIVES+1
ZILOUT    LDA     LEVELSEL
          BMI     LOWRACK
          BEQ     LOWRACK
          LDA     #2
          STA     CHALNUM                ;START W/ CHAL STG NUMBER 3
          LDA     #5
          STA     WAVEREG                ;INIT WAVEREG TO RACK 10
          LDA     #$10
          STA     GASTONHK               ;STORE BCD RECORD OF RACK
          LDA     #10
          STA     CHALINDX               ;INIT CHALINDX TO RACK 10
          BNE     LOWRACK1
LOWRACK   LDA     #1
          STA     GASTONHK               ;STORE BCD RECORD OF RACK
LOWRACK1  STA     RACK
          STA     RLOGO
          LDA     #0
          LDX     #71
XXERO     STA     TYPE,X
          STA     ANGLE,X
          STA     MODE,X                 ;ZERO OUT MODE AS WELL
          DEX
          BPL     XXERO
          LDA     #5
          STA     TYPE+63
          LDA     #$80
          STA     RACKREG
          STA     ANGLE+63
          STA     ANGLE+62
          LDA     #171
          STA     YCORD+63
          LDA     #0
          STA     MODE+40
          STA     TYPE+62
          STA     MODE+63
          LDY     #35
ZCOPY                                    ;SAVE ALL 2ND PLAYER VARIABLES
          LDA     ARRIVED,Y
          STA     SAVES,Y
          DEY
          BPL     ZCOPY
          LDA     #$4F
          STA     RDYREG                 ;GIVE INITIAL DELAY TO GAME
          LDA     #1
          STA     ABORT                  ;GIVE GAME DELAY
BLOOP
          LDA     FRAME
          BMI     BLOOP
          JSR     UPENLIST
          JSR     COLDET1
          JSR     COLDET2
          JSR     ATTACK
          JSR     ADDSCORE
          JSR     TOFIRE
          JSR     HEROSPIN
          JSR     CHBONUS
          JSR     WORDS
          JMP     BLOOP
CHBONUS
          LDA     SCRTIME                ;SEE IF TIME FOR SCORE DISPLAY
          BNE     CHBONUS1
          JMP     ENDBONS2
*WILL NOT LEAVE THIS LOOP UNTIL DONE WITH ALL DISPLAY
CHBONUS1  LDA     #1
          LDY     #65
CHBONUS2  STA     ANGLE,Y                ;SET ALL ANGLES TO 1
          INY
          CPY     #72
          BNE     CHBONUS2
          JSR     CLREXPLO               CLEAR ANY REMAINING EXPLOSIONS
          LDA     CHALSCR                ;GET SCORE FOR STAGE
          CMP     #$40                   ;SEE IF PERFECT SCORE
          BNE     NOFANFR
          LDA     #17
          JSR     TUNIN
          LDA     #18
          JSR     TUNIN                  ;CALL PERFECT SCORE FANFARE
          JMP     NOFAN2
NOFANFR   LDA     #19
          JSR     TUNIN
          LDA     #20
          JSR     TUNIN                  ;CALL REGULAR STATS MUSIC
NOFAN2    LDA     #0
          STA     TYPE+56
          STA     TYPE+57                ;CLEAR OUT HERO MISSILES
          LDA     #36                    ;'NUMBER OF HITS' TYPE
          STA     TYPE+65
          LDA     #72
          STA     YCORD+65
          LDA     #26
          STA     XCORD+65
          LDA     #90
          STA     SCRTIME                ;USE THIS AS A TEMP LOCATION
          JSR     SCRDELAY               ;WAIT 60 FRAMES
          LDA     CHALSCR
          LSR     A
          LSR     A
          LSR     A
          LSR     A                            ;GET RID OF LOWER NIBBLE
          STA     ANGLE+66
          STA     ANGLE+69
          STA     TEMP4                  ;HIGH DIGIT OF SCORE
          BEQ     NOZEROS                ;DONT SHOW IF LEADING ZERO
          LDA     #40                    ;DIGIT TYPE
          STA     TYPE+66
NOZEROS   LDA     #40
          STA     TYPE+67
          LDA     #72
          STA     YCORD+66
          STA     YCORD+67
          LDA     #113
          STA     XCORD+66
          LDA     #81
          STA     XCORD+69
          LDA     #119
          STA     XCORD+67
          LDA     #87
          STA     XCORD+70
          LDA     CHALSCR
          AND     #$0F                   ;BOOT HIGH NIBBLE
          STA     ANGLE+67
          STA     ANGLE+70
          ASL     A
          ASL     A
          ASL     A
          ASL     A
          STA     TEMP5                  ;LOW BYTE OF SCORE
          LDA     #90
          STA     SCRTIME
          JSR     SCRDELAY               ;WAIT 60 FRAMES
          LDA     CHALSCR
          CMP     #$40                   ;SEE IF PERFECT SCORE
          BEQ     PRFCTSCR
          LDA     #39
          STA     TYPE+68                ;SET 'BONUS' TYPE
          LDA     #96
          STA     YCORD+68
          STA     YCORD+69
          STA     YCORD+70
          STA     YCORD+71
          LDA     #45
          STA     XCORD+68
          LDA     #90
          STA     SCRTIME
          JSR     SCRDELAY               ;WAIT 60 FRAMES
          LDA     #40                    ;DIGIT TYPE
          STA     TYPE+69
          STA     TYPE+70
          LDA     ANGLE+69               ;SEE IF IS ZERO
          BNE     NOTXERO
          STA     TYPE+69                ;DONT SHOW IT
          LDA     ANGLE+70
          BNE     NOTXERO
          STA     TYPE+70                ;DONT SHOW IT
NOTXERO   JSR     ADDSCORE
          LDA     #42                    ;DOUBLE ZERO TYPE
          STA     TYPE+71
          LDA     #93
          STA     XCORD+71
          LDA     #$B0
          STA     SCRTIME
          JSR     SCRDELAY
          JMP     ENDBONUS
PRFCTSCR  LDA     #37
          STA     TYPE+71
          LDA     #48
          STA     YCORD+71
          LDA     #60
          STA     XCORD+71
          LDA     #30
          STA     SCRTIME
          JSR     SCRDELAY               ;PERFECT ON
          LDA     #0
          STA     TYPE+71
          LDA     #30
          STA     SCRTIME
          JSR     SCRDELAY               ;PERFECT OFF
          LDA     #37
          STA     TYPE+71
          LDA     #38
          STA     TYPE+68                ;'SPECIAL BONUS' TYPE
          LDA     #20
          STA     XCORD+68
          LDA     #96
          STA     YCORD+68
          LDA     #30
          STA     SCRTIME
          JSR     SCRDELAY               ;PERFECT ON
          LDA     #0
          STA     TYPE+71
          LDA     #30
          STA     SCRTIME
          JSR     SCRDELAY               ;PERFECT OFF
          LDA     #37
          STA     TYPE+71
          LDA     #0
          STA     TEMP5
          LDA     #10
          STA     TEMP4                  ;GIVES SCORE OF 10,000 BONUS
          JSR     ADDSCORE
          LDA     #41
          STA     TYPE+69                ;TEN THOUSAND TYPE
          LDA     #1
          STA     ANGLE+69               ;RESET THE ANGLE
          LDA     #96
          STA     YCORD+69
          LDA     #107
          STA     XCORD+69
          LDA     #30
          STA     SCRTIME
          JSR     SCRDELAY               ;PERFECT ON
          LDA     #0
          STA     TYPE+71
          LDA     #30
          STA     SCRTIME
          JSR     SCRDELAY               ;PERFECT OFF
          LDA     #37
          STA     TYPE+71
ENDBONUS  LDA     #0
          LDY     #65
ENDBONS1  STA     TYPE,Y
          INY
          CPY     #72
          BMI     ENDBONS1               ;CLEAR ALL TYPES
          STA     CHALSCR                ;RESET SCORE REGISTER
;         LDA     XCORD+63
 ;        STA     HEROX                  ;RESET HEROS POSITION
ENDBONS2  RTS
SCRDELAY  DEC     FRAME                  ;THIS SUBROUTINE CAUSES A DELAY
SCRDLY1   LDA     FRAME                  ;DELAY LENGTH IS STORED IN SCRTIME
          BMI     SCRDLY1
          DEC     SCRTIME
          BEQ     SCRDLY2
          DEC     FRAME
          JMP     SCRDLY1
SCRDLY2   RTS
WORDS     LDA     RDYREG                 ;SEE IF READY SHOULD BE DISPLAYED
          BEQ     WORDS0                 ;GO TO NEXT WORD SECTION
          SEC
          SBC     #1
          STA     RDYREG
          BEQ     WORDS1                 ;RESET LOGO
          CMP     #$4E                   ;SEE IF FIRST TIME THROUGH
          BNE     WORDS0                 ;GO TO NEXT WORD SECTION
;THIS SECTION DISPLAYS THE "READY" LOGO
          LDA     #26                    ;THIS IS READY TYPE
          STA     TYPE+65
          LDA     #96
          STA     YCORD+65
          LDA     #65
          STA     XCORD+65
          LDA     #1
          STA     ANGLE+65
          JMP     WORDS0
WORDS1    LDA     #0
          STA     ABORT                  ;RESET ABORT REGISTER
          STA     TYPE+65
;THIS SECTION DISPLAYS THE "PLAYER X" LOGO
WORDS0    LDA     PLAYRREG
          BEQ     WORDS2                 ;GO TO NEXT SECTION
          SEC
          SBC     #1
          STA     PLAYRREG
          BEQ     WORDS3                 ;RESET LOGO
          CMP     #$4E
          BNE     WORDS2                 ;GO TO NEXT SECTION
          LDA     #25
          STA     TYPE+66
          LDA     #84
          STA     YCORD+66
          LDA     #55
          STA     XCORD+66
          LDA     #1
          STA     ANGLE+66
;DISPLAY  "1" OR "2"
          LDA     GMOVEREG
          BEQ     WPLAYER0
          LDA     PLAYER
          BNE     WPLAYER1
          LDA     #32
          JMP     WPLAYER2
WPLAYER0  LDA     PLAYER
          BEQ     WPLAYER1
          LDA     #32
          JMP     WPLAYER2               ;PLAYER 2 TYPE
WPLAYER1  LDA     #31                    ;PLAYER 1 TYPE
WPLAYER2  STA     TYPE+67
          LDA     #84
          STA     YCORD+67
          LDA     #95
          STA     XCORD+67
          LDA     #1
          STA     ANGLE+67
          JMP     WORDS2
WORDS3    LDA     #0
          STA     TYPE+66                ;RESET LOGO
          STA     TYPE+67
;THIS SECTION HANDLES A "CHALLENGING STAGE"
WORDS2    LDA     CHLNGREG
          BEQ     WORDS4                 ;GO TO NEXT SECTION
          SEC
          SBC     #1
          STA     CHLNGREG
          BEQ     WORDS5                 ;RESET LOGO
          CMP     #$4E
          BNE     WORDS4                 ;GO TO NEXT SECTION
          JSR     CLREXPLO
          LDY     #29
          STY     TYPE+65
          INY                            ;Y NOW HAS 30
          STY     TYPE+66
          STY     XCORD+65
          LDA     #96
          STA     YCORD+65
          STA     YCORD+66
          LDA     #100
          STA     XCORD+66
          LDA     #1
          STA     ANGLE+65
          STA     ANGLE+66
          JMP     WORDS4
WORDS5    LDA     #0
          STA     TYPE+65
          STA     TYPE+66
;THIS SECTION HANDLES "GAME OVER"
WORDS4    LDA     GMOVEREG
          BNE     NOWORDS6                 ;GO TO NEXT SECTION
GOWORDS6  JMP     WORDS6
NOWORDS6  SEC
          SBC     #1
          STA     GMOVEREG
          BNE     PISMEOFF
          JMP     WORDS7                 ;RESET LOGO
PISMEOFF  CMP     #$4E
          BNE     GOWORDS6               ;GO TO NEXT SECTION
          JSR     CLREXPLO
          LDA     #28
          STA     TYPE+68
          LDA     #96
          STA     YCORD+68
          LDA     #55
          STA     XCORD+68
          LDA     #1
          STA     ANGLE+68
          LDA     GAMEOVER
          BEQ     WORDS6                 ;GAME NOT OVER, GO ON
          LDA     #1
          STA     LIVES                  ;KEEPS LOADER FROM BARFING
          STA     LIVES+1
WORDS8            ;NOT USED
          LDA     #$FF
          STA     SCRTIME                ;USE SCRDELAY AS A WAIT LOOP
          JSR     SCRDELAY
          JSR     STATS                  ;SHOW THE GAME STATS
          LDA     FARREN
          BMI     HSCBAR
          LDA     #1
          STA     INHSC
          LDY     #1
          LDX     #71
CLRTYPES  LDA     #0
          STA     TYPE,X                 ;BOOT ALL EXTRAEOUS CHARACTERS
          TYA
          STA     ANGLE,X
          DEX
          BPL     CLRTYPES
          JSR     SETLOGO                ;SET UP THE LOGO DISPLAY
          LDA     LEVELSEL
          CLC
          ADC     #1                     ;DIFCULTY MUST BE 0 OR GREATER
          STA     DIFCULTY
          LDA     #0
          STA     PLAYER
          JSR     HSCENTER
          LDA     TWOPLAYR               ;SEE IF TWO PEOPLE PLAYING
          BEQ     ONLYONE
          LDA     #1
          STA     PLAYER
          JSR     HSCENTER
ONLYONE   LDA     #0
          STA     INHSC
          LDA     #$40
          STA     CTRLWT                 ;RESTART THE DLI'S
          LDA     #L(DLSTLST1)
          STA     DPPL
          LDA     #H(DLSTLST1)
          STA     DPPH
          LDA     #0
          STA     DLSPTR
HSCBAR    LDX     #$FF
          TXS
          JMP     RESTART
WORDS7    LDA     #0
          STA     TYPE+68                ;RESET "GAME OVER" LOGO
          STA     GMOVEREG
          LDA     #$4F
          STA     RDYREG
          STA     PLAYRREG
;THIS SECTION HANDLES "FIGHTER CAPTURED"
WORDS6    LDA     CAPTDREG
          BEQ     WORDS10                 ;GO TO NEXT SECTION
          SEC
          SBC     #1
          STA     CAPTDREG
          BEQ     WORDS9
          CMP     #$4E                   ;SEE IF FIRST TIME THROUGH
          BNE     WORDS10                 ;GO TO NEXT SECTION
          LDY     #33                    ;FIGHTER TYPE
          STY     TYPE+65
          INY
          STY     TYPE+66
          LDA     #30
          STA     XCORD+65
          LDA     #80
          STA     XCORD+66
          LDA     #96
          STA     YCORD+65
          STA     YCORD+66
          LDA     #1
          STA     ANGLE+65
          STA     ANGLE+66
          JMP     WORDS10
WORDS9    LDA     #0
          STA     TYPE+65
          STA     TYPE+66
*THIS SECTION HANDLES AUTOPLAY MODE
WORDS10
          LDA     AUTOPLAY               ;SEE IF IN  AUTOPLAY MODE
          BEQ     WORDS11
          BIT     INPT4                  ;LOOK AT JOYSTICK FIRE BUTTON
          BMI     WORDS12                ;NO INPUT, GO ON
          LDX     #$FF
          TXS
          STX     RSTRTREG               ;INDICATE GAME RESTART
          JMP     RESTART
WORDS12
          LDA     SWCHA                  ;CHECK JOYSTICK INPUT
          ORA     #$0F                   ;BOOT PLAYER 2 INPUT
          CMP     #$FF
          BEQ     WORDS14
          LDX     #$FF
          TXS
          TXA
          STA     SELECT                 ;INDICATE SELECT MODE NOW
          JMP     RESTART
WORDS14   DEC     AUTOPLAY
          BNE     WORDS11
          DEC     AUTOPLAZ
          BEQ     WORDS15
          LDA     #$FF
          STA     AUTOPLAY
          BNE     WORDS11
WORDS15   LDX     #$FF
          TXS
          JMP     RESTART                ;GO BACK TO TITLE PAGE DISPLAY
*THIS SECTION HANDLES RESETS OR SELECTS WHICH OCCUR AT ANY TIME
WORDS11   LDA     SWCHB
          LSR     A
          BCS     WORDS16
          LDX     #$FF
          TXS
          STX     RSTRTREG               ;INDICATE GAME RESTART
          JMP     RESTART
WORDS16   LSR     A                      ;CHECK FOR SELECT SWITCH SET
          BCS     WORDS17
          LDX     #$FF
          TXS
          TXA
          STA     SELECT
          JMP     RESTART

WORDS17   LDA     PAUSTOG                ;SEE IF PAUSE INPUT IS VALID
          ASL     A                      ;SET CARRY BIT IF PAUSE INVALID
          BCC     PSVALID
          INC     PAUSTOG                WILL EVENTUALLY INC TO ZERO
          BCS     SKIPPAUS
PSVALID   LDA     #$F0
          STA     PAUSTOG
          LDA     SWCHB
          LSR     A
          LSR     A
          LSR     A
          LSR     A
;NO CARRY INDICATES PAUSE IS BEING PUSHED
SKIPPAUS  BIT     PAUSE
          BPL     NOPAUSON               ;PAUSE WASN'T ON ALREADY
          BCC     PAUSOFF                ;PAUSE WAS ON, NOW TAKE IT OFF
;INC ALL COUNTERS HERE
PAUSCNT   INC     PAUSECT1
          BNE     PAUSCNTL
          INC     PAUSECT2
          BNE     PAUSCNTL
          LDA     #$FF
          STA     CTRLWT                 ;BLANK OFF THE SCREEN DISPLAY
          LDA     #$80
          STA     PAUSE                  ;INDICATES THAT SCREEN IS OFF
PAUSCNTL  LDA     SWCHA
          CMP     #$FF                   ;SEE IF ANY INPUT AT ALL
          BEQ     PAUSFIRE               ;NO INPUT, CONTINUE TO SCAN
PAUSFIR1  LDA     #0
          STA     PAUSECT1
          LDA     #$D0
          STA     PAUSECT2               ;RESET THESE COUNTERS
          LDA     #$40
          STA     CTRLWT                 ;RESET THE DISPLAY
          LDA     #$FF
          STA     PAUSE                  ;INDICATE SCREEN ON MODE AGAIN
          BNE     PAUSWAIT
PAUSFIRE  BIT     INPT4                  ;SEE IF FIRE BUTTON HIT
          BPL     PAUSFIR1
PAUSWAIT  DEC     FRAME
PAUSWT    LDA     PAUSE
          CMP     #$80                   ;NO DMA IN THIS MODE
          BEQ     WORDS17
          LDA     FRAME
          BMI     PAUSWT
          BPL     WORDS17

NOPAUSON  BCS     WORDSEND               ;PAUSE NOT ON, NO PAUSE INPUT GIVEN
          LDA     #$FF
          STA     PAUSE                  ;INDICATE PAUSE ON NOW
          LDA     #0
          STA     AUDV0
          STA     AUDV1                  ;SILENCE CURRENT SOUNDS
          BCC     PAUSCNT                ;GO TO PAUSE COUNTING ROUTINE

PAUSOFF   LDA     #0
          STA     PAUSE                  ;CLEAR PAUSE
          STA     FRAME
          STA     PAUSECT1
          LDA     #$D0
          STA     PAUSECT2               ;RESET COUNTERS
          LDA     #$40
          STA     CTRLWT                 ;RESET THE CONTROL WORD
WORDSEND  DEC     FRAME                  ;END OF GAME LOOP
          RTS

HSTAR     DB      010,140,080,075,030,020,050,130        ;HORIZONTAL
          DB      100,090,130,080,070,020,030,130        ;POSITION
          DB      020,080,085,145,020,003,050,030        ;FOR
          DB      110,157,095,125,048,011,150,037        ;THE STARS
          DB      038,003,092,111,057,141,042,043
          DB      065,072,030,095,048,080,138,087
          DB      024,117,009,150,058,088,036,080
          DB      104,068,094,031,064,007,150,111
          DB      022,088,066,109,139,117,045,036
          DB      043,009,081,094,051,112,018,043
          DB      031,083,137,090,067,003,077,037
          DB      126,078,093,125,007,157,033,056
          DB      023,003,069,115,087,060,097,100
          DB      055,023,077,016,146,086,045,081
          DB      017,143,042,073,051,035,058,033
          DB      098,052,036,103,010,071,150,111

;TWINKY    DB      $43,$50,$41,$48,$52,$50,$5D,$49

;TWINKX    DB      $28,$3E,$47,$50,$30,$57,$5B,$72

STATS
          LDY     #70
          LDA     #0
STATS2    STA     TYPE,Y                 ;ZERO OUT TYPE LIST
          DEY
          BPL     STATS2
          STA     PLAYER                 ;INIT TO PLAYER ONE
;ASSUME RATIO = 0 BEFORE STARTING
;THIS SECTION MULTIPLIES MISCNT21 BY 100
STATS1    LDX     #1                     ;MULTIPLY BY 4 AND ADD
          JSR     SHIFTMIS
          LDX     #2                     ;MULTIPLY BY 8 AND ADD
          JSR     SHIFTMIS
          LDX     #0                     ;MULTIPLY BY 2 AND ADD
          JSR     SHIFTMIS
;THIS SECTION DIVIDES MISCNT2 BY MISCNT1
          LDA     MISCNT11
          BNE     DIVMIS                 ;SEE IF THIS IS ZERO
          LDA     MISCNT11+1
          BEQ     SHORATIO               ;DON'T DIVIDE BY ZERO
DIVMIS    SEC
          LDA     RATIO
          SBC     MISCNT11
          STA     RATIO
          LDA     RATIO+1
          SBC     MISCNT11+1
          STA     RATIO+1
          LDA     RATIO+2
          SBC     #0
          STA     RATIO+2
          BMI     SHORATIO               ;SHOW RATIO WHEN THIS IS NEGATIVE
          SED
          CLC
          LDA     PRCNTREG               ;INCREMENT THE PERCENTAGE COUNTER
          ADC     #1
          STA     PRCNTREG
          CLD
          BCS     NOMISSES               ;SEE IF HIT 100%
          JMP     DIVMIS
NOMISSES  LDY     PLAYER                 ;GET CURRENT PLAYER DISPLAYED
          LDA     #48                    ;'1' TYPE, FIRST PAGE
          STA     TYPE+4,Y
SHORATIO  LDY     PLAYER                 ;USES TYPE SLOTS 65,66,67,68,69,70
          BNE     SHORAT1                ;WILL HAVE ALREADY DONE THIS
          LDA     #25                    ;'PLAYER' TYPE
          STA     TYPE+69
          LDA     #20
          STA     XCORD+69
          LDA     #60
          STA     YCORD+69
          STA     YCORD+70
          LDA     #1
          STA     ANGLE+69               ;PLAYER
          STA     ANGLE+70               ;NUMBER OF HITS
          STA     ANGLE                  ;1
          STA     ANGLE+1                ;2
          LDA     #36
          STA     TYPE+70                ;'NUMBER OF HITS' TYPE
          LDA     #70
          STA     XCORD+70
          LDA     #48                    ;'1' TYPE, FIRST PAGE GRAPHICS
          STA     TYPE
          LDA     #40
          STA     XCORD
          STA     XCORD+1
          LDA     #84
          STA     YCORD
          LDA     #108
          STA     YCORD+1
          LDA     TWOPLAYR
          BEQ     SHORAT1
          LDA     #49                    ;DON'T SHOW IF ONLY ONE PLAYER
          STA     TYPE+1
SHORAT1   LDA     PRCNTREG               ;GET THE PERCENT SCORE
          LSR     A
          LSR     A
          LSR     A
          LSR     A                            ;GET RID OF LOWER NIBBLE
          STA     ANGLE+65,Y
          LDA     #40                    ;DIGIT TYPE
          STA     TYPE+65,Y
          STA     TYPE+67,Y
          TYA                            ;LOOK AT Y REG
          BEQ     SHORAT2                ;SEE WHICH PLAYER
          LDA     #108
          BNE     SHORAT3
SHORAT2   LDA     #84
SHORAT3   STA     YCORD+65,Y
          STA     YCORD+67,Y
          STA     YCORD+2,Y              ;PERCENT SIGN
          STA     YCORD+4,Y              ;100% SCORE
          LDA     #101
          STA     XCORD+4,Y
          LDA     #107
          STA     XCORD+65,Y
          LDA     #113
          STA     XCORD+67,Y
          LDA     #119
          STA     XCORD+2,Y
          LDA     #1
          STA     ANGLE+2,Y
          STA     ANGLE+4,Y
          LDA     #51
          STA     TYPE+2,Y
          LDA     PRCNTREG
          AND     #$0F                   ;BOOT HIGH NIBBLE
          STA     ANGLE+67,Y
          LDA     TWOPLAYR               ;SEE IF IN TWO PLAYER MODE
          BEQ     ONESTATS
          LDA     PLAYER
          BNE     ONESTATS               ;SEE IF ALREADY DID PLAYER 2
          LDA     MISCNT22               ;TRANSFER PLAYER2 TO PLAYER1'S REGS
          STA     MISCNT21
          LDA     MISCNT22+1
          STA     MISCNT21+1
          LDA     MISCNT22+2
          STA     MISCNT21+2
          LDA     MISCNT12
          STA     MISCNT11
          LDA     MISCNT12+1
          STA     MISCNT11+1
          LDA     #0
          STA     RATIO
          STA     RATIO+1
          STA     RATIO+2
          STA     PRCNTREG
          INC     PLAYER
          JMP     STATS1
ONESTATS  LDA     #$FF
          STA     SCRTIME
          JSR     SCRDELAY               ;GIVE APPROPRIATE DELAY
          RTS

SHIFTMIS  CLC
          ASL     MISCNT21+2
          ASL     MISCNT21+1
          BCC     SHIFTM1
          INC     MISCNT21+2
SHIFTM1   ASL     MISCNT21
          BCC     SHIFTM2
          INC     MISCNT21+1
SHIFTM2   DEX
          BPL     SHIFTMIS
          CLC
          LDA     RATIO
          ADC     MISCNT21
          STA     RATIO
          LDA     RATIO+1
          ADC     MISCNT21+1
          STA     RATIO+1
          LDA     RATIO+2
          ADC     MISCNT21+2
          STA     RATIO+2
          RTS
CLREXPLO  LDX     #57
CLREXP    INX
          LDA     TYPE,X
          CMP     #8                     SEE IF SOME SORT OF EXPLOSION
          BMI     CLREXP1
          LDA     #0
          STA     TYPE,X
CLREXP1   CPX     #61
          BMI     CLREXP
          RTS
TWINKEL   DEC     TEMP1
          BNE     TWINKEND
          LDA     TEMP3                  ;USED AS A TOGGLE SWITCH
          BPL     INCANGLE
          DEC     ANGLE
          BMI     RELOCATE               ;MOVE STAR
          BPL     RESETEMP
INCANGLE  INC     ANGLE
          LDA     ANGLE
          CMP     #7                     ;SEE IF DONE INCREMENTING
          BMI     RESETEMP               ;NO, RESET TEMP VARIABLE
          LDA     #$FF
          STA     TEMP3
          BNE     RESETEMP               ;NOW RESET TEMP
RELOCATE  LDA     #0
          STA     ANGLE
          STA     TEMP3                  ;RESET TOGGLE VARIABLE
          DEC     BOZO0
          BPL     RELOC1
          LDA     #7
          STA     BOZO0
RELOC1    LDA     BOZO0
          TAY
          LDA     TWINKY,Y               ;GET TWINKLE Y CORD
          STA     YCORD
          LDA     TWINKX,Y               ;GET TWINKLE X CORD
          STA     XCORD
RESETEMP  LDA     #3
          STA     TEMP1
          DEC     TEMP2
TWINKEND  RTS
