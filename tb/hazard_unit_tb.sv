`timescale 1ns/1ps
module hazard_unit_tb;

    logic [4:0] id_ex_rd;
    logic [4:0] if_id_rs,if_id_rt;
    logic id_ex_memread;
    logic branch_taken;
    logic jump;
    logic pc_stall,if_id_stall;
    logic if_id_flush,id_ex_flush;

    hazard_unit DUT(
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

endmodule