!LoadedPedestalNumber = LimitedRunStore
!PedestalCollectedFlags = LimitedRunStore+1

; --------------------------------------------------------------------------------

Limited_OverworldPedestalTileChanges:
    LDA.b OverworldIndex : CMP.w #$0080 : BEQ + : RTL : +
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

