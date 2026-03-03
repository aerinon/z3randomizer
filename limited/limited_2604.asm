!LoadedPedestalNumber = LimitedRunStore
!PedestalCollectedFlags = LimitedRunStore+1
!KickedOutMessage = LimitedRunStore+2
!FortuneRead = LimitedRunStore+3
!ScreenSequenceIndex = LimitedRunStore+4 ; 16-bit, screen temporary
!BananaFlags = LimitedRunStore+4 ; 16-bit, screen temporary
!StatueGFXLoaded = LimitedRunStore+4 ; 16-bit, screen temporary
!GFXLoadFlag = LimitedRunStore+$20

!BananaXPos = LimitedRunData
!BananaYPos = LimitedRunData+10
!LostWoodsMessage = LimitedRunData+20

; --------------------------------------------------------------------------------

Limited_LoadEggGoalHUDGfx:
    LDA.b #.gfx>>16 : STA.b Scrap02
    REP #$30
    LDA.w #.gfx : STA.b Scrap00
    LDA.w #$E0E0>>1 : STA.w VMADDR
    LDX.w #$0007
    - LDA.b [$00] : STA.w VMDATA
    INC.b Scrap00 : INC.b Scrap00
    DEX : BPL -
    LDA.w #$7C00 : STA.w VMADDR ; restore VMADDR
    SEP #$30
    RTL
.gfx
db $00, $00, $04, $1C, $02, $3E, $02, $3E, $02, $3E, $02, $3E, $24, $3C, $18, $18

Limited_OverworldPedestalTileChanges:
    LDA.b OverworldIndex : CMP.w #$0015 : BNE +
        LDA.w #$02C3 : STA.w $20A8
	    LDA.w #$02CA : STA.w $2128
        RTL
    + CMP.w #$001E : BNE +
        LDA.w #$0000 : STA.l !StatueGFXLoaded
        LDA.l OverworldEventDataWRAM+$1E : AND.w #$0040 : BEQ ++
		LDA.w #$0912 : STA.w $3318
            INC : STA.w $331A
            INC : STA.w $3398
            INC : STA.w $339A
        ++ RTL
    + CMP.w #$0043 : BNE +
        LDA.l OverworldEventDataWRAM+$43 : AND.w #$0040 : BEQ ++
		LDA.w #$0912 : STA.w $2310
            INC : STA.w $2312
            INC : STA.w $2390
            INC : STA.w $2392
        ++ RTL
    + CMP.w #$005E : BNE +
        LDA.l OverworldEventDataWRAM+$5E : AND.w #$0040 : BEQ ++
		LDA.w #$0912 : STA.w $2B74
            INC : STA.w $2B76
            INC : STA.w $2BF4
            INC : STA.w $2BF6
        ++ RTL
    + CMP.w #$007A : BNE +
        LDA.l OverworldEventDataWRAM+$7A : AND.w #$0020 : BEQ ++
		LDA.w #$0912 : STA.w $2A1E
            INC : STA.w $2A20
            INC : STA.w $2A9E
            INC : STA.w $2AA0
        ++ RTL
    + CMP.w #$0080 : BEQ + : RTL : +
        LDA.w #$0034 : STA.w $2A14 : STA.w $2A96
        LDA.l !LoadedPedestalNumber : AND.w #$00FF : BNE + : RTL
        + CMP.w #$0001 : BNE +
            LDA.w #$00DA : STA.w $2794 : STA.w $2814 : STA.w $2894
                STA.w $2914 : STA.w $2992 : STA.w $2994 : STA.w $2996
            LDA.w #$010D : STA.w $2792
            RTL
        + CMP.w #$0002 : BNE +
            LDA.w #$010D : STA.w $2792 : STA.w $2894 : STA.w $2912
                INC : STA.w $2896 : STA.w $2914
                INC : STA.w $2796
            LDA.w #$0071 : STA.w $2812
            LDA.w #$00DA : STA.w $2794 : STA.w $2816 : STA.w $2992 : STA.w $2994 : STA.w $2996
            LDA.w #$0034 : STA.w $2814
            RTL
        + CMP.w #$0003 : BNE +
            LDA.w #$010D : STA.w $2792
            INC : STA.w $2996
            INC : STA.w $2796 : STA.w $2896
            LDA.w #$0071 : STA.w $2812
            LDA.w #$0034 : STA.w $2814
            INC : STA.w $2912
            LDA.w #$00F8 : STA.w $2992
            LDA.w #$00DA : STA.w $2794 : STA.w $2816 : STA.w $2894 : STA.w $2916 : STA.w $2994
            RTL
        + CMP.w #$0004 : BNE +
            LDA.w #$00DA : STA.w $2792 : STA.w $2796 : STA.w $2812 : STA.w $2816
                STA.w $2894 : STA.w $2896 : STA.w $2916 : STA.w $2996
            LDA.w #$00F8 : STA.w $2892
            LDA.w #$0034 : STA.w $2814
            RTL
        + CMP.w #$0005 : BNE +
            LDA.w #$00DA : STA.w $2792 : STA.w $2794 : STA.w $2796
                STA.w $2812 : STA.w $2894 : STA.w $2916 : STA.w $2994
            LDA.w #$0034 : STA.w $2814
                INC : STA.w $2912
            LDA.w #$00F8 : STA.w $2892 : STA.w $2992
            LDA.w #$010E : STA.w $2996
                INC : STA.w $2896
            RTL
        + CMP.w #$0006 : BNE +
            LDA.w #$010D : STA.w $2792
                INC : STA.w $2996
                INC : STA.w $2796 : STA.w $2896
            LDA.w #$00DA : STA.w $2794 : STA.w $2812 : STA.w $2892
                STA.w $2894 : STA.w $2912 : STA.w $2916 : STA.w $2994
            LDA.w #$00F8 : STA.w $2992
            LDA.w #$0034 : STA.w $2814
            LDA.w #$0071 : STA.w $2816
            RTL
        + CMP.w #$0007 : BNE +
            LDA.w #$00DA : STA.w $2792 : STA.w $2794
                STA.w $2796 : STA.w $2816 : STA.w $2992
            LDA.w #$0034 : STA.w $2814
            LDA.w #$010D : STA.w $2894 : STA.w $2912
                INC : STA.w $2896 : STA.w $2914
            RTL
        + CMP.w #$0008 : BNE ++
            LDA.w #$010D : STA.w $2792 : STA.w $2892
                INC : STA.w $2996
                INC : STA.w $2796 : STA.w $2896
            LDA.w #$00DA : STA.w $2794 : STA.w $2812 : STA.w $2816
                STA.w $2894 : STA.w $2912 : STA.w $2916 : STA.w $2994
            LDA.w #$0034 : STA.w $2814
            LDA.w #$00F8 : STA.w $2992
        ++ RTL

Limited_PedestalBeeSecrets_noreveal:
    CLC
    RTL
Limited_PedestalBeeSecrets:
    LDA.b IndoorsFlag : BNE .noreveal
    LDA.b OverworldIndex : CMP.b #$15 : BNE +
        LDA.b #$04 : BRA .set_secret
    + CMP.b #$11 : BNE +
        LDA.b #$06 : BRA .set_secret
    + CMP.b #$43 : BNE +
        LDA.b #$08 : BRA .set_secret
    + CMP.b #$12 : BNE +
        LDA.b #$0A : BRA .set_secret
    + CMP.b #$7A : BNE +
        LDA.b #$0C : BRA .set_secret
    + CMP.b #$5B : BNE +
        LDA.b #$0E : BRA .set_secret
    + CMP.b #$5E : BNE +
        LDA.b #$02 : BRA .set_secret
    + CMP.b #$00 : BNE +
        LDA.b #$10 : BRA .set_secret
    +
    BRA .noreveal
.set_secret
    STA.b Scrap02
    PHX
        JSL GetRandomInt : AND.b #$03 : PHA
        JSL GetRandomInt : AND.b #$03 : PHA
        REP #$20
        LDX.b Scrap02
        LDA.l .secret_xpos,X
        STA.b Scrap00
        PLX
        LDA.l Bee_BounceBoundaries, X : AND.w #$00FF
        CLC : ADC.b Scrap00
        STA.b Scrap04
        LDX.b Scrap02
        LDA.l .secret_ypos,X
        STA.b Scrap02
        PLX
        LDA.l Bee_BounceBoundaries, X : AND.w #$00FF
        CLC : ADC.b Scrap02
        STA.b Scrap06
        SEP #$20
    PLX 
    SEC 
    RTL

.secret_xpos
dw $0000, $0FA8, $0B40, $02F8, $0688, $04A0, $0460, $06E8 ; pedestals
dw $0280, $0000, $0000, $0000

.secret_ypos
dw $0000, $0770, $0418, $0520, $0068, $05F0, $0F10, $07C8 ; pedestals
dw $0060, $0000, $0000, $0000

pushpc
org $82AE8E
JSL MasterSword_ConditionalLoadOverlay
pullpc

; return Z = 0 if vanilla, 1 if limited
; return C = 0 if not pulled, 1 if pulled, irrelevant if Z=0
MasterSword_LimitedCheckIfPulled:
    LDA.l !LoadedPedestalNumber : BEQ .vanilla
    PHX
        XBA : LDA.b #$00 : XBA
        TAX
        SEC : LDA.b #$00
        - ROL : DEX : BNE -
        AND.l !PedestalCollectedFlags : CMP.b #$01
    PLX
    INC
    RTL
.vanilla
    LDA.b #$00
    RTL

MasterSword_LimitedActivateCutscene:
    JSL MasterSword_LimitedCheckIfPulled : BEQ .exit
        REP #$30
        LDA.w #$1020
        LDX.w ItemStackPtr : STA.l ItemGFXStack, X
        LDA.w #$BCE0>>1 : STA.l ItemTargetStack, X
        TXA : INC #2 : STA.w ItemStackPtr
        SEC : RTL
.exit
    CLC : RTL

MasterSword_LimitedHandleReceipt:
    JSL MasterSword_LimitedCheckIfPulled : BEQ .exit
    LDY.b #$6C
    PHX
        LDA.l !LoadedPedestalNumber : TAX
        SEC : LDA.b #$00
        - ROL : DEX : BNE -
        ORA.l !PedestalCollectedFlags
        STA.l !PedestalCollectedFlags
        LDA.b #$01 : STA.l !MULTIWORLD_RECEIVING_ITEM
    PLX
.exit
    RTL

MasterSword_ConditionalLoadOverlay:
    SEP #$20
    JSL MasterSword_LimitedCheckIfPulled
    REP #$20
    BEQ .vanilla : BCC +
        LDA.w #$0040 : RTL 
    + LDA.w #$0000 : RTL
.vanilla
    LDA.l OverworldEventDataWRAM, X ; what we wrote over
    RTL

Limited_ResetOnOWTransition:
    LDA.b #$00 : STA.l !LoadedPedestalNumber
.exit
    RTL

Limited_HammerPegSwampNook:
    LDA.b OverworldIndex : CMP.w #$007A : BNE .exit
    INC.w HammerPegCounter
    LDA.w HammerPegCounter : CMP.w #$0007 : BNE .exit
    PHX 
        SEP #$20
        LDA.l OverworldEventDataWRAM+$7A : ORA.b #$20
        STA.l OverworldEventDataWRAM+$7A
        LDA.b #$1B : STA.w SFX3
        REP #$20
        LDA.w #$0050 : STA.w TileMapUpdateId
        LDA.w #$0A1E : STA.w TileMapTile32
        JSL Overworld_DoMapUpdate32x32_long
        REP #$30
    PLX
.exit
    RTL

Limited_HandlePedestalEntrances:
    LDA.w OverworldIndexMirror : CMP.w #$0015 : BNE +
        LDA.b LinkPosX : AND.w #$FFF8 : CMP.w #$0B40 : BNE .exit
        LDA.w #$0003 : BRA .load_pedestal
    + CMP.w #$001E : BNE +
        LDA.b LinkPosX : AND.w #$FFF8 : CMP.w #$0CC8 : BNE .exit
        LDA.w #$0000 : STA.l !StatueGFXLoaded
        LDA.w #$0001 : BRA .load_pedestal
    + CMP.w #$0043 : BNE +
        LDA.b LinkPosX : AND.w #$FFF8 : CMP.w #$0688 : BNE .exit
        LDA.w #$0005 : BRA .load_pedestal
    + CMP.w #$005B : BNE +
        LDA.b LinkPosX : AND.w #$FFF8 : CMP.w #$06E8 : BNE .exit
        LDA.w #$0008 : BRA .load_pedestal
    + CMP.w #$005E : BNE +
        LDA.b LinkPosX : AND.w #$FFF8 : CMP.w #$0FA8 : BNE .exit
        LDA.w #$0002 : BRA .load_pedestal
    + CMP.w #$007A : BNE .exit
        LDA.w #$0007 : BRA .load_pedestal
.load_pedestal
    SEP #$20
    STA.l !LoadedPedestalNumber
    PLA : REP #$20 : PLX ; discard return address
    LDX.w #$0000
    JML Overworld_DoSpecialOverworldTrigger
.exit
    RTL

pushpc
org $9BC8BE
JSL Overworld_OverrideSecrets : NOP

org $9BC0C6
JSL Overworld_OverrideSecretFlag : NOP #2
pullpc

; if bushdrop shuffle is ever implemented, this would need to be
;   removed and entries would need to be added thru the generator
Overworld_OverrideSecrets:
    CPX.w #$0043<<1 : BNE .vanilla
    LDA.w #OverworldData_HiddenItems_Screen_43 : STA.b Scrap00
    LDA.w #OverworldData_HiddenItems_Screen_43>>16 : STA.b Scrap02
    RTL
.vanilla
    LDA.w #$009B : STA.b Scrap02 ; what we wrote over
    RTL

Overworld_OverrideSecretFlag:
    CPX.w #$0043 : BNE .vanilla
        LDA.l OverworldEventDataWRAM, X : ORA.b #$40
        RTL
.vanilla
    LDA.l OverworldEventDataWRAM, X : ORA.b #$20
    RTL

OverworldData_HiddenItems_Screen_43:
    db $10, $03, $84 ; Staircase    xy:{ 0x080, 0x060 }
    db $60, $0A, $04 ; Random pack  xy:{ 0x300, 0x140 }
    db $DA, $0B, $04 ; Random pack  xy:{ 0x2D0, 0x160 }
    db $E6, $0B, $04 ; Random pack  xy:{ 0x330, 0x160 }
    db $60, $0D, $04 ; Random pack  xy:{ 0x300, 0x1A0 }
    db $20, $19, $01 ; Green rupee  xy:{ 0x100, 0x320 }
    db $04, $1A, $04 ; Random pack  xy:{ 0x020, 0x340 }
    db $EE, $17, $06 ; Heart        xy:{ 0x370, 0x2E0 }
    db $68, $19, $06 ; Heart        xy:{ 0x340, 0x320 }
    db $74, $19, $06 ; Heart        xy:{ 0x3A0, 0x320 }
    db $EE, $1A, $06 ; Heart        xy:{ 0x370, 0x340 }
    dw $FFFF

Limited_OverworldTransitionPedestal:
    TXY : LDA.l !ScreenSequenceIndex : TAX
    TYA : CMP.l .lookupid, X : BNE .reset
    LDA.w TransitionDirection : CMP.l .direction, X : BNE .reset
        LDA.l .override, X : STA.w RandoOverworldTargetEdge
        CPX.w #$000A : BNE +
            SEP #$20
            LDA.b #$06 : STA.l !LoadedPedestalNumber
            LDA.b #$00 : STA.l !ScreenSequenceIndex
            REP #$20
            LDA.w #$1B00 : STA.w SFX2
            RTL
        +
        LDA.w #$2D00 : STA.w SFX2
        INX : INX : TXA
        BRA .increment
.reset
    LDA.w #$0000
.increment
    STA.l !ScreenSequenceIndex
    RTL

.lookupid
dw $0090, $0050, $00A0, $0070, $0040, $0060
.direction
dw $0001, $0002, $0001, $0003, $0002, $0000
.override
dw $0006, $0007, $0006, $0005, $0006, $B080

Limited_FluteMenu_PedestalDestination:
    LDA.l !FortuneRead : BEQ .exit
    LDA.w FluteSelection : CMP.b #($04-1)<<1 : BNE .exit
        LDA.b #$04 : STA.l !LoadedPedestalNumber
        STZ.w CutsceneFlag
        STZ.b LinkVisible
        STZ.w ItemReceiptPose
        PLA : REP #$30 : PLX ; discard return address
        LDX.w #$0000 : JML Overworld_DoSpecialOverworldTrigger
.exit
    RTL

pushpc
org $8DC849
LDA.b #$00 : NOP #2

org $8DC986 : JSL FortuneTeller_TakeMoney_Additional
org $8DCA89 : JSL FortuneTeller_TakeMoney_Additional
pullpc

FortuneTeller_TakeMoney_Additional:
    STA.l HeartsFiller ; what we wrote over
    LDA.b #$01 : STA.l !FortuneRead
    RTL

; Lost Woods Fake Master Sword Gimmick
pushpc
org $86E091
JSL ThrownSprite_FakeMasterSwordDeath : NOP
pullpc

Limited_InitializeWallmasterTileset:
    LDA.b LinkFallPose : BEQ .exit
    LDA.b IndoorsFlag : BEQ .exit
    LDA.w OverworldIndexMirror : BNE .exit ; came in from lost woods
    LDA.w OWTransitionFlag : BEQ .exit
        LDA.b #$23 : STA.l LastSpriteSet+2 : STA.b Scrap07 ; wallmaster gfx
.exit
    RTL

Limited_UnderworldPrepWallmasterKickOut:
    LDA.b LinkFallPose : BEQ .vanilla
    LDA.b IndoorsFlag : BEQ .vanilla
    LDA.w OverworldIndexMirror : BNE .vanilla ; came in from lost woods
    LDA.w OWTransitionFlag : BEQ .vanilla
        LDA.b #$90 : LDY.b #$09 : JSL Sprite_SpawnDynamically
        LDA.b LinkPosX : STA.w SpritePosXLow,Y
        LDA.b LinkPosX+1 : STA.w SpritePosXHigh,Y
        LDA.b LinkTargetPosY : STA.w SpritePosYLow,Y
        LDA.b LinkTargetPosY+1 : STA.w SpritePosYHigh,Y
        LDA.b #$80 : STA.w SpriteZCoord,Y
        LDA.b #$01 : STA.w SpriteAuxTable, Y
            STA.w CutsceneFlag
            STA.l !KickedOutMessage
        LDA.b #$20 : STA.w SFX2
        LDA.b #$00
        RTL
.vanilla
    LDA.b #$01
    RTL

Limited_LoadOverworldFromUnderworld:
    LDA.l !KickedOutMessage : BEQ .exit
    PLA : PLA : PLA : PLA : PLA : PLA
    LDA.b #$08 : STA.b GameMode
    STZ.b SubSubModule
    REP #$20
    LDA.w #$0100 : STA.b RoomIndex
    LDA.w #$0208 : STA.l EN_POSY
    LDA.w #$0320 : STA.l EN_POSX
    SEP #$20
    JML $82E337 ; some RTS in bank 02
.exit
    RTL

Limited_ShowAwaitingMessage:
    LDA.l !KickedOutMessage : BEQ .exit
        LDA.l !LostWoodsMessage+1 : TAY : LDA.l !LostWoodsMessage
        JSL Sprite_ShowMessageUnconditional
        LDA.b #$00 : STA.l !KickedOutMessage
.exit
    RTL

Limited_ModifyFakeSwordOverPit:
    LDA.w OWTransitionFlag : BEQ .exit
    CPY.b #$20 : BNE .exit ; over pit
    LDA.w SpriteTypeTable, X : CMP.b #$E8 : BNE .exit
        LDA.w SpriteVelocityY, X : JSL DivideByTwoPreserveSign : STA.w SpriteVelocityY, X
        LDA.w SpriteVelocityX, X : JSL DivideByTwoPreserveSign : STA.w SpriteVelocityX, X
        LDA.w SpriteVelocityZ, X : SEC : SBC.b #$02 : STA.w SpriteVelocityZ, X
.exit
    RTL

ThrownSprite_FakeMasterSwordDeath:
    LDA.b #$06 : STA.w SpriteAITable, X ; what we wrote over
    LDA.w CurrentSpriteTile : CMP.b #$20 : BNE .exit ; over pit
    LDA.l OWTransitionFlag : BEQ .exit
        STZ.w OWTransitionFlag
        LDA.b #$09 : STA.w SFX3
.exit
    RTL

; Snitch Cucco Storm Gimmick
pushpc

org $9DC9CD
JSL Thief_Chasing_CuccoStorm : NOP #2
db $B0, $05 ; BCS to skip over following JSR

org $9DCCC2
JSL SpriteDraw_Thief_SnitchVariant

pullpc

SpriteDraw_Thief_SnitchVariant:
    TAX ; part of what we wrote over
    LDA.b IndoorsFlag : BNE .vanilla
    LDA.b OverworldIndex : CMP.b #$18 : BNE .vanilla
        LDY.b #$06
        LDA.l .oam_body,X : STA.b ($90),Y
        LDA.l .oam_head,X
        RTL
.vanilla
    LDA.l $9DCC96,X ; part of what we wrote over
    RTL

.oam_head
    db $E2, $E2, $C0, $E0
.oam_body
    db $E4, $E4, $C2, $E8

Thief_Chasing_CuccoStorm:
    INC.w SpriteActivity, X : LDA.b #$20 : STA.w SpriteTimer, X ; what we wrote over
    LDA.b IndoorsFlag : BNE .exit
    LDA.b OverworldIndex : CMP.b #$18 : BNE .exit
        PHX
            JSL CuccoStorm_activate
        PLX
        SEC
        RTL
.exit
    CLC
    RTL

; Flying Floor Tiles
pushpc
org $89BA8A
JSL SpawnFlyingTile_FollowLink : NOP
pullpc

SpawnFlyingTile_FollowLink:
    LDA.b #$04 : STA.w SpriteHitPoints,Y ; what we wrote over
    LDA.b LinkPosX : JSR .within_range
    CMP.b #$C0 : BCC +
        LDA.b #$C0
    + STA.w SpritePosXLow,Y
    LDA.b LinkPosY : JSR .within_range
    CMP.b #$B0 : BCC +
        LDA.b #$B0 : CLC
    + ADC.b #$08 : STA.w SpritePosYLow,Y
.exit
    RTL
.within_range
    CLC : ADC.b #$08 : AND.b #$F0
        CMP.b #$10 : BCS .return
            LDA.b #$10
.return
    RTS

; Desert Statue Gimmick
pushpc
org $8595DA : NOP #5
org $8595E6 : db #$03
org $8595F3
JSL DesertStatue_Moving_Finish : NOP
STZ.w $02F0
pullpc

DesertStatue_Moving_Finish:
    STZ.w SpriteActivity, X
    STZ.w SpriteSpawnStep, X
    RTL

; Z1 Armos Gimmick
pushpc
org $87C0F7
JSL CheckForGravePush_Conditional

org $87CB2E
JSL CheckForZ1StatuePush : NOP

org $8999E0
JSL AncillaAdd_Z1ArmosStatue

org $85A072
JSL ArmosKnight_KnightDead

org $85B800
JSL SpriteDraw_Z1ArmosStatue_Alternate : NOP
org $85B758
JSL ArmosStatue_InactivePalette : NOP

org $85A288
JSL SpriteDraw_Z1ArmosKnight_Alternate
org $9DEF7E
JSL ArmosKnight_RedCrusherPalette : NOP

org $8FFE97 : db $42 : skip 5 : db $42 : skip 8 : db $42, $42 : skip 5 : db $42 ; make statues pushable
pullpc

CheckForGravePush_Conditional:
    BEQ .reset_push_timer ; what we
    LDA.b LinkLastDirection : BEQ .continue ; wrote over
    LDA.b OverworldIndex : CMP.b #$1E : BEQ .continue
.reset_push_timer
    LDA.b #$01
.continue
    RTL

; most of this code is copied from CheckForGravePush
CheckForZ1StatuePush:
    STZ.b $6B ; part of what we wrote over
    LDA.b OverworldIndex : CMP.b #$1E : BNE .reset_push_timer
    LDA.w $02E7 : AND.b #$0F : BEQ .reset_push_timer
    LDA.b LinkLastDirection : AND.b #$02 : BEQ .reset_push_timer
    DEC.b $61 : BPL .return
.dashing
    LDA.b Scrap0E : PHA
        LDY.b #$04 : LDA.b #$24 ; ANCILLA 24
        JSL AncillaAdd_GraveStone
    PLA : STA.b Scrap0E
.reset_push_timer
    LDA.b #$34 : STA.b $61
.return
    LDA.w $02E8 ; part of what we wrote over
    RTL

AncillaAdd_Z1ArmosStatue_gravestone:
    REP #$30 : LDY.b LinkPosY ; what we wrote over
    RTL
AncillaAdd_Z1ArmosStatue:
    LDA.b OverworldIndex : CMP.b #$1E : BNE .gravestone
    PLA : PLA : PLA ; discard return address
    LDA.b #AncillaAdd_Z1ArmosStatue>>16 : STA.b Scrap06 : PHA : PLB
    STZ.w AncillaID, X

    REP #$30
    LDA.b LinkLastDirection : AND.w #$0002 : BNE +
        ; up/down, set X
        LDA.b LinkPosX : CLC : ADC.w #$0008 : AND.w #$FFF0 : STA.b Scrap02
        BRA .determine_xy
    + ; left/right, set Y
    LDA.b LinkPosY : AND.w #$FFF0 : CLC : ADC.w #$0008 : STA.b Scrap00
.determine_xy
    LDA.b LinkLastDirection : AND.w #$00FF : BNE + ; up
        LDA.b LinkPosY : SEC : SBC.w #$001C : AND.w #$FFF8 : STA.b Scrap00
        BRA .search
    + DEC : BNE + ; down
        LDA.b LinkPosY : CLC : ADC.w #$0010 : AND.w #$FFF8 : STA.b Scrap00
        BRA .search
    + DEC : BNE + ; left
        LDA.b LinkPosX : SEC : SBC.w #$001C : AND.w #$FFF0 : STA.b Scrap02
        BRA .search
    + LDA.b LinkPosX : CLC : ADC.w #$0010 : AND.w #$FFF0 : STA.b Scrap02 ;right
.search
    LDA.b LinkLastDirection : AND.w #$00FF : ASL : TAX
    LDA.w .direction, X : STA.b Scrap04
    LDY.w #((.position_x-.position_y)+2)
.next_statue
    JMP.w [Scrap04]
.direction
    dw .check_up, .check_down, .check_left, .check_right

.check_up
    LDA.w .position_y, Y : CMP.b Scrap00 : BNE .continue
    LDA.w .position_x, Y : DEC : CMP.b Scrap02 : BCS .continue
    CLC : ADC.w #$0020 : CMP.b Scrap02 : BCC .continue
    BRA .found_statue
.check_down
    LDA.w .position_y, Y : CMP.b Scrap00 : BNE .continue
    LDA.w .position_x, Y : DEC : CMP.b Scrap02 : BCS .continue
    CLC : ADC.w #$0020 : CMP.b Scrap02 : BCC .continue
    BRA .found_statue
.check_left
    LDA.w .position_x, Y : CMP.b Scrap02 : BNE .continue
    LDA.w .position_y, Y : DEC : CMP.b Scrap00 : BCS .continue
    CLC : ADC.w #$0020 : CMP.b Scrap00 : BCC .continue
    BRA .found_statue
.check_right
    LDA.w .position_x, Y : CMP.b Scrap02 : BNE .continue
    LDA.w .position_y, Y : DEC : CMP.b Scrap00 : BCS .continue
    CLC : ADC.w #$0020 : CMP.b Scrap00 : BCC .continue
    BRA .found_statue

.continue
    DEY #2 : BMI + : JMP.w [Scrap04] : +
    SEP #$30
    BRL .exit

.found_statue
    LDX.w .tilemap_offset, Y

    PHY
        LDA.w #$02E5 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
        INX #2
        LDA.w #$02E5 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
        TXA : CLC : ADC.w #$007E : TAX
        LDA.w #$02E5 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
        INX #2
        LDA.w #$02E5 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
    PLX
    SEP #$30
    LDA.b #$01 : STA.b NMISTRIPES

    PHX
        TXA : LSR : TAX
        LDA.w .sprite_id,X
        PHA
            JSL Sprite_SpawnDynamically
            BMI +
                JSL SpritePrep_LoadProperties
            +
        PLA
    PLX
    CPY.b #$00 : BMI .exit

    CMP.b #$53 : BNE +
        LDA.b #$01 : STA.w $0FF8 ; Red Armos Knight
        BRA .set_position
    +
    LDA.b #$02 : STA.w SpriteSpawnStep, Y
    LDA.b #$0D : STA.w SpriteOAMProp, Y
.set_position
    REP #$20
    LDA.w .position_x, X : CLC : ADC.w #$0008 : STA.b Scrap00
    LDA.w .position_y, X : CLC : ADC.w #$0010 : STA.b Scrap02
    SEP #$20

    LDA.b Scrap02 : STA.w SpritePosYLow, Y
    LDA.b Scrap03 : STA.w SpritePosYHigh, Y

    LDA.b Scrap00 : STA.w SpritePosXLow, Y
    LDA.b Scrap01 : STA.w SpritePosXHigh, Y

    LDA.l !StatueGFXLoaded : BNE +
        LDA.b #$01 : STA.l !StatueGFXLoaded : STA.l !GFXLoadFlag
    +
.exit
    PLB : RTL

.position_y
    ;dw $06B0
    ;dw $06B0
    dw $0818
    dw $0828
    dw $0828
    dw $0828
    dw $0858
    dw $0858
    dw $0888
    dw $0888
    dw $0888
    dw $0938
    dw $0938
.position_x
    ;dw $0EE0
    ;dw $0FB0
    dw $0E20
    dw $0C60
    dw $0CC0
    dw $0D20
    dw $0CC0
    dw $0EC0
    dw $0C60
    dw $0CC0
    dw $0D20
    dw $0D20
    dw $0D80
.tilemap_offset
    ;dw $05DC
    ;dw $05F6
    dw $1144
    dw $118C
    dw $1198
    dw $11A4
    dw $1318
    dw $1358
    dw $148C
    dw $1498
    dw $14A4
    dw $1A24
    dw $1A30
.sprite_id
    ;db $51
    ;db $51
    db $51
    db $51
    db $51
    db $51
    db $53
    db $51
    db $51
    db $51
    db $51
    db $51
    db $51

ArmosKnight_KnightDead:
    JSL $89AF32 ; CheckIfScreenIsClear - what we wrote over
    BCC .exit
    LDA.b IndoorsFlag : BNE .exit
        ; reveal entrance
        LDA.b #$1A : STA.w SFX3
        LDA.l OverworldEventDataWRAM+$1E : ORA.b #$40
        STA.l OverworldEventDataWRAM+$1E
        REP #$30
            LDA.w #$0912 : LDX.w #$1318 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
            LDA.w #$0913 : LDX.w #$131A : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
            LDA.w #$0914 : LDX.w #$1398 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
            LDA.w #$0915 : LDX.w #$139A : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
        SEP #$30
        LDA.b #$01 : STA.b NMISTRIPES
        CLC
.exit
    RTL

ArmosStatue_InactivePalette:
    LDA.b #$0B ; what we
    CLC : ADC.w SpriteSpawnStep, X
    STA.w SpriteOAMProp, X ; wrote over
    RTL

ArmosKnight_RedCrusherPalette:
    LDA.b IndoorsFlag : BNE .vanilla
        LDA.b #$03
        BRA .set_palette
.vanilla
    LDA.b #$07 ; what we
.set_palette
    STA.w SpriteOAMProp, X ; wrote over
    RTL

SpriteDraw_Z1ArmosStatue_Alternate:
    LDA.w SpriteSpawnStep, X : BEQ .vanilla
        PHB : PHK : PLB
            JSL OAM_AllocateFromRegionC
            REP #$20
            LDA.w #.oam_groups : STA.b Scrap08
            SEP #$20
            LDA.b #$04 : JSL Sprite_DrawMultiple
            JSL OAM_AllocateFromRegionF
        PLB
    RTL
.vanilla
    LDA.b #$02 : JML Sprite_DrawMultiple ; what we wrote over
.oam_groups
dw  -8, -12 : db $CE, $00, $00, $02
dw   8, -12 : db $CE, $40, $00, $02
dw  -8,   4 : db $EE, $00, $00, $02
dw   8,   4 : db $EE, $40, $00, $02

SpriteDraw_Z1ArmosKnight_Alternate:
    LDA.b IndoorsFlag : BNE .vanilla
        PLA : PLA : PEA.w $A2E7 ; discard return address
        PHB : PHK : PLB
            JSL OAM_AllocateFromRegionC
            REP #$20
            LDA.w #.oam_groups : STA.b Scrap08
            SEP #$20
            LDA.b #$04 : JSL Sprite_DrawMultiple
            JSL OAM_AllocateFromRegionF
            JSL Sprite_DrawShadowLong
        PLB
.vanilla
    LDA.w SpriteGFXControl, X : ASL ; what we wrote over
    RTL
.oam_groups
dw  -8, -12 : db $CE, $00, $00, $02
dw   8, -12 : db $CE, $40, $00, $02
dw  -8,   4 : db $EE, $00, $00, $02
dw   8,   4 : db $EE, $40, $00, $02

Limited_TransferGFX_exit:
    RTL
Limited_TransferGFX:
    LDA.l !GFXLoadFlag : BEQ .exit
        PHP
            REP #$10
            SEP #$20
            LDA.b #$80 : STA.w VMAIN
            LDA.b #$01 : STA.w DMA0MODE
            DEC : STA.l !GFXLoadFlag
            LDA.b #$18 : STA.w DMA0PORT
            LDA.b #$A2 : STA.w DMA0ADDRB

            REP #$20
            ; row 0 (tiles 0-1)
            LDA.w #$B9C0>>1 : STA.w VMADDR
            LDA.w #$9C20 : STA.w DMA0ADDR
            LDA.w #$0040 : STA.w DMA0SIZE
            SEP #$20 : LDA.b #$01 : STA.w DMAENABLE : REP #$20
            ; row 1 (tiles 2-3)
            LDA.w #$BBC0>>1 : STA.w VMADDR
            LDA.w #$9E20 : STA.w DMA0ADDR
            LDA.w #$0040 : STA.w DMA0SIZE
            SEP #$20 : LDA.b #$01 : STA.w DMAENABLE : REP #$20
            ; row 2 (tiles 4-5)
            LDA.w #$BDC0>>1 : STA.w VMADDR
            LDA.w #$A020 : STA.w DMA0ADDR
            LDA.w #$0040 : STA.w DMA0SIZE
            SEP #$20 : LDA.b #$01 : STA.w DMAENABLE : REP #$20
            ; row 3 (tiles 6-7)
            LDA.w #$BFC0>>1 : STA.w VMADDR
            LDA.w #$A220 : STA.w DMA0ADDR
            LDA.w #$0040 : STA.w DMA0SIZE
            SEP #$20 : LDA.b #$01 : STA.w DMAENABLE : REP #$20
        PLP
    RTL

; Kiki Banana Fetch Game
pushpc
org $9EE516
JSL Kiki_VerifyPurchaseCheckBanana
pullpc

SpritePrep_KikiBanana:
    LDA.l OverworldEventDataWRAM+$5E : AND.b #$60 : CMP.b #$60 : BEQ .despawn
    ; despawn if one exists already
    LDY.b #$0F
    STX.b Scrap00
    - CPY.b Scrap00 : BEQ +
        LDA.w SpriteTypeTable, Y : CMP.b #$03 : BNE +
            .despawn
            STZ.w SpriteAITable, X
            RTL
    + DEY : BPL -

    LDA.b #$00 : STA.l !BananaFlags : STA.l !BananaFlags+1
    STA.w SpriteAux, X : STA.w SpriteSpawnStep, X : STA.w SpriteTimer, X

    PHX
        REP #$20
        LDA.w #$1160 ; banana gfx
        LDX.w ItemStackPtr : STA.l ItemGFXStack, X
        LDA.w #$B840>>1 : STA.l ItemTargetStack, X
        TXA : INC #2 : STA.w ItemStackPtr
        SEP #$20
    PLX
    RTL

Sprite_03_KikiBanana:
    STZ.w SpriteAux, X : STZ.w SpriteDirectionTable, X
    LDY.b #$00
.next_instance
    PHY
        REP #$20
        INY : LDA.l !BananaFlags
        - ROR : DEY : BNE -
        SEP #$20
    PLY
    BCS .collected
    JSL KikiBanana_SetCoords
    JSL Sprite_Get16BitCoords_long
    PHY
        JSL Sprite_PrepOAMCoordLong
    PLY
    LDA.w SpriteDirectionTable, X : BNE +
        TYA : INC : STA.w SpriteDirectionTable, X
    + BCS .skip_instance ; offscreen
    REP #$20
        ; check if link is close to banana
        LDA.w SpriteTimer, X : BNE ++
            LDA.w SpriteCoordCacheX : SEC : SBC.w LinkPosX : BPL +
                EOR.w #$FFFF : INC
            + CMP.w #$0018 : BCS ++
                LDA.w SpriteCoordCacheY : SEC : SBC.w LinkPosY : BPL +
                    EOR.w #$FFFF : INC
                + CMP.w #$0018 : BCS ++
                    SEP #$20
                    TYA : INC : ASL #4
                    ORA.w SpriteAux, X : STA.w SpriteAux, X ; set sprite coords to this index later
        ++
    SEP #$20
    PHY
        JSL SpriteDraw_KikiBanana
    PLY
.skip_instance
    INC.w SpriteAux, X
.collected
    INY : CPY.b #(!BananaYPos-!BananaXPos) : BCC .next_instance
    LDA.w SpriteTimer, X : DEC : BNE +
        LDA.b #$FF : STA.w HUDTimer
    +
    LDA.w SpriteAux, X : LSR #4 : BEQ .exit
    TAY : DEY
    JSL KikiBanana_SetCoords
    JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .exit
        JML KikiBanana_Collect
.exit
    RTL

; X = sprite index
; Y = banana index
KikiBanana_Collect:
    INC.w SpriteSpawnStep, X
    LDA.b #$0A : STA.w SFX3
    TYA : INC : CMP.w SpriteDirectionTable, X : BNE +
        INC.w SpriteSpawnStep, X
        LDA.b #$2D : STA.w SFX3
    +
    REP #$20
        SEC : INY : LDA.w #$0000
        - ROL : DEY : BNE -
        ORA.l !BananaFlags : STA.l !BananaFlags
    SEP #$20
    LDA.b #$10 : STA.w SpriteTimer, X
    LDA.b #$FF : STA.w HUDTimerDelay
    LDA.w SpriteSpawnStep, X : STA.w HUDTimer
    CMP.b #((!BananaYPos-!BananaXPos)<<1) : BNE +
        ; reveal entrance
        LDA.b #$1A : STA.w SFX3
        LDA.l OverworldEventDataWRAM+$5E : ORA.b #$40
        STA.l OverworldEventDataWRAM+$5E
        REP #$30
            LDA.w #$0912 : LDX.w #$0B74 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
            LDA.w #$0914 : LDX.w #$0BF4 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
            LDA.w #$0913 : LDX.w #$0B76 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
            LDA.w #$0915 : LDX.w #$0BF6 : JSL Overworld_MemorizeMap16Change : JSL Overworld_DrawPersistentMap16
        SEP #$30
        LDA.b #$01 : STA.b NMISTRIPES
    +
    RTL

; X = sprite index
; Y = banana index
SpriteDraw_KikiBanana:
    PHY
        LDA.b #$08 : JSL OAM_AllocateFromRegionA
        JSL Sprite_PrepAndDrawSingleLargeLong  ; draws gfx at current coord
    PLY
    TYA : INC : CMP.w SpriteDirectionTable, X : BNE .exit
        LDA.w SpritePosYLow, X : CLC : ADC.b #$10 : STA.w SpritePosYLow, X
        LDA.w SpritePosYHigh, X : ADC.b #$00 : STA.w SpritePosYHigh, X
        JSL Sprite_SpawnSparkleGarnish
.exit
    RTL

KikiBanana_SetCoords:
    PHX : TYX : PLY
        REP #$20
            LDA.l !BananaXPos, X : AND.w #$007F
            ASL #4 : CLC : ADC.w $0604
        SEP #$20
        STA.w SpritePosXLow, Y : XBA : STA.w SpritePosXHigh, Y
        REP #$20
            LDA.l !BananaYPos, X : AND.w #$007F
            ASL #4 : CLC : ADC.w $0600
        SEP #$20
        STA.w SpritePosYLow, Y : XBA : STA.w SpritePosYHigh, Y
    PHX : TYX : PLY
    RTL

Kiki_VerifyPurchaseCheckBanana:
    LDY.b #$0F
    - LDA.w SpriteTypeTable, Y : CMP.b #$03 : BNE +
        LDA.w SpriteSpawnStep, Y : CMP.b #(!BananaYPos-!BananaXPos) : BCS .checkrupees
        BRA .fail
    + DEY : BPL -
.fail
    CLC : PLA : LDA.b #$1C : PHA ; overwrite return address to fail rupee check
    RTL
.checkrupees
    LDA.b #$64 : LDY.b #$00 ; what we wrote over
    RTL

; Ganon Gimmick
pushpc
org $9D8FCC
JML Ganon_MaybeWarpOnLink
org $9D8F58
JSL Sprite_Ganon_skip_damage : NOP #2
org $9D8EEA
JSL Ganon_MaybeEnableVulnerabilty : NOP
org $9DF00F
JSL RedArmosCrusher_Jump_adjust_proximity : NOP #2
org $89EE44
JSL Ganon_FakeVictory : NOP
org $81C78A
JSL RoomTag_GanonDoor_victory
pullpc

macro JSRLongCall_Bank1D(call, return)
    PHK : PEA.w (<return>)-1 ; address to return back to
    PEA.w $88BB-1 ; some RTL in bank 1D
    JML <call>
endmacro

; $0D80 - SpriteActivity - this determines which routine runs on the next frame, the added routines are $14-$1B
; $0C9A - SpriteScreenOwner - prevents vanilla torch-based invulnerability check from activating
;                             *allows our code to properly let Ganon be set up for this newly added phase
; $0BA0 - SpriteAncillaInteract - this is used to skip the collision/damage check
;                                 *sometimes is ineffective under certain conditions
; $0CAA - SpriteDeflection - this is used to bypass activating an invulnerability timer* during the $0A carry state
;                            *this timer caused routine code to be skipped for a period after throwing Ganon
; $0E40 - SpriteOAMProperties - toggles 'harmless' bit to selectively avoid collision/damage in stunned phase

; $0E90/$0DA0/$0DB0 - SpriteAuxB/SpriteAuxTable/SpriteAuxTableB - Armos code uses these to temp store Link's coords

; $0EB0 - SpriteDirectionTable - this is used to change the direction Ganon faces
;                                *Armos code also uses this to temp store part of Link's coords
; $0DC0 - SpriteGFXControl - this determines which body gfx Ganon uses
; $0DE0 - SpriteMoveDirection - this determines which head gfx Ganon uses
; $0ED0 - SpriteSpawnStep - controls gfx for Ganon's trident
;                           *Armos code increments this to determine if ready for the next routine
; $0F50 - SpriteOAMProp - controls the palette for Ganon gfx

; $0EC0 - SpriteAuxC - used to count how many times Ganon was hit since last reset
; $0D90 - SpriteMovement - used to count how many times Ganon has smashed the floor since last reset

; $0E70 - SpriteTileCollision - this is zeroed when we want Ganon to clip thru tiles
;                               *helps let him clip into walls slightly to allow pit fall
; $0B68 - SpriteTileDeath - this allows Ganon to fall into pits

; $0DF0 - SpriteTimer - this is the primary routine countdown timer
; $0E00 - SpriteTimerB - while active, this skips damage checks, but also exits Ganon code early
; $0F10 - SpriteTimerE - this timer allows the current routine to pause and let recoil take visual effect
; $0EE0 - SpriteTimerD - controls duration of floor shake

Ganon_MaybeWarpOnLink:
    ; Ganon in phase 4 has a chance to warp on Link's position
    JSL RNG_Ganon : AND.b #$03 : BNE .vanilla
        LDA.b LinkPosX : STA.l $7FFD5C
        LDA.b LinkPosY : STA.l $7FFD68
        LDA.b #$12 : JML Ganon_SelectWarpLocation_custom
.vanilla
    LDA.b #$12 : JML Ganon_SelectWarpLocation ; what we wrote over

Ganon_FakeVictory:
    LDA.b #$13 : STA.w MusicControlRequest ; what we wrote over
    LDA.b #$09 : STA.w SpriteAITable, X
    LDA.b #$01 : STA.w CutsceneFlag : STA.w ForceSwordUp
    LDA.b #$14 : STA.w SpriteActivity, X
    LDA.b #$04 : STA.w SpriteHitPoints, X
    LDA.b #$80 : STA.w SpriteTimer, X
    LDA.b #$FF : STA.w SpriteGFXControl, X
    LDA.w SpriteDeflection, X : ORA.b #$80 : STA.w SpriteDeflection, X
    STZ.w SpriteTimerB, X
.exit
    RTL

RoomTag_GanonDoor_victory:
    STA.b $11 : STZ.b $B0 ; what we wrote over
    LDA.b #$13 : STA.w MusicControlRequest
    RTL

Sprite_Ganon_skip_damage_return:
    RTL
Sprite_Ganon_skip_damage:
    STZ.w SpriteAncillaInteract, X : LDA.w SpriteActivity, X ; what we wrote over
    CMP.b #$14 : BCC .return
    TAY
    PLA : PLA : PEA.w $8FAD-1 ; some RTS in bank 1D
    TYA
    SEC : SBC.b #$14
    JSL JumpTableLocal
    dw Ganon_Phase5_WaitForFanfare  ; 0x14
    dw Ganon_Phase5_SpawnBats       ; 0x15
    dw Ganon_Phase5_RelightTorches  ; 0x16
    dw Ganon_Phase5_TargetLink      ; 0x17
    dw Ganon_Phase5_Jump            ; 0x18
    dw Ganon_Phase5_Hover           ; 0x19
    dw Ganon_Phase5_PrepSlam        ; 0x1A
    dw Ganon_Phase5_Stunned         ; 0x1B

Ganon_Phase5_WaitForFanfare:
    LDA.w SpriteTimer, X : BNE .exit
    LDA.b #$A0 : STA.w SpriteTimer, X
    LDA.w SpriteHitPoints, X : DEC : STA.w SpriteHitPoints, X : BNE .exit
        INC.w SpriteActivity, X
        LDA.b #$12 : STA.w SFX1
        LDA.b #$FF : STA.w SpriteTimer, X
        LDA.b #$02 : STA.w SpriteHitPoints, X
        STZ.w SpriteMoveDirection, X
.exit
    RTL

Ganon_Phase5_SpawnBats_advance:
    INC.w SpriteActivity, X
    LDA.b #$10 : STA.w SpriteTimer, X
    LDA.b #$02 : STA.w SpriteHitPoints, X
    STZ.w SpriteLayer, X
Ganon_Phase5_SpawnBats_exit:
    RTL
Ganon_Phase5_SpawnBats:
    LDA.w SpriteTimer, X : BNE .exit
    LDA.w SpriteHitPoints, X : BEQ .advance
        LDA.b #$20 : STA.w SpriteTimer, X
        STZ.w CutsceneFlag : STZ.w ForceSwordUp
        %JSRLongCall_Bank1D(Ganon_SpawnFireBat_trailing, +) : +
        LDA.b LinkPosX : STA.l $7EC10A
        LDA.b LinkPosY : STA.l $7EC108
        LDA.b #$B8 : STA.b LinkPosY
        LDA.b #$20 : STA.w SpritePosYLow, Y
        LDA.w SpriteHitPoints, X : DEC : STA.w SpriteHitPoints, X
        AND.b #$01 : BEQ +
            ; bat 1
            LDA.b #$28 : STA.w SpritePosXLow, Y
            LDA.b #$C8 : STA.b LinkPosX
            BRA .bat_move
        + ; bat 2
        LDA.b #$C8 : STA.w SpritePosXLow, Y
        LDA.b #$28 : STA.b LinkPosX
.bat_move
    PHX : TYX
    LDA.b #$20 : JSL Sprite_ApplySpeedTowardsPlayerLong
    PLX
    LDA.l $7EC10A : STA.b LinkPosX
    LDA.l $7EC108 : STA.b LinkPosY
    RTL

Ganon_Phase5_RelightTorches_advance:
    INC.w SpriteActivity, X
    LDA.b #$FF : STA.w SpriteHitPoints, X
    LDA.b #$1F : STA.w MusicControlRequest
    STZ.w SpriteAuxC, X
    STZ.w SpriteTimerB, X
    LDA.b #$20 : STA.w SpriteTimer, X
Ganon_Phase5_RelightTorches_exit:
    RTL
Ganon_Phase5_RelightTorches:
    LDA.w SpriteTimer, X : BNE .exit
    LDA.w SpriteHitPoints, X : BEQ .advance
        LDA.w SpriteHitPoints, X : DEC : STA.w SpriteHitPoints, X
        AND.b #$01 : CLC : BEQ + : SEC : +
        LDA.b #$C0 : BCC + : INC : + : STA.w $0333
        PHP : PHX
            JSL LightTorch
        PLX : PLP
        LDA.w $04C5 : INC : STA.w SpriteScreenOwner, X
        LDY.b #$00 : TYA : BCC + : INY : + : STA.w $04F0, Y
        LDA.b #$20 : STA.w SpriteTimer, X
    RTL

Ganon_Phase5_HandleShake:
    STZ.w BG1ShakeH : STZ.w BG1ShakeH+1
    LDA.w SpriteTimerD, X : BEQ +
        AND.b #$01 : TAY
        LDA.w $9D8000, Y : STA.w BG1ShakeH
        LDA.w $9D8002, Y : STA.w BG1ShakeH+1
    +
    RTS

Ganon_Phase5_CheckDamage:
    LDA.w SpriteHitPoints, X : CMP.b #$FF : BEQ .exit
        LDA.b #$FF : STA.w SpriteHitPoints, X
        LDA.w SpriteAuxC, X : INC : CMP.b #$03 : BCS Ganon_Phase5_TargetLink_stun
            STA.w SpriteAuxC, X
            LDA.b #$10 : STA.w SpriteTimerE, X
            CMP.w SpriteTimer, X : BCS .exit
                STA.w SpriteTimer, X
.exit
    RTL

Ganon_Phase5_TargetLink_stun:
    LDA.b #$1B : STA.w SpriteActivity, X
    LDA.b #$FF : STA.w SpriteTimer, X
    STZ.w SpriteAuxC, X : STZ.w SpriteMovement, X
    STZ.w SpriteVelocityZ, X : STZ.w SpriteVelocityX, X : STZ.w SpriteVelocityY, X
Ganon_Phase5_TargetLink_exit:
    RTL
Ganon_Phase5_TargetLink:
    JSR Ganon_Phase5_HandleShake
    JSL Ganon_Phase5_CheckDamage
    %JSRLongCall_Bank1D(MoveSpriteZ_bank1D, +) : +
    LDA.w SpriteZCoord, X : BPL +
        LDA.b #$00 : STA.w SpriteZCoord, X
    +
    CMP.b #$10 : BCC +
        INC.w SpriteAncillaInteract, X
    +
    ORA.w SpriteTimer, X : BNE .exit
        LDA.b #$20 : STA.w SpriteVelocityZ, X
        JSL Sprite_ApplySpeedTowardsPlayerLong
        INC.w SpriteActivity, X
        LDA.w SpriteMovement, X : INC : STA.w SpriteMovement, X
        CMP.b #$05 : BCC +
            STZ.w SpriteAuxC, X : STZ.w SpriteMovement, X
            LDA.b #$6E : STA.w TextID
            LDA.b #$01 : STA.w TextID+1
            JSL Sprite_ShowMessageMinimal
        +
        LDA.b LinkPosX : STA.w SpriteAuxTable, X
        LDA.b LinkPosX+1 : STA.w SpriteAuxTableB, X
        LDA.b LinkPosY : STA.w SpriteAuxB, X
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
    RTL

Ganon_Phase5_Jump_exit:
    RTL
Ganon_Phase5_Jump:
    JSL Ganon_Phase5_CheckDamage
    LDA.w SpriteTimerE, X : BNE .exit
        LDA.b LinkPosY+1 : STA.w SpriteDirectionTable, X
        LDA.w SpriteSpawnStep, X : PHA : STZ.w SpriteSpawnStep, X
            %JSRLongCall_Bank1D($9DEFE0, +) : + ; RedArmosCrusher_Jump
        PLA : XBA : LDA.w SpriteSpawnStep, X : PHP
            XBA : STA.w SpriteSpawnStep, X
        PLP : BEQ +
        LDA.w SpriteZCoord, X : CMP.b #$20 : BCC +
            INC.w SpriteActivity, X
        +
        %JSRLongCall_Bank1D(MoveSpriteXYZ_bank1D, +) : +
        LDA.w SpriteZCoord, X : CMP.b #$40 : BCC +
            LDA.b #$40 : STA.w SpriteZCoord, X
            STZ.w SpriteVelocityZ, X
        +
        STZ.w SpriteDirectionTable, X
        LDA.b #$06 : STA.w SpriteGFXControl, X
        INC.w SpriteAncillaInteract, X
    RTL

RedArmosCrusher_Jump_adjust_proximity:
    PHA
        LDA.b RoomIndex : BNE .vanilla
            ; makes Ganon go closer to target
            PLA : ADC.w #$0004 : CMP.w #$0008
        RTL
.vanilla
    PLA
    ADC.w #$0010 : CMP.w #$0020 ; what we wrote over
    RTL

Ganon_Phase5_Hover:
    STZ.w SpriteVelocityZ, X
    STZ.w SpriteVelocityY, X
    STZ.w SpriteVelocityX, X
    INC.w SpriteAncillaInteract, X
    %JSRLongCall_Bank1D(MoveSpriteXYZ_bank1D, +) : +
    LDA.w SpriteTimer, X : BNE .exit
        INC.w SpriteActivity, X
.exit
    RTL

Ganon_Phase5_PrepSlam:
    LDA.b #$98 : STA.w SpriteVelocityZ, X
    LDA.b #$07 : STA.w SpriteGFXControl, X
    INC.w SpriteAncillaInteract, X
    %JSRLongCall_Bank1D(MoveSpriteZ_bank1D, +) : +
    LDA.w SpriteZCoord, X : BMI .exit
        LDA.b #$0C : JSL Sound_SetSfx2PanLong
        LDA.b #$20 : STA.w SpriteTimerD, X
#Ganon_Phase5_Reset:
        LDA.b #$20 : STA.w SpriteTimer, X
        LDA.b #$17 : STA.w SpriteActivity, X
        LDA.w SpriteOAMProperties, X : AND.b #$7F : STA.w SpriteOAMProperties, X
.exit
    RTL

Ganon_Phase5_Stunned:
    LDA.w SpriteOAMProperties, X : ORA.b #$80 : STA.w SpriteOAMProperties, X
    LDA.b #$02 : STA.w SpriteTileDeath, X
    LDA.b #$01 : STA.w SpriteDirectionTable, X
    %JSRLongCall_Bank1D(MoveSpriteXYZ_bank1D, +) : +
    LDA.w SpriteVelocityZ, X : ORA.w SpriteVelocityX, X : ORA.w SpriteVelocityY, X : BEQ .skip_throw
        LDA.b #$02 : STA.w SpriteTimer, X
        JSL Sprite_CheckTileCollisionLong
        LDA.w $0FA5 : CMP.b #$20 : BNE +
            STZ.w SpriteTileCollision, X
        +
        JSL ThrownSprite_TileAndSpriteInteraction_long  
.skip_throw
    LDA.w SpriteTimer, X : BNE .exit
        LDA.b #$01 : STA.w SpriteOAMProp, X
        LDA.b #$07 : STA.w SpriteGFXControl, X
        BRA Ganon_Phase5_Reset
.exit
    JSL Sprite_CheckIfLifted_permissive_long
    LDA.b #$05 : STA.w SpriteOAMProp, X
    RTL

Ganon_MaybeEnableVulnerabilty:
    LDA.w SpriteActivity, X : CMP.b #$1B : BEQ .skip
        LDA.b #$40 : STA.w SpriteTimerB, X ; what we wrote over
.exit
    RTL
.skip
    ; change Ganon GFX based on Link direction if carried
    LDA.w SpriteAITable, X : CMP.b #$0A : BNE .exit
    PHB : PHK : PLB
        LDA.b LinkDirection : LSR : TAY
        LDA.w .stun_gfx, Y : STA.w SpriteGFXControl, X
    PLB
    RTL
.stun_gfx
db $0A, $05, $0F, $05
