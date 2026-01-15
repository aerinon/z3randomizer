; This file contains hooks for various limited run features and are meant
;   to be generic-use for potential future limited run events
; If a new hook seems to be niche and specific to one limited run event,
;   it is recommended to place it in the specific limited run event file
;   to help reduce clutter in this global hook file
; If there are new features/fixes unrelated to limited run events that require
;   changes to code here, it is recommended to move these hooks to the outside
;   and instead redirect the relevant portions to the limited run code here

; Limited run events will vary how they use data:
;   Reserved ROM space: LimitedRunData
;   Reserved "SRAM" space: LimitedRunStore

; --------------------------------------------------------------------------------

if !FEATURE_LIMITED_RUN

    org $80E239
    JSL InitializeTilesets_Override

    org $828068
    JSL LoadDefaultGraphics_Custom

    org $82EA33
    JSL FluteMenu_InterruptFluteDestination

    org $84E804
    JSL HandleStakeFieldExtra : NOP

    org $86E7A7
    JSL Sprite_ModifyBehaviorOverTile

    org $9EDFA9
    JSL PlayerBee_FindSecrets
    db $B0, $78 ; BCS to skip over copying sprite coords

    ; --------------------------------------------------------------------------------

    org $AD8000
    LoadDefaultGraphics_Custom:
        JSL LoadDefaultGraphics ; what we wrote over
    .exit
        RTL

    PlayerBee_FindSecrets:
        TXA : ASL : ASL : AND #$0F : TAY ; what we wrote over
    .vanilla
        CLC
        RTL

    HandleStakeFieldExtra:
    .exit
    RTL

    FluteMenu_InterruptFluteDestination:
        if !FEATURE_LIMITED_RUN == 2604
            JSL Limited_FluteMenu_PedestalDestination
        endif
    .exit
        JML Sprite_ResetAll ; what we wrote over

    InitializeTilesets_Override:
    .exit
        LDY.b Scrap09 : LDA.b #$7E ; what we wrote over
        RTL

    Sprite_ModifyBehaviorOverTile:
        TAY ; part of what we wrote over
    .exit
        LDA.w $0CAA,X ; part of what we wrote over
        RTL

endif

; this might be better implemented as a general message framework elsewhere
ShowAwaitingMessage:
.exit
    RTL

SpritePrep_CustomSprite:
.exit
    RTL

Sprite_03_CustomSprite:
.exit
    RTL

; load specific limited run events here
if !FEATURE_LIMITED_RUN == 2604
    incsrc limited_2604.asm
endif
