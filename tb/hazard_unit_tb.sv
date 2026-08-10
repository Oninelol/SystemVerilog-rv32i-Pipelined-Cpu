`timescale 1ns/1ps
module hazard_unit_tb;

    logic [4:0] id_ex_rd;
    logic [4:0] if_id_rs,if_id_rt;
    logic id_ex_memread;
    logic branch_taken;
    logic jump;
    logic pc_stall,if_id_stall;
    logic if_id_flush,id_ex_flush;

    hazard_unit DUT( // instantiate device under test (hazard_unit)
        .id_ex_rd (id_ex_rd),
        .if_id_rs (if_id_rs),
        .if_id_rt (if_id_rt),
        .id_ex_memread (id_ex_memread),
        .branch_taken (branch_taken),
        .jump (jump),
        .pc_stall (pc_stall),
        .if_id_stall (if_id_stall),
        .if_id_flush (if_id_flush),
        .id_ex_flush (id_ex_flush)
    );
    
    integer errors = 0;
    integer tests = 0;

    task hazard_check(  // task to check if hazard_unit controls correctly
        input [4:0] id_ex_rd_,
        input [4:0] if_id_a,
        input [4:0] if_id_b,
        input id_ex_memread_,
        input branch_taken_,
        input jump_,
        input expected_pcstall,
        input expected_ifidstall,
        input expected_ifidflush,
        input expected_idexflush,
        input string test_name
    );
        id_ex_rd = id_ex_rd_;
        if_id_rs = if_id_a;
        if_id_rt = if_id_b;
        id_ex_memread = id_ex_memread_;
        branch_taken = branch_taken_;
        jump = jump_;
        #1; // wait for combinational logic to run
        tests = tests + 1;
        if(expected_pcstall !== pc_stall || expected_ifidstall !== if_id_stall 
            || expected_ifidflush !== if_id_flush || expected_idexflush !== id_ex_flush) begin 
                // if any stall or flush mismatch
                errors = errors + 1;
                $display("FAILED %s TEST, PC_STALL: %b(exp %b), IF_ID_STALL: %b(exp %b), IF_ID_FLUSH: %b(exp %b), ID_EX_FLUSH: %b(exp %b)",
                        test_name,pc_stall,expected_pcstall,if_id_stall,expected_ifidstall,if_id_flush,expected_ifidflush,id_ex_flush,expected_idexflush);
        end
    endtask

    initial begin // test checks
        hazard_check(5'd3, 5'd3, 5'd9, 1, 0, 0,  1,1,0,1, "load-use on rs"); // cases of load use
        hazard_check(5'd3, 5'd9, 5'd3, 1, 0, 0,  1,1,0,1, "load-use on rt");
        hazard_check(5'd3, 5'd3, 5'd3, 1, 0, 0,  1,1,0,1, "load-use on both operands");
        hazard_check(5'd3, 5'd8, 5'd9, 1, 0, 0,  0,0,0,0, "load, no dependency");   // cases where load use must not fire
        hazard_check(5'd3, 5'd3, 5'd9, 0, 0, 0,  0,0,0,0, "dependency but producer is not a load");
        hazard_check(5'd0, 5'd0, 5'd0, 1, 0, 0,  0,0,0,0, "load into x0, consumer reads x0");
        hazard_check(5'd3, 5'd8, 5'd9, 0, 1, 0,  0,0,1,1, "branch taken"); // control hazards by branch/jump
        hazard_check(5'd3, 5'd8, 5'd9, 0, 0, 1,  0,0,1,1, "jump");
        hazard_check(5'd3, 5'd8, 5'd9, 0, 1, 1,  0,0,1,1, "branch and jump both asserted");
        hazard_check(5'd3, 5'd3, 5'd9, 1, 1, 0,  1,1,1,1, "load-use during taken branch"); // both branch/jump and load use at the same time
        hazard_check(5'd3, 5'd3, 5'd9, 1, 0, 1,  1,1,1,1, "load-use during jump");
        hazard_check(5'd0, 5'd0, 5'd0, 0, 0, 0,  0,0,0,0, "no hazard"); // idle baseline
        if(errors == 0) begin
            $display("SUCCESS: ALL %d TESTS PASSED",tests);
        end
        else begin
            $display("FAILED: %d ERRORS IN %d TESTS",errors,tests);
        end
        $finish;
    end

endmodule