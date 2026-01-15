!LoadedPedestalNumber = LimitedRunStore
!PedestalCollectedFlags = LimitedRunStore+1
!FortuneRead = LimitedRunStore+3
!ScreenSequenceIndex = LimitedRunStore+4 ; 16-bit, screen temporary

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

