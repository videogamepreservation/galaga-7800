;  GDAC2.S
;THIS SUBROUTINE DETECTS A COLLISION BETWEEN A HERO MISSLE AND AN ENEMY SHIP
;
;
COLDET1   LDX     #56                    ;INIT PTR TO BEGINNING OF HERO MISSLES
NEWMIS    LDA     TYPE,X                 ;SEE IF MISSLE EXISTS
          BEQ     NXMIS
          LDY     #0
NXEN      LDA     TYPE,Y                 ;SEE IF ENEMY EXISTS
          BEQ     NXENMY
          LDA     YCORD,X                ;TEST FOR COLLISION
          CLC                            ;IF: (YSHIP < YMIS+7) AND
          ADC     #4                     ;    (YSHIP+10 > YMIS) AND
          CMP     YCORD,Y                ;    (XSHIP < XMIS+4 < XSHIP+7)
          BCC     NXENMY
          LDA     YCORD,Y
          CLC
          ADC     #6
          CMP     YCORD,X
          BCC     NXENMY
          LDA     TYPE+62                ;SEE IF SECOND SHIP ACTIVE
          BEQ     MONODTCT
          LDA     XCORD,Y
          CLC
          ADC     #3
          CMP     XCORD,X
          BCC     NXENMY
          LDA     XCORD,X
          CLC
          ADC     #3                     ;SEE IF SHIP IS BETWEEN MISSILES
          CMP     XCORD,Y
          BEQ     NXENMY
          ADC     #6
          CMP     XCORD,Y
          BCC     NXENMY
          JSR     COLLIS1
          RTS
;         JMP     NXMIS
MONODTCT  LDA     XCORD,X
          CLC
          ADC     #3
          CMP     XCORD,Y
          BCC     NXENMY
          LDA     XCORD,Y
          CLC
          ADC     #2
          CMP     XCORD,X
          BCC     NXENMY
          JSR     COLLIS1                ;FOUND A COLLISION
          RTS
;         JMP     NXMIS
NXENMY    INY                            ;INC ELISTPTR TO NEXT ENEMY
          CPY     #40                    ;SEE IF CAPTD HERO
          BNE     CHKPHERO
          LDA     MODE+40
          CMP     #6
          BCC     CHKPHERO
          CMP     #10                    ;MODES 6 - 9 ARE SAFE FROM EXPLOSION
          BCS     CHKPHERO
SKIPHERO  INY                            ;IF SO, DON'T CHECK FOR COLLISION
CHKPHERO  CPY     #45                    ;AND SEE IF AT END OF ENMYLIST
          BNE     NXEN
NXMIS     CPX     #57                    ;INC MISPTR TO NEXT MISSLE AND SEE
          BNE     NDONCOL                ;IF AT END OF HMISLST
          RTS                            ;YES, SO RETURN FROM SUBROUTINE
NDONCOL   LDX     #57                    ;NO, SO CHECK NEW MISSLE AGAINST ALL
          JMP     NEWMIS                 ;OF ENMYLIST


;
;
;THIS SUBROUTINE IS CALLED BY COLDET1 WHEN A COLLISION IS FOUND BETWEEN A HERO
;MISSLE (POINTED TO BY X REG) AND AN ENEMY SHIP (POINTED TO BY Y REG).
;
COLLIS1   LDA     TYPE,Y                 ;SEE IF IS BOSS SHIP AND FIRST SHOT
          AND     #$7F                   ;TO HIT IT
          CMP     #3
          BEQ     COLLIXY
          CMP     #4                     ;SEE IF BLUE BOSS
          BNE     COLLIXZ
          LDA     MODE,Y                 ;SEE IF IN BOSS WAIT MODE
          AND     #$8F                   ;LOOK AT MSB AND LOW 4 BITS
          CMP     #3
          BNE     COLLIXZ
          LDA     #0
          STA     WAITCNT                ;CLEAR WAITCNT
          JSR     SCRAPALL               ;KILL TRACTOR BEAM
          JMP     COLLIXX                ;NOW HANDLE EXPLOSION
COLLIXY   LDA     TYPE,Y                 ;CHANGE TO BLUE BOSS
          CLC
          ADC     #1
          STA     TYPE,Y
          LDA     #14                    ;BOSS HIT SOUND
          JSR     TUNIN
          LDA     #0                     ;ZERO OUT MISSLE
          STA     TYPE,X
          RTS
COLLIXZ
          CMP     #16                    ;GREEN BOSS W/ CAPTURED HERO
          BNE     DAK1
          LDA     TYPE,Y
          CLC
          ADC     #1
          STA     TYPE,Y                 ;CHANGE TYPE TO BLUE BOSS W/ HERO
          LDA     #14
          JSR     TUNIN
          LDA     #0
          STA     TYPE,X                 ;ZERO OUT MISSILE
          RTS
DAK1      CMP     #17                    ;BLUE BOSS W/ CAPTURED HERO
          BNE     COLLIXX
          LDA     WAITCNT                ;SEE IF FIRST PICKED UP
          BEQ     NOTRACTR
          LDA     #0
          STA     WAITCNT                ;BOOT TRACTOR BEAM IF FIRST PICKED UP
          JSR     SCRAPALL               ;BOOT TRACTOR BEAM TUNE
          LDA     #11                    ;PUT IN 'PUT HERO BACK DOWN' MODE
          STA     MODE+40
          BNE     BIRDBUG1
NOTRACTR
          LDA     MODE,Y                 ;GET MODE OF BOSS
          BEQ     HREAPR
          CMP     #1
          BNE     NOTHRP
HREAPR    LDA     #5
          STA     HEROREAP               ;SET HERO REAPPEAR MODE
;MAY NEED TO STORE A 5 TO THE MODE HERE
          STX     BOZO0
          LDX     #40
          JSR     COTBOATK
          LDX     BOZO0                  ;NEED TO SAVE THE X VALUE
          JMP     BIRDBUG1               ;CONTINUE TO KILL BOSS
NOTHRP    LDA     #8                     ;HERO SPIN MODE
          STA     MODE+40
          LDA     #5
          JSR     TUNIN                 ;TUNE 5 IS RELEASED HERO TUNE
          LDA     #6
          JSR     TUNIN                 ;TUNE 6 IS OTHER CHANNEL OF TUNE
BIRDBUG1  LDA     #4
          STA     TYPE,Y                 ;HANDLE LIKE REGULAR BLUE BOSS
COLLIXX   CPY     #40                    ;SEE IF CAPTURED HERO SHIP
          BEQ     NOATC
;         DEC     NUMFLY
          LDA     MODE,Y                 ;SEE IF IN SHIFT OR EXPAND MODE
          BEQ     NOATC
          CMP     #1                     ;DEC AIRBORNE IF WAS FLYING
          BEQ     NOATC
;NOW, DEC IF SHOT WHILE IN ORIENT MODE
          DEC     AIRBORNE
NOATC     CPY     #40                    ;SEE WHAT TYPE ENEMY SHIP WAS KILLED
          BNE     NOTHER                 ;SEE IF HERO SHIP
          LDA     #27                    ;HERO DEATH SOUND
          JSR     TUNIN
          LDA     #28                    ;HERO DEATH SOUND
          JSR     TUNIN
          LDA     #$00                   ;HERO DEATH SCORE
          STA     HEROREAP
          STA     MODE+40                ;RESET MODE OF DEAD HERO
          JSR     CLEARBOS               ;CLEAR BOSS WHICH CARRIED HERO
          LDA     #$01
          STA     TEMP4
          LDA     #11                    ;ONE THOUSAND TYPE
          STA     SCRTEMP
          JMP     NOATCX
NOTHER    LDA     CHALSTG                ;SEE IF CHALLENGING STAGE
          BEQ     NOTHER0
          SED
          LDA     CHALSCR
          CLC
          ADC     #1                     ;INCREMENT SCORE FOR CHLNGING STAGE
          STA     CHALSCR
          CLD
          INC     WAVESCR                ;INCREMENT SCORE FOR THIS WAVE
NOTHER0   LDA     TYPE,Y
          AND     #$7F
          CMP     #1                     ;SEE IF BLUE SHIP
          BEQ     META10
          CMP     #13
          BNE     NOTBLU
          LDA     CHALSTG
          BNE     META10                 DONT GIVE 1000 BONUS IF CHAL STAGE
          INC     SCORPCNT
          LDA     SCORPCNT
          CMP     #3                     ;SEE IF HAVE 2 ALREADY
          BNE     META10
          LDA     #11
          STA     SCRTEMP                ;GIVE THOUSAND BONUS
          LDA     #$01
          STA     TEMP4
          BNE     NOATCX
META10    LDA     #12                    ;BLUE DEATH SOUND
          JSR     TUNIN
          LDA     MODE,Y                 ;GET MODE OF DEAD SHIP
          BEQ     LOWBLUE                ;SEE IF IN SHIFTING MODE
          CMP     #1                     ;SEE IF IN EXPANSION MODE
          BEQ     LOWBLUE                ;IF SO, SCORE = 50
          LDA     #$10                   ;BLUE DEATH SCORE
          STA     TEMP5
          BNE     NOATCX
LOWBLUE   LDA     #$05
          STA     TEMP5                  ;GIVE SCORE OF 50
          BNE     NOATCX
NOTBLU    CMP     #2                     ;SEE IF RED SHIP
          BEQ     ISREDX
          CMP     #50
          BNE     NOTREDX
ISREDX    LDA     #11                    ;RED DEATH SOUND
          JSR     TUNIN
          LDA     MODE,Y                 ;GET MODE OF DEAD SHIP
          BEQ     LOWRED
          CMP     #1
          BEQ     LOWRED                 ;SEE IF IN SHIFT OR EXPAND MODE
          LDA     #$16                   ;RED DEATH SCORE
          STA     TEMP5
          BNE     NOATCX
LOWRED    LDA     #$08
          STA     TEMP5                  ;GIVE SCORE OF 80
          BNE     NOATCX

NOTREDX
          LDA     #10                    ;BOSS DEATH SOUND (MUST BE BOSS)
          JSR     TUNIN
          JSR    ABOSSHIT

;         ENTRY POINT FROM OTHER CODE SEGMENTS (I'M SORRY TO SAY)
NOATCX
          LDA     WAVESCR                ;CHECK SCORE OF WAVE
          CMP     #8                     ;SEE IF PERFECT
          BNE     NOTHOBON               ;NO THOUSAND BONUS
          LDA     #0
          STA     WAVESCR
          LDA     #$80
          STA     BORNCNT                PUT DELAY BEFORE NEXT WAVE
          LDA     #$01
          STA     TEMP4
          LDA     CHALNUM                ;SEE WHAT STAGE THIS IS
          CMP     #4
          BMI     THOBON
          LDA     #$60
          STA     TEMP5
          LDA     #12
          BNE     SIXTNBON
THOBON    LDA     #11
SIXTNBON  STA     SCRTEMP                ;STORE 1000 SCORE BONUS
NOTHOBON  LDA     #0                     ;ZERO OUT MISSLE
          STA     TYPE,X
          STA     TYPE,Y                 ;ZERO OUT ENEMY SHIP

          JSR    ENMYBOOM
          RTS


;
;THIS SUBROUTINE DETECTS A COLLISION BETWEEN THE HERO SHIP AND ANY ENEMY
;SHIP
;
COLDET2   LDA     TYPE+63                ;SEE IF HERO SHIP EXISTS
          BNE     CONTC2
NONIE     RTS
CONTC2    LDA     FARREN
          BMI     NONIE
          LDA     CHALSTG                DONT DETECT IF CHALLENGING STAGE
          BNE     NONIE
          LDY     #0                     ;INIT PTR TO BEGINNING OF ENEMY SHIPS
NXSHP     LDA     TYPE,Y                 ;SEE IF ENEMY SHIP EXISTS
          BEQ     NXESHIP
          LDA     YCORD,Y                ;TEST FOR COLLISION
          CMP     #162                   ;IF: 161 < YSHIP < 181 AND
          BCC     NXESHIP                ;    (HEROX + 7) > XSHIP AND
          CMP     #181                   ;    (XSHIP + 7) > HEROX
          BCS     NXESHIP
          LDA     XCORD+63               ;(HEROX)
          CLC
          ADC     #6
          CMP     XCORD,Y
          BCC     HERO2TST
          LDA     XCORD,Y
          CLC
          ADC     #6
          CMP     XCORD+63               ;(HEROX)
          BCC     NXESHIP
          JSR     COLLIS2
          RTS                            NEW CODE
HERO2TST  LDA     TYPE+62
          BEQ     NXESHIP
          LDA     XCORD+62
          CLC
          ADC     #6
          CMP     XCORD,Y                ;MAKE SURE Y ISN'T TRASHED
          BCC     NXESHIP
          LDA     XCORD,Y
          CLC
          ADC     #6
          CMP     XCORD+62               ;(HEROX)
          BCC     NXESHIP
          JSR     COLLIS2A
          RTS
NXESHIP   INY                            ;INC ELISTPTR TO NEXT ENEMY
          CPY     #45                    ;AND SEE IF AT END OF ENMYLIST
          BMI     NXSHP
;THIS CHECKS FOR COLLISION BETWEEN AN ENEMY MISSILE AND THE HERO SHIP
          LDY     #46
NXEMIS1   LDA     TYPE,Y                 ;SEE IF ENEMY MISSLE EXISTS
          BEQ     NXEMIS
          LDA     YCORD,Y                ;TEST FOR COLLISION
          CLC                            ;IF:  (171 < YMIS+7) AND
          ADC     #6                           (181 > YMIS) AND
          CMP     #171                   ;     (XHERO < XMIS+4 < XHERO+7)
          BCC     NXEMIS
          LDA     #180
          CMP     YCORD,Y
          BCC     NXEMIS
          LDA     XCORD,Y
          CLC
          ADC     #4
          CMP     XCORD+63
          BCC     NXEMIS                 ;MISSILE TOO FAR TO LEFT OF SHIP
          LDA     XCORD+63
          CLC
          ADC     #4
          CMP     XCORD,Y
          BCC     HERO2CHK               ;MISSILE TOO FAR TO RIGHT OF SHIP
          JSR     COLLIS3
          RTS
HERO2CHK  LDA     TYPE+62                ;SEE IF 2ND HERO ACTIVE
          BEQ     NXEMIS
          LDA     XCORD+62               ;CHECK FOR HIT ON 2ND HERO
          SEC
          SBC     #4
          CMP     XCORD,Y
          BCS     NXEMIS
          CLC
          ADC     #7
          CMP     XCORD,Y
          BCC     NXEMIS
          JSR     COLLIS3A
          RTS
NXEMIS    INY                            ;INC ELISTPTR TO NEXT ENEMY
          CPY     #56                    ;AND SEE IF AT END OF ENMYLIST
          BNE     NXEMIS1
          RTS

H2BOOM    LDA     #0                     ;ZERO OUT SECOND SHIP
          STA     TYPE+62
          STA     MODE+63                ;RESET DUAL MODE
          LDA     #52                    ;STORE HERO EXPLOSION TYPE
          STA     TYPE+65
          LDA     XCORD+62
          SEC
          SBC     #4
          STA     XCORD+65               ;STORE XCORD FOR EXPLOSION
          LDA     #7
          STA     ANGLE+65
          LDA     #168
          STA     YCORD+65
          LDA     #5
          STA     ML+65
          LDA     #0
          STA     MODE+65
          RTS

H1BOOM    LDA     #0                     ;ZERO OUT HERO SHIP
          STA     TYPE+63
          LDA     #52                    ;STORE HERO EXPLOSION TYPE
          STA     TYPE+66
          LDA     XCORD+63
          SEC
          SBC     #4
          STA     XCORD+66               ;STORE XCORD FOR EXPLOSION
          LDA     #7
          STA     ANGLE+66
          LDA     #168
          STA     YCORD+66
          LDA     #5
          STA     ML+66
          LDA     #0
          STA     MODE+66
          RTS
;
;THIS SUBROUTINE IS CALLED WHEN AN ENEMY SHIP RUNS INTO THE HERO SHIP
;
COLLIS2A  JSR     H2BOOM
          JMP     COLLIS2B
COLLIS2   CPY     #40
          BNE     COLLIS2M
          LDA     MODE+40                ;GET MODE OF SHIP
          CMP     #9                     ;SEE IF IN REUNITE MODE
          BNE     COLLIS2M
          RTS                            ;DON'T DO ANYTHING
COLLIS2M  JSR     H1BOOM
          LDA     TYPE+62                ;SEE IF 2ND HERO ACTIVE
          BEQ     COLLIS2B               ;NO, GO ON
          LDA     #5                     ;RESET HERO SHIP
          STA     TYPE+63
          LDA     XCORD+62
;         STA     XCORD+63               ;SWITCH XCORDS
          STA     HEROX
          LDA     #0
          STA     TYPE+62                ;KILL 2ND SHIP
          STA     MODE+63                ;RESET DUAL MODE
COLLIS2B  LDA     TYPE,Y                 ;SEE IF IS BOSS SHIP AND FIRST TIME
          AND     #$7F                   ;HIT
          CMP     #3
          BEQ     COLL21
          CMP     #16                    ;SEE IF GREEN BOSS W/ HERO
          BNE     COLLIS2G
          LDA     #17
          STA     TYPE,Y                 ;CHANGE TO BLUE BOSS W/ HERO
          JMP     COLL22
COLL21    LDA     #4
          STA     TYPE,Y                 ;CHANGE TO BLUE BOSS
COLL22    LDA     #9                     ;HERO DEATH SOUND
          JSR     TUNIN
          LDA     #14                    ;CHANGE TO BLUE BOSS SOUND
          JSR     TUNIN
          LDX     #58
          JMP     TRYNXSP1
COLLIS2G  CMP     #17                    ;SEE IF IS BLUE BOSS W/ HERO
          BNE     COLLIS2H
          LDA     #8
          STA     MODE+40                ;SET TO HERO SPIN MODE
          LDA     #4                     ;SET TO REG BLUE BOSS
          STA     TYPE,Y
          LDA     #5
          JSR     TUNIN
          LDA     #6
          JSR     TUNIN                  ;HERO RELEASE SOUND
COLLIS2H  CPY     #40                    ;SEE IF IS CAPTURED HERO SHIP
          BNE     NOTCAPH
          JSR     CLEARBOS               ;CLEAR BOSS THAT CARRIED HERO
          LDA     #$01
          STA     TEMP4
          LDA     #11                    ;ONE THOUSAND TYPE
          STA     SCRTEMP
          LDA     #0
          STA     HEROREAP
          JMP     ZAPHERO
NOTCAPH
;         DEC     NUMFLY                 ;DEC NUMBER SHPS FLYING
          DEC     AIRBORNE
          LDA     TYPE,Y                 ;SEE WHAT TYPE OF ENEMY SHIP IT WAS
          AND     #$7F
          CMP     #1                     ;SEE IF BLUE SHIP
          BEQ     META11
          CMP     #13
          BNE     NOTBLUG
META11    LDA     #$10                   ;BLUE DEATH SCORE
          STA     TEMP5
          LDA     FARREN
          CMP     #4
          BNE     DSBLFAR
          LDA     SWCHA
          ASL     A
          ASL     A
          ASL     A
          BCS     DSBLFAR
          LDA     #$FF
          STA     FARREN
          JMP     ZAPHERO
DSBLFAR   LDA     #0
          STA     FARREN
          JMP     ZAPHERO

NOTBLUG
          CMP     #2                     ;SEE IF RED SHIP
          BNE     NOTREDXG
          LDA     #$16                   ;RED DEATH SCORE
          STA     TEMP5
          JMP     ZAPHERO
NOTREDXG
          JSR    ABOSSHIT               ; HOW YOU PRONOUNCE IT IS YOUR OWN
                                         ; BUSINESS

;         THIS IS AN ENTRY POINT FOR BIZARRE CODE SEGMENTS ABOVE
ZAPHERO   LDA     #0                     ; FORMERLY COLLIS2X
          STA     TYPE,Y                 ;ZERO OUT ENEMY SHIP
          LDA     #9                     ;HERO DEATH SOUND
          JSR     TUNIN

TRYNXSP1
          JSR     ENMYBOOM
          RTS                            ;

;         COMBINED NOTREDXG AND NOTREDX
ABOSSHIT
          LDA     MODE,Y                 ;MUST BE BOSS
          BPL     FOURHX                 ;SEE IF WAS ATTACKING WITH ESCORTS
          AND     #$0F
          CMP     #5
          BMI     FOURHX
          CMP     #9
          BPL     FOURHX
          LDA     COUNTXY,Y              ;SEE HOW MANY ESCORTS IT HAD
          CMP     #$0F
          BEQ     FOURHX                 ;GO TO NO ESCORT
          CMP     #$1F
          BNE     SIXTENHX
          LDA     #$80                   ;ONE ESCORT
          STA     TEMP5
          LDA     #10                    ;EIGHT HUNDRED TYPE
          STA     SCRTEMP
          RTS
SIXTENHX  LDA     #$60                   ;TWO ESCORTS
          STA     TEMP5
          LDA     #$01
          STA     TEMP4
          LDA     #12                    ;SIXTEEN HUNDRED TYPE
          STA     SCRTEMP
          RTS

FOURHX    LDA     YCORD,Y                ;GET YCORD OF BOSS
          CMP     #13                    ;SEE IF AT RESTING YCORD
          BEQ     FOURH1                 ;SCORE IS 150 IF SO
          LDA     #$40                   ;NO ESCORTS
          STA     TEMP5                  ;SCORE
          LDA     #9                     ;FOUR HUNDRED TYPE
          STA     SCRTEMP
          RTS
FOURH1    LDA     #$15
          STA     TEMP5                  ;GIVE SCORE OF 150
          RTS

;         ENEMY BOOM !
ENMYBOOM  LDX     #58
BOOMLOOP  LDA     TYPE,X                 ; IT IS NOW TIME FOR THE GALAGA ON
          BEQ     GOTSP1                 ; YOUR TELEVISION TO EXPLODE
          INX
          CPX     #62
          BNE     BOOMLOOP
          LDX     #58                    ;ALL SPACES TAKEN, JUST USE FIRST SPACE
BOMLOP    LDA     TYPE,X                 ;FIND A USABLE SPOT
          CMP     #9
          BPL     GOTSP1                 USE A 'NUMBER' SPOT
          INX
          CPX     #62
          BNE     BOMLOP
          LDX     #58
GOTSP1    LDA     #8                     ;CHANGE ENEMY SHIP INTO EXPLOSION
          STA     TYPE,X
          LDA     XCORD,Y
          SEC
          SBC     #3                     ;CENTER THE EXPLOSION
          STA     XCORD,X
          LDA     YCORD,Y
          STA     YCORD,X
          LDA     #5
          STA     ML,X
          LDA     #7
          STA     ANGLE,X
          LDA     SCRTEMP
          STA     MODE,X
          LDA     #0
          STA     SCRTEMP
          RTS


;
;THIS SUBROUTINE IS CALLED WHEN AN ENEMY MISSLE RUNS INTO THE HERO SHIP
;
COLLIS3A  JSR     H2BOOM                 ;ZERO OUT 2ND HERO
          JMP     COLLIS3B
COLLIS3   JSR     H1BOOM                 ;ZERO OUT HERO SHIP
          LDA     TYPE+62                ;SEE IF 2ND SHIP ACTIVE
          BEQ     COLLIS3B               ;NO, GO ON
          LDA     #0
          STA     MODE+63                ;PUT BACK IN SINGLE MODE
          STA     TYPE+62                ;KILL 2ND SHIP
          LDA     #5
          STA     TYPE+63                ;SWITCH TO HERO SHIP
          LDA     XCORD+62
;         STA     XCORD+63               ;SET NEW XCORD
          STA     HEROX
COLLIS3B  LDA     #0
          STA     TYPE,Y                 ;ZERO OUT MISSLE
          LDA     #9                     ;HERO DEATH SOUND
          JSR     TUNIN
          LDA     FARREN
          BEQ     NON1
          LDA     SWCHA
          ASL     A
          ASL     A
          ASL     A
          ASL     A
          BCS     DISFAR
          INC     FARREN
          BNE     NON1
DISFAR    LDA     #0
          STA     FARREN
NON1      RTS

;THIS SUBROUTINE CLEARS THE BOSS GALAGA WHICH WAS CARRYING A HERO SHIP
; IT IS CALLED WHEN THE CAPTURED HERO IS KILLED
CLEARBOS  STY     KEEPY
          LDY     CAPBOS1
          LDA     TYPE,Y                 ;GET TYPE OF CAPTURING HERO
          AND     #$7F                   ;BOOT HIGH BIT
          CMP     #16                    ;SEE IF HAS HERO
          BMI     ENDCLRBS
          LDA     TYPE,Y
          SEC
          SBC     #13
          STA     TYPE,Y
ENDCLRBS  LDY     KEEPY
          RTS
;
;THIS SUBROUTINE HANDLES EXPLOSIONS.  THE EXPLOSION IS POINTED TO BY THE
;Y REG
;THE Y REG IS SAVED
;
EXPLO     TYA                            ;TRANSFER Y REG TO X REG
          TAX
          LDA     TYPE,X                 ;CHECK TYPE
          CMP     #8                     ;SEE IF EXPLOSION
          BEQ     BUGEXPLO
          CMP     #52
          BNE     SHOWNUM
BUGEXPLO  DEC     ML,X
          BPL     ENDNUM
          CPY     #60                    ;SEE IF IS HERO EXPLOSION
          BMI     BUGEX1
          LDA     #7
          BNE     BUGEX2
BUGEX1    LDA     #3
BUGEX2    STA     ML,X
          DEC     ANGLE,X
          BNE     ENDNUM
          LDA     MODE,X
          STA     TYPE,X
          LDA     #100
          STA     ML,X
          LDA     #1
          STA     ANGLE,X                ;PREVENT FLAPPING
          BNE     ENDNUM
SHOWNUM   CMP     #9
          BMI     ENDNUM                 ;NOT A SCORE
          CMP     #13
          BPL     ENDNUM                 ;NOT A SCORE
          DEC     ML,X
          BNE     ENDNUM
          LDA     #0
          STA     TYPE,X
          STA     MODE,X
ENDNUM    RTS


*******************************************************************************
*
*         SOUND.S       by Kevin G. Osborn
*         Contains subroutines
*                 TUNER
*                 SCRAPALL
*                 SCRAPONE
*                 TUNIN
*******************************************************************************
********************************************************************************
* SIMPSONG VERSION 0.03
*
* THIS SIMPLE SOUND DRIVER HAS, IN SOME WAYS, FEWER FEATURES BUT USES LESS RAM
* AND ROM AND DOES NOT BACK UP SOUNDS FOR LATER (SOMETIMES MUCH LATER)
* CONTINUATION. IT FEATURES 256 NOTE TUNES, SINGLE DURATION PER TUNE, ENDLESS
* TUNES. IF A VALUE IN THE CONTROL OR VOLUME TABLES HAS THE HIGH BIT SET, THAT
* VOLUME OR CONTROL WILL REMAIN IN EFFECT TILL THE END OF THE TUNE.
* AN FF IN THE FREQUENCY TABLE WILL TERMINATE THE TUNE, AN FE WILL CAUSE IT TO
* RESTART.  AN FD WILL CALL THE TUNE NUMBER FOLLOWING (IN THE FREQ TABLE).
*
* SUBROUTINES:
*     SCRAPALL -- KILL ALL TUNES. SHOULD BE CALLED AT POWERUP, CHANGING PLAYERS,
*                AND GAME OVER
*
*     SCRAPONE -- KILL A PARTICULAR TUNE. PUT THE NUMBER OF THE TUNE YA WANNA
*                 AXE IN THE ACCUMULATOR.
*
*     TUNIN   --  START THAT TUNE YOU PUT IN ACC.
*
* THE ABOVE ROUTINES PRESERVE THE X AND Y REGS
*
* TABLES NEEDED ARE:
* RAM:
*DCH0      DS      1                      ONE BYTE--DURATION CNTR CHAN. 0
*DCH1      DS      1                      ONE BYTE--DURATION CNTR CHAN. 1
*TUNNUM    DS      1                      ONE BYTE--TUNE NUM FOR CHAN. 0
*TUNNUM1   DS      1                      ONE BYTE--TUNE NUM FOR CHAN. 1
*TINDEX0   DS      1                      ONE BYTE--NOTE POINTER 0
*TINDEX1   DS      1                      ONE BYTE--NOTE POINTER 1
*CINDEX0   DS      1                      CONTROL INDEX
*CINDEX1   DS      1
*VINDEX0   DS      1                      VOLUME INDEX
*VINDEX1   DS      1
*MPTRL     EQU     KTEMP0                 ZERO PAGE TEMP(NOT GAMEPLAY)
*MPTRH     EQU     KTEMP1                 ZERO PAGE TEMP(NOT GAMEPLAY)
*TUNTEMP   EQU     TEMP0                  ANY GAMEPLAY TEMP
* ROM:
*   DURTABL       ONE DURATION IN FRAMES PER TUNE
*   TBASE         LOW ADDRESS OF THE START OF FREQ DATA BY TUNE NUMBER
*   TBASEH        DITTO FOR HIGH ADDRESS
*   VBASE         LOW ADDRESS OF THE START OF VOL DATA BY TUNE NUMBER
*   VBASEH        DITTO FOR HIGH ADDRESS
*   CBASE         LOW ADDRESS OF THE START OF CTRL DATA BY TUNE NUMBER
*   CBASEH        DITTO FOR HIGH ADDRESS
*   PRYOR         PRIORITY BY TUNE NUMBERS  --  ZERO THE LOWEST
*   VOLTABL       VOLUMES
*   FREQTABL      FREQUENCIES
*   CTLTABL       CONTROLS

********************************************************************************
* SCRAPALL
*         KILL ALL TUNES. SHOULD BE CALLED AT POWERUP, CHANGING PLAYERS,
*                AND GAME OVER
*   ALSO BEFORE INITIATING A TUNE WITH TWO VOICES

SCRAPALL  TYA
          PHA
          TXA
          PHA
          LDY     #0
          STY     AUDV0
          STY     AUDV1
          DEY
          STY     TUNNUM
          STY     TUNNUM1
          PLA
          TAX
          PLA
          TAY
          RTS

; IF YOU WANT, LOOP THIS UP

********************************************************************************
* SCRAPONE
*         KILL A PARTICULAR TUNE. PUT THE NUMBER OF THE TUNE YA WANNA
*                 AXE IN THE ACCUMULATOR.
SCRAPONE  CMP     TUNNUM
         BNE     CKCH1
         LDA     #0
         STA     AUDV0
         LDA     #$FF
         STA     TUNNUM
         RTS
CKCH1     SEC
         SBC     TUNNUM1
         BNE     REETS
         STA     AUDV1
         LDA     #$FF
         STA     TUNNUM1
REETS     RTS

********************************************************************************
* TUNIN
*         START THAT TUNE YOU PUT IN ACC.

TUNIN     STA     TUNTEMP
          TYA
          PHA
          TXA
          PHA

          LDY     #1
          LDX     TUNTEMP

TROIK1    LDA     TUNNUM,Y
          CMP     TUNTEMP                ;SEE IF TUNE IS ALREADY IN
          BEQ     DO                     ;GO AHEAD AND LOAD
          DEY
          BPL     TROIK1

          LDY     #1
TROIKA    LDA     TUNNUM,Y               ;FIRST CHECK FOR AN EMPTY CHANNEL
          CMP     #$FF
          BEQ     DO
TRKNX     DEY
          BPL     TROIKA
          LDA     TUNNUM1                ;THIS IS DONE TO PREVENT GLITCHINESS
          AND     #$7F
          TAY
          LDA     PRYOR,X
          CMP     PRYOR,Y               ;CHECK FOR LOWEST PRIORITY
          LDY     #1
          BCS     DO
          LDA     TUNNUM                ;THIS IS DONE TO PREVENT GLITCHINESS
          AND     #$7F
          TAY
          LDA     PRYOR,X
          CMP     PRYOR,Y               ;CHECK FOR LOWEST PRIORITY
          BCC     ROOTS
          LDY     #0
DO        TXA
          ORA     #$80
          STA     TUNNUM,Y
ROOTS     PLA
          TAX
          PLA
          TAY
          RTS

********************************************************************************
*TUNER SHOULD BE CALLED ONCE PER FRAME, NO INPUTS, AND IT OPERATES WITH
*A TOTAL DISREGARD FOR REGISTER SANCTITY. EACH TUNE CAN BE 256 NOTES LONG
*IF YOUR TUNES ARE VERY SMALL, YOU COULD DO AWAY WITH ALL THE INDIRECT STUFF
TUNER
; TEST FOR ATTRACT
          LDA     AUTOPLAY
          BNE     REETS
; TEST FOR PAUSE
          LDA     PAUSE
          BMI     REETS                  ;MINUS IF IN PAUSE

          LDX     #1
TUNLOP    LDY     TUNNUM,X
          INY
          BNE     NETN                   ;TUNNUM=FF DO NEXT CHANNEL
JNXTCH    JMP     NXTCH
NETN      DEY
          BPL     BOOGIE
          TYA                            ;NEW TUNE--INTITIATE
          AND     #$7F
          STA     TUNNUM,X
          TAY
          LDA     CTRLTABL,Y
          STA     AUDC0,X                ; IN EFFECT UNTIL CHANGED
          LDA     #$FF
          STA     DCH0,X                 ;START
          STA     TINDEX0,X
*         STA     CINDEX0,X
          STA     VINDEX0,X
BOOGIE    LDA     TBASE,Y
          STA     MPTRL
          LDA     TBASEH,Y
          STA     MPTRH
          DEC     DCH0,X
          BPL     JNXTCH
          LDA     DURTABL,Y
          STA     DCH0,X
          LDY     TINDEX0,X
*         INC     CINDEX0,X
          INC     VINDEX0,X
          INY
          LDA     (MPTRL),Y              ;FREQ
          CMP     #$FF
          BNE     CKENL
          STA     TUNNUM,X               ;END THIS FUNKY TUNE
          LDA     #0
          STA     AUDV0,X
          BEQ     JNXTCH
CKENL     CMP     #$FE                  ; TEST FOR REPEATS
          BEQ     FOOBEQ
CKNXTT    CMP     #$FD                   ; CONTINUE WITH THE NEXT TUNE
          BNE     STFREQ
          INY                            ; NEXT BYTE IS TUNE INDEX
          LDA     (MPTRL),Y
          TAY
          ORA     #$80                   ; SO THAT NEW CTRL AND VOLUME GET READ
          STA     TUNNUM,X
          LDA     TBASE,Y                ; GET ADDRESS OF NEW TUNE
          STA     MPTRL
          LDA     TBASEH,Y
          STA     MPTRH
FOOBEQ    LDY     #0                     ; JUMP HERE FOR REPEAT
          TYA                            ; Y MUST BE 0, IT'S THE FREQ. INDEX
*         STA     CINDEX0,X
          STA     VINDEX0,X
FRQLOOP   LDA     (MPTRL),Y
STFREQ  ; BPL     SKIP0                  ; IF BIT 7 SET, GET NEW DURATION
;         INY
 ;        LDA     (MPTRL),Y              ;DURATION CHANGES ARE DISABLED
  ;       STA     DCH0,X
   ;      DEY
    ;     LDA     (MPTRL),Y
     ;    INY
      ;   JMP     STIT0
SKIP0     ASL     A
          BPL     SKIP1                  ; IF BIT 6 SET, THIS IS A REST
          LSR     A
          AND     #$BF
          STA     DCH0,X
          TYA
          STA     TINDEX0,X
          DEC     VINDEX0,X
*         DEC     CINDEX0,X
          LDA     #0
          STA     AUDV0,X
          BEQ     NXTCH
SKIP1     ASL     A
          BPL     STIT                   ; IF BIT 5 IS SET, THIS IS A NEW CTRL
          LSR     A
          LSR     A
          AND     #$1F
          STA     AUDC0,X
          INY
          JMP     FRQLOOP                ; DO NEXT BYTE BEFORE RETURNING
STIT      LSR     A
          LSR     A
STIT0     STA     AUDF0,X
          TYA
          STA     TINDEX0,X
          LDY     TUNNUM,X
          LDA     VBASE,Y
          STA     MPTRL
          LDA     VBASEH,Y
          STA     MPTRH
          LDY     VINDEX0,X
          LDA     (MPTRL),Y
          BPL     STVL
          DEY
STVL      STA     AUDV0,X
          TYA
          STA     VINDEX0,X
NXTCH     DEX
          BMI     ROTS
          JMP     TUNLOP
ROTS      RTS


********************************************************************************


********************************************************************************
*         POINTER TABLES.

TBASE     DB      L(TTITLE0),L(TTITLE1),L(TSTACHA),L(TFREE1),L(TFREE2)
          DB      L(TRELEAS1),L(TRELEAS2),L(THERSHOT),L(TBIRDSWO)
          DB      L(THERDEA),L(TBOSDEA),L(TREDDEA),L(TBLUDEA)
          DB      L(TTRANSFM),L(TBOSCHNG),L(TCHALNG1),L(TCHALNG2)
          DB      L(TPERFEC1),L(TPERFEC2),L(TSTATS1),L(TSTATS2)
          DB      L(TTRACTOR),L(TCAPTURE),L(TKIDNAP1),L(TKIDNAP2)
          DB      L(TBACMUS),L(TTRAC2),L(TSUIC),L(TSUIC2)

TBASEH    DB      H(TTITLE0),H(TTITLE1),H(TSTACHA),H(TFREE1),H(TFREE2)
          DB      H(TRELEAS1),H(TRELEAS2),H(THERSHOT),H(TBIRDSWO)
          DB      H(THERDEA),H(TBOSDEA),H(TREDDEA),H(TBLUDEA)
          DB      H(TTRANSFM),H(TBOSCHNG),H(TCHALNG1),H(TCHALNG2)
          DB      H(TPERFEC1),H(TPERFEC2),H(TSTATS1),H(TSTATS2)
          DB      H(TTRACTOR),H(TCAPTURE),H(TKIDNAP1),H(TKIDNAP2)
          DB      H(TBACMUS),H(TTRAC2),H(TSUIC),H(TSUIC2)

VBASE     DB      L(TTITLE0V),L(TTITLE1V),L(TSTACHAV),L(TFREE1V),L(TFREE2V)
          DB      L(TRELES1V),L(TRELES2V),L(THERSHOV),L(TBIRDSWV)
          DB      L(THERDEAV),L(TBOSDEAV),L(TREDDEAV),L(TBLUDEAV)
          DB      L(TTRNSFMV),L(TBOSCHGV),L(TCHLNG1V),L(TCHLNG2V)
          DB      L(TPERFC1V),L(TPERFC2V),L(TSTATS1V),L(TSTATS2V)
          DB      L(TTRACTRV),L(TCAPTURV),L(TKIDNP1V),L(TKIDNP2V)
          DB      L(TBACMUSV),L(TTRAC2V),L(TSUICV),L(TSUIC2V)

VBASEH    DB      H(TTITLE0V),H(TTITLE1V),H(TSTACHAV),H(TFREE1V),H(TFREE2V)
          DB      H(TRELES1V),H(TRELES2V),H(THERSHOV),H(TBIRDSWV)
          DB      H(THERDEAV),H(TBOSDEAV),H(TREDDEAV),H(TBLUDEAV)
          DB      H(TTRNSFMV),H(TBOSCHGV),H(TCHLNG1V),H(TCHLNG2V)
          DB      H(TPERFC1V),H(TPERFC2V),H(TSTATS1V),H(TSTATS2V)
          DB      H(TTRACTRV),H(TCAPTURV),H(TKIDNP1V),H(TKIDNP2V)
          DB      H(TBACMUSV),H(TTRAC2V),H(TSUICV),H(TSUIC2V)


********************************************************************************
CTRLTABL  DB      $0D,$0D,4,4,4
          DB      4,$D,4,4
          DB      8,4,1,1
          DB      4,4,4,4
          DB      4,$D,$D,$D
          DB      4,4,4,$D
          DB      $D,4,4,$D       ;29 TUNES

DURTABL   DB      $08,$08,$00,$03,$03
          DB      $02,$02,$00,$03
          DB      $09,$02,$01,$01
          DB      $03,$00,$05,$05
          DB      $02,$02,$08,$08
          DB      $01,$02,$02,$02
          DB      $03,$01,$00,$00


PRYOR     DB      6,5,7,8,7
          DB      13,12,3,4
          DB      7,5,5,5
          DB      9,5,8,7
          DB      15,14,15,14
          DB      9,9,11,10
          DB      1,8,8,1
********************************************************************************

* FREQTABL
;TUNE 0: TITLE SONG
TTITLE0   DB      $0D,$0D,$24,$1F,$1B,$1B,$17,$18,$18,$1F,$1B,$1B,$12,$14,$14
          DB      $1F,$1B,$1B,$17,$18,$18,$1F,$1B,$1B,$10,$0F,$0F,$11,$13,$13
          DB      $14,$17,$17,$1A,$1B,$1B,$2D,$0B,$24,$11,$11,$0F,$11,$11,$14
          DB      $12,$17,$1B,$14,$14,$14,$FF

TREDDEAV
TBLUDEAV
TTITLE0V
TBIRDSWV
TBOSDEAV
TBOSCHGV
TCHLNG1V
TCHLNG2V
TPERFC1V
TSTATS1V
TTRACTRV
TSUICV    DB      $89

;TUNE1: TITLE SONG
TTITLE1   DB      $10,$51,$0F,$51,$0D,$51,$0F,$51,$10,$51
          DB      $0F,$51,$0D,$51,$0F,$48,$0F,$11,$11,$12,$14,$14
          DB      $17,$1A,$1A,$1B,$1F,$1F,$1B,$12,$12,$11,$12,$12,$16,$18,$18
          DB      $18,$1B,$1B,$1B,$FF

TTITLE1V
TTRAC2V
TSUIC2V   DB      $84

;TUNE2: STAGE CHANGE
TSTACHA   DB      $0F,$40,$13,$40,$11,$43
          DB      $0F,$40,$13,$40,$11,$FF

TSTACHAV
TKIDNP1V
TFREE2V   DB      $87

;TUNE3: EXTRA SHIP FANFARE
TFREE1    DB      $13,$17,$13,$0E,$0B,$09,$FF

TFREE1V   DB      $8A
TBACMUSV  DB      $83                    ;LOWERED THIS VOLUME

;TUNE4: EXTRA SHIP FANFARE
TFREE2    DB      $17,$1D,$17,$13,$0F,$11,$FF


;TUNE5: CAPTURED SHIP RELEASED, PLAYS UNTIL UNITED
TRELEAS1  DB      $D,$42,$10,$42,$F,$42,$12,$42
          DB      $10,$42,$14,$42,$12,$42,$15,$42
          DB      $14,$42,$19,$42,$1C,$42,$1F,$42
          DB      $2D,$A,$42,$C,$42,$D,$42,$E,$42
          DB      $D,$42,$A,$42,$C,$42,$24,$1F,$42
          DB      $2D,$A,$42,$24,$1C,$42,$1F,$42,$19,$42
          DB      $1C,$42,$14,$42,$15,$42,$14,$42
          DB      $12,$42,$1C,$42,$19,$42,$16,$42,$FE


TRELES1V
TTRNSFMV  DB      $88

;TUNE6: SAME AS 4
TRELEAS2  DB      $1C,$1C,$1C,$1C,$12,$12,$12,$12
          DB      $D,$D,$D,$D,$D,$D,$10,$10
          DB      $12,$12,$14,$14,$15,$15,$18,$18
          DB      $1C,$1C,$1D,$1D,$1C,$1C,$18,$18
          DB      $15,$15,$45,$14,$14,$45
          DB      $12,$12,$45,$10,$10,$45
          DB      $12,$12,$12,$41,$14,$14,$15,$15
          DB      $18,$18,$1C,$1C,$1D,$1D,$18,$18,$FE

TPERFC2V
TRELES2V
TSTATS2V
TKIDNP2V  DB      $85

;TUNE7: HERO SHOT
THERSHOT  DB      6,7,8,9,$A,$B,$C,$D        ;FREQ
          DB      $F,$11,$13,$15,$17,$19,$1C,$1F
          DB      $FF

THERSHOV  DB      3,4,5,5,5,5,5,5,5,5,4,4,3,3,4,4,$FF

;TUNE8: BIRDSWOOPING SOUND
TBIRDSWO  DB      $0A,$0B,$0C,$0D,$0E        ;FREQ
          DB      $0F,$10,$11,$12,$13
          DB      $14,$15,$17,$18,$1A
          DB      $1B,$1D,$1F,$2D,$0B,$0C
          DB      $0D,$0E,$0F,$10,$11
          DB      $12,$13,$14,$15,$FF


;TUNE9: HERO DEATH SOUND
THERDEA   DB      $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$FF

THERDEAV  DB      $B,$D,$C,$B,$A,9,7,5,3,2,1,$FF

;TUNE10: BOSS DEATH SOUND
TBOSDEA   DB      $1F,$1C,$1A,$1C,$1A
          DB      $19,$1A,$19,$18,$FF


;TUNE11: RED DEATH SOUND
TREDDEA   DB      $09,$08,$07,$05,$41        ;FREQ
          DB      $06,$07,$08,$0B,$FF


;TUNE12: BLUE DEATH SOUND
TBLUDEA   DB      $0D,$0B,$0A,$09,$41        ;FREQ
          DB      $0A,$0B,$0D,$0F,$FF


;TUNE13: ONE BIRD INTO THREE BIRDS
TTRANSFM  DB      $1D,$1A,$1D,$1A,$16,$13,$16,3,$FF


;TUNE14: BOSS GOING TO BLUE
TBOSCHNG  DB      $1F,$1E,$40,$1C,$1B
          DB      $40,$19,$18,$FF


;TUNE15: CHALLENGING STAGE CHANNEL 1
TCHALNG1  DB      $13,$4B,$13,$12
          DB      $10,$0E,$0E,$0E,$FF


;TUNE16: CHALLENGING STAGE CHANNEL 2
TCHALNG2  DB      $1F,$4B,$1F,$1D
          DB      $1A,$17,$17,$17,$FF


;TUNE17: PERFECT SCORE FANFARE
TPERFEC1  DB      $12,$12,$12,$12,$12,$00,$12,$00
          DB      $12,$12,$12,$12,$14,$14,$14,$14
          DB      $14,$14,$14,$00,$14,$14,$14,$14
          DB      $14,$14,$14,$00,$14,$14,$14,$14
          DB      $11,$11,$11,$11,$11,$00,$11,$00
          DB      $11,$11,$11,$11,$12,$12,$12,$12
          DB      $12,$12,$12,$00,$12,$12,$12,$12
          DB      $12,$12,$12,$00,$12,$12,$12,$00
          DB      $11,$00,$11,$11,$11,$00,$11,$00
          DB      $11,$11,$11,$11,$0F,$00,$0F,$0F
          DB      $0F,$00,$0F,$00,$0F,$0F,$0F,$00
          DB      $0F,$0F,$0F,$00,$0F,$0F,$0F,$00
          DB      $0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D
          DB      $0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D
          DB      $FD,8  ;CALL BIRD SWOOP SOUND

;TUNE18: PERFECT SCORE FANFARE
TPERFEC2  DB      $1F,$1F,$18,$18,$14,$14,$0F,$0F
          DB      $1F,$1F,$18,$18,$14,$14,$0F,$0F
          DB      $1F,$1F,$18,$18,$14,$14,$0F,$0F
          DB      $1F,$1F,$18,$18,$14,$14,$0F,$0F
          DB      $1F,$1F,$18,$18,$14,$14,$0F,$0F
          DB      $1F,$1F,$18,$18,$14,$14,$0F,$0F
          DB      $1F,$1F,$18,$18,$14,$14,$0F,$0F
          DB      $1F,$1F,$18,$18,$14,$14,$0F,$0F
          DB      $1D,$42,$1D,$1D,$1D,$42,$1D,$42
          DB      $1D,$1D,$1D,$1D,$1A,$42,$1A,$1A
          DB      $1A,$42,$1A,$42,$1A,$1A,$1A,$42
          DB      $1A,$1A,$1A,$42,$1A,$1A,$1A,$42
          DB      $17,$17,$14,$14,$12,$12,$0F,$0F
          DB      $12,$12,$12,$12,$17,$17,$17,$17,$FF

;TUNE19: STATISTICS DISPLAY SOUND
TSTATS1   DB      $D,$D,$24,$1F,$1B,$1B,$17,$18,$18
          DB      $1F,$1B,$1B,$12,$14,$14,$1F,$1B
          DB      $1B,$17,$18,$18,$1F,$1B,$1B,$10
          DB      $F,$F,$11,$13,$13,$14,$17,$17
          DB      $1A,$1B,$1B,$2D,$B,$24,$11,$11,$F,$11
          DB      $11,$14,$12,$17,$1B,$14,$14,$14
ABCD      DB      $14,$14,$14,$FF


;TUNE20: STATISTICS DISPLAY SOUND
TSTATS2   DB      $51,$D,$D,$24,$1F,$1B,$1B,$17
          DB      $18,$18,$1F,$1B,$1B,$12,$14,$14
          DB      $1F,$1B,$1B,$17,$18,$18,$1F,$1B
          DB      $1B,$10,$F,$F,$11,$13,$13,$14
          DB      $17,$17,$1A,$1B,$1B,$2D,$B,$24,$11,$11
          DB      $F,$11,$11,$14,$12,$17,$1B,$14
ABCDE     DB      $14,$14,$14,$FF


;TUNE21: TRACTOR BEAM
TTRACTOR  DB      $0E,$41,$0F,$41,$11,$41,$13,$41,$FE          ;REPEATS

;TUNE26   SECOND CHANNEL OF TRACTOR BEAM SOUND
TTRAC2    DB      $41,$11,$41,$13,$41,$16,$41,$17,$FE    ;REPEATS


;TUNE22: HERO SHIP BEING CAPTURED
TCAPTURE  DB      $17,$13,$10,$0D,$0B
          DB      $0D,$10,$13,$FE        ;REPEATS

TCAPTURV  DB      $02,$04,$06,$08,$08,$06,$04,$02
          DB      $03,$03,$03,$03,$03,$03,$03,$03
          DB      $07,$09,$0A,$0A,$0A,$0A,$09,$07
          DB      $04,$04,$04,$04,$04,$04,$04,$04
          DB      $03,$05,$07,$09,$09,$07,$05,$03
          DB      $04,$04,$04,$04,$04,$04,$04,$04
          DB      $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
          DB      $03,$FE                ;REPEATS

;TUNE23: HERO BEING TAKEN TO TOP OF SCREEN
TKIDNAP1  DB      $0D,$42,$11,$42,$0F,$42,$12,$42
          DB      $11,$42,$14,$42,$12,$42,$15
          DB      $42,$14,$42,$1A,$42,$1C,$42,$1F
          DB      $42,$2D,$0B,$42,$0C,$42,$0D,$42
          DB      $0E,$42,$0D,$42,$0B,$42,$0C,$42
          DB      $24,$1F,$42,$2D,$0B,$42,$24,$1C,$42,$1F
          DB      $42,$1A,$42,$1C,$42,$14,$42,$16
          DB      $42,$14,$42,$12,$42,$1C,$42
          DB      $19,$42,$16,$42,$FF    ;MAY END ABRUPTLY???


;TUNE24: HERO BEING TAKEN TO TOP OF SCREEN
TKIDNAP2  DB      $1C,$1C,$1C,$1C,$12,$12,$12,$12
          DB      $0D,$0D,$0D,$0D,$0D,$0D,$11
          DB      $11,$12,$12,$14,$14,$17,$17,$18
          DB      $18,$1C,$1C,$1E,$1E,$1C,$1C
          DB      $18,$18,$17,$17,$17,$17,$14,$14
          DB      $14,$14,$12,$12,$12,$12,$11
          DB      $11,$11,$11,$12,$12,$12,$12,$14
          DB      $14,$17,$17,$18,$18,$1C,$1C
          DB      $1D,$1D,$18,$18,$FF    ;MAY END ABRUPTLY???


;TUNE25: BACKGROUND MUSIC
TBACMUS   DB      $1F,$1D,$1B,$1A,$18        ;FREQ
          DB      $17,$15,$14,$13,$12
          DB      $15,$14,$13,$12,$1F
          DB      $1D,$1B,$1A,$18,$17
          DB      $15,$14,$13,$12,$1F
          DB      $1D,$1B,$1A,$18,$17
          DB      $15,$14,$13,$12,$1F
          DB      $1D,$1B,$1A,$18,$17
          DB      $15,$14,$13,$12,$13
          DB      $14,$15,$17,$12,$13
          DB      $14,$15,$17,$18,$1A
          DB      $1B,$1D,$1F,$12,$13
          DB      $14,$15,$17,$18,$1A
          DB      $1B,$1D,$1F,$12,$13
          DB      $14,$15,$17,$18,$1A
          DB      $1B,$1D,$1F,$12,$13
          DB      $14,$15,$17,$18,$1A
          DB      $1B,$1D,$1F,$FE


;TUNE27   SUICIDE CHANNEL 1
TSUIC     DB      $0D,$40,$11,$40,$F,$40,$12,$40
          DB      $11,$40,$14,$40,$12,$40,$15,$40
          DB      $14,$40,$1C,$40,$1A,$40,$1F,$40
          DB      $1C,$40,$2D,$0B,$40,$24,$15,$40,$1A,$40
          DB      $14,$40,$1C,$40,$1A,$40,$1F,$40
          DB      $1C,$40,$2D,$0B,$40,$15,$40,$1F,$40
          DB      $14,$40,$FF


;TUNE28   SUICIDE CHANNEL 2
TSUIC2    DB      $1C,$1C,$1C,$1C,$12,$12,$12,$12
          DB      $D,$D,$D,$D,$D,$D,$11,$11
          DB      $12,$12,$12,$12,$14,$14,$14,$14
          DB      $17,$17,$17,$17,$18,$18,$18,$18
          DB      $17,$17,$17,$17,$14,$14,$14,$14
          DB      $12,$12,0,0,$12,$12,0,0
          DB      $1C,$1C
          DB      $FF


