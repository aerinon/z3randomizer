;================================================================================
; Boots State Modifier
;--------------------------------------------------------------------------------
ModifyBoots:
    PHA
        LDA.l BootsModifier : CMP.b #$01 : BNE +
            PLA : AND.l AbilityFlags : ORA.b #$04 : RTL ; yes boots
        + : CMP.b #$02 : BNE +
            PLA : AND.l AbilityFlags : AND.b #$FB : RTL ; no boots
        + : LDA.l FakeBoots : CMP.b #$01 : BNE +
            LDA.b LinkSlipping : BEQ ++ : LDA.b PitTileActField : BNE + ; hover check
                ++ : PLA : AND.l AbilityFlags : ORA.b #$04 : RTL ; yes boots, not hovering
        +
    PLA
    AND.l AbilityFlags ; regular boots
RTL
;--------------------------------------------------------------------------------
AddBonkTremors:
    PHA
        LDA.b LinkIncapacitatedTimer : BNE + ; Check for incapacitated Link
            JSL IncrementBonkCounter
        +
        LDA.l BootsModifier : CMP.b #$01 : BEQ +
        LDA.l BootsEquipment : BNE + ; Check for Boots
            PLA : RTL
        +
    PLA
    JSL AddDashTremor : JSL Player_ApplyRumbleToSprites ; things we wrote over
RTL
;--------------------------------------------------------------------------------
ValidDashCheck:
    PHP
        SEP #$20
        LDA.l BootsModifier : CMP.b #$01 : BEQ +
            LDA.l BootsEquipment : BEQ .exit
        + LDA.w LinkDashing
.exit
    BEQ +
        PLP : REP #$02
        RTL
    +
    PLP : SEP #$02
    RTL
;--------------------------------------------------------------------------------
BonkRockPile:
    LDA.l BootsModifier : CMP.b #$01 : BEQ +
    LDA.l BootsEquipment : BNE + ; Check for Boots
        LDA.b #$00 : RTL
    +
    LDA.w TileActBE : AND.b #$70 ; things we wrote over
RTL
;--------------------------------------------------------------------------------
GravestoneHook:
    JSL ValidDashCheck : BEQ .done ; things we wrote over
        JML moveGravestone
    .done
    JML GravestoneHook_continue
;--------------------------------------------------------------------------------
JumpDownLedge:
    LDA.l BootsModifier : CMP.b #$01 : BEQ +
    LDA.l BootsEquipment : BNE + ; Check for Boots
        ; Disarm Waterwalk
        LDA.b LinkSlipping : CMP.b #$01 : BNE +
            STZ.b LinkSlipping
    +
    LDA.b IndoorsFlag : BNE .done : LDA.b #$02 : STA.b LinkLayer ; things we wrote over
    .done
RTL
;--------------------------------------------------------------------------------
BonkRecoil:
    LDA.l BootsModifier : CMP.b #$01 : BEQ +
    LDA.l BootsEquipment : BNE + ; Check for Boots
        LDA.b #$16 : STA.b LinkRecoilZ : RTL
    +
    LDA.b #$24 : STA.b LinkRecoilZ ; things we wrote over
RTL
;--------------------------------------------------------------------------------
BonkRecoilStop:
    LDA.l BootsModifier : CMP.b #$01 : BEQ .return
    LDA.l BootsEquipment : BNE .return
    LDA.b LinkState : CMP.b #$02 : BNE .return
    LDA.b LinkPosZ : BMI .return : CMP.b #$09 : BCC .return
    LDA.b FrameCounter : AND.b #$01 : BNE .return
        REP #$20
            LDA.w $0114 : CMP.w #$0020 : SEP #$20 : BNE .return
                LDA.b LinkRecoilY : BEQ ++ : BMI +
                    DEC : BRA ++
                + INC
                ++ STA.b LinkRecoilY
                LDA.b LinkRecoilX : BEQ ++ : BMI +
                    DEC : BRA ++
                + INC
                ++ STA.b LinkRecoilX
    .return
    JML LinkHop_FindArbitraryLandingSpot
