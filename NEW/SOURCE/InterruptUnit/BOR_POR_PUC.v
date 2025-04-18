/*--------------------------------------------------------
    Module Name: BOR_POR_PUC
    Description:
        The BOR, POR, and PUC reset module causes a device reset.
    Inputs:
        RSTn - reset IO pin
        INTACKin - INTACK input from CPU
        IntAddrthru - INT Address index from lower-priority interrupts

    Outputs:
        req - reset request
        INTACKthru - INTACK to lower-priority interrupts
        IntAddrout - INT Address Index sent to CPU
    
    Parameters:
        DELAYBITS - decrement counter width
        DELAY - A decrement counter emulates a BOR circuit as Vss rises

--------------------------------------------------------*/
`timescale 100ns/100ns

module BOR_POR_PUC#(
    parameter   DELAYBITS = 2,
                DELAY = 3
    )(
    input MCLK, RSTn, TEST,
    input INTACKin,
    input [5:0] IntAddrthru,

    output req, INTACKthru, BSLenter,
    output [5:0] IntAddrout
 );
    `include "NEW\\PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    reg [DELAYBITS-1:0] BORcounter;
    reg [7:0] RSTnDebounce;
    reg [1:0] TESTcounter;
    reg       TESTedge;
    reg [1:0] BSLenterHold;

    initial begin 
        BORcounter   = DELAY;
        RSTnDebounce = 0;
        TESTcounter = 2;
        TESTedge = 0;
        BSLenterHold = 0;
    end

    /* Continuous Logic Assignments */
    assign req = (BORcounter || RSTnDebounce);
    assign INTACKthru = INTACKin & ~req;
    assign IntAddrout = (req) ? IVT_RESET : IntAddrthru;
    assign BSLenter = (BSLenterHold != 0 && RSTn);

    /* Sequential Logic Assignments */
    always @(posedge MCLK) begin
        RSTnDebounce <= {RSTnDebounce[6:0], ~RSTn};
        if (BORcounter != 0)
            BORcounter <= BORcounter - 1;

        // TEST Detect
        TESTedge <= TEST;
        if ((|RSTnDebounce) & ~TESTedge & TEST && TESTcounter != 0) begin
            TESTcounter <= TESTcounter - 1;
        end
        else if (RSTnDebounce == 0)
            TESTcounter <= 2;

        if (TESTcounter == 0 & RSTn & TEST)
            BSLenterHold <= 3;
        else if (BSLenterHold != 0 && ~req)
            BSLenterHold <= BSLenterHold - 1;
    end
endmodule
