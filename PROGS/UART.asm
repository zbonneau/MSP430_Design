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
    ; echo on UART A0 @ 9600 BAUD

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

    ; Configure TX on P2.0 as well for oscope view
            mov.b   #1, P2SEL0

    ; Configure eUSCIA0 for uart 9600 BAUD
            mov.w   #6,         UCA0BRW
            mov.w   #0x2081,    UCA0MCTLW
            mov.w   #0x0080,    UCA0CTLW0

Loop:
            ; Read Rx, Send on Tx
            bit.w   #UCRXIFG,   UCA0IFG
            jz      Loop
            mov.b   UCA0RXBUF,  UCA0TXBUF
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
