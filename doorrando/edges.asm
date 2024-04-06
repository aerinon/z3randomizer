; defines
; Ram usage

HorzEdge:
    cpy.b #$ff : beq +
        jsr DetectWestEdge : ldy.b #$02 : bra ++
    + jsr DetectEastEdge
    ++ cmp.b #$ff : beq +
        sta.b Scrap00 : asl : !ADD.b Scrap00 : tax
        cpy.b #$ff : beq ++
            jsr LoadWestData : bra .main
        ++ jsr LoadEastData
        .main
        jsr LoadEdgeRoomHorz
        sec : rts
    + clc : rts

VertEdge:
    cpy.b #$ff : beq +
        jsr DetectNorthEdge : bra ++
    + jsr DetectSouthEdge
    ++ cmp.b #$ff : beq +
        sta.b Scrap00 : asl : !ADD.b Scrap00 : tax
        cpy.b #$ff : beq ++
            jsr LoadNorthData : bra .main
        ++ jsr LoadSouthData
        .main
        jsr LoadEdgeRoomVert
        sec : rts
    + clc : rts

LoadEdgeRoomHorz:
    lda.b Scrap03 : sta.b RoomIndex
    sty.b Scrap06
    and.b #$0f : asl a : !SUB.b LinkPosX+1 : !ADD.b Scrap06 : sta.b Scrap02
    ldy.b #$00 : jsr ShiftVariablesMainDir

    lda.b Scrap04 : and.b #$80 : bne .edge
    lda.b Scrap04 : sta.b Scrap01 ; load up flags in $01
    jsr PrepScrollToNormal
    bra .scroll

    .edge
    lda.b Scrap04 : and.b #$10 : beq +
       lda.b #$01
    + sta.b LinkLayer ; layer stuff

    jsr MathHorz

    .scroll
    jsr ScrollY
    rts

LoadEdgeRoomVert:
    lda.b Scrap03 : sta.b RoomIndex
    sty.b Scrap06
    and.b #$f0 : lsr #3 : !SUB.b LinkPosY+1 : !ADD.b Scrap06 : sta.b Scrap02

    lda.b Scrap04 : and.b #$80 : bne .edge
    lda.b Scrap04 : sta.b Scrap01 ; load up flags in $01
    and.b #$03 : cmp.b #$03 : beq .inroom
    ldy.b #$01 : jsr ShiftVariablesMainDir
    jsr PrepScrollToNormal
    bra .scroll

    .inroom
    jsr ScrollToInroomStairs
    rts

    .edge
    ldy.b #$01 : jsr ShiftVariablesMainDir
    lda.b Scrap04 : and.b #$10 : beq +
       lda.b #$01
    + sta.b LinkLayer ; layer stuff

    jsr MathVert
    lda.b Scrap03

    .scroll
    jsr ScrollX
    rts


MathHorz:
    jsr MathStart : lda.b LinkPosY
    jsr MathMid : and.w #$0040
    jsr MathEnd
    rts

MathVert:
    jsr MathStart : lda.b LinkPosX
    jsr MathMid : and.w #$0020
    jsr MathEnd
    rts

MathStart:
    rep #$30
    lda.b Scrap08 : and.w #$00ff : sta.b Scrap00
    rts

MathMid:
    and.w #$01ff : !SUB.b Scrap00 : and.w #$00ff : sta.b Scrap00
    ; nothing should be bigger than $a0 at this point

    lda.b Scrap05 : and.w #$00f0 : lsr #4 : tax
    lda.w MultDivInfo, x : and.w #$00ff : tay
    lda.b Scrap00 : jsr MultiplyByY : sta.b Scrap02

    lda.b Scrap07 : and.w #$00ff : jsr MultiplyByY : tax

    lda.b Scrap05 : and.w #$000f : tay
    lda.w MultDivInfo, y : and.w #$00ff : tay
    lda.b Scrap02 : jsr DivideByY : sta.b Scrap00
    lda.b Scrap0C : and.w #$00ff : sta.b Scrap02
    lda.b Scrap04
    rts

MathEnd:
     beq +
        lda.w #$0100
    + !ADD.b Scrap02 : !ADD.b Scrap00
    sta.b Scrap04
    sep #$30
    rts

; don't need midpoint of edge Link is leaving (formerly in $06 - used by dir indicator)
; don't need width of edge Link is going to (currently in $0b)
LoadNorthData:
    lda.w NorthOpenEdge, x : sta.b Scrap03 : inx ; target room
    lda.w NorthEdgeInfo, x : sta.b Scrap07 ; needed for maths - (divide by 2 anyway)
    lda.w NorthOpenEdge, x : sta.b Scrap04 : inx ; bit field
    lda.w NorthEdgeInfo, x : sta.b Scrap08 ; needed for maths
    lda.w NorthOpenEdge, x : sta.b Scrap05 ; ratio
    lda.b Scrap04 : jsr LoadSouthMidpoint : inx ; needed now, and for nrml transition
    lda.w SouthEdgeInfo, x : sta.b Scrap0B : inx ; probably not needed todo: remove
    lda.w SouthEdgeInfo, x : sta.b Scrap0C ; needed for maths
    rts

LoadSouthMidpoint:
    and.b #$0f : sta.b Scrap00 : asl : !ADD.b Scrap00 : tax
    lda.w SouthEdgeInfo, x : sta.b Scrap0A ; needed now, and for nrml transition
    rts

LoadSouthData:
    lda.w SouthOpenEdge, x : sta.b Scrap03 : inx
    lda.w SouthEdgeInfo, x : sta.b Scrap07
    lda.w SouthOpenEdge, x : sta.b Scrap04 : inx
    lda.w SouthEdgeInfo, x : sta.b Scrap08
    lda.w SouthOpenEdge, x : sta.b Scrap05
    lda.b Scrap04 : jsr LoadNorthMidpoint : inx
    lda.w NorthEdgeInfo, x : sta.b Scrap0B : inx
    lda.w NorthEdgeInfo, x : sta.b Scrap0C
    rts

LoadNorthMidpoint:
    and.b #$0f : sta.b Scrap00 : asl : !ADD.b Scrap00 : tax
    lda.w NorthEdgeInfo, x : sta.b Scrap0A ; needed now, and for nrml transition
    rts

LoadWestData:
    lda.w WestOpenEdge, x : sta.b Scrap03 : inx
    lda.w WestEdgeInfo, x : sta.b Scrap07
    lda.w WestOpenEdge, x : sta.b Scrap04 : inx
    lda.w WestEdgeInfo, x : sta.b Scrap08
    lda.w WestOpenEdge, x : sta.b Scrap05
    lda.b Scrap04 : jsr LoadEastMidpoint : inx
    lda.w EastEdgeInfo, x : sta.b Scrap0B : inx
    lda.w EastEdgeInfo, x : sta.b Scrap0C
    rts

LoadEastMidpoint:
    and.b #$0f : sta.b Scrap00 : asl : !ADD.b Scrap00 : tax
    lda.w EastEdgeInfo, x : sta.b Scrap0A ; needed now, and for nrml transition
    rts

LoadEastData:
    lda.w EastOpenEdge, x : sta.b Scrap03 : inx
    lda.w EastEdgeInfo, x : sta.b Scrap07
    lda.w EastOpenEdge, x : sta.b Scrap04 : inx
    lda.w EastEdgeInfo, x : sta.b Scrap08
    lda.w EastOpenEdge, x : sta.b Scrap05
    lda.b Scrap04 : jsr LoadWestMidpoint : inx
    lda.w WestEdgeInfo, x : sta.b Scrap0B : inx
    lda.w WestEdgeInfo, x : sta.b Scrap0C


LoadWestMidpoint:
    and.b #$0f : sta.b Scrap00 : asl : !ADD.b Scrap00 : tax
    lda.w WestEdgeInfo, x : sta.b Scrap0A ; needed now, and for nrml transition
    rts


DetectNorthEdge:
    ldx.b #$ff
    lda.b PreviousRoom
    cmp.b #$82 : bne +
        lda.b LinkPosX : cmp.b #$50 : bcs ++
            ldx.b #$01 : bra .end
        ++ ldx.b #$00 : bra .end
    + cmp.b #$83 : bne +
        ldx.b #$02 : bra .end
    + cmp.b #$84 : bne +
        lda.b $a9 : beq ++
            lda.b LinkPosX : cmp.b #$78 : bcs +++
                ldx.b #$04 : bra .end
            +++ ldx.b #$05 : bra .end
        ++ lda.b LinkPosX : cmp.b #$78 : bcs ++
            ldx.b #$03 : bra .end
        ++ ldx.b #$04 : bra .end
    + cmp.b #$85 : bne +
        ldx.b #$06 : bra .end
    + cmp.b #$db : bne +
        lda.b $a9 : beq ++
            lda.b LinkPosX : beq ++
                ldx.b #$08 : bra .end
        ++ ldx.b #$07 : bra .end
    + cmp.b #$dc : bne .end
        lda.b $a9 : bne ++
            lda.b LinkPosX : cmp.b #$b0 : bcs ++
                ldx.b #$09 : bra .end
        ++ ldx.b #$0a
    .end txa : rts

DetectSouthEdge:
    ldx.b #$ff
    lda.b PreviousRoom
    cmp.b #$72 : bne +
        lda.b LinkPosX : cmp.b #$50 : bcs ++
            ldx.b #$01 : bra .end
        ++ ldx.b #$00 : bra .end
    + cmp.b #$73 : bne +
        ldx.b #$02 : bra .end
    + cmp.b #$74 : bne +
        lda.b $a9 : beq ++
            lda.b LinkPosX : cmp.b #$78 : bcs +++
                ldx.b #$04 : bra .end
            +++ ldx.b #$05 : bra .end
        ++ lda.b LinkPosX : cmp.b #$78 : bcs ++
            ldx.b #$03 : bra .end
        ++ ldx.b #$04 : bra .end
    + cmp.b #$75 : bne +
        ldx.b #$06 : bra .end
    + cmp.b #$cb : bne +
        lda.b $a9 : beq ++
            lda.b LinkPosX : beq ++
                ldx.b #$08 : bra .end
        ++ ldx.b #$07 : bra .end
    + cmp.b #$cc : bne .end
        lda.b $a9 : bne ++
            lda.b LinkPosX : cmp.b #$b0 : bcs ++
                ldx.b #$09 : bra .end
        ++ ldx.b #$0a
    .end txa : rts

DetectWestEdge:
    ldx.b #$ff
    lda.b PreviousRoom
    cmp.b #$65 : bne +
        ldx.b #$00 : bra .end
    + cmp.b #$74 : bne +
        ldx.b #$01 : bra .end
    + cmp.b #$75 : bne +
        ldx.b #$02 : bra .end
    + cmp.b #$82 : bne +
        lda.b LinkQuadrantV : beq ++
           ldx.b #$03 : bra .end
        ++ ldx.b #$04 : bra .end
    + cmp.b #$85 : bne +
            ldx.b #$05 : bra .end
    + cmp.b #$cc : bne +
        lda.b LinkQuadrantV : beq ++
            ldx.b #$06 : bra .end
        ++ ldx.b #$07 : bra .end
    + cmp.b #$dc : bne .end
        ldx.b #$08
    .end txa : rts

DetectEastEdge:
    ldx.b #$ff
    lda.b PreviousRoom
    cmp.b #$64 : bne +
        ldx.b #$00 : bra .end
    + cmp.b #$73 : bne +
        ldx.b #$01 : bra .end
    + cmp.b #$74 : bne +
        ldx.b #$02 : bra .end
    + cmp.b #$81 : bne +
        lda.b LinkQuadrantV : beq ++
           ldx.b #$04 : bra .end
        ++ ldx.b #$03 : bra .end
    + cmp.b #$84 : bne +
        ldx.b #$05 : bra .end
    + cmp.b #$cb : bne +
        lda.b LinkQuadrantV : beq ++
            ldx.b #$06 : bra .end
        ++ ldx.b #$07 : bra .end
    + cmp.b #$db : bne .end
        ldx.b #$08
    .end txa : rts

AlwaysPushThroughFDoors:
	PHA : AND.b #$F0 : CMP.b #$F0 : BNE +
		PLA : RTL
	+ PLA : AND.b #$8E : CMP.b #$80
	RTL
