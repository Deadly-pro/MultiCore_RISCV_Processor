module if_id_buffer (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] if_ins_in,
    input  wire [31:0] if_pc_plus_4_in,
    output reg  [31:0] id_ins_out,
    output reg  [31:0] id_pc_plus_4_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            id_ins_out <= 32'h00000013; 
            id_pc_plus_4_out   <= 32'b0;
        end else begin
            id_ins_out <= if_ins_in;
            id_pc_plus_4_out   <= if_pc_plus_4_in;
        end
    end

endmodule
