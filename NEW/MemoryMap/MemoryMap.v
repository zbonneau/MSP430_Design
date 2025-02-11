/*--------------------------------------------------------
    Module Name: MemoryMap
    Description:
        The Memory Map bridges the CPU with the memory files 
        and peripheral modules. It essentially describes the 
        System Bus. This module assumes the ideal high-impedance 
        double data bus. 


    Inputs:
        MAB - Memory Address Bus
        MDBwrite - MDB from CPU to memory+peripherals
        MW,BW - Control Signals

    Outputs:
        MDBread - MDB from memory+peripherals to CPU

--------------------------------------------------------*/

module MemoryMap(
    input MCLK, rst,
    input [15:0] MAB, MDBwrite,
    input MW, BW,

    output [15:0] MDBread
 );

    /* Internal signal definitions */

    initial begin {} = 0; end

    `include "NEW\\PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */

    /* Sequential Logic Assignments */

endmodule
