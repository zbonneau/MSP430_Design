/*--------------------------------------------------------
    Module Name : Instruction Decoder
    Description: 
        Describes the MSP430 Instruction Decoder
        No extended/address instructions
    
    Inputs:
        Instruction - from Instruction Register

    Outputs:
        FS          - Funnction Select = OpCode - src, dst, As, Ad, BW Info
        BranchOffset - 10-bit sign-extended immediate offset for jumping instructions
        srcA, dstA  - src, dst Register Addresses
        As, Ad      - Address Modes
        BW          - Byte/Word
        OneOp       - True if one-operand Instruction
        
        
--------------------------------------------------------*/

module InstructionDecoder(
    input [15:0] Instruction,

    output reg [15:0] FS, BranchOffset
    output reg [3:0] srcA, dstA,
    output reg [1:0] As,
    output reg Ad, BW, OneOp
    );

    `include "CPU\\FunctionUnit\\FSparams.v"
    `include "CPU\\InstructionDecoder\\DecoderParams.v"

    initial begin {FS, srcA, dstA, As, Ad, BW, OneOp} <= 0; end

    always @(*) begin
        {BranchOffset, srcA, dstA, As, Ad, BW, OneOp} <= 0;
        case(Instruction[15:12])
            4'h0: begin 
                FS           <= MOV; // Invalid Instruction, Force as NOP mov R3, R3
                srcA         <= CG2;
                dstA         <= CG2;
            end

            4'h1: begin // Format 2 - One Operand
                FS <= {Instruction[15:6], 6'b0}; // mask dstA, Ad
                dsta <= Instruction[3:0];
                As <= Instruction[5:4];
                BW <= Instruction[6];
                OneOp <= 1;
            end

            4'h2, 4'h3:begin // Jump Instructions
                FS <= {Instruction[15:10], 10'b0};
                BranchOffset <= {5'{Instruction[9]},Instruction[9:0],1'b0};
            end

            default:begin // Format 1 Instruction
                FS <= {Instruction[15:12], 5'b0, Instruction[6], 6'b0};
                srcA <= Instruction[11:8];
                dstA <= Instruction[3:0];
                {Ad, BW, As} <= Instruction[7:4];
            end
        endcase        
    end
endmodule