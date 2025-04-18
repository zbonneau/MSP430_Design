/*--------------------------------------------------------
    Module Name: TimerABase
    Description:
        Combines Base MMRs, Predivision, and Counting.
    Inputs:
        MCLK, TACLK, ACLK, SMCLK, INCLK - Clocks
        MAB, MDBwrite - from CPU
        MW, BW - SysBus control signals
        EQU0 - From CCM 0
        TAIFGclr - From IV

    Outputs:
        TimerClock
        TAxRcurrent
        TAIFG, TAIE - for IV
        MDBread - to CPU

--------------------------------------------------------*/
`timescale 100ns/100ns

module TimerABase#(
    parameter   TAnCTL_OFFSET = TA0CTL,
                TAnR_OFFSET   = TA0R,
                TAnEX0_OFFSET = TA0EX0
    )(
    input MCLK, TACLK, ACLK, SMCLK, INCLK, reset,
    input [15:0] MAB, MDBwrite,
    input MW, BW, EQU0, TAIFGclr,

    output TimerClock,
    output [15:0] TAxRcurrent,
    output wTAIFG, wTAIE,
    output reg [15:0] MDBread
 );
    `include "NEW/PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    reg [15:0] TAxCTL, TAxR, TAxEX0;
    wire [15:0] TAxRnew;
    wire TAIFGset;

    // Register Bit assignments
    wire [1:0] TASSEL, ID, MC;
    wire wTACLR;
    wire [2:0] IDEX;

    initial begin {TAxCTL, TAxR, TAxEX0, MDBread} = 0; end

    /* Continuous Logic Assignments */
    assign TASSEL = TAxCTL[TASSEL1:TASSEL0];
    assign ID = TAxCTL[ID1:ID0];
    assign MC = TAxCTL[MC1:MC0];
    assign wTACLR = TAxCTL[TACLR];
    assign wTAIE = TAxCTL[TAIE];
    assign wTAIFG = TAxCTL[TAIFG];
    assign IDEX = TAxEX0[TAIDEX2:TAIDEX0];
    assign TAxRcurrent = TAxR;

    // Handle memory reads
    always @(*) begin
        if (BW) begin
            case(MAB)
                TAnCTL_OFFSET:     MDBread = {8'h00, TAxCTL[7:0]};
                TAnCTL_OFFSET+1:   MDBread = {8'h00, TAxCTL[15:8]};
                TAnR_OFFSET:       MDBread = {8'h00, TAxR[7:0]};
                TAnR_OFFSET+1:     MDBread = {8'h00, TAxR[15:8]};
                TAnEX0_OFFSET:     MDBread = {8'h00, TAxEX0[7:0]};
                TAnEX0_OFFSET+1:   MDBread = {8'h00, TAxEX0[15:8]};
                default:           MDBread = {16{1'bz}};
            endcase
        end else begin
            case(MAB & ~1)
                TAnCTL_OFFSET:     MDBread = TAxCTL;
                TAnR_OFFSET:       MDBread = TAxR;
                TAnEX0_OFFSET:     MDBread = TAxEX0;
                default:           MDBread = {16{1'bz}};
            endcase
        end
    end

    /* Sequential Logic Assignments */
    always @(posedge MCLK) begin
        if (reset) begin
            {TAxCTL, TAxR, TAxEX0} <= 0;
        end
        else begin
            // Handle Memory Writes
            if (MW & BW) begin
                case(MAB)
                    TAnCTL_OFFSET:     TAxCTL[7:0]  <= MDBwrite[7:0];
                    TAnCTL_OFFSET+1:   TAxCTL[15:8] <= MDBwrite[7:0];
                    TAnR_OFFSET:       TAxR[7:0]    <= MDBwrite[7:0];
                    TAnR_OFFSET+1:     TAxR[15:8]   <= MDBwrite[7:0];
                    TAnEX0_OFFSET:     TAxEX0[2:0]  <= MDBwrite[2:0];
                    TAnEX0_OFFSET+1:   begin end // reserved as r0
                    default:           begin end
                endcase
            end
            else if (MW & ~BW) begin
                case(MAB & ~1)
                    TAnCTL_OFFSET:     TAxCTL <= MDBwrite;
                    TAnR_OFFSET:       TAxR <= MDBwrite;
                    TAnEX0_OFFSET:     TAxEX0[2:0] <= MDBwrite[2:0];
                    default:           begin end
                endcase
            end

            // TACLR autoclears
            if (TAxCTL[TACLR])
                TAxCTL[TACLR] <= 1'b0;

            // TAIFG autoclears when IV read
            if (TAIFGclr)
                TAxCTL[TAIFG] <= 1'b0;
        end
    end
    
    always @(posedge TimerClock or posedge wTACLR or posedge reset) begin
        if (wTACLR | reset) begin
            TAxR <= 0;
        end
        else begin
            TAxR <= TAxRnew;
            if (TAIFGset)
                TAxCTL[TAIFG] <= 1'b1;
        end
    end

    // always @(posedge TAIFGset) begin
    //     if (~reset)
    //         TAxCTL[TAIFG] <= 1'b1;
    // end

    /* Submodule Instantiation */
    TimerA_PreDiv PreDiv(
        .TAxCLK(TACLK), .ACLK(ACLK), .SMCLK(SMCLK), .INCLK(INCLK), 
        .reset(reset), .wTACLR(wTACLR), 
        .TASSEL(TASSEL), 
        .ID(ID), .IDEX(IDEX), 
        .TimerClock(TimerClock)
    );

    TimerACount Count(
        .TimerClock(TimerClock), 
        .wTACLR(wTACLR), .reset(reset), 
        .MC(MC), .EQU0(EQU0), 
        .TAxRcurrent(TAxRcurrent), 
        .TAxRnew(TAxRnew), 
        .TAIFGset(TAIFGset)
    );

endmodule
