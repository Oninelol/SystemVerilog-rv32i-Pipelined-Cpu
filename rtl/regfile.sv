module regfile
import pkg::*;
(
    input logic clk,
    input logic rst,
    input logic reg_write,
    input logic [4:0] rs1,
    output logic [31:0] read_data1,
    input logic [4:0] rs2,
    output logic [31:0] read_data2,
    input logic [4:0] rd,
    input logic [31:0] write_data
);

    logic [31:0] regs [31:0]; // 32 Registers that are each 32 bit wide in regfile

    always_ff @(posedge clk) begin // clocked regfile
        if(rst) begin
            integer i;
            for(i=0;i<32;i=i+1) begin
                regs[i] <= 32'd0;
            end
        end
        else if(reg_write && rd != 5'd0) begin
            regs[rd] <= write_data; // write data into desired register
        end
    end

    always_comb begin   // combinational read
        read_data1 = regs[rs1];
        read_data2 = regs[rs2];
    end

endmodule
