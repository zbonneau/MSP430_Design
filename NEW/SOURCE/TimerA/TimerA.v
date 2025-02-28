/*--------------------------------------------------------
    Module Name: TimerA
    Description:
        Timer A is a 16-bit timer/counter with 3 modes and 
        up to 7 Capture/Compare modules. The module contains
        a generic timer counter which drives the integrated
        submodules.
    Inputs:

    Outputs:

--------------------------------------------------------*/
`timescale 100ns/100ns

module TimerA#(
    parameter START = MAP_TIMER_TA0,
    parameter CCM_COUNT = TA0_CCM_COUNT
    )(
    input MCLK, reset,
    input TACLK, ACLK, SMCLK, INCLK,
    input [15:0] MAB, MDBwrite, 
    input MW, BW,
    input TAxCLR0,
    input [CCM_COUNT-1:0] CCInA, CCInB,

    output [15:0] MDBread,
    output TAxINT1, TAxINT0,
    output [CCM_COUNT-1:0] OUTn
 );
    `include "NEW/PARAMS.v" // global parameter defines    

    /* Internal signal definitions */
    wire [CCM_COUNT-1:0] wEQU, wCCIFG, wCCIE, CCIFGclr;
    wire TimerClock;
    wire [15:0] TAxRcurrent;
    wire wTAIFG, wTAIE, TAIFGclr;

    wire TAxIVread;
    wire [3:0] TAxIV;

    /* Continuous Logic Assignments */
    assign MDBread = (MAB == START + TAxIV) ?    {12'h000, TAxIV} :
                     (BW & (MAB == START + TAxIV + 1)) ? 16'h0000 :
                                                        {16{1'bz}};
    assign TAxIVread = (MAB & ~1 == START + TAxIV);

    /* Sequential Logic Assignments */

    /* Submodule instantiations */
    TimerABase #(
        .TAnCTL_OFFSET(START + TAnCTL),
        .TAnR_OFFSET(START + TAnR),
        .TAnEX0_OFFSET(START + TAnEX0)
        )base(
        .MCLK(MCLK), .TACLK(TACLK), .ACLK(ACLK), .SMCLK(SMCLK), .INCLK(INCLK), 
        .reset(reset), 
        .MAB(MAB), .MDBwrite(MDBwrite), .MW(MW), .BW(BW), 
        .EQU0(wEQU[0]), .TAIFGclr(TAIFGclr), 
        .TimerClock(TimerClock), 
        .TAxRcurrent(TAxRcurrent), 
        .wTAIFG(wTAIFG), 
        .wTAIE(wTAIE), 
        .MDBread(MDBread)
    ); 

    TimerAINT #(
        .CCM_COUNT(CCM_COUNT)
        )INT(
        .wTAIFG(wTAIFG), .wTAIE(wTAIE), 
        .wCCIFG(wCCIFG), .wCCIE(wCCIE), 
        .TAxIVcurrent(TAxIV), 
        .TAxIVread(TAxIVread), .TAxCLR0(TAxCLR0), 
        .TAxIVnew(TAxIV), 
        .TAxINT1(TAxINT1), .TAxINT0(TAxINT0), 
        .TAIFGclr(TAIFGclr), .CCIFGclr(CCIFGclr)
    );

    genvar i;
    generate
        for (i = 0; i < CCM_COUNT; i = i + 1) begin
            CCM #(
                .CCRn_OFFSET(START + TAnCCR0 + i<<1),
                .CCTLn_OFFSET(START + TAnCCTL0 + i<<1)
                )CCM_mod(
                .MCLK(MCLK), .TimerClock(TimerClock), .reset(reset), 
                .MAB(MAB), .MDBwrite(MDBwrite), .MW(MW), .BW(BW), 
                .TAxRcurrent(TAxRcurrent), 
                .EQU0(wEQU[0]), .CCIFGclr(CCIFGclr[i]), 
                .CCInA(CCInA[i]), .CCInB(CCInB[i]), 
                .CCIFGn(wCCIFG[i]), .CCIEn(wCCIE[i]), 
                .OUTn(OUTn[i]), .EQUn(wEQU[i]), 
                .MDBread(MDBread)
            );
        end
    endgenerate

endmodule
