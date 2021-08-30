InitMenu:
    lda #01             ; bg 3 high prio, mode 1
    sta BGMODE

    lda #00             ; first write = lower byte
    sta BG1HOFS         ; horizontal scroll ;
    sta BG1HOFS         ; second write = upper 2 bits
    lda #ff             ; vertical scroll. caution, offset by -1
    sta BG1VOFS
    lda #00
    sta BG1VOFS

    lda #00
    sta BG12NBA         ; BG1 tiles @ VRAM[0000]
    lda #20
    sta BG1SC           ; BG1 MAP @ VRAM[4000]

    lda #01             ; enable BG1
    sta TM

    .call WRAM_DMA_TRANSFER 00, @tilemap_buffer, menu_map, MENU_MAP_SIZE
    .call VRAM_DMA_TRANSFER 0000, menu_tiles, MENU_TILES_SIZE
    .call CGRAM_DMA_TRANSFER 00, menu_palette, MENU_PAL_SIZE

    ; maybe wait for DMA transfer to complete ?
    ; maybe dma using different channel for each call ?
    jsr @TransferBG13Buffer
    jsr @SpcUploadRoutine

    lda #0f             ; release forced blanking, set screen to full brightness
    sta INIDISP

    lda #81             ; enable NMI, turn on automatic joypad polling
    sta NMITIMEN
    cli                 ; enable interrupts

MenuLoop:
    wai

    lda @joy1_press+1
    bit #JOY_START
    bne @init_game

    jmp @MenuLoop

init_game:
    brk 00
    jmp @InitGame
