/*--------------------------------------------------------
    Module Name : Constant Generator
    Description: 
        Describes the MSP430 CPU Constant Generator.
        Certain Immediate constants are more common than others.
        Generating these values in silicon is faster and more 
        memory efficient than storing them in program memory.
        The constant generator utilizes two registers (R2/R3 - 
        CG1/CG2) and various address modes to produce source
        operands.
    
    Inputs:
        Format   - Format 1/2 indicator (~1/2)
        srcA, As - Combinations of these IW bits produce CGx output
        dstA, Ad - Same as above. Less common, but possible for 
                   instructions such as Push, Call, etc 

    Outputs: 
        src, dst - src & dst operand data
        srcGenerated, dstGenerated - 
            notify external modules that the CG triggered

--------------------------------------------------------*/

module ConstantGenerator(
    input               Format,
    input [3:0]         srcA,
    input [1:0]         As,
    input [3:0]         dstA,
    input               Ad,
    output reg [15:0]   src, dst,
    output reg          srcGenerated, dstGenerated
 );
 `include "NEW\\PARAMS.v"

 // Initialize regs
    initial begin {src, dst, srcGenerated, dstGenerated} = 0; end

 always @(*) begin
    // default behavior
    {src, dst, srcGenerated, dstGenerated} = 0;

    if (~Format) begin
        // 2-op instruction decoding
        case ({srcA, As})
            {CG1, INDEXED_MODE}:                begin src <= 16'h0;     srcGenerated <= 1; end
            {CG1, INDIRECT_MODE}:               begin src <= 16'h4;     srcGenerated <= 1; end
            {CG1, INDIRECT_AUTOINCREMENT_MODE}: begin src <= 16'h8;     srcGenerated <= 1; end
            {CG2, REGISTER_MODE}:               begin src <= 16'h0;     srcGenerated <= 1; end
            {CG2, INDEXED_MODE}:                begin src <= 16'h1;     srcGenerated <= 1; end
            {CG2, INDIRECT_MODE}:               begin src <= 16'h2;     srcGenerated <= 1; end
            {CG2, INDIRECT_AUTOINCREMENT_MODE}: begin src <= 16'hFFFF;  srcGenerated <= 1; end
            default:                            begin src <= 16'h0;     srcGenerated <= 0; end
        endcase
        // 2-op instructions with generated destination produce assembler warning.
        // Silicon support included to prevent undefined behavior
        case ({dstA, Ad})
            {CG1, 1'b1}: begin dst <= 16'h0; dstGenerated <= 1; end
            {CG2, 1'b0}: begin dst <= 16'h0; dstGenerated <= 1; end
            {CG2, 1'b1}: begin dst <= 16'h1; dstGenerated <= 1; end
            default:     begin dst <= 16'h0; dstGenerated <= 0; end
        endcase
    end
    else begin
        // 1-op & jump instructions
        case ({dstA, As}) // As bits of IW are used by Rdst for generation. See 
                        // CPU (16-bit) - Instruction Set - Single Operand
            {CG1, INDEXED_MODE}:                begin dst <= 16'h0;     dstGenerated <= 1; end
            {CG1, INDIRECT_MODE}:               begin dst <= 16'h4;     dstGenerated <= 1; end
            {CG1, INDIRECT_AUTOINCREMENT_MODE}: begin dst <= 16'h8;     dstGenerated <= 1; end
            {CG2, REGISTER_MODE}:               begin dst <= 16'h0;     dstGenerated <= 1; end
            {CG2, INDEXED_MODE}:                begin dst <= 16'h1;     dstGenerated <= 1; end
            {CG2, INDIRECT_MODE}:               begin dst <= 16'h2;     dstGenerated <= 1; end
            {CG2, INDIRECT_AUTOINCREMENT_MODE}: begin dst <= 16'hFFFF;  dstGenerated <= 1; end
            default:                            begin dst <= 16'h0;     dstGenerated <= 0; end
        endcase
    end
 end
endmodule
