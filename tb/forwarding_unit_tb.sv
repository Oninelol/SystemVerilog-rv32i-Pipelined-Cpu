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

    initial begin 

    end

endmodule