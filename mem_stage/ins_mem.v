// Memory stage logic.
`timescale 1ns / 1ps

module ins_mem (
    input  wire [31:0] alu_result_in,
    input  wire [31:0] rs2_data_in,
    input  wire [4:0]  rd_addr_in,
    input  wire [31:0] pc_plus_4_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        reg_write_in,
    input  wire        mem_to_reg_in,
    input  wire        write_from_pc_in,

    input  wire [31:0] mem_read_data_in,
    output wire [31:0] mem_address_out,
    output wire [31:0] mem_write_data_out,
    output wire        mem_read_en_out,
    output wire        mem_write_en_out,

    output wire [31:0] alu_result_out,
    output wire [31:0] read_data_out,
    output wire [4:0]  rd_addr_out,
    output wire [31:0] pc_plus_4_out,
    output wire        reg_write_out,
    output wire        mem_to_reg_out,
    output wire        write_from_pc_out
);

    assign mem_address_out    = alu_result_in;
    assign mem_write_data_out = rs2_data_in;
    assign mem_read_en_out    = mem_read_in;
    assign mem_write_en_out   = mem_write_in;

    assign alu_result_out     = alu_result_in;
    assign read_data_out      = mem_read_data_in;
    assign rd_addr_out        = rd_addr_in;
    assign pc_plus_4_out      = pc_plus_4_in;
    assign reg_write_out      = reg_write_in;
    assign mem_to_reg_out     = mem_to_reg_in;
    assign write_from_pc_out  = write_from_pc_in;

endmodule
