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

    always_ff @(posedge clk) begin
        if(rst || flush) begin  // when reset or flush triggered
            pc_out <= 32'd0;
            read_data1_out <= 32'd0;
            read_data2_out <= 32'd0;
            sign_ext32_out <= 32'd0;
            instr_out <= 32'h00000013; // addi x0,x0,0 
            reg_write_out <= 1'd0;
            alu_type_out <= 2'b11; // default to ADD operation
            mem_read_out <= 1'd0;
            mem_write_out <= 1'd0;
            branch_enable_out <= 1'd0;
            alu_src_out <= 1'd0;
            mem_to_reg_out <= 1'd0;
            jump_out <= 1'd0;
        end
    else begin  // otherwise pipeline continues to flow
        pc_out <= pc_in;
        read_data1_out <= read_data1_in;
        read_data2_out <= read_data2_in;
        sign_ext32_out <= sign_ext32_in;
        instr_out <= instr_in;
        reg_write_out <= reg_write_in;
        alu_type_out <= alu_type_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        branch_enable_out <= branch_enable_in;
        alu_src_out <= alu_src_in;
        mem_to_reg_out <= mem_to_reg_in;
        jump_out <= jump_in;
    end
    end

endmodule