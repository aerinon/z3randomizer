pushpc

org $8794B1 ; overworld pit fall: replaces LDA.l $7EC000
JSL PitWarpTransitionOverride

org $87D12F ; underworld warp tile: replaces LDA.l $7EC000
JSL PitWarpTransitionOverride

org $829611 ; warp finalize: replaces JSL SetAndSaveVisitedQuadrantFlags
JSL PitWarpWarpFinalize

pullpc

; PitWarpTransitionOverride
; Replaces the LDA.l $7EC000 instruction at the pit and warp hook sites.
; On entry: 8-bit A, RoomIndex ($A0) holds the source room (not yet overwritten).
; On exit:  8-bit A contains the destination room ID.
;           Caller's STA.b $A0 then writes it to RoomIndex as normal.
; If an override applies, also writes placement variables (scroll, camera, etc.) to RAM.
; If no override, returns the vanilla $7EC000 value unchanged.

PitWarpTransitionOverride:
  LDA.l $7EC000   ; load vanilla destination (replaces the instruction we hooked)
  PHA             ; push it — will be returned in A or replaced on override path

  PHP : PHB

  ; Set data bank to $7E for absolute addressing of RAM (A is already 8-bit at both hook sites)
  LDA.b #$7E : PHA : PLB

  ; --- Lookup phase ---
  SEP #$30            ; 8-bit A, 8-bit X/Y
  LDA.b RoomIndex : TAX : LDA.l PitWarpLookupTable, X
  BEQ .normal_transition

  ; Classify the lookup value
  CMP.b #$C0 : BCS .list_check
  BIT.b #$80 : BNE .quad_check

  ; --- $4x: Room-only override ---
  ; Low 6 bits = direct LandingZoneData row index
  AND.b #$3F
  BRA .resolve_row

.quad_check:
  ; --- $8x: Quadrant-based override ---
  ; Low 3 bits = PitWarpQuadrantTable entry index (0-5)
  ; Each entry is 4 bytes; multiply index by 4
  AND.b #$07 : ASL #2 : TAX

  ; Add quadrant offset to entry base: V (0/2) and H (0/1) occupy different bits so ADD = OR
  TXA : CLC : ADC.b LinkQuadrantV : ADC.b LinkQuadrantH : TAX

  ; Read the row index from the quadrant table
  LDA.l PitWarpQuadrantTable, X : CMP.b #$FF : BEQ .normal_transition
  BRA .resolve_row

.list_check:
  ; --- $Cx: Collision bounding-box check ---
  AND.b #$03 : ASL A : TAX     ; low 2 bits × 2 = word index into pointers

  REP #$30
  LDA.l PitWarpCollisionListPointers, X : TAX  ; X = list pointer (bank $A7 offset)
  LDA.l $A70000, X : TAY : BEQ .normal_transition_16  ; Y = entry count
  INX #2                        ; advance past count

  ; Each entry: xMin(w), xMax(w), yMin(w), yMax(w), rowIndex(w) = 10 bytes
.collision_loop:
  LDA.b LinkPosX : CMP.l $A70000, X : BCC .collision_next  ; LinkPosX >= xMin?
  LDA.l $A70002, X : CMP.b LinkPosX : BCC .collision_next  ; xMax >= LinkPosX?
  LDA.b LinkPosY : CMP.l $A70004, X : BCC .collision_next  ; LinkPosY >= yMin?
  LDA.l $A70006, X : CMP.b LinkPosY : BCC .collision_next  ; yMax >= LinkPosY?
  LDA.l $A70008, X : SEP #$30 : BRA .resolve_row           ; match: row index in A

.collision_next:
  TXA : CLC : ADC.w #$000A : TAX  ; advance to next entry
  DEY : BNE .collision_loop

.normal_transition_16:
  SEP #$30
.normal_transition:
  PLB :  PLP      ; restores register
  PLA :  RTL      ; return vanilla destination in A

.resolve_row:
  ; A = LandingZoneData row index (8-bit)
  ; Multiply by 25: index*3 then *8 gives *24, add index = *25
  REP #$30
  AND.w #$00FF : TAY            ; zero-extend index into Y
  LDA.b Scrap00 : PHA           ; preserve $00: pit handler reads it after we return
  TYA : STA.b Scrap00
  ASL A : CLC : ADC.b Scrap00   ; A = index * 3
  ASL #3 : CLC : ADC.b Scrap00  ; A = index * 24 + index = index * 25
  TAX               ; X = byte offset into LandingZoneData
  PLA : STA.b Scrap00           ; restore $00

  ; --- Check vanilla flag and load room ID ---
  ; High byte $80 = vanilla flag; BIT.w #$8000 tests bit 15 without changing A or mode
  LDA.l LandingZoneData, X
  BIT.w #$8000 : BNE .normal_transition_16

  ; Offset 2: Link Y -> LinkPosY
  LDA.l LandingZoneData+2, X : STA.b LinkPosY

  ; Offset 4: Link X -> LinkPosX
  LDA.l LandingZoneData+4, X : STA.b LinkPosX

  ; Offset 6: Scroll X -> BG1H and BG2H
  LDA.l LandingZoneData+6, X : STA.b BG1H : STA.b BG2H

  ; Offset 8: Scroll Y -> BG1V and BG2V
  LDA.l LandingZoneData+8, X : STA.b BG1V : STA.b BG2V

  ; Offset 10: Camera Y -> CameraScrollN; CameraScrollS = N + 2 (vanilla keeps the pair together)
  LDA.l LandingZoneData+10, X : STA.w CameraScrollN : INC #2 : STA.w CameraScrollS

  ; Offset 12: Camera X -> CameraScrollW; CameraScrollE = W + 2
  LDA.l LandingZoneData+12, X : STA.w CameraScrollW : INC #2 : STA.w CameraScrollE

  ; --- Single-byte fields (8-bit A) ---
  SEP #$20

  ; Offset 14: target layer (0-2) -> $063C; HandleLayerOfDestination derives $0476/$EE from it
  LDA.l LandingZoneData+14, X : STA.w $063C

  ; Offset 15: HV scroll packed -> CameraBoundH (bits 1-0), CameraBoundV (bits 3-2)
  LDA.l LandingZoneData+15, X
  PHA : AND.b #$03 : STA.b CameraBoundH
  PLA : LSR #2 : AND.b #$03 : STA.b CameraBoundV

  ; Offset 16: Scroll quad packed -> LinkQuadrantH (bit 0), LinkQuadrantV (bit 1 -> 0 or 2)
  LDA.l LandingZoneData+16, X
  PHA : AND.b #$01 : STA.b LinkQuadrantH
  PLA : AND.b #$02 : STA.b LinkQuadrantV

  ; ApplyLinksMovementToCamera runs later this frame and flips the quadrant if Link's
  ; position high bytes differ from the pre-move cache ($40/$41); match the cache
  LDA.b LinkPosY+1 : STA.b $40
  LDA.b LinkPosX+1 : STA.b $41

  ; Offset 17-24: Camera bounds -> $7E0601, $7E0603, ..., $7E060F (odd bytes)
  ; X counts up so it never wraps below the row (long,X would carry into bank $A8)
  LDY.w #$0000
.camera_bounds_loop:
  LDA.l LandingZoneData+17, X : STA.w $0601, Y
  INX : INY #2 : CPY.w #$0010 : BCC .camera_bounds_loop

  ; X is now row offset + 8; reload override room ID for return
  ; PreviousRoom = destination zeroes vanilla's room-grid shift (Underworld_AdjustAfterSpiralStairs)
  LDA.l LandingZoneData-8, X : STA.b PreviousRoom : TAY

  ; Return override destination in A; discard vanilla destination from stack
  PLB :  PLP      ; restores 8-bit A mode
  PLA             ; discard vanilla destination
  TYA             ; return override room ID
  RTL

; PitWarpWarpFinalize
; Vanilla warps never land in a boss room, so the warp's final step lacks the
; boss music check the fall path runs (Module07_07_11_CacheRoomAndSetMusic).
PitWarpWarpFinalize:
  JSL SetAndSaveVisitedQuadrantFlags
  JML Underworld_SetBossOrSancMusicUponEntry_long
