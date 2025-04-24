/*--------------------------------------------------------
    Module Name: TimerA_PreDiv
    Description:
        Describes the source select & Pre-division logic 
        of the TimerA module.
    Inputs:
        TAxCLK, ACLK, SMCLK, INCLK - clock options
        TASSEL - Source select
        ID - Division index
        IDEX - Extended division index
        TACLR - logic clear signal (posedge)

    Outputs:
        TimerClock - selected, divided clock signal.

--------------------------------------------------------*/
`timescale 100ns/100ns

module TimerA_PreDiv(
    input TAxCLK, ACLK, SMCLK, INCLK,
    input reset, wTACLR,
    input [1:0] TASSEL,
    input [1:0] ID,
    input [2:0] IDEX,

    output TimerClock
 );
    `include "NEW/PARAMS.v"
    reg [3:0] divCount, ExCount;
    reg rTimerClock;
    wire SelectClock;

    initial begin {divCount, ExCount, rTimerClock} = 0; end

    assign SelectClock = (TASSEL == TASSEL__TACLK) ? TAxCLK :
                         (TASSEL == TASSEL__ACLK)  ?  ACLK  :
                         (TASSEL == TASSEL__SMCLK) ? SMCLK  : 
                                                     INCLK;

    assign TimerClock = ({ID,IDEX}==0) ? SelectClock : rTimerClock;

    always @(posedge SelectClock or posedge reset or posedge wTACLR) begin
        if (reset | wTACLR) begin
            {divCount, ExCount, rTimerClock} <= 0;
        end else if (divCount == 0) begin
            case(ID) 
            0: divCount <= 0;
            1: divCount <= 1;
            2: divCount <= 3;
            3: divCount <= 7;
            endcase
            if (ExCount == 0) begin
                rTimerClock <= 0;
                ExCount <= IDEX;
            end else if (ExCount == ((IDEX >> 1) | IDEX[0])) begin
                rTimerClock <= 1;
                ExCount <= ExCount - 1;
            end else begin
                ExCount <= ExCount - 1;
            end
        end else if (IDEX == 0 && (divCount == ID)) begin
            divCount <= divCount - 1;
            rTimerClock <= 1;
        end else begin
            divCount <= divCount - 1;
        end
    end

endmodule

//  /* Internal signal definitions */
//     reg [2:0] divCounter, exDivCounter;
//     wire clockSelect;
//     reg divClock;

//     wire [1:0]edgeDetect;
//     assign edgeDetect[0] = clockSelect ^ ~clockSelect;
//     assign edgeDetect[1] = divClock ^ ~divClock;

//     initial begin {divCounter, exDivCounter, divClock, TimerClock} = 0; end

//     /* Continuous Logic Assignments */
//     assign clockSelect = (TASSEL == TASSEL__TACLK) ? TAxCLK :
//                          (TASSEL == TASSEL__ACLK)  ? ACLK   :
//                          (TASSEL == TASSEL__SMCLK) ? SMCLK  :
//                                                      INCLK  ;

//     /* Sequential Logic Assignments */
//     // Predivider 
//     always @(posedge edgeDetect[0] or posedge reset or posedge wTACLR) begin
//         if (reset | wTACLR) begin
//             divClock <= 0;
//             divCounter <= 0;
//         end else begin
//             if (divCounter == 0) begin
//                 divClock <= ~divClock;
//                 case(ID)
//                 ID__1: divCounter <= 0; 
//                 ID__2: divCounter <= 1; 
//                 ID__4: divCounter <= 3; 
//                 ID__8: divCounter <= 7; 
//                 endcase
//             end else begin
//             divCounter <= divCounter - 1;
//             end
//         end
//     end

//     // Extended Predivider
//     always @(posedge edgeDetect[1] or posedge reset or posedge wTACLR) begin
//         if (reset | wTACLR) begin
//             TimerClock   <= 0;
//             exDivCounter <= 0;
//         end else begin
//             if (exDivCounter == 0) begin
//                 TimerClock <= ~TimerClock;
//                 exDivCounter <= IDEX;
//             end else begin
//                 exDivCounter <= exDivCounter - 1;
//             end
//         end
//     end
