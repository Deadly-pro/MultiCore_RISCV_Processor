// -----------------------------------------------------------------------------
// File: fetch_stage/ins_memory.v
// Purpose: Simple instruction memory (ROM) initialized via $readmemh.
// Params:  MEM_SIZE (words), PROGRAM_FILE (hex file with 32-bit words).
// Access:  Combinational read; address is word-indexed by [11:2].
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//
// ins_memory
//
module ins_memory #(
    parameter MEM_SIZE=1024, 
    parameter PROGRAM_FILE="program.txt"
)
( 
    input wire [31:0] addr,
    output wire [31:0] ins_out 
);

    // Array of registers for the instructions
    reg [31:0] memory[0:MEM_SIZE-1];
    
    // --- Pre-initialize the entire memory ---
    integer i;
    initial begin
        // 1. First, set every word in memory to 0 (NOP)
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            memory[i] = 32'h00000000;
        end
        
        // 2. Now, $readmemh will overwrite the first N lines
        $display("Loading Ins Memory from: %s",PROGRAM_FILE);
        
        // --- FIX: Explicitly tell $readmemh to read from address 0 ---
        // This is a more robust way to call it and should
        // resolve the "Not enough words" warning.
        $readmemh(PROGRAM_FILE, memory, 0); 
    end
    
    // Combinational read
    assign ins_out = memory[addr[11:2]];

endmodule