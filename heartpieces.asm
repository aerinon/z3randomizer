;================================================================================
; Randomize Heart Pieces
;--------------------------------------------------------------------------------
HeartPieceGet:
        PHX : PHY
        TAY
        .skipLoad
        JSL HeartPieceGetPlayer : STA.l !MULTIWORLD_ITEM_PLAYER_ID
        CPY.b #$26 : BNE .not_heart ; don't add a 1/4 heart if it's not a heart piece
        		LDA.l !MULTIWORLD_ITEM_PLAYER_ID : BNE .not_heart
                LDA.l HeartPieceQuarter : INC A : AND.b #$03 : STA.l HeartPieceQuarter
        .not_heart
        STZ.w ItemReceiptMethod ; 0 = Receiving item from an NPC or message
        JSL MaybeUnlockTabletAnimation
    JSL LoadHeartPieceRoomValue
    JSL AttemptItemSubstitution
    JSL ResolveLootIDLong
    JSL MaybeMarkDigSpotCollected
    JSL Player_HaltDashAttackLong
    JSL Link_ReceiveItem

        PLY : PLX
RTL
;--------------------------------------------------------------------------------
HeartContainerGet:
	PHX : PHY
	LDY.w SpriteID, X : BNE +
	+
	BRA HeartPieceGet_skipLoad
    JSL IncrementBossSword
        JSL LoadHeartContainerRoomValue : TAY
;--------------------------------------------------------------------------------
DrawHeartPieceGFX:
        PHP
                PHA : PHY
                LDA.l RedrawFlag : BEQ .skipInit ; skip init if already ready
                        JMP .done ; don't draw on the init frame
                .skipInit
                LDA.w SpriteID, X ; Retrieve stored item type
                .skipLoad
                PHA : PHX
                TAX
                LDA.l SpriteProperties_standing_width,X : BNE +
                        PLX
                        LDA.w SpriteControl, X : ORA.b #$20 : STA.w SpriteControl, X
                        PLA
                        LDA.b Scrap00
                        CLC : ADC.b #$04
                        STA.b Scrap00
                        BRA .done
                +
                PLX
                PLA
                .done
                PLY : PLA
        .offscreen
        PLP
    JSL Sprite_IsOnscreen : BCC .offscreen
            JSL HeartPieceSpritePrep
            JSL DrawDynamicTile
            JSL Sprite_DrawShadowLong
        JSL DrawDynamicTile
        JSL Sprite_DrawShadowLong
RTL
;--------------------------------------------------------------------------------
DrawHeartContainerGFX:
	PHP
	JSL Sprite_IsOnscreen : BCC DrawHeartPieceGFX_offscreen
	
	PHA : PHY
	LDA.l RedrawFlag : BEQ .skipInit ; skip init if already ready
	JSL HeartContainerSpritePrep
	BRA DrawHeartPieceGFX_done ; don't draw on the init frame
	
	.skipInit
	LDA.w SpriteID, X ; Retrieve stored item type

	BRA DrawHeartPieceGFX_skipLoad
;--------------------------------------------------------------------------------
HeartContainerSound:
		LDA.l !MULTIWORLD_ITEM_PLAYER_ID : BNE +
        LDA.w ItemReceiptMethod : CMP.b #$03 : BEQ +
                LDA.b #$2E
                SEC
                RTL
	+
	CLC
    JSL CheckIfBossRoom : BCC + ; Skip if not in a boss room
RTL
;--------------------------------------------------------------------------------
NormalItemSkipSound:
; Out: c - skip sounds if set
		LDA.l !MULTIWORLD_ITEM_PLAYER_ID : BNE .skip
        JSL.l CheckIfBossRoom : BCS .boss_room
                TDC
                CPY #$17 : BEQ .skip
                CLC
RTL
        .boss_room
        LDA.w ItemReceiptMethod : CMP.b #$03 : BEQ +
                .skip
                SEC
                RTL
        +
        LDA.b #$20
        .dont_skip
        CLC
RTL
;--------------------------------------------------------------------------------
HeartPieceSpritePrep:
	PHA
	
	LDA.l ServerRequestMode : BEQ + :  : +
	
	LDA.b #$01 : STA.l RedrawFlag
	LDA.b LinkState : CMP.b #$14 : BEQ .skip ; skip if we're mid-mirror

	LDA.b #$00 : STA.l RedrawFlag
	JSL HeartPieceGetPlayer : STA.l !MULTIWORLD_SPRITEITEM_PLAYER_ID
	STA.w SpriteID, X
    JSL LoadHeartPieceRoomValue
    JSL AttemptItemSubstitution
    JSL ResolveLootIDLong
    JSL PrepDynamicTile_loot_resolved
	
	.skip
	PLA
RTL
;--------------------------------------------------------------------------------
HeartContainerSpritePrep:
	PHA
	
	LDA.b #$00 : STA.l RedrawFlag
	JSL HeartPieceGetPlayer : STA.l !MULTIWORLD_SPRITEITEM_PLAYER_ID
	STA.w SpriteID, X
    JSL LoadHeartContainerRoomValue ; load item type
    JSL AttemptItemSubstitution
    JSL ResolveLootIDLong
    JSL PrepDynamicTile_loot_resolved
	
	PLA
RTL
;--------------------------------------------------------------------------------
LoadHeartPieceRoomValue:
	LDA.b IndoorsFlag : BEQ .outdoors ; check if we're indoors or outdoors
	.indoors
	JMP .done
	.outdoors
	.done
    JSL LoadIndoorValue
    JSL LoadOutdoorValue
RTL
;--------------------------------------------------------------------------------
HPItemReset:
	PHA
	LDA.l !MULTIWORLD_ITEM_PLAYER_ID : BNE .skip
		PLA
		BRA .done
	.skip
	PLA
	.done
	PHA : LDA.b #$01 : STA.l RedrawFlag : PLA
        JSL GiveRupeeGift ; thing we wrote over
RTL
;--------------------------------------------------------------------------------
MaybeMarkDigSpotCollected:
	PHA : PHP
		LDA.b IndoorsFlag : BNE +
		REP #$20 ; set 16-bit accumulator
		LDA.b OverworldIndex
		CMP.w #$2A : BNE +
			LDA.l HasGroveItem : ORA.w #$0001 : STA.l HasGroveItem
		+
	PLP : PLA
RTL
;--------------------------------------------------------------------------------
macro GetPossiblyEncryptedItem(ItemLabel,TableLabel)
	LDA.l IsEncrypted : BNE ?encrypted
		LDA.l <ItemLabel>
		BRA ?done
	?encrypted:
	PHX : PHP
		REP #$30 ; set 16-bit accumulator & index registers
		LDA.b Scrap00 : PHA : LDA.b Scrap02 : PHA

		LDA.w #<TableLabel> : STA.b Scrap00
		LDA.w #<TableLabel>>>16 : STA.b Scrap02
		LDA.w #<ItemLabel>-<TableLabel>
		JSL RetrieveValueFromEncryptedTable

		PLX : STX.b Scrap02 : PLX : STX.b Scrap01
	PLP : PLX
	?done:
endmacro

LoadIndoorValue:
	PHP
	REP #$20 ; set 16-bit accumulator
	LDA.b RoomIndex ; these are all decimal because i got them that way
	CMP.w #225 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Forest_Thieves, HeartPieceIndoorValues)
		JMP .done
	+ CMP.w #226 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Lumberjack_Tree, HeartPieceIndoorValues)
		JMP .done
	+ CMP.w #234 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Spectacle_Cave, HeartPieceIndoorValues)
		JMP .done
	+ CMP.w #283 : BNE +
		LDA.b LinkPosX : XBA : AND.w #$0001 ; figure out where link is
		BNE ++
			%GetPossiblyEncryptedItem(HeartPiece_Circle_Bushes, HeartPieceIndoorValues)
			JMP .done
		++
			%GetPossiblyEncryptedItem(HeartPiece_Graveyard_Warp, HeartPieceIndoorValues)
			JMP .done
	+ CMP.w #294 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Mire_Warp, HeartPieceIndoorValues)
		JMP .done
	+ CMP.w #295 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Smith_Pegs, HeartPieceIndoorValues)
		JMP .done
	+ CMP.w #135 : BNE +
		LDA.l StandingKey_Hera
		JMP .done
	+
        PHX
        LDX.w CurrentSpriteSlot ; If we're on a different screen ID via glitches load the sprite
        LDA.w SpriteID,X        ; we can see and are interacting with
        PLX
	.done
	AND.w #$00FF ; the loads are words but the values are 1-byte so we need to clear the top half of the accumulator - no guarantee it was 8-bit before
	PLP
RTL
;--------------------------------------------------------------------------------
;225 - HeartPiece_Forest_Thieves
;226 - HeartPiece_Lumberjack_Tree
;234 - HeartPiece_Spectacle_Cave
;283 - HeartPiece_Circle_Bushes
;283 - HeartPiece_Graveyard_Warp
;294 - HeartPiece_Mire_Warp
;295 - HeartPiece_Smith_Pegs
;--------------------------------------------------------------------------------
LoadOutdoorValue:
	PHP
	REP #$20 ; set 16-bit accumulator
	LDA.b OverworldIndex
	CMP.w #$03 : BNE +
		LDA.b LinkPosX : CMP.w #1890 : !BLT ++
			%GetPossiblyEncryptedItem(HeartPiece_Spectacle, HeartPieceOutdoorValues)
			JMP .done
		++
			%GetPossiblyEncryptedItem(EtherItem, SpriteItemValues)
			JMP .done
	+ CMP.w #$05 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Mountain_Warp, HeartPieceOutdoorValues)
		JMP .done
	+ CMP.w #$28 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Maze, HeartPieceOutdoorValues)
		JMP .done
	+ CMP.w #$2A : BNE +
		%GetPossiblyEncryptedItem(HauntedGroveItem, HeartPieceOutdoorValues)
		JMP .done
	+ CMP.w #$30 : BNE +
		LDA.b LinkPosX : CMP.w #512 : !BGE ++
			%GetPossiblyEncryptedItem(HeartPiece_Desert, HeartPieceOutdoorValues)
			JMP .done
		++
			%GetPossiblyEncryptedItem(BombosItem, SpriteItemValues)
			JMP .done
	+ CMP.w #$35 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Lake, HeartPieceOutdoorValues)
		JMP .done
	+ CMP.w #$3B : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Swamp, HeartPieceOutdoorValues)
		JMP .done
	+ CMP.w #$42 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Cliffside, HeartPieceOutdoorValues)
		JMP .done
	+ CMP.w #$4A : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Cliffside, HeartPieceOutdoorValues)
		JMP .done
	+ CMP.w #$5B : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Pyramid, HeartPieceOutdoorValues)
		JMP .done
	+ CMP.w #$68 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Digging, HeartPieceOutdoorValues)
		JMP .done
	+ CMP.w #$81 : BNE +
		%GetPossiblyEncryptedItem(HeartPiece_Zora, HeartPieceOutdoorValues)
		JMP .done
	+
        PHX
        LDX.w CurrentSpriteSlot ; If we're on a different screen ID via glitches load the sprite
        LDA.w SpriteID,X        ; we can see and are interacting with.
        PLX
	.done
	AND.w #$00FF ; the loads are words but the values are 1-byte so we need to clear the top half of the accumulator - no guarantee it was 8-bit before
	PLP
RTL
;--------------------------------------------------------------------------------
;$03 - HeartPiece_Spectacle
;$05 - HeartPiece_Mountain_Warp
;$28 - HeartPiece_Maze
;$30 - HeartPiece_Desert
;$35 - HeartPiece_Lake
;$3B - HeartPiece_Swamp
;$42 - HeartPiece_Cliffside - not really but the gfx load weird otherwise
;$4A - HeartPiece_Cliffside
;$5B - HeartPiece_Pyramid
;$68 - HeartPiece_Digging
;$81 - HeartPiece_Zora
;--------------------------------------------------------------------------------
LoadHeartContainerRoomValue:
LoadBossValue:
	PHP
	REP #$20 ; set 16-bit accumulator
	LDA.b RoomIndex ; these are all decimal because i got them that way
	CMP.w #200 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_ArmosKnights, HeartContainerBossValues)
		JMP .done
	+ CMP.w #51 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_Lanmolas, HeartContainerBossValues)
		JMP .done
	+ CMP.w #7 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_Moldorm, HeartContainerBossValues)
		JMP .done
	+ CMP.w #90 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_HelmasaurKing, HeartContainerBossValues)
		JMP .done
	+ CMP.w #6 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_Arrghus, HeartContainerBossValues)
		JMP .done
	+ CMP.w #41 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_Mothula, HeartContainerBossValues)
		JMP .done
	+ CMP.w #172 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_Blind, HeartContainerBossValues)
		JMP .done
	+ CMP.w #222 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_Kholdstare, HeartContainerBossValues)
		JMP .done
	+ CMP.w #144 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_Vitreous, HeartContainerBossValues)
		JMP .done
	+ CMP.w #164 : BNE +
		%GetPossiblyEncryptedItem(HeartContainer_Trinexx, HeartContainerBossValues)
		JMP .done
	+
	LDA.w #$003E ; default to a normal boss heart
	.done
	AND.w #$00FF ; the loads are words but the values are 1-byte so we need to clear the top half of the accumulator - no guarantee it was 8-bit before
	PLP
RTL
;--------------------------------------------------------------------------------
CheckIfBossRoom:
;--------------------------------------------------------------------------------
; Carry set if we're in a boss room, unset otherwise.
;--------------------------------------------------------------------------------
	REP #$20 ; set 16-bit accumulator
	LDA.b RoomIndex ; these are all decimal because i got them that way
	CMP.w #200 : BEQ .done
	CMP.w #51 : BEQ .done
	CMP.w #7 : BEQ .done
	CMP.w #90 : BEQ .done
	CMP.w #6 : BEQ .done
	CMP.w #41 : BEQ .done
	CMP.w #172 : BEQ .done
	CMP.w #222 : BEQ .done
	CMP.w #144 : BEQ .done
	CMP.w #164 : BEQ .done
	CLC
	.done
+	SEP #$20 ; set 8-bit accumulator
RTL
;--------------------------------------------------------------------------------
;#200 - Eastern Palace - Armos Knights
;#51 - Desert Palace - Lanmolas
;#7 - Tower of Hera - Moldorm
;#32 - Agahnim's Tower - Agahnim I
;#90 - Palace of Darkness - Helmasaur King
;#6 - Swamp Palace - Arrghus
;#41 - Skull Woods - Mothula
;#172 - Thieves' Town - Blind
;#222 - Ice Palace - Kholdstare
;#144 - Misery Mire - Vitreous
;#164 - Turtle Rock - Trinexx
;#13 - Ganon's Tower - Agahnim II
;#0 - Pyramid of Power - Ganon
;--------------------------------------------------------------------------------
;JSL $86DD40 ; DashKey_Draw
;JSL $86DBF8 ; Sprite_PrepAndDrawSingleLargeLong
;JSL $86DC00 ; Sprite_PrepAndDrawSingleSmallLong ; draw first cell correctly
;JSL $80D51B ; GetAnimatedSpriteTile
;JSL $80D52D ; GetAnimatedSpriteTile.variable
;================================================================================
HeartPieceGetPlayer:
{
	PHY
	LDA.b IndoorsFlag : BNE +
		BRL .outdoors
	+

	PHP
	REP #$20 ; set 16-bit accumulator
	LDA.b RoomIndex ; these are all decimal because i got them that way
	CMP.w #135 : BNE +
		LDA.l StandingKey_Hera_Player
		BRL .done
	+ CMP.w #200 : BNE +
		LDA.l HeartContainer_ArmosKnights_Player
		BRL .done
	+ CMP.w #51 : BNE +
		LDA.l HeartContainer_Lanmolas_Player
		BRL .done
	+ CMP.w #7 : BNE +
		LDA.l HeartContainer_Moldorm_Player
		BRL .done
	+ CMP.w #90 : BNE +
		LDA.l HeartContainer_HelmasaurKing_Player
		BRL .done
	+ CMP.w #6 : BNE +
		LDA.l HeartContainer_Arrghus_Player
		BRL .done
	+ CMP.w #41 : BNE +
		LDA.l HeartContainer_Mothula_Player
		BRL .done
	+ CMP.w #172 : BNE +
		LDA.l HeartContainer_Blind_Player
		BRL .done
	+ CMP.w #222 : BNE +
		LDA.l HeartContainer_Kholdstare_Player
		BRL .done
	+ CMP.w #144 : BNE +
		LDA.l HeartContainer_Vitreous_Player
		BRL .done
	+ CMP.w #164 : BNE +
		LDA.l HeartContainer_Trinexx_Player
		BRL .done
	+ CMP.w #225 : BNE +
		LDA.l HeartPiece_Forest_Thieves_Player
		BRL .done
	+ CMP.w #226 : BNE +
		LDA.l HeartPiece_Lumberjack_Tree_Player
		BRL .done
	+ CMP.w #234 : BNE +
		LDA.l HeartPiece_Spectacle_Cave_Player
		BRL .done
	+ CMP.w #283 : BNE +
		LDA.b LinkPosX : XBA : AND.w #$0001 ; figure out where link is
		BNE ++
			LDA.l HeartPiece_Circle_Bushes_Player
			BRL .done
		++
			LDA.l HeartPiece_Graveyard_Warp_Player
			BRL .done
	+ CMP.w #294 : BNE +
		LDA.l HeartPiece_Mire_Warp_Player
		BRL .done
	+ CMP.w #295 : BNE +
		LDA.l HeartPiece_Smith_Pegs_Player
		BRL .done
	LDA.w #$0000
	BRL .done

	.outdoors
	PHP
	REP #$20 ; set 16-bit accumulator
	LDA.b OverworldIndex
	CMP.w #$03 : BNE +
		LDA.b LinkPosX : CMP.w #1890 : !BLT ++
			LDA.l HeartPiece_Spectacle_Player
			BRL .done
		++
			LDA.l EtherItem_Player
			BRL .done
	+ CMP.w #$05 : BNE +
		LDA.l HeartPiece_Mountain_Warp_Player
		BRL .done
	+ CMP.w #$28 : BNE +
		LDA.l HeartPiece_Maze_Player
		BRL .done
	+ CMP.w #$2A : BNE +
		LDA.l HauntedGroveItem_Player
		BRL .done
	+ CMP.w #$30 : BNE +
		LDA.b LinkPosX : CMP.w #512 : !BGE ++
			LDA.l HeartPiece_Desert_Player
			BRL .done
		++
			LDA.l BombosItem_Player
			BRL .done
	+ CMP.w #$35 : BNE +
		LDA.l HeartPiece_Lake_Player
		BRL .done
	+ CMP.w #$3B : BNE +
		LDA.l HeartPiece_Swamp_Player
		BRL .done
	+ CMP.w #$42 : BNE +
		LDA.l HeartPiece_Cliffside_Player
		BRL .done
	+ CMP.w #$4A : BNE +
		LDA.l HeartPiece_Cliffside_Player
		BRL .done
	+ CMP.w #$5B : BNE +
		LDA.l HeartPiece_Pyramid_Player
		BRL .done
	+ CMP.w #$68 : BNE +
		LDA.l HeartPiece_Digging_Player
		BRL .done
	+ CMP.w #$81 : BNE +
		LDA.l HeartPiece_Zora_Player
		BRL .done
	+
	LDA.w #$0000

	.done
	AND.w #$00FF ; the loads are words but the values are 1-byte so we need to clear the top half of the accumulator - no guarantee it was 8-bit before
	PLP
	PLY
RTL
}
