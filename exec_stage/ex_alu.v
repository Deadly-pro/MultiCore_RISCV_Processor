


module ALU (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALU_control,
    output reg  [31:0] result
);

always @(*) begin
    case (ALU_control)
        4'b0000: result = A & B;                        // AND
        4'b0001: result = A | B;                        // OR
        4'b0010: result = A + B;                        // ADD
        4'b0011: result = A ^ B;                        // XOR
        4'b0100: result = A << B[4:0];                  // SLL
        4'b0101: result = A >> B[4:0];                  // SRL
        4'b0110: result = A - B;                        // SUB
        4'b0111: result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLT (signed)
        4'b1000: result = (A < B) ? 32'b1 : 32'b0;      // SLTU (unsigned)
        4'b1001: result = $signed(A) >>> B[4:0];        // SRA
        4'b1010: result = A;                            // PASS A
        4'b1011: result = B;                            // PASS B
        default: result = 32'b0;                        // Default
    endcase
end

endmodule
