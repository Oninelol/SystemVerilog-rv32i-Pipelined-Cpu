module pc
import pkg::*;
(
    input [31:0] pc_in,
    input logic clk,
    input logic rst,
    input logic stall,
    output logic [31:0] pc_out
);

    always_ff @(posedge clk) begin 
        if(rst) begin
            pc_out <= 32'd0; // reset pc to 0 when reset signal
        end
        else if (~stall) begin 
            pc_out <= pc_in;    // if pc not stalled and not reset, output the pc input to perform operations
        end
    end   

endmodule
