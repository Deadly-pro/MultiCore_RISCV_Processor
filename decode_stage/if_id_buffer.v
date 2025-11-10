// if_id_buffer.v
//
// This is the pipeline register between the
// Instruction Fetch (IF) and Instruction Decode (ID) stages.
//
// *** UPDATED WITH STALL LOGIC ***

`timescale 1ns / 1ps

module if_id_buffer(
    input  wire        clk,
    input  wire        rst,
    
    // --- STALL input from Hazard Unit ---
    input  wire        pipeline_stall, // 1 = Freeze
    
    // --- Inputs from IF Stage ---
    input  wire [31:0] if_ins_in,
    input  wire [31:0] if_pc_plus_4_in,

    // --- Outputs to ID Stage ---
    output reg  [31:0] id_ins_out,
    output reg  [31:0] id_pc_plus_4_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, clear the outputs (insert a NOP)
            id_ins_out <= 32'h00000013; // addi x0, x0, 0 (NOP)
            id_pc_plus_4_out   <= 32'b0;
        
        // --- NEW STALL LOGIC ---
        // If we are stalling, we "do nothing", which means
        // the registers hold their current values.
        end else if (pipeline_stall) begin
            // Hold current value
            
        end else begin
            // Normal operation: latch the inputs
            id_ins_out <= if_ins_in;
            id_pc_plus_4_out   <= if_pc_plus_4_in;
        end
    end

endmodule