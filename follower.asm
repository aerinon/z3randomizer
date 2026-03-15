pushpc
; follower hooks
org $81EBB6
JSL MaybeSetZeldaCheckpoint
org $899FA1
db $FF, $FF, $FF ; disable timed follower messages
org $89A647
JSL MaybeSkipFollowerTrigger : NOP
org $89F544
JSL MaybeDeleteFollowersOnDeath

org $85EBCF
JSL SpritePrep_ZeldaFollower : NOP #2
org $85EC9E
JSL SpriteDraw_ZeldaMaiden
org $85ECD9
JSL Zelda_WaitingInCell
org $85ED46
JSL Zelda_BecomeFollower : NOP #2

org $9EE902
JSL SpritePrep_OldManFollower : NOP #2 : db $F0 ; BEQ
org $9DFF18
JSL SpriteDraw_OldManFollower
org $9EE9BC
JSL OldMan_WaitForCollision
org $9EE9CC
JSL OldMan_BecomeFollower : NOP #2

org $86899C
JSL SpritePrep_BlindMaiden : NOP #2
org $8689A7
JSL BlindZeldaDespawnFix : NOP #2
org $9EE8B0
JSL SpriteDraw_ZeldaMaiden
org $9EE8CD
JSL Follower_CheckCollision
org $9EE8D7
JSL BlindMaiden_BecomeFollower : NOP

org $868A7E
JSL SpritePrep_SmithyFrog : BRA + : NOP #8 : +
org $86B2AA
JSL Follower_CheckMessageCollision
org $86B2B4
JSL Frog_BecomeFollower : NOP #2
org $86B341
JSL SpriteDraw_FrogFollower

org $868A53
JSL SpritePrep_PurpleChest : NOP #2
org $9EE0D7
JSL SpriteDraw_PurpleChest
org $9EE0E7
JSL Follower_CheckMessageCollision
org $9EE0ED
JSL PurpleChest_FollowCheck
org $9EE0F7
JSL PurpleChest_BecomeFollower : NOP

org $868A0A
JSL SpritePrep_SuperBomb
org $868A4A
SuperBomb_BecomeFollower_exit:
org $9EE16E
BRA + : NOP #6 : + ; fix bomb shop dialog for dwarfless big bomb
org $9EE1E8
JSL SuperBomb_FollowCheck
org $9EE1F1
JSL SuperBomb_BecomeFollower : NOP #2
org $9EE2C0
JSL SpriteDraw_SuperBomb

org $868D51
JSL SpritePrep_Kiki : NOP #2
org $9EE3E6
JSL Kiki_OfferToFollow
org $9EE495
JSL Kiki_FollowCheck : BRA + : NOP #12 : +
org $9EE4AF
JSL Kiki_BecomeFollower : NOP #2
org $9EE4F7
JSL Kiki_FixTeleportOnExit
org $89A1B2
JSL Kiki_DontScareTheMonke : NOP #3
org $89A69D
JSL Kiki_ActivateEntranceOpening

org $868D63
JSL SpritePrep_Locksmith : NOP #2 : db $90 ; BCC
org $868D7E
db $80 ; BRA
org $86BCD9
JML Locksmith_Chillin_PostMessage
org $86BD09
JSL Locksmith_BecomeFollower : NOP #2
org $86BD7A ; allow follower pickup after purple chest item
LDA.b #$00 : STA.w SpriteActivity, X
JSL Locksmith_RespondToAnswer_PostItem
org $86BDB4
JSL SpriteDraw_LocksmithFollower
pullpc

MaybeSkipFollowerTrigger:
    LDA.b GameMode : AND.w #$00FF : CMP.w #$0010 : BNE .normal
.no_trigger
    INC : RTL
.normal
    LDA.w $02F2 : AND.b Scrap06 ; what we wrote over
    RTL

MaybeDeleteFollowersOnDeath:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        ; s+q = favor keeping current follower
        ; death = favor replacing with unfulfilled starting followers
        ; during escape = always favor keeping zelda
        LDA.b GameMode : CMP.b #$17 : BEQ .keep
        LDA.w DungeonID : NOP #2 : BPL .keep
        LDA.l InitFollowerIndicator : BEQ .keep
        JSL DetermineFollowerSpawn_check_resolved : BCS .keep
        LDA.l ProgressIndicator : CMP.b #$02 : BCS .delete
        LDA.l FollowerIndicator : CMP.b #$01 : BEQ .keep
.delete
    PLA : PLA : PEA.w $89F558-1
    RTL
.keep
    PLA : PLA : PEA.w $89F55E-1
    RTL
.vanilla
    LDA.l FollowerIndicator ; what we wrote over
    RTL

StartingFollower:
    LDA.l InitFollowerIndicator : BEQ .return
    PHA
    REP #$20
        ; possible spawn points
        LDA.b RoomIndex : CMP.w #$0104 : BEQ + ; links house
        CMP.w #$0012 : BEQ + ; sanc
        CMP.w #$00E4 : BEQ + ; old man
        CMP.w #$0112 : BEQ + ; dark sanc
        CMP.w #$011C : BEQ + ; bomb shop
            SEP #$20 : PLA : RTL
    +
    SEP #$20
    LDA.l FollowerIndicator : BEQ +
        LDA.l FollowerDropped : CMP.b #$80 : PLA : BCC .return : PHA
    + LDA.l ProgressIndicator : CMP.b #$02 : PLA : BCC .escape_check
        PHA
            JSL DetermineFollowerSpawn_check_resolved
        PLA
        BCC .issue_follower
        BRA .return
.escape_check
    CMP.b #$01 : BNE .return
    PHA : LDA.l ProgressFlags : AND.b #$04 : CMP.b #$04 : PLA : BCS .return
.issue_follower
    STA.l FollowerIndicator
    LDA.b #$00 : STA.l FollowerDropped
.return
    RTL

MaybeSetZeldaCheckpoint:
    AND.w #$7FFF : TAX ; what we wrote over
    SEP #$20
        LDA.l ProgressFlags : AND.b #$04 : BNE .return ; zelda rescued
        LDA.l StartingEntrance : CMP.b #$02 : BEQ .return ; cell checkpoint set
            CMP.b #$04 : BEQ .return ; throne room checkpoint set
        LDA.l FollowerIndicator : CMP.b #$01 : BNE .return ; zelda following
        LDA.b RoomIndex : CMP.b #$80 : BNE + ;zelda cell
            LDA.l Follower_Zelda : CMP.b #$01 : BNE .return
            BRA .set_checkpoint
        + CMP.b #$45 : BNE .return ; maiden cell
            CPX.w #$0964 : BNE .return ; top big lock
            LDA.l Follower_Maiden : CMP.b #$01 : BNE .return
.set_checkpoint
    LDA.b #$02 : STA.l StartingEntrance
    PHX
        SEP #$10
        JSL SaveDeathCount
        JSL Dungeon_SaveRoomQuadrantData
        REP #$10
    PLX
.return
    REP #$30
    RTL

FollowerGfxRedraw:
    PHP : SEP #$30
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .return
        PHY
            LDY.b #$0F
            .next
            LDA.w SpriteAITable,Y : BEQ ++
                LDA.w SpriteTypeTable,Y : CMP.b #$76 : BEQ + ; zelda
                CMP.b #$AD : BEQ + ; old man
                CMP.b #$B7 : BEQ + ; maiden
                CMP.b #$1A : BEQ + ; frog
                CMP.b #$39 : BEQ + ; locksmith
                CMP.b #$B6 : BEQ + ; kiki
                CMP.b #$B4 : BEQ + ; purple chest
                CMP.b #$B5 : BNE ++ ; big bomb
                    LDA.w SpriteJumpIndex,Y : CMP.b #$02 : BEQ +
                BRA ++
                    + LDA.b #$01 : STA.w SprRedrawFlag,Y
            ++ DEY : BPL .next
        PLY
.return
    PLP
    RTL

; A = 2 byte VRAM position in OAM2 for head/body
; Scrap06/07/08 = address to OAM group
; Returns with carry flag set if draw occurred
TransferAndDrawFollowerGfx:
    PHA
    LDA.w SpriteTimerE, X : AND.w #$0008 : BNE .skip_draw ; skip drawing every other frame
        LDA.b 1,S
        JSR TransferFollowerSpriteGfx ; returns with SEP #$20
        LDA.w SpriteTypeTable, X : CMP.b #$39 : BNE +
            ; locksmith location flicker if quest completed but purple chest remains
            LDA.w SpriteAux, X : BNE .continue
            JSL DetermineFollowerSpawn : BCS .flicker
        + BRA .continue
        .flicker
        LDA.w SpriteTimerE, X : NOP #2 : BNE .continue
            LDA.b #$0C : STA.w SpriteTimerE, X
        .continue
        PLA : XBA : PLA : XBA
        JSL SpriteDraw_Follower
        SEC
        RTL
.skip_draw
    PLA
    SEP #$20
    CLC
    RTL

; A = 2 byte VRAM position in OAM2 for head/body
TransferFollowerSpriteGfx_skip_transfer:
    PLA : PLA
    RTS
TransferFollowerSpriteGfx:
    PHA : SEP #$20
    LDA.w SprRedrawFlag, X : BEQ .skip_transfer
.redraw
    STZ.w SprRedrawFlag, X
    JSL DetermineFollower
    CMP.b #$01 : BNE +
        PLA : XBA : LDA.b #$83 ; zelda body
        JSR QueueFollowerSpriteGfx
        PLA : XBA : LDA.b #$82 ; zelda head
        JMP QueueFollowerSpriteGfx
    + CMP.b #$04 : BNE +
        PLA : XBA : LDA.b #$84 ; old man body
        JSR QueueFollowerSpriteGfx
        PLA : XBA : LDA.b #$85 ; old man head
        JMP QueueFollowerSpriteGfx
    + CMP.b #$06 : BNE +
        PLA : XBA : LDA.b #$81 ; maiden body
        JSR QueueFollowerSpriteGfx
        PLA : XBA : LDA.b #$80 ; maiden head
        JMP QueueFollowerSpriteGfx
    + CMP.b #$07 : BNE +
        PLA : XBA : PLA : LDA.b #$11 ; frog
        JMP QueueFollowerSpriteGfx
    + CMP.b #$08 : BNE +
        PLA : XBA : PLA : LDA.b #$16 ; smith
        JMP QueueFollowerSpriteGfx
    + CMP.b #$09 : BNE +
        PLA : XBA : LDA.b #$87 ; locksmith body
        JSR QueueFollowerSpriteGfx
        PLA : XBA : LDA.b #$86 ; locksmith head
        JMP QueueFollowerSpriteGfx
    + CMP.b #$0A : BNE +
        PLA : XBA : LDA.b #$13 ; kiki body
        JSR QueueFollowerSpriteGfx
        PLA : XBA : LDA.b #$12 ; kiki head
        JMP QueueFollowerSpriteGfx
    + CMP.b #$0C : BNE +
        PLA : XBA : PLA : LDA.b #$14 ; purple chest
        JMP QueueFollowerSpriteGfx
    + PLA : XBA : PLA : LDA.b #$15 ; super bomb
    JMP QueueFollowerSpriteGfx

; A = 2 bytes, dest/src
QueueFollowerSpriteGfx:
    PHX : REP #$20
        PHA
        AND.w #$00FF : CMP.w #$00FF : BEQ +
            ASL #6 : EOR.w #$8000 : BRA .write_src
        + LDA.w #$0020 ; blank tile
        .write_src
        LDX.w ItemStackPtr : STA.l ItemGFXStack,X
        PLA : XBA
        AND.w #$00FF : ASL #4 : EOR.w #$5000
        STA.l ItemTargetStack,X
        TXA : INC #2 : STA.w ItemStackPtr
    SEP #$20 : PLX
    RTS

; A = 2 byte VRAM position in OAM2 for head/body
; Scrap06/07/08 = address to OAM group
; Scrap09/0A = address to palette data
SpriteDraw_Follower:
    PHB : LDY.b #$7E : PHY : PLB
        REP #$20
        PHA
            LDY.b #$0E
            - LDA.b [Scrap06], Y : STA.w SpriteDynamicOAM, Y
            DEY #2 : BPL -
            LDA.b Scrap09 : STA.b Scrap06
        PLA
        SEP #$20
        STA.w SpriteDynamicOAM+$0C : XBA : STA.w SpriteDynamicOAM+$04
        JSL DetermineFollower : PHA
            PHX
                TAX : DEX
                LDA.b Scrap06 : ORA.b Scrap07 : BEQ +
                    TXY
                    LDA.b [Scrap06], Y
                    BRA .set_palette
                +
                LDA.l .palette_data, X
                .set_palette
                STA.w SpriteDynamicOAM+$05 : STA.w SpriteDynamicOAM+$0D
            PLX
            REP #$20
                LDA.w #$0002 : STA.b Scrap06
                LDA.w #SpriteDynamicOAM : STA.b Scrap08
            SEP #$20
        PLA : CMP.b #$07 : BCC + : CMP.b #$09 : BEQ + : CMP.b #$0A : BEQ +
            ; only draw body
            PHA
                LDA.b #$01 : STA.b Scrap06
                LDA.b #SpriteDynamicOAM+8 : STA.b Scrap08
            PLA
        +
        ; follower specific adjustments
        CMP.b #$04 : BNE +
            LDA.w SpriteDynamicOAM+$0A : SEC : SBC.b #8 : STA.w SpriteDynamicOAM+$02 ; old man coords
        +
        CMP.b #$0A : BNE +
            LDA.w SpriteDynamicOAM+$0A : SEC : SBC.b #6 : STA.w SpriteDynamicOAM+$02 ; kiki coords
            LDA.w SpriteTypeTable, X : CMP.b #$1A : BEQ ++ : CMP.b #$B4 : BCS ++ : BRA .draw
                ++ LDA.w SpriteDynamicOAM+$05 : ORA.b #$40
                STA.w SpriteDynamicOAM+$05 : STA.w SpriteDynamicOAM+$0D ; kiki horiz flip
        +
        .draw
        JSL Sprite_DrawMultiple_player_deferred
    PLB
    RTL
.palette_data
;   01             04        06   07   08   09   0A        0C   0D
db $00, $00, $00, $00, $00, $06, $00, $00, $06, $00, $00, $00, $00


DetermineFollower:
    LDA.w SpriteAux, X : BEQ .skip_stored : RTL ; stored follower
.skip_stored
    + LDA.w SpriteTypeTable, X : CMP.b #$1A : BNE +
        LDA.l Follower_Frog : BRA .finalize
    + CMP.b #$39 : BNE +
        LDA.l Follower_Locksmith : BRA .finalize
    + CMP.b #$AD : BNE +
        LDA.l Follower_OldMan : BRA .finalize
    + CMP.b #$B6 : BNE +
        LDA.l Follower_Kiki : BRA .finalize
    + CMP.b #$B7 : BNE +
        LDA.l Follower_Maiden : BRA .finalize
    + CMP.b #$76 : BNE +
        LDA.l Follower_Zelda : BRA .finalize
    + CMP.b #$B4 : BNE +
        LDA.l Follower_PurpleChest : BRA .finalize
    + LDA.l Follower_SuperBomb
.finalize
    PHA
        CMP.b #$07 : BNE +
        LDA.l CurrentWorld : BNE +
            PLA : LDA.b #$08 : RTL
        +
    PLA
    RTL

SetAndLoadFollower:
    LDA.l FollowerIndicator
.skip_current
    PHA
        LDA.b #$00 : STA.l FollowerDropped
        JSL DetermineFollower : STA.l FollowerIndicator
        CMP.b #$01 : BNE +
            JSL DetermineFollower_skip_stored : CMP.b #$01 : BNE +
                LDA.b #$02 : STA.l StartingEntrance
                JSL SaveDeathCount
                PHX
                    JSL Dungeon_SaveRoomQuadrantData
                PLX
        + CMP.b #$09 : BNE +
            LDA.b #$40 : STA.w $02CD : STZ.w $02CE ; locksmith timed message
        +
        PHX
        JSL Tagalong_LoadGfx
        PLX
    PLA : BNE +
        JSL Follower_Initialize
        JML Sprite_BecomeFollower
    +
    RTL

StoreAndLoadFollower:
    LDA.l FollowerDropped : BNE .no_storage
    LDA.l FollowerIndicator : BEQ .no_storage
        PHA
        JSL SetAndLoadFollower_skip_current
        PLA : STA.w SpriteAux, X
        LDA.b #$13 : JSL Sound_SetSfx3PanLong
        LDA.b #$01 : STA.w SprRedrawFlag, X
        STZ.w SpriteActivity, X
        LDA.b #$90 : STA.w SpriteTimerE, X
        SEC : RTL
.no_storage
    JSL SetAndLoadFollower_skip_current
    CLC : RTL

; return SEC if destination resolved
DetermineFollowerSpawn_locksmith_check:
    ; locksmith location needs to spawn if purple chest reward not acquired
    LDA.l FollowerIndicator : CMP.b #$0C : BEQ .always_spawn
    JSL DetermineFollower_skip_stored : CMP.l FollowerIndicator : BEQ .matched_following
    LDA.l NpcFlagsVanilla : AND.b #$10 : BEQ .always_spawn
    BRA DetermineFollowerSpawn
.always_spawn
    CLC : RTL
.matched_following
    SEC : RTL

DetermineFollowerSpawn_include_stored:
    JSL DetermineFollower
    BRA DetermineFollowerSpawn_byof
DetermineFollowerSpawn:
    JSL DetermineFollower_skip_stored
.byof
    CMP.l FollowerIndicator : BEQ .matched_following
.skip_match_check
    PHA
        ; despawn if pre-requisite not met
        LDA.w SpriteTypeTable, X : CMP.b #$B4 : BNE +
            LDA.l NpcFlagsVanilla : AND.b #$20 : EOR.b #$20 : CMP.b #$20
            BRA .prereq_check
        + CMP.b #$B5 : BNE +
            LDA.l CrystalsField : AND.b #$05 : CMP.b #$05
            LDA.b #$FF : ADC.b #$00 : ROR ; flip carry flag
        .prereq_check
        PLA : BCC .check_resolved
            RTL
        +
    PLA
.check_resolved
    CMP.b #$01 : BNE +
        LDA.l ProgressFlags : AND.b #$04 : CMP.b #$04 : RTL
    + CMP.b #$04 : BNE +
        JML ItemCheck_OldMan
    + CMP.b #$06 : BNE +
        LDA.l RoomDataWRAM[$AC].high : AND.b #$08 : CMP.b #$08 : BCS ++
            LDA.l EnemizerFlags_close_blind_door : CMP.b #$01
        ++
        RTL
    + CMP.b #$09 : BCS + ; if frog or smith
        LDA.l NpcFlagsVanilla : AND.b #$20 : CMP.b #$20 : RTL
    + CMP.b #$0A : BNE +
        LDA.l OverworldEventDataWRAM+$5E : AND.b #$20 : CMP.b #$20 : RTL
    + CMP.b #$0C : BNE +
        LDA.l NpcFlagsVanilla : AND.b #$10 : CMP.b #$10 : RTL
    +
.always_spawn
    CLC : RTL ; big bomb and locksmith have no completion condition in code
.matched_following
    SEC : RTL

Follower_CheckMessageCollision:
    PHA
        LDA.w SpriteTimerE, X : BNE .skip_collision_check
    PLA
    JML Sprite_ShowMessageFromPlayerContact ; what we wrote over
.skip_collision_check
    PLA
    CLC : RTL

Follower_CheckTileCollision:
    LDA.w SpriteTimerE, X : BNE .skip_collision_check
    JML Sprite_CheckTileCollisionLong ; what we wrote over
.skip_collision_check
    RTL

Follower_CheckCollision:
    LDA.w SpriteTimerE, X : BNE .skip_collision_check
    JML Sprite_CheckDamageToPlayerSameLayerLong ; what we wrote over
.skip_collision_check
    CLC : RTL

SpritePrep_ZeldaFollower:
    LDA.b RoomIndex : CMP.b #$12 : BEQ .no_follower_shuffle_sanc
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .no_follower_shuffle
        JSL DetermineFollowerSpawn : BCC + : RTL : +
        LDA.b #$01 : STA.w SprRedrawFlag, X
        PLA : PLA : PEA.w $EC4B-1 ; return to spawn
        RTL
.no_follower_shuffle
    LDA.l FollowerIndicator : CMP.b #$01
    RTL
.no_follower_shuffle_sanc
    LDA.l FollowerIndicator : CMP.b #$02
    RTL

Zelda_WaitingInCell:
    JSL Follower_CheckCollision ; what we wrote over, kinda
    BCC .return
    PHP
        LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE +
            INC.w SpriteActivity, X
            PLP
            PLA : PLA : PEA.w $ECF9-1 : RTL ; skip sprite movement
        +
    PLP
.return
    RTL

Zelda_BecomeFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        PLA : PLA
        JSL StoreAndLoadFollower : BCC +
            PEA.w $ED68-1 : RTL ; jump to avoid sprite despawn
        +
        PEA.w $ED60-1 ; jump to despawn
        RTL
    
.vanilla
    LDA.b #$02 : STA.l StartingEntrance ; what we wrote over
    RTL

SpritePrep_BlindMaiden:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        JSL DetermineFollowerSpawn : BCC +
            LDA.b #$01 : RTL
        +
        LDA.b #$01 : STA.w SprRedrawFlag, X
        INC.w SpriteAncillaInteract, X
        STZ.w FollowerNoDraw
        PLA : PLA : PEA.w $89C8-1 ; return to spawn
        RTL
.vanilla
    LDA.l RoomDataWRAM[$AC].high : AND.b #$08 ; what we wrote over
    RTL

; Prevent followers from causing blind/maiden to despawn:
; Door rando: let zelda despawn the maiden.
BlindZeldaDespawnFix:
    LDA.l FollowerIndicator ; what we wrote over
    CMP.b #06 : BEQ +
        LDA.w SpritePosYLow,X : BEQ +
        LDA.b #$00 : RTL ; don't despawn follower if maiden isn't "present"
    +
    LDA.b #$01 : RTL

SpriteDraw_ZeldaMaiden:
    LDA.b RoomIndex : CMP.b #$12 : BEQ .vanilla
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        LDA.b #.oam_group>>16 : STA.b Scrap08
        LDA.w SpriteTypeTable, X : CMP.b #$76 : BNE +
            REP #$20
            LDA.w #.oam_group : STA.b Scrap06
            LDA.w #0000 : STA.b Scrap09
            LDA.l Follower_Zelda_vram
            BRA .transfer
        +
        REP #$20
        LDA.w #.oam_group : STA.b Scrap06
        LDA.w #.palette_data_maiden : STA.b Scrap09
        LDA.l Follower_Maiden_vram
        .transfer
        JML TransferAndDrawFollowerGfx
.skip_draw
    RTL
.vanilla:
    JML SpriteDraw_Maiden
.oam_group:
dw 1, -7 : db $20, $00, $00, $02
dw 1,  3 : db $22, $00, $00, $02
.palette_data_maiden
;   01             04        06   07   08   09   0A        0C   0D
db $02, $00, $00, $02, $00, $04, $02, $02, $04, $02, $00, $02, $02

BlindMaiden_BecomeFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        PLA : PLA
        JSL StoreAndLoadFollower : BCS .return
            STZ.w SpriteAITable, X
.return
    PEA.w $E8EA-1 ; jump ahead on return
    RTL
.vanilla
    STZ.w SpriteAITable, X : LDA.b #$06 ; what we wrote over
    RTL

SpritePrep_OldManFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .no_follower_shuffle
        PLA : PLA
        JSL DetermineFollowerSpawn : BCC +
            PEA.w $E928-1 ; return to despawn
            RTL
        +
        LDA.b #$01 : STA.w SprRedrawFlag, X
        PEA.w $E927-1 ; return to spawn
        RTL
.no_follower_shuffle
    LDA.l FollowerIndicator : CMP.b #$04
    RTL

SpriteDraw_OldManFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
    LDA.w SpriteJumpIndex, X : CMP.b #$01 : BEQ .vanilla
        LDA.b #.oam_group>>16 : STA.b Scrap08
        REP #$20
        LDA.w #.oam_group : STA.b Scrap06
        LDA.w #0000 : STA.b Scrap09
        PLA : PEA.w $FF45-1 ; skip vanilla draw
        LDA.l Follower_OldMan_vram
        JML TransferAndDrawFollowerGfx
.vanilla
    LDA.b #$02 : STA.b Scrap06 ; what we wrote over
    RTL
.oam_group
dw 0,  0 : db $AC, $00, $00, $02
dw 0,  8 : db $AE, $00, $00, $02

OldMan_WaitForCollision:
    PHA
    LDA.w LinkIFrames : BEQ +
        PLA : CLC
        RTL
    +
    PLA
    JML Follower_CheckMessageCollision

OldMan_BecomeFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BCC .set_follower_and_despawn
        PLA : PLA
        JSL StoreAndLoadFollower : BCC +
            PEA.w $E9DF-1 : RTL ; jump to avoid sprite despawn
        +
        PEA.w $E9DC-1 ; jump to despawn
        RTL
.set_follower_and_despawn
    JSL SetAndLoadFollower
    PLA : PLA : PEA.w $E9D6-1

SpritePrep_SmithyFrog:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .no_follower_shuffle
        JSL DetermineFollowerSpawn : BCC +
            LDA.b #$01 ; return to despawn
            RTL
        +
        LDA.b #$01 : STA.w SprRedrawFlag, X
        DEC ; return to spawn
        RTL
.no_follower_shuffle
    LDA.l FollowerIndicator : BNE + ; what we wrote over
        LDA.l NpcFlagsVanilla : AND.b #$20 ; what we wrote over
    + RTL

SpriteDraw_FrogFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        LDA.b #.oam_group>>16 : STA.b Scrap08
        REP #$20
        LDA.w #.oam_group : STA.b Scrap06
        LDA.w #0000 : STA.b Scrap09
        PLA : PEA.w $DCD6-1
        LDA.l Follower_Frog_vram
        JML TransferAndDrawFollowerGfx
.vanilla
    LDA.b #$01 : STA.b Scrap06 ; what we wrote over
    RTL
.oam_group:
dw 1, -8 : db $FF, $00, $00, $02
dw 1,  0 : db $C8, $00, $00, $02

Frog_BecomeFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BCC .set_follower_and_despawn
        PLA : PLA
        JSL StoreAndLoadFollower : BCC +
            PEA.w $B2C7-1 : RTL ; jump to avoid sprite despawn
        +
        PEA.w $B2C4-1 ; jump to despawn
        RTL
.set_follower_and_despawn
    JSL SetAndLoadFollower
    PLA : PLA : PEA.w $B2C4-1 ; jump to despawn
    RTL

SpritePrep_PurpleChest:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        JSL DetermineFollowerSpawn : BCC +
            LDA.b #$00 ; return to despawn
            RTL
        +
        PLA : PLA : PEA.w $8A69-1 ; return to spawn
        LDA.b #$01 : STA.w SprRedrawFlag, X
        RTL
.vanilla
    LDA.l FollowerIndicator : CMP.b #$0C
    RTL

SpriteDraw_PurpleChest:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        LDA.b #.oam_group>>16 : STA.b Scrap08
        REP #$20
        LDA.w #.oam_group : STA.b Scrap06
        LDA.w #0000 : STA.b Scrap09
        LDA.l Follower_PurpleChest_vram
        JML TransferAndDrawFollowerGfx
.vanilla
    JML Sprite_PrepAndDrawSingleLargeLong ; what we wrote over
.oam_group:
dw 0, -8 : db $C8, $00, $00, $02
dw 0,  0 : db $EE, $00, $00, $02

PurpleChest_FollowCheck:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        LDA.b #$00
        RTL
.vanilla
    LDA.l FollowerIndicator ; what we wrote over
    RTL

PurpleChest_BecomeFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        PLA : PLA
        JSL StoreAndLoadFollower : BCS .return
            STZ.w SpriteAITable, X
.return
    PEA.w $E10A-1 ; jump ahead on return
    RTL
.vanilla
    STZ.w SpriteAITable, X : LDA.b #$0C ; what we wrote over
    RTL

SpritePrep_SuperBomb:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        JSL DetermineFollowerSpawn : BCC +
            LDA.b #$00 ; despawn on exit
            RTL
        +
        LDA.b #$05
        RTL
.vanilla
    LDA.l CrystalsField ; what we wrote over
    RTL

SpriteDraw_SuperBomb:
    LDA.w SpriteJumpIndex, X : CMP.b #$02 : BNE .vanilla
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        LDA.b #.oam_group>>16 : STA.b Scrap08
        REP #$20
        LDA.w #.oam_group : STA.b Scrap06
        LDA.w #.palette_data : STA.b Scrap09
        PLA : PEA.w $E2E2-1 ; skip vanilla draw
        LDA.l Follower_SuperBomb_vram
        JML TransferAndDrawFollowerGfx
.vanilla
    LDA.b #$01 : STA.b Scrap06 ; what we wrote over
    RTL
.oam_group:
dw 0, -8 : db $AE, $08, $00, $02
dw 0,  0 : db $4E, $08, $00, $02
.palette_data
;   01             04        06   07   08   09   0A        0C   0D
db $08, $00, $00, $08, $00, $06, $08, $08, $06, $08, $00, $08, $08

SuperBomb_FollowCheck:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        LDA.w SpriteTimerE, X : BNE .skip_follow
        LDA.w SpriteAux, X : BEQ .vanilla
            PLA : PLA : PEA.w $E1F1-1 ; jump to skip cost, no double charge
            RTL
.skip_follow
    PLA : PLA : PEA.w $E20C-1 ; jump to exit
    RTL
.vanilla
    LDA.b #$64 : LDY.b #$00 ; what we wrote over
    RTL

SuperBomb_BecomeFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        PLA : PLA
        JSL StoreAndLoadFollower : BCC +
            PEA.w $E20C-1 : RTL ; jump to exit
        +
        PEA.w $E201-1 ; jump to despawn
        RTL
.vanilla
    LDA.b #$0D : STA.l FollowerIndicator ; what we wrote over
    RTL

pushpc
org $868A14
NOP #3 ; fix bomb shop spawn for dwarfless big bomb
LDA.b #$B5 : JSL Sprite_SpawnDynamically
BMI SuperBomb_BecomeFollower_exit
LDA.b #$01 : STA.w SprRedrawFlag, Y ; force redraw for super bomb gfx
pullpc

SpritePrep_Kiki:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        JSL DetermineFollowerSpawn : BCC +
            LDA.b #$20 : RTL ; despawn on exit
        +
        LDA.b #$00
        RTL
.vanilla
    LDX.b OverworldIndex : LDA.l OverworldEventDataWRAM,X ; what we wrote over
    RTL

Kiki_OfferToFollow:
    PHA
        LDA.w SpriteTimerE, X : BNE .skip_collision_check
    PLA
    JML Sprite_ShowMessageUnconditional ; what we wrote over
.skip_collision_check
    PLA
    CLC : RTL

Kiki_FollowCheck:
    JSL DetermineFollowerSpawn_include_stored : BCS .skip_follow
    LDA.w SpriteTimerE, X
    RTL
.skip_follow
    LDA.b #$20
    RTL

Kiki_BecomeFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .no_follower_shuffle
        PLA : PLA : PEA.w $E4C2-1 ; jump to exit
        STZ.w FollowerNoDraw
        JML StoreAndLoadFollower
.no_follower_shuffle
    LDA.b #$00 : STA.l FollowerDropped ; defuse bomb
    LDA.b #$0A : STA.l FollowerIndicator
RTL

Kiki_FixTeleportOnExit:
    REP #$30
        LDA.b LinkPosX : STA.w LinkPosXCache
        LDA.b LinkPosY : STA.w LinkPosYCache
    SEP #$30
    LDA.b #$19 : LDY.b #$01 ; what we wrote over
RTL 

; on return it checks BEQ and if non-zero, kiki get spook
Kiki_DontScareTheMonke:
    LDA.b LinkJumping : BEQ .return
    CMP.b #$02 : BEQ .no_spook ; needed for quake usage
    LDA.b GameMode : CMP.b #$0F : BEQ .no_spook ; needed for entrance transitions
    LDA.w NoDamage : BNE .no_spook
    LDA.w LinkThud : BNE .no_spook
.spook
    LDA.b #$01 : RTL
.no_spook
    LDA.b #$00
.return
    RTL

Kiki_ActivateEntranceOpening:
    PHA
        LDA.b LinkDirection : CMP.b #$02 : BNE .continue
        LDA.b LinkStrafe : BEQ .exit
.continue
    PLA
    JML Kiki_RevertToSprite ; what we wrote over
.exit
    PLA
    RTL

SpritePrep_Locksmith:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        JSL DetermineFollowerSpawn_locksmith_check : BCS +
            LDA.b #$01 : STA.w SprRedrawFlag, X
        +
        LDA.l FollowerIndicator
        RTL
.vanilla
    LDA.l FollowerIndicator : CMP.b #$09 ; what we wrote over
    BEQ +
        CLC : RTL
    +
    SEC : RTL

SpriteDraw_LocksmithFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        LDA.b #.oam_group>>16 : STA.b Scrap08
        REP #$20
        LDA.w #.oam_group : STA.b Scrap06
        LDA.w #.palette_data : STA.b Scrap09
        PLA : PEA.w $DCD6-1 ; skip draw on exit
        LDA.l Follower_Locksmith_vram
        JML TransferAndDrawFollowerGfx
.vanilla
    LDA.b #$02 : STA.b Scrap06 ; what we wrote over
    RTL
.oam_group:
dw 0, -8 : db $EA, $00, $00, $02
dw 0,  0 : db $EC, $00, $00, $02
.palette_data
;   01             04        06   07   08   09   0A        0C   0D
db $00, $00, $00, $0E, $00, $00, $0E, $0E, $00, $0E, $00, $0E, $0E

Locksmith_Chillin_PostMessage:
    LDA.w SpriteAux, X : BEQ +
        ; when a follower is stored, merely walk near them
        LDA.w SpritePosXLow, X : PHA
        JSL Follower_CheckCollision : BCC .return
        BRA .continue
    +
    LDA.w SpritePosXLow, X : PHA
    SEC : SBC.b #$10 : STA.w SpritePosXLow, X
    LDA.b #$01 : STA.w SpriteVelocityX, X
    JSL Sprite_Get16BitCoords_long
    JSL Follower_CheckTileCollision : BNE .return
.continue
        INC.w SpriteActivity, X ; award follower
        LDA.l FollowerIndicator : CMP.b #$0C : BEQ .purple_chest_prize
        LDA.l FollowerTravelAllowed : CMP.b #$02 : BEQ .return
        LDA.l FollowerIndicator : CMP.b #$00 : BEQ .return
            LDA.b #$05 : STA.w SpriteActivity, X ; forever do nothing
            BRA .return
.purple_chest_prize
    INC.w SpriteActivity, X ; prep for purple chest prize
.return
    PLA : STA.w SpritePosXLow, X
    JML $86BD08 ; jump back to immediately RTS

Locksmith_BecomeFollower:
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .vanilla
        STZ.w FollowerNoDraw
        PLA : PLA
        JSL StoreAndLoadFollower : BCS +
            LDA.l FollowerIndicator : CMP.b #$0C : BEQ +
            PEA.w $BD24-1 : RTL ; jump to despawn
        +
        PEA.w $BD27-1 ; jump to exit
        RTL
.vanilla
    LDA.b #$09 : STA.l FollowerIndicator
    RTL

Locksmith_RespondToAnswer_PostItem:
    STA.l FollowerIndicator ; what we wrote over
    LDA.l FollowerTravelAllowed : CMP.b #$02 : BNE .no_despawn
    LDA.w SpriteAux, X : CMP.b #$0C : BEQ .despawn
        CMP.b #$00 : BNE .no_despawn
    LDA.l Follower_Locksmith : CMP.b #$0C : BEQ .despawn
    JSL DetermineFollowerSpawn_include_stored : BCC .no_despawn
.despawn
    STZ.w SpriteAITable, X
.no_despawn
    RTL
