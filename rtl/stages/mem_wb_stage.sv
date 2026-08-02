module mem_wb_reg(
    input logic clk,
    input logic rst,
    input logic [31:0] read_data_in,
    input logic [31:0] addr_in,
    input logic [31:0] pc_result_in,
    input logic [4:0] rd_in,
    input logic reg_write_in,
    input logic mem_to_reg_in,
    input logic jump_in,
    output logic [31:0] read_data_out,
    output logic [31:0] addr_out,
    output logic [31:0] pc_result_out,
    output logic [4:0] rd_out,
    output logic reg_write_out,
    output logic mem_to_reg_out,
    output logic jump_out
);

    always_ff @(posedge clk) begin
        if(rst) begin   // reset triggered
            read_data_out <= 32'd0;
            addr_out <= 32'd0;
            pc_result_out <= 32'd0;
            rd_out <= 5'd0;
            reg_write_out <= 1'd0;
            mem_to_reg_out <= 1'd0;
            jump_out <= 1'd0;
        end
        else begin  // flow pipeline register
            read_data_out <= read_data_in;
            addr_out <= addr_in;
            pc_result_out <= pc_result_in;
            rd_out <= rd_in;
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            jump_out <= jump_in;
        end
    end

endmodule
