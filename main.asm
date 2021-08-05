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


    jsr @HasWon

    jmp @MainLoop

; direction change in A
MovePlayer:
    php

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
    ldx #ff
    lda @player_position
    jsr @IsOnCrate
    cmp #ff
    beq @exit_move_player

    ; try to move crate here
    tax ; crate index
    lda 2,s ; change of direction
    jsr @MoveCrate
    ; here, check if MoveCrate result is 0 -> exit move player
    ; if result is 1 -> restore crate position AND player position
    beq @exit_move_player

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
    phx ; save crate index
    pha ; save change of direction

    lda @crate_positions,x
    pha ; save old position

    clc
    adc 2,s
    sta @crate_positions,x ; crate position += change of direction

    tax
    lda @level_tiles,x
    cmp #WALL_T
    beq @restore_crate_position

    lda 3,s
    tax
    lda @crate_positions,x
    jsr @IsOnCrate

    cmp #ff
    bne @restore_crate_position

    ldx #00 ; 00 -> moved
    bra @exit_move_crate

restore_crate_position:
    lda 3,s
    tax
    lda 1,s
    sta @crate_positions,x

    ldx #01 ; 01 -> not moved

exit_move_crate:
    pla
    pla
    pla

    txa

    rts

; input : A -> input position
; input : X -> index to ignore
; output : A -> crate index if is on crate, 0xff if is not on crate
IsOnCrate:
brk 00
    phx ; save index to ignore
    pha ; save player position
    phd
    tsc
    tcd

    ; 03 -> input position
    ; 04 -> index to ignore


    ldx #00
    lda 03

is_on_crate_loop:
    ; here, ignore if x == index to ignore
    cpx 04
    beq @next_is_on_crate_loop

    cmp @crate_positions,x
    beq @exit_is_on_crate ; found, exit loop

next_is_on_crate_loop:
    inx
    cpx @crate_count
    bne @is_on_crate_loop

    ; is not on crate
    ldx #ff
exit_is_on_crate:
    pld
    pla
    pla

    txa ; return index of found crate

    rts

HasWon:
    ; here loop through crate position,
    ; increment counter if crate is on target
    ; at the end of the loop, if counter == crate_count, WON
    php

    sep #30

    ; local stack frame
    ; 01 -> crate on target count
    tsc
    dec
    tcs
    tcd

    stz 01

    ldx #00

has_won_loop:
    lda @crate_positions,x
    phx

    tax
    lda @level_tiles,x
    cmp #TARGET_T
    bne @continue_has_won_loop

    inc 01

continue_has_won_loop:
    plx
    inx
    cpx @crate_count
    bne @has_won_loop

    lda @crate_count
    cmp 01
    bne @exit_has_won

    jmp @ResetVector

exit_has_won:
    ; restore stack frame
    tsc
    inc
    tcs

    plp

    rts

.include info.asm
