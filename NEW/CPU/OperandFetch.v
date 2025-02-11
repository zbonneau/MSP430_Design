/*--------------------------------------------------------
    Module Name : Operand Fetch
    Description: 
        Contains registers, decoders, and adders for operand 
        fetching.
    
    Inputs:
        Rsrc, Rdst, MDB - 16-bit operand words for register source, destination, and memory
        srcM, srcL - src mux and latch control
        dstM, dstL - dst mux and latch control
        IdxM, AddrM, AddrL - address control for index adder mux, address select, and address latch

    Outputs:
        src, dst - source and destination operands
        address  - memory address for operand fetch, result write
        
--------------------------------------------------------*/

module OperandFetch(
    input clk, rst,
    input [15:0] Rsrc, Rdst, MDB, 
    input srcM, srcL, dstM, dstL,
    input [1:0] AddrM,
    input AddrL, IdxM,
    output [15:0] OpSrc, OpDst, MAB
 );

 // Internal Regs for various address modes
    reg [15:0] src, dst, Addr;

 // Initialize
    initial begin {src, dst, Addr} = 0; end

 // Combinational Logic - outputs to MAB, Func Unit
    assign OpSrc = srcM ? src : Rsrc;
    assign OpDst = dstM ? dst : Rdst;
    assign MAB   = (AddrM == 0) ? Addr :
                   (AddrM == 1) ? Rsrc - 2 :
                   (AddrM == 2) ? Rsrc : 
                   (AddrM == 3) ? Rdst : 16'hDEAD;

 // Sequential Logic - src, dst, Addr for various address modes
    always @(posedge clk) begin
        if (rst) begin
            {src, dst, Addr} = 0;
        end
        else begin
            if (srcL) begin
                src <= MDB;
            end
            if (dstL) begin
                dst <= dstM ? MDB : Rdst;
            end
            if (AddrL) begin
                Addr = (AddrM == 0 && IdxM == 0) ? MDB + Rsrc :
                       (AddrM == 0 && IdxM == 1) ? MDB + Rdst :
                       (AddrM == 3) ? Rdst :
                       Addr; // Default to no Change
            end
        end
    end
endmodule