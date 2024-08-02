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
START
	RRC 	R4
	RRC 	@R5
	RRC 	@R6+
	RRC 	10(R7)

	RRC.b 	R4
	RRC.b 	@R5
	RRC.b 	@R6+
	RRC.b 	10(R7)

	swpb	R8
	swpb	@R9
	swpb	@R10+
	swpb	10(R11)

	rra		R12
	rra		@R13
	rra		@R14+
	rra		10(R15)

	rra.b	R12
	rra.b	@R13
	rra.b	@R14+
	rra.b	10(R15)

	sxt		R4
	sxt		@R6
	sxt		@R8+
	sxt		10(R8)

	push	R5
	push	@R6
	push	@R7+
	push	#10
	push	10(R11)

	push.b	R5
	push.b	@R6
	push.b	@R7+
	push.b	#10
	push.b	10(R11)

	call 	R4
	call	@R5
	call 	@R6+
	call	#10
	call 	10(R7)

	reti

	;; Conditional Jumps
THERE:
	jne		HERE
	jnz	 	HERE
	jeq		HERE
	jz		HERE
	jnc		HERE
	jc		HERE
	jn		THERE
	jge		THERE
	jl		THERE
	jmp		THERE
HERE:

	;; 2-Operand Instructions

	mov 	R4, 	    R7
	mov 	R5, 	    10(R8)
    mov 	@R6, 	    R9
    mov 	@R7, 	    10(R10)
    mov 	@R8+, 	    R11
    mov 	@R9+, 	    10(R12)
    mov 	#10, 	    R13
    mov 	10(R10),    R14
    mov 	10(R11),    10(R15)

	mov.b	R8, 	    R5
	mov.b 	R9, 	    10(R6)
    mov.b 	@R10, 	    R7
    mov.b 	@R11, 	    10(R8)
    mov.b 	@R12+, 	    R9 
    mov.b 	@R13+, 	    10(R10)
    mov.b 	#10, 	    R11
    mov.b 	10(R14),    R12
    mov.b 	10(R15),    10(R13)

    add 	R4, 	    R7
	add 	R5, 	    10(R8)
    add 	@R6, 	    R9
    add 	@R7, 	    10(R10)
    add 	@R8+, 	    R11
    add 	@R9+, 	    10(R12)
    add 	#10, 	    R13
    add 	10(R10),    R14
    add 	10(R11),    10(R15)

	add.b	R8, 	    R5
	add.b 	R9, 	    10(R6)
    add.b 	@R10, 	    R7
    add.b 	@R11, 	    10(R8)
    add.b 	@R12+, 	    R9 
    add.b 	@R13+, 	    10(R10)
    add.b 	#10, 	    R11
    add.b 	10(R14),    R12
    add.b 	10(R15),    10(R13)

	addc 	R4, 	    R7
	addc 	R5, 	    10(R8)
    addc 	@R6, 	    R9
    addc 	@R7, 	    10(R10)
    addc 	@R8+, 	    R11
    addc 	@R9+, 	    10(R12)
    addc 	#10, 	    R13
    addc 	10(R10),    R14
    addc 	10(R11),    10(R15)

	addc.b	R8, 	    R5
	addc.b 	R9, 	    10(R6)
    addc.b 	@R10, 	    R7
    addc.b 	@R11, 	    10(R8)
    addc.b 	@R12+, 	    R9 
    addc.b 	@R13+, 	    10(R10)
    addc.b 	#10, 	    R11
    addc.b 	10(R14),    R12
    addc.b 	10(R15),    10(R13)

	subc 	R4, 	    R7
	subc 	R5, 	    10(R8)
    subc 	@R6, 	    R9
    subc 	@R7, 	    10(R10)
    subc 	@R8+, 	    R11
    subc 	@R9+, 	    10(R12)
    subc 	#10, 	    R13
    subc 	10(R10),    R14
    subc 	10(R11),    10(R15)

	subc.b	R8, 	    R5
	subc.b 	R9, 	    10(R6)
    subc.b 	@R10, 	    R7
    subc.b 	@R11, 	    10(R8)
    subc.b 	@R12+, 	    R9 
    subc.b 	@R13+, 	    10(R10)
    subc.b 	#10, 	    R11
    subc.b 	10(R14),    R12
    subc.b 	10(R15),    10(R13)

	sub 	R4, 	    R7
	sub 	R5, 	    10(R8)
    sub 	@R6, 	    R9
    sub 	@R7, 	    10(R10)
    sub 	@R8+, 	    R11
    sub 	@R9+, 	    10(R12)
    sub 	#10, 	    R13
    sub 	10(R10),    R14
    sub 	10(R11),    10(R15)

	sub.b	R8, 	    R5
	sub.b 	R9, 	    10(R6)
    sub.b 	@R10, 	    R7
    sub.b 	@R11, 	    10(R8)
    sub.b 	@R12+, 	    R9 
    sub.b 	@R13+, 	    10(R10)
    sub.b 	#10, 	    R11
    sub.b 	10(R14),    R12
    sub.b 	10(R15),    10(R13)

	cmp 	R4, 	    R7
	cmp 	R5, 	    10(R8)
    cmp 	@R6, 	    R9
    cmp 	@R7, 	    10(R10)
    cmp 	@R8+, 	    R11
    cmp 	@R9+, 	    10(R12)
    cmp 	#10, 	    R13
    cmp 	10(R10),    R14
    cmp 	10(R11),    10(R15)

	cmp.b	R8, 	    R5
	cmp.b 	R9, 	    10(R6)
    cmp.b 	@R10, 	    R7
    cmp.b 	@R11, 	    10(R8)
    cmp.b 	@R12+, 	    R9 
    cmp.b 	@R13+, 	    10(R10)
    cmp.b 	#10, 	    R11
    cmp.b 	10(R14),    R12
    cmp.b 	10(R15),    10(R13)

	dadd 	R4, 	    R7
	dadd 	R5, 	    10(R8)
    dadd 	@R6, 	    R9
    dadd 	@R7, 	    10(R10)
    dadd 	@R8+, 	    R11
    dadd 	@R9+, 	    10(R12)
    dadd 	#10, 	    R13
    dadd 	10(R10),    R14
    dadd 	10(R11),    10(R15)

	dadd.b	R8, 	    R5
	dadd.b 	R9, 	    10(R6)
    dadd.b 	@R10, 	    R7
    dadd.b 	@R11, 	    10(R8)
    dadd.b 	@R12+, 	    R9 
    dadd.b 	@R13+, 	    10(R10)
    dadd.b 	#10, 	    R11
    dadd.b 	10(R14),    R12
    dadd.b 	10(R15),    10(R13)

	bit 	R4, 	    R7
	bit 	R5, 	    10(R8)
    bit 	@R6, 	    R9
    bit 	@R7, 	    10(R10)
    bit 	@R8+, 	    R11
    bit 	@R9+, 	    10(R12)
    bit 	#10, 	    R13
    bit 	10(R10),    R14
    bit 	10(R11),    10(R15)

	bit.b	R8, 	    R5
	bit.b 	R9, 	    10(R6)
    bit.b 	@R10, 	    R7
    bit.b 	@R11, 	    10(R8)
    bit.b 	@R12+, 	    R9 
    bit.b 	@R13+, 	    10(R10)
    bit.b 	#10, 	    R11
    bit.b 	10(R14),    R12
    bit.b 	10(R15),    10(R13)

	bic 	R4, 	    R7
	bic 	R5, 	    10(R8)
    bic 	@R6, 	    R9
    bic 	@R7, 	    10(R10)
    bic 	@R8+, 	    R11
    bic 	@R9+, 	    10(R12)
    bic 	#10, 	    R13
    bic 	10(R10),    R14
    bic 	10(R11),    10(R15)

	bic.b	R8, 	    R5
	bic.b 	R9, 	    10(R6)
    bic.b 	@R10, 	    R7
    bic.b 	@R11, 	    10(R8)
    bic.b 	@R12+, 	    R9 
    bic.b 	@R13+, 	    10(R10)
    bic.b 	#10, 	    R11
    bic.b 	10(R14),    R12
    bic.b 	10(R15),    10(R13)

	bis 	R4, 	    R7
	bis 	R5, 	    10(R8)
    bis 	@R6, 	    R9
    bis 	@R7, 	    10(R10)
    bis 	@R8+, 	    R11
    bis 	@R9+, 	    10(R12)
    bis 	#10, 	    R13
    bis 	10(R10),    R14
    bis 	10(R11),    10(R15)

	bis.b	R8, 	    R5
	bis.b 	R9, 	    10(R6)
    bis.b 	@R10, 	    R7
    bis.b 	@R11, 	    10(R8)
    bis.b 	@R12+, 	    R9 
    bis.b 	@R13+, 	    10(R10)
    bis.b 	#10, 	    R11
    bis.b 	10(R14),    R12
    bis.b 	10(R15),    10(R13)

	xor 	R4, 	    R7
	xor 	R5, 	    10(R8)
    xor 	@R6, 	    R9
    xor 	@R7, 	    10(R10)
    xor 	@R8+, 	    R11
    xor 	@R9+, 	    10(R12)
    xor 	#10, 	    R13
    xor 	10(R10),    R14
    xor 	10(R11),    10(R15)

	xor.b	R8, 	    R5
	xor.b 	R9, 	    10(R6)
    xor.b 	@R10, 	    R7
    xor.b 	@R11, 	    10(R8)
    xor.b 	@R12+, 	    R9 
    xor.b 	@R13+, 	    10(R10)
    xor.b 	#10, 	    R11
    xor.b 	10(R14),    R12
    xor.b 	10(R15),    10(R13)

	and 	R4, 	    R7
	and 	R5, 	    10(R8)
    and 	@R6, 	    R9
    and 	@R7, 	    10(R10)
    and 	@R8+, 	    R11
    and 	@R9+, 	    10(R12)
    and 	#10, 	    R13
    and 	10(R10),    R14
    and 	10(R11),    10(R15)

	and.b	R8, 	    R5
	and.b 	R9, 	    10(R6)
    and.b 	@R10, 	    R7
    and.b 	@R11, 	    10(R8)
    and.b 	@R12+, 	    R9 
    and.b 	@R13+, 	    10(R10)
    and.b 	#10, 	    R11
    and.b 	10(R14),    R12
    and.b 	10(R15),    10(R13)
END:

    .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
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
            
