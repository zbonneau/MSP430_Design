`include "MSP430_ALU\\instruction_patterns.v"

module ALUX(
    input [15:0] instr, 
    input [19:0] src, dst,
    input Cin, Vin, Nin, Zin,
    output reg [19:0] result
    output reg Cout, Vout, Nout, Zout
 );

    initial begin {result, Cout, Vout, Nout, Zout} = 0; end

    always@(*) begin
        {result, Cout, Vout, Nout, Zout} = 0;

        case({instr[15:12], 5'b0000_0, instr[6], 6'b00_0000})
            ADDRESS: begin
                
            end

            FORMATII: begin

            end

            JMP2, JMP24, JMP3, JMP34: begin

            end

            MOV: begin
                result <= {4'h0, src[15:0]};
                {Cout, Vout, Nout, Zout} <= {Cin, Vin, Nin, Zin};
            end

            MOVB: begin
                result <= {12'h0, src[7:0]};
                {Cout, Vout, Nout, Zout} <= {Cin, Vin, Nin, Zin};
            end

            ADD: begin
                {Cout, result[15:0]} = src[15:0]+dst[15:0];
                Nout = result[15];
                Zout = (result == 0);
                Vout = (src[15] & dst[15] & ~result[15] | ~src[15] & ~dst[15] & result[15]);
            end

            ADDB: begin
                {Cout, result[7:0]} = src[7:0]+dst[7:0];
                Nout = result[7];
                Zout = (result == 0);
                Vout = (src[7] & dst[7] & ~result[7] | ~src[7] & ~dst[7] & result[7]);
            end

            ADDC: begin
                {Cout, result[15:0]} = src[15:0]+dst[15:0] + Cin;
                Nout = result[15];
                Zout = (result == 0);
                Vout = (src[15] & dst[15] & ~result[15] | ~src[15] & ~dst[15] & result[15]);
            end

            ADDCB: begin
                {Cout, result[7:0]} = src[7:0]+dst[7:0] + Cin;
                Nout = result[7];
                Zout = (result == 0);
                Vout = (src[7] & dst[7] & ~result[7] | ~src[7] & ~dst[7] & result[7]);
            end

            SUBC: begin
                {Cout, result[15:0]} = dst[15:0] - src[15:0] + 1 + Cin;
                Nout = result[15];
                Zout = (result == 0);
                Vout = (dst[15] & ~src[15] & ~result[15] | ~dst[15] & src[15] & result[15]);
                      // neg    -  pos     =  pos       OR  pos     - neg     = neg
            end

            SUBCB: begin
                {Cout, result[7:0]} = dst[7:0] - src[7:0] + 1 + Cin;
                Nout = result[7];
                Zout = (result == 0);
                Vout = (dst[7] & ~src[7] & ~result[7] | ~dst[7] & src[7] & result[7]);
                      // neg    -  pos     =  pos       OR  pos     - neg     = neg
            end

            SUB, CMP: begin // subtract and compare execute the same microperation, with/without dst overwrite
                {Cout, result[15:0]} = dst[15:0] - src[15:0];
                Nout = result[15];
                Zout = (result == 0);
                Vout = (dst[15] & ~src[15] & ~result[15] | ~dst[15] & src[15] & result[15]);
            end

            SUBB, CMPB: begin
                {Cout, result[7:0]} = dst[7:0] - src[7:0];
                Nout = result[7];
                Zout = (result == 0);
                Vout = (dst[7] & ~src[7] & ~result[7] | ~dst[7] & src[7] & result[7]);
            end

            DADD: begin
                Cout = Cin; // Cout used ass ripple-carry for this instruction

                // See DADD_test.v for explanation of this block.
                // TL;DR causes carry through nibbles on decimal overflow rather than hex overflow
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

            DADDB: begin
                Cout = Cin;

                {Cout, result[3:0]}   = (dst[3:0]   + src[3:0]   + Cout < 10) ? dst[3:0]   + src[3:0]   + Cout
                                                                              : dst[3:0]   + src[3:0]   + Cout + 6;
                {Cout, result[7:4]}   = (dst[7:4]   + src[7:4]   + Cout < 10) ? dst[7:4]   + src[7:4]   + Cout
                                                                              : dst[7:4]   + src[7:4]   + Cout + 6;
                Nout = result[7];
                Zout = (result == 0);
                Vout = 0; // Undefined by MSP430 Family Guide
            end

            BIT, AND: begin // Bit test and bitwise And execute same microperation, with/without dst overwrite
                result[15:0] = src[15:0] & dst[15:0];
                Nout = result[15];
                Zout = (result == 0);
                Cout = ~Zout;
                Vout = 0; // defined as 0 by MSP430 Family Guide
            end

            BITB, ANDB: begin
                result[7:0] = src[7:0] & dst[7:0];
                Nout = result[7];
                Zout = (result == 0);
                Cout = ~Zout;
                Vout = 0; // defined as 0 by MSP430 Family Guide
            end

            BIC: begin
                result[15:0] = ~src[15:0] & dst[15:0];
                Nout = Nin;
                Zout = Zin;
                Cout = Cin;
                Vout = Vin;
            end

            BICB: begin
                result[7:0] = ~src[7:0] & dst[7:0];
                Nout = Nin;
                Zout = Zin;
                Cout = Cin;
                Vout = Vin;
            end

            BIS: begin
                result[15:0] = src[15:0] | dst[15:0];
                Nout = Nin;
                Zout = Zin;
                Cout = Cin;
                Vout = Vin;
            end

            BISB: begin
                result[7:0] = src[7:0] | dst[7:0];
                Nout = Nin;
                Zout = Zin;
                Cout = Cin;
                Vout = Vin;
            end

            XOR: begin
                result[15:0] = src[15:0] ^ dst[15:0];
                Nout = result[15];
                Zout = (result == 0);
                Cout = ~Zout;
                Vout = src[15] & dst[15]; 
            end

            XORB: begin
                result[7:0] = src[7:0] ^ dst[7:0];
                Nout = result[7];
                Zout = (result == 0);
                Cout = ~Zout;
                Vout = src[7] & dst[7]; 
            end

            default: begin // unreadable instruction
                result[15:0] = 16'hDEAD;
                {Nout, Zout, Cout, Vout} = 0;
            end
        endcase
    end
endmodule