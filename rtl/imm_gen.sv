import pkg::*;

module imm_generator(
    input logic [31:0] instr,
    output logic [31:0] imm;
);

    always_comb begin // always logic for imm generation
        case(instr[6:0])
            7'b0010011: imm = {{20{instr[31]}},instr[31:20]}; 
            7'b0000011: imm = {{20{instr[31]}},instr[31:20]}; 
            7'b1100111: imm = {{20{instr[31]}},instr[31:20]}; // first three cases for I type imms
            7'b0100011: imm = {{20{instr[31]}},instr[31:25],instr[11:7]}; // case for S type imm
            7'b1100011: imm = {{20{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8]}; // case for B type imm
            7'b0110111: imm = {instr[31:12],12'd0}; 
            7'b0010111: imm = {instr[31:12],12'd0};  // two cases for U type imm
            7'b1101111: imm = {{12{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'd0}; // case for J type imm
            default: imm = 32'd0;   
        endcase
    end


endmodule