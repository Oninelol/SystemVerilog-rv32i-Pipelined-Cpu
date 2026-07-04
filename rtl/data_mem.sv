import pkg::*;

module data_memory(
    input logic clk,
    input logic rst,
    input logic [31:0] address,  // takes result of ALU
    input logic [31:0] mem_write_data, // write data input
    input logic [2:0] funct3, // funct3 used to differentiate between different types of store/load
    input logic mem_read,
    input logic mem_write,
    output logic [31:0] mem_read_data
);

    logic [7:0] mem [65535:0]; // allocate memory for 64KB, and byte addressed
    // Risc-V meant to be 4GB memory, but 64KB is written to protect simulation from crashing

    always_ff @(posedge clk) begin // clocked reset and mem_write
            if(rst) begin // if reset signal indicated
                integer i;
                for(i=0;i<65536;i = i+1) begin
                    mem[i] <= 8'b0;
                end
            end
            else if(mem_write) begin // if memory write instructed
                case(funct3)
                    3'b000: mem[address] <= mem_write_data[7:0];
                    3'b001: begin
                        mem[address] <= mem_write_data[7:0];
                        mem[address+1] <= mem_write_data[15:8];
                    end 
                    3'b010: begin   
                        mem[address] <= mem_write_data[7:0];
                        mem[address+1] <= mem_write_data[15:8];
                        mem[address+2] <= mem_write_data[23:16];
                        mem[address+3] <= mem_write_data[31:24];
                    end
                endcase
            end

    end

    always_comb begin // combinational memory read
        mem_read_data = 32'd0; // default case where nothing is loaded (read data = 0);
        if(mem_read) begin
            case(funct3)
                3'b000: mem_read_data = {{24{mem[address][7]}},mem[address]};
                3'b001: mem_read_data = {{16{mem[address+1][7]}},mem[address+1],mem[address]};
                3'b010: mem_read_data = {mem[address+3],mem[address+2],mem[address+1],mem[address]};
                3'b100: mem_read_data = {{24{1'b0}},mem[address]};
                3'b101: mem_read_data = {{16{1'b0}},mem[address+1],mem[address]};
            endcase
        end
    end

endmodule