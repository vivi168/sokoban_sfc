.org 818000
.base 8000

tileset:                  .incbin assets/tileset.bin
tileset_palette:          .incbin assets/tileset-pal.bin
spritesheet:              .incbin assets/sprites.bin
spritesheet_pal:          .incbin assets/sprites-pal.bin
level1:                   .incbin assets/level1.txt
level2:                   .incbin assets/level2.txt
level3:                   .incbin assets/level3.txt

level_lut:
           .db ^level1
level1_lu: .db @level1
level2_lu: .db @level2
level3_lu: .db @level3

.define TILEMAP_BUFFER_SIZE 0800
.define TILESET_SIZE 00c0
.define SPRTSHT_SIZE 0400
.define PALETTE_SIZE 20
