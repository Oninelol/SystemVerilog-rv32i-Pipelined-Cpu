`timescale 1ns/1ps
module forwarding_unit_tb;

    logic [4:0] rs,rt;
    logic [4:0] ex_mem_rd;
    logic [4:0] mem_wb_rd;
    logic ex_mem_regwrite;
    logic mem_wb_regwrite;
    logic [1:0] forward_A,forward_B;

    forwarding_unit DUT( // Initiate device under test (forwarding_unit)
        .rs (rs),
        .rt (rt),
        .ex_mem_rd (ex_mem_rd),
        .mem_wb_rd (mem_wb_rd),
        .ex_mem_regwrite (ex_mem_regwrite),
        .mem_wb_regwrite (mem_wb_regwrite),
        .forward_A (forward_A),
        .forward_B (forward_B)
    );

    integer errors = 0;
    integer tests = 0;

    function string fwd_name( // helper function to display forward type
        input [1:0] fwd
    );
        case(fwd)
            2'b00: return "REGFILE OPERAND USED";
            2'b01: return "EXE RESULT FORWARDED";
            2'b10: return "MEM RESULT FORWARDED";
            default: return "INVALID FORWARD TYPE 11";
        endcase
    endfunction

    task check_fwd( // task to check correct forward signals
        input [4:0] a,
        input [4:0] b,
        input [4:0] ex_mem_rd_,
        input [4:0] mem_wb_rd_,
        input [1:0] expected_fwdA,
        input [1:0] expected_fwdB,
        input ex_mem_regwrite_,
        input mem_wb_regwrite_,
        input string test_name
    );
        rs = a;
        rt = b;
        ex_mem_regwrite = ex_mem_regwrite_;
        mem_wb_regwrite = mem_wb_regwrite_;
        ex_mem_rd = ex_mem_rd_;
        mem_wb_rd = mem_wb_rd_;
        #1; // wait for combinational logic to run
        tests = tests + 1;
        if(forward_A !== expected_fwdA || forward_B !== expected_fwdB) begin // if at least one forwarded incorrectly
            errors = errors + 1;
            $display("FAILED %s TEST, FORWARD_A & FORWARD_B TYPE: %s, %s  EXPECTED: %s, %s",
                        test_name,fwd_name(forward_A),fwd_name(forward_B),fwd_name(expected_fwdA),fwd_name(expected_fwdB));
        end
    endtask

    initial begin // test checks
        check_fwd(5'd1, 5'd2, 5'd7, 5'd8, 2'b00, 2'b00, 1, 1, "no match either stage"); // baseline
        check_fwd(5'd3, 5'd2, 5'd3, 5'd8, 2'b01, 2'b00, 1, 1, "EX/MEM matches rs only"); // when single stage matches one operand
        check_fwd(5'd1, 5'd3, 5'd3, 5'd8, 2'b00, 2'b01, 1, 1, "EX/MEM matches rt only");
        check_fwd(5'd4, 5'd2, 5'd7, 5'd4, 2'b10, 2'b00, 1, 1, "MEM/WB matches rs only");
        check_fwd(5'd1, 5'd4, 5'd7, 5'd4, 2'b00, 2'b10, 1, 1, "MEM/WB matches rt only"); 
        check_fwd(5'd5, 5'd2, 5'd5, 5'd5, 2'b01, 2'b00, 1, 1, "both stages match rs, EX/MEM wins"); // when both stages match the operand
        check_fwd(5'd5, 5'd5, 5'd5, 5'd5, 2'b01, 2'b01, 1, 1, "both stages match both ops, EX/MEM wins");
        check_fwd(5'd3, 5'd4, 5'd3, 5'd4, 2'b01, 2'b10, 1, 1, "rs from EX/MEM, rt from MEM/WB"); // different stages forward to different operands
        check_fwd(5'd4, 5'd3, 5'd3, 5'd4, 2'b10, 2'b01, 1, 1, "rs from MEM/WB, rt from EX/MEM");
        check_fwd(5'd6, 5'd6, 5'd6, 5'd8, 2'b01, 2'b01, 1, 1, "rs == rt, one producer feeds both"); // same register used in both fields
        check_fwd(5'd3, 5'd2, 5'd3, 5'd8, 2'b00, 2'b00, 0, 1, "EX/MEM rd matches but regwrite=0"); // phantom rd cases
        check_fwd(5'd4, 5'd2, 5'd7, 5'd4, 2'b00, 2'b00, 1, 0, "MEM/WB rd matches but regwrite=0");
        check_fwd(5'd5, 5'd2, 5'd5, 5'd5, 2'b10, 2'b00, 0, 1, "EX/MEM disqualified, falls through to MEM/WB");
        check_fwd(5'd0, 5'd0, 5'd0, 5'd8, 2'b00, 2'b00, 1, 1, "EX/MEM rd = x0, no forward"); // x0 register cases check
        check_fwd(5'd0, 5'd0, 5'd7, 5'd0, 2'b00, 2'b00, 1, 1, "MEM/WB rd = x0, no forward");
        if(errors == 0) begin
            $display("SUCCESS: ALL %d TESTS PASSED",tests);
        end
        else begin
            $display("FAILED: %d ERRORS IN %d TESTS",errors,tests);
        end
        $finish;
    end

endmodule