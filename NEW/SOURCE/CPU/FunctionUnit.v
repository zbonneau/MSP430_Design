/*--------------------------------------------------------
    Module Name : Function Unit
    Description: 
        Describes the MSP430 CPU for 16-, 8-bit data
        No Extended/Address instructions
    
    Inputs:
        src, dst - operands
        IW - Instruction Word
        (Z,V,N,C)in - Status Bits from SR

    Outputs:
        (Z,V,N,C)out - Status Bits from operation
        result - data out
        
--------------------------------------------------------*/
`timescale 100ns/100ns

module FunctionUnit(
    input [15:0] src, dst, IW,
    input Zin, Vin, Nin, Cin,
    output reg [15:0] result,
    output reg Zout, Vout, Nout, Cout
    );

    initial begin {result, Zout, Vout, Nout, Cout} <= 0; end

    `include "NEW\\PARAMS.v"

    always @(IW, src, dst, Zin, Vin, Nin, Cin) begin
        // By default, status bits are not changed
        {Zout, Vout, Nout, Cout} = {Zin, Vin, Nin, Cin}; 
        result = 0; // set 0 so that byte operations have high byte = 0
        case ({IW[15:12], 5'b0, IW[6], 6'b0})
            16'h1000, 16'h1040: begin
                case ({IW[15:6], 6'b0})
                    RRC  : begin 
                        {result, Cout} = {Cin, dst};
                        Zout <= (result == 0);
                        Nout <= result[15];
                        Vout <= 0;
                    end

                    RRCB : begin 
                        {result[7:0], Cout} = {Cin, dst[7:0]};
                        Zout <= (result == 0);
                        Nout <= result[7];
                        Vout <= 0;
                    end

                    SWPB : begin 
                        result = {dst[7:0], dst[15:8]};
                    end

                    RRA  : begin 
                        {result, Cout} = {dst[15], dst[15:0]};
                        Zout <= (result == 0);
                        Nout <= result[15];
                        Vout <= 0;
                    end

                    RRAB : begin 
                        {result[7:0], Cout} = {dst[7], dst[7:0]};
                        Zout <= (result == 0);
                        Nout <= result[7];
                        Vout <= 0;
                    end

                    SXT  : begin 
                        result = {{8{dst[7]}}, dst[7:0]};
                        Zout <= (result == 0);
                        Cout <= (result != 0);
                        Nout <= result[15];
                        Vout <= 1'b0;
                    end

                    PUSH : begin 
                        result <= dst;
                    end

                    PUSHB: begin 
                        result[7:0] <= dst[7:0];  
                    end

                    CALL : begin 
                        result <= dst; // PC
                    end

                    RETI : begin 
                        result <= src; // M[SP+]
                    end

                    default: begin 
                        result = 16'hDEAD;// default 1 OP Instruction - dead
                    end
                endcase
            end

            16'h2000, 16'h2040, 16'h3000, 16'h3040: begin // jumps
                // New Address offset from PC by 10-bit SE offset
                result = dst + {{5{IW[9]}}, IW[9:0], 1'b0}; // assume condition is met
                case({IW[15:10], 10'b0})
                        // if Condition not met, result = dst (PC)
                    JNE, JNZ: begin
                        if (Zin) begin result = dst; end
                     end

                    JEQ, JZ: begin
                        if (~Zin) begin result = dst; end
                     end

                    JNC: begin
                        if (Cin) begin result = dst; end
                     end

                    JC : begin
                        if (~Cin) begin result = dst; end
                     end

                    JN : begin
                        if (~Nin) begin result = dst; end
                     end

                    JGE: begin
                        if (Nin^Vin) begin result = dst; end
                     end

                    JL : begin
                        if (~Nin^Vin) begin result = dst; end
                     end

                    JMP: begin
                         
                     end

                endcase
            end

            MOV  : begin 
                result <= src;
            end

            MOVB : begin 
                result[7:0] <= src[7:0];
            end

            ADD  : begin 
                {Cout, result} = src + dst;
                Zout <= (result == 0);
                Nout <= result[15];
                Vout <= (src[15] &  dst[15] & ~result[15] |
                        ~src[15] & ~dst[15] &  result[15]);
            end

            ADDB : begin 
                {Cout, result[7:0]} = src[7:0] + dst[7:0];
                Zout <= (result == 0);
                Nout <= result[7];
                Vout <= (src[7] &  dst[7] & ~result[7] |
                        ~src[7] & ~dst[7] &  result[7]);
            end

            ADDC : begin 
                {Cout, result} = src + dst + Cin;
                Zout <= (result == 0);
                Nout <= result[15];
                Vout <= (src[15] &  dst[15] & ~result[15] |
                        ~src[15] & ~dst[15] &  result[15]);
            end

            ADDCB: begin 
                {Cout, result[7:0]} = src[7:0] + dst[7:0] + Cin;
                Zout <= (result == 0);
                Nout <= result[7];
                Vout <= (src[7] &  dst[7] & ~result[7] |
                        ~src[7] & ~dst[7] &  result[7]);
            end

            // Subtraction operations compute 17-bit subtraction. Vectored dst, src extend 
            // operands as unsigned operands to compute the correct Carry values

            SUBC : begin 
                {Cout, result} = {1'b0, dst} + {1'b0, ~src} + Cin;
                Zout <= (result == 0);
                Nout <= result[15];
                Vout <= (dst[15] & ~src[15] & ~result[15] | 
                        ~dst[15] &  src[15] &  result[15]);
            end

            SUBCB: begin 
                {Cout, result[7:0]} = {1'b0, dst[7:0]} + {1'b0, ~src[7:0]} + Cin;
                Zout <= (result == 0);
                Nout <= result[7];
                Vout <= (dst[7] & ~src[7] & ~result[7] | 
                        ~dst[7] &  src[7] &  result[7]);
            end

            SUB, CMP  : begin // SUB, CMP execute the same operation, with/wout dst overwrite
                {Cout, result} = {1'b0, dst} + {1'b0, ~src} + 1'b1;
                // {Cout, result} = dst - src;
                Zout <= (result == 0);
                Nout <= result[15];
                Vout <= (dst[15] & ~src[15] & ~result[15] | 
                        ~dst[15] &  src[15] &  result[15]);
            end

            SUBB, CMPB : begin 
                {Cout, result[7:0]} = {1'b0, dst[7:0]} + {1'b0, ~src[7:0]} + 1'b1;
                // {Cout, result[7:0]} = dst[7:0] - src[7:0];
                Zout <= (result == 0);
                Nout <= result[7];
                Vout <= (dst[7] & ~src[7] & ~result[7] | 
                        ~dst[7] &  src[7] &  result[7]);
            end

            DADD : begin 
                Cout = Cin;

                // See CPUX\DADD_test.v for further explanation
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
                Nout <= result[7];
                Zout <= (result == 0);
                Vout <= 0; // Undefined by MSP430 Family Guide
            end

            BIT, AND  : begin // Bit test and bitwise And execute same microperation, with/without dst overwrite
                result = src & dst;
                Nout <= result[15];
                Zout <= (result == 0);
                Cout <= (result != 0);
                Vout <= 0; // defined as 0 by MSP430 Family Guide
            end

            BITB, ANDB : begin 
                result[7:0] = src[7:0] & dst[7:0];
                Nout <= result[7];
                Zout <= (result == 0);
                Cout <= (result != 0);
                Vout <= 0; // defined as 0 by MSP430 Family Guide
            end

            BIC  : begin 
                result = ~src & dst;
            end

            BICB : begin 
                result[7:0] = ~src[7:0] & dst[7:0];
            end

            BIS  : begin 
                result = src | dst;
            end

            BISB : begin 
                result[7:0] = src[7:0] | dst[7:0];
            end

            XOR  : begin 
                result = src ^ dst;
                Zout <= (result == 0);
                Cout <= (result != 0);
                Nout <= result[15];
                Vout <= src[15] & dst[15];
            end

            XORB : begin 
                result[7:0] = src[7:0] ^ dst[7:0];
                Zout <= (result == 0);
                Cout <= (result != 0);
                Nout <= result[7];
                Vout <= src[7] & dst[7];
            end

            default: begin 
                result = 16'hDEAD;
            end
        endcase
    end
endmodule