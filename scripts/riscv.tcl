rm -f *.bin

echo "   Info: ...assembler"

# Note keep in-sync with 'RV32E' parameter of IBEX core...
# high performance configuration
export ARCH="-mabi=ilp32 -march=rv32imc"
export CRT=src/cpp/asm/crt0.S
# Note: exclude multiplication instruction ('m') from code and RTL to improve FPGA timing
export ARCH="-mabi=ilp32 -march=rv32ic"

# embedded architecture (16 GPRs)
#export ARCH="-mabi=ilp32e -march=rv32e"
#export CRT=src/cpp/asm/crt0e.S
# Note: up to -O3 gives faster runtime
export OPT=-O3

export COMPILER=riscv64-unknown-elf

echo "   Info: ...compiler"
${COMPILER}-gcc ${OPT} ${ARCH} -nostartfiles -c ${CRT} -o start.o
${COMPILER}-gcc ${OPT} ${ARCH} -nostartfiles -c -Isrc/cpp/ibex src/cpp/ibex/isr.c src/cpp/ibex/irq.c
${COMPILER}-gcc ${OPT} ${ARCH} -nostartfiles -c -Isrc/cpp/ibex -Isrc/cpp/api src/cpp/${test}.c

echo "   Info: ...linker"
${COMPILER}-ld -EL -N -melf32lriscv -T scripts/ibex.ld isr.o irq.o ${test}.o start.o -o rom.elf
${COMPILER}-objdump -D rom.elf > reports/rom.lst
${COMPILER}-objcopy rom.elf data/rom.mem -O verilog --only-section=.vectors --only-section=.text --only-section=.rodata \
   --change-section-address .vectors-0x00000000 \
   --change-section-address .text-0x00000000 \
   --change-section-address .rodata-0x00000000 \
   --verilog-data-width 1
# --reverse-bytes=4 --verilog-data-width 4
rm -fr start.o isr.o irq.o ${test}.o rom.elf

echo "   Info: done."
