**Exercise 5**
---

1.  ```c
        Fill in the missing code in mem_init() after the call to check_page().
        Your code should now pass the check_kern_pgdir() and check_page_installed_pgdir() checks.
    ```
*Questions:*

2. What entries (rows) in the page directory have been filled in at this point? What addresses do they map and where do they point? In other words, fill out this table as much as possible:

```
+------+-----------------------+----------------------------------------+
|Entry |Base Virtual Address   |Points to (logically):                  |
+------+-----------------------+----------------------------------------+
|1023  |?	               |Page table for top 4MB of phys memory   |
+------+-----------------------+----------------------------------------+
|1022  |?	               |?                                       |
+------+-----------------------+----------------------------------------+
|.     |?	               |?                                       |
+------+-----------------------+----------------------------------------+
|.     |?	               |?                                       |
+------+-----------------------+----------------------------------------+
|.     |?	               |?                                       |
+------+-----------------------+----------------------------------------+
|2     |0x00800000	       |?                                       |
+------+-----------------------+----------------------------------------+
|1     |0x00400000	       |?                                       |
+------+-----------------------+----------------------------------------+
|0     |0x00000000	       |[see next question]                     |
+------+-----------------------+----------------------------------------+
```

3. We have placed the kernel and user environment in the same address space. Why will user programs not be able to read or write the kernel's memory? What specific mechanisms protect the kernel memory?
4. What is the maximum amount of physical memory that this operating system can support? Why?
5. How much space overhead is there for managing memory, if we actually had the maximum amount of physical memory? How is this overhead broken down?
6. Revisit the page table setup in kern/entry.S and kern/entrypgdir.c. Immediately after we turn on paging, EIP is still a low number (a little over 1MB). At what point do we transition to running at an EIP above KERNBASE? What makes it possible for us to continue executing at a low EIP between when we enable paging and when we begin running at an EIP above KERNBASE? Why is this transition necessary?

---

***My result:***
---

1. This is my code for the rest of `mem_init()`:
    - ```c
        // Now we set up virtual memory

        //////////////////////////////////////////////////////////////////////
        // Map 'pages' read-only by the user at linear address UPAGES
        // Permissions:
        //    - the new image at UPAGES -- kernel R, user R
        //      (ie. perm = PTE_U | PTE_P)
        //    - pages itself -- kernel RW, user NONE
        // Your code goes here:
        
        boot_map_region(kern_pgdir, UPAGES, npages * (sizeof(struct PageInfo)), PADDR(pages), PTE_U | PTE_W);                              

        //////////////////////////////////////////////////////////////////////
        // Use the physical memory that 'bootstack' refers to as the kernel
        // stack.  The kernel stack grows down from virtual address KSTACKTOP.
        // We consider the entire range from [KSTACKTOP-PTSIZE, KSTACKTOP)
        // to be the kernel stack, but break this into two pieces:
        //     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
        //     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
        //       the kernel overflows its stack, it will fault rather than
        //       overwrite memory.  Known as a "guard page".
        //     Permissions: kernel RW, user NONE
        // Your code goes here:

        boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
        //////////////////////////////////////////////////////////////////////
        // Map all of physical memory at KERNBASE.
        // Ie.  the VA range [KERNBASE, 2^32) should map to
        //      the PA range [0, 2^32 - KERNBASE)
        // We might not have 2^32 - KERNBASE bytes of physical memory, but
        // we just set up the mapping anyway.
        // Permissions: kernel RW, user NONE
        // Your code goes here:
        long long int num = 1;
        num <<= 32; // 2^32
        boot_map_region(kern_pgdir, KERNBASE, num - KERNBASE, 0, PTE_W);
      ```
    - Because `boot_map_region()` can be use to map a region of virtual address to a region of physical address, so i use it to map the request regions.
        - `UPAGES` is the memory region for read-only copies of the Page structures that only allow user to read the permission of each page but not change the page informations.
        - `KSTACKTOP` is where kernel stack started, at `0xF0000000`
        - The last mapping region is mapping all current kernel virtual address to physical address
    - Here is my result:
        - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/63205bec-d139-44a9-a496-8605c58d80d9)

2. The table:
   
```
+------+-----------------------+----------------------------------------+
|Entry |Base Virtual Address   |Points to (logically):                  |
+------+-----------------------+----------------------------------------+
|1023  |0xFFC00000             |Page table for top 4MB of phys memory   |
+------+-----------------------+----------------------------------------+
|1022  |0xFF800000             |Most new page allocated here            |
+------+-----------------------+----------------------------------------+
|.     |0xEFC00000             |Guard page                              |
+------+-----------------------+----------------------------------------+
|.     |0xEF400000             |Kern_pgdir page table                   |
+------+-----------------------+----------------------------------------+
|.     |0xEF000000             |The Read-only copies of Page structures |
+------+-----------------------+----------------------------------------+
|2     |0x00800000	       |?                                       |
+------+-----------------------+----------------------------------------+
|1     |0x00400000	       |?                                       |
+------+-----------------------+----------------------------------------+
|0     |0x00000000	       |[see next question]                     |
+------+-----------------------+----------------------------------------+
```

3. Because that kernel's memory only modify through kernel functions and it prevent user program from directly interact with kernel's memory. User program have to first walk through page directory before doing anything on an address and each entry of page table entry have permission bits, this mechanisms would let the kernel decide what user program can do with an address by checking the page table entry permission bits, so user programs will not be able to read or write the kernel's memory by kernel's first setup.

4. The maximum amount of physical memory that this operating system can support is `0xFFFFFFFF` = 4GB of memory. Because it is 32bit and the maximum virtual address it can handle is `0xFFFFFFFF` so even if more memory on this operating system, it can only map maximum 4GB of memory.

5. With maximum 4GB of memory, the operating system need 1 page directory with 1024 entry, each entry is a page table with 1024 entry point to physical address. The  overall space overhead is equal to size of page directory:
   - Sizeof(page_directory) = N * sizeof(page_table) = 1024 * 1024 * 4 = 4194304 Byte = 4096 Kilobyte = 4 Megabyte
     - N: Number of page table entry in page directory (1024)
     - Size of a page table equal to size of an entry (4 byte) mul number of entry (1024)
   - In conclusion, 4MB is the space overhead for managing memory if we actually had the maximum amount of physical memory.

6. At this point:
   - ![image](https://github.com/user-attachments/assets/b4bc0d99-a7a5-44c0-8caf-9641f6763cde)
   - After `jmp $eax` we start running at an EIP above KERNBASE
     - ![image](https://github.com/user-attachments/assets/0ce6f9a6-644a-4592-9133-4f57b38cf2e2)
   - We still possible to continue executing at a low EIP because CPU only increase EIP 4 bytes after execute most instruction but jump and call, so evenwhen paging is enable and high number address above KERNBASE have been inited, we still run at low number EIP if we don't jump or call high address to change EIP. So that this transition is necessary because it starting paing on system by turning EIP to high number address.

**Challenge!:**
---

1. Challenge! We consumed many physical pages to hold the page tables for the KERNBASE mapping. Do a more space-efficient job using the PTE_PS ("Page Size") bit in the page directory entries. This bit was not supported in the original 80386, but is supported on more recent x86 processors. You will therefore have to refer to [Volume 3 of the current Intel manuals](https://pdos.csail.mit.edu/6.828/2018/readings/ia32/IA32-3A.pdf). Make sure you design the kernel to use this optimization only on processors that support it!

2.Challenge! Extend the JOS kernel monitor with commands to:
        - Display in a useful and easy-to-read format all of the physical page mappings (or lack thereof) that apply to a particular range of virtual/linear addresses in the currently active address space. For example, you might enter 'showmappings 0x3000 0x5000' to display the physical page mappings and corresponding permission bits that apply to the pages at virtual addresses 0x3000, 0x4000, and 0x5000.
        - Explicitly set, clear, or change the permissions of any mapping in the current address space.
        - Dump the contents of a range of memory given either a virtual or physical address range. Be sure the dump code behaves correctly when the range extends across page boundaries!
        - Do anything else that you think might be useful later for debugging the kernel. (There's a good chance it will be!)

3. Challenge! Each user-level environment maps the kernel. Change JOS so that the kernel has its own page table and so that a user-level environment runs with a minimal number of kernel pages mapped. That is, each user-level environment maps just enough pages mapped so that the user-level environment can enter and leave the kernel correctly. You also have to come up with a plan for the kernel to read/write arguments to system calls.

4. Challenge! Write up an outline of how a kernel could be designed to allow user environments unrestricted use of the full 4GB virtual and linear address space. Hint: do the previous challenge exercise first, which reduces the kernel to a few mappings in a user environment. Hint: the technique is sometimes known as "follow the bouncing kernel." In your design, be sure to address exactly what has to happen when the processor transitions between kernel and user modes, and how the kernel would accomplish such transitions. Also describe how the kernel would access physical memory and I/O devices in this scheme, and how the kernel would access a user environment's virtual address space during system calls and the like. Finally, think about and describe the advantages and disadvantages of such a scheme in terms of flexibility, performance, kernel complexity, and other factors you can think of.

5. Challenge! Since our JOS kernel's memory management system only allocates and frees memory on page granularity, we do not have anything comparable to a general-purpose malloc/free facility that we can use within the kernel. This could be a problem if we want to support certain types of I/O devices that require physically contiguous buffers larger than 4KB in size, or if we want user-level environments, and not just the kernel, to be able to allocate and map 4MB superpages for maximum processor efficiency. (See the earlier challenge problem about PTE_PS.)
Generalize the kernel's memory allocation system to support pages of a variety of power-of-two allocation unit sizes from 4KB up to some reasonable maximum of your choice. Be sure you have some way to divide larger allocation units into smaller ones on demand, and to coalesce multiple small allocation units back into larger units when possible. Think about the issues that might arise in such a system.

