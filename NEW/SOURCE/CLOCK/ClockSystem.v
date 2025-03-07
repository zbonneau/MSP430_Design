/*--------------------------------------------------------
    Module Name: ClockSystem
    Description:
        The Clock System Module is responsible for generating
        the internal clock signals (MCLK, SMCLK, ACLK).
    Inputs:
        sysOsc - systemOscillator from FPGA board (12 MHz)

    Outputs:
        MCLK - 1 MHz
        SMCLK - 1 MHz
        ACLK  - 32,768 Hz

--------------------------------------------------------*/
`timescale 1ns/1ps

module ClockSystem(
    input sysOsc, reset,
    output reg MCLK, ACLK,
    output SMCLK
 );

    /* Internal signal definitions */
    reg [8:0] ACLK_counter;
    reg [3:0] MCLK_counter;
    initial begin {MCLK, ACLK, ACLK_counter, MCLK_counter} = 0; end

    `include "NEW/PARAMS.v" // global parameter defines
    `include "NEW/FPGA.v" // FPGA parameters

    /* Continuous Logic Assignments */
    assign SMCLK = MCLK;

    /* Sequential Logic Assignments */
    always @(posedge sysOsc) begin
        if (reset) begin
            {MCLK, ACLK, ACLK_counter, MCLK_counter} <= 0;
        end else begin
            if (ACLK_counter == 0) begin
                ACLK <= ~ACLK;
                ACLK_counter <= ACLK_DOWNCOUNT-1;
            end else begin
                ACLK_counter <= ACLK_counter - 1;
            end

            if (MCLK_counter == 0) begin
                MCLK <= ~MCLK;
                MCLK_counter <= MCLK_DOWNCOUNT-1;
            end else begin
                MCLK_counter <= MCLK_counter - 1;
            end
        end
    end
endmodule
