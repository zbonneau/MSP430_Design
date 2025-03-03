/* 
 * Synthesis Choices for the MSP430
 */

    // Defines for BOR POR PUC 
`define BOR_DELAY     (3)
`define BOR_DELAYBITS (2)

    // Defines for Interrupt Module synthesis. If defined, it is synthesized
`define IVT_RESET_USED      
// `define IVT_SNMI_USED       
// `define IVT_UNMI_USED       
// `define IVT_ComparatorE_USED
// `define IVT_Timer0B0_USED   
// `define IVT_Timer0B1_USED   
// `define IVT_WDT_USED        
// `define IVT_ESI_USED        
// `define IVT_eUSCI_A0_USED   
// `define IVT_eUSCI_B0_USED   
// `define IVT_ADC12_B_USED    
`define IVT_Timer0A0_USED   
`define IVT_Timer0A1_USED   
// `define IVT_eUSCI_A1_USED   
// `define IVT_eUSCI_B1_USED   
// `define IVT_DMA_USED        
// `define IVT_Timer1A0_USED   
// `define IVT_Timer1A1_USED   
`define IVT_PORT1_USED      
// `define IVT_Timer2A0_USED   
// `define IVT_Timer2A1_USED   
`define IVT_PORT2_USED      
// `define IVT_Timer3A0_USED   
// `define IVT_Timer3A1_USED   
// `define IVT_PORT3_USED      
// `define IVT_PORT4_USED      
// `define IVT_LCD_C_USED      
// `define IVT_RTC_C_USED      
// `define IVT_AES_USED        

