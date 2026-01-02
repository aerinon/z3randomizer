; potential hook points for pit/warp transitions
;for pits: 0794B1 maybe a good place to hook
;for warps: 07D12F maybe a good place to hook

PitWarpTransitionOverride:

  LDA.l $7EC000 ; room header destination
  PHA
  ; check a flag to see if this type of transition has been hijacked
  LDX.b RoomIndex ; assumes 8-bit AX, probably not a good assumption, need to check on hooks
  LDA.l PitWarpLookupTable, X
  BEQ .normal_transition

  CMP.b #$C0 : BCS .list_check
  BIT.b #$80 : BNE .quad_check
  AND.b #$3F : TAX : BRA .read_landing_zone

.quad_check
  ; todo: implement quad check
  BRA .read_landing_zone

.list_check
  ; todo: implement list check

.read_landing_zone ; requires X to be set correctly
  ; todo: read landing zone data from table and set variables accordingly
  ; todo: note room id may have a bit set
  ; todo: note we need to change the PLA on the stack appropriately ($A0/RoomID will be set to that)

.normal_transition
  PLA
  RTL