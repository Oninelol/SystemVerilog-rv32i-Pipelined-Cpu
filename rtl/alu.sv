import pkg::*;

module ALU{
    input [1:0] alu_sel;
    input [31:0] operand_1;
    input [31:0] operand_2;
    output logic zero;
    output logic negative;
    output [31:0] alu_result;
}



endmodule