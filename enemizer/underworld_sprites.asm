LoadUnderworldSprites:
	STA.b $00  ; part one of what we replaced
	LDA.w #$0028 : STA.b $02 ; set the bank to 28 for now
    LDA.w $048E
RTL

GetSpriteSlot16Bit:
	LDA.b $03 : AND #$00FF
	ASL A
	TAY
RTL