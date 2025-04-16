/*--------------------------------------------------------
    Module Name: eUSCI_A
    Description:
        
    Inputs:

    Outputs:

--------------------------------------------------------*/
`timescale 100ns/100ns

module eUSCI_A #(
    parameter START = MAP_eUSCI_A0
    )(
    input MCLK, UCxCLK, ACLK, SMCLK, reset,
    input Rx, 
    input  [15:0] MAB, MDBwrite,
    input MW, BW,
    output reg [15:0] MDBread,
    output Tx,
    output INT1
 );

    /* Internal signal definitions */
    reg [15:0] rUCAxCTLW0, rUCAxBRW, rUCAxMCTLW, rUCAxSTATW; 
    reg [15:0] rUCAxRXBUF, rUCAxTXBUF, rUCAxIE, rUCAxIFG, rUCAxIV;

    reg [3:0] syncFlags;

    initial begin 
        // Defined reset condition for MMRs
        rUCAxCTLW0  = 16'h0001;    
        rUCAxBRW    = 16'h0000;    
        rUCAxMCTLW  = 16'h0000;
        rUCAxSTATW  = 16'h0000;
        rUCAxRXBUF  = 16'h0000;
        rUCAxTXBUF  = 16'h0000;
        rUCAxIE     = 16'h0000;
        rUCAxIFG    = 16'h0002;
        rUCAxIV     = 0;
        syncFlags   = 0;     
    end

    // wires from UCAxCTLW0
    wire wUCPEN, wUCPAR, wUCMSB, wUC7BIT, wUCSPB;
    wire [1:0] wUCSSEL;
    wire wUCRXEIE, wUCSWRST;
    assign {wUCPEN, wUCPAR, wUCMSB, wUC7BIT, wUCSPB} = rUCAxCTLW0[UCPEN:UCSPB];
    assign {wUCSSEL, wUCRXEIE} = rUCAxCTLW0[UCSSELx1:UCRXEIE];
    assign wUCSWRST = rUCAxCTLW0[UCSWRST];

    // wires from UCAxMCTLW
    wire [7:0] wUCBRSx;
    wire [3:0] wUCBRFx;
    wire       wUCOS16;
    assign {wUCBRSx,wUCBRFx} = rUCAxMCTLW[UCBRSx7:UCBRFx0];
    assign wUCOS16 = rUCAxMCTLW[UCOS16];

    // wires from UCAxSTATW
    wire wUCLISTEN;
    assign wUCLISTEN = rUCAxSTATW[UCLISTEN]; 

    // wires from UCAxIE
    wire wUCTXCPTIE,  wUCSTTIE,  wUCTXIE,  wUCRXIE;
    assign {wUCTXCPTIE, wUCSTTIE, wUCTXIE, wUCRXIE} = rUCAxIE[UCTXCPTIE:UCRXIE];

    // wires from UCAxIFG
    wire wUCTXCPTIFG, wUCSTTIFG, wUCTXIFG, wUCRXIFG;
    assign {wUCTXCPTIFG, wUCSTTIFG, wUCTXIFG, wUCRXIFG} = rUCAxIFG[UCTXCPTIFG:UCRXIFG];

    // Other wires
    wire BRCLK, RxBEN, RxCLK, TxBEN, TxCLK;
    wire wUCPE, wUCFE, wUCOE, wSetRXIFG, wUCRXERR, wSetSTTIFG;
    wire RxBusy, TxBusy;
    wire wSetTXIFG, wSetTXCPTIFG;
    wire [7:0] wRxData;

    `include "NEW/PARAMS.v" // global parameter defines

    /* Continuous Logic Assignments */

    assign INT1 = rUCAxIV != 0;

    assign BRCLK = (wUCSSEL == UCSSEL__UCLK) ? UCxCLK :
                   (wUCSSEL == UCSSEL__ACLK) ? ACLK   :
                                               SMCLK  ;
    
    // Assign UCAxIV based on IFG & IE bits
    always @(rUCAxIFG, rUCAxIE) begin
        casex(rUCAxIFG[UCTXCPTIFG:UCRXIFG] & rUCAxIE[UCTXCPTIE:UCRXIE])
            4'bxxx1: rUCAxIV = 16'h0002; // Rx Buf full.        TXIFG
            4'bxx10: rUCAxIV = 16'h0004; // Tx Buf empty.       TXIFG
            4'bx100: rUCAxIV = 16'h0006; // Start Bit Rx.       STTIFG
            4'b1000: rUCAxIV = 16'h0008; // Transmit Complete.  TXCPTIFG
            default: rUCAxIV = 16'h0000; // default - no pending interrupts
        endcase
    end

    // Assign MDBread
    always @(*) begin
        if (BW) begin
            case(MAB - START)
            UCAnCTLW0_L:    MDBread = {8'h00, rUCAxCTLW0[7:0]};    
            UCAnCTLW0_H:    MDBread = {8'h00, rUCAxCTLW0[15:8]};    
            UCAnBRW_L:      MDBread = {8'h00, rUCAxBRW[7:0]};  
            UCAnBRW_H:      MDBread = {8'h00, rUCAxBRW[15:8]};  
            UCAnMCTLW_L:    MDBread = {8'h00, rUCAxMCTLW[7:0]};    
            UCAnMCTLW_H:    MDBread = {8'h00, rUCAxMCTLW[15:8]};    
            UCAnSTATW_L:    MDBread = {8'h00, rUCAxSTATW[7:0]};    
            UCAnSTATW_H:    MDBread = {8'h00, rUCAxSTATW[15:8]};    
            UCAnRXBUF_L:    MDBread = {8'h00, rUCAxRXBUF[7:0]};    
            UCAnRXBUF_H:    MDBread = {8'h00, rUCAxRXBUF[15:8]};    
            UCAnTXBUF_L:    MDBread = {8'h00, rUCAxTXBUF[7:0]};    
            UCAnTXBUF_H:    MDBread = {8'h00, rUCAxTXBUF[15:8]};    
            UCAnIE_L:       MDBread = {8'h00, rUCAxIE[7:0]};   
            UCAnIE_H:       MDBread = {8'h00, rUCAxIE[15:8]};   
            UCAnIFG_L:      MDBread = {8'h00, rUCAxIFG[7:0]};  
            UCAnIFG_H:      MDBread = {8'h00, rUCAxIFG[15:8]};  
            UCAnIV_L:       MDBread = {8'h00, rUCAxIV[7:0]};   
            UCAnIV_H:       MDBread = {8'h00, rUCAxIV[15:8]};  
            default:        MDBread = {16{1'bz}}; 
            endcase
        end else begin
            case((MAB & ~1) - START)
            UCAnCTLW0:  MDBread = rUCAxCTLW0;    
            UCAnBRW:    MDBread = rUCAxBRW;    
            UCAnMCTLW:  MDBread = rUCAxMCTLW;    
            UCAnSTATW:  MDBread = rUCAxSTATW;    
            UCAnRXBUF:  MDBread = rUCAxRXBUF;    
            UCAnTXBUF:  MDBread = rUCAxTXBUF;    
            UCAnIE:     MDBread = rUCAxIE;
            UCAnIFG:    MDBread = rUCAxIFG;    
            UCAnIV:     MDBread = rUCAxIV;
            default:    MDBread = {16{1'bz}};
            endcase
        end
    end

    /* Sequential Logic Assignments */

    always @(posedge MCLK) begin
        if (reset) begin
            // Defined reset condition for MMRs
            rUCAxCTLW0  <= 16'h0001;    
            rUCAxBRW    <= 16'h0000;    
            rUCAxMCTLW   <= 16'h0000;
            rUCAxSTATW  <= 16'h0000;
            rUCAxRXBUF  <= 16'h0000;
            rUCAxTXBUF  <= 16'h0000;
            rUCAxIE     <= 16'h0000;
            rUCAxIFG    <= 16'h0002;
            syncFlags   <= 0;
        end else begin
            // Handle System Bus Access
            if (MW & BW & wUCSWRST) begin
                case(MAB - START)
                    UCAnCTLW0_L: rUCAxCTLW0[7:0]  <= MDBwrite[7:0];
                    UCAnCTLW0_H: rUCAxCTLW0[15:8] <= MDBwrite[7:0];
                    UCAnBRW_L:   rUCAxBRW[7:0]    <= MDBwrite[7:0];
                    UCAnBRW_H:   rUCAxBRW[15:8]   <= MDBwrite[7:0];
                    UCAnMCTLW_L: rUCAxMCTLW[7:0]  <= {MDBwrite[7:4], 3'b0, MDBwrite[0]};
                    UCAnMCTLW_H: rUCAxMCTLW[15:8] <= MDBwrite[7:0];
                    UCAnSTATW_L: rUCAxSTATW[7]    <= MDBwrite[7]; // 6-0 READ ONLY
                    // UCAnSTATW_H      RESERVED
                    // UCAnRXBUF        READ ONLY
                    UCAnTXBUF_L: rUCAxTXBUF       <= MDBwrite[7:0];
                    // UCAnTXBUF_H      RESERVED
                    UCAnIE_L:    rUCAxIE[3:0]     <= MDBwrite[3:0]; // 7:4 RESERVED
                    // UCAnIE_H         RESERVED
                    UCAnIFG_L:   rUCAxIFG[3:0]    <= MDBwrite[3:0]; // 7:4 RESERVED
                    // UCAnIE_L         RESERVED
                    // UCAnIV           READ ONLY   
                    default: begin end
                endcase
            end else if (MW & BW & ~wUCSWRST) begin
                // UCSWRST protects certain bits
                case(MAB - START)
                    UCAnCTLW0_L: rUCAxCTLW0[5:0] <= MDBwrite[5:0]; // 7:6 is PROTECTED
                    // UCAnCTLW0_H      PROTECTED
                    // UCAnBRW_L        PROTECTED
                    // UCAnBRW_H        PROTECTED
                    // UCAnMCTLW_L      PROTECTED
                    // UCAnMCTLW_H      PROTECTED
                    // UCAnSTATW_L      PROTECTED / READ ONLY
                    // UCAnSTATW_H      RESERVED
                    // UCAnRXBUF_L      READ ONLY
                    // UCAnRXBUF_H      RESERVED
                    UCAnTXBUF_L: rUCAxTXBUF <= MDBwrite[7:0];
                    // UCAnTXBUF_H      RESERVED
                    UCAnIE_L:    rUCAxIE[3:0] <= MDBwrite[3:0]; // 7:4 RESERVED
                    // UCAnIE_H         RESERVED
                    UCAnIFG_L:   rUCAxIFG[3:0] <= MDBwrite[3:0]; // 7:4 RESERVED
                    // UCAnIFG_H        RESERVED
                    // UCAnIV_L         READ ONLY
                    // UCAnIV_H         RESERVED
                    default: begin end
                endcase
            end else if (MW & ~BW & wUCSWRST) begin
                case((MAB & ~1) - START)
                UCAnCTLW0: rUCAxCTLW0    <= MDBwrite;
                UCAnBRW:   rUCAxBRW      <= MDBwrite;
                UCAnMCTLW: rUCAxMCTLW    <= {MDBwrite[15:4], 3'b0, MDBwrite[0]}; // 3:1 RESERVED
                UCAnSTATW: rUCAxSTATW[7] <= MDBwrite[7]; // 15:8 RSVD, 6:0 READ
                // UCAnRXBUF            RESERVED / READ ONLY
                UCAnTXBUF: rUCAxTXBUF    <= {8'h00, MDBwrite[7:0]};   // 15:8 RESERVED
                UCAnIE:    rUCAxIE       <= {12'h000, MDBwrite[3:0]}; // 15:4 RESERVED
                UCAnIFG:   rUCAxIFG      <= {12'h000, MDBwrite[3:0]}; // 15:4 RESERVED
                // UCAnIV               READ ONLY
                default: begin end    
                endcase
            end else if (MW & ~BW & ~wUCSWRST)begin
                case((MAB & ~1) - START)
                UCAnCTLW0: rUCAxCTLW0[5:0] <= MDBwrite[5:0]; // 15:6 PROTECTED
                // UCAnBRW              PROTECTED
                // UCAnMCTLW            PROTECTED
                // UCAnSTATW            PROTECTED
                // UCAnRXBUF            READ ONLY
                UCAnTXBUF: rUCAxTXBUF[7:0]    <= MDBwrite[7:0]; // [15:8] RESERVED 
                UCAnIE:    rUCAxIE[3:0]       <= MDBwrite[3:0]; // 15:4 RESERVED
                UCAnIFG:   rUCAxIFG[3:0]      <= MDBwrite[3:0]; // 15:4 RESERVED
                // UCAnIV               READ ONLY
                default: begin end    
                endcase
            end

            // Handle UCSTATW bit sets
            if (wUCFE) rUCAxSTATW[UCFE] <= 1;
            if (wUCOE) rUCAxSTATW[UCOE] <= 1;
            if (wUCPE) rUCAxSTATW[UCPE] <= 1;
            if (wUCRXERR) rUCAxSTATW[UCRXERR] <= 1;
            rUCAxSTATW[UCBUSY] <= RxBusy | TxBusy;

            // Handle UCSTATW bit clears on RxBuf Read
            if (~wUCSWRST && (MAB - START == UCAnRXBUF) && ~MW) begin
                rUCAxSTATW[UCFE:UCRXERR] <= 0;
            end

            // Handle RxBuf writes
            if (wSetRXIFG) rUCAxRXBUF[7:0] <= wRxData;  

            // Handle RXIFG clears when RxBuf is read
            if (~reset && ~wUCSWRST && (MAB-START == UCAnRXBUF) && ~MW) begin
                rUCAxIFG[UCRXIFG] <= 0;
            end

            // Handle TxBUF autoclear UCTXIFG
            if ((MAB - START == UCAnTXBUF) && MW && ~reset && ~wUCSWRST) begin
                rUCAxIFG[UCTXIFG] <= 0;
            end

            // Handle UCAxIFG flag sets
            syncFlags <= {wSetRXIFG, wSetTXIFG, wSetSTTIFG, wSetTXCPTIFG};
            // Look for rising edges
            if (wSetRXIFG & ~syncFlags[3])    rUCAxIFG[UCRXIFG]     <= 1;
            if (wSetTXIFG & ~syncFlags[2])    rUCAxIFG[UCTXIFG]     <= 1;
            if (wSetSTTIFG & ~syncFlags[1])   rUCAxIFG[UCSTTIFG]    <= 1;
            if (wSetTXCPTIFG & ~syncFlags[0]) rUCAxIFG[UCTXCPTIFG]  <= 1;
            
            // Handle UCAxIFG flag clears when IV read
            if (~wUCSWRST && ((MAB & ~1) - START == UCAnIV) && ~MW) begin
                case(rUCAxIV)
                    2: rUCAxIFG[UCRXIFG]    <= 0;
                    4: rUCAxIFG[UCTXIFG]    <= 0;
                    6: rUCAxIFG[UCSTTIFG]   <= 0;
                    8: rUCAxIFG[UCTXCPTIFG] <= 0;
                    default: begin end
                endcase
            end
        end
        // Force reserved bits to 0 in case it was missed above
        rUCAxCTLW0[UCMODEx1:UCSYNC] <= 3'd0; rUCAxCTLW0[UCBRKIE:UCTXBRK] <= 4'd0;
        rUCAxMCTLW[3:1]  <= 3'd0;
        rUCAxSTATW[15:8] <= 8'h00; rUCAxSTATW[UCBRK] <= 0; rUCAxSTATW[UCADDR] <= 0;
        rUCAxRXBUF[15:8] <= 0;
        rUCAxTXBUF[15:8] <= 0;
        rUCAxIE[15:4]    <= 0;
        rUCAxIFG[15:4]   <= 0;
    end
    
    /* Submodule Instantiations */
    BaudRateGenerator RxBRG(
        .BRCLK(BRCLK), .UCABEN(RxBEN & ~reset & ~wUCSWRST),
        .wUC0BRx(rUCAxBRW), .wUCBRFx(wUCBRFx), .wUCBRSx(wUCBRSx),
        .wUCOS16(wUCOS16),
        .BITCLK(RxCLK), .MajorityClk()
    );

    BaudRateGenerator TxBRG(
        .BRCLK(BRCLK), .UCABEN(TxBEN & ~reset & ~wUCSWRST),
        .wUC0BRx(rUCAxBRW), .wUCBRFx(wUCBRFx), .wUCBRSx(wUCBRSx),
        .wUCOS16(wUCOS16),
        .BITCLK(TxCLK), .MajorityClk()
    );

    ReceiveStateMachine RxSM(
        .MCLK(MCLK), .BITCLK(RxCLK), .reset(reset | wUCSWRST),
        .wUCPEN(wUCPEN), .wUCPAR(wUCPAR), .wUCMSB(wUCMSB), .wUC7BIT(wUC7BIT), 
        .wUCSPB(wUCSPB), .wUCRXEIE(wUCRXEIE), 
        .Rx((wUCLISTEN) ? Tx : Rx), .RxIFG(wUCRXIFG),
        .RxBEN(RxBEN), .rUCPE(wUCPE), .rUCFE(wUCFE), .rUCOE(wUCOE), 
        .rSetRxIFG(wSetRXIFG), .oUCRXERR(wUCRXERR), .oSetSTTIFG(wSetSTTIFG),
        .RxData(wRxData), .RxBusy(RxBusy)
    );

    TransmitStateMachine TxSM(
        .BITCLK(TxCLK), .reset(reset | wUCSWRST),
        .wUCPEN(wUCPEN), .wUCPAR(wUCPAR), .wUCMSB(wUCMSB), .wUC7BIT(wUC7BIT), 
        .wUCSPB(wUCSPB),
        .TxData(rUCAxTXBUF[7:0]), 
        .iTXIFG(wUCTXIFG),
        .TxBEN(TxBEN), .setTXIFG(wSetTXIFG), .setTXCPTIFG(wSetTXCPTIFG),
        .TxBusy(TxBusy), 
        .Tx(Tx)
    );

endmodule
