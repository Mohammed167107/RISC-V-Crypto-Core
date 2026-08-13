MEMORY
{
    IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 2K
    DMEM (rwx) : ORIGIN = 0x00000000, LENGTH = 16K   /* distinct link-time address */
}

SECTIONS
{
    .text : {
        *(.text.start)
        *(.text)
        *(.text.*)
    } > IMEM

    .rodata : { *(.rodata) *(.rodata.*) } > DMEM
    .data   : { *(.data) *(.data.*) } > DMEM
    .bss : {
        __bss_start = .;
        *(.bss) *(.bss.*) *(COMMON)
        __bss_end = .;
    } > DMEM

    __stack_top = ORIGIN(DMEM) + LENGTH(DMEM);
}