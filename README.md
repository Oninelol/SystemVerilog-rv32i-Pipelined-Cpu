# SystemVerilog-rv32i-Pipelined-Cpu

A RISC-V processor written from scratch in SystemVerilog. It implements the RV32I base integer ISA plus the M (multiply/divide) extension. It is simulated with Verilator and it is written with synthesizable code.
The processor is implemented with a classic 5-stage pipeline with forwarding and hazard detection. 

## Features

- **Full RV32I base ISA** (FENCE/ECALL/EBREAK/CSR not implemented)
  - R-type: `ADD SUB SLL SLT SLTU XOR SRL SRA OR AND`
  - I-type ALU: `ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI`
  - Loads: `LB LH LW LBU LHU`
  - Stores: `SB SH SW`
  - Branches: `BEQ BNE BLT BGE BLTU BGEU`
  - Jumps: `JAL JALR`
  - Upper immediates: `LUI AUIPC`
- **M extension**: `MUL MULH MULHSU MULHU DIV DIVU REM REMU`, decoded from `instr[25]` (`funct7 = 0000001`)
- **Byte-addressed data memory** with access width and sign extension controlled by `funct3`
- **Two-level ALU control**: a coarse hint from the main decoder plus a typed ALU operation enum
- **Shared SystemVerilog package** with typed enums for opcodes, `funct3` fields, and ALU operations

## Architecture

### 5-Stage Pipelined Datapath

<img src="docs/pipeline.png" alt="5-stage pipeline" width="900">

### Overview of Modules

| Module | File | Description |
|---|---|---|
| `top` | `rtl/top.sv` | Connects all stages; next-PC selection, branch decision, forwarding muxes, writeback mux |
| `pc` | `rtl/pc.sv` | Program counter with stall enable; resets to `0x00000000` |
| `instr_mem` | `rtl/instr_mem.sv` | 4 KB instruction memory, loaded from `test_program.hex` |
| `control` | `rtl/control.sv` | Main decoder: register write, memory read/write, branch, jump, ALU source, writeback select |
| `regfile` | `rtl/regfile.sv` | 32 × 32-bit registers, `x0` hardwired to 0, same-cycle write-through bypass |
| `imm_gen` | `rtl/imm_gen.sv` | Sign-extended I, S, B, U, and J-type immediates |
| `alu_control` | `rtl/alu_control.sv` | Maps `alu_type`, `funct3`, and `funct7` bits to an ALU operation |
| `alu` | `rtl/alu.sv` | Integer and M-extension operations; `zero`, signed and unsigned less-than flags for branches |
| `data_mem` | `rtl/data_mem.sv` | 64 KB data memory, 16K × 32-bit words with byte enables |
| `forwarding_unit` | `rtl/pipeline/forward_unit.sv` | Selects EX/MEM or MEM/WB forwarding for each ALU operand |
| `hazard_unit` | `rtl/pipeline/hazard_unit.sv` | Load-use stall and branch/jump flush control |
| `if_id_reg`, `id_ex_reg`, `ex_mem_reg`, `mem_wb_reg` | `rtl/stages/*.sv` | Pipeline registers with stall and flush (flushed slots become `addi x0, x0, 0`) |
| `pkg` | `rtl/pkg.sv` | Opcode, `funct3`, and ALU-operation enums |

### Pipeline Stages

| Stage | What happens |
|---|---|
| **IF** – Fetch | PC selects the next instruction from instruction memory; PC + 4 by default |
| **ID** – Decode | Control signals, register file read (with write-through bypass), immediate generation, load-use hazard detection |
| **EX** – Execute | Forwarding muxes, ALU / multiply / divide, branch condition, branch and jump target calculation |
| **MEM** – Memory | Data memory load/store with byte, halfword, and word accesses |
| **WB** – Writeback | Selects ALU result, load data, or PC + 4 (for `JAL`/`JALR`) and writes the register file |

### Hazard Handling

**Data hazards** are resolved by forwarding wherever possible:

| Producer → consumer distance | Mechanism |
|---|---|
| 1 instruction | Forward from EX/MEM (highest priority) |
| 2 instructions | Forward from MEM/WB |
| 3 instructions | Register-file write-through bypass (write and read of the same register in one cycle) |
| Load followed immediately by a use | 1-cycle stall: hold PC and IF/ID, insert a bubble into ID/EX |

Writes to `x0` are never forwarded, `JAL`/`JALR` link values (PC + 4) are forwarded like ALU results, and store data and `JALR` base registers use the forwarded operands.

**Control hazards** use static not-taken prediction: fetch continues at PC + 4, branches and jumps resolve in EX, and on a taken branch or any jump the two younger instructions in IF/ID and ID/EX are flushed (2-cycle penalty). Wrong-path instructions are squashed before they can write registers or memory.

**Structural hazards** are avoided by construction: separate instruction and data memories, a register file with 2 read ports and 1 write port, dedicated adders for PC + 4, branch targets, and link values, and single-cycle multiply/divide.

## Verification

1. **Unit testbenches** (`tb/`) for the ALU, ALU control, immediate generator, forwarding unit, hazard unit, and a top-level program test.
2. **Official riscv-tests**: all 48 applicable `rv32ui` and `rv32um` tests pass, using a custom test environment (no CSRs or traps). Two tests do not apply to this design: `fence_i` requires self-modifying code, which is impossible with separate instruction memory, and `ma_data` requires misaligned-access support or traps.
3. **Randomized differential testing**: 500+ generated programs dense with back-to-back dependencies, load-use pairs, branches, jumps, and loops, plus 100 divide/remainder programs focused on edge cases. Each is run on the RTL and on a Python RV32IM golden model, and the final state of all registers and memory is compared.
4. **Compiled C programs** (GCC `-O2`, `-march=rv32im`) produce results identical to the golden model in both Verilator and Icarus Verilog.

## Performance

Measured in cycle-accurate simulation with ideal single-cycle memories (no caches), so these numbers characterize the pipeline itself. Cycle counts come from the RTL; exact instruction counts come from the golden model.

| Workload | Cycles | Instructions | IPC | Load-use stall cycles | Branch/jump flush cycles |
|---|---:|---:|---:|---:|---:|
| CoreMark | 394,406 | 304,046 | 0.771 | 5.3% | 17.7% |
| AES-SHA | 968,258 | 776,010 | 0.801 | 15.5% | 4.3% |
| Compression | 556,372 | 435,230 | 0.782 | 7.2% | 14.6% |
| FFT | 1,268,100 | 1,166,734 | 0.920 | 3.7% | 4.3% |
| Mergesort | 624,309 | 493,189 | 0.790 | 5.9% | 15.1% |

**EEMBC CoreMark** (standard 2K performance run, GCC `-O2`, CRCs validated): **2.43 CoreMark/MHz**, 411,731 cycles per iteration, CPI 1.31. This is an unofficial score; an official CoreMark result requires a run of at least 10 seconds on hardware.

The stall breakdown shows where cycles go: the 2-cycle taken-branch penalty dominates control-heavy code (CoreMark, mergesort, compression), while table-lookup code (AES-SHA) is limited by load-use stalls.

## Getting Started

### Requirements

- [Verilator](https://verilator.org) 5.x or [Icarus Verilog](https://steveicarus.github.io/iverilog/) 11+
- Optional: `riscv64-unknown-elf` binutils/GCC to assemble or compile your own programs

### Running a testbench

```bash
# Icarus Verilog: forwarding unit testbench
iverilog -g2012 -o sim rtl/pkg.sv $(ls rtl/*.sv | grep -v pkg.sv) rtl/pipeline/*.sv rtl/stages/*.sv \
    tb/forwarding_unit_tb.sv -s forwarding_unit_tb
vvp sim

# Verilator: top-level program test
verilator --binary --timing -Wno-fatal rtl/pkg.sv $(ls rtl/*.sv | grep -v pkg.sv) rtl/pipeline/*.sv \
    rtl/stages/*.sv tb/top_tb.sv --top-module top_tb
./obj_dir/Vtop_tb
```

`top_tb` runs `test_program.hex` from the simulation directory and checks the final register values it expects from that program.

### Running your own program

The instruction memory loads `test_program.hex` (one 32-bit word per line, little-endian instruction words) from the simulation directory, and execution starts at address `0x0`:

```bash
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 prog.S -o prog.o
riscv64-unknown-elf-ld -m elf32lriscv -Ttext=0 prog.o -o prog.elf
riscv64-unknown-elf-objcopy -O binary -j .text prog.elf prog.bin
python3 -c "d=open('prog.bin','rb').read(); d+=b'\0'*(-len(d)%4); \
[print('%08x'%int.from_bytes(d[i:i+4],'little')) for i in range(0,len(d),4)]" > test_program.hex
```

## Repository Structure

```
rtl/
├── pkg.sv              # shared enums
├── top.sv              # top-level datapath
├── pc.sv  instr_mem.sv  control.sv  regfile.sv  imm_gen.sv
├── alu.sv  alu_control.sv  data_mem.sv
├── pipeline/           # forwarding_unit, hazard_unit
└── stages/             # IF/ID, ID/EX, EX/MEM, MEM/WB pipeline registers
tb/                     # unit and top-level testbenches
docs/                   # pipeline diagram
```

