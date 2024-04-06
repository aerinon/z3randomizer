Moldorm_UpdateOamPosition:
{
	PHX

	LDA.l !MOLDORM_EYES_FLAG : TAX
	.more_eyes
	LDA.b $90 : CLC : ADC.w #$0004 : STA.b $90
	LDA.b $92 : CLC : ADC.w #$0001 : STA.b $92
	DEX : BPL .more_eyes ; X >= 0

	PLX
	
	RTL
}
