.spc700

.include macros.inc

.org 0600
.base 0000

.call SET_FIRN 20, 6
.call SET_VNENVX 20, 4

wait:
    bra @wait
