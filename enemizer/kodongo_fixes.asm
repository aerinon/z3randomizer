pushpc

org $9EC147
JSL NewKodongoCollision
JMP .continue : NOP #2
.continue

org $9EC152
Kodongo_SetDirection:

pullpc

NewKodongoCollision:
    LDA.w SpriteMoveDirection, X : INC A : AND.b #$03 : STA.w SpriteMoveDirection, X
    ;If they collide more than 4 times just set direction
    LDA.w SpriteAuxTable, X : INC A : STA.w SpriteAuxTable, X : CMP.b #$04 : BCC .continue
    PLA : PLA : PEA.w Kodongo_SetDirection-1
.continue
RTL