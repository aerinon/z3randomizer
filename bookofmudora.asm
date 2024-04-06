;================================================================================
; Randomize Book of Mudora
;--------------------------------------------------------------------------------
LoadLibraryItemGFX:
		LDA.l LibraryItem_Player : STA.l !MULTIWORLD_SPRITEITEM_PLAYER_ID
        %GetPossiblyEncryptedItem(LibraryItem, SpriteItemValues)
        JSL AttemptItemSubstitution
        JSL ResolveLootIDLong
        STA.w SpriteID, X
        JSL PrepDynamicTile_loot_resolved
RTL
;--------------------------------------------------------------------------------
DrawLibraryItemGFX:
        PHA
        LDA.w SpriteID, X
        JSL DrawDynamicTile
        PLA
RTL
;--------------------------------------------------------------------------------
SetLibraryItem:
        LDY.w SpriteID, X
        JSL ItemSet_Library ; contains thing we wrote over
RTL
;--------------------------------------------------------------------------------

;0x0087 - Hera Room w/key
;================================================================================
; Randomize Bonk Keys
;--------------------------------------------------------------------------------
LoadBonkItemGFX:
	LDA.b #$08 : STA.w SpriteOAMProp, X ; thing we wrote over
LoadBonkItemGFX_inner:
	LDA.b #$00 : STA.l RedrawFlag
	JSR LoadBonkItem_Player : STA.l !MULTIWORLD_SPRITEITEM_PLAYER_ID
	JSR LoadBonkItem
        JSL AttemptItemSubstitution
        JSL ResolveLootIDLong
        STA.w $0E80, X
        STA.w SpriteID, X
	JSL PrepDynamicTile
        PHA : PHX
        LDA.w SpriteID,X : TAX
        LDA.l SpriteProperties_standing_width,X : BNE +
                LDA.b #$00 : STA.l SpriteOAM : STA.l SpriteOAM+8
        +
        PLX : PLA
RTL
;--------------------------------------------------------------------------------
DrawBonkItemGFX: 
        PHA
        LDA.l RedrawFlag : BEQ .skipInit
        JSL LoadBonkItemGFX_inner
        BRA .done ; don't draw on the init frame

	.skipInit
        LDA.w SpriteID,X
        JSL DrawDynamicTileNoShadow

        .done
        PLA
RTL
;--------------------------------------------------------------------------------
GiveBonkItem:
	JSR LoadBonkItem_Player : STA.l !MULTIWORLD_ITEM_PLAYER_ID
	JSR LoadBonkItem
        JSR AbsorbKeyCheck : BCC .notKey
	.key
		PHY : LDY.b #$24 : JSL AddInventory : PLY ; do inventory processing for a small key
		LDA.l CurrentSmallKeys : INC A : STA.l CurrentSmallKeys
		LDA.b #$2F : JSL Sound_SetSfx3PanLong
		INC.w UpdateHUDFlag
RTL
	.notKey
		PHY : TAY : JSL Link_ReceiveItem : PLY
RTL
;--------------------------------------------------------------------------------
LoadBonkItem:
	LDA.b RoomIndex ; check room ID - only bonk keys in 2 rooms so we're just checking the lower byte
	CMP.b #$73 : BNE + ; Desert Bonk Key
    	LDA.l BonkKey_Desert
		BRA ++
	+ : CMP.b #$8C : BNE + ; GTower Bonk Key
    	LDA.l BonkKey_GTower
		BRA ++
	+
		LDA.b #$24 ; default to small key
	++
RTS
;--------------------------------------------------------------------------------
LoadBonkItem_Player:
	LDA.b RoomIndex ; check room ID - only bonk keys in 2 rooms so we're just checking the lower byte
	CMP.b #$73 : BNE + ; Desert Bonk Key
		LDA.l BonkKey_Desert_Player
		BRA ++
	+ : CMP.b #$8C : BNE + ; GTower Bonk Key
    	LDA.l BonkKey_GTower_Player
		BRA ++
	+
		LDA.b #$00
	++
RTS
;--------------------------------------------------------------------------------
AbsorbKeyCheck:
        PHA
	CMP.b #$24 : BEQ .key
        CMP.b #$A0 : BCC .not_key
        CMP.b #$B0 : BCS .not_key
                AND.b #$0F : ASL
                CMP.w DungeonID : BNE .not_key
                        .key
                        PLA
                        SEC
                        RTS
        .not_key
        PLA
        CLC
RTS
