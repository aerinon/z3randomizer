org $8780CA ; Bank07.asm(179)
JSL CheckIfLinkShouldDie : NOP : NOP : NOP
;SEC : SBC.b Scrap00 : CMP.b #$00 : BEQ .linkIsDead ; Bank07.asm(179) - 

org $8780D1
BNE linkNotDead : NOP : NOP ; Bank07.asm(183) - CMP.b #$A8 : BCC .linkNotDead

org $8780D5
linkIsDead:

org $8780F7
linkNotDead:
