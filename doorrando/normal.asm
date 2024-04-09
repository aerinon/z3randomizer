WarpLeft:
    lda.l DRMode : beq .end
	JSR CheckIfCave : BCS .end
	lda.b LinkPosY : ldx.b LinkQuadrantV
	jsr CalcIndex
	!ADD.b #$06 : ldy.b #$01 ; offsets in A, Y
	jsr LoadRoomHorz
.end
	jsr Cleanup
	rtl

WarpRight:
    lda.l DRMode : beq .end
	JSR CheckIfCave : BCS .end
	lda.b LinkPosY : ldx.b LinkQuadrantV
	jsr CalcIndex
	!ADD.b #$12 : ldy.b #$ff ; offsets in A, Y
	jsr LoadRoomHorz
.end
	jsr Cleanup
	rtl

WarpUp:
    lda.l DRMode : beq .end
	JSR CheckIfCave : BCS .end
	lda.b LinkPosX : ldx.b LinkQuadrantH
	jsr CalcIndex
	ldy.b #$02 ; offsets in A, Y
	jsr LoadRoomVert
.end
	jsr Cleanup
	rtl

; Checks if $a0 is equal to <Room>. If it is, opens its stonewall if it's there
macro StonewallCheck(Room)
    lda.b RoomIndex : cmp.b #<Room> : bne ?end
        lda.l <Room>*2+$7ef000 : ora.b #$80 : sta.l <Room>*2+$7ef000
    ?end
endmacro

WarpDown:
    lda.l DRMode : beq .end
	JSR CheckIfCave : BCS .end
	lda.b LinkPosX : ldx.b LinkQuadrantH
	jsr CalcIndex
	!ADD.b #$0c : ldy.b #$ff ; offsets in A, Y
	jsr LoadRoomVert
    %StonewallCheck($43)
.end
	jsr Cleanup
	rtl

; carry set = use link door like normal
; carry clear = we are in dr mode, never use linking doors
CheckLinkDoorR:
    lda.l DRMode : bne +
        lda.l $7ec004 : sta.b RoomIndex ; what we wrote over
        sec : rtl
    + clc : rtl

CheckLinkDoorL:
    lda.l DRMode : bne +
        lda.l $7ec003 : sta.b RoomIndex ; what we wrote over
        sec : rtl
    + clc : rtl

TrapDoorFixer:
    lda.b $fe : and.w #$0038 : beq .end
    xba : asl #2 : sta.b Scrap00
    stz.w TrapDoorFlag : lda.w $068c : ora.b Scrap00 : sta.w $068c
    .end
    stz.b $fe ; clear our fe here because we don't need it anymore
    rts

Cleanup:
	lda.l DRFlags : and.b #$10 : beq +
    	stz.w LayerAdjustment
	+ inc.b GameSubMode
	lda.b $ef
	rts

; carry set if cave, clear otherwise
CheckIfCave:
	REP #$30
	LDA.b PreviousRoom : CMP.w #$00E1 : BCS .invalid
	SEP #$30 : CLC : RTS
	.invalid
	SEP #$30 : SEC : RTS

;A needs be to the low coordinate, x needs to be either 0 for left,upper or non-zero for right,down
; This sets A (00,02,04) and stores half that at $04 for later use, (src door)
CalcIndex: ; A->low byte of Link's Coord, X-> Link's quadrant, DoorOffset x 2 -> A, DoorOffset -> $04 (vert/horz agnostic)
	cpx.b #00 : bne .largeDoor
	cmp.b #$d0 : bcc .smallDoor
	lda.b #$01 : bra .done ; Middle Door
	.smallDoor lda.b #$00 : bra .done
	.largeDoor lda.b #$02
	.done
	sta.b Scrap04
	asl
	rts

; Y is an adjustment for main direction of travel
; A is a door table row offset
LoadRoomHorz:
{
    phb : phk : plb
	sty.b Scrap06 : sta.b Scrap07 : lda.b RoomIndex : pha ; Store normal room on stack
	lda.b Scrap07 : jsr LookupNewRoom ; New room is in A, Room Data is in $00-$01
	lda.b Scrap00 : cmp.b #$03 : bne .gtg
	jsr HorzEdge : pla : bcs .end
	sta.b RoomIndex : bra .end ; Restore normal room, abort (straight staircases and open edges can get in this routine)

	.gtg ;Good to Go!
	pla ; Throw away normal room (don't fill up the stack)
	lda.b RoomIndex : and.b #$0F : asl a : !SUB.b LinkPosX+1 : !ADD.b Scrap06 : sta.b Scrap02
	ldy.b #$00 : jsr ShiftVariablesMainDir

    lda.b Scrap01 : and.b #$80 : beq .normal
    ldy.b Scrap06 : cpy.b #$ff : beq +
        lda.b Scrap01 : jsr LoadEastMidpoint : bra ++
    + lda.b Scrap01 : jsr LoadWestMidpoint
    ++ jsr PrepScrollToEdge : bra .scroll

    .normal
    jsr PrepScrollToNormal
	.scroll
	lda.b Scrap01 : and.b #$40 : pha
	jsr ScrollY
	pla : beq .end
	    ldy.b #$06 : jsr ApplyScroll
	.end
	plb ; restore db register
    rts
}

; Y is an adjustment for main direction of travel (stored at $06)
; A is a door table row offset (stored a $07)
LoadRoomVert:
{
    phb : phk : plb
	sty.b Scrap06 : sta.b Scrap07 : lda.b RoomIndex : pha ; Store normal room on stack
	lda.b Scrap07 : jsr LookupNewRoom ; New room is in A, Room Data is in $00-$01
	lda.b Scrap00 : cmp.b #$03 : bne .gtg
	jsr VertEdge : pla : bcs .end
	sta.b RoomIndex : bra .end ; Restore normal room, abort (straight staircases and open edges can get in this routine)
	.gtg ;Good to Go!
	pla ; Throw away normal room (don't fill up the stack)
	lda.b RoomIndex : and.b #$F0 : lsr #3 : !SUB.b LinkPosY+1 : !ADD.b Scrap06 : sta.b Scrap02

	lda.b Scrap01 : and.b #$80 : beq .notEdge
	    ldy.b #$01 : jsr ShiftVariablesMainDir
        ldy.b Scrap06 : cpy.b #$ff : beq +
            lda.b Scrap01 : jsr LoadSouthMidpoint : bra ++
        + lda.b Scrap01 : jsr LoadNorthMidpoint
	++ jsr PrepScrollToEdge : bra .scroll

    .notEdge
    lda.b Scrap01 : and.b #$03 : cmp.b #$03 : bne .normal
        jsr ScrollToInroomStairs
        stz.w $046d
        bra .end
    .normal
	ldy.b #$01 : jsr ShiftVariablesMainDir
    jsr PrepScrollToNormal
    .scroll
    lda.b Scrap01 : and.b #$40 : sta.w $046d
    jsr ScrollX
    .end
    plb ; restore db register
    rts
}

LookupNewRoom: ; expects data offset to be in A
{
    rep #$30 : and.w #$00FF ;sanitize A reg (who knows what is in the high byte)
	sta.b Scrap00 ; offset in 00
	lda.b PreviousRoom : tax ; probably okay loading $a3 in the high byte
	lda.w DoorOffset,x : and.w #$00FF ;we only want the low byte
	asl #3 : sta.b Scrap02 : !ADD.b Scrap02 : !ADD.b Scrap02 ;multiply by 24 (data size)
	!ADD.b Scrap00 ; should now have the offset of the address I want to load
	tax : lda.w DoorTable,x : sta.b Scrap00
	and.w #$00FF : sta.b RoomIndex ; assign new room
	sep #$30
	rts
}

; INPUTS-- Y: Direction Index , $02:  Shift Value
; Sets high bytes of various registers
ShiftVariablesMainDir:
{
	lda.w CoordIndex,y : tax
	lda.b LinkPosY+1,x : !ADD.b Scrap02 : sta.b LinkPosY+1,x ; coordinate update
	lda.w CameraIndex,y : tax
	lda.b $e3,x : !ADD.b Scrap02 : sta.b $e3,x ; scroll register high byte
	lda.w CamQuadIndex,y : tax
	lda.w $0605,x : !ADD.b Scrap02 : sta.w $0605,x ; high bytes of these guys
	lda.w $0607,x : !ADD.b Scrap02 : sta.w $0607,x
	lda.w $0601,x : !ADD.b Scrap02 : sta.w $0601,x
	lda.w $0603,x : !ADD.b Scrap02 : sta.w $0603,x
	rts
}

; Normal Flags should be in $01
ScrollToInroomStairs:
{
    jsr PrepScrollToInroomStairs
    ldy.b #$01 : jsr ShiftVariablesMainDir
    jsr ScrollX
    ldy.b #$00 : jsr ApplyScroll
    lda.b RoomIndex : and.b #$0f : cmp.b #$0f : bne +
        stz.b BG1H : stz.b BG2H ; special case camera fix
        lda.b #$1f : sta.b BG1H+1 : sta.b BG2H+1
    +
    rts
}

; Direction should be in $06, Shift Value (see above) in $02 and other info in $01
; Sets $02, $04, $05, $ee, $045e, $045f and things related to Y coordinate
PrepScrollToInroomStairs:
{
    lda.b Scrap01 : and.b #$30 : lsr #3 : tay
    lda.w InroomStairsX,y : sta.b Scrap04
    lda.w InroomStairsX+1,y : sta.b Scrap05
    lda.b Scrap06 : cmp.b #$ff : beq .south
        lda.w InroomStairsY+1,y : bne +
            inc.w $045f ; flag indicating special screen transition
            dec.b Scrap02 ; shift variables further
            stz.b LinkQuadrantV
            lda.b $a8 : and.b #%11111101 : sta.b $a8
            stz.w CameraTargetS+1 ; North scroll target
            inc.w $0603 : inc.w $0607
            dec.w CameraScrollN+1 : dec.w CameraScrollS+1
        +
        lda.w InroomStairsY,y : !ADD.b #$20 : sta.b LinkPosY
        !SUB.b #$38 : sta.w $045e
        lda.b Scrap01 : and.b #$40 : beq +
            lda.b LinkPosY : !ADD.b #$20 : sta.b LinkPosY
            stz.w $045f
        +
        dec.b LinkPosY+1
        %StonewallCheck($1b)
        bra ++
    .south
        lda.w InroomStairsY+1,y : beq +
            inc.w $045f ; flag indicating special screen transition
            inc.b Scrap02 ; shift variables further
            lda.b #$02 : sta.b LinkQuadrantV
            lda.b $a8 : ora.b #%00000010 : sta.b $a8
            inc.w CameraTargetN+1 ; South scroll target
            dec.w $0603 : dec.w $0607
            inc.w CameraScrollN+1 : inc.w CameraScrollS+1
        +
        lda.w InroomStairsY,y : !SUB.b #$20 : sta.b LinkPosY
        !ADD.b #$38 : sta.w $045e
        lda.b Scrap01 : and.b #$40 : beq +
            lda.b LinkPosY : !SUB.b #$20 : sta.b LinkPosY
            stz.w $045f
        +
        inc.b LinkPosY+1
    ++
    lda.b Scrap01 : and.b #$04 : lsr #2 : sta.b LinkLayer : bne +
    	stz.w $0476
    + rts
}

; Target pixel should be in A, other info in $01
; Sets $04 $05 and $ee
PrepScrollToEdge:
{
    sta.b Scrap04 : lda.b Scrap01 : and.b #$20 : beq +
        lda.b #01
    + sta.b Scrap05
    lda.b Scrap01 : and.b #$10 : beq +
        lda.b #01
    + sta.b LinkLayer : bne +
    	stz.w $0476
    + rts
}

; Normal Flags should be in $01
; Sets $04 $05 and $ee, and $fe
PrepScrollToNormal:
{
    lda.b Scrap01 : sta.b $fe : and.b #$04 : lsr #2 : sta.b LinkLayer ; trap door and layer
    bne +
    	stz.w $0476
    + stz.b Scrap05 : lda.b #$78 : sta.b Scrap04
    lda.b Scrap01 : and.b #$03 : beq .end
        cmp.b #$02 : !BGE +
            lda.b #$f8 : sta.b Scrap04 : bra .end
        + inc.b Scrap05
    .end rts
}

StraightStairsAdj:
{
    stx.w $0464 : sty.w SFX2 ; what we wrote over
    lda.l DRMode : beq +
        lda.w $045e : bne .toInroom
        lda.w $046d : beq .noScroll
            sta.b LinkPosX
            ldy.b #$00 : jsr ApplyScroll
            stz.w $046d
        .noScroll
        jsr GetTileAttribute : tax
        lda.b GameSubMode : cmp.b #$12 : beq .goingNorth
            lda.b PreviousRoom : cmp.b #$51 : bne ++
                rep #$20 : lda.w #$0018 : !ADD.b LinkPosY : sta.b LinkPosY : sep #$20 ; special fix for throne room
                jsr GetTileAttribute : tax
            ++ lda.l StepAdjustmentDown, X : bra .end
;            lda.b LinkLayer : beq .end
;                rep #$20 : lda.w #$ffe0 : !ADD.b LinkPosY : sta.b LinkPosY : sep #$20
        .goingNorth
            cpx.b #$00 : bne ++
            lda.b RoomIndex : cmp.b #$51 : bne ++
                lda.b #$36 : bra .end ; special fix for throne room
            ++ ldy.b LinkLayer : cpy.b #$00 : beq ++
                inx
            ++ lda.l StepAdjustmentUp, X
        .end
        pha : lda.w $0462 : and.b #$04 : bne ++
            pla : !ADD.b #$f6 : pha
        ++ pla : !ADD.w $0464 : sta.w $0464
    + rtl
    .toInroom
    lda.b #$32 : sta.w $0464 : stz.w $045e
    rtl
}

GetTileAttribute:
{
    phk : pea.w .jslrtsreturn-1
    pea.w $82802c
    jml CalculateTransitionLanding ; mucks with x/y sets a to Tile Attribute, I think
    .jslrtsreturn
    rts
}

; 0 open edge
; 1 nrm door high
; 2 straight str
; 3 nrm door low
; 4 trap door high
; 5 trap door low   (none of these exist on North direction)
StepAdjustmentUp: ; really North Stairs
db $00, $f6, $1a, $18, $16, $38
StepAdjustmentDown: ; really South Stairs
db $d0, $f6, $10, $1a, $f0, $00

StraightStairsFix:
{
    pha
    lda.l DRMode : bne +
        pla : !ADD.b LinkPosY : sta.b LinkPosY : rtl ;what we wrote over
    + pla : rtl
}

StraightStairLayerFix:
{
    lda.l DRMode : beq +
        lda.b LinkLayer : rtl
    + lda.l LayerOfDestination+3, x : rtl ; what we wrote over
}

DoorToStraight:
{
    pha
    lda.l DRMode : beq .skip
        pla : bne .end
        pha
        lda.b RoomIndex : cmp.b #$51 : bne .skip
        lda.b #$04 : sta.b $4e
    .skip pla
    .end LDX.w TransitionDirection : CMP.b #$02 ; what we wrote over
    rtl
}

DoorToInroom:
{
    ldx.w $045e : bne .end
        sta.w $0020, y ; what we wrote over
    .end
    ldx.b #$00 ; what we wrote over
    rtl
}

DoorToInroomEnd:
{
    ldy.w $045e : beq .vanilla
    cmp.w $045e : bne .return
        stz.w $045e ; clear
    .return
    rtl
    .vanilla
    cmp.l UnderworldTransitionLandingCoordinate, x ; what we wrote over
    rtl
}

StraightStairsTrapDoor:
{
    lda.w $0464 : bne +
        ; reset function
        .reset phk : pea.w .jslrtsreturn-1
        pea.w $82802c
        jml ResetThenCacheRoomEntryProperties ; $10D71 .reset label of Bank02
        .jslrtsreturn
        lda.w TrapDoorFlag : bne ++
        lda.b RoomIndex : cmp.b #$ac : bne .animateTraps
        lda.w $0403 : and.b #$20 : bne .animateTraps
        lda.w $0403 : and.b #$10 : beq ++
            .animateTraps
            lda.b #$05 : sta.b GameSubMode
            inc.w TrapDoorFlag : stz.w TileMapDoorPos : stz.w DoorTimer
        ++ JML Underworld_SetBossOrSancMusicUponEntry_long
    + JML Dungeon_ApproachFixedColor ; what we wrote over
}

InroomStairsTrapDoor:
{
    lda.w SubModuleInterface : cmp.b #$05 : beq .reset
    lda.b SubSubModule : jml JumpTableLocal ; what we wrote over (essentially)
    .reset
    pla : pla : pla
    jsl StraightStairsTrapDoor_reset
    jml $828b15 ; just some RTS in bank 02
}

HandleSpecialDoorLanding: {
    LDA.l $7F2000,X ; what we wrote over
    SEP #$30
    ; A = tiletype
    HandleIncomingDoorState:
    PHA
        LDA.l DRMode : BEQ .noDoor
        LDA.b 1,S : AND.b #$FA : CMP.b #$80 : bne .noDoor

        .setDoorState
        LDA.w TransitionDirection : AND.b #$02 : BNE + : INC
        + STA.b $6C

        .noDoor
	PLA
    CMP.b #$34 : BNE + ; inroom stairs
        PHA : LDA.b #$26 : STA.w $045E : PLA
    +
RTL
}
