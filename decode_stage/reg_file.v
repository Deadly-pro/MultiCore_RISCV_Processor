
// -----------------------------------------------------------------------------
// File: decode_stage/reg_file.v
// Purpose: RV32I 32x32 register file with 2 read ports and 1 write port.
// Behavior: x0 is hardwired to 0; writes to x0 are ignored. Sync reset.
// -----------------------------------------------------------------------------
module reg_file (
    input  wire        clk,
    input  wire        rst,

    input  wire [4:0]  read_addr1,
    output wire [31:0] read_data1,

    input  wire [4:0]  read_addr2,
    output wire [31:0] read_data2,

    input  wire [4:0]  write_addr,
    input  wire [31:0] write_data,
    input  wire        write_enable // This is the 'RegWrite' control signal
);
    integer i;
    reg [31:0] registers [0:31];
    assign read_data1 = (read_addr1 == 5'b0) ? 32'b0 : registers[read_addr1];
    assign read_data2 = (read_addr2 == 5'b0) ? 32'b0 : registers[read_addr2];
    always @(posedge clk or posedge rst) begin
       if(rst)begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end 
        else begin
            // Only write if enabled AND the destination is NOT x0.
            if (write_enable && (write_addr != 5'b0)) begin
                registers[write_addr] <= write_data;
            end
        end
    end

endmodule
