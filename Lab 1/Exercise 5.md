**Exercise 5**
---

Trace through the first few instructions of the boot loader again and identify the first instruction that would "break" or otherwise do the wrong thing if you were to get the boot loader's link address wrong. Then change the link address in boot/Makefrag to something wrong, run make clean, recompile the lab with make, and trace into the boot loader again to see what happens. Don't forget to change the link address back and make clean again afterward!

---

My result
**Exercise question:**
- ![image](https://github.com/vilesport/General-Xv6/assets/89498002/cb7e40fb-acaa-463c-a132-5abfb1815de2)
  - After modified the link address to `0x7c99` instead of `0x7c00` default, the program have some strange behaviour when switch from 16-bit mode to 32-bit mode. 
  - ![image](https://github.com/vilesport/General-Xv6/assets/89498002/fd7d63cd-36fe-4f59-8b3d-041a5f79879e)
  - I found that because when lgdt, the global descripter table are not at that address, so when switch to 32-bit by changing cr0 PE flag bit, it can't ljmp into 32-bit segment because the segment register is not correct to run 32-bit mode, so it do something strange and then reboot and try to switch from 16-bit to 32-bit mode again

