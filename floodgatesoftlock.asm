;================================================================================
; Floodgate Softlock Fix
;--------------------------------------------------------------------------------
FloodGateAndMasterSwordFollowerReset:
	JSL MasterSwordFollowerClear
FloodGateReset:
	LDA.l PersistentFloodgate : BNE +
		LDA.l OverworldEventDataWRAM+$3B : AND.b #$DF : STA.l OverworldEventDataWRAM+$3B ; reset water outside floodgate
		LDA.l OverworldEventDataWRAM+$7B : AND.b #$DF : STA.l OverworldEventDataWRAM+$7B ; reset water outside swamp palace
		LDA.l RoomDataWRAM[$010B].low : AND.b #$7F : STA.l RoomDataWRAM[$010B].low ; clear water inside floodgate
		LDA.l RoomDataWRAM[$28].high : AND.b #$FE : STA.l RoomDataWRAM[$28].high ; clear water front room (room 40)
	+

; note - official sram for getting keys under pots has changed for DR, see RoomPotData
FloodGateResetInner:
	LDA.l Bugfix_SwampWaterLevel : BEQ .done

	LDA.l DRMode : BEQ .check_room_35; Only do the check for room 37 if on door rando
	LDA.l SwampDrain1HasItem : BEQ .flipper_check
	LDA.l $7F666F : AND.b #$80 : BEQ .drain_room_37 ; Check if key in room 37 has been collected.
.flipper_check
	LDA.l FlippersEquipment : AND.b #$01 : BNE .check_room_35 ; Check for flippers. This can otherwise softlock doors if flooded without flippers and no way to reset.
.drain_room_37
	LDA.l RoomDataWRAM[$37].low : AND.b #$7F : STA.l RoomDataWRAM[$37].low ; clear water room 37 - outer room you shouldn't be able to softlock except in major glitches
.check_room_35
	LDA.l SwampDrain2HasItem : BEQ .done
	LDA.l $7F666B : AND.b #$80 : BNE .done ; Check if key in room 35 has been collected.
	; no need to check for flippers on the inner room, as you can't get to the west door no matter what, without flippers.
	LDA.l RoomDataWRAM[$35].low : AND.b #$7F : STA.l RoomDataWRAM[$35].low ; clear water room 35 - inner room with the easy key flood softlock
.done
RTL
;================================================================================
