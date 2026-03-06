// Data hazard forwarding control unit.
`timescale 1ns / 1ps

module forwarding_unit (
    input  wire [4:0] ex_rs1_addr,
    input  wire [4:0] ex_rs2_addr,
    input  wire [4:0] mem_rd_addr,
    input  wire       mem_reg_write,
    input  wire [4:0] wb_rd_addr,
    input  wire       wb_reg_write,
    output reg  [1:0] forward_a,
    output reg  [1:0] forward_b
);

    always @(*) begin
        forward_a = 2'b00;
        if (mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == ex_rs1_addr)) begin
            forward_a = 2'b10;
        end else if (wb_reg_write && (wb_rd_addr != 5'b0) && (wb_rd_addr == ex_rs1_addr)) begin
            forward_a = 2'b01;
        end

        forward_b = 2'b00;
        if (mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == ex_rs2_addr)) begin
            forward_b = 2'b10;
        end else if (wb_reg_write && (wb_rd_addr != 5'b0) && (wb_rd_addr == ex_rs2_addr)) begin
            forward_b = 2'b01;
        end
    end

endmodule
