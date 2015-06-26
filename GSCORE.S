*GSCORE.S

* THIS ADDSCORE SUBROUTINE ADDS THE SCORE IN TEMP4 AND TEMP5 *



ADDSCORE  LDX     PLAYER
          LDA     LIVES,X                ;LIVES IS THE NO OF LIVES OF PLAYER X
          BMI     ZADSOUT                ;IF MINUS THEN YOU ARE OUT
          LDA     AUTOPLAY               ;CHECK IF IN AUTO PLAY
          BNE     ZADSOUT                ;IF ZERO THEN NOT IN AUTO
          STA     TEMP3                  ;STORE ZERO IN HERE
          TXA
          BNE     ZADSP2                 ;BRANCH IF IN PLAYER TWO
          LDY     #2
          SED                            ;SET DECIMAL MODE ON
          CLC

ZDS1LOOP  LDA     TEMP3,Y                ;GET ADDRESS AFTER TEMP3 LOCATION
          ADC     P1SCORE,Y              ;ADD IT TO SCORE
          STA     P1SCORE,Y              ;STORE
          DEY                            ;GO TO NEXT DIGITS
          BPL     ZDS1LOOP
          BCC     NOMILLS                ;NO MILLION INCREASE
          LDA     SCORE+6                ;GET MILLIONS DIGIT
          ADC     #0                     ;INC DIGIT
          STA     SCORE+6
          CMP     #10
          BMI     NOMILLS
          SEC
          SBC     #10
          STA     SCORE+6
          LDA     SCORE+7
          CLC
          ADC     #1
          STA     SCORE+7
NOMILLS   TXA                            ;PUT PLAYER NO IN ACCUMULATOR
          JSR     CHKSCOR1               ;CLEARS DECIMAL MODE
          JMP     ZADSOUT                ;GO TO END

ZADSP2    LDY     #$2
          SED
          CLC
ZDS2LOOP  LDA     TEMP3,Y
          ADC     P2SCORE,Y
          STA     P2SCORE,Y
          DEY
          BPL     ZDS2LOOP
          BCC     NOP2MILL
          LDA     SCORE+14               ;GET MILLIONS DIGIT
          ADC     #0
          STA     SCORE+14
          CMP     #10                    ;SEE IF 10 YET
          BMI     NOP2MILL
          SEC
          SBC     #10
          STA     SCORE+14
          LDA     SCORE+15
          CLC
          ADC     #1
          STA     SCORE+15
NOP2MILL  TXA
          JSR     CHKSCOR2

ZADSOUT   JSR     WRTSCORE
          LDA     #0
          STA     TEMP5
          STA     TEMP4
          RTS



* THIS SUBROUTINE CHECKS FOR BONUS LIFE *

CHKSCOR1  LDY     #1                     ;DO NOT CARE ABOUT MOST SIG,
          CLC
ZKS1LOOP  LDA     TEMP4,Y                ;TAKE THE THOUSANDS
          ADC     P1BONUS,Y              ;ADD TO BONUS  COUNTER
          STA     P1BONUS,Y
          DEY
          BPL     ZKS1LOOP
          CLD                            ;TURN DECIMAL MODE OFF
          LDA     P1BONUS                ;CHECK TO SEE IF ENOUGH BONUS
          CMP     #L(BONUSPT)
          BCC     ZKS1OUT
          LDA     P1BONUS
          SEC
          SBC     #L(BONUSPT)                ;TAKE THAT AMOUNT OFF
          STA     P1BONUS
          LDA     P1TOG                  ;SEE IF HAVE GIVEN BONUS YET
          BEQ     NP1BONYT              ;NO PLAYER 1 BONUS YET
          INC     P1TOG                  ;INCREMENT TOGGLE COUNTER
          LDA     P1TOG
          CMP     #5                     ;SEE IF AT 4*BONUSPT YET
          BEQ     NEXTBON1               ;YES, NEXT BONUS REACHED
          RTS
NEXTBON1  JSR     INCLIVES
          LDA     #1
          STA     P1TOG
          RTS
NP1BONYT
          INC     P1TOG
          INC     P1TOG
          JSR     INCLIVES               ;INCREMENT THE LIVES
ZKS1OUT   RTS

CHKSCOR2  LDY     #1
          CLC
ZKS2LOOP  LDA     TEMP4,Y
          ADC     P2BONUS,Y
          STA     P2BONUS,Y
          DEY
          BPL     ZKS2LOOP
          CLD
          LDA     P2BONUS
          CMP     #L(BONUSPT)
          BCC     ZKS2OUT
          LDA     P2TOG                  ;SEE IF HAVE GIVEN BONUS YET
          BEQ     NP2BONYT              ;NO PLAYER 2 BONUS YET
          LDA     P2BONUS
          SEC
          SBC     #L(BONUSPT)                ;TAKE THAT AMOUNT OFF
          STA     P2BONUS
          INC     P2TOG                  ;INCREMENT TOGGLE COUNTER
          LDA     P2TOG
          CMP     #5                     ;SEE IF AT 4*BONUSPT YET
          BEQ     NEXTBON2               ;YES, NEXT BONUS REACHED
          RTS
NEXTBON2  JSR     INCLIVES
          LDA     #1
          STA     P2TOG
          RTS
NP2BONYT  LDA     P2BONUS
          SEC
          SBC     #L(BONUSPT)                ;TAKE THAT AMOUNT OFF
          STA     P2BONUS
          INC     P2TOG
          INC     P2TOG
          JSR     INCLIVES               ;INCREMENT THE LIVES
ZKS2OUT   RTS





*DECREMENT THE LIVES OF THE GUY INDICATED IN REGISTER X*
DECLIVES  LDA     TWOPLAYR
          BEQ     DECLIVE1
          LDA     #$A0
          STA     DECREG
          RTS
DECLIVE1  LDX     PLAYER
          DEC     LIVES,X                ;DEC LIVES OF CURRENT PLAYER
          BNE     ZDLOUT
          LDA     LIVES                  ;GET LIVES OF PLAYER 1
          ORA     LIVES+1                ;SEE IF BOTH ARE OVER
          BEQ     ZZLOVER                ;RESTART GAME PLAY
          STY     TTEMP                  ;SAVE Y VALUE
          LDA     #$4F
          STA     PLAYRREG               ;"PLAYER X"
          STA     GMOVEREG               ;"GAME OVER"
          LDA     #5
          STA     TYPE+63
          LDA     #73
          STA     XCORD+63
          JMP     ZDLOUT3
ZZLOVER   JMP     ZDLOVER

* PUT READY MESSAGE
ZDLOUT
          LDA     MODE+63                ;SEE IF IN HERO DUAL MODE
          BEQ     ZDLLUT
          RTS
ZDLLUT    LDA     #$4F
          STA     RDYREG                 ;STORE COUNTER FOR READY
          LDA     #5
          STA     TYPE+63
          LDA     #73
          STA     HEROX
;         STA     XCORD+63
          LDA     NOSWITCH               ;SEE IF SHOULDN'T SWITCH PLAYERS
          BNE     ZSWITCH                ;EQUAL TO ZERO MEANS SWITCH
          LDA     TWOPLAYR
          BNE     ZDLOUT0
          LDA     #40
          STA     MISTIMER               ;PREVENT CHEAP SHOTS DURING 'READY'
ZSWITCH   RTS

;  THIS ROUTINE MUST SAVE THE CURRENT DATA, SWITCH TO THE NEW PLAYER, AND
;         SWITCH TO THE PREVIOUS SCREEN OF THE NEW PLAYER
;         THE X REGISTER HAS THE OLD PLAYER
ZDLOUT0   LDA     #$4F
          STA     PLAYRREG               ;"PLAYER X"

ZDLOUT3
          LDA     #72
          STA     BULLSHT                ;RESET STALL REGISTER
          LDA     PLAYER
          EOR     #1                     ;INC TO NEXT PLAYER
          TAX
          LDA     LIVES,X
          BNE     NOTDEAD
          JMP     ZDEND                  ;DON'T SWITCH PLAYERS
NOTDEAD   TXA
          STA     PLAYER                 ;STORE NEW PLAYER
          LDY     #40                    ;INIT TO LAST ENEMY IN ENMYLIST
ZDLOUT1   LDX     NEWTYPE,Y              ;GET SAVED TYPE VALUE
          LDA     TYPE,Y                 ;GET CURRENT TYPE INFO
          STA     NEWTYPE,Y              ;STORE CURRENT TYPE INFO
          TXA
          STA     TYPE,Y                 ;RESTORE OLD TYPE INFO
          DEY
          BPL     ZDLOUT1                ;LOOP UNTIL ALL ARE SAVED
          LDY     #9                     ;INIT Y TO LAST COLPOS
ZDLOUT2   LDX     NEWCOLS,Y              ;GET SAVED COLUMN VALUE
          LDA     COLPOS,Y               ;GET CURRENT COLPOS INFO
          STA     NEWCOLS,Y              ;STORE CURRENT COLPOS INFO
          TXA
          STA     COLPOS,Y               ;RESTORE OLD COLPOS INFO
          DEY
          BPL     ZDLOUT2
          LDY     #35                    ;THIS SAVES FIRST 36 ZERO PAGE REGS.
XAVESLP   LDX     SAVES,Y
          LDA     ARRIVED,Y
          STA     SAVES,Y
          TXA
          STA     ARRIVED,Y
          DEY
          BPL     XAVESLP
          LDX     #40                    ;PUT OFF SCREEN Y COORDINATES
XXAVE     LDA     RESTABY,X
          SEC
          SBC     #60
          STA     YCORD,X
          DEX
          BPL     XXAVE
          LDA     #0
          LDY     #45
AEROMODE  STA     MODE,Y
          STA     ANGLE,Y
          STA     MOMENTUM,Y
          DEY
          BPL     AEROMODE
          LDY     #39
SETCOLS   LDA     TYPE,Y
          BEQ     SETCOLS1
          LDX     CHTAB,Y                ;SET ALL XCORDS
          LDA     COLPOS,X
          STA     XCORD,Y
SETCOLS1  DEY
          BPL     SETCOLS
          LDA     TYPE+40                ;SEE IF CAPTD HERO ACTIVE
          BEQ     ZDEND
          LDY     #39
SETCAPY   LDA     TYPE,Y                 ;GET TYPE OF SHIP
          CMP     #16                    ;BOSS WOULD BE 16 OR 17
          BPL     FNDBOSS
          DEY
          BPL     SETCAPY
FNDBOSS   LDA     XCORD,Y                ;GET BOSS XCORD
          STA     XCORD+40               ;SET CAPT HERO XCORD
          LDA     #$80
          STA     MISTIMER               ;PREVENT SHOTS DURING SCROLL IN
ZDEND     LDY     TTEMP
          RTS


; THIS ROUTINE RESTARTS THE GAME PLAY
ZDLOVER   LDA     #1
          STA     GAMEOVER
          LDA     #$4F
          STA     GMOVEREG
          JMP     WORDS4
          RTS





* INCREMENTING THE LIVES OF THE PLAYER INDICATED BY REG X *

INCLIVES  LDA     LIVES,X
          CMP     #$A
          BEQ     ZICLOUT
          INC     LIVES,X
;         JSR     WRTLIVES
ZICLOUT   LDA     #3
          JSR     TUNIN                  ;TUNE FOR GETTING EXTRA GUY
          LDA     #4
          JSR     TUNIN
          RTS


* WRITE SCORE OF BOTH PLAYERS IN SCORE *


WRTSCORE  LDA     #1
          STA     TEMP0
          LDX     #0

ZWSALOOP  LDA     P1SCORE,X              ;ELIMINATE LEADING ZEROES
          LSR     A
          LSR     A
          LSR     A
          LSR     A
          BNE     ZWS1JMP0
          JSR     WRTBLANK
          LDA     P1SCORE,X
          AND     #$F
          BNE     ZWS1JMP1
          JSR     WRTBLANK
          INX
          CPX     #3
          BMI     ZWSALOOP
          JMP     ZWS1OUT

ZWS1LOOP  LDA     P1SCORE,X              ;WRITE SIGNIFICANT DIGITS
          LSR     A
          LSR     A
          LSR     A
          LSR     A
ZWS1JMP0                                 ;THIS PART WRITES PLAYER 1
          JSR     DOWRITE
          LDA     P1SCORE,X
          AND     #$F

ZWS1JMP1
          JSR     DOWRITE
          INX
          CPX     #3
          BMI     ZWS1LOOP

ZWS1OUT   LDA     #0
          JSR     DOWRITE
          LDA     TWOPLAYR               ;CHECK TO SEE IF TWO PLAYERS
          BNE     ZWS2
          RTS

ZWS2      LDA     #9                     ;USED TO BE A 7
          STA     TEMP0

          LDX     #0
ZWSBLOOP  LDA     P2SCORE,X
          LSR     A
          LSR     A
          LSR     A
          LSR     A
          BNE     ZWS2JMP0
          JSR     WRTBLANK
          LDA     P2SCORE,X
          AND     #$F
          BNE     ZWS2JMP1
          JSR     WRTBLANK
          INX
          CPX     #3
          BMI     ZWSBLOOP
          JMP     ZWS2OUT

ZWS2LOOP  LDA     P2SCORE,X
          LSR     A
          LSR     A
          LSR     A
          LSR     A
ZWS2JMP0
          JSR     DOWRITE
          LDA     P2SCORE,X
          AND     #$F

ZWS2JMP1
          JSR     DOWRITE
          INX
          CPX     #3
          BMI     ZWS2LOOP

ZWS2OUT   LDA     #0
          JMP     DOWRITE




* THIS SUBROUTINE PUTS LIFE INDICATORS FOR BOTH PLAYERS *



;WRTLIVES  RTS
 ;        TYA
  ;       PHA
   ;      TXA
    ;     PHA
     ;    LDA     AUTOPLAY
      ;   BNE     ZWLOUT                 ; 0 IF IN AUTO PLAY
       ;  LDX     #1                     ;START WITH PLAYER 1

;ZWLLOOP   LDA     LIFEX,X
 ;        STA     TEMP0                  ;DOWRITE USES THIS
  ;       LDY     #3
;ZWLINDLP  TYA
 ;        CMP     LIVES,X
  ;       BPL     ZWLBLANK
   ;      LDA     LIFEIND,X
    ;     JSR     DOWRITE
     ;    JMP     ZWLNEXT
;ZWLBLANK  JSR     WRTBLANK
;ZWLNEXT   DEY
 ;        BPL     ZWLINDLP
  ;       DEX
   ;      BPL     ZWLLOOP

;ZWLOUT
 ;        PLA
  ;       TAX
   ;      PLA
    ;     TAY
     ;    RTS

;LIFEIND   DB      0,0                    ;WHERE LIFE INDICATORS ARE KEPT
;LIFEX     DB      0,0                    ;WHERE THE LIFE INDICATORS GO IN STR.

WRTBLANK  LDA     #$A                    ;FIRST  CHARACTER IN FONT IS BLANK

*  ACCUMULATOR NOW HAS THE DIGIT TO BE DISPLAYED *
*  Y HAS THE POSITION OF THE DIGIT TO GO *


DOWRITE   STY     TEMP1
          LDY     TEMP0
          STA     SCORE,Y                ;PUT INTO STRING, AND IT IS DISPLAYED
          LDY     TEMP1
          INC     TEMP0
          RTS

