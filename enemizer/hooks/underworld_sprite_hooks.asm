org $89C29A
JSL LoadUnderworldSprites : NOP

; these hooks change the LDA.b ($00) commands to use LDA.b [$00] commands
; so we can store the sprites in a different bank
; also needs to change the use of $02 to $03 for slot index to make that possible

org $89C2B2
LDA.b [Scrap00]

org $89C2C1
LDA.b [Scrap00],Y

org $89C2CA
INC.b Scrap03 ; change slot variable to $03

;org $09C329  standing items overwrote this one
;LDA.b [Scrap00],Y

org $89C332
LDA.b [Scrap00],Y

org $89C345
DEC.b Scrap03 : LDX.b Scrap03

org $89C350
LDA.b [Scrap00],Y

org $89C35A
DEC.b Scrap03

org $89C36E
JSL GetSpriteSlot16Bit ; depended on high bit being zero, which it isn't anymore

org $89C383
LDX.b Scrap03

org $89C38C
LDA.b [Scrap00],Y

org $89C398
LDA.b [Scrap00],Y

org $89C3AA
LDA.b [Scrap00],Y

org $89C3BF
LDA.b [Scrap00],Y

org $89C3DF
LDA.b Scrap03

org $89C3F3
LDA.b [Scrap00],Y

org $89C3FB
LDA.b [Scrap00],Y

org $89C404
LDA.b [Scrap00],Y

org $89C416
LDA.b [Scrap00],Y




