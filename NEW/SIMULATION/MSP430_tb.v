/*--------------------------------------------------------
    Module Name : MSP430 Testbench
    Description:
        Verifies Functionality of the MSP430

--------------------------------------------------------*/

`default_nettype none
`timescale 100ns/100ns

module tb_MSP430;
`include "NEW/PARAMS.v"
reg SysClock, rst_n;
reg [43:0] gpio_driver;
wire [43:0] gpio;

assign gpio[00] = (uut.padir[00]) ? 1'bz : gpio_driver[00];
assign gpio[01] = (uut.padir[01]) ? 1'bz : gpio_driver[01];
assign gpio[02] = (uut.padir[02]) ? 1'bz : gpio_driver[02];
assign gpio[03] = (uut.padir[03]) ? 1'bz : gpio_driver[03];
assign gpio[04] = (uut.padir[04]) ? 1'bz : gpio_driver[04];
assign gpio[05] = (uut.padir[05]) ? 1'bz : gpio_driver[05];
assign gpio[06] = (uut.padir[06]) ? 1'bz : gpio_driver[06];
assign gpio[07] = (uut.padir[07]) ? 1'bz : gpio_driver[07];
assign gpio[08] = (uut.padir[08]) ? 1'bz : gpio_driver[08];
assign gpio[09] = (uut.padir[09]) ? 1'bz : gpio_driver[09];
assign gpio[10] = (uut.padir[10]) ? 1'bz : gpio_driver[10];
assign gpio[11] = (uut.padir[11]) ? 1'bz : gpio_driver[11];
assign gpio[12] = (uut.padir[12]) ? 1'bz : gpio_driver[12];
assign gpio[13] = (uut.padir[13]) ? 1'bz : gpio_driver[13];
assign gpio[14] = (uut.padir[14]) ? 1'bz : gpio_driver[14];
assign gpio[15] = (uut.padir[15]) ? 1'bz : gpio_driver[15];

assign gpio[43] = (uut.padir[00]) ? 1'bz : gpio_driver[43];
assign gpio[42] = (uut.padir[01]) ? 1'bz : gpio_driver[42];
assign gpio[41] = (uut.padir[02]) ? 1'bz : gpio_driver[41];
assign gpio[40] = (uut.padir[03]) ? 1'bz : gpio_driver[40];
assign gpio[39] = (uut.padir[04]) ? 1'bz : gpio_driver[39];
assign gpio[38] = (uut.padir[05]) ? 1'bz : gpio_driver[38];
assign gpio[37] = (uut.padir[06]) ? 1'bz : gpio_driver[37];
assign gpio[36] = (uut.padir[07]) ? 1'bz : gpio_driver[36];
assign gpio[35] = (uut.padir[08]) ? 1'bz : gpio_driver[35];
assign gpio[34] = (uut.padir[09]) ? 1'bz : gpio_driver[34];
assign gpio[33] = (uut.padir[10]) ? 1'bz : gpio_driver[33];
assign gpio[32] = (uut.padir[11]) ? 1'bz : gpio_driver[32];
assign gpio[31] = (uut.padir[12]) ? 1'bz : gpio_driver[31];
assign gpio[30] = (uut.padir[13]) ? 1'bz : gpio_driver[30];
assign gpio[29] = (uut.padir[14]) ? 1'bz : gpio_driver[29];
assign gpio[28] = (uut.padir[15]) ? 1'bz : gpio_driver[28];

assign gpio[GPIO_RST] = rst_n;

initial begin {SysClock, rst_n} = 2'b01; end

MSP430 uut
(
.SysClock(SysClock), .gpio(gpio)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) SysClock = ~SysClock;

initial begin
    $dumpfile("MSP430.vcd");
    $dumpvars(0, tb_MSP430);
end

initial begin
    timer_test;
    $finish(0);
end

`include "NEW/SIMULATION/MSP430_tests/timer_test.v"
endmodule
`default_nettype wire
