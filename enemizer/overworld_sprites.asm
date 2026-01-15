LoadOverworldSprites:
    ; restore code
    STA.b Scrap01 ; 85 01
    LDY.w #$0000 ; A0 00 00

    ; set bank
    LDA.b #$09 : STA.b Scrap02 ; default is bank 9
RTL

; return A = $03 for post-aga enemies, $02 for pre-aga enemies, else rain state enemies
Overworld_LoadSprites_Decision:
    PHY : SEP #$10
    JSL ClearSpriteData
    REP #$10 : PLY
    LDA.l ProgressIndicator ; what we wrote over
RTL