/*--------------------------------------------------------
    Module Name : TimerA PreDiv Testbench
    Description:
        Verifies Functionality of the TimerA prediv

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_TimerA_PreDiv;
reg TAxCLK, ACLK, SMCLK, INCLK;
reg reset, wTACLR;
reg [1:0] TASSEL;
reg [1:0] ID;
reg [2:0] IDEX;

wire TimerClock;
integer i = 0;

`include "NEW/PARAMS.v"

initial begin 
    {TAxCLK, ACLK, SMCLK, INCLK, reset, wTACLR, TASSEL, ID, IDEX} = 0; 
end

TimerA_PreDiv uut
(
.TAxCLK(TAxCLK), .ACLK(ACLK), .SMCLK(SMCLK), .INCLK(INCLK), 
.reset(reset), .wTACLR(wTACLR), 
.TASSEL(TASSEL), .ID(ID), .IDEX(IDEX), 
.TimerClock(TimerClock)
);

localparam TACLK_PERIOD = 14;
localparam ACLK_PERIOD  = 23;
localparam SMCLK_PERIOD = 10;
localparam INCLK_PERIOD = 31;
always #(TACLK_PERIOD/2)    TAxCLK = ~TAxCLK;
always #(ACLK_PERIOD/2)     ACLK   = ~ACLK;
always #(SMCLK_PERIOD/2)    SMCLK  = ~SMCLK;
always #(INCLK_PERIOD/2)    INCLK  = ~INCLK;


initial begin
    $dumpfile("TimerA_PreDiv.vcd");
    $dumpvars(0, tb_TimerA_PreDiv);
end

initial begin
    // Default clock division on reset
    // TACLK, no division
    #(10*TACLK_PERIOD);

    // ACLK, no division
    TASSEL = TASSEL__ACLK;
    #(10*ACLK_PERIOD);

    // SMCLK, no division
    TASSEL = TASSEL__SMCLK;
    #(10*SMCLK_PERIOD);

    // INCLK, no division
    TASSEL = TASSEL__INCLK;
    #(10*INCLK_PERIOD);

    // SMCLK, sweep through division
    TASSEL = TASSEL__SMCLK;
    
    for (i=0; i < 1<<5; i = i + 1) begin
        {ID, IDEX} = i; `PULSE(wTACLR)
        @(negedge TimerClock);
        // #(2*SMCLK_PERIOD);
        // #(64*SMCLK_PERIOD);
    end

    // TACLR in middle of count
    {ID, IDEX} = 5'b11_111;
    #(20*SMCLK_PERIOD);

    `PULSE(wTACLR);

    // reset in middle of count
    #(20*SMCLK_PERIOD);
    `PULSE(reset);
    #(20*SMCLK_PERIOD);

    $finish(0);
end
endmodule
`default_nettype wire
