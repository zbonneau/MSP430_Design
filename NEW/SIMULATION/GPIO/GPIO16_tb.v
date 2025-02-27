/*--------------------------------------------------------
    Module Name : GPIO16 Testbench
    Description:
        Verifies Functionality of the GPIO16

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_GPIO16;
reg clk, rst;
reg [15:0] MAB, MDBwrite;
reg MW, BW;
reg [7:0] PxIN, PyIN;

wire [15:0] MDBread;
wire PxINT, PyINT;
wire [7:0] PxOUT, PxDIR, PxREN, PxSEL0, PxSEL1;
wire [7:0] PyOUT, PyDIR, PyREN, PySEL0, PySEL1;

`include "NEW/PARAMS.v"

initial begin {clk, rst, MAB, MDBwrite, MW, BW, PxIN, PyIN} = 0; end

GPIO16 #(
    .START(MAP_PORTA)
    ) uut (
    .MCLK(clk), .reset(rst),
    .MAB(MAB), .MDBwrite(MDBwrite), 
    .MW(MW), .BW(BW), 
    .PxIN(PxIN), .PyIN(PyIN), 

    .MDBread(MDBread), 
    .PxINT(PxINT), .PyINT(PyINT), 
    .PxOUT(PxOUT), .PxDIR(PxDIR), .PxREN(PxREN), .PxSEL0(PxSEL0), .PxSEL1(PxSEL1), 
    .PyOUT(PyOUT), .PyDIR(PyDIR), .PyREN(PyREN), .PySEL0(PySEL0), .PySEL1(PySEL1)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

`ifdef __ICARUS__
initial begin
    $dumpfile("GPIO16.vcd");
    $dumpvars(0, tb_GPIO16);
    for (integer i = 0; i < 32; i = i+1)
        $dumpvars(1,uut.memory[i]);
end
`endif

initial begin
    // TEST PAIN
    {PyIN, PxIN} = 16'ha55a;

    // TEST Bus read
    MAB = P1IN; BW = 1; #CLK_PERIOD;

    // TEST Bus write to IN
    MAB = P1IN; BW = 0; MW = 1; MDBwrite = 16'hFFFF; #CLK_PERIOD;

    // TEST Bus write to IV
    MAB = P1IV; BW = 0; MW = 1; MDBwrite = 16'hFFFF; #CLK_PERIOD;
    MAB = P2IV; BW = 0; MW = 1; MDBwrite = 16'hFFFF; #CLK_PERIOD;

    // TEST Bus write to valid MMR
    MAB = PADIR; BW = 0; MW = 1; MDBwrite = 16'hFFF9; #CLK_PERIOD; // P1.1/2 are inputs
    MAB = P2DIR; BW = 1; MW = 1; MDBwrite = 16'hFFFF; #CLK_PERIOD; // P1.1/2 are inputs

    // Setup P1.1/2 as pullup momentary switched w/ int enabled
    MAB = P1REN; BW = 1; MW = 1; MDBwrite = 8'h06; #CLK_PERIOD;
    MAB = P1OUT; BW = 1; MW = 1; MDBwrite = 8'h06; #CLK_PERIOD;
    MAB = P1IES; BW = 1; MW = 1; MDBwrite = 8'h06; #CLK_PERIOD;
    MAB = P1IE;  BW = 1; MW = 1; MDBwrite = 8'h06; #CLK_PERIOD;
    MAB = P1IFG; BW = 1; MW = 1; MDBwrite = 8'h00; #CLK_PERIOD;
    MAB = 0; BW = 0; MW = 0; MDBwrite = 0;

    #(3*CLK_PERIOD);
    // Triger falling edge on P1.1
    PxIN = 8'h58; #(3*CLK_PERIOD);

    // INT entered, read P1IV
    MAB = P1IV; BW = 0; MW = 0; #CLK_PERIOD;
    MAB = 0; BW = 0; MW = 0;

    #(3*CLK_PERIOD);
    // trigger P1.2
    PxIN = 8'h5F; #CLK_PERIOD;
    PxIN = 8'h5B; #CLK_PERIOD;

    // trigger P1.1 - P1IV priority switches
    PxIN = 8'h59; #CLK_PERIOD;

    #(3*CLK_PERIOD);

    // Read P1IV. Clear P1IFG.1
    MAB = P1IV; BW = 0; MW = 0; #CLK_PERIOD;
    MAB = 0; BW = 0; MW = 0;
    #(3*CLK_PERIOD);

    // Read P1IV. Clear P1IFG.2
    MAB = P1IV; BW = 0; MW = 0; #CLK_PERIOD;
    MAB = 0; BW = 0; MW = 0;
    #(3*CLK_PERIOD);

    // Reset device
    `PULSE(rst)

    // write to SELC
    MAB = PASEL0; MW = 1; BW = 0; MDBwrite = 16'ha55a; #CLK_PERIOD;
    MAB = 0; BW = 0; MW = 0; MDBwrite = 0;

    `ifdef __ICARUS__
    $finish(0);
    `endif
end
endmodule
`default_nettype wire
