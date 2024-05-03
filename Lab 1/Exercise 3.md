**Exercise 3**
---
Take a look at the [lab tools guide](https://pdos.csail.mit.edu/6.828/2018/labguide.html), especially the section on GDB commands. Even if you're familiar with GDB, this includes some esoteric GDB commands that are useful for OS work.

Set a breakpoint at address 0x7c00, which is where the boot sector will be loaded. Continue execution until that breakpoint. Trace through the code in boot/boot.S, using the source code and the disassembly file obj/boot/boot.asm to keep track of where you are. Also use the x/i command in GDB to disassemble sequences of instructions in the boot loader, and compare the original boot loader source code with both the disassembly in obj/boot/boot.asm and GDB.

Trace into bootmain() in boot/main.c, and then into readsect(). Identify the exact assembly instructions that correspond to each of the statements in readsect(). Trace through the rest of readsect() and back out into bootmain(), and identify the begin and end of the for loop that reads the remaining sectors of the kernel from the disk. Find out what code will run when the loop is finished, set a breakpoint there, and continue to that breakpoint. Then step through the remainder of the boot loader.
---

- In lab directory, start the debugger by run these command in 2 command step by step:
1. `make qemu-gdb`
2. `make gdb`
- Then i am in the gdb real mode and answer these questions:
  ![image](https://github.com/vilesport/General-Xv6/assets/89498002/fdc067af-aeec-4094-9850-4c9709bde8d1)
+ At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?
  +  
