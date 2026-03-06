// Multiplexer for data forwarding.
`timescale 1ns / 1ps

module forward_mux (
    input  wire [31:0] reg_data_in,
    input  wire [31:0] mem_forward_data_in,
    input  wire [31:0] wb_forward_data_in,
    input  wire [1:0]  forward_sel_in,
    output reg  [31:0] forward_out
);

    always @(*) begin
        case (forward_sel_in)
            2'b00:   forward_out = reg_data_in;
            2'b01:   forward_out = wb_forward_data_in;
            2'b10:   forward_out = mem_forward_data_in;
            default: forward_out = reg_data_in;
        endcase
    end

endmodule
