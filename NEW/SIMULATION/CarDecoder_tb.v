/*--------------------------------------------------------
    Module Name : Car Decoder Testbench
    Description:
        Verifies functionality of CAR Decoder

--------------------------------------------------------*/

`include "NEW\\CarDecoder.v"
`default_nettype none
`timescale 100ns/100ns

module tb_CarDecoder;
reg [15:0] IW;
wire [CAR_BITS-1:0] CAR;

`include "NEW\\MACROS.v"

CarDecoder uut
(
.IW(IW), .CAR(CAR)
);

localparam CLK_PERIOD = 10;

initial begin
    $display("| Inst | CAR |");
    $display("|------|-----|");
    $monitor("| %4h | %2d  |", IW, CAR);
end

initial begin
    /* Test 1-op combinations */
    IW = RRC           | REGISTER_MODE<<4 | R0                   ; #CLK_PERIOD
    IW = RRCB          | REGISTER_MODE<<4 | R2                   ; #CLK_PERIOD
    IW = SWPB          | INDEXED_MODE <<4 | R0                   ; #CLK_PERIOD
    IW = RRA           | INDEXED_MODE <<4 | R3                   ; #CLK_PERIOD
    IW = RRAB          | INDIRECT_MODE<<4 | R0                   ; #CLK_PERIOD
    IW = SXT           | INDIRECT_MODE<<4 | R2                   ; #CLK_PERIOD
    IW = PUSH          | REGISTER_MODE<<4 | R0                   ; #CLK_PERIOD
    IW = PUSH          | REGISTER_MODE<<4 | R2                   ; #CLK_PERIOD
    IW = PUSH          | REGISTER_MODE<<4 | R3                   ; #CLK_PERIOD
    IW = PUSH          | INDEXED_MODE <<4 | R0                   ; #CLK_PERIOD
    IW = PUSH          | INDEXED_MODE <<4 | R2                   ; #CLK_PERIOD
    IW = PUSH          | INDEXED_MODE <<4 | R3                   ; #CLK_PERIOD
    IW = PUSHB         | INDIRECT_MODE<<4 | R0                   ; #CLK_PERIOD
    IW = PUSHB         | INDIRECT_MODE<<4 | R2                   ; #CLK_PERIOD
    IW = PUSHB         | INDIRECT_MODE<<4 | R3                   ; #CLK_PERIOD
    IW = CALL          | REGISTER_MODE<<4 | R0                   ; #CLK_PERIOD
    IW = CALL          | REGISTER_MODE<<4 | R2                   ; #CLK_PERIOD
    IW = CALL          | REGISTER_MODE<<4 | R3                   ; #CLK_PERIOD
    IW = CALL          | INDEXED_MODE <<4 | R0                   ; #CLK_PERIOD
    IW = CALL          | INDEXED_MODE <<4 | R2                   ; #CLK_PERIOD
    IW = CALL          | INDEXED_MODE <<4 | R3                   ; #CLK_PERIOD
    IW = CALL          | INDIRECT_MODE<<4 | R0                   ; #CLK_PERIOD
    IW = CALL          | INDIRECT_MODE<<4 | R2                   ; #CLK_PERIOD
    IW = CALL          | INDIRECT_MODE<<4 | R3                   ; #CLK_PERIOD
    IW = RETI                                                    ; #CLK_PERIOD
    IW = JNE                                                     ; #CLK_PERIOD
    IW = JNZ                                                     ; #CLK_PERIOD
    IW = JEQ                                                     ; #CLK_PERIOD
    IW = JZ                                                      ; #CLK_PERIOD
    IW = JNC                                                     ; #CLK_PERIOD
    IW = JC                                                      ; #CLK_PERIOD
    IW = JN                                                      ; #CLK_PERIOD
    IW = JGE                                                     ; #CLK_PERIOD
    IW = JL                                                      ; #CLK_PERIOD
    IW = JMP                                                     ; #CLK_PERIOD
    IW = MOV   | R0<<8 | REGISTER_MODE<<4 | R0 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = MOVB  | R2<<8 | REGISTER_MODE<<4 | R2 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = ADD   | R3<<8 | REGISTER_MODE<<4 | R3 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = ADDB  | R0<<8 | REGISTER_MODE<<4 | R0 | INDEXED_MODE <<7; #CLK_PERIOD
    IW = ADDC  | R2<<8 | REGISTER_MODE<<4 | R2 | INDEXED_MODE <<7; #CLK_PERIOD
    IW = ADDCB | R3<<8 | REGISTER_MODE<<4 | R3 | INDEXED_MODE <<7; #CLK_PERIOD
    IW = SUBC  | R0<<8 | INDEXED_MODE <<4 | R0 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = SUBCB | R2<<8 | INDEXED_MODE <<4 | R2 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = SUB   | R3<<8 | INDEXED_MODE <<4 | R3 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = SUBB  | R0<<8 | INDEXED_MODE <<4 | R0 | INDEXED_MODE <<7; #CLK_PERIOD
    IW = CMP   | R2<<8 | INDEXED_MODE <<4 | R2 | INDEXED_MODE <<7; #CLK_PERIOD
    IW = CMPB  | R3<<8 | INDEXED_MODE <<4 | R3 | INDEXED_MODE <<7; #CLK_PERIOD
    IW = DADD  | R0<<8 | INDIRECT_MODE<<4 | R0 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = DADDB | R2<<8 | INDIRECT_MODE<<4 | R2 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = BIT   | R3<<8 | INDIRECT_MODE<<4 | R3 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = BITB  | R0<<8 | INDIRECT_MODE<<4 | R0 | INDEXED_MODE <<7; #CLK_PERIOD
    IW = BIC   | R2<<8 | INDIRECT_MODE<<4 | R2 | INDEXED_MODE <<7; #CLK_PERIOD
    IW = BICB  | R3<<8 | INDIRECT_MODE<<4 | R3 | INDEXED_MODE <<7; #CLK_PERIOD
    IW = BIS   | R0<<8 | REGISTER_MODE<<4 | R0 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = BISB  | R2<<8 | REGISTER_MODE<<4 | R2 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = XOR   | R0<<8 | INDEXED_MODE <<4 | R0 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = XORB  | R2<<8 | INDEXED_MODE <<4 | R2 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = AND   | R0<<8 | INDIRECT_MODE<<4 | R0 | REGISTER_MODE<<7; #CLK_PERIOD
    IW = ANDB  | R2<<8 | INDIRECT_MODE<<4 | R2 | REGISTER_MODE<<7; #CLK_PERIOD
    $display("|------|-----|");
    $finish(0);
end
endmodule
`default_nettype wire
