/*--------------------------------------------------------
    Module Name : InterruptModule Testbench
    Description:
        Verifies Functionality of the InterruptModule

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_InterruptModule;
reg INT, INTACKin, REQthru;
reg [5:0] IntAddrthru;
integer i;

wire CLR, INTACKthru, REQout;
wire [5:0] IntAddrout;
`include "NEW/PARAMS.v"

initial begin {INT, INTACKin, REQthru, IntAddrthru} = 0; end

InterruptModule #(
    .INDEX(IVT_PORT1)
) uut (
.INT(INT), .INTACKin(INTACKin), 
.REQthru(REQthru), .IntAddrthru(IntAddrthru), 
.CLR(CLR), .INTACKthru(INTACKthru), 
.REQout(REQout), .IntAddrout(IntAddrout)
);

initial begin
    $display("| INT | ACK | REQ | ADR || CLR | ACK | REQ | ADR |");
    $display("|-----|-----|-----|-----||-----|-----|-----|-----|");
    $monitor("|  %1b  |  %1b  |  %1b  |  %2d ||  %1b  |  %1b  |  %1b  |  %2d |",
               INT, INTACKin, REQthru, IntAddrthru, 
               CLR, INTACKthru, REQout, IntAddrout);
end

initial begin
    IntAddrthru = IVT_PORT2;
    for (i = 0; i < 8; i = i +1) begin
        {INT, INTACKin, REQthru} = i; #10;
    end
    
    $display("|-----|-----|-----|-----||-----|-----|-----|-----|");
    $finish(0);
end
endmodule
`default_nettype wire
