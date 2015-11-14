
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
  80002c:	e8 20 02 00 00       	call   800251 <libmain>
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
  80005d:	e8 91 12 00 00       	call   8012f3 <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 a0 17 80 	movl   $0x8017a0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  800081:	e8 2b 02 00 00       	call   8002b1 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 9d 12 00 00       	call   801347 <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 c3 17 80 	movl   $0x8017c3,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  8000c9:	e8 e3 01 00 00       	call   8002b1 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 8e 0f 00 00       	call   801074 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 a0 12 00 00       	call   80139a <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 d4 17 80 	movl   $0x8017d4,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  800119:	e8 93 01 00 00       	call   8002b1 <_panic>
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
  800155:	e8 57 01 00 00       	call   8002b1 <_panic>
  80015a:	89 c3                	mov    %eax,%ebx
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 22                	jne    800182 <dumbfork+0x5d>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 50 11 00 00       	call   8012b5 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	89 c2                	mov    %eax,%edx
  80016c:	c1 e2 07             	shl    $0x7,%edx
  80016f:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800176:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80017b:	b8 00 00 00 00       	mov    $0x0,%eax
  800180:	eb 71                	jmp    8001f3 <dumbfork+0xce>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800182:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800189:	eb 13                	jmp    80019e <dumbfork+0x79>
		duppage(envid, addr);
  80018b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80018f:	89 1c 24             	mov    %ebx,(%esp)
  800192:	e8 a9 fe ff ff       	call   800040 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800197:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80019e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001a1:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  8001a7:	72 e2                	jb     80018b <dumbfork+0x66>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b5:	89 34 24             	mov    %esi,(%esp)
  8001b8:	e8 83 fe ff ff       	call   800040 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001bd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001c4:	00 
  8001c5:	89 34 24             	mov    %esi,(%esp)
  8001c8:	e8 20 12 00 00       	call   8013ed <sys_env_set_status>
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	79 20                	jns    8001f1 <dumbfork+0xcc>
		panic("sys_env_set_status: %e", r);
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	c7 44 24 08 f7 17 80 	movl   $0x8017f7,0x8(%esp)
  8001dc:	00 
  8001dd:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e4:	00 
  8001e5:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  8001ec:	e8 c0 00 00 00       	call   8002b1 <_panic>

	return envid;
  8001f1:	89 f0                	mov    %esi,%eax
}
  8001f3:	83 c4 20             	add    $0x20,%esp
  8001f6:	5b                   	pop    %ebx
  8001f7:	5e                   	pop    %esi
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    

008001fa <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	56                   	push   %esi
  8001fe:	53                   	push   %ebx
  8001ff:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800202:	e8 1e ff ff ff       	call   800125 <dumbfork>
  800207:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800209:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020e:	eb 28                	jmp    800238 <umain+0x3e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800210:	b8 15 18 80 00       	mov    $0x801815,%eax
  800215:	eb 05                	jmp    80021c <umain+0x22>
  800217:	b8 0e 18 80 00       	mov    $0x80180e,%eax
  80021c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800220:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800224:	c7 04 24 1b 18 80 00 	movl   $0x80181b,(%esp)
  80022b:	e8 7a 01 00 00       	call   8003aa <cprintf>
		sys_yield();
  800230:	e8 9f 10 00 00       	call   8012d4 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800235:	83 c3 01             	add    $0x1,%ebx
  800238:	85 f6                	test   %esi,%esi
  80023a:	75 07                	jne    800243 <umain+0x49>
  80023c:	83 fb 13             	cmp    $0x13,%ebx
  80023f:	7e cf                	jle    800210 <umain+0x16>
  800241:	eb 05                	jmp    800248 <umain+0x4e>
  800243:	83 fb 09             	cmp    $0x9,%ebx
  800246:	7e cf                	jle    800217 <umain+0x1d>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800248:	83 c4 10             	add    $0x10,%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5d                   	pop    %ebp
  80024e:	66 90                	xchg   %ax,%ax
  800250:	c3                   	ret    

00800251 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 10             	sub    $0x10,%esp
  800259:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80025c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80025f:	e8 51 10 00 00       	call   8012b5 <sys_getenvid>
  800264:	25 ff 03 00 00       	and    $0x3ff,%eax
  800269:	89 c2                	mov    %eax,%edx
  80026b:	c1 e2 07             	shl    $0x7,%edx
  80026e:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800275:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80027a:	85 db                	test   %ebx,%ebx
  80027c:	7e 07                	jle    800285 <libmain+0x34>
		binaryname = argv[0];
  80027e:	8b 06                	mov    (%esi),%eax
  800280:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800285:	89 74 24 04          	mov    %esi,0x4(%esp)
  800289:	89 1c 24             	mov    %ebx,(%esp)
  80028c:	e8 69 ff ff ff       	call   8001fa <umain>

	// exit gracefully
	exit();
  800291:	e8 07 00 00 00       	call   80029d <exit>
}
  800296:	83 c4 10             	add    $0x10,%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002aa:	e8 b4 0f 00 00       	call   801263 <sys_env_destroy>
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002bc:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002c2:	e8 ee 0f 00 00       	call   8012b5 <sys_getenvid>
  8002c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ca:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	c7 04 24 38 18 80 00 	movl   $0x801838,(%esp)
  8002e4:	e8 c1 00 00 00       	call   8003aa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	e8 51 00 00 00       	call   800349 <vcprintf>
	cprintf("\n");
  8002f8:	c7 04 24 2b 18 80 00 	movl   $0x80182b,(%esp)
  8002ff:	e8 a6 00 00 00       	call   8003aa <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800304:	cc                   	int3   
  800305:	eb fd                	jmp    800304 <_panic+0x53>

00800307 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	53                   	push   %ebx
  80030b:	83 ec 14             	sub    $0x14,%esp
  80030e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800311:	8b 13                	mov    (%ebx),%edx
  800313:	8d 42 01             	lea    0x1(%edx),%eax
  800316:	89 03                	mov    %eax,(%ebx)
  800318:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80031b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80031f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800324:	75 19                	jne    80033f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800326:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80032d:	00 
  80032e:	8d 43 08             	lea    0x8(%ebx),%eax
  800331:	89 04 24             	mov    %eax,(%esp)
  800334:	e8 ed 0e 00 00       	call   801226 <sys_cputs>
		b->idx = 0;
  800339:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80033f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800343:	83 c4 14             	add    $0x14,%esp
  800346:	5b                   	pop    %ebx
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800352:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800359:	00 00 00 
	b.cnt = 0;
  80035c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800363:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800366:	8b 45 0c             	mov    0xc(%ebp),%eax
  800369:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	89 44 24 08          	mov    %eax,0x8(%esp)
  800374:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037e:	c7 04 24 07 03 80 00 	movl   $0x800307,(%esp)
  800385:	e8 b5 02 00 00       	call   80063f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80038a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800390:	89 44 24 04          	mov    %eax,0x4(%esp)
  800394:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80039a:	89 04 24             	mov    %eax,(%esp)
  80039d:	e8 84 0e 00 00       	call   801226 <sys_cputs>

	return b.cnt;
}
  8003a2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    

008003aa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ba:	89 04 24             	mov    %eax,(%esp)
  8003bd:	e8 87 ff ff ff       	call   800349 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    
  8003c4:	66 90                	xchg   %ax,%ax
  8003c6:	66 90                	xchg   %ax,%ax
  8003c8:	66 90                	xchg   %ax,%ax
  8003ca:	66 90                	xchg   %ax,%ax
  8003cc:	66 90                	xchg   %ax,%ax
  8003ce:	66 90                	xchg   %ax,%ax

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 3c             	sub    $0x3c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d7                	mov    %edx,%edi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e7:	89 c3                	mov    %eax,%ebx
  8003e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003fd:	39 d9                	cmp    %ebx,%ecx
  8003ff:	72 05                	jb     800406 <printnum+0x36>
  800401:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800404:	77 69                	ja     80046f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800406:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800409:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80040d:	83 ee 01             	sub    $0x1,%esi
  800410:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800414:	89 44 24 08          	mov    %eax,0x8(%esp)
  800418:	8b 44 24 08          	mov    0x8(%esp),%eax
  80041c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800420:	89 c3                	mov    %eax,%ebx
  800422:	89 d6                	mov    %edx,%esi
  800424:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800427:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80042a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80042e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800432:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800435:	89 04 24             	mov    %eax,(%esp)
  800438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80043b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043f:	e8 cc 10 00 00       	call   801510 <__udivdi3>
  800444:	89 d9                	mov    %ebx,%ecx
  800446:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80044a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80044e:	89 04 24             	mov    %eax,(%esp)
  800451:	89 54 24 04          	mov    %edx,0x4(%esp)
  800455:	89 fa                	mov    %edi,%edx
  800457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045a:	e8 71 ff ff ff       	call   8003d0 <printnum>
  80045f:	eb 1b                	jmp    80047c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800461:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800465:	8b 45 18             	mov    0x18(%ebp),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	ff d3                	call   *%ebx
  80046d:	eb 03                	jmp    800472 <printnum+0xa2>
  80046f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800472:	83 ee 01             	sub    $0x1,%esi
  800475:	85 f6                	test   %esi,%esi
  800477:	7f e8                	jg     800461 <printnum+0x91>
  800479:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800480:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800484:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800487:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80048a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80049b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049f:	e8 9c 11 00 00       	call   801640 <__umoddi3>
  8004a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a8:	0f be 80 5c 18 80 00 	movsbl 0x80185c(%eax),%eax
  8004af:	89 04 24             	mov    %eax,(%esp)
  8004b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b5:	ff d0                	call   *%eax
}
  8004b7:	83 c4 3c             	add    $0x3c,%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	57                   	push   %edi
  8004c3:	56                   	push   %esi
  8004c4:	53                   	push   %ebx
  8004c5:	83 ec 3c             	sub    $0x3c,%esp
  8004c8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004cb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ce:	89 cf                	mov    %ecx,%edi
  8004d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d9:	89 c3                	mov    %eax,%ebx
  8004db:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004de:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ec:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004ef:	39 d9                	cmp    %ebx,%ecx
  8004f1:	72 13                	jb     800506 <cprintnum+0x47>
  8004f3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8004f6:	76 0e                	jbe    800506 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8004f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fb:	0b 45 18             	or     0x18(%ebp),%eax
  8004fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800501:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800504:	eb 6a                	jmp    800570 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800506:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800509:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80050d:	83 ee 01             	sub    $0x1,%esi
  800510:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800514:	89 44 24 08          	mov    %eax,0x8(%esp)
  800518:	8b 44 24 08          	mov    0x8(%esp),%eax
  80051c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800520:	89 c3                	mov    %eax,%ebx
  800522:	89 d6                	mov    %edx,%esi
  800524:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800527:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80052a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80052e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800532:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80053b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053f:	e8 cc 0f 00 00       	call   801510 <__udivdi3>
  800544:	89 d9                	mov    %ebx,%ecx
  800546:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80054a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	89 54 24 04          	mov    %edx,0x4(%esp)
  800555:	89 f9                	mov    %edi,%ecx
  800557:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80055a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80055d:	e8 5d ff ff ff       	call   8004bf <cprintnum>
  800562:	eb 16                	jmp    80057a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800564:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800568:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800570:	83 ee 01             	sub    $0x1,%esi
  800573:	85 f6                	test   %esi,%esi
  800575:	7f ed                	jg     800564 <cprintnum+0xa5>
  800577:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80057a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800582:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800585:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800588:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800590:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800593:	89 04 24             	mov    %eax,(%esp)
  800596:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800599:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059d:	e8 9e 10 00 00       	call   801640 <__umoddi3>
  8005a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a6:	0f be 80 5c 18 80 00 	movsbl 0x80185c(%eax),%eax
  8005ad:	0b 45 dc             	or     -0x24(%ebp),%eax
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b6:	ff d0                	call   *%eax
}
  8005b8:	83 c4 3c             	add    $0x3c,%esp
  8005bb:	5b                   	pop    %ebx
  8005bc:	5e                   	pop    %esi
  8005bd:	5f                   	pop    %edi
  8005be:	5d                   	pop    %ebp
  8005bf:	c3                   	ret    

008005c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005c3:	83 fa 01             	cmp    $0x1,%edx
  8005c6:	7e 0e                	jle    8005d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005c8:	8b 10                	mov    (%eax),%edx
  8005ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005cd:	89 08                	mov    %ecx,(%eax)
  8005cf:	8b 02                	mov    (%edx),%eax
  8005d1:	8b 52 04             	mov    0x4(%edx),%edx
  8005d4:	eb 22                	jmp    8005f8 <getuint+0x38>
	else if (lflag)
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	74 10                	je     8005ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005df:	89 08                	mov    %ecx,(%eax)
  8005e1:	8b 02                	mov    (%edx),%eax
  8005e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e8:	eb 0e                	jmp    8005f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ef:	89 08                	mov    %ecx,(%eax)
  8005f1:	8b 02                	mov    (%edx),%eax
  8005f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005f8:	5d                   	pop    %ebp
  8005f9:	c3                   	ret    

008005fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005fa:	55                   	push   %ebp
  8005fb:	89 e5                	mov    %esp,%ebp
  8005fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800600:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800604:	8b 10                	mov    (%eax),%edx
  800606:	3b 50 04             	cmp    0x4(%eax),%edx
  800609:	73 0a                	jae    800615 <sprintputch+0x1b>
		*b->buf++ = ch;
  80060b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80060e:	89 08                	mov    %ecx,(%eax)
  800610:	8b 45 08             	mov    0x8(%ebp),%eax
  800613:	88 02                	mov    %al,(%edx)
}
  800615:	5d                   	pop    %ebp
  800616:	c3                   	ret    

00800617 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800617:	55                   	push   %ebp
  800618:	89 e5                	mov    %esp,%ebp
  80061a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80061d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800620:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800624:	8b 45 10             	mov    0x10(%ebp),%eax
  800627:	89 44 24 08          	mov    %eax,0x8(%esp)
  80062b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800632:	8b 45 08             	mov    0x8(%ebp),%eax
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	e8 02 00 00 00       	call   80063f <vprintfmt>
	va_end(ap);
}
  80063d:	c9                   	leave  
  80063e:	c3                   	ret    

0080063f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	57                   	push   %edi
  800643:	56                   	push   %esi
  800644:	53                   	push   %ebx
  800645:	83 ec 3c             	sub    $0x3c,%esp
  800648:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80064b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80064e:	eb 14                	jmp    800664 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800650:	85 c0                	test   %eax,%eax
  800652:	0f 84 b3 03 00 00    	je     800a0b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800658:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800662:	89 f3                	mov    %esi,%ebx
  800664:	8d 73 01             	lea    0x1(%ebx),%esi
  800667:	0f b6 03             	movzbl (%ebx),%eax
  80066a:	83 f8 25             	cmp    $0x25,%eax
  80066d:	75 e1                	jne    800650 <vprintfmt+0x11>
  80066f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800673:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80067a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800681:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800688:	ba 00 00 00 00       	mov    $0x0,%edx
  80068d:	eb 1d                	jmp    8006ac <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800691:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800695:	eb 15                	jmp    8006ac <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800699:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80069d:	eb 0d                	jmp    8006ac <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80069f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006a5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ac:	8d 5e 01             	lea    0x1(%esi),%ebx
  8006af:	0f b6 0e             	movzbl (%esi),%ecx
  8006b2:	0f b6 c1             	movzbl %cl,%eax
  8006b5:	83 e9 23             	sub    $0x23,%ecx
  8006b8:	80 f9 55             	cmp    $0x55,%cl
  8006bb:	0f 87 2a 03 00 00    	ja     8009eb <vprintfmt+0x3ac>
  8006c1:	0f b6 c9             	movzbl %cl,%ecx
  8006c4:	ff 24 8d 20 19 80 00 	jmp    *0x801920(,%ecx,4)
  8006cb:	89 de                	mov    %ebx,%esi
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006d2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006d5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006d9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006dc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006df:	83 fb 09             	cmp    $0x9,%ebx
  8006e2:	77 36                	ja     80071a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006e4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006e7:	eb e9                	jmp    8006d2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ef:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006f9:	eb 22                	jmp    80071d <vprintfmt+0xde>
  8006fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006fe:	85 c9                	test   %ecx,%ecx
  800700:	b8 00 00 00 00       	mov    $0x0,%eax
  800705:	0f 49 c1             	cmovns %ecx,%eax
  800708:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070b:	89 de                	mov    %ebx,%esi
  80070d:	eb 9d                	jmp    8006ac <vprintfmt+0x6d>
  80070f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800711:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800718:	eb 92                	jmp    8006ac <vprintfmt+0x6d>
  80071a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80071d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800721:	79 89                	jns    8006ac <vprintfmt+0x6d>
  800723:	e9 77 ff ff ff       	jmp    80069f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800728:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80072d:	e9 7a ff ff ff       	jmp    8006ac <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8d 50 04             	lea    0x4(%eax),%edx
  800738:	89 55 14             	mov    %edx,0x14(%ebp)
  80073b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	89 04 24             	mov    %eax,(%esp)
  800744:	ff 55 08             	call   *0x8(%ebp)
			break;
  800747:	e9 18 ff ff ff       	jmp    800664 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8d 50 04             	lea    0x4(%eax),%edx
  800752:	89 55 14             	mov    %edx,0x14(%ebp)
  800755:	8b 00                	mov    (%eax),%eax
  800757:	99                   	cltd   
  800758:	31 d0                	xor    %edx,%eax
  80075a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80075c:	83 f8 09             	cmp    $0x9,%eax
  80075f:	7f 0b                	jg     80076c <vprintfmt+0x12d>
  800761:	8b 14 85 e0 1b 80 00 	mov    0x801be0(,%eax,4),%edx
  800768:	85 d2                	test   %edx,%edx
  80076a:	75 20                	jne    80078c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80076c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800770:	c7 44 24 08 74 18 80 	movl   $0x801874,0x8(%esp)
  800777:	00 
  800778:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	89 04 24             	mov    %eax,(%esp)
  800782:	e8 90 fe ff ff       	call   800617 <printfmt>
  800787:	e9 d8 fe ff ff       	jmp    800664 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80078c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800790:	c7 44 24 08 7d 18 80 	movl   $0x80187d,0x8(%esp)
  800797:	00 
  800798:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	89 04 24             	mov    %eax,(%esp)
  8007a2:	e8 70 fe ff ff       	call   800617 <printfmt>
  8007a7:	e9 b8 fe ff ff       	jmp    800664 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ac:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8d 50 04             	lea    0x4(%eax),%edx
  8007bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007be:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8007c0:	85 f6                	test   %esi,%esi
  8007c2:	b8 6d 18 80 00       	mov    $0x80186d,%eax
  8007c7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007ca:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007ce:	0f 84 97 00 00 00    	je     80086b <vprintfmt+0x22c>
  8007d4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007d8:	0f 8e 9b 00 00 00    	jle    800879 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e2:	89 34 24             	mov    %esi,(%esp)
  8007e5:	e8 ce 06 00 00       	call   800eb8 <strnlen>
  8007ea:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007ed:	29 c2                	sub    %eax,%edx
  8007ef:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8007f2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007f6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007f9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800802:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800804:	eb 0f                	jmp    800815 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800806:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80080a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80080d:	89 04 24             	mov    %eax,(%esp)
  800810:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800812:	83 eb 01             	sub    $0x1,%ebx
  800815:	85 db                	test   %ebx,%ebx
  800817:	7f ed                	jg     800806 <vprintfmt+0x1c7>
  800819:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80081c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	0f 49 c2             	cmovns %edx,%eax
  800829:	29 c2                	sub    %eax,%edx
  80082b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80082e:	89 d7                	mov    %edx,%edi
  800830:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800833:	eb 50                	jmp    800885 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800835:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800839:	74 1e                	je     800859 <vprintfmt+0x21a>
  80083b:	0f be d2             	movsbl %dl,%edx
  80083e:	83 ea 20             	sub    $0x20,%edx
  800841:	83 fa 5e             	cmp    $0x5e,%edx
  800844:	76 13                	jbe    800859 <vprintfmt+0x21a>
					putch('?', putdat);
  800846:	8b 45 0c             	mov    0xc(%ebp),%eax
  800849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800854:	ff 55 08             	call   *0x8(%ebp)
  800857:	eb 0d                	jmp    800866 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800866:	83 ef 01             	sub    $0x1,%edi
  800869:	eb 1a                	jmp    800885 <vprintfmt+0x246>
  80086b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80086e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800871:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800874:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800877:	eb 0c                	jmp    800885 <vprintfmt+0x246>
  800879:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80087c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80087f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800882:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800885:	83 c6 01             	add    $0x1,%esi
  800888:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80088c:	0f be c2             	movsbl %dl,%eax
  80088f:	85 c0                	test   %eax,%eax
  800891:	74 27                	je     8008ba <vprintfmt+0x27b>
  800893:	85 db                	test   %ebx,%ebx
  800895:	78 9e                	js     800835 <vprintfmt+0x1f6>
  800897:	83 eb 01             	sub    $0x1,%ebx
  80089a:	79 99                	jns    800835 <vprintfmt+0x1f6>
  80089c:	89 f8                	mov    %edi,%eax
  80089e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	89 c3                	mov    %eax,%ebx
  8008a6:	eb 1a                	jmp    8008c2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ac:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008b3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008b5:	83 eb 01             	sub    $0x1,%ebx
  8008b8:	eb 08                	jmp    8008c2 <vprintfmt+0x283>
  8008ba:	89 fb                	mov    %edi,%ebx
  8008bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bf:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008c2:	85 db                	test   %ebx,%ebx
  8008c4:	7f e2                	jg     8008a8 <vprintfmt+0x269>
  8008c6:	89 75 08             	mov    %esi,0x8(%ebp)
  8008c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008cc:	e9 93 fd ff ff       	jmp    800664 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d1:	83 fa 01             	cmp    $0x1,%edx
  8008d4:	7e 16                	jle    8008ec <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8d 50 08             	lea    0x8(%eax),%edx
  8008dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008df:	8b 50 04             	mov    0x4(%eax),%edx
  8008e2:	8b 00                	mov    (%eax),%eax
  8008e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008e7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008ea:	eb 32                	jmp    80091e <vprintfmt+0x2df>
	else if (lflag)
  8008ec:	85 d2                	test   %edx,%edx
  8008ee:	74 18                	je     800908 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8008f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f3:	8d 50 04             	lea    0x4(%eax),%edx
  8008f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f9:	8b 30                	mov    (%eax),%esi
  8008fb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008fe:	89 f0                	mov    %esi,%eax
  800900:	c1 f8 1f             	sar    $0x1f,%eax
  800903:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800906:	eb 16                	jmp    80091e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8d 50 04             	lea    0x4(%eax),%edx
  80090e:	89 55 14             	mov    %edx,0x14(%ebp)
  800911:	8b 30                	mov    (%eax),%esi
  800913:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800916:	89 f0                	mov    %esi,%eax
  800918:	c1 f8 1f             	sar    $0x1f,%eax
  80091b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80091e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800921:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800924:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800929:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80092d:	0f 89 80 00 00 00    	jns    8009b3 <vprintfmt+0x374>
				putch('-', putdat);
  800933:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800937:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80093e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800941:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800944:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800947:	f7 d8                	neg    %eax
  800949:	83 d2 00             	adc    $0x0,%edx
  80094c:	f7 da                	neg    %edx
			}
			base = 10;
  80094e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800953:	eb 5e                	jmp    8009b3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800955:	8d 45 14             	lea    0x14(%ebp),%eax
  800958:	e8 63 fc ff ff       	call   8005c0 <getuint>
			base = 10;
  80095d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800962:	eb 4f                	jmp    8009b3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800964:	8d 45 14             	lea    0x14(%ebp),%eax
  800967:	e8 54 fc ff ff       	call   8005c0 <getuint>
			base = 8 ;
  80096c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800971:	eb 40                	jmp    8009b3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800973:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800977:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80097e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800981:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800985:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80098c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800998:	8b 00                	mov    (%eax),%eax
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80099f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8009a4:	eb 0d                	jmp    8009b3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a9:	e8 12 fc ff ff       	call   8005c0 <getuint>
			base = 16;
  8009ae:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009b3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8009b7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8009bb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009be:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8009c2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009c6:	89 04 24             	mov    %eax,(%esp)
  8009c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009cd:	89 fa                	mov    %edi,%edx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	e8 f9 f9 ff ff       	call   8003d0 <printnum>
			break;
  8009d7:	e9 88 fc ff ff       	jmp    800664 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009e0:	89 04 24             	mov    %eax,(%esp)
  8009e3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009e6:	e9 79 fc ff ff       	jmp    800664 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ef:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009f6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009f9:	89 f3                	mov    %esi,%ebx
  8009fb:	eb 03                	jmp    800a00 <vprintfmt+0x3c1>
  8009fd:	83 eb 01             	sub    $0x1,%ebx
  800a00:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800a04:	75 f7                	jne    8009fd <vprintfmt+0x3be>
  800a06:	e9 59 fc ff ff       	jmp    800664 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a0b:	83 c4 3c             	add    $0x3c,%esp
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	83 ec 3c             	sub    $0x3c,%esp
  800a1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  800a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a22:	8d 50 04             	lea    0x4(%eax),%edx
  800a25:	89 55 14             	mov    %edx,0x14(%ebp)
  800a28:	8b 00                	mov    (%eax),%eax
  800a2a:	c1 e0 08             	shl    $0x8,%eax
  800a2d:	0f b7 c0             	movzwl %ax,%eax
  800a30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800a33:	83 c8 25             	or     $0x25,%eax
  800a36:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800a39:	eb 1a                	jmp    800a55 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a3b:	85 c0                	test   %eax,%eax
  800a3d:	0f 84 a9 03 00 00    	je     800dec <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800a43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a4d:	89 04 24             	mov    %eax,(%esp)
  800a50:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a53:	89 fb                	mov    %edi,%ebx
  800a55:	8d 7b 01             	lea    0x1(%ebx),%edi
  800a58:	0f b6 03             	movzbl (%ebx),%eax
  800a5b:	83 f8 25             	cmp    $0x25,%eax
  800a5e:	75 db                	jne    800a3b <cvprintfmt+0x28>
  800a60:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800a64:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800a6b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800a70:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800a77:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7c:	eb 18                	jmp    800a96 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a80:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800a84:	eb 10                	jmp    800a96 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a86:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a88:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800a8c:	eb 08                	jmp    800a96 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a8e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800a91:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a96:	8d 5f 01             	lea    0x1(%edi),%ebx
  800a99:	0f b6 0f             	movzbl (%edi),%ecx
  800a9c:	0f b6 c1             	movzbl %cl,%eax
  800a9f:	83 e9 23             	sub    $0x23,%ecx
  800aa2:	80 f9 55             	cmp    $0x55,%cl
  800aa5:	0f 87 1f 03 00 00    	ja     800dca <cvprintfmt+0x3b7>
  800aab:	0f b6 c9             	movzbl %cl,%ecx
  800aae:	ff 24 8d 78 1a 80 00 	jmp    *0x801a78(,%ecx,4)
  800ab5:	89 df                	mov    %ebx,%edi
  800ab7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800abc:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  800abf:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800ac3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800ac6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800ac9:	83 f9 09             	cmp    $0x9,%ecx
  800acc:	77 33                	ja     800b01 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ace:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ad1:	eb e9                	jmp    800abc <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ad3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad6:	8d 48 04             	lea    0x4(%eax),%ecx
  800ad9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800adc:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ade:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ae0:	eb 1f                	jmp    800b01 <cvprintfmt+0xee>
  800ae2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ae5:	85 ff                	test   %edi,%edi
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	0f 49 c7             	cmovns %edi,%eax
  800aef:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af2:	89 df                	mov    %ebx,%edi
  800af4:	eb a0                	jmp    800a96 <cvprintfmt+0x83>
  800af6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800af8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800aff:	eb 95                	jmp    800a96 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800b01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b05:	79 8f                	jns    800a96 <cvprintfmt+0x83>
  800b07:	eb 85                	jmp    800a8e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b09:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b0c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b0e:	66 90                	xchg   %ax,%ax
  800b10:	eb 84                	jmp    800a96 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800b12:	8b 45 14             	mov    0x14(%ebp),%eax
  800b15:	8d 50 04             	lea    0x4(%eax),%edx
  800b18:	89 55 14             	mov    %edx,0x14(%ebp)
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b25:	0b 10                	or     (%eax),%edx
  800b27:	89 14 24             	mov    %edx,(%esp)
  800b2a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b2d:	e9 23 ff ff ff       	jmp    800a55 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b32:	8b 45 14             	mov    0x14(%ebp),%eax
  800b35:	8d 50 04             	lea    0x4(%eax),%edx
  800b38:	89 55 14             	mov    %edx,0x14(%ebp)
  800b3b:	8b 00                	mov    (%eax),%eax
  800b3d:	99                   	cltd   
  800b3e:	31 d0                	xor    %edx,%eax
  800b40:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b42:	83 f8 09             	cmp    $0x9,%eax
  800b45:	7f 0b                	jg     800b52 <cvprintfmt+0x13f>
  800b47:	8b 14 85 e0 1b 80 00 	mov    0x801be0(,%eax,4),%edx
  800b4e:	85 d2                	test   %edx,%edx
  800b50:	75 23                	jne    800b75 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800b52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b56:	c7 44 24 08 74 18 80 	movl   $0x801874,0x8(%esp)
  800b5d:	00 
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	89 04 24             	mov    %eax,(%esp)
  800b6b:	e8 a7 fa ff ff       	call   800617 <printfmt>
  800b70:	e9 e0 fe ff ff       	jmp    800a55 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800b75:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b79:	c7 44 24 08 7d 18 80 	movl   $0x80187d,0x8(%esp)
  800b80:	00 
  800b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	89 04 24             	mov    %eax,(%esp)
  800b8e:	e8 84 fa ff ff       	call   800617 <printfmt>
  800b93:	e9 bd fe ff ff       	jmp    800a55 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b98:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b9b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800b9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba1:	8d 48 04             	lea    0x4(%eax),%ecx
  800ba4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800ba7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800ba9:	85 ff                	test   %edi,%edi
  800bab:	b8 6d 18 80 00       	mov    $0x80186d,%eax
  800bb0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800bb3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800bb7:	74 61                	je     800c1a <cvprintfmt+0x207>
  800bb9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800bbd:	7e 5b                	jle    800c1a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bbf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bc3:	89 3c 24             	mov    %edi,(%esp)
  800bc6:	e8 ed 02 00 00       	call   800eb8 <strnlen>
  800bcb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800bce:	29 c2                	sub    %eax,%edx
  800bd0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800bd3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800bd7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800bda:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800bdd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800be0:	8b 75 08             	mov    0x8(%ebp),%esi
  800be3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bea:	eb 0f                	jmp    800bfb <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800bec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf3:	89 3c 24             	mov    %edi,(%esp)
  800bf6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bf8:	83 eb 01             	sub    $0x1,%ebx
  800bfb:	85 db                	test   %ebx,%ebx
  800bfd:	7f ed                	jg     800bec <cvprintfmt+0x1d9>
  800bff:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800c02:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c0b:	85 d2                	test   %edx,%edx
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c12:	0f 49 c2             	cmovns %edx,%eax
  800c15:	29 c2                	sub    %eax,%edx
  800c17:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800c1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c1d:	83 c8 3f             	or     $0x3f,%eax
  800c20:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c23:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c26:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c29:	eb 36                	jmp    800c61 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c2f:	74 1d                	je     800c4e <cvprintfmt+0x23b>
  800c31:	0f be d2             	movsbl %dl,%edx
  800c34:	83 ea 20             	sub    $0x20,%edx
  800c37:	83 fa 5e             	cmp    $0x5e,%edx
  800c3a:	76 12                	jbe    800c4e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c43:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c46:	89 04 24             	mov    %eax,(%esp)
  800c49:	ff 55 08             	call   *0x8(%ebp)
  800c4c:	eb 10                	jmp    800c5e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c51:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c55:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800c58:	89 04 24             	mov    %eax,(%esp)
  800c5b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c5e:	83 eb 01             	sub    $0x1,%ebx
  800c61:	83 c7 01             	add    $0x1,%edi
  800c64:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800c68:	0f be c2             	movsbl %dl,%eax
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	74 27                	je     800c96 <cvprintfmt+0x283>
  800c6f:	85 f6                	test   %esi,%esi
  800c71:	78 b8                	js     800c2b <cvprintfmt+0x218>
  800c73:	83 ee 01             	sub    $0x1,%esi
  800c76:	79 b3                	jns    800c2b <cvprintfmt+0x218>
  800c78:	89 d8                	mov    %ebx,%eax
  800c7a:	8b 75 08             	mov    0x8(%ebp),%esi
  800c7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c80:	89 c3                	mov    %eax,%ebx
  800c82:	eb 18                	jmp    800c9c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800c84:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c8f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800c91:	83 eb 01             	sub    $0x1,%ebx
  800c94:	eb 06                	jmp    800c9c <cvprintfmt+0x289>
  800c96:	8b 75 08             	mov    0x8(%ebp),%esi
  800c99:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c9c:	85 db                	test   %ebx,%ebx
  800c9e:	7f e4                	jg     800c84 <cvprintfmt+0x271>
  800ca0:	89 75 08             	mov    %esi,0x8(%ebp)
  800ca3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ca6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca9:	e9 a7 fd ff ff       	jmp    800a55 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800cae:	83 fa 01             	cmp    $0x1,%edx
  800cb1:	7e 10                	jle    800cc3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800cb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb6:	8d 50 08             	lea    0x8(%eax),%edx
  800cb9:	89 55 14             	mov    %edx,0x14(%ebp)
  800cbc:	8b 30                	mov    (%eax),%esi
  800cbe:	8b 78 04             	mov    0x4(%eax),%edi
  800cc1:	eb 26                	jmp    800ce9 <cvprintfmt+0x2d6>
	else if (lflag)
  800cc3:	85 d2                	test   %edx,%edx
  800cc5:	74 12                	je     800cd9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800cc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cca:	8d 50 04             	lea    0x4(%eax),%edx
  800ccd:	89 55 14             	mov    %edx,0x14(%ebp)
  800cd0:	8b 30                	mov    (%eax),%esi
  800cd2:	89 f7                	mov    %esi,%edi
  800cd4:	c1 ff 1f             	sar    $0x1f,%edi
  800cd7:	eb 10                	jmp    800ce9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800cd9:	8b 45 14             	mov    0x14(%ebp),%eax
  800cdc:	8d 50 04             	lea    0x4(%eax),%edx
  800cdf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ce2:	8b 30                	mov    (%eax),%esi
  800ce4:	89 f7                	mov    %esi,%edi
  800ce6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ce9:	89 f0                	mov    %esi,%eax
  800ceb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ced:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cf2:	85 ff                	test   %edi,%edi
  800cf4:	0f 89 8e 00 00 00    	jns    800d88 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d04:	83 c8 2d             	or     $0x2d,%eax
  800d07:	89 04 24             	mov    %eax,(%esp)
  800d0a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800d0d:	89 f0                	mov    %esi,%eax
  800d0f:	89 fa                	mov    %edi,%edx
  800d11:	f7 d8                	neg    %eax
  800d13:	83 d2 00             	adc    $0x0,%edx
  800d16:	f7 da                	neg    %edx
			}
			base = 10;
  800d18:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800d1d:	eb 69                	jmp    800d88 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800d1f:	8d 45 14             	lea    0x14(%ebp),%eax
  800d22:	e8 99 f8 ff ff       	call   8005c0 <getuint>
			base = 10;
  800d27:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800d2c:	eb 5a                	jmp    800d88 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800d2e:	8d 45 14             	lea    0x14(%ebp),%eax
  800d31:	e8 8a f8 ff ff       	call   8005c0 <getuint>
			base = 8 ;
  800d36:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800d3b:	eb 4b                	jmp    800d88 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d44:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800d47:	89 f0                	mov    %esi,%eax
  800d49:	83 c8 30             	or     $0x30,%eax
  800d4c:	89 04 24             	mov    %eax,(%esp)
  800d4f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d59:	89 f0                	mov    %esi,%eax
  800d5b:	83 c8 78             	or     $0x78,%eax
  800d5e:	89 04 24             	mov    %eax,(%esp)
  800d61:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d64:	8b 45 14             	mov    0x14(%ebp),%eax
  800d67:	8d 50 04             	lea    0x4(%eax),%edx
  800d6a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800d6d:	8b 00                	mov    (%eax),%eax
  800d6f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d74:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800d79:	eb 0d                	jmp    800d88 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d7b:	8d 45 14             	lea    0x14(%ebp),%eax
  800d7e:	e8 3d f8 ff ff       	call   8005c0 <getuint>
			base = 16;
  800d83:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800d88:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800d8c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d90:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800d93:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d97:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d9b:	89 04 24             	mov    %eax,(%esp)
  800d9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dab:	e8 0f f7 ff ff       	call   8004bf <cprintnum>
			break;
  800db0:	e9 a0 fc ff ff       	jmp    800a55 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800db5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dbc:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800dbf:	89 04 24             	mov    %eax,(%esp)
  800dc2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800dc5:	e9 8b fc ff ff       	jmp    800a55 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800dca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800dd4:	89 04 24             	mov    %eax,(%esp)
  800dd7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800dda:	89 fb                	mov    %edi,%ebx
  800ddc:	eb 03                	jmp    800de1 <cvprintfmt+0x3ce>
  800dde:	83 eb 01             	sub    $0x1,%ebx
  800de1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800de5:	75 f7                	jne    800dde <cvprintfmt+0x3cb>
  800de7:	e9 69 fc ff ff       	jmp    800a55 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800dec:	83 c4 3c             	add    $0x3c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800dfa:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e01:	8b 45 10             	mov    0x10(%ebp),%eax
  800e04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	89 04 24             	mov    %eax,(%esp)
  800e15:	e8 f9 fb ff ff       	call   800a13 <cvprintfmt>
	va_end(ap);
}
  800e1a:	c9                   	leave  
  800e1b:	c3                   	ret    

00800e1c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 28             	sub    $0x28,%esp
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e28:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e2b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e2f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	74 30                	je     800e6d <vsnprintf+0x51>
  800e3d:	85 d2                	test   %edx,%edx
  800e3f:	7e 2c                	jle    800e6d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e41:	8b 45 14             	mov    0x14(%ebp),%eax
  800e44:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e48:	8b 45 10             	mov    0x10(%ebp),%eax
  800e4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e56:	c7 04 24 fa 05 80 00 	movl   $0x8005fa,(%esp)
  800e5d:	e8 dd f7 ff ff       	call   80063f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e65:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6b:	eb 05                	jmp    800e72 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e7a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e81:	8b 45 10             	mov    0x10(%ebp),%eax
  800e84:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e92:	89 04 24             	mov    %eax,(%esp)
  800e95:	e8 82 ff ff ff       	call   800e1c <vsnprintf>
	va_end(ap);

	return rc;
}
  800e9a:	c9                   	leave  
  800e9b:	c3                   	ret    
  800e9c:	66 90                	xchg   %ax,%ax
  800e9e:	66 90                	xchg   %ax,%ax

00800ea0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eab:	eb 03                	jmp    800eb0 <strlen+0x10>
		n++;
  800ead:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800eb0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800eb4:	75 f7                	jne    800ead <strlen+0xd>
		n++;
	return n;
}
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	eb 03                	jmp    800ecb <strnlen+0x13>
		n++;
  800ec8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ecb:	39 d0                	cmp    %edx,%eax
  800ecd:	74 06                	je     800ed5 <strnlen+0x1d>
  800ecf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ed3:	75 f3                	jne    800ec8 <strnlen+0x10>
		n++;
	return n;
}
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	53                   	push   %ebx
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ee1:	89 c2                	mov    %eax,%edx
  800ee3:	83 c2 01             	add    $0x1,%edx
  800ee6:	83 c1 01             	add    $0x1,%ecx
  800ee9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800eed:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ef0:	84 db                	test   %bl,%bl
  800ef2:	75 ef                	jne    800ee3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ef4:	5b                   	pop    %ebx
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	53                   	push   %ebx
  800efb:	83 ec 08             	sub    $0x8,%esp
  800efe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f01:	89 1c 24             	mov    %ebx,(%esp)
  800f04:	e8 97 ff ff ff       	call   800ea0 <strlen>
	strcpy(dst + len, src);
  800f09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f10:	01 d8                	add    %ebx,%eax
  800f12:	89 04 24             	mov    %eax,(%esp)
  800f15:	e8 bd ff ff ff       	call   800ed7 <strcpy>
	return dst;
}
  800f1a:	89 d8                	mov    %ebx,%eax
  800f1c:	83 c4 08             	add    $0x8,%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2d:	89 f3                	mov    %esi,%ebx
  800f2f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	eb 0f                	jmp    800f45 <strncpy+0x23>
		*dst++ = *src;
  800f36:	83 c2 01             	add    $0x1,%edx
  800f39:	0f b6 01             	movzbl (%ecx),%eax
  800f3c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f3f:	80 39 01             	cmpb   $0x1,(%ecx)
  800f42:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f45:	39 da                	cmp    %ebx,%edx
  800f47:	75 ed                	jne    800f36 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800f49:	89 f0                	mov    %esi,%eax
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	8b 75 08             	mov    0x8(%ebp),%esi
  800f57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f5d:	89 f0                	mov    %esi,%eax
  800f5f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f63:	85 c9                	test   %ecx,%ecx
  800f65:	75 0b                	jne    800f72 <strlcpy+0x23>
  800f67:	eb 1d                	jmp    800f86 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f69:	83 c0 01             	add    $0x1,%eax
  800f6c:	83 c2 01             	add    $0x1,%edx
  800f6f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f72:	39 d8                	cmp    %ebx,%eax
  800f74:	74 0b                	je     800f81 <strlcpy+0x32>
  800f76:	0f b6 0a             	movzbl (%edx),%ecx
  800f79:	84 c9                	test   %cl,%cl
  800f7b:	75 ec                	jne    800f69 <strlcpy+0x1a>
  800f7d:	89 c2                	mov    %eax,%edx
  800f7f:	eb 02                	jmp    800f83 <strlcpy+0x34>
  800f81:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800f83:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800f86:	29 f0                	sub    %esi,%eax
}
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f92:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f95:	eb 06                	jmp    800f9d <strcmp+0x11>
		p++, q++;
  800f97:	83 c1 01             	add    $0x1,%ecx
  800f9a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f9d:	0f b6 01             	movzbl (%ecx),%eax
  800fa0:	84 c0                	test   %al,%al
  800fa2:	74 04                	je     800fa8 <strcmp+0x1c>
  800fa4:	3a 02                	cmp    (%edx),%al
  800fa6:	74 ef                	je     800f97 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fa8:	0f b6 c0             	movzbl %al,%eax
  800fab:	0f b6 12             	movzbl (%edx),%edx
  800fae:	29 d0                	sub    %edx,%eax
}
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	53                   	push   %ebx
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbc:	89 c3                	mov    %eax,%ebx
  800fbe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800fc1:	eb 06                	jmp    800fc9 <strncmp+0x17>
		n--, p++, q++;
  800fc3:	83 c0 01             	add    $0x1,%eax
  800fc6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800fc9:	39 d8                	cmp    %ebx,%eax
  800fcb:	74 15                	je     800fe2 <strncmp+0x30>
  800fcd:	0f b6 08             	movzbl (%eax),%ecx
  800fd0:	84 c9                	test   %cl,%cl
  800fd2:	74 04                	je     800fd8 <strncmp+0x26>
  800fd4:	3a 0a                	cmp    (%edx),%cl
  800fd6:	74 eb                	je     800fc3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fd8:	0f b6 00             	movzbl (%eax),%eax
  800fdb:	0f b6 12             	movzbl (%edx),%edx
  800fde:	29 d0                	sub    %edx,%eax
  800fe0:	eb 05                	jmp    800fe7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800fe7:	5b                   	pop    %ebx
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ff4:	eb 07                	jmp    800ffd <strchr+0x13>
		if (*s == c)
  800ff6:	38 ca                	cmp    %cl,%dl
  800ff8:	74 0f                	je     801009 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ffa:	83 c0 01             	add    $0x1,%eax
  800ffd:	0f b6 10             	movzbl (%eax),%edx
  801000:	84 d2                	test   %dl,%dl
  801002:	75 f2                	jne    800ff6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801004:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	8b 45 08             	mov    0x8(%ebp),%eax
  801011:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801015:	eb 07                	jmp    80101e <strfind+0x13>
		if (*s == c)
  801017:	38 ca                	cmp    %cl,%dl
  801019:	74 0a                	je     801025 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80101b:	83 c0 01             	add    $0x1,%eax
  80101e:	0f b6 10             	movzbl (%eax),%edx
  801021:	84 d2                	test   %dl,%dl
  801023:	75 f2                	jne    801017 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801030:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801033:	85 c9                	test   %ecx,%ecx
  801035:	74 36                	je     80106d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801037:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80103d:	75 28                	jne    801067 <memset+0x40>
  80103f:	f6 c1 03             	test   $0x3,%cl
  801042:	75 23                	jne    801067 <memset+0x40>
		c &= 0xFF;
  801044:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801048:	89 d3                	mov    %edx,%ebx
  80104a:	c1 e3 08             	shl    $0x8,%ebx
  80104d:	89 d6                	mov    %edx,%esi
  80104f:	c1 e6 18             	shl    $0x18,%esi
  801052:	89 d0                	mov    %edx,%eax
  801054:	c1 e0 10             	shl    $0x10,%eax
  801057:	09 f0                	or     %esi,%eax
  801059:	09 c2                	or     %eax,%edx
  80105b:	89 d0                	mov    %edx,%eax
  80105d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80105f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801062:	fc                   	cld    
  801063:	f3 ab                	rep stos %eax,%es:(%edi)
  801065:	eb 06                	jmp    80106d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801067:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106a:	fc                   	cld    
  80106b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80106d:	89 f8                	mov    %edi,%eax
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	8b 45 08             	mov    0x8(%ebp),%eax
  80107c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80107f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801082:	39 c6                	cmp    %eax,%esi
  801084:	73 35                	jae    8010bb <memmove+0x47>
  801086:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801089:	39 d0                	cmp    %edx,%eax
  80108b:	73 2e                	jae    8010bb <memmove+0x47>
		s += n;
		d += n;
  80108d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801090:	89 d6                	mov    %edx,%esi
  801092:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801094:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80109a:	75 13                	jne    8010af <memmove+0x3b>
  80109c:	f6 c1 03             	test   $0x3,%cl
  80109f:	75 0e                	jne    8010af <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8010a1:	83 ef 04             	sub    $0x4,%edi
  8010a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8010a7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8010aa:	fd                   	std    
  8010ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010ad:	eb 09                	jmp    8010b8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8010af:	83 ef 01             	sub    $0x1,%edi
  8010b2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8010b5:	fd                   	std    
  8010b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8010b8:	fc                   	cld    
  8010b9:	eb 1d                	jmp    8010d8 <memmove+0x64>
  8010bb:	89 f2                	mov    %esi,%edx
  8010bd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010bf:	f6 c2 03             	test   $0x3,%dl
  8010c2:	75 0f                	jne    8010d3 <memmove+0x5f>
  8010c4:	f6 c1 03             	test   $0x3,%cl
  8010c7:	75 0a                	jne    8010d3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8010c9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8010cc:	89 c7                	mov    %eax,%edi
  8010ce:	fc                   	cld    
  8010cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010d1:	eb 05                	jmp    8010d8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8010d3:	89 c7                	mov    %eax,%edi
  8010d5:	fc                   	cld    
  8010d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8010e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	89 04 24             	mov    %eax,(%esp)
  8010f6:	e8 79 ff ff ff       	call   801074 <memmove>
}
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    

008010fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	8b 55 08             	mov    0x8(%ebp),%edx
  801105:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801108:	89 d6                	mov    %edx,%esi
  80110a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80110d:	eb 1a                	jmp    801129 <memcmp+0x2c>
		if (*s1 != *s2)
  80110f:	0f b6 02             	movzbl (%edx),%eax
  801112:	0f b6 19             	movzbl (%ecx),%ebx
  801115:	38 d8                	cmp    %bl,%al
  801117:	74 0a                	je     801123 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801119:	0f b6 c0             	movzbl %al,%eax
  80111c:	0f b6 db             	movzbl %bl,%ebx
  80111f:	29 d8                	sub    %ebx,%eax
  801121:	eb 0f                	jmp    801132 <memcmp+0x35>
		s1++, s2++;
  801123:	83 c2 01             	add    $0x1,%edx
  801126:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801129:	39 f2                	cmp    %esi,%edx
  80112b:	75 e2                	jne    80110f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80113f:	89 c2                	mov    %eax,%edx
  801141:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801144:	eb 07                	jmp    80114d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801146:	38 08                	cmp    %cl,(%eax)
  801148:	74 07                	je     801151 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80114a:	83 c0 01             	add    $0x1,%eax
  80114d:	39 d0                	cmp    %edx,%eax
  80114f:	72 f5                	jb     801146 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80115f:	eb 03                	jmp    801164 <strtol+0x11>
		s++;
  801161:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801164:	0f b6 0a             	movzbl (%edx),%ecx
  801167:	80 f9 09             	cmp    $0x9,%cl
  80116a:	74 f5                	je     801161 <strtol+0xe>
  80116c:	80 f9 20             	cmp    $0x20,%cl
  80116f:	74 f0                	je     801161 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801171:	80 f9 2b             	cmp    $0x2b,%cl
  801174:	75 0a                	jne    801180 <strtol+0x2d>
		s++;
  801176:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801179:	bf 00 00 00 00       	mov    $0x0,%edi
  80117e:	eb 11                	jmp    801191 <strtol+0x3e>
  801180:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801185:	80 f9 2d             	cmp    $0x2d,%cl
  801188:	75 07                	jne    801191 <strtol+0x3e>
		s++, neg = 1;
  80118a:	8d 52 01             	lea    0x1(%edx),%edx
  80118d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801191:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801196:	75 15                	jne    8011ad <strtol+0x5a>
  801198:	80 3a 30             	cmpb   $0x30,(%edx)
  80119b:	75 10                	jne    8011ad <strtol+0x5a>
  80119d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8011a1:	75 0a                	jne    8011ad <strtol+0x5a>
		s += 2, base = 16;
  8011a3:	83 c2 02             	add    $0x2,%edx
  8011a6:	b8 10 00 00 00       	mov    $0x10,%eax
  8011ab:	eb 10                	jmp    8011bd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	75 0c                	jne    8011bd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8011b1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8011b3:	80 3a 30             	cmpb   $0x30,(%edx)
  8011b6:	75 05                	jne    8011bd <strtol+0x6a>
		s++, base = 8;
  8011b8:	83 c2 01             	add    $0x1,%edx
  8011bb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  8011bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8011c5:	0f b6 0a             	movzbl (%edx),%ecx
  8011c8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8011cb:	89 f0                	mov    %esi,%eax
  8011cd:	3c 09                	cmp    $0x9,%al
  8011cf:	77 08                	ja     8011d9 <strtol+0x86>
			dig = *s - '0';
  8011d1:	0f be c9             	movsbl %cl,%ecx
  8011d4:	83 e9 30             	sub    $0x30,%ecx
  8011d7:	eb 20                	jmp    8011f9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8011d9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8011dc:	89 f0                	mov    %esi,%eax
  8011de:	3c 19                	cmp    $0x19,%al
  8011e0:	77 08                	ja     8011ea <strtol+0x97>
			dig = *s - 'a' + 10;
  8011e2:	0f be c9             	movsbl %cl,%ecx
  8011e5:	83 e9 57             	sub    $0x57,%ecx
  8011e8:	eb 0f                	jmp    8011f9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8011ea:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8011ed:	89 f0                	mov    %esi,%eax
  8011ef:	3c 19                	cmp    $0x19,%al
  8011f1:	77 16                	ja     801209 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8011f3:	0f be c9             	movsbl %cl,%ecx
  8011f6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8011f9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8011fc:	7d 0f                	jge    80120d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8011fe:	83 c2 01             	add    $0x1,%edx
  801201:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801205:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801207:	eb bc                	jmp    8011c5 <strtol+0x72>
  801209:	89 d8                	mov    %ebx,%eax
  80120b:	eb 02                	jmp    80120f <strtol+0xbc>
  80120d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80120f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801213:	74 05                	je     80121a <strtol+0xc7>
		*endptr = (char *) s;
  801215:	8b 75 0c             	mov    0xc(%ebp),%esi
  801218:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80121a:	f7 d8                	neg    %eax
  80121c:	85 ff                	test   %edi,%edi
  80121e:	0f 44 c3             	cmove  %ebx,%eax
}
  801221:	5b                   	pop    %ebx
  801222:	5e                   	pop    %esi
  801223:	5f                   	pop    %edi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	57                   	push   %edi
  80122a:	56                   	push   %esi
  80122b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122c:	b8 00 00 00 00       	mov    $0x0,%eax
  801231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801234:	8b 55 08             	mov    0x8(%ebp),%edx
  801237:	89 c3                	mov    %eax,%ebx
  801239:	89 c7                	mov    %eax,%edi
  80123b:	89 c6                	mov    %eax,%esi
  80123d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5f                   	pop    %edi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <sys_cgetc>:

int
sys_cgetc(void)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124a:	ba 00 00 00 00       	mov    $0x0,%edx
  80124f:	b8 01 00 00 00       	mov    $0x1,%eax
  801254:	89 d1                	mov    %edx,%ecx
  801256:	89 d3                	mov    %edx,%ebx
  801258:	89 d7                	mov    %edx,%edi
  80125a:	89 d6                	mov    %edx,%esi
  80125c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80125e:	5b                   	pop    %ebx
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	57                   	push   %edi
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80126c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801271:	b8 03 00 00 00       	mov    $0x3,%eax
  801276:	8b 55 08             	mov    0x8(%ebp),%edx
  801279:	89 cb                	mov    %ecx,%ebx
  80127b:	89 cf                	mov    %ecx,%edi
  80127d:	89 ce                	mov    %ecx,%esi
  80127f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801281:	85 c0                	test   %eax,%eax
  801283:	7e 28                	jle    8012ad <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801285:	89 44 24 10          	mov    %eax,0x10(%esp)
  801289:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801290:	00 
  801291:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  801298:	00 
  801299:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012a0:	00 
  8012a1:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  8012a8:	e8 04 f0 ff ff       	call   8002b1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8012ad:	83 c4 2c             	add    $0x2c,%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	57                   	push   %edi
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8012c5:	89 d1                	mov    %edx,%ecx
  8012c7:	89 d3                	mov    %edx,%ebx
  8012c9:	89 d7                	mov    %edx,%edi
  8012cb:	89 d6                	mov    %edx,%esi
  8012cd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	5f                   	pop    %edi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <sys_yield>:

void
sys_yield(void)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012da:	ba 00 00 00 00       	mov    $0x0,%edx
  8012df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012e4:	89 d1                	mov    %edx,%ecx
  8012e6:	89 d3                	mov    %edx,%ebx
  8012e8:	89 d7                	mov    %edx,%edi
  8012ea:	89 d6                	mov    %edx,%esi
  8012ec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012ee:	5b                   	pop    %ebx
  8012ef:	5e                   	pop    %esi
  8012f0:	5f                   	pop    %edi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	57                   	push   %edi
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012fc:	be 00 00 00 00       	mov    $0x0,%esi
  801301:	b8 04 00 00 00       	mov    $0x4,%eax
  801306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801309:	8b 55 08             	mov    0x8(%ebp),%edx
  80130c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80130f:	89 f7                	mov    %esi,%edi
  801311:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801313:	85 c0                	test   %eax,%eax
  801315:	7e 28                	jle    80133f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801317:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801322:	00 
  801323:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  80132a:	00 
  80132b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801332:	00 
  801333:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  80133a:	e8 72 ef ff ff       	call   8002b1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80133f:	83 c4 2c             	add    $0x2c,%esp
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5f                   	pop    %edi
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	57                   	push   %edi
  80134b:	56                   	push   %esi
  80134c:	53                   	push   %ebx
  80134d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801350:	b8 05 00 00 00       	mov    $0x5,%eax
  801355:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801358:	8b 55 08             	mov    0x8(%ebp),%edx
  80135b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80135e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801361:	8b 75 18             	mov    0x18(%ebp),%esi
  801364:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801366:	85 c0                	test   %eax,%eax
  801368:	7e 28                	jle    801392 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801375:	00 
  801376:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  80137d:	00 
  80137e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801385:	00 
  801386:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  80138d:	e8 1f ef ff ff       	call   8002b1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801392:	83 c4 2c             	add    $0x2c,%esp
  801395:	5b                   	pop    %ebx
  801396:	5e                   	pop    %esi
  801397:	5f                   	pop    %edi
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	57                   	push   %edi
  80139e:	56                   	push   %esi
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8013ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b3:	89 df                	mov    %ebx,%edi
  8013b5:	89 de                	mov    %ebx,%esi
  8013b7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	7e 28                	jle    8013e5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013c8:	00 
  8013c9:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  8013d0:	00 
  8013d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013d8:	00 
  8013d9:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  8013e0:	e8 cc ee ff ff       	call   8002b1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013e5:	83 c4 2c             	add    $0x2c,%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5f                   	pop    %edi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	57                   	push   %edi
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801400:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801403:	8b 55 08             	mov    0x8(%ebp),%edx
  801406:	89 df                	mov    %ebx,%edi
  801408:	89 de                	mov    %ebx,%esi
  80140a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80140c:	85 c0                	test   %eax,%eax
  80140e:	7e 28                	jle    801438 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801410:	89 44 24 10          	mov    %eax,0x10(%esp)
  801414:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80141b:	00 
  80141c:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  801423:	00 
  801424:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80142b:	00 
  80142c:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  801433:	e8 79 ee ff ff       	call   8002b1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801438:	83 c4 2c             	add    $0x2c,%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	5f                   	pop    %edi
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	57                   	push   %edi
  801444:	56                   	push   %esi
  801445:	53                   	push   %ebx
  801446:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801449:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144e:	b8 09 00 00 00       	mov    $0x9,%eax
  801453:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801456:	8b 55 08             	mov    0x8(%ebp),%edx
  801459:	89 df                	mov    %ebx,%edi
  80145b:	89 de                	mov    %ebx,%esi
  80145d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80145f:	85 c0                	test   %eax,%eax
  801461:	7e 28                	jle    80148b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801463:	89 44 24 10          	mov    %eax,0x10(%esp)
  801467:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80146e:	00 
  80146f:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  801476:	00 
  801477:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80147e:	00 
  80147f:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  801486:	e8 26 ee ff ff       	call   8002b1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80148b:	83 c4 2c             	add    $0x2c,%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5f                   	pop    %edi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	57                   	push   %edi
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801499:	be 00 00 00 00       	mov    $0x0,%esi
  80149e:	b8 0b 00 00 00       	mov    $0xb,%eax
  8014a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8014af:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8014b1:	5b                   	pop    %ebx
  8014b2:	5e                   	pop    %esi
  8014b3:	5f                   	pop    %edi
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	57                   	push   %edi
  8014ba:	56                   	push   %esi
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014c4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014cc:	89 cb                	mov    %ecx,%ebx
  8014ce:	89 cf                	mov    %ecx,%edi
  8014d0:	89 ce                	mov    %ecx,%esi
  8014d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	7e 28                	jle    801500 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014dc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8014e3:	00 
  8014e4:	c7 44 24 08 08 1c 80 	movl   $0x801c08,0x8(%esp)
  8014eb:	00 
  8014ec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014f3:	00 
  8014f4:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  8014fb:	e8 b1 ed ff ff       	call   8002b1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801500:	83 c4 2c             	add    $0x2c,%esp
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	5f                   	pop    %edi
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    
  801508:	66 90                	xchg   %ax,%ax
  80150a:	66 90                	xchg   %ax,%ax
  80150c:	66 90                	xchg   %ax,%ax
  80150e:	66 90                	xchg   %ax,%ax

00801510 <__udivdi3>:
  801510:	55                   	push   %ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	83 ec 0c             	sub    $0xc,%esp
  801516:	8b 44 24 28          	mov    0x28(%esp),%eax
  80151a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80151e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801522:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801526:	85 c0                	test   %eax,%eax
  801528:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80152c:	89 ea                	mov    %ebp,%edx
  80152e:	89 0c 24             	mov    %ecx,(%esp)
  801531:	75 2d                	jne    801560 <__udivdi3+0x50>
  801533:	39 e9                	cmp    %ebp,%ecx
  801535:	77 61                	ja     801598 <__udivdi3+0x88>
  801537:	85 c9                	test   %ecx,%ecx
  801539:	89 ce                	mov    %ecx,%esi
  80153b:	75 0b                	jne    801548 <__udivdi3+0x38>
  80153d:	b8 01 00 00 00       	mov    $0x1,%eax
  801542:	31 d2                	xor    %edx,%edx
  801544:	f7 f1                	div    %ecx
  801546:	89 c6                	mov    %eax,%esi
  801548:	31 d2                	xor    %edx,%edx
  80154a:	89 e8                	mov    %ebp,%eax
  80154c:	f7 f6                	div    %esi
  80154e:	89 c5                	mov    %eax,%ebp
  801550:	89 f8                	mov    %edi,%eax
  801552:	f7 f6                	div    %esi
  801554:	89 ea                	mov    %ebp,%edx
  801556:	83 c4 0c             	add    $0xc,%esp
  801559:	5e                   	pop    %esi
  80155a:	5f                   	pop    %edi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    
  80155d:	8d 76 00             	lea    0x0(%esi),%esi
  801560:	39 e8                	cmp    %ebp,%eax
  801562:	77 24                	ja     801588 <__udivdi3+0x78>
  801564:	0f bd e8             	bsr    %eax,%ebp
  801567:	83 f5 1f             	xor    $0x1f,%ebp
  80156a:	75 3c                	jne    8015a8 <__udivdi3+0x98>
  80156c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801570:	39 34 24             	cmp    %esi,(%esp)
  801573:	0f 86 9f 00 00 00    	jbe    801618 <__udivdi3+0x108>
  801579:	39 d0                	cmp    %edx,%eax
  80157b:	0f 82 97 00 00 00    	jb     801618 <__udivdi3+0x108>
  801581:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801588:	31 d2                	xor    %edx,%edx
  80158a:	31 c0                	xor    %eax,%eax
  80158c:	83 c4 0c             	add    $0xc,%esp
  80158f:	5e                   	pop    %esi
  801590:	5f                   	pop    %edi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    
  801593:	90                   	nop
  801594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801598:	89 f8                	mov    %edi,%eax
  80159a:	f7 f1                	div    %ecx
  80159c:	31 d2                	xor    %edx,%edx
  80159e:	83 c4 0c             	add    $0xc,%esp
  8015a1:	5e                   	pop    %esi
  8015a2:	5f                   	pop    %edi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    
  8015a5:	8d 76 00             	lea    0x0(%esi),%esi
  8015a8:	89 e9                	mov    %ebp,%ecx
  8015aa:	8b 3c 24             	mov    (%esp),%edi
  8015ad:	d3 e0                	shl    %cl,%eax
  8015af:	89 c6                	mov    %eax,%esi
  8015b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8015b6:	29 e8                	sub    %ebp,%eax
  8015b8:	89 c1                	mov    %eax,%ecx
  8015ba:	d3 ef                	shr    %cl,%edi
  8015bc:	89 e9                	mov    %ebp,%ecx
  8015be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8015c2:	8b 3c 24             	mov    (%esp),%edi
  8015c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8015c9:	89 d6                	mov    %edx,%esi
  8015cb:	d3 e7                	shl    %cl,%edi
  8015cd:	89 c1                	mov    %eax,%ecx
  8015cf:	89 3c 24             	mov    %edi,(%esp)
  8015d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015d6:	d3 ee                	shr    %cl,%esi
  8015d8:	89 e9                	mov    %ebp,%ecx
  8015da:	d3 e2                	shl    %cl,%edx
  8015dc:	89 c1                	mov    %eax,%ecx
  8015de:	d3 ef                	shr    %cl,%edi
  8015e0:	09 d7                	or     %edx,%edi
  8015e2:	89 f2                	mov    %esi,%edx
  8015e4:	89 f8                	mov    %edi,%eax
  8015e6:	f7 74 24 08          	divl   0x8(%esp)
  8015ea:	89 d6                	mov    %edx,%esi
  8015ec:	89 c7                	mov    %eax,%edi
  8015ee:	f7 24 24             	mull   (%esp)
  8015f1:	39 d6                	cmp    %edx,%esi
  8015f3:	89 14 24             	mov    %edx,(%esp)
  8015f6:	72 30                	jb     801628 <__udivdi3+0x118>
  8015f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015fc:	89 e9                	mov    %ebp,%ecx
  8015fe:	d3 e2                	shl    %cl,%edx
  801600:	39 c2                	cmp    %eax,%edx
  801602:	73 05                	jae    801609 <__udivdi3+0xf9>
  801604:	3b 34 24             	cmp    (%esp),%esi
  801607:	74 1f                	je     801628 <__udivdi3+0x118>
  801609:	89 f8                	mov    %edi,%eax
  80160b:	31 d2                	xor    %edx,%edx
  80160d:	e9 7a ff ff ff       	jmp    80158c <__udivdi3+0x7c>
  801612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801618:	31 d2                	xor    %edx,%edx
  80161a:	b8 01 00 00 00       	mov    $0x1,%eax
  80161f:	e9 68 ff ff ff       	jmp    80158c <__udivdi3+0x7c>
  801624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801628:	8d 47 ff             	lea    -0x1(%edi),%eax
  80162b:	31 d2                	xor    %edx,%edx
  80162d:	83 c4 0c             	add    $0xc,%esp
  801630:	5e                   	pop    %esi
  801631:	5f                   	pop    %edi
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    
  801634:	66 90                	xchg   %ax,%ax
  801636:	66 90                	xchg   %ax,%ax
  801638:	66 90                	xchg   %ax,%ax
  80163a:	66 90                	xchg   %ax,%ax
  80163c:	66 90                	xchg   %ax,%ax
  80163e:	66 90                	xchg   %ax,%ax

00801640 <__umoddi3>:
  801640:	55                   	push   %ebp
  801641:	57                   	push   %edi
  801642:	56                   	push   %esi
  801643:	83 ec 14             	sub    $0x14,%esp
  801646:	8b 44 24 28          	mov    0x28(%esp),%eax
  80164a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80164e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801652:	89 c7                	mov    %eax,%edi
  801654:	89 44 24 04          	mov    %eax,0x4(%esp)
  801658:	8b 44 24 30          	mov    0x30(%esp),%eax
  80165c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801660:	89 34 24             	mov    %esi,(%esp)
  801663:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801667:	85 c0                	test   %eax,%eax
  801669:	89 c2                	mov    %eax,%edx
  80166b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80166f:	75 17                	jne    801688 <__umoddi3+0x48>
  801671:	39 fe                	cmp    %edi,%esi
  801673:	76 4b                	jbe    8016c0 <__umoddi3+0x80>
  801675:	89 c8                	mov    %ecx,%eax
  801677:	89 fa                	mov    %edi,%edx
  801679:	f7 f6                	div    %esi
  80167b:	89 d0                	mov    %edx,%eax
  80167d:	31 d2                	xor    %edx,%edx
  80167f:	83 c4 14             	add    $0x14,%esp
  801682:	5e                   	pop    %esi
  801683:	5f                   	pop    %edi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    
  801686:	66 90                	xchg   %ax,%ax
  801688:	39 f8                	cmp    %edi,%eax
  80168a:	77 54                	ja     8016e0 <__umoddi3+0xa0>
  80168c:	0f bd e8             	bsr    %eax,%ebp
  80168f:	83 f5 1f             	xor    $0x1f,%ebp
  801692:	75 5c                	jne    8016f0 <__umoddi3+0xb0>
  801694:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801698:	39 3c 24             	cmp    %edi,(%esp)
  80169b:	0f 87 e7 00 00 00    	ja     801788 <__umoddi3+0x148>
  8016a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016a5:	29 f1                	sub    %esi,%ecx
  8016a7:	19 c7                	sbb    %eax,%edi
  8016a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8016b9:	83 c4 14             	add    $0x14,%esp
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    
  8016c0:	85 f6                	test   %esi,%esi
  8016c2:	89 f5                	mov    %esi,%ebp
  8016c4:	75 0b                	jne    8016d1 <__umoddi3+0x91>
  8016c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8016cb:	31 d2                	xor    %edx,%edx
  8016cd:	f7 f6                	div    %esi
  8016cf:	89 c5                	mov    %eax,%ebp
  8016d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8016d5:	31 d2                	xor    %edx,%edx
  8016d7:	f7 f5                	div    %ebp
  8016d9:	89 c8                	mov    %ecx,%eax
  8016db:	f7 f5                	div    %ebp
  8016dd:	eb 9c                	jmp    80167b <__umoddi3+0x3b>
  8016df:	90                   	nop
  8016e0:	89 c8                	mov    %ecx,%eax
  8016e2:	89 fa                	mov    %edi,%edx
  8016e4:	83 c4 14             	add    $0x14,%esp
  8016e7:	5e                   	pop    %esi
  8016e8:	5f                   	pop    %edi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    
  8016eb:	90                   	nop
  8016ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016f0:	8b 04 24             	mov    (%esp),%eax
  8016f3:	be 20 00 00 00       	mov    $0x20,%esi
  8016f8:	89 e9                	mov    %ebp,%ecx
  8016fa:	29 ee                	sub    %ebp,%esi
  8016fc:	d3 e2                	shl    %cl,%edx
  8016fe:	89 f1                	mov    %esi,%ecx
  801700:	d3 e8                	shr    %cl,%eax
  801702:	89 e9                	mov    %ebp,%ecx
  801704:	89 44 24 04          	mov    %eax,0x4(%esp)
  801708:	8b 04 24             	mov    (%esp),%eax
  80170b:	09 54 24 04          	or     %edx,0x4(%esp)
  80170f:	89 fa                	mov    %edi,%edx
  801711:	d3 e0                	shl    %cl,%eax
  801713:	89 f1                	mov    %esi,%ecx
  801715:	89 44 24 08          	mov    %eax,0x8(%esp)
  801719:	8b 44 24 10          	mov    0x10(%esp),%eax
  80171d:	d3 ea                	shr    %cl,%edx
  80171f:	89 e9                	mov    %ebp,%ecx
  801721:	d3 e7                	shl    %cl,%edi
  801723:	89 f1                	mov    %esi,%ecx
  801725:	d3 e8                	shr    %cl,%eax
  801727:	89 e9                	mov    %ebp,%ecx
  801729:	09 f8                	or     %edi,%eax
  80172b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80172f:	f7 74 24 04          	divl   0x4(%esp)
  801733:	d3 e7                	shl    %cl,%edi
  801735:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801739:	89 d7                	mov    %edx,%edi
  80173b:	f7 64 24 08          	mull   0x8(%esp)
  80173f:	39 d7                	cmp    %edx,%edi
  801741:	89 c1                	mov    %eax,%ecx
  801743:	89 14 24             	mov    %edx,(%esp)
  801746:	72 2c                	jb     801774 <__umoddi3+0x134>
  801748:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80174c:	72 22                	jb     801770 <__umoddi3+0x130>
  80174e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801752:	29 c8                	sub    %ecx,%eax
  801754:	19 d7                	sbb    %edx,%edi
  801756:	89 e9                	mov    %ebp,%ecx
  801758:	89 fa                	mov    %edi,%edx
  80175a:	d3 e8                	shr    %cl,%eax
  80175c:	89 f1                	mov    %esi,%ecx
  80175e:	d3 e2                	shl    %cl,%edx
  801760:	89 e9                	mov    %ebp,%ecx
  801762:	d3 ef                	shr    %cl,%edi
  801764:	09 d0                	or     %edx,%eax
  801766:	89 fa                	mov    %edi,%edx
  801768:	83 c4 14             	add    $0x14,%esp
  80176b:	5e                   	pop    %esi
  80176c:	5f                   	pop    %edi
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    
  80176f:	90                   	nop
  801770:	39 d7                	cmp    %edx,%edi
  801772:	75 da                	jne    80174e <__umoddi3+0x10e>
  801774:	8b 14 24             	mov    (%esp),%edx
  801777:	89 c1                	mov    %eax,%ecx
  801779:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80177d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801781:	eb cb                	jmp    80174e <__umoddi3+0x10e>
  801783:	90                   	nop
  801784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801788:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80178c:	0f 82 0f ff ff ff    	jb     8016a1 <__umoddi3+0x61>
  801792:	e9 1a ff ff ff       	jmp    8016b1 <__umoddi3+0x71>
