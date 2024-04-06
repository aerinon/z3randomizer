pushpc

org $8AC02B
DrawPrizesOverride:
LDX.b #$FF

.loopStart
	INX : PHX
	JSR OverworldMap_CheckForPrize
	BCC + : JMP .skip_draw : +

	TXA : ASL A : TAX
	LDA.l MapCompassFlag
	AND.b #$01 : BNE +
		LDA.l WorldMapIcon_posx_vanilla+1, X : STA.l $7EC10B
		LDA.l WorldMapIcon_posx_vanilla, X : STA.l $7EC10A
        LDA.l WorldMapIcon_posy_vanilla+1, X : STA.l $7EC109
        LDA.l WorldMapIcon_posy_vanilla, X : STA.l $7EC108
        BRA .adjustment
	+ LDA.l WorldMapIcon_posx_located+1, X : STA.l $7EC10B
	LDA.l WorldMapIcon_posx_located, X : STA.l $7EC10A
	LDA.l WorldMapIcon_posy_located+1, X : STA.l $7EC109
	LDA.l WorldMapIcon_posy_located, X : STA.l $7EC108
    .adjustment
    LDA.l WorldMapIcon_tile, X : CMP.b #$FF : BEQ .skip_draw
   	LDA.l WorldMapIcon_tile+1, X : BEQ .dont_adjust
   	CMP.b #$64 : BEQ .is_crystal
   	LDA.b FrameCounter : AND.b #$10 : BNE .skip_draw
   	.is_crystal
   	JSR WorldMapIcon_AdjustCoordinate
   	.dont_adjust
   	JSR WorldMap_CalculateOAMCoordinates
    BCC .skip_draw
    PLX : PHX : TXA : ASL A : TAX
    LDA.l WorldMapIcon_tile+1, X : BEQ .is_red_x
    LDA.l MapCompassFlag : CMP.b #$01 : BEQ .is_red_x
    LDA.l WorldMapIcon_tile+1, X : STA.b Scrap0D
    LDA.l WorldMapIcon_tile, X : STA.b Scrap0C
    LDA.b #$02 : BRA .continue
    .is_red_x
    LDA.b FrameCounter : LSR #3 : AND.b #$03 : TAX
    LDA.l WorldMap_RedXChars,X : STA.b Scrap0D
    LDA.b #$32 : STA.b Scrap0C : LDA.b #$00
    .continue
    STA.b Scrap0B
    PLX : PHX
    INX : JSR WorldMap_HandleSpriteBlink
    .skip_draw
	; end of loop
	PLX : CPX.b #12 : BCS + : JMP .loopStart : +

    PLA : STA.l $7EC10B
	PLA : STA.l $7EC10A
	PLA : STA.l $7EC109
	PLA : STA.l $7EC108
	RTS


; X - the index of the prize marker
OverworldMap_CheckForPrize:
PHX
	LDA.b #$00 : STA.l MapCompassFlag
	JSR OverworldMap_CheckForCompass
	BCC +
		LDA.l MapCompassFlag : ORA.b #$01 : STA.l MapCompassFlag
		LDA.l CurrentWorld : AND.b #$40 : BNE ++ ; is the compass position on LW or DW?
        	LDA.l WorldCompassMask, X : BEQ + : JMP .fail
        ++ LDA.l WorldCompassMask, X : BNE + : JMP .fail
	+ JSR OverworldMap_CheckForMap
	BCC +
		LDA.l MapCompassFlag : ORA.b #$02 : STA.l MapCompassFlag
	+
	LDA.l MapCompassFlag : BEQ .fail
	CMP.b #$02 : BNE .checkIfObtained
		LDA.l CurrentWorld : AND.b #$40 : BNE +
			CPX.b #3 : BCS .fail : BRA .checkIfObtained
		+ CPX.b #10 : BCS .fail
		CPX.b #3 : BCC .fail

	.checkIfObtained
	LDA.l MC_DungeonIdsForPrize, X
	BPL +++ : CLC : BRA .done : +++ ; non-prize flags
        CMP.b #$02 : BCC .hyrule_castle
        ASL : TAX
        REP #$20
        LDA.l DungeonsCompleted : AND.l DungeonItemMasks,X : BNE .fail
        CLC : BRA .done

	; see if hyrule castle has been completely cleared
	.hyrule_castle
	REP #$20
	LDA.l CompassTotalsWRAM, X : SEC : SBC.l DungeonLocationsChecked, X
	SEP #$20
	BEQ .fail
	CLC : BRA .done

	.fail
	SEC
.done
SEP #$20
PLX
RTS

; X - which compass in question
; CLC - should not move indicator
; SEC - yep indicator can move
OverworldMap_CheckForCompass:
	LDA.l CompassMode : AND.b #$80 : BEQ .unset ; should I check for compass logic
	LDA.l CompassMode : AND.b #$40 : BEQ .set ; compasses/maps aren't shuffled
	LDA.l CompassMode : AND.b #$20 : BNE +
		JSR OverworldMap_CheckForMap : BCC .unset : BRA .set
	+ LDA.l CompassExists, X : BEQ .set ; compass doesn't exist
	PHX
		LDA.l MC_SRAM_Offsets, X : TAX ; put compass offset into X
		LDA.l CompassField, X : ORA.l MapOverlay, X
	PLX
	AND.l MC_Masks, X : BNE .set ; is the compass obtained
.unset
CLC
RTS
.set
SEC
RTS

; map - which map in question
; CLC - should not show exact prize
; SEC - yep should show exact prize
OverworldMap_CheckForMap:
	LDA.l MapMode : BEQ .set ; obtaining map doesn't change anything
	LDA.l CurrentWorld : AND.b #$40 : BNE + ; not really sure on this check
		LDA.l MapField : ORA.l MapOverlay : AND.b #$01 : BNE .set : BRA .continue
	+ LDA.l MapField : ORA.l MapOverlay : AND.b #$02 : BNE .set
.continue
	PHX
		LDA.l MC_SRAM_Offsets, X : TAX ; put map offset into X
		LDA.l MapField, X : ORA.l MapOverlay, X
	PLX
	AND.l MC_Masks, X : BNE .set ; is the map obtained?
.unset
CLC
RTS
.set
SEC
RTS

pullpc
