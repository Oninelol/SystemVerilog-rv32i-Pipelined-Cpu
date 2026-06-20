import pkg::*;

module program_counter{
    input [31:0] addr;
    input clk;
    output [31:0] addr_out;
}

    always @(posedge clk) begin
        addr = addr + 4;
    end

endmodule