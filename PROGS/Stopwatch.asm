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
;   Drive a 4x7 segment display on P2 + P3 to make a minute:second stopwatch
;   
;
;

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

    ; Configure IO
    mov.b   #0xFF,      P2DIR
    mov.b   #0x00,      P2OUT
    mov.b   #0x8F,      P3DIR
    mov.b   #0x8F,      P3OUT

    clr		PM5CTL0

    ; Configure Timer TA0 - 1 second
    mov     #0x02C0,    TA0CTL
    mov     #0x0001,    TA0EX0
    mov     #62499,     TA0CCR0
    mov     #0x0010,    TA0CCTL0
    bis     #0x0010,    TA0CTL

    ; Configure Timer TA1 - 200 Hz
    mov     #0x0200,    TA1CTL
    mov     #4999,      TA1CCR0
    mov     #0x0010,    TA1CCTL0
    bis     #0x0010,    TA1CTL

    ; Configure GPRs
Digit   .equ R4
SEC     .equ R5
MIN     .equ R6

    mov     #0x0010,    Digit
    clr     SEC
    clr     MIN

    nop
    eint
    nop

wait: jmp wait

;------------------------------------------------------------------------------
TA0_ISR:
	clrc
    dadd    #1,     SEC
    cmp     #0x60,  SEC
    jne     TA0_ISR_end
    clr     SEC

	clrc
    dadd    #1,     MIN
    cmp     #0x60,  MIN
    jne     TA0_ISR_end
    clr     MIN

TA0_ISR_end:
    reti

;------------------------------------------------------------------------------
TA1_ISR:
    bis.b   #0x0F, P3OUT
    rra     Digit
    jnz     TA1_DISPLAY
    mov     #0x08, Digit

TA1_DISPLAY:
    mov     SEC,    R15
    cmp     #0x04,  Digit
    jeq     DIG_ROLL
    jhs     TA1_ISR_end

    mov     MIN,    R15
NOT_DIG3:
    cmp     #0x02,  Digit
    jeq     TA1_ISR_end

DIG_ROLL:
    rra     R15
    rra     R15
    rra     R15
    rra     R15

TA1_ISR_end:
    and     #0x0F,  R15
    mov.b   sseg(R15),  P2OUT
    bic.b   Digit,  P3OUT
    reti

sseg:
    .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

	nop
	nop
	.word 0

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

            .intvec ".int44", TA0_ISR
            .intvec ".int39", TA1_ISR
