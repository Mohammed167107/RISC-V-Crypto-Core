# start.s
.section .text.start
.globl _start
_start:
    la   sp, 0x01FF       # set stack pointer near top of your data RAM
                            # (16KB DMEM => last word-aligned addr = 0x3FFC)
    call main               # jump into main
1:  j    1b                 # halt / infinite loop after return