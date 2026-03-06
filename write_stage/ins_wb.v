// Write-back stage logic.
`timescale 1ns / 1ps

module ins_wb (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] alu_result_in,
    input  wire [31:0] read_data_in,
    input  wire [31:0] pc_plus_4_in,
    input  wire [4:0]  rd_addr_in,
    input  wire        reg_write_in,
    input  wire        mem_to_reg_in,
    input  wire        write_from_pc_in,

    output wire [31:0] wb_write_data_out,
    output wire [4:0]  wb_rd_addr_out,
    output wire        wb_reg_write_en_out
);

    wire [31:0] write_data_mux;

    assign write_data_mux = (mem_to_reg_in) ? read_data_in : alu_result_in;
    assign wb_write_data_out = (write_from_pc_in) ? pc_plus_4_in : write_data_mux;
    assign wb_rd_addr_out = rd_addr_in;
    assign wb_reg_write_en_out = reg_write_in;

endmodule
