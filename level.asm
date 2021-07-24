; tilemap format
; tile number lowest 8 bits
; vert flip | hori flip | prio bit | pal no H | pal no M | pal no L | tile number 10th bit | tile number 9th bit
; 0 0 0 0 0 0 0 0
; 0 0 0 000 0 0
; GROUND = 00, TARGET = 01 02 03 04, WALL = 05

; tile definition in level.txt
.define GROUND_CHAR   20 ; \s
.define TARGET_CHAR   2e ; .
.define WALL_CHAR     23 ; #
.define CRATE_CHAR    24 ; $
.define PLAYER_CHAR   40 ; @
.define NEWLINE_CHAR  0a ; \n

; tiles enum
.define GROUND_T 00
.define TARGET_T 01
.define WALL_T   02

.define TILEMAP_SIZE 400

InitTilemapBuffer:
    php
    ; @tilemap_buffer

    rep #30 ; A X 16

    ldx #0000
clear_buffer_loop:
    ; TODO replace with DMA?
    lda #0000
    sta !tilemap_buffer,x
    inx
    cpx #TILEMAP_BUFFER_SIZE
    bne @clear_buffer_loop

    plp
    rts

ResetLevel:
    php

    sep #30
    lda #GROUND_T
    ldx #00

reset_level_loop:
    sta @level_tiles,x

    inx
    cpx #LEVEL_SIZE
    bne @reset_level_loop

    plp
    rts


ReadLevel:
    php
    phd
    ; here build map from level.txt
    sep #20 ; A 8
    ; local stack frame
    ; reserve 6 bytes
    ; 01 -> current tile
    ; 02 -> curent_level low
    ; 03 -> current_level high
    ; 04 -> current_level bank
    ; 05 -> i
    ; 06 -> l
    tsc
    sec
    sbc #06
    tcs
    tcd

    ldx @current_level
    stx 02
    lda @current_level+2
    sta 04

    stz 05
    stz 06

    sep #10 ; X 8

    ldy #00
read_lv_loop:
    ; read tile from current_level
    lda [02],y
    sta 01

;-----
    cmp #TARGET_CHAR
    bne @is_wall

    ldx 05
    lda #TARGET_T
    sta @level_tiles,x

is_wall:
    lda 01
    cmp #WALL_CHAR
    bne @is_crate

    ldx 05
    lda #WALL_T
    sta @level_tiles,x

is_crate:
    lda 01
    cmp #CRATE_CHAR
    bne @is_player

    ldx @crate_count
    lda 05
    sta @crate_positions,x
    inc @crate_count

is_player:
    lda 01
    cmp #PLAYER_CHAR
    bne @is_newline

    lda 05
    sta @player_position

is_newline:
    lda 01
    cmp #NEWLINE_CHAR
    bne @unknown_tile

    ; i += LEVEL_W - l;
    lda #LEVEL_W
    sec
    sbc 06
    clc
    adc 05
    sta 05
    ; l = 0
    stz 06
    bra @read_next_tile

unknown_tile:
    inc 05
    inc 06

;-----
read_next_tile:
    iny
    lda 01  ; \0 -> end of file
    bne @read_lv_loop

    ; restore stack frame
    tsc
    clc
    adc #06
    tcs

    pld
    plp
    rts

LevelToBuffer:
    rts
