LoadOverworldSprites:
    ; restore code
    STA.b Scrap01 ; 85 01
    LDY.w #$0000 ; A0 00 00

    ; set bank
    LDA.b #$09 : STA.b Scrap02 ; default is bank 9
RTL