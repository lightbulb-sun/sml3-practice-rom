BGP                             equ     $ff47
OBP0                            equ     $ff48
OBP1                            equ     $ff49
LCDC                            equ     $ff40

NR50                            equ     $ff24
NR51                            equ     $ff25
NR52                            equ     $ff26

CUR_ROM_BANK                    equ     $a8c5
SELECT_ROM_BANK                 equ     $2100

BIT_BUTTON_A                    equ     0
BIT_BUTTON_B                    equ     1
BIT_BUTTON_SELECT               equ     2
BIT_BUTTON_START                equ     3
BIT_BUTTON_RIGHT                equ     4
BIT_BUTTON_LEFT                 equ     5
BIT_BUTTON_UP                   equ     6
BIT_BUTTON_DOWN                 equ     7

MY_ROM_BANK                     equ     17

NUM_LINES                       equ     18

SPRITE_BUFFER                   equ     $af00
MY_SPRITES                      equ     $8d00
NUM_SPRITES                     equ     3

MAX_NUM_LEVELS                  equ     8

TILE_EMPTY                      equ     $bf
TILE_CURSOR_INACTIVE            equ     $d0
TILE_CURSOR_ACTIVE              equ     $d1
TILE_LINE                       equ     $d2
TILE_VERSION_1                  equ     $d3
TILE_VERSION_2                  equ     $d4
TILE_VERSION_3                  equ     $d5
TILE_ZERO                       equ     $a0
TILE_A                          equ     $80

CURSOR_TOP_Y                    equ     $48
CURSOR_WORLD_X                  equ     $08
CURSOR_LEVEL_X                  equ     $48
CURSOR_POWERUP_X                equ     $70

INITIAL_CURSOR_X                equ     CURSOR_WORLD_X
INITIAL_CURSOR_Y                equ     CURSOR_TOP_Y

CATEGORY_WORLD                  equ     0
CATEGORY_LEVEL                  equ     1
CATEGORY_POWERUP                equ     2

NUMBERS_X                       equ     $50
NUMBERS_Y                       equ     $48
NUM_NUMBERS                     equ     7

SPRITE_VISIBLE                  equ     $00
SPRITE_INVISIBLE                equ     $10

JOYPAD_0                        equ     $ff80
JOYPAD_1                        equ     $ff81

FUNC_READ_JOYPAD                equ     $11f0

DEVELOPER_DEBUG_MODE            equ     $a8c7
CUR_ROM_STATE                   equ     $a9d7
CUR_GAME_STATE                  equ     $a8c3
NUM_LIVES                       equ     $a809
WAYPOINT                        equ     $a804
TMP_WAYPOINT                    equ     $a7a0
CUR_POWERUP                     equ     $a80a

NUM_WORLDS                      equ     7
NUM_POWERUPS                    equ     5

V_A                             equ     $80
V_B                             equ     $c0

COPY8                           equ     $127f



SECTION "protected1", ROM0[$0100]
        nop

SECTION "overwrite_paused_game", ROMX[$403b], BANK[5]
        call    my_paused_game

SECTION "overwrite_soft_reset_block", ROM0[$02b7]
        nop
        nop

SECTION "overwrite_entry", ROM0[$0101]
        call    init_variables

SECTION "overwrite_lcdc_on", ROM0[$0217]
        nop
        nop

SECTION "skip_title_screen", ROM0[$02a9]
        call    jump_my_save_file_screen

SECTION "jumps1", ROM0[$004b]
init_variables:
        ld      a, $0a
        ld      [$0000], a

        xor     a
        ld      [selected_world], a
        ld      [selected_level], a
        ld      [selected_powerup], a
        ld      [cur_category], a
        ld      a, 6
        ld      [cur_num_levels], a

        ; replace original instruction
        jp      $150
        ret

my_paused_game::
        ld      a, [JOYPAD_0]
        bit     BIT_BUTTON_SELECT, a
        jr      z, .cont
.exit_level
        ld      a, 1
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        call    $43cf 
        ld      a, 5
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        ld      [CUR_GAME_STATE], a

.cont
        ; replace original instruction
        ld      hl, $9c2f
        ret

skip_title_screen:
        ld      a, 2
        ld      [$a9d7], a
        ret

start_level:
        ld      a, 1
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        call    $74ae

        ld      a, $99
        ld      [NUM_LIVES], a
        ld      a, [selected_powerup]
        ld      [CUR_POWERUP], a
        ld      a, [cur_waypoint]
        ld      [WAYPOINT], a
        ld      [TMP_WAYPOINT], a
        ld      a, 1
        ld      [$a7a1], a
        ld      a, 1
        ld      [CUR_GAME_STATE], a

        ret

jump_my_save_file_screen:
        ; replace original instruction
        ld      [CUR_ROM_STATE], a

.wait_for_vblank
        halt
        nop

        xor     a
        ld      [LCDC], a

        ld      a, 6
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        call    $40b6

        ld      a, MY_ROM_BANK
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        call    my_save_file_screen

        ld      a, 1
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        jp      start_level

        ret

SECTION "code1", ROMX[$5c00], BANK[MY_ROM_BANK]
my_save_file_screen:
        xor     a
        ld      [LCDC], a
        ;call    init_variables
        call    fix_palette
        call    clear_oam
        call    copy_my_sprites
        call    print_screen
        call    print_version
        call    init_cursors
        call    update_level_numbers
        call    fix_screen_scroll
        call    turn_on_lcdc
        ei
        call    main_loop
        ret


main_loop::
        call    FUNC_READ_JOYPAD
        ld      a, [JOYPAD_1]
        bit     BIT_BUTTON_START, a
        jr      z, .cont
.start_level
        call    level_to_waypoint
        call    create_savefile
        call    load_savefile
        ld      a, $ff
        ld      [NR52], a
        ret
.cont
        call    process_dpad
        halt
        jr      main_loop


load_savefile::
        ld      hl, savefile
        ld      de, $a000
        ld      b, 24
        call    COPY8
        ret


create_savefile::
        ld      hl, $a804
        ld      b, 20
        xor     a
.loop
        ld      [hl+], a
        dec     b
        jr      nz, .loop

        ld      a, $99
        ld      [NUM_LIVES], a
        ld      a, [cur_waypoint]
        ld      [WAYPOINT], a
        ld      [TMP_WAYPOINT], a
        ld      a, [selected_powerup]
        ld      [CUR_POWERUP], a

        ld      a, 7
        ld      [$a80a], a

        ret


level_to_waypoint::
        ld      hl, waypoint_table
        ld      a, [selected_world]
        sla     a
        sla     a
        sla     a
        ld      d, 0
        ld      e, a
        add     hl, de
        ld      a, [selected_level]
        ld      e, a
        add     hl, de
        ld      a, [hl]
        ld      [cur_waypoint], a
        ret


process_dpad::
.check_down
        ld      a, [JOYPAD_1]
        bit     BIT_BUTTON_DOWN, a
        call    nz, process_down
        ld      a, [JOYPAD_1]
        bit     BIT_BUTTON_UP, a
        call    nz, process_up
        ld      a, [JOYPAD_1]
        bit     BIT_BUTTON_RIGHT, a
        call    nz, process_right
        ld      a, [JOYPAD_1]
        bit     BIT_BUTTON_LEFT, a
        call    nz, process_left
        ret

process_down::
        ld      a, [cur_category]
        and     a
        jp      z, process_down_world
        dec     a
        jp      z, process_down_level
        dec     a
        jp      z, process_down_powerup
        ret

process_down_world::
        xor     a
        ld      [selected_level], a
        ld      a, CURSOR_TOP_Y
        ld      [SPRITE_BUFFER+4], a

        ld      a, [selected_world]
        cp      NUM_WORLDS-1
        jr      nz, .normal
.back_up
        xor     a
        jr      .cont
.normal
        inc     a
.cont
        ld      [selected_world], a
.update_sprite
        sla     a
        sla     a
        sla     a
        add     CURSOR_TOP_Y
        ld      [SPRITE_BUFFER+0], a
        call    update_level_numbers
        ret

process_down_level::
        ld      a, [cur_num_levels]
        ld      b, a
        dec     b
        ld      a, [selected_level]
        cp      b
        jr      nz, .normal
.back_up
        xor     a
        jr      .cont
.normal
        inc     a
.cont
        ld      [selected_level], a
.update_sprite
        sla     a
        sla     a
        sla     a
        add     CURSOR_TOP_Y
        ld      [SPRITE_BUFFER+4], a
        call    update_level_numbers
        ret

process_down_powerup::
        ld      a, [selected_powerup]
        cp      NUM_POWERUPS-1
        jr      nz, .normal
.back_up
        xor     a
        jr      .cont
.normal
        inc     a
.cont
        ld      [selected_powerup], a
.update_sprite
        sla     a
        sla     a
        sla     a
        add     CURSOR_TOP_Y
        ld      [SPRITE_BUFFER+8], a
        ret


process_up::
        ld      a, [cur_category]
        and     a
        jp      z, process_up_world
        dec     a
        jp      z, process_up_level
        dec     a
        jp      z, process_up_powerup
        ret

process_up_world::
        xor     a
        ld      [selected_level], a
        ld      a, CURSOR_TOP_Y
        ld      [SPRITE_BUFFER+4], a

        ld      a, [selected_world]
        and     a
        jr      nz, .normal
.back_down
        ld      a, NUM_WORLDS-1
        jr      .cont
.normal
        dec     a
.cont
        ld      [selected_world], a
.update_sprite
        sla     a
        sla     a
        sla     a
        add     CURSOR_TOP_Y
        ld      [SPRITE_BUFFER+0], a
        call    update_level_numbers
        ret

process_up_level::
        ld      a, [cur_num_levels]
        ld      b, a
        dec     b
        ld      a, [selected_level]
        and     a
        jr      nz, .normal
.back_down
        ld      a, [cur_num_levels]
        dec     a
        jr      .cont
.normal
        dec     a
.cont
        ld      [selected_level], a
.update_sprite
        sla     a
        sla     a
        sla     a
        add     CURSOR_TOP_Y
        ld      [SPRITE_BUFFER+4], a
        call    update_level_numbers
        ret

process_up_powerup::
        ld      a, [selected_powerup]
        and     a
        jr      nz, .normal
.back_down
        ld      a, NUM_POWERUPS-1
        jr      .cont
.normal
        dec     a
.cont
        ld      [selected_powerup], a
.update_sprite
        sla     a
        sla     a
        sla     a
        add     CURSOR_TOP_Y
        ld      [SPRITE_BUFFER+8], a
        ret


process_right::
        ld      a, [cur_category]
        and     a
        jp      z, process_right_world
        dec     a
        jp      z, process_right_level
        dec     a
        jp      z, process_right_powerup
        ret


process_right_world::
        ld      a, TILE_CURSOR_INACTIVE
        ld      [SPRITE_BUFFER+2], a
        ld      a, TILE_CURSOR_ACTIVE
        ld      [SPRITE_BUFFER+6], a
        ld      a, 1
        ld      [cur_category], a
        ret

process_right_level::
        ld      a, TILE_CURSOR_INACTIVE
        ld      [SPRITE_BUFFER+6], a
        ld      a, TILE_CURSOR_ACTIVE
        ld      [SPRITE_BUFFER+10], a
        ld      a, 2
        ld      [cur_category], a
        ret

process_right_powerup::
        ld      a, TILE_CURSOR_INACTIVE
        ld      [SPRITE_BUFFER+10], a
        ld      a, TILE_CURSOR_ACTIVE
        ld      [SPRITE_BUFFER+2], a
        ld      a, 0
        ld      [cur_category], a
        ret


process_left::
        ld      a, [cur_category]
        and     a
        jp      z, process_left_world
        dec     a
        jp      z, process_left_level
        dec     a
        jp      z, process_left_powerup
        ret


process_left_world::
        ld      a, TILE_CURSOR_INACTIVE
        ld      [SPRITE_BUFFER+2], a
        ld      a, TILE_CURSOR_ACTIVE
        ld      [SPRITE_BUFFER+10], a
        ld      a, 2
        ld      [cur_category], a
        ret

process_left_level::
        ld      a, TILE_CURSOR_INACTIVE
        ld      [SPRITE_BUFFER+6], a
        ld      a, TILE_CURSOR_ACTIVE
        ld      [SPRITE_BUFFER+2], a
        ld      a, 0
        ld      [cur_category], a
        ret

process_left_powerup::
        ld      a, TILE_CURSOR_INACTIVE
        ld      [SPRITE_BUFFER+10], a
        ld      a, TILE_CURSOR_ACTIVE
        ld      [SPRITE_BUFFER+6], a
        ld      a, 1
        ld      [cur_category], a
        ret


fix_palette:
        ld      a, 30
        ld      [BGP], a
        ld      [OBP0], a
        ld      a, %01000000
        ld      [OBP1], a
        ret


clear_oam:
        ld      hl, SPRITE_BUFFER
        ld      b, $a0
        xor     a
.loop
        ld      [hl+], a
        dec     b
        jr      nz, .loop
        ret


copy_my_sprites:
        ld      hl, my_sprites
        ld      de, MY_SPRITES
        ld      b, end_my_sprites-my_sprites
.loop
        ld      a, [hl+]
        ld      [de], a
        inc     de
        dec     b
        jr      nz, .loop
        ret

print_screen:
        ld      de, screen_tile_data
        ld      hl, $9800
        ld      c, NUM_LINES
.row_loop
        ld      b, 20
.col_loop
        ld      a, [de]
        ld      [hl+], a
        inc     de
        dec     b
        jr      nz, .col_loop
        ld      a, c
        ld      bc, 12
        add     hl, bc
        ld      c, a
        dec     c
        jr      nz, .row_loop
        ret


print_version:
        ld      a, TILE_VERSION_1
        ld      [$9a31], a
        ld      a, TILE_VERSION_2
        ld      [$9a32], a
        ld      a, TILE_VERSION_3
        ld      [$9a33], a
        ret


init_cursors:
        ld      a, TILE_CURSOR_INACTIVE
        ld      [SPRITE_BUFFER+2], a
        ld      a, TILE_CURSOR_INACTIVE
        ld      [SPRITE_BUFFER+6], a
        ld      a, TILE_CURSOR_INACTIVE
        ld      [SPRITE_BUFFER+10], a
.world
        ld      a, [selected_world]
        sla     a
        sla     a
        sla     a
        ld      b, a
        ld      a, CURSOR_TOP_Y
        add     b
        ld      [SPRITE_BUFFER+0], a
        ld      a, CURSOR_WORLD_X
        ld      [SPRITE_BUFFER+1], a
        xor     a
        ld      [SPRITE_BUFFER+3], a
.level
        ld      a, [selected_level]
        sla     a
        sla     a
        sla     a
        ld      b, a
        ld      a, CURSOR_TOP_Y
        add     b
        ld      [SPRITE_BUFFER+4], a
        ld      a, CURSOR_LEVEL_X
        ld      [SPRITE_BUFFER+5], a
        xor     a
        ld      [SPRITE_BUFFER+7], a
.powerup
        ld      a, [selected_powerup]
        sla     a
        sla     a
        sla     a
        ld      b, a
        ld      a, CURSOR_TOP_Y
        add     b
        ld      [SPRITE_BUFFER+8], a
        ld      a, CURSOR_POWERUP_X
        ld      [SPRITE_BUFFER+9], a
        xor     a
        ld      [SPRITE_BUFFER+11], a

.check_world
        ld      a, [cur_category]
        and     a
        jr      nz, .check_level
.have_world
        ld      a, TILE_CURSOR_ACTIVE
        ld      [SPRITE_BUFFER+2], a
        ret
.check_level
        dec     a
        jr      nz, .check_powerup
.have_level
        ld      a, TILE_CURSOR_ACTIVE
        ld      [SPRITE_BUFFER+6], a
        ret
.check_powerup
        dec     a
        ret     nz
.have_powerup
        ld      a, TILE_CURSOR_ACTIVE
        ld      [SPRITE_BUFFER+10], a
        ret


init_level_numbers::
        ld      d, CURSOR_TOP_Y
        ld      e, CURSOR_LEVEL_X+8
        ld      hl, SPRITE_BUFFER+12
        ld      b, MAX_NUM_LEVELS
.rowloop
        ld      c, 3
.colloop
        ld      a, d
        ld      [hl+], a
        ld      a, e
        ld      [hl+], a
        ld      a, TILE_EMPTY
        ld      [hl+], a
        xor     a
        ld      [hl+], a
        ld      a, 8
        add     e
        ld      e, a
        dec     c
        jr      nz, .colloop
        dec     hl
        ld      a, $10
        ld      [hl+], a

        ld      a, 8
        add     d
        ld      d, a
        ld      a, -3*8
        add     e
        ld      e, a
        dec     b
        jr      nz, .rowloop
        ret


update_level_numbers::
        call    init_level_numbers

        ld      hl, level_sprite_pointers
        ld      a, [selected_world]
        sla     a
        ld      d, 0
        ld      e, a
        add     hl, de
        ld      a, [hl+]
        ld      e, a
        ld      a, [hl+]
        ld      h, a
        ld      l, e
        ld      a, [hl+]
        ld      [cur_num_levels], a
        ld      b, a

        ld      de, SPRITE_BUFFER+12+2
.loop
        ld      a, [hl]
        and     $3f
        inc     a
        daa
        swap    a
        and     $0f
        add     TILE_ZERO
        ld      [de], a
        inc     de
        inc     de
        inc     de
        inc     de
        ld      a, [hl]
        inc     a
        daa
        and     $0f
        add     TILE_ZERO
        ld      [de], a
        inc     de
        inc     de
        inc     de
        inc     de

        ld      a, [hl+]
.check_for_variant
        bit     7, a
        jr      z, .cont
.have_variant
        bit     6, a
        jr      nz, .have_variant_b
.have_variant_a
        ld      a, TILE_A + "A" - "A"
        ld      [de], a
        jr      .cont
.have_variant_b
        ld      a, TILE_A + "B" - "A"
        ld      [de], a
.cont
        inc     de
        inc     de
        inc     de
        inc     de

        dec     b
        jr      nz, .loop

        ret


fix_screen_scroll:
        xor     a
        ld      [$a9a9], a
        ld      [$ff87], a
        ld      [$a994], a
        ret

turn_on_lcdc:
        ld      a, $83
        ld      [LCDC], a
        ret


waypoint_table:
        db      $07, $17, $0f, $0e, $24, $0c, $19, $29 ; world 1
        db      $06, $10, $0d, $05, $11, $09, $0a, $ff ; world 2
        db      $21, $02, $04, $08, $20, $18, $ff, $ff ; world 3
        db      $03, $15, $16, $27, $1b, $1c, $ff, $ff ; world 4
        db      $00, $1e, $1f, $0b, $14, $ff, $ff, $ff ; world 5
        db      $26, $2a, $1d, $01, $13, $12, $1a, $ff ; world 6
        db      $25, $22, $23, $28, $ff, $ff, $ff, $ff ; world 7

level_sprite_pointers:
        dw      world_1_levels
        dw      world_2_levels
        dw      world_3_levels
        dw      world_4_levels
        dw      world_5_levels
        dw      world_6_levels
        dw      world_7_levels
        
world_1_levels:
        db      8
        db      $00|V_A, $00|V_B, $01, $02|V_A, $02|V_B, $03, $04, $05

world_2_levels:
        db      7
        db      $06, $07, $08, $09, $10, $11, $12

world_3_levels:
        db      6
        db      $13, $14, $15, $16, $17, $18

world_4_levels:
        db      6
        db      $19, $20, $21, $22, $23, $24

world_5_levels:
        db      5
        db      $25, $26, $27, $28, $29

world_6_levels:
        db      7
        db      $30|V_A, $30|V_B, $31, $32, $33, $34, $35

world_7_levels:
        db      4
        db      $36, $37, $38, $39

screen_tile_data:
        incbin  "screen.dat"

my_sprites:
        incbin  "gfx/out/cursor_inactive.2bpp"
        incbin  "gfx/out/cursor_active.2bpp"
        incbin  "gfx/out/line.2bpp"
        incbin  "gfx/out/version_minor.2bpp"
end_my_sprites:

savefile:
        incbin "no_treasures_no_bosses.sav", 0, 24

SECTION "variables", SRAM[$a040], BANK[0]
selected_world:                 db
selected_level:                 db
selected_powerup:               db
cur_category:                   db
cur_num_levels:                 db
cur_waypoint:                   db
