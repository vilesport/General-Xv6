**Exercise 3**
---
Take a look at the [lab tools guide](https://pdos.csail.mit.edu/6.828/2018/labguide.html), especially the section on GDB commands. Even if you're familiar with GDB, this includes some esoteric GDB commands that are useful for OS work.

Set a breakpoint at address 0x7c00, which is where the boot sector will be loaded. Continue execution until that breakpoint. Trace through the code in boot/boot.S, using the source code and the disassembly file obj/boot/boot.asm to keep track of where you are. Also use the x/i command in GDB to disassemble sequences of instructions in the boot loader, and compare the original boot loader source code with both the disassembly in obj/boot/boot.asm and GDB.

- Trace into bootmain() in boot/main.c, and then into readsect(). 
- Identify the exact assembly instructions that correspond to each of the statements in readsect(). 
- Trace through the rest of readsect() and back out into bootmain(), and identify the begin and end of the for loop that reads the remaining sectors of the kernel from the disk. 
- Find out what code will run when the loop is finished, set a breakpoint there, and continue to that breakpoint. 
- Then step through the remainder of the boot loader.

Target questions:
1. At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?
2. What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?
3. Where is the first instruction of the kernel?
4. How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?

---
Prepare the debugger:
- In lab directory, i start the debugger by run these command step by step:
1. `make qemu-gdb`
2. `make gdb` (i optimize the gdb by adding [target.xml](https://github.com/vilesport/Kernel-mode/blob/main/target.xml) and [i386-32bit.xml](https://github.com/vilesport/Kernel-mode/blob/main/i386-32bit.xml) into lab folder and then add `set tdesc filename target.xml` in .gdbinit to make it better)
- Then i am in real mode gdb
  ![image](https://github.com/vilesport/General-Xv6/assets/89498002/3b7de91f-539a-4cc7-bd22-16f16074187d)
---

