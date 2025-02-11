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

/* Useful Construction in iVerilog simulator. Arrays are not
 * exported by the vvp simulator
 */
wire [15:0] Reg0, Reg1, Reg2, Reg3, Reg4, Reg5, Reg6, Reg7,
      Reg8, Reg9, Reg10, Reg11, Reg12, Reg13, Reg14, Reg15;

`include "NEW\\MACROS.v"

initial begin 
    {MCLK, reset} = 0; 
    NMI = 0;
    INT = 0;
    IntAddrLSBs = 63; // maps to FFFE, reset vector
end

reg [15:0] exit;


/* Simple Memory File Construct */
reg [7:0] memory[65535:17408];
integer i;

initial begin
    for (i = 16'h4400; i < 17'h1_0000; i = i + 2) 
        {memory[i+1], memory[i]} = 16'h4303; // default NOP
    i = 16'h4400;
    
    /* load program memory here */
    {memory[i+1], memory[i]} = 16'h4031; i = i+2;
    {memory[i+1], memory[i]} = 16'h2400; i = i+2;
    {memory[i+1], memory[i]} = 16'h40B2; i = i+2;
    {memory[i+1], memory[i]} = 16'h5A80; i = i+2;
    {memory[i+1], memory[i]} = 16'h015C; i = i+2;
    {memory[i+1], memory[i]} = 16'h4034; i = i+2;
    {memory[i+1], memory[i]} = 16'h1234; i = i+2;
    {memory[i+1], memory[i]} = 16'h5234; i = i+2;
    {memory[i+1], memory[i]} = 16'h4445; i = i+2;
    {memory[i+1], memory[i]} = 16'h4016; i = i+2;
    {memory[i+1], memory[i]} = 16'h0024; i = i+2;
    {memory[i+1], memory[i]} = 16'h4037; i = i+2;
    {memory[i+1], memory[i]} = 16'h4438; i = i+2;
    {memory[i+1], memory[i]} = 16'h8738; i = i+2;
    {memory[i+1], memory[i]} = 16'h57A0; i = i+2;
    {memory[i+1], memory[i]} = 16'h001C; i = i+2;
    {memory[i+1], memory[i]} = 16'h1204; i = i+2;
    {memory[i+1], memory[i]} = 16'h1244; i = i+2;
    {memory[i+1], memory[i]} = 16'h4039; i = i+2;
    {memory[i+1], memory[i]} = 16'h0005; i = i+2;
    {memory[i+1], memory[i]} = 16'h8319; i = i+2;
    {memory[i+1], memory[i]} = 16'h23FE; i = i+2;
    {memory[i+1], memory[i]} = 16'h403A; i = i+2;
    {memory[i+1], memory[i]} = 16'h0020; i = i+2;
    {memory[i+1], memory[i]} = 16'h100A; i = i+2;
    {memory[i+1], memory[i]} = 16'h2BFE; i = i+2;
    {memory[i+1], memory[i]} = 16'h3FFF; i = i+2; exit = i;
    {memory[i+1], memory[i]} = 16'h4303; i = i+2;
    {memory[i+1], memory[i]} = 16'hA5A5; i = i+2;
    {memory[i+1], memory[i]} = 16'h2244; i = i+2;


    {memory[16'hFFFF], memory[16'hFFFE]} = 16'h4400;
end

assign MDBin = (MAB >= 16'h4400) ?
                    BW ? {8'h00,         memory[MAB]}
                       : {memory[MAB+1], memory[MAB]}
                                 : 16'h0000;

/* End Memory */

CPU uut
(
    .MCLK(MCLK), .reset(reset), 
    .NMI(NMI), .INT(INT), .IntAddrLSBs(IntAddrLSBs), 
    .MDBin(MDBin), .MAB(MAB), .MDBout(MDBout), 
    .MW(MW), .BW(BW), .INTACK(INTACK)
);

assign Reg0  = uut.RFile.Registers[R0];
assign Reg1  = uut.RFile.Registers[R1];
assign Reg2  = uut.RFile.Registers[R2];
assign Reg3  = uut.RFile.Registers[R3];
assign Reg4  = uut.RFile.Registers[R4];
assign Reg5  = uut.RFile.Registers[R5];
assign Reg6  = uut.RFile.Registers[R6];
assign Reg7  = uut.RFile.Registers[R7];
assign Reg8  = uut.RFile.Registers[R8];
assign Reg9  = uut.RFile.Registers[R9];
assign Reg10 = uut.RFile.Registers[R10];
assign Reg11 = uut.RFile.Registers[R11];
assign Reg12 = uut.RFile.Registers[R12];
assign Reg13 = uut.RFile.Registers[R13];
assign Reg14 = uut.RFile.Registers[R14];
assign Reg15 = uut.RFile.Registers[R15];

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) MCLK = ~MCLK;

initial begin
    $dumpfile("CPU.vcd");
    $dumpvars(0, tb_CPU);
end

initial begin
    IntAddrLSBs = 63;
    reset = 1; #(3*CLK_PERIOD); reset = 0; 
    while (~INTACK) #CLK_PERIOD;

    /* Program has entered reset vector at this point */
    while (uut.RFile.Registers[PC] != exit)
        #CLK_PERIOD;
    #(3*CLK_PERIOD);
    $finish(0);
end
endmodule
`default_nettype wire
