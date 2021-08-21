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
