.define STACK_SIZE 1fff

ResetVector:
    sei                 ; disable interrupts
    clc
    xce
    cld
    jmp !FastReset
FastReset:
    sep #20             ; M8
    rep #10             ; X16

    ldx #STACK_SIZE
    txs                 ; set stack pointer to 1fff

    lda #01
    sta @MEMSEL

    ; Forced Blank
    lda #80
    sta INIDISP
    jsr @ClearRegisters

    ;  ---- Some initialization
    ; store current level address
    ldx #@level1            ; LL HH
    stx @current_level
    lda #^level1            ; BB
    sta @current_level+2

    jsr @ResetLevel
    jsr @ReadLevel
    jsr @ResetTilemapBuffer
    jsr @InitTilemapBuffer

    ; ---- BG settings
    lda #01
    sta BGMODE

    lda #00    ; first write = lower byte
    sta BG1HOFS         ; horizontal scroll ;
    sta BG1HOFS         ; second write = upper 2 bits
    lda #00             ; vertical scroll. caution, offset by -1
    sta BG1VOFS
    lda #00
    sta BG1VOFS

    lda #20             ; BG1 MAP @ VRAM[4000]
    sta BG1SC
    lda #00             ; BG1 tiles @ VRAM[0000]
    sta BG12NBA

    lda #11             ; enable BG1 + sprites
    sta TM

    ; --- OBJ settings
    lda #62             ; sprite 16x16 small, 32x32 big
    sta OBJSEL          ; oam start @VRAM[8000]

    jsr @InitOamBuffer
    jsr @TransferOamBuffer

    ; ---- DMA transfers ---
    ; Copy tilemap buffer to VRAM
    tsx                 ; save stack pointer
    pea 2000            ; vram dest addr (@4000 really, word steps)
    pea @tilemap_buffer
    lda #^tilemap_buffer
    pha
    pea TILEMAP_BUFFER_SIZE    ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset.bin to VRAM
    tsx                 ; save stack pointer
    pea 0000            ; vram dest addr (@0000 really, word steps)
    pea @tileset
    lda #^tileset
    pha
    pea TILESET_SIZE    ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset-pal.bin to CGRAM
    tsx                 ; save stack pointer
    lda #00             ; cgram dest addr (@0000 really, 2 bytes step)
    pha
    pea @tileset_palette
    lda #^tileset_palette
    pha
    ; TODO allow for more than $ff bytes
    lda #ff   ; bytes_to_trasnfer
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

    ; Copy spritesheet-pal.bin to CGRAM
    tsx                 ; save stack pointer
    lda #80             ; cgram dest addr (@CGRAM[0100] really, 2 bytes step)
    pha
    pea @spritesheet_pal
    lda #^spritesheet_pal
    pha
    lda #PALETTE_SIZE   ; bytes_to_trasnfer
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
    rep #30
    pha
    phx
    phy

    sep #20
    rep #10

    lda RDNMI

    inc @frame_counter

    ; Copy tilemap buffer to VRAM
    tsx                 ; save stack pointer
    pea 2000            ; vram dest addr (@4000 really, word steps)
    pea @tilemap_buffer
    lda #^tilemap_buffer
    pha
    pea TILEMAP_BUFFER_SIZE    ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    jsr @TransferOamBuffer

    jsr @ReadJoyPad1

    rep #30
    ply
    plx
    pla
    plp
    rti
