OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  .text : { *(.text) }
}

