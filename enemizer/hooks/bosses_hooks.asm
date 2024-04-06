; *$4C114-$4C174 LONG
org $89C114
Dungeon_ResetSprites: ; Bank09.asm(822)

; *$4C44E-$4C498 LONG
org $89C44E
Sprite_ResetAll: ; Bank09.asm(1344)

;--------------------------------------------------------------------------------

;================================================================================
; On Room Transition -> Move Sprite depending on the room loaded
;--------------------------------------------------------------------------------
org $828979 ;  JSL Dungeon_ResetSprites ; REPLACE THAT (Sprite initialization) original jsl : $09C114
JSL boss_move
org $828C16 ;  JSL Dungeon_ResetSprites ; REPLACE THAT (Sprite initialization) original jsl : $09C114
JSL boss_move
org $829338 ;  JSL Dungeon_ResetSprites ; REPLACE THAT (Sprite initialization) original jsl : $09C114
JSL boss_move
org $828256 ;  JSL Dungeon_ResetSprites ; REPLACE THAT (Sprite initialization) original jsl : $09C114
JSL boss_move
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------

;================================================================================
; Draw kholdstare shell
;--------------------------------------------------------------------------------
org $8DD97F ; jump point
Kholdstare_Draw:

org $9E9518 ; sprite_kholdstare.asm (154) : JSL Kholdstare_Draw
JSL new_kholdstare_code ; Write new gfx in the vram
;--------------------------------------------------------------------------------

;================================================================================
; Draw trinexx shell
;--------------------------------------------------------------------------------
org $1DAD67 ; sprite_trinexx.asm (62) : LDA.b #$03 : STA $0DC0, X
JSL new_trinexx_code : NOP
;--------------------------------------------------------------------------------
