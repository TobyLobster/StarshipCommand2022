stack1 = $500 ;main stack
stack2 = $501 ;decrunch stack

!if elk=0 {
    gcb_loc=$54b
} else {
    gcb_loc=$545
}
!pseudopc gcb_loc {
decrunch = $41e
INITSTACK = $c0
loader_start
get_crunched_byte
	php
	tya
	pha
	txa
	pha
	bit first
	bmi notfirst
	sec
	ror first
	tsx
	stx stack2
	ldx stack1
	txs
	cli
	rts 			; to main
notfirst
	tsx
	stx stack2
	ldx stack1
	txs
	pla
	tay
	pla
	tax
	lda $fc
	rti
loader_end
}

partno
	!byte 2 ; total number of parts minus one
irqdecr_init
	sei
	lda $0204
	sta oldirq+1
	lda $0205
	sta oldirq+2
	lda #<get_crunched_byte_irq
	sta $204
	lda #>get_crunched_byte_irq
	sta $205
	tsx
	stx stack1
	ldx #INITSTACK
	txs
!if elk=0 {
	ldx #0
	stx $278 ; ACIA mask
} else {
	ldy #$1c
	jsr $faf3 ; set ULA interrupt mask
}
-
	jsr decrunch
	dec partno
	bne -
loading_done
!if elk=0 {
	lda #$56
	sta $fe08
	lda $fe08
	lda #$45
	sta $fe10 	; tape off
}
	sei
	lda oldirq+1
	sta $0204
	lda oldirq+2
	sta $0205
	cli
	jmp notfirst

get_crunched_byte_irq
!if elk=0 {
	lda $fe08
	lsr
	bcs +
} else {
	lda #$10
	bit $fe00
	bne +
}
oldirq
	jmp $ffff
+
	txa
	pha
	tya
	pha
	dec timer
	bne +
	lda #120
	sta timer
;	jsr tick_cb
	dec timeleft+3
	bpl +
	lda #9
	sta timeleft+3
	dec timeleft+2
	bpl +
	lda #5
	sta timeleft+2
	dec timeleft
+
	tsx
	stx stack1
	ldx stack2
	txs
	pla
	tax
	pla
	tay
!if elk=0 {
 	lda $fe09
} else {
	lda $fe04
}
	plp
	rts	; to decrunch
first	!byte 0

timeleft
	!byte 1,':'-'0',3,0
;tick_cb
;	rts
timer
	!byte 120
