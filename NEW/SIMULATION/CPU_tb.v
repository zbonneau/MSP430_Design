/*--------------------------------------------------------
    Module Name : CPU Testbench
    Description:
        Verifies Functionality of the CPU

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_CPU;
reg MCLK, reset;
reg NMI, INT;
reg [5:0] IntAddrLSBs;

wire [15:0] MDBin;
    
wire [15:0] MAB;
wire [15:0] MDBout;
wire MW, BW, INTACK;

initial begin 
    {MCLK, reset} = 0; 
    NMI = 0;
    INT = 0;
    IntAddrLSBs = 63; // maps to FFFE, reset vector
end


/* Simple Memory File Construct */
reg [7:0] memory[65535:17408];

initial begin
    for (integer i = 16'h4400; i < 17'h1_0000; i = i + 2) 
        {memory[i+1], memory[i]} <= 16'h4303; // default NOP
    
    /* load program memory here */



    {memory[16'hFFFF], memory[16'hFFFE]} = 16'h4400;
end

assign MDBin = BW ? {8'h00,         memory[MAB]} :
                    {memory[MAB+1], memory[MAB]};

/* End Memory */

CPU uut
(
    .MCLK(MCLK), .reset(reset), 
    .NMI(NMI), .INT(INT), .IntAddrLSBs(IntAddrLSBs), 
    .MDBin(MDBin), .MAB(MAB), .MDBout(MDBout), 
    .MW(MW), .BW(BW), .INTACK(INTACK)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) MCLK = ~MCLK;

initial begin
    $dumpfile("CPU.vcd");
    $dumpvars(0, tb_CPU);
end

initial begin
    IntAddr = 63;
    reset = 1; #(3*CLK_PERIOD); reset = 0; 
    while (~INTACK) #CLK_PERIOD;

    /* Program has entered reset vector at this point */
    #(100*CLK_PERIOD);
    $finish(0);
end
endmodule
`default_nettype wire
