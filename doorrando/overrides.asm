GtBossHeartCheckOverride:
    lda $a0 : cmp #$1c : beq ++
    cmp #$6c : beq ++
    cmp #$4d : bne +
    ++ lda.l DRFlags : and #$01 : bne ++ ;skip if flag on
        lda $403 : ora #$80 : sta $403
    ++ clc
rtl
    + sec
rtl

OnFileLoadOverride:
    jsl OnFileLoad ; what I wrote over
    + lda.l DRFlags : and #$02 : beq + ; Mirror Scroll
        lda MirrorEquipment : bne +
            lda #$01 : sta MirrorEquipment
+ rtl

MirrorCheckOverride:
    lda.l DRFlags : and #$02 : beq ++
        lda MirrorEquipment : cmp #$01 : beq +
    ++ lda $8A : and #$40 ; what I wrote over
    rtl
    + lda.l DRScroll : rtl

EGFixOnMirror:
	lda.l DRFlags : and #$10 : beq +
		stz $047a
	+ jsl Mirror_SaveRoomData
	rtl

BlockEraseFix:
    lda MirrorEquipment : and #$02 : beq +
        stz $05fc : stz $05fd
    + rtl

FixShopCode:
    cpx #$300 : !bge +
        sta RoomDataWRAM[$00].l, x
    + rtl

VitreousKeyReset:
    LDA.l FixPrizeOnTheEyes : BEQ +
        STZ.w $0CBA, X
    + JML $0DB818 ;restore old code - SpritePrep_LoadProperties

GuruguruFix:
    lda $a0 : cmp #$df : !bge +
        and #$0f : cmp #$0e : !blt +
            iny #2
    + rtl

BlindAtticFix:
    lda.l DRMode : beq +
        lda #$01 : rtl
    + lda FollowerIndicator : cmp.b #$06
    rtl

SuctionOverworldFix:
    stz $50 : stz $5e
    lda.l DRMode : beq +
        stz $49
    + rtl

!CutoffTable = "$A7E000"

CutoffEntranceRug:
    PHA : PHX
    LDA.l DRMode : BEQ .norm
        LDA $04 : cmp #$000A : BEQ + ; only affect A & C objects
        cmp #$000C : BNE .norm
          + LDX #$0000 : LDA !CutoffTable, x
          	- CMP.W $A0 : BEQ .check
           	INX #2 : LDA !CutoffTable, x : CMP.w #$FFFF : BNE -
    .norm PLX : PLA : LDA $9B52, y : STA $7E2000, x ; what we wrote over
RTL
     .check
		  LDA $0c : CMP #$0004 : !BGE .skip
		  LDA $0e : CMP #$0008 : !BGE .skip
		  CMP.l #$0004 : !BLT .skip
      BRA .norm
.skip PLX : PLA : RTL

StoreTempBunnyState:
	LDA $5D : CMP #$1C : BNE +
		STA $5F
	+ LDA #$15 : STA $5D ; what we wrote over
RTL

RetrieveBunnyState:
	STY $5D : STZ $02D8 ; what we wrote over
	LDA $5F : BEQ +
		STA $5D
 + JML MaybeKeepLootID

; A should be how much dmg to do to Aga when leaving this function
StandardAgaDmg:
	LDX.b #$00 ; part of what we wrote over
	LDA.l ProgressFlags : AND #$04 : BEQ .checkShouldAgaTakeDamage ; zelda's not been rescued
		LDA.b #$10 ; hurt him!
	.checkShouldAgaTakeDamage ; should be damage aga anyway?
		LDA.l AllowAgaDamageBeforeZeldaRescued : BEQ .end;
		LDA.b #$10 ; hurt him!
	.end
	+ RTL ; A is zero if the AND results in zero, and we don't force damage, then Agahnim's invincible!

StandardSaveAndQuit:
	LDA.b #$0F : STA.b $95 ; what we wrote over
	LDA.l ProgressFlags : AND #$04 : BNE +
	LDA.l DRMode : BEQ +
	LDA.l StartingEntrance : CMP.b #$02 : BCC +
		LDA.b #$03 : STA.l StartingEntrance  ; set spawn to uncle if >=
+ RTL

; note: this skips both maiden dialog triggers if the hole is open
BlindsAtticHint:
	REP #$20
	CMP.w #$0122 : BNE +
	LDA RoomDataWRAM[$65].low : AND.w #$0100 : BEQ +
		SEP #$20 : RTL ; skip the dialog box if the hole is already open
	+ SEP #$20 : JML Main_ShowTextMessage

BlindZeldaDespawnFix:
	CMP.b #06 : BEQ +
	LDA.w $0D00,X : BEQ + ; don't despawn follower if maiden isn't "present"
		PLA : PLA : PEA.w SpritePrep_BlindMaiden_despawn_follower-1 : RTL
	+ PLA : PLA : PEA.w SpritePrep_BlindMaiden_kill_the_girl-1 : RTL

BigKeyDoorCheck:
	CPY.w #$001E : BNE + ; skip if it isn't a BK door
	LDA.l DRFlags : AND #$0400 : BNE + ; skip if the flag is set - bk doors can be double-sided
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