;================================================================================
; Fix boss item drop position to 'center' of screen
;================================================================================
change_heartcontainer_position:
{
    PHA
    	LDA.l !CENTER_BOSS_DROP_FLAG : BEQ .not_moldorm_room
		LDA.b #$78 : STA.w SpritePosXLow, X
					 STA.w SpritePosYLow, X

		LDA.b LinkPosX+1 : STA.w SpritePosXHigh, X
		LDA.b LinkPosY+1 : STA.w SpritePosYHigh, X

		LDA.b RoomIndex : CMP.b #$07 : BNE .not_moldorm_room  ; not moldorm room
		LDA.b LinkPosX : STA.w SpritePosXLow, X
		LDA.b LinkPosY : STA.w SpritePosYLow, X

    .not_moldorm_room
    
    PLA
    JSL Sprite_Get16BitCoords_long
    RTL 
}