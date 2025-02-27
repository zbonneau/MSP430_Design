/*--------------------------------------------------------
    Module Name: TimerAINT
    Description:
        Implements the TAxIV set and clear logic.
    Inputs:
        TAIFG, TAIE - INT for Timer Block
        CCIFG[n:0], CCIE[n:0] - INT for CCM block(s)
        TAxIVcurrent - current TAxIV value
        TAxIVread - true when MAB == TAxIV and MR
        TAxCLR0 - TAxCCTL0.CCIFG autoclear from INT Unit 

    Outputs:
        TAxIVnew - new value for TAxIV
        TAxINT1, TAxINT0 - INT signals sent to INT Unit
        TAIFGclr - clear Timer Block IFG
        CCIFGclr[n:0] clear TAxCCTLn.CCIFG

--------------------------------------------------------*/
`timescale 100ns/100ns

module TimerAINT#(
    parameter [2:0] CCM_COUNT = 1
    )(
    input wTAIFG, wTAIE,
    input [CCM_COUNT-1:0] wCCIFG, wCCIE,
    input [3:0] TAxIVcurrent,
    input TAxIVread, TAxCLR0,

    output reg [3:0] TAxIVnew,
    output TAxINT1, TAxINT0,
    output reg TAIFGclr,
    output reg [CCM_COUNT-1:0] CCIFGclr
 );
    `include "NEW\\PARAMS.v" // global parameter defines
    integer i;

    /* Internal signal definitions */

    initial begin {TAxIVnew, TAIFGclr, CCIFGclr} = 0; end

    /* Continuous Logic Assignments */
    assign TAxINT1 = (TAxIVnew != 0);
    assign TAxINT0 = (wCCIFG[0] & wCCIE[0]);

    // TAxIV Sets - executed in reverse-priority allows for overwrites
    always @(*) begin
        TAxIVnew = 0;

        if (wTAIFG & wTAIE)
            TAxIVnew = 4'hE;

        for (i=CCM_COUNT-1; i > 0; i = i - 1) begin
            if (wCCIFG[i] & wCCIE[i])
                TAxIVnew = i<<1;
        end
    end

    // TAxIV clears
    always @(*) begin
        TAIFGclr = 0;
        CCIFGclr = TAxCLR0;
        if (TAxIVread) begin
            case(TAxIVcurrent)
                4'h2:    CCIFGclr[1] = 1'b1;
                4'h4:    CCIFGclr[2] = 1'b1;
                4'h6:    CCIFGclr[3] = 1'b1;
                4'h8:    CCIFGclr[4] = 1'b1;
                4'hA:    CCIFGclr[5] = 1'b1;
                4'hC:    CCIFGclr[6] = 1'b1;
                4'hE:    TAIFGclr = 1'b1;
                default: begin end
            endcase
        end
    end
    
endmodule
