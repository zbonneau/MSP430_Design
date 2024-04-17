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
	subc.b #0x00FF, R4 ; MAXPOS - NEG + 1 + Cin = NEG
	setc
	subc.b #0x0081, R5 ; MAXPOS - 8001h + 1 + Cin = 0
	setc
	subc.b #0x007f, R6 ; MAXNEG - MAXPOS + 2 = POS

	clr SR
	mov #0x7fff, R4
	mov #0x7fff, R5
	mov #0x8000, R6
	mov #0x8000, R7

	sub #0x0020, R4 ; Cout
	sub #0x8000, R5 ; pos - neg = neg
	sub #0x7fff, R6 ; Neg - Pos = Pos
	sub #0x8000, R7 ; zero'

	clr SR
	mov #0x7f, R4
	mov #0x7f, R5
	mov #0x80, R6
	mov #0x80, R7

	sub.b #0x20, R4 ; Cout
	sub.b #0x80, R5 ; pos - neg = neg
	sub.b #0x7f, R6 ; Neg - Pos = Pos
	sub.b #0x80, R7 ; zero'

	clr SR
	mov #0x7fff, R4
	mov #0x7fff, R5
	mov #0x8000, R6
	mov #0x8000, R7

	cmp #0x0020, R4 ; Cout
	cmp #0x8000, R5 ; pos - neg = neg
	cmp #0x7fff, R6 ; Neg - Pos = Pos
	cmp #0x8000, R7 ; zero'

	clr SR
	mov #0x7f, R4
	mov #0x7f, R5
	mov #0x80, R6
	mov #0x80, R7

	cmp.b #0x20, R4 ; Cout
	cmp.b #0x80, R5 ; pos - neg = neg
	cmp.b #0x7f, R6 ; Neg - Pos = Pos
	cmp.b #0x80, R7 ; zero'

	clr SR
	mov #0x1234, R4
	mov #0x9999, R5
	mov #0x6678, R6
	mov #0x9999, R7

	dadd #0x4567, R4 ; No carry, N, or Z
	dadd #0x0001, R5 ; Carry, Zero
	dadd #0x3210, R6 ; Cin, Nout, no Cout
	dadd #0x9999, R7 ; Cout

	clr SR
	mov #0x12, R4
	mov #0x99, R5
	mov #0x56, R6
	mov #0x99, R7

	dadd.b #0x45, R4 ; No carry, N, or Z
	dadd.b #0x01, R5 ; Carry, Zero
	dadd.b #0x42, R6 ; Cin, Nout, no Cout
	dadd.b #0x99, R7 ; Cout

	clr SR
	mov #0xFFFF, R4
	mov #0x1111, R5
	mov #0x1111, R6
	mov #0x0000, R7

	and #0x8765, R4 ; 0xffff and X = X, N, Cout
	and #0x1234, R5 ; = 0x1010, No N, Cout
	and #0x2468, R6 ; = 0, No N, No C, Z
	and #0xFFFF, R7 ; 0x0000 and X = 0, Z

	clr SR
	mov #0xFF, R4
	mov #0x11, R5
	mov #0x11, R6
	mov #0x00, R7

	and.b #0x87, R4 ; 0xffff and X = X, N, Cout
	and.b #0x12, R5 ; = 0x1010, No N, Cout
	and.b #0x24, R6 ; = 0, No N, No C, Z
	and.b #0xFF, R7 ; 0x0000 and X = 0, Z

	clr SR
	mov #0xFFFF, R4
	mov #0x1234, R5
	mov #0x1111, R6

	bic #0x1234, R4
	bic #0x2345, R5
	bic #0x1111, R6

	clr SR
	mov #0xFF, R4
	mov #0x12, R5
	mov #0x11, R6

	bic.b #0x34, R4
	bic.b #0x45, R5
	bic.b #0x11, R6

	clr SR
	mov #0xFFFF, R4
	mov #0x1111, R5
	mov #0x1111, R6
	mov #0x0000, R7

	bis #0x1234, R4
	bis #0x2345, R5
	bis #0x1111, R6
	bis #0xA5A5, R7

	clr SR
	mov #0xFF, R4
	mov #0x11, R5
	mov #0x11, R6
	mov #0x00, R7

	bis.b #0x12, R4
	bis.b #0x23, R5
	bis.b #0x11, R6
	bis.b #0xA5, R7

	clr SR
	mov #0xFFFF, R4
	mov #0xA5A5, R5
	mov #0x1234, R6
	mov #0xFFFF, R7

	xor #0x1234, R4 ; C, N
	xor #0x5AA5, R5 ; C, N
	xor #0x1234, R6 ; Z
	xor #0x8000, R7 ; C, V

	clr SR
	mov #0xFF, R4
	mov #0xA5, R5
	mov #0x12, R6
	mov #0xFF, R7

	xor.b #0x12, R4 ; C, N
	xor.b #0x55, R5 ; C, N
	xor.b #0x12, R6 ; Z
	xor.b #0x80, R7 ; C, V

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
            
