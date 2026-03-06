// Program counter register for a RISC-V core.
`timescale 1ns / 1ps

module prog_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_in,
    output reg  [31:0] pc_out
);

    always @(posedge clk) begin
        if (rst) begin
            pc_out <= 32'h0000_0000;
        end else begin
            pc_out <= pc_in;
        end
    end

endmodule
