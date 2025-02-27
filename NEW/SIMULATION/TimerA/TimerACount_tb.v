/*--------------------------------------------------------
    Module Name : TimerACount Testbench
    Description:
        Verifies Functionality of the TimerACount

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_TimerACount;
reg TimerClock;
reg wTACLR, reset;
reg [1:0] MC;
reg EQU0;
reg [15:0] TAxRcurrent;
wire [15:0] TAxRnew;
wire TAIFGset;

`include "NEW/PARAMS.v"

initial begin {TimerClock, wTACLR, reset, MC, EQU0, TAxRcurrent} = 0; end

TimerACount uut
(
.TimerClock(TimerClock), 
.wTACLR(wTACLR), .reset(reset), 
.MC(MC), .EQU0(EQU0), 
.TAxRcurrent(TAxRcurrent), .TAxRnew(TAxRnew), 
.TAIFGset(TAIFGset)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) TimerClock = ~TimerClock;

initial begin
    $dumpfile("TimerACount.vcd");
    $dumpvars(0, tb_TimerACount);
end

initial begin
    /* MC == STOP */
    `PULSE_VAL(TAxRcurrent, 0)
    `PULSE_VAL(TAxRcurrent, 10)
    `PULSE_VAL(TAxRcurrent, 16'hFFFF)
    `PULSE(EQU0)
    `PULSE(wTACLR)
    `PULSE(reset)

    /* MC == UP */
    MC = MC__UP;
    `PULSE_VAL(TAxRcurrent, 0)
    `PULSE_VAL(TAxRcurrent, 10)
    `PULSE_VAL(TAxRcurrent, 16'hFFFF)
    TAxRcurrent = 1000;
    `PULSE(EQU0)
    `PULSE(wTACLR)
    `PULSE(reset)

    /* MC == CONTINUOUS */
    MC = MC__CONTINUOUS;
    `PULSE_VAL(TAxRcurrent, 0)
    `PULSE_VAL(TAxRcurrent, 10)
    `PULSE_VAL(TAxRcurrent, 16'hFFFF)
    TAxRcurrent = 1000;
    `PULSE(EQU0)
    `PULSE(wTACLR)
    `PULSE(reset)
    
    /* MC == UPDOWN */
    MC = MC__UPDOWN;
    `PULSE_VAL(TAxRcurrent, 0)
    `PULSE_VAL(TAxRcurrent, 10)
    `PULSE_VAL(TAxRcurrent, 16'hFFFF)
    `PULSE_VAL(TAxRcurrent, 10)
    `PULSE_VAL(TAxRcurrent, 0)
    TAxRcurrent = 1000;
    `PULSE(EQU0)
    `PULSE(wTACLR)
    `PULSE(reset)



    $finish(0);
end
endmodule
`default_nettype wire
