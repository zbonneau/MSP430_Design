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

	RRC 	R4
	RRC 	@R5
	RRC 	@R6+
	RRC 	2(R7)

	RRC.b 	R4
	RRC.b 	@R5
	RRC.b 	@R6+
	RRC.b 	2(R7)

	swpb	R8
	swpb	@R9
	swpb	@R10+
	swpb	4(R11)

	rra		R12
	rra		@R13
	rra		@R14+
	rra		6(R15)

	rra.b	R12
	rra.b	@R13
	rra.b	@R14+
	rra.b	6(R15)

	sxt		R4
	sxt		@R6
	sxt		@R8+
	sxt		6(R8)

	push	R5
	push	@R6
	push	@R7+
	push	#122
	push	4(R11)

	push.b	R5
	push.b	@R6
	push.b	@R7+
	push.b	#122
	push.b	4(R11)

	call 	R4
	call	@R5
	call 	@R6+
	call	#0x4800
	call 	12(R7)

	reti

	;; Conditional Jumps

	jne		20
	jnz		30
	jeq		40
	jz		50
	jnc		60
	jc		70
	jn		-10
	jge		-20
	jl		-30
	jmp		-40


	;; 2-Operand Instructions

	mov 	R4, 	R5
	mov 	R5, 	10(R6)
    mov 	@R6, 	R7
    mov 	@R7, 	10(R8)
    mov 	@R8+, 	R9
    mov 	@R9+, 	R10
    mov 	#1234, 	R11
    mov 	10(R10), R12
    mov 	12(R11), R13

	mov.b	R4, 	R5
	mov.b 	R5, 	10(R6)
    mov.b 	@R6, 	R7
    mov.b 	@R7, 	10(R8)
    mov.b 	@R8+, 	R9
    mov.b 	@R9+, 	R10
    mov.b 	#1234, 	R11
    mov.b 	10(R10), R12
    mov.b 	12(R11), R13

    add 	R4, 	R5
	add 	R5, 	10(R6)
    add 	@R6, 	R7
    add 	@R7, 	10(R8)
    add 	@R8+, 	R9
    add 	@R9+, 	R10
    add 	#1234, 	R11
    add 	10(R10), R12
    add 	12(R11), R13

	add.b	R4, 	R5
	add.b 	R5, 	10(R6)
    add.b 	@R6, 	R7
    add.b 	@R7, 	10(R8)
    add.b 	@R8+, 	R9
    add.b 	@R9+, 	R10
    add.b 	#1234, 	R11
    add.b 	10(R10), R12
    add.b 	12(R11), R13

	addc 	R4, 	R5
	addc 	R5, 	10(R6)
    addc 	@R6, 	R7
    addc 	@R7, 	10(R8)
    addc 	@R8+, 	R9
    addc 	@R9+, 	R10
    addc 	#1234, 	R11
    addc 	10(R10), R12
    addc 	12(R11), R13

	addc.b	R4, 	R5
	addc.b 	R5, 	10(R6)
    addc.b 	@R6, 	R7
    addc.b 	@R7, 	10(R8)
    addc.b 	@R8+, 	R9
    addc.b 	@R9+, 	R10
    addc.b 	#1234, 	R11
    addc.b 	10(R10), R12
    addc.b 	12(R11), R13

	subc 	R4, 	R5
	subc 	R5, 	10(R6)
    subc 	@R6, 	R7
    subc 	@R7, 	10(R8)
    subc 	@R8+, 	R9
    subc 	@R9+, 	R10
    subc 	#1234, 	R11
    subc 	10(R10), R12
    subc 	12(R11), R13

	subc.b	R4, 	R5
	subc.b 	R5, 	10(R6)
    subc.b 	@R6, 	R7
    subc.b 	@R7, 	10(R8)
    subc.b 	@R8+, 	R9
    subc.b 	@R9+, 	R10
    subc.b 	#1234, 	R11
    subc.b 	10(R10), R12
    subc.b 	12(R11), R13

	sub 	R4, 	R5
	sub 	R5, 	10(R6)
    sub 	@R6, 	R7
    sub 	@R7, 	10(R8)
    sub 	@R8+, 	R9
    sub 	@R9+, 	R10
    sub 	#1234, 	R11
    sub 	10(R10), R12
    sub 	12(R11), R13

	sub.b	R4, 	R5
	sub.b 	R5, 	10(R6)
    sub.b 	@R6, 	R7
    sub.b 	@R7, 	10(R8)
    sub.b 	@R8+, 	R9
    sub.b 	@R9+, 	R10
    sub.b 	#1234, 	R11
    sub.b 	10(R10), R12
    sub.b 	12(R11), R13

	cmp 	R4, 	R5
	cmp 	R5, 	10(R6)
    cmp 	@R6, 	R7
    cmp 	@R7, 	10(R8)
    cmp 	@R8+, 	R9
    cmp 	@R9+, 	R10
    cmp 	#1234, 	R11
    cmp 	10(R10), R12
    cmp 	12(R11), R13

	cmp.b	R4, 	R5
	cmp.b 	R5, 	10(R6)
    cmp.b 	@R6, 	R7
    cmp.b 	@R7, 	10(R8)
    cmp.b 	@R8+, 	R9
    cmp.b 	@R9+, 	R10
    cmp.b 	#1234, 	R11
    cmp.b 	10(R10), R12
    cmp.b 	12(R11), R13

	dadd 	R4, 	R5
	dadd 	R5, 	10(R6)
    dadd 	@R6, 	R7
    dadd 	@R7, 	10(R8)
    dadd 	@R8+, 	R9
    dadd 	@R9+, 	R10
    dadd 	#1234, 	R11
    dadd 	10(R10), R12
    dadd 	12(R11), R13

	dadd.b	R4, 	R5
	dadd.b 	R5, 	10(R6)
    dadd.b 	@R6, 	R7
    dadd.b 	@R7, 	10(R8)
    dadd.b 	@R8+, 	R9
    dadd.b 	@R9+, 	R10
    dadd.b 	#1234, 	R11
    dadd.b 	10(R10), R12
    dadd.b 	12(R11), R13

	bit 	R4, 	R5
	bit 	R5, 	10(R6)
    bit 	@R6, 	R7
    bit 	@R7, 	10(R8)
    bit 	@R8+, 	R9
    bit 	@R9+, 	R10
    bit 	#1234, 	R11
    bit 	10(R10), R12
    bit 	12(R11), R13

	bit.b	R4, 	R5
	bit.b 	R5, 	10(R6)
    bit.b 	@R6, 	R7
    bit.b 	@R7, 	10(R8)
    bit.b 	@R8+, 	R9
    bit.b 	@R9+, 	R10
    bit.b 	#1234, 	R11
    bit.b 	10(R10), R12
    bit.b 	12(R11), R13

	bic 	R4, 	R5
	bic 	R5, 	10(R6)
    bic 	@R6, 	R7
    bic 	@R7, 	10(R8)
    bic 	@R8+, 	R9
    bic 	@R9+, 	R10
    bic 	#1234, 	R11
    bic 	10(R10), R12
    bic 	12(R11), R13

	bic.b	R4, 	R5
	bic.b 	R5, 	10(R6)
    bic.b 	@R6, 	R7
    bic.b 	@R7, 	10(R8)
    bic.b 	@R8+, 	R9
    bic.b 	@R9+, 	R10
    bic.b 	#1234, 	R11
    bic.b 	10(R10), R12
    bic.b 	12(R11), R13

	bis 	R4, 	R5
	bis 	R5, 	10(R6)
    bis 	@R6, 	R7
    bis 	@R7, 	10(R8)
    bis 	@R8+, 	R9
    bis 	@R9+, 	R10
    bis 	#1234, 	R11
    bis 	10(R10), R12
    bis 	12(R11), R13

	bis.b	R4, 	R5
	bis.b 	R5, 	10(R6)
    bis.b 	@R6, 	R7
    bis.b 	@R7, 	10(R8)
    bis.b 	@R8+, 	R9
    bis.b 	@R9+, 	R10
    bis.b 	#1234, 	R11
    bis.b 	10(R10), R12
    bis.b 	12(R11), R13

	xor 	R4, 	R5
	xor 	R5, 	10(R6)
    xor 	@R6, 	R7
    xor 	@R7, 	10(R8)
    xor 	@R8+, 	R9
    xor 	@R9+, 	R10
    xor 	#1234, 	R11
    xor 	10(R10), R12
    xor 	12(R11), R13

	xor.b	R4, 	R5
	xor.b 	R5, 	10(R6)
    xor.b 	@R6, 	R7
    xor.b 	@R7, 	10(R8)
    xor.b 	@R8+, 	R9
    xor.b 	@R9+, 	R10
    xor.b 	#1234, 	R11
    xor.b 	10(R10), R12
    xor.b 	12(R11), R13

	and 	R4, 	R5
	and 	R5, 	10(R6)
    and 	@R6, 	R7
    and 	@R7, 	10(R8)
    and 	@R8+, 	R9
    and 	@R9+, 	R10
    and 	#1234, 	R11
    and 	10(R10), R12
    and 	12(R11), R13

	and.b	R4, 	R5
	and.b 	R5, 	10(R6)
    and.b 	@R6, 	R7
    and.b 	@R7, 	10(R8)
    and.b 	@R8+, 	R9
    and.b 	@R9+, 	R10
    and.b 	#1234, 	R11
    and.b 	10(R10), R12
    and.b 	12(R11), R13
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
            
