module Dadd(
    input [15:0] src, dst,
    input Cin,
    output reg [15:0] result,
    output reg Cout, Vout, Nout, Zout
);

    reg Cinternal = 0;

    initial begin {result, Cout, Vout, Nout, Zout} = 0; end

        always @(*) begin
            Cout = Cin;

            // The following code block computes the following microperations
                // tempSum <- src + dst + Cin
                // if tempSum >= 10: tempSum <- tempSum + 6
                // sum = tempSum[3:0]
                // Cout = tempSum[4]

                // Repeat this for the 4 nibbles of a 16-bit word result

            {Cout, result[3:0]}   = (dst[3:0]   + src[3:0]   + Cout < 10) ? dst[3:0]   + src[3:0]   + Cout
                                                                          : dst[3:0]   + src[3:0]   + Cout + 6;
            {Cout, result[7:4]}   = (dst[7:4]   + src[7:4]   + Cout < 10) ? dst[7:4]   + src[7:4]   + Cout
                                                                          : dst[7:4]   + src[7:4]   + Cout + 6;
            {Cout, result[11:8]}  = (dst[11:8]  + src[11:8]  + Cout < 10) ? dst[11:8]  + src[11:8]  + Cout
                                                                          : dst[11:8]  + src[11:8]  + Cout + 6;
            {Cout, result[15:12]} = (dst[15:12] + src[15:12] + Cout < 10) ? dst[15:12] + src[15:12] + Cout
                                                                          : dst[15:12] + src[15:12] + Cout + 6;
            Nout = result[15];
            Zout = (result == 0);
            Vout = 0; // Undefined by MSP430 Family Guide
        end
endmodule

`timescale 100ns/10ns // MSP430FR6989 default MCLK = 1 MHz. T = 1 us. Divide wait time into 1/10th clock speed

module Dadd_tb;
    reg [15:0] src, dst;
    reg Cin;
    wire [15:0] result;
    wire Cout, Vout, Nout, Zout;

    Dadd uut(src, dst, Cin, result, Cout, Vout, Nout, Zout);
    
    initial begin
        // If simulating with Xilinx Vivado or other HDL IDE, comment out the following 2 lines
        $dumpfile("Dadd.vcd");
        $dumpvars(0, Dadd_tb);

        // Test 1: 0 + 0 + 0
        Cin = 0; {src, dst} = 32'h0; #10; // split Cin, src/dst for hex width cleanliness

        // Test 2: 0 + 1234 + 5678
        Cin = 0; {src, dst} = 32'h1234_5678; #10;

        // Test 3: 0 + 7999 + 0001 <-> MAXPOS + 1 = MAXNEG
        Cin = 0; {src, dst} = 32'h7999_0001; #10;

        // Test 4: 1 + 9999 + 0000 <-> MAX_UNSIGNED + 1 = Carry Overflow + Zero(0000h)
        Cin = 1; {src, dst} = 32'h9999_0000; #10;

        // Test 5: 0 + 5000 + 0321 <-> Test Cin with no Cout
        Cin = 1; {src, dst} = 32'h5000_0321; #10;

        $finish;
    end

endmodule