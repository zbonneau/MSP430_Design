/*--------------------------------------------------------
    Module Name : CarDecoder
    Description: 
        Maps Instruction Fetch to CAR microsequence index.

    Inputs:
        IW  - Instruction Word

    Outputs:
        CAR - CAR microsequence index

--------------------------------------------------------*/

module CarDecoder(
    input [15:0] IW,
    output reg [CAR_BITS-1:0] CAR
 );

    `include "NEW\\PARAMS.v"

    initial begin CAR = 0; end

    /* Summary of Car Decoder. 
        Inspect Instruction Format
        |
        |-> 2-op. Inspect src address mode
        |   |
        |   |-> Register OR CG1/2. Inspect dst address mode
        |   |   |
        |   |   |-> Register OR CG1/2
        |   |   |
        |   |   |-> Indexed Mode
        |   |
        |   |-> Indexed Mode. Inspect dst ...
        |   |   | ...
        |   |
        |   |-> Indirect (autoincrement) Mode. Inspect dst ...
        |       | ...
        |   
        |-> Jump Instructions
        |
        |-> 1-op. Inspect 1-op type
            |
            |-> ALU. Inspect dst address mode (stored in As position)
            |
            |-> PUSH. Inspect dst ...
            |
            |-> CALL. Inspect dst ...
            |
            |-> RETI
    */
    always @(*) begin
        if (|IW[15:14]) begin
            // 2-op instruction -----------------------------------------------
            if (IW[5:4] == REGISTER_MODE || IW[11:8] == CG2 || 
                (IW[11:8] == CG1 && IW[5:4] != INDEXED_MODE)
                ) begin
                // Special Decoding for Constant Generator calls to source
                // && Register address mode
                if ((IW[3:0] == CG1 && IW[7] != INDEXED_MODE) || 
                     IW[3:0] == CG2) begin
                    // Special Decoding for Constant Generator calls to dst
                    CAR = CAR_REG_REG;
                end
                else begin
                    //     Ad ?     Indexed      : Register
                    CAR = (IW[7]) ? CAR_REG_IDX0 : CAR_REG_REG;
                end
            end

            else if (IW[5:4] == INDEXED_MODE) begin
                // As = Indexed mode
                if ((IW[3:0] == CG1 && IW[7] != INDEXED_MODE) || 
                     IW[3:0] == CG2) begin
                    // Special Decoding for Constant Generator calls to dst
                    CAR = CAR_IDX_REG0;
                end
                else begin
                    //     Ad ?     Indexed      : Register
                    CAR = (IW[7]) ? CAR_IDX_IDX0 : CAR_IDX_REG0;
                end
            end 

            else begin
                // As = indirect (autoincrement) mode
                if ((IW[3:0] == CG1 && IW[7] != INDEXED_MODE) || 
                     IW[3:0] == CG2) begin
                    // Special Decoding for Constant Generator calls to dst
                    CAR = CAR_IND_REG0;
                end
                else begin
                    //     Ad ?     Indexed      : Register
                    CAR = (IW[7]) ? CAR_IND_IDX0 : CAR_IND_REG0;
                end
            end
        end

        else if (IW[15:13] == 3'b001) begin
            // Jump instruction -----------------------------------------------
            CAR = CAR_JMP0;
        end 

        else if (IW[15:12] == 4'b0001) begin
            // 1-op instruction -----------------------------------------------
            case({IW[15:7], 7'b0})
                RRC, RRCB, SWPB, RRA, RRAB, SXT: begin
                    // basic 1-op ALU instructions ------------------------
                    if (IW[3:0] == CG1 && IW[5:4] != INDEXED_MODE || 
                        IW[3:0] == CG2) begin
                        // Special decoding for constant generator calls
                        CAR = CAR_1OP_REG;
                    end
                    else begin
                        // CAR index depends on address mode
                        case(IW[5:4])
                            REGISTER_MODE:  begin CAR = CAR_1OP_REG;  end
                            INDEXED_MODE:   begin CAR = CAR_1OP_IDX0; end
                            default:        begin CAR = CAR_1OP_IND0; end
                        endcase
                    end
                end

                PUSH, PUSHB: begin
                    // Push decoding --------------------------------------
                    if (IW[3:0] == CG1 && IW[5:4] != INDEXED_MODE || 
                        IW[3:0] == CG2) begin
                        // Special decoding for constant generator calls
                        CAR = CAR_PUSH_REG0;
                    end
                    else begin
                        // CAR index depends on address mode
                        case(IW[5:4]) 
                            REGISTER_MODE:  begin CAR = CAR_PUSH_REG0; end
                            INDEXED_MODE:   begin CAR = CAR_PUSH_IDX0; end
                            default:        begin CAR = CAR_PUSH_IND0; end
                        endcase
                    end
                end

                CALL: begin
                    // Call decoding --------------------------------------
                    if (IW[3:0] == CG1 && IW[5:4] != INDEXED_MODE || 
                        IW[3:0] == CG2) begin
                        // Special decoding for constant generator calls
                        CAR = CAR_CALL_REG0;
                    end
                    else begin
                        // CAR index depends on address mode
                        case(IW[5:4]) 
                            REGISTER_MODE:  begin CAR = CAR_CALL_REG0; end
                            INDEXED_MODE:   begin CAR = CAR_CALL_IDX0; end
                            default:        begin CAR = CAR_CALL_IND0; end
                        endcase
                    end
                end

                RETI: begin
                    // RETI decoding --------------------------------------
                    CAR = CAR_RETI0;
                end

                default: begin
                    // undefined 1-op instruction -------------------------
                    CAR = 0;
                end
            endcase
        end

        else begin
            // undefined instruction format
            CAR = 0;
        end
    end

endmodule
