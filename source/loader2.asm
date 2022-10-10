; loader2.asm

; This code manages the loading and decompression of the game from tape including
; simultaneously updating the globe rotation and time remaining.

; There are two stack pointers, one for the decrunch code, and one for the regular code.
stack_main                  = $500               ; main stack pointer
stack_decrunch              = $501               ; decrunch stack pointer

irq1v_low                   = $0204
irq1v_high                  = $0205
rs423IRQBitMask             = $0278
acia6850ControlRegister     = $fe08
acia6850DataRegister        = $fe09
serialULAControlRegister    = $fe10

!if elk=0 {
    gcb_loc = $54b
} else {
    gcb_loc = $545
}

decrunch                    = $41e
INITSTACK                   = $c0

!pseudopc gcb_loc {

loader_start

; ----------------------------------------------------------------------------------
; This routine is called each time a new byte is required by the decompression routine.
; It switches stacks and register state from the middle of the decrunch routine to the
; main stack to continue updating the globe etc. The main stack code will continue until
; an interrupt indicating the next byte from tape has arrived (see get_crunched_byte_irq).
; This updates the time remaining, and switches back to the decrunch stack to continue
; the decompression with the newly acquired byte.
;
; Effectively the decompression routine is running under the IRQ interrupt (after the
; first byte), and this does some fancy stack manipulation to manage the control flow.
; ----------------------------------------------------------------------------------
get_crunched_byte
    ; remember flags and registers
    php                             ;
    tya                             ;
    pha                             ;
    txa                             ;
    pha                             ;

    ; first time called?
    bit first                       ;
    bmi not_first                   ;
    sec                             ;
    ror first                       ;

    ; first time called
    ; remember the current stack pointer as the decrunch stack pointer
    tsx                             ;
    stx stack_decrunch              ;

    ; switch back to regular stack pointer
    ldx stack_main                  ;
    txs                             ;
    cli                             ;
    rts                             ; return to main code

not_first
    ; remember the current stack pointer as the decrunch stack pointer
    tsx                             ;
    stx stack_decrunch              ;

    ; switch back to main stack pointer
    ldx stack_main                  ;
    txs                             ;

    ; restore main stack registers
    pla                             ;
    tay                             ;
    pla                             ;
    tax                             ;

    ; exit the interrupt back to main code
    lda $fc                         ;
    rti                             ;
loader_end
}

; ----------------------------------------------------------------------------------
; load in three parts
part_number
    !byte 2                         ; total number of parts minus one

; ----------------------------------------------------------------------------------
irqdecr_init
    sei                             ;

    ; replace IRQ1 vector with our own routine
    lda irq1v_low                   ;
    sta oldirq+1                    ;
    lda irq1v_high                  ;
    sta oldirq+2                    ;
    lda #<get_crunched_byte_irq     ;
    sta irq1v_low                   ;
    lda #>get_crunched_byte_irq     ;
    sta irq1v_high                  ;

    ; remember main stack pointer
    tsx                             ;
    stx stack_main                  ;

    ; set new stack pointer for decompressing
    ldx #INITSTACK                  ;
    txs                             ;

!if elk=0 {
    ; BBC/Master
    ldx #0                          ;
    stx rs423IRQBitMask             ; Disable RS-423 interrupts.
} else {
    ; Electron
    lda #$f0                        ;
    sta $282                        ;
    lda #$1c                        ;
    sta $fe00                       ;
    lda #$0c                        ;
    sta $25b                        ;
}

    ; decompress each part in turn
    ;
    ; while waiting for the next byte to be read, control is transferred back to the
    ; main stack (the routine calling this) until the next byte is read.
-
    jsr decrunch                    ;
    dec part_number                 ;
    bne -                           ;

loading_done
!if elk=0 {
    ; BBC/Master
    lda #%01010110                  ;
    sta acia6850ControlRegister     ;
    lda acia6850ControlRegister     ;
    lda #%01000101                  ; Make ACIA control the RS-423 system rather than tape
    sta serialULAControlRegister    ; tape off
} else {
    ; Electron
    lda #$0c                        ;
    sta $fe00                       ;
    ldx #0                          ;
    jsr $e48a                       ; tape off
}

    ; restore old IRQ1 handler
    sei                             ;
    lda oldirq+1                    ;
    sta irq1v_low                   ;
    lda oldirq+2                    ;
    sta irq1v_high                  ;
    cli                             ;

    jmp not_first                   ;

; ----------------------------------------------------------------------------------
; When we receive a byte from tape, we update the timer, and switch from the main
; stack to the decrunch stack. This continues the decompression code until the next byte
; is needed, where it switches back to the main stack to continue the main code.
; See 'get_crunched_byte'.
; ----------------------------------------------------------------------------------
get_crunched_byte_irq
!if elk=0 {
    ; BBC/Master
    lda acia6850ControlRegister     ;
    lsr                             ;
    bcs +                           ; branch if ACIA is the reason for the interrupt
} else {
    ; Electron
    lda #$10                        ;
    bit $fe00                       ;
    bne +                           ; branch if ACIA is the reason for the interrupt
}
oldirq
    jmp $ffff                       ; regular interrupt handling

    ; We've read a byte from tape
+
    ; remember the registers on the main stack
    txa                             ;
    pha                             ;
    tya                             ;
    pha                             ;

    ; update a timer to measure once a second
    dec timer                       ;
    bne +                           ;

    ; reset second timer
    lda #120                        ;
    sta timer                       ;

    ; update time remaining
    dec time_left+3                 ;
    bpl +                           ;
    lda #9                          ;
    sta time_left+3                 ;
    dec time_left+2                 ;
    bpl +                           ;
    lda #5                          ;
    sta time_left+2                 ;
    dec time_left                   ;
+
    ; store main stack pointer
    tsx                             ;
    stx stack_main                  ;

    ; start using decrunch stack pointer
    ldx stack_decrunch              ;
    txs                             ;

    pla                             ;
    tax                             ;
    pla                             ;
    tay                             ;
!if elk=0 {
    ; BBC/Master
    lda acia6850DataRegister        ; read byte
} else {
    ; Electron
    lda $fe04                       ; read byte
}
    plp                             ;
    rts                             ; return to decrunch routine

; ----------------------------------------------------------------------------------
first
    !byte 0

time_left
    !byte '1' - '0'                 ; Digits of the time remaining
    !byte ':' - '0'                 ;
    !byte '3' - '0'                 ;
    !byte '0' - '0'                 ;

timer
    !byte 120                       ; ticks down each interrupt
