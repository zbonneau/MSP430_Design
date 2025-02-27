/*--------------------------------------------------------
    Module Name : TimerAINT Testbench
    Description:
        Verifies Functionality of the TimerAINT

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_TimerAINT;
localparam CCM_COUNT = 7;
reg wTAIFG, wTAIE;
reg [CCM_COUNT-1:0] wCCIFG, wCCIE;
reg [3:0] TAxIVcurrent;
reg TAxIVread, TAxCLR0;
wire [3:0] TAxIVnew;
wire TAxINT1, TAxINT0;
wire TAIFGclr;
wire [CCM_COUNT-1:0] CCIFGclr;

`include "NEW/PARAMS.v"

initial begin {wTAIFG, wTAIE, wCCIFG, wCCIE, TAxIVcurrent, TAxIVread, TAxCLR0} = 0; end

TimerAINT #(
    .CCM_COUNT(CCM_COUNT)
 )uut(
    .wTAIFG(wTAIFG), .wTAIE(wTAIE), 
    .wCCIFG(wCCIFG), .wCCIE(wCCIE), 
    .TAxIVcurrent(TAxIVcurrent), 
    .TAxIVread(TAxIVread), 
    .TAxCLR0(TAxCLR0), 
    .TAxIVnew(TAxIVnew), 
    .TAxINT1(TAxINT1), .TAxINT0(TAxINT0), 
    .TAIFGclr(TAIFGclr), .CCIFGclr(CCIFGclr)
);

localparam CLK_PERIOD = 10;
reg clk = 0;
always #(CLK_PERIOD/2) clk = ~clk;
always @(posedge clk) TAxIVcurrent = TAxIVnew;

initial begin
    $dumpfile("TimerAINT.vcd");
    $dumpvars(0, tb_TimerAINT);
end

initial begin
    // Test IV sets. Enable all interrupts
    wCCIE = ~0; wTAIE = 1;

    wTAIFG = 1; #CLK_PERIOD;
    wCCIFG[6] = 1; #CLK_PERIOD;
    wCCIFG[5] = 1; #CLK_PERIOD;
    wCCIFG[4] = 1; #CLK_PERIOD;
    wCCIFG[3] = 1; #CLK_PERIOD;
    wCCIFG[2] = 1; #CLK_PERIOD;
    wCCIFG[1] = 1; #CLK_PERIOD;

    // Disable Interrupts
    wCCIE[1] = 0; #CLK_PERIOD;
    wCCIE[2] = 0; #CLK_PERIOD;
    wCCIE[3] = 0; #CLK_PERIOD;
    wCCIE[4] = 0; #CLK_PERIOD;
    wCCIE[5] = 0; #CLK_PERIOD;
    wCCIE[6] = 0; #CLK_PERIOD;
    wTAIE = 0; #CLK_PERIOD;


    // Trigger INT0
    wCCIFG[0] = 1; #CLK_PERIOD;

    // Disable INT0
    wCCIE[0] = 0; #CLK_PERIOD;

    // Enable INTS
    wCCIE = ~0; wTAIE = 1;

    // Clear INTS by reading IV
    `PULSE(TAxCLR0)
    wCCIFG[0] = 0;

    TAxIVread = 1; #(CLK_PERIOD/2);

    wCCIFG[1] = 0; #CLK_PERIOD;
    wCCIFG[2] = 0; #CLK_PERIOD;
    wCCIFG[3] = 0; #CLK_PERIOD;
    wCCIFG[4] = 0; #CLK_PERIOD;
    wCCIFG[5] = 0; #CLK_PERIOD;
    wCCIFG[6] = 0; #CLK_PERIOD;
    wTAIFG = 0; #(CLK_PERIOD/2);

    $finish(0);
end
endmodule
`default_nettype wire
