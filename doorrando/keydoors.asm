; code to un-pair or re-pair doors

; doorlist is loaded into 19A0 but no terminator
; new room is in A0
; for "each" door do the following: (each could mean the first four doors?)
; in lookup table, grab room and corresponding position
; find the info at 7ef000, x where x is twice the paired room
; check the corresponding bit (there are only 4)
; set the bit in 068C

; Note the carry bit is used to indicate if we should aborted (set) or not
CheckIfDoorsOpen: {
    jsr TrapDoorFixer ; see normal.asm
    ; note we are 16bit mode right now
    lda.l DRMode : beq +
        lda.w DungeonID : cmp.w #$00ff : bne .gtg
    + lda.b RoomIndex : dec : tax : and.w #$000f ; hijacked code
    sec : rtl ; set carry to indicate normal behavior

    .gtg
    phb : phk : plb
    stx.b Scrap00 : ldy.w #$0000
    .nextDoor
    lda.b RoomIndex : asl : tax
    lda.w KeyDoorOffset, x : beq .skipDoor
    asl : sty.b Scrap05 : !ADD.b Scrap05 : tax
    lda.w PairedDoorTable, x : beq .skipDoor
    sta.b Scrap02 : and.w #$00ff : asl a : tax
    lda.b Scrap02 : and.w #$ff00 : sta.b Scrap03
    lda.l RoomDataWRAM.l, X : and.w #$f000 : and.b Scrap03 : beq .skipDoor
    tyx : lda.w $068c : ora.l DungeonMask,x  : sta.w $068c
    .skipDoor
    iny #2 : cpy.b Scrap00 : bne .nextDoor
    plb : clc : rtl
}

; outstanding issues
; how to indicate opening for other (non-first four doors?)
; Bank01 Door Register stores the 4 bits in 068c to 400 (depending on type)
; Key collision and others depend on F0-F3 attribute not sure if extendable to other numbers
; Dungeon_ProcessTorchAndDoorInteractives.isOpenableDoor is the likely culprit for collision problems
; Saving open status to other unused rooms is tricky -- Bank 2 13947 (line 8888)
