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

    function string op_name(input [4:0] op_) // helper function to display result and expected operations with names
        case(op_)
            ALU_ADD: return "ADD";
            ALU_SUB: return "SUB";
            ALU_XOR:  return "XOR";
            ALU_OR:   return "OR";
            ALU_AND:  return "AND";
            ALU_SLL:  return "SLL";
            ALU_SRL:  return "SRL";
            ALU_SRA:  return "SRA";
            ALU_SLT:  return "SLT";
            ALU_SLTU: return "SLTU";
            ALU_MUL:  return "MUL";
            ALU_MULH: return "MULH";
            ALU_MULU: return "MULU";
            ALU_DIV: return "DIV";
            ALU_DIVU: return "DIVU";
            ALU_REM: return "REM";
            ALU_REMU: return "REMU";
            default: return $sformatf("UNKNOWN OPCODE %05b",op_);
        endcase
    endfunction

    task check_alu_op( // task to check if alu operations match what is expected
        input [1:0] input_alu_type,
        input [31:0] input_instr,
        input [4:0] expected_alu_op,
        input string name
    );
    alu_type = input_alu_type;
    instr = input_instr;
    #1;
    tests = tests + 1;
    if(alu_op !== expected_alu_op) begin
        errors = errors + 1;
        $display("FAILED %s TEST, ");
    end
    endtask

    initial begin
        
    end

endmodule