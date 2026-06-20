import pkg::*;

module control_unit{
    input [31:0] instr;
    output logic reg_write;
    output [] alu_sel;
    output logic mem_read;
    output logic mem_write;
    output logic branch_code;
}




endmodule