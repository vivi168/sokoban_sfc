.spc700

.include registers.inc
.include macros.inc

.org 0600
.base 0000

.call SET_DSP_REG DIR, >BrrDirectory

wait:
    bra @wait

.org 5600
.base 5000

BrrDirectory:
    nop
