Moldorm_UpdateOamPosition:
{
	PHX

	LDA.l !MOLDORM_EYES_FLAG : TAX
	.more_eyes
	LDA.b OAMPtr : CLC : ADC.w #$0004 : STA.b OAMPtr
	LDA.b OAMPtr+2 : CLC : ADC.w #$0001 : STA.b OAMPtr+2
	DEX : BPL .more_eyes ; X >= 0

	PLX
	
	RTL
}
