/*--------------------------------------------------------
    Module Name : Control Unit Testbench
    Description:
        Verifies functionality of the Control Unit

--------------------------------------------------------*/

`include "NEW\\ControlUnit.v"
`default_nettype none
`timescale 100ns/100ns

module tb_ControlUnit;
reg [CAR_BITS-1:0] CAR;
reg [15:0] IR;

wire [15:0] IW;
wire [3:0] srcA;
wire [1:0] As;
wire [3:0] dstA;
wire Ad;
wire [11:0] ControlWord;

`include "NEW\\MACROS.v"

initial begin {CAR, IR} = 0; end

ControlUnit uut
(
.CAR(CAR), .IR(IR),
.IW(IW),
.srcA(srcA), .As(As),
.dstA(dstA), .Ad(Ad),
.ControlWord(ControlWord)
);

localparam CLK_PERIOD = 10;

initial begin
    $dumpfile("ControlUnit.vcd");
    $dumpvars(0, tb_ControlUnit);
    $display("| CAR |  IR  |  IW  | Rs | As | Rd | Ad | Ctl |");
    $display("|-----|------|------|----|----|----|----|-----|");
    $monitor("|  %2d | %4h | %4h | %2d | %2b | %2d |  %1d | %3h |", CAR, IR, IW, srcA, As, dstA, Ad, ControlWord);
end

initial begin
    // CAR Reset
    CAR = 0; IR = 0; #CLK_PERIOD;
    // 2-op instructions ------------------------------------------------------
    CAR = 01; IR = MOV  | R4 <<8 | REGISTER_MODE<<4 | R10 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 02; IR = MOV  | R5 <<8 | REGISTER_MODE<<4 | R11 | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 03; IR = MOV  | R6 <<8 | REGISTER_MODE<<4 | R12 | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 04; IR = MOV  | R7 <<8 | REGISTER_MODE<<4 | R13 | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 05; IR = MOV  | R8 <<8 | REGISTER_MODE<<4 | R14 | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 06; IR = MOV  | R9 <<8 | INDIRECT_MODE<<4 | R15 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 07; IR = MOV  | R10<<8 | INDIRECT_MODE<<4 | R4  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 08; IR = MOV  | R11<<8 | INDIRECT_MODE<<4 | R5  | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 09; IR = MOV  | R12<<8 | INDIRECT_MODE<<4 | R6  | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 10; IR = MOV  | R13<<8 | INDIRECT_MODE<<4 | R7  | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 11; IR = MOV  | R14<<8 | INDIRECT_MODE<<4 | R8  | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 12; IR = MOV  | R15<<8 | INDIRECT_MODE<<4 | R9  | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 13; IR = MOV  | R4 <<8 | INDEXED_MODE <<4 | R10 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 14; IR = MOV  | R5 <<8 | INDEXED_MODE <<4 | R11 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 15; IR = MOV  | R6 <<8 | INDEXED_MODE <<4 | R12 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 16; IR = MOV  | R7 <<8 | INDEXED_MODE <<4 | R13 | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 17; IR = MOV  | R8 <<8 | INDEXED_MODE <<4 | R14 | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 18; IR = MOV  | R9 <<8 | INDEXED_MODE <<4 | R15 | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 19; IR = MOV  | R10<<8 | INDEXED_MODE <<4 | R4  | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 20; IR = MOV  | R11<<8 | INDEXED_MODE <<4 | R5  | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 21; IR = MOV  | R12<<8 | INDEXED_MODE <<4 | R6  | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 22; IR = RRA  |          REGISTER_MODE<<4 | R7  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 23; IR = RRA  |          INDIRECT_MODE<<4 | R8  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 24; IR = RRA  |          INDIRECT_MODE<<4 | R9  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 25; IR = RRA  |          INDIRECT_MODE<<4 | R10 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 26; IR = RRA  |          INDEXED_MODE <<4 | R11 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 27; IR = RRA  |          INDEXED_MODE <<4 | R12 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 28; IR = RRA  |          INDEXED_MODE <<4 | R13 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 29; IR = RRA  |          INDEXED_MODE <<4 | R14 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 30; IR = PUSH |          REGISTER_MODE<<4 | R15 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 31; IR = PUSH |          REGISTER_MODE<<4 | R4  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 32; IR = PUSH |          REGISTER_MODE<<4 | R5  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 33; IR = PUSH |          INDIRECT_MODE<<4 | R6  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 34; IR = PUSH |          INDIRECT_MODE<<4 | R7  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 35; IR = PUSH |          INDIRECT_MODE<<4 | R8  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 36; IR = PUSH |          INDEXED_MODE <<4 | R9  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 37; IR = PUSH |          INDEXED_MODE <<4 | R10 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 38; IR = PUSH |          INDEXED_MODE <<4 | R11 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 39; IR = PUSH |          INDEXED_MODE <<4 | R12 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 40; IR = CALL |          REGISTER_MODE<<4 | R13 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 41; IR = CALL |          REGISTER_MODE<<4 | R14 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 42; IR = CALL |          REGISTER_MODE<<4 | R15 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 43; IR = CALL |          INDIRECT_MODE<<4 | R4  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 44; IR = CALL |          INDIRECT_MODE<<4 | R5  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 45; IR = CALL |          INDIRECT_MODE<<4 | R6  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 46; IR = CALL |          INDEXED_MODE <<4 | R7  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 47; IR = CALL |          INDEXED_MODE <<4 | R8  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 48; IR = CALL |          INDEXED_MODE <<4 | R9  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 49; IR = CALL |          INDEXED_MODE <<4 | R10 | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 50; IR = RETI |          REGISTER_MODE<<4 |       REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 51; IR = RETI |          REGISTER_MODE<<4 |       REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 52; IR = RETI |          REGISTER_MODE<<4 |       REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 53; IR = RETI |          REGISTER_MODE<<4 |       REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 54; IR = MOV  | R4 <<8 | REGISTER_MODE<<4 | R5  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 55; IR = ADD  | R5 <<8 | INDEXED_MODE <<4 | R6  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 56; IR = RRA  |          REGISTER_MODE<<4 | R7  | INDEXED_MODE <<7; #CLK_PERIOD;
    CAR = 57; IR = RRC  |          REGISTER_MODE<<4 | R8  | INDIRECT_MODE<<7; #CLK_PERIOD;
    CAR = 58; IR = SUBC | R6 <<8 | INDIRECT_MODE<<4 | R9  | REGISTER_MODE<<7; #CLK_PERIOD;
    CAR = 59; IR = JMP  |          REGISTER_MODE<<4 |       REGISTER_MODE<<7; #CLK_PERIOD;
    
    $display("|-----|------|------|----|----|----|----|-----|");
    $finish(0);
end
endmodule
`default_nettype wire