import pkg::*;

module alu_control(
    input logic [1:0] alu_type,
    input logic [31:0] instr,
    output logic [4:0] alu_op
);

    always_comb begin
        if(alu_type == 2'b00) begin // ALU_R (R type) operations
            case(instr[14:12]) 
                3'b000: alu_op = instr[30] ? ALU_SUB : (instr[25] ? ALU_MUL : ALU_ADD);
                3'b001: alu_op = instr[25] ? ALU_MULH : ALU_SLL;
                3'b010: alu_op = instr[25] ? ALU_MULSU : ALU_SLT;
                3'b011: alu_op = instr[25] ? ALU_MULU : ALU_SLTU;
                3'b100: alu_op = instr[25] ? ALU_DIV : ALU_XOR;
                3'b101: alu_op = instr[25] ? ALU_DIVU : (instr[30] ? ALU_SRA : ALU_SRL);
                3'b110: alu_op = instr[25] ? ALU_REM : ALU_OR;
                3'b111: alu_op = instr[25] ? ALU_REMU : ALU_AND;
                default: alu_op = ALU_ADD;
            endcase
        end
        else if(alu_type == 2'b01) begin // ALU_I (I type) operations
            case(instr[14:12])
                3'b000: alu_op = ALU_ADD;
                3'b001: alu_op = ALU_SLL;
                3'b010: alu_op = ALU_SLT;
                3'b011: alu_op = ALU_SLTU;
                3'b100: alu_op = ALU_XOR;
                3'b101: alu_op = instr[30] ? ALU_SRA : ALU_SRL;
                3'b110: alu_op = ALU_OR;
                3'b111: alu_op = ALU_AND;
                default: alu_op = ALU_ADD;
            endcase
        end
        else if(alu_type == 2'b11) begin // Store/Load operation, defaulted to addition to directly add up addresses
            alu_op = ALU_ADD;
        end
        else if(alu_type == 2'b10) begin // Branch operation, defaulted to subtraction for direct comparisons in ALU
            alu_op = ALU_SUB;
        end
        else begin // For operations that are not Branch/Store/Load/R type/I type, default to perform add in ALU 
            alu_op = ALU_ADD; 
        end
    end
    
endmodule