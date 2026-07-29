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
    if(imm !== expected_imm) begin
        errors = errors + 1;
        $display("FAILED %s TEST, imm=%08h expected=%08h",name,imm,expected_imm);
    end
    endtask

    initial begin
        check_imm(32'h00500093, 32'h00000005, "I addi +5"); // I-type instructions
        check_imm(32'hFFF00093, 32'hFFFFFFFF, "I addi -1 (sign ext all 1s)");
        check_imm(32'h7FF00093, 32'h000007FF, "I addi +2047 (max)");
        check_imm(32'h80000093, 32'hFFFFF800, "I addi -2048 (min)");
        check_imm(32'hFFC0A103, 32'hFFFFFFFC, "I lw offset -4 (LOAD opcode path)");
        check_imm(32'h010100E7, 32'h00000010, "I jalr offset +16 (JALR opcode path)");
        check_imm(32'h0020A423, 32'h00000008, "S sw offset +8"); // S-type instructions
        check_imm(32'hFE20AFA3, 32'hFFFFFFFF, "S sw offset -1 (both fields all 1s)");
        check_imm(32'h8020A023, 32'hFFFFF800, "S sw offset -2048 (only sign bit)");
        check_imm(32'h00208463, 32'h00000008, "B beq offset +8"); // B-type instructions
        check_imm(32'hFE208CE3, 32'hFFFFFFF8, "B beq offset -8");
        check_imm(32'h000000E3, 32'h00000800, "B isolate imm[11] (instr[7])");
        check_imm(32'h80000063, 32'hFFFFF000, "B isolate imm[12]/sign (instr[31])");
        check_imm(32'hABCDE0B7, 32'hABCDE000, "U lui 0xABCDE"); // U-type instructions
        check_imm(32'h001000B7, 32'h00100000, "U lui 0x00100 (single bit)");
        check_imm(32'hFFFFF097, 32'hFFFFF000, "U auipc 0xFFFFF (AUIPC opcode path)");
        check_imm(32'h008000EF, 32'h00000008, "J jal offset +8"); // J-type instructions
        check_imm(32'hFF9FF06F, 32'hFFFFFFF8, "J jal offset -8");
        check_imm(32'h0010006F, 32'h00000800, "J isolate imm[11] (instr[20])");
        check_imm(32'h0000106F, 32'h00001000, "J isolate imm[12] (instr[12])");
        check_imm(32'h8000006F, 32'hFFF00000, "J isolate imm[20]/sign (instr[31])");
        check_imm(32'h00208033, 32'h00000000, "default R-type add -> 0"); // R-type opcode instruction with no imm
        // test results displayed:
        if(errors == 0) begin
            $display("SUCESS: ALL %d TESTS PASSED",tests);
        end
        else begin
            $display("FAILED: %d ERRORS IN %d TESTS",errors,tests);
        end
        $finish;
    end


endmodule