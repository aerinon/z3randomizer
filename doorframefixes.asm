;================================================================================
; Door Frame Fixes
;================================================================================

;--------------------------------------------------------------------------------
; StoreLastOverworldDoorID
;--------------------------------------------------------------------------------
StoreLastOverworldDoorID:
	TXA : INC
	STA.l PreviousOverworldDoor
	LDA.l Overworld_Entrance_ID, X : STA.w EntranceIndex
RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; CacheDoorFrameData
;--------------------------------------------------------------------------------
CacheDoorFrameData:
	LDA.l PreviousOverworldDoor : BEQ .originalBehaviour
	DEC : ASL : TAX
	LDA.l EntranceDoorFrameTable, X : STA.w TileMapEntranceDoors
	LDA.l EntranceAltDoorFrameTable, X : STA.w TileMapTile32
	BRA .done
	.originalBehaviour
		LDA.w $D724, X : STA.w TileMapEntranceDoors
		STZ.w TileMapTile32
	.done
RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; WalkDownIntoTavern
;--------------------------------------------------------------------------------
WalkDownIntoTavern:
	LDA.l PreviousOverworldDoor
	; tavern door has index 0x42 (saved off value is incremented by one)
	CMP.b #$43
RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; TurnAroundOnUnderworld
;--------------------------------------------------------------------------------
TurnAroundOnUnderworld:
	LDA.b LinkPushDirection : BEQ .done
		; turn around if ($010E == #$43) != ($7F5099 == #$43)
		LDX.b #$00
		LDA.b #$43 : CMP.w EntranceIndex : BEQ +
			INX
		+
		CMP.l PreviousOverworldDoor : BEQ +
			DEX
		+
		CPX.b #$00 : BEQ .done
			LDA.b LinkPushDirection : EOR.b #$0C : STA.b LinkPushDirection
.done
JML Underworld_LoadCustomTileAttributes ; what we overwrote

;--------------------------------------------------------------------------------
; TurnUpOnOverworld
;--------------------------------------------------------------------------------
TurnUpOnOverworld:
	LDA.l EntranceTavernBack : CMP.b #$43 : BEQ .done
		LDA.b #$08 : STA.b LinkPushDirection ; only fix this glitch if exit not vanilla
.done
JML Link_HandleMovingAnimation_FullLongEntry ; what we overwrote

;--------------------------------------------------------------------------------
; WalkUpOnOverworld
;--------------------------------------------------------------------------------
WalkUpOnOverworld:
	LDA.b LinkPosY : CMP.w #$091B : BNE .normal ; hardcoded Y coordinate
		STZ.b LinkDirection
		RTL
	.normal
	LDA.w #$0002 : STA.b LinkDirection ; what we overwrote
RTL

;--------------------------------------------------------------------------------
; CheckStairsAdjustment
;--------------------------------------------------------------------------------
CheckStairsAdjustment:
	LDA.b RoomIndex
	CMP.w #$0124 ; vanilla check, rooms $0124 to $0127 have a lower exit position (currently ER ignores the entrance location)
	BCC .done
	LDA.w #$FFFF-1
	CMP.w TileMapEntranceDoors ; tavern back ($0696 == #$FFFF) should always have carry cleared
.done
RTL
; if carry cleared, shift position up