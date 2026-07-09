module top(
    input logic clk,
    input logic rst,
    output logic [31:0] pc_out,
    output logic [31:0] alu_res
);

    // wires below connects modules 
    wire [31:0] pc_in,read_addr_wire; 
    wire [31:0] instr;
    wire [31:0] read_data_1,read_data_2;
    wire [31:0] write_data;
    wire [31:0] imm_result;
    wire [4:0] alu_op;
    wire [31:0] ALU_result;
    wire [31:0] mem_read_data; 


    // below are control signals from the control unit and ALU (for branching)
    logic RegWrite;
    logic [1:0] ALUOp;
    logic MemRead,MemWrite,BranchEnable,ALUSrc,MemtoReg;
    logic zero,negative;

    // below connects the modules
    program_counter cpu_pc (
        .pc_in (pc_in),
        .clk (clk),
        .rst (rst),
        .pc_out (read_addr_wire)
    );  // PC connections

    instruction_memory cpu_imem (
        .addr (read_addr_wire),
        .instr (instr)
    ); // Intructional memory connections

    control_unit cpu_control (
        .instr (instr),
        .reg_write (RegWrite),
        .alu_type (ALUOp),
        .mem_read (MemRead),
        .mem_write (MemWrite),
        .branch_enable (BranchEnable),
        .alu_src (ALUSrc),
        .mem_to_reg (MemtoReg)
    ); // Control unit connections

    register_file cpu_regfile (
        .clk (clk),
        .rst (rst),
        .reg_write (RegWrite),
        .rs1 (instr[19:15]),
        .read_data1 (read_data_1),
        .rs2 (instr[24:20]),
        .read_data2 (read_data_2),
        .rd (instr[11:7]),
        .write_data (MemtoReg ? mem_read_data : ALU_result)
    ); // Regfile connections

    imm_generator cpu_immgen (
        .instr (instr),
        .imm (imm_result)
    ); // immediate generator connections

    alu_control cpu_alucontrol (
        .alu_type (ALUOp),
        .instr (instr),
        .alu_op (alu_op)
    ); // alu control connections

    ALU cpu_alu (
        .alu_op (alu_op),
        .operand_1 (read_data_1),
        .operand_2 (ALUSrc ? imm_result : read_data_2),
        .zero (zero),
        .negative (negative),
        .alu_result (ALU_result)
    ); // Arithmetic logical unit connections

    data_memory cpu_dmem (
        .clk (clk),
        .rst (rst),
        .address (ALU_result),
        .mem_write_data (read_data_2),
        .funct3 (instr[14:12]),
        .mem_read (MemRead),
        .mem_write (MemWrite),
        .mem_read_data (mem_read_data)
    ); // Data memory connections



endmodule