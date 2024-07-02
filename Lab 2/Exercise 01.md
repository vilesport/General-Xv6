**Exercise 1**
---

In the file kern/pmap.c, you must implement code for the following functions (probably in the order given).
```
boot_alloc()
mem_init() (only up to the call to check_page_free_list(1))
page_init()
page_alloc()
page_free()
```
check_page_free_list() and check_page_alloc() test your physical page allocator. You should boot JOS and see whether check_page_alloc() reports success. Fix your code so that it passes. You may find it helpful to add your own assert()s to verify that your assumptions are correct.

---

***My result***
---

- boot_alloc()
  - ```c
    static void * boot_alloc(uint32_t n)
    {
    	static char *nextfree;
    	char *result;
  
    	if (!nextfree) {
    		extern char end[];
    		nextfree = ROUNDUP((char *) end, PGSIZE);
    	}
    	
    	// LAB 2: Your code here.
    	uint32_t req_npages = n / PGSIZE;
    	if(req_npages > npages)				//npages is the number of available memory page
    		panic("Not enough spaces");
    	result = nextfree;
    	nextfree += req_npages * PGSIZE;
    	return result;
    }
    ```
    
- mem_init() (up to the call check_page_free_list(1))
  - ```c
      void mem_init(void)
      {
      	uint32_t cr0;
      	size_t n;
      	i386_detect_memory();
      
      	//////////////////////////////////////////////////////////////////////
      	// create initial page directory.
      	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
      	memset(kern_pgdir, 0, PGSIZE);
      
      	//////////////////////////////////////////////////////////////////////
      	// Recursively insert PD in itself as a page table, to form
      	// a virtual page table at virtual address UVPT.
      	// (For now, you don't have understand the greater purpose of the
      	// following line.)
      
      	// Permissions: kernel R, user R
      	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
      
      	//////////////////////////////////////////////////////////////////////
      	// Your code goes here:
      	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo *) * npages);
      	memset(pages, 0, sizeof(struct PageInfo *) * npages);
      
      	//////////////////////////////////////////////////////////////////////
      
      	page_init();
      
      	check_page_free_list(1);
      	check_page_alloc();
     ```
    
- page_init()
  - ```c
    void page_init(void)
    {
    	size_t i;
    	pages[0].pp_ref = 0;
    	pages[0].pp_link = NULL;
    	page_free_list = NULL;
    	for(i = 1; i < npages_basemem; i++)
    	{
    		pages[i].pp_ref = 0;
    		pages[i].pp_link = page_free_list;
    		page_free_list = &pages[i];
    	}
    	for(i = PGNUM(0x100000); page2kva(&pages[i]) < (void *)&pages[npages]; i++)
    	{
    		pages[i].pp_ref = 0;
    		pages[i].pp_link = NULL;
    	}
    	for(i; i < npages; i++)
    	{
    		pages[i].pp_ref = 0;
    		pages[i].pp_link = page_free_list;
    		page_free_list = &pages[i];
    	}
    }
    ```

- page_alloc()
  - ```c
    struct PageInfo * page_alloc(int alloc_flags)
    {
    	// Fill this function in
    	size_t i;
    	if(!page_free_list)
    		return NULL;
    	struct PageInfo * tmp = page_free_list->pp_link;
    
    	page_free_list->pp_link = NULL;
    	page_free_list->pp_ref = 0;
    
    	if(alloc_flags & ALLOC_ZERO)
    		memset(page2kva(page_free_list), '\0', PGSIZE);
    
    	struct PageInfo * res = page_free_list;
    	page_free_list = tmp;
    	return res;
    }
    ```
- page_free()
  - ```c
    void page_free(struct PageInfo *pp)
    {
    	// Fill this function in
    	if(pp->pp_link != NULL || pp->pp_ref != 0)
    		panic("Double free detected");
    	pp->pp_ref = 0;
    	pp->pp_link = page_free_list;
    	page_free_list = pp;
    	// Hint: You may want to panic if pp->pp_ref is nonzero or
    	// pp->pp_link is not NULL.
    }
    ```
    
- `boot_alloc`, `mem_init` and `page_init` will run first when kernel started. The kernel keep an eye on memory through `kern_pgdir` and `pages`.
  - Both `kern_pgdir` and `pages` are storaged in extended memory that hold informations using for paging by kernel.
  - `kern_pgdir` is the kernel page directory - the first level of paging. In exercise 1 not yet using it.
  - `pages` storage information of each physical memory pages it prefer to. Including `pp_ref` and `pp_link`
    - `pp_link` : the pointer to the next free page if current page is freed, NULL if not.
    - `pp_ref` : in exercise 1 not yet using `pp_ref` but it stand for the number of virtual page that reference to current physical page.
      
- This is what i learn from exercise:
  - The kernel use `page_alloc` and `page_free` to change information about a page. If a page is in used, it's `pp_ref` after `page_alloc` would be 1. If a page is free, it must in `page_free_list`. So if there is no page in `page_free_list` mean kernel run out of memory
  - `boot_alloc`: Just return a pointer to a block of memory that aligned page size and enough for request size. 
  - `page_alloc`: It will take a freed page in `page_free_list`, reset informations of that page and return the pointer to a page.
  - `page_free`: free a page by reset it's informations and push to `page_free_list`.
    - A page only free when it `pp_ref` is reduce to zero, that mean no virtual page map to current physical page and `pp_link` must not be 0 to make sure that `page_free` won't double free.
  - `page_init`: This functions setup all informations of all pages when the kernel start paging so that the rest of kernel functions could only use what can use from `page_free_list` and all in use pages.
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/27c120d1-e6ef-425b-8a6a-4dd486f8d46c)
  - `mem_init`: This functions demonstrate how kernel paging.
- Everything work right and here is my result:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/ee1c14c9-c166-49cc-9d32-f5c073c12b5c)
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/2b429aca-9b1b-40b3-a03a-77d1bebb95fd)
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/d2b6f320-1828-4068-8ed4-f4c1841e6be9)
- It is the end of exercise 1.

---
