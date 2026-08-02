module id_ex_reg(
    input logic clk,
    input logic rst,
    input logic flush,
    input logic reg_write_in,
    input logic [1:0] alu_type_in,
    input logic mem_read_in,
    input logic mem_write_in,
    input logic branch_enable_in,
    input logic alu_src_in,
    input logic mem_to_reg_in, 
    input logic jump_in,
    input logic [31:0] pc_in,
    input logic [31:0] read_data1_in,
    input logic [31:0] read_data2_in,
    input logic [31:0] sign_ext32_in,
    input logic [31:0] instr_in,
    output logic [31:0] pc_out,
    output logic [31:0] read_data1_out,
    output logic [31:0] read_data2_out,
    output logic [31:0] sign_ext32_out,
    output logic [31:0] instr_out,
    output logic reg_write_out,
    output logic [1:0] alu_type_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic branch_enable_out,
    output logic alu_src_out,
    output logic mem_to_reg_out, 
    output logic jump_out
);


endmodule