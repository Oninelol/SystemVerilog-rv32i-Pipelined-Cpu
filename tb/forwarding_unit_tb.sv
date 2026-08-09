`timescale 1ns/1ps
module forwarding_unit_tb;

    logic [4:0] rs,rt;
    logic [4:0] ex_mem_rd;
    logic [4:0] mem_wb_rd;
    logic ex_mem_regwrite;
    logic mem_wb_regwrite;
    logic [1:0] forward_A,forward_B;

    forwarding_unit DUT(
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

endmodule