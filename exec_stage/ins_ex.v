// -----------------------------------------------------------------------------
// File: exec_stage/ins_ex.v
// Purpose: Execute stage. Applies forwarding, selects ALU operands, computes
//          ALU result and branch decision/target, and forwards control.
// Notes:   Branch decision/target are registered to avoid multiple drivers.
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//
// ins_ex (Execute Stage)
// This version fixes the multiple-driver bug on the branch outputs.
//
module ins_ex (
    input  wire        clk,
    input  wire        rst,

    // --- Inputs from ID/EX Register ---
    input  wire [31:0] id_pc_plus_4_in,
    input  wire [31:0] id_pc_in,
    input  wire [31:0] id_read_data1_in,  // rs1 data
    input  wire [31:0] id_read_data2_in,  // rs2 data
    input  wire [31:0] id_immediate_in,
    input  wire [4:0]  id_rd_addr_in,

    // --- Forwarding Inputs ---
    input  wire [31:0] mem_forward_data_in,
    input  wire [31:0] wb_forward_data_in,
    input  wire [1:0]  forward_a_in,
    input  wire [1:0]  forward_b_in,

    // --- Control signals from ID/EX ---
    input  wire        id_mem_read_in,
    input  wire        id_mem_write_in,
    input  wire        id_reg_write_in,
    input  wire        id_mem_to_reg_in, // <-- This is [1:0]
    input  wire        id_branch_in,
    input  wire        id_alu_src_in,
    input  wire [3:0]  id_alu_ctrl_in,
    input  wire        id_write_from_pc_in,

    // --- Outputs (to be latched in EX/MEM register) ---
    output reg  [31:0] ex_pc_plus_4_out,
    output reg  [31:0] ex_alu_result_out,
    output reg  [31:0] ex_read_data2_out,
    output reg  [4:0]  ex_rd_addr_out,
    output reg         ex_mem_read_out,
    output reg         ex_mem_write_out,
    output reg         ex_reg_write_out,
    output reg         ex_mem_to_reg_out,
    output reg         ex_write_from_pc_out,

    // --- Branch Outputs (to PC control) ---
    output reg         ex_branch_taken_out,
    output reg  [31:0] ex_branch_target_out
);

    // --- Internal wires for forwarding and ALU path ---
    wire [31:0] fwd_data_a;
    wire [31:0] fwd_data_b;
    wire [31:0] alu_mux_out_b;
    wire [31:0] alu_result;
    
    // --- Internal (non-registered) branch signals ---
    wire        branch_taken_comb;
    wire [31:0] branch_target_comb;
    
    // --- 1. Forwarding MUXes (Combinational) ---
    forwarding_mux fwd_mux_a (
        .data_from_reg_file(id_read_data1_in),
        .data_from_mem_stage(mem_forward_data_in),
        .data_from_wb_stage(wb_forward_data_in),
        .forward_sel(forward_a_in),
        .forwarded_data(fwd_data_a)
    );

    forwarding_mux fwd_mux_b (
        .data_from_reg_file(id_read_data2_in),
        .data_from_mem_stage(mem_forward_data_in),
        .data_from_wb_stage(wb_forward_data_in),
        .forward_sel(forward_b_in),
        .forwarded_data(fwd_data_b)
    );

    // --- 2. ALU Source MUX (Combinational) ---
    ALU_SRC_MUX alu_src_mux_inst (
        .rs2(fwd_data_b),
        .imm(id_immediate_in),
        .alu_src(id_alu_src_in),
        .mux_out(alu_mux_out_b)
    );

    // --- 3. ALU (Combinational) ---
    ALU alu_inst (
        .A(fwd_data_a),
        .B(alu_mux_out_b),
        .ALU_control(id_alu_ctrl_in),
        .result(alu_result)
    );
    
    // --- 4. Branch Logic (Combinational) ---
    branch_logic branch_unit (
        .rs1_data(fwd_data_a),
        .rs2_data(fwd_data_b),
        .immediate(id_immediate_in),
        .current_pc(id_pc_in),
        .branch_in(id_branch_in),
        .branch_taken_out(branch_taken_comb),    // Use the temp wire
        .branch_target_out(branch_target_comb) // Use the temp wire
    );

    // --- 5. Register Outputs (Sequential) ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_pc_plus_4_out   <= 32'b0;
            ex_alu_result_out  <= 32'b0;
            ex_read_data2_out  <= 32'b0;
            ex_rd_addr_out     <= 5'b0;
            ex_mem_read_out    <= 1'b0;
            ex_mem_write_out   <= 1'b0;
            ex_reg_write_out   <= 1'b0;
            ex_mem_to_reg_out  <= 1'b0;
            ex_write_from_pc_out <= 1'b0;
            
            // Clear branch outputs
            ex_branch_taken_out  <= 1'b0;
            ex_branch_target_out <= 32'b0;
            
        end else begin
            // Pass computed and passthrough values forward
            ex_pc_plus_4_out   <= id_pc_plus_4_in;
            ex_alu_result_out  <= alu_result;
            ex_read_data2_out  <= fwd_data_b; 
            ex_rd_addr_out     <= id_rd_addr_in;

            // Forward control signals
            ex_mem_read_out    <= id_mem_read_in;
            ex_mem_write_out   <= id_mem_write_in;
            ex_reg_write_out   <= id_reg_write_in;
            ex_mem_to_reg_out  <= id_mem_to_reg_in;
            ex_write_from_pc_out <= id_write_from_pc_in;
            
            // --- FIX: Register the branch signals ---
            ex_branch_taken_out  <= branch_taken_comb;
            ex_branch_target_out <= branch_target_comb;
        end
    end

    // Debug: Log when performing a register-register ADD to rd==x3
    always @(posedge clk) begin
        if (!rst && id_alu_ctrl_in == 4'h0 && id_alu_src_in == 1'b0 && id_rd_addr_in == 5'd3) begin
            $display("[EX dbg] t=%0t A=%0d B=%0d (rs2=%0d imm=%0d sel=%0b fwd_b=%0b) -> result=%0d", $time, fwd_data_a, alu_mux_out_b, id_read_data2_in, id_immediate_in, id_alu_src_in, forward_b_in, alu_result);
        end
    end

endmodule