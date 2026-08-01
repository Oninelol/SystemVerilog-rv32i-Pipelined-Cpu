`timescale 1ns/1ps
module top_tb;

    logic clk,rst;
    logic [31:0] pc_out;   

    top DUT( // Instantiate device under test (top module)
        .clk (clk),
        .rst (rst),
        .pc_out (pc_out)
    );

    initial clk = 1;
    always #5 clk = ~clk; // 100 MHz clock

    integer errors = 0;
    logic [31:0] prev_pc; 
    integer pc_loop,cycles; // variables to check if pc loops (unchanged) or continues cycling. 

    task check_reg( // task to check if register values are correct
        input [4:0] reg_,
        input [31:0] expected,
        input string expln
    );
        if(DUT.cpu_regfile.regs[reg_] != expected) begin
            errors = errors + 1;
            $display("ERROR: REGISTER x%d=%08h EXPECTED %08h (%s)",reg_,DUT.cpu_regfile.regs[reg_],expected,expln);
        end
    endtask

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0,top_tb);
        rst = 1;
        repeat (2) @(posedge clk); // control reset cpu into known state
        rst = 0; // stop resetting until repeated 2 positive clockedges 
        prev_pc = 32'hFFFFFFFF; 
        pc_loop = 0;
        cycles = 0;
        while(pc_loop < 3 && cycles < 1000) begin
            @(negedge clk); // sample at falling edges to have settled pc outputs
            if(prev_pc !== pc_out) begin 
                pc_loop = 0; // reset pc self loop count
                cycles = cycles + 1;
                prev_pc = pc_out; 
            end
            else begin
                pc_loop = pc_loop + 1;
            end
        end
        if(pc_loop < 3 || cycles >= 1000) begin
            errors = errors + 1;
            $display("FAILED WATCHDOG: PROGRAM NEVER REACHED SELF-LOOP, PC=%08h",pc_out);
        end
        // Architectural state checks for test_program.hex:
        check_reg(5'd1,  32'hFFFFFFFD, "addi negative imm -3");   
        check_reg(5'd2,  32'd5,        "addi positive");
        check_reg(5'd3,  32'd2,        "add -3+5");
        check_reg(5'd4,  32'd8,        "sub 5-(-3)");
        check_reg(5'd5,  32'd5,        "and");
        check_reg(5'd6,  32'hFFFFFFFD, "or");
        check_reg(5'd7,  32'hFFFFFFF8, "xor");
        check_reg(5'd8,  32'h50,       "slli 5<<4");
        check_reg(5'd9,  32'hFFFFFFFE, "srai -3>>>1 = -2");
        check_reg(5'd10, 32'd1,        "slt -3<5 signed true");
        check_reg(5'd11, 32'd0,        "sltu 0xFFFFFFFD<5 unsigned false");
        check_reg(5'd12, 32'h12345000, "lui");
        check_reg(5'd13, 32'h1030,     "auipc: PC(0x30)+0x1000");
        check_reg(5'd14, 32'hFFFFFFFD, "lb sign-extends 0xFD");
        check_reg(5'd15, 32'h000000FD, "lbu zero-extends");
        check_reg(5'd16, 32'h0000FFFD, "lhu zero-extends halfword");
        check_reg(5'd17, 32'd5,        "sh/lh roundtrip");
        check_reg(5'd18, 32'h50,       "jal link = 0x4C+4");
        check_reg(5'd19, 32'd0,        "jal shadow skipped");
        check_reg(5'd20, 32'h58,       "jalr link = 0x54+4");
        check_reg(5'd21, 32'd0,        "jalr shadow skipped");
        // Test results displayed:
        if(errors == 0) begin
            $display("SUCCESS: ALL TESTS PASSED, HALTED AT %08h",pc_out);
        end
        else begin
            $display("FAILED: %d ERRORS FOUND",errors);
        end
        $finish;
    end

endmodule