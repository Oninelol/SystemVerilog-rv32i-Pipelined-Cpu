import pkg::*;

module control_unit{
    input [31:0] instr;
    output logic reg_write;
    output [1:0] alu_sel;
    output logic mem_read;
    output logic mem_write;
    output logic branch_enable;
}

    always_comb begin // logic for ALU control signals, determining operation type
        case(instr[6:0])
            ALU_R: alu_sel = 2'b00;
            ALU_I: alu_sel = 2'b01;
            JAL_R: alu_sel = 2'b01; // case JALR also uses the ALU, as I type.
            (STORE || LOAD): alu_sel = 2'b10;
            BRANCH: alu_sel = 2'b11;
            default: alu_sel = 2'b11; // assign ALU control code to 2'b11 as default, so the default is ADD just like in branch.
        endcase // default as 2'b11 is high, convinient for debugging purposes
    end

    always_comb begin // logic for reg_write
        if(instr[6:0] == )

    end

    always_comb begin // logic for data memory control signals 
        mem_read = 0;
        mem_write = 0;
        case(instr[6:0])
            STORE: mem_write = 1;
            LOAD: mem_read = 1;
        endcase
    end

    always_comb begin   // logic for branch signal
        if(intr[6:0] == BRANCH)
            branch_enable = 1;
        else
            branch_enable = 0;
    end

endmodule