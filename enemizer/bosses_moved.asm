;================================================================================
; Move the bosses to the right screen location depending on the room
;--------------------------------------------------------------------------------
boss_move:
{
    ; TODO: should probably double check that we don't need to preserve registers (A,X)...

	JSL Dungeon_ResetSprites            ; Restore the dungeon_resetsprites
	LDA $A0                             ; load room index (low byte)
	LDX $A1                             ; 				  (high byte)

	CMP #7   : BNE +                    ; Is is Hera Tower Boss Room
	CPX #$00 : BNE +
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
		BRL .move_to_middle
	+

	CMP #200 : BNE +                    ; Is is Eastern Palace Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_right
	+

	CMP #41 : BNE +                     ; Is is Skull Woods Boss Room
        ; TODO: Add moving floor sprite
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        LDA #$07 : STA $0B00;Spawn the moving floor sprite
        STZ $0B28
        INC $0B08
        BRL .move_to_bottom_right
	+

	CMP #51 : BNE +                     ; Is is Desert Palace Boss Room 
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_left
	+

	CMP #90 : BNE +                     ; Is is Palace of darkness Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_right
	+

	CMP #144 : BNE +                    ; Is is Misery Mire Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_left
	+

	CMP #172 : BNE +                    ; Is is Thieve Town Boss Room
                                        ; IF MAIDEN IS NOT RESCUED -> DO NOTHING
                                        ; IF MAIDEN IS ALREADY RESCUED -> spawn sprites normally
        JSL Sprite_ResetAll             ; removes sprites in thieve town boss room
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        ;Close the door if !BLIND_DOOR_FLAG == 1
        LDA !BLIND_DOOR_FLAG : BEQ .no_blind_door
        INC $0468                       ; $0468[0x02] - Flag that is set when trap doors are down.
        STZ $068E                       ; $068E[0x02] - (Dungeon) ???? related to trap doors and if they are open ; possibly bomb doors too? Update: module 0x07.0x4 probably uses this to know whether it's a key door or big key door to open.
        STZ $0690                       ; $0690[0x02] - (Overworld) Generally is used as an animation step indicator, only for doors that animate when they open, such as the Santuary and Hyrule Castle doors. This variable is incremented up to a value of 3, at which point a logic check kicks in and stops animating the opening of a door.
        INC $0CF3                     ; $0CF3[0x01] - free ram
         ; ;That must be called after the room load!
    .no_blind_door
        BRL .move_to_bottom_right
	+

	CMP #6   : BNE +                    ; Is is Swamp Palace Boss Room
	CPX #$00 : BNE +
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_left
	+

	CMP #222 : BNE +                    ; Is is Ice Palace Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
    	BRL .move_to_top_right
	+

	CMP #164 : BNE +                    ; Is is Turtle Rock Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
    	BRL .move_to_bottom_left
	+

	CMP #28 : BNE +                     ; Is is Gtower (Armos2) Boss Room
	CPX #$00 : BNE +
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
    	BRL .move_to_bottom_right
	+

	CMP #108 : BNE +                    ; Is is Gtower (Lanmo2) Boss Room
        JSL Sprite_ResetAll             ; reset sprites twice in that room for some reasons (fix bug with kholdstare)
        JSL Dungeon_ResetSprites        ; Restore the dungeon_resetsprites
        BRL .move_to_bottom_left
	+

	CMP #77 : BNE +                     ; Is is Gtower (Moldorm2) Boss Room
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
        LDX #$00

        .loop_middle ; move sprites
        LDA $0E20, X
        JSR ShouldMoveSprite : BCC .no_change
        LDA $0D10, X : !ADD #$68 : STA $0D10, X
        LDA $0D00, X : !ADD #$68 : STA $0D00, X

        .no_change
        INX : CPX #$10 : BNE .loop_middle
        LDX #$00

        .loop_middle2 ; move overlords
        LDA $0B00, X 
        CMP #$E3 : BNE + ;is it moving floor?
            BRA .no_change_ov
        +
        LDA $0B08, X : !ADD #$68 : STA $0B08, X
        LDA $0B18, X : !ADD #$68 : STA $0B18, X

        .no_change_ov
        INX : CPX #$08 : BNE .loop_middle2
        BRL .return


	.move_to_top_right
        LDX #$00

        .loop_top_right ; move sprites
        LDA $0E20, X
        JSR ShouldMoveSprite : BCC .no_change2
        LDA $0D20, X : !ADD #$00 : STA $0D20, X
        LDA $0D30, X : !ADD #$01 : STA $0D30, X

        .no_change2
        INX : CPX #$10 : BNE .loop_top_right
        LDX #$00

        .loop_top_right2 ; move overlords
        LDA $0B00, X 
        CMP #$E3 : BNE + ;is it moving floor?
            BRA .no_change_ov2
        +
        LDA $0B10, X : !ADD #$01 : STA $0B10, X
        LDA $0B20, X : !ADD #$00 : STA $0B20, X

        .no_change_ov2
        INX : CPX #$08 : BNE .loop_top_right2
        BRL .return


	.move_to_bottom_right
        LDX #$00

        .loop_bottom_right ; move sprites
        LDA $0E20, X
        JSR ShouldMoveSprite : BCC .no_change3
        LDA $0D20, X : !ADD #$01 : STA $0D20, X
        LDA $0D30, X : !ADD #$01 : STA $0D30, X

        .no_change3
        INX : CPX #$10 : BNE .loop_bottom_right
        LDX #$00

        .loop_bottom_right2 ; move overlords
        LDA $0B00, X 
        CMP #$E3 : BNE + ;is it moving floor?
            BRA .no_change_ov3
        +
        LDA $0B10, X : !ADD #$01 : STA $0B10, X
        LDA $0B20, X : !ADD #$01 : STA $0B20, X

        .no_change_ov3
        INX : CPX #$08 : BNE .loop_bottom_right2
        BRL .return


	.move_to_bottom_left
        LDX #$00

        .loop_bottom_left ; move sprites
        LDA $0E20, X
        JSR ShouldMoveSprite : BCC .no_change4
        LDA $0D20, X : !ADD #$01 : STA $0D20, X
        LDA $0D30, X : !ADD #$00 : STA $0D30, X

        .no_change4
        INX : CPX #$10 : BNE .loop_bottom_left
        LDX #$00

        .loop_bottom_left2 ; move overlords
        LDA $0B00, X 
        CMP #$E3 : BNE + ;is it moving floor?
            BRA .no_change_ov4
        +
        LDA $0B10, X : !ADD #$00 : STA $0B10, X
        LDA $0B20, X : !ADD #$01 : STA $0B20, X
        
        .no_change_ov4
        INX : CPX #$08 : BNE .loop_bottom_left2
        BRL .return


.return
    RTL
}

; A - sprite id from E20, X
; X - sprite index - should be preserved
; sets or clears carry flag, set if sprite should be moved
ShouldMoveSprite:
	PHX
	LDX #$FF
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
;    LDA $A0 : CMP #$39 : BNE .no_key_drop       ; Check if the room id is skullwoods before boss
;    LDA $0DD0, X : CMP #$09 : BNE .no_key_drop  ; Check if the sprite is alive
;    LDA #$01 : STA $0CBA, X;set key
;
;.no_key_drop
;    JSL $06DC5C ;Restore draw shadow
;    RTL
;--------------------------------------------------------------------------------

;================================================================================
; Set a flag to draw kholdstare shell on next NMI
;--------------------------------------------------------------------------------
new_kholdstare_code:
    LDA $0CBA : BNE .already_iced
    LDA #$01 : STA $0CBA

    LDA #$01 : STA !SHELL_DMA_FLAG ; tell our NMI to draw the shell

.already_iced
    ; restore code
    JSL Kholdstare_Draw         ; sprite_kholdstare.asm (154) : JSL Kholdstare_Draw
    RTL
;--------------------------------------------------------------------------------

;================================================================================
; Set a flag to draw trinexx shell on next NMI
;--------------------------------------------------------------------------------
new_trinexx_code:
    LDA $0CBA : BNE .already_rocked
    LDA #$01 : STA $0CBA

    LDA #$02 : STA !SHELL_DMA_FLAG ; tell our NMI to draw the shell

.already_rocked
    ; restore code
    LDA.b #$03 : STA $0DC0, X ; sprite_trinexx.asm (62) : LDA.b #$03 : STA $0DC0, X

    RTL
;--------------------------------------------------------------------------------
