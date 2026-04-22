module maindec(
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] op,
    output logic [1:0] ALUOp,
    output logic [1:0] ALUSrcA,
    output logic [1:0] ALUSrcB,
    output logic [1:0] ResultSrc,
    output logic       AdrSrc,
    output logic       IRWrite,
    output logic       RegWrite,
    output logic       MemWrite,
    output logic       Branch,
    output logic       PCUpdate
);

    typedef enum logic [3:0] {
        S0_FETCH,
        S1_DECODE,
        S2_MEMADR,
        S3_MEMREAD,
        S4_MEMWB,
        S5_MEMWRITE,
        S6_EXECUTER,
        S7_ALUWB,
        S8_EXECUTEI,
        S9_JAL,
        S10_BEQ
    } state_t;

    state_t state, nextstate;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0_FETCH;
        else
            state <= nextstate;
    end

    always_comb begin
        case (state)
            S0_FETCH: nextstate = S1_DECODE;

            S1_DECODE: begin
                case (op)
                    7'b0000011, 7'b0100011: nextstate = S2_MEMADR;
                    7'b0110011: nextstate = S6_EXECUTER;
                    7'b0010011: nextstate = S8_EXECUTEI;
                    7'b1101111: nextstate = S9_JAL;
                    7'b1100011: nextstate = S10_BEQ;
                    default:    nextstate = S0_FETCH;
                endcase
            end

            S2_MEMADR: begin
                case (op)
                    7'b0000011: nextstate = S3_MEMREAD;
                    7'b0100011: nextstate = S5_MEMWRITE;
                    default:    nextstate = S0_FETCH;
                endcase
            end

            S3_MEMREAD:  nextstate = S4_MEMWB;
            S4_MEMWB:    nextstate = S0_FETCH;
            S5_MEMWRITE: nextstate = S0_FETCH;
            S6_EXECUTER: nextstate = S7_ALUWB;
            S7_ALUWB:    nextstate = S0_FETCH;
            S8_EXECUTEI: nextstate = S7_ALUWB;
            S9_JAL:      nextstate = S7_ALUWB;
            S10_BEQ:     nextstate = S0_FETCH;
            default:     nextstate = S0_FETCH;
        endcase
    end

    always_comb begin
        ALUOp=0; ALUSrcA=0; ALUSrcB=0; ResultSrc=0;
        AdrSrc=0; IRWrite=0; RegWrite=0; MemWrite=0;
        Branch=0; PCUpdate=0;

        case (state)
            S0_FETCH: begin
                IRWrite=1; ALUSrcB=2'b10; ResultSrc=2'b10; PCUpdate=1;
            end
            S1_DECODE: begin
                ALUSrcA=2'b01; ALUSrcB=2'b01;
            end
            S2_MEMADR: begin
                ALUSrcA=2'b10; ALUSrcB=2'b01;
            end
            S3_MEMREAD: AdrSrc=1;
            S4_MEMWB: begin ResultSrc=2'b01; RegWrite=1; end
            S5_MEMWRITE: begin AdrSrc=1; MemWrite=1; end
            S6_EXECUTER: begin ALUSrcA=2'b10; ALUOp=2'b10; end
            S7_ALUWB: RegWrite=1;
            S8_EXECUTEI: begin ALUSrcA=2'b10; ALUSrcB=2'b01; ALUOp=2'b10; end
            S9_JAL: begin ALUSrcA=2'b01; ALUSrcB=2'b10; PCUpdate=1; end
            S10_BEQ: begin ALUSrcA=2'b10; ALUOp=2'b01; Branch=1; end
        endcase
    end

endmodule