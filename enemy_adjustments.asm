;--------------------------------------------------------------------------------
; NewBatInit:
; make sure bats always load LW stats
;--------------------------------------------------------------------------------
NewBatInit:
	CPY.b #$00 : BEQ .light_world
	;check if map id == 240 or 241
	LDA.b RoomIndex : CMP.b #$F0 : BEQ .light_world ;oldman cave1
	CMP.b #$F1 : BEQ .light_world ;oldman cave2
	CMP.b #$B0 : BEQ .light_world ;agahnim statue keese
	CMP.b #$D0 : BEQ .light_world ;agahnim darkmaze

	
	LDA.b #$85 : STA.w SpriteBump, X
	LDA.b #$04 : STA.w SpriteHitPoints, X
RTL
	.light_world
		LDA.b #$80 : STA.w SpriteBump, X
		LDA.b #$01 : STA.w SpriteHitPoints, X
RTL
;--------------------------------------------------------------------------------
NewFireBarDamage:
        LDA.b LinkLayer : CMP.w SpriteLayer, X : BNE .NotSameLayer
                JSL Sprite_AttemptDamageToPlayerPlusRecoilLong
                RTL
.NotSameLayer
RTL

;===================================================================================================

SnitchGuardMusic = $0E90 ; this seems safe?

TryGuardMusic:
	; check if we were spawned by a snitch
	LDA.w SnitchGuardMusic,X
	BEQ .exit

	LDA.w $0136 ; check for overworld song bank
	BNE .fail

	LDA.b #$0C ; SONG 0C
	CMP.w $0130
	BEQ .fail ; don't duplicate

	STA.w $012C

.exit
	RTL

.fail
	STZ.w SnitchGuardMusic,X
	RTL

;---------------------------------------------------------------------------------------------------

TryUndoGuardMusic:
	LDA.w SnitchGuardMusic,X
	BEQ .exit

	
	LDY.w $0136 ; check for overworld song bank
	BNE .exit

	CPY.w $0130 ; don't duplicate
	BEQ .exit

	LDY.w $012C ; don't override
	BNE .exit

	STA.w $012C

.exit
	RTL

;---------------------------------------------------------------------------------------------------
; only used when actually called by a snitch
;---------------------------------------------------------------------------------------------------
FinalizeSnitchGuard:
	LDA.b #$0B : STA.w $0F50,Y
	LDA.w $0130 : STA.w SnitchGuardMusic,Y ; remember last song played
	PLB
	RTL
