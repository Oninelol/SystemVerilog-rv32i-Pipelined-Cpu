package pkg

    typedef enum logic [6:0]{
        ALU_R = 7'b0110011;
        ALU_I = 7'b0010011;
        LOAD =  7'b0000011;
        STORE = 7'b1100011;
        BRANCH = 7'b1100011;
        JAL = 7'b1101111;
        JAL_R = 7'b1100111;
        LUI = 7'b0110111;
        AUIPC = 7'b0010111;
        ENV = 7'b1110011;

    } opcode; // constructed enum based off opcode of rv32i instructions

    typedef enum logic [2:0]{ // different types of load and store and branching also looks at funct3
        ADD_SUB_F3 = 3'b000;
        SLL_F3 = 3'b001;
        SLT_F3 = 3'b010;
        SLTU_F3 = 3'b011;
        XOR_F3 = 3'b100;
        SRL_SRA_F3 = 3'b101;
        OR_F3 = 3'b110;
        AND_F3 = 3'b111;

    } funct3; // constructed enum based off different funct3 of rv32i instructions

    typedef enum logic [6:0]{
        REGULAR_F7 = 7'b0000000;
        MUL_F7 = 7'b0000001;
        SUB_SRA_F7 = 7'b0000010;

    } funct7; // constructed enum based off different funct7 of rv32i instructions, with the multiplication extension

endpackage 