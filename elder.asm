NewElderCode:
{
LDA.b OverworldIndex : AND.b #$3F : CMP.b #$1B : BEQ .newCodeContinue
;Restore Jump we can keep the RTL so JML
JML Sprite_16_Elder
.newCodeContinue
PHB : PHK : PLB
LDA.b #$07 : STA.w SpriteOAMProp, X ; Palette 
JSR Elder_Draw
JSL Sprite_PlayerCantPassThrough
JSR Elder_Code

PLB
RTL
}

    Elder_Draw:
    {
        LDA.b #$02 : STA.b Scrap06 : STZ.b Scrap07 ;Number of Tiles
        
        LDA.w SpriteGFXControl, X : ASL #04
        
        ADC.b #.animation_states : STA.b Scrap08
        LDA.b #.animation_states>>8 : ADC.b #$00 : STA.b Scrap09
        
        JSL Sprite_DrawMultiple_player_deferred
        JSL Sprite_DrawShadowLong

        RTS

        .animation_states
        ;Frame0
        dw 0, -9 : db $C6, $00, $00, $02
        dw 0,  0 : db $C8, $00, $00, $02
        ;Frame1
        dw 0, -8 : db $C6, $00, $00, $02
        dw 0,  0 : db $CA, $40, $00, $02
    }

    Elder_Code:
    {
        TXY : LDX.b #$06
            REP #$30
            LDA.l GoalConditionTable, X
            TAX : LDA.l $B00000, X
            SEP #$30
        TYX
        CMP.b #$00 : BEQ .despawn ; no goal, despawn
        LDA.l TurnInGoalItems : BNE +
            .despawn
            STZ.w SpriteAITable, X ; despawn self
            RTS
        +
        LDA.b GameSubMode
        BNE .done
        LDA.b #$96
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing_PreserveMessage : BCC .dont_show
            LDA.b #$03 : JSL CheckConditionPass : BCC +
                JSL ActivateTriforceCutscene
            +
        .dont_show
        
        .done
        LDA.b FrameCounter : LSR #5 : AND.b #$01 : STA.w SpriteGFXControl, X
        RTS
    }

;--------------------------------------------------------------------------------
; Triforce (Pedestal) Cutscene
;--------------------------------------------------------------------------------
ActivateTriforceCutscene:
    ; despawn other sprites
    LDY.b #$0F
    - LDA.w SpriteTypeTable,Y : CMP.b #$16 : BNE +
        CPY.b #$00 : BEQ .next
        ; move Murahdahla to slot 0 for draw priority reasons
        LDA.w SpriteTypeTable,Y : STA.w SpriteTypeTable
        LDA.w SpritePosYLow,Y : STA.w SpritePosYLow
        LDA.w SpritePosXLow,Y : STA.w SpritePosXLow
        LDA.w SpritePosYHigh,Y : STA.w SpritePosYHigh
        LDA.w SpritePosXHigh,Y : STA.w SpritePosXHigh
        LDA.w SpriteVelocityY,Y : STA.w SpriteVelocityY
        LDA.w SpriteOAMProp,Y : STA.w SpriteOAMProp
        LDA.w SpriteOAMProperties,Y : STA.w SpriteOAMProperties
        LDA.w SpriteControl,Y : STA.w SpriteControl
        LDA.w SpriteAITable,Y : STA.w SpriteAITable
        LDA.b #$02 : STA.w SpriteLayer
    + LDA.b #$00 : STA.w SpriteAITable,Y
    .next
    DEY : BPL -
    
    LDA.b #$62 ; MasterSword Sprite
    JSL Sprite_SpawnDynamically

    ; set up coords
    LDA.b LinkPosX : STA.w SpritePosXLow,Y
    LDA.b LinkPosX+1 : STA.w SpritePosXHigh,Y
    LDA.b LinkPosY : CLC : ADC.b #$08 : STA.w SpritePosYLow,Y
    LDA.b LinkPosY+1 : ADC.b #$00 : STA.w SpritePosYHigh,Y

    LDA.b #$01 : STA.w SpriteMovement,Y ; our indicator this is a special cutscene sprite
    INC : STA.b LinkDirection ; makes Link face downward

    ; reset modules
    LDA.b IndoorsFlag : BEQ +
        LDA.b #$07
        BRA ++
    + LDA.b #$09
    ++ STA.b GameMode
    STZ.b GameSubMode : STZ.b SubSubModule
RTL

pushpc
    org $858928
    MasterSword_InPedestal_DoCutscene:
    org $8589B1
    MasterSword_ConditionalHandleReceipt_DoReceipt:

    org $8588DF
    JSL MasterSword_CheckIfPulled : PLX : NOP #2
    db $90 ; BCC instead of BEQ
    org $85890E
    JSL MasterSword_ConditionalActivateCutscene
    org $85895F
    JSL MasterSword_ConditionalGrabPose : NOP
    org $858994
    JSL MasterSword_ConditionalGrabPose : NOP
    org $858D1C
    JML MasterSword_SpawnPendantProp_ChangePalette
    MasterSword_SpawnPendantProp_ChangePalette_return:
    org $8589A3
    JSL MasterSword_ConditionalHandleReceipt : NOP #2
pullpc

MasterSword_CheckIfPulled:
    CPX.b #$80 : BEQ +
        - CLC : RTL ; not on pedestal screen, continue with cutscene
    if !FEATURE_LIMITED_RUN == 2604
        + JSL MasterSword_LimitedCheckIfPulled : BEQ + : RTL
    endif
    + LDA.l OverworldEventDataWRAM,X : AND.b #$40 ; what we wrote over
    BEQ - : SEC : RTL

MasterSword_ConditionalActivateCutscene:
    LDA.w SpriteMovement,X : BNE .specialCutscene
        PHX
            LDA.w SprRedrawFlag, X : BNE .doNormalPed
            INC.w SprRedrawFlag, X
            if !FEATURE_LIMITED_RUN == 2604
                JSL MasterSword_LimitedActivateCutscene : BCS .doNormalPed
            endif
            REP #$30
            LDA.l PedPullGfx : BEQ .doNormalPed
            LDX.w ItemStackPtr : STA.l ItemGFXStack,X
            LDA.w #$BCE0>>1 : STA.l ItemTargetStack,X
            TXA : INC #2 : STA.w ItemStackPtr
    .doNormalPed
            SEP #$30
        PLX
        JML Sprite_CheckDamageToPlayerSameLayerLong ; what we wrote over
    .specialCutscene
    LDA.b #$02 : STA.w ItemReceiptPose ; Link's 2-hands-up pose
    STA.b LinkLayer ; draw Link on top
    ; draw Triforce piece in VRAM
    LDA.w SprRedrawFlag, X : BNE .skipTransfer
    INC.w SprRedrawFlag, X
    PHX
        REP #$30
        LDA.l MurahdahlaGfx : BNE .submitRequest
        LDX.w #$006A<<1 : LDA.l StandingItemGraphicsOffsets,X
    .submitRequest
        LDX.w ItemStackPtr : STA.l ItemGFXStack,X
        LDA.w #$9CE0>>1 : STA.l ItemTargetStack,X
        TXA : INC #2 : STA.w ItemStackPtr
	    SEP #$30
    PLX
    .skipTransfer
    PLA : PLA : PLA : JML MasterSword_InPedestal_DoCutscene ; do cutscene

MasterSword_ConditionalGrabPose:
    PHA
        LDA.w SpriteMovement,X : BNE .specialCutscene
    PLA
    STA.w $0377 : LDA.b #$01 ; what we wrote over
    RTL
    .specialCutscene
    PLA
    LDA.b #$01
RTL

MasterSword_SpawnPendantProp_ChangePalette:
    STA.w SpriteVelocityY,Y : PLX ; what we wrote over
    LDA.w SpriteMovement,X : BNE .specialCutscene
    if !FEATURE_LIMITED_RUN == 2604
        JSL MasterSword_LimitedCheckIfPulled : BEQ .regularPedestal
            LDA.b #$09 : BRA .setPalette
    endif
    .regularPedestal
        LDA.l PedPullGfx : BNE .customPedGfx
        LDA.l PedPullGfx+1 : BNE .customPedGfx
        BRA .done
    .customPedGfx
        LDA.l PedPullPalette : ASL : INC : BRA .setPalette
    .specialCutscene
    LDA.b #$02 : STA.w SpriteLayer,Y ; change layer
    LDA.l MurahdahlaGfx : BNE .customGfx
    LDA.l MurahdahlaGfx+1 : BNE .customGfx
        LDA.b #$08 : BRA .setPalette
    .customGfx
    LDA.l MurahdahlaPalette : ASL
    .setPalette
    STA.w SpriteOAMProp,Y ; change palette
.done
JML MasterSword_SpawnPendantProp_ChangePalette_return

MasterSword_ConditionalHandleReceipt:
    LDA.w SpriteMovement,X : BNE .specialCutscene
    if !FEATURE_LIMITED_RUN == 2604
        JSL MasterSword_LimitedHandleReceipt : BNE .return
    endif
    .regularPedestal
        LDX.b OverworldIndex : LDA.l OverworldEventDataWRAM,X ; what we wrote over
        RTL
    .specialCutscene
        LDA.b 6,S : TAX
        LDY.b #$6A
    .return
        PLA : PLA : PEA.w MasterSword_ConditionalHandleReceipt_DoReceipt-1
    RTL

pushpc
    org $858AB6
    MasterSword_SpawnLightWell:
    org $858AD0
    MasterSword_SpawnLightFountain:
    org $858B62
    MasterSword_SpawnLightBeam:

    org $858941
    JSL MasterSword_ConditionalSpawnLightWell : NOP #2
    MasterSword_SpawnLightWell_return:
    org $858952
    JSL MasterSword_ConditionalSpawnLightFountain : NOP #2
    MasterSword_SpawnLightFountain_return:
    org $858B64
    JSL MasterSword_ConditionalSpawnLightBeam : NOP #2
pullpc

MasterSword_ConditionalSpawnLightWell:
    INC.w SpriteActivity,X ; part of what we wrote over
    LDA.w SpriteMovement,X : BNE .specialCutscene
        PLA : PLA : PLA : PEA.w MasterSword_SpawnLightWell_return-1
        JML MasterSword_SpawnLightWell ; part of what we wrote over
    .specialCutscene
    RTL

MasterSword_ConditionalSpawnLightFountain:
    INC.w SpriteActivity,X ; part of what we wrote over
    LDA.w SpriteMovement,X : BNE .specialCutscene
        PLA : PLA : PLA : PEA.w MasterSword_SpawnLightFountain_return-1
        JML MasterSword_SpawnLightFountain ; part of what we wrote over
    .specialCutscene
    RTL

MasterSword_ConditionalSpawnLightBeam:
    LDA.w SpriteMovement,X : BNE .specialCutscene
        LDA.b #$62 : JSL Sprite_SpawnDynamically ; what we wrote over
        RTL
    .specialCutscene
    LDY.b #$FF
    RTL
