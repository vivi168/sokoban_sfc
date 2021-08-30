ResetVector:
    sei                 ; disable interrupts
    clc
    xce
    cld
    jmp !FastReset
FastReset:
    .call M8
    .call X16

    ldx #STACK_TOP
    txs                 ; set stack pointer to 1fff

    lda #01
    sta MEMSEL

    ; Forced Blank
    lda #80
    sta INIDISP
    jsr @ClearRegisters

    jmp @InitMenu

BreakVector:
    rti

NmiVector:
    php
    .call MX16
    pha
    phx
    phy

    .call M8
    .call X16

    lda RDNMI

    inc @frame_counter

    lda @horizontal_offset
    eor #ff
    inc                         ; two's complement trick
    sta BG1HOFS
    lda #00
    sta BG1HOFS

    lda @vertical_offset
    eor #ff
    sta BG1VOFS
    lda #00
    sta BG1VOFS

    jsr @TransferBG13Buffer
    jsr @TransferOamBuffer

    jsr @ReadJoyPad1

    .call MX16
    ply
    plx
    pla
    plp
    rti
