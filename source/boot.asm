oscli   = $fff7
osbyte  = $fff4

* = $180

entry_point
	cli                         ; Enable interrupts (since normally disabled on a *RUN !BOOT)
	lda #0                      ;
	ldx #1                      ;
	jsr osbyte                  ; Check the machine type
	cpx #0                      ;
	beq electron                ; if (we on an Electron) then branch

	ldy #end1-command           ; BBC version executes "/STAR", Y=length
    !byte $2c                   ; 'BIT abs' to skip the next instruction
electron
    ldy #end2-command           ; Electron version executes "/STARELK", Y=length
    lda #13                     ;
    sta command,Y               ; Write terminating character 13 at end of filename

    ldx #<command               ; Execute the command to *RUN the appropriate binary
    ldy #>command               ;
    jmp oscli                   ;

command
	!text "/STAR"               ;
end1
	!text "ELK"                 ;
end2
