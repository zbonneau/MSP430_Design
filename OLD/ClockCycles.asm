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
	; P4.0 is MCLK, mode OUTPUT SEL = 11b

	mov.b #0xFF, &P4DIR
	mov.b #0xFF, &P4OUT
	mov.b #0x01, &P4SELC
	clr &PM5CTL0

	mov #4, R4
	mov #8000, R6
; 2 Operand Instructions
	; src <- Rn
	add r4, r5
	add r4, 2(R6)
	add r4, EDE
	add r4, &EDE
	add r4, PC
	nop
	nop
	nop
	nop

INDIRECT: ; src <- @Rn
	mov #IND, R4

	add @R4, r5
	add @R4, 4(R6)
	add @R4, EDE
	add @R4, &EDE
	add @R4, PC
	nop
	nop
	nop
	nop
	nop

INDIRECT_AUTOINCREMENT:
	add @R4+, r5
	add @R4+, 6(R6)
	add @R4+, EDE
	add @R4+, &EDE
	add @R4+, PC
	nop
	nop
	nop
	nop

IMMEDIATE:
	add #1000, r5
    add #1000, 8(R6)
	add #1000, EDE
	add #1000, &EDE
	add #4, PC
	nop
	nop
	nop
	nop

INDEXED:
	add 2(R4), R5
	add 4(R4), 10(R6)
	add 6(R4), EDE
	add 8(R4), &EDE
	add 10(R4), PC
	nop
	nop
	nop
	nop

; 1 Operand Generic
	mov #IND, R4
	rra R5
	rra @R4   ; 0: 5 -> 2
	rra @R4+  ; 0: 2 -> 1
	rra 2(R4) ; 2: 2 -> 1

; PUSH
	push R4
	push @R4
	push @R4+
	push #0x1234
	push 4(R4)

; CALL
	mov #subroutine, R4

	call r4

	mov #address, R4

	call @R4
	call @R4+
	call #subroutine
	call 2(R4)
	call address
	call &address

	jmp $
	nop
	nop



SRC:
	jmp INDIRECT

IND: .word 5, 1, 2, 3, 4, 4
address: .word subroutine, subroutine, subroutine



EDE: .word 0x0000


subroutine:
	RET
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
            
