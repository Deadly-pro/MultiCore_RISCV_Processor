// Branch decision and target calculation unit.
`timescale 1ns / 1ps

module branch_unit (
    input  wire [31:0] op_a_in,
    input  wire [31:0] op_b_in,
    input  wire [31:0] pc_in,
    input  wire [31:0] immediate_in,
    input  wire        branch_ctrl_in,
    output wire        branch_taken_out,
    output wire [31:0] branch_target_out
);

    wire is_equal = (op_a_in == op_b_in);
    assign branch_taken_out = branch_ctrl_in && is_equal;
    assign branch_target_out = pc_in + immediate_in;

endmodule
