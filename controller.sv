module controller(
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       zero,
    output logic [1:0] immsrc,
    output logic [1:0] alusrca,
    output logic [1:0] alusrcb,
    output logic [1:0] resultsrc,
    output logic       adrsrc,
    output logic [2:0] alucontrol,
    output logic       irwrite,
    output logic       pcwrite,
    output logic       regwrite,
    output logic       memwrite
);

    logic [1:0] ALUOp;
    logic       branch;
    logic       pcupdate;

    maindec md(
        .clk(clk),
        .reset(reset),
        .op(op),
        .ALUOp(ALUOp),
        .ALUSrcA(alusrca),
        .ALUSrcB(alusrcb),
        .ResultSrc(resultsrc),
        .AdrSrc(adrsrc),
        .IRWrite(irwrite),
        .RegWrite(regwrite),
        .MemWrite(memwrite),
        .Branch(branch),
        .PCUpdate(pcupdate)
    );

    instrdec id(
        .op(op),
        .ImmSrc(immsrc)
    );

    aludec ad(
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(ALUOp),
        .ALUControl(alucontrol)
    );

    assign pcwrite = pcupdate | (branch & zero);

endmodule