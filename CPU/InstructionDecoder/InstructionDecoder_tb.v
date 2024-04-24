`include "CPU\\InstructionDecoder\\InstructionDecoder.v"
`timescale 100ns/100ns

module InstructionDecoder_tb;
    reg [15:0] Instruction;

    wire [15:0] FS, BranchOffset;
    wire [3:0] srcA, dstA;
    wire [1:0] As;
    wire Ad, BW, OneOp;

    InstructionDecoder uut(
        Instruction.(Instruction),
        FS.(FS), BranchOffset.(BranchOffset),
        srcA.(srcA), dstA.(dstA),
        As.(As), Ad.(Ad), BW.(BW), OneOp.(OneOp)
    );

    initial begin
        $dumpfile("InstructionDecoder.vcd");
        $dumpvars(0, InstructionDecoder_tb);
        // Dump Instructions Here
        
    end
endmodule