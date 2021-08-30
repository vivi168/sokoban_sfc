hex_to_dec_lut:
    .db    00, 00, 01,    00, 00, 02,    00, 00, 04,    00, 00, 08
    .db    00, 00, 16,    00, 00, 32,    00, 00, 64,    00, 01, 28
    .db    00, 02, 56,    00, 05, 12,    00, 10, 24,    00, 20, 48
    .db    00, 40, 96,    00, 81, 92,    01, 63, 84,    03, 27, 68

HexToDec:                   ; http://6502.org/source/integers/hex2dec.htm
    php
    .call MX8
    sed                     ; output gets added up in decimal.

    stz @hex_to_dec_out     ; inititalize output as 0.
    stz @hex_to_dec_out+1
    stz @hex_to_dec_out+2

    ldx #2d                 ; 0x2d is 45 decimal, or 3x15 bits.
hex_to_dec_loop:
    asl @hex_to_dec_in      ; (0 to 15 is 16 bit positions.)
    rol @hex_to_dec_in+1    ; if the next highest bit was 0,
    bcc @skip_bit           ; then skip to the next bit after that.

    lda @hex_to_dec_out     ; but if the bit was 1,
    clc                     ; get ready to
    adc @hex_to_dec_lut+2,x ; add the bit value in the hex_to_dec_lut to the
    sta @hex_to_dec_out     ; output sum in decimal

    lda @hex_to_dec_out+1   ; then middle byte,
    adc @hex_to_dec_lut+1,x
    sta @hex_to_dec_out+1

    lda @hex_to_dec_out+2   ; then high byte,
    adc @hex_to_dec_lut,x   ; storing each byte
    sta @hex_to_dec_out+2   ; of the summed output in hex_to_dec_out.

skip_bit:
    dex                     ; by taking x in steps of 3, we don't have to
    dex                     ; multiply by 3 to get the right bytes from the
    dex                     ; hex_to_dec_lut.
    bpl @hex_to_dec_loop

    plp
    rts

EncodeStepCount:
    ldx @step_count
    stx @hex_to_dec_in
    jsr @HexToDec

    ; EOS
    stz @step_count_bcd+5

    ; units
    lda @hex_to_dec_out
    and #0f
    sta @step_count_bcd+4

    ; tens
    lda @hex_to_dec_out
    and #f0
    .call LSR4
    sta @step_count_bcd+3

    ; hundreds
    lda @hex_to_dec_out+1
    and #0f
    sta @step_count_bcd+2

    ; thousands
    lda @hex_to_dec_out+1
    and #f0
    .call LSR4
    sta @step_count_bcd+1

    ; ten thousands
    lda @hex_to_dec_out+2
    and #0f
    sta @step_count_bcd

    rts

ClearTextBuffer:
    php
    ; @tilemap_buffer

    .call MX16

    ldx #0000
clear_text_buffer_loop:
    lda #3000
    sta !text_buffer,x
    inx
    inx
    cpx #TILEMAP_BUFFER_SIZE
    bne @clear_text_buffer_loop

    plp
    rts

step_count_str: .db 53, 54, 45, 50, 20, 43, 4f, 55, 4e, 54, 3a, 20, 00
current_level_str: .db  00
PutStepCount:
    ldx #0000

put_string_loop:
    lda @step_count_str,x
    beq @put_step_count

    phx
    pha
    .call M16
    txa
    asl
    tax
    .call M8
    pla
    sec
    sbc #20
    sta !text_buffer,x
    plx

    inx
    bra @put_string_loop

put_step_count:
    .call M16
    txa
    asl
    tax
    .call M8
    lda @step_count_bcd
    clc
    adc #10
    sta !text_buffer,x
    inx
    inx
    lda @step_count_bcd+1
    clc
    adc #10
    sta !text_buffer,x
    inx
    inx
    lda @step_count_bcd+2
    clc
    adc #10
    sta !text_buffer,x
    inx
    inx
    lda @step_count_bcd+3
    clc
    adc #10
    sta !text_buffer,x
    inx
    inx
    lda @step_count_bcd+4
    clc
    adc #10
    sta !text_buffer,x

    rts
