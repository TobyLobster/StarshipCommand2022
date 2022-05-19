start
	!if start != $500 {
	!error
	}
basic
	!byte 13,$07,$e6,$07,$d6,$b8,$50,13,255
reloc
	sec
	ror $ff
	lda #126
	jsr $fff4
	ldy #0
	sty $b9
	tsx
	lda $100,X
	sta $ba
relocloop
	lda ($b9),Y
	sta start,Y
	iny
	bne relocloop
	jmp main
main
	sei
!if elk=0 {
	;; tape on
	lda #$85
	sta $fe10
	lda #$d5
	sta $fe08
	;; screen off
	lda #8
	sta $fe00
	lda #$f0
	sta $fe01
	dey
} else {
	;; tape on
	sty $fe06
	lda #$f0
	sta $fe07
	;; screen off
	dey
	sty $fe08
	sty $fe09
}
loadinitial
	jsr get_crunched_byte
	sta $400,Y
	dey
	bne loadinitial
	jsr decrunch
!if elk=0 {
	; tape off
 	lda #$45
	sta $fe10
}
	jmp go
get_crunched_byte
	php
!if elk=0 {
retry	lda $fe08
	lsr
	bcc retry
	lda $fe09
} else {
	lda #$10
retry	bit $fe00
	beq retry
	lda $fe04
}
	plp
	rts
end
