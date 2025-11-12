    `timescale 1ns / 1ps
    //
    // It contains the full 5-stage pipeline with FORWARDING.
    //
    module riscv_core (
        input  wire        clk,
        input  wire        rst,
        
        // --- Instruction Memory Interface ---
        output wire [31:0] imem_address_out, // PC
        input  wire [31:0] imem_data_in,     // Instruction
        
        // --- Data Memory Interface ---
        output wire        dmem_read_en_out,
        output wire        dmem_write_en_out,
        output wire [31:0] dmem_address_out,
        output wire [31:0] dmem_write_data_out,
        input  wire [31:0] dmem_read_data_in
    );

        // -------------------------------------------------------------------------
        // --- PC CONTROL LOGIC (Part of IF) ---
        // -------------------------------------------------------------------------
        wire [31:0] next_pc;
        wire [31:0] curr_pc;
        wire [31:0] pc_plus_4;
        wire        pipeline_stall;
        wire        branch_taken;
        wire [31:0] branch_target;

        prog_counter pc_reg (
            .clk(clk),
            .rst(rst),
            .pc_in(next_pc),
            .pc_out(curr_pc)
        );

        assign next_pc = (branch_taken)     ? branch_target :
                        (pipeline_stall)   ? curr_pc :
                        pc_plus_4;
                        
        assign imem_address_out = curr_pc; // The PC is the address for IMEM

        // -------------------------------------------------------------------------
        // --- STAGE 1: INSTRUCTION FETCH (IF) ---
        // -------------------------------------------------------------------------
        wire [31:0] if_instruction_in;
                
        ins_fetch fetch_stage (
            .clk(clk),
            .rst(rst),
            .pc_in(curr_pc),
            .instruction_in(imem_data_in),    // From external port
            .pc_plus_4_out(pc_plus_4),
            .instruction_out(if_instruction_in)
        );

        // -------------------------------------------------------------------------
        // --- IF/ID PIPELINE REGISTER ---
        // -------------------------------------------------------------------------
        wire [31:0] id_instruction_in;
        wire [31:0] id_pc_plus_4_in;
        wire [31:0] id_pc_in;

        if_id_buffer if_id (
            .clk(clk),
            .rst(rst),
            .pipeline_stall(pipeline_stall),
            .if_instruction_in(if_instruction_in), // Use fetch-stage output
            .if_pc_plus_4_in(pc_plus_4),
            .if_pc_in(curr_pc),
            .id_instruction_out(id_instruction_in),
            .id_pc_plus_4_out(id_pc_plus_4_in),
            .id_pc_out(id_pc_in)
        );

        // -------------------------------------------------------------------------
        // --- STAGE 2: INSTRUCTION DECODE (ID) ---
        // -------------------------------------------------------------------------
        wire [31:0] id_pc_plus_4_out;
        wire [31:0] id_pc_out_pass;
        wire [31:0] id_read_data1_out;
        wire [31:0] id_read_data2_out;
        wire [31:0] id_immediate_out;
        wire [4:0]  id_rs1_addr_out;
        wire [4:0]  id_rs2_addr_out;
        wire [4:0]  id_rd_addr_out;
        wire [31:0] id_instruction_debug_out;
        wire        id_mem_read_out;
        wire        id_mem_write_out;
        wire        id_reg_write_out;
        wire        id_mem_to_reg_out;
        wire        id_alu_src_out;
        wire        id_branch_out;
        wire [3:0]  id_alu_ctrl_out;
        wire        id_write_from_pc_out;
        
        // Feedback signals for Hazard/WB
        wire [4:0]  ex_rd_feedback;
        wire        ex_mem_read_feedback;
        wire [4:0]  wb_rd_feedback;
        wire [31:0] wb_write_data_feedback;
        wire        wb_reg_write_feedback;

        ins_decode decode_stage (
            .clk(clk),
            .rst(rst),
            .id_instruction_in(id_instruction_in),
            .id_pc_plus_4_in(id_pc_plus_4_in),
            .id_pc_in(id_pc_in),
            .ex_rd_addr_in(ex_rd_feedback),
            .ex_mem_read_in(ex_mem_read_feedback),
            .wb_write_addr_in(wb_rd_feedback),
            .wb_write_data_in(wb_write_data_feedback),
            .wb_reg_write_en_in(wb_reg_write_feedback),
            .pipeline_stall_out(pipeline_stall),
            .id_pc_plus_4_out(id_pc_plus_4_out),
            .id_pc_out(id_pc_out_pass),
            .id_read_data1_out(id_read_data1_out),
            .id_read_data2_out(id_read_data2_out),
            .id_immediate_out(id_immediate_out),
            .id_rs1_addr_out(id_rs1_addr_out),
            .id_rs2_addr_out(id_rs2_addr_out),
            .id_rd_addr_out(id_rd_addr_out),
            .id_instruction_out(id_instruction_debug_out),
            .id_mem_read_out(id_mem_read_out),
            .id_mem_write_out(id_mem_write_out),
            .id_reg_write_out(id_reg_write_out),
            .id_mem_to_reg_out(id_mem_to_reg_out),
            .id_alu_src_out(id_alu_src_out),
            .id_branch_out(id_branch_out),
            .id_alu_ctrl_out(id_alu_ctrl_out),
            .id_write_from_pc_out(id_write_from_pc_out)
        );

        // -------------------------------------------------------------------------
        // --- ID/EX PIPELINE REGISTER ---
        // -------------------------------------------------------------------------
        wire [31:0] ex_pc_plus_4_in;
        wire [31:0] ex_pc_in;
        wire [31:0] ex_read_data1_in;
        wire [31:0] ex_read_data2_in;
        wire [31:0] ex_immediate_in;
        wire [4:0]  ex_rs1_addr_in;
        wire [4:0]  ex_rs2_addr_in;
        wire [4:0]  ex_rd_addr_in;
        wire [31:0] ex_instruction_in;
        wire        ex_mem_read_in;
        wire        ex_mem_write_in;
        wire        ex_reg_write_in;
        wire        ex_mem_to_reg_in;
        wire        ex_alu_src_in;
        wire        ex_branch_in;
        wire [3:0]  ex_alu_ctrl_in;
        wire        ex_write_from_pc_in;

        id_ex_buffer id_ex (
            .clk(clk),
            .rst(rst),
            .pipeline_stall(pipeline_stall),
            .id_pc_plus_4_in(id_pc_plus_4_out),
            .id_pc_in(id_pc_out_pass),
            .id_read_data1_in(id_read_data1_out),
            .id_read_data2_in(id_read_data2_out),
            .id_immediate_in(id_immediate_out),
            .id_rs1_addr_in(id_rs1_addr_out),
            .id_rs2_addr_in(id_rs2_addr_out),
            .id_rd_addr_in(id_rd_addr_out),
            .id_instruction_in(id_instruction_debug_out),
            .id_mem_read_in(id_mem_read_out),
            .id_mem_write_in(id_mem_write_out),
            .id_reg_write_in(id_reg_write_out),
            .id_MemToReg_in(id_mem_to_reg_out),
            .id_ALUSrc_in(id_alu_src_out),
            .id_Branch_in(id_branch_out),
            .id_ALUCtrl_in(id_alu_ctrl_out),
            .id_WriteFromPC_in(id_write_from_pc_out),
            .ex_pc_plus_4_out(ex_pc_plus_4_in),
            .ex_pc_out(ex_pc_in),
            .ex_read_data1_out(ex_read_data1_in),
            .ex_read_data2_out(ex_read_data2_in),
            .ex_immediate_out(ex_immediate_in),
            .ex_rs1_addr_out(ex_rs1_addr_in),
            .ex_rs2_addr_out(ex_rs2_addr_in),
            .ex_rd_addr_out(ex_rd_addr_in),
            .ex_instruction_out(ex_instruction_in),
            .ex_mem_read_out(ex_mem_read_in),
            .ex_mem_write_out(ex_mem_write_in),
            .ex_reg_write_out(ex_reg_write_in),
            .ex_MemToReg_out(ex_mem_to_reg_in),
            .ex_ALUSrc_out(ex_alu_src_in),
            .ex_Branch_out(ex_branch_in),
            .ex_ALUCtrl_out(ex_alu_ctrl_in),
            .ex_WriteFromPC_out(ex_write_from_pc_in)
        );

        // -------------------------------------------------------------------------
        // --- STAGE 3: EXECUTE (EX) ---
        // -------------------------------------------------------------------------
        wire [31:0] ex_pc_plus_4_out;
        wire [31:0] ex_alu_result_out;
        wire [31:0] ex_read_data2_out;
        wire [4:0]  ex_rd_addr_out;
        wire        ex_mem_read_out;
        wire        ex_mem_write_out;
        wire        ex_reg_write_out;
        wire        ex_mem_to_reg_out;
        wire        ex_write_from_pc_out;
        
        // --- NEW: Wires for Forwarding Unit ---
        wire [1:0]  forward_a;
        wire [1:0]  forward_b;
        wire [31:0] mem_forward_data;
        wire [31:0] wb_forward_data;

        ins_ex ex_stage (
            .clk(clk),
            .rst(rst),
            .id_pc_plus_4_in(ex_pc_plus_4_in),
            .id_pc_in(ex_pc_in),
            .id_read_data1_in(ex_read_data1_in),
            .id_read_data2_in(ex_read_data2_in),
            .id_immediate_in(ex_immediate_in),
            .id_rd_addr_in(ex_rd_addr_in),
            
            // --- NEW: Forwarding Ports ---
            .mem_forward_data_in(mem_forward_data),
            .wb_forward_data_in(wb_forward_data),
            .forward_a_in(forward_a),
            .forward_b_in(forward_b),

            .id_mem_read_in(ex_mem_read_in),
            .id_mem_write_in(ex_mem_write_in),
            .id_reg_write_in(ex_reg_write_in),
            .id_mem_to_reg_in(ex_mem_to_reg_in),
            .id_branch_in(ex_branch_in),
            .id_alu_src_in(ex_alu_src_in),
            .id_alu_ctrl_in(ex_alu_ctrl_in),
            .id_write_from_pc_in(ex_write_from_pc_in),
            .ex_pc_plus_4_out(ex_pc_plus_4_out),
            .ex_alu_result_out(ex_alu_result_out),
            .ex_read_data2_out(ex_read_data2_out),
            .ex_rd_addr_out(ex_rd_addr_out),
            .ex_mem_read_out(ex_mem_read_out),
            .ex_mem_write_out(ex_mem_write_out),
            .ex_reg_write_out(ex_reg_write_out),
            .ex_mem_to_reg_out(ex_mem_to_reg_out),
            .ex_write_from_pc_out(ex_write_from_pc_out),
            .ex_branch_taken_out(branch_taken),
            .ex_branch_target_out(branch_target)
        );

        // -------------------------------------------------------------------------
        // --- EX/MEM PIPELINE REGISTER ---
        // -------------------------------------------------------------------------
        wire [31:0] ma_pc_plus_4_out;
        wire [31:0] ma_alu_result_out;
        wire [31:0] ma_write_data_out;
        wire [4:0]  ma_rd_addr_out;
        wire        ma_mem_read_out;
        wire        ma_mem_write_out;
        wire        ma_reg_write_out;
        wire        ma_mem_to_reg_out;
        wire        ma_write_from_pc_out;

        ex_ma_buffer ex_ma (
            .clk(clk),
            .rst(rst),
            .ex_pc_plus_4_in(ex_pc_plus_4_out),
            .ex_alu_result_in(ex_alu_result_out),
            .ex_read_data2_in(ex_read_data2_out),
            .ex_rd_addr_in(ex_rd_addr_out),
            .ex_mem_read_in(ex_mem_read_out),
            .ex_mem_write_in(ex_mem_write_out),
            .ex_reg_write_in(ex_reg_write_out),
            .ex_mem_to_reg_in(ex_mem_to_reg_out),
            .ex_branch_in(1'b0), // Branch is handled in EX
            .ex_write_from_pc_in(ex_write_from_pc_out),
            .ma_pc_plus_4_out(ma_pc_plus_4_out),
            .ma_alu_result_out(ma_alu_result_out),
            .ma_write_data_out(ma_write_data_out),
            .ma_rd_addr_out(ma_rd_addr_out),
            .ma_mem_read_out(ma_mem_read_out),
            .ma_mem_write_out(ma_mem_write_out),
            .ma_reg_write_out(ma_reg_write_out),
            .ma_mem_to_reg_out(ma_mem_to_reg_out),
            .ma_write_from_pc_out(ma_write_from_pc_out)
        );

        // --- Feedback for Hazard Unit ---
        assign ex_rd_feedback       = ma_rd_addr_out;
        assign ex_mem_read_feedback = ma_mem_read_out;

        // -------------------------------------------------------------------------
        // --- STAGE 4: MEMORY (MEM) ---
        // -------------------------------------------------------------------------
        wire [31:0] mem_alu_result_to_wb;
        wire [31:0] mem_read_data_to_wb;
        wire [4:0]  mem_rd_addr_to_wb;
        wire [31:0] mem_pc_plus_4_to_wb;
        wire        mem_reg_write_to_wb;
        wire        mem_mem_to_reg_to_wb;
        wire        mem_write_from_pc_to_wb;

        ins_mem mem_stage (
            .clk(clk),
            .rst(rst),
            .alu_result_in(ma_alu_result_out),
            .rs2_data_in(ma_write_data_out),
            .rd_addr_in(ma_rd_addr_out),
            .pc_plus_4_in(ma_pc_plus_4_out),
            .mem_read_in(ma_mem_read_out),
            .mem_write_in(ma_mem_write_out),
            .reg_write_in(ma_reg_write_out),
            .mem_to_reg_in(ma_mem_to_reg_out),
            .write_from_pc_in(ma_write_from_pc_out),
            
            // Connect to Data Memory Ports
            .mem_read_data_in(dmem_read_data_in),
            .mem_address_out(dmem_address_out),
            .mem_write_data_out(dmem_write_data_out),
            .mem_read_en_out(dmem_read_en_out),
            .mem_write_en_out(dmem_write_en_out),
            
            // Outputs to MEM/WB Register
            .alu_result_out(mem_alu_result_to_wb),
            .read_data_out(mem_read_data_to_wb),
            .rd_addr_out(mem_rd_addr_to_wb),
            .pc_plus_4_out(mem_pc_plus_4_to_wb),
            .reg_write_out(mem_reg_write_to_wb),
            .mem_to_reg_out(mem_mem_to_reg_to_wb),
            .write_from_pc_out(mem_write_from_pc_to_wb)
        );
            
        // -------------------------------------------------------------------------
        // --- MEM/WB PIPELINE REGISTER ---
        // -------------------------------------------------------------------------
        wire [31:0] wb_alu_result_in;
        wire [31:0] wb_read_data_in;
        wire [4:0]  wb_rd_addr_in;
        wire [31:0] wb_pc_plus_4_in;
        wire        wb_reg_write_in;
        wire        wb_mem_to_reg_in;
        wire        wb_write_from_pc_in;

        mem_wb_buffer mem_wb (
            .clk(clk),
            .rst(rst),
            .mem_alu_result_in(mem_alu_result_to_wb),
            .mem_read_data_in(mem_read_data_to_wb),
            .mem_rd_addr_in(mem_rd_addr_to_wb),
            .mem_pc_plus_4_in(mem_pc_plus_4_to_wb),
            .mem_reg_write_in(mem_reg_write_to_wb),
            .mem_mem_to_reg_in(mem_mem_to_reg_to_wb),
            .mem_write_from_pc_in(mem_write_from_pc_to_wb),
            .wb_alu_result_out(wb_alu_result_in),
            .wb_read_data_out(wb_read_data_in),
            .wb_rd_addr_out(wb_rd_addr_in),
            .wb_pc_plus_4_out(wb_pc_plus_4_in),
            .wb_reg_write_out(wb_reg_write_in),
            .wb_mem_to_reg_out(wb_mem_to_reg_in),
            .wb_write_from_pc_out(wb_write_from_pc_in)
        );

        // -------------------------------------------------------------------------
        // --- STAGE 5: WRITE BACK (WB) ---
        // -------------------------------------------------------------------------
        
        // The WB stage is now a module that selects the final
        // data and provides the feedback signals.
        ins_wb wb_stage (
            .clk(clk),
            .rst(rst),
            .alu_result_in(wb_alu_result_in),
            .read_data_in(wb_read_data_in),
            .pc_plus_4_in(wb_pc_plus_4_in),
            .rd_addr_in(wb_rd_addr_in),
            .reg_write_in(wb_reg_write_in),
            .mem_to_reg_in(wb_mem_to_reg_in),
            .write_from_pc_in(wb_write_from_pc_in),
            
            .wb_write_data_out(wb_write_data_feedback),
            .wb_rd_addr_out(wb_rd_feedback),
            .wb_reg_write_en_out(wb_reg_write_feedback)
        );
        
        // -------------------------------------------------------------------------
        // --- NEW: FORWARDING UNIT INSTANTIATION ---
        // -------------------------------------------------------------------------
        
        // Define the data to be forwarded
        assign mem_forward_data = ma_alu_result_out; // Data from EX/MEM buffer
        assign wb_forward_data  = wb_write_data_feedback; // Data from WB stage
        
        forwarding_unit fwd_unit (
            // EX stage read addresses (from ID/EX buffer)
            .ex_rs1_addr(ex_rs1_addr_in),
            .ex_rs2_addr(ex_rs2_addr_in),
            
            // MEM stage write info (from EX/MEM buffer)
            .mem_rd_addr(ma_rd_addr_out),
            .mem_reg_write(ma_reg_write_out),
            
            // WB stage write info (from MEM/WB buffer)
            .wb_rd_addr(wb_rd_addr_in),
            .wb_reg_write(wb_reg_write_in),
            
            // Forwarding control signals (to EX stage)
            .forward_a(forward_a),
            .forward_b(forward_b)
        );

    endmodule