// 4-bank shared data memory controller.
`timescale 1ns / 1ps

module mem_controller(
    input  wire        clk,

    input  wire        core0_mem_read_en,
    input  wire        core0_mem_write_en,
    input  wire [31:0] core0_address,
    input  wire [31:0] core0_write_data,
    output wire [31:0] core0_read_data,

    input  wire        core1_mem_read_en,
    input  wire        core1_mem_write_en,
    input  wire [31:0] core1_address,
    input  wire [31:0] core1_write_data,
    output wire [31:0] core1_read_data,
    
    input  wire        core2_mem_read_en,
    input  wire        core2_mem_write_en,
    input  wire [31:0] core2_address,
    input  wire [31:0] core2_write_data,
    output wire [31:0] core2_read_data,
    
    input  wire        core3_mem_read_en,
    input  wire        core3_mem_write_en,
    input  wire [31:0] core3_address,
    input  wire [31:0] core3_write_data,
    output wire [31:0] core3_read_data
);

    reg [31:0] bank0 [0:1023];
    reg [31:0] bank1 [0:1023];
    reg [31:0] bank2 [0:1023];
    reg [31:0] bank3 [0:1023];

    always @(posedge clk) begin
        if (core0_mem_write_en) bank0[core0_address[11:2]] <= core0_write_data;
    end
    assign core0_read_data = (core0_mem_read_en) ? bank0[core0_address[11:2]] : 32'b0;

    always @(posedge clk) begin
        if (core1_mem_write_en) bank1[core1_address[11:2]] <= core1_write_data;
    end
    assign core1_read_data = (core1_mem_read_en) ? bank1[core1_address[11:2]] : 32'b0;

    always @(posedge clk) begin
        if (core2_mem_write_en) bank2[core2_address[11:2]] <= core2_write_data;
    end
    assign core2_read_data = (core2_mem_read_en) ? bank2[core2_address[11:2]] : 32'b0;

    always @(posedge clk) begin
        if (core3_mem_write_en) bank3[core3_address[11:2]] <= core3_write_data;
    end
    assign core3_read_data = (core3_mem_read_en) ? bank3[core3_address[11:2]] : 32'b0;

endmodule
