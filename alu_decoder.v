module alu_decoder(input op[5],input [2:0] funct3,input funct7_5,input [1:0] ALUOp,output [2:0] ALUControl);

always@(*) begin

if (ALUOp == 2'b00) begin
      ALUControl = 3'b000;

end else if (ALUOp==2'b01) begin
      ALUControl=3'b001;

end else if (ALUOp==2'b10) begin
  if (funct3==3'b000) begin
    if (op[5]==1'b1 && funct7_5==1'b1) begin
        ALUControl=3'b001;
    end else begin
        ALUControl=3'b000;
    end
  end
  else if (funct3==3'b010) begin
        ALUControl=101;
  end
  else if (funct3==3'b110) begin
          ALUControl=010;
  end
  else if (funct3==3'b111) begin
          ALUControl=011;
  end

end
end
endmodule
