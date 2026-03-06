// Instruction memory ROM initialized via hex files.
`timescale 1ns / 1ps

module ins_memory #(
    parameter MEM_SIZE = 1024,
    parameter PROGRAM_FILE = "program0.txt"
)(
    input  wire [31:0] addr,
    output wire [31:0] ins_out
);

    reg [31:0] mem [0:MEM_SIZE-1];

    assign ins_out = mem[addr[31:2]];

    initial begin
        $display("Loading Ins Memory from: %s",PROGRAM_FILE);
        $readmemh(PROGRAM_FILE, mem);
    end

endmodule
