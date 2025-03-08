/*--------------------------------------------------------
    Module Name : PIN Testbench
    Description:
        Verifies Functionality of the PIN

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_PIN;

reg Px_m_driver;
wire Px_m;

assign Px_m = (uut.DIR_sel) ? 1'bz : Px_m_driver;

reg PxOUTm, PxDIRm, PxRENm;
reg [1:0] PxSELm;
reg OUT_1, DIR_1;    
reg OUT_2, DIR_2;
reg OUT_3, DIR_3;

wire PxINm;
wire IN_1, IN_2, IN_3;

`include "NEW/PARAMS.v"

initial begin 
    {Px_m_driver, PxOUTm, PxDIRm, PxRENm, PxSELm} = 0;
    {OUT_1, DIR_1, OUT_2, DIR_2, OUT_3, DIR_3} = 0; 
end

PIN uut
(
    .Px_m(Px_m), 
    .PxOUTm(PxOUTm), .PxDIRm(PxDIRm), .PxRENm(PxRENm), 
    .PxSELm(PxSELm), 
    .OUT_1(OUT_1), .DIR_1(DIR_1), 
    .OUT_2(OUT_2), .DIR_2(DIR_2), 
    .OUT_3(OUT_3), .DIR_3(DIR_3), 
    .PxINm(PxINm), 
    .IN_1(IN_1), .IN_2(IN_2), .IN_3(IN_3)
);


initial begin
    $dumpfile("PIN.vcd");
    $dumpvars(0, tb_PIN);
end

initial begin
    // Test mode 0 - input - no resistor
    Px_m_driver = 0; #10; Px_m_driver = 1; #10; Px_m_driver = 1'bz; #10;

    // Test mode 0 - input - pullup
    PxRENm = 1; PxOUTm = 1;
    Px_m_driver = 0; #10; Px_m_driver = 1; #10; Px_m_driver = 1'bz; #10;

    // Test mode 0 - input - pulldown
    PxOUTm = 0;
    Px_m_driver = 0; #10; Px_m_driver = 1; #10; Px_m_driver = 1'bz; #10;
    Px_m_driver = 0;

    // Test mode 0 - output
    PxDIRm = 1; 
    PxOUTm = 0; #10; PxOUTm = 1; #10; 
    
    PxRENm = 1;
    #10; PxOUTm = 0; #10;

    PxRENm = 0; PxDIRm = 0; 

    // Test mode 1 - constants from module
    PxSELm = 2'b01; DIR_1 = 0; 
    OUT_1 = 0; #10; OUT_1 = 1; #10; OUT_1 = 0;
    Px_m_driver = 0; #10; Px_m_driver = 1; #10; Px_m_driver = 1'bz; #10;
    Px_m_driver = 0;

    // Test mode 2 - constants from module
    PxSELm = 2'b10; DIR_2 = 1;
    OUT_2 = 0; #10; OUT_2 = 1; #10; OUT_2 = 0; 

    // Test mode 3 - constants from module
    PxSELm = 2'b11; DIR_3 = 1;
    OUT_3 = 0; #10; OUT_3 = 1; #10; OUT_3 = 0; 

    $finish(0);
end
endmodule
`default_nettype wire
