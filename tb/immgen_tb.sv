`timescale 1ns/1ps
import pkg::*;

module immgen_tb;

    logic [31:0] instr;
    logic [31:0] imm;

    imm_generator DUT( // instantiate device under test (immgen module)
        .instr (instr),
        .imm (imm)
    );

    integer errors = 0;
    integer tests = 0;

    task check_imm( // create task to compare generated imm to expected value
        input [31:0] input_instr,
        input [31:0] expected_imm,
        input string name
    );
    instr = input_instr;
    #1;
    tests = tests + 1;
    if(imm != expected_imm) begin
        errors = errors + 1;
        $display("FAILED %s TEST, imm=%08h expected=%08h",name,imm,expected_imm);
    end
    endtask

    


endmodule