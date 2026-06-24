import pkg::*;

module ALU(
    input [4:0] alu_op,
    input [31:0] operand_1,
    input [31:0] operand_2,
    output logic zero,
    output logic negative,
    output [31:0] alu_result,
)

    always_comb begin // case statement inside to derive alu operation based on alu operation decided in alu_control block
        case(alu_op)
            ALU_ADD: alu_result = operand_1 + operand_2;
            ALU_SUB: alu_result = operand_1 - operand_2;
            ALU_XOR: alu_result = operand_1 ^ operand_2;
            ALU_OR: alu_result = operand_1 | operand_2;
            ALU_AND: alu_result = operand_1 & operand_2;
            ALU_SLL: alu_result = operand_1 << operand_2[4:0];
            ALU_SRL: alu_result = operand_1 >> operand_2[4:0];
            ALU_SRA: alu_result = $signed(operand_1) >>> operand_2[4:0];
            ALU_SLT: alu_result = ($signed(operand_1) < $signed(operand_2)) ? 32'd1 : 32'd0;
            ALU_SLTU: alu_result = (operand_1 < operand_2) ? 32'd1 : 32'd0;
            ALU_MUL: alu_result = operand_1 * operand_2;
            ALU_MULH: alu_result = ($signed(operand_1) * $signed(operand_2))[63:32]; // fix here later, as the result cannot be directly sliced, use temp to store result first 
            ALU_MULSU: alu_result = ($signed(operand_1) * operand_2)[63:32];
            ALU_MULU: alu_result = (operand_1 * operand_2)[63:32];
            ALU_DIV: alu_result = ($signed(operand_1) / $signed(operand_2));
            ALU_DIVU: alu_result = operand_1 / operand_2;
            ALU_REM: alu_result = ($signed(operand_1) % $signed(operand_2));
            ALU_REMU: alu_result = operand_1 % operand_2;
            default: alu_result = operand_1 + operand_2;
        endcase
    end

    assign zero = (alu_result == 32'd0) ? 32'd1 : 32'd0;  // logic to calculate the zero signal used for branching
    assign negative = (alu_result < 32'd0) ? 32'd1 : 32'd0; // logic to calculate the negative signal used for branching

endmodule