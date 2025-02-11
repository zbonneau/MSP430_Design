/*--------------------------------------------------------
    Module Name : Register File Testbench
    Description:
        Verifies Functionality of the Register File

--------------------------------------------------------*/

`include "NEW\\RegisterFile.v"
`default_nettype none
`timescale 100ns/100ns

module tb_RegisterFile;
reg clk, rst;
reg IdxF, IF, SPF, INTACK, Ex;
reg [3:0] SRnew;
reg [3:0] srcA, dstA;
reg IW6, srcInc, dstInc, RW;
reg [15:0] result, ISR;
wire [15:0] PCout, SPout, Rsrc, Rdst;
wire [3:0] SRcurrent;
wire GIE;

`include "NEW\\MACROS.v" // global parameter defines


initial begin 
    {clk, rst} = 0; 
    {IdxF, IF, SPF, INTACK, Ex} = 0;
    SRnew = 4'b1010;
    {srcA, dstA} = {R4, R5};
    {IW6, srcInc, dstInc, RW} = 0;
    result = 16'h89AB;
    ISR = 16'h4456; // ISR located in FRAM code memory
end

RegisterFile uut
(
    .clk(clk), .rst(rst),
    .IdxF(IdxF), .IF(IF), .SPF(SPF), .INTACK(INTACK), .Ex(Ex), 
    .SRnew(SRnew), 
    .srcA(srcA), .dstA(dstA), 
    .IW6(IW6), .srcInc(srcInc), .dstInc(dstInc), .RW(RW), 
    .result(result), .ISR(ISR), 
    
    .PCout(PCout), .SPout(SPout), .Rsrc(Rsrc), .Rdst(Rdst), 
    .SRcurrent(SRcurrent), .GIE(GIE)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    $dumpfile("RegisterFile.vcd");
    $dumpvars(0, tb_RegisterFile);
    for (integer i = 0; i < 16; i = i + 1)
        $dumpvars(1, uut.Registers[i]);
end

initial begin
    rst = 1; #(3*CLK_PERIOD); rst = 0;

    /* Test PC SFR */
    INTACK = 1; #CLK_PERIOD; INTACK = 0;
    IdxF = 1; #CLK_PERIOD; IdxF = 0;
    IF = 1; #CLK_PERIOD; IF = 0;

    /* Test SP SFR */
    SPF = 1; #CLK_PERIOD; SPF = 0;

    /* Test SR SFR */
    Ex = 1; #CLK_PERIOD; Ex = 0;

    /* Test R3 src, dst, RW */
    srcA = CG2; dstA = CG2; RW = 1; #CLK_PERIOD; RW = 0;

    /* Test dst RW - word */
    srcA = PC;  dstA = PC;  RW = 1; IW6 = 0; #CLK_PERIOD;
    srcA = SP;  dstA = SP;  RW = 1; IW6 = 0; #CLK_PERIOD;
    srcA = SR;  dstA = SR;  RW = 1; IW6 = 0; #CLK_PERIOD;
    srcA = CG2; dstA = CG2; RW = 1; IW6 = 0; #CLK_PERIOD;
    srcA = R4;  dstA = R4;  RW = 1; IW6 = 0; #CLK_PERIOD; RW = 0;

    /* Test generic dst RW - byte */
    srcA = PC;  dstA = PC;  RW = 1; IW6 = 1; #CLK_PERIOD;
    srcA = SP;  dstA = SP;  RW = 1; IW6 = 1; #CLK_PERIOD;
    srcA = SR;  dstA = SR;  RW = 1; IW6 = 1; #CLK_PERIOD;
    srcA = CG2; dstA = CG2; RW = 1; IW6 = 1; #CLK_PERIOD;
    srcA = R4;  dstA = R4;  RW = 1; IW6 = 1; #CLK_PERIOD; RW = 0;

    /* Test generic src, dst read */
    for (integer i = 0; i < 16; i = i + 1) begin
        srcA = i;
        dstA = i % 16; #CLK_PERIOD;
    end

    /* Test INTACK SR reset */
    INTACK = 1; #CLK_PERIOD; INTACK = 0;

    /* Test src, dst autoincrememnt - word */
    srcA = PC;  IW6 = 0; srcInc = 1; #CLK_PERIOD;
    srcA = SP;  IW6 = 0; srcInc = 1; #CLK_PERIOD;
    srcA = SR;  IW6 = 0; srcInc = 1; #CLK_PERIOD;
    srcA = CG2; IW6 = 0; srcInc = 1; #CLK_PERIOD;
    srcA = R4;  IW6 = 0; srcInc = 1; #CLK_PERIOD; srcInc = 0;

    dstA = PC;  IW6 = 0; dstInc = 1; #CLK_PERIOD;
    dstA = SP;  IW6 = 0; dstInc = 1; #CLK_PERIOD;
    dstA = SR;  IW6 = 0; dstInc = 1; #CLK_PERIOD;
    dstA = CG2; IW6 = 0; dstInc = 1; #CLK_PERIOD;
    dstA = R4;  IW6 = 0; dstInc = 1; #CLK_PERIOD; dstInc = 0;

    /* Test src, dst autoincrememnt - byte */
    srcA = PC;  IW6 = 1; srcInc = 1; #CLK_PERIOD;
    srcA = SP;  IW6 = 1; srcInc = 1; #CLK_PERIOD;
    srcA = SR;  IW6 = 1; srcInc = 1; #CLK_PERIOD;
    srcA = CG2; IW6 = 1; srcInc = 1; #CLK_PERIOD;
    srcA = R4;  IW6 = 1; srcInc = 1; #CLK_PERIOD; srcInc = 0;

    dstA = PC;  IW6 = 1; dstInc = 1; #CLK_PERIOD;
    dstA = SP;  IW6 = 1; dstInc = 1; #CLK_PERIOD;
    dstA = SR;  IW6 = 1; dstInc = 1; #CLK_PERIOD;
    dstA = CG2; IW6 = 1; dstInc = 1; #CLK_PERIOD;
    dstA = R4;  IW6 = 1; dstInc = 1; #CLK_PERIOD; dstInc = 0;

    /* Test reset entry */
    rst = 1; #(3*CLK_PERIOD);

    $finish(0);
end
endmodule
`default_nettype wire
