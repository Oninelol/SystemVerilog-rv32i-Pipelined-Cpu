module forwarding_unit(
    input logic [4:0] rs,
    input logic [4:0] rt,
    input logic [4:0] ex_mem_rd,
    input logic [4:0] mem_wb_rd,
    input logic ex_mem_regwrite,
    input logic mem_wb_regwrite,
    output logic [1:0] forward_A, 
    output logic [1:0] forward_B
    // 00 uses regfile operands, 01 forwards from prior ALU result, 10 forwards from data memory or previous result
);

    always_comb begin
        // logic for rs1
        if(ex_mem_regwrite && ex_mem_rd != 5'd0 && rs == ex_mem_rd) begin // if rs1 uses register that just finished execution
            forward_A = 2'b01;
        end
        else if(mem_wb_regwrite && mem_wb_rd != 5'd0 && rs == mem_wb_rd) begin // if rs1 uses register flowing in data memory/last stage register
            forward_A = 2'b10;
        end
        else begin // otherwise use regfile operand
            forward_A = 2'b00;
        end

        // logic for rs2
        if(ex_mem_regwrite && ex_mem_rd != 5'd0 && rt == ex_mem_rd) begin // if rs2 uses register that just finished execution
            forward_B = 2'b01;
        end
        else if(mem_wb_regwrite && mem_wb_rd != 5'd0 && rt == mem_wb_rd) begin // if rs2 uses register flowing in data memory/last stage register
            forward_B = 2'b10;
        end
        else begin // otherwise use regfile operand
            forward_B = 2'b00;
        end
    end

endmodule
