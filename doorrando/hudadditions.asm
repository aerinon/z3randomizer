!BlankTile = $207F
!SlashTile = $2830
!HyphenTile = $2405
!PTile = $296C
!CTile = $295F
!RedSquare = $345E
!BlueSquare = $2C5E

DrHudOverride:
	PHB
	SEP #$30
	LDA.b #$7E
	PHA
	PLB

DRHUD_DrawItemCounter:
	; hides total for mystery seeds
	LDA.l ItemCounterHUD : BEQ DRHUD_DrawIndicators
	LDA.l DRFlags+1 : LSR : BCC DRHUD_DrawIndicators
	REP #$30
	LDY.w #!HyphenTile : STY.w HUDGoalIndicator+$0A : STY.w HUDGoalIndicator+$0C
                       STY.w HUDGoalIndicator+$0E : STY.w HUDGoalIndicator+$10
    SEP #$30

DRHUD_DrawIndicators:
	LDA.b IndoorsFlag : BNE .continue
	JMP DRHUD_Finished
.continue
	LDA.b FrameCounter : AND.b #$10 : BEQ DRHUD_EnemyDropIndicator

DRHUD_BossIndicator:
	LDA.l DRMode : BNE .continue
.early_exit
	REP #$10
	LDY.w #!BlankTile : STY.w HUDMultiIndicator
	JMP DRHUD_Finished
.continue
	LDA.w DungeonID : CMP.b #$1B : BCS .early_exit

	SEP #$10 ; clears the high byte of X and prevents it from getting B register
	TAX

	REP #$30
	LDY.w #!BlankTile
	LDA.w CompassField : AND.l DungeonMask, x
	SEP #$20
	BEQ .draw_indicator
    LDA.l CompassBossIndicator, x : CMP.b RoomIndex : BNE .draw_indicator
    LDY.w #!RedSquare
.draw_indicator
    STY.w HUDMultiIndicator
	BRA DRHUD_DrawCurrentDungeonIndicator

DRHUD_EnemyDropIndicator:
	REP #$30
	LDA.w EnemyDropIndicator : STA.w HUDMultiIndicator
	SEP #$20
	LDA.w DungeonID : CMP.b #$1B : BCS DRHUD_Finished
	SEP #$10 : TAX : REP #$10

DRHUD_DrawCurrentDungeonIndicator: ; mX
    LDA.l DRMode : BIT.b #$02 : BEQ DRHUD_Finished
    LDY.w #!BlankTile
    LDA.w CurrentHealth : BEQ .draw_indicator

    REP #$20 : LDA.l DungeonReminderTable,X : TAY
    SEP #$20
.draw_indicator
	STY.w HUDCurrentDungeonWorld

DRHUD_DrawKeyCounter:
    LDA.l DRFlags : AND.b #$04 : BEQ DRHUD_Finished
    REP #$20
    LDA.w MapField : AND.l DungeonMask, X : BEQ DRHUD_Finished
	TXA : LSR : TAX
	LDA.l GenericKeys : AND.w #$00FF : BNE .total_only
	LDA.w DungeonCollectedKeys, X : JSR ConvertToDisplay : STA.w HUDKeysObtained
	LDA.w #!SlashTile : STA.w HUDKeysSlash
.total_only
	LDA.l ChestKeys, x : JSR ConvertToDisplay : STA.w HUDKeysTotal

DRHUD_Finished:
    PLB : RTL

;===================================================================================================

;column distance for BK/Smalls
HudOffsets:
;   none  hc     east   desert aga    swamp  pod    mire   skull  ice    hera   tt     tr     gt
dw $fffe, $0000, $0006, $0008, $0002, $0010, $000e, $0018, $0012, $0016, $000a, $0014, $001a, $001e

; offset from 1644
RowOffsets:
dw $0000, $0000, $0040, $0080, $0000, $0080, $0040, $0080, $00c0, $0040, $00c0, $0000, $00c0, $0000

ColumnOffsets:
dw $0000, $0000, $0000, $0000, $000a, $000a, $000a, $0014, $000a, $0014, $0000, $0014, $0014, $001e


DrHudDungeonItemsAdditions:
{
    jsl DrawHUDDungeonItems
    lda.l HUDDungeonItems : and.b #$ff : bne + : rtl : +
    lda.l DRMode : cmp.b #$02 : beq + : rtl : +

    phx : phy : php
    rep #$30

    lda.w #$24f5 : sta.w $1606 : sta.w $1610 : sta.w $161a : sta.w $1624
    sta.w $1644 : sta.w $164a : sta.w $1652 : sta.w $1662 : sta.w $1684 : sta.w $16c4
    ldx.w #$0000
    - sta.w $1704, x : sta.w $170e, x : sta.w $1718, x
    inx #2 : cpx.w #$0008 : !BLT -

    lda.l HudFlag : and.w #$0020 : beq + : JMP ++ : +
    lda.l HUDDungeonItems : and.w #$0007 : bne + : JMP ++ : +
    	; bk symbols
		lda.w #$2811 : sta.w $1606 : sta.w $1610 : sta.w $161a : sta.w $1624
		; sm symbols
		lda.w #$2810 : sta.w $160a : sta.w $1614 : sta.w $161e : sta.w $16e4
    	; blank out stuff
    	lda.w #$24f5 : sta.w $1724

        ldx.w #$0002
        	- lda.w #$0000 : !ADD.l RowOffsets,x : !ADD.l ColumnOffsets, x : tay
        	lda.l DungeonReminderTable, x : sta.w $1644, y : iny #2
        	lda.w #$24f5 : sta.w $1644, y
        	lda.l MapField : and.l DungeonMask, x : beq + ; must have map
        		jsr BkStatus : sta.w $1644, y : bra .smallKey ; big key status
        	+ lda.l BigKeyField : and.l DungeonMask, x : beq .smallKey
        		lda.w #$2826 : sta.w $1644, y
        	.smallKey
        	+ iny #2
			cpx.w #$001a : bne +
				tya : !ADD.w #$003c : tay
        	+ stx.b Scrap00
        		txa : lsr : tax
        		lda.w #$24f5 : sta.w $1644, y
        		lda.l GenericKeys : and.w #$00FF : bne +
        		lda.l DungeonKeys, x : and.w #$00FF : beq +
        			jsr ConvertToDisplay2 : sta.w $1644, y
        		+ iny #2 : lda.w #$24f5 : sta.w $1644, y
        		phx : ldx.b Scrap00
        			lda.l MapField : and.l DungeonMask, x : beq + ; must have map
        				plx : sep #$30 : lda.l ChestKeys, x : sta.b Scrap02
        				lda.l GenericKeys : bne +++
        					lda.b Scrap02 : !SUB.l DungeonCollectedKeys, x : sta.b Scrap02
        				+++ lda.b Scrap02
        				rep #$30
        				jsr ConvertToDisplay2 : sta.w $1644, y ; small key totals
        				bra .skipStack
        		+ plx
        		.skipStack iny #2
        		cpx.w #$000d : beq +
        			lda.w #$24f5 : sta.w $1644, y
        		+
        	ldx.b Scrap00
            + inx #2 : cpx.w #$001b : bcs ++ : JMP -
    ++
    lda.l HudFlag : and.w #$0020 : bne + : JMP ++ : +
    lda.l HUDDungeonItems : and.w #$000c : bne + : JMP ++ : +
        ; map symbols (do I want these) ; note compass symbol is 2c20
        lda.w #$2821 : sta.w $1606 : sta.w $1610 : sta.w $161a : sta.w $1624
        ; blank out a couple thing from old hud
        lda.w #$24f5 : sta.w $16e4 : sta.w $1724
        sta.w $160a : sta.w $1614 : sta.w $161e ; blank out sm key indicators
        ldx.w #$0002
        	- lda.w #$0000 ; start of hud area
        	!ADD.l RowOffsets, x : !ADD.l ColumnOffsets, x : tay
        	lda.l DungeonReminderTable, x : sta.w $1644, y
        	iny #2
        	lda.w #$24f5 : sta.w $1644, y ; blank out map spot
        	lda.l MapField : and.l DungeonMask, x : beq + ; must have map
        		JSR MapIndicatorShort : STA.w $1644, Y
			+ iny #2
            cpx.w #$001a : bne +
				tya : !ADD.w #$003c : tay
			+ lda.l CompassField : and.l DungeonMask, x : beq + ; must have compass
                phx ; total chest counts
                    LDA.l CompassTotalsWRAM, x : !SUB.l DungeonLocationsChecked, x
                    SEP #$30 : JSR HudHexToDec2DigitCopy : REP #$30
                    lda.b Scrap06 : jsr ConvertToDisplay2 : sta.w $1644, y : iny #2
                    lda.b Scrap07 : jsr ConvertToDisplay2 : sta.w $1644, y
                plx
                bra .skipBlanks
			+ lda.w #$24f5 : sta.w $1644, y : iny #2 : sta.w $1644, y
            .skipBlanks iny #2
            cpx.w #$001a : beq +
				lda.w #$24f5 : sta.w $1644, y ; blank out spot
            + inx #2 : cpx.w #$001b : !BGE ++ : JMP -
    ++
    plp : ply : plx : rtl
}

MapIndicatorLong:
	PHX
		LDA.l OldHudToNewHudTable, X : TAX
		JSR MapIndicator
	PLX
RTL

MapIndicatorShort:
	PHX
		TXA : LSR : TAX
		JSR MapIndicator
	PLX
RTS

OldHudToNewHudTable:
	dw 1, 2, 3, 10, 4, 6, 5, 8, 11, 9, 7, 12, 13

IndicatorCharacters:
	;  check      1      2      3      4      5      6      7      G      B      R
	dw $2426, $2817, $2818, $2819, $281A, $281B, $281C, $281D, $2590, $258B, $259B

MapIndicator:
	LDA.l CrystalPendantFlags_3, X : AND.w #$00FF
	PHX
		ASL : TAX : LDA.l IndicatorCharacters, X
	PLX
RTS

BkStatus:
    lda.l BigKeyField : and.l DungeonMask, x : bne +++ ; has the bk already
         lda.l BigKeyStatus, x : bne ++
            lda.w #$2827 : rts ; 0/O for no BK
         ++ cmp.w #$0002 : bne +
            lda.w #$2420 : rts ; symbol for BnC
    + lda.w #$24f5 : rts ; black otherwise
    +++ lda.w #$2826 : rts ; check mark

ConvertToDisplay:
    and.w #$00ff : cmp.w #$000a : !BLT +
        !ADD.w #$2553 : rts
    + !ADD.w #$2490 : rts

ConvertToDisplay2:
    and.w #$00ff : beq ++
        cmp.w #$000a : !BLT +
            !ADD.w #$2553 : rts ; 2580 with 258A as "A" for non transparent digits
        + !ADD.w #$2816 : rts
    ++ lda.w #$2827 : rts ; 0/O for 0 or placeholder digit ;2483

CountAbsorbedKeys:
    JML IncrementSmallKeysNoPrimary

;================================================================================
; 8-bit registers
; in:	A(b) - Byte to Convert
; out:	$06 - $07 (high - low)
;================================================================================
HudHexToDec2DigitCopy: ; modified
	PHY
		LDY.b #$00
		-
			CMP.b #10 : !BLT +
			INY
			SBC.b #10 : BRA -
		+
		STY.b Scrap06 : LDY.b #$00 ; Store 10s digit and reset Y
		CMP.b #1 : !BLT +
		-
			INY
			DEC : BNE -
		+
		STY.b Scrap07	; Store 1s digit
	PLY
RTS
