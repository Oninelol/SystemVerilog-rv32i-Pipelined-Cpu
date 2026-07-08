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


    // below are control signals from the control unit
    logic RegWrite;
    logic [1:0] ALUOp;
    logic MemRead,MemWrite,BranchEnable,ALUSrc,MemtoReg;

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
        .write_data (write_data)
    ); // Regfile connections

    

endmodule