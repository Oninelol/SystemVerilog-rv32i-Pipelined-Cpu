module if_id_reg(
    input logic clk,
    input logic rst,
    input logic stall,
    input logic flush,
    input logic [31:0] pc_in, // pc_plus_4 connects in
    input logic [31:0] instr_in,
    output logic [31:0] pc_out, 
    output logic [31:0] instr_out
);

    always_ff @(posedge clk) begin
        if(rst || flush) begin // when reset or flush triggered
            pc_out <= 32'd0; // reset PC
            instr_out <= 32'h00000013; // addi x0,x0,0;
        end
        else if(~stall) begin // if no stall, move forward
            pc_out <= pc_in;
            instr_out <= instr_in;
        end 
        // when stall is triggered, the contents in register is held for the clock cycle
    end

endmodule
