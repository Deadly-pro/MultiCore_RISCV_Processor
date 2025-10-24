module prog_counter(
input wire clk,
input wire rst,
input wire [31:0] pc_in,
output reg [31:0] pc_out
    );
// this program counter will just pass the input pc addr back to output
// while the actual incrementation is done in the Fetch module itself this PC serves as a 
// means of handling branching of instructions by providing them as input which can be controlled 
// by using a mux and the 'branch' control signal  
 always@(posedge clk)begin
    if(rst) begin
      pc_out<=32'b0;
    end
    else begin
     pc_out<=pc_in;
    end
 end
endmodule
