.define STACK_TOP 1fff

.define TILEMAP_BUFFER_SIZE 0800
.define BG_BUFFERS_SIZE 1000
.define TILESET_SIZE 00c0
.define TILE_PAL_SIZE 28
.define FONT_SIZE 0600
.define SPRTSHT_SIZE 0400
.define PALETTES_SIZE 40

; joypad
.define JOY_UP      0800
.define JOY_DOWN    0400
.define JOY_LEFT    0200
.define JOY_RIGHT   0100
.define JOY_SELECT  2000

; GROUND = 00, TARGET = 01 02 03 04, WALL = 05
; tile definition in level.txt
.define GROUND_CHAR   20 ; \s
.define TARGET_CHAR   2e ; .
.define TARGET_PCHAR  2b ; + (player starts on a target)
.define TARGET_CCHAR  2a ; * (crate starts on a target)
.define WALL_CHAR     23 ; #
.define CRATE_CHAR    24 ; $
.define PLAYER_CHAR   40 ; @
.define NEWLINE_CHAR  0a ; \n

; tiles enum
.define GROUND_T 00
.define TARGET_T 01
.define WALL_T   02

.define OAML_SIZE   0200
.define OAM_SIZE    0220

.define LEVEL_W        10
.define LEVEL_H        0e
.define LEVEL_SIZE     e0
.define MAX_CRATES     1f

.define SPC_ROM_SIZE 000e
