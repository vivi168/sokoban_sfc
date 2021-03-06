.macro M8
    sep #20
.endm

.macro X8
    sep #10
.endm

.macro M16
    rep #20
.endm

.macro X16
    rep #10
.endm

.macro MX8
    sep #30
.endm

.macro MX16
    rep #30
.endm

; multiply by 16
.macro ASL4
    asl
    asl
    asl
    asl
.endm

; multiply by 32
.macro ASL5
    asl
    asl
    asl
    asl
    asl
.endm

; divide by 16
.macro LSR4
    lsr
    lsr
    lsr
    lsr
.endm

.macro VRAM_DMA_TRANSFER dest_addr, src_addr, nb_bytes
    ldx #%dest_addr
    stx VMADDL

    lda #18             ; VMDATAL 21*18*
    sta BBAD0

    ldx #@%src_addr
    stx A1T0L
    lda #^%src_addr
    sta A1T0B

    ldx #%nb_bytes
    stx DAS0L

    lda #01
    sta DMAP0

    lda #01
    sta MDMAEN
.endm

.macro CGRAM_DMA_TRANSFER dest_addr, src_addr, nb_bytes
    lda #%dest_addr
    sta CGADD

    lda #22             ; CGDATA 21*22*
    sta BBAD0

    ldx #@%src_addr
    stx A1T0L
    lda #^%src_addr
    sta A1T0B

    lda #%nb_bytes
    sta DAS0L

    lda #00
    sta DMAP0

    lda #01
    sta MDMAEN
.endm

.macro WRAM_DMA_TRANSFER upper, dest_addr, src_addr, nb_bytes
    ldx #%dest_addr
    stx WMADDL

    lda #%upper
    sta WMADDH

    lda #80             ; WMDATA 21*80*
    sta BBAD0

    ldx #@%src_addr
    stx A1T0L
    lda #^%src_addr
    sta A1T0B

    ldx #%nb_bytes
    stx DAS0L

    lda #00
    sta DMAP0

    lda #01
    sta MDMAEN
.endm
