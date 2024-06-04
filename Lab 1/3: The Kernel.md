**The Kernel**
---

***Exercise 7***
---

Use QEMU and GDB to trace into the JOS kernel and stop at the movl %eax, %cr0. Examine memory at 0x00100000 and at 0xf0100000. Now, single step over that instruction using the stepi GDB command. Again, examine memory at 0x00100000 and at 0xf0100000. Make sure you understand what just happened.

What is the first instruction after the new mapping is established that would fail to work properly if the mapping weren't in place? Comment out the movl %eax, %cr0 in kern/entry.S, trace into it, and see if you were right.

---

***My result:***
---

**Exercise questions:**

- This is what happen before and after `movl %eax, %cr0` to memory at `0x00100000` and at `0xf0100000`:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/06836a48-0a63-460d-afce-8a7518faffab)
  - This will be the first instruction after the new mapping is established that would fail to work properly if the mapping weren't in place
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/423f5476-4949-440c-a985-dcefd5bcb8a7)
    - Because now, `jmp *%eax` will jump to address that stored in `eax`, and `eax` is `0xf010002f`, which is the virtual address. So if the mapping weren't in place, this instruction would fail.

---

**Exercise 8**
---
We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment.

Target question:
1. Explain the interface between printf.c and console.c. Specifically, what function does console.c export? How is this function used by printf.c?
2. Explain the following from console.c:
```c!
if (crt_pos >= CRT_SIZE) {
          int i;
          memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
          for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
                crt_buf[i] = 0x0700 | ' ';
          crt_pos -= CRT_COLS;
}
```
3. For the following questions you might wish to consult the notes for Lecture 2. These notes cover GCC's calling convention on the x86.
- Trace the execution of the following code step-by-step:
```c!
int x = 1, y = 3, z = 4;
cprintf("x %d, y %x, z %d\n", x, y, z);
```
- In the call to cprintf(), to what does fmt point? To what does ap point?
- List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.

4. Run the following code.
```c!
    unsigned int i = 0x00646c72;
    cprintf("H%x Wo%s", 57616, &i);
```
- What is the output? Explain how this output is arrived at in the step-by-step manner of the previous exercise. [Here's an ASCII table](https://ascii.cl/) that maps bytes to characters.
- The output depends on that fact that the x86 is little-endian. If the x86 were instead big-endian what would you set i to in order to yield the same output? Would you need to change 57616 to a different value?

[Here's a description of little- and big-endian](http://www.webopedia.com/TERM/b/big_endian.html) and [a more whimsical description](http://www.networksorcery.com/enp/ien/ien137.txt).

5. In the following code, what is going to be printed after 'y='? (note: the answer is not a specific value.) Why does this happen?
```c!
cprintf("x=%d y=%d", 3);
```
6. Let's say that GCC changed its calling convention so that it pushed arguments on the stack in declaration order, so that the last argument is pushed last. How would you have to change cprintf or its interface so that it would still be possible to pass it a variable number of arguments?

---

***My result:***
---

**Exercise questions:**

- This is the code to print octal number:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/c7cff345-68d9-487e-86b4-09d244280d9c)
- This is my code replaced:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/7b2ca369-541f-483d-b649-99a5e13db1c8)
  - ```c!
    case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			goto number;
    ```

**Target questions:**

1. Both printf.c and console.c are designed to print to stdout. Printf.c just pass the target printed to other functions, which also do not directly print to stdout. Console.c is different, it directly output to stdout.

2. The code run when pointer on console out the current window range, it expand another row and init ' ' character before end.
   - It is why the console have no scroll bar because the console only grow down, when an row added at the bottom, the top row will be replaced.

3. In cprintf(), the fmt point to the format string, the ap point to the argument. In this case, ap first point to the argument x, then y and z equal to the request argument that format string need.
   - cons_putc(): argument is `int c`.
   - va_arg(): first it point to first argument as va_list pointer, after the function, it still point to the same point, but as defined type pointer.
   - vcprintf(): it first argument is char pointer to the first character of format string, it second argument is the list of argument the format string require.
  
4. The output is `He110 World`. First it output the `He`, and then format value `57616` as `%x` format give the result `110`. Then it print out ` Wo` and format `0x00646c72` as `%s` format and the result is `dlr`. But it is little-endian so `dlr` will be `rld` and the final result is `He` + `110` + ` Wo` + `rld` = `He110 World`.
   - If it is big-endian, we only have to change the value of i to `0x00726c64`. It no need to change `57616` to a different value.
  
5. Because the function only give the format 1 argument when it need 2, the argument for format `%d` at y will take in order of calling convention. So it will be some value in stack.

---

**Exercise 9**
---

Determine where the kernel initializes its stack, and exactly where in memory its stack is located. How does the kernel reserve space for its stack? And at which "end" of this reserved area is the stack pointer initialized to point to?

---

***My result:***
---

**Exercise questions:**

- This is where the kernel initializes its stack:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/982294a7-b02c-4c7f-b4bd-4d0934dd834e)
- This is where the stack is located:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/f24a6de1-2259-471b-88b2-1dc03bcf36e0)
  - It also included the current address.
- The kernel reserve space for its stack by calling init:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/897ed8e3-a950-450d-b4c0-a2ad45ac69f7)
- At this end of reserved area the stack pointer initialized point to:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/3d3a1676-d7b1-4e29-ab12-2935ea379e3b)

---

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
      - Tracing null frame from `sub $0xc,%esp`
      - Tracing eax from `lea -0x1(%esi),%eax` -> `push %eax`
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/65cc348a-796e-42fd-821b-e45582e016ca)

---

**Exercise 11**
---

Implement the backtrace function as specified above. Use the same format as in the example, since otherwise the grading script will be confused. When you think you have it working right, run make grade to see if its output conforms to what our grading script expects, and fix it if it doesn't. After you have handed in your Lab 1 code, you are welcome to change the output format of the backtrace function any way you like.

If you use read_ebp(), note that GCC may generate "optimized" code that calls read_ebp() before mon_backtrace()'s function prologue, which results in an incomplete stack trace (the stack frame of the most recent function call is missing). While we have tried to disable optimizations that cause this reordering, you may want to examine the assembly of mon_backtrace() and make sure the call to read_ebp() is happening after the function prologue.

---

***My result:***
- This is my code that run correctly and got 20 points from count and arguments, so i think it is correct
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/117a2952-c5b8-49b4-992c-a217b4cf3b22)
  - ```c!
    int mon_backtrace(int argc, char **argv, struct Trapframe *tf)
    {
    	// Your code here.
    	cprintf("Stack backtrace:\n");
    	for(uint32_t* ebp = (uint32_t *) read_ebp(); ebp; ebp = (uint32_t*) ebp[0])
    	{
    		cprintf("ebp %08x  eip %08x  args ", ebp, ebp[1]);
    		for(int i = 2; i < 7; i++)
    			cprintf("%08x ", ebp[i]);
    		cprintf("\n");
    	}
    	return 0;
    }
    ```
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/8e361a03-62ab-4cd7-9771-bec9fcd03642)
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/4e08de1a-539c-48e2-aa4e-9c8b033e7a00)

---

![image](https://github.com/vilesport/General-Xv6/assets/89498002/ffb2fdb8-4a7c-49d0-890d-f5c586e3be96)**Exercise 12**
---

Modify your stack backtrace function to display, for each eip, the function name, source file name, and line number corresponding to that eip.

In debuginfo_eip, where do __STAB_* come from? This question has a long answer; to help you to discover the answer, here are some things you might want to do:

look in the file kern/kernel.ld for __STAB_*
run objdump -h obj/kern/kernel
run objdump -G obj/kern/kernel
run gcc -pipe -nostdinc -O2 -fno-builtin -I. -MD -Wall -Wno-format -DJOS_KERNEL -gstabs -c -S kern/init.c, and look at init.s.
see if the bootloader loads the symbol table in memory as part of loading the kernel binary
Complete the implementation of debuginfo_eip by inserting the call to stab_binsearch to find the line number for an address.

Add a backtrace command to the kernel monitor, and extend your implementation of mon_backtrace to call debuginfo_eip and print a line for each stack frame of the form:
```
K> backtrace
Stack backtrace:
  ebp f010ff78  eip f01008ae  args 00000001 f010ff8c 00000000 f0110580 00000000
         kern/monitor.c:143: monitor+106
  ebp f010ffd8  eip f0100193  args 00000000 00001aac 00000660 00000000 00000000
         kern/init.c:49: i386_init+59
  ebp f010fff8  eip f010003d  args 00000000 00000000 0000ffff 10cf9a00 0000ffff
         kern/entry.S:70: <unknown>+0
K>
```
Each line gives the file name and line within that file of the stack frame's eip, followed by the name of the function and the offset of the eip from the first instruction of the function (e.g., monitor+106 means the return eip is 106 bytes past the beginning of monitor).

Be sure to print the file and function names on a separate line, to avoid confusing the grading script.

Tip: printf format strings provide an easy, albeit obscure, way to print non-null-terminated strings like those in STABS tables. printf("%.*s", length, string) prints at most length characters of string. Take a look at the printf man page to find out why this works.

You may find that some functions are missing from the backtrace. For example, you will probably see a call to monitor() but not to runcmd(). This is because the compiler in-lines some function calls. Other optimizations may cause you to see unexpected line numbers. If you get rid of the -O2 from GNUMakefile, the backtraces may make more sense (but your kernel will run more slowly).

---
***My result:***
- This exercise request manything so i will explain what i did orderly:
  - First, i write the code for searching eip num line by the given infomations
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/f37f8aa8-c657-41bb-a951-aa767d5f5fe1)
    - ```c!
      	lnum = lline;
    	rnum = rline;
    	stab_binsearch(stabs, &lnum, &rnum, N_SLINE, addr);
    	if (lnum <= rnum)
    		info->eip_line = rnum;
    	else
    		return -1;
      ```
    - It is request that i have to declare lnum and rnum stand for left numline and right numline above
      - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/f186f085-f5b8-4b1f-9fde-f119e198a419)
    - So that the function debuginfo_eip would work correcty
  - Then, backinto monitor.c, i have to reimplement mon_stackbacktrace() function so it would write eip_info right below it's arguments
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/54fceaf5-0d11-4279-a646-ba29d0c5d5f8)
```c!
int mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
// Your code here.
struct Eipdebuginfo info;
cprintf("Stack backtrace:\n");
for(uint32_t* ebp = (uint32_t *) read_ebp(); ebp; ebp = (uint32_t*) ebp[0])
{
	cprintf("ebp %08x  eip %08x  args ", ebp, ebp[1]);
	for(int i = 2; i < 7; i++)
		cprintf("%08x ", ebp[i]);
	cprintf("\n");
	debuginfo_eip(ebp[1], &info);
	cprintf("%s:%d: ", info.eip_file, info.eip_line);
	for(int i = 0; i < info.eip_fn_namelen; i++)
		cprintf("%c", info.eip_fn_name[i]);
	cprintf("+%d\n", ebp[1] - (int)info.eip_fn_addr);
}
return 0;
}
```
    - And also add backtrace command to kernel monitor
      - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/61dae403-864e-42e0-b2f3-9a77b56ee0b4)
  - So, that all i did. Finally exercise 11 and excercise 12 all corrects
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/7bc6fc46-d66f-4859-a940-6adad54da561)

---
