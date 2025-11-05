`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 18:36:49
// Design Name: 
// Module Name: riscv_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module riscv_core(
input wire clk,
input wire rst
);
 wire [31:0] next_pc;
 wire [31:0] curr_pc;
 wire [31:0] instruction;
 wire [31:0] curr_pc_plus_4;
 // fetch stage 
 ins_fetch fetch_state(
 .clk(clk),
 .rst(rst),
 .pc_in(next_pc),
 .ins_out(instruction),
 .pc_out(curr_pc),
 .pc_plus_4_out(curr_pc_plus_4));   
 // connect to the IF/ID Buffer
 wire [31:0] id_ins_in;
 wire [31:0] id_pc_plus_4;
 if_id_buffer if_id_buff(
  .clk(clk),
  .rst(rst),
  .if_ins_in(instruction),
  .if_pc_plus_4_in(curr_pc_plus_4),
  .id_ins_out(id_ins_in),
  .id_pc_plus_4_out(id_pc_plus_4)
  );
 // decode stage  
  wire        pipeline_stall_out;
  wire [31:0] id_pc_plus_4_out;
  wire [31:0] id_read_data1_out;
  wire [31:0] id_read_data2_out;
  wire [31:0] id_immediate_out;
  wire [4:0]  id_rs1_addr_out;
  wire [4:0]  id_rs2_addr_out;
  wire [4:0]  id_rd_addr_out;
  wire        id_mem_read_out;
  wire        id_mem_write_out;
  wire        id_reg_write_out;
  wire        id_mem_to_reg_out;
  wire        id_alu_src_out;
  wire        id_branch_out;
  wire [3:0]  id_alu_ctrl_out;
 ins_decode decode_stage(
 .clk(clk),
 .rst(rst),
 .instruction_in(id_ins_in),
 .pc_plus_4_in(id_pc_plus_4),
 .ex_rd_addr_in(5'b0),
  .ex_mem_read_in(1'b0),
  .wb_write_addr_in(5'b0),
  .wb_write_data_in(32'b0),
  .wb_reg_write_en_in(1'b0),
  
   // --- Outputs (connected to our wires) ---
  .pipeline_stall_out(pipeline_stall_out),
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
endmodule
