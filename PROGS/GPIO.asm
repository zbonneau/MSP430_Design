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
    ; write some values to P2 in infinite loop
    ; Configure P1.1, P1.2 as interrupts on falling edge
    ; On P1.1, P2 <- 0xa5
    ; On P1.2, P2 <- 0x5a
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

    mov.w   #0xFFF9,    PADIR
    mov.w   #0x0006,    R15
    mov.w   R15,        PAREN
    mov.w   R15,        PAOUT
    mov.w   R15,        PAIE
    mov.w   R15,        PAIES

    clr.w               PM5CTL0
    clr.w               PAIFG

    clr     R4
    mov     #1,         R5

    nop
    eint
    nop

loop:
    mov.b   sseg(R4),   P2OUT
    add     R5,         R4
    and     #0x000F,    R4
    call    #delay
    jmp     loop
    nop

sseg:   ; 0     1     2     3     4     5     6     7      
    .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07 
        ; 8     9     A     B     C     D     E     F
    .byte 0x7F, 0x6F,  0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

delay:
    mov     #5,         R14
d1:
    mov     #0xFFFF,    R15
d2:
    dec     R15
    jnz     d2
    dec     R14
    jnz     d1
    ret

P1_ISR:
    add     P1IV,       PC
    reti    ; none
    reti    ; p1.0
    jmp     P1_1_ISR
    jmp     P1_2_ISR
    reti
    reti
    reti
    reti
    reti

P1_1_ISR: ; Reset Counter
    clr     R4
    reti

P1_2_ISR: ; Flip counting direction
    xor     #0xFFFF,    R5
    inc     R5
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
            
            .intvec ".int37", P1_ISR
