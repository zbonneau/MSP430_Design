/*--------------------------------------------------------
    Module Name : Control Unit
    Description: 
        Describes the MSP430 CPU Controller for 16-, 8-bit data
        No Extended/Address instructions
    
    Inputs:
        CAR - controls datapath for various instruction and operand types
        IR  - instruction register

    Outputs: 
        IW       - Instruction word (usually directly piped from IR, but can be
                                     altered for Interrupt)
        srcA, As - src register and address mode
        dstA, Ad - dst register and address mode
        Format   - instruction Format type. Controls Constant Generator 
                   behavior: 
                    0: Format 1 - 2-op
                    1: Format 2 - 1-op
        INTACK   - INTerrupt ACKnowledge
        {PCO[1:0], MEM, EX, srcM, srcL, dstM, dstL, AddressM[1:0], AddressL, IdxM} ->
         -> 12-bit output containing controll signals for PC options, memory/execute, operand selection, and address manipulation
                
--------------------------------------------------------*/
`timescale 100ns/100ns

module ControlUnit(
    input [CAR_BITS-1:0] CAR,
    input [15:0]        IR,

    output reg [15:0]   IW,
    output reg [3:0]    srcA,
    output reg [1:0]    As,
    output reg [3:0]    dstA,
    output reg          Ad, BW, 
    output              Format, INTACK,
    output reg [11:0]   ControlWord
);

    `include "NEW\\PARAMS.v"
    initial begin {IW, srcA, As, dstA, Ad, BW, ControlWord} <= 0; end

    /* Format 1 vs 2 instructions. Controls Constant Generator */
    assign Format = (IW[15:12] == 4'h1);

    /* INTACK - informs interrupt unit that Controller accepts interrupt */
    assign INTACK = (CAR == CAR_INT4); 

    always @(*) begin
        IW      = IR;
        srcA    = IR[11:8];
        As      = IR[5:4]; 
        dstA    = IR[3:0];
        Ad      = IR[7];
        BW      = IR[6];

        case(CAR)           //  | -----Control Word---- | --------IW Alterations--------- |
            CAR_0         : begin ControlWord = 12'h400; end
            CAR_REG_REG   : begin ControlWord = 12'h500; end
            CAR_REG_IDX0  : begin ControlWord = 12'h823; end
            CAR_REG_IDX1  : begin ControlWord = 12'h230; end
            CAR_REG_IDX2  : begin ControlWord = 12'h320; end
            CAR_REG_IDX3  : begin ControlWord = 12'h400; end
            CAR_IND_REG0  : begin ControlWord = 12'h2C8; end
            CAR_IND_REG1  : begin ControlWord = 12'h580; end
            CAR_IND_IDX0  : begin ControlWord = 12'h2E8; end
            CAR_IND_IDX1  : begin ControlWord = 12'h8A3; end
            CAR_IND_IDX2  : begin ControlWord = 12'h2B0; end
            CAR_IND_IDX3  : begin ControlWord = 12'h3A0; end
            CAR_IND_IDX4  : begin ControlWord = 12'h400; end
            CAR_IDX_REG0  : begin ControlWord = 12'h882; end
            CAR_IDX_REG1  : begin ControlWord = 12'h2C0; end
            CAR_IDX_REG2  : begin ControlWord = 12'h580; end
            CAR_IDX_IDX0  : begin ControlWord = 12'h8A2; end
            CAR_IDX_IDX1  : begin ControlWord = 12'h2E0; end
            CAR_IDX_IDX2  : begin ControlWord = 12'h8A3; end
            CAR_IDX_IDX3  : begin ControlWord = 12'h2B0; end
            CAR_IDX_IDX4  : begin ControlWord = 12'h3A0; end
            CAR_IDX_IDX5  : begin ControlWord = 12'h400; end
            CAR_1OP_REG   : begin ControlWord = 12'h500; end
            CAR_1OP_IND0  : begin ControlWord = 12'h23E; end
            CAR_1OP_IND1  : begin ControlWord = 12'h320; end
            CAR_1OP_IND2  : begin ControlWord = 12'h420; end
            CAR_1OP_IDX0  : begin ControlWord = 12'h823; end
            CAR_1OP_IDX1  : begin ControlWord = 12'h230; end
            CAR_1OP_IDX2  : begin ControlWord = 12'h320; end
            CAR_1OP_IDX3  : begin ControlWord = 12'h400; end
            CAR_PUSH_REG0 : begin ControlWord = 12'h010; srcA = SP; end
            CAR_PUSH_REG1 : begin ControlWord = 12'h324; srcA = SP; end
            CAR_PUSH_REG2 : begin ControlWord = 12'h400; srcA = SP; end
            CAR_PUSH_IND0 : begin ControlWord = 12'h23C; srcA = SP; end
            CAR_PUSH_IND1 : begin ControlWord = 12'h324; srcA = SP; end
            CAR_PUSH_IND2 : begin ControlWord = 12'h400; srcA = SP; end
            CAR_PUSH_IDX0 : begin ControlWord = 12'h823; srcA = SP; end
            CAR_PUSH_IDX1 : begin ControlWord = 12'h230; srcA = SP; end
            CAR_PUSH_IDX2 : begin ControlWord = 12'h324; srcA = SP; end
            CAR_PUSH_IDX3 : begin ControlWord = 12'h400; srcA = SP; end
            CAR_CALL_REG0 : begin ControlWord = 12'h010; srcA = SP; end
            CAR_CALL_REG1 : begin ControlWord = 12'h304; srcA = SP; dstA = PC; end
            CAR_CALL_REG2 : begin ControlWord = 12'h120; srcA = SP; dstA = PC; end
            CAR_CALL_IND0 : begin ControlWord = 12'h23C; srcA = SP; end
            CAR_CALL_IND1 : begin ControlWord = 12'h304; srcA = SP; dstA = PC; end
            CAR_CALL_IND2 : begin ControlWord = 12'h120; srcA = SP; dstA = PC; end
            CAR_CALL_IDX0 : begin ControlWord = 12'h803; srcA = SP; end
            CAR_CALL_IDX1 : begin ControlWord = 12'h230; srcA = SP; end
            CAR_CALL_IDX2 : begin ControlWord = 12'h304; srcA = SP; dstA = PC; end
            CAR_CALL_IDX3 : begin ControlWord = 12'h120; srcA = SP; dstA = PC; end
            CAR_RETI0     : begin ControlWord = 12'h2C8; srcA = SP; As = 2'b11; dstA = SR; end
            CAR_RETI1     : begin ControlWord = 12'h180; dstA = SR; end
            CAR_RETI2     : begin ControlWord = 12'h2C8; srcA = SP; As = 2'b11; dstA = PC; end
            CAR_RETI3     : begin ControlWord = 12'h180; dstA = PC; end
            CAR_INT0      : begin ControlWord = 12'h010; srcA = SP; As = 0; Ad = 0; dstA = PC; end
            CAR_INT1      : begin ControlWord = 12'h324; BW = 0;    As = 0; Ad = 0; srcA = SP; dstA = PC; IW = PUSH; end
            CAR_INT2      : begin ControlWord = 12'h010; srcA = SP; As = 0; Ad = 0; dstA = SR; end
            CAR_INT3      : begin ControlWord = 12'h324; BW = 0;    As = 0; Ad = 0; srcA = SP; dstA = SR; IW = PUSH; end
            CAR_INT4      : begin ControlWord = 12'h000; end
            CAR_JMP0      : begin ControlWord = 12'h100; BW = 0;    dstA = PC; end
            default: ControlWord = 12'h000;
        endcase
    end

endmodule