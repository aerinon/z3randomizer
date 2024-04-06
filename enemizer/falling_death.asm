pushpc

org $868536
JSL CheckFallingDeathFlag

org $86FBF8
JSL CheckFallingDeathFlag

pullpc

CheckFallingDeathFlag:
	LDA.l !ENEMY_FALLING_STAY_ALIVE
	BEQ +
	RTL
	+ JML Sprite_ManuallySetDeathFlagUW  ; original code

