pushpc

org $8691B6
SpritePrep_Eyegore_bounce:
JSL SpritePrep_EyegoreNew

org $868839  ; 0xEF
dw SpritePrep_Eyegore_bounce
dw SpritePrep_Eyegore_bounce

;org $869468 ; These need to go else where
;dw #$BFF7  ; SpriteModule_Active_Bank1E_bounce
;dw #$BFF7  ; SpriteModule_Active_Bank1E_bounce

;org $9E8B21
;JSL FixVectorForMimics

;org $9E8BBB ; New vectors for mimics
;dw #$C795
;dw #$C795

org $9EC70D
SpritePrep_Eyegore_become_mimic:

;org $86EC08 ; Sprite_AttemptZapDamage
;JSL resetSprite_Mimic : NOP

org $86ED9E ; Sprite_ApplyCalculatedDamage, skip high sprite id early exit
JSL IsItReallyAMimic : NOP

org $86EDA6 ; Sprite_ApplyCalculatedDamage .not_absorbable
JSL notItemSprite_Mimic

pullpc


;FixVectorForMimics:
;	CMP.w $#00EF : BCC .end
;		SBC.w #$0032  ; this puts the vector at the unused bytes at UNREACHABLE_1E8BBB
;	.end
;	AND.w #$00FF ; what we wrote over
;	ASL A
;RTL

; replace SpritePrep_Eyegore if flag is on
SpritePrep_EyegoreNew:
{
    LDA.l !ENABLE_MIMIC_OVERRIDE : BNE .new
        ; old
        JSL SpritePrep_Eyegore
        RTL

    .new
    LDA.w SpriteTypeTable, X : CMP.b #$EF : BCS .mimic ;If sprite id >= EF (unused somaria platform)
        ; seems unnecessary it's just an rtl?
;        JSL $9EC71A ; 0xF471A set eyegore to be only eyegore (.not_goriya?)
    RTL
    .mimic
    	SBC.b #$6C : STA.w SpriteTypeTable, X : JSL SpritePrep_LoadProperties ; pretending to be $83 or $84
    	JSL SpritePrep_Eyegore_become_mimic
;        LDA.w SpriteTypeTable, X : ADC.b #$6C : STA.w SpriteTypeTable, X ; set the sprite back to special mimic
        ; todo? unsure about this code - seems unnecessary
;        LDA.w $0CAA, X : AND.b #$FB : ORA.b #$80 : STA.w $0CAA, X ; STZ.w $0CAA, X
RTL
}

;resetSprite_Mimic:
;    LDA.l !ENABLE_MIMIC_OVERRIDE : BEQ .notMimic ; skip to what it would have done normally
;
;    LDA.w SpriteTypeTable, X
;    CMP.b #$EF : BCC .notMimic
;    LDA.w SpriteTypeTable, X : SBC.b #$6C : STA.w SpriteTypeTable, X ; overwrite the sprite id with eyegore id
;
;.notMimic
;     restore code
;    LDA.w SpriteTypeTable, X : CMP.b #$7A
;RTL

IsItReallyAMimic:
	LDA.l !ENABLE_MIMIC_OVERRIDE : BEQ .continue
	LDA.w SpriteTypeTable,X : CMP.b #$EF : BEQ .is_mimic
	CMP.b #$F0 : BNE .continue

	.is_mimic
	CLC : RTL

	.continue  ; code we hijacked
	LDA.w SpriteTypeTable,X
    CMP.b #$D8
RTL

; this is just for killable thieves now
notItemSprite_Mimic:
;     if we set killable thief we want to update the sprite id so it can be killed
    LDA.w SpriteTypeTable, X
    CMP.l !KILLABLE_THIEVES_ID : BNE .continue ; thief #$C4 (default is B8/dialog tester)

    ; if we don't have mimic code turned on we want to skip, but we also need to reload the sprite id because we just smoked it with this LDA
;    LDA.l !ENABLE_MIMIC_OVERRIDE : BEQ .reloadSpriteIdAndSkipMimic ; skip to what it would have done normally

;    LDA.w SpriteTypeTable, X ; I hate assembly
;    CMP.b #$EF : BCC .continue
;    SBC.b #$6C : BRA .continue

.changeSpriteId
    LDA.b #$83 ; load green eyegore sprite id so we can kill the thing

.continue
    ; restore code
    REP #$20 : ASL #2
RTL