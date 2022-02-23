; ----------------------------------------------------------------------------------
;
; Starship Command (the original BBC Micro version)
;
; Disassembled by TobyLobster using the py8dis tool.
; Based on the labels from the Level 7 disassembly (http://www.level7.org.uk/miscellany/starship-command-disassembly.txt)
;
; ----------------------------------------------------------------------------------

osword_envelope = $08
osbyte_inkey = $81
inkey_key_delete = $a6
osword_sound = $07
osbyte_select_adc_channels = $10
osbyte_set_cursor_editing = $04
osbyte_flush_buffer_class = $0f
osbyte_acknowledge_escape = $7e
osword_read_line = $00
osbyte_read_adc_or_get_buffer_status = $80

; for multiply routines
a                       = $00
b                       = $01
c                       = $02
z                       = $03
new                     = $04
addition                = $05
temp_m2                 = $06
prod_low                = $07
t                       = $08

starship_velocity_high              = $09
starship_velocity_low               = $0a
starship_rotation                   = $0b
starship_rotation_magnitude         = $0c
starship_rotation_cosine            = $0d
starship_rotation_sine_magnitude    = $0e


screen_address_low      = $70
screen_address_high     = $71
output_pixels           = $72
output_fraction         = $73
segment_length          = $74
temp8                   = $75
temp9                   = $76
temp10                  = $77
segment_angle           = $78
screen_start_high       = $79
x_pixels                = $7a
y_pixels                = $7b
temp11                  = $7c
temp0_low               = $80
temp0_high              = $81
temp1_low               = $82
temp1_high              = $83
temp3                   = $84
temp4                   = $85
temp5                   = $86
temp6                   = $87
temp7                   = $88

enemy_ships_previous_on_screen          = $0400
enemy_ships_previous_x_fraction         = $0401
enemy_ships_previous_x_pixels           = $0402
enemy_ships_previous_x_screens          = $0403
enemy_ships_previous_x_fraction1        = $0404
enemy_ships_previous_x_pixels1          = $0405
enemy_ships_previous_x_screens1         = $0406
enemy_ships_previous_angle              = $0407
enemy_ships_velocity                    = $0408
enemy_ships_flags_or_explosion_timer    = $0409
enemy_ships_type                        = $040a

enemy_ships_on_screen                   = $0480
enemy_ships_x_fraction                  = $0481
enemy_ships_x_pixels                    = $0482
enemy_ships_x_screens                   = $0483
enemy_ships_x_fraction1                 = $0484
enemy_ships_x_pixels1                   = $0485
enemy_ships_x_screens1                  = $0486
enemy_ships_angle                       = $0487
enemy_ships_temporary_behaviour_flags   = $0488
enemy_ships_energy                      = $0489
enemy_ships_firing_cooldown             = $048a

user_defined_characters                 = $0c00

starship_top_screen_address             = $6b38
starship_bottom_screen_address          = $6c78
energy_screen_address                   = $6e48

oswrch = $ffee
osword = $fff1
osbyte = $fff4

* = $1f00

!pseudopc $0e00 {
enemy_ship_was_previously_on_screen
    !byte 1                                                           ;
enemy_ship_was_on_screen
    !byte 1                                                           ;
additional_damage_from_collision_with_enemy_ship
    !byte $c0                                                         ;
damage_enemy_ship_incurs_from_collision_with_other_enemy_ship
    !byte $20                                                         ;
starship_angle_fraction
    !byte $c4                                                         ;
starship_angle_delta
    !byte $ff                                                         ;
damage_to_enemy_ship_from_starship_torpedo
    !byte $10                                                         ;
maximum_number_of_explosions
    !byte 8                                                           ;
value_used_for_enemy_torpedo_ttl
    !byte $20                                                         ;
frame_of_enemy_ship_explosion_after_which_no_collisions
    !byte $1b                                                         ;
frame_of_enemy_ship_explosion_after_which_no_segments_are_plotted
    !byte $23                                                         ;
enemy_ship_explosion_duration
    !byte $25                                                         ;
size_of_enemy_ship_for_collisions_with_torpedoes
    !byte 5                                                           ;
size_of_enemy_ship_for_collisions_between_enemy_ships
    !byte 8  , $4d                                                    ;
starship_torpedo_tail_table_address_low
    !byte <(starship_torpedoes_table+4)                               ;
starship_torpedo_tail_table_address_high
    !byte >(starship_torpedoes_table+4)                               ;
maximum_number_of_enemy_ships
    !byte 8                                                           ;
maximum_number_of_stars
    !byte $11                                                         ;
maximum_number_of_starship_torpedoes
    !byte $0c                                                         ;
maximum_number_of_enemy_torpedoes
    !byte $18                                                         ;
starship_torpedoes_time_to_live
    !byte $0f                                                         ;
enemy_ships_still_to_consider
    !byte 0                                                           ;
torpedoes_still_to_consider
    !byte 0                                                           ;
starship_shields_active
    !byte 1                                                           ;
cosine_table
    !byte $fa, $fa, $fb, $fb, $fc, $fd, $fe, $ff                      ; overlaps with sine table
sine_table
    !byte 0  , 1  , 2  , 3  , 4  , 5  , 5  , 6  , 6  , 6  , 5  , 5    ;
    !byte 4  , 3  , 2  , 1  , 0  , $ff, $fe, $fd, $fc, $fb, $fb, $fa  ;
    !byte $fa, $fa, $fb, $fb, $fc, $fd, $fe, $ff                      ;

segment_angle_to_x_deltas_table
    !byte $1     ; x+
    !byte $1     ; x+
    !byte $1     ; x+
    !byte $1     ; x+
    !byte $1     ; x+
    !byte $0     ; x0
    !byte $1     ; x+
    !byte $0     ; x0
    !byte $0     ; x0
    !byte $ff    ; x-
    !byte $0     ; x0
    !byte $ff    ; x-
    !byte $ff    ; x-
    !byte $ff    ; x-
    !byte $ff    ; x-
    !byte $ff    ; x-
    !byte $ff    ; x-
    !byte $ff    ; x-
    !byte $ff    ; x-
    !byte $ff    ; x-
    !byte $ff    ; x-
    !byte $0     ; x0
    !byte $ff    ; x-
    !byte $0     ; x0
    !byte $0     ; x0
    !byte $1     ; x+
    !byte $0     ; x0
    !byte $1     ; x+
    !byte $1     ; x+
    !byte $1     ; x+
    !byte $1     ; x+
    !byte $1     ; x+

segment_angle_to_y_deltas_table
    !byte $0     ; y0
    !byte $1     ; y+
    !byte $0     ; y0
    !byte $1     ; y+
    !byte $1     ; y+
    !byte $1     ; y+
    !byte $1     ; y+
    !byte $1     ; y+
    !byte $1     ; y+
    !byte $1     ; y+
    !byte $1     ; y+
    !byte $1     ; y+
    !byte $1     ; y+
    !byte $0     ; y0
    !byte $1     ; y+
    !byte $0     ; y0
    !byte $0     ; y0
    !byte $ff    ; y-
    !byte $0     ; y0
    !byte $ff    ; y-
    !byte $ff    ; y-
    !byte $ff    ; y-
    !byte $ff    ; y-
    !byte $ff    ; y-
    !byte $ff    ; y-
    !byte $ff    ; y-
    !byte $ff    ; y-
    !byte $ff    ; y-
    !byte $ff    ; y-
    !byte $0     ; y0
    !byte $ff    ; y-
    !byte $0     ; y0


starship_rotation_cosine_table
    !byte 0  , $fe, $f8, $ee, $e0, $ce                                ;
starship_rotation_sine_table
    !byte 0  , 2  , 4  , 6  , 8  , $0a                                ;
rotated_x_correction_lsb
    !byte 0  , $ff, $fc, $f7, $f0, $e7                                ;
rotated_x_correction_screens
    !byte 0, 0, 1, 2, 3, 4                                            ;
rotated_y_correction_lsb
    !byte 0  , 1  , 4  , 9  , $10, $19                                ;
rotated_y_correction_screens
    !byte 0, 1, 2, 3, 4, 5                                            ;
rotated_x_correction_fraction
    !byte 0  , $fe, $ff, $fc, $fa, $f6                                ;
rotated_x_correction_pixels
    !byte 0  , $fe, $fb, $f6, $ef, $e6                                ;
rotated_y_correction_fraction
    !byte 1  , 0  , 2  , 0  , $ff, $fe                                ;
rotated_y_correction_pixels
    !byte 0  , 1  , 4  , 9  , $0f, $18                                ;

starship_torpedo_cooldown
    !byte 0                                                           ;
starship_torpedo_cooldown_after_firing
    !byte 1                                                           ;
fire_pressed
    !byte 0                                                           ;
starship_energy_low
    !byte 0                                                           ;
starship_energy_high
    !byte 0                                                           ;
damage_high
    !byte 0                                                           ;
damage_low
damage_low1
    !byte 0                                                           ;
starship_destroyed
    !byte 0                                                           ;
minimum_energy_value_to_avoid_starship_destruction
    !byte 4                                                           ;
starship_energy_divided_by_sixteen
    !byte 0                                                           ;
starship_energy_regeneration
    !byte 0                                                           ;
starship_automatic_shields
    !byte 0                                                           ;
value_of_x_when_incur_damage_called
    !byte 0                                                           ;
shields_state_delta
    !byte 0                                                           ;
rotation_delta
    !byte 0                                                           ;
starship_rotation_fraction
    !byte 0                                                           ;
strength_of_player_rotation
    !byte $f0                                                         ;
strength_of_rotation_dampers
    !byte $40                                                         ;
starship_energy_drain_from_acceleration
    !byte 4                                                           ;
rotation_damper
    !byte 0                                                           ;
starship_energy_drain_from_non_zero_rotation
    !byte 4                                                           ;
velocity_delta
    !byte 0                                                           ;
starship_acceleration_from_player
    !byte $40                                                         ;
starship_acceleration_from_velocity_damper
    !byte $20                                                         ;
velocity_damper
    !byte 0                                                           ;
maximum_starship_velocity
    !byte 4                                                           ;
enemy_ship_x_plus_half_sine
    !byte 0                                                           ;
enemy_ship_y_plus_half_cosine
    !byte 0                                                           ;
enemy_ship_type
    !byte 0                                                           ;
starship_torpedo_counter
    !byte 0                                                           ;
starship_torpedoes_per_round
    !byte 4                                                           ;
starship_torpedo_cooldown_after_round
    !byte 2                                                           ;
starship_energy_drain_from_firing_torpedo
    !byte 4                                                           ;
previous_starship_automatic_shields
    !byte 0                                                           ;

; ----------------------------------------------------------------------------------
set_pixel
    ldy y_pixels                                                      ;
    lda rowHigh,y                                                     ;
    clc                                                               ;
    adc screen_start_high                                             ;
    sta screen_address_high                                           ;
    lda rowLow,y                                                      ;
    sta screen_address_low                                            ;
    lda x_pixels                                                      ;
    tax                                                               ;
    and #$f8                                                          ;
    tay                                                               ;
    lda xbit_table,x                                                  ;
    ora (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
unset_pixel
    ldy y_pixels                                                      ;
    lda rowHigh,y                                                     ;
    clc                                                               ;
    adc screen_start_high                                             ;
    sta screen_address_high                                           ;
    lda rowLow,y                                                      ;
    sta screen_address_low                                            ;
    lda x_pixels                                                      ;
    tax                                                               ;
    and #$f8                                                          ;
    tay                                                               ;
    lda xinverse_bit_table,x                                          ;
    and (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
eor_pixel_within_box_around_origin
    lda x_pixels                                                      ;
    sec                                                               ;
    sbc temp10                                                        ;
    bcs skip_inversion_x                                              ;
    eor #$ff                                                          ;
skip_inversion_x
    cmp #$20                                                          ;
    bcs return                                                        ;
    lda y_pixels                                                      ;
    sec                                                               ;
    sbc temp9                                                         ;
    bcs skip_inversion_y                                              ;
    eor #$ff                                                          ;
skip_inversion_y
    cmp #$20                                                          ;
    bcs return                                                        ;
eor_pixel
    ldy y_pixels                                                      ;
    lda rowHigh,y                                                     ;
    clc                                                               ;
    adc screen_start_high                                             ;
    sta screen_address_high                                           ;
    lda rowLow,y                                                      ;
    sta screen_address_low                                            ;
    lda x_pixels                                                      ;
    tax                                                               ;
    and #$f8                                                          ;
    tay                                                               ;
    lda xbit_table,x                                                  ;
    eor (screen_address_low),y                                        ;
    sta (screen_address_low),y                                        ;
return
    rts                                                               ;

rowLow
    !for i, 0, 255 {
        !byte <((i & 7) + (i/8) * $0140)
    }
rowHigh
    !for i, 0, 255 {
        !byte >((i & 7) + (i/8) * $0140)
    }

xbit_table
    !for i, 0, 255 {
        !byte $80 >> (i & 7)
    }

xinverse_bit_table
    !for i, 0, 255 {
        !byte ($80 >> (i & 7)) XOR 255
    }

squares_low
    !for i, 0, 511 {
        !byte <((i*i)/4)
    }
squares_high
    !for i, 0, 511 {
        !byte >((i*i)/4)
    }

; ----------------------------------------------------------------------------------
; Calculate A*X (aka m1 * m2) with the product returned in prodLow(low) and A (high)
; unsigned
; ----------------------------------------------------------------------------------
mul8x8
    tay                     ; save m1 in y
    stx temp_m2             ; save m2
    sec                     ; set carry for subtract
    sbc temp_m2             ; find difference
    bcs +                   ; was m1 > m2 ?
    eor #$ff                ; invert it
    adc #1                  ; and add 1
+
    tax                     ; use abs(m1-m2) as index
    clc                     ;
    tya                     ; get m1 back
    adc temp_m2             ; find m1 + m2
    tay                     ; use m1+m2 as index
    bcc +                   ; m1+m2 < 255 ?
    lda squares_low+256,y   ; find sum squared low if > 255
    sbc squares_low,x       ; subtract diff squared
    sta prod_low            ; save in product
    lda squares_high+256,y  ; hi byte
    sbc squares_high,x      ;
    rts                     ; done
+
    sec                     ; set carry for subtract
    lda squares_low,y       ; find sum of squares low if < 255
    sbc squares_low,x       ; subtract diff squared
    sta prod_low            ; save in product
    lda squares_high,y      ; hi byte
    sbc squares_high,x      ;
    rts                     ;

; ----------------------------------------------------------------------------------
multiply_torpedo_position_by_starship_rotation_sine_magnitude

    ; (output_fraction, output_pixels) = starship_rotation_sine_magnitude * pos16
    lda starship_rotation_sine_magnitude                              ;
    sta b                                                             ;
    lda (temp0_low),y                                                 ;
    sta a                                                             ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    sta c                                                             ;
    ; fall through to multiply routine...

; ----------------------------------------------------------------------------------
; Given a signed 8.8 fixed point number 'b.a', and an 8 bit number 'c'
; calculate their product 'b.a * c' with the result in 8.8 fixed point 'output_pixels . output_fraction'
;
; Method:
;
; (c.a)*b = ((a+256*c)*b)/256 = (a*b)/256 + c*b
;
; We calculate a*b as a 16 bit number and just take the top byte, call this t
; then we calculate c*b as a 16 bit number and add t
;
; Y is preserved
; ----------------------------------------------------------------------------------
mul16x8
    sty temp_y                                                        ; remember Y
    lda a                                                             ;
    ldx b                                                             ;
    jsr mul8x8                                                        ;
    sta t                                                             ;
    lda c                                                             ;
    ldx b                                                             ;
    jsr mul8x8                                                        ;
    sta output_fraction                                               ;
    lda prod_low                                                      ;
    clc                                                               ;
    adc t                                                             ;
    sta output_pixels                                                 ;
    bcc +                                                             ;
    inc output_fraction                                               ;
+
temp_y = *+1
    ldy #$ff                                                          ; restore Y
    rts                                                               ;


; ----------------------------------------------------------------------------------
; Adapted from White Flame's code (https://codebase64.org/doku.php?id=base:8bit_multiplication_16bit_product)
;
; Calculates ((a+256*c)*b)/256
;
; result is 16 bit, returned in output_pixels(low) and output_fraction(high)
;
; Y is preserved
; ----------------------------------------------------------------------------------
;mul16x8
;    sty temp_y                                                        ; remember Y
;    lda #0                                                            ;
;    tay                                                               ;
;    sta new                                                           ;
;    sta z                                                             ;
;    beq enter_loop                                                    ;
;
;do_add
;    clc                                                               ;
;    adc a                                                             ;
;    tax                                                               ;
;    tya                                                               ;
;    adc c                                                             ;
;    tay                                                               ;
;    lda z                                                             ;
;    adc new                                                           ;
;    sta z                                                             ;
;    txa                                                               ;
;mul_loop
;    asl a                                                             ;
;    rol c                                                             ;
;    rol new                                                           ;
;enter_loop                                                            ; accumulating multiply entry point (enter with .A=lo, .Y=hi)
;    lsr b                                                             ;
;    bcs do_add                                                        ;
;    bne mul_loop                                                      ;
;    sty output_pixels                                                 ;
;    lda z                                                             ;
;    sta output_fraction                                               ;
;temp_y = *+1
;    ldy #$ff                                                          ; restore Y
;    rts                                                               ;

; ----------------------------------------------------------------------------------
multiply_torpedo_position_by_starship_rotation_cosine
    lda starship_rotation_cosine                                      ;
    sta temp8                                                         ;
    lda (temp0_low),y                                                 ;
    sec                                                               ;
    sbc #1                                                            ;
    sta addition                                                      ;

    ; unrolled loop for 8x8 multiply with 8 bit result (high byte)
    lda #0                                                            ;
    lsr temp8                                                         ;
    bcc +                                                             ;
    adc addition                                                      ;
+
    ror                                                               ;
    lsr temp8                                                         ;
    bcc +                                                             ;
    adc addition                                                      ;
+
    ror                                                               ;
    lsr temp8                                                         ;
    bcc +                                                             ;
    adc addition                                                      ;
+
    ror                                                               ;
    lsr temp8                                                         ;
    bcc +                                                             ;
    adc addition                                                      ;
+
    ror                                                               ;
    lsr temp8                                                         ;
    bcc +                                                             ;
    adc addition                                                      ;
+
    ror                                                               ;
    lsr temp8                                                         ;
    bcc +                                                             ;
    adc addition                                                      ;
+
    ror                                                               ;
    lsr temp8                                                         ;
    bcc +                                                             ;
    adc addition                                                      ;
+
    ror                                                               ;
    lsr temp8                                                         ;
    bcc +                                                             ;
    adc addition                                                      ;
+
    ror                                                               ;
    inc addition                                                      ;
    sec                                                               ;
    sbc addition                                                      ;
    tax                                                               ;
    lda addition                                                      ;
    sbc #0                                                            ;
    sta temp8                                                         ;
    txa                                                               ;
    dey                                                               ;
    clc                                                               ;
    adc (temp0_low),y                                                 ;
    bcc return1                                                       ;
    inc temp8                                                         ;
return1
    rts                                                               ;

; ----------------------------------------------------------------------------------
update_object_position_for_starship_rotation_and_speed
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    sta x_pixels                                                      ;
    ldx starship_rotation                                             ;
    bmi skip_inversion                                                ;
    eor #$ff                                                          ;
    sta (temp0_low),y                                                 ;
    dey                                                               ;
    lda (temp0_low),y                                                 ;
    eor #$ff                                                          ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
skip_inversion
    iny                                                               ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    sta y_pixels                                                      ;
    ldx starship_rotation_sine_magnitude                              ;
    bne update_position_for_rotation                                  ;
    jmp add_starship_velocity_to_position                             ;

; ----------------------------------------------------------------------------------
update_position_for_rotation
    dey                                                               ;
    jsr multiply_torpedo_position_by_starship_rotation_sine_magnitude ;
    dey                                                               ;
    dey                                                               ;
    jsr multiply_torpedo_position_by_starship_rotation_cosine         ;
    clc                                                               ;
    adc output_pixels                                                 ;
    sta temp9                                                         ;
    lda temp8                                                         ;
    adc output_fraction                                               ;
    sta temp10                                                        ;
    jsr multiply_torpedo_position_by_starship_rotation_sine_magnitude ;
    iny                                                               ;
    iny                                                               ;
    jsr multiply_torpedo_position_by_starship_rotation_cosine         ;
    sec                                                               ;
    sbc output_pixels                                                 ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda temp8                                                         ;
    sbc output_fraction                                               ;
    sta (temp0_low),y                                                 ;
    dey                                                               ;
    dey                                                               ;
    dey                                                               ;
    ldx starship_rotation_magnitude                                   ;
    lda temp9                                                         ;
    sec                                                               ;
    sbc rotated_x_correction_lsb,x                                    ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda temp10                                                        ;
    sbc rotated_x_correction_screens,x                                ;
    sta (temp0_low),y                                                 ;
    lda starship_rotation                                             ;
    bmi skip_uninversion                                              ;
    dey                                                               ;
    lda (temp0_low),y                                                 ;
    eor #$ff                                                          ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    eor #$ff                                                          ;
    sta (temp0_low),y                                                 ;
skip_uninversion
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    clc                                                               ;
    adc rotated_y_correction_lsb,x                                    ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    adc rotated_y_correction_screens,x                                ;
    sta (temp0_low),y                                                 ;
add_starship_velocity_to_position
    dey                                                               ;
    lda (temp0_low),y                                                 ;
    clc                                                               ;
    adc starship_velocity_low                                         ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    adc starship_velocity_high                                        ;
    sta (temp0_low),y                                                 ;
    rts                                                               ;

; TODO: optimise
; ----------------------------------------------------------------------------------
multiply_enemy_position_by_starship_rotation_sine_magnitude
    lda starship_rotation_sine_magnitude                              ;
    sta segment_length                                                ;
    lda enemy_ships_x_fraction,x                                      ;
    sta temp9                                                         ;
    lda enemy_ships_x_pixels,x                                        ;
    sta temp10                                                        ;
    lda enemy_ships_x_screens,x                                       ;
    sta segment_angle                                                 ;
    lda #0                                                            ;
    ldy #$18                                                          ;
loop_over_bits_of_input1
    lsr segment_angle                                                 ;
    ror temp10                                                        ;
    ror temp9                                                         ;
    bcc input_bit_unset1                                              ;
    clc                                                               ;
    adc segment_length                                                ;
input_bit_unset1
    ror                                                               ;
    ror output_fraction                                               ;
    ror output_pixels                                                 ;
    dey                                                               ;
    bne loop_over_bits_of_input1                                      ;
    sta segment_length                                                ;
    rts                                                               ;

; TODO: optimise
; ----------------------------------------------------------------------------------
multiply_enemy_position_by_starship_rotation_cosine
    lda starship_rotation_cosine                                      ;
    sta segment_angle                                                 ;
    lda enemy_ships_x_pixels,x                                        ;
    sta temp9                                                         ;
    lda enemy_ships_x_screens,x                                       ;
    sta temp10                                                        ;
    lda #0                                                            ;
    ldy #$10                                                          ;
loop_over_bits_of_input2
    lsr temp10                                                        ;
    ror temp9                                                         ;
    bcc input_bit_unset2                                              ;
    clc                                                               ;
    adc segment_angle                                                 ;
input_bit_unset2
    ror                                                               ;
    ror temp8                                                         ;
    dey                                                               ;
    bne loop_over_bits_of_input2                                      ;
    tay                                                               ;
    lda temp8                                                         ;
    clc                                                               ;
    adc enemy_ships_x_fraction,x                                      ;
    sta temp9                                                         ;
    tya                                                               ;
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
    lda enemy_ships_previous_x_pixels1,x                              ;
    clc                                                               ;
    adc #$80                                                          ;
    sta enemy_ships_x_pixels1,x                                       ;
    bcc skip2                                                         ;
    inc enemy_ships_x_screens1,x                                      ;
skip2
    ldy starship_rotation                                             ;
    bmi skip_inversion1                                               ;
    lda enemy_ships_previous_x_fraction,x                             ;
    eor #$ff                                                          ;
    sta enemy_ships_x_fraction,x                                      ;
    lda enemy_ships_x_pixels,x                                        ;
    eor #$ff                                                          ;
    sta enemy_ships_x_pixels,x                                        ;
    lda enemy_ships_x_screens,x                                       ;
    eor #$ff                                                          ;
    sta enemy_ships_x_screens,x                                       ;
skip_inversion1
    inx                                                               ;
    inx                                                               ;
    inx                                                               ;
    jsr multiply_enemy_position_by_starship_rotation_sine_magnitude   ;
    dex                                                               ;
    dex                                                               ;
    dex                                                               ;
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
    inx                                                               ;
    inx                                                               ;
    inx                                                               ;
    jsr multiply_enemy_position_by_starship_rotation_cosine           ;
    dex                                                               ;
    dex                                                               ;
    dex                                                               ;
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
    sta enemy_ships_x_fraction,x                                      ;
    lda y_pixels                                                      ;
    sbc rotated_x_correction_pixels,y                                 ;
    sta enemy_ships_x_pixels,x                                        ;
    lda temp11                                                        ;
    sbc rotated_x_correction_screens,y                                ;
    sta enemy_ships_x_screens,x                                       ;
    lda starship_rotation                                             ;
    bmi skip_uninversion1                                             ;
    lda enemy_ships_x_fraction,x                                      ;
    eor #$ff                                                          ;
    sta enemy_ships_x_fraction,x                                      ;
    lda enemy_ships_x_pixels,x                                        ;
    eor #$ff                                                          ;
    sta enemy_ships_x_pixels,x                                        ;
    lda enemy_ships_x_screens,x                                       ;
    eor #$ff                                                          ;
    sta enemy_ships_x_screens,x                                       ;
skip_uninversion1
    lda temp9                                                         ;
    clc                                                               ;
    adc rotated_y_correction_fraction,y                               ;
    sta enemy_ships_x_fraction1,x                                     ;
    lda temp10                                                        ;
    adc rotated_y_correction_pixels,y                                 ;
    sta enemy_ships_x_pixels1,x                                       ;
    lda segment_angle                                                 ;
    adc rotated_y_correction_screens,y                                ;
    sta enemy_ships_x_screens1,x                                      ;
    lda enemy_ships_x_pixels1,x                                       ;
    sec                                                               ;
    sbc #$80                                                          ;
    sta enemy_ships_x_pixels1,x                                       ;
    lda enemy_ships_x_screens1,x                                      ;
    sbc #0                                                            ;
    sta enemy_ships_x_screens1,x                                      ;
    lda enemy_ships_x_pixels,x                                        ;
    sec                                                               ;
    sbc #$80                                                          ;
    sta enemy_ships_x_pixels,x                                        ;
    lda enemy_ships_x_screens,x                                       ;
    sbc #0                                                            ;
    sta enemy_ships_x_screens,x                                       ;
apply_starship_velocity_to_enemy_ship
    lda enemy_ships_x_fraction1,x                                     ;
    clc                                                               ;
    adc starship_velocity_low                                         ;
    sta enemy_ships_x_fraction1,x                                     ;
    lda enemy_ships_x_pixels1,x                                       ;
    adc starship_velocity_high                                        ;
    sta enemy_ships_x_pixels1,x                                       ;
    lda enemy_ships_x_screens1,x                                      ;
    adc #0                                                            ;
    sta enemy_ships_x_screens1,x                                      ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_starship_torpedoes
    lda maximum_number_of_starship_torpedoes                          ;
    sta torpedoes_still_to_consider                                   ;
    lda #<starship_torpedoes_table                                    ;
    sta temp0_low                                                     ;
    lda #>starship_torpedoes_table                                    ;
    sta temp0_high                                                    ;
    lda #<(starship_torpedoes_table+4)                                ;
    sta temp1_low                                                     ;
    lda #>(starship_torpedoes_table+4)                                ;
    sta temp1_high                                                    ;
plot_starship_torpedoes_loop
    ldy #0                                                            ;
    lda (temp0_low),y                                                 ;
    bne torpedo_present                                               ;
    jmp update_next_torpedo                                           ;

torpedo_present
    sec                                                               ;
    sbc #1                                                            ;
    sta (temp0_low),y                                                 ;
    bne torpedo_still_alive                                           ;
    dec number_of_live_starship_torpedoes                             ;
    jsr plot_expiring_torpedo                                         ;
    jmp update_next_torpedo                                           ;

torpedo_still_alive
    jsr plot_starship_torpedo                                         ;
    ldy #1                                                            ;
    jsr update_object_position_for_starship_rotation_and_speed        ;
    ldy #5                                                            ;
    jsr update_object_position_for_starship_rotation_and_speed        ;
    ldy #1                                                            ;
    lda (temp0_low),y                                                 ;
    sec                                                               ;
    sbc (temp1_low),y                                                 ;
    sta output_pixels                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    sbc (temp1_low),y                                                 ;
    asl output_pixels                                                 ;
    rol                                                               ;
    asl output_pixels                                                 ;
    rol                                                               ;
    sta output_fraction                                               ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    sec                                                               ;
    sbc (temp1_low),y                                                 ;
    sta temp9                                                         ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    sbc (temp1_low),y                                                 ;
    asl temp9                                                         ;
    rol                                                               ;
    asl temp9                                                         ;
    rol                                                               ;
    sta temp10                                                        ;
    ldy #1                                                            ;
    lda (temp0_low),y                                                 ;
    clc                                                               ;
    adc output_pixels                                                 ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    adc output_fraction                                               ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    clc                                                               ;
    adc temp9                                                         ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    adc temp10                                                        ;
    sta (temp0_low),y                                                 ;
    ldy #1                                                            ;
    lda (temp1_low),y                                                 ;
    clc                                                               ;
    adc output_pixels                                                 ;
    sta (temp1_low),y                                                 ;
    iny                                                               ;
    lda (temp1_low),y                                                 ;
    adc output_fraction                                               ;
    sta (temp1_low),y                                                 ;
    iny                                                               ;
    lda (temp1_low),y                                                 ;
    clc                                                               ;
    adc temp9                                                         ;
    sta (temp1_low),y                                                 ;
    iny                                                               ;
    lda (temp1_low),y                                                 ;
    adc temp10                                                        ;
    sta (temp1_low),y                                                 ;
    jsr check_for_collision_with_enemy_ships                          ;
    bcs update_next_torpedo                                           ;
    ldy #0                                                            ;
    lda (temp0_low),y                                                 ;
    cmp #2                                                            ;
    bcs unplot_torpedo                                                ;
    jsr plot_expiring_torpedo                                         ;
    sec                                                               ;
    bcs update_next_torpedo                                           ;
unplot_torpedo
    jsr plot_starship_torpedo                                         ;
update_next_torpedo
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #9                                                            ;
    sta temp0_low                                                     ;
    bcc skip3                                                         ;
    inc temp0_high                                                    ;
skip3
    lda temp1_low                                                     ;
    clc                                                               ;
    adc #9                                                            ;
    sta temp1_low                                                     ;
    bcc skip4                                                         ;
    inc temp1_high                                                    ;
skip4
    dec torpedoes_still_to_consider                                   ;
    beq return2                                                       ;
    jmp plot_starship_torpedoes_loop                                  ;

return2
    rts                                                               ;

; ----------------------------------------------------------------------------------
fire_starship_torpedo
    lda number_of_live_starship_torpedoes                             ;
    cmp maximum_number_of_starship_torpedoes                          ;
    bcs return3                                                       ;
    inc number_of_live_starship_torpedoes                             ;
    inc starship_fired_torpedo                                        ;
    lda #<starship_torpedoes_table                                    ;
    sta temp0_low                                                     ;
    lda #>starship_torpedoes_table                                    ;
    sta temp0_high                                                    ;
    ldy #0                                                            ;
loop5
    lda (temp0_low),y                                                 ;
    beq empty_torpedo_slot                                            ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #9                                                            ;
    sta temp0_low                                                     ;
    bcc loop5                                                         ;
    inc temp0_high                                                    ;
    bne loop5                                                         ;
return3
    rts                                                               ;

; ----------------------------------------------------------------------------------
empty_torpedo_slot
    lda starship_torpedoes_time_to_live                               ;
    sta (temp0_low),y                                                 ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #4                                                            ;
    sta temp1_low                                                     ;
    lda temp0_high                                                    ;
    adc #0                                                            ;
    sta temp1_high                                                    ;
    iny                                                               ;
    lda #$7f                                                          ;
    sta (temp0_low),y                                                 ;
    sta (temp1_low),y                                                 ;
    iny                                                               ;
    sta (temp0_low),y                                                 ;
    sta (temp1_low),y                                                 ;
    iny                                                               ;
    lda #$80                                                          ;
    sta (temp0_low),y                                                 ;
    lda #$90                                                          ;
    sta (temp1_low),y                                                 ;
    iny                                                               ;
    lda #$75                                                          ;
    sta (temp0_low),y                                                 ;
    lda #$77                                                          ;
    sta (temp1_low),y                                                 ;
    lda #0                                                            ;
    sta how_enemy_ship_was_damaged                                    ;
    jsr check_for_collision_with_enemy_ships                          ;
    bcs return4                                                       ;
    jmp plot_starship_torpedo                                         ;

return4
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_big_torpedo
    inc x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec x_pixels                                                      ;
    dec y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec y_pixels                                                      ;
    inc x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_expiring_torpedo
    ldy #2                                                            ;
    lda (temp0_low),y                                                 ;
    sta x_pixels                                                      ;
    ldy #4                                                            ;
    lda (temp0_low),y                                                 ;
    sta y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc x_pixels                                                      ;
    dec y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec x_pixels                                                      ;
    inc y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
update_stars
    lda #<star_table                                                  ;
    sta temp0_low                                                     ;
    lda #>star_table                                                  ;
    sta temp0_high                                                    ;
    lda maximum_number_of_stars                                       ;
    sta enemy_ships_still_to_consider                                 ;
update_stars_loop
    ldy #0                                                            ;
    jsr update_object_position_for_starship_rotation_and_speed        ;
    jsr eor_pixel                                                     ;
    ldy #1                                                            ;
    lda (temp0_low),y                                                 ;
    sta x_pixels                                                      ;
    ldy #3                                                            ;
    lda (temp0_low),y                                                 ;
    sta y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #4                                                            ;
    sta temp0_low                                                     ;
    bcc skip5                                                         ;
    inc temp0_high                                                    ;
skip5
    dec enemy_ships_still_to_consider                                 ;
    bne update_stars_loop                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
unplot_long_range_scanner_if_shields_inactive
    lda starship_shields_active                                       ;
    beq return5                                                       ;
    lda #0                                                            ;
    sta starship_shields_active                                       ;
    jsr plot_top_and_right_edge_of_long_range_scanner_without_text    ;
    jsr plot_enemy_ships_on_scanners                                  ;
    ldy #$1f                                                          ;
    sty x_pixels                                                      ;
    iny                                                               ;
    sty y_pixels                                                      ;
    inc screen_start_high                                             ;
    jsr unset_pixel                                                   ;
    dec screen_start_high                                             ;
    jsr plot_shields_text                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_top_and_right_edge_of_long_range_scanner_with_blank_text
    lda starship_shields_active                                       ;
    bne return5                                                       ;
    lda #1                                                            ;
    sta starship_shields_active                                       ;
    jsr plot_blank_text                                               ;
; ----------------------------------------------------------------------------------
plot_top_and_right_edge_of_long_range_scanner_without_text
    inc screen_start_high                                             ;
    lda #$3f                                                          ;
    sta x_pixels                                                      ;
    lda #0                                                            ;
    sta y_pixels                                                      ;
plot_top_edge_loop
    jsr eor_pixel                                                     ;
    dec x_pixels                                                      ;
    bpl plot_top_edge_loop                                            ;
    lda #$3f                                                          ;
    sta y_pixels                                                      ;
    sta x_pixels                                                      ;
plot_right_edge_loop
    jsr eor_pixel                                                     ;
    dec y_pixels                                                      ;
    bne plot_right_edge_loop                                          ;
    dec screen_start_high                                             ;
return5
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_starship_torpedo
    ldy #2                                                            ;
    lda (temp0_low),y                                                 ;
    sta x_pixels                                                      ;
    ldy #4                                                            ;
    lda (temp0_low),y                                                 ;
    sta y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    lda starship_torpedo_type                                         ;
    beq small_starship_torpedoes                                      ;
    jmp plot_big_torpedo                                              ;

small_starship_torpedoes
    ldy #2                                                            ;
    lda (temp1_low),y                                                 ;
    sta x_pixels                                                      ;
    ldy #4                                                            ;
    lda (temp1_low),y                                                 ;
    sta y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    ldy #1                                                            ;
    lda (temp0_low),y                                                 ;
    clc                                                               ;
    adc (temp1_low),y                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    adc (temp1_low),y                                                 ;
    ror                                                               ;
    sta x_pixels                                                      ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    clc                                                               ;
    adc (temp1_low),y                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    adc (temp1_low),y                                                 ;
    ror                                                               ;
    sta y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    rts                                                               ;

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
    sta how_enemy_ship_was_damaged                                    ;
    lda maximum_number_of_enemy_torpedoes                             ;
    sta torpedoes_still_to_consider                                   ;
    lda #<enemy_torpedoes_table                                       ;
    sta temp0_low                                                     ;
    lda #>enemy_torpedoes_table                                       ;
    sta temp0_high                                                    ;
update_enemy_torpedoes_loop
    ldy #0                                                            ;
    lda (temp0_low),y                                                 ;
    bne enemy_torpedo_in_slot                                         ;
    jmp move_to_next_enemy_torpedo                                    ;

; ----------------------------------------------------------------------------------
enemy_torpedo_in_slot
    sec                                                               ;
    sbc #1                                                            ;
    sta (temp0_low),y                                                 ;
    bne enemy_torpedo_still_alive                                     ;
    jsr plot_expiring_torpedo                                         ;
    jmp move_to_next_enemy_torpedo                                    ;

enemy_torpedo_still_alive
    jsr plot_enemy_torpedo                                            ;
    ldy #1                                                            ;
    jsr update_object_position_for_starship_rotation_and_speed        ;
    ldy #5                                                            ;
    lda (temp0_low),y                                                 ;
    clc                                                               ;
    adc starship_angle_delta                                          ;
    sta (temp0_low),y                                                 ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    tax                                                               ;
    dey                                                               ;
    lda cosine_table,x                                                ;
    clc                                                               ;
    adc (temp0_low),y                                                 ;
    sta (temp0_low),y                                                 ;
    sec                                                               ;
    sbc y_pixels                                                      ;
    bcs skip_inversion2                                               ;
    eor #$ff                                                          ;
skip_inversion2
    cmp #$40                                                          ;
    bcs remove_torpedo                                                ;
    ldy #2                                                            ;
    lda sine_table,x                                                  ;
    clc                                                               ;
    adc (temp0_low),y                                                 ;
    sta (temp0_low),y                                                 ;
    sec                                                               ;
    sbc x_pixels                                                      ;
    bcs skip_uninversion2                                             ;
    eor #$ff                                                          ;
skip_uninversion2
    cmp #$40                                                          ;
    bcc consider_collisions                                           ;
remove_torpedo
    lda #0                                                            ;
    tay                                                               ;
    sta (temp0_low),y                                                 ;
    jmp move_to_next_enemy_torpedo                                    ;

; ----------------------------------------------------------------------------------
consider_collisions
    lda (temp0_low),y                                                 ;
    cmp starship_maximum_x_for_collisions_with_enemy_torpedoes        ;
    bcs enemy_torpedo_missed_starship                                 ;
    cmp starship_minimum_x_for_collisions_with_enemy_torpedoes        ;
    bcc enemy_torpedo_missed_starship                                 ;
    ldy #4                                                            ;
    lda (temp0_low),y                                                 ;
    cmp starship_maximum_y_for_collisions_with_enemy_torpedoes        ;
    bcs enemy_torpedo_missed_starship                                 ;
    cmp starship_minimum_y_for_collisions_with_enemy_torpedoes        ;
    bcc enemy_torpedo_missed_starship                                 ;
    jsr plot_expiring_torpedo                                         ;
    inc enemy_torpedo_hits_against_starship                           ;
    lda damage_from_enemy_torpedo                                     ;
    jsr incur_damage                                                  ;
    ldy #0                                                            ;
    lda #1                                                            ;
    sta (temp0_low),y                                                 ;
    jmp move_to_next_enemy_torpedo                                    ;

enemy_torpedo_missed_starship
    jsr check_for_collision_with_enemy_ships                          ;
    bcs move_to_next_enemy_torpedo                                    ;
    ldy #0                                                            ;
    lda (temp0_low),y                                                 ;
    cmp #2                                                            ;
    bcs enemy_torpedo_ok                                              ;
    jsr plot_expiring_torpedo                                         ;
    jmp move_to_next_enemy_torpedo                                    ;

enemy_torpedo_ok
    jsr plot_enemy_torpedo                                            ;
move_to_next_enemy_torpedo
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #6                                                            ;
    sta temp0_low                                                     ;
    bcc skip8                                                         ;
    inc temp0_high                                                    ;
skip8
    dec torpedoes_still_to_consider                                   ;
    beq finished_updating_torpedoes                                   ;
    jmp update_enemy_torpedoes_loop                                   ;

finished_updating_torpedoes
    rts                                                               ;

; ----------------------------------------------------------------------------------
check_for_collision_with_enemy_ships
    ldy #2                                                            ;
    lda (temp0_low),y                                                 ;
    sta temp3                                                         ;
    ldy #4                                                            ;
    lda (temp0_low),y                                                 ;
    sta temp4                                                         ;
    lda maximum_number_of_enemy_ships                                 ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
consider_enemy_slot
    lda enemy_ships_on_screen,x                                       ;
    bne move_to_next_enemy                                            ;
    lda enemy_ships_x_pixels,x                                        ;
    sec                                                               ;
    sbc temp3                                                         ;
    bcs skip_inversion_x1                                             ;
    eor #$ff                                                          ;
skip_inversion_x1
    cmp size_of_enemy_ship_for_collisions_with_torpedoes              ;
    bcs move_to_next_enemy                                            ;
    lda enemy_ships_x_pixels1,x                                       ;
    sec                                                               ;
    sbc temp4                                                         ;
    bcs skip_inversion_y1                                             ;
    eor #$ff                                                          ;
skip_inversion_y1
    cmp size_of_enemy_ship_for_collisions_with_torpedoes              ;
    bcs move_to_next_enemy                                            ;
    lda enemy_ships_energy,x                                          ;
    bne skip_considering_explosion                                    ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    cmp frame_of_enemy_ship_explosion_after_which_no_collisions       ;
    bcs skip_damage                                                   ;
    bcc move_to_next_enemy                                            ;
skip_considering_explosion
    inc enemy_ship_was_hit                                            ;
    inc enemy_ships_temporary_behaviour_flags,x                       ;
    lda how_enemy_ship_was_damaged                                    ;
    beq damaged_by_other                                              ;
    lda damage_to_enemy_ship_from_starship_torpedo                    ;
    jmp collision_occurred                                            ;

damaged_by_other
    lda damage_to_enemy_ship_from_other_collision                     ;
collision_occurred
    jsr damage_enemy_ship                                             ;
skip_damage
    ldy #0                                                            ;
    lda #1                                                            ;
    sta (temp0_low),y                                                 ;
    jsr plot_expiring_torpedo                                         ;
    sec                                                               ;
    rts                                                               ;

move_to_next_enemy
    txa                                                               ;
    clc                                                               ;
    adc #$0b                                                          ;
    tax                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    bne consider_enemy_slot                                           ;
    clc                                                               ;
    rts                                                               ;

plot_enemy_torpedo
    ldy #2                                                            ;
    lda (temp0_low),y                                                 ;
    sta x_pixels                                                      ;
    ldy #4                                                            ;
    lda (temp0_low),y                                                 ;
    sta y_pixels                                                      ;
    jsr eor_pixel                                                     ;
enemy_torpedo_type_instruction
    rts                                                               ;

apply_velocity_to_enemy_ships
    lda maximum_number_of_enemy_ships                                 ;
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
    ldy #5                                                            ;
    lda #0                                                            ;
    sta temp8                                                         ;
loop_over_bits_of_sine
    lsr temp3                                                         ; TODO: optimise?
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
    ldy #5                                                            ;
    lda #0                                                            ;
    sta temp8                                                         ;
loop_over_bits_of_cosine
    lsr temp4                                                         ; TODO: optimise?
    bcc cosine_bit_unset                                              ;
    clc                                                               ;
    adc temp7                                                         ;
cosine_bit_unset
    ror                                                               ;
    ror temp8                                                         ;
    dey                                                               ;
    bne loop_over_bits_of_cosine                                      ;
    tay                                                               ;
    lda enemy_ships_x_fraction1,x                                     ;
    adc temp8                                                         ;
    sta enemy_ships_x_fraction1,x                                     ;
    tya                                                               ;
    adc enemy_ships_x_pixels1,x                                       ;
    sta enemy_ships_x_pixels1,x                                       ;
    bcc skip10                                                        ;
    inc enemy_ships_x_screens1,x                                      ;
skip10
    ldy temp4                                                         ;
    beq skip_subtraction_cosine                                       ;
    sec                                                               ;
    sbc temp7                                                         ;
    sta enemy_ships_x_pixels1,x                                       ;
    bcs skip_subtraction_cosine                                       ;
    dec enemy_ships_x_screens1,x                                      ;
skip_subtraction_cosine
mark_enemy_ship_as_plotted_if_on_starship_screen
    lda #$7f                                                          ;
    cmp enemy_ships_x_screens,x                                       ;
    bne enemy_ship_not_on_starship_screen                             ;
    cmp enemy_ships_x_screens1,x                                      ;
    bne enemy_ship_not_on_starship_screen                             ;
    lda #0                                                            ;
    beq set_enemy_ships_on_screen                                     ;
enemy_ship_not_on_starship_screen
    lda #1                                                            ;
set_enemy_ships_on_screen
    sta enemy_ships_on_screen,x                                       ;
    txa                                                               ;
    clc                                                               ;
    adc #$0b                                                          ;
    tax                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    beq return7                                                       ;
    jmp apply_velocity_to_enemy_ships_loop                            ;

return7
    rts                                                               ;

plot_enemy_ships
    lda maximum_number_of_enemy_ships                                 ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
plot_enemy_ships_loop
    lda enemy_ships_previous_on_screen,x                              ;
    sta enemy_ship_was_previously_on_screen                           ;
    lda enemy_ships_energy,x                                          ;
    bne explosion_continuing                                          ;
    ldy enemy_ships_still_to_consider                                 ;
    lda enemy_ships_explosion_number - 1,y                            ;
    tay                                                               ;
    lda enemy_explosion_address_low_table - 1,y                       ;
    sta temp5                                                         ;
    lda enemy_explosion_address_high_table - 1,y                      ;
    sta temp6                                                         ;
    lda enemy_ship_was_previously_on_screen                           ;
    bne not_previously_on_screen                                      ;
    dec enemy_ship_was_previously_on_screen                           ;
    jsr update_enemy_explosion_pieces                                 ;
not_previously_on_screen
    dec enemy_ships_flags_or_explosion_timer,x                        ;
    bne explosion_continuing                                          ;
    jsr initialise_enemy_ship                                         ;
explosion_continuing
    lda enemy_ships_on_screen,x                                       ;
    sta enemy_ship_was_on_screen                                      ;
    bne not_on_screen                                                 ;
    lda enemy_ships_energy,x                                          ;
    bne skip_extra_delay                                              ;
    dec enemy_ship_was_on_screen                                      ;
    bne skip_extra_delay                                              ;
not_on_screen
skip_extra_delay
    lda enemy_ship_was_previously_on_screen                           ;
    bne skip_plotting                                                 ;

unplot_enemy_ship
    jsr plot_enemy_ship                                               ;
skip_plotting
    lda enemy_ships_angle,x                                           ;
    sta enemy_ships_previous_angle,x                                  ;
    lda enemy_ships_x_pixels1,x                                       ;
    sta enemy_ships_previous_x_pixels1,x                              ;
    lda enemy_ships_x_pixels,x                                        ;
    sta enemy_ships_previous_x_pixels,x                               ;
    lda enemy_ship_was_on_screen                                      ;
    beq plot_enemy_ship_and_copy_position                             ;
    bpl copy_position_without_plotting                                ;
    jsr plot_enemy_ship_explosion                                     ;
    jmp copy_position_without_plotting                                ;

plot_enemy_ship_and_copy_position
    jsr plot_enemy_ship                                               ;
copy_position_without_plotting
    lda enemy_ships_on_screen,x                                       ;
    sta enemy_ships_previous_on_screen,x                              ;
    lda enemy_ships_x_screens1,x                                      ;
    sta enemy_ships_previous_x_screens1,x                             ;
    lda enemy_ships_x_fraction1,x                                     ;
    sta enemy_ships_previous_x_fraction1,x                            ;
    lda enemy_ships_x_screens,x                                       ;
    sta enemy_ships_previous_x_screens,x                              ;
    lda enemy_ships_x_fraction,x                                      ;
    sta enemy_ships_previous_x_fraction,x                             ;
    txa                                                               ;
    clc                                                               ;
    adc #$0b                                                          ;
    tax                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    beq return8                                                       ;
    jmp plot_enemy_ships_loop                                         ;

return8
    rts                                                               ;

delay_loop
    ldx #2                                                            ;
delay_loop_outer_loop
    ldy #$7f                                                          ;
delay_loop_inner_loop
    dey                                                               ;
    bne delay_loop_inner_loop                                         ;
    dex                                                               ;
    bne delay_loop_outer_loop                                         ;
    rts                                                               ;

shield_state_strings
    !byte $1f, $22, $18                                               ;
    !text " ON "                                                      ;
    !byte $1f, $22, $18                                               ;
    !text " OFF"                                                      ;
    !byte $1f, $22, $18                                               ;
    !text "AUTO"                                                      ;
enemy_ships_collided_with_each_other
    !byte 0                                                           ;
check_for_starship_collision_with_enemy_ships
    lda maximum_number_of_enemy_ships                                 ;
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
    cmp frame_of_enemy_ship_explosion_after_which_no_collisions       ;
    bcs check_for_collision                                           ;
to_consider_next_enemy_ship
    jmp consider_next_enemy_ship                                      ;

check_for_collision
    lda starship_has_exploded                                         ;
    beq starship_not_exploded                                         ;
    lda starship_explosion_countdown                                  ;
    cmp frame_of_starship_explosion_after_which_no_collisions         ;
    bcc no_collision                                                  ;
starship_not_exploded
    lda enemy_ships_x_pixels,x                                        ;
    cmp starship_maximum_x_for_collisions_with_enemy_ships            ;
    bcs no_collision                                                  ;
    cmp starship_minimum_x_for_collisions_with_enemy_ships            ;
    bcc no_collision                                                  ;
    lda enemy_ships_x_pixels1,x                                       ;
    cmp starship_maximum_y_for_collisions_with_enemy_ships            ;
    bcs no_collision                                                  ;
    cmp starship_minimum_y_for_collisions_with_enemy_ships            ;
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
    adc additional_damage_from_collision_with_enemy_ship              ;
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
    rts                                                               ;

check_for_collisions_between_enemy_ships
    lda temp1_low                                                     ;
    clc                                                               ;
    adc #$0b                                                          ;
    sta temp1_low                                                     ;
    tax                                                               ;
    lda enemy_ships_on_screen,x                                       ;
    bne consider_next_second_enemy_ship                               ;
    ldy temp0_low                                                     ;
    lda enemy_ships_x_pixels,x                                        ;
    sec                                                               ;
    sbc enemy_ships_x_pixels,y                                        ;
    bcs skip_inversion_x2                                             ;
    eor #$ff                                                          ;
skip_inversion_x2
    cmp size_of_enemy_ship_for_collisions_between_enemy_ships         ;
    bcs consider_next_second_enemy_ship                               ;
    sta enemy_ships_collision_x_difference                            ;
    lda enemy_ships_x_pixels1,x                                       ;
    sec                                                               ;
    sbc enemy_ships_x_pixels1,y                                       ;
    bcs skip_inversion_y2                                             ;
    eor #$ff                                                          ;
skip_inversion_y2
    cmp size_of_enemy_ship_for_collisions_between_enemy_ships         ;
    bcs consider_next_second_enemy_ship                               ;
    sta enemy_ships_collision_y_difference                            ;
    lda enemy_ships_energy,x                                          ;
    bne second_ship_not_exploding                                     ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    cmp frame_of_enemy_ship_explosion_after_which_no_collisions       ;
    bcs to_collide_enemy_ships                                        ;
    bcc consider_next_second_enemy_ship                               ;
second_ship_not_exploding
    inc enemy_ships_collided_with_each_other                          ;
    sec                                                               ;
    sbc damage_enemy_ship_incurs_from_collision_with_other_enemy_ship ;
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
    inc enemy_ship_was_hit_by_collision_with_other_enemy_ship         ;
enemy_ship_isnt_destroyed_by_collision
    lda enemy_ships_type,x                                            ;
    cmp #4                                                            ;
    bcc to_collide_enemy_ships                                        ;
    and #3                                                            ;
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
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #$0b                                                          ;
    sta temp0_low                                                     ;
    dec enemy_ships_still_to_consider                                 ;
    beq return9                                                       ;
    jmp check_for_starship_collision_with_enemy_ships_loop            ;

return9
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_segment
    jsr eor_pixel_within_box_around_origin                            ;
    ldy segment_angle                                                 ;
    lda segment_angle_to_x_deltas_table,y                             ;
    clc                                                               ;
    adc x_pixels                                                      ;
    sta x_pixels                                                      ;
    lda segment_angle_to_y_deltas_table,y                             ;
    clc                                                               ;
    adc y_pixels                                                      ;
    sta y_pixels                                                      ;
    lda segment_angle                                                 ;
    clc                                                               ;
    adc output_pixels                                                 ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    dec segment_length                                                ;
    bne plot_segment                                                  ;
    rts                                                               ;

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
    jmp skip_reset_starship_torpedo_round                             ;

reset_starship_torpedo_round
    lda starship_torpedoes_per_round                                  ;
    sta starship_torpedo_counter                                      ;
skip_reset_starship_torpedo_round
    jsr check_for_keypresses                                          ;
    lda starship_destroyed                                            ;
    beq starship_isnt_destroyed                                       ;
    jmp player_isnt_firing                                            ;

starship_isnt_destroyed
    lda velocity_delta                                                ;
    bne player_is_accelerating                                        ;
    lda velocity_damper                                               ;
    beq finished_accelerating                                         ;
    lda starship_acceleration_from_velocity_damper                    ;
    jmp set_deceleration                                              ;

player_is_accelerating
    bmi starship_is_decelerating                                      ;
    lda starship_acceleration_from_player                             ;
    sta temp8                                                         ;
    clc                                                               ;
    adc starship_velocity_low                                         ;
    sta starship_velocity_low                                         ;
    bcc skip12                                                        ;
    inc starship_velocity_high                                        ;
skip12
    lda starship_velocity_high                                        ;
    cmp maximum_starship_velocity                                     ;
    bcc incur_damage_from_acceleration                                ;
    lda maximum_starship_velocity                                     ;
    sta starship_velocity_high                                        ;
    lda #0                                                            ;
    sta starship_velocity_low                                         ;
    beq finished_accelerating                                         ;
starship_is_decelerating
    lda starship_acceleration_from_player                             ;
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
    lda starship_energy_drain_from_acceleration                       ;
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
    sbc strength_of_rotation_dampers                                  ;
    jmp store_rotation                                                ;

starship_was_turned_clockwise
    clc                                                               ;
    adc strength_of_rotation_dampers                                  ;
    jmp set_starship_rotation_fraction_and_consider_rotating          ;

player_is_turning
    bpl player_is_turning_clockwise                                   ;
    sec                                                               ;
    sbc strength_of_player_rotation                                   ;
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
    adc strength_of_player_rotation                                   ;
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
    lda starship_rotation                                             ;
    bmi skip_inversion3                                               ;
    eor #$ff                                                          ;
    adc #1                                                            ;
skip_inversion3
    adc #$80                                                          ;
    tay                                                               ;
    sta starship_rotation_magnitude                                   ;
    lda starship_rotation_sine_table,y                                ;
    sta starship_rotation_sine_magnitude                              ;
    lda starship_rotation_cosine_table,y                              ;
    sta starship_rotation_cosine                                      ;
incur_energy_drain_from_rotation
    lda starship_energy_drain_from_non_zero_rotation                  ;
    jsr incur_low_damage                                              ;
finished_rotating
    lda fire_pressed                                                  ;
    beq player_isnt_firing                                            ;
    lda starship_torpedo_cooldown                                     ;
    bne player_isnt_firing                                            ;
    dec starship_torpedo_counter                                      ;
    bne not_end_of_round                                              ;
    lda starship_torpedoes_per_round                                  ;
    sta starship_torpedo_counter                                      ;
    lda starship_torpedo_cooldown_after_round                         ;
    jmp set_starship_torpedo_cooldown                                 ;

not_end_of_round
    lda starship_torpedo_cooldown_after_firing                        ;
set_starship_torpedo_cooldown
    sta starship_torpedo_cooldown                                     ;
    jsr fire_starship_torpedo                                         ;
    lda starship_fired_torpedo                                        ;
    beq player_isnt_firing                                            ;
    lda starship_energy_drain_from_firing_torpedo                     ;
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
    beq return10                                                      ;
    ldx #0                                                            ;
    stx starship_automatic_shields                                    ;
    stx previous_starship_automatic_shields                           ;
    tay                                                               ;
    bmi plot_shields_on_and_consider_activation                       ;
    ldx #7                                                            ;
    jsr plot_shields_string_and_something                             ;
    jmp plot_top_and_right_edge_of_long_range_scanner_with_blank_text ;

plot_shields_on_and_consider_activation
    jsr plot_shields_string_and_something                             ;
    jmp unplot_long_range_scanner_if_shields_inactive                 ;

return10
    rts                                                               ;

; ----------------------------------------------------------------------------------
incur_damage
    stx value_of_x_when_incur_damage_called                           ;
    ldx starship_shields_active                                       ;
    beq shields_are_active                                            ;
    asl                                                               ;
    bcc skip13                                                        ;
    inc damage_high                                                   ;
skip13
    asl                                                               ;
    bcc shields_are_active                                            ;
    inc damage_high                                                   ;
shields_are_active
    ldx value_of_x_when_incur_damage_called                           ;
incur_low_damage
    clc                                                               ;
    adc damage_low                                                    ;
    sta damage_low                                                    ;
    bcc return11                                                      ;
    inc damage_high                                                   ;
return11
    rts                                                               ;

update_various_starship_statuses_on_screen
    jsr apply_damage_to_starship_energy                               ;
    jsr plot_starship_velocity_and_rotation_on_gauges                 ;
    jmp flash_energy_when_low                                         ;

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
    cmp minimum_energy_value_to_avoid_starship_destruction            ;
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
    sta y_pixels                                                      ;
    inc screen_start_high                                             ;
plot_energy_change_loop
    lda #5                                                            ;
    jsr plot_vertical_line                                            ;
    dec x_pixels                                                      ;
    lda y_pixels                                                      ;
    sec                                                               ;
    sbc #5                                                            ;
    sta y_pixels                                                      ;
    lda #$0c                                                          ;
    cmp x_pixels                                                      ;
    bcc skip_moving_to_next_bar                                       ;
    lda y_pixels                                                      ;
    clc                                                               ;
    adc #8                                                            ;
    sta y_pixels                                                      ;
    lda #$3e                                                          ;
    sta x_pixels                                                      ;
skip_moving_to_next_bar
    dec output_fraction                                               ;
    lda output_fraction                                               ;
    cmp output_pixels                                                 ;
    bne plot_energy_change_loop                                       ;
    dec screen_start_high                                             ;
return12
    rts                                                               ;

activate_shields_when_enemy_ship_enters_main_square
    lda maximum_number_of_enemy_ships                                 ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
activate_shields_when_enemy_ship_enters_main_square_loop
    lda enemy_ships_on_screen,x                                       ;
    beq enemy_ship_is_on_screen                                       ;
    txa                                                               ;
    clc                                                               ;
    adc #$0b                                                          ;
    tax                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    bne activate_shields_when_enemy_ship_enters_main_square_loop      ;
    lda starship_shields_active                                       ;
    bne return13                                                      ;
    jmp plot_top_and_right_edge_of_long_range_scanner_with_blank_text ;

enemy_ship_is_on_screen
    lda starship_shields_active                                       ;
    beq return13                                                      ;
    jmp unplot_long_range_scanner_if_shields_inactive                 ;

return13
    rts                                                               ;

plot_vertical_line
    sta temp3                                                         ;
plot_vertical_line_loop
    jsr eor_pixel                                                     ;
    inc y_pixels                                                      ;
    dec temp3                                                         ;
    bne plot_vertical_line_loop                                       ;
    rts                                                               ;

plot_horizontal_line
    sta temp3                                                         ;
plot_horizontal_line_loop
    jsr eor_pixel                                                     ;
    inc x_pixels                                                      ;
    dec temp3                                                         ;
    bne plot_horizontal_line_loop                                     ;
    rts                                                               ;

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
    jsr explode_enemy_ship                                            ;
return14
    rts                                                               ;

plot_enemy_ship
    stx temp8                                                         ;
    lda enemy_ships_type,x                                            ;
    sta enemy_ship_type                                               ;
    cmp #2                                                            ;
    bcc enemy_ship_isnt_cloaked                                       ;
    jmp enemy_ship_is_cloaked                                         ;

enemy_ship_isnt_cloaked
    lda enemy_ships_previous_x_pixels,x                               ;
    sta temp10                                                        ;
    lda enemy_ships_previous_x_pixels1,x                              ;
    sta temp9                                                         ;
    lda enemy_ships_previous_angle,x                                  ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    sta temp11                                                        ;
    clc                                                               ;
    adc #$10                                                          ;
    and #$1f                                                          ;
    tay                                                               ;
    lda sine_table,y                                                  ;
    clc                                                               ;
    bpl skip_set_carry_sine                                           ;
    sec                                                               ;
skip_set_carry_sine
    ror                                                               ;
    clc                                                               ;
    adc temp10                                                        ;
    sta enemy_ship_x_plus_half_sine                                   ;
    lda cosine_table,y                                                ;
    clc                                                               ;
    bpl skip_set_carry_cosine                                         ;
    sec                                                               ;
skip_set_carry_cosine
    ror                                                               ;
    clc                                                               ;
    adc temp9                                                         ;
    sta enemy_ship_y_plus_half_cosine                                 ;
    lda temp11                                                        ;
    clc                                                               ;
    adc #3                                                            ;
    and #$1f                                                          ;
    tay                                                               ;
    sta segment_angle                                                 ;
    lda enemy_ship_x_plus_half_sine                                   ;
    clc                                                               ;
    adc sine_table,y                                                  ;
    sta x_pixels                                                      ;
    lda enemy_ship_y_plus_half_cosine                                 ;
    clc                                                               ;
    adc cosine_table,y                                                ;
    sta y_pixels                                                      ;
    lda #8                                                            ;
    sta segment_length                                                ;
    lda #1                                                            ;
    sta output_pixels                                                 ;
    jsr plot_segment                                                  ;
    lda temp11                                                        ;
    clc                                                               ;
    adc #$14                                                          ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda #$0a                                                          ;
    sta segment_length                                                ;
    lda #$ff                                                          ;
    sta output_pixels                                                 ;
    jsr plot_segment                                                  ;
    lda temp11                                                        ;
    clc                                                               ;
    adc #$15                                                          ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda #9                                                            ;
    sta segment_length                                                ;
    lda #1                                                            ;
    sta output_pixels                                                 ;
    jsr plot_segment                                                  ;
    lda enemy_ship_type                                               ;
    beq regular_ship                                                  ;
    lda temp10                                                        ;
    sta x_pixels                                                      ;
    lda temp9                                                         ;
    jmp long_ship                                                     ;

regular_ship
    lda enemy_ship_x_plus_half_sine                                   ;
    sta x_pixels                                                      ;
    lda enemy_ship_y_plus_half_cosine                                 ;
long_ship
    sta y_pixels                                                      ;
    lda temp11                                                        ;
    clc                                                               ;
    adc #$14                                                          ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda #8                                                            ;
    sta segment_length                                                ;
    jsr plot_segment                                                  ;
    lda temp11                                                        ;
    clc                                                               ;
    adc #4                                                            ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda #9                                                            ;
    sta segment_length                                                ;
    jsr plot_segment                                                  ;
enemy_ship_is_cloaked
    ldx temp8                                                         ;
    rts                                                               ;

starship_has_exploded
    !byte 0                                                           ;
starship_explosion_address_low
    !byte <starship_explosion_table                                   ;
starship_explosion_address_high
    !byte >starship_explosion_table                                   ;
starship_explosion_size
    !byte $40                                                         ;
maximum_starship_explosion_countdown
    !byte $50                                                         ;
starship_explosion_countdown
    !byte 0                                                           ;
number_of_bytes_per_enemy_explosion
    !byte $3f                                                         ;
create_new_enemy_explosion_piece_after_one_dies
    !byte 0                                                           ;
rnd_1
    !byte $ca                                                         ;
rnd_2
    !byte $48                                                         ;
keyboard_or_joystick
    !byte 0                                                           ;
sound_enabled
    !byte 0                                                           ;
escape_capsule_launched
    !byte 0                                                           ;
damage_from_enemy_torpedo
    !byte $10                                                         ;
frame_of_starship_explosion_after_which_no_sound
    !byte $11                                                         ;
escape_capsule_sound_channel
    !byte 0                                                           ;
enemy_ship_fired_torpedo
    !byte 0                                                           ;
enemy_torpedo_hits_against_starship
    !byte 0                                                           ;
enemy_ship_was_hit
    !byte 0                                                           ;
damage_to_enemy_ship_from_other_collision
    !byte $ea                                                         ;
how_enemy_ship_was_damaged
    !byte $ea                                                         ;
enemy_ships_explosion_number
    !byte 0, 0, 0, 0, 0, 0, 0, 0                                      ;
enemy_explosion_address_low_table
    !byte <(enemy_explosion_tables + $0000)                           ;
    !byte <(enemy_explosion_tables + $0040)                           ;
    !byte <(enemy_explosion_tables + $0080)                           ;
    !byte <(enemy_explosion_tables + $00c0)                           ;
    !byte <(enemy_explosion_tables + $0100)                           ;
    !byte <(enemy_explosion_tables + $0140)                           ;
    !byte <(enemy_explosion_tables + $0180)                           ;
    !byte <(enemy_explosion_tables + $01c0)                           ;
    !byte <(enemy_explosion_tables + $0200)                           ;
    !byte <(enemy_explosion_tables + $0240)                           ;
    !byte <(enemy_explosion_tables + $0280)                           ;
    !byte <(enemy_explosion_tables + $02c0)                           ;
    !byte <(enemy_explosion_tables + $0300)                           ;
    !byte <(enemy_explosion_tables + $0340)                           ;
    !byte <(enemy_explosion_tables + $0380)                           ;
    !byte <(enemy_explosion_tables + $03c0)                           ;
enemy_explosion_address_high_table
    !byte >(enemy_explosion_tables + $0000)                           ;
    !byte >(enemy_explosion_tables + $0040)                           ;
    !byte >(enemy_explosion_tables + $0080)                           ;
    !byte >(enemy_explosion_tables + $00c0)                           ;
    !byte >(enemy_explosion_tables + $0100)                           ;
    !byte >(enemy_explosion_tables + $0140)                           ;
    !byte >(enemy_explosion_tables + $0180)                           ;
    !byte >(enemy_explosion_tables + $01c0)                           ;
    !byte >(enemy_explosion_tables + $0200)                           ;
    !byte >(enemy_explosion_tables + $0240)                           ;
    !byte >(enemy_explosion_tables + $0280)                           ;
    !byte >(enemy_explosion_tables + $02c0)                           ;
    !byte >(enemy_explosion_tables + $0300)                           ;
    !byte >(enemy_explosion_tables + $0340)                           ;
    !byte >(enemy_explosion_tables + $0380)                           ;
    !byte >(enemy_explosion_tables + $03c0)                           ;
enemy_explosion_piece_ageing_table
    !byte $0f, $11, $13, $15                                          ;
starship_explosion_piece_ageing_table
    !byte 5  , 6  , 7  , 8  , 9  , $0a, $0b, $0c                      ;
plot_stars
    lda #<star_table                                                  ;
    sta temp0_low                                                     ;
    lda #>star_table                                                  ;
    sta temp0_high                                                    ;
    lda maximum_number_of_stars                                       ;
    sta enemy_ships_still_to_consider                                 ;
plot_stars_loop
    ldy #1                                                            ;
    lda (temp0_low),y                                                 ;
    sta x_pixels                                                      ;
    ldy #3                                                            ;
    lda (temp0_low),y                                                 ;
    sta y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #4                                                            ;
    sta temp0_low                                                     ;
    bcc skip17                                                        ;
    inc temp0_high                                                    ;
skip17
    dec enemy_ships_still_to_consider                                 ;
    bne plot_stars_loop                                               ;
    rts                                                               ;

initialise_stars_at_random_positions
    lda #<star_table                                                  ;
    sta temp0_low                                                     ;
    lda #>star_table                                                  ;
    sta temp0_high                                                    ;
    lda maximum_number_of_stars                                       ;
    sta enemy_ships_still_to_consider                                 ;
initialise_stars_at_random_positions_loop
    jsr random_number_generator                                       ;
    ldy #1                                                            ;
    lda rnd_1                                                         ;
    sta (temp0_low),y                                                 ;
    ldy #3                                                            ;
    lda rnd_2                                                         ;
    sta (temp0_low),y                                                 ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #4                                                            ;
    sta temp0_low                                                     ;
    bcc skip18                                                        ;
    inc temp0_high                                                    ;
skip18
    dec enemy_ships_still_to_consider                                 ;
    bne initialise_stars_at_random_positions_loop                     ;
    rts                                                               ;

plot_starship
    ldx #$0f                                                          ;
plot_starship_top_loop
    lda user_defined_characters,x                                     ;
    eor starship_top_screen_address,x                                 ;
    sta starship_top_screen_address,x                                 ;
    dex                                                               ;
    bpl plot_starship_top_loop                                        ;
    ldx #$0f                                                          ;
plot_starship_bottom_loop
    lda user_defined_characters + 16,x                                ;
    eor starship_bottom_screen_address,x                              ;
    sta starship_bottom_screen_address,x                              ;
    dex                                                               ;
    bpl plot_starship_bottom_loop                                     ;
    rts                                                               ;

explode_starship
    lda starship_explosion_address_low                                ;
    sta temp0_low                                                     ;
    lda starship_explosion_address_high                               ;
    sta temp0_high                                                    ;
    lda starship_explosion_size                                       ;
    sta enemy_ships_still_to_consider                                 ;
plot_starship_explosion_loop
    jsr plot_starship_explosion_piece                                 ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #3                                                            ;
    sta temp0_low                                                     ;
    bcc skip19                                                        ;
    inc temp0_high                                                    ;
skip19
    dec enemy_ships_still_to_consider                                 ;
    bne plot_starship_explosion_loop                                  ;
    inc starship_has_exploded                                         ;
    lda rnd_1                                                         ;
    ora #$10                                                          ;
    sta rnd_1                                                         ;
    jsr turn_scanner_to_static                                        ;
    jmp plot_starship                                                 ;

plot_starship_explosion
    dec starship_explosion_countdown                                  ;
    bne starship_explosion_continuing                                 ;
    jmp end_of_command                                                ;

starship_explosion_continuing
    lda starship_explosion_address_low                                ;
    sta temp0_low                                                     ;
    lda starship_explosion_address_high                               ;
    sta temp0_high                                                    ;
    lda starship_explosion_size                                       ;
    sta enemy_ships_still_to_consider                                 ;
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
    dec enemy_ships_still_to_consider                                 ;
    bne loop6                                                         ;
    rts                                                               ;

plot_starship_explosion_piece
    ldy #0                                                            ;
    lda (temp0_low),y                                                 ;
    and #$c0                                                          ;
    sta temp8                                                         ;
    ldy #2                                                            ;
    lda (temp0_low),y                                                 ;
    sta temp11                                                        ;
    lda enemy_ships_still_to_consider                                 ;
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
    ldx #3                                                            ;
    lda #0                                                            ;
loop_over_bits_of_sine1
    lsr x_pixels                                                      ; TODO: optimise?
    bcc sine_bit_unset1                                               ;
    clc                                                               ;
    adc temp11                                                        ;
sine_bit_unset1
    ror                                                               ;
    dex                                                               ;
    bne loop_over_bits_of_sine1                                       ;
    ldx x_pixels                                                      ;
    beq skip_uninversion_sine                                         ;
    eor #$ff                                                          ;
skip_uninversion_sine
    eor #$80                                                          ;
    sta x_pixels                                                      ;
    ldx #3                                                            ;
    lda #0                                                            ;
loop_over_bits_of_cosine1
    lsr y_pixels                                                      ; TODO: optimise?
    bcc skip22                                                        ;
    clc                                                               ;
    adc temp11                                                        ;
skip22
    ror                                                               ;
    dex                                                               ;
    bne loop_over_bits_of_cosine1                                     ;
    ldx y_pixels                                                      ;
    beq skip_uninversion_cosine                                       ;
    eor #$ff                                                          ;
skip_uninversion_cosine
    eor #$80                                                          ;
    sta y_pixels                                                      ;
    dey                                                               ;
    lda (temp0_low),y                                                 ;
    bpl plot_variable_size_fragment                                   ;
    lda temp8                                                         ;
    clc                                                               ;
    rol                                                               ;
    rol                                                               ;
    rol                                                               ;
    sta output_pixels                                                 ;
    eor #3                                                            ;
    clc                                                               ;
    adc #1                                                            ;
    sec                                                               ;
    rol                                                               ;
    sta segment_length                                                ;
    inc output_pixels                                                 ;
    iny                                                               ;
    lda (temp0_low),y                                                 ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda x_pixels                                                      ;
    sta temp10                                                        ;
    lda y_pixels                                                      ;
    sta temp9                                                         ;
    jsr plot_segment                                                  ;
    rts                                                               ;

plot_variable_size_fragment
    jsr eor_pixel                                                     ;
    lda temp8                                                         ;
    cmp #$c0                                                          ;
    beq return15                                                      ;
    inc x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    lda temp8                                                         ;
    bmi return15                                                      ;
    inc y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    lda temp8                                                         ;
    bne return15                                                      ;
    inc y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec y_pixels                                                      ;
    dec x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec y_pixels                                                      ;
    inc x_pixels                                                      ;
    jsr eor_pixel                                                     ;
return15
    rts                                                               ;

initialise_starship_explosion_pieces
    lda maximum_starship_explosion_countdown                          ;
    sta starship_explosion_countdown                                  ;
    lda starship_explosion_address_low                                ;
    sta temp0_low                                                     ;
    lda starship_explosion_address_high                               ;
    sta temp0_high                                                    ;
    lda starship_explosion_size                                       ;
    sta enemy_ships_still_to_consider                                 ;
initialise_starship_explosion_pieces_loop
    jsr initialise_starship_explosion_piece                           ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #3                                                            ;
    sta temp0_low                                                     ;
    bcc skip23                                                        ;
    inc temp0_high                                                    ;
skip23
    dec enemy_ships_still_to_consider                                 ;
    bne initialise_starship_explosion_pieces_loop                     ;
    rts                                                               ;

initialise_starship_explosion_piece
    jsr random_number_generator                                       ;
    ldy #2                                                            ;
    lda rnd_1                                                         ;
    and #7                                                            ;
    sta (temp0_low),y                                                 ;
    dey                                                               ;
    lda rnd_2                                                         ;
    lsr                                                               ;
    sta (temp0_low),y                                                 ;
    lda rnd_1                                                         ;
    and #$3c                                                          ;
    bne not_a_segment                                                 ;
    lda (temp0_low),y                                                 ;
    ora #$80                                                          ;
    sta (temp0_low),y                                                 ;
not_a_segment
    dey                                                               ;
    lda rnd_1                                                         ;
    and #$1f                                                          ;
    clc                                                               ;
    adc #1                                                            ;
    sta (temp0_low),y                                                 ;
    rts                                                               ;

explode_enemy_ship
    lda enemy_ships_previous_on_screen,x                              ;
    bne skip_unplotting                                               ;
    jsr plot_enemy_ship                                               ;
skip_unplotting
    lda enemy_ship_explosion_duration                                 ;
    sta enemy_ships_flags_or_explosion_timer,x                        ;
    ldy maximum_number_of_enemy_ships                                 ;
    lda #0                                                            ;
find_free_explosion_slot_loop
    cmp enemy_ships_explosion_number - 1,y                            ;
    bcs skip24                                                        ;
    lda enemy_ships_explosion_number - 1,y                            ;
skip24
    dey                                                               ;
    bne find_free_explosion_slot_loop                                 ;
    cmp maximum_number_of_explosions                                  ;
    beq too_many_explosions                                           ;
    clc                                                               ;
    adc #1                                                            ;
too_many_explosions
    ldy enemy_ships_still_to_consider                                 ;
    sta enemy_ships_explosion_number - 1,y                            ;
    tay                                                               ;
    lda enemy_explosion_address_low_table - 1,y                       ;
    sta temp5                                                         ;
    lda enemy_explosion_address_high_table - 1,y                      ;
    sta temp6                                                         ;
    ldy number_of_bytes_per_enemy_explosion                           ;
loop_c1f97
    jsr random_number_generator                                       ;
enemy_explosion_initialisation_loop
    lda rnd_2                                                         ;
    and #$3f                                                          ;
    sta (temp5),y                                                     ;
    dey                                                               ;
    lda rnd_1                                                         ;
    and #$3f                                                          ;
    clc                                                               ;
    adc #$68                                                          ;
    sta (temp5),y                                                     ;
    dey                                                               ;
    bpl loop_c1f97                                                    ;
    jmp score_points_for_destroying_enemy_ship                        ;

update_enemy_explosion_pieces
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    cmp frame_of_enemy_ship_explosion_after_which_no_collisions       ;
    lda #1                                                            ;
    bcs skip25                                                        ;
    lda #0                                                            ;
skip25
    sta create_new_enemy_explosion_piece_after_one_dies               ;
    jsr plot_enemy_ship_or_explosion_segments                         ;
    ldy number_of_bytes_per_enemy_explosion                           ;
update_enemy_explosion_pieces_loop
    dey                                                               ;
    lda (temp5),y                                                     ;
    beq move_to_next_piece                                            ;
    jsr plot_enemy_explosion_fragment                                 ;
    lda (temp5),y                                                     ;
    and #3                                                            ;
    tax                                                               ;
    lda enemy_explosion_piece_ageing_table,x                          ;
    dey                                                               ;
    clc                                                               ;
    adc (temp5),y                                                     ;
    bcc piece_still_active                                            ;
    lda create_new_enemy_explosion_piece_after_one_dies               ;
    sta (temp5),y                                                     ;
    beq move_to_next_piece                                            ;
    jsr random_number_generator                                       ;
    lda rnd_2                                                         ;
    lsr                                                               ;
    and #$3f                                                          ;
    iny                                                               ;
    sta (temp5),y                                                     ;
    jmp move_to_next_piece_after_dey                                  ;

piece_still_active
    sta (temp5),y                                                     ;
    iny                                                               ;
    inx                                                               ;
    txa                                                               ;
    asl                                                               ;
    asl                                                               ;
    clc                                                               ;
    adc (temp5),y                                                     ;
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
    ldy number_of_bytes_per_enemy_explosion                           ;
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

plot_enemy_explosion_fragment
    lda (temp5),y                                                     ;
    and #$c0                                                          ;
    sta segment_angle                                                 ;
    iny                                                               ;
    lda (temp5),y                                                     ;
    lsr                                                               ;
    lsr                                                               ;
    sta temp11                                                        ;
    tya                                                               ;
    lsr                                                               ;
    tax                                                               ;
    lda sine_table,x                                                  ;
    bpl skip_inversion_sine1                                          ;
    eor #$1f                                                          ;
    clc                                                               ;
    adc #1                                                            ;
skip_inversion_sine1
    sta x_pixels                                                      ;
    lda cosine_table,x                                                ;
    bpl skip_inversion_cosine1                                        ;
    eor #$1f                                                          ;
    clc                                                               ;
    adc #1                                                            ;
skip_inversion_cosine1
    sta y_pixels                                                      ;
    ldx #3                                                            ;
    lda #0                                                            ;
loop_over_bits_of_sine2
    lsr x_pixels                                                      ; TODO: optimise?
    bcc sine_bit_unset2                                               ;
    clc                                                               ;
    adc temp11                                                        ;
sine_bit_unset2
    ror                                                               ;
    dex                                                               ;
    bne loop_over_bits_of_sine2                                       ;
    ldx x_pixels                                                      ;
    beq skip_uninversion_sine1                                        ;
    eor #$ff                                                          ;
skip_uninversion_sine1
    clc                                                               ;
    adc temp10                                                        ;
    sta x_pixels                                                      ;
    ldx #3                                                            ;
    lda #0                                                            ;
loop_over_bits_of_cosine2
    lsr y_pixels                                                      ; TODO: optimise?
    bcc cosine_bit_unset1                                             ;
    clc                                                               ;
    adc temp11                                                        ;
cosine_bit_unset1
    ror                                                               ;
    dex                                                               ;
    bne loop_over_bits_of_cosine2                                     ;
    ldx y_pixels                                                      ;
    beq skip_uninversion_cosine1                                      ;
    eor #$ff                                                          ;
skip_uninversion_cosine1
    clc                                                               ;
    adc temp9                                                         ;
    sta y_pixels                                                      ;
    sty temp11                                                        ;
    jsr eor_pixel_within_box_around_origin                            ;
    lda segment_angle                                                 ;
    bmi leave_after_restoring_y                                       ;
    inc x_pixels                                                      ;
    jsr eor_pixel_within_box_around_origin                            ;
    lda segment_angle                                                 ;
    bne leave_after_restoring_y                                       ;
    inc y_pixels                                                      ;
    jsr eor_pixel_within_box_around_origin                            ;
    dec x_pixels                                                      ;
    jsr eor_pixel_within_box_around_origin                            ;
leave_after_restoring_y
    ldy temp11                                                        ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_enemy_ship_or_explosion_segments
    stx temp7                                                         ;
    lda enemy_ships_previous_x_pixels,x                               ;
    sta temp10                                                        ;
    lda enemy_ships_previous_x_pixels1,x                              ;
    sta temp9                                                         ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    cmp frame_of_enemy_ship_explosion_after_which_no_collisions       ;
    bcc return16                                                      ;
    cmp frame_of_enemy_ship_explosion_after_which_no_segments_are_plotted ;
    bcc plot_enemy_explosion_segments                                 ;
    jsr plot_enemy_ship                                               ;
    rts                                                               ;

return16
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_enemy_explosion_segments
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda temp10                                                        ;
    sta x_pixels                                                      ;
    lda temp9                                                         ;
    sta y_pixels                                                      ;
    lda #$0a                                                          ;
    sta segment_length                                                ;
    lda #1                                                            ;
    sta output_pixels                                                 ;
    jsr plot_segment                                                  ;
    ldx temp7                                                         ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    eor #$1f                                                          ;
    and #$1f                                                          ;
    sta segment_angle                                                 ;
    lda #7                                                            ;
    sta segment_length                                                ;
    inc output_pixels                                                 ;
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
    sta output_pixels                                                 ;
    jsr plot_segment                                                  ;
    rts                                                               ;

random_number_generator
    lda rnd_1                                                         ;
    sta y_pixels                                                      ;
    lda rnd_2                                                         ;
    sta x_pixels                                                      ;
    lda #8                                                            ;
    sta temp11                                                        ;
    lda #$d5                                                          ;
random_number_generator_loop
random_number_generator_loop1
    lsr x_pixels                                                      ;
    ror y_pixels                                                      ;
    bcc lowest_bit_unset                                              ;
    clc                                                               ;
    adc #$25                                                          ;
lowest_bit_unset
    ror                                                               ;
    ror temp8                                                         ;
    dec temp11                                                        ;
    bne random_number_generator_loop                                  ;
    clc                                                               ;
    adc rnd_1                                                         ;
    sta rnd_2                                                         ;
    lda temp8                                                         ;
    sta rnd_1                                                         ;
    rts                                                               ;

game_key_table
    !byte $9e                                                         ;
    !byte $bd                                                         ;
    !byte $9a                                                         ;
    !byte $99                                                         ;
    !byte $aa                                                         ;
    !byte $ac                                                         ;
    !byte $bc                                                         ;
    !byte $df                                                         ;
    !byte $8e                                                         ;
    !byte $ce                                                         ;
    !byte $ee                                                         ;
    !byte $9c                                                         ;
    !byte $9b                                                         ;
    !byte $ad                                                         ;
    !byte $96                                                         ;
screen_border_string
    !byte 0  , 0  , 3  , $ff, 5  , $19                                ;
    !byte 3  , $ff, 3  , $ff, 5  , $19                                ;
    !byte 3  , $ff, 0  , 0  , 5  , $19                                ;
    !byte 0  , 0  , 0  , 0  , 5  , $19                                ;
    !byte 0  , 0  , 4  , $ff, 5  , $19                                ;
    !byte 2  , $fc, 4  , $ff, 5  , $19                                ;
    !byte 2  , $fc, 4  , 0  , 4  , $19                                ;
envelope1
    !byte 1  , 0  , $f8, $fa, $0f, 4  , $0a, 8  , $7f, $fe, $fc, $ff, $7e, $64 ;
envelope2
    !byte 2  , 0  , $f8, $fa, $fe, 4  , $0a, 8  , $7f, $fe, $ff, $ff, $64, $50 ;
envelope3
    !byte 3  , $86, $ff, 0  , 1  , 3  , 1  , 2  , $7f, $ff, $fd, $fd, $7e, $78 ;
envelope4
    !byte 4  , 0  , $10, $f0, $10, 4  , 8  , 4  , $7f, $ff, $ff, $ff, $7e, $64 ;

sound_0
    !byte 0,0,0,0,0,0,0,0                                             ; TODO: Add sound?
; ----------------------------------------------------------------------------------
; Exploding starship 1
; ----------------------------------------------------------------------------------
sound_1
    !byte $11, 0  , 0  , 0                                            ;
sound_1_pitch
    !byte 0, 0, 8, 0                                                  ;
; ----------------------------------------------------------------------------------
; Exploding starship 2
; ----------------------------------------------------------------------------------
sound_2
    !byte $10, 0                                                      ;
sound_1_volume_low
    !byte 0                                                           ;
sound_1_volume_high
    !byte 0, 7, 0, 8, 0                                               ;
; ----------------------------------------------------------------------------------
; Starship fired torpedo
; ----------------------------------------------------------------------------------
sound_3
    !byte $13, 0  , 1  , 0  , $80, 0  , 4  , 0                        ;
; ----------------------------------------------------------------------------------
; Enemy ship fired torpedo
; ----------------------------------------------------------------------------------
sound_4
    !byte $12, 0  , 2  , 0  , $c0, 0  , $1f, 0                        ;
; ----------------------------------------------------------------------------------
; Enemy ship hit by torpedo
; ----------------------------------------------------------------------------------
sound_5
    !byte $12, 0  , 4  , 0  , $40, 0  , 8  , 0                        ;
; ----------------------------------------------------------------------------------
; Starship hit by torpedo
; ----------------------------------------------------------------------------------
sound_6
    !byte $12, 0  , 4  , 0  , $be, 0  , 8  , 0                        ;
; ----------------------------------------------------------------------------------
; Enemy ships collided with each other
; ----------------------------------------------------------------------------------
sound_7
    !byte $13, 0  , 2  , 0  , $6c, 0  , 8  , 0                        ;
; ----------------------------------------------------------------------------------
; Escape capsule launched
; ----------------------------------------------------------------------------------
sound_8
    !byte $13, 0                                                      ;
sound_8_volume_low
    !byte 0                                                           ;
sound_8_volume_high
    !byte 0  , $64, 0  , 4  , 0                                       ;
; ----------------------------------------------------------------------------------
; Low energy warning
; ----------------------------------------------------------------------------------
sound_9
    !byte $11, 0  , $f1, $ff, $c8, 0  , 4  , 0                        ;
; ----------------------------------------------------------------------------------
set_foreground_colour_to_white_string
    !byte 0  , 0  , 0  , 7  , 1  , $13                                ;
set_foreground_colour_to_black_string
    !byte 0  , 0  , 0  , 0  , 1  , $13                                ;
set_background_colour_to_black_string
    !byte 0  , 0  , 0  , 0  , 0  , $13                                ;
energy_string
    !text "YGRENE"                                                    ;
    !byte $11, $21, $1f                                               ;
one_two_three_four_string
    !byte 4  , $34, $0a, 8  , $33, $0a, 8  , $32, $0a, 8  , $31, 5    ;
    !byte 1  , $ac, 4  , 8  , 4  , $19                                ;
shields_string
    !text "NO"                                                        ;
    !byte 5  , $23, $1f                                               ;
    !text "SDLEIHS"                                                   ;
    !byte 2  , $21, $1f                                               ;
blank_string
    !byte $20, $20, 5  , $23, $1f                                     ;
    !text "       "                                                   ;
    !byte 2  , $21, $1f                                               ;
enable_cursor_string
    !byte 0  , 0  , 0  , 0  , 0  , 0  , $60, $0a, 0  , $17            ;
disable_cursor_string
    !byte 0  , 0  , 0  , 0  , 0  , 0  , $3c, $0a, 0  , $17            ;
plot_energy_bar_edges
    lda #$93                                                          ;
    sta y_pixels                                                      ;
    lda #5                                                            ;
    sta temp8                                                         ;
    inc screen_start_high                                             ;
plot_energy_bar_edges_loop
    lda #$0d                                                          ;
    sta x_pixels                                                      ;
    lda #$32                                                          ;
    jsr plot_horizontal_line                                          ;
    lda y_pixels                                                      ;
    clc                                                               ;
    adc #8                                                            ;
    sta y_pixels                                                      ;
    dec temp8                                                         ;
    bne plot_energy_bar_edges_loop                                    ;
    lda #$93                                                          ;
    sta y_pixels                                                      ;
    lda #$0c                                                          ;
    sta x_pixels                                                      ;
    lda #$21                                                          ;
    jsr plot_vertical_line                                            ;
    dec screen_start_high                                             ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_energy_text
    ldx #8                                                            ;
loop
    lda energy_string,x                                               ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl loop                                                          ;
    ldx #$11                                                          ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_one_two_three_four_text
    ldx #$11                                                          ;
loop1
    lda one_two_three_four_string,x                                   ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl loop1                                                         ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_shields_text
    ldx #$0e                                                          ;
loop2
    lda shields_string,x                                              ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl loop2                                                         ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
plot_blank_text
    ldx #$0e                                                          ;
loop3
    lda blank_string,x                                                ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl loop3                                                         ;
    rts                                                               ;

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
    jsr osword                                                        ;
    rts                                                               ;

plot_screen_border
    ldx #$29                                                          ;
loop_c22fc
    lda screen_border_string,x                                        ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl loop_c22fc                                                    ;
    rts                                                               ;

set_foreground_colour_to_white
    ldx #5                                                            ;
loop_c2308
    lda set_foreground_colour_to_white_string,x                       ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl loop_c2308                                                    ;
    rts                                                               ;

set_foreground_colour_to_black
    ldx #5                                                            ;
loop_c2314
    lda set_foreground_colour_to_black_string,x                       ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl loop_c2314                                                    ;
    rts                                                               ;

set_background_colour_to_black
    ldx #5                                                            ;
loop_c2320
    lda set_background_colour_to_black_string,x                       ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl loop_c2320                                                    ;
    rts                                                               ;

enable_cursor
    ldx #9                                                            ;
enable_cursor_loop
    lda enable_cursor_string,x                                        ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl enable_cursor_loop                                            ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
disable_cursor
    ldx #9                                                            ;
loop4
disable_cursor_loop
    lda disable_cursor_string,x                                       ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl loop4                                                         ;
    rts                                                               ;

check_for_keypresses
    ldy escape_capsule_launched                                       ;
    bne return17                                                      ;
    ldy keyboard_or_joystick                                          ;
    beq use_keyboard_input                                            ;
    jsr get_joystick_input                                            ;
    lda #4                                                            ;
    sta temp8                                                         ;
    bne check_for_additional_keys                                     ;
use_keyboard_input
    lda #$ff                                                          ;
    sta temp8                                                         ;
    jsr check_key                                                     ;
    beq not_rotate_anticlockwise                                      ;
    dec rotation_delta                                                ;
not_rotate_anticlockwise
    jsr check_key                                                     ;
    beq not_rotate_clockwise                                          ;
    inc rotation_delta                                                ;
not_rotate_clockwise
    jsr check_key                                                     ;
    beq not_accelerate                                                ;
    inc velocity_delta                                                ;
not_accelerate
    jsr check_key                                                     ;
    beq not_decelerate                                                ;
    dec velocity_delta                                                ;
not_decelerate
    jsr check_key                                                     ;
    beq check_for_additional_keys                                     ;
    inc fire_pressed                                                  ;
check_for_additional_keys
    jsr check_key                                                     ;
    beq not_launch_starboard_escape_capsule                           ;
    jmp launch_escape_capsule_starboard                               ;

not_launch_starboard_escape_capsule
    jsr check_key                                                     ;
    beq not_launch_port_escape_capsule                                ;
    jmp launch_escape_capsule_port                                    ;

not_launch_port_escape_capsule
    lda keyboard_or_joystick                                          ;
    beq is_keyboard                                                   ;
    lda #$0a                                                          ;
    sta temp8                                                         ;
    bne skip_damper_keys                                              ;
is_keyboard
    lda rotation_delta                                                ;
    ora velocity_delta                                                ;
    bne return17                                                      ;
    jsr check_key                                                     ;
    beq not_enable_rotation_damper                                    ;
    lda #1                                                            ;
    sta rotation_damper                                               ;
return17
    rts                                                               ;

not_enable_rotation_damper
    jsr check_key                                                     ;
    beq not_enable_velocity_damper                                    ;
    lda #1                                                            ;
    sta velocity_damper                                               ;
    rts                                                               ;

not_enable_velocity_damper
    jsr check_key                                                     ;
    beq not_disable_rotation_damper                                   ;
    lda #0                                                            ;
    sta rotation_damper                                               ;
    rts                                                               ;

not_disable_rotation_damper
    jsr check_key                                                     ;
    beq skip_damper_keys                                              ;
    lda #0                                                            ;
    sta velocity_damper                                               ;
    rts                                                               ;

skip_damper_keys
    jsr check_key                                                     ;
    beq not_enable_shields                                            ;
    inc shields_state_delta                                           ;
    rts                                                               ;

not_enable_shields
    jsr check_key                                                     ;
    beq not_disable_shields                                           ;
    dec shields_state_delta                                           ;
    rts                                                               ;

not_disable_shields
    jsr check_key                                                     ;
    beq check_for_copy                                                ;
    lda #1                                                            ;
    sta starship_automatic_shields                                    ;
    rts                                                               ;

check_for_copy
    jsr check_key                                                     ;
    beq return18                                                      ;
    jmp pause_game                                                    ;

return18
    rts                                                               ;

check_key
    inc temp8                                                         ;
    ldx temp8                                                         ;
    lda game_key_table,x                                              ;
    tay                                                               ;
    tax                                                               ;
    lda #osbyte_inkey                                                 ;
    jsr osbyte                                                        ;
    tya                                                               ;
    rts                                                               ;

pause_game
    ldx #inkey_key_delete                                             ;
    ldy #$a6                                                          ;
    lda #osbyte_inkey                                                 ;
    jsr osbyte                                                        ;
    tya                                                               ;
    beq pause_game                                                    ;
    rts                                                               ;

play_sounds
    lda sound_enabled                                                 ;
    beq sound_is_enabled                                              ;
    rts                                                               ;

sound_is_enabled
    lda enemy_torpedo_hits_against_starship                           ;
    beq no_enemy_torpedo_hits_against_starship                        ;
    lda starship_has_exploded                                         ;
    bne skip_explosion_or_firing_sound                                ;
    ldx #$f0                                                          ;
    ldy #$21                                                          ;
    bne play_explosion_or_firing_sound                                ;
no_enemy_torpedo_hits_against_starship
    lda enemy_ship_was_hit                                            ;
    beq no_enemy_ship_was_hit                                         ;
    ldx #$e8                                                          ;
    ldy #$21                                                          ;
    bne play_explosion_or_firing_sound                                ;
no_enemy_ship_was_hit
    lda enemy_ship_fired_torpedo                                      ;
    beq skip_explosion_or_firing_sound                                ;
    ldx #<(sound_4)                                                   ;
    ldy #>(sound_4)                                                   ;
play_explosion_or_firing_sound
    lda #osword_sound                                                 ;
    jsr osword                                                        ;
skip_explosion_or_firing_sound
    ldy #0                                                            ;
    lda escape_capsule_launched                                       ;
    beq set_escape_capsule_sound_channel                              ;
    lda escape_capsule_destroyed                                      ;
    bne set_escape_capsule_sound_channel                              ;
    iny                                                               ;
set_escape_capsule_sound_channel
    sty escape_capsule_sound_channel                                  ;
    lda starship_has_exploded                                         ;
    bne play_sound_for_exploding_starship                             ;
    lda score_delta_low                                               ;
    ora score_delta_high                                              ;
    beq skip_sound_for_exploding_enemy_ship                           ;
    ldx #<(sound_11)                                                  ;
    ldy #>(sound_11)                                                  ;
    lda #osword_sound                                                 ;
    jsr osword                                                        ;
skip_sound_for_exploding_enemy_ship
    lda escape_capsule_sound_channel                                  ;
    beq escape_capsule_not_launched                                   ;
    jmp play_escape_capsule_sound                                     ;

escape_capsule_not_launched
    lda sound_needed_for_low_energy                                   ;
    beq play_starship_engine_sound                                    ;
    dec sound_needed_for_low_energy                                   ;
    ldx #<(sound_9)                                                   ;
    ldy #>(sound_9)                                                   ;
    lda #osword_sound                                                 ;
    jsr osword                                                        ;
    jmp consider_torpedo_sound                                        ;

play_starship_engine_sound
    lda starship_velocity_low                                         ;
    clc                                                               ;
    adc #$40                                                          ;
    sta x_pixels                                                      ;
    lda #0                                                            ;
    adc starship_velocity_high                                        ;
    asl x_pixels                                                      ;
    rol                                                               ;
    adc starship_rotation_magnitude                                   ;
    sta sound_10_pitch                                                ;
    cmp #$0a                                                          ;
    bcc skip_ceiling                                                  ;
    lda #9                                                            ;
    clc                                                               ;
skip_ceiling
    eor #$ff                                                          ;
    adc #1                                                            ;
    sta sound_10_volume_low                                           ;
    lda #$ff                                                          ;
    adc #0                                                            ;
    sta sound_10_volume_high                                          ;
    ldx #<(sound_10)                                                  ;
    ldy #>(sound_10)                                                  ;
    lda #osword_sound                                                 ;
    jsr osword                                                        ;
    jmp consider_torpedo_sound                                        ;

play_sound_for_exploding_starship
    lda starship_explosion_countdown                                  ;
    sec                                                               ;
    sbc frame_of_starship_explosion_after_which_no_sound              ;
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
    clc                                                               ;
skip_ceiling1
    eor #$ff                                                          ;
    adc #1                                                            ;
    sta sound_1_volume_low                                            ;
    lda #$ff                                                          ;
    adc #0                                                            ;
    sta sound_1_volume_high                                           ;
    ldx #<(sound_1)                                                   ;
    ldy #>(sound_1)                                                   ;
    lda #osword_sound                                                 ;
    jsr osword                                                        ;
    ldx #<(sound_2)                                                   ;
    ldy #>(sound_2)                                                   ;
    lda #osword_sound                                                 ;
    jsr osword                                                        ;
skip_starship_explosion_sound
    lda escape_capsule_sound_channel                                  ;
    beq consider_torpedo_sound                                        ;
    lda #3                                                            ;
    sta escape_capsule_sound_channel                                  ;
play_escape_capsule_sound
    ora #$10                                                          ;
    sta sound_8                                                       ;
    lda self_destruct_countdown                                       ;
    and #1                                                            ;
    beq set_volume                                                    ;
    lda self_destruct_countdown                                       ;
    lsr                                                               ;
    lsr                                                               ;
    eor #$ff                                                          ;
    clc                                                               ;
    adc #1                                                            ;
set_volume
    sta sound_8_volume_low                                            ;
    beq set_volume_high                                               ;
    lda #$ff                                                          ;
set_volume_high
    sta sound_8_volume_high                                           ;
    ldx #<(sound_8)                                                   ;
    ldy #>(sound_8)                                                   ;
    lda #osword_sound                                                 ;
    jsr osword                                                        ;
    lda escape_capsule_sound_channel                                  ;
    cmp #3                                                            ;
    beq return19                                                      ;
consider_torpedo_sound
    lda starship_fired_torpedo                                        ;
    beq skip_starship_torpedo_sound                                   ;
    ldx #<(sound_3)                                                   ;
    ldy #>(sound_3)                                                   ;
    lda #osword_sound                                                 ;
    jmp osword                                                        ;

skip_starship_torpedo_sound
    lda enemy_ships_collided_with_each_other                          ;
    beq return19                                                      ;
    ldx #<(sound_7)                                                   ;
    ldy #>(sound_7)                                                   ;
    lda #osword_sound                                                 ;
    jsr osword                                                        ;
return19
    rts                                                               ;

starship_maximum_x_for_collisions_with_enemy_torpedoes
    !byte $86                                                         ;
starship_minimum_x_for_collisions_with_enemy_torpedoes
    !byte $78                                                         ;
starship_maximum_y_for_collisions_with_enemy_torpedoes
    !byte $86                                                         ;
starship_minimum_y_for_collisions_with_enemy_torpedoes
    !byte $7a                                                         ;
starship_maximum_x_for_collisions_with_enemy_ships
    !byte $8c                                                         ;
starship_minimum_x_for_collisions_with_enemy_ships
    !byte $73                                                         ;
starship_maximum_y_for_collisions_with_enemy_ships
    !byte $8c                                                         ;
starship_minimum_y_for_collisions_with_enemy_ships
    !byte $76                                                         ;
enemy_ship_was_hit_by_collision_with_other_enemy_ship
    !byte 4                                                           ;
starship_collided_with_enemy_ship
    !byte 0                                                           ;
frame_of_starship_explosion_after_which_no_collisions
    !byte $4a                                                         ;
enemy_ships_collision_x_difference
    !byte 6                                                           ;
enemy_ships_collision_y_difference
    !byte 5                                                           ;
timer_for_low_energy_warning_sound
    !byte 0                                                           ;
sound_needed_for_low_energy
    !byte 0                                                           ;
energy_flash_timer
    !byte 0                                                           ;
flash_energy_when_low
    lda energy_flash_timer                                            ;
    bne energy_is_already_low                                         ;
    lda starship_energy_divided_by_sixteen                            ;
    cmp #$32                                                          ;
    bcs consider_warning_sound                                        ;
    lda #4                                                            ;
    sta energy_flash_timer                                            ;
    jsr invert_energy_text                                            ;
    jmp consider_warning_sound                                        ;

energy_is_already_low
    dec energy_flash_timer                                            ;
    cmp #2                                                            ;
    bne consider_warning_sound                                        ;
    jsr invert_energy_text                                            ;
consider_warning_sound
    dec timer_for_low_energy_warning_sound                            ;
    bne return20                                                      ;
    lda #8                                                            ;
    sta timer_for_low_energy_warning_sound                            ;
    lda starship_energy_divided_by_sixteen                            ;
    cmp #$19                                                          ;
    bcs return20                                                      ;
    inc sound_needed_for_low_energy                                   ;
return20
    rts                                                               ;

invert_energy_text
    ldy #$2f                                                          ;
invert_energy_text_loop
    lda energy_screen_address,y                                       ;
    eor #$ff                                                          ;
    sta energy_screen_address,y                                       ;
    dey                                                               ;
    bpl invert_energy_text_loop                                       ;
    rts                                                               ;

enemy_ships_can_cloak
    !byte 1                                                           ;
probability_of_enemy_ship_cloaking
    !byte $3f                                                         ;
minimum_energy_for_enemy_ship_to_cloak
    !byte $40                                                         ;
enemy_ship_desired_angle_divided_by_eight
    !byte 0                                                           ;
number_of_live_starship_torpedoes
    !byte 0                                                           ;
starship_fired_torpedo
    !byte $ea                                                         ;
scanner_failure_duration
    !byte $ea                                                         ;
starship_shields_active_before_failure
    !byte $ea                                                         ;
starship_torpedo_type
    !byte 0                                                           ;
handle_enemy_ships_cloaking
    lda enemy_ships_can_cloak                                         ;
    beq return21                                                      ;
    lda maximum_number_of_enemy_ships                                 ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
handle_enemy_ships_cloaking_loop
    lda enemy_ships_type,x                                            ;
    cmp #4                                                            ;
    ror temp8                                                         ;
    bmi enemy_ship_is_already_cloaked                                 ;
    cmp #1                                                            ;
    bne handle_enemy_ships_cloaking_next                              ;
enemy_ship_is_already_cloaked
    ldy enemy_ships_on_screen,x                                       ;
    beq enemy_ship_is_on_screen1                                      ;
    and #3                                                            ;
    sta enemy_ships_type,x                                            ;
    jmp handle_enemy_ships_cloaking_next                              ;

enemy_ship_is_on_screen1
    ldy enemy_ships_energy,x                                          ;
    cpy minimum_energy_for_enemy_ship_to_cloak                        ;
    bcs enemy_ship_has_sufficient_energy_to_cloak                     ;
    asl temp8                                                         ;
    bcc handle_enemy_ships_cloaking_next                              ;
    and #3                                                            ;
    sta enemy_ships_type,x                                            ;
    jsr plot_enemy_ship                                               ;
    jmp handle_enemy_ships_cloaking_next                              ;

enemy_ship_has_sufficient_energy_to_cloak
    asl temp8                                                         ;
    bcs handle_enemy_ships_cloaking_next                              ;
    jsr random_number_generator                                       ;
    lda rnd_2                                                         ;
    and probability_of_enemy_ship_cloaking                            ;
    bne handle_enemy_ships_cloaking_next                              ;
    jsr plot_enemy_ship                                               ;
    lda enemy_ships_type,x                                            ;
    ora #4                                                            ;
    sta enemy_ships_type,x                                            ;
handle_enemy_ships_cloaking_next
    txa                                                               ;
    clc                                                               ;
    adc #$0b                                                          ;
    tax                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    bne handle_enemy_ships_cloaking_loop                              ;
return21
    rts                                                               ;

fire_enemy_torpedo
    lda torpedoes_still_to_consider                                   ;
    beq leave_after_clearing_carry                                    ;
    lda enemy_ships_firing_cooldown,x                                 ;
    and #$0f                                                          ;
    bne leave_after_clearing_carry                                    ;
    ldy #0                                                            ;
find_enemy_torpedo_slot_loop
    lda (temp0_low),y                                                 ;
    beq free_slot                                                     ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #6                                                            ;
    sta temp0_low                                                     ;
    bcc skip26                                                        ;
    inc temp0_high                                                    ;
skip26
    dec torpedoes_still_to_consider                                   ;
    bne find_enemy_torpedo_slot_loop                                  ;
leave_after_clearing_carry
    clc                                                               ;
    rts                                                               ;

free_slot
    lda enemy_ships_angle,x                                           ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    cmp enemy_ship_desired_angle_divided_by_eight                     ;
    bne leave_after_clearing_carry                                    ;
    lda enemy_ships_firing_cooldown,x                                 ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    adc enemy_ships_firing_cooldown,x                                 ;
    sta enemy_ships_firing_cooldown,x                                 ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    and #$10                                                          ;
    beq single_torpedo                                                ;
    jmp fire_enemy_torpedo_cluster                                    ;

single_torpedo
    lda value_used_for_enemy_torpedo_ttl                              ;
    ldy #0                                                            ;
    sta (temp0_low),y                                                 ;
    lda enemy_ships_angle,x                                           ;
    ldy #5                                                            ;
    sta (temp0_low),y                                                 ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    tay                                                               ;
    lda sine_table,y                                                  ;
    clc                                                               ;
    adc enemy_ships_x_pixels,x                                        ;
    sta x_pixels                                                      ;
    lda cosine_table,y                                                ;
    clc                                                               ;
    adc enemy_ships_x_pixels1,x                                       ;
    ldy #4                                                            ;
    sta (temp0_low),y                                                 ;
    ldy #2                                                            ;
    lda x_pixels                                                      ;
    sta (temp0_low),y                                                 ;
    inc enemy_ship_fired_torpedo                                      ;
    stx temp8                                                         ;
    jsr plot_enemy_torpedo                                            ;
    ldx temp8                                                         ;
    dec torpedoes_still_to_consider                                   ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #6                                                            ;
    sta temp0_low                                                     ;
    bcc skip27                                                        ;
    inc temp0_high                                                    ;
skip27
    sec                                                               ;
    rts                                                               ;

calculate_enemy_ship_angle_to_starship
    lda temp9                                                         ;
    sec                                                               ;
    bmi skip_inversion_y3                                             ;
    eor #$ff                                                          ;
    sbc #1                                                            ;
    clc                                                               ;
skip_inversion_y3
    ror temp8                                                         ;
    sec                                                               ;
    sbc #$7f                                                          ;
    sta y_pixels                                                      ;
    lda temp10                                                        ;
    sec                                                               ;
    bmi skip_inversion_x3                                             ;
    eor #$ff                                                          ;
    sbc #1                                                            ;
    clc                                                               ;
skip_inversion_x3
    ror temp8                                                         ;
    sec                                                               ;
    sbc #$7f                                                          ;
    sta x_pixels                                                      ;
    cmp y_pixels                                                      ;
    bcs skip_swap                                                     ;
    ldy y_pixels                                                      ;
    sty x_pixels                                                      ;
    sta y_pixels                                                      ;
skip_swap
    ror temp8                                                         ;
    lda #0                                                            ;
    sta temp11                                                        ;
    ldy #$0c                                                          ;
division_loop
    asl x_pixels                                                      ;
    rol                                                               ;
    cmp y_pixels                                                      ;
    bcc still_less_than                                               ;
    sbc y_pixels                                                      ;
still_less_than
    rol temp11                                                        ;
    bcs ninety_degrees                                                ;
    dey                                                               ;
    bne division_loop                                                 ;
    ldy #$0c                                                          ;
    lda temp11                                                        ;
    cmp #$14                                                          ;
    bcc finished_calculating_partial_angle                            ;
    dey                                                               ;
    cmp #$1e                                                          ;
    bcc finished_calculating_partial_angle                            ;
    dey                                                               ;
    cmp #$35                                                          ;
    bcc finished_calculating_partial_angle                            ;
    dey                                                               ;
    cmp #$a3                                                          ;
    bcc finished_calculating_partial_angle                            ;
    dey                                                               ;
finished_calculating_partial_angle
    tya                                                               ;
adjust_angle_for_inversions_and_swap
    rol temp8                                                         ;
    bcs skip_angle_swap                                               ;
    eor #7                                                            ;
    adc #1                                                            ;
skip_angle_swap
    rol temp8                                                         ;
    bcs skip_angle_inversion_x                                        ;
    eor #$1f                                                          ;
    adc #1                                                            ;
skip_angle_inversion_x
    rol temp8                                                         ;
    bcs skip_angle_inversion_x1                                       ;
    eor #$0f                                                          ;
    adc #1                                                            ;
skip_angle_inversion_x1
    and #$1f                                                          ;
    sta enemy_ship_desired_angle_divided_by_eight                     ;
    rts                                                               ;

ninety_degrees
    lda #8                                                            ;
    bne adjust_angle_for_inversions_and_swap                          ;
collide_enemy_ships
    ldx temp0_low                                                     ;
    lda enemy_ships_energy,x                                          ;
    beq first_ship_is_already_exploding                               ;
    sec                                                               ;
    sbc damage_enemy_ship_incurs_from_collision_with_other_enemy_ship ;
    bcs skip_floor                                                    ;
    lda #0                                                            ;
skip_floor
    sta enemy_ships_energy,x                                          ;
    bne first_ship_survives_collision                                 ;
    jsr explode_enemy_ship                                            ;
    inc enemy_ship_was_hit_by_collision_with_other_enemy_ship         ;
first_ship_survives_collision
    lda enemy_ships_type,x                                            ;
    cmp #4                                                            ;
    bcc first_ship_is_already_exploding                               ;
    and #3                                                            ;
    sta enemy_ships_type,x                                            ;
    lda #1                                                            ;
    sta enemy_ships_previous_on_screen,x                              ;
first_ship_is_already_exploding
    ldy temp1_low                                                     ;
    lda enemy_ships_velocity,x                                        ;
    sta x_pixels                                                      ;
    lda enemy_ships_velocity,y                                        ;
    sta y_pixels                                                      ;
    lda enemy_ships_angle,x                                           ;
    sta temp7                                                         ;
    lda enemy_ships_angle,y                                           ;
    sta enemy_ships_angle,x                                           ;
    lda temp7                                                         ;
    sta enemy_ships_angle,y                                           ;
    sec                                                               ;
    sbc enemy_ships_angle,x                                           ;
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
    lsr x_pixels                                                      ;
    lsr y_pixels                                                      ;
    sec                                                               ;
    sbc #1                                                            ;
    bne angle_loop                                                    ;
skip_velocity_absorption
    lda x_pixels                                                      ;
    sta enemy_ships_velocity,y                                        ;
    lda y_pixels                                                      ;
    sta enemy_ships_velocity,x                                        ;
    lda enemy_ships_collision_x_difference                            ;
    cmp enemy_ships_collision_y_difference                            ;
    bcs use_x_pixels_and_difference                                   ;
    inx                                                               ;
    inx                                                               ;
    inx                                                               ;
    iny                                                               ;
    iny                                                               ;
    iny                                                               ;
    lda enemy_ships_collision_y_difference                            ;
use_x_pixels_and_difference
    sta y_pixels                                                      ;
    lda size_of_enemy_ship_for_collisions_between_enemy_ships         ;
    sec                                                               ;
    sbc y_pixels                                                      ;
    clc                                                               ;
    adc #1                                                            ;
    lsr                                                               ;
    sta y_pixels                                                      ;
    lda enemy_ships_x_pixels,x                                        ;
    cmp enemy_ships_x_pixels,y                                        ;
    bcs dont_swap_two_ships_for_collision                             ;
    sty x_pixels                                                      ;
    txa                                                               ;
    tay                                                               ;
    ldx x_pixels                                                      ;
dont_swap_two_ships_for_collision
    lda enemy_ships_x_pixels,x                                        ;
    clc                                                               ;
    adc y_pixels                                                      ;
    bcs dont_alter_first_ships_position                               ;
    sta enemy_ships_x_pixels,x                                        ;
dont_alter_first_ships_position
    lda enemy_ships_x_pixels,y                                        ;
    sec                                                               ;
    sbc y_pixels                                                      ;
    bcc dont_alter_second_ships_position                              ;
    sta enemy_ships_x_pixels,y                                        ;
dont_alter_second_ships_position
    jmp consider_next_second_enemy_ship                               ;

escape_capsule_destroyed
    !byte 0                                                           ;
self_destruct_countdown
    !byte 0                                                           ;
escape_capsule_on_screen
    !byte 0                                                           ;
escape_capsule_x_fraction
    !byte 0                                                           ;
escape_capsule_x_pixels
    !byte 0                                                           ;
escape_capsule_y_fraction
    !byte 0                                                           ;
escape_capsule_y_pixels
    !byte 0                                                           ;
escape_capsule_launch_direction
    !byte 0                                                           ;
initialise_game_screen
    jsr disable_cursor                                                ;
    jsr set_foreground_colour_to_black                                ;
    jsr set_background_colour_to_black                                ;
    jsr initialise_starship_explosion_pieces                          ;
    jsr initialise_envelopes                                          ;
    jsr plot_starship                                                 ;
    jsr plot_energy_text                                              ;
    jsr plot_one_two_three_four_text                                  ;
    jsr plot_energy_bar_edges                                         ;
    jsr plot_gauge_edges                                              ;
    jsr plot_scanner_grid                                             ;
    jsr plot_command_number                                           ;
    jsr plot_screen_border                                            ;
    jsr plot_stars                                                    ;
    jsr plot_top_and_right_edge_of_long_range_scanner_with_blank_text ;
    jsr initialise_joystick_and_cursor_keys                           ;
    jsr set_foreground_colour_to_white                                ;
    rts                                                               ;

launch_escape_capsule_port
    ldy #$c0                                                          ;
    bne launch_escape_capsule                                         ;
launch_escape_capsule_starboard
    ldy #$40                                                          ;
launch_escape_capsule
    inc escape_capsule_launched                                       ;
    sty escape_capsule_launch_direction                               ;
    lda #$3f                                                          ;
    sta self_destruct_countdown                                       ;
    jsr plot_escape_capsule_launched                                  ;
    lda #$7f                                                          ;
    sta escape_capsule_x_pixels                                       ;
    sta escape_capsule_y_pixels                                       ;
    sta escape_capsule_on_screen                                      ;
    bne update_escape_capsule                                         ;
handle_starship_self_destruct
    lda escape_capsule_launched                                       ;
    beq return22                                                      ;
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
    lda #<escape_capsule_on_screen                                    ;
    sta temp0_low                                                     ;
    lda #>escape_capsule_on_screen                                    ;
    sta temp0_high                                                    ;
    ldy #1                                                            ;
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
    bcs escape_capsule_collided_with_enemy_ship                       ;
    jsr plot_escape_capsule                                           ;
return22
    rts                                                               ;

escape_capsule_collided_with_enemy_ship
    lda maximum_number_of_enemy_ships                                 ;
    sec                                                               ;
    sbc enemy_ships_still_to_consider                                 ;
    sta x_pixels                                                      ;
    asl                                                               ;
    asl                                                               ;
    adc x_pixels                                                      ;
    asl                                                               ;
    adc x_pixels                                                      ;
    tax                                                               ;
    lda enemy_ships_energy,x                                          ;
    beq enemy_ship_is_already_exploding                               ;
    lda #0                                                            ;
    sta enemy_ships_energy,x                                          ;
    jsr explode_enemy_ship                                            ;
enemy_ship_is_already_exploding
    ldy #0                                                            ;
    sty escape_capsule_on_screen                                      ;
    jsr plot_expiring_torpedo                                         ;
    lda #1                                                            ;
    sta escape_capsule_destroyed                                      ;
    rts                                                               ;

mark_escape_capsule_as_off_screen
    lda #0                                                            ;
    sta escape_capsule_on_screen                                      ;
    rts                                                               ;

plot_escape_capsule
    lda escape_capsule_x_pixels                                       ;
    sta x_pixels                                                      ;
    lda escape_capsule_y_pixels                                       ;
    sta y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc y_pixels                                                      ;
    dec x_pixels                                                      ;
    jsr eor_pixel                                                     ;
    dec x_pixels                                                      ;
    dec y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    inc x_pixels                                                      ;
    dec y_pixels                                                      ;
    jsr eor_pixel                                                     ;
    rts                                                               ;

fire_enemy_torpedo_cluster
    lda enemy_ships_angle,x                                           ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    tay                                                               ;
    lda sine_table,y                                                  ;
    clc                                                               ;
    adc enemy_ships_x_pixels,x                                        ;
    sta output_fraction                                               ;
    lda cosine_table,y                                                ;
    clc                                                               ;
    adc enemy_ships_x_pixels1,x                                       ;
    sta output_pixels                                                 ;
    jsr add_single_torpedo_to_enemy_torpedo_cluster                   ;
    dec output_fraction                                               ;
    dec output_fraction                                               ;
    dec output_pixels                                                 ;
    dec output_pixels                                                 ;
    jsr add_single_torpedo_to_enemy_torpedo_cluster                   ;
    inc output_fraction                                               ;
    inc output_fraction                                               ;
    dec output_pixels                                                 ;
    dec output_pixels                                                 ;
    jsr add_single_torpedo_to_enemy_torpedo_cluster                   ;
    inc output_fraction                                               ;
    inc output_fraction                                               ;
    inc output_pixels                                                 ;
    inc output_pixels                                                 ;
    jsr add_single_torpedo_to_enemy_torpedo_cluster                   ;
    sec                                                               ;
    rts                                                               ;

add_single_torpedo_to_enemy_torpedo_cluster
    ldy #0                                                            ;
    lda value_used_for_enemy_torpedo_ttl                              ;
    sta (temp0_low),y                                                 ;
    ldy #2                                                            ;
    lda output_fraction                                               ;
    sta (temp0_low),y                                                 ;
    ldy #4                                                            ;
    lda output_pixels                                                 ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda enemy_ships_angle,x                                           ;
    sta (temp0_low),y                                                 ;
    inc enemy_ship_fired_torpedo                                      ;
    stx temp8                                                         ;
    jsr plot_enemy_torpedo                                            ;
    ldx temp8                                                         ;
    ldy #0                                                            ;
find_free_torpedo_slot
    dec torpedoes_still_to_consider                                   ;
    beq dont_add_any_more_torpedoes_to_cluster                        ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #6                                                            ;
    sta temp0_low                                                     ;
    bcc skip28                                                        ;
    inc temp0_high                                                    ;
skip28
    lda (temp0_low),y                                                 ;
    bne find_free_torpedo_slot                                        ;
    rts                                                               ;

dont_add_any_more_torpedoes_to_cluster
    pla                                                               ;
    pla                                                               ;
    sec                                                               ;
    rts                                                               ;

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
partial_velocity_for_damaged_enemy_ships
    !byte 6                                                           ;
desired_velocity_for_intact_enemy_ships
    !byte $18                                                         ;
enemy_ship_defensive_behaviour_handling
    lda enemy_ships_on_screen,x                                       ;
    bne unset_retreating_flags                                        ;
    lda enemy_ships_x_pixels,x                                        ;
    sta temp10                                                        ;
    lda enemy_ships_x_pixels1,x                                       ;
    sta temp9                                                         ;
    jsr calculate_enemy_ship_angle_to_starship                        ;
    ldy enemy_ships_temporary_behaviour_flags,x                       ;
    bmi skip_retreating_because_of_damage                             ;
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    and #$40                                                          ;
    beq skip_retreating_because_of_damage                             ;
    tya                                                               ;
    and #$0f                                                          ;
    beq skip_retreating_because_of_damage                             ;
    tya                                                               ;
    ora #$80                                                          ;
    tay                                                               ;
skip_retreating_because_of_damage
    lda enemy_ships_flags_or_explosion_timer,x                        ;
    and #$20                                                          ;
    beq skip_retreating_because_of_angle                              ;
    tya                                                               ;
    and #$40                                                          ;
    bne already_retreating_because_of_angle                           ;
    lda enemy_ship_desired_angle_divided_by_eight                     ;
    clc                                                               ;
    adc #3                                                            ;
    and #$1f                                                          ;
    cmp #7                                                            ;
    bcs skip_retreating_because_of_angle                              ;
    tya                                                               ;
    ora #$40                                                          ;
    bne set_temporary_behaviour_flags                                 ;
already_retreating_because_of_angle
    lda enemy_ship_desired_angle_divided_by_eight                     ;
    clc                                                               ;
    adc #5                                                            ;
    and #$1f                                                          ;
    cmp #$0b                                                          ;
    bcc skip_retreating_because_of_angle                              ;
    tya                                                               ;
    and #$bf                                                          ;
    tay                                                               ;
skip_retreating_because_of_angle
    tya                                                               ;
set_temporary_behaviour_flags
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    and #$c0                                                          ;
    beq leave_after_clearing_carry1                                   ;
    jsr turn_enemy_ship_towards_desired_angle                         ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    sec                                                               ;
    rts                                                               ;

unset_retreating_flags
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    and #$3f                                                          ;
    sta enemy_ships_temporary_behaviour_flags,x                       ;
leave_after_clearing_carry1
    clc                                                               ;
    rts                                                               ;

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
    rol                                                               ;
    adc enemy_ships_x_pixels1,x                                       ;
    bmi skip_inversion8                                               ;
    eor #$ff                                                          ;
skip_inversion8
    clc                                                               ;
    adc x_pixels                                                      ;
    rts                                                               ;

get_rectilinear_distance_from_centre_of_screen
    lda enemy_ships_x_pixels,x                                        ;
    bmi skip_inversion_x4                                             ;
    eor #$ff                                                          ;
skip_inversion_x4
    sta x_pixels                                                      ;
    lda enemy_ships_x_pixels1,x                                       ;
    bmi skip_inversion_y4                                             ;
    eor #$ff                                                          ;
skip_inversion_y4
    clc                                                               ;
    adc x_pixels                                                      ;
    rts                                                               ;

turn_enemy_ship_towards_starship_using_screens
    lda enemy_ships_x_screens,x                                       ;
    sta temp10                                                        ;
    lda enemy_ships_x_screens1,x                                      ;
    sta temp9                                                         ;
    jmp turn_enemy_ship_towards_starship                              ;

turn_enemy_ship_towards_starship
    jsr calculate_enemy_ship_angle_to_starship                        ;
turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity
    lda enemy_ship_desired_angle_divided_by_eight                     ;
    clc                                                               ;
    adc #$10                                                          ;
    and #$1f                                                          ;
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
    lda #0                                                            ;
    ldy #3                                                            ;
loop_over_bits_of_sine3
    lsr y_pixels                                                      ; TODO: optimise?
    bcc sine_bit_unset3                                               ;
    clc                                                               ;
    adc x_pixels                                                      ;
sine_bit_unset3
    ror                                                               ;
    dey                                                               ;
    bne loop_over_bits_of_sine3                                       ;
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
    cmp #$0b                                                          ;
    bcc finished_calculating_change_in_angle                          ;
    iny                                                               ;
    cmp #$0e                                                          ;
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
    sbc y_pixels                                                      ;
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
    cmp enemy_ships_velocity,x                                        ;
return24
    rts                                                               ;

starship_sprite_1
    !byte %.#.....#                                                   ;
    !byte %.#.....#                                                   ;
    !byte %.#.....#                                                   ;
    !byte %.#....##                                                   ;
    !byte %###..###                                                   ;
    !byte %#.#..###                                                   ;
    !byte %#.#..#.#                                                   ;
    !byte %#.#...##                                                   ;
    !byte %.....#..                                                   ;
    !byte %.....#..                                                   ;
    !byte %.....#..                                                   ;
    !byte %#....#..                                                   ;
    !byte %##..###.                                                   ;
    !byte %##..#.#.                                                   ;
    !byte %.#..#.#.                                                   ;
    !byte %#...#.#.                                                   ;
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
    !byte %......##                                                   ;
    !byte %....##..                                                   ;
    !byte %...#....                                                   ;
    !byte %...#..##                                                   ;
    !byte %..#..#..                                                   ;
    !byte %..#..#.#                                                   ;
    !byte %..#..#..                                                   ;
    !byte %...#..##                                                   ;
    !byte %#.......                                                   ;
    !byte %.##.....                                                   ;
    !byte %...#....                                                   ;
    !byte %#..#....                                                   ;
    !byte %.#..#...                                                   ;
    !byte %.#..#...                                                   ;
    !byte %.#..#...                                                   ;
    !byte %#..#....                                                   ;
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
starship_sprite_3
    !byte %.......#                                                   ;
    !byte %.....###                                                   ;
    !byte %.#..##..                                                   ;
    !byte %.#..##..                                                   ;
    !byte %.#...###                                                   ;
    !byte %.#.....#                                                   ;
    !byte %###...#.                                                   ;
    !byte %#.#....#                                                   ;
    !byte %........                                                   ;
    !byte %##......                                                   ;
    !byte %.##..#..                                                   ;
    !byte %.##..#..                                                   ;
    !byte %##...#..                                                   ;
    !byte %.....#..                                                   ;
    !byte %#...###.                                                   ;
    !byte %....#.#.                                                   ;
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
starship_sprite_4
    !byte %.......#                                                   ;
    !byte %.......#                                                   ;
    !byte %......##                                                   ;
    !byte %##....##                                                   ;
    !byte %##...##.                                                   ;
    !byte %##...##.                                                   ;
    !byte %##..##..                                                   ;
    !byte %##..##.#                                                   ;
    !byte %........                                                   ;
    !byte %........                                                   ;
    !byte %#.......                                                   ;
    !byte %#....##.                                                   ;
    !byte %##...##.                                                   ;
    !byte %##...##.                                                   ;
    !byte %.##..##.                                                   ;
    !byte %.##..##.                                                   ;
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
starship_sprite_5
    !byte %........                                                   ;
    !byte %......##                                                   ;
    !byte %.....#..                                                   ;
    !byte %....#...                                                   ;
    !byte %...#...#                                                   ;
    !byte %...#..#.                                                   ;
    !byte %...#...#                                                   ;
    !byte %.#..#...                                                   ;
    !byte %........                                                   ;
    !byte %#.......                                                   ;
    !byte %.#......                                                   ;
    !byte %..#.....                                                   ;
    !byte %...#....                                                   ;
    !byte %#..#....                                                   ;
    !byte %...#....                                                   ;
    !byte %..#..#..                                                   ;
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
starship_sprite_6
    !byte %......##                                                   ;
    !byte %.....##.                                                   ;
    !byte %.#..##..                                                   ;
    !byte %.#...###                                                   ;
    !byte %.#....#.                                                   ;
    !byte %###...#.                                                   ;
    !byte %#.#...#.                                                   ;
    !byte %#.#...#.                                                   ;
    !byte %#.......                                                   ;
    !byte %##......                                                   ;
    !byte %.##..#..                                                   ;
    !byte %##...#..                                                   ;
    !byte %#....#..                                                   ;
    !byte %#...###.                                                   ;
    !byte %#...#.#.                                                   ;
    !byte %#...#.#.                                                   ;
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
starship_sprite_7
    !byte %.......#                                                   ;
    !byte %.......#                                                   ;
    !byte %.#....##                                                   ;
    !byte %.#....##                                                   ;
    !byte %.#...##.                                                   ;
    !byte %###..##.                                                   ;
    !byte %###.##.#                                                   ;
    !byte %###.##.#                                                   ;
    !byte %........                                                   ;
    !byte %........                                                   ;
    !byte %#....#..                                                   ;
    !byte %#....#..                                                   ;
    !byte %##...#..                                                   ;
    !byte %##..###.                                                   ;
    !byte %.##.###.                                                   ;
    !byte %.##.###.                                                   ;
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
starship_sprite_8
    !byte %.....###                                                   ;
    !byte %....##..                                                   ;
    !byte %...##..#                                                   ;
    !byte %...##.##                                                   ;
    !byte %...##.##                                                   ;
    !byte %...##..#                                                   ;
    !byte %....##..                                                   ;
    !byte %##...###                                                   ;
    !byte %##......                                                   ;
    !byte %.##.....                                                   ;
    !byte %..##....                                                   ;
    !byte %#.##....                                                   ;
    !byte %#.##....                                                   ;
    !byte %..##....                                                   ;
    !byte %.##.....                                                   ;
    !byte %##...##.                                                   ;
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
velocity_gauge_position
    !byte 0                                                           ;
rotation_gauge_position
    !byte 0                                                           ;
score_delta_low
    !byte 0                                                           ;
score_delta_high
    !byte 0                                                           ;
score_as_bcd
    !byte 0                                                           ;
    !byte 0                                                           ;
    !byte 0                                                           ;
score_as_digits
    !byte 0                                                           ;
    !byte 0                                                           ;
    !byte 0                                                           ;
    !byte 0                                                           ;
    !byte 0                                                           ;
    !byte 0                                                           ;
scores_for_destroying_enemy_ships
    !byte 8  , $12, 3  , 4  , $70, $90, 3  , 4  , 2  , 3              ;
score_points_for_destroying_enemy_ship
    lda #1                                                            ;
    sta enemy_ships_previous_on_screen,x                              ;
    lda how_enemy_ship_was_damaged                                    ;
    asl                                                               ;
    tay                                                               ;
    lda enemy_ships_can_cloak                                         ;
    beq not_cloaked                                                   ;
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
    clc                                                               ;
    sei                                                               ;
    sed                                                               ;
    adc score_delta_low                                               ;
    sta score_delta_low                                               ;
    lda score_delta_high                                              ;
    adc #0                                                            ;
    sta score_delta_high                                              ;
    cld                                                               ;
    cli                                                               ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
; add to score (in binary coded decimal)
; ----------------------------------------------------------------------------------
apply_delta_to_score
apply_delta_to_score1
    lda score_delta_low                                               ;
    clc                                                               ;
    sei                                                               ;
    sed                                                               ;
    adc score_as_bcd                                                  ;
    sta score_as_bcd                                                  ;
    lda score_as_bcd + 1                                              ;
    adc score_delta_high                                              ;
    sta score_as_bcd + 1                                              ;
    lda score_as_bcd + 2                                              ;
    adc #0                                                            ;
    sta score_as_bcd + 2                                              ;
    cld                                                               ;
    cli                                                               ;
    lda #0                                                            ;
    cmp score_delta_low                                               ;
    bne zero_score_delate                                             ;
    cmp score_delta_high                                              ;
    beq c2e5e                                                         ;
zero_score_delate
    sta score_delta_low                                               ;
    sta score_delta_high                                              ;
; calculate the characters to display the score, then display them
convert_score_as_bcd_to_score_as_digits
    lda score_as_bcd + 2                                              ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    sta score_as_digits + 5                                           ;
    lda score_as_bcd + 2                                              ;
    and #$0f                                                          ;
    sta score_as_digits + 4                                           ;
    lda score_as_bcd + 1                                              ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    sta score_as_digits + 3                                           ;
    lda score_as_bcd + 1                                              ;
    and #$0f                                                          ;
    sta score_as_digits + 2                                           ;
    lda score_as_bcd                                                  ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    sta score_as_digits + 1                                           ;
    lda score_as_bcd                                                  ;
    and #$0f                                                          ;
    sta score_as_digits                                               ;
; tab into position, TAB(33,30):
    lda #$1f                                                          ;
    jsr oswrch                                                        ;
    lda #$21                                                          ;
    jsr oswrch                                                        ;
    lda #$1e                                                          ;
    jsr oswrch                                                        ;
; display the characters for the score
    ldy #5                                                            ;
    ldx #$20                                                          ;
plot_score_loop
    lda score_as_digits,y                                             ;
    bne non_zero_digit                                                ;
    txa                                                               ;
    jmp leading_zero                                                  ;

non_zero_digit
    clc                                                               ;
    adc #'0'                                                          ;
    ldx #'0'                                                          ;
leading_zero
    jsr oswrch                                                        ;
    dey                                                               ;
    bpl plot_score_loop                                               ;
c2e5e
    rts                                                               ;

plot_scanner_grid
    inc screen_start_high                                             ;
    lda #9                                                            ;
    sta x_pixels                                                      ;
    lda #5                                                            ;
    sta output_pixels                                                 ;
    sta output_fraction                                               ;
plot_vertical_lines_outer_loop
    lda #$41                                                          ;
    sta y_pixels                                                      ;
    lda #$31                                                          ;
    sta temp11                                                        ;
plot_vertical_lines_inner_loop
    jsr set_pixel                                                     ;
    inc y_pixels                                                      ;
    dec temp11                                                        ;
    bne plot_vertical_lines_inner_loop                                ;
    lda x_pixels                                                      ;
    clc                                                               ;
    adc #$0a                                                          ;
    sta x_pixels                                                      ;
    dec output_pixels                                                 ;
    bne plot_vertical_lines_outer_loop                                ;
    lda #$4a                                                          ;
    sta y_pixels                                                      ;
plot_horizontal_lines_outer_loop
    lda #0                                                            ;
    sta x_pixels                                                      ;
    lda #$32                                                          ;
    sta temp11                                                        ;
plot_horizontal_lines_inner_loop
    jsr set_pixel                                                     ;
    inc x_pixels                                                      ;
    dec temp11                                                        ;
    bne plot_horizontal_lines_inner_loop                              ;
    lda y_pixels                                                      ;
    clc                                                               ;
    adc #$0a                                                          ;
    sta y_pixels                                                      ;
    dec output_fraction                                               ;
    bne plot_horizontal_lines_outer_loop                              ;
    dec screen_start_high                                             ;
    rts                                                               ;

plot_gauge_edges
    inc screen_start_high                                             ;
    lda #$35                                                          ;
    sta x_pixels                                                      ;
    lda #$41                                                          ;
    sta y_pixels                                                      ;
    lda #$42                                                          ;
    jsr plot_vertical_line                                            ;
    lda #$3b                                                          ;
    sta x_pixels                                                      ;
    lda #$41                                                          ;
    sta y_pixels                                                      ;
    lda #$42                                                          ;
    jsr plot_vertical_line                                            ;
    lda #5                                                            ;
    sta x_pixels                                                      ;
    lda #$77                                                          ;
    sta y_pixels                                                      ;
    lda #$2b                                                          ;
    jsr plot_horizontal_line                                          ;
    lda #7                                                            ;
    jsr plot_vertical_line                                            ;
    lda #5                                                            ;
    sta x_pixels                                                      ;
    lda #$78                                                          ;
    sta y_pixels                                                      ;
    lda #6                                                            ;
    jsr plot_vertical_line                                            ;
    lda #$2c                                                          ;
    jsr plot_horizontal_line                                          ;
    lda #0                                                            ;
    sta x_pixels                                                      ;
    lda #$83                                                          ;
    sta y_pixels                                                      ;
    lda #$3f                                                          ;
    jsr plot_horizontal_line                                          ;
    lda #$1a                                                          ;
    sta x_pixels                                                      ;
    lda #$75                                                          ;
    sta y_pixels                                                      ;
    jsr set_pixel                                                     ;
    inc x_pixels                                                      ;
    jsr set_pixel                                                     ;
    inc y_pixels                                                      ;
    jsr set_pixel                                                     ;
    dec x_pixels                                                      ;
    jsr set_pixel                                                     ;
    lda #$7f                                                          ;
    sta y_pixels                                                      ;
    jsr set_pixel                                                     ;
    inc x_pixels                                                      ;
    jsr set_pixel                                                     ;
    inc y_pixels                                                      ;
    jsr set_pixel                                                     ;
    dec x_pixels                                                      ;
    jsr set_pixel                                                     ;
    lda #0                                                            ;
    sta x_pixels                                                      ;
    lda #$e7                                                          ;
    sta y_pixels                                                      ;
    lda #$3f                                                          ;
    jsr plot_horizontal_line                                          ;
    dec screen_start_high                                             ;
    rts                                                               ;

plot_starship_velocity_and_rotation_on_gauges
    inc screen_start_high                                             ;
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
    rol                                                               ;
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
    bcc set_rotation_gauge_position_for_unset                         ;
    sbc #3                                                            ;
    cmp #$14                                                          ;
    bcs set_rotation_gauge_position_for_unset                         ;
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
    dec screen_start_high                                             ;
    rts                                                               ;

plot_enemy_ships_on_scanners
    inc screen_start_high                                             ;
    lda maximum_number_of_enemy_ships                                 ;
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
    lda enemy_ships_previous_x_screens1,x                             ;
    cmp #$60                                                          ;
    bcc skip_unplotting_enemy_ship_on_scanner                         ;
    cmp #$9f                                                          ;
    bcs skip_unplotting_enemy_ship_on_scanner                         ;
    adc #$a1                                                          ;
    sta y_pixels                                                      ;
    lda x_pixels                                                      ;
    clc                                                               ;
    adc #$a0                                                          ;
    sta x_pixels                                                      ;
    jsr unset_pixel                                                   ;
    lda x_pixels                                                      ;
    sec                                                               ;
    sbc #$1d                                                          ;
    bcc skip_unplotting_enemy_ship_on_scanner                         ;
    cmp #5                                                            ;
    bcs skip_unplotting_enemy_ship_on_scanner                         ;
    tay                                                               ;
    lda y_pixels                                                      ;
    sec                                                               ;
    sbc #$1e                                                          ;
    bcc skip_unplotting_enemy_ship_on_scanner                         ;
    cmp #5                                                            ;
    bcs skip_unplotting_enemy_ship_on_scanner                         ;
    asl                                                               ;
    sta y_pixels                                                      ;
    asl                                                               ;
    asl                                                               ;
    adc y_pixels                                                      ;
    sta y_pixels                                                      ;
    ldx temp8                                                         ;
    lda enemy_ships_previous_x_pixels1,x                              ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc y_pixels                                                      ;
    adc #$41                                                          ;
    sta y_pixels                                                      ;
    tya                                                               ;
    asl                                                               ;
    sta x_pixels                                                      ;
    asl                                                               ;
    asl                                                               ;
    adc x_pixels                                                      ;
    sta x_pixels                                                      ;
    lda enemy_ships_previous_x_pixels,x                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc x_pixels                                                      ;
    sta x_pixels                                                      ;
    jsr unset_pixel                                                   ;
    inc x_pixels                                                      ;
    jsr unset_pixel                                                   ;
    inc y_pixels                                                      ;
    jsr unset_pixel                                                   ;
    dec x_pixels                                                      ;
    jsr unset_pixel                                                   ;
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
    lda enemy_ships_x_screens1,x                                      ;
    cmp #$60                                                          ;
    bcc skip_plotting_enemy_ship_on_scanner                           ;
    cmp #$9f                                                          ;
    bcs skip_plotting_enemy_ship_on_scanner                           ;
    adc #$a1                                                          ;
    sta y_pixels                                                      ;
    lda x_pixels                                                      ;
    clc                                                               ;
    adc #$a0                                                          ;
    sta x_pixels                                                      ;
    jsr set_pixel                                                     ;
    lda x_pixels                                                      ;
    sec                                                               ;
    sbc #$1d                                                          ;
    bcc skip_plotting_enemy_ship_on_scanner                           ;
    cmp #5                                                            ;
    bcs skip_plotting_enemy_ship_on_scanner                           ;
    tay                                                               ;
    lda y_pixels                                                      ;
    sec                                                               ;
    sbc #$1e                                                          ;
    bcc skip_plotting_enemy_ship_on_scanner                           ;
    cmp #5                                                            ;
    bcs skip_plotting_enemy_ship_on_scanner                           ;
    asl                                                               ;
    sta y_pixels                                                      ;
    asl                                                               ;
    asl                                                               ;
    adc y_pixels                                                      ;
    sta y_pixels                                                      ;
    ldx temp8                                                         ;
    lda enemy_ships_x_pixels1,x                                       ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc y_pixels                                                      ;
    adc #$41                                                          ;
    sta y_pixels                                                      ;
    tya                                                               ;
    asl                                                               ;
    sta x_pixels                                                      ;
    asl                                                               ;
    asl                                                               ;
    adc x_pixels                                                      ;
    sta x_pixels                                                      ;
    lda enemy_ships_x_pixels,x                                        ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc x_pixels                                                      ;
    sta x_pixels                                                      ;
    jsr set_pixel                                                     ;
    inc x_pixels                                                      ;
    jsr set_pixel                                                     ;
    inc y_pixels                                                      ;
    jsr set_pixel                                                     ;
    dec x_pixels                                                      ;
    jsr set_pixel                                                     ;
skip_plotting_enemy_ship_on_scanner
    lda temp8                                                         ;
    clc                                                               ;
    adc #$0b                                                          ;
    tax                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    beq continue3                                                     ;
    jmp plot_enemy_ships_on_scanners_loop                             ;

continue3
    ldy #$1f                                                          ;
    sty x_pixels                                                      ;
    iny                                                               ;
    sty y_pixels                                                      ;
    jsr set_pixel                                                     ;
    dec screen_start_high                                             ;
    rts                                                               ;

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
    lda rnd_2                                                         ;
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
    lda #0                                                            ;
    sta temp5                                                         ;
    sta temp0_low                                                     ;
    lda #$d0                                                          ;
    sta temp6                                                         ;
    lda #$59                                                          ;
    sta temp0_high                                                    ;
    ldx #8                                                            ;
plot_static_row_loop
    ldy #$3f                                                          ;
plot_static_column_loop
    lda (temp5),y                                                     ;
    sta (temp0_low),y                                                 ;
    dey                                                               ;
    bpl plot_static_column_loop                                       ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #$40                                                          ;
    sta temp0_low                                                     ;
    lda temp0_high                                                    ;
    adc #1                                                            ;
    sta temp0_high                                                    ;
    lda temp5                                                         ;
    clc                                                               ;
    adc #$40                                                          ;
    sta temp5                                                         ;
    lda temp6                                                         ;
    adc #1                                                            ;
    sta temp6                                                         ;
    dex                                                               ;
    bne plot_static_row_loop                                          ;
return25
    rts                                                               ;

starship_didnt_incur_major_damage
    lda scanner_failure_duration                                      ;
    beq return26                                                      ;
handle_failed_scanner
    dec scanner_failure_duration                                      ;
    beq clear_long_range_scanner                                      ;
    lda #0                                                            ;
    sta temp0_low                                                     ;
    lda #$59                                                          ; temp0 = $5900
    sta temp0_high                                                    ;
    ldx #8                                                            ;
update_static_row_loop
    ldy #$3f                                                          ;
update_static_column_loop
    lda (temp0_low),y                                                 ;
    eor y_pixels                                                      ;
    sta (temp0_low),y                                                 ;
    sta y_pixels                                                      ;
    dey                                                               ;
    bpl update_static_column_loop                                     ;
    lda temp0_low                                                     ;
    clc                                                               ;
    adc #$40                                                          ;
    sta temp0_low                                                     ;
    lda temp0_high                                                    ;
    adc #1                                                            ;
    sta temp0_high                                                    ;
    dex                                                               ;
    bne update_static_row_loop                                        ;
    lda y_pixels                                                      ;
return26
    rts                                                               ;

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
    bne return26                                                      ;
    jsr unplot_long_range_scanner_if_shields_inactive                 ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine0
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    and #$10                                                          ;
    bne skip_setting_enemy_ship_was_on_screen_above                   ;
    lda enemy_ships_x_screens,x                                       ;
    cmp #$7f                                                          ;
    bne not_on_screen_above                                           ;
    lda enemy_ships_x_screens1,x                                      ;
    cmp #$7e                                                          ;
    bne not_on_screen_above                                           ;
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    ora #$10                                                          ;
    sta enemy_ships_temporary_behaviour_flags,x                       ;
skip_setting_enemy_ship_was_on_screen_above
    lda #4                                                            ;
    sta enemy_ship_desired_velocity                                   ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    lda enemy_ships_on_screen,x                                       ;
    bne not_on_screen1                                                ;
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne to_return_from_enemy_ship_behaviour_routine                   ;
    jsr fire_enemy_torpedo                                            ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

not_on_screen1
    jsr turn_enemy_ship_towards_starship_using_screens                ;
    lda temp9                                                         ;
    cmp #$80                                                          ;
    bcc to_return_from_enemy_ship_behaviour_routine                   ;
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    and #$ef                                                          ;
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

not_on_screen_above
    lda enemy_ships_x_screens,x                                       ;
    sta temp10                                                        ;
    lda enemy_ships_x_screens1,x                                      ;
    clc                                                               ;
    adc #1                                                            ;
    sta temp9                                                         ;
    jsr turn_enemy_ship_towards_starship                              ;
    lda enemy_ship_desired_velocity                                   ;
    clc                                                               ;
    adc #$0a                                                          ;
    sta enemy_ship_desired_velocity                                   ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
to_return_from_enemy_ship_behaviour_routine
    jmp return_from_enemy_ship_behaviour_routine                      ;

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
    cmp enemy_ship_desired_velocity                                   ;
    bcs skip_setting_desired_velocity                                 ;
    sta enemy_ship_desired_velocity                                   ;
skip_setting_desired_velocity
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne return_after_changing_velocity                                ;
    jsr fire_enemy_torpedo                                            ;
    jmp return_after_changing_velocity                                ;

to_set_retreating_and_head_towards_desired_velocity_and_angle
    jmp set_retreating_and_head_towards_desired_velocity_and_angle    ;

off_screen
    jsr turn_enemy_ship_towards_starship_using_screens                ;
return_after_changing_velocity
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine2
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen1                                                   ;
    jsr get_rectilinear_distance_from_centre_of_screen                ;
    cmp #$46                                                          ;
    bcc to_set_retreating_and_head_towards_desired_velocity_and_angle1 ;
    cmp #$6e                                                          ;
    bcs return_after_turning_enemy_ship_towards_desired_angle         ;
    jsr decrease_enemy_ship_velocity                                  ;
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne to_return_from_enemy_ship_behaviour_routine1                  ;
    jsr fire_enemy_torpedo                                            ;
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
enemy_ship_behaviour_routine3
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen2                                                   ;
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne skip_firing                                                   ;
    jsr fire_enemy_torpedo                                            ;
skip_firing
    jsr get_rectilinear_distance_from_centre_of_screen                ;
    cmp #$78                                                          ;
    bcs to_return_from_enemy_ship_behaviour_routine2                  ;
    jsr decrease_enemy_ship_velocity                                  ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

off_screen2
    jsr turn_enemy_ship_towards_starship_using_screens                ;
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
to_return_from_enemy_ship_behaviour_routine2
    jmp return_from_enemy_ship_behaviour_routine                      ;

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
    jsr decrease_enemy_ship_velocity                                  ;
skip_deceleration
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne return_after_changing_velocity2                               ;
    jsr fire_enemy_torpedo                                            ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

off_screen3
    jsr turn_enemy_ship_towards_starship_using_screens                ;
return_after_changing_velocity2
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
    jmp return_from_enemy_ship_behaviour_routine                      ;

; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine5
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen4                                                   ;
    jsr get_rectilinear_distance_from_centre_of_screen                ;
    cmp #$50                                                          ;
    bcc to_set_retreating_and_head_towards_desired_velocity_and_angle2 ;
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne return_after_changing_velocity3                               ;
    jsr fire_enemy_torpedo                                            ;
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

maximum_enemy_torpedo_cooldown_per_command
    !byte $0f, $0d, $0b, 9  , 7  , 5  , 3  , 2                        ;
command_number_used_for_maximum_enemy_torpedo_cooldown_lookup
    !byte 0                                                           ;
probability_of_new_enemy_ship_being_defensive_about_damage
    !byte 0                                                           ;
probability_of_new_enemy_ship_being_defensive_about_angle
    !byte 0                                                           ;
probability_of_new_enemy_ship_firing_torpedo_clusters
    !byte 0                                                           ;
probability_of_new_enemy_ship_being_large
    !byte 0                                                           ;
change_in_enemy_ship_spawning_probabilities_per_command
    !byte $ec, $f2, $0f, $17                                          ;
ultimate_enemy_ship_probabilities
    !byte $20, 4  , $b8, $ff                                          ;
initial_enemy_ship_spawning_probabilities
    !byte $c0, $82, 4  , 2                                            ;
; ----------------------------------------------------------------------------------
initialise_enemy_ship
    lda #$ff                                                          ;
    sta enemy_ships_energy,x                                          ;
    ldy enemy_ships_still_to_consider                                 ;
    lda #0                                                            ;
    sta enemy_ships_explosion_number - 1,y                            ;
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    jsr random_number_generator                                       ;
    lda rnd_2                                                         ;
    and #$0f                                                          ;
    sta enemy_ships_flags_or_explosion_timer,x                        ;
    ldy #$5f                                                          ;
    lda rnd_2                                                         ;
    bpl skip29                                                        ;
    ldy #$9f                                                          ;
skip29
    sty x_pixels                                                      ;
    lda rnd_1                                                         ;
    and #$1f                                                          ;
    clc                                                               ;
    adc #$70                                                          ;
    tay                                                               ;
    lda rnd_2                                                         ;
    asl                                                               ;
    bpl skip_swap1                                                    ;
    tya                                                               ;
    ldy x_pixels                                                      ;
    sta x_pixels                                                      ;
skip_swap1
    tya                                                               ;
    sta enemy_ships_x_screens,x                                       ;
    sta temp10                                                        ;
    lda x_pixels                                                      ;
    sta enemy_ships_x_screens1,x                                      ;
    sta temp9                                                         ;
    jsr calculate_enemy_ship_angle_to_starship                        ;
    clc                                                               ;
    adc #$10                                                          ;
    asl                                                               ;
    asl                                                               ;
    asl                                                               ;
    sta enemy_ships_angle,x                                           ;
    jsr random_number_generator                                       ;
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
    lda probability_of_new_enemy_ship_being_large                     ;
    cmp rnd_2                                                         ;
    bcc small_ship                                                    ;
    iny                                                               ;
small_ship
    tya                                                               ;
    sta enemy_ships_type,x                                            ;
    jsr random_number_generator                                       ;
    ldy command_number_used_for_maximum_enemy_torpedo_cooldown_lookup ;
    cpy #8                                                            ;
    bcc skip_ceiling2                                                 ;
    ldy #7                                                            ;
skip_ceiling2
    lda maximum_enemy_torpedo_cooldown_per_command,y                  ;
    sta x_pixels                                                      ;
    ldy #4                                                            ;
    lda #0                                                            ;
calculate_cooldown_loop
    lsr x_pixels                                                      ;
    bcc skip_addition                                                 ;
    clc                                                               ;
    adc rnd_2                                                         ;
skip_addition
    ror                                                               ;
    dey                                                               ;
    bne calculate_cooldown_loop                                       ;
    clc                                                               ;
    adc #$10                                                          ;
    and #$f0                                                          ;
    sta enemy_ships_firing_cooldown,x                                 ;
    lda #1                                                            ;
    sta enemy_ships_on_screen,x                                       ;
    lda #$ff                                                          ;
    sta enemy_ships_velocity,x                                        ;
    rts                                                               ;

starship_type
    !byte 0                                                           ;
command_number
    !byte 0                                                           ;
regeneration_rate_for_enemy_ships
    !byte 1                                                           ;
maximum_timer_for_enemy_ships_regeneration
    !byte 4                                                           ;
timer_for_enemy_ships_regeneration
    !byte 0                                                           ;
base_regeneration_rate_for_starship
    !byte $0c                                                         ;
maximum_timer_for_starship_energy_regeneration
    !byte 3                                                           ;
timer_for_starship_energy_regeneration
    !byte 3                                                           ;
base_damage_to_enemy_ship_from_other_collision
    !byte $14                                                         ;
maximum_number_of_stars_in_game
    !byte $11                                                         ;
minimum_number_of_stars
    !byte 1                                                           ;
change_in_number_of_stars_per_command
    !byte $fe                                                         ;
subtraction_from_starship_regeneration_when_shields_active
    !byte 4                                                           ;
escape_capsule_launched_string
    !text "DEHCNUAL"                                                  ;
    !byte $19, $20, $1f                                               ;
    !text "ELUSPAC"                                                   ;
    !byte $18, $20, $1f                                               ;
    !text "EPACSE"                                                    ;
    !byte $17, $20, $1f                                               ;
command_move_string
    !byte 0  , $81, 4                                                 ;
command_move_string_horizontal_pos
    !byte $6f, 4  , $19                                               ;
command_string
    !text "DNAMMOC"                                                   ;
    !byte 5  , 0  , $a2, 4  , $0f, 4  , $19                           ;
prepare_starship_for_next_command
    inc starship_type                                                 ;
    inc command_number_used_for_maximum_enemy_torpedo_cooldown_lookup ;
    lda command_number                                                ;
    clc                                                               ;
    sei                                                               ;
    sed                                                               ;
    adc #1                                                            ;
    cld                                                               ;
    cli                                                               ;
    sta command_number                                                ;
    lda #0                                                            ;
    sta starship_has_exploded                                         ;
    sta escape_capsule_launched                                       ;
    sta escape_capsule_destroyed                                      ;
    sta score_delta_high                                              ;
    sta score_delta_low                                               ;
    sta damage_high                                                   ;
    sta damage_low                                                    ;
    sta starship_energy_divided_by_sixteen                            ;
    sta rotation_damper                                               ;
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
    lda #4                                                            ;
    sta starship_velocity_high                                        ;
    lda #1                                                            ;
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
; clear screen
    lda #$0c                                                          ;
    jsr oswrch                                                        ;
    ldx #<(sound_0)                                                   ;
    ldy #>(sound_0)                                                   ;
    lda #osword_sound                                                 ;
    jsr osword                                                        ;
initialise_starship_sprite
    lda starship_type                                                 ;
    asl                                                               ;
    asl                                                               ;
    asl                                                               ;
    asl                                                               ;
    asl                                                               ;
    tay                                                               ;
    ldx #0                                                            ;
initialise_starship_sprite_loop
    lda starship_sprite_1,y                                           ;
    sta user_defined_characters,x                                     ;
    iny                                                               ;
    inx                                                               ;
    cpx #$20                                                          ;
    bne initialise_starship_sprite_loop                               ;
    jsr initialise_stars_at_random_positions                          ;
    jsr initialise_enemy_ships                                        ;
    jsr initialise_game_screen                                        ;
    jsr plot_enemy_ships                                              ;
    rts                                                               ;

plot_command_number
    lda #$d4                                                          ;
    sta y_pixels                                                      ;
    lda #0                                                            ;
    sta x_pixels                                                      ;
    inc screen_start_high                                             ;
    lda #$3f                                                          ;
    jsr plot_horizontal_line                                          ;
    dec screen_start_high                                             ;
    ldy #$0d                                                          ;
plot_command_loop
    lda command_string,y                                              ;
    jsr oswrch                                                        ;
    dey                                                               ;
    bpl plot_command_loop                                             ;
    ldy #$73                                                          ;
    lda command_number                                                ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    tax                                                               ;
    beq single_digit_command_number_for_move                          ;
    ldy #$63                                                          ;
single_digit_command_number_for_move
    sty command_move_string_horizontal_pos                            ;
    ldy #5                                                            ;
plot_command_move_loop
    lda command_move_string,y                                         ;
    jsr oswrch                                                        ;
    dey                                                               ;
    bpl plot_command_move_loop                                        ;
    txa                                                               ;
    beq single_digit_command_number                                   ;
    clc                                                               ;
    adc #$30                                                          ;
    jsr oswrch                                                        ;
single_digit_command_number
    lda command_number                                                ;
    and #$0f                                                          ;
    clc                                                               ;
    adc #$30                                                          ;
    jsr oswrch                                                        ;
    lda #4                                                            ;
    jsr oswrch                                                        ;
    rts                                                               ;

plot_escape_capsule_launched
    ldy #$1d                                                          ;
plot_escape_capsule_launched_loop_loop
    lda escape_capsule_launched_string,y                              ;
    jsr oswrch                                                        ;
    dey                                                               ;
    bpl plot_escape_capsule_launched_loop_loop                        ;
    lda #$c8                                                          ;
    sta y_pixels                                                      ;
    lda #$3f                                                          ;
    sta x_pixels                                                      ;
    inc screen_start_high                                             ;
    lda #8                                                            ;
    jsr plot_vertical_line                                            ;
    dec screen_start_high                                             ;
    rts                                                               ;

initialise_enemy_ships
    lda maximum_number_of_enemy_ships                                 ;
    sta enemy_ships_still_to_consider                                 ;
    ldx #0                                                            ;
initialise_enemy_ships_loop
    jsr initialise_enemy_ship                                         ;
    lda #1                                                            ;
    sta enemy_ships_previous_on_screen,x                              ;
    txa                                                               ;
    clc                                                               ;
    adc #$0b                                                          ;
    tax                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    bne initialise_enemy_ships_loop                                   ;
    rts                                                               ;

initialise_joystick_and_cursor_keys
    ldx #2                                                            ;
    lda #osbyte_select_adc_channels                                   ;
    jsr osbyte                                                        ;
    ldx #1                                                            ;
    lda #osbyte_set_cursor_editing                                    ;
    jsr osbyte                                                        ;
    jsr convert_score_as_bcd_to_score_as_digits                       ;
    rts                                                               ;

update_enemy_ships
    dec timer_for_enemy_ships_regeneration                            ;
    bpl skip_timer_reset                                              ;
    lda maximum_timer_for_enemy_ships_regeneration                    ;
    sta timer_for_enemy_ships_regeneration                            ;
skip_timer_reset
    lda maximum_number_of_enemy_torpedoes                             ;
    sta torpedoes_still_to_consider                                   ;
    lda #<enemy_torpedoes_table                                       ;
    sta temp0_low                                                     ;
    lda #>enemy_torpedoes_table                                       ;
    sta temp0_high                                                    ;
    lda maximum_number_of_enemy_ships                                 ;
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
    adc partial_velocity_for_damaged_enemy_ships                      ;
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
    cmp #4                                                            ;
    bcs skip_enemy_regeneration                                       ;
    lda enemy_ships_energy,x                                          ;
    clc                                                               ;
    adc regeneration_rate_for_enemy_ships                             ;
    bcc skip_ceiling3                                                 ;
    lda #$ff                                                          ;
skip_ceiling3
    sta enemy_ships_energy,x                                          ;
skip_enemy_regeneration
    jsr enemy_ship_defensive_behaviour_handling                       ;
    bcs skip_behaviour_routine                                        ;
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
    lda enemy_ships_x_screens1,x                                      ;
    bmi skip_inversion_y5                                             ;
    eor #$ff                                                          ;
skip_inversion_y5
    clc                                                               ;
    adc x_pixels                                                      ;
    cmp #6                                                            ;
    bcc skip_behaviour_routine                                        ;
    ldy enemy_ships_velocity,x                                        ;
    cpy #$22                                                          ;
    bcs skip_behaviour_routine                                        ;
    adc #$50                                                          ;
    bcc skip_ceiling4                                                 ;
    lda #$ff                                                          ;
skip_ceiling4
    sta enemy_ships_velocity,x                                        ;
skip_behaviour_routine
    jsr random_number_generator                                       ;
    lda rnd_1                                                         ;
    cmp #6                                                            ;
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
    and #$f0                                                          ;
skip_resetting_hit_count
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    txa                                                               ;
    clc                                                               ;
    adc #$0b                                                          ;
    tax                                                               ;
    dec enemy_ships_still_to_consider                                 ;
    beq return27                                                      ;
    jmp update_enemy_ships_loop                                       ;

return27
    rts                                                               ;

; ----------------------------------------------------------------------------------
enemy_ship_behaviour_routine6
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen5                                                   ;
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    bne skip_firing1                                                  ;
    jsr fire_enemy_torpedo                                            ;
skip_firing1
    lda enemy_ships_x_pixels1,x                                       ;
    bpl slow_to_a_crawl                                               ;
    and #$7f                                                          ;
    lsr                                                               ;
    clc                                                               ;
    adc enemy_ships_still_to_consider                                 ;
    sbc #6                                                            ;
    bcs use_speed_based_on_y_pixels                                   ;
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
enemy_ship_behaviour_routine7
    lda enemy_ship_desired_velocity                                   ;
    clc                                                               ;
    adc #8                                                            ;
    sta enemy_ship_desired_velocity                                   ;
    lda enemy_ships_on_screen,x                                       ;
    bne off_screen6                                                   ;
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    tay                                                               ;
    and #$10                                                          ;
    bne kamikaze_stage_one_set                                        ;
    tya                                                               ;
    and #$20                                                          ;
    bne skip_setting_kamikaze_stage_one                               ;
    lda starship_velocity_high                                        ;
    cmp #2                                                            ;
    bcc skip_setting_kamikaze_stage_one                               ;
    tya                                                               ;
    ora #$10                                                          ;
    tay                                                               ;
    sta enemy_ships_temporary_behaviour_flags,x                       ;
skip_setting_kamikaze_stage_one
    jsr get_rectilinear_distance_from_centre_of_screen                ;
    cmp #$69                                                          ;
    bcc decelerate1                                                   ;
    tya                                                               ;
    and #$cf                                                          ;
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
    adc #8                                                            ;
    and #$1f                                                          ;
    sta enemy_ship_desired_angle_divided_by_eight                     ;
    jsr turn_enemy_ship_towards_desired_angle_accounting_for_starship_velocity ;
    lda enemy_ships_x_pixels1,x                                       ;
    bmi return_after_changing_velocity5                               ;
    lda enemy_ships_x_pixels,x                                        ;
    sec                                                               ;
    sbc #$60                                                          ;
    cmp #$40                                                          ;
    bcs return_after_changing_velocity5                               ;
    lda enemy_ships_temporary_behaviour_flags,x                       ;
    eor #$30                                                          ;
    sta enemy_ships_temporary_behaviour_flags,x                       ;
    jmp return_after_changing_velocity5                               ;

off_screen6
    jsr turn_enemy_ship_towards_starship_using_screens                ;
return_after_changing_velocity5
    jsr increase_or_decrease_enemy_ship_velocity_towards_desired_velocity ;
to_return_from_enemy_ship_behaviour_routine3
    jmp return_from_enemy_ship_behaviour_routine                      ;

start_game_continuation
    lda #$ff                                                          ;
    sta command_number_used_for_maximum_enemy_torpedo_cooldown_lookup ;
    sta starship_type                                                 ;
    lda #0                                                            ;
    sta command_number                                                ;
    sta score_as_bcd + 2                                              ;
    sta score_as_bcd + 1                                              ;
    sta score_as_bcd                                                  ;
    lda maximum_number_of_stars_in_game                               ;
    sta maximum_number_of_stars                                       ;
    ldy #3                                                            ;
reset_enemy_ship_spawning_probabilities_loop
    lda initial_enemy_ship_spawning_probabilities,y                   ;
    sta probability_of_new_enemy_ship_being_defensive_about_damage,y  ;
    dey                                                               ;
    bpl reset_enemy_ship_spawning_probabilities_loop                  ;
    jsr prepare_starship_for_next_command                             ;
    jmp main_game_loop                                                ;

main_game_loop
    lda #0                                                            ;
    sta enemy_torpedo_hits_against_starship                           ;
    sta enemy_ship_was_hit                                            ;
    sta starship_collided_with_enemy_ship                             ;
    sta starship_fired_torpedo                                        ;
    sta enemy_ship_fired_torpedo                                      ;
    sta enemy_ships_collided_with_each_other                          ;
    jsr apply_velocity_to_enemy_ships                                 ;
    lda #$ff                                                          ;
    sta how_enemy_ship_was_damaged                                    ;
    jsr check_for_starship_collision_with_enemy_ships                 ;
    jsr update_enemy_ships                                            ;
    lda starship_shields_active                                       ;
    beq skip_scanner_update                                           ;
    lda scanner_failure_duration                                      ;
    bne skip_scanner_update                                           ;
    jsr plot_enemy_ships_on_scanners                                  ;
skip_scanner_update
    jsr plot_enemy_ships                                              ;
    jsr update_stars                                                  ;
    jsr handle_enemy_ships_cloaking                                   ;
    inc how_enemy_ship_was_damaged                                    ;
    jsr plot_starship_torpedoes                                       ;
    jsr update_enemy_torpedoes                                        ;
    inc how_enemy_ship_was_damaged                                    ;
    jsr handle_starship_self_destruct                                 ;
    jsr handle_scanner_failure                                        ;
    lda #0                                                            ;
    dec timer_for_starship_energy_regeneration                        ;
    bne set_regeneration                                              ;
    lda maximum_timer_for_starship_energy_regeneration                ;
    sta timer_for_starship_energy_regeneration                        ;
    lda base_regeneration_rate_for_starship                           ;
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
    lda rnd_2                                                         ;
    and #$3f                                                          ;
    clc                                                               ;
    adc base_damage_to_enemy_ship_from_other_collision                ;
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
    sta value_used_for_enemy_torpedo_ttl                              ;
    jmp main_game_loop                                                ;

previous_score_as_bcd
    !byte 0                                                           ;
    !byte 0                                                           ;
    !byte 0                                                           ;
allowed_another_command
    !byte 0                                                           ;
combat_experience_rating_string
    !byte $1f, $0b, 5                                                 ;
    !text "STARSHIP COMMAND"                                          ;
    !byte $1f, 5  , $0a                                               ;
    !text "An escape capsule was launched"                            ;
    !byte $1f, 4  , $0f                                               ;
    !text "Your official combat experience"                           ;
    !byte $1f, 4  , $11                                               ;
    !text "rating is now recorded as."                                ;
    !byte $1f, $0d, $1f                                               ;
    !text "Press <RETURN>"                                            ;
    !byte $0d                                                         ;
no_before_the_starship_exploded_string
    !byte $1f, 5  , $0a, $4e, $4f, $1f, 5  , $0b                      ;
    !text "before the starship exploded."                             ;
    !byte $0d                                                         ;
after_your_performance_string
    !byte $1f, 3  , $16                                               ;
    !text "After  your  performance  on  this"                        ;
    !byte $1f, 3  , $17                                               ;
    !text "command the Star-Fleet authorities"                        ;
    !byte $1f, 3  , $18                                               ;
    !text "are  said  to  be  ", '"'                                  ;
    !byte $0d                                                         ;
and_returned_safely_text
    !byte $1f, 5  , $0b                                               ;
    !text "and returned safely from the"                              ;
    !byte $1f, 5  , $0c                                               ;
    !text "combat zone."                                              ;
    !byte $0d                                                         ;
but_collided_string
    !byte $1f, 5  , $0b                                               ;
    !text "but collided with an enemy ship."                          ;
    !byte $0d                                                         ;
having_just_gained_string
    !byte $1f, 4  , $13                                               ;
    !text "having  just  gained  "                                    ;
    !byte $0d                                                         ;
and_but_they_allow_string
    !text "and but they allow you the command of"                     ;
    !byte $1f, 3  , $1b                                               ;
    !text "another starship."                                         ;
    !byte $0d                                                         ;
emotions
    !text '"'                                                         ;
    !text "furious", '"'                                              ;
    !text "displeased", '"'                                           ;
    !text "disappointed", '"'                                         ;
    !text "disappointed", '"'                                         ;
    !text "satisfied", '"'                                            ;
    !text "pleased", '"'                                              ;
    !text "impressed", '"'                                            ;
    !text "delighted", '"'                                            ;
    !byte $0d                                                         ;
and_they_retire_you_string
    !byte $1f, 0  , $1a                                               ;
    !text "and they retire you from active service."                  ;
    !byte $0d                                                         ;
threshold_table
    !byte 2  , 3  , 4  , 7  , $0d, $14, $1e                           ;
plot_debriefing
    lda #$0a                                                          ;
    jsr oswrch                                                        ;
    ldy #$0d                                                          ;
plot_row_of_starships_top_line_loop
    lda #$20                                                          ;
    jsr oswrch                                                        ;
    lda #$e0                                                          ;
    jsr oswrch                                                        ;
    lda #$e1                                                          ;
    jsr oswrch                                                        ;
    dey                                                               ;
    bne plot_row_of_starships_top_line_loop                           ;
    lda #$20                                                          ;
    jsr oswrch                                                        ;
    ldy #$0d                                                          ;
plot_row_of_starships_bottom_line_loop
    lda #$20                                                          ;
    jsr oswrch                                                        ;
    lda #$e2                                                          ;
    jsr oswrch                                                        ;
    lda #$e3                                                          ;
    jsr oswrch                                                        ;
    dey                                                               ;
    bne plot_row_of_starships_bottom_line_loop                        ;
    jsr plot_line_of_underscores                                      ;
    ldy #0                                                            ;
plot_combat_experience_rating_text_loop
    lda combat_experience_rating_string,y                             ;
    jsr oswrch                                                        ;
    iny                                                               ;
    cmp #$3e                                                          ;
    bne plot_combat_experience_rating_text_loop                       ;
plot_command_number1
    ldy #5                                                            ;
    ldx #$1c                                                          ;
    jsr tab_to_x_y                                                    ;
    lda command_number                                                ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    beq single_digit_command_number1                                  ;
    clc                                                               ;
    adc #$30                                                          ;
    jsr oswrch                                                        ;
single_digit_command_number1
    lda command_number                                                ;
    and #$0f                                                          ;
    clc                                                               ;
    adc #$30                                                          ;
    jsr oswrch                                                        ;
    jsr plot_line_of_underscores                                      ;
    lda escape_capsule_launched                                       ;
    bne escape_capsule_was_launched                                   ;
    ldy #0                                                            ;
plot_no_before_the_starship_exploded_loop
    lda no_before_the_starship_exploded_string,y                      ;
    jsr oswrch                                                        ;
    iny                                                               ;
    cmp #$2e                                                          ;
    bne plot_no_before_the_starship_exploded_loop                     ;
    beq plot_score_in_debriefing                                      ;
escape_capsule_was_launched
    lda escape_capsule_destroyed                                      ;
    bne escape_capsule_was_destroyed                                  ;
    ldy #0                                                            ;
plot_and_returned_safely_loop
    lda and_returned_safely_text,y                                    ;
    jsr oswrch                                                        ;
    iny                                                               ;
    cmp #$2e                                                          ;
    bne plot_and_returned_safely_loop                                 ;
    beq plot_score_in_debriefing                                      ;
escape_capsule_was_destroyed
    ldy #0                                                            ;
plot_but_collided_loop
    lda but_collided_string,y                                         ;
    jsr oswrch                                                        ;
    iny                                                               ;
    cmp #$2e                                                          ;
    bne plot_but_collided_loop                                        ;
plot_score_in_debriefing
    ldy #$11                                                          ;
    ldx #$1e                                                          ;
    jsr tab_to_x_y                                                    ;
    ldx #$fe                                                          ;
    ldy #5                                                            ;
plot_score_in_debriefing_loop
    lda score_as_digits,y                                             ;
    bne non_zero_digit1                                               ;
    tya                                                               ;
    beq non_zero_digit1                                               ;
    txa                                                               ;
    jmp leading_zero1                                                 ;

non_zero_digit1
    ldx #0                                                            ;
leading_zero1
    clc                                                               ;
    adc #$30                                                          ;
    jsr oswrch                                                        ;
    dey                                                               ;
    bpl plot_score_in_debriefing_loop                                 ;
    lda score_as_bcd                                                  ;
    sec                                                               ;
    sei                                                               ;
    sed                                                               ;
    sbc previous_score_as_bcd                                         ;
    sta previous_score_as_bcd                                         ;
    lda score_as_bcd + 1                                              ;
    sbc previous_score_as_bcd + 1                                     ;
    sta previous_score_as_bcd + 1                                     ;
    lda score_as_bcd + 2                                              ;
    sbc previous_score_as_bcd + 2                                     ;
    sta previous_score_as_bcd + 2                                     ;
    cld                                                               ;
    cli                                                               ;
    lda escape_capsule_destroyed                                      ;
    eor escape_capsule_launched                                       ;
    sta allowed_another_command                                       ;
    lda command_number                                                ;
    cmp #1                                                            ;
    beq skip_previous_command_score                                   ;
    ldy #0                                                            ;
plot_having_just_gained_loop
    lda having_just_gained_string,y                                   ;
    jsr oswrch                                                        ;
    iny                                                               ;
    cpy #$19                                                          ;
    bne plot_having_just_gained_loop                                  ;
    ldx #1                                                            ;
    lda previous_score_as_bcd + 2                                     ;
    jsr plot_bcd_number_as_two_digits                                 ;
    lda previous_score_as_bcd + 1                                     ;
    jsr plot_bcd_number_as_two_digits                                 ;
    lda previous_score_as_bcd                                         ;
    jsr plot_bcd_number_as_two_digits                                 ;
    txa                                                               ;
    beq skip_previous_command_score                                   ;
    lda #$30                                                          ;
    jsr oswrch                                                        ;
skip_previous_command_score
    lda allowed_another_command                                       ;
    bne plot_after_your_performance                                   ;
    jmp leave_after_plotting_line_of_underscores                      ;

plot_after_your_performance
    ldy #0                                                            ;
plot_after_your_performance_loop
    lda after_your_performance_string,y                               ;
    jsr oswrch                                                        ;
    iny                                                               ;
    cpy #$61                                                          ;
    bne plot_after_your_performance_loop                              ;
judge_player
    lda rnd_2                                                         ;
    and #$3f                                                          ;
    clc                                                               ;
    adc previous_score_as_bcd                                         ;
    sta previous_score_as_bcd                                         ;
    lda previous_score_as_bcd + 1                                     ;
    adc #0                                                            ;
    ldy #5                                                            ;
division_loop1
    lsr                                                               ;
    ror previous_score_as_bcd                                         ;
    dey                                                               ;
    bne division_loop1                                                ;
    ldy #8                                                            ;
    ora previous_score_as_bcd + 2                                     ;
    bne end_of_calculation                                            ;
    ldy #1                                                            ;
    lda previous_score_as_bcd                                         ;
check_threshold_loop
    cmp threshold_table - 1,y                                         ;
    bcc end_of_calculation                                            ;
    iny                                                               ;
    cpy #8                                                            ;
    bne check_threshold_loop                                          ;
end_of_calculation
    sty y_pixels                                                      ;
    ldx #$ff                                                          ;
    lda #$22                                                          ;
find_emotion_loop
    inx                                                               ;
    cmp emotions,x                                                    ;
    bne find_emotion_loop                                             ;
    dey                                                               ;
    bne find_emotion_loop                                             ;
plot_emotion_loop
    inx                                                               ;
    lda emotions,x                                                    ;
    jsr oswrch                                                        ;
    cmp #$22                                                          ;
    bne plot_emotion_loop                                             ;
    lda y_pixels                                                      ;
    cmp #4                                                            ;
    bcc player_retired                                                ;
    ldy #$1a                                                          ;
    ldx #3                                                            ;
    jsr tab_to_x_y                                                    ;
    ldy #0                                                            ;
    lda y_pixels                                                      ;
    cmp #4                                                            ;
    bne plot_and_or_but_loop                                          ;
    ldy #4                                                            ;
plot_and_or_but_loop
    lda and_but_they_allow_string,y                                   ;
    jsr oswrch                                                        ;
    iny                                                               ;
    cmp #$20                                                          ;
    bne plot_and_or_but_loop                                          ;
    ldy #8                                                            ;
plot_they_allow_you_loop
    lda and_but_they_allow_string,y                                   ;
    jsr oswrch                                                        ;
    iny                                                               ;
    cmp #$2e                                                          ;
    bne plot_they_allow_you_loop                                      ;
    beq leave_after_plotting_line_of_underscores                      ;
player_retired
    ldy #0                                                            ;
    sty allowed_another_command                                       ;
plot_and_they_retire_you_loop
    lda and_they_retire_you_string,y                                  ;
    jsr oswrch                                                        ;
    iny                                                               ;
    cmp #$2e                                                          ;
    bne plot_and_they_retire_you_loop                                 ;
leave_after_plotting_line_of_underscores
    jsr plot_line_of_underscores                                      ;
    rts                                                               ;

plot_line_of_underscores
    lda #$0d                                                          ;
    jsr oswrch                                                        ;
    lda #$0a                                                          ;
    jsr oswrch                                                        ;
    ldy #$28                                                          ;
plot_line_of_underscores_loop
    lda #$5f                                                          ;
    jsr oswrch                                                        ;
    dey                                                               ;
    bne plot_line_of_underscores_loop                                 ;
    rts                                                               ;

tab_to_x_y
    lda #$1f                                                          ;
    jsr oswrch                                                        ;
    txa                                                               ;
    jsr oswrch                                                        ;
    tya                                                               ;
    jsr oswrch                                                        ;
    rts                                                               ;

plot_bcd_number_as_two_digits
    tay                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    bne has_non_zero_tens                                             ;
    txa                                                               ;
    bne skip_leading_zeroes                                           ;
has_non_zero_tens
    ldx #0                                                            ;
    clc                                                               ;
    adc #$30                                                          ;
    jsr oswrch                                                        ;
skip_leading_zeroes
    tya                                                               ;
    and #$0f                                                          ;
    bne has_non_zero_ones                                             ;
    txa                                                               ;
    bne skip_leading_zeroes_again                                     ;
has_non_zero_ones
    ldx #0                                                            ;
    clc                                                               ;
    adc #$30                                                          ;
    jsr oswrch                                                        ;
skip_leading_zeroes_again
    rts                                                               ;

instructions_string
    !byte $1f, 6  , 2                                                 ;
    !text "**** STARSHIP CONTROLS ****"                               ;
    !byte $1f, 3  , 5                                                 ;
    !text "Z  -  Rotate left"                                         ;
    !byte $1f, 3  , 6                                                 ;
    !text "X  -  Rotate right"                                        ;
    !byte $1f, 3  , 7                                                 ;
    !text "N  -  Fire torpedoes"                                      ;
    !byte $1f, 3  , 8                                                 ;
    !text "M  -  Thrust"                                              ;
    !byte $1f, 3  , 9                                                 ;
    !text ",  -  Brake"                                               ;
    !byte $1f, 3  , $0b                                               ;
    !text "F  -  Launch port escape capsule"                          ;
    !byte $1f, 3  , $0c                                               ;
    !text "G  -  Launch starboard escape capsule"                     ;
    !byte $1f, 0  , $0e                                               ;
    !text "All the above may operate simultaneouslyAlter"             ;
    !text "natively , ONE of the following maybe depress"             ;
    !text "ed...."                                                    ;
    !byte $1f, 3  , $12                                               ;
    !text "B  -  Shields ON / Scanners OFF"                           ;
    !byte $1f, 3  , $13                                               ;
    !text "V  -  Scanners ON / Shields OFF"                           ;
    !byte $1f, 3  , $14                                               ;
    !text "C  -  ", '"', "Auto-Changeover", '"', " ON"                ;
    !byte $1f, 3  , $16                                               ;
    !text "f0 -  ", '"', "Rotation Dampers", '"', " ON"               ;
    !byte $1f, 3  , $17                                               ;
    !text "2  -  ", '"', "Rotation Dampers", '"', " OFF"              ;
    !byte $1f, 3  , $18                                               ;
    !text "f1 -  ", '"', "Velocity Dampers", '"', " ON"               ;
    !byte $1f, 3  , $19                                               ;
    !text "3  -  ", '"', "Velocity Dampers", '"', " OFF"              ;
    !byte $1f, 3  , $1b                                               ;
    !text "<COPY>   - FREEZE"                                         ;
    !byte $1f, 3  , $1c                                               ;
    !text "<DELETE> - UNFREEZE"                                       ;
    !byte $1f, $0d, $1f                                               ;
    !text "Press <RETURN>~"                                           ;
plot_instructions
    lda #<instructions_string                                         ;
    sta temp0_low                                                     ;
    lda #>instructions_string                                         ;
    sta temp0_high                                                    ;
    ldy #0                                                            ;
plot_instructions_loop
    lda (temp0_low),y                                                 ;
    cmp #'~'                                                          ;
    beq finished_plotting_instructions                                ;
    jsr oswrch                                                        ;
    inc temp0_low                                                     ;
    bne plot_instructions_loop                                        ;
    inc temp0_high                                                    ;
    bne plot_instructions_loop                                        ;
finished_plotting_instructions
finished_plotting_instructions1
    lda #0                                                            ;
    jsr plot_line_of_underscores_at_y                                 ;
    lda #3                                                            ;
    jsr plot_line_of_underscores_at_y                                 ;
    lda #$1d                                                          ;
    jsr plot_line_of_underscores_at_y                                 ;
    rts                                                               ;

plot_line_of_underscores_at_y
    tay                                                               ;
    lda #$1f                                                          ;
    jsr oswrch                                                        ;
    lda #0                                                            ;
    jsr oswrch                                                        ;
    tya                                                               ;
    jsr oswrch                                                        ;
    ldy #$28                                                          ;
    lda #$5f                                                          ;
plot_line_of_underscores_at_y_loop
    jsr oswrch                                                        ;
    dey                                                               ;
    bne plot_line_of_underscores_at_y_loop                            ;
    rts                                                               ;

combat_preparation_screen_key_table
    !byte $df                                                         ;
    !byte $8e                                                         ;
    !byte $8d                                                         ;
    !byte $8c                                                         ;
    !byte $eb                                                         ;
    !byte $8b                                                         ;
    !byte $8a                                                         ;
    !byte $e9                                                         ;
    !byte $89                                                         ;
    !byte $88                                                         ;
game_options
option_sound
    !byte 0                                                           ;
option_starship_torpedoes
    !byte 0                                                           ;
option_enemy_torpedoes
    !byte 0                                                           ;
option_keyboard_joystick
    !byte 0                                                           ;
options_values_to_write
    !byte 0                                                           ;
    !byte 1                                                           ;
    !byte 0                                                           ;
    !byte 1                                                           ;
    !byte $60                                                         ;
    !byte $ea                                                         ;
    !byte 0                                                           ;
    !byte 1                                                           ;
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
combat_preparation_string
    !byte $1f, 6  , 3                                                 ;
    !text "**** COMBAT PREPARATION ****"                              ;
    !byte $1f, 6  , 7                                                 ;
    !text "f0  View starship controls"                                ;
    !byte $1f, 6  , 9                                                 ;
    !text "f1  View Star-Fleet records"                               ;
    !byte $1f, 6  , $0b                                               ;
    !text "f2  Enable"                                                ;
    !byte $1f, $11, $0c                                               ;
    !text "}the sound effects"                                        ;
    !byte $1f, 6  , $0d                                               ;
    !text "f3  Disable"                                               ;
    !byte $1f, 6  , $0f                                               ;
    !text "f4  Small"                                                 ;
    !byte $1f, $11, $10                                               ;
    !text "}starship torpedoes"                                       ;
    !byte $1f, 6  , $11                                               ;
    !text "f5  Large"                                                 ;
    !byte $1f, 6  , $13                                               ;
    !text "f6  Small"                                                 ;
    !byte $1f, $11, $14                                               ;
    !text "}enemy torpedoes"                                          ;
    !byte $1f, 6  , $15                                               ;
    !text "f7  Large"                                                 ;
    !byte $1f, 6  , $17                                               ;
    !text "f8  Keyboard"                                              ;
    !byte $1f, 6  , $19                                               ;
    !text "f9  Joystick"                                              ;
    !byte $1f, $0d, $1e                                               ;
    !text "Press <RETURN>~"                                           ;
plot_selected_options
    ldx #3                                                            ;
plot_selected_options_loop
    lda #$1f                                                          ;
    jsr oswrch                                                        ;
    lda #9                                                            ;
    jsr oswrch                                                        ;
    txa                                                               ;
    asl                                                               ;
    adc game_options,x                                                ;
    asl                                                               ;
    adc #$0b                                                          ;
    jsr oswrch                                                        ;
    lda #$2d                                                          ;
    jsr oswrch                                                        ;
    dex                                                               ;
    bpl plot_selected_options_loop                                    ;
    rts                                                               ;

wait_for_return
    lda #osbyte_flush_buffer_class                                    ;
    ldx #1                                                            ;
    ldy #0                                                            ;
    jsr osbyte                                                        ;
wait_for_return_loop
    lda #osbyte_inkey                                                 ;
    ldx #$32                                                          ;
    ldy #0                                                            ;
    jsr osbyte                                                        ;
    cpy #$1b                                                          ;
    beq escape_pressed                                                ;
    cpy #$ff                                                          ;
    beq wait_for_return_loop                                          ;
    cpx #$0d                                                          ;
    bne wait_for_return_loop                                          ;
    rts                                                               ;

escape_pressed
    lda #osbyte_acknowledge_escape                                    ;
    jsr osbyte                                                        ;
    jmp wait_for_return_loop                                          ;

instructions_screen
    lda #$16                                                          ;
    jsr oswrch                                                        ;
    lda #4                                                            ;
    jsr oswrch                                                        ;
    jsr disable_cursor                                                ;
    jsr set_foreground_colour_to_black                                ;
    jsr plot_instructions                                             ;
    jsr set_foreground_colour_to_white                                ;
    jsr wait_for_return                                               ;
    rts                                                               ;

combat_preparation_screen
    lda #$16                                                          ;
    jsr oswrch                                                        ;
    lda #4                                                            ;
    jsr oswrch                                                        ;
    jsr disable_cursor                                                ;
    jsr set_foreground_colour_to_black                                ;
    lda #<combat_preparation_string                                   ;
    sta temp0_low                                                     ;
    lda #>combat_preparation_string                                   ;
    sta temp0_high                                                    ;
    ldy #0                                                            ;
plot_combat_preparations_loop
    lda (temp0_low),y                                                 ;
    cmp #$7e                                                          ;
    beq finished_plotting_combat_preparations                         ;
    jsr oswrch                                                        ;
    inc temp0_low                                                     ;
    bne plot_combat_preparations_loop                                 ;
    inc temp0_high                                                    ;
    bne plot_combat_preparations_loop                                 ;
finished_plotting_combat_preparations
    lda #1                                                            ;
    jsr plot_line_of_underscores_at_y                                 ;
    lda #4                                                            ;
    jsr plot_line_of_underscores_at_y                                 ;
    jsr set_foreground_colour_to_white                                ;
    jsr plot_selected_options                                         ;
get_keypress
    lda #osbyte_flush_buffer_class                                    ;
    ldx #1                                                            ;
    jsr osbyte                                                        ;
    lda #osbyte_inkey                                                 ;
    ldx #5                                                            ;
    ldy #0                                                            ;
    jsr osbyte                                                        ;
    cpx #$0d                                                          ;
    beq return28                                                      ;
    lda #osbyte_acknowledge_escape                                    ;
    jsr osbyte                                                        ;
    lda #$0a                                                          ;
    sta x_pixels                                                      ;
check_next_key
    dec x_pixels                                                      ;
    bmi get_keypress                                                  ;
    ldx x_pixels                                                      ;
    lda combat_preparation_screen_key_table,x                         ;
    tax                                                               ;
    tay                                                               ;
    lda #osbyte_inkey                                                 ;
    jsr osbyte                                                        ;
    tya                                                               ;
    beq check_next_key                                                ;
    ldx x_pixels                                                      ;
    bne not_f0                                                        ;
    jsr instructions_screen                                           ;
    jmp combat_preparation_screen                                     ;

not_f0
    cpx #1                                                            ;
    bne not_f1                                                        ;
    jsr starfleet_records_screen                                      ;
    jmp combat_preparation_screen                                     ;

not_f1
    txa                                                               ;
    lsr                                                               ;
    tay                                                               ;
    txa                                                               ;
    and #1                                                            ;
    cmp game_options - 1,y                                            ;
    beq check_next_key                                                ;
    sta game_options - 1,y                                            ;
    lda option_address_low_table - 1,y                                ;
    sta temp0_low                                                     ;
    lda option_address_high_table - 1,y                               ;
    sta temp0_high                                                    ;
    lda option_enemy_torpedoes,x                                      ;
    ldy #0                                                            ;
    sta (temp0_low),y                                                 ;
    jmp combat_preparation_screen                                     ;

return28
    rts                                                               ;

; ----------------------------------------------------------------------------------
starfleet_records_string
    !byte $1f, 6  , 1                                                 ;
    !text "**** STAR-FLEET RECORDS ****"                              ;
    !byte $1f, 0  , 4                                                 ;
    !text "Below is a list of the most highly ratedof St"             ;
    !text "ar-Fleet's past commanders."                               ;
    !byte $1f, $0d, $18                                               ;
    !text "Press <RETURN>~"                                           ;
; ----------------------------------------------------------------------------------
; There are eight entries of 16 bytes each. The first three bytes are the score, then 13 bytes for the name
; ----------------------------------------------------------------------------------
high_score_table
    !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0              ;
    !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0              ;
    !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0              ;
    !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0              ;
    !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0              ;
    !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0              ;
    !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0              ;
    !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0              ;
starfleet_records_screen
    lda #$16                                                          ;
    jsr oswrch                                                        ;
    lda #7                                                            ;
    jsr oswrch                                                        ;
    jsr disable_cursor                                                ;
    lda #<starfleet_records_string                                    ;
    sta temp0_low                                                     ;
    lda #>starfleet_records_string                                    ;
    sta temp0_high                                                    ;
    ldy #0                                                            ;
plot_starfleet_records_loop
    lda (temp0_low),y                                                 ;
    cmp #$7e                                                          ;
    beq finished_plotting_starfleet_records                           ;
    jsr oswrch                                                        ;
    inc temp0_low                                                     ;
    bne plot_starfleet_records_loop                                   ;
    inc temp0_high                                                    ;
    bne plot_starfleet_records_loop                                   ;
finished_plotting_starfleet_records
    lda #8                                                            ;
    sta temp8                                                         ;
    ldx #0                                                            ;
plot_high_scores_loop
    lda #$1f                                                          ;
    jsr oswrch                                                        ;
    lda #7                                                            ;
    jsr oswrch                                                        ;
    txa                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc #8                                                            ;
    jsr oswrch                                                        ;
    lda high_score_table + 3,x                                        ;
    beq leave_after_plotting_underscores                              ;
    txa                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    clc                                                               ;
    adc #$31                                                          ;
    jsr oswrch                                                        ;
    lda #$20                                                          ;
    jsr oswrch                                                        ;
    jsr oswrch                                                        ;
    jsr oswrch                                                        ;
    inx                                                               ;
    inx                                                               ;
    inx                                                               ;
    ldy #$0d                                                          ;
plot_name_loop
    lda high_score_table,x                                            ;
    jsr oswrch                                                        ;
    inx                                                               ;
    dey                                                               ;
    bne plot_name_loop                                                ;
    lda #$20                                                          ;
    jsr oswrch                                                        ;
    jsr oswrch                                                        ;
    jsr oswrch                                                        ;
    ldy #$20                                                          ;
    lda high_score_table - 16,x                                       ;
    jsr plot_two_digit_high_score                                     ;
    lda high_score_table - 15,x                                       ;
    jsr plot_two_digit_high_score                                     ;
    lda high_score_table - 14,x                                       ;
    jsr plot_two_digit_high_score                                     ;
    dec temp8                                                         ;
    bne plot_high_scores_loop                                         ;
leave_after_plotting_underscores
    lda #0                                                            ;
    jsr plot_line_of_underscores_at_y                                 ;
    lda #2                                                            ;
    jsr plot_line_of_underscores_at_y                                 ;
    lda #$17                                                          ;
    jsr plot_line_of_underscores_at_y                                 ;
    jsr wait_for_return                                               ;
    rts                                                               ;

plot_two_digit_high_score
    sta temp7                                                         ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    jsr plot_one_digit_high_score                                     ;
    lda temp7                                                         ;
    and #$0f                                                          ;
plot_one_digit_high_score
    bne not_zero                                                      ;
    tya                                                               ;
    bne leading_zero2                                                 ;
not_zero
    ldy #$30                                                          ;
    clc                                                               ;
    adc #$30                                                          ;
leading_zero2
    jsr oswrch                                                        ;
    rts                                                               ;

; ----------------------------------------------------------------------------------
enter_your_name_string
    !byte $1f, 0  , $0a                                               ;
    !text "Enter your name for Star-Fleet records."                   ;
    !byte $1f, $0d, $10                                               ;
    !text "-------------"                                             ;
    !byte $1f, $0d, $0f, $7e, $0d                                     ;
input_buffer
    !text "PPPPPPPPPPPP"                                              ;
    !byte $88, $0d                                                    ;
input_osword_block
    !word input_buffer                                                ;
    !byte $0d, $20, $ff                                               ;
; ----------------------------------------------------------------------------------
check_for_high_score
    lda #$16                                                          ;
    jsr oswrch                                                        ;
    lda #4                                                            ;
    jsr oswrch                                                        ;
    lda score_as_bcd                                                  ;
    ora score_as_bcd + 1                                              ;
    ora score_as_bcd + 2                                              ;
    beq score_is_zero                                                 ;
    lda #8                                                            ;
    sta temp8                                                         ;
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
    dec temp8                                                         ;
    bne consider_records_loop                                         ;
score_is_zero
    rts                                                               ;

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
    lda #<enter_your_name_string                                      ;
    sta temp0_low                                                     ;
    lda #>enter_your_name_string                                      ;
    sta temp0_high                                                    ;
    ldy #0                                                            ;
plot_enter_your_name_loop
    lda (temp0_low),y                                                 ;
    cmp #$7e                                                          ;
    beq finished_plotting_enter_your_name                             ;
    jsr oswrch                                                        ;
    inc temp0_low                                                     ;
    bne plot_enter_your_name_loop                                     ;
    inc temp0_high                                                    ;
    bne plot_enter_your_name_loop                                     ;
finished_plotting_enter_your_name
    ldx #<(input_osword_block)                                        ;
    ldy #>(input_osword_block)                                        ;
    lda #osword_read_line                                             ;
    jsr osword                                                        ;
    sty y_pixels                                                      ;
    bcc escape_not_pressed                                            ;
    lda #osbyte_acknowledge_escape                                    ;
    jsr osbyte                                                        ;
escape_not_pressed
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
    jsr starfleet_records_screen                                      ;
    rts                                                               ;

plot_shields_string_and_something
    txa                                                               ;
    and #1                                                            ;
    sta starship_shields_active_before_failure                        ;
    jsr plot_shields_string                                           ;
    lda scanner_failure_duration                                      ;
    beq return29                                                      ;
    pla                                                               ;
    pla                                                               ;
return29
    rts                                                               ;

plot_auto_shields_string
    lda previous_starship_automatic_shields                           ;
    cmp starship_automatic_shields                                    ;
    bpl return30                                                      ;
    ldx #$0e                                                          ;
plot_shields_string
    ldy #7                                                            ;
plot_shields_string_loop
    lda shield_state_strings,x                                        ;
    jsr oswrch                                                        ;
    inx                                                               ;
    dey                                                               ;
    bne plot_shields_string_loop                                      ;
return30
    rts                                                               ;

start_game
    lda #$16                                                          ;
    jsr oswrch                                                        ;
    lda #4                                                            ;
    jsr oswrch                                                        ;
    jsr disable_cursor                                                ;
    lda #0                                                            ;
    sta previous_score_as_bcd                                         ;
    sta previous_score_as_bcd + 1                                     ;
    sta previous_score_as_bcd + 2                                     ;
    sta number_of_live_starship_torpedoes                             ;
    jmp start_game_continuation                                       ;

end_of_command
    pla                                                               ;
    pla                                                               ;
    lda enemy_ships_previous_x_fraction                               ;
    sta rnd_2                                                         ;
    lda enemy_ships_previous_x_fraction1                              ;
    sta rnd_1                                                         ;
    lda #$16                                                          ;
    jsr oswrch                                                        ;
    lda #4                                                            ;
    jsr oswrch                                                        ;
    jsr disable_cursor                                                ;
    jsr set_foreground_colour_to_black                                ;
    jsr plot_debriefing                                               ;
    jsr set_foreground_colour_to_white                                ;
    jsr wait_for_return                                               ;
    lda allowed_another_command                                       ;
    bne start_next_command                                            ;
    jsr check_for_high_score                                          ;
    jmp start                                                         ;

start_next_command
    jsr combat_preparation_screen                                     ;
    lda score_as_bcd                                                  ;
    sta previous_score_as_bcd                                         ;
    lda score_as_bcd + 1                                              ;
    sta previous_score_as_bcd + 1                                     ;
    lda score_as_bcd + 2                                              ;
    sta previous_score_as_bcd + 2                                     ;
    ldy #3                                                            ;
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
    cmp minimum_number_of_stars                                       ;
    beq skip_change_of_stars                                          ;
    clc                                                               ;
    adc change_in_number_of_stars_per_command                         ;
    sta maximum_number_of_stars                                       ;
skip_change_of_stars
    lda #$16                                                          ;
    jsr oswrch                                                        ;
    lda #4                                                            ;
    jsr oswrch                                                        ;
    jsr disable_cursor                                                ;
    jsr prepare_starship_for_next_command                             ;
    jmp main_game_loop                                                ;

the_frontiers_string
    !byte $1f, 0  , 5                                                 ;
    !text "  The frontiers of space are frequently penet"             ;
    !text "rated  by  hostile  alien  ships .  These are"             ;
    !text " tackled by battle starships ,the  command  o"             ;
    !text "f  which  is  given  to  deserving captains f"             ;
    !text "rom the Star-Fleet ."                                      ;
    !byte $1f, $0b, 2                                                 ;
    !text "STARSHIP  COMMAND"                                         ;
    !byte $1f, 6  , $0a                                               ;
    !text "To begin your first command"                               ;
    !byte $1f, $0c, $0b                                               ;
    !text "Press <RETURN>~"                                           ;
start
    lda #<star_table                                                  ;
    sta temp0_low                                                     ;
    lda #>star_table                                                  ;
    sta temp0_high                                                    ;
    ldy #0                                                            ;
    ldx #0                                                            ;
initialise_stars_loop
    lda #$80                                                          ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    lda initial_star_positions,x                                      ;
    sta (temp0_low),y                                                 ;
    iny                                                               ;
    bne skip                                                          ;
    inc temp0_high                                                    ;
skip
    inx                                                               ;
    bne initialise_stars_loop                                         ;
    jsr initialise_joystick_and_cursor_keys                           ;
    lda #$16                                                          ;
    jsr oswrch                                                        ;
    lda #4                                                            ;
    jsr oswrch                                                        ;
    lda #$0d                                                          ;
    jsr oswrch                                                        ;
    lda #0                                                            ;
    jsr plot_line_of_underscores_at_y                                 ;
    lda #3                                                            ;
    jsr plot_line_of_underscores_at_y                                 ;
    lda #<the_frontiers_string                                        ;
    sta temp0_low                                                     ;
    lda #>the_frontiers_string                                        ;
    sta temp0_high                                                    ;
    ldy #0                                                            ;
plot_the_frontiers_loop
    lda (temp0_low),y                                                 ;
    cmp #$7e                                                          ;
    beq finished_the_frontiers                                        ;
    jsr oswrch                                                        ;
    inc temp0_low                                                     ;
    bne plot_the_frontiers_loop                                       ;
    inc temp0_high                                                    ;
    bne plot_the_frontiers_loop                                       ;
finished_the_frontiers
    lda #osbyte_flush_buffer_class                                    ;
    ldx #1                                                            ;
    ldy #0                                                            ;
    jsr osbyte                                                        ;
    lda #$80                                                          ;
    sta maximum_number_of_stars                                       ;
    lda #1                                                            ;
    sta starship_velocity_high                                        ;
    sta starship_velocity_low                                         ;
    lda #$85                                                          ;
    sta starship_rotation                                             ;
    lda #5                                                            ;
    sta starship_rotation_magnitude                                   ;
    lda #$ce                                                          ;
    sta starship_rotation_cosine                                      ;
    lda #$0a                                                          ;
    sta starship_rotation_sine_magnitude                              ;
    lda #$62                                                          ;
    sta screen_start_high                                             ;
    jsr plot_stars                                                    ;
wait_for_return_in_frontiers
    inc rnd_1                                                         ;
    jsr update_stars                                                  ;
    lda #osbyte_inkey                                                 ;
    ldx #$b6                                                          ; check for RETURN
    ldy #$ff                                                          ;
    jsr osbyte                                                        ;
    cpy #$ff                                                          ;
    bne wait_for_return_in_frontiers                                  ;

return_pressed
    lda #$58                                                          ;
    sta screen_start_high                                             ;
    lda rnd_1                                                         ;
    eor #$cd                                                          ;
    sta rnd_2                                                         ;
    lda #$0d                                                          ;
    jsr oswrch                                                        ;
    jsr combat_preparation_screen                                     ;
    jmp start_game                                                    ;

get_joystick_input
    lda #osbyte_read_adc_or_get_buffer_status                         ;
    ldx #0                                                            ;
    jsr osbyte                                                        ;
    txa                                                               ;
    and #3                                                            ;
    beq fire_not_pressed                                              ;
    inc fire_pressed                                                  ;
fire_not_pressed
    lda #osbyte_read_adc_or_get_buffer_status                         ;
    ldx #2                                                            ;
    jsr osbyte                                                        ;
    lda starship_velocity_high                                        ;
    sta x_pixels                                                      ;
    lda starship_velocity_low                                         ;
    asl                                                               ;
    rol x_pixels                                                      ;
    asl                                                               ;
    rol x_pixels                                                      ;
    tya                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    lsr                                                               ;
    sec                                                               ;
    sbc #8                                                            ;
    bcs skip_floor1                                                   ;
    lda #0                                                            ;
skip_floor1
    cmp x_pixels                                                      ;
    beq consider_rotation                                             ;
    bcc decrease_velocity                                             ;
increase_velocity
    inc velocity_delta                                                ;
    jmp consider_rotation                                             ;

decrease_velocity
    dec velocity_delta                                                ;
consider_rotation
    lda #osbyte_read_adc_or_get_buffer_status                         ;
    ldx #1                                                            ;
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
    jmp return31                                                      ;

rotate_clockwise
    inc rotation_delta                                                ;
return31
    rts                                                               ;

sound_10
    !byte $11, 0                                                      ;
sound_10_volume_low
    !byte 0                                                           ;
sound_10_volume_high
    !byte 0                                                           ;
sound_10_pitch
    !byte 0, 0, 4, 0                                                  ;
sound_11
    !byte $10, 0  , 3  , 0  , 7  , 0  , $1e, 0                        ;
initial_star_positions
    !byte $d5, $82, $d5, $7b, $d5, $88, $d5, $75, $d3, $8f, $d3, $6e  ;
    !byte $d3, $84, $d3, $79, $d2, $8d, $d2, $70, $d1, $95, $d1, $68  ;
    !byte $cf, $92, $cf, $6b, $cf, $9b, $cf, $62, $cf, $87, $cf, $76  ;
    !byte $cb, $a0, $cb, $5d, $cb, $98, $cb, $65, $c9, $8b, $c9, $72  ;
    !byte $c7, $9c, $c7, $61, $c7, $a5, $c7, $58, $c3, $aa, $c3, $53  ;
    !byte $c2, $8d, $c2, $70, $c1, $a0, $c1, $5d, $be, $ae, $be, $4f  ;
    !byte $bb, $a4, $bb, $59, $b9, $90, $b9, $6d, $b8, $b2, $b8, $4b  ;
    !byte $b4, $a7, $b4, $56, $b3, $b5, $b3, $48, $af, $91, $af, $6c  ;
    !byte $ad, $b7, $ad, $46, $ad, $a9, $ad, $54, $a6, $b9, $a6, $44  ;
    !byte $a5, $ab, $a5, $52, $a5, $92, $a5, $6b, $a0, $ba, $a0, $43  ;
    !byte $9d, $ab, $9d, $52, $9a, $bb, $9a, $43, $9a, $93, $9a, $6b  ;
    !byte $96, $ab, $96, $52, $93, $ba, $93, $43, $8e, $ab, $8e, $52  ;
    !byte $8e, $92, $8e, $6b, $8d, $b9, $8d, $44, $86, $a9, $86, $54  ;
    !byte $86, $b7, $86, $46, $84, $91, $84, $6c, $80, $b5, $80, $48  ;
    !byte $7f, $a7, $7f, $56, $7b, $b2, $7b, $4b, $7a, $90, $7a, $6d  ;
    !byte $78, $a4, $78, $59, $75, $ae, $75, $4f, $72, $a0, $72, $5d  ;
    !byte $71, $8d, $71, $70, $70, $aa, $70, $53, $6c, $a5, $6c, $58  ;
    !byte $6c, $9c, $6c, $61, $6a, $8b, $6a, $72, $68, $98, $68, $65  ;
    !byte $68, $a0, $68, $5d, $64, $92, $64, $6b, $64, $9b, $64, $62  ;
    !byte $64, $87, $64, $76, $62, $95, $62, $68, $61, $8d, $61, $70  ;
    !byte $60, $8f, $60, $6e, $60, $84, $60, $79, $5e, $82, $5e, $7b  ;
    !byte $5e, $88, $5e, $75                                          ;
star_table
    !byte $cd, $49, $3a, $96, $f8, $8d, $6e, $61, $c6, $2d, $68, $1f  ;
    !byte $0d, $74, $52, $d2, $f8, $9e, $3e, $a9, $b1, $25, $2b, $54  ;
    !byte $6d, $6f, $94, $44, $56, $24, $fb, $88, $fd, $b6, $8f, $31  ;
    !byte $6a, $ea, $36, $b6, $14, $b5, $0a, $4b, $97, $4c, $f4, $0a  ;
    !byte $10, $9d, 7  , $40, $e5, $66, $c0, $26, $25, $7d, $2e, $4c  ;
    !byte $63, $7a, $fe, $e4, $b2, $23, $a6, $43, $84, $cc, $3f, $6c  ;
    !byte $c0, $d0, $39, $96, $be, $c3, $80, $54, $32, $cf, $60, $8e  ;
    !byte $4b, $c5, $59, $5c, $b6, $ca, 3  , $82, $dc, $c5, $7c, $69  ;
    !byte $0c, $cc, $13, $93, $99, $c0, $33, $59, $cc, $cd, $e7, $9b  ;
    !byte $da, $be, $5d, $50, $d7, $ca, $95, $a1, $f4, $b9, $3d, $4c  ;
    !byte $3a, $c4, $55, $85, $9b, $be, $e2, $68, $f1, $c6, $2b, $98  ;
    !byte $ee, $b9, $70, $56, $b6, $c6, $7c, $a6, $45, $b4, $49, $49  ;
    !byte $d3, $c1, $41, $9d, $46, $b3, $ae, $53, $fb, $bb, 6  , $8a  ;
    !byte $31, $b5, $af, $67, $9a, $c1, $92, $ab, $9c, $ad, $87, $46  ;
    !byte $8b, $bb, $8d, $a1, $d2, $ab, $18, $52, $49, $bd, $7b, $af  ;
    !byte $1f, $a8, $8f, $44, $5e, $b2, $f2, $8c, $30, $ab, $a6, $68  ;
    !byte $c9, $b7, $9c, $b2, $d9, $a1, $c1, $43, $12, $b5, $e0, $a4  ;
    !byte $90, $a4, $7d, $51                                          ;
starship_explosion_table
    !byte 0  , 0  , $2f, 0  , 9  , $57, 0  , $15, $96, 0  , $1a, $63  ;
    !byte 0  , $46, $90, 0  , $59, $55, 0  , $37, $9a, 0  , $7d, $91  ;
    !byte 0  , $32, $69, 0  , $3b, $75, 0  , $7e, $a0, 0  , $71, $51  ;
    !byte 0  , $42, $67, 0  , $42, $61, 0  , $57, $9a, 0  , $0a, $6d  ;
    !byte 0  , $f6, $a1, 0  , $6e, $98, 0  , $55, $8a, 0  , $36, $9d  ;
    !byte 0  , $3d, $94, 0  , $2b, $75, 0  , $78, $32, 0  , 6  , $a1  ;
    !byte 0  , $29, $4c, 0  , $0e, $98, 0  , $2c, $83, 0  , $0d, $99  ;
    !byte 0  , $39, $56, 0  , $15, $91, 0  , 5  , $98, 0  , $13, $73  ;
    !byte 0  , $6d, $8a, 0  , $40, $36, 0  , 3  , $7e, 0  , $51, $4d  ;
    !byte 0  , $34, $81, 0  , $90, $33, 0  , $25, $86, 0  , $21, $53  ;
    !byte 0  , $1f, $a0, 0  , $72, $65, 0  , $6c, $8d, 0  , $16, $96  ;
    !byte 0  , $2f, $9c, 0  , $79, $4d, 0  , $45, $8c, 0  , $2f, $9f  ;
    !byte 0  , $64, $8c, 0  , $12, $68, 0  , $43, $76, 0  , $6d, $93  ;
    !byte 0  , $2b, $7c, 0  , $62, $64, 0  , $65, $92, 0  , $3d, $97  ;
    !byte 0  , $16, $8c, 0  , $45, $95, 0  , $1a                      ;
    !byte $69, 0  , $b1, $55, 0  , $26, $9e, 0  , $4b, $79, 0  , $85  ;
    !byte $98, 0  , $4a, $64                                          ;
further_star_table
    !byte $86, $74, $92, $ad, $94, $65, 8  , $62, $c6, $72, $be, $a4  ;
    !byte $53, $67, $dd, $6a, $85, $6d, $73, $94, $ab, $68, $ee, $7b  ;
    !byte $14, $6e, $97, $a1, $2e, $64, $91, $6f, $a1, $6f, $71, $a9  ;
    !byte $9f, $62, $b7, $67, $fd, $68, $7c, $9c, $6b, $61, $3a, $76  ;
    !byte $bd, $6a, $50, $a5, $ac, $5f, $66, $6d, $db, $66, $b1, $91  ;
    !byte $8d, $63, 5  , $81, $9d, $67, $d0, $9f, $e0, $5e, $ab, $73  ;
    !byte $12, $65, $2b, $98, $74, $5f, $b6, $7b, $7d, $64, $51, $9a  ;
    !byte $15, $5e, $f3, $79, $5b, $62, $87, $8f, $37, $60, $bd, $84  ;
    !byte 0  , $60, $f3, $8d, $a3, $5e, $16, $87, $2a, $61, $d7, $93  ;
    !byte $78, $5d, $33, $81                                          ;
enemy_explosion_tables
    !byte 0  , $d3, 0  , $85, 0  , $a9, 0  , $c6                      ;
    !byte 0  , $d7, 0  , $9e, 0  , $cb, 0  , $cb                      ;
    !byte 0  , $9e, 0  , $a1, 0  , $7d, 0  , $da                      ;
    !byte 0  , $fb, 0  , $ce, 0  , $b2, 0  , $54                      ;
    !byte 0  , $6c, 0  , $da, 0  , $99, 0  , $aa                      ;
    !byte 0  , $d6, 0  , $91, 0  , $95, 0  , $ad                      ;
    !byte 0  , $f7, 0  , $81, 0  , $89, 0  , $64                      ;
    !byte 0  , $99, 0  , $fb, 0  , $44, 0  , $a2                      ;
    !byte 0  , $a5, 0  , $9d, 0  , $a2, 0  , $a5                      ;
    !byte 0  , $75, 0  , $fb, 0  , $48, 0  , $ae                      ;
    !byte 0  , $d2, 0  , $4c, 0  , $ff, 0  , $60                      ;
    !byte 0  , $71, 0  , $ba, 0  , $44, 0  , $4c                      ;
    !byte 0  , $c2, 0  , $58, 0  , $f3, 0  , $91                      ;
    !byte 0  , $e7, 0  , $aa, 0  , $71, 0  , $da                      ;
    !byte 0  , $9e, 0  , $71, 0  , $50, 0  , $50                      ;
    !byte 0  , $a2, 0  , $4c, 0  , $e3, 0  , $cb                      ;
    !byte 0  , $91, 0  , $f3, 0  , $85, 0  , $89                      ;
    !byte 0  , $81, 0  , $e3, 0  , $cb, 0  , $9e                      ;
    !byte 0  , $44, 0  , $ba, 0  , $a1, 0  , $79                      ;
    !byte 0  , $54, 0  , $58, 0  , $44, 0  , $c7                      ;
    !byte 0  , $aa, 0  , $cb, 0  , $7d, 0  , $68                      ;
    !byte 0  , $a5, 0  , $cf, 0  , $40, 0  , $71                      ;
    !byte 0  , $68, 0  , $ae, 0  , $d2, 0  , $c2                      ;
    !byte 0  , $ae, 0  , $da, 0  , $6c, 0  , $c2                      ;
    !byte 0  , $a2, 0  , $54, 0  , $78, 0  , $eb                      ;
    !byte 0  , $d6, 0  , $fb, 0  , $ce, 0  , $fb                      ;
    !byte 0  , $81, 0  , $ad, 0  , $f7, 0  , $ad                      ;
    !byte 0  , $89, 0  , $a2, 0  , $b6, 0  , $91                      ;
    !byte 0  , $44, 0  , $d2, 0  , $a6, 0  , $c7                      ;
    !byte 0  , $85, 0  , $44, 0  , $50, 0  , $74                      ;
    !byte 0  , $85, 0  , $79, 0  , $a2, 0  , $40                      ;
    !byte 0  , $75, 0  , $ca, 0  , $cf, 0  , $a6                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff                      ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
    !byte 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0                        ;
starship_torpedoes_table
    !byte 0  , $4b, $66, $b1, $48, $fd, $66, $a3, $4a, 0  , $17, $66  ;
    !byte $3a, $4b, $cb, $66, $2b, $4d, 0  , $94, $49, $19, $44, $a2  ;
    !byte $4a, $db, $45, 0  , $2f, $4a, 9  , $46, $3d, $4b, $c9, $47  ;
    !byte 0  , $6b, $4b, $0e, $48, $77, $4c, $d2, $49, 0  , $81, $4b  ;
    !byte $fc, $48, $91, $4c, $bf, $4a, 0  , $39, $83, $6b, $3f, $1d  ;
    !byte $83, $7c, $41, 0  , $72, $7d, $89, $3a, $82, $7d, $98, $3c  ;
    !byte 0  , $12, $75, $76, $3f, $60, $75, $7e, $41, 0  , $99, $6d  ;
    !byte $31, $3d, $13, $6e, $33, $3f, 0  , $d5, $6a, $36, $40, $63  ;
    !byte $6b, $35, $42, 0  , $b1, $68, $93, $43, $4f, $69, $86, $45  ;
enemy_torpedoes_table
    !byte 0  , $fb, $23, 5  , 7  , $97, 0  , $38, $83, $f6, $7d, $9e  ;
    !byte 0  , $e7, $45, $45, $8a, $c5, 0  , $f9, $37, $94, $6c, $bf  ;
    !byte 0  , $78, $8a, $4e, $77, $a5, 0  , $28, $82, $6d, $7c, $d2  ;
    !byte 0  , $72, $fe, $82, $b1, $ac, 0  , $26, $81, $c2, $7e, $c8  ;
    !byte 0  , $ab, $fd, $23, $a7, $ae, 0  , $4a, $fe, $f5, $93, $b8  ;
    !byte 0  , $5e, 2  , 3  , $ed, $9f, 0  , $85, $fd, 9  , $98, $b7  ;
    !byte 0  , $46, $81, $d8, $7b, $ab, 0  , $f0, $18, $b1, $b0, $a8  ;
    !byte 0  , $75, $0d, $21, $90, $b8, 0  , $fb, $43, $77, $c9, $b3  ;
    !byte 0  , $1d, $47, 1  , $8f, $af, 0  , $55, $43, $b0, $73, $c3  ;
    !byte 0  , $2e, $36, $45, $b1, $b4, 0  , $ed, $81, $73, $7d, $a7  ;
    !byte 0  , $af, $7d, $5d, $7b, $b2, 0  , $d9, $1c, $c9, $93, $b4  ;
    !byte 0  , $51, $21, $1d, $82, $b8, 0  , $31, $28, $f2, $96, $be  ;
}
; ----------------------------------------------------------------------------------
entry_point
    lda #0                                                            ;
    tay                                                               ;
    sta $80                                                           ;
    lda #$0e                                                          ; dest = $0e00
    sta $81                                                           ;
    lda #0                                                            ;
    sta $82                                                           ;
    lda #$1f                                                          ; source = $1f00
    sta $83                                                           ;
    lda #<entry_point                                                 ;
    sta $84                                                           ;
    lda #>entry_point                                                 ; end = $61b0
    sta $85                                                           ;
relocate_loop
    lda ($82),y                                                       ;
    sta ($80),y                                                       ;
    ldx $82                                                           ;
    cpx $84                                                           ;
    bne not_done                                                      ;
    ldx $83                                                           ;
    cpx $85                                                           ;
    beq done                                                          ;
not_done
    clc                                                               ;
    lda #$01                                                          ;
    adc $82                                                           ;
    sta $82                                                           ;
    lda #$00                                                          ;
    adc $83                                                           ;
    sta $83                                                           ;
    lda #$01                                                          ;
    adc $80                                                           ;
    sta $80                                                           ;
    lda #$00                                                          ;
    adc $81                                                           ;
    sta $81                                                           ;
    jmp relocate_loop                                                 ;

done
    jmp start
