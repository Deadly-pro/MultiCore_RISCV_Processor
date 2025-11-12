// -----------------------------------------------------------------------------
// File: exec_stage/branch_unit.v
// Purpose: Compute branch decision and target.
// Current: Implements BEQ semantics (equal comparison). Target = PC + imm.
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module branch_logic (
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire [31:0] immediate,
    input  wire [31:0] current_pc,
    input  wire        branch_in,
    
    output wire        branch_taken_out,
    output wire [31:0] branch_target_out
);

    // For now, just implements BEQ
    wire is_equal = (rs1_data == rs2_data);

    assign branch_target_out = current_pc + immediate;
    assign branch_taken_out  = branch_in & is_equal;

endmodule