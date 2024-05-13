**Exercise 8**
---
Exercise questions:
- We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment.

Target question:
1. Explain the interface between printf.c and console.c. Specifically, what function does console.c export? How is this function used by printf.c?
2. Explain the following from console.c:
```c++!
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
```c++!
int x = 1, y = 3, z = 4;
cprintf("x %d, y %x, z %d\n", x, y, z);
```
- In the call to cprintf(), to what does fmt point? To what does ap point?
- List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.

4. Run the following code.
```c++!
    unsigned int i = 0x00646c72;
    cprintf("H%x Wo%s", 57616, &i);
```
- What is the output? Explain how this output is arrived at in the step-by-step manner of the previous exercise. [Here's an ASCII table](https://ascii.cl/) that maps bytes to characters.
- The output depends on that fact that the x86 is little-endian. If the x86 were instead big-endian what would you set i to in order to yield the same output? Would you need to change 57616 to a different value?

[Here's a description of little- and big-endian](http://www.webopedia.com/TERM/b/big_endian.html) and [a more whimsical description](http://www.networksorcery.com/enp/ien/ien137.txt).

5. In the following code, what is going to be printed after 'y='? (note: the answer is not a specific value.) Why does this happen?
```c++!
cprintf("x=%d y=%d", 3);
```
6. Let's say that GCC changed its calling convention so that it pushed arguments on the stack in declaration order, so that the last argument is pushed last. How would you have to change cprintf or its interface so that it would still be possible to pass it a variable number of arguments?

---

***My result:***
---

**Exercise questions:**
