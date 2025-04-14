/*--------------------------------------------------------
    Module Name: TransmitStateMachine
    Description:
        
    Inputs:

    Outputs:

--------------------------------------------------------*/
`timescale 100ns/100ns

module TransmitStateMachine(
    input BITCLK, reset,
    input wUCPEN, wUCPAR, wUCMSB, wUC7BIT, wUCSPB,
    input [7:0] TxData,
    input iTXIFG,

    output TxBEN, setTXIFG, setTXCPTIFG, TxBusy, 
    output reg Tx
 );

    /* Internal signal definitions */
    reg [3:0] state, nextState;
    reg [7:0] data;

    initial begin 
        Tx = 1;
        {state, nextState, data} = 0;
    end

    localparam 
        sIDLE   = 0,
        sSTART  = 1,
        sBIT1   = 2,
        sBIT2   = 3,
        sBIT3   = 4,
        sBIT4   = 5,
        sBIT5   = 6,
        sBIT6   = 7,
        sBIT7   = 8,
        sBIT8   = 9,
        sPARITY = 10,
        sSTOP2  = 11,
        sSTOP1  = 12;

    `include "NEW/PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */
    assign TxBEN        = ~iTXIFG | TxBusy;
    assign setTXIFG     = (state == sSTART);
    assign setTXCPTIFG  = (state == sSTOP1);
    assign TxBusy       = (state != sIDLE);
    always @(*) begin
        case(state)
            sIDLE: begin 
                nextState = ~iTXIFG ? sSTART : sIDLE;
            end

            sSTART: begin 
                nextState = sBIT1;
            end

            sBIT1: begin 
                nextState = sBIT2;
            end

            sBIT2: begin 
                nextState = sBIT3;
            end

            sBIT3: begin 
                nextState = sBIT4;
            end

            sBIT4: begin 
                nextState = sBIT5;
            end

            sBIT5: begin 
                nextState = sBIT6;
            end

            sBIT6: begin 
                nextState = sBIT7;
            end

            sBIT7: begin 
                casex({wUC7BIT, wUCPEN, wUCSPB})
                    3'b0xx: nextState = sBIT8;
                    3'b11x: nextState = sPARITY;
                    3'b101: nextState = sSTOP2;
                    3'b100: nextState = sSTOP1;
                endcase
            end

            sBIT8: begin 
                casex({wUCPEN, wUCSPB})
                    2'b1x: nextState = sPARITY;
                    2'b01: nextState = sSTOP2;
                    2'b00: nextState = sSTOP1;
                endcase
            end

            sPARITY: begin 
                nextState = wUCSPB ? sSTOP2 : sSTOP1;
            end

            sSTOP2: begin 
                nextState = sSTOP1;
            end

            sSTOP1: begin 
                nextState = ~iTXIFG ? sSTART : sIDLE;
            end

            default: begin 

                nextState = sIDLE;
            end
        endcase
    end

    /* Sequential Logic Assignments */
    always @(posedge BITCLK or posedge reset) begin
        if (reset) begin
            state = sIDLE; data = 0;
            Tx = 1; 
        end else begin
            state <= nextState;
            case(nextState)
                sIDLE: begin 
                    Tx <= 1;
                end

                sSTART: begin 
                    Tx <= 0;
                    case({wUCMSB, wUC7BIT})
                        2'b00: data <= TxData;
                        2'b01: data <= TxData[6:0];
                        2'b10: data <= {TxData[0], TxData[1], TxData[2], TxData[3], TxData[4], TxData[5], TxData[6], TxData[7]};
                        2'b11: data <= {1'b0,      TxData[0], TxData[1], TxData[2], TxData[3], TxData[4], TxData[5], TxData[6]};
                    endcase
                end

                sBIT1: begin 
                    Tx <= data[0];
                end

                sBIT2: begin 
                    Tx <= data[1];
                end

                sBIT3: begin 
                    Tx <= data[2];
                end

                sBIT4: begin 
                    Tx <= data[3];
                end

                sBIT5: begin 
                    Tx <= data[4];
                end

                sBIT6: begin 
                    Tx <= data[5];
                end

                sBIT7: begin 
                    Tx <= data[6];
                end

                sBIT8: begin 
                    Tx <= data[7];
                end

                sPARITY: begin 
                    Tx <= ~wUCPAR ^ (^data);
                end

                sSTOP2: begin 
                    Tx <= 1;
                end

                sSTOP1: begin 
                    Tx <= 1;
                end

                default: begin end
            endcase
        end
    end
endmodule
