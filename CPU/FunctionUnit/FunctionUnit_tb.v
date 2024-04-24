`include "CPU\\FunctionUnit\\FunctionUnit.v"
`timescale 100ns/100ns

module FunctionUnit_tb;
    reg [15:0] src, dst, Instruction;
    reg Zin, Vin, Nin, Cin;
    wire [15:0] result;
    wire Zout, Vout, Nout, Cout;

    reg [15:0] expectedResult;
    reg [3:0] expectedStatus; // V, N, Z, C
    wire diffResult, diffStatus;
    wire [3:0] actualStatus;
    assign actualStatus = {Vout, Nout, Zout, Cout};

    assign diffResult = (expectedResult == result) ? 0 : 1'bx;
    assign diffStatus = (expectedStatus == actualStatus) ? 0 : 1'bx;

    initial begin {src, dst, Instruction, Zin, Vin, Nin, Cin, expectedResult, expectedStatus} = 0; end

    FunctionUnit uut(
        src, dst, Instruction,
        Zin, Vin, Nin, Cin,
        result,
        Zout, Vout, Nout, Cout
    );

    `include "CPU\\FunctionUnit\\FSparams.v"

    initial begin
        $dumpfile("FunctionUnit.vcd");
        $dumpvars(0, FunctionUnit_tb);
        #10;
        $monitor("Time: %4d | Instruction: %h | result: %h | Status: %b", $time, Instruction, result, actualStatus);

        Instruction = RRC; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'hA5A5; expectedResult = 16'h52D2; expectedStatus = 4'b0001; #10;
        Instruction = RRC; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'hA5A5; expectedResult = 16'hD2D2; expectedStatus = 4'b0101; #10;
        Instruction = RRC; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h8000; expectedStatus = 4'b0100; #10;
        Instruction = RRC; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        
        Instruction = RRCB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h00A5; expectedResult = 16'h0052; expectedStatus = 4'b0001; #10;
        Instruction = RRCB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'h00A5; expectedResult = 16'h00D2; expectedStatus = 4'b0101; #10;
        Instruction = RRCB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0080; expectedStatus = 4'b0100; #10;
        Instruction = RRCB; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        
        Instruction = SWPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h1234; expectedResult = 16'h3412; expectedStatus = 4'b0000; #10;
        Instruction = SWPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h2332; expectedResult = 16'h3223; expectedStatus = 4'b0000; #10;
        Instruction = SWPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h0011; expectedResult = 16'h1100; expectedStatus = 4'b0000; #10;
        Instruction = SWPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h2200; expectedResult = 16'h0022; expectedStatus = 4'b0000; #10;
        
        Instruction = RRA; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h5A5A; expectedResult = 16'h2D2D; expectedStatus = 4'b0000; #10;
        Instruction = RRA; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'hA5A5; expectedResult = 16'hD2D2; expectedStatus = 4'b0101; #10;
        Instruction = RRA; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        Instruction = RRA; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h0000; dst = 16'h0001; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        
        Instruction = RRAB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h005A; expectedResult = 16'h002D; expectedStatus = 4'b0000; #10;
        Instruction = RRAB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h00A5; expectedResult = 16'h00D2; expectedStatus = 4'b0101; #10;
        Instruction = RRAB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        Instruction = RRAB; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h0000; dst = 16'h0001; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        
        Instruction = SXT; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0000; dst = 16'h007f; expectedResult = 16'h007f; expectedStatus = 4'b0001; #10;
        Instruction = SXT; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0000; dst = 16'h0080; expectedResult = 16'hFF80; expectedStatus = 4'b0101; #10;
        Instruction = SXT; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h00FF; expectedResult = 16'hFFFF; expectedStatus = 4'b0101; #10;
        Instruction = SXT; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        
        Instruction = MOV; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'h0000; expectedResult = 16'h1234; expectedStatus = 4'b0000; #10;
        Instruction = MOV; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h5678; dst = 16'h0000; expectedResult = 16'h5678; expectedStatus = 4'b0001; #10;
        Instruction = MOV; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0101; #10;
        Instruction = MOV; {Vin, Nin, Zin, Cin} = 4'b0111; src = 16'hFFFF; dst = 16'h0000; expectedResult = 16'hFFFF; expectedStatus = 4'b0111; #10;
        
        Instruction = MOVB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'h0000; expectedResult = 16'h0034; expectedStatus = 4'b0000; #10;
        Instruction = MOVB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h5678; dst = 16'h0000; expectedResult = 16'h0078; expectedStatus = 4'b0001; #10;
        Instruction = MOVB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0000; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0101; #10;
        Instruction = MOVB; {Vin, Nin, Zin, Cin} = 4'b0111; src = 16'hFFFF; dst = 16'h0000; expectedResult = 16'h00FF; expectedStatus = 4'b0111; #10;
        
        Instruction = ADD; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h7FFF; dst = 16'h0001; expectedResult = 16'h8000; expectedStatus = 4'b1100; #10;
        Instruction = ADD; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h7FFF; dst = 16'hFFFF; expectedResult = 16'h7FFE; expectedStatus = 4'b0001; #10;
        Instruction = ADD; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h8000; dst = 16'h8000; expectedResult = 16'h0000; expectedStatus = 4'b1011; #10;
        Instruction = ADD; {Vin, Nin, Zin, Cin} = 4'b1011; src = 16'h8000; dst = 16'hFFFF; expectedResult = 16'h7FFF; expectedStatus = 4'b1001; #10;
        
        Instruction = ADDB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h007F; dst = 16'h0001; expectedResult = 16'h0080; expectedStatus = 4'b1100; #10;
        Instruction = ADDB; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h007F; dst = 16'h00FF; expectedResult = 16'h007E; expectedStatus = 4'b0001; #10;
        Instruction = ADDB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0080; dst = 16'h0080; expectedResult = 16'h0000; expectedStatus = 4'b1011; #10;
        Instruction = ADDB; {Vin, Nin, Zin, Cin} = 4'b1011; src = 16'h0080; dst = 16'h00FF; expectedResult = 16'h007F; expectedStatus = 4'b1001; #10;
        
        Instruction = ADDC; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h7FFF; dst = 16'h0001; expectedResult = 16'h8001; expectedStatus = 4'b1100; #10;
        Instruction = ADDC; {Vin, Nin, Zin, Cin} = 4'b1101; src = 16'h8000; dst = 16'h8000; expectedResult = 16'h0001; expectedStatus = 4'b1001; #10;
        Instruction = ADDC; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h8000; dst = 16'h7FFF; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        Instruction = ADDC; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h8000; dst = 16'hFFFF; expectedResult = 16'h8000; expectedStatus = 4'b0101; #10;
        
        Instruction = ADDCB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h007F; dst = 16'h0001; expectedResult = 16'h0081; expectedStatus = 4'b1100; #10;
        Instruction = ADDCB; {Vin, Nin, Zin, Cin} = 4'b1101; src = 16'h0080; dst = 16'h0080; expectedResult = 16'h0001; expectedStatus = 4'b1001; #10;
        Instruction = ADDCB; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h0080; dst = 16'h007F; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        Instruction = ADDCB; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h0080; dst = 16'h00FF; expectedResult = 16'h0080; expectedStatus = 4'b0101; #10;
        
        Instruction = SUBC; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'hFFFF; dst = 16'h7FFF; expectedResult = 16'h8000; expectedStatus = 4'b1100; #10;
        Instruction = SUBC; {Vin, Nin, Zin, Cin} = 4'b1101; src = 16'h7FFF; dst = 16'h7FFF; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        Instruction = SUBC; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h7FFF; dst = 16'h8000; expectedResult = 16'h0001; expectedStatus = 4'b1001; #10;
        
        Instruction = SUBCB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h00FF; dst = 16'h007F; expectedResult = 16'h0080; expectedStatus = 4'b1100; #10;
        Instruction = SUBCB; {Vin, Nin, Zin, Cin} = 4'b1101; src = 16'h007F; dst = 16'h007F; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        Instruction = SUBCB; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h007F; dst = 16'h0080; expectedResult = 16'h0001; expectedStatus = 4'b1001; #10;
        
        Instruction = SUB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0020; dst = 16'h7FFF; expectedResult = 16'h7FDF; expectedStatus = 4'b0001; #10;
        Instruction = SUB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h8000; dst = 16'h7FFF; expectedResult = 16'hFFFF; expectedStatus = 4'b1100; #10;
        Instruction = SUB; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h7FFF; dst = 16'h8000; expectedResult = 16'h0001; expectedStatus = 4'b1001; #10;
        Instruction = SUB; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h8000; dst = 16'h8000; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        
        Instruction = SUBB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0020; dst = 16'h007F; expectedResult = 16'h005F; expectedStatus = 4'b0001; #10;
        Instruction = SUBB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0080; dst = 16'h007F; expectedResult = 16'h00FF; expectedStatus = 4'b1100; #10;
        Instruction = SUBB; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h007F; dst = 16'h0080; expectedResult = 16'h0001; expectedStatus = 4'b1001; #10;
        Instruction = SUBB; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h0080; dst = 16'h0080; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        
        // Subtract will yield a diffResult = X. This is acceptable, as CMP prevents Register Write-back. 
        Instruction = CMP; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0020; dst = 16'h7FFF; expectedResult = 16'h7FFF; expectedStatus = 4'b0001; #10;
        Instruction = CMP; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h8000; dst = 16'h7FFF; expectedResult = 16'h7FFF; expectedStatus = 4'b1100; #10;
        Instruction = CMP; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h7FFF; dst = 16'h8000; expectedResult = 16'h8000; expectedStatus = 4'b1001; #10;
        Instruction = CMP; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h8000; dst = 16'h8000; expectedResult = 16'h8000; expectedStatus = 4'b0011; #10;
        
        Instruction = CMPB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0020; dst = 16'h007F; expectedResult = 16'h007F; expectedStatus = 4'b0001; #10;
        Instruction = CMPB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0080; dst = 16'h007F; expectedResult = 16'h007F; expectedStatus = 4'b1100; #10;
        Instruction = CMPB; {Vin, Nin, Zin, Cin} = 4'b1100; src = 16'h007F; dst = 16'h0080; expectedResult = 16'h0080; expectedStatus = 4'b1001; #10;
        Instruction = CMPB; {Vin, Nin, Zin, Cin} = 4'b1001; src = 16'h0080; dst = 16'h0080; expectedResult = 16'h0080; expectedStatus = 4'b0011; #10;
        
        Instruction = DADD; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h4567; dst = 16'h1234; expectedResult = 16'h5801; expectedStatus = 4'b0000; #10;
        Instruction = DADD; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0001; dst = 16'h9999; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        Instruction = DADD; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h3210; dst = 16'h6678; expectedResult = 16'h9889; expectedStatus = 4'b0100; #10;
        Instruction = DADD; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h9999; dst = 16'h9999; expectedResult = 16'h9998; expectedStatus = 4'b0101; #10;
        
        Instruction = DADDB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0045; dst = 16'h0012; expectedResult = 16'h0057; expectedStatus = 4'b0000; #10;
        Instruction = DADDB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0001; dst = 16'h0099; expectedResult = 16'h0000; expectedStatus = 4'b0011; #10;
        Instruction = DADDB; {Vin, Nin, Zin, Cin} = 4'b0011; src = 16'h0042; dst = 16'h0056; expectedResult = 16'h0099; expectedStatus = 4'b0100; #10;
        Instruction = DADDB; {Vin, Nin, Zin, Cin} = 4'b0100; src = 16'h0099; dst = 16'h0099; expectedResult = 16'h0098; expectedStatus = 4'b0101; #10;
        
        Instruction = AND; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h8765; dst = 16'hFFFF; expectedResult = 16'h8765; expectedStatus = 4'b0101; #10;
        Instruction = AND; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h1234; dst = 16'h1111; expectedResult = 16'h1010; expectedStatus = 4'b0001; #10;
        Instruction = AND; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h2468; dst = 16'h1111; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        Instruction = AND; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'hFFFF; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        
        Instruction = ANDB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0087; dst = 16'h00FF; expectedResult = 16'h0087; expectedStatus = 4'b0101; #10;
        Instruction = ANDB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0012; dst = 16'h0011; expectedResult = 16'h0010; expectedStatus = 4'b0001; #10;
        Instruction = ANDB; {Vin, Nin, Zin, Cin} = 4'b0001; src = 16'h0024; dst = 16'h0011; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        Instruction = ANDB; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h00FF; dst = 16'h0000; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        
        Instruction = BIC; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'hFFFF; expectedResult = 16'hEDCB; expectedStatus = 4'b0000; #10;
        Instruction = BIC; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h2345; dst = 16'h1234; expectedResult = 16'h1030; expectedStatus = 4'b0000; #10;
        Instruction = BIC; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1111; dst = 16'h1111; expectedResult = 16'h0000; expectedStatus = 4'b0000; #10;
        
        Instruction = BICB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0034; dst = 16'h00FF; expectedResult = 16'h00CB; expectedStatus = 4'b0000; #10;
        Instruction = BICB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0045; dst = 16'h0012; expectedResult = 16'h0012; expectedStatus = 4'b0000; #10;
        Instruction = BICB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0011; dst = 16'h0011; expectedResult = 16'h0000; expectedStatus = 4'b0000; #10;
        
        Instruction = BIS; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'hFFFF; expectedResult = 16'hFFFF; expectedStatus = 4'b0000; #10;
        Instruction = BIS; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h2345; dst = 16'h1111; expectedResult = 16'h3355; expectedStatus = 4'b0000; #10;
        Instruction = BIS; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1111; dst = 16'h1111; expectedResult = 16'h1111; expectedStatus = 4'b0000; #10;
        Instruction = BIS; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'hA5A5; dst = 16'h0000; expectedResult = 16'hA5A5; expectedStatus = 4'b0000; #10;
        
        Instruction = BISB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0012; dst = 16'h00FF; expectedResult = 16'h00FF; expectedStatus = 4'b0000; #10;
        Instruction = BISB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0023; dst = 16'h0011; expectedResult = 16'h0033; expectedStatus = 4'b0000; #10;
        Instruction = BISB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0011; dst = 16'h0011; expectedResult = 16'h0011; expectedStatus = 4'b0000; #10;
        Instruction = BISB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h00A5; dst = 16'h0000; expectedResult = 16'h00A5; expectedStatus = 4'b0000; #10;
        
        Instruction = XOR; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h1234; dst = 16'hFFFF; expectedResult = 16'hEDCB; expectedStatus = 4'b0101; #10;
        Instruction = XOR; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h5AA5; dst = 16'hA5A5; expectedResult = 16'hFF00; expectedStatus = 4'b0101; #10;
        Instruction = XOR; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h1234; dst = 16'h1234; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        Instruction = XOR; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h8000; dst = 16'hFFFF; expectedResult = 16'h7FFF; expectedStatus = 4'b1001; #10;
        
        Instruction = XORB; {Vin, Nin, Zin, Cin} = 4'b0000; src = 16'h0012; dst = 16'h00FF; expectedResult = 16'h00ED; expectedStatus = 4'b0101; #10;
        Instruction = XORB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0055; dst = 16'h00A5; expectedResult = 16'h00F0; expectedStatus = 4'b0101; #10;
        Instruction = XORB; {Vin, Nin, Zin, Cin} = 4'b0101; src = 16'h0012; dst = 16'h0012; expectedResult = 16'h0000; expectedStatus = 4'b0010; #10;
        Instruction = XORB; {Vin, Nin, Zin, Cin} = 4'b0010; src = 16'h0080; dst = 16'h00FF; expectedResult = 16'h007F; expectedStatus = 4'b1001; #10;

        $finish;
    end
endmodule