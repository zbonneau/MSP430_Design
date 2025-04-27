/*--------------------------------------------------------
    Module Name: BlockMemInterface
    Description:
        Interfaces the System Memory Bus with a Block Memory Module
    Inputs:

    Outputs:

--------------------------------------------------------*/
`timescale 100ns/100ns

module BlockMemInterface (
    input MCLK,
    input [15:0] MAB, MDBwrite,
    input MW, BW,
    output reg [15:0] MDBread
 );
    `include "PARAMS.v"

    /* Internal signal definitions */
    reg [1:0] RAM_we, FRAM_we, IVT_we;

    reg [7:0]  BSL_addr;
    reg [9:0]  RAM_addr;
    reg [14:0] FRAM_addr;
    reg [5:0]  IVT_addr;

    reg [15:0]  RAM_din,  FRAM_din,  IVT_din;
    wire [15:0] RAM_dout, FRAM_dout, IVT_dout, BSL_dout;

    initial begin 
        {RAM_we, FRAM_we, IVT_we} = 0;
        {RAM_addr, FRAM_addr, IVT_addr, BSL_addr} = 0;
        {RAM_din, FRAM_din, IVT_din} = 0;
        MDBread = 0;
    end 

    /* Handle BSL Interface */
    always @(*) begin
        if (MAB >= BSL_START && MAB < BSL_START + BSL_LEN) 
            BSL_addr = ({MAB[15:1], 1'b0} - BSL_START) >> 1;
        else 
            BSL_addr = 0;
    end

    /* Handle RAM interface */
    always @(*) begin
        if (MAB >= RAM_START && MAB < RAM_START + RAM_LEN) begin
            RAM_addr = ({MAB[15:1], 1'b0} - RAM_START) >> 1;
            if (BW & MAB[0]) begin
                RAM_din = {MDBwrite[7:0], 8'b0};
                RAM_we = 2'b10;
            end 
            else if (BW & ~MAB[0]) begin
                RAM_din = {8'h00, MDBwrite[7:0]};
                RAM_we = 2'b01;
            end
            else begin
                RAM_din = MDBwrite;
                RAM_we = 2'b11;
            end

            if (~MW) RAM_we = 0;
        end
        else begin
            {RAM_din, RAM_addr, RAM_we} = 0;
        end
    end

    /* Handle FRAM interface */
    always @(*) begin
        if (MAB >= FRAM_START && MAB < FRAM_START + FRAM_LEN) begin
            FRAM_addr = ({MAB[15:1], 1'b0} - FRAM_START) >> 1;
            if (BW & MAB[0]) begin
                FRAM_din = {MDBwrite[7:0], 8'b0};
                FRAM_we = 2'b10;
            end 
            else if (BW & ~MAB[0]) begin
                FRAM_din = {8'h00, MDBwrite[7:0]};
                FRAM_we = 2'b01;
            end
            else begin
                FRAM_din = MDBwrite;
                FRAM_we = 2'b11;
            end

            if (~MW) FRAM_we = 0;
        end
        else begin
            {FRAM_din, FRAM_addr, FRAM_we} = 0;
        end
    end
    
    /* Handle IVT interface */
    always @(*) begin
        if (MAB >= IVT_START) begin 
            IVT_addr = ({MAB[15:1], 1'b0} - IVT_START) >> 1;
            if (BW & MAB[0]) begin
                IVT_din = {MDBwrite[7:0], 8'b0};
                IVT_we = 2'b10;
            end 
            else if (BW & ~MAB[0]) begin
                IVT_din = {8'h00, MDBwrite[7:0]};
                IVT_we = 2'b01;
            end
            else begin
                IVT_din = MDBwrite;
                IVT_we = 2'b11;
            end

            if (~MW) IVT_we = 0;
        end
        else begin
            {IVT_din, IVT_addr, IVT_we} = 0;
        end
    end

    /* Handle MABread */
    always @(*) begin
        if (MAB >= BSL_START && MAB < BSL_START + BSL_LEN) begin
            if (BW & MAB[0])
                MDBread = {8'h00, BSL_dout[15:8]};
            else if (BW & ~MAB[1])
                MDBread = {8'h00, BSL_dout[7:0]};
            else 
                MDBread = BSL_dout;
        end
        if (MAB >= RAM_START && MAB < RAM_START + RAM_LEN) begin
            if (BW & MAB[0])
                MDBread = {8'h00, RAM_dout[15:8]};
            else if (BW & ~MAB[1])
                MDBread = {8'h00, RAM_dout[7:0]};
            else 
                MDBread = RAM_dout;
        end 
        else if (MAB >= FRAM_START && MAB < FRAM_START + FRAM_LEN) begin
            if (BW & MAB[0])
                MDBread = {8'h00, FRAM_dout[15:8]};
            else if (BW & ~MAB[1])
                MDBread = {8'h00, FRAM_dout[7:0]};
            else 
                MDBread = FRAM_dout;
        end 
        else if (MAB >= IVT_START) begin // upper limit is MAX(MAB)
            if (BW & MAB[0])
                MDBread = {8'h00, IVT_dout[15:8]};
            else if (BW & ~MAB[1])
                MDBread = {8'h00, IVT_dout[7:0]};
            else 
                MDBread = IVT_dout;
        end 
        else begin
            MDBread = {16{1'bz}};
        end
    end

    /* Block MEM Instances */
    blk_mem_gen_BSL BSL_isnt(
        .clka(~MCLK),
        .addra(BSL_addr),
        .douta(BSL_dout)
    );

    blk_mem_gen_RAM RAM_inst(
        .clka(~MCLK),
        .wea(RAM_we),
        .addra(RAM_addr),
        .dina(RAM_din),
        .douta(RAM_dout)
    );

    blk_mem_gen_FRAM FRAM_inst(
        .clka(~MCLK),
        .wea(FRAM_we),
        .addra(FRAM_addr),
        .dina(FRAM_din),
        .douta(FRAM_dout)
    );

    blk_mem_gen_IVT IVT_inst(
        .clka(~MCLK),
        .wea(IVT_we),
        .addra(IVT_addr),
        .dina(IVT_din),
        .douta(IVT_dout)
    );
endmodule
