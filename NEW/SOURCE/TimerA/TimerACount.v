/*--------------------------------------------------------
    Module Name: TimerACount
    Description:
        TimerA Count is responsible for the counting logic of TAxR. It 
        provides new count values and triggers the TAxCTL.TAIFG set.

    Inputs:
        TimerClock - From pre-divider
        TACLR - clear UpDown FF,
        reset - POR
        MC - mode control
        EQU0 - clears TAxR in MC__UP and MC_UPDOWN
        TAxRcurrent - current value of TAxR

    Outputs:
        TAxRnew - new value of TAxR
        TAIFGset - triggers set on rising edge

--------------------------------------------------------*/
`timescale 100ns/100ns

module TimerACount(
    input TimerClock,
    input wTACLR, reset,
    input [1:0] MC,
    input EQU0, 
    input [15:0] TAxRcurrent,

    output reg [15:0] TAxRnew,
    output TAIFGset
 );
    `include "NEW\\PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    reg UpDownFF;

    initial begin {UpDownFF} = 0; end

    /* Continuous Logic Assignments */
    assign TAIFGset = (MC != MC__STOP) && (TAxRnew == 0);

    always @(*) begin
        case(MC)
            MC__STOP: TAxRnew = TAxRcurrent;
            MC__UP:     TAxRnew = (EQU0) ? 0 : TAxRcurrent + 1;
            MC__CONTINUOUS: TAxRnew = TAxRcurrent + 1;
            MC__UPDOWN: TAxRnew = (UpDownFF) ? TAxRcurrent - 1: TAxRcurrent + 1;
        endcase 
    end
    /* Sequential Logic Assignments */
    always @(posedge TimerClock or posedge (wTACLR | reset)) begin
        if (reset | wTACLR)
            UpDownFF <= 0;
        else if (EQU0 && (MC == MC__UPDOWN))
            UpDownFF <= 1;
        else if (TAxRnew == 16'h0000 && (MC == MC__UPDOWN))
            UpDownFF <= 0;
    end

endmodule
