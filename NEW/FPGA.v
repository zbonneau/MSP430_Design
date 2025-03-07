localparam  FPGA_FREQ   = 12_000_000,
            MCLK_FREQ   =  1_000_000,
            SMCLK_FREQ  =  1_000_000,
            ACLK_FREQ   =     32_768;

localparam  ACLK_DOWNCOUNT = FPGA_FREQ/ACLK_FREQ/2,
            MCLK_DOWNCOUNT = FPGA_FREQ/MCLK_FREQ/2;
