module ex_mem_reg(
    input logic clk,
    input logic rst,
    input logic [31:0] pc_result_in,
    input logic [31:0] alu_result_in,
    input logic [31:0] write_data_in,
    input logic [4:0] rd_in,
    input logic [2:0] funct3_in,
    input logic reg_write_in,
    input logic mem_read_in,
    input logic mem_write_in,
    input logic mem_to_reg_in,
    input logic jump_in,
    output logic [31:0] pc_result_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [4:0] rd_out,
    output logic [2:0] funct3_out,
    output logic reg_write_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic mem_to_reg_out,
    output logic jump_out
);

    always_ff @(posedge clk) begin
        if(rst) begin // reset register triggered
            pc_result_out <= 32'd0;
            alu_result_out <= 32'd0;
            write_data_out <= 32'd0;
            rd_out <= 5'd0;
            funct3_out <= 3'd0;
            reg_write_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            mem_to_reg_out <= 0;
            jump_out <= 0;
        end
        else begin // flow on otherwise
            pc_result_out <= pc_result_in;
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            rd_out <= rd_in;
            funct3_out <= funct3_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            jump_out <= jump_in;
        end
    end


endmodule
