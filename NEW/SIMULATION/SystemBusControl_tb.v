/*--------------------------------------------------------
    Module Name : System Bus Control Testbench
    Description:
        Verifies functionality of System Bus Control Module

--------------------------------------------------------*/

`include "NEW\\SystemBusControl.v"
`default_nettype none
`timescale 100ns/100ns

module tb_SystemBusControl;
reg IdxF, IF, Mem, Ex, INTACK, IW6;
reg [15:0]  PCnt, Addr, IntAddr, result;
wire [15:0] MAB, MDBout;
wire        BW, MW;

initial begin 
    {IdxF, IF, Mem, Ex, INTACK, IW6} = 0;
    PCnt = 16'h4400; // Generic FRAM code address
    Addr = 16'h1C09; // Generic RAM data address
    IntAddr = 16'hFFF8; // Generic IVT address
    result = 16'h1234;
end

SystemBusControl uut
(
    .IdxF(IdxF), .IF(IF), .Mem(Mem), .Ex(Ex), .INTACK(INTACK), .IW6(IW6),
    .PCnt(PCnt), .Addr(Addr), .IntAddr(IntAddr), .result(result),
    .MAB(MAB), .MDBout(MDBout), 
    .BW(BW), .MW(MW)
);

localparam CLK_PERIOD = 10;

initial begin
    $display("PCnt = %4h", PCnt);
    $display("Addr = %4h", Addr);
    $display("IntAddr = %4h", IntAddr);
    $display("result = %4h", result);
    $display("|---|---|---|---|---|---|||------|------|---|---|");
    $display("|INT|Idx|IF |Mem|Ex |IW6||| MAB  | MDB  |MW |BW |");
    $display("|---|---|---|---|---|---|||------|------|---|---|");
    $monitor("| %1b | %1b | %1b | %1b | %1b | %1b ||| %4h | %4h | %1b | %1b |",
              INTACK, IdxF, IF,   Mem,  Ex,   IW6,    MAB,  MDBout,  MW,   BW);
end

initial begin

    for (integer i = 0; i < (1<<6); i = i+1) begin
    {INTACK, IdxF, IF, Mem, Ex, IW6} = i[5:0]; #CLK_PERIOD;
    end

    $display("|---|---|---|---|---|---|||------|------|---|---|");
    $finish(0);
end
endmodule
`default_nettype wire
