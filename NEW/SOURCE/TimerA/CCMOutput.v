/*--------------------------------------------------------
    Module Name: CCMOutput
    Description:
        This module implements the Output logic of a Capture/
        Compare module.

    Inputs:
        TimerClock - from TimerA Base
        wOUT - From TAnCCTLm.OUT
        EQU0 - From CCM 0 module
        EQUn - From CCM n module (n can = 0)
        OUTMOD - From TAnCCTLm.OUTMOD

    Outputs:
        OUTn -> to PIN module

--------------------------------------------------------*/
`timescale 100ns/100ns

module CCMOutput(
    input TimerClock, reset, 
    input wOUT, EQU0, EQUn,
    input [2:0] OUTMOD,
    output OUTn
 );
    `include "NEW/PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    reg OutQ;
    assign OUTn = (OUTMOD == 0) ? (wOUT & ~reset) : OutQ;

    initial begin {OutQ} = 0; end

    /* Sequential Logic Assignments */
    always @(posedge TimerClock or posedge reset) begin
        if (reset) 
            OutQ <= 1'b0;
        else begin
            case(OUTMOD)
            OUTMOD__OUT:     OutQ <= OutQ;    
            OUTMOD__SET:     OutQ <= OutQ | EQUn;        
            OUTMOD__TOG_RST: OutQ <= ~(EQU0) & (EQUn ^ OutQ);  
            OUTMOD__SET_RST: OutQ <= ~(EQU0) & (EQUn | OutQ);         
            OUTMOD__TOG:     OutQ <= (OutQ ^ EQUn);        
            OUTMOD__RST:     OutQ <= ~(EQUn) & OutQ;        
            OUTMOD__TOG_SET: OutQ <= EQU0 | (EQUn ^ OutQ);        
            OUTMOD__RST_SET: OutQ <= EQU0 | (~EQUn & OutQ);        
            endcase
        end
    end 
endmodule
