module riscv_pipelined(input clk,input reset,
output [31:0] PC,
input  [31:0] Instr,
output  MemWrite,
output  [31:0] ALUResult,output [31:0] WriteData,
input  [31:0] ReadData_from_data_memory);
// Inputs : clk ,reset , Inctruction , Readata_from_data_memeory
// Outputs : Program counrer , memwrite, alu result , writedata(data to be writt// to memory 


//Internal signals :
wire  ALUSrc;// alu source values are from imm/reg
wire  RegWrite; // asssert to write to reg file
wire  Jump; // asserted in b type or jal instructions
wire  Zero; // used in b type , if the computed alu result is 0 , then asserted
wire [1:0] ResultSrc; // chooses bw slu output/memory or imm
wire  ImmSrc; // imm extraction from instructions
wire [2:0] ALUControl; // 3 bit signal gives exacy operation to be done

// Controller
controller c(Instr[6:0] // Opcode
, Instr[14:12] // funct3
, Instr[30] // funct7
, Zero,// asserted if answer is 0
ResultSrc, MemWrite, PCSrc,
ALUSrc, RegWrite, Jump,
ImmSrc, ALUControl);

// data path:

datapath dp(clk, reset, ResultSrc, PCSrc,
ALUSrc, RegWrite,
ImmSrc, ALUControl,
Zero, PC, Instr,
ALUResult, WriteData, ReadData);
endmodule
