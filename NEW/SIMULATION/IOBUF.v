/*--------------------------------------------------------
    Module Name: IOBUF
    Description:
        Simulates the IOBUFs present on the Cmod A7-35T 
        FPGA Development Board
    Inputs:
        I - input from logic
        T - input toggle (1: IO = Z)
        IO - IO bi-directional pin from external
    Outputs:
        O - output to logic
        IO - IO bi-driectional pin from external

--------------------------------------------------------*/
`timescale 100ns/100ns

module IOBUF(
    input I, T,
    output O,
    inout IO
 );
    `include "NEW/PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */
    assign O = IO;
    assign IO = (T) ? 1'bz : I;

endmodule

