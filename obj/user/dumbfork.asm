
obj/user/dumbfork:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1d 02 00 00       	call   80024e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80004e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800055:	00 
  800056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80005a:	89 34 24             	mov    %esi,(%esp)
  80005d:	e8 81 12 00 00       	call   8012e3 <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 a0 17 80 	movl   $0x8017a0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  800081:	e8 24 02 00 00       	call   8002aa <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 8d 12 00 00       	call   801337 <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 c3 17 80 	movl   $0x8017c3,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  8000c9:	e8 dc 01 00 00       	call   8002aa <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 7e 0f 00 00       	call   801064 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 90 12 00 00       	call   80138a <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 d4 17 80 	movl   $0x8017d4,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  800119:	e8 8c 01 00 00       	call   8002aa <_panic>
}
  80011e:	83 c4 20             	add    $0x20,%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <dumbfork>:

envid_t
dumbfork(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80012d:	b8 07 00 00 00       	mov    $0x7,%eax
  800132:	cd 30                	int    $0x30
  800134:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	79 20                	jns    80015a <dumbfork+0x35>
		panic("sys_exofork: %e", envid);
  80013a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013e:	c7 44 24 08 e7 17 80 	movl   $0x8017e7,0x8(%esp)
  800145:	00 
  800146:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014d:	00 
  80014e:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  800155:	e8 50 01 00 00       	call   8002aa <_panic>
  80015a:	89 c3                	mov    %eax,%ebx
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 1e                	jne    80017e <dumbfork+0x59>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 40 11 00 00       	call   8012a5 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800177:	b8 00 00 00 00       	mov    $0x0,%eax
  80017c:	eb 71                	jmp    8001ef <dumbfork+0xca>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017e:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800185:	eb 13                	jmp    80019a <dumbfork+0x75>
		duppage(envid, addr);
  800187:	89 54 24 04          	mov    %edx,0x4(%esp)
  80018b:	89 1c 24             	mov    %ebx,(%esp)
  80018e:	e8 ad fe ff ff       	call   800040 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800193:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80019a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80019d:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  8001a3:	72 e2                	jb     800187 <dumbfork+0x62>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	89 34 24             	mov    %esi,(%esp)
  8001b4:	e8 87 fe ff ff       	call   800040 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001c0:	00 
  8001c1:	89 34 24             	mov    %esi,(%esp)
  8001c4:	e8 14 12 00 00       	call   8013dd <sys_env_set_status>
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	79 20                	jns    8001ed <dumbfork+0xc8>
		panic("sys_env_set_status: %e", r);
  8001cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d1:	c7 44 24 08 f7 17 80 	movl   $0x8017f7,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e0:	00 
  8001e1:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  8001e8:	e8 bd 00 00 00       	call   8002aa <_panic>

	return envid;
  8001ed:	89 f0                	mov    %esi,%eax
}
  8001ef:	83 c4 20             	add    $0x20,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001fe:	e8 22 ff ff ff       	call   800125 <dumbfork>
  800203:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020a:	eb 28                	jmp    800234 <umain+0x3e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020c:	b8 15 18 80 00       	mov    $0x801815,%eax
  800211:	eb 05                	jmp    800218 <umain+0x22>
  800213:	b8 0e 18 80 00       	mov    $0x80180e,%eax
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800220:	c7 04 24 1b 18 80 00 	movl   $0x80181b,(%esp)
  800227:	e8 77 01 00 00       	call   8003a3 <cprintf>
		sys_yield();
  80022c:	e8 93 10 00 00       	call   8012c4 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800231:	83 c3 01             	add    $0x1,%ebx
  800234:	85 f6                	test   %esi,%esi
  800236:	75 0a                	jne    800242 <umain+0x4c>
  800238:	83 fb 13             	cmp    $0x13,%ebx
  80023b:	7e cf                	jle    80020c <umain+0x16>
  80023d:	8d 76 00             	lea    0x0(%esi),%esi
  800240:	eb 05                	jmp    800247 <umain+0x51>
  800242:	83 fb 09             	cmp    $0x9,%ebx
  800245:	7e cc                	jle    800213 <umain+0x1d>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 10             	sub    $0x10,%esp
  800256:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800259:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80025c:	e8 44 10 00 00       	call   8012a5 <sys_getenvid>
  800261:	25 ff 03 00 00       	and    $0x3ff,%eax
  800266:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800269:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80026e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800273:	85 db                	test   %ebx,%ebx
  800275:	7e 07                	jle    80027e <libmain+0x30>
		binaryname = argv[0];
  800277:	8b 06                	mov    (%esi),%eax
  800279:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80027e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800282:	89 1c 24             	mov    %ebx,(%esp)
  800285:	e8 6c ff ff ff       	call   8001f6 <umain>

	// exit gracefully
	exit();
  80028a:	e8 07 00 00 00       	call   800296 <exit>
}
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80029c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a3:	e8 ab 0f 00 00       	call   801253 <sys_env_destroy>
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002bb:	e8 e5 0f 00 00       	call   8012a5 <sys_getenvid>
  8002c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ce:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d6:	c7 04 24 38 18 80 00 	movl   $0x801838,(%esp)
  8002dd:	e8 c1 00 00 00       	call   8003a3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e9:	89 04 24             	mov    %eax,(%esp)
  8002ec:	e8 51 00 00 00       	call   800342 <vcprintf>
	cprintf("\n");
  8002f1:	c7 04 24 2b 18 80 00 	movl   $0x80182b,(%esp)
  8002f8:	e8 a6 00 00 00       	call   8003a3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002fd:	cc                   	int3   
  8002fe:	eb fd                	jmp    8002fd <_panic+0x53>

00800300 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	53                   	push   %ebx
  800304:	83 ec 14             	sub    $0x14,%esp
  800307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030a:	8b 13                	mov    (%ebx),%edx
  80030c:	8d 42 01             	lea    0x1(%edx),%eax
  80030f:	89 03                	mov    %eax,(%ebx)
  800311:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800314:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800318:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031d:	75 19                	jne    800338 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80031f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800326:	00 
  800327:	8d 43 08             	lea    0x8(%ebx),%eax
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	e8 e4 0e 00 00       	call   801216 <sys_cputs>
		b->idx = 0;
  800332:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800338:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80033c:	83 c4 14             	add    $0x14,%esp
  80033f:	5b                   	pop    %ebx
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80034b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800352:	00 00 00 
	b.cnt = 0;
  800355:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80035c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80035f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800362:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800366:	8b 45 08             	mov    0x8(%ebp),%eax
  800369:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800373:	89 44 24 04          	mov    %eax,0x4(%esp)
  800377:	c7 04 24 00 03 80 00 	movl   $0x800300,(%esp)
  80037e:	e8 ac 02 00 00       	call   80062f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800383:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	e8 7b 0e 00 00       	call   801216 <sys_cputs>

	return b.cnt;
}
  80039b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003a9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	e8 87 ff ff ff       	call   800342 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    
  8003bd:	66 90                	xchg   %ax,%ax
  8003bf:	90                   	nop

008003c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	57                   	push   %edi
  8003c4:	56                   	push   %esi
  8003c5:	53                   	push   %ebx
  8003c6:	83 ec 3c             	sub    $0x3c,%esp
  8003c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cc:	89 d7                	mov    %edx,%edi
  8003ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d7:	89 c3                	mov    %eax,%ebx
  8003d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003ed:	39 d9                	cmp    %ebx,%ecx
  8003ef:	72 05                	jb     8003f6 <printnum+0x36>
  8003f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003f4:	77 69                	ja     80045f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003fd:	83 ee 01             	sub    $0x1,%esi
  800400:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800404:	89 44 24 08          	mov    %eax,0x8(%esp)
  800408:	8b 44 24 08          	mov    0x8(%esp),%eax
  80040c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800410:	89 c3                	mov    %eax,%ebx
  800412:	89 d6                	mov    %edx,%esi
  800414:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800417:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80041a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80041e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800422:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800425:	89 04 24             	mov    %eax,(%esp)
  800428:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80042b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042f:	e8 cc 10 00 00       	call   801500 <__udivdi3>
  800434:	89 d9                	mov    %ebx,%ecx
  800436:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80043a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80043e:	89 04 24             	mov    %eax,(%esp)
  800441:	89 54 24 04          	mov    %edx,0x4(%esp)
  800445:	89 fa                	mov    %edi,%edx
  800447:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80044a:	e8 71 ff ff ff       	call   8003c0 <printnum>
  80044f:	eb 1b                	jmp    80046c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800451:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800455:	8b 45 18             	mov    0x18(%ebp),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	ff d3                	call   *%ebx
  80045d:	eb 03                	jmp    800462 <printnum+0xa2>
  80045f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800462:	83 ee 01             	sub    $0x1,%esi
  800465:	85 f6                	test   %esi,%esi
  800467:	7f e8                	jg     800451 <printnum+0x91>
  800469:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800470:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800474:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800477:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80047a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800482:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800485:	89 04 24             	mov    %eax,(%esp)
  800488:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80048b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048f:	e8 9c 11 00 00       	call   801630 <__umoddi3>
  800494:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800498:	0f be 80 5c 18 80 00 	movsbl 0x80185c(%eax),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a5:	ff d0                	call   *%eax
}
  8004a7:	83 c4 3c             	add    $0x3c,%esp
  8004aa:	5b                   	pop    %ebx
  8004ab:	5e                   	pop    %esi
  8004ac:	5f                   	pop    %edi
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    

008004af <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	57                   	push   %edi
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
  8004b5:	83 ec 3c             	sub    $0x3c,%esp
  8004b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004bb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004be:	89 cf                	mov    %ecx,%edi
  8004c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c9:	89 c3                	mov    %eax,%ebx
  8004cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004dc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004df:	39 d9                	cmp    %ebx,%ecx
  8004e1:	72 13                	jb     8004f6 <cprintnum+0x47>
  8004e3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8004e6:	76 0e                	jbe    8004f6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8004e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004eb:	0b 45 18             	or     0x18(%ebp),%eax
  8004ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f4:	eb 6a                	jmp    800560 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8004f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004fd:	83 ee 01             	sub    $0x1,%esi
  800500:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800504:	89 44 24 08          	mov    %eax,0x8(%esp)
  800508:	8b 44 24 08          	mov    0x8(%esp),%eax
  80050c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800510:	89 c3                	mov    %eax,%ebx
  800512:	89 d6                	mov    %edx,%esi
  800514:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800517:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80051a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80051e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800522:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800525:	89 04 24             	mov    %eax,(%esp)
  800528:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052f:	e8 cc 0f 00 00       	call   801500 <__udivdi3>
  800534:	89 d9                	mov    %ebx,%ecx
  800536:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80053a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	89 54 24 04          	mov    %edx,0x4(%esp)
  800545:	89 f9                	mov    %edi,%ecx
  800547:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80054a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054d:	e8 5d ff ff ff       	call   8004af <cprintnum>
  800552:	eb 16                	jmp    80056a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800554:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800560:	83 ee 01             	sub    $0x1,%esi
  800563:	85 f6                	test   %esi,%esi
  800565:	7f ed                	jg     800554 <cprintnum+0xa5>
  800567:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80056a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800572:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800575:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800578:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800580:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800583:	89 04 24             	mov    %eax,(%esp)
  800586:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058d:	e8 9e 10 00 00       	call   801630 <__umoddi3>
  800592:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800596:	0f be 80 5c 18 80 00 	movsbl 0x80185c(%eax),%eax
  80059d:	0b 45 dc             	or     -0x24(%ebp),%eax
  8005a0:	89 04 24             	mov    %eax,(%esp)
  8005a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a6:	ff d0                	call   *%eax
}
  8005a8:	83 c4 3c             	add    $0x3c,%esp
  8005ab:	5b                   	pop    %ebx
  8005ac:	5e                   	pop    %esi
  8005ad:	5f                   	pop    %edi
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005b3:	83 fa 01             	cmp    $0x1,%edx
  8005b6:	7e 0e                	jle    8005c6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005bd:	89 08                	mov    %ecx,(%eax)
  8005bf:	8b 02                	mov    (%edx),%eax
  8005c1:	8b 52 04             	mov    0x4(%edx),%edx
  8005c4:	eb 22                	jmp    8005e8 <getuint+0x38>
	else if (lflag)
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 10                	je     8005da <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005ca:	8b 10                	mov    (%eax),%edx
  8005cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005cf:	89 08                	mov    %ecx,(%eax)
  8005d1:	8b 02                	mov    (%edx),%eax
  8005d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d8:	eb 0e                	jmp    8005e8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005df:	89 08                	mov    %ecx,(%eax)
  8005e1:	8b 02                	mov    (%edx),%eax
  8005e3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005e8:	5d                   	pop    %ebp
  8005e9:	c3                   	ret    

008005ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005ea:	55                   	push   %ebp
  8005eb:	89 e5                	mov    %esp,%ebp
  8005ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8005f9:	73 0a                	jae    800605 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005fe:	89 08                	mov    %ecx,(%eax)
  800600:	8b 45 08             	mov    0x8(%ebp),%eax
  800603:	88 02                	mov    %al,(%edx)
}
  800605:	5d                   	pop    %ebp
  800606:	c3                   	ret    

00800607 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800610:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800614:	8b 45 10             	mov    0x10(%ebp),%eax
  800617:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800622:	8b 45 08             	mov    0x8(%ebp),%eax
  800625:	89 04 24             	mov    %eax,(%esp)
  800628:	e8 02 00 00 00       	call   80062f <vprintfmt>
	va_end(ap);
}
  80062d:	c9                   	leave  
  80062e:	c3                   	ret    

0080062f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	57                   	push   %edi
  800633:	56                   	push   %esi
  800634:	53                   	push   %ebx
  800635:	83 ec 3c             	sub    $0x3c,%esp
  800638:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80063b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80063e:	eb 14                	jmp    800654 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800640:	85 c0                	test   %eax,%eax
  800642:	0f 84 b3 03 00 00    	je     8009fb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800648:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064c:	89 04 24             	mov    %eax,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800652:	89 f3                	mov    %esi,%ebx
  800654:	8d 73 01             	lea    0x1(%ebx),%esi
  800657:	0f b6 03             	movzbl (%ebx),%eax
  80065a:	83 f8 25             	cmp    $0x25,%eax
  80065d:	75 e1                	jne    800640 <vprintfmt+0x11>
  80065f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800663:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80066a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800671:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800678:	ba 00 00 00 00       	mov    $0x0,%edx
  80067d:	eb 1d                	jmp    80069c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800681:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800685:	eb 15                	jmp    80069c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800689:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80068d:	eb 0d                	jmp    80069c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80068f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800692:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800695:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80069f:	0f b6 0e             	movzbl (%esi),%ecx
  8006a2:	0f b6 c1             	movzbl %cl,%eax
  8006a5:	83 e9 23             	sub    $0x23,%ecx
  8006a8:	80 f9 55             	cmp    $0x55,%cl
  8006ab:	0f 87 2a 03 00 00    	ja     8009db <vprintfmt+0x3ac>
  8006b1:	0f b6 c9             	movzbl %cl,%ecx
  8006b4:	ff 24 8d 20 19 80 00 	jmp    *0x801920(,%ecx,4)
  8006bb:	89 de                	mov    %ebx,%esi
  8006bd:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006c2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006c5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006c9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006cc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006cf:	83 fb 09             	cmp    $0x9,%ebx
  8006d2:	77 36                	ja     80070a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d7:	eb e9                	jmp    8006c2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8006df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006e9:	eb 22                	jmp    80070d <vprintfmt+0xde>
  8006eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ee:	85 c9                	test   %ecx,%ecx
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f5:	0f 49 c1             	cmovns %ecx,%eax
  8006f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fb:	89 de                	mov    %ebx,%esi
  8006fd:	eb 9d                	jmp    80069c <vprintfmt+0x6d>
  8006ff:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800701:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800708:	eb 92                	jmp    80069c <vprintfmt+0x6d>
  80070a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80070d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800711:	79 89                	jns    80069c <vprintfmt+0x6d>
  800713:	e9 77 ff ff ff       	jmp    80068f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800718:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80071d:	e9 7a ff ff ff       	jmp    80069c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8d 50 04             	lea    0x4(%eax),%edx
  800728:	89 55 14             	mov    %edx,0x14(%ebp)
  80072b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	89 04 24             	mov    %eax,(%esp)
  800734:	ff 55 08             	call   *0x8(%ebp)
			break;
  800737:	e9 18 ff ff ff       	jmp    800654 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8d 50 04             	lea    0x4(%eax),%edx
  800742:	89 55 14             	mov    %edx,0x14(%ebp)
  800745:	8b 00                	mov    (%eax),%eax
  800747:	99                   	cltd   
  800748:	31 d0                	xor    %edx,%eax
  80074a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80074c:	83 f8 09             	cmp    $0x9,%eax
  80074f:	7f 0b                	jg     80075c <vprintfmt+0x12d>
  800751:	8b 14 85 e0 1b 80 00 	mov    0x801be0(,%eax,4),%edx
  800758:	85 d2                	test   %edx,%edx
  80075a:	75 20                	jne    80077c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80075c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800760:	c7 44 24 08 74 18 80 	movl   $0x801874,0x8(%esp)
  800767:	00 
  800768:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	e8 90 fe ff ff       	call   800607 <printfmt>
  800777:	e9 d8 fe ff ff       	jmp    800654 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80077c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800780:	c7 44 24 08 7d 18 80 	movl   $0x80187d,0x8(%esp)
  800787:	00 
  800788:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	89 04 24             	mov    %eax,(%esp)
  800792:	e8 70 fe ff ff       	call   800607 <printfmt>
  800797:	e9 b8 fe ff ff       	jmp    800654 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80079f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 50 04             	lea    0x4(%eax),%edx
  8007ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ae:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8007b0:	85 f6                	test   %esi,%esi
  8007b2:	b8 6d 18 80 00       	mov    $0x80186d,%eax
  8007b7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007ba:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007be:	0f 84 97 00 00 00    	je     80085b <vprintfmt+0x22c>
  8007c4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007c8:	0f 8e 9b 00 00 00    	jle    800869 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007d2:	89 34 24             	mov    %esi,(%esp)
  8007d5:	e8 ce 06 00 00       	call   800ea8 <strnlen>
  8007da:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007dd:	29 c2                	sub    %eax,%edx
  8007df:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8007e2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007e9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ef:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007f2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f4:	eb 0f                	jmp    800805 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8007f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007fd:	89 04 24             	mov    %eax,(%esp)
  800800:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800802:	83 eb 01             	sub    $0x1,%ebx
  800805:	85 db                	test   %ebx,%ebx
  800807:	7f ed                	jg     8007f6 <vprintfmt+0x1c7>
  800809:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80080c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80080f:	85 d2                	test   %edx,%edx
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	0f 49 c2             	cmovns %edx,%eax
  800819:	29 c2                	sub    %eax,%edx
  80081b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80081e:	89 d7                	mov    %edx,%edi
  800820:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800823:	eb 50                	jmp    800875 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800825:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800829:	74 1e                	je     800849 <vprintfmt+0x21a>
  80082b:	0f be d2             	movsbl %dl,%edx
  80082e:	83 ea 20             	sub    $0x20,%edx
  800831:	83 fa 5e             	cmp    $0x5e,%edx
  800834:	76 13                	jbe    800849 <vprintfmt+0x21a>
					putch('?', putdat);
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
  800839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800844:	ff 55 08             	call   *0x8(%ebp)
  800847:	eb 0d                	jmp    800856 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800850:	89 04 24             	mov    %eax,(%esp)
  800853:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800856:	83 ef 01             	sub    $0x1,%edi
  800859:	eb 1a                	jmp    800875 <vprintfmt+0x246>
  80085b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80085e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800861:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800864:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800867:	eb 0c                	jmp    800875 <vprintfmt+0x246>
  800869:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80086c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80086f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800872:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800875:	83 c6 01             	add    $0x1,%esi
  800878:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80087c:	0f be c2             	movsbl %dl,%eax
  80087f:	85 c0                	test   %eax,%eax
  800881:	74 27                	je     8008aa <vprintfmt+0x27b>
  800883:	85 db                	test   %ebx,%ebx
  800885:	78 9e                	js     800825 <vprintfmt+0x1f6>
  800887:	83 eb 01             	sub    $0x1,%ebx
  80088a:	79 99                	jns    800825 <vprintfmt+0x1f6>
  80088c:	89 f8                	mov    %edi,%eax
  80088e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800891:	8b 75 08             	mov    0x8(%ebp),%esi
  800894:	89 c3                	mov    %eax,%ebx
  800896:	eb 1a                	jmp    8008b2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800898:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008a5:	83 eb 01             	sub    $0x1,%ebx
  8008a8:	eb 08                	jmp    8008b2 <vprintfmt+0x283>
  8008aa:	89 fb                	mov    %edi,%ebx
  8008ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8008af:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008b2:	85 db                	test   %ebx,%ebx
  8008b4:	7f e2                	jg     800898 <vprintfmt+0x269>
  8008b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8008b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008bc:	e9 93 fd ff ff       	jmp    800654 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c1:	83 fa 01             	cmp    $0x1,%edx
  8008c4:	7e 16                	jle    8008dc <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8008c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c9:	8d 50 08             	lea    0x8(%eax),%edx
  8008cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cf:	8b 50 04             	mov    0x4(%eax),%edx
  8008d2:	8b 00                	mov    (%eax),%eax
  8008d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008da:	eb 32                	jmp    80090e <vprintfmt+0x2df>
	else if (lflag)
  8008dc:	85 d2                	test   %edx,%edx
  8008de:	74 18                	je     8008f8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 50 04             	lea    0x4(%eax),%edx
  8008e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e9:	8b 30                	mov    (%eax),%esi
  8008eb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008ee:	89 f0                	mov    %esi,%eax
  8008f0:	c1 f8 1f             	sar    $0x1f,%eax
  8008f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f6:	eb 16                	jmp    80090e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8d 50 04             	lea    0x4(%eax),%edx
  8008fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800901:	8b 30                	mov    (%eax),%esi
  800903:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800906:	89 f0                	mov    %esi,%eax
  800908:	c1 f8 1f             	sar    $0x1f,%eax
  80090b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80090e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800911:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800914:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800919:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80091d:	0f 89 80 00 00 00    	jns    8009a3 <vprintfmt+0x374>
				putch('-', putdat);
  800923:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800927:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80092e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800931:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800934:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800937:	f7 d8                	neg    %eax
  800939:	83 d2 00             	adc    $0x0,%edx
  80093c:	f7 da                	neg    %edx
			}
			base = 10;
  80093e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800943:	eb 5e                	jmp    8009a3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800945:	8d 45 14             	lea    0x14(%ebp),%eax
  800948:	e8 63 fc ff ff       	call   8005b0 <getuint>
			base = 10;
  80094d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800952:	eb 4f                	jmp    8009a3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800954:	8d 45 14             	lea    0x14(%ebp),%eax
  800957:	e8 54 fc ff ff       	call   8005b0 <getuint>
			base = 8 ;
  80095c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800961:	eb 40                	jmp    8009a3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800963:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800967:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80096e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800971:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800975:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80097c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80097f:	8b 45 14             	mov    0x14(%ebp),%eax
  800982:	8d 50 04             	lea    0x4(%eax),%edx
  800985:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800988:	8b 00                	mov    (%eax),%eax
  80098a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80098f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800994:	eb 0d                	jmp    8009a3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800996:	8d 45 14             	lea    0x14(%ebp),%eax
  800999:	e8 12 fc ff ff       	call   8005b0 <getuint>
			base = 16;
  80099e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009a3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8009a7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8009ab:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8009b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009b6:	89 04 24             	mov    %eax,(%esp)
  8009b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009bd:	89 fa                	mov    %edi,%edx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	e8 f9 f9 ff ff       	call   8003c0 <printnum>
			break;
  8009c7:	e9 88 fc ff ff       	jmp    800654 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009d0:	89 04 24             	mov    %eax,(%esp)
  8009d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009d6:	e9 79 fc ff ff       	jmp    800654 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009e6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e9:	89 f3                	mov    %esi,%ebx
  8009eb:	eb 03                	jmp    8009f0 <vprintfmt+0x3c1>
  8009ed:	83 eb 01             	sub    $0x1,%ebx
  8009f0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009f4:	75 f7                	jne    8009ed <vprintfmt+0x3be>
  8009f6:	e9 59 fc ff ff       	jmp    800654 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8009fb:	83 c4 3c             	add    $0x3c,%esp
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	83 ec 3c             	sub    $0x3c,%esp
  800a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  800a0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a12:	8d 50 04             	lea    0x4(%eax),%edx
  800a15:	89 55 14             	mov    %edx,0x14(%ebp)
  800a18:	8b 00                	mov    (%eax),%eax
  800a1a:	c1 e0 08             	shl    $0x8,%eax
  800a1d:	0f b7 c0             	movzwl %ax,%eax
  800a20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800a23:	83 c8 25             	or     $0x25,%eax
  800a26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800a29:	eb 1a                	jmp    800a45 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a2b:	85 c0                	test   %eax,%eax
  800a2d:	0f 84 a9 03 00 00    	je     800ddc <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a43:	89 fb                	mov    %edi,%ebx
  800a45:	8d 7b 01             	lea    0x1(%ebx),%edi
  800a48:	0f b6 03             	movzbl (%ebx),%eax
  800a4b:	83 f8 25             	cmp    $0x25,%eax
  800a4e:	75 db                	jne    800a2b <cvprintfmt+0x28>
  800a50:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800a54:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800a5b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800a60:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	eb 18                	jmp    800a86 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a70:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800a74:	eb 10                	jmp    800a86 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a78:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800a7c:	eb 08                	jmp    800a86 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a7e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800a81:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a86:	8d 5f 01             	lea    0x1(%edi),%ebx
  800a89:	0f b6 0f             	movzbl (%edi),%ecx
  800a8c:	0f b6 c1             	movzbl %cl,%eax
  800a8f:	83 e9 23             	sub    $0x23,%ecx
  800a92:	80 f9 55             	cmp    $0x55,%cl
  800a95:	0f 87 1f 03 00 00    	ja     800dba <cvprintfmt+0x3b7>
  800a9b:	0f b6 c9             	movzbl %cl,%ecx
  800a9e:	ff 24 8d 78 1a 80 00 	jmp    *0x801a78(,%ecx,4)
  800aa5:	89 df                	mov    %ebx,%edi
  800aa7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800aac:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  800aaf:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800ab3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800ab6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800ab9:	83 f9 09             	cmp    $0x9,%ecx
  800abc:	77 33                	ja     800af1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800abe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ac1:	eb e9                	jmp    800aac <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ac3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac6:	8d 48 04             	lea    0x4(%eax),%ecx
  800ac9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800acc:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ace:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ad0:	eb 1f                	jmp    800af1 <cvprintfmt+0xee>
  800ad2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ad5:	85 ff                	test   %edi,%edi
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  800adc:	0f 49 c7             	cmovns %edi,%eax
  800adf:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ae2:	89 df                	mov    %ebx,%edi
  800ae4:	eb a0                	jmp    800a86 <cvprintfmt+0x83>
  800ae6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800ae8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800aef:	eb 95                	jmp    800a86 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800af1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800af5:	79 8f                	jns    800a86 <cvprintfmt+0x83>
  800af7:	eb 85                	jmp    800a7e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800af9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afc:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800afe:	66 90                	xchg   %ax,%ax
  800b00:	eb 84                	jmp    800a86 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800b02:	8b 45 14             	mov    0x14(%ebp),%eax
  800b05:	8d 50 04             	lea    0x4(%eax),%edx
  800b08:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b15:	0b 10                	or     (%eax),%edx
  800b17:	89 14 24             	mov    %edx,(%esp)
  800b1a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b1d:	e9 23 ff ff ff       	jmp    800a45 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b22:	8b 45 14             	mov    0x14(%ebp),%eax
  800b25:	8d 50 04             	lea    0x4(%eax),%edx
  800b28:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2b:	8b 00                	mov    (%eax),%eax
  800b2d:	99                   	cltd   
  800b2e:	31 d0                	xor    %edx,%eax
  800b30:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b32:	83 f8 09             	cmp    $0x9,%eax
  800b35:	7f 0b                	jg     800b42 <cvprintfmt+0x13f>
  800b37:	8b 14 85 e0 1b 80 00 	mov    0x801be0(,%eax,4),%edx
  800b3e:	85 d2                	test   %edx,%edx
  800b40:	75 23                	jne    800b65 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800b42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b46:	c7 44 24 08 74 18 80 	movl   $0x801874,0x8(%esp)
  800b4d:	00 
  800b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	e8 a7 fa ff ff       	call   800607 <printfmt>
  800b60:	e9 e0 fe ff ff       	jmp    800a45 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800b65:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b69:	c7 44 24 08 7d 18 80 	movl   $0x80187d,0x8(%esp)
  800b70:	00 
  800b71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7b:	89 04 24             	mov    %eax,(%esp)
  800b7e:	e8 84 fa ff ff       	call   800607 <printfmt>
  800b83:	e9 bd fe ff ff       	jmp    800a45 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b88:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b8b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800b8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b91:	8d 48 04             	lea    0x4(%eax),%ecx
  800b94:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b97:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800b99:	85 ff                	test   %edi,%edi
  800b9b:	b8 6d 18 80 00       	mov    $0x80186d,%eax
  800ba0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800ba3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800ba7:	74 61                	je     800c0a <cvprintfmt+0x207>
  800ba9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800bad:	7e 5b                	jle    800c0a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800baf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bb3:	89 3c 24             	mov    %edi,(%esp)
  800bb6:	e8 ed 02 00 00       	call   800ea8 <strnlen>
  800bbb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800bbe:	29 c2                	sub    %eax,%edx
  800bc0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800bc3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800bc7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800bca:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800bcd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800bd0:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bda:	eb 0f                	jmp    800beb <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be3:	89 3c 24             	mov    %edi,(%esp)
  800be6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800be8:	83 eb 01             	sub    $0x1,%ebx
  800beb:	85 db                	test   %ebx,%ebx
  800bed:	7f ed                	jg     800bdc <cvprintfmt+0x1d9>
  800bef:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800bf2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800bfb:	85 d2                	test   %edx,%edx
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800c02:	0f 49 c2             	cmovns %edx,%eax
  800c05:	29 c2                	sub    %eax,%edx
  800c07:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800c0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0d:	83 c8 3f             	or     $0x3f,%eax
  800c10:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c13:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c16:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c19:	eb 36                	jmp    800c51 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c1b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c1f:	74 1d                	je     800c3e <cvprintfmt+0x23b>
  800c21:	0f be d2             	movsbl %dl,%edx
  800c24:	83 ea 20             	sub    $0x20,%edx
  800c27:	83 fa 5e             	cmp    $0x5e,%edx
  800c2a:	76 12                	jbe    800c3e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c33:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c36:	89 04 24             	mov    %eax,(%esp)
  800c39:	ff 55 08             	call   *0x8(%ebp)
  800c3c:	eb 10                	jmp    800c4e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c41:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c45:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800c48:	89 04 24             	mov    %eax,(%esp)
  800c4b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c4e:	83 eb 01             	sub    $0x1,%ebx
  800c51:	83 c7 01             	add    $0x1,%edi
  800c54:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800c58:	0f be c2             	movsbl %dl,%eax
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	74 27                	je     800c86 <cvprintfmt+0x283>
  800c5f:	85 f6                	test   %esi,%esi
  800c61:	78 b8                	js     800c1b <cvprintfmt+0x218>
  800c63:	83 ee 01             	sub    $0x1,%esi
  800c66:	79 b3                	jns    800c1b <cvprintfmt+0x218>
  800c68:	89 d8                	mov    %ebx,%eax
  800c6a:	8b 75 08             	mov    0x8(%ebp),%esi
  800c6d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c70:	89 c3                	mov    %eax,%ebx
  800c72:	eb 18                	jmp    800c8c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800c74:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c78:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c7f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800c81:	83 eb 01             	sub    $0x1,%ebx
  800c84:	eb 06                	jmp    800c8c <cvprintfmt+0x289>
  800c86:	8b 75 08             	mov    0x8(%ebp),%esi
  800c89:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c8c:	85 db                	test   %ebx,%ebx
  800c8e:	7f e4                	jg     800c74 <cvprintfmt+0x271>
  800c90:	89 75 08             	mov    %esi,0x8(%ebp)
  800c93:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800c96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c99:	e9 a7 fd ff ff       	jmp    800a45 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c9e:	83 fa 01             	cmp    $0x1,%edx
  800ca1:	7e 10                	jle    800cb3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800ca3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca6:	8d 50 08             	lea    0x8(%eax),%edx
  800ca9:	89 55 14             	mov    %edx,0x14(%ebp)
  800cac:	8b 30                	mov    (%eax),%esi
  800cae:	8b 78 04             	mov    0x4(%eax),%edi
  800cb1:	eb 26                	jmp    800cd9 <cvprintfmt+0x2d6>
	else if (lflag)
  800cb3:	85 d2                	test   %edx,%edx
  800cb5:	74 12                	je     800cc9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800cb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cba:	8d 50 04             	lea    0x4(%eax),%edx
  800cbd:	89 55 14             	mov    %edx,0x14(%ebp)
  800cc0:	8b 30                	mov    (%eax),%esi
  800cc2:	89 f7                	mov    %esi,%edi
  800cc4:	c1 ff 1f             	sar    $0x1f,%edi
  800cc7:	eb 10                	jmp    800cd9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800cc9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ccc:	8d 50 04             	lea    0x4(%eax),%edx
  800ccf:	89 55 14             	mov    %edx,0x14(%ebp)
  800cd2:	8b 30                	mov    (%eax),%esi
  800cd4:	89 f7                	mov    %esi,%edi
  800cd6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800cd9:	89 f0                	mov    %esi,%eax
  800cdb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cdd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ce2:	85 ff                	test   %edi,%edi
  800ce4:	0f 89 8e 00 00 00    	jns    800d78 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800cea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cf4:	83 c8 2d             	or     $0x2d,%eax
  800cf7:	89 04 24             	mov    %eax,(%esp)
  800cfa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800cfd:	89 f0                	mov    %esi,%eax
  800cff:	89 fa                	mov    %edi,%edx
  800d01:	f7 d8                	neg    %eax
  800d03:	83 d2 00             	adc    $0x0,%edx
  800d06:	f7 da                	neg    %edx
			}
			base = 10;
  800d08:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800d0d:	eb 69                	jmp    800d78 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800d0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800d12:	e8 99 f8 ff ff       	call   8005b0 <getuint>
			base = 10;
  800d17:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800d1c:	eb 5a                	jmp    800d78 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800d1e:	8d 45 14             	lea    0x14(%ebp),%eax
  800d21:	e8 8a f8 ff ff       	call   8005b0 <getuint>
			base = 8 ;
  800d26:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800d2b:	eb 4b                	jmp    800d78 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d34:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800d37:	89 f0                	mov    %esi,%eax
  800d39:	83 c8 30             	or     $0x30,%eax
  800d3c:	89 04 24             	mov    %eax,(%esp)
  800d3f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d49:	89 f0                	mov    %esi,%eax
  800d4b:	83 c8 78             	or     $0x78,%eax
  800d4e:	89 04 24             	mov    %eax,(%esp)
  800d51:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d54:	8b 45 14             	mov    0x14(%ebp),%eax
  800d57:	8d 50 04             	lea    0x4(%eax),%edx
  800d5a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800d5d:	8b 00                	mov    (%eax),%eax
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d64:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800d69:	eb 0d                	jmp    800d78 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800d6e:	e8 3d f8 ff ff       	call   8005b0 <getuint>
			base = 16;
  800d73:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800d78:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800d7c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d80:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800d83:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d8b:	89 04 24             	mov    %eax,(%esp)
  800d8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d9b:	e8 0f f7 ff ff       	call   8004af <cprintnum>
			break;
  800da0:	e9 a0 fc ff ff       	jmp    800a45 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800da5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dac:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800daf:	89 04 24             	mov    %eax,(%esp)
  800db2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800db5:	e9 8b fc ff ff       	jmp    800a45 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800dc4:	89 04 24             	mov    %eax,(%esp)
  800dc7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800dca:	89 fb                	mov    %edi,%ebx
  800dcc:	eb 03                	jmp    800dd1 <cvprintfmt+0x3ce>
  800dce:	83 eb 01             	sub    $0x1,%ebx
  800dd1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800dd5:	75 f7                	jne    800dce <cvprintfmt+0x3cb>
  800dd7:	e9 69 fc ff ff       	jmp    800a45 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800ddc:	83 c4 3c             	add    $0x3c,%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800dea:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800ded:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800df1:	8b 45 10             	mov    0x10(%ebp),%eax
  800df4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	89 04 24             	mov    %eax,(%esp)
  800e05:	e8 f9 fb ff ff       	call   800a03 <cvprintfmt>
	va_end(ap);
}
  800e0a:	c9                   	leave  
  800e0b:	c3                   	ret    

00800e0c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	83 ec 28             	sub    $0x28,%esp
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e18:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e1b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e1f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	74 30                	je     800e5d <vsnprintf+0x51>
  800e2d:	85 d2                	test   %edx,%edx
  800e2f:	7e 2c                	jle    800e5d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e31:	8b 45 14             	mov    0x14(%ebp),%eax
  800e34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e38:	8b 45 10             	mov    0x10(%ebp),%eax
  800e3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e3f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e46:	c7 04 24 ea 05 80 00 	movl   $0x8005ea,(%esp)
  800e4d:	e8 dd f7 ff ff       	call   80062f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e55:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5b:	eb 05                	jmp    800e62 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e6a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e71:	8b 45 10             	mov    0x10(%ebp),%eax
  800e74:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e82:	89 04 24             	mov    %eax,(%esp)
  800e85:	e8 82 ff ff ff       	call   800e0c <vsnprintf>
	va_end(ap);

	return rc;
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9b:	eb 03                	jmp    800ea0 <strlen+0x10>
		n++;
  800e9d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ea0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ea4:	75 f7                	jne    800e9d <strlen+0xd>
		n++;
	return n;
}
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb6:	eb 03                	jmp    800ebb <strnlen+0x13>
		n++;
  800eb8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ebb:	39 d0                	cmp    %edx,%eax
  800ebd:	74 06                	je     800ec5 <strnlen+0x1d>
  800ebf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ec3:	75 f3                	jne    800eb8 <strnlen+0x10>
		n++;
	return n;
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	53                   	push   %ebx
  800ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ece:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	83 c2 01             	add    $0x1,%edx
  800ed6:	83 c1 01             	add    $0x1,%ecx
  800ed9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800edd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ee0:	84 db                	test   %bl,%bl
  800ee2:	75 ef                	jne    800ed3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ee4:	5b                   	pop    %ebx
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 08             	sub    $0x8,%esp
  800eee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ef1:	89 1c 24             	mov    %ebx,(%esp)
  800ef4:	e8 97 ff ff ff       	call   800e90 <strlen>
	strcpy(dst + len, src);
  800ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f00:	01 d8                	add    %ebx,%eax
  800f02:	89 04 24             	mov    %eax,(%esp)
  800f05:	e8 bd ff ff ff       	call   800ec7 <strcpy>
	return dst;
}
  800f0a:	89 d8                	mov    %ebx,%eax
  800f0c:	83 c4 08             	add    $0x8,%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	56                   	push   %esi
  800f16:	53                   	push   %ebx
  800f17:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	89 f3                	mov    %esi,%ebx
  800f1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	eb 0f                	jmp    800f35 <strncpy+0x23>
		*dst++ = *src;
  800f26:	83 c2 01             	add    $0x1,%edx
  800f29:	0f b6 01             	movzbl (%ecx),%eax
  800f2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f2f:	80 39 01             	cmpb   $0x1,(%ecx)
  800f32:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f35:	39 da                	cmp    %ebx,%edx
  800f37:	75 ed                	jne    800f26 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800f39:	89 f0                	mov    %esi,%eax
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	8b 75 08             	mov    0x8(%ebp),%esi
  800f47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f4d:	89 f0                	mov    %esi,%eax
  800f4f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f53:	85 c9                	test   %ecx,%ecx
  800f55:	75 0b                	jne    800f62 <strlcpy+0x23>
  800f57:	eb 1d                	jmp    800f76 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f59:	83 c0 01             	add    $0x1,%eax
  800f5c:	83 c2 01             	add    $0x1,%edx
  800f5f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f62:	39 d8                	cmp    %ebx,%eax
  800f64:	74 0b                	je     800f71 <strlcpy+0x32>
  800f66:	0f b6 0a             	movzbl (%edx),%ecx
  800f69:	84 c9                	test   %cl,%cl
  800f6b:	75 ec                	jne    800f59 <strlcpy+0x1a>
  800f6d:	89 c2                	mov    %eax,%edx
  800f6f:	eb 02                	jmp    800f73 <strlcpy+0x34>
  800f71:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800f73:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800f76:	29 f0                	sub    %esi,%eax
}
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f85:	eb 06                	jmp    800f8d <strcmp+0x11>
		p++, q++;
  800f87:	83 c1 01             	add    $0x1,%ecx
  800f8a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f8d:	0f b6 01             	movzbl (%ecx),%eax
  800f90:	84 c0                	test   %al,%al
  800f92:	74 04                	je     800f98 <strcmp+0x1c>
  800f94:	3a 02                	cmp    (%edx),%al
  800f96:	74 ef                	je     800f87 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f98:	0f b6 c0             	movzbl %al,%eax
  800f9b:	0f b6 12             	movzbl (%edx),%edx
  800f9e:	29 d0                	sub    %edx,%eax
}
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	53                   	push   %ebx
  800fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fac:	89 c3                	mov    %eax,%ebx
  800fae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800fb1:	eb 06                	jmp    800fb9 <strncmp+0x17>
		n--, p++, q++;
  800fb3:	83 c0 01             	add    $0x1,%eax
  800fb6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800fb9:	39 d8                	cmp    %ebx,%eax
  800fbb:	74 15                	je     800fd2 <strncmp+0x30>
  800fbd:	0f b6 08             	movzbl (%eax),%ecx
  800fc0:	84 c9                	test   %cl,%cl
  800fc2:	74 04                	je     800fc8 <strncmp+0x26>
  800fc4:	3a 0a                	cmp    (%edx),%cl
  800fc6:	74 eb                	je     800fb3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fc8:	0f b6 00             	movzbl (%eax),%eax
  800fcb:	0f b6 12             	movzbl (%edx),%edx
  800fce:	29 d0                	sub    %edx,%eax
  800fd0:	eb 05                	jmp    800fd7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800fd2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800fd7:	5b                   	pop    %ebx
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fe4:	eb 07                	jmp    800fed <strchr+0x13>
		if (*s == c)
  800fe6:	38 ca                	cmp    %cl,%dl
  800fe8:	74 0f                	je     800ff9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800fea:	83 c0 01             	add    $0x1,%eax
  800fed:	0f b6 10             	movzbl (%eax),%edx
  800ff0:	84 d2                	test   %dl,%dl
  800ff2:	75 f2                	jne    800fe6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	8b 45 08             	mov    0x8(%ebp),%eax
  801001:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801005:	eb 07                	jmp    80100e <strfind+0x13>
		if (*s == c)
  801007:	38 ca                	cmp    %cl,%dl
  801009:	74 0a                	je     801015 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80100b:	83 c0 01             	add    $0x1,%eax
  80100e:	0f b6 10             	movzbl (%eax),%edx
  801011:	84 d2                	test   %dl,%dl
  801013:	75 f2                	jne    801007 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
  80101d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801020:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801023:	85 c9                	test   %ecx,%ecx
  801025:	74 36                	je     80105d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801027:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80102d:	75 28                	jne    801057 <memset+0x40>
  80102f:	f6 c1 03             	test   $0x3,%cl
  801032:	75 23                	jne    801057 <memset+0x40>
		c &= 0xFF;
  801034:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801038:	89 d3                	mov    %edx,%ebx
  80103a:	c1 e3 08             	shl    $0x8,%ebx
  80103d:	89 d6                	mov    %edx,%esi
  80103f:	c1 e6 18             	shl    $0x18,%esi
  801042:	89 d0                	mov    %edx,%eax
  801044:	c1 e0 10             	shl    $0x10,%eax
  801047:	09 f0                	or     %esi,%eax
  801049:	09 c2                	or     %eax,%edx
  80104b:	89 d0                	mov    %edx,%eax
  80104d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80104f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801052:	fc                   	cld    
  801053:	f3 ab                	rep stos %eax,%es:(%edi)
  801055:	eb 06                	jmp    80105d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801057:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105a:	fc                   	cld    
  80105b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80105d:	89 f8                	mov    %edi,%eax
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5f                   	pop    %edi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	57                   	push   %edi
  801068:	56                   	push   %esi
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80106f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801072:	39 c6                	cmp    %eax,%esi
  801074:	73 35                	jae    8010ab <memmove+0x47>
  801076:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801079:	39 d0                	cmp    %edx,%eax
  80107b:	73 2e                	jae    8010ab <memmove+0x47>
		s += n;
		d += n;
  80107d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801080:	89 d6                	mov    %edx,%esi
  801082:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801084:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80108a:	75 13                	jne    80109f <memmove+0x3b>
  80108c:	f6 c1 03             	test   $0x3,%cl
  80108f:	75 0e                	jne    80109f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801091:	83 ef 04             	sub    $0x4,%edi
  801094:	8d 72 fc             	lea    -0x4(%edx),%esi
  801097:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80109a:	fd                   	std    
  80109b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80109d:	eb 09                	jmp    8010a8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80109f:	83 ef 01             	sub    $0x1,%edi
  8010a2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8010a5:	fd                   	std    
  8010a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8010a8:	fc                   	cld    
  8010a9:	eb 1d                	jmp    8010c8 <memmove+0x64>
  8010ab:	89 f2                	mov    %esi,%edx
  8010ad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010af:	f6 c2 03             	test   $0x3,%dl
  8010b2:	75 0f                	jne    8010c3 <memmove+0x5f>
  8010b4:	f6 c1 03             	test   $0x3,%cl
  8010b7:	75 0a                	jne    8010c3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8010b9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8010bc:	89 c7                	mov    %eax,%edi
  8010be:	fc                   	cld    
  8010bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010c1:	eb 05                	jmp    8010c8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8010c3:	89 c7                	mov    %eax,%edi
  8010c5:	fc                   	cld    
  8010c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8010d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	89 04 24             	mov    %eax,(%esp)
  8010e6:	e8 79 ff ff ff       	call   801064 <memmove>
}
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    

008010ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f8:	89 d6                	mov    %edx,%esi
  8010fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010fd:	eb 1a                	jmp    801119 <memcmp+0x2c>
		if (*s1 != *s2)
  8010ff:	0f b6 02             	movzbl (%edx),%eax
  801102:	0f b6 19             	movzbl (%ecx),%ebx
  801105:	38 d8                	cmp    %bl,%al
  801107:	74 0a                	je     801113 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801109:	0f b6 c0             	movzbl %al,%eax
  80110c:	0f b6 db             	movzbl %bl,%ebx
  80110f:	29 d8                	sub    %ebx,%eax
  801111:	eb 0f                	jmp    801122 <memcmp+0x35>
		s1++, s2++;
  801113:	83 c2 01             	add    $0x1,%edx
  801116:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801119:	39 f2                	cmp    %esi,%edx
  80111b:	75 e2                	jne    8010ff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80111d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801122:	5b                   	pop    %ebx
  801123:	5e                   	pop    %esi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	8b 45 08             	mov    0x8(%ebp),%eax
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80112f:	89 c2                	mov    %eax,%edx
  801131:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801134:	eb 07                	jmp    80113d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801136:	38 08                	cmp    %cl,(%eax)
  801138:	74 07                	je     801141 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80113a:	83 c0 01             	add    $0x1,%eax
  80113d:	39 d0                	cmp    %edx,%eax
  80113f:	72 f5                	jb     801136 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80114f:	eb 03                	jmp    801154 <strtol+0x11>
		s++;
  801151:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801154:	0f b6 0a             	movzbl (%edx),%ecx
  801157:	80 f9 09             	cmp    $0x9,%cl
  80115a:	74 f5                	je     801151 <strtol+0xe>
  80115c:	80 f9 20             	cmp    $0x20,%cl
  80115f:	74 f0                	je     801151 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801161:	80 f9 2b             	cmp    $0x2b,%cl
  801164:	75 0a                	jne    801170 <strtol+0x2d>
		s++;
  801166:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801169:	bf 00 00 00 00       	mov    $0x0,%edi
  80116e:	eb 11                	jmp    801181 <strtol+0x3e>
  801170:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801175:	80 f9 2d             	cmp    $0x2d,%cl
  801178:	75 07                	jne    801181 <strtol+0x3e>
		s++, neg = 1;
  80117a:	8d 52 01             	lea    0x1(%edx),%edx
  80117d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801181:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801186:	75 15                	jne    80119d <strtol+0x5a>
  801188:	80 3a 30             	cmpb   $0x30,(%edx)
  80118b:	75 10                	jne    80119d <strtol+0x5a>
  80118d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801191:	75 0a                	jne    80119d <strtol+0x5a>
		s += 2, base = 16;
  801193:	83 c2 02             	add    $0x2,%edx
  801196:	b8 10 00 00 00       	mov    $0x10,%eax
  80119b:	eb 10                	jmp    8011ad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80119d:	85 c0                	test   %eax,%eax
  80119f:	75 0c                	jne    8011ad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8011a1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8011a3:	80 3a 30             	cmpb   $0x30,(%edx)
  8011a6:	75 05                	jne    8011ad <strtol+0x6a>
		s++, base = 8;
  8011a8:	83 c2 01             	add    $0x1,%edx
  8011ab:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8011b5:	0f b6 0a             	movzbl (%edx),%ecx
  8011b8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8011bb:	89 f0                	mov    %esi,%eax
  8011bd:	3c 09                	cmp    $0x9,%al
  8011bf:	77 08                	ja     8011c9 <strtol+0x86>
			dig = *s - '0';
  8011c1:	0f be c9             	movsbl %cl,%ecx
  8011c4:	83 e9 30             	sub    $0x30,%ecx
  8011c7:	eb 20                	jmp    8011e9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8011c9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8011cc:	89 f0                	mov    %esi,%eax
  8011ce:	3c 19                	cmp    $0x19,%al
  8011d0:	77 08                	ja     8011da <strtol+0x97>
			dig = *s - 'a' + 10;
  8011d2:	0f be c9             	movsbl %cl,%ecx
  8011d5:	83 e9 57             	sub    $0x57,%ecx
  8011d8:	eb 0f                	jmp    8011e9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8011da:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8011dd:	89 f0                	mov    %esi,%eax
  8011df:	3c 19                	cmp    $0x19,%al
  8011e1:	77 16                	ja     8011f9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8011e3:	0f be c9             	movsbl %cl,%ecx
  8011e6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8011e9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8011ec:	7d 0f                	jge    8011fd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8011ee:	83 c2 01             	add    $0x1,%edx
  8011f1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8011f5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8011f7:	eb bc                	jmp    8011b5 <strtol+0x72>
  8011f9:	89 d8                	mov    %ebx,%eax
  8011fb:	eb 02                	jmp    8011ff <strtol+0xbc>
  8011fd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8011ff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801203:	74 05                	je     80120a <strtol+0xc7>
		*endptr = (char *) s;
  801205:	8b 75 0c             	mov    0xc(%ebp),%esi
  801208:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80120a:	f7 d8                	neg    %eax
  80120c:	85 ff                	test   %edi,%edi
  80120e:	0f 44 c3             	cmove  %ebx,%eax
}
  801211:	5b                   	pop    %ebx
  801212:	5e                   	pop    %esi
  801213:	5f                   	pop    %edi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	57                   	push   %edi
  80121a:	56                   	push   %esi
  80121b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121c:	b8 00 00 00 00       	mov    $0x0,%eax
  801221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801224:	8b 55 08             	mov    0x8(%ebp),%edx
  801227:	89 c3                	mov    %eax,%ebx
  801229:	89 c7                	mov    %eax,%edi
  80122b:	89 c6                	mov    %eax,%esi
  80122d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <sys_cgetc>:

int
sys_cgetc(void)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	57                   	push   %edi
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123a:	ba 00 00 00 00       	mov    $0x0,%edx
  80123f:	b8 01 00 00 00       	mov    $0x1,%eax
  801244:	89 d1                	mov    %edx,%ecx
  801246:	89 d3                	mov    %edx,%ebx
  801248:	89 d7                	mov    %edx,%edi
  80124a:	89 d6                	mov    %edx,%esi
  80124c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80124e:	5b                   	pop    %ebx
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	57                   	push   %edi
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801261:	b8 03 00 00 00       	mov    $0x3,%eax
  801266:	8b 55 08             	mov    0x8(%ebp),%edx
  801269:	89 cb                	mov    %ecx,%ebx
  80126b:	89 cf                	mov    %ecx,%edi
  80126d:	89 ce                	mov    %ecx,%esi
  80126f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801271:	85 c0                	test   %eax,%eax
  801273:	7e 28                	jle    80129d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801275:	89 44 24 10          	mov    %eax,0x10(%esp)
  801279:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801280:	00 
  801281:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  801288:	00 
  801289:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801290:	00 
  801291:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  801298:	e8 0d f0 ff ff       	call   8002aa <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80129d:	83 c4 2c             	add    $0x2c,%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	57                   	push   %edi
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8012b5:	89 d1                	mov    %edx,%ecx
  8012b7:	89 d3                	mov    %edx,%ebx
  8012b9:	89 d7                	mov    %edx,%edi
  8012bb:	89 d6                	mov    %edx,%esi
  8012bd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012bf:	5b                   	pop    %ebx
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <sys_yield>:

void
sys_yield(void)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	57                   	push   %edi
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012d4:	89 d1                	mov    %edx,%ecx
  8012d6:	89 d3                	mov    %edx,%ebx
  8012d8:	89 d7                	mov    %edx,%edi
  8012da:	89 d6                	mov    %edx,%esi
  8012dc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5f                   	pop    %edi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	57                   	push   %edi
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
  8012e9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ec:	be 00 00 00 00       	mov    $0x0,%esi
  8012f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8012f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ff:	89 f7                	mov    %esi,%edi
  801301:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801303:	85 c0                	test   %eax,%eax
  801305:	7e 28                	jle    80132f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801307:	89 44 24 10          	mov    %eax,0x10(%esp)
  80130b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801312:	00 
  801313:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  80131a:	00 
  80131b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801322:	00 
  801323:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  80132a:	e8 7b ef ff ff       	call   8002aa <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80132f:	83 c4 2c             	add    $0x2c,%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5f                   	pop    %edi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	57                   	push   %edi
  80133b:	56                   	push   %esi
  80133c:	53                   	push   %ebx
  80133d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801340:	b8 05 00 00 00       	mov    $0x5,%eax
  801345:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801348:	8b 55 08             	mov    0x8(%ebp),%edx
  80134b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801351:	8b 75 18             	mov    0x18(%ebp),%esi
  801354:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801356:	85 c0                	test   %eax,%eax
  801358:	7e 28                	jle    801382 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80135e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801365:	00 
  801366:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  80136d:	00 
  80136e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801375:	00 
  801376:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  80137d:	e8 28 ef ff ff       	call   8002aa <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801382:	83 c4 2c             	add    $0x2c,%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	5f                   	pop    %edi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	57                   	push   %edi
  80138e:	56                   	push   %esi
  80138f:	53                   	push   %ebx
  801390:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801393:	bb 00 00 00 00       	mov    $0x0,%ebx
  801398:	b8 06 00 00 00       	mov    $0x6,%eax
  80139d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a3:	89 df                	mov    %ebx,%edi
  8013a5:	89 de                	mov    %ebx,%esi
  8013a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	7e 28                	jle    8013d5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013b1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013b8:	00 
  8013b9:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  8013c0:	00 
  8013c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013c8:	00 
  8013c9:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  8013d0:	e8 d5 ee ff ff       	call   8002aa <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013d5:	83 c4 2c             	add    $0x2c,%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	57                   	push   %edi
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8013f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f6:	89 df                	mov    %ebx,%edi
  8013f8:	89 de                	mov    %ebx,%esi
  8013fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	7e 28                	jle    801428 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801400:	89 44 24 10          	mov    %eax,0x10(%esp)
  801404:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80140b:	00 
  80140c:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  801413:	00 
  801414:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80141b:	00 
  80141c:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  801423:	e8 82 ee ff ff       	call   8002aa <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801428:	83 c4 2c             	add    $0x2c,%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5f                   	pop    %edi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	57                   	push   %edi
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801439:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143e:	b8 09 00 00 00       	mov    $0x9,%eax
  801443:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801446:	8b 55 08             	mov    0x8(%ebp),%edx
  801449:	89 df                	mov    %ebx,%edi
  80144b:	89 de                	mov    %ebx,%esi
  80144d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80144f:	85 c0                	test   %eax,%eax
  801451:	7e 28                	jle    80147b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801453:	89 44 24 10          	mov    %eax,0x10(%esp)
  801457:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80145e:	00 
  80145f:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  801466:	00 
  801467:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80146e:	00 
  80146f:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  801476:	e8 2f ee ff ff       	call   8002aa <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80147b:	83 c4 2c             	add    $0x2c,%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	57                   	push   %edi
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801489:	be 00 00 00 00       	mov    $0x0,%esi
  80148e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801493:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801496:	8b 55 08             	mov    0x8(%ebp),%edx
  801499:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80149c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80149f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8014a1:	5b                   	pop    %ebx
  8014a2:	5e                   	pop    %esi
  8014a3:	5f                   	pop    %edi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	57                   	push   %edi
  8014aa:	56                   	push   %esi
  8014ab:	53                   	push   %ebx
  8014ac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014b4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bc:	89 cb                	mov    %ecx,%ebx
  8014be:	89 cf                	mov    %ecx,%edi
  8014c0:	89 ce                	mov    %ecx,%esi
  8014c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	7e 28                	jle    8014f0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014cc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8014d3:	00 
  8014d4:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  8014db:	00 
  8014dc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014e3:	00 
  8014e4:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  8014eb:	e8 ba ed ff ff       	call   8002aa <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014f0:	83 c4 2c             	add    $0x2c,%esp
  8014f3:	5b                   	pop    %ebx
  8014f4:	5e                   	pop    %esi
  8014f5:	5f                   	pop    %edi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    
  8014f8:	66 90                	xchg   %ax,%ax
  8014fa:	66 90                	xchg   %ax,%ax
  8014fc:	66 90                	xchg   %ax,%ax
  8014fe:	66 90                	xchg   %ax,%ax

00801500 <__udivdi3>:
  801500:	55                   	push   %ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	83 ec 0c             	sub    $0xc,%esp
  801506:	8b 44 24 28          	mov    0x28(%esp),%eax
  80150a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80150e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801512:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801516:	85 c0                	test   %eax,%eax
  801518:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80151c:	89 ea                	mov    %ebp,%edx
  80151e:	89 0c 24             	mov    %ecx,(%esp)
  801521:	75 2d                	jne    801550 <__udivdi3+0x50>
  801523:	39 e9                	cmp    %ebp,%ecx
  801525:	77 61                	ja     801588 <__udivdi3+0x88>
  801527:	85 c9                	test   %ecx,%ecx
  801529:	89 ce                	mov    %ecx,%esi
  80152b:	75 0b                	jne    801538 <__udivdi3+0x38>
  80152d:	b8 01 00 00 00       	mov    $0x1,%eax
  801532:	31 d2                	xor    %edx,%edx
  801534:	f7 f1                	div    %ecx
  801536:	89 c6                	mov    %eax,%esi
  801538:	31 d2                	xor    %edx,%edx
  80153a:	89 e8                	mov    %ebp,%eax
  80153c:	f7 f6                	div    %esi
  80153e:	89 c5                	mov    %eax,%ebp
  801540:	89 f8                	mov    %edi,%eax
  801542:	f7 f6                	div    %esi
  801544:	89 ea                	mov    %ebp,%edx
  801546:	83 c4 0c             	add    $0xc,%esp
  801549:	5e                   	pop    %esi
  80154a:	5f                   	pop    %edi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    
  80154d:	8d 76 00             	lea    0x0(%esi),%esi
  801550:	39 e8                	cmp    %ebp,%eax
  801552:	77 24                	ja     801578 <__udivdi3+0x78>
  801554:	0f bd e8             	bsr    %eax,%ebp
  801557:	83 f5 1f             	xor    $0x1f,%ebp
  80155a:	75 3c                	jne    801598 <__udivdi3+0x98>
  80155c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801560:	39 34 24             	cmp    %esi,(%esp)
  801563:	0f 86 9f 00 00 00    	jbe    801608 <__udivdi3+0x108>
  801569:	39 d0                	cmp    %edx,%eax
  80156b:	0f 82 97 00 00 00    	jb     801608 <__udivdi3+0x108>
  801571:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801578:	31 d2                	xor    %edx,%edx
  80157a:	31 c0                	xor    %eax,%eax
  80157c:	83 c4 0c             	add    $0xc,%esp
  80157f:	5e                   	pop    %esi
  801580:	5f                   	pop    %edi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    
  801583:	90                   	nop
  801584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801588:	89 f8                	mov    %edi,%eax
  80158a:	f7 f1                	div    %ecx
  80158c:	31 d2                	xor    %edx,%edx
  80158e:	83 c4 0c             	add    $0xc,%esp
  801591:	5e                   	pop    %esi
  801592:	5f                   	pop    %edi
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    
  801595:	8d 76 00             	lea    0x0(%esi),%esi
  801598:	89 e9                	mov    %ebp,%ecx
  80159a:	8b 3c 24             	mov    (%esp),%edi
  80159d:	d3 e0                	shl    %cl,%eax
  80159f:	89 c6                	mov    %eax,%esi
  8015a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8015a6:	29 e8                	sub    %ebp,%eax
  8015a8:	89 c1                	mov    %eax,%ecx
  8015aa:	d3 ef                	shr    %cl,%edi
  8015ac:	89 e9                	mov    %ebp,%ecx
  8015ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8015b2:	8b 3c 24             	mov    (%esp),%edi
  8015b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8015b9:	89 d6                	mov    %edx,%esi
  8015bb:	d3 e7                	shl    %cl,%edi
  8015bd:	89 c1                	mov    %eax,%ecx
  8015bf:	89 3c 24             	mov    %edi,(%esp)
  8015c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015c6:	d3 ee                	shr    %cl,%esi
  8015c8:	89 e9                	mov    %ebp,%ecx
  8015ca:	d3 e2                	shl    %cl,%edx
  8015cc:	89 c1                	mov    %eax,%ecx
  8015ce:	d3 ef                	shr    %cl,%edi
  8015d0:	09 d7                	or     %edx,%edi
  8015d2:	89 f2                	mov    %esi,%edx
  8015d4:	89 f8                	mov    %edi,%eax
  8015d6:	f7 74 24 08          	divl   0x8(%esp)
  8015da:	89 d6                	mov    %edx,%esi
  8015dc:	89 c7                	mov    %eax,%edi
  8015de:	f7 24 24             	mull   (%esp)
  8015e1:	39 d6                	cmp    %edx,%esi
  8015e3:	89 14 24             	mov    %edx,(%esp)
  8015e6:	72 30                	jb     801618 <__udivdi3+0x118>
  8015e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015ec:	89 e9                	mov    %ebp,%ecx
  8015ee:	d3 e2                	shl    %cl,%edx
  8015f0:	39 c2                	cmp    %eax,%edx
  8015f2:	73 05                	jae    8015f9 <__udivdi3+0xf9>
  8015f4:	3b 34 24             	cmp    (%esp),%esi
  8015f7:	74 1f                	je     801618 <__udivdi3+0x118>
  8015f9:	89 f8                	mov    %edi,%eax
  8015fb:	31 d2                	xor    %edx,%edx
  8015fd:	e9 7a ff ff ff       	jmp    80157c <__udivdi3+0x7c>
  801602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801608:	31 d2                	xor    %edx,%edx
  80160a:	b8 01 00 00 00       	mov    $0x1,%eax
  80160f:	e9 68 ff ff ff       	jmp    80157c <__udivdi3+0x7c>
  801614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801618:	8d 47 ff             	lea    -0x1(%edi),%eax
  80161b:	31 d2                	xor    %edx,%edx
  80161d:	83 c4 0c             	add    $0xc,%esp
  801620:	5e                   	pop    %esi
  801621:	5f                   	pop    %edi
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    
  801624:	66 90                	xchg   %ax,%ax
  801626:	66 90                	xchg   %ax,%ax
  801628:	66 90                	xchg   %ax,%ax
  80162a:	66 90                	xchg   %ax,%ax
  80162c:	66 90                	xchg   %ax,%ax
  80162e:	66 90                	xchg   %ax,%ax

00801630 <__umoddi3>:
  801630:	55                   	push   %ebp
  801631:	57                   	push   %edi
  801632:	56                   	push   %esi
  801633:	83 ec 14             	sub    $0x14,%esp
  801636:	8b 44 24 28          	mov    0x28(%esp),%eax
  80163a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80163e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801642:	89 c7                	mov    %eax,%edi
  801644:	89 44 24 04          	mov    %eax,0x4(%esp)
  801648:	8b 44 24 30          	mov    0x30(%esp),%eax
  80164c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801650:	89 34 24             	mov    %esi,(%esp)
  801653:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801657:	85 c0                	test   %eax,%eax
  801659:	89 c2                	mov    %eax,%edx
  80165b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80165f:	75 17                	jne    801678 <__umoddi3+0x48>
  801661:	39 fe                	cmp    %edi,%esi
  801663:	76 4b                	jbe    8016b0 <__umoddi3+0x80>
  801665:	89 c8                	mov    %ecx,%eax
  801667:	89 fa                	mov    %edi,%edx
  801669:	f7 f6                	div    %esi
  80166b:	89 d0                	mov    %edx,%eax
  80166d:	31 d2                	xor    %edx,%edx
  80166f:	83 c4 14             	add    $0x14,%esp
  801672:	5e                   	pop    %esi
  801673:	5f                   	pop    %edi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    
  801676:	66 90                	xchg   %ax,%ax
  801678:	39 f8                	cmp    %edi,%eax
  80167a:	77 54                	ja     8016d0 <__umoddi3+0xa0>
  80167c:	0f bd e8             	bsr    %eax,%ebp
  80167f:	83 f5 1f             	xor    $0x1f,%ebp
  801682:	75 5c                	jne    8016e0 <__umoddi3+0xb0>
  801684:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801688:	39 3c 24             	cmp    %edi,(%esp)
  80168b:	0f 87 e7 00 00 00    	ja     801778 <__umoddi3+0x148>
  801691:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801695:	29 f1                	sub    %esi,%ecx
  801697:	19 c7                	sbb    %eax,%edi
  801699:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80169d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8016a9:	83 c4 14             	add    $0x14,%esp
  8016ac:	5e                   	pop    %esi
  8016ad:	5f                   	pop    %edi
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    
  8016b0:	85 f6                	test   %esi,%esi
  8016b2:	89 f5                	mov    %esi,%ebp
  8016b4:	75 0b                	jne    8016c1 <__umoddi3+0x91>
  8016b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8016bb:	31 d2                	xor    %edx,%edx
  8016bd:	f7 f6                	div    %esi
  8016bf:	89 c5                	mov    %eax,%ebp
  8016c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8016c5:	31 d2                	xor    %edx,%edx
  8016c7:	f7 f5                	div    %ebp
  8016c9:	89 c8                	mov    %ecx,%eax
  8016cb:	f7 f5                	div    %ebp
  8016cd:	eb 9c                	jmp    80166b <__umoddi3+0x3b>
  8016cf:	90                   	nop
  8016d0:	89 c8                	mov    %ecx,%eax
  8016d2:	89 fa                	mov    %edi,%edx
  8016d4:	83 c4 14             	add    $0x14,%esp
  8016d7:	5e                   	pop    %esi
  8016d8:	5f                   	pop    %edi
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    
  8016db:	90                   	nop
  8016dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016e0:	8b 04 24             	mov    (%esp),%eax
  8016e3:	be 20 00 00 00       	mov    $0x20,%esi
  8016e8:	89 e9                	mov    %ebp,%ecx
  8016ea:	29 ee                	sub    %ebp,%esi
  8016ec:	d3 e2                	shl    %cl,%edx
  8016ee:	89 f1                	mov    %esi,%ecx
  8016f0:	d3 e8                	shr    %cl,%eax
  8016f2:	89 e9                	mov    %ebp,%ecx
  8016f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f8:	8b 04 24             	mov    (%esp),%eax
  8016fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8016ff:	89 fa                	mov    %edi,%edx
  801701:	d3 e0                	shl    %cl,%eax
  801703:	89 f1                	mov    %esi,%ecx
  801705:	89 44 24 08          	mov    %eax,0x8(%esp)
  801709:	8b 44 24 10          	mov    0x10(%esp),%eax
  80170d:	d3 ea                	shr    %cl,%edx
  80170f:	89 e9                	mov    %ebp,%ecx
  801711:	d3 e7                	shl    %cl,%edi
  801713:	89 f1                	mov    %esi,%ecx
  801715:	d3 e8                	shr    %cl,%eax
  801717:	89 e9                	mov    %ebp,%ecx
  801719:	09 f8                	or     %edi,%eax
  80171b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80171f:	f7 74 24 04          	divl   0x4(%esp)
  801723:	d3 e7                	shl    %cl,%edi
  801725:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801729:	89 d7                	mov    %edx,%edi
  80172b:	f7 64 24 08          	mull   0x8(%esp)
  80172f:	39 d7                	cmp    %edx,%edi
  801731:	89 c1                	mov    %eax,%ecx
  801733:	89 14 24             	mov    %edx,(%esp)
  801736:	72 2c                	jb     801764 <__umoddi3+0x134>
  801738:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80173c:	72 22                	jb     801760 <__umoddi3+0x130>
  80173e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801742:	29 c8                	sub    %ecx,%eax
  801744:	19 d7                	sbb    %edx,%edi
  801746:	89 e9                	mov    %ebp,%ecx
  801748:	89 fa                	mov    %edi,%edx
  80174a:	d3 e8                	shr    %cl,%eax
  80174c:	89 f1                	mov    %esi,%ecx
  80174e:	d3 e2                	shl    %cl,%edx
  801750:	89 e9                	mov    %ebp,%ecx
  801752:	d3 ef                	shr    %cl,%edi
  801754:	09 d0                	or     %edx,%eax
  801756:	89 fa                	mov    %edi,%edx
  801758:	83 c4 14             	add    $0x14,%esp
  80175b:	5e                   	pop    %esi
  80175c:	5f                   	pop    %edi
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    
  80175f:	90                   	nop
  801760:	39 d7                	cmp    %edx,%edi
  801762:	75 da                	jne    80173e <__umoddi3+0x10e>
  801764:	8b 14 24             	mov    (%esp),%edx
  801767:	89 c1                	mov    %eax,%ecx
  801769:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80176d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801771:	eb cb                	jmp    80173e <__umoddi3+0x10e>
  801773:	90                   	nop
  801774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801778:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80177c:	0f 82 0f ff ff ff    	jb     801691 <__umoddi3+0x61>
  801782:	e9 1a ff ff ff       	jmp    8016a1 <__umoddi3+0x71>
