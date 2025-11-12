# MultiCore RISC‑V Processor (RV32I)

A simple multi-core RISC‑V (RV32I) processor built from a classic 5‑stage pipeline (IF, ID, EX, MEM, WB) with basic hazard detection and data forwarding. The top-level integrates 4 cores, per‑core instruction memories, and a 4‑bank data memory so each core has its own bank.

## Prerequisites
- Icarus Verilog (iverilog, vvp)
- GTKWave (gtkwave)
- Optional: GNU Make (for Windows, install via MSYS2, Git Bash, or WSL for convenience)

Verify tools are on your PATH:
- `iverilog -V`
- `vvp -V`
- `gtkwave -V`
- `make -v` (optional)

## Quick start

Using Make (recommended):
1. Build, run simulation, and open waveform
   - `make`
   - This compiles to `processor.vvp`, runs it with `vvp`, and opens `waveform.vcd` in GTKWave.
   - You should see PASS lines for each core showing independent programs:
     - Core 0: x3=15, Core 1: x3=27, Core 2: x3=7, Core 3: x3=42

2. Clean artifacts
   - `make clean`

Compile only (no automatic run/GUI):
- `make processor.vvp`
- Then run: `vvp processor.vvp`
- Open waveform manually if desired: `gtkwave waveform.vcd`

If you don’t have `make`, you can copy the iverilog command echoed by the Makefile or use WSL/Git Bash to run `make`.

## Project layout

Top level and testbench
- `multicore_processor.v` — Top-level: instantiates 4 `riscv_core` instances, per‑core `ins_memory`, and shared 4‑bank `mem_controller`.
- `multicore_tb.v` — Testbench: drives clk/rst, dumps `waveform.vcd`, and performs simple checks.

Core pipeline (5‑stage)
- `riscv_core.v` — Integrates all stages and pipeline registers; exposes external IMEM/DMEM ports.

Fetch stage
- `fetch_stage/ins_fetch.v` — Computes PC+4 and passes instruction input.
- `fetch_stage/ins_memory.v` — Simple instruction ROM initialized via `$readmemh` (per core).
- `fetch_stage/prog_counter.v` — PC register.

Decode stage
- `decode_stage/control_unit.v` — RV32I decode to control signals.
- `decode_stage/imm_gen.v` — Immediate generator for I/S/B/U/J types.
- `decode_stage/reg_file.v` — 32×32 register file (x0 is hardwired to 0).
- `decode_stage/hazard_unit.v` — Load‑use hazard detection; requests a stall.
- `decode_stage/if_id_buffer.v` — IF/ID pipeline register.
- `decode_stage/forwarding_unit.v` — Data hazard detection for forwarding.
- `decode_stage/forward_mux.v` — Forwarding mux used by EX stage.

Execute stage
- `exec_stage/ALU` files: `ex_alu.v` (ALU), `ex_alu_src_mux.v` (RS2/IMM mux).
- `exec_stage/branch_unit.v` — Branch decision/target (BEQ logic).
- `exec_stage/id_ex_buffer.v` — ID/EX pipeline register.
- `exec_stage/ex_ma.v` — EX/MEM pipeline register.
- `exec_stage/ins_ex.v` — Execute stage (forwarding, ALU, branch).

Memory stage
- `mem_stage/ins_mem.v` — Issues DMEM signals and registers outputs to MEM/WB.
- `memory/mem_controller.v` — 4 independent 1KB word banks (one per core).

Writeback stage
- `write_stage/mem_wb_buffer.v` — MEM/WB pipeline register.
- `write_stage/ins_wb.v` — Writeback mux and feedback signals.

Other
- `program0.txt`..`program3.txt` — Hex program files for cores 0–3.
- `Makefile` — Windows‑friendly build script using iverilog/vvp/gtkwave.

## Programs (instruction memory)
Each core’s instruction memory is a ROM initialized from a hex file:
- Core 0 → `program0.txt`
- Core 1 → `program1.txt`
- Core 2 → `program2.txt`
- Core 3 → `program3.txt`

Built-in demo programs and expected results (checked by the testbench):
- Core 0: computes x3 = 15 (addi/add sequence)
- Core 1: computes x3 = 27 (addi/add sequence)
- Core 2: computes x3 = 7  (addi/add sequence)
- Core 3: computes x3 = 42 (addi/add sequence)

Format
- `$readmemh` expects one 32‑bit hex word per line (no `0x` prefix).
- Example words:
  - `00000013`  (ADDI x0, x0, 0 => NOP)
  - `00500093`  (ADDI x1, x0, 5)
  - `00A00113`  (ADDI x2, x0, 10)
  - `002081B3`  (ADD  x3, x1, x2)
- If a file has fewer than MEM_SIZE lines, the remaining ROM locations default to 0.

Changing programs
- Edit the `PROGRAM_FILE` parameter or replace the default files `program*.txt`.
- Rebuild (`make`) to re-run with the updated program(s).

## Tips & troubleshooting
- If GTKWave doesn’t launch automatically, you can open `waveform.vcd` manually.
- If `make` isn’t available on Windows, install it via MSYS2/Chocolatey or use WSL.
- Ensure `iverilog`, `vvp`, and `gtkwave` are in your PATH.
- The testbench checks a couple of registers as a quick sanity test; expand as needed.

## License
