module data_mem
import pkg::*;
(
    input  logic        clk,
    input  logic        rst,             
    input  logic [31:0] address,        
    input  logic [31:0] mem_write_data, 
    input  logic [2:0]  funct_3,         
    input  logic        mem_read,
    input  logic        mem_write,
    output logic [31:0] mem_read_data
);

    logic [31:0] mem [0:16383];

    logic [13:0] word_idx;   // 32-bit word
    logic [1:0]  byte_off;   // byte inside the word
    assign word_idx = address[15:2];
    assign byte_off = address[1:0];

    initial begin
        for (int k = 0; k < 16384; k++) begin 
            mem[k] = 32'd0;   
        end
    end

    logic [3:0]  byte_en;
    logic [31:0] wdata;

    always_comb begin
        byte_en = 4'b0000;
        wdata   = 32'd0;
        if (mem_write) begin
            case (funct_3)
                3'b000: begin 
                    byte_en = 4'b0001 << byte_off;
                    wdata   = {4{mem_write_data[7:0]}};
                end
                3'b001: begin 
                    byte_en = byte_off[1] ? 4'b1100 : 4'b0011;
                    wdata   = {2{mem_write_data[15:0]}};
                end
                3'b010: begin 
                    byte_en = 4'b1111;
                    wdata   = mem_write_data;
                end
                default: ;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (byte_en[0]) mem[word_idx][7:0]   <= wdata[7:0];
        if (byte_en[1]) mem[word_idx][15:8]  <= wdata[15:8];
        if (byte_en[2]) mem[word_idx][23:16] <= wdata[23:16];
        if (byte_en[3]) mem[word_idx][31:24] <= wdata[31:24];
    end

    logic [31:0] rword;
    logic [7:0]  rbyte;
    logic [15:0] rhalf;

    assign rword = mem[word_idx];

    always_comb begin
        rbyte = rword[8*byte_off +: 8];
        rhalf = byte_off[1] ? rword[31:16] : rword[15:0];

        mem_read_data = 32'd0;
        if (mem_read) begin
            case (funct_3)
                3'b000: mem_read_data = {{24{rbyte[7]}}, rbyte};  
                3'b001: mem_read_data = {{16{rhalf[15]}}, rhalf}; 
                3'b010: mem_read_data = rword;                     
                3'b100: mem_read_data = {24'd0, rbyte};           
                3'b101: mem_read_data = {16'd0, rhalf};            
                default: ;
            endcase
        end
    end

endmodule