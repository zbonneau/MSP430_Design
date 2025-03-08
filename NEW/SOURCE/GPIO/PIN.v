/*--------------------------------------------------------
    Module Name: PIN
    Description:
        Describes the Pin MUX behavior of the external MSP430 pins.
    Inputs:
        Px_m - External IO pin
        PxINm, PxOUTm, PxDIRm, PxRENm, PxSELm - PORT signals
        IN_1, OUT_1, DIR_1 - Module 1 IO signals
        IN_2, OUT_2, DIR_2 - Module 2 IO signals
        IN_3, OUT_3, DIR_3 - Module 3 IO signals

    Outputs:
        Px_m - External IO pin

--------------------------------------------------------*/

`ifdef __ICARUS__
`include "NEW/SIMULATION/IOBUF.v"
`endif 

`timescale 1ns/1ps

module PIN(
    inout Px_m,
    input PxOUTm, PxDIRm, PxRENm, 
    output PxINm,
    input [1:0] PxSELm,
    input OUT_1, DIR_1,    
    input OUT_2, DIR_2,
    input OUT_3, DIR_3,
    output IN_1, IN_2, IN_3
 );

    /* Internal signal definitions */
    wire O_buf, pull_driver;
    reg DIR_sel, OUT_sel;

    `include "NEW/PARAMS.v" // global parameter defines
    initial begin {DIR_sel, OUT_sel} = 0; end

    /* Continuous Logic Assignments */
    always @(*) begin
        case(PxSELm)
            0: begin 
                DIR_sel = PxDIRm;
                OUT_sel = PxOUTm;
            end

            1: begin 
                DIR_sel = DIR_1;
                OUT_sel = OUT_1;
            end

            2: begin 
                DIR_sel = DIR_2;
                OUT_sel = OUT_2;
            end

            3: begin 
                DIR_sel = DIR_3;
                OUT_sel = OUT_3;
            end
        endcase
    end

    `ifdef __ICARUS__
        IOBUF buf_inst(
            .I(OUT_sel), .T(~DIR_sel),
            .O(O_buf),
            .IO(Px_m)
        );
    `else
        IOBUF #(.DRIVE(12), .IOSTANDARD("LVCMOS33")) buf_inst(
            .I(OUT_sel), .T(~DIR_sel),
            .O(O_buf),
            .IO(Px_m)
        );
    `endif

    assign PxINm = O_buf;
    assign IN_1 = (PxSELm == 1) & O_buf;
    assign IN_2 = (PxSELm == 2) & O_buf;
    assign IN_3 = (PxSELm == 3) & O_buf;

    assign pull_driver = (~DIR_sel & PxRENm) ? PxOUTm : 1'bz;

    assign (weak1, weak0) Px_m = (~DIR_sel & PxRENm) ? pull_driver : 1'bz;

    /* Sequential Logic Assignments */

endmodule
