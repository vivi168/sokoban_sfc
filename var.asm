.define LEVEL_W        10
.define LEVEL_H        0e
.define LEVEL_SIZE     e0
.define MAX_CRATES     1f

.org 7e0000

joy1_raw:                 .rb 2
joy1_press:               .rb 2
joy1_held:                .rb 2

current_level:            .rb 3
level_tiles:              .rb LEVEL_SIZE

crate_count:              .rb 1
crate_positions:          .rb MAX_CRATES

player_position:          .rb 1

frame_counter:            .rb 1

.org 7e2000

tilemap_buffer:           .rb 800
oam_buffer:               .rb 200         ; OAM buffer
oam_buffer_hi:            .rb 20
