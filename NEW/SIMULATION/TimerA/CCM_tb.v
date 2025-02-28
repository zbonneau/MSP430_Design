/*--------------------------------------------------------
    Module Name : CCM Testbench
    Description:
        Verifies Functionality of the CCM

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_CCM;
reg MCLK, TimerClock, reset;
reg [15:0] MAB, MDBwrite;
reg MW, BW;
reg [15:0] TAxRcurrent;
reg EQU0, CCIFGclr;
reg CCInA, CCInB;
wire CCIFGn, CCIEn, OUTn, EQUn;
wire [15:0] MDBread;

`include "NEW/PARAMS.v"

initial begin 
    {MCLK, TimerClock, reset, MAB, MDBwrite} = 0;
    {MW, BW, TAxRcurrent, EQU0, CCIFGclr, CCInA, CCInB} = 0; 
end

CCM #(
    .CCRx(TA0CCR1),
    .CCTLx(TA0CCTL1)
    )uut(
    .MCLK(MCLK), .TimerClock(TimerClock), .reset(reset), 
    .MAB(MAB), .MDBwrite(MDBwrite), .MW(MW), .BW(BW), 
    .TAxRcurrent(TAxRcurrent), .EQU0(EQU0), 
    .CCIFGclr(CCIFGclr), .CCInA(CCInA), .CCInB(CCInB), 
    .CCIFGn(CCIFGn), .CCIEn(CCIEn), 
    .OUTn(OUTn), .EQUn(EQUn), 
    .MDBread(MDBread)
);

localparam MCLK_PERIOD = 10;
localparam TCLK_PERIOD = 30;
always #(MCLK_PERIOD/2) MCLK = ~MCLK;
always #(TCLK_PERIOD/2) TimerClock = ~TimerClock;

/* Simulate timer in up mode */
always @(posedge TimerClock) begin
    TAxRcurrent <= TAxRcurrent + 1;
end

initial begin
    $dumpfile("CCM.vcd");
    $dumpvars(0, tb_CCM);
end

initial begin
    `PULSE(reset) // reset device prevents CCIFGset on power on

    /* Memory Write to CCTL1, configure for compare and output set/reset */
    MAB = TA0CCTL1; MW = 1; MDBwrite = 16'h0070; #MCLK_PERIOD;
    MAB = TA0CCR1; MW = 1; MDBwrite = 16'hFF20; `PULSE(BW)
    MAB = 0; MW = 0; MDBwrite = 0;

    /* Trigger CCIFG, set output */
    @(posedge CCIFGn);
    #(3*TCLK_PERIOD + 2)

    /* Trigger EQU0, delayed 200 ns, reset output */
    `PULSE_DELAY(EQU0, TCLK_PERIOD)

    /* Clear CCIFG on IV read */
    @(negedge MCLK); // synchronize
    `PULSE(CCIFGclr)

    $finish(0);
end
endmodule
`default_nettype wire
