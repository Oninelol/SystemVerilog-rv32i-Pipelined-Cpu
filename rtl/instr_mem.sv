import pkg::*;

module instruction_memory(
    input [31:0] addr,
    output [31:0] instr
);

    logic [31:0] mem[1023:0]; // 4KB insruction memory 
    initial $readmemh("test_program.hex",mem); // load the hex program (assembly) into instruction memory
    assign instr = mem[addr[11:2]]; // drop addr[1:0] to divide 4, as mem address indexes incrementes by 1, while pc is incremented by 4
    // drop addr[31:12] as memory is not large enough to use them

endmodule