`timescale 1ns / 1ps
// This register sits between IF and ID

module if_id_buffer (
    input  wire        clk,
    input  wire        rst,
    input  wire        pipeline_stall, // From Hazard Unit
    
    // --- Inputs from IF Stage ---
    input  wire [31:0] if_instruction_in,
    input  wire [31:0] if_pc_plus_4_in,
    input  wire [31:0] if_pc_in,

    // --- Outputs to ID Stage ---
    output reg  [31:0] id_instruction_out,
    output reg  [31:0] id_pc_plus_4_out,
    output reg  [31:0] id_pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            id_instruction_out <= 32'h00000013; // NOP
            id_pc_plus_4_out   <= 32'b0;
            id_pc_out          <= 32'b0;
        end 
        // If we stall, we hold our current value (do nothing)
        else if (!pipeline_stall) begin
            id_instruction_out <= if_instruction_in;
            id_pc_plus_4_out   <= if_pc_plus_4_in;
            id_pc_out          <= if_pc_in;
        end
    end

endmodule