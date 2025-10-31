module id_ex_buffer(
    input  wire        clk,
    input  wire        rst,
    // Stall/Bubble controls from Hazard Unit
    input  wire        pipeline_stall, // 1 = Stall (keep current values)

    // --- Inputs from ID Stage ---
    input  wire [31:0] id_pc_plus_4_in,
    input  wire [31:0] id_read_data1_in,
    input  wire [31:0] id_read_data2_in,
    input  wire [31:0] id_immediate_in,
    input  wire [4:0]  id_rs1_addr_in,
    input  wire [4:0]  id_rs2_addr_in,
    input  wire [4:0]  id_rd_addr_in,

    // Control Signals from Control Unit (inputs)
    input  wire        id_mem_read_in,
    input  wire        id_mem_write_in,
    input  wire        id_reg_write_in,
    input  wire        id_MemToReg_in,
    input  wire        id_ALUSrc_in,     // 0 -> reg2, 1 -> immediate
    input  wire        id_Branch_in,     // generic branch indicator
    input  wire [3:0]  id_ALUCtrl_in,    // ALU operation code

    // --- Outputs to EX Stage ---
    output reg  [31:0] ex_pc_plus_4_out,
    output reg  [31:0] ex_read_data1_out,
    output reg  [31:0] ex_read_data2_out,
    output reg  [31:0] ex_immediate_out,
    output reg  [4:0]  ex_rs1_addr_out,
    output reg  [4:0]  ex_rs2_addr_out,
    output reg  [4:0]  ex_rd_addr_out,

    // Control Signals to EX Stage (registered)
    output reg         ex_mem_read_out,
    output reg         ex_mem_write_out,
    output reg         ex_reg_write_out,
    output reg         ex_MemToReg_out,
    output reg         ex_ALUSrc_out,
    output reg         ex_Branch_out,
    output reg  [3:0]  ex_ALUCtrl_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_pc_plus_4_out  <= 32'b0;
            ex_read_data1_out <= 32'b0;
            ex_read_data2_out <= 32'b0;
            ex_immediate_out  <= 32'b0;
            ex_rs1_addr_out   <= 5'b0;
            ex_rs2_addr_out   <= 5'b0;
            ex_rd_addr_out    <= 5'b0;

            ex_mem_read_out   <= 1'b0;
            ex_mem_write_out  <= 1'b0;
            ex_reg_write_out  <= 1'b0;
            ex_MemToReg_out   <= 1'b0;
            ex_ALUSrc_out     <= 1'b0;
            ex_Branch_out     <= 1'b0;
            ex_ALUCtrl_out    <= 4'b0000;
        end else if (pipeline_stall) begin
            // Hold current outputs (stall): do nothing so registers keep previous value
        end else begin
            // Normal: capture inputs from ID stage
            ex_pc_plus_4_out  <= id_pc_plus_4_in;
            ex_read_data1_out <= id_read_data1_in;
            ex_read_data2_out <= id_read_data2_in;
            ex_immediate_out  <= id_immediate_in;
            ex_rs1_addr_out   <= id_rs1_addr_in;
            ex_rs2_addr_out   <= id_rs2_addr_in;
            ex_rd_addr_out    <= id_rd_addr_in;

            ex_mem_read_out   <= id_mem_read_in;
            ex_mem_write_out  <= id_mem_write_in;
            ex_reg_write_out  <= id_reg_write_in;
            ex_MemToReg_out   <= id_MemToReg_in;
            ex_ALUSrc_out     <= id_ALUSrc_in;
            ex_Branch_out     <= id_Branch_in;
            ex_ALUCtrl_out    <= id_ALUCtrl_in;
        end
    end

endmodule
