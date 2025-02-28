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
    parameter   CCRn_OFFSET = TA0CCR0,
    parameter   CCTLn_OFFSET = TA0CCTL0
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
    reg [15:0] CCTLx, CCRx;
    wire SetCCIFG;

    wire [1:0] CM, CCIS;
    wire wSCS, wSCCI, wCAP;
    wire [2:0] OUTMOD;
    wire wCCI, wOUT, wCOV;

    initial begin {MDBread, CCTLx, CCRx} = 0; end

    /* Continuous Logic Assignments */
    assign {CM, CCIS, wSCS, wSCCI} = CCTLx[CM1:SCCI];
    assign {wCAP, OUTMOD, CCIEn, wCCI, wOUT, wCOV, CCIFGn} = CCTLx[CAP:CCIFG];
    assign EQUn = (TAxRcurrent == CCRx);
    assign SetCCIFG = (wCAP) ? 0 : EQUn;

    /* Describe MMR read */
    always @(*) begin
        if (BW) begin
            case(MAB) 
                CCRn_OFFSET:    MDBread = {8'h00, CCRx[7:0]  };
                CCRn_OFFSET+1:  MDBread = {8'h00, CCRx[15:8] };
                CCTLn_OFFSET:   MDBread = {8'h00, CCTLx[7:0] };
                CCTLn_OFFSET+1: MDBread = {8'h00, CCTLx[15:0]};
                default:        MDBread = {16{1'bz}};
            endcase
        end else begin
            case(MAB&~1)
                CCRn_OFFSET:    MDBread = CCRx;
                CCTLn_OFFSET:   MDBread = CCTLx;
                default:        MDBread = {16{1'bz}};
            endcase
        end
    end

    /* Sequential Logic Assignments */
    always @(posedge SetCCIFG) begin
        if (~reset)
            CCTLx[CCIFG] <= 1'b1;
    end

    always @(posedge MCLK or posedge reset) begin
        if (reset) begin
            {CCTLx, CCRx} <= 0;
        end else begin
            /* Describe MMR write */
            if (MW & BW) begin
                case(MAB)
                    CCRn_OFFSET:    CCRx[7:0]   <= MDBwrite[7:0];
                    CCRn_OFFSET+1:  CCRx[15:8]  <= MDBwrite[7:0];
                    CCTLn_OFFSET:   CCTLx[7:0]  <= MDBwrite[7:0];
                    CCTLn_OFFSET+1: CCTLx[15:0] <= MDBwrite[7:0];
                    default:        begin end
                endcase
            end else if (MW & ~BW) begin
                case(MAB & ~1)
                    CCRn_OFFSET:  CCRx  <= MDBwrite;
                    CCTLn_OFFSET: CCTLx <= MDBwrite;
                    default:      begin end
                endcase
            end

            /* Handle CCIFG Autoclear */
            if (CCIFGclr)
                CCTLx[CCIFG] <= 1'b0;

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
