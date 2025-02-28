module datapath(
    input logic clk, reset,
    input logic [1:0] ResultSrc,
    input logic PCSrc, ALUSrc,
    input logic RegWrite,
    input logic [1:0] ImmSrc,
    input logic [2:0] ALUControl,
    output logic Zero,
    output logic [31:0] PC,
    input logic [31:0] Instr,
    output logic [31:0] ALUResult, WriteData,
    input logic [31:0] ReadData
);

    // IF/ID Pipeline registers (Instruction Fetch to Instruction Decode)
    logic [31:0] IF_ID_PCPlus4, IF_ID_Instr;
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            IF_ID_PCPlus4 <= 32'b0;
            IF_ID_Instr <= 32'b0;
        end else begin
            IF_ID_PCPlus4 <= PCPlus4;
            IF_ID_Instr <= Instr;
        end
    end

    // ID/EX Pipeline registers (Instruction Decode to Execute)
    logic [31:0] ID_EX_PCPlus4, ID_EX_ImmExt, ID_EX_SrcA, ID_EX_SrcB;
    logic [4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;
    logic ID_EX_RegWrite, ID_EX_ALUSrc;
    logic [2:0] ID_EX_ALUControl;
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            ID_EX_PCPlus4 <= 32'b0;
            ID_EX_ImmExt <= 32'b0;
            ID_EX_SrcA <= 32'b0;
            ID_EX_SrcB <= 32'b0;
            ID_EX_Rs1 <= 5'b0;
            ID_EX_Rs2 <= 5'b0;
            ID_EX_Rd <= 5'b0;
            ID_EX_RegWrite <= 0;
            ID_EX_ALUSrc <= 0;
            ID_EX_ALUControl <= 3'b0;
        end else begin
            ID_EX_PCPlus4 <= IF_ID_PCPlus4;
            ID_EX_ImmExt <= ImmExt;
            ID_EX_SrcA <= SrcA;
            ID_EX_SrcB <= SrcB;
            ID_EX_Rs1 <= Instr[19:15];  // Rs1
            ID_EX_Rs2 <= Instr[24:20];  // Rs2
            ID_EX_Rd <= Instr[11:7];    // Rd
            ID_EX_RegWrite <= RegWrite;
            ID_EX_ALUSrc <= ALUSrc;
            ID_EX_ALUControl <= ALUControl;
        end
    end

    // EX/MEM Pipeline registers (Execute to Memory Access)
    logic [31:0] EX_MEM_ALUResult, EX_MEM_SrcB;
    logic EX_MEM_RegWrite;
    logic [4:0] EX_MEM_Rd;
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            EX_MEM_ALUResult <= 32'b0;
            EX_MEM_SrcB <= 32'b0;
            EX_MEM_RegWrite <= 0;
            EX_MEM_Rd <= 5'b0;
        end else begin
            EX_MEM_ALUResult <= ALUResult;
            EX_MEM_SrcB <= SrcB;
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_Rd <= ID_EX_Rd;
        end
    end

    // MEM/WB Pipeline registers (Memory Access to Write Back)
    logic [31:0] MEM_WB_ALUResult, MEM_WB_ReadData;
    logic MEM_WB_RegWrite;
    logic [4:0] MEM_WB_Rd;
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            MEM_WB_ALUResult <= 32'b0;
            MEM_WB_ReadData <= 32'b0;
            MEM_WB_RegWrite <= 0;
            MEM_WB_Rd <= 5'b0;
        end else begin
            MEM_WB_ALUResult <= EX_MEM_ALUResult;
            MEM_WB_ReadData <= ReadData;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_Rd <= EX_MEM_Rd;
        end
    end

    // Next PC and Instruction Fetch Logic (IF Stage)
    logic [31:0] PCNext, PCPlus4, PCTarget;
    adder pcadd4(PC, 32'd4, PCPlus4);
    adder pcaddbranch(PC, ImmExt, PCTarget);
    mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
    flopr #(32) pcreg(clk, reset, PCNext, PC);

    // Instruction Decode Logic (ID Stage)
    regfile rf(clk, RegWrite, IF_ID_Instr[19:15], IF_ID_Instr[24:20],
                IF_ID_Instr[11:7], Result, SrcA, WriteData);
    extend ext(IF_ID_Instr[31:7], ImmSrc, ImmExt);

    // ALU and Execution Logic (EX Stage)
    mux2 #(32) srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
    alu alu(SrcA, SrcB, ID_EX_ALUControl, ALUResult, Zero);

    // Result Multiplexing Logic (WB Stage)
    mux3 #(32) resultmux(MEM_WB_ALUResult, MEM_WB_ReadData, PCPlus4,
                         ResultSrc, Result);
    
endmodule

