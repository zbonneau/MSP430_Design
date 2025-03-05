/*--------------------------------------------------------
    Module Name : TimerA Testbench
    Description:
        Verifies Functionality of the TimerA

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_TimerA;
localparam CCM_COUNT = 3;

reg MCLK, reset;
reg TACLK, ACLK, SMCLK, INCLK;
reg [15:0] MAB, MDBwrite;
reg MW, BW;
reg TAxCLR0;
reg [CCM_COUNT-1:0] CCInA, CCInB;
wire [15:0] MDBread;
wire TAxINT1, TAxINT0;
wire [CCM_COUNT-1:0] OUTn;

`include "NEW/PARAMS.v"

initial begin 
    {MCLK, reset, TACLK, ACLK, SMCLK, INCLK, MAB, MDBwrite, MW, BW, TAxCLR0, CCInA, CCInB} = 0; 
end

TimerA #(
    .START(MAP_TIMER_TA0),
    .CCM_COUNT(CCM_COUNT)
    )uut(
    .MCLK(MCLK), .reset(reset), 
    .TACLK(TACLK), .ACLK(ACLK), .SMCLK(SMCLK), .INCLK(INCLK), 
    .MAB(MAB), .MDBwrite(MDBwrite), 
    .MW(MW), .BW(BW), 
    .TAxCLR0(TAxCLR0), 
    .CCInA(CCInA), .CCInB(CCInB), 
    .MDBread(MDBread), 
    .TAxINT1(TAxINT1), .TAxINT0(TAxINT0), 
    .OUTn(OUTn)
);

localparam MCLK_PERIOD = 10;
localparam ACLK_PERIOD = 37;
localparam SMCLK_PERIOD = 10;
always #(MCLK_PERIOD/2) MCLK = ~MCLK;
always #(ACLK_PERIOD/2) ACLK = ~ACLK;
always #(SMCLK_PERIOD/2) SMCLK = ~SMCLK;

initial begin
    $dumpfile("TimerA.vcd");
    $dumpvars(0, tb_TimerA);
end

integer i = 1;
initial begin
    `TEST(UpTest, i)
    `TEST(ContinuousTest, i)
    `TEST(UpDownTest, i)

    $finish(0);
end

task MMRconfig(inout [15:0] MMR, input [15:0] Value, input [3:0] bit);
    begin 
        MMR = MMR + (Value << bit);
    end
endtask

task UpTest();
    begin 
    `PULSE(reset)
    /* Configure Timer for ACLK, /3, /2. Enable TAIFG*/
    MW = 1; MAB = TA0CTL; 
    MMRconfig(MDBwrite, TASSEL__ACLK, TASSEL0);
    MMRconfig(MDBwrite, ID__2, ID0);
    MMRconfig(MDBwrite, 1'b1, TAIE);
    MMRconfig(MDBwrite, 1'b1, TACLR);
    #MCLK_PERIOD;

    MAB = TA0EX0; MDBwrite = 2; #MCLK_PERIOD;

    /* Configure CCR0 for 19 counts, no OUTMOD, Enable CCIFG */
    MAB = TA0CCR0; MDBwrite = 19; #MCLK_PERIOD;
    MAB = TA0CCTL0; MDBwrite = 1<<CCIE; #MCLK_PERIOD;

    /* Configure CCR1 for 9 counts, set/reset OUTMOD, enable CCIFG */
    MAB = TA0CCR1;  MDBwrite = 9; #MCLK_PERIOD;
    MAB = TA0CCTL1; MDBwrite = 0; 
    MMRconfig(MDBwrite, OUTMOD__SET_RST, OUTMOD0);
    MMRconfig(MDBwrite, 1'b1, CCIE);
    #MCLK_PERIOD;

    /* Start Timer */
    MAB = TA0CTL; MDBwrite = uut.base.TAxCTL + (MC__UP<<MC0); #MCLK_PERIOD;
    MW = 0; MDBwrite = 0;  
    MAB = TA0R;

    /* Wait for TAIFG */
    @(posedge uut.wTAIFG);

    /* synchronize with MCLK */
    @(negedge MCLK);
    #(6*MCLK);

    /* TAINT0 and INT1 are enabled */
    `PULSE(TAxCLR0);

    MAB = TA0IV; #MCLK_PERIOD;
    {MW, MAB, MDBwrite} = 0;

    /* TAIFG still set. Reset device */
    `PULSE(reset);        
    end
endtask

task ContinuousTest();
    begin
    `PULSE(reset)
    /* Setup Timer for SMCLK, /1 /4, disable TAIE */
    MW = 1; MAB = TA0CTL; MDBwrite= 0;
    MMRconfig(MDBwrite, TASSEL__SMCLK, TASSEL0);
    MMRconfig(MDBwrite, ID__4, ID0);
    #MCLK_PERIOD;

    /* Setup CCR0 for 29, OUTMOD = 0, enable CCIE */
    MAB = TA0CCR0; MDBwrite = 29; #MCLK_PERIOD;
    MAB = TA0CCTL0; MDBwrite = 1<<CCIE; #MCLK_PERIOD;

    /* Setup CCR1 for 26, OUTMOD = Toggle, disable CCIE */
    MAB = TA0CCR1; MDBwrite = 26; #MCLK_PERIOD;
    MAB = TA0CCTL1; MDBwrite = OUTMOD__TOG<<OUTMOD0; #MCLK_PERIOD;

    /* Setup CCR2 for 37, OUTMOD = RST SET, disable CCIE */
    MAB = TA0CCR2; MDBwrite = 37; #MCLK_PERIOD;
    MAB = TA0CCTL2; MDBwrite = OUTMOD__RST_SET<<OUTMOD0; #MCLK_PERIOD;

    /* Clear timer and start in continuous mode */
    MAB = TA0CTL; MDBwrite = uut.base.TAxCTL + (1'b1<<TACLR);
    MMRconfig(MDBwrite, MC__CONTINUOUS, MC0);
    #MCLK_PERIOD;
    {MW, MDBwrite} = 0;

    /* Wait for TAxR ==  */
    MAB = TA0R;
    // #(65*SMCLK_PERIOD*4);
    while(MDBread != 60) #MCLK_PERIOD;

    @(negedge MCLK);
    $display("    TA0R changed @%6d uS", $time/10);
    MW = 1; MDBwrite = 16'hFFF8; #MCLK_PERIOD;
    {MW, MDBwrite} = 0;
    MAB = TA0R;

    /* Wait for Timer Overflow */
    @(posedge uut.wTAIFG);

    /* Synchronize to MCLK */
    @(posedge MCLK);

    /* clear TA0INT0 */
    `PULSE(TAxCLR0)
    
    /* Wait for OUT1 to toggle low */
    @(negedge OUTn[1]);

    #MCLK_PERIOD;
    `PULSE(reset)
    end
endtask

task UpDownTest();
    begin
    `PULSE(reset)
    /* Setup TA0 for ACLK, /1 /1, enable TAIE */
    MW = 1; MAB = TA0CTL; MDBwrite = 1<<TAIE;
    MMRconfig(MDBwrite, TASSEL__ACLK, TASSEL0);
    #MCLK_PERIOD;

    /* Setup CCR0 for 19. OUTMOD = TOGGLE. disable CCIE */
    MAB = TA0CCR0; MDBwrite = 19; #MCLK_PERIOD;
    MAB = TA0CCTL0; MDBwrite = OUTMOD__TOG << OUTMOD0; #MCLK_PERIOD;

    /* Setup CCR1 for 7. OUTMOD = TOGGLE RST. enable CCIE */
    MAB = TA0CCR1; MDBwrite = 7; #MCLK_PERIOD;
    MAB = TA0CCTL1; MDBwrite = (OUTMOD__TOG_RST << OUTMOD0) + (1<<CCIE); #MCLK_PERIOD;

    /* Setup CCR2 for 13. OUTMOD = TOG SET. disable CCIE */
    MAB = TA0CCR2; MDBwrite = 13; #MCLK_PERIOD;
    MAB = TA0CCTL2; MDBwrite = OUTMOD__TOG_SET<<OUTMOD0; #MCLK_PERIOD;

    /* Start Timer in UpDown mode */
    MAB = TA0CTL; MDBwrite = uut.base.TAxCTL + (1<<TACLR) + (MC__UPDOWN<<MC0);  #MCLK_PERIOD;
    {MW,MDBwrite} = 0;
    MAB = TA0R;

    #(80*ACLK_PERIOD);


    `PULSE(reset)
    end
endtask

endmodule
`default_nettype wire
