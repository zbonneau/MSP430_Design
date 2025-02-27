/*--------------------------------------------------------
    Module Name : TimerABase Testbench
    Description:
        Verifies Functionality of the TimerABase

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_TimerABase;
reg  MCLK, TACLK, ACLK, SMCLK, INCLK, reset;
reg  [15:0] MAB, MDBwrite;
reg  MW, BW, EQU0, TAIFGclr;
wire TimerClock;
wire [15:0] TAxRcurrent;
wire wTAIFG, wTAIE;
wire [15:0] MDBread;

`include "NEW/PARAMS.v"

initial begin 
    {MCLK, TACLK, ACLK, SMCLK, INCLK, reset, MAB, MDBwrite, MW, BW, EQU0, TAIFGclr} = 0; 
end

TimerABase uut
(
    .MCLK(MCLK), .TACLK(TACLK), .ACLK(ACLK), .SMCLK(SMCLK), .INCLK(INCLK), 
    .reset(reset), 
    .MAB(MAB), .MDBwrite(MDBwrite), 
    .MW(MW), .BW(BW), 
    .EQU0(EQU0), .TAIFGclr(TAIFGclr), 
    .TimerClock(TimerClock), 
    .TAxRcurrent(TAxRcurrent), 
    .wTAIFG(wTAIFG), .wTAIE(wTAIE), 
    .MDBread(MDBread)
);

localparam CLK_PERIOD = 10;
localparam TACLK_PERIOD = 100;
localparam ACLK_PERIOD = 50;
localparam SMCLK_PERIOD = 10;
localparam INCLK_PERIOD = 67;
always #(CLK_PERIOD/2)   MCLK = ~MCLK;
always #(TACLK_PERIOD/2) TACLK = ~TACLK;
always #(ACLK_PERIOD/2)  ACLK  = ~ACLK;
always #(SMCLK_PERIOD/2) SMCLK = ~SMCLK;
always #(INCLK_PERIOD/2) INCLK = ~INCLK;

initial begin
    $dumpfile("TimerABase.vcd");
    $dumpvars(0, tb_TimerABase);
end

initial begin
    // Setup Timer for up mode using MWs
    MW = 1; MAB = TA0EX0; MDBwrite = 4; #CLK_PERIOD;
    MAB = TA0R; MDBwrite = 16'hFFFF; `PULSE(BW) // test Byte
    MAB = TA0CTL; MDBwrite = 16'h0254; #CLK_PERIOD;

    MW = 0; MAB = 0; MDBwrite = 0;

    // Timer counting up.
    #(300*SMCLK_PERIOD)

    // Trigger a set
    EQU0 = 1;
    @(posedge TimerClock);

    EQU0 = 0;

    // INT1 Set by TAIFG
    #(3*CLK_PERIOD)

    // Clear by read IV
    `PULSE(TAIFGclr);
    #(2*CLK_PERIOD);

    // Reset Device
    `PULSE(reset)

    // Setup Timer for continuous mode using MWs
    MW = 1; MAB = TA0EX0; MDBwrite = 4; #CLK_PERIOD;
    MAB = TA0R; MDBwrite = 16'hFFFF; `PULSE(BW) // test Byte
    MAB = TA0CTL; MDBwrite = 16'h0264; #CLK_PERIOD;
    MW = 0; MAB = 0; MDBwrite = 0;

    // Timer counting up.
    #(300*SMCLK_PERIOD)

    // Trigger a set
    EQU0 = 1;
    @(posedge TimerClock);
    EQU0 = 0;

    // Force Timer value to FFF8
    @(negedge MCLK);
    MAB = TA0R; MDBwrite = 16'hFFF8; `PULSE(MW) // test Byte
    MAB = 0; MDBwrite = 0;    

    @(wTAIFG)
    #(3*CLK_PERIOD)

    // Clear by read IV
    `PULSE(TAIFGclr);
    #(2*CLK_PERIOD);
    
    // Reset Device
    `PULSE(reset)

    // Setup Timer for updown mode using MWs
    MW = 1; MAB = TA0EX0; MDBwrite = 4; #CLK_PERIOD;
    MAB = TA0R; MDBwrite = 16'hFFFF; `PULSE(BW) // test Byte
    MAB = TA0CTL; MDBwrite = 16'h0274; #CLK_PERIOD;
    MW = 0; MAB = 0; MDBwrite = 0;

    // Timer counting up.
    #(300*SMCLK_PERIOD)

    // Trigger Set
    EQU0 = 1;
    @(posedge TimerClock);
    EQU0 = 0;

    // Timer counting down
    @(wTAIFG)
    #(3*CLK_PERIOD)

    // Clear by read IV
    `PULSE(TAIFGclr);
    #(2*CLK_PERIOD);

    $finish(0);
end
endmodule
`default_nettype wire
