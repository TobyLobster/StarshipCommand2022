; ----------------------------------------------------------------------------------
;
; Starship Command 2022 (v2) (for the BBC Micro, Master and Electron)
;
; An update to the original Starship Command (1983) by Peter Irvin.
;
; Based originally on the excellent Level 7 disassembly:
; http://www.level7.org.uk/miscellany/starship-command-disassembly.txt
;
; The Level 7 disassembly contains the following notes which I reproduce here
; with minor corrections, which are very useful in understanding the code:
;
; "
; Technical notes
; ===============
; The starship never rotates or moves. Instead, everything else does!
;
; Enemy ship co-ordinates are stored as three bytes, corresponding to screens,
; pixels and fractions of a pixel. Torpedo co-ordinates are stored as two bytes,
; for pixels and fractions of a pixel. Tables of pre-calculated sines and cosines
; are used in multiplication and division routines for trigonometric functions.
;
; Angles are stored such that $100 = 360 degrees, starting from up at $00 and
; increasing clockwise. $40 = right, $80 = down, $c0 = left.
;
; The main screen is ($7f, $7f).
;
; Game-play notes
; ===============
; There are always eight enemy ships. Each is assigned one of eight behaviour
; patterns at random, which can change with probability $06/$ff per frame:
;
;     0 Timid ship, retreats upwards as soon as on screen
;     1 Comes to a stop near edge of screen when starship is stationary, follows
;       closer when starship is moving
;     2 Approaches starship, stops or retreats
;     3 Approaches close, then stops
;     4 Approaches very close, then stops
;     5 Approaches very close, then retreats
;     6 Comes up from below starship to near stop above
;     7 Crashes into starship when going more than half speed
;
; They also have five properties which are determined by the command number:
;
;   * defensive about damage (less likely in later commands)
;     if set, enemy ship retreats when hit by starship torpedo
;
;   * defensive about angle (less likely in later commands)
;     if set, enemy ship retreats when directly in front of the starship
;
;   * fires cluster torpedoes (more likely in later commands)
;     if set, fires multiple torpedoes at once
;
;   * second enemy type, capable of cloaking (more likely in later commands)
;     if set, can become invisible
;
;   * torpedo cooldown (more likely to be lower in later commands)
;     number of frames between successive torpedo firings
;
;     command number                       1  2  3  4  5  6  7  8  9 10 11 12 13+
;
;     probability of enemy ships being:
;         defensive about damage          c0 ac 98 84 70 5c 48 34 20 20 20 20 20
;         defensive about angle           82 74 66 58 4a 3c 2e 20 12 04 04 04 04
;         fires cluster torpedoes         04 13 22 31 40 4f 5e 6d 7c 8b 9a a9 b8
;         second enemy type & cloakable   02 19 30 47 5e 75 8c a3 ba d1 e8 ff ff
;
;     maximum torpedo cooldown            0f 0d 0b 09 07 05 03 02 02 02 02 02 02
;
;     number of stars                     11 0f 0d 0b 09 07 05 03 01 01 01 01 01
;
; The game reaches its maximum difficulty at command thirteen.
;
; Energy is handled as follows:
;
;     maximum starship energy                               c80 (four bars)
;     low energy warning - flashing text                    320 (one bar)
;                        - beep                             190
;     minimum starship energy to avoid explosion             40
;
;     drain from accelerating or decelerating starship        4
;     drain from rotating starship                            4
;     drain from firing starship torpedo                      4
;
;     starship regeneration (every 3 frames)                  c
;
;     damage from enemy torpedo                              10
;     damage from collision with enemy ship (maximum ff)     c0 + enemy_energy/2
;     damage from passing through enemy explosion            explosion_timer/2
;         (all multiplied by four when shields are off)
;
;     damage from self-destruct                            4000
;
;     damage sufficient to cause shields to fail             3c
;         (with probability $6c/$ff)
;
;
;     maximum energy ship energy (all types)                 ff
;
;     enemy ship regeneration (every 4 frames)                1
;
;     damage from starship torpedo                           10
;     damage from collision with other enemy ship            20
;     damage from other collisions                           14 + rnd(3f)
;
; The size of starship and enemy torpedoes makes no difference to their damage.
;
; Points are scored for destroyed enemy ships as follows:
;
;     first enemy ship type, starship torpedo                      8
;     first enemy ship type, enemy torpedo                         3
;     first enemy ship type, escape capsule                       70
;     first enemy ship type, collision with other enemy ship       3
;     first enemy ship type, collision with starship               2
;
;     second enemy ship type, starship torpedo                    12
;     second enemy ship type, enemy torpedo                        4
;     second enemy ship type, escape capsule                      90
;     second enemy ship type, collision with other enemy ship      4
;     second enemy ship type, collision with starship              3
;
;
; A random, undisclosed factor of between 0 and 39 points is added to the score
; at the end of a command, for comparison against the following table:
;
;  score range  |  result
; --------------+------------------------------------------------------------------
;     0 -  39   |  furious,      and they retire you from active service
;    40 -  59   |  displeased,   and they retire you from active service
;    60 -  79   |  disappointed, and they retire you from active service
;    80 - 139   |  disappointed, but they allow you the command of another starship
;   140 - 259   |  satisfied,    and they allow you the command of another starship
;   260 - 399   |  pleased,      and they allow you the command of another starship
;   400 - 599   |  impressed,    and they allow you the command of another starship
;      600+     |  delighted,    and they allow you the command of another starship
; --------------+------------------------------------------------------------------
;
; The player must thus score at least 80 points to guarantee another command.
;
; Notes
; =====
; Enemy ships are stored in multiple arrays:
;
;  enemy_ships_previous_on_screen
;  enemy_ships_previous_x_fraction
;  enemy_ships_previous_x_pixels
;  enemy_ships_previous_x_screens
;  enemy_ships_previous_y_fraction
;  enemy_ships_previous_y_pixels
;  enemy_ships_previous_y_screens
;  enemy_ships_previous_angle
;  enemy_ships_velocity
;  enemy_ships_flags_or_explosion_timer:
;      ....8421 enemy ship behaviour type
;      ...1.... fires cluster torpedoes
;      ..2..... defensive about angle
;      .4...... defensive about damage
;  enemy_ships_type
;      0 = first ship type
;      1 = second ship type
;      4 = cloaked
;
;  enemy_ships_on_screen
;  enemy_ships_x_fraction
;  enemy_ships_x_pixels
;  enemy_ships_x_screens
;  enemy_ships_y_fraction
;  enemy_ships_y_pixels
;  enemy_ships_y_screens
;  enemy_ships_angle
;  enemy_ships_temporary_behaviour_flags
;      ....8421 enemy_ship_hit_count
;      ...1.... behaviour 0: enemy_ship_was_on_screen_above
;               behaviour 7: kamikaze_one
;      ..2..... behaviour 7: kamikaze_two
;      .4...... retreating because of angle
;      8....... retreating
;  enemy_ships_energy
;  enemy_ships_firing_cooldown
;      ....8421 current torpedo cooldown
;      8421.... maximum torpedo cooldown
;
; Enemy torpedoes are stored 6 bytes per torpedo:
;
;        +0 time to live (in frames)
;        +1 x_fraction
;        +2 x_pixels
;        +3 y_fraction
;        +4 y_pixels
;        +5 angle
;
; Starship torpedoes are stored 9 bytes per torpedo:
;
;        +0 time to live (in frames)
;        +1 x_fraction for head of torpedo
;        +2 x_pixels
;        +3 y_fraction
;        +4 y_pixels
;        +5 x_fraction for tail of torpedo
;        +6 x_pixels
;        +7 y_fraction
;        +8 y_pixels
;
; Stars are stored 4 bytes per star:
;
;        +0 x_fraction
;        +1 x_pixels
;        +2 y_fraction
;        +3 y_pixels
;
; Enemy explosion pieces are stored array 'enemy_explosion_tables', 2 bytes per piece:
;
;        +0 age
;           (top two bits are used to determine size of piece)
;        +1 radius
;            ......21 speed of ageing (via lookup table), if not a segment
;
; Starship explosion pieces are stored in array 'starship_explosion_table', 3 bytes per piece:
;
;        +0 age
;           (top two bits are used to determine size of piece, if not a segment)
;        +1 segment angle or ageing rate
;            8....... piece is a segment (probability 1/$3c)
;            ...18421 angle of segment, if piece is a segment
;            .....421 speed of ageing (via lookup table), if not a segment
;        +2 radius
;"
; ----------------------------------------------------------------------------------

do_debug = 0
rom_writes = 1
!ifndef elk {
elk=0           ; 0xC0DE: 0=Beeb version, 1=Elk version
}
antiflicker=1   ; 0xC0DE: affects Elk version only (0=off, 1=on) reduces flicker a little but slows down the game (?)
cheat=0         ; 0xC0DE: 0=no cheat, 1=cheat (no damage to starship)
cheat_score=0   ; key '6' gives you score, '7' kills you

; ----------------------------------------------------------------------------------
; gameplay constants
; ----------------------------------------------------------------------------------
; Number of 50Hz frames between game updates = 2*game_speed/39 = 64/39 ~= 1.64
game_speed                                                          = 32

starship_explosion_size                                             = 64
maximum_number_of_stars_in_game                                     = 17
maximum_number_of_frontier_stars                                    = 128
maximum_number_of_explosions                                        = 8
maximum_number_of_enemy_ships                                       = 8
maximum_number_of_starship_torpedoes                                = 24
maximum_number_of_enemy_torpedoes                                   = 24
maximum_starship_velocity                                           = 4
size_of_enemy_ship_for_collisions_between_enemy_ships               = 8
enemy_ship_explosion_duration                                       = 37
frame_of_enemy_ship_explosion_after_which_no_collisions             = 27
frame_of_enemy_ship_explosion_after_which_no_segments_are_plotted   = 35
starship_torpedoes_time_to_live                                     = 15
damage_enemy_ship_incurs_from_collision_with_other_enemy_ship       = 32
additional_damage_from_collision_with_enemy_ship                    = 192
damage_to_enemy_ship_from_starship_torpedo                          = 16
size_of_enemy_ship_for_collisions_with_torpedoes                    = 5
maximum_starship_explosion_countdown                                = 80
enemy_full_speed                                                    = 24

number_of_bytes_per_enemy_explosion                                 = 63

starship_maximum_x_for_collisions_with_enemy_torpedoes              = $7f + 7
starship_minimum_x_for_collisions_with_enemy_torpedoes              = $7f - 7
starship_maximum_y_for_collisions_with_enemy_torpedoes              = $7f + 7
starship_minimum_y_for_collisions_with_enemy_torpedoes              = $7f - 5
starship_maximum_x_for_collisions_with_enemy_ships                  = $7f + 13
starship_minimum_x_for_collisions_with_enemy_ships                  = $7f - 12
starship_maximum_y_for_collisions_with_enemy_ships                  = $7f + 13
starship_minimum_y_for_collisions_with_enemy_ships                  = $7f - 9

frame_of_starship_explosion_after_which_no_collisions               = 74
frame_of_starship_explosion_after_which_no_sound                    = 17
damage_from_enemy_torpedo                                           = 16

probability_of_enemy_ship_cloaking                                  = $3f   ; bit mask
minimum_energy_for_enemy_ship_to_cloak                              = $40

partial_velocity_for_damaged_enemy_ships                            = 6
minimum_number_of_stars                                             = 1

starship_torpedo_cooldown_after_firing                              = 1
starship_energy_drain_from_non_zero_rotation                        = 4
starship_torpedoes_per_round                                        = 4
starship_energy_drain_from_acceleration                             = 4
starship_acceleration_from_player                                   = $40
starship_acceleration_from_velocity_damper                          = $20
starship_torpedo_cooldown_after_round                               = 2
starship_energy_drain_from_firing_torpedo                           = 4

strength_of_player_rotation                                         = $f0
strength_of_rotation_dampers                                        = $40
minimum_energy_value_to_avoid_starship_destruction                  = 4

regeneration_rate_for_enemy_ships                                   = 1
maximum_timer_for_enemy_ships_regeneration                          = 4
base_regeneration_rate_for_starship                                 = 12
base_damage_to_enemy_ship_from_other_collision                      = 20
change_in_number_of_stars_per_command                               = -2

danger_height                                                       = 8

; ----------------------------------------------------------------------------------
; OS constants
; ----------------------------------------------------------------------------------
osbyte_set_cursor_editing               = $04
osbyte_flush_buffer_class               = $0f
osbyte_select_adc_channels              = $10
osbyte_read_adc_or_get_buffer_status    = $80
osbyte_inkey                            = $81

osword_read_line                        = $00
osword_sound                            = $07
osword_envelope                         = $08

; negative INKEY numbers
inkey_return                            = $b6
inkey_delete                            = $a6
inkey_z                                 = $9e
inkey_x                                 = $bd
inkey_m                                 = $9a
inkey_comma                             = $99
inkey_n                                 = $aa
inkey_g                                 = $ac
inkey_f                                 = $bc
inkey_f0                                = $df
inkey_f1                                = $8e
inkey_2                                 = $ce
inkey_3                                 = $ee
inkey_v                                 = $9c
inkey_b                                 = $9b
inkey_c                                 = $ad
inkey_p                                 = $c8
inkey_space                             = $9d
inkey_colon                             = $b7
inkey_slash                             = $97
inkey_6                                 = $cb
inkey_7                                 = $db

; OS memory locations
irq_accumulator                         = $fc           ;

irq1_vector_low                         = $204          ;
irq1_vector_high                        = $205          ;
bytev                                   = $20a          ;
wordv                                   = $20c          ;
rdchv                                   = $210          ;
verticalSyncCounter                     = $240          ;
enableKeyboardInterruptProcessingFlag   = $242          ;
basicROMNumber                          = $24b          ; page BASIC in for ROM writes

; reusing this flag makes the OS not beep during high score entry when we have sound disabled
sound_enabled                           = $262          ; OS sound suppression flag
soundBELLChannel                        = $263          ; sound channel for CTRL-G
soundBELLAmplitudeEnvelope              = $264          ; sound amp or envelope for CTRL-G
soundBELLPitch                          = $265          ; sound pitch for CTRL-G
soundBELLDuration                       = $266          ; sound duration for CTRL-G
functionAndCursorKeyCodes               = $26d          ; function key translations
vduInterlaceValue                       = $291          ;

videoULAPaletteRegister                 = $fe21         ; Video ULA palette register

userVIATimer1CounterLow                 = $fe64         ; Timer 1 counter (low)
userVIATimer1CounterHigh                = $fe65         ; Timer 1 counter (high)
userVIATimer1LatchLow                   = $fe66         ; Timer 1 latch (low)
userVIATimer1LatchHigh                  = $fe67         ; Timer 1 latch (high)
userVIATimer2CounterLow                 = $fe68         ; Timer 2 counter (low)
userVIATimer2CounterHigh                = $fe69         ; Timer 2 counter (high)
userVIAAuxiliaryControlRegister         = $fe6b         ; auxiliary control register
userVIAInterruptFlagRegister            = $fe6d         ; Interrupt flag register
userVIAInterruptEnableRegister          = $fe6e         ; Interrupt enable register

systemVIAOutB                           = $fe40         ; Output B
systemVIAOutA                           = $fe41         ; Output A
systemVIADirA                           = $fe43         ; Direction A
systemVIATimer1CounterLow               = $fe44         ; Timer 1 counter (low)
systemVIATimer1CounterHigh              = $fe45         ; Timer 1 counter (high)
systemVIATimer1LatchLow                 = $fe46         ; Timer 1 latch (low)
systemVIATimer1LatchHigh                = $fe47         ; Timer 1 latch (high)
systemVIATimer2CounterLow               = $fe48         ; Timer 2 counter (low)
systemVIATimer2CounterHigh              = $fe49         ; Timer 2 counter (high)
systemVIAAuxiliaryControlRegister       = $fe4b         ; auxiliary control register
systemVIAInterruptFlagRegister          = $fe4d         ; Interrupt flag register
systemVIAInterruptEnableRegister        = $fe6e         ; Interrupt enable register
systemVIAOutA_NH                        = $fe4f         ; Output A (no handshake)

!if elk=1 {
oswrch                                  = fastwrch
} else {
oswrch                                  = $ffcb         ; nvwrch avoids an indirection
}
osnewl                                  = $ffe7
osword                                  = $fff1
osbyte                                  = $fff4

; ----------------------------------------------------------------------------------
; zero page
; ----------------------------------------------------------------------------------

; for multiply routines
b                                       = $00
c                                       = $01
prod_low                                = $02
t                                       = $03   ; } same location
num_frontier_star_updates               = $03   ; }
torpedo_dir                             = $03   ; }


starship_rotation_eor                   = $04
starship_velocity_high                  = $05
starship_velocity_low                   = $06
starship_rotation                       = $07
starship_rotation_magnitude             = $08
starship_rotation_cosine                = $09
starship_rotation_sine_magnitude        = $0a

stars_still_to_consider                 = $0b   ; }
explosion_bits_still_to_consider        = $0b   ; } same location
enemy_ships_still_to_consider           = $0b   ; }

lookup_low                              = $0c   ; used in decompressing text, and initialising the enemy cache
lookup_high                             = $0d   ;
lookup_byte                             = $0e   ;
bytes_left                              = $0f   ;

temp_x                                  = $10
temp_y                                  = $11

object_x_fraction                       = $12
object_x_pixels                         = $13
object_y_fraction                       = $14
object_y_pixels                         = $15

maximum_number_of_stars                 = $16

x_pixels                                = $17
y_pixels                                = $18

temp0_low                               = $19
temp0_high                              = $1a

screen_address_low                      = $1b
screen_address_high                     = $1c
output_pixels                           = $1d   ; } same location
segment_angle_change_per_pixel          = $1d   ; }
output_fraction                         = $1e

temp8                                   = $1f
temp9                                   = $20   ; } same location
input_fraction                          = $20   ; }

temp10                                  = $21   ; } same location
input_pixels                            = $21   ; }

segment_angle                           = $22   ; } same location
input_screens                           = $22   ; }

zp_start                                = $23

rnd_1                                   = $23   ;
rnd_2                                   = $24   ;

torpedoes_still_to_consider             = $25
enemy_ship_was_previously_on_screen     = $26   ; 0=previously on screen, $ff=otherwise
enemy_ship_was_on_screen                = $27
how_enemy_ship_was_damaged              = $28
old_timing_counter                      = $29
timing_counter                          = $2a

engine_sound_shifter                    = $2b
irqtmp                                  = $2c   ; IRQ-safe temporary
enemy_low                               = $2d
enemy_high                              = $2e
plot_enemy_progress                     = $2f

result                                  = $30   ; used in decompressing text
end_low                                 = $31
end_high                                = $32
starship_low                            = $33   ; }
cache_start_low                         = $33   ; } same location
current_enemy_torpedo_object_index      = $33   ; }

starship_high                           = $34   ; }
cache_start_high                        = $34   ; } same location

enemy_number                            = $35   ; Enemy definition 0-5
enemy_stride                            = $36   ; offset in bytes to get from one enemy angle definition to the next

irq_counter                             = $37   ; Elk: 0 = electron beam is somewhere between vsync and rtc (upper half of screen), 1 = electron beam is somewhere between rtc and vsync (lower half of screen)

enemy_ships_flags_or_explosion_timer    = $38 +  0 * maximum_number_of_enemy_ships    ; i.e. starts at $38
enemy_ships_on_screen                   = $38 +  1 * maximum_number_of_enemy_ships    ; i.e. starts at $40
enemy_ships_x_fraction                  = $38 +  2 * maximum_number_of_enemy_ships    ; i.e. starts at $48
enemy_ships_x_pixels                    = $38 +  3 * maximum_number_of_enemy_ships    ; i.e. starts at $50
enemy_ships_x_screens                   = $38 +  4 * maximum_number_of_enemy_ships    ; i.e. starts at $58
enemy_ships_y_fraction                  = $38 +  5 * maximum_number_of_enemy_ships    ; i.e. starts at $60
enemy_ships_y_pixels                    = $38 +  6 * maximum_number_of_enemy_ships    ; i.e. starts at $68
enemy_ships_y_screens                   = $38 +  7 * maximum_number_of_enemy_ships    ; i.e. starts at $70
enemy_ships_velocity                    = $38 +  8 * maximum_number_of_enemy_ships    ; i.e. starts at $78
enemy_ships_angle                       = $38 +  9 * maximum_number_of_enemy_ships    ; i.e. starts at $80
enemy_ships_temporary_behaviour_flags   = $38 + 10 * maximum_number_of_enemy_ships    ; i.e. starts at $88
enemy_ships_energy                      = $38 + 11 * maximum_number_of_enemy_ships    ; i.e. starts at $90

segment_length                          = $98   ; } same location
multiplier                              = $98   ; }
temp11                                  = $99
temp1_low                               = $9a
temp1_high                              = $9b
temp3                                   = $9c
temp4                                   = $9d
temp5                                   = $9e
temp6                                   = $9f
temp7                                   = $a0

score_delta_low                         = $a1
score_delta_high                        = $a2
score_as_bcd                            = $a3
score_as_bcd_mid                        = $a4
score_as_bcd_high                       = $a5
codeptr_low                             = $a6   ; } same location
set_pixel_flag                          = $a6   ; }
codeptr_high                            = $a7
rotation_damper                         = $a8

enemy_ship_update_done                  = $a9
starship_energy_low                     = $aa
starship_energy_high                    = $ab
desired_velocity_for_intact_enemy_ships = $ac

starship_angle_fraction                 = $ad
starship_angle_delta                    = $ae
value_used_for_enemy_torpedo_time_to_live = $af
starship_shields_active                 = $b0
starship_torpedo_cooldown               = $b1
fire_pressed                            = $b2
damage_high                             = $b3
damage_low                              = $b4
starship_destroyed                      = $b5
starship_energy_divided_by_sixteen      = $b6
starship_energy_regeneration            = $b7
starship_automatic_shields              = $b8
value_of_x_when_incur_damage_called     = $b9
shields_state_delta                     = $ba
rotation_delta                          = $bb
starship_rotation_fraction              = $bc
velocity_delta                          = $bd
velocity_damper                         = $be
enemy_ship_type                         = $bf
starship_torpedo_counter                = $c0
previous_starship_automatic_shields     = $c1
starship_has_exploded                   = $c2
starship_explosion_countdown            = $c3
create_new_enemy_explosion_piece_after_one_dies = $c4
keyboard_or_joystick                    = $c5
escape_capsule_launched                 = $c6
escape_capsule_sound_channel            = $c7
enemy_ship_fired_torpedo                = $c8
enemy_ships_collided_with_each_other    = $c9
enemy_torpedo_hits_against_starship     = $ca
enemy_ship_was_hit                      = $cb
damage_to_enemy_ship_from_other_collision = $cc
enemy_ships_collision_x_difference      = $cd
enemy_ships_collision_y_difference      = $ce
timer_for_low_energy_warning_sound      = $cf

zp_end                                  = $d0

sound_needed_for_low_energy             = $e2
energy_flash_timer                      = $e3
starship_collided_with_enemy_ship       = $e4
velocity_gauge_position                 = $e5

current_object_index                    = $e8
torpedo_head_index                      = $f2
torpedo_tail_index                      = $f3

rotation_gauge_position                 = $f5
enemy_ship_desired_angle_divided_by_eight = $f6
number_of_live_starship_torpedoes       = $f7
starship_fired_torpedo                  = $f8
scanner_failure_duration                = $f9
starship_shields_active_before_failure  = $fd
starship_torpedo_type                   = $fe




; reuse zero page variables when filling in enemy cache
enemy_x                                 = enemy_ships_flags_or_explosion_timer
enemy_y                                 = enemy_ships_flags_or_explosion_timer + 1
enemy_start_angle                       = enemy_ships_flags_or_explosion_timer + 2
enemy_end_angle                         = enemy_ships_flags_or_explosion_timer + 3
enemy_arc_length                        = enemy_ships_flags_or_explosion_timer + 4
enemy_temp_index                        = enemy_ships_flags_or_explosion_timer + 5

award                                   = enemy_ships_flags_or_explosion_timer
allowed_another_command                 = award + 1


; ----------------------------------------------------------------------------------
; memory locations
; ----------------------------------------------------------------------------------

; High score table.
; There are eight entries of 16 bytes each. The first three bytes are the score, then 13 bytes for the name
high_score_table                        = $0100
high_score_table_end                    = $0180
input_buffer                            = $0180

; enemy data $0400-$0758
enemy_ships_previous_on_screen          = $0400 +  0 * maximum_number_of_enemy_ships    ; i.e. starts at $0400
enemy_ships_previous_x_fraction         = $0400 +  1 * maximum_number_of_enemy_ships    ; i.e. starts at $0408
enemy_ships_previous_x_pixels           = $0400 +  2 * maximum_number_of_enemy_ships    ; i.e. starts at $0410
enemy_ships_previous_x_screens          = $0400 +  3 * maximum_number_of_enemy_ships    ; i.e. starts at $0418
enemy_ships_previous_y_fraction         = $0400 +  4 * maximum_number_of_enemy_ships    ; i.e. starts at $0420
enemy_ships_previous_y_pixels           = $0400 +  5 * maximum_number_of_enemy_ships    ; i.e. starts at $0428
enemy_ships_previous_y_screens          = $0400 +  6 * maximum_number_of_enemy_ships    ; i.e. starts at $0430
enemy_ships_previous_angle              = $0400 +  7 * maximum_number_of_enemy_ships    ; i.e. starts at $0438
enemy_ships_type                        = $0400 +  8 * maximum_number_of_enemy_ships    ; i.e. starts at $0440
enemy_ships_firing_cooldown             = $0400 +  9 * maximum_number_of_enemy_ships    ; i.e. starts at $0448
enemy_ships_explosion_number            = $0400 + 10 * maximum_number_of_enemy_ships    ; i.e. starts at $0450

; 64 table entries. Each entry has a high byte and a low byte.
; The first  32 entries are the address of each angle of the first enemy type.
; The second 32 entries are the address of each angle of the second enemy type.
; These addresses depend upon the number of arcs in each enemy,
; so are filled in via code (in fill_enemy_cache).
enemy_address_low                       = $0400 + 11 * maximum_number_of_enemy_ships    ; i.e. starts at $0458
enemy_address_high                      = enemy_address_low + 64                        ; i.e. starts at $0498
enemy_address_high_end                  = enemy_address_high + 64                       ; i.e. end    at $04d7

enemy_cache_a                           = $4d8
    ; (x, y, start_angle, length) = 4 bytes
    ; 4 bytes * 5 arcs * 32 angles = 640 bytes
; to $758

frontier_star_positions_y               = enemy_cache_a + 640                           ; to $7d8
unused2 = frontier_star_positions_y + 128                                               ; UNUSED: 40 bytes free to $800

stride_between_enemy_coordinates        = enemy_ships_previous_y_fraction - enemy_ships_previous_x_fraction

squares1_low                            = $0900  ; } 512 entries of 16 bit value (i*i)/4
squares1_high                           = $0b00  ; } (1k total)

nmi_routine                             = $0d00
starship_explosion_table                = $0d01  ; (192 bytes) randomised when needed.

squares2_low                            = $0e00  ; } 512 entries of 16 bit value (i*i)/4
squares2_high                           = $1000  ; } (1k total)
row_table_low                           = $1200
play_area_row_table_high                = $1300
xandf8                                  = $1400  ; }
xbit_table                              = $1500  ; } tables of constants (768 bytes)

; in front end:
frontier_star_positions_x               = $1600  ; 192 bytes.
loader_string                           = $1700

; in game:
enemy_explosion_tables                  = $1600
enemy_cache_b                           = enemy_explosion_tables + maximum_number_of_enemy_ships * 64
    ; (x, y, start_angle, length) = 4 bytes
    ; 4 bytes * 6 arcs * 32 angles = 768 bytes

end_of_tables = enemy_cache_b + 768
;!warn "end of tables: ", end_of_tables

starship_top_screen_address             = $6b38
starship_bottom_screen_address          = $6c78
energy_screen_address                   = $6e48

; This is the delay between interrupts. Set to (number_of_pixel_rows * 64) - 2.
; Each frame is 312 pixel rows. Interrupt every sixteen pixel rows.
; This is used to track the electron gun to avoid flicker.
ShortTimerValue  = 16*64 - 2

; ----------------------------------------------------------------------------------
; code and data
; ----------------------------------------------------------------------------------

* = end_of_tables

load_addr

!macro start_keyboard_read {
!if elk=0 {
    sei                                                               ;
    lda #$7f                                                          ;
    sta $fe43                                                         ;
    lda #$03                                                          ;
    sta $fe40                                                         ;
}
}
!macro finish_keyboard_read {
!if elk=0 {
    lda #$0b                                                          ;
    sta $fe40                                                         ;
    cli                                                               ;
}
}

; macros for object drawing
; A holds the current screen modification byte
; X and Y are between 0 and 7
!macro left {
    dex                                                               ;
    bpl +                                                             ;
    jsr leftfix                                                       ;
+
    eor xbit_table,x                                                  ;
}

!macro right {
    inx                                                               ;
    cpx #8                                                            ;
    bne +                                                             ;
    jsr rightfix                                                      ;
+
    eor xbit_table,x                                                  ;
}
!macro up {
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    dey                                                               ;
    bpl +                                                             ;
    jsr upfix                                                         ;
+
    lda xbit_table,x                                                  ;
}
!macro down {
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    iny                                                               ;
    cpy #8                                                            ;
    bne +                                                             ;
    jsr downfix                                                       ;
+
    lda xbit_table,x                                                  ;
}
!macro downleft {
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    iny                                                               ;
    dex                                                               ;
    bmi .nope                                                         ;
    cpy #8                                                            ;
    bne .ok                                                           ;
.nope
    jsr downleftfix                                                   ;
.ok
    lda xbit_table,x                                                  ;
}
!macro downright {
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    inx                                                               ;
    iny                                                               ;
    cpx #8                                                            ;
    beq .nope                                                         ;
    cpy #8                                                            ;
    bne .ok                                                           ;
.nope
    jsr downrightfix                                                  ;
.ok
    lda xbit_table,x                                                  ;
}
!macro upleft {
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    dex                                                               ;
    dey                                                               ;
    bmi .nope                                                         ;
    cpx #$ff                                                          ;
    bne .ok                                                           ;
.nope
    jsr upleftfix                                                     ;
.ok
    lda xbit_table,x                                                  ;
}
!macro upright {
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    inx                                                               ;
    dey                                                               ;
    bmi .nope                                                         ;
    cpx #8                                                            ;
    bne .ok                                                           ;
.nope
    jsr uprightfix                                                    ;
.ok
    lda xbit_table,x                                                  ;
}

; ----------------------------------------------------------------------------------
plus_angle0
    +right
plus_angle1
    +downright
plus_angle2
    +right
plus_angle3
    +downright
plus_angle4
    +downright
plus_angle5
    +down
plus_angle6
    +downright
plus_angle7
    +down
plus_angle8
    +down
plus_angle9
    +downleft
plus_angle10
    +down
plus_angle11
    +downleft
plus_angle12
    +downleft
plus_angle13
    +left
plus_angle14
    +downleft
plus_angle15
    +left
plus_angle16
    +left
plus_angle17
    +upleft
plus_angle18
    +left
plus_angle19
    +upleft
plus_angle20
    +upleft
plus_angle21
    +up
plus_angle22
    +upleft
plus_angle23
    +up
plus_angle24
    +up
plus_angle25
    +upright
plus_angle26
    +up
plus_angle27
    +upright
plus_angle28
    +upright
plus_angle29
    +right
plus_angle30
    +upright
plus_angle31
    +right
plus_angle32
    +right
plus_angle33
    +downright
plus_angle34
    +right
plus_angle35
    +downright
plus_angle36
    +downright
plus_angle37
    +down
plus_angle38
    +downright
plus_angle39
    +down
plus_angle40
    +down
plus_angle41
    +downleft
plus_angle42

; ----------------------------------------------------------------------------------
starship_rotation_cosine_table
    !byte 0  , $fe, $f8, $ee, $e0, $ce                                ;
starship_rotation_sine_table
    !byte 0  , 2  , 4  , 6  , 8  , 10                                 ;

cosine_table
    !byte $fa, $fa, $fb, $fb, $fc, $fd, $fe, $ff                      ; overlaps with sine table
sine_table
    !byte 0  , 1  , 2  , 3  , 4  , 5  , 5  , 6                        ; full sine table
    !byte 6  , 6  , 5  , 5  , 4  , 3  , 2  , 1                        ;
    !byte 0  , $ff, $fe, $fd, $fc, $fb, $fb, $fa                      ;
    !byte $fa, $fa, $fb, $fb, $fc, $fd, $fe, $ff                      ;

; ----------------------------------------------------------------------------------
; Align to page boundary for speed

plot_table_offset_low
    !byte <plus_angle0
    !byte <plus_angle1
    !byte <plus_angle2
    !byte <plus_angle3
    !byte <plus_angle4
    !byte <plus_angle5
    !byte <plus_angle6
    !byte <plus_angle7
    !byte <plus_angle8
    !byte <plus_angle9
    !byte <plus_angle10
    !byte <plus_angle11
    !byte <plus_angle12
    !byte <plus_angle13
    !byte <plus_angle14
    !byte <plus_angle15
    !byte <plus_angle16
    !byte <plus_angle17
    !byte <plus_angle18
    !byte <plus_angle19
    !byte <plus_angle20
    !byte <plus_angle21
    !byte <plus_angle22
    !byte <plus_angle23
    !byte <plus_angle24
    !byte <plus_angle25
    !byte <plus_angle26
    !byte <plus_angle27
    !byte <plus_angle28
    !byte <plus_angle29
    !byte <plus_angle30
    !byte <plus_angle31
    !byte <plus_angle32
    !byte <plus_angle33
    !byte <plus_angle34
    !byte <plus_angle35
    !byte <plus_angle36
    !byte <plus_angle37
    !byte <plus_angle38
    !byte <plus_angle39
    !byte <plus_angle40
    !byte <plus_angle41
    !byte <plus_angle42
!align 255, 0
plot_table_offset_high
    !byte >plus_angle0
    !byte >plus_angle1
    !byte >plus_angle2
    !byte >plus_angle3
    !byte >plus_angle4
    !byte >plus_angle5
    !byte >plus_angle6
    !byte >plus_angle7
    !byte >plus_angle8
    !byte >plus_angle9
    !byte >plus_angle10
    !byte >plus_angle11
    !byte >plus_angle12
    !byte >plus_angle13
    !byte >plus_angle14
    !byte >plus_angle15
    !byte >plus_angle16
    !byte >plus_angle17
    !byte >plus_angle18
    !byte >plus_angle19
    !byte >plus_angle20
    !byte >plus_angle21
    !byte >plus_angle22
    !byte >plus_angle23
    !byte >plus_angle24
    !byte >plus_angle25
    !byte >plus_angle26
    !byte >plus_angle27
    !byte >plus_angle28
    !byte >plus_angle29
    !byte >plus_angle30
    !byte >plus_angle31
    !byte >plus_angle32
    !byte >plus_angle33
    !byte >plus_angle34
    !byte >plus_angle35
    !byte >plus_angle36
    !byte >plus_angle37
    !byte >plus_angle38
    !byte >plus_angle39
    !byte >plus_angle40
    !byte >plus_angle41
    !byte >plus_angle42

segment_angle_to_x_deltas_table
    !byte $1     ; 0   x+ y0
    !byte $1     ; 1   x+ y+
    !byte $1     ; 2   x+ y0
    !byte $1     ; 3   x+ y+
    !byte $1     ; 4   x+ y+
    !byte $0     ; 5   x0 y+
    !byte $1     ; 6   x+ y+
    !byte $0     ; 7   x0 y+
    !byte $0     ; 8   x0 y+
    !byte $ff    ; 9   x- y+
    !byte $0     ; 10  x0 y+
    !byte $ff    ; 11  x- y+
    !byte $ff    ; 12  x- y+
    !byte $ff    ; 13  x- y0
    !byte $ff    ; 14  x- y+
    !byte $ff    ; 15  x- y0
    !byte $ff    ; 16  x- y0
    !byte $ff    ; 17  x- y-
    !byte $ff    ; 18  x- y0
    !byte $ff    ; 19  x- y-
    !byte $ff    ; 20  x- y-
    !byte $0     ; 21  x0 y-
    !byte $ff    ; 22  x- y-
    !byte $0     ; 23  x0 y-
    !byte $0     ; 24  x0 y-
    !byte $1     ; 25  x+ y-
    !byte $0     ; 26  x0 y-
    !byte $1     ; 27  x+ y-
    !byte $1     ; 28  x+ y-
    !byte $1     ; 29  x+ y0
    !byte $1     ; 30  x+ y-
    !byte $1     ; 31  x+ y0

segment_angle_to_y_deltas_table
    !byte $0     ; 0   y0
    !byte $1     ; 1   y+
    !byte $0     ; 2   y0
    !byte $1     ; 3   y+
    !byte $1     ; 4   y+
    !byte $1     ; 5   y+
    !byte $1     ; 6   y+
    !byte $1     ; 7   y+
    !byte $1     ; 8   y+
    !byte $1     ; 9   y+
    !byte $1     ; 10  y+
    !byte $1     ; 11  y+
    !byte $1     ; 12  y+
    !byte $0     ; 13  y0
    !byte $1     ; 14  y+
    !byte $0     ; 15  y0
    !byte $0     ; 16  y0
    !byte $ff    ; 17  y-
    !byte $0     ; 18  y0
    !byte $ff    ; 19  y-
    !byte $ff    ; 20  y-
    !byte $ff    ; 21  y-
    !byte $ff    ; 22  y-
    !byte $ff    ; 23  y-
    !byte $ff    ; 24  y-
    !byte $ff    ; 25  y-
    !byte $ff    ; 26  y-
    !byte $ff    ; 27  y-
    !byte $ff    ; 28  y-
    !byte $0     ; 29  y0
    !byte $ff    ; 30  y-
    !byte $0     ; 31  y0

; ----------------------------------------------------------------------------------
; Exploding starship 1
; ----------------------------------------------------------------------------------
sound_1
    !byte $11, 0                                                      ; channel 1
    !byte 0, 0                                                        ; volume 0 (silent)
sound_1_pitch
    !byte 0, 0                                                        ; pitch for the white noise of sound_2
    !byte 8, 0                                                        ; duration 8

; ----------------------------------------------------------------------------------
; Exploding starship 2
; ----------------------------------------------------------------------------------
sound_2
    !byte $10, 0                                                      ; channel 0 (white noise)
sound_2_volume_low
    !byte 0                                                           ; volume
sound_2_volume_high
    !byte 0
    !byte 7, 0                                                        ; pitch determined by the pitch of channel 1
    !byte 8, 0                                                        ; duration 8

; ----------------------------------------------------------------------------------
; Starship fired torpedo
; ----------------------------------------------------------------------------------
sound_3
    !byte $13, 0                                                      ; channel 3
    !byte 1, 0                                                        ; envelope 1
    !byte $80, 0                                                      ; pitch 128
    !byte 4, 0                                                        ; duration 4

; ----------------------------------------------------------------------------------
; Enemy ship fired torpedo
; ----------------------------------------------------------------------------------
sound_4
    !byte $12, 0                                                      ; channel 2
    !byte 2, 0                                                        ; envelope 2
    !byte $c0, 0                                                      ; pitch 192
!if elk {
    ; echo effect is totally wasted on Electron
    !byte $4, 0                                                      ; duration 4
} else {
    !byte $1f, 0                                                      ; duration 31
}
; ----------------------------------------------------------------------------------
; Enemy ship hit by torpedo
; ----------------------------------------------------------------------------------
sound_5
    !byte $12, 0                                                      ; channel 2
    !byte 4, 0                                                        ; envelope 4
    !byte $40, 0                                                      ; pitch 64
    !byte 8, 0                                                        ; duration 8

; ----------------------------------------------------------------------------------
; Starship hit by torpedo
; ----------------------------------------------------------------------------------
sound_6
    !byte $12, 0                                                      ; channel 2
    !byte 4, 0                                                        ; envelope 4
    !byte $be, 0                                                      ; pitch 190
    !byte 8, 0                                                        ; duration 8

; ----------------------------------------------------------------------------------
; Enemy ships collided with each other
; ----------------------------------------------------------------------------------
sound_7
    !byte $13, 0                                                      ; channel 3
    !byte 2, 0                                                        ; envelope 2
    !byte $6c, 0                                                      ; pitch 108
    !byte 8, 0                                                        ; duration 8

; ----------------------------------------------------------------------------------
; Escape capsule launched
; ----------------------------------------------------------------------------------
sound_8
    !byte $13, 0                                                      ; channel 3
sound_8_volume_low
    !byte 0                                                           ; volume
sound_8_volume_high
    !byte 0                                                           ;
    !byte $64, 0                                                      ; pitch 100
    !byte 4  , 0                                                      ; duration 4

; ----------------------------------------------------------------------------------
; Low energy warning
; ----------------------------------------------------------------------------------
sound_9
    !byte $11, 0                                                      ; channel 1
    !byte $f1, $ff                                                    ; volume 15
    !byte $c8, 0                                                      ; duration 200
    !byte 2, 0                                                        ; duration 2

!if elk=0 {
; ----------------------------------------------------------------------------------
; Starship engine
; ----------------------------------------------------------------------------------
sound_10
    !byte $11, 0                                                      ; channel 1
sound_10_volume_low
    !byte 0                                                           ; volume
sound_10_volume_high
    !byte 0                                                           ;
sound_10_pitch
    !byte 0, 0                                                        ; pitch
    !byte 4, 0                                                        ; duration 4
}

; ----------------------------------------------------------------------------------
; Exploding enemy ship
; ----------------------------------------------------------------------------------
sound_11
    !byte $10, 0                                                      ; channel 0 (white noise)
    !byte 3, 0                                                        ; envelope 3
    !byte 7, 0                                                        ; pitch 7
    !byte $1e, 0                                                      ; duration 30

!if >sound_1 != >sound_11 {
    !error "alignment error", sound_1, sound_11;
}
sounds = sound_1 & 0xff00

!src "build/sc_text.a"

start
    lda #$ce                                                          ;
    sta starship_rotation_cosine                                      ;
    lda #$0a                                                          ;
    sta starship_rotation_sine_magnitude                              ;
    jsr init_self_modifying_bytes_for_starship_rotation               ;
    jsr init_frontier_screen                                          ;
    ldx #the_frontiers_string                                         ;
    jsr print_compressed_string                                       ;
print_string_after_loading
    ; display string
    ldx #begin_first_command_string                                   ;
    jsr print_compressed_string                                       ;
    jsr finish_screen
wait_for_return_in_frontiers_loop
    inc rnd_1                                                         ;
    jsr update_frontier_stars                                         ;
    jsr get_key_maybe_its_return                                      ;
    bne wait_for_return_in_frontiers_loop                             ;
return_pressed
    lda rnd_1                                                         ;
    eor #$cd                                                          ;
    sta rnd_2                                                         ;

    jsr combat_preparation_screen                                     ;
    jmp start_game                                                    ;

; ----------------------------------------------------------------------------------
set_or_unset_pixel
    lda set_pixel_flag                                                ;
    beq unset_pixel                                                   ;
    ; fall through...

; ----------------------------------------------------------------------------------
set_pixel
    ldy y_pixels                                                      ;
    ldx play_area_row_table_high,y                                    ;
    inx                                                               ;
    stx screen_address_high                                           ;
    lda row_table_low,y                                               ;
    sta screen_address_low                                            ;
    ldx x_pixels                                                      ;
    ldy xandf8,x                                                      ;
    lda xbit_table,x                                                  ;
    ora (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
unset_pixel
    ldy y_pixels                                                      ;
    ldx play_area_row_table_high,y                                    ;
    inx                                                               ;
    stx screen_address_high                                           ;
    lda row_table_low,y                                               ;
    sta screen_address_low                                            ;
    ldx x_pixels                                                      ;
    ldy xandf8,x                                                      ;
    lda xbit_table,x                                                  ;
    eor #$ff                                                          ;
    and (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
init_self_modifying_bytes_for_starship_rotation
    lda starship_rotation_sine_magnitude                              ;
    sta sm_sine_a1                                                    ;
    sta sm_sine_b1                                                    ;
    sta sm_sine_a3                                                    ;
    sta sm_sine_b3                                                    ;
    eor #$ff                                                          ;
    sta sm_sine_a2                                                    ;
    sta sm_sine_b2                                                    ;
    sta sm_sine_a4                                                    ;
    sta sm_sine_b4                                                    ;
    lda starship_rotation_cosine                                      ;
    sta sm_cosine_a1                                                  ;
    sta sm_cosine_b1                                                  ;
    sta sm_cosine_c1                                                  ;
    sta sm_cosine_a3                                                  ;
    sta sm_cosine_b3                                                  ;
    sta sm_cosine_c3                                                  ;
    eor #$ff                                                          ;
    sta sm_cosine_a2                                                  ;
    sta sm_cosine_b2                                                  ;
    sta sm_cosine_c2                                                  ;
    sta sm_cosine_a4                                                  ;
    sta sm_cosine_b4                                                  ;
    sta sm_cosine_c4                                                  ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
multiply_enemy_position_by_starship_rotation_sine_magnitude
    ; set up inputs
    lda starship_rotation_sine_magnitude                              ;
    sta t                                                             ;
    lda enemy_ships_x_fraction,x                                      ;
    sta input_fraction                                                ;
    lda enemy_ships_x_pixels,x                                        ;
    sta input_pixels                                                  ;
    lda enemy_ships_x_screens,x                                       ;
    sta input_screens                                                 ;
    ; fall through...

; ----------------------------------------------------------------------------------
; multiply 24 bit by 8 bit
; input is (input_fraction,input_pixels,input_screens) x t
; output is (multiplier, output_fraction, output_pixels)
; Average cycle count: 354 cycles
mul24x8
    lda #0                                                            ;
    sta multiplier                                                    ;
    sta output_fraction                                               ;
    sta output_pixels                                                 ;
    ldy #8                                                            ;
-
    lsr t                                                             ;
    bcc skipZ                                                         ;

    lda output_pixels                                                 ;
    clc                                                               ;
    adc input_fraction                                                ;
    sta output_pixels                                                 ;

    lda output_fraction                                               ;
    adc input_pixels                                                  ;
    sta output_fraction                                               ;

    lda multiplier                                                    ;
    adc input_screens                                                 ;
    sta multiplier                                                    ;
skipZ
    ror multiplier                                                    ;
    ror output_fraction                                               ;
    ror output_pixels                                                 ;
    dey                                                               ;
    bne -                                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
multiply_enemy_position_by_starship_rotation_cosine
    stx temp_x                                                        ; remember x

    ; set up inputs
    lda enemy_ships_x_screens,x                                       ;
    ldy enemy_ships_x_pixels,x                                        ;
    tax                                                               ;

    ; multiply the 16 bit number 'c.b' by starship_rotation_cosine (8 bit)
    ; result in A (low) and temp8 (high)

    ; multiply X * starship_rotation_cosine, result in A (high byte) and prod_low
sm_cosine_b1 = * + 1
    lda squares1_low,y                                                ;
    sec                                                               ;
sm_cosine_b2 = * + 1
    sbc squares2_low,y                                                ;
sm_cosine_b3 = * + 1
    lda squares1_high,y                                               ;
sm_cosine_b4 = * + 1
    sbc squares2_high,y                                               ;
    tay                                                               ; remember high byte ('t')

    ; multiply c * starship_rotation_cosine, result in A (high byte) and prod_low
sm_cosine_c1 = * + 1
    lda squares1_low,x                                                ;
    sec                                                               ;
sm_cosine_c2 = * + 1
    sbc squares2_low,x                                                ;
    sta prod_low                                                      ;
sm_cosine_c3 = * + 1
    lda squares1_high,x                                               ;
sm_cosine_c4 = * + 1
    sbc squares2_high,x                                               ;

    sta temp8                                                         ;
    tya                                                               ; recall 't'
    clc                                                               ;
    adc prod_low                                                      ;
    bcc +                                                             ;
    inc temp8                                                         ;
+

    ; update enemy position
    ldx temp_x                                                        ; restore x
    clc                                                               ;
    adc enemy_ships_x_fraction,x                                      ;
    sta temp9                                                         ;
    lda temp8                                                         ;
    adc enemy_ships_x_pixels,x                                        ;
    tay                                                               ;
    lda enemy_ships_x_screens,x                                       ;
    adc #0                                                            ;
    sta segment_angle                                                 ;
    lda temp9                                                         ;
    sec                                                               ;
    sbc enemy_ships_x_pixels,x                                        ;
    sta temp9                                                         ;
    tya                                                               ;
    sbc enemy_ships_x_screens,x                                       ;
    sta temp10                                                        ;
    lda segment_angle                                                 ;
    sbc #0                                                            ;
    sta segment_angle                                                 ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
apply_starship_rotation_and_velocity_to_enemy_ships
    lda starship_rotation_sine_magnitude                              ;
    bne starship_is_rotating                                          ;
    jmp apply_starship_velocity_to_enemy_ship                         ;

starship_is_rotating
    lda enemy_ships_previous_x_pixels,x                               ;
    clc                                                               ;
    adc #$80                                                          ;
    sta enemy_ships_x_pixels,x                                        ;
    bcc skip1                                                         ;
    inc enemy_ships_x_screens,x                                       ;
skip1
    lda enemy_ships_previous_y_pixels,x                               ;
    clc                                                               ;
    adc #$80                                                          ;
    sta enemy_ships_y_pixels,x                                        ;
    bcc skip2                                                         ;
    inc enemy_ships_y_screens,x                                       ;
skip2
    ldy starship_rotation                                             ;
    bmi skip_inversion1                                               ;
    lda enemy_ships_x_fraction,x                                      ;
    eor #$ff                                                          ;
    sta enemy_ships_x_fraction,x                                      ;

    lda enemy_ships_x_pixels,x                                        ;
    eor #$ff                                                          ;
    sta enemy_ships_x_pixels,x                                        ;

    lda enemy_ships_x_screens,x                                       ;
    eor #$ff                                                          ;
    sta enemy_ships_x_screens,x                                       ;
skip_inversion1
    stx temp_y
    txa                                                               ;
    clc                                                               ;
    adc #stride_between_enemy_coordinates                             ; X += stride
    tax                                                               ;

    jsr multiply_enemy_position_by_starship_rotation_sine_magnitude   ;

    ldx temp_y
    jsr multiply_enemy_position_by_starship_rotation_cosine           ;
    lda temp9                                                         ;
    clc                                                               ;
    adc output_pixels                                                 ;
    sta x_pixels                                                      ;
    lda temp10                                                        ;
    adc output_fraction                                               ;
    sta y_pixels                                                      ;
    lda segment_angle                                                 ;
    adc segment_length                                                ;
    sta temp11                                                        ;
    jsr multiply_enemy_position_by_starship_rotation_sine_magnitude   ;

    txa                                                               ;
    clc                                                               ;
    adc #stride_between_enemy_coordinates                             ; X += stride
    tax                                                               ;

    jsr multiply_enemy_position_by_starship_rotation_cosine           ;

    ldx temp_y
    lda temp9                                                         ;
    sec                                                               ;
    sbc output_pixels                                                 ;
    sta temp9                                                         ;
    lda temp10                                                        ;
    sbc output_fraction                                               ;
    sta temp10                                                        ;
    lda segment_angle                                                 ;
    sbc segment_length                                                ;
    sta segment_angle                                                 ;
    ldy starship_rotation_magnitude                                   ;
    lda x_pixels                                                      ;
    sec                                                               ;
    sbc rotated_x_correction_fraction,y                               ;
    eor starship_rotation_eor                                         ;
    sta enemy_ships_x_fraction,x                                      ;
    lda y_pixels                                                      ;
    sbc rotated_x_correction_pixels,y                                 ;
    eor starship_rotation_eor                                         ;
    sta enemy_ships_x_pixels,x                                        ;
    lda temp11                                                        ;
    sbc rotated_x_correction_screens,y                                ;
    eor starship_rotation_eor                                         ;
    sta enemy_ships_x_screens,x                                       ;
    lda temp9                                                         ;
    clc                                                               ;
    adc rotated_y_correction_fraction,y                               ;
    sta enemy_ships_y_fraction,x                                      ;
    lda temp10                                                        ;
    adc rotated_y_correction_pixels,y                                 ;
    sta enemy_ships_y_pixels,x                                        ;
    lda segment_angle                                                 ;
    adc rotated_y_correction_screens,y                                ;
    sta enemy_ships_y_screens,x                                       ;
    lda enemy_ships_y_pixels,x                                        ;
    sec                                                               ;
    sbc #$80                                                          ;
    sta enemy_ships_y_pixels,x                                        ;
    lda enemy_ships_y_screens,x                                       ;
    sbc #0                                                            ;
    sta enemy_ships_y_screens,x                                       ;
    lda enemy_ships_x_pixels,x                                        ;
    sec                                                               ;
    sbc #$80                                                          ;
    sta enemy_ships_x_pixels,x                                        ;
    lda enemy_ships_x_screens,x                                       ;
    sbc #0                                                            ;
    sta enemy_ships_x_screens,x                                       ;
apply_starship_velocity_to_enemy_ship
    lda enemy_ships_y_fraction,x                                      ;
    clc                                                               ;
    adc starship_velocity_low                                         ;
    sta enemy_ships_y_fraction,x                                      ;
    lda enemy_ships_y_pixels,x                                        ;
    adc starship_velocity_high                                        ;
    sta enemy_ships_y_pixels,x                                        ;
    lda enemy_ships_y_screens,x                                       ;
    adc #0                                                            ;
    sta enemy_ships_y_screens,x                                       ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
update_starship_torpedoes
    ldy #index_of_starship_torpedo_tails                              ; object index for start of starship torpedo tails
    sty torpedo_tail_index                                            ;
    ldy #index_of_starship_torpedo_heads                              ; object index for start of starship torpedo heads
    sty torpedo_head_index                                            ;

update_starship_torpedoes_loop
    ldy torpedo_head_index                                            ;
    lda object_table_time_to_live,y                                   ;
    bne torpedo_present                                               ;
    jmp update_next_torpedo                                           ;

torpedo_present
    ; Decrease torpedo time to live
    lda object_table_time_to_live,y                                   ;
    sec                                                               ;
    sbc #1                                                            ;
    sta object_table_time_to_live,y                                   ;

    bne torpedo_still_alive                                           ;
    dec number_of_live_starship_torpedoes                             ;

    jsr plot_expiring_torpedo                                         ;
    jmp update_next_torpedo                                           ;

torpedo_still_alive
    jsr plot_starship_torpedo                                         ; unplot old torpedo

    ; Starship torpedoes have a time to live and a position (x,y pixel and x,y fraction)
    ldy torpedo_head_index                                            ;
    jsr update_object_position_for_starship_rotation_and_speed        ;
    ldy torpedo_tail_index                                            ;
    jsr update_object_position_for_starship_rotation_and_speed        ;

    ; update head of torpedo

    ; find the difference between head and tail position
    ; multiply by four to get velocity
    ; store in (output_fraction, output_pixels)

    ; x coordinates
    ldy torpedo_head_index                                            ;
    ldx torpedo_tail_index                                            ;
    lda object_table_xfraction,y                                      ; x fraction for head of torpedo
    sec                                                               ;
    sbc object_table_xfraction,x                                      ; x fraction for tail of torpedo
    sta output_pixels                                                 ;

    ; get velocity
    lda object_table_xpixels,y                                        ; x pixels for head of torpedo
    sbc object_table_xpixels,x                                        ; x pixels for tail of torpedo
    asl output_pixels                                                 ; }
    rol                                                               ; }
    asl output_pixels                                                 ; } store difference * 4 = velocity
    rol                                                               ; }
    sta output_fraction                                               ; }

    ; y coordinates
    lda object_table_yfraction,y                                      ; y fraction for head of torpedo
    sec                                                               ;
    sbc object_table_yfraction,x                                      ; y fraction for tail of torpedo
    sta temp9                                                         ;
    lda object_table_ypixels,y                                        ; y pixels for head of torpedo
    sbc object_table_ypixels,x                                        ; y pixels for tail of torpedo
    asl temp9                                                         ; }
    rol                                                               ; }
    asl temp9                                                         ; } store difference * 4 = velocity
    rol                                                               ; }
    sta temp10                                                        ; }

    ; update head: position += velocity
    lda object_table_xfraction,y                                      ; x fraction for head of torpedo
    clc                                                               ;
    adc output_pixels                                                 ; add difference
    sta object_table_xfraction,y                                      ; store
    lda object_table_xpixels,y                                        ; x pixels for head of torpedo
    adc output_fraction                                               ; add difference
    sta object_table_xpixels,y                                        ; store

    lda object_table_yfraction,y                                      ; y fraction for head of torpedo
    clc                                                               ;
    adc temp9                                                         ; add difference
    sta object_table_yfraction,y                                      ; store

    lda object_table_ypixels,y                                        ; y pixels for head of torpedo
    adc temp10                                                        ; add difference
    sta object_table_ypixels,y                                        ; store

    ; update tail: position += velocity
    lda object_table_xfraction,x                                      ; x fraction for tail of torpedo
    clc                                                               ;
    adc output_pixels                                                 ; add difference
    sta object_table_xfraction,x                                      ; store

    lda object_table_xpixels,x                                        ; x pixels for tail of torpedo
    adc output_fraction                                               ; add difference
    sta object_table_xpixels,x                                        ; store

    lda object_table_yfraction,x                                      ; y fraction for tail of torpedo
    clc                                                               ;
    adc temp9                                                         ; add difference
    sta object_table_yfraction,x                                      ; store

    lda object_table_ypixels,x                                        ; y pixels for tail of torpedo
    adc temp10                                                        ; add difference
    sta object_table_ypixels,x                                        ; store

    jsr check_for_collision_with_enemy_ships                          ;
    bcs update_next_torpedo                                           ;

    ldy torpedo_head_index                                            ;
    ldx torpedo_tail_index                                            ; probably redundant
    lda object_table_time_to_live,y                                   ;
    cmp #2                                                            ;
    bcs plot_torpedo_at_new_position                                  ;
    jsr plot_expiring_torpedo                                         ;
    jmp update_next_torpedo                                           ;

plot_torpedo_at_new_position
    jsr plot_starship_torpedo                                         ;
update_next_torpedo
    inc torpedo_tail_index                                            ;
    inc torpedo_head_index                                            ;
    ldy torpedo_head_index                                            ;
    cpy #index_of_starship_torpedo_heads + maximum_number_of_starship_torpedoes ;
    beq return2                                                       ;
    jmp update_starship_torpedoes_loop                                ;

return2
    rts                                                               ;

; ----------------------------------------------------------------------------------
fire_starship_torpedo
    ldx #0                                                            ;
    stx torpedo_dir                                                   ; loop counter - three directions of spray

fire_torpedo_loop
    ; find a free slot
    lda number_of_live_starship_torpedoes                             ;
    cmp #maximum_number_of_starship_torpedoes                         ;
    bcs return3                                                       ;
    inc number_of_live_starship_torpedoes                             ;
    inc starship_fired_torpedo                                        ;
    ldy #index_of_starship_torpedo_heads                              ;
    ldx #index_of_starship_torpedo_tails                              ;
loop5
    lda object_table_time_to_live,y                                   ;
    beq found_empty_torpedo_slot                                      ;
    inx                                                               ;
    iny                                                               ;
    bne loop5                                                         ;
return3
    rts                                                               ;

; ----------------------------------------------------------------------------------
found_empty_torpedo_slot
    sty torpedo_head_index                                            ; for plot_starship_torpedo
    stx torpedo_tail_index                                            ; for plot_starship_torpedo

    lda #starship_torpedoes_time_to_live                              ;
    sta object_table_time_to_live,y                                   ; set time to live for starship torpedo

    stx temp_x                                                        ; store x
    ldx torpedo_dir                                                   ;
    lda torpedo_dir_table,x                                           ; get x fraction for current direction of spray
    ldx temp_x                                                        ; recall x

    sta object_table_xfraction,y                                      ; head x fraction
    lda #$7f                                                          ;
    sta object_table_xfraction,x                                      ; tail x fraction
    lda #$7f                                                          ;
    sta object_table_xpixels,y                                        ; head x pixels
    sta object_table_xpixels,x                                        ; tail x pixels
    lda #$80                                                          ;
    sta object_table_yfraction,y                                      ; head y fraction
    lda #$90                                                          ;
    sta object_table_yfraction,x                                      ; tail y fraction
    lda #$75                                                          ;
    sta object_table_ypixels,y                                        ; head y pixels
    lda #$77                                                          ;
    sta object_table_ypixels,x                                        ; tail y pixels
    lda #0                                                            ;
    sta how_enemy_ship_was_damaged                                    ;
    jsr check_for_collision_with_enemy_ships                          ;
    bcs next_torpedo_fire                                             ;

    jsr plot_starship_torpedo                                         ;
next_torpedo_fire
    inc torpedo_dir                                                   ;
    ldx torpedo_dir                                                   ;
    cpx #3                                                            ;
    bcc fire_torpedo_loop                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
torpedo_dir_table
    !byte $40, $7f, $c0

    ;   -21012
    ; -1 .ffg.
    ;  0 aabbc
    ;  1 .edd.
; ----------------------------------------------------------------------------------
plot_expiring_torpedo
    ldx object_table_xpixels,y                                        ; x coordinate
    lda object_table_ypixels,y                                        ; y coordinate
    sta y_pixels                                                      ;

    dex                                                               ;
    dex                                                               ;
    jsr eor_two_play_area_pixels                                      ; aa
    inx                                                               ;
    inx                                                               ;
    jsr eor_two_play_area_pixels_same_y                               ; bb
    inx                                                               ;
    inx                                                               ;
    jsr eor_play_area_pixel_same_y                                    ; c
    dex                                                               ;
    dex                                                               ;
    inc y_pixels                                                      ;
    jsr eor_two_play_area_pixels                                      ; dd
    dex                                                               ;
    jsr eor_play_area_pixel_same_y                                    ; e
    dec y_pixels                                                      ;
    dec y_pixels                                                      ;
    jsr eor_two_play_area_pixels                                      ; ff
    inx                                                               ;
    inx                                                               ;
    jmp eor_play_area_pixel_same_y                                    ; g

; ----------------------------------------------------------------------------------
unplot_long_range_scanner_if_shields_inactive
    lda starship_shields_active                                       ;
    beq return5                                                       ;
    lda #0                                                            ;
    sta starship_shields_active                                       ;
    jsr plot_top_and_right_edge_of_long_range_scanner_without_text    ;
    jsr plot_enemy_ships_on_scanners                                  ;
    ldy #$1f                                                          ; pixel in centre of long range scanner
    sty x_pixels                                                      ;
    iny                                                               ;
    sty y_pixels                                                      ;
    jsr unset_pixel                                                   ;
    ldx #regular_string_index_shields_on                              ;
    jmp print_regular_string                                          ;

return5
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_top_and_right_edge_of_long_range_scanner_with_blank_text
    lda starship_shields_active                                       ;
    bne return5                                                       ;
    lda #1                                                            ;
    sta starship_shields_active                                       ;
    ldx #regular_string_index_shields_off                             ;
    jsr print_regular_string                                          ;
    ; fall through...

; ----------------------------------------------------------------------------------
plot_top_and_right_edge_of_long_range_scanner_without_text
    ldx #0                                                            ;
    ldy #0                                                            ;
    lda #$3f                                                          ;
    jsr plot_horizontal_line_xy                                       ;
    ldx #$3f                                                          ;
    ldy #0                                                            ;
    lda #$40                                                          ;
    jmp plot_vertical_line_xy                                         ;

    ;-101
    ; .O.  2
    ; OOO  1
    ; OOO  0
    ; .O. -1
; ----------------------------------------------------------------------------------
plot_big_torpedo
    jmp plot_3x4

; ----------------------------------------------------------------------------------
plot_starship_torpedo

    ; Head of torpedo
    ldy torpedo_head_index                                            ; current torpedo head
    ldx object_table_xpixels,y                                        ; x coordinate
    lda object_table_ypixels,y                                        ; y coordinate
    sta y_pixels                                                      ;
    lda starship_torpedo_type                                         ;
    bne plot_big_torpedo                                              ;

small_starship_torpedoes
    jsr eor_play_area_pixel                                           ; Plot pixel for head of torpedo

    ; Tail of torpedo
    ldy torpedo_tail_index                                            ; current torpedo tail
    lda object_table_xpixels,y                                        ;
    sta x_pixels                                                      ;
    tax                                                               ; x coordinate
    lda object_table_ypixels,y                                        ;
    sta y_pixels                                                      ; y coordinate
    jsr eor_play_area_pixel                                           ; Plot pixel for tail of torpedo

    ; Middle of torpedo
    ; Add head and tail positions and divide by two to get the middle point between them
    ldy torpedo_head_index                                            ; current torpedo head
    ldx torpedo_tail_index                                            ; current torpedo tail

    ; y coordinate
    lda object_table_yfraction,y                                      ;
    clc                                                               ;
    adc object_table_yfraction,x                                      ; for the carry flag

    lda object_table_ypixels,y                                        ;
    adc y_pixels                                                      ;
    ror                                                               ;
    sta y_pixels                                                      ; y coordinate

    ; x coordinate
    lda object_table_xfraction,y                                      ;
    clc                                                               ;
    adc object_table_xpixels,x                                        ; for the carry flag

    lda object_table_xpixels,y                                        ;
    adc x_pixels                                                      ;
    ror                                                               ;
    tax                                                               ; x coordinate

    jmp eor_play_area_pixel                                           ; Plot pixel for middle of torpedo

; ----------------------------------------------------------------------------------
apply_rotation_to_starship_angle
    lda #0                                                            ;
    sta starship_angle_delta                                          ;
    ldx starship_rotation_magnitude                                   ;
    beq return6                                                       ;
    lda starship_angle_fraction                                       ;
    ldy starship_rotation                                             ;
    bpl subtract_fraction                                             ;
add_fraction
    clc                                                               ;
    adc #$52                                                          ;
    bcc skip6                                                         ;
    dec starship_angle_delta                                          ;
skip6
    dex                                                               ;
    bne add_fraction                                                  ;
    beq set_starship_angle_fraction                                   ;
subtract_fraction
    sec                                                               ;
    sbc #$52                                                          ;
    bcs skip7                                                         ;
    inc starship_angle_delta                                          ;
skip7
    dex                                                               ;
    bne subtract_fraction                                             ;
set_starship_angle_fraction
    sta starship_angle_fraction                                       ;
return6
    rts                                                               ;

; ----------------------------------------------------------------------------------
update_enemy_torpedoes
    lda #1                                                            ;
    sta how_enemy_ship_was_damaged                                    ; 1 = collision with their torpedoes
    lda #maximum_number_of_enemy_torpedoes                            ;
    sta torpedoes_still_to_consider                                   ;
    ldy #index_of_enemy_torpedoes                                     ;
update_enemy_torpedoes_loop
    sty current_enemy_torpedo_object_index                            ;
    sty current_object_index                                          ;
    lda object_table_time_to_live,y                                   ;
    bne enemy_torpedo_in_slot                                         ;
    jmp move_to_next_enemy_torpedo                                    ;

; ----------------------------------------------------------------------------------
enemy_torpedo_in_slot
    ; Decrease torpedo time to live
    lda object_table_time_to_live,y                                   ;
    sec                                                               ;
    sbc #1                                                            ;
    sta object_table_time_to_live,y                                   ;

    bne enemy_torpedo_still_alive                                     ;
    jsr plot_expiring_torpedo                                         ; unplot expiring torpedo
    jmp move_to_next_enemy_torpedo                                    ;

enemy_torpedo_still_alive
    jsr plot_enemy_torpedo                                            ; unplot torpedo
    ldy current_enemy_torpedo_object_index                            ;
    jsr update_object_position_for_starship_rotation_and_speed        ;
    lda object_table_angle,y                                          ;
    clc                                                               ;
    adc starship_angle_delta                                          ;
    sta object_table_angle,y                                          ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    tax                                                               ;
    lda cosine_table,x                                                ;
    clc                                                               ;
    adc object_table_ypixels,y                                        ;
    sta object_table_ypixels,y                                        ;
    sec                                                               ;
    sbc y_pixels                                                      ;
    bcs skip_inversion2                                               ;
    eor #$ff                                                          ;
skip_inversion2
    cmp #$40                                                          ;
    bcs remove_torpedo                                                ; Remove torpedo if off screen
    lda sine_table,x                                                  ;
    clc                                                               ;
    adc object_table_xpixels,y                                        ;
    sta object_table_xpixels,y                                        ;
    sec                                                               ;
    sbc x_pixels                                                      ;
    bcs skip_uninversion2                                             ;
    eor #$ff                                                          ;
skip_uninversion2
    cmp #$40                                                          ;
    bcc consider_collisions                                           ;
remove_torpedo
    lda #0                                                            ;
    sta object_table_time_to_live,y                                   ;
    jmp move_to_next_enemy_torpedo                                    ;

; ----------------------------------------------------------------------------------
consider_collisions
    lda object_table_xpixels,y                                        ; torpedo_x_pixels
    cmp #starship_maximum_x_for_collisions_with_enemy_torpedoes       ;
    bcs enemy_torpedo_missed_starship                                 ;
    cmp #starship_minimum_x_for_collisions_with_enemy_torpedoes       ;
    bcc enemy_torpedo_missed_starship                                 ;
    lda object_table_ypixels,y                                        ; torpedo_y_pixels
    cmp #starship_maximum_y_for_collisions_with_enemy_torpedoes       ;
    bcs enemy_torpedo_missed_starship                                 ;
    cmp #starship_minimum_y_for_collisions_with_enemy_torpedoes       ;
    bcc enemy_torpedo_missed_starship                                 ;
    jsr plot_expiring_torpedo                                         ;
    inc enemy_torpedo_hits_against_starship                           ;
    lda #damage_from_enemy_torpedo                                    ;
    jsr incur_damage                                                  ;
    lda #1                                                            ;
    ldy current_object_index                                          ;
    sta object_table_time_to_live,y                                   ; remove torpedo next turn
    jmp move_to_next_enemy_torpedo                                    ;

enemy_torpedo_missed_starship
    jsr check_for_collision_with_enemy_ships                          ;
    bcs move_to_next_enemy_torpedo                                    ;

    lda object_table_time_to_live,y                                   ;
    cmp #2                                                            ;
    bcs enemy_torpedo_ok                                              ;
    jsr plot_expiring_torpedo                                         ; torpedo has a final frame as a larger explosion
    jmp move_to_next_enemy_torpedo                                    ;

enemy_torpedo_ok
    jsr plot_enemy_torpedo                                            ; plot torpedo
move_to_next_enemy_torpedo
    inc current_enemy_torpedo_object_index                            ;
    ldy current_enemy_torpedo_object_index                            ;
    cpy #index_of_enemy_torpedoes + maximum_number_of_enemy_torpedoes ;
    beq finished_updating_torpedoes                                   ;
    jmp update_enemy_torpedoes_loop                                   ;

finished_updating_torpedoes
    rts                                                               ;

; ----------------------------------------------------------------------------------
check_for_collision_with_enemy_ships
    sty current_object_index                                          ;
    lda object_table_xpixels,y                                        ;
    sta temp3                                                         ; torpedo_x_pixels
    lda object_table_ypixels,y                                        ; torpedo_y_pixels
    sta temp4                                                         ;

    lda #maximum_number_of_enemy_ships                                ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
consider_enemy_slot
    lda enemy_ships_on_screen,x                                       ;
    bne move_to_next_enemy                                            ;
    lda enemy_ships_x_pixels,x                                        ;
    sec                                                               ;
    sbc temp3                                                         ; torpedo_x_pixels
    bcs skip_inversion_x1                                             ;
    eor #$ff                                                          ;
skip_inversion_x1
    cmp #size_of_enemy_ship_for_collisions_with_torpedoes             ;
    bcs move_to_next_enemy                                            ;
    lda enemy_ships_y_pixels,x                                        ;
    sec                                                               ;
    sbc temp4                                                         ; torpedo_y_pixels
    bcs skip_inversion_y1                                             ;
    eor #$ff                                                          ;
skip_inversion_y1
    cmp #size_of_enemy_ship_for_collisions_with_torpedoes             ;
    bcs move_to_next_enemy                                            ;
    lda enemy_ships_energy,x                                          ;
    bne skip_considering_explosion                                    ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    cmp #frame_of_enemy_ship_explosion_after_which_no_collisions      ;
    bcs skip_damage                                                   ;
    bcc move_to_next_enemy                                            ;
skip_considering_explosion
    inc enemy_ship_was_hit                                            ;
    inc enemy_ships_temporary_behaviour_flags,x                       ;
    lda how_enemy_ship_was_damaged                                    ;
    beq damaged_by_other                                              ;
    lda #damage_to_enemy_ship_from_starship_torpedo                   ;
    jmp collision_occurred                                            ;

damaged_by_other
    lda damage_to_enemy_ship_from_other_collision                     ;
collision_occurred
    jsr damage_enemy_ship                                             ;
skip_damage
    lda #1                                                            ;
    ldy current_object_index                                          ;
    sta object_table_time_to_live,y                                   ; remove torpedo next turn
    jsr plot_expiring_torpedo                                         ;
    sec                                                               ; the torpedo hit something
    rts                                                               ;

move_to_next_enemy
    inx                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    bne consider_enemy_slot                                           ;
    clc                                                               ; the torpedo didn't hit anything
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_enemy_torpedo
    ldx object_table_xpixels,y                                        ; x coordinate
    lda object_table_ypixels,y                                        ;
    sta y_pixels                                                      ;
enemy_torpedo_type_instruction
    jsr eor_play_area_pixel                                           ; self modifying code
    ; ... actually JMP if option_enemy_torpedoes is zero, (for small enemy torpedoes)

    ; draw the large enemy torpedoes
    inx                                                               ;
    jsr eor_play_area_pixel_same_y                                    ;
    inc y_pixels                                                      ;
    dex                                                               ;
    jmp eor_two_play_area_pixels                                      ;

; ----------------------------------------------------------------------------------
apply_velocity_to_enemy_ships
    lda #maximum_number_of_enemy_ships                                ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
apply_velocity_to_enemy_ships_loop
    jsr apply_starship_rotation_and_velocity_to_enemy_ships           ;
    lda enemy_ships_previous_angle,x                                  ;
    clc                                                               ;
    adc starship_angle_delta                                          ;
    sta enemy_ships_angle,x                                           ;
    lda enemy_ships_velocity,x                                        ;
    sta temp7                                                         ;
    beq skip_subtraction_cosine                                       ;
    lda enemy_ships_previous_angle,x                                  ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    tay                                                               ;
    lda sine_table,y                                                  ;
    sta temp3                                                         ;
    lda cosine_table,y                                                ;
    sta temp4                                                         ;

    ; 5-bit multiplication of sine by enemy ship velocity
    ldy #5                                                            ;
    lda #0                                                            ;
    sta temp8                                                         ;
loop_over_bits_of_sine
    lsr temp3                                                         ;
    bcc sine_bit_unset                                                ;
    clc                                                               ;
    adc temp7                                                         ;
sine_bit_unset
    ror                                                               ;
    ror temp8                                                         ;
    dey                                                               ;
    bne loop_over_bits_of_sine                                        ;

    tay                                                               ;
    lda enemy_ships_x_fraction,x                                      ;
    adc temp8                                                         ;
    sta enemy_ships_x_fraction,x                                      ;
    tya                                                               ;
    adc enemy_ships_x_pixels,x                                        ;
    sta enemy_ships_x_pixels,x                                        ;
    bcc skip9                                                         ;
    inc enemy_ships_x_screens,x                                       ;
skip9
    ldy temp3                                                         ;
    beq skip_subtraction_sine                                         ;
    sec                                                               ;
    sbc temp7                                                         ;
    sta enemy_ships_x_pixels,x                                        ;
    bcs skip_subtraction_sine                                         ;
    dec enemy_ships_x_screens,x                                       ;
skip_subtraction_sine

    ; 5-bit multiplication of cosine by enemy ship velocity
    ldy #5                                                            ;
    lda #0                                                            ;
    sta temp8                                                         ;
loop_over_bits_of_cosine
    lsr temp4                                                         ;
    bcc cosine_bit_unset                                              ;
    clc                                                               ;
    adc temp7                                                         ;
cosine_bit_unset
    ror                                                               ;
    ror temp8                                                         ;
    dey                                                               ;
    bne loop_over_bits_of_cosine                                      ;

    tay                                                               ;
    lda enemy_ships_y_fraction,x                                      ;
    adc temp8                                                         ;
    sta enemy_ships_y_fraction,x                                      ;
    tya                                                               ;
    adc enemy_ships_y_pixels,x                                        ;
    sta enemy_ships_y_pixels,x                                        ;
    bcc skip10                                                        ;
    inc enemy_ships_y_screens,x                                       ;
skip10
    ldy temp4                                                         ;
    beq skip_subtraction_cosine                                       ;
    sec                                                               ;
    sbc temp7                                                         ;
    sta enemy_ships_y_pixels,x                                        ;
    bcs skip_subtraction_cosine                                       ;
    dec enemy_ships_y_screens,x                                       ;
skip_subtraction_cosine
mark_enemy_ship_as_plotted_if_on_starship_screen
    lda #$7f                                                          ;
    cmp enemy_ships_x_screens,x                                       ;
    bne enemy_ship_not_on_starship_screen                             ;
    cmp enemy_ships_y_screens,x                                       ;
    bne enemy_ship_not_on_starship_screen                             ;
    lda #0                                                            ;
    beq set_enemy_ships_on_screen                                     ;
enemy_ship_not_on_starship_screen
    lda #1                                                            ;
set_enemy_ships_on_screen
    sta enemy_ships_on_screen,x                                       ;
    inx                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    beq return7                                                       ;
    jmp apply_velocity_to_enemy_ships_loop                            ;

return7
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_enemy_update_explosion
    ; update explosion
    ldy enemy_ships_still_to_consider                                 ;
    lda enemy_ships_explosion_number - 1,y                            ;
    tay                                                               ;
    lda enemy_explosion_address_low_table - 1,y                       ;
    sta temp5                                                         ;
    lda enemy_explosion_address_high_table - 1,y                      ;
    sta temp6                                                         ;
    lda enemy_ship_was_previously_on_screen                           ; 0=previously on screen, $ff=otherwise
    bne not_previously_on_screen                                      ;
    dec enemy_ship_was_previously_on_screen                           ; set not previously on screen (=$ff)
    jsr update_enemy_explosion_pieces                                 ;

not_previously_on_screen
    ; wait for explosion to finish
    dec enemy_ships_flags_or_explosion_timer,x                        ;
    bne return7                                                       ;

    ; increment enemy velocity
    lda desired_velocity_for_intact_enemy_ships                       ;
    cmp #enemy_full_speed                                             ; full speed
    bcs +                                                             ;
    inc desired_velocity_for_intact_enemy_ships                       ;
+
    ; create new ship
    jmp initialise_enemy_ship                                         ;

; ----------------------------------------------------------------------------------
plot_enemy_ships
    ; initialize the array to ones (nothing done yet)
    lda #(1<<maximum_number_of_enemy_ships)-1                         ;
    sta enemy_ship_update_done                                        ;

retry_loop
    ldx #0
    lda #maximum_number_of_enemy_ships                                ;
    sta enemy_ships_still_to_consider                                 ;

plot_enemy_ships_loop
; ----------------------------------------------------------------------------------
; On Exit:
;   Preserves X
; ----------------------------------------------------------------------------------
try_plot_enemy_ship
    ldy enemy_ships_still_to_consider                                 ;
    lda xbit_table,x                                                  ;
    bit enemy_ship_update_done                                        ;
    beq skip_enemy_altogether                                         ; if (already updated) then branch

    lda enemy_ships_on_screen,x                                       ;
    bne not_on_screen_a                                               ;

!if (elk=0) or (elk+antiflicker=2) {
    ; check if we are in the danger zone, if so then skip this one
    lda enemy_ships_y_pixels,x                                        ;
    jsr is_in_danger_area                                             ;
    bcc skip_enemy_altogether                                         ; if in danger zone, skip this enemy
}

not_on_screen_a
    ; DEBUG
    ; jsr debug_make_background_green

    lda enemy_ships_previous_on_screen,x                              ;
    sta enemy_ship_was_previously_on_screen                           ;
    lda enemy_ships_energy,x                                          ;
    bne skip_explosion                                                ; if (non zero energy) then branch

    jsr plot_enemy_update_explosion                                   ;

skip_explosion
    lda enemy_ships_on_screen,x                                       ;
    sta enemy_ship_was_on_screen                                      ;
    bne not_on_screen                                                 ;

    ; if enemy ship has run out of energy, mark as off screen
    lda enemy_ships_energy,x                                          ;
    bne skip30                                                        ;
    dec enemy_ship_was_on_screen                                      ;

not_on_screen
skip30
    lda enemy_ship_was_previously_on_screen                           ;
    bne skip_unplotting                                               ; if not previously on screen, skip unplot

unplot_enemy_ship
    jsr plot_enemy_ship                                               ; unplot
skip_unplotting
    lda enemy_ships_angle,x                                           ;
    sta enemy_ships_previous_angle,x                                  ;
    lda enemy_ships_y_pixels,x                                        ;
    sta enemy_ships_previous_y_pixels,x                               ;
    lda enemy_ships_x_pixels,x                                        ;
    sta enemy_ships_previous_x_pixels,x                               ;
    lda enemy_ship_was_on_screen                                      ;
    beq plot_enemy_ship_and_copy_position                             ; if (was on screen) then branch (to plot)
    bpl copy_position_without_plotting                                ; if (not exploding) then branch

    jsr plot_enemy_ship_explosion                                     ; plot explosion
    jmp copy_position_without_plotting                                ;

plot_enemy_ship_and_copy_position
    jsr plot_enemy_ship                                               ;

copy_position_without_plotting
    ; DEBUG
    ; jsr debug_make_background_black

    ; mark enemy as done
    lda enemy_ship_update_done                                        ;
    eor xbit_table,x                                                  ;
    sta enemy_ship_update_done                                        ;

    lda enemy_ships_on_screen,x                                       ;
    sta enemy_ships_previous_on_screen,x                              ;

    ; store position off screen
    lda enemy_ships_y_screens,x                                       ;
    sta enemy_ships_previous_y_screens,x                              ;
    lda enemy_ships_y_fraction,x                                      ;
    sta enemy_ships_previous_y_fraction,x                             ;
    lda enemy_ships_x_screens,x                                       ;
    sta enemy_ships_previous_x_screens,x                              ;
    lda enemy_ships_x_fraction,x                                      ;
    sta enemy_ships_previous_x_fraction,x                             ;

skip_enemy_altogether
    ; check if all enemies have updated
    lda enemy_ship_update_done                                        ;
    beq return8                                                       ;

    ; move X onto next enemy
    inx                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    beq retry_loop
    bne plot_enemy_ships_loop                                         ;

return8
    rts                                                               ;

; ----------------------------------------------------------------------------------
;debug_make_background_black
;    pha
;    php
;    ; DEBUG
;    LDA #$07
;    STA videoULAPaletteRegister
;    LDA #$17
;    STA videoULAPaletteRegister
;    LDA #$27
;    STA videoULAPaletteRegister
;    LDA #$37
;    STA videoULAPaletteRegister
;    LDA #$47
;    STA videoULAPaletteRegister
;    LDA #$57
;    STA videoULAPaletteRegister
;    LDA #$67
;    STA videoULAPaletteRegister
;    LDA #$77
;    STA videoULAPaletteRegister
;    plp
;    pla
;    RTS
;
;debug_make_background_green
;    ; DEBUG
;    pha
;    php
;    LDA #$05
;    STA videoULAPaletteRegister
;    LDA #$15
;    STA videoULAPaletteRegister
;    LDA #$25
;    STA videoULAPaletteRegister
;    LDA #$35
;    STA videoULAPaletteRegister
;    LDA #$45
;    STA videoULAPaletteRegister
;    LDA #$55
;    STA videoULAPaletteRegister
;    LDA #$65
;    STA videoULAPaletteRegister
;    LDA #$75
;    STA videoULAPaletteRegister
;    plp
;    pla
;    rts


; ----------------------------------------------------------------------------------
check_for_starship_collision_with_enemy_ships
    lda #maximum_number_of_enemy_ships                                ;
    sta enemy_ships_still_to_consider                                 ;
    lda #0                                                            ;
    sta temp0_low                                                     ;
check_for_starship_collision_with_enemy_ships_loop
    ldx temp0_low                                                     ;
    lda enemy_ships_on_screen,x                                       ;
    bne to_consider_next_enemy_ship                                   ;
    lda enemy_ships_energy,x                                          ;
    bne check_for_collision                                           ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    cmp #frame_of_enemy_ship_explosion_after_which_no_collisions      ;
    bcs check_for_collision                                           ;
to_consider_next_enemy_ship
    jmp consider_next_enemy_ship                                      ;

; ----------------------------------------------------------------------------------
check_for_collision
    lda starship_has_exploded                                         ;
    beq starship_not_exploded                                         ;
    lda starship_explosion_countdown                                  ;
    cmp #frame_of_starship_explosion_after_which_no_collisions        ;
    bcc no_collision                                                  ;
starship_not_exploded
    lda enemy_ships_x_pixels,x                                        ;
    cmp #starship_maximum_x_for_collisions_with_enemy_ships           ;
    bcs no_collision                                                  ;
    cmp #starship_minimum_x_for_collisions_with_enemy_ships           ;
    bcc no_collision                                                  ;
    lda enemy_ships_y_pixels,x                                        ;
    cmp #starship_maximum_y_for_collisions_with_enemy_ships           ;
    bcs no_collision                                                  ;
    cmp #starship_minimum_y_for_collisions_with_enemy_ships           ;
    bcc no_collision                                                  ;
    lda enemy_ships_energy,x                                          ;
    beq incur_damage_from_passing_through_explosion                   ;
    pha                                                               ;
    inc starship_collided_with_enemy_ship                             ;
    lda #0                                                            ;
    sta enemy_ships_energy,x                                          ;
    jsr explode_enemy_ship                                            ;
    pla                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc #additional_damage_from_collision_with_enemy_ship             ;
    bcc incur_damage_from_collision                                   ;
    lda #$ff                                                          ;
    bne incur_damage_from_collision                                   ;
incur_damage_from_passing_through_explosion
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    lsr                                                               ;
incur_damage_from_collision
    jsr incur_damage                                                  ;
no_collision
    stx temp1_low                                                     ;
    ldx enemy_ships_still_to_consider                                 ;
    dex                                                               ;
    stx torpedoes_still_to_consider                                   ;
    bne check_for_collisions_between_enemy_ships                      ;
return9
    rts                                                               ;

; ----------------------------------------------------------------------------------
check_for_collisions_between_enemy_ships
    inc temp1_low                                                     ;
    ldx temp1_low                                                     ;
    lda enemy_ships_on_screen,x                                       ;
    bne consider_next_second_enemy_ship                               ; not if not on screen
    ldy temp0_low                                                     ; enemy_ship_offset
    lda enemy_ships_x_pixels,x                                        ;
    sec                                                               ;
    sbc enemy_ships_x_pixels,y                                        ;
    bcs skip_inversion_x2                                             ;
    eor #$ff                                                          ;
skip_inversion_x2
    cmp #size_of_enemy_ship_for_collisions_between_enemy_ships        ;
    bcs consider_next_second_enemy_ship                               ;
    sta enemy_ships_collision_x_difference                            ;
    lda enemy_ships_y_pixels,x                                        ;
    sec                                                               ;
    sbc enemy_ships_y_pixels,y                                        ;
    bcs skip_inversion_y2                                             ;
    eor #$ff                                                          ;
skip_inversion_y2
    cmp #size_of_enemy_ship_for_collisions_between_enemy_ships        ;
    bcs consider_next_second_enemy_ship                               ;
    sta enemy_ships_collision_y_difference                            ;
    lda enemy_ships_energy,x                                          ;
    bne second_ship_not_exploding                                     ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    cmp #frame_of_enemy_ship_explosion_after_which_no_collisions      ;
    bcs to_collide_enemy_ships                                        ;
    bcc consider_next_second_enemy_ship                               ;
second_ship_not_exploding
    inc enemy_ships_collided_with_each_other                          ;
    sec                                                               ;
    sbc #damage_enemy_ship_incurs_from_collision_with_other_enemy_ship ;
    bcs skip11                                                        ;
    lda #0                                                            ;
skip11
    sta enemy_ships_energy,x                                          ;
    bne enemy_ship_isnt_destroyed_by_collision                        ;
    lda enemy_ships_still_to_consider                                 ;
    pha                                                               ;
    lda torpedoes_still_to_consider                                   ;
    sta enemy_ships_still_to_consider                                 ;
    jsr explode_enemy_ship                                            ;
    pla                                                               ;
    sta enemy_ships_still_to_consider                                 ;
enemy_ship_isnt_destroyed_by_collision
    lda enemy_ships_type,x                                            ;
    cmp #4                                                            ;
    bcc to_collide_enemy_ships                                        ;
    and #3                                                            ; uncloak ship in collision
    sta enemy_ships_type,x                                            ;
    lda #1                                                            ;
    sta enemy_ships_previous_on_screen,x                              ;
to_collide_enemy_ships
    jmp collide_enemy_ships                                           ;

consider_next_second_enemy_ship
    dec torpedoes_still_to_consider                                   ;
    beq consider_next_enemy_ship                                      ;
    jmp check_for_collisions_between_enemy_ships                      ;

consider_next_enemy_ship
    inc temp0_low                                                     ;
    dec enemy_ships_still_to_consider                                 ;
    beq return9                                                       ;
    jmp check_for_starship_collision_with_enemy_ships_loop            ;

; ----------------------------------------------------------------------------------
plot_segment
    ; check if we are close to the side of the screen.
    ; If not we can forego the boundary checks and run faster.
    lda temp10                                                        ;
    cmp #16                                                           ;
    bcc plot_segment_with_boundary_checks                             ;
    cmp #256 - 16                                                     ;
    bcs plot_segment_with_boundary_checks                             ;
!if rom_writes {
    ; fast path now includes going off the top/bottom of the screen
} else {
    lda temp9                                                         ;
    cmp #16                                                           ;
    bcc plot_segment_with_boundary_checks                             ;
    cmp #256 - 16                                                     ;
    bcs plot_segment_with_boundary_checks                             ;
}
    lda segment_angle_change_per_pixel                                ;
    cmp #1                                                            ;
    beq plot_segment_unrolled                                         ;

    ldx x_pixels                                                      ;
plot_segment_regular_loop
    jsr eor_play_area_pixel                                           ;

    ldy segment_angle                                                 ;
    txa                                                               ;
    clc                                                               ;
    adc segment_angle_to_x_deltas_table,y                             ; update x
    tax                                                               ;

    lda segment_angle_to_y_deltas_table,y                             ;
    clc                                                               ;
    adc y_pixels                                                      ; update y
    sta y_pixels                                                      ;

    tya                                                               ;
    clc                                                               ;
    adc segment_angle_change_per_pixel                                ; update angle
    and #$1f                                                          ;
    sta segment_angle                                                 ;

    dec segment_length                                                ;
    bne plot_segment_regular_loop                                     ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_segment_with_boundary_checks
    ldx x_pixels                                                      ;

plot_segment_loop
    jsr eor_pixel_with_boundary_check                                 ;

    ldy segment_angle                                                 ;
    txa                                                               ;
    clc                                                               ;
    adc segment_angle_to_x_deltas_table,y                             ; update x
    tax                                                               ;

    lda segment_angle_to_y_deltas_table,y                             ;
    clc                                                               ;
    adc y_pixels                                                      ; update y
    sta y_pixels                                                      ;

    tya                                                               ;
    clc                                                               ;
    adc segment_angle_change_per_pixel                                ; update angle
    and #$1f                                                          ;
    sta segment_angle                                                 ;

    dec segment_length                                                ;
    bne plot_segment_loop                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_segment_unrolled
    ldx segment_angle                                                 ; based on start angle,
    lda plot_table_offset_low,x                                       ; look up in a table
    sta jump_address                                                  ; the address we jump to (low byte)
    lda plot_table_offset_high,x                                      ; look up in a table
    sta jump_address+1                                                ; the address we jump to (high byte)
    txa                                                               ;
    clc                                                               ;
    adc segment_length                                                ; add the segment length
    tax                                                               ;
    lda plot_table_offset_low-1,x                                     ;
    sta codeptr_low                                                   ;
    lda plot_table_offset_high-1,x                                    ;
    sta codeptr_high                                                  ;
    ldy #0                                                            ;
    lda (codeptr_low),y                                               ;
    sta temp_x                                                        ; remember the opcode
    lda #$60                                                          ; store opcode for RTS
    sta (codeptr_low),y                                               ;

    ; initialize X,Y cell offsets and accumulator for current pixel
    ldx x_pixels                                                      ;
    ldy y_pixels                                                      ;
    lda row_table_low,y                                               ;
    and #$f8                                                          ;
    clc                                                               ;
    adc xandf8,x                                                      ;
    sta screen_address_low                                            ;
    lda play_area_row_table_high,y                                    ;
    adc #0                                                            ;
    sta screen_address_high                                           ;
    txa                                                               ;
    and #7                                                            ;
    tax                                                               ;
    tya                                                               ;
    and #7                                                            ;
    tay                                                               ;
    lda xbit_table,x                                                  ;

jump_address = * + 1
    jsr $0000                                                         ;
finish_object
    eor (screen_address_low),y                                        ; write final byte
    sta (screen_address_low),y                                        ;
    lda temp_x                                                        ; recall opcode
    ldy #0                                                            ;
    sta (codeptr_low),y                                               ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
leftfix
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
leftfix2
    lda screen_address_low                                            ;
    sec                                                               ;
    sbc #8                                                            ;
    sta screen_address_low                                            ;
    bcs +                                                             ;
    dec screen_address_high                                           ;
+
    ldx #7                                                            ;
    lda #0                                                            ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
rightfix
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
rightfix2
    lda screen_address_low                                            ;
    clc                                                               ;
    adc #8                                                            ;
    sta screen_address_low                                            ;
    bcc +                                                             ;
    inc screen_address_high                                           ;
+
    ldx #0                                                            ;
    txa                                                               ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
downfix
    lda #$40                                                          ;
downfix_with_offset
    clc                                                               ;
    adc screen_address_low                                            ;
    sta screen_address_low                                            ;
    inc screen_address_high                                           ;
    bcc +                                                             ;
    inc screen_address_high                                           ;
+
!if rom_writes {
    bmi offscreen_down                                                ;
}
    ldy #0                                                            ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
downrightfix
    cpx #8                                                            ; if (x != 8) then right doesn't need fixing,
    bne downfix                                                       ; so it must be down that does
                                                                      ; (we know *something* does)
    ; right needs fixing. does down need fixing too?
    cpy #8                                                            ;
    bne rightfix2                                                     ; if (y != 8) then only fix right

    ; fix both
    ldx #0                                                            ; fix right
    lda #$48                                                          ;
    bne downfix_with_offset                                           ; ALWAYS branch

; ----------------------------------------------------------------------------------
downleftfix
    cpx #$ff                                                          ;
    bne downfix                                                       ; if (x != 255) then left doesn't need fixing (down does)

    ; left needs fixing. does down need fixing too?
    cpy #8                                                            ;
    bne leftfix2                                                      ; if (y != 8) then down doesn't need fixing (left does)

    ; fix down and left
    ldx #7                                                            ; fix left
    lda #$38                                                          ;
    bne downfix_with_offset                                           ; ALWAYS branch

; ----------------------------------------------------------------------------------
upfix
    lda #$100-$40                                                     ;
upfix_with_offset
    clc                                                               ;
    adc screen_address_low                                            ;
    sta screen_address_low                                            ;
    lda screen_address_high                                           ;
    sbc #1                                                            ;
    sta screen_address_high                                           ;
!if rom_writes {
    cmp #$58                                                          ;
}
    ldy #7                                                            ;
!if rom_writes {
    bcc offscreen_up                                                  ;
}
-
    rts                                                               ;

; ----------------------------------------------------------------------------------
!if rom_writes {
offscreen_down
    ldy #0                                                            ;
    ; if screen address >$8000 then we're off the bottom
    ; we leave the address unchanged, writing to ROM (but that's OK)
    lda screen_address_high                                           ;
    cmp #$98                                                          ;
    bcc -                                                             ;
    ; we've just moved back onto the top of the screen
    ; subtract $4000 to reinstate the screen address

offscreen_up
    ; if screen address <$5800 then we're off the top
    ; we add $4000 to make the address <$9800, which is also in ROM.
    eor #$c0                                                          ;
    sta screen_address_high                                           ;
    rts                                                               ;
}

; ----------------------------------------------------------------------------------
upleftfix
    cpx #$ff                                                          ;
    bne upfix                                                         ; if (x != 255) then left doesn't need fixing (but up does)

    ; left needs fixing. does up need fixing too?
    cpy #$ff                                                          ;
    bne leftfix2                                                      ; if (y != 255) then up doesn't need fixing (but left does)

    ; fix both
    ldx #7                                                            ; fix left
    lda #$100-$40-$8                                                  ;
    bne upfix_with_offset                                             ; ALWAYS branch

; ----------------------------------------------------------------------------------
uprightfix
    cpx #8                                                            ;
    bne upfix                                                         ; if (x != 8) then right doesn't need fixing (but up does)

    ; fix right. does up need fixing too?
    ldx #0                                                            ; fix right
    cpy #$ff                                                          ;
    bne rightfix2                                                     ; if (y != 255) then fix right

    ; fix up.
    lda #$100-$40+$8                                                  ;
    bne upfix_with_offset                                             ; ALWAYS branch


; ----------------------------------------------------------------------------------
handle_player_movement
    lda #0                                                            ;
    sta rotation_delta                                                ;
    sta velocity_delta                                                ;
    sta fire_pressed                                                  ;
    sta shields_state_delta                                           ;
    ldx starship_torpedo_cooldown                                     ;
    beq reset_starship_torpedo_round                                  ;
    dec starship_torpedo_cooldown                                     ;
    bpl skip_reset_starship_torpedo_round                             ; ALWAYS branch

; ----------------------------------------------------------------------------------
reset_starship_torpedo_round
    lda #starship_torpedoes_per_round                                 ;
    sta starship_torpedo_counter                                      ;
skip_reset_starship_torpedo_round
    jsr check_for_keypresses                                          ;
    +finish_keyboard_read                                             ;
    lda starship_destroyed                                            ;
    beq starship_isnt_destroyed                                       ;
    jmp player_isnt_firing                                            ;

starship_isnt_destroyed
    lda velocity_delta                                                ;
    bne player_is_accelerating                                        ;
    lda velocity_damper                                               ;
    beq finished_accelerating                                         ;
    lda #starship_acceleration_from_velocity_damper                   ;
    jmp set_deceleration                                              ;

; ----------------------------------------------------------------------------------
player_is_accelerating
    bmi starship_is_decelerating                                      ;
    lda #starship_acceleration_from_player                            ;
    sta temp8                                                         ;
    clc                                                               ;
    adc starship_velocity_low                                         ;
    sta starship_velocity_low                                         ;
    bcc skip12                                                        ;
    inc starship_velocity_high                                        ;
skip12
    lda starship_velocity_high                                        ;
    cmp #maximum_starship_velocity                                    ;
    bcc incur_damage_from_acceleration                                ;
    lda #maximum_starship_velocity                                    ;
    sta starship_velocity_high                                        ;
    lda #0                                                            ;
    sta starship_velocity_low                                         ;
    beq finished_accelerating                                         ;
starship_is_decelerating
    lda #starship_acceleration_from_player                            ;
set_deceleration
    sta temp8                                                         ;
    lda starship_velocity_low                                         ;
    sec                                                               ;
    sbc temp8                                                         ;
    sta starship_velocity_low                                         ;
    bcs incur_damage_from_acceleration                                ;
    dec starship_velocity_high                                        ;
    bpl incur_damage_from_acceleration                                ;
    lda #0                                                            ;
    sta starship_velocity_low                                         ;
    sta starship_velocity_high                                        ;
    beq finished_accelerating                                         ;
incur_damage_from_acceleration
    lda #starship_energy_drain_from_acceleration                      ;
    jsr incur_low_damage                                              ;
finished_accelerating
    lda starship_rotation_fraction                                    ;
    ldy rotation_delta                                                ;
    bne player_is_turning                                             ;
    ldy rotation_damper                                               ;
    beq finished_rotating                                             ;
    ldx starship_rotation                                             ;
    bpl starship_was_turned_clockwise                                 ;
    dex                                                               ;
    bpl finished_rotating                                             ;
    sec                                                               ;
    sbc #strength_of_rotation_dampers                                 ;
    jmp store_rotation                                                ;

; ----------------------------------------------------------------------------------
starship_was_turned_clockwise
    clc                                                               ;
    adc #strength_of_rotation_dampers                                 ;
    jmp set_starship_rotation_fraction_and_consider_rotating          ;

; ----------------------------------------------------------------------------------
player_is_turning
    bpl player_is_turning_clockwise                                   ;
    sec                                                               ;
    sbc #strength_of_player_rotation                                  ;
store_rotation
    sta starship_rotation_fraction                                    ;
    bcs incur_energy_drain_from_rotation                              ;
    lda #$7b                                                          ;
    cmp starship_rotation                                             ;
    bne rotate_starship_anticlockwise                                 ;
    lda #0                                                            ;
    beq set_starship_rotation_fraction                                ;
player_is_turning_clockwise
    clc                                                               ;
    adc #strength_of_player_rotation                                  ;
set_starship_rotation_fraction_and_consider_rotating
    sta starship_rotation_fraction                                    ;
    bcc incur_energy_drain_from_rotation                              ;
    lda #$85                                                          ;
    cmp starship_rotation                                             ;
    bne rotate_starship_clockwise                                     ;
    lda #$ff                                                          ;
set_starship_rotation_fraction
    sta starship_rotation_fraction                                    ;
    jmp finished_rotating                                             ;

rotate_starship_clockwise
    inc starship_rotation                                             ;
    bne continue                                                      ;
rotate_starship_anticlockwise
    dec starship_rotation                                             ;
continue
    clc                                                               ;
    ldx #0
    lda starship_rotation                                             ;
    bmi skip_inversion3                                               ;
    dex
    eor #$ff                                                          ;
    adc #1                                                            ;
skip_inversion3
    adc #$80                                                          ;
    tay                                                               ;
    sta starship_rotation_magnitude                                   ;
    stx starship_rotation_eor
    lda starship_rotation_sine_table,y                                ;
    sta starship_rotation_sine_magnitude                              ;
    lda starship_rotation_cosine_table,y                              ;
    sta starship_rotation_cosine                                      ;
    jsr init_self_modifying_bytes_for_starship_rotation               ;
incur_energy_drain_from_rotation
    lda #starship_energy_drain_from_non_zero_rotation                 ;
    jsr incur_low_damage                                              ;
finished_rotating
    lda fire_pressed                                                  ;
    beq player_isnt_firing                                            ;
    lda starship_torpedo_cooldown                                     ;
    bne player_isnt_firing                                            ;
    dec starship_torpedo_counter                                      ;
    bne not_end_of_round                                              ;
    lda #starship_torpedoes_per_round                                 ;
    sta starship_torpedo_counter                                      ;
    lda #starship_torpedo_cooldown_after_round                        ;
    bne set_starship_torpedo_cooldown                                 ; ALWAYS branch

not_end_of_round
    lda #starship_torpedo_cooldown_after_firing                       ;
set_starship_torpedo_cooldown
    sta starship_torpedo_cooldown                                     ;
    jsr fire_starship_torpedo                                         ;
    lda starship_fired_torpedo                                        ;
    beq player_isnt_firing                                            ;
    lda #starship_energy_drain_from_firing_torpedo                    ;
    jsr incur_low_damage                                              ;
player_isnt_firing
    jsr plot_auto_shields_string                                      ;
    lda starship_automatic_shields                                    ;
    sta previous_starship_automatic_shields                           ;
    beq skip_shield_activation                                        ;
    lda scanner_failure_duration                                      ;
    bne skip_shield_activation                                        ;
    jsr activate_shields_when_enemy_ship_enters_main_square           ;
skip_shield_activation
    lda shields_state_delta                                           ;
    beq return11                                                      ;
    ldx #regular_string_index_shield_state_on                         ;
    stx starship_automatic_shields                                    ;
    stx previous_starship_automatic_shields                           ;
    tay                                                               ;
    bmi plot_shields_on_and_consider_activation                       ;
    ldx #regular_string_index_shield_state_off                        ;
    jsr plot_shields_string_and_something                             ;
    jmp plot_top_and_right_edge_of_long_range_scanner_with_blank_text ;

plot_shields_on_and_consider_activation
    jsr plot_shields_string_and_something                             ;
    jmp unplot_long_range_scanner_if_shields_inactive                 ;

; ----------------------------------------------------------------------------------
incur_damage

!if cheat=0 {
    stx value_of_x_when_incur_damage_called                           ;
    ldx starship_shields_active                                       ;
    beq shields_are_active                                            ;
    asl                                                               ; Four times the damage when shields off
    bcc skip13                                                        ;
    inc damage_high                                                   ;
skip13
    asl                                                               ;
    bcc shields_are_active                                            ;
    inc damage_high                                                   ;
shields_are_active
    ldx value_of_x_when_incur_damage_called                           ;
}

incur_low_damage

!if cheat=0 {
    clc                                                               ;
    adc damage_low                                                    ;
    sta damage_low                                                    ;
    bcc return11                                                      ;
    inc damage_high                                                   ;
}

return11
    rts                                                               ;

; ----------------------------------------------------------------------------------
update_various_starship_statuses_on_screen
    jsr apply_damage_to_starship_energy                               ;
    jmp plot_starship_velocity_and_rotation_on_gauges                 ;

apply_damage_to_starship_energy
    lda starship_energy_low                                           ;
    sec                                                               ;
    sbc damage_low                                                    ;
    sta starship_energy_low                                           ;
    lda starship_energy_high                                          ;
    sbc damage_high                                                   ;
    sta starship_energy_high                                          ;
    lda starship_energy_low                                           ;
    clc                                                               ;
    adc starship_energy_regeneration                                  ;
    sta starship_energy_low                                           ;
    bcc skip14                                                        ;
    inc starship_energy_high                                          ;
skip14
    lda starship_energy_high                                          ;
    bpl starship_still_has_energy                                     ;
    jsr explode_starship                                              ;
    lda #0                                                            ;
    sta starship_energy_low                                           ;
    sta starship_energy_high                                          ;
    beq reset_damage_counter                                          ;
starship_still_has_energy
    cmp #$0c                                                          ;
    bcc reset_damage_counter                                          ;
    bne skip15                                                        ;
    lda starship_energy_low                                           ;
    cmp #$81                                                          ;
    bcc reset_damage_counter                                          ;
skip15
    lda #$0c                                                          ;
    sta starship_energy_high                                          ;
    lda #$80                                                          ;
    sta starship_energy_low                                           ;
reset_damage_counter
    lda #0                                                            ;
    sta damage_low                                                    ;
    sta damage_high                                                   ;
    sta starship_destroyed                                            ;
    lda starship_energy_high                                          ;
    sta temp3                                                         ;
    lda starship_energy_low                                           ;
    lsr temp3                                                         ;
    ror                                                               ;
    lsr temp3                                                         ;
    ror                                                               ;
    lsr temp3                                                         ;
    ror                                                               ;
    lsr temp3                                                         ;
    ror                                                               ;
    cmp #minimum_energy_value_to_avoid_starship_destruction           ;
    bcs skip_destruction                                              ;
    inc starship_destroyed                                            ;
skip_destruction
    cmp starship_energy_divided_by_sixteen                            ;
    beq return12                                                      ;
plot_starship_energy_bars
    ldx starship_energy_divided_by_sixteen                            ;
    sta starship_energy_divided_by_sixteen                            ;
    sta output_pixels                                                 ;
    cpx output_pixels                                                 ;
    bcs skip_swapping_start_and_end                                   ;
    stx output_pixels                                                 ;
    tax                                                               ;
skip_swapping_start_and_end
    stx output_fraction                                               ;
    ldx #3                                                            ;
    lda output_fraction                                               ;
calculate_pixel_position_in_bar
    cmp #$33                                                          ;
    bcc finished_calculating_pixel_position_in_bar                    ;
    sec                                                               ;
    sbc #$32                                                          ;
    dex                                                               ;
    bpl calculate_pixel_position_in_bar                               ;
finished_calculating_pixel_position_in_bar
    clc                                                               ;
    adc #$0c                                                          ;
    sta x_pixels                                                      ;
    txa                                                               ;
    asl                                                               ;
    asl                                                               ;
    asl                                                               ;
    clc                                                               ;
    adc #$95                                                          ;
    tay                                                               ;
    ldx x_pixels                                                      ;
    sty energy_y+1                                                    ;
plot_energy_change_loop
    lda #5                                                            ;
    jsr plot_vertical_line_xy                                         ;
    dex                                                               ;
energy_y
    ldy #0                                                            ;
    cpx #$0d                                                          ;
    bcs skip_moving_to_next_bar                                       ;
    tya                                                               ;
    adc #8                                                            ; C is clear
    tay                                                               ;
    sty energy_y+1                                                    ;
    ldx #$3e                                                          ;
skip_moving_to_next_bar
    dec output_fraction                                               ;
    lda output_fraction                                               ;
    cmp output_pixels                                                 ;
    bne plot_energy_change_loop                                       ;
return12
    rts                                                               ;

; ----------------------------------------------------------------------------------
activate_shields_when_enemy_ship_enters_main_square
    lda #maximum_number_of_enemy_ships                                ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
activate_shields_when_enemy_ship_enters_main_square_loop
    lda enemy_ships_on_screen,x                                       ;
    beq enemy_ship_is_on_screen                                       ;
    inx                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    bne activate_shields_when_enemy_ship_enters_main_square_loop      ;
    lda starship_shields_active                                       ;
    bne return13                                                      ;
    jmp plot_top_and_right_edge_of_long_range_scanner_with_blank_text ;

enemy_ship_is_on_screen
    lda starship_shields_active                                       ;
    beq return13                                                      ;
    jmp unplot_long_range_scanner_if_shields_inactive                 ;

; ----------------------------------------------------------------------------------
plot_vertical_line_xy
    sty y_pixels                                                      ;
plot_vertical_line
    sta temp3                                                         ; length of line in pixels (loop counter)
plot_vertical_line_loop
    jsr eor_pixel_xcoord_in_x                                         ;
    inc y_pixels                                                      ;
    dec temp3                                                         ;
    bne plot_vertical_line_loop                                       ;
return13
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_horizontal_line_xy
    sty y_pixels                                                      ;
plot_horizontal_line
    sta temp3                                                         ;
    jsr eor_pixel_xcoord_in_x                                         ;
    jmp +                                                             ;
plot_horizontal_line_loop
    jsr eor_pixel_same_y                                              ;
+
    inx                                                               ;
    dec temp3                                                         ;
    bne plot_horizontal_line_loop                                     ;
return14
    rts                                                               ;

; ----------------------------------------------------------------------------------
damage_enemy_ship
    sta temp8                                                         ;
    lda enemy_ships_energy,x                                          ;
    sec                                                               ;
    sbc temp8                                                         ;
    bcs skip16                                                        ;
    lda #0                                                            ;
skip16
    sta enemy_ships_energy,x                                          ;
    bne return14                                                      ;
    jmp explode_enemy_ship                                            ;

; ----------------------------------------------------------------------------------
; On Exit:
;   Preserves X
plot_enemy_ship
    stx temp8                                                         ;
    lda enemy_ships_type,x                                            ;
    sta enemy_ship_type                                               ;
    cmp #2                                                            ;
    bcc enemy_ship_isnt_cloaked                                       ;
    jmp enemy_ship_is_cloaked                                         ;

enemy_ship_isnt_cloaked
    lda enemy_ships_previous_x_pixels,x                               ;
    sta temp10                                                        ; enemy x position
    lda enemy_ships_previous_y_pixels,x                               ;
    sta temp9                                                         ; enemy y position

    lda enemy_ships_previous_angle,x                                  ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    sta temp11                                                        ; enemy angle to draw at (0-31)

debug_plot_enemy
    ; which enemy to use
    lda enemy_ship_type                                               ;
    beq first_ship_type                                               ;

    ; second enemy ship type
    ldx enemy_number                                                  ;
    lda enemy_strides,x                                               ;
    sta enemy_stride                                                  ;
    lda temp11                                                        ; angle
    clc                                                               ;
    adc #32                                                           ; move to second ship definition
    tax                                                               ;
    bne got_ship                                                      ; ALWAYS branch

first_ship_type
    ldx enemy_number                                                  ;
    dex                                                               ;
    lda enemy_strides,x                                               ;
    sta enemy_stride                                                  ;
    ldx temp11                                                        ; angle
got_ship
    lda enemy_address_low,x                                           ;
    sta enemy_low                                                     ;
    lda enemy_address_high,x                                          ;
    sta enemy_high                                                    ;

    lda #1                                                            ;
    sta segment_angle_change_per_pixel                                ;

    ; move x,y
    ; plot arcs
    ldy #0                                                            ;
plot_enemy_loop
    lda (enemy_low),y                                                 ;
    clc                                                               ;
    adc temp10                                                        ; enemy x position
    sta x_pixels                                                      ;
    iny                                                               ;
    lda (enemy_low),y                                                 ;
    clc                                                               ;
    adc temp9                                                         ; enemy y position
    sta y_pixels                                                      ;
    iny                                                               ;
    lda (enemy_low),y                                                 ;
    sta segment_angle                                                 ;
    iny                                                               ;
    lda (enemy_low),y                                                 ;
    sta segment_length                                                ;
    iny                                                               ;
    sty plot_enemy_progress                                           ;
    jsr plot_segment                                                  ;

    ldy plot_enemy_progress                                           ;
    cpy enemy_stride                                                  ; stride between angles (in bytes)
    bcc plot_enemy_loop                                               ;

plot_enemy_done
enemy_ship_is_cloaked
    ldx temp8                                                         ;
    rts                                                               ;


; The Circle
;
;                      31 00 01
;                29 30          02 03
;             28                      04
;          27                            05
;          26                            06
;       25                                  07
;       24                                  08
;       23                                  09
;          22                            10
;          21                            11
;             20                      12
;                19 18          14 13
;                      17 16 15
;
;


; Enemy 1
;
;                         04
;                     27      05
;                     26      06
;             29  25              07  03
;         28      24      ..      08      04
;     27          23              09          05
;     26              22      10              06
; 25                  21      11                  07
; 24                  31  00  01                  08
; 23          29  30              02  03          09
;     22  28                              04  10
;     21                                      11
;

; start address of the definition of each enemy
enemy_table_low
    !byte <enemy0
    !byte <enemy1
    !byte <enemy2
    !byte <enemy3
    !byte <enemy4
    !byte <enemy5

enemy_table_high
    !byte >enemy0
    !byte >enemy1
    !byte >enemy2
    !byte >enemy3
    !byte >enemy4
    !byte >enemy5

; The number of arcs that define the enemy
enemy_arc_counts
    !byte 5     ; enemy 0
    !byte 5     ; enemy 1
    !byte 5     ; enemy 2
    !byte 5     ; enemy 3
    !byte 5     ; enemy 4
    !byte 6     ; enemy 5

; the stride of an enemy is the number of bytes to get from the definition of one angle
; of the enemy to the next. Four times the number of arcs of the enemy.
enemy_strides
    !byte 4*5   ; enemy 0
    !byte 4*5   ; enemy 1
    !byte 4*5   ; enemy 2
    !byte 4*5   ; enemy 3
    !byte 4*5   ; enemy 4
    !byte 4*6   ; enemy 5

; There are 32 angles for each enemy covering the full 360 degrees.
; We define just 5 angles for each enemy. This covers 0-45 degrees. All other angles
; are copies of these rotated and/or reflected into a cache for the current command.
enemy0
    ; (x, y, start_angle, length)

    ; angle 0
    !byte  3, -1, 3, 9
    !byte -5,  7,21, 9
    !byte -4,  6,28, 9
    !byte -1,  3,21, 7
    !byte  0, -4, 4, 8

    ; angle 1
    !byte  3,  0, 4, 9
    !byte -6,  6,22, 9
    !byte -5,  5,29, 9
    !byte -1,  3,22, 7
    !byte  1, -4, 5, 8

    ; angle 2
    !byte  4,  0, 5, 9
    !byte -7,  4,23, 9
    !byte -6,  4,30, 9
    !byte -2,  2,23, 7
    !byte  2, -4, 6, 8

    ; angle 3
    !byte  3,  1, 6, 8
    !byte -8,  3,24,10
    !byte -7,  3,31, 9
    !byte -2,  3,23, 8
    !byte  3, -3, 7, 8

    ; angle 4
    !byte  3,  1, 7, 7
    !byte -7,  1,26, 8
    !byte -7,  2, 0, 8
    !byte -4,  2,25, 8
    !byte  3, -3, 8, 9

enemy1
    ; (x, y, start_angle, length)

    ; angle 0
    !byte  3,  1, 3, 9
    !byte -5,  9,21, 9
    !byte -4,  8,28, 9
    !byte  0,  4,20, 8
    !byte  0, -4, 4, 8

    ; angle 1
    !byte  2,  2, 4, 9
    !byte -6,  8,22, 9
    !byte -5,  7,30, 8
    !byte -1,  3,22, 7
    !byte  1, -4, 5, 8

    ; angle 2
    !byte  2,  2, 5, 8
    !byte -7,  6,23, 8
    !byte -6,  6,31, 8
    !byte -1,  3,22, 8
    !byte  2, -4, 6, 8

    ; angle 3
    !byte  2,  2, 6, 8
    !byte -9,  5,24,10
    !byte -8,  5,31, 9
    !byte -2,  3,23, 8
    !byte  3, -3, 7, 8

    ; angle 4
    !byte  1,  3, 7, 7
    !byte -9,  3,26, 8
    !byte -8,  3, 0, 8
    !byte -4,  2,25, 8
    !byte  3, -3, 8, 9

enemy2
    ; (x, y, start_angle, length)

    ; angle 0
    !byte  3, -1, 4, 8
    !byte -4,  6,21, 8
    !byte -3,  4,29, 7
    !byte  0, -5, 4, 4
    !byte -1, -4, 8, 3

    ; angle 1
    !byte  3, -1, 5, 8
    !byte -4,  5,21, 8
    !byte -3,  4,30, 6
    !byte  1, -5, 5, 4
    !byte  0, -5, 9, 4

    ; angle 2
    !byte  3, -1, 5, 9
    !byte -5,  4,23, 7
    !byte -4,  3,31, 6
    !byte  3, -2,22, 4
    !byte  1, -5, 9, 4

    ; angle 3
    !byte  2,  0, 6, 9
    !byte -6,  4,23, 8
    !byte -5,  3,31, 6
    !byte  3, -4, 8, 4
    !byte  2, -5,12, 4

    ; angle 4
    !byte  2,  1, 7, 8
    !byte -7,  2,26, 8
    !byte -6,  1, 1, 7
    !byte  4, -4, 8, 5
    !byte  3, -4,12, 4

enemy3
    ; (x, y, start_angle, length)

    ; angle 0
    !byte  2, -2, 3,11
    !byte -2,  8,19,11
    !byte -2,  6,30, 5
    !byte -1,  3,21, 7
    !byte  0, -4, 4, 9

    ; angle 1
    !byte  3, -1, 5,10
    !byte -5,  6,21,11
    !byte -4,  4,31, 6
    !byte -1,  3,22, 7
    !byte  1, -4, 5, 8

    ; angle 2
    !byte  4,  0, 7, 9
    !byte -7,  3,24, 9
    !byte -6,  2, 0, 7
    !byte -2,  2,23, 7
    !byte  2, -4, 6, 9

    ; angle 3
    !byte  3,  1, 7,10
    !byte -7,  4,24, 9
    !byte -6,  3, 0, 6
    !byte -2,  3,23, 8
    !byte  3, -3, 7, 8

    ; angle 4
    !byte  3,  0, 7,11
    !byte -7,  4,23,11
    !byte -6,  3, 2, 5
    !byte -4,  2,25, 8
    !byte  3, -3, 8, 9

enemy4
    ; (x, y, start_angle, length)

    ; angle 0
    !byte  1, -5, 1,11
    !byte  4,  5,12,11
    !byte -6,  2,23, 9
    !byte -1,  3,21, 7
    !byte  0, -4, 4, 9

    ; angle 1
    !byte  2, -4, 2,10
    !byte  4,  5,12,11
    !byte -6,  2,23,10
    !byte -1,  3,22, 7
    !byte  1, -4, 5, 8

    ; angle 2
    !byte  3, -4, 3, 9
    !byte  4,  5,12,11
    !byte -6,  2,23,11
    !byte -2,  2,23, 7
    !byte  2, -4, 6, 9

    ; angle 3
    !byte  4, -3, 4,10
    !byte  2,  6,14,11
    !byte -6,  0,25,10
    !byte -2,  3,23, 8
    !byte  3, -3, 7, 8

    ; angle 4
    !byte  4, -3, 4,10
    !byte  2,  6,14,11
    !byte -6,  0,25,10
    !byte -4,  2,25, 8
    !byte  3, -3, 8, 9

enemy5
    ; (x, y, start_angle, length)

    ; angle 0
    !byte  3,  3,21, 7
    !byte -1,  0,31, 3
    !byte  4, -4, 4, 9
    !byte -5,  3,21, 7
    !byte -4, -4, 4, 9
    !byte  0, -3, 7, 3

    ; angle 1
    !byte  3,  4,22, 7
    !byte -1, -1, 1, 3
    !byte  5, -3, 5, 8
    !byte -5,  3,22, 7
    !byte -3, -4, 5, 8
    !byte  1, -3, 9, 3

    ; angle 2
    !byte  1,  4,23, 7
    !byte -1, -1, 1, 3
    !byte  5, -2, 6, 9
    !byte -6,  1,23, 7
    !byte -2, -5, 6, 9
    !byte  1, -3, 8, 3

    ; angle 3
    !byte  1,  4,23, 8
    !byte  0,  0, 1, 2
    !byte  6, -2, 7, 8
    !byte -5,  1,23, 8
    !byte  0, -5, 7, 8
    !byte  2, -3,11, 3

    ; angle 4
    !byte -1,  5,25, 8
    !byte  0,  0, 1, 2
    !byte  6,  0, 8, 9
    !byte -6,  0,25, 8
    !byte  1, -5, 8, 9
    !byte  3, -3,11, 3

; Enemy definitions for the current command

; The centre_array holds (dx,dy) from the centre of the circle to each pixel on the
; perimeter of the circle. 32 entries, with the tables overlapping.
centre_array_dy
    !byte -6,-6,-5,-5,-4,-3,-2,-1

centre_array_dx
    !byte  0, 1, 2, 3, 4, 5, 5, 6, 6, 6, 5, 5, 4, 3, 2, 1
    !byte  0,-1,-2,-3,-4,-5,-5,-6,-6,-6,-5,-5,-4,-3,-2,-1

; ----------------------------------------------------------------------------------
read_enemy_arc
    lda (lookup_low),y                                                ;
    sta enemy_x                                                       ;
    iny                                                               ;
    lda (lookup_low),y                                                ;
    sta enemy_y                                                       ;
    iny                                                               ;
    lda (lookup_low),y                                                ;
    sta enemy_start_angle                                             ;
    iny                                                               ;
    lda (lookup_low),y                                                ;
    sta enemy_arc_length                                              ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
store_enemy_address
    stx temp_x                                                        ;
    ldx enemy_temp_index                                              ;
    lda end_low                                                       ;
    sta enemy_address_low,x                                           ;
    lda end_high                                                      ;
    sta enemy_address_high,x                                          ;
    inc enemy_temp_index                                              ;
    ldx temp_x                                                        ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
add_strides
    jsr store_enemy_address                                           ;
    lda lookup_low                                                    ;
    clc                                                               ;
    adc enemy_stride                                                  ;
    sta lookup_low                                                    ;
    bcc +                                                             ;
    inc lookup_high                                                   ;
+
    lda end_low                                                       ;
    clc                                                               ;
    adc enemy_stride                                                  ;
    sta end_low                                                       ;
    bcc +                                                             ;
    inc end_high                                                      ;
+
    rts                                                               ;

; ----------------------------------------------------------------------------------
backup_lookup_pointer
    lda lookup_low                                                    ;
    sec                                                               ;
    sbc enemy_stride                                                  ;
    sta lookup_low                                                    ;
    bcs +                                                             ;
    dec lookup_high                                                   ;
+
    rts                                                               ;

; ----------------------------------------------------------------------------------
fill_enemy_cache
    ldx #0                                                            ;
    stx enemy_temp_index                                              ;
    lda #<enemy_cache_a                                               ;
    sta end_low                                                       ;
    sta cache_start_low                                               ;
    lda #>enemy_cache_a                                               ;
    sta end_high                                                      ;
    sta cache_start_high                                              ;
    jsr fill_one_enemy_cache                                          ;

    inc enemy_number                                                  ; enemy number incremented to second enemy type
    lda #<enemy_cache_b                                               ;
    sta end_low                                                       ;
    sta cache_start_low                                               ;
    lda #>enemy_cache_b                                               ;
    sta end_high                                                      ;
    sta cache_start_high                                              ;
    ; fall through...

; ----------------------------------------------------------------------------------
fill_one_enemy_cache
    ldx enemy_number                                                  ;
    lda enemy_arc_counts,x                                            ;
    asl                                                               ;
    asl                                                               ;
    sta enemy_stride                                                  ; four bytes * number of arcs

    ; set lookup pointer
    ldx enemy_number                                                  ;
    lda enemy_table_low,x                                             ;
    sta lookup_low                                                    ;
    lda enemy_table_high,x                                            ;
    sta lookup_high                                                   ;

    ; copy first five angles
    ldx #5                                                            ; five angles
--
    ldy #0                                                            ;
-
    lda (lookup_low),y                                                ;
    sta (end_low),y                                                   ;
    iny                                                               ;
    cpy enemy_stride                                                  ;
    bne -                                                             ;

    jsr add_strides                                                   ;
    dex                                                               ;
    bne --                                                            ;

    ; append angles 5 to 7
    ; go to the previous angle, angle 3
    jsr backup_lookup_pointer
    jsr backup_lookup_pointer

    ldx #3                                                            ; three angles
--
    ldy #0                                                            ;
-
    jsr read_enemy_arc                                                ;
    jsr convert_enemy_5to7                                            ;
    cpy enemy_stride                                                  ;
    bne -                                                             ;

    jsr store_enemy_address                                           ;
    jsr backup_lookup_pointer                                         ;

    ; move destination pointer onwards
    lda end_low                                                       ;
    clc                                                               ;
    adc enemy_stride                                                  ;
    sta end_low                                                       ;
    bcc +                                                             ;
    inc end_high                                                      ;
+
    dex                                                               ;
    bne --                                                            ;

    ; append remaining angles 8 to 31
    lda cache_start_low                                               ;
    sta lookup_low                                                    ;
    lda cache_start_high                                              ;
    sta lookup_high                                                   ;

    ldx #24                                                           ; twenty four angles
--
    ldy #0                                                            ;
-
    jsr read_enemy_arc                                                ;
    jsr convert_enemy_8to31                                           ;
    cpy enemy_stride                                                  ;
    bne -                                                             ;

    jsr add_strides                                                   ;
    dex                                                               ;
    bne --                                                            ;
    rts                                                               ;

; preserves X
; increments Y
; ----------------------------------------------------------------------------------
convert_enemy_5to7
    stx temp_x                                                        ;
    dey                                                               ;
    dey                                                               ;
    dey                                                               ;
    lda enemy_start_angle                                             ;
    clc                                                               ;
    adc enemy_arc_length                                              ;
    sec                                                               ;
    sbc #1                                                            ;
    and #31                                                           ;
    sta enemy_end_angle                                               ;
    tax                                                               ;

    ; x' = circle[start].y - circle[end].y - y
    ldx enemy_start_angle                                             ;
    lda centre_array_dy,x                                             ;
    ldx enemy_end_angle                                               ;
    sec                                                               ;
    sbc centre_array_dy,x                                             ;
    sec                                                               ;
    sbc enemy_y                                                       ;
    sta (end_low),y                                                   ;
    iny                                                               ;

    ; y' = circle[end].x - circle[start].x + x
    ldx enemy_start_angle                                             ;
    lda centre_array_dx,x                                             ;
    ldx enemy_end_angle                                               ;
    sec                                                               ;
    sbc centre_array_dx,x                                             ;
    sec                                                               ;
    sbc enemy_x                                                       ;
    sta (end_low),y                                                   ;
    iny                                                               ;

    ; start' = (40-end) & 31
    lda #40                                                           ;
    sec                                                               ;
    sbc enemy_end_angle                                               ;
    and #31                                                           ;
    sta (end_low),y                                                   ;
    iny                                                               ;

    ; length' = length
    lda enemy_arc_length                                              ;
    sta (end_low),y                                                   ;
    iny                                                               ;

    ldx temp_x                                                        ;
    rts                                                               ;

; preserves X
; increments Y
; ----------------------------------------------------------------------------------
convert_enemy_8to31
    dey                                                               ;
    dey                                                               ;
    dey                                                               ;

    ; x' = -y
    lda #0                                                            ;
    sec                                                               ;
    sbc enemy_y                                                       ;
    sta (end_low),y                                                   ;
    iny                                                               ;

    ; y = x
    lda enemy_x                                                       ;
    sta (end_low),y                                                   ;
    iny                                                               ;

    ; start' = (start+8) & 31
    lda enemy_start_angle                                             ;
    clc                                                               ;
    adc #8                                                            ;
    and #31                                                           ;
    sta (end_low),y                                                   ;
    iny                                                               ;

    ; length' = length
    lda enemy_arc_length                                              ;
    sta (end_low),y                                                   ;
    iny                                                               ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
enemy_explosion_address_low_table
    !byte <(enemy_explosion_tables + $0000)                           ;
    !byte <(enemy_explosion_tables + $0040)                           ;
    !byte <(enemy_explosion_tables + $0080)                           ;
    !byte <(enemy_explosion_tables + $00c0)                           ;
    !byte <(enemy_explosion_tables + $0100)                           ;
    !byte <(enemy_explosion_tables + $0140)                           ;
    !byte <(enemy_explosion_tables + $0180)                           ;
    !byte <(enemy_explosion_tables + $01c0)                           ;
enemy_explosion_address_high_table
    !byte >(enemy_explosion_tables + $0000)                           ;
    !byte >(enemy_explosion_tables + $0040)                           ;
    !byte >(enemy_explosion_tables + $0080)                           ;
    !byte >(enemy_explosion_tables + $00c0)                           ;
    !byte >(enemy_explosion_tables + $0100)                           ;
    !byte >(enemy_explosion_tables + $0140)                           ;
    !byte >(enemy_explosion_tables + $0180)                           ;
    !byte >(enemy_explosion_tables + $01c0)                           ;
enemy_explosion_piece_ageing_table
    !byte 15, 17, 19, 21                                              ;
starship_explosion_piece_ageing_table
    !byte 5, 6, 7, 8, 9, 10, 11, 12                                   ;

; ----------------------------------------------------------------------------------
initialise_stars_at_random_positions
    lda maximum_number_of_stars                                       ;
    sta stars_still_to_consider                                       ;
    ldy #index_of_in_game_stars                                       ;
initialise_stars_at_random_positions_loop
    jsr random_number_generator                                       ;
    lda rnd_1                                                         ;
    sta object_table_xpixels,y                                        ;
    lda rnd_2                                                         ;
    sta object_table_ypixels,y                                        ;
    iny                                                               ;
    dec stars_still_to_consider                                       ;
    bne initialise_stars_at_random_positions_loop                     ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
get_starship_address
    ldx starship_type                                                 ;
    lda starship_addresses_low,x                                      ;
    sta starship_low                                                  ;
    lda starship_addresses_high,x                                     ;
    sta starship_high                                                 ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_starship_heading
    jsr get_starship_address                                          ;

    ; plot top half (14 times across the screen)
    lda #<$5a88                                                       ;
    sta end_low                                                       ;
    lda #>$5a88                                                       ;
    sta end_high                                                      ;

    jsr copy_half                                                     ;

    ; plot bottom half (14 times across the screen)
    lda #<$5bc8                                                       ;
    sta end_low                                                       ;
    lda #>$5bc8                                                       ;
    sta end_high                                                      ;
    lda starship_low                                                  ;
    clc                                                               ;
    adc #16                                                           ;
    sta starship_low                                                  ;
    lda starship_high                                                 ;
    adc #0                                                            ;
    sta starship_high                                                 ;
    ; fall through...

copy_half
    ldx #13                                                           ;
--
    ldy #15                                                           ;
-
    lda (starship_low),y                                              ;
    sta (end_low),y                                                   ;
    dey                                                               ;
    bpl -                                                             ;

    lda end_low                                                       ;
    clc                                                               ;
    adc #$18                                                          ;
    sta end_low                                                       ;
    bcc +                                                             ;
    inc end_high                                                      ;
+
    dex                                                               ;
    bne --                                                            ;
    rts                                                               ;


; ----------------------------------------------------------------------------------
plot_starship
    jsr get_starship_address                                          ;

    ldy #0                                                            ; Y = 0
plot_starship_top_loop
    lda (starship_low),y                                              ; copy starship sprite
    eor starship_top_screen_address,y                                 ; } draw top half
    sta starship_top_screen_address,y                                 ; }
    iny                                                               ;
    cpy #16                                                           ;
    bne plot_starship_top_loop                                        ;

plot_starship_bottom_loop
    lda (starship_low),y                                              ; copy starship sprite
    eor starship_bottom_screen_address - 16,y                         ; } draw bottom half
    sta starship_bottom_screen_address - 16,y                         ; }
    iny                                                               ;
    cpy #32                                                           ;
    bne plot_starship_bottom_loop                                     ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
explode_starship
    lda #<starship_explosion_table                                    ;
    sta temp0_low                                                     ;
    lda #>starship_explosion_table                                    ;
    sta temp0_high                                                    ;
    lda #starship_explosion_size                                      ;
    sta explosion_bits_still_to_consider                              ;
plot_starship_explosion_loop
    jsr plot_starship_explosion_piece                                 ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #3                                                            ;
    sta temp0_low                                                     ;
    bcc skip19                                                        ;
    inc temp0_high                                                    ;
skip19
    dec explosion_bits_still_to_consider                              ;
    bne plot_starship_explosion_loop                                  ;
    inc starship_has_exploded                                         ;
    lda rnd_1                                                         ;
    ora #$10                                                          ;
    sta rnd_1                                                         ;
    jsr turn_scanner_to_static                                        ;
    jmp plot_starship                                                 ;

; ----------------------------------------------------------------------------------
plot_starship_explosion
    dec starship_explosion_countdown                                  ;
    bne starship_explosion_continuing                                 ;
    jmp end_of_command                                                ;

starship_explosion_continuing
    lda #<starship_explosion_table                                    ;
    sta temp0_low                                                     ;
    lda #>starship_explosion_table                                    ;
    sta temp0_high                                                    ;
    lda #starship_explosion_size                                      ;
    sta explosion_bits_still_to_consider                              ;
loop6
    ldy #0                                                            ;
    lda (temp0_low),y                                                 ;
    beq move_to_next_starship_explosion_piece                         ;
    jsr plot_starship_explosion_piece                                 ;
    ldy #1                                                            ;
    lda (temp0_low),y                                                 ;
    and #7                                                            ;
    tax                                                               ;
    lda starship_explosion_piece_ageing_table,x                       ;
    dey                                                               ;
    clc                                                               ;
    adc (temp0_low),y                                                 ;
    bcc skip20                                                        ;
    tya                                                               ;
    sta (temp0_low),y                                                 ;
    beq move_to_next_starship_explosion_piece                         ;
skip20
    sta (temp0_low),y                                                 ;
    txa                                                               ;
    ldy #2                                                            ;
    sec                                                               ;
    adc (temp0_low),y                                                 ;
    sta (temp0_low),y                                                 ;
    jsr plot_starship_explosion_piece                                 ;
move_to_next_starship_explosion_piece
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #3                                                            ;
    sta temp0_low                                                     ;
    bcc skip21                                                        ;
    inc temp0_high                                                    ;
skip21
    dec explosion_bits_still_to_consider                              ;
    bne loop6                                                         ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_starship_explosion_piece
    ldy #0                                                            ;
    lda (temp0_low),y                                                 ;
    and #$c0                                                          ;
    sta temp8                                                         ;
    ldy #2                                                            ;
    lda (temp0_low),y                                                 ;
    sta temp11                                                        ;
    lda explosion_bits_still_to_consider                              ;
    and #$1f                                                          ;
    tax                                                               ;
    lda sine_table,x                                                  ;
    bpl skip_inversion_sine                                           ;
    eor #$1f                                                          ;
    clc                                                               ;
    adc #1                                                            ;
skip_inversion_sine
    sta x_pixels                                                      ;
    lda cosine_table,x                                                ;
    bpl skip_inversion_cosine                                         ;
    eor #$1f                                                          ;
    clc                                                               ;
    adc #1                                                            ;
skip_inversion_cosine
    sta y_pixels                                                      ;

    ; 3-bit multiplication of sine by radius, A = (x_pixels * temp11)/8
    lda #0                                                            ;
    lsr x_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;
    lsr x_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;
    lsr x_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;

    ldx x_pixels                                                      ;
    beq skip_uninversion_sine                                         ;
    eor #$ff                                                          ;
skip_uninversion_sine
    eor #$80                                                          ;
    sta x_pixels                                                      ;

    ; 3-bit multiplication of cosine by radius, A = (y_pixels * temp11)/8
    lda #0                                                            ;
    lsr y_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;
    lsr y_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;
    lsr y_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;

    ldx y_pixels                                                      ;
    beq skip_uninversion_cosine                                       ;
    eor #$ff                                                          ;
skip_uninversion_cosine
    eor #$80                                                          ;
    sta y_pixels                                                      ; y = radius * cos(piece)
    dey                                                               ;
    lda (temp0_low),y                                                 ;
    bpl plot_variable_size_fragment                                   ;
    lda temp8                                                         ;
    clc                                                               ;
    rol                                                               ;
    rol                                                               ;
    rol                                                               ;
    sta segment_angle_change_per_pixel                                ;
    eor #3                                                            ;
    clc                                                               ;
    adc #1                                                            ;
    sec                                                               ;
    rol                                                               ;
    sta segment_length                                                ;
    inc segment_angle_change_per_pixel                                ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda x_pixels                                                      ;
    sta temp10                                                        ;
    lda y_pixels                                                      ;
    sta temp9                                                         ;
    jmp plot_segment                                                  ;


;   -101
; -1  h
;  0 gab
;  1 fdc
;  2  e
; ----------------------------------------------------------------------------------
plot_variable_size_fragment
    ldx x_pixels
    lda temp8                                                         ;
    cmp #$c0                                                          ;
    beq plot_1x1
    lda temp8                                                         ;
    bmi plot_2x1                                                      ;
    bne plot_2x2
plot_3x4
    dec y_pixels                                                      ;
    jsr eor_play_area_pixel                                           ; h
    inc y_pixels                                                      ;
    jsr eor_two_play_area_pixels                                      ; a,b
    dex                                                               ;
    jsr eor_play_area_pixel_same_y                                    ; g
    inc y_pixels                                                      ;
    jsr eor_play_area_pixel                                           ; f
    inx                                                               ;
    jsr eor_two_play_area_pixels_same_y                               ; d,c
    inc y_pixels                                                      ;
plot_1x1
    jmp eor_play_area_pixel                                           ; e
plot_2x2
    jsr eor_two_play_area_pixels                                      ;
    inc y_pixels                                                      ;
    ; here we don't need this check
    ;beq return15 ; wrapped?
plot_2x1
    jmp eor_two_play_area_pixels                                      ;

; ----------------------------------------------------------------------------------
initialise_starship_explosion_pieces
    lda #maximum_starship_explosion_countdown                         ;
    sta starship_explosion_countdown                                  ;
    lda #<starship_explosion_table                                    ;
    sta temp0_low                                                     ;
    lda #>starship_explosion_table                                    ;
    sta temp0_high                                                    ;
    lda #starship_explosion_size                                      ;
    sta explosion_bits_still_to_consider                              ;
initialise_starship_explosion_pieces_loop
    jsr initialise_starship_explosion_piece                           ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #3                                                            ;
    sta temp0_low                                                     ;
    bcc skip23                                                        ;
    inc temp0_high                                                    ;
skip23
    dec explosion_bits_still_to_consider                              ;
    bne initialise_starship_explosion_pieces_loop                     ;
return15
    rts                                                               ;

; ----------------------------------------------------------------------------------
initialise_starship_explosion_piece
    jsr random_number_generator                                       ;
    ldy #2                                                            ;
    lda rnd_1                                                         ;
    and #7                                                            ;
    sta (temp0_low),y                                                 ; random 0-7
    dey                                                               ;
    lda rnd_2                                                         ;
    lsr                                                               ;
    sta (temp0_low),y                                                 ; random 0-127
    lda rnd_1                                                         ;
    and #$3c                                                          ;
    bne not_a_segment                                                 ;
    lda (temp0_low),y                                                 ;
    ora #$80                                                          ; top bit set indicates a segment
    sta (temp0_low),y                                                 ;
not_a_segment
    dey                                                               ;
    lda rnd_1                                                         ;
    and #$1f                                                          ;
    clc                                                               ;
    adc #1                                                            ;
    sta (temp0_low),y                                                 ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
explode_enemy_ship
    lda enemy_ships_previous_on_screen,x                              ;
    bne skip_plotting                                                 ;
    jsr plot_enemy_ship                                               ;
skip_plotting
    lda #enemy_ship_explosion_duration                                ;
    sta enemy_ships_flags_or_explosion_timer,x                        ;
    ldy #maximum_number_of_enemy_ships                                ;
    lda #0                                                            ;
find_free_explosion_slot_loop
    cmp enemy_ships_explosion_number - 1,y                            ;
    bcs skip24                                                        ;
    lda enemy_ships_explosion_number - 1,y                            ;
skip24
    dey                                                               ;
    bne find_free_explosion_slot_loop                                 ;
    cmp #maximum_number_of_explosions                                 ;
    beq skip_add_explosion_index                                      ; this branch can never happen?
    clc                                                               ;
    adc #1                                                            ;
skip_add_explosion_index
    ; initialise explosion
    ldy explosion_bits_still_to_consider                              ;
    sta enemy_ships_explosion_number - 1,y                            ;
    tay                                                               ;
    lda enemy_explosion_address_low_table - 1,y                       ;
    sta temp5                                                         ;
    lda enemy_explosion_address_high_table - 1,y                      ;
    sta temp6                                                         ;
    ldy #number_of_bytes_per_enemy_explosion                          ;
loop_initialise_explosion
    jsr random_number_generator                                       ;

    ;enemy_explosion_initialisation
    and #$3f                                                          ;
    sta (temp5),y                                                     ; random between 0 and 63
    dey                                                               ;
    lda rnd_1                                                         ;
    and #$3f                                                          ;
    clc                                                               ;
    adc #$68                                                          ;
    sta (temp5),y                                                     ; random between 104 to 167
    dey                                                               ;
    bpl loop_initialise_explosion                                     ;

; ----------------------------------------------------------------------------------
score_points_for_destroying_enemy_ship
    lda #1                                                            ;
    sta enemy_ships_previous_on_screen,x                              ;
    lda how_enemy_ship_was_damaged                                    ;
    asl                                                               ;
    tay                                                               ;
    iny                                                               ;
    lda enemy_ships_type,x                                            ;
    cmp #4                                                            ;
    bcs not_cloaked                                                   ;
    cmp #1                                                            ;
    beq not_cloaked                                                   ;
    dey                                                               ;
not_cloaked
    tya                                                               ;
    bpl convert_offset_to_score                                       ;
    and #7                                                            ;
    tay                                                               ;
    lda starship_collided_with_enemy_ship                             ;
    beq convert_offset_to_score                                       ;
    dec starship_collided_with_enemy_ship                             ;
    iny                                                               ;
    iny                                                               ;
convert_offset_to_score
    lda scores_for_destroying_enemy_ships,y                           ;
debug_score_points
    clc                                                               ;
    sei                                                               ;
    sed                                                               ; BCD on
    adc score_delta_low                                               ;
    sta score_delta_low                                               ;
    lda score_delta_high                                              ;
    adc #0                                                            ;
    sta score_delta_high                                              ;
    cld                                                               ; BCD off
    cli                                                               ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
update_enemy_explosion_pieces
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    cmp #frame_of_enemy_ship_explosion_after_which_no_collisions      ;
    lda #1                                                            ; create new explosion pieces when old ones die
    bcs skip25                                                        ;
    lda #0                                                            ; don't create new explosion pieces when old ones die
skip25
    sta create_new_enemy_explosion_piece_after_one_dies               ;
    jsr plot_enemy_ship_or_explosion_segments                         ;
    ldy #number_of_bytes_per_enemy_explosion                          ;
update_enemy_explosion_pieces_loop
    dey                                                               ;
    lda (temp5),y                                                     ; age rate index, angle etc
    beq move_to_next_piece                                            ;
    jsr plot_enemy_explosion_fragment                                 ; unplot?
    lda (temp5),y                                                     ;
    and #3                                                            ; extract age rate index
    tax                                                               ;
    lda enemy_explosion_piece_ageing_table,x                          ; get actual ageing rate from table
    dey                                                               ;
    clc                                                               ;
    adc (temp5),y                                                     ; add to age
    bcc piece_still_active                                            ;
    lda create_new_enemy_explosion_piece_after_one_dies               ;
    sta (temp5),y                                                     ; store flag to say if we will create a new piece
    beq move_to_next_piece                                            ;
    jsr random_number_generator                                       ;
    lsr                                                               ;
    and #$3f                                                          ;
    iny                                                               ;
    sta (temp5),y                                                     ;
    bne move_to_next_piece_after_dey                                  ; ALWAYS branch

piece_still_active
    sta (temp5),y                                                     ; store updated age
    iny                                                               ;
    inx                                                               ;
    txa                                                               ;
    asl                                                               ;
    asl                                                               ;
    clc                                                               ;
    adc (temp5),y                                                     ; add to random angle etc
    sta (temp5),y                                                     ;
move_to_next_piece_after_dey
    dey                                                               ;
move_to_next_piece
    dey                                                               ;
    bpl update_enemy_explosion_pieces_loop                            ;
    ldx temp7                                                         ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_enemy_ship_explosion
    jsr plot_enemy_ship_or_explosion_segments                         ;

    ldy #number_of_bytes_per_enemy_explosion                          ;
plot_enemy_ship_explosion_loop
    dey                                                               ;
    lda (temp5),y                                                     ;
    beq move_to_next_explosion_piece                                  ;
    jsr plot_enemy_explosion_fragment                                 ;
    dey                                                               ;
move_to_next_explosion_piece
    dey                                                               ;
    bpl plot_enemy_ship_explosion_loop                                ;
    ldx temp7                                                         ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_enemy_explosion_fragment
    lda (temp5),y                                                     ;
    and #$c0                                                          ;
    sta segment_angle                                                 ;
    iny                                                               ;
    lda (temp5),y                                                     ;
    lsr                                                               ;
    lsr                                                               ;
    sta temp11                                                        ;

    ; calculate sine
    tya                                                               ;
    lsr                                                               ;
    tax                                                               ;
    lda sine_table,x                                                  ;
    bpl skip_inversion_sine1                                          ;
    eor #$1f                                                          ;
    clc                                                               ;
    adc #1                                                            ;
skip_inversion_sine1
    sta x_pixels                                                      ; sine

    ; calculate cosine
    lda cosine_table,x                                                ;
    bpl skip_inversion_cosine1                                        ;
    eor #$1f                                                          ;
    clc                                                               ;
    adc #1                                                            ;
skip_inversion_cosine1
    sta y_pixels                                                      ; cosine

    ; 3-bit multiplication of sine by radius, A = (x_pixels * temp11)/8
    lda #0                                                            ;
    lsr x_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;
    lsr x_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;
    lsr x_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;

    ldx x_pixels                                                      ;
    beq skip_uninversion_sine1                                        ;
    eor #$ff                                                          ;
skip_uninversion_sine1
    clc                                                               ;
    adc temp10                                                        ;
    sta x_pixels                                                      ; x = origin_x + radius * sin(piece)

    ; 3-bit multiplication of cosine by radius, A = (y_pixels * temp11)/8
    lda #0                                                            ;
    lsr y_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;
    lsr y_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;
    lsr y_pixels                                                      ; sine
    bcc +                                                             ;
    clc                                                               ;
    adc temp11                                                        ; radius
+
    ror                                                               ;

    ldx y_pixels                                                      ;
    beq skip_uninversion_cosine1                                      ;
    eor #$ff                                                          ;
skip_uninversion_cosine1
    clc                                                               ;
    adc temp9                                                         ;
    sta y_pixels                                                      ; y = origin_y + radius * cos(piece)
    sty temp11                                                        ;

    ; draw a dot or two, or four
    ldx x_pixels                                                      ;
    ; boundary check X
    txa                                                               ;
    sec                                                               ;
    sbc temp10                                                        ;
    bcs +                                                             ;
    eor #$ff                                                          ;
+
    cmp #$20                                                          ;
    bcs leave_after_restoring_y                                       ;

    ; boundary check Y
    lda y_pixels                                                      ;
    sec                                                               ;
    sbc temp9                                                         ;
    bcs +                                                             ;
    eor #$ff                                                          ;
+
    cmp #$20                                                          ;
    bcs leave_after_restoring_y                                       ;
    ; fall through...
    ; TODO: merge with plot_variable_size_fragment
    lda segment_angle                                                 ;
    bmi plot_1x1_a                                                    ;
    bne plot_2x1_a                                                    ;
plot_2x2_a
    jsr eor_two_play_area_pixels                                      ;
    inc y_pixels                                                      ;
    beq leave_after_restoring_y                                       ; wrapped?
    ; fall through...

plot_2x1_a
    jsr eor_two_play_area_pixels                                      ;
leave_after_restoring_y
    ldy temp11                                                        ;
    rts                                                               ;
plot_1x1_a
    jsr eor_play_area_pixel                                           ;
    ldy temp11                                                        ;
return16
    rts                                                               ;


; ----------------------------------------------------------------------------------
plot_enemy_ship_or_explosion_segments
    stx temp7                                                         ;
    lda enemy_ships_previous_x_pixels,x                               ;
    sta temp10                                                        ;
    lda enemy_ships_previous_y_pixels,x                               ;
    sta temp9                                                         ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    cmp #frame_of_enemy_ship_explosion_after_which_no_collisions      ;
    bcc return16                                                      ;
    cmp #frame_of_enemy_ship_explosion_after_which_no_segments_are_plotted ;
    bcc plot_enemy_explosion_segments                                 ;
    jmp plot_enemy_ship                                               ;

; ----------------------------------------------------------------------------------
plot_enemy_explosion_segments
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda temp10                                                        ;
    sta x_pixels                                                      ;
    lda temp9                                                         ;
    sta y_pixels                                                      ;
    lda #10                                                           ;
    sta segment_length                                                ;
    lda #1                                                            ;
    sta segment_angle_change_per_pixel                                ;
    jsr plot_segment                                                  ;
    ldx temp7                                                         ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    eor #$1f                                                          ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda #7                                                            ;
    sta segment_length                                                ;
    inc segment_angle_change_per_pixel                                ; two
    jsr plot_segment                                                  ;
    ldx temp7                                                         ;
    lda temp10                                                        ;
    sta x_pixels                                                      ;
    lda temp9                                                         ;
    sta y_pixels                                                      ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    eor #$0f                                                          ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda #6                                                            ;
    sta segment_length                                                ;
    lda #$ff                                                          ;
    sta segment_angle_change_per_pixel                                ;
    jmp plot_segment                                                  ;

; ----------------------------------------------------------------------------------
; random number generator
; From https://codebase64.org/doku.php?id=base:16bit_xorshift_random_generator
; Preserves X and Y
; ----------------------------------------------------------------------------------
random_number_generator
    lda rnd_2                                                         ;
    lsr                                                               ;
    lda rnd_1                                                         ;
    ror                                                               ;
    eor rnd_2                                                         ;
    sta rnd_2                                                         ; high part of x ^= x << 7 done
    ror                                                               ; A has now x >> 9 and high bit comes from low byte
    eor rnd_1                                                         ;
    sta rnd_1                                                         ; x ^= x >> 9 and the low part of x ^= x << 7 done
    eor rnd_2                                                         ;
    sta rnd_2                                                         ; x ^= x << 8 done
return16a
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_energy_bar_edges
    lda #$93                                                          ;
    sta y_pixels                                                      ;
    lda #5                                                            ;
    sta temp8                                                         ;
plot_energy_bar_edges_loop
    ldx #$0d                                                          ;
    lda #$32                                                          ;
    jsr plot_horizontal_line                                          ;
    lda y_pixels                                                      ;
    clc                                                               ;
    adc #8                                                            ;
    sta y_pixels                                                      ;
    dec temp8                                                         ;
    bne plot_energy_bar_edges_loop                                    ;
    ldy #$93                                                          ;
    ldx #$0c                                                          ;
    lda #$21                                                          ;
    jmp plot_vertical_line_xy                                         ;

; ----------------------------------------------------------------------------------
check_for_keypresses
    ldy escape_capsule_launched                                       ;
    bne return16a                                                     ;
    ldy keyboard_or_joystick                                          ;
    beq use_keyboard_input                                            ;
    jsr get_joystick_input                                            ;
    +start_keyboard_read                                              ;
    jmp check_for_additional_keys                                     ;

; ----------------------------------------------------------------------------------
!macro do_key .inkey_value, .row, .col, .skip, .invert {
!if elk {
    ; Electron
.rom_address   = $bfff - (1<<.row)
.bitmask       = 1<<.col
    lda .rom_address                                                  ;
    and #.bitmask                                                     ;
!if .invert {
    bne .skip                                                         ;
} else {
    beq .skip                                                         ;
}
} else {
    ; BBC/Master
    lda #255-.inkey_value                                             ;
    sta $fe4f                                                         ;
    lda $fe4f                                                         ;
!if .invert {
    bmi .skip                                                         ;
} else {
    bpl .skip                                                         ;
}
}
}

; ----------------------------------------------------------------------------------
use_keyboard_input
    +start_keyboard_read                                              ;
    +do_key inkey_z, 12, 3, +, 0                                      ;
    dec rotation_delta                                                ;
+
    +do_key inkey_x, 11, 3, +, 0                                      ;
    inc rotation_delta                                                ;
+
    +do_key inkey_m, 6, 3, speed_up, 1                                ;
    +do_key inkey_colon, 2, 2, +, 0                                   ;
speed_up
    inc velocity_delta                                                ;
+
    +do_key inkey_comma, 5, 3, slow_down, 1                           ;
    +do_key inkey_slash, 3, 3, +, 0                                   ;
slow_down
    dec velocity_delta                                                ;
+
    +do_key inkey_n, 7, 3, fire, 1                                    ;
    +do_key inkey_return, 1, 2, check_for_additional_keys, 0          ;
fire
    inc fire_pressed                                                  ;

check_for_additional_keys
    +do_key inkey_g, 8, 2, +, 0                                       ;
    jmp launch_escape_capsule_starboard                               ;
+
    +do_key inkey_f, 9, 2, +, 0                                       ;
    jmp launch_escape_capsule_port                                    ;
+
    lda keyboard_or_joystick                                          ;
    beq is_keyboard                                                   ;
    bne skip_damper_keys                                              ;
is_keyboard
    lda rotation_delta                                                ;
    ora velocity_delta                                                ;
    bne return17                                                      ; dampers only work when not accelerating / turning
    +do_key inkey_f0, 12, 0, +, 0                                     ; '1' on Electron
    lda #1                                                            ;
    sta rotation_damper                                               ; rotation dampers on
return17
    rts                                                               ;

+
    +do_key inkey_f1, 11, 0, +, 0                                     ; '2' on Electron
    lda #1                                                            ;
    sta velocity_damper                                               ; velocity dampers on
    rts                                                               ;

+
    +do_key inkey_2, 12, 1, +, 0                                      ; 'Q' on Electron
    lda #0                                                            ;
    sta rotation_damper                                               ; rotation dampers off
    rts                                                               ;

+
    +do_key inkey_3, 11, 1, skip_damper_keys, 0                       ; 'W' on Electron
    lda #0                                                            ;
    sta velocity_damper                                               ; velocity dampers off
    rts                                                               ;

skip_damper_keys
    +do_key inkey_v, 9, 3, +, 0                                       ;
    inc shields_state_delta                                           ; enable shields
    rts                                                               ;

+
    +do_key inkey_b, 8, 3, +, 0                                       ;
    dec shields_state_delta                                           ; disable shields
    rts                                                               ;

+
    +do_key inkey_c, 10, 3, +, 0                                      ;
    lda #1                                                            ;
    sta starship_automatic_shields                                    ; automatic shields
    rts                                                               ;

; ----------------------------------------------------------------------------------
!if cheat_score { ; for testing scoring
+
    +do_key inkey_6, 7, 0, +, 0                                       ;
    lda #10                                                           ;
    jsr debug_score_points                                            ;
+
    +do_key inkey_7, 6, 0, +, 0                                       ;
    lda #$40                                                          ;
    sta damage_high                                                   ;
}
; ----------------------------------------------------------------------------------
+
    +do_key inkey_p, 3, 1, return18, 0                                ;
pause_game
!if elk=0 {
    ; turn off engine sound for pause mode
    jsr disable_engine_interrupt                                      ;
}

pause_game_loop
    +finish_keyboard_read                                             ;
    +start_keyboard_read                                              ;
    +do_key inkey_space, 0, 3, pause_game_loop, 0                     ;

!if elk=0 {
    ; turn on engine sound after pause is finished
    jsr enable_engine_interrupt                                       ;
}
return18
    rts                                                               ;

!if elk=0 {
    ; BBC/Master
    random_data = $4000                                               ;
} else {
    ; Electron
    random_data = $d000                                               ; ROM is cheaper to access than RAM
}

; ----------------------------------------------------------------------------------
!if elk=0 {
enable_engine_interrupt
    ; turn on engine sound
    lda #$a0                                                          ; enable engine interrupt
    bne +                                                             ; ALWAYS branch

disable_engine_interrupt
    ; turn off engine sound
    lda #$20                                                          ; disable engine interrupt
+
    sta userVIAInterruptEnableRegister                                ; on timer 2
    rts                                                               ;
}

; ----------------------------------------------------------------------------------
play_sounds
    lda sound_enabled                                                 ;
    bne return18                                                      ;
    ; sound_is_enabled
    lda enemy_torpedo_hits_against_starship                           ;
    beq no_enemy_torpedo_hits_against_starship                        ;
    lda starship_has_exploded                                         ;
    bne skip_explosion_or_firing_sound                                ;
    ldx #<sound_6                                                     ;
    bne play_explosion_or_firing_sound                                ;
no_enemy_torpedo_hits_against_starship
    lda enemy_ship_was_hit                                            ;
    beq no_enemy_ship_was_hit                                         ;
    ldx #<sound_5                                                     ;
    bne play_explosion_or_firing_sound                                ;
no_enemy_ship_was_hit
    lda enemy_ship_fired_torpedo                                      ;
    beq skip_explosion_or_firing_sound                                ;
    ldx #<(sound_4)                                                   ;
play_explosion_or_firing_sound
    jsr do_osword_sound                                               ;
skip_explosion_or_firing_sound
    ldy #0                                                            ;
    lda escape_capsule_launched                                       ;
    beq set_escape_capsule_sound_channel                              ;
    lda escape_capsule_destroyed                                      ;
    bne set_escape_capsule_sound_channel                              ;
    iny                                                               ;
set_escape_capsule_sound_channel
    sty escape_capsule_sound_channel                                  ; 1 if launched, but not collided with enemy ship
    lda starship_has_exploded                                         ;
    bne play_sound_for_exploding_starship                             ;
    lda score_delta_low                                               ;
    ora score_delta_high                                              ;
    beq skip_sound_for_exploding_enemy_ship                           ;
    ldx #<(sound_11)                                                  ;
    jsr do_osword_sound                                               ;
skip_sound_for_exploding_enemy_ship
    lda escape_capsule_sound_channel                                  ;
    beq escape_capsule_not_launched                                   ;
    jmp play_escape_capsule_sound                                     ;

escape_capsule_not_launched
    jsr consider_torpedo_sound                                        ;
    lda sound_needed_for_low_energy                                   ;
    bne return18                                                      ;
    ; fall through...

; ----------------------------------------------------------------------------------
play_starship_engine_sound

    ; On Elk, disable engine sound. Elk has 1 sound channel and the starship engine
    ; sound is interfering with the other sounds.
!if elk=0 {
    lda starship_velocity_low                                         ;
    clc                                                               ;
    adc #$40                                                          ;
    sta irqtmp                                                        ;
    lda #0                                                            ;
    adc starship_velocity_high                                        ;
    asl irqtmp                                                        ;
    rol                                                               ;
    adc starship_rotation_magnitude                                   ;
    sta sound_10_pitch                                                ;
    beq skip_ceiling                                                  ;
    adc #2                                                            ;
    cmp #$0d                                                          ; Pitch = (velocity_high * 2) + rotation_magnitude
    bcc skip_ceiling                                                  ;
    lda #12                                                           ; volume = -min(pitch, 9) + 1
skip_ceiling
    ldx #<(sound_10)                                                  ;
    jsr sound_with_volume                                             ;
    jsr enable_engine_interrupt                                       ;
}
return19
    rts                                                               ;

; ----------------------------------------------------------------------------------
play_sound_for_exploding_starship
!if elk=0 {
    jsr disable_engine_interrupt                                      ;
}
    lda starship_explosion_countdown                                  ;
    sec                                                               ;
    sbc #frame_of_starship_explosion_after_which_no_sound             ;
    bcc skip_starship_explosion_sound                                 ;
    sta x_pixels                                                      ;
    rol                                                               ;
    cmp #$56                                                          ;
    bcc skip_pitch_bend                                               ;
    sbc #$40                                                          ;
    rol                                                               ;
    rol                                                               ;
skip_pitch_bend
    sta sound_1_pitch                                                 ;
    lda x_pixels                                                      ;
    lsr                                                               ;
    cmp #$10                                                          ;
    bcc skip_ceiling1                                                 ;
    lda #$0f                                                          ;
skip_ceiling1
    ldx #<(sound_2)                                                   ;
    jsr sound_with_volume                                             ;
!if elk=0 {
    ldx #<(sound_1)                                                   ; } no sound output here (volume is 0), but it
    jsr do_osword_sound                                               ; } sets the pitch for the white noise of sound_2 to follow...
}
skip_starship_explosion_sound
    lda escape_capsule_sound_channel                                  ;
    beq consider_torpedo_sound                                        ;
    lda #3                                                            ;
    sta escape_capsule_sound_channel                                  ; 3 if starship exploding

play_escape_capsule_sound
    ora #$10                                                          ; flush channel; play sound immediately
    sta sound_8                                                       ;
!if elk=0 {
    jsr disable_engine_interrupt                                      ;
}
    lda self_destruct_countdown                                       ;
    and #1                                                            ;
    beq silent                                                        ;
    lda self_destruct_countdown                                       ;
    lsr                                                               ;
    lsr                                                               ;
silent
    ldx #<(sound_8)                                                   ;
    jsr sound_with_volume                                             ;
    lda escape_capsule_sound_channel                                  ;
    cmp #3                                                            ; has the starship exploded?
    beq return19                                                      ;
consider_torpedo_sound
    lda starship_fired_torpedo                                        ;
    beq skip_starship_torpedo_sound                                   ;
    ldx #<(sound_3)                                                   ;
    bne do_osword_sound                                               ; ALWAYS branch

skip_starship_torpedo_sound
    lda enemy_ships_collided_with_each_other                          ;
    beq return19                                                      ;
    ldx #<(sound_7)                                                   ;
    bne do_osword_sound                                               ; ALWAYS branch

sound_with_volume
    ; negate and sign-extend the volume
    eor #$ff                                                          ;
    clc                                                               ;
    adc #1                                                            ;
    sta sounds+2, x                                                   ; volume low byte
    beq set_volume_high                                               ;
    lda #$ff                                                          ;
set_volume_high
    sta sounds+3, x                                                   ; volume high byte
do_osword_sound
    ldy #>(sound_1)                                                   ; all sounds in the same page
    lda #osword_sound                                                 ;
    jmp (wordv)                                                       ;

; ----------------------------------------------------------------------------------
flash_energy_when_low
    lda energy_flash_timer                                            ;
    bne energy_is_already_low                                         ;
    lda starship_energy_divided_by_sixteen                            ;
    cmp #$32                                                          ;
    bcs return20                                                      ;
    lda #12                                                           ;
    sta energy_flash_timer                                            ;
consider_warning_sound
    lda starship_energy_divided_by_sixteen                            ;
    cmp #$19                                                          ;
    bcs invert_energy_text                                            ;

    ; beep has started
    lda starship_has_exploded                                         ;
    ora escape_capsule_sound_channel                                  ;
    ora sound_enabled                                                 ;
    bne invert_energy_text                                            ;
    lda #1                                                            ;
    sta sound_needed_for_low_energy                                   ;
!if elk=0 {
    jsr disable_engine_interrupt                                      ;
}
    ldx #<(sound_9)                                                   ;
    jsr do_osword_sound                                               ;

; ----------------------------------------------------------------------------------
invert_energy_text
    ldy #7                                                            ;
invert_energy_text_loop
    lda energy_screen_address,y                                       ; E
    eor #$ff                                                          ;
    sta energy_screen_address,y                                       ;
    sta energy_screen_address+16,y                                    ; second E
    lda energy_screen_address+8,y                                     ; N
    eor #$ff                                                          ;
    sta energy_screen_address+8,y                                     ;
    lda energy_screen_address+24,y                                    ; R
    eor #$ff                                                          ;
    sta energy_screen_address+24,y                                    ;
    lda energy_screen_address+32,y                                    ; G
    eor #$ff                                                          ;
    sta energy_screen_address+32,y                                    ;
    lda energy_screen_address+40,y                                    ; Y
    eor #$ff                                                          ;
    sta energy_screen_address+40,y                                    ;
    dey                                                               ;
    bpl invert_energy_text_loop                                       ;
return20
    rts                                                               ;

; ----------------------------------------------------------------------------------
energy_is_already_low
    dec energy_flash_timer                                            ;
    cmp #10                                                           ;
    beq invert_energy_text                                            ;
    cmp #11                                                           ;
    bne return20                                                      ;
nobeep
    ; beep has finished
    lda starship_has_exploded                                         ;
    ora escape_capsule_sound_channel                                  ;
    ora sound_enabled                                                 ;
    bne return20                                                      ;
    lda #0                                                            ;
    sta sound_needed_for_low_energy                                   ;
    jmp play_starship_engine_sound                                    ;

; ----------------------------------------------------------------------------------
handle_enemy_ships_cloaking
    lda #maximum_number_of_enemy_ships                                ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
handle_enemy_ships_cloaking_loop
    lda enemy_ships_type,x                                            ;
    cmp #4                                                            ;
    ror temp8                                                         ;
    bmi enemy_ship_is_already_cloaked                                 ;
    cmp #1                                                            ; only long ships can cloak
    bne handle_enemy_ships_cloaking_next                              ;
enemy_ship_is_already_cloaked
    ldy enemy_ships_on_screen,x                                       ;
    beq enemy_ship_is_on_screen1                                      ;
    and #3                                                            ; ships decloak when not on main screen
    sta enemy_ships_type,x                                            ;
    jmp handle_enemy_ships_cloaking_next                              ;

enemy_ship_is_on_screen1
    ldy enemy_ships_energy,x                                          ;
    cpy #minimum_energy_for_enemy_ship_to_cloak                       ;
    bcs enemy_ship_has_sufficient_energy_to_cloak                     ;
    asl temp8                                                         ;
    bcc handle_enemy_ships_cloaking_next                              ;
    and #3                                                            ; uncloak it if cloaked, and plot
    sta enemy_ships_type,x                                            ;
    jsr plot_enemy_ship                                               ;
    jmp handle_enemy_ships_cloaking_next                              ;

enemy_ship_has_sufficient_energy_to_cloak
    asl temp8                                                         ;
    bcs handle_enemy_ships_cloaking_next                              ; leave it cloaked if so
    jsr random_number_generator                                       ;
    and #probability_of_enemy_ship_cloaking                           ;
    bne handle_enemy_ships_cloaking_next                              ;
    jsr plot_enemy_ship                                               ; otherwise, mark as cloaked and unplot
    lda enemy_ships_type,x                                            ;
    ora #4                                                            ;
    sta enemy_ships_type,x                                            ;
handle_enemy_ships_cloaking_next
    inx                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    bne handle_enemy_ships_cloaking_loop                              ;
return21
    rts                                                               ;

; ----------------------------------------------------------------------------------
; On Entry:
;   X = enemy ship index
; Preserves X
fire_enemy_torpedo
    ; are we done?
    lda torpedoes_still_to_consider                                   ;
    beq leave_after_clearing_carry                                    ;

    ; are we still cooling down after a previous shot?
    lda enemy_ships_firing_cooldown,x                                 ; lower four bits are torpedo cooldown
    and #$0f                                                          ;
    bne leave_after_clearing_carry                                    ; can't fire until this is zero

    ; find free slot
    ldy #index_of_enemy_torpedoes                                     ;
find_enemy_torpedo_slot_loop
    lda object_table_time_to_live,y                                   ;
    beq found_free_slot                                               ;
    iny                                                               ;
    dec torpedoes_still_to_consider                                   ;
    bne find_enemy_torpedo_slot_loop                                  ;
leave_after_clearing_carry
    clc                                                               ; no torpedo fired
    rts                                                               ;

found_free_slot
    sty current_object_index                                          ;
    lda enemy_ships_angle,x                                           ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    cmp enemy_ship_desired_angle_divided_by_eight                     ;
    bne leave_after_clearing_carry                                    ; can't fire if not pointing at starship
    lda enemy_ships_firing_cooldown,x                                 ;
    lsr                                                               ; upper four bits are maximum cooldown
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    adc enemy_ships_firing_cooldown,x                                 ;
    sta enemy_ships_firing_cooldown,x                                 ; reset torpedo cooldown
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    and #$10                                                          ;
    beq single_torpedo                                                ;

    ; fire enemy torpedo cluster
    lda enemy_ships_angle,x                                           ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    tay                                                               ;
    lda sine_table,y                                                  ;
    clc                                                               ;
    adc enemy_ships_x_pixels,x                                        ;
    sta output_fraction                                               ; torpedo_x = enemy_ship_x + sin(angle)
    lda cosine_table,y                                                ;
    clc                                                               ;
    adc enemy_ships_y_pixels,x                                        ;
    sta output_pixels                                                 ; torpedo_y = enemy_ship_y + cos(angle)
    jsr add_single_torpedo_to_enemy_torpedo_cluster                   ;
    dec output_fraction                                               ;
    dec output_fraction                                               ; torpedo_x = enemy_ship_x + sin(angle) - 2
    dec output_pixels                                                 ;
    dec output_pixels                                                 ; torpedo_y = enemy_ship_y + cos(angle) - 2
    jsr add_single_torpedo_to_enemy_torpedo_cluster                   ;
    dec output_pixels                                                 ; torpedo_y = enemy_ship_y + cos(angle) - 3
    inc output_fraction                                               ;
    inc output_fraction                                               ;
    inc output_fraction                                               ; torpedo_x = enemy_ship_x + sin(angle) + 1
    jsr add_single_torpedo_to_enemy_torpedo_cluster                   ;
    sec                                                               ; torpedo was fired
    rts                                                               ;

single_torpedo
    lda value_used_for_enemy_torpedo_time_to_live                     ;
    ldy current_object_index                                          ;
    sta object_table_time_to_live,y                                   ;
    lda enemy_ships_angle,x                                           ;
    sta object_table_angle,y                                          ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    tay                                                               ;
    lda sine_table,y                                                  ;
    clc                                                               ;
    adc enemy_ships_x_pixels,x                                        ;
    sta x_pixels                                                      ; torpedo_x = enemy_ship_x + sin(angle)
    lda cosine_table,y                                                ;
    clc                                                               ;
    adc enemy_ships_y_pixels,x                                        ;
    ldy current_object_index                                          ;
    sta object_table_ypixels,y                                        ; torpedo_y = enemy_ship_y + cos(angle)
    lda x_pixels                                                      ;
    sta object_table_xpixels,y                                        ;
    inc enemy_ship_fired_torpedo                                      ;
    stx temp8                                                         ;
    jsr plot_enemy_torpedo                                            ; plot torpedo
    ldx temp8                                                         ;
    dec torpedoes_still_to_consider                                   ;
;    inc current_object_index                                          ;
    sec                                                               ; torpedo fired
    rts                                                               ;

; tables of rotations for each of the eight combinations of x-flip, y-flip and xy-swap
angle_result_table_8
    !byte $00,$18,$00,$08,$10,$18,$10,$08
angle_result_table_9
    !byte $1f,$19,$01,$07,$11,$17,$0f,$09
angle_result_table_10
    !byte $1e,$1a,$02,$06,$12,$16,$0e,$0a
angle_result_table_11
    !byte $1d,$1b,$03,$05,$13,$15,$0d,$0b
angle_result_table_12
    !byte $1c,$1c,$04,$04,$14,$14,$0c,$0c

; ----------------------------------------------------------------------------------
; On Entry:
;   (temp10, temp9) are the (x,y) coordinates of the enemy ship
; On Exit:
;   Angle in A. Preserves X
; ----------------------------------------------------------------------------------

; original code: 1574cs, ~480 cycles, 122 bytes, accuracy OK
; Toby's code: 702cs, ~214 cycles, 152 bytes, accuracy excellent
; with accurate_atan2=1: 452cs, ~138 cycles, 211 bytes. accuracy as Toby's
; with accurate_atan2=0: 411cs, ~125 cycles, 179 bytes, accuracy OK
accurate_atan2 = 0

calculate_enemy_ship_angle_to_starship
    lda temp9                                                         ;
calculate_enemy_ship_angle_to_starship_ycoord_in_a
    ldy #0                                                            ;
    sty temp8                                                         ;
!if accurate_atan2 {
    sec                                                               ;
    bmi skip_inversion_y3                                             ;
    eor #$ff                                                          ;
    sbc #1                                                            ;
    clc                                                               ;
.skip_inversion_y3
    rol temp8                                                         ; note whether inversion occurred
;    sec                                                              ;
    sbc #$7e                                                          ; difference from centre point (starship)
    sta y_pixels                                                      ;

    lda temp10                                                        ;
    bmi skip_inversion_x3                                             ;
;    sec                                                               ;
    eor #$ff                                                          ;
    sbc #1                                                            ;
    clc                                                               ;
skip_inversion_x3
    rol temp8                                                         ; note whether inversion occurred
;    sec                                                               ;
    sbc #$7e                                                          ; difference from centre point (starship)
} else {
    sec                                                               ;
    sbc #$7f                                                          ; difference from centre point (starship)
    bpl skip_inversion_y3                                             ;
    eor #$ff                                                          ;
skip_inversion_y3
    rol temp8                                                         ; note whether inversion occurred
    sta y_pixels                                                      ;

    lda temp10                                                        ;
    sbc #$7e                                                          ; difference from centre point (starship)
    bpl skip_inversion_x3                                             ;
    eor #$ff                                                          ;
skip_inversion_x3
    rol temp8                                                         ; note whether inversion occurred
}
    sta x_pixels                                                      ;

    cmp y_pixels                                                      ;
    bcs skip_swap                                                     ; swap if y is bigger than x
    ldy y_pixels                                                      ;
    sty x_pixels                                                      ;
    sta y_pixels                                                      ;
skip_swap
    rol temp8                                                         ; note whether swap occurred

    ; At this point x_pixels >= y_pixels, and both values are distances from centre point

    ; use fast 8 bit multiply with fixed constants
    ldy x_pixels                                                      ;
    tya                                                               ;
    ; through cunning use of binary search we can narrow down the number of
    ; multiplications required to at most one
    lsr                                                               ;
    cmp y_pixels                                                      ; 128
    bcc angle_10_or_greater                                           ;
    lsr                                                               ;
    cmp y_pixels                                                      ; 64
    bcc angle_9_or_greater                                            ;
    lsr                                                               ;
    cmp y_pixels                                                      ; 32
    bcc return_angle_9                                                ;
    lsr                                                               ;
    cmp y_pixels                                                      ; 16
    bcs return_angle_8                                                ;
angle_8_or_greater
!if accurate_atan2 {
    lda squares1_low + 25,y                                           ;
    ;sec                                                               ;
    sbc squares2_low + 255-25,y                                       ;
}
    lda squares1_high + 25,y                                          ;
    sbc squares2_high + 255-25,y                                      ;
    cmp y_pixels                                                      ;
    bcc return_angle_9                                                ; if (x*25/256 >= y) then angle=8
return_angle_8
    ldy temp8                                                         ;
    lda angle_result_table_8,y                                        ;
    rts                                                               ;
return_angle_9
    ldy temp8                                                         ;
    lda angle_result_table_9,y                                        ;
    rts                                                               ;
angle_9_or_greater
!if accurate_atan2 {
    lda squares1_low + 78,y                                           ;
    sec                                                               ;
    sbc squares2_low + 255-78,y                                       ;
}
    lda squares1_high + 78,y                                          ;
    sbc squares2_high + 255-78,y                                      ;
    cmp y_pixels                                                      ;
    bcs return_angle_9                                                ; if (x*78/256 >= y) then angle=9
return_angle_10
    ldy temp8                                                         ;
    lda angle_result_table_10,y                                       ;
    rts                                                               ;

angle_10_or_greater
    adc x_pixels                                                      ;
    ror                                                               ;
    cmp y_pixels                                                      ; 192
    bcc angle_11_or_greater                                           ;
!if accurate_atan2 {
    lda squares1_low + 137,y                                          ;
    ;sec                                                               ;
    sbc squares2_low + 255-137,y                                      ;
}
    lda squares1_high + 137,y                                         ;
    sbc squares2_high + 255-137,y                                     ;
    cmp y_pixels                                                      ;
    bcs return_angle_10                                               ; if (x*137/256 >= y) then angle=10
return_angle_11
    ldy temp8                                                         ;
    lda angle_result_table_11,y                                       ;
    rts                                                               ;

angle_11_or_greater
    ; commented out because of extremely marginal benefit
;    adc x_pixels
;    ror
;    cmp y_pixels ; 224
;    bcc return_angle_12
!if accurate_atan2 {
    lda squares1_low + 210,y                                          ;
    sec                                                               ;
    sbc squares2_low + 255-210,y                                      ;
}
    lda squares1_high + 210,y                                         ;
    sbc squares2_high + 255-210,y                                     ;
    cmp y_pixels                                                      ;
    bcs return_angle_11                                               ; if (x*210/256 >= y) then angle=11
return_angle_12
    ldy temp8                                                         ;
    lda angle_result_table_12,y                                       ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
collide_enemy_ships
    ldx temp0_low                                                     ;
    lda enemy_ships_energy,x                                          ;
    beq first_ship_is_already_exploding                               ;
    sec                                                               ;
    sbc #damage_enemy_ship_incurs_from_collision_with_other_enemy_ship ;
    bcs skip_floor                                                    ;
    lda #0                                                            ;
skip_floor
    sta enemy_ships_energy,x                                          ;
    bne first_ship_survives_collision                                 ;
    jsr explode_enemy_ship                                            ;
first_ship_survives_collision
    lda enemy_ships_type,x                                            ;
    cmp #4                                                            ;
    bcc first_ship_is_already_exploding                               ;
    and #3                                                            ; remove cloaking
    sta enemy_ships_type,x                                            ;
    lda #1                                                            ;
    sta enemy_ships_previous_on_screen,x                              ;
first_ship_is_already_exploding
    ldy temp1_low                                                     ;
    lda enemy_ships_velocity,x                                        ;
    sta x_pixels                                                      ;
    lda enemy_ships_velocity,y                                        ;
    sta y_pixels                                                      ;

    lda enemy_ships_angle,x                                           ; swap the angles of the two ships
    sta temp7                                                         ;
    lda enemy_ships_angle,y                                           ;
    sta enemy_ships_angle,x                                           ;
    lda temp7                                                         ;
    sta enemy_ships_angle,y                                           ;

    ; get difference in angles
    sec                                                               ;
    sbc enemy_ships_angle,x                                           ;

    ; get the magnitude of the angle difference
    bpl skip_inversion4                                               ;
    eor #$ff                                                          ;
skip_inversion4
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    beq skip_velocity_absorption                                      ;

angle_loop
    lsr x_pixels                                                      ; For every 11.25 degrees difference in angle,
    lsr y_pixels                                                      ; halve both ships' velocities
    sec                                                               ;
    sbc #1                                                            ;
    bne angle_loop                                                    ;

skip_velocity_absorption
    lda x_pixels                                                      ; swap the velocities of the two ships
    sta enemy_ships_velocity,y                                        ;
    lda y_pixels                                                      ;
    sta enemy_ships_velocity,x                                        ;

    ;
    lda enemy_ships_collision_x_difference                            ;
    cmp enemy_ships_collision_y_difference                            ;
    bcs use_x_pixels_and_difference                                   ; if (x position difference > y position difference) then branch
    inx                                                               ; use y coordinates rather than x coordinates
    inx                                                               ;
    inx                                                               ;
    iny                                                               ;
    iny                                                               ;
    iny                                                               ;
    lda enemy_ships_collision_y_difference                            ;
use_x_pixels_and_difference

    sta y_pixels                                                      ; store largest coordinate difference
    lda #size_of_enemy_ship_for_collisions_between_enemy_ships        ;
    sec                                                               ;
    sbc y_pixels                                                      ;
    clc                                                               ;
    adc #1                                                            ;
    lsr                                                               ;
    sta y_pixels                                                      ; y_pixels =  (8 - largest coordinate difference + 1)/2

    ; sort so the first ship has the larger coordinate
    lda enemy_ships_x_pixels,x                                        ;
    cmp enemy_ships_x_pixels,y                                        ;
    bcs dont_swap_two_ships_for_collision                             ;
    sty x_pixels                                                      ; swap the two enemy ships
    txa                                                               ;
    tay                                                               ;
    ldx x_pixels                                                      ;
dont_swap_two_ships_for_collision

    ; add positive? offset to first ship
    lda enemy_ships_x_pixels,x                                        ;
    clc                                                               ;
    adc y_pixels                                                      ; add offset to the first ship
    bcs dont_alter_first_ships_position                               ;
    sta enemy_ships_x_pixels,x                                        ;
dont_alter_first_ships_position

    ; subtract negative offset from second ship
    lda enemy_ships_x_pixels,y                                        ;
    sec                                                               ;
    sbc y_pixels                                                      ; subtract it from the other
    bcc dont_alter_second_ships_position                              ;
    sta enemy_ships_x_pixels,y                                        ;
dont_alter_second_ships_position
    jmp consider_next_second_enemy_ship                               ;

; ----------------------------------------------------------------------------------
escape_capsule_destroyed
    !byte 0                                                           ;
self_destruct_countdown
    !byte 0                                                           ;
escape_capsule_launch_direction
    !byte 0                                                           ;

; ----------------------------------------------------------------------------------
initialise_game_screen
    jsr initialise_starship_explosion_pieces                          ;
    jsr plot_starship                                                 ;
    ldx #regular_string_index_energy_string                           ;
    jsr print_regular_string                                          ;
    jsr plot_energy_bar_edges                                         ;
    jsr plot_gauge_edges                                              ;
    jsr plot_scanner_grid                                             ;
    jsr plot_command_number                                           ;
!if do_debug = 0 {
    ldy #index_of_in_game_stars                                       ;
    jsr plot_and_rotate_in_game_stars                                 ;
}
    jsr plot_top_and_right_edge_of_long_range_scanner_without_text    ;
    ldx #$c7                                                          ; draw full
    jsr skip_swapping_start_and_end                                   ; energy bars
    jsr initialise_joystick                                           ;
    jsr plot_score                                                    ;
    jmp screen_on                                                     ;
return22
    rts                                                               ;

; ----------------------------------------------------------------------------------
launch_escape_capsule_port
    ldy #$c0                                                          ;
    bne launch_escape_capsule                                         ;
launch_escape_capsule_starboard
    ldy #$40                                                          ;
launch_escape_capsule
    inc escape_capsule_launched                                       ;
    sty escape_capsule_launch_direction                               ;
    +finish_keyboard_read
    lda #$3f                                                          ;
    sta self_destruct_countdown                                       ;
    ldx #regular_string_index_escape_capsule_launched                 ;
    jsr print_regular_string                                          ;
    lda #$7f                                                          ;
    sta escape_capsule_x_pixels                                       ;
    sta escape_capsule_y_pixels                                       ;
    sta escape_capsule_on_screen                                      ;
    bne update_escape_capsule                                         ; ALWAYS branch

handle_starship_self_destruct
    lda escape_capsule_launched                                       ;
    beq return22                                                      ; self-destruct only after escape capsule launched
    lda self_destruct_countdown                                       ;
    beq skip_immense_damage                                           ;
    dec self_destruct_countdown                                       ;
    bne skip_immense_damage                                           ;
    lda #$40                                                          ;
    sta damage_high                                                   ;
skip_immense_damage
    lda escape_capsule_on_screen                                      ;
    beq return22                                                      ;
    jsr plot_escape_capsule                                           ;
update_escape_capsule
    ldy #index_of_escape_capsule                                      ;
    jsr update_object_position_for_starship_rotation_and_speed        ;
    lda escape_capsule_launch_direction                               ;
    clc                                                               ;
    adc starship_angle_delta                                          ;
    sta escape_capsule_launch_direction                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    tay                                                               ;
    lda sine_table,y                                                  ;
    clc                                                               ;
    adc escape_capsule_x_pixels                                       ;
    sta escape_capsule_x_pixels                                       ;
    lda cosine_table,y                                                ;
    clc                                                               ;
    adc escape_capsule_y_pixels                                       ;
    sta escape_capsule_y_pixels                                       ;
    sec                                                               ;
    sbc y_pixels                                                      ;
    bcs skip_inversion5                                               ;
    eor #$ff                                                          ;
skip_inversion5
    cmp #$40                                                          ;
    bcs mark_escape_capsule_as_off_screen                             ;
    lda escape_capsule_x_pixels                                       ;
    sec                                                               ;
    sbc x_pixels                                                      ;
    bcs skip_inversion6                                               ;
    eor #$ff                                                          ;
skip_inversion6
    cmp #$40                                                          ;
    bcs mark_escape_capsule_as_off_screen                             ;
    jsr check_for_collision_with_enemy_ships                          ;
    bcc plot_escape_capsule                                           ;

    ;
    ; escape capsule collided with enemy ship
    ;
    lda #maximum_number_of_enemy_ships                                ;
    sec                                                               ;
    sbc enemy_ships_still_to_consider                                 ;
    tax                                                               ;
    lda enemy_ships_energy,x                                          ;
    beq enemy_ship_is_already_exploding                               ;
    lda #0                                                            ;
    sta enemy_ships_energy,x                                          ;
    jsr explode_enemy_ship                                            ;
enemy_ship_is_already_exploding
    ldy #index_of_escape_capsule                                      ;
    jsr plot_expiring_torpedo                                         ;
    lda #1                                                            ;
    sta escape_capsule_destroyed                                      ;
mark_escape_capsule_as_off_screen
    ldy #0                                                            ;
    sty escape_capsule_on_screen                                      ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_escape_capsule
    ldx escape_capsule_x_pixels                                       ;
    ldy escape_capsule_y_pixels                                       ;    6
    sty y_pixels                                                      ;    5
    jsr eor_play_area_pixel                                           ;  34012
    inx                                                               ;    7
    jsr eor_two_play_area_pixels_same_y                               ;    8
    dex                                                               ;
    dex                                                               ;
    dex                                                               ;
    jsr eor_two_play_area_pixels_same_y                               ;
    inx                                                               ;
    inx                                                               ;
    inc y_pixels                                                      ;
    jsr eor_play_area_pixel                                           ;
    inc y_pixels                                                      ;
    jsr eor_play_area_pixel                                           ;
    ldy escape_capsule_y_pixels                                       ;
    dey                                                               ;
    sty y_pixels                                                      ;
    jsr eor_play_area_pixel                                           ;
    dec y_pixels                                                      ;
    jmp eor_play_area_pixel                                           ;

; ----------------------------------------------------------------------------------
add_single_torpedo_to_enemy_torpedo_cluster
    lda value_used_for_enemy_torpedo_time_to_live                     ;
    ldy current_object_index                                          ;
    sta object_table_time_to_live,y                                   ;
    lda output_fraction                                               ;
    sta object_table_xpixels,y                                        ;
    lda output_pixels                                                 ;
    sta object_table_ypixels,y                                        ;
    lda enemy_ships_angle,x                                           ;
    sta object_table_angle,y                                          ;
    inc enemy_ship_fired_torpedo                                      ;
    stx temp8                                                         ;
    jsr plot_enemy_torpedo                                            ; plot torpedo
    ldx temp8                                                         ;
find_free_torpedo_slot
    dec torpedoes_still_to_consider                                   ;
    beq dont_add_any_more_torpedoes_to_cluster                        ;
    inc current_object_index                                          ;
    ldy current_object_index                                          ;
    lda object_table_time_to_live,y                                   ;
    bne find_free_torpedo_slot                                        ;
    rts                                                               ;

dont_add_any_more_torpedoes_to_cluster
    pla                                                               ; abandon remainder of fire_enemy_torpedo_cluster
    pla                                                               ;
    sec                                                               ; torpedo was fired
    rts                                                               ;

; ----------------------------------------------------------------------------------
angle_to_action_table
    !byte 0, 0, 1, 3, 7, 5, 2, 2                                      ;

enemy_ship_behaviour_routine_low_table
    !byte <(enemy_ship_behaviour_routine0)                            ;
    !byte <(enemy_ship_behaviour_routine1)                            ;
    !byte <(enemy_ship_behaviour_routine2)                            ;
    !byte <(enemy_ship_behaviour_routine3)                            ;
    !byte <(enemy_ship_behaviour_routine4)                            ;
    !byte <(enemy_ship_behaviour_routine5)                            ;
    !byte <(enemy_ship_behaviour_routine6)                            ;
    !byte <(enemy_ship_behaviour_routine7)                            ;
    !byte <(enemy_ship_behaviour_routine4)                            ;
    !byte <(enemy_ship_behaviour_routine0)                            ;
    !byte <(enemy_ship_behaviour_routine7)                            ;
    !byte <(enemy_ship_behaviour_routine5)                            ;
    !byte <(enemy_ship_behaviour_routine6)                            ;
    !byte <(enemy_ship_behaviour_routine2)                            ;
    !byte <(enemy_ship_behaviour_routine3)                            ;
    !byte <(enemy_ship_behaviour_routine1)                            ;
enemy_ship_behaviour_routine_high_table
    !byte >(enemy_ship_behaviour_routine0)                            ;
    !byte >(enemy_ship_behaviour_routine1)                            ;
    !byte >(enemy_ship_behaviour_routine2)                            ;
    !byte >(enemy_ship_behaviour_routine3)                            ;
    !byte >(enemy_ship_behaviour_routine4)                            ;
    !byte >(enemy_ship_behaviour_routine5)                            ;
    !byte >(enemy_ship_behaviour_routine6)                            ;
    !byte >(enemy_ship_behaviour_routine7)                            ;
    !byte >(enemy_ship_behaviour_routine4)                            ;
    !byte >(enemy_ship_behaviour_routine0)                            ;
    !byte >(enemy_ship_behaviour_routine7)                            ;
    !byte >(enemy_ship_behaviour_routine5)                            ;
    !byte >(enemy_ship_behaviour_routine6)                            ;
    !byte >(enemy_ship_behaviour_routine2)                            ;
    !byte >(enemy_ship_behaviour_routine3)                            ;
    !byte >(enemy_ship_behaviour_routine1)                            ;

enemy_ship_desired_velocity
    !byte 0                                                           ;

; ----------------------------------------------------------------------------------
enemy_ship_defensive_behaviour_handling
    lda enemy_ships_on_screen,x                                       ;
    bne unset_retreating_flags                                        ;
    lda enemy_ships_x_pixels,x                                        ;
    sta temp10                                                        ;
    lda enemy_ships_y_pixels,x                                        ;
    jsr calculate_enemy_ship_angle_to_starship_ycoord_in_a            ;
    sta enemy_ship_desired_angle_divided_by_eight
    ldy enemy_ships_temporary_behaviour_flags,x                       ;
    bmi skip_retreating_because_of_damage                             ; if not already retreating,
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    and #$40                                                          ;
    beq skip_retreating_because_of_damage                             ; and enemy ship is defensive_about_damage
    tya                                                               ;
    and #$0f                                                          ;
    beq skip_retreating_because_of_damage                             ; and enemy_ship_hit_count > 0
    tya                                                               ;
    ora #$80                                                          ; set retreating
    tay                                                               ;
skip_retreating_because_of_damage
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    and #$20                                                          ;
    beq skip_retreating_because_of_angle                              ;
    tya                                                               ;
    and #$40                                                          ;
    bne already_retreating_because_of_angle                           ; if not already retreating because of angle,
    lda enemy_ship_desired_angle_divided_by_eight                     ;
    clc                                                               ;
    adc #3                                                            ;
    and #$1f                                                          ;
    cmp #7                                                            ; if within 33.75 degrees of starship
    bcs skip_retreating_because_of_angle                              ;
    tya                                                               ;
    ora #$40                                                          ; set retreating_because_of_angle
    bne set_temporary_behaviour_flags                                 ;
already_retreating_because_of_angle                                   ; if retreating because of angle,
    lda enemy_ship_desired_angle_divided_by_eight                     ;
    clc                                                               ;
    adc #5                                                            ;
    and #$1f                                                          ;
    cmp #11                                                           ; if not within 56.25 degrees of starship
    bcc skip_retreating_because_of_angle                              ;
    tya                                                               ;
    and #$bf                                                          ; unset retreating_because_of_angle
    tay                                                               ;
skip_retreating_because_of_angle
    tya                                                               ;
set_temporary_behaviour_flags
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    and #$c0                                                          ;
    beq leave_after_clearing_carry1                                   ; if retreating,
    jsr turn_enemy_ship_towards_desired_angle                         ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    sec                                                               ; skip behaviour routine
    rts                                                               ;

; ----------------------------------------------------------------------------------
unset_retreating_flags
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    and #$3f                                                          ; unset retreating | retreating_because_of_angle
    sta enemy_ships_temporary_behaviour_flags,x                       ;
leave_after_clearing_carry1
    clc                                                               ; do behaviour routine
    rts                                                               ;

; ----------------------------------------------------------------------------------
get_rectilinear_distance_from_centre_of_screen_accounting_for_starship_velocity
    lda enemy_ships_x_pixels,x                                        ;
    bmi skip_inversion7                                               ;
    eor #$ff                                                          ;
skip_inversion7
    sta x_pixels                                                      ;
    lda starship_velocity_low                                         ;
    sta y_pixels                                                      ;
    lda starship_velocity_high                                        ;
    asl y_pixels                                                      ;
    rol                                                               ;
    asl y_pixels                                                      ;
    rol                                                               ;
    asl y_pixels                                                      ;
    rol                                                               ; starship_velocity_high * 8
    adc enemy_ships_y_pixels,x                                        ;
    bmi skip_inversion8                                               ;
    eor #$ff                                                          ;
skip_inversion8
    clc                                                               ;
    adc x_pixels                                                      ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
get_rectilinear_distance_from_centre_of_screen
    lda enemy_ships_x_pixels,x                                        ;
    bmi skip_inversion_x4                                             ;
    eor #$ff                                                          ;
skip_inversion_x4
    sta x_pixels                                                      ;
    lda enemy_ships_y_pixels,x                                        ;
    bmi skip_inversion_y4                                             ;
    eor #$ff                                                          ;
skip_inversion_y4
    clc                                                               ;
    adc x_pixels                                                      ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
turn_enemy_ship_towards_starship_using_screens
    lda enemy_ships_x_screens,x                                       ;
    sta temp10                                                        ;
    lda enemy_ships_y_screens,x                                       ;
    sta temp9                                                         ;
    jmp turn_enemy_ship_towards_starship                              ;

; ----------------------------------------------------------------------------------
turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity
    lda enemy_ship_desired_angle_divided_by_eight                     ;
    bpl turn_enemy_ship_towards_angle_accounting_for_starship_velocity ; ALWAYS branch

; ----------------------------------------------------------------------------------
turn_enemy_ship_towards_starship
    jsr calculate_enemy_ship_angle_to_starship                        ;
turn_enemy_ship_towards_angle_accounting_for_starship_velocity
    eor #$10
    sta enemy_ship_desired_angle_divided_by_eight                     ;
    cmp #$11                                                          ;
    bcc skip_inversion9                                               ;
    eor #$1f                                                          ;
    adc #0                                                            ;
    sec                                                               ;
skip_inversion9
    ror temp8                                                         ;
    tay                                                               ;
    lda sine_table,y                                                  ;
    sta y_pixels                                                      ;
    lda starship_velocity_low                                         ;
    sta x_pixels                                                      ;
    lda starship_velocity_high                                        ;
    asl x_pixels                                                      ;
    rol                                                               ;
    asl x_pixels                                                      ;
    rol                                                               ;
    asl x_pixels                                                      ;
    rol                                                               ;
    sta x_pixels                                                      ;

    ; 3-bit multiplication of sine by starship_velocity
    lda #0                                                            ;
    tay                                                               ; Y=0
    lsr y_pixels                                                      ;
    bcc +                                                             ;
    clc                                                               ;
    adc x_pixels                                                      ;
+
    ror                                                               ;
    lsr y_pixels                                                      ;
    bcc +                                                             ;
    clc                                                               ;
    adc x_pixels                                                      ;
+
    ror                                                               ;
    lsr y_pixels                                                      ;
    bcc +                                                             ;
    clc                                                               ;
    adc x_pixels                                                      ;
+
    ror                                                               ; A = starship_velocity * sin(angle)

    lsr                                                               ;
    cmp #2                                                            ;
    bcc finished_calculating_change_in_angle                          ;
    iny                                                               ;
    cmp #5                                                            ;
    bcc finished_calculating_change_in_angle                          ;
    iny                                                               ;
    cmp #8                                                            ;
    bcc finished_calculating_change_in_angle                          ;
    iny                                                               ;
    cmp #11                                                           ;
    bcc finished_calculating_change_in_angle                          ;
    iny                                                               ;
    cmp #14                                                           ;
    bcc finished_calculating_change_in_angle                          ;
    iny                                                               ;
finished_calculating_change_in_angle
    tya                                                               ;
    asl temp8                                                         ;
    bcc skip_uninversion3                                             ;
    eor #$1f                                                          ;
    adc #0                                                            ;
skip_uninversion3
    sta y_pixels                                                      ;
    lda enemy_ship_desired_angle_divided_by_eight                     ;
    sec                                                               ;
    sbc y_pixels                                                      ; adjust angle to account for starship velocity
    and #$1f                                                          ;
    sta enemy_ship_desired_angle_divided_by_eight                     ;
turn_enemy_ship_towards_desired_angle
    lda enemy_ships_angle,x                                           ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    sec                                                               ;
    sbc enemy_ship_desired_angle_divided_by_eight                     ;
    beq no_change_needed_to_enemy_ship_angle                          ;
    lsr                                                               ;
    lsr                                                               ;
    and #7                                                            ;
    tay                                                               ;
    lda angle_to_action_table,y                                       ;
    sta y_pixels                                                      ;
    lsr y_pixels                                                      ;
    bcc skip_velocity_decrease                                        ;
    jsr decrease_enemy_ship_velocity                                  ;
    lsr y_pixels                                                      ;
    bcc skip_velocity_decrease                                        ;
    jsr decrease_enemy_ship_velocity                                  ;
skip_velocity_decrease
    lsr y_pixels                                                      ;
    bcs increase_angle                                                ;
    dec enemy_ships_angle,x                                           ;
    dec enemy_ships_angle,x                                           ;
    jmp continue1                                                     ;

increase_angle
    inc enemy_ships_angle,x                                           ;
    inc enemy_ships_angle,x                                           ;
continue1
    lda enemy_ships_angle,x                                           ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    sec                                                               ;
    sbc enemy_ship_desired_angle_divided_by_eight                     ;
no_change_needed_to_enemy_ship_angle
    rts                                                               ;

decrease_enemy_ship_velocity
    lda enemy_ships_velocity,x                                        ;
    beq return23                                                      ;
    sec                                                               ;
    sbc #1                                                            ;
    sta enemy_ships_velocity,x                                        ;
return23
    rts                                                               ;

increase_or_decrease_enemy_ship_velocity_towards_desired_velocity
    lda enemy_ship_desired_velocity                                   ;
    cmp enemy_ships_velocity,x                                        ;
    beq return24                                                      ;
    bcs increase                                                      ;
    dec enemy_ships_velocity,x                                        ;
    jmp compare_velocity                                              ;

increase
    inc enemy_ships_velocity,x                                        ;
compare_velocity
    cmp enemy_ships_velocity,x                                        ; comparison is never actually used
return24
    rts                                                               ;

; ----------------------------------------------------------------------------------
starship_addresses_low
    !byte <starship_sprite_1
    !byte <starship_sprite_2
    !byte <starship_sprite_3
    !byte <starship_sprite_4
    !byte <starship_sprite_5
    !byte <starship_sprite_6
    !byte <starship_sprite_7
    !byte <starship_sprite_8
    !byte <starship_sprite_9
    !byte <starship_sprite_10
    !byte <starship_sprite_11
starship_addresses_high
    !byte >starship_sprite_1
    !byte >starship_sprite_2
    !byte >starship_sprite_3
    !byte >starship_sprite_4
    !byte >starship_sprite_5
    !byte >starship_sprite_6
    !byte >starship_sprite_7
    !byte >starship_sprite_8
    !byte >starship_sprite_9
    !byte >starship_sprite_10
    !byte >starship_sprite_11
num_starships = * - starship_addresses_high

; ----------------------------------------------------------------------------------
starship_sprite_1
    !byte %.#.....#                                                   ; .#.....#.....#..
    !byte %.#.....#                                                   ; .#.....#.....#..
    !byte %.#.....#                                                   ; .#.....#.....#..
    !byte %.#....##                                                   ; .#....###....#..
    !byte %###..###                                                   ; ###..#####..###.
    !byte %#.#..###                                                   ; #.#..#####..#.#.
    !byte %#.#..#.#                                                   ; #.#..#.#.#..#.#.
    !byte %#.#...##                                                   ; #.#...###...#.#.
    !byte %.....#..                                                   ; #####.###.#####.
    !byte %.....#..                                                   ; .#..#######..#..
    !byte %.....#..                                                   ; .#....###....#..
    !byte %#....#..                                                   ; .....#.#.#......
    !byte %##..###.                                                   ; ....##.#.##.....
    !byte %##..#.#.                                                   ; ....##.#.##.....
    !byte %.#..#.#.                                                   ; ....##.#.##.....
    !byte %#...#.#.                                                   ; .....#####......
    !byte %#####.##                                                   ;
    !byte %.#..####                                                   ;
    !byte %.#....##                                                   ;
    !byte %.....#.#                                                   ;
    !byte %....##.#                                                   ;
    !byte %....##.#                                                   ;
    !byte %....##.#                                                   ;
    !byte %.....###                                                   ;
    !byte %#.#####.                                                   ;
    !byte %###..#..                                                   ;
    !byte %#....#..                                                   ;
    !byte %.#......                                                   ;
    !byte %.##.....                                                   ;
    !byte %.##.....                                                   ;
    !byte %.##.....                                                   ;
    !byte %##......                                                   ;

starship_sprite_2
    !byte %......##                                                   ; ......###.......
    !byte %....##..                                                   ; ....##...##.....
    !byte %...#....                                                   ; ...#.......#....
    !byte %...#..##                                                   ; ...#..###..#....
    !byte %..#..#..                                                   ; ..#..#...#..#...
    !byte %..#..#.#                                                   ; ..#..#.#.#..#...
    !byte %..#..#..                                                   ; ..#..#...#..#...
    !byte %...#..##                                                   ; ...#..###..#....
    !byte %#.......                                                   ; ...#.......#....
    !byte %.##.....                                                   ; .#..##...##..#..
    !byte %...#....                                                   ; ###...###...###.
    !byte %#..#....                                                   ; ###..##.##..###.
    !byte %.#..#...                                                   ; ######...######.
    !byte %.#..#...                                                   ; ###..##.##..###.
    !byte %.#..#...                                                   ; ###...###...###.
    !byte %#..#....                                                   ; .#...........#..
    !byte %...#....                                                   ;
    !byte %.#..##..                                                   ;
    !byte %###...##                                                   ;
    !byte %###..##.                                                   ;
    !byte %######..                                                   ;
    !byte %###..##.                                                   ;
    !byte %###...##                                                   ;
    !byte %.#......                                                   ;
    !byte %...#....                                                   ;
    !byte %.##..#..                                                   ;
    !byte %#...###.                                                   ;
    !byte %##..###.                                                   ;
    !byte %.######.                                                   ;
    !byte %##..###.                                                   ;
    !byte %#...###.                                                   ;
    !byte %.....#..                                                   ;

; TOBY:
starship_sprite_3
    !byte %.......#                                                   ; .......#........
    !byte %......#.                                                   ; ......#.#.......
    !byte %......#.                                                   ; ......#.#.......
    !byte %.....#..                                                   ; .....#...#......
    !byte %.....#.#                                                   ; .....#.#.#......
    !byte %....#.#.                                                   ; ....#.#.#.#.....
    !byte %#..#.###                                                   ; #..#.#####.#..#.
    !byte %##.#....                                                   ; ##.#.......#.##.
    !byte %........                                                   ; #.##...#...##.#.
    !byte %#.......                                                   ; #..#..#.#..#..#.
    !byte %#.......                                                   ; #...##...##...#.
    !byte %.#......                                                   ; #...#.....#...#.
    !byte %.#......                                                   ; #..#.......#..#.
    !byte %#.#.....                                                   ; #.#.........#.#.
    !byte %##.#..#.                                                   ; .#...........#..
    !byte %...#.##.                                                   ; ..###########...
    !byte %#.##...#
    !byte %#..#..#.
    !byte %#...##..
    !byte %#...#...
    !byte %#..#....
    !byte %#.#.....
    !byte %.#......
    !byte %..######
    !byte %...##.#.
    !byte %#..#..#.
    !byte %.##...#.
    !byte %..#...#.
    !byte %...#..#.
    !byte %....#.#.
    !byte %.....#..
    !byte %#####...

starship_sprite_4
    !byte %.......#                                                   ; .......#........
    !byte %.....###                                                   ; .....#####......
    !byte %.#..##..                                                   ; .#..##...##..#..
    !byte %.#..##..                                                   ; .#..##...##..#..
    !byte %.#...###                                                   ; .#...#####...#..
    !byte %.#.....#                                                   ; .#.....#.....#..
    !byte %###...#.                                                   ; ###...#.#...###.
    !byte %#.#....#                                                   ; #.#....#....#.#.
    !byte %........                                                   ; #.#...#.#...#.#.
    !byte %##......                                                   ; #.#....#....#.#.
    !byte %.##..#..                                                   ; #..#..###..#..#.
    !byte %.##..#..                                                   ; #..###...###..#.
    !byte %##...#..                                                   ; #.#.#.....#.#.#.
    !byte %.....#..                                                   ; .#...#...#...#..
    !byte %#...###.                                                   ; ......#.#.......
    !byte %....#.#.                                                   ; .......#........
    !byte %#.#...#.                                                   ;
    !byte %#.#....#                                                   ;
    !byte %#..#..##                                                   ;
    !byte %#..###..                                                   ;
    !byte %#.#.#...                                                   ;
    !byte %.#...#..                                                   ;
    !byte %......#.                                                   ;
    !byte %.......#                                                   ;
    !byte %#...#.#.                                                   ;
    !byte %....#.#.                                                   ;
    !byte %#..#..#.                                                   ;
    !byte %.###..#.                                                   ;
    !byte %..#.#.#.                                                   ;
    !byte %.#...#..                                                   ;
    !byte %#.......                                                   ;
    !byte %........                                                   ;

; ADE:
starship_sprite_5
    !byte %..#.....                                                   ; ..#.........#...
    !byte %.##....#                                                   ; .##....#....##..
    !byte %.#.#...#                                                   ; .#.#...#...#.#..
    !byte %.#.#..##                                                   ; .#.#..###..#.#..
    !byte %#...#.##                                                   ; #...#.###.#...#.
    !byte %#...#.##                                                   ; #...#.###.#...#.
    !byte %#....###                                                   ; #....#####....#.
    !byte %#..#..##                                                   ; #..#..###..#..#.
    !byte %....#...                                                   ; #.###.###.###.#.
    !byte %....##..                                                   ; .#.#..###..#.#..
    !byte %...#.#..                                                   ; .#....###....#..
    !byte %#..#.#..                                                   ; ..#..#####..#...
    !byte %#.#...#.                                                   ; ...##..#..##....
    !byte %#.#...#.                                                   ; ....##...##.....
    !byte %##....#.                                                   ; ....##...##.....
    !byte %#..#..#.                                                   ; .....#####......
    !byte %#.###.##
    !byte %.#.#..##
    !byte %.#....##
    !byte %..#..###
    !byte %...##..#
    !byte %....##..
    !byte %....##..
    !byte %.....###
    !byte %#.###.#.
    !byte %#..#.#..
    !byte %#....#..
    !byte %##..#...
    !byte %..##....
    !byte %.##.....
    !byte %.##.....
    !byte %##......

starship_sprite_6
    !byte %.......#                                                   ; .......#........
    !byte %.......#                                                   ; .......#........
    !byte %......##                                                   ; ......###.......
    !byte %##....##                                                   ; ##....###....##.
    !byte %##...##.                                                   ; ##...##.##...##.
    !byte %##...##.                                                   ; ##...##.##...##.
    !byte %##..##..                                                   ; ##..##...##..##.
    !byte %##..##.#                                                   ; ##..##.#.##..##.
    !byte %........                                                   ; #####..#..#####.
    !byte %........                                                   ; ##....###....##.
    !byte %#.......                                                   ; ######...######.
    !byte %#....##.                                                   ; ##...##.##...##.
    !byte %##...##.                                                   ; ####..###..####.
    !byte %##...##.                                                   ; ##.##..#..##.##.
    !byte %.##..##.                                                   ; ##..##.#.##..##.
    !byte %.##..##.                                                   ; .....#####......
    !byte %#####..#                                                   ;
    !byte %##....##                                                   ;
    !byte %######..                                                   ;
    !byte %##...##.                                                   ;
    !byte %####..##                                                   ;
    !byte %##.##..#                                                   ;
    !byte %##..##.#                                                   ;
    !byte %.....###                                                   ;
    !byte %..#####.                                                   ;
    !byte %#....##.                                                   ;
    !byte %.######.                                                   ;
    !byte %##...##.                                                   ;
    !byte %#..####.                                                   ;
    !byte %..##.##.                                                   ;
    !byte %.##..##.                                                   ;
    !byte %##......                                                   ;

; TOBY
starship_sprite_7
    !byte %.......#                                                   ; .......#........
    !byte %......#.                                                   ; ......#.#.......
    !byte %......#.                                                   ; ......#.#.......
    !byte %.....#..                                                   ; .....#...#......
    !byte %....#..#                                                   ; ....#..#..#.....
    !byte %..##..#.                                                   ; ..##..#.#..##...
    !byte %.#..#..#                                                   ; .#..#..#..#..#..
    !byte %#....#.#                                                   ; #....#.#.#....#.
    !byte %........                                                   ; #..#..#.#..#..#.
    !byte %#.......                                                   ; #.#.#..#..#.#.#.
    !byte %#.......                                                   ; #..#.#.#.#.#..#.
    !byte %.#......                                                   ; .#....#.#....#..
    !byte %..#.....                                                   ; ..#..#...#..#...
    !byte %#..##...                                                   ; .#.##..#..##.#..
    !byte %..#..#..                                                   ; #....#####....#.
    !byte %.#....#.                                                   ; #.............#.
    !byte %#..#..#.
    !byte %#.#.#..#
    !byte %#..#.#.#
    !byte %.#....#.
    !byte %..#..#..
    !byte %.#.##..#
    !byte %#....###
    !byte %#.......
    !byte %#..#..#.
    !byte %..#.#.#.
    !byte %.#.#..#.
    !byte %#....#..
    !byte %.#..#...
    !byte %..##.#..
    !byte %##....#.
    !byte %......#.

starship_sprite_8
    !byte %........                                                   ; ................
    !byte %......##                                                   ; ......###.......
    !byte %.....#..                                                   ; .....#...#......
    !byte %....#...                                                   ; ....#.....#.....
    !byte %...#...#                                                   ; ...#...#...#....
    !byte %...#..#.                                                   ; ...#..#.#..#....
    !byte %...#...#                                                   ; ...#...#...#....
    !byte %.#..#...                                                   ; .#..#.....#..#..
    !byte %........                                                   ; ###..#...#..###.
    !byte %#.......                                                   ; ###...###...###.
    !byte %.#......                                                   ; ##.#..#.#..#.##.
    !byte %..#.....                                                   ; ##.##.#.#.##.##.
    !byte %...#....                                                   ; ###.###.###.###.
    !byte %#..#....                                                   ; ###..#...#..###.
    !byte %...#....                                                   ; .#....#.#....#..
    !byte %..#..#..                                                   ; .#.....#.....#..
    !byte %###..#..                                                   ;
    !byte %###...##                                                   ;
    !byte %##.#..#.                                                   ;
    !byte %##.##.#.                                                   ;
    !byte %###.###.                                                   ;
    !byte %###..#..                                                   ;
    !byte %.#....#.                                                   ;
    !byte %.#.....#                                                   ;
    !byte %.#..###.                                                   ;
    !byte %#...###.                                                   ;
    !byte %#..#.##.                                                   ;
    !byte %#.##.##.                                                   ;
    !byte %###.###.                                                   ;
    !byte %.#..###.                                                   ;
    !byte %#....#..                                                   ;
    !byte %.....#..                                                   ;

starship_sprite_9
    !byte %......##                                                   ; ......###.......
    !byte %.....##.                                                   ; .....##.##......
    !byte %.#..##..                                                   ; .#..##...##..#..
    !byte %.#...###                                                   ; .#...#####...#..
    !byte %.#....#.                                                   ; .#....#.#....#..
    !byte %###...#.                                                   ; ###...#.#...###.
    !byte %#.#...#.                                                   ; #.#...#.#...#.#.
    !byte %#.#...#.                                                   ; #.#...#.#...#.#.
    !byte %#.......                                                   ; #..#..#.#..#..#.
    !byte %##......                                                   ; #...#.#.#.#...#.
    !byte %.##..#..                                                   ; #....#.#.#....#.
    !byte %##...#..                                                   ; #..#...#...#..#.
    !byte %#....#..                                                   ; #.#.#..#..#.#.#.
    !byte %#...###.                                                   ; .#...#.#.#...#..
    !byte %#...#.#.                                                   ; .#....###....#..
    !byte %#...#.#.                                                   ; .......#........
    !byte %#..#..#.                                                   ;
    !byte %#...#.#.                                                   ;
    !byte %#....#.#                                                   ;
    !byte %#..#...#                                                   ;
    !byte %#.#.#..#                                                   ;
    !byte %.#...#.#                                                   ;
    !byte %.#....##                                                   ;
    !byte %.......#                                                   ;
    !byte %#..#..#.                                                   ;
    !byte %#.#...#.                                                   ;
    !byte %.#....#.                                                   ;
    !byte %...#..#.                                                   ;
    !byte %..#.#.#.                                                   ;
    !byte %.#...#..                                                   ;
    !byte %#....#..                                                   ;
    !byte %........                                                   ;

starship_sprite_10
    !byte %.......#                                                   ; .......#........
    !byte %.......#                                                   ; .......#........
    !byte %.#....##                                                   ; .#....###....#..
    !byte %.#....##                                                   ; .#....###....#..
    !byte %.#...##.                                                   ; .#...##.##...#..
    !byte %###..##.                                                   ; ###..##.##..###.
    !byte %###.##.#                                                   ; ###.##.#.##.###.
    !byte %###.##.#                                                   ; ###.##.#.##.###.
    !byte %........                                                   ; #####..#..#####.
    !byte %........                                                   ; ##.....#.....##.
    !byte %#....#..                                                   ; ######.#.######.
    !byte %#....#..                                                   ; ##....###....##.
    !byte %##...#..                                                   ; #####..#..#####.
    !byte %##..###.                                                   ; ###.##.#.##.###.
    !byte %.##.###.                                                   ; ###..##.##..###.
    !byte %.##.###.                                                   ; .#....###....#..
    !byte %#####..#                                                   ;
    !byte %##.....#                                                   ;
    !byte %######.#                                                   ;
    !byte %##....##                                                   ;
    !byte %#####..#                                                   ;
    !byte %###.##.#                                                   ;
    !byte %###..##.                                                   ;
    !byte %.#....##                                                   ;
    !byte %..#####.                                                   ;
    !byte %.....##.                                                   ;
    !byte %.######.                                                   ;
    !byte %#....##.                                                   ;
    !byte %..#####.                                                   ;
    !byte %.##.###.                                                   ;
    !byte %##..###.                                                   ;
    !byte %#....#..                                                   ;

starship_sprite_11
    !byte %.....###                                                   ;.....#####......
    !byte %....##..                                                   ;....##...##.....
    !byte %...##..#                                                   ;...##..#..##....
    !byte %...##.##                                                   ;...##.###.##....
    !byte %...##.##                                                   ;...##.###.##....
    !byte %...##..#                                                   ;...##..#..##....
    !byte %....##..                                                   ;....##...##.....
    !byte %##...###                                                   ;##...#####...##.
    !byte %##......                                                   ;##.....#.....##.
    !byte %.##.....                                                   ;###...###...###.
    !byte %..##....                                                   ;####..###..####.
    !byte %#.##....                                                   ;##.##.###.##.##.
    !byte %#.##....                                                   ;##..#######..##.
    !byte %..##....                                                   ;##....###....##.
    !byte %.##.....                                                   ;##....###....##.
    !byte %##...##.                                                   ;##.....#.....##.
    !byte %##.....#                                                   ;
    !byte %###...##                                                   ;
    !byte %####..##                                                   ;
    !byte %##.##.##                                                   ;
    !byte %##..####                                                   ;
    !byte %##....##                                                   ;
    !byte %##....##                                                   ;
    !byte %##.....#                                                   ;
    !byte %.....##.                                                   ;
    !byte %#...###.                                                   ;
    !byte %#..####.                                                   ;
    !byte %#.##.##.                                                   ;
    !byte %###..##.                                                   ;
    !byte %#....##.                                                   ;
    !byte %#....##.                                                   ;
    !byte %.....##.                                                   ;


; ----------------------------------------------------------------------------------
scores_for_destroying_enemy_ships
    ; BCD scores
    !byte $08   ; first ship type, starship torpedo                   ; how_enemy_ship_was_damaged = 0
    !byte $12   ; second ship type / cloaked ship, starship torpedo
    !byte $03   ; first ship type, enemy torpedo                      ; how_enemy_ship_was_damaged = 1
    !byte $04   ; second ship type / cloaked ship, enemy torpedo
    !byte $70   ; first ship type, escape capsule                     ; how_enemy_ship_was_damaged = 2
    !byte $90   ; second ship type / cloaked ship, escape capsule
    !byte $03   ; first ship type, collision with other enemy ship    ; how_enemy_ship_was_damaged = -1
    !byte $04   ; second ship type / cloaked ship, collision with other enemy ship
    !byte $02   ; first ship type, collision with starship            ; how_enemy_ship_was_damaged = -1
    !byte $03   ; second ship type / cloaked ship, collision with starship

; ----------------------------------------------------------------------------------
; add to score (in binary coded decimal)
; ----------------------------------------------------------------------------------
apply_delta_to_score
    lda score_delta_low                                               ;
    clc                                                               ;
    sei                                                               ;
    sed                                                               ; BCD on
    adc score_as_bcd                                                  ;
    sta score_as_bcd                                                  ;
    lda score_as_bcd + 1                                              ;
    adc score_delta_high                                              ;
    sta score_as_bcd + 1                                              ;
    lda score_as_bcd + 2                                              ;
    adc #0                                                            ;
    sta score_as_bcd + 2                                              ;
    cld                                                               ; BCD off
    cli                                                               ;

    lda #0                                                            ;
    cmp score_delta_low                                               ;
    bne set_score_delta_to_zero                                       ;
    cmp score_delta_high                                              ;
    beq return32                                                      ; no need to update score if delta is zero
set_score_delta_to_zero
    sta score_delta_low                                               ;
    sta score_delta_high                                              ;

    ; calculate the characters to display the score, then display them
plot_score
    ldx #33                                                           ;
    ldy #30                                                           ;
    jsr tab_to_x_y                                                    ;
print_score
    lda score_as_bcd + 2                                              ;
    jsr plot_two_bcd_digits_with_leading_spaces                       ;
print_score2
    lda score_as_bcd + 1                                              ;
    jsr plot_two_bcd_digits                                           ;
    lda score_as_bcd                                                  ;
    jmp plot_two_bcd_digits                                           ;

; ----------------------------------------------------------------------------------
plot_scanner_grid
    lda #0                                                            ;
    sta y_pixels                                                      ;
    sta temp_x                                                        ;
    lda #64
    sta temp_y                                                        ;

--
    lda temp_y                                                        ;
    clc                                                               ;
    adc #10                                                           ;
    sta next_y                                                        ;
    tay                                                               ;
    ldx temp_x                                                        ;
    stx x_pixels                                                      ;
    lda #9                                                            ;
-
    jsr plot_horizontal_line_xy                                       ;
    ldy temp_y                                                        ;
    iny
    lda #9                                                            ;
    jsr plot_vertical_line_xy                                         ;
    lda #10                                                           ;
    ldy y_pixels                                                      ;
    cpx #$31                                                          ;
    bcc -                                                             ;

    ; draw corner pixel
    stx x_pixels                                                      ;
    jsr set_pixel                                                     ;

next_y = * + 1
    lda #0
    sta temp_y                                                        ;
    cmp #64 + 50
    bcc --

    lda #0
    sta output_pixels                                                 ;
    sta output_fraction                                               ;

return32
    rts                                                               ;

; ----------------------------------------------------------------------------------
;         vertical lines    ,   horizontal lines
x_lines
    !byte $35, $3b, $30, $05,   $00, $05, $05, $00
y_lines
    !byte $41, $41, $77, $78,   $e7, $77, $7e, $83
lengths
    !byte $42, $42, $07, $06,   $3f, $2b, $2c, $3f

; ----------------------------------------------------------------------------------
plot_gauge_edges
    ldy #8                                                            ;
    sty temp_x                                                        ;
plot_gauge_edges_loop
    dec temp_x                                                        ;
    bmi return32                                                      ;
    ldy temp_x                                                        ;
    ldx x_lines,y                                                     ;
    lda y_lines,y                                                     ;
    sta temp_y                                                        ;
    lda lengths,y                                                     ;

    cpy #4                                                            ;
    bcc plot_gauge_v                                                  ;

plot_gauge_h
    ldy temp_y                                                        ;
    jsr plot_horizontal_line_xy                                       ;
    jmp plot_gauge_edges_loop                                         ;

plot_gauge_v
    ldy temp_y                                                        ;
    jsr plot_vertical_line_xy                                         ;
    jmp plot_gauge_edges_loop                                         ;

; ----------------------------------------------------------------------------------
plot_starship_velocity_and_rotation_on_gauges

    ; velocity gauge
    lda starship_velocity_low                                         ;
    sta y_pixels                                                      ;
    lda starship_velocity_high                                        ;
    asl y_pixels                                                      ;
    rol                                                               ;
    asl y_pixels                                                      ;
    rol                                                               ;
    asl y_pixels                                                      ;
    rol                                                               ;
    asl y_pixels                                                      ;
    rol                                                               ; x16
    cmp velocity_gauge_position                                       ;
    beq skip_velocity_gauge                                           ;
    tay                                                               ;
    lda #$81                                                          ;
    sec                                                               ;
    sbc velocity_gauge_position                                       ;
    sta y_pixels                                                      ;
    sty velocity_gauge_position                                       ;
    lda #$36                                                          ;
    sta x_pixels                                                      ;
    lda #5                                                            ;
    sta temp7                                                         ;
    sta temp11                                                        ;
plot_velocity_gauge_unset_loop
    jsr unset_pixel                                                   ;
    inc y_pixels                                                      ;
    jsr unset_pixel                                                   ;
    dec y_pixels                                                      ;
    inc x_pixels                                                      ;
    dec temp7                                                         ;
    bne plot_velocity_gauge_unset_loop                                ;
    lda #$81                                                          ;
    sec                                                               ;
    sbc velocity_gauge_position                                       ;
    sta y_pixels                                                      ;
plot_velocity_gauge_set_loop
    dec x_pixels                                                      ;
    jsr set_pixel                                                     ;
    inc y_pixels                                                      ;
    jsr set_pixel                                                     ;
    dec y_pixels                                                      ;
    dec temp11                                                        ;
    bne plot_velocity_gauge_set_loop                                  ;
skip_velocity_gauge

    ; rotation gauge
    lda starship_rotation_fraction                                    ;
    sta y_pixels                                                      ;
    lda starship_rotation                                             ;
    sec                                                               ;
    sbc #$7b                                                          ;
    asl y_pixels                                                      ;
    rol                                                               ;
    asl y_pixels                                                      ;
    rol                                                               ;
    cmp rotation_gauge_position                                       ;
    beq skip_rotation_gauge                                           ;
    tay                                                               ;
    lda rotation_gauge_position                                       ;
    sty rotation_gauge_position                                       ;
    cmp #$15                                                          ;
    bcc set_rotation_gauge_position_for_unset                         ; rotating anticlockwise
    sbc #3                                                            ;
    cmp #$14                                                          ;
    bcs set_rotation_gauge_position_for_unset                         ; rotating clockwise
    lda #$14                                                          ;
set_rotation_gauge_position_for_unset
    clc                                                               ;
    adc #6                                                            ;
    sta x_pixels                                                      ;
    lda #$78                                                          ;
    sta y_pixels                                                      ;
    lda #6                                                            ;
    sta temp7                                                         ;
    sta temp11                                                        ;
plot_rotation_gauge_unset_loop
    jsr unset_pixel                                                   ;
    inc x_pixels                                                      ;
    jsr unset_pixel                                                   ;
    dec x_pixels                                                      ;
    inc y_pixels                                                      ;
    dec temp7                                                         ;
    bne plot_rotation_gauge_unset_loop                                ;
    lda rotation_gauge_position                                       ;
    cmp #$15                                                          ;
    bcc set_rotation_gauge_position_for_set                           ;
    sbc #3                                                            ;
    cmp #$14                                                          ;
    bcs set_rotation_gauge_position_for_set                           ;
    lda #$14                                                          ;
set_rotation_gauge_position_for_set
    clc                                                               ;
    adc #6                                                            ;
    sta x_pixels                                                      ;
plot_rotation_gauge_set_loop
    dec y_pixels                                                      ;
    jsr set_pixel                                                     ;
    inc x_pixels                                                      ;
    jsr set_pixel                                                     ;
    dec x_pixels                                                      ;
    dec temp11                                                        ;
    bne plot_rotation_gauge_set_loop                                  ;
skip_rotation_gauge
return33
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_or_unplot_enemy_on_scanner
    sta set_pixel_flag                                                ;
    lda x_pixels                                                      ;
    clc                                                               ;
    adc #$a0                                                          ;
    sta x_pixels                                                      ;
    jsr set_or_unset_pixel                                            ; set single pixel on
                                                                      ; long range scanner

    ; check if on short range scanner
    lda x_pixels                                                      ;
    sec                                                               ;
    sbc #$1d                                                          ;
    bcc return33                                                      ;
    cmp #5                                                            ;
    bcs return33                                                      ;
    tay                                                               ; remember x_pixels

    lda y_pixels                                                      ;
    sec                                                               ;
    sbc #$1e                                                          ;
    bcc return33                                                      ;
    cmp #5                                                            ;
    bcs return33                                                      ;

    ; scale up y coordinate
    asl                                                               ;
    sta y_pixels                                                      ;
    asl                                                               ;
    asl                                                               ;
    adc y_pixels                                                      ;
    sta y_pixels                                                      ; y_pixels *= 10

    ldx temp8                                                         ;
    lda enemy_ships_y_pixels,x                                        ;
    bit set_pixel_flag                                                ;
    bmi +                                                             ;
    lda enemy_ships_previous_y_pixels,x                               ;
+
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc y_pixels                                                      ;
    adc #$41                                                          ;
    sta y_pixels                                                      ;

    tya                                                               ; recall x_pixels

    ; scale up x coordinate
    asl                                                               ;
    sta x_pixels                                                      ;
    asl                                                               ;
    asl                                                               ;
    adc x_pixels                                                      ;
    sta x_pixels                                                      ; x_pixels *= 10

    lda enemy_ships_x_pixels,x                                        ;
    bit set_pixel_flag                                                ;
    bmi +                                                             ;
    lda enemy_ships_previous_x_pixels,x                               ;
+
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc x_pixels                                                      ;
    sta x_pixels                                                      ;

    jsr set_or_unset_pixel                                            ;
    inc x_pixels                                                      ;
    jsr set_or_unset_pixel                                            ;
    inc y_pixels                                                      ;
    jsr set_or_unset_pixel                                            ;
    dec x_pixels                                                      ;
    jmp set_or_unset_pixel                                            ;

; ----------------------------------------------------------------------------------
plot_enemy_ships_on_scanners
    lda #maximum_number_of_enemy_ships                                ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
plot_enemy_ships_on_scanners_loop
    stx temp8                                                         ;
    lda enemy_ships_previous_x_screens,x                              ;
    cmp #$60                                                          ;
    bcc skip_unplotting_enemy_ship_on_scanner                         ;
    cmp #$9f                                                          ;
    bcs skip_unplotting_enemy_ship_on_scanner                         ;
    sta x_pixels                                                      ;

    lda enemy_ships_previous_y_screens,x                              ;
    cmp #$60                                                          ;
    bcc skip_unplotting_enemy_ship_on_scanner                         ;
    cmp #$9f                                                          ;
    bcs skip_unplotting_enemy_ship_on_scanner                         ;
    adc #$a1                                                          ;
    sta y_pixels                                                      ;

    lda #0                                                            ; unplot
    jsr plot_or_unplot_enemy_on_scanner                               ;
skip_unplotting_enemy_ship_on_scanner
    lda starship_shields_active                                       ;
    beq to_skip_plotting_enemy_ship_on_scanner                        ;
    ldx temp8                                                         ;
    lda enemy_ships_energy,x                                          ;
    bne continue2                                                     ;
to_skip_plotting_enemy_ship_on_scanner
    jmp skip_plotting_enemy_ship_on_scanner                           ;

continue2
    lda enemy_ships_x_screens,x                                       ;
    cmp #$60                                                          ;
    bcc skip_plotting_enemy_ship_on_scanner                           ;
    cmp #$9f                                                          ;
    bcs skip_plotting_enemy_ship_on_scanner                           ;
    sta x_pixels                                                      ;

    lda enemy_ships_y_screens,x                                       ;
    cmp #$60                                                          ;
    bcc skip_plotting_enemy_ship_on_scanner                           ;
    cmp #$9f                                                          ;
    bcs skip_plotting_enemy_ship_on_scanner                           ;
    adc #$a1                                                          ;
    sta y_pixels                                                      ;

    lda #$ff                                                          ; plot
    jsr plot_or_unplot_enemy_on_scanner                               ;
skip_plotting_enemy_ship_on_scanner
    ldx temp8                                                         ;
    inx                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    beq continue3                                                     ;
    jmp plot_enemy_ships_on_scanners_loop                             ;

continue3
    ldy #$1f                                                          ;
    sty x_pixels                                                      ;
    iny                                                               ;
    sty y_pixels                                                      ;
    jmp set_pixel                                                     ; plot pixel in middle of long range scanner

; ----------------------------------------------------------------------------------
handle_scanner_failure
    lda damage_low                                                    ;
    cmp #$3c                                                          ;
    bcs starship_incurred_major_damage                                ;
    lda damage_high                                                   ;
    beq starship_didnt_incur_major_damage                             ;
starship_incurred_major_damage
    lda scanner_failure_duration                                      ;
    bne handle_failed_scanner                                         ;
    jsr random_number_generator                                       ;
    and #$6c                                                          ;
    bne return25                                                      ;

turn_scanner_to_static
    lda starship_shields_active                                       ;
    sta starship_shields_active_before_failure                        ;
    beq skip_unplotting_scanners                                      ;
    lda #0                                                            ;
    sta starship_shields_active                                       ;
    jsr plot_enemy_ships_on_scanners                                  ;
skip_unplotting_scanners
    inc starship_shields_active                                       ;
    lda rnd_1                                                         ;
    ora #$42                                                          ;
    sta scanner_failure_duration                                      ;
return25
    rts

; ----------------------------------------------------------------------------------
starship_didnt_incur_major_damage
    lda scanner_failure_duration                                      ;
    beq return25                                                      ;
handle_failed_scanner
    dec scanner_failure_duration                                      ;
    bne return25

; ----------------------------------------------------------------------------------
clear_long_range_scanner
    lda #0                                                            ;
    sta temp0_low                                                     ;
    lda #$59                                                          ;
    sta temp0_high                                                    ;
    ldx #8                                                            ;
clear_long_range_scanner_row_loop
    ldy #$3f                                                          ;
    lda #0                                                            ;
clear_long_range_scanner_column_loop
    sta (temp0_low),y                                                 ;
    dey                                                               ;
    bpl clear_long_range_scanner_column_loop                          ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #$40                                                          ;
    sta temp0_low                                                     ;
    lda temp0_high                                                    ;
    adc #1                                                            ;
    sta temp0_high                                                    ;
    dex                                                               ;
    bne clear_long_range_scanner_row_loop                             ;
    lda #0                                                            ;
    sta starship_shields_active                                       ;
    jsr plot_top_and_right_edge_of_long_range_scanner_with_blank_text ;
    lda starship_shields_active_before_failure                        ;
    bne return25                                                      ;
    jmp unplot_long_range_scanner_if_shields_inactive                 ;

; ----------------------------------------------------------------------------------
; timid ship, retreats upwards as soon as on screen
; On Entry:
;   X is the index of the enemy ship in question
; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine0
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    and #$10                                                          ;
    bne skip_setting_enemy_ship_was_on_screen_above                   ;
    lda enemy_ships_x_screens,x                                       ;
    cmp #$7f                                                          ;
    bne not_on_screen_above                                           ;
    lda enemy_ships_y_screens,x                                       ;
    cmp #$7e                                                          ; is the enemy ship on the screen above the starship?
    bne not_on_screen_above                                           ;
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    ora #$10                                                          ; if so, set enemy_ship_was_on_screen_above
    sta enemy_ships_temporary_behaviour_flags,x                       ;
skip_setting_enemy_ship_was_on_screen_above
    lda #4                                                            ;
    sta enemy_ship_desired_velocity                                   ; move slowly on screen above starship
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;

    lda enemy_ships_on_screen,x                                       ;
    bne not_on_screen1                                                ; If it appears on main screen pointing at starship,
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne to_return_from_enemy_ship_behaviour_routine                   ;
    jsr fire_enemy_torpedo                                            ; then fire; otherwise leave
    jmp return_from_enemy_ship_behaviour_routine                      ;

not_on_screen1
    jsr turn_enemy_ship_towards_starship_using_screens                ;
    lda temp9                                                         ;
    cmp #$80                                                          ; is the enemy ship on a screen below the starship?
    bcc to_return_from_enemy_ship_behaviour_routine                   ;
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    and #$ef                                                          ; if so, unset enemy_ship_was_on_screen_above
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

not_on_screen_above
    lda enemy_ships_x_screens,x                                       ;
    sta temp10                                                        ;
    lda enemy_ships_y_screens,x                                       ;
    clc                                                               ;
    adc #1                                                            ;
    sta temp9                                                         ;
    jsr turn_enemy_ship_towards_starship                              ; aim at centre of screen above starship
    lda enemy_ship_desired_velocity                                   ;
    clc                                                               ;
    adc #$0a                                                          ; boost speed
    sta enemy_ship_desired_velocity                                   ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
to_return_from_enemy_ship_behaviour_routine
    jmp return_from_enemy_ship_behaviour_routine                      ;

; ----------------------------------------------------------------------------------
; Comes to a stop near edge of screen when starship is stationary, follows closer when starship is moving
; On Entry:
;   X is the index of the enemy ship in question
; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine1
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen                                                    ;
    jsr get_rectilinear_distance_from_centre_of_screen_accounting_for_starship_velocity ;
    cmp #$40                                                          ;
    bcc to_set_retreating_and_head_towards_desired_velocity_and_angle ;
    lda starship_velocity_low                                         ;
    sta x_pixels                                                      ;
    lda starship_velocity_high                                        ;
    asl x_pixels                                                      ;
    rol                                                               ;
    sta y_pixels                                                      ;
    asl x_pixels                                                      ;
    rol                                                               ;
    adc y_pixels                                                      ;
    cmp enemy_ship_desired_velocity                                   ; limit velocity to starship_velocity_high * 6
    bcs skip_setting_desired_velocity                                 ;
    sta enemy_ship_desired_velocity                                   ;
skip_setting_desired_velocity
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne return_after_changing_velocity                                ;
    jsr fire_enemy_torpedo                                            ; fire if pointing at starship
    jmp return_after_changing_velocity                                ;

to_set_retreating_and_head_towards_desired_velocity_and_angle
    jmp set_retreating_and_head_towards_desired_velocity_and_angle    ;

off_screen
    jsr turn_enemy_ship_towards_starship_using_screens                ;
return_after_changing_velocity
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

; ----------------------------------------------------------------------------------
; Approaches starship, stops or retreats
; On Entry:
;   X is the index of the enemy ship in question
; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine2
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen1                                                   ;
    jsr get_rectilinear_distance_from_centre_of_screen                ;
    cmp #$46                                                          ; retreat if too close
    bcc to_set_retreating_and_head_towards_desired_velocity_and_angle1 ;
    cmp #$6e                                                          ;
    bcs return_after_turning_enemy_ship_towards_desired_angle         ;
    jsr decrease_enemy_ship_velocity                                  ; slow down when within range
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne to_return_from_enemy_ship_behaviour_routine1                  ;
    jsr fire_enemy_torpedo                                            ; fire if pointing at starship
    jmp to_return_from_enemy_ship_behaviour_routine1                  ;

to_set_retreating_and_head_towards_desired_velocity_and_angle1
    jmp set_retreating_and_head_towards_desired_velocity_and_angle    ;

return_after_turning_enemy_ship_towards_desired_angle
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    jmp return_after_changing_velocity1                               ;

off_screen1
    jsr turn_enemy_ship_towards_starship_using_screens                ;
return_after_changing_velocity1
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
to_return_from_enemy_ship_behaviour_routine1
    jmp return_from_enemy_ship_behaviour_routine                      ;

; ----------------------------------------------------------------------------------
; Approaches close, then stops
; On Entry:
;   X is the index of the enemy ship in question
; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine3
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen2                                                   ;
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne skip_firing                                                   ;
    jsr fire_enemy_torpedo                                            ; fire if pointing at starship
skip_firing
    jsr get_rectilinear_distance_from_centre_of_screen                ;
    cmp #$78                                                          ;
    bcs to_return_from_enemy_ship_behaviour_routine2                  ;
    jsr decrease_enemy_ship_velocity                                  ; slow down when close
    jmp return_from_enemy_ship_behaviour_routine                      ;

off_screen2
    jsr turn_enemy_ship_towards_starship_using_screens                ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
to_return_from_enemy_ship_behaviour_routine2
    jmp return_from_enemy_ship_behaviour_routine                      ;

; ----------------------------------------------------------------------------------
; Approaches very close, then stops
; On Entry:
;   X is the index of the enemy ship in question
; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine4
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen3                                                   ;
    jsr get_rectilinear_distance_from_centre_of_screen                ;
    cmp #$64                                                          ;
    bcc decelerate                                                    ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    jmp skip_deceleration                                             ;

decelerate
    jsr decrease_enemy_ship_velocity                                  ; slow down when close
skip_deceleration
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne return_after_changing_velocity2                               ;
    jsr fire_enemy_torpedo                                            ; fire if pointing at starship
    jmp return_from_enemy_ship_behaviour_routine                      ;

off_screen3
    jsr turn_enemy_ship_towards_starship_using_screens                ;
return_after_changing_velocity2
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

; ----------------------------------------------------------------------------------
; Approaches very close, then retreats
; On Entry:
;   X is the index of the enemy ship in question
; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine5
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen4                                                   ;
    jsr get_rectilinear_distance_from_centre_of_screen                ;
    cmp #$50                                                          ; retreat if close
    bcc to_set_retreating_and_head_towards_desired_velocity_and_angle2 ;
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne return_after_changing_velocity3                               ;
    jsr fire_enemy_torpedo                                            ; fire if pointing at starship
    jmp return_after_changing_velocity3                               ;

to_set_retreating_and_head_towards_desired_velocity_and_angle2
    jmp set_retreating_and_head_towards_desired_velocity_and_angle    ;

off_screen4
    jsr turn_enemy_ship_towards_starship_using_screens                ;
return_after_changing_velocity3
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

set_retreating_and_head_towards_desired_velocity_and_angle
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    ora #$80                                                          ;
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    jsr turn_enemy_ship_towards_desired_angle                         ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

; ----------------------------------------------------------------------------------
maximum_enemy_torpedo_cooldown_per_command
    ; cmd  1,  2,  3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13+
    !byte 15, 13, 11, 9, 8, 7, 6, 5, 4,  4,  3,  3,  2
num_cooldown_values = * - maximum_enemy_torpedo_cooldown_per_command

command_number_used_for_maximum_enemy_torpedo_cooldown_lookup
    !byte 0                                                           ;

probability_of_new_enemy_ship_being_defensive_about_damage
    !byte 0                                                           ;
probability_of_new_enemy_ship_being_defensive_about_angle
    !byte 0                                                           ;
probability_of_new_enemy_ship_firing_torpedo_clusters
    !byte 0                                                           ;
probability_of_new_enemy_ship_being_second_type
    !byte 0                                                           ;

initial_enemy_ship_spawning_probabilities
    !byte $c0                                                         ; probability_of_new_enemy_ship_being_defensive_about_damage
    !byte $82                                                         ; probability_of_new_enemy_ship_being_defensive_about_angle
    !byte 4                                                           ; probability_of_new_enemy_ship_firing_torpedo_clusters
    !byte 2                                                           ; probability_of_new_enemy_ship_being_second_type
change_in_enemy_ship_spawning_probabilities_per_command
    !byte $ec                                                         ; probability_of_new_enemy_ship_being_defensive_about_damage
    !byte $f2                                                         ; probability_of_new_enemy_ship_being_defensive_about_angle
    !byte $0f                                                         ; probability_of_new_enemy_ship_firing_torpedo_clusters
    !byte $17                                                         ; probability_of_new_enemy_ship_being_second_type
ultimate_enemy_ship_probabilities
    !byte $20                                                         ; probability_of_new_enemy_ship_being_defensive_about_damage
    !byte 4                                                           ; probability_of_new_enemy_ship_being_defensive_about_angle
    !byte $b8                                                         ; probability_of_new_enemy_ship_firing_torpedo_clusters
    !byte $ff                                                         ; probability_of_new_enemy_ship_being_second_type

; ----------------------------------------------------------------------------------
initialise_enemy_ship
    lda #$ff                                                          ;
    sta enemy_ships_energy,x                                          ; full energy
    ldy enemy_ships_still_to_consider                                 ;
    lda #0                                                            ;
    sta enemy_ships_explosion_number - 1,y                            ;
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    jsr random_number_generator                                       ;
    and #$0f                                                          ; pick random behaviour type for enemy ship
    sta enemy_ships_flags_or_explosion_timer,x                        ;
    ldy #$5f                                                          ;
    lda rnd_2                                                         ;
    bpl skip29                                                        ;
    ldy #$9f                                                          ; y_screens is randomly either &5f or &9f
skip29
    sty x_pixels                                                      ;
    lda rnd_1                                                         ;
    and #$1f                                                          ;
    clc                                                               ;
    adc #$70                                                          ;
    tay                                                               ; x_screens is randomly chosen between &70 - &8f
    lda rnd_2                                                         ;
    asl                                                               ;
    bpl skip_swap1                                                    ; 50% chance of swapping x_screens and y_screens
    tya                                                               ;
    ldy x_pixels                                                      ;
    sta x_pixels                                                      ;
skip_swap1
    tya                                                               ;
    sta enemy_ships_x_screens,x                                       ;
    sta temp10                                                        ;
    lda x_pixels                                                      ;
    sta enemy_ships_y_screens,x                                       ;
    jsr calculate_enemy_ship_angle_to_starship_ycoord_in_a            ;
    eor #$10                                                          ; initially pointing away from starship
    asl                                                               ;
    asl                                                               ;
    asl                                                               ;
    sta enemy_ships_angle,x                                           ;
    jsr random_number_generator                                       ; properties depending on command probabilities
    lda probability_of_new_enemy_ship_being_defensive_about_damage    ;
    cmp rnd_2                                                         ;
    bcc not_defensive_about_damage                                    ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    ora #$40                                                          ;
    sta enemy_ships_flags_or_explosion_timer,x                        ;
not_defensive_about_damage
    lda probability_of_new_enemy_ship_being_defensive_about_angle     ;
    cmp rnd_1                                                         ;
    bcc defensive_about_angle                                         ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    ora #$20                                                          ;
    sta enemy_ships_flags_or_explosion_timer,x                        ;
defensive_about_angle
    jsr random_number_generator                                       ;
    lda probability_of_new_enemy_ship_firing_torpedo_clusters         ;
    cmp rnd_1                                                         ;
    bcc clusters_unset                                                ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    ora #$10                                                          ;
    sta enemy_ships_flags_or_explosion_timer,x                        ;
clusters_unset
    ldy #0                                                            ;
    lda probability_of_new_enemy_ship_being_second_type               ;
    cmp rnd_2                                                         ;
    bcc small_ship                                                    ;
    iny                                                               ;
small_ship
    tya                                                               ;
    sta enemy_ships_type,x                                            ;
    jsr random_number_generator                                       ; maximum torpedo cooldown depends on command number
    ldy command_number_used_for_maximum_enemy_torpedo_cooldown_lookup ;
    cpy #num_cooldown_values                                          ;
    bcc skip_ceiling2                                                 ;
    ldy #num_cooldown_values - 1                                      ;
skip_ceiling2
    lda maximum_enemy_torpedo_cooldown_per_command,y                  ;
    sta x_pixels                                                      ; store value

    ; calculate a random value between 1 and x_pixels (aka 'max').
    ;
    ; this is done by essentially multiplying max by rnd_2,
    ; and taking the high byte of the result.
    ; But with optimisations that end up with the result in
    ; the top nybble.
    ldy #4                                                            ; loop counter
    lda #0                                                            ;
calculate_cooldown_loop
    lsr x_pixels                                                      ; examine bit by bit
    bcc skip_addition                                                 ;
    clc                                                               ;
    adc rnd_2                                                         ;
skip_addition
    ror                                                               ;
    dey                                                               ;
    bne calculate_cooldown_loop                                       ;

    ; use the top four bits
    clc                                                               ;
    adc #$10                                                          ; not range 0-(max-1) but range 1-max
    and #$f0                                                          ; in top nybble
    sta enemy_ships_firing_cooldown,x                                 ;
    lda #1                                                            ;
    sta enemy_ships_on_screen,x                                       ;
    lda #$ff                                                          ;
    sta enemy_ships_velocity,x                                        ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
starship_type
    !byte 0                                                           ;
command_number
    !byte 0                                                           ;
timer_for_enemy_ships_regeneration
    !byte 0                                                           ;
maximum_timer_for_starship_energy_regeneration
    !byte 3                                                           ;
timer_for_starship_energy_regeneration
    !byte 3                                                           ;
subtraction_from_starship_regeneration_when_shields_active
    !byte 4                                                           ;

; ----------------------------------------------------------------------------------
initial_enemy_speed_per_command
    !byte enemy_full_speed/2, 3*enemy_full_speed/4, enemy_full_speed

; ----------------------------------------------------------------------------------
prepare_starship_for_next_command
    ldx starship_type                                                 ;
    inx                                                               ;
    cpx #num_starships                                                ;
    bcc +                                                             ;
    ldx #0                                                            ;
+
    stx starship_type                                                 ;

    ; Enemy designs range from 0-5. There are two designs per command
    ; the pairs: (0,1) (2,3) (4,5) the first type and the
    ; second type.

    ; We increment the enemy number to be the next first ship type design.
    ; Up to this point it has been pointing at the second ship type design
    ; from the previous round. The call to fill_enemy_cache below
    ; will increment it again to be the second ship type again for
    ; the duration of this command.
    inc enemy_number                                                  ;
    ldx enemy_number                                                  ;
    cpx #6                                                            ;
    bcc +                                                             ;
    ldx #0                                                            ;
+
    stx enemy_number                                                  ;

    inc command_number_used_for_maximum_enemy_torpedo_cooldown_lookup ;

    ; increment command number (in BCD)
    lda command_number                                                ;
    clc                                                               ;
    sei                                                               ;
    sed                                                               ; BCD on
    adc #1                                                            ;
    cld                                                               ; BCD off
    cli                                                               ;
    sta command_number                                                ;
    tax

    ; set velocity of enemy ships, based on command number
    lda #enemy_full_speed                                             ; full speed
    cpx #3                                                            ;
    bcs +                                                             ;
    lda initial_enemy_speed_per_command - 1,x                         ; lower speeds for lower commands
+
    sta desired_velocity_for_intact_enemy_ships                       ;

    lda #0                                                            ;
    sta starship_has_exploded                                         ;
    sta escape_capsule_launched                                       ;
    sta escape_capsule_destroyed                                      ;
    sta score_delta_high                                              ;
    sta score_delta_low                                               ;
    sta damage_high                                                   ;
    sta damage_low                                                    ;
    sta velocity_damper                                               ;
    sta velocity_gauge_position                                       ;
    sta rotation_gauge_position                                       ;
    sta starship_velocity_low                                         ;
    sta starship_rotation_magnitude                                   ;
    sta starship_rotation_cosine                                      ;
    sta starship_rotation_sine_magnitude                              ;
    sta starship_angle_delta                                          ;
    sta previous_starship_automatic_shields                           ;
    sta sound_needed_for_low_energy                                   ;
    sta energy_flash_timer                                            ;
    sta enableKeyboardInterruptProcessingFlag                         ; disable keyboard interrupt
    lda #4                                                            ;
    sta starship_velocity_high                                        ;
    lda #0                                                            ;
    sta scanner_failure_duration                                      ;
    sta starship_shields_active_before_failure                        ;
    lda #$80                                                          ;
    sta starship_angle_fraction                                       ;
    sta starship_rotation                                             ;
    sta starship_rotation_fraction                                    ;
    sta starship_automatic_shields                                    ;
    lda #$0c                                                          ;
    sta starship_energy_high                                          ;
    lda #$7f                                                          ;
    sta starship_energy_low                                           ;
    lda #$c7
    sta starship_energy_divided_by_sixteen                            ;

    jsr init_self_modifying_bytes_for_starship_rotation               ;

    ; fill enemy ship cache
    jsr fill_enemy_cache                                              ;
    jsr zero_objects                                                  ;
    jsr initialise_stars_at_random_positions                          ;
    jsr initialise_enemy_ships                                        ;
    jsr initialise_game_screen                                        ;
    jmp plot_enemy_ships                                              ;

; ----------------------------------------------------------------------------------
plot_command_number
    ldy #$d4                                                          ;
    ldx #0                                                            ;
    lda #$3f                                                          ;
    jsr plot_horizontal_line_xy                                       ;

    ldx #regular_string_index_command                                 ;
    jsr print_regular_string                                          ;

    ldy #$73                                                          ; normal position for command number (single digit)
    lda command_number                                                ; print digits
    pha
    and #$f0
    beq single_digit_command_number_for_move                          ;
    ldy #$63                                                          ; adjusted position for command number (two digits)
single_digit_command_number_for_move
    sty command_move_string_horizontal_pos                            ; set horizontal position of text

    ldx #regular_string_index_command_move                            ;
    jsr print_regular_string                                          ;
    pla                                                               ;
    jsr plot_two_bcd_digits_with_no_spaces
    lda #4                                                            ;
    jmp oswrch                                                        ;

; ----------------------------------------------------------------------------------
initialise_enemy_ships
    lda #maximum_number_of_enemy_ships                                ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
initialise_enemy_ships_loop
    jsr initialise_enemy_ship                                         ;
    lda #1                                                            ;
    sta enemy_ships_previous_on_screen,x                              ;
    inx                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    bne initialise_enemy_ships_loop                                   ;
    rts                                                               ;

initialise_joystick
    ldx keyboard_or_joystick                                          ; enable 2 ADC channels
    lda #osbyte_select_adc_channels                                   ; only if we need them
    jmp (bytev)                                                       ; for joystick

; ----------------------------------------------------------------------------------
update_enemy_ships
    dec timer_for_enemy_ships_regeneration                            ;
    bpl skip_timer_reset                                              ;
    lda #maximum_timer_for_enemy_ships_regeneration                   ;
    sta timer_for_enemy_ships_regeneration                            ;
skip_timer_reset
    lda #maximum_number_of_enemy_torpedoes                            ;
    sta torpedoes_still_to_consider                                   ;

    lda #maximum_number_of_enemy_ships                                ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
update_enemy_ships_loop
    lda enemy_ships_energy,x                                          ;
    beq to_skip_changing_behaviour_type                               ;
    ldy starship_has_exploded                                         ;
    beq starship_still_viable                                         ;
    jsr decrease_enemy_ship_velocity                                  ;
to_skip_changing_behaviour_type
    jmp skip_changing_behaviour_type                                  ;

starship_still_viable
    cmp #$ff                                                          ;
    bne enemy_ship_is_damaged                                         ;
    lda desired_velocity_for_intact_enemy_ships                       ;
    bne set_velocity                                                  ;
enemy_ship_is_damaged
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc #partial_velocity_for_damaged_enemy_ships                     ;
set_velocity
    sta enemy_ship_desired_velocity                                   ;
    lda enemy_ships_firing_cooldown,x                                 ;
    and #$0f                                                          ;
    beq cooldown_is_zero                                              ;
    dec enemy_ships_firing_cooldown,x                                 ;
cooldown_is_zero
    lda timer_for_enemy_ships_regeneration                            ;
    bne skip_enemy_regeneration                                       ;
    lda enemy_ships_type,x                                            ;
    cmp #4                                                            ; no regeneration if enemy ship cloaked
    bcs skip_enemy_regeneration                                       ;
    lda enemy_ships_energy,x                                          ;
    clc                                                               ;
    adc #regeneration_rate_for_enemy_ships                            ;
    bcc skip_ceiling3                                                 ;
    lda #$ff                                                          ;
skip_ceiling3
    sta enemy_ships_energy,x                                          ;
skip_enemy_regeneration
    jsr enemy_ship_defensive_behaviour_handling                       ;
    bcs skip_behaviour_routine                                        ;

    ; call the current behaviour routine
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    and #$0f                                                          ;
    tay                                                               ;
    lda enemy_ship_behaviour_routine_low_table,y                      ;
    sta temp1_low                                                     ;
    lda enemy_ship_behaviour_routine_high_table,y                     ;
    sta temp1_high                                                    ;
    jmp (temp1_low)                                                   ;

return_from_enemy_ship_behaviour_routine
    lda enemy_ships_x_screens,x                                       ;
    bmi skip_inversion_x5                                             ;
    eor #$ff                                                          ;
skip_inversion_x5
    sta x_pixels                                                      ;
    lda enemy_ships_y_screens,x                                       ;
    bmi skip_inversion_y5                                             ;
    eor #$ff                                                          ;
skip_inversion_y5
    clc                                                               ;
    adc x_pixels                                                      ;
    cmp #6                                                            ; velocity boost if very far away
    bcc skip_behaviour_routine                                        ;
    ldy enemy_ships_velocity,x                                        ;
    cpy #$22                                                          ;
    bcs skip_behaviour_routine                                        ; but not already boosted
    adc #$50                                                          ;
    bcc skip_ceiling4                                                 ;
    lda #$ff                                                          ;
skip_ceiling4
    sta enemy_ships_velocity,x                                        ;
skip_behaviour_routine
    jsr random_number_generator                                       ;
    lda rnd_1                                                         ;
    cmp #6                                                            ; 6/256 chance of changing behaviour type
    bcs skip_changing_behaviour_type                                  ;
    lda rnd_2                                                         ;
    and #$0f                                                          ;
    sta x_pixels                                                      ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    and #$f0                                                          ;
    ora x_pixels                                                      ;
    sta enemy_ships_flags_or_explosion_timer,x                        ;
    lda #0                                                            ;
    beq skip_resetting_hit_count                                      ;
skip_changing_behaviour_type
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    and #$f0                                                          ; reset enemy_ship_hit_count
skip_resetting_hit_count
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    inx                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    beq return27                                                      ;
    jmp update_enemy_ships_loop                                       ;

return27
    rts                                                               ;

; ----------------------------------------------------------------------------------
; Comes up from below starship to near stop above
; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine6
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen5                                                   ;
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne skip_firing1                                                  ;
    jsr fire_enemy_torpedo                                            ; fire if pointing at starship
skip_firing1
    lda enemy_ships_y_pixels,x                                        ;
    bpl slow_to_a_crawl                                               ; slow to a crawl if above starship
    and #$7f                                                          ;
    lsr                                                               ;
    clc                                                               ;
    adc enemy_ships_still_to_consider                                 ;
    sbc #6                                                            ;
    bcs use_speed_based_on_y_pixels                                   ; otherwise, set speed proportional to position
slow_to_a_crawl
    lda #1                                                            ;
use_speed_based_on_y_pixels
    cmp enemy_ship_desired_velocity                                   ;
    bcs return_after_changing_velocity4                               ;
    sta enemy_ship_desired_velocity                                   ;
    jmp return_after_changing_velocity4                               ;

off_screen5
    jsr turn_enemy_ship_towards_starship_using_screens                ;
return_after_changing_velocity4
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

; ----------------------------------------------------------------------------------
; Crashes into starship when going more than half speed
; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine7
    lda enemy_ship_desired_velocity                                   ;
    clc                                                               ;
    adc #8                                                            ;
    sta enemy_ship_desired_velocity                                   ;
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen6                                                   ; if enemy ship is on screen,
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    tay                                                               ;
    and #$10                                                          ;
    bne kamikaze_stage_one_set                                        ; and kamikaze_stage_one is unset,
    tya                                                               ;
    and #$20                                                          ;
    bne skip_setting_kamikaze_stage_one                               ; and kamikaze_stage_two is unset,
    lda starship_velocity_high                                        ;
    cmp #2                                                            ;
    bcc skip_setting_kamikaze_stage_one                               ; and starship going at more than half speed
    tya                                                               ;
    ora #$10                                                          ; then set kamikaze_stage_one
    tay                                                               ;
    sta enemy_ships_temporary_behaviour_flags,x                       ;
skip_setting_kamikaze_stage_one
    jsr get_rectilinear_distance_from_centre_of_screen                ;
    cmp #$69                                                          ;
    bcc decelerate1                                                   ; decelerate when close to starship
    tya                                                               ;
    and #$cf                                                          ; unset kamikaze_stage_one and kamikaze_stage_two
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    jmp skip_deceleration1                                            ;

decelerate1
    jsr decrease_enemy_ship_velocity                                  ;
    jsr decrease_enemy_ship_velocity                                  ;
skip_deceleration1
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne to_return_from_enemy_ship_behaviour_routine3                  ;
    jsr fire_enemy_torpedo                                            ;
    jmp to_return_from_enemy_ship_behaviour_routine3                  ;

kamikaze_stage_one_set
    lda enemy_ship_desired_angle_divided_by_eight                     ;
    lsr                                                               ;
    clc                                                               ;
    adc #8                                                            ; ninety degrees clockwise turn
    and #$1f                                                          ;
    jsr turn_enemy_ship_towards_angle_accounting_for_starship_velocity ;
    lda enemy_ships_y_pixels,x                                        ;
    bmi return_after_changing_velocity5                               ; leave if underneath starship
    lda enemy_ships_x_pixels,x                                        ;
    sec                                                               ;
    sbc #$60                                                          ;
    cmp #$40                                                          ;
    bcs return_after_changing_velocity5                               ; leave if too far to the right
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    eor #$30                                                          ; unset kamikaze_stage_one, set kamikaze_stage_two
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    jmp return_after_changing_velocity5                               ;

off_screen6
    jsr turn_enemy_ship_towards_starship_using_screens                ;
return_after_changing_velocity5
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
to_return_from_enemy_ship_behaviour_routine3
    jmp return_from_enemy_ship_behaviour_routine                      ;

!if do_debug {
counter
    !byte 0
column
    !byte 0
row
    !byte 0

; ----------------------------------------------------------------------------------
debug_plot
    lda #50                                                           ;
    sta x_pixels                                                      ;
    sta temp10                                                        ;
    lda #128                                                          ;
    sta y_pixels                                                      ;
    sta temp9                                                         ;
    jmp debug_plot_enemy                                              ;

; ----------------------------------------------------------------------------------
debug_show_rotation_value_text
    lda #30                                                           ;
    jsr oswrch                                                        ;

    lda temp11                                                        ;
    ldx #0                                                            ;
-
    cmp #10                                                           ;
    bcc +                                                             ;
    inx                                                               ;
    sec                                                               ;
    sbc #10                                                           ;
    jmp -                                                             ;
+
    tay                                                               ;
    txa                                                               ;
    clc                                                               ;
    adc #'0'                                                          ;
    jsr oswrch                                                        ;
    tya                                                               ;
    clc                                                               ;
    adc #'0'                                                          ;
    ldy #' '                                                          ;
    jmp oswrch_ay                                                     ;

key
    !byte 0                                                           ;

; ----------------------------------------------------------------------------------
debug_get_key_press
    lda #15                                                           ;
    ldx #1                                                            ;
    jsr osbyte                                                        ;

    lda #osbyte_inkey                                                 ;
    ldx #$ff                                                          ;
    ldy #$7f                                                          ;
    jmp osbyte                                                        ;

; ----------------------------------------------------------------------------------
debug
    lda #0                                                            ;
    sta temp11                                                        ;

    lda #36                                                           ;
    sta column                                                        ;

    lda #30                                                           ;
    sta row                                                           ;

    lda #1                                                            ;
    sta command_number                                                ;
    lda #0                                                            ; Zero for first ship type, 1 for second ship type
    sta enemy_ship_type                                               ;

    lda #0                                                            ;
    sta counter                                                       ;

--
    lda column                                                        ;
    clc                                                               ;
    adc #20                                                           ;
    sta column                                                        ;
    sta x_pixels                                                      ;
    sta temp10                                                        ;

    lda row                                                           ;
    sta y_pixels                                                      ;
    sta temp9                                                         ;

    jsr debug_plot_enemy                                              ;

    lda temp11                                                        ;
    clc                                                               ;
    adc #1                                                            ;
    and #$1f                                                          ;
    sta temp11                                                        ;

    inc counter                                                       ;
    lda counter                                                       ;
    cmp #8                                                            ;
    bcc --                                                            ;

    lda #0                                                            ;
    sta counter                                                       ;

    lda #36                                                           ;
    sta column                                                        ;

    lda row                                                           ;
    clc                                                               ;
    adc #20                                                           ;
    sta row                                                           ;

    cmp #100                                                          ;
    bcc --                                                            ;

    ; interactive bit
--
    jsr debug_plot                                                    ; plot
    jsr debug_show_rotation_value_text                                ;

-
    jsr debug_get_key_press                                           ;
    cpx #'X'                                                          ;
    bne +                                                             ;

    jsr debug_plot                                                    ; unplot
    ; increment angle
    lda temp11                                                        ;
    clc                                                               ;
    adc #1                                                            ;
    and #$1f                                                          ;
    sta temp11                                                        ;
    jmp --                                                            ;

+
    cpx #'Z'                                                          ;
    bne -                                                             ;

    jsr debug_plot                                                    ; unplot
    ; decrement angle
    lda temp11                                                        ;
    sec                                                               ;
    sbc #1                                                            ;
    and #$1f                                                          ;
    sta temp11                                                        ;
    jmp --                                                            ;
}

!if elk+antiflicker=2 { ; crude anti flicker on Elk
; ----------------------------------------------------------------------------------
; On Entry:
;   A = Y coordinate to plot at
; On Exit:
;   Carry clear if in danger area
;   Preserves X,Y
; ----------------------------------------------------------------------------------
is_in_danger_area
    cmp #100                                                          ;
    bcs lower_half                                                    ;

    ; enemy ship is in upper half of screen, but what about the electron beam?
    lda irq_counter                                                   ;
    beq in_danger                                                     ;
    ; electron beam is in lower half, so no problem
no_danger
    sec                                                               ;
    rts                                                               ;

lower_half
    ; enemy ship is in lower half of screen, but what about the electron beam?
    lda irq_counter                                                   ;
    beq no_danger                                                     ; electron beam is in upper half, so no problem
in_danger
    clc                                                               ;
    rts                                                               ;
}

!if elk=0 {
; ----------------------------------------------------------------------------------
; On Entry:
;   A = Y coordinate to plot at
;   danger_height = height in character rows of the danger zone
; On Exit:
;   Carry clear if in danger area
;   Preserves X,Y
; ----------------------------------------------------------------------------------
is_in_danger_area
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ; A = character row
    sec                                                               ;
    sbc irq_counter                                                   ;
    cmp #danger_height                                                ;
    bcc done1                                                         ;
    sec                                                               ;
    sbc #256-38                                                       ;
    cmp #danger_height                                                ;
done1
    rts                                                               ;
}

; ----------------------------------------------------------------------------------
main_game_loop
!if do_debug {
    jsr debug
}

    lda #0                                                            ;
    sta enemy_torpedo_hits_against_starship                           ;
    sta enemy_ship_was_hit                                            ;
    sta starship_collided_with_enemy_ship                             ;
    sta starship_fired_torpedo                                        ;
    sta enemy_ship_fired_torpedo                                      ;
    sta enemy_ships_collided_with_each_other                          ;
    jsr apply_velocity_to_enemy_ships                                 ;
    lda #$ff                                                          ;
    sta how_enemy_ship_was_damaged                                    ; -1 = collision with starship
    jsr check_for_starship_collision_with_enemy_ships                 ;
    jsr update_enemy_ships                                            ;
    lda starship_shields_active                                       ;
    beq skip_scanner_update                                           ;
    lda scanner_failure_duration                                      ;
    bne skip_scanner_update                                           ;
    jsr plot_enemy_ships_on_scanners                                  ;
skip_scanner_update

!if elk=0 {
wait_for_timer
    ; wait for some time to have elapsed
-
    lda timing_counter                                                ;
    sec                                                               ;
    sbc old_timing_counter                                            ;
    cmp #game_speed                                                   ;
    bcc -                                                             ;

post_wait_for_timer
    clc                                                               ;
    adc old_timing_counter                                            ;
    sta old_timing_counter                                            ;
}

    jsr plot_enemy_ships                                              ;
    ldy #index_of_in_game_stars                                       ;
    jsr update_stars                                                  ;
    jsr handle_enemy_ships_cloaking                                   ;
    inc how_enemy_ship_was_damaged                                    ; # 0 = collision with starship torpedoes
    jsr update_starship_torpedoes                                     ;
    jsr update_enemy_torpedoes                                        ;
    inc how_enemy_ship_was_damaged                                    ; # 2 = collision with escape pod
    jsr handle_starship_self_destruct                                 ;
    jsr handle_scanner_failure                                        ;
    lda #0                                                            ;
    dec timer_for_starship_energy_regeneration                        ;
    bne set_regeneration                                              ;
    lda maximum_timer_for_starship_energy_regeneration                ;
    sta timer_for_starship_energy_regeneration                        ;
    lda #base_regeneration_rate_for_starship                          ;
    sec                                                               ;
    sbc starship_velocity_high                                        ;
    ldy starship_shields_active                                       ;
    bne set_regeneration                                              ;
    sec                                                               ;
    sbc subtraction_from_starship_regeneration_when_shields_active    ;
set_regeneration
    sta starship_energy_regeneration                                  ;
    lda starship_has_exploded                                         ;
    beq starship_hasnt_exploded                                       ;
    jsr plot_starship_explosion                                       ;
    jmp skip_player_movement                                          ;

starship_hasnt_exploded
    jsr update_various_starship_statuses_on_screen                    ;
    jsr handle_player_movement                                        ;
skip_player_movement
    jsr apply_rotation_to_starship_angle                              ;
    jsr play_sounds                                                   ;
    jsr apply_delta_to_score                                          ;
    jsr random_number_generator                                       ;
    and #$3f                                                          ;
    clc                                                               ;
    adc #base_damage_to_enemy_ship_from_other_collision               ;
    sta damage_to_enemy_ship_from_other_collision                     ;
    lda starship_velocity_high                                        ;
    sta y_pixels                                                      ;
    lda starship_velocity_low                                         ;
    asl                                                               ;
    rol y_pixels                                                      ;
    asl                                                               ;
    rol y_pixels                                                      ;
    lda rnd_1                                                         ;
    and #$1f                                                          ;
    adc y_pixels                                                      ;
    adc #$0c                                                          ;
    sta value_used_for_enemy_torpedo_time_to_live                     ;
    jmp main_game_loop                                                ;

; ----------------------------------------------------------------------------------
previous_score_as_bcd
    !byte 0                                                           ;
    !byte 0                                                           ;
    !byte 0                                                           ;

; ----------------------------------------------------------------------------------
; twenty times these values are the score thresholds to reach
score_threshold_table
    ; entry * 20 = score to reach |  emotion when reached
    ; ----------------------------+-----------------------------------
    ;                0            |  "furious"
    ;     2 * 20 =  40            |  "displeased"
    ;     3 * 20 =  60            |  "disappointed" and they retire you from active service.
    ;     4 * 20 =  80            |  "disappointed" but they allow you the command of another starship.
    ;     7 * 20 = 140            |  "satisfied"
    ;    13 * 20 = 260            |  "pleased"
    ;    20 * 20 = 400            |  "impressed"
    ;    30 * 20 = 600            |  "delighted"
    ; ----------------------------+-----------------------------------
    !byte 2, 3, 4, 7, 13, 20, 30                                      ;

print_escape_capsule_launched_with_qualifier
    jsr oswrch_ay                                                     ;
    ; Print " escape capsule was launched "                           ;
    ldx #escape_capsule_was_launched_string                           ;
    jmp print_compressed_string                                       ;

; ----------------------------------------------------------------------------------
no_escape_capsule
    ; Print "No escape capsule was launched "
    lda #'N'                                                          ;
    ldy #'o'                                                          ;
    jsr print_escape_capsule_launched_with_qualifier                  ;

    ; Print "before the starship exploded."
    ldx #before_the_starship_exploded_string                          ;
    jsr print_compressed_string                                       ;
    jmp print_experience                                              ;

; ----------------------------------------------------------------------------------
plot_debriefing
    jsr plot_starship_heading                                         ;

    lda #30                                                           ;
    jsr oswrch                                                        ;
    jsr plot_line_of_underscores_raw                                  ;

    ; Print heading
    ldx #combat_experience_heading_string                             ;
    jsr print_compressed_string                                       ;

    ; Print command number
    lda command_number                                                ;
    jsr plot_two_bcd_digits_with_no_spaces                            ;
    jsr osnewl                                                        ;
    jsr plot_line_of_underscores_raw                                  ;

    ldy #29                                                           ;
    jsr plot_line_of_underscores_at_y                                 ;

    ldx #4                                                            ;
    ldy #9                                                            ;
    jsr tab_to_x_y                                                    ;

    lda escape_capsule_launched                                       ;
    beq no_escape_capsule                                             ; if (no escape capsule launched) then branch

    ; Print "An escape capsule was launched"
    lda #'A'                                                          ;
    ldy #'n'                                                          ;
    jsr print_escape_capsule_launched_with_qualifier                  ;

    ; Print one of:
    ;   " and returned safely from the combat zone."
    ;   " but collided with an enemy ship."
    ldx #but_collided_string                                          ;
    lda escape_capsule_destroyed                                      ;
    bne +                                                             ; if (capsule destroyed) then branch
    dex
+
    jsr print_compressed_string                                       ;

print_experience
    ; Print "Your official combat experience rating is now recorded as"
    ldx #combat_experience_rating_string                              ;
    jsr print_compressed_string                                       ;

    ; print score with no leading spaces
    lda score_as_bcd + 2                                              ;
    jsr plot_two_bcd_digits_with_no_spaces                            ;
    lda score_as_bcd + 1                                              ;
    jsr plot_two_bcd_digits                                           ;
    lda score_as_bcd                                                  ;
    jsr plot_final_two_digits                                         ;

    ; subtract the previous total score from the current total score, to get the amount gained in the last command
    php                                                               ;
    sec                                                               ;
    sei                                                               ;
    sed                                                               ; BCD on
    ldx #0                                                            ;
    ldy #3                                                            ;
-
    lda score_as_bcd,x                                                ;
    sbc previous_score_as_bcd,x                                       ;
    sta previous_score_as_bcd,x                                       ;
    inx                                                               ;
    dey                                                               ;
    bne -                                                             ;
    plp                                                               ;

    lda escape_capsule_destroyed                                      ;
    eor escape_capsule_launched                                       ; check for 'launched and not destroyed'
    sta allowed_another_command                                       ;

    lda command_number                                                ;
    cmp #1                                                            ;
    beq skip_previous_command_score                                   ;

    ldx #having_just_gained_string                                    ;
    jsr print_compressed_string                                       ;

    ; print previous score
    lda previous_score_as_bcd + 2                                     ;
    jsr plot_two_bcd_digits_with_no_spaces                            ;
    lda previous_score_as_bcd + 1                                     ;
    jsr plot_two_bcd_digits                                           ;
    lda previous_score_as_bcd                                         ;
    jsr plot_final_two_digits                                         ;

skip_previous_command_score
    jsr print_dot                                                     ; End with full stop
    lda allowed_another_command                                       ;
    beq show_any_posthumous_award                                     ;

plot_after_your_performance
    ; print "After your performance on this command the Star-Fleet authorities are said to be \""
    ldx #after_your_performance_string                                ;
    jsr print_compressed_string                                       ;

judge_player
calculate_and_print_emotion
    ; add random amount $00-$3f to BCD version of score.
    ; Implementation seems odd, mixing a regular number with BCD number.
    lda rnd_2                                                         ; add random &00 - &3f to score
    and #$3f                                                          ;
    clc                                                               ;
    adc previous_score_as_bcd                                         ;
    sta previous_score_as_bcd                                         ;
    lda previous_score_as_bcd + 1                                     ;
    adc #0                                                            ;

    ; divide by 20 (shifts BCD number five times)
    ldy #5                                                            ;
division_loop1
    lsr                                                               ;
    ror previous_score_as_bcd                                         ;
    dey                                                               ;
    bne division_loop1                                                ;

    ; automatic delighted if score > 10000
    ldy #8                                                            ; emotion index
    ora previous_score_as_bcd + 2                                     ;
    bne end_of_calculation                                            ;

    ldy #1                                                            ; emotion index
    lda previous_score_as_bcd                                         ;
check_threshold_loop
    cmp score_threshold_table - 1,y                                   ; otherwise, compare against threshold
    bcc end_of_calculation                                            ;
    iny                                                               ; emotion index
    cpy #8                                                            ;
    bne check_threshold_loop                                          ;

end_of_calculation
print_quoted_emotion
    ; print emotion, quote
    tya                                                               ;
    pha                                                               ;
    clc                                                               ;
    adc #emotions_1 - 1                                               ;
    tax                                                               ;
    jsr print_compressed_string                                       ;
print_quote                                                           ;
    lda #'"'                                                          ;"
    jsr oswrch                                                        ;

    ldx #and_string                                                   ;
    ; check for retired
    pla                                                               ; emotion
    cmp #4                                                            ;
    bcc player_retired                                                ; if (retired) then branch

    ; print " and " / " but "
    bne do_and                                                        ;
    inx                                                               ;
do_and
    jsr print_compressed_string                                       ;

    ; print "they allow you the command of another starship."
    ldx #they_allow_string                                            ;
    jmp print_compressed_string                                       ;

player_retired
    ldy #0                                                            ;
    sty allowed_another_command                                       ;

    ldx #and_they_retire_you_string                                   ;
    jsr print_compressed_string                                       ;

show_any_retirement_award
    lda #award_outcome_escape_1                                       ;
    !byte $2c                                                         ; 'BIT abs' opcode to skip next instruction
show_any_posthumous_award
    lda #award_outcome_die_1                                          ;
    pha
calculate_and_print_award
    ldy #num_award_levels - 1                                         ; start at highest award level
    lda score_as_bcd + 2                                              ;
    bne done_award                                                    ;
    iny                                                               ;
-
    dey                                                               ;
    lda score_as_bcd + 1                                              ;
    cmp award_thresholds_high,y                                       ;
    bcc -                                                             ;
    bne done_award                                                    ;
    lda score_as_bcd                                                  ;
    cmp award_thresholds_low,y                                        ;
    bcc -                                                             ;
done_award
    sty award                                                         ;
    ldx #award_review_string
    jsr print_compressed_string                                       ;
    lda #award_adjective_6                                            ; distinguished
    ldx command_number                                                ;
    cpx #9                                                            ;
    bcs +                                                             ;
    lda adjective_table - 1,x                                         ;
+
    tax                                                               ;
    jsr print_compressed_string                                       ;
    pla                                                               ;
    clc                                                               ;
    adc award                                                         ;
print_award
    tax                                                               ;
    jsr print_compressed_string                                       ;
print_dot
    lda #'.'                                                          ;
    jmp oswrch                                                        ;

; ----------------------------------------------------------------------------------
; "After reviewing your ADJECTIVE career, Star-Fleet OUTCOME."
;
; ADJECTIVE:
;   if only one command: "all-too brief"
;   if only two commands: "short"
;   if three to four: "fairly short"
;   if five to six: "fairly long"
;   seven to nine: "long"
;   else "distinguished"
;
; OUTCOME IF YOU DIE:
;
;   1. list your name on the Pluto monument
;   2. mention you in a tri-vi broadcast
;   3. award you the Order of the Badger
;   4. award you the Order of the Lion, Second Class
;   5. award you the Order of the Lion, First Class
;   6. award you the Order of the Lion, First Class, with Oak Leaves
;   7. award you the Order of the Lion, First Class, with Oak Leaves and Crossed Blasters
;   8. put your face on recruiting posters
;   9. build a statue of you on Mars
;   10. rename the Academy after you
;
; OUTCOME IF YOU ESCAPE IN POD:
;
;   1. court-martial you for cowardice
;   2. demote you to worker grade
;   3. retrain you as a gardener
;   4. assign you to planning staff
;   5. grant you a full pension
;   6. promote you to Commodore
;   7. promote you to Rear-Admiral
;   8. promote you to Admiral
;   9. promote you to Grand Admiral
;   10. elect you President of the Solar Federation
; ----------------------------------------------------------------------------------
; In BCD
award_thresholds_low
    !byte <$0000                                                      ; 1.    score >=   0
    !byte <$0020                                                      ; 2.    score >=  20
    !byte <$0050                                                      ; 3.    score >=  50
    !byte <$0100                                                      ; 4.    score >= 100
    !byte <$0200                                                      ; 5.    score >= 200
    !byte <$0300                                                      ; 6.    score >= 300
    !byte <$0400                                                      ; 7.    score >= 400
    !byte <$0500                                                      ; 8.    score >= 500
    !byte <$0750                                                      ; 9.    score >= 750
    !byte <$1000                                                      ; 10.   score >= 1000

award_thresholds_high
    !byte >$0000                                                      ; 1.    score >=   0
    !byte >$0020                                                      ; 2.    score >=  20
    !byte >$0050                                                      ; 3.    score >=  50
    !byte >$0100                                                      ; 4.    score >= 100
    !byte >$0200                                                      ; 5.    score >= 200
    !byte >$0300                                                      ; 6.    score >= 300
    !byte >$0400                                                      ; 7.    score >= 400
    !byte >$0500                                                      ; 8.    score >= 500
    !byte >$0750                                                      ; 9.    score >= 750
    !byte >$1000                                                      ; 10.   score >= 1000


num_award_levels = award_thresholds_high - award_thresholds_low

; ----------------------------------------------------------------------------------
adjective_table
    !byte award_adjective_1         ; 1 command:    "all-too-brief"
    !byte award_adjective_2         ; 2 commands:   "short"
    !byte award_adjective_3         ; 3 commands:   "fairly short"
    !byte award_adjective_3         ; 4 commands:   "fairly short"
    !byte award_adjective_4         ; 5 commands:   "fairly long"
    !byte award_adjective_4         ; 6 commands:   "fairly long"
    !byte award_adjective_5         ; 7 commands:   "long"
    !byte award_adjective_5         ; 8 commands:   "long"
    !byte award_adjective_5         ; 9 commands:   "long"
                                    ; 10+ commands: "distinguished"

; ----------------------------------------------------------------------------------
game_options
option_sound
    !byte 0                                                           ;
option_starship_torpedoes
    !byte 0                                                           ;
option_enemy_torpedoes
    !byte 1                                                           ;
option_keyboard_joystick
    !byte 0                                                           ;

options_values_to_write
    !byte 0                                                           ;
    !byte 1                                                           ;
    !byte 0                                                           ;
    !byte 1                                                           ;
    !byte $4c                                                         ; JMP opcode
    !byte $20                                                         ; JSR opcode
    !byte 0                                                           ;
    !byte 2                                                           ;
option_address_low_table
    !byte <sound_enabled                                              ;
    !byte <starship_torpedo_type                                      ;
    !byte <enemy_torpedo_type_instruction                             ;
    !byte <keyboard_or_joystick                                       ;
option_address_high_table
    !byte >sound_enabled                                              ;
    !byte >starship_torpedo_type                                      ;
    !byte >enemy_torpedo_type_instruction                             ;
    !byte >keyboard_or_joystick                                       ;

; ----------------------------------------------------------------------------------
plot_selected_option
    dey                                                               ;
    lda #$1f                                                          ;
    jsr oswrch                                                        ;
    lda #9                                                            ;
    jsr oswrch                                                        ;
    tya                                                               ;
    asl                                                               ;
    jsr oswrch                                                        ;
    tya                                                               ;
    and #1                                                            ;
    eor game_options,x                                                ;
    beq +                                                             ;
    lda #'*'                                                          ; more legible than '-'
    !byte $2c                                                         ; 'BIT abs' opcode, to skip the next instruction
+
    lda #' '                                                          ;
    jmp oswrch                                                        ;

; ----------------------------------------------------------------------------------
get_key_maybe_its_return
    lda #osbyte_inkey                                                 ;
    ldx #0                                                            ;
    ldy #0                                                            ;
    jsr osbyte                                                        ;
    cpx #$0d                                                          ;
return28
    rts                                                               ;

; ----------------------------------------------------------------------------------
combat_preparation_screen
    jsr screen_off                                                    ;
    ldx #combat_preparation_string                                    ;
    jsr print_string_and_finish_screen

plot_selected_options
    ldx #3                                                            ;
    ldy #13                                                           ;
plot_selected_options_loop
    jsr plot_selected_option                                          ;
    jsr plot_selected_option                                          ;
    dex                                                               ;
    bpl plot_selected_options_loop                                    ;
get_keypress
    jsr get_key_maybe_its_return                                      ;
    beq return28                                                      ;
    cpx #'9'+1                                                        ;
    bcs get_keypress                                                  ;
    cpx #'0'                                                          ;
    bcc get_keypress                                                  ;
    bne not_f0                                                        ;
instructions_screen
    jsr screen_off                                                    ;
    ldx #instructions_string1                                         ;
    jsr print_compressed_string                                       ;
    ldx #instructions_string2                                         ;
    jsr print_string_finish_and_wait                                  ;
    beq combat_preparation_screen                                     ; ALWAYS branch

not_f0
    cpx #'1'                                                          ;
    bne not_f1                                                        ;
    jsr starfleet_records_screen                                      ;
    beq combat_preparation_screen                                     ; ALWAYS branch

not_f1
    txa                                                               ; Translate ASCII '2'-'9'
    and #$0f                                                          ; into option number
    lsr                                                               ; Y=1-4
    tay                                                               ;
    txa                                                               ;
    and #1                                                            ; 0=switch off, 1=switch on

    ; calculate destination address for the new option
    sta game_options - 1,y                                            ;
    lda option_address_low_table - 1,y                                ;
    sta temp0_low                                                     ;
    lda option_address_high_table - 1,y                               ;
    sta temp0_high                                                    ;

    ; write the new option value
    lda options_values_to_write-'0'-2,x                               ; read new value from table
    ldy #0                                                            ;
    sta (temp0_low),y                                                 ; write to destination address
    beq plot_selected_options                                         ; ALWAYS branch

; ----------------------------------------------------------------------------------
starfleet_records_screen
    jsr screen_off                                                    ;

    ldx #0                                                            ;
plot_high_scores_loop
    lda #$1f                                                          ;
    jsr oswrch                                                        ;
    lda #7                                                            ; TAB(7,10 + X/8)
    jsr oswrch                                                        ;
    txa                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    adc #10                                                           ;
!if elk {
    pha                                                               ;
}
    jsr oswrch                                                        ;
!if elk {
    pla                                                               ;
}
    ldy high_score_table + 3,x                                        ;
    beq leave_after_plotting_underscores                              ;

    ; plot index (X/16)
    lsr                                                               ;
    adc #44                                                           ;
    jsr oswrch                                                        ;
    jsr print_three_spaces                                            ;
    inx                                                               ;
    inx                                                               ;
    inx                                                               ;

    ; plot name
    ldy #$0d                                                          ;
plot_name_loop
    lda high_score_table,x                                            ;
    jsr oswrch                                                        ;
    inx                                                               ;
    dey                                                               ;
    bne plot_name_loop                                                ;

    jsr print_three_spaces                                            ;

    ; print score
    lda $0000 + high_score_table - 16,x                               ; }
    jsr plot_two_bcd_digits_with_leading_spaces                       ; }
    lda $0000 + high_score_table - 15,x                               ; } using $0000 to ensure full 16 bit addressing
    jsr plot_two_bcd_digits                                           ; }
    lda $0000 + high_score_table - 14,x                               ; }
    jsr plot_two_bcd_digits                                           ;

    ; loop over all entries
    txa                                                               ;
    bpl plot_high_scores_loop                                         ;

leave_after_plotting_underscores
    ldx #starfleet_records_string                                     ;

print_string_finish_and_wait
    jsr print_string_and_finish_screen                                ;
wait_for_return
    jsr get_key_maybe_its_return                                      ;
    bne wait_for_return                                               ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
print_three_spaces
    ldy #3                                                            ;
-
    lda #9                                                            ;
    jsr oswrch                                                        ;
    dey                                                               ;
    bpl -                                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_final_two_digits
    ; print two digits, but ensure that at least one zero is printed
    ; this is only ever called with null padding character so we don't need to backspace
    pha                                                               ;
    jsr plot_two_bcd_digits                                           ;
    pla                                                               ;
    bne +                                                             ;
    cpy #'0'
    bne print_final_zero                                              ; padding still in place?
+
    rts                                                               ;
plot_two_bcd_digits_with_no_spaces
    ldy #0                                                            ; null padding. printing this is a no-op
    !byte $2c                                                         ; 'BIT abs' opcode, to skip the next instruction
plot_two_bcd_digits_with_leading_spaces
    ldy #' '                                                          ;
plot_two_bcd_digits
    pha                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    jsr plot_one_digit                                                ;
    pla                                                               ;
    and #$0f                                                          ;
plot_one_digit
    bne not_zero                                                      ;
    tya                                                               ;
    bpl leading_zero2                                                 ; ALWAYS branch
not_zero
    ldy #'0'                                                          ;
print_final_zero
    ora #'0'                                                          ;
leading_zero2
    jmp oswrch                                                        ;

; ----------------------------------------------------------------------------------
input_osword_block
    !word input_buffer                                                ;
    !byte 13                                                          ; buffer length
    !byte $20, $ff                                                    ; range of characters accepted

; ----------------------------------------------------------------------------------
check_for_high_score
    lda score_as_bcd                                                  ;
    ora score_as_bcd + 1                                              ;
    ora score_as_bcd + 2                                              ;
    beq score_is_zero                                                 ; don't check if player scored zero
    ldx #0                                                            ;
consider_records_loop
    lda score_as_bcd + 2                                              ;
    cmp high_score_table,x                                            ;
    bcc consider_next_record                                          ;
    bne higher_score                                                  ;
    lda score_as_bcd + 1                                              ;
    cmp high_score_table + 1,x                                        ;
    bcc consider_next_record                                          ;
    bne higher_score                                                  ;
    lda score_as_bcd                                                  ;
    cmp high_score_table + 2,x                                        ;
    bcs higher_score                                                  ;
consider_next_record
    txa                                                               ;
    clc                                                               ;
    adc #$10                                                          ;
    tax                                                               ;
    bpl consider_records_loop                                         ;
score_is_zero
    rts                                                               ;

; ----------------------------------------------------------------------------------
higher_score
    stx temp7                                                         ;
    ldx #$70                                                          ;
move_records_down_a_slot_loop
    cpx temp7                                                         ;
    beq finished_moving_records                                       ;
    dex                                                               ;
    lda high_score_table,x                                            ;
    sta high_score_table + 16,x                                       ;
    jmp move_records_down_a_slot_loop                                 ;

finished_moving_records
    jsr screen_off                                                    ;
    ldx #enter_your_name_string                                       ;
    jsr print_compressed_string                                       ;
    jsr screen_on_with_cursor                                         ;

    ldx #<(input_osword_block)                                        ;
    ldy #>(input_osword_block)                                        ;
    lda #osword_read_line                                             ;
    jsr osword                                                        ;
    sty y_pixels                                                      ;
    ldx temp7                                                         ;
    lda score_as_bcd                                                  ;
    sta high_score_table + 2,x                                        ;
    lda score_as_bcd + 1                                              ;
    sta high_score_table + 1,x                                        ;
    lda score_as_bcd + 2                                              ;
    sta high_score_table,x                                            ;
    ldy #0                                                            ;
copy_name_loop
    cpy y_pixels                                                      ;
    beq pad_name_loop                                                 ;
    lda input_buffer,y                                                ;
    sta high_score_table + 3,x                                        ;
    inx                                                               ;
    iny                                                               ;
    bne copy_name_loop                                                ;
pad_name_loop
    cpy #$0d                                                          ;
    beq finished_padding_name                                         ;
    lda #$20                                                          ;
    sta high_score_table + 3,x                                        ;
    inx                                                               ;
    iny                                                               ;
    bne pad_name_loop                                                 ;
finished_padding_name
    jmp starfleet_records_screen                                      ;

; ----------------------------------------------------------------------------------
plot_shields_string_and_something
    stx starship_shields_active_before_failure                        ;
    jsr plot_shields_string                                           ;
    lda scanner_failure_duration                                      ;
    beq return29                                                      ;
    pla                                                               ; abandon any further plotting in handle_player_movement
    pla                                                               ;
return29
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_auto_shields_string
    lda previous_starship_automatic_shields                           ;
    cmp starship_automatic_shields                                    ;
    bpl return29                                                      ;
    ldx #regular_string_index_shield_state_auto                       ;
plot_shields_string
    jmp print_regular_string                                          ;

; ----------------------------------------------------------------------------------
start_game
    jsr screen_off
    lda #0                                                            ;
    sta previous_score_as_bcd                                         ;
    sta previous_score_as_bcd + 1                                     ;
    sta previous_score_as_bcd + 2                                     ;
    sta number_of_live_starship_torpedoes                             ;

    lda #$ff                                                          ;
    sta command_number_used_for_maximum_enemy_torpedo_cooldown_lookup ;
    sta starship_type                                                 ;
    sta enemy_number                                                  ;
    lda #0                                                            ;
    sta command_number                                                ;
    sta score_as_bcd + 2                                              ;
    sta score_as_bcd + 1                                              ;
    sta score_as_bcd                                                  ;
    lda #maximum_number_of_stars_in_game                              ;
    sta maximum_number_of_stars                                       ;
    ldy #3                                                            ;
reset_enemy_ship_spawning_probabilities_loop
    lda initial_enemy_ship_spawning_probabilities,y                   ;
    sta probability_of_new_enemy_ship_being_defensive_about_damage,y  ;
    dey                                                               ;
    bpl reset_enemy_ship_spawning_probabilities_loop                  ;
    jsr prepare_starship_for_next_command                             ;
    jmp main_game_loop                                                ;

; ----------------------------------------------------------------------------------
end_of_command
    pla                                                               ; remove plot_starship_explosion from stack
    pla                                                               ;
    lda enemy_ships_previous_x_fraction                               ;
    sta rnd_2                                                         ; re-seed the RNG with two essentially random numbers
    lda enemy_ships_previous_y_fraction                               ;
    sta rnd_1                                                         ;

    ; check the random number generator isn't zero
    ora rnd_2                                                         ;
    bne +                                                             ; if (non zero) then branch
    inc rnd_1                                                         ;
+
    lda #0                                                            ; turn static off
    sta scanner_failure_duration                                      ;
    sta energy_flash_timer                                            ;
    lda #$ff
    sta starship_energy_divided_by_sixteen                            ; disable energy low
    sta enableKeyboardInterruptProcessingFlag                         ; enable keyboard interrupt
    jsr screen_off                                                    ;
    jsr plot_debriefing                                               ;
    jsr screen_on_and_flush                                           ;
    jsr wait_for_return                                               ;
    lda allowed_another_command                                       ;
    bne start_next_command                                            ;
    jsr check_for_high_score                                          ;
    jmp start                                                         ;

; ----------------------------------------------------------------------------------
start_next_command
    jsr combat_preparation_screen                                     ;
    ldy #0                                                            ;
-
    lda score_as_bcd,y                                                ;
    sta previous_score_as_bcd,y                                       ;
    iny                                                               ;
    cpy #3                                                            ;
    bne -                                                             ;
change_probabilities_loop
    lda probability_of_new_enemy_ship_being_defensive_about_damage,y  ;
    cmp ultimate_enemy_ship_probabilities,y                           ;
    beq skip_change_of_probability                                    ;
    clc                                                               ;
    adc change_in_enemy_ship_spawning_probabilities_per_command,y     ;
    sta probability_of_new_enemy_ship_being_defensive_about_damage,y  ;
skip_change_of_probability
    dey                                                               ;
    bpl change_probabilities_loop                                     ;
    lda maximum_number_of_stars                                       ;
    cmp #minimum_number_of_stars                                      ;
    beq skip_change_of_stars                                          ;
    clc                                                               ;
    adc #change_in_number_of_stars_per_command                        ;
    sta maximum_number_of_stars                                       ;
skip_change_of_stars
    jsr screen_off                                                    ;
    jsr prepare_starship_for_next_command                             ;
    jmp main_game_loop                                                ;

; ----------------------------------------------------------------------------------
get_joystick_input
    lda #osbyte_read_adc_or_get_buffer_status                         ;
    ldx #0                                                            ; Read joystick buttons
    jsr osbyte                                                        ;
    txa                                                               ;
    and #3                                                            ;
    beq fire_not_pressed                                              ; fire_not_pressed
    inc fire_pressed                                                  ; fire_pressed
fire_not_pressed
    lda #osbyte_read_adc_or_get_buffer_status                         ;
    ldx #2                                                            ; Read analogue Channel 2
    jsr osbyte                                                        ;
    lda starship_velocity_high                                        ;
    sta x_pixels                                                      ; get velocity
    lda starship_velocity_low                                         ;
    asl                                                               ;
    rol x_pixels                                                      ; velocity_high_shifted
    asl                                                               ;
    rol x_pixels                                                      ; velocity_high_shifted
    tya                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    sec                                                               ;
    sbc #8                                                            ;
    bcs skip_floor1                                                   ;
    lda #0                                                            ;
skip_floor1
    cmp x_pixels                                                      ; velocity_high_shifted
    beq consider_rotation                                             ;
    bcc decrease_velocity                                             ;
increase_velocity
    inc velocity_delta                                                ;
    bcs consider_rotation                                             ; ALWAYS branch

decrease_velocity
    dec velocity_delta                                                ;
consider_rotation
    lda #osbyte_read_adc_or_get_buffer_status                         ;
    ldx #1                                                            ; Read analogue Channel 1
    jsr osbyte                                                        ;
    tya                                                               ;
    eor #$ff                                                          ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    cmp #8                                                            ;
    bcc skip_subtraction                                              ;
    sbc #1                                                            ;
    clc                                                               ;
skip_subtraction
    adc #$79                                                          ;
    cmp starship_rotation                                             ;
    beq return31                                                      ;
    bcs rotate_clockwise                                              ;
rotate_anticlockwise
    dec rotation_delta                                                ;
    bcc return31                                                      ; ALWAYS branch

rotate_clockwise
    inc rotation_delta                                                ;
return31
    rts                                                               ;

; ----------------------------------------------------------------------------------
; avoid returning control characters other than 13 (newline) and 21 (erase)
; without this it is trivial to crash the game by entering, e.g., ctrl+V A
our_rdch
    jsr $0000                                                         ;
    cmp #0                                                            ;
    bmi our_rdch                                                      ; skip top bit set chars

    ; these are generated by cursor keys and still displayed even if not
    ; accepted into our input string
    cmp #$20                                                          ;
    bcs +                                                             ;
    cmp #$0d                                                          ;
    beq +                                                             ;
    cmp #$15                                                          ;
    bne our_rdch                                                      ;
+
    clc                                                               ;
    rts                                                               ;

!if elk+antiflicker=2 {
; ----------------------------------------------------------------------------------
; Only uses A, preserves X,Y
irq_routine
    ; check master IRQ
    lda $fe00                                                         ;
    lsr                                                               ;
    bcc call_old_irq                                                  ;

    ; check DisplayEnd interrupt (vsync)
    lsr                                                               ;
    lsr                                                               ;
    bcc check_rtc                                                     ;
    lsr irq_counter                                                   ; 0 indicates electron beam is in upper half of screen
    jmp every_vsync                                                   ;

check_rtc
    ; check RTC interrupt (at 100th scanline)
    lsr                                                               ;
    bcc call_old_irq                                                  ;
    rol irq_counter                                                   ; 1 indicates electron beam is in lower half of screen
    ; fall through to call_old_irq

call_old_irq
    lda irq_accumulator                                               ;
old_irq1
    jmp $0000                                                         ;

}

!if elk=0 {
; ----------------------------------------------------------------------------------
; Only uses A, preserves X,Y
irq_routine
    bit userVIAInterruptFlagRegister                                  ; get interrupt flag register
    bpl check_vsync                                                   ; if (not a user via interrupt) then branch

    bvc not_timer1
    ; At the entry point for the program we disabled every interrupt on the user via
    ; except for timer 1, so we know this must be a timer 1 interrupt. We clear it here.
    lda #$40                                                          ;
    sta userVIAInterruptFlagRegister                                  ; clear interrupt

    ; increment timing counter
    inc timing_counter                                                ;

    ; increment irq_counter by two (to count the number of character rows)
    lda irq_counter                                                   ;
    clc                                                               ;
    adc #2                                                            ;
    cmp #39                                                           ;
    bcc +                                                             ;
    lda #0                                                            ;
+
    sta irq_counter                                                   ;
irqret
    lda irq_accumulator                                               ;
    rti                                                               ;

not_timer1
    lda #$ff                                                          ;
    sta systemVIADirA                                                 ;
flipbranch
    bne +                                                             ;
    clc                                                               ;
    adc sound_10_volume_low                                           ;
+
    and #$df                                                          ;
    sta systemVIAOutA_NH                                              ;
    sta userVIATimer2CounterLow                                       ;
    lda #0                                                            ;
    sta systemVIAOutB                                                 ;
    lda engine_sound_shifter                                          ;
    cmp #$80                                                          ;
    rol engine_sound_shifter                                          ;
engine_sound_timer=*+1
    lda #$0d                                                          ; about 7ms
    bcc +                                                             ;
    asl                                                               ;
+
    sta userVIATimer2CounterHigh                                      ;
    ;lda rnd_1
    ;eor timing_counter
    ;beq +
    ;and #$1f
    ;and #$3f
engine_sound_randomness=*+1
    ora #$80                                                          ;
    sta userVIATimer2CounterLow                                       ;
    lda flipbranch                                                    ;
    eor #$20                                                          ;
    sta flipbranch                                                    ;
+
    lda #8                                                            ;
    sta systemVIAOutB                                                 ;
    bne irqret                                                        ;

; ----------------------------------------------------------------------------------
check_vsync
    lda systemVIAInterruptFlagRegister                                ; get interrupt flag register
    and #$82                                                          ;
    cmp #$82                                                          ; check for vsync
    bne call_old_irq                                                  ; if (not vsync) then branch

    ; Set timer to fire every 'short time' (set latch)
    lda #<ShortTimerValue                                             ;
    sta userVIATimer1LatchLow                                         ;
    lda #>ShortTimerValue                                             ;
    sta userVIATimer1LatchHigh                                        ;

    lda #34                                                           ; reset count of character rows
    sta irq_counter                                                   ; every vsync
    jmp every_vsync
}
call_old_irq
    lda irq_accumulator                                               ;
old_irq1
    jmp $0000                                                         ;

; ----------------------------------------------------------------------------------
; Do some things every frame rather than every game tick to improve perceived responsiveness:
; * update the static
; * flash the energy text and beep
every_vsync
    stx xtmp+1                                                        ;
    sty ytmp+1                                                        ;

    jsr flash_energy_when_low                                         ;
    lda scanner_failure_duration                                      ;
    beq skip_static                                                   ;
!if elk {
    ; only update the static every other frame
    lda flipbranch                                                    ;
    eor #$20                                                          ;
    sta flipbranch                                                    ;
flipbranch
    bne skip_static                                                   ;
}
draw_static
    jsr random_number_generator                                       ;
    tay                                                               ;
    ; most of the time we want white-ish noise as cheaply as we can make it
    ; but *occasionally* show bursts of periodic noise
    cpy #$10                                                          ;
    bcs white                                                         ;
    lda #update_static_loop-update_static_loop_end                    ;
    !byte $2c                                                         ; 'BIT abs' opcode, to skip the next instruction
white
    lda #update_static_loop_white-update_static_loop_end              ;
    sta update_static_loop_end-1                                      ;
    lda rnd_2                                                         ;
    ldx #$3f                                                          ;
update_static_loop_white
    eor random_data,x                                                 ;
update_static_loop
    eor random_data,y                                                 ;
    sta $5900,x                                                       ;
    ror                                                               ;
    sta $5e00,x                                                       ;
    eor random_data+$100,y                                            ;
    sta $61c0,x                                                       ;
    ror                                                               ;
    sta $5cc0,x                                                       ;
    eor random_data+$200,y                                            ;
    sta $5f40,x                                                       ;
    ror                                                               ;
    sta $5a40,x                                                       ;
    ror                                                               ;
    eor random_data+$300,y                                            ;
    sta $5b80,x                                                       ;
    ror                                                               ;
    sta $6080,x                                                       ;
    dex                                                               ;
    bpl update_static_loop                                            ;
update_static_loop_end
skip_static
xtmp
    ldx #0                                                            ;
ytmp
    ldy #0                                                            ;
    jmp call_old_irq                                                  ;

; ----------------------------------------------------------------------------------
; On Entry:
;   X is the index of the string to print
print_regular_string
    ldy regular_strings_table,x                                       ;
    dey                                                               ;
-
    lda regular_strings_table+1,x                                     ;
    jsr oswrch                                                        ;
    inx                                                               ;
    dey                                                               ;
    bne -                                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
move_to_next_byte
    inc lookup_low                                                    ;
    bne +                                                             ;
    inc lookup_high                                                   ;
+
    dec bytes_left                                                    ;
    bne get_byte                                                      ;

    ; done with this string
    pla                                                               ;
    pla                                                               ;
    rts                                                               ;

get_byte
    lda (lookup_low),y                                                ;
    sec                                                               ; set MSB
    ror                                                               ;
    bne resume_getting_bits                                           ; ALWAYS branch

; ----------------------------------------------------------------------------------
get_5_bits
    ldx #5                                                            ;
get_x_bits
    lda #0                                                            ;
    sta result                                                        ;
    lda lookup_byte                                                   ;
-
    lsr                                                               ; get result
    beq move_to_next_byte                                             ;
resume_getting_bits
    rol result                                                        ;
    dex                                                               ;
    bne -                                                             ;
    sta lookup_byte
    lda result                                                        ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
; On Entry:
;   X is the index of the string to print
print_compressed_string
    lda #<text_data                                                   ;
    sta lookup_low                                                    ;
    lda #>text_data                                                   ;
    sta lookup_high                                                   ;
    ldy #0                                                            ;
-
    lda (lookup_low),y                                                ;
    dex                                                               ;
    bmi ++                                                            ;
    clc                                                               ;
    adc lookup_low                                                    ;
    sta lookup_low                                                    ;
    bcc +                                                             ;
    inc lookup_high                                                   ;
+
    bne -                                                             ;

++
    sta bytes_left                                                    ;
    sty lookup_byte                                                   ; 0
print_compressed_loop
    jsr get_5_bits                                                    ;
    cmp #31                                                           ;
    beq token                                                         ;
    cmp #29                                                           ;
    beq extended1                                                     ;
    bcs extended2                                                     ;
    tax                                                               ;
    lda text_header_data,x                                            ;
output_character
    jsr oswrch                                                        ;
    jmp print_compressed_loop                                         ;

extended1
    ldx #7
    !byte $2c                                                         ; 'BIT abs' opcode, to skip the next instruction
extended2
    ldx #5                                                            ;
    jsr get_x_bits                                                    ;
    bcc output_character                                              ; ALWAYS branch

token
    jsr get_5_bits                                                    ;
    sec                                                               ;
    sbc #$100 - award_you_the_order_of_the                            ;
    tax                                                               ;
    ldy #3                                                            ;
-
    lda lookup_low,y                                                  ;
    pha                                                               ;
    dey                                                               ;
    bpl -                                                             ;
    jsr print_compressed_string                                       ;
    ldy #0                                                            ;
-
    pla                                                               ;
    sta lookup_low,y                                                  ;
    iny                                                               ;
    cpy #4                                                            ;
    bne -                                                             ;
    ldy #0                                                            ;
    beq print_compressed_loop                                         ; ALWAYS branch

; ----------------------------------------------------------------------------------
eor_two_play_area_pixels
    ldy y_pixels                                                      ;
eor_two_play_area_pixels_ycoord_in_y
    lda play_area_row_table_high,y                                    ;
    sta screen_address_high                                           ;
    lda row_table_low,y                                               ;
    sta screen_address_low                                            ;
eor_two_play_area_pixels_same_y
    ldy xandf8,x                                                      ;
    lda xbit_table,x                                                  ;
    lsr                                                               ;
    bcs straddle                                                      ;
    ora xbit_table,x                                                  ;
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    rts                                                               ;
straddle
    lda #1                                                            ;
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    inx                                                               ; second pixel is off screen?
    beq returna                                                       ;
    lda #$80                                                          ;
    ldy xandf8,x                                                      ;
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
returna
    dex                                                               ; restore
    rts                                                               ;

; ----------------------------------------------------------------------------------
; things we need during the loader must go after here
; ----------------------------------------------------------------------------------
post_reloc
    ; MODE 4
    lda #22                                                           ;
    ldy #4                                                            ;
    jsr oswrch_ay                                                     ;

!if tape {
    ; frontiers loading screen
    jsr init_frontier_screen                                          ;

    ; show initial loading text
    ldx #0                                                            ;
-
    lda loader_string,x                                               ;
    jsr oswrch                                                        ;
    inx                                                               ;
    cpx #$32                                                          ;
    bne -                                                             ;
    jsr finish_screen                                                 ;

    ; show rest of message progressively over time, then update the timer display
loader_stars_loop
loader_string_count
    ldx #0                                                            ;
    cpx #$de                                                          ;
    beq +                                                             ;
    lda loader_string+$32,x                                           ;
    jsr oswrch                                                        ;
    inc loader_string_count+1                                         ;
    bne ++                                                            ;
+
    ; update the timer display
    ldx #18                                                           ;
    ldy #12                                                           ;
    jsr tab_to_x_y                                                    ;
    ldx #0                                                            ;
-
    lda time_left,x                                                   ;
    ora #48                                                           ;
    jsr oswrch                                                        ;
    inx                                                               ;
    cpx #4                                                            ;
    bne -                                                             ;

++
    ; update the globe
    jsr update_frontier_stars                                         ;

    ; loop until everything has loaded
    lda part_number                                                   ;
    bne loader_stars_loop                                             ;

    ; do any remaining initialisation
    jsr init_late                                                     ;

    ; continue with the globe spinning
    jmp print_string_after_loading                                    ;
} else {
    ; if on disk, do the regular globe initialisation
    jmp start                                                         ;
}

print_string_and_finish_screen
    jsr print_compressed_string                                       ;
finish_screen
    jsr plot_underscores_at_0_3                                       ;
screen_on_and_flush
    jsr screen_on                                                     ;
flush
    lda #osbyte_flush_buffer_class                                    ;
    ldx #1                                                            ;
    jmp (bytev)                                                       ;

; ----------------------------------------------------------------------------------
plot_underscores_at_0_3
    ldy #0                                                            ;
    jsr plot_line_of_underscores_at_y                                 ;
    ldy #3                                                            ;
plot_line_of_underscores_at_y
    ldx #0                                                            ;
    jsr tab_to_x_y                                                    ;
plot_line_of_underscores_raw
    ldy #$28                                                          ; loop counter
plot_line_of_underscores_loop
    lda #'_'                                                          ; underscore
    jsr oswrch                                                        ;
    dey                                                               ;
    bne plot_line_of_underscores_loop                                 ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
!if (elk=0) {
    ; BBC/Master
screen_off
    lda #$f0                                                          ;
    jsr writeR8                                                       ;
    lda #12                                                           ;
    jmp oswrch                                                        ;

screen_on_with_cursor
    lda #0                                                            ;
    !byte $2c                                                         ; 'BIT abs' opcode, to skip the next instruction
screen_on
    lda #$c0                                                          ;
writeR8
    pha                                                               ;
    lda #19                                                           ;
    jsr osbyte                                                        ;
    ldx #8                                                            ;
    pla                                                               ;
    ora vduInterlaceValue                                             ; OR in TV interlace
    sei                                                               ;
    stx $fe00                                                         ;
    sta $fe01                                                         ;
    cli                                                               ;
    rts                                                               ;
} else {
    ; Electron
screen_off
    lda #$ff                                                          ;
    ldx #$10                                                          ;
    jsr writepal                                                      ;
    jmp $cb9d                                                         ; clear screen

screen_on_with_cursor
    ldx #0                                                            ;
    !byte $2c                                                         ; 'BIT abs' opcode, to skip the next instruction
screen_on
    ldx #$10                                                          ;
    lda #$11                                                          ;
writepal
    stx $d0                                                           ;
    sta $804                                                          ;
    sta $805                                                          ;
    ldy verticalSyncCounter                                           ;
-
    cpy verticalSyncCounter                                           ;
    beq -                                                             ;
    sta $fe08                                                         ;
    sta $fe09                                                         ;
    rts
fastwrch
    ; we deliberately don't save A here as it's rarely required
    stx xtmp2+1                                                       ;
    sty ytmp2+1                                                       ;
    jsr $c433                                                         ;
xtmp2
    ldx #0                                                            ;
ytmp2
    ldy #0                                                            ;
    rts                                                               ;
}

; ----------------------------------------------------------------------------------
init_frontier_screen
    ; initialise stars for frontiers rotating globe

    ; initialise the constant x coordinates
    lda #$5e                                                          ;
    ldx #0                                                            ;
    stx starship_rotation_eor                                         ;
    jsr init_first_frontier_coord                                     ;
    ldy #31                                                           ;
-
    jsr init_frontier_x_coord                                         ;
    dey                                                               ;
    bpl -                                                             ;
-
    iny                                                               ;
    jsr init_frontier_x_coord                                         ;
    bpl -                                                             ;

    ; initialise the star positions themselves
    jsr initialise_frontier_stars                                     ;

    jsr screen_off                                                    ;

    ; start rotating stars
    lda #maximum_number_of_frontier_stars                             ;
    sta maximum_number_of_stars                                       ;
    lda #1                                                            ;
    sta starship_velocity_high                                        ;
    sta starship_velocity_low                                         ;
    lda #$85                                                          ;
    sta starship_rotation                                             ;
    lda #5                                                            ;
    sta starship_rotation_magnitude                                   ;
!if tape {
    lda #$ce                                                          ;
    sta starship_rotation_cosine                                      ;
    lda #$0a                                                          ;
    sta starship_rotation_sine_magnitude                              ;
}
    ; fall through

    ; initialise stars update code to use frontier stars
    dec num_frontier_star_updates                                     ; plot performs a rotation
    lda #<eor_frontier_pixel                                          ;
    ldy #index_of_frontier_stars                                      ;
    !byte $2c                                                         ; 'BIT abs' opcode, to skip the next instruction
plot_and_rotate_in_game_stars
    lda #<eor_play_area_pixel                                         ;
    sta maybe_unplot_star+1                                           ;
    sta plot_star+1                                                   ;

    ; plot but don't unplot (for this first update)
    lda #$2c                                                          ; 'BIT abs' opcode
    sta maybe_unplot_star                                             ; to skip unplotting

    ; update and plot the stars
    jsr update_stars                                                  ;

    ; from now on, unplot and plot
    lda #$20                                                          ; 'JSR abs' opcode
    sta maybe_unplot_star                                             ;

    rts                                                               ;

; ----------------------------------------------------------------------------------
update_stars
    sty current_object_index                                          ;
    lda maximum_number_of_stars                                       ;
    sta stars_still_to_consider                                       ;
update_stars_loop
    ldy current_object_index                                          ;
    jsr update_object_position_for_starship_rotation_and_speed        ;
    ldx x_pixels                                                      ;
maybe_unplot_star
    jsr eor_play_area_pixel                                           ; unplot. Target of self modifying code.
    ldy current_object_index                                          ;
    ldx object_table_xpixels,y                                        ;
    lda object_table_ypixels,y                                        ;
    sta y_pixels                                                      ;
plot_star
    jsr eor_play_area_pixel                                           ; plot. Target of self modifying code.
    inc current_object_index                                          ;
    dec stars_still_to_consider                                       ;
    bne update_stars_loop                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
update_frontier_stars
    ; each full rotation of the globe, we reset the stars to stop them drifting out of alignment over time.
    ldy #index_of_frontier_stars                                      ;
    dec num_frontier_star_updates                                     ;
    bne update_stars                                                  ;
    ; fall through...

; ----------------------------------------------------------------------------------
initialise_frontier_stars
    ldy #index_of_frontier_stars                                      ;
    sty current_object_index                                          ;
    ldx #0                                                            ;
initialise_stars_loop
    lda frontier_star_positions_x,x                                   ;
    sta object_table_xpixels,y                                        ;
    lda frontier_star_positions_y,x                                   ;
    sta object_table_ypixels,y                                        ;
    lda #$80                                                          ;
    sta object_table_xfraction,y                                      ;
    sta object_table_yfraction,y                                      ;
    iny                                                               ;
    inx                                                               ;
    bpl initialise_stars_loop                                         ;

    ; number of updates before re-initialising the stars again
    lda #162                                                          ;
    sta num_frontier_star_updates                                     ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
; From https://codebase64.org/doku.php?id=base:seriously_fast_multiplication
; Calculate A*X with the product returned in prod_low(low) and A (high)
; unsigned.
; Preserves Y
; ----------------------------------------------------------------------------------
;mul8x8
;    sta sm1                                                           ;
;    sta sm3                                                           ;
;    eor #$ff                                                          ;
;    sta sm2                                                           ;
;    sta sm4                                                           ;
;
;    sec                                                               ;
;sm1 = * + 1
;    lda squares1_low,x                                                ;
;sm2 = * + 1
;    sbc squares2_low,x                                                ;
;    sta prod_low                                                      ;
;sm3 = * + 1
;    lda squares1_high,x                                               ;
;sm4 = * + 1
;    sbc squares2_high,x                                               ;
;    rts                                                               ;

; ----------------------------------------------------------------------------------
; Set (output_fraction, output_pixels) = starship_rotation_sine * position (16 bits)
;
; Given a signed 8.8 fixed point number 'b.a', and an 8 bit number 'c'
; calculate the product 'b.a * c' with the result in 8.8 fixed point 'output_fraction . output_pixels'
;
; Method:
;
; (c.a)*b = ((a+256*c)*b)/256 = (a*b)/256 + c*b
;
; We calculate a*b as a 16 bit number and just take the top byte, call this t
; then we calculate c*b as a 16 bit number and add t
;
; here b = starship_rotation_sine_magnitude
;      a = x register
;
; On Entry:
;   X = low byte of position  (one coordinate)
;   Y = high byte of position (one coordinate)
; On Exit:
;   output_pixels (low) and output_fraction (high)
; ----------------------------------------------------------------------------------
multiply_object_position_by_starship_rotation_sine_magnitude
    ; 8 bit multiply starship_rotation_sine_magnitude * x into A register (the high byte)
sm_sine_a1 = * + 1
    lda squares1_low+$0a,x                                            ;
    sec                                                               ;
sm_sine_a2 = * + 1
    sbc squares2_low+$f5,x                                            ;
sm_sine_a3 = * + 1
    lda squares1_high+$0a,x                                           ;
sm_sine_a4 = * + 1
    sbc squares2_high+$f5,x                                           ;

    tax                                                               ; X = store the high byte 't'

    ; 8 bit multiply 'Y * starship_rotation_sine_magnitude', result in A register (high byte) and prod_low
sm_sine_b1 = * + 1
    lda squares1_low+$0a,y                                            ;
    ;sec ; C is already set                                           ;
sm_sine_b2 = * + 1
    sbc squares2_low+$f5,y                                            ;
    sta prod_low                                                      ;
sm_sine_b3 = * + 1
    lda squares1_high+$0a,y                                           ;
sm_sine_b4 = * + 1
    sbc squares2_high+$f5,y                                           ;
    sta output_fraction                                               ;
    txa                                                               ; recall 't'
    clc
    adc prod_low                                                      ;
    sta output_pixels                                                 ;
    bcc +                                                             ;
    inc output_fraction                                               ;
+
    rts                                                               ;

; ----------------------------------------------------------------------------------
; On Entry:
;   X = low byte of position 'fraction' (one coordinate)
;   Y = high byte of position 'pixels'  (one coordinate)
; On Exit:
;   Result in A (low byte) and temp8 (high byte)
;   Preserves X,Y
; ----------------------------------------------------------------------------------
multiply_object_position_by_starship_rotation_cosine
    ;cpy #0 ; Z is already set
    beq shortcut                                                      ;

    stx temp_x                                                        ;
    sty temp8                                                         ;

    ; 8x8 multiply 'Y * starship_rotation_cosine', result in A (high byte only needed)
sm_cosine_a1 = * + 1
    lda squares1_low+$ce,y                                            ;
    sec                                                               ;
sm_cosine_a2 = * + 1
    sbc squares2_low+$31,y                                            ;
sm_cosine_a3 = * + 1
    lda squares1_high+$ce,y                                           ;
sm_cosine_a4 = * + 1
    sbc squares2_high+$31,y                                           ;

;    sec ; C is already set                                           ;
    sbc temp8                                                         ;
;    bcs +                                                            ;
;    dec temp8                                                        ;
;+
;    clc ; C is already clear                                         ;
    adc temp_x                                                        ;
    bcs return1                                                       ;
;    inc temp8                                                        ;
    dec temp8                                                         ;
return1
    rts                                                               ;

shortcut
    tya                                                               ; zero
    sta temp8                                                         ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
; Preserves Y
update_object_position_for_starship_rotation_and_speed
    ; Rotate object by starship rotation
    lda object_table_xfraction,y                                      ;
    eor starship_rotation_eor                                         ;
    sta object_x_fraction                                             ;
    lda object_table_xpixels,y                                        ;
    sta x_pixels                                                      ; remember old x pixel position
    eor starship_rotation_eor                                         ;
    sta object_x_pixels                                               ;

    lda object_table_yfraction,y                                      ;
    sta object_y_fraction                                             ;
    lda object_table_ypixels,y                                        ;
    sta y_pixels                                                      ; remember old y pixel position
    sta object_y_pixels                                               ;

skip_inversion
    ldx starship_rotation_sine_magnitude                              ;
    beq add_starship_velocity_to_position                             ;
    ; fall through...

; ----------------------------------------------------------------------------------
update_position_for_rotation
    sty temp_y                                                        ; remember Y

    ; X' = Y*sine + X*cosine
    ldx object_y_fraction                                             ;
    tay
;    ldy object_y_pixels                                               ;
    jsr multiply_object_position_by_starship_rotation_sine_magnitude  ;
    ldx object_x_fraction                                             ;
    ldy object_x_pixels                                               ;
    jsr multiply_object_position_by_starship_rotation_cosine          ;
    clc                                                               ;
    adc output_pixels                                                 ; sine_y_fraction
    sta temp9                                                         ; cosine_x_plus_sine_y_fraction
    lda temp8                                                         ; cosine_x_pixels
    adc output_fraction                                               ; sine_y_pixels
    sta temp10                                                        ; cosine_x_plus_sine_y_pixels

    ; Y' = Y*cosine - X*sine

;    These assignments are not needed since X,Y are still set to these values:
;    ldx object_x_fraction                                             ;
;    ldy object_x_pixels                                               ;
    jsr multiply_object_position_by_starship_rotation_sine_magnitude  ;
    ldx object_y_fraction                                             ;
    ldy object_y_pixels                                               ;
    jsr multiply_object_position_by_starship_rotation_cosine          ;
    sec                                                               ;
    sbc output_pixels                                                 ; sine_x_fraction
    sta object_y_fraction                                             ;
    lda temp8                                                         ; cosine_y_pixels
    sbc output_fraction                                               ; sine_x_pixels
    sta object_y_pixels                                               ;

    ; do correction for X
    ldx starship_rotation_magnitude                                   ;
    lda temp9                                                         ; cosine_x_plus_sine_y_fraction
    sec                                                               ;
    sbc rotated_x_correction_lsb,x                                    ;
    eor starship_rotation_eor
    sta object_x_fraction                                             ;

    lda temp10                                                        ; cosine_x_plus_sine_y_pixels
    sbc rotated_x_correction_screens,x                                ;
    eor starship_rotation_eor
    sta object_x_pixels                                               ;

    ; do correction for Y
    lda object_y_fraction                                             ;
    clc                                                               ;
    adc rotated_y_correction_lsb,x                                    ;
    sta object_y_fraction                                             ;

    lda object_y_pixels                                               ;
    adc rotated_y_correction_screens,x                                ;
    sta object_y_pixels                                               ;

    ldy temp_y                                                        ; recall Y
    ; fall through...

; ----------------------------------------------------------------------------------
add_starship_velocity_to_position
    ; add velocity and write back to object
    lda object_y_fraction                                             ;
    clc                                                               ;
    adc starship_velocity_low                                         ;
    sta object_table_yfraction,y                                      ;

    lda object_y_pixels                                               ;
    adc starship_velocity_high                                        ;
    sta object_table_ypixels,y                                        ;

    lda object_x_pixels                                               ;
    sta object_table_xpixels,y                                        ;
    lda object_x_fraction                                             ;
    sta object_table_xfraction,y                                      ;
    rts

; ----------------------------------------------------------------------------------
rotated_x_correction_lsb
    !byte 0  , $ff, $fc, $f7, $f0, $e7                                ;

rotated_x_correction_screens
    !byte 0
rotated_y_correction_screens
    !byte 0, 1, 2, 3, 4, 5                                            ;

rotated_y_correction_lsb
    !byte 0  , 1  , 4  , 9  , $10, $19                                ;

rotated_x_correction_fraction
    !byte 0  , $fe, $ff, $fc, $fa, $f6                                ;
rotated_x_correction_pixels
    !byte 0  , $fe, $fb, $f6, $ef, $e6                                ;

rotated_y_correction_fraction
    !byte 1  , 0  , 2  , 0  , $ff, $fe                                ;
rotated_y_correction_pixels
    !byte 0  , 1  , 4  , 9  , $0f, $18                                ;

; ----------------------------------------------------------------------------------
; Plot a point, with boundary check
;
; Checks that the point we are about to plot is close to the centre of the object.
; If it isn't, it's because the point wrapped around from one side of the
; play area and back onto the other side.
;
; On Entry:
;   X        = x coordinate to plot
;   y_pixels = y coordinate to plot
;
; On Exit:
;   X is preserved
; ----------------------------------------------------------------------------------
eor_pixel_with_boundary_check
    ; boundary check X
    txa                                                               ;
    sec                                                               ;
    sbc temp10                                                        ;
    bcs +                                                             ;
    eor #$ff                                                          ;
+
    cmp #$20                                                          ;
    bcs return                                                        ;

    ; boundary check Y
    lda y_pixels                                                      ;
    sec                                                               ;
    sbc temp9                                                         ;
    bcs +                                                             ;
    eor #$ff                                                          ;
+
    cmp #$20                                                          ;
    bcs return                                                        ;
    ; fall through...

; ----------------------------------------------------------------------------------
; Plot a point (using 'exclusive or')
;
; On Entry:
;   X        = x coordinate to plot
;   y_pixels = y coordinate to plot
;
; On Exit:
;   X is preserved
; ----------------------------------------------------------------------------------
eor_play_area_pixel
    ldy y_pixels                                                      ;
eor_play_area_pixel_ycoord_in_y
    lda play_area_row_table_high,y                                    ;
    sta screen_address_high                                           ;
eor_pixel_entry
    lda row_table_low,y                                               ;
    sta screen_address_low                                            ;
eor_pixel_same_y
eor_play_area_pixel_same_y
    ldy xandf8,x                                                      ;
    lda xbit_table,x                                                  ;
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
return
    rts                                                               ;

; ----------------------------------------------------------------------------------
; version for the frontiers screen, offset stars by $0780
; ----------------------------------------------------------------------------------
eor_frontier_pixel
    lda y_pixels                                                      ;
    ;clc ; C is already clear
    adc #48                                                           ;
    tay                                                               ;
    bne eor_play_area_pixel_ycoord_in_y                               ;

; ----------------------------------------------------------------------------------
; version that plots to scanner area
; ----------------------------------------------------------------------------------
eor_pixel
    ldx x_pixels                                                      ;
eor_pixel_xcoord_in_x
    ldy y_pixels                                                      ;
    lda play_area_row_table_high,y                                    ;
    sta screen_address_high                                           ;
    inc screen_address_high                                           ;
    bne eor_pixel_entry                                               ;

!if >eor_frontier_pixel != >eor_play_area_pixel {
    !error "alignment error: ", eor_frontier_pixel, "!=", eor_play_area_pixel;
}

!if <eor_frontier_pixel = 0 {
    !error "alignment error";
}

!macro m_regular_strings {

regular_strings_table
shield_state_string1
    !byte shield_state_string1_end - shield_state_string1             ;
    !byte $1f, $22, $18                                               ;
    !text " ON "                                                      ;
shield_state_string1_end

; ----------------------------------------------------------------------------------
shield_state_string2
    !byte shield_state_string2_end - shield_state_string2             ;
    !byte $1f, $22, $18                                               ;
    !text " OFF"                                                      ;
shield_state_string2_end

; ----------------------------------------------------------------------------------
shield_state_string3
    !byte shield_state_string3_end - shield_state_string3             ;
    !byte $1f, $22, $18                                               ;
    !text "AUTO"                                                      ;
shield_state_string3_end

; ----------------------------------------------------------------------------------
energy_string
    !byte energy_string_end - energy_string
    !byte $1f, 33, 17                                                 ; TAB(33, 17)
    !text "ENERGY"                                                    ;
    !byte $19, 4, 8, 4, $ac, 1                                        ; MOVE 1032, 428
    !byte 5                                                           ; VDU 5
    !byte $31, 8, $0a                                                 ; "1"
    !byte $32, 8, $0a                                                 ; "2"
    !byte $33, 8, $0a                                                 ; "3"
    !byte $34                                                         ; "4"
    !byte 4                                                           ; VDU 4
    !byte $19,  4  ,  0  ,  4  ,  $fc, 2                              ; MOVE 1024, 764
    !byte $19,  5  ,  $ff,  4  ,  $fc, 2                              ; DRAW 1279, 764
    !byte $19,  5  ,  $ff,  4  ,  0  , 0                              ; DRAW 1279, 0
    !byte $19,  5  ,  0  ,  0  ,  0  , 0                              ; DRAW    0, 0
    !byte $19,  5  ,  0  ,  0  ,  $ff, 3                              ; DRAW    0, 1023
    !byte $19,  5  ,  $ff,  3  ,  $ff, 3                              ; DRAW 1023, 1023
    !byte $19,  5  ,  $ff,  3  ,  0  , 0                              ; DRAW 1023, 0
energy_string_end

; ----------------------------------------------------------------------------------
shields_string
    !byte shields_string_end - shields_string
    !byte $1f, 33, 2                                                  ; TAB(33, 2)
    !text "SHIELDS"                                                   ;
    !byte $1f, 35, 5                                                  ; TAB(35, 5)
    !text "ON"                                                        ;
shields_string_end

; ----------------------------------------------------------------------------------
; aka shields_off
blank_string
    !byte blank_string_end - blank_string
    !byte $1f, 33, 2                                                  ; TAB(33, 2)
    !text "       "                                                   ;
    !byte $1f, 35, 5                                                  ; TAB(35, 5)
    !text "  "                                                        ;
blank_string_end

; ----------------------------------------------------------------------------------
escape_capsule_launched_string
    !byte escape_capsule_launched_string_end - escape_capsule_launched_string
    !byte $1f, 33, 23                                                 ; TAB(33, 23); "ESCAPE"
    !text "ESCAPE"                                                    ; TAB(32.5,24);"CAPSULE"
    !byte $1f, 34, 24                                                 ; TAB(32, 25); "LAUNCHED"
    !text "    "                                                      ;
    !byte 5,25,4,$10,4,$ff,0                                          ;
    !text "CAPSULE"                                                   ;
    !byte 25,4,0,4,$df,0                                              ;
    !text "LAUNCHED"                                                  ;
    !byte 4
escape_capsule_launched_string_end

; ----------------------------------------------------------------------------------
command_string
    !byte command_string_end - command_string
    !byte $19, 4, $0f, 4, $a2, 0                                      ; MOVE &040f, &00a2
    !byte 5                                                           ; VDU 5
    !text "COMMAND"                                                   ;
command_string_end

; ----------------------------------------------------------------------------------
command_move_string
    !byte command_move_string_end - command_move_string
    !byte $19, 4                                                      ; MOVE &046f, &0081
command_move_string_horizontal_pos
    !byte $6f                                                         ;
    !byte 4, $81, 0                                                   ;
command_move_string_end

} ; end macro m_regular_strings

; ----------------------------------------------------------------------------------
regular_strings_start
    +m_regular_strings

regular_strings_end

; ----------------------------------------------------------------------------------
frontier_x_deltas
    !byte 4,0,4,4,1,3,3,2,2,4,2,1,3,3,1,3,2,0,3,3,0,2,2,1,1,1,1,1,1,1,0,1
init_frontier_x_coord
    clc                                                               ;
    adc frontier_x_deltas,y                                           ;
    sta frontier_star_positions_x,x                                   ;
    inx                                                               ;
init_first_frontier_coord
    sta frontier_star_positions_x,x                                   ;
    inx                                                               ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
tab_to_x_y
    lda #$1f                                                          ;
oswrch_axy
    jsr oswrch                                                        ;
    txa                                                               ;
oswrch_ay
    jsr oswrch                                                        ;
    tya                                                               ;
    jmp oswrch                                                        ;

; ----------------------------------------------------------------------------------
zero_objects
    lda #0                                                            ;
    tax                                                               ;
-
    sta object_tables_start,x                                         ;
    sta object_tables_start + 256,x                                   ;
    sta object_tables_end - 256,x                                     ;
    dex                                                               ;
    bne -                                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
; Everything from here is *only* used while loading
; ----------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------
init_late
    ; clear zp vars
    lda #0                                                            ;
    ldx #zp_end-zp_start                                              ;
-
    sta zp_start-1,x                                                  ;
    dex                                                               ;
    bne -                                                             ;

    ; and any other zp oddballs
    sta sound_needed_for_low_energy                                   ;
    sta energy_flash_timer                                            ;
    sta starship_torpedo_type                                         ;
    sta scanner_failure_duration                                      ;

    lda #$ca                                                          ;
    sta rnd_1                                                         ; seed random numbers
    lda #1                                                            ;
    sta rotation_damper                                               ; rotation dampers on by default
    sta starship_shields_active                                       ; for some reason this needs initializing
    lda #$ff                                                          ;
    sta starship_energy_divided_by_sixteen                            ; disable low energy flashing

    ; zero highscore table
    lda #0                                                            ;
    ldx #high_score_table_end - high_score_table                      ;
-
    sta high_score_table - 1,x                                        ;
    dex                                                               ;
    bne -                                                             ;

    ; zero object tables
    jsr zero_objects                                                  ;

!if (elk=0) or (elk+antiflicker=2) {
    ; set up timer
    lda #0                                                            ;
    sta timing_counter                                                ;
    sta irq_counter                                                   ;

    sei                                                               ;
}

!if elk {
    ; Electron
    ; page in keyboard ROM
    lda #8                                                            ;
    jsr $e3a0                                                         ;
} else {
    ; BBC/Master
!if rom_writes {
    ; page in BASIC to minimize the chance of scribbling over whatever may be in SWRAM
    lda basicROMNumber                                                ;
    sta $f4                                                           ;
    sta $fe30                                                         ;
}
}

!if elk=0 {
    ; enable timer 1 in free run mode (on the User VIA)
    lda #0                                                            ; Disable all interrupts on the User VIA
    sta userVIAInterruptEnableRegister                                ;
    lda #$c0                                                          ; Enable timer 1
    sta userVIAInterruptEnableRegister                                ; Interrupt enable register
    lda #$40                                                          ; Enable free run mode for timer 1
    sta userVIAAuxiliaryControlRegister                               ; Auxiliary control register
    sta userVIATimer2CounterHigh                                      ; poke timer 2
    lda #$99
    sta engine_sound_shifter
}

!if (elk=0) or (elk+antiflicker=2) {
    ; set up our own IRQ routine to increment a timer
    lda irq1_vector_low                                               ;
    sta old_irq1+1                                                    ;
    lda irq1_vector_high                                              ;
    sta old_irq1+2                                                    ;

    lda #<irq_routine                                                 ;
    sta irq1_vector_low                                               ;
    lda #>irq_routine                                                 ;
    sta irq1_vector_high                                              ;

    cli                                                               ;
}

 !if elk=0 {
   ; Set timer to fire every 'short time' (set latch)
    lda #<ShortTimerValue                                             ;
    sta userVIATimer1LatchLow                                         ;
    lda #>ShortTimerValue                                             ;
    sta userVIATimer1LatchHigh                                        ;

    ; Start the timer going
    lda #>ShortTimerValue                                             ;
    sta userVIATimer1CounterHigh                                      ;
}

    ; set_rdchv
    lda rdchv                                                         ;
    sta our_rdch+1                                                    ;
    lda rdchv+1                                                       ;
    sta our_rdch+2                                                    ;

    lda #<our_rdch                                                    ;
    sta rdchv                                                         ;
    lda #>our_rdch                                                    ;
    sta rdchv+1                                                       ;

!if tape {
    rts                                                               ;
} else {
    jmp post_reloc                                                    ;
}

; ----------------------------------------------------------------------------------
!if tape {
loader_copy_start
    !src "source/loader2.asm"                                         ;
loader_copy_end
}

; ----------------------------------------------------------------------------------
; Objects are
;
; When in game:
;
; 1 escape capsule              (5 bytes)
; 24 enemy torpedos             (24  * 6 = 144 bytes)
; 24 starship torpedo heads     (24  * 5 = 120 bytes)
; 24 starship torpedo tails     (24  * 4 =  96 bytes)
;                        TOTAL: 365 bytes
;
; Or, when in front end:
;
; 128 frontier stars            (128 * 4 = 512 bytes)

index_of_frontier_stars         = 0

index_of_escape_capsule         = 0
index_of_enemy_torpedoes        = index_of_escape_capsule + 1
index_of_starship_torpedo_heads = index_of_enemy_torpedoes + maximum_number_of_enemy_torpedoes
index_of_starship_torpedo_tails = index_of_starship_torpedo_heads + maximum_number_of_starship_torpedoes
index_of_in_game_stars          = index_of_starship_torpedo_tails + maximum_number_of_starship_torpedoes

max_in_game_objects = index_of_in_game_stars + maximum_number_of_stars_in_game

; This allows for all in game objects OR 128 frontier stars
max_objects = 128

object_tables_start

object_table_angle          = object_tables_start
object_table_time_to_live   = object_table_angle + 1 + maximum_number_of_enemy_torpedoes    ; only escape capsule and enemy torpedoes have an angle
object_table_xfraction      = object_table_time_to_live + index_of_in_game_stars            ; everything except the stars has a 'time to live'. Wow, that's deep.
object_table_xpixels        = object_table_xfraction    + max_objects                       ; every object has a position
object_table_yfraction      = object_table_xpixels      + max_objects
object_table_ypixels        = object_table_yfraction    + max_objects
object_tables_end           = object_table_ypixels      + max_objects

!if ((object_tables_end - object_tables_start) < $200) {
    !error "object table too small for initialisation code in init_late"
}
!if ((object_tables_end - object_tables_start) > $300) {
    !error "object table too big for initialisation code in init_late"
}

escape_capsule_on_screen  = object_table_time_to_live + index_of_escape_capsule
escape_capsule_x_fraction = object_table_xfraction    + index_of_escape_capsule
escape_capsule_x_pixels   = object_table_xpixels      + index_of_escape_capsule
escape_capsule_y_fraction = object_table_yfraction    + index_of_escape_capsule
escape_capsule_y_pixels   = object_table_ypixels      + index_of_escape_capsule

free_space = $5800 - object_tables_end
!if (object_tables_end > $5800) {
    !error "code overflowed by ", object_tables_end-$5800, " bytes"
}

entry_point
; ----------------------------------------------------------------------------------
; Everything from here is *only* used while loading *before* 'MODE 4' wipes $5800 upwards
; ----------------------------------------------------------------------------------
init_early
    ldx #$ff                                                          ; we want all the stack
    txs                                                               ;
    lda #234                                                          ; disable tube
    jsr osbyte_zeroxy                                                 ;
    lda #200                                                          ; clear memory
    ldx #3                                                            ; on break
    jsr osbyte_zeroy                                                  ;
!if tape=0 {
    lda #140                                                          ; *TAPE
    jsr osbyte_zeroxy                                                 ;
}
    lda #143                                                          ; claim NMI vector
    ldx #12                                                           ; so we can safely use
    ldy #255                                                          ; page D
    jsr osbyte                                                        ; (and also A0-A7)
    lda #$40                                                          ; 'RTI' opcode
    sta nmi_routine                                                   ; store at $0d00
    lda #133                                                          ; read HIMEM were we to
    ldx #4                                                            ; switch into MODE 4
    jsr osbyte_zeroy                                                  ;
    tya                                                               ;
    bpl noshadow                                                      ; if it's >$7FFF we need to
    lda #114                                                          ; disable shadow screen
    ldx #1                                                            ; (we can't do this unconditionally
    jsr osbyte_zeroy                                                  ; because it's not implemented
noshadow                                                              ; on earlier machines)

    ; set beep sound to sound_6 why not
    ; hopefully players will have learned to avoid doing
    ; things that make this sound :)
    lda #$12                                                          ;
    sta soundBELLChannel                                              ;
    lda #$18                                                          ;
    sta soundBELLAmplitudeEnvelope                                    ;
    lda #$bc                                                          ;
    sta soundBELLPitch                                                ;
    ; because bit 4 of channel is not respected we need to set duration as short as possible,
    ; except on the Electron, where this cuts off the sound prematurely.
!if elk {
    lda #$3                                                           ;
} else {
    lda #$1                                                           ;
}
    sta soundBELLDuration                                             ;

    lda #11                                                           ; disable key repeat
    ldx #0                                                            ;
    ldy #0                                                            ;
    jsr osbyte                                                        ;
    lda #'0'                                                          ; function keys
    sta functionAndCursorKeyCodes + 4                                 ; generate ASCII 0-9
    sta functionAndCursorKeyCodes + 5                                 ;
    sta functionAndCursorKeyCodes + 6                                 ;
    sta functionAndCursorKeyCodes + 7                                 ;
    lda #osbyte_set_cursor_editing                                    ; cursor keys
    ldx #1                                                            ; generate ASCII
    jsr osbyte                                                        ; 136-139

!if tape {
    ; copy tape loader code into page 5
    ; !warn "loader len = ",loader_end-loader_start
    ldy #loader_end-loader_start                                      ;
-
    lda loader_copy_start-1,y                                         ;
    sta loader_start-1,y                                              ;
    dey                                                               ;
    bne -                                                             ;

    ; start the animated loading
    jsr irqdecr_init                                                  ;
}
    ; fall through...

; ----------------------------------------------------------------------------------
; routine to create tables of squares
; from https://codebase64.org/doku.php?id=base:table_generator_routine_for_fast_8_bit_mul_table
; ----------------------------------------------------------------------------------
create_square_tables
    ldx #0                                                            ;
    txa                                                               ;
    !byte $c9                                                         ; 'CMP #immediate' opcode - skip TYA and clear carry flag
lb1
    tya                                                               ;
    adc #0                                                            ;
ml1
    sta squares1_high,x                                               ;
    tay                                                               ;
    cmp #$40                                                          ;
    txa                                                               ;
    ror                                                               ;
ml9
    adc #0                                                            ;
    sta ml9+1                                                         ;
    inx                                                               ;
ml0
    sta squares1_low,x                                                ;
    bne lb1                                                           ;
    inc ml0+2                                                         ;
    inc ml1+2                                                         ;
    clc                                                               ;
    iny                                                               ;
    bne lb1                                                           ;

    ; create second table of squares
    ldx #$00                                                          ;
    ldy #$ff                                                          ;
-
    lda squares1_high + 1,x                                           ;
    sta squares2_high + $100,x                                        ;
    lda squares1_high,x                                               ;
    sta squares2_high,y                                               ;
    lda squares1_low + 1,x                                            ;
    sta squares2_low + $100,x                                         ;
    lda squares1_low,x                                                ;
    sta squares2_low,y                                                ;
    dey                                                               ;
    inx                                                               ;
    bne -                                                             ;
    ; fall through...

; ----------------------------------------------------------------------------------
create_other_tables
    ; create xandf8 table
    ;    !for i, 0, 255 {
    ;        !byte (i & $f8)
    ;    }
    ldx #0                                                            ;
-
    txa                                                               ;
    and #$f8                                                          ;
    sta xandf8,x                                                      ;
    inx                                                               ;
    bne -                                                             ;

    ; create xbit_table:
    ;    !for i, 0, 255 {
    ;        !byte $80 >> (i & 7)
    ;    }
    ;
    ; and xinverse_bit_table:
    ;    !for i, 0, 255 {
    ;        !byte ($80 >> (i & 7)) XOR 255
    ;    }
    lda #$80                                                          ;
    ldx #0                                                            ;
-
    sta xbit_table,x                                                  ;
    lsr                                                               ;
    bcc +                                                             ;
    lda #$80                                                          ;
+
    inx                                                               ;
    bne -                                                             ;

    ; make row tables:
    ; row_table_low
    ;     !for i, 0, 255 {
    ;         !byte <((i & 7) + (i/8) * $0140)
    ;     }
    ; play_area_row_table_high
    ;     !for i, 0, 255 {
    ;         !byte >($5800 + (i & 7) + (i/8) * $0140)
    ;     }

    ldy #0                                                            ;
    lda #$58                                                          ;
row_table_loop2
    ldx #7                                                            ;
row_table_loop
    sty row_table_low                                                 ;
    sta play_area_row_table_high                                      ;
    iny                                                               ;
    inc row_table_loop+1                                              ;
    inc row_table_loop+4                                              ;
    dex                                                               ;
    bpl row_table_loop                                                ;
    pha                                                               ;
    tya                                                               ;
    clc                                                               ;
    adc #$38                                                          ;
    tay                                                               ;
    pla                                                               ;
    adc #1                                                            ;
    bpl row_table_loop2                                               ;

!if tape {
    ; copy strings for the loader
    ldx #0                                                            ;
-
    lda loader_string_copy,x                                          ;
    sta loader_string,x                                               ;
    lda loader_string_copy+$100,x                                     ;
    sta loader_string+$100,x                                          ;
    inx                                                               ;
    bne -                                                             ;
}
    jsr initialise_envelopes                                          ;

    ; copy frontier stars to low in memory
    ldx #maximum_number_of_frontier_stars                             ;
-
    lda copy_frontier_star_positions_y - 1,x                          ;
    sta frontier_star_positions_y - 1,x                               ;
    dex                                                               ;
    bne -                                                             ;

!if tape {
    ; wait for first part to load from tape before starting the globe spinning
-
    lda #1                                                            ;
    cmp part_number                                                   ;
    bne -                                                             ;

    ; start the globe spinning
    jmp post_reloc                                                    ;
} else {
    jmp init_late                                                     ;
}

osbyte_zeroxy
    ldx #0                                                            ;
osbyte_zeroy
    ldy #0                                                            ;
    jmp (bytev)                                                       ;

; ----------------------------------------------------------------------------------
regular_string_index_shield_state_on            = shield_state_string1 - regular_strings_table
regular_string_index_shield_state_off           = shield_state_string2 - regular_strings_table
regular_string_index_shield_state_auto          = shield_state_string3 - regular_strings_table
regular_string_index_energy_string              = energy_string - regular_strings_table
regular_string_index_shields_on                 = shields_string - regular_strings_table
regular_string_index_shields_off                = blank_string - regular_strings_table
regular_string_index_escape_capsule_launched    = escape_capsule_launched_string - regular_strings_table

regular_string_index_command                    = command_string - regular_strings_table
regular_string_index_command_move               = command_move_string - regular_strings_table

; ----------------------------------------------------------------------------------
initialise_envelopes
    ldx #<(envelope1)                                                 ;
    ldy #>(envelope1)                                                 ;
    lda #osword_envelope                                              ;
    jsr osword                                                        ;
    ldx #<(envelope2)                                                 ;
    ldy #>(envelope2)                                                 ;
    lda #osword_envelope                                              ;
    jsr osword                                                        ;
    ldx #<(envelope3)                                                 ;
    ldy #>(envelope3)                                                 ;
    lda #osword_envelope                                              ;
    jsr osword                                                        ;
    ldx #<(envelope4)                                                 ;
    ldy #>(envelope4)                                                 ;
    lda #osword_envelope                                              ;
    jmp osword                                                        ;

; ----------------------------------------------------------------------------------
copy_frontier_star_positions_y
    ; this defines a 'globe' of 128 stars. X positions are calculated
    !byte $80, $78, $7D, $83, $88, $70, $90, $73
    !byte $8D, $7B, $85, $69, $97, $6E, $92, $79
    !byte $87, $62, $9E, $6A, $96, $5B, $77, $89
    !byte $A5, $66, $9A, $56, $75, $8B, $AA, $62
    !byte $9E, $50, $B0, $74, $8C, $5F, $A1, $4C
    !byte $B4, $73, $8D, $5C, $A4, $49, $B7, $72
    !byte $8E, $5A, $A6, $46, $BA, $71, $8F, $59
    !byte $A7, $45, $BB, $58, $71, $8F, $A8, $44
    !byte $BC, $58, $71, $8F, $A8, $45, $BB, $59
    !byte $A7, $71, $8F, $46, $BA, $5A, $A6, $72
    !byte $8E, $49, $B7, $5C, $A4, $73, $8D, $4C
    !byte $B4, $5F, $A1, $74, $8C, $50, $B0, $62
    !byte $9E, $56, $75, $8B, $AA, $66, $9A, $5B
    !byte $77, $89, $A5, $6A, $96, $62, $9E, $79
    !byte $87, $6E, $92, $69, $97, $7B, $85, $73
    !byte $8D, $70, $90, $78, $7D, $83, $88, $80

; ----------------------------------------------------------------------------------
; Envelope 1, used by sound_3 (Starship fired torpedo)
envelope1
    !byte 1, 0  , $f8, $fa, $0f, 4  , $0a, 8  , $7f, $fe, $fc, $ff, $7e, $64

; Envelope 2, used by sound_4 (Enemy ship fired torpedo),
;                 and sound_7 (Enemy ships colliding with each other)
envelope2
    !byte 2, 0  , $f8, $fa, $fe, 4  , $0a, 8  , $7f, $fe, $ff, $ff, $64, $50

; Envelope 3, used by sound_11 (Exploding enemy ship)
envelope3
    !byte 3, $86, $ff, 0  , 1  , 3  , 1  , 2  , $7f, $ff, $fd, $fd, $7e, $78

; Envelope 4, used by sound_5 (Enemy ship hit by torpedo)
;                 and sound_6 (Starship hit by torpedo)
envelope4
    !byte 4, 0  , $10, $f0, $10, 4  , 8  , 4  , $7f, $ff, $ff, $ff, $7e, $64

; ----------------------------------------------------------------------------------

!if tape {
loader_string_copy
    !bin "build/text.o"
}
eof
