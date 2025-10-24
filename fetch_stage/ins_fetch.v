module ins_fetch(
input wire clk,
input wire rst,
input wire  [31:0] pc_in,
output wire [31:0] ins_out,
output wire [31:0] pc_out

);
// here we handle the fetching of the instructions 
// from instrction memeory
prog_counter pc_reg(
.clk(clk),
.rst(rst),
.pc_in(pc_in),
.pc_out(pc_out)
);
// to create instruction memeory instance 
ins_memeory i_mem(
.addr(pc_out),
.ins_out(ins_out));
// increment the pc 
assign pc_out=pc_out+32'd4;
endmodule;