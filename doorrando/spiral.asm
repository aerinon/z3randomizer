RecordStairType: {
    pha
    lda.l DRMode : beq .norm
 	REP #$30 : LDA.b PreviousRoom : CMP.w #$00E1 : BCS .norm
	CMP.w #$00DF : BEQ .norm
	SEP #$30
        lda.b Scrap0E
        cmp.b #$25 : bcc ++ ; don't record straight staircases
            sta.w $045e
        ++ pla : bra +
    .norm SEP #$30 : pla : sta.b RoomIndex
    + lda.w $063d, x
    rtl
}

SpiralWarp: {
    lda.l DRMode : beq .abort ; abort if not DR
    REP #$30 : LDA.b PreviousRoom : CMP.w #$00E1 : BCS .abort
    CMP.w #$00DF : BEQ .abort
    SEP #$30
    lda.w $045e : cmp.b #$5e : beq .gtg ; abort if not spiral - intended room is in A!
    cmp.b #$5f : beq .gtg
    cmp.b #$26 : beq .inroom
    .abort
    SEP #$30 : stz.w $045e : lda.b PreviousRoom : and.b #$0f : rtl ; clear,run hijacked code and get out
    .inroom
    jsr InroomStairsWarp
    lda.b PreviousRoom : and.b #$0f ; this is the code we are hijacking
    rtl

    .gtg
    phb : phk : plb : phx : phy ; push stuff
    jsr LookupSpiralOffset
    rep #$30 : and.w #$00FF : asl #2 : tax
    lda.w SpiralTable, x : sta.b Scrap00
    lda.w SpiralTable+2, x : sta.b Scrap02
    sep #$30
    lda.b Scrap00 : sta.b RoomIndex
    ; shift quadrant if necessary
    stz.b Scrap07 ; this is a x quad adjuster for those blasted staircase on the edges
    lda.b Scrap01 : and.b #$01 : !SUB.b LinkQuadrantH
    bne .xQuad
    lda.w $0462 : and.b #$04 : bne .xqCont
    inc.b Scrap07
    .xqCont lda.b LinkPosX : bne .skipXQuad ; this is an edge case
    dec.b LinkPosX+1 : bra .skipXQuad ; need to -1 if $22 is 0
    .xQuad sta.b Scrap06 : !ADD.b LinkQuadrantH : sta.b LinkQuadrantH
    lda.w $0462 : and.b #$04 : bne .xCont
    inc.b Scrap07 ; up stairs are going to -1 the quad anyway during transition, need to add this back
    .xCont ldy.b #$00 : jsr ShiftQuadSimple

    .skipXQuad
    lda.b LinkQuadrantV : lsr : sta.b Scrap06 : lda.b Scrap01 : and.b #$02 : lsr : !SUB.b Scrap06
    beq .skipYQuad
    sta.b Scrap06 : asl : !ADD.b LinkQuadrantV : sta.b LinkQuadrantV
    ldy.b #$01 : jsr ShiftQuadSimple

    .skipYQuad
    lda.b Scrap01 : and.b #$04 : lsr : sta.w $048a ;fix layer calc 0->0 2->1
    lda.b Scrap01 : and.b #$08 : lsr #2 : sta.w $0492 ;fix from layer calc 0->0 2->1
    ; shift lower coordinates
    lda.b Scrap02 : sta.b LinkPosX : bne .adjY : lda.b LinkPosX+1 : !ADD.b Scrap07 : sta.b LinkPosX+1
    .adjY lda.b Scrap03 : sta.b LinkPosY : bne .upDownAdj : inc.b LinkPosY+1
    .upDownAdj ldx.b #$08
    lda.w $0462 : and.b #$04 : beq .upStairs
    ldx.b #$fd
    lda.b Scrap01 : and.b #$80 : bne .set53
    ; if target is also down adjust by (6,-15)
    lda.b #$06 : !ADD.b LinkPosY : sta.b LinkPosY : lda.b #$eb : !ADD.b LinkPosX : sta.b LinkPosX : bra .set53
    .upStairs
    lda.b Scrap01 : and.b #$80 : beq .set53
    ; if target is also up adjust by (-6, 14)
    lda.b #$fa : !ADD.b LinkPosY : sta.b LinkPosY : lda.b #$14 : !ADD.b LinkPosX : sta.b LinkPosX
    bne .set53 : inc.b LinkPosX+1
    .set53
    txa : !ADD.b LinkPosX : sta.b $53

    lda.b Scrap01 : and.b #$10 : sta.b Scrap07 ; zeroHzCam check
    ldy.b #$00 : jsr SetCamera
    lda.b Scrap01 : and.b #$20 : sta.b Scrap07 ; zeroVtCam check
    ldy.b #$01 : jsr SetCamera

    jsr StairCleanup
    ply : plx : plb ; pull the stuff we pushed
    lda.b PreviousRoom : and.b #$0f ; this is the code we are hijacking
    rtl
}

StairCleanup: {
    stz.w $045e ; clear the staircase flag

    ; animated tiles fix
    lda.l DRMode : cmp.b #$02 : bne + ; only do this in crossed mode
        ldx.b RoomIndex : lda.l TilesetTable, x
        cmp.w $0aa1 : beq + ; already eq no need to decomp
            sta.w $0aa1
            tax : lda.l AnimatedTileSheets, x : tay
            jsl DecompDungAnimatedTiles
    +
    stz.w LayerAdjustment
    rts
}

LookupSpiralOffset_long:
    PHB : PHK : PLB
    JSR LookupSpiralOffset
    PLB : RTL

;Sets the offset in A
LookupSpiralOffset: {
    ;where link currently is in $a2: quad in a8 & #$03
    ;count doors
    stz.b Scrap00 : ldx.b #$00 : stz.b Scrap01

    .loop
    lda.w $047e, x : cmp.b Scrap00 : bcc .continue
    sta.b Scrap00
    .continue inx #2
    cpx.b #$08 : bcc .loop

    lda.b Scrap00 : lsr
    cmp.b #$01 : beq .done

    ; look up the quad
    lda.b LinkQuadrantH : ora.b LinkQuadrantV : and.b #$03 : beq .quad0
    cmp.b #$01 : beq .quad1
    cmp.b #$02 : beq .quad2
    bra .quad3
    .quad0
    inc.b Scrap01 : lda.b PreviousRoom
    cmp.b #$0c : beq .q0diff ;gt ent
    cmp.b #$70 : bne .done   ;hc stairwell
    .q0diff lda.b LinkPosX : cmp.b #$00 : beq .secondDoor
    cmp.b #$98 : bcc .done ;gt ent and hc stairwell
    .secondDoor inc.b Scrap01 : bra .done
    .quad1
    lda.b PreviousRoom
    cmp.b #$1a : beq .q1diff ;pod compass
    cmp.b #$26 : beq .q1diff ;swamp elbows
    cmp.b #$6a : beq .q1diff ;pod dark basement
    cmp.b #$76 : bne .done   ;swamp drain
    .q1diff lda.b LinkPosX : cmp.b #$98 : bcc .done
    inc.b Scrap01 : bra .done
    .quad2
    lda.b #$03 : sta.b Scrap01 : lda.b PreviousRoom
    cmp.b #$5f : beq .iceu ;ice u room
    cmp.b #$3f : bne .done ;hammer ice exception
    stz.b Scrap01 : bra .done
    .iceu lda.b LinkPosX : cmp.b #$78 : bcc .done
    inc.b Scrap01 : bra .done
    .quad3
    lda.b PreviousRoom : cmp.b #$40 : beq .done ; top of aga exception
    lda.b #$02 : sta.b Scrap01 ; always 2

    .done
    lda.b PreviousRoom : tax : lda.w SpiralOffset,x
    !ADD.b Scrap01 ;add a thing (0 in easy case)
    rts
}

InroomStairsWarp: {
    phb : phk : plb : phx : phy ; push stuff
    ; find stairs by room and store index in X
    lda.b RoomIndex : ldx.b #$07
    .loop
        cmp.w InroomStairsRoom,x
        beq .found
        dex
        bne .loop
    .found
    rep #$30
    txa : and.w #$00ff : asl : tay
    lda.w InroomStairsTable,y : sta.b Scrap00
	sep #$30
    sta.b RoomIndex

    ; set position and everything else based on target door type
    txa : and.b #$01 : eor.b #$01 : sta.b Scrap07
    ; should be the same as lda $0462 : and #$04 : lsr #2 : eor #$01 : sta $07
    lda.b Scrap01 : and.b #$80 : beq .notEdge
        lda.b Scrap07 : sta.b Scrap03 : beq +
            lda.b Scrap01 : jsr LoadSouthMidpoint : sta.b LinkPosX : lda.b #$f4
            bra ++
        +
            lda.b Scrap01 : jsr LoadNorthMidpoint : sta.b LinkPosX : dec.b LinkPosY+1 : lda.b #$f7
        ++
        sta.b LinkPosY
        lda.b Scrap01 : and.b #$20 : beq +
            lda.b #$01
        +
        sta.b Scrap02
        stz.b Scrap07
        lda.b Scrap01 : and.b #$10 : lsr #4
        JMP .layer
    .notEdge
    lda.b Scrap01 : and.b #$03 : cmp.b #$03 : bne .normal
        txa : and.b #$06 : sta.b Scrap07
        lda.b Scrap01 : and.b #$30 : lsr #3 : tay
        lda.w InroomStairsX+1,y : sta.b Scrap02
        lda.w InroomStairsY+1,y : sta.b Scrap03
        cpy.b Scrap07 : beq .vanillaTransition
            lda.w InroomStairsX,y : sta.b LinkPosX
            lda.w InroomStairsY,y
            ldy.b Scrap07 : beq +
                !ADD.b #$07
            +
            sta.b LinkPosY
            inc.b Scrap07
            bra ++
        .vanillaTransition
            lda.b #$c0 : sta.b Scrap07 ; leave camera
        ++
        %StonewallCheck($1b)
        lda.b Scrap01 : and.b #$04 : lsr #2
        bra .layer
    .normal
        lda.b Scrap01 : sta.b $fe ; trap door
        lda.b Scrap07 : sta.b Scrap03 : beq +
            lda.b Scrap01 : and.b #$04 : bne .specialFix
            lda.b #$e0 : bra ++
            .specialFix
            lda.b #$c8 : bra ++
        +
            %StonewallCheck($43)
            lda.b Scrap01 : and.b #$04 : bne +
            lda.b #$1b : bra ++
            + lda.b #$33
        ++ sta.b LinkPosY
        inc.b Scrap07 : stz.b Scrap02 : lda.b #$78 : sta.b LinkPosX
        lda.b Scrap01 : and.b #$03 : beq ++
            cmp.b #$02 : !BGE +
                lda.b #$f8 : sta.b LinkPosX : stz.b Scrap07 : bra ++
            + inc.b Scrap02
        ++
        lda.b Scrap01 : and.b #$04 : lsr #2

    .layer
    sta.b LinkLayer
    bne +
    	stz.w $0476
    +

    lda.b Scrap02 : !SUB.b LinkQuadrantH
    beq .skipXQuad
        sta.b Scrap06 : !ADD.b LinkQuadrantH : sta.b LinkQuadrantH
        ldy.b #$00 : jsr ShiftQuadSimple
    .skipXQuad
    lda.b LinkQuadrantV : lsr : sta.b Scrap06 : lda.b Scrap03 : !SUB.b Scrap06
    beq .skipYQuad
        sta.b Scrap06 : asl : !ADD.b LinkQuadrantV : sta.b LinkQuadrantV
        ldy.b #$01 : jsr ShiftQuadSimple
    .skipYQuad

    lda.b Scrap07 : bmi .skipCamera
    ldy.b #$00 : jsr SetCamera ; horizontal camera
    ldy.b #$01 : sty.b Scrap07 : jsr SetCamera ; vertical camera
    lda.b LinkPosY : cmp.b #$e0 : bcc +
    lda.b BG2V : bne +
        lda.b #$10 : sta.b BG2V ; adjust vertical camera at bottom
    +
    .skipCamera

    jsr StairCleanup
    ply : plx : plb ; pull the stuff we pushed
    rts
}

ShiftQuadSimple: {
	lda.w CoordIndex,y : tax
	lda.b LinkPosY,x : beq .skip
	lda.b LinkPosY+1,x : !ADD.b Scrap06 : sta.b LinkPosY+1,x ; coordinate update
	.skip
	lda.w CamQuadIndex,y : tax
	lda.w $0601,x : !ADD.b Scrap06 : sta.w $0601,x
	lda.w $0605,x : !ADD.b Scrap06 : sta.w $0605,x ; high bytes of these guys
	rts
}

SetCamera: {
    stz.b Scrap04
    tyx : lda.b LinkQuadrantH,x : bne .nonZeroHalf
    lda.w CamQuadIndex,y : tax : lda.w $0607,x : pha
    lda.w CameraIndex,y : tax : pla : cmp.b BG2H+1, x : bne .noQuadAdj
    dec.b BG2H+1,x

    .noQuadAdj
    lda.b Scrap07 : bne .adj0
    lda.w CoordIndex,y : tax
    lda.b LinkPosY,x : beq .oddQuad
    cmp.b #$79 : bcc .adj0
    !SUB.b #$78 : sta.b Scrap04
    tya : asl : !ADD.b #$04 : tax : jsr AdjCamBounds : bra .done
    .oddQuad
    lda.b #$80 : sta.b Scrap04 : bra .adj1 ; this is such a weird case - quad cross boundary
    .adj0
    tya : asl : tax : jsr AdjCamBounds : bra .done

    .nonZeroHalf ;meaning either right half or bottom half
    lda.b Scrap07 : bne .setQuad
    lda.w CoordIndex,y : tax
    lda.b LinkPosY,x : cmp.b #$78 : bcs .setQuad
    !ADD.b #$78 : sta.b Scrap04
    lda.w CamQuadIndex,y : tax : lda.w $0603, x : pha
    lda.w CameraIndex,y : tax : pla : sta.b BG2H+1, x
    .adj1
    tya : asl : !ADD.b #$08 : tax : jsr AdjCamBounds : bra .done

    .setQuad
    lda.w CamQuadIndex,y : tax : lda.w $0607, x : pha
    lda.w CameraIndex,y : tax : pla : sta.b BG2H+1, x
    tya : asl : !ADD.b #$0c : tax : jsr AdjCamBounds : bra .done

    .done
    lda.w CameraIndex,y : tax
    lda.b Scrap04 : sta.b BG2H, x
    rts
}

; input, expects X to be an appropriate offset into the CamBoundBaseLine table
; when $04 is 0 no coordinate are added
AdjCamBounds: {
    rep #$20 : lda.w CamBoundBaseLine, x : sta.b Scrap05
    lda.b Scrap04 : and.w #$00ff : beq .common
    lda.w CoordIndex,y : tax
    lda.b LinkPosY, x : and.w #$00ff : !ADD.b Scrap05 : sta.b Scrap05
    .common
    lda.w OppCamBoundIndex,y : tax
    lda.b Scrap05 : sta.w CameraScrollN, x
    inc #2 : sta.w CameraScrollS, x : sep #$20
    rts
}

SpiralPriorityHack: {
    lda.l DRMode : beq +
        lda.b #$01 : rtl ; always skip the priority code - until I figure out how to fix it
    + lda.w $0462 : and.b #$04 ; what we wrote over
    rtl
}