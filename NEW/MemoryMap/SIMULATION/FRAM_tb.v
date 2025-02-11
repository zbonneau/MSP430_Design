/*--------------------------------------------------------
    Module Name : FRAM Testbench
    Description:
        Verifies Functionality of the FRAM

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_FRAM;
reg clk, erase;
reg [15:0] MAB, MDBwrite;
reg MW, BW;

wire [15:0] MDBread;

initial begin {clk, erase, MAB, MDBwrite} = 0; end

FRAM uut
(
.MCLK(clk), .erase(erase),
.MAB(MAB), .MDBwrite(MDBwrite), 
.MW(MW), .BW(BW), 
.MDBread(MDBread)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

wire [15:0] m0, m2, m4, m6, m8, mA;

assign m0 = {uut.memory[1],  uut.memory[0]};
assign m2 = {uut.memory[3],  uut.memory[2]};
assign m4 = {uut.memory[5],  uut.memory[4]};
assign m6 = {uut.memory[7],  uut.memory[6]};
assign m8 = {uut.memory[9],  uut.memory[8]};
assign mA = {uut.memory[11], uut.memory[10]};

initial begin
    $dumpfile("FRAM.vcd");
    $dumpvars(0, tb_FRAM);
end

initial begin
    // Read 4400
    MAB = 16'h4400; MW = 0; BW = 0; #CLK_PERIOD;
    // Write 1234 to 4400
    MDBwrite = 16'h1234; `PULSE(MW)

    // Read byte at 4400
    `PULSE(BW)
    //READ byte at 4401
    MAB = 16'h4401; `PULSE(BW)

    // Write byte to 4403
    MAB = 16'h4403; MW = 1; BW = 1; #CLK_PERIOD; MW = 0; BW = 0;

    // Read Word at 4403 (Should default to 4402)
    #CLK_PERIOD;

    // Write word at 4405 (should default to 4043)
    MAB = 16'h4405; `PULSE(MW)

    // read invalid
    MAB = 16'h1C00; #CLK_PERIOD;

    // write invalid
    `PULSE(MW)

    // erase FRAM
    `PULSE(erase)

    #CLK_PERIOD;

    $finish(0);
end
endmodule
`default_nettype wire
