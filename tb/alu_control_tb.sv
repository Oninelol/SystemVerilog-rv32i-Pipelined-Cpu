`timescale 1ns/1ps
import pkg::*;

module alu_control_tb;

    logic [1:0] alu_type;
    logic [31:0] instr;
    logic [4:0] alu_op;

    // ALU type matches following: 
    // 10: Branch, 11: Store/Load, 00: R type, 01: I type, other operations default to ADD
    alu_control DUT( // instantiate device under test (alu_control module)
        .alu_type (alu_type),
        .instr (instr),
        .alu_op (alu_op)
    );

    integer errors = 0;
    integer tests = 0;

    task check_alu_op(

    );

    endtask

endmodule