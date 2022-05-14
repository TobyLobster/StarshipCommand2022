* = $180
oscli = $fff7
osbyte = $fff4

	cli
	lda #0
	tax
	inx
	jsr osbyte
	cpx #0
	beq electron
	ldy #end1-command
        !byte $2c
electron
        ldy #end2-command
        lda #13
        sta command,Y
        ldx #<command
        ldy #>command
        jmp oscli
command
	!text "/STAR"
end1	!text "ELK"
end2
