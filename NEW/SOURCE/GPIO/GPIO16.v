/*--------------------------------------------------------
    Module Name: GPIO16
    Description:
        The GPIO Module implements the 16-bit port. The only
        Logic implemented in this module is the Edge Detetion
        and Interrupt Vector flag clears.

    Inputs:
        MAB - Memory Address Bus
        MDBwrite - Memory Data Bus from CPU to PORT
        MW, BW - Control Signals
        PxIN, PyIN - Pin input buffer values

    Outputs:
        MDBread - Memory Data Bus from PORT to CPU
        PxINT, PyINT - 8-bit port Interrupt requests
        PxOUT, PxDIR, PxREN, PxSEL0, PxSEL1
            -   8-bit Pin Module control and data signals
            -   Duplicate outputs for Py

--------------------------------------------------------*/
`timescale 100ns/100ns

module GPIO16#(
    parameter [16:0] START = MAP_PORTA
    )(
    input MCLK, reset,
    input [15:0] MAB, MDBwrite,
    input MW, BW,
    input [7:0] PxIN, PyIN,

    output [15:0] MDBread,
    output PxINT, PyINT,
    output [7:0] PxOUT, PxDIR, PxREN, PxSEL0, PxSEL1,
    output [7:0] PyOUT, PyDIR, PyREN, PySEL0, PySEL1
 );
    `include "NEW\\PARAMS.v" // global parameter defines

    // Register Address Offsets
    localparam [4:0] 
        RxIN   = 0,
        RyIN   = 1,
        RxOUT  = 2,
        RyOUT  = 3,
        RxDIR  = 4,
        RyDIR  = 5,
        RxREN  = 6,
        RyREN  = 7,
        RxSEL0 = 10,
        RySEL0 = 11,
        RxSEL1 = 12,
        RySEL1 = 13,
        RxIV   = 14,
        RxIV_L = 14,
        RxIV_H = 15,
        RxSELC = 22,
        RySELC = 23,
        RxIES  = 24,
        RyIES  = 25,
        RxIE   = 26,
        RyIE   = 27,
        RxIFG  = 28,
        RyIFG  = 29,
        RyIV   = 30,
        RyIV_L = 30,
        RyIV_H = 31;

    /* Internal signal definitions */
    reg  [7:0] memory [31:0];
    reg  [7:0] PxIVclear, PyIVclear;

    integer i;

    initial begin 
        // From FUG, IN, OUT, IES are undefined at reset. 
        // 0 chosen for consistent simulation/synthesis
        for (i=0; i<32; i=i+1)
            memory[i] <= 0;
        {PxIVclear, PyIVclear} = 0;
    end

    /* Continuous Logic Assignments */
    // Pass on to Pin Modules
    assign PxINT  = |memory[RxIFG];
    assign PxOUT  =  memory[RxOUT];
    assign PxDIR  =  memory[RxDIR];
    assign PxREN  =  memory[RxREN];
    assign PxSEL0 =  memory[RxSEL0];
    assign PxSEL1 =  memory[RxSEL1];

    assign PyINT  = |memory[RyIFG];
    assign PyOUT  =  memory[RyOUT];
    assign PyDIR  =  memory[RyDIR];
    assign PyREN  =  memory[RyREN];
    assign PySEL0 =  memory[RySEL0];
    assign PySEL1 =  memory[RySEL1];

    // return to System Bus
    assign MDBread = (MAB >= START && MAB <= START + 32)
            ? (BW)
                ? {8'h00, memory[MAB-START]} // valid byte read
                : {memory[((MAB-START) & ~1) + 1], memory[((MAB-START) & ~1)]} // valid word read
            : {16{1'bz}}; // invalid read
    
    always @(*) begin
        PxIVclear = 8'h00;
        PyIVclear = 8'h00;

        // if reading PxIV, determine which flag to clear automatically
        if (~MW && ((MAB & ~1) == START + RxIV)) begin 
        case(memory[RxIV_L])
            8'h02:   PxIVclear = 8'h01; 
            8'h04:   PxIVclear = 8'h02; 
            8'h06:   PxIVclear = 8'h04; 
            8'h08:   PxIVclear = 8'h08; 
            8'h0A:   PxIVclear = 8'h10; 
            8'h0C:   PxIVclear = 8'h20; 
            8'h0E:   PxIVclear = 8'h40; 
            8'h10:   PxIVclear = 8'h80; 
            default: PxIVclear = 8'h00;
        endcase
        end
        
        // if reading PyIV, determine which flag to clear automatically
        if (~MW && ((MAB & ~1) == START + RyIV)) begin 
        case(memory[RyIV_L])
            8'h02:   PyIVclear = 8'h01; 
            8'h04:   PyIVclear = 8'h02; 
            8'h06:   PyIVclear = 8'h04; 
            8'h08:   PyIVclear = 8'h08; 
            8'h0A:   PyIVclear = 8'h10; 
            8'h0C:   PyIVclear = 8'h20; 
            8'h0E:   PyIVclear = 8'h40; 
            8'h10:   PyIVclear = 8'h80; 
            default: PyIVclear = 8'h00;
        endcase
        end
    end

    /* Sequential Logic Assignments */
    always @(posedge MCLK) begin
        if (reset) begin
            for (i=0; i<32; i=i+1)
                memory[i] <= 0;
        end else begin
            // handle memory writes
            if (MW &&                                 // if memory write and
                (MAB >= START && MAB < START + 32) && // valid write address and
                (MAB & ~1) != START+RxIV &&           // not PxIV and
                (MAB & ~1) != START+RyIV &&           // not PyIV and
                (MAB & ~1) != START + RxIN            // not PxIN, PyIN
                ) begin 

                // handle SELC writes
                if (BW && MAB == START + RxSELC)
                    {memory[RxSEL0], memory[RxSEL1]} <= ~{memory[RxSEL0], memory[RxSEL1]};
                else if (BW && MAB == START + RySELC)
                    {memory[RySEL0], memory[RySEL1]} <= ~{memory[RySEL0], memory[RySEL1]};
                else if (~BW && (MAB & ~1) == START + RxSELC) begin
                    {memory[RxSEL0], memory[RxSEL1]} <= ~{memory[RxSEL0], memory[RxSEL1]};
                    {memory[RySEL0], memory[RySEL1]} <= ~{memory[RySEL0], memory[RySEL1]};
                end else begin
                    if (BW)
                        memory[MAB - START] <= MDBwrite[7:0];
                    else begin
                        memory[((MAB-START) & ~1)+1] <= MDBwrite[15:8];
                        memory[((MAB-START) & ~1)]<= MDBwrite[7:0];
                    end
                end 
            end
            // handle pin input
            memory[RxIN] <= PxIN;
            memory[RyIN] <= PyIN;

            // handle IV read clears
            memory[RxIFG] <= memory[RxIFG] & ~PxIVclear;
            memory[RyIFG] <= memory[RyIFG] & ~PyIVclear;

            // handle Edge Detection
            for (i=0;i<8;i=i+1) begin
                if (memory[RxIE][i] &                                    // interrupt enabled
                    (~memory[RxIES][i] & ~memory[RxIN][i] &  PxIN[i]) || // rising edge
                    (memory[RxIES][i] &  memory[RxIN][i] & ~PxIN[i]))    // falling edge
                    memory[RxIFG][i] <=1'b1;
                if (memory[RyIE][i] & // interrupt enabled
                    (~memory[RyIES][i] & ~memory[RyIN][i] &  PyIN[i]) || // rising edge
                    (memory[RyIES][i] &  memory[RyIN][i] & ~PyIN[i]))    // falling edge
                    memory[RyIFG][i] <=1'b1;
            end   

            // handle IV writes
            casex(memory[RxIFG]) 
                8'bxxxx_xxx1: memory[RxIV] <= 8'h02;
                8'bxxxx_xx10: memory[RxIV] <= 8'h04;
                8'bxxxx_x100: memory[RxIV] <= 8'h06;
                8'bxxxx_1000: memory[RxIV] <= 8'h08;
                8'bxxx1_0000: memory[RxIV] <= 8'h0A;
                8'bxx10_0000: memory[RxIV] <= 8'h0C;
                8'bx100_0000: memory[RxIV] <= 8'h0E;
                8'b1000_0000: memory[RxIV] <= 8'h10;
                8'b0000_0000: memory[RxIV] <= 8'h00;
            endcase
            casex(memory[RyIFG]) 
                8'bxxxx_xxx1: memory[RyIV] <= 8'h02;
                8'bxxxx_xx10: memory[RyIV] <= 8'h04;
                8'bxxxx_x100: memory[RyIV] <= 8'h06;
                8'bxxxx_1000: memory[RyIV] <= 8'h08;
                8'bxxx1_0000: memory[RyIV] <= 8'h0A;
                8'bxx10_0000: memory[RyIV] <= 8'h0C;
                8'bx100_0000: memory[RyIV] <= 8'h0E;
                8'b1000_0000: memory[RyIV] <= 8'h10;
                8'b0000_0000: memory[RyIV] <= 8'h00;
            endcase
        end
    end

endmodule
