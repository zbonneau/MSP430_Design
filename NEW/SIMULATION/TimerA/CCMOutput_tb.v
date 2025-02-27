/*--------------------------------------------------------
    Module Name : CCMOutput Testbench
    Description:
        Verifies Functionality of the CCMOutput

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_CCMOutput;
reg TimerClock, reset;
reg wOUT, EQU0, EQUn;
reg [2:0] OUTMOD;
wire OUTn;

`include "NEW/PARAMS.v"

initial begin {TimerClock, reset, wOUT, EQU0, EQUn, OUTMOD} = 0; end

CCMOutput uut
(
    .TimerClock(TimerClock), .reset(reset), 
    .wOUT(wOUT), .EQU0(EQU0), .EQUn(EQUn), 
    .OUTMOD(OUTMOD), 
    .OUTn(OUTn)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) TimerClock = ~TimerClock;

initial begin
    $dumpfile("CCMOutput.vcd");
    $dumpvars(0, tb_CCMOutput);
end

initial begin
    /* Test OUTMOD 0 */
    OUTMOD = OUTMOD__OUT;
    #(3);
    wOUT = 1; #(14) 
    `PULSE(reset)
    #(15);
    wOUT = 0;
    #10;

    // Synchronize to TimerClock
    @(negedge TimerClock); 

    /* Test OUTMOD 1 */
    OUTMOD = OUTMOD__SET;
    #(CLK_PERIOD);
    `PULSE(EQUn);
    `PULSE(EQU0);
    `PULSE(reset);

    /* Test OUTMOD 2 */
    OUTMOD = OUTMOD__TOG_RST;
    #(CLK_PERIOD);
    `PULSE(EQU0)
    `PULSE(EQUn)
    `PULSE(EQU0)
    `PULSE(EQUn)
    `PULSE(EQUn)
    `PULSE(EQUn)
    `PULSE(reset);

    /* Test OUTMOD 3 */
    OUTMOD = OUTMOD__SET_RST;
    `PULSE(EQU0)
    `PULSE(EQUn)
    `PULSE(EQUn)
    `PULSE(EQU0)
    `PULSE(EQUn)
    `PULSE(reset);

    /* Test OUTMOD 4 */
    OUTMOD = OUTMOD__TOG;
    `PULSE(EQUn)
    `PULSE(EQU0)
    `PULSE(EQUn)
    `PULSE(EQUn)
    `PULSE(reset);

    /* Test OUTMOD 5 */
    OUTMOD = OUTMOD__RST;
    uut.OutQ = 1;
    #(CLK_PERIOD);
    `PULSE(EQU0)
    `PULSE(EQUn)
    uut.OutQ = 1; 
    #(CLK_PERIOD);
    `PULSE(reset);

    /* Test OUTMOD 6 */
    OUTMOD = OUTMOD__TOG_SET;
    `PULSE(EQU0)
    `PULSE(EQU0)
    `PULSE(EQUn)
    `PULSE(EQUn)
    `PULSE(reset);

    /* Test OUTMOD 7 */
    OUTMOD = OUTMOD__RST_SET;
    `PULSE(EQU0)
    `PULSE(EQU0)
    `PULSE(EQUn)
    `PULSE(EQUn)
    `PULSE(EQU0)
    `PULSE(reset);

    $finish(0);
end
endmodule
`default_nettype wire
