/*--------------------------------------------------------
    Module Name : BRGPrescaler Testbench
    Description:
        Verifies Functionality of the BRGPrescaler

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_BRGPrescaler;

`include "NEW/PARAMS.v"

reg BRCLK, UCABEN;
reg [15:0] wUC0BRx;
reg m1,m2;
wire ScaleCLK;

integer i;

initial begin {BRCLK, UCABEN, wUC0BRx, m1, m2} = 0; end

BRGPrescaler uut
(
    .BRCLK(BRCLK), .UCABEN(UCABEN), 
    .wUC0BRx(wUC0BRx), 
    .m1(m1), .m2(m2), 
    .ScaleCLK(ScaleCLK)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) BRCLK = ~BRCLK;

initial begin
    $dumpfile("BRGPrescaler.vcd");
    $dumpvars(0, tb_BRGPrescaler);
end

initial begin
    wUC0BRx = 1; {m1,m2} = 0; #CLK_PERIOD;
    UCABEN = 1;
    
    for (i=0; i<4; i = i + 1) begin
        {m1,m2} = i;
        #(6*CLK_PERIOD);
        @(negedge ScaleCLK);
    end

    #CLK_PERIOD;

    wUC0BRx = 3; {m1,m2} = 0; UCABEN = 0; #CLK_PERIOD;
    UCABEN = 1;

    for (i=0; i < 4; i = i+1) begin
        {m1,m2} = i;
        #(6*CLK_PERIOD);
        @(negedge ScaleCLK);
    end
    
    #CLK_PERIOD;

    wUC0BRx = 6; {m1,m2} = 0; UCABEN = 0; #CLK_PERIOD;
    UCABEN = 1;

    for (i=0; i < 4; i = i+1) begin
        {m1,m2} = i;
        #(6*CLK_PERIOD);
        @(negedge ScaleCLK);
    end
    
    #(10*CLK_PERIOD);
    UCABEN = 0;
    #(3*CLK_PERIOD);
    
    $finish(0);
end
endmodule
`default_nettype wire
