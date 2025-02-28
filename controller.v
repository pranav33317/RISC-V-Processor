module controller(input  [6:0] op,
input  [2:0] funct3,
input funct7_5,
input  Zero,
output  [1:0] ResultSrc,
output  MemWrite,
output IRWrite,
output  PCSrc, ALUSrc,
output  RegWrite,
output Jump,
output Branch,
output  [2:0] ImmSrc, // i type , r type and b type instructions
output  [2:0] ALUControl);
// not included PCUpdate since not writing to PC ,we choose bw pc and computed addr 
// include IRWrite because

wire [1:0] ALUOp;
wire [2:0] ALUControl;

main_fsm fsm(op,ResultSrc,MemWrite,IRWritep,PCSrc,ALUSrc,RegWrite,Jump,Branch);

alu_decoder decoder1(op[5], funct3, funct7_5, ALUOp, ALUControl);

instr_decoder decoder2(op,ImmSrc);
assign PCSrc = (Branch  & Zero ) || Jump; 
endmodule
