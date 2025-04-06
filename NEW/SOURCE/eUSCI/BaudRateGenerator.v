/*--------------------------------------------------------
    Module Name: BaudRateGenerator
    Description:
        
    Inputs:

    Outputs:

--------------------------------------------------------*/
`timescale 100ns/100ns

module BaudRateGenerator(
    input BRCLK, UCABEN,
    input [15:0] wUC0BRx, // clock prescaler
    input [3:0]  wUCBRFx, // first mod stage for BITCLK16
    input [7:0]  wUCBRSx, // second mod stage for BITCLK
    input        wUCOS16,

    output       BITCLK, MajorityClk
 );

    /* Internal signal definitions */
    // Oversampling 16x signals
    wire BITCLK16;
    reg [3:0] Div16;
    // modulation stage 2 signals
    wire m2;
    reg [2:0] BitCount;
    // modulation stage 1 signals
    wire m1;
    reg [15:0] m1pattern;

    initial begin {Div16, BitCount, m1pattern} = 0; end

    `include "NEW/PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */
    assign BITCLK      = (wUCOS16) ? Div16[3] : BITCLK16;
    assign MajorityClk = (wUCOS16) ? BITCLK16 : BRCLK;

    assign m2 = wUCBRSx[3'd7-BitCount];
    assign m1 = m1pattern[16'd15-Div16];

    always @(*) begin
        case(wUCBRFx)
            4'h0: m1pattern = 16'b0000_0000_0000_0000;
            4'h1: m1pattern = 16'b0100_0000_0000_0000;
            4'h2: m1pattern = 16'b0100_0000_0000_0001;
            4'h3: m1pattern = 16'b0110_0000_0000_0001;
            4'h4: m1pattern = 16'b0110_0000_0000_0011;
            4'h5: m1pattern = 16'b0111_0000_0000_0011;
            4'h6: m1pattern = 16'b0111_0000_0000_0111;
            4'h7: m1pattern = 16'b0111_1000_0000_0111;
            4'h8: m1pattern = 16'b0111_1000_0000_1111;
            4'h9: m1pattern = 16'b0111_1100_0000_1111;
            4'hA: m1pattern = 16'b0111_1100_0001_1111;
            4'hB: m1pattern = 16'b0111_1110_0001_1111;
            4'hC: m1pattern = 16'b0111_1110_0011_1111;
            4'hD: m1pattern = 16'b0111_1111_0011_1111;
            4'hE: m1pattern = 16'b0111_1111_0111_1111;
            4'hF: m1pattern = 16'b0111_1111_1111_1111;
        endcase
    end

    /* Sequential Logic Assignments */
    always @(negedge BITCLK16, negedge UCABEN) begin
        if (~UCABEN | ~wUCOS16) begin
            Div16 <= 0;
        end else begin
            Div16 <= Div16 + 1;
        end
    end

    always @(negedge BITCLK, negedge UCABEN) begin
        if (~UCABEN) begin
            BitCount <= 0;
        end else begin
            BitCount <= BitCount + 1;
        end
    end

    /* Submodule Instantiations */
    BRGPrescaler Scaler(
        .BRCLK(BRCLK), .UCABEN(UCABEN),
        .wUC0BRx(wUC0BRx),
        .m1(m1), .m2(m2),
        .ScaleCLK(BITCLK16)
    );

endmodule
