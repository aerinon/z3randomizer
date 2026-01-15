GoalItemGanonCheck:
	LDA.w SpriteTypeTable, X : CMP.b #$D6 : BNE .success ; skip if not ganon
		LDA.b #$01 : JSL CheckConditionPass
		BCS .success

		.fail
		LDA.w SpriteActivity, X : CMP.b #17 : !BLT .success ; decmial 17 because Acmlm's chart is decimal
		LDA.b #$00
RTL
		.success
		LDA.b OAMOffsetY : CMP.b #$80 ; thing we wrote over
RTL
;--------------------------------------------------------------------------------
; Input A = Type of condition check
; Carry clear = failed check
; Carry set = successful check
CheckConditionPass:
	PHX : PHY
	PHB
		LDY.b #GoalConditionTable>>16 : PHY : PLB : STY.b Scrap02
		REP #$20
		ASL : TAY
		LDA.w GoalConditionTable, Y : STA.b Scrap00
	PHK : PLB
	SEP #$20
	LDY.b #$00
	- LDA.b [Scrap00], Y : CMP.b #$FF : BEQ .exit
		INY : ROL : TAX
		JSR (.conditions, X) : BCC .exit : BRA -

.exit
	PLB : PLY : PLX
RTL

; Y = index after condition code
; Carry = Set if using default target value
.conditions
	dw .always_fail
	dw .pendants
	dw .crystals
	dw .pendant_bosses
	dw .crystal_bosses
	dw .bosses
	dw .agahnim_defeated
	dw .agahnim2_defeated
	dw .goal_item
	dw .collection_rate
	dw .custom_goal
	dw .bingo
	dw .success
	dw .success
	dw .success
	dw .success

.agahnim2_defeated
	LDA.l RoomDataWRAM[$0D].high : AND.b #$08 : BEQ .fail
.bingo ; not implemented yet
.success
	SEC : RTS
.always_fail
.fail
	CLC : RTS
.pendants
	PHP
	LDA.l PendantCounter : PLP : BCC +
		CMP.b #$03 : RTS
.crystals
	PHP
	LDA.l CrystalCounter : PLP : BCC +
		CMP.b #$07 : RTS
.pendant_bosses
	PHP
	LDA.b #$02
	JSR CheckForBossesDefeated : PLP : BCC +
		CMP.b #$03 : RTS
.crystal_bosses
	PHP
	LDA.b #$01
	JSR CheckForBossesDefeated : PLP : BCC +
		CMP.b #$07 : RTS
.bosses
	PHP
	LDA.b #$00
	JSR CheckForBossesDefeated : PLP : BCC +
		CMP.b #$10 : RTS
	+ CMP.b [Scrap00], Y : INY : RTS
.agahnim_defeated
	LDA.l ProgressIndicator : CMP.b #$03 : RTS
.goal_item
	REP #$20
		LDA.l GoalCounter : BCC +
			CMP.l GoalItemRequirement : BRA ++
.collection_rate
	REP #$20
		LDA.l TotalItemCounter : BCC +
			CMP.l TotalItemCount : BRA ++
		+ CMP.b [Scrap00], Y : INY : INY : ++
	SEP #$20
	RTS
.custom_goal
	LDA.b [Scrap00], Y : INY ; options
	PHA : AND.b #$07 : ASL : TAX : PLA
	;JMP CheckConditionPassCustom
	; flows into next function, do not insert code after without uncommenting above

; --------------------------------------------------------------------------------
; Input A = Options value, see GoalConditionTable for format
; Input X = Condition check type index
; Input Y = Index after Options byte
CheckConditionPassCustom:
	PHX : PHA : BIT.b #$08 : PHP
		REP #$30
		LDA.b [Scrap00], Y : INY : INY ; address
	PLP : REP #$30 : BEQ .byte
.word
	TAX
	SEP #$20
	PLA
		AND.b #$10
		REP #$20
		BNE +
			LDA.l $7E0000, X : BRA ++
		+
		LDA.l $7F0000, X : ++
	SEP #$10
	PLX
	REP #$10
	JSR (.comparisons, X)
	INY
	SEP #$30
	RTS
.byte
	TAX
	SEP #$20
	PLA
		AND.b #$10 : BNE +
			LDA.l $7E0000, X : BRA ++
		+
		LDA.l $7F0000, X : ++
	SEP #$10
	PLX
	JMP (.comparisons, X)

.comparisons
	dw .minimum
	dw .exact
	dw .bitfield_nonzero
	dw .bitfield_match
	dw .count_bits
	dw .fail
	dw .fail
	dw .fail

.pass
	INY : SEC : RTS
.count_bits
	JSL CountBits
.minimum
	CMP.b [Scrap00], Y : INY
	RTS
.bitfield_match
	AND.b [Scrap00], Y
.exact
	CMP.b [Scrap00], Y : BEQ .pass
	INY : CLC : RTS
.bitfield_nonzero
	AND.b [Scrap00], Y : BNE .pass
.fail
	INY : CLC : RTS
;--------------------------------------------------------------------------------
GTCutscene_TransferGfx:
	PHA
		REP #$20
		STZ.w DuckPose
		LDA.l GanonsTowerOpenGfx : BEQ .original_crystal
		PHX
			LDX.w ItemStackPtr : STA.l ItemGFXStack,X
			LDA.w #$81C0>>1 : STA.l ItemTargetStack,X
			INX #2 : STX.w ItemStackPtr
		PLX
		SEP #$20
	PLA
RTL
.original_crystal
	SEP #$20
	PLA
	JML TransferItemReceiptToBuffer_using_GraphicsID
;--------------------------------------------------------------------------------
AncillaDraw_GTCutsceneCrystal_OAMPrep:
	LDA.l GanonsTowerOpenGfx : ORA.l GanonsTowerOpenGfx+1 : BEQ .vanilla
		LDA.b #$0E : STA.b (OAMPtr),Y
		INY
		LDA.l GanonsTowerOpenPalette : AND.b #$67 : ASL : ORA.b #$30
		STA.b (OAMPtr),Y
	RTL
.vanilla
	LDA.b #$24 : STA.b (OAMPtr),Y
	INY
	LDA.b #$3C : STA.b (OAMPtr),Y
RTL
;--------------------------------------------------------------------------------
GTCutscene_CrystalMasks:
db %00000000 ; 0 crystals
db %10000000 ;     BIT INDEX DIAGRAM
db %00010010 ;             0
db %00010101 ;          5     1
db %10010101 ;             7
db %10110110 ;          4     2
db %00111111 ;             3
db %10111111 ; 7 crystals
;--------------------------------------------------------------------------------
GTCutscene_ConditionalAnimateCrystals:
	PHX : PHX
	JSR GTCutscene_NumberOfCrystals : TAX : LDA.l GTCutscene_CrystalMasks,X
	PLX
	- LSR : DEX : BPL -
	PLX : BCC .skip_crystal

.draw_crystal
	LDA.b GameSubMode : BEQ + : JML GTCutscene_AnimateCrystals_NoRotate ; what we wrote over
	+ JML GTCutscene_AnimateCrystals_NextCrystal+4

.skip_crystal
	JML GTCutscene_DrawSingleCrystal-3
;--------------------------------------------------------------------------------
GTCutscene_ConditionalDrawSingleCrystal:
	LDA.w RandoOverworldTargetEdge : BEQ .draw_crystal : STZ.w RandoOverworldTargetEdge
	JSR GTCutscene_NumberOfCrystals : TAX
	LDA.l GTCutscene_CrystalMasks,X : AND.b #$80 : BEQ .skip_crystal
.draw_crystal
	LDX.w CurrentSpriteSlot : PHY ; what we wrote over
	JML GTCutscene_DrawSingleCrystal+4
.skip_crystal
	JML GTCutscene_DrawSingleCrystal_SkipCrystal
;--------------------------------------------------------------------------------
GTCutscene_AnimateCrystals_Prep:
	BEQ + : JSL GTCutscene_SparkleALot : + ; thing we wrote over
	JSR GTCutscene_NumberOfCrystals : BNE +
		JML GTCutscene_DrawSingleCrystal_SkipSparkle
	+ CMP.b #$01 : BNE +
		JML GTCutscene_DrawSingleCrystal
	+ INC.w RandoOverworldTargetEdge ; some free ram OWR also uses
	JML GTCutscene_AnimateCrystals_NextCrystal-2
;--------------------------------------------------------------------------------
GTCutscene_ActivateSparkle_SelectCrystal:
	JSR GTCutscene_NumberOfCrystals : BNE +
		TAX : RTL
	+ STA.b Scrap00
	TXA

	- CMP.l Scrap00 : BCC +
	SBC.l Scrap00 : BRA - ; carry guaranteed set

	+ PHY : TAY
	LDA.b Scrap00 : TAX : LDA.l GTCutscene_CrystalMasks,X
	LDX.b #$FF
	- LSR : INX : BCC +
		DEY
	+ BPL -
	PLY
RTL
;--------------------------------------------------------------------------------
; prioritizes: number of gfx used > sum of targets > number of goals
; Scrap00 stores number of goals
; Y sums all goal target values
GTCutscene_NumberOfCrystals:
	PHX : PHY : PHP
	REP #$20
	LDA.l GanonsTowerOpenGfx+2 : BEQ .not_multiple_gfx
		LDX.b #$04
		- LDA.l GanonsTowerOpenGfx, X : BEQ +
			INX : INX : CPX.b #$0E : BCC -
		+
		TXA : LSR
		JMP .done
.not_multiple_gfx
	LDX.b #$00 : LDA.l GoalConditionTable, X
	TXY : STY.b Scrap00
	REP #$10
	SEP #$20
	TAX
	.next
		LDA.l $B00000, X : CMP.b #$FF : BNE + : JMP .use_y : +
			INC.b Scrap00
			ROL : PHP : CMP.b #$10 : BCS .not_8bit_compare
				CMP.b #$0C : BEQ .agas_goal
				CMP.b #$0E : BEQ .agas_goal
				; uses 8-bit targets
				PLP : BCC .use_8bit_target
				CMP.b #$04 : BEQ .crystal_goal ; crystal goal
				CMP.b #$08 : BEQ .crystal_goal ; crystal bosses goal
				CMP.b #$02 : BEQ .pendant_goal ; pendant goal
				CMP.b #$06 : BEQ .pendant_goal ; pendant bosses goal
				BRA .bosses_goal
			.crystal_goal
				LDA.b #$07 : INX : BRA .add_to_y
			.pendant_goal
				LDA.b #$03 : INX : BRA .add_to_y
			.bosses_goal
				INY : INX : BRA .next ; just increment Y by 1 since default of 10 is already more than max 7
			.agas_goal
				PLP : INX : BRA .next
			.use_8bit_target
				INX : LDA.l $B00000, X : INX
			.add_to_y
				PHY : CLC : ADC.b 1,S : PLY : TAY : BRA .next
		.not_8bit_compare
			CMP.b #$14 : BEQ .custom_goal : BCS .unknown
				; triforce hunt/collection rate - uses 16-bit targets
				PLP : INX : BCC +
					LDA.l $B00000, X : INX : INX : BRA .add_to_y
				+ INY : BRA .next
		.custom_goal
			PLP
			INX : LDA.l $B00000, X : BIT.b #$08 : PHP
			INX : INX : INX : AND.b #$03 : BEQ .use_custom_target
				; comparison method doesn't use a quantity, increment Y by 1
				INY : INX : PLP : BEQ +
					INX
				+
				BRA .next
		.use_custom_target
			PLP : BEQ ..8bit
				; 16-bit target
				REP #$20
				LDA.l $B00000, X : CMP.w #$0008 : SEP #$20 : INX : BRA +
			..8bit
				LDA.l $B00000, X : CMP.b #$08 : + : BCC +
					; target exceeds 7, just increment Y by 1
					INY : INX : JMP .next
				+
				INX : BRA .add_to_y
		.unknown ; unknown condition, exit with safe value
			PLP : INY
.use_y
	TYA : BEQ + : CMP.b #$08 : BCC .done
		+ LDA.b Scrap00 : BEQ .use_one : CMP.b #$08 : BCC .done
.use_one
	LDA.b #$01
.done
	PLP : PLY : PLX
	RTS
;--------------------------------------------------------------------------------
CheckTowerOpen:
	LDA.b #$00 : JML CheckConditionPass
;---------------------------------------------------------------------------------------------------
CheckAgaForPed:
        REP #$20
		; seems light_speed option to force blue balls is unused for now
        BRA .vanilla

.light_speed
        SEP #$20
        LDA.l OverworldEventDataWRAM+$80 ; check ped flag
        AND.b #$40
        BEQ .force_blue_ball

.vanilla ; run vanilla check for phase
        SEP #$20
        LDA.w SpriteAux, X
        CMP.b #$02
        RTL

.force_blue_ball
        LDA.b #$01 : STA.w SpriteAuxTable, Y
        LDA.b #$20 : STA.w SpriteTimer, Y
        CLC ; skip the RNG check
        RTL

;---------------------------------------------------------------------------------------------------
CheckForBossesDefeated:
	PHB : PHX : PHY

	STA.b Scrap04 ; 0 = check all, 1 = check crystals, 2 = check pendants
	
	LDA.b #CrystalPendantFlags_3>>16
	PHA : PLB

	STZ.b Scrap03 ; count of number of bosses killed
	STZ.b Scrap05

	REP #$30

	LDY.w #10

.next_check
	LDA.w CrystalPendantFlags_3+2,Y : AND.w #$00FF : BEQ .skip
	CMP.w #$0008 ; C set = pendant, C clear = crystal
	LDA.b Scrap04 : BEQ .proceed
		PHP : ROR : BCC +
			PLP : BCS .skip : BRA .proceed
		+ PLP : BCC .skip

	.proceed
	TYA : ASL : TAX

	LDA.l DungeonMapBossRooms+4,X
	ASL : TAX
	LDA.l RoomDataWRAM.l,X

	AND.w #$0800 : BEQ .skip
		INC.b Scrap03

	.skip
	DEY : BPL .next_check

	SEP #$30
	PLY : PLX : PLB

	LDA.b Scrap03

	RTS
;---------------------------------------------------------------------------------------------------
CheckPedestalPull:
; Out: c - Successful ped pull if set, do nothing if unset.
	if !FEATURE_LIMITED_RUN == 2604
		JSL MasterSword_LimitedCheckIfPulled : BEQ +
			SEC : RTL
		+
	endif
	LDA.b #$02 : JSL CheckConditionPass : BCS .return
		PHX : PHP
			LDA.b GameMode : CMP.b #$0E : BEQ +
			REP #$30
			LDX.w #$0004 : LDA.l GoalConditionTable, X : TAX
			LDA.l $B00000, X : CMP.w #$FF81 : BEQ +
				SEP #$30
				LDA.b #$97 : LDY.b #$01
				JSL Sprite_ShowMessageUnconditional
			+
		PLP : PLX
.return
RTL
