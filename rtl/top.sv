module top
import pkg::*;
(
    input logic clk,
    input logic rst,
    output logic [31:0] pc_out
);

    // wires below connects modules 
    logic [31:0] instr;
    logic [31:0] pc_in,read_addr_wire; 
    logic [31:0] read_data_1,read_data_2;
    logic [31:0] write_data;
    logic [31:0] imm_result;
    logic [4:0] alu_op;
    logic [31:0] ALU_result;
    logic [31:0] mem_read_data; 


    // below are control signals from the control unit and ALU (for branching)
    logic RegWrite;
    logic [1:0] ALUOp;
    logic MemRead,MemWrite,BranchEnable,ALUSrc,MemtoReg;
    logic zero,lt_signed,lt_unsigned; 
    logic jump;

    // pc logic below
    logic branch_taken; // logic signal indicating if a branch is taken 
    wire [31:0] pc_plus_4, pc_target;
    assign pc_plus_4 = read_addr_wire + 32'd4; // default pc incrementation logic

    always_comb begin
        case(instr[14:12])
            3'b000: branch_taken = zero; // branch equal
            3'b001: branch_taken = ~zero; // branch not equal
            3'b100: branch_taken = lt_signed; // branch less than (signed)
            3'b101: branch_taken = ~lt_signed; // branch greater or equal to (signed)
            3'b110: branch_taken = lt_unsigned; // branch less than (unsigned)
            3'b111: branch_taken = ~lt_unsigned; // branch greater or equal to (unsigned)
            default: branch_taken = 0;
        endcase
    end

    always_comb begin
        if(jump & instr[6:0] == JALR) begin
            pc_in = (read_data_1 + imm_result) & ~32'd1; // JALR, clears bit 0
        end
        else if(jump) begin
            pc_in = read_addr_wire + imm_result; // JAL = pc + imm;
        end
        else if(BranchEnable && branch_taken) begin 
            pc_in = read_addr_wire + imm_result; // Branching, pc += imm;
        end
        else begin // regular case of incrementing by 4
            pc_in = pc_plus_4;
        end
    end

    assign pc_out = read_addr_wire; // set output wire pc_out to read_addr_wire also to debug

    // below connects the modules
    pc cpu_pc (
        .pc_in (pc_in),
        .clk (clk),
        .rst (rst),
        .pc_out (read_addr_wire)
    );  // PC connections

    instr_mem cpu_imem (
        .addr (read_addr_wire),
        .instr (instr)
    ); // Intructional memory connections

    control cpu_control (
        .instr (instr),
        .reg_write (RegWrite),
        .alu_type (ALUOp),
        .mem_read (MemRead),
        .mem_write (MemWrite),
        .branch_enable (BranchEnable),
        .alu_src (ALUSrc),
        .mem_to_reg (MemtoReg),
        .jump (jump)
    ); // Control unit connections

    regfile cpu_regfile (
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

    imm_gen cpu_immgen (
        .instr (instr),
        .imm (imm_result)
    ); // immediate generator connections

    alu_control cpu_alucontrol (
        .alu_type (ALUOp),
        .instr (instr),
        .alu_op (alu_op)
    ); // alu control connections

    alu cpu_alu (
        .alu_op (alu_op),
        .operand_1 (read_data_1),
        .operand_2 (ALUSrc ? imm_result : read_data_2),
        .zero (zero),
        .lt_signed (lt_signed),
        .lt_unsigned(lt_unsigned),
        .alu_result (ALU_result)
    ); // Arithmetic logical unit connections

    data_mem cpu_dmem (
        .clk (clk),
        .rst (rst),
        .address (ALU_result),
        .mem_write_data (read_data_2),
        .funct_3 (instr[14:12]),
        .mem_read (MemRead),
        .mem_write (MemWrite),
        .mem_read_data (mem_read_data)
    ); // Data memory connections



endmodule
