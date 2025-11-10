`timescale 1ns / 1ps
// This is the single-bank data memory for the single-core design.
// It is used by the MEM stage for lw and sw instructions.

module data_mem (
    input  wire        clk,
    
    // --- Control ---
    input  wire        mem_read,  // 1 = Read request (from ins_mem)
    input  wire        mem_write, // 1 = Write request (from ins_mem)
    
    // --- Address/Data ---
    input  wire [31:0] address,   // Address for read or write (from ins_mem)
    input  wire [31:0] write_data, // Data to write (for sw)
    
    output wire [31:0] read_data   // Data read from memory (for lw)
);

    // 1K-word memory (4KB). 
    // This will be synthesized as a Block RAM (BRAM).
    reg [31:0] mem [0:1023];

    // We index the memory by *word* address (addr[11:2])
    // because the PC is byte-addressed.
    wire [9:0] word_address = address[11:2];

    // --- Read Logic (Combinational/Asynchronous) ---
    // The data is available on the same cycle as the address.
    assign read_data = mem[word_address];
    
    // --- Write Logic (Sequential/Synchronous) ---
    // Data is written only on the rising edge of the clock
    // if mem_write is high.
    always @(posedge clk) begin
        if (mem_write) begin
            mem[word_address] <= write_data;
        end
    end

    // --- Simulation Helper ---
    // This initial block initializes all memory to 0
    // to prevent 'X' (unknown) values at the start of simulation.
    // This is not synthesizable but is very useful for testing.
    initial begin
        integer i;
        for (i = 0; i < 1024; i = i + 1) begin
            mem[i] = 32'b0;
        end
    end

endmodule