// Instruction fetch stage logic.
`timescale 1ns / 1ps

module ins_fetch (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_in,
    input  wire [31:0] instruction_in,
    output wire [31:0] pc_plus_4_out,
    output wire [31:0] instruction_out
);

    assign pc_plus_4_out = pc_in + 32'd4;
    assign instruction_out = instruction_in;

endmodule
