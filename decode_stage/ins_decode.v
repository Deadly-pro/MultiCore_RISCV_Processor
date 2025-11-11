`timescale 1ns / 1ps

module ins_decode(
    input  wire        clk,
    input  wire        rst,

    // --- Inputs from IF/ID Register ---
    input  wire [31:0] id_instruction_in,
    input  wire [31:0] id_pc_plus_4_in,
    input  wire [31:0] id_pc_in,         // <-- NEW: Pass PC for branches
    input wire         pipeline_stall,
    // --- Feedback Inputs for Hazards/Writeback ---
    input  wire [4:0]  ex_rd_addr_in,
    input  wire        ex_mem_read_in,
    input  wire [4:0]  wb_write_addr_in,
    input  wire [31:0] wb_write_data_in,
    input  wire        wb_reg_write_en_in,

    // --- Outputs to Hazard Unit/PC Control ---
    output wire        pipeline_stall_out,

    // --- Outputs to ID/EX Register ---
    output wire [31:0] id_pc_plus_4_out,
    output wire [31:0] id_pc_out,        // <-- NEW: Pass PC for branches
    output wire [31:0] id_read_data1_out,
    output wire [31:0] id_read_data2_out,
    output wire [31:0] id_immediate_out,
    output wire [4:0]  id_rs1_addr_out,
    output wire [4:0]  id_rs2_addr_out,
    output wire [4:0]  id_rd_addr_out,
    output wire [31:0] id_instruction_out, // <-- NEW: For debug
    // Control Signals
    output wire        id_mem_read_out,
    output wire        id_mem_write_out,
    output wire        id_reg_write_out,
    output wire        id_mem_to_reg_out,
    output wire        id_alu_src_out,
    output wire        id_branch_out,
    output wire [3:0]  id_alu_ctrl_out
);

    // --- Instruction Field Parsing ---
    wire [4:0] rs1    = id_instruction_in[19:15];
    wire [4:0] rs2    = id_instruction_in[24:20];
    wire [4:0] rd     = id_instruction_in[11:7];

    // --- Internal Wires ---
    wire [31:0] reg_read_data1;
    wire [31:0] reg_read_data2;
    wire [31:0] immediate;
    
    // Control unit output wires
    wire        ctrl_reg_write;
    wire        ctrl_mem_read;
    wire        ctrl_mem_write;
    wire        ctrl_mem_to_reg;
    wire        ctrl_alu_src;
    wire        ctrl_branch;
    wire [3:0]  ctrl_alu_ctrl;

    // --- 1. Register File ---
    reg_file rf (
        .clk(clk),
        .rst(rst),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2),
        .write_addr(wb_write_addr_in),
        .write_data(wb_write_data_in),
        .write_enable(wb_reg_write_en_in)
    );

    // --- 2. Immediate Generator ---
    imm_gen imm_gen_inst (
        .instruction(id_instruction_in),
        .immediate_out(immediate)
    );

    // --- 3. Control Unit ---
    control_unit control_unit_inst (
        .instr(id_instruction_in),
        .RegWrite(ctrl_reg_write),
        .MemRead(ctrl_mem_read),
        .MemWrite(ctrl_mem_write),
        .MemToReg(ctrl_mem_to_reg),
        .ALUSrc(ctrl_alu_src),
        .Branch(ctrl_branch),
        .ALUCtrl(ctrl_alu_ctrl)
    );

    // --- 4. Hazard Unit ---
    hazard_unit hazard_unit_inst (
        .id_rs1_addr(rs1),
        .id_rs2_addr(rs2),
        .ex_rd_addr(ex_rd_addr_in),
        .ex_mem_read(ex_mem_read_in),
        .pipeline_stall(pipeline_stall_out)
    );

    // --- 5. Final Output Assignments ---
    assign id_pc_plus_4_out  = id_pc_plus_4_in;
    assign id_pc_out         = id_pc_in; // Pass-through PC
    assign id_read_data1_out = reg_read_data1;
    assign id_read_data2_out = reg_read_data2;
    assign id_immediate_out  = immediate;
    assign id_rs1_addr_out   = rs1;
    assign id_rs2_addr_out   = rs2;
    assign id_rd_addr_out    = rd;
    assign id_instruction_out = id_instruction_in; // For debug

    // If stalled, we must output all-zeros (a bubble)
    assign id_mem_read_out   = (pipeline_stall) ? 1'b0 : ctrl_mem_read;
    assign id_mem_write_out  = (pipeline_stall) ? 1'b0 : ctrl_mem_write;
    assign id_reg_write_out  = (pipeline_stall) ? 1'b0 : ctrl_reg_write;
    assign id_mem_to_reg_out = (pipeline_stall) ? 1'b0 : ctrl_mem_to_reg;
    assign id_alu_src_out    = (pipeline_stall) ? 1'b0 : ctrl_alu_src;
    assign id_branch_out     = (pipeline_stall) ? 1'b0 : ctrl_branch;
    assign id_alu_ctrl_out   = (pipeline_stall) ? 4'hF : ctrl_alu_ctrl; // 4'hF = NOP

endmodule