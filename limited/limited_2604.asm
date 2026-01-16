!LoadedPedestalNumber = LimitedRunStore
!PedestalCollectedFlags = LimitedRunStore+1
!KickedOutMessage = LimitedRunStore+2
!FortuneRead = LimitedRunStore+3
!ScreenSequenceIndex = LimitedRunStore+4 ; 16-bit, screen temporary
!BananaFlags = LimitedRunStore+4 ; 16-bit, screen temporary

!BananaXPos = LimitedRunData
!BananaYPos = LimitedRunData+10

; --------------------------------------------------------------------------------

Limited_LoadEggGoalHUDGfx:
    LDA.b #.gfx>>16 : STA.b Scrap02
    REP #$30
    LDA.w #.gfx : STA.b Scrap00
    LDA.w #$7070 : STA.w VMADDR ; VRAM $E0E0
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
        LDA.l Bee_BounceBoundaries,X : AND.w #$00FF
        CLC : ADC.b Scrap00
        STA.b Scrap04
        LDX.b Scrap02
        LDA.l .secret_ypos,X
        STA.b Scrap02
        PLX
        LDA.l Bee_BounceBoundaries,X : AND.w #$00FF
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
        LDX.w ItemStackPtr : STA.l ItemGFXStack,X
        LDA.w #$BCE0>>1 : STA.l ItemTargetStack,X
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
    LDA.l OverworldEventDataWRAM,X ; what we wrote over
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
    LDA.b #$98 : LDY.b #$01 : JSL Sprite_ShowMessageUnconditional
    LDA.b #$00 : STA.l !KickedOutMessage
.exit
    RTL

Limited_ModifyFakeSwordOverPit:
    LDA.w OWTransitionFlag : BEQ .exit
    CPY.b #$20 : BNE .exit ; over pit
    LDA.w SpriteTypeTable,X : CMP.b #$E8 : BNE .exit
        LDA.w SpriteVelocityY,X : JSL DivideByTwoPreserveSign : STA.w SpriteVelocityY,X
        LDA.w SpriteVelocityX,X : JSL DivideByTwoPreserveSign : STA.w SpriteVelocityX,X
        LDA.w SpriteVelocityZ,X : SEC : SBC.b #$02 : STA.w SpriteVelocityZ,X
.exit
    RTL

ThrownSprite_FakeMasterSwordDeath:
    LDA.b #$06 : STA.w SpriteAITable,X ; what we wrote over
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
    INC.w SpriteActivity,X : LDA.b #$20 : STA.w SpriteTimer,X ; what we wrote over
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
        LDX.w ItemStackPtr : STA.l ItemGFXStack,X
        LDA.w #$B840>>1 : STA.l ItemTargetStack,X
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
            LDA.w #$0912 : LDX.w #$0B74 : JSL Overworld_DrawPersistentMap16
            LDA.w #$0914 : LDX.w #$0BF4 : JSL Overworld_DrawPersistentMap16
            LDA.w #$0913 : LDX.w #$0B76 : JSL Overworld_DrawPersistentMap16
            LDA.w #$0915 : LDX.w #$0BF6 : JSL Overworld_DrawPersistentMap16
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
