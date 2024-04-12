/*------------------------------------
    Module Name: Register File
    Description:
        Describes the MSP430FR6989 Register File
        as 16-bit registers (no extended/address instructions, Memory Range = 65 kB)

    Inputs:
        clk, reset - reset is from hardware RST IO
        incSrc, incPC - used for indirect autoincrement, increment PC on IF, offset fetch
        branch - latches PC for branching operations
        SRW, BW - control SR writes, BW for indirect autoincrement
        As, Ad - address modes for src, dst (for constant generator)
        srcA, srcData - source address, data
        dstA, dstData - dst address, data
        RW, DA, dataIn - reg write, data address, data
        BranchAddress - PC input for branches
        Zin, Vin, Nin, Cin - SR input Z, V, N, C In/Out relative to Reg File
        PC, SP, SR - special registers

------------------------------------*/

module RegisterFile (
    input clk, reset,
    input incSrc, incPC, branch
    input SRW, BW, RW, Ad
    input [1:0] As,
    input [3:0] srcA, dstA, DA
    input [15:0] dataIn, branchAddress,
    input Zin, Vin, Nin, Cin,

    output reg [15:0] srcData, dstData
    output [15:0] PC, SP
    output Zout, Vout, Nout, Cout
);

    `include "CPU\\RegisterParams.v"
    initial begin {srcData, dstData} = 0; end

    reg [15:0] R [15:0];

    initial begin
        PC  <= 0;
        SP  <= 0;
        SR  <= 0;
        CG2 <= 0;
        // Complete Reset Conditions Here
        R[R4]  <= 16'hFFFF;
        R[R5]  <= 16'hFFFF;
        R[R6]  <= 16'hFFFF;
        R[R7]  <= 16'hA55A;
        R[R8]  <= 16'hFFFF;
        R[R9]  <= 16'h0116;
        R[R10] <= 16'h1AF8;
        R[R11] <= 16'hFFFF;
        R[R12] <= 16'h4;
        // R[R13] <= 16'h0; // R13 Reset Condition appears undefined
        R[R14] <= 16'h1A1A;
        R[R15] <= 16'h4400;
    end

    // handle src, dst assignments
    always @(*) begin
        if (srcA == CG1 || srcA == CG2) begin
            // Handles Constant Generation for src operands. 
            // Taken from Family User Guide, 4.3.4, Pg 119. 
            // Table 4-2 Values of Constant Generators CG1, CG2
            case ({srcA, As})
                {CG1, REGISTER_MODE}              : srcData <= R[srcA];  // Register Mode, SR bits used
                {CG1, ABSOLUTE_MODE}              : srcData <= 0;        // absolute addressing from SR
                {CG1, INDIRECT_MODE}              : srcData <= 4;        // +4, bit processing
                {CG1, INDIRECT_AUTOINCREMENT_MODE}: srcData <= 8;        // +8, bit processing
                {CG2, REGISTER_MODE}              : srcData <= 0;        // 0, word processing
                {CG2, ABSOLUTE_MODE}              : srcData <= 1;        // +1, bit processing, increment, decrement
                {CG2, INDIRECT_MODE}              : srcData <= 2;        // +4, bit processing
                {CG2, INDIRECT_AUTOINCREMENT_MODE}: srcData <= 16'hFFFF; // -1, word processing
            endcase
        end
        dstData <= R[dstA];
    end

    // handle Negative Edge assignments 
    // PC increment, SRW, @Rn+
    always @(negedge clk) begin
        if (incSrc) begin R[srcA] <= (BW) ? R[srcA] + 1 : R[srcA] + 2; end // Autoincrement by 1 if Byte data, 2 if word
        if (incPC)  begin R[PC] <= R[PC] + 2; R[PC][0] <= 0; end // force PC to even addresses
        if (branch) begin R[PC] <= branchAddress; end// handle branching 
        if (SRW)    begin R[SR] <= {7'b0, Vin, 4'b0, R[SR][GIE], Nin, Zin, Cin}; end // do not overwrite GIE
    end

    // Handle WB

    always @(posedge clk) begin
        if (reset) begin
            // Reset Conditions Here
            PC  <= 0;
            SP  <= 0;
            SR  <= 0;
            CG2 <= 0;
            // Complete Reset Conditions Here
            R[R4]  <= 16'hFFFF;
            R[R5]  <= 16'hFFFF;
            R[R6]  <= 16'hFFFF;
            R[R7]  <= 16'hA55A;
            R[R8]  <= 16'hFFFF;
            R[R9]  <= 16'h0116;
            R[R10] <= 16'h1AF8;
            R[R11] <= 16'hFFFF;
            R[R12] <= 16'h4;
            // R[R13] <= 16'h0; // R13 Reset Condition appears undefined
            R[R14] <= 16'h1A1A;
            R[R15] <= 16'h4400;
        end
        else begin
            if (RW) begin
                if (DA != CG2) begin
                    R[DA] <= dataIn;
                end
            end
        end
    end
endmodule