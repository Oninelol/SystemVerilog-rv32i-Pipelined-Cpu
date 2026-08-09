`timescale 1ns/1ps
import pkg::*;

module alu_control_tb;

    logic [1:0] alu_type;
    logic [31:0] instr;
    logic [4:0] alu_op;

    // ALU type matches following: 
    // 00: R type, 01: I type, 10: Branch, 11: Store/Load, other operations default to ADD
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
        $display("FAILED %s TEST, OPERATION: %s EXPECTED: %s",name,op_name(alu_op),op_name(expected_alu_op));
    end
    endtask

    initial begin // test checks
        check_alu_op(2'b00, 32'h002081B3, ALU_ADD,   "R add"); // R-type instruction checks 
        check_alu_op(2'b00, 32'h402081B3, ALU_SUB,   "R sub (instr[30])");
        check_alu_op(2'b00, 32'h022081B3, ALU_MUL,   "R mul (instr[25])");
        check_alu_op(2'b00, 32'h002091B3, ALU_SLL,   "R sll");
        check_alu_op(2'b00, 32'h022091B3, ALU_MULH,  "R mulh");
        check_alu_op(2'b00, 32'h0020A1B3, ALU_SLT,   "R slt");
        check_alu_op(2'b00, 32'h0220A1B3, ALU_MULSU, "R mulhsu");
        check_alu_op(2'b00, 32'h0020B1B3, ALU_SLTU,  "R sltu");
        check_alu_op(2'b00, 32'h0220B1B3, ALU_MULU,  "R mulhu");
        check_alu_op(2'b00, 32'h0020C1B3, ALU_XOR,   "R xor");
        check_alu_op(2'b00, 32'h0220C1B3, ALU_DIV,   "R div");
        check_alu_op(2'b00, 32'h0020D1B3, ALU_SRL,   "R srl");
        check_alu_op(2'b00, 32'h4020D1B3, ALU_SRA,   "R sra (instr[30])");
        check_alu_op(2'b00, 32'h0220D1B3, ALU_DIVU,  "R divu");
        check_alu_op(2'b00, 32'h0020E1B3, ALU_OR,    "R or");
        check_alu_op(2'b00, 32'h0220E1B3, ALU_REM,   "R rem");
        check_alu_op(2'b00, 32'h0020F1B3, ALU_AND,   "R and");
        check_alu_op(2'b00, 32'h0220F1B3, ALU_REMU,  "R remu");
        check_alu_op(2'b01, 32'h00500093, ALU_ADD,  "I addi"); // I-type instruction checks
        check_alu_op(2'b01, 32'hFFF00093, ALU_ADD,  "I addi imm=-1: instr[30] set must NOT give SUB");
        check_alu_op(2'b01, 32'h7FF0C093, ALU_XOR,  "I xori imm=0x7FF: instr[25] set must NOT give DIV");
        check_alu_op(2'b01, 32'h00309093, ALU_SLL,  "I slli");
        check_alu_op(2'b01, 32'h0050A093, ALU_SLT,  "I slti");
        check_alu_op(2'b01, 32'h0050B093, ALU_SLTU, "I sltiu");
        check_alu_op(2'b01, 32'h0040D093, ALU_SRL,  "I srli");
        check_alu_op(2'b01, 32'h4040D093, ALU_SRA,  "I srai (legit instr[30] use)");
        check_alu_op(2'b01, 32'h0050E093, ALU_OR,   "I ori");
        check_alu_op(2'b01, 32'h0050F093, ALU_AND,  "I andi");
        check_alu_op(2'b10, 32'h00208463, ALU_SUB, "B beq -> SUB"); // Branch type instruction checks
        check_alu_op(2'b10, 32'h0020C463, ALU_SUB, "B blt (f3=100) -> still SUB not XOR");
        check_alu_op(2'b11, 32'hFFC0A103, ALU_ADD, "L lw -> ADD"); // Load/Store type instruction checks
        check_alu_op(2'b11, 32'h00008083, ALU_ADD, "L lb -> ADD");
        check_alu_op(2'b11, 32'h0020A423, ALU_ADD, "S sw -> ADD");
        // test results displayed: 
        if(errors == 0) begin
            $display("SUCCESS: ALL %d TESTS PASSED",tests);
        end
        else begin
            $display("FAILED: %d ERRORS IN %d TESTS",errors,tests);
        end
        $finish;
    end

endmodule