;*******************************************************************************
*GLOADER.S
          ORG     $B000                  ;ORG AFTER GRAPHICS

ZERO      EQU     0
HUNDRED   EQU     $100

STARTUP   SEI                            ; STARTUP CODE
          CLD
          LDX     #$FF
          TXS

          LDA     #$17
          STA     $01                    ;LOCK INTO MARIA MODE

          STX     CTRLWT                 ;TURN OFF DMA


          LDA     #0
          STA     $38                    STORE ZERO INTO OFFSET
;         LDX     #$FF                   ;ZERO OUT ZERO PAGE
ZEROLOP1  STA     ZERO,X
          DEX
          CPX     #$3F
          BNE     ZEROLOP1

;         LDA     #0                   ; ZERO OUT ZERO PAGE
          TAY                            SAVE A ZERO HERE
          STA     1                      ;DECONFUSE 6532
          STA     INPT4
          STA     INPT5
          STA     CHARBASE
          STA     DUMYHDR
          STA     DUMYHDR+4
          STA     DUMYHDR+5
          STA     DUMYHDR+6
          STA     ZEROHDR
          STA     ZEROHDR+1
          LDA     #$40
          STA     DUMYHDR+1
          LDA     #$A0
          STA     DUMYHDR+2
          LDA     #$1F
          STA     DUMYHDR+3

; SET UP THE TWO DISPLAY LIST LISTS
;         LDY     #0
          LDA     #$48
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #H(DUMYHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #L(DUMYHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #$4F
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #H(ZEROHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #L(ZEROHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDX     #0
INITDLST  LDA     #$4B
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     LISTTBH1,X
          STA     DLSTLST1,Y
          LDA     LISTTBH2,X
          STA     DLSTLST2,Y
          INY
          LDA     LISTTABL,X
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          INX
          CPX     #16
          BMI     INITDLST
;NOW FINISH LAST TWO ZONES (OFF THE SCREEN)
          LDX     #3
ZHDRLOOP  LDA     #$4F
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #H(ZEROHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #L(ZEROHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          DEX
          BPL     ZHDRLOOP
          LDA     #$49
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #H(ZEROHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #L(ZEROHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #$CF
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #H(ZEROHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
          INY
          LDA     #L(ZEROHDR)
          STA     DLSTLST1,Y
          STA     DLSTLST2,Y
*INITIALIZE COLOR PALETTES
          LDA     #0
          STA     INTIM                  ;TEMPORARILY OUT OF ACTION
          STA     P0C0                   ; MAKE THE SCREEN BLACK
          STA     SELECT                 ;CLEAR SELECT MODE FLAG
          STA     RSTRTREG               ;CLEAR RESTART MODE FLAG
          STA     LEVELSEL
          STA     TWOPLAYR
          STA     FARREN
          JSR     CLRSCORE               ;CLEAR ALL SCORES
          LDX     #8
          LDY     #30
PLOOP     LDA     PTABL,Y
          STA     P0C1,Y
          DEY
          LDA     PTABL,Y
          STA     P0C1,Y
          DEY
          LDA     PTABL,Y
          STA     P0C1,Y
          DEY
          DEY
          DEX
          BNE     PLOOP
WGHTLOOP  LDA     CTRLRD                ;WAIT FOR VBLANK OFF
          BMI     WGHTLOOP               ;LOOP UNTIL VBLANK OFF
WGHTLOP2  LDA     CTRLRD                 ;LOOP UNTIL VBLANK ON
          BPL     WGHTLOP2
          LDA     CTRLRD
          BPL     WGHTLOP2
          JSR     CLEARDL1               CLEAR OUT DISPLAY LIST FIRST
          LDA     #L(DLSTLST1)
          STA     DPPL
          LDA     #H(DLSTLST1)
          STA     DPPH
          LDA     #$40
          STA     CTRLWT
;CONTINUE WITH REMAINDER OF INITIALIZATION
RESTART
          JSR     SCRAPALL
          LDA     #0
          LDX     #$FF                   ;ZERO OUT ZERO PAGE
ZEROLOOP  STA     ZERO,X
          DEX
          CPX     #$3F
          BNE     ZEROLOOP
          JSR     INITCOLS
          LDA     #76
          STA     HEROX
          LDA     #20
          STA     ANIMATE
          STA     SELTIMER               ;SELECT TIMER
          JMP     BEGIN

;HANDLER  IS CALLED BY THE DLI AT THE END OF THE VISIBLE SCREEN
HANDLER
          ; NO PERMINANT LOCAL VARIABLES
          ;TEMP VARIABLES
          ; LISTSIZ   DS 16
          ; ELISTPTR  DS 2     ZERO PAGE
          ; LTYPE     DS 1
          ; LY        DS 1
          ; LA        DS 1
          ; HEADER0   DS 1
          ; HEADER1   DS 1
          ; HEADER2   DS 1
          ; HEADER3   DS 1
          STA     SAVEB                  ;THIS IS FOR LOOPING INTERRUPTS

          LDA     INHSC                  ;SEE IF IN HIGH SCORE CART
          BEQ     NOTHSC
          CMP     #1                     ;SEE IF FIRST DLI ON SCREEN
          BNE     SCNDDLI
          INC     INHSC
          LDA     #0
          STA     FLAP                   ;PREVENT FLAPPING WHILE IN HSC
          LDA     #$40
          STA     CTRLWT                 ;NEED $40 RATHER THAN THE $4B OF HSC
          BNE     YESHSC
SCNDDLI   LDA     #$4B
          STA     CTRLWT
          DEC     INHSC
          INC     BOOTLDR
          CLD                            ;CLEAR DECIMAL MODE, JUST IN CASE
          LDA     #$FF
          STA     DLSPTR                 ;USE FIRST DISPLAY LIST FOR GRAPHICS
          LDA     SAVEB
          STA     SAVEA
          STX     SAVEX
          STY     SAVEY
          JMP     DOHNDLER               ;RUN THE HSC LOADER NOW

NOTHSC    LDA     PAUSE                  ;SEE IF PAUSE
          BPL     NOPAUSE
          INC     FRAME                  ;INC FRAME COUNTER
YESHSC    LDA     SAVEB
          RTI

NOPAUSE   LDA     BOOTLDR                ;SEE IF SHOULD BOOT LDR
          BEQ     NBOOTLDR
          LDA     SAVEB
          RTI

NBOOTLDR
          LDA     SAVEB
          STA     SAVEA                  ;THIS IS FOR LOOPING INTERRUPTS
          STX     SAVEX
          STY     SAVEY
          CLD                            ;CLEAR DECIMAL MODE
          JSR     TUNER

;THIS SECTION FIGURES OUT THE STAR INC SPEED
          LDA     RACK
          CMP     #10
          BCC     SLOWSTAR
          CMP     #18
          BCS     FASTAR
          LDA     #1                     ;SPEED IS 1 UNCONDITIONALLY
          STA     STRSPEED
          BNE     SETBOOT
SLOWSTAR  LDA     STRSPEED               ;DEC STRSPEED UNTIL ZERO, THEN INC
          BEQ     INCSPD
          LDA     #0
          STA     STRSPEED
          BEQ     SETBOOT
INCSPD    LDA     #1
          STA     STRSPEED
          BNE     SETBOOT
FASTAR
          LDA     STRSPEED
          CMP     #2
          BPL     DECFSPD                ;IF 2 OR GREATER, DEC STRSPEED
          LDA     #2
          STA     STRSPEED
          BNE     SETBOOT
DECFSPD   LDA     #1
          STA     STRSPEED
SETBOOT   INC     BOOTLDR                ;INC FLAG FOR LOADER
          LDA     FRAME
          BMI     DOHNDLER
;THIS CODE UPDATES THE STAR POINTERS ONLY
          JSR     MOVSTARS
          JMP     UPSHIP                 ;JUST UPDATE SHIP IF INSUF. TIME


DOHNDLER
          LDA     #16                    ;SAVE SPACE FOR THE STARS
          LDY     #15
LSTSIZLP  STA     LISTSIZ,Y
          DEY
          BPL     LSTSIZLP

          LDA     #0                     ;ZEROS OUT SECOND LIST
          LDY     #8
LIST2LP   STA     LISTSIZ2,Y
          DEY
          BPL     LIST2LP

          LDA     INHSC
          BEQ     STARLDR
          JMP     LSTSZOUT               ;IF IN HSC, DONT DO STARS

STARLDR   LDA     #16
          STA     TEMP6                  ;GET SET FOR 16 ZONES
          LDA     #0
          STA     STARCNTR               ;INC INTO HSTAR
          LDA     #4
          STA     FOURCNT                ;FOUR STARS PER ZONE
          LDY     #0
          LDA     #L(S1L1)               ;SAME AS S2L1
          STA     LISTPTR
          BIT     DLSPTR
          BPL     SUSES2
          LDA     #H(S1L1)
          BNE     SUSES3
SUSES2    LDA     #H(S2L1)
SUSES3    STA     LISTPTR+1
          JSR     MOVSTARS
STAR1     LDA     STARPTR
          CLC
          ADC     STARCNTR
          BVC     STAR3
STAR2     AND     #$7F                   ;BOOT THE SIGN BIT
STAR3     TAX                            ;X NOW HAS OFFSET INTO HSTAR
          LDA     #L(STARGRAF)
          STA     (LISTPTR),Y
          INY
          LDA     #$DF
          STA     (LISTPTR),Y            ;PALLET 0, WIDTH 1
          INY
          LDA     #H(MARIA2)
          CLC
          ADC     THREECNT
          STA     (LISTPTR),Y
          INY
          LDA     HSTAR,X
          STA     (LISTPTR),Y
          INY
          INC     STARCNTR
          LDA     THREECNT
          CLC
          ADC     #3
          STA     THREECNT
          DEC     FOURCNT
          BNE     STAR1
          LDA     THREECNT
          SEC
          SBC     #12
          STA     THREECNT
          DEC     TEMP6                  ;SEE IF ALL ZONES DONE
          BEQ     LSTSZOUT               ;GO TO NEXT ROUTINE
          LDA     LISTPTR
          CLC
          ADC     #DLSIZE
          STA     LISTPTR
          LDA     LISTPTR+1
          ADC     #0
          STA     LISTPTR+1
          LDY     #0
          LDA     #4
          STA     FOURCNT
          JMP     STAR1
LSTSZOUT
          LDA     #71                     ;SET POINTER TO THE FIRST ENEMY DATA
          STA     TEMP6
          TAY
LREADL                                   ;READ THE ENEMY DATA
          LDA     TYPE,Y
          AND     #$7F
          BNE     DOREAD                 ;IF THE TYPE IS ZERO THE ENEMY IS
XXX       DEC     TEMP6                  ;NOTHING
          LDY     TEMP6
          BPL     LREADL
          JMP     DONENMY
DOREAD    CMP     #6
          BEQ     XXX
          STA     LTYPE
          LDA     XCORD,Y
          STA     HEADER3                ;HORIZONTAL POSITION
          LDA     YCORD,Y                ;VERTICAL POSITION
          CMP     #192
          BCS     XXX
DLFKJ     STA     LY
          LDA     ANGLE,Y                ;ANGLE
          CPY     #65
          BPL     DLFKK
          AND     #$07
          STA     LA                     ;DON'T ROUND OFF ANGLE IF Y>64
                                         ; OR FLAP
          LDA     FLAP                   ; FIND THE LOW BYTE FOR THE STAMP
          LSR     A
          BCC     NOFLAP                 ;FLAP ONLY IF THE ANGLE IS ZERO
          LDA     LA
          BNE     NOFLAP
          LDA     #8
DLFKK     STA     LA
NOFLAP    LDX     LTYPE
          LDA     PALWDT,X               ;PALLET AND WIDTH
          STA     HEADER1
          LDA     TYPTOLT,X
          CLC
          ADC     LA
          TAX
          LDA     LSTPTBL,X
          STA     HEADER0                ;LOW BYTE OF STAMP ADDRESS
SZLP      LDA     LY
          LSR     A
          LSR     A
          TAX
          LDA     DIV3,X
          TAX                            ;X NOW HAS CURRENT ZONE
          LDY     LISTSIZ,X
          CPY     #77                    ;NEED ROOM FOR ONE MORE HDR
          BCC     CONT
          LDY     LISTSIZ2,X             ;USE SECOND LIST
CONT      LDA     TEMP6
          CMP     #65
          BCC     CONT1
          LDA     LY
          SEC
          SBC     ZOFF,X
          CLC
          ADC     #$C0                   ;NEXT GRAPHICS AT $C000
          JMP     CONT2
CONT1     LDA     LY
          SEC
          SBC     ZOFF,X
          CLC
          ADC     #H(MARIA2)
CONT2     STA     HEADER2
          LDA     LISTTABL,X             ;GET POINTER TO THE ZONES LIST
          STA     LISTPTR
          LDA     LISTTBH1,X
          BIT     DLSPTR
          BMI     LUST1
          LDA     LISTTBH2,X
LUST1     STA     LISTPTR+1
          LDA     HEADER0                ;STORE THE HEADER
          STA     (LISTPTR),Y
          INY
          LDA     HEADER1
          STA     (LISTPTR),Y
          INY
          LDA     HEADER2
          STA     (LISTPTR),Y
          INY
          LDA     HEADER3
          STA     (LISTPTR),Y
          INY
          LDA     LISTSIZ,X             ;SEE IF USING LIST 2
          CMP     #77
          BCC     LUST4
          TYA
          STA     LISTSIZ2,X             ;STORE NEW LIST SIZE
          BNE     CROSSB1
LUST4     TYA
          STA     LISTSIZ,X              ;INCREMENT THE OFFSET
CROSSB1   LDA     TEMP6                  ;SEE IF WORD
          CMP     #65
          BCS     XXXX
          LDA     HEADER2                ;SEE IF GOES TO NEXT ZONE
          CMP     #$A3                   ;GRAPHICS ORG'D AT $A000
          BCC     XXXX
          CPX     #$F
          BEQ     XXXX
          SEC
          SBC     #$C
          STA     HEADER2
          INX
          LDY     LISTSIZ,X
          CPY     #77
          BCC     LUST3
          LDY     LISTSIZ2,X
LUST3     LDA     LISTTABL,X             ;GET POINTER TO THE ZONES LIST
          STA     LISTPTR
          LDA     LISTTBH1,X
          BIT     DLSPTR
          BMI     LUST2
          LDA     LISTTBH2,X
LUST2     STA     LISTPTR+1
          LDA     HEADER0                ;STORE THE HEADER
          STA     (LISTPTR),Y
          INY
          LDA     HEADER1
          STA     (LISTPTR),Y
          INY
          LDA     HEADER2
          STA     (LISTPTR),Y
          INY
          LDA     HEADER3
          STA     (LISTPTR),Y
          INY
          LDA     LISTSIZ,X
          CMP     #77
          BCC     LUST5
          TYA
          STA     LISTSIZ2,X
          BNE     XXXX
LUST5     TYA
          STA     LISTSIZ,X              ;INCREMENT THE OFFSET
XXXX      JMP     XXX
DONENMY   LDX     #$FF
          LDA     INHSC                  ;SEE IF IN HSC
          BNE     ZHSCLEND
          LDA     RLOGO
          BNE     LPFZ0
ZHSCLEND  JMP     LEND
LPFZ0     LDY     LISTTABL+0
          STY     LISTPTR
          LDY     LISTTBH1+0
          BIT     DLSPTR
          BMI     LZL10
          LDY     LISTTBH2+0
LZL10     STY     LISTPTR+1
SLOADER   INX
          CPX     #16
          BEQ     PUTRACK
          LDA     SCORE,X
          CMP     #$A
          BEQ     SLOADER
          ASL     A
          CLC
          ADC     #L(DIGIT)
          STA     HEADER0
          LDA     #$9E                   ;NUMBERS ON FIRST GRAPHICS PAGE
          ADC     #0
          STA     HEADER2
          LDA     #$7E                   ;PALETTE AND WIDTH
          STA     HEADER1
          LDA     GETXSC,X
          STA     HEADER3
          LDY     LISTSIZ+0
          CPY     #77
          BCC     OVER1
          LDY     LISTSIZ2+0
OVER1
          LDA     HEADER0
          STA     (LISTPTR),Y
          INY
          LDA     HEADER1
          STA     (LISTPTR),Y
          INY
          LDA     HEADER2
          STA     (LISTPTR),Y
          INY
          LDA     HEADER3
          STA     (LISTPTR),Y
          INY
          TYA
          LDY     LISTSIZ+0
          CPY     #77
          BCC     OVER2
          STA     LISTSIZ2+0
          BCS     OVER3
OVER2     STA     LISTSIZ+0
OVER3     JMP     SLOADER
*PUT UP RACK NUMBER HERE
PUTRACK   LDY     LISTTABL+15
          STY     LISTPTR
          LDY     LISTTBH1+15
          BIT     DLSPTR
          BMI     LZL11
          LDY     LISTTBH2+15
LZL11     STY     LISTPTR+1
          LDA     GASTONHK               ;BCD RACK NUMBER
          AND     #$0F                   ;BOOT HIGH NIBBLE
          STA     TEMP8+1                ;ONES DIGIT
          LDA     GASTONHK
          LSR     A
          LSR     A
          LSR     A
          LSR     A
          STA     TEMP8                  ;TENS DIGIT
OUTRLOP
;         LDA     TEMP8
          BEQ     OUTRAL
          ASL     A
          CLC
          ADC     #L(DIGIT)
          STA     HEADER0
          LDA     #$9E                   ;1ST GRAPHICS PAGE
          ADC     #0
          STA     HEADER2
          LDA     #$7E
          STA     HEADER1
          LDA     #142
          STA     HEADER3
          LDY     LISTSIZ+15
          LDA     HEADER0
          STA     (LISTPTR),Y
          INY
          LDA     HEADER1
          STA     (LISTPTR),Y
          INY
          LDA     HEADER2
          STA     (LISTPTR),Y
          INY
          LDA     HEADER3
          STA     (LISTPTR),Y
          INY
          STY     LISTSIZ+15
OUTRAL    LDA     TEMP8+1
          ASL     A
          CLC
          ADC     #L(DIGIT)
          STA     HEADER0
          LDA     #$9E                   ;FIRST GRAPHICS PAGE
          ADC     #0
          STA     HEADER2
          LDA     #$7E
          STA     HEADER1
          LDA     #150
          STA     HEADER3
          LDY     LISTSIZ+15
          LDA     HEADER0
          STA     (LISTPTR),Y
          INY
          LDA     HEADER1
          STA     (LISTPTR),Y
          INY
          LDA     HEADER2
          STA     (LISTPTR),Y
          INY
          LDA     HEADER3
          STA     (LISTPTR),Y
          INY
          STY     LISTSIZ+15
INDLOAD
          LDX     PLAYER
          LDA     LIVES,X
          TAX
          DEX
          BEQ     BEAMLOAD
PUTIND    LDA     #H(MARIA2)
          STA     HEADER2
          LDA     #L(HEROS)
          STA     HEADER0
          LDA     #$BE
          STA     HEADER1
          LDA     INDX,X
          STA     HEADER3
          LDY     LISTSIZ+15
          CPY     #77                    SEE IF HAVE EXCEEDED DISPLAY LIST SIZE
          BCC     LSTLINOK
          LDY     LISTSIZ2+8             USE SECOND LIST OF SIZES
LSTLINOK  LDA     HEADER0
          STA     (LISTPTR),Y
          INY
          LDA     HEADER1
          STA     (LISTPTR),Y
          INY
          LDA     HEADER2
          STA     (LISTPTR),Y
          INY
          LDA     HEADER3
          STA     (LISTPTR),Y
          INY
          LDA     LISTSIZ+15             SEE IF LIST HAS BEEN EXCEEDED
          CMP     #77
          BCC     LASTLNOK
          STY     LISTSIZ2+8
          BNE     LASTLNOQ
LASTLNOK  STY     LISTSIZ+15
LASTLNOQ  DEX
          BNE     PUTIND
BEAMLOAD  LDA     WAITCNT                ;GRAB WAITCNT
          BEQ     BEAM4                  ;IF ZERO, GO TO NEXT ROUTINE
          CMP     #120
          BCS     BEAM1
          LDA     WAITCNT
          STA     WAITCNT3               ;THIS IS THE ZONE OFFSET
          JMP     BEAM2
BEAM1     LDA     #181
          SEC
          SBC     WAITCNT
          STA     WAITCNT3
BEAM2     LDA     #0                     ;FIRST DISPLAY ALL FULL ZONES
          STA     ZOFFSET                ;CLEAR ZOFFSET
          LDX     #11                    ;SET INDEX TO ZONE 12
BEAM3     LDA     WAITCNT3
          SEC
          SBC     #12
          BCC     NEWZONE
          STA     WAITCNT3
          LDA     ZOFFSET
          CLC
          ADC     #12
          STA     ZOFFSET                ;ADVANCE OFFSET TO NEXT ZONE
          LDA     #12
          STA     WAITCNT2
          JSR     DISPLAYZ
          INX
          CPX     #15
          BEQ     BEAM4                  ;ALL ZONES DISPLAYED
          JMP     BEAM3
NEWZONE   LDA     WAITCNT3               ;SEE IF NEW ZONE NEEDED
          BEQ     BEAM4
          CLC
          ADC     ZOFFSET
          STA     ZOFFSET                ;SET ZOFFSET FOR LAST DISPLAY
          LDA     WAITCNT3               ;GET OFFSET INTO LAST ZONE
          STA     WAITCNT2
          JSR     DISPLAYZ               ;NOW DISPLAY NEW ZONE
BEAM4     JMP     LEND
DISPLAYZ  LDA     LISTTABL,X
          STA     LISTPTR
          LDA     LISTTBH1,X             ;GET HIGH @ BYTE
          BIT     DLSPTR                 ;FIND CURRENT DISPLAY LIST
          BMI     OTHERLST
          LDA     LISTTBH2,X             ;GET OTHER HIGH @ BYTE
OTHERLST  STA     LISTPTR+1              ;NOW LISTPTR POINTS TO THE DISPLAY
                                         ;LIST OF THE CURRENT ZONE
          LDA     #L(LSHIELD)            ;LOW @ FOR LEFT SHIELD
          STA     HEADER0
          LDY     ZOFFSET                ;GET TABLE OFFSET
          LDA     BMWIDTH,Y              ;GET CURRENT BEAM WIDTH
          ORA     #$80                   ;USE PALETTE 4
          STA     HEADER1
          LDA     #H(MARIA2)
          SEC
          SBC     #12
          CLC
          ADC     WAITCNT2
          STA     HEADER2
          STA     HEADER6                ;HIGH @ FOR RIGHT SHIELD
          LDA     CAPTUREX
          SEC
          SBC     XCORDOFF,Y
          STA     HEADER3
          LDA     #L(RSHIELD)
          STA     HEADER4
          LDA     #$9F                    ;PALETTE AND WIDTH
          STA     HEADER5
          LDA     CAPTUREX
          CLC
          ADC     XCORDOFF,Y
          CLC                            ;IN CASE OF NEGATIVE NO.
          ADC     #4
          STA     HEADER7
;ALL HEADERS LOADED, NOW STORE IN DISPLAY LIST
          LDY     LISTSIZ,X
          LDA     HEADER0
          STA     (LISTPTR),Y
          INY
          LDA     HEADER1
          STA     (LISTPTR),Y
          INY
          LDA     HEADER2
          STA     (LISTPTR),Y
          INY
          LDA     HEADER3
          STA     (LISTPTR),Y
          INY
          LDA     HEADER4
          STA     (LISTPTR),Y
          INY
          LDA     HEADER5
          STA     (LISTPTR),Y
          INY
          LDA     HEADER6
          STA     (LISTPTR),Y
          INY
          LDA     HEADER7
          STA     (LISTPTR),Y
          INY
          TYA
          STA     LISTSIZ,X              ;RESET LIST SIZE FOR CURRENT ZONE
          RTS
LEND      LDA     #0                     ; PUT TWO ZEROS AT THE ENDS OF THE
          LDX     #15                    ; LISTS
LPFZ      LDY     LISTTABL,X
          STY     LISTPTR
          LDY     LISTTBH1,X
          BIT     DLSPTR
          BMI     LZL1
          LDY     LISTTBH2,X
LZL1      STY     LISTPTR+1
          LDY     LISTSIZ,X
          STA     (LISTPTR),Y
          INY
          STA     (LISTPTR),Y
          DEX
          BPL     LPFZ
;SET DLL TO  POINT TO NEW DISPLAY LIST LIST
          LDA     INHSC                  ;SEE IF IN HSC
          BNE     CONTB                  ;IF SO, BOOT THIS PART
          LDA     #H(DLSTLST1)
          BIT     DLSPTR
          BMI     DLST1
          LDA     #H(DLSTLST2)
DLST1     STA     DPPH
          LDA     #L(DLSTLST1)
          BIT     DLSPTR
          BMI     DLST11
          LDA     #L(DLSTLST2)
DLST11    STA     DPPL
          LDA     DLSPTR
          EOR     #$FF
          STA     DLSPTR                 ;NEXT TIME, WILL USE OTHER DLL
;VESTIGAL KERNEL REMAINS
UPSHIP    LDY     #63
          LDA     TYPE,Y
          BEQ     UNTOUCH1
          LDA     AUTOPLAY               ;NON ZERO IF IN AUTO
          BEQ     NLOOKTAB
          JMP     ALOOKTAB
NLOOKTAB  LDA     MODE+40                ;SEE IF IN REUNITE MODE
          CMP     #9
          BEQ     UNTOUCH1
          LDA     PLAYER                 ;SEE WHICH PLAYER IS UP
          BEQ     NLOOKTB1
          LDA     SWCHA
          ROR     A
          ROR     A
          ROR     A                      ;W BIT IN CARRY
          BCC     GOWEST
          ROR     A
          BCC     GOEAST                 ;E BIT IN CARRY
          BCS     UNTOUCH1
NLOOKTB1  BIT     SWCHA
          BPL     GOEAST
          BVC     GOWEST
UNTOUCH1
          INC     STARINC
          LDA     STARINC
          LSR     A
          BCC     NODEC
NODEC     DEC     ANIMATE
          BNE     CONTA
          LDA     #20
          STA     ANIMATE
          INC     FLAP
CONTA     LDA     MISTIMER
          BEQ     CONTB
          DEC     MISTIMER
CONTB
          INC     FRAME
          DEC     BOOTLDR                ;RESET LOADER FLAG
          LDA     SAVEA
          LDX     SAVEX
          LDY     SAVEY
SPURIOUS  RTI

GOWEST    LDA     HEROX
          BEQ     UNTOUCH1
          DEC     HEROX
          DEC     XCORD+62               ;BLINDLY MOVE THIS GUY
          JMP     UNTOUCH1
GOEAST    LDA     MODE+63                ;GET HERO SHIP MODE
          CMP     #10                    ;SEE IF DUAL HERO MODE
          BNE     GOEAST1
          LDA     HEROX
          CMP     #145
          BEQ     UNTOUCH1
          INC     HEROX
          INC     XCORD+62               ;BLINDLY MOVE THIS GUY
          BNE     UNTOUCH1
GOEAST1   LDA     HEROX
          CMP     #152
          BEQ     UNTOUCH1
          INC     HEROX
          BNE     UNTOUCH1
ALOOKTAB  LDY     TABPNT                 ;HANDLES AUTO GAME
          LDA     AUTAB,Y                ;PICK X COORDINATE TO SHOOT FOR
          CMP     HEROX
          BEQ     TINCPNT                ;INCREMENT POINTER IF IT IS REACHED
          BCS     GOEAST
          BCC     GOWEST
TINCPNT   INC     TABPNT
          LDA     TABPNT
          CMP     #16
          BEQ     TINCPP
          JMP     UNTOUCH1
TINCPP    LDA     #0
          STA     TABPNT
          JMP     UNTOUCH1
PTABL     DB      $41,$61,$71,$00        ;PALLET 0: NOTHING
          DB      $1F,$94,$45,$00        ; 1: RED BUG
          DB      $2C,$0F,$28,$00        ; 2: EXPLOSIONS, SMALL NUMBERS
          DB      $09,$1F,$1D,$00        ; 3: MISSILES, WORDS, SCORES, RACK
          DB      $9B,$E0,$1F,$00        ; 4: BLUE BOSS
          DB      $D6,$40,$1C,$00        ; 5: REGULAR BOSS,HERO
          DB      $E9,$E4,$87,$00        ; 6: LOGO
          DB      $1F,$95,$40,$00        ; 7: BLUE BUG

XCORDOFF  DB      0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3
          DB      4,4,4,4,4,4,5,5,5,5,5,5,6,6,6,6,6,6
          DB      7,7,7,7,7,7,8,8,8

BMWIDTH   DB      $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
          DB      $1E,$1E,$1E,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
          DB      $1D,$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1B
          DB      $1B,$1B,$1B,$1B,$1B,$1B,$1B,$1B

INDX      DB      0,0,10,20,30,40,50,60,70,80,90,100,110,120

DIV3      DB      0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7
          DB      8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13
          DB      14,14,14,15,15,15,16,16,16,17,17,17,18,18,18,19,19,19
          DB      20,20,20,21,21,21,22,22,22
ZOFF      DB      0,12,24,36,48,60,72,84,96,108,120,132,144,156,168,180,192
          DB      $F4,$F4,$F4,$F4,$F4,$F4

LISTTABL  DB      L(S1L1),L(S1L2),L(S1L3),L(S1L4),L(S1L5),L(S1L6)
          DB      L(S1L7),L(S1L8),L(S1L9),L(S1L10),L(S1L11),L(S1L12)
          DB      L(S1L13),L(S1L14),L(S1L15),L(S1L16)
LISTTBH1  DB      H(S1L1),H(S1L2),H(S1L3),H(S1L4),H(S1L5),H(S1L6)
          DB      H(S1L7),H(S1L8),H(S1L9),H(S1L10),H(S1L11),H(S1L12)
          DB      H(S1L13),H(S1L14),H(S1L15),H(S1L16)
LISTTBH2  DB      H(S2L1),H(S2L2),H(S2L3),H(S2L4),H(S2L5),H(S2L6)
          DB      H(S2L7),H(S2L8),H(S2L9),H(S2L10),H(S2L11),H(S2L12)
          DB      H(S2L13),H(S2L14),H(S2L15),H(S2L16)
;GIVES PALETTE AND WIDTH INDEXED BY TYPE
PALWDT    DB      0                      ;PALLET FOR NOTHING
          DB      $FE                    ;PALLET FOR BLUE BUG
          DB      $3E                    ;PALLET FOR RED BUG
          DB      $BE                    ;PALLET FOR REG BOS-GALAGA
          DB      $9E                    ;PALLET FOR BLUE BOS-GALAGA
          DB      $BE                    ;PALLET FOR HERO SHIP
          DB      0                      ;INVISO SHIP (NOT USED)
          DB      $7E                    ;PALLET FOR MISSLES
          DB      $5D                    ;PALLET FOR EXPLOSIONS
          DB      $5C                    ;PALLET FOR SMALL NUMBERS
          DB      $5C                    ;PALLET FOR SMALL NUMBERS
          DB      $5C                    ;PALLET FOR SMALL NUMBERS
          DB      $5C                    ;PALLET FOR SMALL NUMBERS
          DB      $7E                    ;SCORPION,PAL=?,T=13
          DB      0,0
          DB      $BE                    ;PALLET FOR REG-BOSS GALAGA
          DB      $9E                    ;PALLET FOR BLUE-BOSS GALAGA
          DB      $D3                    ;LOGO SECTIONS, W=13,T=18
          DB      $D3                    ;T=19
          DB      $D3                    ;T=20
          DB      $D3                    ;T=21
          DB      $D7                    ;T=22
          DB      $D7                    ;T=23
          DB      $7E                    ;T=24, LINE, NOT USED
          DB      $77                    ;THIS IS PLAYER
          DB      $78                    ;WIDTH 8 FOR READY....
          DB      $7C                    ;DOUBLE MISSILE  TYPE=27
          DB      $73                    ;GAME OVER, WIDTH = 13
          DB      $70                    ;CHALLENGING, WIDTH = 16
          DB      $79                    ;STAGE, WIDTH = 7
          DB      $7E                    ;"1", WIDTH = 2
          DB      $7E                    ;"2", WIDTH = 2
          DB      $76                    ;"FIGHTER" WIDTH = 10
          DB      $74                    ;"CAPTURED" WIDTH = 12
          DB      $9C                    ;TWINKLE, PAL 4, WIDTH = 4
          DB      $6C                    ;NUMOFHTS, PAL3, W=20, TYPE=36
          DB      $76                    ;PERFECT, W=10, PAL3, TYPE=37
          DB      $6D                    ;SPECIAL BONUS, W=19, TYPE=38
          DB      $78                    ;BONUS, W=8, TYPE=39
          DB      $7E                    ;DIGIT, W=2, TYPE=40
          DB      $7A                    ;TEN K, W=6, TYPE=41
          DB      $7D                    ;DOUBLE ZERO, W=3, TYPE=42
          DB      $74                    ;ADVANCED,W=12,T=43
          DB      $77                    ;EXPERT,W=9,T=44
          DB      $77                    ;NOVICE,W=9,T=45
          DB      $78                    ;LEVEL,W=8,T=46
          DB      $75                    ;PLAYERS,W=11?,T=47
          DB      $7E                    ;SONE,W=2,T=48
          DB      $7E                    ;TTWO,W=2,T=49
          DB      $FE                    ;NEWBIRD,W=2,T=50
          DB      $7E                    ;%,W=2,T=51
          DB      $5D                    ;HERO EXPLOSION, W=3,T=52

;THIS TABLE IS INDEXED BY THE TYPE OF THE GIVEN CHARACTER
; IT GIVES AN INDEX INTO THE LSTPTBL
TYPTOLT   DB      0                      ;CALL NO SHIP GRAPHICS (NOT USED)
          DB      0                      ;CALL BLUE BUG GRAPHICS
          DB      9                      ;CALL RED BUG GRAPHICS
          DB      18                     ;CALL BOSS BUG GRAPHICS
          DB      18                     ;CALL BOSS BUG GRAPHICS
          DB      27                     ;CALL HERO GRAPHICS
          DB      0                      ;CALL INVISO SHIP GRAPHICS (NOT USED)
          DB      45                     ;CALL MISSLE GRAPHICS
          DB      36                     ;CALL EXPLOSION GRAPHICS
          DB      53                     ;CALL SMALL NUMBER GRAPHICS
          DB      54                     ;CALL SMALL NUMBER GRAPHICS
          DB      55                     ;CALL SMALL NUMBER GRAPHICS
          DB      56                     ;CALL SMALL NUMBER GRAPHICS
          DB      126                    ;SCORPION,T=13
          DB      0,0
          DB      18                     ;CALL BOSS BUG GRAPHICS
          DB      18                     ;CALL BOSS BUG GRAPHICS
          DB      69,70,71,72,73,74,75
          DB      76                     ;THIS IS FOR PLAYER ANGLE IS 1
          DB      77                     ;FOR READY
          DB      45                     ;CALL MISSILE GRAPHICS
          DB      78                     ;GAME OVER
          DB      79                     ;CHALLENGING
          DB      80                     ;STAGE
          DB      81                     ;"1"
          DB      82                     ;"2"
          DB      83                     ;FIGHTER
          DB      84                     ;CAPTURED
          DB      86                     ;TWINKLE    TYPE=35
          DB      93                     ;NUMOFHTS, T=36
          DB      94                     ;PERFECT, T=37
          DB      95                     ;SPECIAL BONUS, T=38
          DB      96                     ;BONUS, T=39
          DB      98                     ;DIGIT, T=40
          DB      107                    ;TENK, T=41
          DB      108                    ;DBLZERO, T=42
          DB      109                    ;ADVANCED,T=43
          DB      110                    ;EXPERT,T=44
          DB      111                    ;NOVICE,T=45
          DB      112                    ;LEVEL,T=46
          DB      76                     ;PLAYERS,T=47
          DB      113                    ;'1',T=48
          DB      114                    ;'2',T=49
          DB      116                    ;NEWBIRD,T=50
          DB      124                    ;%,T=51
          DB      135                    ;HERO EXPLOSION, T=52

LSTPTBL   DB      L(BLUBUG),L(BLUBUG1),L(BLUBUG2),L(BLUBUG3)
          DB      L(BLUBUG4),L(BLUBUG5),L(BLUBUG6),L(BLUBUG7),L(BLUBUGF)
          DB      L(REDBUG),L(REDBUG1),L(REDBUG2),L(REDBUG3)
          DB      L(REDBUG4),L(REDBUG5),L(REDBUG6),L(REDBUG7),L(REDBUGF)
          DB      L(BOSGAL),L(BOSGAL1),L(BOSGAL2),L(BOSGAL3)             ;21
          DB      L(BOSGAL4),L(BOSGAL5),L(BOSGAL6),L(BOSGAL7),L(BOSGALF)
          DB      L(HEROS),L(HERO1),L(HERO2),L(HERO3)
          DB      L(HERO4),L(HERO5),L(HERO6),L(HERO7),L(HEROS)           ;35
          DB      L(EXPLO0),L(EXPLO1),L(EXPLO2),L(EXPLO3)
          DB      L(EXPLO4),L(EXPLO5),L(EXPLO6),L(EXPLO7),L(EXPLO0)   ;44
          DB      L(MISSLE),L(MISSLE),L(MISSLE),L(MISSLE)
          DB      L(MISSLE4),L(MISSLE),L(MISSLE),L(MISSLE),L(MISSLE)       ;53
          DB      L(SIXTYPE),L(THOTYPE),L(EIGTYPE),L(FOUTYPE)  ;NEW
          DB      L(FOUTYPE),L(FOUTYPE),L(FOUTYPE),L(FOUTYPE),L(FOUTYPE)
          DB      L(FOUTYPE),L(FOUTYPE),L(FOUTYPE),L(FOUTYPE)  ;NEW
          DB      L(FOUTYPE),L(FOUTYPE),L(FOUTYPE)             ;NEW
          DB      L(LULOGO),L(LILOGO),L(RULOGO),L(RILOGO)
          DB      L(BULOGO),L(BILOGO)
          DB      L(LINE)
          DB      L(PLAYERG)             ;77
          DB      L(READY)               ;78
          DB      L(GMEOVER)             ;79
          DB      L(CHLNGING)            ;80
          DB      L(STAGE)               ;81
          DB      L(PONE)                ;82
          DB      L(PTWO)                ;83
          DB      L(FIGHTER)             ;84
          DB      L(CAPTD)               ;85
          DB      L(TWINKLE)             ;86
          DB      L(TWINKL1)             ;87
          DB      L(TWINKL2)             ;88
          DB      L(TWINKL3)             ;89
          DB      L(TWINKL4)             ;90
          DB      L(TWINKL5)             ;91
          DB      L(TWINKL6)             ;92
          DB      L(TWINKL7)             ;93
          DB      L(NUMOFHTS)            ;94TH ENTRY, ANGLE =1
          DB      L(PERFECT)             ;95
          DB      L(SPECIALG)            ;96
          DB      L(BONUS)               ;97
          DB      L(DIGIT0)              ;98
          DB      L(DIGIT1)              ;99
          DB      L(DIGIT2)
          DB      L(DIGIT3)
          DB      L(DIGIT4)
          DB      L(DIGIT5)
          DB      L(DIGIT6)
          DB      L(DIGIT7)
          DB      L(DIGIT8)
          DB      L(DIGIT9)              ;107
          DB      L(TENK)                ;108
          DB      L(DBLZERO)             ;109
          DB      L(ADVANCED)            ;110
          DB      L(EXPERT)              ;111
          DB      L(NOVICE)              ;112
          DB      L(LEVEL)               ;113
          DB      L(SONE)                ;114TH ENTRY
          DB      L(STWO)                ;115
          DB      L(NEWBIRD0),L(NEWBIRD1),L(NEWBIRD2),L(NEWBIRD3)
          DB      L(NEWBIRD4),L(NEWBIRD5),L(NEWBIRD6),L(NEWBIRD7)
          DB      L(NEWBIRD0)            ;124
          DB      L(PERCENT)             ;125
          DB      L(SCORP0),L(SCORP1),L(SCORP2),L(SCORP3),L(SCORP4)
          DB      L(SCORP5),L(SCORP6),L(SCORP7),L(SCORPF)   ;134
          DB      L(HEXPLO0),L(HEXPLO1),L(HEXPLO2),L(HEXPLO3)
          DB      L(HEXPLO4),L(HEXPLO5),L(HEXPLO6),L(HEXPLO7),L(HEXPLO0) ;143

AUTAB     DB      $58,$19,$46,$30,$50,$5A,$40,$20,$50,$45
          DB      $72,$1E,$31,$4C,$80,$30,$38

GETXSC    DB      0,8,16,24,32,40,48,56,94,102,110,118,126,134,142,150

***************************
***** High Score Code *****
***************************
; THIS FILE CONTAINS THE HANDLERS FOR THE INTERFACE TO THE HISCORE
;         MODULE.  "MKHISCOR" AND "MKENTER" INITIATE MODES;
;         "HISCORE" AND "ENTER" JUST LOOP IN WAIT.
; THIS CODE IS REACHED THROUGH A JSR

HSCATRCT  EQU     $3FFA
HSCINITL  EQU     $3FFD
HSCRAM    EQU     $2200

HSCDSPLY  JSR     BUILDHSC
          JMP     HSCATRCT               RETURN FROM THERE

HSCENTER
          JSR     BUILDHSC
          JMP     HSCINITL               RETURN FROM THERE

BUILDHSC
          LDA     $3900
          CMP     #$C6
          BNE     HSCMISSS
          LDA     $3904
          CMP     #$FE
HSCMISSS  BNE     HSCMISS

;         LDX     #31
;DLSTLD    LDA     HSCDLST1,X             ;MOVE LOGO DISPLAY LIST DOWN INTO RAM
 ;        STA     S1L1,X
  ;       DEX
   ;      BPL     DLSTLD

          LDX     #14                    COPY 15 BYTES FROM HSCROM TO HSCRAM
HSCLOAD   LDA     HSCROM,X
          STA     HSCRAM,X
          DEX
          BPL     HSCLOAD

          LDA     DIFCULTY               ; DIFFICULTY LEVEL FOR THIS CALL
          TAX
          ASL     A                      ;  --CALLED 3 TIMES FROM "LOGO"
          ASL     A                      ; ONCE FOR EACH DIFFICULTY LEVEL
          ORA     PLAYER                 WHO'S ENTERING HIS INITIALS
          STA     HSCRAM+2

          LDA     DNTABL,X
          STA     HSCRAM+6
          LDA     DNTABH,X
          STA     HSCRAM+7

          LDA     PLAYER
          BEQ     CONTINUE
;         MOVEPTR SCORE2,HSCRAM+8        OTHER PLAYER
          LDA     SCORE+8                HIGHEST BYTE OF P2 SCORE
          CMP     #$A
          BNE     NIBOK1
          LDA     #0
          BEQ     NXTNIB
NIBOK1    ASL     A
          ASL     A
          ASL     A
          ASL     A
NXTNIB    ORA     SCORE+9                PUT IN BCD FORM
          CMP     #$A
          BNE     NIBOK2
          LDA     #0
NIBOK2    STA     HSCORE
          LDX     #2
LDSCORE   LDA     P2SCORE,X
          STA     HSCORE+1,X
          DEX
          BPL     LDSCORE
          BMI     SETXANDY
CONTINUE
          LDA     SCORE
          CMP     #$A                    ;SEE IF BLANK
          BNE     NIBOK3
          LDA     #0
          BEQ     NXTNIBL
NIBOK3    ASL     A
          ASL     A
          ASL     A
          ASL     A
NXTNIBL   ORA     SCORE+1                ;PUT SCORE IN BCD FORM
          CMP     #$A
          BNE     NIBOKK
          LDA     #0
NIBOKK    STA     HSCORE
          LDX     #2
LDSCORE2  LDA     P1SCORE,X
          STA     HSCORE+1,X
          DEX
          BPL     LDSCORE2
;         COPY    HSCDLIST,ARAMZONE,40
SETXANDY  LDX     #L(HSCRAM)
          LDY     #H(HSCRAM)
NOSOUND   RTS

HSCMISS   PLA
          PLA
          RTS


; THIS TABLE IS COPIED INTO RAM WHEN HSC IS CALLED.  IT'S THE ARGUMENT BLOCK
;         NEEDED BY THE HSC.

HSCROM    DB      $86,$26                ; CARTRIDGE ID NUMBER
                                         ; trailing zero bit set
          DB      $00                    ; DIFFICULTY LEVEL
                                         ;  + PLAYER NUMBER (BOTTOM 2 BITS)
          DB      $00                    ; CONTROLLER TYPE

          DB      0
          DB      0                      ;USE ZEROS FOR GAMENAME
;         DB      L(GAMENAME)            ; UNTIL NEW CART REVISION
;         DB      H(GAMENAME)
          DB      L(DNAME0)            ; POINTER TO DIFFICULTY NAME
          DB      H(DNAME0)              ;26 BYTES LONG
          DB      L(HSCORE),H(HSCORE)  ; POINTER TO THE SCORE
                                         ;   WILL BE PL0SCORE OR PL1SCORE
          DB      L(HSCDLL),H(HSCDLL)    ; DLIST LIST POINTER FOR LOGO
*         DB      $00,$00                IGNORED IF ZEROS

          DB      L(TWINKEL),H(TWINKEL) ; TWINKLE ROUTINE
          DB      $04                    ; SECONDS TO WAIT BEFORE RETURNING
                                         ;  (FOR EACH DIFFICULTY LEVEL)

HSCDLL    DB      $C9,H(DUMYHDR),L(DUMYHDR)
          DB      $43,H(ZEROHDR),L(ZEROHDR)
          DB      $4B,H(S1L6),L(S1L6)
*THIS STUFF IS OFF THE SCREEN ON MOST TV'S
          DB      $4B,H(S1L7),L(S1L7)
          DB      $4B,H(S1L8),L(S1L8)
          DB      $4B,H(S1L9),L(S1L9)
          DB      $4B,H(S1L10),L(S1L10)

;HSCDLST1  DB      L(LULOGO),$D3,$C0,26
 ;        DB      L(RULOGO),$D3,$C0,78
  ;       DB      0,0
   ;      DB      L(LILOGO),$D3,$C0,26   ;HSCDLST2
    ;     DB      L(RILOGO),$D3,$C0,78
     ;    DB      0,0
      ;   DB      L(BULOGO),$D7,$C0,66   ;HSCDLST3
       ;  DB      0,0
;         DB      L(BILOGO),$D7,$C0,66   ;HSCDLST4
 ;        DB      0,0

;GAMENAME  DB      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
 ;        DB      $09,$0E,$14,$12,$13                    ; "JOUST"
  ;       DB      $1D,$1D,$1D
DNAME0    DB      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D    ; overlapped
          DB      $1D,13,14,21,8,2,4,$1D      ; "NOVICE"
          DB      $1D,$1D,$1D
DNAME1    DB      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D    ; overlapped
          DB      $0,$3,$15,$0,$D,$2,$4,$3        ; "ADVANCED"
DNAME2    DB      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D ; overlapped
          DB      $4,$17,$F,$4,$11,$13           ; "EXPERT"
          DB      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D

DNTABL    DB      L(DNAME0),L(DNAME1),L(DNAME2)  ;NOVICE,ADVANCED,EXPERT
DNTABH    DB      H(DNAME0),H(DNAME1),H(DNAME2)
END01     DB      0

;*******************************************************************************
; VECTORS FOR STARTUP
          ORG     $DFF8
          DB      $FF,$E7                ;SECURITY ROM
          DB      L(HANDLER),H(HANDLER)  ;NMI VECTOR FOR DLI
          DB      L(STARTUP),H(STARTUP)  ;STARTUP VECTOR
          DB      L(SPURIOUS),H(SPURIOUS)  ; HITS AN RTI
;*******************************************************************************


;*******************************************************************************
; VECTORS FOR STARTUP
          ORG     $FFF8
          DB      $FF,$E7                ;SECURITY ROM
          DB      L(HANDLER),H(HANDLER)  ;NMI VECTOR FOR DLI
          DB      L(STARTUP),H(STARTUP)  ;STARTUP VECTOR
          DB      L(SPURIOUS),H(SPURIOUS)  ; HITS AN RTI
;*******************************************************************************
;*******************************************************************************
