/*--------------------------------------------------------
    Module Name : Function Unit Testbench
    Description: 
        Verifies the Function Unit module
        
--------------------------------------------------------*/

// `include "NEW\\FunctionUnit.v"
`default_nettype none
`timescale 100ns/100ns

module tb_FunctionUnit;
reg [15:0] src, dst, IW;
reg Zin, Vin, Nin, Cin;
wire [15:0] result;
wire Zout, Vout, Nout, Cout;
reg [3:0] expectedStatus; 
reg [15:0] expectedResult;
wire diffResult, diffStatus;

assign diffResult = (result == expectedResult) ? 0 : 1'bx;
assign diffStatus = ({Vout, Nout, Zout, Cout} == expectedStatus) ? 0 : 1'bx;

`include "NEW\\PARAMS.v"

initial begin {src, dst, IW, Zin, Vin, Nin, Cin, expectedStatus, expectedResult} = 0; end

FunctionUnit uut
(
    .src(src), .dst(dst),
    .IW(IW),
    .Zin(Zin), .Vin(Vin), .Nin(Nin), .Cin(Cin),
    .result(result),
    .Zout(Zout), .Vout(Vout), .Nout(Nout), .Cout(Cout)    
);

localparam CLK_PERIOD = 10;

initial begin
    $dumpfile("tb_FunctionUnit.vcd");
    $dumpvars(0, tb_FunctionUnit);
end

initial begin
    #CLK_PERIOD;
    IW = RRC; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'hA5A5; expectedResult = 16'h52D2; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = RRC; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'hA5A5; expectedResult = 16'hD2D2; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = RRC; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h8000; expectedStatus = 4'b0100; #CLK_PERIOD;
    IW = RRC; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
     
    IW = RRCB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h00A5; expectedResult = 16'h0052; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = RRCB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'h00A5; expectedResult = 16'h00D2; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = RRCB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0080; expectedStatus = 4'b0100; #CLK_PERIOD;
    IW = RRCB; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
     
    IW = SWPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h1234; expectedResult = 16'h3412; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = SWPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h2332; expectedResult = 16'h3223; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = SWPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h0011; expectedResult = 16'h1100; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = SWPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h2200; expectedResult = 16'h0022; expectedStatus = 4'b0000; #CLK_PERIOD;
     
    IW = RRA; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h5A5A; expectedResult = 16'h2D2D; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = RRA; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'hA5A5; expectedResult = 16'hD2D2; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = RRA; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
    IW = RRA; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h0000; dst = 16'h0001; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
     
    IW = RRAB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h005A; expectedResult = 16'h002D; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = RRAB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h00A5; expectedResult = 16'h00D2; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = RRAB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
    IW = RRAB; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h0000; dst = 16'h0001; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
     
    IW = SXT; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h007f; expectedResult = 16'h007f; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = SXT; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'h0080; expectedResult = 16'hFF80; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = SXT; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h00FF; expectedResult = 16'hFFFF; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = SXT; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
     
    IW = PUSH; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'h1234; expectedResult = 16'h1234; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = PUSH; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h0000; dst = 16'h2345; expectedResult = 16'h2345; expectedStatus = 4'b0010; #CLK_PERIOD;
    IW = PUSHB; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0000; dst = 16'h1234; expectedResult = 16'h0034; expectedStatus = 4'b0100; #CLK_PERIOD;
    IW = PUSHB; {Vin, Nin, Zin, Cin} = 4'b1000; src = 16'h0000; dst = 16'h2345; expectedResult = 16'h0045; expectedStatus = 4'b1000; #CLK_PERIOD;
     
    IW = CALL; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'h1234; expectedResult = 16'h1234; expectedStatus = 4'b0001; #CLK_PERIOD;
     
    IW = RETI; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h4440; dst = 16'h0000; expectedResult = 16'h4440; expectedStatus = 4'b0010; #CLK_PERIOD;
     
    IW = JMP | 10'h40; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4480; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = JNE | 10'h40; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4480; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = JNE | 10'h40; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4400; expectedStatus = 4'b0010; #CLK_PERIOD;
    IW = JEQ | 10'h60; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4400; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = JEQ | 10'h60; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h44C0; expectedStatus = 4'b0010; #CLK_PERIOD;
    IW = JNC | 10'h80; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4500; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = JNC | 10'h80; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4400; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = JC | 10'hA0; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4400; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = JC | 10'hA0; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4540; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = JN | 10'hC0; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4400; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = JN | 10'hC0; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4580; expectedStatus = 4'b0100; #CLK_PERIOD;
    IW = JGE | 10'hE0; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h45C0; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = JGE | 10'hE0; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4400; expectedStatus = 4'b0100; #CLK_PERIOD;
    IW = JGE | 10'hE0; {Vin, Nin, Zin, Cin} = 4'b1000; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4400; expectedStatus = 4'b1000; #CLK_PERIOD;
    IW = JGE | 10'hE0; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h45C0; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = JL | 10'h200; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4400; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = JL | 10'h200; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4000; expectedStatus = 4'b0100; #CLK_PERIOD;
    IW = JL | 10'h200; {Vin, Nin, Zin, Cin} = 4'b1000; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4000; expectedStatus = 4'b1000; #CLK_PERIOD;
    IW = JL | 10'h200; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h0000; dst = 16'h4400; expectedResult = 16'h4400; expectedStatus = 4'b1100; #CLK_PERIOD;
     
    IW = MOV; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'h0000; expectedResult = 16'h1234; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = MOV; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h5678; dst = 16'h0000; expectedResult = 16'h5678; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = MOV; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = MOV; {Vin, Nin, Zin, Cin} = 4'b0111; src = 16'hFFFF; dst = 16'h0000; expectedResult = 16'hFFFF; expectedStatus = 4'b0111; #CLK_PERIOD;
     
    IW = MOVB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'h0000; expectedResult = 16'h0034; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = MOVB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h5678; dst = 16'h0000; expectedResult = 16'h0078; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = MOVB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = MOVB; {Vin, Nin, Zin, Cin} = 4'b0111; src = 16'hFFFF; dst = 16'h0000; expectedResult = 16'h00FF; expectedStatus = 4'b0111; #CLK_PERIOD;
     
    IW = ADD; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h7FFF; dst = 16'h0001; expectedResult = 16'h8000; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = ADD; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h7FFF; dst = 16'hFFFF; expectedResult = 16'h7FFE; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = ADD; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h8000; dst = 16'h8000; expectedResult = 16'h0000; expectedStatus = 4'b1011; #CLK_PERIOD;
    IW = ADD; {Vin, Nin, Zin, Cin} = 4'b1011; src = 16'h8000; dst = 16'hFFFF; expectedResult = 16'h7FFF; expectedStatus = 4'b1001; #CLK_PERIOD;
     
    IW = ADDB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h007F; dst = 16'h0001; expectedResult = 16'h0080; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = ADDB; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h007F; dst = 16'h00FF; expectedResult = 16'h007E; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = ADDB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0080; dst = 16'h0080; expectedResult = 16'h0000; expectedStatus = 4'b1011; #CLK_PERIOD;
    IW = ADDB; {Vin, Nin, Zin, Cin} = 4'b1011; src = 16'h0080; dst = 16'h00FF; expectedResult = 16'h007F; expectedStatus = 4'b1001; #CLK_PERIOD;
     
    IW = ADDC; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h7FFF; dst = 16'h0001; expectedResult = 16'h8001; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = ADDC; {Vin, Nin, Zin, Cin} = 4'b1101; src = 16'h8000; dst = 16'h8000; expectedResult = 16'h0001; expectedStatus = 4'b1001; #CLK_PERIOD;
    IW = ADDC; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h8000; dst = 16'h7FFF; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
    IW = ADDC; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h8000; dst = 16'hFFFF; expectedResult = 16'h8000; expectedStatus = 4'b0101; #CLK_PERIOD;
     
    IW = ADDCB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h007F; dst = 16'h0001; expectedResult = 16'h0081; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = ADDCB; {Vin, Nin, Zin, Cin} = 4'b1101; src = 16'h0080; dst = 16'h0080; expectedResult = 16'h0001; expectedStatus = 4'b1001; #CLK_PERIOD;
    IW = ADDCB; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h0080; dst = 16'h007F; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
    IW = ADDCB; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h0080; dst = 16'h00FF; expectedResult = 16'h0080; expectedStatus = 4'b0101; #CLK_PERIOD;
     
    IW = SUBC; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'hFFFF; dst = 16'h7FFF; expectedResult = 16'h8000; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = SUBC; {Vin, Nin, Zin, Cin} = 4'b1101; src = 16'h7FFF; dst = 16'h7FFF; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
    IW = SUBC; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h7FFF; dst = 16'h8000; expectedResult = 16'h0001; expectedStatus = 4'b1001; #CLK_PERIOD;
     
    IW = SUBCB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h00FF; dst = 16'h007F; expectedResult = 16'h0080; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = SUBCB; {Vin, Nin, Zin, Cin} = 4'b1101; src = 16'h007F; dst = 16'h007F; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
    IW = SUBCB; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h007F; dst = 16'h0080; expectedResult = 16'h0001; expectedStatus = 4'b1001; #CLK_PERIOD;
     
    IW = SUB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0020; dst = 16'h7FFF; expectedResult = 16'h7FDF; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = SUB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h8000; dst = 16'h7FFF; expectedResult = 16'hFFFF; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = SUB; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h7FFF; dst = 16'h8000; expectedResult = 16'h0001; expectedStatus = 4'b1001; #CLK_PERIOD;
    IW = SUB; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h8000; dst = 16'h8000; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
     
    IW = SUBB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0020; dst = 16'h007F; expectedResult = 16'h005F; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = SUBB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0080; dst = 16'h007F; expectedResult = 16'h00FF; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = SUBB; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h007F; dst = 16'h0080; expectedResult = 16'h0001; expectedStatus = 4'b1001; #CLK_PERIOD;
    IW = SUBB; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h0080; dst = 16'h0080; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
     
    IW = CMP; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0020; dst = 16'h7FFF; expectedResult = 16'h7FDF; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = CMP; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h8000; dst = 16'h7FFF; expectedResult = 16'hFFFF; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = CMP; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h7FFF; dst = 16'h8000; expectedResult = 16'h0001; expectedStatus = 4'b1001; #CLK_PERIOD;
    IW = CMP; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h8000; dst = 16'h8000; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
     
    IW = CMPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0020; dst = 16'h007F; expectedResult = 16'h005F; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = CMPB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0080; dst = 16'h007F; expectedResult = 16'h00FF; expectedStatus = 4'b1100; #CLK_PERIOD;
    IW = CMPB; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h007F; dst = 16'h0080; expectedResult = 16'h0001; expectedStatus = 4'b1001; #CLK_PERIOD;
    IW = CMPB; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h0080; dst = 16'h0080; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
     
    IW = DADD; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h4567; dst = 16'h1234; expectedResult = 16'h5801; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = DADD; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0001; dst = 16'h9999; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
    IW = DADD; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h3210; dst = 16'h6678; expectedResult = 16'h9889; expectedStatus = 4'b0100; #CLK_PERIOD;
    IW = DADD; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h9999; dst = 16'h9999; expectedResult = 16'h9998; expectedStatus = 4'b0101; #CLK_PERIOD;
     
    IW = DADDB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0045; dst = 16'h0012; expectedResult = 16'h0057; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = DADDB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0001; dst = 16'h0099; expectedResult = 16'h0000; expectedStatus = 4'b0011; #CLK_PERIOD;
    IW = DADDB; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h0042; dst = 16'h0056; expectedResult = 16'h0099; expectedStatus = 4'b0100; #CLK_PERIOD;
    IW = DADDB; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0099; dst = 16'h0099; expectedResult = 16'h0098; expectedStatus = 4'b0101; #CLK_PERIOD;
     
    IW = AND; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h8765; dst = 16'hFFFF; expectedResult = 16'h8765; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = AND; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h1234; dst = 16'h1111; expectedResult = 16'h1010; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = AND; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h2468; dst = 16'h1111; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
    IW = AND; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'hFFFF; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
     
    IW = ANDB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0087; dst = 16'h00FF; expectedResult = 16'h0087; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = ANDB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0012; dst = 16'h0011; expectedResult = 16'h0010; expectedStatus = 4'b0001; #CLK_PERIOD;
    IW = ANDB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0024; dst = 16'h0011; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
    IW = ANDB; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h00FF; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
     
    IW = BIC; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'hFFFF; expectedResult = 16'hEDCB; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BIC; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h2345; dst = 16'h1234; expectedResult = 16'h1030; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BIC; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1111; dst = 16'h1111; expectedResult = 16'h0000; expectedStatus = 4'b0000; #CLK_PERIOD;
     
    IW = BICB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0034; dst = 16'h00FF; expectedResult = 16'h00CB; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BICB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0045; dst = 16'h0012; expectedResult = 16'h0012; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BICB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0011; dst = 16'h0011; expectedResult = 16'h0000; expectedStatus = 4'b0000; #CLK_PERIOD;
     
    IW = BIS; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'hFFFF; expectedResult = 16'hFFFF; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BIS; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h2345; dst = 16'h1111; expectedResult = 16'h3355; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BIS; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1111; dst = 16'h1111; expectedResult = 16'h1111; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BIS; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'hA5A5; dst = 16'h0000; expectedResult = 16'hA5A5; expectedStatus = 4'b0000; #CLK_PERIOD;
     
    IW = BISB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0012; dst = 16'h00FF; expectedResult = 16'h00FF; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BISB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0023; dst = 16'h0011; expectedResult = 16'h0033; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BISB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0011; dst = 16'h0011; expectedResult = 16'h0011; expectedStatus = 4'b0000; #CLK_PERIOD;
    IW = BISB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h00A5; dst = 16'h0000; expectedResult = 16'h00A5; expectedStatus = 4'b0000; #CLK_PERIOD;
     
    IW = XOR; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'hFFFF; expectedResult = 16'hEDCB; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = XOR; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h5AA5; dst = 16'hA5A5; expectedResult = 16'hFF00; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = XOR; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h1234; dst = 16'h1234; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
    IW = XOR; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h8000; dst = 16'hFFFF; expectedResult = 16'h7FFF; expectedStatus = 4'b1001; #CLK_PERIOD;
     
    IW = XORB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0012; dst = 16'h00FF; expectedResult = 16'h00ED; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = XORB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0055; dst = 16'h00A5; expectedResult = 16'h00F0; expectedStatus = 4'b0101; #CLK_PERIOD;
    IW = XORB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0012; dst = 16'h0012; expectedResult = 16'h0000; expectedStatus = 4'b0010; #CLK_PERIOD;
    IW = XORB; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h0080; dst = 16'h00FF; expectedResult = 16'h007F; expectedStatus = 4'b1001; #CLK_PERIOD;

    $finish(0);
end

endmodule
`default_nettype wire