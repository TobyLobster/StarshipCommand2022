; tape.asm
;
; This corresponds to the first file loaded from tape

; insert the decompression code before the proper start (to check it fits)
* = $401
!source "source/exo.asm"

start
	!if start != $500 {
	!error "Wrong start address ", start
	}

basic
    ; A short (tokenised) BASIC program: "2022CALLTOP"
	!byte 13,$07,$e6,$07,$d6,$b8,$50,13,255

; ----------------------------------------------------------------------------------
reloc
	sec                         ;
	ror $ff                     ; set top bit (set ESCAPE flag)

	lda #126                    ;
	jsr $fff4                   ; Acknowledge detection of ESCAPE condition

	ldy #0                      ;
	sty $b9                     ;
	tsx                         ;
	lda $100,X                  ;
	sta $ba                     ; Store current PAGE (value on stack) address in ($b9,$ba)

    ; relocate code from current PAGE to $0500 for 256 bytes
relocloop
	lda ($b9),Y                 ;
	sta start,Y                 ;
	iny                         ;
	bne relocloop               ;

    ; Y=0. Call "main" routine now it has been relocated
	jmp main                    ;

; ----------------------------------------------------------------------------------
main
	sei                         ; disable interrupts
!if elk=0 {
    ; BBC/Master

	; tape on
	lda #$85                    ;
	sta $fe10                   ;
	lda #$d5                    ;
	sta $fe08                   ;

	; screen off
	lda #8                      ;
	sta $fe00                   ;
	lda #$f0                    ;
	sta $fe01                   ;

	dey                         ; Y=255
} else {
    ; Electron

	; tape on
	sty $fe06                   ; Y=0
	lda #$f0                    ;
	sta $fe07                   ;

	; screen off
	dey                         ; Y=255
	sty $fe08                   ;
	sty $fe09                   ;
}

    ; load the first section (255 bytes) backwards into memory $4ff-$401
    ; this is loading the decompression code itself
load_initial
	jsr get_crunched_byte       ;
	sta $400,Y                  ;
	dey                         ;
	bne load_initial            ;

    ; now we have a decompression routine in memory, let's use it
	; we call the decompression code to load and decompress the next section from tape
	jsr decrunch                ;

	; now the initial sections have loaded, jump to the entry_point ('go' is defined on the command line to acme)
	; this will continue loading the remainder of the program from tape
	jmp go                      ;

; ----------------------------------------------------------------------------------
; waits for and reads the next byte from tape
; ----------------------------------------------------------------------------------
get_crunched_byte
	php                         ; remember flags
!if elk=0 {
    ; BBC/Master
    ; wait for byte from tape
retry
    lda $fe08                   ;
	lsr                         ;
	bcc retry                   ;

	; read byte
	lda $fe09                   ;
} else {
    ; Electron
    ; wait for byte from tape
	lda #$10                    ;
retry
	bit $fe00                   ;
	beq retry                   ;

	; read byte
	lda $fe04                   ;
}
	plp                         ; restore flags
	rts                         ;
end
