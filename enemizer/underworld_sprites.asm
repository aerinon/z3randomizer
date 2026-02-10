LoadUnderworldSprites:
	STA.b Scrap00  ; part one of what we replaced
	LDA.w #UWSpritesData>>16 : STA.b Scrap02 ; set the bank to 28 for now
    LDA.w $048E
RTL

GetSpriteSlot16Bit:
	LDA.b Scrap03 : AND.w #$00FF
	ASL A
	TAY
RTL

GeldmanDrawOverride:
    PLA : PLA : PLA ; fix the call stack
    LDA.l DRFlags+1 : AND.b #$08 : BEQ .vanilla

    LDA.b #$01
    STA.w SpriteGFXControl, X
    JML Sprite_4C_Geldman_do_indeed_draw

.vanilla
    JSL Sprite_PrepOAMCoordLong
    JML Sprite_4C_Geldman_continue

StalfosKnightDrawOverride:
		LDA.l DRFlags+1 : AND.b #$08 : BEQ .vanilla

    JSL Sprite_PrepOAMCoordLong
    LDA.b #$12
		JML Sprite_DrawShadowLong

.vanilla
    JSL Sprite_PrepOAMCoordLong
    RTL

BlobDrawOverride:
    PLA : PLA : PLA ; fix the call stack
    LDA.l DRFlags+1 : AND.b #$08 : BEQ .vanilla

    LDA.b #$05
    STA.w SpriteGFXControl, X

    JML SpriteDraw_Blob_head_popping_out

.vanilla
    JSL Sprite_PrepOAMCoordLong
    JML SpriteDraw_Blob_bad_gfx