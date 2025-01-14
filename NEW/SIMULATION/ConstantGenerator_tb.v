/*--------------------------------------------------------
    Module Name : Constant Generator Testbench
    Description:
        Verifies the Constant Generator module

--------------------------------------------------------*/

`include "NEW\\ConstantGenerator.v"
`default_nettype none
`timescale 100ns/100ns

module tb_ConstantGenerator;
reg [15:0]  IW;
reg [3:0]   srcA;
reg [1:0]   As;
reg [3:0]   dstA;
reg         Ad;
wire [15:0] src, dst;
wire srcGenerated, dstGenerated;

`include "NEW\\MACROS.v"

initial begin {IW, srcA, As, dstA, Ad} = 0; end

ConstantGenerator uut
(
    .IW(IW),
    .srcA(srcA), .As(As),    
    .dstA(dstA), .Ad(Ad),    
    .src(src), .dst(dst),    
    .srcGenerated(srcGenerated),    
    .dstGenerated(dstGenerated)     
);

localparam CLK_PERIOD = 10;

initial begin
    $dumpfile("tb_ConstantGenerator.vcd");
    $dumpvars(0, tb_ConstantGenerator);
end

initial begin
    // 2-op instructions
    IW = MOV; srcA = R4 ; As = 00; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    IW = MOV; srcA = R4 ; As = 01; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    IW = MOV; srcA = R4 ; As = 10; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    IW = MOV; srcA = R4 ; As = 11; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    IW = MOV; srcA = CG1; As = 00; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    IW = MOV; srcA = CG1; As = 01; dstA = CG1; Ad = 0; #CLK_PERIOD; 
    IW = MOV; srcA = CG1; As = 10; dstA = CG1; Ad = 1; #CLK_PERIOD; 
    IW = MOV; srcA = CG1; As = 11; dstA = CG2; Ad = 0; #CLK_PERIOD; 
    IW = MOV; srcA = CG2; As = 00; dstA = CG2; Ad = 1; #CLK_PERIOD; 
    IW = MOV; srcA = CG2; As = 01; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    IW = MOV; srcA = CG2; As = 10; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    IW = MOV; srcA = CG2; As = 11; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    // 1-op instructions
    IW = RRC; srcA = CG1; As = 00; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    IW = RRC; srcA = CG1; As = 01; dstA = R5 ; Ad = 1; #CLK_PERIOD; 
    IW = RRC; srcA = CG2; As = 10; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    IW = RRC; srcA = CG2; As = 11; dstA = R5 ; Ad = 1; #CLK_PERIOD; 
    IW = RRC; srcA = R0 ; As = 00; dstA = CG1; Ad = 0; #CLK_PERIOD; 
    IW = RRC; srcA = R0 ; As = 01; dstA = CG1; Ad = 1; #CLK_PERIOD; 
    IW = RRC; srcA = R0 ; As = 10; dstA = CG1; Ad = 0; #CLK_PERIOD; 
    IW = RRC; srcA = R0 ; As = 11; dstA = CG1; Ad = 1; #CLK_PERIOD; 
    IW = RRC; srcA = R0 ; As = 00; dstA = CG2; Ad = 0; #CLK_PERIOD; 
    IW = RRC; srcA = R0 ; As = 01; dstA = CG2; Ad = 1; #CLK_PERIOD; 
    IW = RRC; srcA = R0 ; As = 10; dstA = CG2; Ad = 0; #CLK_PERIOD; 
    IW = RRC; srcA = R0 ; As = 11; dstA = CG2; Ad = 1; #CLK_PERIOD; 

    $finish(0);
end

endmodule
`default_nettype wire
