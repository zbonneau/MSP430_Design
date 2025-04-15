/*--------------------------------------------------------
    Module Name : BaudRateGenerator Testbench
    Description:
        Verifies Functionality of the BaudRateGenerator

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/1ns

`define runTest(BAUD, OS, BR, F, S, expected) begin \
    runBRG(BR, F, S, OS, actual); \
    error = ((expected) - actual) / (expected) * 100.0; \
    // $display("actual: %f \nexpected: %f \nerror: %f", actual, expected, error); \
    $display("%6d |    %b   | %4h |  %2d  |  %2h  | %.2f", BAUD, OS, BR, F, S, error); \
end

module tb_BaudRateGenerator;
wire BRCLK;
reg UCABEN;
reg [15:0] wUC0BRx; // clock prescaler
reg [3:0]  wUCBRFx; // first mod stage for BITCLK16
reg [7:0]  wUCBRSx; // second mod stage for BITCLK
reg        wUCOS16;

wire       BITCLK, MajorityClk;

`include "NEW/PARAMS.v"

initial begin {UCABEN, wUC0BRx, wUCBRFx, wUCBRSx, wUCOS16} = 0; end

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

reg SMCLK = 0;
reg ACLK = 0;
reg SSEL = 0;
localparam SMCLK_P = 10.00;
localparam ACLK_P  = 305.18;
always #(SMCLK_P/2) SMCLK = ~SMCLK;
always #(ACLK_P/2) ACLK = ~ACLK;
assign BRCLK = SSEL ? ACLK : SMCLK;

initial begin
    // $dumpfile("BaudRateGenerator.vcd");
    // $dumpvars(0, tb_BaudRateGenerator);
    $display("  BAUD | UCOS16 | BRSx | BRFx | BRSx | error");
end

realtime error, actual;

initial begin
    // Configure Device for each row of FUG table 30-5

    SSEL = 1;
    `runTest(1200, 1'b1, 16'd1, 8'd11, 8'h25, 11.0/1200*10_000_000)
    `runTest(2400, 1'b0, 16'd13, 8'd0, 8'hB6, 11.0/1200*10_000_000)
    `runTest(4800, 1'b0, 16'd6, 8'd0, 8'hEE, 11.0/4800*10_000_000)
    `runTest(9600, 1'b0, 16'd3, 8'd0, 8'h92, 11.0/9600*10_000_000)
    SSEL = 0;
    `runTest(9600, 1'b1, 16'd6, 8'd8, 8'h20, 11.0/9600*10_000_000)
    `runTest(19200, 1'b1, 16'd3, 8'd4, 8'h02, 11.0/19200*10_000_000)
    `runTest(38400, 1'b1, 16'd1, 8'd10, 8'h0, 11.0/38400*10_000_000)
    `runTest(57600, 1'b0, 16'd17, 8'd0, 8'h4A, 11.0/57600*10_000_000)
    `runTest(115200, 1'b0, 16'd8, 8'd0, 8'hD6, 11.0/115200*10_000_000)
    
    $finish(0);
end

task runBRG;
    input [15:0] BRx;
    input [3:0] BRF;
    input [7:0] BRS;
    input       OS16;
    output realtime TimeElapse;
    integer i;
    realtime Start, Stop;
    begin
        UCABEN = 0;
        @(posedge BRCLK)
        wUCOS16 = OS16;
        wUC0BRx = BRx;
        wUCBRFx = BRF;
        wUCBRSx = BRS;
        
        @(posedge BRCLK) UCABEN = 1;

        Start = $time;
        // wait 11 bit times
        for (i=0; i < 11; i = i + 1) @(negedge BITCLK);
        UCABEN = 0;
        Stop = $time;
        TimeElapse = Stop - Start;
    end
endtask
endmodule
`default_nettype wire
