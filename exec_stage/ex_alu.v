// -----------------------------------------------------------------------------
// File: exec_stage/ex_alu.v
// Purpose: Arithmetic Logic Unit. Operations selected by ALU_control (4-bit).
// Matches encoding defined in control_unit.v.
// -----------------------------------------------------------------------------
module ALU (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALU_control,
    output reg  [31:0] result
);

    // --- ALUCtrl encoding (from control_unit.v) ---
    // This block is added so the 'case' statement is readable
    // and matches your control_unit.v file.
    localparam [3:0] ALU_ADD  = 4'h0;
    localparam [3:0] ALU_SUB  = 4'h1;
    localparam [3:0] ALU_AND  = 4'h2;
    localparam [3:0] ALU_OR   = 4'h3;
    localparam [3:0] ALU_XOR  = 4'h4;
    localparam [3:0] ALU_SLL  = 4'h5;
    localparam [3:0] ALU_SRL  = 4'h6;
    localparam [3:0] ALU_SRA  = 4'h7;
    localparam [3:0] ALU_SLT  = 4'h8;
    localparam [3:0] ALU_SLTU = 4'h9;
    localparam [3:0] ALU_LUI  = 4'hA; // Used for LUI
    localparam [3:0] ALU_NOP  = 4'hF;

always @(*) begin
    case (ALU_control)
        // These values now match control_unit.v
        ALU_ADD:  result = A + B;
        ALU_SUB:  result = A - B;
        ALU_AND:  result = A & B;
        ALU_OR:   result = A | B;
        ALU_XOR:  result = A ^ B;
        ALU_SLL:  result = A << B[4:0];
        ALU_SRL:  result = A >> B[4:0];
        ALU_SRA:  result = $signed(A) >>> B[4:0];
        ALU_SLT:  result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
        ALU_SLTU: result = (A < B) ? 32'b1 : 32'b0;
        
        // For LUI, the control unit sends ALU_LUI.
        // The ALU source mux will select the immediate.
        // We just pass that immediate (B) through.
        ALU_LUI:  result = B; 
        
        default: result = 32'hdeadbeef; // Default (shouldn't happen)
    endcase
end

endmodule