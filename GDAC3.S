;GDAC3.S
;
;THE FOLLOWING TABLE GIVES SINGLE OR DOUBLE BIRTH INFORMATION
LOWPAIR   DB      0,2,1,1,1,1         ;2,2,2,2,2
HIGHPAIR  DB      2,2,2,2,2,2,2,1,1,1,1,2,2        ;,2,2
CHALPAIR  DB      2,2,1,1,1,1
          DB      2,2,2,1,1
          DB      1,2,2,1,1
          DB      2,1,1,2,2
          DB      1,1,1,1,1
          DB      1,2,2,1,1
          DB      1,1,1,1,1
          DB      2,1,1,2                ;LAST MEMBER IS @ LOCATION ZERO

;THE FOLLOWING TABLE INDEXED BY SHIPCNT GIVES THE SHIP NUMBER OF EACH SHIP
;AS IT IS BORN.  NON-FORMATION SHIPS HOLD A SPECIAL CODE
SHPNUTB   DB      38                     ;1
          DB      36                     ;
          DB      39                     ;
          DB      37                     ;
          DB      33                     ;
          DB      31                     ;
          DB      34                     ;
          DB      32                     ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;10
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      6                      ;
          DB      29                     ;
          DB      26                     ;
          DB      30                     ;
          DB      35                     ;
          DB      24                     ;
          DB      17                     ;
          DB      25                     ;20
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      12                     ;
          DB      21                     ;
          DB      16                     ;
          DB      5                      ;
          DB      11                     ;
          DB      20                     ;30
          DB      15                     ;
          DB      4                      ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      19                     ;
          DB      28                     ;
          DB      14                     ;
          DB      23                     ;40
          DB      27                     ;
          DB      18                     ;
          DB      22                     ;
          DB      13                     ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      2                      ;
          DB      9                      ;50
          DB      0                      ;
          DB      7                      ;
          DB      10                     ;
          DB      3                      ;
          DB      8                      ;
          DB      1                      ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;
          DB      L(NOTFOSH)             ;60
          DB      1                      ;

;THIS TABLE GIVES THE INDEX INTO THE CHALTBL, LOWREGTBL, OR HIREGTBL
;  ACCORDING TO THE SHIP'S SHIPCNT
SHIPINDX  DB      0,2,0,2,0,2,0,2,0,2,22,22
          DB      4,6,4,6,4,6,4,6,4,6,22,22
          DB      8,10,8,10,8,10,8,10,8,10,22,22
          DB      12,14,12,14,12,14,12,14,12,14,22,22
          DB      16,18,16,18,16,18,16,18,18,16,22,22
          DB      20

;THIS TABLE GIVES A CHALLENGING STAGE SEQUENCE
CHALTBL   DB      L(RACK3),H(RACK3)
          DB      L(RACK7),H(RACK7)
          DB      L(RACK11),H(RACK11)
          DB      L(RACK15),H(RACK15)
          DB      L(RACK19),H(RACK19)
          DB      L(RACK23),H(RACK23)
          DB      L(RACK27),H(RACK27)
          DB      L(RACK31),H(RACK31)

RACK3     DB      L(SHTY9),H(SHTY9)
          DB      L(SHTY8),H(SHTY8)
          DB      L(SHTY11),H(SHTY11)
          DB      L(SHTY12),H(SHTY12)
          DB      L(SHTY13),H(SHTY13)
          DB      L(SHTY13),H(SHTY13)
          DB      L(SHTY8),H(SHTY8)
          DB      L(SHTY8),H(SHTY8)
          DB      L(SHTY10),H(SHTY10)
          DB      L(SHTY10),H(SHTY10)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

RACK7     DB      L(SHTY18),H(SHTY18)
          DB      L(SHTY19),H(SHTY19)
          DB      L(SHTY20),H(SHTY20)
          DB      L(SHTY21),H(SHTY21)
          DB      L(SHTY53),H(SHTY53)
          DB      L(SHTY21),H(SHTY21)
          DB      L(SHTY19),H(SHTY19)
          DB      L(SHTY19),H(SHTY19)
          DB      L(SHTY18),H(SHTY18)
          DB      L(SHTY18),H(SHTY18)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

RACK11    DB      L(SHTY22),H(SHTY22)
          DB      L(SHTY23),H(SHTY23)
          DB      L(SHTY24),H(SHTY24)
          DB      L(SHTY25),H(SHTY25)
          DB      L(SHTY54),H(SHTY54)
          DB      L(SHTY25),H(SHTY25)
          DB      L(SHTY22),H(SHTY22)
          DB      L(SHTY23),H(SHTY23)
          DB      L(SHTY26),H(SHTY26)
          DB      L(SHTY27),H(SHTY27)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

RACK15    DB      L(SHTY29),H(SHTY29)
          DB      L(SHTY28),H(SHTY28)
          DB      L(SHTY30),H(SHTY30)
          DB      L(SHTY50),H(SHTY50)
          DB      L(SHTY31),H(SHTY31)
          DB      L(SHTY51),H(SHTY51)
          DB      L(SHTY28),H(SHTY28)
          DB      L(SHTY29),H(SHTY29)
          DB      L(SHTY32),H(SHTY32)
          DB      L(SHTY33),H(SHTY33)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

RACK19    DB      L(SHTY34),H(SHTY34)
          DB      L(SHTY34),H(SHTY34)
          DB      L(SHTY35),H(SHTY35)
          DB      L(SHTY55),H(SHTY55)
          DB      L(SHTY36),H(SHTY36)
          DB      L(SHTY36),H(SHTY36)
          DB      L(SHTY34),H(SHTY34)
          DB      L(SHTY34),H(SHTY34)
          DB      L(SHTY37),H(SHTY37)
          DB      L(SHTY37),H(SHTY37)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

RACK23    DB      L(SHTY38),H(SHTY38)
          DB      L(SHTY38),H(SHTY38)
          DB      L(SHTY39),H(SHTY39)
          DB      L(SHTY40),H(SHTY40)
          DB      L(SHTY56),H(SHTY56)
          DB      L(SHTY40),H(SHTY40)
          DB      L(SHTY41),H(SHTY41)
          DB      L(SHTY41),H(SHTY41)
          DB      L(SHTY38),H(SHTY38)
          DB      L(SHTY38),H(SHTY38)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

RACK27    DB      L(SHTY42),H(SHTY42)
          DB      L(SHTY42),H(SHTY42)
          DB      L(SHTY43),H(SHTY43)
          DB      L(SHTY57),H(SHTY57)
          DB      L(SHTY44),H(SHTY44)
          DB      L(SHTY44),H(SHTY44)
          DB      L(SHTY45),H(SHTY45)
          DB      L(SHTY45),H(SHTY45)
          DB      L(SHTY42),H(SHTY42)
          DB      L(SHTY42),H(SHTY42)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

RACK31    DB      L(SHTY46),H(SHTY46)
          DB      L(SHTY47),H(SHTY47)
          DB      L(SHTY58),H(SHTY58)
          DB      L(SHTY48),H(SHTY48)
          DB      L(SHTY49),H(SHTY49)
          DB      L(SHTY49),H(SHTY49)
          DB      L(SHTY46),H(SHTY46)
          DB      L(SHTY47),H(SHTY47)
          DB      L(SHTY46),H(SHTY46)
          DB      L(SHTY47),H(SHTY47)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

LOWREGTB  DB      L(RACK1),H(RACK1)
          DB      L(RACK2),H(RACK2)

HIREGTB   DB      L(RACK4),H(RACK4)
          DB      L(RACK5),H(RACK5)
          DB      L(RACK6),H(RACK6)

RACK6
RACK1     DB      L(SHTY3),H(SHTY3)
          DB      L(SHTY2),H(SHTY2)
          DB      L(SHTY5),H(SHTY5)
          DB      L(SHTY6),H(SHTY6)
          DB      L(SHTY7),H(SHTY7)
          DB      L(SHTY7),H(SHTY7)
          DB      L(SHTY2),H(SHTY2)
          DB      L(SHTY2),H(SHTY2)
          DB      L(SHTY4),H(SHTY4)
          DB      L(SHTY4),H(SHTY4)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

RACK5
RACK2     DB      L(SHTY3),H(SHTY3)
          DB      L(SHTY2),H(SHTY2)
          DB      L(SHTY14),H(SHTY14)
          DB      L(SHTY6),H(SHTY6)
          DB      L(SHTY15),H(SHTY15)
          DB      L(SHTY7),H(SHTY7)
          DB      L(SHTY2),H(SHTY2)
          DB      L(SHTY16),H(SHTY16)
          DB      L(SHTY17),H(SHTY17)
          DB      L(SHTY4),H(SHTY4)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)

RACK4     DB      L(SHTY3),H(SHTY3)
          DB      L(SHTY2),H(SHTY2)
          DB      L(SHTY5),H(SHTY5)
          DB      L(SHTY7),H(SHTY7)
          DB      L(SHTY6),H(SHTY6)
          DB      L(SHTY7),H(SHTY7)
          DB      L(SHTY2),H(SHTY2)
          DB      L(SHTY4),H(SHTY4)
          DB      L(SHTY2),H(SHTY2)
          DB      L(SHTY4),H(SHTY4)
          DB      L(SHTY1),H(SHTY1)
          DB      L(SHTY0),H(SHTY0)
;
;THE FOLLOWING ARE THE DEFINITIONS OF THE SHIP TYPES
;
SHTY0     DB      $00                    ;SHIP TYPE  (DOESN'T EXIST)
;
SHTY1     DB      $06                    ;SHIP TYPE  (INVISO)
          DB      72                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(MOTION1)             ;MOTION TBL PTR LOW
          DB      H(MOTION1)             ;MOTION TBL PTR HIGH
          DB      $C0                    ;MODE BYTE  (INV)
;
SHTY2     DB      $01                    ;SHIP TYPE  (BLUE)
          DB      88                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(MOTION1)             ;MOTION TBL PTR LOW
          DB      H(MOTION1)             ;MOTION TBL PTR HIGH
          DB      $80                    ;MODE BYTE  (NORMAL)
;
SHTY3     DB      $02                    ;SHIP TYPE  (RED)
          DB      72                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(MOTION1)             ;MOTION TBL PTR LOW
          DB      H(MOTION1)             ;MOTION TBL PTR HIGH
          DB      $C0                    ;MODE BYTE  (INV)
;
SHTY4     DB      $01                    ;SHIP TYPE  (BLUE)
          DB      72                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(MOTION1)             ;MOTION TBL PTR LOW
          DB      H(MOTION1)             ;MOTION TBL PTR HIGH
          DB      $C0                    ;MODE BYTE  (INV)
;
SHTY5     DB      $03                    ;SHIP TYPE  (BIG)
          DB      $F8    ;               ;BEGINNING X POS  (SIDE)
          DB      160                    ;BEGINNING Y POS
          DB      $01                    ;BEGINNING ORIENTATION
          DB      L(MOTION2)             ;MOTION TBL PTR LOW
          DB      H(MOTION2)             ;MOTION TBL PTR HIGH
          DB      $80                    ;MODE BYTE  (NORMAL)
;
SHTY6     DB      $02                    ;SHIP TYPE  (RED)
          DB      $F8   ;                ;BEGINNING X POS  (SIDE)
          DB      160                    ;BEGINNING Y POS
          DB      $01                    ;BEGINNING ORIENTATION
          DB      L(MOTION2)             ;MOTION TBL PTR LOW
          DB      H(MOTION2)             ;MOTION TBL PTR HIGH
          DB      $80                    ;MODE BYTE  (NORMAL)
;
SHTY7     DB      $02                    ;SHIP TYPE  (RED)
          DB      159                    ;BEGINNING X POS  (SIDE)
          DB      160                    ;BEGINNING Y POS
          DB      $07                    ;BEGINNING ORIENTATION
          DB      L(MOTION2)             ;MOTION TBL PTR LOW
          DB      H(MOTION2)             ;MOTION TBL PTR HIGH
          DB      $C0                    ;MODE BYTE  (INV)
;
SHTY8     DB      $01                    ;SHIP TYPE  (BLUE)
          DB      88                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(CHRACK3A)            ;MOTION TBL PTR LOW
          DB      H(CHRACK3A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)
;
SHTY9     DB      $02                    ;SHIP TYPE  (RED)
          DB      72                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(CHRACK3A)            ;MOTION TBL PTR LOW
          DB      H(CHRACK3A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)
;
SHTY10    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      72                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(CHRACK3A)            ;MOTION TBL PTR LOW
          DB      H(CHRACK3A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)
;
SHTY11    DB      $03                    ;SHIP TYPE  (BIG)
          DB      $F8    ;               ;BEGINNING X POS  (SIDE)
          DB      160                    ;BEGINNING Y POS
          DB      $02                    ;BEGINNING ORIENTATION
          DB      L(CHRACK3B)            ;MOTION TBL PTR LOW
          DB      H(CHRACK3B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)
;
SHTY12    DB      $02                    ;SHIP TYPE  (RED)
          DB      $F8  ;                 ;BEGINNING X POS  (SIDE)
          DB      160                    ;BEGINNING Y POS
          DB      $02                    ;BEGINNING ORIENTATION
          DB      L(CHRACK3B)            ;MOTION TBL PTR LOW
          DB      H(CHRACK3B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)
;
SHTY13    DB      $02                    ;SHIP TYPE  (RED)
          DB      160                    ;BEGINNING X POS  (SIDE)
          DB      160                    ;BEGINNING Y POS
          DB      $06                    ;BEGINNING ORIENTATION
          DB      L(CHRACK3B)            ;MOTION TBL PTR LOW
          DB      H(CHRACK3B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)
;
SHTY14    DB      $03                    ;SHIP TYPE  (BIG)
          DB      $F8                    ;BEGINNING X POS  (SIDE)
          DB      148                    ;BEGINNING Y POS
          DB      $01                    ;BEGINNING ORIENTATION
          DB      L(MOTION2)             ;MOTION TBL PTR LOW
          DB      H(MOTION2)             ;MOTION TBL PTR HIGH
          DB      $80                    ;MODE BYTE  (NORMAL)
;
SHTY15    DB      $02                    ;SHIP TYPE  (RED)
          DB      159                    ;BEGINNING X POS  (SIDE)
          DB      148                    ;BEGINNING Y POS
          DB      $07                    ;BEGINNING ORIENTATION
          DB      L(MOTION2)             ;MOTION TBL PTR LOW
          DB      H(MOTION2)             ;MOTION TBL PTR HIGH
          DB      $C0                    ;MODE BYTE  (INV)
;
SHTY16    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      78                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(MOTION1)             ;MOTION TBL PTR LOW
          DB      H(MOTION1)             ;MOTION TBL PTR HIGH
          DB      $80                    ;MODE BYTE  (NORMAL)
;
SHTY17    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      82                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(MOTION1)             ;MOTION TBL PTR LOW
          DB      H(MOTION1)             ;MOTION TBL PTR HIGH
          DB      $C0                    ;MODE BYTE  (INV)
;
SHTY18    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      72                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRACK7A)            ;MOTION TBL PTR LOW
          DB      H(CHRACK7A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)
;
SHTY19    DB      $02                    ;SHIP TYPE  (RED)
          DB      88                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRACK7A)            ;MOTION TBL PTR LOW
          DB      H(CHRACK7A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)
;
SHTY20    DB      3                      ;SHIP TYPE  (BOS)
          DB      $F8                    ;BEGINNING X POS  (TOP)
          DB      160                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRACK7B)            ;MOTION TBL PTR LOW
          DB      H(CHRACK7B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)
;
SHTY21    DB      $02                    ;SHIP TYPE  (RED)
          DB      159                    ;BEGINNING X POS  (TOP)
          DB      160                    ;BEGINNING Y POS
          DB      6                      ;BEGINNING ORIENTATION
          DB      L(CHRACK7B)            ;MOTION TBL PTR LOW
          DB      H(CHRACK7B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY22    DB      $02                    ;SHIP TYPE  (RED)
          DB      70                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRACK7A)            ;MOTION TBL PTR LOW
          DB      H(CHRACK7A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY23    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      70                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRACK7A)            ;MOTION TBL PTR LOW
          DB      H(CHRACK7A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY24    DB      $03                    ;SHIP TYPE  (BOSS)
          DB      $F8                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRCK11B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK11B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY25    DB      $02                    ;SHIP TYPE  (RED)
          DB      162                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      6                      ;BEGINNING ORIENTATION
          DB      L(CHRCK11B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK11B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY26    DB      $02                    ;SHIP TYPE  (RED)
          DB      90                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRACK7A)            ;MOTION TBL PTR LOW
          DB      H(CHRACK7A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY27    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      90                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRACK7A)            ;MOTION TBL PTR LOW
          DB      H(CHRACK7A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY28    DB      $02                    ;SHIP TYPE  (RED)
          DB      70                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK15A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK15A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY29    DB      13                    ;SHIP TYPE  (SCORPION)
          DB      70                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK15A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK15A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY30    DB      $03                    ;SHIP TYPE  (BOSS)
          DB      $F8                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      1                      ;BEGINNING ORIENTATION
          DB      L(CHRCK15B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK15B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY31    DB      50                     ;SHIP TYPE  (NEWBIRD)
          DB      160                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      7                      ;BEGINNING ORIENTATION
          DB      L(CHRCK15B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK15B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY32    DB      13                     ;SHIP TYPE  (RED)
          DB      92                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK15A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK15A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY33    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      92                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK15A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK15A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY34    DB      50                     ;SHIP TYPE  (NEWBIRD)
          DB      90                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      5                      ;BEGINNING ORIENTATION
          DB      L(CHRCK19A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK19A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY35    DB      $02                    ;SHIP TYPE  (RED)
          DB      $F8                    ;BEGINNING X POS
          DB      140                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRCK19B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK19B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY36    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      160                    ;BEGINNING X POS
          DB      140                    ;BEGINNING Y POS
          DB      6                      ;BEGINNING ORIENTATION
          DB      L(CHRCK19B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK19B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY37    DB      $02                    ;SHIP TYPE  (RED)
          DB      70                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      3                      ;BEGINNING ORIENTATION
          DB      L(CHRCK19A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK19A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY38    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      76                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK23A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK23A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY39    DB      $03                    ;SHIP TYPE  (BOSS)
          DB      $F8                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRCK23B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK23B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY40    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      160                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      6                      ;BEGINNING ORIENTATION
          DB      L(CHRCK23B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK23B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY41    DB      $02                    ;SHIP TYPE  (RED)
          DB      84                     ;BEGINNING X POS
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK23A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK23A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY42    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      76                     ;BEGINNING X POS
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK27A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK27A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY43    DB      $02                    ;SHIP TYPE  (RED)
          DB      $F8                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRCK27B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK27B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY44    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      160                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      6                      ;BEGINNING ORIENTATION
          DB      L(CHRCK27B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK27B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY45    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      84                     ;BEGINNING X POS
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK27A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK27A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY46    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      88                     ;BEGINNING X POS
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK31A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK31A)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY47    DB      $02                    ;SHIP TYPE  (RED)
          DB      68                     ;BEGINNING X POS
          DB      $FA                    ;BEGINNING Y POS
          DB      4                      ;BEGINNING ORIENTATION
          DB      L(CHRCK31A)            ;MOTION TBL PTR LOW
          DB      H(CHRCK31A)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY48    DB      $01                    ;SHIP TYPE  (BLUE)
          DB      $FA                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      1                      ;BEGINNING ORIENTATION
          DB      L(CHRCK31B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK31B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY49    DB      $02                    ;SHIP TYPE  (RED)
          DB      160                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      7                      ;BEGINNING ORIENTATION
          DB      L(CHRCK31B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK31B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY50    DB      2                      ;SHIP TYPE  (RED)
          DB      $F8                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      1                      ;BEGINNING ORIENTATION
          DB      L(CHRCK15B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK15B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY51    DB      2                      ;SHIP TYPE  (RED)
          DB      160                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      7                      ;BEGINNING ORIENTATION
          DB      L(CHRCK15B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK15B)            ;MOTION TBL PTR HIGH
          DB      $C9                    ;MODE BYTE  (INV)

SHTY52    DB      5                      ;SHIP TYPE  (HERO)
          DB      72                     ;BEGINNING X POS  (TOP)
          DB      $FA                    ;BEGINNING Y POS
          DB      $04                    ;BEGINNING ORIENTATION
          DB      L(MOTION1)             ;MOTION TBL PTR LOW
          DB      H(MOTION1)             ;MOTION TBL PTR HIGH
          DB      $C0                    ;MODE BYTE  (INV)
;
SHTY53    DB      1                      ;SHIP TYPE
          DB      $F8                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRACK7B)            ;MOTION TBL PTR LOW
          DB      H(CHRACK7B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY54    DB      1                      ;SHIP TYPE
          DB      $F8                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRCK11B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK11B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY55    DB      $03                    ;SHIP TYPE
          DB      $F8                    ;BEGINNING X POS
          DB      140                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRCK19B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK19B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY56    DB      2                      ;SHIP TYPE  (RED)
          DB      $F8                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRCK23B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK23B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY57    DB      3                      ;SHIP TYPE
          DB      $F8                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      2                      ;BEGINNING ORIENTATION
          DB      L(CHRCK27B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK27B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

SHTY58    DB      $03                    ;SHIP TYPE
          DB      $FA                    ;BEGINNING X POS
          DB      160                    ;BEGINNING Y POS
          DB      1                      ;BEGINNING ORIENTATION
          DB      L(CHRCK31B)            ;MOTION TBL PTR LOW
          DB      H(CHRCK31B)            ;MOTION TBL PTR HIGH
          DB      $89                    ;MODE BYTE  (NORMAL)

