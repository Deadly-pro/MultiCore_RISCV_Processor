module ins_decode(
    input  wire        clk,
    input  wire        rst,
    
    // --- Inputs from IF/ID Register ---
    input  wire [31:0] ins_in,
    input  wire [31:0] pc_plus_4_in,

    // --- Inputs from EX Stage (for Hazard Unit) ---
    input  wire [4:0]  ex_rd_addr_in,
    input  wire        ex_mem_read_in,

    // --- Inputs from WB Stage (for reg_file write) ---
    input  wire [4:0]  wb_write_addr_in,
    input  wire [31:0] wb_write_data_in,
    input  wire        wb_reg_write_en_in,

    // --- Stall signal (output from hazard unit) ---
    output wire        pipeline_stall_out,

    // --- Outputs to ID/EX Register ---
    output wire [31:0] id_pc_plus_4_out,
    output wire [31:0] id_read_data1_out,
    output wire [31:0] id_read_data2_out,
    output wire [31:0] id_immediate_out,
    output wire [4:0]  id_rs1_addr_out,
    output wire [4:0]  id_rs2_addr_out,
    output wire [4:0]  id_rd_addr_out,
    
    // --- Control Signals to ID/EX Register ---
    output wire        id_mem_read_out,
    output wire        id_mem_write_out,
    output wire        id_reg_write_out,
    output wire        id_mem_to_reg_out,
    output wire        id_alu_src_out,
    output wire        id_branch_out,
    output wire [3:0]  id_alu_ctrl_out
);

    // --- Instruction Field Wires ---
    assign id_rs1_addr_out = ins_in[19:15];
    assign id_rs2_addr_out = ins_in[24:20];
    assign id_rd_addr_out  = ins_in[11:7];

    // Pass-through PC+4 (it's needed for JAL/JALR writeback)
    assign id_pc_plus_4_out = pc_plus_4_in;


    // --- Register File (reg_file.v) ---
    reg_file rf (
        .clk(clk),
        .rst(rst),
        .read_addr1(id_rs1_addr_out),
        .read_data1(id_read_data1_out), // Output to ID/EX
        .read_addr2(id_rs2_addr_out),
        .read_data2(id_read_data2_out), // Output to ID/EX
        
        // Write ports are connected to the WB stage signals
        .write_addr(wb_write_addr_in),
        .write_data(wb_write_data_in),
        .write_enable(wb_reg_write_en_in)
    );

    // --- Immediate Generator (imm_gen.v) ---
    imm_gen im (
        .instruction(ins_in),
        .immediate_out(id_immediate_out) // Output to ID/EX
    );

    // --- Control Unit (control_unit.v) ---
    control_unit cu (
        .instr(ins_in),
        
        // Connect control outputs directly to the stage outputs
        .RegWrite(id_reg_write_out),
        .MemRead(id_mem_read_out),
        .MemWrite(id_mem_write_out),
        .MemToReg(id_mem_to_reg_out),
        .ALUSrc(id_alu_src_out),
        .Branch(id_branch_out),
        .ALUCtrl(id_alu_ctrl_out)
    );

    // --- Hazard Unit (hazard_unit.v) ---
    hazard_unit hu (
        .id_rs1_addr(id_rs1_addr_out),
        .id_rs2_addr(id_rs2_addr_out),
        .ex_rd_addr(ex_rd_addr_in),   // From EX Stage
        .ex_mem_read(ex_mem_read_in), // From EX Stage
        .pipeline_stall(pipeline_stall_out) // Output to pipeline regs
    );

endmodule
