; Free RAM notes
; Normal doors use $AB-AC for scrolling indicator
; Normal doors use $FE to store the trap door indicator
; Normal doors use $045e to store Y coordinate when transitioning to in-room stairs
; Normal doors use $045f to determine the order in which supertile quadrants are drawn
; Straight stairs use $046d to store X coordinate on animation start
; Spiral doors use $045e to store stair type
; Gfx uses $b1 to for sub-sub-sub-module thing

; Hooks into various routines
incsrc drhooks.asm

;Main Code
org $A78000 ;138000
db $44, $52 ;DR
DRMode:
dw 0
; xxpg rmse
; xxxx xBDM
; x - unused

; p - use the original palette for the dungeon rooms instead of the DR table
; g - fix the EG glitch in more places (should be off for no logic)
; r - The collection rate flag
; m - Whether to display keys Map Info
; s - Start with Mirror Scroll
; e - GT minibosses marked as defeated instead of spawning heart container in all dungeons

; B - Big Key doors can displayed and be opened on the "south" side in addition
; D - Enabled spawning as a bunny in the Dark World underworld
; M - hides the total number in the collection rate
DRFlags:
dw 0
DRScroll:
db 0
OffsetTable:
dw -8, 8
org $A78010
DRVersionInfo:
dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

org $A78020

incsrc normal.asm
incsrc scroll.asm
incsrc spiral.asm
incsrc gfx.asm
incsrc keydoors.asm
incsrc overrides.asm
incsrc edges.asm
incsrc math.asm
incsrc hudadditions.asm
incsrc dr_lobby.asm
incsrc entrance_fixes.asm
incsrc bugfix/kholdstare_shell_collision.asm
warnpc $A79C00

incsrc doortables.asm
warnpc $A88000
