`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Module: mem_wb_register
//
// Description: This is the pipeline register between the Memory (MEM)
//              stage and the Write Back (WB) stage.
//
//              It captures the final data (either the ALU result or the
//              data read from memory) and the control signals needed
//              for the final write-back to the register file.
//
//////////////////////////////////////////////////////////////////////////////////

module mem_wb_buffer (
    input  wire        clk,
    input  wire        rst,
    
    // --- Inputs from MEM Stage (ins_mem) ---
    input  wire [31:0] mem_alu_result_in,    // Pass-through ALU result
    input  wire [31:0] mem_read_data_in,     // Data from data memory (for LW)
    input  wire [4:0]  mem_rd_addr_in,       // Destination register
    input  wire [31:0] mem_pc_plus_4_in,     // Pass-through for JAL/JALR
    
    // Control signals
    input  wire        mem_reg_write_in,     // Is a write to a register required?
    input  wire        mem_mem_to_reg_in,    // 0 = ALU result, 1 = Memory data

    // --- Outputs to WB Stage (ins_wb) ---
    output reg  [31:0] wb_alu_result_out,
    output reg  [31:0] wb_read_data_out,
    output reg  [4:0]  wb_rd_addr_out,
    output reg  [31:0] wb_pc_plus_4_out,
    
    // Control signals
    output reg         wb_reg_write_out,
    output reg         wb_mem_to_reg_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, clear all outputs.
            // Importantly, set RegWrite to 0 to prevent
            // accidental writes on startup.
            wb_alu_result_out <= 32'b0;
            wb_read_data_out  <= 32'b0;
            wb_rd_addr_out    <= 5'b0;
            wb_pc_plus_4_out  <= 32'b0;
            wb_reg_write_out  <= 1'b0; // 0 = No write
            wb_mem_to_reg_out <= 1'b0; // Default to 0 (ALU result)
        end else begin
            // Normal operation: capture all inputs from the MEM stage.
            wb_alu_result_out <= mem_alu_result_in;
            wb_read_data_out  <= mem_read_data_in;
            wb_rd_addr_out    <= mem_rd_addr_in;
            wb_pc_plus_4_out  <= mem_pc_plus_4_in;
            wb_reg_write_out  <= mem_reg_write_in;
            wb_mem_to_reg_out <= mem_mem_to_reg_in;
        end
    end

endmodule