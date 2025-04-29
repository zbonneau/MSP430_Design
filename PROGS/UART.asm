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
    ; echo on UART A1 @ 9600 BAUD

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

    ; Enable Application Backchannel on P3.4, P3.5
            mov.b   #0x30,      P3SEL0

    ; Configure eUSCIA1 for uart 9600 BAUD
            mov.w   #6,         UCA1BRW
            mov.w   #0x2081,    UCA1MCTLW
            mov.w   #0x0080,    UCA1CTLW0

Loop:
            ; Read Rx, Send on Tx
            bit.w   #UCRXIFG,   UCA1IFG
            jz      Loop
            mov.b   UCA1RXBUF,  UCA1TXBUF
            jmp Loop
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
