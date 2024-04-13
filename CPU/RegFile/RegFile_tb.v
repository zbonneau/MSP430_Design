`include "CPU\\RegFile\\RegisterFile.v"
`timescale 100ns/100ns

module RegisterFile_tb;
    reg clk, reset;
    reg [1:0] MO;
    
    reg BranchExecute;
    reg [15:0] BranchAddress;

    reg SRW, Zin, Vin, Nin, Cin;

    reg [3:0] srcA, dstA;
    reg [1:0] As;
    reg Ad, OneOp;
    reg incSrc, incDst, BW, indirect;

    reg [3:0] resultA;
    reg RW;
    reg [15:0] dataIn;

    wire [15:0] PCout, SPout, Rsrc, Rdst;
    wire [15:0] MAB;
    wire Zcurrent, Vcurrent, Ncurrent, Ccurrent;

    `include "CPU\\RegFile\\RegisterParams.v"
    `include "CPU\\GeneralParams.v"

    wire [3:0] ZVNCin, ZVNCcurrent;

    // Clean waveform by reducing line # for SR bits
    assign ZVNCin = {Zin, Vin, Nin, Cin};
    assign ZVNCcurrent = {Zcurrent, Vcurrent, Ncurrent, Ccurrent};

    initial begin
        {clk, reset, MO} <= 0;
        {BranchExecute, BranchAddress} <= 0;
        {SRW, Zin, Vin, Nin, Cin} <= 0;
        {srcA, dstA, As, Ad, OneOp, incSrc, incDst, BW, indirect} <= 0;
        {resultA, RW, dataIn} <= 0;
    end

    RegisterFile uut(
        .clk(clk), .reset(reset),
        .MO(MO),
        .BranchExecute(BranchExecute), .BranchAddress(BranchAddress),
        .SRW(SRW), .Zin(Zin), .Vin(Vin), .Nin(Nin), .Cin(Cin),
        .srcA(srcA), .dstA(dstA), .As(As), .Ad(Ad), .OneOp(OneOp),
        .incSrc(incSrc), .incDst(incDst), .BW(BW), .indirect(indirect),
        .resultA(resultA), .RW(RW), .dataIn(dataIn),
        .PCout(PCout), .SPout(SPout), .Rsrc(Rsrc), .Rdst(Rdst),
        .MAB(MAB), .Zcurrent(Zcurrent), .Ncurrent(Ncurrent), 
        .Vcurrent(Vcurrent), .Ccurrent(Ccurrent)
    );

    always #5 begin clk <= ~clk; end

    initial begin
        $dumpfile("RegisterFile.vcd");
        $dumpvars(0, RegisterFile_tb);
        for (integer i = 0; i < 16; i = i+1) begin
            $dumpvars(1, uut.R[i]);
        end

    #2; // Control Signals come from Microsequencer, updated on negedge of clk. 2/10 CC demonstrates signal delay so
        // effects of control signals occur on the next edge, like it would in the full module.

    // Test Status Register Write
    for (integer i = 0; i < 32; i = i+1) begin 
        {SRW, Zin, Vin, Nin, Cin} <= i[4:0] + 1; #10; // SRW occurs on negedge to align with pipeline Ex stage
    end

    // Test Branch Control
    BranchExecute <= 0; BranchAddress <= 10; #10;
    BranchExecute <= 1; BranchAddress <= 10; #10;
    BranchExecute <= 1; BranchAddress <= 21; #10; // Test PC[0] = 0
    BranchExecute <= 1; BranchAddress <= 30; RW <= 1; resultA <= PC; dataIn <= 40; #10; // Test Branch ignore on PC RW
    BranchExecute <= 0;                      RW <= 0; resultA <= 0;  dataIn <= 0;  #10; 
    BranchAddress <= 0;

    // Test MO Control (& MAB for PC, SP)
    uut.R[SP] <= 16'h2400; // Top of Stack
    MO <= MO_NOP; #10;
    MO <= MO_NextInstruction; #10;
    MO <= MO_Offset; #10;
    MO <= MO_SPPreDec; #10;
    MO <= MO_NOP;

    // Test MAB Control for indirect
    indirect <= 1'b1;
    OneOp <= 1'b0; srcA <= R5;  dstA <= R10; As <= INDIRECT_MODE;               incSrc <= 1'b0; #10; // indirect src
    OneOp <= 1'b0; srcA <= R6;  dstA <= R11; As <= INDIRECT_AUTOINCREMENT_MODE; incSrc <= 1'b1; #10; // indirect autoincrement src + 2
    OneOp <= 1'b0; srcA <= CG1; dstA <= R10; As <= INDIRECT_MODE;               incSrc <= 1'b0; #10; // src Generated
    OneOp <= 1'b0; srcA <= CG2; dstA <= R11; As <= INDIRECT_AUTOINCREMENT_MODE; incSrc <= 1'b1; #10; // src Generated
    OneOp <= 1'b1; srcA <= R5;  dstA <= R10; As <= INDIRECT_MODE;               incSrc <= 1'b0; incDst <= 1'b0; #10; // indirect dst
    OneOp <= 1'b1; srcA <= R6;  dstA <= R11; As <= INDIRECT_AUTOINCREMENT_MODE; incSrc <= 1'b0; incDst <= 1'b1; BW <= 1; #10; // indirect autoincrement dst +1
    OneOp <= 1'b1; srcA <= R5;  dstA <= CG1; As <= INDIRECT_MODE;               incSrc <= 1'b0; incDst <= 1'b0; #10; // dst Generated
    OneOp <= 1'b1; srcA <= R6;  dstA <= CG2; As <= INDIRECT_AUTOINCREMENT_MODE; incSrc <= 1'b0; incDst <= 1'b1; #10; // dst Generated
    indirect <= 1'b0; 
    OneOp = 1'b0;               dstA <= R7;  As <= REGISTER_MODE; BW <= 0;                      incDst <= 1'b0;
 
    // Test Write Back
    RW <= 1'b1;
    resultA <= PC; dataIn <= 30; #10; dataIn <= 41; #10;
    resultA <= SP; dataIn <= 30; #10; dataIn <= 41; #10;
    resultA <= SR; dataIn <= 16'h4321; #10; // should see SR = 0x0121. V, ~N, ~Z, C 
    resultA <= CG2; dataIn <= 24; #10;
    for (integer i = R4; i < 16; i = i+1) begin
        resultA = i[3:0]; dataIn = i << 4;
        if (i == R10) RW <= 0; 
        #10;
    end

    // Test Constant Generator Unit
    srcA <= CG1; As <= REGISTER_MODE; #10;
    srcA <= CG1; As <= INDEXED_MODE;  #10;
    srcA <= CG1; As <= INDIRECT_MODE; #10;
    srcA <= CG1; As <= INDIRECT_AUTOINCREMENT_MODE; #10;
    srcA <= CG2; As <= REGISTER_MODE; #10;
    srcA <= CG2; As <= INDEXED_MODE;  #10;
    srcA <= CG2; As <= INDIRECT_MODE; #10;
    srcA <= CG2; As <= INDIRECT_AUTOINCREMENT_MODE; #10;

    srcA  <= PC; As <= REGISTER_MODE;
    OneOp <= 1'b1;
    dstA <= CG1; As <= REGISTER_MODE; #10;
    dstA <= CG1; As <= INDEXED_MODE;  #10;
    dstA <= CG1; As <= INDIRECT_MODE; #10;
    dstA <= CG1; As <= INDIRECT_AUTOINCREMENT_MODE; #10;
    dstA <= CG2; As <= REGISTER_MODE; #10;
    dstA <= CG2; As <= INDEXED_MODE;  #10;
    dstA <= CG2; As <= INDIRECT_MODE; #10;
    dstA <= CG2; As <= INDIRECT_AUTOINCREMENT_MODE; #10;

    As <= REGISTER_MODE;
    OneOp <= 1'b0;
    dstA <= CG1; Ad <= REGISTER_MODE; #10;
    dstA <= CG1; Ad <= INDEXED_MODE;  #10;
    dstA <= CG2; Ad <= REGISTER_MODE; #10;
    dstA <= CG2; Ad <= INDEXED_MODE;  #10;

    dstA <= R6; Ad <= REGISTER_MODE;

    // Test Reset
    reset <= 1; #10;
    reset <= 0; #10;

    $finish;
    end
endmodule