/*--------------------------------------------------------
    Module Name : RegisterFile
    Description:
        Describes the MSP430 Register File as 16-bit registers.
        No Extended/address instructions, Memory Range = 65 kB
    
    Inputs:
        clk, reset
        MO - used for instruction Fetch, offset fetch, SP predecrement

        BranchExecute - write PC <- BranchAddress on posedge for conditional jumps
        BranchAddress - PC <- BranchAddress on posedge with BrEx

        SRW - Update SR bits Z, V, N, C from Function Unit
        Zin, Vin, Nin, Cin - status bits from Function Unit

        srcA, dstA - src, dst Address
        As - Address Mode for Source.      Used only for CG1, CG2 generation
        Ad - Address Mode for Destination. Used only for CG1, CG2 generation
        OneOp: Controls Constant Generator and indirect address mux (0: R[src], 1: R[dst])
        incSrc, incDst, BW, indirect - for indirect AutoIncrement (BW: +1, ~BW: +2)

        resultA - Address for write back data
        RW - enable write back
        dataIn  - write back data

    Outputs:
        PC, SP - special register outputs
        MAB - address value to fetch instruction/data from
        Rsrc, Rdst - register mode operands for src, dst
        Zcurrent, Vcurrent, Ncurrent, Ccurrent - Current Status Bits from SR
--------------------------------------------------------*/

module RegisterFile (
    input clk, reset,
    input [1:0] MO,
    
    input BranchExecute,
    input [15:0] BranchAddress,

    input SRW, Zin, Vin, Nin, Zin,

    input [3:0] srcA, dstA,
    input [1:0] As,
    input Ad, OneOp,
    input incSrc, incDst, BW, indirect,

    input [3:0] resultA,
    input RW,
    input [15:0] dataIn,

    output [15:0] PC, SP, Rsrc, Rdst,
    output reg [15:0] MAB, 
    output Zcurrent, Vcurrent, Ncurrent, Ccurrent
);

    `include "CPU\\RegisterParams.v"
    `include "CPU\\GeneralParams.v"

    reg [15:0] R [15:0];

    initial begin 
        MAB <= 0;
        for (integer i = 0; i < 16; i = i+1) begin R[i] <= 0; end
        // Insert Reset Conditions for special registers here
    end

   // Reset Control
    always @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < 16; i = i+1) begin R[i] <= 0; end
            // Describe Special register reset conditions here
        end
    end

   // Branch Control
    always @(posedge clk) begin
        if (BranchExecute) begin R[PC] <= BranchAddress; end
    end

   // MO Control
    always @(negedge clk) begin
        case (MO)
            MO_NOP:             begin end
            MO_NextInstruction: begin R[PC] <= R[PC] + 2; end 
            MO_Offset:          begin R[PC] <= R[PC] + 2; end
            MO_SPPreDec:        begin R[SP] <= R[SP] - 2; end
        endcase
    end

   // MAB Control
    always @(*) begin
        if (indirect) begin MAB <= (OneOp) ? R[dstA] : R[srcA]; end
        if (MO == MO_NextInstruction || MO == MO_Offset) begin MAB <= R[PC]; end
    end

   // Status Register Control
    always @(posedge clk) begin 
        if (SRW) begin {R[SR][BITZ], R[SR][BITV], R[SR][BITN], R[SR][BITC]} <= {Zin, Vin, Nin, Cin}; end
    end

   // Write Back Control
    always @(posedge clk) begin
        if (RW) begin  
            case (resultA)
                PC, SP:     R[resultA] <= {dataIn[15:1] , 1'b0}; // force PC[0] or SP[0] to 0
                SR:         R[resultA] <= {7'b0, dataIn[8:0]}; // SR[15:9] are reserved (0)
                CG2:        R[resultA] <= 0; // R3, Constant Generator always 0
                default:    R[resultA] <= dataIn;
            endcase
        end
    end

   // Indirect AutoIncrement Addressing Control
    always @(negedge clk) begin
        if (incSrc) begin R[srcA] <= (BW) ? R[srcA] + 1 : R[srcA] + 2; end
        if (incDst) begin R[dstA] <= (BW) ? R[dstA] + 1 : R[dstA] + 2; end
    end

   // Constant Generator Unit
    reg [15:0] srcConstant, dstConstant;
    reg srcGenerated, dstGenerated;
    always @(*) begin
        case ({As, srcA})
            {REGISTER_MODE, R2}:                begin srcConstant <= R[srcA];  srcGenerated = 1; end
            {INDEXED_MODE,  R2}:                begin srcConstant <= 16'h0;    srcGenerated = 1; end
            {INDIRECT_MODE, R2}:                begin srcConstant <= 16'h4;    srcGenerated = 1; end
            {INDIRECT_AUTOINCREMENT_MODE, R2}:  begin srcConstant <= 16'h8;    srcGenerated = 1; end
            {REGISTER_MODE, R3}:                begin srcConstant <= 16'h0;    srcGenerated = 1; end
            {INDEXED_MODE,  R3}:                begin srcConstant <= 16'h1;    srcGenerated = 1; end
            {INDIRECT_MODE, R3}:                begin srcConstant <= 16'h2;    srcGenerated = 1; end
            {INDIRECT_AUTOINCREMENT_MODE, R3}:  begin srcConstant <= 16'hFFFF; srcGenerated = 1; end
            default:                            begin srcConstant <= 16'hDEAD; srcGenerated = 0; end // srcA != CG1, CG2
        endcase

        if (OneOp) begin
            case ({As, dstA})
                {REGISTER_MODE, R2}:                begin dstConstant <= R[dstA];  dstGenerated = 1; end
                {INDEXED_MODE,  R2}:                begin dstConstant <= 16'h0;    dstGenerated = 1; end
                {INDIRECT_MODE, R2}:                begin dstConstant <= 16'h4;    dstGenerated = 1; end
                {INDIRECT_AUTOINCREMENT_MODE, R2}:  begin dstConstant <= 16'h8;    dstGenerated = 1; end
                {REGISTER_MODE, R3}:                begin dstConstant <= 16'h0;    dstGenerated = 1; end
                {INDEXED_MODE,  R3}:                begin dstConstant <= 16'h1;    dstGenerated = 1; end
                {INDIRECT_MODE, R3}:                begin dstConstant <= 16'h2;    dstGenerated = 1; end
                {INDIRECT_AUTOINCREMENT_MODE, R3}:  begin dstConstant <= 16'hFFFF; dstGenerated = 1; end
                default                             begin dstConstant <= 16'hDEAD; dstGenerated = 0; end // dstA != CG1, CG2
            endcase
        end
        else begin
            case ({Ad, dstA})
                {1'b0, R2}: begin dstConstant <= R[dstA];  dstGenerated = 1;  end
                {1'b1, R2}: begin dstConstant <= 16'h0;    dstGenerated = 1;  end
                {1'b0, R3}: begin dstConstant <= 16'h0;    dstGenerated = 1;  end
                {1'b1, R3}: begin dstConstant <= 16'h1;    dstGenerated = 1;  end
                default:    begin dstConstant <= 16'hDEAD; dstGenerated = 0;  end 
            endcase
        end
    end
    
   // Output Assignments
    assign PC = R[PC];
    assign SP = R[SP];
    assign Rsrc = (srcGenerated) ? srcConstant : R[srcA];
    assign Rdst = (dstGenerated) ? dstConstant : R[dstA];

    assign Zcurrent = R[SR][BITZ];
    assign Vcurrent = R[SR][BITV];
    assign Ncurrent = R[SR][BITN];
    assign Ccurrent = R[SR][BITC];
endmodule