`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date
// Design Name: 
// Module Name: riscv_core
// Description: Top-level RISC-V Core with pipeline connections up to EX/MA stage
//////////////////////////////////////////////////////////////////////////////////

module riscv_core(
    input wire clk,
    input wire rst
);
    // -------------------------------------------------------------------------
    // FETCH STAGE
    // -------------------------------------------------------------------------
    wire [31:0] next_pc;
    wire [31:0] curr_pc;
    wire [31:0] instruction;
    wire [31:0] curr_pc_plus_4;

    ins_fetch fetch_stage (
        .clk(clk),
        .rst(rst),
        .pc_in(next_pc),
        .ins_out(instruction),
        .pc_out(curr_pc),
        .pc_plus_4_out(curr_pc_plus_4)
    );

    // Simple PC increment
    assign next_pc = curr_pc_plus_4;

    // -------------------------------------------------------------------------
    // IF/ID BUFFER
    // -------------------------------------------------------------------------
    wire [31:0] id_instruction_in;
    wire [31:0] id_pc_plus_4_in;

    if_id_buffer if_id (
        .clk(clk),
        .rst(rst),
        .if_ins_in(instruction),
        .if_pc_plus_4_in(curr_pc_plus_4),
        .id_ins_out(id_instruction_in),
        .id_pc_plus_4_out(id_pc_plus_4_in)
    );

    // -------------------------------------------------------------------------
    // DECODE STAGE
    // -------------------------------------------------------------------------
    wire [31:0] id_pc_plus_4_out;
    wire [31:0] id_read_data1_out;
    wire [31:0] id_read_data2_out;
    wire [31:0] id_immediate_out;
    wire [4:0]  id_rs1_addr_out;
    wire [4:0]  id_rs2_addr_out;
    wire [4:0]  id_rd_addr_out;

    wire id_mem_read_out;
    wire id_mem_write_out;
    wire id_reg_write_out;
    wire id_mem_to_reg_out;
    wire id_alu_src_out;
    wire id_branch_out;
    wire [3:0] id_alu_ctrl_out;
    wire pipeline_stall_out;

    // Hazard feedback from EX/MEM
    wire [4:0] ex_rd_for_hazard;
    wire ex_mem_read_for_hazard;

    // WB stub for now
    wire [4:0] wb_write_addr_in = 5'b0;
    wire [31:0] wb_write_data_in = 32'b0;
    wire wb_reg_write_en_in = 1'b0;

    ins_decode decode_stage (
        .clk(clk),
        .rst(rst),
        .instruction_in(id_instruction_in),
        .pc_plus_4_in(id_pc_plus_4_in),

        // Hazard feedback
        .ex_rd_addr_in(ex_rd_for_hazard),
        .ex_mem_read_in(ex_mem_read_for_hazard),

        // WB
        .wb_write_addr_in(wb_write_addr_in),
        .wb_write_data_in(wb_write_data_in),
        .wb_reg_write_en_in(wb_reg_write_en_in),

        .pipeline_stall_out(pipeline_stall_out),

        // Outputs to ID/EX buffer
        .id_pc_plus_4_out(id_pc_plus_4_out),
        .id_read_data1_out(id_read_data1_out),
        .id_read_data2_out(id_read_data2_out),
        .id_immediate_out(id_immediate_out),
        .id_rs1_addr_out(id_rs1_addr_out),
        .id_rs2_addr_out(id_rs2_addr_out),
        .id_rd_addr_out(id_rd_addr_out),
        .id_mem_read_out(id_mem_read_out),
        .id_mem_write_out(id_mem_write_out),
        .id_reg_write_out(id_reg_write_out),
        .id_mem_to_reg_out(id_mem_to_reg_out),
        .id_alu_src_out(id_alu_src_out),
        .id_branch_out(id_branch_out),
        .id_alu_ctrl_out(id_alu_ctrl_out)
    );

    // -------------------------------------------------------------------------
    // ID/EX BUFFER
    // -------------------------------------------------------------------------
    wire [31:0] ex_pc_plus_4_in;
    wire [31:0] ex_read_data1_in;
    wire [31:0] ex_read_data2_in;
    wire [31:0] ex_immediate_in;
    wire [4:0]  ex_rs1_addr_in;
    wire [4:0]  ex_rs2_addr_in;
    wire [4:0]  ex_rd_addr_in;

    wire ex_mem_read_in;
    wire ex_mem_write_in;
    wire ex_reg_write_in;
    wire ex_mem_to_reg_in;
    wire ex_alu_src_in;
    wire ex_branch_in;
    wire [3:0] ex_alu_ctrl_in;

    id_ex_buffer id_ex (
        .clk(clk),
        .rst(rst),
        .pipeline_stall(pipeline_stall_out),

        // Inputs from ID
        .id_pc_plus_4_in(id_pc_plus_4_out),
        .id_read_data1_in(id_read_data1_out),
        .id_read_data2_in(id_read_data2_out),
        .id_immediate_in(id_immediate_out),
        .id_rs1_addr_in(id_rs1_addr_out),
        .id_rs2_addr_in(id_rs2_addr_out),
        .id_rd_addr_in(id_rd_addr_out),

        .id_mem_read_in(id_mem_read_out),
        .id_mem_write_in(id_mem_write_out),
        .id_reg_write_in(id_reg_write_out),
        .id_MemToReg_in(id_mem_to_reg_out),
        .id_ALUSrc_in(id_alu_src_out),
        .id_Branch_in(id_branch_out),
        .id_ALUCtrl_in(id_alu_ctrl_out),

        // Outputs to EX stage
        .ex_pc_plus_4_out(ex_pc_plus_4_in),
        .ex_read_data1_out(ex_read_data1_in),
        .ex_read_data2_out(ex_read_data2_in),
        .ex_immediate_out(ex_immediate_in),
        .ex_rs1_addr_out(ex_rs1_addr_in),
        .ex_rs2_addr_out(ex_rs2_addr_in),
        .ex_rd_addr_out(ex_rd_addr_in),
        .ex_mem_read_out(ex_mem_read_in),
        .ex_mem_write_out(ex_mem_write_in),
        .ex_reg_write_out(ex_reg_write_in),
        .ex_MemToReg_out(ex_mem_to_reg_in),
        .ex_ALUSrc_out(ex_alu_src_in),
        .ex_Branch_out(ex_branch_in),
        .ex_ALUCtrl_out(ex_alu_ctrl_in)
    );

    // -------------------------------------------------------------------------
    // EXECUTION STAGE
    // -------------------------------------------------------------------------
    wire [31:0] ex_pc_plus_4_out;
    wire [31:0] ex_alu_result_out;
    wire [31:0] ex_read_data2_out;
    wire [4:0]  ex_rd_addr_out;

    wire ex_mem_read_out;
    wire ex_mem_write_out;
    wire ex_reg_write_out;
    wire ex_mem_to_reg_out;
    wire ex_branch_out;

    ins_ex ex_stage (
        .clk(clk),
        .rst(rst),
        .id_pc_plus_4_in(ex_pc_plus_4_in),
        .id_read_data1_in(ex_read_data1_in),
        .id_read_data2_in(ex_read_data2_in),
        .id_immediate_in(ex_immediate_in),
        .id_rd_addr_in(ex_rd_addr_in),

        .id_mem_read_in(ex_mem_read_in),
        .id_mem_write_in(ex_mem_write_in),
        .id_reg_write_in(ex_reg_write_in),
        .id_mem_to_reg_in(ex_mem_to_reg_in),
        .id_branch_in(ex_branch_in),
        .id_alu_src_in(ex_alu_src_in),
        .id_alu_ctrl_in(ex_alu_ctrl_in),

        .ex_pc_plus_4_out(ex_pc_plus_4_out),
        .ex_alu_result_out(ex_alu_result_out),
        .ex_read_data2_out(ex_read_data2_out),
        .ex_rd_addr_out(ex_rd_addr_out),

        .ex_mem_read_out(ex_mem_read_out),
        .ex_mem_write_out(ex_mem_write_out),
        .ex_reg_write_out(ex_reg_write_out),
        .ex_mem_to_reg_out(ex_mem_to_reg_out),
        .ex_branch_out(ex_branch_out)
    );

    // -------------------------------------------------------------------------
    // EX/MA BUFFER
    // -------------------------------------------------------------------------
    wire [31:0] ma_pc_plus_4_out;
    wire [31:0] ma_alu_result_out;
    wire [31:0] ma_write_data_out;
    wire [4:0]  ma_rd_addr_out;
    wire ma_mem_read_out;
    wire ma_mem_write_out;
    wire ma_reg_write_out;
    wire ma_mem_to_reg_out;
    wire ma_branch_out;

    ex_ma_buffer ex_ma (
        .clk(clk),
        .rst(rst),
        .ex_pc_plus_4_in(ex_pc_plus_4_out),
        .ex_alu_result_in(ex_alu_result_out),
        .ex_read_data2_in(ex_read_data2_out),
        .ex_rd_addr_in(ex_rd_addr_out),

        .ex_mem_read_in(ex_mem_read_out),
        .ex_mem_write_in(ex_mem_write_out),
        .ex_reg_write_in(ex_reg_write_out),
        .ex_mem_to_reg_in(ex_mem_to_reg_out),
        .ex_branch_in(ex_branch_out),

        .ma_pc_plus_4_out(ma_pc_plus_4_out),
        .ma_alu_result_out(ma_alu_result_out),
        .ma_write_data_out(ma_write_data_out),
        .ma_rd_addr_out(ma_rd_addr_out),

        .ma_mem_read_out(ma_mem_read_out),
        .ma_mem_write_out(ma_mem_write_out),
        .ma_reg_write_out(ma_reg_write_out),
        .ma_mem_to_reg_out(ma_mem_to_reg_out),
        .ma_branch_out(ma_branch_out)
    );

    // -------------------------------------------------------------------------
    // FEEDBACK for hazard detection (ID stage)
    // -------------------------------------------------------------------------
    assign ex_rd_for_hazard       = ma_rd_addr_out;
    assign ex_mem_read_for_hazard = ma_mem_read_out;

endmodule
