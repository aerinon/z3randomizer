org $89C50B ; 0x4C50B
{
    ; .loadData
    ;     ; $4C50B-
    ;     STA.b Scrap01 ; 85 01
    ;     ; $4C50D-
    ;     LDY.w #$0000 ; A0 00 00
    JSL LoadOverworldSprites
    NOP
}
    
org $89C510 ; 0x4C510
LDA.b [Scrap00], Y ; replace LDA ($00), Y
; CMP.b #$FF : BEQ .stopLoading
; INY #2
org $89C518 ; 0x4C518
LDA.b [Scrap00], Y ; replace LDA ($00), Y
; DEY #2 : CMP.b #$F4 : BNE .notFallingRocks
; INC.w $0FFD
; INY #3
; BRA .nextSprite
; .notFallingRocks ; Anything other than falling rocks.
org $89C528 ; 0x4C528
LDA.b [Scrap00], Y ; replace LDA ($00), Y
; PHA : LSR #4 : ASL #2 : 
org $89C531 ; 0x4C531
STA.b Scrap0A ; STA.b $02
; INY
org $89C534 ; 0x4C534
LDA.b [Scrap00], Y ; replace LDA ($00), Y
; LSR #4 : CLC
org $89C53B ; 0x4C53B
ADC.b Scrap0A ; ADC.b $02
; STA.b $06
; PLA : ASL #4 : STA.b $07
org $89C546 ; 0x4C546
LDA.b [Scrap00], Y ; replace LDA ($00), Y
; AND.b #$0F : ORA.b $07 : STA.b $05
; INY
org $89C54F ; 0x4C54F
LDA.b [Scrap00], Y ; replace LDA ($00), Y
; LDX.b Scrap05 : INC A : STA.l $7FDF80, X

    ;     ; $4C558-
    ;     ; Move on to the next sprite / overlord.
    ;     INY ; C8
    ;     ; $4C559-
    ;     BRA .nextSprite ; 80 B5
    
    ; .stopLoading
    ;     ; $4C55B-
    ;     SEP #$10 ; E2 10
    ;     ; $4C55D-
    ;     RTS      ; 60
