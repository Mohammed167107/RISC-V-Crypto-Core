import subprocess
import sys
import re

import struct

TOOLCHAIN_BIN = r"C:\Users\Mohammad\Desktop\xpack-riscv-none-elf-gcc-15.2.0-1-win32-x64\xpack-riscv-none-elf-gcc-15.2.0-1\bin"

GCC     = TOOLCHAIN_BIN + r"\riscv-none-elf-gcc.exe"
OBJDUMP = TOOLCHAIN_BIN + r"\riscv-none-elf-objdump.exe"
OBJCOPY = TOOLCHAIN_BIN + r"\riscv-none-elf-objcopy.exe"


def run(cmd, description):
    print(f"\n=== {description} ===")
    print(" ".join(cmd))
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.stdout:
        print(result.stdout)
    if result.stderr:
        print(result.stderr, file=sys.stderr)

    if result.returncode != 0:
        print(f"FAILED: {description} (exit code {result.returncode})", file=sys.stderr)
        sys.exit(result.returncode)

    return result.stdout


def build_and_disassemble(c_file, start_file, elf_out, linker_script="linker.ld"):
    gcc_cmd = [
        GCC,
        "-march=rv32im", "-mabi=ilp32",
        "-ffreestanding", "-nostdlib", "-nostartfiles", "-fno-builtin",
        "-fno-pic",
        "-O0", "-g",
        "-T", linker_script,
        "-Wl,--no-check-sections",     # <-- add this line
        "-o", elf_out,
        c_file, start_file,
    ]
    run(gcc_cmd, "Compiling + linking")

    objdump_cmd = [OBJDUMP, "-d", "-M", "no-aliases", elf_out]
    disassembly = run(objdump_cmd, "Disassembling")
    return disassembly



def extract_data_section(elf_file, dmem_byte_count=16384, output_file="dmem.hex"):
    """
    Dumps the linked .data/.rodata bytes from the ELF and writes them as
    one 8-bit hex byte per line (little-endian byte order, unchanged from
    the ELF), suitable for $readmemh into a byte-addressable memory[].
    """
    bin_out = "data_section.bin"
    run([OBJCOPY, "-O", "binary",
         "-j", ".data", "-j", ".rodata",
         elf_file, bin_out],
        "Extracting .data/.rodata")

    with open(bin_out, "rb") as f:
        raw = f.read()

    hex_bytes = [f"{b:02x}" for b in raw]
    hex_bytes += ["00"] * (dmem_byte_count - len(hex_bytes))  # pad rest of DMEM

    with open(output_file, "w") as f:
        f.write("\n".join(hex_bytes) + "\n")
    print(f"Wrote {len(hex_bytes)} bytes to {output_file}")


def extract_hex_instructions(disassembly_text, output_file="instructions.hex", fill_gaps=True):
    """
    Parses objdump -d output and extracts address + hex instruction pairs,
    writing just the hex words (one per line) to output_file in address order.
    """
    # Matches lines like:  90:   f81ff0ef                jal     ra,10 <add_two>
    pattern = re.compile(r'^\s*([0-9a-fA-F]+):\s+([0-9a-fA-F]{8})\b')

    instructions = {}  # address (int) -> hex string
    for line in disassembly_text.splitlines():
        match = pattern.match(line)
        if match:
            addr = int(match.group(1), 16)
            hex_word = match.group(2).lower()
            instructions[addr] = hex_word

    if not instructions:
        print("WARNING: no instructions found in disassembly text")
        return

    max_addr = max(instructions.keys())
    lines_out = []

    if fill_gaps:
        # Walk every 4-byte-aligned address from 0 to max_addr, filling any
        # missing slots with NOP (0x00000013) so word indices stay correct
        # for IM[address>>2] style memories.
        for addr in range(0, max_addr + 4, 4):
            hex_word = instructions.get(addr, "00000013")  # addi zero,zero,0 = NOP
            lines_out.append(hex_word)
    else:
        for addr in sorted(instructions.keys()):
            lines_out.append(instructions[addr])

    with open(output_file, "w") as f:
        f.write("\n".join(lines_out) + "\n")

    print(f"Wrote {len(lines_out)} instructions to {output_file}")


if __name__ == "__main__":
    disassembly = build_and_disassemble(
        c_file="h.c",
        start_file="start.s",
        elf_out="h.elf",
    )

    extract_data_section("h.elf", dmem_byte_count=16384)

    with open("h.dis", "w") as f:
        f.write(disassembly)
    print("\nSaved disassembly to h.dis")
    extract_hex_instructions(disassembly, "instructions.hex")