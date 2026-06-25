import pkg::*;

module data_memory(
    input logic clk,
    input logic rst,
    input logic [31:0] address,
    input logic [31:0] mem_write_data,
    input logic mem_read,
    input logic mem_write,
    output logic [31:0] mem_read_data
);

    logic [7:0] mem [65535:0]; // allocate memory for 64KB, and byte addressed
    // Risc-V meant to be 4GB memory, but 64KB is written to protect simulation from crashing

    always @(posedge clk) begin
        if(clk) begin
            

        end

    end

    always_comb begin


        
    end

endmodule