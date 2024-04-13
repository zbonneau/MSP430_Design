parameter PC  = 4'd0,
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

parameter BITC  = 0,
          BITZ  = 1,
          BITN  = 2,
          GIE   = 3,
          BITV  = 8;


parameter REGISTER_MODE = 2'b0,
          INDEXED_MODE  = 2'b1,
          SYMBOLIC_MODE = 2'b1,
          ABSOLUTE_MODE = 2'b1,
          INDIRECT_MODE = 2'b10,
          INDIRECT_AUTOINCREMENT_MODE = 2'b11,
          IMMEDIATE_MODE = 2'b11;

