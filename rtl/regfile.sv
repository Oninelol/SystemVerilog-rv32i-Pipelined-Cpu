import pkg::*;

module register_file{
    input clk;
    input rst;
    input logic reg_write;
    input [4:0] rs1;
    output [31:0] read_data1;
    input [4:0] rs2;
    output [31:0] read_data2;
    input [4:0] rd;
    input [31:0] write_data;
}

    logic [31:0] regs [31:0]; // 32 Registers that are each 32 bit wide in regfile

    always_ff @(posedge clk) begin // clocked regfile
        if(rst) begin
            integer i;
            for(i=0;i<32;i=i+1) begin
                regs[i] <= 32'd0;
            end
        end
        else if(reg_write) begin
            regs[rd] <= write_data; // write data into desired register
        end
    end

    always_comb begin   // combinational read
        read_data1 <= regs[rs1];
        read_data2 <= regs[rs2];
    end

endmodule