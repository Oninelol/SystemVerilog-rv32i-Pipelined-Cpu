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

    logic load_use; // create load_use logic that is true when the n+1 instruction uses the register loaded by instruction n
    assign load_use = (id_ex_memread) && (id_ex_rd != 5'b00000) && ((if_id_rs == id_ex_rd) || (if_id_rt == id_ex_rd)); // discard load into reg x0
    assign pc_stall = load_use;
    assign if_id_stall = load_use; 
    assign if_id_flush = (branch_taken || jump); 
    assign id_ex_flush = (load_use || branch_taken || jump); 

endmodule