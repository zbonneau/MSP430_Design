/*--------------------------------------------------------
    Module Name: CPU
    Description:
        Combines subcomponents of the MSP430 CPU. This 
        module is the presentation of the CPU to all other 
        peripherals, and the top module.

    Inputs:
        MCLK - Master System Clock
        reset - System Reset Vector
        NMI - non-Maskable Interrupt Vector
        INT - Maskable Interrupt Vectors
        IntAddrLSBs - Interrupt Vector Address 6 LSBs
        MDBin - Memory Data Bus read by CPU

    Outputs:
        MAB - Memory Address Bus
        MDBout - Memory Data Bus writteb by CPU
        MW - Memory Write
        BW - Byte/Word (1/0)
        INTACK - Interrupt Acknowledge

--------------------------------------------------------*/
`timescale 100ns/100ns

module CPU(
    input MCLK, reset,
    input NMI, INT,
    input [5:0] IntAddrLSBs,
    input [15:0] MDBin,
    
    output [15:0] MAB,
    output [15:0] MDBout,
    output MW, BW, INTACK
 );
    `include "NEW\\PARAMS.v" // global parameter defines

    /* Internal signal definitions */
    reg [15:0] InstructionReg;
    reg [CAR_BITS-1:0] CAR;

    /* From Interrupt Unit */
    wire INTREQ;
    wire [15:0] IntAddr;

    /* From CAR decoder, CAR Latch Control */
    wire [CAR_BITS-1:0] CARnew, CARnext;

    /* From Control Unit */
    wire [15:0] IW;
    wire IdxF, IF, Mem, Ex, srcM, srcL, dstM, dstL;
    wire [1:0] AddrM;
    wire AddrL, IdxM;
    wire Format;
    wire [3:0] srcA, dstA;
    wire [1:0] As;
    wire Ad, CtlBW;

    /* From Constant Generator */
    wire [15:0] CGsrc, CGdst;
    wire CGsrcGen, CGdstGen;

    /* From Branch Detector */
    wire Br;

    /* From Operand Fetch */
    wire [15:0] Opsrc, Opdst, OpAddr;

    /* From Function Unit */
    wire [3:0] SRnew;
    wire [15:0] result;

    /* From Register File */
    wire [15:0] RegPC, RegSP, Rsrc, Rdst;
    wire [3:0] SRcurrent;
    wire GIE;

    /* Blank Detect */
    wire Blank;

    initial begin {InstructionReg, CAR} <= 0; end

    /* Continuous Logic Assignments */
    assign INTREQ = NMI | INT & GIE;
    assign IntAddr = {9'b1111_1111_1, IntAddrLSBs, 1'b0};
    assign Br = INTACK | (~Mem & Ex & (dstA == PC));

    assign Blank = (CAR == CAR_PUSH_REG0 || CAR == CAR_CALL_REG0 ||
                    CAR == CAR_CALL_IND2 || CAR == CAR_CALL_IDX3 ||
                    CAR == CAR_INT0 || CAR == CAR_INT2 || 
                    CAR == CAR_RETI1 || CAR == CAR_RETI3 ||
                    CAR == CAR_JMP0);

    /* Sequential Logic Assignments */
    always @(posedge MCLK) begin
        CAR <= CARnext;
        if (reset) begin
            InstructionReg <= 0;
        end
        else if (IF) begin  
            InstructionReg <= MDBin;
        end
    end

    /* Submodule Instantiations */
    CarDecoder decoder(
        .IW(MDBin), .CAR(CARnew)
    );

    CarLatchControl latchControl(
        .rst(reset), .INTREQ(INTREQ), .IF(IF), .Br(Br),
        .CARnew(CARnew), .CARold(CAR), .CARnext(CARnext)
    );

    ConstantGenerator generator(
        .Format(Format), .srcA(srcA), .As(As), .dstA(dstA), .Ad(Ad), 
        .src(CGsrc), .dst(CGdst), 
        .srcGenerated(CGsrcGen), .dstGenerated(CGdstGen)
    );

    ControlUnit controller(
        .CAR(CAR), .IR(InstructionReg), 
        .IW(IW), .srcA(srcA), .As(As), .dstA(dstA), .Ad(Ad), .BW(CtlBW),
        .Format(Format), .INTACK(INTACK),
        .ControlWord({IdxF, IF, Mem, Ex, srcM, srcL, dstM, dstL, AddrM, AddrL, IdxM})
    );

    FunctionUnit ALU(
        .src(Opsrc), .dst(Opdst), .IW(IW),
        .Vin(SRcurrent[3]), .Nin(SRcurrent[2]), 
        .Zin(SRcurrent[1]), .Cin(SRcurrent[0]),
        .result(result),
        .Vout(SRnew[3]), .Nout(SRnew[2]), .Zout(SRnew[1]), .Cout(SRnew[0])
    );

    OperandFetch OpFetch(
        .clk(MCLK), .rst(reset),
        .Rsrc(CGsrcGen ? CGsrc : Rsrc), .Rdst(CGdstGen ? CGdst : Rdst),
        .MDB(MDBin),
        .srcM(srcM), .srcL(srcL), .dstM(dstM), .dstL(dstL), 
        .AddrM(AddrM), .AddrL(AddrL), .IdxM(IdxM), 
        .OpSrc(Opsrc), .OpDst(Opdst), .MAB(OpAddr)
    );

    RegisterFile RFile(
        .clk(MCLK), .rst(reset),
        .IdxF(IdxF), .IF(IF),
        .SPF(AddrM == 2'b01),
        .INTACK(INTACK), .Ex(Ex),
        .SRnew(SRnew), .srcA(srcA), .dstA(dstA),
        .IW6(CtlBW), 
        .srcInc((AddrM == 2'b10) & (As == INDIRECT_AUTOINCREMENT_MODE)),
        .dstInc((AddrM == 2'b11) & (As == INDIRECT_AUTOINCREMENT_MODE)),
        .RW(~Mem && Ex && ({IW[15:12], 12'b0} != CMP) && ({IW[15:12], 12'b0} != BIT)),
        .result(result), .ISR(MDBin),
        .PCout(RegPC), .SPout(RegSP), .Rsrc(Rsrc), .Rdst(Rdst),
        .SRcurrent(SRcurrent),
        .GIE(GIE)
    );

    SystemBusControl BusCtl(
        .IdxF(IdxF), .IF(IF), .Mem(Mem), .Ex(Ex && ({IW[15:12], 12'b0} != CMP) && ({IW[15:12], 12'b0} != BIT)), .INTACK(INTACK), .IW6(CtlBW),
        .PCnt(RegPC), .Addr((Blank) ? 16'b0 : OpAddr), .IntAddr(IntAddr), .result(result),
        .MAB(MAB), .MDBout(MDBout), .BW(BW), .MW(MW)
    );

endmodule
