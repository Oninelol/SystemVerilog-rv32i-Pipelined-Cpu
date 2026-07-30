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
        while(pc_loop < 3 || cycles < 1000) begin
            if(prev_pc != pc_out) begin
                
            end

        end


    end


endmodule