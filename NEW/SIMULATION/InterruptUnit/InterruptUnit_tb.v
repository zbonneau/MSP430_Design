/*--------------------------------------------------------
    Module Name : InterruptUnit Testbench
    Description:
        Verifies Functionality of the InterruptUnit

--------------------------------------------------------*/

// `include "NEW\\InterruptUnit.v"
`default_nettype none
`timescale 100ns/100ns

module tb_InterruptUnit;
reg clk, rst_n, INTACK, Vacant, TEST;
reg Timer0A0_int, Timer0A1_int, PORT1_int, PORT2_int;

wire reset, NMI, INT, VMA_clr, RST_NMI_clr, BSLenter;
wire [5:0] IntAddrLSBs;
wire Timer0A0_clr, Timer0A1_clr, PORT1_clr, PORT2_clr;

initial begin 
    clk = 0; rst_n = 1; INTACK = 0; Vacant = 0;
    {Timer0A0_int, Timer0A1_int, PORT1_int, PORT2_int} = 0;
end

InterruptUnit uut
(
.MCLK(clk), .RSTn(rst_n), .INTACK(INTACK), .TEST(TEST),// .Vacant(Vacant), 
.reset(reset), .NMI(NMI), .INT(INT), 
// .VMA_clr(VMA_clr), .RST_NMI_clr(RST_NMI_clr), 
.IntAddrLSBs(IntAddrLSBs), .BSLenter(BSLenter),

.Module_52_int(Timer0A0_int), .Module_52_clr(Timer0A0_clr),
.Module_51_int(Timer0A1_int), .Module_51_clr(Timer0A1_clr),
.Module_45_int(PORT1_int),    .Module_45_clr(PORT1_clr),
.Module_42_int(PORT2_int),    .Module_42_clr(PORT2_clr)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    $dumpfile("InterruptUnit.vcd");
    $dumpvars(0, tb_InterruptUnit);
end

initial begin
    INTACK = 1; #CLK_PERIOD;
    while (reset) #CLK_PERIOD;
    #CLK_PERIOD;
    INTACK = 0;
    #(3*CLK_PERIOD);

    // Trigger Device Reset
    `PULSEn(rst_n)

    while (reset) #CLK_PERIOD;

    // Trigger Timer0A0
    Timer0A0_int = 1;

    // ~6 CC for INT entrance. Then INTACK
    #(6*CLK_PERIOD) 
    `PULSE(INTACK)

    // Timer0A0 is a single-source INT, auto clears
    Timer0A0_int = 0;
    #(3*CLK_PERIOD);

    // Trigger PORT1
    PORT1_int = 1;

    // ~6 CC for INT entrance
    #(6*CLK_PERIOD);
    `PULSE(INTACK)

    // PORT1 is a multi-source INT, does not clear on PORT1_clr
    #(3*CLK_PERIOD);
    Vacant = 1;
    
    // ~6 CC for INT entrance
    #(6*CLK_PERIOD);
    `PULSE(INTACK) // clears SNMI
    Vacant = 0;

    // After SNMI ISR, return to PORT1 ISR. P1 Flags cleared in software
    #(3*CLK_PERIOD);
    PORT1_int = 0;

    #CLK_PERIOD;

    $finish(0);
end
endmodule
`default_nettype wire
