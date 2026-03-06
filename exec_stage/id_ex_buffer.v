// ID/EX stage pipeline register.
`timescale 1ns / 1ps

module id_ex_buffer (
    input  wire        clk,
    input  wire        rst,
    input  wire        pipeline_stall,

    input  wire [31:0] id_pc_plus_4_in,
    input  wire [31:0] id_pc_in,
    input  wire [31:0] id_read_data1_in,
    input  wire [31:0] id_read_data2_in,
    input  wire [31:0] id_immediate_in,
    input  wire [4:0]  id_rs1_addr_in,
    input  wire [4:0]  id_rs2_addr_in,
    input  wire [4:0]  id_rd_addr_in,
    input  wire [31:0] id_instruction_in,
    input  wire        id_mem_read_in,
    input  wire        id_mem_write_in,
    input  wire        id_reg_write_in,
    input  wire        id_mem_to_reg_in,
    input  wire        id_alu_src_in,
    input  wire        id_branch_in,
    input  wire [3:0]  id_alu_ctrl_in,
    input  wire        id_write_from_pc_in,

    output reg  [31:0] ex_pc_plus_4_out,
    output reg  [31:0] ex_pc_out,
    output reg  [31:0] ex_read_data1_out,
    output reg  [31:0] ex_read_data2_out,
    output reg  [31:0] ex_immediate_out,
    output reg  [4:0]  ex_rs1_addr_out,
    output reg  [4:0]  ex_rs2_addr_out,
    output reg  [4:0]  ex_rd_addr_out,
    output reg  [31:0] ex_instruction_out,
    output reg         ex_mem_read_out,
    output reg         ex_mem_write_out,
    output reg         ex_reg_write_out,
    output reg         ex_mem_to_reg_out,
    output reg         ex_alu_src_out,
    output reg         ex_branch_out,
    output reg  [3:0]  ex_alu_ctrl_out,
    output reg         ex_write_from_pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst || pipeline_stall) begin
            ex_pc_plus_4_out   <= 32'b0;
            ex_pc_out          <= 32'b0;
            ex_read_data1_out  <= 32'b0;
            ex_read_data2_out  <= 32'b0;
            ex_immediate_out   <= 32'b0;
            ex_rs1_addr_out    <= 5'b0;
            ex_rs2_addr_out    <= 5'b0;
            ex_rd_addr_out     <= 5'b0;
            ex_instruction_out <= 32'b0;
            ex_mem_read_out    <= 1'b0;
            ex_mem_write_out   <= 1'b0;
            ex_reg_write_out   <= 1'b0;
            ex_mem_to_reg_out  <= 1'b0;
            ex_alu_src_out      <= 1'b0;
            ex_branch_out      <= 1'b0;
            ex_alu_ctrl_out     <= 4'b0;
            ex_write_from_pc_out <= 1'b0;
        end else begin
            ex_pc_plus_4_out   <= id_pc_plus_4_in;
            ex_pc_out          <= id_pc_in;
            ex_read_data1_out  <= id_read_data1_in;
            ex_read_data2_out  <= id_read_data2_in;
            ex_immediate_out   <= id_immediate_in;
            ex_rs1_addr_out    <= id_rs1_addr_in;
            ex_rs2_addr_out    <= id_rs2_addr_in;
            ex_rd_addr_out     <= id_rd_addr_in;
            ex_instruction_out <= id_instruction_in;
            ex_mem_read_out    <= id_mem_read_in;
            ex_mem_write_out   <= id_mem_write_in;
            ex_reg_write_out   <= id_reg_write_in;
            ex_mem_to_reg_out  <= id_mem_to_reg_in;
            ex_alu_src_out      <= id_alu_src_in;
            ex_branch_out      <= id_branch_in;
            ex_alu_ctrl_out     <= id_alu_ctrl_in;
            ex_write_from_pc_out <= id_write_from_pc_in;
        end
    end

endmodule
