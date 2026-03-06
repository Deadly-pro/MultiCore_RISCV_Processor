// Execute stage integration.
`timescale 1ns / 1ps

module ins_ex (
    input  wire [31:0] id_pc_plus_4_in,
    input  wire [31:0] id_pc_in,
    input  wire [31:0] id_read_data1_in,
    input  wire [31:0] id_read_data2_in,
    input  wire [31:0] id_immediate_in,
    input  wire [4:0]  id_rd_addr_in,
    input  wire [31:0] mem_forward_data_in,
    input  wire [31:0] wb_forward_data_in,
    input  wire [1:0]  forward_a_in,
    input  wire [1:0]  forward_b_in,
    input  wire        id_mem_read_in,
    input  wire        id_mem_write_in,
    input  wire        id_reg_write_in,
    input  wire        id_mem_to_reg_in,
    input  wire        id_branch_in,
    input  wire        id_alu_src_in,
    input  wire [3:0]  id_alu_ctrl_in,
    input  wire        id_write_from_pc_in,

    output wire [31:0] ex_pc_plus_4_out,
    output wire [31:0] ex_alu_result_out,
    output wire [31:0] ex_read_data2_out,
    output wire [4:0]  ex_rd_addr_out,
    output wire        ex_mem_read_out,
    output wire        ex_mem_write_out,
    output wire        ex_reg_write_out,
    output wire        ex_mem_to_reg_out,
    output wire        ex_write_from_pc_out,
    output wire        ex_branch_taken_out,
    output wire [31:0] ex_branch_target_out
);

    wire [31:0] op_a;
    wire [31:0] op_b_forwarded;
    wire [31:0] alu_op_b;

    forward_mux fwd_mux_a (
        .reg_data_in(id_read_data1_in),
        .mem_forward_data_in(mem_forward_data_in),
        .wb_forward_data_in(wb_forward_data_in),
        .forward_sel_in(forward_a_in),
        .forward_out(op_a)
    );

    forward_mux fwd_mux_b (
        .reg_data_in(id_read_data2_in),
        .mem_forward_data_in(mem_forward_data_in),
        .wb_forward_data_in(wb_forward_data_in),
        .forward_sel_in(forward_b_in),
        .forward_out(op_b_forwarded)
    );

    ex_alu_src_mux alu_src_m (
        .read_data2_in(op_b_forwarded),
        .immediate_in(id_immediate_in),
        .alu_src_sel_in(id_alu_src_in),
        .alu_op_b_out(alu_op_b)
    );

    ex_alu alu (
        .op_a_in(op_a),
        .op_b_in(alu_op_b),
        .alu_ctrl_in(id_alu_ctrl_in),
        .alu_result_out(ex_alu_result_out)
    );

    branch_unit bu (
        .op_a_in(op_a),
        .op_b_in(op_b_forwarded),
        .pc_in(id_pc_in),
        .immediate_in(id_immediate_in),
        .branch_ctrl_in(id_branch_in),
        .branch_taken_out(ex_branch_taken_out),
        .branch_target_out(ex_branch_target_out)
    );

    assign ex_pc_plus_4_out     = id_pc_plus_4_in;
    assign ex_read_data2_out    = op_b_forwarded;
    assign ex_rd_addr_out       = id_rd_addr_in;
    assign ex_mem_read_out      = id_mem_read_in;
    assign ex_mem_write_out     = id_mem_write_in;
    assign ex_reg_write_out     = id_reg_write_in;
    assign ex_mem_to_reg_out    = id_mem_to_reg_in;
    assign ex_write_from_pc_out = id_write_from_pc_in;

endmodule
