// Instruction decode stage integration.
`timescale 1ns / 1ps

module ins_decode (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] id_instruction_in,
    input  wire [31:0] id_pc_plus_4_in,
    input  wire [31:0] id_pc_in,

    input  wire [4:0]  ex_rd_addr_in,
    input  wire        ex_mem_read_in,
    input  wire        ex_reg_write_in,

    input  wire [4:0]  wb_write_addr_in,
    input  wire [31:0] wb_write_data_in,
    input  wire        wb_reg_write_en_in,

    output wire        pipeline_stall_out,
    output wire [31:0] id_pc_plus_4_out,
    output wire [31:0] id_pc_out,
    output wire [31:0] id_read_data1_out,
    output wire [31:0] id_read_data2_out,
    output wire [31:0] id_immediate_out,
    output wire [4:0]  id_rs1_addr_out,
    output wire [4:0]  id_rs2_addr_out,
    output wire [4:0]  id_rd_addr_out,
    output wire [31:0] id_instruction_out,
    output wire        id_mem_read_out,
    output wire        id_mem_write_out,
    output wire        id_reg_write_out,
    output wire        id_mem_to_reg_out,
    output wire        id_alu_src_out,
    output wire        id_branch_out,
    output wire [3:0]  id_alu_ctrl_out,
    output wire        id_write_from_pc_out
);

    wire [6:0] opcode = id_instruction_in[6:0];
    wire [2:0] funct3 = id_instruction_in[14:12];
    wire [6:0] funct7 = id_instruction_in[31:25];

    assign id_rs1_addr_out = id_instruction_in[19:15];
    assign id_rs2_addr_out = id_instruction_in[24:20];
    assign id_rd_addr_out  = id_instruction_in[11:7];

    hazard_unit hu (
        .id_rs1_addr(id_rs1_addr_out),
        .id_rs2_addr(id_rs2_addr_out),
        .ex_rd_addr(ex_rd_addr_in),
        .ex_mem_read(ex_mem_read_in),
        .pipeline_stall(pipeline_stall_out)
    );

    control_unit cu (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RegWrite(id_reg_write_out),
        .MemToReg(id_mem_to_reg_out),
        .MemRead(id_mem_read_out),
        .MemWrite(id_mem_write_out),
        .ALUSrc(id_alu_src_out),
        .Branch(id_branch_out),
        .ALUCtrl(id_alu_ctrl_out),
        .WriteFromPC(id_write_from_pc_out)
    );

    reg_file rf (
        .clk(clk),
        .rst(rst),
        .read_addr1(id_rs1_addr_out),
        .read_data1(id_read_data1_out),
        .read_addr2(id_rs2_addr_out),
        .read_data2(id_read_data2_out),
        .write_addr(wb_write_addr_in),
        .write_data(wb_write_data_in),
        .write_enable(wb_reg_write_en_in)
    );

    imm_gen ig (
        .instruction(id_instruction_in),
        .immediate(id_immediate_out)
    );

    assign id_pc_plus_4_out = id_pc_plus_4_in;
    assign id_pc_out        = id_pc_in;
    assign id_instruction_out = id_instruction_in;

endmodule
