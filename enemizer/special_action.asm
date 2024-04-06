;================================================================================
; Special action
;================================================================================
check_special_action:
{
    LDA.l BossSpecialAction : BEQ .no_special_action
        LDA.b #$05 : STA.b GameSubMode
        STZ.w BossSpecialAction
    .no_special_action
    JSL Player_Main
RTL
}