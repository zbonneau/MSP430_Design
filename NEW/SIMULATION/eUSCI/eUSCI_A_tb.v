/*--------------------------------------------------------
    Module Name : eUSCI Testbench
    Description:
        Verifies Functionality of the eUSCI

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_eUSCI_A;
reg MCLK, UCxCLK, ACLK, reset;
wire SMCLK;
reg Rx; 
reg  [15:0] MAB, MDBwrite;
reg MW, BW;
wire [15:0] MDBread;
wire Tx;
wire INT1;

`include "NEW/PARAMS.v"

assign SMCLK = MCLK;
initial begin 
    {MCLK, UCxCLK, ACLK, reset, Rx, MAB, MDBwrite, MW, BW} = 0;
    Rx = 1;
end

eUSCI_A uut (
    .MCLK(MCLK), .UCxCLK(UCxCLK), .ACLK(ACLK), .SMCLK(SMCLK), .reset(reset), 
    .MAB(MAB), .MDBwrite(MDBwrite), .MW(MW), .BW(BW), .MDBread(MDBread), 
    .Rx(Rx), .Tx(Tx), .INT1(INT1)
);

localparam CLK_PERIOD = 10;
localparam ACLK_PERIOD = 305;
always #(CLK_PERIOD/2) MCLK = ~MCLK;
always #(ACLK_PERIOD/2) ACLK = ~ACLK;

initial begin
    $dumpfile("eUSCI_A.vcd");
    $dumpvars(0, tb_eUSCI_A);
end

initial begin
    `PULSE(reset);
    // Configure module for 8-no-1 frames, listen loopback, RxIE, ignore errors
    // SMCLK, 9600 BAUD
    MW = 1; BW = 0;
    MAB = UCA0BRW;      MDBwrite = 6;           #CLK_PERIOD;
    MAB = UCA0MCTLW+1;  MDBwrite = 8'h20;       BW = 1; #CLK_PERIOD; 
    MAB = UCA0MCTLW+0;  MDBwrite = 8'h81;       #CLK_PERIOD; BW = 0;
    MAB = UCA0STATW;    MDBwrite = 16'hFFFF;    #CLK_PERIOD;
    MAB = UCA0IE;       MDBwrite = 1<<UCRXIE;   #CLK_PERIOD;
    MAB = UCA0CTLW0;    MDBwrite = 16'h0080;    #CLK_PERIOD;
    {MW, BW, MAB, MDBwrite} = 0; #CLK_PERIOD;

    // Device Ready to loopback.
    MAB = UCA0TXBUF; MDBwrite = 8'h56; MW = 1; #CLK_PERIOD;
    MAB = UCA0STATW; MDBwrite = 0; MW = 0;

    while(!INT1) #CLK_PERIOD;

    #(3*CLK_PERIOD);

    // read IV for autoclear
    MAB = UCA0IV; #CLK_PERIOD; MAB = 0;

    // Write 2 frames rapidly
    MAB = UCA0TXBUF; MDBwrite = 8'h55; MW = 1; #CLK_PERIOD; MW = 0;

    #(60*CLK_PERIOD);
    MW = 1; #CLK_PERIOD; MW = 0;

    while(!uut.wUCOE) #CLK_PERIOD;

    // Read RxBuf for autoclear
    MAB = UCA0RXBUF; #CLK_PERIOD;

    $finish(0);
end
endmodule
`default_nettype wire
