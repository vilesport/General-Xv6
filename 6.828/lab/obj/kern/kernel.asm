
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 78 08 ff ff    	lea    -0xf788(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 ee 0a 00 00       	call   f0100b51 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 94 08 ff ff    	lea    -0xf76c(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 c8 0a 00 00       	call   f0100b51 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 ed 07 00 00       	call   f010088e <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 c0 36 11 f0    	mov    $0xf01136c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 7c 16 00 00       	call   f010174b <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3e 05 00 00       	call   f0100612 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 af 08 ff ff    	lea    -0xf751(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 69 0a 00 00       	call   f0100b51 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 97 08 00 00       	call   f0100998 <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	56                   	push   %esi
f010010a:	53                   	push   %ebx
f010010b:	e8 ac 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100110:	81 c3 f8 11 01 00    	add    $0x111f8,%ebx
	va_list ap;

	if (panicstr)
f0100116:	83 bb 58 1d 00 00 00 	cmpl   $0x0,0x1d58(%ebx)
f010011d:	74 0f                	je     f010012e <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011f:	83 ec 0c             	sub    $0xc,%esp
f0100122:	6a 00                	push   $0x0
f0100124:	e8 6f 08 00 00       	call   f0100998 <monitor>
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	eb f1                	jmp    f010011f <_panic+0x19>
	panicstr = fmt;
f010012e:	8b 45 10             	mov    0x10(%ebp),%eax
f0100131:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	asm volatile("cli; cld");
f0100137:	fa                   	cli    
f0100138:	fc                   	cld    
	va_start(ap, fmt);
f0100139:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013c:	83 ec 04             	sub    $0x4,%esp
f010013f:	ff 75 0c             	push   0xc(%ebp)
f0100142:	ff 75 08             	push   0x8(%ebp)
f0100145:	8d 83 ca 08 ff ff    	lea    -0xf736(%ebx),%eax
f010014b:	50                   	push   %eax
f010014c:	e8 00 0a 00 00       	call   f0100b51 <cprintf>
	vcprintf(fmt, ap);
f0100151:	83 c4 08             	add    $0x8,%esp
f0100154:	56                   	push   %esi
f0100155:	ff 75 10             	push   0x10(%ebp)
f0100158:	e8 bd 09 00 00       	call   f0100b1a <vcprintf>
	cprintf("\n");
f010015d:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 e6 09 00 00       	call   f0100b51 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb af                	jmp    f010011f <_panic+0x19>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	push   0xc(%ebp)
f0100189:	ff 75 08             	push   0x8(%ebp)
f010018c:	8d 83 e2 08 ff ff    	lea    -0xf71e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 b9 09 00 00       	call   f0100b51 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	push   0x10(%ebp)
f010019f:	e8 76 09 00 00       	call   f0100b1a <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 9f 09 00 00       	call   f0100b51 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c5:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	74 0a                	je     f01001d4 <serial_proc_data+0x14>
f01001ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	c3                   	ret    
		return -1;
f01001d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001d9:	c3                   	ret    

f01001da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001da:	55                   	push   %ebp
f01001db:	89 e5                	mov    %esp,%ebp
f01001dd:	57                   	push   %edi
f01001de:	56                   	push   %esi
f01001df:	53                   	push   %ebx
f01001e0:	83 ec 1c             	sub    $0x1c,%esp
f01001e3:	e8 6a 05 00 00       	call   f0100752 <__x86.get_pc_thunk.si>
f01001e8:	81 c6 20 11 01 00    	add    $0x11120,%esi
f01001ee:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001f0:	8d 1d 98 1d 00 00    	lea    0x1d98,%ebx
f01001f6:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001ff:	eb 25                	jmp    f0100226 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100201:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100208:	8d 51 01             	lea    0x1(%ecx),%edx
f010020b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010020e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100211:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100217:	b8 00 00 00 00       	mov    $0x0,%eax
f010021c:	0f 44 d0             	cmove  %eax,%edx
f010021f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100226:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100229:	ff d0                	call   *%eax
f010022b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010022e:	74 06                	je     f0100236 <cons_intr+0x5c>
		if (c == 0)
f0100230:	85 c0                	test   %eax,%eax
f0100232:	75 cd                	jne    f0100201 <cons_intr+0x27>
f0100234:	eb f0                	jmp    f0100226 <cons_intr+0x4c>
	}
}
f0100236:	83 c4 1c             	add    $0x1c,%esp
f0100239:	5b                   	pop    %ebx
f010023a:	5e                   	pop    %esi
f010023b:	5f                   	pop    %edi
f010023c:	5d                   	pop    %ebp
f010023d:	c3                   	ret    

f010023e <kbd_proc_data>:
{
f010023e:	55                   	push   %ebp
f010023f:	89 e5                	mov    %esp,%ebp
f0100241:	56                   	push   %esi
f0100242:	53                   	push   %ebx
f0100243:	e8 74 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100248:	81 c3 c0 10 01 00    	add    $0x110c0,%ebx
f010024e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100253:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100254:	a8 01                	test   $0x1,%al
f0100256:	0f 84 f7 00 00 00    	je     f0100353 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f010025c:	a8 20                	test   $0x20,%al
f010025e:	0f 85 f6 00 00 00    	jne    f010035a <kbd_proc_data+0x11c>
f0100264:	ba 60 00 00 00       	mov    $0x60,%edx
f0100269:	ec                   	in     (%dx),%al
f010026a:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010026c:	3c e0                	cmp    $0xe0,%al
f010026e:	74 64                	je     f01002d4 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100270:	84 c0                	test   %al,%al
f0100272:	78 75                	js     f01002e9 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100274:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f010027a:	f6 c1 40             	test   $0x40,%cl
f010027d:	74 0e                	je     f010028d <kbd_proc_data+0x4f>
		data |= 0x80;
f010027f:	83 c8 80             	or     $0xffffff80,%eax
f0100282:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100284:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100287:	89 8b 78 1d 00 00    	mov    %ecx,0x1d78(%ebx)
	shift |= shiftcode[data];
f010028d:	0f b6 d2             	movzbl %dl,%edx
f0100290:	0f b6 84 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%eax
f0100297:	ff 
f0100298:	0b 83 78 1d 00 00    	or     0x1d78(%ebx),%eax
	shift ^= togglecode[data];
f010029e:	0f b6 8c 13 38 09 ff 	movzbl -0xf6c8(%ebx,%edx,1),%ecx
f01002a5:	ff 
f01002a6:	31 c8                	xor    %ecx,%eax
f01002a8:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002ae:	89 c1                	mov    %eax,%ecx
f01002b0:	83 e1 03             	and    $0x3,%ecx
f01002b3:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ba:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002be:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002c1:	a8 08                	test   $0x8,%al
f01002c3:	74 61                	je     f0100326 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002c5:	89 f2                	mov    %esi,%edx
f01002c7:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002ca:	83 f9 19             	cmp    $0x19,%ecx
f01002cd:	77 4b                	ja     f010031a <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002cf:	83 ee 20             	sub    $0x20,%esi
f01002d2:	eb 0c                	jmp    f01002e0 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002d4:	83 8b 78 1d 00 00 40 	orl    $0x40,0x1d78(%ebx)
		return 0;
f01002db:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002e0:	89 f0                	mov    %esi,%eax
f01002e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002e5:	5b                   	pop    %ebx
f01002e6:	5e                   	pop    %esi
f01002e7:	5d                   	pop    %ebp
f01002e8:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e9:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f01002ef:	83 e0 7f             	and    $0x7f,%eax
f01002f2:	f6 c1 40             	test   $0x40,%cl
f01002f5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002f8:	0f b6 d2             	movzbl %dl,%edx
f01002fb:	0f b6 84 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%eax
f0100302:	ff 
f0100303:	83 c8 40             	or     $0x40,%eax
f0100306:	0f b6 c0             	movzbl %al,%eax
f0100309:	f7 d0                	not    %eax
f010030b:	21 c8                	and    %ecx,%eax
f010030d:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
		return 0;
f0100313:	be 00 00 00 00       	mov    $0x0,%esi
f0100318:	eb c6                	jmp    f01002e0 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f010031a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010031d:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100320:	83 fa 1a             	cmp    $0x1a,%edx
f0100323:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100326:	f7 d0                	not    %eax
f0100328:	a8 06                	test   $0x6,%al
f010032a:	75 b4                	jne    f01002e0 <kbd_proc_data+0xa2>
f010032c:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100332:	75 ac                	jne    f01002e0 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100334:	83 ec 0c             	sub    $0xc,%esp
f0100337:	8d 83 fc 08 ff ff    	lea    -0xf704(%ebx),%eax
f010033d:	50                   	push   %eax
f010033e:	e8 0e 08 00 00       	call   f0100b51 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100343:	b8 03 00 00 00       	mov    $0x3,%eax
f0100348:	ba 92 00 00 00       	mov    $0x92,%edx
f010034d:	ee                   	out    %al,(%dx)
}
f010034e:	83 c4 10             	add    $0x10,%esp
f0100351:	eb 8d                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f0100353:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100358:	eb 86                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f010035a:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035f:	e9 7c ff ff ff       	jmp    f01002e0 <kbd_proc_data+0xa2>

f0100364 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100364:	55                   	push   %ebp
f0100365:	89 e5                	mov    %esp,%ebp
f0100367:	57                   	push   %edi
f0100368:	56                   	push   %esi
f0100369:	53                   	push   %ebx
f010036a:	83 ec 1c             	sub    $0x1c,%esp
f010036d:	e8 4a fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100372:	81 c3 96 0f 01 00    	add    $0x10f96,%ebx
f0100378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010037b:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100380:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100385:	b9 84 00 00 00       	mov    $0x84,%ecx
f010038a:	89 fa                	mov    %edi,%edx
f010038c:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038d:	a8 20                	test   $0x20,%al
f010038f:	75 13                	jne    f01003a4 <cons_putc+0x40>
f0100391:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100397:	7f 0b                	jg     f01003a4 <cons_putc+0x40>
f0100399:	89 ca                	mov    %ecx,%edx
f010039b:	ec                   	in     (%dx),%al
f010039c:	ec                   	in     (%dx),%al
f010039d:	ec                   	in     (%dx),%al
f010039e:	ec                   	in     (%dx),%al
	     i++)
f010039f:	83 c6 01             	add    $0x1,%esi
f01003a2:	eb e6                	jmp    f010038a <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003a4:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003a8:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003b0:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003b1:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b6:	bf 79 03 00 00       	mov    $0x379,%edi
f01003bb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003c0:	89 fa                	mov    %edi,%edx
f01003c2:	ec                   	in     (%dx),%al
f01003c3:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c9:	7f 0f                	jg     f01003da <cons_putc+0x76>
f01003cb:	84 c0                	test   %al,%al
f01003cd:	78 0b                	js     f01003da <cons_putc+0x76>
f01003cf:	89 ca                	mov    %ecx,%edx
f01003d1:	ec                   	in     (%dx),%al
f01003d2:	ec                   	in     (%dx),%al
f01003d3:	ec                   	in     (%dx),%al
f01003d4:	ec                   	in     (%dx),%al
f01003d5:	83 c6 01             	add    $0x1,%esi
f01003d8:	eb e6                	jmp    f01003c0 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003da:	ba 78 03 00 00       	mov    $0x378,%edx
f01003df:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003e3:	ee                   	out    %al,(%dx)
f01003e4:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e9:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003ee:	ee                   	out    %al,(%dx)
f01003ef:	b8 08 00 00 00       	mov    $0x8,%eax
f01003f4:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f8:	89 f8                	mov    %edi,%eax
f01003fa:	80 cc 07             	or     $0x7,%ah
f01003fd:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100403:	0f 45 c7             	cmovne %edi,%eax
f0100406:	89 c7                	mov    %eax,%edi
f0100408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f010040b:	0f b6 c0             	movzbl %al,%eax
f010040e:	89 f9                	mov    %edi,%ecx
f0100410:	80 f9 0a             	cmp    $0xa,%cl
f0100413:	0f 84 e4 00 00 00    	je     f01004fd <cons_putc+0x199>
f0100419:	83 f8 0a             	cmp    $0xa,%eax
f010041c:	7f 46                	jg     f0100464 <cons_putc+0x100>
f010041e:	83 f8 08             	cmp    $0x8,%eax
f0100421:	0f 84 a8 00 00 00    	je     f01004cf <cons_putc+0x16b>
f0100427:	83 f8 09             	cmp    $0x9,%eax
f010042a:	0f 85 da 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 2a ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 20 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100444:	b8 20 00 00 00       	mov    $0x20,%eax
f0100449:	e8 16 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010044e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100453:	e8 0c ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100458:	b8 20 00 00 00       	mov    $0x20,%eax
f010045d:	e8 02 ff ff ff       	call   f0100364 <cons_putc>
		break;
f0100462:	eb 26                	jmp    f010048a <cons_putc+0x126>
	switch (c & 0xff) {
f0100464:	83 f8 0d             	cmp    $0xd,%eax
f0100467:	0f 85 9d 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f010046d:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100474:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010047a:	c1 e8 16             	shr    $0x16,%eax
f010047d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100480:	c1 e0 04             	shl    $0x4,%eax
f0100483:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f010048a:	66 81 bb a0 1f 00 00 	cmpw   $0x7cf,0x1fa0(%ebx)
f0100491:	cf 07 
f0100493:	0f 87 98 00 00 00    	ja     f0100531 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100499:	8b 8b a8 1f 00 00    	mov    0x1fa8(%ebx),%ecx
f010049f:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004a4:	89 ca                	mov    %ecx,%edx
f01004a6:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a7:	0f b7 9b a0 1f 00 00 	movzwl 0x1fa0(%ebx),%ebx
f01004ae:	8d 71 01             	lea    0x1(%ecx),%esi
f01004b1:	89 d8                	mov    %ebx,%eax
f01004b3:	66 c1 e8 08          	shr    $0x8,%ax
f01004b7:	89 f2                	mov    %esi,%edx
f01004b9:	ee                   	out    %al,(%dx)
f01004ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004bf:	89 ca                	mov    %ecx,%edx
f01004c1:	ee                   	out    %al,(%dx)
f01004c2:	89 d8                	mov    %ebx,%eax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004ca:	5b                   	pop    %ebx
f01004cb:	5e                   	pop    %esi
f01004cc:	5f                   	pop    %edi
f01004cd:	5d                   	pop    %ebp
f01004ce:	c3                   	ret    
		if (crt_pos > 0) {
f01004cf:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f01004d6:	66 85 c0             	test   %ax,%ax
f01004d9:	74 be                	je     f0100499 <cons_putc+0x135>
			crt_pos--;
f01004db:	83 e8 01             	sub    $0x1,%eax
f01004de:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e5:	0f b7 c0             	movzwl %ax,%eax
f01004e8:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ec:	b2 00                	mov    $0x0,%dl
f01004ee:	83 ca 20             	or     $0x20,%edx
f01004f1:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f01004f7:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004fb:	eb 8d                	jmp    f010048a <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004fd:	66 83 83 a0 1f 00 00 	addw   $0x50,0x1fa0(%ebx)
f0100504:	50 
f0100505:	e9 63 ff ff ff       	jmp    f010046d <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f010050a:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100511:	8d 50 01             	lea    0x1(%eax),%edx
f0100514:	66 89 93 a0 1f 00 00 	mov    %dx,0x1fa0(%ebx)
f010051b:	0f b7 c0             	movzwl %ax,%eax
f010051e:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100524:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010052c:	e9 59 ff ff ff       	jmp    f010048a <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100531:	8b 83 a4 1f 00 00    	mov    0x1fa4(%ebx),%eax
f0100537:	83 ec 04             	sub    $0x4,%esp
f010053a:	68 00 0f 00 00       	push   $0xf00
f010053f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100545:	52                   	push   %edx
f0100546:	50                   	push   %eax
f0100547:	e8 45 12 00 00       	call   f0101791 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010054c:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100552:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100558:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010055e:	83 c4 10             	add    $0x10,%esp
f0100561:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100566:	83 c0 02             	add    $0x2,%eax
f0100569:	39 d0                	cmp    %edx,%eax
f010056b:	75 f4                	jne    f0100561 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010056d:	66 83 ab a0 1f 00 00 	subw   $0x50,0x1fa0(%ebx)
f0100574:	50 
f0100575:	e9 1f ff ff ff       	jmp    f0100499 <cons_putc+0x135>

f010057a <serial_intr>:
{
f010057a:	e8 cf 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f010057f:	05 89 0d 01 00       	add    $0x10d89,%eax
	if (serial_exists)
f0100584:	80 b8 ac 1f 00 00 00 	cmpb   $0x0,0x1fac(%eax)
f010058b:	75 01                	jne    f010058e <serial_intr+0x14>
f010058d:	c3                   	ret    
{
f010058e:	55                   	push   %ebp
f010058f:	89 e5                	mov    %esp,%ebp
f0100591:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100594:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f010059a:	e8 3b fc ff ff       	call   f01001da <cons_intr>
}
f010059f:	c9                   	leave  
f01005a0:	c3                   	ret    

f01005a1 <kbd_intr>:
{
f01005a1:	55                   	push   %ebp
f01005a2:	89 e5                	mov    %esp,%ebp
f01005a4:	83 ec 08             	sub    $0x8,%esp
f01005a7:	e8 a2 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f01005ac:	05 5c 0d 01 00       	add    $0x10d5c,%eax
	cons_intr(kbd_proc_data);
f01005b1:	8d 80 36 ef fe ff    	lea    -0x110ca(%eax),%eax
f01005b7:	e8 1e fc ff ff       	call   f01001da <cons_intr>
}
f01005bc:	c9                   	leave  
f01005bd:	c3                   	ret    

f01005be <cons_getc>:
{
f01005be:	55                   	push   %ebp
f01005bf:	89 e5                	mov    %esp,%ebp
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 04             	sub    $0x4,%esp
f01005c5:	e8 f2 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 3e 0d 01 00    	add    $0x10d3e,%ebx
	serial_intr();
f01005d0:	e8 a5 ff ff ff       	call   f010057a <serial_intr>
	kbd_intr();
f01005d5:	e8 c7 ff ff ff       	call   f01005a1 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005da:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
	return 0;
f01005e0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005e5:	3b 83 9c 1f 00 00    	cmp    0x1f9c(%ebx),%eax
f01005eb:	74 1e                	je     f010060b <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005ed:	8d 48 01             	lea    0x1(%eax),%ecx
f01005f0:	0f b6 94 03 98 1d 00 	movzbl 0x1d98(%ebx,%eax,1),%edx
f01005f7:	00 
			cons.rpos = 0;
f01005f8:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100602:	0f 45 c1             	cmovne %ecx,%eax
f0100605:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
}
f010060b:	89 d0                	mov    %edx,%eax
f010060d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100610:	c9                   	leave  
f0100611:	c3                   	ret    

f0100612 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
f0100615:	57                   	push   %edi
f0100616:	56                   	push   %esi
f0100617:	53                   	push   %ebx
f0100618:	83 ec 1c             	sub    $0x1c,%esp
f010061b:	e8 9c fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100620:	81 c3 e8 0c 01 00    	add    $0x10ce8,%ebx
	was = *cp;
f0100626:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100634:	5a a5 
	if (*cp != 0xA55A) {
f0100636:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063d:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100642:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100647:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064b:	0f 84 ac 00 00 00    	je     f01006fd <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100651:	89 8b a8 1f 00 00    	mov    %ecx,0x1fa8(%ebx)
f0100657:	b8 0e 00 00 00       	mov    $0xe,%eax
f010065c:	89 ca                	mov    %ecx,%edx
f010065e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010065f:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100662:	89 f2                	mov    %esi,%edx
f0100664:	ec                   	in     (%dx),%al
f0100665:	0f b6 c0             	movzbl %al,%eax
f0100668:	c1 e0 08             	shl    $0x8,%eax
f010066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010066e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100673:	89 ca                	mov    %ecx,%edx
f0100675:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100676:	89 f2                	mov    %esi,%edx
f0100678:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100679:	89 bb a4 1f 00 00    	mov    %edi,0x1fa4(%ebx)
	pos |= inb(addr_6845 + 1);
f010067f:	0f b6 c0             	movzbl %al,%eax
f0100682:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100685:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100691:	89 c8                	mov    %ecx,%eax
f0100693:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100698:	ee                   	out    %al,(%dx)
f0100699:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010069e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a3:	89 fa                	mov    %edi,%edx
f01006a5:	ee                   	out    %al,(%dx)
f01006a6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b0:	ee                   	out    %al,(%dx)
f01006b1:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006b6:	89 c8                	mov    %ecx,%eax
f01006b8:	89 f2                	mov    %esi,%edx
f01006ba:	ee                   	out    %al,(%dx)
f01006bb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c0:	89 fa                	mov    %edi,%edx
f01006c2:	ee                   	out    %al,(%dx)
f01006c3:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006c8:	89 c8                	mov    %ecx,%eax
f01006ca:	ee                   	out    %al,(%dx)
f01006cb:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d0:	89 f2                	mov    %esi,%edx
f01006d2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006d8:	ec                   	in     (%dx),%al
f01006d9:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006db:	3c ff                	cmp    $0xff,%al
f01006dd:	0f 95 83 ac 1f 00 00 	setne  0x1fac(%ebx)
f01006e4:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006e9:	ec                   	in     (%dx),%al
f01006ea:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ef:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f0:	80 f9 ff             	cmp    $0xff,%cl
f01006f3:	74 1e                	je     f0100713 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006f8:	5b                   	pop    %ebx
f01006f9:	5e                   	pop    %esi
f01006fa:	5f                   	pop    %edi
f01006fb:	5d                   	pop    %ebp
f01006fc:	c3                   	ret    
		*cp = was;
f01006fd:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100704:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100709:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f010070e:	e9 3e ff ff ff       	jmp    f0100651 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f0100713:	83 ec 0c             	sub    $0xc,%esp
f0100716:	8d 83 08 09 ff ff    	lea    -0xf6f8(%ebx),%eax
f010071c:	50                   	push   %eax
f010071d:	e8 2f 04 00 00       	call   f0100b51 <cprintf>
f0100722:	83 c4 10             	add    $0x10,%esp
}
f0100725:	eb ce                	jmp    f01006f5 <cons_init+0xe3>

f0100727 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100727:	55                   	push   %ebp
f0100728:	89 e5                	mov    %esp,%ebp
f010072a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010072d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100730:	e8 2f fc ff ff       	call   f0100364 <cons_putc>
}
f0100735:	c9                   	leave  
f0100736:	c3                   	ret    

f0100737 <getchar>:

int
getchar(void)
{
f0100737:	55                   	push   %ebp
f0100738:	89 e5                	mov    %esp,%ebp
f010073a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010073d:	e8 7c fe ff ff       	call   f01005be <cons_getc>
f0100742:	85 c0                	test   %eax,%eax
f0100744:	74 f7                	je     f010073d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100746:	c9                   	leave  
f0100747:	c3                   	ret    

f0100748 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100748:	b8 01 00 00 00       	mov    $0x1,%eax
f010074d:	c3                   	ret    

f010074e <__x86.get_pc_thunk.ax>:
f010074e:	8b 04 24             	mov    (%esp),%eax
f0100751:	c3                   	ret    

f0100752 <__x86.get_pc_thunk.si>:
f0100752:	8b 34 24             	mov    (%esp),%esi
f0100755:	c3                   	ret    

f0100756 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	56                   	push   %esi
f010075a:	53                   	push   %ebx
f010075b:	e8 5c fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100760:	81 c3 a8 0b 01 00    	add    $0x10ba8,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100766:	83 ec 04             	sub    $0x4,%esp
f0100769:	8d 83 38 0b ff ff    	lea    -0xf4c8(%ebx),%eax
f010076f:	50                   	push   %eax
f0100770:	8d 83 56 0b ff ff    	lea    -0xf4aa(%ebx),%eax
f0100776:	50                   	push   %eax
f0100777:	8d b3 5b 0b ff ff    	lea    -0xf4a5(%ebx),%esi
f010077d:	56                   	push   %esi
f010077e:	e8 ce 03 00 00       	call   f0100b51 <cprintf>
f0100783:	83 c4 0c             	add    $0xc,%esp
f0100786:	8d 83 14 0c ff ff    	lea    -0xf3ec(%ebx),%eax
f010078c:	50                   	push   %eax
f010078d:	8d 83 64 0b ff ff    	lea    -0xf49c(%ebx),%eax
f0100793:	50                   	push   %eax
f0100794:	56                   	push   %esi
f0100795:	e8 b7 03 00 00       	call   f0100b51 <cprintf>
f010079a:	83 c4 0c             	add    $0xc,%esp
f010079d:	8d 83 6d 0b ff ff    	lea    -0xf493(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	8d 83 79 0b ff ff    	lea    -0xf487(%ebx),%eax
f01007aa:	50                   	push   %eax
f01007ab:	56                   	push   %esi
f01007ac:	e8 a0 03 00 00       	call   f0100b51 <cprintf>
	return 0;
}
f01007b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007b9:	5b                   	pop    %ebx
f01007ba:	5e                   	pop    %esi
f01007bb:	5d                   	pop    %ebp
f01007bc:	c3                   	ret    

f01007bd <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007bd:	55                   	push   %ebp
f01007be:	89 e5                	mov    %esp,%ebp
f01007c0:	57                   	push   %edi
f01007c1:	56                   	push   %esi
f01007c2:	53                   	push   %ebx
f01007c3:	83 ec 18             	sub    $0x18,%esp
f01007c6:	e8 f1 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007cb:	81 c3 3d 0b 01 00    	add    $0x10b3d,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d1:	8d 83 83 0b ff ff    	lea    -0xf47d(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 74 03 00 00       	call   f0100b51 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007dd:	83 c4 08             	add    $0x8,%esp
f01007e0:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f01007e6:	8d 83 3c 0c ff ff    	lea    -0xf3c4(%ebx),%eax
f01007ec:	50                   	push   %eax
f01007ed:	e8 5f 03 00 00       	call   f0100b51 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007fb:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100801:	50                   	push   %eax
f0100802:	57                   	push   %edi
f0100803:	8d 83 64 0c ff ff    	lea    -0xf39c(%ebx),%eax
f0100809:	50                   	push   %eax
f010080a:	e8 42 03 00 00       	call   f0100b51 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010080f:	83 c4 0c             	add    $0xc,%esp
f0100812:	c7 c0 71 1b 10 f0    	mov    $0xf0101b71,%eax
f0100818:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081e:	52                   	push   %edx
f010081f:	50                   	push   %eax
f0100820:	8d 83 88 0c ff ff    	lea    -0xf378(%ebx),%eax
f0100826:	50                   	push   %eax
f0100827:	e8 25 03 00 00       	call   f0100b51 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100835:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010083b:	52                   	push   %edx
f010083c:	50                   	push   %eax
f010083d:	8d 83 ac 0c ff ff    	lea    -0xf354(%ebx),%eax
f0100843:	50                   	push   %eax
f0100844:	e8 08 03 00 00       	call   f0100b51 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100849:	83 c4 0c             	add    $0xc,%esp
f010084c:	c7 c6 c0 36 11 f0    	mov    $0xf01136c0,%esi
f0100852:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100858:	50                   	push   %eax
f0100859:	56                   	push   %esi
f010085a:	8d 83 d0 0c ff ff    	lea    -0xf330(%ebx),%eax
f0100860:	50                   	push   %eax
f0100861:	e8 eb 02 00 00       	call   f0100b51 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100869:	29 fe                	sub    %edi,%esi
f010086b:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100871:	c1 fe 0a             	sar    $0xa,%esi
f0100874:	56                   	push   %esi
f0100875:	8d 83 f4 0c ff ff    	lea    -0xf30c(%ebx),%eax
f010087b:	50                   	push   %eax
f010087c:	e8 d0 02 00 00       	call   f0100b51 <cprintf>
	return 0;
}
f0100881:	b8 00 00 00 00       	mov    $0x0,%eax
f0100886:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100889:	5b                   	pop    %ebx
f010088a:	5e                   	pop    %esi
f010088b:	5f                   	pop    %edi
f010088c:	5d                   	pop    %ebp
f010088d:	c3                   	ret    

f010088e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010088e:	55                   	push   %ebp
f010088f:	89 e5                	mov    %esp,%ebp
f0100891:	57                   	push   %edi
f0100892:	56                   	push   %esi
f0100893:	53                   	push   %ebx
f0100894:	83 ec 48             	sub    $0x48,%esp
f0100897:	e8 20 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010089c:	81 c3 6c 0a 01 00    	add    $0x10a6c,%ebx
	// Your code here.
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f01008a2:	8d 83 9c 0b ff ff    	lea    -0xf464(%ebx),%eax
f01008a8:	50                   	push   %eax
f01008a9:	e8 a3 02 00 00       	call   f0100b51 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ae:	89 e8                	mov    %ebp,%eax
	for(uint32_t* ebp = (uint32_t *) read_ebp(); ebp; ebp = (uint32_t*) ebp[0])
f01008b0:	89 c7                	mov    %eax,%edi
f01008b2:	83 c4 10             	add    $0x10,%esp
			cprintf("%08x ", ebp[i]);
		cprintf("\n");
		debuginfo_eip(ebp[1], &info);
		cprintf("%s:%d: ", info.eip_file, info.eip_line);
		for(int i = 0; i < info.eip_fn_namelen; i++)
			cprintf("%c", info.eip_fn_name[i]);
f01008b5:	8d 83 ce 0b ff ff    	lea    -0xf432(%ebx),%eax
f01008bb:	89 45 bc             	mov    %eax,-0x44(%ebp)
	for(uint32_t* ebp = (uint32_t *) read_ebp(); ebp; ebp = (uint32_t*) ebp[0])
f01008be:	eb 3a                	jmp    f01008fa <mon_backtrace+0x6c>
			cprintf("%c", info.eip_fn_name[i]);
f01008c0:	83 ec 08             	sub    $0x8,%esp
f01008c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01008c6:	0f be 04 30          	movsbl (%eax,%esi,1),%eax
f01008ca:	50                   	push   %eax
f01008cb:	57                   	push   %edi
f01008cc:	e8 80 02 00 00       	call   f0100b51 <cprintf>
		for(int i = 0; i < info.eip_fn_namelen; i++)
f01008d1:	83 c6 01             	add    $0x1,%esi
f01008d4:	83 c4 10             	add    $0x10,%esp
f01008d7:	39 75 dc             	cmp    %esi,-0x24(%ebp)
f01008da:	7f e4                	jg     f01008c0 <mon_backtrace+0x32>
		cprintf("+%d\n", ebp[1] - (int)info.eip_fn_addr);
f01008dc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01008df:	83 ec 08             	sub    $0x8,%esp
f01008e2:	8b 47 04             	mov    0x4(%edi),%eax
f01008e5:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008e8:	50                   	push   %eax
f01008e9:	8d 83 d1 0b ff ff    	lea    -0xf42f(%ebx),%eax
f01008ef:	50                   	push   %eax
f01008f0:	e8 5c 02 00 00       	call   f0100b51 <cprintf>
	for(uint32_t* ebp = (uint32_t *) read_ebp(); ebp; ebp = (uint32_t*) ebp[0])
f01008f5:	8b 3f                	mov    (%edi),%edi
f01008f7:	83 c4 10             	add    $0x10,%esp
f01008fa:	85 ff                	test   %edi,%edi
f01008fc:	0f 84 89 00 00 00    	je     f010098b <mon_backtrace+0xfd>
		cprintf("ebp %08x  eip %08x  args ", ebp, ebp[1]);
f0100902:	83 ec 04             	sub    $0x4,%esp
f0100905:	ff 77 04             	push   0x4(%edi)
f0100908:	57                   	push   %edi
f0100909:	8d 83 ae 0b ff ff    	lea    -0xf452(%ebx),%eax
f010090f:	50                   	push   %eax
f0100910:	e8 3c 02 00 00       	call   f0100b51 <cprintf>
f0100915:	8d 77 08             	lea    0x8(%edi),%esi
f0100918:	8d 47 1c             	lea    0x1c(%edi),%eax
f010091b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010091e:	83 c4 10             	add    $0x10,%esp
			cprintf("%08x ", ebp[i]);
f0100921:	8d 83 c8 0b ff ff    	lea    -0xf438(%ebx),%eax
f0100927:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010092a:	89 c7                	mov    %eax,%edi
f010092c:	83 ec 08             	sub    $0x8,%esp
f010092f:	ff 36                	push   (%esi)
f0100931:	57                   	push   %edi
f0100932:	e8 1a 02 00 00       	call   f0100b51 <cprintf>
		for(int i = 2; i < 7; i++)
f0100937:	83 c6 04             	add    $0x4,%esi
f010093a:	83 c4 10             	add    $0x10,%esp
f010093d:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0100940:	75 ea                	jne    f010092c <mon_backtrace+0x9e>
		cprintf("\n");
f0100942:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100945:	83 ec 0c             	sub    $0xc,%esp
f0100948:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f010094e:	50                   	push   %eax
f010094f:	e8 fd 01 00 00       	call   f0100b51 <cprintf>
		debuginfo_eip(ebp[1], &info);
f0100954:	83 c4 08             	add    $0x8,%esp
f0100957:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010095a:	50                   	push   %eax
f010095b:	ff 77 04             	push   0x4(%edi)
f010095e:	e8 f7 02 00 00       	call   f0100c5a <debuginfo_eip>
		cprintf("%s:%d: ", info.eip_file, info.eip_line);
f0100963:	83 c4 0c             	add    $0xc,%esp
f0100966:	ff 75 d4             	push   -0x2c(%ebp)
f0100969:	ff 75 d0             	push   -0x30(%ebp)
f010096c:	8d 83 da 08 ff ff    	lea    -0xf726(%ebx),%eax
f0100972:	50                   	push   %eax
f0100973:	e8 d9 01 00 00       	call   f0100b51 <cprintf>
		for(int i = 0; i < info.eip_fn_namelen; i++)
f0100978:	83 c4 10             	add    $0x10,%esp
f010097b:	be 00 00 00 00       	mov    $0x0,%esi
f0100980:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100983:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100986:	e9 4c ff ff ff       	jmp    f01008d7 <mon_backtrace+0x49>
	}
	return 0;
}
f010098b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100990:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100993:	5b                   	pop    %ebx
f0100994:	5e                   	pop    %esi
f0100995:	5f                   	pop    %edi
f0100996:	5d                   	pop    %ebp
f0100997:	c3                   	ret    

f0100998 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100998:	55                   	push   %ebp
f0100999:	89 e5                	mov    %esp,%ebp
f010099b:	57                   	push   %edi
f010099c:	56                   	push   %esi
f010099d:	53                   	push   %ebx
f010099e:	83 ec 68             	sub    $0x68,%esp
f01009a1:	e8 16 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01009a6:	81 c3 62 09 01 00    	add    $0x10962,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009ac:	8d 83 20 0d ff ff    	lea    -0xf2e0(%ebx),%eax
f01009b2:	50                   	push   %eax
f01009b3:	e8 99 01 00 00       	call   f0100b51 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009b8:	8d 83 44 0d ff ff    	lea    -0xf2bc(%ebx),%eax
f01009be:	89 04 24             	mov    %eax,(%esp)
f01009c1:	e8 8b 01 00 00       	call   f0100b51 <cprintf>
f01009c6:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009c9:	8d bb da 0b ff ff    	lea    -0xf426(%ebx),%edi
f01009cf:	eb 4a                	jmp    f0100a1b <monitor+0x83>
f01009d1:	83 ec 08             	sub    $0x8,%esp
f01009d4:	0f be c0             	movsbl %al,%eax
f01009d7:	50                   	push   %eax
f01009d8:	57                   	push   %edi
f01009d9:	e8 2e 0d 00 00       	call   f010170c <strchr>
f01009de:	83 c4 10             	add    $0x10,%esp
f01009e1:	85 c0                	test   %eax,%eax
f01009e3:	74 08                	je     f01009ed <monitor+0x55>
			*buf++ = 0;
f01009e5:	c6 06 00             	movb   $0x0,(%esi)
f01009e8:	8d 76 01             	lea    0x1(%esi),%esi
f01009eb:	eb 76                	jmp    f0100a63 <monitor+0xcb>
		if (*buf == 0)
f01009ed:	80 3e 00             	cmpb   $0x0,(%esi)
f01009f0:	74 7c                	je     f0100a6e <monitor+0xd6>
		if (argc == MAXARGS-1) {
f01009f2:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009f6:	74 0f                	je     f0100a07 <monitor+0x6f>
		argv[argc++] = buf;
f01009f8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009fb:	8d 48 01             	lea    0x1(%eax),%ecx
f01009fe:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100a01:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a05:	eb 41                	jmp    f0100a48 <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a07:	83 ec 08             	sub    $0x8,%esp
f0100a0a:	6a 10                	push   $0x10
f0100a0c:	8d 83 df 0b ff ff    	lea    -0xf421(%ebx),%eax
f0100a12:	50                   	push   %eax
f0100a13:	e8 39 01 00 00       	call   f0100b51 <cprintf>
			return 0;
f0100a18:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100a1b:	8d 83 d6 0b ff ff    	lea    -0xf42a(%ebx),%eax
f0100a21:	89 c6                	mov    %eax,%esi
f0100a23:	83 ec 0c             	sub    $0xc,%esp
f0100a26:	56                   	push   %esi
f0100a27:	e8 8f 0a 00 00       	call   f01014bb <readline>
		if (buf != NULL)
f0100a2c:	83 c4 10             	add    $0x10,%esp
f0100a2f:	85 c0                	test   %eax,%eax
f0100a31:	74 f0                	je     f0100a23 <monitor+0x8b>
	argv[argc] = 0;
f0100a33:	89 c6                	mov    %eax,%esi
f0100a35:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a3c:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a43:	eb 1e                	jmp    f0100a63 <monitor+0xcb>
			buf++;
f0100a45:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a48:	0f b6 06             	movzbl (%esi),%eax
f0100a4b:	84 c0                	test   %al,%al
f0100a4d:	74 14                	je     f0100a63 <monitor+0xcb>
f0100a4f:	83 ec 08             	sub    $0x8,%esp
f0100a52:	0f be c0             	movsbl %al,%eax
f0100a55:	50                   	push   %eax
f0100a56:	57                   	push   %edi
f0100a57:	e8 b0 0c 00 00       	call   f010170c <strchr>
f0100a5c:	83 c4 10             	add    $0x10,%esp
f0100a5f:	85 c0                	test   %eax,%eax
f0100a61:	74 e2                	je     f0100a45 <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a63:	0f b6 06             	movzbl (%esi),%eax
f0100a66:	84 c0                	test   %al,%al
f0100a68:	0f 85 63 ff ff ff    	jne    f01009d1 <monitor+0x39>
	argv[argc] = 0;
f0100a6e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a71:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a78:	00 
	if (argc == 0)
f0100a79:	85 c0                	test   %eax,%eax
f0100a7b:	74 9e                	je     f0100a1b <monitor+0x83>
f0100a7d:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a83:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a88:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a8b:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a8d:	83 ec 08             	sub    $0x8,%esp
f0100a90:	ff 36                	push   (%esi)
f0100a92:	ff 75 a8             	push   -0x58(%ebp)
f0100a95:	e8 12 0c 00 00       	call   f01016ac <strcmp>
f0100a9a:	83 c4 10             	add    $0x10,%esp
f0100a9d:	85 c0                	test   %eax,%eax
f0100a9f:	74 28                	je     f0100ac9 <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100aa1:	83 c7 01             	add    $0x1,%edi
f0100aa4:	83 c6 0c             	add    $0xc,%esi
f0100aa7:	83 ff 03             	cmp    $0x3,%edi
f0100aaa:	75 e1                	jne    f0100a8d <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aac:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100aaf:	83 ec 08             	sub    $0x8,%esp
f0100ab2:	ff 75 a8             	push   -0x58(%ebp)
f0100ab5:	8d 83 fc 0b ff ff    	lea    -0xf404(%ebx),%eax
f0100abb:	50                   	push   %eax
f0100abc:	e8 90 00 00 00       	call   f0100b51 <cprintf>
	return 0;
f0100ac1:	83 c4 10             	add    $0x10,%esp
f0100ac4:	e9 52 ff ff ff       	jmp    f0100a1b <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100ac9:	89 f8                	mov    %edi,%eax
f0100acb:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100ace:	83 ec 04             	sub    $0x4,%esp
f0100ad1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ad4:	ff 75 08             	push   0x8(%ebp)
f0100ad7:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ada:	52                   	push   %edx
f0100adb:	ff 75 a4             	push   -0x5c(%ebp)
f0100ade:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ae5:	83 c4 10             	add    $0x10,%esp
f0100ae8:	85 c0                	test   %eax,%eax
f0100aea:	0f 89 2b ff ff ff    	jns    f0100a1b <monitor+0x83>
				break;
	}
}
f0100af0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100af3:	5b                   	pop    %ebx
f0100af4:	5e                   	pop    %esi
f0100af5:	5f                   	pop    %edi
f0100af6:	5d                   	pop    %ebp
f0100af7:	c3                   	ret    

f0100af8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100af8:	55                   	push   %ebp
f0100af9:	89 e5                	mov    %esp,%ebp
f0100afb:	53                   	push   %ebx
f0100afc:	83 ec 10             	sub    $0x10,%esp
f0100aff:	e8 b8 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100b04:	81 c3 04 08 01 00    	add    $0x10804,%ebx
	cputchar(ch);
f0100b0a:	ff 75 08             	push   0x8(%ebp)
f0100b0d:	e8 15 fc ff ff       	call   f0100727 <cputchar>
	*cnt++;
}
f0100b12:	83 c4 10             	add    $0x10,%esp
f0100b15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b18:	c9                   	leave  
f0100b19:	c3                   	ret    

f0100b1a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b1a:	55                   	push   %ebp
f0100b1b:	89 e5                	mov    %esp,%ebp
f0100b1d:	53                   	push   %ebx
f0100b1e:	83 ec 14             	sub    $0x14,%esp
f0100b21:	e8 96 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100b26:	81 c3 e2 07 01 00    	add    $0x107e2,%ebx
	int cnt = 0;
f0100b2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b33:	ff 75 0c             	push   0xc(%ebp)
f0100b36:	ff 75 08             	push   0x8(%ebp)
f0100b39:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b3c:	50                   	push   %eax
f0100b3d:	8d 83 f0 f7 fe ff    	lea    -0x10810(%ebx),%eax
f0100b43:	50                   	push   %eax
f0100b44:	e8 51 04 00 00       	call   f0100f9a <vprintfmt>
	return cnt;
}
f0100b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b4f:	c9                   	leave  
f0100b50:	c3                   	ret    

f0100b51 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b51:	55                   	push   %ebp
f0100b52:	89 e5                	mov    %esp,%ebp
f0100b54:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b57:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b5a:	50                   	push   %eax
f0100b5b:	ff 75 08             	push   0x8(%ebp)
f0100b5e:	e8 b7 ff ff ff       	call   f0100b1a <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b63:	c9                   	leave  
f0100b64:	c3                   	ret    

f0100b65 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b65:	55                   	push   %ebp
f0100b66:	89 e5                	mov    %esp,%ebp
f0100b68:	57                   	push   %edi
f0100b69:	56                   	push   %esi
f0100b6a:	53                   	push   %ebx
f0100b6b:	83 ec 14             	sub    $0x14,%esp
f0100b6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b71:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b74:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b77:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b7a:	8b 1a                	mov    (%edx),%ebx
f0100b7c:	8b 01                	mov    (%ecx),%eax
f0100b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b81:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b88:	eb 2f                	jmp    f0100bb9 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b8a:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b8d:	39 c3                	cmp    %eax,%ebx
f0100b8f:	7f 4e                	jg     f0100bdf <stab_binsearch+0x7a>
f0100b91:	0f b6 0a             	movzbl (%edx),%ecx
f0100b94:	83 ea 0c             	sub    $0xc,%edx
f0100b97:	39 f1                	cmp    %esi,%ecx
f0100b99:	75 ef                	jne    f0100b8a <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b9b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b9e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100ba1:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100ba5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100ba8:	73 3a                	jae    f0100be4 <stab_binsearch+0x7f>
			*region_left = m;
f0100baa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100bad:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100baf:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100bb2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100bb9:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100bbc:	7f 53                	jg     f0100c11 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100bc1:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100bc4:	89 d0                	mov    %edx,%eax
f0100bc6:	c1 e8 1f             	shr    $0x1f,%eax
f0100bc9:	01 d0                	add    %edx,%eax
f0100bcb:	89 c7                	mov    %eax,%edi
f0100bcd:	d1 ff                	sar    %edi
f0100bcf:	83 e0 fe             	and    $0xfffffffe,%eax
f0100bd2:	01 f8                	add    %edi,%eax
f0100bd4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bd7:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100bdb:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100bdd:	eb ae                	jmp    f0100b8d <stab_binsearch+0x28>
			l = true_m + 1;
f0100bdf:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100be2:	eb d5                	jmp    f0100bb9 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100be4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100be7:	76 14                	jbe    f0100bfd <stab_binsearch+0x98>
			*region_right = m - 1;
f0100be9:	83 e8 01             	sub    $0x1,%eax
f0100bec:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bef:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bf2:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100bf4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bfb:	eb bc                	jmp    f0100bb9 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bfd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c00:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100c02:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100c06:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100c08:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c0f:	eb a8                	jmp    f0100bb9 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100c11:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100c15:	75 15                	jne    f0100c2c <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100c17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c1a:	8b 00                	mov    (%eax),%eax
f0100c1c:	83 e8 01             	sub    $0x1,%eax
f0100c1f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c22:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c24:	83 c4 14             	add    $0x14,%esp
f0100c27:	5b                   	pop    %ebx
f0100c28:	5e                   	pop    %esi
f0100c29:	5f                   	pop    %edi
f0100c2a:	5d                   	pop    %ebp
f0100c2b:	c3                   	ret    
		for (l = *region_right;
f0100c2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c2f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c34:	8b 0f                	mov    (%edi),%ecx
f0100c36:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c39:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100c3c:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0100c40:	39 c1                	cmp    %eax,%ecx
f0100c42:	7d 0f                	jge    f0100c53 <stab_binsearch+0xee>
f0100c44:	0f b6 1a             	movzbl (%edx),%ebx
f0100c47:	83 ea 0c             	sub    $0xc,%edx
f0100c4a:	39 f3                	cmp    %esi,%ebx
f0100c4c:	74 05                	je     f0100c53 <stab_binsearch+0xee>
		     l--)
f0100c4e:	83 e8 01             	sub    $0x1,%eax
f0100c51:	eb ed                	jmp    f0100c40 <stab_binsearch+0xdb>
		*region_left = l;
f0100c53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c56:	89 07                	mov    %eax,(%edi)
}
f0100c58:	eb ca                	jmp    f0100c24 <stab_binsearch+0xbf>

f0100c5a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c5a:	55                   	push   %ebp
f0100c5b:	89 e5                	mov    %esp,%ebp
f0100c5d:	57                   	push   %edi
f0100c5e:	56                   	push   %esi
f0100c5f:	53                   	push   %ebx
f0100c60:	83 ec 3c             	sub    $0x3c,%esp
f0100c63:	e8 54 f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c68:	81 c3 a0 06 01 00    	add    $0x106a0,%ebx
f0100c6e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline, lnum, rnum;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c71:	8d 83 69 0d ff ff    	lea    -0xf297(%ebx),%eax
f0100c77:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100c79:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100c80:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100c83:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100c8a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c8d:	89 47 10             	mov    %eax,0x10(%edi)
	info->eip_fn_narg = 0;
f0100c90:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c97:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0100c9c:	0f 86 37 01 00 00    	jbe    f0100dd9 <debuginfo_eip+0x17f>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ca2:	c7 c0 71 5c 10 f0    	mov    $0xf0105c71,%eax
f0100ca8:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100cae:	0f 86 c5 01 00 00    	jbe    f0100e79 <debuginfo_eip+0x21f>
f0100cb4:	c7 c0 96 72 10 f0    	mov    $0xf0107296,%eax
f0100cba:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100cbe:	0f 85 bc 01 00 00    	jne    f0100e80 <debuginfo_eip+0x226>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100cc4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ccb:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100cd1:	c7 c2 70 5c 10 f0    	mov    $0xf0105c70,%edx
f0100cd7:	29 c2                	sub    %eax,%edx
f0100cd9:	c1 fa 02             	sar    $0x2,%edx
f0100cdc:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100ce2:	83 ea 01             	sub    $0x1,%edx
f0100ce5:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100ce8:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100ceb:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cee:	83 ec 08             	sub    $0x8,%esp
f0100cf1:	ff 75 08             	push   0x8(%ebp)
f0100cf4:	6a 64                	push   $0x64
f0100cf6:	e8 6a fe ff ff       	call   f0100b65 <stab_binsearch>
	if (lfile == 0)
f0100cfb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100cfe:	89 75 b8             	mov    %esi,-0x48(%ebp)
f0100d01:	83 c4 10             	add    $0x10,%esp
f0100d04:	85 f6                	test   %esi,%esi
f0100d06:	0f 84 7b 01 00 00    	je     f0100e87 <debuginfo_eip+0x22d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d0c:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f0100d0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d12:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100d15:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d18:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d1b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d1e:	83 ec 08             	sub    $0x8,%esp
f0100d21:	ff 75 08             	push   0x8(%ebp)
f0100d24:	6a 24                	push   $0x24
f0100d26:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100d2c:	e8 34 fe ff ff       	call   f0100b65 <stab_binsearch>

	if (lfun <= rfun) {
f0100d31:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d34:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0100d37:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100d3a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100d3d:	83 c4 10             	add    $0x10,%esp
f0100d40:	39 c8                	cmp    %ecx,%eax
f0100d42:	7f 39                	jg     f0100d7d <debuginfo_eip+0x123>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d44:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100d47:	c7 c2 8c 22 10 f0    	mov    $0xf010228c,%edx
f0100d4d:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100d50:	8b 11                	mov    (%ecx),%edx
f0100d52:	c7 c0 96 72 10 f0    	mov    $0xf0107296,%eax
f0100d58:	81 e8 71 5c 10 f0    	sub    $0xf0105c71,%eax
f0100d5e:	39 c2                	cmp    %eax,%edx
f0100d60:	73 09                	jae    f0100d6b <debuginfo_eip+0x111>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d62:	81 c2 71 5c 10 f0    	add    $0xf0105c71,%edx
f0100d68:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d6b:	8b 41 08             	mov    0x8(%ecx),%eax
f0100d6e:	89 47 10             	mov    %eax,0x10(%edi)
		addr -= info->eip_fn_addr;
f0100d71:	29 45 08             	sub    %eax,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
		rline = rfun;
f0100d74:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d77:	89 45 c0             	mov    %eax,-0x40(%ebp)
		lline = lfun;
f0100d7a:	8b 75 bc             	mov    -0x44(%ebp),%esi
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d7d:	83 ec 08             	sub    $0x8,%esp
f0100d80:	6a 3a                	push   $0x3a
f0100d82:	ff 77 08             	push   0x8(%edi)
f0100d85:	e8 a5 09 00 00       	call   f010172f <strfind>
f0100d8a:	2b 47 08             	sub    0x8(%edi),%eax
f0100d8d:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	lnum = lline;
f0100d90:	89 75 d4             	mov    %esi,-0x2c(%ebp)
	rnum = rline;
f0100d93:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100d96:	89 45 d0             	mov    %eax,-0x30(%ebp)
	stab_binsearch(stabs, &lnum, &rnum, N_SLINE, addr);
f0100d99:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d9c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d9f:	83 c4 08             	add    $0x8,%esp
f0100da2:	ff 75 08             	push   0x8(%ebp)
f0100da5:	6a 44                	push   $0x44
f0100da7:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100dad:	e8 b3 fd ff ff       	call   f0100b65 <stab_binsearch>
	if (lnum <= rnum)
f0100db2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100db5:	83 c4 10             	add    $0x10,%esp
f0100db8:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0100dbb:	0f 8f cd 00 00 00    	jg     f0100e8e <debuginfo_eip+0x234>
		info->eip_line = rnum;
f0100dc1:	89 47 04             	mov    %eax,0x4(%edi)
f0100dc4:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100dc7:	c7 c2 8c 22 10 f0    	mov    $0xf010228c,%edx
f0100dcd:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
f0100dd1:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0100dd4:	8b 7d b8             	mov    -0x48(%ebp),%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100dd7:	eb 1e                	jmp    f0100df7 <debuginfo_eip+0x19d>
  	        panic("User address");
f0100dd9:	83 ec 04             	sub    $0x4,%esp
f0100ddc:	8d 83 73 0d ff ff    	lea    -0xf28d(%ebx),%eax
f0100de2:	50                   	push   %eax
f0100de3:	6a 7f                	push   $0x7f
f0100de5:	8d 83 80 0d ff ff    	lea    -0xf280(%ebx),%eax
f0100deb:	50                   	push   %eax
f0100dec:	e8 15 f3 ff ff       	call   f0100106 <_panic>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100df1:	83 ee 01             	sub    $0x1,%esi
f0100df4:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100df7:	39 f7                	cmp    %esi,%edi
f0100df9:	7f 3c                	jg     f0100e37 <debuginfo_eip+0x1dd>
	       && stabs[lline].n_type != N_SOL
f0100dfb:	0f b6 10             	movzbl (%eax),%edx
f0100dfe:	80 fa 84             	cmp    $0x84,%dl
f0100e01:	74 0b                	je     f0100e0e <debuginfo_eip+0x1b4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e03:	80 fa 64             	cmp    $0x64,%dl
f0100e06:	75 e9                	jne    f0100df1 <debuginfo_eip+0x197>
f0100e08:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100e0c:	74 e3                	je     f0100df1 <debuginfo_eip+0x197>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e0e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100e11:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100e14:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100e1a:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e1d:	c7 c0 96 72 10 f0    	mov    $0xf0107296,%eax
f0100e23:	81 e8 71 5c 10 f0    	sub    $0xf0105c71,%eax
f0100e29:	39 c2                	cmp    %eax,%edx
f0100e2b:	73 0d                	jae    f0100e3a <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e2d:	81 c2 71 5c 10 f0    	add    $0xf0105c71,%edx
f0100e33:	89 17                	mov    %edx,(%edi)
f0100e35:	eb 03                	jmp    f0100e3a <debuginfo_eip+0x1e0>
f0100e37:	8b 7d 0c             	mov    0xc(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e3a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e3f:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0100e42:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100e45:	39 ce                	cmp    %ecx,%esi
f0100e47:	7d 51                	jge    f0100e9a <debuginfo_eip+0x240>
		for (lline = lfun + 1;
f0100e49:	8d 56 01             	lea    0x1(%esi),%edx
f0100e4c:	8d 0c 76             	lea    (%esi,%esi,2),%ecx
f0100e4f:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100e55:	8d 44 88 10          	lea    0x10(%eax,%ecx,4),%eax
f0100e59:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100e5c:	eb 07                	jmp    f0100e65 <debuginfo_eip+0x20b>
			info->eip_fn_narg++;
f0100e5e:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100e62:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e65:	39 d1                	cmp    %edx,%ecx
f0100e67:	74 2c                	je     f0100e95 <debuginfo_eip+0x23b>
f0100e69:	83 c0 0c             	add    $0xc,%eax
f0100e6c:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100e70:	74 ec                	je     f0100e5e <debuginfo_eip+0x204>
	return 0;
f0100e72:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e77:	eb 21                	jmp    f0100e9a <debuginfo_eip+0x240>
		return -1;
f0100e79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e7e:	eb 1a                	jmp    f0100e9a <debuginfo_eip+0x240>
f0100e80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e85:	eb 13                	jmp    f0100e9a <debuginfo_eip+0x240>
		return -1;
f0100e87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e8c:	eb 0c                	jmp    f0100e9a <debuginfo_eip+0x240>
		return -1;
f0100e8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e93:	eb 05                	jmp    f0100e9a <debuginfo_eip+0x240>
	return 0;
f0100e95:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e9d:	5b                   	pop    %ebx
f0100e9e:	5e                   	pop    %esi
f0100e9f:	5f                   	pop    %edi
f0100ea0:	5d                   	pop    %ebp
f0100ea1:	c3                   	ret    

f0100ea2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ea2:	55                   	push   %ebp
f0100ea3:	89 e5                	mov    %esp,%ebp
f0100ea5:	57                   	push   %edi
f0100ea6:	56                   	push   %esi
f0100ea7:	53                   	push   %ebx
f0100ea8:	83 ec 2c             	sub    $0x2c,%esp
f0100eab:	e8 07 06 00 00       	call   f01014b7 <__x86.get_pc_thunk.cx>
f0100eb0:	81 c1 58 04 01 00    	add    $0x10458,%ecx
f0100eb6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100eb9:	89 c7                	mov    %eax,%edi
f0100ebb:	89 d6                	mov    %edx,%esi
f0100ebd:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ec0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ec3:	89 d1                	mov    %edx,%ecx
f0100ec5:	89 c2                	mov    %eax,%edx
f0100ec7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100eca:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100ecd:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ed0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ed3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ed6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100edd:	39 c2                	cmp    %eax,%edx
f0100edf:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100ee2:	72 41                	jb     f0100f25 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ee4:	83 ec 0c             	sub    $0xc,%esp
f0100ee7:	ff 75 18             	push   0x18(%ebp)
f0100eea:	83 eb 01             	sub    $0x1,%ebx
f0100eed:	53                   	push   %ebx
f0100eee:	50                   	push   %eax
f0100eef:	83 ec 08             	sub    $0x8,%esp
f0100ef2:	ff 75 e4             	push   -0x1c(%ebp)
f0100ef5:	ff 75 e0             	push   -0x20(%ebp)
f0100ef8:	ff 75 d4             	push   -0x2c(%ebp)
f0100efb:	ff 75 d0             	push   -0x30(%ebp)
f0100efe:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f01:	e8 3a 0a 00 00       	call   f0101940 <__udivdi3>
f0100f06:	83 c4 18             	add    $0x18,%esp
f0100f09:	52                   	push   %edx
f0100f0a:	50                   	push   %eax
f0100f0b:	89 f2                	mov    %esi,%edx
f0100f0d:	89 f8                	mov    %edi,%eax
f0100f0f:	e8 8e ff ff ff       	call   f0100ea2 <printnum>
f0100f14:	83 c4 20             	add    $0x20,%esp
f0100f17:	eb 13                	jmp    f0100f2c <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f19:	83 ec 08             	sub    $0x8,%esp
f0100f1c:	56                   	push   %esi
f0100f1d:	ff 75 18             	push   0x18(%ebp)
f0100f20:	ff d7                	call   *%edi
f0100f22:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f25:	83 eb 01             	sub    $0x1,%ebx
f0100f28:	85 db                	test   %ebx,%ebx
f0100f2a:	7f ed                	jg     f0100f19 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f2c:	83 ec 08             	sub    $0x8,%esp
f0100f2f:	56                   	push   %esi
f0100f30:	83 ec 04             	sub    $0x4,%esp
f0100f33:	ff 75 e4             	push   -0x1c(%ebp)
f0100f36:	ff 75 e0             	push   -0x20(%ebp)
f0100f39:	ff 75 d4             	push   -0x2c(%ebp)
f0100f3c:	ff 75 d0             	push   -0x30(%ebp)
f0100f3f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f42:	e8 19 0b 00 00       	call   f0101a60 <__umoddi3>
f0100f47:	83 c4 14             	add    $0x14,%esp
f0100f4a:	0f be 84 03 8e 0d ff 	movsbl -0xf272(%ebx,%eax,1),%eax
f0100f51:	ff 
f0100f52:	50                   	push   %eax
f0100f53:	ff d7                	call   *%edi
}
f0100f55:	83 c4 10             	add    $0x10,%esp
f0100f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f5b:	5b                   	pop    %ebx
f0100f5c:	5e                   	pop    %esi
f0100f5d:	5f                   	pop    %edi
f0100f5e:	5d                   	pop    %ebp
f0100f5f:	c3                   	ret    

f0100f60 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f60:	55                   	push   %ebp
f0100f61:	89 e5                	mov    %esp,%ebp
f0100f63:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f66:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f6a:	8b 10                	mov    (%eax),%edx
f0100f6c:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f6f:	73 0a                	jae    f0100f7b <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f71:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f74:	89 08                	mov    %ecx,(%eax)
f0100f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f79:	88 02                	mov    %al,(%edx)
}
f0100f7b:	5d                   	pop    %ebp
f0100f7c:	c3                   	ret    

f0100f7d <printfmt>:
{
f0100f7d:	55                   	push   %ebp
f0100f7e:	89 e5                	mov    %esp,%ebp
f0100f80:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f83:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f86:	50                   	push   %eax
f0100f87:	ff 75 10             	push   0x10(%ebp)
f0100f8a:	ff 75 0c             	push   0xc(%ebp)
f0100f8d:	ff 75 08             	push   0x8(%ebp)
f0100f90:	e8 05 00 00 00       	call   f0100f9a <vprintfmt>
}
f0100f95:	83 c4 10             	add    $0x10,%esp
f0100f98:	c9                   	leave  
f0100f99:	c3                   	ret    

f0100f9a <vprintfmt>:
{
f0100f9a:	55                   	push   %ebp
f0100f9b:	89 e5                	mov    %esp,%ebp
f0100f9d:	57                   	push   %edi
f0100f9e:	56                   	push   %esi
f0100f9f:	53                   	push   %ebx
f0100fa0:	83 ec 3c             	sub    $0x3c,%esp
f0100fa3:	e8 a6 f7 ff ff       	call   f010074e <__x86.get_pc_thunk.ax>
f0100fa8:	05 60 03 01 00       	add    $0x10360,%eax
f0100fad:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fb0:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fb3:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100fb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100fb9:	8d 80 3c 1d 00 00    	lea    0x1d3c(%eax),%eax
f0100fbf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100fc2:	eb 0a                	jmp    f0100fce <vprintfmt+0x34>
			putch(ch, putdat);
f0100fc4:	83 ec 08             	sub    $0x8,%esp
f0100fc7:	57                   	push   %edi
f0100fc8:	50                   	push   %eax
f0100fc9:	ff d6                	call   *%esi
f0100fcb:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100fce:	83 c3 01             	add    $0x1,%ebx
f0100fd1:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100fd5:	83 f8 25             	cmp    $0x25,%eax
f0100fd8:	74 0c                	je     f0100fe6 <vprintfmt+0x4c>
			if (ch == '\0')
f0100fda:	85 c0                	test   %eax,%eax
f0100fdc:	75 e6                	jne    f0100fc4 <vprintfmt+0x2a>
}
f0100fde:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fe1:	5b                   	pop    %ebx
f0100fe2:	5e                   	pop    %esi
f0100fe3:	5f                   	pop    %edi
f0100fe4:	5d                   	pop    %ebp
f0100fe5:	c3                   	ret    
		padc = ' ';
f0100fe6:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100fea:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0100ff1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100ff8:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0100fff:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101004:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101007:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010100a:	8d 43 01             	lea    0x1(%ebx),%eax
f010100d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101010:	0f b6 13             	movzbl (%ebx),%edx
f0101013:	8d 42 dd             	lea    -0x23(%edx),%eax
f0101016:	3c 55                	cmp    $0x55,%al
f0101018:	0f 87 fd 03 00 00    	ja     f010141b <.L20>
f010101e:	0f b6 c0             	movzbl %al,%eax
f0101021:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101024:	89 ce                	mov    %ecx,%esi
f0101026:	03 b4 81 1c 0e ff ff 	add    -0xf1e4(%ecx,%eax,4),%esi
f010102d:	ff e6                	jmp    *%esi

f010102f <.L68>:
f010102f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0101032:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0101036:	eb d2                	jmp    f010100a <vprintfmt+0x70>

f0101038 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0101038:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010103b:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f010103f:	eb c9                	jmp    f010100a <vprintfmt+0x70>

f0101041 <.L31>:
f0101041:	0f b6 d2             	movzbl %dl,%edx
f0101044:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0101047:	b8 00 00 00 00       	mov    $0x0,%eax
f010104c:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f010104f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101052:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101056:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0101059:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010105c:	83 f9 09             	cmp    $0x9,%ecx
f010105f:	77 58                	ja     f01010b9 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0101061:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0101064:	eb e9                	jmp    f010104f <.L31+0xe>

f0101066 <.L34>:
			precision = va_arg(ap, int);
f0101066:	8b 45 14             	mov    0x14(%ebp),%eax
f0101069:	8b 00                	mov    (%eax),%eax
f010106b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010106e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101071:	8d 40 04             	lea    0x4(%eax),%eax
f0101074:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101077:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f010107a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010107e:	79 8a                	jns    f010100a <vprintfmt+0x70>
				width = precision, precision = -1;
f0101080:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101083:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101086:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010108d:	e9 78 ff ff ff       	jmp    f010100a <vprintfmt+0x70>

f0101092 <.L33>:
f0101092:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101095:	85 d2                	test   %edx,%edx
f0101097:	b8 00 00 00 00       	mov    $0x0,%eax
f010109c:	0f 49 c2             	cmovns %edx,%eax
f010109f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010a2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01010a5:	e9 60 ff ff ff       	jmp    f010100a <vprintfmt+0x70>

f01010aa <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01010aa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01010ad:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f01010b4:	e9 51 ff ff ff       	jmp    f010100a <vprintfmt+0x70>
f01010b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010bc:	89 75 08             	mov    %esi,0x8(%ebp)
f01010bf:	eb b9                	jmp    f010107a <.L34+0x14>

f01010c1 <.L27>:
			lflag++;
f01010c1:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01010c8:	e9 3d ff ff ff       	jmp    f010100a <vprintfmt+0x70>

f01010cd <.L30>:
			putch(va_arg(ap, int), putdat);
f01010cd:	8b 75 08             	mov    0x8(%ebp),%esi
f01010d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d3:	8d 58 04             	lea    0x4(%eax),%ebx
f01010d6:	83 ec 08             	sub    $0x8,%esp
f01010d9:	57                   	push   %edi
f01010da:	ff 30                	push   (%eax)
f01010dc:	ff d6                	call   *%esi
			break;
f01010de:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01010e1:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01010e4:	e9 c8 02 00 00       	jmp    f01013b1 <.L25+0x45>

f01010e9 <.L28>:
			err = va_arg(ap, int);
f01010e9:	8b 75 08             	mov    0x8(%ebp),%esi
f01010ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ef:	8d 58 04             	lea    0x4(%eax),%ebx
f01010f2:	8b 10                	mov    (%eax),%edx
f01010f4:	89 d0                	mov    %edx,%eax
f01010f6:	f7 d8                	neg    %eax
f01010f8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010fb:	83 f8 06             	cmp    $0x6,%eax
f01010fe:	7f 27                	jg     f0101127 <.L28+0x3e>
f0101100:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101103:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101106:	85 d2                	test   %edx,%edx
f0101108:	74 1d                	je     f0101127 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f010110a:	52                   	push   %edx
f010110b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010110e:	8d 80 af 0d ff ff    	lea    -0xf251(%eax),%eax
f0101114:	50                   	push   %eax
f0101115:	57                   	push   %edi
f0101116:	56                   	push   %esi
f0101117:	e8 61 fe ff ff       	call   f0100f7d <printfmt>
f010111c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010111f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101122:	e9 8a 02 00 00       	jmp    f01013b1 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0101127:	50                   	push   %eax
f0101128:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010112b:	8d 80 a6 0d ff ff    	lea    -0xf25a(%eax),%eax
f0101131:	50                   	push   %eax
f0101132:	57                   	push   %edi
f0101133:	56                   	push   %esi
f0101134:	e8 44 fe ff ff       	call   f0100f7d <printfmt>
f0101139:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010113c:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010113f:	e9 6d 02 00 00       	jmp    f01013b1 <.L25+0x45>

f0101144 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0101144:	8b 75 08             	mov    0x8(%ebp),%esi
f0101147:	8b 45 14             	mov    0x14(%ebp),%eax
f010114a:	83 c0 04             	add    $0x4,%eax
f010114d:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0101150:	8b 45 14             	mov    0x14(%ebp),%eax
f0101153:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0101155:	85 d2                	test   %edx,%edx
f0101157:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010115a:	8d 80 9f 0d ff ff    	lea    -0xf261(%eax),%eax
f0101160:	0f 45 c2             	cmovne %edx,%eax
f0101163:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0101166:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010116a:	7e 06                	jle    f0101172 <.L24+0x2e>
f010116c:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0101170:	75 0d                	jne    f010117f <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101172:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101175:	89 c3                	mov    %eax,%ebx
f0101177:	03 45 d4             	add    -0x2c(%ebp),%eax
f010117a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010117d:	eb 58                	jmp    f01011d7 <.L24+0x93>
f010117f:	83 ec 08             	sub    $0x8,%esp
f0101182:	ff 75 d8             	push   -0x28(%ebp)
f0101185:	ff 75 c8             	push   -0x38(%ebp)
f0101188:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010118b:	e8 48 04 00 00       	call   f01015d8 <strnlen>
f0101190:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101193:	29 c2                	sub    %eax,%edx
f0101195:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0101198:	83 c4 10             	add    $0x10,%esp
f010119b:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010119d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01011a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01011a4:	eb 0f                	jmp    f01011b5 <.L24+0x71>
					putch(padc, putdat);
f01011a6:	83 ec 08             	sub    $0x8,%esp
f01011a9:	57                   	push   %edi
f01011aa:	ff 75 d4             	push   -0x2c(%ebp)
f01011ad:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01011af:	83 eb 01             	sub    $0x1,%ebx
f01011b2:	83 c4 10             	add    $0x10,%esp
f01011b5:	85 db                	test   %ebx,%ebx
f01011b7:	7f ed                	jg     f01011a6 <.L24+0x62>
f01011b9:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01011bc:	85 d2                	test   %edx,%edx
f01011be:	b8 00 00 00 00       	mov    $0x0,%eax
f01011c3:	0f 49 c2             	cmovns %edx,%eax
f01011c6:	29 c2                	sub    %eax,%edx
f01011c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01011cb:	eb a5                	jmp    f0101172 <.L24+0x2e>
					putch(ch, putdat);
f01011cd:	83 ec 08             	sub    $0x8,%esp
f01011d0:	57                   	push   %edi
f01011d1:	52                   	push   %edx
f01011d2:	ff d6                	call   *%esi
f01011d4:	83 c4 10             	add    $0x10,%esp
f01011d7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01011da:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011dc:	83 c3 01             	add    $0x1,%ebx
f01011df:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01011e3:	0f be d0             	movsbl %al,%edx
f01011e6:	85 d2                	test   %edx,%edx
f01011e8:	74 4b                	je     f0101235 <.L24+0xf1>
f01011ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01011ee:	78 06                	js     f01011f6 <.L24+0xb2>
f01011f0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01011f4:	78 1e                	js     f0101214 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f01011f6:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01011fa:	74 d1                	je     f01011cd <.L24+0x89>
f01011fc:	0f be c0             	movsbl %al,%eax
f01011ff:	83 e8 20             	sub    $0x20,%eax
f0101202:	83 f8 5e             	cmp    $0x5e,%eax
f0101205:	76 c6                	jbe    f01011cd <.L24+0x89>
					putch('?', putdat);
f0101207:	83 ec 08             	sub    $0x8,%esp
f010120a:	57                   	push   %edi
f010120b:	6a 3f                	push   $0x3f
f010120d:	ff d6                	call   *%esi
f010120f:	83 c4 10             	add    $0x10,%esp
f0101212:	eb c3                	jmp    f01011d7 <.L24+0x93>
f0101214:	89 cb                	mov    %ecx,%ebx
f0101216:	eb 0e                	jmp    f0101226 <.L24+0xe2>
				putch(' ', putdat);
f0101218:	83 ec 08             	sub    $0x8,%esp
f010121b:	57                   	push   %edi
f010121c:	6a 20                	push   $0x20
f010121e:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101220:	83 eb 01             	sub    $0x1,%ebx
f0101223:	83 c4 10             	add    $0x10,%esp
f0101226:	85 db                	test   %ebx,%ebx
f0101228:	7f ee                	jg     f0101218 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010122a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010122d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101230:	e9 7c 01 00 00       	jmp    f01013b1 <.L25+0x45>
f0101235:	89 cb                	mov    %ecx,%ebx
f0101237:	eb ed                	jmp    f0101226 <.L24+0xe2>

f0101239 <.L29>:
	if (lflag >= 2)
f0101239:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010123c:	8b 75 08             	mov    0x8(%ebp),%esi
f010123f:	83 f9 01             	cmp    $0x1,%ecx
f0101242:	7f 1b                	jg     f010125f <.L29+0x26>
	else if (lflag)
f0101244:	85 c9                	test   %ecx,%ecx
f0101246:	74 63                	je     f01012ab <.L29+0x72>
		return va_arg(*ap, long);
f0101248:	8b 45 14             	mov    0x14(%ebp),%eax
f010124b:	8b 00                	mov    (%eax),%eax
f010124d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101250:	99                   	cltd   
f0101251:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101254:	8b 45 14             	mov    0x14(%ebp),%eax
f0101257:	8d 40 04             	lea    0x4(%eax),%eax
f010125a:	89 45 14             	mov    %eax,0x14(%ebp)
f010125d:	eb 17                	jmp    f0101276 <.L29+0x3d>
		return va_arg(*ap, long long);
f010125f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101262:	8b 50 04             	mov    0x4(%eax),%edx
f0101265:	8b 00                	mov    (%eax),%eax
f0101267:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010126a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010126d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101270:	8d 40 08             	lea    0x8(%eax),%eax
f0101273:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101276:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101279:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f010127c:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f0101281:	85 db                	test   %ebx,%ebx
f0101283:	0f 89 0e 01 00 00    	jns    f0101397 <.L25+0x2b>
				putch('-', putdat);
f0101289:	83 ec 08             	sub    $0x8,%esp
f010128c:	57                   	push   %edi
f010128d:	6a 2d                	push   $0x2d
f010128f:	ff d6                	call   *%esi
				num = -(long long) num;
f0101291:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101294:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101297:	f7 d9                	neg    %ecx
f0101299:	83 d3 00             	adc    $0x0,%ebx
f010129c:	f7 db                	neg    %ebx
f010129e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01012a1:	ba 0a 00 00 00       	mov    $0xa,%edx
f01012a6:	e9 ec 00 00 00       	jmp    f0101397 <.L25+0x2b>
		return va_arg(*ap, int);
f01012ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ae:	8b 00                	mov    (%eax),%eax
f01012b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012b3:	99                   	cltd   
f01012b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ba:	8d 40 04             	lea    0x4(%eax),%eax
f01012bd:	89 45 14             	mov    %eax,0x14(%ebp)
f01012c0:	eb b4                	jmp    f0101276 <.L29+0x3d>

f01012c2 <.L23>:
	if (lflag >= 2)
f01012c2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012c5:	8b 75 08             	mov    0x8(%ebp),%esi
f01012c8:	83 f9 01             	cmp    $0x1,%ecx
f01012cb:	7f 1e                	jg     f01012eb <.L23+0x29>
	else if (lflag)
f01012cd:	85 c9                	test   %ecx,%ecx
f01012cf:	74 32                	je     f0101303 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f01012d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d4:	8b 08                	mov    (%eax),%ecx
f01012d6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012db:	8d 40 04             	lea    0x4(%eax),%eax
f01012de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012e1:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f01012e6:	e9 ac 00 00 00       	jmp    f0101397 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01012eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ee:	8b 08                	mov    (%eax),%ecx
f01012f0:	8b 58 04             	mov    0x4(%eax),%ebx
f01012f3:	8d 40 08             	lea    0x8(%eax),%eax
f01012f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012f9:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f01012fe:	e9 94 00 00 00       	jmp    f0101397 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101303:	8b 45 14             	mov    0x14(%ebp),%eax
f0101306:	8b 08                	mov    (%eax),%ecx
f0101308:	bb 00 00 00 00       	mov    $0x0,%ebx
f010130d:	8d 40 04             	lea    0x4(%eax),%eax
f0101310:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101313:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0101318:	eb 7d                	jmp    f0101397 <.L25+0x2b>

f010131a <.L26>:
	if (lflag >= 2)
f010131a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010131d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101320:	83 f9 01             	cmp    $0x1,%ecx
f0101323:	7f 1b                	jg     f0101340 <.L26+0x26>
	else if (lflag)
f0101325:	85 c9                	test   %ecx,%ecx
f0101327:	74 2c                	je     f0101355 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f0101329:	8b 45 14             	mov    0x14(%ebp),%eax
f010132c:	8b 08                	mov    (%eax),%ecx
f010132e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101333:	8d 40 04             	lea    0x4(%eax),%eax
f0101336:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101339:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f010133e:	eb 57                	jmp    f0101397 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101340:	8b 45 14             	mov    0x14(%ebp),%eax
f0101343:	8b 08                	mov    (%eax),%ecx
f0101345:	8b 58 04             	mov    0x4(%eax),%ebx
f0101348:	8d 40 08             	lea    0x8(%eax),%eax
f010134b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010134e:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f0101353:	eb 42                	jmp    f0101397 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101355:	8b 45 14             	mov    0x14(%ebp),%eax
f0101358:	8b 08                	mov    (%eax),%ecx
f010135a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010135f:	8d 40 04             	lea    0x4(%eax),%eax
f0101362:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101365:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f010136a:	eb 2b                	jmp    f0101397 <.L25+0x2b>

f010136c <.L25>:
			putch('0', putdat);
f010136c:	8b 75 08             	mov    0x8(%ebp),%esi
f010136f:	83 ec 08             	sub    $0x8,%esp
f0101372:	57                   	push   %edi
f0101373:	6a 30                	push   $0x30
f0101375:	ff d6                	call   *%esi
			putch('x', putdat);
f0101377:	83 c4 08             	add    $0x8,%esp
f010137a:	57                   	push   %edi
f010137b:	6a 78                	push   $0x78
f010137d:	ff d6                	call   *%esi
			num = (unsigned long long)
f010137f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101382:	8b 08                	mov    (%eax),%ecx
f0101384:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0101389:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010138c:	8d 40 04             	lea    0x4(%eax),%eax
f010138f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101392:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0101397:	83 ec 0c             	sub    $0xc,%esp
f010139a:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010139e:	50                   	push   %eax
f010139f:	ff 75 d4             	push   -0x2c(%ebp)
f01013a2:	52                   	push   %edx
f01013a3:	53                   	push   %ebx
f01013a4:	51                   	push   %ecx
f01013a5:	89 fa                	mov    %edi,%edx
f01013a7:	89 f0                	mov    %esi,%eax
f01013a9:	e8 f4 fa ff ff       	call   f0100ea2 <printnum>
			break;
f01013ae:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01013b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013b4:	e9 15 fc ff ff       	jmp    f0100fce <vprintfmt+0x34>

f01013b9 <.L21>:
	if (lflag >= 2)
f01013b9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01013bc:	8b 75 08             	mov    0x8(%ebp),%esi
f01013bf:	83 f9 01             	cmp    $0x1,%ecx
f01013c2:	7f 1b                	jg     f01013df <.L21+0x26>
	else if (lflag)
f01013c4:	85 c9                	test   %ecx,%ecx
f01013c6:	74 2c                	je     f01013f4 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f01013c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01013cb:	8b 08                	mov    (%eax),%ecx
f01013cd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013d2:	8d 40 04             	lea    0x4(%eax),%eax
f01013d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013d8:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f01013dd:	eb b8                	jmp    f0101397 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01013df:	8b 45 14             	mov    0x14(%ebp),%eax
f01013e2:	8b 08                	mov    (%eax),%ecx
f01013e4:	8b 58 04             	mov    0x4(%eax),%ebx
f01013e7:	8d 40 08             	lea    0x8(%eax),%eax
f01013ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013ed:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f01013f2:	eb a3                	jmp    f0101397 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01013f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01013f7:	8b 08                	mov    (%eax),%ecx
f01013f9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013fe:	8d 40 04             	lea    0x4(%eax),%eax
f0101401:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101404:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0101409:	eb 8c                	jmp    f0101397 <.L25+0x2b>

f010140b <.L35>:
			putch(ch, putdat);
f010140b:	8b 75 08             	mov    0x8(%ebp),%esi
f010140e:	83 ec 08             	sub    $0x8,%esp
f0101411:	57                   	push   %edi
f0101412:	6a 25                	push   $0x25
f0101414:	ff d6                	call   *%esi
			break;
f0101416:	83 c4 10             	add    $0x10,%esp
f0101419:	eb 96                	jmp    f01013b1 <.L25+0x45>

f010141b <.L20>:
			putch('%', putdat);
f010141b:	8b 75 08             	mov    0x8(%ebp),%esi
f010141e:	83 ec 08             	sub    $0x8,%esp
f0101421:	57                   	push   %edi
f0101422:	6a 25                	push   $0x25
f0101424:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101426:	83 c4 10             	add    $0x10,%esp
f0101429:	89 d8                	mov    %ebx,%eax
f010142b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010142f:	74 05                	je     f0101436 <.L20+0x1b>
f0101431:	83 e8 01             	sub    $0x1,%eax
f0101434:	eb f5                	jmp    f010142b <.L20+0x10>
f0101436:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101439:	e9 73 ff ff ff       	jmp    f01013b1 <.L25+0x45>

f010143e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010143e:	55                   	push   %ebp
f010143f:	89 e5                	mov    %esp,%ebp
f0101441:	53                   	push   %ebx
f0101442:	83 ec 14             	sub    $0x14,%esp
f0101445:	e8 72 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010144a:	81 c3 be fe 00 00    	add    $0xfebe,%ebx
f0101450:	8b 45 08             	mov    0x8(%ebp),%eax
f0101453:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101456:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101459:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010145d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101460:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101467:	85 c0                	test   %eax,%eax
f0101469:	74 2b                	je     f0101496 <vsnprintf+0x58>
f010146b:	85 d2                	test   %edx,%edx
f010146d:	7e 27                	jle    f0101496 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010146f:	ff 75 14             	push   0x14(%ebp)
f0101472:	ff 75 10             	push   0x10(%ebp)
f0101475:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101478:	50                   	push   %eax
f0101479:	8d 83 58 fc fe ff    	lea    -0x103a8(%ebx),%eax
f010147f:	50                   	push   %eax
f0101480:	e8 15 fb ff ff       	call   f0100f9a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101485:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101488:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010148b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010148e:	83 c4 10             	add    $0x10,%esp
}
f0101491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101494:	c9                   	leave  
f0101495:	c3                   	ret    
		return -E_INVAL;
f0101496:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010149b:	eb f4                	jmp    f0101491 <vsnprintf+0x53>

f010149d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010149d:	55                   	push   %ebp
f010149e:	89 e5                	mov    %esp,%ebp
f01014a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014a6:	50                   	push   %eax
f01014a7:	ff 75 10             	push   0x10(%ebp)
f01014aa:	ff 75 0c             	push   0xc(%ebp)
f01014ad:	ff 75 08             	push   0x8(%ebp)
f01014b0:	e8 89 ff ff ff       	call   f010143e <vsnprintf>
	va_end(ap);

	return rc;
}
f01014b5:	c9                   	leave  
f01014b6:	c3                   	ret    

f01014b7 <__x86.get_pc_thunk.cx>:
f01014b7:	8b 0c 24             	mov    (%esp),%ecx
f01014ba:	c3                   	ret    

f01014bb <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014bb:	55                   	push   %ebp
f01014bc:	89 e5                	mov    %esp,%ebp
f01014be:	57                   	push   %edi
f01014bf:	56                   	push   %esi
f01014c0:	53                   	push   %ebx
f01014c1:	83 ec 1c             	sub    $0x1c,%esp
f01014c4:	e8 f3 ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01014c9:	81 c3 3f fe 00 00    	add    $0xfe3f,%ebx
f01014cf:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014d2:	85 c0                	test   %eax,%eax
f01014d4:	74 13                	je     f01014e9 <readline+0x2e>
		cprintf("%s", prompt);
f01014d6:	83 ec 08             	sub    $0x8,%esp
f01014d9:	50                   	push   %eax
f01014da:	8d 83 af 0d ff ff    	lea    -0xf251(%ebx),%eax
f01014e0:	50                   	push   %eax
f01014e1:	e8 6b f6 ff ff       	call   f0100b51 <cprintf>
f01014e6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01014e9:	83 ec 0c             	sub    $0xc,%esp
f01014ec:	6a 00                	push   $0x0
f01014ee:	e8 55 f2 ff ff       	call   f0100748 <iscons>
f01014f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014f6:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01014f9:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f01014fe:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0101504:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101507:	eb 45                	jmp    f010154e <readline+0x93>
			cprintf("read error: %e\n", c);
f0101509:	83 ec 08             	sub    $0x8,%esp
f010150c:	50                   	push   %eax
f010150d:	8d 83 74 0f ff ff    	lea    -0xf08c(%ebx),%eax
f0101513:	50                   	push   %eax
f0101514:	e8 38 f6 ff ff       	call   f0100b51 <cprintf>
			return NULL;
f0101519:	83 c4 10             	add    $0x10,%esp
f010151c:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101521:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101524:	5b                   	pop    %ebx
f0101525:	5e                   	pop    %esi
f0101526:	5f                   	pop    %edi
f0101527:	5d                   	pop    %ebp
f0101528:	c3                   	ret    
			if (echoing)
f0101529:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010152d:	75 05                	jne    f0101534 <readline+0x79>
			i--;
f010152f:	83 ef 01             	sub    $0x1,%edi
f0101532:	eb 1a                	jmp    f010154e <readline+0x93>
				cputchar('\b');
f0101534:	83 ec 0c             	sub    $0xc,%esp
f0101537:	6a 08                	push   $0x8
f0101539:	e8 e9 f1 ff ff       	call   f0100727 <cputchar>
f010153e:	83 c4 10             	add    $0x10,%esp
f0101541:	eb ec                	jmp    f010152f <readline+0x74>
			buf[i++] = c;
f0101543:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101546:	89 f0                	mov    %esi,%eax
f0101548:	88 04 39             	mov    %al,(%ecx,%edi,1)
f010154b:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010154e:	e8 e4 f1 ff ff       	call   f0100737 <getchar>
f0101553:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101555:	85 c0                	test   %eax,%eax
f0101557:	78 b0                	js     f0101509 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101559:	83 f8 08             	cmp    $0x8,%eax
f010155c:	0f 94 c0             	sete   %al
f010155f:	83 fe 7f             	cmp    $0x7f,%esi
f0101562:	0f 94 c2             	sete   %dl
f0101565:	08 d0                	or     %dl,%al
f0101567:	74 04                	je     f010156d <readline+0xb2>
f0101569:	85 ff                	test   %edi,%edi
f010156b:	7f bc                	jg     f0101529 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010156d:	83 fe 1f             	cmp    $0x1f,%esi
f0101570:	7e 1c                	jle    f010158e <readline+0xd3>
f0101572:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101578:	7f 14                	jg     f010158e <readline+0xd3>
			if (echoing)
f010157a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010157e:	74 c3                	je     f0101543 <readline+0x88>
				cputchar(c);
f0101580:	83 ec 0c             	sub    $0xc,%esp
f0101583:	56                   	push   %esi
f0101584:	e8 9e f1 ff ff       	call   f0100727 <cputchar>
f0101589:	83 c4 10             	add    $0x10,%esp
f010158c:	eb b5                	jmp    f0101543 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f010158e:	83 fe 0a             	cmp    $0xa,%esi
f0101591:	74 05                	je     f0101598 <readline+0xdd>
f0101593:	83 fe 0d             	cmp    $0xd,%esi
f0101596:	75 b6                	jne    f010154e <readline+0x93>
			if (echoing)
f0101598:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010159c:	75 13                	jne    f01015b1 <readline+0xf6>
			buf[i] = 0;
f010159e:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f01015a5:	00 
			return buf;
f01015a6:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f01015ac:	e9 70 ff ff ff       	jmp    f0101521 <readline+0x66>
				cputchar('\n');
f01015b1:	83 ec 0c             	sub    $0xc,%esp
f01015b4:	6a 0a                	push   $0xa
f01015b6:	e8 6c f1 ff ff       	call   f0100727 <cputchar>
f01015bb:	83 c4 10             	add    $0x10,%esp
f01015be:	eb de                	jmp    f010159e <readline+0xe3>

f01015c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015c0:	55                   	push   %ebp
f01015c1:	89 e5                	mov    %esp,%ebp
f01015c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01015cb:	eb 03                	jmp    f01015d0 <strlen+0x10>
		n++;
f01015cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01015d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015d4:	75 f7                	jne    f01015cd <strlen+0xd>
	return n;
}
f01015d6:	5d                   	pop    %ebp
f01015d7:	c3                   	ret    

f01015d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015d8:	55                   	push   %ebp
f01015d9:	89 e5                	mov    %esp,%ebp
f01015db:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01015e6:	eb 03                	jmp    f01015eb <strnlen+0x13>
		n++;
f01015e8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015eb:	39 d0                	cmp    %edx,%eax
f01015ed:	74 08                	je     f01015f7 <strnlen+0x1f>
f01015ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01015f3:	75 f3                	jne    f01015e8 <strnlen+0x10>
f01015f5:	89 c2                	mov    %eax,%edx
	return n;
}
f01015f7:	89 d0                	mov    %edx,%eax
f01015f9:	5d                   	pop    %ebp
f01015fa:	c3                   	ret    

f01015fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015fb:	55                   	push   %ebp
f01015fc:	89 e5                	mov    %esp,%ebp
f01015fe:	53                   	push   %ebx
f01015ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101605:	b8 00 00 00 00       	mov    $0x0,%eax
f010160a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f010160e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0101611:	83 c0 01             	add    $0x1,%eax
f0101614:	84 d2                	test   %dl,%dl
f0101616:	75 f2                	jne    f010160a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101618:	89 c8                	mov    %ecx,%eax
f010161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010161d:	c9                   	leave  
f010161e:	c3                   	ret    

f010161f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010161f:	55                   	push   %ebp
f0101620:	89 e5                	mov    %esp,%ebp
f0101622:	53                   	push   %ebx
f0101623:	83 ec 10             	sub    $0x10,%esp
f0101626:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101629:	53                   	push   %ebx
f010162a:	e8 91 ff ff ff       	call   f01015c0 <strlen>
f010162f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0101632:	ff 75 0c             	push   0xc(%ebp)
f0101635:	01 d8                	add    %ebx,%eax
f0101637:	50                   	push   %eax
f0101638:	e8 be ff ff ff       	call   f01015fb <strcpy>
	return dst;
}
f010163d:	89 d8                	mov    %ebx,%eax
f010163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101642:	c9                   	leave  
f0101643:	c3                   	ret    

f0101644 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101644:	55                   	push   %ebp
f0101645:	89 e5                	mov    %esp,%ebp
f0101647:	56                   	push   %esi
f0101648:	53                   	push   %ebx
f0101649:	8b 75 08             	mov    0x8(%ebp),%esi
f010164c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010164f:	89 f3                	mov    %esi,%ebx
f0101651:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101654:	89 f0                	mov    %esi,%eax
f0101656:	eb 0f                	jmp    f0101667 <strncpy+0x23>
		*dst++ = *src;
f0101658:	83 c0 01             	add    $0x1,%eax
f010165b:	0f b6 0a             	movzbl (%edx),%ecx
f010165e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101661:	80 f9 01             	cmp    $0x1,%cl
f0101664:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0101667:	39 d8                	cmp    %ebx,%eax
f0101669:	75 ed                	jne    f0101658 <strncpy+0x14>
	}
	return ret;
}
f010166b:	89 f0                	mov    %esi,%eax
f010166d:	5b                   	pop    %ebx
f010166e:	5e                   	pop    %esi
f010166f:	5d                   	pop    %ebp
f0101670:	c3                   	ret    

f0101671 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101671:	55                   	push   %ebp
f0101672:	89 e5                	mov    %esp,%ebp
f0101674:	56                   	push   %esi
f0101675:	53                   	push   %ebx
f0101676:	8b 75 08             	mov    0x8(%ebp),%esi
f0101679:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010167c:	8b 55 10             	mov    0x10(%ebp),%edx
f010167f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101681:	85 d2                	test   %edx,%edx
f0101683:	74 21                	je     f01016a6 <strlcpy+0x35>
f0101685:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101689:	89 f2                	mov    %esi,%edx
f010168b:	eb 09                	jmp    f0101696 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010168d:	83 c1 01             	add    $0x1,%ecx
f0101690:	83 c2 01             	add    $0x1,%edx
f0101693:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0101696:	39 c2                	cmp    %eax,%edx
f0101698:	74 09                	je     f01016a3 <strlcpy+0x32>
f010169a:	0f b6 19             	movzbl (%ecx),%ebx
f010169d:	84 db                	test   %bl,%bl
f010169f:	75 ec                	jne    f010168d <strlcpy+0x1c>
f01016a1:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01016a3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01016a6:	29 f0                	sub    %esi,%eax
}
f01016a8:	5b                   	pop    %ebx
f01016a9:	5e                   	pop    %esi
f01016aa:	5d                   	pop    %ebp
f01016ab:	c3                   	ret    

f01016ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01016ac:	55                   	push   %ebp
f01016ad:	89 e5                	mov    %esp,%ebp
f01016af:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016b5:	eb 06                	jmp    f01016bd <strcmp+0x11>
		p++, q++;
f01016b7:	83 c1 01             	add    $0x1,%ecx
f01016ba:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01016bd:	0f b6 01             	movzbl (%ecx),%eax
f01016c0:	84 c0                	test   %al,%al
f01016c2:	74 04                	je     f01016c8 <strcmp+0x1c>
f01016c4:	3a 02                	cmp    (%edx),%al
f01016c6:	74 ef                	je     f01016b7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016c8:	0f b6 c0             	movzbl %al,%eax
f01016cb:	0f b6 12             	movzbl (%edx),%edx
f01016ce:	29 d0                	sub    %edx,%eax
}
f01016d0:	5d                   	pop    %ebp
f01016d1:	c3                   	ret    

f01016d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016d2:	55                   	push   %ebp
f01016d3:	89 e5                	mov    %esp,%ebp
f01016d5:	53                   	push   %ebx
f01016d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016dc:	89 c3                	mov    %eax,%ebx
f01016de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016e1:	eb 06                	jmp    f01016e9 <strncmp+0x17>
		n--, p++, q++;
f01016e3:	83 c0 01             	add    $0x1,%eax
f01016e6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016e9:	39 d8                	cmp    %ebx,%eax
f01016eb:	74 18                	je     f0101705 <strncmp+0x33>
f01016ed:	0f b6 08             	movzbl (%eax),%ecx
f01016f0:	84 c9                	test   %cl,%cl
f01016f2:	74 04                	je     f01016f8 <strncmp+0x26>
f01016f4:	3a 0a                	cmp    (%edx),%cl
f01016f6:	74 eb                	je     f01016e3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016f8:	0f b6 00             	movzbl (%eax),%eax
f01016fb:	0f b6 12             	movzbl (%edx),%edx
f01016fe:	29 d0                	sub    %edx,%eax
}
f0101700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101703:	c9                   	leave  
f0101704:	c3                   	ret    
		return 0;
f0101705:	b8 00 00 00 00       	mov    $0x0,%eax
f010170a:	eb f4                	jmp    f0101700 <strncmp+0x2e>

f010170c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010170c:	55                   	push   %ebp
f010170d:	89 e5                	mov    %esp,%ebp
f010170f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101712:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101716:	eb 03                	jmp    f010171b <strchr+0xf>
f0101718:	83 c0 01             	add    $0x1,%eax
f010171b:	0f b6 10             	movzbl (%eax),%edx
f010171e:	84 d2                	test   %dl,%dl
f0101720:	74 06                	je     f0101728 <strchr+0x1c>
		if (*s == c)
f0101722:	38 ca                	cmp    %cl,%dl
f0101724:	75 f2                	jne    f0101718 <strchr+0xc>
f0101726:	eb 05                	jmp    f010172d <strchr+0x21>
			return (char *) s;
	return 0;
f0101728:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010172d:	5d                   	pop    %ebp
f010172e:	c3                   	ret    

f010172f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010172f:	55                   	push   %ebp
f0101730:	89 e5                	mov    %esp,%ebp
f0101732:	8b 45 08             	mov    0x8(%ebp),%eax
f0101735:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101739:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010173c:	38 ca                	cmp    %cl,%dl
f010173e:	74 09                	je     f0101749 <strfind+0x1a>
f0101740:	84 d2                	test   %dl,%dl
f0101742:	74 05                	je     f0101749 <strfind+0x1a>
	for (; *s; s++)
f0101744:	83 c0 01             	add    $0x1,%eax
f0101747:	eb f0                	jmp    f0101739 <strfind+0xa>
			break;
	return (char *) s;
}
f0101749:	5d                   	pop    %ebp
f010174a:	c3                   	ret    

f010174b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010174b:	55                   	push   %ebp
f010174c:	89 e5                	mov    %esp,%ebp
f010174e:	57                   	push   %edi
f010174f:	56                   	push   %esi
f0101750:	53                   	push   %ebx
f0101751:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101754:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101757:	85 c9                	test   %ecx,%ecx
f0101759:	74 2f                	je     f010178a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010175b:	89 f8                	mov    %edi,%eax
f010175d:	09 c8                	or     %ecx,%eax
f010175f:	a8 03                	test   $0x3,%al
f0101761:	75 21                	jne    f0101784 <memset+0x39>
		c &= 0xFF;
f0101763:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101767:	89 d0                	mov    %edx,%eax
f0101769:	c1 e0 08             	shl    $0x8,%eax
f010176c:	89 d3                	mov    %edx,%ebx
f010176e:	c1 e3 18             	shl    $0x18,%ebx
f0101771:	89 d6                	mov    %edx,%esi
f0101773:	c1 e6 10             	shl    $0x10,%esi
f0101776:	09 f3                	or     %esi,%ebx
f0101778:	09 da                	or     %ebx,%edx
f010177a:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010177c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010177f:	fc                   	cld    
f0101780:	f3 ab                	rep stos %eax,%es:(%edi)
f0101782:	eb 06                	jmp    f010178a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101784:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101787:	fc                   	cld    
f0101788:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010178a:	89 f8                	mov    %edi,%eax
f010178c:	5b                   	pop    %ebx
f010178d:	5e                   	pop    %esi
f010178e:	5f                   	pop    %edi
f010178f:	5d                   	pop    %ebp
f0101790:	c3                   	ret    

f0101791 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101791:	55                   	push   %ebp
f0101792:	89 e5                	mov    %esp,%ebp
f0101794:	57                   	push   %edi
f0101795:	56                   	push   %esi
f0101796:	8b 45 08             	mov    0x8(%ebp),%eax
f0101799:	8b 75 0c             	mov    0xc(%ebp),%esi
f010179c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010179f:	39 c6                	cmp    %eax,%esi
f01017a1:	73 32                	jae    f01017d5 <memmove+0x44>
f01017a3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01017a6:	39 c2                	cmp    %eax,%edx
f01017a8:	76 2b                	jbe    f01017d5 <memmove+0x44>
		s += n;
		d += n;
f01017aa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017ad:	89 d6                	mov    %edx,%esi
f01017af:	09 fe                	or     %edi,%esi
f01017b1:	09 ce                	or     %ecx,%esi
f01017b3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017b9:	75 0e                	jne    f01017c9 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017bb:	83 ef 04             	sub    $0x4,%edi
f01017be:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01017c4:	fd                   	std    
f01017c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017c7:	eb 09                	jmp    f01017d2 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017c9:	83 ef 01             	sub    $0x1,%edi
f01017cc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01017cf:	fd                   	std    
f01017d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017d2:	fc                   	cld    
f01017d3:	eb 1a                	jmp    f01017ef <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017d5:	89 f2                	mov    %esi,%edx
f01017d7:	09 c2                	or     %eax,%edx
f01017d9:	09 ca                	or     %ecx,%edx
f01017db:	f6 c2 03             	test   $0x3,%dl
f01017de:	75 0a                	jne    f01017ea <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017e0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01017e3:	89 c7                	mov    %eax,%edi
f01017e5:	fc                   	cld    
f01017e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017e8:	eb 05                	jmp    f01017ef <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01017ea:	89 c7                	mov    %eax,%edi
f01017ec:	fc                   	cld    
f01017ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017ef:	5e                   	pop    %esi
f01017f0:	5f                   	pop    %edi
f01017f1:	5d                   	pop    %ebp
f01017f2:	c3                   	ret    

f01017f3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01017f3:	55                   	push   %ebp
f01017f4:	89 e5                	mov    %esp,%ebp
f01017f6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01017f9:	ff 75 10             	push   0x10(%ebp)
f01017fc:	ff 75 0c             	push   0xc(%ebp)
f01017ff:	ff 75 08             	push   0x8(%ebp)
f0101802:	e8 8a ff ff ff       	call   f0101791 <memmove>
}
f0101807:	c9                   	leave  
f0101808:	c3                   	ret    

f0101809 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101809:	55                   	push   %ebp
f010180a:	89 e5                	mov    %esp,%ebp
f010180c:	56                   	push   %esi
f010180d:	53                   	push   %ebx
f010180e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101811:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101814:	89 c6                	mov    %eax,%esi
f0101816:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101819:	eb 06                	jmp    f0101821 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010181b:	83 c0 01             	add    $0x1,%eax
f010181e:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0101821:	39 f0                	cmp    %esi,%eax
f0101823:	74 14                	je     f0101839 <memcmp+0x30>
		if (*s1 != *s2)
f0101825:	0f b6 08             	movzbl (%eax),%ecx
f0101828:	0f b6 1a             	movzbl (%edx),%ebx
f010182b:	38 d9                	cmp    %bl,%cl
f010182d:	74 ec                	je     f010181b <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f010182f:	0f b6 c1             	movzbl %cl,%eax
f0101832:	0f b6 db             	movzbl %bl,%ebx
f0101835:	29 d8                	sub    %ebx,%eax
f0101837:	eb 05                	jmp    f010183e <memcmp+0x35>
	}

	return 0;
f0101839:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010183e:	5b                   	pop    %ebx
f010183f:	5e                   	pop    %esi
f0101840:	5d                   	pop    %ebp
f0101841:	c3                   	ret    

f0101842 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101842:	55                   	push   %ebp
f0101843:	89 e5                	mov    %esp,%ebp
f0101845:	8b 45 08             	mov    0x8(%ebp),%eax
f0101848:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010184b:	89 c2                	mov    %eax,%edx
f010184d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101850:	eb 03                	jmp    f0101855 <memfind+0x13>
f0101852:	83 c0 01             	add    $0x1,%eax
f0101855:	39 d0                	cmp    %edx,%eax
f0101857:	73 04                	jae    f010185d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101859:	38 08                	cmp    %cl,(%eax)
f010185b:	75 f5                	jne    f0101852 <memfind+0x10>
			break;
	return (void *) s;
}
f010185d:	5d                   	pop    %ebp
f010185e:	c3                   	ret    

f010185f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010185f:	55                   	push   %ebp
f0101860:	89 e5                	mov    %esp,%ebp
f0101862:	57                   	push   %edi
f0101863:	56                   	push   %esi
f0101864:	53                   	push   %ebx
f0101865:	8b 55 08             	mov    0x8(%ebp),%edx
f0101868:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010186b:	eb 03                	jmp    f0101870 <strtol+0x11>
		s++;
f010186d:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0101870:	0f b6 02             	movzbl (%edx),%eax
f0101873:	3c 20                	cmp    $0x20,%al
f0101875:	74 f6                	je     f010186d <strtol+0xe>
f0101877:	3c 09                	cmp    $0x9,%al
f0101879:	74 f2                	je     f010186d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010187b:	3c 2b                	cmp    $0x2b,%al
f010187d:	74 2a                	je     f01018a9 <strtol+0x4a>
	int neg = 0;
f010187f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101884:	3c 2d                	cmp    $0x2d,%al
f0101886:	74 2b                	je     f01018b3 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101888:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010188e:	75 0f                	jne    f010189f <strtol+0x40>
f0101890:	80 3a 30             	cmpb   $0x30,(%edx)
f0101893:	74 28                	je     f01018bd <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101895:	85 db                	test   %ebx,%ebx
f0101897:	b8 0a 00 00 00       	mov    $0xa,%eax
f010189c:	0f 44 d8             	cmove  %eax,%ebx
f010189f:	b9 00 00 00 00       	mov    $0x0,%ecx
f01018a4:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01018a7:	eb 46                	jmp    f01018ef <strtol+0x90>
		s++;
f01018a9:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f01018ac:	bf 00 00 00 00       	mov    $0x0,%edi
f01018b1:	eb d5                	jmp    f0101888 <strtol+0x29>
		s++, neg = 1;
f01018b3:	83 c2 01             	add    $0x1,%edx
f01018b6:	bf 01 00 00 00       	mov    $0x1,%edi
f01018bb:	eb cb                	jmp    f0101888 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018bd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01018c1:	74 0e                	je     f01018d1 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f01018c3:	85 db                	test   %ebx,%ebx
f01018c5:	75 d8                	jne    f010189f <strtol+0x40>
		s++, base = 8;
f01018c7:	83 c2 01             	add    $0x1,%edx
f01018ca:	bb 08 00 00 00       	mov    $0x8,%ebx
f01018cf:	eb ce                	jmp    f010189f <strtol+0x40>
		s += 2, base = 16;
f01018d1:	83 c2 02             	add    $0x2,%edx
f01018d4:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018d9:	eb c4                	jmp    f010189f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01018db:	0f be c0             	movsbl %al,%eax
f01018de:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018e1:	3b 45 10             	cmp    0x10(%ebp),%eax
f01018e4:	7d 3a                	jge    f0101920 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01018e6:	83 c2 01             	add    $0x1,%edx
f01018e9:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f01018ed:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f01018ef:	0f b6 02             	movzbl (%edx),%eax
f01018f2:	8d 70 d0             	lea    -0x30(%eax),%esi
f01018f5:	89 f3                	mov    %esi,%ebx
f01018f7:	80 fb 09             	cmp    $0x9,%bl
f01018fa:	76 df                	jbe    f01018db <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f01018fc:	8d 70 9f             	lea    -0x61(%eax),%esi
f01018ff:	89 f3                	mov    %esi,%ebx
f0101901:	80 fb 19             	cmp    $0x19,%bl
f0101904:	77 08                	ja     f010190e <strtol+0xaf>
			dig = *s - 'a' + 10;
f0101906:	0f be c0             	movsbl %al,%eax
f0101909:	83 e8 57             	sub    $0x57,%eax
f010190c:	eb d3                	jmp    f01018e1 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f010190e:	8d 70 bf             	lea    -0x41(%eax),%esi
f0101911:	89 f3                	mov    %esi,%ebx
f0101913:	80 fb 19             	cmp    $0x19,%bl
f0101916:	77 08                	ja     f0101920 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0101918:	0f be c0             	movsbl %al,%eax
f010191b:	83 e8 37             	sub    $0x37,%eax
f010191e:	eb c1                	jmp    f01018e1 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101920:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101924:	74 05                	je     f010192b <strtol+0xcc>
		*endptr = (char *) s;
f0101926:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101929:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f010192b:	89 c8                	mov    %ecx,%eax
f010192d:	f7 d8                	neg    %eax
f010192f:	85 ff                	test   %edi,%edi
f0101931:	0f 45 c8             	cmovne %eax,%ecx
}
f0101934:	89 c8                	mov    %ecx,%eax
f0101936:	5b                   	pop    %ebx
f0101937:	5e                   	pop    %esi
f0101938:	5f                   	pop    %edi
f0101939:	5d                   	pop    %ebp
f010193a:	c3                   	ret    
f010193b:	66 90                	xchg   %ax,%ax
f010193d:	66 90                	xchg   %ax,%ax
f010193f:	90                   	nop

f0101940 <__udivdi3>:
f0101940:	f3 0f 1e fb          	endbr32 
f0101944:	55                   	push   %ebp
f0101945:	57                   	push   %edi
f0101946:	56                   	push   %esi
f0101947:	53                   	push   %ebx
f0101948:	83 ec 1c             	sub    $0x1c,%esp
f010194b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010194f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101953:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101957:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010195b:	85 c0                	test   %eax,%eax
f010195d:	75 19                	jne    f0101978 <__udivdi3+0x38>
f010195f:	39 f3                	cmp    %esi,%ebx
f0101961:	76 4d                	jbe    f01019b0 <__udivdi3+0x70>
f0101963:	31 ff                	xor    %edi,%edi
f0101965:	89 e8                	mov    %ebp,%eax
f0101967:	89 f2                	mov    %esi,%edx
f0101969:	f7 f3                	div    %ebx
f010196b:	89 fa                	mov    %edi,%edx
f010196d:	83 c4 1c             	add    $0x1c,%esp
f0101970:	5b                   	pop    %ebx
f0101971:	5e                   	pop    %esi
f0101972:	5f                   	pop    %edi
f0101973:	5d                   	pop    %ebp
f0101974:	c3                   	ret    
f0101975:	8d 76 00             	lea    0x0(%esi),%esi
f0101978:	39 f0                	cmp    %esi,%eax
f010197a:	76 14                	jbe    f0101990 <__udivdi3+0x50>
f010197c:	31 ff                	xor    %edi,%edi
f010197e:	31 c0                	xor    %eax,%eax
f0101980:	89 fa                	mov    %edi,%edx
f0101982:	83 c4 1c             	add    $0x1c,%esp
f0101985:	5b                   	pop    %ebx
f0101986:	5e                   	pop    %esi
f0101987:	5f                   	pop    %edi
f0101988:	5d                   	pop    %ebp
f0101989:	c3                   	ret    
f010198a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101990:	0f bd f8             	bsr    %eax,%edi
f0101993:	83 f7 1f             	xor    $0x1f,%edi
f0101996:	75 48                	jne    f01019e0 <__udivdi3+0xa0>
f0101998:	39 f0                	cmp    %esi,%eax
f010199a:	72 06                	jb     f01019a2 <__udivdi3+0x62>
f010199c:	31 c0                	xor    %eax,%eax
f010199e:	39 eb                	cmp    %ebp,%ebx
f01019a0:	77 de                	ja     f0101980 <__udivdi3+0x40>
f01019a2:	b8 01 00 00 00       	mov    $0x1,%eax
f01019a7:	eb d7                	jmp    f0101980 <__udivdi3+0x40>
f01019a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01019b0:	89 d9                	mov    %ebx,%ecx
f01019b2:	85 db                	test   %ebx,%ebx
f01019b4:	75 0b                	jne    f01019c1 <__udivdi3+0x81>
f01019b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01019bb:	31 d2                	xor    %edx,%edx
f01019bd:	f7 f3                	div    %ebx
f01019bf:	89 c1                	mov    %eax,%ecx
f01019c1:	31 d2                	xor    %edx,%edx
f01019c3:	89 f0                	mov    %esi,%eax
f01019c5:	f7 f1                	div    %ecx
f01019c7:	89 c6                	mov    %eax,%esi
f01019c9:	89 e8                	mov    %ebp,%eax
f01019cb:	89 f7                	mov    %esi,%edi
f01019cd:	f7 f1                	div    %ecx
f01019cf:	89 fa                	mov    %edi,%edx
f01019d1:	83 c4 1c             	add    $0x1c,%esp
f01019d4:	5b                   	pop    %ebx
f01019d5:	5e                   	pop    %esi
f01019d6:	5f                   	pop    %edi
f01019d7:	5d                   	pop    %ebp
f01019d8:	c3                   	ret    
f01019d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01019e0:	89 f9                	mov    %edi,%ecx
f01019e2:	ba 20 00 00 00       	mov    $0x20,%edx
f01019e7:	29 fa                	sub    %edi,%edx
f01019e9:	d3 e0                	shl    %cl,%eax
f01019eb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019ef:	89 d1                	mov    %edx,%ecx
f01019f1:	89 d8                	mov    %ebx,%eax
f01019f3:	d3 e8                	shr    %cl,%eax
f01019f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01019f9:	09 c1                	or     %eax,%ecx
f01019fb:	89 f0                	mov    %esi,%eax
f01019fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a01:	89 f9                	mov    %edi,%ecx
f0101a03:	d3 e3                	shl    %cl,%ebx
f0101a05:	89 d1                	mov    %edx,%ecx
f0101a07:	d3 e8                	shr    %cl,%eax
f0101a09:	89 f9                	mov    %edi,%ecx
f0101a0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101a0f:	89 eb                	mov    %ebp,%ebx
f0101a11:	d3 e6                	shl    %cl,%esi
f0101a13:	89 d1                	mov    %edx,%ecx
f0101a15:	d3 eb                	shr    %cl,%ebx
f0101a17:	09 f3                	or     %esi,%ebx
f0101a19:	89 c6                	mov    %eax,%esi
f0101a1b:	89 f2                	mov    %esi,%edx
f0101a1d:	89 d8                	mov    %ebx,%eax
f0101a1f:	f7 74 24 08          	divl   0x8(%esp)
f0101a23:	89 d6                	mov    %edx,%esi
f0101a25:	89 c3                	mov    %eax,%ebx
f0101a27:	f7 64 24 0c          	mull   0xc(%esp)
f0101a2b:	39 d6                	cmp    %edx,%esi
f0101a2d:	72 19                	jb     f0101a48 <__udivdi3+0x108>
f0101a2f:	89 f9                	mov    %edi,%ecx
f0101a31:	d3 e5                	shl    %cl,%ebp
f0101a33:	39 c5                	cmp    %eax,%ebp
f0101a35:	73 04                	jae    f0101a3b <__udivdi3+0xfb>
f0101a37:	39 d6                	cmp    %edx,%esi
f0101a39:	74 0d                	je     f0101a48 <__udivdi3+0x108>
f0101a3b:	89 d8                	mov    %ebx,%eax
f0101a3d:	31 ff                	xor    %edi,%edi
f0101a3f:	e9 3c ff ff ff       	jmp    f0101980 <__udivdi3+0x40>
f0101a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a48:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101a4b:	31 ff                	xor    %edi,%edi
f0101a4d:	e9 2e ff ff ff       	jmp    f0101980 <__udivdi3+0x40>
f0101a52:	66 90                	xchg   %ax,%ax
f0101a54:	66 90                	xchg   %ax,%ax
f0101a56:	66 90                	xchg   %ax,%ax
f0101a58:	66 90                	xchg   %ax,%ax
f0101a5a:	66 90                	xchg   %ax,%ax
f0101a5c:	66 90                	xchg   %ax,%ax
f0101a5e:	66 90                	xchg   %ax,%ax

f0101a60 <__umoddi3>:
f0101a60:	f3 0f 1e fb          	endbr32 
f0101a64:	55                   	push   %ebp
f0101a65:	57                   	push   %edi
f0101a66:	56                   	push   %esi
f0101a67:	53                   	push   %ebx
f0101a68:	83 ec 1c             	sub    $0x1c,%esp
f0101a6b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a73:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0101a77:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0101a7b:	89 f0                	mov    %esi,%eax
f0101a7d:	89 da                	mov    %ebx,%edx
f0101a7f:	85 ff                	test   %edi,%edi
f0101a81:	75 15                	jne    f0101a98 <__umoddi3+0x38>
f0101a83:	39 dd                	cmp    %ebx,%ebp
f0101a85:	76 39                	jbe    f0101ac0 <__umoddi3+0x60>
f0101a87:	f7 f5                	div    %ebp
f0101a89:	89 d0                	mov    %edx,%eax
f0101a8b:	31 d2                	xor    %edx,%edx
f0101a8d:	83 c4 1c             	add    $0x1c,%esp
f0101a90:	5b                   	pop    %ebx
f0101a91:	5e                   	pop    %esi
f0101a92:	5f                   	pop    %edi
f0101a93:	5d                   	pop    %ebp
f0101a94:	c3                   	ret    
f0101a95:	8d 76 00             	lea    0x0(%esi),%esi
f0101a98:	39 df                	cmp    %ebx,%edi
f0101a9a:	77 f1                	ja     f0101a8d <__umoddi3+0x2d>
f0101a9c:	0f bd cf             	bsr    %edi,%ecx
f0101a9f:	83 f1 1f             	xor    $0x1f,%ecx
f0101aa2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101aa6:	75 40                	jne    f0101ae8 <__umoddi3+0x88>
f0101aa8:	39 df                	cmp    %ebx,%edi
f0101aaa:	72 04                	jb     f0101ab0 <__umoddi3+0x50>
f0101aac:	39 f5                	cmp    %esi,%ebp
f0101aae:	77 dd                	ja     f0101a8d <__umoddi3+0x2d>
f0101ab0:	89 da                	mov    %ebx,%edx
f0101ab2:	89 f0                	mov    %esi,%eax
f0101ab4:	29 e8                	sub    %ebp,%eax
f0101ab6:	19 fa                	sbb    %edi,%edx
f0101ab8:	eb d3                	jmp    f0101a8d <__umoddi3+0x2d>
f0101aba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101ac0:	89 e9                	mov    %ebp,%ecx
f0101ac2:	85 ed                	test   %ebp,%ebp
f0101ac4:	75 0b                	jne    f0101ad1 <__umoddi3+0x71>
f0101ac6:	b8 01 00 00 00       	mov    $0x1,%eax
f0101acb:	31 d2                	xor    %edx,%edx
f0101acd:	f7 f5                	div    %ebp
f0101acf:	89 c1                	mov    %eax,%ecx
f0101ad1:	89 d8                	mov    %ebx,%eax
f0101ad3:	31 d2                	xor    %edx,%edx
f0101ad5:	f7 f1                	div    %ecx
f0101ad7:	89 f0                	mov    %esi,%eax
f0101ad9:	f7 f1                	div    %ecx
f0101adb:	89 d0                	mov    %edx,%eax
f0101add:	31 d2                	xor    %edx,%edx
f0101adf:	eb ac                	jmp    f0101a8d <__umoddi3+0x2d>
f0101ae1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101ae8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101aec:	ba 20 00 00 00       	mov    $0x20,%edx
f0101af1:	29 c2                	sub    %eax,%edx
f0101af3:	89 c1                	mov    %eax,%ecx
f0101af5:	89 e8                	mov    %ebp,%eax
f0101af7:	d3 e7                	shl    %cl,%edi
f0101af9:	89 d1                	mov    %edx,%ecx
f0101afb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101aff:	d3 e8                	shr    %cl,%eax
f0101b01:	89 c1                	mov    %eax,%ecx
f0101b03:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101b07:	09 f9                	or     %edi,%ecx
f0101b09:	89 df                	mov    %ebx,%edi
f0101b0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101b0f:	89 c1                	mov    %eax,%ecx
f0101b11:	d3 e5                	shl    %cl,%ebp
f0101b13:	89 d1                	mov    %edx,%ecx
f0101b15:	d3 ef                	shr    %cl,%edi
f0101b17:	89 c1                	mov    %eax,%ecx
f0101b19:	89 f0                	mov    %esi,%eax
f0101b1b:	d3 e3                	shl    %cl,%ebx
f0101b1d:	89 d1                	mov    %edx,%ecx
f0101b1f:	89 fa                	mov    %edi,%edx
f0101b21:	d3 e8                	shr    %cl,%eax
f0101b23:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b28:	09 d8                	or     %ebx,%eax
f0101b2a:	f7 74 24 08          	divl   0x8(%esp)
f0101b2e:	89 d3                	mov    %edx,%ebx
f0101b30:	d3 e6                	shl    %cl,%esi
f0101b32:	f7 e5                	mul    %ebp
f0101b34:	89 c7                	mov    %eax,%edi
f0101b36:	89 d1                	mov    %edx,%ecx
f0101b38:	39 d3                	cmp    %edx,%ebx
f0101b3a:	72 06                	jb     f0101b42 <__umoddi3+0xe2>
f0101b3c:	75 0e                	jne    f0101b4c <__umoddi3+0xec>
f0101b3e:	39 c6                	cmp    %eax,%esi
f0101b40:	73 0a                	jae    f0101b4c <__umoddi3+0xec>
f0101b42:	29 e8                	sub    %ebp,%eax
f0101b44:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101b48:	89 d1                	mov    %edx,%ecx
f0101b4a:	89 c7                	mov    %eax,%edi
f0101b4c:	89 f5                	mov    %esi,%ebp
f0101b4e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101b52:	29 fd                	sub    %edi,%ebp
f0101b54:	19 cb                	sbb    %ecx,%ebx
f0101b56:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101b5b:	89 d8                	mov    %ebx,%eax
f0101b5d:	d3 e0                	shl    %cl,%eax
f0101b5f:	89 f1                	mov    %esi,%ecx
f0101b61:	d3 ed                	shr    %cl,%ebp
f0101b63:	d3 eb                	shr    %cl,%ebx
f0101b65:	09 e8                	or     %ebp,%eax
f0101b67:	89 da                	mov    %ebx,%edx
f0101b69:	83 c4 1c             	add    $0x1c,%esp
f0101b6c:	5b                   	pop    %ebx
f0101b6d:	5e                   	pop    %esi
f0101b6e:	5f                   	pop    %edi
f0101b6f:	5d                   	pop    %ebp
f0101b70:	c3                   	ret    
