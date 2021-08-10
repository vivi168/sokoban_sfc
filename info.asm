;**************************************
; ROM registration data
;**************************************
.org ffb0
.base 7fb0

; zero bytes
    .db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
; game title "SOKOBAN              "
    .db 53,4f,4b,4f,42,41,4e,20,20,20,20,20,20,20,20,20,20,20,20,20,20
; map mode
    .db 30
; cartridge type
    .db 00
; ROM size
    .db 09
; RAM size
    .db 01
; destination code
    .db 00
; fixed value
    .db 33
; mask ROM version
    .db 00
; checksum complement
    .db 00,00
; checksum
    .db 00,00

;**************************************
; Vectors
;**************************************
.org ffe0
.base 7fe0

; zero bytes
    .db 00,00,00,00
; 65816 mode
    .db 00,00           ; COP
    .db @BreakVector    ; BRK
    .db 00,00
    .db @NmiVector      ; NMI
    .db 00,00
    .db 00,00           ; IRQ

; zero bytes
    .db 00,00,00,00
; 6502 mode
    .db 00,00           ; COP
    .db 00,00
    .db 00,00
    .db 00,00           ; NMI
    .db @ResetVector    ; RESET
    .db 00,00           ; IRQ/BRK
