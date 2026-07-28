`timescale 1ns/1ps
import pkg::*;

module tb_alu;

    logic [4:0] alu_op;
    logic [31:0] operand_1,operand_2;
    logic zero,lt_signed,lt_unsigned;
    logic [31:0] alu_result;

    ALU DUT( // instantiate device under test, the ALU
        .alu_op (alu_op),
        .operand_1 (operand_1),
        .operand_2 (operand_2),
        .zero (zero),
        .lt_signed (lt_signed),
        .lt_unsigned (lt_unsigned),
        .alu_result (alu_result)
    );

    integer errors = 0;
    integer tests = 0; // initialize variables counting total errors and total tests

    task check_res( // task to check if ALU module result matches expected result
        input [4:0] operation,
        input [31:0] a,b,
        input [31:0] alu_expected,
        input string test_name
    );
        alu_op = operation;
        operand_1 = a; 
        operand_2 = b;
        #1; // wait for alu combinational logic to run
        tests = tests + 1; // increment number of tests
        if(alu_result != alu_expected) begin
            errors = errors + 1; // increment error count
            $display("FAILED %s TEST, var1=%08h var2=%08h result=%08h expected=%08h",test_name,a,b,alu_result,alu_expected);
        end
    endtask 

    task check_flags( // check flags outputted from the ALU
        input [31:0] a,b,
        input expected_zero,expected_lts,expected_ltu,
        input string test_name
    ); 
        operand_1 = a;
        operand_2 = b;
        alu_op = ALU_SUB; // default ALU operation to subtraction for flag checking
        #1;
        tests = tests + 1;
        if(zero != expected_zero || lt_signed != expected_lts || lt_unsigned != expected_ltu) begin
            errors = errors + 1;
            $display("FAILED %s FLAG TEST, var1=%08h var2=%08h zero=%b(expected %b) lt_signed=%b(expected %b) lt_unsigned=%b(expected %b)",
                        test_name,a,b,zero,expected_zero,lt_signed,expected_lts,lt_unsigned,expected_ltu);
        end
    endtask

    initial begin // start running tests

    end


endmodule