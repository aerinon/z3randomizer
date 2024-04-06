AdjustTransition:
{
	lda.b $ab : and.w #$01ff : beq .reset
	phy : ldy.b #$06 ; operating on vertical registers during horizontal trans
	cpx.b #$02 : bcs .horizontalScrolling
	ldy.b #$00  ; operate on horizontal regs during vert trans
	.horizontalScrolling
	cmp.w #$0008 : bcs +
	    pha : lda.b $ab : and.w #$0200 : beq ++
	        pla : bra .add
	    ++ pla : eor.w #$ffff : inc ; convert to negative
	    .add jsr AdjustCamAdd : ply : bra .reset
	+ lda.b $ab : and.w #$0200 : xba : tax
	lda.l OffsetTable,x : jsr AdjustCamAdd
	lda.b $ab : !SUB.w #$0008 : sta.b $ab
	ply : bra .done
	.reset ; clear the $ab variable so to not disturb intra-tile doors
	stz.b $ab
	.done
	lda.b Scrap00 : and.w #$01fc
	rtl
}

AdjustCamAdd:
    !ADD.w $00E2,y : pha
    and.w #$01ff : cmp.w #$0111 : !BLT +
        cmp.w #$01f8 : !BGE ++
            pla : and.w #$ff10 : pha : bra +
        ++ pla : and.w #$ff00 : !ADD.w #$0100 : pha
    + pla : sta.w $00E2,y : sta.w $00E0,y : rts

; expects target quad in $05 (either 0 or 1) and target pixel in $04, target room should be in $a0
; $06 is either $ff or $01/02
; uses $00-$03 and $0e for calculation
; also set up $ac
ScrollY: ;change the Y offset variables
    lda.b RoomIndex : and.b #$f0 : lsr #3 : sta.w $0603 : inc : sta.w $0607

    lda.b Scrap05 : bne +
        lda.w $0603 : sta.b Scrap00 : stz.b Scrap01 : bra ++
    +   lda.w $0607 : sta.b Scrap00 : lda.b #$02 : sta.b Scrap01
    ++ ; $01 now contains 0 or 2 and $00 contains the correct lat

    stz.b Scrap0E
    rep #$30
    lda.b Scrap00 : pha

    lda.b BG2V : and.w #$01ff : sta.b Scrap02
    lda.b Scrap04 : jsr LimitYCamera : sta.b Scrap00
    jsr CheckRoomLayoutY : bcc +
        lda.b Scrap00 : cmp.w #$0080 : !BGE ++
            cmp.w #$0010 : !BLT .cmpSrll
                lda.w #$0010 : bra .cmpSrll
        ++ cmp.w #$0100 : !BGE .cmpSrll
            lda.w #$0100
    .cmpSrll sta.b Scrap00

    ; figures out scroll amt
    + lda.b Scrap00 : cmp.b Scrap02 : bne +
        lda.w #$0000 : bra .next
    + !BLT +
        !SUB.b Scrap02 : inc.b Scrap0E : bra .next
    + lda.b Scrap02 : !SUB.b Scrap00

    .next
    sta.b $ab
    jsr AdjustCameraBoundsY

    pla : sta.b Scrap00
    sep #$30
    lda.b Scrap04 : sta.b $20
    lda.b Scrap00 : sta.b $21 : sta.w $0601 : sta.w $0605
    lda.b Scrap01 : sta.b $aa
    lda.b Scrap0E : asl : ora.b $ac : sta.b $ac
    lda.b BG2V+1 : and.b #$01 : asl #2 : tax : lda.w $0603, x : sta.b BG2V+1
    rts

LimitYCamera:
    cmp.w #$006c : !BGE +
        lda.w #$0000 : bra .end
    + cmp.w #$017d : !BLT +
        lda.w #$0110 : bra .end
    + !SUB.w #$006c
    .end rts

CheckRoomLayoutY:
    jsr LoadRoomLayout ;switches to 8-bit
    cmp.b #$00 : beq .lock
    cmp.b #$07 : beq .free
    cmp.b #$01 : beq .free
    cmp.b #$04 : !BGE .lock
    cmp.b #$02 : bne +
        lda.b Scrap06 : cmp.b #$ff : beq .lock
    + cmp.b #$03 : bne .free
        lda.b Scrap06 : cmp.b #$ff : bne .lock
    .free rep #$30 : clc : rts
    .lock rep #$30 : sec : rts

AdjustCameraBoundsY:
    jsr CheckRoomLayoutY : bcc .free

    ; layouts that are camera locked (quads only)
    lda.b Scrap04 : and.w #$00ff : cmp.w #$007d : !BLT +
        lda.w #$0088 : bra ++
    + cmp.w #$006d : !BGE +
        lda.w #$0078 : bra ++
    + !ADD.w #$000b

    ; I think we no longer need the $02 variable
    ++ sta.b Scrap02 : lda.b Scrap04 : and.w #$0100 : !ADD.b Scrap02 : bra .setBounds

    ; layouts where the camera is free
    .free lda.b Scrap04 : cmp.w #$006c : !BGE +
        lda.w #$0077 : bra .setBounds
    + cmp.w #$017c : !BLT +
        lda.w #$0187 : bra .setBounds
    + !ADD.w #$000b
    .setBounds sta.w $0618 : inc #2 : sta.w $061a
    rts

LoadRoomLayout:
    lda.b RoomIndex : asl : !ADD.b RoomIndex : tax
    lda.l RoomData_ObjectDataPointers+1, x : sta.b $b8
    lda.l RoomData_ObjectDataPointers, x : sta.b $b7
    sep #$30
    ldy.b #$01 : lda.b [$b7], y : and.b #$1c : lsr #2
    rts

; expects target quad in $05 (either 0 or 1) and target pixel in $04, target room should be in $a0
; uses $00-$03 and $0e for calculation
; also set up $ac
ScrollX: ;change the X offset variables
    lda.b RoomIndex : and.b #$0f : asl : sta.w $060b : inc : sta.w $060f

    lda.b Scrap05 : bne +
        lda.w $060b : sta.b Scrap00 : stz.b Scrap01 : bra ++
    +   lda.w $060f : sta.b Scrap00 : lda.b #$01 : sta.b Scrap01
    ++ ; $01 now contains 0 or 1 and $00 contains the correct long

    stz.b Scrap0E ; pos/neg indicator
    rep #$30
    lda.b Scrap00 : pha

    lda.b BG2H : and.w #$01ff : sta.b Scrap02
    lda.b Scrap04 : jsr LimitXCamera : sta.b Scrap00
    jsr CheckRoomLayoutX : bcc +
        lda.b Scrap00 : cmp.w #$0080 : !BGE ++
            lda.w #$0000 : bra .cmpSrll
        ++ lda.w #$0100
    .cmpSrll sta.b Scrap00

    ;figures out scroll amt
    + lda.b Scrap00 : cmp.b Scrap02 : bne +
        lda.w #$0000 : bra .next
    + !BLT +
        !SUB.b Scrap02 : inc.b Scrap0E : bra .next
    + lda.b Scrap02 : !SUB.b Scrap00

    .next
    sta.b $ab : lda.b Scrap04

    cmp.w #$0078 : !BGE +
        lda.w #$007f : bra ++
    + cmp.w #$0178 : !BLT +
        lda.w #$017f : bra ++
    + !ADD.w #$0007
    ++ sta.w $061c : inc #2 : sta.w $061e

    pla : sta.b Scrap00
    sep #$30
    lda.b Scrap04 : ldx.w $046d : bne .straight
        sta.b LinkPosX : bra +
    .straight
        sta.w $046d ; set X position later
    +
    lda.b Scrap00 : sta.b LinkPosX+1 : sta.w $0609 : sta.w $060d
    lda.b Scrap01 : sta.b LinkQuadrantH
    lda.b Scrap0E : asl : ora.b $ac : sta.b $ac
    lda.b BG2H+1 : and.b #$01 : asl #2 : tax : lda.w $060b, x : sta.b BG2H+1

    rts

LimitXCamera:
    cmp.w #$0079 : !BGE +
        lda.w #$0000 : bra .end
    + cmp.w #$0178 : !BLT +
        lda.w #$0178
    + !SUB.w #$0078
    .end rts

CheckRoomLayoutX:
    jsr LoadRoomLayout ;switches to 8-bit
    cmp.b #$04 : !BLT .lock
    cmp.b #$05 : bne +
        lda.b Scrap06 : cmp.b #$ff : beq .lock
    + cmp.b #$06 : bne .free
        lda.b Scrap06 : cmp.b #$ff : bne .lock
    .free rep #$30 : clc : rts
    .lock rep #$30 : sec : rts

ApplyScroll:
    rep #$30
    lda.b $ab : and.w #$01ff : sta.b Scrap00
    lda.b $ab : and.w #$0200 : beq +
        lda.w $00e2, y : !ADD.b Scrap00 : bra .end
    + lda.w $00e2, y : !SUB.b Scrap00
    .end
    sta.w $00e2, y
    sta.w $00e0, y
    stz.b $ab : sep #$30 : rts

QuadrantLoadOrderBeforeScroll:
    lda.w $045f : beq .end
    lda.b #$08 : sta.w $045c ; start with opposite quadrant row
    .end
    JML WaterFlood_BuildOneQuadrantForVRAM ; what we overwrote

QuadrantLoadOrderAfterScroll:
    lda.w $045f : beq .end
    stz.w $045c : stz.w $045f ; draw other row and clear flag
    .end
    JML WaterFlood_BuildOneQuadrantForVRAM ; what we overwrote