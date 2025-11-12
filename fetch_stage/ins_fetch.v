// -----------------------------------------------------------------------------
// File: fetch_stage/ins_fetch.v
// Purpose: Instruction Fetch datapath: computes PC+4 and passes instruction in.
// Notes:   IMEM is external; this stage is purely combinational.
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//
// ins_fetch (for multi-core)
// This module NO LONGER instantiates memory.
// It is purely combinational.
//
module ins_fetch(
    input  wire        clk,
    input  wire        rst,
    
    // --- Inputs ---
    input  wire [31:0] pc_in,            // From PC register
    input  wire [31:0] instruction_in,   // From external IMEM
    
    // --- Outputs ---
    output wire [31:0] pc_plus_4_out,
    output wire [31:0] instruction_out
);
    
    // Calculate PC+4 for the next stage and for PC control
    assign pc_plus_4_out = pc_in + 32'd4;
    assign instruction_out=instruction_in;
endmodule