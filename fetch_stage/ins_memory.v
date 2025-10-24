// this module will fetch the required instructions per core of the cpu
// in the simulation we will be reading from the .txt file from which we will seperate the work load back to this 
// module which will load the instrcutions required for the core its a prt of 
module ins_memory #(
parameter MEM_SIZE=1024, // 1024 word memeory for one core 
parameter TEMP_PROG="program.txt"// temporary .txt file to test single core 
)
( input wire [31:0] addr,
  output wire [31:0] ins_out );
// to make an array of registers for the instructions to be loaded onto
reg [31:0] memory[0:MEM_SIZE-1];
// for testing of single stage cpu with .txt file load the memeory with the machine code from .txt file
initial begin
    $display("Loading ins Memory from: %s",TEMP_PROG);
    $readmemh(TEMP_PROG,memory);
    end
 // now to provide the fetched instruction back to the output
 assign ins_out = memory[addr[11:2]];
 // 11:2 since the memory is word addressed and PC is byte addressed since
 // we only load one instruction and it has to be formatted to be a multiple of a 4 byte addr
 // we can slice the segment of the addr we need by this method 
endmodule
