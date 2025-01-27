/*--------------------------------------------------------
    Module Name : OperandFetch Testbench
    Description:
        Verifies operation of the operand fetch module

--------------------------------------------------------*/

`include "NEW\\OperandFetch.v"
`default_nettype none
`timescale 100ns/100ns

module tb_OperandFetch;
reg clk, rst;

reg [15:0] Rsrc, Rdst, MDB;
reg srcM, srcL, dstM, dstL;
reg [1:0] AddrM;
reg AddrL, IdxM;
wire [15:0] OpSrc, OpDst, MAB;

initial begin  
    {clk, rst, Rsrc,Rdst, MDB, srcM, srcL, 
    dstM, dstL, AddrM, AddrL, IdxM} = 0; 

    Rsrc = 40;
    Rdst = 80;
    MDB  = 120;
    end

OperandFetch uut
(
.clk(clk), .rst(rst),
.Rsrc(Rsrc),   .Rdst(Rdst),   .MDB(MDB),
.srcM(srcM),   .srcL(srcL),   .dstM(dstM), .dstL(dstL),
.AddrM(AddrM), .AddrL(AddrL), .IdxM(IdxM),
.OpSrc(OpSrc), .OpDst(OpDst), .MAB(MAB)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    $dumpfile("OperandFetch.vcd");
    $dumpvars(0, tb_OperandFetch);
end

initial begin
    /* Test src logic */
    rst = 1; #CLK_PERIOD; rst = 0;

    srcM = 0; #CLK_PERIOD;
    srcM = 1; #CLK_PERIOD;
    srcL = 1; #CLK_PERIOD;
    srcM = 0; srcL = 0;

    /* Test dst logic */
    dstM = 0; #CLK_PERIOD;
    dstL = 1; #CLK_PERIOD;
    dstM = 1; dstL = 0; #CLK_PERIOD;
    dstL = 1; #CLK_PERIOD;
    dstM = 0; dstL = 0; 

    /* Test Address logic */
    IdxM = 0; AddrM = 0; AddrL = 1; #CLK_PERIOD;
    IdxM = 1; #CLK_PERIOD;
    IdxM = 0; AddrM = 3; #CLK_PERIOD;
    AddrL = 0; AddrM = 2; #CLK_PERIOD;
    AddrM = 1; #CLK_PERIOD;
    AddrM = 0; #CLK_PERIOD;

    /* Test Reset Condition */
    rst = 1; #CLK_PERIOD; rst = 0;

    $finish(0);
end
endmodule
`default_nettype wire
