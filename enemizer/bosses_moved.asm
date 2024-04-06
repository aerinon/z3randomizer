;================================================================================
; Move the bosses to the right screen location depending on the room
;--------------------------------------------------------------------------------
boss_move:
{
    ; TODO: should probably double check that we don't need to preserve registers (A,X)...

	JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
	LDA.b RoomIndex                 ; load room index (low byte)
	LDX.b RoomIndex+1               ;                 (high byte)

	CMP.b #7   : BNE +                  ; Is it Hera Tower Boss Room
	CPX.b #$00 : BNE +
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
		BRL .move_to_middle
	+

	CMP.b #200 : BNE +                  ; Is it Eastern Palace Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_right
	+

	CMP.b #41 : BNE +                   ; Is it Skull Woods Boss Room
        ; TODO: Add moving floor sprite
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        LDA.b #$07 : STA.w $0B00        ;Spawn the moving floor sprite
        STZ.w $0B28
        INC.w OverlordXLow
        BRL .move_to_bottom_right
	+

	CMP.b #51 : BNE +                   ; Is it Desert Palace Boss Room 
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_left
	+

	CMP.b #90 : BNE +                   ; Is it Palace of darkness Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_right
	+

	CMP.b #144 : BNE +                  ; Is it Misery Mire Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_left
	+

	CMP.b #172 : BNE +                  ; Is it Thieve Town Boss Room
                                        ; IF MAIDEN IS NOT RESCUED -> DO NOTHING
                                        ; IF MAIDEN IS ALREADY RESCUED -> spawn sprites normally
        JSL Sprite_ResetAll             ; removes sprites in thieve town boss room
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        ;Close the door if !BLIND_DOOR_FLAG == 1
        LDA.l !BLIND_DOOR_FLAG : BEQ .no_blind_door
        INC.w TrapDoorFlag
        STZ.w TileMapDoorPos
        STZ.w DoorTimer
        INC.w BossSpecialAction
         ; ;That must be called after the room load!
    .no_blind_door
        BRL .move_to_bottom_right
	+

	CMP.b #6   : BNE +                  ; Is it Swamp Palace Boss Room
	CPX.b #$00 : BNE +
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_left
	+

	CMP.b #222 : BNE +                  ; Is it Ice Palace Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
    	BRL .move_to_top_right
	+

	CMP.b #164 : BNE +                  ; Is it Turtle Rock Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
    	BRL .move_to_bottom_left
	+

	CMP.b #28 : BNE +                   ; Is it Gtower (Armos2) Boss Room
	CPX.b #$00 : BNE +
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
    	BRL .move_to_bottom_right
	+

	CMP.b #108 : BNE +                  ; Is it Gtower (Lanmo2) Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_left
	+

	CMP.b #77 : BNE +                   ; Is it Gtower (Moldorm2) Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_middle
	+

	BRL .return

; $0D00[0x10] -   The lower byte of a sprite's Y - coordinate.
; $0D10[0x10] -   The lower byte of a sprite's X - coordinate.

; $0D20[0x10] -   The high byte of a sprite's Y - coordinate.
; $0D30[0x10] -   The high byte of a sprite's X - coordinate.

; $0B08[0x08] -   (Overlord) X coordinate low byte.
; $0B18[0x08] -   (Overlord) Y coordinate low byte.

; $0B10[0x08] -   (Overlord) X coordinate high byte.
; $0B20[0x08] -   (Overlord) Y coordinate high byte.

	.move_to_middle
        ;load all sprite of that room and overlord
        LDX.b #$00

        .loop_middle ; move sprites
        LDA.w SpriteTypeTable, X
        JSR ShouldMoveSprite : BCC .no_change
        LDA.w SpritePosXLow, X : !ADD.b #$68 : STA.w SpritePosXLow, X
        LDA.w SpritePosYLow, X : !ADD.b #$68 : STA.w SpritePosYLow, X

        .no_change
        INX : CPX.b #$10 : BNE .loop_middle
        LDX.b #$00

        .loop_middle2 ; move overlords
        LDA.w $0B00, X 
        CMP.b #$E3 : BNE + ;is it moving floor?
            BRA .no_change_ov
        +
        LDA.w OverlordXLow, X : !ADD.b #$68 : STA.w OverlordXLow, X
        LDA.w OverlordYLow, X : !ADD.b #$68 : STA.w OverlordYLow, X

        .no_change_ov
        INX : CPX.b #$08 : BNE .loop_middle2
        BRL .return


	.move_to_top_right
        LDX.b #$00

        .loop_top_right ; move sprites
        LDA.w SpriteTypeTable, X
        JSR ShouldMoveSprite : BCC .no_change2
        LDA.w SpritePosYHigh, X : !ADD.b #$00 : STA.w SpritePosYHigh, X
        LDA.w SpritePosXHigh, X : !ADD.b #$01 : STA.w SpritePosXHigh, X

        .no_change2
        INX : CPX.b #$10 : BNE .loop_top_right
        LDX.b #$00

        .loop_top_right2 ; move overlords
        LDA.w $0B00, X 
        CMP.b #$E3 : BNE + ;is it moving floor?
            BRA .no_change_ov2
        +
        LDA.w OverlordXHigh, X : !ADD.b #$01 : STA.w OverlordXHigh, X
        LDA.w OverlordYHigh, X : !ADD.b #$00 : STA.w OverlordYHigh, X

        .no_change_ov2
        INX : CPX.b #$08 : BNE .loop_top_right2
        BRL .return


	.move_to_bottom_right
        LDX.b #$00

        .loop_bottom_right ; move sprites
        LDA.w SpriteTypeTable, X
        JSR ShouldMoveSprite : BCC .no_change3
        LDA.w SpritePosYHigh, X : !ADD.b #$01 : STA.w SpritePosYHigh, X
        LDA.w SpritePosXHigh, X : !ADD.b #$01 : STA.w SpritePosXHigh, X

        .no_change3
        INX : CPX.b #$10 : BNE .loop_bottom_right
        LDX.b #$00

        .loop_bottom_right2 ; move overlords
        LDA.w $0B00, X 
        CMP.b #$E3 : BNE + ;is it moving floor?
            BRA .no_change_ov3
        +
        LDA.w OverlordXHigh, X : !ADD.b #$01 : STA.w OverlordXHigh, X
        LDA.w OverlordYHigh, X : !ADD.b #$01 : STA.w OverlordYHigh, X

        .no_change_ov3
        INX : CPX.b #$08 : BNE .loop_bottom_right2
        BRL .return


	.move_to_bottom_left
        LDX.b #$00

        .loop_bottom_left ; move sprites
        LDA.w SpriteTypeTable, X
        JSR ShouldMoveSprite : BCC .no_change4
        LDA.w SpritePosYHigh, X : !ADD.b #$01 : STA.w SpritePosYHigh, X
        LDA.w SpritePosXHigh, X : !ADD.b #$00 : STA.w SpritePosXHigh, X

        .no_change4
        INX : CPX.b #$10 : BNE .loop_bottom_left
        LDX.b #$00

        .loop_bottom_left2 ; move overlords
        LDA.w $0B00, X 
        CMP.b #$E3 : BNE + ;is it moving floor?
            BRA .no_change_ov4
        +
        LDA.w OverlordXHigh, X : !ADD.b #$00 : STA.w OverlordXHigh, X
        LDA.w OverlordYHigh, X : !ADD.b #$01 : STA.w OverlordYHigh, X
        
        .no_change_ov4
        INX : CPX.b #$08 : BNE .loop_bottom_left2
        BRL .return


.return
    RTL
}

; A - sprite id from E20, X
; X - sprite index - should be preserved
; sets or clears carry flag, set if sprite should be moved
ShouldMoveSprite:
	PHX
	LDX.b #$FF
	- INX : CPX.b #$0F : BCS .done
	CMP.l BossIds, X : BNE -
; match found, move it
	PLX : SEC : RTS
.done ; don't move it
	PLX : CLC : RTS

BossIds:
db $53, $54, $09, $92, $8c, $8d, $88, $ce
db $a2, $a3, $a4, $bd, $cb, $cc, $cd, $ff

;================================================================================
; Fix the gibdo key drop in skull woods before the boss room - USELESS CODE
;--------------------------------------------------------------------------------
;gibdo_drop_key:
;    LDA.b RoomIndex : CMP.b #$39 : BNE .no_key_drop       ; Check if the room id is skullwoods before boss
;    LDA.w SpriteAITable, X : CMP.b #$09 : BNE .no_key_drop  ; Check if the sprite is alive
;    LDA.b #$01 : STA.w SpriteForceDrop, X;set key
;
;.no_key_drop
;    JSL $86DC5C ;Restore draw shadow
;    RTL
;--------------------------------------------------------------------------------

;================================================================================
; Set a flag to draw kholdstare shell on next NMI
;--------------------------------------------------------------------------------
new_kholdstare_code:
    LDA.w SpriteForceDrop : BNE .already_iced
    LDA.b #$01 : STA.w SpriteForceDrop

    LDA.b #$01 : STA.l !SHELL_DMA_FLAG ; tell our NMI to draw the shell

.already_iced
    ; restore code
    JSL Kholdstare_Draw         ; sprite_kholdstare.asm (154) : JSL Kholdstare_Draw
    RTL
;--------------------------------------------------------------------------------

;================================================================================
; Set a flag to draw trinexx shell on next NMI
;--------------------------------------------------------------------------------
new_trinexx_code:
    LDA.w SpriteForceDrop : BNE .already_rocked
    LDA.b #$01 : STA.w SpriteForceDrop

    LDA.b #$02 : STA.l !SHELL_DMA_FLAG ; tell our NMI to draw the shell

.already_rocked
    ; restore code
    LDA.b #$03 : STA.w SpriteGFXControl, X ; sprite_trinexx.asm (62) : LDA.b #$03 : STA $0DC0, X

    RTL
;--------------------------------------------------------------------------------
