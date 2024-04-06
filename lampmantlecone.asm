;================================================================================
; Lamp Mantle & Light Cone Fix
;--------------------------------------------------------------------------------
; Output: 0 for darkness, 1 for lamp cone
;--------------------------------------------------------------------------------
LampCheck:
	LDA.l LightConeModifier : BNE .lamp
	LDA.l LampEquipment : BNE .lamp ; skip if we already have lantern
	LDA.w DungeonID : CMP.b #$04 : BCS +  ; are we en HC?
		LDA.l LampConeSewers : RTL
	+ : TDC
	.lamp
RTL
;================================================================================
;--------------------------------------------------------------------------------
; Output: 0 locked, 1 open
;--------------------------------------------------------------------------------
CheckForZelda:
        LDA.l ProgressIndicator : CMP.b #$02 : !BLT + ; Skip if rain is falling
                LDA.b #$01 ; pretend we have zelda anyway
                RTL
        +
        LDA.l FollowerIndicator
RTL
;================================================================================
SetOverlayIfLamp:
        JSL LampCheck
        STA.b SUBDESQ ; write it directly to the overlay, this isn't a terrible idea at all
RTL
;================================================================================
; Mantle Object Changes
;--------------------------------------------------------------------------------
Mantle_CorrectPosition:
	LDA.l ProgressFlags : AND.b #$04 : BEQ +
		LDA.b #$0A : STA.w SpritePosXLow, X ; just spawn it off to the side where we know it should be
		LDA.b #$03 : STA.w SpritePosXHigh, X
		LDA.b #$90 : STA.w SpriteSpawnStep, X
	+
	LDA.w SpritePosYLow, X : !ADD.b #$03 ; thing we did originally
RTL

;================================================================================
; Mirror Scroll -> Spawn at Zelda's Cell
;--------------------------------------------------------------------------------
MirrorScrollSpawnZelda:
	LDA.l MirrorEquipment : CMP.b #$01 : BNE +  ;mirror scroll
	LDA.l StartingEntrance : CMP.b #$02 : BEQ ++ ; zelda's cell
	CMP.b #$04 : BNE +
		++ INC.w RespawnFlag
	; what we replaced
	+ STZ.b GameSubMode : STZ.b NMISTRIPES
RTL
