; tilemap format
; tile number lowest 8 bits
; vert flip | hori flip | prio bit | pal no H | pal no M | pal no L | tile number 10th bit | tile number 9th bit
; 0 0 0 0 0 0 0 0
; 0 0 0 000 0 0
; GROUND = 00, TARGET = 01 02 03 04, WALL = 05

.define GROUND   20 ; \s
.define TARGET   2e ; .
.define WALL     23 ; #
.define PLAYER   40 ; @
.define CRATE    24 ; $

.define LV_W     10
.define LV_H     0e
.define LV_S     e0

.define TILEMAP_SIZE 400

InitTilemapBuffer:
    php
    ; @tilemap_buffer

    rep #30

    ldx #00
clear_buffer_loop:
    ; TODO replace with DMA?
    lda #0000; 000
    sta !tilemap_buffer,x
    inx
    cpx #TILEMAP_BUFFER_SIZE
    bne @clear_buffer_loop

    ; ---- Read level
    jsr @ReadLevel

    plp
    rts

ReadLevel:
    php
    phd
    ; here build map from level.txt
    sep #20
    ; local stack frame
    ; reserve 4 bytes
    ; 01 -> current tile
    ; 02 -> curent_level low
    ; 03 -> current_level high
    ; 04 -> current_level bank
    ; 05/06 -> calculation result
    tsc
    sec
    sbc #06
    tcs
    tcd

    ldx @current_level
    stx 02
    lda @current_level+2
    sta 04

    brk 00

    ldy #0000
read_lv_loop:
    ; read tile from current_level
    lda [02],y
    sta 01

    rep #20
    ; x = i & 15
    tya
    and #000f
    ; y = i >> 4


    ; determine tile no

    ; first index = [x + (y << 5)] << 2
    ; second index = first + 2
    ; third index = first + 64
    ; fourth index = thrid + 2
    sep #20

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
