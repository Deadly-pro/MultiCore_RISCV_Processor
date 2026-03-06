// Arithmetic Logic Unit (ALU) for RV32I.
`timescale 1ns / 1ps

module ex_alu (
    input  wire [31:0] op_a_in,
    input  wire [31:0] op_b_in,
    input  wire [3:0]  alu_ctrl_in,
    output reg  [31:0] alu_result_out
);

    always @(*) begin
        case (alu_ctrl_in)
            4'b0000: alu_result_out = op_a_in + op_b_in;
            4'b0001: alu_result_out = op_a_in - op_b_in;
            4'b0010: alu_result_out = op_a_in & op_b_in;
            4'b0011: alu_result_out = op_a_in | op_b_in;
            4'b0100: alu_result_out = op_a_in ^ op_b_in;
            4'b0101: alu_result_out = op_b_in; 
            default: alu_result_out = 32'b0;
        endcase
    end

endmodule
