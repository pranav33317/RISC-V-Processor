module instr_decoder(input [6:0] op , output reg [1:0] ImmSrc);
always@(*) begin
if (op==7'd3 || op==7'd19) begin
    ImmSrc=2'b00;   // I type ( 3 for load and 19 for arithmetic)
end else if (op==7'd35) begin
    ImmSrc=2'b01; // s type
end else if (op==7'd99) begin
   ImmSrc=2'b10; // b type
end else if (op==7'd111) begin
    ImmSrc=2'b11; // j type
end


end
endmodule
