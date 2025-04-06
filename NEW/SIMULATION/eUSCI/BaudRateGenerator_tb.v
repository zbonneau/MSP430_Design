/*--------------------------------------------------------
    Module Name : BaudRateGenerator Testbench
    Description:
        Verifies Functionality of the BaudRateGenerator

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/1ns

module tb_BaudRateGenerator;
reg BRCLK, UCABEN;
reg [15:0] wUC0BRx; // clock prescaler
reg [3:0]  wUCBRFx; // first mod stage for BITCLK16
reg [7:0]  wUCBRSx; // second mod stage for BITCLK
reg        wUCOS16;

wire       BITCLK, MajorityClk;

`include "NEW/PARAMS.v"

initial begin {BRCLK, UCABEN, wUC0BRx, wUCBRFx, wUCBRSx, wUCOS16} = 0; end

BaudRateGenerator uut
(
    .BRCLK(BRCLK), .UCABEN(UCABEN), 
    .wUC0BRx(wUC0BRx), 
    .wUCBRFx(wUCBRFx),
    .wUCBRSx(wUCBRSx),
    .wUCOS16(wUCOS16),
    .BITCLK(BITCLK),
    .MajorityClk(MajorityClk)
);

localparam CLK_PERIOD = 305.18;
always #(CLK_PERIOD/2) BRCLK = ~BRCLK;

initial begin
    $dumpfile("BaudRateGenerator.vcd");
    $dumpvars(0, tb_BaudRateGenerator);
end

integer i=0;
integer ACLKcount = 0;
integer start, stop, diff;
real expected, actual;

always @(negedge BRCLK) ACLKcount <= ACLKcount + 1;

initial begin
    // // Configure Device while BEN = 0, as FUG describes
    // // ACLK, 9600 BAUD, N=3, OSC16 = 0, F = -, S = 0x92
    // wUC0BRx = 3;
    // wUCBRFx = 0;
    // wUCBRSx = 8'h92;
    // wUCOS16 = 0;
    
    // #(3.5*CLK_PERIOD);

    // UCABEN = 1;

    // for (i=0; i < 10; i = i + 1) 
    //     @(negedge BITCLK);

    // #(CLK_PERIOD)

    // UCABEN = 0;
    // #(1.5*CLK_PERIOD);
    
    // // Configure Device. SMCLK, BAUD 19200, N=3, F=4, S=0x02, OSC16 = 1
    // wUC0BRx = 3;
    // wUCBRFx = 4;
    // wUCBRSx = 8'h02;
    // wUCOS16 = 1;

    // #(CLK_PERIOD);

    // UCABEN = 1;

    // @(negedge BRCLK);

    // start = $time;
    // for (i=0; i < 10; i = i+1)
    //     @(negedge BITCLK);
    
    // stop = $time;
    // diff = stop-start;

    // expected = 1/19200.0 * 10; 
    // actual = 1e-7 * diff;
    // $display("expected: %f \nactual: %f", expected, actual);
    // $display("error: %f %", (actual-expected)/actual * 100.0);

    UCABEN = 0;
    #(1.5*CLK_PERIOD);

    // Configure device. ACLK, 1200 BAUD, OSC16=1, N=1, F=11, S=0x25
    wUCOS16 = 1;
    wUC0BRx = 1;
    wUCBRFx = 11;
    wUCBRSx = 8'h25;

    #(CLK_PERIOD);
    UCABEN = 1;

    @(negedge BRCLK);
    start = ACLKcount;

    for (i=0; i < 10; i = i+1)
        @(negedge BITCLK);

    stop = ACLKcount;
    diff = stop-start;
    actual = diff / 32768.0;
    expected = 1/1200.0  *10;
    $display(diff);
    $display("expected: %f \nactual: %f", expected, actual);
    $display("error: %f ", (actual-expected)/actual * 100.0);

    $finish(0);
end
endmodule
`default_nettype wire
