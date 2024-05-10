**Exercise 4**
---

Read about programming with pointers in C. The best reference for the C language is The C Programming Language by Brian Kernighan and Dennis Ritchie (known as 'K&R'). We recommend that students purchase this book (here is an [Amazon Link](https://www.amazon.com/C-Programming-Language-2nd/dp/0131103628/sr=8-1/qid=1157812738/ref=pd_bbs_1/104-1502762-1803102?ie=UTF8&s=books)) or find one of [MIT's 7 copies](https://libraries.mit.edu/research-support/new-search-platform-launched/).

Read 5.1 (Pointers and Addresses) through 5.5 (Character Pointers and Functions) in K&R. Then download the code for [pointers.c](https://pdos.csail.mit.edu/6.828/2018/labs/lab1/pointers.c), run it, and make sure you understand where all of the printed values come from. In particular, make sure you understand:
- Where the pointer addresses in printed lines 1 and 6 come from
- How all the values in printed lines 2 through 4 get there
- Why the values printed in line 5 are seemingly corrupted.

There are other references on pointers in C (e.g., [A tutorial by Ted Jensen](https://pdos.csail.mit.edu/6.828/2018/readings/pointers.pdf) that cites K&R heavily), though not as strongly recommended.

Warning: Unless you are already thoroughly versed in C, do not skip or even skim this reading exercise. If you do not really understand pointers in C, you will suffer untold pain and misery in subsequent labs, and then eventually come to understand them the hard way. Trust us; you don't want to find out what "the hard way" is.
---

My result:

**Exercise questions:**

![image](https://github.com/vilesport/General-Xv6/assets/89498002/3f6ad5dd-5655-4ecc-9bcc-f8caf9410a73)

- In line 1, the pointer printed out is address of array a, pointer b and pointer c. In these, a and c are point to stack, b point to the heap
- In line 6, the pointer a is currently it address. Evenwhen both b and c equal to pointer a plus 1, b format as an integer pointer so it address greater than address pointer a 4 bytes - size of integer, c format as a char pointer, so it address greater than address pointer a just 1 bytes - size of char
