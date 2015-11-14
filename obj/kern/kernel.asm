
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
f010005f:	e8 55 70 00 00       	call   f01070b9 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 a0 77 10 f0 	movl   $0xf01077a0,(%esp)
f010007d:	e8 01 40 00 00       	call   f0104083 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 8f 3f 00 00       	call   f010401d <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 e9 89 10 f0 	movl   $0xf01089e9,(%esp)
f0100095:	e8 e9 3f 00 00       	call   f0104083 <cprintf>
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
f01000cc:	e8 96 69 00 00       	call   f0106a67 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d1:	e8 a9 05 00 00       	call   f010067f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 0c 78 10 f0 	movl   $0xf010780c,(%esp)
f01000e5:	e8 99 3f 00 00       	call   f0104083 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ea:	e8 6f 14 00 00       	call   f010155e <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000ef:	e8 d4 36 00 00       	call   f01037c8 <env_init>
	trap_init();
f01000f4:	e8 bf 40 00 00       	call   f01041b8 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000f9:	e8 ac 6c 00 00       	call   f0106daa <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 cf 6f 00 00       	call   f01070d4 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100105:	e8 76 3e 00 00       	call   f0103f80 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0100111:	e8 21 72 00 00       	call   f0107337 <spin_lock>
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
f0100127:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 27 78 10 f0 	movl   $0xf0107827,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 e2 6c 10 f0       	mov    $0xf0106ce2,%eax
f0100148:	2d 68 6c 10 f0       	sub    $0xf0106c68,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 68 6c 10 	movl   $0xf0106c68,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 4f 69 00 00       	call   f0106ab4 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100165:	bb 20 10 24 f0       	mov    $0xf0241020,%ebx
f010016a:	eb 4d                	jmp    f01001b9 <i386_init+0x111>
		if (c == cpus + cpunum())  // We've started already.
f010016c:	e8 48 6f 00 00       	call   f01070b9 <cpunum>
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
f01001a9:	e8 76 70 00 00       	call   f0107224 <lapic_startap>
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
f01001d1:	c7 04 24 c6 40 23 f0 	movl   $0xf02340c6,(%esp)
f01001d8:	e8 0d 38 00 00       	call   f01039ea <env_create>
	// Touch all you want.
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001dd:	e8 c2 4e 00 00       	call   f01050a4 <sched_yield>

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
f01001f8:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f01001ff:	f0 
f0100200:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
f0100207:	00 
f0100208:	c7 04 24 27 78 10 f0 	movl   $0xf0107827,(%esp)
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
f010021c:	e8 98 6e 00 00       	call   f01070b9 <cpunum>
f0100221:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100225:	c7 04 24 33 78 10 f0 	movl   $0xf0107833,(%esp)
f010022c:	e8 52 3e 00 00       	call   f0104083 <cprintf>

	lapic_init();
f0100231:	e8 9e 6e 00 00       	call   f01070d4 <lapic_init>
	env_init_percpu();
f0100236:	e8 63 35 00 00       	call   f010379e <env_init_percpu>
	trap_init_percpu();
f010023b:	90                   	nop
f010023c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100240:	e8 7b 3e 00 00       	call   f01040c0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100245:	e8 6f 6e 00 00       	call   f01070b9 <cpunum>
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
f0100263:	e8 cf 70 00 00       	call   f0107337 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100268:	e8 37 4e 00 00       	call   f01050a4 <sched_yield>

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
f0100285:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010028c:	e8 f2 3d 00 00       	call   f0104083 <cprintf>
	vcprintf(fmt, ap);
f0100291:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100295:	8b 45 10             	mov    0x10(%ebp),%eax
f0100298:	89 04 24             	mov    %eax,(%esp)
f010029b:	e8 7d 3d 00 00       	call   f010401d <vcprintf>
	cprintf("\n");
f01002a0:	c7 04 24 e9 89 10 f0 	movl   $0xf01089e9,(%esp)
f01002a7:	e8 d7 3d 00 00       	call   f0104083 <cprintf>
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
f0100365:	0f b6 82 c0 79 10 f0 	movzbl -0xfef8640(%edx),%eax
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
f01003a2:	0f b6 82 c0 79 10 f0 	movzbl -0xfef8640(%edx),%eax
f01003a9:	0b 05 00 f0 23 f0    	or     0xf023f000,%eax
	shift ^= togglecode[data];
f01003af:	0f b6 8a c0 78 10 f0 	movzbl -0xfef8740(%edx),%ecx
f01003b6:	31 c8                	xor    %ecx,%eax
f01003b8:	a3 00 f0 23 f0       	mov    %eax,0xf023f000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003bd:	89 c1                	mov    %eax,%ecx
f01003bf:	83 e1 03             	and    $0x3,%ecx
f01003c2:	8b 0c 8d a0 78 10 f0 	mov    -0xfef8760(,%ecx,4),%ecx
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
f0100402:	c7 04 24 63 78 10 f0 	movl   $0xf0107863,(%esp)
f0100409:	e8 75 3c 00 00       	call   f0104083 <cprintf>
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
f01005a9:	e8 06 65 00 00       	call   f0106ab4 <memmove>
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
f0100717:	e8 f5 37 00 00       	call   f0103f11 <irq_setmask_8259A>
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
f0100776:	c7 04 24 6f 78 10 f0 	movl   $0xf010786f,(%esp)
f010077d:	e8 01 39 00 00       	call   f0104083 <cprintf>
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
f01007c6:	c7 44 24 08 c0 7a 10 	movl   $0xf0107ac0,0x8(%esp)
f01007cd:	f0 
f01007ce:	c7 44 24 04 de 7a 10 	movl   $0xf0107ade,0x4(%esp)
f01007d5:	f0 
f01007d6:	c7 04 24 e3 7a 10 f0 	movl   $0xf0107ae3,(%esp)
f01007dd:	e8 a1 38 00 00       	call   f0104083 <cprintf>
f01007e2:	c7 44 24 08 90 7b 10 	movl   $0xf0107b90,0x8(%esp)
f01007e9:	f0 
f01007ea:	c7 44 24 04 ec 7a 10 	movl   $0xf0107aec,0x4(%esp)
f01007f1:	f0 
f01007f2:	c7 04 24 e3 7a 10 f0 	movl   $0xf0107ae3,(%esp)
f01007f9:	e8 85 38 00 00       	call   f0104083 <cprintf>
f01007fe:	c7 44 24 08 b8 7b 10 	movl   $0xf0107bb8,0x8(%esp)
f0100805:	f0 
f0100806:	c7 44 24 04 f5 7a 10 	movl   $0xf0107af5,0x4(%esp)
f010080d:	f0 
f010080e:	c7 04 24 e3 7a 10 f0 	movl   $0xf0107ae3,(%esp)
f0100815:	e8 69 38 00 00       	call   f0104083 <cprintf>
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
f0100827:	c7 04 24 ff 7a 10 f0 	movl   $0xf0107aff,(%esp)
f010082e:	e8 50 38 00 00       	call   f0104083 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100833:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010083a:	00 
f010083b:	c7 04 24 dc 7b 10 f0 	movl   $0xf0107bdc,(%esp)
f0100842:	e8 3c 38 00 00       	call   f0104083 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100847:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010084e:	00 
f010084f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100856:	f0 
f0100857:	c7 04 24 04 7c 10 f0 	movl   $0xf0107c04,(%esp)
f010085e:	e8 20 38 00 00       	call   f0104083 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100863:	c7 44 24 08 87 77 10 	movl   $0x107787,0x8(%esp)
f010086a:	00 
f010086b:	c7 44 24 04 87 77 10 	movl   $0xf0107787,0x4(%esp)
f0100872:	f0 
f0100873:	c7 04 24 28 7c 10 f0 	movl   $0xf0107c28,(%esp)
f010087a:	e8 04 38 00 00       	call   f0104083 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010087f:	c7 44 24 08 b9 eb 23 	movl   $0x23ebb9,0x8(%esp)
f0100886:	00 
f0100887:	c7 44 24 04 b9 eb 23 	movl   $0xf023ebb9,0x4(%esp)
f010088e:	f0 
f010088f:	c7 04 24 4c 7c 10 f0 	movl   $0xf0107c4c,(%esp)
f0100896:	e8 e8 37 00 00       	call   f0104083 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010089b:	c7 44 24 08 08 20 28 	movl   $0x282008,0x8(%esp)
f01008a2:	00 
f01008a3:	c7 44 24 04 08 20 28 	movl   $0xf0282008,0x4(%esp)
f01008aa:	f0 
f01008ab:	c7 04 24 70 7c 10 f0 	movl   $0xf0107c70,(%esp)
f01008b2:	e8 cc 37 00 00       	call   f0104083 <cprintf>
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
f01008d8:	c7 04 24 94 7c 10 f0 	movl   $0xf0107c94,(%esp)
f01008df:	e8 9f 37 00 00       	call   f0104083 <cprintf>
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
f01008fe:	c7 04 24 19 7b 10 f0 	movl   $0xf0107b19,(%esp)
f0100905:	e8 93 37 00 00       	call   f010409d <ccprintf>
	while ( ( tmp_ebp ) != 0 )  {
f010090a:	e9 d6 00 00 00       	jmp    f01009e5 <mon_backtrace+0xfa>
		ccprintf("  ebp %08x",0x12 ,(int)(tmp_ebp) );
f010090f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100913:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
f010091a:	00 
f010091b:	c7 04 24 2b 7b 10 f0 	movl   $0xf0107b2b,(%esp)
f0100922:	e8 76 37 00 00       	call   f010409d <ccprintf>
                ccprintf("  eip %08x",0x24,*(tmp_ebp+1) );
f0100927:	8b 43 04             	mov    0x4(%ebx),%eax
f010092a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010092e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
f0100935:	00 
f0100936:	c7 04 24 36 7b 10 f0 	movl   $0xf0107b36,(%esp)
f010093d:	e8 5b 37 00 00       	call   f010409d <ccprintf>
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
f010096d:	c7 04 24 c0 7c 10 f0 	movl   $0xf0107cc0,(%esp)
f0100974:	e8 24 37 00 00       	call   f010409d <ccprintf>
                *(tmp_ebp+2) , *(tmp_ebp+3) , *(tmp_ebp+4) , *(tmp_ebp+5) , *(tmp_ebp+6) );
		
                struct Eipdebuginfo eip_info ;
		debuginfo_eip( (*(tmp_ebp+1))-5 , &eip_info ) ; 
f0100979:	8b 43 04             	mov    0x4(%ebx),%eax
f010097c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010097f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100983:	83 e8 05             	sub    $0x5,%eax
f0100986:	89 04 24             	mov    %eax,(%esp)
f0100989:	e8 8e 50 00 00       	call   f0105a1c <debuginfo_eip>
                ccprintf("%s:%d:",0x35,eip_info.eip_file, eip_info.eip_line);
f010098e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100991:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100995:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100998:	89 44 24 08          	mov    %eax,0x8(%esp)
f010099c:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
f01009a3:	00 
f01009a4:	c7 04 24 41 7b 10 f0 	movl   $0xf0107b41,(%esp)
f01009ab:	e8 ed 36 00 00       	call   f010409d <ccprintf>
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
f01009d7:	c7 04 24 48 7b 10 f0 	movl   $0xf0107b48,(%esp)
f01009de:	e8 ba 36 00 00       	call   f010409d <ccprintf>
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
f0100a03:	c7 04 24 e4 7c 10 f0 	movl   $0xf0107ce4,(%esp)
f0100a0a:	e8 74 36 00 00       	call   f0104083 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a0f:	c7 04 24 08 7d 10 f0 	movl   $0xf0107d08,(%esp)
f0100a16:	e8 68 36 00 00       	call   f0104083 <cprintf>

	if (tf != NULL)
f0100a1b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100a1f:	74 0b                	je     f0100a2c <monitor+0x32>
		print_trapframe(tf);
f0100a21:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a24:	89 04 24             	mov    %eax,(%esp)
f0100a27:	e8 43 3e 00 00       	call   f010486f <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100a2c:	c7 04 24 52 7b 10 f0 	movl   $0xf0107b52,(%esp)
f0100a33:	e8 d8 5d 00 00       	call   f0106810 <readline>
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
f0100a64:	c7 04 24 56 7b 10 f0 	movl   $0xf0107b56,(%esp)
f0100a6b:	e8 ba 5f 00 00       	call   f0106a2a <strchr>
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
f0100a86:	c7 04 24 5b 7b 10 f0 	movl   $0xf0107b5b,(%esp)
f0100a8d:	e8 f1 35 00 00       	call   f0104083 <cprintf>
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
f0100aae:	c7 04 24 56 7b 10 f0 	movl   $0xf0107b56,(%esp)
f0100ab5:	e8 70 5f 00 00       	call   f0106a2a <strchr>
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
f0100ad8:	8b 04 85 40 7d 10 f0 	mov    -0xfef82c0(,%eax,4),%eax
f0100adf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae3:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ae6:	89 04 24             	mov    %eax,(%esp)
f0100ae9:	e8 de 5e 00 00       	call   f01069cc <strcmp>
f0100aee:	85 c0                	test   %eax,%eax
f0100af0:	75 24                	jne    f0100b16 <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100af2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100af5:	8b 55 08             	mov    0x8(%ebp),%edx
f0100af8:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100afc:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100aff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100b03:	89 34 24             	mov    %esi,(%esp)
f0100b06:	ff 14 85 48 7d 10 f0 	call   *-0xfef82b8(,%eax,4)
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
f0100b25:	c7 04 24 78 7b 10 f0 	movl   $0xf0107b78,(%esp)
f0100b2c:	e8 52 35 00 00       	call   f0104083 <cprintf>
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
f0100b63:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0100b6a:	f0 
f0100b6b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100b72:	00 
f0100b73:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
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
f0100bbf:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0100bc6:	f0 
f0100bc7:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0100bce:	00 
f0100bcf:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0100c50:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0100c57:	f0 
f0100c58:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f0100c5f:	00 
f0100c60:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0100c67:	e8 d4 f3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100c6c:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
	if ( PGNUM(PADDR(p_nextfree)) > npages ) 
f0100c72:	c1 e8 0c             	shr    $0xc,%eax
f0100c75:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0100c7b:	76 1c                	jbe    f0100c99 <boot_alloc+0x93>
		panic("boot_alloc: Run out of physical memory\n");
f0100c7d:	c7 44 24 08 64 7d 10 	movl   $0xf0107d64,0x8(%esp)
f0100c84:	f0 
f0100c85:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
f0100c8c:	00 
f0100c8d:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0100cb9:	c7 44 24 08 8c 7d 10 	movl   $0xf0107d8c,0x8(%esp)
f0100cc0:	f0 
f0100cc1:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f0100cc8:	00 
f0100cc9:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0100d53:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0100d5a:	f0 
f0100d5b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d62:	00 
f0100d63:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
f0100d6a:	e8 d1 f2 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d6f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100d76:	00 
f0100d77:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d7e:	00 
	return (void *)(pa + KERNBASE);
f0100d7f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d84:	89 04 24             	mov    %eax,(%esp)
f0100d87:	e8 db 5c 00 00       	call   f0106a67 <memset>
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
f0100dce:	c7 44 24 0c 23 87 10 	movl   $0xf0108723,0xc(%esp)
f0100dd5:	f0 
f0100dd6:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100ddd:	f0 
f0100dde:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f0100de5:	00 
f0100de6:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0100ded:	e8 4e f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100df2:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100df5:	72 24                	jb     f0100e1b <check_page_free_list+0x178>
f0100df7:	c7 44 24 0c 44 87 10 	movl   $0xf0108744,0xc(%esp)
f0100dfe:	f0 
f0100dff:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100e06:	f0 
f0100e07:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100e0e:	00 
f0100e0f:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0100e16:	e8 25 f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e1b:	89 d0                	mov    %edx,%eax
f0100e1d:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100e20:	a8 07                	test   $0x7,%al
f0100e22:	74 24                	je     f0100e48 <check_page_free_list+0x1a5>
f0100e24:	c7 44 24 0c b0 7d 10 	movl   $0xf0107db0,0xc(%esp)
f0100e2b:	f0 
f0100e2c:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100e33:	f0 
f0100e34:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0100e3b:	00 
f0100e3c:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0100e52:	c7 44 24 0c 58 87 10 	movl   $0xf0108758,0xc(%esp)
f0100e59:	f0 
f0100e5a:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100e61:	f0 
f0100e62:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0100e69:	00 
f0100e6a:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0100e71:	e8 ca f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e76:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e7b:	75 24                	jne    f0100ea1 <check_page_free_list+0x1fe>
f0100e7d:	c7 44 24 0c 69 87 10 	movl   $0xf0108769,0xc(%esp)
f0100e84:	f0 
f0100e85:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100e8c:	f0 
f0100e8d:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0100e94:	00 
f0100e95:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0100e9c:	e8 9f f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ea1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ea6:	75 24                	jne    f0100ecc <check_page_free_list+0x229>
f0100ea8:	c7 44 24 0c e4 7d 10 	movl   $0xf0107de4,0xc(%esp)
f0100eaf:	f0 
f0100eb0:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100eb7:	f0 
f0100eb8:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0100ebf:	00 
f0100ec0:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0100ec7:	e8 74 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ecc:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ed1:	75 24                	jne    f0100ef7 <check_page_free_list+0x254>
f0100ed3:	c7 44 24 0c 82 87 10 	movl   $0xf0108782,0xc(%esp)
f0100eda:	f0 
f0100edb:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100ee2:	f0 
f0100ee3:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0100eea:	00 
f0100eeb:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0100f10:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0100f17:	f0 
f0100f18:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f1f:	00 
f0100f20:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
f0100f27:	e8 14 f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100f2c:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100f32:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100f35:	0f 86 d3 00 00 00    	jbe    f010100e <check_page_free_list+0x36b>
f0100f3b:	c7 44 24 0c 08 7e 10 	movl   $0xf0107e08,0xc(%esp)
f0100f42:	f0 
f0100f43:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100f4a:	f0 
f0100f4b:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f0100f52:	00 
f0100f53:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0100f5a:	e8 e1 f0 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f5f:	c7 44 24 0c 9c 87 10 	movl   $0xf010879c,0xc(%esp)
f0100f66:	f0 
f0100f67:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100f6e:	f0 
f0100f6f:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0100f76:	00 
f0100f77:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0100f99:	c7 44 24 0c b9 87 10 	movl   $0xf01087b9,0xc(%esp)
f0100fa0:	f0 
f0100fa1:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100fa8:	f0 
f0100fa9:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0100fb0:	00 
f0100fb1:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0100fb8:	e8 83 f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100fbd:	85 ff                	test   %edi,%edi
f0100fbf:	7f 6d                	jg     f010102e <check_page_free_list+0x38b>
f0100fc1:	c7 44 24 0c cb 87 10 	movl   $0xf01087cb,0xc(%esp)
f0100fc8:	f0 
f0100fc9:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0100fd0:	f0 
f0100fd1:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0100fd8:	00 
f0100fd9:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01010d2:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f01010d9:	f0 
f01010da:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
f01010e1:	00 
f01010e2:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01011ac:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f01011b3:	f0 
f01011b4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01011bb:	00 
f01011bc:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
f01011c3:	e8 78 ee ff ff       	call   f0100040 <_panic>
		memset( page2kva(rtn)  , 0 , PGSIZE ) ; 
f01011c8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011cf:	00 
f01011d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011d7:	00 
	return (void *)(pa + KERNBASE);
f01011d8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011dd:	89 04 24             	mov    %eax,(%esp)
f01011e0:	e8 82 58 00 00       	call   f0106a67 <memset>
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
f0101204:	c7 44 24 08 50 7e 10 	movl   $0xf0107e50,0x8(%esp)
f010120b:	f0 
f010120c:	c7 44 24 04 8c 01 00 	movl   $0x18c,0x4(%esp)
f0101213:	00 
f0101214:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f010121b:	e8 20 ee ff ff       	call   f0100040 <_panic>
 	if ( pp->pp_link != 0 ) 
f0101220:	83 38 00             	cmpl   $0x0,(%eax)
f0101223:	74 1c                	je     f0101241 <page_free+0x4d>
		panic("page_free: Page Link is not NULL\n");
f0101225:	c7 44 24 08 7c 7e 10 	movl   $0xf0107e7c,0x8(%esp)
f010122c:	f0 
f010122d:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f0101234:	00 
f0101235:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01012d5:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f01012dc:	f0 
f01012dd:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
f01012e4:	00 
f01012e5:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01013b3:	c7 44 24 08 a0 7e 10 	movl   $0xf0107ea0,0x8(%esp)
f01013ba:	f0 
f01013bb:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01013c2:	00 
f01013c3:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
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
f01013f2:	e8 c2 5c 00 00       	call   f01070b9 <cpunum>
f01013f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01013fa:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0101401:	74 16                	je     f0101419 <tlb_invalidate+0x2d>
f0101403:	e8 b1 5c 00 00       	call   f01070b9 <cpunum>
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
f0101515:	c7 44 24 08 c0 7e 10 	movl   $0xf0107ec0,0x8(%esp)
f010151c:	f0 
f010151d:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0101524:	00 
f0101525:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101575:	e8 6d 29 00 00       	call   f0103ee7 <mc146818_read>
f010157a:	89 c3                	mov    %eax,%ebx
f010157c:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101583:	e8 5f 29 00 00       	call   f0103ee7 <mc146818_read>
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
f01015ac:	e8 36 29 00 00       	call   f0103ee7 <mc146818_read>
f01015b1:	89 c3                	mov    %eax,%ebx
f01015b3:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01015ba:	e8 28 29 00 00       	call   f0103ee7 <mc146818_read>
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
f010161d:	c7 04 24 f0 7e 10 f0 	movl   $0xf0107ef0,(%esp)
f0101624:	e8 5a 2a 00 00       	call   f0104083 <cprintf>
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
f010164b:	e8 17 54 00 00       	call   f0106a67 <memset>
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
f0101660:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0101667:	f0 
f0101668:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010166f:	00 
f0101670:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01016b9:	e8 a9 53 00 00       	call   f0106a67 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = ( struct Env * ) boot_alloc( sizeof( struct Env ) * NENV ) ; 
f01016be:	b8 00 20 02 00       	mov    $0x22000,%eax
f01016c3:	e8 3e f5 ff ff       	call   f0100c06 <boot_alloc>
f01016c8:	a3 48 f2 23 f0       	mov    %eax,0xf023f248
	memset( envs , 0 , sizeof( struct Env ) * NENV ) ; 
f01016cd:	c7 44 24 08 00 20 02 	movl   $0x22000,0x8(%esp)
f01016d4:	00 
f01016d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01016dc:	00 
f01016dd:	89 04 24             	mov    %eax,(%esp)
f01016e0:	e8 82 53 00 00       	call   f0106a67 <memset>
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
f01016fd:	c7 44 24 08 dc 87 10 	movl   $0xf01087dc,0x8(%esp)
f0101704:	f0 
f0101705:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f010170c:	00 
f010170d:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101740:	c7 44 24 0c f7 87 10 	movl   $0xf01087f7,0xc(%esp)
f0101747:	f0 
f0101748:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010174f:	f0 
f0101750:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0101757:	00 
f0101758:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f010175f:	e8 dc e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101764:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010176b:	e8 f9 f9 ff ff       	call   f0101169 <page_alloc>
f0101770:	89 c6                	mov    %eax,%esi
f0101772:	85 c0                	test   %eax,%eax
f0101774:	75 24                	jne    f010179a <mem_init+0x23c>
f0101776:	c7 44 24 0c 0d 88 10 	movl   $0xf010880d,0xc(%esp)
f010177d:	f0 
f010177e:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101785:	f0 
f0101786:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f010178d:	00 
f010178e:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101795:	e8 a6 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010179a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a1:	e8 c3 f9 ff ff       	call   f0101169 <page_alloc>
f01017a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017a9:	85 c0                	test   %eax,%eax
f01017ab:	75 24                	jne    f01017d1 <mem_init+0x273>
f01017ad:	c7 44 24 0c 23 88 10 	movl   $0xf0108823,0xc(%esp)
f01017b4:	f0 
f01017b5:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01017bc:	f0 
f01017bd:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f01017c4:	00 
f01017c5:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01017cc:	e8 6f e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017d1:	39 f7                	cmp    %esi,%edi
f01017d3:	75 24                	jne    f01017f9 <mem_init+0x29b>
f01017d5:	c7 44 24 0c 39 88 10 	movl   $0xf0108839,0xc(%esp)
f01017dc:	f0 
f01017dd:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01017e4:	f0 
f01017e5:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01017ec:	00 
f01017ed:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01017f4:	e8 47 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017fc:	39 c6                	cmp    %eax,%esi
f01017fe:	74 04                	je     f0101804 <mem_init+0x2a6>
f0101800:	39 c7                	cmp    %eax,%edi
f0101802:	75 24                	jne    f0101828 <mem_init+0x2ca>
f0101804:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f010180b:	f0 
f010180c:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101813:	f0 
f0101814:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f010181b:	00 
f010181c:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101844:	c7 44 24 0c 4b 88 10 	movl   $0xf010884b,0xc(%esp)
f010184b:	f0 
f010184c:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101853:	f0 
f0101854:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f010185b:	00 
f010185c:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101863:	e8 d8 e7 ff ff       	call   f0100040 <_panic>
f0101868:	89 f1                	mov    %esi,%ecx
f010186a:	29 d1                	sub    %edx,%ecx
f010186c:	c1 f9 03             	sar    $0x3,%ecx
f010186f:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101872:	39 c8                	cmp    %ecx,%eax
f0101874:	77 24                	ja     f010189a <mem_init+0x33c>
f0101876:	c7 44 24 0c 68 88 10 	movl   $0xf0108868,0xc(%esp)
f010187d:	f0 
f010187e:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101885:	f0 
f0101886:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f010188d:	00 
f010188e:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101895:	e8 a6 e7 ff ff       	call   f0100040 <_panic>
f010189a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010189d:	29 d1                	sub    %edx,%ecx
f010189f:	89 ca                	mov    %ecx,%edx
f01018a1:	c1 fa 03             	sar    $0x3,%edx
f01018a4:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01018a7:	39 d0                	cmp    %edx,%eax
f01018a9:	77 24                	ja     f01018cf <mem_init+0x371>
f01018ab:	c7 44 24 0c 85 88 10 	movl   $0xf0108885,0xc(%esp)
f01018b2:	f0 
f01018b3:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01018ba:	f0 
f01018bb:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01018c2:	00 
f01018c3:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01018f1:	c7 44 24 0c a2 88 10 	movl   $0xf01088a2,0xc(%esp)
f01018f8:	f0 
f01018f9:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101900:	f0 
f0101901:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0101908:	00 
f0101909:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101942:	c7 44 24 0c f7 87 10 	movl   $0xf01087f7,0xc(%esp)
f0101949:	f0 
f010194a:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101951:	f0 
f0101952:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101959:	00 
f010195a:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101961:	e8 da e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101966:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010196d:	e8 f7 f7 ff ff       	call   f0101169 <page_alloc>
f0101972:	89 c7                	mov    %eax,%edi
f0101974:	85 c0                	test   %eax,%eax
f0101976:	75 24                	jne    f010199c <mem_init+0x43e>
f0101978:	c7 44 24 0c 0d 88 10 	movl   $0xf010880d,0xc(%esp)
f010197f:	f0 
f0101980:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101987:	f0 
f0101988:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f010198f:	00 
f0101990:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101997:	e8 a4 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010199c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019a3:	e8 c1 f7 ff ff       	call   f0101169 <page_alloc>
f01019a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019ab:	85 c0                	test   %eax,%eax
f01019ad:	75 24                	jne    f01019d3 <mem_init+0x475>
f01019af:	c7 44 24 0c 23 88 10 	movl   $0xf0108823,0xc(%esp)
f01019b6:	f0 
f01019b7:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01019be:	f0 
f01019bf:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f01019c6:	00 
f01019c7:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01019ce:	e8 6d e6 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019d3:	39 fe                	cmp    %edi,%esi
f01019d5:	75 24                	jne    f01019fb <mem_init+0x49d>
f01019d7:	c7 44 24 0c 39 88 10 	movl   $0xf0108839,0xc(%esp)
f01019de:	f0 
f01019df:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01019e6:	f0 
f01019e7:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f01019ee:	00 
f01019ef:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01019f6:	e8 45 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019fe:	39 c7                	cmp    %eax,%edi
f0101a00:	74 04                	je     f0101a06 <mem_init+0x4a8>
f0101a02:	39 c6                	cmp    %eax,%esi
f0101a04:	75 24                	jne    f0101a2a <mem_init+0x4cc>
f0101a06:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f0101a0d:	f0 
f0101a0e:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101a15:	f0 
f0101a16:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101a1d:	00 
f0101a1e:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101a25:	e8 16 e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101a2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a31:	e8 33 f7 ff ff       	call   f0101169 <page_alloc>
f0101a36:	85 c0                	test   %eax,%eax
f0101a38:	74 24                	je     f0101a5e <mem_init+0x500>
f0101a3a:	c7 44 24 0c a2 88 10 	movl   $0xf01088a2,0xc(%esp)
f0101a41:	f0 
f0101a42:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101a49:	f0 
f0101a4a:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0101a51:	00 
f0101a52:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101a7d:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0101a84:	f0 
f0101a85:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101a8c:	00 
f0101a8d:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
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
f0101ab1:	e8 b1 4f 00 00       	call   f0106a67 <memset>
	page_free(pp0);
f0101ab6:	89 34 24             	mov    %esi,(%esp)
f0101ab9:	e8 36 f7 ff ff       	call   f01011f4 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101abe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101ac5:	e8 9f f6 ff ff       	call   f0101169 <page_alloc>
f0101aca:	85 c0                	test   %eax,%eax
f0101acc:	75 24                	jne    f0101af2 <mem_init+0x594>
f0101ace:	c7 44 24 0c b1 88 10 	movl   $0xf01088b1,0xc(%esp)
f0101ad5:	f0 
f0101ad6:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101add:	f0 
f0101ade:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101ae5:	00 
f0101ae6:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101aed:	e8 4e e5 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101af2:	39 c6                	cmp    %eax,%esi
f0101af4:	74 24                	je     f0101b1a <mem_init+0x5bc>
f0101af6:	c7 44 24 0c cf 88 10 	movl   $0xf01088cf,0xc(%esp)
f0101afd:	f0 
f0101afe:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101b05:	f0 
f0101b06:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101b0d:	00 
f0101b0e:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101b39:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0101b40:	f0 
f0101b41:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101b48:	00 
f0101b49:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
f0101b50:	e8 eb e4 ff ff       	call   f0100040 <_panic>
f0101b55:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101b5b:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b61:	80 38 00             	cmpb   $0x0,(%eax)
f0101b64:	74 24                	je     f0101b8a <mem_init+0x62c>
f0101b66:	c7 44 24 0c df 88 10 	movl   $0xf01088df,0xc(%esp)
f0101b6d:	f0 
f0101b6e:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101b75:	f0 
f0101b76:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101b7d:	00 
f0101b7e:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101bc8:	c7 44 24 0c e9 88 10 	movl   $0xf01088e9,0xc(%esp)
f0101bcf:	f0 
f0101bd0:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101bd7:	f0 
f0101bd8:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101bdf:	00 
f0101be0:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101be7:	e8 54 e4 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101bec:	c7 04 24 4c 7f 10 f0 	movl   $0xf0107f4c,(%esp)
f0101bf3:	e8 8b 24 00 00       	call   f0104083 <cprintf>
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
f0101c0b:	c7 44 24 0c f7 87 10 	movl   $0xf01087f7,0xc(%esp)
f0101c12:	f0 
f0101c13:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101c1a:	f0 
f0101c1b:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0101c22:	00 
f0101c23:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101c2a:	e8 11 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c36:	e8 2e f5 ff ff       	call   f0101169 <page_alloc>
f0101c3b:	89 c3                	mov    %eax,%ebx
f0101c3d:	85 c0                	test   %eax,%eax
f0101c3f:	75 24                	jne    f0101c65 <mem_init+0x707>
f0101c41:	c7 44 24 0c 0d 88 10 	movl   $0xf010880d,0xc(%esp)
f0101c48:	f0 
f0101c49:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101c50:	f0 
f0101c51:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101c58:	00 
f0101c59:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101c60:	e8 db e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c6c:	e8 f8 f4 ff ff       	call   f0101169 <page_alloc>
f0101c71:	89 c6                	mov    %eax,%esi
f0101c73:	85 c0                	test   %eax,%eax
f0101c75:	75 24                	jne    f0101c9b <mem_init+0x73d>
f0101c77:	c7 44 24 0c 23 88 10 	movl   $0xf0108823,0xc(%esp)
f0101c7e:	f0 
f0101c7f:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101c86:	f0 
f0101c87:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101c8e:	00 
f0101c8f:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101c96:	e8 a5 e3 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c9b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101c9e:	75 24                	jne    f0101cc4 <mem_init+0x766>
f0101ca0:	c7 44 24 0c 39 88 10 	movl   $0xf0108839,0xc(%esp)
f0101ca7:	f0 
f0101ca8:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101caf:	f0 
f0101cb0:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101cb7:	00 
f0101cb8:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101cbf:	e8 7c e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cc4:	39 c3                	cmp    %eax,%ebx
f0101cc6:	74 05                	je     f0101ccd <mem_init+0x76f>
f0101cc8:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101ccb:	75 24                	jne    f0101cf1 <mem_init+0x793>
f0101ccd:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f0101cd4:	f0 
f0101cd5:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101cdc:	f0 
f0101cdd:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0101ce4:	00 
f0101ce5:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101d13:	c7 44 24 0c a2 88 10 	movl   $0xf01088a2,0xc(%esp)
f0101d1a:	f0 
f0101d1b:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f0101d2a:	00 
f0101d2b:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101d57:	c7 44 24 0c 6c 7f 10 	movl   $0xf0107f6c,0xc(%esp)
f0101d5e:	f0 
f0101d5f:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101d66:	f0 
f0101d67:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101d6e:	00 
f0101d6f:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101da0:	c7 44 24 0c a4 7f 10 	movl   $0xf0107fa4,0xc(%esp)
f0101da7:	f0 
f0101da8:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101daf:	f0 
f0101db0:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101db7:	00 
f0101db8:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101df4:	c7 44 24 0c d4 7f 10 	movl   $0xf0107fd4,0xc(%esp)
f0101dfb:	f0 
f0101dfc:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101e03:	f0 
f0101e04:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101e0b:	00 
f0101e0c:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101e3f:	c7 44 24 0c 04 80 10 	movl   $0xf0108004,0xc(%esp)
f0101e46:	f0 
f0101e47:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101e4e:	f0 
f0101e4f:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0101e56:	00 
f0101e57:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101e7e:	c7 44 24 0c 2c 80 10 	movl   $0xf010802c,0xc(%esp)
f0101e85:	f0 
f0101e86:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101e8d:	f0 
f0101e8e:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0101e95:	00 
f0101e96:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101e9d:	e8 9e e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ea2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ea7:	74 24                	je     f0101ecd <mem_init+0x96f>
f0101ea9:	c7 44 24 0c f4 88 10 	movl   $0xf01088f4,0xc(%esp)
f0101eb0:	f0 
f0101eb1:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101eb8:	f0 
f0101eb9:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101ec0:	00 
f0101ec1:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101ec8:	e8 73 e1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ecd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ed0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ed5:	74 24                	je     f0101efb <mem_init+0x99d>
f0101ed7:	c7 44 24 0c 05 89 10 	movl   $0xf0108905,0xc(%esp)
f0101ede:	f0 
f0101edf:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101ee6:	f0 
f0101ee7:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101eee:	00 
f0101eef:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101f1b:	c7 44 24 0c 5c 80 10 	movl   $0xf010805c,0xc(%esp)
f0101f22:	f0 
f0101f23:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101f2a:	f0 
f0101f2b:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101f32:	00 
f0101f33:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0101f60:	c7 44 24 0c 98 80 10 	movl   $0xf0108098,0xc(%esp)
f0101f67:	f0 
f0101f68:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101f6f:	f0 
f0101f70:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101f77:	00 
f0101f78:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101f7f:	e8 bc e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f84:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f89:	74 24                	je     f0101faf <mem_init+0xa51>
f0101f8b:	c7 44 24 0c 16 89 10 	movl   $0xf0108916,0xc(%esp)
f0101f92:	f0 
f0101f93:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101f9a:	f0 
f0101f9b:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101fa2:	00 
f0101fa3:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0101faa:	e8 91 e0 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101faf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fb6:	e8 ae f1 ff ff       	call   f0101169 <page_alloc>
f0101fbb:	85 c0                	test   %eax,%eax
f0101fbd:	74 24                	je     f0101fe3 <mem_init+0xa85>
f0101fbf:	c7 44 24 0c a2 88 10 	movl   $0xf01088a2,0xc(%esp)
f0101fc6:	f0 
f0101fc7:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0101fce:	f0 
f0101fcf:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101fd6:	00 
f0101fd7:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102008:	c7 44 24 0c 5c 80 10 	movl   $0xf010805c,0xc(%esp)
f010200f:	f0 
f0102010:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102017:	f0 
f0102018:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f010201f:	00 
f0102020:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f010204d:	c7 44 24 0c 98 80 10 	movl   $0xf0108098,0xc(%esp)
f0102054:	f0 
f0102055:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010205c:	f0 
f010205d:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102064:	00 
f0102065:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f010206c:	e8 cf df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102071:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102076:	74 24                	je     f010209c <mem_init+0xb3e>
f0102078:	c7 44 24 0c 16 89 10 	movl   $0xf0108916,0xc(%esp)
f010207f:	f0 
f0102080:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102087:	f0 
f0102088:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f010208f:	00 
f0102090:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102097:	e8 a4 df ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010209c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020a3:	e8 c1 f0 ff ff       	call   f0101169 <page_alloc>
f01020a8:	85 c0                	test   %eax,%eax
f01020aa:	74 24                	je     f01020d0 <mem_init+0xb72>
f01020ac:	c7 44 24 0c a2 88 10 	movl   $0xf01088a2,0xc(%esp)
f01020b3:	f0 
f01020b4:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01020bb:	f0 
f01020bc:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f01020c3:	00 
f01020c4:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01020ee:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f01020f5:	f0 
f01020f6:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f01020fd:	00 
f01020fe:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102134:	c7 44 24 0c c8 80 10 	movl   $0xf01080c8,0xc(%esp)
f010213b:	f0 
f010213c:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102143:	f0 
f0102144:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f010214b:	00 
f010214c:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f010217d:	c7 44 24 0c 08 81 10 	movl   $0xf0108108,0xc(%esp)
f0102184:	f0 
f0102185:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010218c:	f0 
f010218d:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102194:	00 
f0102195:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01021c5:	c7 44 24 0c 98 80 10 	movl   $0xf0108098,0xc(%esp)
f01021cc:	f0 
f01021cd:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01021d4:	f0 
f01021d5:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f01021dc:	00 
f01021dd:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01021e4:	e8 57 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01021e9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021ee:	74 24                	je     f0102214 <mem_init+0xcb6>
f01021f0:	c7 44 24 0c 16 89 10 	movl   $0xf0108916,0xc(%esp)
f01021f7:	f0 
f01021f8:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01021ff:	f0 
f0102200:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102207:	00 
f0102208:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102231:	c7 44 24 0c 48 81 10 	movl   $0xf0108148,0xc(%esp)
f0102238:	f0 
f0102239:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102240:	f0 
f0102241:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0102248:	00 
f0102249:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102250:	e8 eb dd ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102255:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
f010225a:	f6 00 04             	testb  $0x4,(%eax)
f010225d:	75 24                	jne    f0102283 <mem_init+0xd25>
f010225f:	c7 44 24 0c 27 89 10 	movl   $0xf0108927,0xc(%esp)
f0102266:	f0 
f0102267:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010226e:	f0 
f010226f:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102276:	00 
f0102277:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01022a3:	c7 44 24 0c 5c 80 10 	movl   $0xf010805c,0xc(%esp)
f01022aa:	f0 
f01022ab:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01022b2:	f0 
f01022b3:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01022ba:	00 
f01022bb:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01022e9:	c7 44 24 0c 7c 81 10 	movl   $0xf010817c,0xc(%esp)
f01022f0:	f0 
f01022f1:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01022f8:	f0 
f01022f9:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102300:	00 
f0102301:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f010232f:	c7 44 24 0c b0 81 10 	movl   $0xf01081b0,0xc(%esp)
f0102336:	f0 
f0102337:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010233e:	f0 
f010233f:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102346:	00 
f0102347:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f010237b:	c7 44 24 0c e8 81 10 	movl   $0xf01081e8,0xc(%esp)
f0102382:	f0 
f0102383:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010238a:	f0 
f010238b:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102392:	00 
f0102393:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01023c4:	c7 44 24 0c 20 82 10 	movl   $0xf0108220,0xc(%esp)
f01023cb:	f0 
f01023cc:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01023d3:	f0 
f01023d4:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01023db:	00 
f01023dc:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f010240a:	c7 44 24 0c b0 81 10 	movl   $0xf01081b0,0xc(%esp)
f0102411:	f0 
f0102412:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102419:	f0 
f010241a:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102421:	00 
f0102422:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102457:	c7 44 24 0c 5c 82 10 	movl   $0xf010825c,0xc(%esp)
f010245e:	f0 
f010245f:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102466:	f0 
f0102467:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f010246e:	00 
f010246f:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102476:	e8 c5 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010247b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102480:	89 f8                	mov    %edi,%eax
f0102482:	e8 fe e6 ff ff       	call   f0100b85 <check_va2pa>
f0102487:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010248a:	74 24                	je     f01024b0 <mem_init+0xf52>
f010248c:	c7 44 24 0c 88 82 10 	movl   $0xf0108288,0xc(%esp)
f0102493:	f0 
f0102494:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010249b:	f0 
f010249c:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01024a3:	00 
f01024a4:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01024ab:	e8 90 db ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01024b0:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01024b5:	74 24                	je     f01024db <mem_init+0xf7d>
f01024b7:	c7 44 24 0c 3d 89 10 	movl   $0xf010893d,0xc(%esp)
f01024be:	f0 
f01024bf:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01024c6:	f0 
f01024c7:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01024ce:	00 
f01024cf:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01024d6:	e8 65 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01024db:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01024e0:	74 24                	je     f0102506 <mem_init+0xfa8>
f01024e2:	c7 44 24 0c 4e 89 10 	movl   $0xf010894e,0xc(%esp)
f01024e9:	f0 
f01024ea:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01024f1:	f0 
f01024f2:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f01024f9:	00 
f01024fa:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102501:	e8 3a db ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102506:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010250d:	e8 57 ec ff ff       	call   f0101169 <page_alloc>
f0102512:	85 c0                	test   %eax,%eax
f0102514:	74 04                	je     f010251a <mem_init+0xfbc>
f0102516:	39 c6                	cmp    %eax,%esi
f0102518:	74 24                	je     f010253e <mem_init+0xfe0>
f010251a:	c7 44 24 0c b8 82 10 	movl   $0xf01082b8,0xc(%esp)
f0102521:	f0 
f0102522:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102529:	f0 
f010252a:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102531:	00 
f0102532:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f010256a:	c7 44 24 0c dc 82 10 	movl   $0xf01082dc,0xc(%esp)
f0102571:	f0 
f0102572:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102579:	f0 
f010257a:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f0102581:	00 
f0102582:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01025ac:	c7 44 24 0c 88 82 10 	movl   $0xf0108288,0xc(%esp)
f01025b3:	f0 
f01025b4:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01025bb:	f0 
f01025bc:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01025c3:	00 
f01025c4:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01025cb:	e8 70 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025d0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01025d5:	74 24                	je     f01025fb <mem_init+0x109d>
f01025d7:	c7 44 24 0c f4 88 10 	movl   $0xf01088f4,0xc(%esp)
f01025de:	f0 
f01025df:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01025e6:	f0 
f01025e7:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01025ee:	00 
f01025ef:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01025f6:	e8 45 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025fb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102600:	74 24                	je     f0102626 <mem_init+0x10c8>
f0102602:	c7 44 24 0c 4e 89 10 	movl   $0xf010894e,0xc(%esp)
f0102609:	f0 
f010260a:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102611:	f0 
f0102612:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102619:	00 
f010261a:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102646:	c7 44 24 0c 00 83 10 	movl   $0xf0108300,0xc(%esp)
f010264d:	f0 
f010264e:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102655:	f0 
f0102656:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f010265d:	00 
f010265e:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102665:	e8 d6 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010266a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010266f:	75 24                	jne    f0102695 <mem_init+0x1137>
f0102671:	c7 44 24 0c 5f 89 10 	movl   $0xf010895f,0xc(%esp)
f0102678:	f0 
f0102679:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102680:	f0 
f0102681:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f0102688:	00 
f0102689:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102690:	e8 ab d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102695:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102698:	74 24                	je     f01026be <mem_init+0x1160>
f010269a:	c7 44 24 0c 6b 89 10 	movl   $0xf010896b,0xc(%esp)
f01026a1:	f0 
f01026a2:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01026a9:	f0 
f01026aa:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f01026b1:	00 
f01026b2:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01026ea:	c7 44 24 0c dc 82 10 	movl   $0xf01082dc,0xc(%esp)
f01026f1:	f0 
f01026f2:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01026f9:	f0 
f01026fa:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102701:	00 
f0102702:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102709:	e8 32 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010270e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102713:	89 f8                	mov    %edi,%eax
f0102715:	e8 6b e4 ff ff       	call   f0100b85 <check_va2pa>
f010271a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010271d:	74 24                	je     f0102743 <mem_init+0x11e5>
f010271f:	c7 44 24 0c 38 83 10 	movl   $0xf0108338,0xc(%esp)
f0102726:	f0 
f0102727:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010272e:	f0 
f010272f:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102736:	00 
f0102737:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f010273e:	e8 fd d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102743:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102748:	74 24                	je     f010276e <mem_init+0x1210>
f010274a:	c7 44 24 0c 80 89 10 	movl   $0xf0108980,0xc(%esp)
f0102751:	f0 
f0102752:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102759:	f0 
f010275a:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102761:	00 
f0102762:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102769:	e8 d2 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010276e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102773:	74 24                	je     f0102799 <mem_init+0x123b>
f0102775:	c7 44 24 0c 4e 89 10 	movl   $0xf010894e,0xc(%esp)
f010277c:	f0 
f010277d:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102784:	f0 
f0102785:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010278c:	00 
f010278d:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102794:	e8 a7 d8 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027a0:	e8 c4 e9 ff ff       	call   f0101169 <page_alloc>
f01027a5:	85 c0                	test   %eax,%eax
f01027a7:	74 04                	je     f01027ad <mem_init+0x124f>
f01027a9:	39 c3                	cmp    %eax,%ebx
f01027ab:	74 24                	je     f01027d1 <mem_init+0x1273>
f01027ad:	c7 44 24 0c 60 83 10 	movl   $0xf0108360,0xc(%esp)
f01027b4:	f0 
f01027b5:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01027bc:	f0 
f01027bd:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01027c4:	00 
f01027c5:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01027cc:	e8 6f d8 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01027d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027d8:	e8 8c e9 ff ff       	call   f0101169 <page_alloc>
f01027dd:	85 c0                	test   %eax,%eax
f01027df:	74 24                	je     f0102805 <mem_init+0x12a7>
f01027e1:	c7 44 24 0c a2 88 10 	movl   $0xf01088a2,0xc(%esp)
f01027e8:	f0 
f01027e9:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01027f0:	f0 
f01027f1:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f01027f8:	00 
f01027f9:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102825:	c7 44 24 0c 04 80 10 	movl   $0xf0108004,0xc(%esp)
f010282c:	f0 
f010282d:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102834:	f0 
f0102835:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f010283c:	00 
f010283d:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102844:	e8 f7 d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102849:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010284f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102852:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102857:	74 24                	je     f010287d <mem_init+0x131f>
f0102859:	c7 44 24 0c 05 89 10 	movl   $0xf0108905,0xc(%esp)
f0102860:	f0 
f0102861:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102868:	f0 
f0102869:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102870:	00 
f0102871:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01028d3:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f01028da:	f0 
f01028db:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f01028e2:	00 
f01028e3:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01028ea:	e8 51 d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028ef:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f01028f5:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01028f8:	74 24                	je     f010291e <mem_init+0x13c0>
f01028fa:	c7 44 24 0c 91 89 10 	movl   $0xf0108991,0xc(%esp)
f0102901:	f0 
f0102902:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102909:	f0 
f010290a:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f0102911:	00 
f0102912:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102947:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f010294e:	f0 
f010294f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102956:	00 
f0102957:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
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
f010297b:	e8 e7 40 00 00       	call   f0106a67 <memset>
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
f01029c7:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f01029ce:	f0 
f01029cf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01029d6:	00 
f01029d7:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
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
f01029f7:	c7 44 24 0c a9 89 10 	movl   $0xf01089a9,0xc(%esp)
f01029fe:	f0 
f01029ff:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102a06:	f0 
f0102a07:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0102a0e:	00 
f0102a0f:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102a98:	c7 44 24 0c 84 83 10 	movl   $0xf0108384,0xc(%esp)
f0102a9f:	f0 
f0102aa0:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102aa7:	f0 
f0102aa8:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0102aaf:	00 
f0102ab0:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102ab7:	e8 84 d5 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102abc:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102ac2:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102ac8:	77 08                	ja     f0102ad2 <mem_init+0x1574>
f0102aca:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102ad0:	77 24                	ja     f0102af6 <mem_init+0x1598>
f0102ad2:	c7 44 24 0c ac 83 10 	movl   $0xf01083ac,0xc(%esp)
f0102ad9:	f0 
f0102ada:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102ae1:	f0 
f0102ae2:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0102ae9:	00 
f0102aea:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102af1:	e8 4a d5 ff ff       	call   f0100040 <_panic>
f0102af6:	89 da                	mov    %ebx,%edx
f0102af8:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102afa:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102b00:	74 24                	je     f0102b26 <mem_init+0x15c8>
f0102b02:	c7 44 24 0c d4 83 10 	movl   $0xf01083d4,0xc(%esp)
f0102b09:	f0 
f0102b0a:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102b11:	f0 
f0102b12:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102b19:	00 
f0102b1a:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102b21:	e8 1a d5 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102b26:	39 c6                	cmp    %eax,%esi
f0102b28:	73 24                	jae    f0102b4e <mem_init+0x15f0>
f0102b2a:	c7 44 24 0c c0 89 10 	movl   $0xf01089c0,0xc(%esp)
f0102b31:	f0 
f0102b32:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102b39:	f0 
f0102b3a:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102b41:	00 
f0102b42:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102b49:	e8 f2 d4 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102b4e:	8b 3d 8c fe 23 f0    	mov    0xf023fe8c,%edi
f0102b54:	89 da                	mov    %ebx,%edx
f0102b56:	89 f8                	mov    %edi,%eax
f0102b58:	e8 28 e0 ff ff       	call   f0100b85 <check_va2pa>
f0102b5d:	85 c0                	test   %eax,%eax
f0102b5f:	74 24                	je     f0102b85 <mem_init+0x1627>
f0102b61:	c7 44 24 0c fc 83 10 	movl   $0xf01083fc,0xc(%esp)
f0102b68:	f0 
f0102b69:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102b70:	f0 
f0102b71:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102b78:	00 
f0102b79:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102b80:	e8 bb d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102b85:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102b8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b8e:	89 c2                	mov    %eax,%edx
f0102b90:	89 f8                	mov    %edi,%eax
f0102b92:	e8 ee df ff ff       	call   f0100b85 <check_va2pa>
f0102b97:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102b9c:	74 24                	je     f0102bc2 <mem_init+0x1664>
f0102b9e:	c7 44 24 0c 20 84 10 	movl   $0xf0108420,0xc(%esp)
f0102ba5:	f0 
f0102ba6:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102bad:	f0 
f0102bae:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102bb5:	00 
f0102bb6:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102bbd:	e8 7e d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102bc2:	89 f2                	mov    %esi,%edx
f0102bc4:	89 f8                	mov    %edi,%eax
f0102bc6:	e8 ba df ff ff       	call   f0100b85 <check_va2pa>
f0102bcb:	85 c0                	test   %eax,%eax
f0102bcd:	74 24                	je     f0102bf3 <mem_init+0x1695>
f0102bcf:	c7 44 24 0c 50 84 10 	movl   $0xf0108450,0xc(%esp)
f0102bd6:	f0 
f0102bd7:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102bde:	f0 
f0102bdf:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102be6:	00 
f0102be7:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102bee:	e8 4d d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102bf3:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102bf9:	89 f8                	mov    %edi,%eax
f0102bfb:	e8 85 df ff ff       	call   f0100b85 <check_va2pa>
f0102c00:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c03:	74 24                	je     f0102c29 <mem_init+0x16cb>
f0102c05:	c7 44 24 0c 74 84 10 	movl   $0xf0108474,0xc(%esp)
f0102c0c:	f0 
f0102c0d:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102c14:	f0 
f0102c15:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f0102c1c:	00 
f0102c1d:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102c42:	c7 44 24 0c a0 84 10 	movl   $0xf01084a0,0xc(%esp)
f0102c49:	f0 
f0102c4a:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102c51:	f0 
f0102c52:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f0102c59:	00 
f0102c5a:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102c84:	c7 44 24 0c e4 84 10 	movl   $0xf01084e4,0xc(%esp)
f0102c8b:	f0 
f0102c8c:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102c93:	f0 
f0102c94:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0102c9b:	00 
f0102c9c:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102d08:	c7 04 24 d2 89 10 f0 	movl   $0xf01089d2,(%esp)
f0102d0f:	e8 6f 13 00 00       	call   f0104083 <cprintf>
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
f0102d36:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0102d3d:	f0 
f0102d3e:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0102d45:	00 
f0102d46:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102d81:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0102d88:	f0 
f0102d89:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0102d90:	00 
f0102d91:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102d98:	e8 a3 d2 ff ff       	call   f0100040 <_panic>
f0102d9d:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102da4:	00 
	return (physaddr_t)kva - KERNBASE;
f0102da5:	05 00 00 00 10       	add    $0x10000000,%eax
f0102daa:	89 04 24             	mov    %eax,(%esp)
f0102dad:	b9 00 20 02 00       	mov    $0x22000,%ecx
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
f0102dd1:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0102dd8:	f0 
f0102dd9:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
f0102de0:	00 
f0102de1:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102e4e:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0102e55:	f0 
f0102e56:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
f0102e5d:	00 
f0102e5e:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102eac:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0102eb3:	f0 
f0102eb4:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
f0102ebb:	00 
f0102ebc:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102f2a:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0102f31:	f0 
f0102f32:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0102f39:	00 
f0102f3a:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102f41:	e8 fa d0 ff ff       	call   f0100040 <_panic>
f0102f46:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f49:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102f4c:	39 d0                	cmp    %edx,%eax
f0102f4e:	74 24                	je     f0102f74 <mem_init+0x1a16>
f0102f50:	c7 44 24 0c 18 85 10 	movl   $0xf0108518,0xc(%esp)
f0102f57:	f0 
f0102f58:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102f5f:	f0 
f0102f60:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0102f67:	00 
f0102f68:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102f9f:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0102fa6:	f0 
f0102fa7:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0102fae:	00 
f0102faf:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0102fcd:	c7 44 24 0c 4c 85 10 	movl   $0xf010854c,0xc(%esp)
f0102fd4:	f0 
f0102fd5:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0102fdc:	f0 
f0102fdd:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0102fe4:	00 
f0102fe5:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0102fec:	e8 4f d0 ff ff       	call   f0100040 <_panic>
f0102ff1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) 
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ff7:	81 fb 00 20 c2 ee    	cmp    $0xeec22000,%ebx
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
f0103021:	c7 44 24 0c 80 85 10 	movl   $0xf0108580,0xc(%esp)
f0103028:	f0 
f0103029:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0103030:	f0 
f0103031:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0103038:	00 
f0103039:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0103090:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0103097:	f0 
f0103098:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f010309f:	00 
f01030a0:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01030c1:	c7 44 24 0c a8 85 10 	movl   $0xf01085a8,0xc(%esp)
f01030c8:	f0 
f01030c9:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01030d0:	f0 
f01030d1:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f01030d8:	00 
f01030d9:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0103108:	c7 44 24 0c f0 85 10 	movl   $0xf01085f0,0xc(%esp)
f010310f:	f0 
f0103110:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0103117:	f0 
f0103118:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f010311f:	00 
f0103120:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f0103175:	c7 44 24 0c eb 89 10 	movl   $0xf01089eb,0xc(%esp)
f010317c:	f0 
f010317d:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0103184:	f0 
f0103185:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f010318c:	00 
f010318d:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01031a8:	c7 44 24 0c eb 89 10 	movl   $0xf01089eb,0xc(%esp)
f01031af:	f0 
f01031b0:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01031b7:	f0 
f01031b8:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f01031bf:	00 
f01031c0:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01031c7:	e8 74 ce ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01031cc:	f6 c2 02             	test   $0x2,%dl
f01031cf:	75 4e                	jne    f010321f <mem_init+0x1cc1>
f01031d1:	c7 44 24 0c fc 89 10 	movl   $0xf01089fc,0xc(%esp)
f01031d8:	f0 
f01031d9:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01031e0:	f0 
f01031e1:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01031e8:	00 
f01031e9:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01031f0:	e8 4b ce ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01031f5:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01031f9:	74 24                	je     f010321f <mem_init+0x1cc1>
f01031fb:	c7 44 24 0c 0d 8a 10 	movl   $0xf0108a0d,0xc(%esp)
f0103202:	f0 
f0103203:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010320a:	f0 
f010320b:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0103212:	00 
f0103213:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f010322d:	c7 04 24 14 86 10 f0 	movl   $0xf0108614,(%esp)
f0103234:	e8 4a 0e 00 00       	call   f0104083 <cprintf>

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
f0103259:	c7 44 24 0c f7 87 10 	movl   $0xf01087f7,0xc(%esp)
f0103260:	f0 
f0103261:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0103268:	f0 
f0103269:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0103270:	00 
f0103271:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0103278:	e8 c3 cd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010327d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103284:	e8 e0 de ff ff       	call   f0101169 <page_alloc>
f0103289:	89 c7                	mov    %eax,%edi
f010328b:	85 c0                	test   %eax,%eax
f010328d:	75 24                	jne    f01032b3 <mem_init+0x1d55>
f010328f:	c7 44 24 0c 0d 88 10 	movl   $0xf010880d,0xc(%esp)
f0103296:	f0 
f0103297:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010329e:	f0 
f010329f:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f01032a6:	00 
f01032a7:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01032ae:	e8 8d cd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01032b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01032ba:	e8 aa de ff ff       	call   f0101169 <page_alloc>
f01032bf:	89 c6                	mov    %eax,%esi
f01032c1:	85 c0                	test   %eax,%eax
f01032c3:	75 24                	jne    f01032e9 <mem_init+0x1d8b>
f01032c5:	c7 44 24 0c 23 88 10 	movl   $0xf0108823,0xc(%esp)
f01032cc:	f0 
f01032cd:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01032d4:	f0 
f01032d5:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f01032dc:	00 
f01032dd:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f010330b:	e8 57 37 00 00       	call   f0106a67 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103310:	89 f0                	mov    %esi,%eax
f0103312:	e8 29 d8 ff ff       	call   f0100b40 <page2kva>
f0103317:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010331e:	00 
f010331f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103326:	00 
f0103327:	89 04 24             	mov    %eax,(%esp)
f010332a:	e8 38 37 00 00       	call   f0106a67 <memset>
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
f0103357:	c7 44 24 0c f4 88 10 	movl   $0xf01088f4,0xc(%esp)
f010335e:	f0 
f010335f:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0103366:	f0 
f0103367:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f010336e:	00 
f010336f:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0103376:	e8 c5 cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010337b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103382:	01 01 01 
f0103385:	74 24                	je     f01033ab <mem_init+0x1e4d>
f0103387:	c7 44 24 0c 34 86 10 	movl   $0xf0108634,0xc(%esp)
f010338e:	f0 
f010338f:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0103396:	f0 
f0103397:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f010339e:	00 
f010339f:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01033d8:	c7 44 24 0c 58 86 10 	movl   $0xf0108658,0xc(%esp)
f01033df:	f0 
f01033e0:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01033e7:	f0 
f01033e8:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f01033ef:	00 
f01033f0:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f01033f7:	e8 44 cc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01033fc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103401:	74 24                	je     f0103427 <mem_init+0x1ec9>
f0103403:	c7 44 24 0c 16 89 10 	movl   $0xf0108916,0xc(%esp)
f010340a:	f0 
f010340b:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0103412:	f0 
f0103413:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f010341a:	00 
f010341b:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f0103422:	e8 19 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103427:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010342c:	74 24                	je     f0103452 <mem_init+0x1ef4>
f010342e:	c7 44 24 0c 80 89 10 	movl   $0xf0108980,0xc(%esp)
f0103435:	f0 
f0103436:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010343d:	f0 
f010343e:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0103445:	00 
f0103446:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f010344d:	e8 ee cb ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103452:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103459:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010345c:	89 f0                	mov    %esi,%eax
f010345e:	e8 dd d6 ff ff       	call   f0100b40 <page2kva>
f0103463:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0103469:	74 24                	je     f010348f <mem_init+0x1f31>
f010346b:	c7 44 24 0c 7c 86 10 	movl   $0xf010867c,0xc(%esp)
f0103472:	f0 
f0103473:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010347a:	f0 
f010347b:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0103482:	00 
f0103483:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01034ab:	c7 44 24 0c 4e 89 10 	movl   $0xf010894e,0xc(%esp)
f01034b2:	f0 
f01034b3:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01034ba:	f0 
f01034bb:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f01034c2:	00 
f01034c3:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
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
f01034ee:	c7 44 24 0c 04 80 10 	movl   $0xf0108004,0xc(%esp)
f01034f5:	f0 
f01034f6:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f01034fd:	f0 
f01034fe:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f0103505:	00 
f0103506:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f010350d:	e8 2e cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103512:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103518:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010351d:	74 24                	je     f0103543 <mem_init+0x1fe5>
f010351f:	c7 44 24 0c 05 89 10 	movl   $0xf0108905,0xc(%esp)
f0103526:	f0 
f0103527:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f010352e:	f0 
f010352f:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0103536:	00 
f0103537:	c7 04 24 17 87 10 f0 	movl   $0xf0108717,(%esp)
f010353e:	e8 fd ca ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103543:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103549:	89 1c 24             	mov    %ebx,(%esp)
f010354c:	e8 a3 dc ff ff       	call   f01011f4 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103551:	c7 04 24 a8 86 10 f0 	movl   $0xf01086a8,(%esp)
f0103558:	e8 26 0b 00 00       	call   f0104083 <cprintf>
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
f0103646:	c7 04 24 d4 86 10 f0 	movl   $0xf01086d4,(%esp)
f010364d:	e8 31 0a 00 00       	call   f0104083 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103652:	89 1c 24             	mov    %ebx,(%esp)
f0103655:	e8 10 07 00 00       	call   f0103d6a <env_destroy>
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
f0103692:	c7 44 24 08 1c 8a 10 	movl   $0xf0108a1c,0x8(%esp)
f0103699:	f0 
f010369a:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f01036a1:	00 
f01036a2:	c7 04 24 3e 8a 10 f0 	movl   $0xf0108a3e,(%esp)
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
f01036ce:	c7 44 24 08 1c 8a 10 	movl   $0xf0108a1c,0x8(%esp)
f01036d5:	f0 
f01036d6:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
f01036dd:	00 
f01036de:	c7 04 24 3e 8a 10 f0 	movl   $0xf0108a3e,(%esp)
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
f0103704:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103707:	85 c0                	test   %eax,%eax
f0103709:	75 1a                	jne    f0103725 <envid2env+0x29>
		*env_store = curenv;
f010370b:	e8 a9 39 00 00       	call   f01070b9 <cpunum>
f0103710:	6b c0 74             	imul   $0x74,%eax,%eax
f0103713:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103719:	8b 75 0c             	mov    0xc(%ebp),%esi
f010371c:	89 06                	mov    %eax,(%esi)
		return 0;
f010371e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103723:	eb 75                	jmp    f010379a <envid2env+0x9e>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103725:	89 c2                	mov    %eax,%edx
f0103727:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010372d:	89 d3                	mov    %edx,%ebx
f010372f:	c1 e3 07             	shl    $0x7,%ebx
f0103732:	8d 1c d3             	lea    (%ebx,%edx,8),%ebx
f0103735:	03 1d 48 f2 23 f0    	add    0xf023f248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010373b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010373f:	74 05                	je     f0103746 <envid2env+0x4a>
f0103741:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103744:	74 10                	je     f0103756 <envid2env+0x5a>
		*env_store = 0;
f0103746:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103749:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010374f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103754:	eb 44                	jmp    f010379a <envid2env+0x9e>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103756:	84 c9                	test   %cl,%cl
f0103758:	74 36                	je     f0103790 <envid2env+0x94>
f010375a:	e8 5a 39 00 00       	call   f01070b9 <cpunum>
f010375f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103762:	39 98 28 10 24 f0    	cmp    %ebx,-0xfdbefd8(%eax)
f0103768:	74 26                	je     f0103790 <envid2env+0x94>
f010376a:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010376d:	e8 47 39 00 00       	call   f01070b9 <cpunum>
f0103772:	6b c0 74             	imul   $0x74,%eax,%eax
f0103775:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f010377b:	3b 70 48             	cmp    0x48(%eax),%esi
f010377e:	74 10                	je     f0103790 <envid2env+0x94>
		*env_store = 0;
f0103780:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103783:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103789:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010378e:	eb 0a                	jmp    f010379a <envid2env+0x9e>
	}

	*env_store = e;
f0103790:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103793:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103795:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010379a:	5b                   	pop    %ebx
f010379b:	5e                   	pop    %esi
f010379c:	5d                   	pop    %ebp
f010379d:	c3                   	ret    

f010379e <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010379e:	55                   	push   %ebp
f010379f:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01037a1:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f01037a6:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01037a9:	b8 23 00 00 00       	mov    $0x23,%eax
f01037ae:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01037b0:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01037b2:	b0 10                	mov    $0x10,%al
f01037b4:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01037b6:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01037b8:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01037ba:	ea c1 37 10 f0 08 00 	ljmp   $0x8,$0xf01037c1
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01037c1:	b0 00                	mov    $0x0,%al
f01037c3:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01037c6:	5d                   	pop    %ebp
f01037c7:	c3                   	ret    

f01037c8 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01037c8:	55                   	push   %ebp
f01037c9:	89 e5                	mov    %esp,%ebp
f01037cb:	56                   	push   %esi
f01037cc:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL ; 
	size_t ptr = NENV - 1 ; 
	for ( ; ptr != -1 ; ptr -- ) {
		envs[ptr].env_link = env_free_list ; 
f01037cd:	8b 35 48 f2 23 f0    	mov    0xf023f248,%esi
f01037d3:	8d 86 78 1f 02 00    	lea    0x21f78(%esi),%eax
f01037d9:	ba 00 04 00 00       	mov    $0x400,%edx
f01037de:	b9 00 00 00 00       	mov    $0x0,%ecx
f01037e3:	89 c3                	mov    %eax,%ebx
f01037e5:	89 48 44             	mov    %ecx,0x44(%eax)
		envs[ptr].env_id = 0 ; 
f01037e8:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
f01037ef:	2d 88 00 00 00       	sub    $0x88,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL ; 
	size_t ptr = NENV - 1 ; 
	for ( ; ptr != -1 ; ptr -- ) {
f01037f4:	83 ea 01             	sub    $0x1,%edx
f01037f7:	74 04                	je     f01037fd <env_init+0x35>
		envs[ptr].env_link = env_free_list ; 
		envs[ptr].env_id = 0 ; 
		env_free_list = &(envs[ptr]) ; 
f01037f9:	89 d9                	mov    %ebx,%ecx
f01037fb:	eb e6                	jmp    f01037e3 <env_init+0x1b>
f01037fd:	89 35 4c f2 23 f0    	mov    %esi,0xf023f24c
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103803:	e8 96 ff ff ff       	call   f010379e <env_init_percpu>
}
f0103808:	5b                   	pop    %ebx
f0103809:	5e                   	pop    %esi
f010380a:	5d                   	pop    %ebp
f010380b:	c3                   	ret    

f010380c <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010380c:	55                   	push   %ebp
f010380d:	89 e5                	mov    %esp,%ebp
f010380f:	57                   	push   %edi
f0103810:	56                   	push   %esi
f0103811:	53                   	push   %ebx
f0103812:	83 ec 2c             	sub    $0x2c,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103815:	8b 1d 4c f2 23 f0    	mov    0xf023f24c,%ebx
f010381b:	85 db                	test   %ebx,%ebx
f010381d:	0f 84 b3 01 00 00    	je     f01039d6 <env_alloc+0x1ca>
{
	int i;	
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103823:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010382a:	e8 3a d9 ff ff       	call   f0101169 <page_alloc>
f010382f:	85 c0                	test   %eax,%eax
f0103831:	0f 84 a6 01 00 00    	je     f01039dd <env_alloc+0x1d1>
f0103837:	89 c6                	mov    %eax,%esi
f0103839:	2b 35 90 fe 23 f0    	sub    0xf023fe90,%esi
f010383f:	c1 fe 03             	sar    $0x3,%esi
f0103842:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103845:	89 f2                	mov    %esi,%edx
f0103847:	c1 ea 0c             	shr    $0xc,%edx
f010384a:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0103850:	72 20                	jb     f0103872 <env_alloc+0x66>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103852:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103856:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f010385d:	f0 
f010385e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103865:	00 
f0103866:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
f010386d:	e8 ce c7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103872:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
f0103878:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010387b:	ba 00 00 00 00       	mov    $0x0,%edx
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	pde_t * tmp_pgdir = ( pde_t * ) page2kva(p);
	for ( i = 0  ; i < NPDENTRIES  ; i ++ ) {
		tmp_pgdir[i] = kern_pgdir[i];	
f0103880:	8b 0d 8c fe 23 f0    	mov    0xf023fe8c,%ecx
f0103886:	8b 0c 11             	mov    (%ecx,%edx,1),%ecx
f0103889:	89 8c 32 00 00 00 f0 	mov    %ecx,-0x10000000(%edx,%esi,1)
f0103890:	83 c2 04             	add    $0x4,%edx
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	pde_t * tmp_pgdir = ( pde_t * ) page2kva(p);
	for ( i = 0  ; i < NPDENTRIES  ; i ++ ) {
f0103893:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0103899:	75 e5                	jne    f0103880 <env_alloc+0x74>
		tmp_pgdir[i] = kern_pgdir[i];	
	}
	( p->pp_ref ) ++ ;  
f010389b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	for ( i = 0 ; i <  PDX(UTOP) ; i ++ ) tmp_pgdir[i] = 0   ; 
f01038a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01038a5:	66 ba 00 00          	mov    $0x0,%dx
f01038a9:	c7 04 97 00 00 00 00 	movl   $0x0,(%edi,%edx,4)
f01038b0:	83 c0 01             	add    $0x1,%eax
f01038b3:	89 c2                	mov    %eax,%edx
f01038b5:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01038ba:	75 ed                	jne    f01038a9 <env_alloc+0x9d>
	e->env_pgdir = tmp_pgdir ; 
f01038bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038bf:	89 43 60             	mov    %eax,0x60(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038c7:	77 20                	ja     f01038e9 <env_alloc+0xdd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038cd:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f01038d4:	f0 
f01038d5:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f01038dc:	00 
f01038dd:	c7 04 24 3e 8a 10 f0 	movl   $0xf0108a3e,(%esp)
f01038e4:	e8 57 c7 ff ff       	call   f0100040 <_panic>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01038e9:	83 ce 05             	or     $0x5,%esi
f01038ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038ef:	89 b0 f4 0e 00 00    	mov    %esi,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01038f5:	8b 43 48             	mov    0x48(%ebx),%eax
f01038f8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01038fd:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103902:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103907:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010390a:	89 da                	mov    %ebx,%edx
f010390c:	2b 15 48 f2 23 f0    	sub    0xf023f248,%edx
f0103912:	c1 fa 03             	sar    $0x3,%edx
f0103915:	69 d2 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%edx,%edx
f010391b:	09 d0                	or     %edx,%eax
f010391d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103920:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103923:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103926:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010392d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103934:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010393b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103942:	00 
f0103943:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010394a:	00 
f010394b:	89 1c 24             	mov    %ebx,(%esp)
f010394e:	e8 14 31 00 00       	call   f0106a67 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103953:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103959:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010395f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103965:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010396c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags = (e->env_tf.tf_eflags) | FL_IF ;
f0103972:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103979:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103980:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103984:	8b 43 44             	mov    0x44(%ebx),%eax
f0103987:	a3 4c f2 23 f0       	mov    %eax,0xf023f24c
	*newenv_store = e;
f010398c:	8b 45 08             	mov    0x8(%ebp),%eax
f010398f:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103991:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103994:	e8 20 37 00 00       	call   f01070b9 <cpunum>
f0103999:	6b d0 74             	imul   $0x74,%eax,%edx
f010399c:	b8 00 00 00 00       	mov    $0x0,%eax
f01039a1:	83 ba 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%edx)
f01039a8:	74 11                	je     f01039bb <env_alloc+0x1af>
f01039aa:	e8 0a 37 00 00       	call   f01070b9 <cpunum>
f01039af:	6b c0 74             	imul   $0x74,%eax,%eax
f01039b2:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01039b8:	8b 40 48             	mov    0x48(%eax),%eax
f01039bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01039bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039c3:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f01039ca:	e8 b4 06 00 00       	call   f0104083 <cprintf>
	return 0;
f01039cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01039d4:	eb 0c                	jmp    f01039e2 <env_alloc+0x1d6>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01039d6:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01039db:	eb 05                	jmp    f01039e2 <env_alloc+0x1d6>
	int i;	
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01039dd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01039e2:	83 c4 2c             	add    $0x2c,%esp
f01039e5:	5b                   	pop    %ebx
f01039e6:	5e                   	pop    %esi
f01039e7:	5f                   	pop    %edi
f01039e8:	5d                   	pop    %ebp
f01039e9:	c3                   	ret    

f01039ea <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01039ea:	55                   	push   %ebp
f01039eb:	89 e5                	mov    %esp,%ebp
f01039ed:	57                   	push   %edi
f01039ee:	56                   	push   %esi
f01039ef:	53                   	push   %ebx
f01039f0:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env * newEnv = NULL ; 
f01039f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	env_alloc( &newEnv , 0 ) ;
f01039fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a01:	00 
f0103a02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103a05:	89 04 24             	mov    %eax,(%esp)
f0103a08:	e8 ff fd ff ff       	call   f010380c <env_alloc>
    	newEnv->env_type = type ; 
f0103a0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a10:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a13:	89 47 50             	mov    %eax,0x50(%edi)
	//  What?  (See env_run() and env_pop_tf() below.)
	// LAB 3: Your code here.
	struct Elf *ELFHDR = ( struct Elf * ) binary ; 
	
	struct Proghdr *ph , *eph ; 
	ph = ( struct Proghdr * ) ( ( uint8_t * ) ELFHDR + ELFHDR->e_phoff) ;
f0103a16:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a19:	89 c3                	mov    %eax,%ebx
f0103a1b:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum ; 
f0103a1e:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103a22:	c1 e0 05             	shl    $0x5,%eax
f0103a25:	01 d8                	add    %ebx,%eax
f0103a27:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103a2a:	e9 0b 01 00 00       	jmp    f0103b3a <env_create+0x150>
	for ( ; ph < eph ; ph ++ ) {
		if ( ph->p_type != ELF_PROG_LOAD ) continue ; 
f0103a2f:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103a32:	0f 85 ff 00 00 00    	jne    f0103b37 <env_create+0x14d>
		region_alloc( e , ( void * )ph->p_va , ph->p_memsz) ; 
f0103a38:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103a3b:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a3e:	89 f8                	mov    %edi,%eax
f0103a40:	e8 1b fc ff ff       	call   f0103660 <region_alloc>
		struct PageInfo * pp = page_lookup( e->env_pgdir , ( void * )  ph->p_va , NULL ) ;
f0103a45:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103a4c:	00 
f0103a4d:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a54:	8b 47 60             	mov    0x60(%edi),%eax
f0103a57:	89 04 24             	mov    %eax,(%esp)
f0103a5a:	e8 15 d9 ff ff       	call   f0101374 <page_lookup>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a5f:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0103a65:	c1 f8 03             	sar    $0x3,%eax
f0103a68:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a6b:	89 c2                	mov    %eax,%edx
f0103a6d:	c1 ea 0c             	shr    $0xc,%edx
f0103a70:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0103a76:	72 20                	jb     f0103a98 <env_create+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a78:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a7c:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0103a83:	f0 
f0103a84:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103a8b:	00 
f0103a8c:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
f0103a93:	e8 a8 c5 ff ff       	call   f0100040 <_panic>
		uint32_t now_ptr = ( ( uint32_t ) page2kva(pp) ) + ( ( 0xFFF ) & ( ( unsigned ) ph->p_va ) );
f0103a98:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a9b:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0103aa1:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
		uint32_t i = 0 ; 
f0103aa8:	be 00 00 00 00       	mov    $0x0,%esi
f0103aad:	eb 7f                	jmp    f0103b2e <env_create+0x144>
		for ( ; i < ph->p_memsz  ; i ++ ) { 
			if ( ( ( unsigned ) ( ph->p_va + i ) & ( 0xFFF ) ) == 0 ) {
f0103aaf:	89 f2                	mov    %esi,%edx
f0103ab1:	03 53 08             	add    0x8(%ebx),%edx
f0103ab4:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0103aba:	75 55                	jne    f0103b11 <env_create+0x127>
				pp = page_lookup( e->env_pgdir , ( void * ) ( ( ph->p_va ) + i ) , NULL ) ; 
f0103abc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103ac3:	00 
f0103ac4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103ac8:	8b 47 60             	mov    0x60(%edi),%eax
f0103acb:	89 04 24             	mov    %eax,(%esp)
f0103ace:	e8 a1 d8 ff ff       	call   f0101374 <page_lookup>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103ad3:	2b 05 90 fe 23 f0    	sub    0xf023fe90,%eax
f0103ad9:	c1 f8 03             	sar    $0x3,%eax
f0103adc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103adf:	89 c2                	mov    %eax,%edx
f0103ae1:	c1 ea 0c             	shr    $0xc,%edx
f0103ae4:	3b 15 88 fe 23 f0    	cmp    0xf023fe88,%edx
f0103aea:	72 20                	jb     f0103b0c <env_create+0x122>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103aec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103af0:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0103af7:	f0 
f0103af8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103aff:	00 
f0103b00:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
f0103b07:	e8 34 c5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103b0c:	2d 00 00 00 10       	sub    $0x10000000,%eax
				now_ptr = ( uint32_t ) page2kva(pp);	 
			}
			if ( i < ph->p_filesz ) 
f0103b11:	3b 73 10             	cmp    0x10(%ebx),%esi
f0103b14:	73 0f                	jae    f0103b25 <env_create+0x13b>
				* ( ( uint8_t * ) ( now_ptr ) ) = * ( binary + ph->p_offset + i ) ;
f0103b16:	89 f2                	mov    %esi,%edx
f0103b18:	03 55 08             	add    0x8(%ebp),%edx
f0103b1b:	03 53 04             	add    0x4(%ebx),%edx
f0103b1e:	0f b6 12             	movzbl (%edx),%edx
f0103b21:	88 10                	mov    %dl,(%eax)
f0103b23:	eb 03                	jmp    f0103b28 <env_create+0x13e>
			else
				* ( ( uint8_t * ) ( now_ptr ) ) = 0 ;
f0103b25:	c6 00 00             	movb   $0x0,(%eax)
			now_ptr ++ ; 
f0103b28:	83 c0 01             	add    $0x1,%eax
		if ( ph->p_type != ELF_PROG_LOAD ) continue ; 
		region_alloc( e , ( void * )ph->p_va , ph->p_memsz) ; 
		struct PageInfo * pp = page_lookup( e->env_pgdir , ( void * )  ph->p_va , NULL ) ;
		uint32_t now_ptr = ( ( uint32_t ) page2kva(pp) ) + ( ( 0xFFF ) & ( ( unsigned ) ph->p_va ) );
		uint32_t i = 0 ; 
		for ( ; i < ph->p_memsz  ; i ++ ) { 
f0103b2b:	83 c6 01             	add    $0x1,%esi
f0103b2e:	3b 73 14             	cmp    0x14(%ebx),%esi
f0103b31:	0f 82 78 ff ff ff    	jb     f0103aaf <env_create+0xc5>
	struct Elf *ELFHDR = ( struct Elf * ) binary ; 
	
	struct Proghdr *ph , *eph ; 
	ph = ( struct Proghdr * ) ( ( uint8_t * ) ELFHDR + ELFHDR->e_phoff) ;
	eph = ph + ELFHDR->e_phnum ; 
	for ( ; ph < eph ; ph ++ ) {
f0103b37:	83 c3 20             	add    $0x20,%ebx
f0103b3a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103b3d:	0f 87 ec fe ff ff    	ja     f0103a2f <env_create+0x45>
			else
				* ( ( uint8_t * ) ( now_ptr ) ) = 0 ;
			now_ptr ++ ; 
		}
	} 
	e->env_tf.tf_eip = ELFHDR->e_entry ; 
f0103b43:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b46:	8b 40 18             	mov    0x18(%eax),%eax
f0103b49:	89 47 30             	mov    %eax,0x30(%edi)
	
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	region_alloc( e , ( void * ) ( USTACKTOP - PGSIZE ) , PGSIZE ) ;
f0103b4c:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103b51:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103b56:	89 f8                	mov    %edi,%eax
f0103b58:	e8 03 fb ff ff       	call   f0103660 <region_alloc>
	// LAB 3: Your code here.
	struct Env * newEnv = NULL ; 
	env_alloc( &newEnv , 0 ) ;
    	newEnv->env_type = type ; 
	load_icode( newEnv , binary) ;  	
}
f0103b5d:	83 c4 3c             	add    $0x3c,%esp
f0103b60:	5b                   	pop    %ebx
f0103b61:	5e                   	pop    %esi
f0103b62:	5f                   	pop    %edi
f0103b63:	5d                   	pop    %ebp
f0103b64:	c3                   	ret    

f0103b65 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103b65:	55                   	push   %ebp
f0103b66:	89 e5                	mov    %esp,%ebp
f0103b68:	57                   	push   %edi
f0103b69:	56                   	push   %esi
f0103b6a:	53                   	push   %ebx
f0103b6b:	83 ec 2c             	sub    $0x2c,%esp
f0103b6e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103b71:	e8 43 35 00 00       	call   f01070b9 <cpunum>
f0103b76:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b79:	39 b8 28 10 24 f0    	cmp    %edi,-0xfdbefd8(%eax)
f0103b7f:	75 34                	jne    f0103bb5 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103b81:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b86:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b8b:	77 20                	ja     f0103bad <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b91:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0103b98:	f0 
f0103b99:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
f0103ba0:	00 
f0103ba1:	c7 04 24 3e 8a 10 f0 	movl   $0xf0108a3e,(%esp)
f0103ba8:	e8 93 c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103bad:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103bb2:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103bb5:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103bb8:	e8 fc 34 00 00       	call   f01070b9 <cpunum>
f0103bbd:	6b d0 74             	imul   $0x74,%eax,%edx
f0103bc0:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bc5:	83 ba 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%edx)
f0103bcc:	74 11                	je     f0103bdf <env_free+0x7a>
f0103bce:	e8 e6 34 00 00       	call   f01070b9 <cpunum>
f0103bd3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bd6:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103bdc:	8b 40 48             	mov    0x48(%eax),%eax
f0103bdf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103be3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103be7:	c7 04 24 5e 8a 10 f0 	movl   $0xf0108a5e,(%esp)
f0103bee:	e8 90 04 00 00       	call   f0104083 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bf3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103bfa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103bfd:	89 c8                	mov    %ecx,%eax
f0103bff:	c1 e0 02             	shl    $0x2,%eax
f0103c02:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103c05:	8b 47 60             	mov    0x60(%edi),%eax
f0103c08:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103c0b:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103c11:	0f 84 b7 00 00 00    	je     f0103cce <env_free+0x169>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103c17:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c1d:	89 f0                	mov    %esi,%eax
f0103c1f:	c1 e8 0c             	shr    $0xc,%eax
f0103c22:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103c25:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0103c2b:	72 20                	jb     f0103c4d <env_free+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103c2d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103c31:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0103c38:	f0 
f0103c39:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f0103c40:	00 
f0103c41:	c7 04 24 3e 8a 10 f0 	movl   $0xf0108a3e,(%esp)
f0103c48:	e8 f3 c3 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103c4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c50:	c1 e0 16             	shl    $0x16,%eax
f0103c53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103c56:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103c5b:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103c62:	01 
f0103c63:	74 17                	je     f0103c7c <env_free+0x117>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103c65:	89 d8                	mov    %ebx,%eax
f0103c67:	c1 e0 0c             	shl    $0xc,%eax
f0103c6a:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c71:	8b 47 60             	mov    0x60(%edi),%eax
f0103c74:	89 04 24             	mov    %eax,(%esp)
f0103c77:	e8 a5 d7 ff ff       	call   f0101421 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103c7c:	83 c3 01             	add    $0x1,%ebx
f0103c7f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103c85:	75 d4                	jne    f0103c5b <env_free+0xf6>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103c87:	8b 47 60             	mov    0x60(%edi),%eax
f0103c8a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103c8d:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c94:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103c97:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0103c9d:	72 1c                	jb     f0103cbb <env_free+0x156>
		panic("pa2page called with invalid pa");
f0103c9f:	c7 44 24 08 a0 7e 10 	movl   $0xf0107ea0,0x8(%esp)
f0103ca6:	f0 
f0103ca7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103cae:	00 
f0103caf:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
f0103cb6:	e8 85 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103cbb:	a1 90 fe 23 f0       	mov    0xf023fe90,%eax
f0103cc0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103cc3:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103cc6:	89 04 24             	mov    %eax,(%esp)
f0103cc9:	e8 82 d5 ff ff       	call   f0101250 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103cce:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103cd2:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103cd9:	0f 85 1b ff ff ff    	jne    f0103bfa <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103cdf:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ce2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ce7:	77 20                	ja     f0103d09 <env_free+0x1a4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ce9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ced:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0103cf4:	f0 
f0103cf5:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f0103cfc:	00 
f0103cfd:	c7 04 24 3e 8a 10 f0 	movl   $0xf0108a3e,(%esp)
f0103d04:	e8 37 c3 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103d09:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103d10:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103d15:	c1 e8 0c             	shr    $0xc,%eax
f0103d18:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0103d1e:	72 1c                	jb     f0103d3c <env_free+0x1d7>
		panic("pa2page called with invalid pa");
f0103d20:	c7 44 24 08 a0 7e 10 	movl   $0xf0107ea0,0x8(%esp)
f0103d27:	f0 
f0103d28:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103d2f:	00 
f0103d30:	c7 04 24 09 87 10 f0 	movl   $0xf0108709,(%esp)
f0103d37:	e8 04 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103d3c:	8b 15 90 fe 23 f0    	mov    0xf023fe90,%edx
f0103d42:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103d45:	89 04 24             	mov    %eax,(%esp)
f0103d48:	e8 03 d5 ff ff       	call   f0101250 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103d4d:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103d54:	a1 4c f2 23 f0       	mov    0xf023f24c,%eax
f0103d59:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103d5c:	89 3d 4c f2 23 f0    	mov    %edi,0xf023f24c
}
f0103d62:	83 c4 2c             	add    $0x2c,%esp
f0103d65:	5b                   	pop    %ebx
f0103d66:	5e                   	pop    %esi
f0103d67:	5f                   	pop    %edi
f0103d68:	5d                   	pop    %ebp
f0103d69:	c3                   	ret    

f0103d6a <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103d6a:	55                   	push   %ebp
f0103d6b:	89 e5                	mov    %esp,%ebp
f0103d6d:	53                   	push   %ebx
f0103d6e:	83 ec 14             	sub    $0x14,%esp
f0103d71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103d74:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103d78:	75 19                	jne    f0103d93 <env_destroy+0x29>
f0103d7a:	e8 3a 33 00 00       	call   f01070b9 <cpunum>
f0103d7f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d82:	39 98 28 10 24 f0    	cmp    %ebx,-0xfdbefd8(%eax)
f0103d88:	74 09                	je     f0103d93 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103d8a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103d91:	eb 2f                	jmp    f0103dc2 <env_destroy+0x58>
	}

	env_free(e);
f0103d93:	89 1c 24             	mov    %ebx,(%esp)
f0103d96:	e8 ca fd ff ff       	call   f0103b65 <env_free>

	if (curenv == e) {
f0103d9b:	e8 19 33 00 00       	call   f01070b9 <cpunum>
f0103da0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da3:	39 98 28 10 24 f0    	cmp    %ebx,-0xfdbefd8(%eax)
f0103da9:	75 17                	jne    f0103dc2 <env_destroy+0x58>
		curenv = NULL;
f0103dab:	e8 09 33 00 00       	call   f01070b9 <cpunum>
f0103db0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db3:	c7 80 28 10 24 f0 00 	movl   $0x0,-0xfdbefd8(%eax)
f0103dba:	00 00 00 
		sched_yield();
f0103dbd:	e8 e2 12 00 00       	call   f01050a4 <sched_yield>
	}
}
f0103dc2:	83 c4 14             	add    $0x14,%esp
f0103dc5:	5b                   	pop    %ebx
f0103dc6:	5d                   	pop    %ebp
f0103dc7:	c3                   	ret    

f0103dc8 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103dc8:	55                   	push   %ebp
f0103dc9:	89 e5                	mov    %esp,%ebp
f0103dcb:	53                   	push   %ebx
f0103dcc:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103dcf:	e8 e5 32 00 00       	call   f01070b9 <cpunum>
f0103dd4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dd7:	8b 98 28 10 24 f0    	mov    -0xfdbefd8(%eax),%ebx
f0103ddd:	e8 d7 32 00 00       	call   f01070b9 <cpunum>
f0103de2:	89 43 5c             	mov    %eax,0x5c(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103de5:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0103dec:	e8 f2 35 00 00       	call   f01073e3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103df1:	f3 90                	pause  

	unlock_kernel();
	__asm __volatile("movl %0,%%esp\n"
f0103df3:	8b 65 08             	mov    0x8(%ebp),%esp
f0103df6:	61                   	popa   
f0103df7:	07                   	pop    %es
f0103df8:	1f                   	pop    %ds
f0103df9:	83 c4 08             	add    $0x8,%esp
f0103dfc:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103dfd:	c7 44 24 08 74 8a 10 	movl   $0xf0108a74,0x8(%esp)
f0103e04:	f0 
f0103e05:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
f0103e0c:	00 
f0103e0d:	c7 04 24 3e 8a 10 f0 	movl   $0xf0108a3e,(%esp)
f0103e14:	e8 27 c2 ff ff       	call   f0100040 <_panic>

f0103e19 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103e19:	55                   	push   %ebp
f0103e1a:	89 e5                	mov    %esp,%ebp
f0103e1c:	83 ec 18             	sub    $0x18,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if ( ( curenv ) && ( curenv->env_status == ENV_RUNNING ) )
f0103e1f:	e8 95 32 00 00       	call   f01070b9 <cpunum>
f0103e24:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e27:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0103e2e:	74 29                	je     f0103e59 <env_run+0x40>
f0103e30:	e8 84 32 00 00       	call   f01070b9 <cpunum>
f0103e35:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e38:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e3e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103e42:	75 15                	jne    f0103e59 <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE ;  
f0103e44:	e8 70 32 00 00       	call   f01070b9 <cpunum>
f0103e49:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e4c:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e52:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e ;
f0103e59:	e8 5b 32 00 00       	call   f01070b9 <cpunum>
f0103e5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e61:	8b 55 08             	mov    0x8(%ebp),%edx
f0103e64:	89 90 28 10 24 f0    	mov    %edx,-0xfdbefd8(%eax)
	curenv -> env_status = ENV_RUNNING ; 
f0103e6a:	e8 4a 32 00 00       	call   f01070b9 <cpunum>
f0103e6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e72:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e78:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	( curenv -> env_runs ) ++ ;
f0103e7f:	e8 35 32 00 00       	call   f01070b9 <cpunum>
f0103e84:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e87:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e8d:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3( PADDR( curenv -> env_pgdir ) ) ; 	
f0103e91:	e8 23 32 00 00       	call   f01070b9 <cpunum>
f0103e96:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e99:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103e9f:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ea2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ea7:	77 20                	ja     f0103ec9 <env_run+0xb0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ead:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0103eb4:	f0 
f0103eb5:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
f0103ebc:	00 
f0103ebd:	c7 04 24 3e 8a 10 f0 	movl   $0xf0108a3e,(%esp)
f0103ec4:	e8 77 c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ec9:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ece:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf( &curenv->env_tf ) ; 	
f0103ed1:	e8 e3 31 00 00       	call   f01070b9 <cpunum>
f0103ed6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ed9:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0103edf:	89 04 24             	mov    %eax,(%esp)
f0103ee2:	e8 e1 fe ff ff       	call   f0103dc8 <env_pop_tf>

f0103ee7 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103ee7:	55                   	push   %ebp
f0103ee8:	89 e5                	mov    %esp,%ebp
f0103eea:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103eee:	ba 70 00 00 00       	mov    $0x70,%edx
f0103ef3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103ef4:	b2 71                	mov    $0x71,%dl
f0103ef6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103ef7:	0f b6 c0             	movzbl %al,%eax
}
f0103efa:	5d                   	pop    %ebp
f0103efb:	c3                   	ret    

f0103efc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103efc:	55                   	push   %ebp
f0103efd:	89 e5                	mov    %esp,%ebp
f0103eff:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103f03:	ba 70 00 00 00       	mov    $0x70,%edx
f0103f08:	ee                   	out    %al,(%dx)
f0103f09:	b2 71                	mov    $0x71,%dl
f0103f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f0e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103f0f:	5d                   	pop    %ebp
f0103f10:	c3                   	ret    

f0103f11 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103f11:	55                   	push   %ebp
f0103f12:	89 e5                	mov    %esp,%ebp
f0103f14:	56                   	push   %esi
f0103f15:	53                   	push   %ebx
f0103f16:	83 ec 10             	sub    $0x10,%esp
f0103f19:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103f1c:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103f22:	80 3d 50 f2 23 f0 00 	cmpb   $0x0,0xf023f250
f0103f29:	74 4e                	je     f0103f79 <irq_setmask_8259A+0x68>
f0103f2b:	89 c6                	mov    %eax,%esi
f0103f2d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103f32:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103f33:	66 c1 e8 08          	shr    $0x8,%ax
f0103f37:	b2 a1                	mov    $0xa1,%dl
f0103f39:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103f3a:	c7 04 24 80 8a 10 f0 	movl   $0xf0108a80,(%esp)
f0103f41:	e8 3d 01 00 00       	call   f0104083 <cprintf>
	for (i = 0; i < 16; i++)
f0103f46:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103f4b:	0f b7 f6             	movzwl %si,%esi
f0103f4e:	f7 d6                	not    %esi
f0103f50:	0f a3 de             	bt     %ebx,%esi
f0103f53:	73 10                	jae    f0103f65 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103f55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f59:	c7 04 24 3b 8f 10 f0 	movl   $0xf0108f3b,(%esp)
f0103f60:	e8 1e 01 00 00       	call   f0104083 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103f65:	83 c3 01             	add    $0x1,%ebx
f0103f68:	83 fb 10             	cmp    $0x10,%ebx
f0103f6b:	75 e3                	jne    f0103f50 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103f6d:	c7 04 24 e9 89 10 f0 	movl   $0xf01089e9,(%esp)
f0103f74:	e8 0a 01 00 00       	call   f0104083 <cprintf>
}
f0103f79:	83 c4 10             	add    $0x10,%esp
f0103f7c:	5b                   	pop    %ebx
f0103f7d:	5e                   	pop    %esi
f0103f7e:	5d                   	pop    %ebp
f0103f7f:	c3                   	ret    

f0103f80 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103f80:	c6 05 50 f2 23 f0 01 	movb   $0x1,0xf023f250
f0103f87:	ba 21 00 00 00       	mov    $0x21,%edx
f0103f8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f91:	ee                   	out    %al,(%dx)
f0103f92:	b2 a1                	mov    $0xa1,%dl
f0103f94:	ee                   	out    %al,(%dx)
f0103f95:	b2 20                	mov    $0x20,%dl
f0103f97:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f9c:	ee                   	out    %al,(%dx)
f0103f9d:	b2 21                	mov    $0x21,%dl
f0103f9f:	b8 20 00 00 00       	mov    $0x20,%eax
f0103fa4:	ee                   	out    %al,(%dx)
f0103fa5:	b8 04 00 00 00       	mov    $0x4,%eax
f0103faa:	ee                   	out    %al,(%dx)
f0103fab:	b8 03 00 00 00       	mov    $0x3,%eax
f0103fb0:	ee                   	out    %al,(%dx)
f0103fb1:	b2 a0                	mov    $0xa0,%dl
f0103fb3:	b8 11 00 00 00       	mov    $0x11,%eax
f0103fb8:	ee                   	out    %al,(%dx)
f0103fb9:	b2 a1                	mov    $0xa1,%dl
f0103fbb:	b8 28 00 00 00       	mov    $0x28,%eax
f0103fc0:	ee                   	out    %al,(%dx)
f0103fc1:	b8 02 00 00 00       	mov    $0x2,%eax
f0103fc6:	ee                   	out    %al,(%dx)
f0103fc7:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fcc:	ee                   	out    %al,(%dx)
f0103fcd:	b2 20                	mov    $0x20,%dl
f0103fcf:	b8 68 00 00 00       	mov    $0x68,%eax
f0103fd4:	ee                   	out    %al,(%dx)
f0103fd5:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103fda:	ee                   	out    %al,(%dx)
f0103fdb:	b2 a0                	mov    $0xa0,%dl
f0103fdd:	b8 68 00 00 00       	mov    $0x68,%eax
f0103fe2:	ee                   	out    %al,(%dx)
f0103fe3:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103fe8:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103fe9:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0103ff0:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103ff4:	74 12                	je     f0104008 <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103ff6:	55                   	push   %ebp
f0103ff7:	89 e5                	mov    %esp,%ebp
f0103ff9:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103ffc:	0f b7 c0             	movzwl %ax,%eax
f0103fff:	89 04 24             	mov    %eax,(%esp)
f0104002:	e8 0a ff ff ff       	call   f0103f11 <irq_setmask_8259A>
}
f0104007:	c9                   	leave  
f0104008:	f3 c3                	repz ret 

f010400a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010400a:	55                   	push   %ebp
f010400b:	89 e5                	mov    %esp,%ebp
f010400d:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104010:	8b 45 08             	mov    0x8(%ebp),%eax
f0104013:	89 04 24             	mov    %eax,(%esp)
f0104016:	e8 6f c7 ff ff       	call   f010078a <cputchar>
	*cnt++;
}
f010401b:	c9                   	leave  
f010401c:	c3                   	ret    

f010401d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010401d:	55                   	push   %ebp
f010401e:	89 e5                	mov    %esp,%ebp
f0104020:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104023:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010402a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010402d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104031:	8b 45 08             	mov    0x8(%ebp),%eax
f0104034:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104038:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010403b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010403f:	c7 04 24 0a 40 10 f0 	movl   $0xf010400a,(%esp)
f0104046:	e8 64 1f 00 00       	call   f0105faf <vprintfmt>
	return cnt;
}
f010404b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010404e:	c9                   	leave  
f010404f:	c3                   	ret    

f0104050 <cvcprintf>:

int
cvcprintf(const char *fmt, va_list ap)
{
f0104050:	55                   	push   %ebp
f0104051:	89 e5                	mov    %esp,%ebp
f0104053:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104056:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	cvprintfmt((void*)putch, &cnt, fmt, ap);
f010405d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104060:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104064:	8b 45 08             	mov    0x8(%ebp),%eax
f0104067:	89 44 24 08          	mov    %eax,0x8(%esp)
f010406b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010406e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104072:	c7 04 24 0a 40 10 f0 	movl   $0xf010400a,(%esp)
f0104079:	e8 05 23 00 00       	call   f0106383 <cvprintfmt>
	return cnt;
}
f010407e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104081:	c9                   	leave  
f0104082:	c3                   	ret    

f0104083 <cprintf>:


int
cprintf(const char *fmt, ...)
{
f0104083:	55                   	push   %ebp
f0104084:	89 e5                	mov    %esp,%ebp
f0104086:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104089:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010408c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104090:	8b 45 08             	mov    0x8(%ebp),%eax
f0104093:	89 04 24             	mov    %eax,(%esp)
f0104096:	e8 82 ff ff ff       	call   f010401d <vcprintf>
	va_end(ap);

	return cnt;
}
f010409b:	c9                   	leave  
f010409c:	c3                   	ret    

f010409d <ccprintf>:

int
ccprintf(const char *fmt, ...)
{
f010409d:	55                   	push   %ebp
f010409e:	89 e5                	mov    %esp,%ebp
f01040a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01040a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = cvcprintf(fmt, ap);
f01040a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01040ad:	89 04 24             	mov    %eax,(%esp)
f01040b0:	e8 9b ff ff ff       	call   f0104050 <cvcprintf>
	va_end(ap);

	return cnt;
}
f01040b5:	c9                   	leave  
f01040b6:	c3                   	ret    
f01040b7:	66 90                	xchg   %ax,%ax
f01040b9:	66 90                	xchg   %ax,%ax
f01040bb:	66 90                	xchg   %ax,%ax
f01040bd:	66 90                	xchg   %ax,%ax
f01040bf:	90                   	nop

f01040c0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01040c0:	55                   	push   %ebp
f01040c1:	89 e5                	mov    %esp,%ebp
f01040c3:	57                   	push   %edi
f01040c4:	56                   	push   %esi
f01040c5:	53                   	push   %ebx
f01040c6:	83 ec 0c             	sub    $0xc,%esp
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	   
	(thiscpu->cpu_ts).ts_esp0 = KSTACKTOP - ( thiscpu->cpu_id ) * ( KSTKGAP + KSTKSIZE ) ;
f01040c9:	e8 eb 2f 00 00       	call   f01070b9 <cpunum>
f01040ce:	89 c3                	mov    %eax,%ebx
f01040d0:	e8 e4 2f 00 00       	call   f01070b9 <cpunum>
f01040d5:	6b db 74             	imul   $0x74,%ebx,%ebx
f01040d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01040db:	0f b6 80 20 10 24 f0 	movzbl -0xfdbefe0(%eax),%eax
f01040e2:	f7 d8                	neg    %eax
f01040e4:	c1 e0 10             	shl    $0x10,%eax
f01040e7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01040ec:	89 83 30 10 24 f0    	mov    %eax,-0xfdbefd0(%ebx)
	(thiscpu->cpu_ts).ts_ss0 = GD_KD;
f01040f2:	e8 c2 2f 00 00       	call   f01070b9 <cpunum>
f01040f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040fa:	66 c7 80 34 10 24 f0 	movw   $0x10,-0xfdbefcc(%eax)
f0104101:	10 00 

	gdt[(thiscpu->cpu_id)+(GD_TSS0 >> 3)] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0104103:	e8 b1 2f 00 00       	call   f01070b9 <cpunum>
f0104108:	6b c0 74             	imul   $0x74,%eax,%eax
f010410b:	0f b6 98 20 10 24 f0 	movzbl -0xfdbefe0(%eax),%ebx
f0104112:	83 c3 05             	add    $0x5,%ebx
f0104115:	e8 9f 2f 00 00       	call   f01070b9 <cpunum>
f010411a:	89 c7                	mov    %eax,%edi
f010411c:	e8 98 2f 00 00       	call   f01070b9 <cpunum>
f0104121:	89 c6                	mov    %eax,%esi
f0104123:	e8 91 2f 00 00       	call   f01070b9 <cpunum>
f0104128:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f010412f:	f0 67 00 
f0104132:	6b ff 74             	imul   $0x74,%edi,%edi
f0104135:	81 c7 2c 10 24 f0    	add    $0xf024102c,%edi
f010413b:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f0104142:	f0 
f0104143:	6b d6 74             	imul   $0x74,%esi,%edx
f0104146:	81 c2 2c 10 24 f0    	add    $0xf024102c,%edx
f010414c:	c1 ea 10             	shr    $0x10,%edx
f010414f:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0104156:	c6 04 dd 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%ebx,8)
f010415d:	99 
f010415e:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0104165:	40 
f0104166:	6b c0 74             	imul   $0x74,%eax,%eax
f0104169:	05 2c 10 24 f0       	add    $0xf024102c,%eax
f010416e:	c1 e8 18             	shr    $0x18,%eax
f0104171:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(thiscpu->cpu_id)+(GD_TSS0 >> 3)].sd_s = 0;
f0104178:	e8 3c 2f 00 00       	call   f01070b9 <cpunum>
f010417d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104180:	0f b6 80 20 10 24 f0 	movzbl -0xfdbefe0(%eax),%eax
f0104187:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f010418e:	ef 

	ltr(GD_TSS0 + ( thiscpu->cpu_id ) * 8 );
f010418f:	e8 25 2f 00 00       	call   f01070b9 <cpunum>
f0104194:	6b c0 74             	imul   $0x74,%eax,%eax
f0104197:	0f b6 80 20 10 24 f0 	movzbl -0xfdbefe0(%eax),%eax
f010419e:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01041a5:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01041a8:	b8 aa 23 12 f0       	mov    $0xf01223aa,%eax
f01041ad:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01041b0:	83 c4 0c             	add    $0xc,%esp
f01041b3:	5b                   	pop    %ebx
f01041b4:	5e                   	pop    %esi
f01041b5:	5f                   	pop    %edi
f01041b6:	5d                   	pop    %ebp
f01041b7:	c3                   	ret    

f01041b8 <trap_init>:
}


void
trap_init(void)
{
f01041b8:	55                   	push   %ebp
f01041b9:	89 e5                	mov    %esp,%ebp
f01041bb:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
		
	long* ptr ;
	for ( ptr = vec ; ptr < vec_end ; ptr+=2 ) {
f01041be:	b8 b4 23 12 f0       	mov    $0xf01223b4,%eax
f01041c3:	eb 14                	jmp    f01041d9 <trap_init+0x21>
		if ( ptr[0] == -1 ) break ;
f01041c5:	8b 10                	mov    (%eax),%edx
f01041c7:	83 fa ff             	cmp    $0xffffffff,%edx
f01041ca:	74 14                	je     f01041e0 <trap_init+0x28>
		handler_entry[ ptr[1] ] = ptr[0] ;	
f01041cc:	8b 48 04             	mov    0x4(%eax),%ecx
f01041cf:	89 14 8d a0 fe 23 f0 	mov    %edx,-0xfdc0160(,%ecx,4)
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
		
	long* ptr ;
	for ( ptr = vec ; ptr < vec_end ; ptr+=2 ) {
f01041d6:	83 c0 08             	add    $0x8,%eax
f01041d9:	3d d4 24 12 f0       	cmp    $0xf01224d4,%eax
f01041de:	72 e5                	jb     f01041c5 <trap_init+0xd>
		if ( ptr[0] == -1 ) break ;
		handler_entry[ ptr[1] ] = ptr[0] ;	
	}
	
	
	SETGATE( idt[0] , 0 , GD_KT , handler_entry[0] , 0 ) ;  
f01041e0:	a1 a0 fe 23 f0       	mov    0xf023fea0,%eax
f01041e5:	66 a3 60 f2 23 f0    	mov    %ax,0xf023f260
f01041eb:	66 c7 05 62 f2 23 f0 	movw   $0x8,0xf023f262
f01041f2:	08 00 
f01041f4:	c6 05 64 f2 23 f0 00 	movb   $0x0,0xf023f264
f01041fb:	c6 05 65 f2 23 f0 8e 	movb   $0x8e,0xf023f265
f0104202:	c1 e8 10             	shr    $0x10,%eax
f0104205:	66 a3 66 f2 23 f0    	mov    %ax,0xf023f266
	SETGATE( idt[1] , 0 , GD_KT , handler_entry[1] , 0 ) ;  
f010420b:	a1 a4 fe 23 f0       	mov    0xf023fea4,%eax
f0104210:	66 a3 68 f2 23 f0    	mov    %ax,0xf023f268
f0104216:	66 c7 05 6a f2 23 f0 	movw   $0x8,0xf023f26a
f010421d:	08 00 
f010421f:	c6 05 6c f2 23 f0 00 	movb   $0x0,0xf023f26c
f0104226:	c6 05 6d f2 23 f0 8e 	movb   $0x8e,0xf023f26d
f010422d:	c1 e8 10             	shr    $0x10,%eax
f0104230:	66 a3 6e f2 23 f0    	mov    %ax,0xf023f26e
	SETGATE( idt[2] , 0 , GD_KT , handler_entry[2] , 0 ) ;  
f0104236:	a1 a8 fe 23 f0       	mov    0xf023fea8,%eax
f010423b:	66 a3 70 f2 23 f0    	mov    %ax,0xf023f270
f0104241:	66 c7 05 72 f2 23 f0 	movw   $0x8,0xf023f272
f0104248:	08 00 
f010424a:	c6 05 74 f2 23 f0 00 	movb   $0x0,0xf023f274
f0104251:	c6 05 75 f2 23 f0 8e 	movb   $0x8e,0xf023f275
f0104258:	c1 e8 10             	shr    $0x10,%eax
f010425b:	66 a3 76 f2 23 f0    	mov    %ax,0xf023f276
	SETGATE( idt[3] , 1 , GD_KT , handler_entry[3] , 3 ) ;  
f0104261:	a1 ac fe 23 f0       	mov    0xf023feac,%eax
f0104266:	66 a3 78 f2 23 f0    	mov    %ax,0xf023f278
f010426c:	66 c7 05 7a f2 23 f0 	movw   $0x8,0xf023f27a
f0104273:	08 00 
f0104275:	c6 05 7c f2 23 f0 00 	movb   $0x0,0xf023f27c
f010427c:	c6 05 7d f2 23 f0 ef 	movb   $0xef,0xf023f27d
f0104283:	c1 e8 10             	shr    $0x10,%eax
f0104286:	66 a3 7e f2 23 f0    	mov    %ax,0xf023f27e
	SETGATE( idt[4] , 1 , GD_KT , handler_entry[4] , 0 ) ;  
f010428c:	a1 b0 fe 23 f0       	mov    0xf023feb0,%eax
f0104291:	66 a3 80 f2 23 f0    	mov    %ax,0xf023f280
f0104297:	66 c7 05 82 f2 23 f0 	movw   $0x8,0xf023f282
f010429e:	08 00 
f01042a0:	c6 05 84 f2 23 f0 00 	movb   $0x0,0xf023f284
f01042a7:	c6 05 85 f2 23 f0 8f 	movb   $0x8f,0xf023f285
f01042ae:	c1 e8 10             	shr    $0x10,%eax
f01042b1:	66 a3 86 f2 23 f0    	mov    %ax,0xf023f286
	SETGATE( idt[5] , 0 , GD_KT , handler_entry[5] , 0 ) ;  
f01042b7:	a1 b4 fe 23 f0       	mov    0xf023feb4,%eax
f01042bc:	66 a3 88 f2 23 f0    	mov    %ax,0xf023f288
f01042c2:	66 c7 05 8a f2 23 f0 	movw   $0x8,0xf023f28a
f01042c9:	08 00 
f01042cb:	c6 05 8c f2 23 f0 00 	movb   $0x0,0xf023f28c
f01042d2:	c6 05 8d f2 23 f0 8e 	movb   $0x8e,0xf023f28d
f01042d9:	c1 e8 10             	shr    $0x10,%eax
f01042dc:	66 a3 8e f2 23 f0    	mov    %ax,0xf023f28e
	SETGATE( idt[6] , 0 , GD_KT , handler_entry[6] , 0 ) ;  
f01042e2:	a1 b8 fe 23 f0       	mov    0xf023feb8,%eax
f01042e7:	66 a3 90 f2 23 f0    	mov    %ax,0xf023f290
f01042ed:	66 c7 05 92 f2 23 f0 	movw   $0x8,0xf023f292
f01042f4:	08 00 
f01042f6:	c6 05 94 f2 23 f0 00 	movb   $0x0,0xf023f294
f01042fd:	c6 05 95 f2 23 f0 8e 	movb   $0x8e,0xf023f295
f0104304:	c1 e8 10             	shr    $0x10,%eax
f0104307:	66 a3 96 f2 23 f0    	mov    %ax,0xf023f296
	SETGATE( idt[7] , 0 , GD_KT , handler_entry[7] , 0 ) ;  
f010430d:	a1 bc fe 23 f0       	mov    0xf023febc,%eax
f0104312:	66 a3 98 f2 23 f0    	mov    %ax,0xf023f298
f0104318:	66 c7 05 9a f2 23 f0 	movw   $0x8,0xf023f29a
f010431f:	08 00 
f0104321:	c6 05 9c f2 23 f0 00 	movb   $0x0,0xf023f29c
f0104328:	c6 05 9d f2 23 f0 8e 	movb   $0x8e,0xf023f29d
f010432f:	c1 e8 10             	shr    $0x10,%eax
f0104332:	66 a3 9e f2 23 f0    	mov    %ax,0xf023f29e
	SETGATE( idt[8] , 0 , GD_KT , handler_entry[8] , 0 ) ;  
f0104338:	a1 c0 fe 23 f0       	mov    0xf023fec0,%eax
f010433d:	66 a3 a0 f2 23 f0    	mov    %ax,0xf023f2a0
f0104343:	66 c7 05 a2 f2 23 f0 	movw   $0x8,0xf023f2a2
f010434a:	08 00 
f010434c:	c6 05 a4 f2 23 f0 00 	movb   $0x0,0xf023f2a4
f0104353:	c6 05 a5 f2 23 f0 8e 	movb   $0x8e,0xf023f2a5
f010435a:	c1 e8 10             	shr    $0x10,%eax
f010435d:	66 a3 a6 f2 23 f0    	mov    %ax,0xf023f2a6
	SETGATE( idt[10] , 0 , GD_KT , handler_entry[10] , 0 ) ;  
f0104363:	a1 c8 fe 23 f0       	mov    0xf023fec8,%eax
f0104368:	66 a3 b0 f2 23 f0    	mov    %ax,0xf023f2b0
f010436e:	66 c7 05 b2 f2 23 f0 	movw   $0x8,0xf023f2b2
f0104375:	08 00 
f0104377:	c6 05 b4 f2 23 f0 00 	movb   $0x0,0xf023f2b4
f010437e:	c6 05 b5 f2 23 f0 8e 	movb   $0x8e,0xf023f2b5
f0104385:	c1 e8 10             	shr    $0x10,%eax
f0104388:	66 a3 b6 f2 23 f0    	mov    %ax,0xf023f2b6
	SETGATE( idt[11] , 0 , GD_KT , handler_entry[11] , 0 ) ;  
f010438e:	a1 cc fe 23 f0       	mov    0xf023fecc,%eax
f0104393:	66 a3 b8 f2 23 f0    	mov    %ax,0xf023f2b8
f0104399:	66 c7 05 ba f2 23 f0 	movw   $0x8,0xf023f2ba
f01043a0:	08 00 
f01043a2:	c6 05 bc f2 23 f0 00 	movb   $0x0,0xf023f2bc
f01043a9:	c6 05 bd f2 23 f0 8e 	movb   $0x8e,0xf023f2bd
f01043b0:	c1 e8 10             	shr    $0x10,%eax
f01043b3:	66 a3 be f2 23 f0    	mov    %ax,0xf023f2be
	SETGATE( idt[12] , 0 , GD_KT , handler_entry[12] , 0 ) ;  
f01043b9:	a1 d0 fe 23 f0       	mov    0xf023fed0,%eax
f01043be:	66 a3 c0 f2 23 f0    	mov    %ax,0xf023f2c0
f01043c4:	66 c7 05 c2 f2 23 f0 	movw   $0x8,0xf023f2c2
f01043cb:	08 00 
f01043cd:	c6 05 c4 f2 23 f0 00 	movb   $0x0,0xf023f2c4
f01043d4:	c6 05 c5 f2 23 f0 8e 	movb   $0x8e,0xf023f2c5
f01043db:	c1 e8 10             	shr    $0x10,%eax
f01043de:	66 a3 c6 f2 23 f0    	mov    %ax,0xf023f2c6
	SETGATE( idt[13] , 0 , GD_KT , handler_entry[13] , 0 ) ;  
f01043e4:	a1 d4 fe 23 f0       	mov    0xf023fed4,%eax
f01043e9:	66 a3 c8 f2 23 f0    	mov    %ax,0xf023f2c8
f01043ef:	66 c7 05 ca f2 23 f0 	movw   $0x8,0xf023f2ca
f01043f6:	08 00 
f01043f8:	c6 05 cc f2 23 f0 00 	movb   $0x0,0xf023f2cc
f01043ff:	c6 05 cd f2 23 f0 8e 	movb   $0x8e,0xf023f2cd
f0104406:	c1 e8 10             	shr    $0x10,%eax
f0104409:	66 a3 ce f2 23 f0    	mov    %ax,0xf023f2ce
	SETGATE( idt[14] , 0 , GD_KT , handler_entry[14] , 0 ) ;  
f010440f:	a1 d8 fe 23 f0       	mov    0xf023fed8,%eax
f0104414:	66 a3 d0 f2 23 f0    	mov    %ax,0xf023f2d0
f010441a:	66 c7 05 d2 f2 23 f0 	movw   $0x8,0xf023f2d2
f0104421:	08 00 
f0104423:	c6 05 d4 f2 23 f0 00 	movb   $0x0,0xf023f2d4
f010442a:	c6 05 d5 f2 23 f0 8e 	movb   $0x8e,0xf023f2d5
f0104431:	c1 e8 10             	shr    $0x10,%eax
f0104434:	66 a3 d6 f2 23 f0    	mov    %ax,0xf023f2d6
	SETGATE( idt[16] , 0 , GD_KT , handler_entry[16] , 0 ) ;  
f010443a:	a1 e0 fe 23 f0       	mov    0xf023fee0,%eax
f010443f:	66 a3 e0 f2 23 f0    	mov    %ax,0xf023f2e0
f0104445:	66 c7 05 e2 f2 23 f0 	movw   $0x8,0xf023f2e2
f010444c:	08 00 
f010444e:	c6 05 e4 f2 23 f0 00 	movb   $0x0,0xf023f2e4
f0104455:	c6 05 e5 f2 23 f0 8e 	movb   $0x8e,0xf023f2e5
f010445c:	c1 e8 10             	shr    $0x10,%eax
f010445f:	66 a3 e6 f2 23 f0    	mov    %ax,0xf023f2e6
	SETGATE( idt[17] , 0 , GD_KT , handler_entry[17] , 0 ) ;  
f0104465:	a1 e4 fe 23 f0       	mov    0xf023fee4,%eax
f010446a:	66 a3 e8 f2 23 f0    	mov    %ax,0xf023f2e8
f0104470:	66 c7 05 ea f2 23 f0 	movw   $0x8,0xf023f2ea
f0104477:	08 00 
f0104479:	c6 05 ec f2 23 f0 00 	movb   $0x0,0xf023f2ec
f0104480:	c6 05 ed f2 23 f0 8e 	movb   $0x8e,0xf023f2ed
f0104487:	c1 e8 10             	shr    $0x10,%eax
f010448a:	66 a3 ee f2 23 f0    	mov    %ax,0xf023f2ee
	SETGATE( idt[18] , 0 , GD_KT , handler_entry[18] , 0 ) ;  
f0104490:	a1 e8 fe 23 f0       	mov    0xf023fee8,%eax
f0104495:	66 a3 f0 f2 23 f0    	mov    %ax,0xf023f2f0
f010449b:	66 c7 05 f2 f2 23 f0 	movw   $0x8,0xf023f2f2
f01044a2:	08 00 
f01044a4:	c6 05 f4 f2 23 f0 00 	movb   $0x0,0xf023f2f4
f01044ab:	c6 05 f5 f2 23 f0 8e 	movb   $0x8e,0xf023f2f5
f01044b2:	c1 e8 10             	shr    $0x10,%eax
f01044b5:	66 a3 f6 f2 23 f0    	mov    %ax,0xf023f2f6
	SETGATE( idt[19] , 0 , GD_KT , handler_entry[19] , 0 ) ;  
f01044bb:	a1 ec fe 23 f0       	mov    0xf023feec,%eax
f01044c0:	66 a3 f8 f2 23 f0    	mov    %ax,0xf023f2f8
f01044c6:	66 c7 05 fa f2 23 f0 	movw   $0x8,0xf023f2fa
f01044cd:	08 00 
f01044cf:	c6 05 fc f2 23 f0 00 	movb   $0x0,0xf023f2fc
f01044d6:	c6 05 fd f2 23 f0 8e 	movb   $0x8e,0xf023f2fd
f01044dd:	c1 e8 10             	shr    $0x10,%eax
f01044e0:	66 a3 fe f2 23 f0    	mov    %ax,0xf023f2fe
	SETGATE( idt[48] , 0 , GD_KT , handler_entry[48] , 3 ) ;
f01044e6:	a1 60 ff 23 f0       	mov    0xf023ff60,%eax
f01044eb:	66 a3 e0 f3 23 f0    	mov    %ax,0xf023f3e0
f01044f1:	66 c7 05 e2 f3 23 f0 	movw   $0x8,0xf023f3e2
f01044f8:	08 00 
f01044fa:	c6 05 e4 f3 23 f0 00 	movb   $0x0,0xf023f3e4
f0104501:	c6 05 e5 f3 23 f0 ee 	movb   $0xee,0xf023f3e5
f0104508:	c1 e8 10             	shr    $0x10,%eax
f010450b:	66 a3 e6 f3 23 f0    	mov    %ax,0xf023f3e6
	
	SETGATE( idt[32] , 0 , GD_KT , handler_entry[32] , 3 ) ;  
f0104511:	a1 20 ff 23 f0       	mov    0xf023ff20,%eax
f0104516:	66 a3 60 f3 23 f0    	mov    %ax,0xf023f360
f010451c:	66 c7 05 62 f3 23 f0 	movw   $0x8,0xf023f362
f0104523:	08 00 
f0104525:	c6 05 64 f3 23 f0 00 	movb   $0x0,0xf023f364
f010452c:	c6 05 65 f3 23 f0 ee 	movb   $0xee,0xf023f365
f0104533:	c1 e8 10             	shr    $0x10,%eax
f0104536:	66 a3 66 f3 23 f0    	mov    %ax,0xf023f366
	SETGATE( idt[33] , 0 , GD_KT , handler_entry[33] , 3 ) ;  
f010453c:	a1 24 ff 23 f0       	mov    0xf023ff24,%eax
f0104541:	66 a3 68 f3 23 f0    	mov    %ax,0xf023f368
f0104547:	66 c7 05 6a f3 23 f0 	movw   $0x8,0xf023f36a
f010454e:	08 00 
f0104550:	c6 05 6c f3 23 f0 00 	movb   $0x0,0xf023f36c
f0104557:	c6 05 6d f3 23 f0 ee 	movb   $0xee,0xf023f36d
f010455e:	c1 e8 10             	shr    $0x10,%eax
f0104561:	66 a3 6e f3 23 f0    	mov    %ax,0xf023f36e
	SETGATE( idt[34] , 0 , GD_KT , handler_entry[34] , 3 ) ;  
f0104567:	a1 28 ff 23 f0       	mov    0xf023ff28,%eax
f010456c:	66 a3 70 f3 23 f0    	mov    %ax,0xf023f370
f0104572:	66 c7 05 72 f3 23 f0 	movw   $0x8,0xf023f372
f0104579:	08 00 
f010457b:	c6 05 74 f3 23 f0 00 	movb   $0x0,0xf023f374
f0104582:	c6 05 75 f3 23 f0 ee 	movb   $0xee,0xf023f375
f0104589:	c1 e8 10             	shr    $0x10,%eax
f010458c:	66 a3 76 f3 23 f0    	mov    %ax,0xf023f376
	SETGATE( idt[35] , 0 , GD_KT , handler_entry[35] , 3 ) ;  
f0104592:	a1 2c ff 23 f0       	mov    0xf023ff2c,%eax
f0104597:	66 a3 78 f3 23 f0    	mov    %ax,0xf023f378
f010459d:	66 c7 05 7a f3 23 f0 	movw   $0x8,0xf023f37a
f01045a4:	08 00 
f01045a6:	c6 05 7c f3 23 f0 00 	movb   $0x0,0xf023f37c
f01045ad:	c6 05 7d f3 23 f0 ee 	movb   $0xee,0xf023f37d
f01045b4:	c1 e8 10             	shr    $0x10,%eax
f01045b7:	66 a3 7e f3 23 f0    	mov    %ax,0xf023f37e
	SETGATE( idt[36] , 0 , GD_KT , handler_entry[36] , 3 ) ;  
f01045bd:	a1 30 ff 23 f0       	mov    0xf023ff30,%eax
f01045c2:	66 a3 80 f3 23 f0    	mov    %ax,0xf023f380
f01045c8:	66 c7 05 82 f3 23 f0 	movw   $0x8,0xf023f382
f01045cf:	08 00 
f01045d1:	c6 05 84 f3 23 f0 00 	movb   $0x0,0xf023f384
f01045d8:	c6 05 85 f3 23 f0 ee 	movb   $0xee,0xf023f385
f01045df:	c1 e8 10             	shr    $0x10,%eax
f01045e2:	66 a3 86 f3 23 f0    	mov    %ax,0xf023f386
	SETGATE( idt[37] , 0 , GD_KT , handler_entry[37] , 3 ) ;  
f01045e8:	a1 34 ff 23 f0       	mov    0xf023ff34,%eax
f01045ed:	66 a3 88 f3 23 f0    	mov    %ax,0xf023f388
f01045f3:	66 c7 05 8a f3 23 f0 	movw   $0x8,0xf023f38a
f01045fa:	08 00 
f01045fc:	c6 05 8c f3 23 f0 00 	movb   $0x0,0xf023f38c
f0104603:	c6 05 8d f3 23 f0 ee 	movb   $0xee,0xf023f38d
f010460a:	c1 e8 10             	shr    $0x10,%eax
f010460d:	66 a3 8e f3 23 f0    	mov    %ax,0xf023f38e
	SETGATE( idt[38] , 0 , GD_KT , handler_entry[38] , 3 ) ;  
f0104613:	a1 38 ff 23 f0       	mov    0xf023ff38,%eax
f0104618:	66 a3 90 f3 23 f0    	mov    %ax,0xf023f390
f010461e:	66 c7 05 92 f3 23 f0 	movw   $0x8,0xf023f392
f0104625:	08 00 
f0104627:	c6 05 94 f3 23 f0 00 	movb   $0x0,0xf023f394
f010462e:	c6 05 95 f3 23 f0 ee 	movb   $0xee,0xf023f395
f0104635:	c1 e8 10             	shr    $0x10,%eax
f0104638:	66 a3 96 f3 23 f0    	mov    %ax,0xf023f396
	SETGATE( idt[39] , 0 , GD_KT , handler_entry[39] , 3 ) ;  
f010463e:	a1 3c ff 23 f0       	mov    0xf023ff3c,%eax
f0104643:	66 a3 98 f3 23 f0    	mov    %ax,0xf023f398
f0104649:	66 c7 05 9a f3 23 f0 	movw   $0x8,0xf023f39a
f0104650:	08 00 
f0104652:	c6 05 9c f3 23 f0 00 	movb   $0x0,0xf023f39c
f0104659:	c6 05 9d f3 23 f0 ee 	movb   $0xee,0xf023f39d
f0104660:	c1 e8 10             	shr    $0x10,%eax
f0104663:	66 a3 9e f3 23 f0    	mov    %ax,0xf023f39e
	SETGATE( idt[40] , 0 , GD_KT , handler_entry[40] , 3 ) ;  
f0104669:	a1 40 ff 23 f0       	mov    0xf023ff40,%eax
f010466e:	66 a3 a0 f3 23 f0    	mov    %ax,0xf023f3a0
f0104674:	66 c7 05 a2 f3 23 f0 	movw   $0x8,0xf023f3a2
f010467b:	08 00 
f010467d:	c6 05 a4 f3 23 f0 00 	movb   $0x0,0xf023f3a4
f0104684:	c6 05 a5 f3 23 f0 ee 	movb   $0xee,0xf023f3a5
f010468b:	c1 e8 10             	shr    $0x10,%eax
f010468e:	66 a3 a6 f3 23 f0    	mov    %ax,0xf023f3a6
	SETGATE( idt[41] , 0 , GD_KT , handler_entry[41] , 3 ) ;  
f0104694:	a1 44 ff 23 f0       	mov    0xf023ff44,%eax
f0104699:	66 a3 a8 f3 23 f0    	mov    %ax,0xf023f3a8
f010469f:	66 c7 05 aa f3 23 f0 	movw   $0x8,0xf023f3aa
f01046a6:	08 00 
f01046a8:	c6 05 ac f3 23 f0 00 	movb   $0x0,0xf023f3ac
f01046af:	c6 05 ad f3 23 f0 ee 	movb   $0xee,0xf023f3ad
f01046b6:	c1 e8 10             	shr    $0x10,%eax
f01046b9:	66 a3 ae f3 23 f0    	mov    %ax,0xf023f3ae
	SETGATE( idt[42] , 0 , GD_KT , handler_entry[42] , 3 ) ;  
f01046bf:	a1 48 ff 23 f0       	mov    0xf023ff48,%eax
f01046c4:	66 a3 b0 f3 23 f0    	mov    %ax,0xf023f3b0
f01046ca:	66 c7 05 b2 f3 23 f0 	movw   $0x8,0xf023f3b2
f01046d1:	08 00 
f01046d3:	c6 05 b4 f3 23 f0 00 	movb   $0x0,0xf023f3b4
f01046da:	c6 05 b5 f3 23 f0 ee 	movb   $0xee,0xf023f3b5
f01046e1:	c1 e8 10             	shr    $0x10,%eax
f01046e4:	66 a3 b6 f3 23 f0    	mov    %ax,0xf023f3b6
	SETGATE( idt[43] , 0 , GD_KT , handler_entry[43] , 3 ) ;  
f01046ea:	a1 4c ff 23 f0       	mov    0xf023ff4c,%eax
f01046ef:	66 a3 b8 f3 23 f0    	mov    %ax,0xf023f3b8
f01046f5:	66 c7 05 ba f3 23 f0 	movw   $0x8,0xf023f3ba
f01046fc:	08 00 
f01046fe:	c6 05 bc f3 23 f0 00 	movb   $0x0,0xf023f3bc
f0104705:	c6 05 bd f3 23 f0 ee 	movb   $0xee,0xf023f3bd
f010470c:	c1 e8 10             	shr    $0x10,%eax
f010470f:	66 a3 be f3 23 f0    	mov    %ax,0xf023f3be
	SETGATE( idt[44] , 0 , GD_KT , handler_entry[44] , 3 ) ;  
f0104715:	a1 50 ff 23 f0       	mov    0xf023ff50,%eax
f010471a:	66 a3 c0 f3 23 f0    	mov    %ax,0xf023f3c0
f0104720:	66 c7 05 c2 f3 23 f0 	movw   $0x8,0xf023f3c2
f0104727:	08 00 
f0104729:	c6 05 c4 f3 23 f0 00 	movb   $0x0,0xf023f3c4
f0104730:	c6 05 c5 f3 23 f0 ee 	movb   $0xee,0xf023f3c5
f0104737:	c1 e8 10             	shr    $0x10,%eax
f010473a:	66 a3 c6 f3 23 f0    	mov    %ax,0xf023f3c6
	SETGATE( idt[45] , 0 , GD_KT , handler_entry[45] , 3 ) ;  
f0104740:	a1 54 ff 23 f0       	mov    0xf023ff54,%eax
f0104745:	66 a3 c8 f3 23 f0    	mov    %ax,0xf023f3c8
f010474b:	66 c7 05 ca f3 23 f0 	movw   $0x8,0xf023f3ca
f0104752:	08 00 
f0104754:	c6 05 cc f3 23 f0 00 	movb   $0x0,0xf023f3cc
f010475b:	c6 05 cd f3 23 f0 ee 	movb   $0xee,0xf023f3cd
f0104762:	c1 e8 10             	shr    $0x10,%eax
f0104765:	66 a3 ce f3 23 f0    	mov    %ax,0xf023f3ce
	SETGATE( idt[46] , 0 , GD_KT , handler_entry[46] , 3 ) ;  
f010476b:	a1 58 ff 23 f0       	mov    0xf023ff58,%eax
f0104770:	66 a3 d0 f3 23 f0    	mov    %ax,0xf023f3d0
f0104776:	66 c7 05 d2 f3 23 f0 	movw   $0x8,0xf023f3d2
f010477d:	08 00 
f010477f:	c6 05 d4 f3 23 f0 00 	movb   $0x0,0xf023f3d4
f0104786:	c6 05 d5 f3 23 f0 ee 	movb   $0xee,0xf023f3d5
f010478d:	c1 e8 10             	shr    $0x10,%eax
f0104790:	66 a3 d6 f3 23 f0    	mov    %ax,0xf023f3d6
	SETGATE( idt[47] , 0 , GD_KT , handler_entry[47] , 3 ) ;  
f0104796:	a1 5c ff 23 f0       	mov    0xf023ff5c,%eax
f010479b:	66 a3 d8 f3 23 f0    	mov    %ax,0xf023f3d8
f01047a1:	66 c7 05 da f3 23 f0 	movw   $0x8,0xf023f3da
f01047a8:	08 00 
f01047aa:	c6 05 dc f3 23 f0 00 	movb   $0x0,0xf023f3dc
f01047b1:	c6 05 dd f3 23 f0 ee 	movb   $0xee,0xf023f3dd
f01047b8:	c1 e8 10             	shr    $0x10,%eax
f01047bb:	66 a3 de f3 23 f0    	mov    %ax,0xf023f3de
        SETGATE( idt[18] , 0 , GD_KT , IMCHK , 0 ) ;
        SETGATE( idt[19] , 0 , GD_KT , ISIMDERR , 0 ) ;
        SETGATE( idt[48] , 1 , GD_KT , ISYSCALL , 3 ) ;
	*/
        // Per-CPU setup 
	trap_init_percpu();
f01047c1:	e8 fa f8 ff ff       	call   f01040c0 <trap_init_percpu>
}
f01047c6:	c9                   	leave  
f01047c7:	c3                   	ret    

f01047c8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01047c8:	55                   	push   %ebp
f01047c9:	89 e5                	mov    %esp,%ebp
f01047cb:	53                   	push   %ebx
f01047cc:	83 ec 14             	sub    $0x14,%esp
f01047cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01047d2:	8b 03                	mov    (%ebx),%eax
f01047d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047d8:	c7 04 24 94 8a 10 f0 	movl   $0xf0108a94,(%esp)
f01047df:	e8 9f f8 ff ff       	call   f0104083 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01047e4:	8b 43 04             	mov    0x4(%ebx),%eax
f01047e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047eb:	c7 04 24 a3 8a 10 f0 	movl   $0xf0108aa3,(%esp)
f01047f2:	e8 8c f8 ff ff       	call   f0104083 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01047f7:	8b 43 08             	mov    0x8(%ebx),%eax
f01047fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047fe:	c7 04 24 b2 8a 10 f0 	movl   $0xf0108ab2,(%esp)
f0104805:	e8 79 f8 ff ff       	call   f0104083 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010480a:	8b 43 0c             	mov    0xc(%ebx),%eax
f010480d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104811:	c7 04 24 c1 8a 10 f0 	movl   $0xf0108ac1,(%esp)
f0104818:	e8 66 f8 ff ff       	call   f0104083 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010481d:	8b 43 10             	mov    0x10(%ebx),%eax
f0104820:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104824:	c7 04 24 d0 8a 10 f0 	movl   $0xf0108ad0,(%esp)
f010482b:	e8 53 f8 ff ff       	call   f0104083 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104830:	8b 43 14             	mov    0x14(%ebx),%eax
f0104833:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104837:	c7 04 24 df 8a 10 f0 	movl   $0xf0108adf,(%esp)
f010483e:	e8 40 f8 ff ff       	call   f0104083 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104843:	8b 43 18             	mov    0x18(%ebx),%eax
f0104846:	89 44 24 04          	mov    %eax,0x4(%esp)
f010484a:	c7 04 24 ee 8a 10 f0 	movl   $0xf0108aee,(%esp)
f0104851:	e8 2d f8 ff ff       	call   f0104083 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104856:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104859:	89 44 24 04          	mov    %eax,0x4(%esp)
f010485d:	c7 04 24 fd 8a 10 f0 	movl   $0xf0108afd,(%esp)
f0104864:	e8 1a f8 ff ff       	call   f0104083 <cprintf>
}
f0104869:	83 c4 14             	add    $0x14,%esp
f010486c:	5b                   	pop    %ebx
f010486d:	5d                   	pop    %ebp
f010486e:	c3                   	ret    

f010486f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010486f:	55                   	push   %ebp
f0104870:	89 e5                	mov    %esp,%ebp
f0104872:	56                   	push   %esi
f0104873:	53                   	push   %ebx
f0104874:	83 ec 10             	sub    $0x10,%esp
f0104877:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010487a:	e8 3a 28 00 00       	call   f01070b9 <cpunum>
f010487f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104883:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104887:	c7 04 24 61 8b 10 f0 	movl   $0xf0108b61,(%esp)
f010488e:	e8 f0 f7 ff ff       	call   f0104083 <cprintf>
	print_regs(&tf->tf_regs);
f0104893:	89 1c 24             	mov    %ebx,(%esp)
f0104896:	e8 2d ff ff ff       	call   f01047c8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010489b:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010489f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a3:	c7 04 24 7f 8b 10 f0 	movl   $0xf0108b7f,(%esp)
f01048aa:	e8 d4 f7 ff ff       	call   f0104083 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01048af:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01048b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048b7:	c7 04 24 92 8b 10 f0 	movl   $0xf0108b92,(%esp)
f01048be:	e8 c0 f7 ff ff       	call   f0104083 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048c3:	8b 43 28             	mov    0x28(%ebx),%eax
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};
	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01048c6:	83 f8 13             	cmp    $0x13,%eax
f01048c9:	77 09                	ja     f01048d4 <print_trapframe+0x65>
		return excnames[trapno];
f01048cb:	8b 14 85 20 8e 10 f0 	mov    -0xfef71e0(,%eax,4),%edx
f01048d2:	eb 1f                	jmp    f01048f3 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01048d4:	83 f8 30             	cmp    $0x30,%eax
f01048d7:	74 15                	je     f01048ee <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01048d9:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01048dc:	83 fa 0f             	cmp    $0xf,%edx
f01048df:	ba 18 8b 10 f0       	mov    $0xf0108b18,%edx
f01048e4:	b9 2b 8b 10 f0       	mov    $0xf0108b2b,%ecx
f01048e9:	0f 47 d1             	cmova  %ecx,%edx
f01048ec:	eb 05                	jmp    f01048f3 <print_trapframe+0x84>
		"SIMD Floating-Point Exception"
	};
	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01048ee:	ba 0c 8b 10 f0       	mov    $0xf0108b0c,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048f3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048fb:	c7 04 24 a5 8b 10 f0 	movl   $0xf0108ba5,(%esp)
f0104902:	e8 7c f7 ff ff       	call   f0104083 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104907:	3b 1d 60 fa 23 f0    	cmp    0xf023fa60,%ebx
f010490d:	75 19                	jne    f0104928 <print_trapframe+0xb9>
f010490f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104913:	75 13                	jne    f0104928 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104915:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104918:	89 44 24 04          	mov    %eax,0x4(%esp)
f010491c:	c7 04 24 b7 8b 10 f0 	movl   $0xf0108bb7,(%esp)
f0104923:	e8 5b f7 ff ff       	call   f0104083 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104928:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010492b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010492f:	c7 04 24 c6 8b 10 f0 	movl   $0xf0108bc6,(%esp)
f0104936:	e8 48 f7 ff ff       	call   f0104083 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010493b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010493f:	75 51                	jne    f0104992 <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104941:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104944:	89 c2                	mov    %eax,%edx
f0104946:	83 e2 01             	and    $0x1,%edx
f0104949:	ba 3a 8b 10 f0       	mov    $0xf0108b3a,%edx
f010494e:	b9 45 8b 10 f0       	mov    $0xf0108b45,%ecx
f0104953:	0f 45 ca             	cmovne %edx,%ecx
f0104956:	89 c2                	mov    %eax,%edx
f0104958:	83 e2 02             	and    $0x2,%edx
f010495b:	ba 51 8b 10 f0       	mov    $0xf0108b51,%edx
f0104960:	be 57 8b 10 f0       	mov    $0xf0108b57,%esi
f0104965:	0f 44 d6             	cmove  %esi,%edx
f0104968:	83 e0 04             	and    $0x4,%eax
f010496b:	b8 5c 8b 10 f0       	mov    $0xf0108b5c,%eax
f0104970:	be af 8c 10 f0       	mov    $0xf0108caf,%esi
f0104975:	0f 44 c6             	cmove  %esi,%eax
f0104978:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010497c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104980:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104984:	c7 04 24 d4 8b 10 f0 	movl   $0xf0108bd4,(%esp)
f010498b:	e8 f3 f6 ff ff       	call   f0104083 <cprintf>
f0104990:	eb 0c                	jmp    f010499e <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104992:	c7 04 24 e9 89 10 f0 	movl   $0xf01089e9,(%esp)
f0104999:	e8 e5 f6 ff ff       	call   f0104083 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010499e:	8b 43 30             	mov    0x30(%ebx),%eax
f01049a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049a5:	c7 04 24 e3 8b 10 f0 	movl   $0xf0108be3,(%esp)
f01049ac:	e8 d2 f6 ff ff       	call   f0104083 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01049b1:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01049b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049b9:	c7 04 24 f2 8b 10 f0 	movl   $0xf0108bf2,(%esp)
f01049c0:	e8 be f6 ff ff       	call   f0104083 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01049c5:	8b 43 38             	mov    0x38(%ebx),%eax
f01049c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049cc:	c7 04 24 05 8c 10 f0 	movl   $0xf0108c05,(%esp)
f01049d3:	e8 ab f6 ff ff       	call   f0104083 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01049d8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01049dc:	74 27                	je     f0104a05 <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01049de:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01049e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049e5:	c7 04 24 14 8c 10 f0 	movl   $0xf0108c14,(%esp)
f01049ec:	e8 92 f6 ff ff       	call   f0104083 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01049f1:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01049f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049f9:	c7 04 24 23 8c 10 f0 	movl   $0xf0108c23,(%esp)
f0104a00:	e8 7e f6 ff ff       	call   f0104083 <cprintf>
	}
}
f0104a05:	83 c4 10             	add    $0x10,%esp
f0104a08:	5b                   	pop    %ebx
f0104a09:	5e                   	pop    %esi
f0104a0a:	5d                   	pop    %ebp
f0104a0b:	c3                   	ret    

f0104a0c <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104a0c:	55                   	push   %ebp
f0104a0d:	89 e5                	mov    %esp,%ebp
f0104a0f:	57                   	push   %edi
f0104a10:	56                   	push   %esi
f0104a11:	53                   	push   %ebx
f0104a12:	83 ec 2c             	sub    $0x2c,%esp
f0104a15:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104a18:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ( ! ( tf->tf_err & 0x4 ) ) {
f0104a1b:	f6 43 2c 04          	testb  $0x4,0x2c(%ebx)
f0104a1f:	75 1c                	jne    f0104a3d <page_fault_handler+0x31>
		panic("Page fault caused by Kernel!\n");
f0104a21:	c7 44 24 08 36 8c 10 	movl   $0xf0108c36,0x8(%esp)
f0104a28:	f0 
f0104a29:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
f0104a30:	00 
f0104a31:	c7 04 24 54 8c 10 f0 	movl   $0xf0108c54,(%esp)
f0104a38:	e8 03 b6 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if ( curenv->env_pgfault_upcall != NULL ) {
f0104a3d:	e8 77 26 00 00       	call   f01070b9 <cpunum>
f0104a42:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a45:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104a4b:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104a4f:	0f 84 8c 01 00 00    	je     f0104be1 <page_fault_handler+0x1d5>
		//cprintf(" page_fault_handler : now esp point to %08x\n",tf->tf_esp); 
		//cprintf(" page_fault_handler : now eip point to %08x\n",tf->tf_eip); 
		char * stack_ptr ;
		if ( ! ( ( tf->tf_esp < UXSTACKTOP ) && ( tf->tf_esp >= UXSTACKTOP - PGSIZE ) ) ) {
f0104a55:	8b 73 3c             	mov    0x3c(%ebx),%esi
f0104a58:	8d 86 00 10 40 11    	lea    0x11401000(%esi),%eax
f0104a5e:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0104a63:	0f 86 c4 00 00 00    	jbe    f0104b2d <page_fault_handler+0x121>
			stack_ptr = ( char * )  UXSTACKTOP ; 
			struct UTrapframe * utf_ptr = ( struct UTrapframe * ) ( stack_ptr - sizeof( struct UTrapframe ) ) ;  
			
			user_mem_assert( curenv , utf_ptr , sizeof( struct UTrapframe) , PTE_U | PTE_P | PTE_W ) ;		
f0104a69:	e8 4b 26 00 00       	call   f01070b9 <cpunum>
f0104a6e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104a75:	00 
f0104a76:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104a7d:	00 
f0104a7e:	c7 44 24 04 cc ff bf 	movl   $0xeebfffcc,0x4(%esp)
f0104a85:	ee 
f0104a86:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a89:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104a8f:	89 04 24             	mov    %eax,(%esp)
f0104a92:	e8 71 eb ff ff       	call   f0103608 <user_mem_assert>
			utf_ptr->utf_fault_va = fault_va ; 
f0104a97:	89 3d cc ff bf ee    	mov    %edi,0xeebfffcc
			utf_ptr->utf_err = tf->tf_err ;
f0104a9d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104aa0:	a3 d0 ff bf ee       	mov    %eax,0xeebfffd0
			utf_ptr->utf_regs = tf->tf_regs ; 
f0104aa5:	8b 03                	mov    (%ebx),%eax
f0104aa7:	a3 d4 ff bf ee       	mov    %eax,0xeebfffd4
f0104aac:	8b 43 04             	mov    0x4(%ebx),%eax
f0104aaf:	a3 d8 ff bf ee       	mov    %eax,0xeebfffd8
f0104ab4:	8b 43 08             	mov    0x8(%ebx),%eax
f0104ab7:	a3 dc ff bf ee       	mov    %eax,0xeebfffdc
f0104abc:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104abf:	a3 e0 ff bf ee       	mov    %eax,0xeebfffe0
f0104ac4:	8b 43 10             	mov    0x10(%ebx),%eax
f0104ac7:	a3 e4 ff bf ee       	mov    %eax,0xeebfffe4
f0104acc:	8b 43 14             	mov    0x14(%ebx),%eax
f0104acf:	a3 e8 ff bf ee       	mov    %eax,0xeebfffe8
f0104ad4:	8b 43 18             	mov    0x18(%ebx),%eax
f0104ad7:	a3 ec ff bf ee       	mov    %eax,0xeebfffec
f0104adc:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104adf:	a3 f0 ff bf ee       	mov    %eax,0xeebffff0
			utf_ptr->utf_eip = tf->tf_eip ; 
f0104ae4:	8b 43 30             	mov    0x30(%ebx),%eax
f0104ae7:	a3 f4 ff bf ee       	mov    %eax,0xeebffff4
			utf_ptr->utf_eflags = tf->tf_eflags ; 
f0104aec:	8b 43 38             	mov    0x38(%ebx),%eax
f0104aef:	a3 f8 ff bf ee       	mov    %eax,0xeebffff8
			utf_ptr->utf_esp = tf->tf_esp ; 
f0104af4:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104af7:	a3 fc ff bf ee       	mov    %eax,0xeebffffc
			tf->tf_esp = (uint32_t) ( utf_ptr ) ; 
f0104afc:	c7 43 3c cc ff bf ee 	movl   $0xeebfffcc,0x3c(%ebx)
			tf->tf_eip = ( uint32_t ) ( curenv->env_pgfault_upcall ) ;
f0104b03:	e8 b1 25 00 00       	call   f01070b9 <cpunum>
f0104b08:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b0b:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104b11:	8b 40 64             	mov    0x64(%eax),%eax
f0104b14:	89 43 30             	mov    %eax,0x30(%ebx)
			env_run(curenv);	 								
f0104b17:	e8 9d 25 00 00       	call   f01070b9 <cpunum>
f0104b1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1f:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104b25:	89 04 24             	mov    %eax,(%esp)
f0104b28:	e8 ec f2 ff ff       	call   f0103e19 <env_run>
		} else {
			stack_ptr = ( char * ) ( tf->tf_esp ) ;
			struct UTrapframe * utf_ptr = ( struct UTrapframe * ) ( stack_ptr - 4 - sizeof( struct UTrapframe ) ) ;  
f0104b2d:	8d 46 c8             	lea    -0x38(%esi),%eax
f0104b30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			user_mem_assert( curenv , utf_ptr , 4 + sizeof( struct UTrapframe) , PTE_U | PTE_P | PTE_W ) ;		
f0104b33:	e8 81 25 00 00       	call   f01070b9 <cpunum>
f0104b38:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104b3f:	00 
f0104b40:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
f0104b47:	00 
f0104b48:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b4b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b52:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104b58:	89 04 24             	mov    %eax,(%esp)
f0104b5b:	e8 a8 ea ff ff       	call   f0103608 <user_mem_assert>
			* ( ( int * ) ( stack_ptr - 4 ) ) = 0 ;  
f0104b60:	c7 46 fc 00 00 00 00 	movl   $0x0,-0x4(%esi)
			utf_ptr->utf_fault_va = fault_va ; 
f0104b67:	89 7e c8             	mov    %edi,-0x38(%esi)
			utf_ptr->utf_err = tf->tf_err ;
f0104b6a:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104b6d:	89 46 cc             	mov    %eax,-0x34(%esi)
			utf_ptr->utf_regs = tf->tf_regs ; 
f0104b70:	8b 03                	mov    (%ebx),%eax
f0104b72:	89 46 d0             	mov    %eax,-0x30(%esi)
f0104b75:	8b 43 04             	mov    0x4(%ebx),%eax
f0104b78:	89 46 d4             	mov    %eax,-0x2c(%esi)
f0104b7b:	8b 43 08             	mov    0x8(%ebx),%eax
f0104b7e:	89 46 d8             	mov    %eax,-0x28(%esi)
f0104b81:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104b84:	89 46 dc             	mov    %eax,-0x24(%esi)
f0104b87:	8b 43 10             	mov    0x10(%ebx),%eax
f0104b8a:	89 46 e0             	mov    %eax,-0x20(%esi)
f0104b8d:	8b 43 14             	mov    0x14(%ebx),%eax
f0104b90:	89 46 e4             	mov    %eax,-0x1c(%esi)
f0104b93:	8b 43 18             	mov    0x18(%ebx),%eax
f0104b96:	89 46 e8             	mov    %eax,-0x18(%esi)
f0104b99:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104b9c:	89 46 ec             	mov    %eax,-0x14(%esi)
			utf_ptr->utf_eip = tf->tf_eip ; 
f0104b9f:	8b 43 30             	mov    0x30(%ebx),%eax
f0104ba2:	89 46 f0             	mov    %eax,-0x10(%esi)
			utf_ptr->utf_eflags = tf->tf_eflags ; 
f0104ba5:	8b 43 38             	mov    0x38(%ebx),%eax
f0104ba8:	89 46 f4             	mov    %eax,-0xc(%esi)
			utf_ptr->utf_esp = tf->tf_esp ; 
f0104bab:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104bae:	89 46 f8             	mov    %eax,-0x8(%esi)
			tf->tf_esp = (uint32_t) ( utf_ptr ) ; 
f0104bb1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104bb4:	89 53 3c             	mov    %edx,0x3c(%ebx)
			tf->tf_eip = ( uint32_t ) ( curenv->env_pgfault_upcall ) ;
f0104bb7:	e8 fd 24 00 00       	call   f01070b9 <cpunum>
f0104bbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bbf:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104bc5:	8b 40 64             	mov    0x64(%eax),%eax
f0104bc8:	89 43 30             	mov    %eax,0x30(%ebx)
			env_run(curenv);	 								
f0104bcb:	e8 e9 24 00 00       	call   f01070b9 <cpunum>
f0104bd0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd3:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104bd9:	89 04 24             	mov    %eax,(%esp)
f0104bdc:	e8 38 f2 ff ff       	call   f0103e19 <env_run>
		} 	
		
	}
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104be1:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104be4:	e8 d0 24 00 00       	call   f01070b9 <cpunum>
		} 	
		
	}
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104be9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104bed:	89 7c 24 08          	mov    %edi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104bf1:	6b c0 74             	imul   $0x74,%eax,%eax
		} 	
		
	}
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bf4:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104bfa:	8b 40 48             	mov    0x48(%eax),%eax
f0104bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c01:	c7 04 24 fc 8d 10 f0 	movl   $0xf0108dfc,(%esp)
f0104c08:	e8 76 f4 ff ff       	call   f0104083 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104c0d:	89 1c 24             	mov    %ebx,(%esp)
f0104c10:	e8 5a fc ff ff       	call   f010486f <print_trapframe>
	env_destroy(curenv);
f0104c15:	e8 9f 24 00 00       	call   f01070b9 <cpunum>
f0104c1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c1d:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104c23:	89 04 24             	mov    %eax,(%esp)
f0104c26:	e8 3f f1 ff ff       	call   f0103d6a <env_destroy>
}
f0104c2b:	83 c4 2c             	add    $0x2c,%esp
f0104c2e:	5b                   	pop    %ebx
f0104c2f:	5e                   	pop    %esi
f0104c30:	5f                   	pop    %edi
f0104c31:	5d                   	pop    %ebp
f0104c32:	c3                   	ret    

f0104c33 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104c33:	55                   	push   %ebp
f0104c34:	89 e5                	mov    %esp,%ebp
f0104c36:	57                   	push   %edi
f0104c37:	56                   	push   %esi
f0104c38:	83 ec 20             	sub    $0x20,%esp
f0104c3b:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104c3e:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104c3f:	83 3d 80 fe 23 f0 00 	cmpl   $0x0,0xf023fe80
f0104c46:	74 01                	je     f0104c49 <trap+0x16>
		asm volatile("hlt");
f0104c48:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104c49:	e8 6b 24 00 00       	call   f01070b9 <cpunum>
f0104c4e:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c51:	81 c2 20 10 24 f0    	add    $0xf0241020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104c57:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c5c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104c60:	83 f8 02             	cmp    $0x2,%eax
f0104c63:	75 0c                	jne    f0104c71 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104c65:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0104c6c:	e8 c6 26 00 00       	call   f0107337 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104c71:	9c                   	pushf  
f0104c72:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104c73:	f6 c4 02             	test   $0x2,%ah
f0104c76:	74 24                	je     f0104c9c <trap+0x69>
f0104c78:	c7 44 24 0c 60 8c 10 	movl   $0xf0108c60,0xc(%esp)
f0104c7f:	f0 
f0104c80:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0104c87:	f0 
f0104c88:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
f0104c8f:	00 
f0104c90:	c7 04 24 54 8c 10 f0 	movl   $0xf0108c54,(%esp)
f0104c97:	e8 a4 b3 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104c9c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104ca0:	83 e0 03             	and    $0x3,%eax
f0104ca3:	66 83 f8 03          	cmp    $0x3,%ax
f0104ca7:	0f 85 a7 00 00 00    	jne    f0104d54 <trap+0x121>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104cad:	e8 07 24 00 00       	call   f01070b9 <cpunum>
f0104cb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cb5:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0104cbc:	75 24                	jne    f0104ce2 <trap+0xaf>
f0104cbe:	c7 44 24 0c 79 8c 10 	movl   $0xf0108c79,0xc(%esp)
f0104cc5:	f0 
f0104cc6:	c7 44 24 08 2f 87 10 	movl   $0xf010872f,0x8(%esp)
f0104ccd:	f0 
f0104cce:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0104cd5:	00 
f0104cd6:	c7 04 24 54 8c 10 f0 	movl   $0xf0108c54,(%esp)
f0104cdd:	e8 5e b3 ff ff       	call   f0100040 <_panic>
f0104ce2:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f0104ce9:	e8 49 26 00 00       	call   f0107337 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104cee:	e8 c6 23 00 00       	call   f01070b9 <cpunum>
f0104cf3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cf6:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104cfc:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104d00:	75 2d                	jne    f0104d2f <trap+0xfc>
			env_free(curenv);
f0104d02:	e8 b2 23 00 00       	call   f01070b9 <cpunum>
f0104d07:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d0a:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104d10:	89 04 24             	mov    %eax,(%esp)
f0104d13:	e8 4d ee ff ff       	call   f0103b65 <env_free>
			curenv = NULL;
f0104d18:	e8 9c 23 00 00       	call   f01070b9 <cpunum>
f0104d1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d20:	c7 80 28 10 24 f0 00 	movl   $0x0,-0xfdbefd8(%eax)
f0104d27:	00 00 00 
			sched_yield();
f0104d2a:	e8 75 03 00 00       	call   f01050a4 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104d2f:	e8 85 23 00 00       	call   f01070b9 <cpunum>
f0104d34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d37:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104d3d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104d42:	89 c7                	mov    %eax,%edi
f0104d44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104d46:	e8 6e 23 00 00       	call   f01070b9 <cpunum>
f0104d4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d4e:	8b b0 28 10 24 f0    	mov    -0xfdbefd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104d54:	89 35 60 fa 23 f0    	mov    %esi,0xf023fa60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104d5a:	8b 46 28             	mov    0x28(%esi),%eax
f0104d5d:	83 f8 27             	cmp    $0x27,%eax
f0104d60:	75 19                	jne    f0104d7b <trap+0x148>
		cprintf("Spurious interrupt on irq 7\n");
f0104d62:	c7 04 24 80 8c 10 f0 	movl   $0xf0108c80,(%esp)
f0104d69:	e8 15 f3 ff ff       	call   f0104083 <cprintf>
		print_trapframe(tf);
f0104d6e:	89 34 24             	mov    %esi,(%esp)
f0104d71:	e8 f9 fa ff ff       	call   f010486f <print_trapframe>
f0104d76:	e9 c1 00 00 00       	jmp    f0104e3c <trap+0x209>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
        
	if ( ( tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER ) ) {
f0104d7b:	83 f8 20             	cmp    $0x20,%eax
f0104d7e:	66 90                	xchg   %ax,%ax
f0104d80:	75 0a                	jne    f0104d8c <trap+0x159>
		lapic_eoi();
f0104d82:	e8 7f 24 00 00       	call   f0107206 <lapic_eoi>
		sched_yield();
f0104d87:	e8 18 03 00 00       	call   f01050a4 <sched_yield>
		return ;
	}

	if (tf->tf_trapno == T_PGFLT ) {
f0104d8c:	83 f8 0e             	cmp    $0xe,%eax
f0104d8f:	90                   	nop
f0104d90:	75 0d                	jne    f0104d9f <trap+0x16c>
		page_fault_handler( tf ) ;
f0104d92:	89 34 24             	mov    %esi,(%esp)
f0104d95:	e8 72 fc ff ff       	call   f0104a0c <page_fault_handler>
f0104d9a:	e9 9d 00 00 00       	jmp    f0104e3c <trap+0x209>
		return ; 
	}	
	if (tf->tf_trapno == T_BRKPT ) {
f0104d9f:	83 f8 03             	cmp    $0x3,%eax
f0104da2:	75 20                	jne    f0104dc4 <trap+0x191>
		monitor(tf);
f0104da4:	89 34 24             	mov    %esi,(%esp)
f0104da7:	e8 4e bc ff ff       	call   f01009fa <monitor>
		env_destroy(curenv);
f0104dac:	e8 08 23 00 00       	call   f01070b9 <cpunum>
f0104db1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104db4:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104dba:	89 04 24             	mov    %eax,(%esp)
f0104dbd:	e8 a8 ef ff ff       	call   f0103d6a <env_destroy>
f0104dc2:	eb 78                	jmp    f0104e3c <trap+0x209>
		return ;
	}
	if (tf->tf_trapno == T_SYSCALL ) {	
f0104dc4:	83 f8 30             	cmp    $0x30,%eax
f0104dc7:	75 32                	jne    f0104dfb <trap+0x1c8>
		(tf->tf_regs).reg_eax = 
	        syscall( (tf->tf_regs).reg_eax , 
f0104dc9:	8b 46 04             	mov    0x4(%esi),%eax
f0104dcc:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104dd0:	8b 06                	mov    (%esi),%eax
f0104dd2:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104dd6:	8b 46 10             	mov    0x10(%esi),%eax
f0104dd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104ddd:	8b 46 18             	mov    0x18(%esi),%eax
f0104de0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104de4:	8b 46 14             	mov    0x14(%esi),%eax
f0104de7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104deb:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104dee:	89 04 24             	mov    %eax,(%esp)
f0104df1:	e8 aa 03 00 00       	call   f01051a0 <syscall>
		monitor(tf);
		env_destroy(curenv);
		return ;
	}
	if (tf->tf_trapno == T_SYSCALL ) {	
		(tf->tf_regs).reg_eax = 
f0104df6:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104df9:	eb 41                	jmp    f0104e3c <trap+0x209>
			 (tf->tf_regs).reg_edi , 
			 (tf->tf_regs).reg_esi ) ;
		return ; 
	}	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104dfb:	89 34 24             	mov    %esi,(%esp)
f0104dfe:	e8 6c fa ff ff       	call   f010486f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104e03:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104e08:	75 1c                	jne    f0104e26 <trap+0x1f3>
		panic("unhandled trap in kernel");
f0104e0a:	c7 44 24 08 9d 8c 10 	movl   $0xf0108c9d,0x8(%esp)
f0104e11:	f0 
f0104e12:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0104e19:	00 
f0104e1a:	c7 04 24 54 8c 10 f0 	movl   $0xf0108c54,(%esp)
f0104e21:	e8 1a b2 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104e26:	e8 8e 22 00 00       	call   f01070b9 <cpunum>
f0104e2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e2e:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104e34:	89 04 24             	mov    %eax,(%esp)
f0104e37:	e8 2e ef ff ff       	call   f0103d6a <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104e3c:	e8 78 22 00 00       	call   f01070b9 <cpunum>
f0104e41:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e44:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0104e4b:	74 2a                	je     f0104e77 <trap+0x244>
f0104e4d:	e8 67 22 00 00       	call   f01070b9 <cpunum>
f0104e52:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e55:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104e5b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e5f:	75 16                	jne    f0104e77 <trap+0x244>
		env_run(curenv);
f0104e61:	e8 53 22 00 00       	call   f01070b9 <cpunum>
f0104e66:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e69:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0104e6f:	89 04 24             	mov    %eax,(%esp)
f0104e72:	e8 a2 ef ff ff       	call   f0103e19 <env_run>
	else
		sched_yield();
f0104e77:	e8 28 02 00 00       	call   f01050a4 <sched_yield>

f0104e7c <IDIVIDE>:
.data
.global vec;
.long vec;
vec:

TRAPHANDLER_NOEC(IDIVIDE    , 0)		// divide error
f0104e7c:	6a 00                	push   $0x0
f0104e7e:	6a 00                	push   $0x0
f0104e80:	e9 4f d6 01 00       	jmp    f01224d4 <_alltraps>
f0104e85:	90                   	nop

f0104e86 <IDEBUG>:
TRAPHANDLER_NOEC(IDEBUG     , 1)		// debug exception
f0104e86:	6a 00                	push   $0x0
f0104e88:	6a 01                	push   $0x1
f0104e8a:	e9 45 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104e8f:	90                   	nop

f0104e90 <INMI>:
TRAPHANDLER_NOEC(INMI       , 2)		// non-maskable interrupt
f0104e90:	6a 00                	push   $0x0
f0104e92:	6a 02                	push   $0x2
f0104e94:	e9 3b d6 01 00       	jmp    f01224d4 <_alltraps>
f0104e99:	90                   	nop

f0104e9a <IBRKPT>:
TRAPHANDLER_NOEC(IBRKPT     , 3)		// breakpoint
f0104e9a:	6a 00                	push   $0x0
f0104e9c:	6a 03                	push   $0x3
f0104e9e:	e9 31 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104ea3:	90                   	nop

f0104ea4 <IOFLOW>:
TRAPHANDLER_NOEC(IOFLOW     , 4)		// overflow
f0104ea4:	6a 00                	push   $0x0
f0104ea6:	6a 04                	push   $0x4
f0104ea8:	e9 27 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104ead:	90                   	nop

f0104eae <IBOUND>:
TRAPHANDLER_NOEC(IBOUND     , 5)		// bounds check
f0104eae:	6a 00                	push   $0x0
f0104eb0:	6a 05                	push   $0x5
f0104eb2:	e9 1d d6 01 00       	jmp    f01224d4 <_alltraps>
f0104eb7:	90                   	nop

f0104eb8 <IILLOP>:
TRAPHANDLER_NOEC(IILLOP     , 6)		// illegal opcode
f0104eb8:	6a 00                	push   $0x0
f0104eba:	6a 06                	push   $0x6
f0104ebc:	e9 13 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104ec1:	90                   	nop

f0104ec2 <IDEVICE>:
TRAPHANDLER_NOEC(IDEVICE    , 7)		// device not available
f0104ec2:	6a 00                	push   $0x0
f0104ec4:	6a 07                	push   $0x7
f0104ec6:	e9 09 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104ecb:	90                   	nop

f0104ecc <IDBLFLT>:
TRAPHANDLER(IDBLFLT    , 8)		// double fault
f0104ecc:	6a 08                	push   $0x8
f0104ece:	e9 01 d6 01 00       	jmp    f01224d4 <_alltraps>
f0104ed3:	90                   	nop

f0104ed4 <ITSS>:
TRAPHANDLER(ITSS       ,10)		// invalid task switch segment
f0104ed4:	6a 0a                	push   $0xa
f0104ed6:	e9 f9 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104edb:	90                   	nop

f0104edc <ISEGNP>:
TRAPHANDLER(ISEGNP     ,11)		// segment not present
f0104edc:	6a 0b                	push   $0xb
f0104ede:	e9 f1 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104ee3:	90                   	nop

f0104ee4 <ISTACK>:
TRAPHANDLER(ISTACK     ,12)		// stack exception
f0104ee4:	6a 0c                	push   $0xc
f0104ee6:	e9 e9 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104eeb:	90                   	nop

f0104eec <IGPFLT>:
TRAPHANDLER(IGPFLT     ,13)		// general protection fault
f0104eec:	6a 0d                	push   $0xd
f0104eee:	e9 e1 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104ef3:	90                   	nop

f0104ef4 <IPGFLT>:
TRAPHANDLER(IPGFLT     ,14)		// page fault
f0104ef4:	6a 0e                	push   $0xe
f0104ef6:	e9 d9 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104efb:	90                   	nop

f0104efc <IFPERR>:
TRAPHANDLER_NOEC(IFPERR     ,16)		// floating point error
f0104efc:	6a 00                	push   $0x0
f0104efe:	6a 10                	push   $0x10
f0104f00:	e9 cf d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f05:	90                   	nop

f0104f06 <IALIGN>:
TRAPHANDLER(IALIGN     ,17)		// aligment check
f0104f06:	6a 11                	push   $0x11
f0104f08:	e9 c7 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f0d:	90                   	nop

f0104f0e <IMCHK>:
TRAPHANDLER_NOEC(IMCHK      ,18)		// machine check
f0104f0e:	6a 00                	push   $0x0
f0104f10:	6a 12                	push   $0x12
f0104f12:	e9 bd d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f17:	90                   	nop

f0104f18 <ISIMDERR>:
TRAPHANDLER_NOEC(ISIMDERR   ,19)		// SIMD floating point error
f0104f18:	6a 00                	push   $0x0
f0104f1a:	6a 13                	push   $0x13
f0104f1c:	e9 b3 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f21:	90                   	nop

f0104f22 <ISYSCALL>:
TRAPHANDLER_NOEC(ISYSCALL   ,48)
f0104f22:	6a 00                	push   $0x0
f0104f24:	6a 30                	push   $0x30
f0104f26:	e9 a9 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f2b:	90                   	nop

f0104f2c <IRQ0>:
TRAPHANDLER_NOEC(IRQ0,32)
f0104f2c:	6a 00                	push   $0x0
f0104f2e:	6a 20                	push   $0x20
f0104f30:	e9 9f d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f35:	90                   	nop

f0104f36 <IRQ1>:
TRAPHANDLER_NOEC(IRQ1,33)
f0104f36:	6a 00                	push   $0x0
f0104f38:	6a 21                	push   $0x21
f0104f3a:	e9 95 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f3f:	90                   	nop

f0104f40 <IRQ2>:
TRAPHANDLER_NOEC(IRQ2,34)
f0104f40:	6a 00                	push   $0x0
f0104f42:	6a 22                	push   $0x22
f0104f44:	e9 8b d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f49:	90                   	nop

f0104f4a <IRQ3>:
TRAPHANDLER_NOEC(IRQ3,35)
f0104f4a:	6a 00                	push   $0x0
f0104f4c:	6a 23                	push   $0x23
f0104f4e:	e9 81 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f53:	90                   	nop

f0104f54 <IRQ4>:
TRAPHANDLER_NOEC(IRQ4,36)
f0104f54:	6a 00                	push   $0x0
f0104f56:	6a 24                	push   $0x24
f0104f58:	e9 77 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f5d:	90                   	nop

f0104f5e <IRQ5>:
TRAPHANDLER_NOEC(IRQ5,37)
f0104f5e:	6a 00                	push   $0x0
f0104f60:	6a 25                	push   $0x25
f0104f62:	e9 6d d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f67:	90                   	nop

f0104f68 <IRQ6>:
TRAPHANDLER_NOEC(IRQ6,38)
f0104f68:	6a 00                	push   $0x0
f0104f6a:	6a 26                	push   $0x26
f0104f6c:	e9 63 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f71:	90                   	nop

f0104f72 <IRQ7>:
TRAPHANDLER_NOEC(IRQ7,39)
f0104f72:	6a 00                	push   $0x0
f0104f74:	6a 27                	push   $0x27
f0104f76:	e9 59 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f7b:	90                   	nop

f0104f7c <IRQ8>:
TRAPHANDLER_NOEC(IRQ8,40)
f0104f7c:	6a 00                	push   $0x0
f0104f7e:	6a 28                	push   $0x28
f0104f80:	e9 4f d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f85:	90                   	nop

f0104f86 <IRQ9>:
TRAPHANDLER_NOEC(IRQ9,41)
f0104f86:	6a 00                	push   $0x0
f0104f88:	6a 29                	push   $0x29
f0104f8a:	e9 45 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f8f:	90                   	nop

f0104f90 <IRQ10>:
TRAPHANDLER_NOEC(IRQ10,42)
f0104f90:	6a 00                	push   $0x0
f0104f92:	6a 2a                	push   $0x2a
f0104f94:	e9 3b d5 01 00       	jmp    f01224d4 <_alltraps>
f0104f99:	90                   	nop

f0104f9a <IRQ11>:
TRAPHANDLER_NOEC(IRQ11,43)
f0104f9a:	6a 00                	push   $0x0
f0104f9c:	6a 2b                	push   $0x2b
f0104f9e:	e9 31 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104fa3:	90                   	nop

f0104fa4 <IRQ12>:
TRAPHANDLER_NOEC(IRQ12,44)
f0104fa4:	6a 00                	push   $0x0
f0104fa6:	6a 2c                	push   $0x2c
f0104fa8:	e9 27 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104fad:	90                   	nop

f0104fae <IRQ13>:
TRAPHANDLER_NOEC(IRQ13,45)
f0104fae:	6a 00                	push   $0x0
f0104fb0:	6a 2d                	push   $0x2d
f0104fb2:	e9 1d d5 01 00       	jmp    f01224d4 <_alltraps>
f0104fb7:	90                   	nop

f0104fb8 <IRQ14>:
TRAPHANDLER_NOEC(IRQ14,46)
f0104fb8:	6a 00                	push   $0x0
f0104fba:	6a 2e                	push   $0x2e
f0104fbc:	e9 13 d5 01 00       	jmp    f01224d4 <_alltraps>
f0104fc1:	90                   	nop

f0104fc2 <IRQ15>:
TRAPHANDLER_NOEC(IRQ15,47)
f0104fc2:	6a 00                	push   $0x0
f0104fc4:	6a 2f                	push   $0x2f
f0104fc6:	e9 09 d5 01 00       	jmp    f01224d4 <_alltraps>

f0104fcb <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104fcb:	55                   	push   %ebp
f0104fcc:	89 e5                	mov    %esp,%ebp
f0104fce:	83 ec 18             	sub    $0x18,%esp
f0104fd1:	8b 15 48 f2 23 f0    	mov    0xf023f248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104fd7:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104fdc:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104fdf:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104fe2:	83 f9 02             	cmp    $0x2,%ecx
f0104fe5:	76 12                	jbe    f0104ff9 <sched_halt+0x2e>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104fe7:	83 c0 01             	add    $0x1,%eax
f0104fea:	81 c2 88 00 00 00    	add    $0x88,%edx
f0104ff0:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104ff5:	75 e5                	jne    f0104fdc <sched_halt+0x11>
f0104ff7:	eb 07                	jmp    f0105000 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104ff9:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104ffe:	75 1a                	jne    f010501a <sched_halt+0x4f>
		cprintf("No runnable environments in the system!\n");
f0105000:	c7 04 24 70 8e 10 f0 	movl   $0xf0108e70,(%esp)
f0105007:	e8 77 f0 ff ff       	call   f0104083 <cprintf>
		while (1)
			monitor(NULL);
f010500c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105013:	e8 e2 b9 ff ff       	call   f01009fa <monitor>
f0105018:	eb f2                	jmp    f010500c <sched_halt+0x41>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010501a:	e8 9a 20 00 00       	call   f01070b9 <cpunum>
f010501f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105022:	c7 80 28 10 24 f0 00 	movl   $0x0,-0xfdbefd8(%eax)
f0105029:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010502c:	a1 8c fe 23 f0       	mov    0xf023fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0105031:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0105036:	77 20                	ja     f0105058 <sched_halt+0x8d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0105038:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010503c:	c7 44 24 08 e8 77 10 	movl   $0xf01077e8,0x8(%esp)
f0105043:	f0 
f0105044:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f010504b:	00 
f010504c:	c7 04 24 99 8e 10 f0 	movl   $0xf0108e99,(%esp)
f0105053:	e8 e8 af ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0105058:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010505d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0105060:	e8 54 20 00 00       	call   f01070b9 <cpunum>
f0105065:	6b d0 74             	imul   $0x74,%eax,%edx
f0105068:	81 c2 20 10 24 f0    	add    $0xf0241020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010506e:	b8 02 00 00 00       	mov    $0x2,%eax
f0105073:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105077:	c7 04 24 00 25 12 f0 	movl   $0xf0122500,(%esp)
f010507e:	e8 60 23 00 00       	call   f01073e3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105083:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0105085:	e8 2f 20 00 00       	call   f01070b9 <cpunum>
f010508a:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010508d:	8b 80 30 10 24 f0    	mov    -0xfdbefd0(%eax),%eax
f0105093:	bd 00 00 00 00       	mov    $0x0,%ebp
f0105098:	89 c4                	mov    %eax,%esp
f010509a:	6a 00                	push   $0x0
f010509c:	6a 00                	push   $0x0
f010509e:	fb                   	sti    
f010509f:	f4                   	hlt    
f01050a0:	eb fd                	jmp    f010509f <sched_halt+0xd4>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01050a2:	c9                   	leave  
f01050a3:	c3                   	ret    

f01050a4 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01050a4:	55                   	push   %ebp
f01050a5:	89 e5                	mov    %esp,%ebp
f01050a7:	53                   	push   %ebx
f01050a8:	83 ec 14             	sub    $0x14,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	if ( curenv == NULL ) idle = envs ; 
f01050ab:	e8 09 20 00 00       	call   f01070b9 <cpunum>
f01050b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01050b3:	8b 1d 48 f2 23 f0    	mov    0xf023f248,%ebx
f01050b9:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f01050c0:	74 14                	je     f01050d6 <sched_yield+0x32>
			else  idle = curenv + 1 ;
f01050c2:	e8 f2 1f 00 00       	call   f01070b9 <cpunum>
f01050c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ca:	8b 98 28 10 24 f0    	mov    -0xfdbefd8(%eax),%ebx
f01050d0:	81 c3 88 00 00 00    	add    $0x88,%ebx
	for ( ; idle < envs + NENV ; idle ++ ) {
f01050d6:	a1 48 f2 23 f0       	mov    0xf023f248,%eax
f01050db:	05 00 20 02 00       	add    $0x22000,%eax
f01050e0:	eb 14                	jmp    f01050f6 <sched_yield+0x52>
		if ( idle ->env_status == ENV_RUNNABLE ) {
f01050e2:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f01050e6:	75 08                	jne    f01050f0 <sched_yield+0x4c>
			env_run( idle ) ; 
f01050e8:	89 1c 24             	mov    %ebx,(%esp)
f01050eb:	e8 29 ed ff ff       	call   f0103e19 <env_run>
	// below to halt the cpu.

	// LAB 4: Your code here.
	if ( curenv == NULL ) idle = envs ; 
			else  idle = curenv + 1 ;
	for ( ; idle < envs + NENV ; idle ++ ) {
f01050f0:	81 c3 88 00 00 00    	add    $0x88,%ebx
f01050f6:	39 c3                	cmp    %eax,%ebx
f01050f8:	72 e8                	jb     f01050e2 <sched_yield+0x3e>
		if ( idle ->env_status == ENV_RUNNABLE ) {
			env_run( idle ) ; 
	
		}
	}
	if ( curenv != NULL ) {
f01050fa:	e8 ba 1f 00 00       	call   f01070b9 <cpunum>
f01050ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0105102:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0105109:	74 37                	je     f0105142 <sched_yield+0x9e>
		for ( idle = envs ; idle < curenv ; idle ++ ) {
f010510b:	8b 1d 48 f2 23 f0    	mov    0xf023f248,%ebx
f0105111:	eb 14                	jmp    f0105127 <sched_yield+0x83>
			if ( idle->env_status == ENV_RUNNABLE ) {
f0105113:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0105117:	75 08                	jne    f0105121 <sched_yield+0x7d>
				env_run ( idle ) ;
f0105119:	89 1c 24             	mov    %ebx,(%esp)
f010511c:	e8 f8 ec ff ff       	call   f0103e19 <env_run>
			env_run( idle ) ; 
	
		}
	}
	if ( curenv != NULL ) {
		for ( idle = envs ; idle < curenv ; idle ++ ) {
f0105121:	81 c3 88 00 00 00    	add    $0x88,%ebx
f0105127:	e8 8d 1f 00 00       	call   f01070b9 <cpunum>
f010512c:	6b c0 74             	imul   $0x74,%eax,%eax
f010512f:	3b 98 28 10 24 f0    	cmp    -0xfdbefd8(%eax),%ebx
f0105135:	72 dc                	jb     f0105113 <sched_yield+0x6f>
			if ( idle->env_status == ENV_RUNNABLE ) {
				env_run ( idle ) ;
			}
		}	
		idle = envs + NENV ; 
f0105137:	a1 48 f2 23 f0       	mov    0xf023f248,%eax
f010513c:	8d 98 00 20 02 00    	lea    0x22000(%eax),%ebx
	}
	if ( ( curenv ) && ( idle == envs + NENV ) &&
f0105142:	e8 72 1f 00 00       	call   f01070b9 <cpunum>
f0105147:	6b c0 74             	imul   $0x74,%eax,%eax
f010514a:	83 b8 28 10 24 f0 00 	cmpl   $0x0,-0xfdbefd8(%eax)
f0105151:	74 38                	je     f010518b <sched_yield+0xe7>
f0105153:	a1 48 f2 23 f0       	mov    0xf023f248,%eax
f0105158:	05 00 20 02 00       	add    $0x22000,%eax
f010515d:	39 c3                	cmp    %eax,%ebx
f010515f:	75 2a                	jne    f010518b <sched_yield+0xe7>
             ( curenv->env_status == ENV_RUNNING) ) {
f0105161:	e8 53 1f 00 00       	call   f01070b9 <cpunum>
f0105166:	6b c0 74             	imul   $0x74,%eax,%eax
f0105169:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
				env_run ( idle ) ;
			}
		}	
		idle = envs + NENV ; 
	}
	if ( ( curenv ) && ( idle == envs + NENV ) &&
f010516f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0105173:	75 16                	jne    f010518b <sched_yield+0xe7>
             ( curenv->env_status == ENV_RUNNING) ) {
		env_run( curenv ) ; 
f0105175:	e8 3f 1f 00 00       	call   f01070b9 <cpunum>
f010517a:	6b c0 74             	imul   $0x74,%eax,%eax
f010517d:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105183:	89 04 24             	mov    %eax,(%esp)
f0105186:	e8 8e ec ff ff       	call   f0103e19 <env_run>
	}			
	// sched_halt never returns
	sched_halt();
f010518b:	e8 3b fe ff ff       	call   f0104fcb <sched_halt>
}
f0105190:	83 c4 14             	add    $0x14,%esp
f0105193:	5b                   	pop    %ebx
f0105194:	5d                   	pop    %ebp
f0105195:	c3                   	ret    
f0105196:	66 90                	xchg   %ax,%ax
f0105198:	66 90                	xchg   %ax,%ax
f010519a:	66 90                	xchg   %ax,%ax
f010519c:	66 90                	xchg   %ax,%ax
f010519e:	66 90                	xchg   %ax,%ax

f01051a0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01051a0:	55                   	push   %ebp
f01051a1:	89 e5                	mov    %esp,%ebp
f01051a3:	56                   	push   %esi
f01051a4:	53                   	push   %ebx
f01051a5:	83 ec 20             	sub    $0x20,%esp
f01051a8:	8b 45 08             	mov    0x8(%ebp),%eax

	//panic("syscall not implemented");
	//if ( syscallno == SYS_yield){
	//	cprintf("Does it happen?\n");
	//}
	switch (syscallno) {
f01051ab:	83 f8 0c             	cmp    $0xc,%eax
f01051ae:	0f 87 3f 07 00 00    	ja     f01058f3 <syscall+0x753>
f01051b4:	ff 24 85 e0 8e 10 f0 	jmp    *-0xfef7120(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        user_mem_assert( curenv , s , len , PTE_U ) ;	
f01051bb:	e8 f9 1e 00 00       	call   f01070b9 <cpunum>
f01051c0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01051c7:	00 
f01051c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01051cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01051cf:	8b 75 0c             	mov    0xc(%ebp),%esi
f01051d2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01051d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01051d9:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01051df:	89 04 24             	mov    %eax,(%esp)
f01051e2:	e8 21 e4 ff ff       	call   f0103608 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01051e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051ea:	89 44 24 08          	mov    %eax,0x8(%esp)
f01051ee:	8b 45 10             	mov    0x10(%ebp),%eax
f01051f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051f5:	c7 04 24 a6 8e 10 f0 	movl   $0xf0108ea6,(%esp)
f01051fc:	e8 82 ee ff ff       	call   f0104083 <cprintf>
	//	cprintf("Does it happen?\n");
	//}
	switch (syscallno) {
		case SYS_cputs :
			sys_cputs( ( const char * ) a1 , ( size_t ) a2 ); 
			return 0 ; 
f0105201:	b8 00 00 00 00       	mov    $0x0,%eax
f0105206:	e9 08 07 00 00       	jmp    f0105913 <syscall+0x773>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010520b:	e8 25 b4 ff ff       	call   f0100635 <cons_getc>
	switch (syscallno) {
		case SYS_cputs :
			sys_cputs( ( const char * ) a1 , ( size_t ) a2 ); 
			return 0 ; 
		case SYS_cgetc :
			return sys_cgetc();
f0105210:	e9 fe 06 00 00       	jmp    f0105913 <syscall+0x773>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0105215:	e8 9f 1e 00 00       	call   f01070b9 <cpunum>
f010521a:	6b c0 74             	imul   $0x74,%eax,%eax
f010521d:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105223:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs( ( const char * ) a1 , ( size_t ) a2 ); 
			return 0 ; 
		case SYS_cgetc :
			return sys_cgetc();
		case SYS_getenvid:
                        return sys_getenvid();
f0105226:	e9 e8 06 00 00       	jmp    f0105913 <syscall+0x773>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010522b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105232:	00 
f0105233:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105236:	89 44 24 04          	mov    %eax,0x4(%esp)
f010523a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010523d:	89 04 24             	mov    %eax,(%esp)
f0105240:	e8 b7 e4 ff ff       	call   f01036fc <envid2env>
		return r;
f0105245:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0105247:	85 c0                	test   %eax,%eax
f0105249:	78 6e                	js     f01052b9 <syscall+0x119>
		return r;
	if (e == curenv)
f010524b:	e8 69 1e 00 00       	call   f01070b9 <cpunum>
f0105250:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105253:	6b c0 74             	imul   $0x74,%eax,%eax
f0105256:	39 90 28 10 24 f0    	cmp    %edx,-0xfdbefd8(%eax)
f010525c:	75 23                	jne    f0105281 <syscall+0xe1>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010525e:	e8 56 1e 00 00       	call   f01070b9 <cpunum>
f0105263:	6b c0 74             	imul   $0x74,%eax,%eax
f0105266:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f010526c:	8b 40 48             	mov    0x48(%eax),%eax
f010526f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105273:	c7 04 24 ab 8e 10 f0 	movl   $0xf0108eab,(%esp)
f010527a:	e8 04 ee ff ff       	call   f0104083 <cprintf>
f010527f:	eb 28                	jmp    f01052a9 <syscall+0x109>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105281:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105284:	e8 30 1e 00 00       	call   f01070b9 <cpunum>
f0105289:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010528d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105290:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105296:	8b 40 48             	mov    0x48(%eax),%eax
f0105299:	89 44 24 04          	mov    %eax,0x4(%esp)
f010529d:	c7 04 24 c6 8e 10 f0 	movl   $0xf0108ec6,(%esp)
f01052a4:	e8 da ed ff ff       	call   f0104083 <cprintf>
	env_destroy(e);
f01052a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052ac:	89 04 24             	mov    %eax,(%esp)
f01052af:	e8 b6 ea ff ff       	call   f0103d6a <env_destroy>
	return 0;
f01052b4:	ba 00 00 00 00       	mov    $0x0,%edx
		case SYS_cgetc :
			return sys_cgetc();
		case SYS_getenvid:
                        return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy( a1 ) ; 
f01052b9:	89 d0                	mov    %edx,%eax
f01052bb:	e9 53 06 00 00       	jmp    f0105913 <syscall+0x773>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01052c0:	e8 df fd ff ff       	call   f01050a4 <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env * newenv = NULL ; 
f01052c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_alloc = env_alloc( &newenv , curenv->env_id ) ; 
f01052cc:	e8 e8 1d 00 00       	call   f01070b9 <cpunum>
f01052d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01052d4:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01052da:	8b 40 48             	mov    0x48(%eax),%eax
f01052dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01052e4:	89 04 24             	mov    %eax,(%esp)
f01052e7:	e8 20 e5 ff ff       	call   f010380c <env_alloc>
	if ( result_alloc < 0 ) return result_alloc ; 
f01052ec:	89 c2                	mov    %eax,%edx
f01052ee:	85 c0                	test   %eax,%eax
f01052f0:	78 50                	js     f0105342 <syscall+0x1a2>
	memcpy( & ( newenv->env_tf ) , & ( curenv->env_tf ) , sizeof( struct Trapframe ) ) ;
f01052f2:	e8 c2 1d 00 00       	call   f01070b9 <cpunum>
f01052f7:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01052fe:	00 
f01052ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0105302:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105308:	89 44 24 04          	mov    %eax,0x4(%esp)
f010530c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010530f:	89 04 24             	mov    %eax,(%esp)
f0105312:	e8 05 18 00 00       	call   f0106b1c <memcpy>
	newenv->env_status = ENV_NOT_RUNNABLE ; 
f0105317:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010531a:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	(newenv->env_tf).tf_regs.reg_eax = 0 ;
f0105321:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
	(newenv->env_pgfault_upcall) = ( curenv->env_pgfault_upcall);
f0105328:	e8 8c 1d 00 00       	call   f01070b9 <cpunum>
f010532d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105330:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105336:	8b 40 64             	mov    0x64(%eax),%eax
f0105339:	89 43 64             	mov    %eax,0x64(%ebx)
	//cprintf(" sys_exofor : eip is %08x\n",(newenv->env_tf).tf_eip ) ; 
	return ( newenv->env_id ) ;  
f010533c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010533f:	8b 50 48             	mov    0x48(%eax),%edx
			return sys_env_destroy( a1 ) ; 
		case SYS_yield:
			sys_yield();
			return 0 ;	
		case SYS_exofork:
			return sys_exofork() ; 
f0105342:	89 d0                	mov    %edx,%eax
f0105344:	e9 ca 05 00 00       	jmp    f0105913 <syscall+0x773>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
        //cprintf(" sys_page_alloc : %d %08x\n",envid,(uint32_t)va);
	struct Env * tarenv = NULL ; 
f0105349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
f0105350:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105357:	00 
f0105358:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010535b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010535f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105362:	89 04 24             	mov    %eax,(%esp)
f0105365:	e8 92 e3 ff ff       	call   f01036fc <envid2env>
	if ( result_getenv < 0 ) 
f010536a:	85 c0                	test   %eax,%eax
f010536c:	78 6d                	js     f01053db <syscall+0x23b>
		return -E_BAD_ENV ; 	
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
f010536e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105375:	77 6e                	ja     f01053e5 <syscall+0x245>
f0105377:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010537e:	75 6f                	jne    f01053ef <syscall+0x24f>
		return -E_INVAL ; 
	//cprintf("Did it reach here? perm : %08x\n",perm);
        if ( ( ! ( perm & PTE_U ) ) ||
 	     ( ! ( perm & PTE_P ) ) ||
f0105380:	8b 45 14             	mov    0x14(%ebp),%eax
f0105383:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
	if ( result_getenv < 0 ) 
		return -E_BAD_ENV ; 	
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
		return -E_INVAL ; 
	//cprintf("Did it reach here? perm : %08x\n",perm);
        if ( ( ! ( perm & PTE_U ) ) ||
f0105388:	83 f8 05             	cmp    $0x5,%eax
f010538b:	75 6c                	jne    f01053f9 <syscall+0x259>
 	     ( ! ( perm & PTE_P ) ) ||
             ( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f010538d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105394:	e8 d0 bd ff ff       	call   f0101169 <page_alloc>
f0105399:	89 c3                	mov    %eax,%ebx
	if ( pp == NULL ) return -E_NO_MEM ; 
f010539b:	85 c0                	test   %eax,%eax
f010539d:	74 64                	je     f0105403 <syscall+0x263>
	int result_insert = page_insert( tarenv->env_pgdir , pp , va , perm ) ; 
f010539f:	8b 45 14             	mov    0x14(%ebp),%eax
f01053a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01053a6:	8b 45 10             	mov    0x10(%ebp),%eax
f01053a9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01053ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01053b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01053b4:	8b 40 60             	mov    0x60(%eax),%eax
f01053b7:	89 04 24             	mov    %eax,(%esp)
f01053ba:	e8 b2 c0 ff ff       	call   f0101471 <page_insert>
	if ( result_insert < 0 ) {
f01053bf:	85 c0                	test   %eax,%eax
f01053c1:	79 4a                	jns    f010540d <syscall+0x26d>
		pp->pp_ref = 0 ; 
f01053c3:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		page_free(pp);
f01053c9:	89 1c 24             	mov    %ebx,(%esp)
f01053cc:	e8 23 be ff ff       	call   f01011f4 <page_free>
		return -E_NO_MEM ; 
f01053d1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01053d6:	e9 38 05 00 00       	jmp    f0105913 <syscall+0x773>
	// LAB 4: Your code here.
        //cprintf(" sys_page_alloc : %d %08x\n",envid,(uint32_t)va);
	struct Env * tarenv = NULL ; 
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
	if ( result_getenv < 0 ) 
		return -E_BAD_ENV ; 	
f01053db:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01053e0:	e9 2e 05 00 00       	jmp    f0105913 <syscall+0x773>
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
		return -E_INVAL ; 
f01053e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053ea:	e9 24 05 00 00       	jmp    f0105913 <syscall+0x773>
f01053ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053f4:	e9 1a 05 00 00       	jmp    f0105913 <syscall+0x773>
	//cprintf("Did it reach here? perm : %08x\n",perm);
        if ( ( ! ( perm & PTE_U ) ) ||
 	     ( ! ( perm & PTE_P ) ) ||
             ( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
f01053f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053fe:	e9 10 05 00 00       	jmp    f0105913 <syscall+0x773>
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if ( pp == NULL ) return -E_NO_MEM ; 
f0105403:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105408:	e9 06 05 00 00       	jmp    f0105913 <syscall+0x773>
	if ( result_insert < 0 ) {
		pp->pp_ref = 0 ; 
		page_free(pp);
		return -E_NO_MEM ; 
	}
	return 0 ; 
f010540d:	b8 00 00 00 00       	mov    $0x0,%eax
			sys_yield();
			return 0 ;	
		case SYS_exofork:
			return sys_exofork() ; 
		case SYS_page_alloc:
			return sys_page_alloc( ( envid_t ) a1 , ( void * ) a2 , a3 ) ;
f0105412:	e9 fc 04 00 00       	jmp    f0105913 <syscall+0x773>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env * srcenv = NULL ; 
f0105417:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int result_getsrcenv = envid2env( srcenvid , &srcenv  , 1 ) ;
f010541e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105425:	00 
f0105426:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105429:	89 44 24 04          	mov    %eax,0x4(%esp)
f010542d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105430:	89 04 24             	mov    %eax,(%esp)
f0105433:	e8 c4 e2 ff ff       	call   f01036fc <envid2env>
	if ( result_getsrcenv < 0 ) 
f0105438:	85 c0                	test   %eax,%eax
f010543a:	0f 88 ce 00 00 00    	js     f010550e <syscall+0x36e>
		return -E_BAD_ENV ; 	
	struct Env * dstenv = NULL ; 
f0105440:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int result_getdstenv = envid2env( dstenvid , &dstenv  , 1 ) ;
f0105447:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010544e:	00 
f010544f:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105452:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105456:	8b 45 14             	mov    0x14(%ebp),%eax
f0105459:	89 04 24             	mov    %eax,(%esp)
f010545c:	e8 9b e2 ff ff       	call   f01036fc <envid2env>
	if ( result_getdstenv < 0 ) 
f0105461:	85 c0                	test   %eax,%eax
f0105463:	0f 88 af 00 00 00    	js     f0105518 <syscall+0x378>
		return -E_BAD_ENV ; 	
	
	if ( ( ( uint32_t ) srcva >= UTOP ) || ( PGOFF( ( uint32_t ) srcva ) ) ) 
f0105469:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105470:	0f 87 ac 00 00 00    	ja     f0105522 <syscall+0x382>
f0105476:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010547d:	0f 85 a9 00 00 00    	jne    f010552c <syscall+0x38c>
		return -E_INVAL ; 

	if ( ( ( uint32_t ) dstva >= UTOP ) || ( PGOFF( ( uint32_t ) dstva ) ) ) 
f0105483:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010548a:	0f 87 a6 00 00 00    	ja     f0105536 <syscall+0x396>
f0105490:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105497:	0f 85 a3 00 00 00    	jne    f0105540 <syscall+0x3a0>
		return -E_INVAL ; 
       
        if ( ( ! ( perm & PTE_U ) ) ||
 	     ( ! ( perm & PTE_P ) ) ||
f010549d:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01054a0:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
		return -E_INVAL ; 

	if ( ( ( uint32_t ) dstva >= UTOP ) || ( PGOFF( ( uint32_t ) dstva ) ) ) 
		return -E_INVAL ; 
       
        if ( ( ! ( perm & PTE_U ) ) ||
f01054a5:	83 f8 05             	cmp    $0x5,%eax
f01054a8:	0f 85 9c 00 00 00    	jne    f010554a <syscall+0x3aa>
 	     ( ! ( perm & PTE_P ) ) ||
             ( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
	pte_t *srcpte = NULL ;  
f01054ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
f01054b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01054b8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054bc:	8b 45 10             	mov    0x10(%ebp),%eax
f01054bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054c6:	8b 40 60             	mov    0x60(%eax),%eax
f01054c9:	89 04 24             	mov    %eax,(%esp)
f01054cc:	e8 a3 be ff ff       	call   f0101374 <page_lookup>
	if ( pp == NULL ) return -E_INVAL ; 
f01054d1:	85 c0                	test   %eax,%eax
f01054d3:	74 7f                	je     f0105554 <syscall+0x3b4>
	
	if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
f01054d5:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01054d9:	74 08                	je     f01054e3 <syscall+0x343>
f01054db:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01054de:	f6 02 02             	testb  $0x2,(%edx)
f01054e1:	74 7b                	je     f010555e <syscall+0x3be>
		return -E_INVAL ; 

	int result_insert = page_insert( dstenv->env_pgdir , pp , dstva , perm ) ;	
f01054e3:	8b 75 1c             	mov    0x1c(%ebp),%esi
f01054e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01054ea:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01054ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01054f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01054f8:	8b 40 60             	mov    0x60(%eax),%eax
f01054fb:	89 04 24             	mov    %eax,(%esp)
f01054fe:	e8 6e bf ff ff       	call   f0101471 <page_insert>
	if ( result_insert < 0 ) 
		return -E_NO_MEM ; 
f0105503:	c1 f8 1f             	sar    $0x1f,%eax
f0105506:	83 e0 fc             	and    $0xfffffffc,%eax
f0105509:	e9 05 04 00 00       	jmp    f0105913 <syscall+0x773>

	// LAB 4: Your code here.
	struct Env * srcenv = NULL ; 
	int result_getsrcenv = envid2env( srcenvid , &srcenv  , 1 ) ;
	if ( result_getsrcenv < 0 ) 
		return -E_BAD_ENV ; 	
f010550e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105513:	e9 fb 03 00 00       	jmp    f0105913 <syscall+0x773>
	struct Env * dstenv = NULL ; 
	int result_getdstenv = envid2env( dstenvid , &dstenv  , 1 ) ;
	if ( result_getdstenv < 0 ) 
		return -E_BAD_ENV ; 	
f0105518:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010551d:	e9 f1 03 00 00       	jmp    f0105913 <syscall+0x773>
	
	if ( ( ( uint32_t ) srcva >= UTOP ) || ( PGOFF( ( uint32_t ) srcva ) ) ) 
		return -E_INVAL ; 
f0105522:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105527:	e9 e7 03 00 00       	jmp    f0105913 <syscall+0x773>
f010552c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105531:	e9 dd 03 00 00       	jmp    f0105913 <syscall+0x773>

	if ( ( ( uint32_t ) dstva >= UTOP ) || ( PGOFF( ( uint32_t ) dstva ) ) ) 
		return -E_INVAL ; 
f0105536:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010553b:	e9 d3 03 00 00       	jmp    f0105913 <syscall+0x773>
f0105540:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105545:	e9 c9 03 00 00       	jmp    f0105913 <syscall+0x773>
       
        if ( ( ! ( perm & PTE_U ) ) ||
 	     ( ! ( perm & PTE_P ) ) ||
             ( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
f010554a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010554f:	e9 bf 03 00 00       	jmp    f0105913 <syscall+0x773>
	pte_t *srcpte = NULL ;  
	struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
	if ( pp == NULL ) return -E_INVAL ; 
f0105554:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105559:	e9 b5 03 00 00       	jmp    f0105913 <syscall+0x773>
	
	if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
		return -E_INVAL ; 
f010555e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_exofork:
			return sys_exofork() ; 
		case SYS_page_alloc:
			return sys_page_alloc( ( envid_t ) a1 , ( void * ) a2 , a3 ) ;
		case SYS_page_map:
			return sys_page_map( ( envid_t ) a1 , ( void * ) a2 , ( envid_t ) a3 , ( void * ) a4 , a5 ) ;
f0105563:	e9 ab 03 00 00       	jmp    f0105913 <syscall+0x773>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
f0105568:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
f010556f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105576:	00 
f0105577:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010557a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010557e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105581:	89 04 24             	mov    %eax,(%esp)
f0105584:	e8 73 e1 ff ff       	call   f01036fc <envid2env>
	if ( result_getenv < 0 ) 
f0105589:	85 c0                	test   %eax,%eax
f010558b:	78 31                	js     f01055be <syscall+0x41e>
		return -E_BAD_ENV ; 	
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
f010558d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105594:	77 32                	ja     f01055c8 <syscall+0x428>
f0105596:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010559d:	75 33                	jne    f01055d2 <syscall+0x432>
		return -E_INVAL ; 
  	page_remove( tarenv->env_pgdir , va ) ; 	
f010559f:	8b 45 10             	mov    0x10(%ebp),%eax
f01055a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01055a9:	8b 40 60             	mov    0x60(%eax),%eax
f01055ac:	89 04 24             	mov    %eax,(%esp)
f01055af:	e8 6d be ff ff       	call   f0101421 <page_remove>
	return 0 ;
f01055b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01055b9:	e9 55 03 00 00       	jmp    f0105913 <syscall+0x773>

	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
	if ( result_getenv < 0 ) 
		return -E_BAD_ENV ; 	
f01055be:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01055c3:	e9 4b 03 00 00       	jmp    f0105913 <syscall+0x773>
	if ( ( ( uint32_t ) va >= UTOP ) || ( PGOFF( ( uint32_t ) va ) ) ) 
		return -E_INVAL ; 
f01055c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055cd:	e9 41 03 00 00       	jmp    f0105913 <syscall+0x773>
f01055d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc:
			return sys_page_alloc( ( envid_t ) a1 , ( void * ) a2 , a3 ) ;
		case SYS_page_map:
			return sys_page_map( ( envid_t ) a1 , ( void * ) a2 , ( envid_t ) a3 , ( void * ) a4 , a5 ) ;
		case SYS_page_unmap:
			return sys_page_unmap( ( envid_t ) a1 , ( void * ) a2 ) ;
f01055d7:	e9 37 03 00 00       	jmp    f0105913 <syscall+0x773>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
f01055dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
f01055e3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01055ea:	00 
f01055eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01055ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055f2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01055f5:	89 04 24             	mov    %eax,(%esp)
f01055f8:	e8 ff e0 ff ff       	call   f01036fc <envid2env>
	if ( result_getenv < 0 ) return result_getenv ; 
f01055fd:	85 c0                	test   %eax,%eax
f01055ff:	0f 88 0e 03 00 00    	js     f0105913 <syscall+0x773>
	tarenv->env_status = status ;
f0105605:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105608:	8b 75 10             	mov    0x10(%ebp),%esi
f010560b:	89 70 54             	mov    %esi,0x54(%eax)
	return 0 ;  
f010560e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105613:	e9 fb 02 00 00       	jmp    f0105913 <syscall+0x773>
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
f0105618:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;
f010561f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105626:	00 
f0105627:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010562a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010562e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105631:	89 04 24             	mov    %eax,(%esp)
f0105634:	e8 c3 e0 ff ff       	call   f01036fc <envid2env>

	if ( result_getenv < 0 ) 
f0105639:	85 c0                	test   %eax,%eax
f010563b:	78 13                	js     f0105650 <syscall+0x4b0>
		return -E_BAD_ENV ; 
	(tarenv->env_pgfault_upcall) = func ;
f010563d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105640:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105643:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0 ; 
f0105646:	b8 00 00 00 00       	mov    $0x0,%eax
f010564b:	e9 c3 02 00 00       	jmp    f0105913 <syscall+0x773>
	// LAB 4: Your code here.
	struct Env * tarenv = NULL ; 
	int result_getenv = envid2env( envid , &tarenv  , 1 ) ;

	if ( result_getenv < 0 ) 
		return -E_BAD_ENV ; 
f0105650:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		case SYS_page_unmap:
			return sys_page_unmap( ( envid_t ) a1 , ( void * ) a2 ) ;
		case SYS_env_set_status:
			return sys_env_set_status( ( envid_t ) a1 , a2 ) ;   
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall( ( envid_t ) a1 , ( void * ) a2 ) ; 
f0105655:	e9 b9 02 00 00       	jmp    f0105913 <syscall+0x773>
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env * srcenv = curenv ; 
f010565a:	e8 5a 1a 00 00       	call   f01070b9 <cpunum>
f010565f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105662:	8b 98 28 10 24 f0    	mov    -0xfdbefd8(%eax),%ebx
	struct Env * dstenv = NULL ; 
f0105668:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int result_getdstenv = envid2env( envid , &dstenv  , 0 ) ;
f010566f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105676:	00 
f0105677:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010567a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010567e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105681:	89 04 24             	mov    %eax,(%esp)
f0105684:	e8 73 e0 ff ff       	call   f01036fc <envid2env>
	if ( result_getdstenv < 0 ) 
f0105689:	85 c0                	test   %eax,%eax
f010568b:	0f 88 77 01 00 00    	js     f0105808 <syscall+0x668>
		return -E_BAD_ENV ; 	

	if ( (( (uintptr_t)srcva) < UTOP ) && ( PGOFF(srcva) != 0 ) )
f0105691:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105698:	0f 87 63 02 00 00    	ja     f0105901 <syscall+0x761>
f010569e:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01056a5:	0f 85 67 01 00 00    	jne    f0105812 <syscall+0x672>
		 return  -E_INVAL ; 
	
	if (  ( ! ( dstenv->env_ipc_recving ) ) 
f01056ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01056ae:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01056b2:	74 1f                	je     f01056d3 <syscall+0x533>
	     || ( ( dstenv->env_ipc_recving ) && ( dstenv->env_ipc_lockon != curenv->env_id ) && ( dstenv->env_ipc_lockon != 0 ) ) ) {
f01056b4:	8b 70 7c             	mov    0x7c(%eax),%esi
f01056b7:	e8 fd 19 00 00       	call   f01070b9 <cpunum>
f01056bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01056bf:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01056c5:	3b 70 48             	cmp    0x48(%eax),%esi
f01056c8:	74 59                	je     f0105723 <syscall+0x583>
f01056ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01056cd:	83 78 7c 00          	cmpl   $0x0,0x7c(%eax)
f01056d1:	74 50                	je     f0105723 <syscall+0x583>
		curenv->env_ipc_waitnext = dstenv->env_ipc_waithead;
f01056d3:	e8 e1 19 00 00       	call   f01070b9 <cpunum>
f01056d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01056db:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01056e1:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01056e4:	8b 93 84 00 00 00    	mov    0x84(%ebx),%edx
f01056ea:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
		dstenv->env_ipc_waithead = curenv ;  
f01056f0:	e8 c4 19 00 00       	call   f01070b9 <cpunum>
f01056f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01056f8:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01056fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
		curenv->env_status = ENV_NOT_RUNNABLE;
f0105704:	e8 b0 19 00 00       	call   f01070b9 <cpunum>
f0105709:	6b c0 74             	imul   $0x74,%eax,%eax
f010570c:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105712:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
		return -E_IPC_NOT_RECV ; 
f0105719:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
f010571e:	e9 f0 01 00 00       	jmp    f0105913 <syscall+0x773>
	}	
		
	if ( ( ( uintptr_t ) srcva ) < UTOP ) {	
f0105723:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f010572a:	0f 87 8f 00 00 00    	ja     f01057bf <syscall+0x61f>
		if ( ( ! ( perm & PTE_U ) ) ||
				( ! ( perm & PTE_P ) ) ||
f0105730:	8b 55 18             	mov    0x18(%ebp),%edx
f0105733:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
				( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
f0105739:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		curenv->env_status = ENV_NOT_RUNNABLE;
		return -E_IPC_NOT_RECV ; 
	}	
		
	if ( ( ( uintptr_t ) srcva ) < UTOP ) {	
		if ( ( ! ( perm & PTE_U ) ) ||
f010573e:	83 fa 05             	cmp    $0x5,%edx
f0105741:	0f 85 cc 01 00 00    	jne    f0105913 <syscall+0x773>
				( ! ( perm & PTE_P ) ) ||
				( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
		pte_t *srcpte = NULL ;  
f0105747:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
f010574e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105751:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105755:	8b 45 14             	mov    0x14(%ebp),%eax
f0105758:	89 44 24 04          	mov    %eax,0x4(%esp)
f010575c:	8b 43 60             	mov    0x60(%ebx),%eax
f010575f:	89 04 24             	mov    %eax,(%esp)
f0105762:	e8 0d bc ff ff       	call   f0101374 <page_lookup>
f0105767:	89 c2                	mov    %eax,%edx
		if ( pp == NULL ) return -E_INVAL ; 
f0105769:	85 c0                	test   %eax,%eax
f010576b:	74 3d                	je     f01057aa <syscall+0x60a>

		if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
f010576d:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105771:	74 11                	je     f0105784 <syscall+0x5e4>
			return -E_INVAL ; 
f0105773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL ;  			
		pte_t *srcpte = NULL ;  
		struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
		if ( pp == NULL ) return -E_INVAL ; 

		if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
f0105778:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f010577b:	f6 01 02             	testb  $0x2,(%ecx)
f010577e:	0f 84 8f 01 00 00    	je     f0105913 <syscall+0x773>
			return -E_INVAL ; 

		int result_insert = page_insert( dstenv->env_pgdir , pp , dstenv->env_ipc_dstva , perm ) ;	
f0105784:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105787:	8b 75 18             	mov    0x18(%ebp),%esi
f010578a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010578e:	8b 48 6c             	mov    0x6c(%eax),%ecx
f0105791:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105795:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105799:	8b 40 60             	mov    0x60(%eax),%eax
f010579c:	89 04 24             	mov    %eax,(%esp)
f010579f:	e8 cd bc ff ff       	call   f0101471 <page_insert>
		if ( result_insert < 0 ) 
f01057a4:	85 c0                	test   %eax,%eax
f01057a6:	79 17                	jns    f01057bf <syscall+0x61f>
f01057a8:	eb 0b                	jmp    f01057b5 <syscall+0x615>
				( ! ( perm & PTE_P ) ) ||
				( perm & ( ~ ( PTE_U | PTE_P | PTE_AVAIL | PTE_W ) ) ) )
		return -E_INVAL ;  			
		pte_t *srcpte = NULL ;  
		struct PageInfo * pp = page_lookup( srcenv->env_pgdir , srcva , &srcpte) ; 
		if ( pp == NULL ) return -E_INVAL ; 
f01057aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01057af:	90                   	nop
f01057b0:	e9 5e 01 00 00       	jmp    f0105913 <syscall+0x773>
		if ( ( perm & PTE_W ) && ( ! ( ( *srcpte ) & PTE_W ) ) )
			return -E_INVAL ; 

		int result_insert = page_insert( dstenv->env_pgdir , pp , dstenv->env_ipc_dstva , perm ) ;	
		if ( result_insert < 0 ) 
		return -E_NO_MEM ; 
f01057b5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01057ba:	e9 54 01 00 00       	jmp    f0105913 <syscall+0x773>
	}
	dstenv->env_ipc_lockon = 0 ; 
f01057bf:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01057c2:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
	dstenv->env_ipc_recving = false ; 
f01057c9:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	dstenv->env_ipc_from = curenv->env_id ; 
f01057cd:	e8 e7 18 00 00       	call   f01070b9 <cpunum>
f01057d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01057d5:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01057db:	8b 40 48             	mov    0x48(%eax),%eax
f01057de:	89 43 74             	mov    %eax,0x74(%ebx)
	dstenv->env_ipc_value = value ; 
f01057e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01057e4:	8b 75 10             	mov    0x10(%ebp),%esi
f01057e7:	89 70 70             	mov    %esi,0x70(%eax)
	dstenv->env_status = ENV_RUNNABLE ;		
f01057ea:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	dstenv->env_ipc_perm = perm ;
f01057f1:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01057f4:	89 48 78             	mov    %ecx,0x78(%eax)
	(dstenv->env_tf).tf_regs.reg_eax = 0 ;
f01057f7:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0 ;
f01057fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0105803:	e9 0b 01 00 00       	jmp    f0105913 <syscall+0x773>
	// LAB 4: Your code here.
	struct Env * srcenv = curenv ; 
	struct Env * dstenv = NULL ; 
	int result_getdstenv = envid2env( envid , &dstenv  , 0 ) ;
	if ( result_getdstenv < 0 ) 
		return -E_BAD_ENV ; 	
f0105808:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010580d:	e9 01 01 00 00       	jmp    f0105913 <syscall+0x773>

	if ( (( (uintptr_t)srcva) < UTOP ) && ( PGOFF(srcva) != 0 ) )
		 return  -E_INVAL ; 
f0105812:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_env_set_status:
			return sys_env_set_status( ( envid_t ) a1 , a2 ) ;   
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall( ( envid_t ) a1 , ( void * ) a2 ) ; 
		case SYS_ipc_try_send:
			return sys_ipc_try_send( ( envid_t) a1 , a2 , (void * ) a3 , a4 ) ; 
f0105817:	e9 f7 00 00 00       	jmp    f0105913 <syscall+0x773>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ( (( (uintptr_t)dstva) < UTOP ) && ( PGOFF(dstva) != 0 ) ) 
f010581c:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105823:	77 0d                	ja     f0105832 <syscall+0x692>
f0105825:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010582c:	0f 85 c8 00 00 00    	jne    f01058fa <syscall+0x75a>
		return  -E_INVAL ; 
	curenv->env_ipc_recving = true ;
f0105832:	e8 82 18 00 00       	call   f01070b9 <cpunum>
f0105837:	6b c0 74             	imul   $0x74,%eax,%eax
f010583a:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105840:	c6 40 68 01          	movb   $0x1,0x68(%eax)
 	curenv->env_status = ENV_NOT_RUNNABLE ;
f0105844:	e8 70 18 00 00       	call   f01070b9 <cpunum>
f0105849:	6b c0 74             	imul   $0x74,%eax,%eax
f010584c:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105852:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva ;  
f0105859:	e8 5b 18 00 00       	call   f01070b9 <cpunum>
f010585e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105861:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010586a:	89 48 6c             	mov    %ecx,0x6c(%eax)
	if ( curenv->env_ipc_waithead ) {
f010586d:	e8 47 18 00 00       	call   f01070b9 <cpunum>
f0105872:	6b c0 74             	imul   $0x74,%eax,%eax
f0105875:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f010587b:	83 b8 84 00 00 00 00 	cmpl   $0x0,0x84(%eax)
f0105882:	74 55                	je     f01058d9 <syscall+0x739>
		struct Env * dstenv = curenv->env_ipc_waithead ; 
f0105884:	e8 30 18 00 00       	call   f01070b9 <cpunum>
f0105889:	6b c0 74             	imul   $0x74,%eax,%eax
f010588c:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105892:	8b 98 84 00 00 00    	mov    0x84(%eax),%ebx
		curenv->env_ipc_lockon = dstenv ->env_id ; 
f0105898:	e8 1c 18 00 00       	call   f01070b9 <cpunum>
f010589d:	6b c0 74             	imul   $0x74,%eax,%eax
f01058a0:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01058a6:	8b 53 48             	mov    0x48(%ebx),%edx
f01058a9:	89 50 7c             	mov    %edx,0x7c(%eax)
		dstenv->env_status = ENV_RUNNABLE ;
f01058ac:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
		curenv->env_ipc_waithead = dstenv -> env_ipc_waitnext ;
f01058b3:	e8 01 18 00 00       	call   f01070b9 <cpunum>
f01058b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01058bb:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01058c1:	8b 93 80 00 00 00    	mov    0x80(%ebx),%edx
f01058c7:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
		dstenv->env_ipc_waitnext = NULL ; 
f01058cd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
f01058d4:	00 00 00 
f01058d7:	eb 15                	jmp    f01058ee <syscall+0x74e>
	} else {
		curenv->env_ipc_lockon = 0 ; 
f01058d9:	e8 db 17 00 00       	call   f01070b9 <cpunum>
f01058de:	6b c0 74             	imul   $0x74,%eax,%eax
f01058e1:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f01058e7:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
	}
	sched_yield();
f01058ee:	e8 b1 f7 ff ff       	call   f01050a4 <sched_yield>
		case SYS_ipc_try_send:
			return sys_ipc_try_send( ( envid_t) a1 , a2 , (void * ) a3 , a4 ) ; 
		case SYS_ipc_recv:
			return sys_ipc_recv( (void* ) a1 ) ;
	default:
		return -E_NO_SYS;
f01058f3:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01058f8:	eb 19                	jmp    f0105913 <syscall+0x773>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall( ( envid_t ) a1 , ( void * ) a2 ) ; 
		case SYS_ipc_try_send:
			return sys_ipc_try_send( ( envid_t) a1 , a2 , (void * ) a3 , a4 ) ; 
		case SYS_ipc_recv:
			return sys_ipc_recv( (void* ) a1 ) ;
f01058fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01058ff:	eb 12                	jmp    f0105913 <syscall+0x773>
		return -E_BAD_ENV ; 	

	if ( (( (uintptr_t)srcva) < UTOP ) && ( PGOFF(srcva) != 0 ) )
		 return  -E_INVAL ; 
	
	if (  ( ! ( dstenv->env_ipc_recving ) ) 
f0105901:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105904:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105908:	0f 85 a6 fd ff ff    	jne    f01056b4 <syscall+0x514>
f010590e:	e9 c0 fd ff ff       	jmp    f01056d3 <syscall+0x533>
		case SYS_ipc_recv:
			return sys_ipc_recv( (void* ) a1 ) ;
	default:
		return -E_NO_SYS;
	}
}
f0105913:	83 c4 20             	add    $0x20,%esp
f0105916:	5b                   	pop    %ebx
f0105917:	5e                   	pop    %esi
f0105918:	5d                   	pop    %ebp
f0105919:	c3                   	ret    

f010591a <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010591a:	55                   	push   %ebp
f010591b:	89 e5                	mov    %esp,%ebp
f010591d:	57                   	push   %edi
f010591e:	56                   	push   %esi
f010591f:	53                   	push   %ebx
f0105920:	83 ec 14             	sub    $0x14,%esp
f0105923:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105926:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105929:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010592c:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010592f:	8b 1a                	mov    (%edx),%ebx
f0105931:	8b 01                	mov    (%ecx),%eax
f0105933:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105936:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010593d:	e9 88 00 00 00       	jmp    f01059ca <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0105942:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105945:	01 d8                	add    %ebx,%eax
f0105947:	89 c7                	mov    %eax,%edi
f0105949:	c1 ef 1f             	shr    $0x1f,%edi
f010594c:	01 c7                	add    %eax,%edi
f010594e:	d1 ff                	sar    %edi
f0105950:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105953:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105956:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0105959:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010595b:	eb 03                	jmp    f0105960 <stab_binsearch+0x46>
			m--;
f010595d:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105960:	39 c3                	cmp    %eax,%ebx
f0105962:	7f 1f                	jg     f0105983 <stab_binsearch+0x69>
f0105964:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105968:	83 ea 0c             	sub    $0xc,%edx
f010596b:	39 f1                	cmp    %esi,%ecx
f010596d:	75 ee                	jne    f010595d <stab_binsearch+0x43>
f010596f:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105972:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105975:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105978:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010597c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010597f:	76 18                	jbe    f0105999 <stab_binsearch+0x7f>
f0105981:	eb 05                	jmp    f0105988 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105983:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105986:	eb 42                	jmp    f01059ca <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105988:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010598b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010598d:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105990:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105997:	eb 31                	jmp    f01059ca <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105999:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010599c:	73 17                	jae    f01059b5 <stab_binsearch+0x9b>
			*region_right = m - 1;
f010599e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01059a1:	83 e8 01             	sub    $0x1,%eax
f01059a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01059a7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01059aa:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01059ac:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01059b3:	eb 15                	jmp    f01059ca <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01059b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059b8:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01059bb:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f01059bd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01059c1:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01059c3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01059ca:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01059cd:	0f 8e 6f ff ff ff    	jle    f0105942 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01059d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01059d7:	75 0f                	jne    f01059e8 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01059d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059dc:	8b 00                	mov    (%eax),%eax
f01059de:	83 e8 01             	sub    $0x1,%eax
f01059e1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01059e4:	89 07                	mov    %eax,(%edi)
f01059e6:	eb 2c                	jmp    f0105a14 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01059e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059eb:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01059ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059f0:	8b 0f                	mov    (%edi),%ecx
f01059f2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01059f5:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01059f8:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01059fb:	eb 03                	jmp    f0105a00 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01059fd:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105a00:	39 c8                	cmp    %ecx,%eax
f0105a02:	7e 0b                	jle    f0105a0f <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0105a04:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0105a08:	83 ea 0c             	sub    $0xc,%edx
f0105a0b:	39 f3                	cmp    %esi,%ebx
f0105a0d:	75 ee                	jne    f01059fd <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105a0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a12:	89 07                	mov    %eax,(%edi)
	}
}
f0105a14:	83 c4 14             	add    $0x14,%esp
f0105a17:	5b                   	pop    %ebx
f0105a18:	5e                   	pop    %esi
f0105a19:	5f                   	pop    %edi
f0105a1a:	5d                   	pop    %ebp
f0105a1b:	c3                   	ret    

f0105a1c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105a1c:	55                   	push   %ebp
f0105a1d:	89 e5                	mov    %esp,%ebp
f0105a1f:	57                   	push   %edi
f0105a20:	56                   	push   %esi
f0105a21:	53                   	push   %ebx
f0105a22:	83 ec 5c             	sub    $0x5c,%esp
f0105a25:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a28:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105a2b:	c7 07 14 8f 10 f0    	movl   $0xf0108f14,(%edi)
	info->eip_line = 0;
f0105a31:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0105a38:	c7 47 08 14 8f 10 f0 	movl   $0xf0108f14,0x8(%edi)
	info->eip_fn_namelen = 9;
f0105a3f:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0105a46:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f0105a49:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105a50:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105a56:	0f 87 dc 00 00 00    	ja     f0105b38 <debuginfo_eip+0x11c>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if ( user_mem_check( curenv , usd , sizeof( struct UserStabData) ,  PTE_U ) != 0 ) return -1 ; 
f0105a5c:	e8 58 16 00 00       	call   f01070b9 <cpunum>
f0105a61:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105a68:	00 
f0105a69:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105a70:	00 
f0105a71:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105a78:	00 
f0105a79:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a7c:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105a82:	89 04 24             	mov    %eax,(%esp)
f0105a85:	e8 f9 da ff ff       	call   f0103583 <user_mem_check>
f0105a8a:	85 c0                	test   %eax,%eax
f0105a8c:	0f 85 6d 02 00 00    	jne    f0105cff <debuginfo_eip+0x2e3>

		stabs = usd->stabs;
f0105a92:	a1 00 00 20 00       	mov    0x200000,%eax
f0105a97:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105a9a:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0105aa0:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105aa6:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105aa9:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105aaf:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if ( user_mem_check( curenv , usd->stabs , usd->stab_end - usd->stabs ,  PTE_U ) != 0 ) return -1 ; 
f0105ab2:	e8 02 16 00 00       	call   f01070b9 <cpunum>
f0105ab7:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105abe:	00 
f0105abf:	89 da                	mov    %ebx,%edx
f0105ac1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105ac4:	29 ca                	sub    %ecx,%edx
f0105ac6:	c1 fa 02             	sar    $0x2,%edx
f0105ac9:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0105acf:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105ad3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105ad7:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ada:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105ae0:	89 04 24             	mov    %eax,(%esp)
f0105ae3:	e8 9b da ff ff       	call   f0103583 <user_mem_check>
f0105ae8:	85 c0                	test   %eax,%eax
f0105aea:	0f 85 16 02 00 00    	jne    f0105d06 <debuginfo_eip+0x2ea>
	 	if ( user_mem_check( curenv , usd->stabstr , usd->stabstr_end - usd-> stabstr, PTE_U ) != 0 ) return -1; 
f0105af0:	a1 08 00 20 00       	mov    0x200008,%eax
f0105af5:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105afb:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0105afe:	29 c2                	sub    %eax,%edx
f0105b00:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0105b03:	e8 b1 15 00 00       	call   f01070b9 <cpunum>
f0105b08:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105b0f:	00 
f0105b10:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0105b13:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105b17:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0105b1a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105b1e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b21:	8b 80 28 10 24 f0    	mov    -0xfdbefd8(%eax),%eax
f0105b27:	89 04 24             	mov    %eax,(%esp)
f0105b2a:	e8 54 da ff ff       	call   f0103583 <user_mem_check>
f0105b2f:	85 c0                	test   %eax,%eax
f0105b31:	74 1f                	je     f0105b52 <debuginfo_eip+0x136>
f0105b33:	e9 d5 01 00 00       	jmp    f0105d0d <debuginfo_eip+0x2f1>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105b38:	c7 45 bc dc 7f 11 f0 	movl   $0xf0117fdc,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105b3f:	c7 45 c0 61 47 11 f0 	movl   $0xf0114761,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105b46:	bb 60 47 11 f0       	mov    $0xf0114760,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105b4b:	c7 45 c4 58 95 10 f0 	movl   $0xf0109558,-0x3c(%ebp)
		if ( user_mem_check( curenv , usd->stabs , usd->stab_end - usd->stabs ,  PTE_U ) != 0 ) return -1 ; 
	 	if ( user_mem_check( curenv , usd->stabstr , usd->stabstr_end - usd-> stabstr, PTE_U ) != 0 ) return -1; 
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105b52:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105b55:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0105b58:	0f 83 b6 01 00 00    	jae    f0105d14 <debuginfo_eip+0x2f8>
f0105b5e:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105b62:	0f 85 b3 01 00 00    	jne    f0105d1b <debuginfo_eip+0x2ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105b68:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105b6f:	89 d8                	mov    %ebx,%eax
f0105b71:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105b74:	29 d8                	sub    %ebx,%eax
f0105b76:	c1 f8 02             	sar    $0x2,%eax
f0105b79:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105b7f:	83 e8 01             	sub    $0x1,%eax
f0105b82:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105b85:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b89:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105b90:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105b93:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105b96:	89 d8                	mov    %ebx,%eax
f0105b98:	e8 7d fd ff ff       	call   f010591a <stab_binsearch>
	if (lfile == 0)
f0105b9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ba0:	85 c0                	test   %eax,%eax
f0105ba2:	0f 84 7a 01 00 00    	je     f0105d22 <debuginfo_eip+0x306>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105ba8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105bab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105bb1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105bb5:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105bbc:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105bbf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105bc2:	89 d8                	mov    %ebx,%eax
f0105bc4:	e8 51 fd ff ff       	call   f010591a <stab_binsearch>

	if (lfun <= rfun) {
f0105bc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105bcc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105bcf:	39 d0                	cmp    %edx,%eax
f0105bd1:	7f 32                	jg     f0105c05 <debuginfo_eip+0x1e9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105bd3:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105bd6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105bd9:	8d 0c 8b             	lea    (%ebx,%ecx,4),%ecx
f0105bdc:	8b 19                	mov    (%ecx),%ebx
f0105bde:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f0105be1:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0105be4:	2b 5d c0             	sub    -0x40(%ebp),%ebx
f0105be7:	39 5d b8             	cmp    %ebx,-0x48(%ebp)
f0105bea:	73 09                	jae    f0105bf5 <debuginfo_eip+0x1d9>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105bec:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105bef:	03 5d c0             	add    -0x40(%ebp),%ebx
f0105bf2:	89 5f 08             	mov    %ebx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105bf5:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105bf8:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0105bfb:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105bfd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105c00:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105c03:	eb 0f                	jmp    f0105c14 <debuginfo_eip+0x1f8>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105c05:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f0105c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c0b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105c0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105c11:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105c14:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105c1b:	00 
f0105c1c:	8b 47 08             	mov    0x8(%edi),%eax
f0105c1f:	89 04 24             	mov    %eax,(%esp)
f0105c22:	e8 24 0e 00 00       	call   f0106a4b <strfind>
f0105c27:	2b 47 08             	sub    0x8(%edi),%eax
f0105c2a:	89 47 0c             	mov    %eax,0xc(%edi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

        stab_binsearch(stabs, &lline , &rline , N_SLINE , addr ) ;
f0105c2d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105c31:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105c38:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105c3b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105c3e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105c41:	89 f0                	mov    %esi,%eax
f0105c43:	e8 d2 fc ff ff       	call   f010591a <stab_binsearch>
        if ( lline > rline ) return -1 ;      
f0105c48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105c4b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105c4e:	0f 8f d5 00 00 00    	jg     f0105d29 <debuginfo_eip+0x30d>
	info->eip_line = stabs[lline].n_desc ; 
f0105c54:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105c57:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105c5c:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105c5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c62:	89 c3                	mov    %eax,%ebx
f0105c64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105c67:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105c6a:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105c6d:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105c70:	89 df                	mov    %ebx,%edi
f0105c72:	eb 06                	jmp    f0105c7a <debuginfo_eip+0x25e>
f0105c74:	83 e8 01             	sub    $0x1,%eax
f0105c77:	83 ea 0c             	sub    $0xc,%edx
f0105c7a:	89 c6                	mov    %eax,%esi
f0105c7c:	39 c7                	cmp    %eax,%edi
f0105c7e:	7f 3c                	jg     f0105cbc <debuginfo_eip+0x2a0>
	       && stabs[lline].n_type != N_SOL
f0105c80:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105c84:	80 f9 84             	cmp    $0x84,%cl
f0105c87:	75 08                	jne    f0105c91 <debuginfo_eip+0x275>
f0105c89:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105c8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105c8f:	eb 11                	jmp    f0105ca2 <debuginfo_eip+0x286>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105c91:	80 f9 64             	cmp    $0x64,%cl
f0105c94:	75 de                	jne    f0105c74 <debuginfo_eip+0x258>
f0105c96:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105c9a:	74 d8                	je     f0105c74 <debuginfo_eip+0x258>
f0105c9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105c9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105ca2:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105ca5:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105ca8:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105cab:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105cae:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105cb1:	39 d0                	cmp    %edx,%eax
f0105cb3:	73 0a                	jae    f0105cbf <debuginfo_eip+0x2a3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105cb5:	03 45 c0             	add    -0x40(%ebp),%eax
f0105cb8:	89 07                	mov    %eax,(%edi)
f0105cba:	eb 03                	jmp    f0105cbf <debuginfo_eip+0x2a3>
f0105cbc:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105cbf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105cc2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105cc5:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105cca:	39 da                	cmp    %ebx,%edx
f0105ccc:	7d 67                	jge    f0105d35 <debuginfo_eip+0x319>
		for (lline = lfun + 1;
f0105cce:	83 c2 01             	add    $0x1,%edx
f0105cd1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105cd4:	89 d0                	mov    %edx,%eax
f0105cd6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105cd9:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105cdc:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105cdf:	eb 04                	jmp    f0105ce5 <debuginfo_eip+0x2c9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105ce1:	83 47 14 01          	addl   $0x1,0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105ce5:	39 c3                	cmp    %eax,%ebx
f0105ce7:	7e 47                	jle    f0105d30 <debuginfo_eip+0x314>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105ce9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105ced:	83 c0 01             	add    $0x1,%eax
f0105cf0:	83 c2 0c             	add    $0xc,%edx
f0105cf3:	80 f9 a0             	cmp    $0xa0,%cl
f0105cf6:	74 e9                	je     f0105ce1 <debuginfo_eip+0x2c5>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105cf8:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cfd:	eb 36                	jmp    f0105d35 <debuginfo_eip+0x319>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if ( user_mem_check( curenv , usd , sizeof( struct UserStabData) ,  PTE_U ) != 0 ) return -1 ; 
f0105cff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d04:	eb 2f                	jmp    f0105d35 <debuginfo_eip+0x319>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if ( user_mem_check( curenv , usd->stabs , usd->stab_end - usd->stabs ,  PTE_U ) != 0 ) return -1 ; 
f0105d06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d0b:	eb 28                	jmp    f0105d35 <debuginfo_eip+0x319>
	 	if ( user_mem_check( curenv , usd->stabstr , usd->stabstr_end - usd-> stabstr, PTE_U ) != 0 ) return -1; 
f0105d0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d12:	eb 21                	jmp    f0105d35 <debuginfo_eip+0x319>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d19:	eb 1a                	jmp    f0105d35 <debuginfo_eip+0x319>
f0105d1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d20:	eb 13                	jmp    f0105d35 <debuginfo_eip+0x319>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d27:	eb 0c                	jmp    f0105d35 <debuginfo_eip+0x319>
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

        stab_binsearch(stabs, &lline , &rline , N_SLINE , addr ) ;
        if ( lline > rline ) return -1 ;      
f0105d29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d2e:	eb 05                	jmp    f0105d35 <debuginfo_eip+0x319>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105d30:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d35:	83 c4 5c             	add    $0x5c,%esp
f0105d38:	5b                   	pop    %ebx
f0105d39:	5e                   	pop    %esi
f0105d3a:	5f                   	pop    %edi
f0105d3b:	5d                   	pop    %ebp
f0105d3c:	c3                   	ret    
f0105d3d:	66 90                	xchg   %ax,%ax
f0105d3f:	90                   	nop

f0105d40 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105d40:	55                   	push   %ebp
f0105d41:	89 e5                	mov    %esp,%ebp
f0105d43:	57                   	push   %edi
f0105d44:	56                   	push   %esi
f0105d45:	53                   	push   %ebx
f0105d46:	83 ec 3c             	sub    $0x3c,%esp
f0105d49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105d4c:	89 d7                	mov    %edx,%edi
f0105d4e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d51:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105d54:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d57:	89 c3                	mov    %eax,%ebx
f0105d59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105d5c:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d5f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105d62:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105d67:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105d6a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105d6d:	39 d9                	cmp    %ebx,%ecx
f0105d6f:	72 05                	jb     f0105d76 <printnum+0x36>
f0105d71:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105d74:	77 69                	ja     f0105ddf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105d76:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105d79:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105d7d:	83 ee 01             	sub    $0x1,%esi
f0105d80:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105d84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d88:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d8c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105d90:	89 c3                	mov    %eax,%ebx
f0105d92:	89 d6                	mov    %edx,%esi
f0105d94:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105d97:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105d9a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105d9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105da5:	89 04 24             	mov    %eax,(%esp)
f0105da8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105dab:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105daf:	e8 4c 17 00 00       	call   f0107500 <__udivdi3>
f0105db4:	89 d9                	mov    %ebx,%ecx
f0105db6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105dba:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105dbe:	89 04 24             	mov    %eax,(%esp)
f0105dc1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105dc5:	89 fa                	mov    %edi,%edx
f0105dc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105dca:	e8 71 ff ff ff       	call   f0105d40 <printnum>
f0105dcf:	eb 1b                	jmp    f0105dec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105dd1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105dd5:	8b 45 18             	mov    0x18(%ebp),%eax
f0105dd8:	89 04 24             	mov    %eax,(%esp)
f0105ddb:	ff d3                	call   *%ebx
f0105ddd:	eb 03                	jmp    f0105de2 <printnum+0xa2>
f0105ddf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105de2:	83 ee 01             	sub    $0x1,%esi
f0105de5:	85 f6                	test   %esi,%esi
f0105de7:	7f e8                	jg     f0105dd1 <printnum+0x91>
f0105de9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105dec:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105df0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105df4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105df7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105dfa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105dfe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105e02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105e05:	89 04 24             	mov    %eax,(%esp)
f0105e08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e0f:	e8 1c 18 00 00       	call   f0107630 <__umoddi3>
f0105e14:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e18:	0f be 80 1e 8f 10 f0 	movsbl -0xfef70e2(%eax),%eax
f0105e1f:	89 04 24             	mov    %eax,(%esp)
f0105e22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e25:	ff d0                	call   *%eax
}
f0105e27:	83 c4 3c             	add    $0x3c,%esp
f0105e2a:	5b                   	pop    %ebx
f0105e2b:	5e                   	pop    %esi
f0105e2c:	5f                   	pop    %edi
f0105e2d:	5d                   	pop    %ebp
f0105e2e:	c3                   	ret    

f0105e2f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105e2f:	55                   	push   %ebp
f0105e30:	89 e5                	mov    %esp,%ebp
f0105e32:	57                   	push   %edi
f0105e33:	56                   	push   %esi
f0105e34:	53                   	push   %ebx
f0105e35:	83 ec 3c             	sub    $0x3c,%esp
f0105e38:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105e3b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105e3e:	89 cf                	mov    %ecx,%edi
f0105e40:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e43:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105e46:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e49:	89 c3                	mov    %eax,%ebx
f0105e4b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105e4e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e51:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105e54:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105e59:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105e5c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105e5f:	39 d9                	cmp    %ebx,%ecx
f0105e61:	72 13                	jb     f0105e76 <cprintnum+0x47>
f0105e63:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105e66:	76 0e                	jbe    f0105e76 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
f0105e68:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105e6b:	0b 45 18             	or     0x18(%ebp),%eax
f0105e6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105e71:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105e74:	eb 6a                	jmp    f0105ee0 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
f0105e76:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105e79:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105e7d:	83 ee 01             	sub    $0x1,%esi
f0105e80:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105e84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e88:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105e8c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105e90:	89 c3                	mov    %eax,%ebx
f0105e92:	89 d6                	mov    %edx,%esi
f0105e94:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105e97:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105e9a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105e9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105ea2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105ea5:	89 04 24             	mov    %eax,(%esp)
f0105ea8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105eab:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105eaf:	e8 4c 16 00 00       	call   f0107500 <__udivdi3>
f0105eb4:	89 d9                	mov    %ebx,%ecx
f0105eb6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105eba:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105ebe:	89 04 24             	mov    %eax,(%esp)
f0105ec1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ec5:	89 f9                	mov    %edi,%ecx
f0105ec7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105eca:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105ecd:	e8 5d ff ff ff       	call   f0105e2f <cprintnum>
f0105ed2:	eb 16                	jmp    f0105eea <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
f0105ed4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105edb:	89 04 24             	mov    %eax,(%esp)
f0105ede:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105ee0:	83 ee 01             	sub    $0x1,%esi
f0105ee3:	85 f6                	test   %esi,%esi
f0105ee5:	7f ed                	jg     f0105ed4 <cprintnum+0xa5>
f0105ee7:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
f0105eea:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105eee:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105ef2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105ef5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105ef8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105efc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105f00:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105f03:	89 04 24             	mov    %eax,(%esp)
f0105f06:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105f09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f0d:	e8 1e 17 00 00       	call   f0107630 <__umoddi3>
f0105f12:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f16:	0f be 80 1e 8f 10 f0 	movsbl -0xfef70e2(%eax),%eax
f0105f1d:	0b 45 dc             	or     -0x24(%ebp),%eax
f0105f20:	89 04 24             	mov    %eax,(%esp)
f0105f23:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105f26:	ff d0                	call   *%eax
}
f0105f28:	83 c4 3c             	add    $0x3c,%esp
f0105f2b:	5b                   	pop    %ebx
f0105f2c:	5e                   	pop    %esi
f0105f2d:	5f                   	pop    %edi
f0105f2e:	5d                   	pop    %ebp
f0105f2f:	c3                   	ret    

f0105f30 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105f30:	55                   	push   %ebp
f0105f31:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105f33:	83 fa 01             	cmp    $0x1,%edx
f0105f36:	7e 0e                	jle    f0105f46 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105f38:	8b 10                	mov    (%eax),%edx
f0105f3a:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105f3d:	89 08                	mov    %ecx,(%eax)
f0105f3f:	8b 02                	mov    (%edx),%eax
f0105f41:	8b 52 04             	mov    0x4(%edx),%edx
f0105f44:	eb 22                	jmp    f0105f68 <getuint+0x38>
	else if (lflag)
f0105f46:	85 d2                	test   %edx,%edx
f0105f48:	74 10                	je     f0105f5a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105f4a:	8b 10                	mov    (%eax),%edx
f0105f4c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105f4f:	89 08                	mov    %ecx,(%eax)
f0105f51:	8b 02                	mov    (%edx),%eax
f0105f53:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f58:	eb 0e                	jmp    f0105f68 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105f5a:	8b 10                	mov    (%eax),%edx
f0105f5c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105f5f:	89 08                	mov    %ecx,(%eax)
f0105f61:	8b 02                	mov    (%edx),%eax
f0105f63:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105f68:	5d                   	pop    %ebp
f0105f69:	c3                   	ret    

f0105f6a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105f6a:	55                   	push   %ebp
f0105f6b:	89 e5                	mov    %esp,%ebp
f0105f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105f70:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105f74:	8b 10                	mov    (%eax),%edx
f0105f76:	3b 50 04             	cmp    0x4(%eax),%edx
f0105f79:	73 0a                	jae    f0105f85 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105f7b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105f7e:	89 08                	mov    %ecx,(%eax)
f0105f80:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f83:	88 02                	mov    %al,(%edx)
}
f0105f85:	5d                   	pop    %ebp
f0105f86:	c3                   	ret    

f0105f87 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105f87:	55                   	push   %ebp
f0105f88:	89 e5                	mov    %esp,%ebp
f0105f8a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105f8d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105f90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f94:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fa2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa5:	89 04 24             	mov    %eax,(%esp)
f0105fa8:	e8 02 00 00 00       	call   f0105faf <vprintfmt>
	va_end(ap);
}
f0105fad:	c9                   	leave  
f0105fae:	c3                   	ret    

f0105faf <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105faf:	55                   	push   %ebp
f0105fb0:	89 e5                	mov    %esp,%ebp
f0105fb2:	57                   	push   %edi
f0105fb3:	56                   	push   %esi
f0105fb4:	53                   	push   %ebx
f0105fb5:	83 ec 3c             	sub    $0x3c,%esp
f0105fb8:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105fbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105fbe:	eb 14                	jmp    f0105fd4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105fc0:	85 c0                	test   %eax,%eax
f0105fc2:	0f 84 b3 03 00 00    	je     f010637b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
f0105fc8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105fcc:	89 04 24             	mov    %eax,(%esp)
f0105fcf:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105fd2:	89 f3                	mov    %esi,%ebx
f0105fd4:	8d 73 01             	lea    0x1(%ebx),%esi
f0105fd7:	0f b6 03             	movzbl (%ebx),%eax
f0105fda:	83 f8 25             	cmp    $0x25,%eax
f0105fdd:	75 e1                	jne    f0105fc0 <vprintfmt+0x11>
f0105fdf:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105fe3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105fea:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105ff1:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105ff8:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ffd:	eb 1d                	jmp    f010601c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105fff:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0106001:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0106005:	eb 15                	jmp    f010601c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106007:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0106009:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010600d:	eb 0d                	jmp    f010601c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010600f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106012:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106015:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010601c:	8d 5e 01             	lea    0x1(%esi),%ebx
f010601f:	0f b6 0e             	movzbl (%esi),%ecx
f0106022:	0f b6 c1             	movzbl %cl,%eax
f0106025:	83 e9 23             	sub    $0x23,%ecx
f0106028:	80 f9 55             	cmp    $0x55,%cl
f010602b:	0f 87 2a 03 00 00    	ja     f010635b <vprintfmt+0x3ac>
f0106031:	0f b6 c9             	movzbl %cl,%ecx
f0106034:	ff 24 8d e0 8f 10 f0 	jmp    *-0xfef7020(,%ecx,4)
f010603b:	89 de                	mov    %ebx,%esi
f010603d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0106042:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0106045:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0106049:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010604c:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010604f:	83 fb 09             	cmp    $0x9,%ebx
f0106052:	77 36                	ja     f010608a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0106054:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0106057:	eb e9                	jmp    f0106042 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0106059:	8b 45 14             	mov    0x14(%ebp),%eax
f010605c:	8d 48 04             	lea    0x4(%eax),%ecx
f010605f:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0106062:	8b 00                	mov    (%eax),%eax
f0106064:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106067:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0106069:	eb 22                	jmp    f010608d <vprintfmt+0xde>
f010606b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010606e:	85 c9                	test   %ecx,%ecx
f0106070:	b8 00 00 00 00       	mov    $0x0,%eax
f0106075:	0f 49 c1             	cmovns %ecx,%eax
f0106078:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010607b:	89 de                	mov    %ebx,%esi
f010607d:	eb 9d                	jmp    f010601c <vprintfmt+0x6d>
f010607f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0106081:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0106088:	eb 92                	jmp    f010601c <vprintfmt+0x6d>
f010608a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f010608d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0106091:	79 89                	jns    f010601c <vprintfmt+0x6d>
f0106093:	e9 77 ff ff ff       	jmp    f010600f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0106098:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010609b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010609d:	e9 7a ff ff ff       	jmp    f010601c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01060a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01060a5:	8d 50 04             	lea    0x4(%eax),%edx
f01060a8:	89 55 14             	mov    %edx,0x14(%ebp)
f01060ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01060af:	8b 00                	mov    (%eax),%eax
f01060b1:	89 04 24             	mov    %eax,(%esp)
f01060b4:	ff 55 08             	call   *0x8(%ebp)
			break;
f01060b7:	e9 18 ff ff ff       	jmp    f0105fd4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01060bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01060bf:	8d 50 04             	lea    0x4(%eax),%edx
f01060c2:	89 55 14             	mov    %edx,0x14(%ebp)
f01060c5:	8b 00                	mov    (%eax),%eax
f01060c7:	99                   	cltd   
f01060c8:	31 d0                	xor    %edx,%eax
f01060ca:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01060cc:	83 f8 09             	cmp    $0x9,%eax
f01060cf:	7f 0b                	jg     f01060dc <vprintfmt+0x12d>
f01060d1:	8b 14 85 a0 92 10 f0 	mov    -0xfef6d60(,%eax,4),%edx
f01060d8:	85 d2                	test   %edx,%edx
f01060da:	75 20                	jne    f01060fc <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f01060dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01060e0:	c7 44 24 08 36 8f 10 	movl   $0xf0108f36,0x8(%esp)
f01060e7:	f0 
f01060e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01060ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01060ef:	89 04 24             	mov    %eax,(%esp)
f01060f2:	e8 90 fe ff ff       	call   f0105f87 <printfmt>
f01060f7:	e9 d8 fe ff ff       	jmp    f0105fd4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f01060fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106100:	c7 44 24 08 41 87 10 	movl   $0xf0108741,0x8(%esp)
f0106107:	f0 
f0106108:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010610c:	8b 45 08             	mov    0x8(%ebp),%eax
f010610f:	89 04 24             	mov    %eax,(%esp)
f0106112:	e8 70 fe ff ff       	call   f0105f87 <printfmt>
f0106117:	e9 b8 fe ff ff       	jmp    f0105fd4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010611c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010611f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106122:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0106125:	8b 45 14             	mov    0x14(%ebp),%eax
f0106128:	8d 50 04             	lea    0x4(%eax),%edx
f010612b:	89 55 14             	mov    %edx,0x14(%ebp)
f010612e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0106130:	85 f6                	test   %esi,%esi
f0106132:	b8 2f 8f 10 f0       	mov    $0xf0108f2f,%eax
f0106137:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f010613a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010613e:	0f 84 97 00 00 00    	je     f01061db <vprintfmt+0x22c>
f0106144:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0106148:	0f 8e 9b 00 00 00    	jle    f01061e9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f010614e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106152:	89 34 24             	mov    %esi,(%esp)
f0106155:	e8 9e 07 00 00       	call   f01068f8 <strnlen>
f010615a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010615d:	29 c2                	sub    %eax,%edx
f010615f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f0106162:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0106166:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106169:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010616c:	8b 75 08             	mov    0x8(%ebp),%esi
f010616f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106172:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106174:	eb 0f                	jmp    f0106185 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0106176:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010617a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010617d:	89 04 24             	mov    %eax,(%esp)
f0106180:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106182:	83 eb 01             	sub    $0x1,%ebx
f0106185:	85 db                	test   %ebx,%ebx
f0106187:	7f ed                	jg     f0106176 <vprintfmt+0x1c7>
f0106189:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010618c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010618f:	85 d2                	test   %edx,%edx
f0106191:	b8 00 00 00 00       	mov    $0x0,%eax
f0106196:	0f 49 c2             	cmovns %edx,%eax
f0106199:	29 c2                	sub    %eax,%edx
f010619b:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010619e:	89 d7                	mov    %edx,%edi
f01061a0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01061a3:	eb 50                	jmp    f01061f5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01061a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01061a9:	74 1e                	je     f01061c9 <vprintfmt+0x21a>
f01061ab:	0f be d2             	movsbl %dl,%edx
f01061ae:	83 ea 20             	sub    $0x20,%edx
f01061b1:	83 fa 5e             	cmp    $0x5e,%edx
f01061b4:	76 13                	jbe    f01061c9 <vprintfmt+0x21a>
					putch('?', putdat);
f01061b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01061b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061bd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01061c4:	ff 55 08             	call   *0x8(%ebp)
f01061c7:	eb 0d                	jmp    f01061d6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f01061c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01061cc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01061d0:	89 04 24             	mov    %eax,(%esp)
f01061d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01061d6:	83 ef 01             	sub    $0x1,%edi
f01061d9:	eb 1a                	jmp    f01061f5 <vprintfmt+0x246>
f01061db:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01061de:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01061e1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01061e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01061e7:	eb 0c                	jmp    f01061f5 <vprintfmt+0x246>
f01061e9:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01061ec:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01061ef:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01061f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01061f5:	83 c6 01             	add    $0x1,%esi
f01061f8:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f01061fc:	0f be c2             	movsbl %dl,%eax
f01061ff:	85 c0                	test   %eax,%eax
f0106201:	74 27                	je     f010622a <vprintfmt+0x27b>
f0106203:	85 db                	test   %ebx,%ebx
f0106205:	78 9e                	js     f01061a5 <vprintfmt+0x1f6>
f0106207:	83 eb 01             	sub    $0x1,%ebx
f010620a:	79 99                	jns    f01061a5 <vprintfmt+0x1f6>
f010620c:	89 f8                	mov    %edi,%eax
f010620e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106211:	8b 75 08             	mov    0x8(%ebp),%esi
f0106214:	89 c3                	mov    %eax,%ebx
f0106216:	eb 1a                	jmp    f0106232 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0106218:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010621c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106223:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106225:	83 eb 01             	sub    $0x1,%ebx
f0106228:	eb 08                	jmp    f0106232 <vprintfmt+0x283>
f010622a:	89 fb                	mov    %edi,%ebx
f010622c:	8b 75 08             	mov    0x8(%ebp),%esi
f010622f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106232:	85 db                	test   %ebx,%ebx
f0106234:	7f e2                	jg     f0106218 <vprintfmt+0x269>
f0106236:	89 75 08             	mov    %esi,0x8(%ebp)
f0106239:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010623c:	e9 93 fd ff ff       	jmp    f0105fd4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0106241:	83 fa 01             	cmp    $0x1,%edx
f0106244:	7e 16                	jle    f010625c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f0106246:	8b 45 14             	mov    0x14(%ebp),%eax
f0106249:	8d 50 08             	lea    0x8(%eax),%edx
f010624c:	89 55 14             	mov    %edx,0x14(%ebp)
f010624f:	8b 50 04             	mov    0x4(%eax),%edx
f0106252:	8b 00                	mov    (%eax),%eax
f0106254:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0106257:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010625a:	eb 32                	jmp    f010628e <vprintfmt+0x2df>
	else if (lflag)
f010625c:	85 d2                	test   %edx,%edx
f010625e:	74 18                	je     f0106278 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f0106260:	8b 45 14             	mov    0x14(%ebp),%eax
f0106263:	8d 50 04             	lea    0x4(%eax),%edx
f0106266:	89 55 14             	mov    %edx,0x14(%ebp)
f0106269:	8b 30                	mov    (%eax),%esi
f010626b:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010626e:	89 f0                	mov    %esi,%eax
f0106270:	c1 f8 1f             	sar    $0x1f,%eax
f0106273:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106276:	eb 16                	jmp    f010628e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
f0106278:	8b 45 14             	mov    0x14(%ebp),%eax
f010627b:	8d 50 04             	lea    0x4(%eax),%edx
f010627e:	89 55 14             	mov    %edx,0x14(%ebp)
f0106281:	8b 30                	mov    (%eax),%esi
f0106283:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0106286:	89 f0                	mov    %esi,%eax
f0106288:	c1 f8 1f             	sar    $0x1f,%eax
f010628b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010628e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106291:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0106294:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0106299:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010629d:	0f 89 80 00 00 00    	jns    f0106323 <vprintfmt+0x374>
				putch('-', putdat);
f01062a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01062a7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01062ae:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01062b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01062b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01062b7:	f7 d8                	neg    %eax
f01062b9:	83 d2 00             	adc    $0x0,%edx
f01062bc:	f7 da                	neg    %edx
			}
			base = 10;
f01062be:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01062c3:	eb 5e                	jmp    f0106323 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01062c5:	8d 45 14             	lea    0x14(%ebp),%eax
f01062c8:	e8 63 fc ff ff       	call   f0105f30 <getuint>
			base = 10;
f01062cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01062d2:	eb 4f                	jmp    f0106323 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01062d4:	8d 45 14             	lea    0x14(%ebp),%eax
f01062d7:	e8 54 fc ff ff       	call   f0105f30 <getuint>
			base = 8 ;
f01062dc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
f01062e1:	eb 40                	jmp    f0106323 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
f01062e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01062e7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01062ee:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01062f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01062f5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01062fc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01062ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0106302:	8d 50 04             	lea    0x4(%eax),%edx
f0106305:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0106308:	8b 00                	mov    (%eax),%eax
f010630a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010630f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0106314:	eb 0d                	jmp    f0106323 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0106316:	8d 45 14             	lea    0x14(%ebp),%eax
f0106319:	e8 12 fc ff ff       	call   f0105f30 <getuint>
			base = 16;
f010631e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106323:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0106327:	89 74 24 10          	mov    %esi,0x10(%esp)
f010632b:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010632e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106332:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106336:	89 04 24             	mov    %eax,(%esp)
f0106339:	89 54 24 04          	mov    %edx,0x4(%esp)
f010633d:	89 fa                	mov    %edi,%edx
f010633f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106342:	e8 f9 f9 ff ff       	call   f0105d40 <printnum>
			break;
f0106347:	e9 88 fc ff ff       	jmp    f0105fd4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010634c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106350:	89 04 24             	mov    %eax,(%esp)
f0106353:	ff 55 08             	call   *0x8(%ebp)
			break;
f0106356:	e9 79 fc ff ff       	jmp    f0105fd4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010635b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010635f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0106366:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0106369:	89 f3                	mov    %esi,%ebx
f010636b:	eb 03                	jmp    f0106370 <vprintfmt+0x3c1>
f010636d:	83 eb 01             	sub    $0x1,%ebx
f0106370:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0106374:	75 f7                	jne    f010636d <vprintfmt+0x3be>
f0106376:	e9 59 fc ff ff       	jmp    f0105fd4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f010637b:	83 c4 3c             	add    $0x3c,%esp
f010637e:	5b                   	pop    %ebx
f010637f:	5e                   	pop    %esi
f0106380:	5f                   	pop    %edi
f0106381:	5d                   	pop    %ebp
f0106382:	c3                   	ret    

f0106383 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0106383:	55                   	push   %ebp
f0106384:	89 e5                	mov    %esp,%ebp
f0106386:	57                   	push   %edi
f0106387:	56                   	push   %esi
f0106388:	53                   	push   %ebx
f0106389:	83 ec 3c             	sub    $0x3c,%esp
f010638c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
f010638f:	8b 45 14             	mov    0x14(%ebp),%eax
f0106392:	8d 50 04             	lea    0x4(%eax),%edx
f0106395:	89 55 14             	mov    %edx,0x14(%ebp)
f0106398:	8b 00                	mov    (%eax),%eax
f010639a:	c1 e0 08             	shl    $0x8,%eax
f010639d:	0f b7 c0             	movzwl %ax,%eax
f01063a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
f01063a3:	83 c8 25             	or     $0x25,%eax
f01063a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01063a9:	eb 1a                	jmp    f01063c5 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01063ab:	85 c0                	test   %eax,%eax
f01063ad:	0f 84 a9 03 00 00    	je     f010675c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
f01063b3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01063b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01063ba:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01063bd:	89 04 24             	mov    %eax,(%esp)
f01063c0:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01063c3:	89 fb                	mov    %edi,%ebx
f01063c5:	8d 7b 01             	lea    0x1(%ebx),%edi
f01063c8:	0f b6 03             	movzbl (%ebx),%eax
f01063cb:	83 f8 25             	cmp    $0x25,%eax
f01063ce:	75 db                	jne    f01063ab <cvprintfmt+0x28>
f01063d0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01063d4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01063db:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01063e0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f01063e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01063ec:	eb 18                	jmp    f0106406 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01063ee:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01063f0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01063f4:	eb 10                	jmp    f0106406 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01063f6:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01063f8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01063fc:	eb 08                	jmp    f0106406 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01063fe:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0106401:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106406:	8d 5f 01             	lea    0x1(%edi),%ebx
f0106409:	0f b6 0f             	movzbl (%edi),%ecx
f010640c:	0f b6 c1             	movzbl %cl,%eax
f010640f:	83 e9 23             	sub    $0x23,%ecx
f0106412:	80 f9 55             	cmp    $0x55,%cl
f0106415:	0f 87 1f 03 00 00    	ja     f010673a <cvprintfmt+0x3b7>
f010641b:	0f b6 c9             	movzbl %cl,%ecx
f010641e:	ff 24 8d 38 91 10 f0 	jmp    *-0xfef6ec8(,%ecx,4)
f0106425:	89 df                	mov    %ebx,%edi
f0106427:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010642c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
f010642f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
f0106433:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0106436:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0106439:	83 f9 09             	cmp    $0x9,%ecx
f010643c:	77 33                	ja     f0106471 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010643e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0106441:	eb e9                	jmp    f010642c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0106443:	8b 45 14             	mov    0x14(%ebp),%eax
f0106446:	8d 48 04             	lea    0x4(%eax),%ecx
f0106449:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010644c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010644e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0106450:	eb 1f                	jmp    f0106471 <cvprintfmt+0xee>
f0106452:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0106455:	85 ff                	test   %edi,%edi
f0106457:	b8 00 00 00 00       	mov    $0x0,%eax
f010645c:	0f 49 c7             	cmovns %edi,%eax
f010645f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106462:	89 df                	mov    %ebx,%edi
f0106464:	eb a0                	jmp    f0106406 <cvprintfmt+0x83>
f0106466:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0106468:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f010646f:	eb 95                	jmp    f0106406 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
f0106471:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0106475:	79 8f                	jns    f0106406 <cvprintfmt+0x83>
f0106477:	eb 85                	jmp    f01063fe <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0106479:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010647c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010647e:	66 90                	xchg   %ax,%ax
f0106480:	eb 84                	jmp    f0106406 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
f0106482:	8b 45 14             	mov    0x14(%ebp),%eax
f0106485:	8d 50 04             	lea    0x4(%eax),%edx
f0106488:	89 55 14             	mov    %edx,0x14(%ebp)
f010648b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010648e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106492:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106495:	0b 10                	or     (%eax),%edx
f0106497:	89 14 24             	mov    %edx,(%esp)
f010649a:	ff 55 08             	call   *0x8(%ebp)
			break;
f010649d:	e9 23 ff ff ff       	jmp    f01063c5 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01064a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01064a5:	8d 50 04             	lea    0x4(%eax),%edx
f01064a8:	89 55 14             	mov    %edx,0x14(%ebp)
f01064ab:	8b 00                	mov    (%eax),%eax
f01064ad:	99                   	cltd   
f01064ae:	31 d0                	xor    %edx,%eax
f01064b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01064b2:	83 f8 09             	cmp    $0x9,%eax
f01064b5:	7f 0b                	jg     f01064c2 <cvprintfmt+0x13f>
f01064b7:	8b 14 85 a0 92 10 f0 	mov    -0xfef6d60(,%eax,4),%edx
f01064be:	85 d2                	test   %edx,%edx
f01064c0:	75 23                	jne    f01064e5 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
f01064c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064c6:	c7 44 24 08 36 8f 10 	movl   $0xf0108f36,0x8(%esp)
f01064cd:	f0 
f01064ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01064d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01064d8:	89 04 24             	mov    %eax,(%esp)
f01064db:	e8 a7 fa ff ff       	call   f0105f87 <printfmt>
f01064e0:	e9 e0 fe ff ff       	jmp    f01063c5 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
f01064e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01064e9:	c7 44 24 08 41 87 10 	movl   $0xf0108741,0x8(%esp)
f01064f0:	f0 
f01064f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01064f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01064fb:	89 04 24             	mov    %eax,(%esp)
f01064fe:	e8 84 fa ff ff       	call   f0105f87 <printfmt>
f0106503:	e9 bd fe ff ff       	jmp    f01063c5 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106508:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010650b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
f010650e:	8b 45 14             	mov    0x14(%ebp),%eax
f0106511:	8d 48 04             	lea    0x4(%eax),%ecx
f0106514:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0106517:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0106519:	85 ff                	test   %edi,%edi
f010651b:	b8 2f 8f 10 f0       	mov    $0xf0108f2f,%eax
f0106520:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0106523:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0106527:	74 61                	je     f010658a <cvprintfmt+0x207>
f0106529:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010652d:	7e 5b                	jle    f010658a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
f010652f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106533:	89 3c 24             	mov    %edi,(%esp)
f0106536:	e8 bd 03 00 00       	call   f01068f8 <strnlen>
f010653b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010653e:	29 c2                	sub    %eax,%edx
f0106540:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
f0106543:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0106547:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010654a:	89 7d d8             	mov    %edi,-0x28(%ebp)
f010654d:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0106550:	8b 75 08             	mov    0x8(%ebp),%esi
f0106553:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106556:	89 d3                	mov    %edx,%ebx
f0106558:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010655a:	eb 0f                	jmp    f010656b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
f010655c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010655f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106563:	89 3c 24             	mov    %edi,(%esp)
f0106566:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106568:	83 eb 01             	sub    $0x1,%ebx
f010656b:	85 db                	test   %ebx,%ebx
f010656d:	7f ed                	jg     f010655c <cvprintfmt+0x1d9>
f010656f:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106572:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0106575:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0106578:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010657b:	85 d2                	test   %edx,%edx
f010657d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106582:	0f 49 c2             	cmovns %edx,%eax
f0106585:	29 c2                	sub    %eax,%edx
f0106587:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
f010658a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010658d:	83 c8 3f             	or     $0x3f,%eax
f0106590:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0106593:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106596:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0106599:	eb 36                	jmp    f01065d1 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010659b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010659f:	74 1d                	je     f01065be <cvprintfmt+0x23b>
f01065a1:	0f be d2             	movsbl %dl,%edx
f01065a4:	83 ea 20             	sub    $0x20,%edx
f01065a7:	83 fa 5e             	cmp    $0x5e,%edx
f01065aa:	76 12                	jbe    f01065be <cvprintfmt+0x23b>
					putch(color | '?', putdat);
f01065ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01065af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01065b6:	89 04 24             	mov    %eax,(%esp)
f01065b9:	ff 55 08             	call   *0x8(%ebp)
f01065bc:	eb 10                	jmp    f01065ce <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
f01065be:	8b 55 0c             	mov    0xc(%ebp),%edx
f01065c1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01065c5:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01065c8:	89 04 24             	mov    %eax,(%esp)
f01065cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01065ce:	83 eb 01             	sub    $0x1,%ebx
f01065d1:	83 c7 01             	add    $0x1,%edi
f01065d4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01065d8:	0f be c2             	movsbl %dl,%eax
f01065db:	85 c0                	test   %eax,%eax
f01065dd:	74 27                	je     f0106606 <cvprintfmt+0x283>
f01065df:	85 f6                	test   %esi,%esi
f01065e1:	78 b8                	js     f010659b <cvprintfmt+0x218>
f01065e3:	83 ee 01             	sub    $0x1,%esi
f01065e6:	79 b3                	jns    f010659b <cvprintfmt+0x218>
f01065e8:	89 d8                	mov    %ebx,%eax
f01065ea:	8b 75 08             	mov    0x8(%ebp),%esi
f01065ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01065f0:	89 c3                	mov    %eax,%ebx
f01065f2:	eb 18                	jmp    f010660c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
f01065f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01065f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01065ff:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
f0106601:	83 eb 01             	sub    $0x1,%ebx
f0106604:	eb 06                	jmp    f010660c <cvprintfmt+0x289>
f0106606:	8b 75 08             	mov    0x8(%ebp),%esi
f0106609:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010660c:	85 db                	test   %ebx,%ebx
f010660e:	7f e4                	jg     f01065f4 <cvprintfmt+0x271>
f0106610:	89 75 08             	mov    %esi,0x8(%ebp)
f0106613:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0106616:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0106619:	e9 a7 fd ff ff       	jmp    f01063c5 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010661e:	83 fa 01             	cmp    $0x1,%edx
f0106621:	7e 10                	jle    f0106633 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
f0106623:	8b 45 14             	mov    0x14(%ebp),%eax
f0106626:	8d 50 08             	lea    0x8(%eax),%edx
f0106629:	89 55 14             	mov    %edx,0x14(%ebp)
f010662c:	8b 30                	mov    (%eax),%esi
f010662e:	8b 78 04             	mov    0x4(%eax),%edi
f0106631:	eb 26                	jmp    f0106659 <cvprintfmt+0x2d6>
	else if (lflag)
f0106633:	85 d2                	test   %edx,%edx
f0106635:	74 12                	je     f0106649 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
f0106637:	8b 45 14             	mov    0x14(%ebp),%eax
f010663a:	8d 50 04             	lea    0x4(%eax),%edx
f010663d:	89 55 14             	mov    %edx,0x14(%ebp)
f0106640:	8b 30                	mov    (%eax),%esi
f0106642:	89 f7                	mov    %esi,%edi
f0106644:	c1 ff 1f             	sar    $0x1f,%edi
f0106647:	eb 10                	jmp    f0106659 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
f0106649:	8b 45 14             	mov    0x14(%ebp),%eax
f010664c:	8d 50 04             	lea    0x4(%eax),%edx
f010664f:	89 55 14             	mov    %edx,0x14(%ebp)
f0106652:	8b 30                	mov    (%eax),%esi
f0106654:	89 f7                	mov    %esi,%edi
f0106656:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0106659:	89 f0                	mov    %esi,%eax
f010665b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010665d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0106662:	85 ff                	test   %edi,%edi
f0106664:	0f 89 8e 00 00 00    	jns    f01066f8 <cvprintfmt+0x375>
				putch(color | '-', putdat);
f010666a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010666d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106674:	83 c8 2d             	or     $0x2d,%eax
f0106677:	89 04 24             	mov    %eax,(%esp)
f010667a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010667d:	89 f0                	mov    %esi,%eax
f010667f:	89 fa                	mov    %edi,%edx
f0106681:	f7 d8                	neg    %eax
f0106683:	83 d2 00             	adc    $0x0,%edx
f0106686:	f7 da                	neg    %edx
			}
			base = 10;
f0106688:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010668d:	eb 69                	jmp    f01066f8 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010668f:	8d 45 14             	lea    0x14(%ebp),%eax
f0106692:	e8 99 f8 ff ff       	call   f0105f30 <getuint>
			base = 10;
f0106697:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010669c:	eb 5a                	jmp    f01066f8 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f010669e:	8d 45 14             	lea    0x14(%ebp),%eax
f01066a1:	e8 8a f8 ff ff       	call   f0105f30 <getuint>
			base = 8 ;
f01066a6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
f01066ab:	eb 4b                	jmp    f01066f8 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
f01066ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01066b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066b4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01066b7:	89 f0                	mov    %esi,%eax
f01066b9:	83 c8 30             	or     $0x30,%eax
f01066bc:	89 04 24             	mov    %eax,(%esp)
f01066bf:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
f01066c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01066c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066c9:	89 f0                	mov    %esi,%eax
f01066cb:	83 c8 78             	or     $0x78,%eax
f01066ce:	89 04 24             	mov    %eax,(%esp)
f01066d1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01066d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01066d7:	8d 50 04             	lea    0x4(%eax),%edx
f01066da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
f01066dd:	8b 00                	mov    (%eax),%eax
f01066df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01066e4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01066e9:	eb 0d                	jmp    f01066f8 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01066eb:	8d 45 14             	lea    0x14(%ebp),%eax
f01066ee:	e8 3d f8 ff ff       	call   f0105f30 <getuint>
			base = 16;
f01066f3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
f01066f8:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f01066fc:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106700:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0106703:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106707:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010670b:	89 04 24             	mov    %eax,(%esp)
f010670e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106715:	8b 55 08             	mov    0x8(%ebp),%edx
f0106718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010671b:	e8 0f f7 ff ff       	call   f0105e2f <cprintnum>
			break;
f0106720:	e9 a0 fc ff ff       	jmp    f01063c5 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
f0106725:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106728:	89 54 24 04          	mov    %edx,0x4(%esp)
f010672c:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010672f:	89 04 24             	mov    %eax,(%esp)
f0106732:	ff 55 08             	call   *0x8(%ebp)
			break;
f0106735:	e9 8b fc ff ff       	jmp    f01063c5 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
f010673a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010673d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106741:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106744:	89 04 24             	mov    %eax,(%esp)
f0106747:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010674a:	89 fb                	mov    %edi,%ebx
f010674c:	eb 03                	jmp    f0106751 <cvprintfmt+0x3ce>
f010674e:	83 eb 01             	sub    $0x1,%ebx
f0106751:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0106755:	75 f7                	jne    f010674e <cvprintfmt+0x3cb>
f0106757:	e9 69 fc ff ff       	jmp    f01063c5 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
f010675c:	83 c4 3c             	add    $0x3c,%esp
f010675f:	5b                   	pop    %ebx
f0106760:	5e                   	pop    %esi
f0106761:	5f                   	pop    %edi
f0106762:	5d                   	pop    %ebp
f0106763:	c3                   	ret    

f0106764 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0106764:	55                   	push   %ebp
f0106765:	89 e5                	mov    %esp,%ebp
f0106767:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010676a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
f010676d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106771:	8b 45 10             	mov    0x10(%ebp),%eax
f0106774:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106778:	8b 45 0c             	mov    0xc(%ebp),%eax
f010677b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010677f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106782:	89 04 24             	mov    %eax,(%esp)
f0106785:	e8 f9 fb ff ff       	call   f0106383 <cvprintfmt>
	va_end(ap);
}
f010678a:	c9                   	leave  
f010678b:	c3                   	ret    

f010678c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010678c:	55                   	push   %ebp
f010678d:	89 e5                	mov    %esp,%ebp
f010678f:	83 ec 28             	sub    $0x28,%esp
f0106792:	8b 45 08             	mov    0x8(%ebp),%eax
f0106795:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0106798:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010679b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010679f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01067a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01067a9:	85 c0                	test   %eax,%eax
f01067ab:	74 30                	je     f01067dd <vsnprintf+0x51>
f01067ad:	85 d2                	test   %edx,%edx
f01067af:	7e 2c                	jle    f01067dd <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01067b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01067b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01067b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01067bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01067bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01067c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067c6:	c7 04 24 6a 5f 10 f0 	movl   $0xf0105f6a,(%esp)
f01067cd:	e8 dd f7 ff ff       	call   f0105faf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01067d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01067d5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01067d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01067db:	eb 05                	jmp    f01067e2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01067dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01067e2:	c9                   	leave  
f01067e3:	c3                   	ret    

f01067e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01067e4:	55                   	push   %ebp
f01067e5:	89 e5                	mov    %esp,%ebp
f01067e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01067ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01067ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01067f1:	8b 45 10             	mov    0x10(%ebp),%eax
f01067f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01067f8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01067fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0106802:	89 04 24             	mov    %eax,(%esp)
f0106805:	e8 82 ff ff ff       	call   f010678c <vsnprintf>
	va_end(ap);

	return rc;
}
f010680a:	c9                   	leave  
f010680b:	c3                   	ret    
f010680c:	66 90                	xchg   %ax,%ax
f010680e:	66 90                	xchg   %ax,%ax

f0106810 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106810:	55                   	push   %ebp
f0106811:	89 e5                	mov    %esp,%ebp
f0106813:	57                   	push   %edi
f0106814:	56                   	push   %esi
f0106815:	53                   	push   %ebx
f0106816:	83 ec 1c             	sub    $0x1c,%esp
f0106819:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010681c:	85 c0                	test   %eax,%eax
f010681e:	74 10                	je     f0106830 <readline+0x20>
		cprintf("%s", prompt);
f0106820:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106824:	c7 04 24 41 87 10 f0 	movl   $0xf0108741,(%esp)
f010682b:	e8 53 d8 ff ff       	call   f0104083 <cprintf>

	i = 0;
	echoing = iscons(0);
f0106830:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106837:	e8 6f 9f ff ff       	call   f01007ab <iscons>
f010683c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010683e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0106843:	e8 52 9f ff ff       	call   f010079a <getchar>
f0106848:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010684a:	85 c0                	test   %eax,%eax
f010684c:	79 17                	jns    f0106865 <readline+0x55>
			cprintf("read error: %e\n", c);
f010684e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106852:	c7 04 24 c8 92 10 f0 	movl   $0xf01092c8,(%esp)
f0106859:	e8 25 d8 ff ff       	call   f0104083 <cprintf>
			return NULL;
f010685e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106863:	eb 6d                	jmp    f01068d2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106865:	83 f8 7f             	cmp    $0x7f,%eax
f0106868:	74 05                	je     f010686f <readline+0x5f>
f010686a:	83 f8 08             	cmp    $0x8,%eax
f010686d:	75 19                	jne    f0106888 <readline+0x78>
f010686f:	85 f6                	test   %esi,%esi
f0106871:	7e 15                	jle    f0106888 <readline+0x78>
			if (echoing)
f0106873:	85 ff                	test   %edi,%edi
f0106875:	74 0c                	je     f0106883 <readline+0x73>
				cputchar('\b');
f0106877:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010687e:	e8 07 9f ff ff       	call   f010078a <cputchar>
			i--;
f0106883:	83 ee 01             	sub    $0x1,%esi
f0106886:	eb bb                	jmp    f0106843 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0106888:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010688e:	7f 1c                	jg     f01068ac <readline+0x9c>
f0106890:	83 fb 1f             	cmp    $0x1f,%ebx
f0106893:	7e 17                	jle    f01068ac <readline+0x9c>
			if (echoing)
f0106895:	85 ff                	test   %edi,%edi
f0106897:	74 08                	je     f01068a1 <readline+0x91>
				cputchar(c);
f0106899:	89 1c 24             	mov    %ebx,(%esp)
f010689c:	e8 e9 9e ff ff       	call   f010078a <cputchar>
			buf[i++] = c;
f01068a1:	88 9e 80 fa 23 f0    	mov    %bl,-0xfdc0580(%esi)
f01068a7:	8d 76 01             	lea    0x1(%esi),%esi
f01068aa:	eb 97                	jmp    f0106843 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01068ac:	83 fb 0d             	cmp    $0xd,%ebx
f01068af:	74 05                	je     f01068b6 <readline+0xa6>
f01068b1:	83 fb 0a             	cmp    $0xa,%ebx
f01068b4:	75 8d                	jne    f0106843 <readline+0x33>
			if (echoing)
f01068b6:	85 ff                	test   %edi,%edi
f01068b8:	74 0c                	je     f01068c6 <readline+0xb6>
				cputchar('\n');
f01068ba:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01068c1:	e8 c4 9e ff ff       	call   f010078a <cputchar>
			buf[i] = 0;
f01068c6:	c6 86 80 fa 23 f0 00 	movb   $0x0,-0xfdc0580(%esi)
			return buf;
f01068cd:	b8 80 fa 23 f0       	mov    $0xf023fa80,%eax
		}
	}
}
f01068d2:	83 c4 1c             	add    $0x1c,%esp
f01068d5:	5b                   	pop    %ebx
f01068d6:	5e                   	pop    %esi
f01068d7:	5f                   	pop    %edi
f01068d8:	5d                   	pop    %ebp
f01068d9:	c3                   	ret    
f01068da:	66 90                	xchg   %ax,%ax
f01068dc:	66 90                	xchg   %ax,%ax
f01068de:	66 90                	xchg   %ax,%ax

f01068e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01068e0:	55                   	push   %ebp
f01068e1:	89 e5                	mov    %esp,%ebp
f01068e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01068e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01068eb:	eb 03                	jmp    f01068f0 <strlen+0x10>
		n++;
f01068ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01068f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01068f4:	75 f7                	jne    f01068ed <strlen+0xd>
		n++;
	return n;
}
f01068f6:	5d                   	pop    %ebp
f01068f7:	c3                   	ret    

f01068f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01068f8:	55                   	push   %ebp
f01068f9:	89 e5                	mov    %esp,%ebp
f01068fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01068fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106901:	b8 00 00 00 00       	mov    $0x0,%eax
f0106906:	eb 03                	jmp    f010690b <strnlen+0x13>
		n++;
f0106908:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010690b:	39 d0                	cmp    %edx,%eax
f010690d:	74 06                	je     f0106915 <strnlen+0x1d>
f010690f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0106913:	75 f3                	jne    f0106908 <strnlen+0x10>
		n++;
	return n;
}
f0106915:	5d                   	pop    %ebp
f0106916:	c3                   	ret    

f0106917 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0106917:	55                   	push   %ebp
f0106918:	89 e5                	mov    %esp,%ebp
f010691a:	53                   	push   %ebx
f010691b:	8b 45 08             	mov    0x8(%ebp),%eax
f010691e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106921:	89 c2                	mov    %eax,%edx
f0106923:	83 c2 01             	add    $0x1,%edx
f0106926:	83 c1 01             	add    $0x1,%ecx
f0106929:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010692d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0106930:	84 db                	test   %bl,%bl
f0106932:	75 ef                	jne    f0106923 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0106934:	5b                   	pop    %ebx
f0106935:	5d                   	pop    %ebp
f0106936:	c3                   	ret    

f0106937 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0106937:	55                   	push   %ebp
f0106938:	89 e5                	mov    %esp,%ebp
f010693a:	53                   	push   %ebx
f010693b:	83 ec 08             	sub    $0x8,%esp
f010693e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106941:	89 1c 24             	mov    %ebx,(%esp)
f0106944:	e8 97 ff ff ff       	call   f01068e0 <strlen>
	strcpy(dst + len, src);
f0106949:	8b 55 0c             	mov    0xc(%ebp),%edx
f010694c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106950:	01 d8                	add    %ebx,%eax
f0106952:	89 04 24             	mov    %eax,(%esp)
f0106955:	e8 bd ff ff ff       	call   f0106917 <strcpy>
	return dst;
}
f010695a:	89 d8                	mov    %ebx,%eax
f010695c:	83 c4 08             	add    $0x8,%esp
f010695f:	5b                   	pop    %ebx
f0106960:	5d                   	pop    %ebp
f0106961:	c3                   	ret    

f0106962 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106962:	55                   	push   %ebp
f0106963:	89 e5                	mov    %esp,%ebp
f0106965:	56                   	push   %esi
f0106966:	53                   	push   %ebx
f0106967:	8b 75 08             	mov    0x8(%ebp),%esi
f010696a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010696d:	89 f3                	mov    %esi,%ebx
f010696f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106972:	89 f2                	mov    %esi,%edx
f0106974:	eb 0f                	jmp    f0106985 <strncpy+0x23>
		*dst++ = *src;
f0106976:	83 c2 01             	add    $0x1,%edx
f0106979:	0f b6 01             	movzbl (%ecx),%eax
f010697c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010697f:	80 39 01             	cmpb   $0x1,(%ecx)
f0106982:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106985:	39 da                	cmp    %ebx,%edx
f0106987:	75 ed                	jne    f0106976 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106989:	89 f0                	mov    %esi,%eax
f010698b:	5b                   	pop    %ebx
f010698c:	5e                   	pop    %esi
f010698d:	5d                   	pop    %ebp
f010698e:	c3                   	ret    

f010698f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010698f:	55                   	push   %ebp
f0106990:	89 e5                	mov    %esp,%ebp
f0106992:	56                   	push   %esi
f0106993:	53                   	push   %ebx
f0106994:	8b 75 08             	mov    0x8(%ebp),%esi
f0106997:	8b 55 0c             	mov    0xc(%ebp),%edx
f010699a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010699d:	89 f0                	mov    %esi,%eax
f010699f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01069a3:	85 c9                	test   %ecx,%ecx
f01069a5:	75 0b                	jne    f01069b2 <strlcpy+0x23>
f01069a7:	eb 1d                	jmp    f01069c6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01069a9:	83 c0 01             	add    $0x1,%eax
f01069ac:	83 c2 01             	add    $0x1,%edx
f01069af:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01069b2:	39 d8                	cmp    %ebx,%eax
f01069b4:	74 0b                	je     f01069c1 <strlcpy+0x32>
f01069b6:	0f b6 0a             	movzbl (%edx),%ecx
f01069b9:	84 c9                	test   %cl,%cl
f01069bb:	75 ec                	jne    f01069a9 <strlcpy+0x1a>
f01069bd:	89 c2                	mov    %eax,%edx
f01069bf:	eb 02                	jmp    f01069c3 <strlcpy+0x34>
f01069c1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01069c3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01069c6:	29 f0                	sub    %esi,%eax
}
f01069c8:	5b                   	pop    %ebx
f01069c9:	5e                   	pop    %esi
f01069ca:	5d                   	pop    %ebp
f01069cb:	c3                   	ret    

f01069cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01069cc:	55                   	push   %ebp
f01069cd:	89 e5                	mov    %esp,%ebp
f01069cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01069d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01069d5:	eb 06                	jmp    f01069dd <strcmp+0x11>
		p++, q++;
f01069d7:	83 c1 01             	add    $0x1,%ecx
f01069da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01069dd:	0f b6 01             	movzbl (%ecx),%eax
f01069e0:	84 c0                	test   %al,%al
f01069e2:	74 04                	je     f01069e8 <strcmp+0x1c>
f01069e4:	3a 02                	cmp    (%edx),%al
f01069e6:	74 ef                	je     f01069d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01069e8:	0f b6 c0             	movzbl %al,%eax
f01069eb:	0f b6 12             	movzbl (%edx),%edx
f01069ee:	29 d0                	sub    %edx,%eax
}
f01069f0:	5d                   	pop    %ebp
f01069f1:	c3                   	ret    

f01069f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01069f2:	55                   	push   %ebp
f01069f3:	89 e5                	mov    %esp,%ebp
f01069f5:	53                   	push   %ebx
f01069f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01069f9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01069fc:	89 c3                	mov    %eax,%ebx
f01069fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0106a01:	eb 06                	jmp    f0106a09 <strncmp+0x17>
		n--, p++, q++;
f0106a03:	83 c0 01             	add    $0x1,%eax
f0106a06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106a09:	39 d8                	cmp    %ebx,%eax
f0106a0b:	74 15                	je     f0106a22 <strncmp+0x30>
f0106a0d:	0f b6 08             	movzbl (%eax),%ecx
f0106a10:	84 c9                	test   %cl,%cl
f0106a12:	74 04                	je     f0106a18 <strncmp+0x26>
f0106a14:	3a 0a                	cmp    (%edx),%cl
f0106a16:	74 eb                	je     f0106a03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106a18:	0f b6 00             	movzbl (%eax),%eax
f0106a1b:	0f b6 12             	movzbl (%edx),%edx
f0106a1e:	29 d0                	sub    %edx,%eax
f0106a20:	eb 05                	jmp    f0106a27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106a22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106a27:	5b                   	pop    %ebx
f0106a28:	5d                   	pop    %ebp
f0106a29:	c3                   	ret    

f0106a2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106a2a:	55                   	push   %ebp
f0106a2b:	89 e5                	mov    %esp,%ebp
f0106a2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106a30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106a34:	eb 07                	jmp    f0106a3d <strchr+0x13>
		if (*s == c)
f0106a36:	38 ca                	cmp    %cl,%dl
f0106a38:	74 0f                	je     f0106a49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106a3a:	83 c0 01             	add    $0x1,%eax
f0106a3d:	0f b6 10             	movzbl (%eax),%edx
f0106a40:	84 d2                	test   %dl,%dl
f0106a42:	75 f2                	jne    f0106a36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0106a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106a49:	5d                   	pop    %ebp
f0106a4a:	c3                   	ret    

f0106a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0106a4b:	55                   	push   %ebp
f0106a4c:	89 e5                	mov    %esp,%ebp
f0106a4e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106a55:	eb 07                	jmp    f0106a5e <strfind+0x13>
		if (*s == c)
f0106a57:	38 ca                	cmp    %cl,%dl
f0106a59:	74 0a                	je     f0106a65 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0106a5b:	83 c0 01             	add    $0x1,%eax
f0106a5e:	0f b6 10             	movzbl (%eax),%edx
f0106a61:	84 d2                	test   %dl,%dl
f0106a63:	75 f2                	jne    f0106a57 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0106a65:	5d                   	pop    %ebp
f0106a66:	c3                   	ret    

f0106a67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106a67:	55                   	push   %ebp
f0106a68:	89 e5                	mov    %esp,%ebp
f0106a6a:	57                   	push   %edi
f0106a6b:	56                   	push   %esi
f0106a6c:	53                   	push   %ebx
f0106a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106a70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106a73:	85 c9                	test   %ecx,%ecx
f0106a75:	74 36                	je     f0106aad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106a77:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106a7d:	75 28                	jne    f0106aa7 <memset+0x40>
f0106a7f:	f6 c1 03             	test   $0x3,%cl
f0106a82:	75 23                	jne    f0106aa7 <memset+0x40>
		c &= 0xFF;
f0106a84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106a88:	89 d3                	mov    %edx,%ebx
f0106a8a:	c1 e3 08             	shl    $0x8,%ebx
f0106a8d:	89 d6                	mov    %edx,%esi
f0106a8f:	c1 e6 18             	shl    $0x18,%esi
f0106a92:	89 d0                	mov    %edx,%eax
f0106a94:	c1 e0 10             	shl    $0x10,%eax
f0106a97:	09 f0                	or     %esi,%eax
f0106a99:	09 c2                	or     %eax,%edx
f0106a9b:	89 d0                	mov    %edx,%eax
f0106a9d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0106a9f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106aa2:	fc                   	cld    
f0106aa3:	f3 ab                	rep stos %eax,%es:(%edi)
f0106aa5:	eb 06                	jmp    f0106aad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106aaa:	fc                   	cld    
f0106aab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0106aad:	89 f8                	mov    %edi,%eax
f0106aaf:	5b                   	pop    %ebx
f0106ab0:	5e                   	pop    %esi
f0106ab1:	5f                   	pop    %edi
f0106ab2:	5d                   	pop    %ebp
f0106ab3:	c3                   	ret    

f0106ab4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106ab4:	55                   	push   %ebp
f0106ab5:	89 e5                	mov    %esp,%ebp
f0106ab7:	57                   	push   %edi
f0106ab8:	56                   	push   %esi
f0106ab9:	8b 45 08             	mov    0x8(%ebp),%eax
f0106abc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106ac2:	39 c6                	cmp    %eax,%esi
f0106ac4:	73 35                	jae    f0106afb <memmove+0x47>
f0106ac6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106ac9:	39 d0                	cmp    %edx,%eax
f0106acb:	73 2e                	jae    f0106afb <memmove+0x47>
		s += n;
		d += n;
f0106acd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0106ad0:	89 d6                	mov    %edx,%esi
f0106ad2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106ada:	75 13                	jne    f0106aef <memmove+0x3b>
f0106adc:	f6 c1 03             	test   $0x3,%cl
f0106adf:	75 0e                	jne    f0106aef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106ae1:	83 ef 04             	sub    $0x4,%edi
f0106ae4:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106ae7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0106aea:	fd                   	std    
f0106aeb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106aed:	eb 09                	jmp    f0106af8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0106aef:	83 ef 01             	sub    $0x1,%edi
f0106af2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106af5:	fd                   	std    
f0106af6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106af8:	fc                   	cld    
f0106af9:	eb 1d                	jmp    f0106b18 <memmove+0x64>
f0106afb:	89 f2                	mov    %esi,%edx
f0106afd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106aff:	f6 c2 03             	test   $0x3,%dl
f0106b02:	75 0f                	jne    f0106b13 <memmove+0x5f>
f0106b04:	f6 c1 03             	test   $0x3,%cl
f0106b07:	75 0a                	jne    f0106b13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0106b09:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0106b0c:	89 c7                	mov    %eax,%edi
f0106b0e:	fc                   	cld    
f0106b0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106b11:	eb 05                	jmp    f0106b18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106b13:	89 c7                	mov    %eax,%edi
f0106b15:	fc                   	cld    
f0106b16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106b18:	5e                   	pop    %esi
f0106b19:	5f                   	pop    %edi
f0106b1a:	5d                   	pop    %ebp
f0106b1b:	c3                   	ret    

f0106b1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106b1c:	55                   	push   %ebp
f0106b1d:	89 e5                	mov    %esp,%ebp
f0106b1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106b22:	8b 45 10             	mov    0x10(%ebp),%eax
f0106b25:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106b29:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b30:	8b 45 08             	mov    0x8(%ebp),%eax
f0106b33:	89 04 24             	mov    %eax,(%esp)
f0106b36:	e8 79 ff ff ff       	call   f0106ab4 <memmove>
}
f0106b3b:	c9                   	leave  
f0106b3c:	c3                   	ret    

f0106b3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106b3d:	55                   	push   %ebp
f0106b3e:	89 e5                	mov    %esp,%ebp
f0106b40:	56                   	push   %esi
f0106b41:	53                   	push   %ebx
f0106b42:	8b 55 08             	mov    0x8(%ebp),%edx
f0106b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106b48:	89 d6                	mov    %edx,%esi
f0106b4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106b4d:	eb 1a                	jmp    f0106b69 <memcmp+0x2c>
		if (*s1 != *s2)
f0106b4f:	0f b6 02             	movzbl (%edx),%eax
f0106b52:	0f b6 19             	movzbl (%ecx),%ebx
f0106b55:	38 d8                	cmp    %bl,%al
f0106b57:	74 0a                	je     f0106b63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0106b59:	0f b6 c0             	movzbl %al,%eax
f0106b5c:	0f b6 db             	movzbl %bl,%ebx
f0106b5f:	29 d8                	sub    %ebx,%eax
f0106b61:	eb 0f                	jmp    f0106b72 <memcmp+0x35>
		s1++, s2++;
f0106b63:	83 c2 01             	add    $0x1,%edx
f0106b66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106b69:	39 f2                	cmp    %esi,%edx
f0106b6b:	75 e2                	jne    f0106b4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106b6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106b72:	5b                   	pop    %ebx
f0106b73:	5e                   	pop    %esi
f0106b74:	5d                   	pop    %ebp
f0106b75:	c3                   	ret    

f0106b76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106b76:	55                   	push   %ebp
f0106b77:	89 e5                	mov    %esp,%ebp
f0106b79:	8b 45 08             	mov    0x8(%ebp),%eax
f0106b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0106b7f:	89 c2                	mov    %eax,%edx
f0106b81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106b84:	eb 07                	jmp    f0106b8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106b86:	38 08                	cmp    %cl,(%eax)
f0106b88:	74 07                	je     f0106b91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106b8a:	83 c0 01             	add    $0x1,%eax
f0106b8d:	39 d0                	cmp    %edx,%eax
f0106b8f:	72 f5                	jb     f0106b86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106b91:	5d                   	pop    %ebp
f0106b92:	c3                   	ret    

f0106b93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106b93:	55                   	push   %ebp
f0106b94:	89 e5                	mov    %esp,%ebp
f0106b96:	57                   	push   %edi
f0106b97:	56                   	push   %esi
f0106b98:	53                   	push   %ebx
f0106b99:	8b 55 08             	mov    0x8(%ebp),%edx
f0106b9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106b9f:	eb 03                	jmp    f0106ba4 <strtol+0x11>
		s++;
f0106ba1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106ba4:	0f b6 0a             	movzbl (%edx),%ecx
f0106ba7:	80 f9 09             	cmp    $0x9,%cl
f0106baa:	74 f5                	je     f0106ba1 <strtol+0xe>
f0106bac:	80 f9 20             	cmp    $0x20,%cl
f0106baf:	74 f0                	je     f0106ba1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106bb1:	80 f9 2b             	cmp    $0x2b,%cl
f0106bb4:	75 0a                	jne    f0106bc0 <strtol+0x2d>
		s++;
f0106bb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106bb9:	bf 00 00 00 00       	mov    $0x0,%edi
f0106bbe:	eb 11                	jmp    f0106bd1 <strtol+0x3e>
f0106bc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106bc5:	80 f9 2d             	cmp    $0x2d,%cl
f0106bc8:	75 07                	jne    f0106bd1 <strtol+0x3e>
		s++, neg = 1;
f0106bca:	8d 52 01             	lea    0x1(%edx),%edx
f0106bcd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106bd1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0106bd6:	75 15                	jne    f0106bed <strtol+0x5a>
f0106bd8:	80 3a 30             	cmpb   $0x30,(%edx)
f0106bdb:	75 10                	jne    f0106bed <strtol+0x5a>
f0106bdd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106be1:	75 0a                	jne    f0106bed <strtol+0x5a>
		s += 2, base = 16;
f0106be3:	83 c2 02             	add    $0x2,%edx
f0106be6:	b8 10 00 00 00       	mov    $0x10,%eax
f0106beb:	eb 10                	jmp    f0106bfd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0106bed:	85 c0                	test   %eax,%eax
f0106bef:	75 0c                	jne    f0106bfd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106bf1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106bf3:	80 3a 30             	cmpb   $0x30,(%edx)
f0106bf6:	75 05                	jne    f0106bfd <strtol+0x6a>
		s++, base = 8;
f0106bf8:	83 c2 01             	add    $0x1,%edx
f0106bfb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0106bfd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106c02:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106c05:	0f b6 0a             	movzbl (%edx),%ecx
f0106c08:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0106c0b:	89 f0                	mov    %esi,%eax
f0106c0d:	3c 09                	cmp    $0x9,%al
f0106c0f:	77 08                	ja     f0106c19 <strtol+0x86>
			dig = *s - '0';
f0106c11:	0f be c9             	movsbl %cl,%ecx
f0106c14:	83 e9 30             	sub    $0x30,%ecx
f0106c17:	eb 20                	jmp    f0106c39 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0106c19:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0106c1c:	89 f0                	mov    %esi,%eax
f0106c1e:	3c 19                	cmp    $0x19,%al
f0106c20:	77 08                	ja     f0106c2a <strtol+0x97>
			dig = *s - 'a' + 10;
f0106c22:	0f be c9             	movsbl %cl,%ecx
f0106c25:	83 e9 57             	sub    $0x57,%ecx
f0106c28:	eb 0f                	jmp    f0106c39 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0106c2a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0106c2d:	89 f0                	mov    %esi,%eax
f0106c2f:	3c 19                	cmp    $0x19,%al
f0106c31:	77 16                	ja     f0106c49 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0106c33:	0f be c9             	movsbl %cl,%ecx
f0106c36:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106c39:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0106c3c:	7d 0f                	jge    f0106c4d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0106c3e:	83 c2 01             	add    $0x1,%edx
f0106c41:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0106c45:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0106c47:	eb bc                	jmp    f0106c05 <strtol+0x72>
f0106c49:	89 d8                	mov    %ebx,%eax
f0106c4b:	eb 02                	jmp    f0106c4f <strtol+0xbc>
f0106c4d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0106c4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106c53:	74 05                	je     f0106c5a <strtol+0xc7>
		*endptr = (char *) s;
f0106c55:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106c58:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0106c5a:	f7 d8                	neg    %eax
f0106c5c:	85 ff                	test   %edi,%edi
f0106c5e:	0f 44 c3             	cmove  %ebx,%eax
}
f0106c61:	5b                   	pop    %ebx
f0106c62:	5e                   	pop    %esi
f0106c63:	5f                   	pop    %edi
f0106c64:	5d                   	pop    %ebp
f0106c65:	c3                   	ret    
f0106c66:	66 90                	xchg   %ax,%ax

f0106c68 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106c68:	fa                   	cli    

	xorw    %ax, %ax
f0106c69:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106c6b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106c6d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106c6f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106c71:	0f 01 16             	lgdtl  (%esi)
f0106c74:	74 70                	je     f0106ce6 <mpentry_end+0x4>
	movl    %cr0, %eax
f0106c76:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106c79:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106c7d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106c80:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106c86:	08 00                	or     %al,(%eax)

f0106c88 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106c88:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106c8c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106c8e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106c90:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106c92:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106c96:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106c98:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106c9a:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0106c9f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106ca2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106ca5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106caa:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106cad:	8b 25 84 fe 23 f0    	mov    0xf023fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106cb3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106cb8:	b8 e2 01 10 f0       	mov    $0xf01001e2,%eax
	call    *%eax
f0106cbd:	ff d0                	call   *%eax

f0106cbf <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106cbf:	eb fe                	jmp    f0106cbf <spin>
f0106cc1:	8d 76 00             	lea    0x0(%esi),%esi

f0106cc4 <gdt>:
	...
f0106ccc:	ff                   	(bad)  
f0106ccd:	ff 00                	incl   (%eax)
f0106ccf:	00 00                	add    %al,(%eax)
f0106cd1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106cd8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106cdc <gdtdesc>:
f0106cdc:	17                   	pop    %ss
f0106cdd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106ce2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106ce2:	90                   	nop
f0106ce3:	66 90                	xchg   %ax,%ax
f0106ce5:	66 90                	xchg   %ax,%ax
f0106ce7:	66 90                	xchg   %ax,%ax
f0106ce9:	66 90                	xchg   %ax,%ax
f0106ceb:	66 90                	xchg   %ax,%ax
f0106ced:	66 90                	xchg   %ax,%ax
f0106cef:	90                   	nop

f0106cf0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106cf0:	55                   	push   %ebp
f0106cf1:	89 e5                	mov    %esp,%ebp
f0106cf3:	56                   	push   %esi
f0106cf4:	53                   	push   %ebx
f0106cf5:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106cf8:	8b 0d 88 fe 23 f0    	mov    0xf023fe88,%ecx
f0106cfe:	89 c3                	mov    %eax,%ebx
f0106d00:	c1 eb 0c             	shr    $0xc,%ebx
f0106d03:	39 cb                	cmp    %ecx,%ebx
f0106d05:	72 20                	jb     f0106d27 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106d07:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106d0b:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0106d12:	f0 
f0106d13:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106d1a:	00 
f0106d1b:	c7 04 24 65 94 10 f0 	movl   $0xf0109465,(%esp)
f0106d22:	e8 19 93 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106d27:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106d2d:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106d2f:	89 c2                	mov    %eax,%edx
f0106d31:	c1 ea 0c             	shr    $0xc,%edx
f0106d34:	39 d1                	cmp    %edx,%ecx
f0106d36:	77 20                	ja     f0106d58 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106d38:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106d3c:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0106d43:	f0 
f0106d44:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106d4b:	00 
f0106d4c:	c7 04 24 65 94 10 f0 	movl   $0xf0109465,(%esp)
f0106d53:	e8 e8 92 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106d58:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0106d5e:	eb 36                	jmp    f0106d96 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106d60:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106d67:	00 
f0106d68:	c7 44 24 04 75 94 10 	movl   $0xf0109475,0x4(%esp)
f0106d6f:	f0 
f0106d70:	89 1c 24             	mov    %ebx,(%esp)
f0106d73:	e8 c5 fd ff ff       	call   f0106b3d <memcmp>
f0106d78:	85 c0                	test   %eax,%eax
f0106d7a:	75 17                	jne    f0106d93 <mpsearch1+0xa3>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106d7c:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106d81:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106d85:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106d87:	83 c2 01             	add    $0x1,%edx
f0106d8a:	83 fa 10             	cmp    $0x10,%edx
f0106d8d:	75 f2                	jne    f0106d81 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106d8f:	84 c0                	test   %al,%al
f0106d91:	74 0e                	je     f0106da1 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106d93:	83 c3 10             	add    $0x10,%ebx
f0106d96:	39 f3                	cmp    %esi,%ebx
f0106d98:	72 c6                	jb     f0106d60 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106d9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0106d9f:	eb 02                	jmp    f0106da3 <mpsearch1+0xb3>
f0106da1:	89 d8                	mov    %ebx,%eax
}
f0106da3:	83 c4 10             	add    $0x10,%esp
f0106da6:	5b                   	pop    %ebx
f0106da7:	5e                   	pop    %esi
f0106da8:	5d                   	pop    %ebp
f0106da9:	c3                   	ret    

f0106daa <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106daa:	55                   	push   %ebp
f0106dab:	89 e5                	mov    %esp,%ebp
f0106dad:	57                   	push   %edi
f0106dae:	56                   	push   %esi
f0106daf:	53                   	push   %ebx
f0106db0:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106db3:	c7 05 c0 13 24 f0 20 	movl   $0xf0241020,0xf02413c0
f0106dba:	10 24 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106dbd:	83 3d 88 fe 23 f0 00 	cmpl   $0x0,0xf023fe88
f0106dc4:	75 24                	jne    f0106dea <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106dc6:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106dcd:	00 
f0106dce:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0106dd5:	f0 
f0106dd6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106ddd:	00 
f0106dde:	c7 04 24 65 94 10 f0 	movl   $0xf0109465,(%esp)
f0106de5:	e8 56 92 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106dea:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106df1:	85 c0                	test   %eax,%eax
f0106df3:	74 16                	je     f0106e0b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106df5:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106df8:	ba 00 04 00 00       	mov    $0x400,%edx
f0106dfd:	e8 ee fe ff ff       	call   f0106cf0 <mpsearch1>
f0106e02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106e05:	85 c0                	test   %eax,%eax
f0106e07:	75 3c                	jne    f0106e45 <mp_init+0x9b>
f0106e09:	eb 20                	jmp    f0106e2b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106e0b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106e12:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106e15:	2d 00 04 00 00       	sub    $0x400,%eax
f0106e1a:	ba 00 04 00 00       	mov    $0x400,%edx
f0106e1f:	e8 cc fe ff ff       	call   f0106cf0 <mpsearch1>
f0106e24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106e27:	85 c0                	test   %eax,%eax
f0106e29:	75 1a                	jne    f0106e45 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106e2b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106e30:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106e35:	e8 b6 fe ff ff       	call   f0106cf0 <mpsearch1>
f0106e3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106e3d:	85 c0                	test   %eax,%eax
f0106e3f:	0f 84 54 02 00 00    	je     f0107099 <mp_init+0x2ef>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106e45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106e48:	8b 70 04             	mov    0x4(%eax),%esi
f0106e4b:	85 f6                	test   %esi,%esi
f0106e4d:	74 06                	je     f0106e55 <mp_init+0xab>
f0106e4f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106e53:	74 11                	je     f0106e66 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106e55:	c7 04 24 d8 92 10 f0 	movl   $0xf01092d8,(%esp)
f0106e5c:	e8 22 d2 ff ff       	call   f0104083 <cprintf>
f0106e61:	e9 33 02 00 00       	jmp    f0107099 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106e66:	89 f0                	mov    %esi,%eax
f0106e68:	c1 e8 0c             	shr    $0xc,%eax
f0106e6b:	3b 05 88 fe 23 f0    	cmp    0xf023fe88,%eax
f0106e71:	72 20                	jb     f0106e93 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106e73:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106e77:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f0106e7e:	f0 
f0106e7f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106e86:	00 
f0106e87:	c7 04 24 65 94 10 f0 	movl   $0xf0109465,(%esp)
f0106e8e:	e8 ad 91 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106e93:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106e99:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106ea0:	00 
f0106ea1:	c7 44 24 04 7a 94 10 	movl   $0xf010947a,0x4(%esp)
f0106ea8:	f0 
f0106ea9:	89 1c 24             	mov    %ebx,(%esp)
f0106eac:	e8 8c fc ff ff       	call   f0106b3d <memcmp>
f0106eb1:	85 c0                	test   %eax,%eax
f0106eb3:	74 11                	je     f0106ec6 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106eb5:	c7 04 24 08 93 10 f0 	movl   $0xf0109308,(%esp)
f0106ebc:	e8 c2 d1 ff ff       	call   f0104083 <cprintf>
f0106ec1:	e9 d3 01 00 00       	jmp    f0107099 <mp_init+0x2ef>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106ec6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0106eca:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0106ece:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106ed1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106ed6:	b8 00 00 00 00       	mov    $0x0,%eax
f0106edb:	eb 0d                	jmp    f0106eea <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f0106edd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106ee4:	f0 
f0106ee5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106ee7:	83 c0 01             	add    $0x1,%eax
f0106eea:	39 c7                	cmp    %eax,%edi
f0106eec:	7f ef                	jg     f0106edd <mp_init+0x133>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106eee:	84 d2                	test   %dl,%dl
f0106ef0:	74 11                	je     f0106f03 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106ef2:	c7 04 24 3c 93 10 f0 	movl   $0xf010933c,(%esp)
f0106ef9:	e8 85 d1 ff ff       	call   f0104083 <cprintf>
f0106efe:	e9 96 01 00 00       	jmp    f0107099 <mp_init+0x2ef>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106f03:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106f07:	3c 04                	cmp    $0x4,%al
f0106f09:	74 1f                	je     f0106f2a <mp_init+0x180>
f0106f0b:	3c 01                	cmp    $0x1,%al
f0106f0d:	8d 76 00             	lea    0x0(%esi),%esi
f0106f10:	74 18                	je     f0106f2a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106f12:	0f b6 c0             	movzbl %al,%eax
f0106f15:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f19:	c7 04 24 60 93 10 f0 	movl   $0xf0109360,(%esp)
f0106f20:	e8 5e d1 ff ff       	call   f0104083 <cprintf>
f0106f25:	e9 6f 01 00 00       	jmp    f0107099 <mp_init+0x2ef>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106f2a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f0106f2e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0106f32:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106f34:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106f39:	b8 00 00 00 00       	mov    $0x0,%eax
f0106f3e:	eb 09                	jmp    f0106f49 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f0106f40:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0106f44:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106f46:	83 c0 01             	add    $0x1,%eax
f0106f49:	39 c6                	cmp    %eax,%esi
f0106f4b:	7f f3                	jg     f0106f40 <mp_init+0x196>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106f4d:	02 53 2a             	add    0x2a(%ebx),%dl
f0106f50:	84 d2                	test   %dl,%dl
f0106f52:	74 11                	je     f0106f65 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106f54:	c7 04 24 80 93 10 f0 	movl   $0xf0109380,(%esp)
f0106f5b:	e8 23 d1 ff ff       	call   f0104083 <cprintf>
f0106f60:	e9 34 01 00 00       	jmp    f0107099 <mp_init+0x2ef>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106f65:	85 db                	test   %ebx,%ebx
f0106f67:	0f 84 2c 01 00 00    	je     f0107099 <mp_init+0x2ef>
		return;
	ismp = 1;
f0106f6d:	c7 05 00 10 24 f0 01 	movl   $0x1,0xf0241000
f0106f74:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106f77:	8b 43 24             	mov    0x24(%ebx),%eax
f0106f7a:	a3 00 20 28 f0       	mov    %eax,0xf0282000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106f7f:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106f82:	be 00 00 00 00       	mov    $0x0,%esi
f0106f87:	e9 86 00 00 00       	jmp    f0107012 <mp_init+0x268>
		switch (*p) {
f0106f8c:	0f b6 07             	movzbl (%edi),%eax
f0106f8f:	84 c0                	test   %al,%al
f0106f91:	74 06                	je     f0106f99 <mp_init+0x1ef>
f0106f93:	3c 04                	cmp    $0x4,%al
f0106f95:	77 57                	ja     f0106fee <mp_init+0x244>
f0106f97:	eb 50                	jmp    f0106fe9 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106f99:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106f9d:	8d 76 00             	lea    0x0(%esi),%esi
f0106fa0:	74 11                	je     f0106fb3 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106fa2:	6b 05 c4 13 24 f0 74 	imul   $0x74,0xf02413c4,%eax
f0106fa9:	05 20 10 24 f0       	add    $0xf0241020,%eax
f0106fae:	a3 c0 13 24 f0       	mov    %eax,0xf02413c0
			if (ncpu < NCPU) {
f0106fb3:	a1 c4 13 24 f0       	mov    0xf02413c4,%eax
f0106fb8:	83 f8 07             	cmp    $0x7,%eax
f0106fbb:	7f 13                	jg     f0106fd0 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f0106fbd:	6b d0 74             	imul   $0x74,%eax,%edx
f0106fc0:	88 82 20 10 24 f0    	mov    %al,-0xfdbefe0(%edx)
				ncpu++;
f0106fc6:	83 c0 01             	add    $0x1,%eax
f0106fc9:	a3 c4 13 24 f0       	mov    %eax,0xf02413c4
f0106fce:	eb 14                	jmp    f0106fe4 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106fd0:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106fd8:	c7 04 24 b0 93 10 f0 	movl   $0xf01093b0,(%esp)
f0106fdf:	e8 9f d0 ff ff       	call   f0104083 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106fe4:	83 c7 14             	add    $0x14,%edi
			continue;
f0106fe7:	eb 26                	jmp    f010700f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106fe9:	83 c7 08             	add    $0x8,%edi
			continue;
f0106fec:	eb 21                	jmp    f010700f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106fee:	0f b6 c0             	movzbl %al,%eax
f0106ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ff5:	c7 04 24 d8 93 10 f0 	movl   $0xf01093d8,(%esp)
f0106ffc:	e8 82 d0 ff ff       	call   f0104083 <cprintf>
			ismp = 0;
f0107001:	c7 05 00 10 24 f0 00 	movl   $0x0,0xf0241000
f0107008:	00 00 00 
			i = conf->entry;
f010700b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010700f:	83 c6 01             	add    $0x1,%esi
f0107012:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0107016:	39 c6                	cmp    %eax,%esi
f0107018:	0f 82 6e ff ff ff    	jb     f0106f8c <mp_init+0x1e2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010701e:	a1 c0 13 24 f0       	mov    0xf02413c0,%eax
f0107023:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010702a:	83 3d 00 10 24 f0 00 	cmpl   $0x0,0xf0241000
f0107031:	75 22                	jne    f0107055 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0107033:	c7 05 c4 13 24 f0 01 	movl   $0x1,0xf02413c4
f010703a:	00 00 00 
		lapicaddr = 0;
f010703d:	c7 05 00 20 28 f0 00 	movl   $0x0,0xf0282000
f0107044:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0107047:	c7 04 24 f8 93 10 f0 	movl   $0xf01093f8,(%esp)
f010704e:	e8 30 d0 ff ff       	call   f0104083 <cprintf>
		return;
f0107053:	eb 44                	jmp    f0107099 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0107055:	8b 15 c4 13 24 f0    	mov    0xf02413c4,%edx
f010705b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010705f:	0f b6 00             	movzbl (%eax),%eax
f0107062:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107066:	c7 04 24 7f 94 10 f0 	movl   $0xf010947f,(%esp)
f010706d:	e8 11 d0 ff ff       	call   f0104083 <cprintf>

	if (mp->imcrp) {
f0107072:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107075:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0107079:	74 1e                	je     f0107099 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010707b:	c7 04 24 24 94 10 f0 	movl   $0xf0109424,(%esp)
f0107082:	e8 fc cf ff ff       	call   f0104083 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0107087:	ba 22 00 00 00       	mov    $0x22,%edx
f010708c:	b8 70 00 00 00       	mov    $0x70,%eax
f0107091:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0107092:	b2 23                	mov    $0x23,%dl
f0107094:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0107095:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0107098:	ee                   	out    %al,(%dx)
	}
}
f0107099:	83 c4 2c             	add    $0x2c,%esp
f010709c:	5b                   	pop    %ebx
f010709d:	5e                   	pop    %esi
f010709e:	5f                   	pop    %edi
f010709f:	5d                   	pop    %ebp
f01070a0:	c3                   	ret    

f01070a1 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01070a1:	55                   	push   %ebp
f01070a2:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01070a4:	8b 0d 04 20 28 f0    	mov    0xf0282004,%ecx
f01070aa:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01070ad:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01070af:	a1 04 20 28 f0       	mov    0xf0282004,%eax
f01070b4:	8b 40 20             	mov    0x20(%eax),%eax
}
f01070b7:	5d                   	pop    %ebp
f01070b8:	c3                   	ret    

f01070b9 <cpunum>:
	
}

int
cpunum(void)
{
f01070b9:	55                   	push   %ebp
f01070ba:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01070bc:	a1 04 20 28 f0       	mov    0xf0282004,%eax
f01070c1:	85 c0                	test   %eax,%eax
f01070c3:	74 08                	je     f01070cd <cpunum+0x14>
		return lapic[ID] >> 24;
f01070c5:	8b 40 20             	mov    0x20(%eax),%eax
f01070c8:	c1 e8 18             	shr    $0x18,%eax
f01070cb:	eb 05                	jmp    f01070d2 <cpunum+0x19>
	return 0;
f01070cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01070d2:	5d                   	pop    %ebp
f01070d3:	c3                   	ret    

f01070d4 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01070d4:	a1 00 20 28 f0       	mov    0xf0282000,%eax
f01070d9:	85 c0                	test   %eax,%eax
f01070db:	0f 84 23 01 00 00    	je     f0107204 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01070e1:	55                   	push   %ebp
f01070e2:	89 e5                	mov    %esp,%ebp
f01070e4:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01070e7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01070ee:	00 
f01070ef:	89 04 24             	mov    %eax,(%esp)
f01070f2:	e8 e9 a3 ff ff       	call   f01014e0 <mmio_map_region>
f01070f7:	a3 04 20 28 f0       	mov    %eax,0xf0282004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01070fc:	ba 27 01 00 00       	mov    $0x127,%edx
f0107101:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0107106:	e8 96 ff ff ff       	call   f01070a1 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010710b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0107110:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0107115:	e8 87 ff ff ff       	call   f01070a1 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010711a:	ba 20 00 02 00       	mov    $0x20020,%edx
f010711f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0107124:	e8 78 ff ff ff       	call   f01070a1 <lapicw>
	lapicw(TICR, 10000000); 
f0107129:	ba 80 96 98 00       	mov    $0x989680,%edx
f010712e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0107133:	e8 69 ff ff ff       	call   f01070a1 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0107138:	e8 7c ff ff ff       	call   f01070b9 <cpunum>
f010713d:	6b c0 74             	imul   $0x74,%eax,%eax
f0107140:	05 20 10 24 f0       	add    $0xf0241020,%eax
f0107145:	39 05 c0 13 24 f0    	cmp    %eax,0xf02413c0
f010714b:	74 0f                	je     f010715c <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f010714d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107152:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0107157:	e8 45 ff ff ff       	call   f01070a1 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010715c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107161:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0107166:	e8 36 ff ff ff       	call   f01070a1 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010716b:	a1 04 20 28 f0       	mov    0xf0282004,%eax
f0107170:	8b 40 30             	mov    0x30(%eax),%eax
f0107173:	c1 e8 10             	shr    $0x10,%eax
f0107176:	3c 03                	cmp    $0x3,%al
f0107178:	76 0f                	jbe    f0107189 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f010717a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010717f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0107184:	e8 18 ff ff ff       	call   f01070a1 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0107189:	ba 33 00 00 00       	mov    $0x33,%edx
f010718e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0107193:	e8 09 ff ff ff       	call   f01070a1 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0107198:	ba 00 00 00 00       	mov    $0x0,%edx
f010719d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01071a2:	e8 fa fe ff ff       	call   f01070a1 <lapicw>
	lapicw(ESR, 0);
f01071a7:	ba 00 00 00 00       	mov    $0x0,%edx
f01071ac:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01071b1:	e8 eb fe ff ff       	call   f01070a1 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01071b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01071bb:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01071c0:	e8 dc fe ff ff       	call   f01070a1 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01071c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01071ca:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01071cf:	e8 cd fe ff ff       	call   f01070a1 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01071d4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01071d9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01071de:	e8 be fe ff ff       	call   f01070a1 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01071e3:	8b 15 04 20 28 f0    	mov    0xf0282004,%edx
f01071e9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01071ef:	f6 c4 10             	test   $0x10,%ah
f01071f2:	75 f5                	jne    f01071e9 <lapic_init+0x115>
		;

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01071f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01071f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01071fe:	e8 9e fe ff ff       	call   f01070a1 <lapicw>
	
}
f0107203:	c9                   	leave  
f0107204:	f3 c3                	repz ret 

f0107206 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0107206:	83 3d 04 20 28 f0 00 	cmpl   $0x0,0xf0282004
f010720d:	74 13                	je     f0107222 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010720f:	55                   	push   %ebp
f0107210:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0107212:	ba 00 00 00 00       	mov    $0x0,%edx
f0107217:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010721c:	e8 80 fe ff ff       	call   f01070a1 <lapicw>
}
f0107221:	5d                   	pop    %ebp
f0107222:	f3 c3                	repz ret 

f0107224 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0107224:	55                   	push   %ebp
f0107225:	89 e5                	mov    %esp,%ebp
f0107227:	56                   	push   %esi
f0107228:	53                   	push   %ebx
f0107229:	83 ec 10             	sub    $0x10,%esp
f010722c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010722f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107232:	ba 70 00 00 00       	mov    $0x70,%edx
f0107237:	b8 0f 00 00 00       	mov    $0xf,%eax
f010723c:	ee                   	out    %al,(%dx)
f010723d:	b2 71                	mov    $0x71,%dl
f010723f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0107244:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107245:	83 3d 88 fe 23 f0 00 	cmpl   $0x0,0xf023fe88
f010724c:	75 24                	jne    f0107272 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010724e:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0107255:	00 
f0107256:	c7 44 24 08 c4 77 10 	movl   $0xf01077c4,0x8(%esp)
f010725d:	f0 
f010725e:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
f0107265:	00 
f0107266:	c7 04 24 9c 94 10 f0 	movl   $0xf010949c,(%esp)
f010726d:	e8 ce 8d ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0107272:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0107279:	00 00 
	wrv[1] = addr >> 4;
f010727b:	89 f0                	mov    %esi,%eax
f010727d:	c1 e8 04             	shr    $0x4,%eax
f0107280:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0107286:	c1 e3 18             	shl    $0x18,%ebx
f0107289:	89 da                	mov    %ebx,%edx
f010728b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107290:	e8 0c fe ff ff       	call   f01070a1 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0107295:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010729a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010729f:	e8 fd fd ff ff       	call   f01070a1 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01072a4:	ba 00 85 00 00       	mov    $0x8500,%edx
f01072a9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01072ae:	e8 ee fd ff ff       	call   f01070a1 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01072b3:	c1 ee 0c             	shr    $0xc,%esi
f01072b6:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01072bc:	89 da                	mov    %ebx,%edx
f01072be:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01072c3:	e8 d9 fd ff ff       	call   f01070a1 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01072c8:	89 f2                	mov    %esi,%edx
f01072ca:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01072cf:	e8 cd fd ff ff       	call   f01070a1 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01072d4:	89 da                	mov    %ebx,%edx
f01072d6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01072db:	e8 c1 fd ff ff       	call   f01070a1 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01072e0:	89 f2                	mov    %esi,%edx
f01072e2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01072e7:	e8 b5 fd ff ff       	call   f01070a1 <lapicw>
		microdelay(200);
	}
}
f01072ec:	83 c4 10             	add    $0x10,%esp
f01072ef:	5b                   	pop    %ebx
f01072f0:	5e                   	pop    %esi
f01072f1:	5d                   	pop    %ebp
f01072f2:	c3                   	ret    

f01072f3 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01072f3:	55                   	push   %ebp
f01072f4:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01072f6:	8b 55 08             	mov    0x8(%ebp),%edx
f01072f9:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01072ff:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107304:	e8 98 fd ff ff       	call   f01070a1 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0107309:	8b 15 04 20 28 f0    	mov    0xf0282004,%edx
f010730f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0107315:	f6 c4 10             	test   $0x10,%ah
f0107318:	75 f5                	jne    f010730f <lapic_ipi+0x1c>
		;
}
f010731a:	5d                   	pop    %ebp
f010731b:	c3                   	ret    

f010731c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010731c:	55                   	push   %ebp
f010731d:	89 e5                	mov    %esp,%ebp
f010731f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0107322:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0107328:	8b 55 0c             	mov    0xc(%ebp),%edx
f010732b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010732e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0107335:	5d                   	pop    %ebp
f0107336:	c3                   	ret    

f0107337 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0107337:	55                   	push   %ebp
f0107338:	89 e5                	mov    %esp,%ebp
f010733a:	56                   	push   %esi
f010733b:	53                   	push   %ebx
f010733c:	83 ec 20             	sub    $0x20,%esp
f010733f:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0107342:	83 3b 00             	cmpl   $0x0,(%ebx)
f0107345:	75 07                	jne    f010734e <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0107347:	ba 01 00 00 00       	mov    $0x1,%edx
f010734c:	eb 42                	jmp    f0107390 <spin_lock+0x59>
f010734e:	8b 73 08             	mov    0x8(%ebx),%esi
f0107351:	e8 63 fd ff ff       	call   f01070b9 <cpunum>
f0107356:	6b c0 74             	imul   $0x74,%eax,%eax
f0107359:	05 20 10 24 f0       	add    $0xf0241020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010735e:	39 c6                	cmp    %eax,%esi
f0107360:	75 e5                	jne    f0107347 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0107362:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107365:	e8 4f fd ff ff       	call   f01070b9 <cpunum>
f010736a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010736e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107372:	c7 44 24 08 ac 94 10 	movl   $0xf01094ac,0x8(%esp)
f0107379:	f0 
f010737a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0107381:	00 
f0107382:	c7 04 24 10 95 10 f0 	movl   $0xf0109510,(%esp)
f0107389:	e8 b2 8c ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010738e:	f3 90                	pause  
f0107390:	89 d0                	mov    %edx,%eax
f0107392:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107395:	85 c0                	test   %eax,%eax
f0107397:	75 f5                	jne    f010738e <spin_lock+0x57>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0107399:	e8 1b fd ff ff       	call   f01070b9 <cpunum>
f010739e:	6b c0 74             	imul   $0x74,%eax,%eax
f01073a1:	05 20 10 24 f0       	add    $0xf0241020,%eax
f01073a6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01073a9:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f01073ac:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01073ae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01073b3:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01073b9:	76 12                	jbe    f01073cd <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01073bb:	8b 4a 04             	mov    0x4(%edx),%ecx
f01073be:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01073c1:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01073c3:	83 c0 01             	add    $0x1,%eax
f01073c6:	83 f8 0a             	cmp    $0xa,%eax
f01073c9:	75 e8                	jne    f01073b3 <spin_lock+0x7c>
f01073cb:	eb 0f                	jmp    f01073dc <spin_lock+0xa5>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01073cd:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01073d4:	83 c0 01             	add    $0x1,%eax
f01073d7:	83 f8 09             	cmp    $0x9,%eax
f01073da:	7e f1                	jle    f01073cd <spin_lock+0x96>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01073dc:	83 c4 20             	add    $0x20,%esp
f01073df:	5b                   	pop    %ebx
f01073e0:	5e                   	pop    %esi
f01073e1:	5d                   	pop    %ebp
f01073e2:	c3                   	ret    

f01073e3 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01073e3:	55                   	push   %ebp
f01073e4:	89 e5                	mov    %esp,%ebp
f01073e6:	57                   	push   %edi
f01073e7:	56                   	push   %esi
f01073e8:	53                   	push   %ebx
f01073e9:	83 ec 6c             	sub    $0x6c,%esp
f01073ec:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01073ef:	83 3e 00             	cmpl   $0x0,(%esi)
f01073f2:	74 18                	je     f010740c <spin_unlock+0x29>
f01073f4:	8b 5e 08             	mov    0x8(%esi),%ebx
f01073f7:	e8 bd fc ff ff       	call   f01070b9 <cpunum>
f01073fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01073ff:	05 20 10 24 f0       	add    $0xf0241020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0107404:	39 c3                	cmp    %eax,%ebx
f0107406:	0f 84 ce 00 00 00    	je     f01074da <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010740c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0107413:	00 
f0107414:	8d 46 0c             	lea    0xc(%esi),%eax
f0107417:	89 44 24 04          	mov    %eax,0x4(%esp)
f010741b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010741e:	89 1c 24             	mov    %ebx,(%esp)
f0107421:	e8 8e f6 ff ff       	call   f0106ab4 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0107426:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0107429:	0f b6 38             	movzbl (%eax),%edi
f010742c:	8b 76 04             	mov    0x4(%esi),%esi
f010742f:	e8 85 fc ff ff       	call   f01070b9 <cpunum>
f0107434:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107438:	89 74 24 08          	mov    %esi,0x8(%esp)
f010743c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107440:	c7 04 24 d8 94 10 f0 	movl   $0xf01094d8,(%esp)
f0107447:	e8 37 cc ff ff       	call   f0104083 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010744c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010744f:	eb 65                	jmp    f01074b6 <spin_unlock+0xd3>
f0107451:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107455:	89 04 24             	mov    %eax,(%esp)
f0107458:	e8 bf e5 ff ff       	call   f0105a1c <debuginfo_eip>
f010745d:	85 c0                	test   %eax,%eax
f010745f:	78 39                	js     f010749a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0107461:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0107463:	89 c2                	mov    %eax,%edx
f0107465:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0107468:	89 54 24 18          	mov    %edx,0x18(%esp)
f010746c:	8b 55 b0             	mov    -0x50(%ebp),%edx
f010746f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107473:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0107476:	89 54 24 10          	mov    %edx,0x10(%esp)
f010747a:	8b 55 ac             	mov    -0x54(%ebp),%edx
f010747d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107481:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0107484:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107488:	89 44 24 04          	mov    %eax,0x4(%esp)
f010748c:	c7 04 24 20 95 10 f0 	movl   $0xf0109520,(%esp)
f0107493:	e8 eb cb ff ff       	call   f0104083 <cprintf>
f0107498:	eb 12                	jmp    f01074ac <spin_unlock+0xc9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010749a:	8b 06                	mov    (%esi),%eax
f010749c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01074a0:	c7 04 24 37 95 10 f0 	movl   $0xf0109537,(%esp)
f01074a7:	e8 d7 cb ff ff       	call   f0104083 <cprintf>
f01074ac:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01074af:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01074b2:	39 c3                	cmp    %eax,%ebx
f01074b4:	74 08                	je     f01074be <spin_unlock+0xdb>
f01074b6:	89 de                	mov    %ebx,%esi
f01074b8:	8b 03                	mov    (%ebx),%eax
f01074ba:	85 c0                	test   %eax,%eax
f01074bc:	75 93                	jne    f0107451 <spin_unlock+0x6e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01074be:	c7 44 24 08 3f 95 10 	movl   $0xf010953f,0x8(%esp)
f01074c5:	f0 
f01074c6:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01074cd:	00 
f01074ce:	c7 04 24 10 95 10 f0 	movl   $0xf0109510,(%esp)
f01074d5:	e8 66 8b ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01074da:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01074e1:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f01074e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01074ed:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01074f0:	83 c4 6c             	add    $0x6c,%esp
f01074f3:	5b                   	pop    %ebx
f01074f4:	5e                   	pop    %esi
f01074f5:	5f                   	pop    %edi
f01074f6:	5d                   	pop    %ebp
f01074f7:	c3                   	ret    
f01074f8:	66 90                	xchg   %ax,%ax
f01074fa:	66 90                	xchg   %ax,%ax
f01074fc:	66 90                	xchg   %ax,%ax
f01074fe:	66 90                	xchg   %ax,%ax

f0107500 <__udivdi3>:
f0107500:	55                   	push   %ebp
f0107501:	57                   	push   %edi
f0107502:	56                   	push   %esi
f0107503:	83 ec 0c             	sub    $0xc,%esp
f0107506:	8b 44 24 28          	mov    0x28(%esp),%eax
f010750a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010750e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0107512:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0107516:	85 c0                	test   %eax,%eax
f0107518:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010751c:	89 ea                	mov    %ebp,%edx
f010751e:	89 0c 24             	mov    %ecx,(%esp)
f0107521:	75 2d                	jne    f0107550 <__udivdi3+0x50>
f0107523:	39 e9                	cmp    %ebp,%ecx
f0107525:	77 61                	ja     f0107588 <__udivdi3+0x88>
f0107527:	85 c9                	test   %ecx,%ecx
f0107529:	89 ce                	mov    %ecx,%esi
f010752b:	75 0b                	jne    f0107538 <__udivdi3+0x38>
f010752d:	b8 01 00 00 00       	mov    $0x1,%eax
f0107532:	31 d2                	xor    %edx,%edx
f0107534:	f7 f1                	div    %ecx
f0107536:	89 c6                	mov    %eax,%esi
f0107538:	31 d2                	xor    %edx,%edx
f010753a:	89 e8                	mov    %ebp,%eax
f010753c:	f7 f6                	div    %esi
f010753e:	89 c5                	mov    %eax,%ebp
f0107540:	89 f8                	mov    %edi,%eax
f0107542:	f7 f6                	div    %esi
f0107544:	89 ea                	mov    %ebp,%edx
f0107546:	83 c4 0c             	add    $0xc,%esp
f0107549:	5e                   	pop    %esi
f010754a:	5f                   	pop    %edi
f010754b:	5d                   	pop    %ebp
f010754c:	c3                   	ret    
f010754d:	8d 76 00             	lea    0x0(%esi),%esi
f0107550:	39 e8                	cmp    %ebp,%eax
f0107552:	77 24                	ja     f0107578 <__udivdi3+0x78>
f0107554:	0f bd e8             	bsr    %eax,%ebp
f0107557:	83 f5 1f             	xor    $0x1f,%ebp
f010755a:	75 3c                	jne    f0107598 <__udivdi3+0x98>
f010755c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0107560:	39 34 24             	cmp    %esi,(%esp)
f0107563:	0f 86 9f 00 00 00    	jbe    f0107608 <__udivdi3+0x108>
f0107569:	39 d0                	cmp    %edx,%eax
f010756b:	0f 82 97 00 00 00    	jb     f0107608 <__udivdi3+0x108>
f0107571:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107578:	31 d2                	xor    %edx,%edx
f010757a:	31 c0                	xor    %eax,%eax
f010757c:	83 c4 0c             	add    $0xc,%esp
f010757f:	5e                   	pop    %esi
f0107580:	5f                   	pop    %edi
f0107581:	5d                   	pop    %ebp
f0107582:	c3                   	ret    
f0107583:	90                   	nop
f0107584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107588:	89 f8                	mov    %edi,%eax
f010758a:	f7 f1                	div    %ecx
f010758c:	31 d2                	xor    %edx,%edx
f010758e:	83 c4 0c             	add    $0xc,%esp
f0107591:	5e                   	pop    %esi
f0107592:	5f                   	pop    %edi
f0107593:	5d                   	pop    %ebp
f0107594:	c3                   	ret    
f0107595:	8d 76 00             	lea    0x0(%esi),%esi
f0107598:	89 e9                	mov    %ebp,%ecx
f010759a:	8b 3c 24             	mov    (%esp),%edi
f010759d:	d3 e0                	shl    %cl,%eax
f010759f:	89 c6                	mov    %eax,%esi
f01075a1:	b8 20 00 00 00       	mov    $0x20,%eax
f01075a6:	29 e8                	sub    %ebp,%eax
f01075a8:	89 c1                	mov    %eax,%ecx
f01075aa:	d3 ef                	shr    %cl,%edi
f01075ac:	89 e9                	mov    %ebp,%ecx
f01075ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01075b2:	8b 3c 24             	mov    (%esp),%edi
f01075b5:	09 74 24 08          	or     %esi,0x8(%esp)
f01075b9:	89 d6                	mov    %edx,%esi
f01075bb:	d3 e7                	shl    %cl,%edi
f01075bd:	89 c1                	mov    %eax,%ecx
f01075bf:	89 3c 24             	mov    %edi,(%esp)
f01075c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01075c6:	d3 ee                	shr    %cl,%esi
f01075c8:	89 e9                	mov    %ebp,%ecx
f01075ca:	d3 e2                	shl    %cl,%edx
f01075cc:	89 c1                	mov    %eax,%ecx
f01075ce:	d3 ef                	shr    %cl,%edi
f01075d0:	09 d7                	or     %edx,%edi
f01075d2:	89 f2                	mov    %esi,%edx
f01075d4:	89 f8                	mov    %edi,%eax
f01075d6:	f7 74 24 08          	divl   0x8(%esp)
f01075da:	89 d6                	mov    %edx,%esi
f01075dc:	89 c7                	mov    %eax,%edi
f01075de:	f7 24 24             	mull   (%esp)
f01075e1:	39 d6                	cmp    %edx,%esi
f01075e3:	89 14 24             	mov    %edx,(%esp)
f01075e6:	72 30                	jb     f0107618 <__udivdi3+0x118>
f01075e8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01075ec:	89 e9                	mov    %ebp,%ecx
f01075ee:	d3 e2                	shl    %cl,%edx
f01075f0:	39 c2                	cmp    %eax,%edx
f01075f2:	73 05                	jae    f01075f9 <__udivdi3+0xf9>
f01075f4:	3b 34 24             	cmp    (%esp),%esi
f01075f7:	74 1f                	je     f0107618 <__udivdi3+0x118>
f01075f9:	89 f8                	mov    %edi,%eax
f01075fb:	31 d2                	xor    %edx,%edx
f01075fd:	e9 7a ff ff ff       	jmp    f010757c <__udivdi3+0x7c>
f0107602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107608:	31 d2                	xor    %edx,%edx
f010760a:	b8 01 00 00 00       	mov    $0x1,%eax
f010760f:	e9 68 ff ff ff       	jmp    f010757c <__udivdi3+0x7c>
f0107614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107618:	8d 47 ff             	lea    -0x1(%edi),%eax
f010761b:	31 d2                	xor    %edx,%edx
f010761d:	83 c4 0c             	add    $0xc,%esp
f0107620:	5e                   	pop    %esi
f0107621:	5f                   	pop    %edi
f0107622:	5d                   	pop    %ebp
f0107623:	c3                   	ret    
f0107624:	66 90                	xchg   %ax,%ax
f0107626:	66 90                	xchg   %ax,%ax
f0107628:	66 90                	xchg   %ax,%ax
f010762a:	66 90                	xchg   %ax,%ax
f010762c:	66 90                	xchg   %ax,%ax
f010762e:	66 90                	xchg   %ax,%ax

f0107630 <__umoddi3>:
f0107630:	55                   	push   %ebp
f0107631:	57                   	push   %edi
f0107632:	56                   	push   %esi
f0107633:	83 ec 14             	sub    $0x14,%esp
f0107636:	8b 44 24 28          	mov    0x28(%esp),%eax
f010763a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010763e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0107642:	89 c7                	mov    %eax,%edi
f0107644:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107648:	8b 44 24 30          	mov    0x30(%esp),%eax
f010764c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0107650:	89 34 24             	mov    %esi,(%esp)
f0107653:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107657:	85 c0                	test   %eax,%eax
f0107659:	89 c2                	mov    %eax,%edx
f010765b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010765f:	75 17                	jne    f0107678 <__umoddi3+0x48>
f0107661:	39 fe                	cmp    %edi,%esi
f0107663:	76 4b                	jbe    f01076b0 <__umoddi3+0x80>
f0107665:	89 c8                	mov    %ecx,%eax
f0107667:	89 fa                	mov    %edi,%edx
f0107669:	f7 f6                	div    %esi
f010766b:	89 d0                	mov    %edx,%eax
f010766d:	31 d2                	xor    %edx,%edx
f010766f:	83 c4 14             	add    $0x14,%esp
f0107672:	5e                   	pop    %esi
f0107673:	5f                   	pop    %edi
f0107674:	5d                   	pop    %ebp
f0107675:	c3                   	ret    
f0107676:	66 90                	xchg   %ax,%ax
f0107678:	39 f8                	cmp    %edi,%eax
f010767a:	77 54                	ja     f01076d0 <__umoddi3+0xa0>
f010767c:	0f bd e8             	bsr    %eax,%ebp
f010767f:	83 f5 1f             	xor    $0x1f,%ebp
f0107682:	75 5c                	jne    f01076e0 <__umoddi3+0xb0>
f0107684:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0107688:	39 3c 24             	cmp    %edi,(%esp)
f010768b:	0f 87 e7 00 00 00    	ja     f0107778 <__umoddi3+0x148>
f0107691:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0107695:	29 f1                	sub    %esi,%ecx
f0107697:	19 c7                	sbb    %eax,%edi
f0107699:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010769d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01076a1:	8b 44 24 08          	mov    0x8(%esp),%eax
f01076a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01076a9:	83 c4 14             	add    $0x14,%esp
f01076ac:	5e                   	pop    %esi
f01076ad:	5f                   	pop    %edi
f01076ae:	5d                   	pop    %ebp
f01076af:	c3                   	ret    
f01076b0:	85 f6                	test   %esi,%esi
f01076b2:	89 f5                	mov    %esi,%ebp
f01076b4:	75 0b                	jne    f01076c1 <__umoddi3+0x91>
f01076b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01076bb:	31 d2                	xor    %edx,%edx
f01076bd:	f7 f6                	div    %esi
f01076bf:	89 c5                	mov    %eax,%ebp
f01076c1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01076c5:	31 d2                	xor    %edx,%edx
f01076c7:	f7 f5                	div    %ebp
f01076c9:	89 c8                	mov    %ecx,%eax
f01076cb:	f7 f5                	div    %ebp
f01076cd:	eb 9c                	jmp    f010766b <__umoddi3+0x3b>
f01076cf:	90                   	nop
f01076d0:	89 c8                	mov    %ecx,%eax
f01076d2:	89 fa                	mov    %edi,%edx
f01076d4:	83 c4 14             	add    $0x14,%esp
f01076d7:	5e                   	pop    %esi
f01076d8:	5f                   	pop    %edi
f01076d9:	5d                   	pop    %ebp
f01076da:	c3                   	ret    
f01076db:	90                   	nop
f01076dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01076e0:	8b 04 24             	mov    (%esp),%eax
f01076e3:	be 20 00 00 00       	mov    $0x20,%esi
f01076e8:	89 e9                	mov    %ebp,%ecx
f01076ea:	29 ee                	sub    %ebp,%esi
f01076ec:	d3 e2                	shl    %cl,%edx
f01076ee:	89 f1                	mov    %esi,%ecx
f01076f0:	d3 e8                	shr    %cl,%eax
f01076f2:	89 e9                	mov    %ebp,%ecx
f01076f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01076f8:	8b 04 24             	mov    (%esp),%eax
f01076fb:	09 54 24 04          	or     %edx,0x4(%esp)
f01076ff:	89 fa                	mov    %edi,%edx
f0107701:	d3 e0                	shl    %cl,%eax
f0107703:	89 f1                	mov    %esi,%ecx
f0107705:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107709:	8b 44 24 10          	mov    0x10(%esp),%eax
f010770d:	d3 ea                	shr    %cl,%edx
f010770f:	89 e9                	mov    %ebp,%ecx
f0107711:	d3 e7                	shl    %cl,%edi
f0107713:	89 f1                	mov    %esi,%ecx
f0107715:	d3 e8                	shr    %cl,%eax
f0107717:	89 e9                	mov    %ebp,%ecx
f0107719:	09 f8                	or     %edi,%eax
f010771b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010771f:	f7 74 24 04          	divl   0x4(%esp)
f0107723:	d3 e7                	shl    %cl,%edi
f0107725:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107729:	89 d7                	mov    %edx,%edi
f010772b:	f7 64 24 08          	mull   0x8(%esp)
f010772f:	39 d7                	cmp    %edx,%edi
f0107731:	89 c1                	mov    %eax,%ecx
f0107733:	89 14 24             	mov    %edx,(%esp)
f0107736:	72 2c                	jb     f0107764 <__umoddi3+0x134>
f0107738:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010773c:	72 22                	jb     f0107760 <__umoddi3+0x130>
f010773e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0107742:	29 c8                	sub    %ecx,%eax
f0107744:	19 d7                	sbb    %edx,%edi
f0107746:	89 e9                	mov    %ebp,%ecx
f0107748:	89 fa                	mov    %edi,%edx
f010774a:	d3 e8                	shr    %cl,%eax
f010774c:	89 f1                	mov    %esi,%ecx
f010774e:	d3 e2                	shl    %cl,%edx
f0107750:	89 e9                	mov    %ebp,%ecx
f0107752:	d3 ef                	shr    %cl,%edi
f0107754:	09 d0                	or     %edx,%eax
f0107756:	89 fa                	mov    %edi,%edx
f0107758:	83 c4 14             	add    $0x14,%esp
f010775b:	5e                   	pop    %esi
f010775c:	5f                   	pop    %edi
f010775d:	5d                   	pop    %ebp
f010775e:	c3                   	ret    
f010775f:	90                   	nop
f0107760:	39 d7                	cmp    %edx,%edi
f0107762:	75 da                	jne    f010773e <__umoddi3+0x10e>
f0107764:	8b 14 24             	mov    (%esp),%edx
f0107767:	89 c1                	mov    %eax,%ecx
f0107769:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010776d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0107771:	eb cb                	jmp    f010773e <__umoddi3+0x10e>
f0107773:	90                   	nop
f0107774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107778:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010777c:	0f 82 0f ff ff ff    	jb     f0107691 <__umoddi3+0x61>
f0107782:	e9 1a ff ff ff       	jmp    f01076a1 <__umoddi3+0x71>
