**Exercise 4**
---

In the file kern/pmap.c, you must implement code for the following functions.
```c
    pgdir_walk()
    boot_map_region()
    page_lookup()
    page_remove()
    page_insert()
```
check_page(), called from mem_init(), tests your page table management routines. You should make sure it reports success before proceeding.

---

***My result***
---

- `pgdir_walk()`
    - ```c
        pte_t * 
        pgdir_walk(pde_t *pgdir, const void *va, int create)
        {
            // Fill this function in
            if(!pgdir[PDX(va)])
            {
                if(create == 0)
                    return (pte_t*) NULL;

                struct PageInfo* pp = page_alloc(ALLOC_ZERO);
                
                if(pp == NULL)
                    return (pte_t*) NULL;
                
                pgdir[PDX(va)] = page2pa(pp) | PTE_P | PTE_W | PTE_U;
                pp->pp_ref++;
            }
            
            return (pte_t *) &((pte_t*)KADDR(PTE_ADDR(pgdir[PDX(va)])))[PTX(va)];
        }
      ```

- `boot_map_region()`
    - ```c
        static void 
        boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
        {
            // Fill this function in
            pte_t* pgte;
            for(int i = 0; i < PGNUM(size); i++)
            {
                pgte = pgdir_walk(pgdir, (void *)va + i, 1);
                *pgte = (pa + i) | perm | PTE_P;
            }
            return;
        }
      ```

- `page_lookup()`
    - ```c
        struct PageInfo *
        page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
        {
            // Fill this function in
            pde_t* pgte = pgdir_walk(pgdir, va, 0);
            if(pte_store)
		        pte_store = &pgte;
            if(!pgte || !*pgte)
                return NULL;
            
            return pa2page(PTE_ADDR(*pgte));
        }
      ```

- `page_remove()`
    - ```c
        void
        page_remove(pde_t *pgdir, void *va)
        {
            // Fill this function in
            struct PageInfo* pp = page_lookup(pgdir, va, NULL);

            if(!pp)
                return;
            
            page_decref(pp);

            pte_t* pgte = pgdir_walk(pgdir, va, 0);
            
            if(*pgte)
            {
                *pgte = 0;
                tlb_invalidate(pgdir, va);
            }

            return;
        }
      ```

- `page_insert()`
    - ```c
        int
        page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
        {
            // Fill this function in
            pte_t* pgte = pgdir_walk(pgdir, va, 1);
            
            if(!pgte)
                return -E_NO_MEM;

            if(*pgte)
            {
                if(PTE_ADDR(*pgte) == page2pa(pp))
                {
                    *pgte = page2pa(pp) | perm | PTE_P;
                    return 0;
                }
                page_remove(pgdir, va);
                tlb_invalidate(pgdir, va);
            }

            *pgte = page2pa(pp) | perm | PTE_P;
            
            pp->pp_ref++;

            return 0;
        }
      ```

- `va`: virtual address
- `pa`: physical address
- `pgdir`: page directory

- These functions demonstrate absolutely how virtual address mapping to a physical address through paging
    - `pgdir_walk`: take `va` return that page table entry in given `pgdir`. This also use to create a page table if there is no page table and `create` is on.
    - `boot_map_region`: use to map a range of `va` to a range of `pa` instead of a fixed page.
    - `page_lookup`: with given `pgdir` and `va`, return page hold informations of physical page that `va` mapped to.
    - `page_remove`: ummap `va` in `pgdir`
    - `page_insert`: map `va` to `pa` page that `pp` handle
- From these functions, i know that kernel set permission for an address by place permission bits in these page table entry, also page directory entry but it is more permissive than strictly necessary.
    - This can happen because page table entry and page directory entry of an address only use 20 higher bits, so 12 lower bits can be used to set permission without changing the result when translate `va` to `pa` through paging
- And here is my score:
    - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/b3056564-414b-4118-9edf-a7877c270726)
