/*--------------------------------------------------------
    Module Name : TransmitStateMachine Testbench
    Description:
        Verifies Functionality of the TransmitStateMachine

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_TransmitStateMachine;
reg BITCLK, reset;
reg wUCPEN, wUCPAR, wUCMSB, wUC7BIT, wUCSPB;
reg [7:0] TxData;
reg iTXIFG;
wire TxBEN, setTXIFG, setTXCPTIFG, TxBusy;
wire Tx;

`include "NEW/PARAMS.v"
reg [15:0] outFrame;

initial begin 
    {BITCLK, reset, wUCPEN, wUCPAR, wUCMSB, wUC7BIT, wUCSPB, TxData, iTXIFG, outFrame} = 0; 
    iTXIFG = 1;
end

TransmitStateMachine uut
(
    .BITCLK(BITCLK), .reset(reset), 
    .wUCPEN(wUCPEN), .wUCPAR(wUCPAR), .wUCMSB(wUCMSB), .wUC7BIT(wUC7BIT), 
    .wUCSPB(wUCSPB), 
    .TxData(TxData), .iTXIFG(iTXIFG), 
    .TxBEN(TxBEN), 
    .setTXIFG(setTXIFG), .setTXCPTIFG(setTXCPTIFG), 
    .TxBusy(TxBusy),
    .Tx(Tx)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) BITCLK = ~BITCLK;

initial begin
    $dumpfile("TransmitStateMachine.vcd");
    $dumpvars(0, tb_TransmitStateMachine);
end

initial begin
    // 8-bit, no parity, 1 stop, LSB
    reset = 1; #CLK_PERIOD;
    wUC7BIT = 0; wUCMSB = 0; wUCSPB = 0; wUCPEN = 0; wUCPAR = 0; #CLK_PERIOD;
    reset = 0; #CLK_PERIOD;

    receiveFrame(8'ha5, 10, 0);
    #(CLK_PERIOD);
    receiveFrame(8'h55, 9, 0);
    receiveFrame(8'hFF, 10, 0);

    // 7-bit, odd parity, 2 stop, MSB
    reset = 1; #CLK_PERIOD;
    wUC7BIT = 1; wUCMSB = 1; wUCSPB = 1; wUCPEN = 1; wUCPAR = 0; #CLK_PERIOD;
    reset = 0; #CLK_PERIOD;

    receiveFrame(8'h35, 11, 1);
    #CLK_PERIOD;
    receiveFrame(8'h24, 11, 1);


    $finish(0);
end

task receiveFrame;
    input [7:0] data;
    input [3:0] bits;
    input MSB;
    integer i;
    begin
        @(negedge BITCLK);
        outFrame = 0;
        TxData = data; iTXIFG = 0; #CLK_PERIOD; iTXIFG = 1;
        for (i=0; i < bits; i = i + 1) begin
            if(MSB)
                outFrame[bits-i-1] = Tx;
            else
                outFrame[i] = Tx;
            #CLK_PERIOD;
        end
    end
endtask

endmodule
`default_nettype wire
