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
|1023  |?	                   |Page table for top 4MB of phys memory   |
+------+-----------------------+----------------------------------------+
|1022  |?	                   |?                                       |
+------+-----------------------+----------------------------------------+
|.	   |?	                   |?                                       |
+------+-----------------------+----------------------------------------+
|.	   |?	                   |?                                       |
+------+-----------------------+----------------------------------------+
|.	   |?	                   |?                                       |
+------+-----------------------+----------------------------------------+
|2	   |0x00800000	           |?                                       |
+------+-----------------------+----------------------------------------+
|1	   |0x00400000	           |?                                       |
+------+-----------------------+----------------------------------------+
|0	   |0x00000000	           |[see next question]                     |
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
        -