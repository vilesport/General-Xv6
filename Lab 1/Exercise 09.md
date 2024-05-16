**Exercise 9**
---

Determine where the kernel initializes its stack, and exactly where in memory its stack is located. How does the kernel reserve space for its stack? And at which "end" of this reserved area is the stack pointer initialized to point to?

---

***My result:***
---

**Exercise questions:**

- This is where the kernel initializes its stack:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/982294a7-b02c-4c7f-b4bd-4d0934dd834e)
- This is where the stack is located:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/f24a6de1-2259-471b-88b2-1dc03bcf36e0)
  - It also included the current address.
- The kernel reserve space for its stack by calling the init:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/897ed8e3-a950-450d-b4c0-a2ad45ac69f7)
- At this end of reserved area the stack pointer initialized point to:
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/3d3a1676-d7b1-4e29-ab12-2935ea379e3b)

