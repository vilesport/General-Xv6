![image](https://github.com/vilesport/General-Xv6/assets/89498002/addb36f6-11c0-4c33-8ff7-0edc6d105fa0)**Exercise 8**
---
We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment.

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

- This is the code to print octal number:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/c7cff345-68d9-487e-86b4-09d244280d9c)
- This is my code replaced:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/7b2ca369-541f-483d-b649-99a5e13db1c8)

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

6. Because now the argument list is reversed, so i will change the interface of cprintf
   - From this:
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/91b6a399-d470-4085-905d-c5537df7c27e)
   - To this:
     - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/d1d6473a-b5f6-4e9b-919d-18ae76fd7202)

