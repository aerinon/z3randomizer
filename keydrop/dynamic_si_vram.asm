; Come in with
;   A = item receipt ID
;   X = slot
RequestStandingItemVRAMSlot:
	PHA

	LDA.w DynamicDropGFXIndex
	INC
	CMP.b #$05 : BCC .fine

	LDA.b #$00

.fine
	STA.w DynamicDropGFXIndex
	STA.w SprItemGFX,X


	PLA : PHX
	; unsure about substitution rules here, because they aren't skipped properly for MW yet
	JSL AttemptItemSubstitution
	JSL ResolveLootIDLong
	JSL ResolveBeeTrapLong
	REP #$30
	ASL : TAX
	LDA.l StandingItemGraphicsOffsets,X
	LDX.w ItemStackPtr
	STA.l ItemGFXStack,X
	LDA.w DynamicDropGFXIndex : AND.w #$000F : ASL : TAX
	LDA.l FreeUWGraphics,X
	LDX.w ItemStackPtr
	STA.l ItemTargetStack,X
	TXA : INC #2 : STA.w ItemStackPtr
	SEP #$30
	PLX

	RTL


;===================================================================================================

FreeUWGraphics:
	dw $8800>>1
	dw $8840>>1
	dw $8980>>1
	dw $9CA0>>1
	dw $9DC0>>1

;	dw $8800>>1
;	dw $8840>>1
;	dw $8980>>1
;	dw $9960>>1 # Arghuss Splash apparently
;	dw $9C00>>1
;	dw $9CA0>>1
;	dw $9DC0>>1

;===================================================================================================

DrawPotItem:
	PHX
	JSL.l AttemptItemSubstitution
	JSL.l ResolveLootIDLong
	TAX
	LDA.l BeeTrapDisguise : BEQ +
		TAX
	+ LDA.l SpriteProperties_standing_width,X : BEQ .narrow

	.full
	PLX
	LDA.b #$01 : STA $06
	LDA #$0C : JSL.l OAM_AllocateFromRegionC
	LDA #$02 : PHA
		REP #$20
		LDA.w #DynamicOAMTile_full
	BRA .draw

	.narrow
	PLX
	LDA.b #$02 : STA $06
	LDA #$10 : JSL.l OAM_AllocateFromRegionC
	LDA #$03 : PHA
		 REP #$20
		 LDA.w #DynamicOAMTile_thin
    .draw
	PHB : PHK : PLB

	STA.b $08
	LDA.w SprItemGFX,X
	AND.w #$00FF
	ASL : ASL : ASL : ASL
	ADC.b $08
	STA.b $08
	SEP #$20
	STZ.b $07

	LDA.b #$00 : STA.l SpriteSkipEOR
	JSL Sprite_DrawMultiple_quantity_preset

	LDA.b $90 : CLC : ADC.b #$08 : STA.b $90
	INC.b $92
	INC.b $92

	PLB
	PLA
	RTL

DynamicOAMTile_thin:
	dw 0, 0 : db $40, $00, $20, $00
	dw 0, 8 : db $50, $00, $20, $00

	dw 0, 0 : db $42, $00, $20, $00
	dw 0, 8 : db $52, $00, $20, $00

	dw 0, 0 : db $4C, $00, $20, $00
	dw 0, 8 : db $5C, $00, $20, $00

	dw 0, 0 : db $E5, $00, $20, $00
	dw 0, 8 : db $F5, $00, $20, $00

	dw 0, 0 : db $EE, $00, $20, $00
	dw 0, 8 : db $FE, $00, $20, $00

DynamicOAMTile_full:
	dw -4, -1 : db $40, $00, $20, $02
	dd 0, 0

	dw -4, -1 : db $42, $00, $20, $02
	dd 0, 0

	dw -4, -1 : db $4C, $00, $20, $02
	dd 0, 0

	dw -4, -1 : db $E5, $00, $20, $02
	dd 0, 0

	dw -4, -1 : db $EE, $00, $20, $02
	dd 0, 0