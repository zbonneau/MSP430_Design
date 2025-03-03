/*--------------------------------------------------------
    Module Name : CPUwInterrupt Testbench
    Description:
        Verifies Functionality of the CPUwInterrupt

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_CPUwInterrupt;
reg MCLK, RSTn;

reg INT_Timer0A0, INT_Timer0A1, INT_PORT1, INT_PORT2;
wire CLR_Timer0A0, CLR_Timer0A1, CLR_PORT1, CLR_PORT2;

wire reset, NMI, INT, INTACK;
wire [5:0] IntAddrLSBs;
wire [15:0] MAB, MDBwrite, MDBread;
wire MW, BW;

wire [15:0] Reg0, Reg1, Reg2, Reg3, Reg4, Reg5, Reg6, Reg7,
      Reg8, Reg9, Reg10, Reg11, Reg12, Reg13, Reg14, Reg15;

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

`include "NEW/PARAMS.v"

initial begin 
    {MCLK, INT_Timer0A0, INT_Timer0A1, INT_PORT1, INT_PORT2} = 0; 
    RSTn = 1;
end

CPU cpu(
    .MCLK(MCLK), .reset(reset),
    .NMI(NMI), .INT(INT), .IntAddrLSBs(IntAddrLSBs),
    .MDBin(MDBread), .MDBout(MDBwrite), .MAB(MAB),
    .MW(MW), .BW(BW), .INTACK(INTACK)
);

InterruptUnit INT_Unit(
    .MCLK(MCLK), .RSTn(RSTn), .INTACK(INTACK), 
    .reset(reset), .NMI(NMI), .INT(INT), .IntAddrLSBs(IntAddrLSBs),
    .Module_52_int(INT_Timer0A0),   .Module_52_clr(CLR_Timer0A0),
    .Module_51_int(INT_Timer0A1),   .Module_51_clr(CLR_Timer0A1),
    .Module_45_int(INT_PORT1),      .Module_45_clr(CLR_PORT1),
    .Module_42_int(INT_PORT2),      .Module_42_clr(CLR_PORT2)
);

MemoryMap SysMap(
    .MCLK(MCLK), .rst(reset),
    .MAB(MAB), .MDBwrite(MDBwrite), .MDBread(MDBread),
    .MW(MW), .BW(BW)
);

/* Load Program Memory here */
integer i = 0;

initial begin
    i = 0;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4031; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h2400; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4303; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'hD232; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4303; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4034; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h000D; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4035; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h0014; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h1204; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h1245; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h12B0; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h442A; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h8314; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h8315; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4177; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4138; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4303; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h3FFF; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'hA5A5; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h2244; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4506; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h5406; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4130; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4036; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h001E; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'hE0F0; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h00AA; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'hFFEF; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h1300; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'hD032; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h0010; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h3FFD; i=i+2;
    {SysMap.FRAM.memory[i+1], SysMap.FRAM.memory[i]} = 16'h4303; i=i+2;
end

initial begin
    i = 0;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'hFFFF; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h4430; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h443C; i=i+2;
    {SysMap.IVT.memory[i+1], SysMap.IVT.memory[i]} = 16'h4400; i=i+2;
end

/* run Simulation */
localparam MCLK_PERIOD = 10;
always #(MCLK_PERIOD/2) MCLK = ~MCLK;

initial begin
    $dumpfile("CPUwInterrupt.vcd");
    $dumpvars(0, tb_CPUwInterrupt);
end

initial begin
    

    // Program entered Subroutine func1. Call interrupt
    while(Reg0 != 16'h442C) #(MCLK_PERIOD/2);

    INT_PORT1 = 1;
    while (~INTACK) #(MCLK_PERIOD/2);

    // Program Entered PORT1 ISR, Clear IFG on IV read
    #(3*MCLK_PERIOD);
    @(posedge MCLK);
    INT_PORT1 = 0;

    while(cpu.RFile.Registers[PC] != 16'h4424) #(MCLK_PERIOD/2);
    #(3*MCLK_PERIOD);
    
    $finish(0);
end
endmodule
`default_nettype wire
