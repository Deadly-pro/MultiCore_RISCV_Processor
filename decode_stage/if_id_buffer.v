// IF/ID stage pipeline register.
`timescale 1ns / 1ps

module if_id_buffer (
    input  wire        clk,
    input  wire        rst,
    input  wire        pipeline_stall,
    input  wire [31:0] if_instruction_in,
    input  wire [31:0] if_pc_plus_4_in,
    input  wire [31:0] if_pc_in,
    output reg  [31:0] id_instruction_out,
    output reg  [31:0] id_pc_plus_4_out,
    output reg  [31:0] id_pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            id_instruction_out <= 32'b0;
            id_pc_plus_4_out   <= 32'b0;
            id_pc_out          <= 32'b0;
        end else if (!pipeline_stall) begin
            id_instruction_out <= if_instruction_in;
            id_pc_plus_4_out   <= if_pc_plus_4_in;
            id_pc_out          <= if_pc_in;
        end
    end

endmodule
