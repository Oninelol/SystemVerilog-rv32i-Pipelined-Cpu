module top(
    input logic clk,
    input logic rst,
    output logic [31:0] pc_out,
    output logic [31:0] alu_res
);

    // wires below connects modules 
    wire [31:0] pc_in,read_addr_wire; 
    wire [31:0] instr_wire;


    // below are control signals from the control unit
    logic RegWrite;
    logic [1:0] ALUOp;
    logic MemRead,MemWrite,BranchEnable,ALUSrc,MemtoReg;

    // below connects the modules
    program_counter cpu_pc(pc_in,clk,rst,read_addr_wire);
    instruction_memory cpu_imem(read_addr_wire,instr_wire);
    control_unit cpu_control(instr_wire,RegWrite,ALUOp,MemRead,MemWrite,BranchEnable,ALUSrc,MemtoReg);
    register_file cpu_regfile(clk,rst,);

endmodule