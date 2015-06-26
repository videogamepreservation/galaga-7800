;GDAC4.S
;
;
;
;THIS TABLE IS A MOTION TABLE WHICH CAUSES A SHIP TO ENTER IN THE FIRST, FOURTH,
;AND FIFTH WAVES.  X AND ANGLE MUST BE NEGATED FOR HALF OF THE FIRST WAVE AND
;THE FIFTH WAVE.
;THERE ARE 110 ENTRIES.
;
MOTION1   DB      $F6,$04
          DB      $56,$04
          DB      $E5,$04,$E4,$04,$E4,$04,$E4,$04
          DB      $56,$E4,$C4,$E4,$C4,$E4
          DB      $C4,$E4,$C4,$E4,$C4,$E4,$C4,$E4,$C4,$E4
          DB      $C4,$E4,$C4,$E4,$C4,$F6,$E4
          DB      $E4,$E4,$04,$E4,$04,$46
          DB      $E4,$04,$E4,$04,$E4,$04,$E4,$04,$E4,$04
          DB      $E4,$04,$E4,$04,$E4,$26,$04,$E7,$04
          DB      $E4,$C6
          DB      $04,$27,$04,$24,$04,$36,$24
          DB      $44,$24,$44,$24,$24,$20,$24,$40
          DB      $27,$20,$24
          DB      $F6,$20
          DB      $26,$20,$3F,$20,$3C,$20,$3C,$20,$3C,$20
          DB      $5C,$3C,$5C,$36,$3C,$1C,$3C
          DB      $66,$1C,$1F,$26,$1C
          DB      $3C,$1C,$3C,$A6
          DB      $1C,$02

;
;THIS IS THE TABLE WHICH CAUSES A SHIP TO ENTER IN THE SECOND AND THIRD WAVES.
;X AND ANGLE MUST BE NEGATED FOR THE THIRD WAVE.
;141 ENTRIES
MOTION2   DB      $3C,$20,$3C,$20,$3C,$20,$3C,$20,$3C,$20
          DB      $3C,$20,$3C,$20,$3C,$20,$3C,$20,$3C,$20
          DB      $3C,$20,$3C,$20,$3C,$20,$3C,$20,$3C,$20
          DB      $3C,$20,$3C,$20,$3C,$20,$3C,$20,$3C,$20
          DB      $3C,$3C,$3C,$20,$3C,$20,$3C,$3C,$3C,$20
          DB      $3C,$20
          DB      $F6,$3C
          DB      $46,$3C,$1C,$3C,$1C,$3C,$1C,$3F,$66,$1C
          DB      $FC,$1C,$FC,$26
          DB      $1C,$FC,$1C,$FF,$1C,$26,$FC,$E0
          DB      $FC,$E0,$E3,$86
          DB      $E0,$E7,$E0,$E4,$E0,$E4,$E0,$E4,$E0
          DB      $E4,$04,$E4,$04,$E4,$04,$E7,$86
          DB      $04,$27,$04,$24,$04
          DB      $24,$04,$24,$04,$26,$24,$20,$24,$20
          DB      $23
          DB      $A6,$20,$3F,$20,$3C,$20,$26,$3C,$1C
          DB      $3C,$1C,$3C,$1C,$3C,$1C,$3C,$1C,$3C
          DB      $46,$1C,$1F,$26,$1C,$3C,$1C
          DB      $3C
          DB      $C6,$1C,$02


;THIS TABLE IS A MOTION TABLE WHICH IS FOLLOWED BY AN ATTACKING BLUE SHIP.
;IT IS GONE THROUGH TWICE.
;THERE ARE TWO PARTS, ONLY THE SECOND PART IS REPEATED.
;THERE ARE A TOTAL OF 58 ENTRIES
;
BATBL1    DB      $FF,$1C,$DF,$FC,$C7,$E4,$E7
BATBL1B   DB      $F6,$04
          DB      $D6,$04
BATBL1A   DB      $56,$04,$24,$04,$27,$04
          DB      $24,$04,$24,$04,$26,$24,$00,$24,$00
          DB      $27,$20,$24,$66,$20
          DB      $24,$20,$25,$20,$24,$20,$24,$20,$24,$20
          DB      $24,$20,$24,$20,$28,$24,$28,$24,$24,$04
          DB      $24,$04,$25,$04,$24,$04,$02

;THIS TABLE INDEXED BY RACK TELLS HOW MANY MISSLES CAN EXIST AT A TIME
;DURING THE SPECIFIC RACK
;32 ENTRIES
NUMMIS    DB      53,47,48,46,48,49,49,46      ;46=0,47=1,ETC
          DB      49,49,49,46,49,50,50,46
          DB      48,49,49,46,49,49,50,46
          DB      49,49,49,46,50,50,51
          DB      46

;THESE TABLES ARE THE MOTION TABLES FOR BOSS ATTACK
;9 ENTRIES
BOTBL1    DB      $FF,$1C,$DF,$FC,$C7,$E4,$E7,$04,$02

;THIS IS A HSC GAMEPOLL ROUTINE
GAMEPOLL
          LDX     SWCHA
          INX
          BNE     FUCKYES                YES, THERE IS AN INPUT
          LDA     SWCHB
          AND     #$03
          CMP     #$03
          BNE     FUCKYES                YES, THERE IS AN INPUT
          LDA     INPT4
          AND     INPT5
          BPL     FUCKYES
          CLC                            SIGNAL NO INPUT
          RTS
FUCKYES   SEC                            SIGNAL INPUT FOUND
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
          DB      L(DNAME0)            ; POINTER TO DIFFICULTY NAME
          DB      H(DNAME0)              ;26 BYTES LONG
          DB      L(HSCORE),H(HSCORE)  ; POINTER TO THE SCORE
                                         ;   WILL BE PL0SCORE OR PL1SCORE
          DB      L(HSCDLL),H(HSCDLL)    ; DLIST LIST POINTER FOR LOGO

          DB      L(TWINKEL),H(TWINKEL) ; TWINKLE ROUTINE

          DB      $04                    ; SECONDS TO WAIT BEFORE RETURNING
                                         ;  (FOR EACH DIFFICULTY LEVEL)


DNTABL    DB      L(DNAME0),L(DNAME1),L(DNAME2)  ;NOVICE,ADVANCED,EXPERT
DNTABH    DB      H(DNAME0),H(DNAME1),H(DNAME2)
TWINKY    DB      $43,$50,$41,$48,$52,$50,$5D
END3      DB      $49


          ORG     END4
;
;THIS IS THE MOTION TABLE WHICH CAUSES AN ATACKING BLUE SHIP TO CIRCLE AROUND.
;THERE ARE 110 ENTRIES
BATBL3    DB      $E4,$04,$E5,$04,$E4,$04,$E4,$04,$26
          DB      $E4,$E0,$E4,$E0,$E4,$E0,$E4,$E0,$E5,$E0
          DB      $E4,$C6
          DB      $E0,$FC,$E0,$FD,$E0,$FC,$E0
          DB      $FC,$E0,$FC,$E0,$FC,$E0,$46
          DB      $FC,$1C,$FC,$1C,$FC,$1C,$FC,$1C,$FD,$1C
          DB      $FC,$C6
          DB      $1C,$3C,$1C,$3D,$1C,$3C,$1C
          DB      $3C,$1C,$3C,$1C,$3C,$1C,$46
          DB      $3C,$20,$3C,$20,$3C,$20,$3C,$20,$3D,$20
          DB      $3C,$C6
          DB      $20,$24,$20,$25,$20,$24,$20
          DB      $24,$20,$24,$20,$24,$20,$46
          DB      $24,$04,$24,$04,$24,$04,$24,$04,$25,$04
          DB      $24
          DB      $F6,$04,$F6,$04
          DB      $F6,$04,$04
BATBL3A   DB      $F6,$04
          DB      $76,$04,$0E

TWINKX    DB      $28,$3E,$47,$50,$30,$57,$5B,$72

;THESE TABLES ARE THE MOTION TABLES FOR BOSS ATTACK
;66 ENTRIES
BOTBL2    DB      $05,$E4,$04,$E4,$04,$E4,$04,$26,$E4
          DB      $E0,$E4,$E0,$E5,$A6
          DB      $E0,$E1,$E0,$FC,$E0
          DB      $26,$FC,$1C,$FC,$1C,$FC,$1C,$FC,$1C,$FD
          DB      $86,$1C,$3D
          DB      $1C,$3C,$1C,$3C,$1C,$3C,$20,$3C,$20,$3C
          DB      $20,$3C,$20,$3D,$86
          DB      $20,$21,$20,$24,$20,$26,$24
          DB      $04,$24,$04,$24,$26,$04,$25,$04,$24
          DB      $56,$04
END5      DB      $02



          ORG     $DF76
;COPYRIGHT GCC 1984
          DB      $47,$43,$43,$28,$63,$29,$31,$39,$38,$34

;THIS NEXT SECTION GOES AFTER GLOADER.S
          ORG     END01

;
;THIS IS THE MOTION TABLE WHICH CAUSES AN ATTACKING BLUE SHIP TO CURVE
;UP TOWARD THE FORMATION.
;THERE ARE 4 ENTRIES
;
BATBL2    DB      $E5,$04,$C5,$E4,$DD,$FC,$FD,$1C,$06

;
;
;THIS TABLE INDEXED BY RACK TELLS HOW MANY SHIPS CAN BE FLYING AROUND
;IN THE SPECIFIC RACK
;
NUMATTK   DB      4,2,2,1,3,3,3,1
          DB      2,2,2,1,3,3,3,1
          DB      3,3,3,1,3,3,3,1
          DB      3,3,3,1,4,4,4,1

;  THIS TABLE IS FOR THE RACK 3 CHALLENGING STAGE
CHRACK3A  DB      $F6,$08
          DB      $F6,$08
          DB      $36,$08,$E8,$08,$08,$E9
          DB      $E8,$08,$E8,$08,$26,$E8,$08,$36,$E8
          DB      $E4,$E4,$36,$E8,$E4,$E4
          DB      $E8,$E8,$E4,$E4,$E8,$E4,$E4,$E8,$56,$E4
          DB      $C4,$26,$E4
          DB      $26,$C4,$C0,$C0,$DC,$DD,$DC,$F8,$F9
          DB      $18,$F8,$18,$38,$18,$38,$38,$39,$38,$20,$3C
          DB      $58,$58,$20,$3C,$58,$20,$3D,$20,$3C,$20,$3C
          DB      $20,$3C,$20,$3C,$58,$40,$20,$3C,$5C,$20
          DB      $3C,$20,$3C,$40,$20,$3C,$20,$3C,$20,$3C,$40
          DB      $20,$3C,$40,$40,$20,$3C,$40,$20,$3C,$40,$20
          DB      $3C,$20,$3C,$40,$20,$3C,$40,$20,$3C,$20
          DB      $3C,$40,$20,$3C,$40,$20,$3C,$20,$3C,$40
          DB      $20,$3C,$40,$20,$3C,$20,$3C,$40,$20,$3C
          DB      $40,$20,$3C,$20,$3C,$40,$20,$3C,$40,$20
          DB      $3C,$20,$3C,$40,$20,$3C,$40,$20,$3C,$20
          DB      $3C,$40,$20,$3C,$40,$20,$3C,$02

CHRACK3B  DB      $E0,$E0,$FC,$26,$E0,$FC,$E0,$FC,$E0
          DB      $FC,$E0,$FC,$E0,$FC,$E0,$FC,$E0,$FC,$E0
          DB      $FC,$E0,$FC,$E0,$FC,$E0,$FC,$E0,$FC,$E0
          DB      $FC,$E0,$FC,$E0,$FC,$E0,$FC,$E0,$FC,$E0
          DB      $FC,$E0,$FC,$E0,$FC,$E0,$FC,$E0,$FC,$E0
          DB      $FC,$E0,$FC,$E0,$D8,$FC,$E0,$FC,$E0
          DB      $FC,$E0,$D8,$FC,$E0,$D8,$FC,$E0
          DB      $D8,$FC,$E0,$D8,$FC,$E0,$FC,$E0
          DB      $FC,$E0,$FC,$FC,$1C,$56
          DB      $FC
          DB      $1C,$26,$FC,$FD
          DB      $FC,$1C,$FC,$FD,$F8
          DB      $36,$1C,$F8,$F6,$1C
          DB      $F6,$1C
          DB      $B6,$1C
          DB      $3D,$3C,$1C,$3C,$3C,$3D,$26,$20,$24
          DB      $20,$25,$26,$24,$20,$24,$24,$04,$24
          DB      $05,$F6,$04
          DB      $F6,$04
          DB      $B6,$04
          DB      $E9
          DB      $E0,$FC,$E0,$FC,$FD
          DB      $FC,$FD
          DB      $F6,$FC
          DB      $F6,$FC
          DB      $F6,$FC
          DB      $F6,$FC
          DB      $F6,$FC,$F2
          DB      $02

CHRACK7B  DB      $F6,$20
          DB      $F6,$20
          DB      $F6,$20
          DB      $F6,$20
          DB      $F6,$20
          DB      $36,$20,$3C,$26,$20
          DB      $3C,$26,$20,$3C,$20,$3C,$20,$3C,$20
          DB      $36,$5C,$5F,$5C,$58,$5C,$58,$58
          DB      $38,$58,$58,$38,$58,$26,$38,$58,$46
          DB      $38,$3B,$18,$38,$38,$18,$38
          DB      $18,$38,$26,$18,$38,$56,$18
          DB      $F8,$26,$18,$F8,$18,$F8,$18
          DB      $F8,$F8,$18,$F8,$FB,$66,$F8
          DB      $26,$D8,$86,$DC
          DB      $C3,$DC,$C0,$C0,$DC,$B6,$C0
          DB      $C4,$C0,$C3,$C4
          DB      $C0,$76,$C4,$36
          DB      $C8,$46,$E8,$EB,$26
          DB      $08,$E8,$E8,$08,$E8,$08,$E8,$26
          DB      $08,$E8,$56,$08,$28
          DB      $26,$08,$28,$08,$28,$08,$28,$28,$08
          DB      $56,$28,$48,$28,$28,$2B
          DB      $48,$28,$48,$48,$28,$48,$48,$44,$48,$44
          DB      $24,$20,$24,$20,$27,$20,$24,$20,$24,$20
          DB      $24,$20,$24,$20,$24,$26,$20,$24,$26
          DB      $20,$24,$F6,$20
          DB      $F6,$20
          DB      $F6,$20,$F6,$20
          DB      $F6,$20
          DB      $26,$20,$02

*THIS DATA IS ALSO USED FOR CHRACK11A
CHRACK7A  DB      $F6,$08
          DB      $F6,$08
          DB      $A6,$08
          DB      $28,$2B,$28,$56,$48
          DB      $44,$48,$44,$48,$26,$44,$47
          DB      $44,$40,$44,$40,$44,$40,$44,$41,$45,$41
          DB      $C1,$DC,$C0,$DC,$C1,$DC,$C0,$DC,$C0
          DB      $46,$DC,$D8,$DC,$D8,$DC,$56,$D8
          DB      $F9,$F8,$F8,$F6,$18
          DB      $F6,$18
          DB      $A6,$18
          DB      $02

CHRCK11B  DB      $F6,$40
          DB      $F6,$40
          DB      $86,$40,$36,$03,$B6,$C0
          DB      $DD
          DB      $DC,$DC,$D8,$DC,$36,$D8,$36,$F8
          DB      $18,$F8,$F8,$18,$F8,$F8,$18,$F9
          DB      $18,$F8,$18,$F8,$18,$F8,$26,$18,$F8
          DB      $36,$18,$F8,$66,$18
          DB      $38,$18,$38,$38,$18,$66,$38
          DB      $39,$86,$58
          DB      $26,$5C,$5D,$5C,$5C
          DB      $40,$45,$44,$48,$28,$29,$28,$28,$08,$08
          DB      $28,$26,$08,$28,$F6,$08
          DB      $46,$08,$2B,$28,$48,$48
          DB      $47,$44,$F6,$40
          DB      $F6,$40
          DB      $86,$40
          DB      $02

CHRCK15A  DB      $76,$08,$0B,$03
          DB      $40,$44,$40,$44,$45,$48,$48,$4C,$28,$29
          DB      $28,$08,$28,$08,$E8,$08,$26,$E8,$C9
          DB      $26,$C8,$C4,$C1,$C4,$36,$C0
          DB      $36,$C4,$C7,$C8,$C8,$CC,$E8,$0B
          DB      $E8,$36,$08,$28,$08,$28,$28,$4B
          DB      $48,$48,$64,$40,$47,$46,$40
          DB      $44,$40,$44,$48,$49,$48,$48,$28,$28,$09
          DB      $28,$26,$08,$E8,$08,$26,$E8,$C9
          DB      $C8,$A8,$C4,$C0,$C1,$C4,$26,$C0,$46
          DB      $DC,$D9,$D8,$D4,$F8,$F8,$19
          DB      $F8,$18,$18,$38,$18,$36,$38,$59
          DB      $58,$26,$5C,$41,$5C,$26,$40,$5C
          DB      $40,$26,$5C,$5B,$58,$58,$38,$38,$3B
          DB      $18,$38,$18,$18,$F8,$18,$26,$F8,$DB
          DB      $B4,$D8,$DC,$DC,$DF,$46,$C0
          DB      $DC,$C0,$DC,$DC,$DD,$D8,$26,$F8,$F9
          DB      $18,$F8,$18,$18,$38,$18,$38,$18,$38,$59
          DB      $58,$58,$5C,$5C,$5D,$40,$5C,$40,$43,$03
          DB      $86,$18,$02

CHRCK15B  DB      $5C,$5C,$66,$58,$38
          DB      $3B,$36,$38,$18,$38,$18,$38,$18
          DB      $38,$18,$38,$18,$18,$38,$18,$38,$18,$38
          DB      $18,$36,$38,$58,$38,$58,$38,$5D
          DB      $58,$5C,$5C,$41,$5C
*THIS IS THE FIRST LOOP
CHRCK15C
          DB      $46,$40,$44,$45,$44,$24
          DB      $48,$26,$28,$09,$28,$08,$28,$08,$08
          DB      $28,$08,$08,$C8,$08,$C8,$08,$C8,$08,$C8
          DB      $C8,$C9,$C8,$C4,$C9,$C8,$C4,$C0,$D8,$D9
          DB      $D8,$18,$F9,$46,$18,$38,$18
          DB      $38,$18,$38,$18,$46,$38,$59
          DB      $38,$26,$58,$59,$58,$40,$58,$40

          DB      $46,$40,$44,$45,$44,$24
          DB      $48,$26,$28,$09,$28,$08,$28,$08,$08
          DB      $28,$08,$08,$C8,$08,$C8,$08,$C8,$08,$C8
          DB      $C8,$C9,$C8,$C4,$C9,$C8,$C4,$C0,$D8,$D9
          DB      $D8,$18,$F9,$46,$18,$38,$18
          DB      $38,$18,$38,$18,$46,$38,$59
          DB      $38,$26,$58,$59,$58,$40,$58,$40

          DB      $46,$40,$44,$45,$44,$24
          DB      $48,$26,$28,$09,$28,$08,$28,$08,$08
          DB      $28,$08,$08,$C8,$08,$C8,$08,$C8,$08,$C8
          DB      $C8,$C9,$C8,$C4,$C9,$C8,$C4,$C0,$D8,$D9
          DB      $D8,$18,$F9,$46,$18,$38,$18
          DB      $38,$18,$38,$18,$46,$38,$59
          DB      $38,$26,$58,$59,$58,$40,$58,$40
*THIS IS THE DEPARTING PATH
CHRCK15D
          DB      $40,$44,$45
          DB      $48,$48,$26,$28,$48,$26,$28,$29
          DB      $08,$28,$08,$28,$08,$28,$26,$08,$28
          DB      $08,$28,$08,$28,$08,$28,$08,$28,$08,$28
          DB      $08,$26,$28,$2B,$36,$28,$47
          DB      $40,$40,$02

CHRCK19A  DB      $F6,$E8,$F6,$E8,$F6,$E8,$46,$E8,$EB,$08,$2B
          DB      $F6,$48,$48,$47,$40,$5F,$F6,$58,$58
          DB      $3B,$38,$FB
          DB      $F8,$F6,$D8,$26,$D8,$DF,$C7,$D6,$C8,$EB
          DB      $08,$2B,$B6,$48,$47,$40,$5F,$B6
          DB      $58,$3B,$18,$FB,$A6,$D8,$DF,$C7
          DB      $A6,$C8,$EB,$08,$2B,$86,$48,$47
          DB      $40,$5F,$86,$58,$3B,$18,$FB,$76
          DB      $D8,$DF,$C7,$76,$C8,$EB,$2B,$66
          DB      $48,$47,$5F,$56,$58,$5B,$1B,$F6
          DB      $D8,$F6,$D8,$F6,$D8,$36,$D8,$02

CHRCK19B
          DB      $76,$40,$5F,$26,$5C,$F6,$58,$F6,$58,$96
          DB      $58,$5D,$26,$5C,$36,$40,$45,$26,$44,$48
          DB      $49,$36,$28,$36,$08,$E9,$26,$E8,$C8,$C8
          DB      $C4,$C5,$76,$C0,$DD,$26,$DC,$F6,$D8,$D8
          DB      $36,$DC,$C3,$26,$C0,$C7,$26,$C4,$C8,$C8
          DB      $EB,$26,$E8,$36,$08,$2B,$26,$28,$48,$48
          DB      $36,$44,$43,$26,$40,$5F,$26,$5C,$F6,$58
          DB      $26,$58
          DB      $3B,$26,$38,$36,$18,$FB,$26,$F8,$D8,$D8
          DB      $36,$DC,$C3,$26,$C0,$C7,$26,$C4,$C8,$CB
          DB      $36,$E8,$36,$08,$2B,$F6,$28,$F6,$28,$86
          DB      $28,$36,$48,$76,$44,$43,$D6,$40,$02

CHRCK23A  DB      $F6,$08,$36,$08,3,3,$B6,$40
          DB      1,1,$F6,8,$36,8,3,3,$B6,$40,1,1
          DB      $F6,8,$36,8,3,3,$F6,$40,$36,$40
          DB      $02

CHRCK23B  DB      $36,$40,$5F,$F6,$5C,$F6,$5C,$F6,$5C,$F6,$5C,$5C
          DB      $58,$3B,$18,$FB,$D8,$96,$DC,$C3,$F6,$C0
          DB      $F6,$C0,$DD,$26,$DC,$D8,$F9,$18
          DB      $39,$58,$36,$5C,$41,$F6,$40,$76,$40,$5F
          DB      $26,$5C,$58,$3B,$18,$FB,$D8,$36,$DC,$C3
          DB      $F6,$C0,$C0,$C0,$DD,$26,$DC,$D8,$F9,$18
          DB      $39,$48,$36,$5C,$41,$76,$40,$03,$03,$76
          DB      $18,$02

CHRCK27A  DB      $76,$08,$01,$01,$F6,$C0,$F6,$C0,$C0,$C3
          DB      $03,$03,$F6,$24,$F6,$24,$F6,$24,$F6,$24
          DB      $F6,$24,$F6,$24,$F6,$24,$F6,$24,$F6,$24
          DB      $49,$01,$01,$F6,$C0,$F6,$C0,$F6,$C0,$F6
          DB      $C0,$B6,$C0,$02

CHRCK27B  DB      $F6,$20,$5F,$26,$5C,$36,$3C,$3B,$26,$38
          DB      $F6,$18,$A6,$18,$39,$26,$38,$36,$3C,$21
          DB      $3C,$20,$3C,$76,$20,$25,$20,$24,$20
          DB      $24,$20,$24,$20,$24,$20,$24,$20,$24,$20,$96,$24
          DB      $24,$20,$27,$20
          DB      $B6,$20,$3F,$20,$3C,$20,$96,$3C
          DB      $3C,$20,$3C,$20,$3C,$20,$3C,$20,$3C,$20,$3D,$20
          DB      $76,$20,$25,$20,$24,$20,$36,$24,$36,$28
          DB      $05,$F6,$08,$A6,$08,$2B,$26,$28,$36,$24
          DB      $36,$44,$23,$A6,$20,$02

CHRCK31A  DB      $F6,$08,$B6,$08,$2B,$26,$28,$48,$48,$26
          DB      $44,$47,$56,$40,$5F,$26,$5C,$58,$5B,$36
          DB      $38,$56,$18,$FB,$26,$F8,$D8,$DB,$36,$DC
          DB      $56,$C0,$C7,$26,$C4,$C8,$C8,$F6,$E8,$F6
          DB      $E8,$56,$E8,$C8,$C8,$36,$C4,$C1,$46,$C0
          DB      $DD,$26,$DC,$D8,$D8,$36,$F8,$19,$46,$18
          DB      $36,$38,$59,$58,$26,$5C,$5D,$56,$40
          DB      $36,$44,$49,$48,$36,$28,$09,$46,$08,$E9
          DB      $F6,$E8,$E8,$36,$C8,$B6,$C4,$C1,$76,$C0
          DB      $02

CHRCK31B  DB      $F6,$5C,$F6,$5C,$F6,$5C,$56,$5C,$36,$58
          DB      $3B,$46,$38,$76,$18,$56,$F8,$DB,$26,$D8
          DB      $56,$DC,$C3,$66,$C0,$56,$C4,$CB,$26,$C8
          DB      $56,$E8,$0B,$66,$08,$56,$28,$4B,$26,$48
          DB      $56,$44,$43,$66,$40,$5F,$F6,$5C,$F6,$5C
          DB      $46,$5C,$02
END2      DB      $02

          END
