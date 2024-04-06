pushpc

org $9E9463
JSL CheckKholdShellCoordinates
BCC Sprite_A3_KholdstareShell_link_not_close
BRA Sprite_A3_KholdstareShell_link_close
NOP #13

Sprite_A3_KholdstareShell_link_close = $9E9478
Sprite_A3_KholdstareShell_link_not_close = $9E9480

pullpc

CheckKholdShellCoordinates:

LDA.w SpritePosXHigh, X
XBA
LDA.w SpritePosXLow, X  ; full 16 bit X coordinate of sprite

REP #$21  ; carry is guaranteed clear
SBC.w #$0020
CMP.b LinkPosX
BCS .not_colliding

ADC.w #$0040  ; carry is guaranteed clear
CMP.b LinkPosX
BCC .not_colliding

SEP #$20
LDA.w SpritePosYHigh, X
XBA
LDA.w SpritePosYLow, X  ; full 16 bit Y coordinate of sprite

REP #$21 ; carry is guaranteed clear
SBC.w #$001F  ; could go to 27 and still let link squeeze in
CMP.b LinkPosY
BCS .not_colliding

ADC.w #$0037 ; carry is guaranteed clear
CMP.b LinkPosY
BCC .not_colliding

SEP #$20  ; collision detected
SEC
RTL

.not_colliding
SEP #$30
CLC
RTL

