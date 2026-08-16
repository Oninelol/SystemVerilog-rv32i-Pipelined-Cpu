module top
import pkg::*;
(
    input logic clk,
    input logic rst,
    output logic [31:0] pc_out
);

    // logic to connect modules 
    logic [31:0] instr;
    logic [31:0] pc_in,read_addr_wire; 
    logic [31:0] read_data_1,read_data_2;
    logic [31:0] alu_operand_1;
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

    // pipeline logic
    logic pc_stall;
    logic if_id_stall,if_id_flush;
    logic [31:0] if_id_instr_out;
    logic [31:0] if_id_pc_out;
    logic id_ex_flush;
    logic [31:0] id_ex_pc_out;
    logic [31:0] idex_read_data1_out,idex_read_data2_out;
    logic [31:0] idex_imm_out;
    logic [31:0] id_ex_instr_out;
    logic idex_reg_write_out;
    logic [1:0] idex_ALUOp_out,
    logic idex_mem_read_out,
    logic idex_mem_write_out,
    logic idex_branch_enable_out,
    logic idex_alu_src_out,
    logic idex_mem_to_reg_out, 
    logic idex_jump_out
    logic [31:0] pc_jal_link;
    logic [31:0] exmem_pc_result_out;
    logic [31:0] exmem_alu_result_out;
    logic [31:0] exmem_write_data_out;
    logic [4:0] exmem_rd_out;
    logic [2:0] exmem_funct3_out;
    logic exmem_reg_write_out;
    logic exmem_mem_read_out;
    logic exmem_mem_write_out;
    logic exmem_mem_to_reg_out;
    logic exmem_jump_out;
    logic [31:0] memwb_read_data_out;
    logic [31:0] memwb_addr_out;
    logic [31:0] memwb_pc_result_out;
    logic [4:0] memwb_rd_out;
    logic memwb_reg_write_out;
    logic memwb_mem_to_reg_out;
    logic memwb_jump_out;

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

    if_id_reg cpu_ifid_reg (
        .clk (clk),
        .rst (rst),
        .stall (if_id_stall),
        .flush (if_id_flush),
        .pc_in (pc_plus_4),
        .instr_in (instr),
        .pc_out (if_id_pc_out),
        .instr_out (if_id_instr_out)
    ); // pipeline stage register fetch->decode connections

    control cpu_control (
        .instr (if_id_instr_out),
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
        .rs1 (if_id_instr_out[19:15]),
        .read_data1 (read_data_1),
        .rs2 (if_id_instr_out[24:20]),
        .read_data2 (read_data_2),
        .rd (if_id_instr_out[11:7]),
        .write_data (jump ? pc_plus_4 : (MemtoReg ? mem_read_data : ALU_result))
    ); // Regfile connections

    imm_gen cpu_immgen (
        .instr (if_id_instr_out),
        .imm (imm_result)
    ); // immediate generator connections

    id_ex_reg cpu_id_ex_reg (
        .clk (clk),
        .rst (rst),
        .flush (id_ex_flush),
        .reg_write_in (RegWrite),
        .alu_type_in (ALUOp),
        .mem_read_in (MemRead),
        .mem_write_in (MemWrite),
        .branch_enable_in (BranchEnable),
        .alu_src_in (ALUSrc),
        .mem_to_reg_in (MemtoReg),
        .jump_in (jump),
        .pc_in (if_id_pc_out),
        .read_data1_in (read_data_1),
        .read_data2_in (read_data_2),
        .sign_ext32_in (imm_result),
        .instr_in (if_id_instr_out),
        .pc_out (id_ex_pc_out),
        .read_data1_out (idex_read_data1_out),
        .read_data2_out (idex_read_data2_out),
        .sign_ext32_out (idex_imm_out),
        .instr_out (id_ex_instr_out),
        .reg_write_out (idex_reg_write_out),
        .alu_type_out (idex_ALUOp_out),
        .mem_read_out (idex_mem_read_out),
        .mem_write_out (idex_mem_write_out),
        .branch_enable_out (idex_branch_enable_out),
        .alu_src_out (idex_alu_src_out),
        .mem_to_reg_out (idex_mem_to_reg_out),
        .jump_out (idex_jump_out)
    ); // pipeline stage register decode->execution connections

    alu_control cpu_alucontrol (
        .alu_type (idex_ALUOp_out),
        .instr (id_ex_instr_out),
        .alu_op (alu_op)
    ); // alu control connections

    // next-pc logic should be here

    assign alu_operand_1 = (id_ex_instr_out[6:0] == AUIPC) ? read_addr_wire : ((id_ex_instr_out[6:0] == LUI) ? 32'd0 : read_data_1); // handle cases for LUI/AUIPC instructions

    alu cpu_alu (
        .alu_op (alu_op),
        .operand_1 (alu_operand_1),
        .operand_2 (idex_alu_src_out ? idex_imm_out : idex_read_data2_out),
        .zero (zero),
        .lt_signed (lt_signed),
        .lt_unsigned(lt_unsigned),
        .alu_result (ALU_result)
    ); // Arithmetic logical unit connections

    assign pc_jal_link = id_ex_pc_out + 32'd4; // link value for JAL/JALR

    ex_mem_reg cpu_ex_mem_reg (
        .clk (clk),
        .rst (rst),
        .pc_result_in (pc_jal_link),
        .write_data_in (ALU_result),
        .rd_in (id_ex_instr_out[11:7]),
        .funct3_in (id_ex_instr_out[14:12]),
        .reg_write_in (idex_reg_write_out),
        .mem_read_in (idex_mem_read_out),
        .mem_write_in (idex_mem_write_out),
        .mem_to_reg_in (idex_mem_to_reg_out),
        .jump_in (idex_jump_out), 
        // inputs to here, rest outputs
        .pc_result_out (exmem_pc_result_out),
        .alu_result_out (exmem_alu_result_out),
        .write_data_out (exmem_write_data_out),
        .rd_out (exmem_rd_out),
        .funct3_out (exmem_funct3_out),
        .reg_write_out (exmem_reg_write_out),
        .mem_read_out (exmem_mem_read_out),
        .mem_write_out (exmem_mem_write_out),
        .mem_to_reg_out (exmem_mem_to_reg_out),
        .jump_out (exmem_jump_out)
    ); // pipeline stage register execution->memory connections

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

    mem_wb_reg cpu_mem_wb_reg (
        .clk (clk),
        .rst (rst),
        .read_data_in (mem_read_data),
        .addr_in (exmem_alu_result_out),
        .pc_result_in (exmem_pc_result_out),
        .rd_in (exmem_rd_out),
        .reg_write_in (exmem_reg_write_out),
        .mem_to_reg_in (exmem_mem_to_reg_out),
        .jump_in (exmem_jump_out),
        .read_data_out (memwb_read_data_out),
        .addr_out (memwb_addr_out),
        .pc_result_out (memwb_pc_result_out),
        .rd_out (memwb_rd_out),
        .reg_write_out (memwb_reg_write_out),
        .mem_to_reg_out (memwb_mem_to_reg_out),
        .jump_out (memwb_jump_out)
    );



endmodule

// fix pc logic, add forwarding unit and hazard unit
