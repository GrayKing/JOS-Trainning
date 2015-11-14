
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800043:	c7 04 24 a0 16 80 00 	movl   $0x8016a0,(%esp)
  80004a:	e8 ea 01 00 00       	call   800239 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 15 11 00 00       	call   801183 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 c0 16 80 	movl   $0x8016c0,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 aa 16 80 00 	movl   $0x8016aa,(%esp)
  800091:	e8 aa 00 00 00       	call   800140 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 ec 16 80 	movl   $0x8016ec,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 52 0c 00 00       	call   800d04 <snprintf>
}
  8000b2:	83 c4 24             	add    $0x24,%esp
  8000b5:	5b                   	pop    %ebx
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <umain>:

void
umain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000be:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000c5:	e8 ce 12 00 00       	call   801398 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000ca:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d1:	00 
  8000d2:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000d9:	e8 d8 0f 00 00       	call   8010b6 <sys_cputs>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 10             	sub    $0x10,%esp
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  8000ee:	e8 52 10 00 00       	call   801145 <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	89 c2                	mov    %eax,%edx
  8000fa:	c1 e2 07             	shl    $0x7,%edx
  8000fd:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800104:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800109:	85 db                	test   %ebx,%ebx
  80010b:	7e 07                	jle    800114 <libmain+0x34>
		binaryname = argv[0];
  80010d:	8b 06                	mov    (%esi),%eax
  80010f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800114:	89 74 24 04          	mov    %esi,0x4(%esp)
  800118:	89 1c 24             	mov    %ebx,(%esp)
  80011b:	e8 98 ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  800120:	e8 07 00 00 00       	call   80012c <exit>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800139:	e8 b5 0f 00 00       	call   8010f3 <sys_env_destroy>
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
  800145:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800148:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800151:	e8 ef 0f 00 00       	call   801145 <sys_getenvid>
  800156:	8b 55 0c             	mov    0xc(%ebp),%edx
  800159:	89 54 24 10          	mov    %edx,0x10(%esp)
  80015d:	8b 55 08             	mov    0x8(%ebp),%edx
  800160:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800164:	89 74 24 08          	mov    %esi,0x8(%esp)
  800168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016c:	c7 04 24 18 17 80 00 	movl   $0x801718,(%esp)
  800173:	e8 c1 00 00 00       	call   800239 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017c:	8b 45 10             	mov    0x10(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 51 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  800187:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  80018e:	e8 a6 00 00 00       	call   800239 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x53>

00800196 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	53                   	push   %ebx
  80019a:	83 ec 14             	sub    $0x14,%esp
  80019d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a0:	8b 13                	mov    (%ebx),%edx
  8001a2:	8d 42 01             	lea    0x1(%edx),%eax
  8001a5:	89 03                	mov    %eax,(%ebx)
  8001a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 19                	jne    8001ce <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001bc:	00 
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 ee 0e 00 00       	call   8010b6 <sys_cputs>
		b->idx = 0;
  8001c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ce:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d2:	83 c4 14             	add    $0x14,%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    

008001d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	c7 04 24 96 01 80 00 	movl   $0x800196,(%esp)
  800214:	e8 b6 02 00 00       	call   8004cf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800219:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 85 0e 00 00       	call   8010b6 <sys_cputs>

	return b.cnt;
}
  800231:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	e8 87 ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800251:	c9                   	leave  
  800252:	c3                   	ret    
  800253:	66 90                	xchg   %ax,%ax
  800255:	66 90                	xchg   %ax,%ax
  800257:	66 90                	xchg   %ax,%ax
  800259:	66 90                	xchg   %ax,%ax
  80025b:	66 90                	xchg   %ax,%ax
  80025d:	66 90                	xchg   %ax,%ax
  80025f:	90                   	nop

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 c3                	mov    %eax,%ebx
  800279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80027c:	8b 45 10             	mov    0x10(%ebp),%eax
  80027f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800282:	b9 00 00 00 00       	mov    $0x0,%ecx
  800287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028d:	39 d9                	cmp    %ebx,%ecx
  80028f:	72 05                	jb     800296 <printnum+0x36>
  800291:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800294:	77 69                	ja     8002ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800296:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800299:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80029d:	83 ee 01             	sub    $0x1,%esi
  8002a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b0:	89 c3                	mov    %eax,%ebx
  8002b2:	89 d6                	mov    %edx,%esi
  8002b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	e8 3c 11 00 00       	call   801410 <__udivdi3>
  8002d4:	89 d9                	mov    %ebx,%ecx
  8002d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e5:	89 fa                	mov    %edi,%edx
  8002e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ea:	e8 71 ff ff ff       	call   800260 <printnum>
  8002ef:	eb 1b                	jmp    80030c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	ff d3                	call   *%ebx
  8002fd:	eb 03                	jmp    800302 <printnum+0xa2>
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800302:	83 ee 01             	sub    $0x1,%esi
  800305:	85 f6                	test   %esi,%esi
  800307:	7f e8                	jg     8002f1 <printnum+0x91>
  800309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800317:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80031a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 0c 12 00 00       	call   801540 <__umoddi3>
  800334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800338:	0f be 80 3c 17 80 00 	movsbl 0x80173c(%eax),%eax
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800345:	ff d0                	call   *%eax
}
  800347:	83 c4 3c             	add    $0x3c,%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
  800355:	83 ec 3c             	sub    $0x3c,%esp
  800358:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80035b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80035e:	89 cf                	mov    %ecx,%edi
  800360:	8b 45 08             	mov    0x8(%ebp),%eax
  800363:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800366:	8b 45 0c             	mov    0xc(%ebp),%eax
  800369:	89 c3                	mov    %eax,%ebx
  80036b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80036e:	8b 45 10             	mov    0x10(%ebp),%eax
  800371:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800374:	b9 00 00 00 00       	mov    $0x0,%ecx
  800379:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80037c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80037f:	39 d9                	cmp    %ebx,%ecx
  800381:	72 13                	jb     800396 <cprintnum+0x47>
  800383:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800386:	76 0e                	jbe    800396 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800388:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038b:	0b 45 18             	or     0x18(%ebp),%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800391:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800394:	eb 6a                	jmp    800400 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800396:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800399:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80039d:	83 ee 01             	sub    $0x1,%esi
  8003a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003b0:	89 c3                	mov    %eax,%ebx
  8003b2:	89 d6                	mov    %edx,%esi
  8003b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8003ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cf:	e8 3c 10 00 00       	call   801410 <__udivdi3>
  8003d4:	89 d9                	mov    %ebx,%ecx
  8003d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003de:	89 04 24             	mov    %eax,(%esp)
  8003e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003e5:	89 f9                	mov    %edi,%ecx
  8003e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ed:	e8 5d ff ff ff       	call   80034f <cprintnum>
  8003f2:	eb 16                	jmp    80040a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8003f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800400:	83 ee 01             	sub    $0x1,%esi
  800403:	85 f6                	test   %esi,%esi
  800405:	7f ed                	jg     8003f4 <cprintnum+0xa5>
  800407:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80040a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800412:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800415:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800418:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800420:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800423:	89 04 24             	mov    %eax,(%esp)
  800426:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800429:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042d:	e8 0e 11 00 00       	call   801540 <__umoddi3>
  800432:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800436:	0f be 80 3c 17 80 00 	movsbl 0x80173c(%eax),%eax
  80043d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800446:	ff d0                	call   *%eax
}
  800448:	83 c4 3c             	add    $0x3c,%esp
  80044b:	5b                   	pop    %ebx
  80044c:	5e                   	pop    %esi
  80044d:	5f                   	pop    %edi
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800453:	83 fa 01             	cmp    $0x1,%edx
  800456:	7e 0e                	jle    800466 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800458:	8b 10                	mov    (%eax),%edx
  80045a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80045d:	89 08                	mov    %ecx,(%eax)
  80045f:	8b 02                	mov    (%edx),%eax
  800461:	8b 52 04             	mov    0x4(%edx),%edx
  800464:	eb 22                	jmp    800488 <getuint+0x38>
	else if (lflag)
  800466:	85 d2                	test   %edx,%edx
  800468:	74 10                	je     80047a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80046a:	8b 10                	mov    (%eax),%edx
  80046c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046f:	89 08                	mov    %ecx,(%eax)
  800471:	8b 02                	mov    (%edx),%eax
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 0e                	jmp    800488 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047f:	89 08                	mov    %ecx,(%eax)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800488:	5d                   	pop    %ebp
  800489:	c3                   	ret    

0080048a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800490:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800494:	8b 10                	mov    (%eax),%edx
  800496:	3b 50 04             	cmp    0x4(%eax),%edx
  800499:	73 0a                	jae    8004a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80049b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80049e:	89 08                	mov    %ecx,(%eax)
  8004a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a3:	88 02                	mov    %al,(%edx)
}
  8004a5:	5d                   	pop    %ebp
  8004a6:	c3                   	ret    

008004a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004a7:	55                   	push   %ebp
  8004a8:	89 e5                	mov    %esp,%ebp
  8004aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c5:	89 04 24             	mov    %eax,(%esp)
  8004c8:	e8 02 00 00 00       	call   8004cf <vprintfmt>
	va_end(ap);
}
  8004cd:	c9                   	leave  
  8004ce:	c3                   	ret    

008004cf <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004cf:	55                   	push   %ebp
  8004d0:	89 e5                	mov    %esp,%ebp
  8004d2:	57                   	push   %edi
  8004d3:	56                   	push   %esi
  8004d4:	53                   	push   %ebx
  8004d5:	83 ec 3c             	sub    $0x3c,%esp
  8004d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004de:	eb 14                	jmp    8004f4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	0f 84 b3 03 00 00    	je     80089b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8004e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ec:	89 04 24             	mov    %eax,(%esp)
  8004ef:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f2:	89 f3                	mov    %esi,%ebx
  8004f4:	8d 73 01             	lea    0x1(%ebx),%esi
  8004f7:	0f b6 03             	movzbl (%ebx),%eax
  8004fa:	83 f8 25             	cmp    $0x25,%eax
  8004fd:	75 e1                	jne    8004e0 <vprintfmt+0x11>
  8004ff:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800503:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80050a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800511:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800518:	ba 00 00 00 00       	mov    $0x0,%edx
  80051d:	eb 1d                	jmp    80053c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800521:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800525:	eb 15                	jmp    80053c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800529:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80052d:	eb 0d                	jmp    80053c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80052f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800532:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800535:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80053f:	0f b6 0e             	movzbl (%esi),%ecx
  800542:	0f b6 c1             	movzbl %cl,%eax
  800545:	83 e9 23             	sub    $0x23,%ecx
  800548:	80 f9 55             	cmp    $0x55,%cl
  80054b:	0f 87 2a 03 00 00    	ja     80087b <vprintfmt+0x3ac>
  800551:	0f b6 c9             	movzbl %cl,%ecx
  800554:	ff 24 8d 00 18 80 00 	jmp    *0x801800(,%ecx,4)
  80055b:	89 de                	mov    %ebx,%esi
  80055d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800562:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800565:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800569:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80056c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80056f:	83 fb 09             	cmp    $0x9,%ebx
  800572:	77 36                	ja     8005aa <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800574:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800577:	eb e9                	jmp    800562 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 48 04             	lea    0x4(%eax),%ecx
  80057f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800589:	eb 22                	jmp    8005ad <vprintfmt+0xde>
  80058b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058e:	85 c9                	test   %ecx,%ecx
  800590:	b8 00 00 00 00       	mov    $0x0,%eax
  800595:	0f 49 c1             	cmovns %ecx,%eax
  800598:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	89 de                	mov    %ebx,%esi
  80059d:	eb 9d                	jmp    80053c <vprintfmt+0x6d>
  80059f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005a1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005a8:	eb 92                	jmp    80053c <vprintfmt+0x6d>
  8005aa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8005ad:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b1:	79 89                	jns    80053c <vprintfmt+0x6d>
  8005b3:	e9 77 ff ff ff       	jmp    80052f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005b8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005bd:	e9 7a ff ff ff       	jmp    80053c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 04 24             	mov    %eax,(%esp)
  8005d4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005d7:	e9 18 ff ff ff       	jmp    8004f4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	99                   	cltd   
  8005e8:	31 d0                	xor    %edx,%eax
  8005ea:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ec:	83 f8 09             	cmp    $0x9,%eax
  8005ef:	7f 0b                	jg     8005fc <vprintfmt+0x12d>
  8005f1:	8b 14 85 c0 1a 80 00 	mov    0x801ac0(,%eax,4),%edx
  8005f8:	85 d2                	test   %edx,%edx
  8005fa:	75 20                	jne    80061c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8005fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800600:	c7 44 24 08 54 17 80 	movl   $0x801754,0x8(%esp)
  800607:	00 
  800608:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060c:	8b 45 08             	mov    0x8(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	e8 90 fe ff ff       	call   8004a7 <printfmt>
  800617:	e9 d8 fe ff ff       	jmp    8004f4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80061c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800620:	c7 44 24 08 5d 17 80 	movl   $0x80175d,0x8(%esp)
  800627:	00 
  800628:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	e8 70 fe ff ff       	call   8004a7 <printfmt>
  800637:	e9 b8 fe ff ff       	jmp    8004f4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80063f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800642:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8d 50 04             	lea    0x4(%eax),%edx
  80064b:	89 55 14             	mov    %edx,0x14(%ebp)
  80064e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800650:	85 f6                	test   %esi,%esi
  800652:	b8 4d 17 80 00       	mov    $0x80174d,%eax
  800657:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80065a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80065e:	0f 84 97 00 00 00    	je     8006fb <vprintfmt+0x22c>
  800664:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800668:	0f 8e 9b 00 00 00    	jle    800709 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800672:	89 34 24             	mov    %esi,(%esp)
  800675:	e8 ce 06 00 00       	call   800d48 <strnlen>
  80067a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80067d:	29 c2                	sub    %eax,%edx
  80067f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800682:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800686:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800689:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80068c:	8b 75 08             	mov    0x8(%ebp),%esi
  80068f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800692:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800694:	eb 0f                	jmp    8006a5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800696:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80069d:	89 04 24             	mov    %eax,(%esp)
  8006a0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a2:	83 eb 01             	sub    $0x1,%ebx
  8006a5:	85 db                	test   %ebx,%ebx
  8006a7:	7f ed                	jg     800696 <vprintfmt+0x1c7>
  8006a9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ac:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006af:	85 d2                	test   %edx,%edx
  8006b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b6:	0f 49 c2             	cmovns %edx,%eax
  8006b9:	29 c2                	sub    %eax,%edx
  8006bb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006be:	89 d7                	mov    %edx,%edi
  8006c0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006c3:	eb 50                	jmp    800715 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c9:	74 1e                	je     8006e9 <vprintfmt+0x21a>
  8006cb:	0f be d2             	movsbl %dl,%edx
  8006ce:	83 ea 20             	sub    $0x20,%edx
  8006d1:	83 fa 5e             	cmp    $0x5e,%edx
  8006d4:	76 13                	jbe    8006e9 <vprintfmt+0x21a>
					putch('?', putdat);
  8006d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006e4:	ff 55 08             	call   *0x8(%ebp)
  8006e7:	eb 0d                	jmp    8006f6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8006e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006f0:	89 04 24             	mov    %eax,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f6:	83 ef 01             	sub    $0x1,%edi
  8006f9:	eb 1a                	jmp    800715 <vprintfmt+0x246>
  8006fb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006fe:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800701:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800704:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800707:	eb 0c                	jmp    800715 <vprintfmt+0x246>
  800709:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80070c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80070f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800712:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800715:	83 c6 01             	add    $0x1,%esi
  800718:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80071c:	0f be c2             	movsbl %dl,%eax
  80071f:	85 c0                	test   %eax,%eax
  800721:	74 27                	je     80074a <vprintfmt+0x27b>
  800723:	85 db                	test   %ebx,%ebx
  800725:	78 9e                	js     8006c5 <vprintfmt+0x1f6>
  800727:	83 eb 01             	sub    $0x1,%ebx
  80072a:	79 99                	jns    8006c5 <vprintfmt+0x1f6>
  80072c:	89 f8                	mov    %edi,%eax
  80072e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800731:	8b 75 08             	mov    0x8(%ebp),%esi
  800734:	89 c3                	mov    %eax,%ebx
  800736:	eb 1a                	jmp    800752 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800738:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800743:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800745:	83 eb 01             	sub    $0x1,%ebx
  800748:	eb 08                	jmp    800752 <vprintfmt+0x283>
  80074a:	89 fb                	mov    %edi,%ebx
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800752:	85 db                	test   %ebx,%ebx
  800754:	7f e2                	jg     800738 <vprintfmt+0x269>
  800756:	89 75 08             	mov    %esi,0x8(%ebp)
  800759:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80075c:	e9 93 fd ff ff       	jmp    8004f4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800761:	83 fa 01             	cmp    $0x1,%edx
  800764:	7e 16                	jle    80077c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8d 50 08             	lea    0x8(%eax),%edx
  80076c:	89 55 14             	mov    %edx,0x14(%ebp)
  80076f:	8b 50 04             	mov    0x4(%eax),%edx
  800772:	8b 00                	mov    (%eax),%eax
  800774:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800777:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80077a:	eb 32                	jmp    8007ae <vprintfmt+0x2df>
	else if (lflag)
  80077c:	85 d2                	test   %edx,%edx
  80077e:	74 18                	je     800798 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8d 50 04             	lea    0x4(%eax),%edx
  800786:	89 55 14             	mov    %edx,0x14(%ebp)
  800789:	8b 30                	mov    (%eax),%esi
  80078b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80078e:	89 f0                	mov    %esi,%eax
  800790:	c1 f8 1f             	sar    $0x1f,%eax
  800793:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800796:	eb 16                	jmp    8007ae <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 50 04             	lea    0x4(%eax),%edx
  80079e:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a1:	8b 30                	mov    (%eax),%esi
  8007a3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007a6:	89 f0                	mov    %esi,%eax
  8007a8:	c1 f8 1f             	sar    $0x1f,%eax
  8007ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007bd:	0f 89 80 00 00 00    	jns    800843 <vprintfmt+0x374>
				putch('-', putdat);
  8007c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007ce:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d7:	f7 d8                	neg    %eax
  8007d9:	83 d2 00             	adc    $0x0,%edx
  8007dc:	f7 da                	neg    %edx
			}
			base = 10;
  8007de:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007e3:	eb 5e                	jmp    800843 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e8:	e8 63 fc ff ff       	call   800450 <getuint>
			base = 10;
  8007ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007f2:	eb 4f                	jmp    800843 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f7:	e8 54 fc ff ff       	call   800450 <getuint>
			base = 8 ;
  8007fc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800801:	eb 40                	jmp    800843 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800803:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800807:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80080e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800811:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800815:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80081c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800828:	8b 00                	mov    (%eax),%eax
  80082a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80082f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800834:	eb 0d                	jmp    800843 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800836:	8d 45 14             	lea    0x14(%ebp),%eax
  800839:	e8 12 fc ff ff       	call   800450 <getuint>
			base = 16;
  80083e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800843:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800847:	89 74 24 10          	mov    %esi,0x10(%esp)
  80084b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80084e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800852:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085d:	89 fa                	mov    %edi,%edx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	e8 f9 f9 ff ff       	call   800260 <printnum>
			break;
  800867:	e9 88 fc ff ff       	jmp    8004f4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800870:	89 04 24             	mov    %eax,(%esp)
  800873:	ff 55 08             	call   *0x8(%ebp)
			break;
  800876:	e9 79 fc ff ff       	jmp    8004f4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80087f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800886:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800889:	89 f3                	mov    %esi,%ebx
  80088b:	eb 03                	jmp    800890 <vprintfmt+0x3c1>
  80088d:	83 eb 01             	sub    $0x1,%ebx
  800890:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800894:	75 f7                	jne    80088d <vprintfmt+0x3be>
  800896:	e9 59 fc ff ff       	jmp    8004f4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80089b:	83 c4 3c             	add    $0x3c,%esp
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5f                   	pop    %edi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	57                   	push   %edi
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	83 ec 3c             	sub    $0x3c,%esp
  8008ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	8d 50 04             	lea    0x4(%eax),%edx
  8008b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b8:	8b 00                	mov    (%eax),%eax
  8008ba:	c1 e0 08             	shl    $0x8,%eax
  8008bd:	0f b7 c0             	movzwl %ax,%eax
  8008c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  8008c3:	83 c8 25             	or     $0x25,%eax
  8008c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8008c9:	eb 1a                	jmp    8008e5 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	0f 84 a9 03 00 00    	je     800c7c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  8008d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008da:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8008dd:	89 04 24             	mov    %eax,(%esp)
  8008e0:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008e3:	89 fb                	mov    %edi,%ebx
  8008e5:	8d 7b 01             	lea    0x1(%ebx),%edi
  8008e8:	0f b6 03             	movzbl (%ebx),%eax
  8008eb:	83 f8 25             	cmp    $0x25,%eax
  8008ee:	75 db                	jne    8008cb <cvprintfmt+0x28>
  8008f0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8008f4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008fb:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800900:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800907:	ba 00 00 00 00       	mov    $0x0,%edx
  80090c:	eb 18                	jmp    800926 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800910:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800914:	eb 10                	jmp    800926 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800916:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800918:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80091c:	eb 08                	jmp    800926 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80091e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800921:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800926:	8d 5f 01             	lea    0x1(%edi),%ebx
  800929:	0f b6 0f             	movzbl (%edi),%ecx
  80092c:	0f b6 c1             	movzbl %cl,%eax
  80092f:	83 e9 23             	sub    $0x23,%ecx
  800932:	80 f9 55             	cmp    $0x55,%cl
  800935:	0f 87 1f 03 00 00    	ja     800c5a <cvprintfmt+0x3b7>
  80093b:	0f b6 c9             	movzbl %cl,%ecx
  80093e:	ff 24 8d 58 19 80 00 	jmp    *0x801958(,%ecx,4)
  800945:	89 df                	mov    %ebx,%edi
  800947:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80094c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80094f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800953:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800956:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800959:	83 f9 09             	cmp    $0x9,%ecx
  80095c:	77 33                	ja     800991 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80095e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800961:	eb e9                	jmp    80094c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8d 48 04             	lea    0x4(%eax),%ecx
  800969:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80096c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800970:	eb 1f                	jmp    800991 <cvprintfmt+0xee>
  800972:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800975:	85 ff                	test   %edi,%edi
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
  80097c:	0f 49 c7             	cmovns %edi,%eax
  80097f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800982:	89 df                	mov    %ebx,%edi
  800984:	eb a0                	jmp    800926 <cvprintfmt+0x83>
  800986:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800988:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80098f:	eb 95                	jmp    800926 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800991:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800995:	79 8f                	jns    800926 <cvprintfmt+0x83>
  800997:	eb 85                	jmp    80091e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800999:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80099e:	66 90                	xchg   %ax,%ax
  8009a0:	eb 84                	jmp    800926 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  8009a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a5:	8d 50 04             	lea    0x4(%eax),%edx
  8009a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009b5:	0b 10                	or     (%eax),%edx
  8009b7:	89 14 24             	mov    %edx,(%esp)
  8009ba:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009bd:	e9 23 ff ff ff       	jmp    8008e5 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	8d 50 04             	lea    0x4(%eax),%edx
  8009c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cb:	8b 00                	mov    (%eax),%eax
  8009cd:	99                   	cltd   
  8009ce:	31 d0                	xor    %edx,%eax
  8009d0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009d2:	83 f8 09             	cmp    $0x9,%eax
  8009d5:	7f 0b                	jg     8009e2 <cvprintfmt+0x13f>
  8009d7:	8b 14 85 c0 1a 80 00 	mov    0x801ac0(,%eax,4),%edx
  8009de:	85 d2                	test   %edx,%edx
  8009e0:	75 23                	jne    800a05 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  8009e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e6:	c7 44 24 08 54 17 80 	movl   $0x801754,0x8(%esp)
  8009ed:	00 
  8009ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	89 04 24             	mov    %eax,(%esp)
  8009fb:	e8 a7 fa ff ff       	call   8004a7 <printfmt>
  800a00:	e9 e0 fe ff ff       	jmp    8008e5 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800a05:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a09:	c7 44 24 08 5d 17 80 	movl   $0x80175d,0x8(%esp)
  800a10:	00 
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	89 04 24             	mov    %eax,(%esp)
  800a1e:	e8 84 fa ff ff       	call   8004a7 <printfmt>
  800a23:	e9 bd fe ff ff       	jmp    8008e5 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a28:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800a2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a31:	8d 48 04             	lea    0x4(%eax),%ecx
  800a34:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a37:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a39:	85 ff                	test   %edi,%edi
  800a3b:	b8 4d 17 80 00       	mov    $0x80174d,%eax
  800a40:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a43:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a47:	74 61                	je     800aaa <cvprintfmt+0x207>
  800a49:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a4d:	7e 5b                	jle    800aaa <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a53:	89 3c 24             	mov    %edi,(%esp)
  800a56:	e8 ed 02 00 00       	call   800d48 <strnlen>
  800a5b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a5e:	29 c2                	sub    %eax,%edx
  800a60:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800a63:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a67:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a6a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a6d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800a70:	8b 75 08             	mov    0x8(%ebp),%esi
  800a73:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a76:	89 d3                	mov    %edx,%ebx
  800a78:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a7a:	eb 0f                	jmp    800a8b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a83:	89 3c 24             	mov    %edi,(%esp)
  800a86:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a88:	83 eb 01             	sub    $0x1,%ebx
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	7f ed                	jg     800a7c <cvprintfmt+0x1d9>
  800a8f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a92:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a98:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a9b:	85 d2                	test   %edx,%edx
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa2:	0f 49 c2             	cmovns %edx,%eax
  800aa5:	29 c2                	sub    %eax,%edx
  800aa7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800aaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aad:	83 c8 3f             	or     $0x3f,%eax
  800ab0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ab9:	eb 36                	jmp    800af1 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800abb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800abf:	74 1d                	je     800ade <cvprintfmt+0x23b>
  800ac1:	0f be d2             	movsbl %dl,%edx
  800ac4:	83 ea 20             	sub    $0x20,%edx
  800ac7:	83 fa 5e             	cmp    $0x5e,%edx
  800aca:	76 12                	jbe    800ade <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad6:	89 04 24             	mov    %eax,(%esp)
  800ad9:	ff 55 08             	call   *0x8(%ebp)
  800adc:	eb 10                	jmp    800aee <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae5:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800ae8:	89 04 24             	mov    %eax,(%esp)
  800aeb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aee:	83 eb 01             	sub    $0x1,%ebx
  800af1:	83 c7 01             	add    $0x1,%edi
  800af4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800af8:	0f be c2             	movsbl %dl,%eax
  800afb:	85 c0                	test   %eax,%eax
  800afd:	74 27                	je     800b26 <cvprintfmt+0x283>
  800aff:	85 f6                	test   %esi,%esi
  800b01:	78 b8                	js     800abb <cvprintfmt+0x218>
  800b03:	83 ee 01             	sub    $0x1,%esi
  800b06:	79 b3                	jns    800abb <cvprintfmt+0x218>
  800b08:	89 d8                	mov    %ebx,%eax
  800b0a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	eb 18                	jmp    800b2c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800b14:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b1f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800b21:	83 eb 01             	sub    $0x1,%ebx
  800b24:	eb 06                	jmp    800b2c <cvprintfmt+0x289>
  800b26:	8b 75 08             	mov    0x8(%ebp),%esi
  800b29:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b2c:	85 db                	test   %ebx,%ebx
  800b2e:	7f e4                	jg     800b14 <cvprintfmt+0x271>
  800b30:	89 75 08             	mov    %esi,0x8(%ebp)
  800b33:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b39:	e9 a7 fd ff ff       	jmp    8008e5 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b3e:	83 fa 01             	cmp    $0x1,%edx
  800b41:	7e 10                	jle    800b53 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800b43:	8b 45 14             	mov    0x14(%ebp),%eax
  800b46:	8d 50 08             	lea    0x8(%eax),%edx
  800b49:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4c:	8b 30                	mov    (%eax),%esi
  800b4e:	8b 78 04             	mov    0x4(%eax),%edi
  800b51:	eb 26                	jmp    800b79 <cvprintfmt+0x2d6>
	else if (lflag)
  800b53:	85 d2                	test   %edx,%edx
  800b55:	74 12                	je     800b69 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800b57:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5a:	8d 50 04             	lea    0x4(%eax),%edx
  800b5d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b60:	8b 30                	mov    (%eax),%esi
  800b62:	89 f7                	mov    %esi,%edi
  800b64:	c1 ff 1f             	sar    $0x1f,%edi
  800b67:	eb 10                	jmp    800b79 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800b69:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6c:	8d 50 04             	lea    0x4(%eax),%edx
  800b6f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b72:	8b 30                	mov    (%eax),%esi
  800b74:	89 f7                	mov    %esi,%edi
  800b76:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b79:	89 f0                	mov    %esi,%eax
  800b7b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b7d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b82:	85 ff                	test   %edi,%edi
  800b84:	0f 89 8e 00 00 00    	jns    800c18 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b94:	83 c8 2d             	or     $0x2d,%eax
  800b97:	89 04 24             	mov    %eax,(%esp)
  800b9a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b9d:	89 f0                	mov    %esi,%eax
  800b9f:	89 fa                	mov    %edi,%edx
  800ba1:	f7 d8                	neg    %eax
  800ba3:	83 d2 00             	adc    $0x0,%edx
  800ba6:	f7 da                	neg    %edx
			}
			base = 10;
  800ba8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bad:	eb 69                	jmp    800c18 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800baf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb2:	e8 99 f8 ff ff       	call   800450 <getuint>
			base = 10;
  800bb7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bbc:	eb 5a                	jmp    800c18 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800bbe:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc1:	e8 8a f8 ff ff       	call   800450 <getuint>
			base = 8 ;
  800bc6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800bcb:	eb 4b                	jmp    800c18 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800bd7:	89 f0                	mov    %esi,%eax
  800bd9:	83 c8 30             	or     $0x30,%eax
  800bdc:	89 04 24             	mov    %eax,(%esp)
  800bdf:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be9:	89 f0                	mov    %esi,%eax
  800beb:	83 c8 78             	or     $0x78,%eax
  800bee:	89 04 24             	mov    %eax,(%esp)
  800bf1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bf4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf7:	8d 50 04             	lea    0x4(%eax),%edx
  800bfa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800bfd:	8b 00                	mov    (%eax),%eax
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c04:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c09:	eb 0d                	jmp    800c18 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c0b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c0e:	e8 3d f8 ff ff       	call   800450 <getuint>
			base = 16;
  800c13:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800c18:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800c1c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c20:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800c23:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c27:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c2b:	89 04 24             	mov    %eax,(%esp)
  800c2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c3b:	e8 0f f7 ff ff       	call   80034f <cprintnum>
			break;
  800c40:	e9 a0 fc ff ff       	jmp    8008e5 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800c45:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c48:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c4c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800c4f:	89 04 24             	mov    %eax,(%esp)
  800c52:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c55:	e9 8b fc ff ff       	jmp    8008e5 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c61:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c64:	89 04 24             	mov    %eax,(%esp)
  800c67:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c6a:	89 fb                	mov    %edi,%ebx
  800c6c:	eb 03                	jmp    800c71 <cvprintfmt+0x3ce>
  800c6e:	83 eb 01             	sub    $0x1,%ebx
  800c71:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c75:	75 f7                	jne    800c6e <cvprintfmt+0x3cb>
  800c77:	e9 69 fc ff ff       	jmp    8008e5 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800c7c:	83 c4 3c             	add    $0x3c,%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c8a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800c8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c91:	8b 45 10             	mov    0x10(%ebp),%eax
  800c94:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca2:	89 04 24             	mov    %eax,(%esp)
  800ca5:	e8 f9 fb ff ff       	call   8008a3 <cvprintfmt>
	va_end(ap);
}
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    

00800cac <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 28             	sub    $0x28,%esp
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cbb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cbf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cc2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	74 30                	je     800cfd <vsnprintf+0x51>
  800ccd:	85 d2                	test   %edx,%edx
  800ccf:	7e 2c                	jle    800cfd <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cd1:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cdf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce6:	c7 04 24 8a 04 80 00 	movl   $0x80048a,(%esp)
  800ced:	e8 dd f7 ff ff       	call   8004cf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cf2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cf5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cfb:	eb 05                	jmp    800d02 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cfd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    

00800d04 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d0a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d11:	8b 45 10             	mov    0x10(%ebp),%eax
  800d14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	89 04 24             	mov    %eax,(%esp)
  800d25:	e8 82 ff ff ff       	call   800cac <vsnprintf>
	va_end(ap);

	return rc;
}
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d36:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3b:	eb 03                	jmp    800d40 <strlen+0x10>
		n++;
  800d3d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d40:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d44:	75 f7                	jne    800d3d <strlen+0xd>
		n++;
	return n;
}
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	eb 03                	jmp    800d5b <strnlen+0x13>
		n++;
  800d58:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d5b:	39 d0                	cmp    %edx,%eax
  800d5d:	74 06                	je     800d65 <strnlen+0x1d>
  800d5f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d63:	75 f3                	jne    800d58 <strnlen+0x10>
		n++;
	return n;
}
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	53                   	push   %ebx
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	83 c2 01             	add    $0x1,%edx
  800d76:	83 c1 01             	add    $0x1,%ecx
  800d79:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d7d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d80:	84 db                	test   %bl,%bl
  800d82:	75 ef                	jne    800d73 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d84:	5b                   	pop    %ebx
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 08             	sub    $0x8,%esp
  800d8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d91:	89 1c 24             	mov    %ebx,(%esp)
  800d94:	e8 97 ff ff ff       	call   800d30 <strlen>
	strcpy(dst + len, src);
  800d99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800da0:	01 d8                	add    %ebx,%eax
  800da2:	89 04 24             	mov    %eax,(%esp)
  800da5:	e8 bd ff ff ff       	call   800d67 <strcpy>
	return dst;
}
  800daa:	89 d8                	mov    %ebx,%eax
  800dac:	83 c4 08             	add    $0x8,%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	8b 75 08             	mov    0x8(%ebp),%esi
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	89 f3                	mov    %esi,%ebx
  800dbf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc2:	89 f2                	mov    %esi,%edx
  800dc4:	eb 0f                	jmp    800dd5 <strncpy+0x23>
		*dst++ = *src;
  800dc6:	83 c2 01             	add    $0x1,%edx
  800dc9:	0f b6 01             	movzbl (%ecx),%eax
  800dcc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dcf:	80 39 01             	cmpb   $0x1,(%ecx)
  800dd2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dd5:	39 da                	cmp    %ebx,%edx
  800dd7:	75 ed                	jne    800dc6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	8b 75 08             	mov    0x8(%ebp),%esi
  800de7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ded:	89 f0                	mov    %esi,%eax
  800def:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800df3:	85 c9                	test   %ecx,%ecx
  800df5:	75 0b                	jne    800e02 <strlcpy+0x23>
  800df7:	eb 1d                	jmp    800e16 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800df9:	83 c0 01             	add    $0x1,%eax
  800dfc:	83 c2 01             	add    $0x1,%edx
  800dff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e02:	39 d8                	cmp    %ebx,%eax
  800e04:	74 0b                	je     800e11 <strlcpy+0x32>
  800e06:	0f b6 0a             	movzbl (%edx),%ecx
  800e09:	84 c9                	test   %cl,%cl
  800e0b:	75 ec                	jne    800df9 <strlcpy+0x1a>
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	eb 02                	jmp    800e13 <strlcpy+0x34>
  800e11:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800e13:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800e16:	29 f0                	sub    %esi,%eax
}
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e22:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e25:	eb 06                	jmp    800e2d <strcmp+0x11>
		p++, q++;
  800e27:	83 c1 01             	add    $0x1,%ecx
  800e2a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e2d:	0f b6 01             	movzbl (%ecx),%eax
  800e30:	84 c0                	test   %al,%al
  800e32:	74 04                	je     800e38 <strcmp+0x1c>
  800e34:	3a 02                	cmp    (%edx),%al
  800e36:	74 ef                	je     800e27 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e38:	0f b6 c0             	movzbl %al,%eax
  800e3b:	0f b6 12             	movzbl (%edx),%edx
  800e3e:	29 d0                	sub    %edx,%eax
}
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	53                   	push   %ebx
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4c:	89 c3                	mov    %eax,%ebx
  800e4e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e51:	eb 06                	jmp    800e59 <strncmp+0x17>
		n--, p++, q++;
  800e53:	83 c0 01             	add    $0x1,%eax
  800e56:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e59:	39 d8                	cmp    %ebx,%eax
  800e5b:	74 15                	je     800e72 <strncmp+0x30>
  800e5d:	0f b6 08             	movzbl (%eax),%ecx
  800e60:	84 c9                	test   %cl,%cl
  800e62:	74 04                	je     800e68 <strncmp+0x26>
  800e64:	3a 0a                	cmp    (%edx),%cl
  800e66:	74 eb                	je     800e53 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e68:	0f b6 00             	movzbl (%eax),%eax
  800e6b:	0f b6 12             	movzbl (%edx),%edx
  800e6e:	29 d0                	sub    %edx,%eax
  800e70:	eb 05                	jmp    800e77 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e77:	5b                   	pop    %ebx
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e84:	eb 07                	jmp    800e8d <strchr+0x13>
		if (*s == c)
  800e86:	38 ca                	cmp    %cl,%dl
  800e88:	74 0f                	je     800e99 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e8a:	83 c0 01             	add    $0x1,%eax
  800e8d:	0f b6 10             	movzbl (%eax),%edx
  800e90:	84 d2                	test   %dl,%dl
  800e92:	75 f2                	jne    800e86 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ea5:	eb 07                	jmp    800eae <strfind+0x13>
		if (*s == c)
  800ea7:	38 ca                	cmp    %cl,%dl
  800ea9:	74 0a                	je     800eb5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800eab:	83 c0 01             	add    $0x1,%eax
  800eae:	0f b6 10             	movzbl (%eax),%edx
  800eb1:	84 d2                	test   %dl,%dl
  800eb3:	75 f2                	jne    800ea7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	57                   	push   %edi
  800ebb:	56                   	push   %esi
  800ebc:	53                   	push   %ebx
  800ebd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ec0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ec3:	85 c9                	test   %ecx,%ecx
  800ec5:	74 36                	je     800efd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ec7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ecd:	75 28                	jne    800ef7 <memset+0x40>
  800ecf:	f6 c1 03             	test   $0x3,%cl
  800ed2:	75 23                	jne    800ef7 <memset+0x40>
		c &= 0xFF;
  800ed4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ed8:	89 d3                	mov    %edx,%ebx
  800eda:	c1 e3 08             	shl    $0x8,%ebx
  800edd:	89 d6                	mov    %edx,%esi
  800edf:	c1 e6 18             	shl    $0x18,%esi
  800ee2:	89 d0                	mov    %edx,%eax
  800ee4:	c1 e0 10             	shl    $0x10,%eax
  800ee7:	09 f0                	or     %esi,%eax
  800ee9:	09 c2                	or     %eax,%edx
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ef2:	fc                   	cld    
  800ef3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ef5:	eb 06                	jmp    800efd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efa:	fc                   	cld    
  800efb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800efd:	89 f8                	mov    %edi,%eax
  800eff:	5b                   	pop    %ebx
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f12:	39 c6                	cmp    %eax,%esi
  800f14:	73 35                	jae    800f4b <memmove+0x47>
  800f16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f19:	39 d0                	cmp    %edx,%eax
  800f1b:	73 2e                	jae    800f4b <memmove+0x47>
		s += n;
		d += n;
  800f1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800f20:	89 d6                	mov    %edx,%esi
  800f22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f2a:	75 13                	jne    800f3f <memmove+0x3b>
  800f2c:	f6 c1 03             	test   $0x3,%cl
  800f2f:	75 0e                	jne    800f3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f31:	83 ef 04             	sub    $0x4,%edi
  800f34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f3a:	fd                   	std    
  800f3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f3d:	eb 09                	jmp    800f48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f3f:	83 ef 01             	sub    $0x1,%edi
  800f42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f45:	fd                   	std    
  800f46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f48:	fc                   	cld    
  800f49:	eb 1d                	jmp    800f68 <memmove+0x64>
  800f4b:	89 f2                	mov    %esi,%edx
  800f4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f4f:	f6 c2 03             	test   $0x3,%dl
  800f52:	75 0f                	jne    800f63 <memmove+0x5f>
  800f54:	f6 c1 03             	test   $0x3,%cl
  800f57:	75 0a                	jne    800f63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f59:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f5c:	89 c7                	mov    %eax,%edi
  800f5e:	fc                   	cld    
  800f5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f61:	eb 05                	jmp    800f68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f63:	89 c7                	mov    %eax,%edi
  800f65:	fc                   	cld    
  800f66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f72:	8b 45 10             	mov    0x10(%ebp),%eax
  800f75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	89 04 24             	mov    %eax,(%esp)
  800f86:	e8 79 ff ff ff       	call   800f04 <memmove>
}
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f98:	89 d6                	mov    %edx,%esi
  800f9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f9d:	eb 1a                	jmp    800fb9 <memcmp+0x2c>
		if (*s1 != *s2)
  800f9f:	0f b6 02             	movzbl (%edx),%eax
  800fa2:	0f b6 19             	movzbl (%ecx),%ebx
  800fa5:	38 d8                	cmp    %bl,%al
  800fa7:	74 0a                	je     800fb3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800fa9:	0f b6 c0             	movzbl %al,%eax
  800fac:	0f b6 db             	movzbl %bl,%ebx
  800faf:	29 d8                	sub    %ebx,%eax
  800fb1:	eb 0f                	jmp    800fc2 <memcmp+0x35>
		s1++, s2++;
  800fb3:	83 c2 01             	add    $0x1,%edx
  800fb6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fb9:	39 f2                	cmp    %esi,%edx
  800fbb:	75 e2                	jne    800f9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fc2:	5b                   	pop    %ebx
  800fc3:	5e                   	pop    %esi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fcf:	89 c2                	mov    %eax,%edx
  800fd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fd4:	eb 07                	jmp    800fdd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fd6:	38 08                	cmp    %cl,(%eax)
  800fd8:	74 07                	je     800fe1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fda:	83 c0 01             	add    $0x1,%eax
  800fdd:	39 d0                	cmp    %edx,%eax
  800fdf:	72 f5                	jb     800fd6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fef:	eb 03                	jmp    800ff4 <strtol+0x11>
		s++;
  800ff1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ff4:	0f b6 0a             	movzbl (%edx),%ecx
  800ff7:	80 f9 09             	cmp    $0x9,%cl
  800ffa:	74 f5                	je     800ff1 <strtol+0xe>
  800ffc:	80 f9 20             	cmp    $0x20,%cl
  800fff:	74 f0                	je     800ff1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801001:	80 f9 2b             	cmp    $0x2b,%cl
  801004:	75 0a                	jne    801010 <strtol+0x2d>
		s++;
  801006:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801009:	bf 00 00 00 00       	mov    $0x0,%edi
  80100e:	eb 11                	jmp    801021 <strtol+0x3e>
  801010:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801015:	80 f9 2d             	cmp    $0x2d,%cl
  801018:	75 07                	jne    801021 <strtol+0x3e>
		s++, neg = 1;
  80101a:	8d 52 01             	lea    0x1(%edx),%edx
  80101d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801021:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801026:	75 15                	jne    80103d <strtol+0x5a>
  801028:	80 3a 30             	cmpb   $0x30,(%edx)
  80102b:	75 10                	jne    80103d <strtol+0x5a>
  80102d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801031:	75 0a                	jne    80103d <strtol+0x5a>
		s += 2, base = 16;
  801033:	83 c2 02             	add    $0x2,%edx
  801036:	b8 10 00 00 00       	mov    $0x10,%eax
  80103b:	eb 10                	jmp    80104d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80103d:	85 c0                	test   %eax,%eax
  80103f:	75 0c                	jne    80104d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801041:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801043:	80 3a 30             	cmpb   $0x30,(%edx)
  801046:	75 05                	jne    80104d <strtol+0x6a>
		s++, base = 8;
  801048:	83 c2 01             	add    $0x1,%edx
  80104b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80104d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801052:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801055:	0f b6 0a             	movzbl (%edx),%ecx
  801058:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80105b:	89 f0                	mov    %esi,%eax
  80105d:	3c 09                	cmp    $0x9,%al
  80105f:	77 08                	ja     801069 <strtol+0x86>
			dig = *s - '0';
  801061:	0f be c9             	movsbl %cl,%ecx
  801064:	83 e9 30             	sub    $0x30,%ecx
  801067:	eb 20                	jmp    801089 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801069:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80106c:	89 f0                	mov    %esi,%eax
  80106e:	3c 19                	cmp    $0x19,%al
  801070:	77 08                	ja     80107a <strtol+0x97>
			dig = *s - 'a' + 10;
  801072:	0f be c9             	movsbl %cl,%ecx
  801075:	83 e9 57             	sub    $0x57,%ecx
  801078:	eb 0f                	jmp    801089 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80107a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80107d:	89 f0                	mov    %esi,%eax
  80107f:	3c 19                	cmp    $0x19,%al
  801081:	77 16                	ja     801099 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801083:	0f be c9             	movsbl %cl,%ecx
  801086:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801089:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80108c:	7d 0f                	jge    80109d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80108e:	83 c2 01             	add    $0x1,%edx
  801091:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801095:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801097:	eb bc                	jmp    801055 <strtol+0x72>
  801099:	89 d8                	mov    %ebx,%eax
  80109b:	eb 02                	jmp    80109f <strtol+0xbc>
  80109d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80109f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010a3:	74 05                	je     8010aa <strtol+0xc7>
		*endptr = (char *) s;
  8010a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8010aa:	f7 d8                	neg    %eax
  8010ac:	85 ff                	test   %edi,%edi
  8010ae:	0f 44 c3             	cmove  %ebx,%eax
}
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	57                   	push   %edi
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	89 c3                	mov    %eax,%ebx
  8010c9:	89 c7                	mov    %eax,%edi
  8010cb:	89 c6                	mov    %eax,%esi
  8010cd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010da:	ba 00 00 00 00       	mov    $0x0,%edx
  8010df:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e4:	89 d1                	mov    %edx,%ecx
  8010e6:	89 d3                	mov    %edx,%ebx
  8010e8:	89 d7                	mov    %edx,%edi
  8010ea:	89 d6                	mov    %edx,%esi
  8010ec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010ee:	5b                   	pop    %ebx
  8010ef:	5e                   	pop    %esi
  8010f0:	5f                   	pop    %edi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801101:	b8 03 00 00 00       	mov    $0x3,%eax
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	89 cb                	mov    %ecx,%ebx
  80110b:	89 cf                	mov    %ecx,%edi
  80110d:	89 ce                	mov    %ecx,%esi
  80110f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801111:	85 c0                	test   %eax,%eax
  801113:	7e 28                	jle    80113d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801115:	89 44 24 10          	mov    %eax,0x10(%esp)
  801119:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801120:	00 
  801121:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  801128:	00 
  801129:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801130:	00 
  801131:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  801138:	e8 03 f0 ff ff       	call   800140 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80113d:	83 c4 2c             	add    $0x2c,%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5f                   	pop    %edi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114b:	ba 00 00 00 00       	mov    $0x0,%edx
  801150:	b8 02 00 00 00       	mov    $0x2,%eax
  801155:	89 d1                	mov    %edx,%ecx
  801157:	89 d3                	mov    %edx,%ebx
  801159:	89 d7                	mov    %edx,%edi
  80115b:	89 d6                	mov    %edx,%esi
  80115d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <sys_yield>:

void
sys_yield(void)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116a:	ba 00 00 00 00       	mov    $0x0,%edx
  80116f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801174:	89 d1                	mov    %edx,%ecx
  801176:	89 d3                	mov    %edx,%ebx
  801178:	89 d7                	mov    %edx,%edi
  80117a:	89 d6                	mov    %edx,%esi
  80117c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80117e:	5b                   	pop    %ebx
  80117f:	5e                   	pop    %esi
  801180:	5f                   	pop    %edi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	57                   	push   %edi
  801187:	56                   	push   %esi
  801188:	53                   	push   %ebx
  801189:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118c:	be 00 00 00 00       	mov    $0x0,%esi
  801191:	b8 04 00 00 00       	mov    $0x4,%eax
  801196:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801199:	8b 55 08             	mov    0x8(%ebp),%edx
  80119c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119f:	89 f7                	mov    %esi,%edi
  8011a1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	7e 28                	jle    8011cf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  8011ca:	e8 71 ef ff ff       	call   800140 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011cf:	83 c4 2c             	add    $0x2c,%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	57                   	push   %edi
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8011e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	7e 28                	jle    801222 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011fe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801205:	00 
  801206:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  80120d:	00 
  80120e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801215:	00 
  801216:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  80121d:	e8 1e ef ff ff       	call   800140 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801222:	83 c4 2c             	add    $0x2c,%esp
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	57                   	push   %edi
  80122e:	56                   	push   %esi
  80122f:	53                   	push   %ebx
  801230:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801233:	bb 00 00 00 00       	mov    $0x0,%ebx
  801238:	b8 06 00 00 00       	mov    $0x6,%eax
  80123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801240:	8b 55 08             	mov    0x8(%ebp),%edx
  801243:	89 df                	mov    %ebx,%edi
  801245:	89 de                	mov    %ebx,%esi
  801247:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801249:	85 c0                	test   %eax,%eax
  80124b:	7e 28                	jle    801275 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80124d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801251:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801258:	00 
  801259:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  801260:	00 
  801261:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  801270:	e8 cb ee ff ff       	call   800140 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801275:	83 c4 2c             	add    $0x2c,%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	57                   	push   %edi
  801281:	56                   	push   %esi
  801282:	53                   	push   %ebx
  801283:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801286:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128b:	b8 08 00 00 00       	mov    $0x8,%eax
  801290:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801293:	8b 55 08             	mov    0x8(%ebp),%edx
  801296:	89 df                	mov    %ebx,%edi
  801298:	89 de                	mov    %ebx,%esi
  80129a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80129c:	85 c0                	test   %eax,%eax
  80129e:	7e 28                	jle    8012c8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8012ab:	00 
  8012ac:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  8012b3:	00 
  8012b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012bb:	00 
  8012bc:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  8012c3:	e8 78 ee ff ff       	call   800140 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012c8:	83 c4 2c             	add    $0x2c,%esp
  8012cb:	5b                   	pop    %ebx
  8012cc:	5e                   	pop    %esi
  8012cd:	5f                   	pop    %edi
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    

008012d0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	57                   	push   %edi
  8012d4:	56                   	push   %esi
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012de:	b8 09 00 00 00       	mov    $0x9,%eax
  8012e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e9:	89 df                	mov    %ebx,%edi
  8012eb:	89 de                	mov    %ebx,%esi
  8012ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	7e 28                	jle    80131b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012fe:	00 
  8012ff:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  801306:	00 
  801307:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80130e:	00 
  80130f:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  801316:	e8 25 ee ff ff       	call   800140 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80131b:	83 c4 2c             	add    $0x2c,%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801329:	be 00 00 00 00       	mov    $0x0,%esi
  80132e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801336:	8b 55 08             	mov    0x8(%ebp),%edx
  801339:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80133f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	57                   	push   %edi
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80134f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801354:	b8 0c 00 00 00       	mov    $0xc,%eax
  801359:	8b 55 08             	mov    0x8(%ebp),%edx
  80135c:	89 cb                	mov    %ecx,%ebx
  80135e:	89 cf                	mov    %ecx,%edi
  801360:	89 ce                	mov    %ecx,%esi
  801362:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801364:	85 c0                	test   %eax,%eax
  801366:	7e 28                	jle    801390 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801368:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801373:	00 
  801374:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  80137b:	00 
  80137c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801383:	00 
  801384:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  80138b:	e8 b0 ed ff ff       	call   800140 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801390:	83 c4 2c             	add    $0x2c,%esp
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80139e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8013a5:	75 32                	jne    8013d9 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  8013a7:	e8 99 fd ff ff       	call   801145 <sys_getenvid>
  8013ac:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013b3:	00 
  8013b4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013bb:	ee 
  8013bc:	89 04 24             	mov    %eax,(%esp)
  8013bf:	e8 bf fd ff ff       	call   801183 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  8013c4:	e8 7c fd ff ff       	call   801145 <sys_getenvid>
  8013c9:	c7 44 24 04 e3 13 80 	movl   $0x8013e3,0x4(%esp)
  8013d0:	00 
  8013d1:	89 04 24             	mov    %eax,(%esp)
  8013d4:	e8 f7 fe ff ff       	call   8012d0 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dc:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8013e1:	c9                   	leave  
  8013e2:	c3                   	ret    

008013e3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013e3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013e4:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8013e9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013eb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  8013ee:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  8013f1:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  8013f5:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  8013f9:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  8013fc:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  801400:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  801402:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  801403:	83 c4 04             	add    $0x4,%esp
	popfl 	
  801406:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801407:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801408:	c3                   	ret    
  801409:	66 90                	xchg   %ax,%ax
  80140b:	66 90                	xchg   %ax,%ax
  80140d:	66 90                	xchg   %ax,%ax
  80140f:	90                   	nop

00801410 <__udivdi3>:
  801410:	55                   	push   %ebp
  801411:	57                   	push   %edi
  801412:	56                   	push   %esi
  801413:	83 ec 0c             	sub    $0xc,%esp
  801416:	8b 44 24 28          	mov    0x28(%esp),%eax
  80141a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80141e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801422:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801426:	85 c0                	test   %eax,%eax
  801428:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80142c:	89 ea                	mov    %ebp,%edx
  80142e:	89 0c 24             	mov    %ecx,(%esp)
  801431:	75 2d                	jne    801460 <__udivdi3+0x50>
  801433:	39 e9                	cmp    %ebp,%ecx
  801435:	77 61                	ja     801498 <__udivdi3+0x88>
  801437:	85 c9                	test   %ecx,%ecx
  801439:	89 ce                	mov    %ecx,%esi
  80143b:	75 0b                	jne    801448 <__udivdi3+0x38>
  80143d:	b8 01 00 00 00       	mov    $0x1,%eax
  801442:	31 d2                	xor    %edx,%edx
  801444:	f7 f1                	div    %ecx
  801446:	89 c6                	mov    %eax,%esi
  801448:	31 d2                	xor    %edx,%edx
  80144a:	89 e8                	mov    %ebp,%eax
  80144c:	f7 f6                	div    %esi
  80144e:	89 c5                	mov    %eax,%ebp
  801450:	89 f8                	mov    %edi,%eax
  801452:	f7 f6                	div    %esi
  801454:	89 ea                	mov    %ebp,%edx
  801456:	83 c4 0c             	add    $0xc,%esp
  801459:	5e                   	pop    %esi
  80145a:	5f                   	pop    %edi
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    
  80145d:	8d 76 00             	lea    0x0(%esi),%esi
  801460:	39 e8                	cmp    %ebp,%eax
  801462:	77 24                	ja     801488 <__udivdi3+0x78>
  801464:	0f bd e8             	bsr    %eax,%ebp
  801467:	83 f5 1f             	xor    $0x1f,%ebp
  80146a:	75 3c                	jne    8014a8 <__udivdi3+0x98>
  80146c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801470:	39 34 24             	cmp    %esi,(%esp)
  801473:	0f 86 9f 00 00 00    	jbe    801518 <__udivdi3+0x108>
  801479:	39 d0                	cmp    %edx,%eax
  80147b:	0f 82 97 00 00 00    	jb     801518 <__udivdi3+0x108>
  801481:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801488:	31 d2                	xor    %edx,%edx
  80148a:	31 c0                	xor    %eax,%eax
  80148c:	83 c4 0c             	add    $0xc,%esp
  80148f:	5e                   	pop    %esi
  801490:	5f                   	pop    %edi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    
  801493:	90                   	nop
  801494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801498:	89 f8                	mov    %edi,%eax
  80149a:	f7 f1                	div    %ecx
  80149c:	31 d2                	xor    %edx,%edx
  80149e:	83 c4 0c             	add    $0xc,%esp
  8014a1:	5e                   	pop    %esi
  8014a2:	5f                   	pop    %edi
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    
  8014a5:	8d 76 00             	lea    0x0(%esi),%esi
  8014a8:	89 e9                	mov    %ebp,%ecx
  8014aa:	8b 3c 24             	mov    (%esp),%edi
  8014ad:	d3 e0                	shl    %cl,%eax
  8014af:	89 c6                	mov    %eax,%esi
  8014b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8014b6:	29 e8                	sub    %ebp,%eax
  8014b8:	89 c1                	mov    %eax,%ecx
  8014ba:	d3 ef                	shr    %cl,%edi
  8014bc:	89 e9                	mov    %ebp,%ecx
  8014be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014c2:	8b 3c 24             	mov    (%esp),%edi
  8014c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8014c9:	89 d6                	mov    %edx,%esi
  8014cb:	d3 e7                	shl    %cl,%edi
  8014cd:	89 c1                	mov    %eax,%ecx
  8014cf:	89 3c 24             	mov    %edi,(%esp)
  8014d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014d6:	d3 ee                	shr    %cl,%esi
  8014d8:	89 e9                	mov    %ebp,%ecx
  8014da:	d3 e2                	shl    %cl,%edx
  8014dc:	89 c1                	mov    %eax,%ecx
  8014de:	d3 ef                	shr    %cl,%edi
  8014e0:	09 d7                	or     %edx,%edi
  8014e2:	89 f2                	mov    %esi,%edx
  8014e4:	89 f8                	mov    %edi,%eax
  8014e6:	f7 74 24 08          	divl   0x8(%esp)
  8014ea:	89 d6                	mov    %edx,%esi
  8014ec:	89 c7                	mov    %eax,%edi
  8014ee:	f7 24 24             	mull   (%esp)
  8014f1:	39 d6                	cmp    %edx,%esi
  8014f3:	89 14 24             	mov    %edx,(%esp)
  8014f6:	72 30                	jb     801528 <__udivdi3+0x118>
  8014f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014fc:	89 e9                	mov    %ebp,%ecx
  8014fe:	d3 e2                	shl    %cl,%edx
  801500:	39 c2                	cmp    %eax,%edx
  801502:	73 05                	jae    801509 <__udivdi3+0xf9>
  801504:	3b 34 24             	cmp    (%esp),%esi
  801507:	74 1f                	je     801528 <__udivdi3+0x118>
  801509:	89 f8                	mov    %edi,%eax
  80150b:	31 d2                	xor    %edx,%edx
  80150d:	e9 7a ff ff ff       	jmp    80148c <__udivdi3+0x7c>
  801512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801518:	31 d2                	xor    %edx,%edx
  80151a:	b8 01 00 00 00       	mov    $0x1,%eax
  80151f:	e9 68 ff ff ff       	jmp    80148c <__udivdi3+0x7c>
  801524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801528:	8d 47 ff             	lea    -0x1(%edi),%eax
  80152b:	31 d2                	xor    %edx,%edx
  80152d:	83 c4 0c             	add    $0xc,%esp
  801530:	5e                   	pop    %esi
  801531:	5f                   	pop    %edi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    
  801534:	66 90                	xchg   %ax,%ax
  801536:	66 90                	xchg   %ax,%ax
  801538:	66 90                	xchg   %ax,%ax
  80153a:	66 90                	xchg   %ax,%ax
  80153c:	66 90                	xchg   %ax,%ax
  80153e:	66 90                	xchg   %ax,%ax

00801540 <__umoddi3>:
  801540:	55                   	push   %ebp
  801541:	57                   	push   %edi
  801542:	56                   	push   %esi
  801543:	83 ec 14             	sub    $0x14,%esp
  801546:	8b 44 24 28          	mov    0x28(%esp),%eax
  80154a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80154e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801552:	89 c7                	mov    %eax,%edi
  801554:	89 44 24 04          	mov    %eax,0x4(%esp)
  801558:	8b 44 24 30          	mov    0x30(%esp),%eax
  80155c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801560:	89 34 24             	mov    %esi,(%esp)
  801563:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801567:	85 c0                	test   %eax,%eax
  801569:	89 c2                	mov    %eax,%edx
  80156b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80156f:	75 17                	jne    801588 <__umoddi3+0x48>
  801571:	39 fe                	cmp    %edi,%esi
  801573:	76 4b                	jbe    8015c0 <__umoddi3+0x80>
  801575:	89 c8                	mov    %ecx,%eax
  801577:	89 fa                	mov    %edi,%edx
  801579:	f7 f6                	div    %esi
  80157b:	89 d0                	mov    %edx,%eax
  80157d:	31 d2                	xor    %edx,%edx
  80157f:	83 c4 14             	add    $0x14,%esp
  801582:	5e                   	pop    %esi
  801583:	5f                   	pop    %edi
  801584:	5d                   	pop    %ebp
  801585:	c3                   	ret    
  801586:	66 90                	xchg   %ax,%ax
  801588:	39 f8                	cmp    %edi,%eax
  80158a:	77 54                	ja     8015e0 <__umoddi3+0xa0>
  80158c:	0f bd e8             	bsr    %eax,%ebp
  80158f:	83 f5 1f             	xor    $0x1f,%ebp
  801592:	75 5c                	jne    8015f0 <__umoddi3+0xb0>
  801594:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801598:	39 3c 24             	cmp    %edi,(%esp)
  80159b:	0f 87 e7 00 00 00    	ja     801688 <__umoddi3+0x148>
  8015a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015a5:	29 f1                	sub    %esi,%ecx
  8015a7:	19 c7                	sbb    %eax,%edi
  8015a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015b9:	83 c4 14             	add    $0x14,%esp
  8015bc:	5e                   	pop    %esi
  8015bd:	5f                   	pop    %edi
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    
  8015c0:	85 f6                	test   %esi,%esi
  8015c2:	89 f5                	mov    %esi,%ebp
  8015c4:	75 0b                	jne    8015d1 <__umoddi3+0x91>
  8015c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015cb:	31 d2                	xor    %edx,%edx
  8015cd:	f7 f6                	div    %esi
  8015cf:	89 c5                	mov    %eax,%ebp
  8015d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8015d5:	31 d2                	xor    %edx,%edx
  8015d7:	f7 f5                	div    %ebp
  8015d9:	89 c8                	mov    %ecx,%eax
  8015db:	f7 f5                	div    %ebp
  8015dd:	eb 9c                	jmp    80157b <__umoddi3+0x3b>
  8015df:	90                   	nop
  8015e0:	89 c8                	mov    %ecx,%eax
  8015e2:	89 fa                	mov    %edi,%edx
  8015e4:	83 c4 14             	add    $0x14,%esp
  8015e7:	5e                   	pop    %esi
  8015e8:	5f                   	pop    %edi
  8015e9:	5d                   	pop    %ebp
  8015ea:	c3                   	ret    
  8015eb:	90                   	nop
  8015ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015f0:	8b 04 24             	mov    (%esp),%eax
  8015f3:	be 20 00 00 00       	mov    $0x20,%esi
  8015f8:	89 e9                	mov    %ebp,%ecx
  8015fa:	29 ee                	sub    %ebp,%esi
  8015fc:	d3 e2                	shl    %cl,%edx
  8015fe:	89 f1                	mov    %esi,%ecx
  801600:	d3 e8                	shr    %cl,%eax
  801602:	89 e9                	mov    %ebp,%ecx
  801604:	89 44 24 04          	mov    %eax,0x4(%esp)
  801608:	8b 04 24             	mov    (%esp),%eax
  80160b:	09 54 24 04          	or     %edx,0x4(%esp)
  80160f:	89 fa                	mov    %edi,%edx
  801611:	d3 e0                	shl    %cl,%eax
  801613:	89 f1                	mov    %esi,%ecx
  801615:	89 44 24 08          	mov    %eax,0x8(%esp)
  801619:	8b 44 24 10          	mov    0x10(%esp),%eax
  80161d:	d3 ea                	shr    %cl,%edx
  80161f:	89 e9                	mov    %ebp,%ecx
  801621:	d3 e7                	shl    %cl,%edi
  801623:	89 f1                	mov    %esi,%ecx
  801625:	d3 e8                	shr    %cl,%eax
  801627:	89 e9                	mov    %ebp,%ecx
  801629:	09 f8                	or     %edi,%eax
  80162b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80162f:	f7 74 24 04          	divl   0x4(%esp)
  801633:	d3 e7                	shl    %cl,%edi
  801635:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801639:	89 d7                	mov    %edx,%edi
  80163b:	f7 64 24 08          	mull   0x8(%esp)
  80163f:	39 d7                	cmp    %edx,%edi
  801641:	89 c1                	mov    %eax,%ecx
  801643:	89 14 24             	mov    %edx,(%esp)
  801646:	72 2c                	jb     801674 <__umoddi3+0x134>
  801648:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80164c:	72 22                	jb     801670 <__umoddi3+0x130>
  80164e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801652:	29 c8                	sub    %ecx,%eax
  801654:	19 d7                	sbb    %edx,%edi
  801656:	89 e9                	mov    %ebp,%ecx
  801658:	89 fa                	mov    %edi,%edx
  80165a:	d3 e8                	shr    %cl,%eax
  80165c:	89 f1                	mov    %esi,%ecx
  80165e:	d3 e2                	shl    %cl,%edx
  801660:	89 e9                	mov    %ebp,%ecx
  801662:	d3 ef                	shr    %cl,%edi
  801664:	09 d0                	or     %edx,%eax
  801666:	89 fa                	mov    %edi,%edx
  801668:	83 c4 14             	add    $0x14,%esp
  80166b:	5e                   	pop    %esi
  80166c:	5f                   	pop    %edi
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    
  80166f:	90                   	nop
  801670:	39 d7                	cmp    %edx,%edi
  801672:	75 da                	jne    80164e <__umoddi3+0x10e>
  801674:	8b 14 24             	mov    (%esp),%edx
  801677:	89 c1                	mov    %eax,%ecx
  801679:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80167d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801681:	eb cb                	jmp    80164e <__umoddi3+0x10e>
  801683:	90                   	nop
  801684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801688:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80168c:	0f 82 0f ff ff ff    	jb     8015a1 <__umoddi3+0x61>
  801692:	e9 1a ff ff ff       	jmp    8015b1 <__umoddi3+0x71>
