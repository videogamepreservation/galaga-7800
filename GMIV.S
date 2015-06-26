;GMIV.S
;ORG IS AFTER BLOOP
UPENLIST
GOLIST    LDA     EXPANCC
          CMP     #127
          BNE     INCFRM
          LDA     EXPANR
          BPL     INCFRM
CHTOGGLE  INC     TOGGLEM                ;CHANGE FLAG IN MASTER TOGGLE
          LDA     #63
          STA     COL4
          LDA     #21
          STA     COL3
          LDA     #12
          STA     COL2
          LDA     #9
          STA     COL1
          LDA     #7
          STA     COL0
          LDA     #0                     ;RESET POINTER TO BEGINNING OF TABLE
          STA     EXPANCC
          BEQ     CHKMODE0
INCFRM
          LDA     COUNT
          BNE     CHKMODE0
          INC     TOGGLEM0
          LDA     #25
          STA     COUNT
CHKMODE0  LDY     #45

CHKMODE   LDA     TYPE,Y
          BNE     NEND0
          BEQ     TEST

NEND0     LDA     MODE,Y                 ;SEE IF IN CONSTANT OR FASTER MODE
          BMI     FASTER

CONSTANT  AND     #$F                    ;SEE IF IN SHIFTING MODE
          BNE     BOSACAP0               ;SEE IF IN EXPAND MODE
          CPY     #40                    ;SEE IF CAPT'D HERO
          BNE     CONSTNT9
          LDX     CHTAB40                ;GET COLUMN NUMBER
          BPL     CONSTNT8
CONSTNT9  LDX     CHTAB,Y
CONSTNT8  LDA     COLPOS,X
          STA     XCORD,Y
          JMP     END1

BOSACAP0  LDA     MODE,Y
          AND     #$F
          CMP     #2                     ;SEE IF IN BOSS CAPTURE MODE1
          BNE     BOSSWAI0
          JMP     BOSACAP

BOSSWAI0  CMP     #3                     ;SEE IF IN BOSS CAPTURE MODE2
          BNE     BCAPTUR0
          JMP     BOSSWAIT

BCAPTUR0  CMP     #4                     ;SEE IF IN BOSS CAPTURE MODE3
          BNE     ORIENT0
          JMP     BCAPTUR
ORIENT0   CMP     #5
          BNE     HEROTWRL
          JMP     ORIENT
HEROTWRL  CMP     #7
          BNE     PUTDOWN
          JMP     TWIRL
PUTDOWN   CMP     #11                    ;SEE IF IN HERO PUT DOWN MODE
          BNE     TEST
          LDA     #0
          STA     ANGLE+40
          LDA     YCORD+40               ;SEE IF AT 171 YET
          CMP     #171
          BCS     ISDOWN
          INC     YCORD+40
          BNE     TEST
ISDOWN
          LDA     #5
          STA     TYPE+63
          LDA     #0
          STA     TYPE+40
          STA     MODE+40
          STA     NOSWITCH
; HOPEFULLY, THE REST OF THE HERO PARAMETERS ARE OK
TEST      JMP     END1                   ;DONE WITH CONSTANT MOTIONS

FASTER    LDA     MODE,Y                 ;SEE IF IN TABLEINC MODE
          AND     #$F
          BNE     CONTFAST
          JSR     TABLEINC
          JMP     END1

CONTFAST  CMP     #1                     ;SEE IF IN GOHOME MODE
          BNE     CONTFST1
          JSR     GOHOME
          JMP     END1

CONTFST1  CMP     #2                     ;SEE IF IN REAPPEAR MODE
          BNE     NOREAPP
          JMP     REAPPEAR

NOREAPP   CMP     #3                     ;SEE IF IN BLUE ATTACK MODE
          BNE     REDATAK
          JSR     BLUATK
          LDA     TYPE,Y
          CMP     #13                    ;SEE IF IS A SCORPION
          BNE     END1
          LDA     METACNT                ;GET META DELAY CNTR
          BMI     END1
          SEC
          SBC     #1
          STA     METACNT
          BEQ     META7
          CMP     #30
          BNE     END1
          LDX     #42
          BNE     META20
META7     LDX     #43

META20    LDA     #L(BATBL1)             ;MAKE
          STA     ML,X                   ;MTBLPTR AND MODE TO BE BLUE ATTACK
          LDA     #H(BATBL1)
          STA     MH,X
          LDA     #13
          STA     TYPE,X
          LDA     #0
          STA     ANGLE,X
          STA     MOMENTUM,X             ;CLEAR MOMENTUM OF SHIP
          LDA     XCORD,X                ;SEE IF ON LEFT OR RIGHT SIDE OF
          CMP     #80                    ;SCREEN AND THUS WHICH WAY TO ATTACK
          BCS     META21
          LDA     #$83
          BNE     META22
META21    LDA     #$C3
META22    STA     MODE,X
          INC     AIRBORNE               ;MAY NOT HAVE BEEN ALL THE WAY HOME
          JMP     END1

REDATAK   CMP     #4                     ;SEE IF IN RED ATTACK MODE
          BNE     ATAKBNOR
          JMP     ATAKRED

ATAKBNOR  CMP     #5                     ;SEE IF IN BOSS ATTACK MODE1
          BNE     ATKBOSS1
          JSR     BOSSATK1
          JMP     END1

ATKBOSS1  CMP     #6                     ;SEE IF IN BOSS ATTACK MODE2
          BNE     ATKBOSS2
          JSR     BOSSATK2
          JMP     END1

ATKBOSS2  CMP     #7                     ;SEE IF IN BOSS ATTACK MODE3
          BNE     ATKBOSS3
          JSR     BOSSATK3
          JMP     END1

ATKBOSS3  CMP     #8                     ;SEE IF IN BOSS ATTACK MODE4
          BNE     CHALTYPE
          JSR     BOSSATK4
          JMP     END1

CHALTYPE  CMP     #9                     ;SEE IF IN CHALLENGING ATTACK MODE
          BNE     END1
          JSR     TABLEINC
          JMP     END1

END1      DEY                            ;UPDATE NEXT SHIP
          BMI     DOMISS
          JMP     CHKMODE

DOMISS    LDY     #46                    ;UPDATE MISSLE POSITIONS
DOMISS1   LDA     TYPE,Y
          BEQ     DOMISS0
          JSR     MOVMIS
DOMISS0   INY
          CPY     #58
          BMI     DOMISS1


DOEXPL    LDY     #58                    UPDATE EXPLOSIONS
DOEXPL1   LDA     TYPE,Y
          BEQ     DOEXPL0
          JSR     EXPLO
DOEXPL0   INY
          CPY     #67
          BMI     DOEXPL1

DOSCROLL
          LDA     TWOPLAYR
          BEQ     DOHEROS
          LDA     DECREG
          BEQ     DOHEROS
          LDA     AIRBORNE
          BNE     DOHEROS                ;DON'T SCROLL IF SHIPS ARE FLYING
          LDA     SHIPCNT                ;SEE IF ALL SHIPS ON SCREEN
          CMP     #$3E
          BCC     DOSCROL1               ;NO, CAN SCROLL NOW
          LDA     ARRIVED                ;YES, WAIT FOR ARRIVED = $FF
          BEQ     DOHEROS
DOSCROL1  LDA     #1
          STA     ABORT                  ;PREVENT FURTHER ATTACKS/BIRTHS
          DEC     DECREG
          LDA     DECREG
          CMP     #135                   ;GIVE A LITTLE WAITING TIME FOR
          BCS     DOHEROS                ;THE CAPTURED HERO TO GO HOME
          CMP     #60
          BEQ     ENDDEC
          BPL     SCROLLUP
          LDA     PUNTSCRL               ;SEE IF SHOULD SCROLL
          BNE     SCRLLOOP
          JMP     RESTRT
SCRLLOOP  LDX     #40
SCROLDWN  INC     YCORD,X
          DEX
          BPL     SCROLDWN
PNTSCRL   DEC     DECREG
          BMI     RESTRT
          DEC     FRAME
SCRLWT    LDA     FRAME
          BMI     SCRLWT
          JMP     SCRLLOOP
RESTRT
          LDA     #0
          STA     DECREG
          STA     FRAME
          STA     PUNTSCRL
          JMP     BLOOP
SCROLLUP  LDA     PLAYER                 ;GET CURRENT PLAYER
          CLC
          ADC     #1
          AND     #$01                   ;CLEAR ALL BUT LSBIT
          TAX
          LDA     LIVES,X                ;SEE IF OTHER PLAYER IS ALIVE
          BEQ     PNTSCRL1
          STA     PUNTSCRL               ;SAVE VALUE FOR SCROLL BACK DOWN
          LDA     DECREG                 SEE IF SHOULD SCROLL CAPTD HERO
          CMP     #90                    IF LESS THAN 90, DONT SCROLL HERO
          BCS     DO40
          LDX     #39
          BNE     SCROLUP1
DO40      LDX     #40
SCROLUP1  DEC     YCORD,X
          DEX
          BPL     SCROLUP1
PNTSCRL1  JMP     DOHEROS
ENDDEC    JSR     DECLIVE1               ;SWITCHES TO OTHER PLAYER
          JMP     DOSCROLL

DOHEROS   LDY     #62
          LDA     TYPE,Y                 ;UPDATE HERO SHIPS
          BEQ     NEXTH
          LDA     HEROX
          CLC
          ADC     #7
          STA     XCORD,Y                ;UPDATE 62 IF ALIVE
          INY
          JMP     DOHER21
NEXTH     LDY     #63
          LDA     TYPE,Y
          BNE     DOHER2
          LDA     AIRBORNE               ;MAKE SURE NOBODY IS FLYING
          BEQ     NEXTH2
NEXTH3    JMP     END0
NEXTH2    LDA     MODE+40
          CMP     #8                     ;SEE IF IN SPIN MODE
          BEQ     NEXTH3
          CMP     #9                     ;SEE IF IN UNITE MODE
          BEQ     NEXTH3
          CMP     #11                    ;SEE IF IN PUT BACK DOWN MODE
          BEQ     NEXTH3

REVIVE    LDA     NOSWITCH
          BEQ     REVIVE1
          JSR     DECLIVE1
          LDA     #0
          STA     NOSWITCH
          BEQ     DOHER2
REVIVE1   LDA     DECREG
          BNE     DOHER2
          LDA     TWOPLAYR
          BNE     REVIVE3
          INC     DECDELAY
          LDA     DECDELAY               ;THIS IS FOR SINGLE PLAYER DELAY
          CMP     #60
          BMI     DOHER2                 ;  BETWEEN REVIVALS OF HERO SHIP
REVIVE3   JSR     DECLIVES
          LDA     #0
          STA     DECDELAY

DOHER2    LDA     MODE+40
          CMP     #9
          BNE     DOHER21
          JMP     UNTOUCH
DOHER21  ;LDA     HEROX
;         STA     XCORD,Y

UNTOUCH
          LDA     TYPE+63                ;SEE IF HERO ALIVE
          BEQ     NOREMIST               ;IE. JMP END0
          LDA     AUTOPLAY               ;NONZERO IF AUTOPLAY ACTIVE
          BNE     GOFIRE
          LDA     PLAYER                 ;SEE WHICH PLAYER ACTIVE
          BEQ     FIREPLY1
          BIT     INPT5
          BPL     GOFIRE
REMIST1   LDA     MISTIMER
          CMP     #5                    ;SEE IF LESS THAN 5 ALREADY
          BMI     NOREMIST               ;DON'T RESET MISTIMER
          LDA     #5                    ;SET TO 5
          STA     MISTIMER
NOREMIST  JMP     END0
FIREPLY1  BIT     INPT4                  ;SEE IF HERO SHIP IS FIRING
          BMI     REMIST1                ;FIRE BUTTON NONACTIVE
GOFIRE    LDA     MISTIMER
          BNE     NOREMIST               ;IE. END0
          LDA     MODE+63                ;SEE IF DUAL HERO MODE
          CMP     #10
          BNE     GOFIRE1
          LDY     #56
          LDA     TYPE,Y
          BEQ     DBLFIRE
          INY
          LDA     TYPE,Y
          BNE     NOREMIST
DBLFIRE
          LDA     PLAYER
          BEQ     INCPL1M
          INC     MISCNT12               ;INC # OF MISSILES FIRED
          BNE     INCMCNT2
          LDA     MISCNT12+1
          CLC
          ADC     #1
          BVS     CONTFIRE
          STA     MISCNT12+1              ;DONT INC PAST 32 THOUSAND
INCMCNT2  INC     MISCNT22
          BNE     CONTFIRE               ;CONTINUE W/ FIRING ROUTINE
          INC     MISCNT22+1
          JMP     CONTFIRE
INCPL1M   INC     MISCNT11               ;INC # OF MISSILES FIRED
          BNE     INNC1
          LDA     MISCNT11+1
          CLC
          ADC     #1
          BVS     CONTFIRE
          STA     MISCNT11+1              ;DONT INC PAST 32 THOUSAND
INNC1     INC     MISCNT21
          BNE     CONTFIRE               ;CONTINUE W/ FIRING ROUTINE
          INC     MISCNT21+1
CONTFIRE  LDA     #27                    ;THIS IS THE DBL MISSILE TYPE
          STA     TYPE,Y
          LDA     XCORD+63
          STA     XCORD,Y
          LDA     #0
          STA     ANGLE,Y
          LDA     #171
          STA     YCORD,Y
          BNE     GOFIRE2
GOFIRE1   LDY     #56
          LDA     TYPE,Y
          BEQ     FOSPA
          INY
          LDA     TYPE,Y
          BNE     END0
FOSPA
          LDA     PLAYER
          BEQ     INNC3                  ;DO PLAYER 1 COUNTERS
          INC     MISCNT12               ;INC # OF MISSILES FIRED
          BNE     INCMCNT3
          LDA     MISCNT12+1
          CLC
          ADC     #1
          BVS     CONTFIR2
          STA     MISCNT12+1              ;DONT INC PAST 32 THOUSAND
INCMCNT3  INC     MISCNT22
          BNE     CONTFIR2               ;CONTINUE W/ FIRING ROUTINE
          INC     MISCNT22+1
          JMP     CONTFIR2
INNC3     INC     MISCNT11               ;INC # OF MISSILES FIRED
          BNE     INNC4
          LDA     MISCNT11+1
          CLC
          ADC     #1
          BVS     CONTFIR2
          STA     MISCNT11+1              ;DONT INC PAST 32 THOUSAND
INNC4     INC     MISCNT21
          BNE     CONTFIR2               ;CONTINUE W/ FIRING ROUTINE
          INC     MISCNT21+1
CONTFIR2  LDA     #L(MISTYPE)
          STA     TYPE,Y
          LDA     XCORD+63
          STA     XCORD,Y
          LDA     #171
          STA     YCORD,Y
          LDA     #0
          STA     ANGLE,Y
GOFIRE2   LDA     #15
          STA     MISTIMER
          LDA     #7
          JSR     TUNIN                  ;HERO MISSILE TUNE

END0      LDA     EXPANR
          BMI     DONTBORN
          DEC     DECCNT
          BNE     BORNER
          LDA     #8
          STA     DECCNT
          LDA     TOGGLEM0
          LSR     A
          BCC     GOLEFT0C
          LDX     #9
ACKHACK   INC     COLPOS,X
          DEX
          BPL     ACKHACK
          LDA     COLPOS+9
          CMP     #135
          BNE     BORNER
          INC     TOGGLEM0
          JMP     BORNER
GOLEFT0C  LDX     #9
ACKHACK1  DEC     COLPOS,X
          DEX
          BPL     ACKHACK1
          LDA     COLPOS
          CMP     #15
          BNE     BORNER
          INC     TOGGLEM0
BORNER    DEC     BORNCNT
          BNE     DONTBORN
          LDA     SHIPCNT
          CMP     #$3D
          BPL     DONTBORN
          LDA     TYPE+63
          BNE     CALLB
          LDA     AIRBORNE
          BNE     CALLB                  ;WANT NO SHIPS FLYING
          JMP     REVIVE
CALLB     JSR     BIRTH
DONTBORN                                 ; DEC     FRAME
          LDA     ARRIVED
          BNE     NOTARR
          JSR     ARRIVE
NOTARR    LDA     EXPANR
          BPL     CONTDON
          DEC     EXPANC
          BNE     CONTDON
          JSR     EXLOOP
          LDA     #1
          STA     EXPANC
          INC     EXPANCC

CONTDON   RTS                            ;JMP     UPENLIST


REAPPEAR  CPY     #40
          BNE     REAPPP1
          LDA     ARRIVED
          BEQ     KILHERO
          LDA     HEROREAP               ;THIS WILL BE NONZERO IF HERO
                                         ;SHOULD NOT REAPPEAR
          BEQ     NKILHERO
KILHERO   LDA     #0
          STA     TYPE+40
          JMP     END1
NKILHERO  LDX     CHTAB40                ;GET CAPT'D HERO COL NUMBER
          BPL     REAPPP2
REAPPP1   LDX     CHTAB,Y
REAPPP2   LDA     COLPOS,X
          STA     XCORD,Y
          TYA
          TAX
          LDA     TYPE,Y
          BPL     REAP11
          JMP     REAP1
REAP11    ORA     #$80
          STA     TYPE,Y
          LDA     #$FE
          STA     YCORD,Y
          LDA     #4
          STA     ANGLE,Y
          LDA     RACK                   ;SEE IF CAN DO FAST REAPPEAR
          CMP     #2
          BNE     TSTLEV
          LDA     LEVELSEL
          BPL     NOACCEL
          LDA     FARREN
          CMP     #2
          BPL     NOACCEL
          LDA     #1
          STA     FARREN
          BNE     TSTNUM
TSTLEV    CMP     #12
          BCC     NOACCEL
          LDA     LEVELSEL               ;SEE IF IN NOVICE MODE
          BMI     NOACCEL
TSTNUM    LDA     #0
          STA     BOZO0                  ;CLEAR THE SHIP COUNTER
          LDX     #39
CNTSHPS   LDA     TYPE,X
          BNE     INCCNT
CNTSHP1   DEX
          BPL     CNTSHPS
          BMI     ENOUGH
INCCNT    INC     BOZO0
          LDA     RACK
          CMP     #32
          BPL     TENFAST
          LDA     BOZO0
          CMP     #3
          BPL     NOACCEL                ;TOO MANY SHIPS TO ACCELERATE
          BNE     CNTSHP1
TENFAST   LDA     BOZO0
          CMP     #11
          BPL     NOACCEL
          BNE     CNTSHP1
ENOUGH
          LDA     FARREN
          CMP     #1
          BNE     INCMOM
          LDA     BOZO0
          CMP     #1
          BNE     NOACCEL
          LDA     TYPE
          BEQ     NOACCEL
          LDA     TWOPLAYR
          BNE     NOACCEL
          LDA     LIVES
          CMP     #4
          BNE     NOACCEL
          LDA     #2
          STA     FARREN
          BNE     NOACCEL
INCMOM    LDA     MOMENTUM,Y             ;GET MOMENTUM BYTE
          ORA     #$80                   ;SET FLAG
          STA     MOMENTUM,Y
          CPY     #40
          BNE     NOACCEL
          LDX     CAPBOS1                GET CAPTURING BOSS MOMENTUM
          LDA     MOMENTUM,X
          ORA     #$80
          STA     MOMENTUM,X
NOACCEL   JMP     END1

REAP1     LDA     #$FF
          STA     BOZO0
ACCELRPR  INC     YCORD,X
          LDA     RESTABY,Y
          SEC
          SBC     #2
          CMP     YCORD,Y
          BEQ     DONER
          LDA     MOMENTUM,Y
          BPL     NOACCEL                ;DON'T ACCELERATE IF POSITIVE
          INC     BOZO0
          BEQ     ACCELRPR
          BNE     ENDONER


DONER
          LDA     #05
          STA     MODE,Y
ENDONER   JMP     END1





EXLOOP    DEC     COL0
          BNE     COLC1
          JSR     COLS0
          LDA     #7
          STA     COL0
COLC1     DEC     COL1
          BNE     COLC2
          LDA     #9
          STA     COL1
          JSR     COLS1
COLC2     DEC     COL2
          BNE     COLC3
          LDA     #12
          STA     COL2
          JSR     COLS2
COLC3     DEC     COL3
          BNE     COLC4
          LDA     #21
          STA     COL3
          JSR     COLS3
COLC4     DEC     COL4
          BNE     ENDC4
          LDA     #63
          STA     COL4
          JSR     COLS4
ENDC4     RTS


COLS0     LDA     TOGGLEM
          LSR     A
          BCS     COL0E
          INC     COLPOS                 ;COL0C
          DEC     COLPOS+9
          RTS
COL0E     DEC     COLPOS
          INC     COLPOS+9
          RTS

COLS1     LDA     TOGGLEM
          LSR     A
          BCS     COL1E
COL1C     INC     COLPOS+1
          DEC     COLPOS+8
          RTS
COL1E     DEC     COLPOS+1
          INC     COLPOS+8
          RTS

COLS2     LDA     TOGGLEM
          LSR     A
          BCS     COL2E
COL2C     INC     COLPOS+2
          DEC     COLPOS+7
          RTS
COL2E     DEC     COLPOS+2
          INC     COLPOS+7
          RTS

COLS3     LDA     TOGGLEM
          LSR     A
          BCS     COL3E
COL3C     INC     COLPOS+3
          DEC     COLPOS+6
          RTS
COL3E     DEC     COLPOS+3
          INC     COLPOS+6
          RTS


COLS4     LDA     TOGGLEM
          LSR     A
          BCS     COL4E
COL4C     INC     COLPOS+4
          DEC     COLPOS+5
          RTS
COL4E     DEC     COLPOS+4
          INC     COLPOS+5
          RTS







ATAKRED   LDA     TYPE,Y
          BPL     ATAKRED3
          JSR     MSHBTBL
          CPX     #0
          BNE     ATAKRED1
          BEQ     END11

ATAKRED1  LDA     MODE,Y
          EOR     #$40
          STA     MODE,Y
          LDA     TYPE,Y
          AND     #$7F
          STA     TYPE,Y
          LDA     #0
          STA     COUNTXY,Y


ATAKRED2  LDA     #L(REDTAB)
          STA     ML,Y
          LDA     #H(REDTAB)
          STA     MH,Y
          BNE     END11

ATAKRED3  JSR     MSHBTBL
          CPX     #0
          BNE     ATAKRED4
          LDA     YCORD,Y
          CMP     #194
          BCS     GORREAP
          BCC     END11

ATAKRED4  LDA     #0
          STA     TEMP1
          LDA     XCORD,Y
          CMP     #160                   SEE IF OFF SCREEN
          BCC     NOTOFF
          LDA     #0
NOTOFF    STA     TEMP0
          CMP     HEROX
          BCS     MAKENEG
          LDA     MODE,Y
          AND     #$BF
          STA     MODE,Y
          LDA     HEROX
          SEC
          SBC     TEMP0

CONTRA    CMP     #40
          BCS     RED64
RED32     INC     TEMP1
RED64     LDA     TEMP1
          BEQ     ATAKRED2
ATAKRED5  LDA     #L(REDTAB1)
          STA     ML,Y
          LDA     #H(REDTAB1)
          STA     MH,Y
          BNE     END11
MAKENEG   LDA     MODE,Y
          ORA     #$40
          STA     MODE,Y
          LDA     TEMP0
          SEC
          SBC     HEROX
          JMP     CONTRA


GORREAP
          LDA     #$82
          STA     MODE,Y
END11     JMP     END1



GOHOME
          LDA     TYPE,Y
          BMI     GO
          ORA     #$80
          STA     TYPE,Y
          LDA     #0
          STA     DONE,Y
          JSR     FINDFING               ;INITS FINPOSX AND FINPOSY
          LDA     XCORD,Y
          CMP     BOZO0
          BCS     MINUSG
          STA     TEMP1
          LDA     BOZO0
          SEC
          SBC     TEMP1
          STA     ML,Y                   ;ML CONTAINS THE X DIFFERENTIAL
          JMP     STOREY


MINUSG    SEC
          SBC     BOZO0
          ORA     #$80
          STA     ML,Y                   ;ML CONTAINS THE X DIFFERENTIAL

STOREY
          LDA     YCORD,Y
          SEC
          SBC     BOZO1
          STA     MH,Y                   ;MH CONTAINS THE Y DIFFERENTIAL

GO
          LDA     ML,Y
          AND     #$7F
          BEQ     DONEGOX
          STA     TEMP0
          LDA     #1
          STA     XSTEPY
          LDA     MH,Y
          STA     TEMP1
          CMP     TEMP0
          BCS     GOGEN
          ASL     XSTEPY
          LSR     TEMP0
          CMP     TEMP0
          BCS     GOGEN
          ASL     XSTEPY
          ASL     A
          CMP     TEMP0
          BCS     GOGEN
          ASL     XSTEPY

GOGEN     TYA
          TAX
          DEC     ML,X
          BMI     DECREASE
          INC     XCORD,X
          JMP     DOY

DECREASE
          DEC     XCORD,X

DOY
          LDA     MH,Y
          BEQ     DONEGOY
          STA     TEMP0
          LDA     COUNTXY,Y
          CMP     XSTEPY
          BCS     MOVEYONE
          INC     COUNTXY,X
          RTS

MOVEYONE  LDA     #1
          STA     COUNTXY,Y
          DEC     MH,X
          DEC     YCORD,X
          RTS


DONEGOX   LDA     #$FF
          STA     DONE,Y
          JMP     DOXY

DONEGOY
          LDA     DONE,Y
          BMI     FINI
          RTS

;WHEN IT GETS INTO EXPANSION DEC NUMFLY

FINI
          LDA     TYPE,Y
          AND     #$7F
          STA     TYPE,Y
          LDA     #0
          STA     MODE,Y
          LDA     TYPE,Y                 ;SEE IF SCORPION TYPE
          CMP     #13
          BNE     META13
          LDA     #1
          STA     TYPE,Y                 ;CHANGE BACK TO BLUE SHIP
META13    CPY     #40
          BEQ     FIXBS
;         DEC     NUMFLY
          CPY     #41
          BCS     FINI1
          DEC     AIRBORNE
FINI1     RTS
FIXBS     LDX     CAPBOS1                ;PUT IN CAPTURING BOSS NUMBER
          LDA     TYPE,X
          BEQ     CAPATTK                ;MAKE CAPTD HERO ATTACK
          AND     #$7F                   ;BOOT HIGH BIT
          CMP     #16                    ;SEE IF ALREADY KNOWS HE HAS A HERO
          BPL     FINI1
          LDA     TYPE,X
          CLC
          ADC     #13
          STA     TYPE,X
          RTS
CAPATTK   LDX     #40
          JSR     COTBOATK               ;MAKE HERO ATTACK
          LDA     #5
          STA     HEROREAP               ;INDICATE HERO MUST COME BACK NEXT RACK
          RTS



FINDFING
          CPY     #40
          BNE     FINDFINH
          LDX     CAPBOS1                ;GET CAPTURING BOSS NUMBER
          LDA     TYPE,X                 ;SEE IF ALIVE
          BNE     BOSALIVE
          LDX     #6
          JSR     GTNWCOL                ;GET NEW COLUMN
          BCS     BOSALIVE
          LDX     #17
          JSR     GTNWCOL
          BCS     BOSALIVE
          LDX     #26
          JSR     GTNWCOL
          BCS     BOSALIVE
          LDX     #35
          JSR     GTNWCOL
          JMP     BOSALIVE
;         BCC     BOSALIVE               ;NEED TO HANDLE THIS CASE WHEN DONE

GTNWCOL   LDA     TYPE,X
          BEQ     ENDGTCOL
          LDA     CHTAB,X
          STA     CHTAB40
          STX     CAPBOS1                ;INDICATE NEW CAPTURING BOSS
          SEC
          RTS
ENDGTCOL  CLC
          RTS

BOSALIVE  LDX     CHTAB40
          BPL     FINDFINI
FINDFINH  LDX     CHTAB,Y
FINDFINI  LDA     COLPOS,X
          STA     BOZO0
          LDA     RESTABY,Y
          STA     BOZO1
          RTS


DOXY
          CPY     #40
          BNE     DOXY1
          LDX     CHTAB40
          BPL     DOXY2
DOXY1     LDX     CHTAB,Y
DOXY2     LDA     COLPOS,X
          STA     TEMP0
          TYA
          TAX
          LDA     XCORD,Y
          CMP     TEMP0
          BEQ     DONTDOX0
          BCS     DECDOX
          INC     XCORD,X
          JMP     DONTDOX1

DECDOX
          DEC     XCORD,X

DONTDOX0
          LDA     RESTABY,Y
          STA     TEMP0
          LDA     YCORD,Y
          CMP     TEMP0
          BNE     DONTDOX3
          JMP     FINI
DONTDOX3  DEC     YCORD,X
          RTS

DONTDOX1
          LDA     RESTABY,Y
          STA     TEMP0
          LDA     YCORD,Y
          CMP     TEMP0
          BNE     CONTDONT
          RTS
CONTDONT
          DEC     YCORD,X
          RTS



*THIS SUBROUTINE TAKES THE INITIAL PARTS OF BOSS GALAGA *
*WHOSE INTENTION IS TO CAPTURE THE HERO SHIP*


BOSACAP
          LDA     TYPE,Y
          BPL     CAPBYAR                ;IF TYPE NEG THEN DONT USE TABLES
          JSR     MSHBTBL
          CPX     #0
          BNE     STOPTBL
          BEQ     END12

STOPTBL                                  ;THIS CHANGES THE MODE FROM TABLES
          LDA     TYPE,Y
          AND     #$7F                   ;INTO GOING BY ALGORITHM
          STA     TYPE,Y
END12     JMP     END1


CAPBYAR                                  ;GO IN A STRAIGHT LINE
          LDA     YCORD,Y
          CMP     #120                   ;IS THE CAPTURE POINT REACHED?
          BCC     NOTWAIT
          LDA     #03                    ;YES PUT IN THE WAIT MODE
          STA     MODE,Y
          LDA     #180
          STA     WAITCNT
          LDA     #21
          JSR     TUNIN                 ;START TRACTOR BEAM TUNE
          LDA     #26
          JSR     TUNIN                  ;SECOND TRACTOR BEAM CHANNEL
          LDA     XCORD,Y
          STA     CAPTUREX
          STY     CAPBOS1                 ;KEEP TRACK OF WHICH BOSS HAS HERO
          BNE     END12


NOTWAIT
          ADC     #2
          STA     YCORD,Y
          BNE     END12


BOSSWAIT  TYA
          TAX
          DEC     WAITCNT
          BEQ     SBCAPTUR
          LDA     RACK                   SEE IF FAST BEAM RACK
          CMP     #18
          BCC     NOFBEAM
          DEC     WAITCNT
          BEQ     SBCAPTUR
NOFBEAM   LDA     TYPE+40                ;CHECK TYPE OF HERO SHIP
          BNE     GONE0END               ;SHIP ALREADY CAPTURED
                                         ;LOWER SHIELDS
          JSR     CHECKCAP               ;DOES THE CHECKING IT SHIP GETS
                                         ;IN RANGE OF CAPTURE

          JMP     END1


SBCAPTUR  JSR     SCRAPALL               ;KILL TRACTOR BEAM
          LDA     TYPE+40                ;SEE IF HERO WAS CAPTURED
          BEQ     SBCAPTR1
          LDA     #23
          JSR     TUNIN                  ;HERO BEING TAKEN TO TOP OF SCREEN
          LDA     #24
          JSR     TUNIN                  ;SECOND CHANNEL OF TUNE
SBCAPTR1  LDA     CHTAB,Y
          STA     CHTAB40                ;GET PROPER COLUMN FROM BOSS
          LDA     XCORD+40
          CMP     #80
          BCS     NEGTABM
          LDA     #04                    ;SET MODE FOR END OF BOSS WAIT
          BPL     POSTABM                ;UNCONDITIONAL RELATIVE JUMP
NEGTABM   LDA     #$44
POSTABM   STA     MODE,Y
          STA     MODE+40
          LDA     TYPE,Y                 ;GET TYPE OF BOSS GALAGA
          BPL     GONE0END               ;BRANCH IF NO CAPTURE
          LDA     #L(PEELDOWN)
          STA     ML,Y                   ;SET BOSS FOR PEELDOWN
          STA     ML+40                  ;SET HERO FOR PEELDOWN
          LDA     #H(PEELDOWN)
          STA     MH,Y
          STA     MH+40
GONE0END  JMP     END1

CHECKCAP  LDA     TYPE+63                ;SEE IF HERO DEAD
          BEQ     ENDCAP
          LDA     WAITCNT                ;READ WAIT COUNTER
          CMP     #120                   ;FINISHED LOWERING SHIELDS?
          BCS     ENDCAP
          CMP     #60                    ;SHOULD SHIELDS BE RAISED?
          BMI     ENDCAP
          LDA     RACK
          CMP     #18
          BCC     CONTCAP                LOW RACK, CHECK CAPTURE LONGER
          LDA     WAITCNT
          CMP     #80
          BMI     ENDCAP
;NOW CHECK FOR CAPTURE OF HERO SHIP
CONTCAP   LDA     CAPTUREX               ;GET XPOS OF BOSS GALAGA
          CMP     HEROX
          BCS     TESTPOS                ;CAPTUREX > HEROX
TESTNEG   LDA     HEROX                  ;CAPTUREX < HEROX
          SEC
          SBC     CAPTUREX               ;GET DIFFERENCE
          CMP     #12                    ;WITHIN RANGE?
          BMI     CAPTURED
          BPL     ENDCAP
TESTPOS   SEC
          SBC     HEROX
          CMP     #12
          BMI     CAPTURED
          BPL     ENDCAP
CAPTURED  LDA     #$85                   ;5 IS HERO SHIP TYPE
          STA     TYPE+40                ;STORE NEW TYPE
          LDA     #7
          STA     MODE+40                ;SET HERO TWIRL MODE
          LDA     #171                   ;STARTING HERO YCORD
          STA     YCORD+40
          LDA     HEROX                  ;STARTING HERO XCORD
          STA     XCORD+40
          LDA     #0
          STA     ANGLE+40               ;SET ORIGINAL ANGLE TO 0
          LDA     TYPE,Y                 ;GET BOSS GALAGA TYPE
          CLC
          ADC     #13                    ;CHANGE TYPE TO SIGNIFY CAPTURE
          ORA     #$80                   ;SET TYPE TO MINUS
          STA     TYPE,Y
          LDA     #0
          STA     TYPE+63                ;KILL TRAPPED HERO SHIP
          LDA     MOMENTUM,Y             ;GET MOMENTUM OF BOSS
          AND     #$80                   ;ONLY KEEP HIGH BIT
          STA     MOMENTUM+40
          LDX     PLAYER                 ;GET CURRENT PLAYER
          LDA     LIVES,X                ;SEE HOW MANY LIVES LEFT
          CMP     #1
          BEQ     SWTCHSCR               ;WILL BE OUT OF LIVES AFTER THIS
          LDA     #$FF
          STA     NOSWITCH               ;DON'T SWITCH PLAYERS
SWTCHSCR  JSR     SCRAPALL
          LDA     #22
          JSR     TUNIN                  ;START HERO CAPTURE TUNE
ENDCAP    RTS


TWIRL
          LDA     #$FF
          STA     BOZO4
          INC     STARPTR                MOVE STARS BACKWARDS
          BPL     BACKSTAR
          LDA     #0
          STA     STARPTR
BACKSTAR
          LDA     YCORD+40               ;GET HERO SHIP YCORD
          SEC
          SBC     #1                     ;MOVE UP 1 PIXEL
          STA     YCORD+40
          CMP     #139
          BCC     ENDCHCK
          LDA     XCORD+40               ;GET HERO XCORD
          CMP     CAPTUREX               ;COMPARE TO BOSS POSITION
          BCS     MVLFT
MVRT      INC     XCORD+40               ;INCREMENT XCORD OF HERO SHIP
          JMP     CHNGANGL
MVLFT     DEC     XCORD+40               ;DEC XCORD OF HERO SHIP
CHNGANGL  LDA     RACK
          CMP     #18
          BCS     FASTANGL
          LDA     STARINC
          LSR     A
          BCC     ENDTWIRL
FASTANGL  INC     ANGLE+40
          JMP     END1
ENDCHCK   CMP     #133
          BNE     ENDTWIRL
          LDA     #6                     ;SIGNIFY HERO WAIT MODE
          STA     MODE+40
          LDA     #$4F
          STA     CAPTDREG               ;SIGNIFY "FIGHTER CAPTURED"
          BNE     ENDTWIL
ENDTWIRL  LDA     RACK
          CMP     #18
          BCC     ENDTWIL
          INC     BOZO4
          BEQ     BACKSTAR
ENDTWIL   JMP     END1

BCAPTUR                                  ;DIFFERENTIATE IF THERE IS A CAPTURED
          LDA     TYPE,Y                 ;SHIP TOGETHER
          BPL     BNCAPTUR
          JMP     BCAPTURE
BNCAPTUR
          LDA     YCORD,Y
          CLC
          ADC     #3
          STA     YCORD,Y
          CMP     #192
          BCS     GOINREP                ;OFF THE SCREEN?
          JMP     END1

GOINREP
          LDA     #$82
          STA     MODE,Y
          JMP     END1



BCAPTURE
          JSR     MSHBTBL
          CPX     #0
          BNE     STOPTBL1
          JMP     END1
STOPTBL1
          LDA     TYPE,Y
          AND     #$7F
          STA     TYPE,Y
          LDA     #$81
          STA     MODE,Y
          JMP     END1

ORIENT    LDA     TYPE,Y
          BPL     DODANG                 ;IF TRUE DO THE ANGLES
          LDA     YCORD,Y
          CLC                            ;ELSE ADD TO Y COORDINATE
          ADC     #1
          STA     YCORD,Y
          CMP     RESTABY,Y              ;IS IT AT REST POSITION
          BNE     GOTOEND
          LDA     TYPE,Y                 ;YES THEN START ANGLE PROCESSING
          AND     #$7F
          STA     TYPE,Y
          LDA     #8
          STA     COUNTXY,Y
GOTOEND   JMP     END1
DODANG    CPY     #40                    ;SEE IF CAPTD HERO
          BNE     DODANG01
          LDX     CHTAB40
          BPL     DODANG02
DODANG01  LDX     CHTAB,Y
DODANG02  LDA     COLPOS,X
          STA     XCORD,Y
          LDA     COUNTXY,Y
          BNE     GOTOEND0
          LDA     #8
          STA     COUNTXY,Y
          LDA     ANGLE,Y                ;DO THE ANGLES
          SEC
          SBC     #1
          STA     ANGLE,Y
          BEQ     DONEANG
          JMP     END1
DONEANG   LDA     #0
          STA     MODE,Y
;         LDA     TYPE+63                ;SEE IF HERO DEAD
;         BNE     DONEANG1               ;DEC IF HERO DEAD
          CPY     #40                    ;SEE IF CAPTD HERO
          BPL     DONEANG1               ;DONT DEC IF SO
          DEC     AIRBORNE               ;ALWAYS DEC WHEN DONE WITH ORIENT
DONEANG1  JMP     END1
GOTOEND0  SEC
          SBC     #1
          STA     COUNTXY,Y
          JMP     END1

HEROSPIN  LDA     MODE+40                ;GET CAPTURED HERO MODE
          CMP     #9                     ;SEE IF IN REUNITE MODE
          BEQ     REUNITE
          CMP     #8                     ;SEE IF IN SPIN MODE
          BNE     ENDHSPIN
          LDA     AIRBORNE               ;CHECK IF SHIPS ARE ATTACKING
          BNE     HSPIN1
          LDA     ANGLE+40               ;STOP SPINNING, SET PROPER ANGLE
          CMP     #0                     ;IS IT POINTING UP?
          BEQ     HSPIN2                 ;YES, CHANGE HERO MODE
          BNE     HSPIN1
HSPIN2    LDA     #9
          STA     MODE+40                ;CHANGE TO REUNITE MODE
                                         ;IN THE CAPTURE ATTEMPT
          BNE     ENDHSPIN
HSPIN1
          INC     ANGLE+40
ENDHSPIN  RTS

REUNITE   LDA     XCORD+40               ;GET CAPTURED HERO XCORD
          CMP     #80                    ;SEE IF AT CENTER YET
          BEQ     REINCY                 ;IF SO, INCREMENT YCORD
          BCS     REDECX                 ;IF GREATER, DECREMENT XCORD
          INC     XCORD+40               ;INCREMENT X POSITION
          RTS
REDECX    DEC     XCORD+40               ;DECREMENT X POSITION
          RTS
REINCY    LDA     YCORD+40               ;GET CAPTURED HERO YCORD
          CMP     #171                   ;SEE IF AT REST POSITION
          BEQ     UNITESHP
          INC     YCORD+40               ;LOWER SHIP ONE PIXEL
RNT1      LDA     XCORD+63               ;GET BASE XCORD
          CMP     #73                    ;SEE IF AT CENTER YET
          BEQ     ENDRNT
          BCS     RNT2
          INC     XCORD+63               ;MOVE HERO RIGHT
          JMP     ENDRNT
RNT2      DEC     XCORD+63               ;MOVE HERO LEFT
ENDRNT    LDA     #10                    ;PREVENT FURTHER FIRING
          STA     MISTIMER
          RTS

UNITESHP  LDA     TYPE+63                ;SEE IF HERO WAS KILLED
          BEQ     UNITESH2
          LDA     XCORD+63               ;SEE IF BASE HERO HAS ARRIVED
          CMP     #73
          BNE     RNT1                   ;NO, WAIT LONGER
;         LDA     #73
 ;        STA     HEROX                  ;INITIALIZE HEROX
          LDA     #5
          STA     TYPE+62                ;INITIALIZE 2ND HERO SHIP
          LDA     #10
          STA     MODE+63                ;SET HERO DUAL MODE
UNITESH1  LDA     #0
          STA     MODE+40                ;RESET MODE
          STA     TYPE+40                ;KILL CAPTURED HERO SHIP
          STA     ANGLE+62               ;SET NEW HERO ANGLE
          LDA     #80
          STA     XCORD+62               ;SET NEW HERO XCORD
          LDA     #171                   ;INIT 2ND HERO YCORD
          STA     YCORD+62
          LDA     #5
          JSR     SCRAPONE
          LDA     #6
          JSR     SCRAPONE               ;KILL RELEASE TUNE
ENDUNITE  RTS

UNITESH2  LDA     XCORD+40
          CMP     #80                    ;SEE IF AT CENTER YET
          BNE     ENDUNITE               ;WAIT LONGER
;         STA     XCORD+63
          STA     HEROX
          LDA     #5
          STA     TYPE+63
          JMP     UNITESH1


PEELDOWN  DB      $04,$04,$24,$07,$24,$24
          DB      $27,$40,$44,$43,$5C,$3C
          DB      $3C,$3F,$1C,$3C,$1C,$1C
          DB      2,2,2,2,2                     ;2 INDICATES END OF TABLE

PEELOFF   DB      $38,$59,$5C,$21,$45
          DB      $48,$29
          DB      2,2,2,2,2,2                    ;HERE COMES THE PEELOFF  TABLE
REDTAB    DB      $04,$04
          DB      $04,$24,$04,$04,$04
          DB      $24,$04,$04,$24
          DB      $04,$04
          DB      $24,$04,$20,$24
          DB      $04,$23,$04,$20
          DB      $04,$24,$24,$20
          DB      $24,$24,$24,$24
          DB      $20,$24,$24,$24
          DB      $24,$24,$20,$04
          DB      $24,$24,$24,$20
          DB      $04,$24,$24,$20
          DB      $04,$24,$20,$04
          DB      $24,$24,$04,$20
          DB      $24,$04,$20,$05
          DB      $04,$24,$04,$04
          DB      $24,$04,$04,$04
          DB      $24,$04,2,2

REDTAB1   DB      $04,$04,$04,$04
          DB      $04,$20,$04,$07
          DB      $20,$24,$24,$20
          DB      $24,$04,$24,$04
          DB      $20,$24,$24,$20
          DB      $24,$04,$24,$04
          DB      $20,$04,$05,$20
          DB      $04,$04,$04,$04
          DB      $04,$04,$04,$04
          DB      $04,2,2

CHTAB     DB      0,9,0,9,1,8,3,1,8,1
          DB      8,1,8,2,7,2,7,6,2,7
          DB      2,7,3,6,3,6,4,3,6,3
          DB      6,4,5,4,5,5,4,5,4,5
          DB      0


RESTABY   DB      61,61,49,49,37,37,13,61,61,49
          DB      49,25,25,61,61,37,37,13,49,49
          DB      25,25,61,61,37,37,13,49,49,25
          DB      25,61,61,37,37,13,49,49,25,25
          DB      1

