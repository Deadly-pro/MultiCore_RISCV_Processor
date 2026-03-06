// Testbench for the multicore RISC-V system.
`timescale 1ns / 1ps

module multicore_tb;

    reg clk;
    reg rst;

    multicore_processor uut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        $display("=== Starting RISC-V Multicore Simulation ===");
        rst = 1;
        #20;
        rst = 0;
        #600;
        $display("=== Simulation Finished ===");
        $finish;
    end
    
    initial begin
        $dumpfile("multicore.vcd");
        $dumpvars(0, multicore_tb);
    end

endmodule
