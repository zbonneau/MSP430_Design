/*--------------------------------------------------------
    Module Name : Constant Generator Testbench
    Description:
        Verifies the Constant Generator module

--------------------------------------------------------*/

// `include "NEW\\ConstantGenerator.v"
`default_nettype none
`timescale 100ns/100ns

module tb_ConstantGenerator;
reg         Format;
reg [3:0]   srcA;
reg [1:0]   As;
reg [3:0]   dstA;
reg         Ad;
wire [15:0] src, dst;
wire srcGenerated, dstGenerated;

`include "NEW\\PARAMS.v"

initial begin {Format, srcA, As, dstA, Ad} = 0; end

ConstantGenerator uut
(
    .Format(Format),
    .srcA(srcA), .As(As),    
    .dstA(dstA), .Ad(Ad),    
    .src(src), .dst(dst),    
    .srcGenerated(srcGenerated),    
    .dstGenerated(dstGenerated)     
);

localparam CLK_PERIOD = 10;

initial begin
    $display("| F | srcA | As | dstA | Ad ||| src  | G | dst  | G |");
    $display("|---|------|----|------|----|||------|---|------|---|");
    $monitor("| %1b |  %1h   | %2b |  %1h   | %1b  ||| %4h | %1b | %4h | %1b |",
              Format, srcA, As, dstA, Ad, src, srcGenerated, dst, dstGenerated);
end

initial begin
    // 2-op instructions
    Format = 0;
    srcA = R4 ; As = 00; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    srcA = R4 ; As = 01; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    srcA = R4 ; As = 10; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    srcA = R4 ; As = 11; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    srcA = CG1; As = 00; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    srcA = CG1; As = 01; dstA = CG1; Ad = 0; #CLK_PERIOD; 
    srcA = CG1; As = 10; dstA = CG1; Ad = 1; #CLK_PERIOD; 
    srcA = CG1; As = 11; dstA = CG2; Ad = 0; #CLK_PERIOD; 
    srcA = CG2; As = 00; dstA = CG2; Ad = 1; #CLK_PERIOD; 
    srcA = CG2; As = 01; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    srcA = CG2; As = 10; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    srcA = CG2; As = 11; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    // 1-op instructions
    Format = 1;
    srcA = CG1; As = 00; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    srcA = CG1; As = 01; dstA = R5 ; Ad = 1; #CLK_PERIOD; 
    srcA = CG2; As = 10; dstA = R5 ; Ad = 0; #CLK_PERIOD; 
    srcA = CG2; As = 11; dstA = R5 ; Ad = 1; #CLK_PERIOD; 
    srcA = R0 ; As = 00; dstA = CG1; Ad = 0; #CLK_PERIOD; 
    srcA = R0 ; As = 01; dstA = CG1; Ad = 1; #CLK_PERIOD; 
    srcA = R0 ; As = 10; dstA = CG1; Ad = 0; #CLK_PERIOD; 
    srcA = R0 ; As = 11; dstA = CG1; Ad = 1; #CLK_PERIOD; 
    srcA = R0 ; As = 00; dstA = CG2; Ad = 0; #CLK_PERIOD; 
    srcA = R0 ; As = 01; dstA = CG2; Ad = 1; #CLK_PERIOD; 
    srcA = R0 ; As = 10; dstA = CG2; Ad = 0; #CLK_PERIOD; 
    srcA = R0 ; As = 11; dstA = CG2; Ad = 1; #CLK_PERIOD; 

    $display("|---|------|----|------|----|||------|---|------|---|");
    $finish(0);
end

endmodule
`default_nettype wire
