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
 if_id_buffer if_id(
  .clk(clk),
  .rst(rst),
  .if_ins_in(instruction),
  .if_pc_plus_4_in(curr_pc_plus_4),
  .id_ins_out(id_ins_in),
  .id_pc_plus_4_out(id_pc_plus_4)
  );
 // decode stage  
endmodule
