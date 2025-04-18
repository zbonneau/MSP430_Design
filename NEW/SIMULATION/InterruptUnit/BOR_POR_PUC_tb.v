/*--------------------------------------------------------
    Module Name : BOR POR PUC Testbench
    Description:
        Verifies Functionality of the BOR

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_BOR_POR_PUC;
reg clk, rst, TEST;
reg INTACKin;
reg [5:0] IntAddrthru;

wire req, INTACKthru, BSLenter;
wire [5:0] IntAddrout;

`include "NEW/PARAMS.v"

initial begin {clk, rst, TEST, INTACKin, IntAddrthru} = 0; end

BOR_POR_PUC uut 
(
.MCLK(clk), .RSTn(rst), .INTACKin(INTACKin), .TEST(TEST),
.IntAddrthru(IntAddrthru), 
.req(req), .INTACKthru(INTACKthru), .BSLenter(BSLenter),
.IntAddrout(IntAddrout)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    $dumpfile("BOR_POR_PUC.vcd");
    $dumpvars(0, tb_BOR_POR_PUC);
end

initial begin
    rst = 1; // active low
    #CLK_PERIOD;
    // #(10*CLK_PERIOD);
    
    // Wait for BOR circuit to finish
    while(req) #CLK_PERIOD;

    // Test IntAddr Feedthrough
    `PULSE_VAL(IntAddrthru, IVT_PORT1)

    // Test INTACK Feedthrough
    `PULSE(INTACKin)

    // Trigger RSTn with regular RESET entrance
    rst = 0; #(3*CLK_PERIOD);
    rst = 1;

    // Test INTACK feedthrough while req active
    `PULSE(INTACKin)

    while(req) #CLK_PERIOD;

    // Test RSTn bounce
    rst = 0; #CLK_PERIOD; 
    `PULSE(rst)#CLK_PERIOD;
    `PULSE(rst)#CLK_PERIOD;
    `PULSE(rst)#CLK_PERIOD;
    rst = 1;

    while (req) #CLK_PERIOD;

    // trigger BSL entrance
    rst = 0; #(4*CLK_PERIOD);
    `PULSE(TEST) #CLK_PERIOD;
    TEST = 1; #CLK_PERIOD;
    rst = 1; #CLK_PERIOD;
    TEST = 0;

    #(12*CLK_PERIOD);

    // fail BSL entrance with only one TEST edge
    rst = 0; #(4*CLK_PERIOD);
    `PULSE(TEST) #CLK_PERIOD;
    rst = 1; 
    #(12*CLK_PERIOD);

    // bounce rst and then trigger BSL
    `PULSEn(rst)
    #(2*CLK_PERIOD);
    `PULSE(TEST)
    #CLK_PERIOD;
    `PULSE_DELAY(TEST, 3*CLK_PERIOD)

    #(12*CLK_PERIOD);

    $finish(0);
end
endmodule
`default_nettype wire
