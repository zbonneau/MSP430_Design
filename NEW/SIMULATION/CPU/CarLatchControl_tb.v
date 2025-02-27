/*--------------------------------------------------------
    Module Name : Car Latch Control Testbench
    Description:
        Verifies functionality of the CAR Latch Control

--------------------------------------------------------*/

// `include "NEW\\CarLatchControl.v"
`default_nettype none
`timescale 100ns/100ns

module tb_CarLatchControl;
reg rst, INTREQ, IF, Br;
reg [CAR_BITS-1:0]  CARnew, CARold;
wire [CAR_BITS-1:0] CARnext;

`include "NEW\\PARAMS.v"

initial begin 
    {rst, INTREQ, IF, Br} = 0;
    CARnew = CAR_IND_IDX0; 
    CARold = CAR_1OP_IND1;
end

CarLatchControl uut
(
    .rst(rst), .INTREQ(INTREQ), .IF(IF), .Br(Br),
    .CARnew(CARnew), .CARold(CARold),
    .CARnext(CARnext)
);

localparam CLK_PERIOD = 10;

initial begin
    $display("    CARnew = %2d", CARnew);
    $display("    CARold = %2d", CARold);
    $display("  CAR_INT0 = %2d", CAR_INT0);
    $display("  CAR_INT4 = %2d", CAR_INT4);
    $display("|-----|-----|-----|-----|");
    $display("| rst | Br  | INT | IF  | CARnext");
    $display("|-----|-----|-----|-----|");
    $monitor("|  %1b  |  %1b  |  %1b  |  %1b  |  %2d", 
                 rst,    Br,    INTREQ,  IF,     CARnext);
end

initial begin
    /* Small enough to test all cases */
    for (integer i = 0; i < 16; i = i + 1) begin
        {rst, Br, INTREQ, IF} = i[3:0]; #CLK_PERIOD;
    end
    
    $display("|-----|-----|-----|-----|");
    $finish(0);
end
endmodule
`default_nettype wire
