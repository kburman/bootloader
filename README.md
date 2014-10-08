bootloader
==========

A Simple Boot loader which will load code from next sector and then start excuting it in protected mode.

## Building
nasm -fbin -oboot.bin boot_loader.asm
cat boot.bin kernel.bin > boot.img

kernel.bin is you binary format kernel code in 32bit in which text section start from the starting
