/*--------------------------------------------------------
    Module Name : ReceiveStateMachine Testbench
    Description:
        Verifies Functionality of the ReceiveStateMachine

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

`define ConsoleLog(condition, testStr, startTime) begin \
        if (condition) \
            $display("%5d - %5d uS: Test %s Passed", startTime/10, $time/10, testStr); \
        else begin \
            $display("%5d - %5d uS: Test %s Failed", startTime/10, $time/10, testStr); \
            $finish(1); \
        end \
    end

`define subTest(testLabel, FrameData, FrameLen, MSB, testCondition) begin \
        #(3*BITCLK_PERIOD); \
        StartTime = $time; \
        transmitFrame(FrameData, FrameLen, MSB); \
        `ConsoleLog(testCondition, testLabel, StartTime) \
    end

module tb_ReceiveStateMachine;
reg MCLK, BITCLK, reset;
reg wUCPEN, wUCPAR, wUCMSB, wUC7BIT, wUCSPB, wUCRXEIE, wUCBRKIE;
reg Rx, RxIFG; // current IFG value. Used for UCOE
wire RxBEN, rUCPE, rUCFE, rUCOE, rUCBRK, rSetRxIFG;
wire oUCRXERR;
wire [7:0] RxData;
wire RxBusy;

time StartTime;

`include "NEW/PARAMS.v"

localparam  STARTBIT   = 1'b0,
            STOPBIT    = 1'b1,
            PARITYONE  = 1'b1,
            PARITYZERO = 1'b0;

initial begin 
    {MCLK, BITCLK, reset, wUCPEN, wUCPAR, wUCMSB, wUC7BIT, wUCSPB, wUCRXEIE, RxIFG} = 0; 
    Rx = 1;
end

ReceiveStateMachine uut
(
    .MCLK(MCLK), .BITCLK(BITCLK), .reset(reset), 
    .wUCPEN(wUCPEN), .wUCPAR(wUCPAR), 
    .wUCMSB(wUCMSB), .wUC7BIT(wUC7BIT), 
    .wUCSPB(wUCSPB), .wUCRXEIE(wUCRXEIE),
    .wUCBRKIE(wUCBRKIE), 
    .Rx(Rx), .RxIFG(RxIFG), 
    .RxBEN(RxBEN), 
    .rUCPE(rUCPE), .rUCFE(rUCFE), .rUCOE(rUCOE), .rUCBRK(rUCBRK), 
    .rSetRxIFG(rSetRxIFG), .oUCRXERR(oUCRXERR),
    .RxData(RxData), .RxBusy(RxBusy)  
);

localparam CLK_PERIOD = 10;
localparam BITCLK_PERIOD = 305;
always #(CLK_PERIOD/2) MCLK = ~MCLK;
always #(BITCLK_PERIOD/2) BITCLK = ~BITCLK;


initial begin
    $dumpfile("ReceiveStateMachine.vcd");
    $dumpvars(0, tb_ReceiveStateMachine);
end

initial begin
    test1;
    test2;
    test3;
    test4;
    test5;
    test6;
    $finish(0);
end

task transmitFrame; //(data, bits, MSB);
    input [15:0] data;
    input [3:0] bits;
    input MSB;
    integer i;
    begin
        // Idle line = 1 while waiting for negedge BITCLK
        // causality is flipped in implementation with BRGen.
        Rx = 1; 
        @(negedge BITCLK)

        for (i=0; i<bits; i = i + 1) begin
            if (MSB)
                Rx = data[bits-i-1]; 
            else
                Rx = data[i];    
            #BITCLK_PERIOD; // introduces error in Rx Line due to integer division 
        end
        Rx = 1; // idle high after frame
    end
endtask

task test1;
    /*  Test 1: 8-bit data, LSB first, no parity, 1 stop bit, RXEIE = 0, BRKIE = 0
        Test procedure:
            - Setup
                - device starts in SWRST condition
                - configure control bits
                - disable SWRST
            - Ideal condition
                - feed start, 8 bit data, stop
                - confirm RxData
            - Error 1: Frame error
                - feed start, 8-bit data, start bit
                - confirm RxData is unchanged
                - confire UCFE 
            - Error 1: Overrun error
                - Set RxIFG
                - feed valid frame
                - confirm RxData is unchanged
                - confirm UCOE
            - Break Condition
                - clear RxIFG
                - feed break
                - confirm break, RxData, SetRxIFG
     */
    begin
        `timeLog("Start Task 1")
        // Setup
        reset = 1; #CLK_PERIOD;
        wUC7BIT = 0; 
        wUCPEN = 0; wUCPAR = 0; 
        wUCMSB = 0; wUCSPB = 0; 
        wUCRXEIE = 0; wUCBRKIE = 0;
        #CLK_PERIOD;
        reset = 0; #CLK_PERIOD;

        // Ideal
        `subTest(
            "1a - Ideal",
            {STOPBIT, 8'ha5, STARTBIT}, 4'd10, 1'b0,
            (rSetRxIFG && RxData == 8'ha5)
            )

        // Error 1 - frame error
        `subTest(
            "1b - FE",
            {STARTBIT, 8'h3E, STARTBIT}, 4'd10, 1'b0,
            (~rSetRxIFG && RxData == 8'ha5 && rUCFE)
            )

        // Error 2 - Overrun error
        RxIFG = 1;
        `subTest(
            "1c - OE",
            {STOPBIT, 8'h6C, STARTBIT}, 4'd10, 1'b0, 
            (~rSetRxIFG && RxData == 8'ha5 && rUCOE) 
            )

        // Break 
        RxIFG = 0;
        `subTest(
            "1d - BRK", 
            {STOPBIT, 8'h00, STARTBIT}, 4'd10, 1'b0,
            (~rSetRxIFG && RxData == 8'h00 && rUCBRK)
            )
        
        #(3*BITCLK_PERIOD);
        reset = 1;
        `timeLog("End Task 1");
        $display("----------------------------------------");
        // Add buffer time between tests
        #(5*CLK_PERIOD);
        @(negedge MCLK);
    end
endtask

task test2;
    /*  Test 2: 8-bit data, LSB first, odd parity, 2 stop bits, RXEIE = 1, BRKIE = 1
        Test Procedure:
            - Setup
                - device SWRT set
                - configure control
                - clear SWRT
            - Ideal condition
                - feed start, 8-bit data, odd parity, 2 stop
                - confirm SetRxIFG, RxData
            - Error 1: Frame error
                - false start 2 bit
                - confirm failure, and RxData still shows
            - Error 2: Frame error
                - false start 1 bit + break
                - confirm failure, and RxData still shows
            - Error 3: parity error
                - false parity bit
                - confirm failure, and RxData still shows
            - Error 4: parity and overrun error
                - Set RxIFG
                - false parity
                - confirm both failures, and RxData still shows
     */
    begin
        `timeLog("Start Task 2")

        // Setup
        reset = 1; #CLK_PERIOD;
        wUC7BIT = 0; 
        wUCPEN = 1; wUCPAR = 0; 
        wUCMSB = 0; wUCSPB = 1; 
        wUCRXEIE = 1; wUCBRKIE = 1;
        #CLK_PERIOD;
        reset = 0; #CLK_PERIOD;

        // Ideal
        `subTest(
            "2a - Ideal", 
            {STOPBIT, STOPBIT, 1'b1, 8'h55, STARTBIT}, 4'd12, 1'b0,
            (rSetRxIFG && RxData == 8'h55 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 0) 
            )

        // Error 1 - Frame Error
        `subTest(
            "2b - FE2", 
            {STOPBIT, STARTBIT, 1'b0, 8'h3E, STARTBIT}, 4'd12, 1'b0,
            (rSetRxIFG && RxData == 8'h3E && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b1000)
            )
        
        // Error 2 - Frame Error
        `subTest(
            "2c - FE1", 
            {STARTBIT, STOPBIT, 1'b1, 8'h00, STARTBIT}, 4'd12, 1'b0,
            (rSetRxIFG && RxData == 8'h00 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b1001)
            )
                    
        // Error 3 - Parity Error
        `subTest(
            "2d - PE", 
            {STOPBIT, STOPBIT, 1'b1, 8'hA4, STARTBIT}, 4'd12, 1'b0, 
            (rSetRxIFG && RxData == 8'hA4 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0010)
            )

        // Error 4 - Parity Error and Overrun Error
        RxIFG = 1;
        `subTest(
            "2e - PE & OE", 
            {STOPBIT, STOPBIT, 1'b0, 8'hA5, STARTBIT}, 4'd12, 1'b0,
            (rSetRxIFG && RxData == 8'hA5 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0110)
            )
                    
        // Reset device and End Task
        #(3*BITCLK_PERIOD);
        RxIFG = 0;
        reset = 1;
        `timeLog("End Task 2");
        $display("----------------------------------------");
        // Add Buffer Time
        #(5*CLK_PERIOD);
        @(negedge MCLK);
    end
endtask

task test3;
    /*  Test 3: 8-bit data, MSB first, even parity, 1 stop, RXEIE = 0, BRKIE = 1 
        Test Procedure:
            - Configure
                - SWRST set
                - Configure
                - SWRST clear
            - Ideal
                - feed start, data, polarity, stop
                - confirm RxData, RxIFG, no errors
            - Error 1: Polarity Error
                - feed wrong pol bit
                - check RxData, PE flag
     */
    begin
        `timeLog("Start Task 3")
        // Setup
        reset = 1; #CLK_PERIOD;
        wUC7BIT = 0; 
        wUCPEN = 1; wUCPAR = 1; 
        wUCMSB = 1; wUCSPB = 0; 
        wUCRXEIE = 0; wUCBRKIE = 1;
        #CLK_PERIOD;
        reset = 0; #CLK_PERIOD;

        // Ideal
        `subTest(
            "3a - Ideal",
            {STARTBIT, 8'h34, 1'b1, STOPBIT}, 4'd11, 1'b1,
            (rSetRxIFG && RxData == 8'h34 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0000)
            )

        // Error 1
        `subTest(
            "3b - PE + BRK",
            {STARTBIT, 8'h00, 1'b1, STOPBIT}, 4'd11, 1'b1,
            (~rSetRxIFG && RxData == 8'h34 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0011)
            )   

        // Reset device and End Task
        #(3*BITCLK_PERIOD);
        reset = 1;
        `timeLog("End Task 3")
        $display("----------------------------------------");
        // Add Buffer Time
        #(5*CLK_PERIOD);
        @(negedge MCLK);
    end
endtask

task test4;
    /*  Test 4: 8-bit data, MSB first, no Parity, 2 stop, RXEIE = 1, BRKIE = 0
        Test Procedure:
            - Setup
            - Ideal
                - Feed Start, 8 data, 2 stop
                - confirm RxData
            - Error 1: Frame error 2
                - Error on stop 2 bit
                - confirm RxData, error flags
            - Error 2: Frame error 1
                - Error on stop 1 bit
                - confirm RxData, error flags
     */
    begin 
        `timeLog("Start Task 4")

        // Setup
        reset = 1; #CLK_PERIOD;
        wUC7BIT = 0; 
        wUCPEN = 0; wUCPAR = 0; 
        wUCMSB = 1; wUCSPB = 1; 
        wUCRXEIE = 1; wUCBRKIE = 0;
        #CLK_PERIOD;
        reset = 0; #CLK_PERIOD;

        // Ideal
        `subTest(
            "4a - Ideal",
            {STARTBIT, 8'h1F, STOPBIT, STOPBIT}, 4'd11, 1'b1,
            (rSetRxIFG && RxData == 8'h1F && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0000)
            )
        
        // Error 1
        `subTest(
            "4b - FE 2 + BRK",
            {STARTBIT, 8'h00, STARTBIT, STOPBIT}, 4'd11, 1'b1,
            (~rSetRxIFG && RxData == 8'h00 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b1001)
            )

        // Error 2
        `subTest(
            "4b - FE 1",
            {STARTBIT, 8'hFF, STOPBIT, STARTBIT}, 4'd11, 1'b1,
            (rSetRxIFG && RxData == 8'hFF && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b1000)
            )

        // Reset device and End Task
        #(3*BITCLK_PERIOD);
        reset = 1;
        `timeLog("End Task 4");
        $display("----------------------------------------");
        // Add Buffer Time
        #(5*CLK_PERIOD);
        @(negedge MCLK);
    end
endtask

task test5;
    /*  Test5: 7-bit data, LSB, no parity, 1 stop, RXEIE = 0, BRKIE = 1
        Test Procedure:
            - Setup
            - Test 1: Ideal
                - send valid frame
            - Test 2: Frame error
                - send false stop
            - Test 3: Overrun Error
                - set RxIFG
                - send valid frame
            - Test 4: Break
                - send break
     */
    begin
        `timeLog("Start Task 5")
        // Setup
        reset = 1; #CLK_PERIOD;
        wUC7BIT = 1; 
        wUCPEN = 0; wUCPAR = 0; 
        wUCMSB = 0; wUCSPB = 0; 
        wUCRXEIE = 0; wUCBRKIE = 1;
        #CLK_PERIOD;
        reset = 0; #CLK_PERIOD;

        // Ideal
        `subTest(
            "5a - Ideal",
            {STOPBIT, 7'h5A, STARTBIT}, 4'd9, 1'b0,
            (rSetRxIFG && RxData == 8'h5A && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0000)
        )

        // Error 1
        `subTest(
            "5b - FE",
            {STARTBIT, 7'h34, STARTBIT}, 4'd9, 1'b0,
            (~rSetRxIFG && RxData == 8'h5A && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b1000)
        )

        // Error 2
        RxIFG = 1;
        `subTest(
            "5c - OE",
            {STOPBIT, 7'h76, STARTBIT}, 4'd9, 1'b0,
            (~rSetRxIFG && RxData == 8'h5A && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0100)
        )
        RxIFG = 0;

        // Test 4 - Break
        `subTest(
            "5d - BRK",
            {STOPBIT, 7'h00, STARTBIT}, 4'd9, 1'b0,
            (rSetRxIFG && RxData == 8'h00 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0001)
        )

        // Reset device and End Task
        #(3*BITCLK_PERIOD);
        reset = 1;
        `timeLog("End Task 5")
        $display("----------------------------------------");
        // Add Buffer Time
        #(5*CLK_PERIOD);
        @(negedge MCLK);
    end
endtask

task test6;
    /*  Test6: 7-bit data, MSB, Odd Parity, 2 stop, RXEIE = 1, BRKIE = 0
        Test Procedure:
            - Setup
            - Test 1: Ideal
            - Test 2: Frame Error 2
            - Test 3: Frame Error 1
            - Test 4: Parity Error + Break
     */
    begin
        `timeLog("Start Task 6")
        // Setup
        reset = 1; #CLK_PERIOD;
        wUC7BIT = 1; 
        wUCPEN = 1; wUCPAR = 0; 
        wUCMSB = 1; wUCSPB = 1; 
        wUCRXEIE = 1; wUCBRKIE = 0;
        #CLK_PERIOD;
        reset = 0; #CLK_PERIOD;

        // Ideal
        `subTest(
            "6a - Ideal",
            {STARTBIT, 7'h35, 1'b1, STOPBIT, STOPBIT}, 4'd11, 1'b1,
            (rSetRxIFG && RxData == 8'h35 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0000)
        )

        // Frame Error
        `subTest(
            "6b - FE 2",
            {STARTBIT, 7'h5E, 1'b0, STARTBIT, STOPBIT}, 4'd11, 1'b1,
            (rSetRxIFG && RxData == 8'h5E && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b1000)
        )

        // Frame Error
        `subTest(
            "6c - FE 1",
            {STARTBIT, 7'h12, 1'b1, STOPBIT, STARTBIT}, 4'd11, 1'b1,
            (rSetRxIFG && RxData == 8'h12 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b1000)
        )

        // Parity Error
        `subTest(
            "6d - PAR + BRK",
            {STARTBIT, 7'h00, 1'b0, STOPBIT, STOPBIT}, 4'd11, 1'b1,
            (~rSetRxIFG && RxData == 8'h00 && {rUCFE, rUCOE, rUCPE, rUCBRK} == 4'b0011)
        )

        // End Task
        #(3*BITCLK_PERIOD);
        reset = 1;
        `timeLog("End Task 6")
        $display("----------------------------------------");
        // Add Buffer Time
        #(5*CLK_PERIOD);
        @(negedge MCLK);
    end
endtask

endmodule
`default_nettype wire
