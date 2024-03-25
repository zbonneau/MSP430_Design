/*------------------------------------
    Module Name: Register File
    Description:
        Describes the MSP430FR6989 Register File
        as 16-bit registers (no extended/address instructions, Memory Range = 65 kB)

    Inputs:
        clk, reset
        incSrc, incPC - used for indirect autoincrement, increment PC on IF, offset fetch
        branch - latches PC for branching operations
        SRW, BW - control SR writes, BW for indirect autoincrement
        As, Ad - address modes for src, dst (for constant generator)
        srcA, srcData - source address, data
        dstA, dstData - dst address, data
        RW, DA, dataIn - reg write, data address, data
        BranchAddress - PC input for branches
        SRin - SR input Z, V, N, C
        PC, SP, SR - special registers

------------------------------------*/

module RegisterFile (
    input clk, reset,
    input incSrc, incPC, branch
    input SRW, BW, RW, Ad
    input [1:0] As,
    input [3:0] srcA, dstA, DA
    input [15:0] dataIn
    input Zero, V, N, C,

    output reg [15:0] srcData, dstData
    output [15:0] PC, SP, SR
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
    end
    
endmodule