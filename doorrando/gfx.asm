GfxFixer:
{
    lda.l DRMode : bne +
        jsl LoadRoomHook ;this is the code we overwrote
        jsl Dungeon_InitStarTileCh
        jsl LoadTransAuxGfx_Alt
        inc.b SubSubModule
        rtl
    + lda.b $b1 : bne .stage2
    jsl LoadRoomHook ; this is the rando version - let's only call this guy once - may fix star tiles and slower loads
    jsl Dungeon_InitStarTileCh
    jsl LoadTransAuxGfx
    jsl Dungeon_LoadCustomTileAttr
    jsl PrepTransAuxGfx
    lda.l DRMode : cmp.b #$02 : bne + ; only do this in crossed mode
        ldx.b RoomIndex : lda.l TilesetTable, x
        cmp.w $0aa1 : beq + ; already eq no need to decomp
            sta.w $0aa1
            tax : lda.l AnimatedTileSheets, x : tay
            jsl DecompDungAnimatedTiles
    +
    lda.b #$09 : sta.b NMIINCR : sta.w SkipOAM
    jsl Palette_SpriteAux3
    jsl Palette_SpriteAux2
    jsl Palette_SpriteAux1
    jsl Palette_DungBgMain
    jsr CgramAuxToMain
    inc.b $b1
    rtl
    .stage2
    lda.b #$0a : sta.b NMIINCR : sta.w SkipOAM
    stz.b $b1 : inc.b SubSubModule
    rtl
}

FixAnimatedTiles:
	LDA.l DRMode : CMP.b #$02 : BNE +
	LDA.w DungeonID : CMP.b #$FF : BEQ +
		PHX
			LDX.b RoomIndex : LDA.l TilesetTable, x
			CMP.w $0AA1 : beq ++
				TAX : PLA : BRA +
			++
		PLX
	+ LDA.l AnimatedTileSheets, X ; what we wrote over
	RTL

FixCloseDungeonMap:
    LDA.l DRMode : CMP.b #$02 : BNE .vanilla
	LDA.w DungeonID : BMI .vanilla
        LSR : TAX
        LDA.l DungeonTilesets,x
        RTL
    .vanilla
    LDA.l $7EC20E
    RTL

FixWallmasterLamp:
ORA.w $0458
STY.b MAINDESQ : STA.b SUBDESQ : RTL ; what we wrote over


CgramAuxToMain: ; ripped this from bank02 because it ended with rts
{
    rep #$20
    ldx.b #$00

    .loop
    lda.l $7EC300, X : sta.l $7EC500, x
    lda.l $7EC340, x : sta.l $7EC540, x
    lda.l $7EC380, x : sta.l $7EC580, x
    lda.l $7EC3C0, x : sta.l $7EC5C0, x
    lda.l $7EC400, x : sta.l $7EC600, x
    lda.l $7EC440, x : sta.l $7EC640, x
    lda.l $7EC480, x : sta.l $7EC680, x
    lda.l $7EC4C0, x : sta.l $7EC6C0, x

    inx #2 : cpx.b #$40 : bne .loop
    sep #$20

    ; tell NMI to upload new CGRAM data
    inc.b NMICGRAM
    rts
}

OverridePaletteHeader:
	lda.l DRMode : cmp.b #$02 : bne +
	lda.l DRFlags : and.b #$20 : bne +
	cpx.w #$01c2 : !BGE +
		rep #$20
		txa : lsr : tax
		lda.l PaletteTable, x
		iny : rtl
	+ rep #$20 : iny : lda.b [Scrap0D], Y ; what we wrote over
rtl