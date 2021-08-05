; tilemap format
; tile number lowest 8 bits
; vert flip | hori flip | prio bit | pal no H | pal no M | pal no L | tile number 10th bit | tile number 9th bit
; 0 0 0 0 0 0 0 0
; 0 0 0 000 0 0
; GROUND = 00, TARGET = 01 02 03 04, WALL = 05

; tile definition in level.txt
; should replace char by 0, 1, 2, 3... to be able to have a look up table and spare cycles
; python script to convert txt level to bin
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

; ************
; Construct level_tiles array, init player and crates positions
; from level file definition
; ************
ReadLevel:
    php
    phd
    sep #20 ; A 8
    ; local stack frame
    ; reserve 6 bytes
    ; 01 -> current tile char
    ; 02 -> curent_level low
    ; 03 -> current_level high
    ; 04 -> current_level bank
    ; 05 -> index in level_tile array
    ; 06 -> length of current line
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
    stz @crate_count

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
    bra @unknown_tile

is_wall:
    cmp #WALL_CHAR
    bne @is_crate

    ldx 05
    lda #WALL_T
    sta @level_tiles,x
    bra @unknown_tile

is_crate:
    cmp #CRATE_CHAR
    bne @is_player

    ldx @crate_count
    lda 05
    sta @crate_positions,x
    inc @crate_count
    bra @unknown_tile

is_player:
    cmp #PLAYER_CHAR
    bne @is_newline

    lda 05
    sta @player_position
    bra @unknown_tile

is_newline:
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

; ************
; Reset tile map buffer to empty tiles (GROUND)
; ************
ResetTilemapBuffer:
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

; ************
; Construct level_tiles array, init player and crates positions
; from level file definition
; ************
InitTilemapBuffer:
    php
    phd

    sep #30
    ; reserve bytes on stack
    ; 01/02 first tile
    ; 03/04 second tile
    ; 05/06 third tile
    ; 07/08 fourth tile
    tsc
    sec
    sbc #08
    tcs
    tcd

    ; set tiles data here
    ldy #00 ; X 8
set_tiles_loop:
    ; compute coordinates here
    rep #30

    tya
    ; y = i // 16
    lsr
    lsr
    lsr
    lsr
    ; y *= 32
    asl
    asl
    asl
    asl
    asl

    sta 01
    tya
    ; x = i % 16
    and #000f

    ; i = y + x
    clc
    adc 01

    ; i *= 4
    asl
    asl

    sta 01      ; first = i
    clc
    adc #0002
    sta 03      ; second = first + 2
    clc
    adc #003e
    sta 05      ; third = first + 64
    clc
    adc #0002
    sta 07      ; fourth = third + 2

    sep #30
    lda @level_tiles,y
    asl
    tax
    jmp (@tile_lut,x)

; -----
continue_set_tile_loop:
    sep #30
    iny
    cpy #LEVEL_SIZE
    bne @set_tiles_loop

    ; restore stack frame
    tsc
    clc
    adc #08
    tcs

    pld
    plp
    rts

process_ground:
    jmp @continue_set_tile_loop
process_target:
    rep #30

    lda #0001
    ldx 01
    sta !tilemap_buffer,x

    lda #0002
    ldx 03
    sta !tilemap_buffer,x

    lda #0003
    ldx 05
    sta !tilemap_buffer,x

    lda #0004
    ldx 07
    sta !tilemap_buffer,x

    jmp @continue_set_tile_loop
process_wall:
    rep #30

    lda #0005

    ldx 01
    sta !tilemap_buffer,x
    ldx 03
    sta !tilemap_buffer,x
    ldx 05
    sta !tilemap_buffer,x
    ldx 07
    sta !tilemap_buffer,x

    jmp @continue_set_tile_loop

tile_lut:
ground_lu: .db @process_ground
target_lu: .db @process_target
wall_lu:   .db @process_wall

SetCurrentLevel:
    php
    phb


    lda !level_bank
    pha
    plb

    sta @current_level+2

    rep #20
    lda @level_no
    and #00ff
    asl
    tax
    lda @level_lut+1,x
    sta @current_level

    plb
    plp
    rts

InitLevel:
    rep #20
    stz @step_count
    sep #20

    jsr @ResetLevel
    jsr @ReadLevel
    jsr @ResetTilemapBuffer
    jsr @InitTilemapBuffer

    jsr @InitOamBuffer
    jsr @InitPlayerOamBuffer
    jsr @InitCratesOamBuffer

    rts

NextLevel:
    sep #20
    rep #10
    inc @level_no

    jsr @SetCurrentLevel
    jsr @InitLevel

    jmp @MainLoop

PrevLevel:
    sep #20
    rep #10
    dec @level_no

    jsr @SetCurrentLevel
    jsr @InitLevel

    jmp @MainLoop

RestartLevel:
    sep #20
    rep #10
    jsr @InitLevel
    jmp @MainLoop
