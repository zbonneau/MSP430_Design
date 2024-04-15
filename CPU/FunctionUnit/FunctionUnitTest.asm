;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

	clr SR
	mov #0xA5A5, R4
	mov #0xA5A5, R5
	clr R6
	clr R7
	rrc R4 ; No  Cin, yes Cout, No  N,  No Z
	rrc R5 ; Yes Cin, yes Cout, yes N,  no Z
	rrc R6 ; Yes Cin, no  Cout, Yes N,  no Z
	rrc R7 ; No  Cin, no  Cout, No  N, yes Z

	clr SR
	mov #0xA5, R4
	mov #0xA5, R4
	clr R6
	clr R7
	rrc.b R4 ; No  Cin, yes Cout, No  N,  No Z
	rrc.b R5 ; Yes Cin, yes Cout, yes N,  no Z
	rrc.b R6 ; Yes Cin, no  Cout, Yes N,  no Z
	rrc.b R7 ; No  Cin, no  Cout, No  N, yes Z

	clr SR
	mov #0x1234, R4
	mov #0x2332, R5
	mov #0x0011, R6
	mov #0x2200, R7
	swpb R4
	swpb R5
	swpb R6
	swpb R7

	clr SR
	mov #0x5A5A, R4 ; No  Cout, No  N, No  Z
	mov #0xA5A5, R5	; Yes Cout, yes N, No  Z
	mov #0x0000, R6 ; No  Cout, no  N, Yes Z
	mov #0x0001, R7	; Yes Cout, no	N, yes Z
	rra R4
	rra R5
	rra R6
	rra R7

	clr SR
	mov #0x5A, R4 ; No  Cout, No  N, No  Z
	mov #0xA5, R5 ; Yes Cout, yes N, No  Z
	mov #0x00, R6 ; No  Cout, no  N, Yes Z
	mov #0x01, R7 ; Yes Cout, no  N, yes Z
	rra.b R4
	rra.b R5
	rra.b R6
	rra.b R7

	clr SR
	mov #0x007f, R4 ; Yes Cout, No  N, No  Z
	mov #0x0080, R5 ; Yes Cout, Yes N, No  Z
	mov #0x00FF, R6 ; Yes Cout, Yes N, No  Z
	mov #0x0000, R6 ; No  Cout, No  N, Yes Z
	sxt R4
	sxt R5
	sxt R6
	sxt R7

	clr SR
	mov #0x1234, R4 ; SR = 0000
	setc
	mov #0x5678, R5 ; SR = 0001
	setn
	mov #0x0000, R6 ; SR = 0101
	setz
	mov #0xFFFF, R7 ; SR = 0111

	clr SR
	mov #0x7fff, R4
	mov #0x7fff, R5
	mov #0x8000, R6
	mov #0x8000, R7

	add #0x0001, R4 ; MAXPOS + 1 = MAXNEG
	add #0x7fff, R5 ; MAXPOS + MAXPOS = -2
	add #0x8000, R6 ; MAXNEG + MAXNEG = 0
	add #0xFFFF, R7 ; MAXNEG + -1 = MAXPOS

	clr SR
	mov #0x007f, R4
	mov #0x007f, R5
	mov #0x0080, R6
	mov #0x0080, R7

	add.b #0x0001, R4 ; MAXPOS + 1 = MAXNEG
	add.b #0x007f, R5 ; MAXPOS + MAXPOS = -2
	add.b #0x0080, R6 ; MAXNEG + MAXNEG = 0
	add.b #0x00FF, R7 ; MAXNEG + -1 = MAXPOS

	clr SR
	mov #0x7fff, R4
	mov #0x8000, R5
	mov #0x8000, R6
	mov #0x8000, R7

	setc
	addc #0x0001, R4 ; MAXPOS + 1 + 1 = MAXNEG + 1
	setc
	addc #0x8000, R5 ; MAXNEG + MAXNEG + 1 = 1
	setc
	addc #0x7fff, R6 ; MAXNEG + MAXPOS + 1 = 0
	setc
	addc #0xFFFF, R7 ; MAXNEG + -1 + 1 = MAXNEG

	clr SR
	mov #0x007f, R4
	mov #0x0080, R5
	mov #0x0080, R6
	mov #0x0080, R7
	setc
	addc.b #0x0001, R4 ; MAXPOS + 1 + 1 = MAXNEG + 1
	setc
	addc.b #0x0080, R5 ; MAXNEG + MAXNEG + 1 = 1
	setc
	addc.b #0x007f, R6 ; MAXNEG + MAXPOS + 1 = 0
	setc
	addc.b #0x00FF, R7 ; MAXNEG + -1 + 1 = MAXNEG

	clr SR
	mov #0x7fff, R4
	mov #0x7fff, R5
	mov #0x8000, R6
	setc
	subc #0xFFFF, R4 ; MAXPOS - NEG + 1 + Cin = NEG
	setc
	subc #0x8001, R5 ; MAXPOS - 8001h + 1 + Cin = 0
	setc
	subc #0x7fff, R6 ; MAXNEG - MAXPOS + 2 = POS


	clr SR
	mov #0x007f, R4
	mov #0x007f, R5
	mov #0x0080, R6
	setc
	subc #0x00FF, R4 ; MAXPOS - NEG + 1 + Cin = NEG
	setc
	subc #0x0081, R5 ; MAXPOS - 8001h + 1 + Cin = 0
	setc
	subc #0x007f, R6 ; MAXNEG - MAXPOS + 2 = POS

	clr SR

	nop
	nop
	nop
                                            

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
