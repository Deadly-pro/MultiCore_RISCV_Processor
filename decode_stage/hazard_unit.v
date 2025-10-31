module hazard_unit (
    // Inputs from ID Stage (current instruction)
    input  wire [4:0] id_rs1_addr,
    input  wire [4:0] id_rs2_addr,

    // Inputs from EX Stage (from the id_ex_register)
    input  wire [4:0] ex_rd_addr,    // Destination register in EX stage
    input  wire       ex_mem_read, // Is the instruction in EX a LOAD?

    // Outputs to control the pipeline
    output wire       pipeline_stall //Tells PC, IF/ID, and ID/EX to stall
);

    // --- Load-Use Hazard Detection Logic ---
    assign pipeline_stall = ex_mem_read && // If instr in EX is a LOAD
                            (ex_rd_addr != 5'b0) &&    // and it's not writing to x0
                            ( (ex_rd_addr == id_rs1_addr) || // and if rd in exec is src1 of decode
                              (ex_rd_addr == id_rs2_addr) ); // or if rd in exec is src2 of decode

endmodule
