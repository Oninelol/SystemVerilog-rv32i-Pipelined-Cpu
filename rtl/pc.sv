import pkg::*;

module program_counter(
    input [31:0] pc_in,
    input logic clk,
    input logic rst,
    output [31:0] pc_out
);

    always_ff @(posedge clk) begin 
        if(rst) begin
            pc_out <= 32'd0; // reset pc to 0 when reset signal
        end
        else begin
            pc_out <= pc_in;    // otherwise, output the pc input to perform operations
        end
    end   

endmodule