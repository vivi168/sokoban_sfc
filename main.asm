;**************************************
; SOKOBAN
;**************************************
.65816

.include define.inc
.include registers.inc
.include macros.inc
.include var.asm
.include assets.asm

.org 808000
.base 0000

.include vectors.asm
.include clear.asm
.include dma.asm
.include joypad.asm
.include level.asm
.include object.asm
.include hud.asm
.include music.asm
.include menu.asm

InitGame:
    sei
    ; Forced Blank
    lda #80
    sta INIDISP

    ; ---- BG settings
    lda #09             ; bg 3 high prio, mode 1
    sta BGMODE

    lda #00             ; first write = lower byte
    sta BG1HOFS         ; horizontal scroll ;
    sta BG1HOFS         ; second write = upper 2 bits
    lda #ff             ; vertical scroll. caution, offset by -1
    sta BG1VOFS
    lda #00
    sta BG1VOFS

    lda #00
    sta BG3HOFS
    sta BG3HOFS
    lda #ff
    sta BG3VOFS
    lda #00
    sta BG3VOFS

    lda #00
    sta BG12NBA         ; BG1 tiles @ VRAM[0000]

    lda #01
    sta BG34NBA         ; BG3 tiles @ VRAM[2000]

    lda #20
    sta BG1SC           ; BG1 MAP @ VRAM[4000]

    lda #24
    sta BG3SC           ; BG3 MAP @ VRAM[4800]

    lda #15             ; enable BG13 + sprites
    sta TM

    ; --- OBJ settings
    lda #62             ; sprite 16x16 small, 32x32 big
    sta OBJSEL          ; oam start @VRAM[8000]

    ;  ---- Some initialization
    jsr @SetCurrentLevel
    jsr @InitLevel

    jsr @ClearTextBuffer

    jsr @TransferBG13Buffer
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

MainLoop:
    wai

    jsr @EncodeStepCount
    jsr @PutStepCount

    jsr @HandleInput
    jsr @UpdatePlayerOamBuffer
    jsr @UpdateCratesOamBuffer


    jsr @HasWon

    jmp @MainLoop

; direction change in A
MovePlayer:
    php

    .call MX8
    pha ; save direction change
    tax
    lda @player_position
    pha ; save old player position

    txa
    clc
    adc 1,s ; new player position = direction_change + position
    sta @player_position
    tax

    ; check if land on wall
    lda @level_tiles,x
    cmp #WALL_T
    ; land on wall, reset player position
    beq @restore_player_position

    ; check if land on crate
check_crate_collide:
    ldx #ff
    lda @player_position
    jsr @IsOnCrate
    cmp #ff
    beq @increase_step_count

    ; try to move crate here
    tax ; crate index
    lda 2,s ; change of direction
    jsr @MoveCrate
    ; here, check if MoveCrate result is 0 -> exit move player
    ; if result is 1 -> restore crate position AND player position
    beq @increase_step_count

restore_player_position:
    lda 1,s
    sta @player_position
    bra @exit_move_player

increase_step_count:
    .call M16
    inc @step_count
    .call M8

exit_move_player:
    pla
    pla
    plp
    rts

; input : X -> crate index
; input : A -> change of direction
; output : A -> 0x00 = moved, 0x01 = not moved
MoveCrate:
    phx ; save crate index
    pha ; save change of direction

    lda @crate_positions,x
    pha ; save old position

    clc
    adc 2,s
    sta @crate_positions,x ; crate position += change of direction

    tax
    lda @level_tiles,x
    cmp #WALL_T
    beq @restore_crate_position

    lda 3,s
    tax
    lda @crate_positions,x
    jsr @IsOnCrate

    cmp #ff
    bne @restore_crate_position

    ldx #00 ; 00 -> moved
    bra @exit_move_crate

restore_crate_position:
    lda 3,s
    tax
    lda 1,s
    sta @crate_positions,x

    ldx #01 ; 01 -> not moved

exit_move_crate:
    pla
    pla
    pla

    txa

    rts

; input : A -> input position
; input : X -> index to ignore
; output : A -> crate index if is on crate, 0xff if is not on crate
IsOnCrate:
    phx ; save index to ignore
    pha ; save player position
    phd
    tsc
    tcd

    ; 03 -> input position
    ; 04 -> index to ignore


    ldx #00
    lda 03

is_on_crate_loop:
    ; here, ignore if x == index to ignore
    cpx 04
    beq @next_is_on_crate_loop

    cmp @crate_positions,x
    beq @exit_is_on_crate ; found, exit loop

next_is_on_crate_loop:
    inx
    cpx @crate_count
    bne @is_on_crate_loop

    ; is not on crate
    ldx #ff
exit_is_on_crate:
    pld
    pla
    pla

    txa ; return index of found crate

    rts

HasWon:
    ; here loop through crate position,
    ; increment counter if crate is on target
    ; at the end of the loop, if counter == crate_count, WON
    php

    .call MX8

    ; local stack frame
    ; 01 -> crate on target count
    tsc
    dec
    tcs
    tcd

    stz 01

    ldx #00

has_won_loop:
    lda @crate_positions,x
    phx

    tax
    lda @level_tiles,x
    cmp #TARGET_T
    bne @continue_has_won_loop

    inc 01

continue_has_won_loop:
    plx
    inx
    cpx @crate_count
    bne @has_won_loop

    lda @crate_count
    cmp 01
    bne @exit_has_won

    jmp @NextLevel

exit_has_won:
    ; restore stack frame
    tsc
    inc
    tcs

    plp

    rts

.include info.asm
