;================================================================================
; NMI Hook
;--------------------------------------------------------------------------------
; rando already hooks the Bank00.asm : 164 (PHA : PHX : PHY : PHD : PHB) so we have to hook after that
org $8080D0 ; <- D0 - Bank00.asm : 164-167 (PHB, LDA.w #$0000)
JML NMIHookActionEnemizer
org $8080D5 ; <- D5 - Bank00.asm : 164-167 (PHB, LDA.w #$0000)
NMIHookReturnEnemizer:
;--------------------------------------------------------------------------------
