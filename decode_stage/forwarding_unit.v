`timescale 1ns / 1ps
module forwarding_unit (
    // --- Inputs from EX Stage ---
    // These are the registers the *current* EX instruction wants to READ
    input  wire [4:0]  ex_rs1_addr,
    input  wire [4:0]  ex_rs2_addr,

    // --- Inputs from MEM Stage ---
    // This is the register the *previous* instruction (now in MEM) will WRITE
    input  wire [4:0]  mem_rd_addr,
    input  wire        mem_reg_write, // Is the MEM stage instruction writing to a register?

    // --- Inputs from WB Stage ---
    // This is the register the instruction *before that* (now in WB) will WRITE
    input  wire [4:0]  wb_rd_addr,
    input  wire        wb_reg_write,  // Is the WB stage instruction writing to a register?

    // --- Outputs to EX Stage MUXes ---
    // These signals control the two forwarding MUXes in ins_ex.v
    output reg  [1:0]  forward_a,
    output reg  [1:0]  forward_b
);

    // Forwarding MUX Control Signals:
    // 2'b00:  Use Register File data (from ID/EX register)
    // 2'b01:  Forward from MEM stage (ALU result)
    // 2'b10:  Forward from WB stage (Final write-back data)

    always @(*) begin
        // --- Forwarding Logic for ALU Operand A (rs1) ---
        
        // Default: No forwarding
        forward_a = 2'b00; 

        // 1. Check for EX/MEM Hazard:
        // Does the destination register in MEM stage match the rs1 in EX stage?
        // AND is the MEM stage actually writing to a register?
        // AND is the destination not x0?
        if (mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == ex_rs1_addr)) begin
            forward_a = 2'b01; // Forward from MEM stage
        end
        
        // 2. Check for MEM/WB Hazard:
        // Does the destination register in WB stage match rs1 in EX stage?
        // AND is the WB stage actually writing?
        // AND is the destination not x0?
        // *AND* is it not the *same* hazard we just detected? (MEM has priority)
        else if (wb_reg_write && (wb_rd_addr != 5'b0) && (wb_rd_addr == ex_rs1_addr)) begin
            forward_a = 2'b10; // Forward from WB stage
        end

        // --- Forwarding Logic for ALU Operand B (rs2) ---
        
        // Default: No forwarding
        forward_b = 2'b00;

        // 1. Check for EX/MEM Hazard:
        if (mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == ex_rs2_addr)) begin
            forward_b = 2'b01; // Forward from MEM stage
        end
        
        // 2. Check for MEM/WB Hazard:
        else if (wb_reg_write && (wb_rd_addr != 5'b0) && (wb_rd_addr == ex_rs2_addr)) begin
            forward_b = 2'b10; // Forward from WB stage
        end
    end

endmodule