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
    pha ; save direction change
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
    lda @player_position
    jsr @IsOnCrate
    cmp #ff
    beq @exit_move_player

    ; try to move crate here
    tax
    lda 2,s
    jsr @MoveCrate
    ; here, check if MoveCrate result is 0 -> exit move player
    ; if result is 1 -> restore crate position AND player position
    bra @exit_move_player

restore_player_position:
    lda 1,s
    sta @player_position

exit_move_player:
    pla
    pla
    plp
    rts

; input : X -> crate index
; input : A -> change of direction
; output : A -> 0x00 = moved, 0x01 = not moved
MoveCrate:
    clc
    adc @crate_positions,x
    sta @crate_positions,x

    rts

; input : A -> player position
; output : A -> crate index if is on crate, 0xff if is not on crate
IsOnCrate:
    ldx #00

is_on_crate_loop:
    cmp @crate_positions,x
    beq @is_on_crate ; found, exit loop

    inx
    cpx @crate_count
    bne @is_on_crate_loop

    ; is not on crate
    lda #ff
    bra @exit_is_on_crate

is_on_crate:
    txa

exit_is_on_crate:
    rts

HasWon:
    rts

.include info.asm
