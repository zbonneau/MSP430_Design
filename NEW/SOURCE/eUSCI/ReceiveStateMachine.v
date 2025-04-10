/*--------------------------------------------------------
    Module Name: ReceiveStateMachine
    Description:
        
    Inputs:

    Outputs:

--------------------------------------------------------*/
`timescale 100ns/100ns

module ReceiveStateMachine(
    input MCLK, BITCLK, reset,
    input wUCPEN, wUCPAR, wUCMSB, wUC7BIT, wUCSPB, wUCRXEIE,
    input Rx, RxIFG, // current IFG value. Used for UCOE

    output reg RxBEN, rUCPE, rUCFE, rUCOE, rUCBRK, rSetRxIFG,

    output reg [7:0] RxData,
    output reg RxBusy
 );

    /* Internal signal definitions */
    reg [3:0] state, nextState;
    reg [7:0] data;

    initial begin 
        {RxBEN, rUCPE, rUCFE, rUCOE, rUCBRK, rSetRxIFG, RxData, RxBusy} = 0; 
        {state, nextState, data} = 0;
    end

    localparam 
        sIDLE       = 0,
        sSTART      = 1,
        sBIT1       = 2,
        sBIT2       = 3,
        sBIT3       = 4,
        sBIT4       = 5,
        sBIT5       = 6,
        sBIT6       = 7,
        sBIT7       = 8,
        sBIT8       = 9,
        sPARITY     = 10,
        sSTOP2      = 11,
        sSTOP1      = 12;

    `include "NEW/PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */
    always @(*) begin
        case(state)
            sIDLE: begin 
                nextState = (Rx) ? sIDLE : sSTART;
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
                    3'b0xx: nextState = sBIT8; // 8-bit data
                    3'b11x: nextState = sPARITY; // 7-bit, parity enabled
                    3'b101: nextState = sSTOP2; // 7-bit, no parity, 2 stop
                    3'b100: nextState = sSTOP1; // 7-bit, no parity, 1 stop
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
                nextState = Rx ? sIDLE : sSTART;
            end

            default: nextState = sIDLE;
        endcase
    end

    /* Sequential Logic Assignments */
    always @(posedge MCLK, posedge reset)
        RxBEN <= (~Rx | RxBEN & RxBusy) & ~reset;

    always @(posedge BITCLK, posedge reset) begin
        if (reset) begin
            {RxData, RxBusy} <= 0; 
            {state, data} <= 0;
        end else begin
            state <= nextState;
            case(nextState) 
                sIDLE: begin 
                    RxBusy <= 0;
                    data <= 0;
                    {rUCPE, rUCFE, rUCOE, rSetRxIFG} <= 0;
                end

                sSTART: begin
                    RxBusy <= 1;
                    data <= 0; // Clear data for new transaction
                    {rUCPE, rUCFE, rUCOE, rSetRxIFG} <= 0;
                end
                
                sBIT1: begin 
                    RxBusy <= 1;
                    data[0] <= Rx;
                end
                
                sBIT2: begin 
                    RxBusy <= 1;
                    data[1] <= Rx;
                end
                
                sBIT3: begin 
                    RxBusy <= 1;
                    data[2] <= Rx;
                end
                
                sBIT4: begin 
                    RxBusy <= 1;
                    data[3] <= Rx;
                end
                
                sBIT5: begin 
                    RxBusy <= 1;
                    data[4] <= Rx;
                end
                
                sBIT6: begin 
                    RxBusy <= 1;
                    data[5] <= Rx;
                end
                
                sBIT7: begin 
                    RxBusy <= 1;
                    data[6] <= Rx;
                end
                
                sBIT8: begin 
                    RxBusy <= 1;
                    data[7] <= Rx;
                end
                
                sPARITY: begin 
                    RxBusy <= 1;
                    if (wUCPAR) begin
                        // Even parity selected
                        rUCPE <= (^data) ^ Rx;
                    end else begin
                        // Odd parity selected
                        rUCPE <= (^data) ^ Rx ^ 1'b1;
                    end
                end
                
                sSTOP2: begin 
                    RxBusy <= 1;
                    rUCFE <= ~Rx;
                end
                
                sSTOP1: begin 
                    rUCFE  <= rUCFE | ~Rx;
                    rUCOE  <= RxIFG; // UCOE = 1 when previous read incomplete
                    rUCBRK <= (data == 0);
                    RxBusy <= 0;
                                 // old flags and current conditions
                    if (wUCRXEIE || {rUCPE, rUCFE | ~Rx, RxIFG} == 0) begin
                        // If Receive erroneous char enabled OR no errors
                        // Set RxIFG
                        rSetRxIFG <= 1;
                        // Receive character
                        case({wUCMSB, wUC7BIT})
                            2'b00: RxData <= data[7:0]; 
                            2'b01: RxData <= data[6:0];
                            2'b10: RxData <= {data[0],data[1],data[2],data[3],data[4],data[5],data[6],data[7]};
                            2'b11: RxData <= {data[0],data[1],data[2],data[3],data[4],data[5],data[6]};
                        endcase
                    end
                end
                
                default: begin end
            endcase
        end 
    end
endmodule
