/*--------------------------------------------------------
    Module Name: InterruptUnit
    Description:
        The Interrupt Unit Connects the collection of daisy-
        chained interrupt modules to the CPU. Because it contains
        the BOR POR PUC reset circuit, it is also the origin
        of the device-wide reset signal
    Inputs:
        INTACK - from CPU
        RST_NMI - RSTn and user NMI reset pin. Control logic for 
                    rst vs NMI mode probably never implemented
        Vacant - Vacant Memory Access - SNMI - probably never implemented
        Module_n_int - interrupt source flags from module n.

    Outputs:
        reset - device-wide reset signal
        NMI   - SNMI | UNMI. Probably never triggers
        INT   - Maskable Interrupt request
        IntAddrLSBs - Interrupt Address Index
        Module_n_clr - interrupt clear flag to module n

--------------------------------------------------------*/
`timescale 100ns/100ns

module InterruptUnit(
    input MCLK, RSTn, INTACK, TEST, 
    output reset, NMI, INT, BSLenter,

    // Conditionally Compiled netlist elements
    `ifdef IVT_SNMI_USED
        input Vacant,
        output VMA_clr, 
     `endif 
    `ifdef IVT_UNMI_USED
        output RST_NMI_clr,
     `endif
    `ifdef IVT_ComparatorE_USED 
        input Module_60_int, 
        output Module_60_clr, 
     `endif
    `ifdef IVT_Timer0B0_USED 
        input Module_59_int, 
        output Module_59_clr, 
     `endif
    `ifdef IVT_Timer0B1_USED 
        input Module_58_int, 
        output Module_58_clr, 
     `endif
    `ifdef IVT_WDT_USED 
        input Module_57_int,
        output Module_57_clr,
     `endif
    `ifdef IVT_ESI_USED 
        input Module_56_int, 
        output Module_56_clr, 
     `endif
    `ifdef IVT_eUSCI_A0_USED 
        input Module_55_int, 
        output Module_55_clr, 
     `endif
    `ifdef IVT_eUSCI_B0_USED 
        input Module_54_int, 
        output Module_54_clr, 
     `endif
    `ifdef IVT_ADC12_B_USED 
        input Module_53_int, 
        output Module_53_clr, 
     `endif
    `ifdef IVT_Timer0A0_USED 
        input Module_52_int, 
        output Module_52_clr, 
     `endif
    `ifdef IVT_Timer0A1_USED 
        input Module_51_int, 
        output Module_51_clr, 
     `endif
    `ifdef IVT_eUSCI_A1_USED 
        input Module_50_int, 
        output Module_50_clr, 
     `endif
    `ifdef IVT_eUSCI_B1_USED 
        input Module_49_int,
        output Module_49_clr,
     `endif
    `ifdef IVT_DMA_USED 
        input Module_48_int, 
        output Module_48_clr, 
     `endif
    `ifdef IVT_Timer1A0_USED 
        input Module_47_int, 
        output Module_47_clr, 
     `endif
    `ifdef IVT_Timer1A1_USED 
        input Module_46_int, 
        output Module_46_clr, 
     `endif
    `ifdef IVT_PORT1_USED 
        input Module_45_int, 
        output Module_45_clr, 
     `endif
    `ifdef IVT_Timer2A0_USED 
        input Module_44_int, 
        output Module_44_clr, 
     `endif
    `ifdef IVT_Timer2A1_USED 
        input Module_43_int, 
        output Module_43_clr, 
     `endif
    `ifdef IVT_PORT2_USED 
        input Module_42_int, 
        output Module_42_clr, 
     `endif
    `ifdef IVT_Timer3A0_USED 
        input Module_41_int, 
        output Module_41_clr, 
     `endif
    `ifdef IVT_Timer3A1_USED 
        input Module_40_int, 
        output Module_40_clr, 
     `endif
    `ifdef IVT_PORT3_USED 
        input Module_39_int, 
        output Module_39_clr, 
     `endif
    `ifdef IVT_PORT4_USED 
        input Module_38_int, 
        output Module_38_clr, 
     `endif
    `ifdef IVT_LCD_C_USED 
        input Module_37_int, 
        output Module_37_clr, 
     `endif
    `ifdef IVT_RTC_C_USED 
        input Module_36_int, 
        output Module_36_clr, 
     `endif
    `ifdef IVT_AES_USED 
        input Module_35_int,
        output Module_35_clr,
     `endif
    // Netlist requires no comma at the end. Place one constant element here
    output [5:0] IntAddrLSBs
 );
    `include "NEW\\PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    wire 
    INTACK_from_RESET,          INTACK_from_SNMI,       INTACK_from_UNMI, 
    INTACK_from_ComparatorE,    INTACK_from_Timer0B0,   INTACK_from_Timer0B1,
    INTACK_from_WDT,            INTACK_from_ESI,        INTACK_from_eUSCI_A0,
    INTACK_from_eUSCI_B0,       INTACK_from_ADC12_B,    INTACK_from_Timer0A0, 
    INTACK_from_Timer0A1,       INTACK_from_eUSCI_A1,   INTACK_from_eUSCI_B1, 
    INTACK_from_DMA,            INTACK_from_Timer1A0,   INTACK_from_Timer1A1, 
    INTACK_from_PORT1,          INTACK_from_Timer2A0,   INTACK_from_Timer2A1, 
    INTACK_from_PORT2,          INTACK_from_Timer3A0,   INTACK_from_Timer3A1, 
    INTACK_from_PORT3,          INTACK_from_PORT4,      INTACK_from_LCD_C, 
    INTACK_from_RTC_C,          INTACK_from_AES;

    wire
    REQ_from_RESET,             REQ_from_SNMI,          REQ_from_UNMI, 
    REQ_from_ComparatorE,       REQ_from_Timer0B0,      REQ_from_Timer0B1, 
    REQ_from_WDT,               REQ_from_ESI,           REQ_from_eUSCI_A0, 
    REQ_from_eUSCI_B0,          REQ_from_ADC12_B,       REQ_from_Timer0A0, 
    REQ_from_Timer0A1,          REQ_from_eUSCI_A1,      REQ_from_eUSCI_B1, 
    REQ_from_DMA,               REQ_from_Timer1A0,      REQ_from_Timer1A1, 
    REQ_from_PORT1,             REQ_from_Timer2A0,      REQ_from_Timer2A1, 
    REQ_from_PORT2,             REQ_from_Timer3A0,      REQ_from_Timer3A1, 
    REQ_from_PORT3,             REQ_from_PORT4,         REQ_from_LCD_C, 
    REQ_from_RTC_C,             REQ_from_AES;

    wire [5:0]
    IntAddr_from_RESET,         IntAddr_from_SNMI,      IntAddr_from_UNMI, 
    IntAddr_from_ComparatorE,   IntAddr_from_Timer0B0,  IntAddr_from_Timer0B1, 
    IntAddr_from_WDT,           IntAddr_from_ESI,       IntAddr_from_eUSCI_A0, 
    IntAddr_from_eUSCI_B0,      IntAddr_from_ADC12_B,   IntAddr_from_Timer0A0, 
    IntAddr_from_Timer0A1,      IntAddr_from_eUSCI_A1,  IntAddr_from_eUSCI_B1, 
    IntAddr_from_DMA,           IntAddr_from_Timer1A0,  IntAddr_from_Timer1A1, 
    IntAddr_from_PORT1,         IntAddr_from_Timer2A0,  IntAddr_from_Timer2A1, 
    IntAddr_from_PORT2,         IntAddr_from_Timer3A0,  IntAddr_from_Timer3A1, 
    IntAddr_from_PORT3,         IntAddr_from_PORT4,     IntAddr_from_LCD_C,
    IntAddr_from_RTC_C,         IntAddr_from_AES;


    /* Continuous Logic Assignments */
    assign IntAddrLSBs = IntAddr_from_RESET;
    assign reset = REQ_from_RESET;
    assign NMI = ~REQ_from_RESET & REQ_from_SNMI;
    assign INT = REQ_from_ComparatorE;

    /* Module Instantiations */
    BOR_POR_PUC #(
        .DELAYBITS(`BOR_DELAYBITS),
        .DELAY(`BOR_DELAY)
        ) resetModule(
        .MCLK(MCLK), .RSTn(RSTn), .TEST(TEST),
        .INTACKin(INTACK), .IntAddrthru(IntAddr_from_SNMI),
        .req(REQ_from_RESET), .INTACKthru(INTACK_from_RESET),
        .IntAddrout(IntAddr_from_RESET),
        .BSLenter(BSLenter)
    );

    /* Conditional compilation starts here. If a module is defined as being 
     * used, generate its interrupt module.
     */
    `ifdef IVT_SNMI_USED
        InterruptModule #(
            .INDEX(IVT_SNMI)
            ) Int_SNMI (
            .INT(Vacant), .INTACKin(INTACK_from_RESET),
            .REQthru(REQ_from_UNMI), .IntAddrthru(IntAddr_from_UNMI),
            .CLR(VMA_clr), .INTACKthru(INTACK_from_SNMI),
            .REQout(REQ_from_SNMI), .IntAddrout(IntAddr_from_SNMI) 
        );
     `else
        assign REQ_from_SNMI = REQ_from_UNMI;
        assign IntAddr_from_SNMI = IntAddr_from_UNMI;
        assign INTACK_from_SNMI = INTACK_from_RESET;
    `endif
    
    `ifdef IVT_UNMI_USED
        InterruptModule #(
            .INDEX(IVT_UNMI)
            ) Int_UNMI (
            .INT(~RSTn), .INTACKin(INTACK_from_SNMI),
            .REQthru(1'b0), .IntAddrthru(IntAddr_from_ComparatorE),
            .CLR(RST_NMI_clr), .INTACKthru(INTACK_from_UNMI),
            .REQout(REQ_from_UNMI), .IntAddrout(IntAddr_from_UNMI) 
        );
     `else
        assign REQ_from_UNMI = 1'b0;
        assign IntAddr_from_UNMI = IntAddr_from_ComparatorE;
        assign INTACK_from_UNMI = INTACK_from_SNMI;
    `endif

    `ifdef IVT_ComparatorE_USED
        InterruptModule #(
            .INDEX(IVT_ComparatorE)
            ) Int_ComparatorE (
            .INT(Module_60_int), .INTACKin(INTACK_from_UNMI),
            .REQthru(REQ_from_Timer0B0), .IntAddrthru(IntAddr_from_Timer0B0),
            .CLR(Module_60_clr), .INTACKthru(INTACK_from_ComparatorE),
            .REQout(REQ_from_ComparatorE), .IntAddrout(IntAddr_from_ComparatorE) 
        );
     `else
        assign REQ_from_ComparatorE = REQ_from_Timer0B0;
        assign IntAddr_from_ComparatorE = IntAddr_from_Timer0B0;
        assign INTACK_from_ComparatorE = INTACK_from_UNMI;
    `endif
   
   `ifdef IVT_Timer0B0_USED
       InterruptModule #(
           .INDEX(IVT_Timer0B0)
           ) Int_Timer0B0 (
           .INT(Module_59_int), .INTACKin(INTACK_from_ComparatorE),
           .REQthru(REQ_from_Timer0B1), .IntAddrthru(IntAddr_from_Timer0B1),
           .CLR(Module_59_clr), .INTACKthru(INTACK_from_Timer0B0),
           .REQout(REQ_from_Timer0B0), .IntAddrout(IntAddr_from_Timer0B0) 
       );
    `else
       assign REQ_from_Timer0B0 = REQ_from_Timer0B1;
       assign IntAddr_from_Timer0B0 = IntAddr_from_Timer0B1;
       assign INTACK_from_Timer0B0 = INTACK_from_ComparatorE;
   `endif
   
   `ifdef IVT_Timer0B1_USED
       InterruptModule #(
           .INDEX(IVT_Timer0B1)
           ) Int_Timer0B1 (
           .INT(Module_58_int), .INTACKin(INTACK_from_Timer0B0),
           .REQthru(REQ_from_WDT), .IntAddrthru(IntAddr_from_WDT),
           .CLR(Module_58_clr), .INTACKthru(INTACK_from_Timer0B1),
           .REQout(REQ_from_Timer0B1), .IntAddrout(IntAddr_from_Timer0B1) 
       );
    `else
       assign REQ_from_Timer0B1 = REQ_from_WDT;
       assign IntAddr_from_Timer0B1 = IntAddr_from_WDT;
       assign INTACK_from_Timer0B1 = INTACK_from_Timer0B0;
   `endif
   
   `ifdef IVT_WDT_USED
       InterruptModule #(
           .INDEX(IVT_WDT)
           ) Int_WDT (
           .INT(Module_57_int), .INTACKin(INTACK_from_Timer0B1),
           .REQthru(REQ_from_ESI), .IntAddrthru(IntAddr_from_ESI),
           .CLR(Module_57_clr), .INTACKthru(INTACK_from_WDT),
           .REQout(REQ_from_WDT), .IntAddrout(IntAddr_from_WDT) 
       );
    `else
       assign REQ_from_WDT = REQ_from_ESI;
       assign IntAddr_from_WDT = IntAddr_from_ESI;
       assign INTACK_from_WDT = INTACK_from_Timer0B1;
   `endif
   
   `ifdef IVT_ESI_USED
       InterruptModule #(
           .INDEX(IVT_ESI)
           ) Int_ESI (
           .INT(Module_56_int), .INTACKin(INTACK_from_WDT),
           .REQthru(REQ_from_eUSCI_A0), .IntAddrthru(IntAddr_from_eUSCI_A0),
           .CLR(Module_56_clr), .INTACKthru(INTACK_from_ESI),
           .REQout(REQ_from_ESI), .IntAddrout(IntAddr_from_ESI) 
       );
    `else
       assign REQ_from_ESI = REQ_from_eUSCI_A0;
       assign IntAddr_from_ESI = IntAddr_from_eUSCI_A0;
       assign INTACK_from_ESI = INTACK_from_WDT;
   `endif
   
   `ifdef IVT_eUSCI_A0_USED
       InterruptModule #(
           .INDEX(IVT_eUSCI_A0)
           ) Int_eUSCI_A0 (
           .INT(Module_55_int), .INTACKin(INTACK_from_ESI),
           .REQthru(REQ_from_eUSCI_B0), .IntAddrthru(IntAddr_from_eUSCI_B0),
           .CLR(Module_55_clr), .INTACKthru(INTACK_from_eUSCI_A0),
           .REQout(REQ_from_eUSCI_A0), .IntAddrout(IntAddr_from_eUSCI_A0) 
       );
    `else
       assign REQ_from_eUSCI_A0 = REQ_from_eUSCI_B0;
       assign IntAddr_from_eUSCI_A0 = IntAddr_from_eUSCI_B0;
       assign INTACK_from_eUSCI_A0 = INTACK_from_ESI;
   `endif
   
   `ifdef IVT_eUSCI_B0_USED
       InterruptModule #(
           .INDEX(IVT_eUSCI_B0)
           ) Int_eUSCI_B0 (
           .INT(Module_54_int), .INTACKin(INTACK_from_eUSCI_A0),
           .REQthru(REQ_from_ADC12_B), .IntAddrthru(IntAddr_from_ADC12_B),
           .CLR(Module_54_clr), .INTACKthru(INTACK_from_eUSCI_B0),
           .REQout(REQ_from_eUSCI_B0), .IntAddrout(IntAddr_from_eUSCI_B0) 
       );
    `else
       assign REQ_from_eUSCI_B0 = REQ_from_ADC12_B;
       assign IntAddr_from_eUSCI_B0 = IntAddr_from_ADC12_B;
       assign INTACK_from_eUSCI_B0 = INTACK_from_eUSCI_A0;
   `endif
   
   `ifdef IVT_ADC12_B_USED
       InterruptModule #(
           .INDEX(IVT_ADC12_B)
           ) Int_ADC12_B (
           .INT(Module_53_int), .INTACKin(INTACK_from_eUSCI_B0),
           .REQthru(REQ_from_Timer0A0), .IntAddrthru(IntAddr_from_Timer0A0),
           .CLR(Module_53_clr), .INTACKthru(INTACK_from_ADC12_B),
           .REQout(REQ_from_ADC12_B), .IntAddrout(IntAddr_from_ADC12_B) 
       );
    `else
       assign REQ_from_ADC12_B = REQ_from_Timer0A0;
       assign IntAddr_from_ADC12_B = IntAddr_from_Timer0A0;
       assign INTACK_from_ADC12_B = INTACK_from_eUSCI_B0;
   `endif
   
   `ifdef IVT_Timer0A0_USED
       InterruptModule #(
           .INDEX(IVT_Timer0A0)
           ) Int_Timer0A0 (
           .INT(Module_52_int), .INTACKin(INTACK_from_ADC12_B),
           .REQthru(REQ_from_Timer0A1), .IntAddrthru(IntAddr_from_Timer0A1),
           .CLR(Module_52_clr), .INTACKthru(INTACK_from_Timer0A0),
           .REQout(REQ_from_Timer0A0), .IntAddrout(IntAddr_from_Timer0A0) 
       );
    `else
       assign REQ_from_Timer0A0 = REQ_from_Timer0A1;
       assign IntAddr_from_Timer0A0 = IntAddr_from_Timer0A1;
       assign INTACK_from_Timer0A0 = INTACK_from_ADC12_B;
   `endif
   
   `ifdef IVT_Timer0A1_USED
       InterruptModule #(
           .INDEX(IVT_Timer0A1)
           ) Int_Timer0A1 (
           .INT(Module_51_int), .INTACKin(INTACK_from_Timer0A0),
           .REQthru(REQ_from_eUSCI_A1), .IntAddrthru(IntAddr_from_eUSCI_A1),
           .CLR(Module_51_clr), .INTACKthru(INTACK_from_Timer0A1),
           .REQout(REQ_from_Timer0A1), .IntAddrout(IntAddr_from_Timer0A1) 
       );
    `else
       assign REQ_from_Timer0A1 = REQ_from_eUSCI_A1;
       assign IntAddr_from_Timer0A1 = IntAddr_from_eUSCI_A1;
       assign INTACK_from_Timer0A1 = INTACK_from_Timer0A0;
   `endif
   
   `ifdef IVT_eUSCI_A1_USED
       InterruptModule #(
           .INDEX(IVT_eUSCI_A1)
           ) Int_eUSCI_A1 (
           .INT(Module_50_int), .INTACKin(INTACK_from_Timer0A1),
           .REQthru(REQ_from_eUSCI_B1), .IntAddrthru(IntAddr_from_eUSCI_B1),
           .CLR(Module_50_clr), .INTACKthru(INTACK_from_eUSCI_A1),
           .REQout(REQ_from_eUSCI_A1), .IntAddrout(IntAddr_from_eUSCI_A1) 
       );
    `else
       assign REQ_from_eUSCI_A1 = REQ_from_eUSCI_B1;
       assign IntAddr_from_eUSCI_A1 = IntAddr_from_eUSCI_B1;
       assign INTACK_from_eUSCI_A1 = INTACK_from_Timer0A1;
   `endif
   
   `ifdef IVT_eUSCI_B1_USED
       InterruptModule #(
           .INDEX(IVT_eUSCI_B1)
           ) Int_eUSCI_B1 (
           .INT(Module_49_int), .INTACKin(INTACK_from_eUSCI_A1),
           .REQthru(REQ_from_DMA), .IntAddrthru(IntAddr_from_DMA),
           .CLR(Module_49_clr), .INTACKthru(INTACK_from_eUSCI_B1),
           .REQout(REQ_from_eUSCI_B1), .IntAddrout(IntAddr_from_eUSCI_B1) 
       );
    `else
       assign REQ_from_eUSCI_B1 = REQ_from_DMA;
       assign IntAddr_from_eUSCI_B1 = IntAddr_from_DMA;
       assign INTACK_from_eUSCI_B1 = INTACK_from_eUSCI_A1;
   `endif
   
   `ifdef IVT_DMA_USED
       InterruptModule #(
           .INDEX(IVT_DMA)
           ) Int_DMA (
           .INT(Module_48_int), .INTACKin(INTACK_from_eUSCI_B1),
           .REQthru(REQ_from_Timer1A0), .IntAddrthru(IntAddr_from_Timer1A0),
           .CLR(Module_48_clr), .INTACKthru(INTACK_from_DMA),
           .REQout(REQ_from_DMA), .IntAddrout(IntAddr_from_DMA) 
       );
    `else
       assign REQ_from_DMA = REQ_from_Timer1A0;
       assign IntAddr_from_DMA = IntAddr_from_Timer1A0;
       assign INTACK_from_DMA = INTACK_from_eUSCI_B1;
   `endif
   
   `ifdef IVT_Timer1A0_USED
       InterruptModule #(
           .INDEX(IVT_Timer1A0)
           ) Int_Timer1A0 (
           .INT(Module_47_int), .INTACKin(INTACK_from_DMA),
           .REQthru(REQ_from_Timer1A1), .IntAddrthru(IntAddr_from_Timer1A1),
           .CLR(Module_47_clr), .INTACKthru(INTACK_from_Timer1A0),
           .REQout(REQ_from_Timer1A0), .IntAddrout(IntAddr_from_Timer1A0) 
       );
    `else
       assign REQ_from_Timer1A0 = REQ_from_Timer1A1;
       assign IntAddr_from_Timer1A0 = IntAddr_from_Timer1A1;
       assign INTACK_from_Timer1A0 = INTACK_from_DMA;
   `endif
   
   `ifdef IVT_Timer1A1_USED
       InterruptModule #(
           .INDEX(IVT_Timer1A1)
           ) Int_Timer1A1 (
           .INT(Module_46_int), .INTACKin(INTACK_from_Timer1A0),
           .REQthru(REQ_from_PORT1), .IntAddrthru(IntAddr_from_PORT1),
           .CLR(Module_46_clr), .INTACKthru(INTACK_from_Timer1A1),
           .REQout(REQ_from_Timer1A1), .IntAddrout(IntAddr_from_Timer1A1) 
       );
    `else
       assign REQ_from_Timer1A1 = REQ_from_PORT1;
       assign IntAddr_from_Timer1A1 = IntAddr_from_PORT1;
       assign INTACK_from_Timer1A1 = INTACK_from_Timer1A0;
   `endif
   
   `ifdef IVT_PORT1_USED
       InterruptModule #(
           .INDEX(IVT_PORT1)
           ) Int_PORT1 (
           .INT(Module_45_int), .INTACKin(INTACK_from_Timer1A1),
           .REQthru(REQ_from_Timer2A0), .IntAddrthru(IntAddr_from_Timer2A0),
           .CLR(Module_45_clr), .INTACKthru(INTACK_from_PORT1),
           .REQout(REQ_from_PORT1), .IntAddrout(IntAddr_from_PORT1) 
       );
    `else
       assign REQ_from_PORT1 = REQ_from_Timer2A0;
       assign IntAddr_from_PORT1 = IntAddr_from_Timer2A0;
       assign INTACK_from_PORT1 = INTACK_from_Timer1A1;
   `endif
   
   `ifdef IVT_Timer2A0_USED
       InterruptModule #(
           .INDEX(IVT_Timer2A0)
           ) Int_Timer2A0 (
           .INT(Module_44_int), .INTACKin(INTACK_from_PORT1),
           .REQthru(REQ_from_Timer2A1), .IntAddrthru(IntAddr_from_Timer2A1),
           .CLR(Module_44_clr), .INTACKthru(INTACK_from_Timer2A0),
           .REQout(REQ_from_Timer2A0), .IntAddrout(IntAddr_from_Timer2A0) 
       );
    `else
       assign REQ_from_Timer2A0 = REQ_from_Timer2A1;
       assign IntAddr_from_Timer2A0 = IntAddr_from_Timer2A1;
       assign INTACK_from_Timer2A0 = INTACK_from_PORT1;
   `endif
   
   `ifdef IVT_Timer2A1_USED
       InterruptModule #(
           .INDEX(IVT_Timer2A1)
           ) Int_Timer2A1 (
           .INT(Module_43_int), .INTACKin(INTACK_from_Timer2A0),
           .REQthru(REQ_from_PORT2), .IntAddrthru(IntAddr_from_PORT2),
           .CLR(Module_43_clr), .INTACKthru(INTACK_from_Timer2A1),
           .REQout(REQ_from_Timer2A1), .IntAddrout(IntAddr_from_Timer2A1) 
       );
    `else
       assign REQ_from_Timer2A1 = REQ_from_PORT2;
       assign IntAddr_from_Timer2A1 = IntAddr_from_PORT2;
       assign INTACK_from_Timer2A1 = INTACK_from_Timer2A0;
   `endif
   
   `ifdef IVT_PORT2_USED
       InterruptModule #(
           .INDEX(IVT_PORT2)
           ) Int_PORT2 (
           .INT(Module_42_int), .INTACKin(INTACK_from_Timer2A1),
           .REQthru(REQ_from_Timer3A0), .IntAddrthru(IntAddr_from_Timer3A0),
           .CLR(Module_42_clr), .INTACKthru(INTACK_from_PORT2),
           .REQout(REQ_from_PORT2), .IntAddrout(IntAddr_from_PORT2) 
       );
    `else
       assign REQ_from_PORT2 = REQ_from_Timer3A0;
       assign IntAddr_from_PORT2 = IntAddr_from_Timer3A0;
       assign INTACK_from_PORT2 = INTACK_from_Timer2A1;
   `endif
   
   `ifdef IVT_Timer3A0_USED
       InterruptModule #(
           .INDEX(IVT_Timer3A0)
           ) Int_Timer3A0 (
           .INT(Module_41_int), .INTACKin(INTACK_from_PORT2),
           .REQthru(REQ_from_Timer3A1), .IntAddrthru(IntAddr_from_Timer3A1),
           .CLR(Module_41_clr), .INTACKthru(INTACK_from_Timer3A0),
           .REQout(REQ_from_Timer3A0), .IntAddrout(IntAddr_from_Timer3A0) 
       );
    `else
       assign REQ_from_Timer3A0 = REQ_from_Timer3A1;
       assign IntAddr_from_Timer3A0 = IntAddr_from_Timer3A1;
       assign INTACK_from_Timer3A0 = INTACK_from_PORT2;
   `endif
   
   `ifdef IVT_Timer3A1_USED
       InterruptModule #(
           .INDEX(IVT_Timer3A1)
           ) Int_Timer3A1 (
           .INT(Module_40_int), .INTACKin(INTACK_from_Timer3A0),
           .REQthru(REQ_from_PORT3), .IntAddrthru(IntAddr_from_PORT3),
           .CLR(Module_40_clr), .INTACKthru(INTACK_from_Timer3A1),
           .REQout(REQ_from_Timer3A1), .IntAddrout(IntAddr_from_Timer3A1) 
       );
    `else
       assign REQ_from_Timer3A1 = REQ_from_PORT3;
       assign IntAddr_from_Timer3A1 = IntAddr_from_PORT3;
       assign INTACK_from_Timer3A1 = INTACK_from_Timer3A0;
   `endif
   
   `ifdef IVT_PORT3_USED
       InterruptModule #(
           .INDEX(IVT_PORT3)
           ) Int_PORT3 (
           .INT(Module_39_int), .INTACKin(INTACK_from_Timer3A1),
           .REQthru(REQ_from_PORT4), .IntAddrthru(IntAddr_from_PORT4),
           .CLR(Module_39_clr), .INTACKthru(INTACK_from_PORT3),
           .REQout(REQ_from_PORT3), .IntAddrout(IntAddr_from_PORT3) 
       );
    `else
       assign REQ_from_PORT3 = REQ_from_PORT4;
       assign IntAddr_from_PORT3 = IntAddr_from_PORT4;
       assign INTACK_from_PORT3 = INTACK_from_Timer3A1;
   `endif
   
   `ifdef IVT_PORT4_USED
       InterruptModule #(
           .INDEX(IVT_PORT4)
           ) Int_PORT4 (
           .INT(Module_38_int), .INTACKin(INTACK_from_PORT3),
           .REQthru(REQ_from_LCD_C), .IntAddrthru(IntAddr_from_LCD_C),
           .CLR(Module_38_clr), .INTACKthru(INTACK_from_PORT4),
           .REQout(REQ_from_PORT4), .IntAddrout(IntAddr_from_PORT4) 
       );
    `else
       assign REQ_from_PORT4 = REQ_from_LCD_C;
       assign IntAddr_from_PORT4 = IntAddr_from_LCD_C;
       assign INTACK_from_PORT4 = INTACK_from_PORT3;
   `endif
   
   `ifdef IVT_LCD_C_USED
       InterruptModule #(
           .INDEX(IVT_LCD_C)
           ) Int_LCD_C (
           .INT(Module_37_int), .INTACKin(INTACK_from_PORT4),
           .REQthru(REQ_from_RTC_C), .IntAddrthru(IntAddr_from_RTC_C),
           .CLR(Module_37_clr), .INTACKthru(INTACK_from_LCD_C),
           .REQout(REQ_from_LCD_C), .IntAddrout(IntAddr_from_LCD_C) 
       );
    `else
       assign REQ_from_LCD_C = REQ_from_RTC_C;
       assign IntAddr_from_LCD_C = IntAddr_from_RTC_C;
       assign INTACK_from_LCD_C = INTACK_from_PORT4;
   `endif
   
   `ifdef IVT_RTC_C_USED
       InterruptModule #(
           .INDEX(IVT_RTC_C)
           ) Int_RTC_C (
           .INT(Module_36_int), .INTACKin(INTACK_from_LCD_C),
           .REQthru(REQ_from_AES), .IntAddrthru(IntAddr_from_AES),
           .CLR(Module_36_clr), .INTACKthru(INTACK_from_RTC_C),
           .REQout(REQ_from_RTC_C), .IntAddrout(IntAddr_from_RTC_C) 
       );
    `else
       assign REQ_from_RTC_C = REQ_from_AES;
       assign IntAddr_from_RTC_C = IntAddr_from_AES;
       assign INTACK_from_RTC_C = INTACK_from_LCD_C;
   `endif
   
   `ifdef IVT_AES_USED
       InterruptModule #(
           .INDEX(IVT_AES)
           ) Int_AES (
           .INT(Module_35_int), .INTACKin(INTACK_from_RTC_C),
           .REQthru(1'b0), .IntAddrthru(IVT_RESET),
           .CLR(Module_35_clr), .INTACKthru(INTACK_from_AES),
           .REQout(REQ_from_AES), .IntAddrout(IntAddr_from_AES) 
       );
    `else
       assign REQ_from_AES = 1'b0;
       assign IntAddr_from_AES = IVT_RESET; // default INTADDR when none active
       assign INTACK_from_AES = INTACK_from_RTC_C;
   `endif
   
endmodule
