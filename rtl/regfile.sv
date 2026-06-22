import pkg::*;

module register_file{
    input clk;
    input rst;
    input logic reg_write;
    input [4:0] rs1;
    output [31:0] read_data1;
    input [4:0] rs2;
    output [31:0] read_data2;
    input [4:0] rd;
    input [31:0] write_data;
}

    [31:0] regs [31:0]; // 32 Registers that are each 32 bit wide in regfile

    always_ff @(posedge clk) begin

    end

endmodule