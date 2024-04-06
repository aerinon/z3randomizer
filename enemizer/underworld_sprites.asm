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