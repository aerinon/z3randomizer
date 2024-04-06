GtBossHeartCheckOverride:
    lda.b RoomIndex : cmp.b #$1c : beq ++
    cmp.b #$6c : beq ++
    cmp.b #$4d : bne +
    ++ lda.l DRFlags : and.b #$01 : bne ++ ;skip if flag on
        lda.w RoomItemsTaken : ora.b #$80 : sta.w RoomItemsTaken
    ++ clc
rtl
    + sec
rtl

OnFileLoadOverride:
    jsl OnFileLoad ; what I wrote over
    + lda.l DRFlags : and.b #$02 : beq + ; Mirror Scroll
        lda.l MirrorEquipment : bne +
            lda.b #$01 : sta.l MirrorEquipment
+ rtl

MirrorCheckOverride:
    lda.l DRFlags : and.b #$02 : beq ++
        lda.l MirrorEquipment : cmp.b #$01 : beq +
    ++ lda.b OverworldIndex : and.b #$40 ; what I wrote over
    rtl
    + lda.l DRScroll : rtl

EGFixOnMirror:
	lda.l DRFlags : and.b #$10 : beq +
		stz.w LayerAdjustment
	+ jsl Mirror_SaveRoomData
	rtl

BlockEraseFix:
    lda.l MirrorEquipment : and.b #$02 : beq +
        stz.w $05fc : stz.w $05fd
    + rtl

FixShopCode:
    cpx.w #$0300 : !BGE +
        sta.l RoomDataWRAM[$00].l, x
    + rtl

VitreousKeyReset:
    LDA.l FixPrizeOnTheEyes : BEQ +
        STZ.w SpriteForceDrop, X
    + JML SpritePrep_LoadProperties ; what we wrote over

GuruguruFix:
    lda.b RoomIndex : cmp.b #$df : !BGE +
        and.b #$0f : cmp.b #$0e : !BLT +
            iny #2
    + rtl

BlindAtticFix:
    lda.l DRMode : beq +
        lda.b #$01 : rtl
    + lda.l FollowerIndicator : cmp.b #$06
    rtl

SuctionOverworldFix:
    stz.b LinkStrafe : stz.b LinkSpeed
    lda.l DRMode : beq +
        stz.b ForceMove
    + rtl

CutoffEntranceRug:
    PHA : PHX
    LDA.l DRMode : BEQ .norm
        LDA.b Scrap04 : CMP.w #$000A : BEQ + ; only affect A & C objects
        CMP.w #$000C : BNE .norm
          + LDX.w #$0000 : LDA.l CutoffRooms, x
            - CMP.b RoomIndex : BEQ .check
                INX #2 : LDA.l CutoffRooms, x : CMP.w #$FFFF : BNE -
    .norm
    PLX : PLA : LDA.w $9B52, Y : STA.l TileMapA, X ; what we wrote over
    RTL
    .check
    LDA.b Scrap0C : CMP.w #$0004 : !BGE .skip
    LDA.b Scrap0E : CMP.w #$0008 : !BGE .skip
    CMP.w #$0004 : !BLT .skip
    BRA .norm
.skip
PLX : PLA : RTL

StoreTempBunnyState:
	LDA.b LinkState : CMP.b #$1C : BNE +
		STA.b ManipTileField
	+ LDA.b #$15 : STA.b LinkState ; what we wrote over
RTL

RetrieveBunnyState:
	STY.b LinkState : STZ.w ItemReceiptID ; what we wrote over
	LDA.b ManipTileField : BEQ +
		STA.b LinkState
 + JML MaybeKeepLootID

; A should be how much dmg to do to Aga when leaving this function, 0 if prevented
StandardAgaDmg:
	LDX.b #$00 ; part of what we wrote over
	LDA.l ProgressFlags : AND.b #$04 : BNE .enableDamage ; zelda's been rescued, no further checks needed
	; zelda's not been rescued
	LDA.l AllowAgaDamageBeforeZeldaRescued : BEQ + ; zelda needs to be rescued if not allowed
		.enableDamage
		LDA.b #$10 ; hurt him!
	+	RTL

StandardSaveAndQuit:
	LDA.b #$0F : STA.b MOSAICQ ; what we wrote over
	LDA.l ProgressFlags : AND.b #$04 : BNE +
	LDA.l DRMode : BEQ +
	LDA.l StartingEntrance : CMP.b #$02 : BCC +
		LDA.b #$03 : STA.l StartingEntrance  ; set spawn to uncle if >=
+ RTL

; note: this skips both maiden dialog triggers if the hole is open
BlindsAtticHint:
	REP #$20
	CMP.w #$0122 : BNE +
	LDA.l RoomDataWRAM[$65].low : AND.w #$0100 : BEQ +
		SEP #$20 : RTL ; skip the dialog box if the hole is already open
	+ SEP #$20 : JML Main_ShowTextMessage

BlindZeldaDespawnFix:
	CMP.b #06 : BEQ +
	LDA.w SpritePosYLow,X : BEQ + ; don't despawn follower if maiden isn't "present"
		PLA : PLA : PEA.w SpritePrep_BlindMaiden_despawn_follower-1 : RTL
	+ PLA : PLA : PEA.w SpritePrep_BlindMaiden_kill_the_girl-1 : RTL

BigKeyDoorCheck:
	CPY.w #$001E : BNE + ; skip if it isn't a BK door
	LDA.l DRFlags : AND.w #$0400 : BNE + ; skip if the flag is set - bk doors can be double-sided
		PLA : PEA.w RoomDraw_OneSidedShutters_South_onesided_shutter_or_big_key_door-1
+ LDA.w #$0000 : RTL

FixOvalFadeOutMirror:
	LDA.b $10 : CMP.b #$0F : BEQ .skip_activation
	LDA.l InvertedMode : BNE +
		LDA.l CurrentWorld : BNE .skip_activation
		RTL
	+ LDA.l CurrentWorld : BEQ .skip_activation
	RTL
	.skip_activation
	PLA : PLA : PLA : JML Sprite_6C_MirrorPortal_missing_mirror