
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
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
  800043:	c7 04 24 c0 16 80 00 	movl   $0x8016c0,(%esp)
  80004a:	e8 fa 01 00 00       	call   800249 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 25 11 00 00       	call   801193 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 e0 16 80 	movl   $0x8016e0,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 ca 16 80 00 	movl   $0x8016ca,(%esp)
  800091:	e8 ba 00 00 00       	call   800150 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 0c 17 80 	movl   $0x80170c,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 62 0c 00 00       	call   800d14 <snprintf>
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
  8000c5:	e8 de 12 00 00       	call   8013a8 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000ca:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d1:	de 
  8000d2:	c7 04 24 dc 16 80 00 	movl   $0x8016dc,(%esp)
  8000d9:	e8 6b 01 00 00       	call   800249 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000de:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e5:	ca 
  8000e6:	c7 04 24 dc 16 80 00 	movl   $0x8016dc,(%esp)
  8000ed:	e8 57 01 00 00       	call   800249 <cprintf>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ff:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800102:	e8 4e 10 00 00       	call   801155 <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x30>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800124:	89 74 24 04          	mov    %esi,0x4(%esp)
  800128:	89 1c 24             	mov    %ebx,(%esp)
  80012b:	e8 88 ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  800130:	e8 07 00 00 00       	call   80013c <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800149:	e8 b5 0f 00 00       	call   801103 <sys_env_destroy>
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800158:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800161:	e8 ef 0f 00 00       	call   801155 <sys_getenvid>
  800166:	8b 55 0c             	mov    0xc(%ebp),%edx
  800169:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800174:	89 74 24 08          	mov    %esi,0x8(%esp)
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 38 17 80 00 	movl   $0x801738,(%esp)
  800183:	e8 c1 00 00 00       	call   800249 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	89 04 24             	mov    %eax,(%esp)
  800192:	e8 51 00 00 00       	call   8001e8 <vcprintf>
	cprintf("\n");
  800197:	c7 04 24 de 16 80 00 	movl   $0x8016de,(%esp)
  80019e:	e8 a6 00 00 00       	call   800249 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x53>

008001a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 14             	sub    $0x14,%esp
  8001ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b0:	8b 13                	mov    (%ebx),%edx
  8001b2:	8d 42 01             	lea    0x1(%edx),%eax
  8001b5:	89 03                	mov    %eax,(%ebx)
  8001b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c3:	75 19                	jne    8001de <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cc:	00 
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 ee 0e 00 00       	call   8010c6 <sys_cputs>
		b->idx = 0;
  8001d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001de:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e2:	83 c4 14             	add    $0x14,%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f8:	00 00 00 
	b.cnt = 0;
  8001fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800202:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800205:	8b 45 0c             	mov    0xc(%ebp),%eax
  800208:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020c:	8b 45 08             	mov    0x8(%ebp),%eax
  80020f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800213:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021d:	c7 04 24 a6 01 80 00 	movl   $0x8001a6,(%esp)
  800224:	e8 b6 02 00 00       	call   8004df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800229:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800233:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800239:	89 04 24             	mov    %eax,(%esp)
  80023c:	e8 85 0e 00 00       	call   8010c6 <sys_cputs>

	return b.cnt;
}
  800241:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800252:	89 44 24 04          	mov    %eax,0x4(%esp)
  800256:	8b 45 08             	mov    0x8(%ebp),%eax
  800259:	89 04 24             	mov    %eax,(%esp)
  80025c:	e8 87 ff ff ff       	call   8001e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800261:	c9                   	leave  
  800262:	c3                   	ret    
  800263:	66 90                	xchg   %ax,%ax
  800265:	66 90                	xchg   %ax,%ax
  800267:	66 90                	xchg   %ax,%ax
  800269:	66 90                	xchg   %ax,%ax
  80026b:	66 90                	xchg   %ax,%ax
  80026d:	66 90                	xchg   %ax,%ax
  80026f:	90                   	nop

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 c3                	mov    %eax,%ebx
  800289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80028c:	8b 45 10             	mov    0x10(%ebp),%eax
  80028f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800292:	b9 00 00 00 00       	mov    $0x0,%ecx
  800297:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029d:	39 d9                	cmp    %ebx,%ecx
  80029f:	72 05                	jb     8002a6 <printnum+0x36>
  8002a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002a4:	77 69                	ja     80030f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ad:	83 ee 01             	sub    $0x1,%esi
  8002b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002c0:	89 c3                	mov    %eax,%ebx
  8002c2:	89 d6                	mov    %edx,%esi
  8002c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 3c 11 00 00       	call   801420 <__udivdi3>
  8002e4:	89 d9                	mov    %ebx,%ecx
  8002e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f5:	89 fa                	mov    %edi,%edx
  8002f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fa:	e8 71 ff ff ff       	call   800270 <printnum>
  8002ff:	eb 1b                	jmp    80031c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800305:	8b 45 18             	mov    0x18(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff d3                	call   *%ebx
  80030d:	eb 03                	jmp    800312 <printnum+0xa2>
  80030f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800312:	83 ee 01             	sub    $0x1,%esi
  800315:	85 f6                	test   %esi,%esi
  800317:	7f e8                	jg     800301 <printnum+0x91>
  800319:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800320:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800324:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800327:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80033b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033f:	e8 0c 12 00 00       	call   801550 <__umoddi3>
  800344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800348:	0f be 80 5c 17 80 00 	movsbl 0x80175c(%eax),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800355:	ff d0                	call   *%eax
}
  800357:	83 c4 3c             	add    $0x3c,%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	57                   	push   %edi
  800363:	56                   	push   %esi
  800364:	53                   	push   %ebx
  800365:	83 ec 3c             	sub    $0x3c,%esp
  800368:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80036b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80036e:	89 cf                	mov    %ecx,%edi
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800376:	8b 45 0c             	mov    0xc(%ebp),%eax
  800379:	89 c3                	mov    %eax,%ebx
  80037b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80037e:	8b 45 10             	mov    0x10(%ebp),%eax
  800381:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800384:	b9 00 00 00 00       	mov    $0x0,%ecx
  800389:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80038c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80038f:	39 d9                	cmp    %ebx,%ecx
  800391:	72 13                	jb     8003a6 <cprintnum+0x47>
  800393:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800396:	76 0e                	jbe    8003a6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800398:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039b:	0b 45 18             	or     0x18(%ebp),%eax
  80039e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003a4:	eb 6a                	jmp    800410 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8003a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003ad:	83 ee 01             	sub    $0x1,%esi
  8003b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003c0:	89 c3                	mov    %eax,%ebx
  8003c2:	89 d6                	mov    %edx,%esi
  8003c4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003c7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8003ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d5:	89 04 24             	mov    %eax,(%esp)
  8003d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003df:	e8 3c 10 00 00       	call   801420 <__udivdi3>
  8003e4:	89 d9                	mov    %ebx,%ecx
  8003e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003ee:	89 04 24             	mov    %eax,(%esp)
  8003f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003f5:	89 f9                	mov    %edi,%ecx
  8003f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003fd:	e8 5d ff ff ff       	call   80035f <cprintnum>
  800402:	eb 16                	jmp    80041a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800404:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800408:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800410:	83 ee 01             	sub    $0x1,%esi
  800413:	85 f6                	test   %esi,%esi
  800415:	7f ed                	jg     800404 <cprintnum+0xa5>
  800417:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80041a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80041e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800422:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800425:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800428:	89 44 24 08          	mov    %eax,0x8(%esp)
  80042c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800430:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800433:	89 04 24             	mov    %eax,(%esp)
  800436:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043d:	e8 0e 11 00 00       	call   801550 <__umoddi3>
  800442:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800446:	0f be 80 5c 17 80 00 	movsbl 0x80175c(%eax),%eax
  80044d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800456:	ff d0                	call   *%eax
}
  800458:	83 c4 3c             	add    $0x3c,%esp
  80045b:	5b                   	pop    %ebx
  80045c:	5e                   	pop    %esi
  80045d:	5f                   	pop    %edi
  80045e:	5d                   	pop    %ebp
  80045f:	c3                   	ret    

00800460 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800463:	83 fa 01             	cmp    $0x1,%edx
  800466:	7e 0e                	jle    800476 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800468:	8b 10                	mov    (%eax),%edx
  80046a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80046d:	89 08                	mov    %ecx,(%eax)
  80046f:	8b 02                	mov    (%edx),%eax
  800471:	8b 52 04             	mov    0x4(%edx),%edx
  800474:	eb 22                	jmp    800498 <getuint+0x38>
	else if (lflag)
  800476:	85 d2                	test   %edx,%edx
  800478:	74 10                	je     80048a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047f:	89 08                	mov    %ecx,(%eax)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	ba 00 00 00 00       	mov    $0x0,%edx
  800488:	eb 0e                	jmp    800498 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048f:	89 08                	mov    %ecx,(%eax)
  800491:	8b 02                	mov    (%edx),%eax
  800493:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800498:	5d                   	pop    %ebp
  800499:	c3                   	ret    

0080049a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  80049d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a4:	8b 10                	mov    (%eax),%edx
  8004a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a9:	73 0a                	jae    8004b5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b3:	88 02                	mov    %al,(%edx)
}
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    

008004b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
  8004ba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d5:	89 04 24             	mov    %eax,(%esp)
  8004d8:	e8 02 00 00 00       	call   8004df <vprintfmt>
	va_end(ap);
}
  8004dd:	c9                   	leave  
  8004de:	c3                   	ret    

008004df <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004df:	55                   	push   %ebp
  8004e0:	89 e5                	mov    %esp,%ebp
  8004e2:	57                   	push   %edi
  8004e3:	56                   	push   %esi
  8004e4:	53                   	push   %ebx
  8004e5:	83 ec 3c             	sub    $0x3c,%esp
  8004e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004ee:	eb 14                	jmp    800504 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	0f 84 b3 03 00 00    	je     8008ab <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8004f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800502:	89 f3                	mov    %esi,%ebx
  800504:	8d 73 01             	lea    0x1(%ebx),%esi
  800507:	0f b6 03             	movzbl (%ebx),%eax
  80050a:	83 f8 25             	cmp    $0x25,%eax
  80050d:	75 e1                	jne    8004f0 <vprintfmt+0x11>
  80050f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800513:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80051a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800521:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800528:	ba 00 00 00 00       	mov    $0x0,%edx
  80052d:	eb 1d                	jmp    80054c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800531:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800535:	eb 15                	jmp    80054c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800539:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80053d:	eb 0d                	jmp    80054c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80053f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800542:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800545:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80054f:	0f b6 0e             	movzbl (%esi),%ecx
  800552:	0f b6 c1             	movzbl %cl,%eax
  800555:	83 e9 23             	sub    $0x23,%ecx
  800558:	80 f9 55             	cmp    $0x55,%cl
  80055b:	0f 87 2a 03 00 00    	ja     80088b <vprintfmt+0x3ac>
  800561:	0f b6 c9             	movzbl %cl,%ecx
  800564:	ff 24 8d 20 18 80 00 	jmp    *0x801820(,%ecx,4)
  80056b:	89 de                	mov    %ebx,%esi
  80056d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800572:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800575:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800579:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80057c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80057f:	83 fb 09             	cmp    $0x9,%ebx
  800582:	77 36                	ja     8005ba <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800584:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800587:	eb e9                	jmp    800572 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 48 04             	lea    0x4(%eax),%ecx
  80058f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800599:	eb 22                	jmp    8005bd <vprintfmt+0xde>
  80059b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	0f 49 c1             	cmovns %ecx,%eax
  8005a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	89 de                	mov    %ebx,%esi
  8005ad:	eb 9d                	jmp    80054c <vprintfmt+0x6d>
  8005af:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005b8:	eb 92                	jmp    80054c <vprintfmt+0x6d>
  8005ba:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8005bd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c1:	79 89                	jns    80054c <vprintfmt+0x6d>
  8005c3:	e9 77 ff ff ff       	jmp    80053f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005cd:	e9 7a ff ff ff       	jmp    80054c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 04 24             	mov    %eax,(%esp)
  8005e4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005e7:	e9 18 ff ff ff       	jmp    800504 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	99                   	cltd   
  8005f8:	31 d0                	xor    %edx,%eax
  8005fa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fc:	83 f8 09             	cmp    $0x9,%eax
  8005ff:	7f 0b                	jg     80060c <vprintfmt+0x12d>
  800601:	8b 14 85 e0 1a 80 00 	mov    0x801ae0(,%eax,4),%edx
  800608:	85 d2                	test   %edx,%edx
  80060a:	75 20                	jne    80062c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80060c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800610:	c7 44 24 08 74 17 80 	movl   $0x801774,0x8(%esp)
  800617:	00 
  800618:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	89 04 24             	mov    %eax,(%esp)
  800622:	e8 90 fe ff ff       	call   8004b7 <printfmt>
  800627:	e9 d8 fe ff ff       	jmp    800504 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80062c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800630:	c7 44 24 08 7d 17 80 	movl   $0x80177d,0x8(%esp)
  800637:	00 
  800638:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063c:	8b 45 08             	mov    0x8(%ebp),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	e8 70 fe ff ff       	call   8004b7 <printfmt>
  800647:	e9 b8 fe ff ff       	jmp    800504 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80064f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800652:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 04             	lea    0x4(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800660:	85 f6                	test   %esi,%esi
  800662:	b8 6d 17 80 00       	mov    $0x80176d,%eax
  800667:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80066a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80066e:	0f 84 97 00 00 00    	je     80070b <vprintfmt+0x22c>
  800674:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800678:	0f 8e 9b 00 00 00    	jle    800719 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800682:	89 34 24             	mov    %esi,(%esp)
  800685:	e8 ce 06 00 00       	call   800d58 <strnlen>
  80068a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80068d:	29 c2                	sub    %eax,%edx
  80068f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800692:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800696:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800699:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80069c:	8b 75 08             	mov    0x8(%ebp),%esi
  80069f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006a2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a4:	eb 0f                	jmp    8006b5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006ad:	89 04 24             	mov    %eax,(%esp)
  8006b0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	83 eb 01             	sub    $0x1,%ebx
  8006b5:	85 db                	test   %ebx,%ebx
  8006b7:	7f ed                	jg     8006a6 <vprintfmt+0x1c7>
  8006b9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006bc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c6:	0f 49 c2             	cmovns %edx,%eax
  8006c9:	29 c2                	sub    %eax,%edx
  8006cb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006ce:	89 d7                	mov    %edx,%edi
  8006d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006d3:	eb 50                	jmp    800725 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d9:	74 1e                	je     8006f9 <vprintfmt+0x21a>
  8006db:	0f be d2             	movsbl %dl,%edx
  8006de:	83 ea 20             	sub    $0x20,%edx
  8006e1:	83 fa 5e             	cmp    $0x5e,%edx
  8006e4:	76 13                	jbe    8006f9 <vprintfmt+0x21a>
					putch('?', putdat);
  8006e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ed:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006f4:	ff 55 08             	call   *0x8(%ebp)
  8006f7:	eb 0d                	jmp    800706 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8006f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800706:	83 ef 01             	sub    $0x1,%edi
  800709:	eb 1a                	jmp    800725 <vprintfmt+0x246>
  80070b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80070e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800711:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800714:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800717:	eb 0c                	jmp    800725 <vprintfmt+0x246>
  800719:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80071c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80071f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800722:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800725:	83 c6 01             	add    $0x1,%esi
  800728:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80072c:	0f be c2             	movsbl %dl,%eax
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 27                	je     80075a <vprintfmt+0x27b>
  800733:	85 db                	test   %ebx,%ebx
  800735:	78 9e                	js     8006d5 <vprintfmt+0x1f6>
  800737:	83 eb 01             	sub    $0x1,%ebx
  80073a:	79 99                	jns    8006d5 <vprintfmt+0x1f6>
  80073c:	89 f8                	mov    %edi,%eax
  80073e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800741:	8b 75 08             	mov    0x8(%ebp),%esi
  800744:	89 c3                	mov    %eax,%ebx
  800746:	eb 1a                	jmp    800762 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800748:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800753:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800755:	83 eb 01             	sub    $0x1,%ebx
  800758:	eb 08                	jmp    800762 <vprintfmt+0x283>
  80075a:	89 fb                	mov    %edi,%ebx
  80075c:	8b 75 08             	mov    0x8(%ebp),%esi
  80075f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800762:	85 db                	test   %ebx,%ebx
  800764:	7f e2                	jg     800748 <vprintfmt+0x269>
  800766:	89 75 08             	mov    %esi,0x8(%ebp)
  800769:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80076c:	e9 93 fd ff ff       	jmp    800504 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800771:	83 fa 01             	cmp    $0x1,%edx
  800774:	7e 16                	jle    80078c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8d 50 08             	lea    0x8(%eax),%edx
  80077c:	89 55 14             	mov    %edx,0x14(%ebp)
  80077f:	8b 50 04             	mov    0x4(%eax),%edx
  800782:	8b 00                	mov    (%eax),%eax
  800784:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800787:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80078a:	eb 32                	jmp    8007be <vprintfmt+0x2df>
	else if (lflag)
  80078c:	85 d2                	test   %edx,%edx
  80078e:	74 18                	je     8007a8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 50 04             	lea    0x4(%eax),%edx
  800796:	89 55 14             	mov    %edx,0x14(%ebp)
  800799:	8b 30                	mov    (%eax),%esi
  80079b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80079e:	89 f0                	mov    %esi,%eax
  8007a0:	c1 f8 1f             	sar    $0x1f,%eax
  8007a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a6:	eb 16                	jmp    8007be <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8d 50 04             	lea    0x4(%eax),%edx
  8007ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b1:	8b 30                	mov    (%eax),%esi
  8007b3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007b6:	89 f0                	mov    %esi,%eax
  8007b8:	c1 f8 1f             	sar    $0x1f,%eax
  8007bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007cd:	0f 89 80 00 00 00    	jns    800853 <vprintfmt+0x374>
				putch('-', putdat);
  8007d3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007de:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007e7:	f7 d8                	neg    %eax
  8007e9:	83 d2 00             	adc    $0x0,%edx
  8007ec:	f7 da                	neg    %edx
			}
			base = 10;
  8007ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007f3:	eb 5e                	jmp    800853 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f8:	e8 63 fc ff ff       	call   800460 <getuint>
			base = 10;
  8007fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800802:	eb 4f                	jmp    800853 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800804:	8d 45 14             	lea    0x14(%ebp),%eax
  800807:	e8 54 fc ff ff       	call   800460 <getuint>
			base = 8 ;
  80080c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800811:	eb 40                	jmp    800853 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800813:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800817:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80081e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800821:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800825:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80082c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80082f:	8b 45 14             	mov    0x14(%ebp),%eax
  800832:	8d 50 04             	lea    0x4(%eax),%edx
  800835:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800838:	8b 00                	mov    (%eax),%eax
  80083a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80083f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800844:	eb 0d                	jmp    800853 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 12 fc ff ff       	call   800460 <getuint>
			base = 16;
  80084e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800853:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800857:	89 74 24 10          	mov    %esi,0x10(%esp)
  80085b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80085e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800862:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	89 54 24 04          	mov    %edx,0x4(%esp)
  80086d:	89 fa                	mov    %edi,%edx
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	e8 f9 f9 ff ff       	call   800270 <printnum>
			break;
  800877:	e9 88 fc ff ff       	jmp    800504 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80087c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800880:	89 04 24             	mov    %eax,(%esp)
  800883:	ff 55 08             	call   *0x8(%ebp)
			break;
  800886:	e9 79 fc ff ff       	jmp    800504 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80088b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80088f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800896:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800899:	89 f3                	mov    %esi,%ebx
  80089b:	eb 03                	jmp    8008a0 <vprintfmt+0x3c1>
  80089d:	83 eb 01             	sub    $0x1,%ebx
  8008a0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008a4:	75 f7                	jne    80089d <vprintfmt+0x3be>
  8008a6:	e9 59 fc ff ff       	jmp    800504 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008ab:	83 c4 3c             	add    $0x3c,%esp
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5f                   	pop    %edi
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	57                   	push   %edi
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	83 ec 3c             	sub    $0x3c,%esp
  8008bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  8008bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c2:	8d 50 04             	lea    0x4(%eax),%edx
  8008c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c8:	8b 00                	mov    (%eax),%eax
  8008ca:	c1 e0 08             	shl    $0x8,%eax
  8008cd:	0f b7 c0             	movzwl %ax,%eax
  8008d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  8008d3:	83 c8 25             	or     $0x25,%eax
  8008d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8008d9:	eb 1a                	jmp    8008f5 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	0f 84 a9 03 00 00    	je     800c8c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  8008e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ea:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8008ed:	89 04 24             	mov    %eax,(%esp)
  8008f0:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008f3:	89 fb                	mov    %edi,%ebx
  8008f5:	8d 7b 01             	lea    0x1(%ebx),%edi
  8008f8:	0f b6 03             	movzbl (%ebx),%eax
  8008fb:	83 f8 25             	cmp    $0x25,%eax
  8008fe:	75 db                	jne    8008db <cvprintfmt+0x28>
  800900:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800904:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80090b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800910:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800917:	ba 00 00 00 00       	mov    $0x0,%edx
  80091c:	eb 18                	jmp    800936 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800920:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800924:	eb 10                	jmp    800936 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800926:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800928:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80092c:	eb 08                	jmp    800936 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80092e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800931:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800936:	8d 5f 01             	lea    0x1(%edi),%ebx
  800939:	0f b6 0f             	movzbl (%edi),%ecx
  80093c:	0f b6 c1             	movzbl %cl,%eax
  80093f:	83 e9 23             	sub    $0x23,%ecx
  800942:	80 f9 55             	cmp    $0x55,%cl
  800945:	0f 87 1f 03 00 00    	ja     800c6a <cvprintfmt+0x3b7>
  80094b:	0f b6 c9             	movzbl %cl,%ecx
  80094e:	ff 24 8d 78 19 80 00 	jmp    *0x801978(,%ecx,4)
  800955:	89 df                	mov    %ebx,%edi
  800957:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80095c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80095f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800963:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800966:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800969:	83 f9 09             	cmp    $0x9,%ecx
  80096c:	77 33                	ja     8009a1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80096e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800971:	eb e9                	jmp    80095c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800973:	8b 45 14             	mov    0x14(%ebp),%eax
  800976:	8d 48 04             	lea    0x4(%eax),%ecx
  800979:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80097c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800980:	eb 1f                	jmp    8009a1 <cvprintfmt+0xee>
  800982:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800985:	85 ff                	test   %edi,%edi
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
  80098c:	0f 49 c7             	cmovns %edi,%eax
  80098f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800992:	89 df                	mov    %ebx,%edi
  800994:	eb a0                	jmp    800936 <cvprintfmt+0x83>
  800996:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800998:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80099f:	eb 95                	jmp    800936 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  8009a1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009a5:	79 8f                	jns    800936 <cvprintfmt+0x83>
  8009a7:	eb 85                	jmp    80092e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ac:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009ae:	66 90                	xchg   %ax,%ax
  8009b0:	eb 84                	jmp    800936 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  8009b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b5:	8d 50 04             	lea    0x4(%eax),%edx
  8009b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009c5:	0b 10                	or     (%eax),%edx
  8009c7:	89 14 24             	mov    %edx,(%esp)
  8009ca:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009cd:	e9 23 ff ff ff       	jmp    8008f5 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d5:	8d 50 04             	lea    0x4(%eax),%edx
  8009d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009db:	8b 00                	mov    (%eax),%eax
  8009dd:	99                   	cltd   
  8009de:	31 d0                	xor    %edx,%eax
  8009e0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009e2:	83 f8 09             	cmp    $0x9,%eax
  8009e5:	7f 0b                	jg     8009f2 <cvprintfmt+0x13f>
  8009e7:	8b 14 85 e0 1a 80 00 	mov    0x801ae0(,%eax,4),%edx
  8009ee:	85 d2                	test   %edx,%edx
  8009f0:	75 23                	jne    800a15 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  8009f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f6:	c7 44 24 08 74 17 80 	movl   $0x801774,0x8(%esp)
  8009fd:	00 
  8009fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	e8 a7 fa ff ff       	call   8004b7 <printfmt>
  800a10:	e9 e0 fe ff ff       	jmp    8008f5 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800a15:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a19:	c7 44 24 08 7d 17 80 	movl   $0x80177d,0x8(%esp)
  800a20:	00 
  800a21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	89 04 24             	mov    %eax,(%esp)
  800a2e:	e8 84 fa ff ff       	call   8004b7 <printfmt>
  800a33:	e9 bd fe ff ff       	jmp    8008f5 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a38:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a3b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800a3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a41:	8d 48 04             	lea    0x4(%eax),%ecx
  800a44:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a47:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a49:	85 ff                	test   %edi,%edi
  800a4b:	b8 6d 17 80 00       	mov    $0x80176d,%eax
  800a50:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a53:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a57:	74 61                	je     800aba <cvprintfmt+0x207>
  800a59:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a5d:	7e 5b                	jle    800aba <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a63:	89 3c 24             	mov    %edi,(%esp)
  800a66:	e8 ed 02 00 00       	call   800d58 <strnlen>
  800a6b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a6e:	29 c2                	sub    %eax,%edx
  800a70:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800a73:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a77:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a7a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a7d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800a80:	8b 75 08             	mov    0x8(%ebp),%esi
  800a83:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a86:	89 d3                	mov    %edx,%ebx
  800a88:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a8a:	eb 0f                	jmp    800a9b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a93:	89 3c 24             	mov    %edi,(%esp)
  800a96:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a98:	83 eb 01             	sub    $0x1,%ebx
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	7f ed                	jg     800a8c <cvprintfmt+0x1d9>
  800a9f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800aa2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aa8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800aab:	85 d2                	test   %edx,%edx
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	0f 49 c2             	cmovns %edx,%eax
  800ab5:	29 c2                	sub    %eax,%edx
  800ab7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800aba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800abd:	83 c8 3f             	or     $0x3f,%eax
  800ac0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ac6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ac9:	eb 36                	jmp    800b01 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800acb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800acf:	74 1d                	je     800aee <cvprintfmt+0x23b>
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 20             	sub    $0x20,%edx
  800ad7:	83 fa 5e             	cmp    $0x5e,%edx
  800ada:	76 12                	jbe    800aee <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ae6:	89 04 24             	mov    %eax,(%esp)
  800ae9:	ff 55 08             	call   *0x8(%ebp)
  800aec:	eb 10                	jmp    800afe <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800af5:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800af8:	89 04 24             	mov    %eax,(%esp)
  800afb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800afe:	83 eb 01             	sub    $0x1,%ebx
  800b01:	83 c7 01             	add    $0x1,%edi
  800b04:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800b08:	0f be c2             	movsbl %dl,%eax
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	74 27                	je     800b36 <cvprintfmt+0x283>
  800b0f:	85 f6                	test   %esi,%esi
  800b11:	78 b8                	js     800acb <cvprintfmt+0x218>
  800b13:	83 ee 01             	sub    $0x1,%esi
  800b16:	79 b3                	jns    800acb <cvprintfmt+0x218>
  800b18:	89 d8                	mov    %ebx,%eax
  800b1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b20:	89 c3                	mov    %eax,%ebx
  800b22:	eb 18                	jmp    800b3c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800b24:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b2f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800b31:	83 eb 01             	sub    $0x1,%ebx
  800b34:	eb 06                	jmp    800b3c <cvprintfmt+0x289>
  800b36:	8b 75 08             	mov    0x8(%ebp),%esi
  800b39:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b3c:	85 db                	test   %ebx,%ebx
  800b3e:	7f e4                	jg     800b24 <cvprintfmt+0x271>
  800b40:	89 75 08             	mov    %esi,0x8(%ebp)
  800b43:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800b46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b49:	e9 a7 fd ff ff       	jmp    8008f5 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b4e:	83 fa 01             	cmp    $0x1,%edx
  800b51:	7e 10                	jle    800b63 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800b53:	8b 45 14             	mov    0x14(%ebp),%eax
  800b56:	8d 50 08             	lea    0x8(%eax),%edx
  800b59:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5c:	8b 30                	mov    (%eax),%esi
  800b5e:	8b 78 04             	mov    0x4(%eax),%edi
  800b61:	eb 26                	jmp    800b89 <cvprintfmt+0x2d6>
	else if (lflag)
  800b63:	85 d2                	test   %edx,%edx
  800b65:	74 12                	je     800b79 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800b67:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6a:	8d 50 04             	lea    0x4(%eax),%edx
  800b6d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b70:	8b 30                	mov    (%eax),%esi
  800b72:	89 f7                	mov    %esi,%edi
  800b74:	c1 ff 1f             	sar    $0x1f,%edi
  800b77:	eb 10                	jmp    800b89 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800b79:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7c:	8d 50 04             	lea    0x4(%eax),%edx
  800b7f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b82:	8b 30                	mov    (%eax),%esi
  800b84:	89 f7                	mov    %esi,%edi
  800b86:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b89:	89 f0                	mov    %esi,%eax
  800b8b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b8d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b92:	85 ff                	test   %edi,%edi
  800b94:	0f 89 8e 00 00 00    	jns    800c28 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ba4:	83 c8 2d             	or     $0x2d,%eax
  800ba7:	89 04 24             	mov    %eax,(%esp)
  800baa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	89 fa                	mov    %edi,%edx
  800bb1:	f7 d8                	neg    %eax
  800bb3:	83 d2 00             	adc    $0x0,%edx
  800bb6:	f7 da                	neg    %edx
			}
			base = 10;
  800bb8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bbd:	eb 69                	jmp    800c28 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bbf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc2:	e8 99 f8 ff ff       	call   800460 <getuint>
			base = 10;
  800bc7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bcc:	eb 5a                	jmp    800c28 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800bce:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd1:	e8 8a f8 ff ff       	call   800460 <getuint>
			base = 8 ;
  800bd6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800bdb:	eb 4b                	jmp    800c28 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800be7:	89 f0                	mov    %esi,%eax
  800be9:	83 c8 30             	or     $0x30,%eax
  800bec:	89 04 24             	mov    %eax,(%esp)
  800bef:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf9:	89 f0                	mov    %esi,%eax
  800bfb:	83 c8 78             	or     $0x78,%eax
  800bfe:	89 04 24             	mov    %eax,(%esp)
  800c01:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c04:	8b 45 14             	mov    0x14(%ebp),%eax
  800c07:	8d 50 04             	lea    0x4(%eax),%edx
  800c0a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800c0d:	8b 00                	mov    (%eax),%eax
  800c0f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c14:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c19:	eb 0d                	jmp    800c28 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c1e:	e8 3d f8 ff ff       	call   800460 <getuint>
			base = 16;
  800c23:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800c28:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800c2c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c30:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800c33:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c37:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c3b:	89 04 24             	mov    %eax,(%esp)
  800c3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c4b:	e8 0f f7 ff ff       	call   80035f <cprintnum>
			break;
  800c50:	e9 a0 fc ff ff       	jmp    8008f5 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800c55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c58:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c5c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800c5f:	89 04 24             	mov    %eax,(%esp)
  800c62:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c65:	e9 8b fc ff ff       	jmp    8008f5 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c71:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c74:	89 04 24             	mov    %eax,(%esp)
  800c77:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c7a:	89 fb                	mov    %edi,%ebx
  800c7c:	eb 03                	jmp    800c81 <cvprintfmt+0x3ce>
  800c7e:	83 eb 01             	sub    $0x1,%ebx
  800c81:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c85:	75 f7                	jne    800c7e <cvprintfmt+0x3cb>
  800c87:	e9 69 fc ff ff       	jmp    8008f5 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800c8c:	83 c4 3c             	add    $0x3c,%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c9a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800c9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ca1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb2:	89 04 24             	mov    %eax,(%esp)
  800cb5:	e8 f9 fb ff ff       	call   8008b3 <cvprintfmt>
	va_end(ap);
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 28             	sub    $0x28,%esp
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ccb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ccf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	74 30                	je     800d0d <vsnprintf+0x51>
  800cdd:	85 d2                	test   %edx,%edx
  800cdf:	7e 2c                	jle    800d0d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ce1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ce8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf6:	c7 04 24 9a 04 80 00 	movl   $0x80049a,(%esp)
  800cfd:	e8 dd f7 ff ff       	call   8004df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d05:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d0b:	eb 05                	jmp    800d12 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    

00800d14 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d1a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d21:	8b 45 10             	mov    0x10(%ebp),%eax
  800d24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	89 04 24             	mov    %eax,(%esp)
  800d35:	e8 82 ff ff ff       	call   800cbc <vsnprintf>
	va_end(ap);

	return rc;
}
  800d3a:	c9                   	leave  
  800d3b:	c3                   	ret    
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4b:	eb 03                	jmp    800d50 <strlen+0x10>
		n++;
  800d4d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d50:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d54:	75 f7                	jne    800d4d <strlen+0xd>
		n++;
	return n;
}
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d61:	b8 00 00 00 00       	mov    $0x0,%eax
  800d66:	eb 03                	jmp    800d6b <strnlen+0x13>
		n++;
  800d68:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d6b:	39 d0                	cmp    %edx,%eax
  800d6d:	74 06                	je     800d75 <strnlen+0x1d>
  800d6f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d73:	75 f3                	jne    800d68 <strnlen+0x10>
		n++;
	return n;
}
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	53                   	push   %ebx
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d81:	89 c2                	mov    %eax,%edx
  800d83:	83 c2 01             	add    $0x1,%edx
  800d86:	83 c1 01             	add    $0x1,%ecx
  800d89:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d8d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d90:	84 db                	test   %bl,%bl
  800d92:	75 ef                	jne    800d83 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d94:	5b                   	pop    %ebx
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 08             	sub    $0x8,%esp
  800d9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800da1:	89 1c 24             	mov    %ebx,(%esp)
  800da4:	e8 97 ff ff ff       	call   800d40 <strlen>
	strcpy(dst + len, src);
  800da9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dac:	89 54 24 04          	mov    %edx,0x4(%esp)
  800db0:	01 d8                	add    %ebx,%eax
  800db2:	89 04 24             	mov    %eax,(%esp)
  800db5:	e8 bd ff ff ff       	call   800d77 <strcpy>
	return dst;
}
  800dba:	89 d8                	mov    %ebx,%eax
  800dbc:	83 c4 08             	add    $0x8,%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	8b 75 08             	mov    0x8(%ebp),%esi
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	89 f3                	mov    %esi,%ebx
  800dcf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dd2:	89 f2                	mov    %esi,%edx
  800dd4:	eb 0f                	jmp    800de5 <strncpy+0x23>
		*dst++ = *src;
  800dd6:	83 c2 01             	add    $0x1,%edx
  800dd9:	0f b6 01             	movzbl (%ecx),%eax
  800ddc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ddf:	80 39 01             	cmpb   $0x1,(%ecx)
  800de2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800de5:	39 da                	cmp    %ebx,%edx
  800de7:	75 ed                	jne    800dd6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	8b 75 08             	mov    0x8(%ebp),%esi
  800df7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800dfd:	89 f0                	mov    %esi,%eax
  800dff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e03:	85 c9                	test   %ecx,%ecx
  800e05:	75 0b                	jne    800e12 <strlcpy+0x23>
  800e07:	eb 1d                	jmp    800e26 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e09:	83 c0 01             	add    $0x1,%eax
  800e0c:	83 c2 01             	add    $0x1,%edx
  800e0f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e12:	39 d8                	cmp    %ebx,%eax
  800e14:	74 0b                	je     800e21 <strlcpy+0x32>
  800e16:	0f b6 0a             	movzbl (%edx),%ecx
  800e19:	84 c9                	test   %cl,%cl
  800e1b:	75 ec                	jne    800e09 <strlcpy+0x1a>
  800e1d:	89 c2                	mov    %eax,%edx
  800e1f:	eb 02                	jmp    800e23 <strlcpy+0x34>
  800e21:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800e23:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800e26:	29 f0                	sub    %esi,%eax
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e35:	eb 06                	jmp    800e3d <strcmp+0x11>
		p++, q++;
  800e37:	83 c1 01             	add    $0x1,%ecx
  800e3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e3d:	0f b6 01             	movzbl (%ecx),%eax
  800e40:	84 c0                	test   %al,%al
  800e42:	74 04                	je     800e48 <strcmp+0x1c>
  800e44:	3a 02                	cmp    (%edx),%al
  800e46:	74 ef                	je     800e37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e48:	0f b6 c0             	movzbl %al,%eax
  800e4b:	0f b6 12             	movzbl (%edx),%edx
  800e4e:	29 d0                	sub    %edx,%eax
}
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	53                   	push   %ebx
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
  800e59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5c:	89 c3                	mov    %eax,%ebx
  800e5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e61:	eb 06                	jmp    800e69 <strncmp+0x17>
		n--, p++, q++;
  800e63:	83 c0 01             	add    $0x1,%eax
  800e66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e69:	39 d8                	cmp    %ebx,%eax
  800e6b:	74 15                	je     800e82 <strncmp+0x30>
  800e6d:	0f b6 08             	movzbl (%eax),%ecx
  800e70:	84 c9                	test   %cl,%cl
  800e72:	74 04                	je     800e78 <strncmp+0x26>
  800e74:	3a 0a                	cmp    (%edx),%cl
  800e76:	74 eb                	je     800e63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e78:	0f b6 00             	movzbl (%eax),%eax
  800e7b:	0f b6 12             	movzbl (%edx),%edx
  800e7e:	29 d0                	sub    %edx,%eax
  800e80:	eb 05                	jmp    800e87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e87:	5b                   	pop    %ebx
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e94:	eb 07                	jmp    800e9d <strchr+0x13>
		if (*s == c)
  800e96:	38 ca                	cmp    %cl,%dl
  800e98:	74 0f                	je     800ea9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e9a:	83 c0 01             	add    $0x1,%eax
  800e9d:	0f b6 10             	movzbl (%eax),%edx
  800ea0:	84 d2                	test   %dl,%dl
  800ea2:	75 f2                	jne    800e96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800eb5:	eb 07                	jmp    800ebe <strfind+0x13>
		if (*s == c)
  800eb7:	38 ca                	cmp    %cl,%dl
  800eb9:	74 0a                	je     800ec5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ebb:	83 c0 01             	add    $0x1,%eax
  800ebe:	0f b6 10             	movzbl (%eax),%edx
  800ec1:	84 d2                	test   %dl,%dl
  800ec3:	75 f2                	jne    800eb7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ed0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ed3:	85 c9                	test   %ecx,%ecx
  800ed5:	74 36                	je     800f0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ed7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800edd:	75 28                	jne    800f07 <memset+0x40>
  800edf:	f6 c1 03             	test   $0x3,%cl
  800ee2:	75 23                	jne    800f07 <memset+0x40>
		c &= 0xFF;
  800ee4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ee8:	89 d3                	mov    %edx,%ebx
  800eea:	c1 e3 08             	shl    $0x8,%ebx
  800eed:	89 d6                	mov    %edx,%esi
  800eef:	c1 e6 18             	shl    $0x18,%esi
  800ef2:	89 d0                	mov    %edx,%eax
  800ef4:	c1 e0 10             	shl    $0x10,%eax
  800ef7:	09 f0                	or     %esi,%eax
  800ef9:	09 c2                	or     %eax,%edx
  800efb:	89 d0                	mov    %edx,%eax
  800efd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f02:	fc                   	cld    
  800f03:	f3 ab                	rep stos %eax,%es:(%edi)
  800f05:	eb 06                	jmp    800f0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0a:	fc                   	cld    
  800f0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f0d:	89 f8                	mov    %edi,%eax
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f22:	39 c6                	cmp    %eax,%esi
  800f24:	73 35                	jae    800f5b <memmove+0x47>
  800f26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f29:	39 d0                	cmp    %edx,%eax
  800f2b:	73 2e                	jae    800f5b <memmove+0x47>
		s += n;
		d += n;
  800f2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800f30:	89 d6                	mov    %edx,%esi
  800f32:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f3a:	75 13                	jne    800f4f <memmove+0x3b>
  800f3c:	f6 c1 03             	test   $0x3,%cl
  800f3f:	75 0e                	jne    800f4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f41:	83 ef 04             	sub    $0x4,%edi
  800f44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f4a:	fd                   	std    
  800f4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f4d:	eb 09                	jmp    800f58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f4f:	83 ef 01             	sub    $0x1,%edi
  800f52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f55:	fd                   	std    
  800f56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f58:	fc                   	cld    
  800f59:	eb 1d                	jmp    800f78 <memmove+0x64>
  800f5b:	89 f2                	mov    %esi,%edx
  800f5d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f5f:	f6 c2 03             	test   $0x3,%dl
  800f62:	75 0f                	jne    800f73 <memmove+0x5f>
  800f64:	f6 c1 03             	test   $0x3,%cl
  800f67:	75 0a                	jne    800f73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f69:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f6c:	89 c7                	mov    %eax,%edi
  800f6e:	fc                   	cld    
  800f6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f71:	eb 05                	jmp    800f78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f73:	89 c7                	mov    %eax,%edi
  800f75:	fc                   	cld    
  800f76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f82:	8b 45 10             	mov    0x10(%ebp),%eax
  800f85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
  800f93:	89 04 24             	mov    %eax,(%esp)
  800f96:	e8 79 ff ff ff       	call   800f14 <memmove>
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
  800fa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa8:	89 d6                	mov    %edx,%esi
  800faa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fad:	eb 1a                	jmp    800fc9 <memcmp+0x2c>
		if (*s1 != *s2)
  800faf:	0f b6 02             	movzbl (%edx),%eax
  800fb2:	0f b6 19             	movzbl (%ecx),%ebx
  800fb5:	38 d8                	cmp    %bl,%al
  800fb7:	74 0a                	je     800fc3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800fb9:	0f b6 c0             	movzbl %al,%eax
  800fbc:	0f b6 db             	movzbl %bl,%ebx
  800fbf:	29 d8                	sub    %ebx,%eax
  800fc1:	eb 0f                	jmp    800fd2 <memcmp+0x35>
		s1++, s2++;
  800fc3:	83 c2 01             	add    $0x1,%edx
  800fc6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fc9:	39 f2                	cmp    %esi,%edx
  800fcb:	75 e2                	jne    800faf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fdf:	89 c2                	mov    %eax,%edx
  800fe1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fe4:	eb 07                	jmp    800fed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fe6:	38 08                	cmp    %cl,(%eax)
  800fe8:	74 07                	je     800ff1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fea:	83 c0 01             	add    $0x1,%eax
  800fed:	39 d0                	cmp    %edx,%eax
  800fef:	72 f5                	jb     800fe6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fff:	eb 03                	jmp    801004 <strtol+0x11>
		s++;
  801001:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801004:	0f b6 0a             	movzbl (%edx),%ecx
  801007:	80 f9 09             	cmp    $0x9,%cl
  80100a:	74 f5                	je     801001 <strtol+0xe>
  80100c:	80 f9 20             	cmp    $0x20,%cl
  80100f:	74 f0                	je     801001 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801011:	80 f9 2b             	cmp    $0x2b,%cl
  801014:	75 0a                	jne    801020 <strtol+0x2d>
		s++;
  801016:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801019:	bf 00 00 00 00       	mov    $0x0,%edi
  80101e:	eb 11                	jmp    801031 <strtol+0x3e>
  801020:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801025:	80 f9 2d             	cmp    $0x2d,%cl
  801028:	75 07                	jne    801031 <strtol+0x3e>
		s++, neg = 1;
  80102a:	8d 52 01             	lea    0x1(%edx),%edx
  80102d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801031:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801036:	75 15                	jne    80104d <strtol+0x5a>
  801038:	80 3a 30             	cmpb   $0x30,(%edx)
  80103b:	75 10                	jne    80104d <strtol+0x5a>
  80103d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801041:	75 0a                	jne    80104d <strtol+0x5a>
		s += 2, base = 16;
  801043:	83 c2 02             	add    $0x2,%edx
  801046:	b8 10 00 00 00       	mov    $0x10,%eax
  80104b:	eb 10                	jmp    80105d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80104d:	85 c0                	test   %eax,%eax
  80104f:	75 0c                	jne    80105d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801051:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801053:	80 3a 30             	cmpb   $0x30,(%edx)
  801056:	75 05                	jne    80105d <strtol+0x6a>
		s++, base = 8;
  801058:	83 c2 01             	add    $0x1,%edx
  80105b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80105d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801062:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801065:	0f b6 0a             	movzbl (%edx),%ecx
  801068:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80106b:	89 f0                	mov    %esi,%eax
  80106d:	3c 09                	cmp    $0x9,%al
  80106f:	77 08                	ja     801079 <strtol+0x86>
			dig = *s - '0';
  801071:	0f be c9             	movsbl %cl,%ecx
  801074:	83 e9 30             	sub    $0x30,%ecx
  801077:	eb 20                	jmp    801099 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801079:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80107c:	89 f0                	mov    %esi,%eax
  80107e:	3c 19                	cmp    $0x19,%al
  801080:	77 08                	ja     80108a <strtol+0x97>
			dig = *s - 'a' + 10;
  801082:	0f be c9             	movsbl %cl,%ecx
  801085:	83 e9 57             	sub    $0x57,%ecx
  801088:	eb 0f                	jmp    801099 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80108a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80108d:	89 f0                	mov    %esi,%eax
  80108f:	3c 19                	cmp    $0x19,%al
  801091:	77 16                	ja     8010a9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801093:	0f be c9             	movsbl %cl,%ecx
  801096:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801099:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80109c:	7d 0f                	jge    8010ad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80109e:	83 c2 01             	add    $0x1,%edx
  8010a1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8010a5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8010a7:	eb bc                	jmp    801065 <strtol+0x72>
  8010a9:	89 d8                	mov    %ebx,%eax
  8010ab:	eb 02                	jmp    8010af <strtol+0xbc>
  8010ad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8010af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010b3:	74 05                	je     8010ba <strtol+0xc7>
		*endptr = (char *) s;
  8010b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8010ba:	f7 d8                	neg    %eax
  8010bc:	85 ff                	test   %edi,%edi
  8010be:	0f 44 c3             	cmove  %ebx,%eax
}
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	5f                   	pop    %edi
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	57                   	push   %edi
  8010ca:	56                   	push   %esi
  8010cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d7:	89 c3                	mov    %eax,%ebx
  8010d9:	89 c7                	mov    %eax,%edi
  8010db:	89 c6                	mov    %eax,%esi
  8010dd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f4:	89 d1                	mov    %edx,%ecx
  8010f6:	89 d3                	mov    %edx,%ebx
  8010f8:	89 d7                	mov    %edx,%edi
  8010fa:	89 d6                	mov    %edx,%esi
  8010fc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5f                   	pop    %edi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    

00801103 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	57                   	push   %edi
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801111:	b8 03 00 00 00       	mov    $0x3,%eax
  801116:	8b 55 08             	mov    0x8(%ebp),%edx
  801119:	89 cb                	mov    %ecx,%ebx
  80111b:	89 cf                	mov    %ecx,%edi
  80111d:	89 ce                	mov    %ecx,%esi
  80111f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801121:	85 c0                	test   %eax,%eax
  801123:	7e 28                	jle    80114d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801125:	89 44 24 10          	mov    %eax,0x10(%esp)
  801129:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801130:	00 
  801131:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  801138:	00 
  801139:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801140:	00 
  801141:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  801148:	e8 03 f0 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80114d:	83 c4 2c             	add    $0x2c,%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115b:	ba 00 00 00 00       	mov    $0x0,%edx
  801160:	b8 02 00 00 00       	mov    $0x2,%eax
  801165:	89 d1                	mov    %edx,%ecx
  801167:	89 d3                	mov    %edx,%ebx
  801169:	89 d7                	mov    %edx,%edi
  80116b:	89 d6                	mov    %edx,%esi
  80116d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <sys_yield>:

void
sys_yield(void)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117a:	ba 00 00 00 00       	mov    $0x0,%edx
  80117f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801184:	89 d1                	mov    %edx,%ecx
  801186:	89 d3                	mov    %edx,%ebx
  801188:	89 d7                	mov    %edx,%edi
  80118a:	89 d6                	mov    %edx,%esi
  80118c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	57                   	push   %edi
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119c:	be 00 00 00 00       	mov    $0x0,%esi
  8011a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8011a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011af:	89 f7                	mov    %esi,%edi
  8011b1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	7e 28                	jle    8011df <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8011c2:	00 
  8011c3:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8011da:	e8 71 ef ff ff       	call   800150 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011df:	83 c4 2c             	add    $0x2c,%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	57                   	push   %edi
  8011eb:	56                   	push   %esi
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8011f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  801201:	8b 75 18             	mov    0x18(%ebp),%esi
  801204:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801206:	85 c0                	test   %eax,%eax
  801208:	7e 28                	jle    801232 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80120a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80120e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801215:	00 
  801216:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  80121d:	00 
  80121e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801225:	00 
  801226:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  80122d:	e8 1e ef ff ff       	call   800150 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801232:	83 c4 2c             	add    $0x2c,%esp
  801235:	5b                   	pop    %ebx
  801236:	5e                   	pop    %esi
  801237:	5f                   	pop    %edi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	57                   	push   %edi
  80123e:	56                   	push   %esi
  80123f:	53                   	push   %ebx
  801240:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801243:	bb 00 00 00 00       	mov    $0x0,%ebx
  801248:	b8 06 00 00 00       	mov    $0x6,%eax
  80124d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801250:	8b 55 08             	mov    0x8(%ebp),%edx
  801253:	89 df                	mov    %ebx,%edi
  801255:	89 de                	mov    %ebx,%esi
  801257:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801259:	85 c0                	test   %eax,%eax
  80125b:	7e 28                	jle    801285 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801261:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801268:	00 
  801269:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  801270:	00 
  801271:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801278:	00 
  801279:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  801280:	e8 cb ee ff ff       	call   800150 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801285:	83 c4 2c             	add    $0x2c,%esp
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	57                   	push   %edi
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
  801293:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801296:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129b:	b8 08 00 00 00       	mov    $0x8,%eax
  8012a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a6:	89 df                	mov    %ebx,%edi
  8012a8:	89 de                	mov    %ebx,%esi
  8012aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	7e 28                	jle    8012d8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8012bb:	00 
  8012bc:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  8012c3:	00 
  8012c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012cb:	00 
  8012cc:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8012d3:	e8 78 ee ff ff       	call   800150 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012d8:	83 c4 2c             	add    $0x2c,%esp
  8012db:	5b                   	pop    %ebx
  8012dc:	5e                   	pop    %esi
  8012dd:	5f                   	pop    %edi
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	57                   	push   %edi
  8012e4:	56                   	push   %esi
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ee:	b8 09 00 00 00       	mov    $0x9,%eax
  8012f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f9:	89 df                	mov    %ebx,%edi
  8012fb:	89 de                	mov    %ebx,%esi
  8012fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012ff:	85 c0                	test   %eax,%eax
  801301:	7e 28                	jle    80132b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801303:	89 44 24 10          	mov    %eax,0x10(%esp)
  801307:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80130e:	00 
  80130f:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  801316:	00 
  801317:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80131e:	00 
  80131f:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  801326:	e8 25 ee ff ff       	call   800150 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80132b:	83 c4 2c             	add    $0x2c,%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	57                   	push   %edi
  801337:	56                   	push   %esi
  801338:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801339:	be 00 00 00 00       	mov    $0x0,%esi
  80133e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801343:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801346:	8b 55 08             	mov    0x8(%ebp),%edx
  801349:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80134f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801351:	5b                   	pop    %ebx
  801352:	5e                   	pop    %esi
  801353:	5f                   	pop    %edi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	57                   	push   %edi
  80135a:	56                   	push   %esi
  80135b:	53                   	push   %ebx
  80135c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80135f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801364:	b8 0c 00 00 00       	mov    $0xc,%eax
  801369:	8b 55 08             	mov    0x8(%ebp),%edx
  80136c:	89 cb                	mov    %ecx,%ebx
  80136e:	89 cf                	mov    %ecx,%edi
  801370:	89 ce                	mov    %ecx,%esi
  801372:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801374:	85 c0                	test   %eax,%eax
  801376:	7e 28                	jle    8013a0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801378:	89 44 24 10          	mov    %eax,0x10(%esp)
  80137c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801383:	00 
  801384:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  80138b:	00 
  80138c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801393:	00 
  801394:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  80139b:	e8 b0 ed ff ff       	call   800150 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013a0:	83 c4 2c             	add    $0x2c,%esp
  8013a3:	5b                   	pop    %ebx
  8013a4:	5e                   	pop    %esi
  8013a5:	5f                   	pop    %edi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013ae:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8013b5:	75 32                	jne    8013e9 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  8013b7:	e8 99 fd ff ff       	call   801155 <sys_getenvid>
  8013bc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013c3:	00 
  8013c4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013cb:	ee 
  8013cc:	89 04 24             	mov    %eax,(%esp)
  8013cf:	e8 bf fd ff ff       	call   801193 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  8013d4:	e8 7c fd ff ff       	call   801155 <sys_getenvid>
  8013d9:	c7 44 24 04 f3 13 80 	movl   $0x8013f3,0x4(%esp)
  8013e0:	00 
  8013e1:	89 04 24             	mov    %eax,(%esp)
  8013e4:	e8 f7 fe ff ff       	call   8012e0 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ec:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8013f1:	c9                   	leave  
  8013f2:	c3                   	ret    

008013f3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013f3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013f4:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8013f9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013fb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  8013fe:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  801401:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  801405:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  801409:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  80140c:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  801410:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  801412:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  801413:	83 c4 04             	add    $0x4,%esp
	popfl 	
  801416:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801417:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801418:	c3                   	ret    
  801419:	66 90                	xchg   %ax,%ax
  80141b:	66 90                	xchg   %ax,%ax
  80141d:	66 90                	xchg   %ax,%ax
  80141f:	90                   	nop

00801420 <__udivdi3>:
  801420:	55                   	push   %ebp
  801421:	57                   	push   %edi
  801422:	56                   	push   %esi
  801423:	83 ec 0c             	sub    $0xc,%esp
  801426:	8b 44 24 28          	mov    0x28(%esp),%eax
  80142a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80142e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801432:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801436:	85 c0                	test   %eax,%eax
  801438:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80143c:	89 ea                	mov    %ebp,%edx
  80143e:	89 0c 24             	mov    %ecx,(%esp)
  801441:	75 2d                	jne    801470 <__udivdi3+0x50>
  801443:	39 e9                	cmp    %ebp,%ecx
  801445:	77 61                	ja     8014a8 <__udivdi3+0x88>
  801447:	85 c9                	test   %ecx,%ecx
  801449:	89 ce                	mov    %ecx,%esi
  80144b:	75 0b                	jne    801458 <__udivdi3+0x38>
  80144d:	b8 01 00 00 00       	mov    $0x1,%eax
  801452:	31 d2                	xor    %edx,%edx
  801454:	f7 f1                	div    %ecx
  801456:	89 c6                	mov    %eax,%esi
  801458:	31 d2                	xor    %edx,%edx
  80145a:	89 e8                	mov    %ebp,%eax
  80145c:	f7 f6                	div    %esi
  80145e:	89 c5                	mov    %eax,%ebp
  801460:	89 f8                	mov    %edi,%eax
  801462:	f7 f6                	div    %esi
  801464:	89 ea                	mov    %ebp,%edx
  801466:	83 c4 0c             	add    $0xc,%esp
  801469:	5e                   	pop    %esi
  80146a:	5f                   	pop    %edi
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    
  80146d:	8d 76 00             	lea    0x0(%esi),%esi
  801470:	39 e8                	cmp    %ebp,%eax
  801472:	77 24                	ja     801498 <__udivdi3+0x78>
  801474:	0f bd e8             	bsr    %eax,%ebp
  801477:	83 f5 1f             	xor    $0x1f,%ebp
  80147a:	75 3c                	jne    8014b8 <__udivdi3+0x98>
  80147c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801480:	39 34 24             	cmp    %esi,(%esp)
  801483:	0f 86 9f 00 00 00    	jbe    801528 <__udivdi3+0x108>
  801489:	39 d0                	cmp    %edx,%eax
  80148b:	0f 82 97 00 00 00    	jb     801528 <__udivdi3+0x108>
  801491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801498:	31 d2                	xor    %edx,%edx
  80149a:	31 c0                	xor    %eax,%eax
  80149c:	83 c4 0c             	add    $0xc,%esp
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    
  8014a3:	90                   	nop
  8014a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	89 f8                	mov    %edi,%eax
  8014aa:	f7 f1                	div    %ecx
  8014ac:	31 d2                	xor    %edx,%edx
  8014ae:	83 c4 0c             	add    $0xc,%esp
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    
  8014b5:	8d 76 00             	lea    0x0(%esi),%esi
  8014b8:	89 e9                	mov    %ebp,%ecx
  8014ba:	8b 3c 24             	mov    (%esp),%edi
  8014bd:	d3 e0                	shl    %cl,%eax
  8014bf:	89 c6                	mov    %eax,%esi
  8014c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8014c6:	29 e8                	sub    %ebp,%eax
  8014c8:	89 c1                	mov    %eax,%ecx
  8014ca:	d3 ef                	shr    %cl,%edi
  8014cc:	89 e9                	mov    %ebp,%ecx
  8014ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014d2:	8b 3c 24             	mov    (%esp),%edi
  8014d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8014d9:	89 d6                	mov    %edx,%esi
  8014db:	d3 e7                	shl    %cl,%edi
  8014dd:	89 c1                	mov    %eax,%ecx
  8014df:	89 3c 24             	mov    %edi,(%esp)
  8014e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014e6:	d3 ee                	shr    %cl,%esi
  8014e8:	89 e9                	mov    %ebp,%ecx
  8014ea:	d3 e2                	shl    %cl,%edx
  8014ec:	89 c1                	mov    %eax,%ecx
  8014ee:	d3 ef                	shr    %cl,%edi
  8014f0:	09 d7                	or     %edx,%edi
  8014f2:	89 f2                	mov    %esi,%edx
  8014f4:	89 f8                	mov    %edi,%eax
  8014f6:	f7 74 24 08          	divl   0x8(%esp)
  8014fa:	89 d6                	mov    %edx,%esi
  8014fc:	89 c7                	mov    %eax,%edi
  8014fe:	f7 24 24             	mull   (%esp)
  801501:	39 d6                	cmp    %edx,%esi
  801503:	89 14 24             	mov    %edx,(%esp)
  801506:	72 30                	jb     801538 <__udivdi3+0x118>
  801508:	8b 54 24 04          	mov    0x4(%esp),%edx
  80150c:	89 e9                	mov    %ebp,%ecx
  80150e:	d3 e2                	shl    %cl,%edx
  801510:	39 c2                	cmp    %eax,%edx
  801512:	73 05                	jae    801519 <__udivdi3+0xf9>
  801514:	3b 34 24             	cmp    (%esp),%esi
  801517:	74 1f                	je     801538 <__udivdi3+0x118>
  801519:	89 f8                	mov    %edi,%eax
  80151b:	31 d2                	xor    %edx,%edx
  80151d:	e9 7a ff ff ff       	jmp    80149c <__udivdi3+0x7c>
  801522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801528:	31 d2                	xor    %edx,%edx
  80152a:	b8 01 00 00 00       	mov    $0x1,%eax
  80152f:	e9 68 ff ff ff       	jmp    80149c <__udivdi3+0x7c>
  801534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801538:	8d 47 ff             	lea    -0x1(%edi),%eax
  80153b:	31 d2                	xor    %edx,%edx
  80153d:	83 c4 0c             	add    $0xc,%esp
  801540:	5e                   	pop    %esi
  801541:	5f                   	pop    %edi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    
  801544:	66 90                	xchg   %ax,%ax
  801546:	66 90                	xchg   %ax,%ax
  801548:	66 90                	xchg   %ax,%ax
  80154a:	66 90                	xchg   %ax,%ax
  80154c:	66 90                	xchg   %ax,%ax
  80154e:	66 90                	xchg   %ax,%ax

00801550 <__umoddi3>:
  801550:	55                   	push   %ebp
  801551:	57                   	push   %edi
  801552:	56                   	push   %esi
  801553:	83 ec 14             	sub    $0x14,%esp
  801556:	8b 44 24 28          	mov    0x28(%esp),%eax
  80155a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80155e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801562:	89 c7                	mov    %eax,%edi
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	8b 44 24 30          	mov    0x30(%esp),%eax
  80156c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801570:	89 34 24             	mov    %esi,(%esp)
  801573:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801577:	85 c0                	test   %eax,%eax
  801579:	89 c2                	mov    %eax,%edx
  80157b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80157f:	75 17                	jne    801598 <__umoddi3+0x48>
  801581:	39 fe                	cmp    %edi,%esi
  801583:	76 4b                	jbe    8015d0 <__umoddi3+0x80>
  801585:	89 c8                	mov    %ecx,%eax
  801587:	89 fa                	mov    %edi,%edx
  801589:	f7 f6                	div    %esi
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	31 d2                	xor    %edx,%edx
  80158f:	83 c4 14             	add    $0x14,%esp
  801592:	5e                   	pop    %esi
  801593:	5f                   	pop    %edi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    
  801596:	66 90                	xchg   %ax,%ax
  801598:	39 f8                	cmp    %edi,%eax
  80159a:	77 54                	ja     8015f0 <__umoddi3+0xa0>
  80159c:	0f bd e8             	bsr    %eax,%ebp
  80159f:	83 f5 1f             	xor    $0x1f,%ebp
  8015a2:	75 5c                	jne    801600 <__umoddi3+0xb0>
  8015a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8015a8:	39 3c 24             	cmp    %edi,(%esp)
  8015ab:	0f 87 e7 00 00 00    	ja     801698 <__umoddi3+0x148>
  8015b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015b5:	29 f1                	sub    %esi,%ecx
  8015b7:	19 c7                	sbb    %eax,%edi
  8015b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015c9:	83 c4 14             	add    $0x14,%esp
  8015cc:	5e                   	pop    %esi
  8015cd:	5f                   	pop    %edi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    
  8015d0:	85 f6                	test   %esi,%esi
  8015d2:	89 f5                	mov    %esi,%ebp
  8015d4:	75 0b                	jne    8015e1 <__umoddi3+0x91>
  8015d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015db:	31 d2                	xor    %edx,%edx
  8015dd:	f7 f6                	div    %esi
  8015df:	89 c5                	mov    %eax,%ebp
  8015e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8015e5:	31 d2                	xor    %edx,%edx
  8015e7:	f7 f5                	div    %ebp
  8015e9:	89 c8                	mov    %ecx,%eax
  8015eb:	f7 f5                	div    %ebp
  8015ed:	eb 9c                	jmp    80158b <__umoddi3+0x3b>
  8015ef:	90                   	nop
  8015f0:	89 c8                	mov    %ecx,%eax
  8015f2:	89 fa                	mov    %edi,%edx
  8015f4:	83 c4 14             	add    $0x14,%esp
  8015f7:	5e                   	pop    %esi
  8015f8:	5f                   	pop    %edi
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    
  8015fb:	90                   	nop
  8015fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801600:	8b 04 24             	mov    (%esp),%eax
  801603:	be 20 00 00 00       	mov    $0x20,%esi
  801608:	89 e9                	mov    %ebp,%ecx
  80160a:	29 ee                	sub    %ebp,%esi
  80160c:	d3 e2                	shl    %cl,%edx
  80160e:	89 f1                	mov    %esi,%ecx
  801610:	d3 e8                	shr    %cl,%eax
  801612:	89 e9                	mov    %ebp,%ecx
  801614:	89 44 24 04          	mov    %eax,0x4(%esp)
  801618:	8b 04 24             	mov    (%esp),%eax
  80161b:	09 54 24 04          	or     %edx,0x4(%esp)
  80161f:	89 fa                	mov    %edi,%edx
  801621:	d3 e0                	shl    %cl,%eax
  801623:	89 f1                	mov    %esi,%ecx
  801625:	89 44 24 08          	mov    %eax,0x8(%esp)
  801629:	8b 44 24 10          	mov    0x10(%esp),%eax
  80162d:	d3 ea                	shr    %cl,%edx
  80162f:	89 e9                	mov    %ebp,%ecx
  801631:	d3 e7                	shl    %cl,%edi
  801633:	89 f1                	mov    %esi,%ecx
  801635:	d3 e8                	shr    %cl,%eax
  801637:	89 e9                	mov    %ebp,%ecx
  801639:	09 f8                	or     %edi,%eax
  80163b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80163f:	f7 74 24 04          	divl   0x4(%esp)
  801643:	d3 e7                	shl    %cl,%edi
  801645:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801649:	89 d7                	mov    %edx,%edi
  80164b:	f7 64 24 08          	mull   0x8(%esp)
  80164f:	39 d7                	cmp    %edx,%edi
  801651:	89 c1                	mov    %eax,%ecx
  801653:	89 14 24             	mov    %edx,(%esp)
  801656:	72 2c                	jb     801684 <__umoddi3+0x134>
  801658:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80165c:	72 22                	jb     801680 <__umoddi3+0x130>
  80165e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801662:	29 c8                	sub    %ecx,%eax
  801664:	19 d7                	sbb    %edx,%edi
  801666:	89 e9                	mov    %ebp,%ecx
  801668:	89 fa                	mov    %edi,%edx
  80166a:	d3 e8                	shr    %cl,%eax
  80166c:	89 f1                	mov    %esi,%ecx
  80166e:	d3 e2                	shl    %cl,%edx
  801670:	89 e9                	mov    %ebp,%ecx
  801672:	d3 ef                	shr    %cl,%edi
  801674:	09 d0                	or     %edx,%eax
  801676:	89 fa                	mov    %edi,%edx
  801678:	83 c4 14             	add    $0x14,%esp
  80167b:	5e                   	pop    %esi
  80167c:	5f                   	pop    %edi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    
  80167f:	90                   	nop
  801680:	39 d7                	cmp    %edx,%edi
  801682:	75 da                	jne    80165e <__umoddi3+0x10e>
  801684:	8b 14 24             	mov    (%esp),%edx
  801687:	89 c1                	mov    %eax,%ecx
  801689:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80168d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801691:	eb cb                	jmp    80165e <__umoddi3+0x10e>
  801693:	90                   	nop
  801694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801698:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80169c:	0f 82 0f ff ff ff    	jb     8015b1 <__umoddi3+0x61>
  8016a2:	e9 1a ff ff ff       	jmp    8015c1 <__umoddi3+0x71>
