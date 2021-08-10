.org 818000
.base 8000

tileset:                  .incbin assets/tileset.bin
font8x8:                  .incbin assets/8x8font.bin
tileset_palette:          .incbin assets/tileset-pal.bin
font8x8_palette:          .incbin assets/8x8font-pal.bin

spritesheet:              .incbin assets/sprites.bin
spritesheet_pal:          .incbin assets/sprites-pal.bin
                          .incbin assets/sprites-b-pal.bin

level1:                   .incbin levels/level1.txt
                          .db 00
level2:                   .incbin levels/level2.txt
                          .db 00
level3:                   .incbin levels/level3.txt
                          .db 00
level4:                   .incbin levels/level4.txt
                          .db 00
level5:                   .incbin levels/level5.txt
                          .db 00
level6:                   .incbin levels/level6.txt
                          .db 00
level7:                   .incbin levels/level7.txt
                          .db 00
level8:                   .incbin levels/level8.txt
                          .db 00
level9:                   .incbin levels/level9.txt
                          .db 00
level10:                  .incbin levels/level10.txt
                          .db 00

default_level_count:      .db 0a

level_bank:
           .db ^level1
level_lut:
           .db @level1
           .db @level2
           .db @level3
           .db @level4
           .db @level5
           .db @level6
           .db @level7
           .db @level8
           .db @level9
           .db @level10

.define TILEMAP_BUFFER_SIZE 0800
.define TILESET_SIZE 00c0
.define TILE_PAL_SIZE 28
.define FONT_SIZE 0600
.define SPRTSHT_SIZE 0400
.define PALETTES_SIZE 40
