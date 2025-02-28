/*--------------------------------------------------------
    Module Name: CCM
    Description:
        Describes the Capture/Compare Module for the Timer
        A unit. Note: The Capture Logic is not implemented
    Inputs:
        MCLK - for MW
        TimerClock - Timer synchronizing clock
        MAB, MDBwrite, MW, BW - for MMRs
        TAxRcurrent - From TimerA Base
        EQU0 - From CCM 0
        CCIFGclr - from INT unit
        CCInA, CCInB - capture inputs, unused but described

    Outputs:
        CCIFGn, CCIEn - INT flag and enable
        OUTn - Output signal
        EQUn - comparator result
        MDBread - for MMRs

--------------------------------------------------------*/
`timescale 100ns/100ns

module CCM#(
    parameter   CCRx = TA0CCR0,
    parameter   CCTLx = TA0CCTL0
    )(
    input MCLK, TimerClock, reset,
    input [15:0] MAB, MDBwrite,
    input MW, BW,
    input [15:0] TAxRcurrent,
    input EQU0, CCIFGclr,
    input CCInA, CCInB,

    output CCIFGn, CCIEn, OUTn, EQUn,
    output reg [15:0] MDBread
 );
    `include "NEW/PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    reg [15:0] CCTLn, CCRn;
    wire SetCCIFG;

    wire [1:0] CM, CCIS;
    wire wSCS, wSCCI, wCAP;
    wire [2:0] OUTMOD;
    wire wCCI, wOUT, wCOV;

    initial begin {MDBread, CCTLn, CCRn} = 0; end

    /* Continuous Logic Assignments */
    assign {CM, CCIS, wSCS, wSCCI} = CCTLn[CM1:SCCI];
    assign {wCAP, OUTMOD, CCIEn, wCCI, wOUT, wCOV, CCIFGn} = CCTLn[CAP:CCIFG];
    assign EQUn = (TAxRcurrent == CCRn);
    assign SetCCIFG = (wCAP) ? 0 : EQUn;

    /* Describe MMR read */
    always @(*) begin
        if (BW) begin
            case(MAB) 
                CCRx:    MDBread = {8'h00, CCRn[7:0]  };
                CCRx+1:  MDBread = {8'h00, CCRn[15:8] };
                CCTLx:   MDBread = {8'h00, CCTLn[7:0] };
                CCTLx+1: MDBread = {8'h00, CCTLn[15:0]};
                default: MDBread = {16{1'bz}};
            endcase
        end else begin
            case(MAB&~1)
                CCRx:    MDBread = CCRn;
                CCTLx:   MDBread = CCTLn;
                default: MDBread = {16{1'bz}};
            endcase
        end
    end

    /* Sequential Logic Assignments */
    always @(posedge SetCCIFG) begin
        if (~reset)
            CCTLn[CCIFG] <= 1'b1;
    end

    always @(posedge MCLK or posedge reset) begin
        if (reset) begin
            {CCTLn, CCRn} <= 0;
        end else begin
            /* Describe MMR write */
            if (MW & BW) begin
                case(MAB)
                    CCRx:    CCRn[7:0]   <= MDBwrite[7:0];
                    CCRx+1:  CCRn[15:8]  <= MDBwrite[7:0];
                    CCTLx:   CCTLn[7:0]  <= MDBwrite[7:0];
                    CCTLx+1: CCTLn[15:0] <= MDBwrite[7:0];
                    default: begin end
                endcase
            end else if (MW & ~BW) begin
                case(MAB & ~1)
                    CCRx:  CCRn  <= MDBwrite;
                    CCTLx: CCTLn <= MDBwrite;
                    default: begin end
                endcase
            end

            /* Handle CCIFG Autoclear */
            if (CCIFGclr)
                CCTLn[CCIFG] <= 1'b0;

        end
    end

    /* Submodule Instantiation */
    CCMOutput Output(
        .TimerClock(TimerClock),
        .reset(reset),
        .wOUT(wOUT),
        .EQU0(EQU0),
        .EQUn(EQUn),
        .OUTMOD(OUTMOD),
        .OUTn(OUTn)
    );

endmodule
