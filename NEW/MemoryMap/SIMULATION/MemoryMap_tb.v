/*--------------------------------------------------------
    Module Name : MemoryMap Testbench
    Description:
        Verifies Functionality of the MemoryMap

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_MemoryMap;
reg clk, rst;
reg [15:0] MAB, MDBwrite;
reg MW, BW;

wire [15:0] MDBread;
`include "NEW/PARAMS.v"

initial begin {clk, rst, MAB, MDBwrite, MW, BW} = 0; end

MemoryMap uut(
.MCLK(clk), .rst(rst),
.MAB(MAB), .MDBwrite(MDBwrite), .MDBread(MDBread),
.MW(MW), .BW(BW)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;
integer i = 0;

initial begin
    // Load FRAM with example program
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4031; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h2400; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h40B2; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h5A80; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h015C; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4034; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h1234; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h5234; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4445; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4016; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h0024; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4037; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4438; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h8738; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h57A0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h001C; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h1204; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h1244; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4039; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h0005; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h8319; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h23FE; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h403A; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h0020; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h100A; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h2BFE; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h3FFF; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4303; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hA5A5; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h2244; i = i+2;
end

initial begin
   $dumpfile("MemoryMap.vcd");
   $dumpvars(0, tb_MemoryMap);
end

initial begin
    // Read from invalid below RAM
    MAB = RAM_START - 2; #CLK_PERIOD;

    // Write to invalid below RAM
    MDBwrite = 16'h1234; MW = 1; #CLK_PERIOD; MW = 0;

    // Read from valid RAM
    MAB = RAM_START; #CLK_PERIOD;

    // Write to valid RAM
    MDBwrite = 16'h5678; `PULSE(MW);

    // Read from invalid above RAM
    MAB = RAM_START + RAM_LEN; #CLK_PERIOD;

    // Write to invalid above RAM
    `PULSE(MW)

    // Read from invalid below FRAM
    MAB = FRAM_START - 2; #CLK_PERIOD;

    // Write to invalid below FRAM
    MDBwrite = 16'h1234; `PULSE(MW);

    // Read from valid FRAM
    MAB = FRAM_START; #CLK_PERIOD;

    // Write to valid FRAM
    MDBwrite = 16'h5678; `PULSE(MW);

    // Read from IVT - (above FRAM doesn't exist in full memory simulation)
    MAB = 16'hFFFE; #CLK_PERIOD;

    // Write Byte to Top of RAM - Like PUSH
    MAB = RAM_START + RAM_LEN - 2; MDBwrite = 16'h00A5; BW = 1; `PULSE(MW) 
    BW = 0;

    // Reset Device
    `PULSE(rst)

   $finish(0);
end
endmodule
`default_nettype wire
