import pkg::*;

module control_unit(
    input logic [31:0] instr,
    output logic reg_write,
    output logic [1:0] alu_type,
    output logic mem_read,
    output logic mem_write,
    output logic branch_enable
    output logic alu_src; // to be implemented
    output logic mem_to_reg; // to be implemented
    output logic jump; // to be implemented
);

    always_comb begin // includes logic for ALU control, reg_write, data_memory, and branch signals

        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        branch_enable = 0;
        alu_type = 2'b11; // defaulted signal values

        case(instr[6:0]) 
        ALU_R: begin
            reg_write = 1;
            alu_type = 2'b00;
        end
        ALU_I: begin
            reg_write = 1;
            alu_type = 2'b01;
        end
        BRANCH: begin
            branch_enable = 1;
            alu_type = 2'b10;
        end
        STORE: begin
            mem_write = 1;
            alu_type = 2'b11;
        end
        LOAD: begin
            mem_read = 1;
            reg_write = 1;
            alu_type = 2'b11;
        end
        JAL: reg_write = 1;
        JALR: reg_write = 1;
        LUI: reg_write = 1;
        AUIPC: reg_write = 1;

        endcase
    end

endmodule