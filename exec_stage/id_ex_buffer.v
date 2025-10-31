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
    
    // Control Signals from Control Unit
    input  wire        id_mem_read_in,
    input  wire        id_mem_write_in,
    input  wire        id_reg_write_in,
    // ... (and all other control signals like ALUSrc, ALUOp) ...

    // --- Outputs to EX Stage ---
    output reg  [31:0] ex_pc_plus_4_out,
    output reg  [31:0] ex_read_data1_out,
    output reg  [31:0] ex_read_data2_out,
    output reg  [31:0] ex_immediate_out,
    output reg  [4:0]  ex_rs1_addr_out,
    output reg  [4:0]  ex_rs2_addr_out,
    output reg  [4:0]  ex_rd_addr_out,
    
    // Control Signals to EX Stage
    output reg         ex_mem_read_out,
    output reg         ex_mem_write_out,
    output reg         ex_reg_write_out
    // ... (and all other control signals) ...
);

    // All control signals for a NOP (No-Operation)
    // A NOP writes nothing, reads nothing, and does nothing.
    localparam NOP_CONTROLS = 1'b0; // (expand this as you add signals)

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, clear everything (which is a NOP)
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
            
        end else if (pipeline_stall) begin
            // --- STALL ---
            // Keep all current output values. Do not load new data.
            // (This is why we use 'reg' for the outputs)
            // Verilog: no 'else' means the registers hold their value.
            
        end else begin
            // --- Normal Operation ---
            // Load all inputs from the ID stage.
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
        end
    end

endmodule
