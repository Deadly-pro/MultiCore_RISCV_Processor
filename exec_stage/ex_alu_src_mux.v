module ALU_SRC_MUX (
    input  wire [31:0] rs2,
    input  wire [31:0] imm,
    input  wire        alu_src,
    output wire [31:0] mux_out
);

assign mux_out = (alu_src) ? imm : rs2;

endmodule
