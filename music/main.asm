.spc700

.include registers.inc
.include macros.inc

.org 0600
.base 0000

.call SET_DSP_REG FIR6, 20
.call SET_DSP_REG V4ENVX, 20

wait:
    bra @wait
