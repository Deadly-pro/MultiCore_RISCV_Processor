`timescale 1ns / 1ps
// This is the pipeline register between EX and MEM

module ex_ma_buffer (
    input  wire        clk,
    input  wire        rst,
    
    // --- Inputs from EX Stage ---
    input  wire [31:0] ex_pc_plus_4_in,
    input  wire [31:0] ex_alu_result_in,
    input  wire [31:0] ex_read_data2_in, // This is the data to be written to memory
    input  wire [4:0]  ex_rd_addr_in,
    
    // Control signals
    input  wire        ex_mem_read_in,
    input  wire        ex_mem_write_in,
    input  wire        ex_reg_write_in,
    input  wire        ex_mem_to_reg_in,
    input  wire        ex_branch_in,

    // --- Outputs to MEM Stage ---
    output reg  [31:0] ma_pc_plus_4_out,
    output reg  [31:0] ma_alu_result_out,
    output reg  [31:0] ma_write_data_out, // Renamed from ex_read_data2_in
    output reg  [4:0]  ma_rd_addr_out,

    // Control signals
    output reg         ma_mem_read_out,
    output reg         ma_mem_write_out,
    output reg         ma_reg_write_out,
    output reg         ma_mem_to_reg_out,
    output reg         ma_branch_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ma_pc_plus_4_out  <= 32'b0;
            ma_alu_result_out <= 32'b0;
            ma_write_data_out <= 32'b0;
            ma_rd_addr_out    <= 5'b0;
            ma_mem_read_out   <= 1'b0;
            ma_mem_write_out  <= 1'b0;
            ma_reg_write_out  <= 1'b0;
            ma_mem_to_reg_out <= 1'b0;
            ma_branch_out     <= 1'b0;
        end else begin
            // Normal operation
            ma_pc_plus_4_out  <= ex_pc_plus_4_in;
            ma_alu_result_out <= ex_alu_result_in;
            ma_write_data_out <= ex_read_data2_in;
            ma_rd_addr_out    <= ex_rd_addr_in;
            ma_mem_read_out   <= ex_mem_read_in;
            ma_mem_write_out  <= ex_mem_write_in;
            ma_reg_write_out  <= ex_reg_write_in;
            ma_mem_to_reg_out <= ex_mem_to_reg_in;
            ma_branch_out     <= ex_branch_in;
        end
    end

endmodule