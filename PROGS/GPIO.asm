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

;-------------------------------
; Macros Here
;-------------------------------

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer

            mov.b #0xFF, P1DIR
            mov.b #0x00, P1OUT

            mov.b #0xFF, P4DIR
            mov.b #BIT2, P4OUT

            jmp $1
            nop

            ; Every 1 s, cycle LED 1
prd .equ 62500/2
            mov.w #(TASSEL__SMCLK | ID__8), TA0CTL
            mov.w #2, TA0EX0
            mov.w #prd, &TA0CCR0
            mov.w #CCIE, &TA0CCTL0
            bis.w #TACLR, TA0CTL
            bis.w #MC__UP, TA0CTL


loop:   jmp loop
        nop
    

TA0CCR0_ISR:
    xor.b   #BIT0, P1OUT
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
            
            .intvec ".int44", TA0CCR0_ISR
