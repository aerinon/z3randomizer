; adjust oam position after drawing eyes
;ED88E
org $9DD88E
{
    ; original: GiantMoldorm_Draw+5lines (sprite_giant_moldorm.asm)
    ; lda.b $90 : add.w #$0008 : sta.b $90
    ; INC.b $92 : INC.b $92

	JSL Moldorm_UpdateOamPosition
    NOP #08
}

; set number of eyes
;org $9DDBB2 ;$0EDBB2
;{
    ; LDX.b #$01
	; number of eyes (-1)
    ;0EDBB2 0EDBB3
;    LDX.b #$01
;}
