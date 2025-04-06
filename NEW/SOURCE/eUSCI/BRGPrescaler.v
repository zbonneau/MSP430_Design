/*--------------------------------------------------------
    Module Name: BRGPrescaler
    Description:
        
    Inputs:

    Outputs:

--------------------------------------------------------*/
`timescale 100ns/100ns

module BRGPrescaler(
    input BRCLK, UCABEN,
    input [15:0] wUC0BRx,
    input m1,m2,
    output ScaleCLK
 );

    /* Internal signal definitions */
    reg [14:0] scale, nextScale;
    wire passthrough;
    reg rCLK;
    reg [3:0] state, nextState;

    localparam
        sIDLE           = 0,
        sSCALEM         = 1,
        sMOD2           = 2,
        sMOD1           = 3,
        sSCALEP         = 4,
        sODD            = 5,
        sPASSTHROUGH    = 6,
        sPMODL          = 7,
        sPMODH          = 8;

    initial begin {scale, nextScale, rCLK, state, nextState} = 0; end

    `include "NEW/PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */
    assign ScaleCLK = (passthrough) ? BRCLK : rCLK;
    assign passthrough = ((state == sPASSTHROUGH) && ({m1,m2} == 0));

    always @(*) begin
        nextScale = scale;
        nextState = state;
        case(state)
            sIDLE: begin
                if (UCABEN == 1 && wUC0BRx[15:1] == 0) begin
                    nextState = sPASSTHROUGH;
                    nextScale = 0;
                end else if (UCABEN == 1) begin
                    nextState = sSCALEM;
                    nextScale = wUC0BRx >> 1;
                end else begin
                    nextState = sIDLE;
                    nextScale = 0;
                end
            end

            sSCALEM: begin
                nextScale = scale - 1;
                if (scale == 1) begin
                    case({m1,m2})
                        2'b11: nextState = sMOD2;
                        2'b10: nextState = sMOD1;
                        2'b01: nextState = sMOD1;
                        2'b00: begin 
                            nextState = sSCALEP; 
                            nextScale = wUC0BRx >> 1; 
                        end
                    endcase
                end else begin
                    nextState = sSCALEM;
                end
            end

            sMOD2: begin
                nextState = sMOD1;
            end

            sMOD1: begin
                nextState = sSCALEP;
                nextScale = wUC0BRx >> 1;
            end

            sSCALEP: begin
                nextScale = scale - 1;
                if (scale == 1) begin
                    nextState = (wUC0BRx[0]) ? sODD : sSCALEM;
                    nextScale = wUC0BRx >> 1;
                end else begin
                    nextState = sSCALEP;
                end
            end

            sODD: begin
                nextState = sSCALEM;
                nextScale = wUC0BRx >> 1;
            end

            sPASSTHROUGH: begin
                case({m1,m2})
                    2'b11: nextState = sPMODL;
                    2'b10: nextState = sPMODH;
                    2'b01: nextState = sPMODH;
                    2'b00: nextState = sPASSTHROUGH;
                endcase
            end

            sPMODL: begin
                nextState = sPMODH;
            end

            sPMODH: begin
                nextState = sPASSTHROUGH;
            end

            default: begin 
                nextState = sIDLE;
                nextScale = 0;
            end
        endcase
    end

    /* Sequential Logic Assignments */
    always @(negedge BRCLK) begin
        if (UCABEN == 0) begin
            state <= sIDLE;
            scale <= 0;
        end else begin
            state <= nextState;
            scale <= nextScale;
            case (nextState)
                sIDLE: begin 
                    rCLK <= 0;
                end

                sSCALEM: begin 
                    rCLK <= 0;
                end

                sMOD2: begin 
                    rCLK <= 0;
                end

                sMOD1: begin 
                    rCLK <= 0;
                end

                sSCALEP: begin 
                    rCLK <= 1;
                end

                sODD: begin 
                    rCLK <= 1;
                end

                sPASSTHROUGH: begin 
                    rCLK <= 0;
                end

                sPMODL: begin
                    rCLK <= 0;
                end

                sPMODH: begin
                    rCLK <= 1;
                end

                default: begin
                    rCLK <= 0;
                end
            endcase
        end
    end
endmodule
