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
        if(alu_result !== alu_expected) begin
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
        if(zero !== expected_zero || lt_signed !== expected_lts || lt_unsigned !== expected_ltu) begin
            errors = errors + 1;
            $display("FAILED %s FLAG TEST, var1=%08h var2=%08h zero=%b(expected %b) lt_signed=%b(expected %b) lt_unsigned=%b(expected %b)",
                        test_name,a,b,zero,expected_zero,lt_signed,expected_lts,lt_unsigned,expected_ltu);
        end
    endtask

    initial begin // start running tests
        check_res(ALU_ADD, 32'd5,        32'd7,        32'd12,       "add basic"); // start checking for addition and subtraction
        check_res(ALU_ADD, 32'hFFFFFFFF, 32'd1,        32'd0,        "add wraparound");
        check_res(ALU_ADD, 32'h7FFFFFFF, 32'd1,        32'h80000000, "add signed overflow");
        check_res(ALU_SUB,32'd10,32'd3,32'd7,"sub basic");
        check_res(ALU_SUB, 32'd3,        32'd10,       32'hFFFFFFF9, "sub negative result");
        check_res(ALU_SUB, 32'h80000000, 32'd1,        32'h7FFFFFFF, "sub overflow wrap");
        check_res(ALU_XOR, 32'hFF00FF00, 32'h0F0F0F0F, 32'hF00FF00F, "xor"); // bitwise operations
        check_res(ALU_OR,  32'hFF00FF00, 32'h0F0F0F0F, 32'hFF0FFF0F, "or");
        check_res(ALU_AND, 32'hFF00FF00, 32'h0F0F0F0F, 32'h0F000F00, "and");
        check_res(ALU_SLL, 32'd1,        32'd31,       32'h80000000, "sll by 31"); // shifts 
        check_res(ALU_SLL, 32'd1,        32'd32,       32'd1,        "sll amount masked to 5 bits");
        check_res(ALU_SRL, 32'h80000000, 32'd31,       32'd1,        "srl by 31");
        check_res(ALU_SRL, 32'hFFFFFFFF, 32'd4,        32'h0FFFFFFF, "srl fills zeros");
        check_res(ALU_SRA, 32'h80000000, 32'd4,        32'hF8000000, "sra fills sign bits");
        check_res(ALU_SRA, 32'h7FFFFFFF, 32'd4,        32'h07FFFFFF, "sra positive operand");
        check_res(ALU_SLT,  32'hFFFFFFFF, 32'd1,        32'd1, "slt -1 < 1"); // set less than
        check_res(ALU_SLT,  32'd1,        32'hFFFFFFFF, 32'd0, "slt 1 < -1 false");
        check_res(ALU_SLT,  32'h80000000, 32'd1,        32'd1, "slt INT_MIN < 1");
        check_res(ALU_SLTU, 32'd1,        32'hFFFFFFFF, 32'd1, "sltu 1 < max");
        check_res(ALU_SLTU, 32'hFFFFFFFF, 32'd1,        32'd0, "sltu max < 1 false");
        check_res(ALU_SLTU, 32'd5,        32'd5,        32'd0, "sltu equal false");
        check_res(ALU_MUL,   32'd7,        32'd6,        32'd42,       "mul basic"); // multplication tests
        check_res(ALU_MUL,   32'hFFFFFFFF, 32'hFFFFFFFF, 32'd1,        "mul -1*-1 low word");
        check_res(ALU_MULH,  32'hFFFFFFFF, 32'hFFFFFFFF, 32'd0,        "mulh -1*-1 = 0 high");
        check_res(ALU_MULH,  32'h80000000, 32'h80000000, 32'h40000000, "mulh INT_MIN^2 high");
        check_res(ALU_MULU,  32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFE, "mulhu max*max high");
        check_res(ALU_MULSU, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFF, "mulhsu -1 * max high");
        check_res(ALU_DIV,  32'd42,       32'd7,        32'd6,        "div basic"); // division and remainder tests
        check_res(ALU_DIV,  32'hFFFFFFF9, 32'd2,        32'hFFFFFFFD, "div -7/2 = -3 trunc");
        check_res(ALU_DIVU, 32'hFFFFFFFF, 32'd2,        32'h7FFFFFFF, "divu max/2");
        check_res(ALU_REM,  32'hFFFFFFF9, 32'd2,        32'hFFFFFFFF, "rem -7 mod 2 = -1");
        check_res(ALU_REMU, 32'd7,        32'd3,        32'd1,        "remu basic");
        check_res(ALU_DIV,  32'd5,        32'd0,        32'hFFFFFFFF, "div by zero -> -1 (spec)");
        check_res(ALU_DIVU, 32'd5,        32'd0,        32'hFFFFFFFF, "divu by zero -> all 1s (spec)");
        check_res(ALU_REM,  32'd5,        32'd0,        32'd5,        "rem by zero -> dividend (spec)");
        check_res(ALU_DIV,  32'h80000000, 32'hFFFFFFFF, 32'h80000000, "div overflow INT_MIN/-1 (spec)");
        check_flags(32'd5,        32'd5,        1,   0,   0, "equal"); // branch flags tests
        check_flags(32'd3,        32'd7,        0,   1,   1, "both less");
        check_flags(32'hFFFFFFFF, 32'd1,        0,   1,   0, "-1 vs 1 diverge");
        check_flags(32'd1,        32'hFFFFFFFF, 0,   0,   1, "1 vs -1 diverge");
        check_flags(32'h80000000, 32'd1,        0,   1,   0, "INT_MIN vs 1 (sub overflows)");
        check_flags(32'h7FFFFFFF, 32'h80000000, 0,   0,   1, "INT_MAX vs INT_MIN");
        // results displayed:
        if(errors == 0) begin
            $display("SUCESS: ALL %d TESTS PASSED",tests);
        end
        else begin
            $display("FAILED: %d ERRORS IN %d TESTS",errors,tests);
        end
        $finish;
    end


endmodule