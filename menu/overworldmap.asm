pushpc

org $8ABABE : JSL WorldMap_LoadChrHalfSlot

org $8ABDF6
WorldMapIcon_DungeonPointers: ; dungeon idx order
dw WorldMapIcon_pos_hc
dw $0000
dw WorldMapIcon_pos_ep
dw WorldMapIcon_pos_dp
dw WorldMapIcon_pos_at
dw WorldMapIcon_pos_sp
dw WorldMapIcon_pos_pod
dw WorldMapIcon_pos_mm

dw WorldMapIcon_pos_sw
dw WorldMapIcon_pos_ip
dw WorldMapIcon_pos_toh
dw WorldMapIcon_pos_tt
dw WorldMapIcon_pos_tr
dw WorldMapIcon_pos_gt

WorldMapIcon_ExtraPointers: ; dungeon idx order
dw WorldMapIcon_extrapos_hc
dw $0000

dw $0000
dw WorldMapIcon_extrapos_dp
dw $0000
dw $0000
dw $0000
dw $0000
dw WorldMapIcon_extrapos_sw
dw $0000

dw $0000
dw $0000
dw WorldMapIcon_extrapos_tr
dw $0000

warnpc $8ABE2E
org $8ABE2E
; located posx/posy, dislocated posx/posy, prize posx/posy
; located = proper location of icon (default: if you have map)
; dislocated = location of icon if proper location is hidden from player
; highest bit on first posx indicates which world it should show in
; $FFxx on X coord means skip drawing
WorldMapIcon_pos:
.hc
dw $FF00, $FF00, $FF00, $FF00, $FF00, $FF00
.ep
dw $0F30, $06E0, $FF00, $FF00, $0F30, $06E0
.dp
dw $0170, $0E50, $FF00, $FF00, $0170, $0E50
.at
dw $FF00, $FF00, $FF00, $FF00, $FF00, $FF00
.sp
dw $8790, $0FD0, $FF00, $FF00, $8790, $0FD0
.pod
dw $8F30, $06E0, $FF00, $FF00, $8F30, $06E0
.mm
dw $8160, $0D80, $FF00, $FF00, $8160, $0D80
.sw
dw $80F0, $0160, $FF00, $FF00, $80F0, $0160
.ip
dw $8CB0, $0E80, $FF00, $FF00, $8CB0, $0E80
.toh
dw $0900, $0130, $FF00, $FF00, $0900, $0130
.tt
dw $8240, $0840, $FF00, $FF00, $8240, $0840
.tr
dw $8F30, $01B0, $FF00, $FF00, $8F30, $01B0
.gt
dw $FF00, $FF00, $FF00, $FF00, $FF00, $FF00

warnpc $8ABECA
org $8ABECA
; additional icons posx/posy (terminator = $FFxx)
; additional icons only show if located
; highest bit on posx indicates which world it should show in
WorldMapIcon_extrapos:
.hc
dw $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FFFF
.dp
dw $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FFFF
.sw
dw $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FFFF
.tr
dw $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FFFF

; FREE: 0x15 bytes, for any future usage of extra icons ^^^

warnpc $8ABF2B
org $8ABF2B
WorldMapIcon_Numbers:
db $7F, $79, $6C, $6D, $6E, $6F, $7C, $7D, $7E

org $8ABF34
PrizeExists:
dw $37F8

org $8ABF36
; vhpp ccco  tttttttt
; v/h - vert/horiz flip
; p - draw priority
; c - color palette idx
; o - OAM page change
; t - VRAM tile idx
WorldMapIcon_prize_tile:
db $00, $00 ;                ; Hyrule Castle
db $00, $00 ;                ; Sewers
db $38, $60 ; green pendant  ; Eastern Palace
db $34, $60 ; blue pendant   ; Desert Palace
db $00, $00 ;                ; Agahnim's Tower
db $34, $64 ; crystal        ; Swamp Palace
db $34, $64 ; crystal        ; Dark Palace
db $32, $64 ; red crystal    ; Misery Mire
db $34, $64 ; crystal        ; Skull Woods
db $32, $64 ; red crystal    ; Ice Palace
db $32, $60 ; red pendant    ; Tower of Hera
db $34, $64 ; crystal        ; Thieves' Town
db $34, $64 ; crystal        ; Turtle Rock
db $00, $00 ;                ; Ganon's Tower

warnpc $8ABF52
org $8ABF52
WorldMapIcon_dungeon_tile:
db $1A, $7E ; white H ; Hyrule Castle
db $00, $00 ;         ; Sewers
db $14, $7B ; blue 1  ; Eastern Palace
db $14, $6B ; blue 2  ; Desert Palace
db $1A, $7D ; white A ; Agahnim's Tower
db $12, $79 ; red 2   ; Swamp Palace
db $12, $7F ; red 1   ; Dark Palace
db $12, $6F ; red 6   ; Misery Mire
db $12, $6C ; red 3   ; Skull Woods
db $12, $6E ; red 5   ; Ice Palace
db $14, $7A ; blue 3  ; Tower of Hera
db $12, $6D ; red 4   ; Thieves' Town
db $12, $7C ; red 7   ; Turtle Rock
db $12, $66 ; skull   ; Ganon's Tower
; db $22, $68 ; red X

warnpc $8ABF6E
org $8ABF6E
CompassExists:
dw $37FC

; mirror portal fixes
org $8ABF74
db $24, $64, $E4, $A4 ; lowering mirror portal draw priority
org $8ABFFA
db $4C ; use other mirror portal gfx
org $8AC00E
db $01 ; draw in 2nd OAM slot

org $8AC012 ; <- 54012 - Bank0A.asm:1039 (LDA $7EF2DB : AND.b #$20 : BNE BRANCH_DELTA)
BRA + : NOP #6 : + ; skip pyramid open check

; Scrap
; $00/$01 = Dungeon Pointer
; $02/$03 = Extra Pointer
; $04 = Current World
; $05 = Current Dungeon
; $06 = Helper Bitfield
; $0A = Used as flag to draw icon overlay
; $0B-$0F = OAM GFX Data
org $8AC02B
DrawPrizesOverride:
	PHB : LDA.b #WorldMapIcon_DungeonPointers>>16 : PHA : PLB
		LDA.l CurrentWorld : STA.b Scrap04
		LDY.b #$00 : STY.b Scrap0A
		REP #$20
		LDA.w #$0800+8 : STA.b OAMPtr
		LDA.w #$0A20+2 : STA.b OAMPtr+2
		LDY.b #$1A
		.next_dungeon
		STY.b Scrap05
		REP #$20
		LDA.w WorldMapIcon_DungeonPointers,Y : BNE + : JMP .advance : +
			STA.b Scrap00
			LDA.w WorldMapIcon_ExtraPointers,Y : STA.b Scrap02
			JSR WorldMap_CheckForDungeonState
			LDA.w WorldMapIcon_dungeon_tile,Y : BNE + : JMP .advance : +
			XBA : STA.b Scrap0C
			TAX : CPX.b #$68 : BNE +
				; handle red X animation
				PHX
				LDA.b FrameCounter : LSR #3 : AND.w #$0003 : TAX
				LDA.l WorldMap_RedXChars,X : TAX : STX.b Scrap0D
				PLX : CPX.b #$68
				BRA .do_dungeon
			+
			LDA.b FrameCounter : AND.w #$0010 : BEQ + : JMP .show_prizes : +
				.do_dungeon
				; determine tile size
				LDX.b #$00 : BCS +
					LDX.b #$02
				+ STX.b Scrap0B

				LDA.l CompassMode : AND.w #$00F0 : ORA.b Scrap06
				BIT.w #$0040 : BEQ .main_dungeon_icon
				BIT.w #$0003 : BEQ .main_dungeon_icon
					; draw additional dungeon icon under prize
					LDY.b #$08 ; 8 is located
					BIT.w #$0002 : BNE +
						LDY.b #$04 ; 4 is dislocated
					+
					JSR WorldMap_ValidateCoords : BCS .main_dungeon_icon
					JSR WorldMap_DrawTile

				; determine located/dislocated/hidden
				.main_dungeon_icon
				LDA.l CompassMode : AND.w #$00F0 : ORA.b Scrap06
				BIT.w #$0020 : BEQ + : BIT.w #$0004 : BNE .show_dungeon ; compass mode, show dungeon icon if its allowed to
				+ BIT.w #$0040 : BEQ + : BIT.w #$0008 : BNE .show_dislocated_dungeon : JMP .advance : + ; hidden
				.show_dungeon
				LDY.b #$00 ; 0 is located
				BIT.w #$0004 : BNE + : BIT.w #$0030 : BEQ +
					.show_dislocated_dungeon
					LDY.b #$04 ; 4 is dislocated
				+

				; determine if draw and/or continue
				JSR WorldMap_ValidateCoords : BCC +
					BNE .extras : BRA .advance
				+
				JSR WorldMap_DrawTile

				; TODO: draw X if prize icon is X?... here?
				.extras
				CPY.b #$04 : BCS .advance ; dislocated dungeon skips extras
				LDA.b Scrap02 : BEQ .advance : STA.b Scrap00
				LDY.b #$00
				.next_icon
				JSR WorldMap_ValidateCoords : BCC +
					BEQ .advance : INY #4 : BRA .next_icon
				+
				JSR WorldMap_DrawTile
				BRA .next_icon
			.show_prizes
			LDA.w WorldMapIcon_prize_tile,Y : BEQ .advance
			XBA : STA.b Scrap0C
			LDX.b #$02 : STX.b Scrap0B ; all prize icons are wide

			; determine located/dislocated/unknown
			LDA.l CompassMode : AND.w #$00F0 : ORA.b Scrap06
			LDY.b #$04 ; 4 is dislocated
			BIT.w #$000B : BEQ .advance
			BIT.w #$0008 : BNE .prize_known_check
			BIT.w #$0002 : BEQ +
				LDY.b #$08 ; 8 is located
				.prize_known_check
				BIT.w #$0001 : BNE +
					; don't know what prize
					BIT.w #$0040 : BEQ .advance
						; red X
						STZ.b Scrap0B
						LDA.b FrameCounter : LSR #3 : AND.w #$0003 : TAX
						LDA.l WorldMap_RedXChars,X : AND.w #$00FF : ORA.w #$2200 : STA.b Scrap0C
			+

			; determine if draw and/or continue
			JSR WorldMap_ValidateCoords : BCS .advance
			JSR WorldMap_DrawTileOverlay
			JSR WorldMap_DrawTile
		.advance
		LDY.b Scrap05 : DEY #2 : BMI + : JMP .next_dungeon : +
	PLB
	PLA : XBA : STA.l $7EC10A
	PLA : XBA : STA.l $7EC108
	SEP #$20
RTS

; returns with C set if we skip drawing
; returns with Z unset if we want to continue loop for this dungeon
WorldMap_ValidateCoords:
	; checks if icon is valid
	LDA.b (Scrap00),Y : CMP.w #$FF00 : LDX.b #$00 : BCS .fail ; exits with C and Z set
	BIT.w #$8000 : BEQ +
		LDX.b #$40
	+
	; checks if icon is for this world
	CPX.b Scrap04 : BNE .fail ; exits with C set and Z unset
	AND.w #$7FFF : STA.l $7EC10A
	INY #2 : LDA.b (Scrap00),Y : STA.l $7EC108
	INY #2
CLC : RTS
.fail
SEC : RTS

WorldMap_DrawTileOverlay:
	LDA.l CompassMode : AND.w #$0040 : BEQ +
		LDA.b Scrap05 : BIT.w #$0100 : BEQ .skip+1
		LSR : AND.w #$000F : TAX
		LDA.l CrystalPendantFlags_3,X : TAX : BEQ .skip+1
		CPX.b #$08 : !BGE +
			LDA.b Scrap0C : PHA
			LDA.l WorldMapIcon_Numbers-1,X
				AND.w #$00FF : ORA.w #$3A00 : STA.b Scrap08
		BRA .do_overlay
	+
	LDA.b Scrap0C : PHA
	AND.w #$FF00 : ORA.w #$006A : STA.b Scrap08 ; temp store overlay tile info
	LDA.b 1,S : AND.w #$0EFF
	CMP.w #$0264 : BEQ .do_overlay ; red crystal
	CMP.w #$0860 : BEQ .do_overlay ; green pendant

	.skip
	PLA
RTS
	.do_overlay
	LDX.b Scrap0B : PHX
		LDX.b #$01 : STX.b Scrap0A
		DEX : STX.b Scrap0B
		LDA.b Scrap08 : STA.w Scrap0C
		JSR WorldMap_DrawTile
		LDX.b #$00 : STX.b Scrap0A
	PLX : PLA : STX.b Scrap0B : STA.b Scrap0C
RTS

WorldMap_DrawTile:
	LDA.b Scrap00 : PHA
	SEP #$20
	LDX.b Scrap0B : TXA : STA.b (OAMPtr+2)
	INC.b OAMPtr+2
	REP #$20
	LDA.l $7EC10A : BIT.w #$4000 : SEP #$20 : BNE .raw_coords ; use raw OAM coordinates
		JSR WorldMap_CalculateOAMCoordinates
		BRA .apply_offsets
	.raw_coords
		STA.b Scrap0E
		LDA.l $7EC108 : STA.b Scrap0F
.apply_offsets
	LDX.b Scrap0A : BNE .aligned ; prize number/overlay: no offset
	LDX.b Scrap0B : BEQ +
		; 16x16 sprite: -8 pixels
		LDA.b Scrap0E : SEC : SBC.b #$08 : STA.b Scrap0E
		LDA.b Scrap0F : SBC.b #$08 : STA.b Scrap0F
		BRA .aligned
	+
	; 8x8 sprite: -4 pixels
	LDA.b Scrap0E : SEC : SBC.b #$04 : STA.b Scrap0E
	LDA.b Scrap0F : SBC.b #$04 : STA.b Scrap0F
.aligned
	REP #$20
	PLA : STA.b Scrap00
	LDA.b Scrap0E : STA.b (OAMPtr)
	INC.b OAMPtr : INC.b OAMPtr
	LDA.b Scrap0C : STA.b (OAMPtr)
	INC.b OAMPtr : INC.b OAMPtr
RTS

; Y - dungeon index
; TODO: This is terribly inefficient and needs to be rewritten someday
; DungeonItemMasks = 16-bit mask for bitfields
; DungeonsCompleted = 16-bit bitfield for beaten bosses
; MapMode = flag is maps are not wild
; MapField = 16-bit bitfield for collected maps
; MapOverlay = 16-bit bitfield for revealed prizes via Saha/Bomb Shop
; CompassMode = (repurposed version of MapMode above)
;    0x80 = flag is compasses are not wild (similar to MapMode)
;    0x10 = Maps reveals location of dungeons
;    0x20 = Compass reveals location of dungeons
;    0x40 = Boss kill reveals location of prize
; CompassField = 16-bit bitfield for collected compasses
WorldMap_CheckForDungeonState:
	PHY : TYX
		LDY.b #$00 ; used as bitfield
		; determine if prize is revealed
		LDA.l MapMode : AND.w #$0001 : BEQ .setRevealPrize ; 0 = always show, 1 = requires map
		LDA.l MapField : ORA.l MapOverlay : AND.l DungeonItemMasks,X : BEQ +
			.setRevealPrize
			TYA : ORA.w #$0001 : TAY
		+

		; determine if prize is located
		LDA.l CompassMode : BIT.w #$0040 : BEQ + ; boss defeated
			JSR WorldMap_CheckPrizeCollected : BCC ++
				TYA : AND.w #$00FD : ORA.w #$0008 : TAY ; prize collected, hide prize icons
				BRA .dungeon_icon
			++ LDA.l DungeonsCompleted : AND.l DungeonItemMasks,X : BEQ ++
				.setLocatePrize
				TYA : ORA.w #$0002 : TAY
				BRA .dungeon_icon
			++ LDA.l MapOverlay : AND.l DungeonItemMasks,X : BNE .setLocatePrize
			BRA .dungeon_icon
		+ BIT.w #$0030 : BNE + ; Default ow map
			.defaultPrizeCheck
			LDA.l MapMode : AND.w #$00FF : BEQ .setLocatePrize ; 0 = always show, 1 = requires map
			LDA.l MapField : ORA.l MapOverlay : AND.l DungeonItemMasks,X : BNE .setLocatePrize
			BRA .dungeon_icon
		+ BIT.w #$0020 : BEQ + ; compass collected
			BIT.w #$0080 : BEQ .setLocatePrize ; 0 = always show, 1 = require compass
			LDA.l CompassExists : AND.l DungeonItemMasks,X : BEQ .setLocatePrize
			LDA.l CompassField : ORA.l MapOverlay : AND.l DungeonItemMasks,X : BNE .setLocatePrize
		+ LDA.l CompassMode : BIT.w #$0010 : BNE .defaultPrizeCheck ; map collected

		; determine if dungeon is located
		.dungeon_icon
		LDA.l CompassMode : BIT.w #$0020 : BEQ + ; compass collected
			BIT.w #$0080 : BEQ .setLocateDungeon ; 0 = always show, 1 = require compass
			LDA.l CompassExists : AND.l DungeonItemMasks,X : BEQ .setLocateDungeon
			LDA.l CompassField : AND.l DungeonItemMasks,X : BNE .setLocateDungeon
		+ ; Overworld Map: Default or Map option
		LDA.l CompassMode : BIT.w #$0010 : BNE ++
		BIT.w #$0040 : BEQ ++ ; skip if wild prizes
			LDA.l PrizeExists : AND.l DungeonItemMasks,X : BNE +
		++
		LDA.l MapMode : AND.w #$00FF : BNE + ; 0 = always show, 1 = requires map
		LDA.l MapField : AND.l DungeonItemMasks,X : BEQ +
			.setLocateDungeon
			TYA : ORA.w #$0004 : TAY
		+
	.continue
	STY.b Scrap06
	PLY
RTS

WorldMap_CheckPrizeCollected:
	PHX
		TXA : LSR : TAX
		LDA.l CrystalPendantFlags_3,X : AND.w #$00FF : BEQ .prize_not_collected
			CMP.w #$0008 : LDA.l CrystalPendantFlags,X : BCS .pendant
				AND.l CrystalsField : BRA .check
				.pendant
				AND.l PendantsField
			.check
			AND.w #$00FF : BEQ .prize_not_collected
			PLX : SEC : RTS
		.prize_not_collected
	PLX : CLC
RTS

warnpc $8AC3B1

org $8AC3B6
; ---------------------------------------------------------------------------------------------------
; Y coordinate calculation: Quadratic approximation
; Formula: Y_oam = 0x16 + (Y * 118 >> 12) + ((Y>>4)^2 * 49 >> 8)
; Accurate to within ±1.5 pixels across entire range
; ---------------------------------------------------------------------------------------------------
	REP #$20
	LDA.l $7EC108 : ASL #4 ; world Y coordinate
	PHA
		; calculate linear term: (Y * 118) >> 12
		SEP #$20
		LDA.b #$76
		JSR WorldMap_MultiplyAxB ; (Y>>4) * 118
		REP #$20
		STA.b Scrap00 ; linear term stored at high byte (Scrap01)

		; calculate quadratic term: ((Y>>4)^2 * 49) >> 8
		LDA.b 1,S
		SEP #$20
		XBA : TAX : XBA : TXA
		JSR WorldMap_MultiplyAxB ; (Y>>4) ^ 2
		LDA.b #$31
		JSR WorldMap_MultiplyAxB ; multiply by 49
		XBA ; quadratic term

		; combine: 0x16 + linear_term + quadratic_term
		CLC : ADC.b Scrap01 ; add linear term
		ADC.b #$16 ; add fixed offset
		STA.b Scrap0F
		REP #$20
	PLA ; world Y coordinate

; ---------------------------------------------------------------------------------------------------
; Calculate half_width for perspective: 91 + (Y_shifted * 28 / 256)
; The world map appears wider at the bottom than at the top, simulating perspective
; Top (Y=0): X range 0x26-0xDC (half-width: 91), Bottom (Y=FFF): X range 0x08-0xF6 (half-width: 119)
; ---------------------------------------------------------------------------------------------------
	SEP #$20
	LDA.b #$1C ; width increase factor
	JSR WorldMap_MultiplyAxB
	XBA : CLC : ADC.b #$5B ; add fixed half-width
	STA.b Scrap00

; ---------------------------------------------------------------------------------------------------
; Calculate X offset: X_offset = (X_from_center * half_width * 2) / 256
; where X_from_center = (world_X >> 4) - 128
; The center X is at 129 (0x81)
; ---------------------------------------------------------------------------------------------------
	REP #$20
	LDA.l $7EC10A : LSR #4 ; world X coordinate
	SEP #$20
	SEC : SBC.b #$80 ; subtract 128 (center point)
	PHP ; preserve carry
		BPL + : EOR.b #$FF : INC : + ; absolute value
		PHA
			LDA.b Scrap00 : ASL : XBA ; half-width x 2
		PLA
		JSR WorldMap_MultiplyAxB
		XBA
	PLP : BCS +
		STA.b Scrap00
		LDA.b #$81 : SEC : SBC.b Scrap00 ; center X position - offset
		BRA .store_and_exit
	+ CLC : ADC.b #$81 ; center X position + offset

.store_and_exit
	STA.b Scrap0E
	SEP #$30
	JMP WorldMap_CalculateOAMCoordinates_exit_successfully

warnpc $8AC433
pullpc

WorldMap_LoadChrHalfSlot:
	JSL Graphics_LoadChrHalfSlot ; what we wrote over

	PHB : LDA.b #$7F : PHA : PLB
	LDA.b #PreloadedGraphicsROM>>16 : STA.b Scrap02
	REP #$20
	LDX.b GameSubMode : CPX.b #$07 : BEQ .not_flute_menu
		REP #$10
		LDX.w #(.list_end-.list_flute)-6

		.next_flute_group
		LDA.l .list_flute+4,X : TAY
		LDA.l .list_flute+2,X : STA.b Scrap03
		LDA.l .list_flute,X : STA.b Scrap00
			- LDA.b [$00],Y : STA.b ($03),Y : DEY #2 : BPL -
		TXA : SBC.w #6 : TAX : BPL .next_flute_group ; SEC is always set
		BRA .return

	.not_flute_menu
	REP #$10
	LDX.w #(.list_flute-.list)-6

	.next_group
	LDA.l .list+4,X : TAY
	LDA.l .list+2,X : STA.b Scrap03
	LDA.l .list,X : STA.b Scrap00
		- LDA.b [$00],Y : STA.b ($03),Y : DEY #2 : BPL -
	TXA : SBC.w #6 : TAX : BPL .next_group ; SEC is always set

	.return
	SEP #$30
	PLB
RTL

; from (bank $A2 only), to (bank $7F only), length
.list
dw #PreloadedGraphicsROM+$140, $7F1140, $C0-2
dw #PreloadedGraphicsROM+$320, $7F1320, $E0-2
.list_flute
dw #PreloadedGraphicsROM+$120, $7F13C0, $20-2
.list_end
