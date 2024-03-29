parameter PC  = 0,
          SP  = 1,
          SR  = 2,
          CG1 = 2,
          CG2 = 3,
          R0  = 0,
          R1  = 1,
          R2  = 2,
          R3  = 3,
          R4  = 4,
          R5  = 5,
          R6  = 6,
          R7  = 7,
          R8  = 8,
          R9  = 9,
          R10 = 10,
          R11 = 11,
          R12 = 12,
          R13 = 13,
          R14 = 14,
          R15 = 15;

parameter Carry = 0,
          Zero  = 1,
          Neg   = 2,
          GIE   = 3,
          V     = 8;


parameter REGISTER_MODE = 2'b0,
          INDEXED_MODE  = 2'b1,
          SYMBOLIC_MODE = 2'b1,
          ABSOLUTE_MODE = 2'b1,
          INDIRECT_MODE = 2'b11,
          INDIRECT_AUTOINCREMENT_MODE = 2'b11,
          IMMEDIATE_MODE = 2'b11;