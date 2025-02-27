/*--------------------------------------------------------
    Module Name: InterruptModule
    Description:
        The Interrupt Module defines a single daisy-chained 
        unit. This unit either triggers an interrupt request,
        or chains lower-priority interrupts through.
    Inputs:
        INT - interrupt source flag (or bit-wise OR of multiple flags)
        INTACKin - INTACK from higher-priority module
        REQthru - INT Request from lower-priority module
        IntAddrthru - Interrupt Address index from lower-priority module

    Outputs:
        CLR - intterupt flag clear for single-source modules
        INTACKthru - INTACK to lower-priority module
        REQout - INT Request to higher-priority module
        IntAddrout - Interrupt Address index to higher-priority module

    Parameters:
        INDEX - Priority Index of module. Configures Addr index when triggered

--------------------------------------------------------*/
`timescale 100ns/100ns

module InterruptModule#(
    parameter [5:0] INDEX = 0
    )(
    input INT, INTACKin, REQthru,
    input [5:0] IntAddrthru,

    output CLR, INTACKthru, REQout,
    output [5:0] IntAddrout
 );
    `include "NEW\\PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */
    assign CLR = INTACKin & INT;
    assign INTACKthru = INTACKin & ~INT;
    assign REQout = REQthru | INT;
    assign IntAddrout = (INT) ? INDEX : IntAddrthru;

endmodule
