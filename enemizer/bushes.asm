sprite_bush_spawn:
{
    STY.b Scrap0D           ; restored code
    LDA.l !BUSHES_FLAG  ; That byte is the flag to activate random enemies under bush
    BNE .continue
    CPY.b #$04 : BNE .not_random_old
    JSL GetRandomInt : AND.b #$03 : !ADD.b #$13 : TAY
    
    .not_random_old
    LDA.w $81F3, Y;restored code 
    RTL

    .continue
    PHX : PHY       ; save x,y just to be safe
    PHB : PHK : PLB ; setbank to 40

    CPY.b #$04 : BNE .not_random
    JSL GetRandomInt : AND.b #$03 : TAY
    LDA.w sprite_bush_spawn_table_random_sprites, Y 
    BRL .return

    .not_random

    CPY.b #$0F : BEQ .newSpriteSpawn
    CPY.b #$11 : BEQ .newSpriteSpawn
    CPY.b #$10 : BEQ .newSpriteSpawn
    ;CPY.b #$0E : BEQ .newSpriteSpawn

    LDA.w item_drop_table_override, Y
    BRA .return

    .newSpriteSpawn
    LDA.l OverworldIndexMirror : TAY                               ; load the area ID
    LDA.l ProgressIndicator : CMP.b #$03 : !BLT .dontGoPhase2   ; check if agahnim 1 is alive
    ; aga1 is dead
    LDA.l OverworldIndexMirror : CMP.b #$40 : !BGE .dontGoPhase2   ; check if we are in DW, if so we can skip shifting table index
    !ADD.b #$90 : TAY                                 ; agahnim 1 is dead, so we need to go to the 2nd phase table for LW
    .dontGoPhase2
    LDA.w sprite_bush_spawn_table_overworld, Y ;LDA 408000 + area id

    .return
    PLB         ; restore bank to where it was
    PLY : PLX   ; restore x,y
    RTL
}