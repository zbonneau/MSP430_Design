/*--------------------------------------------------------
    Module Name: MSP430
    Description:
        This module implements the CPU430, Memory Files, 
        Interrupt Unit, and peripherals.
    Inputs:
        SysClock - System Clock from FPGA module (12 MHz)
        gpio [46] - 46 gpio pins on 100 mil offset on FPGA board
            - 2 extra IO pins  (15,16) available if not XADC pins
        pmod [8] - 8 PMOD pins on FPGA board
        btn [2] - 2 user buttons on FPGA board

    Outputs:
        led [2] - 2 user LEDs on board
        RGBled [3] - RGB LED on board

--------------------------------------------------------*/
`timescale 100ns/100ns

module MSP430(
    input SysClock,
    inout [43:0] gpio,
    // inout [7:0] pmod,
    // input btn1, btn2,
    input RST,
    output led1, led2,
    output [2:0] RGB
 );
 
    `include "PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    wire MCLK, SMCLK, ACLK, reset, RSTn;
    assign RSTn = ~RST;
    assign led2 = RST;

    wire [15:0] MAB, MDBwrite; // MDBread;
    wor  [15:0] MDBread;
    wire MW, BW;

    wire NMI, INT, INTACK;
    wire [5:0] IntAddrLSBs;

    `ifdef IVT_Timer0A0_USED
        wor  TA0CLK;
        wire TA0CLR0, TA0INT0, TA0INT1;
        wire [TA0_CCM_COUNT-1:0] CCI0A, CCI0B, OUTA0;

        assign CCI0B[0] = 0;
        assign CCI0B[1] = 0;
        assign CCI0B[2] = ACLK;
    `endif 

    `ifdef IVT_Timer1A0_USED
        wor TA1CLK;
        wire TA1CLR0, TA1INT0, TA1INT1;
        wire [TA1_CCM_COUNT-1:0] CCI1A, CCI1B, OUTA1;

        assign CCI1B[1] = 0;
        assign CCI1B[2] = ACLK;
    `endif 

    `ifdef IVT_PORT1_USED
        wire [15:0] pain, paout, padir, paren, pasel0, pasel1;
        wire P1INT, P2INT;
    `endif 

    `ifdef IVT_PORT3_USED
        wire [15:0] pbin, pbout, pbdir, pbren, pbsel0, pbsel1;
        wire P3INT, P4INT;
    `endif 
    
    // initial begin {} = 0; end

    /* Continuous Logic Assignments */
    // assign gpio[GPIO1_1] = btn1;
    // assign gpio[GPIO1_2] = btn2;
    assign led1 = pain[0];
    //  assign led2 = pbin[10];
    assign RGB = ~pain[7:5];
    
    /* Sequential Logic Assignments */

    /* Submodule Instantiations */
    `ifndef RUN_SIMULATION
        ClockSystem CS(
            .sysOsc(SysClock), .reset(reset),
            .MCLK(MCLK), .SMCLK(SMCLK), .ACLK(ACLK)
        );
    `else
        // If Simulation, MCLK, SMCLK = sysOsc = 1 MHz
        reg ACLKr = 0;
        assign MCLK  = SysClock;
        assign SMCLK = SysClock;
        assign ACLK  = ACLKr;
        integer ACLK_div = 0;
        always @(posedge SysClock) begin
            if (ACLK_div == 16) begin
                ACLK_div <= 0;
                ACLKr <= ~ACLK;
            end
            else ACLK_div = ACLK_div + 1;
        end
    `endif

    CPU CPUv1(
        .MCLK(MCLK), .reset(reset),
        .NMI(NMI), .INT(INT), .IntAddrLSBs(IntAddrLSBs),
        .MDBin(MDBread), .MAB(MAB), .MDBout(MDBwrite),
        .MW(MW), .BW(BW),
        .INTACK(INTACK)
    );
      
    BlockMemInterface memInst(
        .MCLK(MCLK),
        .MAB(MAB), .MDBwrite(MDBwrite), .MDBread(MDBread),
        .MW(MW), .BW(BW)
    );

    InterruptUnit IntUnit(
        .MCLK(MCLK), .RSTn(RSTn), .INTACK(INTACK),
        .reset(reset), .NMI(NMI), .INT(INT),
        .Module_52_int(TA0INT0), .Module_52_clr(TA0CLR0), 
        .Module_51_int(TA0INT1), .Module_51_clr(), 
        .Module_47_int(TA1INT0), .Module_47_clr(TA1CLR0), 
        .Module_46_int(TA1INT1), .Module_46_clr(), 
        .Module_45_int(P1INT), .Module_45_clr(), 
        .Module_42_int(P2INT), .Module_42_clr(), 
        .Module_39_int(P3INT), .Module_39_clr(), 
        .Module_38_int(P4INT), .Module_38_clr(), 
        .IntAddrLSBs(IntAddrLSBs)
    );

    `ifdef IVT_Timer0A0_USED
        TimerA #(
            .START(MAP_TIMER_TA0),
            .CCM_COUNT(TA0_CCM_COUNT)
         )TA0(
            .MCLK(MCLK), .reset(reset), 
            .TACLK(TA0CLK), .ACLK(ACLK), .SMCLK(SMCLK), .INCLK(~TA0CLK),
            .MAB(MAB), .MDBwrite(MDBwrite), .MDBread(MDBread),
            .MW(MW), .BW(BW), 
            .TAxCLR0(TA0CLR0), .TAxINT0(TA0INT0), .TAxINT1(TA0INT1),
            .CCInA(CCI0A), .CCInB(CCI0B), .OUTn(OUTA0)
        );
    `endif

    `ifdef IVT_Timer1A0_USED
        TimerA #(
            .START(MAP_TIMER_TA1),
            .CCM_COUNT(TA1_CCM_COUNT)
         )TA1(
            .MCLK(MCLK), .reset(reset), 
            .TACLK(TA1CLK), .ACLK(ACLK), .SMCLK(SMCLK), .INCLK(~TA1CLK),
            .MAB(MAB), .MDBwrite(MDBwrite), .MDBread(MDBread),
            .MW(MW), .BW(BW), 
            .TAxCLR0(TA1CLR0), .TAxINT0(TA1INT0), .TAxINT1(TA1INT1),
            .CCInA(CCI1A), .CCInB(CCI1B), .OUTn(OUTA1)
        );
    `endif

    `ifdef IVT_PORT1_USED
        GPIO16 #(
            .START(MAP_PORTA)
         )PORTA(
            .MCLK(MCLK), .reset(reset),
            .MAB(MAB), .MDBwrite(MDBwrite), .MDBread(MDBread),
            .MW(MW), .BW(BW),
            .PxINT(P1INT), .PyINT(P2INT),
            .PxIN(pain[7:0]), .PyIN(pain[15:8]),
            .PxOUT(paout[7:0]), .PyOUT(paout[15:8]),
            .PxDIR(padir[7:0]), .PyDIR(padir[15:8]),
            .PxREN(paren[7:0]), .PyREN(paren[15:8]),
            .PxSEL0(pasel0[7:0]), .PySEL0(pasel0[15:8]),
            .PxSEL1(pasel1[7:0]), .PySEL1(pasel1[15:8])
        );
        
        PIN PinA0(
            .Px_m(gpio[GPIO1_0]), .PxOUTm(paout[0]), .PxDIRm(padir[0]), .PxRENm(paren[0]), 
            .PxINm(pain[0]), .PxSELm({pasel1[0], pasel0[0]}), 
            .OUT_1(OUTA0[1]), .DIR_1(padir[0]), .IN_1(CCI0A[1]), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA1(
            .Px_m(gpio[GPIO1_1]), .PxOUTm(paout[1]), .PxDIRm(padir[1]), .PxRENm(paren[1]), 
            .PxINm(pain[1]), .PxSELm({pasel1[1], pasel0[1]}), 
            .OUT_1(OUTA0[2]), .DIR_1(padir[1]), .IN_1(CCI0A[2]), 
            .OUT_2(1'b0), .DIR_2(padir[1]), .IN_2(TA1CLK),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA2(
            .Px_m(gpio[GPIO1_2]), .PxOUTm(paout[2]), .PxDIRm(padir[2]), .PxRENm(paren[2]), 
            .PxINm(pain[2]), .PxSELm({pasel1[2], pasel0[2]}), 
            .OUT_1(OUTA1[1]), .DIR_1(padir[2]), .IN_1(CCI1A[1]), 
            .OUT_2(1'b0), .DIR_2(padir[2]), .IN_2(TA0CLK),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA3(
            .Px_m(gpio[GPIO1_3]), .PxOUTm(paout[3]), .PxDIRm(padir[3]), .PxRENm(paren[3]), 
            .PxINm(pain[3]), .PxSELm({pasel1[3], pasel0[3]}), 
            .OUT_1(OUTA1[2]), .DIR_1(padir[3]), .IN_1(CCI1A[2]), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA4(
            .Px_m(gpio[GPIO1_4]), .PxOUTm(paout[4]), .PxDIRm(padir[4]), .PxRENm(paren[4]), 
            .PxINm(pain[4]), .PxSELm({pasel1[4], pasel0[4]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(OUTA1[0]), .DIR_3(padir[4]), .IN_3(CCI1A[0])
        );
        PIN PinA5(
            .Px_m(gpio[GPIO1_5]), .PxOUTm(paout[5]), .PxDIRm(padir[5]), .PxRENm(paren[5]), 
            .PxINm(pain[5]), .PxSELm({pasel1[5], pasel0[5]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(OUTA0[0]), .DIR_3(padir[5]), .IN_3(CCI0A[0])
        );
        PIN PinA6(
            .Px_m(gpio[GPIO1_6]), .PxOUTm(paout[6]), .PxDIRm(padir[6]), .PxRENm(paren[6]), 
            .PxINm(pain[6]), .PxSELm({pasel1[6], pasel0[6]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(OUTA0[1]), .DIR_3(padir[6]), .IN_3(CCI0A[1])
        );
        PIN PinA7(
            .Px_m(gpio[GPIO1_7]), .PxOUTm(paout[7]), .PxDIRm(padir[7]), .PxRENm(paren[7]), 
            .PxINm(pain[7]), .PxSELm({pasel1[7], pasel0[7]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(OUTA0[2]), .DIR_3(padir[7]), .IN_3(CCI0A[2])
        );
        PIN PinA8(
            .Px_m(gpio[GPIO2_0]), .PxOUTm(paout[8]), .PxDIRm(padir[8]), .PxRENm(paren[8]), 
            .PxINm(pain[8]), .PxSELm({pasel1[8], pasel0[8]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA9(
            .Px_m(gpio[GPIO2_1]), .PxOUTm(paout[9]), .PxDIRm(padir[9]), .PxRENm(paren[9]), 
            .PxINm(pain[9]), .PxSELm({pasel1[9], pasel0[9]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA10(
            .Px_m(gpio[GPIO2_2]), .PxOUTm(paout[10]), .PxDIRm(padir[10]), .PxRENm(paren[10]), 
            .PxINm(pain[10]), .PxSELm({pasel1[10], pasel0[10]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA11(
            .Px_m(gpio[GPIO2_3]), .PxOUTm(paout[11]), .PxDIRm(padir[11]), .PxRENm(paren[11]), 
            .PxINm(pain[11]), .PxSELm({pasel1[11], pasel0[11]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA12(
            .Px_m(gpio[GPIO2_4]), .PxOUTm(paout[12]), .PxDIRm(padir[12]), .PxRENm(paren[12]), 
            .PxINm(pain[12]), .PxSELm({pasel1[12], pasel0[12]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA13(
            .Px_m(gpio[GPIO2_5]), .PxOUTm(paout[13]), .PxDIRm(padir[13]), .PxRENm(paren[13]), 
            .PxINm(pain[13]), .PxSELm({pasel1[13], pasel0[13]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA14(
            .Px_m(gpio[GPIO2_6]), .PxOUTm(paout[14]), .PxDIRm(padir[14]), .PxRENm(paren[14]), 
            .PxINm(pain[14]), .PxSELm({pasel1[14], pasel0[14]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinA15(
            .Px_m(gpio[GPIO2_7]), .PxOUTm(paout[15]), .PxDIRm(padir[15]), .PxRENm(paren[15]), 
            .PxINm(pain[15]), .PxSELm({pasel1[15], pasel0[15]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
    `endif    

    `ifdef IVT_PORT3_USED
        GPIO16 #(
            .START(MAP_PORTB)
         )PORTB(
            .MCLK(MCLK), .reset(reset),
            .MAB(MAB), .MDBwrite(MDBwrite), .MDBread(MDBread),
            .MW(MW), .BW(BW),
            .PxINT(P3INT), .PyINT(P4INT),
            .PxIN(pbin[7:0]), .PyIN(pbin[15:8]),
            .PxOUT(pbout[7:0]), .PyOUT(pbout[15:8]),
            .PxDIR(pbdir[7:0]), .PyDIR(pbdir[15:8]),
            .PxREN(pbren[7:0]), .PyREN(pbren[15:8]),
            .PxSEL0(pbsel0[7:0]), .PySEL0(pbsel0[15:8]),
            .PxSEL1(pbsel1[7:0]), .PySEL1(pbsel1[15:8])
        );

        PIN PinB0(
            .Px_m(gpio[GPIO3_0]), .PxOUTm(pbout[0]), .PxDIRm(pbdir[0]), .PxRENm(pbren[0]), 
            .PxINm(pbin[0]), .PxSELm({pbsel1[0], pbsel0[0]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB1(
            .Px_m(gpio[GPIO3_1]), .PxOUTm(pbout[1]), .PxDIRm(pbdir[1]), .PxRENm(pbren[1]), 
            .PxINm(pbin[1]), .PxSELm({pbsel1[1], pbsel0[1]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB2(
            .Px_m(gpio[GPIO3_2]), .PxOUTm(pbout[2]), .PxDIRm(pbdir[2]), .PxRENm(pbren[2]), 
            .PxINm(pbin[2]), .PxSELm({pbsel1[2], pbsel0[2]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB3(
            .Px_m(gpio[GPIO3_3]), .PxOUTm(pbout[3]), .PxDIRm(pbdir[3]), .PxRENm(pbren[3]), 
            .PxINm(pbin[3]), .PxSELm({pbsel1[3], pbsel0[3]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(OUTA1[1]), .DIR_2(pbdir[3]), .IN_2(CCI1A[1]),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB4(
            .Px_m(gpio[GPIO3_4]), .PxOUTm(pbout[4]), .PxDIRm(pbdir[4]), .PxRENm(pbren[4]), 
            .PxINm(pbin[4]), .PxSELm({pbsel1[4], pbsel0[4]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB5(
            .Px_m(gpio[GPIO3_5]), .PxOUTm(pbout[5]), .PxDIRm(pbdir[5]), .PxRENm(pbren[5]), 
            .PxINm(pbin[5]), .PxSELm({pbsel1[5], pbsel0[5]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB6(
            .Px_m(gpio[GPIO3_6]), .PxOUTm(pbout[6]), .PxDIRm(pbdir[6]), .PxRENm(pbren[6]), 
            .PxINm(pbin[6]), .PxSELm({pbsel1[6], pbsel0[6]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB7(
            .Px_m(gpio[GPIO3_7]), .PxOUTm(pbout[7]), .PxDIRm(pbdir[7]), .PxRENm(pbren[7]), 
            .PxINm(pbin[7]), .PxSELm({pbsel1[7], pbsel0[7]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB8(
            .Px_m(gpio[GPIO4_0]), .PxOUTm(pbout[8]), .PxDIRm(pbdir[8]), .PxRENm(pbren[8]), 
            .PxINm(pbin[8]), .PxSELm({pbsel1[8], pbsel0[8]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(MCLK), .DIR_3(pbdir[8]), .IN_3()
        );
        PIN PinB9(
            .Px_m(gpio[GPIO4_1]), .PxOUTm(pbout[9]), .PxDIRm(pbdir[9]), .PxRENm(pbren[9]), 
            .PxINm(pbin[9]), .PxSELm({pbsel1[9], pbsel0[9]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(ACLK), .DIR_3(pbdir[9]), .IN_3()
        );
        PIN PinB10(
            .Px_m(gpio[GPIO4_2]), .PxOUTm(pbout[10]), .PxDIRm(pbdir[10]), .PxRENm(pbren[10]), 
            .PxINm(pbin[10]), .PxSELm({pbsel1[10], pbsel0[10]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB11(
            .Px_m(gpio[GPIO4_3]), .PxOUTm(pbout[11]), .PxDIRm(pbdir[11]), .PxRENm(pbren[11]), 
            .PxINm(pbin[11]), .PxSELm({pbsel1[11], pbsel0[11]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(1'b0), .IN_3()
        );
        PIN PinB12(
            .Px_m(gpio[GPIO4_4]), .PxOUTm(pbout[12]), .PxDIRm(pbdir[12]), .PxRENm(pbren[12]), 
            .PxINm(pbin[12]), .PxSELm({pbsel1[12], pbsel0[12]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(1'b0), .DIR_3(pbdir[12]), .IN_3(TA1CLK)
        );
        PIN PinB13(
            .Px_m(gpio[GPIO4_5]), .PxOUTm(pbout[13]), .PxDIRm(pbdir[13]), .PxRENm(pbren[13]), 
            .PxINm(pbin[13]), .PxSELm({pbsel1[13], pbsel0[13]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(OUTA1[0]), .DIR_3(pbdir[13]), .IN_3(CCI1A[0])
        );
        PIN PinB14(
            .Px_m(gpio[GPIO4_6]), .PxOUTm(pbout[14]), .PxDIRm(pbdir[14]), .PxRENm(pbren[14]), 
            .PxINm(pbin[14]), .PxSELm({pbsel1[14], pbsel0[14]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(OUTA1[1]), .DIR_3(pbdir[14]), .IN_3(CCI1A[1])
        );
        PIN PinB15(
            .Px_m(gpio[GPIO4_7]), .PxOUTm(pbout[15]), .PxDIRm(pbdir[15]), .PxRENm(pbren[15]), 
            .PxINm(pbin[15]), .PxSELm({pbsel1[15], pbsel0[15]}), 
            .OUT_1(1'b0), .DIR_1(1'b0), .IN_1(), 
            .OUT_2(1'b0), .DIR_2(1'b0), .IN_2(),
            .OUT_3(OUTA1[2]), .DIR_3(pbdir[15]), .IN_3(CCI1A[2])
        );
    `endif

endmodule
