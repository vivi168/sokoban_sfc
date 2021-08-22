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

    ; ---- BG settings
    lda #01
    sta BGMODE

    lda #00             ; first write = lower byte
    sta BG1HOFS         ; horizontal scroll ;
    sta BG1HOFS         ; second write = upper 2 bits
    lda #ff             ; vertical scroll. caution, offset by -1
    sta BG1VOFS
    lda #00
    sta BG1VOFS

    lda #20             ; BG1 MAP @ VRAM[4000]
    sta BG1SC
    lda #00             ; BG1 tiles @ VRAM[0000]
    sta BG12NBA

    lda #30
    sta BG3SC
    lda #10
    sta BG34NBA


    lda #11             ; enable BG1 + sprites
    sta TM

    ; --- OBJ settings
    lda #62             ; sprite 16x16 small, 32x32 big
    sta OBJSEL          ; oam start @VRAM[8000]

    ;  ---- Some initialization
    jsr @SetCurrentLevel
    jsr @InitLevel

    jsr @TransferBG1Buffer
    jsr @TransferOamBuffer

    .call VRAM_DMA_TRANSFER 0000, tileset, TILESET_SIZE
    .call VRAM_DMA_TRANSFER 1000, font8x8, FONT_SIZE            ; VRAM[0x2000] (word step)
    .call VRAM_DMA_TRANSFER 4000, spritesheet, SPRTSHT_SIZE     ; VRAM[0x8000] (word step)

    .call CGRAM_DMA_TRANSFER 00, tileset_palette, TILE_PAL_SIZE
    .call CGRAM_DMA_TRANSFER 80, spritesheet_pal, PALETTES_SIZE ; CGRAM[0x100] (word step)

    ; ----

    lda #0f             ; release forced blanking, set screen to full brightness
    sta INIDISP

    lda #81             ; enable NMI, turn on automatic joypad polling
    sta NMITIMEN
    cli                 ; enable interrupts

    jmp @MainLoop

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

    jsr @TransferBG1Buffer
    jsr @TransferOamBuffer

    jsr @ReadJoyPad1

    .call MX16
    ply
    plx
    pla
    plp
    rti
