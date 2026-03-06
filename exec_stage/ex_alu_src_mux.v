// Multiplexer for ALU source B.
`timescale 1ns / 1ps

module ex_alu_src_mux (
    input  wire [31:0] read_data2_in,
    input  wire [31:0] immediate_in,
    input  wire        alu_src_sel_in,
    output reg  [31:0] alu_op_b_out
);

    always @(*) begin
        case (alu_src_sel_in)
            1'b0: alu_op_b_out = read_data2_in;
            1'b1: alu_op_b_out = immediate_in;
            default: alu_op_b_out = read_data2_in;
        endcase
    end

endmodule
