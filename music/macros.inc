;Left channel master volume
.macro SET_MVOLL value
    mov f2,#0c
    mov f3,#%value
.endm

;Right channel master volume
.macro SET_MVOLR value
    mov f2,#1c
    mov f3,#%value
.endm

;Left channel echo volume
.macro SET_EVOLL value
    mov f2,#2c
    mov f3,#%value
.endm

;Right channel echo volume
.macro SET_EVOLR value
    mov f2,#3c
    mov f3,#%value
.endm

;Key On Flags for Voice 0..7
.macro SET_KON value
    mov f2,#4c
    mov f3,#%value
.endm

;Key Off Flags for Voice 0..7
.macro SET_KOF value
    mov f2,#5c
    mov f3,#%value
.endm

;Reset, Mute, Echo-Write Flags + Noise Clock
.macro SET_FLG value
    mov f2,#6c
    mov f3,#%value
.endm

;Voice End Flags for Voice 0..7
.macro SET_ENDX value
    mov f2,#7c
    mov f3,#%value
.endm

;Echo feedback volume
.macro SET_EFB value
    mov f2,#0d
    mov f3,#%value
.endm

;Pitch Modulation Enable Flags for Voice 1..7
.macro SET_PMON value
    mov f2,#2d
    mov f3,#%value
.endm

;Noise Enable Flags for Voice 0..7
.macro SET_NON value
    mov f2,#3d
    mov f3,#%value
.endm

;Echo Enable Flags for Voice 0..7
.macro SET_EON value
    mov f2,#4d
    mov f3,#%value
.endm

;Sample directory offset address
.macro SET_DIR value
    mov f2,#5d
    mov f3,#%value
.endm

;Echo buffer offset address
.macro SET_ESA value
    mov f2,#6d
    mov f3,#%value
.endm

;Echo delay (ring buffer size)
.macro SET_EDL value
    mov f2,#7d
    mov f3,#%value
.endm

;Echo FIR filter coefficient 0
.macro SET_FIRN value, n
    mov f2,#%n%f
    mov f3,#%value
.endm

; Voice Control (n = 0-7)
;Left volume
.macro SET_VNVOLL value, n
    mov f2,#%n%0
    mov f3,#%value
.endm

;Right volume
.macro SET_VNVOLR value, n
    mov f2,#%n%1
    mov f3,#%value
.endm

;Pitch (LSB)
.macro SET_VNPITCHL value, n
    mov f2,#%n%2
    mov f3,#%value
.endm

;Pitch (MSB)
.macro SET_VNPITCHH value, n
    mov f2,#%n%3
    mov f3,#%value
.endm

;Source number
.macro SET_VNSRCN value, n
    mov f2,#%n%4
    mov f3,#%value
.endm

;ADSR settings 1
.macro SET_VNADSR1 value, n
    mov f2,#%n%5
    mov f3,#%value
.endm

;ADSR settings 2
.macro SET_VNADSR2 value, n
    mov f2,#%n%6
    mov f3,#%value
.endm

;Gain settings
.macro SET_VNGAIN value, n
    mov f2,#%n%7
    mov f3,#%value
.endm

;Current envelope value
.macro SET_VNENVX value, n
    mov f2,#%n%8
    mov f3,#%value
.endm

;Current sample value
.macro SET_VNOUTX value, n
    mov f2,#%n%9
    mov f3,#%value
.endm
