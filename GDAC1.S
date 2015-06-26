;GDAC1.S
;THIS SUBROUTINE GIVES BIRTH TO A SINGLE SHIP OR PAIR OF SHIPS
;IT GIVES BIRTH ACCORDING TO SHIPCNT AND RACK NUMBER
;IT ALSO RESETS BORNCNT
;IT ALSO INCREMENTS SHIPCNT APPROPRIATELY
;
;THE TEMPORARY VARIBLES IT USES ARE
;TEMP1    DS      2                      ;0 PAGE
;TEMP2    DS      2                      ;0 PAGE
;LOOPCNT  DS      1
;
;THE CONSTANTS USED
;TIBTNBIR EQU     ??                     ;FRAMES BETWEEN BIRTHS
;TIBTNWAV EQU     ??                     ;SIZE OF EACH ENTRY IN ENEMY LIST
;NOTFOSH  EQU     ??
;
BIRTH     LDA     ABORT
          BEQ     BIRTH9
          RTS                            ;RETURN IF ABORT = 1
BIRTH9    LDA     CHALSTG                ;SEE IF CHALLENGING STAGE
          BEQ     BIRTH7                 ;IF NOT, GO ON
          LDA     CHALWAVE               ;SEE IF NEW CHALLENGING WAVE
          BEQ     BIRTH7                 ;ONLY CARE ABOUT START OF NEW WAVE
          LDA     AIRBORNE               ;SEE IF AIRBORNE = 0
          BEQ     BIRTH10
          RTS
BIRTH10   LDA     #0
          STA     CHALWAVE               ;USED FOR LONG CHALLENGING WAVES
BIRTH7    LDA     NEWWAVE
          BEQ     BIRTH1
          LDA     TYPE+41
          CLC
          ADC     TYPE+42
          ADC     TYPE+43
          ADC     TYPE+44
          BEQ     BIRTH1
          LDA     #4
          STA     BORNCNT
          RTS
BIRTH1    LDA     SHIPCNT
          CMP     #13
          BEQ     STRTWV
          CMP     #25
          BEQ     STRTWV
          CMP     #37
          BEQ     STRTWV
          CMP     #49
          BEQ     STRTWV
          BNE     BIRTH8
STRTWV    LDA     #0
          STA     WAVECNT                ;INDICATE TIME FOR NEW WAVE
          STA     WAVESCR                ;RESET SCORE FOR CHALLENGING WAVE
          STA     SHPERWAV               ;RESET # OF SHIPS BORN THIS WAVE
BIRTH8    LDA     WAVECNT
          BEQ     INCWVREG
          LDA     CHALSTG
          BEQ     BIRTH11
          LDA     CHALINDX
          JMP     NOCHNG
BIRTH11   LDA     WAVEREG
          JMP     NOCHNG
INCWVREG  LDA     #$FF
          STA     WAVECNT                ;RESET WAVECNT
          LDA     CHALSTG
          BEQ     INCWVRG
          LDA     CHALINDX               ;GET INDEX FOR CHALLENGING STAGES
          CMP     #39                    ;SEE IF NEED TO RESET IT
          BNE     INDXOK
          LDA     #0
          STA     CHALINDX
          BEQ     NOCHNG
INDXOK    CLC
          ADC     #1
          STA     CHALINDX
          BNE     NOCHNG
INCWVRG   LDA     WAVEREG
          CMP     #14                    ;SEE IF NEED TO RESET IT
          BNE     INDXOK1
          LDA     #0
          STA     WAVEREG
          BEQ     NOCHNG
INDXOK1   CLC
          ADC     #1
          STA     WAVEREG
NOCHNG    TAY
          LDA     RACK                   ;SEE IF LOW RACK
          CMP     #3
          BCS     UPPERRK
          LDA     LOWPAIR,Y
          BNE     STRLPCNT
UPPERRK   LDA     CHALSTG                ;SEE IF CHALLENGING STAGE
          BEQ     HIPAIR
          LDA     CHALPAIR,Y             ;GET CHALLENGING PAIR CODE
          BNE     STRLPCNT
HIPAIR    LDA     HIGHPAIR,Y
STRLPCNT  STA     LOOPCNT
DOSISTER
          LDA     CHALSTG                ;SEE IF CHALLENGING STAGE
          BEQ     REGSTG
          LDA     CHALNUM                ;GET # OF THIS CHALLENGING STAGE
          ASL     A                      ;MULT BY 2
          TAY
          LDA     CHALTBL,Y              ;GET LOW BYTE OF ADDRESS
          STA     TEMP1
          INY
          LDA     CHALTBL,Y
          STA     TEMP1+1
GETINDX   LDA     SHIPCNT
          SEC
          SBC     #1                     ;1ST SHIP IS ZEROTH ENTRY
          TAY
          LDA     SHIPINDX,Y
          TAY
          LDA     (TEMP1),Y              ;GET ADDRESS OF SHIP DATA AND PLACE
          STA     TEMP2                  ;IN 0 PAGE, TEMP2
          INY
          LDA     (TEMP1),Y
          STA     TEMP2+1
          LDA     SHIPCNT                ;LOOKUP THE SHIP NUMBER
          CMP     #61                    ;FIRST, SEE IF IS INVISO SHIP
          BNE     NOTINV
          JMP     FOINVISO
REGSTG    LDA     RACK
          CMP     #3
          BCC     LOWRK
FIXRK     SEC
          SBC     #4
          CMP     #3
          BCS     FIXRK                  ;GET INDEX OF 0,1, OR 2
          ASL     A
          TAY
          LDA     HIREGTB,Y
          STA     TEMP1
          INY
          LDA     HIREGTB,Y
          STA     TEMP1+1
          BNE     GETINDX
LOWRK     SEC
          SBC     #1
          ASL     A
          TAY
          LDA     LOWREGTB,Y
          STA     TEMP1
          INY
          LDA     LOWREGTB,Y
          STA     TEMP1+1
          BNE     GETINDX
NOTINV    SEC
          SBC     #1
          TAY
          LDA     SHPNUTB,Y
          CMP     #L(NOTFOSH)            ;SEE IF ENEMY TO BE BORN IS A FORM
          BNE     NFIMPTY                ;SHIP
          JMP     FIEMPTY
NFIMPTY   TAX                            ;SHIP NUMBER IS INDEX FOR FORM SHIP
FOEMPTY   LDY     #6
          LDA     (TEMP2),Y              ;NEXT LOOKUP AND STORE REST OF DATA
          STA     MODE,X
          DEY
          LDA     (TEMP2),Y
          STA     MH,X
          DEY
          LDA     (TEMP2),Y
          STA     ML,X
          DEY
          LDA     (TEMP2),Y
          STA     ANGLE,X
          DEY
          LDA     (TEMP2),Y
          STA     YCORD,X
          DEY
          LDA     (TEMP2),Y
          STA     XCORD,X
          DEY
          LDA     #0
          STA     MOMENTUM,X             ;GIVE ZERO MOMENTUM TO START
          LDA     (TEMP2),Y
          STA     TYPE,X
          BEQ     NOAIR
          CMP     #6
          BEQ     NOAIR
          LDA     CHALSTG                ;SEE IF CHALLENGING STAGE
          BEQ     CHKEXTRA               ;IF NOT, CHECK NORMALLY
          BNE     NOEXTRA                ;IF SO, NO EXTRAS
CHKEXTRA
          LDA     HEROREAP               ;SEE IF HERO MUST REAPPEAR
          BEQ     CHECKRAK
          BPL     CHKCPHER
          LDA     #0
          STA     HEROREAP               ;RESET REGISTER
          BEQ     NOAIR                  ;DONT CHANGE NUMFLY
CHKCPHER  LDA     SHPERWAV               ;SEE IF READY FOR EXTRA
          CMP     #8
          BNE     CHECKRAK               ;DO NORMAL PROCESSING
          DEC     HEROREAP
          BNE     CHECKRAK
          LDA     #0
          STA     TYPE,X                 ;BOOT EXTRA MAN JUST CREATED
          LDA     #L(SHTY52)
          STA     TEMP2
          LDA     #H(SHTY52)
          STA     TEMP2+1
          LDA     #$FF
          STA     HEROREAP
          LDX     #40
          BNE     FOEMPTY

CHECKRAK  LDA     RACK
          CMP     #3                     ;SEE IF EXTRA MAN RACK
          BCS     CHECKFST
NOEXTRA   LDA     SHPERWAV
          CMP     #8
          BMI     GIVEXTRA
          LDA     #0
          STA     TYPE,X
          BEQ     NOAIR
CHECKFST  CMP     #10
          BMI     GIVEXTRA               ;3<X<10=GIVE EXTRA MEN
          CMP     #16
          BMI     NOEXTRA                ;10<X<16=NO EXTRA
GIVEXTRA  INC     AIRBORNE
NOAIR     INC     SHIPCNT
          INC     SHPERWAV
          LDA     SHIPCNT                ;SEE IF JUST DID LAST SHIP TO ENTER
          CMP     #61                    ;AND SHOULD DO INVISO SHIP
          BNE     NODO
          JMP     DOSISTER
NODO      DEC     LOOPCNT
          BEQ     NOJMP
          JMP     DOSISTER               ;SEE IF FINISHED WITH THE PAIR
NOJMP     LDA     SHIPCNT
          CMP     #13
          BEQ     ENDWAV
          CMP     #25
          BEQ     ENDWAV
          CMP     #37
          BEQ     ENDWAV
          CMP     #49
          BEQ     ENDWAV
          LDA     #0
          STA     NEWWAVE
          LDA     RACK
          CMP     #10                    ;GO FASTER AT RACK 10
          BCC     STCNT1
          LDA     CHALSTG                ;SEE IF CHALLENGING STAGE
          BNE     STCNT1                 ;KEEP NORMAL BIRTH IF SO
          LDA     LEVELSEL               ;SEE IF IN BONZO MODE
          BMI     STCNT1                 ;IF SO, LEAVE BORNCNT ALONE
          LDA     #9
          STA     BORNCNT
          RTS

FOINVISO  LDA     #0
          STA     WAVECNT
          LDX     #45                    ;GIVING BIRTH TO INVISO SHIP, SO SET
                                         ;PTR TO INVISO SHIP LOCATION, AND SHIP
          JMP     FOEMPTY                ;TO PROPER NUMBER

FIEMPTY   LDX     #40                    ;FIND 1ST EMPTY SPOT FOR NON-FORM SHIP
KEEPLOOK  INX                            ;INC PTR
          LDA     TYPE,X                 ;NOW SEE IF SPOT IS EMPTY
          BNE     KEEPLOOK
          JMP     FOEMPTY

STCNT1    LDA     #L(TIBTNBIR)           ;THESE ARE REARRANGED TO HANDLE
          STA     BORNCNT                ;A BRANCH OUT OF RANGE
          RTS
ENDWAV    LDA     #$FF
          STA     NEWWAVE
          STA     CHALWAVE               ;INDICATE START OF CHALLENGING WAVE
          LDA     LEVELSEL               ;SEE IF IN BONZO MODE
          BMI     BONZO4
          LDA     RACK
          CMP     #10
          BCC     BONZO4                 ;IF LESS THAN 5,DONT INCREASE SPEED
          LDA     CHALSTG                ;SEE IF CHALLENGING STAGE
          BNE     BONZO4                 ;IF SO,  DONT INCREASE SPEED
          LDA     #L(TIBTNFWV)
          BNE     BONZO5
BONZO4    LDA     #L(TIBTNWAV)
BONZO5    STA     BORNCNT
          RTS


;
;THIS SUBROUTINE SEES IF IT IS TIME TO FIRE A MISSLE
;
TOFIRE    LDA     MODE+40                ;SEE IF CAPTD HERO IS RELEASED
          CMP     #8                     ;SEE IF IN SPIN MODE
          BEQ     ENDFIRE6               ;RETURN
          CMP     #9                     ;SEE IF IN REUNITE MODE
          BEQ     ENDFIRE6               ;RETURN
          LDY     #0                     ;SET ELISTPTR TO BEGINNING OF ENMYLSTF
NXFIRE    LDA     TYPE,Y                 ;SEE IF ENEMY EXISTS
          AND     #$7F
          BEQ     NXPOSI
          LDA     ARRIVED
          BNE     FIRE1                  ;IF ALREADY ARRIVED, GO ON
          LDA     RACK                   ;SEE IF NON FIRING RACK
          CMP     #1
          BEQ     ENDFIRE6
          CMP     #10
          BEQ     ENDFIRE6
          CMP     #18
          BEQ     ENDFIRE6
FIRE1
          LDA     ANGLE,Y
          CMP     #3
          BMI     NXPOSI
          CMP     #6
          BPL     NXPOSI                 ;ONLY FIRE IF ANGLE=3,4,OR 5
          LDA     ARRIVED                ;SEE IF HAVE ARRIVED YET
          BEQ     BLUEFIRE               ;NOT ARRIVED, SO FIRE LOWER
          LDA     TYPE,Y                 ;CHECK OUT TYPE
          AND     #$7F                   ;BOOT HIGH BIT
          CMP     #1
          BEQ     BLUEFIRE
          LDA     YCORD,Y
          CMP     #52
          BEQ     FIREIT
          CMP     #57
          BEQ     FIREIT
          LDA     BULLSHT                ;SEE IF SHOULD GET TOUGH
          BMI     BLUEFIRE
          BPL     NXPOSI
BLUEFIRE  LDA     YCORD,Y
          CMP     #72                    ;SEE IF ENEMY IS AT Y=72
          BEQ     FIREIT
          CMP     #77
          BEQ     FIREIT
          BIT     BULLSHT
          BPL     NXPOSI
          CMP     #8
          BEQ     FIREIT
          CMP     #37
          BEQ     FIREIT
          BNE     NXPOSI
FIREIT    LDA     MODE,Y                 ;MAKE SURE NOT IN CAPTURE MODE
          BPL     NXPOSI
          AND     #$F                    ;OR IN GO HOME MODE
          CMP     #1
          BEQ     NXPOSI
          JSR     BIRMIS
          RTS
NXPOSI    INY                            ;INC ELISTPTR TO NEXT ENEMY
          CPY     #40
          BNE     NXFIRE
ENDFIRE6  RTS


;
;THIS SUBROUTINE GIVES BIRTH TO A MISSLE AT THE LOCATION OF THE ENEMY POINTED
;TO BY THE Y REG.  THE MISSLE IS PLACED IN THE FIRST EMPTY LOCATION IN THE
;MISSLE LIST.  EACH MISSLE LIST ENTRY TAKES 5 BYTES: TYPE, XPOS, YPOS, XTOGO,
;YTOGO.  XTOGO AND YTOGO ARE INITIALLY SET AS (HERO POS AT CONCEPTION)-(BIRTH
;POSITION).
;THE FOLLOWING REGISTERS AND CONSTANTS ARE USED
;MISTYPE  EQU     ?                      ;MISSLE TYPE
;TEMP1    DS      1                      ;TEMPORARY ZERO PAGE REGISTER
;
BIRMIS    LDA     RACK                   ;FIGURE MAX NUMBER OF MISSLES THAT
          AND     #$1F                   ;CAN EXIST
          TAX
          LDA     NUMMIS,X
          STA     TEMP1
          LDA     BULLSHT                SEE IF IN BULLSHIT MODE
          BPL     NORMBIR
          INC     TEMP1
          INC     TEMP1
NORMBIR   LDA     CHALSTG                ;SEE IF CHALLENGING STAGE
          BNE     NOTBONZ1               ;DONT BONZ IF SO
          LDA     LEVELSEL               ;CHECK IF IN BONZO MODE
          BPL     NOTBONZ1
          LDA     #47
          STA     TEMP1                  ;ALLOW ONE MISSILE ON SCREEN
NOTBONZ1  LDX     #46                    ;MAKE PTR POINT TO FIRST MISSLE SPOT
NOSP      CPX     TEMP1
          BNE     FINSPA
          RTS                            ;NO SPACE, SO RETURN
FINSPA    LDA     TYPE,X                 ;SEE IF POSITION IS EMPTY
          BEQ     FOSP
          INX
          JMP     NOSP
FOSP      LDA     #L(MISTYPE)            ;FOUND SPACE, SO GIVE BIRTH TO MISSLE
          STA     TYPE,X                 ;BY STORING MISSLE-TYPE, AND X AND Y
          LDA     XCORD,Y                ;POSITION INTO MISSLE LIST
          STA     XCORD,X
          LDA     YCORD,Y
          STA     YCORD,X
          LDA     #4                     ;ORIENTATION OF ENEMY MISSLES
          STA     ANGLE,X
          INC     BULLSHT                ;INC MISSILE COUNTER
          LDA     XCORD+63               ;NOW CALCULATE TRAJECTORY
          CMP     XCORD,X                ;SEE WHO IS BIGGER
          BCC     HEROLESS
          SEC
          SBC     XCORD,X
          BIT     BULLSHT                ;SEE IF HE'S WASTING TIME
          BPL     XLT78
          CMP     #100
          BCC     XLT88
          LDA     #10
          BNE     YGOMIS
XLT88     CMP     #70
          BCC     XLT78
          LDA     #8
          BNE     YGOMIS
XLT78     CMP     #45
          BCC     XLT56
          LDA     #4
          BNE     YGOMIS
XLT56     CMP     #27
          BCC     XLT33
          LDA     #3
          BNE     YGOMIS
XLT33     CMP     #11
          BCC     XLT11
          LDA     #2
          BNE     YGOMIS
XLT11     CMP     #5
          BCC     XLT5
          LDA     #1
          BNE     YGOMIS
XLT5      LDA     #0
YGOMIS    STA     MODE,X                 ;STORE XTOGO
          STA     ML,X
          LDA     #4                     ;STORE YTOGO
          STA     COUNTXY,X
          STA     MH,X
          RTS

HEROLESS  LDA     XCORD,X
          SEC
          SBC     XCORD+63
          BIT     BULLSHT
          BPL     XLTN78
          CMP     #100
          BCC     XLTN88
          LDA     #$F6
          BNE     YGOMIS
XLTN88    CMP     #70
          BCC     XLTN78
          LDA     #$F8
          BNE     YGOMIS
XLTN78    CMP     #45
          BCC     XLTN56
          LDA     #$FC
          BNE     YGOMIS
XLTN56    CMP     #27
          BCC     XLTN33
          LDA     #$FD
          BNE     YGOMIS
XLTN33    CMP     #11
          BCC     XLTN11
          LDA     #$FE
          BNE     YGOMIS
XLTN11    CMP     #5
          BCC     XLT5
          LDA     #$FF
          BNE     YGOMIS


;
;THE FOLLOWING SUBROUTINE MOVES A MISSLE ONE 'STEP'.  THE SIZE OF THE 'STEP'
;DEPENDS ON THE RATIO OF XTOGO TO YTOGO:
;THE MISSLE MOVED IS POINTED TO BY Y REG
;IF THE MISSLE IS THE HERO'S, THEN THE YPOS IS JUST DECREMENTED
;Y REG IS SAVED
;
MOVMIS    LDA     ANGLE,Y                ;SEE IF HERO MISSLE
          BNE     ENMIS
          LDA     RACK                   ;SEE IF FASTER
          CMP     #10
          BCC     SLOWER
          LDA     #$FB
          BNE     SLOWER1
SLOWER    LDA     #$FC                   ;IS HERO MISSLE, SO ONLY MOVEMENT IS
SLOWER1   CLC                            ;TO DECREMENT YPOS
          ADC     YCORD,Y
          CMP     #192                   ;NOW SEE IF OFF SCREEN
          BCC     DOMOV                  ;YES, SO ERASE MISSLE
          LDA     PLAYER
          BEQ     INNC5                  ;DO PLAYER 1
          LDA     MISCNT22
          SEC
          SBC     #1                     ;MISSILE WAS NOT A HIT
          STA     MISCNT22
          LDA     MISCNT22+1
          SBC     #0
          STA     MISCNT22+1
          JMP     INNC6
INNC5
          LDA     MISCNT21
          SEC
          SBC     #1                     ;MISSILE WAS NOT A HIT
          STA     MISCNT21
          LDA     MISCNT21+1
          SBC     #0
          STA     MISCNT21+1
INNC6     LDA     #0
          STA     TYPE,Y
          RTS
DOMOV     STA     YCORD,Y
          RTS

ENMIS     TYA                            ;TRANSFER POINTER FROM Y REG TO X REG
          TAX
          LDA     ML,X                   ;GET XTOGOING
          BEQ     MOVMISY                ;SEE IF ZERO
          BMI     MISMINX                ;SEE IF NEGATIVE
          DEC     ML,X                   ;XTOGOING IS POSITIVE
          INC     XCORD,X
          LDA     MODE,X                 ;GET XTOGO
          CMP     #$A                    ;SEE IF BULLSHT SET
          BNE     MOVMISY
          INC     XCORD,X
          BNE     MOVMISY
MISMINX   INC     ML,X                   ;XTOGOING IS NEGATIVE
          DEC     XCORD,X
          LDA     MODE,X                 ;GET XTOGO
          CMP     #$F6
          BNE     MOVMISY
          DEC     XCORD,X
MOVMISY   LDA     YCORD,X
          CLC
          ADC     #2
          STA     YCORD,X
          CMP     #192
          BCS     ERAMIS
          DEC     MH,X                   ;DEC YTOGOING
          BEQ     REMISXY                ;SEE IF NEC. TO RESET X AND Y-TOGOING
          RTS
REMISXY   LDA     MODE,X                 ;RESET X AND Y-TOGOING
          STA     ML,X
          LDA     COUNTXY,X
          STA     MH,X
          RTS
ERAMIS    LDA     #0                     ;MISSLE OFF THE SCREEN, SO ERASE
          STA     TYPE,X
          RTS


;
;THIS SUBROUTINE MOVES A ENEMY SHIP POINTED TO BY Y REG ONE STEP BY CALLING
;A SUBROUTINE THAT USES A MOTION TABLE
;
;IT HAS NO PERMANENT LOCAL VARIBLES
;ITS TEMPORARY VARIBLES ARE:
;TEMP1    DS      2                      ;0 PAGE
;
;CONSTANTS ARE
;NOTFOSH  EQU     ?                      ;SHIP NUMBER FOR NON-FORMATION SHIPS
;Y REGISTER IS SAVED, ALL OTHER
;REGISTERS ARE DESTROYED
;
TABLEINC  JSR     MSHBTBL                ;CALL SUBROUTINE TO MOVE SHIP BY TABLE
          TXA                            ;SEE IF END OF TABLE
          BNE     ENDTBL
          RTS
ENDTBL    LDA     MODE,Y
          AND     #$F
          CMP     #9
          BNE     NOTCHAL
          LDA     #0                     ;YES, END OF TABLE, SO GET RID OF
          STA     TYPE,Y
          CPY     #40
          BPL     INVSHIP
          DEC     AIRBORNE
          BNE     INVSHIP                SEE IF ALL SHIPS ARE OFF
          LDA     #80
          STA     BORNCNT                DELAY NEXT WAVE
INVSHIP   RTS
NOTCHAL
          LDA     TYPE,Y
          AND     #$7F
          CMP     #13                    ;SEE IF EXTRA SCORPION SHIPS
          BNE     NOTSCORP
          LDA     #0
          STA     TYPE,Y
          DEC     AIRBORNE
          RTS
NOTSCORP  CPY     #41                    ;IS END, SO FIRST SEE IF FORMATION SHIP
          BMI     FORMSH
          CPY     #45
          BNE     NFORMSH
FORMSH    LDA     #$81                   ;IS FORMATION SHIP, SO CHANGE MODE TO
          STA     MODE,Y                 ;'GO HOME'
          RTS
NFORMSH   JSR     ATTKBL                 ;NOT FORM. SHIP AND COMING SO CHANGE
          DEC     AIRBORNE               ;THIS CANCELS THE INC AIRBORNE DONE
                                         ;IN ATTKBL
          RTS                            ;MTBLPTR AND MODE TO BE BLUE ATTACK


;
;THIS SUBROUTINE ACTUALLY MOVES A SHIP POINTED TO BY Y REG VIA A MOTION TABLE
;IT ALSO INCREMENTS THE MOTION TABLE POINTER
;
;THE TEMPORARY VARIBLES ARE:
;TEMP1    DS      2                      ;0 PAGE
;
MSHBTBL   LDA     #$FF
          STA     MSHCNT
CNTMSHIP  LDX     #0                     ;INITIALIZATION
          LDA     MOMENTUM,Y             ;SEE IF SHIP HAS MOMENTUM
          BEQ     NORMTN
          CMP     #$80
          BEQ     NORMTN                 ;ONLY HAS FAST REAPPEAR SET
          SEC
          SBC     #1
          STA     MOMENTUM,Y             ;DECREASE MOMENTUM
          LDA     ML,Y
          STA     TEMP1
          LDA     MH,Y
          STA     TEMP1+1
          JMP     CONTMSH                ;CONTINUE WITH PROCESSING
NORMTN    LDA     ML,Y                   ;GET ML
          STA     TEMP1                  ;AND STORE IT IN 0 PAGE
          CLC                            ;INC BY 1
          ADC     #1
          STA     ML,Y                   ;AND UPDATE INTO ENEMY LIST
          LDA     MH,Y                   ;GET MH
          STA     TEMP1+1                ;AND STORE IT IN 0 PAGE
          ADC     #0                     ;INC MH
          STA     MH,Y                   ;AND UPDATE
          LDA     (TEMP1,X)              ;SEE IF END OF TABLE AND SHOULD DO
          TAX                            ;STORE TEMP1 VALUE
          AND     #3                     ;NOTHING BUT RETURN
          CMP     #2
          BNE     CONTMSH
          TXA                            ;GET TEMP1 AGAIN
          AND     #$0F                   ;BOOT HIGH NIBBLE
          CMP     #6                     ;SEE IF IS SETTING MOMENTUM
          BNE     NOTMMTM
          TXA
          LSR     A
          LSR     A
          LSR     A
          LSR     A                      ;NOW HAVE HIGH NIBBLE ONLY
          BEQ     NOTMMTM                ;IF MOMENTUM IS ZERO, MUST BE BLUATK
          CLC
          ADC     MOMENTUM,Y             ;IN CASE FAST REAPPEAR IS SET
          STA     MOMENTUM,Y             ;STORE NEW MOMENTUM
          JMP     MSHBTBL
NOTMMTM   LDX     #$FF
          RTS

CONTMSH   LDX     #0
          LDA     MODE,Y                 ;GET MODE BYTE
          AND     #$40                   ;SEE IF IN NEGATE MODE
          BEQ     NONEG1A
          LDA     (TEMP1,X)              ;GET DELTAS
          EOR     #3                     ;NEGATE DELTA ANGLE
          CLC
          ADC     #1
          JMP     NONEG1
NONEG1A   LDA     (TEMP1,X)              ;GET DELTAS
NONEG1    TAX                            ;ISOLATE ANGLE
          AND     #2
          BEQ     APLS                   ;ATTACH LEADING ONES IF DELTA ANGLE
          TXA
          ORA     #$FC                   ;IS NEG
          JMP     ANEG
APLS      TXA
          AND     #3
ANEG      CLC
          ADC     ANGLE,Y                ;AND UPDATE ANGLE
          AND     #07
          STA     ANGLE,Y
          LDX     #0
          LDA     (TEMP1,X)              ;GET DELTA Y
          LSR     A
          LSR     A
          TAX                            ;ATTACH LEADING ONES IF DELTA Y
          AND     #4
          BEQ     YPLS                   ;IS NEG
          TXA
          ORA     #$F8
          JMP     YNEG
YPLS      TXA
          AND     #7
YNEG      CLC
          ADC     YCORD,Y                ;AND UPDATE Y
          STA     YCORD,Y
          LDX     #0
          LDA     MODE,Y                 ;GET MODE BYTE
          AND     #$40                   ;SEE IF IN NEGATE MODE
          BEQ     NONEG2A
          LDA     (TEMP1,X)              ;GET DELTAS
          EOR     #$E0                   ;NEGATE DELTA X
          CLC
          ADC     #$20
          JMP     NONEG2
NONEG2A   LDA     (TEMP1,X)              ;GET DELTAS
NONEG2    ROL     A                      ;ISOLATE DELTA X
          ROL     A
          ROL     A
          ROL     A
          TAX                            ;ATTACH LEADING ONES IF DELTA X
          AND     #4
          BEQ     XPLS                   ;IS NEG
          TXA
          ORA     #$F8
          JMP     XNEG
XPLS      TXA
          AND     #7
XNEG      CLC
          ADC     XCORD,Y                ;AND UPDATE X
          STA     XCORD,Y
          LDA     RACK
          CMP     #10                    ;DON'T GO FASTER IF LOW RACK
          BCC     ENDMSHIP
          LDA     MOMENTUM,Y
          BMI     MOVAGAIN
          LDA     LEVELSEL               ;CHECK IF BONZO MODE
          BMI     ENDMSHIP               ;DONT SPEED UP IF SO
          LDA     CHALSTG                ;SEE IF CHALLENGING STAGE
          BNE     ENDMSHIP               ;DONT SPEED UP IF SO
          LDA     ARRIVED
          BNE     ENDMSHIP
MOVAGAIN  INC     MSHCNT
          BEQ     CNTMSHP1
ENDMSHIP  LDX     #0
          RTS
CNTMSHP1  JMP     CNTMSHIP

;
;THIS SUBROUTINE DETERMINES IF THE INVISO SHIP HAS ARRIVED.
;IF IT HAS ALL FORMATION SHIPS ARE CHANGED TO EXPANSION MODE
;
ARRIVE    LDA     TYPE+45                ;SET PTR TO INVISO SHIP
          CMP     #6                     ;AND SEE IF PRESENT
          BEQ     CHANGE2
          RTS
CHANGE2   LDA     MODE+45                ;GET INVISO SHIP MODE
          BEQ     CHANGE                 ;SEE IF IN SHIFTING MODE YET
          RTS
CHANGE    LDA     COLPOS+5
          CMP     #78
          BEQ     CHANGE3
          LDA     CHALSTG                SEE IF CHALLENGING STAGE
          BNE     CHANGE1                IF SO, END THE STAGE
          RTS
CHANGE3   LDA     TYPE+41                ;SEE IF ALL EXTRA SHIPS GONE
          CLC
          ADC     TYPE+42
          ADC     TYPE+43
          ADC     TYPE+44
          BEQ     CHANGE1
          RTS
CHANGE1                                  ;FINAL SHIP ARRIVED AND FORMATION IS
                                         ;CENTERED
          LDA     #0                     ;INVISO SHIP WORK DONE, SO GET RID OF
          STA     EXPANCC
          STA     TYPE+45
;         STA     NUMFLY                 ;SET NUMBER FLYING TO ZERO
          LDA     #$FF
          STA     ARRIVED
          STA     EXPANR
          RTS


;
;THIS SUBROUTINE CAUSES SHIPS TO PEELOFF AND ATTACK.
;
ATTACK    LDA     RDYREG                 ;SEE IF READY IS BEING DISPLAYED
          BEQ     ATAC1
          RTS
ATAC1     LDA     ABORT
          BEQ     ATTACK7
          RTS                            ;RETURN IF ABORT = 1
ATTACK7   LDA     ARRIVED                ;SEE IF ALL SHIPS ARRIVED
          BNE     CONTAT
          RTS

CONTAT    LDA     TYPE+63
          BNE     ATT00
          RTS
ATT00     LDA     MODE+40                ;GET MODE OF CAPTURED HERO
          CMP     #8
          BEQ     ATT01
          CMP     #9
          BNE     ATT0
ATT01     RTS                            ;IF IN SPIN OR REUNITE MODE, RETURN
ATT0      LDA     LEVELSEL               ;CHECK IF IN BONZO MODE
          BPL     NOTBONZ2
          LDA     AIRBORNE               ;WAS NUMFLY
          BEQ     NOTBONZ2
          RTS                            ;RETURN IF ONE SHIP ATTACKING
NOTBONZ2  LDA     RACK                   ;SEE IF ANY MORE SHIPS NEEDED TO
          AND     #$1F                   ;ATTACK
          TAY
          LDX     NUMATTK,Y
          CPX     AIRBORNE
          BPL     ATT1
          LDA     RACK
          CMP     #32
          BCS     MASSATTK
          RTS
MASSATTK  INX                            TWO MORE ATTACKING THAN BEFORE
          INX
          CPX     AIRBORNE
          BPL     ATT1
          RTS
ATT1      LDA     #0                     ;SET ELISTPTR TO FIRST SHIP OF FORM
          STA     SHIPLEFT               ;RESET SHIPLEFT FLAG
          TAX                            THIS COUNTS THE NO. OF ATTACK ATTEMPS
          LDY     ATTEMPT
          CPY     #39                    INC ATTEMPT TO NEXT ENTRY IN LIST
          BMI     NXATT
          LDY     #$FF
NXATT     INY
          LDA     TYPE,Y                 ;SEE IF SHIP IS PRESENT
          BEQ     NOGOT
          STA     SHIPLEFT               ;A SHIP PRESENT, SO SET SHIPLEFT FLAG
          BPL     NOGOT1                 ;1ST TEST TO SEE IF SHIP JUST ARRIVED
          LDA     MODE,Y                 ;2ND TEST TO SEE IF SHIP JUST ARRIVED
          CMP     #5
          BNE     NOGOT1
          LDA     EXPANCC                ;RANDOM FACTOR IF SHIP JUST ARRIVED
          AND     #1
          BNE     NOGOT1
          JMP     GOTONE1
NOGOT1    LDA     MODE,Y                 ;SEE IF SHIP IS IN EXPANSION MODE
          BEQ     GOTONE
NOGOT     INX                            INC COUNTER OF ATTACK ATTEMPTS
          CPX     #40
          BEQ     NONELEFT               NO SHIPS LEFT
          CPY     #39                    ;IF CAPTD HERO IS ALONE, SET ATTACK
          BNE     NXATT
          LDY     #$FF                   GO TO BEGINNING OF LIST AGAIN
          BNE     NXATT
NONELEFT  LDA     SHIPLEFT               ;NO MORE SHIPS TO PEELOFF, SO SEE IF
          BNE     NOATT                  ;IF ANY SHIPS FLYING AROUND
          JSR     NEWRACK                ;NO SHIPS LEFT, SO START NEW RACK
          RTS
GOTONE    STY     ATTEMPT
          LDA     TUNNUM
          AND     #$7F                   ;BOOT HIGH BIT
          CMP     #25
          BEQ     HASBACK                ;ALREADY HAS BACKGROUND MUSIC
          LDA     TUNNUM1
          AND     #$7F                   ;BOOT HIGH BIT
          CMP     #25
          BEQ     HASBACK
          LDA     #25                    ;DIDN'T HAVE IT, SO START IT
          JSR     TUNIN                  ;TEMPORARILY OUT OF ACTION
HASBACK   LDA     TYPE,Y
          AND     #$7F
          CMP     #1                     ;SEE IF BLUE SHIP
          BNE     NOTBLUE
          JSR     ATTKBL                 ;IS BLUE, MAKE BLUE ATTACK
          JMP     YATT1
NOTBLUE   CMP     #2                     ;SEE IF RED SHIP
          BNE     NOTRED
          LDA     TYPE,Y                 ;IS RED, MAKE RED ATTACK
          ORA     #$80
          STA     TYPE,Y
;         INC     NUMFLY
          INC     AIRBORNE
          LDA     #L(PEELOFF)
          STA     ML,Y
          LDA     #H(PEELOFF)
          STA     MH,Y
          CPY     #40                    ;SEE IF CAPTD HERO
          BNE     GOMIN1
          LDA     CHTAB40
          BPL     GOMIN2
GOMIN1    LDA     CHTAB,Y
GOMIN2    CMP     #5
          BMI     GOMINUS
          LDA     #$84
          JMP     YATT
GOMINUS   LDA     #$C4
          JMP     YATT
NOTRED    JSR     ATTKBO                 ;MUST BE BOSS, MAKE BOSS ATTACK
          JMP     YATT1
YATT      STA     MODE,Y                 ;CHANGE TO ATTACK MODE
YATT1     LDA     #8                     ;BIRD SWOOP SOUND
          JSR     TUNIN
NOATT     RTS

GOTONE1   STY     ATTEMPT
          LDA     TYPE,Y
          AND     #$7F
          CMP     #1                     ;SEE IF BLUE SHIP
          BNE     NOTBLUE1
          LDA     #L(BATBL1B)            ;MAKE MTBLPTR AND MODE TO BE A
          STA     ML,Y                   ;CONTINUED BLUE ATTACK
          LDA     #H(BATBL1B)
          STA     MH,Y
          LDA     XCORD,Y                ;SEE IF ON LEFT OR RIGHT SIDE OF
          CMP     #80                    ;SCREEN AND THUS WHICH WAY TO ATTACK
          BCS     NEGATK1
          LDA     #$83
          JMP     CHMODE1
NEGATK1   LDA     #$C3
CHMODE1   STA     MODE,Y
;         INC     AIRBORNE               ;DONT INC IF CONTINUED ATTACK
;         INC     NUMFLY
          RTS
NOTBLUE1  CMP     #2                     ;SEE IF RED SHIP
          BNE     NOTRED1
          LDA     TYPE,Y                 ;IS RED, MAKE CONTINUED RED ATTACK
          AND     #$7F
          STA     TYPE,Y
;         INC     AIRBORNE               ;DONT INC IF CONTINUED ATTACK
;         INC     NUMFLY
          LDA     #L(REDTAB)
          STA     ML,Y
          LDA     #H(REDTAB)
          STA     MH,Y
          CPY     #40                    ;SEE IF CAPTD HERO
          BNE     GOMIN3
          LDA     CHTAB40
          BPL     GOMIN4
GOMIN3    LDA     CHTAB,Y
GOMIN4    CMP     #5
          BPL     GOMINUS1
          LDA     #$84
          JMP     XATT
GOMINUS1  LDA     #$C4
XATT      STA     MODE,Y                 ;CHANGE TO ATTACK MODE
          RTS
NOTRED1   JSR     ATTKBO1                ;MUST BE BOSS, MAKE CONT. BOSS ATTACK
          RTS


INITCOLS
          LDA     #1
          STA     TOGGLEM
          STA     SHIPCNT
          STA     BORNCNT
          STA     COL0
          STA     COL1
          STA     COL2
          STA     COL3
          STA     COL4
          STA     EXPANC
          LDA     #25
          STA     COUNT
          LDA     #8
          STA     DECCNT
          LDY     #0
          LDA     #28
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          INY
          LDA     #38
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          INY
          LDA     #48
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          INY
          LDA     #58
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          INY
          LDA     #68
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          INY
          LDA     #77
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          INY
          LDA     #87
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          INY
          LDA     #97
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          INY
          LDA     #107
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          INY
          LDA     #117
          STA     COLPOS,Y
          STA     NEWCOLS,Y
          RTS
;
;THIS SUBROUTINE IS CALLED TO START A NEW RACK
;
NEWRACK   LDA     TYPE+40                ;SEE IF CAPTD HERO ACTIVE
          BEQ     NWRCK1
          RTS
NWRCK1    DEC     RACKREG
          BNE     NEWRACK1
          LDA     #0
          STA     WAVESCR                CLEAR CHAL WAVE SCORE COUNTER
          STA     SHPERWAV               ;RESET NUMBER OF SHIPS PER WAVE
          STA     EXPANR
          STA     TOGGLEM0
          STA     ARRIVED
          STA     AIRBORNE               ;WILL BE 0 ANYWAY EXCEPT FOR CH. STG
          STA     METAREG                ;RESET ABILITY TO METAMORPHOSIZE
          STA     SCORPCNT               ;INDICATES 3 SCORPIONS HIT
          STA     CAPQUAN                RESET BOSS CAPTURING REGISTER
          JSR     INITCOLS
          LDA     #25                    ;KILL BACKGROUND MUSIC
          JSR     SCRAPONE
          LDA     #2                     ;SOUND FOR NEW RACK
          JSR     TUNIN
          LDA     #$80                   ;RESET RACKREG
          STA     RACKREG
          LDA     #70                    ;INIT ANTI-STALLING DEVICE
          STA     BULLSHT
          INC     RACK
          LDA     GASTONHK
          SED
          CLC
          ADC     #1
          STA     GASTONHK
          CLD
          BCC     RACKOK
          LDA     #1
          STA     RACK
          STA     GASTONHK               ;RACK WRAPS AROUND AT 100
;MUST RESET VARIOUS STARTUP REGISTERS HERE
          LDA     #0
          STA     STRSPEED               ;SLOW DOWN STARS AGAIN
          STA     CHALNUM
          STA     WAVEREG
          STA     CHALINDX               ;RESET ALL BIRTH PARAMETERS
RACKOK
          RTS
NEWRACK1  LDA     RACKREG
          CMP     #$60                    ;SEE IF HALF WAY DONE WITH WAIT
          BNE     ENDRACK
          LDA     RACK
          CLC
          ADC     #2
          SEC
NEWRACK2  SBC     #4
          BEQ     CHALRACK
          BCS     NEWRACK2
          BCC     CLRCHSTG
CHALRACK  LDA     #$4F
          STA     CHLNGREG
          STA     CHALSTG
          LDA     #15
          JSR     TUNIN                  ;SET UP CHALLENGING STAGE TUNE
          LDA     #16
          JSR     TUNIN
ENDRACK   RTS
CLRCHSTG  LDA     CHALSTG
          BEQ     ENDRACK
          LDA     #0
          STA     CHALSTG
          LDA     #1                     SHORTEN DELAY FOR STATS MUSIC
          STA     RACKREG
          LDA     #$FF
          STA     SCRTIME                ;TIME TO DISPLAY SCORE
          INC     CHALNUM                ;NEXT CHALLENGING STAGE WILL BE HIGHER
          LDA     CHALNUM
          CMP     #8
          BMI     ENDRACK                ;LEAVE ALONE
          LDA     #0                     ;ONLY 8 DIFFERENT CHALLENGING STAGES
          STA     CHALNUM
          RTS


;
;THIS SUBROUTINE INITIATES A SHIP POINTED TO BY Y REG ON BLUE ATTACK
;
ATTKBL
          LDA     METAREG                ;INCREMENT METAMORPHOSIS REGISTER
          BMI     META2                  ;NEGATIVE INDICATES DISABLED
          CLC
          ADC     #1
          STA     METAREG
          CMP     #14                    ;SEE IF ALREADY HAVE MADE 20 ATTACKS
          BMI     META2
          LDA     #$FF
          STA     METAREG                ;DISABLE FURTHER METAS
          LDA     RACK
          CMP     #4                     ;NO METAMORF ON LOWEST RACKS
          BCC     META2
;LOOK FOR AVAILABLE BLUE BUG
          LDX     #0
META1     LDA     TYPE,X
          CMP     #1
          BEQ     META14
META15    INX
          CPX     #15
          BMI     META1
          BPL     META2                  ;NO SHIPS AVAILABLE, ABORT ATTEMPT
META14    LDA     MODE,X                 ;CHECK THAT IT'S IN EXPANSION MODE
          CMP     #1
          BEQ     META3
          CMP     #0
          BNE     META15
;STORE NEW SCORPION TYPES
META3     LDA     #40
          STA     METACNT                ;COUNTER BETWEEN NEW SCORPION BIRTHS
          LDA     #13
          STA     TYPE,X                 ;13 IS SCORPION TYPE AND TUNE NUMBER
          JSR     TUNIN
          LDA     #0
          STA     MOMENTUM,X             BIRTH MUST BE SLOW
          LDA     XCORD,X
          STA     XCORD+42
          STA     XCORD+43
          LDA     YCORD,X
          STA     YCORD+42
          STA     YCORD+43
          TXA
          TAY                            SWITCH TO THE NEW SHIP NUMBER
META2     LDA     #L(BATBL1)             ;MAKE
          STA     ML,Y                   ;MTBLPTR AND MODE TO BE BLUE ATTACK
          LDA     #H(BATBL1)
          STA     MH,Y
          LDA     XCORD,Y                ;SEE IF ON LEFT OR RIGHT SIDE OF
          CMP     #80                    ;SCREEN AND THUS WHICH WAY TO ATTACK
          BCS     NEGATK
          LDA     #$83
          BNE     CHMODE
NEGATK    LDA     #$C3
CHMODE    STA     MODE,Y
          INC     AIRBORNE               ;WAS IN SHIFTING OR EXPANSION MODE
;         INC     NUMFLY
          RTS


;
;THIS SUBROUTINE MOVES A BLUE SHIP POINTED TO BY Y REG ONE STEP BY CALLING
;A SUBROUTINE THAT USES A MOTION TABLE
;
;IT HAS NO PERMANENT LOCAL VARIBLES
;ITS TEMPORARY VARIBLES ARE:
;TEMP1    DS      2
;
;CONSTANTS ARE
;
;Y REGISTER IS SAVED, ALL OTHER
;REGISTERS ARE DESTROYED
;
BLUATK    JSR     MSHBTBL                ;CALL SUBROUTINE TO MOVE SHIP BY TABLE
          TXA                            ;SEE IF END OF TABLE
          BNE     NOEND
          RTS
NOEND     LDA     MODE,Y                 ;IS END
          AND     #$20                   ;SO FIRST SEE IF JUST FINISHED FIRST
          BNE     BAPH2                  ;PHASE
          LDA     XCORD,Y                ;JUST FINISHED FIRST PHASE, SEE IF
          CMP     XCORD+63               ;HERO TO LEFT OR RIGHT
          BCC     NNEGATT
          LDA     MODE,Y                 ;HERO TO THE LEFT, SO DO NEGATE
          ORA     #$60                   ;AND CHANGE MODE TO START PHASE 2
          STA     MODE,Y
          JMP     PHA1
NNEGATT   LDA     MODE,Y                 ;HERO TO THE RIGHT, SO DONT NEGATE
          AND     #$BF
          ORA     #$20                   ;AND CHANGE MODE TO START PHASE 2
          STA     MODE,Y
PHA1      LDA     #H(BATBL1A)            ;NOW CHANGE MOTION TABLE POINTER
          STA     MH,Y                   ;TO START PHASE 2
          LDA     #L(BATBL1A)
          STA     ML,Y
          RTS
BAPH2     LDX     #0
          LDA     (TEMP1,X)              ;SEE IF JUST FINISHED PHASE 2 OR 3
          AND     #$FC
          BNE     BAPH3
          CPY     #40                    ;JUST FINISHED PHASE 2, NOW SEE IF
          BMI     META5                  ;ENEMY STARTED ON LEFT OR RIGHT
          LDA     TYPE,Y                 ;SEE IF SCORPION
          CMP     #13
          BNE     STRAIGHT               ;IF NOT, MAKE GO STRAIGHT
META5     LDA     TYPE,Y                 ;GET SHIP TYPE
          CMP     #13                    ;SEE IF SCORPION
          BNE     META12                 ;HANDLE NORMALLY
          CPY     #40                    ;SEE IF EXTRA SCORPS
          BMI     CURVE                  ;IF ORIGINAL SHIP, GO HOME
          BPL     STRAIGHT               ;IF NOT, GO STRAIGHT DOWN
META12    LDA     CHTAB,Y                ;FIRST SEE IF NOT FORM SHIP, IF SO
          CMP     #5                     ;JUST GO STRAIGHT DOWN
          BPL     RIGHT
          LDA     MODE,Y                 ;STARTED ON LEFT SIDE, NOW SEE IF
          AND     #$40                   ;IS IN NEGATE MODE SO SHOULD DO A
          BEQ     CIRCLE                 ;CURVE, OR NOT NEGATE (CIRCLE)
CURVE     LDA     MOMENTUM,Y             ;SEE IF IN FASTER MODE
          BMI     CIRCLE                 ;DO A CIRCLE IF SO
          LDA     #H(BATBL2)             ;NEGATED SO DO A CURVE (LEFT SIDE)
          STA     MH,Y
          LDA     #L(BATBL2)
          STA     ML,Y
          RTS
CIRCLE    LDA     #H(BATBL3)             ;NOT NEGATED SO DO A CIRCLE (LEFT SIDE)
          STA     MH,Y
          LDA     #L(BATBL3)
          STA     ML,Y
          RTS
STRAIGHT  LDA     #H(BATBL3A)            ;NOT FORM SHIP, AND JUST FINISHED 2ND
          STA     MH,Y                   ;PHASE, SO CAUSE TO GO STRAIGHT DOWN
          LDA     #L(BATBL3A)
          STA     ML,Y
          RTS
RIGHT     LDA     MODE,Y                 ;STARTED ON RIGHT SIDE, SO IF NOT
          AND     #$40                   ;NEGATED DO A CURVE
          BEQ     CURVE
          JMP     CIRCLE
BAPH3     CPY     #40                    ;JUST FINISHED PHASE 3, NOW SEE IF
          BMI     REGUL                  ;NOT FORM SHIP
          LDA     #0                     ;NOT FORM SHIP, SO GET RID OF
          STA     TYPE,Y
          DEC     AIRBORNE
          RTS
REGUL     CMP     #$04                   ;REAL BLUE SHIP, SO SEE IF
          BEQ     UP                     ;SHOULD 'GOHOME' OR 'REAPPEAR'
          LDA     #$82                   ;DID A CIRCLE SO SET MODE TO REAPPEAR
          STA     MODE,Y
          RTS
UP        LDA     #$81                   ;DID A CURVE SO SET MODE TO GOHOME
          STA     MODE,Y
          LDA     TYPE,Y
          AND     #$7F
          STA     TYPE,Y                 ;BOOT THE NEGATIVE SIGN
          RTS
END4      DB      $00                    NEXT CODE SECTION GOES HERE

          ORG     $CC00

;
;THIS SUBROUTINE INITIALIZES A SHIP TO CAUSE A BOSS ATTACK
;THE SHIP IS POINTED TO BY THE Y REGISTER
;THE Y REG IS SAVED
;
ATTKBO    LDA     CAPQUAN                ;SEE IF CAN DO A CAPTURE
          BEQ     DONTCAP
          LDA     HEROREAP               ;SEE IF HERO IS SET TO REAPPEAR
          BNE     DONTCAP
          LDA     TYPE+40                ;SEE IF HERO ALREADY CAPTURED
          BNE     DONTCAP
          LDA     TYPE+62
          BNE     DONTCAP

          LDX     #6                     ;POINT X TO FIRST BOSS
          JSR     TESTBOSS
          LDX     #17
          JSR     TESTBOSS
          LDX     #26
          JSR     TESTBOSS
          LDX     #35
          JSR     TESTBOSS
          JMP     INITCAPX

TESTBOSS  LDA     TYPE,X                 ;SEE IF BOSS ALIVE
          BNE     TESTBOS1
          RTS
TESTBOS1  LDA     MODE,X
          BPL     TESTBOS2
          RTS
TESTBOS2  AND     #$F
          CMP     #2
          BPL     TESTBOS3
          RTS
TESTBOS3  CMP     #5
          BPL     TESTBOS4
          PLA
          PLA                            ;BOOT THE RTS
          JMP     DONTCAP
TESTBOS4  RTS


DONTCAP
          LDA     #$FF
          STA     CAPQUAN                ;RESET ABILITY TO CAPTURE
          TAX
          STA     BOZO8


ESCLOOP   LDX     BOZO8
          INX
          CPX     #4
          BNE     BIGBIRD
          RTS
BIGBIRD
          LDA     ESCARG0,X
          STA     BOZO0

          LDA     ESCARG1,X
          STA     BOZO1

          LDA     ESCARG2,X
          STA     BOZO2

          LDA     ESCARG3,X
          STA     BOZO3

          LDA     ESCARG4,X
          STA     BOZO4

          LDA     ESCARG5,X
          STA     BOZO5

          LDA     ESCARG6,X
          STA     BOZO6

          LDA     ESCARG7,X
          STA     BOZO7

          STX     BOZO8


          CPY     BOZO0                  ;*0 SEE IF FIRST BOSS TO GET ESCORTS
          BNE     ESCLOOP
          LDX     #40                    ;SEE IF OWNS CAPTURED HERO SHIP
          LDA     TYPE,X
          BEQ     NOESC1
          LDA     CHTAB40
          CMP     BOZO1                  ; *1
          BNE     NOESC1
          LDA     MODE,X
          BEQ     YES1
          RTS

YES1
          JSR     STRTESCB               ;YES, OWNS CAPTURED HERO SHIP
          LDA     #$FF
          STA     COUNTXY,X
NOESC1    LDX     BOZO2                  ;*2 CAUSE BOSS TO ATTACK
          JSR     STRTESCB
          LDA     #$0F
          STA     COUNTXY,X
          INC     AIRBORNE
          LDX     BOZO3                  ;*3 SEE IF FIRST ESCORT AROUND
          LDA     TYPE,X
          BEQ     NOESC1A
          LDA     MODE,X
          BNE     NOESC1A
          JSR     STRTESCB
          LDA     BOZO4                  ;*4 SAY IS LEFT ESCORT GOING TO LEFT
          STA     COUNTXY,X
          INC     AIRBORNE
          LDA     #$10                   ;SAY HAS ONE MORE ESCORT
          CLC
          ADC     COUNTXY,Y
          STA     COUNTXY,Y
NOESC1A   LDX     BOZO5                  ;*5 SEE IF SECOND ESCORT AROUND
          LDA     TYPE,X
          BEQ     NOESC1B
          LDA     MODE,X
          BNE     NOESC1B
          JSR     STRTESCB
          LDA     BOZO6                  ;*6 SAY IS RIGHT ESCORT GOING TO LEFT
          STA     COUNTXY,X
          INC     AIRBORNE
          LDA     #$10                   ;SAY HAS ONE MORE ESCORT
          CLC
          ADC     COUNTXY,Y
          STA     COUNTXY,Y
          JMP     ESCLOOP

STRTESCB
          BIT     BOZO7
          BPL     SNUFFY
          JSR     STRTESCN
          RTS
SNUFFY    JSR     STRTESCP
NOESC1B   RTS


ESCARG0   DC      6,26,35,17
ESCARG1   DC      3,4,5,6
ESCARG2   DC      6,26,35,17
ESCARG3   DC      20,29,38,39
ESCARG4   DC      0,0,2,2
ESCARG5   DC      38,39,30,21
ESCARG6   DC      1,1,3,3
ESCARG7   DC      0,0,$80,$80             ; P OR N

INITCAPX  LDA     #0
          STA     CAPQUAN                ;DISABLE FURTHER CAPTURES
          LDA     #L(PEELOFF)
          STA     ML,Y
          LDA     #H(PEELOFF)
          STA     MH,Y
          LDA     TYPE,Y
          ORA     #$80
          STA     TYPE,Y
          LDA     #2
          STA     MODE,Y
          INC     AIRBORNE
          RTS


;
;THIS SUBROUTINE INITIATES A SHIP POINTED TO BY THE X REG TO A POSITIVE BOSS
;ATTACK
;
STRTESCP  LDA     #L(BOTBL1)             ;INIT TABLE POINTERS TO PEELOFF
          STA     ML,X
          LDA     #H(BOTBL1)
          STA     MH,X
          LDA     #$85
          STA     MODE,X
          RTS


;
;THIS SUBROUTINE INITIATES A SHIP POINTED TO BY THE X REG TO A NEGATIVE BOSS
;ATTACK
;
STRTESCN  LDA     #L(BOTBL1)             ;INIT TABLE POINTERS TO PEELOFF
          STA     ML,X
          LDA     #H(BOTBL1)
          STA     MH,X
          LDA     #$C5
          STA     MODE,X
          RTS


;
;THIS SUBROUTINE INITIALIZES A SHIP TO CAUSE A CONTINUED BOSS ATTACK
;THE SHIP IS POINTED TO BY THE Y REGISTER
;THE Y REG IS SAVED
;
ATTKBO1
DONTCAP1  LDX     #40                    ;SEE IF OWNS CAPTURED HERO
          LDA     TYPE,X
          BEQ     FINIBOAT
          CPY     #40
          BNE     DONTCCC
          LDA     CHTAB40
          BPL     DONTCCC1
DONTCCC   LDA     CHTAB,Y
DONTCCC1  CMP     CHTAB40
          BNE     FINIBOAT
          LDA     MODE,X                 ;SEE IF HERO READY
          CMP     #5
          BEQ     YEHP
          RTS
YEHP      JSR     COTBOATK
FINIBOAT  TYA                            ;CAUSE BOSS TO CONTINUE REGULAR BOSS
          TAX                            ;ATTACK
          JSR     COTBOATK
          RTS

;
;THIS SUBROUTINE INITIATES A CONTINUED REGULAR BOSS ATTACK
;THE SHIP INITIATED IS IN THE X REG
;
COTBOATK
          CPX     #40
          BNE     COTB1
          LDA     CHTAB40
          BPL     COTB2
COTB1     LDA     CHTAB,X                ;SEE IF STARTED ON LEFT
COTB2     CMP     #5                     ;OR RIGHT
          BPL     RIGATK2
          LDA     #72                    ;LEFT SIDE, SO GO TO LEFT CORNER
          SEC
          SBC     XCORD,X
          JMP     YGO2
RIGATK2   LDA     #88                    ;RIGHT SIDE, SO GO TO RIGHT CORNER
          SEC
          SBC     XCORD,X
YGO2      STA     ML,X
          LDA     #79
          STA     MH,X
          LDA     #$86
          STA     MODE,X
          LDA     #$0F
          STA     COUNTXY,X
          RTS


;
;
;THIS SUBROUTINE MOVES A BOSS SHIP POINTED TO BY Y REG ONE STEP BY CALLING
;A SUBROUTINE THAT USES A MOTION TABLE.  IT IS PHASE ONE OF BOSS ATTACK.
;
;IT HAS NO PERMANENT LOCAL VARIBLES
;ITS TEMPORARY VARIBLES ARE:
;TEMP1    DS      2                      ;0 PAGE
;
;CONSTANTS ARE
;
;Y REGISTER IS SAVED, ALL OTHER
;REGISTERS ARE DESTROYED
;
BOSSATK1  JSR     MSHBTBL                ;CALL SUBROUTINE TO MOVE SHIP BY TABLE
          TXA                            ;SEE IF END OF TABLE
          BNE     ISEND
          RTS
ISEND     LDA     COUNTXY,Y              ;SEE IF IS BOSS SHIP
          CMP     #$0F
          BCC     ESCORT1
          CPY     #40
          BNE     RIG1
          LDA     CHTAB40
          BPL     RIG2
RIG1      LDA     CHTAB,Y                ;BOSS SHIP, SEE IF STARTED ON LEFT
RIG2      CMP     #5                     ;OR RIGHT
          BPL     RIGATK
          LDA     #72                    ;LEFT SIDE, SO GO TO LEFT CORNER
          JMP     YGO
RIGATK    LDA     #88                    ;RIGHT SIDE, SO GO TO RIGHT CORNER
YGO       SEC
          SBC     XCORD,Y
          STA     ML,Y
          LDA     #79
          STA     MH,Y
          LDA     #$86
          STA     MODE,Y
          RTS
ESCORT1   CMP     #0                     ;SEE IF LEFT ESCORT GOING TO LEFT
          BNE     NOTLL
          LDA     #65
          JMP     YGO
NOTLL     CMP     #1                     ;SEE IF RIGHT ESCORT GOING TO LEFT
          BNE     NOTRL
          LDA     #79
          JMP     YGO
NOTRL     CMP     #2                     ;SEE IF LEFT ESCORT GOING TO RIGHT
          BNE     NOTLR
          LDA     #81
          JMP     YGO
NOTLR     LDA     #95                    ;IS RIGHT ESCORT GOING RIGHT
          JMP     YGO


;
;THIS SUBROUTINE OPERATES PHASE TWO OF BOSS ATTACK. IT BRINGS THE SHIP TO THE
;LOOP
;THE SHIP IS POINTED TO BY THE Y REGISTER
;THE Y REGISTER IS SAVED
;
BOSSATK2  JSR     MOVBOS                 ;CALL SUBROUTINE TO MOVE SHIP BY STEPS
          LDA     MH,Y                   ;SEE IF FINISHED PHASE 2
          BEQ     CHAGAT
          RTS
CHAGAT    LDA     #L(BOTBL2)             ;FINISHED PHASE 2, INITIALIZE FOR LOOP
          STA     ML,Y
          LDA     #H(BOTBL2)
          STA     MH,Y
          LDA     COUNTXY,Y              ;SEE IF IS BOSS SHIP
          CMP     #$0F
          BCC     ESCORT2
          CPY     #40
          BNE     POSS1
          LDA     CHTAB40
          BPL     POSS2
POSS1     LDA     CHTAB,Y                ;BOSS SHIP, SEE IF STARTED ON LEFT
POSS2     CMP     #5                     ;OR RIGHT
          BPL     NEGATTK1
POSATTK1  LDA     #$87
          JMP     MAKEATK1
NEGATTK1  LDA     #$C7
MAKEATK1  STA     MODE,Y
          RTS
ESCORT2   CMP     #2                     ;ESCORTS, SEE IF GOING LEFT
          BPL     NEGATTK1
          JMP     POSATTK1


;
;
;THIS SUBROUTINE MOVES A BOSS SHIP POINTED TO BY Y REG ONE STEP BY CALLING
;A SUBROUTINE THAT USES A MOTION TABLE.  IT IS PHASE THREE OF BOSS ATTACK.
;IT IS THE LOOP.
;IT HAS NO PERMANENT LOCAL VARIBLES
;ITS TEMPORARY VARIBLES ARE:
;TEMP1    DS      2                      ;0 PAGE
;
;CONSTANTS ARE
;
;Y REGISTER IS SAVED, ALL OTHER
;REGISTERS ARE DESTROYED
;
BOSSATK3  JSR     MSHBTBL                ;CALL SUBROUTINE TO MOVE SHIP BY TABLE
          TXA                            ;SEE IF END OF TABLE
          BNE     ISEND1
          RTS
ISEND1    LDA     COUNTXY,Y              ;SEE IF IS BOSS SHIP
          CMP     #$0F
          BCC     ESCORT3
          CPY     #40
          BNE     POOT1
          LDA     CHTAB40
          BPL     POOT2
POOT1     LDA     CHTAB,Y                ;BOSS SHIP, SEE IF STARTED ON LEFT
POOT2     CMP     #5                     ;OR RIGHT
          BPL     RIGATK1
          LDA     #10                    ;LEFT SIDE, SO GO TO LEFT CORNER
          JMP     YGO1
RIGATK1   LDA     #150                   ;RIGHT SIDE, SO GO TO RIGHT CORNER
YGO1      SEC
          SBC     XCORD,Y
          STA     ML,Y
          LDA     #100
          STA     MH,Y
          LDA     #$88
          STA     MODE,Y
          RTS
ESCORT3   CMP     #0                     ;SEE IF LEFT ESCORT GOING TO LEFT
          BNE     NOTLL1
          LDA     #3
          JMP     YGO1
NOTLL1    CMP     #1                     ;SEE IF RIGHT ESCORT GOING TO LEFT
          BNE     NOTRL1
          LDA     #17
          JMP     YGO1
NOTRL1    CMP     #2                     ;SEE IF LEFT ESCORT GOING TO RIGHT
          BNE     NOTLR1
          LDA     #143
          JMP     YGO1
NOTLR1    LDA     #157                   ;IS RIGHT ESCORT GOING RIGHT
          JMP     YGO1


;
;THIS SUBROUTINE OPERATES PHASE FOUR OF BOSS ATTACK. IT BRINGS THE SHIP TO THE
;END
;THE SHIP IS POINTED TO BY THE Y REGISTER
;THE Y REGISTER IS SAVED
;
BOSSATK4  JSR     MOVBOS                 ;CALL SUBROUTINE TO MOVE SHIP BY STEPS
          LDA     MH,Y                   ;SEE IF FINISHED PHASE 4
          BEQ     CHAGAT1
          RTS
CHAGAT1   LDA     #$82                   ;FINISHED PHASE 4, RETURN SHIP TO TOP
          STA     MODE,Y
          RTS


;
;THIS SUBROUTINE IS FOR BOSS GALAGAS, IT MOVES THE SHIP BY STEPS
;
MOVBOS
          LDA     #$FF
          STA     BOZO0                  ;USED AS A TEMP COUNTER
MOVBOS2   TYA                            ;TRANSFER Y REG TO X REG
          TAX
          LDA     ML,X                   ;GET XTOGO
          BEQ     MBOSZER1               ;SEE IF XTOGO IS ZERO
          BPL     MBOSPOS                ;SEE IF XTOGO IS POSITIVE
          DEC     XCORD,X                ;XTOGO IS NEGATIVE
          INC     ML,X
          LDA     #5                     ;SET ANGLE
          JMP     MBOSZER
MBOSPOS   INC     XCORD,X                ;XTOGO IS POSITIVE
          DEC     ML,X
          LDA     #3                     ;SET ANGLE
          JMP     MBOSZER
MBOSZER1  LDA     #4                     ;SET ANGLE
MBOSZER   STA     ANGLE,X                ;STORE ANGLE
          INC     YCORD,X                ;MAKE SHIP GO DOWN ONE STEP
          DEC     MH,X
          BEQ     ENDMBOS
          LDA     MOMENTUM,Y             ;SEE IF TWICE AS FAST
          BPL     ENDMBOS
          INC     BOZO0
          BEQ     MOVBOS2
ENDMBOS   RTS
