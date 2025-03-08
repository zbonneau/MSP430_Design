/*--------------------------------------------------------
    Module Name : IOBUF Testbench
    Description:
        Verifies Functionality of the IOBUF

--------------------------------------------------------*/

`default_nettype none
`include "NEW/SIMULATION/IOBUF.v"
`timescale 100ns/100ns

module tb_IOBUF;
reg I, T;
wire IO;
wire O;

`include "NEW/PARAMS.v"

reg IO_driver;
initial begin {I,T,IO_driver} = 0; end
assign IO = T ? IO_driver : 1'bz;

IOBUF uut
(
    .I(I), .T(T), 
    .IO(IO),
    .O(O)
);

initial begin
    // $dumpfile("IOBUF.vcd");
    // $dumpvars(0, tb_IOBUF);
    $display("| T | I || IO || O |");
    $monitor("| %1b | %1b || %1b  || %1b |",
                T,    I,     IO,     O);
end

initial begin
    T = 1; IO_driver = 0; #10;
    I = 1; #10;
    IO_driver = 1; #10;
    I = 0; #10;

    T = 0; I = 0; IO_driver = 1'bz; #10;
    I = 1; #10;
    $finish(0);
end
endmodule
`default_nettype wire
