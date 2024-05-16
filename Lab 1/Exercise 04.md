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

