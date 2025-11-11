`timescale 1ns / 1ps
//
// This is a 3-to-1 MUX used for data forwarding.
// It selects which data to send to the ALU.
//
module forwarding_mux (
    // --- Data Inputs ---
    input  wire [31:0] data_from_reg_file, // (from ID/EX)
    input  wire [31:0] data_from_mem_stage,  // (from EX/MEM)
    input  wire [31:0] data_from_wb_stage,   // (from MEM/WB)

    // --- Control Input ---
    input  wire [1:0]  forward_sel,        // (from Forwarding Unit)

    // --- Output ---
    output wire [31:0] forwarded_data
);

    // Forwarding MUX Control Signals:
    // 2'b00:  Use Register File data
    // 2'b01:  Forward from MEM stage
    // 2'b10:  Forward from WB stage
    
    // We use a casex here to handle the default (00) case cleanly
    assign forwarded_data = (forward_sel == 2'b10) ? data_from_wb_stage :
                            (forward_sel == 2'b01) ? data_from_mem_stage :
                            data_from_reg_file; // Default (00)

endmodule