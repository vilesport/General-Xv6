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
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/849b25c4-f083-46f4-af7d-d324d0b69688)

- Then i am in the gdb that able to debug the project
  ![image](https://github.com/vilesport/General-Xv6/assets/89498002/3b7de91f-539a-4cc7-bd22-16f16074187d)
---
My result:

**Question 1:**
- After this instruction, the processor start executing 32-bit mode:
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/be9a9dfd-d906-4823-b165-f72ec44df2e5)
- Take a look at these code and description:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/0abd6bf4-11bb-47e7-a4ba-5e1aaa1fe393)
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/2d3dacb7-110e-4bd0-b990-ff72c387171f)
  - I found that the first instruction `lgdtw 0x7c64` just loads the Global Descriptor Table (GDT) with the base address 0x7c64, which is the segment that define the memory segments.
  - And then the next 3 instructions modify `%cr0` register, which contain control flag and then set the Protection Enable flag to 1 (enable) by `or` with 1.
  - After 3 instructions above, the program are now switched to Protection mode (32-bit mode) and be able to execute 32-bit code segment at 0x7c32.
  - It exactly causes the switch from 16- to 32-bit mode

**Question 2:**
- After boot from 16-bit mode to 32-bit mode, the boot loader starting execute bootmain
- In bootmain i found that after the loop, the bootmain jump into `*0x10018` (a.k.a elf header entry)
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/ddc0558b-a276-4cc7-a33b-7c9fcd3f384e)
- Below them is bad segment that only executed when elf header entry function return, but after jump into elf header entry, the boot loader section is done, so the last instruction boot loader executed is this:
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/a25412cb-1e13-4812-bb9e-8ebde6c958c8)
- Jump into the elf header entry, now the kernel start to setup the environment for the operating system by first warm boot and then load the physical address of `entry_pgdir` into cr3
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/6333725f-e441-4337-8d4f-00e54ec14b1e)
     - So that the first instruction of the kernel it just loaded is `mov $0x111000,%eax` - load the physical address of `entry_pgdir` into cr3

**Question 3:**
- The first instruction of the Kernel is store at `0xffff0`, 16 bytes before the end of the BIOS `0x100000`, which is at the very top of the 64KB area reserved for the ROM BIOS
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/4af1904e-07bb-43f0-81de-85cef53e1380)

**Question 4:**


