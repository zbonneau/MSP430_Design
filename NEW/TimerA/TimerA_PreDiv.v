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

module TimerA_PreDiv(
    input TAxCLK, ACLK, SMCLK, INCLK,
    input reset, wTACLR,
    input [1:0] TASSEL,
    input [1:0] ID,
    input [2:0] IDEX,

    output reg TimerClock
 );
    `include "NEW\\PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    reg [2:0] divCounter, exDivCounter;
    wire clockSelect;
    reg divClock;

    initial begin {divCounter, exDivCounter, divClock, TimerClock} = 0; end

    /* Continuous Logic Assignments */
    assign clockSelect = (TASSEL == TASSEL__TACLK) ? TAxCLK :
                         (TASSEL == TASSEL__ACLK)  ? ACLK   :
                         (TASSEL == TASSEL__SMCLK) ? SMCLK  :
                                                     INCLK  ;

    /* Sequential Logic Assignments */
    // Predivider 
    always @(clockSelect or posedge (reset | wTACLR)) begin
        if (reset | wTACLR) begin
            divClock <= 0;
            case(ID)
                ID__1: divCounter <= 0; 
                ID__2: divCounter <= 1; 
                ID__4: divCounter <= 3; 
                ID__8: divCounter <= 7; 
            endcase
        end else begin
            divCounter <= divCounter - 1;
            if (divCounter == 0) begin
                divClock <= ~divClock;
                case(ID)
                ID__1: divCounter <= 0; 
                ID__2: divCounter <= 1; 
                ID__4: divCounter <= 3; 
                ID__8: divCounter <= 7; 
                endcase
            end
        end
    end

    // Extended Predivider
    always @(divClock or posedge (reset | wTACLR)) begin
        if (reset | wTACLR) begin
            TimerClock   <= 0;
            exDivCounter <= IDEX;
        end else begin
            exDivCounter <= exDivCounter - 1;
            if (exDivCounter == 0) begin
                TimerClock <= ~TimerClock;
                exDivCounter <= IDEX;
            end 
        end
    end

endmodule
