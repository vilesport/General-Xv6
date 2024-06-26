**Exercise 12**
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
    - ```c
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
    - ```c
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
  - So, that all i did and finally exercise 11 and excercise 12 all corrects
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/7bc6fc46-d66f-4859-a940-6adad54da561)
