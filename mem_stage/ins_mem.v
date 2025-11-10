`timescale 1ns / 1ps
//
// ins_mem (for multi-core)
// This module NO LONGER instantiates data_memory.
// It is now a sequential stage that outputs memory signals
// to the external DMEM ports.
//
module ins_mem (
    input  wire        clk,
    input  wire        rst,

    // --- Inputs from EX/MEM Register ---
    input  wire [31:0] alu_result_in,    // Memory address
    input  wire [31:0] rs2_data_in,      // Data to write (for SW)
    input  wire [4:0]  rd_addr_in,       // Destination register
    input  wire [31:0] pc_plus_4_in,     // For JAL/JALR
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        reg_write_in,
    input  wire        mem_to_reg_in,

    // --- Interface to Data Memory (External) ---
    input  wire [31:0] mem_read_data_in,   // Data from dmem
    output reg  [31:0] mem_address_out,    // Address to dmem
    output reg  [31:0] mem_write_data_out, // Data to dmem
    output reg         mem_read_en_out,
    output reg         mem_write_en_out,

    // --- Outputs to MEM/WB Register ---
    output reg  [31:0] alu_result_out,
    output reg  [31:0] read_data_out,
    output reg  [4:0]  rd_addr_out,
    output reg  [31:0] pc_plus_4_out,
    output reg         reg_write_out,
    output reg         mem_to_reg_out
);

    // This is a sequential stage, so we register all signals.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Clear all outputs
            mem_address_out    <= 32'b0;
            mem_write_data_out <= 32'b0;
            mem_read_en_out    <= 1'b0;
            mem_write_en_out   <= 1'b0;
            alu_result_out     <= 32'b0;
            read_data_out      <= 32'b0;
            rd_addr_out        <= 5'b0;
            pc_plus_4_out      <= 32'b0;
            reg_write_out      <= 1'b0;
            mem_to_reg_out     <= 1'b0;
        end else begin
            // --- 1. Connect to data_memory ---
            mem_address_out    <= alu_result_in;  // ALU result is the address
            mem_write_data_out <= rs2_data_in;    // rs2_data is the data to store
            mem_read_en_out    <= mem_read_in;
            mem_write_en_out   <= mem_write_in;

            // --- 2. Pass signals to MEM/WB Register ---
            alu_result_out     <= alu_result_in;
            read_data_out      <= mem_read_data_in; // This is the data from dmem
            rd_addr_out        <= rd_addr_in;
            pc_plus_4_out      <= pc_plus_4_in;
            reg_write_out      <= reg_write_in;
            mem_to_reg_out     <= mem_to_reg_in;
        end
    end
    
endmodule