/*--------------------------------------------------------
    Module Name: FRAM
    Description:
        The MEMORY module contains the simulated memory. 
        This module will be used to simulate RAM/FRAM/IVT sections.

    Inputs:
        MAB - Memory Address Bus
        MDBwrite - Memory Data Bus from CPU to FRAM
        MW, BW - Control Signals

    Outputs:
        MDBread - Memory Data Bus from FRAM to CPU. Default Hi-Z

--------------------------------------------------------*/

module MEMORY #(
    parameter   START   = 0,
                DEPTH   = 0,                
                INITVAL = 16'h0000
    )(
    input MCLK, reset, 
    input [15:0] MAB, MDBwrite,
    input MW, BW,

    output [15:0] MDBread
 );
    `include "NEW\\PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    reg [7:0] memory [DEPTH-1:0];
    integer i;

    initial begin 
        for (i = 0; i < DEPTH; i = i + 2) 
            {memory[i+1], memory[i]} = INITVAL;
     end

    /* Continuous Logic Assignments */
    assign MDBread = (MAB >= START && MAB < START + DEPTH) 
            ? (BW)
                ? {8'h00, memory[MAB-START]}                      // valid byte read
                : {memory[((MAB-START) & ~1 )+1], memory[(MAB-START) & ~1]}   // valid word read
            :   {16{1'bz}}; // invalid read

    /* Sequential Logic Assignments */
    always @(posedge MCLK) begin
        if (reset) begin
            for (i = 0; i < DEPTH; i = i + 2) 
                {memory[i+1], memory[i]} = 0;
        end else if (MW && (MAB >= START && MAB < START + DEPTH)) begin
            // valid write to FRAM
            if (BW) begin
                memory[(MAB-START)] <= MDBwrite[7:0];
            end else begin
                memory[((MAB-START) & ~1 )+ 1] <= MDBwrite[15:8];
                memory[(MAB-START) & ~1]     <= MDBwrite[7:0];
            end
        end
    end
endmodule
