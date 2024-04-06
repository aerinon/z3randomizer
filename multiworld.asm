

macro Print_Text(hdr, hdr_len, player_id)
PHX : PHY : PHP
	REP #$30
	LDX.w #$0000
	-
	CPX.w <hdr_len> : !BGE ++
		LDA.l <hdr>, X
		STA.l !MULTIWORLD_HUD_CHARACTER_DATA, X
		INX #2
		BRA -
	++
	LDY.w <hdr_len>

	LDA.l <player_id>
	AND.w #$00FF
	DEC
	CMP.w #$00FF : !BGE .textdone
	ASL #5
	TAX
	-
	CPY.w <hdr_len>+$20 : !BGE ++
		LDA.l PlayerNames, X
		PHX : TYX : STA.l !MULTIWORLD_HUD_CHARACTER_DATA, X : PLX
		INX #2 : INY #2
		BRA -
	++

	TYX
	-
	CPX.w #$0040 : !BGE ++
		LDA.w #$007F
		STA.l !MULTIWORLD_HUD_CHARACTER_DATA, X
		INX #2
		BRA -
	++

	SEP #$20
	LDA.b #$01 : STA.l !NMI_MW+1 : STA.l !NMI_MW
	LDA.b !MULTIWORLD_HUD_DELAY
	STA.l !MULTIWORLD_HUD_TIMER
.textdone
PLP : PLY : PLX
endmacro

WriteText:
{
	PHA : PHX : PHP
		SEP #$10
		LDX.w $4340 : PHX ; preserve DMA parameters
		LDX.w $4341 : PHX ; preserve DMA parameters
		LDX.w $4342 : PHX ; preserve DMA parameters
		LDX.w $4343 : PHX ; preserve DMA parameters
		LDX.w $4344 : PHX ; preserve DMA parameters
		LDX.w $4345 : PHX ; preserve DMA parameters
		LDX.w $4346 : PHX ; preserve DMA parameters
		LDX.w $2115 : PHX ; preserve DMA parameters
		LDX.w $2116 : PHX ; preserve DMA parameters
		LDX.w $2117 : PHX ; preserve DMA parameters
		LDX.w $2100 : PHX : LDX.b #$80 : STX.w $2100 ; save screen state & turn screen off

		REP #$20
		LDX.b #$80 : STX.w $2115
		LDA.w #$6000+$0340 : STA.w $2116
		LDA.w #!MULTIWORLD_HUD_CHARACTER_DATA : STA.w $4342
		LDX.b #!MULTIWORLD_HUD_CHARACTER_DATA>>16 : STX.w $4344
		LDA.w #$0040 : STA.w $4345
		LDA.w #$1801 : STA.w $4340
		LDX.b #$10 : STX.w DMAENABLE

		PLX : STX.w $2100 ; put screen back however it was before
		PLX : STX.w $2117 ; restore DMA parameters
		PLX : STX.w $2116 ; restore DMA parameters
		PLX : STX.w $2115 ; restore DMA parameters
		PLX : STX.w $4346 ; restore DMA parameters
		PLX : STX.w $4345 ; restore DMA parameters
		PLX : STX.w $4344 ; restore DMA parameters
		PLX : STX.w $4343 ; restore DMA parameters
		PLX : STX.w $4342 ; restore DMA parameters
		PLX : STX.w $4341 ; restore DMA parameters
		PLX : STX.w $4340 ; restore DMA parameters
	PLP : PLX : PLA
RTL
}

GetMultiworldItem:
{
	PHP
	LDA.l !MULTIWORLD_ITEM : BNE +
	LDA.l !MULTIWORLD_HUD_TIMER : BNE +
		BRL .return
	+

	LDA.b GameMode
	CMP.b #$07 : BEQ +
	CMP.b #$09 : BEQ +
	CMP.b #$0B : BEQ +
		BRL .return
	+

	LDA.l !MULTIWORLD_HUD_TIMER : BEQ .textend
		DEC.b #$01 : STA.l !MULTIWORLD_HUD_TIMER
		CMP.b #$00 : BNE .textend
			; Clear text
			PHP : REP #$30
			LDX.w #$0000
			-
			CPX.w #$0040 : !BGE ++
				LDA.w #$007F
				STA.l !MULTIWORLD_HUD_CHARACTER_DATA, X
				INX #2
				BRA -
			++
			PLP
			LDA.b #$01 : STA.l !NMI_MW+1 : STA.l !NMI_MW
	.textend

	LDA.b LinkState
	CMP.b #$00 : BEQ +
	CMP.b #$04 : BEQ +
	CMP.b #$17 : BEQ +
		BRL .return
	+

	LDA.l !MULTIWORLD_ITEM : BNE +
		BRL .return
	+

	PHA
	LDA.b #$22
	LDY.b #$04
	JSL Ancilla_CheckForAvailableSlot : BPL +
		PLA
		BRL .return
	+
	PLA

	; Check if we have a key for the dungeon we are currently in
	LDX.w DungeonID
	; Escape
	CMP.b #$A0 : BNE + : CPX.b #$00 : BEQ ++ : CPX.b #$02 : BEQ ++ : BRL .keyend : ++ : BRL .thisdungeon : +
	; Eastern
	CMP.b #$A2 : BNE + : CPX.b #$04 : BEQ .thisdungeon : BRA .keyend : +
	; Desert
	CMP.b #$A3 : BNE + : CPX.b #$06 : BEQ .thisdungeon : BRA .keyend : +
	; Hera
	CMP.b #$AA : BNE + : CPX.b #$14 : BEQ .thisdungeon : BRA .keyend : +
	; Aga
	CMP.b #$A4 : BNE + : CPX.b #$08 : BEQ .thisdungeon : BRA .keyend : +
	; PoD
	CMP.b #$A6 : BNE + : CPX.b #$0C : BEQ .thisdungeon : BRA .keyend : +
	; Swamp
	CMP.b #$A5 : BNE + : CPX.b #$0A : BEQ .thisdungeon : BRA .keyend : +
	; SW
	CMP.b #$A8 : BNE + : CPX.b #$10 : BEQ .thisdungeon : BRA .keyend : +
	; TT
	CMP.b #$AB : BNE + : CPX.b #$16 : BEQ .thisdungeon : BRA .keyend : +
	; Ice
	CMP.b #$A9 : BNE + : CPX.b #$12 : BEQ .thisdungeon : BRA .keyend : +
	; Mire
	CMP.b #$A7 : BNE + : CPX.b #$0E : BEQ .thisdungeon : BRA .keyend : +
	; TR
	CMP.b #$AC : BNE + : CPX.b #$18 : BEQ .thisdungeon : BRA .keyend : +
	; GT
	CMP.b #$AD : BNE + : CPX.b #$1A : BEQ .thisdungeon : BRA .keyend : +
	; GT BK
	CMP.b #$92 : BNE .keyend : CPX.b #$1A : BNE .keyend : LDA.b #$32 : BRA .keyend
	.thisdungeon
	LDA.b #$24
	.keyend

	STA.w ItemReceiptID ;Set Item to receive
	TAY

	LDA.b #$01 : STA.l !MULTIWORLD_RECEIVING_ITEM
	LDA.b #$00 : STA.l !MULTIWORLD_ITEM_PLAYER_ID

	STZ.w ItemReceiptMethod
	JSL Player_HaltDashAttackLong
	JSL Link_ReceiveItem
	LDA.b #$00 : STA.l !MULTIWORLD_ITEM : STA.l !MULTIWORLD_RECEIVING_ITEM

	%Print_Text(HUD_ReceivedFrom, #$001C, !MULTIWORLD_ITEM_FROM)
	
	.return
	PLP
	LDA.b LinkState : ASL A : TAX
RTL
}

Multiworld_OpenKeyedObject:
{
	PHP
	SEP #$20
	LDA.l ChestData_Player+2, X : STA.l !MULTIWORLD_ITEM_PLAYER_ID
	PLP

	LDA.l !Dungeon_ChestData+2, X ; thing we wrote over
RTL
}

Multiworld_BottleVendor_GiveBottle:
{
	PHA : PHP
	SEP #$20
	LDA.l BottleMerchant_Player : STA.l !MULTIWORLD_ITEM_PLAYER_ID
	PLP : PLA

	JSL Link_ReceiveItem ; thing we wrote over
RTL
}

Multiworld_MiddleAgedMan_ReactToSecretKeepingResponse:
{
	PHA : PHP
	SEP #$20
	LDA.l PurpleChest_Item_Player : STA.l !MULTIWORLD_ITEM_PLAYER_ID
	PLP : PLA

	JSL Link_ReceiveItem ; thing we wrote over
RTL
}

Multiworld_Hobo_GrantBottle:
{
	PHA : PHP
	SEP #$20
	LDA.l HoboItem_Player : STA.l !MULTIWORLD_ITEM_PLAYER_ID
	PLP : PLA

	JSL Link_ReceiveItem ; thing we wrote over
RTL
}

Multiworld_MasterSword_GrantToPlayer:
{
	PHA : PHP
	SEP #$20
	LDA.l PedestalSword_Player : STA.l !MULTIWORLD_ITEM_PLAYER_ID
	PLP : PLA

	JSL Link_ReceiveItem ; thing we wrote over
RTL
}

Multiworld_AddReceivedItem_notCrystal:
{
	TYA : STA.w CutsceneFlag : PHX ; things we wrote over
	
	LDA.l !MULTIWORLD_ITEM_PLAYER_ID : BEQ +
		PHY : LDY.w ItemReceiptID : JSL AddInventory : PLY

		%Print_Text(HUD_SentTo, #$0010, !MULTIWORLD_ITEM_PLAYER_ID)
		LDA.b #$33 : STA.w SFX3

		JML AddReceivedItem_gfxHandling
	+
	JML AddReceivedItem_notCrystal+5
}

Multiworld_Ancilla_ReceiveItem_stillInMotion:
{
	CMP.b #$28 : BNE + ; thing we wrote over
	LDA.l !MULTIWORLD_ITEM_PLAYER_ID : BNE +
		JML Ancilla_ReceiveItem_stillInMotion_moveon
	+
	JML Ancilla_ReceiveItem_dontGiveRupees
}

Multiworld_ConsumingFire_TransmuteToSkullWoodsFire:
{
	LDA.b OverworldIndex : AND.b #$40 : BEQ .failed ; things we wrote over
	LDA.w AncillaID : CMP.b #$22 : BEQ .failed
	LDA.w AncillaID+1 : CMP.b #$22 : BEQ .failed
	LDA.w AncillaID+2 : CMP.b #$22 : BEQ .failed
	LDA.w AncillaID+3 : CMP.b #$22 : BEQ .failed
	LDA.w AncillaID+4 : CMP.b #$22 : BEQ .failed
	LDA.w AncillaID+5 : CMP.b #$22 : BEQ .failed

	JML ConsumingFire_TransmuteToSkullWoodsFire_continue

	.failed
	JML AddDoorDebris_spawn_failed
}
