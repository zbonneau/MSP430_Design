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
;
; BSL Interface Script
;   This Device sits between a PC and Target Device to trigger BSL entrance
;
;   UART A1 (P3.4, P3.5) - Backchannel COM port to PC BSL Scripter
;   UART A0 (P2.0, P2.1) - Application UART to Target Device
;   P1.0 - Interface LED 1 (RED). On When BSL Sequence Started
;   P9.7 - Interface LED 2 (GREEN). On When Target Device connected
;   P2.2 - Interface -> Target RESET
;   P2.3 - Interface -> Target TEST

UCAnIFG     .equ    0x1C
UCAnRXBUF   .equ    0x0C
UCAnTXBUF   .equ    0x0E
COLON       .equ    0x3A
CR          .equ    0x0D
LF          .equ    0x0A

RECORD_SUCCESS  .equ 0
RECORD_EOVER    .equ 1

RECORDTYPE_DATA         .equ 0x3030
RECORDTYPE_EOF          .equ 0x3031
RECORDTYPE_NOP          .equ 0x3032
RECORDTYPE_BSL_START    .equ 0x3033

INTERFACE_ACK       .equ 0x10
INTERFACE_NACK      .equ 0x11
ERROR_NO_TARGET     .equ 0x20
ERROR_TRIPLE_NACK   .equ 0x21

RECORD

HEXBUF      .struct
RXIDX       .byte       ; int  - string receive index
TXIDX       .byte       ; int  - string transmit index
START       .byte       ; bool - detected start (;)
PAD         .byte       ; byte padding
STR         .string 80  ; intel hex stream (ASCII coded HEX)
HEXBUF_LEN  .endstruct
STR_LEN		.equ 80

UCA1_Buf	.tag HEXBUF
    .data
    .bss    UCA1_Buf,   HEXBUF_LEN

    .text

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

    ; Configure UART A1 115200 BAUD 8-no-1
    mov.w   #8,         UCA1BRW
    mov.w   #0xD600,    UCA1MCTLW
    mov.w   #0x0080,    UCA1CTLW0

    mov.b   #0x30,      P3SEL0

    clr.w   &PM5CTL0

    ; Initialize UCA1_Buf
    clr.w   &UCA1_Buf.RXIDX
    clr.w   &UCA1_Buf.START

LOOP:
    ; Read A Record In
    call    #RxRecord
    cmp     #RECORD_SUCCESS, R15
    jne     Transmit_NACK

    ; Interface only responsible for record type (check for NOP/BSL_START)

    ; check record type. Exists at STR + 6,7
    mov.w   #RECORDTYPE_DATA,   R13
    mov.w   UCA1_Buf.STR+6,     R14

TYPE_CHECK    .macro label
        cmp.w   R13,    R14
        jeq     label 
        inc     R13
    .endm

    TYPE_CHECK LOOP_DATA
    TYPE_CHECK LOOP_EOF
    TYPE_CHECK LOOP_NOP
    TYPE_CHECK LOOP_BSL_START

Transmit_NACK:
    mov     #UCA1CTLW0, R14
    mov     #INTERFACE_NACK, R13
    call    #UART_write
    jmp     LOOP

LOOP_NOP:
Transmit_ACK:
    mov     #UCA1CTLW0, R14
    mov     #INTERFACE_ACK, R13
    call    #UART_write
    jmp     LOOP

LOOP_DATA:
    ; Immediately transmit Record to Target Device 
    call    #TxRecord
    jmp     Transmit_ACK

LOOP_EOF:
    ; Reset Target Device
    jmp     Transmit_ACK

LOOP_BSL_START:
    ; Reset Target Device in BSL Mode
    jmp     Transmit_ACK


;------------------------------------------------------------------------------
    .newblock
    .asg R14, UCA
    .asg R13, char
    .asg R12, len 

RxRecord:
    push    UCA
    push    char
    push    len

    ;   Wait for ;
    mov     #COLON, char
    mov     #UCA1CTLW0, UCA
$1:
    call    #UART_read
    cmp.b   char,    R15
    jne     $1

    ;   Read in Characters until /r or /n
    mov     #'0',   char
    clr     len
$2:
    call    #UART_read
    cmp     char,    R15
    jn      RxRecord_Success

    ; if ASCII Coded HEX, add to buffer
    cmp     #STR_LEN,   len ; if buffer overflow, return error
    jeq     RxRecord_ERROR_OVER

    mov.b   R15,    UCA1_Buf.STR(len)
    inc     len
    jmp     $2

RxRecord_ERROR_OVER:
    mov     #RECORD_EOVER,  R15
    jmp     RxRecord_Done

RxRecord_Success:
    mov     #RECORD_SUCCESS, R15
    mov.b   len,    UCA1_Buf.RXIDX

RxRecord_Done:
    pop     len
    pop     char
    pop     UCA
    ret
    .unasg UCA
    .unasg char
    .unasg len
;------------------------------------------------------------------------------
    .newblock
    .asg R14, UCA
    .asg R13, char
    .asg R12, idx
    .asg R11, len
TxRecord:
    push    UCA
    push    char
    push    idx
    push    len

    ; Tx (;) to start record
    mov     #UCA1CTLW0, UCA
    mov     #COLON, char
    call    #UART_write

    clr     idx
    mov.b   UCA1_Buf.RXIDX, len 

$1:
    cmp     idx, len 
    jeq     TxRecord_end
    mov.b   UCA1_Buf.STR(idx),  char
    call    #UART_write
    inc     idx
    jmp     $1

TxRecord_end:
    mov.b   idx, UCA1_Buf.TXIDX
    ; Tx (\r) to end record
    mov.b   #CR, R13
    call    #UART_write
    mov.b   #LF, R13
    call    #UART_write

TxRecord_Done:
    pop     len 
    pop     idx 
    pop     char
    pop     UCA
    ret
    .unasg UCA
    .unasg char
    .unasg idx
    .unasg len    
;------------------------------------------------------------------------------
    .newblock
    .asg R14, UCA
    .asg R15, retVal

UART_read:
    bit #UCRXIFG,   0x1C(UCA)
    jz  UART_read

    mov UCAnRXBUF(UCA), retVal
    ret
    .unasg UCA
    .unasg retVal
;------------------------------------------------------------------------------
    .newblock
    .asg R14, UCA
    .asg R13, char    
UART_write:
    bit     #UCTXIFG,   UCAnIFG(UCA)
    jz      UART_write

    mov.b   char,       UCAnTXBUF(UCA)
    ret
    .unasg UCA
    .unasg char
;------------------------------------------------------------------------------
; UCA1_ISR:
;     add    &UCA1IV, PC

;     reti

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

            ; .intvec ".int42",   UCA1_ISR
