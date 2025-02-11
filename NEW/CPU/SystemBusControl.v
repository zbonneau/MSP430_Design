/*--------------------------------------------------------
    Module Name: System Bus Control
    Description:
        The System Bus Control module drives the MAB, MDBout, 
        and MCB (collectively the "System Bus") from the CPU
        perspective. This includes such activities as Instruction 
        Fetch, Address mode operand/offset fetchs, interrupt 
        vector fetches, and memory writes. IW(6) formats 
        instruction operands as Bytes (1) or Words (0).

    Inputs:
        IdxF - index offset fetch
        IF - instruction fetch
        Mem - indicates a memory operation
        Ex - indicates Memory Read (MR - 0) or Write (MW - 1)
        INTACK - Interrupt Acknowledge
        IW6 - Instruction Word bit 6 (B/W)

        PCnt - Program Counter
        Addr - Address for operand data or memory write back
        IntAddr - Interrupt Vector Address
        result - result of function unit for memory write back

    Outputs:
        MAB - Memory Address Bus
        MDBout - Memory Data Bus
        BW - Byte/Word
        MW - Memory Write Enable

--------------------------------------------------------*/

module SystemBusControl(
    input IdxF, IF, Mem, Ex, INTACK, IW6,
    input [15:0]  PCnt, Addr, IntAddr, result,

    output [15:0] MAB, MDBout,
    output        BW, MW
 );

    `include "NEW\\PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */
    assign MAB = (INTACK) ? IntAddr : // Fetch IVT
                 (IdxF | IF) ? PCnt : // Fetch Instruction / Index Offset
                 (BW)        ? Addr : // Read/Write operand data
                  {Addr[15:1], 1'b0}; // mask LSB for word-addressed data

    assign MW     = (~IdxF & ~IF & ~INTACK & Mem & Ex);
    assign MDBout = (~MW) ? 0 :          // No memory write
                    (BW) ? result[7:0] : // byte-wise memory write
                           result;       // word-wise memory write

    // assign BW based on IW6 ONLY when reading operand data
    assign BW  = (~IdxF & ~IF & ~INTACK & Mem & IW6);

endmodule
