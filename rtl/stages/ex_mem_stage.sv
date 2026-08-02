module ex_mem_reg(
    input logic [31:0] pc_result_in,
    input logic [31:0] alu_result_in,
    input logic [31:0] write_data_in,
    input logic [4:0] rd_in,
    input logic reg_write_in,
    input logic mem_read_in,
    input logic mem_write_in,
    input logic branch_enable_in,
    input logic mem_to_reg_in,
    input logic zero_in,
    input logic lt_signed_in,
    input logic lt_unsigned_in,
    output logic [31:0] pc_result_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [4:0] rd_out,
    output logic reg_write_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic branch_enable_in,
    output logic mem_to_reg_out,
    output logic zero_out,
    output logic lt_signed_out, 
    output logic lt_unsigned_out
);



endmodule