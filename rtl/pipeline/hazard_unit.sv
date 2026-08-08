module hazard_unit(
    input logic [4:0] id_ex_rd,
    input logic [4:0] if_id_rs,
    input logic [4:0] if_id_rt,
    input logic id_ex_memread,
    input logic branch_taken,
    input logic jump,
    output logic pc_stall,
    output logic if_id_stall,
    output logic if_id_flush,
    output logic id_ex_flush
);

endmodule