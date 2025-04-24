/*--------------------------------------------------------
    Module Name: Car Latch Control
    Description:
        The CAR Latch Control module decides the order of 
        microsequences (uSeq) during special cases.

    Inputs:
        rst - reset pin from interrupt unit. Always highest priority
        INTREQ - NMI or MI request from interrupt unit
        Instruction Fetch - Prefetch signal from Control Unit
        Br - Branch Detection when dstA = PC with RW
        CARnew - CAR from Decoder for new instruction
        CARold - CAR value from current uSeq. CAR+1 arithmetic implemented 
                 internally

    Outputs:
        CARnext - Next CAR index in uSeq

--------------------------------------------------------*/
`timescale 100ns/100ns

module CarLatchControl(
    input rst, blank, INTREQ, IF, Br, INTACK,
    input [CAR_BITS-1:0]  CARnew, CARold,
    output [CAR_BITS-1:0] CARnext
 );

    `include "NEW/PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */
    assign CARnext = (rst) ? CAR_INT4  : // Interrupt sequence w/out PUSHes
                   (blank) ? CAR_BLANK : // Blank Device Detected.
                  (INTACK) ? CAR_0     : // INTACK Transmitted.
        (INTREQ & (IF|Br)) ? CAR_INT0  : // Interrupt sequence w/ PUSHes
                     (Br)  ? CAR_0     : // PC WB occured @ end of uSeq 
                     (IF)  ? CARnew    : // PC valid & CAR Decoder produces next uSeq
                             CARold +1 ; // No special case, default behavior
endmodule
