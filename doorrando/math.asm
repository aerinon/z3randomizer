;divide by 2 example
;    0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f  10--Offset Ruler
;v  00  01  01  02  02  03  03  04  04  04  05  05  06  06  07  07  08

;divide by 3 example
; 0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f 10 11 12 13 14 15 16 17 18
;00 00 01 01 01 02 02 02 03 03 03 04 04 04 05 05 05 06 06 06 07 07 07 08 08

MultiplyByY:
.loop cpy.w #$0001 : beq .done
cpy.w #$0003 : bne ++
    jsr MultiBy3 : bra .done
++ cpy.w #$0005 : bne ++
    jsr MultiBy5 : bra .done
++ asl : sta.b Scrap00 : tya : lsr : tay : lda.b Scrap00 : bra .loop
.done rts

;Divisor in Y. Width of division is in X for rounding toward middle
DivideByY:
.loop
cpy.w #$0000 : beq .done
cpy.w #$0001 : beq .done
cpy.w #$0003 : bne ++
    jsr DivideBy3 : bra .done
++ cpy.w #$0005 : bne ++
    jsr DivideBy5 : bra .done
++ jsr DivideBy2 : sta.b Scrap00
tya : lsr : tay
txa : lsr : tax
lda.b Scrap00 : bra .loop
.done rts

MultiBy3:
sta.b Scrap00 : asl : !ADD.b Scrap00
rts

MultiBy5:
sta.b Scrap00 : asl #2 : !ADD.b Scrap00
rts

;width of divison in x: rounds toward X/2
DivideBy2:
sta.b Scrap00
lsr : bcc .done
sta.b Scrap02 : txa : lsr : cmp.b Scrap00 : !BLT +
    lda.b Scrap02 : inc : bra .done
+ lda.b Scrap02
.done rts

DivideBy3:
sta.b Scrap00
ldx.w #$0000
lda.w #$0002
.loop cmp.b Scrap00 : !BGE .store
    inx : !ADD.w #$0003 : bra .loop
.store txa
rts

DivideBy5:
sta.b Scrap00
ldx.w #$0000
lda.w #$0003
.loop cmp.b Scrap00 : !BGE .store
    inx : !ADD.w #$0005 : bra .loop
.store txa
rts