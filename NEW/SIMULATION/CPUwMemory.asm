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
StopWDT     ;mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

;			mov.w 	#0x1234, R4
;			add.w	#0x0008, R4
;			mov.b	R4,		 R5


;			mov.w 	var1,  	R6
;			mov.w	#var1, 	R7

;			sub.w	@R7+,  	R8
;			add		@R7, 	var1+2
;			push.w	R4
;			push.b	R4

;			mov.w 	#5, R9
;L1:			dec 	R9
;			jnz		L1

;			mov.w	#0x20, R10
;L2:			RRC		R10
;			jnc		L2

;end:		jmp 	end
;			nop

			nop
			eint
			nop

			mov 	#13, 	R4
			mov 	#20, 	R5

			push.w	R4
			push.b	R5

			call	#func1

			dec		R4
			dec 	R5

			pop.b	R7
			pop		R8

			nop
end:		jmp end




var1 .word	0xa5a5, 0x2244

func1:
			mov 	R5,		R6
			add 	R4,		R6
			ret

ISR44:
			mov		#30,	R6
			xor.b	#0xaa,	var1+1
			reti

                                            

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
            
            .intvec ".int37", ISR44

