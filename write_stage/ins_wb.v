`timescale 1ns / 1ps
//
// ins_wb (Write Back Stage)
// This is the 5th stage. It's purely combinational.
// It selects the correct data to write back to the register file
// and passes the feedback signals to the ID stage.
//
module ins_wb (
    input  wire        clk, // Not used, but kept for consistency
    input  wire        rst, // Not used, but kept for consistency

    // --- Inputs from MEM/WB Register ---
    input  wire [31:0] alu_result_in,
    input  wire [31:0] read_data_in,
    input  wire [31:0] pc_plus_4_in,
    input  wire [4:0]  rd_addr_in,
    input  wire        reg_write_in,
    input  wire        mem_to_reg_in,
    
    // --- Outputs (Feedback to ID Stage) ---
    output wire [31:0] wb_write_data_out, // Data to write to reg_file
    output wire [4:0]  wb_rd_addr_out,    // Address to write
    output wire        wb_reg_write_en_out  // Write enable
);

    // Write-back Mux:
    // Select data from memory (for LW) or from ALU (for R-type/I-type)
    // (A more complete design would also handle JAL/JALR here)
    assign wb_write_data_out = (mem_to_reg_in) ? read_data_in : alu_result_in;

    // Pass feedback signals
    assign wb_rd_addr_out    = rd_addr_in;
    assign wb_reg_write_en_out = reg_write_in;

endmodule