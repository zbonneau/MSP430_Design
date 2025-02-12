/*--------------------------------------------------------
    Module Name : CPUwMemory Testbench
    Description:
        Verifies Functionality of the CPU with Memory Map

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_CPUwMemory;
reg clk, rst;
reg NMI, INT;
reg [5:0] IntAddrLSBs;
wire [15:0] MAB, MDBwrite, MDBread;
wire MW, BW, INTACK;

integer i;
/* Useful Construction in iVerilog simulator. Arrays are not
 * exported by the vvp simulator
 */
wire [15:0] Reg0, Reg1, Reg2, Reg3, Reg4, Reg5, Reg6, Reg7,
      Reg8, Reg9, Reg10, Reg11, Reg12, Reg13, Reg14, Reg15;

initial begin 
    {clk, rst, NMI, INT, IntAddrLSBs} = 0;
end

CPU cpu(
    .MCLK(clk), .reset(rst), 
    .NMI(NMI), .INT(INT), .IntAddrLSBs(IntAddrLSBs), 
    .MDBin(MDBread), .MAB(MAB), .MDBout(MDBwrite), 
    .MW(MW), .BW(BW), .INTACK(INTACK)
);

MemoryMap memmap(
    .MCLK(clk), .rst(rst),
    .MAB(MAB), .MDBwrite(MDBwrite), .MDBread(MDBread),
    .MW(MW), .BW(BW)
);

assign Reg0  = cpu.RFile.Registers[0];
assign Reg1  = cpu.RFile.Registers[1];
assign Reg2  = cpu.RFile.Registers[2];
assign Reg3  = cpu.RFile.Registers[3];
assign Reg4  = cpu.RFile.Registers[4];
assign Reg5  = cpu.RFile.Registers[5];
assign Reg6  = cpu.RFile.Registers[6];
assign Reg7  = cpu.RFile.Registers[7];
assign Reg8  = cpu.RFile.Registers[8];
assign Reg9  = cpu.RFile.Registers[9];
assign Reg10 = cpu.RFile.Registers[10];
assign Reg11 = cpu.RFile.Registers[11];
assign Reg12 = cpu.RFile.Registers[12];
assign Reg13 = cpu.RFile.Registers[13];
assign Reg14 = cpu.RFile.Registers[14];
assign Reg15 = cpu.RFile.Registers[15];

initial begin
    // Load predefined variables here
end

initial begin
    // Load Prgram here
    i = 0;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4031; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h2400; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4303; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'hD232; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4303; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4034; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h000D; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4035; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h0014; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h1204; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h1245; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h12B0; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h442A; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h8314; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h8315; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4177; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4138; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4303; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h3FFF; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'hA5A5; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h2244; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4506; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h5406; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4130; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4036; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h001E; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'hE0F0; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h00AA; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'hFFEF; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h1300; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'hD032; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h0010; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h3FFD; i=i+2;
    {memmap.FRAM.memory[i+1], memmap.FRAM.memory[i]} = 16'h4303; i=i+2;
end

initial begin
    // Load interrupt vectors here
    i = 0;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h4430; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h443C; i=i+2;
    {memmap.IVT.memory[i+1], memmap.IVT.memory[i]} = 16'h4400; i=i+2;
end

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    $dumpfile("CPUwMemory.vcd");
    $dumpvars(0, tb_CPUwMemory);
end

initial begin
    IntAddrLSBs = 63;
    rst = 1; #(3*CLK_PERIOD); rst = 0; 
    while (~INTACK) #CLK_PERIOD;

    // /* Program has entered reset vector at this point */
    while(Reg0 != 16'h442C) #(CLK_PERIOD/2);

    // /* Program executing a subroutine func1. Call Interrupt */
    IntAddrLSBs = 45; INT = 1;// PORT1 ISR
    while (~INTACK) #CLK_PERIOD;
    INT = 0;
    // #(3*CLK_PERIOD);

    // /* Entered PORT1 ISR */


    // /* Leave ISR, return to subroutine */


    // /* Leave subroutine, finish execution */
    // $display("ISR entered ...");
    while (Reg0 != 16'h4424) #CLK_PERIOD;
    // $display("END reached ...");
    #(3*CLK_PERIOD);


    $finish(0);
end
endmodule
`default_nettype wire
