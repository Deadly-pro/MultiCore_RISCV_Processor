// Load-use hazard detection unit.
`timescale 1ns / 1ps

module hazard_unit (
    input  wire [4:0] id_rs1_addr,
    input  wire [4:0] id_rs2_addr,
    input  wire [4:0] ex_rd_addr,
    input  wire       ex_mem_read,
    output reg        pipeline_stall
);

    always @(*) begin
        if (ex_mem_read && ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr))) begin
            pipeline_stall = 1'b1;
        end else begin
            pipeline_stall = 1'b0;
        end
    end

endmodule
