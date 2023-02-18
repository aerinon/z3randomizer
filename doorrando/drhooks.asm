org $82b5c4 ; -- moving right routine 135c4
jsl WarpRight
org $82b665 ; -- moving left routine
jsl WarpLeft
org $82b713 ; -- moving down routine
jsl WarpDown
org $82b7b4 ; -- moving up routine
jsl WarpUp
org $82bd80
jsl AdjustTransition
nop

;turn off linking doors -- see .notRoomLinkDoor label in Bank02.asm
org $82b5a8 ; <- 135a8 - Bank02.asm : 8368 (LDA $7EC004 : STA $A0)
jsl CheckLinkDoorR
bcc NotLinkDoor1
org $82b5b6
NotLinkDoor1:
org $82b649 ; <- 135a8 - Bank02.asm : 8482 (LDA $7EC004 : STA $A0)
jsl CheckLinkDoorL
bcc NotLinkDoor2
org $82b657
NotLinkDoor2:


; Staircase routine
org $81c3d4 ; <- c3d4 - Bank01.asm : 9762-4 (Dungeon_DetectStaircase-> STA $A0 : LDA $063D, X)
jsl RecordStairType : nop
org $82a1e7 ;(PC: 121e7)
jsl SpiralWarp

org $8291b3 ; <- Bank02.asm : 3303 (LDA $0462 : AND.b #$04)
jsl SpiralPriorityHack : nop
org $8290f9 ; <- Bank02.asm : 3188 (LDA $0462 : AND.b #$04)
jsl SpiralPriorityHack : nop

org $829369 ; <- 11369 - Bank02.asm : 3610 (STX $0464 :  STY $012E)
jsl StraightStairsAdj : nop #2
org $829383 ; <- 11384 - Bank02.asm : 3629 (.walkingDownStaircase-> ADD $20 : STA $20)
jsl StraightStairsFix : nop
org $8293aa ; <- 113aa - Bank02.asm : 3653 (ADD $20 : STA $20)
jsl StraightStairsFix : nop
org $8293d1 ; <- 113d1 - Bank02.asm : 3683 (ADD $20 : STA $20 BRANCH_IOTA)
jsl StraightStairsFix : nop
org $829396 ; <- 11396 - Bank02.asm : 3641 (LDA $01C322, X)
jsl StraightStairLayerFix
org $82c06d ; <- Bank02.asm : 9874 (LDX $0418, CMP.b #$02)
jsl DoorToStraight : nop
org $82c092 ; STA $0020, Y : LDX #$00
jsl DoorToInroom : nop
org $82c0f8 ; CMP $02C034, X
jsl DoorToInroomEnd
org $82941a ; <- Bank02.asm : 3748 module 7.12.11 (LDA $0464 : BNE BRANCH_$11513 : INC $B0 : RTS)
jsl StraightStairsTrapDoor : rts
org $828b54 ; <- Bank02.asm : 2200 (JSL UseImplicitRegIndexedLocalJumpTable)
jsl InroomStairsTrapDoor
org $82c146
jsl HandleSpecialDoorLanding

org $8289a0 ; JSL $0091C4
jsl QuadrantLoadOrderBeforeScroll
org $82bd9c ; JSL $0091C4
jsl QuadrantLoadOrderAfterScroll


; Graphics fix
org $82895d ; Bank 02 line 1812 (JSL Dungeon_LoadRoom : JSL Dungeon_InitStarTileChr : JSL $00D6F9 : INC $B0)
Splicer:
jsl GfxFixer
lda $b1 : beq .done
rts
nop #5
.done

org $81b618 ; Bank01.asm : 7963 Dungeon_LoadHeader (REP #$20 : INY : LDA [$0D], Y)
nop : jsl OverridePaletteHeader

org $82817e ; Bank02.asm : 414 (LDA $02811E, X)
jsl FixAnimatedTiles

org $8aef43 ; UnderworldMap_RecoverGFX
jsl FixCloseDungeonMap

org $828a06 ; Bank02.asm : 1941 Dungeon_ResetTorchBackgroundAndPlayer
JSL FixWallmasterLamp

org $80d377 ;Bank 00 line 3185
DecompDungAnimatedTiles:
org $80fda4 ;Bank 00 line 8882
Dungeon_InitStarTileCh:
org $80d6ae ;(PC: 56ae)
LoadTransAuxGfx:
org $80d739 ;
LoadTransAuxGfx_Alt:
org $80df5a ;(PC: 5f5a)
PrepTransAuxGfx:
org $8ffd65 ;(PC: 07fd65)
Dungeon_LoadCustomTileAttr:
org $81feb0
Dungeon_ApproachFixedColor:
;org $01fec1
;Dungeon_ApproachFixedColor_variable:
;org $a0f972 ; Rando version
;LoadRoomHook:
org $9bee74 ;(PC: 0dee74)
Palette_DungBgMain:
org $9bec77
Palette_SpriteAux3:
org $9becc5
Palette_SpriteAux2:
org $9bece4
Palette_SpriteAux1:


org $828046 ; <- 10046 - Bank02.asm : 217 (JSL EnableForceBlank) (Start of Module_LoadFile)
jsl OnFileLoadOverride
org $87A93F  ; < 3A93F - Bank07.asm 6548 (LDA $8A : AND.b #$40 - Mirror checks)
jsl MirrorCheckOverride

org $85ef47
Sprite_HeartContainer_Override: ;sprite_heart_upgrades.asm : 96-100 (LDA $040C : CMP.b #$1A : BNE .not_in_ganons_tower)
jsl GtBossHeartCheckOverride : bcs .not_in_ganons_tower
nop : stz $0dd0, X : rts
.not_in_ganons_tower


org $87a955 ; <- Bank07.asm : around 6564 (JP is a bit different) (STZ $05FC : STZ $05FD)
jsl BlockEraseFix
nop #2

org $82A0A8
Mirror_SaveRoomData:
org $87A95B ; < bank_07.asm ; #_07A95B: JSL Mirror_SaveRoomData
jsl EGFixOnMirror

org $82b82a
jsl FixShopCode

org $9ddeea ; <- Bank1D.asm : 286 (JSL Sprite_LoadProperties)
jsl VitreousKeyReset

org $9ed024 ;  f5024 sprite_guruguru_bar.asm : 27 (LDA $040C : CMP.b #$12 : INY #2
jsl GuruguruFix : bra .next
nop #3
.next

org $828fc9
nop #2 : jsl BlindAtticFix

org $828409
jsl SuctionOverworldFix

org $8ded04 ; <- rando's hooks.asm line 2192 - 6ED04 - equipment.asm : 1963 (REP #$30)
jsl DrHudDungeonItemsAdditions
;org $098638 ; rando's hooks.asm line 2192
;jsl CountChestKeys
org $86D192 ; rando's hooks.asm line 457
jsl CountAbsorbedKeys
; rando's hooks.asm line 1020
;org $05FC7E ; <- 2FC7E - sprite_dash_item.asm : 118 (LDA $7EF36F : INC A : STA $7EF36F)
;jsl CountBonkItem

org $819dbd ; <- Bank01.asm : 4465 of Object_Draw8xN (LDA $9B52, Y : STA $7E2000, X)
jsl CutoffEntranceRug : bra .nextTile : nop
.nextTile

;maybe set 02e2 to 0

org $8799de ; <- Bank07.asm : 4088 (LDA.b #$15 : STA $5D)
JSL StoreTempBunnyState
;
org $88c450 ; <- ancilla_receive_item.asm : 146-148 (STY $5D : STZ $02D8)
JSL RetrieveBunnyState : NOP

org $82d9ce ; <- Bank02.asm : Dungeon_LoadEntrance 10829 (STA $A0 : STA $048E)
JSL CheckDarkWorldSpawn : NOP

org $81891e ; <- Bank 01.asm : 991 Dungeon_LoadType2Object (LDA $00 : XBA : AND.w #$00FF)
JSL RainPrevention : BCC + : RTS : NOP : +

org $9edabf ; <- sprite_energy_ball.asm : 86-7 Sprite_EnergyBall (LDA.b #$10 : LDX.b #$00)
JSL StandardAgaDmg

org $89F7B2 ; 09F7B2 Module17_01 S&Q
JSL StandardSaveAndQuit

org $89a681 ; < - similar to talalong.asm : 1157 (JSL Main_ShowTextMessage)
JSL BlindsAtticHint : NOP #2
org $9cfd69
Main_ShowTextMessage:

; Conditionally disable UW music changes in Door Rando
org $828ADB ; <- Bank02.asm:2088-2095 (LDX.b #$14 : LDA $A0 ...)
JSL.l Underworld_DoorDown_Entry : CPX #$FF
BEQ + : db $80, $1C ; BRA $028B04
NOP #6 : +

org $82C3F2 ; <- Bank02.asm:10521 Unused call
Underworld_DoorDown_Call:
org $82C3F3
dw $8AD9 ; address of Bank02.asm:2085

org $81AA90
JSL BigKeyDoorCheck : NOP

org $81AAA2
RoomDraw_OneSidedShutters_South_onesided_shutter_or_big_key_door:

;Enable south facing bk graphic
org $80CE24
dw $2ac8

org $81b714 ; PC: b714
OpenableDoors:
jsl CheckIfDoorsOpen
bcs .normal
rts
.normal
