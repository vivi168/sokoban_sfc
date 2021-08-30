.org 818000
.base 8000

menu_tiles:               .incbin assets/menu.bin
menu_palette:             .incbin assets/menu-pal.bin
menu_map:                 .incbin assets/menu-map.bin

tileset:                  .incbin assets/tileset.bin
font8x8:                  .incbin assets/8x8font.bin
bg13_palettes:
tileset_palette:          .incbin assets/tileset-pal.bin
font8x8_palette:          .incbin assets/8x8font-pal.bin

spritesheet:              .incbin assets/sprites.bin
spritesheet_pal:          .incbin assets/sprites-pal.bin
                          .incbin assets/sprites-b-pal.bin
.include levels.asm
