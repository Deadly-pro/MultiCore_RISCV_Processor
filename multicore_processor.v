// -----------------------------------------------------------------------------
// File: multicore_processor.v
// Purpose: Top-level multi-core RISC-V system.
//          Instantiates 4 riscv_core instances, per-core instruction memories,
//          and a 4-bank data memory (mem_controller).
// Inputs:
//   - clk: clock
//   - rst: synchronous reset
// Notes:
//   - Each core loads its program from program0.txt..program3.txt via ins_memory.
//   - This replaces riscv_core.v as the top-level.
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//
// THIS IS THE NEW TOP-LEVEL DESIGN
// It replaces riscv_core.v as the top.
// It instantiates 4 cores and the memory systems.
//
module multicore_processor(
    input wire clk,
    input wire rst
);

    // --- Core 0 Wires ---
    wire [31:0] core0_imem_addr;
    wire [31:0] core0_imem_data;
    wire        core0_dmem_read;
    wire        core0_dmem_write;
    wire [31:0] core0_dmem_addr;
    wire [31:0] core0_dmem_write_data;
    wire [31:0] core0_dmem_read_data;

    // --- Core 1 Wires ---
    wire [31:0] core1_imem_addr;
    wire [31:0] core1_imem_data;
    wire        core1_dmem_read;
    wire        core1_dmem_write;
    wire [31:0] core1_dmem_addr;
    wire [31:0] core1_dmem_write_data;
    wire [31:0] core1_dmem_read_data;
    
    // --- Core 2 Wires ---
    wire [31:0] core2_imem_addr;
    wire [31:0] core2_imem_data;
    wire        core2_dmem_read;
    wire        core2_dmem_write;
    wire [31:0] core2_dmem_addr;
    wire [31:0] core2_dmem_write_data;
    wire [31:0] core2_dmem_read_data;

    // --- Core 3 Wires ---
    wire [31:0] core3_imem_addr;
    wire [31:0] core3_imem_data;
    wire        core3_dmem_read;
    wire        core3_dmem_write;
    wire [31:0] core3_dmem_addr;
    wire [31:0] core3_dmem_write_data;
    wire [31:0] core3_dmem_read_data;


    // ---------------------------------------------
    // --- 1. Instantiate Instruction Memories ---
    // ---------------------------------------------
    
    ins_memory #(.MEM_SIZE(1024), .PROGRAM_FILE("program0.txt") ) imem0 (
        .addr(core0_imem_addr),
        .ins_out(core0_imem_data)
    );

    ins_memory #(.MEM_SIZE(1024), .PROGRAM_FILE("program1.txt") ) imem1 (
        .addr(core1_imem_addr),
        .ins_out(core1_imem_data)
    );
    
    // (Using program0.txt for cores 2 and 3 for now)
    ins_memory #( .MEM_SIZE(1024),.PROGRAM_FILE("program2.txt") ) imem2 (
        .addr(core2_imem_addr),
        .ins_out(core2_imem_data)
    );
    
    ins_memory #(.MEM_SIZE(1024), .PROGRAM_FILE("program3.txt") ) imem3 (
        .addr(core3_imem_addr),
        .ins_out(core3_imem_data)
    );

    // ---------------------------------------------
    // --- 2. Instantiate 4-Bank Data Memory ---
    // ---------------------------------------------
    
    mem_controller dmem (
        .clk(clk),
        
        // Core 0 Port
        .core0_mem_read_en(core0_dmem_read),
        .core0_mem_write_en(core0_dmem_write),
        .core0_address(core0_dmem_addr),
        .core0_write_data(core0_dmem_write_data),
        .core0_read_data(core0_dmem_read_data),

        // Core 1 Port
        .core1_mem_read_en(core1_dmem_read),
        .core1_mem_write_en(core1_dmem_write),
        .core1_address(core1_dmem_addr),
        .core1_write_data(core1_dmem_write_data),
        .core1_read_data(core1_dmem_read_data),
        
        // Core 2 Port
        .core2_mem_read_en(core2_dmem_read),
        .core2_mem_write_en(core2_dmem_write),
        .core2_address(core2_dmem_addr),
        .core2_write_data(core2_dmem_write_data),
        .core2_read_data(core2_dmem_read_data),
        
        // Core 3 Port
        .core3_mem_read_en(core3_dmem_read),
        .core3_mem_write_en(core3_dmem_write),
        .core3_address(core3_dmem_addr),
        .core3_write_data(core3_dmem_write_data),
        .core3_read_data(core3_dmem_read_data)
    );

    // ---------------------------------------------
    // --- 3. Instantiate Cores ---
    // ---------------------------------------------
    
    riscv_core core0 (
        .clk(clk),
        .rst(rst),
        .imem_address_out(core0_imem_addr),
        .imem_data_in(core0_imem_data),
        .dmem_read_en_out(core0_dmem_read),
        .dmem_write_en_out(core0_dmem_write),
        .dmem_address_out(core0_dmem_addr),
        .dmem_write_data_out(core0_dmem_write_data),
        .dmem_read_data_in(core0_dmem_read_data)
    );

    riscv_core core1 (
        .clk(clk),
        .rst(rst),
        .imem_address_out(core1_imem_addr),
        .imem_data_in(core1_imem_data),
        .dmem_read_en_out(core1_dmem_read),
        .dmem_write_en_out(core1_dmem_write),
        .dmem_address_out(core1_dmem_addr),
        .dmem_write_data_out(core1_dmem_write_data),
        .dmem_read_data_in(core1_dmem_read_data)
    );
    
    riscv_core core2 (
        .clk(clk),
        .rst(rst),
        .imem_address_out(core2_imem_addr),
        .imem_data_in(core2_imem_data),
        .dmem_read_en_out(core2_dmem_read),
        .dmem_write_en_out(core2_dmem_write),
        .dmem_address_out(core2_dmem_addr),
        .dmem_write_data_out(core2_dmem_write_data),
        .dmem_read_data_in(core2_dmem_read_data)
    );
    
    riscv_core core3 (
        .clk(clk),
        .rst(rst),
        .imem_address_out(core3_imem_addr),
        .imem_data_in(core3_imem_data),
        .dmem_read_en_out(core3_dmem_read),
        .dmem_write_en_out(core3_dmem_write),
        .dmem_address_out(core3_dmem_addr),
        .dmem_write_data_out(core3_dmem_write_data),
        .dmem_read_data_in(core3_dmem_read_data)
    );

endmodule