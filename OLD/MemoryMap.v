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
`timescale 100ns/100ns

module MemoryMap (
    input MCLK, rst,
    input [15:0] MAB, MDBwrite,
    input MW, BW,

    output [15:0] MDBread
 );
    `include "NEW\\PARAMS.v" // global parameter defines

    /* Internal signal definitions */

    // initial begin {} = 0; end

    /* Continuous Logic Assignments */

    /* Sequential Logic Assignments */

    /* Module Instantiations */
    MEMORY #(
        .START(RAM_START), 
        .DEPTH(RAM_LEN),
        .INITVAL(0)
    ) RAM (
        .MCLK(MCLK), .reset(rst),
        .MAB(MAB), .MDBwrite(MDBwrite),
        .MW(MW), .BW(BW),
        .MDBread(MDBread)
    );

    MEMORY #(
        .START(FRAM_START), 
        .DEPTH(FRAM_LEN),
        .INITVAL(16'hFFFF)
    ) FRAM (
        .MCLK(MCLK), .reset(1'b0), // NVM not reset by POR
        .MAB(MAB), .MDBwrite(MDBwrite),
        .MW(MW), .BW(BW),
        .MDBread(MDBread)
    );

    MEMORY #(
        .START(IVT_START), 
        .DEPTH(IVT_LEN),
        .INITVAL(16'h4400) // RESET ISR
    ) IVT (
        .MCLK(MCLK), .reset(1'b0), // IVT not reset by POR
        .MAB(MAB), .MDBwrite(MDBwrite),
        .MW(MW), .BW(BW),
        .MDBread(MDBread)
    );


endmodule
