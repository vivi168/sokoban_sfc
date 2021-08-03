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
    jsr @UpdatePlayerOamBuffer
    jsr @UpdateCratesOamBuffer

    jmp @MainLoop

; direction change in A
MovePlayer:
    php
    brk 00

    sep #30
    tax
    lda @player_position
    pha ; save old player position

    txa
    clc
    adc 1,s ; new player position = direction_change + position
    sta @player_position
    tax

    ; check if land on wall
    lda @level_tiles,x
    cmp #WALL_T
    ; land on wall, reset player position
    beq @restore_player_position

    ; check if land on crate
check_crate_collide:
    nop

    ; moved cleanly
    bra @exit_move_player

restore_player_position:
    lda 1,s
    sta @player_position

exit_move_player:
    pla
    plp
    rts

MoveCrate:
    rts

HasWon:
    rts

.include info.asm
