`timescale 1ns / 1ps

// This is now a SEQUENTIAL module, as requested.
module ins_ex (
    input  wire        clk,
    input  wire        rst,

    // --- Inputs from ID/EX Register ---
    input  wire [31:0] id_pc_plus_4_in,
    input  wire [31:0] id_read_data1_in,
    input  wire [31:0] id_read_data2_in,
    input  wire [31:0] id_immediate_in,
    input  wire [4:0]  id_rd_addr_in,
    
    // Control signals
    input  wire        id_mem_read_in,
    input  wire        id_mem_write_in,
    input  wire        id_reg_write_in,
    input  wire        id_mem_to_reg_in,
    input  wire        id_branch_in,
    input  wire        id_alu_src_in,
    input  wire [3:0]  id_alu_ctrl_in,

    // --- Outputs (to be latched in EX/MEM register) ---
    output reg  [31:0] ex_pc_plus_4_out,
    output reg  [31:0] ex_alu_result_out,
    output reg  [31:0] ex_read_data2_out, // Changed from id_read_data2_in
    output reg  [4:0]  ex_rd_addr_out,

    // --- Control outputs forwarded to EX/MEM ---
    output reg         ex_mem_read_out,
    output reg         ex_mem_write_out,
    output reg         ex_reg_write_out,
    output reg         ex_mem_to_reg_out,
    output reg         ex_branch_out
);

    // --- Internal wires for ALU path ---
    wire [31:0] alu_mux_out;
    wire [31:0] alu_result;

    // Instantiate ALU source mux (select between rs2 and immediate)
    ALU_SRC_MUX alu_src_mux_inst (
        .rs2    (id_read_data2_in),
        .imm    (id_immediate_in),
        .alu_src(id_alu_src_in),
        .mux_out(alu_mux_out)
    );

    // Instantiate ALU (A = rs1, B = mux_out)
    ALU alu_inst (
        .A          (id_read_data1_in),
        .B          (alu_mux_out),
        .ALU_control(id_alu_ctrl_in),
        .result     (alu_result)
    );

    // Latch outputs into EX/MEM register on clock edge
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
            ex_branch_out      <= 1'b0;
        end else begin
            // Pass computed and passthrough values forward
            ex_pc_plus_4_out   <= id_pc_plus_4_in;
            ex_alu_result_out  <= alu_result;       // ALU result computed combinationally
            ex_read_data2_out  <= id_read_data2_in; // value to store (for mem write)
            ex_rd_addr_out     <= id_rd_addr_in;

            // Forward control signals
            ex_mem_read_out    <= id_mem_read_in;
            ex_mem_write_out   <= id_mem_write_in;
            ex_reg_write_out   <= id_reg_write_in;
            ex_mem_to_reg_out  <= id_mem_to_reg_in;
            ex_branch_out      <= id_branch_in;
        end
    end

endmodule