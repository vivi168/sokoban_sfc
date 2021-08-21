.define STACK_TOP 1fff

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

    ; Copy tileset.bin to VRAM
    tsx                 ; save stack pointer
    pea 0000            ; vram dest addr (@0000 really, word steps)
    pea @tileset
    lda #^tileset
    pha
    pea TILESET_SIZE    ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset.bin to VRAM
    tsx                 ; save stack pointer
    pea 1000            ; vram dest addr (@2000 really, word steps)
    pea @font8x8
    lda #^font8x8
    pha
    pea FONT_SIZE    ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs

    ; Copy tileset-pal.bin + font8x8-pal.bin to CGRAM
    tsx                 ; save stack pointer
    lda #00             ; cgram dest addr (@0000 really, 2 bytes step)
    pha
    pea @tileset_palette
    lda #^tileset_palette
    pha
    lda #TILE_PAL_SIZE   ; bytes_to_trasnfer
    pha
    jsr @CgramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy spritesheet.bin to VRAM
    tsx             ; save stack pointer
    pea 4000        ; vram_dest_addr
    pea @spritesheet
    lda #^spritesheet
    pha
    pea SPRTSHT_SIZE; bytes_to_trasnfer
    jsr @VramDmaTransfer
    txs             ; restore stack pointer

    ; Copy sprites-pal.bin + sprites-b-pal to CGRAM
    tsx                 ; save stack pointer
    lda #80             ; cgram dest addr (@CGRAM[0100] really, 2 bytes step)
    pha
    pea @spritesheet_pal
    lda #^spritesheet_pal
    pha
    lda #PALETTES_SIZE   ; bytes_to_trasnfer
    pha
    jsr @CgramDmaTransfer
    txs                 ; restore stack pointer

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
