# RISC-V Crypto Core

A from-scratch RV32IM processor implementation in Verilog, developed as a
research platform for exploring hardware acceleration of cryptographic
workloads on RISC-V. This is a solo, in-progress research project — the
base ISA implementation is functional; the cryptography-acceleration work
this project is ultimately aimed at is upcoming, not yet implemented.

> **Status:** early / in-progress. The core executes real compiled RV32IM
> programs correctly (verified via simulation), but verification is
> currently manual, and no crypto-specific extensions exist yet. See
> [Known Limitations](#known-limitations-and-honesty-notes) below.

---

## Table of Contents

- [Motivation](#motivation)
- [Architecture](#architecture)
- [Supported Instructions](#supported-instructions)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Building a Program](#building-a-program)
- [Running the Simulation](#running-the-simulation)
- [Verifying Output](#verifying-output)
- [Known Limitations and Honesty Notes](#known-limitations-and-honesty-notes)
- [Roadmap](#roadmap)
- [License](#license)
- [Author / Contact](#author--contact)

---

## Motivation

General-purpose RISC-V cores spend a disproportionate number of cycles on
operations that dominate common cryptographic primitives — modular
arithmetic, bit permutations, wide multiplications, constant-time
conditional logic. This project's long-term goal is to design and
integrate custom instruction-set extensions (and supporting datapath
hardware) that accelerate these operations directly in silicon, rather
than relying purely on software implementations running on a stock RV32I
core.

The current phase of the project is the necessary first step: a correct,
well-understood baseline RV32IM core, plus a working software/hardware
co-verification pipeline (compile a C program → run it on the core in
simulation → confirm the result is correct). Crypto-specific extensions
will be built on top of this baseline.

---

## Architecture

The core (`processor.v`) is a **single-cycle**, monolithic-module RV32IM
implementation — every instruction fetches, decodes, executes, accesses
memory, and writes back within a single clock cycle. There is currently
no pipelining, hazard detection, or forwarding logic, since single-cycle
execution makes none of that necessary.

### Top-level ports

```verilog
module processor(
    input  test_button,
    output [31:0] data_seg_test,
    input  clk,
    input  rst,
    output [31:0] pc
);
```

### Datapath overview

The design follows a fairly standard RISC-V single-cycle datapath, built
from discrete submodules wired together in `processor.v`:

| Submodule | Role |
|---|---|
| `pc` | Program counter register |
| `adder` (×3) | PC+4 computation, branch/jump target computation, JALR target computation |
| `instructionMemory` (`i_mem`) | Instruction memory, indexed by `pc` |
| `control_unit` | Decodes opcode/func3/func7 into all control signals |
| `register_file` (`rg_file`) | 32×32-bit general-purpose register file |
| `extend`, `extend_20bits_j`, `extend_B` | Immediate sign-extension for I-type, J-type, and B-type formats |
| `branching_unit` | Evaluates branch conditions (`beq`, `bne`, `blt`, etc.) |
| `alu` | Arithmetic/logic unit, covers RV32I + RV32M operations |
| `data_mem` (`d_mem`) | Data memory, addressed by ALU result |
| `mux2_to_1` / `mux3_to_1` / bit-width variants | Datapath muxing (operand selection, write-back source selection, branch/jump target selection) |

Memory is accessed via two independent instances: `i_mem` (instruction
fetch, address = `pc`) and `d_mem` (load/store, address = ALU result) —
consistent with a Harvard-style split between instruction and data
memory.

---

## Supported Instructions

**RV32I (base integer ISA):**
```
add sub xor or and sll srl sra slt sltu
addi xori ori andi slli srli srai slti sltiu
lb lh lw lbu lhu sb sh sw
beq bne blt bge bltu bgeu
jal jalr lui auipc
```

**RV32M (multiply/divide extension):**
```
mul mulh mulsu mulu div divu rem remu
```

Not yet implemented: RV32F/D (floating point), RV32C (compressed), CSR
instructions, and interrupts/exceptions. There are currently no
crypto-specific custom instructions — the ISA is stock RV32IM.

---

## Repository Structure

```
.
├── processor.v      # CPU core (RTL) + current testbench (p_tb)
├── test.py           # build pipeline: compiles a C program, produces
│                      # instructions.hex and dmem.hex
├── h.c                # example program under test (currently: bubble sort)
├── start.s            # _start: stack init + call into main()
├── linker.ld           # memory map (IMEM/DMEM regions, __stack_top symbol)
└── README.md
```

The repo is currently flat — no `rtl/`, `tb/`, or `docs/` subfolders yet.
As more test programs and RTL modules are added, this will likely need
restructuring (see [Roadmap](#roadmap)).

---

## Prerequisites

- **Python 3**
- **[xPack RISC-V GCC toolchain][(https://xpack.github.io/riscv-none-elf-gcc/](https://xpack-dev-tools.github.io/riscv-none-elf-gcc-xpack/blog/2025/10/23/riscv-none-elf-gcc-v15-2-0-1-released))**
  (`riscv-none-elf-gcc`) — update the `TOOLCHAIN_BIN` path in `test.py` to
  point at your local install:
  ```python
  TOOLCHAIN_BIN = r"C:\path\to\xpack-riscv-none-elf-gcc-<version>\bin"
  ```
- **ModelSim** (the free/student edition is sufficient) for RTL simulation

---

## Getting Started

This walks through the full workflow end-to-end: getting the repo,
installing the toolchain, writing a C program, building it, and running it
on the core in simulation. The sections after this one ([Building a
Program](#building-a-program), [Running the Simulation](#running-the-simulation))
go into more detail on individual steps — use this section as the overview.

### 1. Clone the repository

```bash
git clone https://github.com/Mohammed167107/RISC-V-Crypto-Core.git
cd RISC-V-Crypto-Core
```

### 2. Install the RISC-V toolchain

Download the **xPack RISC-V GCC toolchain** for your platform:
👉 [https://xpack.github.io/riscv-none-elf-gcc/](https://xpack-dev-tools.github.io/riscv-none-elf-gcc-xpack/blog/2025/10/23/riscv-none-elf-gcc-v15-2-0-1-released/)

Extract it anywhere on disk, then open `test.py` and point `TOOLCHAIN_BIN`
at the `bin` folder inside your extracted copy:

```python
TOOLCHAIN_BIN = r"C:\path\to\xpack-riscv-none-elf-gcc-<version>\bin"
```

(On macOS/Linux, use a normal forward-slash path instead, e.g.
`"/opt/xpack-riscv-none-elf-gcc-<version>/bin"`.)

Confirm the toolchain works on its own before going further:

```bash
"<TOOLCHAIN_BIN>/riscv-none-elf-gcc" --version
```

### 3. Install ModelSim

Any edition that supports Verilog-2001 and `$readmemh` works; the free
ModelSim Intel FPGA Starter Edition (or a student license) is sufficient.
No special project setup is required beyond adding `processor.v` (which
also contains the current testbench, `p_tb`) to a ModelSim project/library.

### 4. Write or edit a C program

The program under test lives in `h.c`. It must be **freestanding** — no
`stdio.h`, no dynamic allocation, no OS assumptions — since it runs
directly on bare hardware with no runtime support beyond what `start.s`
provides. `<stdint.h>` (for fixed-width types like `int32_t`) is fine to
use.

```c
#include <stdint.h>

int main(void) {
    // your code here
}
```

`main` is the required entry point — `start.s` calls into it directly
after setting up the stack. If `main` returns, execution falls into an
infinite loop (there's no OS to return control to).

### 5. Build

From the repo root, with the toolchain path configured:

```bash
python test.py
```

On success this produces:
- `h.elf` — the linked binary
- `h.dis` — full disassembly (useful for finding exact memory addresses
  of your variables — see [Verifying Output](#verifying-output))
- `instructions.hex` — for loading into `IMEM`
- `dmem.hex` — for loading into `DMEM`

If this fails, check [Building a Program](#building-a-program) below for
what each compiler flag does, and the
[Known Limitations](#known-limitations-and-honesty-notes) section for
issues that have come up before (e.g. linker section-overlap errors).

### 6. Load the program into the simulator

In your ModelSim testbench (or directly via the transcript/console),
load both hex files into the corresponding memories before running the
clock:

```verilog
initial begin
    $readmemh("instructions.hex", uut.i_mem.memory);
    $readmemh("dmem.hex", uut.d_mem.memory);
end
```

(Adjust the hierarchical paths if your instance names differ from
`i_mem`/`d_mem`.)

### 7. Run the simulation

```bash
vsim p_tb
run -all
```

Or, from the ModelSim GUI: compile `processor.v`, load `p_tb` as the
simulation target, add signals of interest (at minimum `PC`) to a
waveform, and run.

### 8. Check the result

Once execution reaches the halt loop, inspect the relevant `DMEM` address
range (either in the waveform viewer, or via a memory dump if you're
using the logging testbench) and compare against what your C program
should have produced. See [Verifying Output](#verifying-output) for how
to work out *which* addresses to look at, and a caution about sampling
timing.

---

## Building a Program

```bash
python test.py
```

This compiles `h.c` + `start.s` freestanding (no OS, no libc, no CRT —
`start.s` supplies `_start` directly), links against `linker.ld`, and
produces two hex files for simulation:

- **`instructions.hex`** — one 32-bit instruction word per line, extracted
  from the disassembled `.text` section, for loading into `IMEM`
- **`dmem.hex`** — the initialized `.data`/`.rodata` contents, extracted
  separately (since disassembly only covers executable code and would
  otherwise silently omit initialized data), for loading into `DMEM`

### Key compiler flags and why they matter

| Flag | Purpose |
|---|---|
| `-march=rv32im -mabi=ilp32` | Target ISA/ABI matching the core |
| `-ffreestanding -nostdlib -nostartfiles` | No OS assumptions; `start.s` is the real entry point |
| `-fno-pic` | Keeps call sequences as simple `jal`s rather than `auipc`+`jalr` pairs, simplifying extraction |
| `-O0 -g` | Unoptimized, debuggable codegen — makes manually tracing stack offsets during debugging tractable |
| `-Wl,--no-check-sections` | `IMEM` and `DMEM` are separate physical memories that both start at address `0x0` in the linker script — this matches the hardware but trips GNU `ld`'s default overlap check, which doesn't know the two regions are physically independent |

---

## Running the Simulation

1. change directory in modelsim to the right folder and then Compile the design using:
   ```bash
   vlog pack.v
   ```
3. Run the testbench in `processor.v` (`p_tb`):
   ```bash
   vsim p_tb
   ```
4. The testbench clocks the design and watches `PC`. When execution
   reaches the halt loop (`_start`'s trailing `j` self-loop, currently
   hardcoded as `PC == 32'h00000008`), it dumps a fixed address range of
   `DMEM` to a log file.

---

## Verifying Output

The example program (bubble sort over an 8-element `int32_t` array) sorts
its array **in place, on a stack-resident copy** — not at the array's
original `.data` address. Concretely:

- `main` copies the array from `.data` (address `0x0`) onto its own stack
  frame.
- `bubble_sort` receives a pointer to that stack copy and sorts it there;
  nothing is written back to the original `.data` location.
- The final sorted values live at a `sp`/`s0`-relative address that
  depends on the stack pointer value set in `_start` and each function's
  local frame size — **recompute this from the disassembly (`h.dis`) if
  `start.s` or `linker.ld` changes**, rather than assuming a fixed address.

---

## Known Limitations and Honesty Notes

This project is at an early, actively-developed stage. Documenting known
gaps here deliberately, rather than glossing over them:

- **Verification is manual.** Correctness is currently confirmed by
  computing expected stack addresses by hand from the disassembly, then
  visually inspecting simulator waveforms or a dumped memory log —
  there's no automated pass/fail assertion yet.
- **The halt-detection address is hardcoded** (`PC == 32'h00000008`),
  tied to this specific program's build. It will silently fail to detect
  completion (and the simulation will run forever) if the linker script,
  `start.s`, or the program changes such that the halt loop moves.
- **Only one test program exists** (bubble sort). It exercises loads,
  stores, branches, and function calls, but not the RV32M multiply/divide
  instructions, nor any crypto-relevant workload.
- **No crypto-specific hardware exists yet.** The core is currently a
  standard RV32IM implementation; the acceleration work motivating this
  project's name has not started.
- **Single-cycle only.** No pipelining, so no hazard/forwarding logic
  exists — this simplifies correctness but limits performance analysis
  relevance for now.

---

## Roadmap

- [ ] Self-checking testbench with automated PASS/FAIL comparison against expected output
- [ ] Additional test programs (multiply/divide-heavy, memory-intensive, control-flow-heavy)
- [ ] UVM verification environment (monitor + scoreboard) for reusable, program-agnostic testing
- [ ] DPI-C integration for golden-model comparison and/or direct ELF loading
- [ ] Design and implement first crypto-acceleration extension(s)
- [ ] Reorganize repo into `rtl/`, `tb/`, `docs/`, `sw/` once the file count grows

---

## License

This project is licensed under the **MIT License**.

MIT was chosen deliberately: it's the most permissive common open-source
license, allowing anyone — individuals, other researchers, or companies —
to use, modify, and redistribute this code (including commercially) with
only a requirement to retain the copyright notice. For a solo research
project intended to demonstrate ability and attract collaborators or
academic interest, this maximizes who can actually engage with the work
with no legal friction. (The main alternative, copyleft licenses like
GPL, would force anyone building on this code to also open-source their
derivative work — good for keeping the ecosystem open, but a real barrier
for potential industry collaborators. Publishing with no license at all
would legally mean "all rights reserved," meaning no one is permitted to
use, copy, or fork the code at all — the opposite of what's useful here.)

See [`LICENSE`](LICENSE) for the full text.

---

## Author / Contact

**Mohammad Shobaki**
- Communications and computer engineering student
- LinkedIn: https://www.linkedin.com/in/mohammad-shobaki/
- Email: mohammedshobaky8@gmail.com
- Discord: @uicheater

Feedback, questions, and contributions are welcome — this is an active,
solo research effort, and outside perspective is genuinely valuable at
this stage.
