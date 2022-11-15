OUTPUT_ARCH(riscv)
_entry_point = _vectors_start + 0x80; /*reset_handler*/
ENTRY(_entry_point)

MEMORY
{
   ROM (rx) : ORIGIN = 0x00000000, LENGTH = 0x1000 /* 4 KB */
   RAM (rw) : ORIGIN = 0x00001000, LENGTH = 0x400 /* 1 KB */
}

/* information variables */
STACK_SIZE = DEFINED(STACK_SIZE) ? STACK_SIZE : 512;
HEAP_SIZE  = DEFINED(HEAP_SIZE)  ? HEAP_SIZE  : 256;
DUMP_SIZE  = DEFINED(DUMP_SIZE)  ? DUMP_SIZE  : 0; /*The default value is 0. Can be changed in make*/

/* Align each sector to word boundaries */

SECTIONS {
   .vectors : { /*interrupt vectors*/
      . = ALIGN(4);
      _vectors_start = .;
      KEEP(*(.vectors))
      . = ALIGN(4);
      _vectors_end = .;
   } > ROM

   .text : {
      . = ALIGN(4);
      _text_start = .;
      *(.text)
      *(.text.*)
      . = ALIGN(4);
      _text_end = .;
   } > ROM

   .rodata : {
      . = ALIGN(4);
      /* Small RO data before large RO data */
      *(.srodata)
      *(.srodata.*)
      *(.rodata)
      *(.rodata.*)
   } > ROM

/* used by startup to initialize data */
   _data_load = LOADADDR(.data);
   . = ALIGN(4);
   .data : {
      _data_start = .;
      *(.sdata)
      *(.sdata.*)
      *(.data)
      *(.data.*)
      . = ALIGN(4);
      _data_end = .;
   } > RAM
/* } > RAM AT >ROM*/

   .bss : {
      . = ALIGN(4);
      _bss_start = .;
      *(.sbss)
      *(.sbss.*)
      *(.bss)
      *(.bss.*)
      *(COMMON)
      . = ALIGN(4);
      _bss_end = .;
   } > RAM

   .heap : {
      . = ALIGN(4);
      _heap_start = .;
      . += HEAP_SIZE;
      . = ALIGN(4);
      _heap_end = .;
   } > RAM

/* ensure there is enough room for stack */
   .stack ORIGIN(RAM) + LENGTH(RAM) - STACK_SIZE - DUMP_SIZE : {
      . = ALIGN(4);
      _stack_end = .;
      . += STACK_SIZE;
      . = ALIGN(4);
      _stack_start = .;
   } > RAM

   .save_dump : {
      . = ALIGN(4);
      _save_dump = .;
      . += DUMP_SIZE;
   } > RAM

}
