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

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------
; Bootstrap Loader Initialization Code
;-------------------------------

; Configure UART A0, 115200 BAUD, 8-no-1, P2.0 P2.1
    mov.w       #8,         UCA0BRW
    mov.w       #0xD600,    UCA0MCTLW
    mov.w       #0x0080,    UCA0CTLW0

    mov.b       #0x03,      P2SEL0

; while (1)
;   read for ';'
;   
;   while (1)
;       read frame
;       if frame == '\r' or '\n'
;           break
;       nibble = decode frame
;
;       read frame
;       nibble = decode frame
;       byte = nibble | nibble
;       M[buffer++] = byte
;   Check CRC
;       NACK if failed
;   Check Record type
;       ACK if EOF
;   Copy Data
;   Send ACK
;
.equ    BUFSTART  = 0x1c00
.equ    LEN_OFS   = 0
.equ    ADDRH_OFS = 1
.equ    ADDRL_OFS = 2
.equ    REC_OFS   = 3
.equ    DATA_OFS  = 4

.equ    buffer  = R4 
.equ    CRC     = R5
.equ    pADDR    = R6
.equ    LEN     = R7
.equ    pDATA   = R8

.equ    RECORD_DATA = 0
.equ    RECORD_EOF  = 1

.equ    ACK  = 0x10
.equ    NACK = 0x11

LOOP:
    clr     buffer
    clr     CRC

WAIT:
    call    #UART_read
    cmp     #(0x3A),    R15
    jne     WAIT

readRecord:
    call    #UART_read              ; 16-22

    cmp     #('\r'),    R15         ; 2
    jeq     endRecord               ; 2  
    cmp     #('\n'),    R15         ; 2
    jeq     endRecord               ; 2

    sub     #'0',       R15         ; 1
    cmp     #10,        R15         ; 2
    jl      readRecord2             ; 2
    sub     #7,         R15         ; 2
    mov     R15,        R14         ; 1
    rla     R14                     ; 1
    rla     R14                     ; 1
    rla     R14                     ; 1
    rla     R14                     ; 1 - total = 36-42

readRecord2:
    call    #UART_read              ; 16-22

    sub     #'0',       R15         ; 1
    cmp     #10,        R15         ; 2
    jl      putByte                 ; 2
    sub     #7,         R15         ; 2

putByte:
    bis     R14,        R15         ; 1
    mov.b   R15,        BUFSTART(buffer) ; 4
    add.b   R15,        CRC
    inc     buffer                  ; 1
    jmp     readRecord              ; 2 - total = 31-37

endRecord:

; Check CRC
    tst.b   CRC
    jeq     CRC_Passed

    ; if CRC Failed, send NACK, repeat
    mov.b   #NACK,      UCA0TXBUF
    jmp     Loop

CRC_Passed:

; Check record type
    cmp.b   #RECORD_EOF,    BUFSTART+REC_OFS
    jne     BSL_DATA

    ; EOF detected, send ACK
    mov.b   #ACK,       UCA0TXBUF
    jmp     LOOP

BSL_DATA:

; Extract Address from buffer
    mov.b   BUFSTART+ADDRH_OFS,     pADDR
    swpb    ADDR
    mov.b   BUFSTART+ADDRL_OFS,     pADDR

; Copy Data buffer to Memory @ ADDR
    mov.b   BUFSTART+LEN_OFS,       LEN
    mov     #BUFSTART+DATA_OFS,     pDATA

COPY:
    mov.b   @pDATA+,    0(pADDR)
    inc     pADDR
    dec     LEN
    jne     COPY

; Send ACK, repeat
    mov.b   #ACK,   UCA0TXBUF
    jmp     LOOP
    nop

UART_read:                          ; Call # = 4
    bit.w   #UCRXIFG,   UCA0IFG     ; 4
    jz      UART_read               ; 2
    mov.b`  UCA0RXBUF,  R15         ; 3
    mov.b   UCA0RXBUF,  UCA0TXBUF           ;DEBUG
    ret                             ; 3
    nop                             ; total = 16 - 22

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
