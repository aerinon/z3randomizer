;-------------
NMIHookActionEnemizer:
{
    ;-----------------------------------------
    ; do our shell stuff
    PHA
    PHP

    SEP #$20 ; get into 8-bit mode
    
    LDA.l !SHELL_DMA_FLAG : BEQ .return ; check our draw flag
    AND.b #$01 : BNE .loadKholdstare
    LDA.l !SHELL_DMA_FLAG : AND.b #$02 : BNE .loadTrinexx
    BRA .return ; just in case
    ;BIT.b #$01 : BEQ .loadKholdstare
    ;BIT.b #$02 : BEQ .loadTrinexx

.loadKholdstare
    JSL DMAKholdstare
    LDA.b #$00 : STA.l !SHELL_DMA_FLAG ; clear our draw flag
    BRA .return

.loadTrinexx
    JSL DMATrinexx
    LDA.b #$00 : STA.l !SHELL_DMA_FLAG ; clear our draw flag

.return
    PLP
    PLA
    ;-----------------------------------------
    ; restore code Bank00.asm (164-167)
    PHB
    ; Sets DP to $0000
    LDA.w #$0000 : TCD

JML NMIHookReturnEnemizer
}

DMAKholdstare:
{
    ;#GFX_Kholdstare_Shell>>16
    %DMA_VRAM(#$34,#$00,#GFX_Kholdstare_Shell>>16&$FF,#GFX_Kholdstare_Shell>>8&$FF,#GFX_Kholdstare_Shell&$FF,#$10,#$00)
    RTL
}

DMATrinexx:
{
    ; TODO: change this to trinexx gfx
    %DMA_VRAM(#$34,#$00,#GFX_Trinexx_Shell>>16,#GFX_Trinexx_Shell>>8&$FF,#GFX_Trinexx_Shell&$FF,#$08,#$00)
    %DMA_VRAM(#$3A,#$A0,#GFX_Trinexx_Shell2>>16,#GFX_Trinexx_Shell2>>8&$FF,#GFX_Trinexx_Shell2&$FF,#$00,#$C0)

    RTL
}
