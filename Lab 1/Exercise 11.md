**Exercise 11**
---

Implement the backtrace function as specified above. Use the same format as in the example, since otherwise the grading script will be confused. When you think you have it working right, run make grade to see if its output conforms to what our grading script expects, and fix it if it doesn't. After you have handed in your Lab 1 code, you are welcome to change the output format of the backtrace function any way you like.

If you use read_ebp(), note that GCC may generate "optimized" code that calls read_ebp() before mon_backtrace()'s function prologue, which results in an incomplete stack trace (the stack frame of the most recent function call is missing). While we have tried to disable optimizations that cause this reordering, you may want to examine the assembly of mon_backtrace() and make sure the call to read_ebp() is happening after the function prologue.

---

***My result:***
- This is my code that run correctly and got 20 points from count and arguments, so i think it is correct
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/117a2952-c5b8-49b4-992c-a217b4cf3b22)
  - ```
    mon_backtrace(int argc, char **argv, struct Trapframe *tf)
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

