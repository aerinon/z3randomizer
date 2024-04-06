CheckDarkWorldSpawn:
	STA.b RoomIndex : STA.w RoomIndexMirror ; what we wrote over
	LDA.l DRFlags : AND.w #$0200 : BEQ + ; skip if the flag isn't set
	LDA.l MoonPearlEquipment : AND.w #$00FF : BNE + ; moon pearl?
	LDA.l LinksHouseDarkWorld : CMP.b RoomIndex : BEQ ++
	LDA.l SanctuaryDarkWorld : CMP.b RoomIndex : BEQ ++
	LDA.l OldManDarkWorld : CMP.b RoomIndex : BNE +
		++ SEP #$30 : LDA.b #$17 : STA.b LinkState
		INC.w BunnyFlag : LDA.b #$40 : STA.l CurrentWorld : REP #$30
+ RTL
