// RV32I 32x32 register file.
`timescale 1ns / 1ps

module reg_file (
    input  wire        clk,
    input  wire        rst,
    input  wire [4:0]  read_addr1,
    output wire [31:0] read_data1,
    input  wire [4:0]  read_addr2,
    output wire [31:0] read_data2,
    input  wire [4:0]  write_addr,
    input  wire [31:0] write_data,
    input  wire        write_enable 
);
    integer i;
    reg [31:0] registers [0:31];

    assign read_data1 = (read_addr1 == 5'b0) ? 32'b0 : registers[read_addr1];
    assign read_data2 = (read_addr2 == 5'b0) ? 32'b0 : registers[read_addr2];

    always @(posedge clk or posedge rst) begin
       if(rst)begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end 
        else begin
            if (write_enable && (write_addr != 5'b0)) begin
                registers[write_addr] <= write_data;
            end
        end
    end

endmodule
