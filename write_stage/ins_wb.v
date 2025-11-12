// -----------------------------------------------------------------------------
// File: write_stage/ins_wb.v
// Purpose: Write-back stage. Selects final write data to the reg file among
//          ALU result, memory data, or PC+4 (JAL/JALR), and exposes feedback.
// -----------------------------------------------------------------------------
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
    input  wire        write_from_pc_in,
    
    // --- Outputs (Feedback to ID Stage) ---
    output wire [31:0] wb_write_data_out, // Data to write to reg_file
    output wire [4:0]  wb_rd_addr_out,    // Address to write
    output wire        wb_reg_write_en_out  // Write enable
);

    // Write-back Mux:
    // Select data from memory (for LW) or from ALU (for R-type/I-type)
    // (Handle JAL/JALR via write_from_pc flag)
    assign wb_write_data_out = write_from_pc_in ? pc_plus_4_in :
                               (mem_to_reg_in ? read_data_in : alu_result_in);

    // Pass feedback signals
    assign wb_rd_addr_out    = rd_addr_in;
    assign wb_reg_write_en_out = reg_write_in;

    // Debug: log writes to x3
    always @(posedge clk) begin
        if (!rst && reg_write_in && rd_addr_in == 5'd3) begin
            $display("[WB dbg] t=%0t write x3=%0d (src=%s)", $time, wb_write_data_out,
                     write_from_pc_in ? "pc+4" : (mem_to_reg_in ? "mem" : "alu"));
        end
    end

endmodule
