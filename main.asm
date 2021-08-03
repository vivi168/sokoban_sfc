;**************************************
; SOKOBAN
;**************************************
.65816

.include registers.inc
.include var.asm
.include assets.asm

.org 808000
.base 0000

.include vectors.asm
.include clear.asm
.include dma.asm
.include joypad.asm
.include level.asm
.include object.asm

MainLoop:
    wai

    jsr @HandleInput

    jmp @MainLoop


MovePlayer:
    rts

MoveCrate:
    rts

HasWon:
    rts

.include info.asm
