import pkg::*;

module register_file{
    input logic reg_write;
    input [4:0] read_reg1;
    input [4:0] read_reg2;
    input [4:0] write_reg;
    input [31:0] write_data;
    output [31:0] read_data1;
    output [31:0] read_data2;
}

endmodule