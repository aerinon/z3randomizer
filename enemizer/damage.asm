CheckIfLinkShouldDie:
    ; before this we should have:
    ; LDA $7EF36D - this gets hooked, but we should have LDA at the end of it

    CMP.b Scrap00 : BCC .dead
        SEC : SBC.b Scrap00
        BRA .done
    .dead
        LDA.b #$00
.done
RTL
