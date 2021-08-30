.org 7e0000

joy1_raw:                 .rb 2
joy1_press:               .rb 2
joy1_held:                .rb 2

current_level:            .rb 3
level_no:                 .rb 1
level_count:              .rb 1
level_tiles:              .rb LEVEL_SIZE

player_position:          .rb 1
crate_positions:          .rb MAX_CRATES
crate_count:              .rb 1

step_count:               .rb 2
step_count_bcd:           .rb 6

frame_counter:            .rb 1

horizontal_offset:        .rb 1
vertical_offset:          .rb 1

hex_to_dec_in:            .rb 2
hex_to_dec_out:           .rb 3

.org 7e2000

bg_buffers:
tilemap_buffer:           .rb 800
text_buffer:              .rb 800
oam_buffer:               .rb 200         ; OAM buffer
oam_buffer_hi:            .rb 20
