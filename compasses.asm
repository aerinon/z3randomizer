;--------------------------------------------------------------------------------
; $7F5010 - Scratch Space
;--------------------------------------------------------------------------------

DrawDungeonCompassCounts:
        SEP #$10
	LDX $1B : BNE + : RTL : + ; Skip if outdoors

	; extra hard safeties for getting dungeon ID to prevent crashes
	PHA
	LDA.w $040C : AND.w #$00FE : TAX ; force dungeon ID to be multiple of 2
	PLA

	CPX.b #$1B : BCC + ; Skip if not in a valid dungeon ID
		JMP .done
	+
	BIT.w #$0002 : BNE ++ ; if CompassMode==2, we don't check for the compass
		TXY : TXA : LSR : TAX : LDA.l ExistsTransfer, X : TAX : LDA CompassExists, X : BEQ ++
		TYX : LDA CompassField : AND.l DungeonItemMasks, X ; Load compass values to A, mask with dungeon item masks
		BNE ++
			JMP .done ; skip if we don't have compass
	++

	LDA $040C : LSR
	BNE +
		INC
	+ TAX : LDA.l CompassTotalsWRAM, X : AND #$00FF
	PHX
		PHA
			JSL HexToDec_fast
		PLA : CMP.w #100 : !BLT .two_digit
			LDX.b $05 : TXA : ORA #$2490 : STA $7EC79A
			LDX.b $06 : TXA : ORA #$2490 : STA $7EC79C
			LDX.b $07 : TXA : ORA #$2490 : STA $7EC79E
			BRA .end_total
		.two_digit
		LDX.b $06 : TXA : ORA #$2490 : STA $7EC79A
		LDX.b $07 : TXA : ORA #$2490 : STA $7EC79C
	.end_total
	PLX

	LDA DungeonLocationsChecked, X : AND #$00FF
	PHA
		JSL HexToDec_fast
	PLA : CMP.w #100 : !BLT +
		LDX.b $05 : TXA : ORA #$2490 : STA $7EC792 ; Draw the 100's digit
	+
	LDX.b $06 : TXA : ORA #$2490 : STA $7EC794 ; Draw the item count
	LDX.b $07 : TXA : ORA #$2490 : STA $7EC796
	LDA.w #$2830 : STA $7EC798 ; draw the slash

	.done
RTL

DungeonItemMasks: ; these are dungeon correlations to $7EF364 - $7EF369 so it knows where to store compasses, etc
    dw $8000, $4000, $2000, $1000, $0800, $0400, $0200, $0100
    dw $0080, $0040, $0020, $0010, $0008, $0004

; maps from $040C to the odd order used in overworld map
ExistsTransfer:
db $0C, $0C, $00, $02, $0B, $09, $03, $07, $04, $08, $01, $06, $05, $0A

;--------------------------------------------------------------------------------
; $7EF4C0-7EF4CF - item locations checked indexed by $040C >> 1
;--------------------------------------------------------------------------------
InitCompassTotalsRAM:
        LDX #$00
        -
                LDA CompassTotalsROM, X : STA CompassTotalsWRAM, X
                INX
                CPX #$0F : !BLT -
RTL
