;================================================================================
; Randomize Half Magic Bat
;--------------------------------------------------------------------------------
GetMagicBatItem:
	JSL.l ItemSet_MagicBat
	%GetPossiblyEncryptedItem(MagicBatItem, SpriteItemValues)
	CMP.b #$FF : BEQ .normalLogic
	TAY
	PHA : LDA MagicBatItem_Player : STA !MULTIWORLD_ITEM_PLAYER_ID : PLA
	STZ $02E9 ; 0 = Receiving item from an NPC or message
	JML.l Link_ReceiveItem
.normalLogic
	LDA HalfMagic
	STA MagicConsumption
RTL
;--------------------------------------------------------------------------------
