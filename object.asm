.define OAML_SIZE   0200
.define OAM_SIZE    0220
;**************************************
;
; clear oam buffer with off screen sprites
;
;**************************************
InitOamBuffer:
    php
    sep #20
    rep #10
    lda #00
    ldx #0000
set_x_lsb:
    sta !oam_buffer,x
    inx
    inx
    inx
    inx
    cpx #OAML_SIZE
    bne @set_x_lsb

    lda #55         ; 01010101
set_x_msb:
    sta !oam_buffer,x
    inx
    sta !oam_buffer,x
    inx
    cpx #OAM_SIZE
    bne @set_x_msb

    plp
    rts


InitPlayerOamBuffer:
    ; yyyyyyyy xxxxxxxx
    ; vhppcccn nnnnnnnn

    ; compute x/y coords
    ;x
    lda @player_position
    and #0f
    asl
    asl
    asl
    asl
    sta !oam_buffer

    ;y
    lda @player_position
    lsr
    lsr
    lsr
    lsr
    asl
    asl
    asl
    asl
    sta !oam_buffer+1

    lda #00             ; nnnnnnnn
    sta !oam_buffer+2

    lda #30             ; vhppcccn
    sta !oam_buffer+3

    ;-----
    ; oam high : size|x 9th bit
    ; sx sx sx sx

    lda #54
    sta !oam_buffer_hi

    rts


InitCratesOamBuffer:
    php

    sep #30

    ; create stack frame
    ; 01 -> crate count
    ; 02 -> crate_positions[i]
    tsc
    sec
    sbc #02
    tcs
    tcd

    lda @crate_count
    sta 01
    ldx #00

init_crates:
    lda @crate_positions,x
    sta 02

    phx
    ; ----

    txa
    inc ; player is first sprite, index starts at 1
    asl
    asl
    tax ; oam buffer idx = crate idx * 4 (oam entry is 4 bytes long)

    ; ---- set oam buffer data

    ;x
    lda 02
    and #0f
    asl
    asl
    asl
    asl
    sta !oam_buffer,x

    ;y
    lda 02
    lsr
    lsr
    lsr
    lsr
    asl
    asl
    asl
    asl
    sta !oam_buffer+1,x

    lda #02             ; nnnnnnnn
    sta !oam_buffer+2,x

    lda #30             ; vhppcccn
    sta !oam_buffer+3,x

    ; oam hi
    ; x = sprite idx

    ; oam_hi idx = x / 4 (x >> 2)
    ; oam_hi bit = x % 4 (x & 3)

    ; bit 0 -> oam[i] & 0b11_11_11_10 = (1<<0) ^ 255 (0xfe)
    ; bit 1 -> oam[i] & 0b11_11_10_11 = (1<<2) ^ 255 (0xfb)
    ; bit 2 -> oam[i] & 0b11_10_11_11 = (1<<4) ^ 255 (0xef)
    ; bit 3 -> oam[i] & 0b10_11_11_11 = (1<<6) ^ 255 (0xbf)

    ; compute bit mask
    lda 1,s ; sprite index (phx at start of loop)
    inc ; first sprite is player's
    and #03
    asl

    tay
    lda #01
    dey
    bmi @skip_shift_bit_mask

shift_bit_mask:
    asl
    dey
    bpl @shift_bit_mask
skip_shift_bit_mask:

    eor #ff

    ; compute oam_hi idx (oam_hi[idx])
    pha
    lda 2,s
    inc         ; player is first sprite
    lsr
    lsr
    tax
    pla
    and !oam_buffer_hi,x
    sta !oam_buffer_hi,x

    ; ----
    plx

    inx
    cpx 01
    bne @init_crates

    ; restore stack frame
    tsc
    clc
    adc #02
    tcs

    plp
    rts

;**************************************
; update player position
;**************************************
UpdatePlayerOamBuffer:
    ;x
    lda @player_position
    and #0f
    asl
    asl
    asl
    asl
    sta !oam_buffer

    ;y
    lda @player_position
    lsr
    lsr
    lsr
    lsr
    asl
    asl
    asl
    asl
    sta !oam_buffer+1

    rts

;**************************************
; update crates positions
;**************************************
UpdateCratesOamBuffer:
    ; here should check if crate is on target tile, if so, switches its palette
    rts
