`**Exercise 6**
---

We can examine memory using GDB's x command. The [GDB manual](https://sourceware.org/gdb/current/onlinedocs/gdb/Memory.html) has full details, but for now, it is enough to know that the command x/Nx ADDR prints N words of memory at ADDR. (Note that both 'x's in the command are lowercase.) Warning: The size of a word is not a universal standard. In GNU assembly, a word is two bytes (the 'w' in xorw, which stands for word, means 2 bytes).

Reset the machine (exit QEMU/GDB and start them again). Examine the 8 words of memory at 0x00100000 at the point the BIOS enters the boot loader, and then again at the point the boot loader enters the kernel. Why are they different? What is there at the second breakpoint? (You do not really need to use QEMU to answer this question. Just think.)

---

My result

- At the point the BIOS enter the bootloader, 8 words of memory at `0x100000`:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/2c4bd9c1-2a43-4dc2-8545-3677bc53831c)
- At the point the bootloader enters the kernel:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/dcd3738b-f70f-4a93-93e6-3f8e3e46d208)
- It is different because the memory after `0x100000` is only loaded through the bootloader, so when the BIOS enters the bootloader, there is nothing in there because the bootloader didn't load it yet, so it is empty. After the bootloader reads data from disk into memory, this data is loaded so it is different to the first one.


