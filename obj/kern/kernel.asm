
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
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6a 00 00 00       	call   f01000a8 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 fe 23 f0 00 	cmpl   $0x0,0xf023fe80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 fe 23 f0    	mov    %esi,0xf023fe80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 55 6f 00 00       	call   f0106fb9 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 a0 76 10 f0 	movl   $0xf01076a0,(%esp)
f010007d:	e8 fa 3f 00 00       	call   f010407c <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 88 3f 00 00       	call   f0104016 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 e9 88 10 f0 	movl   $0xf01088e9,(%esp)
f0100095:	e8 e2 3f 00 00       	call   f010407c <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 54 09 00 00       	call   f01009fa <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000af:	b8 08 20 28 f0       	mov    $0xf0282008,%eax
f01000b4:	2d b9 eb 23 f0       	sub    $0xf023ebb9,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 b9 eb 23 f0 	movl   $0xf023ebb9,(%esp)
f01000cc:	e8 96 68 00 00       	call   f0106967 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d1:	e8 a9 05 00 00       	call   f010067f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 0c 77 10 f0 	movl   $0xf010770c,(%esp)
f01000e5:	e8 92 3f 00 00       	call   f010407c <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ea:	e8 6f 14 00 00       	call   f010155e <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000ef:	e8 cf 36 00 00       	call   f01037c3 <env_init>
	trap_init();
f01000f4:	e8 af 40 00 00       	call   f01041a8 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000f9:	e8 ac 6b 00 00       	call   f0106caa <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 cf 6e 00 00       	call   f0106fd4 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100105:	e8 6f 3e 00 00       	call   f0103f79 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0100111:	e8 21 71 00 00       	call   f0107237 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 fe 23 f0 07 	cmpl   $0x7,0xf023fe88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 27 77 10 f0 	movl   $0xf0107727,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 e2 6b 10 f0       	mov    $0xf0106be2,%eax
f0100148:	2d 68 6b 10 f0       	sub    $0xf0106b68,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 68 6b 10 	movl   $0xf0106b68,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 4f 68 00 00       	call   f01069b4 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100165:	bb 20 10 24 f0       	mov    $0xf0241020,%ebx
f010016a:	eb 4d                	jmp    f01001b9 <i386_init+0x111>
		if (c == cpus + cpunum())  // We've started already.
f010016c:	e8 48 6e 00 00       	call   f0106fb9 <cpunum>
f0100171:	6b c0 74             	imul   $0x74,%eax,%eax
f0100174:	05 20 10 24 f0       	add    $0xf0241020,%eax
f0100179:	39 c3                	cmp    %eax,%ebx
f010017b:	74 39                	je     f01001b6 <i386_init+0x10e>
f010017d:	89 d8                	mov    %ebx,%eax
f010017f:	2d 20 10 24 f0       	sub    $0xf0241020,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100184:	c1 f8 02             	sar    $0x2,%eax
f0100187:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010018d:	c1 e0 0f             	shl    $0xf,%eax
f0100190:	8d 80 00 a0 24 f0    	lea    -0xfdb6000(%eax),%eax
f0100196:	a3 84 fe 23 f0       	mov    %eax,0xf023fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010019b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001a2:	00 
f01001a3:	0f b6 03             	movzbl (%ebx),%eax
f01001a6:	89 04 24             	mov    %eax,(%esp)
f01001a9:	e8 76 6f 00 00       	call   f0107124 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001ae:	8b 43 04             	mov    0x4(%ebx),%eax
f01001b1:	83 f8 01             	cmp    $0x1,%eax
f01001b4:	75 f8                	jne    f01001ae <i386_init+0x106>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001b6:	83 c3 74             	add    $0x74,%ebx
f01001b9:	6b 05 c4 13 24 f0 74 	imul   $0x74,0xf02413c4,%eax
f01001c0:	05 20 10 24 f0       	add    $0xf0241020,%eax
f01001c5:	39 c3                	cmp    %eax,%ebx
f01001c7:	72 a3                	jb     f010016c <i386_init+0xc4>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001d0:	00 
f01001d1:	c7 04 24 87 a6 20 f0 	movl   $0xf020a687,(%esp)
f01001d8:	e8 06 38 00 00       	call   f01039e3 <env_create>
	// Touch all you want.
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001dd:	e8 dd 4e 00 00       	call   f01050bf <sched_yield>

f01001e2 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001e2:	55                   	push   %ebp
f01001e3:	89 e5                	mov    %esp,%ebp
f01001e5:	83 ec 18             	sub    $0x18,%esp
        	cr4 |= CR4_PSE ;
        	lcr4(cr4);
        	tlbflush();
	}
	*/
	lcr3(PADDR(kern_pgdir));
f01001e8:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f2:	77 20                	ja     f0100214 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001f8:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f01001ff:	f0 
f0100200:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
f0100207:	00 
f0100208:	c7 04 24 27 77 10 f0 	movl   $0xf0107727,(%esp)
f010020f:	e8 2c fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100214:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100219:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010021c:	e8 98 6d 00 00       	call   f0106fb9 <cpunum>
f0100221:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100225:	c7 04 24 33 77 10 f0 	movl   $0xf0107733,(%esp)
f010022c:	e8 4b 3e 00 00       	call   f010407c <cprintf>

	lapic_init();
f0100231:	e8 9e 6d 00 00       	call   f0106fd4 <lapic_init>
	env_init_percpu();
f0100236:	e8 5e 35 00 00       	call   f0103799 <env_init_percpu>
	trap_init_percpu();
f010023b:	90                   	nop
f010023c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100240:	e8 6b 3e 00 00       	call   f01040b0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100245:	e8 6f 6d 00 00       	call   f0106fb9 <cpunum>
f010024a:	6b d0 74             	imul   $0x74,%eax,%edx
f010024d:	81 c2 20 10 24 f0    	add    $0xf0241020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100253:	b8 01 00 00 00       	mov    $0x1,%eax
f0100258:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010025c:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0100263:	e8 cf 6f 00 00       	call   f0107237 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100268:	e8 52 4e 00 00       	call   f01050bf <sched_yield>

f010026d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010026d:	55                   	push   %ebp
f010026e:	89 e5                	mov    %esp,%ebp
f0100270:	53                   	push   %ebx
f0100271:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100274:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100277:	8b 45 0c             	mov    0xc(%ebp),%eax
f010027a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010027e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100281:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100285:	c7 04 24 49 77 10 f0 	movl   $0xf0107749,(%esp)
f010028c:	e8 eb 3d 00 00       	call   f010407c <cprintf>
	vcprintf(fmt, ap);
f0100291:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100295:	8b 45 10             	mov    0x10(%ebp),%eax
f0100298:	89 04 24             	mov    %eax,(%esp)
f010029b:	e8 76 3d 00 00       	call   f0104016 <vcprintf>
	cprintf("\n");
f01002a0:	c7 04 24 e9 88 10 f0 	movl   $0xf01088e9,(%esp)
f01002a7:	e8 d0 3d 00 00       	call   f010407c <cprintf>
	va_end(ap);
}
f01002ac:	83 c4 14             	add    $0x14,%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5d                   	pop    %ebp
f01002b1:	c3                   	ret    
f01002b2:	66 90                	xchg   %ax,%ax
f01002b4:	66 90                	xchg   %ax,%ax
f01002b6:	66 90                	xchg   %ax,%ax
f01002b8:	66 90                	xchg   %ax,%ax
f01002ba:	66 90                	xchg   %ax,%ax
f01002bc:	66 90                	xchg   %ax,%ax
f01002be:	66 90                	xchg   %ax,%ax

f01002c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002c9:	a8 01                	test   $0x1,%al
f01002cb:	74 08                	je     f01002d5 <serial_proc_data+0x15>
f01002cd:	b2 f8                	mov    $0xf8,%dl
f01002cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002d0:	0f b6 c0             	movzbl %al,%eax
f01002d3:	eb 05                	jmp    f01002da <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002da:	5d                   	pop    %ebp
f01002db:	c3                   	ret    

f01002dc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002dc:	55                   	push   %ebp
f01002dd:	89 e5                	mov    %esp,%ebp
f01002df:	53                   	push   %ebx
f01002e0:	83 ec 04             	sub    $0x4,%esp
f01002e3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002e5:	eb 2a                	jmp    f0100311 <cons_intr+0x35>
		if (c == 0)
f01002e7:	85 d2                	test   %edx,%edx
f01002e9:	74 26                	je     f0100311 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002eb:	a1 24 f2 23 f0       	mov    0xf023f224,%eax
f01002f0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002f3:	89 0d 24 f2 23 f0    	mov    %ecx,0xf023f224
f01002f9:	88 90 20 f0 23 f0    	mov    %dl,-0xfdc0fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002ff:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100305:	75 0a                	jne    f0100311 <cons_intr+0x35>
			cons.wpos = 0;
f0100307:	c7 05 24 f2 23 f0 00 	movl   $0x0,0xf023f224
f010030e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100311:	ff d3                	call   *%ebx
f0100313:	89 c2                	mov    %eax,%edx
f0100315:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100318:	75 cd                	jne    f01002e7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010031a:	83 c4 04             	add    $0x4,%esp
f010031d:	5b                   	pop    %ebx
f010031e:	5d                   	pop    %ebp
f010031f:	c3                   	ret    

f0100320 <kbd_proc_data>:
f0100320:	ba 64 00 00 00       	mov    $0x64,%edx
f0100325:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100326:	a8 01                	test   $0x1,%al
f0100328:	0f 84 ef 00 00 00    	je     f010041d <kbd_proc_data+0xfd>
f010032e:	b2 60                	mov    $0x60,%dl
f0100330:	ec                   	in     (%dx),%al
f0100331:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100333:	3c e0                	cmp    $0xe0,%al
f0100335:	75 0d                	jne    f0100344 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100337:	83 0d 00 f0 23 f0 40 	orl    $0x40,0xf023f000
		return 0;
f010033e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100343:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100344:	55                   	push   %ebp
f0100345:	89 e5                	mov    %esp,%ebp
f0100347:	53                   	push   %ebx
f0100348:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010034b:	84 c0                	test   %al,%al
f010034d:	79 37                	jns    f0100386 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010034f:	8b 0d 00 f0 23 f0    	mov    0xf023f000,%ecx
f0100355:	89 cb                	mov    %ecx,%ebx
f0100357:	83 e3 40             	and    $0x40,%ebx
f010035a:	83 e0 7f             	and    $0x7f,%eax
f010035d:	85 db                	test   %ebx,%ebx
f010035f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100362:	0f b6 d2             	movzbl %dl,%edx
f0100365:	0f b6 82 c0 78 10 f0 	movzbl -0xfef8740(%edx),%eax
f010036c:	83 c8 40             	or     $0x40,%eax
f010036f:	0f b6 c0             	movzbl %al,%eax
f0100372:	f7 d0                	not    %eax
f0100374:	21 c1                	and    %eax,%ecx
f0100376:	89 0d 00 f0 23 f0    	mov    %ecx,0xf023f000
		return 0;
f010037c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100381:	e9 9d 00 00 00       	jmp    f0100423 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100386:	8b 0d 00 f0 23 f0    	mov    0xf023f000,%ecx
f010038c:	f6 c1 40             	test   $0x40,%cl
f010038f:	74 0e                	je     f010039f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100391:	83 c8 80             	or     $0xffffff80,%eax
f0100394:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100396:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100399:	89 0d 00 f0 23 f0    	mov    %ecx,0xf023f000
	}

	shift |= shiftcode[data];
f010039f:	0f b6 d2             	movzbl %dl,%edx
f01003a2:	0f b6 82 c0 78 10 f0 	movzbl -0xfef8740(%edx),%eax
f01003a9:	0b 05 00 f0 23 f0    	or     0xf023f000,%eax
	shift ^= togglecode[data];
f01003af:	0f b6 8a c0 77 10 f0 	movzbl -0xfef8840(%edx),%ecx
f01003b6:	31 c8                	xor    %ecx,%eax
f01003b8:	a3 00 f0 23 f0       	mov    %eax,0xf023f000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003bd:	89 c1                	mov    %eax,%ecx
f01003bf:	83 e1 03             	and    $0x3,%ecx
f01003c2:	8b 0c 8d a0 77 10 f0 	mov    -0xfef8860(,%ecx,4),%ecx
f01003c9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003cd:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003d0:	a8 08                	test   $0x8,%al
f01003d2:	74 1b                	je     f01003ef <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01003d4:	89 da                	mov    %ebx,%edx
f01003d6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003d9:	83 f9 19             	cmp    $0x19,%ecx
f01003dc:	77 05                	ja     f01003e3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01003de:	83 eb 20             	sub    $0x20,%ebx
f01003e1:	eb 0c                	jmp    f01003ef <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01003e3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003e6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003e9:	83 fa 19             	cmp    $0x19,%edx
f01003ec:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003ef:	f7 d0                	not    %eax
f01003f1:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003f3:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003f5:	f6 c2 06             	test   $0x6,%dl
f01003f8:	75 29                	jne    f0100423 <kbd_proc_data+0x103>
f01003fa:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100400:	75 21                	jne    f0100423 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f0100402:	c7 04 24 63 77 10 f0 	movl   $0xf0107763,(%esp)
f0100409:	e8 6e 3c 00 00       	call   f010407c <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100413:	b8 03 00 00 00       	mov    $0x3,%eax
f0100418:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100419:	89 d8                	mov    %ebx,%eax
f010041b:	eb 06                	jmp    f0100423 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010041d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100422:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100423:	83 c4 14             	add    $0x14,%esp
f0100426:	5b                   	pop    %ebx
f0100427:	5d                   	pop    %ebp
f0100428:	c3                   	ret    

f0100429 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100429:	55                   	push   %ebp
f010042a:	89 e5                	mov    %esp,%ebp
f010042c:	57                   	push   %edi
f010042d:	56                   	push   %esi
f010042e:	53                   	push   %ebx
f010042f:	83 ec 1c             	sub    $0x1c,%esp
f0100432:	89 c7                	mov    %eax,%edi
f0100434:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100439:	be fd 03 00 00       	mov    $0x3fd,%esi
f010043e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100443:	eb 06                	jmp    f010044b <cons_putc+0x22>
f0100445:	89 ca                	mov    %ecx,%edx
f0100447:	ec                   	in     (%dx),%al
f0100448:	ec                   	in     (%dx),%al
f0100449:	ec                   	in     (%dx),%al
f010044a:	ec                   	in     (%dx),%al
f010044b:	89 f2                	mov    %esi,%edx
f010044d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010044e:	a8 20                	test   $0x20,%al
f0100450:	75 05                	jne    f0100457 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100452:	83 eb 01             	sub    $0x1,%ebx
f0100455:	75 ee                	jne    f0100445 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100457:	89 f8                	mov    %edi,%eax
f0100459:	0f b6 c0             	movzbl %al,%eax
f010045c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010045f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100464:	ee                   	out    %al,(%dx)
f0100465:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010046a:	be 79 03 00 00       	mov    $0x379,%esi
f010046f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100474:	eb 06                	jmp    f010047c <cons_putc+0x53>
f0100476:	89 ca                	mov    %ecx,%edx
f0100478:	ec                   	in     (%dx),%al
f0100479:	ec                   	in     (%dx),%al
f010047a:	ec                   	in     (%dx),%al
f010047b:	ec                   	in     (%dx),%al
f010047c:	89 f2                	mov    %esi,%edx
f010047e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010047f:	84 c0                	test   %al,%al
f0100481:	78 05                	js     f0100488 <cons_putc+0x5f>
f0100483:	83 eb 01             	sub    $0x1,%ebx
f0100486:	75 ee                	jne    f0100476 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100488:	ba 78 03 00 00       	mov    $0x378,%edx
f010048d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100491:	ee                   	out    %al,(%dx)
f0100492:	b2 7a                	mov    $0x7a,%dl
f0100494:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100499:	ee                   	out    %al,(%dx)
f010049a:	b8 08 00 00 00       	mov    $0x8,%eax
f010049f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004a0:	89 fa                	mov    %edi,%edx
f01004a2:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004a8:	89 f8                	mov    %edi,%eax
f01004aa:	80 cc 07             	or     $0x7,%ah
f01004ad:	85 d2                	test   %edx,%edx
f01004af:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004b2:	89 f8                	mov    %edi,%eax
f01004b4:	0f b6 c0             	movzbl %al,%eax
f01004b7:	83 f8 09             	cmp    $0x9,%eax
f01004ba:	74 76                	je     f0100532 <cons_putc+0x109>
f01004bc:	83 f8 09             	cmp    $0x9,%eax
f01004bf:	7f 0a                	jg     f01004cb <cons_putc+0xa2>
f01004c1:	83 f8 08             	cmp    $0x8,%eax
f01004c4:	74 16                	je     f01004dc <cons_putc+0xb3>
f01004c6:	e9 9b 00 00 00       	jmp    f0100566 <cons_putc+0x13d>
f01004cb:	83 f8 0a             	cmp    $0xa,%eax
f01004ce:	66 90                	xchg   %ax,%ax
f01004d0:	74 3a                	je     f010050c <cons_putc+0xe3>
f01004d2:	83 f8 0d             	cmp    $0xd,%eax
f01004d5:	74 3d                	je     f0100514 <cons_putc+0xeb>
f01004d7:	e9 8a 00 00 00       	jmp    f0100566 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f01004dc:	0f b7 05 28 f2 23 f0 	movzwl 0xf023f228,%eax
f01004e3:	66 85 c0             	test   %ax,%ax
f01004e6:	0f 84 e5 00 00 00    	je     f01005d1 <cons_putc+0x1a8>
			crt_pos--;
f01004ec:	83 e8 01             	sub    $0x1,%eax
f01004ef:	66 a3 28 f2 23 f0    	mov    %ax,0xf023f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004f5:	0f b7 c0             	movzwl %ax,%eax
f01004f8:	66 81 e7 00 ff       	and    $0xff00,%di
f01004fd:	83 cf 20             	or     $0x20,%edi
f0100500:	8b 15 2c f2 23 f0    	mov    0xf023f22c,%edx
f0100506:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010050a:	eb 78                	jmp    f0100584 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010050c:	66 83 05 28 f2 23 f0 	addw   $0x50,0xf023f228
f0100513:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100514:	0f b7 05 28 f2 23 f0 	movzwl 0xf023f228,%eax
f010051b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100521:	c1 e8 16             	shr    $0x16,%eax
f0100524:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100527:	c1 e0 04             	shl    $0x4,%eax
f010052a:	66 a3 28 f2 23 f0    	mov    %ax,0xf023f228
f0100530:	eb 52                	jmp    f0100584 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f0100532:	b8 20 00 00 00       	mov    $0x20,%eax
f0100537:	e8 ed fe ff ff       	call   f0100429 <cons_putc>
		cons_putc(' ');
f010053c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100541:	e8 e3 fe ff ff       	call   f0100429 <cons_putc>
		cons_putc(' ');
f0100546:	b8 20 00 00 00       	mov    $0x20,%eax
f010054b:	e8 d9 fe ff ff       	call   f0100429 <cons_putc>
		cons_putc(' ');
f0100550:	b8 20 00 00 00       	mov    $0x20,%eax
f0100555:	e8 cf fe ff ff       	call   f0100429 <cons_putc>
		cons_putc(' ');
f010055a:	b8 20 00 00 00       	mov    $0x20,%eax
f010055f:	e8 c5 fe ff ff       	call   f0100429 <cons_putc>
f0100564:	eb 1e                	jmp    f0100584 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100566:	0f b7 05 28 f2 23 f0 	movzwl 0xf023f228,%eax
f010056d:	8d 50 01             	lea    0x1(%eax),%edx
f0100570:	66 89 15 28 f2 23 f0 	mov    %dx,0xf023f228
f0100577:	0f b7 c0             	movzwl %ax,%eax
f010057a:	8b 15 2c f2 23 f0    	mov    0xf023f22c,%edx
f0100580:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100584:	66 81 3d 28 f2 23 f0 	cmpw   $0x7cf,0xf023f228
f010058b:	cf 07 
f010058d:	76 42                	jbe    f01005d1 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010058f:	a1 2c f2 23 f0       	mov    0xf023f22c,%eax
f0100594:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010059b:	00 
f010059c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005a6:	89 04 24             	mov    %eax,(%esp)
f01005a9:	e8 06 64 00 00       	call   f01069b4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005ae:	8b 15 2c f2 23 f0    	mov    0xf023f22c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005b9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005bf:	83 c0 01             	add    $0x1,%eax
f01005c2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005c7:	75 f0                	jne    f01005b9 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005c9:	66 83 2d 28 f2 23 f0 	subw   $0x50,0xf023f228
f01005d0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005d1:	8b 0d 30 f2 23 f0    	mov    0xf023f230,%ecx
f01005d7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005dc:	89 ca                	mov    %ecx,%edx
f01005de:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005df:	0f b7 1d 28 f2 23 f0 	movzwl 0xf023f228,%ebx
f01005e6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005e9:	89 d8                	mov    %ebx,%eax
f01005eb:	66 c1 e8 08          	shr    $0x8,%ax
f01005ef:	89 f2                	mov    %esi,%edx
f01005f1:	ee                   	out    %al,(%dx)
f01005f2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005f7:	89 ca                	mov    %ecx,%edx
f01005f9:	ee                   	out    %al,(%dx)
f01005fa:	89 d8                	mov    %ebx,%eax
f01005fc:	89 f2                	mov    %esi,%edx
f01005fe:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005ff:	83 c4 1c             	add    $0x1c,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5e                   	pop    %esi
f0100604:	5f                   	pop    %edi
f0100605:	5d                   	pop    %ebp
f0100606:	c3                   	ret    

f0100607 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100607:	80 3d 34 f2 23 f0 00 	cmpb   $0x0,0xf023f234
f010060e:	74 11                	je     f0100621 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100616:	b8 c0 02 10 f0       	mov    $0xf01002c0,%eax
f010061b:	e8 bc fc ff ff       	call   f01002dc <cons_intr>
}
f0100620:	c9                   	leave  
f0100621:	f3 c3                	repz ret 

f0100623 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100623:	55                   	push   %ebp
f0100624:	89 e5                	mov    %esp,%ebp
f0100626:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100629:	b8 20 03 10 f0       	mov    $0xf0100320,%eax
f010062e:	e8 a9 fc ff ff       	call   f01002dc <cons_intr>
}
f0100633:	c9                   	leave  
f0100634:	c3                   	ret    

f0100635 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100635:	55                   	push   %ebp
f0100636:	89 e5                	mov    %esp,%ebp
f0100638:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010063b:	e8 c7 ff ff ff       	call   f0100607 <serial_intr>
	kbd_intr();
f0100640:	e8 de ff ff ff       	call   f0100623 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100645:	a1 20 f2 23 f0       	mov    0xf023f220,%eax
f010064a:	3b 05 24 f2 23 f0    	cmp    0xf023f224,%eax
f0100650:	74 26                	je     f0100678 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100652:	8d 50 01             	lea    0x1(%eax),%edx
f0100655:	89 15 20 f2 23 f0    	mov    %edx,0xf023f220
f010065b:	0f b6 88 20 f0 23 f0 	movzbl -0xfdc0fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100662:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100664:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010066a:	75 11                	jne    f010067d <cons_getc+0x48>
			cons.rpos = 0;
f010066c:	c7 05 20 f2 23 f0 00 	movl   $0x0,0xf023f220
f0100673:	00 00 00 
f0100676:	eb 05                	jmp    f010067d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100678:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010067d:	c9                   	leave  
f010067e:	c3                   	ret    

f010067f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010067f:	55                   	push   %ebp
f0100680:	89 e5                	mov    %esp,%ebp
f0100682:	57                   	push   %edi
f0100683:	56                   	push   %esi
f0100684:	53                   	push   %ebx
f0100685:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100688:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010068f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100696:	5a a5 
	if (*cp != 0xA55A) {
f0100698:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010069f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006a3:	74 11                	je     f01006b6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006a5:	c7 05 30 f2 23 f0 b4 	movl   $0x3b4,0xf023f230
f01006ac:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006af:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006b4:	eb 16                	jmp    f01006cc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006b6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006bd:	c7 05 30 f2 23 f0 d4 	movl   $0x3d4,0xf023f230
f01006c4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006c7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006cc:	8b 0d 30 f2 23 f0    	mov    0xf023f230,%ecx
f01006d2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006d7:	89 ca                	mov    %ecx,%edx
f01006d9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006da:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006dd:	89 da                	mov    %ebx,%edx
f01006df:	ec                   	in     (%dx),%al
f01006e0:	0f b6 f0             	movzbl %al,%esi
f01006e3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006eb:	89 ca                	mov    %ecx,%edx
f01006ed:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ee:	89 da                	mov    %ebx,%edx
f01006f0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006f1:	89 3d 2c f2 23 f0    	mov    %edi,0xf023f22c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006f7:	0f b6 d8             	movzbl %al,%ebx
f01006fa:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006fc:	66 89 35 28 f2 23 f0 	mov    %si,0xf023f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100703:	e8 1b ff ff ff       	call   f0100623 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100708:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010070f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100714:	89 04 24             	mov    %eax,(%esp)
f0100717:	e8 ee 37 00 00       	call   f0103f0a <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010071c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100721:	b8 00 00 00 00       	mov    $0x0,%eax
f0100726:	89 f2                	mov    %esi,%edx
f0100728:	ee                   	out    %al,(%dx)
f0100729:	b2 fb                	mov    $0xfb,%dl
f010072b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100730:	ee                   	out    %al,(%dx)
f0100731:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100736:	b8 0c 00 00 00       	mov    $0xc,%eax
f010073b:	89 da                	mov    %ebx,%edx
f010073d:	ee                   	out    %al,(%dx)
f010073e:	b2 f9                	mov    $0xf9,%dl
f0100740:	b8 00 00 00 00       	mov    $0x0,%eax
f0100745:	ee                   	out    %al,(%dx)
f0100746:	b2 fb                	mov    $0xfb,%dl
f0100748:	b8 03 00 00 00       	mov    $0x3,%eax
f010074d:	ee                   	out    %al,(%dx)
f010074e:	b2 fc                	mov    $0xfc,%dl
f0100750:	b8 00 00 00 00       	mov    $0x0,%eax
f0100755:	ee                   	out    %al,(%dx)
f0100756:	b2 f9                	mov    $0xf9,%dl
f0100758:	b8 01 00 00 00       	mov    $0x1,%eax
f010075d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010075e:	b2 fd                	mov    $0xfd,%dl
f0100760:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100761:	3c ff                	cmp    $0xff,%al
f0100763:	0f 95 c1             	setne  %cl
f0100766:	88 0d 34 f2 23 f0    	mov    %cl,0xf023f234
f010076c:	89 f2                	mov    %esi,%edx
f010076e:	ec                   	in     (%dx),%al
f010076f:	89 da                	mov    %ebx,%edx
f0100771:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100772:	84 c9                	test   %cl,%cl
f0100774:	75 0c                	jne    f0100782 <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f0100776:	c7 04 24 6f 77 10 f0 	movl   $0xf010776f,(%esp)
f010077d:	e8 fa 38 00 00       	call   f010407c <cprintf>
}
f0100782:	83 c4 1c             	add    $0x1c,%esp
f0100785:	5b                   	pop    %ebx
f0100786:	5e                   	pop    %esi
f0100787:	5f                   	pop    %edi
f0100788:	5d                   	pop    %ebp
f0100789:	c3                   	ret    

f010078a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010078a:	55                   	push   %ebp
f010078b:	89 e5                	mov    %esp,%ebp
f010078d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100790:	8b 45 08             	mov    0x8(%ebp),%eax
f0100793:	e8 91 fc ff ff       	call   f0100429 <cons_putc>
}
f0100798:	c9                   	leave  
f0100799:	c3                   	ret    

f010079a <getchar>:

int
getchar(void)
{
f010079a:	55                   	push   %ebp
f010079b:	89 e5                	mov    %esp,%ebp
f010079d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007a0:	e8 90 fe ff ff       	call   f0100635 <cons_getc>
f01007a5:	85 c0                	test   %eax,%eax
f01007a7:	74 f7                	je     f01007a0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a9:	c9                   	leave  
f01007aa:	c3                   	ret    

f01007ab <iscons>:

int
iscons(int fdnum)
{
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b3:	5d                   	pop    %ebp
f01007b4:	c3                   	ret    
f01007b5:	66 90                	xchg   %ax,%ax
f01007b7:	66 90                	xchg   %ax,%ax
f01007b9:	66 90                	xchg   %ax,%ax
f01007bb:	66 90                	xchg   %ax,%ax
f01007bd:	66 90                	xchg   %ax,%ax
f01007bf:	90                   	nop

f01007c0 <mon_help>:
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c0:	55                   	push   %ebp
f01007c1:	89 e5                	mov    %esp,%ebp
f01007c3:	83 ec 18             	sub    $0x18,%esp
	//ccprintf("I'm joke, don't beat me.\n",0x48);
	//ccprintf("Oh, it hurts , boy!\n",0x30);
	//ccprintf("I guess my battery would run out soon...\n",0x50);
	//ccprintf("Bye Bye!\n",0x70);
	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c6:	c7 44 24 08 c0 79 10 	movl   $0xf01079c0,0x8(%esp)
f01007cd:	f0 
f01007ce:	c7 44 24 04 de 79 10 	movl   $0xf01079de,0x4(%esp)
f01007d5:	f0 
f01007d6:	c7 04 24 e3 79 10 f0 	movl   $0xf01079e3,(%esp)
f01007dd:	e8 9a 38 00 00       	call   f010407c <cprintf>
f01007e2:	c7 44 24 08 90 7a 10 	movl   $0xf0107a90,0x8(%esp)
f01007e9:	f0 
f01007ea:	c7 44 24 04 ec 79 10 	movl   $0xf01079ec,0x4(%esp)
f01007f1:	f0 
f01007f2:	c7 04 24 e3 79 10 f0 	movl   $0xf01079e3,(%esp)
f01007f9:	e8 7e 38 00 00       	call   f010407c <cprintf>
f01007fe:	c7 44 24 08 b8 7a 10 	movl   $0xf0107ab8,0x8(%esp)
f0100805:	f0 
f0100806:	c7 44 24 04 f5 79 10 	movl   $0xf01079f5,0x4(%esp)
f010080d:	f0 
f010080e:	c7 04 24 e3 79 10 f0 	movl   $0xf01079e3,(%esp)
f0100815:	e8 62 38 00 00       	call   f010407c <cprintf>
	return 0;
}
f010081a:	b8 00 00 00 00       	mov    $0x0,%eax
f010081f:	c9                   	leave  
f0100820:	c3                   	ret    

f0100821 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100821:	55                   	push   %ebp
f0100822:	89 e5                	mov    %esp,%ebp
f0100824:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel sy0mbols:\n");
f0100827:	c7 04 24 ff 79 10 f0 	movl   $0xf01079ff,(%esp)
f010082e:	e8 49 38 00 00       	call   f010407c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100833:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010083a:	00 
f010083b:	c7 04 24 dc 7a 10 f0 	movl   $0xf0107adc,(%esp)
f0100842:	e8 35 38 00 00       	call   f010407c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100847:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010084e:	00 
f010084f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100856:	f0 
f0100857:	c7 04 24 04 7b 10 f0 	movl   $0xf0107b04,(%esp)
f010085e:	e8 19 38 00 00       	call   f010407c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100863:	c7 44 24 08 87 76 10 	movl   $0x107687,0x8(%esp)
f010086a:	00 
f010086b:	c7 44 24 04 87 76 10 	movl   $0xf0107687,0x4(%esp)
f0100872:	f0 
f0100873:	c7 04 24 28 7b 10 f0 	movl   $0xf0107b28,(%esp)
f010087a:	e8 fd 37 00 00       	call   f010407c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010087f:	c7 44 24 08 b9 eb 23 	movl   $0x23ebb9,0x8(%esp)
f0100886:	00 
f0100887:	c7 44 24 04 b9 eb 23 	movl   $0xf023ebb9,0x4(%esp)
f010088e:	f0 
f010088f:	c7 04 24 4c 7b 10 f0 	movl   $0xf0107b4c,(%esp)
f0100896:	e8 e1 37 00 00       	call   f010407c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010089b:	c7 44 24 08 08 20 28 	movl   $0x282008,0x8(%esp)
f01008a2:	00 
f01008a3:	c7 44 24 04 08 20 28 	movl   $0xf0282008,0x4(%esp)
f01008aa:	f0 
f01008ab:	c7 04 24 70 7b 10 f0 	movl   $0xf0107b70,(%esp)
f01008b2:	e8 c5 37 00 00       	call   f010407c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008b7:	b8 07 24 28 f0       	mov    $0xf0282407,%eax
f01008bc:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008c1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008c6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008cc:	85 c0                	test   %eax,%eax
f01008ce:	0f 48 c2             	cmovs  %edx,%eax
f01008d1:	c1 f8 0a             	sar    $0xa,%eax
f01008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d8:	c7 04 24 94 7b 10 f0 	movl   $0xf0107b94,(%esp)
f01008df:	e8 98 37 00 00       	call   f010407c <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e9:	c9                   	leave  
f01008ea:	c3                   	ret    

f01008eb <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008eb:	55                   	push   %ebp
f01008ec:	89 e5                	mov    %esp,%ebp
f01008ee:	57                   	push   %edi
f01008ef:	56                   	push   %esi
f01008f0:	53                   	push   %ebx
f01008f1:	83 ec 4c             	sub    $0x4c,%esp
        volatile int * tmp_ebp ; 
        volatile int * pre_ebp ; 
        tmp_ebp = ( int * ) read_ebp() ;  
f01008f4:	89 eb                	mov    %ebp,%ebx

        ccprintf("Stack backtrace:\n",0x15);
f01008f6:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
f01008fd:	00 
f01008fe:	c7 04 24 19 7a 10 f0 	movl   $0xf0107a19,(%esp)
f0100905:	e8 8c 37 00 00       	call   f0104096 <ccprintf>
	while ( ( tmp_ebp ) != 0 )  {
f010090a:	e9 d6 00 00 00       	jmp    f01009e5 <mon_backtrace+0xfa>
		ccprintf("  ebp %08x",0x12 ,(int)(tmp_ebp) );
f010090f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100913:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
f010091a:	00 
f010091b:	c7 04 24 2b 7a 10 f0 	movl   $0xf0107a2b,(%esp)
f0100922:	e8 6f 37 00 00       	call   f0104096 <ccprintf>
                ccprintf("  eip %08x",0x24,*(tmp_ebp+1) );
f0100927:	8b 43 04             	mov    0x4(%ebx),%eax
f010092a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010092e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
f0100935:	00 
f0100936:	c7 04 24 36 7a 10 f0 	movl   $0xf0107a36,(%esp)
f010093d:	e8 54 37 00 00       	call   f0104096 <ccprintf>
		ccprintf("  args %08x %08x %08x %08x %08x\n", 25 ,
f0100942:	8b 7b 18             	mov    0x18(%ebx),%edi
f0100945:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0100948:	8b 53 10             	mov    0x10(%ebx),%edx
f010094b:	8b 43 0c             	mov    0xc(%ebx),%eax
f010094e:	8b 73 08             	mov    0x8(%ebx),%esi
f0100951:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0100955:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0100959:	89 54 24 10          	mov    %edx,0x10(%esp)
f010095d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100961:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100965:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
f010096c:	00 
f010096d:	c7 04 24 c0 7b 10 f0 	movl   $0xf0107bc0,(%esp)
f0100974:	e8 1d 37 00 00       	call   f0104096 <ccprintf>
                *(tmp_ebp+2) , *(tmp_ebp+3) , *(tmp_ebp+4) , *(tmp_ebp+5) , *(tmp_ebp+6) );
		
                struct Eipdebuginfo eip_info ;
		debuginfo_eip( (*(tmp_ebp+1))-5 , &eip_info ) ; 
f0100979:	8b 43 04             	mov    0x4(%ebx),%eax
f010097c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010097f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100983:	83 e8 05             	sub    $0x5,%eax
f0100986:	89 04 24             	mov    %eax,(%esp)
f0100989:	e8 82 4f 00 00       	call   f0105910 <debuginfo_eip>
                ccprintf("%s:%d:",0x35,eip_info.eip_file, eip_info.eip_line);
f010098e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100991:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100995:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100998:	89 44 24 08          	mov    %eax,0x8(%esp)
f010099c:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
f01009a3:	00 
f01009a4:	c7 04 24 41 7a 10 f0 	movl   $0xf0107a41,(%esp)
f01009ab:	e8 e6 36 00 00       	call   f0104096 <ccprintf>
                ccprintf(" %.*s+%d\n",0x36,eip_info.eip_fn_namelen, eip_info.eip_fn_name , *(tmp_ebp+1) - 5 - eip_info.eip_fn_addr);
f01009b0:	8b 43 04             	mov    0x4(%ebx),%eax
f01009b3:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f01009b8:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01009bb:	01 d0                	add    %edx,%eax
f01009bd:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01009cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009cf:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
f01009d6:	00 
f01009d7:	c7 04 24 48 7a 10 f0 	movl   $0xf0107a48,(%esp)
f01009de:	e8 b3 36 00 00       	call   f0104096 <ccprintf>
	    tmp_ebp = ( int * ) ( *tmp_ebp ) ; 
f01009e3:	8b 1b                	mov    (%ebx),%ebx
        volatile int * tmp_ebp ; 
        volatile int * pre_ebp ; 
        tmp_ebp = ( int * ) read_ebp() ;  

        ccprintf("Stack backtrace:\n",0x15);
	while ( ( tmp_ebp ) != 0 )  {
f01009e5:	85 db                	test   %ebx,%ebx
f01009e7:	0f 85 22 ff ff ff    	jne    f010090f <mon_backtrace+0x24>
                ccprintf(" %.*s+%d\n",0x36,eip_info.eip_fn_namelen, eip_info.eip_fn_name , *(tmp_ebp+1) - 5 - eip_info.eip_fn_addr);
	    tmp_ebp = ( int * ) ( *tmp_ebp ) ; 
	}
	
	return 0;
}
f01009ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01009f2:	83 c4 4c             	add    $0x4c,%esp
f01009f5:	5b                   	pop    %ebx
f01009f6:	5e                   	pop    %esi
f01009f7:	5f                   	pop    %edi
f01009f8:	5d                   	pop    %ebp
f01009f9:	c3                   	ret    

f01009fa <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009fa:	55                   	push   %ebp
f01009fb:	89 e5                	mov    %esp,%ebp
f01009fd:	57                   	push   %edi
f01009fe:	56                   	push   %esi
f01009ff:	53                   	push   %ebx
f0100a00:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100a03:	c7 04 24 e4 7b 10 f0 	movl   $0xf0107be4,(%esp)
f0100a0a:	e8 6d 36 00 00       	call   f010407c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a0f:	c7 04 24 08 7c 10 f0 	movl   $0xf0107c08,(%esp)
f0100a16:	e8 61 36 00 00       	call   f010407c <cprintf>

	if (tf != NULL)
f0100a1b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100a1f:	74 0b                	je     f0100a2c <monitor+0x32>
		print_trapframe(tf);
f0100a21:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a24:	89 04 24             	mov    %eax,(%esp)
f0100a27:	e8 33 3e 00 00       	call   f010485f <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100a2c:	c7 04 24 52 7a 10 f0 	movl   $0xf0107a52,(%esp)
f0100a33:	e8 d8 5c 00 00       	call   f0106710 <readline>
f0100a38:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a3a:	85 c0                	test   %eax,%eax
f0100a3c:	74 ee                	je     f0100a2c <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a3e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100a45:	be 00 00 00 00       	mov    $0x0,%esi
f0100a4a:	eb 0a                	jmp    f0100a56 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a4c:	c6 03 00             	movb   $0x0,(%ebx)
f0100a4f:	89 f7                	mov    %esi,%edi
f0100a51:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a54:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a56:	0f b6 03             	movzbl (%ebx),%eax
f0100a59:	84 c0                	test   %al,%al
f0100a5b:	74 63                	je     f0100ac0 <monitor+0xc6>
f0100a5d:	0f be c0             	movsbl %al,%eax
f0100a60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a64:	c7 04 24 56 7a 10 f0 	movl   $0xf0107a56,(%esp)
f0100a6b:	e8 ba 5e 00 00       	call   f010692a <strchr>
f0100a70:	85 c0                	test   %eax,%eax
f0100a72:	75 d8                	jne    f0100a4c <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100a74:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a77:	74 47                	je     f0100ac0 <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a79:	83 fe 0f             	cmp    $0xf,%esi
f0100a7c:	75 16                	jne    f0100a94 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a7e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a85:	00 
f0100a86:	c7 04 24 5b 7a 10 f0 	movl   $0xf0107a5b,(%esp)
f0100a8d:	e8 ea 35 00 00       	call   f010407c <cprintf>
f0100a92:	eb 98                	jmp    f0100a2c <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a94:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a97:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a9b:	eb 03                	jmp    f0100aa0 <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a9d:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100aa0:	0f b6 03             	movzbl (%ebx),%eax
f0100aa3:	84 c0                	test   %al,%al
f0100aa5:	74 ad                	je     f0100a54 <monitor+0x5a>
f0100aa7:	0f be c0             	movsbl %al,%eax
f0100aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aae:	c7 04 24 56 7a 10 f0 	movl   $0xf0107a56,(%esp)
f0100ab5:	e8 70 5e 00 00       	call   f010692a <strchr>
f0100aba:	85 c0                	test   %eax,%eax
f0100abc:	74 df                	je     f0100a9d <monitor+0xa3>
f0100abe:	eb 94                	jmp    f0100a54 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0100ac0:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ac7:	00 

	// Lookup and invoke the co00mmand
	if (argc == 0)
f0100ac8:	85 f6                	test   %esi,%esi
f0100aca:	0f 84 5c ff ff ff    	je     f0100a2c <monitor+0x32>
f0100ad0:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ad5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ad8:	8b 04 85 40 7c 10 f0 	mov    -0xfef83c0(,%eax,4),%eax
f0100adf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae3:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ae6:	89 04 24             	mov    %eax,(%esp)
f0100ae9:	e8 de 5d 00 00       	call   f01068cc <strcmp>
f0100aee:	85 c0                	test   %eax,%eax
f0100af0:	75 24                	jne    f0100b16 <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100af2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100af5:	8b 55 08             	mov    0x8(%ebp),%edx
f0100af8:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100afc:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100aff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100b03:	89 34 24             	mov    %esi,(%esp)
f0100b06:	ff 14 85 48 7c 10 f0 	call   *-0xfef83b8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100b0d:	85 c0                	test   %eax,%eax
f0100b0f:	78 25                	js     f0100b36 <monitor+0x13c>
f0100b11:	e9 16 ff ff ff       	jmp    f0100a2c <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the co00mmand
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100b16:	83 c3 01             	add    $0x1,%ebx
f0100b19:	83 fb 03             	cmp    $0x3,%ebx
f0100b1c:	75 b7                	jne    f0100ad5 <monitor+0xdb>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b1e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100b21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b25:	c7 04 24 78 7a 10 f0 	movl   $0xf0107a78,(%esp)
f0100b2c:	e8 4b 35 00 00       	call   f010407c <cprintf>
f0100b31:	e9 f6 fe ff ff       	jmp    f0100a2c <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100b36:	83 c4 5c             	add    $0x5c,%esp
f0100b39:	5b                   	pop    %ebx
f0100b3a:	5e                   	pop    %esi
f0100b3b:	5f                   	pop    %edi
f0100b3c:	5d                   	pop    %ebp
f0100b3d:	c3                   	ret    
f0100b3e:	66 90                	xchg   %ax,%ax

f0100b40 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b40:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0100b46:	c1 f8 03             	sar    $0x3,%eax
f0100b49:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b4c:	89 c2                	mov    %eax,%edx
f0100b4e:	c1 ea 0c             	shr    $0xc,%edx
f0100b51:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0100b57:	72 26                	jb     f0100b7f <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100b59:	55                   	push   %ebp
f0100b5a:	89 e5                	mov    %esp,%ebp
f0100b5c:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b63:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0100b6a:	f0 
f0100b6b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100b72:	00 
f0100b73:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0100b7a:	e8 c1 f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100b7f:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100b84:	c3                   	ret    

f0100b85 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b85:	89 d1                	mov    %edx,%ecx
f0100b87:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b8a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b8d:	a8 01                	test   $0x1,%al
f0100b8f:	74 6f                	je     f0100c00 <check_va2pa+0x7b>
		return ~0;
	if ( (*pgdir) & PTE_PS ) 
f0100b91:	a8 80                	test   $0x80,%al
f0100b93:	74 0e                	je     f0100ba3 <check_va2pa+0x1e>
		return ( va & 0x003FFFFF ) + ( ( * pgdir ) & ( 0xFFC00000 ) ) ; 
f0100b95:	25 00 00 c0 ff       	and    $0xffc00000,%eax
f0100b9a:	81 e2 ff ff 3f 00    	and    $0x3fffff,%edx
f0100ba0:	01 d0                	add    %edx,%eax
f0100ba2:	c3                   	ret    
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ba3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ba8:	89 c1                	mov    %eax,%ecx
f0100baa:	c1 e9 0c             	shr    $0xc,%ecx
f0100bad:	3b 0d 88 fe 23 f0    	cmp    0xf023fe88,%ecx
f0100bb3:	72 26                	jb     f0100bdb <check_va2pa+0x56>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100bb5:	55                   	push   %ebp
f0100bb6:	89 e5                	mov    %esp,%ebp
f0100bb8:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bbf:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0100bc6:	f0 
f0100bc7:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0100bce:	00 
f0100bcf:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100bd6:	e8 65 f4 ff ff       	call   f0100040 <_panic>
	if (!(*pgdir & PTE_P))
		return ~0;
	if ( (*pgdir) & PTE_PS ) 
		return ( va & 0x003FFFFF ) + ( ( * pgdir ) & ( 0xFFC00000 ) ) ; 
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100bdb:	c1 ea 0c             	shr    $0xc,%edx
f0100bde:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100be4:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100beb:	89 c2                	mov    %eax,%edx
f0100bed:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bf0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bf5:	85 d2                	test   %edx,%edx
f0100bf7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bfc:	0f 44 c2             	cmove  %edx,%eax
f0100bff:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100c00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return ( va & 0x003FFFFF ) + ( ( * pgdir ) & ( 0xFFC00000 ) ) ; 
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100c05:	c3                   	ret    

f0100c06 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100c06:	55                   	push   %ebp
f0100c07:	89 e5                	mov    %esp,%ebp
f0100c09:	83 ec 18             	sub    $0x18,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100c0c:	83 3d 38 f2 23 f0 00 	cmpl   $0x0,0xf023f238
f0100c13:	75 11                	jne    f0100c26 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c15:	ba 07 30 28 f0       	mov    $0xf0283007,%edx
f0100c1a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c20:	89 15 38 f2 23 f0    	mov    %edx,0xf023f238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ( n == 0 ) return nextfree ; 
f0100c26:	85 c0                	test   %eax,%eax
f0100c28:	75 07                	jne    f0100c31 <boot_alloc+0x2b>
f0100c2a:	a1 38 f2 23 f0       	mov    0xf023f238,%eax
f0100c2f:	eb 70                	jmp    f0100ca1 <boot_alloc+0x9b>
	char * p_nextfree = ROUNDUP( nextfree + n , PGSIZE ) ;  
f0100c31:	8b 0d 38 f2 23 f0    	mov    0xf023f238,%ecx
f0100c37:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100c3e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c44:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c4a:	77 20                	ja     f0100c6c <boot_alloc+0x66>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c50:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0100c57:	f0 
f0100c58:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f0100c5f:	00 
f0100c60:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100c67:	e8 d4 f3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100c6c:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
	if ( PGNUM(PADDR(p_nextfree)) > npages ) 
f0100c72:	c1 e8 0c             	shr    $0xc,%eax
f0100c75:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0100c7b:	76 1c                	jbe    f0100c99 <boot_alloc+0x93>
		panic("boot_alloc: Run out of physical memory\n");
f0100c7d:	c7 44 24 08 64 7c 10 	movl   $0xf0107c64,0x8(%esp)
f0100c84:	f0 
f0100c85:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
f0100c8c:	00 
f0100c8d:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100c94:	e8 a7 f3 ff ff       	call   f0100040 <_panic>

	char * tmp = nextfree ;
	nextfree = p_nextfree ;  	
f0100c99:	89 15 38 f2 23 f0    	mov    %edx,0xf023f238
	return ( void * ) tmp ;
f0100c9f:	89 c8                	mov    %ecx,%eax
}
f0100ca1:	c9                   	leave  
f0100ca2:	c3                   	ret    

f0100ca3 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ca3:	55                   	push   %ebp
f0100ca4:	89 e5                	mov    %esp,%ebp
f0100ca6:	57                   	push   %edi
f0100ca7:	56                   	push   %esi
f0100ca8:	53                   	push   %ebx
f0100ca9:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cac:	84 c0                	test   %al,%al
f0100cae:	0f 85 31 03 00 00    	jne    f0100fe5 <check_page_free_list+0x342>
f0100cb4:	e9 3e 03 00 00       	jmp    f0100ff7 <check_page_free_list+0x354>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100cb9:	c7 44 24 08 8c 7c 10 	movl   $0xf0107c8c,0x8(%esp)
f0100cc0:	f0 
f0100cc1:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f0100cc8:	00 
f0100cc9:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100cd0:	e8 6b f3 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100cd5:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100cd8:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100cdb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cde:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ce1:	89 c2                	mov    %eax,%edx
f0100ce3:	2b 15 90 fe 23 f0    	sub    0xf023fe90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ce9:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100cef:	0f 95 c2             	setne  %dl
f0100cf2:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100cf5:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100cf9:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100cfb:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cff:	8b 00                	mov    (%eax),%eax
f0100d01:	85 c0                	test   %eax,%eax
f0100d03:	75 dc                	jne    f0100ce1 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100d0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d11:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d14:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100d16:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d19:	a3 40 f2 23 f0       	mov    %eax,0xf023f240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d1e:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d23:	8b 1d 40 f2 23 f0    	mov    0xf023f240,%ebx
f0100d29:	eb 63                	jmp    f0100d8e <check_page_free_list+0xeb>
f0100d2b:	89 d8                	mov    %ebx,%eax
f0100d2d:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0100d33:	c1 f8 03             	sar    $0x3,%eax
f0100d36:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d39:	89 c2                	mov    %eax,%edx
f0100d3b:	c1 ea 16             	shr    $0x16,%edx
f0100d3e:	39 f2                	cmp    %esi,%edx
f0100d40:	73 4a                	jae    f0100d8c <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d42:	89 c2                	mov    %eax,%edx
f0100d44:	c1 ea 0c             	shr    $0xc,%edx
f0100d47:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0100d4d:	72 20                	jb     f0100d6f <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d53:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0100d5a:	f0 
f0100d5b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d62:	00 
f0100d63:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0100d6a:	e8 d1 f2 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d6f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100d76:	00 
f0100d77:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d7e:	00 
	return (void *)(pa + KERNBASE);
f0100d7f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d84:	89 04 24             	mov    %eax,(%esp)
f0100d87:	e8 db 5b 00 00       	call   f0106967 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d8c:	8b 1b                	mov    (%ebx),%ebx
f0100d8e:	85 db                	test   %ebx,%ebx
f0100d90:	75 99                	jne    f0100d2b <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100d92:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d97:	e8 6a fe ff ff       	call   f0100c06 <boot_alloc>
f0100d9c:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d9f:	8b 15 40 f2 23 f0    	mov    0xf023f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100da5:	8b 0d 90 fe 23 f0    	mov    0xf023fe90,%ecx
		assert(pp < pages + npages);
f0100dab:	a1 88 fe 23 f0       	mov    0xf023fe88,%eax
f0100db0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100db3:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100db6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100db9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100dbc:	bf 00 00 00 00       	mov    $0x0,%edi
f0100dc1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dc4:	e9 c4 01 00 00       	jmp    f0100f8d <check_page_free_list+0x2ea>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100dc9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100dcc:	73 24                	jae    f0100df2 <check_page_free_list+0x14f>
f0100dce:	c7 44 24 0c 23 86 10 	movl   $0xf0108623,0xc(%esp)
f0100dd5:	f0 
f0100dd6:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100ddd:	f0 
f0100dde:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f0100de5:	00 
f0100de6:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100ded:	e8 4e f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100df2:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100df5:	72 24                	jb     f0100e1b <check_page_free_list+0x178>
f0100df7:	c7 44 24 0c 44 86 10 	movl   $0xf0108644,0xc(%esp)
f0100dfe:	f0 
f0100dff:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100e06:	f0 
f0100e07:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100e0e:	00 
f0100e0f:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100e16:	e8 25 f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e1b:	89 d0                	mov    %edx,%eax
f0100e1d:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100e20:	a8 07                	test   $0x7,%al
f0100e22:	74 24                	je     f0100e48 <check_page_free_list+0x1a5>
f0100e24:	c7 44 24 0c b0 7c 10 	movl   $0xf0107cb0,0xc(%esp)
f0100e2b:	f0 
f0100e2c:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100e33:	f0 
f0100e34:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0100e3b:	00 
f0100e3c:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100e43:	e8 f8 f1 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e48:	c1 f8 03             	sar    $0x3,%eax
f0100e4b:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100e4e:	85 c0                	test   %eax,%eax
f0100e50:	75 24                	jne    f0100e76 <check_page_free_list+0x1d3>
f0100e52:	c7 44 24 0c 58 86 10 	movl   $0xf0108658,0xc(%esp)
f0100e59:	f0 
f0100e5a:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100e61:	f0 
f0100e62:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0100e69:	00 
f0100e6a:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100e71:	e8 ca f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e76:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e7b:	75 24                	jne    f0100ea1 <check_page_free_list+0x1fe>
f0100e7d:	c7 44 24 0c 69 86 10 	movl   $0xf0108669,0xc(%esp)
f0100e84:	f0 
f0100e85:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100e8c:	f0 
f0100e8d:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0100e94:	00 
f0100e95:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100e9c:	e8 9f f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ea1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ea6:	75 24                	jne    f0100ecc <check_page_free_list+0x229>
f0100ea8:	c7 44 24 0c e4 7c 10 	movl   $0xf0107ce4,0xc(%esp)
f0100eaf:	f0 
f0100eb0:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100eb7:	f0 
f0100eb8:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0100ebf:	00 
f0100ec0:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100ec7:	e8 74 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ecc:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ed1:	75 24                	jne    f0100ef7 <check_page_free_list+0x254>
f0100ed3:	c7 44 24 0c 82 86 10 	movl   $0xf0108682,0xc(%esp)
f0100eda:	f0 
f0100edb:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100ee2:	f0 
f0100ee3:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0100eea:	00 
f0100eeb:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100ef2:	e8 49 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ef7:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100efc:	0f 86 1c 01 00 00    	jbe    f010101e <check_page_free_list+0x37b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f02:	89 c1                	mov    %eax,%ecx
f0100f04:	c1 e9 0c             	shr    $0xc,%ecx
f0100f07:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100f0a:	77 20                	ja     f0100f2c <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f10:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0100f17:	f0 
f0100f18:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f1f:	00 
f0100f20:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0100f27:	e8 14 f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100f2c:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100f32:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100f35:	0f 86 d3 00 00 00    	jbe    f010100e <check_page_free_list+0x36b>
f0100f3b:	c7 44 24 0c 08 7d 10 	movl   $0xf0107d08,0xc(%esp)
f0100f42:	f0 
f0100f43:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100f4a:	f0 
f0100f4b:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f0100f52:	00 
f0100f53:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100f5a:	e8 e1 f0 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f5f:	c7 44 24 0c 9c 86 10 	movl   $0xf010869c,0xc(%esp)
f0100f66:	f0 
f0100f67:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100f6e:	f0 
f0100f6f:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0100f76:	00 
f0100f77:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100f7e:	e8 bd f0 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100f83:	83 c3 01             	add    $0x1,%ebx
f0100f86:	eb 03                	jmp    f0100f8b <check_page_free_list+0x2e8>
		else
			++nfree_extmem;
f0100f88:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f8b:	8b 12                	mov    (%edx),%edx
f0100f8d:	85 d2                	test   %edx,%edx
f0100f8f:	0f 85 34 fe ff ff    	jne    f0100dc9 <check_page_free_list+0x126>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100f95:	85 db                	test   %ebx,%ebx
f0100f97:	7f 24                	jg     f0100fbd <check_page_free_list+0x31a>
f0100f99:	c7 44 24 0c b9 86 10 	movl   $0xf01086b9,0xc(%esp)
f0100fa0:	f0 
f0100fa1:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100fa8:	f0 
f0100fa9:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0100fb0:	00 
f0100fb1:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100fb8:	e8 83 f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100fbd:	85 ff                	test   %edi,%edi
f0100fbf:	7f 6d                	jg     f010102e <check_page_free_list+0x38b>
f0100fc1:	c7 44 24 0c cb 86 10 	movl   $0xf01086cb,0xc(%esp)
f0100fc8:	f0 
f0100fc9:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0100fd0:	f0 
f0100fd1:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0100fd8:	00 
f0100fd9:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0100fe0:	e8 5b f0 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100fe5:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f0100fea:	85 c0                	test   %eax,%eax
f0100fec:	0f 85 e3 fc ff ff    	jne    f0100cd5 <check_page_free_list+0x32>
f0100ff2:	e9 c2 fc ff ff       	jmp    f0100cb9 <check_page_free_list+0x16>
f0100ff7:	83 3d 40 f2 23 f0 00 	cmpl   $0x0,0xf023f240
f0100ffe:	0f 84 b5 fc ff ff    	je     f0100cb9 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101004:	be 00 04 00 00       	mov    $0x400,%esi
f0101009:	e9 15 fd ff ff       	jmp    f0100d23 <check_page_free_list+0x80>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010100e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101013:	0f 85 6f ff ff ff    	jne    f0100f88 <check_page_free_list+0x2e5>
f0101019:	e9 41 ff ff ff       	jmp    f0100f5f <check_page_free_list+0x2bc>
f010101e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101023:	0f 85 5a ff ff ff    	jne    f0100f83 <check_page_free_list+0x2e0>
f0101029:	e9 31 ff ff ff       	jmp    f0100f5f <check_page_free_list+0x2bc>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f010102e:	83 c4 4c             	add    $0x4c,%esp
f0101031:	5b                   	pop    %ebx
f0101032:	5e                   	pop    %esi
f0101033:	5f                   	pop    %edi
f0101034:	5d                   	pop    %ebp
f0101035:	c3                   	ret    

f0101036 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101036:	55                   	push   %ebp
f0101037:	89 e5                	mov    %esp,%ebp
f0101039:	53                   	push   %ebx
f010103a:	83 ec 14             	sub    $0x14,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	pages[0].pp_ref = 0 ; 
f010103d:	a1 90 fe 23 f0       	mov    0xf023fe90,%eax
f0101042:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pages[0].pp_link = NULL ; 
f0101048:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010104e:	8b 1d 40 f2 23 f0    	mov    0xf023f240,%ebx
	for (i = 1; i < PGNUM(IOPHYSMEM) ; i++) {
f0101054:	b8 01 00 00 00       	mov    $0x1,%eax
f0101059:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
		pages[i].pp_ref = 0;
f0101060:	89 ca                	mov    %ecx,%edx
f0101062:	03 15 90 fe 23 f0    	add    0xf023fe90,%edx
f0101068:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		if ( i == PGNUM(MPENTRY_PADDR) ) {
f010106e:	83 f8 07             	cmp    $0x7,%eax
f0101071:	75 0b                	jne    f010107e <page_init+0x48>
			pages[i].pp_link = NULL ; 
f0101073:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	pages[0].pp_ref = 0 ; 
	pages[0].pp_link = NULL ; 
	for (i = 1; i < PGNUM(IOPHYSMEM) ; i++) {
f0101079:	83 c0 01             	add    $0x1,%eax
f010107c:	eb db                	jmp    f0101059 <page_init+0x23>
		pages[i].pp_ref = 0;
		if ( i == PGNUM(MPENTRY_PADDR) ) {
			pages[i].pp_link = NULL ; 
			continue ; 
		}
		pages[i].pp_link = page_free_list;
f010107e:	89 1a                	mov    %ebx,(%edx)
		page_free_list = &pages[i];
f0101080:	03 0d 90 fe 23 f0    	add    0xf023fe90,%ecx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	pages[0].pp_ref = 0 ; 
	pages[0].pp_link = NULL ; 
	for (i = 1; i < PGNUM(IOPHYSMEM) ; i++) {
f0101086:	83 c0 01             	add    $0x1,%eax
f0101089:	3d a0 00 00 00       	cmp    $0xa0,%eax
f010108e:	75 0c                	jne    f010109c <page_init+0x66>
f0101090:	89 0d 40 f2 23 f0    	mov    %ecx,0xf023f240
f0101096:	66 b8 00 05          	mov    $0x500,%ax
f010109a:	eb 04                	jmp    f01010a0 <page_init+0x6a>
		if ( i == PGNUM(MPENTRY_PADDR) ) {
			pages[i].pp_link = NULL ; 
			continue ; 
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f010109c:	89 cb                	mov    %ecx,%ebx
f010109e:	eb b9                	jmp    f0101059 <page_init+0x23>
	}
	for ( ; i < PGNUM(EXTPHYSMEM)  ; i ++ ) {
		pages[i].pp_ref = 0 ; 
f01010a0:	89 c2                	mov    %eax,%edx
f01010a2:	03 15 90 fe 23 f0    	add    0xf023fe90,%edx
f01010a8:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = NULL ; 
f01010ae:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f01010b4:	83 c0 08             	add    $0x8,%eax
			continue ; 
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	for ( ; i < PGNUM(EXTPHYSMEM)  ; i ++ ) {
f01010b7:	3d 00 08 00 00       	cmp    $0x800,%eax
f01010bc:	75 e2                	jne    f01010a0 <page_init+0x6a>
		pages[i].pp_ref = 0 ; 
		pages[i].pp_link = NULL ; 
	}
	size_t limit = PGNUM(PADDR(boot_alloc(0)));
f01010be:	66 b8 00 00          	mov    $0x0,%ax
f01010c2:	e8 3f fb ff ff       	call   f0100c06 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010c7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010cc:	77 20                	ja     f01010ee <page_init+0xb8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010d2:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f01010d9:	f0 
f01010da:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
f01010e1:	00 
f01010e2:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01010e9:	e8 52 ef ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01010ee:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01010f4:	c1 ea 0c             	shr    $0xc,%edx
	for ( ; i < limit ; i ++ ) {
f01010f7:	b8 00 01 00 00       	mov    $0x100,%eax
f01010fc:	eb 18                	jmp    f0101116 <page_init+0xe0>
		pages[i].pp_ref = 0 ; 
f01010fe:	8b 0d 90 fe 23 f0    	mov    0xf023fe90,%ecx
f0101104:	8d 0c c1             	lea    (%ecx,%eax,8),%ecx
f0101107:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = NULL ;
f010110d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	for ( ; i < PGNUM(EXTPHYSMEM)  ; i ++ ) {
		pages[i].pp_ref = 0 ; 
		pages[i].pp_link = NULL ; 
	}
	size_t limit = PGNUM(PADDR(boot_alloc(0)));
	for ( ; i < limit ; i ++ ) {
f0101113:	83 c0 01             	add    $0x1,%eax
f0101116:	39 d0                	cmp    %edx,%eax
f0101118:	72 e4                	jb     f01010fe <page_init+0xc8>
f010111a:	81 fa 00 01 00 00    	cmp    $0x100,%edx
f0101120:	b8 00 01 00 00       	mov    $0x100,%eax
f0101125:	0f 42 d0             	cmovb  %eax,%edx
f0101128:	8b 1d 40 f2 23 f0    	mov    0xf023f240,%ebx
f010112e:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0101135:	eb 1e                	jmp    f0101155 <page_init+0x11f>
		pages[i].pp_ref = 0 ; 
		pages[i].pp_link = NULL ;
	}
	for ( ; i < npages ; i ++ ) {
		pages[i].pp_ref = 0 ; 
f0101137:	89 c1                	mov    %eax,%ecx
f0101139:	03 0d 90 fe 23 f0    	add    0xf023fe90,%ecx
f010113f:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101145:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0101147:	89 c3                	mov    %eax,%ebx
f0101149:	03 1d 90 fe 23 f0    	add    0xf023fe90,%ebx
	size_t limit = PGNUM(PADDR(boot_alloc(0)));
	for ( ; i < limit ; i ++ ) {
		pages[i].pp_ref = 0 ; 
		pages[i].pp_link = NULL ;
	}
	for ( ; i < npages ; i ++ ) {
f010114f:	83 c2 01             	add    $0x1,%edx
f0101152:	83 c0 08             	add    $0x8,%eax
f0101155:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f010115b:	72 da                	jb     f0101137 <page_init+0x101>
f010115d:	89 1d 40 f2 23 f0    	mov    %ebx,0xf023f240
		pages[i].pp_ref = 0 ; 
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0101163:	83 c4 14             	add    $0x14,%esp
f0101166:	5b                   	pop    %ebx
f0101167:	5d                   	pop    %ebp
f0101168:	c3                   	ret    

f0101169 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101169:	55                   	push   %ebp
f010116a:	89 e5                	mov    %esp,%ebp
f010116c:	53                   	push   %ebx
f010116d:	83 ec 14             	sub    $0x14,%esp
	if ( page_free_list == NULL ) {
f0101170:	8b 1d 40 f2 23 f0    	mov    0xf023f240,%ebx
f0101176:	85 db                	test   %ebx,%ebx
f0101178:	74 6f                	je     f01011e9 <page_alloc+0x80>
		return NULL ; 
	}
	struct PageInfo * rtn = page_free_list ;
	page_free_list = rtn->pp_link ; 
f010117a:	8b 03                	mov    (%ebx),%eax
f010117c:	a3 40 f2 23 f0       	mov    %eax,0xf023f240
	rtn->pp_link = NULL ; 
f0101181:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if ( alloc_flags & ALLOC_ZERO ) {
		memset( page2kva(rtn)  , 0 , PGSIZE ) ; 
	} 
	return rtn;
f0101187:	89 d8                	mov    %ebx,%eax
		return NULL ; 
	}
	struct PageInfo * rtn = page_free_list ;
	page_free_list = rtn->pp_link ; 
	rtn->pp_link = NULL ; 
	if ( alloc_flags & ALLOC_ZERO ) {
f0101189:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010118d:	74 5f                	je     f01011ee <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010118f:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0101195:	c1 f8 03             	sar    $0x3,%eax
f0101198:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010119b:	89 c2                	mov    %eax,%edx
f010119d:	c1 ea 0c             	shr    $0xc,%edx
f01011a0:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f01011a6:	72 20                	jb     f01011c8 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011ac:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f01011b3:	f0 
f01011b4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01011bb:	00 
f01011bc:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f01011c3:	e8 78 ee ff ff       	call   f0100040 <_panic>
		memset( page2kva(rtn)  , 0 , PGSIZE ) ; 
f01011c8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011cf:	00 
f01011d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011d7:	00 
	return (void *)(pa + KERNBASE);
f01011d8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011dd:	89 04 24             	mov    %eax,(%esp)
f01011e0:	e8 82 57 00 00       	call   f0106967 <memset>
	} 
	return rtn;
f01011e5:	89 d8                	mov    %ebx,%eax
f01011e7:	eb 05                	jmp    f01011ee <page_alloc+0x85>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if ( page_free_list == NULL ) {
		return NULL ; 
f01011e9:	b8 00 00 00 00       	mov    $0x0,%eax
	rtn->pp_link = NULL ; 
	if ( alloc_flags & ALLOC_ZERO ) {
		memset( page2kva(rtn)  , 0 , PGSIZE ) ; 
	} 
	return rtn;
}
f01011ee:	83 c4 14             	add    $0x14,%esp
f01011f1:	5b                   	pop    %ebx
f01011f2:	5d                   	pop    %ebp
f01011f3:	c3                   	ret    

f01011f4 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01011f4:	55                   	push   %ebp
f01011f5:	89 e5                	mov    %esp,%ebp
f01011f7:	83 ec 18             	sub    $0x18,%esp
f01011fa:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if ( pp->pp_ref != 0 ) 
f01011fd:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101202:	74 1c                	je     f0101220 <page_free+0x2c>
		panic("page_free: Page reference count is nonzero\n");
f0101204:	c7 44 24 08 50 7d 10 	movl   $0xf0107d50,0x8(%esp)
f010120b:	f0 
f010120c:	c7 44 24 04 8c 01 00 	movl   $0x18c,0x4(%esp)
f0101213:	00 
f0101214:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010121b:	e8 20 ee ff ff       	call   f0100040 <_panic>
 	if ( pp->pp_link != 0 ) 
f0101220:	83 38 00             	cmpl   $0x0,(%eax)
f0101223:	74 1c                	je     f0101241 <page_free+0x4d>
		panic("page_free: Page Link is not NULL\n");
f0101225:	c7 44 24 08 7c 7d 10 	movl   $0xf0107d7c,0x8(%esp)
f010122c:	f0 
f010122d:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f0101234:	00 
f0101235:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010123c:	e8 ff ed ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list ; 
f0101241:	8b 15 40 f2 23 f0    	mov    0xf023f240,%edx
f0101247:	89 10                	mov    %edx,(%eax)
	page_free_list = pp ; 
f0101249:	a3 40 f2 23 f0       	mov    %eax,0xf023f240
}
f010124e:	c9                   	leave  
f010124f:	c3                   	ret    

f0101250 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101250:	55                   	push   %ebp
f0101251:	89 e5                	mov    %esp,%ebp
f0101253:	83 ec 18             	sub    $0x18,%esp
f0101256:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101259:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010125d:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101260:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101264:	66 85 d2             	test   %dx,%dx
f0101267:	75 08                	jne    f0101271 <page_decref+0x21>
		page_free(pp);
f0101269:	89 04 24             	mov    %eax,(%esp)
f010126c:	e8 83 ff ff ff       	call   f01011f4 <page_free>
}
f0101271:	c9                   	leave  
f0101272:	c3                   	ret    

f0101273 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101273:	55                   	push   %ebp
f0101274:	89 e5                	mov    %esp,%ebp
f0101276:	56                   	push   %esi
f0101277:	53                   	push   %ebx
f0101278:	83 ec 10             	sub    $0x10,%esp
f010127b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pde_t * ptr_pde = pgdir + ( PDX(va) ) ;
f010127e:	89 de                	mov    %ebx,%esi
f0101280:	c1 ee 16             	shr    $0x16,%esi
f0101283:	c1 e6 02             	shl    $0x2,%esi
f0101286:	03 75 08             	add    0x8(%ebp),%esi
	pde_t   val_pde = * ptr_pde ; 
f0101289:	8b 06                	mov    (%esi),%eax
	if ( ! ( val_pde & PTE_P ) ) { 
f010128b:	a8 01                	test   $0x1,%al
f010128d:	75 30                	jne    f01012bf <pgdir_walk+0x4c>
		if ( create == false ) 
f010128f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101293:	74 6e                	je     f0101303 <pgdir_walk+0x90>
			return NULL ; 
		struct PageInfo * page_ptr = page_alloc(ALLOC_ZERO) ; 
f0101295:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010129c:	e8 c8 fe ff ff       	call   f0101169 <page_alloc>
		if ( page_ptr == NULL )	
f01012a1:	85 c0                	test   %eax,%eax
f01012a3:	74 65                	je     f010130a <pgdir_walk+0x97>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012a5:	89 c2                	mov    %eax,%edx
f01012a7:	2b 15 90 fe 23 f0    	sub    0xf023fe90,%edx
f01012ad:	c1 fa 03             	sar    $0x3,%edx
f01012b0:	c1 e2 0c             	shl    $0xc,%edx
			return NULL ; 
		(*ptr_pde) =  page2pa(page_ptr) | PTE_P | PTE_W | PTE_U ; 
f01012b3:	83 ca 07             	or     $0x7,%edx
f01012b6:	89 16                	mov    %edx,(%esi)
		(page_ptr->pp_ref) ++ ;
f01012b8:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		val_pde = ( * ptr_pde ) ; 
f01012bd:	8b 06                	mov    (%esi),%eax
	}
	pte_t * ptr_base_pte = ( pte_t * ) KADDR( PTE_ADDR( val_pde ) ) ; 
f01012bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012c4:	89 c2                	mov    %eax,%edx
f01012c6:	c1 ea 0c             	shr    $0xc,%edx
f01012c9:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f01012cf:	72 20                	jb     f01012f1 <pgdir_walk+0x7e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012d5:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f01012dc:	f0 
f01012dd:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
f01012e4:	00 
f01012e5:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01012ec:	e8 4f ed ff ff       	call   f0100040 <_panic>
	pte_t * ptr_pte = ptr_base_pte + ( PTX(va) ) ; 
f01012f1:	c1 eb 0a             	shr    $0xa,%ebx
f01012f4:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
	return ptr_pte ; 	
f01012fa:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101301:	eb 0c                	jmp    f010130f <pgdir_walk+0x9c>
	// Fill this function in
	pde_t * ptr_pde = pgdir + ( PDX(va) ) ;
	pde_t   val_pde = * ptr_pde ; 
	if ( ! ( val_pde & PTE_P ) ) { 
		if ( create == false ) 
			return NULL ; 
f0101303:	b8 00 00 00 00       	mov    $0x0,%eax
f0101308:	eb 05                	jmp    f010130f <pgdir_walk+0x9c>
		struct PageInfo * page_ptr = page_alloc(ALLOC_ZERO) ; 
		if ( page_ptr == NULL )	
			return NULL ; 
f010130a:	b8 00 00 00 00       	mov    $0x0,%eax
		val_pde = ( * ptr_pde ) ; 
	}
	pte_t * ptr_base_pte = ( pte_t * ) KADDR( PTE_ADDR( val_pde ) ) ; 
	pte_t * ptr_pte = ptr_base_pte + ( PTX(va) ) ; 
	return ptr_pte ; 	
}
f010130f:	83 c4 10             	add    $0x10,%esp
f0101312:	5b                   	pop    %ebx
f0101313:	5e                   	pop    %esi
f0101314:	5d                   	pop    %ebp
f0101315:	c3                   	ret    

f0101316 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101316:	55                   	push   %ebp
f0101317:	89 e5                	mov    %esp,%ebp
f0101319:	57                   	push   %edi
f010131a:	56                   	push   %esi
f010131b:	53                   	push   %ebx
f010131c:	83 ec 2c             	sub    $0x2c,%esp
f010131f:	89 c6                	mov    %eax,%esi
f0101321:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101324:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

static __inline void
cpuid(uint32_t info, uint32_t *eaxp, uint32_t *ebxp, uint32_t *ecxp, uint32_t *edxp)
{
	uint32_t eax, ebx, ecx, edx;
	asm volatile("cpuid"
f0101327:	b8 01 00 00 00       	mov    $0x1,%eax
f010132c:	0f a2                	cpuid  
	uintptr_t ptr_va = va ; 
	physaddr_t ptr_pa = pa ; 
	size_t cnt = 0 ; 
f010132e:	bb 00 00 00 00       	mov    $0x0,%ebx
			ptr_pa = ptr_pa + PGSIZE * 1024 ;
                        cnt = cnt + PGSIZE * 1024 ; 
			continue ;  
		} 
		pte_t * ptr_pte = pgdir_walk( pgdir , ( void * ) ptr_va , true ) ;	
		(*ptr_pte) = ptr_pa | perm | PTE_P;   
f0101333:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101336:	83 c8 01             	or     $0x1,%eax
f0101339:	89 45 dc             	mov    %eax,-0x24(%ebp)

        uint32_t ceax , cebx , cecx , cedx ;
        cpuid( 1 , &ceax , &cebx , &cecx , &cedx ) ;
	uint32_t pse_enable = 0 & ( cedx & 0x8 ) ; 

	for ( ; cnt < size ; cnt += PGSIZE ) {
f010133c:	eb 24                	jmp    f0101362 <boot_map_region+0x4c>
			ptr_va = ptr_va + PGSIZE * 1024 ; 
			ptr_pa = ptr_pa + PGSIZE * 1024 ;
                        cnt = cnt + PGSIZE * 1024 ; 
			continue ;  
		} 
		pte_t * ptr_pte = pgdir_walk( pgdir , ( void * ) ptr_va , true ) ;	
f010133e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101345:	00 
f0101346:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101349:	01 d8                	add    %ebx,%eax
f010134b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010134f:	89 34 24             	mov    %esi,(%esp)
f0101352:	e8 1c ff ff ff       	call   f0101273 <pgdir_walk>
		(*ptr_pte) = ptr_pa | perm | PTE_P;   
f0101357:	0b 7d dc             	or     -0x24(%ebp),%edi
f010135a:	89 38                	mov    %edi,(%eax)

        uint32_t ceax , cebx , cecx , cedx ;
        cpuid( 1 , &ceax , &cebx , &cecx , &cedx ) ;
	uint32_t pse_enable = 0 & ( cedx & 0x8 ) ; 

	for ( ; cnt < size ; cnt += PGSIZE ) {
f010135c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101362:	89 df                	mov    %ebx,%edi
f0101364:	03 7d 08             	add    0x8(%ebp),%edi
f0101367:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010136a:	72 d2                	jb     f010133e <boot_map_region+0x28>
		pte_t * ptr_pte = pgdir_walk( pgdir , ( void * ) ptr_va , true ) ;	
		(*ptr_pte) = ptr_pa | perm | PTE_P;   
		ptr_va = ptr_va + PGSIZE ; 
		ptr_pa = ptr_pa + PGSIZE ; 
	}
}
f010136c:	83 c4 2c             	add    $0x2c,%esp
f010136f:	5b                   	pop    %ebx
f0101370:	5e                   	pop    %esi
f0101371:	5f                   	pop    %edi
f0101372:	5d                   	pop    %ebp
f0101373:	c3                   	ret    

f0101374 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101374:	55                   	push   %ebp
f0101375:	89 e5                	mov    %esp,%ebp
f0101377:	53                   	push   %ebx
f0101378:	83 ec 14             	sub    $0x14,%esp
f010137b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * ptr = pgdir_walk( pgdir , va , false ) ;
f010137e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101385:	00 
f0101386:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101389:	89 44 24 04          	mov    %eax,0x4(%esp)
f010138d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101390:	89 04 24             	mov    %eax,(%esp)
f0101393:	e8 db fe ff ff       	call   f0101273 <pgdir_walk>
	if ( ptr == NULL ) return NULL ;
f0101398:	85 c0                	test   %eax,%eax
f010139a:	74 3e                	je     f01013da <page_lookup+0x66>
	if ( pte_store != NULL )  
f010139c:	85 db                	test   %ebx,%ebx
f010139e:	74 02                	je     f01013a2 <page_lookup+0x2e>
		(*pte_store) = ptr ; 
f01013a0:	89 03                	mov    %eax,(%ebx)
	if ( ! (  ( * ptr ) & PTE_P ) ) return NULL ;
f01013a2:	8b 00                	mov    (%eax),%eax
f01013a4:	a8 01                	test   $0x1,%al
f01013a6:	74 39                	je     f01013e1 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013a8:	c1 e8 0c             	shr    $0xc,%eax
f01013ab:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f01013b1:	72 1c                	jb     f01013cf <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01013b3:	c7 44 24 08 a0 7d 10 	movl   $0xf0107da0,0x8(%esp)
f01013ba:	f0 
f01013bb:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01013c2:	00 
f01013c3:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f01013ca:	e8 71 ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01013cf:	8b 15 90 fe 23 f0    	mov    0xf023fe90,%edx
f01013d5:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page( PTE_ADDR( ( *ptr) ) ) ;
f01013d8:	eb 0c                	jmp    f01013e6 <page_lookup+0x72>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t * ptr = pgdir_walk( pgdir , va , false ) ;
	if ( ptr == NULL ) return NULL ;
f01013da:	b8 00 00 00 00       	mov    $0x0,%eax
f01013df:	eb 05                	jmp    f01013e6 <page_lookup+0x72>
	if ( pte_store != NULL )  
		(*pte_store) = ptr ; 
	if ( ! (  ( * ptr ) & PTE_P ) ) return NULL ;
f01013e1:	b8 00 00 00 00       	mov    $0x0,%eax
	return pa2page( PTE_ADDR( ( *ptr) ) ) ;
}
f01013e6:	83 c4 14             	add    $0x14,%esp
f01013e9:	5b                   	pop    %ebx
f01013ea:	5d                   	pop    %ebp
f01013eb:	c3                   	ret    

f01013ec <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01013ec:	55                   	push   %ebp
f01013ed:	89 e5                	mov    %esp,%ebp
f01013ef:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01013f2:	e8 c2 5b 00 00       	call   f0106fb9 <cpunum>
f01013f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01013fa:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0101401:	74 16                	je     f0101419 <tlb_invalidate+0x2d>
f0101403:	e8 b1 5b 00 00       	call   f0106fb9 <cpunum>
f0101408:	6b c0 74             	imul   $0x74,%eax,%eax
f010140b:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0101411:	8b 55 08             	mov    0x8(%ebp),%edx
f0101414:	39 50 60             	cmp    %edx,0x60(%eax)
f0101417:	75 06                	jne    f010141f <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101419:	8b 45 0c             	mov    0xc(%ebp),%eax
f010141c:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010141f:	c9                   	leave  
f0101420:	c3                   	ret    

f0101421 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101421:	55                   	push   %ebp
f0101422:	89 e5                	mov    %esp,%ebp
f0101424:	56                   	push   %esi
f0101425:	53                   	push   %ebx
f0101426:	83 ec 20             	sub    $0x20,%esp
f0101429:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010142c:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t * ptr = NULL ; 
f010142f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * page_cur = page_lookup( pgdir , va , &ptr ) ; 
f0101436:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101439:	89 44 24 08          	mov    %eax,0x8(%esp)
f010143d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101441:	89 1c 24             	mov    %ebx,(%esp)
f0101444:	e8 2b ff ff ff       	call   f0101374 <page_lookup>
	if ( page_cur == NULL ) return ;
f0101449:	85 c0                	test   %eax,%eax
f010144b:	74 1d                	je     f010146a <page_remove+0x49>
 	(*ptr) = 0 ; 	
f010144d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101450:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(page_cur);
f0101456:	89 04 24             	mov    %eax,(%esp)
f0101459:	e8 f2 fd ff ff       	call   f0101250 <page_decref>
	tlb_invalidate( pgdir , va ) ;
f010145e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101462:	89 1c 24             	mov    %ebx,(%esp)
f0101465:	e8 82 ff ff ff       	call   f01013ec <tlb_invalidate>
}
f010146a:	83 c4 20             	add    $0x20,%esp
f010146d:	5b                   	pop    %ebx
f010146e:	5e                   	pop    %esi
f010146f:	5d                   	pop    %ebp
f0101470:	c3                   	ret    

f0101471 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101471:	55                   	push   %ebp
f0101472:	89 e5                	mov    %esp,%ebp
f0101474:	57                   	push   %edi
f0101475:	56                   	push   %esi
f0101476:	53                   	push   %ebx
f0101477:	83 ec 1c             	sub    $0x1c,%esp
f010147a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010147d:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t * ptr = pgdir_walk( pgdir , va , true ) ;
f0101480:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101487:	00 
f0101488:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010148c:	8b 45 08             	mov    0x8(%ebp),%eax
f010148f:	89 04 24             	mov    %eax,(%esp)
f0101492:	e8 dc fd ff ff       	call   f0101273 <pgdir_walk>
f0101497:	89 c3                	mov    %eax,%ebx
	if ( ptr == NULL ) return -E_NO_MEM ;
f0101499:	85 c0                	test   %eax,%eax
f010149b:	74 36                	je     f01014d3 <page_insert+0x62>
	(pp->pp_ref) ++ ; 
f010149d:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if ( ( * ptr ) & PTE_P ) page_remove( pgdir , va ) ;
f01014a2:	f6 00 01             	testb  $0x1,(%eax)
f01014a5:	74 0f                	je     f01014b6 <page_insert+0x45>
f01014a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ae:	89 04 24             	mov    %eax,(%esp)
f01014b1:	e8 6b ff ff ff       	call   f0101421 <page_remove>
	( * ptr ) = page2pa(pp) | perm | PTE_P; 	
f01014b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01014b9:	83 c8 01             	or     $0x1,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014bc:	2b 35 90 fe 23 f0    	sub    0xf023fe90,%esi
f01014c2:	c1 fe 03             	sar    $0x3,%esi
f01014c5:	c1 e6 0c             	shl    $0xc,%esi
f01014c8:	09 c6                	or     %eax,%esi
f01014ca:	89 33                	mov    %esi,(%ebx)
	return 0;
f01014cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01014d1:	eb 05                	jmp    f01014d8 <page_insert+0x67>
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t * ptr = pgdir_walk( pgdir , va , true ) ;
	if ( ptr == NULL ) return -E_NO_MEM ;
f01014d3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	(pp->pp_ref) ++ ; 
	if ( ( * ptr ) & PTE_P ) page_remove( pgdir , va ) ;
	( * ptr ) = page2pa(pp) | perm | PTE_P; 	
	return 0;
}
f01014d8:	83 c4 1c             	add    $0x1c,%esp
f01014db:	5b                   	pop    %ebx
f01014dc:	5e                   	pop    %esi
f01014dd:	5f                   	pop    %edi
f01014de:	5d                   	pop    %ebp
f01014df:	c3                   	ret    

f01014e0 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01014e0:	55                   	push   %ebp
f01014e1:	89 e5                	mov    %esp,%ebp
f01014e3:	53                   	push   %ebx
f01014e4:	83 ec 14             	sub    $0x14,%esp
f01014e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	if ( size & 0xFFF ) 
f01014ea:	89 ca                	mov    %ecx,%edx
f01014ec:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
		size += 0xFFF ; 
f01014f2:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f01014f8:	85 d2                	test   %edx,%edx
f01014fa:	0f 45 c8             	cmovne %eax,%ecx
	size = size & ( ~0xFFF ) ; 
f01014fd:	89 cb                	mov    %ecx,%ebx
f01014ff:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		
	if ( base + size > MMIOLIM ) 
f0101505:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f010150b:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010150e:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101513:	76 1c                	jbe    f0101531 <mmio_map_region+0x51>
		panic("mmio_map_region: reservation overflow MMIOLIM!\n");
f0101515:	c7 44 24 08 c0 7d 10 	movl   $0xf0107dc0,0x8(%esp)
f010151c:	f0 
f010151d:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0101524:	00 
f0101525:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010152c:	e8 0f eb ff ff       	call   f0100040 <_panic>
	boot_map_region( kern_pgdir , base , size , pa , PTE_PWT | PTE_PCD | PTE_W ); 
f0101531:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101538:	00 
f0101539:	8b 45 08             	mov    0x8(%ebp),%eax
f010153c:	89 04 24             	mov    %eax,(%esp)
f010153f:	89 d9                	mov    %ebx,%ecx
f0101541:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0101546:	e8 cb fd ff ff       	call   f0101316 <boot_map_region>
	
	uintptr_t tmp_base = base ;
f010154b:	a1 00 23 12 f0       	mov    0xf0122300,%eax
	base = (( uint32_t) base ) + size ;  
f0101550:	01 c3                	add    %eax,%ebx
f0101552:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
	return ( void * ) tmp_base ; 
	//panic("mmio_map_region not implemented");
}
f0101558:	83 c4 14             	add    $0x14,%esp
f010155b:	5b                   	pop    %ebx
f010155c:	5d                   	pop    %ebp
f010155d:	c3                   	ret    

f010155e <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010155e:	55                   	push   %ebp
f010155f:	89 e5                	mov    %esp,%ebp
f0101561:	57                   	push   %edi
f0101562:	56                   	push   %esi
f0101563:	53                   	push   %ebx
f0101564:	83 ec 4c             	sub    $0x4c,%esp

static __inline void
cpuid(uint32_t info, uint32_t *eaxp, uint32_t *ebxp, uint32_t *ecxp, uint32_t *edxp)
{
	uint32_t eax, ebx, ecx, edx;
	asm volatile("cpuid"
f0101567:	b8 01 00 00 00       	mov    $0x1,%eax
f010156c:	0f a2                	cpuid  
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010156e:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101575:	e8 66 29 00 00       	call   f0103ee0 <mc146818_read>
f010157a:	89 c3                	mov    %eax,%ebx
f010157c:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101583:	e8 58 29 00 00       	call   f0103ee0 <mc146818_read>
f0101588:	c1 e0 08             	shl    $0x8,%eax
f010158b:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010158d:	89 d8                	mov    %ebx,%eax
f010158f:	c1 e0 0a             	shl    $0xa,%eax
f0101592:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101598:	85 c0                	test   %eax,%eax
f010159a:	0f 48 c2             	cmovs  %edx,%eax
f010159d:	c1 f8 0c             	sar    $0xc,%eax
f01015a0:	a3 44 f2 23 f0       	mov    %eax,0xf023f244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01015a5:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01015ac:	e8 2f 29 00 00       	call   f0103ee0 <mc146818_read>
f01015b1:	89 c3                	mov    %eax,%ebx
f01015b3:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01015ba:	e8 21 29 00 00       	call   f0103ee0 <mc146818_read>
f01015bf:	c1 e0 08             	shl    $0x8,%eax
f01015c2:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01015c4:	89 d8                	mov    %ebx,%eax
f01015c6:	c1 e0 0a             	shl    $0xa,%eax
f01015c9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01015cf:	85 c0                	test   %eax,%eax
f01015d1:	0f 48 c2             	cmovs  %edx,%eax
f01015d4:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01015d7:	85 c0                	test   %eax,%eax
f01015d9:	74 0e                	je     f01015e9 <mem_init+0x8b>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01015db:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01015e1:	89 15 88 fe 23 f0    	mov    %edx,0xf023fe88
f01015e7:	eb 0c                	jmp    f01015f5 <mem_init+0x97>
	else
		npages = npages_basemem;
f01015e9:	8b 15 44 f2 23 f0    	mov    0xf023f244,%edx
f01015ef:	89 15 88 fe 23 f0    	mov    %edx,0xf023fe88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01015f5:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015f8:	c1 e8 0a             	shr    $0xa,%eax
f01015fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01015ff:	a1 44 f2 23 f0       	mov    0xf023f244,%eax
f0101604:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101607:	c1 e8 0a             	shr    $0xa,%eax
f010160a:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f010160e:	a1 88 fe 23 f0       	mov    0xf023fe88,%eax
f0101613:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101616:	c1 e8 0a             	shr    $0xa,%eax
f0101619:	89 44 24 04          	mov    %eax,0x4(%esp)
f010161d:	c7 04 24 f0 7d 10 f0 	movl   $0xf0107df0,(%esp)
f0101624:	e8 53 2a 00 00       	call   f010407c <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101629:	b8 00 10 00 00       	mov    $0x1000,%eax
f010162e:	e8 d3 f5 ff ff       	call   f0100c06 <boot_alloc>
f0101633:	a3 8c fe 23 f0       	mov    %eax,0xf023fe8c
	memset(kern_pgdir, 0, PGSIZE);
f0101638:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010163f:	00 
f0101640:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101647:	00 
f0101648:	89 04 24             	mov    %eax,(%esp)
f010164b:	e8 17 53 00 00       	call   f0106967 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101650:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101655:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010165a:	77 20                	ja     f010167c <mem_init+0x11e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010165c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101660:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0101667:	f0 
f0101668:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010166f:	00 
f0101670:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101677:	e8 c4 e9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010167c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101682:	83 ca 05             	or     $0x5,%edx
f0101685:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = ( struct PageInfo * ) boot_alloc( npages * sizeof( struct PageInfo ) ) ; 
f010168b:	a1 88 fe 23 f0       	mov    0xf023fe88,%eax
f0101690:	c1 e0 03             	shl    $0x3,%eax
f0101693:	e8 6e f5 ff ff       	call   f0100c06 <boot_alloc>
f0101698:	a3 90 fe 23 f0       	mov    %eax,0xf023fe90
	memset(pages, 0, ( sizeof ( struct PageInfo )) * npages ) ;
f010169d:	8b 0d 88 fe 23 f0    	mov    0xf023fe88,%ecx
f01016a3:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01016aa:	89 54 24 08          	mov    %edx,0x8(%esp)
f01016ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01016b5:	00 
f01016b6:	89 04 24             	mov    %eax,(%esp)
f01016b9:	e8 a9 52 00 00       	call   f0106967 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = ( struct Env * ) boot_alloc( sizeof( struct Env ) * NENV ) ; 
f01016be:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01016c3:	e8 3e f5 ff ff       	call   f0100c06 <boot_alloc>
f01016c8:	a3 48 f2 23 f0       	mov    %eax,0xf023f248
	memset( envs , 0 , sizeof( struct Env ) * NENV ) ; 
f01016cd:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f01016d4:	00 
f01016d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01016dc:	00 
f01016dd:	89 04 24             	mov    %eax,(%esp)
f01016e0:	e8 82 52 00 00       	call   f0106967 <memset>
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	
	page_init();
f01016e5:	e8 4c f9 ff ff       	call   f0101036 <page_init>
         
	check_page_free_list(1);
f01016ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01016ef:	e8 af f5 ff ff       	call   f0100ca3 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01016f4:	83 3d 90 fe 23 f0 00 	cmpl   $0x0,0xf023fe90
f01016fb:	75 1c                	jne    f0101719 <mem_init+0x1bb>
		panic("'pages' is a null pointer!");
f01016fd:	c7 44 24 08 dc 86 10 	movl   $0xf01086dc,0x8(%esp)
f0101704:	f0 
f0101705:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f010170c:	00 
f010170d:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101714:	e8 27 e9 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101719:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f010171e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101723:	eb 05                	jmp    f010172a <mem_init+0x1cc>
		++nfree;
f0101725:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101728:	8b 00                	mov    (%eax),%eax
f010172a:	85 c0                	test   %eax,%eax
f010172c:	75 f7                	jne    f0101725 <mem_init+0x1c7>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010172e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101735:	e8 2f fa ff ff       	call   f0101169 <page_alloc>
f010173a:	89 c7                	mov    %eax,%edi
f010173c:	85 c0                	test   %eax,%eax
f010173e:	75 24                	jne    f0101764 <mem_init+0x206>
f0101740:	c7 44 24 0c f7 86 10 	movl   $0xf01086f7,0xc(%esp)
f0101747:	f0 
f0101748:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010174f:	f0 
f0101750:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0101757:	00 
f0101758:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010175f:	e8 dc e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101764:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010176b:	e8 f9 f9 ff ff       	call   f0101169 <page_alloc>
f0101770:	89 c6                	mov    %eax,%esi
f0101772:	85 c0                	test   %eax,%eax
f0101774:	75 24                	jne    f010179a <mem_init+0x23c>
f0101776:	c7 44 24 0c 0d 87 10 	movl   $0xf010870d,0xc(%esp)
f010177d:	f0 
f010177e:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101785:	f0 
f0101786:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f010178d:	00 
f010178e:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101795:	e8 a6 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010179a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a1:	e8 c3 f9 ff ff       	call   f0101169 <page_alloc>
f01017a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017a9:	85 c0                	test   %eax,%eax
f01017ab:	75 24                	jne    f01017d1 <mem_init+0x273>
f01017ad:	c7 44 24 0c 23 87 10 	movl   $0xf0108723,0xc(%esp)
f01017b4:	f0 
f01017b5:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01017bc:	f0 
f01017bd:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f01017c4:	00 
f01017c5:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01017cc:	e8 6f e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017d1:	39 f7                	cmp    %esi,%edi
f01017d3:	75 24                	jne    f01017f9 <mem_init+0x29b>
f01017d5:	c7 44 24 0c 39 87 10 	movl   $0xf0108739,0xc(%esp)
f01017dc:	f0 
f01017dd:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01017e4:	f0 
f01017e5:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01017ec:	00 
f01017ed:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01017f4:	e8 47 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017fc:	39 c6                	cmp    %eax,%esi
f01017fe:	74 04                	je     f0101804 <mem_init+0x2a6>
f0101800:	39 c7                	cmp    %eax,%edi
f0101802:	75 24                	jne    f0101828 <mem_init+0x2ca>
f0101804:	c7 44 24 0c 2c 7e 10 	movl   $0xf0107e2c,0xc(%esp)
f010180b:	f0 
f010180c:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101813:	f0 
f0101814:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f010181b:	00 
f010181c:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101823:	e8 18 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101828:	8b 15 90 fe 23 f0    	mov    0xf023fe90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010182e:	a1 88 fe 23 f0       	mov    0xf023fe88,%eax
f0101833:	c1 e0 0c             	shl    $0xc,%eax
f0101836:	89 f9                	mov    %edi,%ecx
f0101838:	29 d1                	sub    %edx,%ecx
f010183a:	c1 f9 03             	sar    $0x3,%ecx
f010183d:	c1 e1 0c             	shl    $0xc,%ecx
f0101840:	39 c1                	cmp    %eax,%ecx
f0101842:	72 24                	jb     f0101868 <mem_init+0x30a>
f0101844:	c7 44 24 0c 4b 87 10 	movl   $0xf010874b,0xc(%esp)
f010184b:	f0 
f010184c:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101853:	f0 
f0101854:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f010185b:	00 
f010185c:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101863:	e8 d8 e7 ff ff       	call   f0100040 <_panic>
f0101868:	89 f1                	mov    %esi,%ecx
f010186a:	29 d1                	sub    %edx,%ecx
f010186c:	c1 f9 03             	sar    $0x3,%ecx
f010186f:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101872:	39 c8                	cmp    %ecx,%eax
f0101874:	77 24                	ja     f010189a <mem_init+0x33c>
f0101876:	c7 44 24 0c 68 87 10 	movl   $0xf0108768,0xc(%esp)
f010187d:	f0 
f010187e:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101885:	f0 
f0101886:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f010188d:	00 
f010188e:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101895:	e8 a6 e7 ff ff       	call   f0100040 <_panic>
f010189a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010189d:	29 d1                	sub    %edx,%ecx
f010189f:	89 ca                	mov    %ecx,%edx
f01018a1:	c1 fa 03             	sar    $0x3,%edx
f01018a4:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01018a7:	39 d0                	cmp    %edx,%eax
f01018a9:	77 24                	ja     f01018cf <mem_init+0x371>
f01018ab:	c7 44 24 0c 85 87 10 	movl   $0xf0108785,0xc(%esp)
f01018b2:	f0 
f01018b3:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01018ba:	f0 
f01018bb:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01018c2:	00 
f01018c3:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01018ca:	e8 71 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018cf:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f01018d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018d7:	c7 05 40 f2 23 f0 00 	movl   $0x0,0xf023f240
f01018de:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018e8:	e8 7c f8 ff ff       	call   f0101169 <page_alloc>
f01018ed:	85 c0                	test   %eax,%eax
f01018ef:	74 24                	je     f0101915 <mem_init+0x3b7>
f01018f1:	c7 44 24 0c a2 87 10 	movl   $0xf01087a2,0xc(%esp)
f01018f8:	f0 
f01018f9:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101900:	f0 
f0101901:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0101908:	00 
f0101909:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101910:	e8 2b e7 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101915:	89 3c 24             	mov    %edi,(%esp)
f0101918:	e8 d7 f8 ff ff       	call   f01011f4 <page_free>
	page_free(pp1);
f010191d:	89 34 24             	mov    %esi,(%esp)
f0101920:	e8 cf f8 ff ff       	call   f01011f4 <page_free>
	page_free(pp2);
f0101925:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101928:	89 04 24             	mov    %eax,(%esp)
f010192b:	e8 c4 f8 ff ff       	call   f01011f4 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101930:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101937:	e8 2d f8 ff ff       	call   f0101169 <page_alloc>
f010193c:	89 c6                	mov    %eax,%esi
f010193e:	85 c0                	test   %eax,%eax
f0101940:	75 24                	jne    f0101966 <mem_init+0x408>
f0101942:	c7 44 24 0c f7 86 10 	movl   $0xf01086f7,0xc(%esp)
f0101949:	f0 
f010194a:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101951:	f0 
f0101952:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101959:	00 
f010195a:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101961:	e8 da e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101966:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010196d:	e8 f7 f7 ff ff       	call   f0101169 <page_alloc>
f0101972:	89 c7                	mov    %eax,%edi
f0101974:	85 c0                	test   %eax,%eax
f0101976:	75 24                	jne    f010199c <mem_init+0x43e>
f0101978:	c7 44 24 0c 0d 87 10 	movl   $0xf010870d,0xc(%esp)
f010197f:	f0 
f0101980:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101987:	f0 
f0101988:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f010198f:	00 
f0101990:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101997:	e8 a4 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010199c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019a3:	e8 c1 f7 ff ff       	call   f0101169 <page_alloc>
f01019a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019ab:	85 c0                	test   %eax,%eax
f01019ad:	75 24                	jne    f01019d3 <mem_init+0x475>
f01019af:	c7 44 24 0c 23 87 10 	movl   $0xf0108723,0xc(%esp)
f01019b6:	f0 
f01019b7:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01019be:	f0 
f01019bf:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f01019c6:	00 
f01019c7:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01019ce:	e8 6d e6 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019d3:	39 fe                	cmp    %edi,%esi
f01019d5:	75 24                	jne    f01019fb <mem_init+0x49d>
f01019d7:	c7 44 24 0c 39 87 10 	movl   $0xf0108739,0xc(%esp)
f01019de:	f0 
f01019df:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01019e6:	f0 
f01019e7:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f01019ee:	00 
f01019ef:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01019f6:	e8 45 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019fe:	39 c7                	cmp    %eax,%edi
f0101a00:	74 04                	je     f0101a06 <mem_init+0x4a8>
f0101a02:	39 c6                	cmp    %eax,%esi
f0101a04:	75 24                	jne    f0101a2a <mem_init+0x4cc>
f0101a06:	c7 44 24 0c 2c 7e 10 	movl   $0xf0107e2c,0xc(%esp)
f0101a0d:	f0 
f0101a0e:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101a15:	f0 
f0101a16:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101a1d:	00 
f0101a1e:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101a25:	e8 16 e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101a2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a31:	e8 33 f7 ff ff       	call   f0101169 <page_alloc>
f0101a36:	85 c0                	test   %eax,%eax
f0101a38:	74 24                	je     f0101a5e <mem_init+0x500>
f0101a3a:	c7 44 24 0c a2 87 10 	movl   $0xf01087a2,0xc(%esp)
f0101a41:	f0 
f0101a42:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101a49:	f0 
f0101a4a:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0101a51:	00 
f0101a52:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101a59:	e8 e2 e5 ff ff       	call   f0100040 <_panic>
f0101a5e:	89 f0                	mov    %esi,%eax
f0101a60:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0101a66:	c1 f8 03             	sar    $0x3,%eax
f0101a69:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a6c:	89 c2                	mov    %eax,%edx
f0101a6e:	c1 ea 0c             	shr    $0xc,%edx
f0101a71:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0101a77:	72 20                	jb     f0101a99 <mem_init+0x53b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a7d:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0101a84:	f0 
f0101a85:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101a8c:	00 
f0101a8d:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0101a94:	e8 a7 e5 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101a99:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101aa0:	00 
f0101aa1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101aa8:	00 
	return (void *)(pa + KERNBASE);
f0101aa9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101aae:	89 04 24             	mov    %eax,(%esp)
f0101ab1:	e8 b1 4e 00 00       	call   f0106967 <memset>
	page_free(pp0);
f0101ab6:	89 34 24             	mov    %esi,(%esp)
f0101ab9:	e8 36 f7 ff ff       	call   f01011f4 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101abe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101ac5:	e8 9f f6 ff ff       	call   f0101169 <page_alloc>
f0101aca:	85 c0                	test   %eax,%eax
f0101acc:	75 24                	jne    f0101af2 <mem_init+0x594>
f0101ace:	c7 44 24 0c b1 87 10 	movl   $0xf01087b1,0xc(%esp)
f0101ad5:	f0 
f0101ad6:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101add:	f0 
f0101ade:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101ae5:	00 
f0101ae6:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101aed:	e8 4e e5 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101af2:	39 c6                	cmp    %eax,%esi
f0101af4:	74 24                	je     f0101b1a <mem_init+0x5bc>
f0101af6:	c7 44 24 0c cf 87 10 	movl   $0xf01087cf,0xc(%esp)
f0101afd:	f0 
f0101afe:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101b05:	f0 
f0101b06:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101b0d:	00 
f0101b0e:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101b15:	e8 26 e5 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b1a:	89 f0                	mov    %esi,%eax
f0101b1c:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0101b22:	c1 f8 03             	sar    $0x3,%eax
f0101b25:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b28:	89 c2                	mov    %eax,%edx
f0101b2a:	c1 ea 0c             	shr    $0xc,%edx
f0101b2d:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0101b33:	72 20                	jb     f0101b55 <mem_init+0x5f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b35:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b39:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0101b40:	f0 
f0101b41:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101b48:	00 
f0101b49:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0101b50:	e8 eb e4 ff ff       	call   f0100040 <_panic>
f0101b55:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101b5b:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b61:	80 38 00             	cmpb   $0x0,(%eax)
f0101b64:	74 24                	je     f0101b8a <mem_init+0x62c>
f0101b66:	c7 44 24 0c df 87 10 	movl   $0xf01087df,0xc(%esp)
f0101b6d:	f0 
f0101b6e:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101b75:	f0 
f0101b76:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101b7d:	00 
f0101b7e:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101b85:	e8 b6 e4 ff ff       	call   f0100040 <_panic>
f0101b8a:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101b8d:	39 d0                	cmp    %edx,%eax
f0101b8f:	75 d0                	jne    f0101b61 <mem_init+0x603>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b91:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b94:	a3 40 f2 23 f0       	mov    %eax,0xf023f240

	// free the pages we took
	page_free(pp0);
f0101b99:	89 34 24             	mov    %esi,(%esp)
f0101b9c:	e8 53 f6 ff ff       	call   f01011f4 <page_free>
	page_free(pp1);
f0101ba1:	89 3c 24             	mov    %edi,(%esp)
f0101ba4:	e8 4b f6 ff ff       	call   f01011f4 <page_free>
	page_free(pp2);
f0101ba9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bac:	89 04 24             	mov    %eax,(%esp)
f0101baf:	e8 40 f6 ff ff       	call   f01011f4 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bb4:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f0101bb9:	eb 05                	jmp    f0101bc0 <mem_init+0x662>
		--nfree;
f0101bbb:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bbe:	8b 00                	mov    (%eax),%eax
f0101bc0:	85 c0                	test   %eax,%eax
f0101bc2:	75 f7                	jne    f0101bbb <mem_init+0x65d>
		--nfree;
	assert(nfree == 0);
f0101bc4:	85 db                	test   %ebx,%ebx
f0101bc6:	74 24                	je     f0101bec <mem_init+0x68e>
f0101bc8:	c7 44 24 0c e9 87 10 	movl   $0xf01087e9,0xc(%esp)
f0101bcf:	f0 
f0101bd0:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101bd7:	f0 
f0101bd8:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101bdf:	00 
f0101be0:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101be7:	e8 54 e4 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101bec:	c7 04 24 4c 7e 10 f0 	movl   $0xf0107e4c,(%esp)
f0101bf3:	e8 84 24 00 00       	call   f010407c <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101bf8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bff:	e8 65 f5 ff ff       	call   f0101169 <page_alloc>
f0101c04:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c07:	85 c0                	test   %eax,%eax
f0101c09:	75 24                	jne    f0101c2f <mem_init+0x6d1>
f0101c0b:	c7 44 24 0c f7 86 10 	movl   $0xf01086f7,0xc(%esp)
f0101c12:	f0 
f0101c13:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101c1a:	f0 
f0101c1b:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0101c22:	00 
f0101c23:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101c2a:	e8 11 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c36:	e8 2e f5 ff ff       	call   f0101169 <page_alloc>
f0101c3b:	89 c3                	mov    %eax,%ebx
f0101c3d:	85 c0                	test   %eax,%eax
f0101c3f:	75 24                	jne    f0101c65 <mem_init+0x707>
f0101c41:	c7 44 24 0c 0d 87 10 	movl   $0xf010870d,0xc(%esp)
f0101c48:	f0 
f0101c49:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101c50:	f0 
f0101c51:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101c58:	00 
f0101c59:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101c60:	e8 db e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c6c:	e8 f8 f4 ff ff       	call   f0101169 <page_alloc>
f0101c71:	89 c6                	mov    %eax,%esi
f0101c73:	85 c0                	test   %eax,%eax
f0101c75:	75 24                	jne    f0101c9b <mem_init+0x73d>
f0101c77:	c7 44 24 0c 23 87 10 	movl   $0xf0108723,0xc(%esp)
f0101c7e:	f0 
f0101c7f:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101c86:	f0 
f0101c87:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101c8e:	00 
f0101c8f:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101c96:	e8 a5 e3 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c9b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101c9e:	75 24                	jne    f0101cc4 <mem_init+0x766>
f0101ca0:	c7 44 24 0c 39 87 10 	movl   $0xf0108739,0xc(%esp)
f0101ca7:	f0 
f0101ca8:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101caf:	f0 
f0101cb0:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101cb7:	00 
f0101cb8:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101cbf:	e8 7c e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cc4:	39 c3                	cmp    %eax,%ebx
f0101cc6:	74 05                	je     f0101ccd <mem_init+0x76f>
f0101cc8:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101ccb:	75 24                	jne    f0101cf1 <mem_init+0x793>
f0101ccd:	c7 44 24 0c 2c 7e 10 	movl   $0xf0107e2c,0xc(%esp)
f0101cd4:	f0 
f0101cd5:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101cdc:	f0 
f0101cdd:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0101ce4:	00 
f0101ce5:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101cec:	e8 4f e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101cf1:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f0101cf6:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101cf9:	c7 05 40 f2 23 f0 00 	movl   $0x0,0xf023f240
f0101d00:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d0a:	e8 5a f4 ff ff       	call   f0101169 <page_alloc>
f0101d0f:	85 c0                	test   %eax,%eax
f0101d11:	74 24                	je     f0101d37 <mem_init+0x7d9>
f0101d13:	c7 44 24 0c a2 87 10 	movl   $0xf01087a2,0xc(%esp)
f0101d1a:	f0 
f0101d1b:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f0101d2a:	00 
f0101d2b:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101d32:	e8 09 e3 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d37:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d3a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101d3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101d45:	00 
f0101d46:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0101d4b:	89 04 24             	mov    %eax,(%esp)
f0101d4e:	e8 21 f6 ff ff       	call   f0101374 <page_lookup>
f0101d53:	85 c0                	test   %eax,%eax
f0101d55:	74 24                	je     f0101d7b <mem_init+0x81d>
f0101d57:	c7 44 24 0c 6c 7e 10 	movl   $0xf0107e6c,0xc(%esp)
f0101d5e:	f0 
f0101d5f:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101d66:	f0 
f0101d67:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101d6e:	00 
f0101d6f:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101d76:	e8 c5 e2 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d7b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d82:	00 
f0101d83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d8a:	00 
f0101d8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d8f:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0101d94:	89 04 24             	mov    %eax,(%esp)
f0101d97:	e8 d5 f6 ff ff       	call   f0101471 <page_insert>
f0101d9c:	85 c0                	test   %eax,%eax
f0101d9e:	78 24                	js     f0101dc4 <mem_init+0x866>
f0101da0:	c7 44 24 0c a4 7e 10 	movl   $0xf0107ea4,0xc(%esp)
f0101da7:	f0 
f0101da8:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101daf:	f0 
f0101db0:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101db7:	00 
f0101db8:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101dbf:	e8 7c e2 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101dc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc7:	89 04 24             	mov    %eax,(%esp)
f0101dca:	e8 25 f4 ff ff       	call   f01011f4 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101dcf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dd6:	00 
f0101dd7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101dde:	00 
f0101ddf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101de3:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0101de8:	89 04 24             	mov    %eax,(%esp)
f0101deb:	e8 81 f6 ff ff       	call   f0101471 <page_insert>
f0101df0:	85 c0                	test   %eax,%eax
f0101df2:	74 24                	je     f0101e18 <mem_init+0x8ba>
f0101df4:	c7 44 24 0c d4 7e 10 	movl   $0xf0107ed4,0xc(%esp)
f0101dfb:	f0 
f0101dfc:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101e03:	f0 
f0101e04:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101e0b:	00 
f0101e0c:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101e13:	e8 28 e2 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e18:	8b 3d 8c fe 23 f0    	mov    0xf023fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e1e:	a1 90 fe 23 f0       	mov    0xf023fe90,%eax
f0101e23:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e26:	8b 17                	mov    (%edi),%edx
f0101e28:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e2e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e31:	29 c1                	sub    %eax,%ecx
f0101e33:	89 c8                	mov    %ecx,%eax
f0101e35:	c1 f8 03             	sar    $0x3,%eax
f0101e38:	c1 e0 0c             	shl    $0xc,%eax
f0101e3b:	39 c2                	cmp    %eax,%edx
f0101e3d:	74 24                	je     f0101e63 <mem_init+0x905>
f0101e3f:	c7 44 24 0c 04 7f 10 	movl   $0xf0107f04,0xc(%esp)
f0101e46:	f0 
f0101e47:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101e4e:	f0 
f0101e4f:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0101e56:	00 
f0101e57:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101e5e:	e8 dd e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e63:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e68:	89 f8                	mov    %edi,%eax
f0101e6a:	e8 16 ed ff ff       	call   f0100b85 <check_va2pa>
f0101e6f:	89 da                	mov    %ebx,%edx
f0101e71:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101e74:	c1 fa 03             	sar    $0x3,%edx
f0101e77:	c1 e2 0c             	shl    $0xc,%edx
f0101e7a:	39 d0                	cmp    %edx,%eax
f0101e7c:	74 24                	je     f0101ea2 <mem_init+0x944>
f0101e7e:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f0101e85:	f0 
f0101e86:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101e8d:	f0 
f0101e8e:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0101e95:	00 
f0101e96:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101e9d:	e8 9e e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ea2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ea7:	74 24                	je     f0101ecd <mem_init+0x96f>
f0101ea9:	c7 44 24 0c f4 87 10 	movl   $0xf01087f4,0xc(%esp)
f0101eb0:	f0 
f0101eb1:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101eb8:	f0 
f0101eb9:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101ec0:	00 
f0101ec1:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101ec8:	e8 73 e1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ecd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ed0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ed5:	74 24                	je     f0101efb <mem_init+0x99d>
f0101ed7:	c7 44 24 0c 05 88 10 	movl   $0xf0108805,0xc(%esp)
f0101ede:	f0 
f0101edf:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101ee6:	f0 
f0101ee7:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101eee:	00 
f0101eef:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101ef6:	e8 45 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
        assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101efb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f02:	00 
f0101f03:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f0a:	00 
f0101f0b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f0f:	89 3c 24             	mov    %edi,(%esp)
f0101f12:	e8 5a f5 ff ff       	call   f0101471 <page_insert>
f0101f17:	85 c0                	test   %eax,%eax
f0101f19:	74 24                	je     f0101f3f <mem_init+0x9e1>
f0101f1b:	c7 44 24 0c 5c 7f 10 	movl   $0xf0107f5c,0xc(%esp)
f0101f22:	f0 
f0101f23:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101f2a:	f0 
f0101f2b:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101f32:	00 
f0101f33:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101f3a:	e8 01 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f3f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f44:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0101f49:	e8 37 ec ff ff       	call   f0100b85 <check_va2pa>
f0101f4e:	89 f2                	mov    %esi,%edx
f0101f50:	2b 15 90 fe 23 f0    	sub    0xf023fe90,%edx
f0101f56:	c1 fa 03             	sar    $0x3,%edx
f0101f59:	c1 e2 0c             	shl    $0xc,%edx
f0101f5c:	39 d0                	cmp    %edx,%eax
f0101f5e:	74 24                	je     f0101f84 <mem_init+0xa26>
f0101f60:	c7 44 24 0c 98 7f 10 	movl   $0xf0107f98,0xc(%esp)
f0101f67:	f0 
f0101f68:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101f6f:	f0 
f0101f70:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101f77:	00 
f0101f78:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101f7f:	e8 bc e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f84:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f89:	74 24                	je     f0101faf <mem_init+0xa51>
f0101f8b:	c7 44 24 0c 16 88 10 	movl   $0xf0108816,0xc(%esp)
f0101f92:	f0 
f0101f93:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101f9a:	f0 
f0101f9b:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101fa2:	00 
f0101fa3:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101faa:	e8 91 e0 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101faf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fb6:	e8 ae f1 ff ff       	call   f0101169 <page_alloc>
f0101fbb:	85 c0                	test   %eax,%eax
f0101fbd:	74 24                	je     f0101fe3 <mem_init+0xa85>
f0101fbf:	c7 44 24 0c a2 87 10 	movl   $0xf01087a2,0xc(%esp)
f0101fc6:	f0 
f0101fc7:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0101fce:	f0 
f0101fcf:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101fd6:	00 
f0101fd7:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0101fde:	e8 5d e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
        assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fe3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fea:	00 
f0101feb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ff2:	00 
f0101ff3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ff7:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0101ffc:	89 04 24             	mov    %eax,(%esp)
f0101fff:	e8 6d f4 ff ff       	call   f0101471 <page_insert>
f0102004:	85 c0                	test   %eax,%eax
f0102006:	74 24                	je     f010202c <mem_init+0xace>
f0102008:	c7 44 24 0c 5c 7f 10 	movl   $0xf0107f5c,0xc(%esp)
f010200f:	f0 
f0102010:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102017:	f0 
f0102018:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f010201f:	00 
f0102020:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102027:	e8 14 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010202c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102031:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102036:	e8 4a eb ff ff       	call   f0100b85 <check_va2pa>
f010203b:	89 f2                	mov    %esi,%edx
f010203d:	2b 15 90 fe 23 f0    	sub    0xf023fe90,%edx
f0102043:	c1 fa 03             	sar    $0x3,%edx
f0102046:	c1 e2 0c             	shl    $0xc,%edx
f0102049:	39 d0                	cmp    %edx,%eax
f010204b:	74 24                	je     f0102071 <mem_init+0xb13>
f010204d:	c7 44 24 0c 98 7f 10 	movl   $0xf0107f98,0xc(%esp)
f0102054:	f0 
f0102055:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010205c:	f0 
f010205d:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102064:	00 
f0102065:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010206c:	e8 cf df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102071:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102076:	74 24                	je     f010209c <mem_init+0xb3e>
f0102078:	c7 44 24 0c 16 88 10 	movl   $0xf0108816,0xc(%esp)
f010207f:	f0 
f0102080:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102087:	f0 
f0102088:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f010208f:	00 
f0102090:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102097:	e8 a4 df ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010209c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020a3:	e8 c1 f0 ff ff       	call   f0101169 <page_alloc>
f01020a8:	85 c0                	test   %eax,%eax
f01020aa:	74 24                	je     f01020d0 <mem_init+0xb72>
f01020ac:	c7 44 24 0c a2 87 10 	movl   $0xf01087a2,0xc(%esp)
f01020b3:	f0 
f01020b4:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01020bb:	f0 
f01020bc:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f01020c3:	00 
f01020c4:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01020cb:	e8 70 df ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01020d0:	8b 15 8c fe 23 f0    	mov    0xf023fe8c,%edx
f01020d6:	8b 02                	mov    (%edx),%eax
f01020d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020dd:	89 c1                	mov    %eax,%ecx
f01020df:	c1 e9 0c             	shr    $0xc,%ecx
f01020e2:	3b 0d 88 fe 23 f0    	cmp    0xf023fe88,%ecx
f01020e8:	72 20                	jb     f010210a <mem_init+0xbac>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020ee:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f01020f5:	f0 
f01020f6:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f01020fd:	00 
f01020fe:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102105:	e8 36 df ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010210a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010210f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102112:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102119:	00 
f010211a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102121:	00 
f0102122:	89 14 24             	mov    %edx,(%esp)
f0102125:	e8 49 f1 ff ff       	call   f0101273 <pgdir_walk>
f010212a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010212d:	8d 51 04             	lea    0x4(%ecx),%edx
f0102130:	39 d0                	cmp    %edx,%eax
f0102132:	74 24                	je     f0102158 <mem_init+0xbfa>
f0102134:	c7 44 24 0c c8 7f 10 	movl   $0xf0107fc8,0xc(%esp)
f010213b:	f0 
f010213c:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102143:	f0 
f0102144:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f010214b:	00 
f010214c:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102153:	e8 e8 de ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102158:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010215f:	00 
f0102160:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102167:	00 
f0102168:	89 74 24 04          	mov    %esi,0x4(%esp)
f010216c:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102171:	89 04 24             	mov    %eax,(%esp)
f0102174:	e8 f8 f2 ff ff       	call   f0101471 <page_insert>
f0102179:	85 c0                	test   %eax,%eax
f010217b:	74 24                	je     f01021a1 <mem_init+0xc43>
f010217d:	c7 44 24 0c 08 80 10 	movl   $0xf0108008,0xc(%esp)
f0102184:	f0 
f0102185:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010218c:	f0 
f010218d:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102194:	00 
f0102195:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010219c:	e8 9f de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021a1:	8b 3d 8c fe 23 f0    	mov    0xf023fe8c,%edi
f01021a7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021ac:	89 f8                	mov    %edi,%eax
f01021ae:	e8 d2 e9 ff ff       	call   f0100b85 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021b3:	89 f2                	mov    %esi,%edx
f01021b5:	2b 15 90 fe 23 f0    	sub    0xf023fe90,%edx
f01021bb:	c1 fa 03             	sar    $0x3,%edx
f01021be:	c1 e2 0c             	shl    $0xc,%edx
f01021c1:	39 d0                	cmp    %edx,%eax
f01021c3:	74 24                	je     f01021e9 <mem_init+0xc8b>
f01021c5:	c7 44 24 0c 98 7f 10 	movl   $0xf0107f98,0xc(%esp)
f01021cc:	f0 
f01021cd:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01021d4:	f0 
f01021d5:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f01021dc:	00 
f01021dd:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01021e4:	e8 57 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01021e9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021ee:	74 24                	je     f0102214 <mem_init+0xcb6>
f01021f0:	c7 44 24 0c 16 88 10 	movl   $0xf0108816,0xc(%esp)
f01021f7:	f0 
f01021f8:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01021ff:	f0 
f0102200:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102207:	00 
f0102208:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010220f:	e8 2c de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102214:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010221b:	00 
f010221c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102223:	00 
f0102224:	89 3c 24             	mov    %edi,(%esp)
f0102227:	e8 47 f0 ff ff       	call   f0101273 <pgdir_walk>
f010222c:	f6 00 04             	testb  $0x4,(%eax)
f010222f:	75 24                	jne    f0102255 <mem_init+0xcf7>
f0102231:	c7 44 24 0c 48 80 10 	movl   $0xf0108048,0xc(%esp)
f0102238:	f0 
f0102239:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102240:	f0 
f0102241:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0102248:	00 
f0102249:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102250:	e8 eb dd ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102255:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f010225a:	f6 00 04             	testb  $0x4,(%eax)
f010225d:	75 24                	jne    f0102283 <mem_init+0xd25>
f010225f:	c7 44 24 0c 27 88 10 	movl   $0xf0108827,0xc(%esp)
f0102266:	f0 
f0102267:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010226e:	f0 
f010226f:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102276:	00 
f0102277:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010227e:	e8 bd dd ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102283:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010228a:	00 
f010228b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102292:	00 
f0102293:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102297:	89 04 24             	mov    %eax,(%esp)
f010229a:	e8 d2 f1 ff ff       	call   f0101471 <page_insert>
f010229f:	85 c0                	test   %eax,%eax
f01022a1:	74 24                	je     f01022c7 <mem_init+0xd69>
f01022a3:	c7 44 24 0c 5c 7f 10 	movl   $0xf0107f5c,0xc(%esp)
f01022aa:	f0 
f01022ab:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01022b2:	f0 
f01022b3:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01022ba:	00 
f01022bb:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01022c2:	e8 79 dd ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01022c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022ce:	00 
f01022cf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022d6:	00 
f01022d7:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f01022dc:	89 04 24             	mov    %eax,(%esp)
f01022df:	e8 8f ef ff ff       	call   f0101273 <pgdir_walk>
f01022e4:	f6 00 02             	testb  $0x2,(%eax)
f01022e7:	75 24                	jne    f010230d <mem_init+0xdaf>
f01022e9:	c7 44 24 0c 7c 80 10 	movl   $0xf010807c,0xc(%esp)
f01022f0:	f0 
f01022f1:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01022f8:	f0 
f01022f9:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102300:	00 
f0102301:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102308:	e8 33 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010230d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102314:	00 
f0102315:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010231c:	00 
f010231d:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102322:	89 04 24             	mov    %eax,(%esp)
f0102325:	e8 49 ef ff ff       	call   f0101273 <pgdir_walk>
f010232a:	f6 00 04             	testb  $0x4,(%eax)
f010232d:	74 24                	je     f0102353 <mem_init+0xdf5>
f010232f:	c7 44 24 0c b0 80 10 	movl   $0xf01080b0,0xc(%esp)
f0102336:	f0 
f0102337:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010233e:	f0 
f010233f:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102346:	00 
f0102347:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010234e:	e8 ed dc ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102353:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010235a:	00 
f010235b:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102362:	00 
f0102363:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102366:	89 44 24 04          	mov    %eax,0x4(%esp)
f010236a:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f010236f:	89 04 24             	mov    %eax,(%esp)
f0102372:	e8 fa f0 ff ff       	call   f0101471 <page_insert>
f0102377:	85 c0                	test   %eax,%eax
f0102379:	78 24                	js     f010239f <mem_init+0xe41>
f010237b:	c7 44 24 0c e8 80 10 	movl   $0xf01080e8,0xc(%esp)
f0102382:	f0 
f0102383:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010238a:	f0 
f010238b:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102392:	00 
f0102393:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010239a:	e8 a1 dc ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010239f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023a6:	00 
f01023a7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023ae:	00 
f01023af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01023b3:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f01023b8:	89 04 24             	mov    %eax,(%esp)
f01023bb:	e8 b1 f0 ff ff       	call   f0101471 <page_insert>
f01023c0:	85 c0                	test   %eax,%eax
f01023c2:	74 24                	je     f01023e8 <mem_init+0xe8a>
f01023c4:	c7 44 24 0c 20 81 10 	movl   $0xf0108120,0xc(%esp)
f01023cb:	f0 
f01023cc:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01023d3:	f0 
f01023d4:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01023db:	00 
f01023dc:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01023e3:	e8 58 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023e8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023ef:	00 
f01023f0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023f7:	00 
f01023f8:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f01023fd:	89 04 24             	mov    %eax,(%esp)
f0102400:	e8 6e ee ff ff       	call   f0101273 <pgdir_walk>
f0102405:	f6 00 04             	testb  $0x4,(%eax)
f0102408:	74 24                	je     f010242e <mem_init+0xed0>
f010240a:	c7 44 24 0c b0 80 10 	movl   $0xf01080b0,0xc(%esp)
f0102411:	f0 
f0102412:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102419:	f0 
f010241a:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102421:	00 
f0102422:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102429:	e8 12 dc ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010242e:	8b 3d 8c fe 23 f0    	mov    0xf023fe8c,%edi
f0102434:	ba 00 00 00 00       	mov    $0x0,%edx
f0102439:	89 f8                	mov    %edi,%eax
f010243b:	e8 45 e7 ff ff       	call   f0100b85 <check_va2pa>
f0102440:	89 c1                	mov    %eax,%ecx
f0102442:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102445:	89 d8                	mov    %ebx,%eax
f0102447:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f010244d:	c1 f8 03             	sar    $0x3,%eax
f0102450:	c1 e0 0c             	shl    $0xc,%eax
f0102453:	39 c1                	cmp    %eax,%ecx
f0102455:	74 24                	je     f010247b <mem_init+0xf1d>
f0102457:	c7 44 24 0c 5c 81 10 	movl   $0xf010815c,0xc(%esp)
f010245e:	f0 
f010245f:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102466:	f0 
f0102467:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f010246e:	00 
f010246f:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102476:	e8 c5 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010247b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102480:	89 f8                	mov    %edi,%eax
f0102482:	e8 fe e6 ff ff       	call   f0100b85 <check_va2pa>
f0102487:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010248a:	74 24                	je     f01024b0 <mem_init+0xf52>
f010248c:	c7 44 24 0c 88 81 10 	movl   $0xf0108188,0xc(%esp)
f0102493:	f0 
f0102494:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010249b:	f0 
f010249c:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01024a3:	00 
f01024a4:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01024ab:	e8 90 db ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01024b0:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01024b5:	74 24                	je     f01024db <mem_init+0xf7d>
f01024b7:	c7 44 24 0c 3d 88 10 	movl   $0xf010883d,0xc(%esp)
f01024be:	f0 
f01024bf:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01024c6:	f0 
f01024c7:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01024ce:	00 
f01024cf:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01024d6:	e8 65 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01024db:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01024e0:	74 24                	je     f0102506 <mem_init+0xfa8>
f01024e2:	c7 44 24 0c 4e 88 10 	movl   $0xf010884e,0xc(%esp)
f01024e9:	f0 
f01024ea:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01024f1:	f0 
f01024f2:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f01024f9:	00 
f01024fa:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102501:	e8 3a db ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102506:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010250d:	e8 57 ec ff ff       	call   f0101169 <page_alloc>
f0102512:	85 c0                	test   %eax,%eax
f0102514:	74 04                	je     f010251a <mem_init+0xfbc>
f0102516:	39 c6                	cmp    %eax,%esi
f0102518:	74 24                	je     f010253e <mem_init+0xfe0>
f010251a:	c7 44 24 0c b8 81 10 	movl   $0xf01081b8,0xc(%esp)
f0102521:	f0 
f0102522:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102529:	f0 
f010252a:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102531:	00 
f0102532:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102539:	e8 02 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010253e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102545:	00 
f0102546:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f010254b:	89 04 24             	mov    %eax,(%esp)
f010254e:	e8 ce ee ff ff       	call   f0101421 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102553:	8b 3d 8c fe 23 f0    	mov    0xf023fe8c,%edi
f0102559:	ba 00 00 00 00       	mov    $0x0,%edx
f010255e:	89 f8                	mov    %edi,%eax
f0102560:	e8 20 e6 ff ff       	call   f0100b85 <check_va2pa>
f0102565:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102568:	74 24                	je     f010258e <mem_init+0x1030>
f010256a:	c7 44 24 0c dc 81 10 	movl   $0xf01081dc,0xc(%esp)
f0102571:	f0 
f0102572:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102579:	f0 
f010257a:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f0102581:	00 
f0102582:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102589:	e8 b2 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010258e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102593:	89 f8                	mov    %edi,%eax
f0102595:	e8 eb e5 ff ff       	call   f0100b85 <check_va2pa>
f010259a:	89 da                	mov    %ebx,%edx
f010259c:	2b 15 90 fe 23 f0    	sub    0xf023fe90,%edx
f01025a2:	c1 fa 03             	sar    $0x3,%edx
f01025a5:	c1 e2 0c             	shl    $0xc,%edx
f01025a8:	39 d0                	cmp    %edx,%eax
f01025aa:	74 24                	je     f01025d0 <mem_init+0x1072>
f01025ac:	c7 44 24 0c 88 81 10 	movl   $0xf0108188,0xc(%esp)
f01025b3:	f0 
f01025b4:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01025bb:	f0 
f01025bc:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01025c3:	00 
f01025c4:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01025cb:	e8 70 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025d0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01025d5:	74 24                	je     f01025fb <mem_init+0x109d>
f01025d7:	c7 44 24 0c f4 87 10 	movl   $0xf01087f4,0xc(%esp)
f01025de:	f0 
f01025df:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01025e6:	f0 
f01025e7:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01025ee:	00 
f01025ef:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01025f6:	e8 45 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025fb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102600:	74 24                	je     f0102626 <mem_init+0x10c8>
f0102602:	c7 44 24 0c 4e 88 10 	movl   $0xf010884e,0xc(%esp)
f0102609:	f0 
f010260a:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102611:	f0 
f0102612:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102619:	00 
f010261a:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102621:	e8 1a da ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102626:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010262d:	00 
f010262e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102635:	00 
f0102636:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010263a:	89 3c 24             	mov    %edi,(%esp)
f010263d:	e8 2f ee ff ff       	call   f0101471 <page_insert>
f0102642:	85 c0                	test   %eax,%eax
f0102644:	74 24                	je     f010266a <mem_init+0x110c>
f0102646:	c7 44 24 0c 00 82 10 	movl   $0xf0108200,0xc(%esp)
f010264d:	f0 
f010264e:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102655:	f0 
f0102656:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f010265d:	00 
f010265e:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102665:	e8 d6 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010266a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010266f:	75 24                	jne    f0102695 <mem_init+0x1137>
f0102671:	c7 44 24 0c 5f 88 10 	movl   $0xf010885f,0xc(%esp)
f0102678:	f0 
f0102679:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102680:	f0 
f0102681:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f0102688:	00 
f0102689:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102690:	e8 ab d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102695:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102698:	74 24                	je     f01026be <mem_init+0x1160>
f010269a:	c7 44 24 0c 6b 88 10 	movl   $0xf010886b,0xc(%esp)
f01026a1:	f0 
f01026a2:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01026a9:	f0 
f01026aa:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f01026b1:	00 
f01026b2:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01026b9:	e8 82 d9 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026be:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026c5:	00 
f01026c6:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f01026cb:	89 04 24             	mov    %eax,(%esp)
f01026ce:	e8 4e ed ff ff       	call   f0101421 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026d3:	8b 3d 8c fe 23 f0    	mov    0xf023fe8c,%edi
f01026d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01026de:	89 f8                	mov    %edi,%eax
f01026e0:	e8 a0 e4 ff ff       	call   f0100b85 <check_va2pa>
f01026e5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026e8:	74 24                	je     f010270e <mem_init+0x11b0>
f01026ea:	c7 44 24 0c dc 81 10 	movl   $0xf01081dc,0xc(%esp)
f01026f1:	f0 
f01026f2:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01026f9:	f0 
f01026fa:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102701:	00 
f0102702:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102709:	e8 32 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010270e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102713:	89 f8                	mov    %edi,%eax
f0102715:	e8 6b e4 ff ff       	call   f0100b85 <check_va2pa>
f010271a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010271d:	74 24                	je     f0102743 <mem_init+0x11e5>
f010271f:	c7 44 24 0c 38 82 10 	movl   $0xf0108238,0xc(%esp)
f0102726:	f0 
f0102727:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010272e:	f0 
f010272f:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102736:	00 
f0102737:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010273e:	e8 fd d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102743:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102748:	74 24                	je     f010276e <mem_init+0x1210>
f010274a:	c7 44 24 0c 80 88 10 	movl   $0xf0108880,0xc(%esp)
f0102751:	f0 
f0102752:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102759:	f0 
f010275a:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102761:	00 
f0102762:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102769:	e8 d2 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010276e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102773:	74 24                	je     f0102799 <mem_init+0x123b>
f0102775:	c7 44 24 0c 4e 88 10 	movl   $0xf010884e,0xc(%esp)
f010277c:	f0 
f010277d:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102784:	f0 
f0102785:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010278c:	00 
f010278d:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102794:	e8 a7 d8 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027a0:	e8 c4 e9 ff ff       	call   f0101169 <page_alloc>
f01027a5:	85 c0                	test   %eax,%eax
f01027a7:	74 04                	je     f01027ad <mem_init+0x124f>
f01027a9:	39 c3                	cmp    %eax,%ebx
f01027ab:	74 24                	je     f01027d1 <mem_init+0x1273>
f01027ad:	c7 44 24 0c 60 82 10 	movl   $0xf0108260,0xc(%esp)
f01027b4:	f0 
f01027b5:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01027bc:	f0 
f01027bd:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01027c4:	00 
f01027c5:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01027cc:	e8 6f d8 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01027d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027d8:	e8 8c e9 ff ff       	call   f0101169 <page_alloc>
f01027dd:	85 c0                	test   %eax,%eax
f01027df:	74 24                	je     f0102805 <mem_init+0x12a7>
f01027e1:	c7 44 24 0c a2 87 10 	movl   $0xf01087a2,0xc(%esp)
f01027e8:	f0 
f01027e9:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01027f0:	f0 
f01027f1:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f01027f8:	00 
f01027f9:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102800:	e8 3b d8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102805:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f010280a:	8b 08                	mov    (%eax),%ecx
f010280c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102812:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102815:	2b 15 90 fe 23 f0    	sub    0xf023fe90,%edx
f010281b:	c1 fa 03             	sar    $0x3,%edx
f010281e:	c1 e2 0c             	shl    $0xc,%edx
f0102821:	39 d1                	cmp    %edx,%ecx
f0102823:	74 24                	je     f0102849 <mem_init+0x12eb>
f0102825:	c7 44 24 0c 04 7f 10 	movl   $0xf0107f04,0xc(%esp)
f010282c:	f0 
f010282d:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102834:	f0 
f0102835:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f010283c:	00 
f010283d:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102844:	e8 f7 d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102849:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010284f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102852:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102857:	74 24                	je     f010287d <mem_init+0x131f>
f0102859:	c7 44 24 0c 05 88 10 	movl   $0xf0108805,0xc(%esp)
f0102860:	f0 
f0102861:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102868:	f0 
f0102869:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102870:	00 
f0102871:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102878:	e8 c3 d7 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010287d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102880:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102886:	89 04 24             	mov    %eax,(%esp)
f0102889:	e8 66 e9 ff ff       	call   f01011f4 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010288e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102895:	00 
f0102896:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010289d:	00 
f010289e:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f01028a3:	89 04 24             	mov    %eax,(%esp)
f01028a6:	e8 c8 e9 ff ff       	call   f0101273 <pgdir_walk>
f01028ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01028ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01028b1:	8b 15 8c fe 23 f0    	mov    0xf023fe8c,%edx
f01028b7:	8b 7a 04             	mov    0x4(%edx),%edi
f01028ba:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028c0:	8b 0d 88 fe 23 f0    	mov    0xf023fe88,%ecx
f01028c6:	89 f8                	mov    %edi,%eax
f01028c8:	c1 e8 0c             	shr    $0xc,%eax
f01028cb:	39 c8                	cmp    %ecx,%eax
f01028cd:	72 20                	jb     f01028ef <mem_init+0x1391>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028cf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01028d3:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f01028da:	f0 
f01028db:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f01028e2:	00 
f01028e3:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01028ea:	e8 51 d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028ef:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f01028f5:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01028f8:	74 24                	je     f010291e <mem_init+0x13c0>
f01028fa:	c7 44 24 0c 91 88 10 	movl   $0xf0108891,0xc(%esp)
f0102901:	f0 
f0102902:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102909:	f0 
f010290a:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f0102911:	00 
f0102912:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102919:	e8 22 d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010291e:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102925:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102928:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010292e:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0102934:	c1 f8 03             	sar    $0x3,%eax
f0102937:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010293a:	89 c2                	mov    %eax,%edx
f010293c:	c1 ea 0c             	shr    $0xc,%edx
f010293f:	39 d1                	cmp    %edx,%ecx
f0102941:	77 20                	ja     f0102963 <mem_init+0x1405>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102943:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102947:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f010294e:	f0 
f010294f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102956:	00 
f0102957:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f010295e:	e8 dd d6 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102963:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010296a:	00 
f010296b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102972:	00 
	return (void *)(pa + KERNBASE);
f0102973:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102978:	89 04 24             	mov    %eax,(%esp)
f010297b:	e8 e7 3f 00 00       	call   f0106967 <memset>
	page_free(pp0);
f0102980:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102983:	89 3c 24             	mov    %edi,(%esp)
f0102986:	e8 69 e8 ff ff       	call   f01011f4 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010298b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102992:	00 
f0102993:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010299a:	00 
f010299b:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f01029a0:	89 04 24             	mov    %eax,(%esp)
f01029a3:	e8 cb e8 ff ff       	call   f0101273 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029a8:	89 fa                	mov    %edi,%edx
f01029aa:	2b 15 90 fe 23 f0    	sub    0xf023fe90,%edx
f01029b0:	c1 fa 03             	sar    $0x3,%edx
f01029b3:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029b6:	89 d0                	mov    %edx,%eax
f01029b8:	c1 e8 0c             	shr    $0xc,%eax
f01029bb:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f01029c1:	72 20                	jb     f01029e3 <mem_init+0x1485>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01029c7:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f01029ce:	f0 
f01029cf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01029d6:	00 
f01029d7:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f01029de:	e8 5d d6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01029e3:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01029e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01029ec:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01029f2:	f6 00 01             	testb  $0x1,(%eax)
f01029f5:	74 24                	je     f0102a1b <mem_init+0x14bd>
f01029f7:	c7 44 24 0c a9 88 10 	movl   $0xf01088a9,0xc(%esp)
f01029fe:	f0 
f01029ff:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102a06:	f0 
f0102a07:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0102a0e:	00 
f0102a0f:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102a16:	e8 25 d6 ff ff       	call   f0100040 <_panic>
f0102a1b:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102a1e:	39 d0                	cmp    %edx,%eax
f0102a20:	75 d0                	jne    f01029f2 <mem_init+0x1494>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102a22:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102a27:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102a2d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a30:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102a36:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102a39:	89 0d 40 f2 23 f0    	mov    %ecx,0xf023f240

	// free the pages we took
	page_free(pp0);
f0102a3f:	89 04 24             	mov    %eax,(%esp)
f0102a42:	e8 ad e7 ff ff       	call   f01011f4 <page_free>
	page_free(pp1);
f0102a47:	89 1c 24             	mov    %ebx,(%esp)
f0102a4a:	e8 a5 e7 ff ff       	call   f01011f4 <page_free>
	page_free(pp2);
f0102a4f:	89 34 24             	mov    %esi,(%esp)
f0102a52:	e8 9d e7 ff ff       	call   f01011f4 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102a57:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102a5e:	00 
f0102a5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a66:	e8 75 ea ff ff       	call   f01014e0 <mmio_map_region>
f0102a6b:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102a6d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102a74:	00 
f0102a75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a7c:	e8 5f ea ff ff       	call   f01014e0 <mmio_map_region>
f0102a81:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102a83:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102a89:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102a8e:	77 08                	ja     f0102a98 <mem_init+0x153a>
f0102a90:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102a96:	77 24                	ja     f0102abc <mem_init+0x155e>
f0102a98:	c7 44 24 0c 84 82 10 	movl   $0xf0108284,0xc(%esp)
f0102a9f:	f0 
f0102aa0:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102aa7:	f0 
f0102aa8:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0102aaf:	00 
f0102ab0:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102ab7:	e8 84 d5 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102abc:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102ac2:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102ac8:	77 08                	ja     f0102ad2 <mem_init+0x1574>
f0102aca:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102ad0:	77 24                	ja     f0102af6 <mem_init+0x1598>
f0102ad2:	c7 44 24 0c ac 82 10 	movl   $0xf01082ac,0xc(%esp)
f0102ad9:	f0 
f0102ada:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102ae1:	f0 
f0102ae2:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0102ae9:	00 
f0102aea:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102af1:	e8 4a d5 ff ff       	call   f0100040 <_panic>
f0102af6:	89 da                	mov    %ebx,%edx
f0102af8:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102afa:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102b00:	74 24                	je     f0102b26 <mem_init+0x15c8>
f0102b02:	c7 44 24 0c d4 82 10 	movl   $0xf01082d4,0xc(%esp)
f0102b09:	f0 
f0102b0a:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102b11:	f0 
f0102b12:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102b19:	00 
f0102b1a:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102b21:	e8 1a d5 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102b26:	39 c6                	cmp    %eax,%esi
f0102b28:	73 24                	jae    f0102b4e <mem_init+0x15f0>
f0102b2a:	c7 44 24 0c c0 88 10 	movl   $0xf01088c0,0xc(%esp)
f0102b31:	f0 
f0102b32:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102b39:	f0 
f0102b3a:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102b41:	00 
f0102b42:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102b49:	e8 f2 d4 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102b4e:	8b 3d 8c fe 23 f0    	mov    0xf023fe8c,%edi
f0102b54:	89 da                	mov    %ebx,%edx
f0102b56:	89 f8                	mov    %edi,%eax
f0102b58:	e8 28 e0 ff ff       	call   f0100b85 <check_va2pa>
f0102b5d:	85 c0                	test   %eax,%eax
f0102b5f:	74 24                	je     f0102b85 <mem_init+0x1627>
f0102b61:	c7 44 24 0c fc 82 10 	movl   $0xf01082fc,0xc(%esp)
f0102b68:	f0 
f0102b69:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102b70:	f0 
f0102b71:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102b78:	00 
f0102b79:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102b80:	e8 bb d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102b85:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102b8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b8e:	89 c2                	mov    %eax,%edx
f0102b90:	89 f8                	mov    %edi,%eax
f0102b92:	e8 ee df ff ff       	call   f0100b85 <check_va2pa>
f0102b97:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102b9c:	74 24                	je     f0102bc2 <mem_init+0x1664>
f0102b9e:	c7 44 24 0c 20 83 10 	movl   $0xf0108320,0xc(%esp)
f0102ba5:	f0 
f0102ba6:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102bad:	f0 
f0102bae:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102bb5:	00 
f0102bb6:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102bbd:	e8 7e d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102bc2:	89 f2                	mov    %esi,%edx
f0102bc4:	89 f8                	mov    %edi,%eax
f0102bc6:	e8 ba df ff ff       	call   f0100b85 <check_va2pa>
f0102bcb:	85 c0                	test   %eax,%eax
f0102bcd:	74 24                	je     f0102bf3 <mem_init+0x1695>
f0102bcf:	c7 44 24 0c 50 83 10 	movl   $0xf0108350,0xc(%esp)
f0102bd6:	f0 
f0102bd7:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102bde:	f0 
f0102bdf:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102be6:	00 
f0102be7:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102bee:	e8 4d d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102bf3:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102bf9:	89 f8                	mov    %edi,%eax
f0102bfb:	e8 85 df ff ff       	call   f0100b85 <check_va2pa>
f0102c00:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c03:	74 24                	je     f0102c29 <mem_init+0x16cb>
f0102c05:	c7 44 24 0c 74 83 10 	movl   $0xf0108374,0xc(%esp)
f0102c0c:	f0 
f0102c0d:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102c14:	f0 
f0102c15:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f0102c1c:	00 
f0102c1d:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102c24:	e8 17 d4 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102c29:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c30:	00 
f0102c31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c35:	89 3c 24             	mov    %edi,(%esp)
f0102c38:	e8 36 e6 ff ff       	call   f0101273 <pgdir_walk>
f0102c3d:	f6 00 1a             	testb  $0x1a,(%eax)
f0102c40:	75 24                	jne    f0102c66 <mem_init+0x1708>
f0102c42:	c7 44 24 0c a0 83 10 	movl   $0xf01083a0,0xc(%esp)
f0102c49:	f0 
f0102c4a:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102c51:	f0 
f0102c52:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f0102c59:	00 
f0102c5a:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102c61:	e8 da d3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102c66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c6d:	00 
f0102c6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c72:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102c77:	89 04 24             	mov    %eax,(%esp)
f0102c7a:	e8 f4 e5 ff ff       	call   f0101273 <pgdir_walk>
f0102c7f:	f6 00 04             	testb  $0x4,(%eax)
f0102c82:	74 24                	je     f0102ca8 <mem_init+0x174a>
f0102c84:	c7 44 24 0c e4 83 10 	movl   $0xf01083e4,0xc(%esp)
f0102c8b:	f0 
f0102c8c:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102c93:	f0 
f0102c94:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0102c9b:	00 
f0102c9c:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102ca3:	e8 98 d3 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102ca8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102caf:	00 
f0102cb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102cb4:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102cb9:	89 04 24             	mov    %eax,(%esp)
f0102cbc:	e8 b2 e5 ff ff       	call   f0101273 <pgdir_walk>
f0102cc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102cc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102cce:	00 
f0102ccf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102cd6:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102cdb:	89 04 24             	mov    %eax,(%esp)
f0102cde:	e8 90 e5 ff ff       	call   f0101273 <pgdir_walk>
f0102ce3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102ce9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102cf0:	00 
f0102cf1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102cf5:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102cfa:	89 04 24             	mov    %eax,(%esp)
f0102cfd:	e8 71 e5 ff ff       	call   f0101273 <pgdir_walk>
f0102d02:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102d08:	c7 04 24 d2 88 10 f0 	movl   $0xf01088d2,(%esp)
f0102d0f:	e8 68 13 00 00       	call   f010407c <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here0:
	size_t pages_need = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE) ; 
f0102d14:	a1 88 fe 23 f0       	mov    0xf023fe88,%eax
f0102d19:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102d20:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
 	boot_map_region( kern_pgdir , UPAGES , pages_need , PADDR(pages) , PTE_U | PTE_P ) ;		
f0102d26:	a1 90 fe 23 f0       	mov    0xf023fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d2b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d30:	77 20                	ja     f0102d52 <mem_init+0x17f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d32:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d36:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0102d3d:	f0 
f0102d3e:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0102d45:	00 
f0102d46:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102d4d:	e8 ee d2 ff ff       	call   f0100040 <_panic>
f0102d52:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d59:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d5a:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d5f:	89 04 24             	mov    %eax,(%esp)
f0102d62:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d67:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102d6c:	e8 a5 e5 ff ff       	call   f0101316 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region( kern_pgdir , UENVS , sizeof( struct Env ) * NENV , PADDR(envs) , PTE_U | PTE_P ) ; 
f0102d71:	a1 48 f2 23 f0       	mov    0xf023f248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d76:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d7b:	77 20                	ja     f0102d9d <mem_init+0x183f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d81:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0102d88:	f0 
f0102d89:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0102d90:	00 
f0102d91:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102d98:	e8 a3 d2 ff ff       	call   f0100040 <_panic>
f0102d9d:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102da4:	00 
	return (physaddr_t)kva - KERNBASE;
f0102da5:	05 00 00 00 10       	add    $0x10000000,%eax
f0102daa:	89 04 24             	mov    %eax,(%esp)
f0102dad:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102db2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102db7:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102dbc:	e8 55 e5 ff ff       	call   f0101316 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dc1:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102dc6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dcb:	77 20                	ja     f0102ded <mem_init+0x188f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dcd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dd1:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0102dd8:	f0 
f0102dd9:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
f0102de0:	00 
f0102de1:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102de8:	e8 53 d2 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region( kern_pgdir , KSTACKTOP-KSTKSIZE , KSTKSIZE , PADDR( bootstack ) , PTE_W | PTE_P ) ;  
f0102ded:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102df4:	00 
f0102df5:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f0102dfc:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e01:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102e06:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102e0b:	e8 06 e5 ff ff       	call   f0101316 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region( kern_pgdir , KERNBASE , 0x10000000 , 0 , PTE_W | PTE_P ) ;  
f0102e10:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102e17:	00 
f0102e18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e1f:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102e24:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102e29:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102e2e:	e8 e3 e4 ff ff       	call   f0101316 <boot_map_region>
f0102e33:	bf 00 20 28 f0       	mov    $0xf0282000,%edi
f0102e38:	bb 00 20 24 f0       	mov    $0xf0242000,%ebx
f0102e3d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e42:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e48:	77 20                	ja     f0102e6a <mem_init+0x190c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e4a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e4e:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0102e55:	f0 
f0102e56:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
f0102e5d:	00 
f0102e5e:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102e65:	e8 d6 d1 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
	int i = 0 ; 
	for ( i = 0 ; i < NCPU ; i ++ ) {
                uint32_t kstacktop_i = KSTACKTOP - i * ( KSTKSIZE + KSTKGAP) ; 
		boot_map_region( kern_pgdir , kstacktop_i - KSTKSIZE , KSTKSIZE , PADDR(percpu_kstacks[i]) , PTE_W | PTE_P ) ;   
f0102e6a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102e71:	00 
f0102e72:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102e78:	89 04 24             	mov    %eax,(%esp)
f0102e7b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e80:	89 f2                	mov    %esi,%edx
f0102e82:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0102e87:	e8 8a e4 ff ff       	call   f0101316 <boot_map_region>
f0102e8c:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102e92:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i = 0 ; 
	for ( i = 0 ; i < NCPU ; i ++ ) {
f0102e98:	39 fb                	cmp    %edi,%ebx
f0102e9a:	75 a6                	jne    f0102e42 <mem_init+0x18e4>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102e9c:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ea1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ea6:	77 20                	ja     f0102ec8 <mem_init+0x196a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102eac:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0102eb3:	f0 
f0102eb4:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
f0102ebb:	00 
f0102ebc:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102ec3:	e8 78 d1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102ec8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102ecd:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102ed0:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ed5:	e8 c9 dd ff ff       	call   f0100ca3 <check_page_free_list>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102eda:	8b 3d 8c fe 23 f0    	mov    0xf023fe8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102ee0:	a1 88 fe 23 f0       	mov    0xf023fe88,%eax
f0102ee5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102ee8:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102eef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ef4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102ef7:	8b 35 90 fe 23 f0    	mov    0xf023fe90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102efd:	89 75 cc             	mov    %esi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102f00:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102f06:	89 45 c8             	mov    %eax,-0x38(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102f09:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f0e:	eb 6a                	jmp    f0102f7a <mem_init+0x1a1c>
f0102f10:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102f16:	89 f8                	mov    %edi,%eax
f0102f18:	e8 68 dc ff ff       	call   f0100b85 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f1d:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102f24:	77 20                	ja     f0102f46 <mem_init+0x19e8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f26:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102f2a:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0102f31:	f0 
f0102f32:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0102f39:	00 
f0102f3a:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102f41:	e8 fa d0 ff ff       	call   f0100040 <_panic>
f0102f46:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f49:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102f4c:	39 d0                	cmp    %edx,%eax
f0102f4e:	74 24                	je     f0102f74 <mem_init+0x1a16>
f0102f50:	c7 44 24 0c 18 84 10 	movl   $0xf0108418,0xc(%esp)
f0102f57:	f0 
f0102f58:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102f5f:	f0 
f0102f60:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0102f67:	00 
f0102f68:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102f6f:	e8 cc d0 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102f74:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f7a:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102f7d:	77 91                	ja     f0102f10 <mem_init+0x19b2>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102f7f:	8b 1d 48 f2 23 f0    	mov    0xf023f248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f85:	89 de                	mov    %ebx,%esi
f0102f87:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102f8c:	89 f8                	mov    %edi,%eax
f0102f8e:	e8 f2 db ff ff       	call   f0100b85 <check_va2pa>
f0102f93:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102f99:	77 20                	ja     f0102fbb <mem_init+0x1a5d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102f9f:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0102fa6:	f0 
f0102fa7:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0102fae:	00 
f0102faf:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102fb6:	e8 85 d0 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fbb:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102fc0:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102fc6:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102fc9:	39 d0                	cmp    %edx,%eax
f0102fcb:	74 24                	je     f0102ff1 <mem_init+0x1a93>
f0102fcd:	c7 44 24 0c 4c 84 10 	movl   $0xf010844c,0xc(%esp)
f0102fd4:	f0 
f0102fd5:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0102fdc:	f0 
f0102fdd:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0102fe4:	00 
f0102fe5:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0102fec:	e8 4f d0 ff ff       	call   f0100040 <_panic>
f0102ff1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) 
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ff7:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102ffd:	0f 85 6a 05 00 00    	jne    f010356d <mem_init+0x200f>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103003:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103006:	c1 e6 0c             	shl    $0xc,%esi
f0103009:	bb 00 00 00 00       	mov    $0x0,%ebx
f010300e:	eb 3b                	jmp    f010304b <mem_init+0x1aed>
f0103010:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103016:	89 f8                	mov    %edi,%eax
f0103018:	e8 68 db ff ff       	call   f0100b85 <check_va2pa>
f010301d:	39 c3                	cmp    %eax,%ebx
f010301f:	74 24                	je     f0103045 <mem_init+0x1ae7>
f0103021:	c7 44 24 0c 80 84 10 	movl   $0xf0108480,0xc(%esp)
f0103028:	f0 
f0103029:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0103030:	f0 
f0103031:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0103038:	00 
f0103039:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0103040:	e8 fb cf ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103045:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010304b:	39 f3                	cmp    %esi,%ebx
f010304d:	72 c1                	jb     f0103010 <mem_init+0x1ab2>
f010304f:	c7 45 d0 00 20 24 f0 	movl   $0xf0242000,-0x30(%ebp)
f0103056:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010305d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0103062:	b8 00 20 24 f0       	mov    $0xf0242000,%eax
f0103067:	05 00 80 00 20       	add    $0x20008000,%eax
f010306c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010306f:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0103075:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103078:	89 f2                	mov    %esi,%edx
f010307a:	89 f8                	mov    %edi,%eax
f010307c:	e8 04 db ff ff       	call   f0100b85 <check_va2pa>
f0103081:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103084:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010308a:	77 20                	ja     f01030ac <mem_init+0x1b4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010308c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103090:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0103097:	f0 
f0103098:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f010309f:	00 
f01030a0:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01030a7:	e8 94 cf ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030ac:	89 f3                	mov    %esi,%ebx
f01030ae:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01030b1:	03 4d d4             	add    -0x2c(%ebp),%ecx
f01030b4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01030b7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01030ba:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01030bd:	39 c2                	cmp    %eax,%edx
f01030bf:	74 24                	je     f01030e5 <mem_init+0x1b87>
f01030c1:	c7 44 24 0c a8 84 10 	movl   $0xf01084a8,0xc(%esp)
f01030c8:	f0 
f01030c9:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01030d0:	f0 
f01030d1:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f01030d8:	00 
f01030d9:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01030e0:	e8 5b cf ff ff       	call   f0100040 <_panic>
f01030e5:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01030eb:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f01030ee:	0f 85 6b 04 00 00    	jne    f010355f <mem_init+0x2001>
f01030f4:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01030fa:	89 da                	mov    %ebx,%edx
f01030fc:	89 f8                	mov    %edi,%eax
f01030fe:	e8 82 da ff ff       	call   f0100b85 <check_va2pa>
f0103103:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103106:	74 24                	je     f010312c <mem_init+0x1bce>
f0103108:	c7 44 24 0c f0 84 10 	movl   $0xf01084f0,0xc(%esp)
f010310f:	f0 
f0103110:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0103117:	f0 
f0103118:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f010311f:	00 
f0103120:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0103127:	e8 14 cf ff ff       	call   f0100040 <_panic>
f010312c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103132:	39 de                	cmp    %ebx,%esi
f0103134:	75 c4                	jne    f01030fa <mem_init+0x1b9c>
f0103136:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f010313c:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f0103143:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010314a:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103150:	0f 85 19 ff ff ff    	jne    f010306f <mem_init+0x1b11>
f0103156:	b8 00 00 00 00       	mov    $0x0,%eax
f010315b:	e9 c2 00 00 00       	jmp    f0103222 <mem_init+0x1cc4>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103160:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103166:	83 fa 04             	cmp    $0x4,%edx
f0103169:	77 2e                	ja     f0103199 <mem_init+0x1c3b>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010316b:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010316f:	0f 85 aa 00 00 00    	jne    f010321f <mem_init+0x1cc1>
f0103175:	c7 44 24 0c eb 88 10 	movl   $0xf01088eb,0xc(%esp)
f010317c:	f0 
f010317d:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0103184:	f0 
f0103185:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f010318c:	00 
f010318d:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0103194:	e8 a7 ce ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103199:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010319e:	76 55                	jbe    f01031f5 <mem_init+0x1c97>
				assert(pgdir[i] & PTE_P);
f01031a0:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01031a3:	f6 c2 01             	test   $0x1,%dl
f01031a6:	75 24                	jne    f01031cc <mem_init+0x1c6e>
f01031a8:	c7 44 24 0c eb 88 10 	movl   $0xf01088eb,0xc(%esp)
f01031af:	f0 
f01031b0:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01031b7:	f0 
f01031b8:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f01031bf:	00 
f01031c0:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01031c7:	e8 74 ce ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01031cc:	f6 c2 02             	test   $0x2,%dl
f01031cf:	75 4e                	jne    f010321f <mem_init+0x1cc1>
f01031d1:	c7 44 24 0c fc 88 10 	movl   $0xf01088fc,0xc(%esp)
f01031d8:	f0 
f01031d9:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01031e0:	f0 
f01031e1:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01031e8:	00 
f01031e9:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01031f0:	e8 4b ce ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01031f5:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01031f9:	74 24                	je     f010321f <mem_init+0x1cc1>
f01031fb:	c7 44 24 0c 0d 89 10 	movl   $0xf010890d,0xc(%esp)
f0103202:	f0 
f0103203:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010320a:	f0 
f010320b:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0103212:	00 
f0103213:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010321a:	e8 21 ce ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010321f:	83 c0 01             	add    $0x1,%eax
f0103222:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103227:	0f 85 33 ff ff ff    	jne    f0103160 <mem_init+0x1c02>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010322d:	c7 04 24 14 85 10 f0 	movl   $0xf0108514,(%esp)
f0103234:	e8 43 0e 00 00       	call   f010407c <cprintf>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103239:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010323c:	83 e0 f3             	and    $0xfffffff3,%eax
f010323f:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103244:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103247:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010324e:	e8 16 df ff ff       	call   f0101169 <page_alloc>
f0103253:	89 c3                	mov    %eax,%ebx
f0103255:	85 c0                	test   %eax,%eax
f0103257:	75 24                	jne    f010327d <mem_init+0x1d1f>
f0103259:	c7 44 24 0c f7 86 10 	movl   $0xf01086f7,0xc(%esp)
f0103260:	f0 
f0103261:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0103268:	f0 
f0103269:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0103270:	00 
f0103271:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0103278:	e8 c3 cd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010327d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103284:	e8 e0 de ff ff       	call   f0101169 <page_alloc>
f0103289:	89 c7                	mov    %eax,%edi
f010328b:	85 c0                	test   %eax,%eax
f010328d:	75 24                	jne    f01032b3 <mem_init+0x1d55>
f010328f:	c7 44 24 0c 0d 87 10 	movl   $0xf010870d,0xc(%esp)
f0103296:	f0 
f0103297:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010329e:	f0 
f010329f:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f01032a6:	00 
f01032a7:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01032ae:	e8 8d cd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01032b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01032ba:	e8 aa de ff ff       	call   f0101169 <page_alloc>
f01032bf:	89 c6                	mov    %eax,%esi
f01032c1:	85 c0                	test   %eax,%eax
f01032c3:	75 24                	jne    f01032e9 <mem_init+0x1d8b>
f01032c5:	c7 44 24 0c 23 87 10 	movl   $0xf0108723,0xc(%esp)
f01032cc:	f0 
f01032cd:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01032d4:	f0 
f01032d5:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f01032dc:	00 
f01032dd:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01032e4:	e8 57 cd ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01032e9:	89 1c 24             	mov    %ebx,(%esp)
f01032ec:	e8 03 df ff ff       	call   f01011f4 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f01032f1:	89 f8                	mov    %edi,%eax
f01032f3:	e8 48 d8 ff ff       	call   f0100b40 <page2kva>
f01032f8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032ff:	00 
f0103300:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103307:	00 
f0103308:	89 04 24             	mov    %eax,(%esp)
f010330b:	e8 57 36 00 00       	call   f0106967 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103310:	89 f0                	mov    %esi,%eax
f0103312:	e8 29 d8 ff ff       	call   f0100b40 <page2kva>
f0103317:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010331e:	00 
f010331f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103326:	00 
f0103327:	89 04 24             	mov    %eax,(%esp)
f010332a:	e8 38 36 00 00       	call   f0106967 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010332f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103336:	00 
f0103337:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010333e:	00 
f010333f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103343:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f0103348:	89 04 24             	mov    %eax,(%esp)
f010334b:	e8 21 e1 ff ff       	call   f0101471 <page_insert>
	assert(pp1->pp_ref == 1);
f0103350:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103355:	74 24                	je     f010337b <mem_init+0x1e1d>
f0103357:	c7 44 24 0c f4 87 10 	movl   $0xf01087f4,0xc(%esp)
f010335e:	f0 
f010335f:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0103366:	f0 
f0103367:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f010336e:	00 
f010336f:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0103376:	e8 c5 cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010337b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103382:	01 01 01 
f0103385:	74 24                	je     f01033ab <mem_init+0x1e4d>
f0103387:	c7 44 24 0c 34 85 10 	movl   $0xf0108534,0xc(%esp)
f010338e:	f0 
f010338f:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0103396:	f0 
f0103397:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f010339e:	00 
f010339f:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01033a6:	e8 95 cc ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01033ab:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01033b2:	00 
f01033b3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01033ba:	00 
f01033bb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01033bf:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f01033c4:	89 04 24             	mov    %eax,(%esp)
f01033c7:	e8 a5 e0 ff ff       	call   f0101471 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01033cc:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01033d3:	02 02 02 
f01033d6:	74 24                	je     f01033fc <mem_init+0x1e9e>
f01033d8:	c7 44 24 0c 58 85 10 	movl   $0xf0108558,0xc(%esp)
f01033df:	f0 
f01033e0:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01033e7:	f0 
f01033e8:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f01033ef:	00 
f01033f0:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01033f7:	e8 44 cc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01033fc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103401:	74 24                	je     f0103427 <mem_init+0x1ec9>
f0103403:	c7 44 24 0c 16 88 10 	movl   $0xf0108816,0xc(%esp)
f010340a:	f0 
f010340b:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0103412:	f0 
f0103413:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f010341a:	00 
f010341b:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0103422:	e8 19 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103427:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010342c:	74 24                	je     f0103452 <mem_init+0x1ef4>
f010342e:	c7 44 24 0c 80 88 10 	movl   $0xf0108880,0xc(%esp)
f0103435:	f0 
f0103436:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010343d:	f0 
f010343e:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0103445:	00 
f0103446:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010344d:	e8 ee cb ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103452:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103459:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010345c:	89 f0                	mov    %esi,%eax
f010345e:	e8 dd d6 ff ff       	call   f0100b40 <page2kva>
f0103463:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0103469:	74 24                	je     f010348f <mem_init+0x1f31>
f010346b:	c7 44 24 0c 7c 85 10 	movl   $0xf010857c,0xc(%esp)
f0103472:	f0 
f0103473:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010347a:	f0 
f010347b:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0103482:	00 
f0103483:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010348a:	e8 b1 cb ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010348f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103496:	00 
f0103497:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f010349c:	89 04 24             	mov    %eax,(%esp)
f010349f:	e8 7d df ff ff       	call   f0101421 <page_remove>
	assert(pp2->pp_ref == 0);
f01034a4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01034a9:	74 24                	je     f01034cf <mem_init+0x1f71>
f01034ab:	c7 44 24 0c 4e 88 10 	movl   $0xf010884e,0xc(%esp)
f01034b2:	f0 
f01034b3:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01034ba:	f0 
f01034bb:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f01034c2:	00 
f01034c3:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f01034ca:	e8 71 cb ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01034cf:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f01034d4:	8b 08                	mov    (%eax),%ecx
f01034d6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01034dc:	89 da                	mov    %ebx,%edx
f01034de:	2b 15 90 fe 23 f0    	sub    0xf023fe90,%edx
f01034e4:	c1 fa 03             	sar    $0x3,%edx
f01034e7:	c1 e2 0c             	shl    $0xc,%edx
f01034ea:	39 d1                	cmp    %edx,%ecx
f01034ec:	74 24                	je     f0103512 <mem_init+0x1fb4>
f01034ee:	c7 44 24 0c 04 7f 10 	movl   $0xf0107f04,0xc(%esp)
f01034f5:	f0 
f01034f6:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f01034fd:	f0 
f01034fe:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f0103505:	00 
f0103506:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010350d:	e8 2e cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103512:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103518:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010351d:	74 24                	je     f0103543 <mem_init+0x1fe5>
f010351f:	c7 44 24 0c 05 88 10 	movl   $0xf0108805,0xc(%esp)
f0103526:	f0 
f0103527:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f010352e:	f0 
f010352f:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0103536:	00 
f0103537:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f010353e:	e8 fd ca ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103543:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103549:	89 1c 24             	mov    %ebx,(%esp)
f010354c:	e8 a3 dc ff ff       	call   f01011f4 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103551:	c7 04 24 a8 85 10 f0 	movl   $0xf01085a8,(%esp)
f0103558:	e8 1f 0b 00 00       	call   f010407c <cprintf>
f010355d:	eb 1c                	jmp    f010357b <mem_init+0x201d>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010355f:	89 da                	mov    %ebx,%edx
f0103561:	89 f8                	mov    %edi,%eax
f0103563:	e8 1d d6 ff ff       	call   f0100b85 <check_va2pa>
f0103568:	e9 4a fb ff ff       	jmp    f01030b7 <mem_init+0x1b59>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010356d:	89 da                	mov    %ebx,%edx
f010356f:	89 f8                	mov    %edi,%eax
f0103571:	e8 0f d6 ff ff       	call   f0100b85 <check_va2pa>
f0103576:	e9 4b fa ff ff       	jmp    f0102fc6 <mem_init+0x1a68>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010357b:	83 c4 4c             	add    $0x4c,%esp
f010357e:	5b                   	pop    %ebx
f010357f:	5e                   	pop    %esi
f0103580:	5f                   	pop    %edi
f0103581:	5d                   	pop    %ebp
f0103582:	c3                   	ret    

f0103583 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103583:	55                   	push   %ebp
f0103584:	89 e5                	mov    %esp,%ebp
f0103586:	57                   	push   %edi
f0103587:	56                   	push   %esi
f0103588:	53                   	push   %ebx
f0103589:	83 ec 2c             	sub    $0x2c,%esp
f010358c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010358f:	8b 45 0c             	mov    0xc(%ebp),%eax

	uintptr_t sv = ( ( uintptr_t ) va ) & ( ~0xFFF ) ;
f0103592:	89 c6                	mov    %eax,%esi
f0103594:	89 c3                	mov    %eax,%ebx
f0103596:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t ev = ( ( ( uintptr_t ) va ) + len - 1 + PGSIZE ) & (~0xFFF);
f010359c:	8b 55 10             	mov    0x10(%ebp),%edx
f010359f:	8d 84 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%eax
f01035a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01035ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for ( ; sv != ev ; sv += PGSIZE ) {
f01035ae:	eb 46                	jmp    f01035f6 <user_mem_check+0x73>
		pte_t * npte ;
		user_mem_check_addr = sv ; 
		if ( user_mem_check_addr < ( uintptr_t) va ) 
			user_mem_check_addr = ( uintptr_t) va ; 
f01035b0:	39 de                	cmp    %ebx,%esi
f01035b2:	89 d8                	mov    %ebx,%eax
f01035b4:	0f 47 c6             	cmova  %esi,%eax
f01035b7:	a3 3c f2 23 f0       	mov    %eax,0xf023f23c
		struct PageInfo * pp = page_lookup( env->env_pgdir , ( void * ) sv , &npte ) ; 
f01035bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01035bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01035c7:	8b 47 60             	mov    0x60(%edi),%eax
f01035ca:	89 04 24             	mov    %eax,(%esp)
f01035cd:	e8 a2 dd ff ff       	call   f0101374 <page_lookup>
		if ( pp == NULL ) return -E_FAULT ; 
f01035d2:	85 c0                	test   %eax,%eax
f01035d4:	74 19                	je     f01035ef <user_mem_check+0x6c>
		if ( ! ( ( *npte ) & PTE_P ) ) return -E_FAULT ; 
f01035d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035d9:	8b 00                	mov    (%eax),%eax
f01035db:	a8 01                	test   $0x1,%al
f01035dd:	74 10                	je     f01035ef <user_mem_check+0x6c>
		if ( ( ( * npte ) & perm ) != perm ) return -E_FAULT ;   
f01035df:	23 45 14             	and    0x14(%ebp),%eax
f01035e2:	39 45 14             	cmp    %eax,0x14(%ebp)
f01035e5:	75 08                	jne    f01035ef <user_mem_check+0x6c>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{

	uintptr_t sv = ( ( uintptr_t ) va ) & ( ~0xFFF ) ;
	uintptr_t ev = ( ( ( uintptr_t ) va ) + len - 1 + PGSIZE ) & (~0xFFF);
	for ( ; sv != ev ; sv += PGSIZE ) {
f01035e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01035ed:	eb 07                	jmp    f01035f6 <user_mem_check+0x73>
		pte_t * npte ;
		user_mem_check_addr = sv ; 
		if ( user_mem_check_addr < ( uintptr_t) va ) 
			user_mem_check_addr = ( uintptr_t) va ; 
		struct PageInfo * pp = page_lookup( env->env_pgdir , ( void * ) sv , &npte ) ; 
		if ( pp == NULL ) return -E_FAULT ; 
f01035ef:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01035f4:	eb 0a                	jmp    f0103600 <user_mem_check+0x7d>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{

	uintptr_t sv = ( ( uintptr_t ) va ) & ( ~0xFFF ) ;
	uintptr_t ev = ( ( ( uintptr_t ) va ) + len - 1 + PGSIZE ) & (~0xFFF);
	for ( ; sv != ev ; sv += PGSIZE ) {
f01035f6:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01035f9:	75 b5                	jne    f01035b0 <user_mem_check+0x2d>
		struct PageInfo * pp = page_lookup( env->env_pgdir , ( void * ) sv , &npte ) ; 
		if ( pp == NULL ) return -E_FAULT ; 
		if ( ! ( ( *npte ) & PTE_P ) ) return -E_FAULT ; 
		if ( ( ( * npte ) & perm ) != perm ) return -E_FAULT ;   
	}
	return 0;
f01035fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103600:	83 c4 2c             	add    $0x2c,%esp
f0103603:	5b                   	pop    %ebx
f0103604:	5e                   	pop    %esi
f0103605:	5f                   	pop    %edi
f0103606:	5d                   	pop    %ebp
f0103607:	c3                   	ret    

f0103608 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103608:	55                   	push   %ebp
f0103609:	89 e5                	mov    %esp,%ebp
f010360b:	53                   	push   %ebx
f010360c:	83 ec 14             	sub    $0x14,%esp
f010360f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103612:	8b 45 14             	mov    0x14(%ebp),%eax
f0103615:	83 c8 04             	or     $0x4,%eax
f0103618:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010361c:	8b 45 10             	mov    0x10(%ebp),%eax
f010361f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103623:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103626:	89 44 24 04          	mov    %eax,0x4(%esp)
f010362a:	89 1c 24             	mov    %ebx,(%esp)
f010362d:	e8 51 ff ff ff       	call   f0103583 <user_mem_check>
f0103632:	85 c0                	test   %eax,%eax
f0103634:	79 24                	jns    f010365a <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103636:	a1 3c f2 23 f0       	mov    0xf023f23c,%eax
f010363b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010363f:	8b 43 48             	mov    0x48(%ebx),%eax
f0103642:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103646:	c7 04 24 d4 85 10 f0 	movl   $0xf01085d4,(%esp)
f010364d:	e8 2a 0a 00 00       	call   f010407c <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103652:	89 1c 24             	mov    %ebx,(%esp)
f0103655:	e8 09 07 00 00       	call   f0103d63 <env_destroy>
	}
}
f010365a:	83 c4 14             	add    $0x14,%esp
f010365d:	5b                   	pop    %ebx
f010365e:	5d                   	pop    %ebp
f010365f:	c3                   	ret    

f0103660 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103660:	55                   	push   %ebp
f0103661:	89 e5                	mov    %esp,%ebp
f0103663:	57                   	push   %edi
f0103664:	56                   	push   %esi
f0103665:	53                   	push   %ebx
f0103666:	83 ec 1c             	sub    $0x1c,%esp
f0103669:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start_ptr = ( ( uint32_t ) va ) & ( ~0xFFF ) ;
f010366b:	89 d3                	mov    %edx,%ebx
f010366d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t va_end_ptr = ( ( uint32_t ) va + len + PGSIZE - 1 ) & ( ~0xFFF ) ;   	
f0103673:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010367a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
       	
	for ( ; va_start_ptr != va_end_ptr ; va_start_ptr += PGSIZE ) {
f0103680:	eb 6e                	jmp    f01036f0 <region_alloc+0x90>
		struct PageInfo * pp = page_alloc(0) ; 
f0103682:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103689:	e8 db da ff ff       	call   f0101169 <page_alloc>
		if ( pp == NULL ) 
f010368e:	85 c0                	test   %eax,%eax
f0103690:	75 1c                	jne    f01036ae <region_alloc+0x4e>
			panic("region_alloc : run out of pages!\n");
f0103692:	c7 44 24 08 1c 89 10 	movl   $0xf010891c,0x8(%esp)
f0103699:	f0 
f010369a:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f01036a1:	00 
f01036a2:	c7 04 24 3e 89 10 f0 	movl   $0xf010893e,(%esp)
f01036a9:	e8 92 c9 ff ff       	call   f0100040 <_panic>
		int result = page_insert( e->env_pgdir , pp , ( void * )va_start_ptr , PTE_U | PTE_W ) ;
f01036ae:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01036b5:	00 
f01036b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01036ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036be:	8b 47 60             	mov    0x60(%edi),%eax
f01036c1:	89 04 24             	mov    %eax,(%esp)
f01036c4:	e8 a8 dd ff ff       	call   f0101471 <page_insert>
  		if ( result == -E_NO_MEM ) 
f01036c9:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01036cc:	75 1c                	jne    f01036ea <region_alloc+0x8a>
			panic("region_alloc : run out of pages!\n");
f01036ce:	c7 44 24 08 1c 89 10 	movl   $0xf010891c,0x8(%esp)
f01036d5:	f0 
f01036d6:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
f01036dd:	00 
f01036de:	c7 04 24 3e 89 10 f0 	movl   $0xf010893e,(%esp)
f01036e5:	e8 56 c9 ff ff       	call   f0100040 <_panic>
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start_ptr = ( ( uint32_t ) va ) & ( ~0xFFF ) ;
	uintptr_t va_end_ptr = ( ( uint32_t ) va + len + PGSIZE - 1 ) & ( ~0xFFF ) ;   	
       	
	for ( ; va_start_ptr != va_end_ptr ; va_start_ptr += PGSIZE ) {
f01036ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01036f0:	39 f3                	cmp    %esi,%ebx
f01036f2:	75 8e                	jne    f0103682 <region_alloc+0x22>
			panic("region_alloc : run out of pages!\n");
		int result = page_insert( e->env_pgdir , pp , ( void * )va_start_ptr , PTE_U | PTE_W ) ;
  		if ( result == -E_NO_MEM ) 
			panic("region_alloc : run out of pages!\n");
	}
}
f01036f4:	83 c4 1c             	add    $0x1c,%esp
f01036f7:	5b                   	pop    %ebx
f01036f8:	5e                   	pop    %esi
f01036f9:	5f                   	pop    %edi
f01036fa:	5d                   	pop    %ebp
f01036fb:	c3                   	ret    

f01036fc <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01036fc:	55                   	push   %ebp
f01036fd:	89 e5                	mov    %esp,%ebp
f01036ff:	56                   	push   %esi
f0103700:	53                   	push   %ebx
f0103701:	8b 45 08             	mov    0x8(%ebp),%eax
f0103704:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103707:	85 c0                	test   %eax,%eax
f0103709:	75 1a                	jne    f0103725 <envid2env+0x29>
		*env_store = curenv;
f010370b:	e8 a9 38 00 00       	call   f0106fb9 <cpunum>
f0103710:	6b c0 74             	imul   $0x74,%eax,%eax
f0103713:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103719:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010371c:	89 01                	mov    %eax,(%ecx)
		return 0;
f010371e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103723:	eb 70                	jmp    f0103795 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103725:	89 c3                	mov    %eax,%ebx
f0103727:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010372d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103730:	03 1d 48 f2 23 f0    	add    0xf023f248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103736:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010373a:	74 05                	je     f0103741 <envid2env+0x45>
f010373c:	39 43 48             	cmp    %eax,0x48(%ebx)
f010373f:	74 10                	je     f0103751 <envid2env+0x55>
		*env_store = 0;
f0103741:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103744:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010374a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010374f:	eb 44                	jmp    f0103795 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103751:	84 d2                	test   %dl,%dl
f0103753:	74 36                	je     f010378b <envid2env+0x8f>
f0103755:	e8 5f 38 00 00       	call   f0106fb9 <cpunum>
f010375a:	6b c0 74             	imul   $0x74,%eax,%eax
f010375d:	39 98 28 10 24 f0    	cmp    %ebx,-0xfdbefd8(%eax)
f0103763:	74 26                	je     f010378b <envid2env+0x8f>
f0103765:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103768:	e8 4c 38 00 00       	call   f0106fb9 <cpunum>
f010376d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103770:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103776:	3b 70 48             	cmp    0x48(%eax),%esi
f0103779:	74 10                	je     f010378b <envid2env+0x8f>
		*env_store = 0;
f010377b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010377e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103784:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103789:	eb 0a                	jmp    f0103795 <envid2env+0x99>
	}

	*env_store = e;
f010378b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010378e:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103790:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103795:	5b                   	pop    %ebx
f0103796:	5e                   	pop    %esi
f0103797:	5d                   	pop    %ebp
f0103798:	c3                   	ret    

f0103799 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103799:	55                   	push   %ebp
f010379a:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010379c:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f01037a1:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01037a4:	b8 23 00 00 00       	mov    $0x23,%eax
f01037a9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01037ab:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01037ad:	b0 10                	mov    $0x10,%al
f01037af:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01037b1:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01037b3:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01037b5:	ea bc 37 10 f0 08 00 	ljmp   $0x8,$0xf01037bc
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01037bc:	b0 00                	mov    $0x0,%al
f01037be:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01037c1:	5d                   	pop    %ebp
f01037c2:	c3                   	ret    

f01037c3 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01037c3:	55                   	push   %ebp
f01037c4:	89 e5                	mov    %esp,%ebp
f01037c6:	56                   	push   %esi
f01037c7:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL ; 
	size_t ptr = NENV - 1 ; 
	for ( ; ptr != -1 ; ptr -- ) {
		envs[ptr].env_link = env_free_list ; 
f01037c8:	8b 35 48 f2 23 f0    	mov    0xf023f248,%esi
f01037ce:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01037d4:	ba 00 04 00 00       	mov    $0x400,%edx
f01037d9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01037de:	89 c3                	mov    %eax,%ebx
f01037e0:	89 48 44             	mov    %ecx,0x44(%eax)
		envs[ptr].env_id = 0 ; 
f01037e3:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
f01037ea:	83 e8 7c             	sub    $0x7c,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL ; 
	size_t ptr = NENV - 1 ; 
	for ( ; ptr != -1 ; ptr -- ) {
f01037ed:	83 ea 01             	sub    $0x1,%edx
f01037f0:	74 04                	je     f01037f6 <env_init+0x33>
		envs[ptr].env_link = env_free_list ; 
		envs[ptr].env_id = 0 ; 
		env_free_list = &(envs[ptr]) ; 
f01037f2:	89 d9                	mov    %ebx,%ecx
f01037f4:	eb e8                	jmp    f01037de <env_init+0x1b>
f01037f6:	89 35 4c f2 23 f0    	mov    %esi,0xf023f24c
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f01037fc:	e8 98 ff ff ff       	call   f0103799 <env_init_percpu>
}
f0103801:	5b                   	pop    %ebx
f0103802:	5e                   	pop    %esi
f0103803:	5d                   	pop    %ebp
f0103804:	c3                   	ret    

f0103805 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103805:	55                   	push   %ebp
f0103806:	89 e5                	mov    %esp,%ebp
f0103808:	57                   	push   %edi
f0103809:	56                   	push   %esi
f010380a:	53                   	push   %ebx
f010380b:	83 ec 2c             	sub    $0x2c,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010380e:	8b 1d 4c f2 23 f0    	mov    0xf023f24c,%ebx
f0103814:	85 db                	test   %ebx,%ebx
f0103816:	0f 84 b3 01 00 00    	je     f01039cf <env_alloc+0x1ca>
{
	int i;	
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010381c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103823:	e8 41 d9 ff ff       	call   f0101169 <page_alloc>
f0103828:	85 c0                	test   %eax,%eax
f010382a:	0f 84 a6 01 00 00    	je     f01039d6 <env_alloc+0x1d1>
f0103830:	89 c6                	mov    %eax,%esi
f0103832:	2b 35 90 fe 23 f0    	sub    0xf023fe90,%esi
f0103838:	c1 fe 03             	sar    $0x3,%esi
f010383b:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010383e:	89 f2                	mov    %esi,%edx
f0103840:	c1 ea 0c             	shr    $0xc,%edx
f0103843:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0103849:	72 20                	jb     f010386b <env_alloc+0x66>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010384b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010384f:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0103856:	f0 
f0103857:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010385e:	00 
f010385f:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0103866:	e8 d5 c7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010386b:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
f0103871:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103874:	ba 00 00 00 00       	mov    $0x0,%edx
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	pde_t * tmp_pgdir = ( pde_t * ) page2kva(p);
	for ( i = 0  ; i < NPDENTRIES  ; i ++ ) {
		tmp_pgdir[i] = kern_pgdir[i];	
f0103879:	8b 0d 8c fe 23 f0    	mov    0xf023fe8c,%ecx
f010387f:	8b 0c 11             	mov    (%ecx,%edx,1),%ecx
f0103882:	89 8c 32 00 00 00 f0 	mov    %ecx,-0x10000000(%edx,%esi,1)
f0103889:	83 c2 04             	add    $0x4,%edx
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	pde_t * tmp_pgdir = ( pde_t * ) page2kva(p);
	for ( i = 0  ; i < NPDENTRIES  ; i ++ ) {
f010388c:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0103892:	75 e5                	jne    f0103879 <env_alloc+0x74>
		tmp_pgdir[i] = kern_pgdir[i];	
	}
	( p->pp_ref ) ++ ;  
f0103894:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	for ( i = 0 ; i <  PDX(UTOP) ; i ++ ) tmp_pgdir[i] = 0   ; 
f0103899:	b8 00 00 00 00       	mov    $0x0,%eax
f010389e:	66 ba 00 00          	mov    $0x0,%dx
f01038a2:	c7 04 97 00 00 00 00 	movl   $0x0,(%edi,%edx,4)
f01038a9:	83 c0 01             	add    $0x1,%eax
f01038ac:	89 c2                	mov    %eax,%edx
f01038ae:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01038b3:	75 ed                	jne    f01038a2 <env_alloc+0x9d>
	e->env_pgdir = tmp_pgdir ; 
f01038b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038b8:	89 43 60             	mov    %eax,0x60(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038c0:	77 20                	ja     f01038e2 <env_alloc+0xdd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038c6:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f01038cd:	f0 
f01038ce:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f01038d5:	00 
f01038d6:	c7 04 24 3e 89 10 f0 	movl   $0xf010893e,(%esp)
f01038dd:	e8 5e c7 ff ff       	call   f0100040 <_panic>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01038e2:	83 ce 05             	or     $0x5,%esi
f01038e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038e8:	89 b0 f4 0e 00 00    	mov    %esi,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01038ee:	8b 43 48             	mov    0x48(%ebx),%eax
f01038f1:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01038f6:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01038fb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103900:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103903:	89 da                	mov    %ebx,%edx
f0103905:	2b 15 48 f2 23 f0    	sub    0xf023f248,%edx
f010390b:	c1 fa 02             	sar    $0x2,%edx
f010390e:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103914:	09 d0                	or     %edx,%eax
f0103916:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103919:	8b 45 0c             	mov    0xc(%ebp),%eax
f010391c:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010391f:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103926:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010392d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103934:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010393b:	00 
f010393c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103943:	00 
f0103944:	89 1c 24             	mov    %ebx,(%esp)
f0103947:	e8 1b 30 00 00       	call   f0106967 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010394c:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103952:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103958:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010395e:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103965:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags = (e->env_tf.tf_eflags) | FL_IF ;
f010396b:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103972:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103979:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010397d:	8b 43 44             	mov    0x44(%ebx),%eax
f0103980:	a3 4c f2 23 f0       	mov    %eax,0xf023f24c
	*newenv_store = e;
f0103985:	8b 45 08             	mov    0x8(%ebp),%eax
f0103988:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010398a:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010398d:	e8 27 36 00 00       	call   f0106fb9 <cpunum>
f0103992:	6b d0 74             	imul   $0x74,%eax,%edx
f0103995:	b8 00 00 00 00       	mov    $0x0,%eax
f010399a:	83 ba 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%edx)
f01039a1:	74 11                	je     f01039b4 <env_alloc+0x1af>
f01039a3:	e8 11 36 00 00       	call   f0106fb9 <cpunum>
f01039a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01039ab:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01039b1:	8b 40 48             	mov    0x48(%eax),%eax
f01039b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01039b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039bc:	c7 04 24 49 89 10 f0 	movl   $0xf0108949,(%esp)
f01039c3:	e8 b4 06 00 00       	call   f010407c <cprintf>
	return 0;
f01039c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01039cd:	eb 0c                	jmp    f01039db <env_alloc+0x1d6>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01039cf:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01039d4:	eb 05                	jmp    f01039db <env_alloc+0x1d6>
	int i;	
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01039d6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01039db:	83 c4 2c             	add    $0x2c,%esp
f01039de:	5b                   	pop    %ebx
f01039df:	5e                   	pop    %esi
f01039e0:	5f                   	pop    %edi
f01039e1:	5d                   	pop    %ebp
f01039e2:	c3                   	ret    

f01039e3 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01039e3:	55                   	push   %ebp
f01039e4:	89 e5                	mov    %esp,%ebp
f01039e6:	57                   	push   %edi
f01039e7:	56                   	push   %esi
f01039e8:	53                   	push   %ebx
f01039e9:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env * newEnv = NULL ; 
f01039ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	env_alloc( &newEnv , 0 ) ;
f01039f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039fa:	00 
f01039fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01039fe:	89 04 24             	mov    %eax,(%esp)
f0103a01:	e8 ff fd ff ff       	call   f0103805 <env_alloc>
    	newEnv->env_type = type ; 
f0103a06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a09:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a0c:	89 47 50             	mov    %eax,0x50(%edi)
	//  What?  (See env_run() and env_pop_tf() below.)
	// LAB 3: Your code here.
	struct Elf *ELFHDR = ( struct Elf * ) binary ; 
	
	struct Proghdr *ph , *eph ; 
	ph = ( struct Proghdr * ) ( ( uint8_t * ) ELFHDR + ELFHDR->e_phoff) ;
f0103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a12:	89 c3                	mov    %eax,%ebx
f0103a14:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum ; 
f0103a17:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103a1b:	c1 e0 05             	shl    $0x5,%eax
f0103a1e:	01 d8                	add    %ebx,%eax
f0103a20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103a23:	e9 0b 01 00 00       	jmp    f0103b33 <env_create+0x150>
	for ( ; ph < eph ; ph ++ ) {
		if ( ph->p_type != ELF_PROG_LOAD ) continue ; 
f0103a28:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103a2b:	0f 85 ff 00 00 00    	jne    f0103b30 <env_create+0x14d>
		region_alloc( e , ( void * )ph->p_va , ph->p_memsz) ; 
f0103a31:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103a34:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a37:	89 f8                	mov    %edi,%eax
f0103a39:	e8 22 fc ff ff       	call   f0103660 <region_alloc>
		struct PageInfo * pp = page_lookup( e->env_pgdir , ( void * )  ph->p_va , NULL ) ;
f0103a3e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103a45:	00 
f0103a46:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a4d:	8b 47 60             	mov    0x60(%edi),%eax
f0103a50:	89 04 24             	mov    %eax,(%esp)
f0103a53:	e8 1c d9 ff ff       	call   f0101374 <page_lookup>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a58:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0103a5e:	c1 f8 03             	sar    $0x3,%eax
f0103a61:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a64:	89 c2                	mov    %eax,%edx
f0103a66:	c1 ea 0c             	shr    $0xc,%edx
f0103a69:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0103a6f:	72 20                	jb     f0103a91 <env_create+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a71:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a75:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0103a7c:	f0 
f0103a7d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103a84:	00 
f0103a85:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0103a8c:	e8 af c5 ff ff       	call   f0100040 <_panic>
		uint32_t now_ptr = ( ( uint32_t ) page2kva(pp) ) + ( ( 0xFFF ) & ( ( unsigned ) ph->p_va ) );
f0103a91:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a94:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0103a9a:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
		uint32_t i = 0 ; 
f0103aa1:	be 00 00 00 00       	mov    $0x0,%esi
f0103aa6:	eb 7f                	jmp    f0103b27 <env_create+0x144>
		for ( ; i < ph->p_memsz  ; i ++ ) { 
			if ( ( ( unsigned ) ( ph->p_va + i ) & ( 0xFFF ) ) == 0 ) {
f0103aa8:	89 f2                	mov    %esi,%edx
f0103aaa:	03 53 08             	add    0x8(%ebx),%edx
f0103aad:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0103ab3:	75 55                	jne    f0103b0a <env_create+0x127>
				pp = page_lookup( e->env_pgdir , ( void * ) ( ( ph->p_va ) + i ) , NULL ) ; 
f0103ab5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103abc:	00 
f0103abd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103ac1:	8b 47 60             	mov    0x60(%edi),%eax
f0103ac4:	89 04 24             	mov    %eax,(%esp)
f0103ac7:	e8 a8 d8 ff ff       	call   f0101374 <page_lookup>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103acc:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0103ad2:	c1 f8 03             	sar    $0x3,%eax
f0103ad5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103ad8:	89 c2                	mov    %eax,%edx
f0103ada:	c1 ea 0c             	shr    $0xc,%edx
f0103add:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0103ae3:	72 20                	jb     f0103b05 <env_create+0x122>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103ae5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ae9:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0103af0:	f0 
f0103af1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103af8:	00 
f0103af9:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0103b00:	e8 3b c5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103b05:	2d 00 00 00 10       	sub    $0x10000000,%eax
				now_ptr = ( uint32_t ) page2kva(pp);	 
			}
			if ( i < ph->p_filesz ) 
f0103b0a:	3b 73 10             	cmp    0x10(%ebx),%esi
f0103b0d:	73 0f                	jae    f0103b1e <env_create+0x13b>
				* ( ( uint8_t * ) ( now_ptr ) ) = * ( binary + ph->p_offset + i ) ;
f0103b0f:	89 f2                	mov    %esi,%edx
f0103b11:	03 55 08             	add    0x8(%ebp),%edx
f0103b14:	03 53 04             	add    0x4(%ebx),%edx
f0103b17:	0f b6 12             	movzbl (%edx),%edx
f0103b1a:	88 10                	mov    %dl,(%eax)
f0103b1c:	eb 03                	jmp    f0103b21 <env_create+0x13e>
			else
				* ( ( uint8_t * ) ( now_ptr ) ) = 0 ;
f0103b1e:	c6 00 00             	movb   $0x0,(%eax)
			now_ptr ++ ; 
f0103b21:	83 c0 01             	add    $0x1,%eax
		if ( ph->p_type != ELF_PROG_LOAD ) continue ; 
		region_alloc( e , ( void * )ph->p_va , ph->p_memsz) ; 
		struct PageInfo * pp = page_lookup( e->env_pgdir , ( void * )  ph->p_va , NULL ) ;
		uint32_t now_ptr = ( ( uint32_t ) page2kva(pp) ) + ( ( 0xFFF ) & ( ( unsigned ) ph->p_va ) );
		uint32_t i = 0 ; 
		for ( ; i < ph->p_memsz  ; i ++ ) { 
f0103b24:	83 c6 01             	add    $0x1,%esi
f0103b27:	3b 73 14             	cmp    0x14(%ebx),%esi
f0103b2a:	0f 82 78 ff ff ff    	jb     f0103aa8 <env_create+0xc5>
	struct Elf *ELFHDR = ( struct Elf * ) binary ; 
	
	struct Proghdr *ph , *eph ; 
	ph = ( struct Proghdr * ) ( ( uint8_t * ) ELFHDR + ELFHDR->e_phoff) ;
	eph = ph + ELFHDR->e_phnum ; 
	for ( ; ph < eph ; ph ++ ) {
f0103b30:	83 c3 20             	add    $0x20,%ebx
f0103b33:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103b36:	0f 87 ec fe ff ff    	ja     f0103a28 <env_create+0x45>
			else
				* ( ( uint8_t * ) ( now_ptr ) ) = 0 ;
			now_ptr ++ ; 
		}
	} 
	e->env_tf.tf_eip = ELFHDR->e_entry ; 
f0103b3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b3f:	8b 40 18             	mov    0x18(%eax),%eax
f0103b42:	89 47 30             	mov    %eax,0x30(%edi)
	
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	region_alloc( e , ( void * ) ( USTACKTOP - PGSIZE ) , PGSIZE ) ;
f0103b45:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103b4a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103b4f:	89 f8                	mov    %edi,%eax
f0103b51:	e8 0a fb ff ff       	call   f0103660 <region_alloc>
	// LAB 3: Your code here.
	struct Env * newEnv = NULL ; 
	env_alloc( &newEnv , 0 ) ;
    	newEnv->env_type = type ; 
	load_icode( newEnv , binary) ;  	
}
f0103b56:	83 c4 3c             	add    $0x3c,%esp
f0103b59:	5b                   	pop    %ebx
f0103b5a:	5e                   	pop    %esi
f0103b5b:	5f                   	pop    %edi
f0103b5c:	5d                   	pop    %ebp
f0103b5d:	c3                   	ret    

f0103b5e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103b5e:	55                   	push   %ebp
f0103b5f:	89 e5                	mov    %esp,%ebp
f0103b61:	57                   	push   %edi
f0103b62:	56                   	push   %esi
f0103b63:	53                   	push   %ebx
f0103b64:	83 ec 2c             	sub    $0x2c,%esp
f0103b67:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103b6a:	e8 4a 34 00 00       	call   f0106fb9 <cpunum>
f0103b6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b72:	39 b8 28 10 24 f0    	cmp    %edi,-0xfdbefd8(%eax)
f0103b78:	75 34                	jne    f0103bae <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103b7a:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b7f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b84:	77 20                	ja     f0103ba6 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b86:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b8a:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0103b91:	f0 
f0103b92:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
f0103b99:	00 
f0103b9a:	c7 04 24 3e 89 10 f0 	movl   $0xf010893e,(%esp)
f0103ba1:	e8 9a c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ba6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103bab:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103bae:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103bb1:	e8 03 34 00 00       	call   f0106fb9 <cpunum>
f0103bb6:	6b d0 74             	imul   $0x74,%eax,%edx
f0103bb9:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bbe:	83 ba 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%edx)
f0103bc5:	74 11                	je     f0103bd8 <env_free+0x7a>
f0103bc7:	e8 ed 33 00 00       	call   f0106fb9 <cpunum>
f0103bcc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bcf:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103bd5:	8b 40 48             	mov    0x48(%eax),%eax
f0103bd8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103be0:	c7 04 24 5e 89 10 f0 	movl   $0xf010895e,(%esp)
f0103be7:	e8 90 04 00 00       	call   f010407c <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bec:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103bf3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103bf6:	89 c8                	mov    %ecx,%eax
f0103bf8:	c1 e0 02             	shl    $0x2,%eax
f0103bfb:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103bfe:	8b 47 60             	mov    0x60(%edi),%eax
f0103c01:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103c04:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103c0a:	0f 84 b7 00 00 00    	je     f0103cc7 <env_free+0x169>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103c10:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c16:	89 f0                	mov    %esi,%eax
f0103c18:	c1 e8 0c             	shr    $0xc,%eax
f0103c1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103c1e:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0103c24:	72 20                	jb     f0103c46 <env_free+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103c26:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103c2a:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0103c31:	f0 
f0103c32:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f0103c39:	00 
f0103c3a:	c7 04 24 3e 89 10 f0 	movl   $0xf010893e,(%esp)
f0103c41:	e8 fa c3 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103c46:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c49:	c1 e0 16             	shl    $0x16,%eax
f0103c4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103c54:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103c5b:	01 
f0103c5c:	74 17                	je     f0103c75 <env_free+0x117>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103c5e:	89 d8                	mov    %ebx,%eax
f0103c60:	c1 e0 0c             	shl    $0xc,%eax
f0103c63:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103c66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c6a:	8b 47 60             	mov    0x60(%edi),%eax
f0103c6d:	89 04 24             	mov    %eax,(%esp)
f0103c70:	e8 ac d7 ff ff       	call   f0101421 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103c75:	83 c3 01             	add    $0x1,%ebx
f0103c78:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103c7e:	75 d4                	jne    f0103c54 <env_free+0xf6>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103c80:	8b 47 60             	mov    0x60(%edi),%eax
f0103c83:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103c86:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c8d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103c90:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0103c96:	72 1c                	jb     f0103cb4 <env_free+0x156>
		panic("pa2page called with invalid pa");
f0103c98:	c7 44 24 08 a0 7d 10 	movl   $0xf0107da0,0x8(%esp)
f0103c9f:	f0 
f0103ca0:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103ca7:	00 
f0103ca8:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0103caf:	e8 8c c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103cb4:	a1 90 fe 23 f0       	mov    0xf023fe90,%eax
f0103cb9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103cbc:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103cbf:	89 04 24             	mov    %eax,(%esp)
f0103cc2:	e8 89 d5 ff ff       	call   f0101250 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103cc7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103ccb:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103cd2:	0f 85 1b ff ff ff    	jne    f0103bf3 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103cd8:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cdb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ce0:	77 20                	ja     f0103d02 <env_free+0x1a4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ce2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ce6:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0103ced:	f0 
f0103cee:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f0103cf5:	00 
f0103cf6:	c7 04 24 3e 89 10 f0 	movl   $0xf010893e,(%esp)
f0103cfd:	e8 3e c3 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103d02:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103d09:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103d0e:	c1 e8 0c             	shr    $0xc,%eax
f0103d11:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0103d17:	72 1c                	jb     f0103d35 <env_free+0x1d7>
		panic("pa2page called with invalid pa");
f0103d19:	c7 44 24 08 a0 7d 10 	movl   $0xf0107da0,0x8(%esp)
f0103d20:	f0 
f0103d21:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103d28:	00 
f0103d29:	c7 04 24 09 86 10 f0 	movl   $0xf0108609,(%esp)
f0103d30:	e8 0b c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103d35:	8b 15 90 fe 23 f0    	mov    0xf023fe90,%edx
f0103d3b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103d3e:	89 04 24             	mov    %eax,(%esp)
f0103d41:	e8 0a d5 ff ff       	call   f0101250 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103d46:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103d4d:	a1 4c f2 23 f0       	mov    0xf023f24c,%eax
f0103d52:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103d55:	89 3d 4c f2 23 f0    	mov    %edi,0xf023f24c
}
f0103d5b:	83 c4 2c             	add    $0x2c,%esp
f0103d5e:	5b                   	pop    %ebx
f0103d5f:	5e                   	pop    %esi
f0103d60:	5f                   	pop    %edi
f0103d61:	5d                   	pop    %ebp
f0103d62:	c3                   	ret    

f0103d63 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103d63:	55                   	push   %ebp
f0103d64:	89 e5                	mov    %esp,%ebp
f0103d66:	53                   	push   %ebx
f0103d67:	83 ec 14             	sub    $0x14,%esp
f0103d6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103d6d:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103d71:	75 19                	jne    f0103d8c <env_destroy+0x29>
f0103d73:	e8 41 32 00 00       	call   f0106fb9 <cpunum>
f0103d78:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d7b:	39 98 28 10 24 f0    	cmp    %ebx,-0xfdbefd8(%eax)
f0103d81:	74 09                	je     f0103d8c <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103d83:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103d8a:	eb 2f                	jmp    f0103dbb <env_destroy+0x58>
	}

	env_free(e);
f0103d8c:	89 1c 24             	mov    %ebx,(%esp)
f0103d8f:	e8 ca fd ff ff       	call   f0103b5e <env_free>

	if (curenv == e) {
f0103d94:	e8 20 32 00 00       	call   f0106fb9 <cpunum>
f0103d99:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d9c:	39 98 28 10 24 f0    	cmp    %ebx,-0xfdbefd8(%eax)
f0103da2:	75 17                	jne    f0103dbb <env_destroy+0x58>
		curenv = NULL;
f0103da4:	e8 10 32 00 00       	call   f0106fb9 <cpunum>
f0103da9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dac:	c7 80 28 10 24 f0 00 	movl   $0x0,-0xfdbefd8(%eax)
f0103db3:	00 00 00 
		sched_yield();
f0103db6:	e8 04 13 00 00       	call   f01050bf <sched_yield>
	}
}
f0103dbb:	83 c4 14             	add    $0x14,%esp
f0103dbe:	5b                   	pop    %ebx
f0103dbf:	5d                   	pop    %ebp
f0103dc0:	c3                   	ret    

f0103dc1 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103dc1:	55                   	push   %ebp
f0103dc2:	89 e5                	mov    %esp,%ebp
f0103dc4:	53                   	push   %ebx
f0103dc5:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103dc8:	e8 ec 31 00 00       	call   f0106fb9 <cpunum>
f0103dcd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dd0:	8b 98 28 10 24 f0    	mov    -0xfdbefd8(%eax),%ebx
f0103dd6:	e8 de 31 00 00       	call   f0106fb9 <cpunum>
f0103ddb:	89 43 5c             	mov    %eax,0x5c(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103dde:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0103de5:	e8 f9 34 00 00       	call   f01072e3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103dea:	f3 90                	pause  

	unlock_kernel();
	__asm __volatile("movl %0,%%esp\n"
f0103dec:	8b 65 08             	mov    0x8(%ebp),%esp
f0103def:	61                   	popa   
f0103df0:	07                   	pop    %es
f0103df1:	1f                   	pop    %ds
f0103df2:	83 c4 08             	add    $0x8,%esp
f0103df5:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103df6:	c7 44 24 08 74 89 10 	movl   $0xf0108974,0x8(%esp)
f0103dfd:	f0 
f0103dfe:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
f0103e05:	00 
f0103e06:	c7 04 24 3e 89 10 f0 	movl   $0xf010893e,(%esp)
f0103e0d:	e8 2e c2 ff ff       	call   f0100040 <_panic>

f0103e12 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103e12:	55                   	push   %ebp
f0103e13:	89 e5                	mov    %esp,%ebp
f0103e15:	83 ec 18             	sub    $0x18,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if ( ( curenv ) && ( curenv->env_status == ENV_RUNNING ) )
f0103e18:	e8 9c 31 00 00       	call   f0106fb9 <cpunum>
f0103e1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e20:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0103e27:	74 29                	je     f0103e52 <env_run+0x40>
f0103e29:	e8 8b 31 00 00       	call   f0106fb9 <cpunum>
f0103e2e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e31:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e37:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103e3b:	75 15                	jne    f0103e52 <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE ;  
f0103e3d:	e8 77 31 00 00       	call   f0106fb9 <cpunum>
f0103e42:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e45:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e4b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e ;
f0103e52:	e8 62 31 00 00       	call   f0106fb9 <cpunum>
f0103e57:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e5a:	8b 55 08             	mov    0x8(%ebp),%edx
f0103e5d:	89 90 28 10 24 f0    	mov    %edx,-0xfdbefd8(%eax)
	curenv -> env_status = ENV_RUNNING ; 
f0103e63:	e8 51 31 00 00       	call   f0106fb9 <cpunum>
f0103e68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e6b:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e71:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	( curenv -> env_runs ) ++ ;
f0103e78:	e8 3c 31 00 00       	call   f0106fb9 <cpunum>
f0103e7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e80:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e86:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3( PADDR( curenv -> env_pgdir ) ) ; 	
f0103e8a:	e8 2a 31 00 00       	call   f0106fb9 <cpunum>
f0103e8f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e92:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e98:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e9b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ea0:	77 20                	ja     f0103ec2 <env_run+0xb0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ea2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ea6:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f0103ead:	f0 
f0103eae:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
f0103eb5:	00 
f0103eb6:	c7 04 24 3e 89 10 f0 	movl   $0xf010893e,(%esp)
f0103ebd:	e8 7e c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ec2:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ec7:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf( &curenv->env_tf ) ; 	
f0103eca:	e8 ea 30 00 00       	call   f0106fb9 <cpunum>
f0103ecf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ed2:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103ed8:	89 04 24             	mov    %eax,(%esp)
f0103edb:	e8 e1 fe ff ff       	call   f0103dc1 <env_pop_tf>

f0103ee0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103ee0:	55                   	push   %ebp
f0103ee1:	89 e5                	mov    %esp,%ebp
f0103ee3:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103ee7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103eec:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103eed:	b2 71                	mov    $0x71,%dl
f0103eef:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103ef0:	0f b6 c0             	movzbl %al,%eax
}
f0103ef3:	5d                   	pop    %ebp
f0103ef4:	c3                   	ret    

f0103ef5 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103ef5:	55                   	push   %ebp
f0103ef6:	89 e5                	mov    %esp,%ebp
f0103ef8:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103efc:	ba 70 00 00 00       	mov    $0x70,%edx
f0103f01:	ee                   	out    %al,(%dx)
f0103f02:	b2 71                	mov    $0x71,%dl
f0103f04:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f07:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103f08:	5d                   	pop    %ebp
f0103f09:	c3                   	ret    

f0103f0a <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103f0a:	55                   	push   %ebp
f0103f0b:	89 e5                	mov    %esp,%ebp
f0103f0d:	56                   	push   %esi
f0103f0e:	53                   	push   %ebx
f0103f0f:	83 ec 10             	sub    $0x10,%esp
f0103f12:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103f15:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103f1b:	80 3d 50 f2 23 f0 00 	cmpb   $0x0,0xf023f250
f0103f22:	74 4e                	je     f0103f72 <irq_setmask_8259A+0x68>
f0103f24:	89 c6                	mov    %eax,%esi
f0103f26:	ba 21 00 00 00       	mov    $0x21,%edx
f0103f2b:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103f2c:	66 c1 e8 08          	shr    $0x8,%ax
f0103f30:	b2 a1                	mov    $0xa1,%dl
f0103f32:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103f33:	c7 04 24 80 89 10 f0 	movl   $0xf0108980,(%esp)
f0103f3a:	e8 3d 01 00 00       	call   f010407c <cprintf>
	for (i = 0; i < 16; i++)
f0103f3f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103f44:	0f b7 f6             	movzwl %si,%esi
f0103f47:	f7 d6                	not    %esi
f0103f49:	0f a3 de             	bt     %ebx,%esi
f0103f4c:	73 10                	jae    f0103f5e <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103f4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f52:	c7 04 24 7b 8e 10 f0 	movl   $0xf0108e7b,(%esp)
f0103f59:	e8 1e 01 00 00       	call   f010407c <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103f5e:	83 c3 01             	add    $0x1,%ebx
f0103f61:	83 fb 10             	cmp    $0x10,%ebx
f0103f64:	75 e3                	jne    f0103f49 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103f66:	c7 04 24 e9 88 10 f0 	movl   $0xf01088e9,(%esp)
f0103f6d:	e8 0a 01 00 00       	call   f010407c <cprintf>
}
f0103f72:	83 c4 10             	add    $0x10,%esp
f0103f75:	5b                   	pop    %ebx
f0103f76:	5e                   	pop    %esi
f0103f77:	5d                   	pop    %ebp
f0103f78:	c3                   	ret    

f0103f79 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103f79:	c6 05 50 f2 23 f0 01 	movb   $0x1,0xf023f250
f0103f80:	ba 21 00 00 00       	mov    $0x21,%edx
f0103f85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f8a:	ee                   	out    %al,(%dx)
f0103f8b:	b2 a1                	mov    $0xa1,%dl
f0103f8d:	ee                   	out    %al,(%dx)
f0103f8e:	b2 20                	mov    $0x20,%dl
f0103f90:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f95:	ee                   	out    %al,(%dx)
f0103f96:	b2 21                	mov    $0x21,%dl
f0103f98:	b8 20 00 00 00       	mov    $0x20,%eax
f0103f9d:	ee                   	out    %al,(%dx)
f0103f9e:	b8 04 00 00 00       	mov    $0x4,%eax
f0103fa3:	ee                   	out    %al,(%dx)
f0103fa4:	b8 03 00 00 00       	mov    $0x3,%eax
f0103fa9:	ee                   	out    %al,(%dx)
f0103faa:	b2 a0                	mov    $0xa0,%dl
f0103fac:	b8 11 00 00 00       	mov    $0x11,%eax
f0103fb1:	ee                   	out    %al,(%dx)
f0103fb2:	b2 a1                	mov    $0xa1,%dl
f0103fb4:	b8 28 00 00 00       	mov    $0x28,%eax
f0103fb9:	ee                   	out    %al,(%dx)
f0103fba:	b8 02 00 00 00       	mov    $0x2,%eax
f0103fbf:	ee                   	out    %al,(%dx)
f0103fc0:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fc5:	ee                   	out    %al,(%dx)
f0103fc6:	b2 20                	mov    $0x20,%dl
f0103fc8:	b8 68 00 00 00       	mov    $0x68,%eax
f0103fcd:	ee                   	out    %al,(%dx)
f0103fce:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103fd3:	ee                   	out    %al,(%dx)
f0103fd4:	b2 a0                	mov    $0xa0,%dl
f0103fd6:	b8 68 00 00 00       	mov    $0x68,%eax
f0103fdb:	ee                   	out    %al,(%dx)
f0103fdc:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103fe1:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103fe2:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0103fe9:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103fed:	74 12                	je     f0104001 <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103fef:	55                   	push   %ebp
f0103ff0:	89 e5                	mov    %esp,%ebp
f0103ff2:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103ff5:	0f b7 c0             	movzwl %ax,%eax
f0103ff8:	89 04 24             	mov    %eax,(%esp)
f0103ffb:	e8 0a ff ff ff       	call   f0103f0a <irq_setmask_8259A>
}
f0104000:	c9                   	leave  
f0104001:	f3 c3                	repz ret 

f0104003 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104003:	55                   	push   %ebp
f0104004:	89 e5                	mov    %esp,%ebp
f0104006:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104009:	8b 45 08             	mov    0x8(%ebp),%eax
f010400c:	89 04 24             	mov    %eax,(%esp)
f010400f:	e8 76 c7 ff ff       	call   f010078a <cputchar>
	*cnt++;
}
f0104014:	c9                   	leave  
f0104015:	c3                   	ret    

f0104016 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104016:	55                   	push   %ebp
f0104017:	89 e5                	mov    %esp,%ebp
f0104019:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010401c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104023:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104026:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010402a:	8b 45 08             	mov    0x8(%ebp),%eax
f010402d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104031:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104034:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104038:	c7 04 24 03 40 10 f0 	movl   $0xf0104003,(%esp)
f010403f:	e8 6b 1e 00 00       	call   f0105eaf <vprintfmt>
	return cnt;
}
f0104044:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104047:	c9                   	leave  
f0104048:	c3                   	ret    

f0104049 <cvcprintf>:

int
cvcprintf(const char *fmt, va_list ap)
{
f0104049:	55                   	push   %ebp
f010404a:	89 e5                	mov    %esp,%ebp
f010404c:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010404f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	cvprintfmt((void*)putch, &cnt, fmt, ap);
f0104056:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104059:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010405d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104060:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104064:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104067:	89 44 24 04          	mov    %eax,0x4(%esp)
f010406b:	c7 04 24 03 40 10 f0 	movl   $0xf0104003,(%esp)
f0104072:	e8 0c 22 00 00       	call   f0106283 <cvprintfmt>
	return cnt;
}
f0104077:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010407a:	c9                   	leave  
f010407b:	c3                   	ret    

f010407c <cprintf>:


int
cprintf(const char *fmt, ...)
{
f010407c:	55                   	push   %ebp
f010407d:	89 e5                	mov    %esp,%ebp
f010407f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104082:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104085:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104089:	8b 45 08             	mov    0x8(%ebp),%eax
f010408c:	89 04 24             	mov    %eax,(%esp)
f010408f:	e8 82 ff ff ff       	call   f0104016 <vcprintf>
	va_end(ap);

	return cnt;
}
f0104094:	c9                   	leave  
f0104095:	c3                   	ret    

f0104096 <ccprintf>:

int
ccprintf(const char *fmt, ...)
{
f0104096:	55                   	push   %ebp
f0104097:	89 e5                	mov    %esp,%ebp
f0104099:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010409c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = cvcprintf(fmt, ap);
f010409f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01040a6:	89 04 24             	mov    %eax,(%esp)
f01040a9:	e8 9b ff ff ff       	call   f0104049 <cvcprintf>
	va_end(ap);

	return cnt;
}
f01040ae:	c9                   	leave  
f01040af:	c3                   	ret    

f01040b0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01040b0:	55                   	push   %ebp
f01040b1:	89 e5                	mov    %esp,%ebp
f01040b3:	57                   	push   %edi
f01040b4:	56                   	push   %esi
f01040b5:	53                   	push   %ebx
f01040b6:	83 ec 0c             	sub    $0xc,%esp
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	   
	(thiscpu->cpu_ts).ts_esp0 = KSTACKTOP - ( thiscpu->cpu_id ) * ( KSTKGAP + KSTKSIZE ) ;
f01040b9:	e8 fb 2e 00 00       	call   f0106fb9 <cpunum>
f01040be:	89 c3                	mov    %eax,%ebx
f01040c0:	e8 f4 2e 00 00       	call   f0106fb9 <cpunum>
f01040c5:	6b db 74             	imul   $0x74,%ebx,%ebx
f01040c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01040cb:	0f b6 80 20 10 24 f0 	movzbl -0xfdbefe0(%eax),%eax
f01040d2:	f7 d8                	neg    %eax
f01040d4:	c1 e0 10             	shl    $0x10,%eax
f01040d7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01040dc:	89 83 30 10 24 f0    	mov    %eax,-0xfdbefd0(%ebx)
	(thiscpu->cpu_ts).ts_ss0 = GD_KD;
f01040e2:	e8 d2 2e 00 00       	call   f0106fb9 <cpunum>
f01040e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ea:	66 c7 80 34 10 24 f0 	movw   $0x10,-0xfdbefcc(%eax)
f01040f1:	10 00 

	gdt[(thiscpu->cpu_id)+(GD_TSS0 >> 3)] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01040f3:	e8 c1 2e 00 00       	call   f0106fb9 <cpunum>
f01040f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01040fb:	0f b6 98 20 10 24 f0 	movzbl -0xfdbefe0(%eax),%ebx
f0104102:	83 c3 05             	add    $0x5,%ebx
f0104105:	e8 af 2e 00 00       	call   f0106fb9 <cpunum>
f010410a:	89 c7                	mov    %eax,%edi
f010410c:	e8 a8 2e 00 00       	call   f0106fb9 <cpunum>
f0104111:	89 c6                	mov    %eax,%esi
f0104113:	e8 a1 2e 00 00       	call   f0106fb9 <cpunum>
f0104118:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f010411f:	f0 67 00 
f0104122:	6b ff 74             	imul   $0x74,%edi,%edi
f0104125:	81 c7 2c 10 24 f0    	add    $0xf024102c,%edi
f010412b:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f0104132:	f0 
f0104133:	6b d6 74             	imul   $0x74,%esi,%edx
f0104136:	81 c2 2c 10 24 f0    	add    $0xf024102c,%edx
f010413c:	c1 ea 10             	shr    $0x10,%edx
f010413f:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0104146:	c6 04 dd 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%ebx,8)
f010414d:	99 
f010414e:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0104155:	40 
f0104156:	6b c0 74             	imul   $0x74,%eax,%eax
f0104159:	05 2c 10 24 f0       	add    $0xf024102c,%eax
f010415e:	c1 e8 18             	shr    $0x18,%eax
f0104161:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(thiscpu->cpu_id)+(GD_TSS0 >> 3)].sd_s = 0;
f0104168:	e8 4c 2e 00 00       	call   f0106fb9 <cpunum>
f010416d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104170:	0f b6 80 20 10 24 f0 	movzbl -0xfdbefe0(%eax),%eax
f0104177:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f010417e:	ef 

	ltr(GD_TSS0 + ( thiscpu->cpu_id ) * 8 );
f010417f:	e8 35 2e 00 00       	call   f0106fb9 <cpunum>
f0104184:	6b c0 74             	imul   $0x74,%eax,%eax
f0104187:	0f b6 80 20 10 24 f0 	movzbl -0xfdbefe0(%eax),%eax
f010418e:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104195:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104198:	b8 aa 23 12 f0       	mov    $0xf01223aa,%eax
f010419d:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01041a0:	83 c4 0c             	add    $0xc,%esp
f01041a3:	5b                   	pop    %ebx
f01041a4:	5e                   	pop    %esi
f01041a5:	5f                   	pop    %edi
f01041a6:	5d                   	pop    %ebp
f01041a7:	c3                   	ret    

f01041a8 <trap_init>:
}


void
trap_init(void)
{
f01041a8:	55                   	push   %ebp
f01041a9:	89 e5                	mov    %esp,%ebp
f01041ab:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
		
	long* ptr ;
	for ( ptr = vec ; ptr < vec_end ; ptr+=2 ) {
f01041ae:	b8 b4 23 12 f0       	mov    $0xf01223b4,%eax
f01041b3:	eb 14                	jmp    f01041c9 <trap_init+0x21>
		if ( ptr[0] == -1 ) break ;
f01041b5:	8b 10                	mov    (%eax),%edx
f01041b7:	83 fa ff             	cmp    $0xffffffff,%edx
f01041ba:	74 14                	je     f01041d0 <trap_init+0x28>
		handler_entry[ ptr[1] ] = ptr[0] ;	
f01041bc:	8b 48 04             	mov    0x4(%eax),%ecx
f01041bf:	89 14 8d a0 fe 23 f0 	mov    %edx,-0xfdc0160(,%ecx,4)
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
		
	long* ptr ;
	for ( ptr = vec ; ptr < vec_end ; ptr+=2 ) {
f01041c6:	83 c0 08             	add    $0x8,%eax
f01041c9:	3d d4 24 12 f0       	cmp    $0xf01224d4,%eax
f01041ce:	72 e5                	jb     f01041b5 <trap_init+0xd>
		if ( ptr[0] == -1 ) break ;
		handler_entry[ ptr[1] ] = ptr[0] ;	
	}
	
	
	SETGATE( idt[0] , 0 , GD_KT , handler_entry[0] , 0 ) ;  
f01041d0:	a1 a0 fe 23 f0       	mov    0xf023fea0,%eax
f01041d5:	66 a3 60 f2 23 f0    	mov    %ax,0xf023f260
f01041db:	66 c7 05 62 f2 23 f0 	movw   $0x8,0xf023f262
f01041e2:	08 00 
f01041e4:	c6 05 64 f2 23 f0 00 	movb   $0x0,0xf023f264
f01041eb:	c6 05 65 f2 23 f0 8e 	movb   $0x8e,0xf023f265
f01041f2:	c1 e8 10             	shr    $0x10,%eax
f01041f5:	66 a3 66 f2 23 f0    	mov    %ax,0xf023f266
	SETGATE( idt[1] , 0 , GD_KT , handler_entry[1] , 0 ) ;  
f01041fb:	a1 a4 fe 23 f0       	mov    0xf023fea4,%eax
f0104200:	66 a3 68 f2 23 f0    	mov    %ax,0xf023f268
f0104206:	66 c7 05 6a f2 23 f0 	movw   $0x8,0xf023f26a
f010420d:	08 00 
f010420f:	c6 05 6c f2 23 f0 00 	movb   $0x0,0xf023f26c
f0104216:	c6 05 6d f2 23 f0 8e 	movb   $0x8e,0xf023f26d
f010421d:	c1 e8 10             	shr    $0x10,%eax
f0104220:	66 a3 6e f2 23 f0    	mov    %ax,0xf023f26e
	SETGATE( idt[2] , 0 , GD_KT , handler_entry[2] , 0 ) ;  
f0104226:	a1 a8 fe 23 f0       	mov    0xf023fea8,%eax
f010422b:	66 a3 70 f2 23 f0    	mov    %ax,0xf023f270
f0104231:	66 c7 05 72 f2 23 f0 	movw   $0x8,0xf023f272
f0104238:	08 00 
f010423a:	c6 05 74 f2 23 f0 00 	movb   $0x0,0xf023f274
f0104241:	c6 05 75 f2 23 f0 8e 	movb   $0x8e,0xf023f275
f0104248:	c1 e8 10             	shr    $0x10,%eax
f010424b:	66 a3 76 f2 23 f0    	mov    %ax,0xf023f276
	SETGATE( idt[3] , 1 , GD_KT , handler_entry[3] , 3 ) ;  
f0104251:	a1 ac fe 23 f0       	mov    0xf023feac,%eax
f0104256:	66 a3 78 f2 23 f0    	mov    %ax,0xf023f278
f010425c:	66 c7 05 7a f2 23 f0 	movw   $0x8,0xf023f27a
f0104263:	08 00 
f0104265:	c6 05 7c f2 23 f0 00 	movb   $0x0,0xf023f27c
f010426c:	c6 05 7d f2 23 f0 ef 	movb   $0xef,0xf023f27d
f0104273:	c1 e8 10             	shr    $0x10,%eax
f0104276:	66 a3 7e f2 23 f0    	mov    %ax,0xf023f27e
	SETGATE( idt[4] , 1 , GD_KT , handler_entry[4] , 0 ) ;  
f010427c:	a1 b0 fe 23 f0       	mov    0xf023feb0,%eax
f0104281:	66 a3 80 f2 23 f0    	mov    %ax,0xf023f280
f0104287:	66 c7 05 82 f2 23 f0 	movw   $0x8,0xf023f282
f010428e:	08 00 
f0104290:	c6 05 84 f2 23 f0 00 	movb   $0x0,0xf023f284
f0104297:	c6 05 85 f2 23 f0 8f 	movb   $0x8f,0xf023f285
f010429e:	c1 e8 10             	shr    $0x10,%eax
f01042a1:	66 a3 86 f2 23 f0    	mov    %ax,0xf023f286
	SETGATE( idt[5] , 0 , GD_KT , handler_entry[5] , 0 ) ;  
f01042a7:	a1 b4 fe 23 f0       	mov    0xf023feb4,%eax
f01042ac:	66 a3 88 f2 23 f0    	mov    %ax,0xf023f288
f01042b2:	66 c7 05 8a f2 23 f0 	movw   $0x8,0xf023f28a
f01042b9:	08 00 
f01042bb:	c6 05 8c f2 23 f0 00 	movb   $0x0,0xf023f28c
f01042c2:	c6 05 8d f2 23 f0 8e 	movb   $0x8e,0xf023f28d
f01042c9:	c1 e8 10             	shr    $0x10,%eax
f01042cc:	66 a3 8e f2 23 f0    	mov    %ax,0xf023f28e
	SETGATE( idt[6] , 0 , GD_KT , handler_entry[6] , 0 ) ;  
f01042d2:	a1 b8 fe 23 f0       	mov    0xf023feb8,%eax
f01042d7:	66 a3 90 f2 23 f0    	mov    %ax,0xf023f290
f01042dd:	66 c7 05 92 f2 23 f0 	movw   $0x8,0xf023f292
f01042e4:	08 00 
f01042e6:	c6 05 94 f2 23 f0 00 	movb   $0x0,0xf023f294
f01042ed:	c6 05 95 f2 23 f0 8e 	movb   $0x8e,0xf023f295
f01042f4:	c1 e8 10             	shr    $0x10,%eax
f01042f7:	66 a3 96 f2 23 f0    	mov    %ax,0xf023f296
	SETGATE( idt[7] , 0 , GD_KT , handler_entry[7] , 0 ) ;  
f01042fd:	a1 bc fe 23 f0       	mov    0xf023febc,%eax
f0104302:	66 a3 98 f2 23 f0    	mov    %ax,0xf023f298
f0104308:	66 c7 05 9a f2 23 f0 	movw   $0x8,0xf023f29a
f010430f:	08 00 
f0104311:	c6 05 9c f2 23 f0 00 	movb   $0x0,0xf023f29c
f0104318:	c6 05 9d f2 23 f0 8e 	movb   $0x8e,0xf023f29d
f010431f:	c1 e8 10             	shr    $0x10,%eax
f0104322:	66 a3 9e f2 23 f0    	mov    %ax,0xf023f29e
	SETGATE( idt[8] , 0 , GD_KT , handler_entry[8] , 0 ) ;  
f0104328:	a1 c0 fe 23 f0       	mov    0xf023fec0,%eax
f010432d:	66 a3 a0 f2 23 f0    	mov    %ax,0xf023f2a0
f0104333:	66 c7 05 a2 f2 23 f0 	movw   $0x8,0xf023f2a2
f010433a:	08 00 
f010433c:	c6 05 a4 f2 23 f0 00 	movb   $0x0,0xf023f2a4
f0104343:	c6 05 a5 f2 23 f0 8e 	movb   $0x8e,0xf023f2a5
f010434a:	c1 e8 10             	shr    $0x10,%eax
f010434d:	66 a3 a6 f2 23 f0    	mov    %ax,0xf023f2a6
	SETGATE( idt[10] , 0 , GD_KT , handler_entry[10] , 0 ) ;  
f0104353:	a1 c8 fe 23 f0       	mov    0xf023fec8,%eax
f0104358:	66 a3 b0 f2 23 f0    	mov    %ax,0xf023f2b0
f010435e:	66 c7 05 b2 f2 23 f0 	movw   $0x8,0xf023f2b2
f0104365:	08 00 
f0104367:	c6 05 b4 f2 23 f0 00 	movb   $0x0,0xf023f2b4
f010436e:	c6 05 b5 f2 23 f0 8e 	movb   $0x8e,0xf023f2b5
f0104375:	c1 e8 10             	shr    $0x10,%eax
f0104378:	66 a3 b6 f2 23 f0    	mov    %ax,0xf023f2b6
	SETGATE( idt[11] , 0 , GD_KT , handler_entry[11] , 0 ) ;  
f010437e:	a1 cc fe 23 f0       	mov    0xf023fecc,%eax
f0104383:	66 a3 b8 f2 23 f0    	mov    %ax,0xf023f2b8
f0104389:	66 c7 05 ba f2 23 f0 	movw   $0x8,0xf023f2ba
f0104390:	08 00 
f0104392:	c6 05 bc f2 23 f0 00 	movb   $0x0,0xf023f2bc
f0104399:	c6 05 bd f2 23 f0 8e 	movb   $0x8e,0xf023f2bd
f01043a0:	c1 e8 10             	shr    $0x10,%eax
f01043a3:	66 a3 be f2 23 f0    	mov    %ax,0xf023f2be
	SETGATE( idt[12] , 0 , GD_KT , handler_entry[12] , 0 ) ;  
f01043a9:	a1 d0 fe 23 f0       	mov    0xf023fed0,%eax
f01043ae:	66 a3 c0 f2 23 f0    	mov    %ax,0xf023f2c0
f01043b4:	66 c7 05 c2 f2 23 f0 	movw   $0x8,0xf023f2c2
f01043bb:	08 00 
f01043bd:	c6 05 c4 f2 23 f0 00 	movb   $0x0,0xf023f2c4
f01043c4:	c6 05 c5 f2 23 f0 8e 	movb   $0x8e,0xf023f2c5
f01043cb:	c1 e8 10             	shr    $0x10,%eax
f01043ce:	66 a3 c6 f2 23 f0    	mov    %ax,0xf023f2c6
	SETGATE( idt[13] , 0 , GD_KT , handler_entry[13] , 0 ) ;  
f01043d4:	a1 d4 fe 23 f0       	mov    0xf023fed4,%eax
f01043d9:	66 a3 c8 f2 23 f0    	mov    %ax,0xf023f2c8
f01043df:	66 c7 05 ca f2 23 f0 	movw   $0x8,0xf023f2ca
f01043e6:	08 00 
f01043e8:	c6 05 cc f2 23 f0 00 	movb   $0x0,0xf023f2cc
f01043ef:	c6 05 cd f2 23 f0 8e 	movb   $0x8e,0xf023f2cd
f01043f6:	c1 e8 10             	shr    $0x10,%eax
f01043f9:	66 a3 ce f2 23 f0    	mov    %ax,0xf023f2ce
	SETGATE( idt[14] , 0 , GD_KT , handler_entry[14] , 0 ) ;  
f01043ff:	a1 d8 fe 23 f0       	mov    0xf023fed8,%eax
f0104404:	66 a3 d0 f2 23 f0    	mov    %ax,0xf023f2d0
f010440a:	66 c7 05 d2 f2 23 f0 	movw   $0x8,0xf023f2d2
f0104411:	08 00 
f0104413:	c6 05 d4 f2 23 f0 00 	movb   $0x0,0xf023f2d4
f010441a:	c6 05 d5 f2 23 f0 8e 	movb   $0x8e,0xf023f2d5
f0104421:	c1 e8 10             	shr    $0x10,%eax
f0104424:	66 a3 d6 f2 23 f0    	mov    %ax,0xf023f2d6
	SETGATE( idt[16] , 0 , GD_KT , handler_entry[16] , 0 ) ;  
f010442a:	a1 e0 fe 23 f0       	mov    0xf023fee0,%eax
f010442f:	66 a3 e0 f2 23 f0    	mov    %ax,0xf023f2e0
f0104435:	66 c7 05 e2 f2 23 f0 	movw   $0x8,0xf023f2e2
f010443c:	08 00 
f010443e:	c6 05 e4 f2 23 f0 00 	movb   $0x0,0xf023f2e4
f0104445:	c6 05 e5 f2 23 f0 8e 	movb   $0x8e,0xf023f2e5
f010444c:	c1 e8 10             	shr    $0x10,%eax
f010444f:	66 a3 e6 f2 23 f0    	mov    %ax,0xf023f2e6
	SETGATE( idt[17] , 0 , GD_KT , handler_entry[17] , 0 ) ;  
f0104455:	a1 e4 fe 23 f0       	mov    0xf023fee4,%eax
f010445a:	66 a3 e8 f2 23 f0    	mov    %ax,0xf023f2e8
f0104460:	66 c7 05 ea f2 23 f0 	movw   $0x8,0xf023f2ea
f0104467:	08 00 
f0104469:	c6 05 ec f2 23 f0 00 	movb   $0x0,0xf023f2ec
f0104470:	c6 05 ed f2 23 f0 8e 	movb   $0x8e,0xf023f2ed
f0104477:	c1 e8 10             	shr    $0x10,%eax
f010447a:	66 a3 ee f2 23 f0    	mov    %ax,0xf023f2ee
	SETGATE( idt[18] , 0 , GD_KT , handler_entry[18] , 0 ) ;  
f0104480:	a1 e8 fe 23 f0       	mov    0xf023fee8,%eax
f0104485:	66 a3 f0 f2 23 f0    	mov    %ax,0xf023f2f0
f010448b:	66 c7 05 f2 f2 23 f0 	movw   $0x8,0xf023f2f2
f0104492:	08 00 
f0104494:	c6 05 f4 f2 23 f0 00 	movb   $0x0,0xf023f2f4
f010449b:	c6 05 f5 f2 23 f0 8e 	movb   $0x8e,0xf023f2f5
f01044a2:	c1 e8 10             	shr    $0x10,%eax
f01044a5:	66 a3 f6 f2 23 f0    	mov    %ax,0xf023f2f6
	SETGATE( idt[19] , 0 , GD_KT , handler_entry[19] , 0 ) ;  
f01044ab:	a1 ec fe 23 f0       	mov    0xf023feec,%eax
f01044b0:	66 a3 f8 f2 23 f0    	mov    %ax,0xf023f2f8
f01044b6:	66 c7 05 fa f2 23 f0 	movw   $0x8,0xf023f2fa
f01044bd:	08 00 
f01044bf:	c6 05 fc f2 23 f0 00 	movb   $0x0,0xf023f2fc
f01044c6:	c6 05 fd f2 23 f0 8e 	movb   $0x8e,0xf023f2fd
f01044cd:	c1 e8 10             	shr    $0x10,%eax
f01044d0:	66 a3 fe f2 23 f0    	mov    %ax,0xf023f2fe
	SETGATE( idt[48] , 0 , GD_KT , handler_entry[48] , 3 ) ;
f01044d6:	a1 60 ff 23 f0       	mov    0xf023ff60,%eax
f01044db:	66 a3 e0 f3 23 f0    	mov    %ax,0xf023f3e0
f01044e1:	66 c7 05 e2 f3 23 f0 	movw   $0x8,0xf023f3e2
f01044e8:	08 00 
f01044ea:	c6 05 e4 f3 23 f0 00 	movb   $0x0,0xf023f3e4
f01044f1:	c6 05 e5 f3 23 f0 ee 	movb   $0xee,0xf023f3e5
f01044f8:	c1 e8 10             	shr    $0x10,%eax
f01044fb:	66 a3 e6 f3 23 f0    	mov    %ax,0xf023f3e6
	
	SETGATE( idt[32] , 0 , GD_KT , handler_entry[32] , 3 ) ;  
f0104501:	a1 20 ff 23 f0       	mov    0xf023ff20,%eax
f0104506:	66 a3 60 f3 23 f0    	mov    %ax,0xf023f360
f010450c:	66 c7 05 62 f3 23 f0 	movw   $0x8,0xf023f362
f0104513:	08 00 
f0104515:	c6 05 64 f3 23 f0 00 	movb   $0x0,0xf023f364
f010451c:	c6 05 65 f3 23 f0 ee 	movb   $0xee,0xf023f365
f0104523:	c1 e8 10             	shr    $0x10,%eax
f0104526:	66 a3 66 f3 23 f0    	mov    %ax,0xf023f366
	SETGATE( idt[33] , 0 , GD_KT , handler_entry[33] , 3 ) ;  
f010452c:	a1 24 ff 23 f0       	mov    0xf023ff24,%eax
f0104531:	66 a3 68 f3 23 f0    	mov    %ax,0xf023f368
f0104537:	66 c7 05 6a f3 23 f0 	movw   $0x8,0xf023f36a
f010453e:	08 00 
f0104540:	c6 05 6c f3 23 f0 00 	movb   $0x0,0xf023f36c
f0104547:	c6 05 6d f3 23 f0 ee 	movb   $0xee,0xf023f36d
f010454e:	c1 e8 10             	shr    $0x10,%eax
f0104551:	66 a3 6e f3 23 f0    	mov    %ax,0xf023f36e
	SETGATE( idt[34] , 0 , GD_KT , handler_entry[34] , 3 ) ;  
f0104557:	a1 28 ff 23 f0       	mov    0xf023ff28,%eax
f010455c:	66 a3 70 f3 23 f0    	mov    %ax,0xf023f370
f0104562:	66 c7 05 72 f3 23 f0 	movw   $0x8,0xf023f372
f0104569:	08 00 
f010456b:	c6 05 74 f3 23 f0 00 	movb   $0x0,0xf023f374
f0104572:	c6 05 75 f3 23 f0 ee 	movb   $0xee,0xf023f375
f0104579:	c1 e8 10             	shr    $0x10,%eax
f010457c:	66 a3 76 f3 23 f0    	mov    %ax,0xf023f376
	SETGATE( idt[35] , 0 , GD_KT , handler_entry[35] , 3 ) ;  
f0104582:	a1 2c ff 23 f0       	mov    0xf023ff2c,%eax
f0104587:	66 a3 78 f3 23 f0    	mov    %ax,0xf023f378
f010458d:	66 c7 05 7a f3 23 f0 	movw   $0x8,0xf023f37a
f0104594:	08 00 
f0104596:	c6 05 7c f3 23 f0 00 	movb   $0x0,0xf023f37c
f010459d:	c6 05 7d f3 23 f0 ee 	movb   $0xee,0xf023f37d
f01045a4:	c1 e8 10             	shr    $0x10,%eax
f01045a7:	66 a3 7e f3 23 f0    	mov    %ax,0xf023f37e
	SETGATE( idt[36] , 0 , GD_KT , handler_entry[36] , 3 ) ;  
f01045ad:	a1 30 ff 23 f0       	mov    0xf023ff30,%eax
f01045b2:	66 a3 80 f3 23 f0    	mov    %ax,0xf023f380
f01045b8:	66 c7 05 82 f3 23 f0 	movw   $0x8,0xf023f382
f01045bf:	08 00 
f01045c1:	c6 05 84 f3 23 f0 00 	movb   $0x0,0xf023f384
f01045c8:	c6 05 85 f3 23 f0 ee 	movb   $0xee,0xf023f385
f01045cf:	c1 e8 10             	shr    $0x10,%eax
f01045d2:	66 a3 86 f3 23 f0    	mov    %ax,0xf023f386
	SETGATE( idt[37] , 0 , GD_KT , handler_entry[37] , 3 ) ;  
f01045d8:	a1 34 ff 23 f0       	mov    0xf023ff34,%eax
f01045dd:	66 a3 88 f3 23 f0    	mov    %ax,0xf023f388
f01045e3:	66 c7 05 8a f3 23 f0 	movw   $0x8,0xf023f38a
f01045ea:	08 00 
f01045ec:	c6 05 8c f3 23 f0 00 	movb   $0x0,0xf023f38c
f01045f3:	c6 05 8d f3 23 f0 ee 	movb   $0xee,0xf023f38d
f01045fa:	c1 e8 10             	shr    $0x10,%eax
f01045fd:	66 a3 8e f3 23 f0    	mov    %ax,0xf023f38e
	SETGATE( idt[38] , 0 , GD_KT , handler_entry[38] , 3 ) ;  
f0104603:	a1 38 ff 23 f0       	mov    0xf023ff38,%eax
f0104608:	66 a3 90 f3 23 f0    	mov    %ax,0xf023f390
f010460e:	66 c7 05 92 f3 23 f0 	movw   $0x8,0xf023f392
f0104615:	08 00 
f0104617:	c6 05 94 f3 23 f0 00 	movb   $0x0,0xf023f394
f010461e:	c6 05 95 f3 23 f0 ee 	movb   $0xee,0xf023f395
f0104625:	c1 e8 10             	shr    $0x10,%eax
f0104628:	66 a3 96 f3 23 f0    	mov    %ax,0xf023f396
	SETGATE( idt[39] , 0 , GD_KT , handler_entry[39] , 3 ) ;  
f010462e:	a1 3c ff 23 f0       	mov    0xf023ff3c,%eax
f0104633:	66 a3 98 f3 23 f0    	mov    %ax,0xf023f398
f0104639:	66 c7 05 9a f3 23 f0 	movw   $0x8,0xf023f39a
f0104640:	08 00 
f0104642:	c6 05 9c f3 23 f0 00 	movb   $0x0,0xf023f39c
f0104649:	c6 05 9d f3 23 f0 ee 	movb   $0xee,0xf023f39d
f0104650:	c1 e8 10             	shr    $0x10,%eax
f0104653:	66 a3 9e f3 23 f0    	mov    %ax,0xf023f39e
	SETGATE( idt[40] , 0 , GD_KT , handler_entry[40] , 3 ) ;  
f0104659:	a1 40 ff 23 f0       	mov    0xf023ff40,%eax
f010465e:	66 a3 a0 f3 23 f0    	mov    %ax,0xf023f3a0
f0104664:	66 c7 05 a2 f3 23 f0 	movw   $0x8,0xf023f3a2
f010466b:	08 00 
f010466d:	c6 05 a4 f3 23 f0 00 	movb   $0x0,0xf023f3a4
f0104674:	c6 05 a5 f3 23 f0 ee 	movb   $0xee,0xf023f3a5
f010467b:	c1 e8 10             	shr    $0x10,%eax
f010467e:	66 a3 a6 f3 23 f0    	mov    %ax,0xf023f3a6
	SETGATE( idt[41] , 0 , GD_KT , handler_entry[41] , 3 ) ;  
f0104684:	a1 44 ff 23 f0       	mov    0xf023ff44,%eax
f0104689:	66 a3 a8 f3 23 f0    	mov    %ax,0xf023f3a8
f010468f:	66 c7 05 aa f3 23 f0 	movw   $0x8,0xf023f3aa
f0104696:	08 00 
f0104698:	c6 05 ac f3 23 f0 00 	movb   $0x0,0xf023f3ac
f010469f:	c6 05 ad f3 23 f0 ee 	movb   $0xee,0xf023f3ad
f01046a6:	c1 e8 10             	shr    $0x10,%eax
f01046a9:	66 a3 ae f3 23 f0    	mov    %ax,0xf023f3ae
	SETGATE( idt[42] , 0 , GD_KT , handler_entry[42] , 3 ) ;  
f01046af:	a1 48 ff 23 f0       	mov    0xf023ff48,%eax
f01046b4:	66 a3 b0 f3 23 f0    	mov    %ax,0xf023f3b0
f01046ba:	66 c7 05 b2 f3 23 f0 	movw   $0x8,0xf023f3b2
f01046c1:	08 00 
f01046c3:	c6 05 b4 f3 23 f0 00 	movb   $0x0,0xf023f3b4
f01046ca:	c6 05 b5 f3 23 f0 ee 	movb   $0xee,0xf023f3b5
f01046d1:	c1 e8 10             	shr    $0x10,%eax
f01046d4:	66 a3 b6 f3 23 f0    	mov    %ax,0xf023f3b6
	SETGATE( idt[43] , 0 , GD_KT , handler_entry[43] , 3 ) ;  
f01046da:	a1 4c ff 23 f0       	mov    0xf023ff4c,%eax
f01046df:	66 a3 b8 f3 23 f0    	mov    %ax,0xf023f3b8
f01046e5:	66 c7 05 ba f3 23 f0 	movw   $0x8,0xf023f3ba
f01046ec:	08 00 
f01046ee:	c6 05 bc f3 23 f0 00 	movb   $0x0,0xf023f3bc
f01046f5:	c6 05 bd f3 23 f0 ee 	movb   $0xee,0xf023f3bd
f01046fc:	c1 e8 10             	shr    $0x10,%eax
f01046ff:	66 a3 be f3 23 f0    	mov    %ax,0xf023f3be
	SETGATE( idt[44] , 0 , GD_KT , handler_entry[44] , 3 ) ;  
f0104705:	a1 50 ff 23 f0       	mov    0xf023ff50,%eax
f010470a:	66 a3 c0 f3 23 f0    	mov    %ax,0xf023f3c0
f0104710:	66 c7 05 c2 f3 23 f0 	movw   $0x8,0xf023f3c2
f0104717:	08 00 
f0104719:	c6 05 c4 f3 23 f0 00 	movb   $0x0,0xf023f3c4
f0104720:	c6 05 c5 f3 23 f0 ee 	movb   $0xee,0xf023f3c5
f0104727:	c1 e8 10             	shr    $0x10,%eax
f010472a:	66 a3 c6 f3 23 f0    	mov    %ax,0xf023f3c6
	SETGATE( idt[45] , 0 , GD_KT , handler_entry[45] , 3 ) ;  
f0104730:	a1 54 ff 23 f0       	mov    0xf023ff54,%eax
f0104735:	66 a3 c8 f3 23 f0    	mov    %ax,0xf023f3c8
f010473b:	66 c7 05 ca f3 23 f0 	movw   $0x8,0xf023f3ca
f0104742:	08 00 
f0104744:	c6 05 cc f3 23 f0 00 	movb   $0x0,0xf023f3cc
f010474b:	c6 05 cd f3 23 f0 ee 	movb   $0xee,0xf023f3cd
f0104752:	c1 e8 10             	shr    $0x10,%eax
f0104755:	66 a3 ce f3 23 f0    	mov    %ax,0xf023f3ce
	SETGATE( idt[46] , 0 , GD_KT , handler_entry[46] , 3 ) ;  
f010475b:	a1 58 ff 23 f0       	mov    0xf023ff58,%eax
f0104760:	66 a3 d0 f3 23 f0    	mov    %ax,0xf023f3d0
f0104766:	66 c7 05 d2 f3 23 f0 	movw   $0x8,0xf023f3d2
f010476d:	08 00 
f010476f:	c6 05 d4 f3 23 f0 00 	movb   $0x0,0xf023f3d4
f0104776:	c6 05 d5 f3 23 f0 ee 	movb   $0xee,0xf023f3d5
f010477d:	c1 e8 10             	shr    $0x10,%eax
f0104780:	66 a3 d6 f3 23 f0    	mov    %ax,0xf023f3d6
	SETGATE( idt[47] , 0 , GD_KT , handler_entry[47] , 3 ) ;  
f0104786:	a1 5c ff 23 f0       	mov    0xf023ff5c,%eax
f010478b:	66 a3 d8 f3 23 f0    	mov    %ax,0xf023f3d8
f0104791:	66 c7 05 da f3 23 f0 	movw   $0x8,0xf023f3da
f0104798:	08 00 
f010479a:	c6 05 dc f3 23 f0 00 	movb   $0x0,0xf023f3dc
f01047a1:	c6 05 dd f3 23 f0 ee 	movb   $0xee,0xf023f3dd
f01047a8:	c1 e8 10             	shr    $0x10,%eax
f01047ab:	66 a3 de f3 23 f0    	mov    %ax,0xf023f3de
        SETGATE( idt[18] , 0 , GD_KT , IMCHK , 0 ) ;
        SETGATE( idt[19] , 0 , GD_KT , ISIMDERR , 0 ) ;
        SETGATE( idt[48] , 1 , GD_KT , ISYSCALL , 3 ) ;
	*/
        // Per-CPU setup 
	trap_init_percpu();
f01047b1:	e8 fa f8 ff ff       	call   f01040b0 <trap_init_percpu>
}
f01047b6:	c9                   	leave  
f01047b7:	c3                   	ret    

f01047b8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01047b8:	55                   	push   %ebp
f01047b9:	89 e5                	mov    %esp,%ebp
f01047bb:	53                   	push   %ebx
f01047bc:	83 ec 14             	sub    $0x14,%esp
f01047bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01047c2:	8b 03                	mov    (%ebx),%eax
f01047c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047c8:	c7 04 24 94 89 10 f0 	movl   $0xf0108994,(%esp)
f01047cf:	e8 a8 f8 ff ff       	call   f010407c <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01047d4:	8b 43 04             	mov    0x4(%ebx),%eax
f01047d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047db:	c7 04 24 a3 89 10 f0 	movl   $0xf01089a3,(%esp)
f01047e2:	e8 95 f8 ff ff       	call   f010407c <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01047e7:	8b 43 08             	mov    0x8(%ebx),%eax
f01047ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047ee:	c7 04 24 b2 89 10 f0 	movl   $0xf01089b2,(%esp)
f01047f5:	e8 82 f8 ff ff       	call   f010407c <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01047fa:	8b 43 0c             	mov    0xc(%ebx),%eax
f01047fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104801:	c7 04 24 c1 89 10 f0 	movl   $0xf01089c1,(%esp)
f0104808:	e8 6f f8 ff ff       	call   f010407c <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010480d:	8b 43 10             	mov    0x10(%ebx),%eax
f0104810:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104814:	c7 04 24 d0 89 10 f0 	movl   $0xf01089d0,(%esp)
f010481b:	e8 5c f8 ff ff       	call   f010407c <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104820:	8b 43 14             	mov    0x14(%ebx),%eax
f0104823:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104827:	c7 04 24 df 89 10 f0 	movl   $0xf01089df,(%esp)
f010482e:	e8 49 f8 ff ff       	call   f010407c <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104833:	8b 43 18             	mov    0x18(%ebx),%eax
f0104836:	89 44 24 04          	mov    %eax,0x4(%esp)
f010483a:	c7 04 24 ee 89 10 f0 	movl   $0xf01089ee,(%esp)
f0104841:	e8 36 f8 ff ff       	call   f010407c <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104846:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104849:	89 44 24 04          	mov    %eax,0x4(%esp)
f010484d:	c7 04 24 fd 89 10 f0 	movl   $0xf01089fd,(%esp)
f0104854:	e8 23 f8 ff ff       	call   f010407c <cprintf>
}
f0104859:	83 c4 14             	add    $0x14,%esp
f010485c:	5b                   	pop    %ebx
f010485d:	5d                   	pop    %ebp
f010485e:	c3                   	ret    

f010485f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010485f:	55                   	push   %ebp
f0104860:	89 e5                	mov    %esp,%ebp
f0104862:	56                   	push   %esi
f0104863:	53                   	push   %ebx
f0104864:	83 ec 10             	sub    $0x10,%esp
f0104867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010486a:	e8 4a 27 00 00       	call   f0106fb9 <cpunum>
f010486f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104873:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104877:	c7 04 24 61 8a 10 f0 	movl   $0xf0108a61,(%esp)
f010487e:	e8 f9 f7 ff ff       	call   f010407c <cprintf>
	print_regs(&tf->tf_regs);
f0104883:	89 1c 24             	mov    %ebx,(%esp)
f0104886:	e8 2d ff ff ff       	call   f01047b8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010488b:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010488f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104893:	c7 04 24 7f 8a 10 f0 	movl   $0xf0108a7f,(%esp)
f010489a:	e8 dd f7 ff ff       	call   f010407c <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010489f:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01048a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a7:	c7 04 24 92 8a 10 f0 	movl   $0xf0108a92,(%esp)
f01048ae:	e8 c9 f7 ff ff       	call   f010407c <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048b3:	8b 43 28             	mov    0x28(%ebx),%eax
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};
	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01048b6:	83 f8 13             	cmp    $0x13,%eax
f01048b9:	77 09                	ja     f01048c4 <print_trapframe+0x65>
		return excnames[trapno];
f01048bb:	8b 14 85 60 8d 10 f0 	mov    -0xfef72a0(,%eax,4),%edx
f01048c2:	eb 1f                	jmp    f01048e3 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01048c4:	83 f8 30             	cmp    $0x30,%eax
f01048c7:	74 15                	je     f01048de <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01048c9:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01048cc:	83 fa 0f             	cmp    $0xf,%edx
f01048cf:	ba 18 8a 10 f0       	mov    $0xf0108a18,%edx
f01048d4:	b9 2b 8a 10 f0       	mov    $0xf0108a2b,%ecx
f01048d9:	0f 47 d1             	cmova  %ecx,%edx
f01048dc:	eb 05                	jmp    f01048e3 <print_trapframe+0x84>
		"SIMD Floating-Point Exception"
	};
	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01048de:	ba 0c 8a 10 f0       	mov    $0xf0108a0c,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048e3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048eb:	c7 04 24 a5 8a 10 f0 	movl   $0xf0108aa5,(%esp)
f01048f2:	e8 85 f7 ff ff       	call   f010407c <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01048f7:	3b 1d 60 fa 23 f0    	cmp    0xf023fa60,%ebx
f01048fd:	75 19                	jne    f0104918 <print_trapframe+0xb9>
f01048ff:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104903:	75 13                	jne    f0104918 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104905:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104908:	89 44 24 04          	mov    %eax,0x4(%esp)
f010490c:	c7 04 24 b7 8a 10 f0 	movl   $0xf0108ab7,(%esp)
f0104913:	e8 64 f7 ff ff       	call   f010407c <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104918:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010491b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010491f:	c7 04 24 c6 8a 10 f0 	movl   $0xf0108ac6,(%esp)
f0104926:	e8 51 f7 ff ff       	call   f010407c <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010492b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010492f:	75 51                	jne    f0104982 <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104931:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104934:	89 c2                	mov    %eax,%edx
f0104936:	83 e2 01             	and    $0x1,%edx
f0104939:	ba 3a 8a 10 f0       	mov    $0xf0108a3a,%edx
f010493e:	b9 45 8a 10 f0       	mov    $0xf0108a45,%ecx
f0104943:	0f 45 ca             	cmovne %edx,%ecx
f0104946:	89 c2                	mov    %eax,%edx
f0104948:	83 e2 02             	and    $0x2,%edx
f010494b:	ba 51 8a 10 f0       	mov    $0xf0108a51,%edx
f0104950:	be 57 8a 10 f0       	mov    $0xf0108a57,%esi
f0104955:	0f 44 d6             	cmove  %esi,%edx
f0104958:	83 e0 04             	and    $0x4,%eax
f010495b:	b8 5c 8a 10 f0       	mov    $0xf0108a5c,%eax
f0104960:	be af 8b 10 f0       	mov    $0xf0108baf,%esi
f0104965:	0f 44 c6             	cmove  %esi,%eax
f0104968:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010496c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104970:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104974:	c7 04 24 d4 8a 10 f0 	movl   $0xf0108ad4,(%esp)
f010497b:	e8 fc f6 ff ff       	call   f010407c <cprintf>
f0104980:	eb 0c                	jmp    f010498e <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104982:	c7 04 24 e9 88 10 f0 	movl   $0xf01088e9,(%esp)
f0104989:	e8 ee f6 ff ff       	call   f010407c <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010498e:	8b 43 30             	mov    0x30(%ebx),%eax
f0104991:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104995:	c7 04 24 e3 8a 10 f0 	movl   $0xf0108ae3,(%esp)
f010499c:	e8 db f6 ff ff       	call   f010407c <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01049a1:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01049a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049a9:	c7 04 24 f2 8a 10 f0 	movl   $0xf0108af2,(%esp)
f01049b0:	e8 c7 f6 ff ff       	call   f010407c <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01049b5:	8b 43 38             	mov    0x38(%ebx),%eax
f01049b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049bc:	c7 04 24 05 8b 10 f0 	movl   $0xf0108b05,(%esp)
f01049c3:	e8 b4 f6 ff ff       	call   f010407c <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01049c8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01049cc:	74 27                	je     f01049f5 <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01049ce:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01049d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049d5:	c7 04 24 14 8b 10 f0 	movl   $0xf0108b14,(%esp)
f01049dc:	e8 9b f6 ff ff       	call   f010407c <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01049e1:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01049e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049e9:	c7 04 24 23 8b 10 f0 	movl   $0xf0108b23,(%esp)
f01049f0:	e8 87 f6 ff ff       	call   f010407c <cprintf>
	}
}
f01049f5:	83 c4 10             	add    $0x10,%esp
f01049f8:	5b                   	pop    %ebx
f01049f9:	5e                   	pop    %esi
f01049fa:	5d                   	pop    %ebp
f01049fb:	c3                   	ret    

f01049fc <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01049fc:	55                   	push   %ebp
f01049fd:	89 e5                	mov    %esp,%ebp
f01049ff:	57                   	push   %edi
f0104a00:	56                   	push   %esi
f0104a01:	53                   	push   %ebx
f0104a02:	83 ec 2c             	sub    $0x2c,%esp
f0104a05:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104a08:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ( ! ( tf->tf_err & 0x4 ) ) {
f0104a0b:	f6 43 2c 04          	testb  $0x4,0x2c(%ebx)
f0104a0f:	75 1c                	jne    f0104a2d <page_fault_handler+0x31>
		panic("Page fault caused by Kernel!\n");
f0104a11:	c7 44 24 08 36 8b 10 	movl   $0xf0108b36,0x8(%esp)
f0104a18:	f0 
f0104a19:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
f0104a20:	00 
f0104a21:	c7 04 24 54 8b 10 f0 	movl   $0xf0108b54,(%esp)
f0104a28:	e8 13 b6 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if ( curenv->env_pgfault_upcall != NULL ) {
f0104a2d:	e8 87 25 00 00       	call   f0106fb9 <cpunum>
f0104a32:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a35:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104a3b:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104a3f:	0f 84 b4 01 00 00    	je     f0104bf9 <page_fault_handler+0x1fd>
		//cprintf(" page_fault_handler : now esp point to %08x\n",tf->tf_esp); 
		//cprintf(" page_fault_handler : now eip point to %08x\n",tf->tf_eip); 
		char * stack_ptr ;
		cprintf("envid =[ %08x ] , cur_eip = %08x\n",
f0104a45:	8b 73 30             	mov    0x30(%ebx),%esi
			curenv->env_id , tf->tf_eip ) ; 	
f0104a48:	e8 6c 25 00 00       	call   f0106fb9 <cpunum>
	// LAB 4: Your code here.
	if ( curenv->env_pgfault_upcall != NULL ) {
		//cprintf(" page_fault_handler : now esp point to %08x\n",tf->tf_esp); 
		//cprintf(" page_fault_handler : now eip point to %08x\n",tf->tf_eip); 
		char * stack_ptr ;
		cprintf("envid =[ %08x ] , cur_eip = %08x\n",
f0104a4d:	89 74 24 08          	mov    %esi,0x8(%esp)
			curenv->env_id , tf->tf_eip ) ; 	
f0104a51:	6b c0 74             	imul   $0x74,%eax,%eax
	// LAB 4: Your code here.
	if ( curenv->env_pgfault_upcall != NULL ) {
		//cprintf(" page_fault_handler : now esp point to %08x\n",tf->tf_esp); 
		//cprintf(" page_fault_handler : now eip point to %08x\n",tf->tf_eip); 
		char * stack_ptr ;
		cprintf("envid =[ %08x ] , cur_eip = %08x\n",
f0104a54:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104a5a:	8b 40 48             	mov    0x48(%eax),%eax
f0104a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a61:	c7 04 24 fc 8c 10 f0 	movl   $0xf0108cfc,(%esp)
f0104a68:	e8 0f f6 ff ff       	call   f010407c <cprintf>
			curenv->env_id , tf->tf_eip ) ; 	
		if ( ! ( ( tf->tf_esp < UXSTACKTOP ) && ( tf->tf_esp >= UXSTACKTOP - PGSIZE ) ) ) {
f0104a6d:	8b 73 3c             	mov    0x3c(%ebx),%esi
f0104a70:	8d 86 00 10 40 11    	lea    0x11401000(%esi),%eax
f0104a76:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0104a7b:	0f 86 c4 00 00 00    	jbe    f0104b45 <page_fault_handler+0x149>
			stack_ptr = ( char * )  UXSTACKTOP ; 
			struct UTrapframe * utf_ptr = ( struct UTrapframe * ) ( stack_ptr - sizeof( struct UTrapframe ) ) ;  
			
			user_mem_assert( curenv , utf_ptr , sizeof( struct UTrapframe) , PTE_U | PTE_P | PTE_W ) ;		
f0104a81:	e8 33 25 00 00       	call   f0106fb9 <cpunum>
f0104a86:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104a8d:	00 
f0104a8e:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104a95:	00 
f0104a96:	c7 44 24 04 cc ff bf 	movl   $0xeebfffcc,0x4(%esp)
f0104a9d:	ee 
f0104a9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa1:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104aa7:	89 04 24             	mov    %eax,(%esp)
f0104aaa:	e8 59 eb ff ff       	call   f0103608 <user_mem_assert>
			utf_ptr->utf_fault_va = fault_va ; 
f0104aaf:	89 3d cc ff bf ee    	mov    %edi,0xeebfffcc
			utf_ptr->utf_err = tf->tf_err ;
f0104ab5:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104ab8:	a3 d0 ff bf ee       	mov    %eax,0xeebfffd0
			utf_ptr->utf_regs = tf->tf_regs ; 
f0104abd:	8b 03                	mov    (%ebx),%eax
f0104abf:	a3 d4 ff bf ee       	mov    %eax,0xeebfffd4
f0104ac4:	8b 43 04             	mov    0x4(%ebx),%eax
f0104ac7:	a3 d8 ff bf ee       	mov    %eax,0xeebfffd8
f0104acc:	8b 43 08             	mov    0x8(%ebx),%eax
f0104acf:	a3 dc ff bf ee       	mov    %eax,0xeebfffdc
f0104ad4:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104ad7:	a3 e0 ff bf ee       	mov    %eax,0xeebfffe0
f0104adc:	8b 43 10             	mov    0x10(%ebx),%eax
f0104adf:	a3 e4 ff bf ee       	mov    %eax,0xeebfffe4
f0104ae4:	8b 43 14             	mov    0x14(%ebx),%eax
f0104ae7:	a3 e8 ff bf ee       	mov    %eax,0xeebfffe8
f0104aec:	8b 43 18             	mov    0x18(%ebx),%eax
f0104aef:	a3 ec ff bf ee       	mov    %eax,0xeebfffec
f0104af4:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104af7:	a3 f0 ff bf ee       	mov    %eax,0xeebffff0
			utf_ptr->utf_eip = tf->tf_eip ; 
f0104afc:	8b 43 30             	mov    0x30(%ebx),%eax
f0104aff:	a3 f4 ff bf ee       	mov    %eax,0xeebffff4
			utf_ptr->utf_eflags = tf->tf_eflags ; 
f0104b04:	8b 43 38             	mov    0x38(%ebx),%eax
f0104b07:	a3 f8 ff bf ee       	mov    %eax,0xeebffff8
			utf_ptr->utf_esp = tf->tf_esp ; 
f0104b0c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104b0f:	a3 fc ff bf ee       	mov    %eax,0xeebffffc
			tf->tf_esp = (uint32_t) ( utf_ptr ) ; 
f0104b14:	c7 43 3c cc ff bf ee 	movl   $0xeebfffcc,0x3c(%ebx)
			tf->tf_eip = ( uint32_t ) ( curenv->env_pgfault_upcall ) ;
f0104b1b:	e8 99 24 00 00       	call   f0106fb9 <cpunum>
f0104b20:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b23:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104b29:	8b 40 64             	mov    0x64(%eax),%eax
f0104b2c:	89 43 30             	mov    %eax,0x30(%ebx)
			env_run(curenv);	 								
f0104b2f:	e8 85 24 00 00       	call   f0106fb9 <cpunum>
f0104b34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b37:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104b3d:	89 04 24             	mov    %eax,(%esp)
f0104b40:	e8 cd f2 ff ff       	call   f0103e12 <env_run>
		} else {
			stack_ptr = ( char * ) ( tf->tf_esp ) ;
			struct UTrapframe * utf_ptr = ( struct UTrapframe * ) ( stack_ptr - 4 - sizeof( struct UTrapframe ) ) ;  
f0104b45:	8d 46 c8             	lea    -0x38(%esi),%eax
f0104b48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			user_mem_assert( curenv , utf_ptr , 4 + sizeof( struct UTrapframe) , PTE_U | PTE_P | PTE_W ) ;		
f0104b4b:	e8 69 24 00 00       	call   f0106fb9 <cpunum>
f0104b50:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104b57:	00 
f0104b58:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
f0104b5f:	00 
f0104b60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b63:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b67:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6a:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104b70:	89 04 24             	mov    %eax,(%esp)
f0104b73:	e8 90 ea ff ff       	call   f0103608 <user_mem_assert>
			* ( ( int * ) ( stack_ptr - 4 ) ) = 0 ;  
f0104b78:	c7 46 fc 00 00 00 00 	movl   $0x0,-0x4(%esi)
			utf_ptr->utf_fault_va = fault_va ; 
f0104b7f:	89 7e c8             	mov    %edi,-0x38(%esi)
			utf_ptr->utf_err = tf->tf_err ;
f0104b82:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104b85:	89 46 cc             	mov    %eax,-0x34(%esi)
			utf_ptr->utf_regs = tf->tf_regs ; 
f0104b88:	8b 03                	mov    (%ebx),%eax
f0104b8a:	89 46 d0             	mov    %eax,-0x30(%esi)
f0104b8d:	8b 43 04             	mov    0x4(%ebx),%eax
f0104b90:	89 46 d4             	mov    %eax,-0x2c(%esi)
f0104b93:	8b 43 08             	mov    0x8(%ebx),%eax
f0104b96:	89 46 d8             	mov    %eax,-0x28(%esi)
f0104b99:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104b9c:	89 46 dc             	mov    %eax,-0x24(%esi)
f0104b9f:	8b 43 10             	mov    0x10(%ebx),%eax
f0104ba2:	89 46 e0             	mov    %eax,-0x20(%esi)
f0104ba5:	8b 43 14             	mov    0x14(%ebx),%eax
f0104ba8:	89 46 e4             	mov    %eax,-0x1c(%esi)
f0104bab:	8b 43 18             	mov    0x18(%ebx),%eax
f0104bae:	89 46 e8             	mov    %eax,-0x18(%esi)
f0104bb1:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104bb4:	89 46 ec             	mov    %eax,-0x14(%esi)
			utf_ptr->utf_eip = tf->tf_eip ; 
f0104bb7:	8b 43 30             	mov    0x30(%ebx),%eax
f0104bba:	89 46 f0             	mov    %eax,-0x10(%esi)
			utf_ptr->utf_eflags = tf->tf_eflags ; 
f0104bbd:	8b 43 38             	mov    0x38(%ebx),%eax
f0104bc0:	89 46 f4             	mov    %eax,-0xc(%esi)
			utf_ptr->utf_esp = tf->tf_esp ; 
f0104bc3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104bc6:	89 46 f8             	mov    %eax,-0x8(%esi)
			tf->tf_esp = (uint32_t) ( utf_ptr ) ; 
f0104bc9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104bcc:	89 53 3c             	mov    %edx,0x3c(%ebx)
			tf->tf_eip = ( uint32_t ) ( curenv->env_pgfault_upcall ) ;
f0104bcf:	e8 e5 23 00 00       	call   f0106fb9 <cpunum>
f0104bd4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd7:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104bdd:	8b 40 64             	mov    0x64(%eax),%eax
f0104be0:	89 43 30             	mov    %eax,0x30(%ebx)
			env_run(curenv);	 								
f0104be3:	e8 d1 23 00 00       	call   f0106fb9 <cpunum>
f0104be8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104beb:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104bf1:	89 04 24             	mov    %eax,(%esp)
f0104bf4:	e8 19 f2 ff ff       	call   f0103e12 <env_run>
		} 	
		
	}
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bf9:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104bfc:	e8 b8 23 00 00       	call   f0106fb9 <cpunum>
		} 	
		
	}
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104c01:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104c05:	89 7c 24 08          	mov    %edi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104c09:	6b c0 74             	imul   $0x74,%eax,%eax
		} 	
		
	}
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104c0c:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104c12:	8b 40 48             	mov    0x48(%eax),%eax
f0104c15:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c19:	c7 04 24 20 8d 10 f0 	movl   $0xf0108d20,(%esp)
f0104c20:	e8 57 f4 ff ff       	call   f010407c <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104c25:	89 1c 24             	mov    %ebx,(%esp)
f0104c28:	e8 32 fc ff ff       	call   f010485f <print_trapframe>
	env_destroy(curenv);
f0104c2d:	e8 87 23 00 00       	call   f0106fb9 <cpunum>
f0104c32:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c35:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104c3b:	89 04 24             	mov    %eax,(%esp)
f0104c3e:	e8 20 f1 ff ff       	call   f0103d63 <env_destroy>
}
f0104c43:	83 c4 2c             	add    $0x2c,%esp
f0104c46:	5b                   	pop    %ebx
f0104c47:	5e                   	pop    %esi
f0104c48:	5f                   	pop    %edi
f0104c49:	5d                   	pop    %ebp
f0104c4a:	c3                   	ret    

f0104c4b <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104c4b:	55                   	push   %ebp
f0104c4c:	89 e5                	mov    %esp,%ebp
f0104c4e:	57                   	push   %edi
f0104c4f:	56                   	push   %esi
f0104c50:	83 ec 20             	sub    $0x20,%esp
f0104c53:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104c56:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104c57:	83 3d 80 fe 23 f0 00 	cmpl   $0x0,0xf023fe80
f0104c5e:	74 01                	je     f0104c61 <trap+0x16>
		asm volatile("hlt");
f0104c60:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104c61:	e8 53 23 00 00       	call   f0106fb9 <cpunum>
f0104c66:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c69:	81 c2 20 10 24 f0    	add    $0xf0241020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104c6f:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c74:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104c78:	83 f8 02             	cmp    $0x2,%eax
f0104c7b:	75 0c                	jne    f0104c89 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104c7d:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0104c84:	e8 ae 25 00 00       	call   f0107237 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104c89:	9c                   	pushf  
f0104c8a:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104c8b:	f6 c4 02             	test   $0x2,%ah
f0104c8e:	74 24                	je     f0104cb4 <trap+0x69>
f0104c90:	c7 44 24 0c 60 8b 10 	movl   $0xf0108b60,0xc(%esp)
f0104c97:	f0 
f0104c98:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0104c9f:	f0 
f0104ca0:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
f0104ca7:	00 
f0104ca8:	c7 04 24 54 8b 10 f0 	movl   $0xf0108b54,(%esp)
f0104caf:	e8 8c b3 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104cb4:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104cb8:	83 e0 03             	and    $0x3,%eax
f0104cbb:	66 83 f8 03          	cmp    $0x3,%ax
f0104cbf:	0f 85 a7 00 00 00    	jne    f0104d6c <trap+0x121>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104cc5:	e8 ef 22 00 00       	call   f0106fb9 <cpunum>
f0104cca:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ccd:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0104cd4:	75 24                	jne    f0104cfa <trap+0xaf>
f0104cd6:	c7 44 24 0c 79 8b 10 	movl   $0xf0108b79,0xc(%esp)
f0104cdd:	f0 
f0104cde:	c7 44 24 08 2f 86 10 	movl   $0xf010862f,0x8(%esp)
f0104ce5:	f0 
f0104ce6:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0104ced:	00 
f0104cee:	c7 04 24 54 8b 10 f0 	movl   $0xf0108b54,(%esp)
f0104cf5:	e8 46 b3 ff ff       	call   f0100040 <_panic>
f0104cfa:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0104d01:	e8 31 25 00 00       	call   f0107237 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104d06:	e8 ae 22 00 00       	call   f0106fb9 <cpunum>
f0104d0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d0e:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104d14:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104d18:	75 2d                	jne    f0104d47 <trap+0xfc>
			env_free(curenv);
f0104d1a:	e8 9a 22 00 00       	call   f0106fb9 <cpunum>
f0104d1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d22:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104d28:	89 04 24             	mov    %eax,(%esp)
f0104d2b:	e8 2e ee ff ff       	call   f0103b5e <env_free>
			curenv = NULL;
f0104d30:	e8 84 22 00 00       	call   f0106fb9 <cpunum>
f0104d35:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d38:	c7 80 28 10 24 f0 00 	movl   $0x0,-0xfdbefd8(%eax)
f0104d3f:	00 00 00 
			sched_yield();
f0104d42:	e8 78 03 00 00       	call   f01050bf <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104d47:	e8 6d 22 00 00       	call   f0106fb9 <cpunum>
f0104d4c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d4f:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104d55:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104d5a:	89 c7                	mov    %eax,%edi
f0104d5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104d5e:	e8 56 22 00 00       	call   f0106fb9 <cpunum>
f0104d63:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d66:	8b b0 28 10 24 f0    	mov    -0xfdbefd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104d6c:	89 35 60 fa 23 f0    	mov    %esi,0xf023fa60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104d72:	8b 46 28             	mov    0x28(%esi),%eax
f0104d75:	83 f8 27             	cmp    $0x27,%eax
f0104d78:	75 19                	jne    f0104d93 <trap+0x148>
		cprintf("Spurious interrupt on irq 7\n");
f0104d7a:	c7 04 24 80 8b 10 f0 	movl   $0xf0108b80,(%esp)
f0104d81:	e8 f6 f2 ff ff       	call   f010407c <cprintf>
		print_trapframe(tf);
f0104d86:	89 34 24             	mov    %esi,(%esp)
f0104d89:	e8 d1 fa ff ff       	call   f010485f <print_trapframe>
f0104d8e:	e9 c7 00 00 00       	jmp    f0104e5a <trap+0x20f>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
        
	if ( ( tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER ) ) {
f0104d93:	83 f8 20             	cmp    $0x20,%eax
f0104d96:	75 12                	jne    f0104daa <trap+0x15f>
		lapic_eoi();
f0104d98:	90                   	nop
f0104d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104da0:	e8 61 23 00 00       	call   f0107106 <lapic_eoi>
		sched_yield();
f0104da5:	e8 15 03 00 00       	call   f01050bf <sched_yield>
		return ;
	}

	if (tf->tf_trapno == T_PGFLT ) {
f0104daa:	83 f8 0e             	cmp    $0xe,%eax
f0104dad:	75 0d                	jne    f0104dbc <trap+0x171>
		page_fault_handler( tf ) ;
f0104daf:	89 34 24             	mov    %esi,(%esp)
f0104db2:	e8 45 fc ff ff       	call   f01049fc <page_fault_handler>
f0104db7:	e9 9e 00 00 00       	jmp    f0104e5a <trap+0x20f>
		return ; 
	}	
	if (tf->tf_trapno == T_BRKPT ) {
f0104dbc:	83 f8 03             	cmp    $0x3,%eax
f0104dbf:	90                   	nop
f0104dc0:	75 20                	jne    f0104de2 <trap+0x197>
		monitor(tf);
f0104dc2:	89 34 24             	mov    %esi,(%esp)
f0104dc5:	e8 30 bc ff ff       	call   f01009fa <monitor>
		env_destroy(curenv);
f0104dca:	e8 ea 21 00 00       	call   f0106fb9 <cpunum>
f0104dcf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dd2:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104dd8:	89 04 24             	mov    %eax,(%esp)
f0104ddb:	e8 83 ef ff ff       	call   f0103d63 <env_destroy>
f0104de0:	eb 78                	jmp    f0104e5a <trap+0x20f>
		return ;
	}
	if (tf->tf_trapno == T_SYSCALL ) {	
f0104de2:	83 f8 30             	cmp    $0x30,%eax
f0104de5:	75 32                	jne    f0104e19 <trap+0x1ce>
		(tf->tf_regs).reg_eax = 
	        syscall( (tf->tf_regs).reg_eax , 
f0104de7:	8b 46 04             	mov    0x4(%esi),%eax
f0104dea:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104dee:	8b 06                	mov    (%esi),%eax
f0104df0:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104df4:	8b 46 10             	mov    0x10(%esi),%eax
f0104df7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104dfb:	8b 46 18             	mov    0x18(%esi),%eax
f0104dfe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e02:	8b 46 14             	mov    0x14(%esi),%eax
f0104e05:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e09:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104e0c:	89 04 24             	mov    %eax,(%esp)
f0104e0f:	e8 9c 03 00 00       	call   f01051b0 <syscall>
		monitor(tf);
		env_destroy(curenv);
		return ;
	}
	if (tf->tf_trapno == T_SYSCALL ) {	
		(tf->tf_regs).reg_eax = 
f0104e14:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104e17:	eb 41                	jmp    f0104e5a <trap+0x20f>
			 (tf->tf_regs).reg_edi , 
			 (tf->tf_regs).reg_esi ) ;
		return ; 
	}	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104e19:	89 34 24             	mov    %esi,(%esp)
f0104e1c:	e8 3e fa ff ff       	call   f010485f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104e21:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104e26:	75 1c                	jne    f0104e44 <trap+0x1f9>
		panic("unhandled trap in kernel");
f0104e28:	c7 44 24 08 9d 8b 10 	movl   $0xf0108b9d,0x8(%esp)
f0104e2f:	f0 
f0104e30:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0104e37:	00 
f0104e38:	c7 04 24 54 8b 10 f0 	movl   $0xf0108b54,(%esp)
f0104e3f:	e8 fc b1 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104e44:	e8 70 21 00 00       	call   f0106fb9 <cpunum>
f0104e49:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e4c:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104e52:	89 04 24             	mov    %eax,(%esp)
f0104e55:	e8 09 ef ff ff       	call   f0103d63 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104e5a:	e8 5a 21 00 00       	call   f0106fb9 <cpunum>
f0104e5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e62:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0104e69:	74 2a                	je     f0104e95 <trap+0x24a>
f0104e6b:	e8 49 21 00 00       	call   f0106fb9 <cpunum>
f0104e70:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e73:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104e79:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e7d:	75 16                	jne    f0104e95 <trap+0x24a>
		env_run(curenv);
f0104e7f:	e8 35 21 00 00       	call   f0106fb9 <cpunum>
f0104e84:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e87:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104e8d:	89 04 24             	mov    %eax,(%esp)
f0104e90:	e8 7d ef ff ff       	call   f0103e12 <env_run>
	else
		sched_yield();
f0104e95:	e8 25 02 00 00       	call   f01050bf <sched_yield>

f0104e9a <IDIVIDE>:
.data
.global vec;
.long vec;
vec:

TRAPHANDLER_NOEC(IDIVIDE    , 0)		// divide error
f0104e9a:	6a 00                	push   $0x0
f0104e9c:	6a 00                	push   $0x0
f0104e9e:	e9 31 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104ea3:	90                   	nop

f0104ea4 <IDEBUG>:
TRAPHANDLER_NOEC(IDEBUG     , 1)		// debug exception
f0104ea4:	6a 00                	push   $0x0
f0104ea6:	6a 01                	push   $0x1
f0104ea8:	e9 27 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104ead:	90                   	nop

f0104eae <INMI>:
TRAPHANDLER_NOEC(INMI       , 2)		// non-maskable interrupt
f0104eae:	6a 00                	push   $0x0
f0104eb0:	6a 02                	push   $0x2
f0104eb2:	e9 1d d6 01 00       	jmp    f01224d4 <_alltraps>
f0104eb7:	90                   	nop

f0104eb8 <IBRKPT>:
TRAPHANDLER_NOEC(IBRKPT     , 3)		// breakpoint
f0104eb8:	6a 00                	push   $0x0
f0104eba:	6a 03                	push   $0x3
f0104ebc:	e9 13 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104ec1:	90                   	nop

f0104ec2 <IOFLOW>:
TRAPHANDLER_NOEC(IOFLOW     , 4)		// overflow
f0104ec2:	6a 00                	push   $0x0
f0104ec4:	6a 04                	push   $0x4
f0104ec6:	e9 09 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104ecb:	90                   	nop

f0104ecc <IBOUND>:
TRAPHANDLER_NOEC(IBOUND     , 5)		// bounds check
f0104ecc:	6a 00                	push   $0x0
f0104ece:	6a 05                	push   $0x5
f0104ed0:	e9 ff d5 01 00       	jmp    f01224d4 <_alltraps>
f0104ed5:	90                   	nop

f0104ed6 <IILLOP>:
TRAPHANDLER_NOEC(IILLOP     , 6)		// illegal opcode
f0104ed6:	6a 00                	push   $0x0
f0104ed8:	6a 06                	push   $0x6
f0104eda:	e9 f5 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104edf:	90                   	nop

f0104ee0 <IDEVICE>:
TRAPHANDLER_NOEC(IDEVICE    , 7)		// device not available
f0104ee0:	6a 00                	push   $0x0
f0104ee2:	6a 07                	push   $0x7
f0104ee4:	e9 eb d5 01 00       	jmp    f01224d4 <_alltraps>
f0104ee9:	90                   	nop

f0104eea <IDBLFLT>:
TRAPHANDLER(IDBLFLT    , 8)		// double fault
f0104eea:	6a 08                	push   $0x8
f0104eec:	e9 e3 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104ef1:	90                   	nop

f0104ef2 <ITSS>:
TRAPHANDLER(ITSS       ,10)		// invalid task switch segment
f0104ef2:	6a 0a                	push   $0xa
f0104ef4:	e9 db d5 01 00       	jmp    f01224d4 <_alltraps>
f0104ef9:	90                   	nop

f0104efa <ISEGNP>:
TRAPHANDLER(ISEGNP     ,11)		// segment not present
f0104efa:	6a 0b                	push   $0xb
f0104efc:	e9 d3 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f01:	90                   	nop

f0104f02 <ISTACK>:
TRAPHANDLER(ISTACK     ,12)		// stack exception
f0104f02:	6a 0c                	push   $0xc
f0104f04:	e9 cb d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f09:	90                   	nop

f0104f0a <IGPFLT>:
TRAPHANDLER(IGPFLT     ,13)		// general protection fault
f0104f0a:	6a 0d                	push   $0xd
f0104f0c:	e9 c3 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f11:	90                   	nop

f0104f12 <IPGFLT>:
TRAPHANDLER(IPGFLT     ,14)		// page fault
f0104f12:	6a 0e                	push   $0xe
f0104f14:	e9 bb d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f19:	90                   	nop

f0104f1a <IFPERR>:
TRAPHANDLER_NOEC(IFPERR     ,16)		// floating point error
f0104f1a:	6a 00                	push   $0x0
f0104f1c:	6a 10                	push   $0x10
f0104f1e:	e9 b1 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f23:	90                   	nop

f0104f24 <IALIGN>:
TRAPHANDLER(IALIGN     ,17)		// aligment check
f0104f24:	6a 11                	push   $0x11
f0104f26:	e9 a9 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f2b:	90                   	nop

f0104f2c <IMCHK>:
TRAPHANDLER_NOEC(IMCHK      ,18)		// machine check
f0104f2c:	6a 00                	push   $0x0
f0104f2e:	6a 12                	push   $0x12
f0104f30:	e9 9f d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f35:	90                   	nop

f0104f36 <ISIMDERR>:
TRAPHANDLER_NOEC(ISIMDERR   ,19)		// SIMD floating point error
f0104f36:	6a 00                	push   $0x0
f0104f38:	6a 13                	push   $0x13
f0104f3a:	e9 95 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f3f:	90                   	nop

f0104f40 <ISYSCALL>:
TRAPHANDLER_NOEC(ISYSCALL   ,48)
f0104f40:	6a 00                	push   $0x0
f0104f42:	6a 30                	push   $0x30
f0104f44:	e9 8b d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f49:	90                   	nop

f0104f4a <IRQ0>:
TRAPHANDLER_NOEC(IRQ0,32)
f0104f4a:	6a 00                	push   $0x0
f0104f4c:	6a 20                	push   $0x20
f0104f4e:	e9 81 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f53:	90                   	nop

f0104f54 <IRQ1>:
TRAPHANDLER_NOEC(IRQ1,33)
f0104f54:	6a 00                	push   $0x0
f0104f56:	6a 21                	push   $0x21
f0104f58:	e9 77 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f5d:	90                   	nop

f0104f5e <IRQ2>:
TRAPHANDLER_NOEC(IRQ2,34)
f0104f5e:	6a 00                	push   $0x0
f0104f60:	6a 22                	push   $0x22
f0104f62:	e9 6d d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f67:	90                   	nop

f0104f68 <IRQ3>:
TRAPHANDLER_NOEC(IRQ3,35)
f0104f68:	6a 00                	push   $0x0
f0104f6a:	6a 23                	push   $0x23
f0104f6c:	e9 63 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f71:	90                   	nop

f0104f72 <IRQ4>:
TRAPHANDLER_NOEC(IRQ4,36)
f0104f72:	6a 00                	push   $0x0
f0104f74:	6a 24                	push   $0x24
f0104f76:	e9 59 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f7b:	90                   	nop

f0104f7c <IRQ5>:
TRAPHANDLER_NOEC(IRQ5,37)
f0104f7c:	6a 00                	push   $0x0
f0104f7e:	6a 25                	push   $0x25
f0104f80:	e9 4f d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f85:	90                   	nop

f0104f86 <IRQ6>:
TRAPHANDLER_NOEC(IRQ6,38)
f0104f86:	6a 00                	push   $0x0
f0104f88:	6a 26                	push   $0x26
f0104f8a:	e9 45 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f8f:	90                   	nop

f0104f90 <IRQ7>:
TRAPHANDLER_NOEC(IRQ7,39)
f0104f90:	6a 00                	push   $0x0
f0104f92:	6a 27                	push   $0x27
f0104f94:	e9 3b d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f99:	90                   	nop

f0104f9a <IRQ8>:
TRAPHANDLER_NOEC(IRQ8,40)
f0104f9a:	6a 00                	push   $0x0
f0104f9c:	6a 28                	push   $0x28
f0104f9e:	e9 31 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104fa3:	90                   	nop

f0104fa4 <IRQ9>:
TRAPHANDLER_NOEC(IRQ9,41)
f0104fa4:	6a 00                	push   $0x0
f0104fa6:	6a 29                	push   $0x29
f0104fa8:	e9 27 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104fad:	90                   	nop

f0104fae <IRQ10>:
TRAPHANDLER_NOEC(IRQ10,42)
f0104fae:	6a 00                	push   $0x0
f0104fb0:	6a 2a                	push   $0x2a
f0104fb2:	e9 1d d5 01 00       	jmp    f01224d4 <_alltraps>
f0104fb7:	90                   	nop

f0104fb8 <IRQ11>:
TRAPHANDLER_NOEC(IRQ11,43)
f0104fb8:	6a 00                	push   $0x0
f0104fba:	6a 2b                	push   $0x2b
f0104fbc:	e9 13 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104fc1:	90                   	nop

f0104fc2 <IRQ12>:
TRAPHANDLER_NOEC(IRQ12,44)
f0104fc2:	6a 00                	push   $0x0
f0104fc4:	6a 2c                	push   $0x2c
f0104fc6:	e9 09 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104fcb:	90                   	nop

f0104fcc <IRQ13>:
TRAPHANDLER_NOEC(IRQ13,45)
f0104fcc:	6a 00                	push   $0x0
f0104fce:	6a 2d                	push   $0x2d
f0104fd0:	e9 ff d4 01 00       	jmp    f01224d4 <_alltraps>
f0104fd5:	90                   	nop

f0104fd6 <IRQ14>:
TRAPHANDLER_NOEC(IRQ14,46)
f0104fd6:	6a 00                	push   $0x0
f0104fd8:	6a 2e                	push   $0x2e
f0104fda:	e9 f5 d4 01 00       	jmp    f01224d4 <_alltraps>
f0104fdf:	90                   	nop

f0104fe0 <IRQ15>:
TRAPHANDLER_NOEC(IRQ15,47)
f0104fe0:	6a 00                	push   $0x0
f0104fe2:	6a 2f                	push   $0x2f
f0104fe4:	e9 eb d4 01 00       	jmp    f01224d4 <_alltraps>

f0104fe9 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104fe9:	55                   	push   %ebp
f0104fea:	89 e5                	mov    %esp,%ebp
f0104fec:	83 ec 18             	sub    $0x18,%esp
f0104fef:	8b 15 48 f2 23 f0    	mov    0xf023f248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104ff5:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104ffa:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104ffd:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0105000:	83 f9 02             	cmp    $0x2,%ecx
f0105003:	76 0f                	jbe    f0105014 <sched_halt+0x2b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105005:	83 c0 01             	add    $0x1,%eax
f0105008:	83 c2 7c             	add    $0x7c,%edx
f010500b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0105010:	75 e8                	jne    f0104ffa <sched_halt+0x11>
f0105012:	eb 07                	jmp    f010501b <sched_halt+0x32>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0105014:	3d 00 04 00 00       	cmp    $0x400,%eax
f0105019:	75 1a                	jne    f0105035 <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f010501b:	c7 04 24 b0 8d 10 f0 	movl   $0xf0108db0,(%esp)
f0105022:	e8 55 f0 ff ff       	call   f010407c <cprintf>
		while (1)
			monitor(NULL);
f0105027:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010502e:	e8 c7 b9 ff ff       	call   f01009fa <monitor>
f0105033:	eb f2                	jmp    f0105027 <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0105035:	e8 7f 1f 00 00       	call   f0106fb9 <cpunum>
f010503a:	6b c0 74             	imul   $0x74,%eax,%eax
f010503d:	c7 80 28 10 24 f0 00 	movl   $0x0,-0xfdbefd8(%eax)
f0105044:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0105047:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010504c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0105051:	77 20                	ja     f0105073 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0105053:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105057:	c7 44 24 08 e8 76 10 	movl   $0xf01076e8,0x8(%esp)
f010505e:	f0 
f010505f:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0105066:	00 
f0105067:	c7 04 24 d9 8d 10 f0 	movl   $0xf0108dd9,(%esp)
f010506e:	e8 cd af ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0105073:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0105078:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010507b:	e8 39 1f 00 00       	call   f0106fb9 <cpunum>
f0105080:	6b d0 74             	imul   $0x74,%eax,%edx
f0105083:	81 c2 20 10 24 f0    	add    $0xf0241020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105089:	b8 02 00 00 00       	mov    $0x2,%eax
f010508e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105092:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0105099:	e8 45 22 00 00       	call   f01072e3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010509e:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01050a0:	e8 14 1f 00 00       	call   f0106fb9 <cpunum>
f01050a5:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01050a8:	8b 80 30 10 24 f0    	mov    -0xfdbefd0(%eax),%eax
f01050ae:	bd 00 00 00 00       	mov    $0x0,%ebp
f01050b3:	89 c4                	mov    %eax,%esp
f01050b5:	6a 00                	push   $0x0
f01050b7:	6a 00                	push   $0x0
f01050b9:	fb                   	sti    
f01050ba:	f4                   	hlt    
f01050bb:	eb fd                	jmp    f01050ba <sched_halt+0xd1>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01050bd:	c9                   	leave  
f01050be:	c3                   	ret    

f01050bf <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01050bf:	55                   	push   %ebp
f01050c0:	89 e5                	mov    %esp,%ebp
f01050c2:	53                   	push   %ebx
f01050c3:	83 ec 14             	sub    $0x14,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	if ( curenv == NULL ) idle = envs ; 
f01050c6:	e8 ee 1e 00 00       	call   f0106fb9 <cpunum>
f01050cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ce:	8b 1d 48 f2 23 f0    	mov    0xf023f248,%ebx
f01050d4:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f01050db:	74 11                	je     f01050ee <sched_yield+0x2f>
			else  idle = curenv + 1 ;
f01050dd:	e8 d7 1e 00 00       	call   f0106fb9 <cpunum>
f01050e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01050e5:	8b 98 28 10 24 f0    	mov    -0xfdbefd8(%eax),%ebx
f01050eb:	83 c3 7c             	add    $0x7c,%ebx
	for ( ; idle < envs + NENV ; idle ++ ) {
f01050ee:	a1 48 f2 23 f0       	mov    0xf023f248,%eax
f01050f3:	05 00 f0 01 00       	add    $0x1f000,%eax
f01050f8:	eb 11                	jmp    f010510b <sched_yield+0x4c>
		if ( idle ->env_status == ENV_RUNNABLE ) {
f01050fa:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f01050fe:	75 08                	jne    f0105108 <sched_yield+0x49>
			env_run( idle ) ; 
f0105100:	89 1c 24             	mov    %ebx,(%esp)
f0105103:	e8 0a ed ff ff       	call   f0103e12 <env_run>
	// below to halt the cpu.

	// LAB 4: Your code here.
	if ( curenv == NULL ) idle = envs ; 
			else  idle = curenv + 1 ;
	for ( ; idle < envs + NENV ; idle ++ ) {
f0105108:	83 c3 7c             	add    $0x7c,%ebx
f010510b:	39 c3                	cmp    %eax,%ebx
f010510d:	72 eb                	jb     f01050fa <sched_yield+0x3b>
		if ( idle ->env_status == ENV_RUNNABLE ) {
			env_run( idle ) ; 
	
		}
	}
	if ( curenv != NULL ) {
f010510f:	e8 a5 1e 00 00       	call   f0106fb9 <cpunum>
f0105114:	6b c0 74             	imul   $0x74,%eax,%eax
f0105117:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f010511e:	74 34                	je     f0105154 <sched_yield+0x95>
		for ( idle = envs ; idle < curenv ; idle ++ ) {
f0105120:	8b 1d 48 f2 23 f0    	mov    0xf023f248,%ebx
f0105126:	eb 11                	jmp    f0105139 <sched_yield+0x7a>
			if ( idle->env_status == ENV_RUNNABLE ) {
f0105128:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f010512c:	75 08                	jne    f0105136 <sched_yield+0x77>
				env_run ( idle ) ;
f010512e:	89 1c 24             	mov    %ebx,(%esp)
f0105131:	e8 dc ec ff ff       	call   f0103e12 <env_run>
			env_run( idle ) ; 
	
		}
	}
	if ( curenv != NULL ) {
		for ( idle = envs ; idle < curenv ; idle ++ ) {
f0105136:	83 c3 7c             	add    $0x7c,%ebx
f0105139:	e8 7b 1e 00 00       	call   f0106fb9 <cpunum>
f010513e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105141:	3b 98 28 10 24 f0    	cmp    -0xfdbefd8(%eax),%ebx
f0105147:	72 df                	jb     f0105128 <sched_yield+0x69>
			if ( idle->env_status == ENV_RUNNABLE ) {
				env_run ( idle ) ;
			}
		}	
		idle = envs + NENV ; 
f0105149:	a1 48 f2 23 f0       	mov    0xf023f248,%eax
f010514e:	8d 98 00 f0 01 00    	lea    0x1f000(%eax),%ebx
	}
	if ( ( curenv ) && ( idle == envs + NENV ) &&
f0105154:	e8 60 1e 00 00       	call   f0106fb9 <cpunum>
f0105159:	6b c0 74             	imul   $0x74,%eax,%eax
f010515c:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0105163:	74 38                	je     f010519d <sched_yield+0xde>
f0105165:	a1 48 f2 23 f0       	mov    0xf023f248,%eax
f010516a:	05 00 f0 01 00       	add    $0x1f000,%eax
f010516f:	39 c3                	cmp    %eax,%ebx
f0105171:	75 2a                	jne    f010519d <sched_yield+0xde>
             ( curenv->env_status == ENV_RUNNING) ) {
f0105173:	e8 41 1e 00 00       	call   f0106fb9 <cpunum>
f0105178:	6b c0 74             	imul   $0x74,%eax,%eax
f010517b:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
				env_run ( idle ) ;
			}
		}	
		idle = envs + NENV ; 
	}
	if ( ( curenv ) && ( idle == envs + NENV ) &&
f0105181:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0105185:	75 16                	jne    f010519d <sched_yield+0xde>
             ( curenv->env_status == ENV_RUNNING) ) {
		env_run( curenv ) ; 
f0105187:	e8 2d 1e 00 00       	call   f0106fb9 <cpunum>
f010518c:	6b c0 74             	imul   $0x74,%eax,%eax
f010518f:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105195:	89 04 24             	mov    %eax,(%esp)
f0105198:	e8 75 ec ff ff       	call   f0103e12 <env_run>
	}			
	// sched_halt never returns
	sched_halt();
f010519d:	e8 47 fe ff ff       	call   f0104fe9 <sched_halt>
}
f01051a2:	83 c4 14             	add    $0x14,%esp
f01051a5:	5b                   	pop    %ebx
f01051a6:	5d                   	pop    %ebp
f01051a7:	c3                   	ret    
f01051a8:	66 90                	xchg   %ax,%ax
f01051aa:	66 90                	xchg   %ax,%ax
f01051ac:	66 90                	xchg   %ax,%ax
f01051ae:	66 90                	xchg   %ax,%ax

f01051b0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01051b0:	55                   	push   %ebp
f01051b1:	89 e5                	mov    %esp,%ebp
f01051b3:	53                   	push   %ebx
f01051b4:	83 ec 24             	sub    $0x24,%esp
f01051b7:	8b 45 08             	mov    0x8(%ebp),%eax

	//panic("syscall not implemented");
	//if ( syscallno == SYS_yield){
	//	cprintf("Does it happen?\n");
	//}
	switch (syscallno) {
f01051ba:	83 f8 0c             	cmp    $0xc,%eax
f01051bd:	0f 87 39 06 00 00    	ja     f01057fc <syscall+0x64c>
f01051c3:	ff 24 85 20 8e 10 f0 	jmp    *-0xfef71e0(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        user_mem_assert( curenv , s , len , PTE_U ) ;	
f01051ca:	e8 ea 1d 00 00       	call   f0106fb9 <cpunum>
f01051cf:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01051d6:	00 
f01051d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01051da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01051de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01051e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01051e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01051e8:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01051ee:	89 04 24             	mov    %eax,(%esp)
f01051f1:	e8 12 e4 ff ff       	call   f0103608 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01051f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051f9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01051fd:	8b 45 10             	mov    0x10(%ebp),%eax
f0105200:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105204:	c7 04 24 e6 8d 10 f0 	movl   $0xf0108de6,(%esp)
f010520b:	e8 6c ee ff ff       	call   f010407c <cprintf>
	//	cprintf("Does it happen?\n");
	//}
	switch (syscallno) {
		case SYS_cputs :
			sys_cputs( ( const char * ) a1 , ( size_t ) a2 ); 
			return 0 ; 
f0105210:	b8 00 00 00 00       	mov    $0x0,%eax
f0105215:	e9 ee 05 00 00       	jmp    f0105808 <syscall+0x658>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010521a:	e8 16 b4 ff ff       	call   f0100635 <cons_getc>
	switch (syscallno) {
		case SYS_cputs :
			sys_cputs( ( const char * ) a1 , ( size_t ) a2 ); 
			return 0 ; 
		case SYS_cgetc :
			return sys_cgetc();
f010521f:	90                   	nop
f0105220:	e9 e3 05 00 00       	jmp    f0105808 <syscall+0x658>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0105225:	e8 8f 1d 00 00       	call   f0106fb9 <cpunum>
f010522a:	6b c0 74             	imul   $0x74,%eax,%eax
f010522d:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105233:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs( ( const char * ) a1 , ( size_t ) a2 ); 
			return 0 ; 
		case SYS_cgetc :
			return sys_cgetc();
		case SYS_getenvid:
                        return sys_getenvid();
f0105236:	e9 cd 05 00 00       	jmp    f0105808 <syscall+0x658>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010523b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105242:	00 
f0105243:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105246:	89 44 24 04          	mov    %eax,0x4(%esp)
f010524a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010524d:	89 04 24             	mov    %eax,(%esp)
f0105250:	e8 a7 e4 ff ff       	call   f01036fc <envid2env>
		return r;
f0105255:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0105257:	85 c0                	test   %eax,%eax
f0105259:	78 6e                	js     f01052c9 <syscall+0x119>
		return r;
	if (e == curenv)
f010525b:	e8 59 1d 00 00       	call   f0106fb9 <cpunum>
f0105260:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105263:	6b c0 74             	imul   $0x74,%eax,%eax
f0105266:	39 90 28 10 24 f0    	cmp    %edx,-0xfdbefd8(%eax)
f010526c:	75 23                	jne    f0105291 <syscall+0xe1>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010526e:	e8 46 1d 00 00       	call   f0106fb9 <cpunum>
f0105273:	6b c0 74             	imul   $0x74,%eax,%eax
f0105276:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f010527c:	8b 40 48             	mov    0x48(%eax),%eax
f010527f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105283:	c7 04 24 eb 8d 10 f0 	movl   $0xf0108deb,(%esp)
f010528a:	e8 ed ed ff ff       	call   f010407c <cprintf>
f010528f:	eb 28                	jmp    f01052b9 <syscall+0x109>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105291:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105294:	e8 20 1d 00 00       	call   f0106fb9 <cpunum>
f0105299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010529d:	6b c0 74             	imul   $0x74,%eax,%eax
f01052a0:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01052a6:	8b 40 48             	mov    0x48(%eax),%eax
f01052a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052ad:	c7 04 24 06 8e 10 f0 	movl   $0xf0108e06,(%esp)
f01052b4:	e8 c3 ed ff ff       	call   f010407c <cprintf>
	env_destroy(e);
f01052b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052bc:	89 04 24             	mov    %eax,(%esp)
f01052bf:	e8 9f ea ff ff       	call   f0103d63 <env_destroy>
	return 0;
f01052c4:	ba 00 00 00 00       	mov    $0x0,%edx
		case SYS_cgetc :
			return sys_cgetc();
		case SYS_getenvid:
                        return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy( a1 ) ; 
f01052c9:	89 d0                	mov    %edx,%eax
f01052cb:	e9 38 05 00 00       	jmp    f0105808 <syscall+0x658>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01052d0:	e8 ea fd ff ff       	call   f01050bf <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env * newenv = NULL ; 
f01052d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_alloc = env_alloc( &newenv , curenv->env_id ) ; 
f01052dc:	e8 d8 1c 00 00       	call   f0106fb9 <cpunum>
f01052e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01052e4:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01052ea:	8b 40 48             	mov    0x48(%eax),%eax
f01052ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01052f4:	89 04 24             	mov    %eax,(%esp)
f01052f7:	e8 09 e5 ff ff       	call   f0103805 <env_alloc>
	if ( result_alloc < 0 ) return result_alloc ; 
f01052fc:	89 c2                	mov    %eax,%edx
f01052fe:	85 c0                	test   %eax,%eax
f0105300:	78 50                	js     f0105352 <syscall+0x1a2>
	memcpy( & ( newenv->env_tf ) , & ( curenv->env_tf ) , sizeof( struct Trapframe ) ) ;
f0105302:	e8 b2 1c 00 00       	call   f0106fb9 <cpunum>
f0105307:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010530e:	00 
f010530f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105312:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105318:	89 44 24 04          	mov    %eax,0x4(%esp)
f010531c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010531f:	89 04 24             	mov    %eax,(%esp)
f0105322:	e8 f5 16 00 00       	call   f0106a1c <memcpy>
	newenv->env_status = ENV_NOT_RUNNABLE ; 
f0105327:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010532a:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	(newenv->env_tf).tf_regs.reg_eax = 0 ;
f0105331:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
	(newenv->env_pgfault_upcall) = ( curenv->env_pgfault_upcall);
f0105338:	e8 7c 1c 00 00       	call   f0106fb9 <cpunum>
f010533d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105340:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105346:	8b 40 64             	mov    0x64(%eax),%eax
f0105349:	89 43 64             	mov    %eax,0x64(%ebx)
	//cprintf(" sys_exofor : eip is %08x\n",(newenv->env_tf).tf_eip ) ; 
	return ( newenv->env_id ) ;  
f010534c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010534f:	8b 50 48             	mov    0x48(%eax),%edx
			return sys_env_destroy( a1 ) ; 
		case SYS_yield:
			sys_yield();
			return 0 ;	
		case SYS_exofork:
			return sys_exofork() ; 
f0105352:	89 d0                	mov    %edx,%eax
f0105354:	e9 af 04 00 00       	jmp    f0105808 <syscall+0x658>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
        //cprintf(" sys_page_alloc : %d %08x\n",envid,(uint32_t)va);
	struct Env * tarenv = NULL ; 
f0105359:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
f0105360:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105367:	00 
f0105368:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010536b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010536f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105372:	89 04 24             	mov    %eax,(%esp)
f0105375:	e8 82 e3 ff ff       	call   f01036fc <envid2env>
	if ( result_getenv < 0 ) 
f010537a:	85 c0                	test   %eax,%eax
f010537c:	78 6d                	js     f01053eb <syscall+0x23b>
		return -E_BAD_ENV ; 	
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
f010537e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105385:	77 6e                	ja     f01053f5 <syscall+0x245>
f0105387:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010538e:	75 6f                	jne    f01053ff <syscall+0x24f>
		return -E_INVAL ; 
	//cprintf("Did it reach here? perm : %08x\n",perm);
        if ( ( ! ( perm & PTE_U ) ) ||
 	     ( ! ( perm & PTE_P ) ) ||
f0105390:	8b 45 14             	mov    0x14(%ebp),%eax
f0105393:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
	if ( result_getenv < 0 ) 
		return -E_BAD_ENV ; 	
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
		return -E_INVAL ; 
	//cprintf("Did it reach here? perm : %08x\n",perm);
        if ( ( ! ( perm & PTE_U ) ) ||
f0105398:	83 f8 05             	cmp    $0x5,%eax
f010539b:	75 6c                	jne    f0105409 <syscall+0x259>
 	     ( ! ( perm & PTE_P ) ) ||
             ( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f010539d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01053a4:	e8 c0 bd ff ff       	call   f0101169 <page_alloc>
f01053a9:	89 c3                	mov    %eax,%ebx
	if ( pp == NULL ) return -E_NO_MEM ; 
f01053ab:	85 c0                	test   %eax,%eax
f01053ad:	74 64                	je     f0105413 <syscall+0x263>
	int result_insert = page_insert( tarenv->env_pgdir , pp , va , perm ) ; 
f01053af:	8b 45 14             	mov    0x14(%ebp),%eax
f01053b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01053b6:	8b 45 10             	mov    0x10(%ebp),%eax
f01053b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01053bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01053c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01053c4:	8b 40 60             	mov    0x60(%eax),%eax
f01053c7:	89 04 24             	mov    %eax,(%esp)
f01053ca:	e8 a2 c0 ff ff       	call   f0101471 <page_insert>
	if ( result_insert < 0 ) {
f01053cf:	85 c0                	test   %eax,%eax
f01053d1:	79 4a                	jns    f010541d <syscall+0x26d>
		pp->pp_ref = 0 ; 
f01053d3:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		page_free(pp);
f01053d9:	89 1c 24             	mov    %ebx,(%esp)
f01053dc:	e8 13 be ff ff       	call   f01011f4 <page_free>
		return -E_NO_MEM ; 
f01053e1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01053e6:	e9 1d 04 00 00       	jmp    f0105808 <syscall+0x658>
	// LAB 4: Your code here.
        //cprintf(" sys_page_alloc : %d %08x\n",envid,(uint32_t)va);
	struct Env * tarenv = NULL ; 
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
	if ( result_getenv < 0 ) 
		return -E_BAD_ENV ; 	
f01053eb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01053f0:	e9 13 04 00 00       	jmp    f0105808 <syscall+0x658>
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
		return -E_INVAL ; 
f01053f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053fa:	e9 09 04 00 00       	jmp    f0105808 <syscall+0x658>
f01053ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105404:	e9 ff 03 00 00       	jmp    f0105808 <syscall+0x658>
	//cprintf("Did it reach here? perm : %08x\n",perm);
        if ( ( ! ( perm & PTE_U ) ) ||
 	     ( ! ( perm & PTE_P ) ) ||
             ( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
f0105409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010540e:	e9 f5 03 00 00       	jmp    f0105808 <syscall+0x658>
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if ( pp == NULL ) return -E_NO_MEM ; 
f0105413:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105418:	e9 eb 03 00 00       	jmp    f0105808 <syscall+0x658>
	if ( result_insert < 0 ) {
		pp->pp_ref = 0 ; 
		page_free(pp);
		return -E_NO_MEM ; 
	}
	return 0 ; 
f010541d:	b8 00 00 00 00       	mov    $0x0,%eax
			sys_yield();
			return 0 ;	
		case SYS_exofork:
			return sys_exofork() ; 
		case SYS_page_alloc:
			return sys_page_alloc( ( envid_t ) a1 , ( void * ) a2 , a3 ) ;
f0105422:	e9 e1 03 00 00       	jmp    f0105808 <syscall+0x658>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env * srcenv = NULL ; 
f0105427:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int result_getsrcenv = envid2env( srcenvid , &srcenv  , 1 ) ;
f010542e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105435:	00 
f0105436:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105439:	89 44 24 04          	mov    %eax,0x4(%esp)
f010543d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105440:	89 04 24             	mov    %eax,(%esp)
f0105443:	e8 b4 e2 ff ff       	call   f01036fc <envid2env>
	if ( result_getsrcenv < 0 ) 
f0105448:	85 c0                	test   %eax,%eax
f010544a:	0f 88 ce 00 00 00    	js     f010551e <syscall+0x36e>
		return -E_BAD_ENV ; 	
	struct Env * dstenv = NULL ; 
f0105450:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int result_getdstenv = envid2env( dstenvid , &dstenv  , 1 ) ;
f0105457:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010545e:	00 
f010545f:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105462:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105466:	8b 45 14             	mov    0x14(%ebp),%eax
f0105469:	89 04 24             	mov    %eax,(%esp)
f010546c:	e8 8b e2 ff ff       	call   f01036fc <envid2env>
	if ( result_getdstenv < 0 ) 
f0105471:	85 c0                	test   %eax,%eax
f0105473:	0f 88 af 00 00 00    	js     f0105528 <syscall+0x378>
		return -E_BAD_ENV ; 	
	
	if ( ( ( uint32_t ) srcva >= UTOP ) || ( PGOFF( ( uint32_t ) srcva ) ) ) 
f0105479:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105480:	0f 87 ac 00 00 00    	ja     f0105532 <syscall+0x382>
f0105486:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010548d:	0f 85 a9 00 00 00    	jne    f010553c <syscall+0x38c>
		return -E_INVAL ; 

	if ( ( ( uint32_t ) dstva >= UTOP ) || ( PGOFF( ( uint32_t ) dstva ) ) ) 
f0105493:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010549a:	0f 87 a6 00 00 00    	ja     f0105546 <syscall+0x396>
f01054a0:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01054a7:	0f 85 a3 00 00 00    	jne    f0105550 <syscall+0x3a0>
		return -E_INVAL ; 
       
        if ( ( ! ( perm & PTE_U ) ) ||
 	     ( ! ( perm & PTE_P ) ) ||
f01054ad:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01054b0:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
		return -E_INVAL ; 

	if ( ( ( uint32_t ) dstva >= UTOP ) || ( PGOFF( ( uint32_t ) dstva ) ) ) 
		return -E_INVAL ; 
       
        if ( ( ! ( perm & PTE_U ) ) ||
f01054b5:	83 f8 05             	cmp    $0x5,%eax
f01054b8:	0f 85 9c 00 00 00    	jne    f010555a <syscall+0x3aa>
 	     ( ! ( perm & PTE_P ) ) ||
             ( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
	pte_t *srcpte = NULL ;  
f01054be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
f01054c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01054c8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054cc:	8b 45 10             	mov    0x10(%ebp),%eax
f01054cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054d6:	8b 40 60             	mov    0x60(%eax),%eax
f01054d9:	89 04 24             	mov    %eax,(%esp)
f01054dc:	e8 93 be ff ff       	call   f0101374 <page_lookup>
	if ( pp == NULL ) return -E_INVAL ; 
f01054e1:	85 c0                	test   %eax,%eax
f01054e3:	74 7f                	je     f0105564 <syscall+0x3b4>
	
	if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
f01054e5:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01054e9:	74 08                	je     f01054f3 <syscall+0x343>
f01054eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01054ee:	f6 02 02             	testb  $0x2,(%edx)
f01054f1:	74 7b                	je     f010556e <syscall+0x3be>
		return -E_INVAL ; 

	int result_insert = page_insert( dstenv->env_pgdir , pp , dstva , perm ) ;	
f01054f3:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f01054f6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01054fa:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01054fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105501:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105505:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105508:	8b 40 60             	mov    0x60(%eax),%eax
f010550b:	89 04 24             	mov    %eax,(%esp)
f010550e:	e8 5e bf ff ff       	call   f0101471 <page_insert>
	if ( result_insert < 0 ) 
		return -E_NO_MEM ; 
f0105513:	c1 f8 1f             	sar    $0x1f,%eax
f0105516:	83 e0 fc             	and    $0xfffffffc,%eax
f0105519:	e9 ea 02 00 00       	jmp    f0105808 <syscall+0x658>

	// LAB 4: Your code here.
	struct Env * srcenv = NULL ; 
	int result_getsrcenv = envid2env( srcenvid , &srcenv  , 1 ) ;
	if ( result_getsrcenv < 0 ) 
		return -E_BAD_ENV ; 	
f010551e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105523:	e9 e0 02 00 00       	jmp    f0105808 <syscall+0x658>
	struct Env * dstenv = NULL ; 
	int result_getdstenv = envid2env( dstenvid , &dstenv  , 1 ) ;
	if ( result_getdstenv < 0 ) 
		return -E_BAD_ENV ; 	
f0105528:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010552d:	e9 d6 02 00 00       	jmp    f0105808 <syscall+0x658>
	
	if ( ( ( uint32_t ) srcva >= UTOP ) || ( PGOFF( ( uint32_t ) srcva ) ) ) 
		return -E_INVAL ; 
f0105532:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105537:	e9 cc 02 00 00       	jmp    f0105808 <syscall+0x658>
f010553c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105541:	e9 c2 02 00 00       	jmp    f0105808 <syscall+0x658>

	if ( ( ( uint32_t ) dstva >= UTOP ) || ( PGOFF( ( uint32_t ) dstva ) ) ) 
		return -E_INVAL ; 
f0105546:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010554b:	e9 b8 02 00 00       	jmp    f0105808 <syscall+0x658>
f0105550:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105555:	e9 ae 02 00 00       	jmp    f0105808 <syscall+0x658>
       
        if ( ( ! ( perm & PTE_U ) ) ||
 	     ( ! ( perm & PTE_P ) ) ||
             ( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
f010555a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010555f:	e9 a4 02 00 00       	jmp    f0105808 <syscall+0x658>
	pte_t *srcpte = NULL ;  
	struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
	if ( pp == NULL ) return -E_INVAL ; 
f0105564:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105569:	e9 9a 02 00 00       	jmp    f0105808 <syscall+0x658>
	
	if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
		return -E_INVAL ; 
f010556e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_exofork:
			return sys_exofork() ; 
		case SYS_page_alloc:
			return sys_page_alloc( ( envid_t ) a1 , ( void * ) a2 , a3 ) ;
		case SYS_page_map:
			return sys_page_map( ( envid_t ) a1 , ( void * ) a2 , ( envid_t ) a3 , ( void * ) a4 , a5 ) ;
f0105573:	e9 90 02 00 00       	jmp    f0105808 <syscall+0x658>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
f0105578:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
f010557f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105586:	00 
f0105587:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010558a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010558e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105591:	89 04 24             	mov    %eax,(%esp)
f0105594:	e8 63 e1 ff ff       	call   f01036fc <envid2env>
	if ( result_getenv < 0 ) 
f0105599:	85 c0                	test   %eax,%eax
f010559b:	78 31                	js     f01055ce <syscall+0x41e>
		return -E_BAD_ENV ; 	
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
f010559d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01055a4:	77 32                	ja     f01055d8 <syscall+0x428>
f01055a6:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01055ad:	75 33                	jne    f01055e2 <syscall+0x432>
		return -E_INVAL ; 
  	page_remove( tarenv->env_pgdir , va ) ; 	
f01055af:	8b 45 10             	mov    0x10(%ebp),%eax
f01055b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01055b9:	8b 40 60             	mov    0x60(%eax),%eax
f01055bc:	89 04 24             	mov    %eax,(%esp)
f01055bf:	e8 5d be ff ff       	call   f0101421 <page_remove>
	return 0 ;
f01055c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01055c9:	e9 3a 02 00 00       	jmp    f0105808 <syscall+0x658>

	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
	if ( result_getenv < 0 ) 
		return -E_BAD_ENV ; 	
f01055ce:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01055d3:	e9 30 02 00 00       	jmp    f0105808 <syscall+0x658>
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
		return -E_INVAL ; 
f01055d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055dd:	e9 26 02 00 00       	jmp    f0105808 <syscall+0x658>
f01055e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc:
			return sys_page_alloc( ( envid_t ) a1 , ( void * ) a2 , a3 ) ;
		case SYS_page_map:
			return sys_page_map( ( envid_t ) a1 , ( void * ) a2 , ( envid_t ) a3 , ( void * ) a4 , a5 ) ;
		case SYS_page_unmap:
			return sys_page_unmap( ( envid_t ) a1 , ( void * ) a2 ) ;
f01055e7:	e9 1c 02 00 00       	jmp    f0105808 <syscall+0x658>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
f01055ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
f01055f3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01055fa:	00 
f01055fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01055fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105602:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105605:	89 04 24             	mov    %eax,(%esp)
f0105608:	e8 ef e0 ff ff       	call   f01036fc <envid2env>
	if ( result_getenv < 0 ) return result_getenv ; 
f010560d:	85 c0                	test   %eax,%eax
f010560f:	0f 88 f3 01 00 00    	js     f0105808 <syscall+0x658>
	tarenv->env_status = status ;
f0105615:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105618:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010561b:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0 ;  
f010561e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105623:	e9 e0 01 00 00       	jmp    f0105808 <syscall+0x658>
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
f0105628:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
f010562f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105636:	00 
f0105637:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010563a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010563e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105641:	89 04 24             	mov    %eax,(%esp)
f0105644:	e8 b3 e0 ff ff       	call   f01036fc <envid2env>

	if ( result_getenv < 0 ) 
f0105649:	85 c0                	test   %eax,%eax
f010564b:	78 13                	js     f0105660 <syscall+0x4b0>
		return -E_BAD_ENV ; 
	(tarenv->env_pgfault_upcall) = func ;
f010564d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105650:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105653:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0 ; 
f0105656:	b8 00 00 00 00       	mov    $0x0,%eax
f010565b:	e9 a8 01 00 00       	jmp    f0105808 <syscall+0x658>
	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;

	if ( result_getenv < 0 ) 
		return -E_BAD_ENV ; 
f0105660:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		case SYS_page_unmap:
			return sys_page_unmap( ( envid_t ) a1 , ( void * ) a2 ) ;
		case SYS_env_set_status:
			return sys_env_set_status( ( envid_t ) a1 , a2 ) ;   
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall( ( envid_t ) a1 , ( void * ) a2 ) ; 
f0105665:	e9 9e 01 00 00       	jmp    f0105808 <syscall+0x658>
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env * srcenv = curenv ; 
f010566a:	e8 4a 19 00 00       	call   f0106fb9 <cpunum>
f010566f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105672:	8b 98 28 10 24 f0    	mov    -0xfdbefd8(%eax),%ebx
	struct Env * dstenv = NULL ; 
f0105678:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int result_getdstenv = envid2env( envid , &dstenv  , 0 ) ;
f010567f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105686:	00 
f0105687:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010568a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010568e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105691:	89 04 24             	mov    %eax,(%esp)
f0105694:	e8 63 e0 ff ff       	call   f01036fc <envid2env>
	if ( result_getdstenv < 0 ) 
f0105699:	85 c0                	test   %eax,%eax
f010569b:	0f 88 f4 00 00 00    	js     f0105795 <syscall+0x5e5>
		return -E_BAD_ENV ; 	
	if ( ! ( dstenv->env_ipc_recving ) ) 
f01056a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01056a4:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01056a8:	0f 84 ee 00 00 00    	je     f010579c <syscall+0x5ec>
		return -E_IPC_NOT_RECV ; 	

	if ( (( (uintptr_t)srcva) < UTOP ) && ( PGOFF(srcva) != 0 ) ) 
f01056ae:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01056b5:	0f 87 9b 00 00 00    	ja     f0105756 <syscall+0x5a6>
f01056bb:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01056c2:	0f 85 db 00 00 00    	jne    f01057a3 <syscall+0x5f3>
		return  -E_INVAL ; 
		
	if ( ( ( uintptr_t ) srcva ) < UTOP ) {	
		if ( ( ! ( perm & PTE_U ) ) ||
				( ! ( perm & PTE_P ) ) ||
f01056c8:	8b 55 18             	mov    0x18(%ebp),%edx
f01056cb:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
				( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
f01056d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	if ( (( (uintptr_t)srcva) < UTOP ) && ( PGOFF(srcva) != 0 ) ) 
		return  -E_INVAL ; 
		
	if ( ( ( uintptr_t ) srcva ) < UTOP ) {	
		if ( ( ! ( perm & PTE_U ) ) ||
f01056d6:	83 fa 05             	cmp    $0x5,%edx
f01056d9:	0f 85 29 01 00 00    	jne    f0105808 <syscall+0x658>
				( ! ( perm & PTE_P ) ) ||
				( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
		pte_t *srcpte = NULL ;  
f01056df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
f01056e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01056e9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01056ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01056f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056f4:	8b 43 60             	mov    0x60(%ebx),%eax
f01056f7:	89 04 24             	mov    %eax,(%esp)
f01056fa:	e8 75 bc ff ff       	call   f0101374 <page_lookup>
f01056ff:	89 c2                	mov    %eax,%edx
		if ( pp == NULL ) return -E_INVAL ; 
f0105701:	85 c0                	test   %eax,%eax
f0105703:	74 3d                	je     f0105742 <syscall+0x592>

		if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
f0105705:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105709:	74 11                	je     f010571c <syscall+0x56c>
			return -E_INVAL ; 
f010570b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL ;  			
		pte_t *srcpte = NULL ;  
		struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
		if ( pp == NULL ) return -E_INVAL ; 

		if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
f0105710:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0105713:	f6 01 02             	testb  $0x2,(%ecx)
f0105716:	0f 84 ec 00 00 00    	je     f0105808 <syscall+0x658>
			return -E_INVAL ; 

		int result_insert = page_insert( dstenv->env_pgdir , pp , dstenv->env_ipc_dstva , perm ) ;	
f010571c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010571f:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105722:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105726:	8b 48 6c             	mov    0x6c(%eax),%ecx
f0105729:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010572d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105731:	8b 40 60             	mov    0x60(%eax),%eax
f0105734:	89 04 24             	mov    %eax,(%esp)
f0105737:	e8 35 bd ff ff       	call   f0101471 <page_insert>
		if ( result_insert < 0 ) 
f010573c:	85 c0                	test   %eax,%eax
f010573e:	79 16                	jns    f0105756 <syscall+0x5a6>
f0105740:	eb 0a                	jmp    f010574c <syscall+0x59c>
				( ! ( perm & PTE_P ) ) ||
				( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
		pte_t *srcpte = NULL ;  
		struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
		if ( pp == NULL ) return -E_INVAL ; 
f0105742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105747:	e9 bc 00 00 00       	jmp    f0105808 <syscall+0x658>
		if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
			return -E_INVAL ; 

		int result_insert = page_insert( dstenv->env_pgdir , pp , dstenv->env_ipc_dstva , perm ) ;	
		if ( result_insert < 0 ) 
		return -E_NO_MEM ; 
f010574c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105751:	e9 b2 00 00 00       	jmp    f0105808 <syscall+0x658>
	}
	dstenv->env_ipc_recving = false ; 
f0105756:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105759:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	dstenv->env_ipc_from = curenv->env_id ; 
f010575d:	e8 57 18 00 00       	call   f0106fb9 <cpunum>
f0105762:	6b c0 74             	imul   $0x74,%eax,%eax
f0105765:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f010576b:	8b 40 48             	mov    0x48(%eax),%eax
f010576e:	89 43 74             	mov    %eax,0x74(%ebx)
	dstenv->env_ipc_value = value ; 
f0105771:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105774:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105777:	89 48 70             	mov    %ecx,0x70(%eax)
	dstenv->env_status = ENV_RUNNABLE ;		
f010577a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	dstenv->env_ipc_perm = perm ;
f0105781:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105784:	89 58 78             	mov    %ebx,0x78(%eax)
	(dstenv->env_tf).tf_regs.reg_eax = 0 ;
f0105787:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0 ;
f010578e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105793:	eb 73                	jmp    f0105808 <syscall+0x658>
	// LAB 4: Your code here.
	struct Env * srcenv = curenv ; 
	struct Env * dstenv = NULL ; 
	int result_getdstenv = envid2env( envid , &dstenv  , 0 ) ;
	if ( result_getdstenv < 0 ) 
		return -E_BAD_ENV ; 	
f0105795:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010579a:	eb 6c                	jmp    f0105808 <syscall+0x658>
	if ( ! ( dstenv->env_ipc_recving ) ) 
		return -E_IPC_NOT_RECV ; 	
f010579c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
f01057a1:	eb 65                	jmp    f0105808 <syscall+0x658>

	if ( (( (uintptr_t)srcva) < UTOP ) && ( PGOFF(srcva) != 0 ) ) 
		return  -E_INVAL ; 
f01057a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_env_set_status:
			return sys_env_set_status( ( envid_t ) a1 , a2 ) ;   
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall( ( envid_t ) a1 , ( void * ) a2 ) ; 
		case SYS_ipc_try_send:
			return sys_ipc_try_send( ( envid_t) a1 , a2 , (void * ) a3 , a4 ) ; 
f01057a8:	eb 5e                	jmp    f0105808 <syscall+0x658>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ( (( (uintptr_t)dstva) < UTOP ) && ( PGOFF(dstva) != 0 ) ) 
f01057aa:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01057b1:	77 09                	ja     f01057bc <syscall+0x60c>
f01057b3:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01057ba:	75 47                	jne    f0105803 <syscall+0x653>
		return  -E_INVAL ; 
	curenv->env_ipc_recving = true ;
f01057bc:	e8 f8 17 00 00       	call   f0106fb9 <cpunum>
f01057c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01057c4:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01057ca:	c6 40 68 01          	movb   $0x1,0x68(%eax)
 	curenv->env_status = ENV_NOT_RUNNABLE ;
f01057ce:	e8 e6 17 00 00       	call   f0106fb9 <cpunum>
f01057d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01057d6:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01057dc:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva ;  
f01057e3:	e8 d1 17 00 00       	call   f0106fb9 <cpunum>
f01057e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01057eb:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01057f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01057f4:	89 58 6c             	mov    %ebx,0x6c(%eax)
	sched_yield();
f01057f7:	e8 c3 f8 ff ff       	call   f01050bf <sched_yield>
		case SYS_ipc_try_send:
			return sys_ipc_try_send( ( envid_t) a1 , a2 , (void * ) a3 , a4 ) ; 
		case SYS_ipc_recv:
			return sys_ipc_recv( (void* ) a1 ) ;
	default:
		return -E_NO_SYS;
f01057fc:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0105801:	eb 05                	jmp    f0105808 <syscall+0x658>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall( ( envid_t ) a1 , ( void * ) a2 ) ; 
		case SYS_ipc_try_send:
			return sys_ipc_try_send( ( envid_t) a1 , a2 , (void * ) a3 , a4 ) ; 
		case SYS_ipc_recv:
			return sys_ipc_recv( (void* ) a1 ) ;
f0105803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	default:
		return -E_NO_SYS;
	}
}
f0105808:	83 c4 24             	add    $0x24,%esp
f010580b:	5b                   	pop    %ebx
f010580c:	5d                   	pop    %ebp
f010580d:	c3                   	ret    

f010580e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010580e:	55                   	push   %ebp
f010580f:	89 e5                	mov    %esp,%ebp
f0105811:	57                   	push   %edi
f0105812:	56                   	push   %esi
f0105813:	53                   	push   %ebx
f0105814:	83 ec 14             	sub    $0x14,%esp
f0105817:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010581a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010581d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105820:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105823:	8b 1a                	mov    (%edx),%ebx
f0105825:	8b 01                	mov    (%ecx),%eax
f0105827:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010582a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0105831:	e9 88 00 00 00       	jmp    f01058be <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0105836:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105839:	01 d8                	add    %ebx,%eax
f010583b:	89 c7                	mov    %eax,%edi
f010583d:	c1 ef 1f             	shr    $0x1f,%edi
f0105840:	01 c7                	add    %eax,%edi
f0105842:	d1 ff                	sar    %edi
f0105844:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105847:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010584a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010584d:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010584f:	eb 03                	jmp    f0105854 <stab_binsearch+0x46>
			m--;
f0105851:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105854:	39 c3                	cmp    %eax,%ebx
f0105856:	7f 1f                	jg     f0105877 <stab_binsearch+0x69>
f0105858:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010585c:	83 ea 0c             	sub    $0xc,%edx
f010585f:	39 f1                	cmp    %esi,%ecx
f0105861:	75 ee                	jne    f0105851 <stab_binsearch+0x43>
f0105863:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105866:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105869:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010586c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105870:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105873:	76 18                	jbe    f010588d <stab_binsearch+0x7f>
f0105875:	eb 05                	jmp    f010587c <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105877:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010587a:	eb 42                	jmp    f01058be <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010587c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010587f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105881:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105884:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010588b:	eb 31                	jmp    f01058be <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010588d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105890:	73 17                	jae    f01058a9 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0105892:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105895:	83 e8 01             	sub    $0x1,%eax
f0105898:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010589b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010589e:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01058a0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01058a7:	eb 15                	jmp    f01058be <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01058a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01058ac:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01058af:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f01058b1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01058b5:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01058b7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01058be:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01058c1:	0f 8e 6f ff ff ff    	jle    f0105836 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01058c7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01058cb:	75 0f                	jne    f01058dc <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01058cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058d0:	8b 00                	mov    (%eax),%eax
f01058d2:	83 e8 01             	sub    $0x1,%eax
f01058d5:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01058d8:	89 07                	mov    %eax,(%edi)
f01058da:	eb 2c                	jmp    f0105908 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01058dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058df:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01058e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01058e4:	8b 0f                	mov    (%edi),%ecx
f01058e6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01058e9:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01058ec:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01058ef:	eb 03                	jmp    f01058f4 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01058f1:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01058f4:	39 c8                	cmp    %ecx,%eax
f01058f6:	7e 0b                	jle    f0105903 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01058f8:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01058fc:	83 ea 0c             	sub    $0xc,%edx
f01058ff:	39 f3                	cmp    %esi,%ebx
f0105901:	75 ee                	jne    f01058f1 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105903:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105906:	89 07                	mov    %eax,(%edi)
	}
}
f0105908:	83 c4 14             	add    $0x14,%esp
f010590b:	5b                   	pop    %ebx
f010590c:	5e                   	pop    %esi
f010590d:	5f                   	pop    %edi
f010590e:	5d                   	pop    %ebp
f010590f:	c3                   	ret    

f0105910 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105910:	55                   	push   %ebp
f0105911:	89 e5                	mov    %esp,%ebp
f0105913:	57                   	push   %edi
f0105914:	56                   	push   %esi
f0105915:	53                   	push   %ebx
f0105916:	83 ec 5c             	sub    $0x5c,%esp
f0105919:	8b 75 08             	mov    0x8(%ebp),%esi
f010591c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010591f:	c7 07 54 8e 10 f0    	movl   $0xf0108e54,(%edi)
	info->eip_line = 0;
f0105925:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010592c:	c7 47 08 54 8e 10 f0 	movl   $0xf0108e54,0x8(%edi)
	info->eip_fn_namelen = 9;
f0105933:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f010593a:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f010593d:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105944:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010594a:	0f 87 dc 00 00 00    	ja     f0105a2c <debuginfo_eip+0x11c>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if ( user_mem_check( curenv , usd , sizeof( struct UserStabData) ,  PTE_U ) != 0 ) return -1 ; 
f0105950:	e8 64 16 00 00       	call   f0106fb9 <cpunum>
f0105955:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010595c:	00 
f010595d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105964:	00 
f0105965:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010596c:	00 
f010596d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105970:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105976:	89 04 24             	mov    %eax,(%esp)
f0105979:	e8 05 dc ff ff       	call   f0103583 <user_mem_check>
f010597e:	85 c0                	test   %eax,%eax
f0105980:	0f 85 6d 02 00 00    	jne    f0105bf3 <debuginfo_eip+0x2e3>

		stabs = usd->stabs;
f0105986:	a1 00 00 20 00       	mov    0x200000,%eax
f010598b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010598e:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0105994:	8b 15 08 00 20 00    	mov    0x200008,%edx
f010599a:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f010599d:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01059a3:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if ( user_mem_check( curenv , usd->stabs , usd->stab_end - usd->stabs ,  PTE_U ) != 0 ) return -1 ; 
f01059a6:	e8 0e 16 00 00       	call   f0106fb9 <cpunum>
f01059ab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01059b2:	00 
f01059b3:	89 da                	mov    %ebx,%edx
f01059b5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01059b8:	29 ca                	sub    %ecx,%edx
f01059ba:	c1 fa 02             	sar    $0x2,%edx
f01059bd:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01059c3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01059c7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01059cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01059ce:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01059d4:	89 04 24             	mov    %eax,(%esp)
f01059d7:	e8 a7 db ff ff       	call   f0103583 <user_mem_check>
f01059dc:	85 c0                	test   %eax,%eax
f01059de:	0f 85 16 02 00 00    	jne    f0105bfa <debuginfo_eip+0x2ea>
	 	if ( user_mem_check( curenv , usd->stabstr , usd->stabstr_end - usd-> stabstr, PTE_U ) != 0 ) return -1; 
f01059e4:	a1 08 00 20 00       	mov    0x200008,%eax
f01059e9:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01059ef:	89 45 b8             	mov    %eax,-0x48(%ebp)
f01059f2:	29 c2                	sub    %eax,%edx
f01059f4:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f01059f7:	e8 bd 15 00 00       	call   f0106fb9 <cpunum>
f01059fc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105a03:	00 
f0105a04:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0105a07:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105a0b:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0105a0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105a12:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a15:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105a1b:	89 04 24             	mov    %eax,(%esp)
f0105a1e:	e8 60 db ff ff       	call   f0103583 <user_mem_check>
f0105a23:	85 c0                	test   %eax,%eax
f0105a25:	74 1f                	je     f0105a46 <debuginfo_eip+0x136>
f0105a27:	e9 d5 01 00 00       	jmp    f0105c01 <debuginfo_eip+0x2f1>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105a2c:	c7 45 bc e8 7d 11 f0 	movl   $0xf0117de8,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105a33:	c7 45 c0 d5 45 11 f0 	movl   $0xf01145d5,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105a3a:	bb d4 45 11 f0       	mov    $0xf01145d4,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105a3f:	c7 45 c4 98 94 10 f0 	movl   $0xf0109498,-0x3c(%ebp)
		if ( user_mem_check( curenv , usd->stabs , usd->stab_end - usd->stabs ,  PTE_U ) != 0 ) return -1 ; 
	 	if ( user_mem_check( curenv , usd->stabstr , usd->stabstr_end - usd-> stabstr, PTE_U ) != 0 ) return -1; 
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105a46:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105a49:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0105a4c:	0f 83 b6 01 00 00    	jae    f0105c08 <debuginfo_eip+0x2f8>
f0105a52:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105a56:	0f 85 b3 01 00 00    	jne    f0105c0f <debuginfo_eip+0x2ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105a5c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105a63:	89 d8                	mov    %ebx,%eax
f0105a65:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105a68:	29 d8                	sub    %ebx,%eax
f0105a6a:	c1 f8 02             	sar    $0x2,%eax
f0105a6d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105a73:	83 e8 01             	sub    $0x1,%eax
f0105a76:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105a79:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a7d:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105a84:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105a87:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105a8a:	89 d8                	mov    %ebx,%eax
f0105a8c:	e8 7d fd ff ff       	call   f010580e <stab_binsearch>
	if (lfile == 0)
f0105a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a94:	85 c0                	test   %eax,%eax
f0105a96:	0f 84 7a 01 00 00    	je     f0105c16 <debuginfo_eip+0x306>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105a9c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105a9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105aa2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105aa5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105aa9:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105ab0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105ab3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105ab6:	89 d8                	mov    %ebx,%eax
f0105ab8:	e8 51 fd ff ff       	call   f010580e <stab_binsearch>

	if (lfun <= rfun) {
f0105abd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105ac0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105ac3:	39 d0                	cmp    %edx,%eax
f0105ac5:	7f 32                	jg     f0105af9 <debuginfo_eip+0x1e9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105ac7:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105aca:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105acd:	8d 0c 8b             	lea    (%ebx,%ecx,4),%ecx
f0105ad0:	8b 19                	mov    (%ecx),%ebx
f0105ad2:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f0105ad5:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0105ad8:	2b 5d c0             	sub    -0x40(%ebp),%ebx
f0105adb:	39 5d b8             	cmp    %ebx,-0x48(%ebp)
f0105ade:	73 09                	jae    f0105ae9 <debuginfo_eip+0x1d9>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105ae0:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105ae3:	03 5d c0             	add    -0x40(%ebp),%ebx
f0105ae6:	89 5f 08             	mov    %ebx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105ae9:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105aec:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0105aef:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105af1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105af4:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105af7:	eb 0f                	jmp    f0105b08 <debuginfo_eip+0x1f8>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105af9:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f0105afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105aff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105b02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b05:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105b08:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105b0f:	00 
f0105b10:	8b 47 08             	mov    0x8(%edi),%eax
f0105b13:	89 04 24             	mov    %eax,(%esp)
f0105b16:	e8 30 0e 00 00       	call   f010694b <strfind>
f0105b1b:	2b 47 08             	sub    0x8(%edi),%eax
f0105b1e:	89 47 0c             	mov    %eax,0xc(%edi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

        stab_binsearch(stabs, &lline , &rline , N_SLINE , addr ) ;
f0105b21:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b25:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105b2c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105b2f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105b32:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105b35:	89 f0                	mov    %esi,%eax
f0105b37:	e8 d2 fc ff ff       	call   f010580e <stab_binsearch>
        if ( lline > rline ) return -1 ;      
f0105b3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105b3f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105b42:	0f 8f d5 00 00 00    	jg     f0105c1d <debuginfo_eip+0x30d>
	info->eip_line = stabs[lline].n_desc ; 
f0105b48:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105b4b:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105b50:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105b53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b56:	89 c3                	mov    %eax,%ebx
f0105b58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105b5b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105b5e:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105b61:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105b64:	89 df                	mov    %ebx,%edi
f0105b66:	eb 06                	jmp    f0105b6e <debuginfo_eip+0x25e>
f0105b68:	83 e8 01             	sub    $0x1,%eax
f0105b6b:	83 ea 0c             	sub    $0xc,%edx
f0105b6e:	89 c6                	mov    %eax,%esi
f0105b70:	39 c7                	cmp    %eax,%edi
f0105b72:	7f 3c                	jg     f0105bb0 <debuginfo_eip+0x2a0>
	       && stabs[lline].n_type != N_SOL
f0105b74:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105b78:	80 f9 84             	cmp    $0x84,%cl
f0105b7b:	75 08                	jne    f0105b85 <debuginfo_eip+0x275>
f0105b7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105b80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105b83:	eb 11                	jmp    f0105b96 <debuginfo_eip+0x286>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105b85:	80 f9 64             	cmp    $0x64,%cl
f0105b88:	75 de                	jne    f0105b68 <debuginfo_eip+0x258>
f0105b8a:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105b8e:	74 d8                	je     f0105b68 <debuginfo_eip+0x258>
f0105b90:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105b93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105b96:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105b99:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105b9c:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105b9f:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105ba2:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105ba5:	39 d0                	cmp    %edx,%eax
f0105ba7:	73 0a                	jae    f0105bb3 <debuginfo_eip+0x2a3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105ba9:	03 45 c0             	add    -0x40(%ebp),%eax
f0105bac:	89 07                	mov    %eax,(%edi)
f0105bae:	eb 03                	jmp    f0105bb3 <debuginfo_eip+0x2a3>
f0105bb0:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105bb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105bb6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105bb9:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105bbe:	39 da                	cmp    %ebx,%edx
f0105bc0:	7d 67                	jge    f0105c29 <debuginfo_eip+0x319>
		for (lline = lfun + 1;
f0105bc2:	83 c2 01             	add    $0x1,%edx
f0105bc5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105bc8:	89 d0                	mov    %edx,%eax
f0105bca:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105bcd:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105bd0:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105bd3:	eb 04                	jmp    f0105bd9 <debuginfo_eip+0x2c9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105bd5:	83 47 14 01          	addl   $0x1,0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105bd9:	39 c3                	cmp    %eax,%ebx
f0105bdb:	7e 47                	jle    f0105c24 <debuginfo_eip+0x314>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105bdd:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105be1:	83 c0 01             	add    $0x1,%eax
f0105be4:	83 c2 0c             	add    $0xc,%edx
f0105be7:	80 f9 a0             	cmp    $0xa0,%cl
f0105bea:	74 e9                	je     f0105bd5 <debuginfo_eip+0x2c5>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105bec:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bf1:	eb 36                	jmp    f0105c29 <debuginfo_eip+0x319>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if ( user_mem_check( curenv , usd , sizeof( struct UserStabData) ,  PTE_U ) != 0 ) return -1 ; 
f0105bf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105bf8:	eb 2f                	jmp    f0105c29 <debuginfo_eip+0x319>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if ( user_mem_check( curenv , usd->stabs , usd->stab_end - usd->stabs ,  PTE_U ) != 0 ) return -1 ; 
f0105bfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105bff:	eb 28                	jmp    f0105c29 <debuginfo_eip+0x319>
	 	if ( user_mem_check( curenv , usd->stabstr , usd->stabstr_end - usd-> stabstr, PTE_U ) != 0 ) return -1; 
f0105c01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c06:	eb 21                	jmp    f0105c29 <debuginfo_eip+0x319>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105c08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c0d:	eb 1a                	jmp    f0105c29 <debuginfo_eip+0x319>
f0105c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c14:	eb 13                	jmp    f0105c29 <debuginfo_eip+0x319>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105c16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c1b:	eb 0c                	jmp    f0105c29 <debuginfo_eip+0x319>
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

        stab_binsearch(stabs, &lline , &rline , N_SLINE , addr ) ;
        if ( lline > rline ) return -1 ;      
f0105c1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c22:	eb 05                	jmp    f0105c29 <debuginfo_eip+0x319>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105c24:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c29:	83 c4 5c             	add    $0x5c,%esp
f0105c2c:	5b                   	pop    %ebx
f0105c2d:	5e                   	pop    %esi
f0105c2e:	5f                   	pop    %edi
f0105c2f:	5d                   	pop    %ebp
f0105c30:	c3                   	ret    
f0105c31:	66 90                	xchg   %ax,%ax
f0105c33:	66 90                	xchg   %ax,%ax
f0105c35:	66 90                	xchg   %ax,%ax
f0105c37:	66 90                	xchg   %ax,%ax
f0105c39:	66 90                	xchg   %ax,%ax
f0105c3b:	66 90                	xchg   %ax,%ax
f0105c3d:	66 90                	xchg   %ax,%ax
f0105c3f:	90                   	nop

f0105c40 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105c40:	55                   	push   %ebp
f0105c41:	89 e5                	mov    %esp,%ebp
f0105c43:	57                   	push   %edi
f0105c44:	56                   	push   %esi
f0105c45:	53                   	push   %ebx
f0105c46:	83 ec 3c             	sub    $0x3c,%esp
f0105c49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c4c:	89 d7                	mov    %edx,%edi
f0105c4e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c51:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105c54:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c57:	89 c3                	mov    %eax,%ebx
f0105c59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105c5c:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c5f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105c62:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c67:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105c6a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105c6d:	39 d9                	cmp    %ebx,%ecx
f0105c6f:	72 05                	jb     f0105c76 <printnum+0x36>
f0105c71:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105c74:	77 69                	ja     f0105cdf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105c76:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105c79:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105c7d:	83 ee 01             	sub    $0x1,%esi
f0105c80:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105c84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c88:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105c8c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105c90:	89 c3                	mov    %eax,%ebx
f0105c92:	89 d6                	mov    %edx,%esi
f0105c94:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105c97:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105c9a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105c9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105ca2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ca5:	89 04 24             	mov    %eax,(%esp)
f0105ca8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105cab:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105caf:	e8 4c 17 00 00       	call   f0107400 <__udivdi3>
f0105cb4:	89 d9                	mov    %ebx,%ecx
f0105cb6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105cba:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105cbe:	89 04 24             	mov    %eax,(%esp)
f0105cc1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105cc5:	89 fa                	mov    %edi,%edx
f0105cc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105cca:	e8 71 ff ff ff       	call   f0105c40 <printnum>
f0105ccf:	eb 1b                	jmp    f0105cec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105cd1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cd5:	8b 45 18             	mov    0x18(%ebp),%eax
f0105cd8:	89 04 24             	mov    %eax,(%esp)
f0105cdb:	ff d3                	call   *%ebx
f0105cdd:	eb 03                	jmp    f0105ce2 <printnum+0xa2>
f0105cdf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105ce2:	83 ee 01             	sub    $0x1,%esi
f0105ce5:	85 f6                	test   %esi,%esi
f0105ce7:	7f e8                	jg     f0105cd1 <printnum+0x91>
f0105ce9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105cec:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cf0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105cf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105cf7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105cfa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105cfe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105d02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d05:	89 04 24             	mov    %eax,(%esp)
f0105d08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d0f:	e8 1c 18 00 00       	call   f0107530 <__umoddi3>
f0105d14:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d18:	0f be 80 5e 8e 10 f0 	movsbl -0xfef71a2(%eax),%eax
f0105d1f:	89 04 24             	mov    %eax,(%esp)
f0105d22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d25:	ff d0                	call   *%eax
}
f0105d27:	83 c4 3c             	add    $0x3c,%esp
f0105d2a:	5b                   	pop    %ebx
f0105d2b:	5e                   	pop    %esi
f0105d2c:	5f                   	pop    %edi
f0105d2d:	5d                   	pop    %ebp
f0105d2e:	c3                   	ret    

f0105d2f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105d2f:	55                   	push   %ebp
f0105d30:	89 e5                	mov    %esp,%ebp
f0105d32:	57                   	push   %edi
f0105d33:	56                   	push   %esi
f0105d34:	53                   	push   %ebx
f0105d35:	83 ec 3c             	sub    $0x3c,%esp
f0105d38:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105d3b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105d3e:	89 cf                	mov    %ecx,%edi
f0105d40:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d43:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105d46:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d49:	89 c3                	mov    %eax,%ebx
f0105d4b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105d4e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d51:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105d54:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105d59:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105d5c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105d5f:	39 d9                	cmp    %ebx,%ecx
f0105d61:	72 13                	jb     f0105d76 <cprintnum+0x47>
f0105d63:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105d66:	76 0e                	jbe    f0105d76 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
f0105d68:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105d6b:	0b 45 18             	or     0x18(%ebp),%eax
f0105d6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105d71:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105d74:	eb 6a                	jmp    f0105de0 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
f0105d76:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105d79:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105d7d:	83 ee 01             	sub    $0x1,%esi
f0105d80:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105d84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d88:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d8c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105d90:	89 c3                	mov    %eax,%ebx
f0105d92:	89 d6                	mov    %edx,%esi
f0105d94:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105d97:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105d9a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105d9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105da2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105da5:	89 04 24             	mov    %eax,(%esp)
f0105da8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105dab:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105daf:	e8 4c 16 00 00       	call   f0107400 <__udivdi3>
f0105db4:	89 d9                	mov    %ebx,%ecx
f0105db6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105dba:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105dbe:	89 04 24             	mov    %eax,(%esp)
f0105dc1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105dc5:	89 f9                	mov    %edi,%ecx
f0105dc7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105dca:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105dcd:	e8 5d ff ff ff       	call   f0105d2f <cprintnum>
f0105dd2:	eb 16                	jmp    f0105dea <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
f0105dd4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105dd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ddb:	89 04 24             	mov    %eax,(%esp)
f0105dde:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105de0:	83 ee 01             	sub    $0x1,%esi
f0105de3:	85 f6                	test   %esi,%esi
f0105de5:	7f ed                	jg     f0105dd4 <cprintnum+0xa5>
f0105de7:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
f0105dea:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105dee:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105df2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105df5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105df8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105dfc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105e00:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105e03:	89 04 24             	mov    %eax,(%esp)
f0105e06:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105e09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e0d:	e8 1e 17 00 00       	call   f0107530 <__umoddi3>
f0105e12:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e16:	0f be 80 5e 8e 10 f0 	movsbl -0xfef71a2(%eax),%eax
f0105e1d:	0b 45 dc             	or     -0x24(%ebp),%eax
f0105e20:	89 04 24             	mov    %eax,(%esp)
f0105e23:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105e26:	ff d0                	call   *%eax
}
f0105e28:	83 c4 3c             	add    $0x3c,%esp
f0105e2b:	5b                   	pop    %ebx
f0105e2c:	5e                   	pop    %esi
f0105e2d:	5f                   	pop    %edi
f0105e2e:	5d                   	pop    %ebp
f0105e2f:	c3                   	ret    

f0105e30 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105e30:	55                   	push   %ebp
f0105e31:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105e33:	83 fa 01             	cmp    $0x1,%edx
f0105e36:	7e 0e                	jle    f0105e46 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105e38:	8b 10                	mov    (%eax),%edx
f0105e3a:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105e3d:	89 08                	mov    %ecx,(%eax)
f0105e3f:	8b 02                	mov    (%edx),%eax
f0105e41:	8b 52 04             	mov    0x4(%edx),%edx
f0105e44:	eb 22                	jmp    f0105e68 <getuint+0x38>
	else if (lflag)
f0105e46:	85 d2                	test   %edx,%edx
f0105e48:	74 10                	je     f0105e5a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105e4a:	8b 10                	mov    (%eax),%edx
f0105e4c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105e4f:	89 08                	mov    %ecx,(%eax)
f0105e51:	8b 02                	mov    (%edx),%eax
f0105e53:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e58:	eb 0e                	jmp    f0105e68 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105e5a:	8b 10                	mov    (%eax),%edx
f0105e5c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105e5f:	89 08                	mov    %ecx,(%eax)
f0105e61:	8b 02                	mov    (%edx),%eax
f0105e63:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105e68:	5d                   	pop    %ebp
f0105e69:	c3                   	ret    

f0105e6a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105e6a:	55                   	push   %ebp
f0105e6b:	89 e5                	mov    %esp,%ebp
f0105e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105e70:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105e74:	8b 10                	mov    (%eax),%edx
f0105e76:	3b 50 04             	cmp    0x4(%eax),%edx
f0105e79:	73 0a                	jae    f0105e85 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105e7b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105e7e:	89 08                	mov    %ecx,(%eax)
f0105e80:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e83:	88 02                	mov    %al,(%edx)
}
f0105e85:	5d                   	pop    %ebp
f0105e86:	c3                   	ret    

f0105e87 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105e87:	55                   	push   %ebp
f0105e88:	89 e5                	mov    %esp,%ebp
f0105e8a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105e8d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105e90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e94:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ea2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ea5:	89 04 24             	mov    %eax,(%esp)
f0105ea8:	e8 02 00 00 00       	call   f0105eaf <vprintfmt>
	va_end(ap);
}
f0105ead:	c9                   	leave  
f0105eae:	c3                   	ret    

f0105eaf <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105eaf:	55                   	push   %ebp
f0105eb0:	89 e5                	mov    %esp,%ebp
f0105eb2:	57                   	push   %edi
f0105eb3:	56                   	push   %esi
f0105eb4:	53                   	push   %ebx
f0105eb5:	83 ec 3c             	sub    $0x3c,%esp
f0105eb8:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105ebb:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105ebe:	eb 14                	jmp    f0105ed4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105ec0:	85 c0                	test   %eax,%eax
f0105ec2:	0f 84 b3 03 00 00    	je     f010627b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
f0105ec8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ecc:	89 04 24             	mov    %eax,(%esp)
f0105ecf:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105ed2:	89 f3                	mov    %esi,%ebx
f0105ed4:	8d 73 01             	lea    0x1(%ebx),%esi
f0105ed7:	0f b6 03             	movzbl (%ebx),%eax
f0105eda:	83 f8 25             	cmp    $0x25,%eax
f0105edd:	75 e1                	jne    f0105ec0 <vprintfmt+0x11>
f0105edf:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105ee3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105eea:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105ef1:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105ef8:	ba 00 00 00 00       	mov    $0x0,%edx
f0105efd:	eb 1d                	jmp    f0105f1c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105eff:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105f01:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105f05:	eb 15                	jmp    f0105f1c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f07:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105f09:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105f0d:	eb 0d                	jmp    f0105f1c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105f0f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105f12:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105f15:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f1c:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105f1f:	0f b6 0e             	movzbl (%esi),%ecx
f0105f22:	0f b6 c1             	movzbl %cl,%eax
f0105f25:	83 e9 23             	sub    $0x23,%ecx
f0105f28:	80 f9 55             	cmp    $0x55,%cl
f0105f2b:	0f 87 2a 03 00 00    	ja     f010625b <vprintfmt+0x3ac>
f0105f31:	0f b6 c9             	movzbl %cl,%ecx
f0105f34:	ff 24 8d 20 8f 10 f0 	jmp    *-0xfef70e0(,%ecx,4)
f0105f3b:	89 de                	mov    %ebx,%esi
f0105f3d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105f42:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105f45:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0105f49:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105f4c:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105f4f:	83 fb 09             	cmp    $0x9,%ebx
f0105f52:	77 36                	ja     f0105f8a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105f54:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105f57:	eb e9                	jmp    f0105f42 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105f59:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f5c:	8d 48 04             	lea    0x4(%eax),%ecx
f0105f5f:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105f62:	8b 00                	mov    (%eax),%eax
f0105f64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f67:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105f69:	eb 22                	jmp    f0105f8d <vprintfmt+0xde>
f0105f6b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105f6e:	85 c9                	test   %ecx,%ecx
f0105f70:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f75:	0f 49 c1             	cmovns %ecx,%eax
f0105f78:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f7b:	89 de                	mov    %ebx,%esi
f0105f7d:	eb 9d                	jmp    f0105f1c <vprintfmt+0x6d>
f0105f7f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105f81:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105f88:	eb 92                	jmp    f0105f1c <vprintfmt+0x6d>
f0105f8a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f0105f8d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105f91:	79 89                	jns    f0105f1c <vprintfmt+0x6d>
f0105f93:	e9 77 ff ff ff       	jmp    f0105f0f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105f98:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f9b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105f9d:	e9 7a ff ff ff       	jmp    f0105f1c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105fa2:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fa5:	8d 50 04             	lea    0x4(%eax),%edx
f0105fa8:	89 55 14             	mov    %edx,0x14(%ebp)
f0105fab:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105faf:	8b 00                	mov    (%eax),%eax
f0105fb1:	89 04 24             	mov    %eax,(%esp)
f0105fb4:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105fb7:	e9 18 ff ff ff       	jmp    f0105ed4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105fbc:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fbf:	8d 50 04             	lea    0x4(%eax),%edx
f0105fc2:	89 55 14             	mov    %edx,0x14(%ebp)
f0105fc5:	8b 00                	mov    (%eax),%eax
f0105fc7:	99                   	cltd   
f0105fc8:	31 d0                	xor    %edx,%eax
f0105fca:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105fcc:	83 f8 09             	cmp    $0x9,%eax
f0105fcf:	7f 0b                	jg     f0105fdc <vprintfmt+0x12d>
f0105fd1:	8b 14 85 e0 91 10 f0 	mov    -0xfef6e20(,%eax,4),%edx
f0105fd8:	85 d2                	test   %edx,%edx
f0105fda:	75 20                	jne    f0105ffc <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f0105fdc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105fe0:	c7 44 24 08 76 8e 10 	movl   $0xf0108e76,0x8(%esp)
f0105fe7:	f0 
f0105fe8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105fec:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fef:	89 04 24             	mov    %eax,(%esp)
f0105ff2:	e8 90 fe ff ff       	call   f0105e87 <printfmt>
f0105ff7:	e9 d8 fe ff ff       	jmp    f0105ed4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0105ffc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106000:	c7 44 24 08 41 86 10 	movl   $0xf0108641,0x8(%esp)
f0106007:	f0 
f0106008:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010600c:	8b 45 08             	mov    0x8(%ebp),%eax
f010600f:	89 04 24             	mov    %eax,(%esp)
f0106012:	e8 70 fe ff ff       	call   f0105e87 <printfmt>
f0106017:	e9 b8 fe ff ff       	jmp    f0105ed4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010601c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010601f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106022:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0106025:	8b 45 14             	mov    0x14(%ebp),%eax
f0106028:	8d 50 04             	lea    0x4(%eax),%edx
f010602b:	89 55 14             	mov    %edx,0x14(%ebp)
f010602e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0106030:	85 f6                	test   %esi,%esi
f0106032:	b8 6f 8e 10 f0       	mov    $0xf0108e6f,%eax
f0106037:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f010603a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010603e:	0f 84 97 00 00 00    	je     f01060db <vprintfmt+0x22c>
f0106044:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0106048:	0f 8e 9b 00 00 00    	jle    f01060e9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f010604e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106052:	89 34 24             	mov    %esi,(%esp)
f0106055:	e8 9e 07 00 00       	call   f01067f8 <strnlen>
f010605a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010605d:	29 c2                	sub    %eax,%edx
f010605f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f0106062:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0106066:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106069:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010606c:	8b 75 08             	mov    0x8(%ebp),%esi
f010606f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106072:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106074:	eb 0f                	jmp    f0106085 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0106076:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010607a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010607d:	89 04 24             	mov    %eax,(%esp)
f0106080:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106082:	83 eb 01             	sub    $0x1,%ebx
f0106085:	85 db                	test   %ebx,%ebx
f0106087:	7f ed                	jg     f0106076 <vprintfmt+0x1c7>
f0106089:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010608c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010608f:	85 d2                	test   %edx,%edx
f0106091:	b8 00 00 00 00       	mov    $0x0,%eax
f0106096:	0f 49 c2             	cmovns %edx,%eax
f0106099:	29 c2                	sub    %eax,%edx
f010609b:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010609e:	89 d7                	mov    %edx,%edi
f01060a0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01060a3:	eb 50                	jmp    f01060f5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01060a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01060a9:	74 1e                	je     f01060c9 <vprintfmt+0x21a>
f01060ab:	0f be d2             	movsbl %dl,%edx
f01060ae:	83 ea 20             	sub    $0x20,%edx
f01060b1:	83 fa 5e             	cmp    $0x5e,%edx
f01060b4:	76 13                	jbe    f01060c9 <vprintfmt+0x21a>
					putch('?', putdat);
f01060b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01060b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060bd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01060c4:	ff 55 08             	call   *0x8(%ebp)
f01060c7:	eb 0d                	jmp    f01060d6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f01060c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01060cc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01060d0:	89 04 24             	mov    %eax,(%esp)
f01060d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01060d6:	83 ef 01             	sub    $0x1,%edi
f01060d9:	eb 1a                	jmp    f01060f5 <vprintfmt+0x246>
f01060db:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01060de:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01060e1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01060e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01060e7:	eb 0c                	jmp    f01060f5 <vprintfmt+0x246>
f01060e9:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01060ec:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01060ef:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01060f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01060f5:	83 c6 01             	add    $0x1,%esi
f01060f8:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f01060fc:	0f be c2             	movsbl %dl,%eax
f01060ff:	85 c0                	test   %eax,%eax
f0106101:	74 27                	je     f010612a <vprintfmt+0x27b>
f0106103:	85 db                	test   %ebx,%ebx
f0106105:	78 9e                	js     f01060a5 <vprintfmt+0x1f6>
f0106107:	83 eb 01             	sub    $0x1,%ebx
f010610a:	79 99                	jns    f01060a5 <vprintfmt+0x1f6>
f010610c:	89 f8                	mov    %edi,%eax
f010610e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106111:	8b 75 08             	mov    0x8(%ebp),%esi
f0106114:	89 c3                	mov    %eax,%ebx
f0106116:	eb 1a                	jmp    f0106132 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0106118:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010611c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106123:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106125:	83 eb 01             	sub    $0x1,%ebx
f0106128:	eb 08                	jmp    f0106132 <vprintfmt+0x283>
f010612a:	89 fb                	mov    %edi,%ebx
f010612c:	8b 75 08             	mov    0x8(%ebp),%esi
f010612f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106132:	85 db                	test   %ebx,%ebx
f0106134:	7f e2                	jg     f0106118 <vprintfmt+0x269>
f0106136:	89 75 08             	mov    %esi,0x8(%ebp)
f0106139:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010613c:	e9 93 fd ff ff       	jmp    f0105ed4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0106141:	83 fa 01             	cmp    $0x1,%edx
f0106144:	7e 16                	jle    f010615c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f0106146:	8b 45 14             	mov    0x14(%ebp),%eax
f0106149:	8d 50 08             	lea    0x8(%eax),%edx
f010614c:	89 55 14             	mov    %edx,0x14(%ebp)
f010614f:	8b 50 04             	mov    0x4(%eax),%edx
f0106152:	8b 00                	mov    (%eax),%eax
f0106154:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0106157:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010615a:	eb 32                	jmp    f010618e <vprintfmt+0x2df>
	else if (lflag)
f010615c:	85 d2                	test   %edx,%edx
f010615e:	74 18                	je     f0106178 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f0106160:	8b 45 14             	mov    0x14(%ebp),%eax
f0106163:	8d 50 04             	lea    0x4(%eax),%edx
f0106166:	89 55 14             	mov    %edx,0x14(%ebp)
f0106169:	8b 30                	mov    (%eax),%esi
f010616b:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010616e:	89 f0                	mov    %esi,%eax
f0106170:	c1 f8 1f             	sar    $0x1f,%eax
f0106173:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106176:	eb 16                	jmp    f010618e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
f0106178:	8b 45 14             	mov    0x14(%ebp),%eax
f010617b:	8d 50 04             	lea    0x4(%eax),%edx
f010617e:	89 55 14             	mov    %edx,0x14(%ebp)
f0106181:	8b 30                	mov    (%eax),%esi
f0106183:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0106186:	89 f0                	mov    %esi,%eax
f0106188:	c1 f8 1f             	sar    $0x1f,%eax
f010618b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010618e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106191:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0106194:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0106199:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010619d:	0f 89 80 00 00 00    	jns    f0106223 <vprintfmt+0x374>
				putch('-', putdat);
f01061a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01061a7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01061ae:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01061b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01061b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01061b7:	f7 d8                	neg    %eax
f01061b9:	83 d2 00             	adc    $0x0,%edx
f01061bc:	f7 da                	neg    %edx
			}
			base = 10;
f01061be:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01061c3:	eb 5e                	jmp    f0106223 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01061c5:	8d 45 14             	lea    0x14(%ebp),%eax
f01061c8:	e8 63 fc ff ff       	call   f0105e30 <getuint>
			base = 10;
f01061cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01061d2:	eb 4f                	jmp    f0106223 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01061d4:	8d 45 14             	lea    0x14(%ebp),%eax
f01061d7:	e8 54 fc ff ff       	call   f0105e30 <getuint>
			base = 8 ;
f01061dc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
f01061e1:	eb 40                	jmp    f0106223 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
f01061e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01061e7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01061ee:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01061f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01061f5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01061fc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01061ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0106202:	8d 50 04             	lea    0x4(%eax),%edx
f0106205:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0106208:	8b 00                	mov    (%eax),%eax
f010620a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010620f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0106214:	eb 0d                	jmp    f0106223 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0106216:	8d 45 14             	lea    0x14(%ebp),%eax
f0106219:	e8 12 fc ff ff       	call   f0105e30 <getuint>
			base = 16;
f010621e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106223:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0106227:	89 74 24 10          	mov    %esi,0x10(%esp)
f010622b:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010622e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106232:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106236:	89 04 24             	mov    %eax,(%esp)
f0106239:	89 54 24 04          	mov    %edx,0x4(%esp)
f010623d:	89 fa                	mov    %edi,%edx
f010623f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106242:	e8 f9 f9 ff ff       	call   f0105c40 <printnum>
			break;
f0106247:	e9 88 fc ff ff       	jmp    f0105ed4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010624c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106250:	89 04 24             	mov    %eax,(%esp)
f0106253:	ff 55 08             	call   *0x8(%ebp)
			break;
f0106256:	e9 79 fc ff ff       	jmp    f0105ed4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010625b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010625f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0106266:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0106269:	89 f3                	mov    %esi,%ebx
f010626b:	eb 03                	jmp    f0106270 <vprintfmt+0x3c1>
f010626d:	83 eb 01             	sub    $0x1,%ebx
f0106270:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0106274:	75 f7                	jne    f010626d <vprintfmt+0x3be>
f0106276:	e9 59 fc ff ff       	jmp    f0105ed4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f010627b:	83 c4 3c             	add    $0x3c,%esp
f010627e:	5b                   	pop    %ebx
f010627f:	5e                   	pop    %esi
f0106280:	5f                   	pop    %edi
f0106281:	5d                   	pop    %ebp
f0106282:	c3                   	ret    

f0106283 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0106283:	55                   	push   %ebp
f0106284:	89 e5                	mov    %esp,%ebp
f0106286:	57                   	push   %edi
f0106287:	56                   	push   %esi
f0106288:	53                   	push   %ebx
f0106289:	83 ec 3c             	sub    $0x3c,%esp
f010628c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
f010628f:	8b 45 14             	mov    0x14(%ebp),%eax
f0106292:	8d 50 04             	lea    0x4(%eax),%edx
f0106295:	89 55 14             	mov    %edx,0x14(%ebp)
f0106298:	8b 00                	mov    (%eax),%eax
f010629a:	c1 e0 08             	shl    $0x8,%eax
f010629d:	0f b7 c0             	movzwl %ax,%eax
f01062a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
f01062a3:	83 c8 25             	or     $0x25,%eax
f01062a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01062a9:	eb 1a                	jmp    f01062c5 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01062ab:	85 c0                	test   %eax,%eax
f01062ad:	0f 84 a9 03 00 00    	je     f010665c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
f01062b3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01062ba:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01062bd:	89 04 24             	mov    %eax,(%esp)
f01062c0:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01062c3:	89 fb                	mov    %edi,%ebx
f01062c5:	8d 7b 01             	lea    0x1(%ebx),%edi
f01062c8:	0f b6 03             	movzbl (%ebx),%eax
f01062cb:	83 f8 25             	cmp    $0x25,%eax
f01062ce:	75 db                	jne    f01062ab <cvprintfmt+0x28>
f01062d0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01062d4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01062db:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01062e0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f01062e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01062ec:	eb 18                	jmp    f0106306 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01062ee:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01062f0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01062f4:	eb 10                	jmp    f0106306 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01062f6:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01062f8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01062fc:	eb 08                	jmp    f0106306 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01062fe:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0106301:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106306:	8d 5f 01             	lea    0x1(%edi),%ebx
f0106309:	0f b6 0f             	movzbl (%edi),%ecx
f010630c:	0f b6 c1             	movzbl %cl,%eax
f010630f:	83 e9 23             	sub    $0x23,%ecx
f0106312:	80 f9 55             	cmp    $0x55,%cl
f0106315:	0f 87 1f 03 00 00    	ja     f010663a <cvprintfmt+0x3b7>
f010631b:	0f b6 c9             	movzbl %cl,%ecx
f010631e:	ff 24 8d 78 90 10 f0 	jmp    *-0xfef6f88(,%ecx,4)
f0106325:	89 df                	mov    %ebx,%edi
f0106327:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010632c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
f010632f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
f0106333:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0106336:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0106339:	83 f9 09             	cmp    $0x9,%ecx
f010633c:	77 33                	ja     f0106371 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010633e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0106341:	eb e9                	jmp    f010632c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0106343:	8b 45 14             	mov    0x14(%ebp),%eax
f0106346:	8d 48 04             	lea    0x4(%eax),%ecx
f0106349:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010634c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010634e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0106350:	eb 1f                	jmp    f0106371 <cvprintfmt+0xee>
f0106352:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0106355:	85 ff                	test   %edi,%edi
f0106357:	b8 00 00 00 00       	mov    $0x0,%eax
f010635c:	0f 49 c7             	cmovns %edi,%eax
f010635f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106362:	89 df                	mov    %ebx,%edi
f0106364:	eb a0                	jmp    f0106306 <cvprintfmt+0x83>
f0106366:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0106368:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f010636f:	eb 95                	jmp    f0106306 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
f0106371:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0106375:	79 8f                	jns    f0106306 <cvprintfmt+0x83>
f0106377:	eb 85                	jmp    f01062fe <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0106379:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010637c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010637e:	66 90                	xchg   %ax,%ax
f0106380:	eb 84                	jmp    f0106306 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
f0106382:	8b 45 14             	mov    0x14(%ebp),%eax
f0106385:	8d 50 04             	lea    0x4(%eax),%edx
f0106388:	89 55 14             	mov    %edx,0x14(%ebp)
f010638b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010638e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106392:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106395:	0b 10                	or     (%eax),%edx
f0106397:	89 14 24             	mov    %edx,(%esp)
f010639a:	ff 55 08             	call   *0x8(%ebp)
			break;
f010639d:	e9 23 ff ff ff       	jmp    f01062c5 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01063a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01063a5:	8d 50 04             	lea    0x4(%eax),%edx
f01063a8:	89 55 14             	mov    %edx,0x14(%ebp)
f01063ab:	8b 00                	mov    (%eax),%eax
f01063ad:	99                   	cltd   
f01063ae:	31 d0                	xor    %edx,%eax
f01063b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01063b2:	83 f8 09             	cmp    $0x9,%eax
f01063b5:	7f 0b                	jg     f01063c2 <cvprintfmt+0x13f>
f01063b7:	8b 14 85 e0 91 10 f0 	mov    -0xfef6e20(,%eax,4),%edx
f01063be:	85 d2                	test   %edx,%edx
f01063c0:	75 23                	jne    f01063e5 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
f01063c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01063c6:	c7 44 24 08 76 8e 10 	movl   $0xf0108e76,0x8(%esp)
f01063cd:	f0 
f01063ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01063d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01063d8:	89 04 24             	mov    %eax,(%esp)
f01063db:	e8 a7 fa ff ff       	call   f0105e87 <printfmt>
f01063e0:	e9 e0 fe ff ff       	jmp    f01062c5 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
f01063e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01063e9:	c7 44 24 08 41 86 10 	movl   $0xf0108641,0x8(%esp)
f01063f0:	f0 
f01063f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01063f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01063fb:	89 04 24             	mov    %eax,(%esp)
f01063fe:	e8 84 fa ff ff       	call   f0105e87 <printfmt>
f0106403:	e9 bd fe ff ff       	jmp    f01062c5 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106408:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010640b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
f010640e:	8b 45 14             	mov    0x14(%ebp),%eax
f0106411:	8d 48 04             	lea    0x4(%eax),%ecx
f0106414:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0106417:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0106419:	85 ff                	test   %edi,%edi
f010641b:	b8 6f 8e 10 f0       	mov    $0xf0108e6f,%eax
f0106420:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0106423:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0106427:	74 61                	je     f010648a <cvprintfmt+0x207>
f0106429:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010642d:	7e 5b                	jle    f010648a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
f010642f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106433:	89 3c 24             	mov    %edi,(%esp)
f0106436:	e8 bd 03 00 00       	call   f01067f8 <strnlen>
f010643b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010643e:	29 c2                	sub    %eax,%edx
f0106440:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
f0106443:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0106447:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010644a:	89 7d d8             	mov    %edi,-0x28(%ebp)
f010644d:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0106450:	8b 75 08             	mov    0x8(%ebp),%esi
f0106453:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106456:	89 d3                	mov    %edx,%ebx
f0106458:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010645a:	eb 0f                	jmp    f010646b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
f010645c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010645f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106463:	89 3c 24             	mov    %edi,(%esp)
f0106466:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106468:	83 eb 01             	sub    $0x1,%ebx
f010646b:	85 db                	test   %ebx,%ebx
f010646d:	7f ed                	jg     f010645c <cvprintfmt+0x1d9>
f010646f:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106472:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0106475:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0106478:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010647b:	85 d2                	test   %edx,%edx
f010647d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106482:	0f 49 c2             	cmovns %edx,%eax
f0106485:	29 c2                	sub    %eax,%edx
f0106487:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
f010648a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010648d:	83 c8 3f             	or     $0x3f,%eax
f0106490:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0106493:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106496:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0106499:	eb 36                	jmp    f01064d1 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010649b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010649f:	74 1d                	je     f01064be <cvprintfmt+0x23b>
f01064a1:	0f be d2             	movsbl %dl,%edx
f01064a4:	83 ea 20             	sub    $0x20,%edx
f01064a7:	83 fa 5e             	cmp    $0x5e,%edx
f01064aa:	76 12                	jbe    f01064be <cvprintfmt+0x23b>
					putch(color | '?', putdat);
f01064ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01064af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01064b6:	89 04 24             	mov    %eax,(%esp)
f01064b9:	ff 55 08             	call   *0x8(%ebp)
f01064bc:	eb 10                	jmp    f01064ce <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
f01064be:	8b 55 0c             	mov    0xc(%ebp),%edx
f01064c1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01064c5:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01064c8:	89 04 24             	mov    %eax,(%esp)
f01064cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01064ce:	83 eb 01             	sub    $0x1,%ebx
f01064d1:	83 c7 01             	add    $0x1,%edi
f01064d4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01064d8:	0f be c2             	movsbl %dl,%eax
f01064db:	85 c0                	test   %eax,%eax
f01064dd:	74 27                	je     f0106506 <cvprintfmt+0x283>
f01064df:	85 f6                	test   %esi,%esi
f01064e1:	78 b8                	js     f010649b <cvprintfmt+0x218>
f01064e3:	83 ee 01             	sub    $0x1,%esi
f01064e6:	79 b3                	jns    f010649b <cvprintfmt+0x218>
f01064e8:	89 d8                	mov    %ebx,%eax
f01064ea:	8b 75 08             	mov    0x8(%ebp),%esi
f01064ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01064f0:	89 c3                	mov    %eax,%ebx
f01064f2:	eb 18                	jmp    f010650c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
f01064f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01064f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01064ff:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
f0106501:	83 eb 01             	sub    $0x1,%ebx
f0106504:	eb 06                	jmp    f010650c <cvprintfmt+0x289>
f0106506:	8b 75 08             	mov    0x8(%ebp),%esi
f0106509:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010650c:	85 db                	test   %ebx,%ebx
f010650e:	7f e4                	jg     f01064f4 <cvprintfmt+0x271>
f0106510:	89 75 08             	mov    %esi,0x8(%ebp)
f0106513:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0106516:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0106519:	e9 a7 fd ff ff       	jmp    f01062c5 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010651e:	83 fa 01             	cmp    $0x1,%edx
f0106521:	7e 10                	jle    f0106533 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
f0106523:	8b 45 14             	mov    0x14(%ebp),%eax
f0106526:	8d 50 08             	lea    0x8(%eax),%edx
f0106529:	89 55 14             	mov    %edx,0x14(%ebp)
f010652c:	8b 30                	mov    (%eax),%esi
f010652e:	8b 78 04             	mov    0x4(%eax),%edi
f0106531:	eb 26                	jmp    f0106559 <cvprintfmt+0x2d6>
	else if (lflag)
f0106533:	85 d2                	test   %edx,%edx
f0106535:	74 12                	je     f0106549 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
f0106537:	8b 45 14             	mov    0x14(%ebp),%eax
f010653a:	8d 50 04             	lea    0x4(%eax),%edx
f010653d:	89 55 14             	mov    %edx,0x14(%ebp)
f0106540:	8b 30                	mov    (%eax),%esi
f0106542:	89 f7                	mov    %esi,%edi
f0106544:	c1 ff 1f             	sar    $0x1f,%edi
f0106547:	eb 10                	jmp    f0106559 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
f0106549:	8b 45 14             	mov    0x14(%ebp),%eax
f010654c:	8d 50 04             	lea    0x4(%eax),%edx
f010654f:	89 55 14             	mov    %edx,0x14(%ebp)
f0106552:	8b 30                	mov    (%eax),%esi
f0106554:	89 f7                	mov    %esi,%edi
f0106556:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0106559:	89 f0                	mov    %esi,%eax
f010655b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010655d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0106562:	85 ff                	test   %edi,%edi
f0106564:	0f 89 8e 00 00 00    	jns    f01065f8 <cvprintfmt+0x375>
				putch(color | '-', putdat);
f010656a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010656d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106571:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106574:	83 c8 2d             	or     $0x2d,%eax
f0106577:	89 04 24             	mov    %eax,(%esp)
f010657a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010657d:	89 f0                	mov    %esi,%eax
f010657f:	89 fa                	mov    %edi,%edx
f0106581:	f7 d8                	neg    %eax
f0106583:	83 d2 00             	adc    $0x0,%edx
f0106586:	f7 da                	neg    %edx
			}
			base = 10;
f0106588:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010658d:	eb 69                	jmp    f01065f8 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010658f:	8d 45 14             	lea    0x14(%ebp),%eax
f0106592:	e8 99 f8 ff ff       	call   f0105e30 <getuint>
			base = 10;
f0106597:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010659c:	eb 5a                	jmp    f01065f8 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f010659e:	8d 45 14             	lea    0x14(%ebp),%eax
f01065a1:	e8 8a f8 ff ff       	call   f0105e30 <getuint>
			base = 8 ;
f01065a6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
f01065ab:	eb 4b                	jmp    f01065f8 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
f01065ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01065b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065b4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01065b7:	89 f0                	mov    %esi,%eax
f01065b9:	83 c8 30             	or     $0x30,%eax
f01065bc:	89 04 24             	mov    %eax,(%esp)
f01065bf:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
f01065c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01065c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065c9:	89 f0                	mov    %esi,%eax
f01065cb:	83 c8 78             	or     $0x78,%eax
f01065ce:	89 04 24             	mov    %eax,(%esp)
f01065d1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01065d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01065d7:	8d 50 04             	lea    0x4(%eax),%edx
f01065da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
f01065dd:	8b 00                	mov    (%eax),%eax
f01065df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01065e4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01065e9:	eb 0d                	jmp    f01065f8 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01065eb:	8d 45 14             	lea    0x14(%ebp),%eax
f01065ee:	e8 3d f8 ff ff       	call   f0105e30 <getuint>
			base = 16;
f01065f3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
f01065f8:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f01065fc:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106600:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0106603:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106607:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010660b:	89 04 24             	mov    %eax,(%esp)
f010660e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106615:	8b 55 08             	mov    0x8(%ebp),%edx
f0106618:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010661b:	e8 0f f7 ff ff       	call   f0105d2f <cprintnum>
			break;
f0106620:	e9 a0 fc ff ff       	jmp    f01062c5 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
f0106625:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106628:	89 54 24 04          	mov    %edx,0x4(%esp)
f010662c:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010662f:	89 04 24             	mov    %eax,(%esp)
f0106632:	ff 55 08             	call   *0x8(%ebp)
			break;
f0106635:	e9 8b fc ff ff       	jmp    f01062c5 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
f010663a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010663d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106641:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106644:	89 04 24             	mov    %eax,(%esp)
f0106647:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010664a:	89 fb                	mov    %edi,%ebx
f010664c:	eb 03                	jmp    f0106651 <cvprintfmt+0x3ce>
f010664e:	83 eb 01             	sub    $0x1,%ebx
f0106651:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0106655:	75 f7                	jne    f010664e <cvprintfmt+0x3cb>
f0106657:	e9 69 fc ff ff       	jmp    f01062c5 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
f010665c:	83 c4 3c             	add    $0x3c,%esp
f010665f:	5b                   	pop    %ebx
f0106660:	5e                   	pop    %esi
f0106661:	5f                   	pop    %edi
f0106662:	5d                   	pop    %ebp
f0106663:	c3                   	ret    

f0106664 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0106664:	55                   	push   %ebp
f0106665:	89 e5                	mov    %esp,%ebp
f0106667:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010666a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
f010666d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106671:	8b 45 10             	mov    0x10(%ebp),%eax
f0106674:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106678:	8b 45 0c             	mov    0xc(%ebp),%eax
f010667b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010667f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106682:	89 04 24             	mov    %eax,(%esp)
f0106685:	e8 f9 fb ff ff       	call   f0106283 <cvprintfmt>
	va_end(ap);
}
f010668a:	c9                   	leave  
f010668b:	c3                   	ret    

f010668c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010668c:	55                   	push   %ebp
f010668d:	89 e5                	mov    %esp,%ebp
f010668f:	83 ec 28             	sub    $0x28,%esp
f0106692:	8b 45 08             	mov    0x8(%ebp),%eax
f0106695:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0106698:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010669b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010669f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01066a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01066a9:	85 c0                	test   %eax,%eax
f01066ab:	74 30                	je     f01066dd <vsnprintf+0x51>
f01066ad:	85 d2                	test   %edx,%edx
f01066af:	7e 2c                	jle    f01066dd <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01066b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01066b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01066b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01066bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01066bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01066c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066c6:	c7 04 24 6a 5e 10 f0 	movl   $0xf0105e6a,(%esp)
f01066cd:	e8 dd f7 ff ff       	call   f0105eaf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01066d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01066d5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01066d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01066db:	eb 05                	jmp    f01066e2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01066dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01066e2:	c9                   	leave  
f01066e3:	c3                   	ret    

f01066e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01066e4:	55                   	push   %ebp
f01066e5:	89 e5                	mov    %esp,%ebp
f01066e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01066ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01066ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01066f1:	8b 45 10             	mov    0x10(%ebp),%eax
f01066f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01066f8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01066fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0106702:	89 04 24             	mov    %eax,(%esp)
f0106705:	e8 82 ff ff ff       	call   f010668c <vsnprintf>
	va_end(ap);

	return rc;
}
f010670a:	c9                   	leave  
f010670b:	c3                   	ret    
f010670c:	66 90                	xchg   %ax,%ax
f010670e:	66 90                	xchg   %ax,%ax

f0106710 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106710:	55                   	push   %ebp
f0106711:	89 e5                	mov    %esp,%ebp
f0106713:	57                   	push   %edi
f0106714:	56                   	push   %esi
f0106715:	53                   	push   %ebx
f0106716:	83 ec 1c             	sub    $0x1c,%esp
f0106719:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010671c:	85 c0                	test   %eax,%eax
f010671e:	74 10                	je     f0106730 <readline+0x20>
		cprintf("%s", prompt);
f0106720:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106724:	c7 04 24 41 86 10 f0 	movl   $0xf0108641,(%esp)
f010672b:	e8 4c d9 ff ff       	call   f010407c <cprintf>

	i = 0;
	echoing = iscons(0);
f0106730:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106737:	e8 6f a0 ff ff       	call   f01007ab <iscons>
f010673c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010673e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0106743:	e8 52 a0 ff ff       	call   f010079a <getchar>
f0106748:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010674a:	85 c0                	test   %eax,%eax
f010674c:	79 17                	jns    f0106765 <readline+0x55>
			cprintf("read error: %e\n", c);
f010674e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106752:	c7 04 24 08 92 10 f0 	movl   $0xf0109208,(%esp)
f0106759:	e8 1e d9 ff ff       	call   f010407c <cprintf>
			return NULL;
f010675e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106763:	eb 6d                	jmp    f01067d2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106765:	83 f8 7f             	cmp    $0x7f,%eax
f0106768:	74 05                	je     f010676f <readline+0x5f>
f010676a:	83 f8 08             	cmp    $0x8,%eax
f010676d:	75 19                	jne    f0106788 <readline+0x78>
f010676f:	85 f6                	test   %esi,%esi
f0106771:	7e 15                	jle    f0106788 <readline+0x78>
			if (echoing)
f0106773:	85 ff                	test   %edi,%edi
f0106775:	74 0c                	je     f0106783 <readline+0x73>
				cputchar('\b');
f0106777:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010677e:	e8 07 a0 ff ff       	call   f010078a <cputchar>
			i--;
f0106783:	83 ee 01             	sub    $0x1,%esi
f0106786:	eb bb                	jmp    f0106743 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0106788:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010678e:	7f 1c                	jg     f01067ac <readline+0x9c>
f0106790:	83 fb 1f             	cmp    $0x1f,%ebx
f0106793:	7e 17                	jle    f01067ac <readline+0x9c>
			if (echoing)
f0106795:	85 ff                	test   %edi,%edi
f0106797:	74 08                	je     f01067a1 <readline+0x91>
				cputchar(c);
f0106799:	89 1c 24             	mov    %ebx,(%esp)
f010679c:	e8 e9 9f ff ff       	call   f010078a <cputchar>
			buf[i++] = c;
f01067a1:	88 9e 80 fa 23 f0    	mov    %bl,-0xfdc0580(%esi)
f01067a7:	8d 76 01             	lea    0x1(%esi),%esi
f01067aa:	eb 97                	jmp    f0106743 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01067ac:	83 fb 0d             	cmp    $0xd,%ebx
f01067af:	74 05                	je     f01067b6 <readline+0xa6>
f01067b1:	83 fb 0a             	cmp    $0xa,%ebx
f01067b4:	75 8d                	jne    f0106743 <readline+0x33>
			if (echoing)
f01067b6:	85 ff                	test   %edi,%edi
f01067b8:	74 0c                	je     f01067c6 <readline+0xb6>
				cputchar('\n');
f01067ba:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01067c1:	e8 c4 9f ff ff       	call   f010078a <cputchar>
			buf[i] = 0;
f01067c6:	c6 86 80 fa 23 f0 00 	movb   $0x0,-0xfdc0580(%esi)
			return buf;
f01067cd:	b8 80 fa 23 f0       	mov    $0xf023fa80,%eax
		}
	}
}
f01067d2:	83 c4 1c             	add    $0x1c,%esp
f01067d5:	5b                   	pop    %ebx
f01067d6:	5e                   	pop    %esi
f01067d7:	5f                   	pop    %edi
f01067d8:	5d                   	pop    %ebp
f01067d9:	c3                   	ret    
f01067da:	66 90                	xchg   %ax,%ax
f01067dc:	66 90                	xchg   %ax,%ax
f01067de:	66 90                	xchg   %ax,%ax

f01067e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01067e0:	55                   	push   %ebp
f01067e1:	89 e5                	mov    %esp,%ebp
f01067e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01067e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01067eb:	eb 03                	jmp    f01067f0 <strlen+0x10>
		n++;
f01067ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01067f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01067f4:	75 f7                	jne    f01067ed <strlen+0xd>
		n++;
	return n;
}
f01067f6:	5d                   	pop    %ebp
f01067f7:	c3                   	ret    

f01067f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01067f8:	55                   	push   %ebp
f01067f9:	89 e5                	mov    %esp,%ebp
f01067fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01067fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106801:	b8 00 00 00 00       	mov    $0x0,%eax
f0106806:	eb 03                	jmp    f010680b <strnlen+0x13>
		n++;
f0106808:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010680b:	39 d0                	cmp    %edx,%eax
f010680d:	74 06                	je     f0106815 <strnlen+0x1d>
f010680f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0106813:	75 f3                	jne    f0106808 <strnlen+0x10>
		n++;
	return n;
}
f0106815:	5d                   	pop    %ebp
f0106816:	c3                   	ret    

f0106817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0106817:	55                   	push   %ebp
f0106818:	89 e5                	mov    %esp,%ebp
f010681a:	53                   	push   %ebx
f010681b:	8b 45 08             	mov    0x8(%ebp),%eax
f010681e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106821:	89 c2                	mov    %eax,%edx
f0106823:	83 c2 01             	add    $0x1,%edx
f0106826:	83 c1 01             	add    $0x1,%ecx
f0106829:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010682d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0106830:	84 db                	test   %bl,%bl
f0106832:	75 ef                	jne    f0106823 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0106834:	5b                   	pop    %ebx
f0106835:	5d                   	pop    %ebp
f0106836:	c3                   	ret    

f0106837 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0106837:	55                   	push   %ebp
f0106838:	89 e5                	mov    %esp,%ebp
f010683a:	53                   	push   %ebx
f010683b:	83 ec 08             	sub    $0x8,%esp
f010683e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106841:	89 1c 24             	mov    %ebx,(%esp)
f0106844:	e8 97 ff ff ff       	call   f01067e0 <strlen>
	strcpy(dst + len, src);
f0106849:	8b 55 0c             	mov    0xc(%ebp),%edx
f010684c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106850:	01 d8                	add    %ebx,%eax
f0106852:	89 04 24             	mov    %eax,(%esp)
f0106855:	e8 bd ff ff ff       	call   f0106817 <strcpy>
	return dst;
}
f010685a:	89 d8                	mov    %ebx,%eax
f010685c:	83 c4 08             	add    $0x8,%esp
f010685f:	5b                   	pop    %ebx
f0106860:	5d                   	pop    %ebp
f0106861:	c3                   	ret    

f0106862 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106862:	55                   	push   %ebp
f0106863:	89 e5                	mov    %esp,%ebp
f0106865:	56                   	push   %esi
f0106866:	53                   	push   %ebx
f0106867:	8b 75 08             	mov    0x8(%ebp),%esi
f010686a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010686d:	89 f3                	mov    %esi,%ebx
f010686f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106872:	89 f2                	mov    %esi,%edx
f0106874:	eb 0f                	jmp    f0106885 <strncpy+0x23>
		*dst++ = *src;
f0106876:	83 c2 01             	add    $0x1,%edx
f0106879:	0f b6 01             	movzbl (%ecx),%eax
f010687c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010687f:	80 39 01             	cmpb   $0x1,(%ecx)
f0106882:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106885:	39 da                	cmp    %ebx,%edx
f0106887:	75 ed                	jne    f0106876 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106889:	89 f0                	mov    %esi,%eax
f010688b:	5b                   	pop    %ebx
f010688c:	5e                   	pop    %esi
f010688d:	5d                   	pop    %ebp
f010688e:	c3                   	ret    

f010688f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010688f:	55                   	push   %ebp
f0106890:	89 e5                	mov    %esp,%ebp
f0106892:	56                   	push   %esi
f0106893:	53                   	push   %ebx
f0106894:	8b 75 08             	mov    0x8(%ebp),%esi
f0106897:	8b 55 0c             	mov    0xc(%ebp),%edx
f010689a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010689d:	89 f0                	mov    %esi,%eax
f010689f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01068a3:	85 c9                	test   %ecx,%ecx
f01068a5:	75 0b                	jne    f01068b2 <strlcpy+0x23>
f01068a7:	eb 1d                	jmp    f01068c6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01068a9:	83 c0 01             	add    $0x1,%eax
f01068ac:	83 c2 01             	add    $0x1,%edx
f01068af:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01068b2:	39 d8                	cmp    %ebx,%eax
f01068b4:	74 0b                	je     f01068c1 <strlcpy+0x32>
f01068b6:	0f b6 0a             	movzbl (%edx),%ecx
f01068b9:	84 c9                	test   %cl,%cl
f01068bb:	75 ec                	jne    f01068a9 <strlcpy+0x1a>
f01068bd:	89 c2                	mov    %eax,%edx
f01068bf:	eb 02                	jmp    f01068c3 <strlcpy+0x34>
f01068c1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01068c3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01068c6:	29 f0                	sub    %esi,%eax
}
f01068c8:	5b                   	pop    %ebx
f01068c9:	5e                   	pop    %esi
f01068ca:	5d                   	pop    %ebp
f01068cb:	c3                   	ret    

f01068cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01068cc:	55                   	push   %ebp
f01068cd:	89 e5                	mov    %esp,%ebp
f01068cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01068d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01068d5:	eb 06                	jmp    f01068dd <strcmp+0x11>
		p++, q++;
f01068d7:	83 c1 01             	add    $0x1,%ecx
f01068da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01068dd:	0f b6 01             	movzbl (%ecx),%eax
f01068e0:	84 c0                	test   %al,%al
f01068e2:	74 04                	je     f01068e8 <strcmp+0x1c>
f01068e4:	3a 02                	cmp    (%edx),%al
f01068e6:	74 ef                	je     f01068d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01068e8:	0f b6 c0             	movzbl %al,%eax
f01068eb:	0f b6 12             	movzbl (%edx),%edx
f01068ee:	29 d0                	sub    %edx,%eax
}
f01068f0:	5d                   	pop    %ebp
f01068f1:	c3                   	ret    

f01068f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01068f2:	55                   	push   %ebp
f01068f3:	89 e5                	mov    %esp,%ebp
f01068f5:	53                   	push   %ebx
f01068f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01068f9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01068fc:	89 c3                	mov    %eax,%ebx
f01068fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0106901:	eb 06                	jmp    f0106909 <strncmp+0x17>
		n--, p++, q++;
f0106903:	83 c0 01             	add    $0x1,%eax
f0106906:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106909:	39 d8                	cmp    %ebx,%eax
f010690b:	74 15                	je     f0106922 <strncmp+0x30>
f010690d:	0f b6 08             	movzbl (%eax),%ecx
f0106910:	84 c9                	test   %cl,%cl
f0106912:	74 04                	je     f0106918 <strncmp+0x26>
f0106914:	3a 0a                	cmp    (%edx),%cl
f0106916:	74 eb                	je     f0106903 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106918:	0f b6 00             	movzbl (%eax),%eax
f010691b:	0f b6 12             	movzbl (%edx),%edx
f010691e:	29 d0                	sub    %edx,%eax
f0106920:	eb 05                	jmp    f0106927 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106922:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106927:	5b                   	pop    %ebx
f0106928:	5d                   	pop    %ebp
f0106929:	c3                   	ret    

f010692a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010692a:	55                   	push   %ebp
f010692b:	89 e5                	mov    %esp,%ebp
f010692d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106930:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106934:	eb 07                	jmp    f010693d <strchr+0x13>
		if (*s == c)
f0106936:	38 ca                	cmp    %cl,%dl
f0106938:	74 0f                	je     f0106949 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010693a:	83 c0 01             	add    $0x1,%eax
f010693d:	0f b6 10             	movzbl (%eax),%edx
f0106940:	84 d2                	test   %dl,%dl
f0106942:	75 f2                	jne    f0106936 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0106944:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106949:	5d                   	pop    %ebp
f010694a:	c3                   	ret    

f010694b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010694b:	55                   	push   %ebp
f010694c:	89 e5                	mov    %esp,%ebp
f010694e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106955:	eb 07                	jmp    f010695e <strfind+0x13>
		if (*s == c)
f0106957:	38 ca                	cmp    %cl,%dl
f0106959:	74 0a                	je     f0106965 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010695b:	83 c0 01             	add    $0x1,%eax
f010695e:	0f b6 10             	movzbl (%eax),%edx
f0106961:	84 d2                	test   %dl,%dl
f0106963:	75 f2                	jne    f0106957 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0106965:	5d                   	pop    %ebp
f0106966:	c3                   	ret    

f0106967 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106967:	55                   	push   %ebp
f0106968:	89 e5                	mov    %esp,%ebp
f010696a:	57                   	push   %edi
f010696b:	56                   	push   %esi
f010696c:	53                   	push   %ebx
f010696d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106973:	85 c9                	test   %ecx,%ecx
f0106975:	74 36                	je     f01069ad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106977:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010697d:	75 28                	jne    f01069a7 <memset+0x40>
f010697f:	f6 c1 03             	test   $0x3,%cl
f0106982:	75 23                	jne    f01069a7 <memset+0x40>
		c &= 0xFF;
f0106984:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106988:	89 d3                	mov    %edx,%ebx
f010698a:	c1 e3 08             	shl    $0x8,%ebx
f010698d:	89 d6                	mov    %edx,%esi
f010698f:	c1 e6 18             	shl    $0x18,%esi
f0106992:	89 d0                	mov    %edx,%eax
f0106994:	c1 e0 10             	shl    $0x10,%eax
f0106997:	09 f0                	or     %esi,%eax
f0106999:	09 c2                	or     %eax,%edx
f010699b:	89 d0                	mov    %edx,%eax
f010699d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010699f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01069a2:	fc                   	cld    
f01069a3:	f3 ab                	rep stos %eax,%es:(%edi)
f01069a5:	eb 06                	jmp    f01069ad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01069a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01069aa:	fc                   	cld    
f01069ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01069ad:	89 f8                	mov    %edi,%eax
f01069af:	5b                   	pop    %ebx
f01069b0:	5e                   	pop    %esi
f01069b1:	5f                   	pop    %edi
f01069b2:	5d                   	pop    %ebp
f01069b3:	c3                   	ret    

f01069b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01069b4:	55                   	push   %ebp
f01069b5:	89 e5                	mov    %esp,%ebp
f01069b7:	57                   	push   %edi
f01069b8:	56                   	push   %esi
f01069b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01069bc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01069bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01069c2:	39 c6                	cmp    %eax,%esi
f01069c4:	73 35                	jae    f01069fb <memmove+0x47>
f01069c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01069c9:	39 d0                	cmp    %edx,%eax
f01069cb:	73 2e                	jae    f01069fb <memmove+0x47>
		s += n;
		d += n;
f01069cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01069d0:	89 d6                	mov    %edx,%esi
f01069d2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01069d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01069da:	75 13                	jne    f01069ef <memmove+0x3b>
f01069dc:	f6 c1 03             	test   $0x3,%cl
f01069df:	75 0e                	jne    f01069ef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01069e1:	83 ef 04             	sub    $0x4,%edi
f01069e4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01069e7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01069ea:	fd                   	std    
f01069eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01069ed:	eb 09                	jmp    f01069f8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01069ef:	83 ef 01             	sub    $0x1,%edi
f01069f2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01069f5:	fd                   	std    
f01069f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01069f8:	fc                   	cld    
f01069f9:	eb 1d                	jmp    f0106a18 <memmove+0x64>
f01069fb:	89 f2                	mov    %esi,%edx
f01069fd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01069ff:	f6 c2 03             	test   $0x3,%dl
f0106a02:	75 0f                	jne    f0106a13 <memmove+0x5f>
f0106a04:	f6 c1 03             	test   $0x3,%cl
f0106a07:	75 0a                	jne    f0106a13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0106a09:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0106a0c:	89 c7                	mov    %eax,%edi
f0106a0e:	fc                   	cld    
f0106a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106a11:	eb 05                	jmp    f0106a18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106a13:	89 c7                	mov    %eax,%edi
f0106a15:	fc                   	cld    
f0106a16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106a18:	5e                   	pop    %esi
f0106a19:	5f                   	pop    %edi
f0106a1a:	5d                   	pop    %ebp
f0106a1b:	c3                   	ret    

f0106a1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106a1c:	55                   	push   %ebp
f0106a1d:	89 e5                	mov    %esp,%ebp
f0106a1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106a22:	8b 45 10             	mov    0x10(%ebp),%eax
f0106a25:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106a29:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a30:	8b 45 08             	mov    0x8(%ebp),%eax
f0106a33:	89 04 24             	mov    %eax,(%esp)
f0106a36:	e8 79 ff ff ff       	call   f01069b4 <memmove>
}
f0106a3b:	c9                   	leave  
f0106a3c:	c3                   	ret    

f0106a3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106a3d:	55                   	push   %ebp
f0106a3e:	89 e5                	mov    %esp,%ebp
f0106a40:	56                   	push   %esi
f0106a41:	53                   	push   %ebx
f0106a42:	8b 55 08             	mov    0x8(%ebp),%edx
f0106a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106a48:	89 d6                	mov    %edx,%esi
f0106a4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106a4d:	eb 1a                	jmp    f0106a69 <memcmp+0x2c>
		if (*s1 != *s2)
f0106a4f:	0f b6 02             	movzbl (%edx),%eax
f0106a52:	0f b6 19             	movzbl (%ecx),%ebx
f0106a55:	38 d8                	cmp    %bl,%al
f0106a57:	74 0a                	je     f0106a63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0106a59:	0f b6 c0             	movzbl %al,%eax
f0106a5c:	0f b6 db             	movzbl %bl,%ebx
f0106a5f:	29 d8                	sub    %ebx,%eax
f0106a61:	eb 0f                	jmp    f0106a72 <memcmp+0x35>
		s1++, s2++;
f0106a63:	83 c2 01             	add    $0x1,%edx
f0106a66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106a69:	39 f2                	cmp    %esi,%edx
f0106a6b:	75 e2                	jne    f0106a4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106a72:	5b                   	pop    %ebx
f0106a73:	5e                   	pop    %esi
f0106a74:	5d                   	pop    %ebp
f0106a75:	c3                   	ret    

f0106a76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106a76:	55                   	push   %ebp
f0106a77:	89 e5                	mov    %esp,%ebp
f0106a79:	8b 45 08             	mov    0x8(%ebp),%eax
f0106a7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0106a7f:	89 c2                	mov    %eax,%edx
f0106a81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106a84:	eb 07                	jmp    f0106a8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106a86:	38 08                	cmp    %cl,(%eax)
f0106a88:	74 07                	je     f0106a91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106a8a:	83 c0 01             	add    $0x1,%eax
f0106a8d:	39 d0                	cmp    %edx,%eax
f0106a8f:	72 f5                	jb     f0106a86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106a91:	5d                   	pop    %ebp
f0106a92:	c3                   	ret    

f0106a93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106a93:	55                   	push   %ebp
f0106a94:	89 e5                	mov    %esp,%ebp
f0106a96:	57                   	push   %edi
f0106a97:	56                   	push   %esi
f0106a98:	53                   	push   %ebx
f0106a99:	8b 55 08             	mov    0x8(%ebp),%edx
f0106a9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106a9f:	eb 03                	jmp    f0106aa4 <strtol+0x11>
		s++;
f0106aa1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106aa4:	0f b6 0a             	movzbl (%edx),%ecx
f0106aa7:	80 f9 09             	cmp    $0x9,%cl
f0106aaa:	74 f5                	je     f0106aa1 <strtol+0xe>
f0106aac:	80 f9 20             	cmp    $0x20,%cl
f0106aaf:	74 f0                	je     f0106aa1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106ab1:	80 f9 2b             	cmp    $0x2b,%cl
f0106ab4:	75 0a                	jne    f0106ac0 <strtol+0x2d>
		s++;
f0106ab6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106ab9:	bf 00 00 00 00       	mov    $0x0,%edi
f0106abe:	eb 11                	jmp    f0106ad1 <strtol+0x3e>
f0106ac0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106ac5:	80 f9 2d             	cmp    $0x2d,%cl
f0106ac8:	75 07                	jne    f0106ad1 <strtol+0x3e>
		s++, neg = 1;
f0106aca:	8d 52 01             	lea    0x1(%edx),%edx
f0106acd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106ad1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0106ad6:	75 15                	jne    f0106aed <strtol+0x5a>
f0106ad8:	80 3a 30             	cmpb   $0x30,(%edx)
f0106adb:	75 10                	jne    f0106aed <strtol+0x5a>
f0106add:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106ae1:	75 0a                	jne    f0106aed <strtol+0x5a>
		s += 2, base = 16;
f0106ae3:	83 c2 02             	add    $0x2,%edx
f0106ae6:	b8 10 00 00 00       	mov    $0x10,%eax
f0106aeb:	eb 10                	jmp    f0106afd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0106aed:	85 c0                	test   %eax,%eax
f0106aef:	75 0c                	jne    f0106afd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106af1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106af3:	80 3a 30             	cmpb   $0x30,(%edx)
f0106af6:	75 05                	jne    f0106afd <strtol+0x6a>
		s++, base = 8;
f0106af8:	83 c2 01             	add    $0x1,%edx
f0106afb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0106afd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106b02:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106b05:	0f b6 0a             	movzbl (%edx),%ecx
f0106b08:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0106b0b:	89 f0                	mov    %esi,%eax
f0106b0d:	3c 09                	cmp    $0x9,%al
f0106b0f:	77 08                	ja     f0106b19 <strtol+0x86>
			dig = *s - '0';
f0106b11:	0f be c9             	movsbl %cl,%ecx
f0106b14:	83 e9 30             	sub    $0x30,%ecx
f0106b17:	eb 20                	jmp    f0106b39 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0106b19:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0106b1c:	89 f0                	mov    %esi,%eax
f0106b1e:	3c 19                	cmp    $0x19,%al
f0106b20:	77 08                	ja     f0106b2a <strtol+0x97>
			dig = *s - 'a' + 10;
f0106b22:	0f be c9             	movsbl %cl,%ecx
f0106b25:	83 e9 57             	sub    $0x57,%ecx
f0106b28:	eb 0f                	jmp    f0106b39 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0106b2a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0106b2d:	89 f0                	mov    %esi,%eax
f0106b2f:	3c 19                	cmp    $0x19,%al
f0106b31:	77 16                	ja     f0106b49 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0106b33:	0f be c9             	movsbl %cl,%ecx
f0106b36:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106b39:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0106b3c:	7d 0f                	jge    f0106b4d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0106b3e:	83 c2 01             	add    $0x1,%edx
f0106b41:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0106b45:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0106b47:	eb bc                	jmp    f0106b05 <strtol+0x72>
f0106b49:	89 d8                	mov    %ebx,%eax
f0106b4b:	eb 02                	jmp    f0106b4f <strtol+0xbc>
f0106b4d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0106b4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106b53:	74 05                	je     f0106b5a <strtol+0xc7>
		*endptr = (char *) s;
f0106b55:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106b58:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0106b5a:	f7 d8                	neg    %eax
f0106b5c:	85 ff                	test   %edi,%edi
f0106b5e:	0f 44 c3             	cmove  %ebx,%eax
}
f0106b61:	5b                   	pop    %ebx
f0106b62:	5e                   	pop    %esi
f0106b63:	5f                   	pop    %edi
f0106b64:	5d                   	pop    %ebp
f0106b65:	c3                   	ret    
f0106b66:	66 90                	xchg   %ax,%ax

f0106b68 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106b68:	fa                   	cli    

	xorw    %ax, %ax
f0106b69:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106b6b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106b6d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106b6f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106b71:	0f 01 16             	lgdtl  (%esi)
f0106b74:	74 70                	je     f0106be6 <mpentry_end+0x4>
	movl    %cr0, %eax
f0106b76:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106b79:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106b7d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106b80:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106b86:	08 00                	or     %al,(%eax)

f0106b88 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106b88:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106b8c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106b8e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106b90:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106b92:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106b96:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106b98:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106b9a:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0106b9f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106ba2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106ba5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106baa:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106bad:	8b 25 84 fe 23 f0    	mov    0xf023fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106bb3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106bb8:	b8 e2 01 10 f0       	mov    $0xf01001e2,%eax
	call    *%eax
f0106bbd:	ff d0                	call   *%eax

f0106bbf <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106bbf:	eb fe                	jmp    f0106bbf <spin>
f0106bc1:	8d 76 00             	lea    0x0(%esi),%esi

f0106bc4 <gdt>:
	...
f0106bcc:	ff                   	(bad)  
f0106bcd:	ff 00                	incl   (%eax)
f0106bcf:	00 00                	add    %al,(%eax)
f0106bd1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106bd8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106bdc <gdtdesc>:
f0106bdc:	17                   	pop    %ss
f0106bdd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106be2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106be2:	90                   	nop
f0106be3:	66 90                	xchg   %ax,%ax
f0106be5:	66 90                	xchg   %ax,%ax
f0106be7:	66 90                	xchg   %ax,%ax
f0106be9:	66 90                	xchg   %ax,%ax
f0106beb:	66 90                	xchg   %ax,%ax
f0106bed:	66 90                	xchg   %ax,%ax
f0106bef:	90                   	nop

f0106bf0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106bf0:	55                   	push   %ebp
f0106bf1:	89 e5                	mov    %esp,%ebp
f0106bf3:	56                   	push   %esi
f0106bf4:	53                   	push   %ebx
f0106bf5:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106bf8:	8b 0d 88 fe 23 f0    	mov    0xf023fe88,%ecx
f0106bfe:	89 c3                	mov    %eax,%ebx
f0106c00:	c1 eb 0c             	shr    $0xc,%ebx
f0106c03:	39 cb                	cmp    %ecx,%ebx
f0106c05:	72 20                	jb     f0106c27 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106c07:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106c0b:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0106c12:	f0 
f0106c13:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106c1a:	00 
f0106c1b:	c7 04 24 a5 93 10 f0 	movl   $0xf01093a5,(%esp)
f0106c22:	e8 19 94 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106c27:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106c2d:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106c2f:	89 c2                	mov    %eax,%edx
f0106c31:	c1 ea 0c             	shr    $0xc,%edx
f0106c34:	39 d1                	cmp    %edx,%ecx
f0106c36:	77 20                	ja     f0106c58 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106c38:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106c3c:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0106c43:	f0 
f0106c44:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106c4b:	00 
f0106c4c:	c7 04 24 a5 93 10 f0 	movl   $0xf01093a5,(%esp)
f0106c53:	e8 e8 93 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106c58:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0106c5e:	eb 36                	jmp    f0106c96 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106c60:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106c67:	00 
f0106c68:	c7 44 24 04 b5 93 10 	movl   $0xf01093b5,0x4(%esp)
f0106c6f:	f0 
f0106c70:	89 1c 24             	mov    %ebx,(%esp)
f0106c73:	e8 c5 fd ff ff       	call   f0106a3d <memcmp>
f0106c78:	85 c0                	test   %eax,%eax
f0106c7a:	75 17                	jne    f0106c93 <mpsearch1+0xa3>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106c7c:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106c81:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106c85:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106c87:	83 c2 01             	add    $0x1,%edx
f0106c8a:	83 fa 10             	cmp    $0x10,%edx
f0106c8d:	75 f2                	jne    f0106c81 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106c8f:	84 c0                	test   %al,%al
f0106c91:	74 0e                	je     f0106ca1 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106c93:	83 c3 10             	add    $0x10,%ebx
f0106c96:	39 f3                	cmp    %esi,%ebx
f0106c98:	72 c6                	jb     f0106c60 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106c9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0106c9f:	eb 02                	jmp    f0106ca3 <mpsearch1+0xb3>
f0106ca1:	89 d8                	mov    %ebx,%eax
}
f0106ca3:	83 c4 10             	add    $0x10,%esp
f0106ca6:	5b                   	pop    %ebx
f0106ca7:	5e                   	pop    %esi
f0106ca8:	5d                   	pop    %ebp
f0106ca9:	c3                   	ret    

f0106caa <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106caa:	55                   	push   %ebp
f0106cab:	89 e5                	mov    %esp,%ebp
f0106cad:	57                   	push   %edi
f0106cae:	56                   	push   %esi
f0106caf:	53                   	push   %ebx
f0106cb0:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106cb3:	c7 05 c0 13 24 f0 20 	movl   $0xf0241020,0xf02413c0
f0106cba:	10 24 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106cbd:	83 3d 88 fe 23 f0 00 	cmpl   $0x0,0xf023fe88
f0106cc4:	75 24                	jne    f0106cea <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106cc6:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106ccd:	00 
f0106cce:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0106cd5:	f0 
f0106cd6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106cdd:	00 
f0106cde:	c7 04 24 a5 93 10 f0 	movl   $0xf01093a5,(%esp)
f0106ce5:	e8 56 93 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106cea:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106cf1:	85 c0                	test   %eax,%eax
f0106cf3:	74 16                	je     f0106d0b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106cf5:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106cf8:	ba 00 04 00 00       	mov    $0x400,%edx
f0106cfd:	e8 ee fe ff ff       	call   f0106bf0 <mpsearch1>
f0106d02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106d05:	85 c0                	test   %eax,%eax
f0106d07:	75 3c                	jne    f0106d45 <mp_init+0x9b>
f0106d09:	eb 20                	jmp    f0106d2b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106d0b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106d12:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106d15:	2d 00 04 00 00       	sub    $0x400,%eax
f0106d1a:	ba 00 04 00 00       	mov    $0x400,%edx
f0106d1f:	e8 cc fe ff ff       	call   f0106bf0 <mpsearch1>
f0106d24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106d27:	85 c0                	test   %eax,%eax
f0106d29:	75 1a                	jne    f0106d45 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106d2b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106d30:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106d35:	e8 b6 fe ff ff       	call   f0106bf0 <mpsearch1>
f0106d3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106d3d:	85 c0                	test   %eax,%eax
f0106d3f:	0f 84 54 02 00 00    	je     f0106f99 <mp_init+0x2ef>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106d45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106d48:	8b 70 04             	mov    0x4(%eax),%esi
f0106d4b:	85 f6                	test   %esi,%esi
f0106d4d:	74 06                	je     f0106d55 <mp_init+0xab>
f0106d4f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106d53:	74 11                	je     f0106d66 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106d55:	c7 04 24 18 92 10 f0 	movl   $0xf0109218,(%esp)
f0106d5c:	e8 1b d3 ff ff       	call   f010407c <cprintf>
f0106d61:	e9 33 02 00 00       	jmp    f0106f99 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106d66:	89 f0                	mov    %esi,%eax
f0106d68:	c1 e8 0c             	shr    $0xc,%eax
f0106d6b:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0106d71:	72 20                	jb     f0106d93 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106d73:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106d77:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f0106d7e:	f0 
f0106d7f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106d86:	00 
f0106d87:	c7 04 24 a5 93 10 f0 	movl   $0xf01093a5,(%esp)
f0106d8e:	e8 ad 92 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106d93:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106d99:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106da0:	00 
f0106da1:	c7 44 24 04 ba 93 10 	movl   $0xf01093ba,0x4(%esp)
f0106da8:	f0 
f0106da9:	89 1c 24             	mov    %ebx,(%esp)
f0106dac:	e8 8c fc ff ff       	call   f0106a3d <memcmp>
f0106db1:	85 c0                	test   %eax,%eax
f0106db3:	74 11                	je     f0106dc6 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106db5:	c7 04 24 48 92 10 f0 	movl   $0xf0109248,(%esp)
f0106dbc:	e8 bb d2 ff ff       	call   f010407c <cprintf>
f0106dc1:	e9 d3 01 00 00       	jmp    f0106f99 <mp_init+0x2ef>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106dc6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0106dca:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0106dce:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106dd1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106dd6:	b8 00 00 00 00       	mov    $0x0,%eax
f0106ddb:	eb 0d                	jmp    f0106dea <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f0106ddd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106de4:	f0 
f0106de5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106de7:	83 c0 01             	add    $0x1,%eax
f0106dea:	39 c7                	cmp    %eax,%edi
f0106dec:	7f ef                	jg     f0106ddd <mp_init+0x133>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106dee:	84 d2                	test   %dl,%dl
f0106df0:	74 11                	je     f0106e03 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106df2:	c7 04 24 7c 92 10 f0 	movl   $0xf010927c,(%esp)
f0106df9:	e8 7e d2 ff ff       	call   f010407c <cprintf>
f0106dfe:	e9 96 01 00 00       	jmp    f0106f99 <mp_init+0x2ef>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106e03:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106e07:	3c 04                	cmp    $0x4,%al
f0106e09:	74 1f                	je     f0106e2a <mp_init+0x180>
f0106e0b:	3c 01                	cmp    $0x1,%al
f0106e0d:	8d 76 00             	lea    0x0(%esi),%esi
f0106e10:	74 18                	je     f0106e2a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106e12:	0f b6 c0             	movzbl %al,%eax
f0106e15:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e19:	c7 04 24 a0 92 10 f0 	movl   $0xf01092a0,(%esp)
f0106e20:	e8 57 d2 ff ff       	call   f010407c <cprintf>
f0106e25:	e9 6f 01 00 00       	jmp    f0106f99 <mp_init+0x2ef>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106e2a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f0106e2e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0106e32:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106e34:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106e39:	b8 00 00 00 00       	mov    $0x0,%eax
f0106e3e:	eb 09                	jmp    f0106e49 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f0106e40:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0106e44:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106e46:	83 c0 01             	add    $0x1,%eax
f0106e49:	39 c6                	cmp    %eax,%esi
f0106e4b:	7f f3                	jg     f0106e40 <mp_init+0x196>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106e4d:	02 53 2a             	add    0x2a(%ebx),%dl
f0106e50:	84 d2                	test   %dl,%dl
f0106e52:	74 11                	je     f0106e65 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106e54:	c7 04 24 c0 92 10 f0 	movl   $0xf01092c0,(%esp)
f0106e5b:	e8 1c d2 ff ff       	call   f010407c <cprintf>
f0106e60:	e9 34 01 00 00       	jmp    f0106f99 <mp_init+0x2ef>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106e65:	85 db                	test   %ebx,%ebx
f0106e67:	0f 84 2c 01 00 00    	je     f0106f99 <mp_init+0x2ef>
		return;
	ismp = 1;
f0106e6d:	c7 05 00 10 24 f0 01 	movl   $0x1,0xf0241000
f0106e74:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106e77:	8b 43 24             	mov    0x24(%ebx),%eax
f0106e7a:	a3 00 20 28 f0       	mov    %eax,0xf0282000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106e7f:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106e82:	be 00 00 00 00       	mov    $0x0,%esi
f0106e87:	e9 86 00 00 00       	jmp    f0106f12 <mp_init+0x268>
		switch (*p) {
f0106e8c:	0f b6 07             	movzbl (%edi),%eax
f0106e8f:	84 c0                	test   %al,%al
f0106e91:	74 06                	je     f0106e99 <mp_init+0x1ef>
f0106e93:	3c 04                	cmp    $0x4,%al
f0106e95:	77 57                	ja     f0106eee <mp_init+0x244>
f0106e97:	eb 50                	jmp    f0106ee9 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106e99:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106e9d:	8d 76 00             	lea    0x0(%esi),%esi
f0106ea0:	74 11                	je     f0106eb3 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106ea2:	6b 05 c4 13 24 f0 74 	imul   $0x74,0xf02413c4,%eax
f0106ea9:	05 20 10 24 f0       	add    $0xf0241020,%eax
f0106eae:	a3 c0 13 24 f0       	mov    %eax,0xf02413c0
			if (ncpu < NCPU) {
f0106eb3:	a1 c4 13 24 f0       	mov    0xf02413c4,%eax
f0106eb8:	83 f8 07             	cmp    $0x7,%eax
f0106ebb:	7f 13                	jg     f0106ed0 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f0106ebd:	6b d0 74             	imul   $0x74,%eax,%edx
f0106ec0:	88 82 20 10 24 f0    	mov    %al,-0xfdbefe0(%edx)
				ncpu++;
f0106ec6:	83 c0 01             	add    $0x1,%eax
f0106ec9:	a3 c4 13 24 f0       	mov    %eax,0xf02413c4
f0106ece:	eb 14                	jmp    f0106ee4 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106ed0:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ed8:	c7 04 24 f0 92 10 f0 	movl   $0xf01092f0,(%esp)
f0106edf:	e8 98 d1 ff ff       	call   f010407c <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106ee4:	83 c7 14             	add    $0x14,%edi
			continue;
f0106ee7:	eb 26                	jmp    f0106f0f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106ee9:	83 c7 08             	add    $0x8,%edi
			continue;
f0106eec:	eb 21                	jmp    f0106f0f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106eee:	0f b6 c0             	movzbl %al,%eax
f0106ef1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ef5:	c7 04 24 18 93 10 f0 	movl   $0xf0109318,(%esp)
f0106efc:	e8 7b d1 ff ff       	call   f010407c <cprintf>
			ismp = 0;
f0106f01:	c7 05 00 10 24 f0 00 	movl   $0x0,0xf0241000
f0106f08:	00 00 00 
			i = conf->entry;
f0106f0b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106f0f:	83 c6 01             	add    $0x1,%esi
f0106f12:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106f16:	39 c6                	cmp    %eax,%esi
f0106f18:	0f 82 6e ff ff ff    	jb     f0106e8c <mp_init+0x1e2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106f1e:	a1 c0 13 24 f0       	mov    0xf02413c0,%eax
f0106f23:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106f2a:	83 3d 00 10 24 f0 00 	cmpl   $0x0,0xf0241000
f0106f31:	75 22                	jne    f0106f55 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106f33:	c7 05 c4 13 24 f0 01 	movl   $0x1,0xf02413c4
f0106f3a:	00 00 00 
		lapicaddr = 0;
f0106f3d:	c7 05 00 20 28 f0 00 	movl   $0x0,0xf0282000
f0106f44:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106f47:	c7 04 24 38 93 10 f0 	movl   $0xf0109338,(%esp)
f0106f4e:	e8 29 d1 ff ff       	call   f010407c <cprintf>
		return;
f0106f53:	eb 44                	jmp    f0106f99 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106f55:	8b 15 c4 13 24 f0    	mov    0xf02413c4,%edx
f0106f5b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106f5f:	0f b6 00             	movzbl (%eax),%eax
f0106f62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f66:	c7 04 24 bf 93 10 f0 	movl   $0xf01093bf,(%esp)
f0106f6d:	e8 0a d1 ff ff       	call   f010407c <cprintf>

	if (mp->imcrp) {
f0106f72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f75:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106f79:	74 1e                	je     f0106f99 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106f7b:	c7 04 24 64 93 10 f0 	movl   $0xf0109364,(%esp)
f0106f82:	e8 f5 d0 ff ff       	call   f010407c <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106f87:	ba 22 00 00 00       	mov    $0x22,%edx
f0106f8c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106f91:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106f92:	b2 23                	mov    $0x23,%dl
f0106f94:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106f95:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106f98:	ee                   	out    %al,(%dx)
	}
}
f0106f99:	83 c4 2c             	add    $0x2c,%esp
f0106f9c:	5b                   	pop    %ebx
f0106f9d:	5e                   	pop    %esi
f0106f9e:	5f                   	pop    %edi
f0106f9f:	5d                   	pop    %ebp
f0106fa0:	c3                   	ret    

f0106fa1 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106fa1:	55                   	push   %ebp
f0106fa2:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106fa4:	8b 0d 04 20 28 f0    	mov    0xf0282004,%ecx
f0106faa:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106fad:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106faf:	a1 04 20 28 f0       	mov    0xf0282004,%eax
f0106fb4:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106fb7:	5d                   	pop    %ebp
f0106fb8:	c3                   	ret    

f0106fb9 <cpunum>:
	
}

int
cpunum(void)
{
f0106fb9:	55                   	push   %ebp
f0106fba:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106fbc:	a1 04 20 28 f0       	mov    0xf0282004,%eax
f0106fc1:	85 c0                	test   %eax,%eax
f0106fc3:	74 08                	je     f0106fcd <cpunum+0x14>
		return lapic[ID] >> 24;
f0106fc5:	8b 40 20             	mov    0x20(%eax),%eax
f0106fc8:	c1 e8 18             	shr    $0x18,%eax
f0106fcb:	eb 05                	jmp    f0106fd2 <cpunum+0x19>
	return 0;
f0106fcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106fd2:	5d                   	pop    %ebp
f0106fd3:	c3                   	ret    

f0106fd4 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0106fd4:	a1 00 20 28 f0       	mov    0xf0282000,%eax
f0106fd9:	85 c0                	test   %eax,%eax
f0106fdb:	0f 84 23 01 00 00    	je     f0107104 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106fe1:	55                   	push   %ebp
f0106fe2:	89 e5                	mov    %esp,%ebp
f0106fe4:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106fe7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106fee:	00 
f0106fef:	89 04 24             	mov    %eax,(%esp)
f0106ff2:	e8 e9 a4 ff ff       	call   f01014e0 <mmio_map_region>
f0106ff7:	a3 04 20 28 f0       	mov    %eax,0xf0282004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106ffc:	ba 27 01 00 00       	mov    $0x127,%edx
f0107001:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0107006:	e8 96 ff ff ff       	call   f0106fa1 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010700b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0107010:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0107015:	e8 87 ff ff ff       	call   f0106fa1 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010701a:	ba 20 00 02 00       	mov    $0x20020,%edx
f010701f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0107024:	e8 78 ff ff ff       	call   f0106fa1 <lapicw>
	lapicw(TICR, 10000000); 
f0107029:	ba 80 96 98 00       	mov    $0x989680,%edx
f010702e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0107033:	e8 69 ff ff ff       	call   f0106fa1 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0107038:	e8 7c ff ff ff       	call   f0106fb9 <cpunum>
f010703d:	6b c0 74             	imul   $0x74,%eax,%eax
f0107040:	05 20 10 24 f0       	add    $0xf0241020,%eax
f0107045:	39 05 c0 13 24 f0    	cmp    %eax,0xf02413c0
f010704b:	74 0f                	je     f010705c <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f010704d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107052:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0107057:	e8 45 ff ff ff       	call   f0106fa1 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010705c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107061:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0107066:	e8 36 ff ff ff       	call   f0106fa1 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010706b:	a1 04 20 28 f0       	mov    0xf0282004,%eax
f0107070:	8b 40 30             	mov    0x30(%eax),%eax
f0107073:	c1 e8 10             	shr    $0x10,%eax
f0107076:	3c 03                	cmp    $0x3,%al
f0107078:	76 0f                	jbe    f0107089 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f010707a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010707f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0107084:	e8 18 ff ff ff       	call   f0106fa1 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0107089:	ba 33 00 00 00       	mov    $0x33,%edx
f010708e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0107093:	e8 09 ff ff ff       	call   f0106fa1 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0107098:	ba 00 00 00 00       	mov    $0x0,%edx
f010709d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01070a2:	e8 fa fe ff ff       	call   f0106fa1 <lapicw>
	lapicw(ESR, 0);
f01070a7:	ba 00 00 00 00       	mov    $0x0,%edx
f01070ac:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01070b1:	e8 eb fe ff ff       	call   f0106fa1 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01070b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01070bb:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01070c0:	e8 dc fe ff ff       	call   f0106fa1 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01070c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01070ca:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01070cf:	e8 cd fe ff ff       	call   f0106fa1 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01070d4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01070d9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01070de:	e8 be fe ff ff       	call   f0106fa1 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01070e3:	8b 15 04 20 28 f0    	mov    0xf0282004,%edx
f01070e9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01070ef:	f6 c4 10             	test   $0x10,%ah
f01070f2:	75 f5                	jne    f01070e9 <lapic_init+0x115>
		;

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01070f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01070f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01070fe:	e8 9e fe ff ff       	call   f0106fa1 <lapicw>
	
}
f0107103:	c9                   	leave  
f0107104:	f3 c3                	repz ret 

f0107106 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0107106:	83 3d 04 20 28 f0 00 	cmpl   $0x0,0xf0282004
f010710d:	74 13                	je     f0107122 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010710f:	55                   	push   %ebp
f0107110:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0107112:	ba 00 00 00 00       	mov    $0x0,%edx
f0107117:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010711c:	e8 80 fe ff ff       	call   f0106fa1 <lapicw>
}
f0107121:	5d                   	pop    %ebp
f0107122:	f3 c3                	repz ret 

f0107124 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0107124:	55                   	push   %ebp
f0107125:	89 e5                	mov    %esp,%ebp
f0107127:	56                   	push   %esi
f0107128:	53                   	push   %ebx
f0107129:	83 ec 10             	sub    $0x10,%esp
f010712c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010712f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107132:	ba 70 00 00 00       	mov    $0x70,%edx
f0107137:	b8 0f 00 00 00       	mov    $0xf,%eax
f010713c:	ee                   	out    %al,(%dx)
f010713d:	b2 71                	mov    $0x71,%dl
f010713f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0107144:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107145:	83 3d 88 fe 23 f0 00 	cmpl   $0x0,0xf023fe88
f010714c:	75 24                	jne    f0107172 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010714e:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0107155:	00 
f0107156:	c7 44 24 08 c4 76 10 	movl   $0xf01076c4,0x8(%esp)
f010715d:	f0 
f010715e:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
f0107165:	00 
f0107166:	c7 04 24 dc 93 10 f0 	movl   $0xf01093dc,(%esp)
f010716d:	e8 ce 8e ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0107172:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0107179:	00 00 
	wrv[1] = addr >> 4;
f010717b:	89 f0                	mov    %esi,%eax
f010717d:	c1 e8 04             	shr    $0x4,%eax
f0107180:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0107186:	c1 e3 18             	shl    $0x18,%ebx
f0107189:	89 da                	mov    %ebx,%edx
f010718b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107190:	e8 0c fe ff ff       	call   f0106fa1 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0107195:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010719a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010719f:	e8 fd fd ff ff       	call   f0106fa1 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01071a4:	ba 00 85 00 00       	mov    $0x8500,%edx
f01071a9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01071ae:	e8 ee fd ff ff       	call   f0106fa1 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01071b3:	c1 ee 0c             	shr    $0xc,%esi
f01071b6:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01071bc:	89 da                	mov    %ebx,%edx
f01071be:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01071c3:	e8 d9 fd ff ff       	call   f0106fa1 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01071c8:	89 f2                	mov    %esi,%edx
f01071ca:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01071cf:	e8 cd fd ff ff       	call   f0106fa1 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01071d4:	89 da                	mov    %ebx,%edx
f01071d6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01071db:	e8 c1 fd ff ff       	call   f0106fa1 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01071e0:	89 f2                	mov    %esi,%edx
f01071e2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01071e7:	e8 b5 fd ff ff       	call   f0106fa1 <lapicw>
		microdelay(200);
	}
}
f01071ec:	83 c4 10             	add    $0x10,%esp
f01071ef:	5b                   	pop    %ebx
f01071f0:	5e                   	pop    %esi
f01071f1:	5d                   	pop    %ebp
f01071f2:	c3                   	ret    

f01071f3 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01071f3:	55                   	push   %ebp
f01071f4:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01071f6:	8b 55 08             	mov    0x8(%ebp),%edx
f01071f9:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01071ff:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107204:	e8 98 fd ff ff       	call   f0106fa1 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0107209:	8b 15 04 20 28 f0    	mov    0xf0282004,%edx
f010720f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0107215:	f6 c4 10             	test   $0x10,%ah
f0107218:	75 f5                	jne    f010720f <lapic_ipi+0x1c>
		;
}
f010721a:	5d                   	pop    %ebp
f010721b:	c3                   	ret    

f010721c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010721c:	55                   	push   %ebp
f010721d:	89 e5                	mov    %esp,%ebp
f010721f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0107222:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0107228:	8b 55 0c             	mov    0xc(%ebp),%edx
f010722b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010722e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0107235:	5d                   	pop    %ebp
f0107236:	c3                   	ret    

f0107237 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0107237:	55                   	push   %ebp
f0107238:	89 e5                	mov    %esp,%ebp
f010723a:	56                   	push   %esi
f010723b:	53                   	push   %ebx
f010723c:	83 ec 20             	sub    $0x20,%esp
f010723f:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0107242:	83 3b 00             	cmpl   $0x0,(%ebx)
f0107245:	75 07                	jne    f010724e <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0107247:	ba 01 00 00 00       	mov    $0x1,%edx
f010724c:	eb 42                	jmp    f0107290 <spin_lock+0x59>
f010724e:	8b 73 08             	mov    0x8(%ebx),%esi
f0107251:	e8 63 fd ff ff       	call   f0106fb9 <cpunum>
f0107256:	6b c0 74             	imul   $0x74,%eax,%eax
f0107259:	05 20 10 24 f0       	add    $0xf0241020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010725e:	39 c6                	cmp    %eax,%esi
f0107260:	75 e5                	jne    f0107247 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0107262:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107265:	e8 4f fd ff ff       	call   f0106fb9 <cpunum>
f010726a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010726e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107272:	c7 44 24 08 ec 93 10 	movl   $0xf01093ec,0x8(%esp)
f0107279:	f0 
f010727a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0107281:	00 
f0107282:	c7 04 24 50 94 10 f0 	movl   $0xf0109450,(%esp)
f0107289:	e8 b2 8d ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010728e:	f3 90                	pause  
f0107290:	89 d0                	mov    %edx,%eax
f0107292:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107295:	85 c0                	test   %eax,%eax
f0107297:	75 f5                	jne    f010728e <spin_lock+0x57>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0107299:	e8 1b fd ff ff       	call   f0106fb9 <cpunum>
f010729e:	6b c0 74             	imul   $0x74,%eax,%eax
f01072a1:	05 20 10 24 f0       	add    $0xf0241020,%eax
f01072a6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01072a9:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f01072ac:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01072ae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01072b3:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01072b9:	76 12                	jbe    f01072cd <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01072bb:	8b 4a 04             	mov    0x4(%edx),%ecx
f01072be:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01072c1:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01072c3:	83 c0 01             	add    $0x1,%eax
f01072c6:	83 f8 0a             	cmp    $0xa,%eax
f01072c9:	75 e8                	jne    f01072b3 <spin_lock+0x7c>
f01072cb:	eb 0f                	jmp    f01072dc <spin_lock+0xa5>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01072cd:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01072d4:	83 c0 01             	add    $0x1,%eax
f01072d7:	83 f8 09             	cmp    $0x9,%eax
f01072da:	7e f1                	jle    f01072cd <spin_lock+0x96>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01072dc:	83 c4 20             	add    $0x20,%esp
f01072df:	5b                   	pop    %ebx
f01072e0:	5e                   	pop    %esi
f01072e1:	5d                   	pop    %ebp
f01072e2:	c3                   	ret    

f01072e3 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01072e3:	55                   	push   %ebp
f01072e4:	89 e5                	mov    %esp,%ebp
f01072e6:	57                   	push   %edi
f01072e7:	56                   	push   %esi
f01072e8:	53                   	push   %ebx
f01072e9:	83 ec 6c             	sub    $0x6c,%esp
f01072ec:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01072ef:	83 3e 00             	cmpl   $0x0,(%esi)
f01072f2:	74 18                	je     f010730c <spin_unlock+0x29>
f01072f4:	8b 5e 08             	mov    0x8(%esi),%ebx
f01072f7:	e8 bd fc ff ff       	call   f0106fb9 <cpunum>
f01072fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01072ff:	05 20 10 24 f0       	add    $0xf0241020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0107304:	39 c3                	cmp    %eax,%ebx
f0107306:	0f 84 ce 00 00 00    	je     f01073da <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010730c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0107313:	00 
f0107314:	8d 46 0c             	lea    0xc(%esi),%eax
f0107317:	89 44 24 04          	mov    %eax,0x4(%esp)
f010731b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010731e:	89 1c 24             	mov    %ebx,(%esp)
f0107321:	e8 8e f6 ff ff       	call   f01069b4 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0107326:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0107329:	0f b6 38             	movzbl (%eax),%edi
f010732c:	8b 76 04             	mov    0x4(%esi),%esi
f010732f:	e8 85 fc ff ff       	call   f0106fb9 <cpunum>
f0107334:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107338:	89 74 24 08          	mov    %esi,0x8(%esp)
f010733c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107340:	c7 04 24 18 94 10 f0 	movl   $0xf0109418,(%esp)
f0107347:	e8 30 cd ff ff       	call   f010407c <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010734c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010734f:	eb 65                	jmp    f01073b6 <spin_unlock+0xd3>
f0107351:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107355:	89 04 24             	mov    %eax,(%esp)
f0107358:	e8 b3 e5 ff ff       	call   f0105910 <debuginfo_eip>
f010735d:	85 c0                	test   %eax,%eax
f010735f:	78 39                	js     f010739a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0107361:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0107363:	89 c2                	mov    %eax,%edx
f0107365:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0107368:	89 54 24 18          	mov    %edx,0x18(%esp)
f010736c:	8b 55 b0             	mov    -0x50(%ebp),%edx
f010736f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107373:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0107376:	89 54 24 10          	mov    %edx,0x10(%esp)
f010737a:	8b 55 ac             	mov    -0x54(%ebp),%edx
f010737d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107381:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0107384:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107388:	89 44 24 04          	mov    %eax,0x4(%esp)
f010738c:	c7 04 24 60 94 10 f0 	movl   $0xf0109460,(%esp)
f0107393:	e8 e4 cc ff ff       	call   f010407c <cprintf>
f0107398:	eb 12                	jmp    f01073ac <spin_unlock+0xc9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010739a:	8b 06                	mov    (%esi),%eax
f010739c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01073a0:	c7 04 24 77 94 10 f0 	movl   $0xf0109477,(%esp)
f01073a7:	e8 d0 cc ff ff       	call   f010407c <cprintf>
f01073ac:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01073af:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01073b2:	39 c3                	cmp    %eax,%ebx
f01073b4:	74 08                	je     f01073be <spin_unlock+0xdb>
f01073b6:	89 de                	mov    %ebx,%esi
f01073b8:	8b 03                	mov    (%ebx),%eax
f01073ba:	85 c0                	test   %eax,%eax
f01073bc:	75 93                	jne    f0107351 <spin_unlock+0x6e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01073be:	c7 44 24 08 7f 94 10 	movl   $0xf010947f,0x8(%esp)
f01073c5:	f0 
f01073c6:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01073cd:	00 
f01073ce:	c7 04 24 50 94 10 f0 	movl   $0xf0109450,(%esp)
f01073d5:	e8 66 8c ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01073da:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01073e1:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f01073e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01073ed:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01073f0:	83 c4 6c             	add    $0x6c,%esp
f01073f3:	5b                   	pop    %ebx
f01073f4:	5e                   	pop    %esi
f01073f5:	5f                   	pop    %edi
f01073f6:	5d                   	pop    %ebp
f01073f7:	c3                   	ret    
f01073f8:	66 90                	xchg   %ax,%ax
f01073fa:	66 90                	xchg   %ax,%ax
f01073fc:	66 90                	xchg   %ax,%ax
f01073fe:	66 90                	xchg   %ax,%ax

f0107400 <__udivdi3>:
f0107400:	55                   	push   %ebp
f0107401:	57                   	push   %edi
f0107402:	56                   	push   %esi
f0107403:	83 ec 0c             	sub    $0xc,%esp
f0107406:	8b 44 24 28          	mov    0x28(%esp),%eax
f010740a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010740e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0107412:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0107416:	85 c0                	test   %eax,%eax
f0107418:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010741c:	89 ea                	mov    %ebp,%edx
f010741e:	89 0c 24             	mov    %ecx,(%esp)
f0107421:	75 2d                	jne    f0107450 <__udivdi3+0x50>
f0107423:	39 e9                	cmp    %ebp,%ecx
f0107425:	77 61                	ja     f0107488 <__udivdi3+0x88>
f0107427:	85 c9                	test   %ecx,%ecx
f0107429:	89 ce                	mov    %ecx,%esi
f010742b:	75 0b                	jne    f0107438 <__udivdi3+0x38>
f010742d:	b8 01 00 00 00       	mov    $0x1,%eax
f0107432:	31 d2                	xor    %edx,%edx
f0107434:	f7 f1                	div    %ecx
f0107436:	89 c6                	mov    %eax,%esi
f0107438:	31 d2                	xor    %edx,%edx
f010743a:	89 e8                	mov    %ebp,%eax
f010743c:	f7 f6                	div    %esi
f010743e:	89 c5                	mov    %eax,%ebp
f0107440:	89 f8                	mov    %edi,%eax
f0107442:	f7 f6                	div    %esi
f0107444:	89 ea                	mov    %ebp,%edx
f0107446:	83 c4 0c             	add    $0xc,%esp
f0107449:	5e                   	pop    %esi
f010744a:	5f                   	pop    %edi
f010744b:	5d                   	pop    %ebp
f010744c:	c3                   	ret    
f010744d:	8d 76 00             	lea    0x0(%esi),%esi
f0107450:	39 e8                	cmp    %ebp,%eax
f0107452:	77 24                	ja     f0107478 <__udivdi3+0x78>
f0107454:	0f bd e8             	bsr    %eax,%ebp
f0107457:	83 f5 1f             	xor    $0x1f,%ebp
f010745a:	75 3c                	jne    f0107498 <__udivdi3+0x98>
f010745c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0107460:	39 34 24             	cmp    %esi,(%esp)
f0107463:	0f 86 9f 00 00 00    	jbe    f0107508 <__udivdi3+0x108>
f0107469:	39 d0                	cmp    %edx,%eax
f010746b:	0f 82 97 00 00 00    	jb     f0107508 <__udivdi3+0x108>
f0107471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107478:	31 d2                	xor    %edx,%edx
f010747a:	31 c0                	xor    %eax,%eax
f010747c:	83 c4 0c             	add    $0xc,%esp
f010747f:	5e                   	pop    %esi
f0107480:	5f                   	pop    %edi
f0107481:	5d                   	pop    %ebp
f0107482:	c3                   	ret    
f0107483:	90                   	nop
f0107484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107488:	89 f8                	mov    %edi,%eax
f010748a:	f7 f1                	div    %ecx
f010748c:	31 d2                	xor    %edx,%edx
f010748e:	83 c4 0c             	add    $0xc,%esp
f0107491:	5e                   	pop    %esi
f0107492:	5f                   	pop    %edi
f0107493:	5d                   	pop    %ebp
f0107494:	c3                   	ret    
f0107495:	8d 76 00             	lea    0x0(%esi),%esi
f0107498:	89 e9                	mov    %ebp,%ecx
f010749a:	8b 3c 24             	mov    (%esp),%edi
f010749d:	d3 e0                	shl    %cl,%eax
f010749f:	89 c6                	mov    %eax,%esi
f01074a1:	b8 20 00 00 00       	mov    $0x20,%eax
f01074a6:	29 e8                	sub    %ebp,%eax
f01074a8:	89 c1                	mov    %eax,%ecx
f01074aa:	d3 ef                	shr    %cl,%edi
f01074ac:	89 e9                	mov    %ebp,%ecx
f01074ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01074b2:	8b 3c 24             	mov    (%esp),%edi
f01074b5:	09 74 24 08          	or     %esi,0x8(%esp)
f01074b9:	89 d6                	mov    %edx,%esi
f01074bb:	d3 e7                	shl    %cl,%edi
f01074bd:	89 c1                	mov    %eax,%ecx
f01074bf:	89 3c 24             	mov    %edi,(%esp)
f01074c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01074c6:	d3 ee                	shr    %cl,%esi
f01074c8:	89 e9                	mov    %ebp,%ecx
f01074ca:	d3 e2                	shl    %cl,%edx
f01074cc:	89 c1                	mov    %eax,%ecx
f01074ce:	d3 ef                	shr    %cl,%edi
f01074d0:	09 d7                	or     %edx,%edi
f01074d2:	89 f2                	mov    %esi,%edx
f01074d4:	89 f8                	mov    %edi,%eax
f01074d6:	f7 74 24 08          	divl   0x8(%esp)
f01074da:	89 d6                	mov    %edx,%esi
f01074dc:	89 c7                	mov    %eax,%edi
f01074de:	f7 24 24             	mull   (%esp)
f01074e1:	39 d6                	cmp    %edx,%esi
f01074e3:	89 14 24             	mov    %edx,(%esp)
f01074e6:	72 30                	jb     f0107518 <__udivdi3+0x118>
f01074e8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01074ec:	89 e9                	mov    %ebp,%ecx
f01074ee:	d3 e2                	shl    %cl,%edx
f01074f0:	39 c2                	cmp    %eax,%edx
f01074f2:	73 05                	jae    f01074f9 <__udivdi3+0xf9>
f01074f4:	3b 34 24             	cmp    (%esp),%esi
f01074f7:	74 1f                	je     f0107518 <__udivdi3+0x118>
f01074f9:	89 f8                	mov    %edi,%eax
f01074fb:	31 d2                	xor    %edx,%edx
f01074fd:	e9 7a ff ff ff       	jmp    f010747c <__udivdi3+0x7c>
f0107502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107508:	31 d2                	xor    %edx,%edx
f010750a:	b8 01 00 00 00       	mov    $0x1,%eax
f010750f:	e9 68 ff ff ff       	jmp    f010747c <__udivdi3+0x7c>
f0107514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107518:	8d 47 ff             	lea    -0x1(%edi),%eax
f010751b:	31 d2                	xor    %edx,%edx
f010751d:	83 c4 0c             	add    $0xc,%esp
f0107520:	5e                   	pop    %esi
f0107521:	5f                   	pop    %edi
f0107522:	5d                   	pop    %ebp
f0107523:	c3                   	ret    
f0107524:	66 90                	xchg   %ax,%ax
f0107526:	66 90                	xchg   %ax,%ax
f0107528:	66 90                	xchg   %ax,%ax
f010752a:	66 90                	xchg   %ax,%ax
f010752c:	66 90                	xchg   %ax,%ax
f010752e:	66 90                	xchg   %ax,%ax

f0107530 <__umoddi3>:
f0107530:	55                   	push   %ebp
f0107531:	57                   	push   %edi
f0107532:	56                   	push   %esi
f0107533:	83 ec 14             	sub    $0x14,%esp
f0107536:	8b 44 24 28          	mov    0x28(%esp),%eax
f010753a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010753e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0107542:	89 c7                	mov    %eax,%edi
f0107544:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107548:	8b 44 24 30          	mov    0x30(%esp),%eax
f010754c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0107550:	89 34 24             	mov    %esi,(%esp)
f0107553:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107557:	85 c0                	test   %eax,%eax
f0107559:	89 c2                	mov    %eax,%edx
f010755b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010755f:	75 17                	jne    f0107578 <__umoddi3+0x48>
f0107561:	39 fe                	cmp    %edi,%esi
f0107563:	76 4b                	jbe    f01075b0 <__umoddi3+0x80>
f0107565:	89 c8                	mov    %ecx,%eax
f0107567:	89 fa                	mov    %edi,%edx
f0107569:	f7 f6                	div    %esi
f010756b:	89 d0                	mov    %edx,%eax
f010756d:	31 d2                	xor    %edx,%edx
f010756f:	83 c4 14             	add    $0x14,%esp
f0107572:	5e                   	pop    %esi
f0107573:	5f                   	pop    %edi
f0107574:	5d                   	pop    %ebp
f0107575:	c3                   	ret    
f0107576:	66 90                	xchg   %ax,%ax
f0107578:	39 f8                	cmp    %edi,%eax
f010757a:	77 54                	ja     f01075d0 <__umoddi3+0xa0>
f010757c:	0f bd e8             	bsr    %eax,%ebp
f010757f:	83 f5 1f             	xor    $0x1f,%ebp
f0107582:	75 5c                	jne    f01075e0 <__umoddi3+0xb0>
f0107584:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0107588:	39 3c 24             	cmp    %edi,(%esp)
f010758b:	0f 87 e7 00 00 00    	ja     f0107678 <__umoddi3+0x148>
f0107591:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0107595:	29 f1                	sub    %esi,%ecx
f0107597:	19 c7                	sbb    %eax,%edi
f0107599:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010759d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01075a1:	8b 44 24 08          	mov    0x8(%esp),%eax
f01075a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01075a9:	83 c4 14             	add    $0x14,%esp
f01075ac:	5e                   	pop    %esi
f01075ad:	5f                   	pop    %edi
f01075ae:	5d                   	pop    %ebp
f01075af:	c3                   	ret    
f01075b0:	85 f6                	test   %esi,%esi
f01075b2:	89 f5                	mov    %esi,%ebp
f01075b4:	75 0b                	jne    f01075c1 <__umoddi3+0x91>
f01075b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01075bb:	31 d2                	xor    %edx,%edx
f01075bd:	f7 f6                	div    %esi
f01075bf:	89 c5                	mov    %eax,%ebp
f01075c1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01075c5:	31 d2                	xor    %edx,%edx
f01075c7:	f7 f5                	div    %ebp
f01075c9:	89 c8                	mov    %ecx,%eax
f01075cb:	f7 f5                	div    %ebp
f01075cd:	eb 9c                	jmp    f010756b <__umoddi3+0x3b>
f01075cf:	90                   	nop
f01075d0:	89 c8                	mov    %ecx,%eax
f01075d2:	89 fa                	mov    %edi,%edx
f01075d4:	83 c4 14             	add    $0x14,%esp
f01075d7:	5e                   	pop    %esi
f01075d8:	5f                   	pop    %edi
f01075d9:	5d                   	pop    %ebp
f01075da:	c3                   	ret    
f01075db:	90                   	nop
f01075dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01075e0:	8b 04 24             	mov    (%esp),%eax
f01075e3:	be 20 00 00 00       	mov    $0x20,%esi
f01075e8:	89 e9                	mov    %ebp,%ecx
f01075ea:	29 ee                	sub    %ebp,%esi
f01075ec:	d3 e2                	shl    %cl,%edx
f01075ee:	89 f1                	mov    %esi,%ecx
f01075f0:	d3 e8                	shr    %cl,%eax
f01075f2:	89 e9                	mov    %ebp,%ecx
f01075f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01075f8:	8b 04 24             	mov    (%esp),%eax
f01075fb:	09 54 24 04          	or     %edx,0x4(%esp)
f01075ff:	89 fa                	mov    %edi,%edx
f0107601:	d3 e0                	shl    %cl,%eax
f0107603:	89 f1                	mov    %esi,%ecx
f0107605:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107609:	8b 44 24 10          	mov    0x10(%esp),%eax
f010760d:	d3 ea                	shr    %cl,%edx
f010760f:	89 e9                	mov    %ebp,%ecx
f0107611:	d3 e7                	shl    %cl,%edi
f0107613:	89 f1                	mov    %esi,%ecx
f0107615:	d3 e8                	shr    %cl,%eax
f0107617:	89 e9                	mov    %ebp,%ecx
f0107619:	09 f8                	or     %edi,%eax
f010761b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010761f:	f7 74 24 04          	divl   0x4(%esp)
f0107623:	d3 e7                	shl    %cl,%edi
f0107625:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107629:	89 d7                	mov    %edx,%edi
f010762b:	f7 64 24 08          	mull   0x8(%esp)
f010762f:	39 d7                	cmp    %edx,%edi
f0107631:	89 c1                	mov    %eax,%ecx
f0107633:	89 14 24             	mov    %edx,(%esp)
f0107636:	72 2c                	jb     f0107664 <__umoddi3+0x134>
f0107638:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010763c:	72 22                	jb     f0107660 <__umoddi3+0x130>
f010763e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0107642:	29 c8                	sub    %ecx,%eax
f0107644:	19 d7                	sbb    %edx,%edi
f0107646:	89 e9                	mov    %ebp,%ecx
f0107648:	89 fa                	mov    %edi,%edx
f010764a:	d3 e8                	shr    %cl,%eax
f010764c:	89 f1                	mov    %esi,%ecx
f010764e:	d3 e2                	shl    %cl,%edx
f0107650:	89 e9                	mov    %ebp,%ecx
f0107652:	d3 ef                	shr    %cl,%edi
f0107654:	09 d0                	or     %edx,%eax
f0107656:	89 fa                	mov    %edi,%edx
f0107658:	83 c4 14             	add    $0x14,%esp
f010765b:	5e                   	pop    %esi
f010765c:	5f                   	pop    %edi
f010765d:	5d                   	pop    %ebp
f010765e:	c3                   	ret    
f010765f:	90                   	nop
f0107660:	39 d7                	cmp    %edx,%edi
f0107662:	75 da                	jne    f010763e <__umoddi3+0x10e>
f0107664:	8b 14 24             	mov    (%esp),%edx
f0107667:	89 c1                	mov    %eax,%ecx
f0107669:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010766d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0107671:	eb cb                	jmp    f010763e <__umoddi3+0x10e>
f0107673:	90                   	nop
f0107674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107678:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010767c:	0f 82 0f ff ff ff    	jb     f0107591 <__umoddi3+0x61>
f0107682:	e9 1a ff ff ff       	jmp    f01075a1 <__umoddi3+0x71>
