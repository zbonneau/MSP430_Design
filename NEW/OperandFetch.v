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