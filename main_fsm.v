module main_fsm(
    input [6:0] op,  // Opcode input
    input clk,        // Clock input
    input reset,      // Reset input
    output reg [1:0] ResultSrc,
    output reg MemWrite,
    output reg IRWrite,
    output reg PCSrc,
    output reg ALUSrc,
    output reg RegWrite,
    output reg Jump,
    output reg Branch
);

// 5 states, 3 bits for state encoding
// 000 : Fetch, 001 : Decode, 010 : Execute, 011 : Mem, 101 : Write Back
reg [2:0] state, next_state;

always @(posedge clk) begin
    if (reset) begin
        // On reset, set the FSM to the Fetch state
        state <= 3'b000;  // Fetch state
    end else begin
        // Otherwise, update the state on the clock edge
        state <= next_state;
    end
end

// Logic to determine the next state
always @(*) begin
    case (state)
        3'b000: next_state = 3'b001;  // Fetch -> Decode
        3'b001: next_state = 3'b010;  // Decode -> Execute
        3'b010: next_state = 3'b011;  // Execute -> Mem
        3'b011: next_state = 3'b101;  // Mem -> Write Back
        3'b101: next_state = 3'b000;  // Write Back -> Fetch
        default: next_state = 3'b000; // Default to Fetch on any invalid state
    endcase
end

// Output logic based on current state and opcode (op)
always @(*) begin
    case (state)
        3'b000: begin  // Fetch
            ResultSrc = 2'b10; // to take pc+4 
            MemWrite = 0;
            IRWrite = 1;
            PCSrc = 0; // taking from ALU
           // ALUSrc =0;
            RegWrite = 0;
            Jump = 0;
            Branch = 0;
        end
        3'b001: begin  // Decode
            ResultSrc = 2'b001;
            MemWrite = 0;
            IRWrite = 0;
            ALUSrc = 0;
            RegWrite = 0;
            Jump = 0;
            Branch = 0;
        end
        3'b010: begin  // Execute
            ResultSrc = 3'b010;
            MemWrite = 0;
            IRWrite = 0;
            PCSrc = 0;
            ALUSrc = 1;
            RegWrite = 1;
            Jump = 0;
            Branch = 0;
        end
        3'b011: begin  // Mem
            ResultSrc = 3'b011;
            MemWrite = 1;
            IRWrite = 0;
            PCSrc = 0;
            ALUSrc = 0;
            RegWrite = 0;
            Jump = 0;
            Branch = 0;
        end
        3'b101: begin  // Write Back
            ResultSrc = 3'b100;
            MemWrite = 0;
            IRWrite = 0;
            PCSrc = 0;
            ALUSrc = 0;
            RegWrite = 1;
            Jump = 0;
            Branch = 0;
        end
        default: begin
            ResultSrc = 3'b000;
            MemWrite = 0;
            IRWrite = 0;
            PCSrc = 0;
            ALUSrc = 0;
            RegWrite = 0;
            Jump = 0;
            Branch = 0;
        end
    endcase
end

endmodule

