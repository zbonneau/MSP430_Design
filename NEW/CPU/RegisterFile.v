/*--------------------------------------------------------
    Module Name: Register File
    Description:
        The register file contains 16x16-bit orthoganal 
        registers (R0-R15). 4 Registers (R0-R4) are SFRs:
        PC, SP, SR, CG2. R3, or the constant generator, is
        a pseudo-register. It cannot be overwritten, and it
        it exclusively generated as an operand by the 
        Constant Generator module. All logic for the SFRs and
        Address Modes are included in this module.

    Inputs:
        IdxF - Index Offset Fetch. Increments PC
        IF   - Instruction Fetch. Increments PC
        SPF  - Stack Pointer Fetch (mapped by AddrM = 01b). Decrements SP
        INTACK - Interrupt Acknowledge. Resets SR
        Ex - Instruction execution. Causes SR to latch new bits

        SRnew - new Status Register bits. From instruction execution

        srcA, dstA - source/destination register select
        IW6 - B/W - controls source/destination operand width, autoincrement 
                    feature, and writeback width
        srcInc, dstInc - Indirect Autoincrement Mode signal
        RW - Register Writeback
        result - register writeback value
        ISR - Interrupt Service Routine - MDB value from IVT

    Outputs:
        PC, SP, SRcurrent - SFR register values
        GIE - Global Interrupt Enable - for Maskable Interrupts
        Rsrc, Rdst - register operands

--------------------------------------------------------*/

module RegisterFile(
    input clk, rst,
    input IdxF, IF, SPF, INTACK, Ex,
    input [3:0] SRnew,
    input [3:0] srcA, dstA,
    input IW6, srcInc, dstInc, RW,
    input [15:0] result, ISR,

    output [15:0] PCout, SPout, Rsrc, Rdst,
    output [3:0] SRcurrent,
    output GIE
 );

    /* Internal signal definitions */
    reg [15:0] Registers[15:0];

    initial begin 
        for (integer i = 0; i < 16; i = i + 1) 
            Registers[i] = 0;
     end

    `include "NEW\\MACROS.v" // global parameter defines

    /* Continuous Logic Assignments */
    assign PCout = Registers[PC];
    assign SPout = Registers[SP];
    assign SRcurrent = {
        Registers[SR][BITV],
        Registers[SR][BITN],
        Registers[SR][BITZ],
        Registers[SR][BITC]
    } ;
    assign GIE  = Registers[SR][BITGIE];
    assign Rsrc = Registers[srcA];
    assign Rdst = Registers[dstA];

    /* Sequential Logic Assignments */
    always @(posedge clk) begin
        if (rst) begin
            for (integer i = 0; i < 16; i = i + 1) 
                Registers[i] = 0;
        end
        else begin
            /* Handle PC */
            if (INTACK) begin
                Registers[PC] <= {ISR[15:1], 1'b0};
            end
            else if (IdxF | IF) begin
                Registers[PC] <= Registers[PC] + 2;
            end
            
            /* Handle SP */
            if (SPF) begin
                Registers[SP] <= Registers[SP] - 2;
            end

            /* Handle SR */
            if (INTACK) begin
                Registers[SR] <= 0; // reset on interrupt entrance
            end
            else if (Ex) begin
                {Registers[SR][BITV], Registers[SR][BITN:BITC]} <= SRnew;
            end

            /* Handle dst RW for Words*/
            if (RW & ~IW6) begin
                case(dstA)
                    /* Special Case PC, SP: LSB of result is ignored */
                    PC, SP: Registers[dstA] <= {result[15:1], 1'b0};

                    /* Special Case SR: bits 15:9 are ignored */
                    SR: Registers[SR] <= {7'b0, result[8:0]};

                    /* Special Case CG2: ignore completely */
                    CG2: Registers[CG2] <= Registers[CG2];

                    default: Registers[dstA] <= result;
                endcase
            end
            /* Handle RW for Bytes */
            else if (RW & IW6) begin
                case(dstA)
                    PC, SP: Registers[dstA] <= {8'b0, result[7:1], 1'b0};
                    SR: Registers[SR]<= {8'b0, result[7:0]};
                    CG2: Registers[CG2] <= Registers[CG2];
                    default: Registers[dstA] <= {8'b0, result[7:0]};
                endcase
            end

            /* Handle source autoincrement. Valid only for non-CG srcA */
            if (srcInc && srcA != CG1 && srcA != CG2) begin
                /* Word-wise operands  or PC/SP used for bytes */
                if (~IW6 || (srcA == PC || srcA == SP))
                    Registers[srcA] <= Registers[srcA] + 2;
                else
                    Registers[srcA] <= Registers[srcA] + 1;
            end

            /* Handle destination autoinc. Valid only for non-CG dstA */
            if (dstInc && dstA != CG1 && dstA != CG2) begin
                /* Word-wise operands  or PC/SP used for bytes */
                if (~IW6 || (dstA == PC || dstA == SP))
                    Registers[dstA] <= Registers[dstA] + 2;
                else
                    Registers[dstA] <= Registers[dstA] + 1;
            end
        end
    end

endmodule
