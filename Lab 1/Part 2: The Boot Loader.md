**The Boot Loader**
---

***Exercise 3***
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
***My result:***
---

**Exercise questions:**

- Trace into `readsect()`, this is the exact assembly instructions that correspond to each of the statements in readsect():
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/dfed6898-1b72-4a94-b24c-abfc793a1fb1)
     - `0x7c6a` is `waitdisk()`, `out %al,(dx)` is `outb()` and 4 last instructions correspond to `insl()`
- After all, this is the loop that reads the remaining sectors of the kernel from the disk:
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/2fed2c5d-68c6-4816-9825-1f79c543e0ee)
     - After the loop finished, it `call *0x10018`, which is the elf header entry.


**Target question**

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
     - So that the first instruction of the kernel it just loaded is `mov $0x111000,%eax` - load the physical address of `entry_pgdir` into eax before load into cr3

**Question 3:**
- Take a look at the memory layout of physical memory
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/be15c790-d1e4-48ed-a311-5c4e20172929)
     - And then look at the address of the first instruction executed by kernel
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/96ca024f-12fe-419d-adea-abd04997974b)
     - The address of it is `0x10000c`, which is right above the Bios partition, so that i know the first instruction of the kernel is stored at Extended Memory

**Question 4:**
- Look at this assembly code and the main.c:
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/284d2302-c26d-4d5f-a04b-e43396b103df)
     - The bootloader decide how many sectors it must read in oder to fetch the entire kernel from disk by `movzwl 0x1002c, $esi`, load the value stored at address `0x1002c` into esi

---

***Exercise 4***
---

Read about programming with pointers in C. The best reference for the C language is The C Programming Language by Brian Kernighan and Dennis Ritchie (known as 'K&R'). We recommend that students purchase this book (here is an [Amazon Link](https://www.amazon.com/C-Programming-Language-2nd/dp/0131103628/sr=8-1/qid=1157812738/ref=pd_bbs_1/104-1502762-1803102?ie=UTF8&s=books)) or find one of [MIT's 7 copies](https://libraries.mit.edu/research-support/new-search-platform-launched/).

Read 5.1 (Pointers and Addresses) through 5.5 (Character Pointers and Functions) in K&R. Then download the code for [pointers.c](https://pdos.csail.mit.edu/6.828/2018/labs/lab1/pointers.c), run it, and make sure you understand where all of the printed values come from. In particular, make sure you understand:
- Where the pointer addresses in printed lines 1 and 6 come from
- How all the values in printed lines 2 through 4 get there
- Why the values printed in line 5 are seemingly corrupted.

There are other references on pointers in C (e.g., [A tutorial by Ted Jensen](https://pdos.csail.mit.edu/6.828/2018/readings/pointers.pdf) that cites K&R heavily), though not as strongly recommended.

Warning: Unless you are already thoroughly versed in C, do not skip or even skim this reading exercise. If you do not really understand pointers in C, you will suffer untold pain and misery in subsequent labs, and then eventually come to understand them the hard way. Trust us; you don't want to find out what "the hard way" is.

---

***My result:***
---

**Exercise questions:**

![image](https://github.com/vilesport/General-Xv6/assets/89498002/3f6ad5dd-5655-4ecc-9bcc-f8caf9410a73)

- In line 1, the pointer printed out is address of array a, pointer b and pointer c. In these, a and c are point to stack, b point to the heap.
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/da1708c9-dd5a-49b5-a891-7814116e1bd8)

- In line 6, the pointer a is currently it address. Evenwhen both b and c equal to pointer a plus 1, b format as an integer pointer so it address greater than address pointer a 4 bytes - size of integer, c format as a char pointer, so it address greater than address pointer a just 1 bytes - size of char.
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/957b0d4c-77c0-4999-948c-b809b40555a2)

- ![image](https://github.com/vilesport/General-Xv6/assets/89498002/69b0227d-9e0a-4855-81b3-81a3bebdd5cc)
  - Line 2, because now pointer c is pointer a, so all change to value stored at address in pointer c almost make change to value stored at address in pointer a (because, it is the same)
  - Line 3, these are 3 format to access pointer
  - Line 4, because now pointer c is increase 1 unit, so it now equal to the old pointer c[1], so make change to current pointer c is change the c[1] value

- ![image](https://github.com/vilesport/General-Xv6/assets/89498002/4ef2b9aa-aa5e-4e89-9a2d-235391f73d4f)
  - In line 5, because pointer c format char before adding 1, so 1 unit it calculate is just 1 byte, not 4 byte like integer before, so the change make to pointer c cause corrupted, but it is intend.
  - The array before change:
    - `| c8 00 00 00 | 90 01 00 00 | 2d 01 00 00|`
    - `|     200     |     400     |    301     |`
  - The array after change:
    - `| c8 00 00 00 | 90 f4 01 00 | 00 01 00 00|`
    - `|     200     |    128144   |    256     |`
  - Because when write data to address, it write the number of bytes equal to the data type bytes, so it will write 4 bytes from the pointer c + 1, that make the values printed in line 5 are seemingly corrupted.

---

***Exercise 5***
---

Trace through the first few instructions of the boot loader again and identify the first instruction that would "break" or otherwise do the wrong thing if you were to get the boot loader's link address wrong. Then change the link address in boot/Makefrag to something wrong, run make clean, recompile the lab with make, and trace into the boot loader again to see what happens. Don't forget to change the link address back and make clean again afterward!

---

***My result:***
---

**Exercise questions:**

- ![image](https://github.com/vilesport/General-Xv6/assets/89498002/cb7e40fb-acaa-463c-a132-5abfb1815de2)
  
  - After modified the link address to `0x7c99` instead of `0x7c00` default, the program have some strange behaviour when switch from 16-bit mode to 32-bit mode. 
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/ce170ff6-c985-4702-8d6f-11884ac056cd)

  - I found that because when lgdt, the global descripter table are not at that address, so when switch to 32-bit by changing cr0 PE flag bit, it can't ljmp into 32-bit segment because the segment register is not correct to run 32-bit mode, and also the segment is not correct to, so ljmp from segment and offset make something strange and then reboot, try to switch from 16-bit to 32-bit mode again

---

`**Exercise 6**
---

We can examine memory using GDB's x command. The [GDB manual](https://sourceware.org/gdb/current/onlinedocs/gdb/Memory.html) has full details, but for now, it is enough to know that the command x/Nx ADDR prints N words of memory at ADDR. (Note that both 'x's in the command are lowercase.) Warning: The size of a word is not a universal standard. In GNU assembly, a word is two bytes (the 'w' in xorw, which stands for word, means 2 bytes).

Reset the machine (exit QEMU/GDB and start them again). Examine the 8 words of memory at 0x00100000 at the point the BIOS enters the boot loader, and then again at the point the boot loader enters the kernel. Why are they different? What is there at the second breakpoint? (You do not really need to use QEMU to answer this question. Just think.)

---

***My result:***
---

**Exercise questions:**

- At the point the BIOS enter the bootloader, 8 words of memory at `0x100000`:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/2c4bd9c1-2a43-4dc2-8545-3677bc53831c)
- At the point the bootloader enters the kernel:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/dcd3738b-f70f-4a93-93e6-3f8e3e46d208)
- It is different because the memory after `0x100000` is only loaded through the bootloader, so when the BIOS enters the bootloader, there is nothing in there because the bootloader didn't load it yet, so it is empty. After the bootloader reads data from disk into memory, this data is loaded so it is different to the first one.

---
