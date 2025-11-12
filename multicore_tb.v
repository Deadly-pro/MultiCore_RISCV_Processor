// -----------------------------------------------------------------------------
// File: multicore_tb.v
// Purpose: Testbench for the multicore_processor top.
//          Generates clock/reset, dumps VCD, runs for a fixed time, and checks
//          selected register results from core0/core1.
// Outputs:
//   - waveform.vcd: dump of the entire DUT for viewing in GTKWave.
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module multicore_tb;
    reg clk;
    reg rst;
    
    // This is the new filename for the waveform
    localparam WAVEFORM_FILE = "waveform.vcd";

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
    integer ins_loaded;   
    
    // --- NEW: Waveform (VCD) Dumping ---
    // This tells Icarus Verilog to record all the signals
    // in your 'dut' and save them to the file defined above.
    // Your old file was missing this block.
    initial begin
        $dumpfile(WAVEFORM_FILE);
        $dumpvars(0, dut); // Dump all signals inside the 'dut'
    end

    // Test Sequence
    initial begin
        
        $display("T=0: Multi-Core Testbench Started.");
        rst = 1;
        #20;
        rst = 0;
        $display("T=20: Reset released.");

        // --- FIX: Run for 250ns ---
        // Your old file ran for #150, which was too short.
        #250; 
        
        // --- FIX: Changed display to match the time ---
        $display("T=270: Checking results..."); // 20ns + 250ns
        
        // --- Check Core 0's result ---
        // Path: tb -> dut -> core0 -> decode_stage -> rf -> registers
        core0_x3 = dut.core0.decode_stage.rf.registers[3]; 
        
        $display("Checking Fetch...");
        ins_loaded = dut.core0.if_id.id_instruction_out;
        
        if (core0_x3 == 15)
            $display("Core 0 PASSED! (x3 = %d)", core0_x3);
        else
            $display("Core 0 FAILED! (x3 = %d, expected 15)", core0_x3);

        // --- Check Core 1's result ---
        core1_x3 = dut.core1.decode_stage.rf.registers[3];
        if (core1_x3 == 27)
            $display("Core 1 PASSED! (x3 = %d)", core1_x3);
        else
            $display("Core 1 FAILED! (x3 = %d, expected 27)", core1_x3);

        $display("Simulation finished.");
        $finish;
    end

endmodule