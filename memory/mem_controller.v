
// This is a 4-Page main memory
// It provides 4 independent ports, one for each core,
// so there is no contention or need for a complex controller
// this simple mapping of one Page or frame to one core makes a 
// simple memory addresing format
// Each core accesses its own 1KB "page" or "frame".
// - Reads are combinational (asynchronous).
// - Writes are sequential (synchronous, on the cock edge)
//
// This is a byte-addressable memory that handles 32-bit word
// accesses (lw, sw).\

module mem_controller (
    input  wire        clk,
    
    // --- Core 0 Port ---
    input  wire        core0_mem_read_en,
    input  wire        core0_mem_write_en,
    input  wire [31:0] core0_address,   // Virtual address (0x000 - 0xFFF)
    input  wire [31:0] core0_write_data,
    output wire [31:0] core0_read_data,

    // --- Core 1 Port ---
    input  wire        core1_mem_read_en,
    input  wire        core1_mem_write_en,
    input  wire [31:0] core1_address,   // Virtual address (0x000 - 0xFFF)
    input  wire [31:0] core1_write_data,
    output wire [31:0] core1_read_data,

    // --- Core 2 Port ---
    input  wire        core2_mem_read_en,
    input  wire        core2_mem_write_en,
    input  wire [31:0] core2_address,   // Virtual address (0x000 - 0xFFF)
    input  wire [31:0] core2_write_data,
    output wire [31:0] core2_read_data,

    // --- Core 3 Port ---
    input  wire        core3_mem_read_en,
    input  wire        core3_mem_write_en,
    input  wire [31:0] core3_address,   // Virtual address (0x000 - 0xFFF)
    input  wire [31:0] core3_write_data,
    output wire [31:0] core3_read_data
);

    // 4 independent frames of 1K-word memory (4KB) each.
    // Total 4K words (16KB).
    reg [31:0] mem_bank_0 [0:1023];
    reg [31:0] mem_bank_1 [0:1023];
    reg [31:0] mem_bank_2 [0:1023];
    reg [31:0] mem_bank_3 [0:1023];

    // Initialize banks to zero for clean simulation
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            mem_bank_0[i] = 32'b0;
            mem_bank_1[i] = 32'b0;
            mem_bank_2[i] = 32'b0;
            mem_bank_3[i] = 32'b0;
        end
    end

    // Each core's address (0-4095) is indexed
    // by word (bits 11:2) for word based addresing last two bits arent needed
    wire [9:0] core0_word_addr = core0_address[11:2];
    wire [9:0] core1_word_addr = core1_address[11:2];
    wire [9:0] core2_word_addr = core2_address[11:2];
    wire [9:0] core3_word_addr = core3_address[11:2];

    // --- Core 0 ---
    assign core0_read_data = (core0_mem_read_en) ? mem_bank_0[core0_word_addr] : 32'b0;
    always @(posedge clk) begin
        if (core0_mem_write_en) begin
            mem_bank_0[core0_word_addr] <= core0_write_data;
        end
    end

    // --- Core 1 ---
    assign core1_read_data = (core1_mem_read_en) ? mem_bank_1[core1_word_addr] : 32'b0;
    always @(posedge clk) begin
        if (core1_mem_write_en) begin
            mem_bank_1[core1_word_addr] <= core1_write_data;
        end
    end

    // --- Core 2 ---
    assign core2_read_data = (core2_mem_read_en) ? mem_bank_2[core2_word_addr] : 32'b0;
    always @(posedge clk) begin
        if (core2_mem_write_en) begin
            mem_bank_2[core2_word_addr] <= core2_write_data;
        end
    end

    // --- Core 3 ---
    assign core3_read_data = (core3_mem_read_en) ? mem_bank_3[core3_word_addr] : 32'b0;
    always @(posedge clk) begin
        if (core3_mem_write_en) begin
            mem_bank_3[core3_word_addr] <= core3_write_data;
        end
    end

endmodule
