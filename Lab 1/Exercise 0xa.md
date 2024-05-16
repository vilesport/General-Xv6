**Exercise 10**
---

To become familiar with the C calling conventions on the x86, find the address of the test_backtrace function in obj/kern/kernel.asm, set a breakpoint there, and examine what happens each time it gets called after the kernel starts. How many 32-bit words does each recursive nesting level of test_backtrace push on the stack, and what are those words?

Note that, for this exercise to work properly, you should be using the patched version of QEMU available on the tools page or on Athena. Otherwise, you'll have to manually translate all breakpoint and memory addresses to linear addresses.

---

***My result:***
---

**Exercise questions:**

- This is what happen when each time test_backtrace function called:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/49ea4ccd-1fd0-4e45-ab6a-c2b0796abb77)
  - From this image, i see that when it called again and again, it push it's argument on the stack each time called.
  - It push 8 32-bit words on the stack each run.
    - In reverse order is:
      - Tracing saved ebp
      - Tracing esi argument
      - Tracing ebx argument
      - Tracing null frame from `sub $0x8,%esp`
      - Tracing esi from `mov 0x8(%ebp),%esi` -> `push %esi`
      - Tracing eax from `add $0x102be,%ebx` -> `lea -0xe8e8(%ebx),%eax` -> `push %eax`
      - Tracing null fram from `sub $0xc,%esp`
      - Tracing eax from `lea -0x1(%esi),%eax` -> `push %eax`
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/65cc348a-796e-42fd-821b-e45582e016ca)

