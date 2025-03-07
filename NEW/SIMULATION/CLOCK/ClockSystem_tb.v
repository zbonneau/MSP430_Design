/*--------------------------------------------------------
    Module Name : ClockSystem Testbench
    Description:
        Verifies Functionality of the ClockSystem

--------------------------------------------------------*/

`default_nettype none
`timescale 1ns/1ps

module tb_ClockSystem;
reg sysOsc, reset;
wire MCLK, ACLK;
wire SMCLK;

`include "NEW/PARAMS.v"
`include "NEW/FPGA.v"

reg [63:0] MCLKtick, ACLKtick, OSCtick;
real OSCf, ACLKf, MCLKf;
real OSCerr, ACLKerr, MCLKerr;

initial begin 
    {sysOsc, reset} = 0; 
    {MCLKtick, ACLKtick, OSCtick} = ~0;
    ACLKf = 0; MCLKf = 0; OSCerr = 0; ACLKerr = 0; MCLKerr = 0;
end

ClockSystem uut
(
    .sysOsc(sysOsc), .reset(reset), 
    .MCLK(MCLK), .ACLK(ACLK), .SMCLK(SMCLK)
);

localparam CLK_PERIOD = 83.3333;
always #(CLK_PERIOD/2) sysOsc = ~sysOsc;

always @(posedge sysOsc) OSCtick <= OSCtick+1;
always @(posedge MCLK) MCLKtick <= MCLKtick+1;
always @(posedge ACLK) ACLKtick <= ACLKtick+1;

initial begin // DO NOT GENERATE WAVEFORM. VERY BIG VERY BAD
    // $dumpfile("ClockSystem.vcd");
    // $dumpvars(0, tb_ClockSystem);
end

initial begin
    `PULSE(reset)
    #(1_000_000_000);
    @(posedge ACLK);

    OSCf  = OSCtick / ((1.0 * $realtime) / 1_000_000_000.0);
    MCLKf = OSCf * MCLKtick / OSCtick;
    ACLKf = OSCf * ACLKtick / OSCtick;

    OSCerr = (OSCf - FPGA_FREQ) / FPGA_FREQ * 100.0;
    MCLKerr = (MCLKf - MCLK_FREQ) / MCLK_FREQ * 100.0;
    ACLKerr = (ACLKf - ACLK_FREQ) / ACLK_FREQ * 100.0;

    $display("Time:    %.2f nS", $realtime);
    $display("OSCtick:   %8d", OSCtick);
    $display("MCLKtick:  %8d", MCLKtick);
    $display("ACLKtick:  %8d", ACLKtick);

    $display("\nAbsolute Reference ----------");
    $display("OSC Freq: %.2f Hz", OSCf);
    $display("MCLK Freq:  %.2f Hz", MCLKf);
    $display("ACLK Freq:   %.2f Hz", ACLKf);
    $display("OSCerr:     %f", OSCerr);

    MCLKf = FPGA_FREQ * 1.0 * MCLKtick / OSCtick;
    ACLKf = FPGA_FREQ * 1.0 * ACLKtick / OSCtick;
    MCLKerr = (MCLKf - MCLK_FREQ) / MCLK_FREQ * 100.0;
    ACLKerr = (ACLKf - ACLK_FREQ) / ACLK_FREQ * 100.0;

    $display("\nRelative Reference  (OSCtick)");
    $display("MCLK Freq: %.2f Hz", MCLKf);
    $display("ACLK Freq:  %.2f Hz", ACLKf);
    $display("MCLKerr:   %f", MCLKerr);
    $display("ACLKerr:    %f", ACLKerr);
    
    $finish(0);
end
endmodule
`default_nettype wire
