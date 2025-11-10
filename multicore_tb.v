`timescale 1ns / 1ps

module multicore_tb;
    reg clk;
    reg rst;

    // Instantiate the entire multicore system
    // Make sure your top-level file is named this!
    multicore_processor dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
   integer core0_x3;
   integer core1_x3;
        
    // Test Sequence
    initial begin
        
        $display("T=0: Multi-Core Testbench Started.");
        rst = 1;
        #20;
        rst = 0;
        $display("T=20: Reset released.");

        // Let it run for 15 cycles
        #150;
        
        $display("T=170: Checking results...");
        
        // --- Check Core 0's result ---
        // Path: tb -> dut -> core0 -> decode_stage -> reg_file_inst -> registers
        // NOTE: The instance names inside multicore_system.v must be core0, core1, etc.
        core0_x3 = dut.core0.decode_stage.rf.registers[3]; // Assign value
        if (core0_x3 == 15)
            $display("Core 0 PASSED! (x3 = %d)", core0_x3);
        else
            $display("Core 0 FAILED! (x3 = %d, expected 15)", core0_x3);

        // --- Check Core 1's result ---
        core1_x3 = dut.core1.decode_stage.rf.registers[3]; // Assign value
        if (core1_x3 == 27)
            $display("Core 1 PASSED! (x3 = %d)", core1_x3);
        else
            $display("Core 1 FAILED! (x3 = %d, expected 27)", core1_x3);

        $display("Simulation finished.");
        $finish;
    end

endmodule