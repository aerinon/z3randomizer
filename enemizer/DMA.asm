!DISP_REG           = $2100 ; Screen Display Register
!VMAIN_REG          = $2115 ; Video Port Control Register
!VRAM_LOW_REG       = $2116 ; VRAM Address Registers (Low)
!VRAM_HIGH_REG      = $2117 ; VRAM Address Registers (High)
!VRAM_WRITE_REG     = #$18  ; VRAM Data Write Registers (Low) (you always store it to the dest register so no need for the actual address)

!DMA0_REG           = $4300 ; DMA Control Register - channel 0
!DMA0_DEST_REG      = $4301 ; DMA Destination Register
!DMA0_SRC_LOW_REG   = $4302 ; DMA Source Address Register (Low)
!DMA0_SRC_HIGH_REG  = $4303 ; DMA Source Address Register (High)
!DMA0_SRC_BANK_REG  = $4304 ; DMA Source Address Register (Bank)
!DMA0_SIZE_LOW_REG  = $4305 ; DMA Size Registers (Low)
!DMA0_SIZE_HIGH_REG = $4306 ; DMA Size Registers (Low)

!DMA_ENABLE_REG     = $420B ; DMA Enable Register

macro DMA_VRAM(VRAM_HIGH,VRAM_LOW,SRC_BANK,SRC_HIGH,SRC_LOW,LENGTH_HIGH,LENGTH_LOW)
    PHA
        ; --- preserve DMA registers ----------------------------------------------------
        LDA.w !DMA0_REG           : PHA
        LDA.w !DMA0_DEST_REG      : PHA
        LDA.w !DMA0_SRC_LOW_REG   : PHA
        LDA.w !DMA0_SRC_HIGH_REG  : PHA
        LDA.w !DMA0_SRC_BANK_REG  : PHA
        LDA.w !DMA0_SIZE_LOW_REG  : PHA
        LDA.w !DMA0_SIZE_HIGH_REG : PHA
		; -------------------------------------------------------------------------------

		;LDA.b #$80 : STA.w !DISP_REG ; force vblank
		LDA.b #$80   : STA.w !VMAIN_REG

        ; write to vram at $<VRAM_HIGH><VRAM_LOW>
		LDA.b <VRAM_LOW>  : STA.w !VRAM_LOW_REG  ; Set VRAM destination address low byte
		LDA.b <VRAM_HIGH> : STA.w !VRAM_HIGH_REG ; Set VRAM destination address high byte
		
        ; Set DMA0 to write a word at a time.
		LDA.b #$01
		STA.w !DMA0_REG

        ; Write to $2118 & $2119 - VRAM Data Write Registers (Low) & VRAM Data Write Registers (High)
        ; setting word write mode on DMA0_REG causes a write to $2118 and then $2119
        ; $21xx is assumed
		LDA.b !VRAM_WRITE_REG
		STA.w !DMA0_DEST_REG
		
		; Read from $<SRC_BANK>:<SRC_HIGH><SRC_LOW>.
		LDA.b <SRC_LOW>
		STA.w !DMA0_SRC_LOW_REG           ; set src address low byte
		LDA.b <SRC_HIGH>
		STA.w !DMA0_SRC_HIGH_REG          ; set src address high byte
		LDA.b <SRC_BANK>
		STA.w !DMA0_SRC_BANK_REG          ; set src address bank byte

		; total bytes to copy: #$1000 bytes.
		LDA.b <LENGTH_LOW>  : STA.w !DMA0_SIZE_LOW_REG   ; length low byte
		LDA.b <LENGTH_HIGH> : STA.w !DMA0_SIZE_HIGH_REG   ; length high byte

        ; start DMA on channel 0
		LDA.b #$01                        ; channel select bitmask
		STA.w !DMA_ENABLE_REG
		
		; --- restore DMA registers -----------------------------------------------------
        PLA : STA.w !DMA0_SIZE_HIGH_REG
        PLA : STA.w !DMA0_SIZE_LOW_REG
        PLA : STA.w !DMA0_SRC_BANK_REG
        PLA : STA.w !DMA0_SRC_HIGH_REG
        PLA : STA.w !DMA0_SRC_LOW_REG
        PLA : STA.w !DMA0_DEST_REG
        PLA : STA.w !DMA0_REG
		; -------------------------------------------------------------------------------
    PLA
endmacro
