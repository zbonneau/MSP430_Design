
    // Defines for CAR states
        localparam CAR_BITS      = 6;
        localparam [CAR_BITS-1:0] 
                  CAR_0         = 0,
                  CAR_REG_REG   = 1,
                  CAR_REG_IDX0  = 2,
                  CAR_REG_IDX1  = 3,
                  CAR_REG_IDX2  = 4,
                  CAR_REG_IDX3  = 5,
                  CAR_IND_REG0  = 6,
                  CAR_IND_REG1  = 7,
                  CAR_IND_IDX0  = 8,
                  CAR_IND_IDX1  = 9,
                  CAR_IND_IDX2  = 10,
                  CAR_IND_IDX3  = 11,
                  CAR_IND_IDX4  = 12,
                  CAR_IDX_REG0  = 13,
                  CAR_IDX_REG1  = 14,
                  CAR_IDX_REG2  = 15,
                  CAR_IDX_IDX0  = 16,
                  CAR_IDX_IDX1  = 17,
                  CAR_IDX_IDX2  = 18,
                  CAR_IDX_IDX3  = 19,
                  CAR_IDX_IDX4  = 20,
                  CAR_IDX_IDX5  = 21,
                  CAR_1OP_REG   = 22,
                  CAR_1OP_IND0  = 23,
                  CAR_1OP_IND1  = 24,
                  CAR_1OP_IND2  = 25,
                  CAR_1OP_IDX0  = 26,
                  CAR_1OP_IDX1  = 27,
                  CAR_1OP_IDX2  = 28,
                  CAR_1OP_IDX3  = 29,
                  CAR_PUSH_REG0 = 30,
                  CAR_PUSH_REG1 = 31,
                  CAR_PUSH_REG2 = 32,
                  CAR_PUSH_IND0 = 33,
                  CAR_PUSH_IND1 = 34,
                  CAR_PUSH_IND2 = 35,
                  CAR_PUSH_IDX0 = 36,
                  CAR_PUSH_IDX1 = 37,
                  CAR_PUSH_IDX2 = 38,
                  CAR_PUSH_IDX3 = 39,
                  CAR_CALL_REG0 = 40,
                  CAR_CALL_REG1 = 41,
                  CAR_CALL_REG2 = 42,
                  CAR_CALL_IND0 = 43,
                  CAR_CALL_IND1 = 44,
                  CAR_CALL_IND2 = 45,
                  CAR_CALL_IDX0 = 46,
                  CAR_CALL_IDX1 = 47,
                  CAR_CALL_IDX2 = 48,
                  CAR_CALL_IDX3 = 49,
                  CAR_RETI0     = 50,
                  CAR_RETI1     = 51,
                  CAR_RETI2     = 52,
                  CAR_RETI3     = 53,
                  CAR_INT0      = 54,
                  CAR_INT1      = 55,
                  CAR_INT2      = 56,
                  CAR_INT3      = 57,
                  CAR_INT4      = 58,
                  CAR_JMP0      = 59,
                  CAR_BLANK     = 60;


    // Defines for Instruction Types
        localparam [15:0] 
            RRC     = 16'h1000, 
            RRCB    = 16'h1040,
            SWPB    = 16'h1080,
            RRA     = 16'h1100,
            RRAB    = 16'h1140,
            SXT     = 16'h1180,
            PUSH    = 16'h1200,
            PUSHB   = 16'h1240,
            CALL    = 16'h1280,
            RETI    = 16'h1300,
        
            JNE     = 16'h2000,
            JNZ     = 16'h2000,
            JEQ     = 16'h2400,
            JZ      = 16'h2400,
            JNC     = 16'h2800,
            JC      = 16'h2C00,
            JN      = 16'h3000,
            JGE     = 16'h3400,
            JL      = 16'h3800,
            JMP     = 16'h3C00,
        
            MOV     = 16'h4000,
            MOVB    = 16'h4040,
            ADD     = 16'h5000,
            ADDB    = 16'h5040,
            ADDC    = 16'h6000,
            ADDCB   = 16'h6040,
            SUBC    = 16'h7000,
            SUBCB   = 16'h7040,
            SUB     = 16'h8000,
            SUBB    = 16'h8040,
            CMP     = 16'h9000,
            CMPB    = 16'h9040,
            DADD    = 16'hA000,
            DADDB   = 16'hA040,
            BIT     = 16'hB000,
            BITB    = 16'hB040,
            BIC     = 16'hC000,
            BICB    = 16'hC040,
            BIS     = 16'hD000,
            BISB    = 16'hD040,
            XOR     = 16'hE000,
            XORB    = 16'hE040,
            AND     = 16'hF000,
            ANDB    = 16'hF040;

    // Defines for Register Names
        localparam [3:0]
            PC  = 4'd0,
            SP  = 4'd1,
            SR  = 4'd2,
            CG1 = 4'd2,
            CG2 = 4'd3,
            R0  = 4'd0,
            R1  = 4'd1,
            R2  = 4'd2,
            R3  = 4'd3,
            R4  = 4'd4,
            R5  = 4'd5,
            R6  = 4'd6,
            R7  = 4'd7,
            R8  = 4'd8,
            R9  = 4'd9,
            R10 = 4'd10,
            R11 = 4'd11,
            R12 = 4'd12,
            R13 = 4'd13,
            R14 = 4'd14,
            R15 = 4'd15;
    
    // Defines for SR bits
    localparam 
        BITC  = 0,
        BITZ  = 1,
        BITN  = 2,
        BITGIE= 3,
        BITV  = 8;

    // Defines for Address Modes
    localparam
        REGISTER_MODE = 2'b0,
        INDEXED_MODE  = 2'b1,
        SYMBOLIC_MODE = 2'b1,
        ABSOLUTE_MODE = 2'b1,
        INDIRECT_MODE = 2'b10,
        INDIRECT_AUTOINCREMENT_MODE = 2'b11,
        IMMEDIATE_MODE = 2'b11;

    // Defines for Memory Map
    localparam 
        BSL_START   = 16'h1000,
        BSL_LEN     = 16'h0100,
        RAM_START   = 16'h1C00,
        RAM_LEN     = 16'h0800,
        FRAM_START  = 16'h4400,
        FRAM_LEN    = 16'hBB80,
        IVT_START   = 16'hFF80,
        IVT_LEN     = 16'h0080;

    // Defines for Simulated Memory Map
    // localparam 
    //     BSL_START   = 16'h1000,
    //     RAM_START   = 16'h1C00,
    //     RAM_LEN     = 16'h0800,
    //     FRAM_START  = 16'h4400,
    //     FRAM_LEN    = 16'h0100, 
    //     IVT_START   = 16'hFF80,
    //     IVT_LEN     = 16'h0080;

    // Defines for peripheral map
    localparam 
        MAP_SFRs        = 16'h0100,
        MAP_PMM         = 16'h0120,
        MAP_FRAM_CTL    = 16'h0140,
        MAP_CRC16       = 16'h0150,
        MAP_RAM_CTL     = 16'h0158,
        MAP_WDT         = 16'h015C,
        MAP_CS          = 16'h0160,
        MAP_SYS         = 16'h0180,
        MAP_SHARED_REF  = 16'h01B0,
        MAP_PORTA       = 16'h0200,
        MAP_PORTB       = 16'h0220,
        MAP_PORTC       = 16'h0240,
        MAP_PORTD       = 16'h0260,
        MAP_PORTE       = 16'h0280,
        MAP_PORTJ       = 16'h0320,
        MAP_TIMER_TA0   = 16'h0340,
        MAP_TIMER_TA1   = 16'h0380,
        MAP_TIMER_TB0   = 16'h03C0,
        MAP_TIMER_TA2   = 16'h0400,
        MAP_CAP_TCH_0   = 16'h0430,
        MAP_TIMER_TA3   = 16'h0440,
        MAP_CAP_TCH_1   = 16'h0470,
        MAP_RTC_C       = 16'h04A0,
        MAP_MPY         = 16'h04C0,
        MAP_DMA_CTL     = 16'h0500,
        MAP_DMA_CH0     = 16'h0510,
        MAP_DMA_CH1     = 16'h0520,
        MAP_DMA_CH2     = 16'h0530,
        MAP_MPU         = 16'h05A0,
        MAP_eUSCI_A0    = 16'h05C0,
        MAP_eUSCI_A1    = 16'h05E0,
        MAP_eUSCI_B0    = 16'h0640,
        MAP_eUSCI_B1    = 16'h0680,
        MAP_ADC12_B     = 16'h0800,
        MAP_CMP_E       = 16'h08C0,
        MAP_CRC32       = 16'h0980,
        MAP_AES         = 16'h09C0,
        MAP_LCD_C       = 16'h0A00,
        MAP_ESI         = 16'h0D00,
        MAP_ESI_RAM     = 16'h0E00;

    localparam [5:0]
        IVT_RESET       = 63,
        IVT_SNMI        = 62,
        IVT_UNMI        = 61,
        IVT_ComparatorE = 60, 
        IVT_Timer0B0    = 59,
        IVT_Timer0B1    = 58,
        IVT_WDT         = 57,
        IVT_ESI         = 56,
        IVT_eUSCI_A0    = 55,
        IVT_eUSCI_B0    = 54,
        IVT_ADC12_B     = 53,
        IVT_Timer0A0    = 52,
        IVT_Timer0A1    = 51,
        IVT_eUSCI_A1    = 50,
        IVT_eUSCI_B1    = 49,
        IVT_DMA         = 48,
        IVT_Timer1A0    = 47,
        IVT_Timer1A1    = 46,
        IVT_PORT1       = 45,
        IVT_Timer2A0    = 44,
        IVT_Timer2A1    = 43,
        IVT_PORT2       = 42,
        IVT_Timer3A0    = 41,
        IVT_Timer3A1    = 40,
        IVT_PORT3       = 39,
        IVT_PORT4       = 38,
        IVT_LCD_C       = 37,
        IVT_RTC_C       = 36,
        IVT_AES         = 35,
        IVT_NONE        =  0;

    // defines for PORTA
    localparam
        PAIN            = MAP_PORTA + 0,
        PAIN_L          = PAIN,
        PAIN_H          = PAIN + 1,
        PAOUT           = MAP_PORTA + 2,
        PAOUT_L         = PAOUT,
        PAOUT_H         = PAOUT + 1,
        PADIR           = MAP_PORTA + 4,
        PADIR_L         = PADIR,
        PADIR_H         = PADIR + 1,
        PAREN           = MAP_PORTA + 6,
        PAREN_L         = PAREN,
        PAREN_H         = PAREN + 1,
        PASEL0          = MAP_PORTA + 10,
        PASEL0_L        = PASEL0,
        PASEL0_H        = PASEL0 + 1,
        PASEL1          = MAP_PORTA + 12,
        PASEL1_L        = PASEL1,
        PASEL1_H        = PASEL1 + 1,
        PASELC          = MAP_PORTA + 22,
        PASELC_L        = PASELC,
        PASELC_H        = PASELC + 1,
        PAIES           = MAP_PORTA + 24,
        PAIES_L         = PAIES,
        PAIES_H         = PAIES + 1,
        PAIE            = MAP_PORTA + 26,
        PAIE_L          = PAIE,
        PAIE_H          = PAIE + 1,
        PAIFG           = MAP_PORTA + 28,
        PAIFG_L         = PAIFG,
        PAIFG_H         = PAIFG + 1;
        
    localparam
        P1IN            = PAIN_L,
        P2IN            = PAIN_H,
        P1OUT           = PAOUT_L,
        P2OUT           = PAOUT_H,
        P1DIR           = PADIR_L,
        P2DIR           = PADIR_H,
        P1REN           = PAREN_L,
        P2REN           = PAREN_H,
        P1SEL0          = PASEL0_L,
        P2SEL0          = PASEL0_H,
        P1SEL1          = PASEL1_L,
        P2SEL1          = PASEL1_H,
        P1SELC          = PASELC_L,
        P2SELC          = PASELC_H,
        P1IES           = PAIES_L,
        P2IES           = PAIES_H,
        P1IE            = PAIE_L,
        P2IE            = PAIE_H,
        P1IFG           = PAIFG_L,
        P2IFG           = PAIFG_H,
        P1IV            = MAP_PORTA+14,
        P2IV            = MAP_PORTA+30;

    // defines for TIMER A Module
    localparam 
        TAnCTL          = 8'h00,
        TAnCCTL0        = 8'h02,
        TAnCCTL1        = 8'h04,
        TAnCCTL2        = 8'h06,
        TAnCCTL3        = 8'h08,
        TAnCCTL4        = 8'h0A,
        TAnCCTL5        = 8'h0C,
        TAnCCTL6        = 8'h0E,
        TAnR            = 8'h10,
        TAnCCR0         = 8'h12,
        TAnCCR1         = 8'h14,
        TAnCCR2         = 8'h16,
        TAnCCR3         = 8'h18,
        TAnCCR4         = 8'h1A,
        TAnCCR5         = 8'h1C,
        TAnCCR6         = 8'h1E,
        TAnEX0          = 8'h20,
        TAnIV           = 8'h2E;

    localparam
        TASSEL1         = 9,
        TASSEL0         = 8,
        ID1             = 7,
        ID0             = 6,
        MC1             = 5,
        MC0             = 4,
        TACLR           = 2,
        TAIE            = 1,
        TAIFG           = 0;
    
    localparam 
        MC__STOP        = 0,
        MC__UP          = 1,
        MC__CONTINUOUS  = 2,
        MC__UPDOWN      = 3,
        ID__1           = 0,
        ID__2           = 1,
        ID__4           = 2,
        ID__8           = 3,
        TASSEL__TACLK   = 0,
        TASSEL__ACLK    = 1,
        TASSEL__SMCLK   = 2,
        TASSEL__INCLK   = 3;


    localparam
        CM1             = 15,
        CM0             = 14,
        CCIS1           = 13,
        CCIS0           = 12,
        SCS             = 11,
        SCCI            = 10,
        CAP             = 8,
        OUTMOD2         = 7,
        OUTMOD1         = 6,
        OUTMOD0         = 5,
        CCIE            = 4,
        CCI             = 3,
        OUT             = 2,
        COV             = 1,
        CCIFG           = 0;
    
    localparam
        CM__NONE        = 0,
        CM__RISING      = 1,
        CM__FALLING     = 2,
        CM__BOTH        = 3,
        CCIS__A         = 0,
        CCIS__B         = 1,
        CCIS__GND       = 2,
        CCIS__VCC       = 3,
        OUTMOD__OUT     = 0,
        OUTMOD__SET     = 1,
        OUTMOD__TOG_RST = 2,
        OUTMOD__SET_RST = 3,
        OUTMOD__TOG     = 4,
        OUTMOD__RST     = 5,
        OUTMOD__TOG_SET = 6,
        OUTMOD__RST_SET = 7;

    localparam
        TAnIV_NONE      = 0,
        TAnIV_CCIFG1    = 2,
        TAnIV_CCIFG2    = 4,
        TAnIV_CCIFG3    = 6,
        TAnIV_CCIFG4    = 8,
        TAnIV_CCIFG5    = 10,
        TAnIV_CCIFG6    = 12,
        TAnIV_TAIFG     = 14;

    localparam
        TAIDEX2         = 2,
        TAIDEX1         = 1,
        TAIDEX0         = 0;



    // defines for TIMER A0
    localparam
        TA0_CCM_COUNT   = 3,
        TA0CTL          = MAP_TIMER_TA0,
        TA0CCTL0        = MAP_TIMER_TA0 + 8'h02,
        TA0CCTL1        = MAP_TIMER_TA0 + 8'h04,
        TA0CCTL2        = MAP_TIMER_TA0 + 8'h06,
        TA0R            = MAP_TIMER_TA0 + 8'h10,
        TA0CCR0         = MAP_TIMER_TA0 + 8'h12,
        TA0CCR1         = MAP_TIMER_TA0 + 8'h14,
        TA0CCR2         = MAP_TIMER_TA0 + 8'h16,
        TA0IV           = MAP_TIMER_TA0 + 8'h2E,
        TA0EX0          = MAP_TIMER_TA0 + 8'h20;

    // defines for TIMER A1
    localparam
        TA1_CCM_COUNT   = 3,
        TA1CTL          = MAP_TIMER_TA1,
        TA1CCTL0        = MAP_TIMER_TA1 + 8'h02,
        TA1CCTL1        = MAP_TIMER_TA1 + 8'h04,
        TA1CCTL2        = MAP_TIMER_TA1 + 8'h06,
        TA1R            = MAP_TIMER_TA1 + 8'h10,
        TA1CCR0         = MAP_TIMER_TA1 + 8'h12,
        TA1CCR1         = MAP_TIMER_TA1 + 8'h14,
        TA1CCR2         = MAP_TIMER_TA1 + 8'h16,
        TA1IV           = MAP_TIMER_TA1 + 8'h2E,
        TA1EX0          = MAP_TIMER_TA1 + 8'h20;

    // defines for TIMER A2
    localparam
        TA2_CCM_COUNT   = 3,
        TA2CTL          = MAP_TIMER_TA2,
        TA2CCTL0        = MAP_TIMER_TA2 + 8'h02,
        TA2CCTL1        = MAP_TIMER_TA2 + 8'h04,
        TA2CCTL2        = MAP_TIMER_TA2 + 8'h06,
        TA2R            = MAP_TIMER_TA2 + 8'h10,
        TA2CCR0         = MAP_TIMER_TA2 + 8'h12,
        TA2CCR1         = MAP_TIMER_TA2 + 8'h14,
        TA2CCR2         = MAP_TIMER_TA2 + 8'h16,
        TA2IV           = MAP_TIMER_TA2 + 8'h2E,
        TA2EX0          = MAP_TIMER_TA2 + 8'h20;

    // defines for TIMER A3
    localparam
        TA3_CCM_COUNT   = 5,
        TA3CTL          = MAP_TIMER_TA3,
        TA3CCTL0        = MAP_TIMER_TA3 + 8'h02,
        TA3CCTL1        = MAP_TIMER_TA3 + 8'h04,
        TA3CCTL2        = MAP_TIMER_TA3 + 8'h06,
        TA3CCTL3        = MAP_TIMER_TA3 + 8'h08,
        TA3CCTL4        = MAP_TIMER_TA3 + 8'h0A,
        TA3R            = MAP_TIMER_TA3 + 8'h10,
        TA3CCR0         = MAP_TIMER_TA3 + 8'h12,
        TA3CCR1         = MAP_TIMER_TA3 + 8'h14,
        TA3CCR2         = MAP_TIMER_TA3 + 8'h16,
        TA3CCR3         = MAP_TIMER_TA3 + 8'h18,
        TA3CCR4         = MAP_TIMER_TA3 + 8'h1A,
        TA3IV           = MAP_TIMER_TA3 + 8'h2E,
        TA3EX0          = MAP_TIMER_TA3 + 8'h20;

    //-------------------------------------------------------------------------
    // Register defines for eUSCI_A
    localparam                   // reset | Protected
        UCAnCTLW0       = 8'h00, // 0001  | 15-6
        UCAnCTL0        = 8'h01,
        UCAnCTL1        = 8'h00,
        // UCAnCTLW1       = 8'h02, // 0003  |
        UCAnBRW         = 8'h06, //       | 15-0  
        UCAnBR0         = 8'h06,
        UCAnBR1         = 8'h07,
        UCAnMCTLW       = 8'h08, //       | 15-0
        UCAnSTATW       = 8'h0A, //       | 7
        UCAnRXBUF       = 8'h0C, // 
        UCAnTXBUF       = 8'h0E, // 
        // UCAnABCTL       = 8'h10, //       | 5-4, 0
        // UCAnIRCTL       = 8'h12, //       | 15-0
        // UCAnIRTCTL      = 8'h12,
        // UCAnIRRCTL      = 8'h13,
        UCAnIE          = 8'h1A, 
        UCAnIFG         = 8'h1C, // 0002
        UCAnIV          = 8'h1E;

    localparam
        UCAnCTLW0_L     = UCAnCTLW0,
        UCAnCTLW0_H     = UCAnCTLW0+1,
        UCAnBRW_L       = UCAnBRW,
        UCAnBRW_H       = UCAnBRW+1,
        UCAnMCTLW_L     = UCAnMCTLW,
        UCAnMCTLW_H     = UCAnMCTLW+1,
        UCAnSTATW_L     = UCAnSTATW,
        UCAnSTATW_H     = UCAnSTATW+1,
        UCAnRXBUF_L     = UCAnRXBUF,
        UCAnRXBUF_H     = UCAnRXBUF+1,
        UCAnTXBUF_L     = UCAnTXBUF,
        UCAnTXBUF_H     = UCAnTXBUF+1,
        UCAnIE_L        = UCAnIE,
        UCAnIE_H        = UCAnIE+1,
        UCAnIFG_L       = UCAnIFG,
        UCAnIFG_H       = UCAnIFG+1,
        UCAnIV_L        = UCAnIV,
        UCAnIV_H        = UCAnIV+1;
        

    // bit defines for UCAnCTLW0
    localparam                // Protected ?
        UCPEN           = 15, // Y | Parity Enable 
        UCPAR           = 14, // Y | Parity     0:odd   / 1:even
        UCMSB           = 13, // Y | MSB first  0:LSB   / 1: MSB
        UC7BIT          = 12, // Y | Data len   0:8-bit / 1:7-bit
        UCSPB           = 11, // Y | Stop len   0:one   / 1:two
        UCMODEx1        = 10, // Y | RESERVED
        UCMODEx0        = 9,  // Y | RESERVED
        UCSYNC          = 8,  // Y | RESERVED
        UCSSELx1        = 7,  // Y | Clock Source Select 1
        UCSSELx0        = 6,  // Y | Clock Source Select 2
        UCRXEIE         = 5,  //   | Rx Error Interrupt Enable
        UCBRKIE         = 4,  //   | RESERVED
        UCDORM          = 3,  //   | RESERVED
        UCTXADDR        = 2,  //   | RESERVED
        UCTXBRK         = 1,  //   | RESERVED
        UCSWRST         = 0;  //   | Software Reset. Default 1

    localparam [1:0]
        UCSSEL_0        = 0,
        UCSSEL_1        = 1,
        UCSSEL_2        = 2,
        UCSSEL_3        = 3,
        UCSSEL__UCLK    = 0,
        UCSSEL__ACLK    = 1,
        UCSSEL__SMCLK   = 2;

    // bit defines for UCAnCTLW1
    localparam          // 15-2 : r-0
        UCGLITx1        = 1, // RESERVED
        UCGLITx0        = 0; // RESERVED
    
    // bit defines for UCAnMCTLW
    localparam
        UCBRSx7         = 15,
        UCBRSx6         = 14,
        UCBRSx5         = 13,
        UCBRSx4         = 12,
        UCBRSx3         = 11,
        UCBRSx2         = 10,
        UCBRSx1         = 9,
        UCBRSx0         = 8,
        UCBRFx3         = 7,
        UCBRFx2         = 6,
        UCBRFx1         = 5,
        UCBRFx0         = 4,
                        // 3-1 : r-0
        UCOS16          = 0;

    // bit defines for UCAnSTATW
    localparam
                        // 15-8 : r0
        UCLISTEN        = 7, // protected
        UCFE            = 6,
        UCOE            = 5,
        UCPE            = 4,
        UCBRK           = 3, // RESERVED
        UCRXERR         = 2,
        UCADDR          = 1, // RESERVED
        UCIDLE          = 1, // RESERVED
        UCBUSY          = 0; // r-0

    // bit defines for UCAnRXBUF
    localparam
                        // 15-8 : r-0
        UCRXBUF7        = 7, // r-0
        UCRXBUF6        = 6, // r-0
        UCRXBUF5        = 5, // r-0
        UCRXBUF4        = 4, // r-0
        UCRXBUF3        = 3, // r-0
        UCRXBUF2        = 2, // r-0
        UCRXBUF1        = 1, // r-0
        UCRXBUF0        = 0; // r-0
    
    // bit defines for UCAnTXBUF
    localparam
                        // 15-8 : r-0
        UCTXBUF7        = 7,
        UCTXBUF6        = 6, 
        UCTXBUF5        = 5,
        UCTXBUF4        = 4,
        UCTXBUF3        = 3,
        UCTXBUF2        = 2,
        UCTXBUF1        = 1,
        UCTXBUF0        = 0;

    // bit defines for UCAnABCTL
    localparam
                        // 15-6 : r-0
        UCDELIM1        = 5, // protected
        UCDELIM0        = 4, // protected
        UCSTOE          = 3,
        UCBTOE          = 2,
                        // 1 : r-0
        UCABDEN         = 0; // protected
    
    // bit defines for UCAIRCTL
    localparam
        UCIRRXFL5       = 15, // ALL bits protected
        UCIRRXFL4       = 14,
        UCIRRXFL3       = 13,
        UCIRRXFL2       = 12,
        UCIRRXFL1       = 11,
        UCIRRXFL0       = 10,
        UCIRRXPL        = 9,
        UCIRRXFE        = 8,
        UCIRTXPL5       = 7,
        UCIRTXPL4       = 6,
        UCIRTXPL3       = 5,
        UCIRTXPL2       = 4,
        UCIRTXPL1       = 3,
        UCIRTXPL0       = 2,
        UCIRTXCLK       = 1,
        UCIREN          = 0;

    // bit defines for UCAnIE
    localparam
                        // 15-4 : r-0
        UCTXCPTIE       = 3,
        UCSTTIE         = 2,
        UCTXIE          = 1,
        UCRXIE          = 0;
    
    // bit defines for UCAnIFG
    localparam
                        // 15-4 : r-0
        UCTXCPTIFG      = 3,
        UCSTTIFG        = 2,
        UCTXIFG         = 1, // rw-1
        UCRXIFG         = 0;
    
    // bit defines for UCAnIV
    localparam
                        // 15-4 : r0
        UCIV3           = 3, // r-(0)
        UCIV2           = 2, // r-(0)
        UCIV1           = 1; // r-(0)
                        // 0 : r0

    // MMR defines for eUSCI A0
    localparam
        UCA0CTLW0 = MAP_eUSCI_A0 + UCAnCTLW0,
        UCA0BRW   = MAP_eUSCI_A0 + UCAnBRW,
        UCA0MCTLW = MAP_eUSCI_A0 + UCAnMCTLW,
        UCA0STATW = MAP_eUSCI_A0 + UCAnSTATW,
        UCA0RXBUF = MAP_eUSCI_A0 + UCAnRXBUF,
        UCA0TXBUF = MAP_eUSCI_A0 + UCAnTXBUF,
        UCA0IE    = MAP_eUSCI_A0 + UCAnIE,
        UCA0IFG   = MAP_eUSCI_A0 + UCAnIFG,
        UCA0IV    = MAP_eUSCI_A0 + UCAnIV;

    //-------------------------------------------------------------------------
    // pin mappings
    localparam
        GPIO1_0 = 0,  // maps to dip 1
        GPIO1_1 = 1,
        GPIO1_2 = 2,
        GPIO1_3 = 3,
        GPIO1_4 = 4,
        GPIO1_5 = 5,
        GPIO1_6 = 6,
        GPIO1_7 = 7,
        GPIO2_0 = 8,
        GPIO2_1 = 9,
        GPIO2_2 = 10,
        GPIO2_3 = 11,
        GPIO2_4 = 12,
        GPIO2_5 = 13,
        GPIO2_6 = 14, // maps to dip 17
        GPIO2_7 = 15, 
        GPIO3_0 = 43, // maps to dip 48
        GPIO3_1 = 42,
        GPIO3_2 = 41,
        GPIO3_3 = 40,
        GPIO3_4 = 39,
        GPIO3_5 = 38,
        GPIO3_6 = 37,
        GPIO3_7 = 36,
        GPIO4_0 = 35,
        GPIO4_1 = 34,
        GPIO4_2 = 33,
        GPIO4_3 = 32,
        GPIO4_4 = 31,
        GPIO4_5 = 30,
        GPIO4_6 = 29,
        GPIO4_7 = 28,  // maps to dip 33
        GPIO_RST = 20; // maps to dip 23

// `endif 