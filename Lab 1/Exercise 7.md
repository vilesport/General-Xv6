**Exercise 7**
---

Use QEMU and GDB to trace into the JOS kernel and stop at the movl %eax, %cr0. Examine memory at 0x00100000 and at 0xf0100000. Now, single step over that instruction using the stepi GDB command. Again, examine memory at 0x00100000 and at 0xf0100000. Make sure you understand what just happened.

What is the first instruction after the new mapping is established that would fail to work properly if the mapping weren't in place? Comment out the movl %eax, %cr0 in kern/entry.S, trace into it, and see if you were right.

---

My result

- This is what happen before and after `movl %eax, %cr0` to memory at `0x00100000` and at `0xf0100000`:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/06836a48-0a63-460d-afce-8a7518faffab)
  - This will be the first instruction after the new mapping is established that would fail to work properly if the mapping weren't in place
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/423f5476-4949-440c-a985-dcefd5bcb8a7)
    - Because now, `jmp *%eax` will jump to address that stored in `eax`, and `eax` is `0xf010002f`, which is the virtual address. So if the mapping weren't in place, this instruction would fail.
