
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
  80004a:	e8 e6 01 00 00       	call   800235 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 05 11 00 00       	call   801173 <sys_page_alloc>
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
  800091:	e8 a6 00 00 00       	call   80013c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 ec 16 80 	movl   $0x8016ec,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 42 0c 00 00       	call   800cf4 <snprintf>
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
  8000c5:	e8 be 12 00 00       	call   801388 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000ca:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d1:	00 
  8000d2:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000d9:	e8 c8 0f 00 00       	call   8010a6 <sys_cputs>
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
  8000ee:	e8 42 10 00 00       	call   801135 <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x30>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800110:	89 74 24 04          	mov    %esi,0x4(%esp)
  800114:	89 1c 24             	mov    %ebx,(%esp)
  800117:	e8 9c ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  80011c:	e8 07 00 00 00       	call   800128 <exit>
}
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800135:	e8 a9 0f 00 00       	call   8010e3 <sys_env_destroy>
}
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
  800141:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800144:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800147:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014d:	e8 e3 0f 00 00       	call   801135 <sys_getenvid>
  800152:	8b 55 0c             	mov    0xc(%ebp),%edx
  800155:	89 54 24 10          	mov    %edx,0x10(%esp)
  800159:	8b 55 08             	mov    0x8(%ebp),%edx
  80015c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800160:	89 74 24 08          	mov    %esi,0x8(%esp)
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	c7 04 24 18 17 80 00 	movl   $0x801718,(%esp)
  80016f:	e8 c1 00 00 00       	call   800235 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	8b 45 10             	mov    0x10(%ebp),%eax
  80017b:	89 04 24             	mov    %eax,(%esp)
  80017e:	e8 51 00 00 00       	call   8001d4 <vcprintf>
	cprintf("\n");
  800183:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  80018a:	e8 a6 00 00 00       	call   800235 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x53>

00800192 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	53                   	push   %ebx
  800196:	83 ec 14             	sub    $0x14,%esp
  800199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019c:	8b 13                	mov    (%ebx),%edx
  80019e:	8d 42 01             	lea    0x1(%edx),%eax
  8001a1:	89 03                	mov    %eax,(%ebx)
  8001a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001af:	75 19                	jne    8001ca <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b8:	00 
  8001b9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bc:	89 04 24             	mov    %eax,(%esp)
  8001bf:	e8 e2 0e 00 00       	call   8010a6 <sys_cputs>
		b->idx = 0;
  8001c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ca:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ce:	83 c4 14             	add    $0x14,%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e4:	00 00 00 
	b.cnt = 0;
  8001e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800205:	89 44 24 04          	mov    %eax,0x4(%esp)
  800209:	c7 04 24 92 01 80 00 	movl   $0x800192,(%esp)
  800210:	e8 aa 02 00 00       	call   8004bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	e8 79 0e 00 00       	call   8010a6 <sys_cputs>

	return b.cnt;
}
  80022d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800233:	c9                   	leave  
  800234:	c3                   	ret    

00800235 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	e8 87 ff ff ff       	call   8001d4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    
  80024f:	90                   	nop

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 3c             	sub    $0x3c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d7                	mov    %edx,%edi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
  800267:	89 c3                	mov    %eax,%ebx
  800269:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800272:	b9 00 00 00 00       	mov    $0x0,%ecx
  800277:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80027d:	39 d9                	cmp    %ebx,%ecx
  80027f:	72 05                	jb     800286 <printnum+0x36>
  800281:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800284:	77 69                	ja     8002ef <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800286:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800289:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80028d:	83 ee 01             	sub    $0x1,%esi
  800290:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8b 44 24 08          	mov    0x8(%esp),%eax
  80029c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002a0:	89 c3                	mov    %eax,%ebx
  8002a2:	89 d6                	mov    %edx,%esi
  8002a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	e8 3c 11 00 00       	call   801400 <__udivdi3>
  8002c4:	89 d9                	mov    %ebx,%ecx
  8002c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 71 ff ff ff       	call   800250 <printnum>
  8002df:	eb 1b                	jmp    8002fc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff d3                	call   *%ebx
  8002ed:	eb 03                	jmp    8002f2 <printnum+0xa2>
  8002ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f2:	83 ee 01             	sub    $0x1,%esi
  8002f5:	85 f6                	test   %esi,%esi
  8002f7:	7f e8                	jg     8002e1 <printnum+0x91>
  8002f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800307:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80031b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031f:	e8 0c 12 00 00       	call   801530 <__umoddi3>
  800324:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800328:	0f be 80 3c 17 80 00 	movsbl 0x80173c(%eax),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800335:	ff d0                	call   *%eax
}
  800337:	83 c4 3c             	add    $0x3c,%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 3c             	sub    $0x3c,%esp
  800348:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80034b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80034e:	89 cf                	mov    %ecx,%edi
  800350:	8b 45 08             	mov    0x8(%ebp),%eax
  800353:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
  800359:	89 c3                	mov    %eax,%ebx
  80035b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80035e:	8b 45 10             	mov    0x10(%ebp),%eax
  800361:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800364:	b9 00 00 00 00       	mov    $0x0,%ecx
  800369:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80036c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80036f:	39 d9                	cmp    %ebx,%ecx
  800371:	72 13                	jb     800386 <cprintnum+0x47>
  800373:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800376:	76 0e                	jbe    800386 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800378:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037b:	0b 45 18             	or     0x18(%ebp),%eax
  80037e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800381:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800384:	eb 6a                	jmp    8003f0 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800386:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800389:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80038d:	83 ee 01             	sub    $0x1,%esi
  800390:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800394:	89 44 24 08          	mov    %eax,0x8(%esp)
  800398:	8b 44 24 08          	mov    0x8(%esp),%eax
  80039c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003a0:	89 c3                	mov    %eax,%ebx
  8003a2:	89 d6                	mov    %edx,%esi
  8003a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003a7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8003aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b5:	89 04 24             	mov    %eax,(%esp)
  8003b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bf:	e8 3c 10 00 00       	call   801400 <__udivdi3>
  8003c4:	89 d9                	mov    %ebx,%ecx
  8003c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003ce:	89 04 24             	mov    %eax,(%esp)
  8003d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003d5:	89 f9                	mov    %edi,%ecx
  8003d7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003dd:	e8 5d ff ff ff       	call   80033f <cprintnum>
  8003e2:	eb 16                	jmp    8003fa <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8003e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003f0:	83 ee 01             	sub    $0x1,%esi
  8003f3:	85 f6                	test   %esi,%esi
  8003f5:	7f ed                	jg     8003e4 <cprintnum+0xa5>
  8003f7:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  8003fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fe:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800402:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800405:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800408:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800410:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800413:	89 04 24             	mov    %eax,(%esp)
  800416:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041d:	e8 0e 11 00 00       	call   801530 <__umoddi3>
  800422:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800426:	0f be 80 3c 17 80 00 	movsbl 0x80173c(%eax),%eax
  80042d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800436:	ff d0                	call   *%eax
}
  800438:	83 c4 3c             	add    $0x3c,%esp
  80043b:	5b                   	pop    %ebx
  80043c:	5e                   	pop    %esi
  80043d:	5f                   	pop    %edi
  80043e:	5d                   	pop    %ebp
  80043f:	c3                   	ret    

00800440 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800443:	83 fa 01             	cmp    $0x1,%edx
  800446:	7e 0e                	jle    800456 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800448:	8b 10                	mov    (%eax),%edx
  80044a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80044d:	89 08                	mov    %ecx,(%eax)
  80044f:	8b 02                	mov    (%edx),%eax
  800451:	8b 52 04             	mov    0x4(%edx),%edx
  800454:	eb 22                	jmp    800478 <getuint+0x38>
	else if (lflag)
  800456:	85 d2                	test   %edx,%edx
  800458:	74 10                	je     80046a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80045a:	8b 10                	mov    (%eax),%edx
  80045c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045f:	89 08                	mov    %ecx,(%eax)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	ba 00 00 00 00       	mov    $0x0,%edx
  800468:	eb 0e                	jmp    800478 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80046a:	8b 10                	mov    (%eax),%edx
  80046c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046f:	89 08                	mov    %ecx,(%eax)
  800471:	8b 02                	mov    (%edx),%eax
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800478:	5d                   	pop    %ebp
  800479:	c3                   	ret    

0080047a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800480:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800484:	8b 10                	mov    (%eax),%edx
  800486:	3b 50 04             	cmp    0x4(%eax),%edx
  800489:	73 0a                	jae    800495 <sprintputch+0x1b>
		*b->buf++ = ch;
  80048b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80048e:	89 08                	mov    %ecx,(%eax)
  800490:	8b 45 08             	mov    0x8(%ebp),%eax
  800493:	88 02                	mov    %al,(%edx)
}
  800495:	5d                   	pop    %ebp
  800496:	c3                   	ret    

00800497 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800497:	55                   	push   %ebp
  800498:	89 e5                	mov    %esp,%ebp
  80049a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80049d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b5:	89 04 24             	mov    %eax,(%esp)
  8004b8:	e8 02 00 00 00       	call   8004bf <vprintfmt>
	va_end(ap);
}
  8004bd:	c9                   	leave  
  8004be:	c3                   	ret    

008004bf <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	57                   	push   %edi
  8004c3:	56                   	push   %esi
  8004c4:	53                   	push   %ebx
  8004c5:	83 ec 3c             	sub    $0x3c,%esp
  8004c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004ce:	eb 14                	jmp    8004e4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	0f 84 b3 03 00 00    	je     80088b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8004d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e2:	89 f3                	mov    %esi,%ebx
  8004e4:	8d 73 01             	lea    0x1(%ebx),%esi
  8004e7:	0f b6 03             	movzbl (%ebx),%eax
  8004ea:	83 f8 25             	cmp    $0x25,%eax
  8004ed:	75 e1                	jne    8004d0 <vprintfmt+0x11>
  8004ef:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004f3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004fa:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800501:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800508:	ba 00 00 00 00       	mov    $0x0,%edx
  80050d:	eb 1d                	jmp    80052c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800511:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800515:	eb 15                	jmp    80052c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800519:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80051d:	eb 0d                	jmp    80052c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80051f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800522:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800525:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80052f:	0f b6 0e             	movzbl (%esi),%ecx
  800532:	0f b6 c1             	movzbl %cl,%eax
  800535:	83 e9 23             	sub    $0x23,%ecx
  800538:	80 f9 55             	cmp    $0x55,%cl
  80053b:	0f 87 2a 03 00 00    	ja     80086b <vprintfmt+0x3ac>
  800541:	0f b6 c9             	movzbl %cl,%ecx
  800544:	ff 24 8d 00 18 80 00 	jmp    *0x801800(,%ecx,4)
  80054b:	89 de                	mov    %ebx,%esi
  80054d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800552:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800555:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800559:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80055c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80055f:	83 fb 09             	cmp    $0x9,%ebx
  800562:	77 36                	ja     80059a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800564:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800567:	eb e9                	jmp    800552 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 48 04             	lea    0x4(%eax),%ecx
  80056f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800577:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800579:	eb 22                	jmp    80059d <vprintfmt+0xde>
  80057b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80057e:	85 c9                	test   %ecx,%ecx
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	0f 49 c1             	cmovns %ecx,%eax
  800588:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	89 de                	mov    %ebx,%esi
  80058d:	eb 9d                	jmp    80052c <vprintfmt+0x6d>
  80058f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800591:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800598:	eb 92                	jmp    80052c <vprintfmt+0x6d>
  80059a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80059d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a1:	79 89                	jns    80052c <vprintfmt+0x6d>
  8005a3:	e9 77 ff ff ff       	jmp    80051f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ad:	e9 7a ff ff ff       	jmp    80052c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 04             	lea    0x4(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 04 24             	mov    %eax,(%esp)
  8005c4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005c7:	e9 18 ff ff ff       	jmp    8004e4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	99                   	cltd   
  8005d8:	31 d0                	xor    %edx,%eax
  8005da:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005dc:	83 f8 09             	cmp    $0x9,%eax
  8005df:	7f 0b                	jg     8005ec <vprintfmt+0x12d>
  8005e1:	8b 14 85 c0 1a 80 00 	mov    0x801ac0(,%eax,4),%edx
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	75 20                	jne    80060c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8005ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f0:	c7 44 24 08 54 17 80 	movl   $0x801754,0x8(%esp)
  8005f7:	00 
  8005f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	e8 90 fe ff ff       	call   800497 <printfmt>
  800607:	e9 d8 fe ff ff       	jmp    8004e4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80060c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800610:	c7 44 24 08 5d 17 80 	movl   $0x80175d,0x8(%esp)
  800617:	00 
  800618:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	89 04 24             	mov    %eax,(%esp)
  800622:	e8 70 fe ff ff       	call   800497 <printfmt>
  800627:	e9 b8 fe ff ff       	jmp    8004e4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80062f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800632:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 50 04             	lea    0x4(%eax),%edx
  80063b:	89 55 14             	mov    %edx,0x14(%ebp)
  80063e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800640:	85 f6                	test   %esi,%esi
  800642:	b8 4d 17 80 00       	mov    $0x80174d,%eax
  800647:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80064a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80064e:	0f 84 97 00 00 00    	je     8006eb <vprintfmt+0x22c>
  800654:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800658:	0f 8e 9b 00 00 00    	jle    8006f9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80065e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800662:	89 34 24             	mov    %esi,(%esp)
  800665:	e8 ce 06 00 00       	call   800d38 <strnlen>
  80066a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80066d:	29 c2                	sub    %eax,%edx
  80066f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800672:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800676:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800679:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80067c:	8b 75 08             	mov    0x8(%ebp),%esi
  80067f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800682:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800684:	eb 0f                	jmp    800695 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800686:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800692:	83 eb 01             	sub    $0x1,%ebx
  800695:	85 db                	test   %ebx,%ebx
  800697:	7f ed                	jg     800686 <vprintfmt+0x1c7>
  800699:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80069c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a6:	0f 49 c2             	cmovns %edx,%eax
  8006a9:	29 c2                	sub    %eax,%edx
  8006ab:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006ae:	89 d7                	mov    %edx,%edi
  8006b0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006b3:	eb 50                	jmp    800705 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b9:	74 1e                	je     8006d9 <vprintfmt+0x21a>
  8006bb:	0f be d2             	movsbl %dl,%edx
  8006be:	83 ea 20             	sub    $0x20,%edx
  8006c1:	83 fa 5e             	cmp    $0x5e,%edx
  8006c4:	76 13                	jbe    8006d9 <vprintfmt+0x21a>
					putch('?', putdat);
  8006c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006d4:	ff 55 08             	call   *0x8(%ebp)
  8006d7:	eb 0d                	jmp    8006e6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8006d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e6:	83 ef 01             	sub    $0x1,%edi
  8006e9:	eb 1a                	jmp    800705 <vprintfmt+0x246>
  8006eb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006ee:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006f1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006f4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006f7:	eb 0c                	jmp    800705 <vprintfmt+0x246>
  8006f9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006fc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006ff:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800702:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800705:	83 c6 01             	add    $0x1,%esi
  800708:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80070c:	0f be c2             	movsbl %dl,%eax
  80070f:	85 c0                	test   %eax,%eax
  800711:	74 27                	je     80073a <vprintfmt+0x27b>
  800713:	85 db                	test   %ebx,%ebx
  800715:	78 9e                	js     8006b5 <vprintfmt+0x1f6>
  800717:	83 eb 01             	sub    $0x1,%ebx
  80071a:	79 99                	jns    8006b5 <vprintfmt+0x1f6>
  80071c:	89 f8                	mov    %edi,%eax
  80071e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800721:	8b 75 08             	mov    0x8(%ebp),%esi
  800724:	89 c3                	mov    %eax,%ebx
  800726:	eb 1a                	jmp    800742 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800728:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800733:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800735:	83 eb 01             	sub    $0x1,%ebx
  800738:	eb 08                	jmp    800742 <vprintfmt+0x283>
  80073a:	89 fb                	mov    %edi,%ebx
  80073c:	8b 75 08             	mov    0x8(%ebp),%esi
  80073f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800742:	85 db                	test   %ebx,%ebx
  800744:	7f e2                	jg     800728 <vprintfmt+0x269>
  800746:	89 75 08             	mov    %esi,0x8(%ebp)
  800749:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80074c:	e9 93 fd ff ff       	jmp    8004e4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800751:	83 fa 01             	cmp    $0x1,%edx
  800754:	7e 16                	jle    80076c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8d 50 08             	lea    0x8(%eax),%edx
  80075c:	89 55 14             	mov    %edx,0x14(%ebp)
  80075f:	8b 50 04             	mov    0x4(%eax),%edx
  800762:	8b 00                	mov    (%eax),%eax
  800764:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800767:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80076a:	eb 32                	jmp    80079e <vprintfmt+0x2df>
	else if (lflag)
  80076c:	85 d2                	test   %edx,%edx
  80076e:	74 18                	je     800788 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 50 04             	lea    0x4(%eax),%edx
  800776:	89 55 14             	mov    %edx,0x14(%ebp)
  800779:	8b 30                	mov    (%eax),%esi
  80077b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80077e:	89 f0                	mov    %esi,%eax
  800780:	c1 f8 1f             	sar    $0x1f,%eax
  800783:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800786:	eb 16                	jmp    80079e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8d 50 04             	lea    0x4(%eax),%edx
  80078e:	89 55 14             	mov    %edx,0x14(%ebp)
  800791:	8b 30                	mov    (%eax),%esi
  800793:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800796:	89 f0                	mov    %esi,%eax
  800798:	c1 f8 1f             	sar    $0x1f,%eax
  80079b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80079e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ad:	0f 89 80 00 00 00    	jns    800833 <vprintfmt+0x374>
				putch('-', putdat);
  8007b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007be:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c7:	f7 d8                	neg    %eax
  8007c9:	83 d2 00             	adc    $0x0,%edx
  8007cc:	f7 da                	neg    %edx
			}
			base = 10;
  8007ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d3:	eb 5e                	jmp    800833 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d8:	e8 63 fc ff ff       	call   800440 <getuint>
			base = 10;
  8007dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007e2:	eb 4f                	jmp    800833 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e7:	e8 54 fc ff ff       	call   800440 <getuint>
			base = 8 ;
  8007ec:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  8007f1:	eb 40                	jmp    800833 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8007f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007fe:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800801:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800805:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80080c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8d 50 04             	lea    0x4(%eax),%edx
  800815:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80081f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800824:	eb 0d                	jmp    800833 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800826:	8d 45 14             	lea    0x14(%ebp),%eax
  800829:	e8 12 fc ff ff       	call   800440 <getuint>
			base = 16;
  80082e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800833:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800837:	89 74 24 10          	mov    %esi,0x10(%esp)
  80083b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80083e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800842:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800846:	89 04 24             	mov    %eax,(%esp)
  800849:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084d:	89 fa                	mov    %edi,%edx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	e8 f9 f9 ff ff       	call   800250 <printnum>
			break;
  800857:	e9 88 fc ff ff       	jmp    8004e4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	ff 55 08             	call   *0x8(%ebp)
			break;
  800866:	e9 79 fc ff ff       	jmp    8004e4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80086b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80086f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800876:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800879:	89 f3                	mov    %esi,%ebx
  80087b:	eb 03                	jmp    800880 <vprintfmt+0x3c1>
  80087d:	83 eb 01             	sub    $0x1,%ebx
  800880:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800884:	75 f7                	jne    80087d <vprintfmt+0x3be>
  800886:	e9 59 fc ff ff       	jmp    8004e4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80088b:	83 c4 3c             	add    $0x3c,%esp
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5f                   	pop    %edi
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	57                   	push   %edi
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	83 ec 3c             	sub    $0x3c,%esp
  80089c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  80089f:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a2:	8d 50 04             	lea    0x4(%eax),%edx
  8008a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a8:	8b 00                	mov    (%eax),%eax
  8008aa:	c1 e0 08             	shl    $0x8,%eax
  8008ad:	0f b7 c0             	movzwl %ax,%eax
  8008b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  8008b3:	83 c8 25             	or     $0x25,%eax
  8008b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8008b9:	eb 1a                	jmp    8008d5 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	0f 84 a9 03 00 00    	je     800c6c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  8008c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ca:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8008cd:	89 04 24             	mov    %eax,(%esp)
  8008d0:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d3:	89 fb                	mov    %edi,%ebx
  8008d5:	8d 7b 01             	lea    0x1(%ebx),%edi
  8008d8:	0f b6 03             	movzbl (%ebx),%eax
  8008db:	83 f8 25             	cmp    $0x25,%eax
  8008de:	75 db                	jne    8008bb <cvprintfmt+0x28>
  8008e0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8008e4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008eb:	be ff ff ff ff       	mov    $0xffffffff,%esi
  8008f0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8008f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008fc:	eb 18                	jmp    800916 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fe:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800900:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800904:	eb 10                	jmp    800916 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800906:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800908:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80090c:	eb 08                	jmp    800916 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80090e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800911:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800916:	8d 5f 01             	lea    0x1(%edi),%ebx
  800919:	0f b6 0f             	movzbl (%edi),%ecx
  80091c:	0f b6 c1             	movzbl %cl,%eax
  80091f:	83 e9 23             	sub    $0x23,%ecx
  800922:	80 f9 55             	cmp    $0x55,%cl
  800925:	0f 87 1f 03 00 00    	ja     800c4a <cvprintfmt+0x3b7>
  80092b:	0f b6 c9             	movzbl %cl,%ecx
  80092e:	ff 24 8d 58 19 80 00 	jmp    *0x801958(,%ecx,4)
  800935:	89 df                	mov    %ebx,%edi
  800937:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80093c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80093f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800943:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800946:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800949:	83 f9 09             	cmp    $0x9,%ecx
  80094c:	77 33                	ja     800981 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80094e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800951:	eb e9                	jmp    80093c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800953:	8b 45 14             	mov    0x14(%ebp),%eax
  800956:	8d 48 04             	lea    0x4(%eax),%ecx
  800959:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80095c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800960:	eb 1f                	jmp    800981 <cvprintfmt+0xee>
  800962:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800965:	85 ff                	test   %edi,%edi
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
  80096c:	0f 49 c7             	cmovns %edi,%eax
  80096f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800972:	89 df                	mov    %ebx,%edi
  800974:	eb a0                	jmp    800916 <cvprintfmt+0x83>
  800976:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800978:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80097f:	eb 95                	jmp    800916 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800981:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800985:	79 8f                	jns    800916 <cvprintfmt+0x83>
  800987:	eb 85                	jmp    80090e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800989:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80098e:	66 90                	xchg   %ax,%ax
  800990:	eb 84                	jmp    800916 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800992:	8b 45 14             	mov    0x14(%ebp),%eax
  800995:	8d 50 04             	lea    0x4(%eax),%edx
  800998:	89 55 14             	mov    %edx,0x14(%ebp)
  80099b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009a5:	0b 10                	or     (%eax),%edx
  8009a7:	89 14 24             	mov    %edx,(%esp)
  8009aa:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009ad:	e9 23 ff ff ff       	jmp    8008d5 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b5:	8d 50 04             	lea    0x4(%eax),%edx
  8009b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bb:	8b 00                	mov    (%eax),%eax
  8009bd:	99                   	cltd   
  8009be:	31 d0                	xor    %edx,%eax
  8009c0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009c2:	83 f8 09             	cmp    $0x9,%eax
  8009c5:	7f 0b                	jg     8009d2 <cvprintfmt+0x13f>
  8009c7:	8b 14 85 c0 1a 80 00 	mov    0x801ac0(,%eax,4),%edx
  8009ce:	85 d2                	test   %edx,%edx
  8009d0:	75 23                	jne    8009f5 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  8009d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d6:	c7 44 24 08 54 17 80 	movl   $0x801754,0x8(%esp)
  8009dd:	00 
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	89 04 24             	mov    %eax,(%esp)
  8009eb:	e8 a7 fa ff ff       	call   800497 <printfmt>
  8009f0:	e9 e0 fe ff ff       	jmp    8008d5 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  8009f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009f9:	c7 44 24 08 5d 17 80 	movl   $0x80175d,0x8(%esp)
  800a00:	00 
  800a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	89 04 24             	mov    %eax,(%esp)
  800a0e:	e8 84 fa ff ff       	call   800497 <printfmt>
  800a13:	e9 bd fe ff ff       	jmp    8008d5 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a18:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a1b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800a1e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a21:	8d 48 04             	lea    0x4(%eax),%ecx
  800a24:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a27:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a29:	85 ff                	test   %edi,%edi
  800a2b:	b8 4d 17 80 00       	mov    $0x80174d,%eax
  800a30:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a33:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a37:	74 61                	je     800a9a <cvprintfmt+0x207>
  800a39:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a3d:	7e 5b                	jle    800a9a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a43:	89 3c 24             	mov    %edi,(%esp)
  800a46:	e8 ed 02 00 00       	call   800d38 <strnlen>
  800a4b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a4e:	29 c2                	sub    %eax,%edx
  800a50:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800a53:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a57:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a5a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a5d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800a60:	8b 75 08             	mov    0x8(%ebp),%esi
  800a63:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a66:	89 d3                	mov    %edx,%ebx
  800a68:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a6a:	eb 0f                	jmp    800a7b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a73:	89 3c 24             	mov    %edi,(%esp)
  800a76:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a78:	83 eb 01             	sub    $0x1,%ebx
  800a7b:	85 db                	test   %ebx,%ebx
  800a7d:	7f ed                	jg     800a6c <cvprintfmt+0x1d9>
  800a7f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a82:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a88:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a8b:	85 d2                	test   %edx,%edx
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	0f 49 c2             	cmovns %edx,%eax
  800a95:	29 c2                	sub    %eax,%edx
  800a97:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800a9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a9d:	83 c8 3f             	or     $0x3f,%eax
  800aa0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800aa9:	eb 36                	jmp    800ae1 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aaf:	74 1d                	je     800ace <cvprintfmt+0x23b>
  800ab1:	0f be d2             	movsbl %dl,%edx
  800ab4:	83 ea 20             	sub    $0x20,%edx
  800ab7:	83 fa 5e             	cmp    $0x5e,%edx
  800aba:	76 12                	jbe    800ace <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800abc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ac6:	89 04 24             	mov    %eax,(%esp)
  800ac9:	ff 55 08             	call   *0x8(%ebp)
  800acc:	eb 10                	jmp    800ade <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad5:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800ad8:	89 04 24             	mov    %eax,(%esp)
  800adb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ade:	83 eb 01             	sub    $0x1,%ebx
  800ae1:	83 c7 01             	add    $0x1,%edi
  800ae4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800ae8:	0f be c2             	movsbl %dl,%eax
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	74 27                	je     800b16 <cvprintfmt+0x283>
  800aef:	85 f6                	test   %esi,%esi
  800af1:	78 b8                	js     800aab <cvprintfmt+0x218>
  800af3:	83 ee 01             	sub    $0x1,%esi
  800af6:	79 b3                	jns    800aab <cvprintfmt+0x218>
  800af8:	89 d8                	mov    %ebx,%eax
  800afa:	8b 75 08             	mov    0x8(%ebp),%esi
  800afd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b00:	89 c3                	mov    %eax,%ebx
  800b02:	eb 18                	jmp    800b1c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800b04:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b0f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800b11:	83 eb 01             	sub    $0x1,%ebx
  800b14:	eb 06                	jmp    800b1c <cvprintfmt+0x289>
  800b16:	8b 75 08             	mov    0x8(%ebp),%esi
  800b19:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b1c:	85 db                	test   %ebx,%ebx
  800b1e:	7f e4                	jg     800b04 <cvprintfmt+0x271>
  800b20:	89 75 08             	mov    %esi,0x8(%ebp)
  800b23:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b29:	e9 a7 fd ff ff       	jmp    8008d5 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b2e:	83 fa 01             	cmp    $0x1,%edx
  800b31:	7e 10                	jle    800b43 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800b33:	8b 45 14             	mov    0x14(%ebp),%eax
  800b36:	8d 50 08             	lea    0x8(%eax),%edx
  800b39:	89 55 14             	mov    %edx,0x14(%ebp)
  800b3c:	8b 30                	mov    (%eax),%esi
  800b3e:	8b 78 04             	mov    0x4(%eax),%edi
  800b41:	eb 26                	jmp    800b69 <cvprintfmt+0x2d6>
	else if (lflag)
  800b43:	85 d2                	test   %edx,%edx
  800b45:	74 12                	je     800b59 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800b47:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4a:	8d 50 04             	lea    0x4(%eax),%edx
  800b4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b50:	8b 30                	mov    (%eax),%esi
  800b52:	89 f7                	mov    %esi,%edi
  800b54:	c1 ff 1f             	sar    $0x1f,%edi
  800b57:	eb 10                	jmp    800b69 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800b59:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5c:	8d 50 04             	lea    0x4(%eax),%edx
  800b5f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b62:	8b 30                	mov    (%eax),%esi
  800b64:	89 f7                	mov    %esi,%edi
  800b66:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b69:	89 f0                	mov    %esi,%eax
  800b6b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b6d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b72:	85 ff                	test   %edi,%edi
  800b74:	0f 89 8e 00 00 00    	jns    800c08 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b84:	83 c8 2d             	or     $0x2d,%eax
  800b87:	89 04 24             	mov    %eax,(%esp)
  800b8a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	89 fa                	mov    %edi,%edx
  800b91:	f7 d8                	neg    %eax
  800b93:	83 d2 00             	adc    $0x0,%edx
  800b96:	f7 da                	neg    %edx
			}
			base = 10;
  800b98:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b9d:	eb 69                	jmp    800c08 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b9f:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba2:	e8 99 f8 ff ff       	call   800440 <getuint>
			base = 10;
  800ba7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bac:	eb 5a                	jmp    800c08 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800bae:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb1:	e8 8a f8 ff ff       	call   800440 <getuint>
			base = 8 ;
  800bb6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800bbb:	eb 4b                	jmp    800c08 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800bc7:	89 f0                	mov    %esi,%eax
  800bc9:	83 c8 30             	or     $0x30,%eax
  800bcc:	89 04 24             	mov    %eax,(%esp)
  800bcf:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd9:	89 f0                	mov    %esi,%eax
  800bdb:	83 c8 78             	or     $0x78,%eax
  800bde:	89 04 24             	mov    %eax,(%esp)
  800be1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800be4:	8b 45 14             	mov    0x14(%ebp),%eax
  800be7:	8d 50 04             	lea    0x4(%eax),%edx
  800bea:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800bed:	8b 00                	mov    (%eax),%eax
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bf4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bf9:	eb 0d                	jmp    800c08 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bfb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bfe:	e8 3d f8 ff ff       	call   800440 <getuint>
			base = 16;
  800c03:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800c08:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800c0c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c10:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800c13:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c17:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c1b:	89 04 24             	mov    %eax,(%esp)
  800c1e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2b:	e8 0f f7 ff ff       	call   80033f <cprintnum>
			break;
  800c30:	e9 a0 fc ff ff       	jmp    8008d5 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800c35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c38:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c3c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800c3f:	89 04 24             	mov    %eax,(%esp)
  800c42:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c45:	e9 8b fc ff ff       	jmp    8008d5 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c54:	89 04 24             	mov    %eax,(%esp)
  800c57:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c5a:	89 fb                	mov    %edi,%ebx
  800c5c:	eb 03                	jmp    800c61 <cvprintfmt+0x3ce>
  800c5e:	83 eb 01             	sub    $0x1,%ebx
  800c61:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c65:	75 f7                	jne    800c5e <cvprintfmt+0x3cb>
  800c67:	e9 69 fc ff ff       	jmp    8008d5 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800c6c:	83 c4 3c             	add    $0x3c,%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c7a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800c7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c81:	8b 45 10             	mov    0x10(%ebp),%eax
  800c84:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	89 04 24             	mov    %eax,(%esp)
  800c95:	e8 f9 fb ff ff       	call   800893 <cvprintfmt>
	va_end(ap);
}
  800c9a:	c9                   	leave  
  800c9b:	c3                   	ret    

00800c9c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 28             	sub    $0x28,%esp
  800ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800caf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cb2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	74 30                	je     800ced <vsnprintf+0x51>
  800cbd:	85 d2                	test   %edx,%edx
  800cbf:	7e 2c                	jle    800ced <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cc1:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ccf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd6:	c7 04 24 7a 04 80 00 	movl   $0x80047a,(%esp)
  800cdd:	e8 dd f7 ff ff       	call   8004bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ce2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ce5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ceb:	eb 05                	jmp    800cf2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ced:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cfa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d01:	8b 45 10             	mov    0x10(%ebp),%eax
  800d04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d12:	89 04 24             	mov    %eax,(%esp)
  800d15:	e8 82 ff ff ff       	call   800c9c <vsnprintf>
	va_end(ap);

	return rc;
}
  800d1a:	c9                   	leave  
  800d1b:	c3                   	ret    
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d26:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2b:	eb 03                	jmp    800d30 <strlen+0x10>
		n++;
  800d2d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d30:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d34:	75 f7                	jne    800d2d <strlen+0xd>
		n++;
	return n;
}
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
  800d46:	eb 03                	jmp    800d4b <strnlen+0x13>
		n++;
  800d48:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4b:	39 d0                	cmp    %edx,%eax
  800d4d:	74 06                	je     800d55 <strnlen+0x1d>
  800d4f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d53:	75 f3                	jne    800d48 <strnlen+0x10>
		n++;
	return n;
}
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	53                   	push   %ebx
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d61:	89 c2                	mov    %eax,%edx
  800d63:	83 c2 01             	add    $0x1,%edx
  800d66:	83 c1 01             	add    $0x1,%ecx
  800d69:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d6d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d70:	84 db                	test   %bl,%bl
  800d72:	75 ef                	jne    800d63 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d74:	5b                   	pop    %ebx
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 08             	sub    $0x8,%esp
  800d7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d81:	89 1c 24             	mov    %ebx,(%esp)
  800d84:	e8 97 ff ff ff       	call   800d20 <strlen>
	strcpy(dst + len, src);
  800d89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d90:	01 d8                	add    %ebx,%eax
  800d92:	89 04 24             	mov    %eax,(%esp)
  800d95:	e8 bd ff ff ff       	call   800d57 <strcpy>
	return dst;
}
  800d9a:	89 d8                	mov    %ebx,%eax
  800d9c:	83 c4 08             	add    $0x8,%esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	8b 75 08             	mov    0x8(%ebp),%esi
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	89 f3                	mov    %esi,%ebx
  800daf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db2:	89 f2                	mov    %esi,%edx
  800db4:	eb 0f                	jmp    800dc5 <strncpy+0x23>
		*dst++ = *src;
  800db6:	83 c2 01             	add    $0x1,%edx
  800db9:	0f b6 01             	movzbl (%ecx),%eax
  800dbc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dbf:	80 39 01             	cmpb   $0x1,(%ecx)
  800dc2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc5:	39 da                	cmp    %ebx,%edx
  800dc7:	75 ed                	jne    800db6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dda:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800de3:	85 c9                	test   %ecx,%ecx
  800de5:	75 0b                	jne    800df2 <strlcpy+0x23>
  800de7:	eb 1d                	jmp    800e06 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800de9:	83 c0 01             	add    $0x1,%eax
  800dec:	83 c2 01             	add    $0x1,%edx
  800def:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800df2:	39 d8                	cmp    %ebx,%eax
  800df4:	74 0b                	je     800e01 <strlcpy+0x32>
  800df6:	0f b6 0a             	movzbl (%edx),%ecx
  800df9:	84 c9                	test   %cl,%cl
  800dfb:	75 ec                	jne    800de9 <strlcpy+0x1a>
  800dfd:	89 c2                	mov    %eax,%edx
  800dff:	eb 02                	jmp    800e03 <strlcpy+0x34>
  800e01:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800e03:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800e06:	29 f0                	sub    %esi,%eax
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e12:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e15:	eb 06                	jmp    800e1d <strcmp+0x11>
		p++, q++;
  800e17:	83 c1 01             	add    $0x1,%ecx
  800e1a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e1d:	0f b6 01             	movzbl (%ecx),%eax
  800e20:	84 c0                	test   %al,%al
  800e22:	74 04                	je     800e28 <strcmp+0x1c>
  800e24:	3a 02                	cmp    (%edx),%al
  800e26:	74 ef                	je     800e17 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e28:	0f b6 c0             	movzbl %al,%eax
  800e2b:	0f b6 12             	movzbl (%edx),%edx
  800e2e:	29 d0                	sub    %edx,%eax
}
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	53                   	push   %ebx
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3c:	89 c3                	mov    %eax,%ebx
  800e3e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e41:	eb 06                	jmp    800e49 <strncmp+0x17>
		n--, p++, q++;
  800e43:	83 c0 01             	add    $0x1,%eax
  800e46:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e49:	39 d8                	cmp    %ebx,%eax
  800e4b:	74 15                	je     800e62 <strncmp+0x30>
  800e4d:	0f b6 08             	movzbl (%eax),%ecx
  800e50:	84 c9                	test   %cl,%cl
  800e52:	74 04                	je     800e58 <strncmp+0x26>
  800e54:	3a 0a                	cmp    (%edx),%cl
  800e56:	74 eb                	je     800e43 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e58:	0f b6 00             	movzbl (%eax),%eax
  800e5b:	0f b6 12             	movzbl (%edx),%edx
  800e5e:	29 d0                	sub    %edx,%eax
  800e60:	eb 05                	jmp    800e67 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e67:	5b                   	pop    %ebx
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e74:	eb 07                	jmp    800e7d <strchr+0x13>
		if (*s == c)
  800e76:	38 ca                	cmp    %cl,%dl
  800e78:	74 0f                	je     800e89 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e7a:	83 c0 01             	add    $0x1,%eax
  800e7d:	0f b6 10             	movzbl (%eax),%edx
  800e80:	84 d2                	test   %dl,%dl
  800e82:	75 f2                	jne    800e76 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e95:	eb 07                	jmp    800e9e <strfind+0x13>
		if (*s == c)
  800e97:	38 ca                	cmp    %cl,%dl
  800e99:	74 0a                	je     800ea5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e9b:	83 c0 01             	add    $0x1,%eax
  800e9e:	0f b6 10             	movzbl (%eax),%edx
  800ea1:	84 d2                	test   %dl,%dl
  800ea3:	75 f2                	jne    800e97 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eb0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800eb3:	85 c9                	test   %ecx,%ecx
  800eb5:	74 36                	je     800eed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eb7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ebd:	75 28                	jne    800ee7 <memset+0x40>
  800ebf:	f6 c1 03             	test   $0x3,%cl
  800ec2:	75 23                	jne    800ee7 <memset+0x40>
		c &= 0xFF;
  800ec4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ec8:	89 d3                	mov    %edx,%ebx
  800eca:	c1 e3 08             	shl    $0x8,%ebx
  800ecd:	89 d6                	mov    %edx,%esi
  800ecf:	c1 e6 18             	shl    $0x18,%esi
  800ed2:	89 d0                	mov    %edx,%eax
  800ed4:	c1 e0 10             	shl    $0x10,%eax
  800ed7:	09 f0                	or     %esi,%eax
  800ed9:	09 c2                	or     %eax,%edx
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800edf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ee2:	fc                   	cld    
  800ee3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ee5:	eb 06                	jmp    800eed <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eea:	fc                   	cld    
  800eeb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800eed:	89 f8                	mov    %edi,%eax
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f02:	39 c6                	cmp    %eax,%esi
  800f04:	73 35                	jae    800f3b <memmove+0x47>
  800f06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f09:	39 d0                	cmp    %edx,%eax
  800f0b:	73 2e                	jae    800f3b <memmove+0x47>
		s += n;
		d += n;
  800f0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800f10:	89 d6                	mov    %edx,%esi
  800f12:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f1a:	75 13                	jne    800f2f <memmove+0x3b>
  800f1c:	f6 c1 03             	test   $0x3,%cl
  800f1f:	75 0e                	jne    800f2f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f21:	83 ef 04             	sub    $0x4,%edi
  800f24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f2a:	fd                   	std    
  800f2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f2d:	eb 09                	jmp    800f38 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f2f:	83 ef 01             	sub    $0x1,%edi
  800f32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f35:	fd                   	std    
  800f36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f38:	fc                   	cld    
  800f39:	eb 1d                	jmp    800f58 <memmove+0x64>
  800f3b:	89 f2                	mov    %esi,%edx
  800f3d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3f:	f6 c2 03             	test   $0x3,%dl
  800f42:	75 0f                	jne    800f53 <memmove+0x5f>
  800f44:	f6 c1 03             	test   $0x3,%cl
  800f47:	75 0a                	jne    800f53 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f49:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f4c:	89 c7                	mov    %eax,%edi
  800f4e:	fc                   	cld    
  800f4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f51:	eb 05                	jmp    800f58 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f53:	89 c7                	mov    %eax,%edi
  800f55:	fc                   	cld    
  800f56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f62:	8b 45 10             	mov    0x10(%ebp),%eax
  800f65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f70:	8b 45 08             	mov    0x8(%ebp),%eax
  800f73:	89 04 24             	mov    %eax,(%esp)
  800f76:	e8 79 ff ff ff       	call   800ef4 <memmove>
}
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
  800f82:	8b 55 08             	mov    0x8(%ebp),%edx
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	89 d6                	mov    %edx,%esi
  800f8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f8d:	eb 1a                	jmp    800fa9 <memcmp+0x2c>
		if (*s1 != *s2)
  800f8f:	0f b6 02             	movzbl (%edx),%eax
  800f92:	0f b6 19             	movzbl (%ecx),%ebx
  800f95:	38 d8                	cmp    %bl,%al
  800f97:	74 0a                	je     800fa3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f99:	0f b6 c0             	movzbl %al,%eax
  800f9c:	0f b6 db             	movzbl %bl,%ebx
  800f9f:	29 d8                	sub    %ebx,%eax
  800fa1:	eb 0f                	jmp    800fb2 <memcmp+0x35>
		s1++, s2++;
  800fa3:	83 c2 01             	add    $0x1,%edx
  800fa6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fa9:	39 f2                	cmp    %esi,%edx
  800fab:	75 e2                	jne    800f8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fbf:	89 c2                	mov    %eax,%edx
  800fc1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fc4:	eb 07                	jmp    800fcd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fc6:	38 08                	cmp    %cl,(%eax)
  800fc8:	74 07                	je     800fd1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fca:	83 c0 01             	add    $0x1,%eax
  800fcd:	39 d0                	cmp    %edx,%eax
  800fcf:	72 f5                	jb     800fc6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fdf:	eb 03                	jmp    800fe4 <strtol+0x11>
		s++;
  800fe1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fe4:	0f b6 0a             	movzbl (%edx),%ecx
  800fe7:	80 f9 09             	cmp    $0x9,%cl
  800fea:	74 f5                	je     800fe1 <strtol+0xe>
  800fec:	80 f9 20             	cmp    $0x20,%cl
  800fef:	74 f0                	je     800fe1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ff1:	80 f9 2b             	cmp    $0x2b,%cl
  800ff4:	75 0a                	jne    801000 <strtol+0x2d>
		s++;
  800ff6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ff9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ffe:	eb 11                	jmp    801011 <strtol+0x3e>
  801000:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801005:	80 f9 2d             	cmp    $0x2d,%cl
  801008:	75 07                	jne    801011 <strtol+0x3e>
		s++, neg = 1;
  80100a:	8d 52 01             	lea    0x1(%edx),%edx
  80100d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801011:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801016:	75 15                	jne    80102d <strtol+0x5a>
  801018:	80 3a 30             	cmpb   $0x30,(%edx)
  80101b:	75 10                	jne    80102d <strtol+0x5a>
  80101d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801021:	75 0a                	jne    80102d <strtol+0x5a>
		s += 2, base = 16;
  801023:	83 c2 02             	add    $0x2,%edx
  801026:	b8 10 00 00 00       	mov    $0x10,%eax
  80102b:	eb 10                	jmp    80103d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80102d:	85 c0                	test   %eax,%eax
  80102f:	75 0c                	jne    80103d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801031:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801033:	80 3a 30             	cmpb   $0x30,(%edx)
  801036:	75 05                	jne    80103d <strtol+0x6a>
		s++, base = 8;
  801038:	83 c2 01             	add    $0x1,%edx
  80103b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80103d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801042:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801045:	0f b6 0a             	movzbl (%edx),%ecx
  801048:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80104b:	89 f0                	mov    %esi,%eax
  80104d:	3c 09                	cmp    $0x9,%al
  80104f:	77 08                	ja     801059 <strtol+0x86>
			dig = *s - '0';
  801051:	0f be c9             	movsbl %cl,%ecx
  801054:	83 e9 30             	sub    $0x30,%ecx
  801057:	eb 20                	jmp    801079 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801059:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80105c:	89 f0                	mov    %esi,%eax
  80105e:	3c 19                	cmp    $0x19,%al
  801060:	77 08                	ja     80106a <strtol+0x97>
			dig = *s - 'a' + 10;
  801062:	0f be c9             	movsbl %cl,%ecx
  801065:	83 e9 57             	sub    $0x57,%ecx
  801068:	eb 0f                	jmp    801079 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80106a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80106d:	89 f0                	mov    %esi,%eax
  80106f:	3c 19                	cmp    $0x19,%al
  801071:	77 16                	ja     801089 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801073:	0f be c9             	movsbl %cl,%ecx
  801076:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801079:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80107c:	7d 0f                	jge    80108d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80107e:	83 c2 01             	add    $0x1,%edx
  801081:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801085:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801087:	eb bc                	jmp    801045 <strtol+0x72>
  801089:	89 d8                	mov    %ebx,%eax
  80108b:	eb 02                	jmp    80108f <strtol+0xbc>
  80108d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80108f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801093:	74 05                	je     80109a <strtol+0xc7>
		*endptr = (char *) s;
  801095:	8b 75 0c             	mov    0xc(%ebp),%esi
  801098:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80109a:	f7 d8                	neg    %eax
  80109c:	85 ff                	test   %edi,%edi
  80109e:	0f 44 c3             	cmove  %ebx,%eax
}
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b7:	89 c3                	mov    %eax,%ebx
  8010b9:	89 c7                	mov    %eax,%edi
  8010bb:	89 c6                	mov    %eax,%esi
  8010bd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d4:	89 d1                	mov    %edx,%ecx
  8010d6:	89 d3                	mov    %edx,%ebx
  8010d8:	89 d7                	mov    %edx,%edi
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8010f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f9:	89 cb                	mov    %ecx,%ebx
  8010fb:	89 cf                	mov    %ecx,%edi
  8010fd:	89 ce                	mov    %ecx,%esi
  8010ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801101:	85 c0                	test   %eax,%eax
  801103:	7e 28                	jle    80112d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801105:	89 44 24 10          	mov    %eax,0x10(%esp)
  801109:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801110:	00 
  801111:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  801118:	00 
  801119:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801120:	00 
  801121:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  801128:	e8 0f f0 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80112d:	83 c4 2c             	add    $0x2c,%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113b:	ba 00 00 00 00       	mov    $0x0,%edx
  801140:	b8 02 00 00 00       	mov    $0x2,%eax
  801145:	89 d1                	mov    %edx,%ecx
  801147:	89 d3                	mov    %edx,%ebx
  801149:	89 d7                	mov    %edx,%edi
  80114b:	89 d6                	mov    %edx,%esi
  80114d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5f                   	pop    %edi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <sys_yield>:

void
sys_yield(void)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115a:	ba 00 00 00 00       	mov    $0x0,%edx
  80115f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801164:	89 d1                	mov    %edx,%ecx
  801166:	89 d3                	mov    %edx,%ebx
  801168:	89 d7                	mov    %edx,%edi
  80116a:	89 d6                	mov    %edx,%esi
  80116c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117c:	be 00 00 00 00       	mov    $0x0,%esi
  801181:	b8 04 00 00 00       	mov    $0x4,%eax
  801186:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801189:	8b 55 08             	mov    0x8(%ebp),%edx
  80118c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80118f:	89 f7                	mov    %esi,%edi
  801191:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801193:	85 c0                	test   %eax,%eax
  801195:	7e 28                	jle    8011bf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801197:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8011a2:	00 
  8011a3:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b2:	00 
  8011b3:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  8011ba:	e8 7d ef ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011bf:	83 c4 2c             	add    $0x2c,%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8011d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011e1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	7e 28                	jle    801212 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ee:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011f5:	00 
  8011f6:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  8011fd:	00 
  8011fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801205:	00 
  801206:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  80120d:	e8 2a ef ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801212:	83 c4 2c             	add    $0x2c,%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5f                   	pop    %edi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	57                   	push   %edi
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801223:	bb 00 00 00 00       	mov    $0x0,%ebx
  801228:	b8 06 00 00 00       	mov    $0x6,%eax
  80122d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801230:	8b 55 08             	mov    0x8(%ebp),%edx
  801233:	89 df                	mov    %ebx,%edi
  801235:	89 de                	mov    %ebx,%esi
  801237:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801239:	85 c0                	test   %eax,%eax
  80123b:	7e 28                	jle    801265 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80123d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801241:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801248:	00 
  801249:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  801250:	00 
  801251:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801258:	00 
  801259:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  801260:	e8 d7 ee ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801265:	83 c4 2c             	add    $0x2c,%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	57                   	push   %edi
  801271:	56                   	push   %esi
  801272:	53                   	push   %ebx
  801273:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801276:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127b:	b8 08 00 00 00       	mov    $0x8,%eax
  801280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801283:	8b 55 08             	mov    0x8(%ebp),%edx
  801286:	89 df                	mov    %ebx,%edi
  801288:	89 de                	mov    %ebx,%esi
  80128a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80128c:	85 c0                	test   %eax,%eax
  80128e:	7e 28                	jle    8012b8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801290:	89 44 24 10          	mov    %eax,0x10(%esp)
  801294:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80129b:	00 
  80129c:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  8012a3:	00 
  8012a4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012ab:	00 
  8012ac:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  8012b3:	e8 84 ee ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012b8:	83 c4 2c             	add    $0x2c,%esp
  8012bb:	5b                   	pop    %ebx
  8012bc:	5e                   	pop    %esi
  8012bd:	5f                   	pop    %edi
  8012be:	5d                   	pop    %ebp
  8012bf:	c3                   	ret    

008012c0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	57                   	push   %edi
  8012c4:	56                   	push   %esi
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ce:	b8 09 00 00 00       	mov    $0x9,%eax
  8012d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d9:	89 df                	mov    %ebx,%edi
  8012db:	89 de                	mov    %ebx,%esi
  8012dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	7e 28                	jle    80130b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012e7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012ee:	00 
  8012ef:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  8012f6:	00 
  8012f7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012fe:	00 
  8012ff:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  801306:	e8 31 ee ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80130b:	83 c4 2c             	add    $0x2c,%esp
  80130e:	5b                   	pop    %ebx
  80130f:	5e                   	pop    %esi
  801310:	5f                   	pop    %edi
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    

00801313 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	57                   	push   %edi
  801317:	56                   	push   %esi
  801318:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801319:	be 00 00 00 00       	mov    $0x0,%esi
  80131e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801326:	8b 55 08             	mov    0x8(%ebp),%edx
  801329:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80132c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80132f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	57                   	push   %edi
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
  80133c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80133f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801344:	b8 0c 00 00 00       	mov    $0xc,%eax
  801349:	8b 55 08             	mov    0x8(%ebp),%edx
  80134c:	89 cb                	mov    %ecx,%ebx
  80134e:	89 cf                	mov    %ecx,%edi
  801350:	89 ce                	mov    %ecx,%esi
  801352:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801354:	85 c0                	test   %eax,%eax
  801356:	7e 28                	jle    801380 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801358:	89 44 24 10          	mov    %eax,0x10(%esp)
  80135c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801363:	00 
  801364:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  80136b:	00 
  80136c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801373:	00 
  801374:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  80137b:	e8 bc ed ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801380:	83 c4 2c             	add    $0x2c,%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80138e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801395:	75 32                	jne    8013c9 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  801397:	e8 99 fd ff ff       	call   801135 <sys_getenvid>
  80139c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013a3:	00 
  8013a4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013ab:	ee 
  8013ac:	89 04 24             	mov    %eax,(%esp)
  8013af:	e8 bf fd ff ff       	call   801173 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  8013b4:	e8 7c fd ff ff       	call   801135 <sys_getenvid>
  8013b9:	c7 44 24 04 d3 13 80 	movl   $0x8013d3,0x4(%esp)
  8013c0:	00 
  8013c1:	89 04 24             	mov    %eax,(%esp)
  8013c4:	e8 f7 fe ff ff       	call   8012c0 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cc:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013d3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013d4:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8013d9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013db:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  8013de:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  8013e1:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  8013e5:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  8013e9:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  8013ec:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  8013f0:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  8013f2:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  8013f3:	83 c4 04             	add    $0x4,%esp
	popfl 	
  8013f6:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8013f7:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8013f8:	c3                   	ret    
  8013f9:	66 90                	xchg   %ax,%ax
  8013fb:	66 90                	xchg   %ax,%ax
  8013fd:	66 90                	xchg   %ax,%ax
  8013ff:	90                   	nop

00801400 <__udivdi3>:
  801400:	55                   	push   %ebp
  801401:	57                   	push   %edi
  801402:	56                   	push   %esi
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	8b 44 24 28          	mov    0x28(%esp),%eax
  80140a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80140e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801412:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801416:	85 c0                	test   %eax,%eax
  801418:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80141c:	89 ea                	mov    %ebp,%edx
  80141e:	89 0c 24             	mov    %ecx,(%esp)
  801421:	75 2d                	jne    801450 <__udivdi3+0x50>
  801423:	39 e9                	cmp    %ebp,%ecx
  801425:	77 61                	ja     801488 <__udivdi3+0x88>
  801427:	85 c9                	test   %ecx,%ecx
  801429:	89 ce                	mov    %ecx,%esi
  80142b:	75 0b                	jne    801438 <__udivdi3+0x38>
  80142d:	b8 01 00 00 00       	mov    $0x1,%eax
  801432:	31 d2                	xor    %edx,%edx
  801434:	f7 f1                	div    %ecx
  801436:	89 c6                	mov    %eax,%esi
  801438:	31 d2                	xor    %edx,%edx
  80143a:	89 e8                	mov    %ebp,%eax
  80143c:	f7 f6                	div    %esi
  80143e:	89 c5                	mov    %eax,%ebp
  801440:	89 f8                	mov    %edi,%eax
  801442:	f7 f6                	div    %esi
  801444:	89 ea                	mov    %ebp,%edx
  801446:	83 c4 0c             	add    $0xc,%esp
  801449:	5e                   	pop    %esi
  80144a:	5f                   	pop    %edi
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    
  80144d:	8d 76 00             	lea    0x0(%esi),%esi
  801450:	39 e8                	cmp    %ebp,%eax
  801452:	77 24                	ja     801478 <__udivdi3+0x78>
  801454:	0f bd e8             	bsr    %eax,%ebp
  801457:	83 f5 1f             	xor    $0x1f,%ebp
  80145a:	75 3c                	jne    801498 <__udivdi3+0x98>
  80145c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801460:	39 34 24             	cmp    %esi,(%esp)
  801463:	0f 86 9f 00 00 00    	jbe    801508 <__udivdi3+0x108>
  801469:	39 d0                	cmp    %edx,%eax
  80146b:	0f 82 97 00 00 00    	jb     801508 <__udivdi3+0x108>
  801471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801478:	31 d2                	xor    %edx,%edx
  80147a:	31 c0                	xor    %eax,%eax
  80147c:	83 c4 0c             	add    $0xc,%esp
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    
  801483:	90                   	nop
  801484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801488:	89 f8                	mov    %edi,%eax
  80148a:	f7 f1                	div    %ecx
  80148c:	31 d2                	xor    %edx,%edx
  80148e:	83 c4 0c             	add    $0xc,%esp
  801491:	5e                   	pop    %esi
  801492:	5f                   	pop    %edi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    
  801495:	8d 76 00             	lea    0x0(%esi),%esi
  801498:	89 e9                	mov    %ebp,%ecx
  80149a:	8b 3c 24             	mov    (%esp),%edi
  80149d:	d3 e0                	shl    %cl,%eax
  80149f:	89 c6                	mov    %eax,%esi
  8014a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8014a6:	29 e8                	sub    %ebp,%eax
  8014a8:	89 c1                	mov    %eax,%ecx
  8014aa:	d3 ef                	shr    %cl,%edi
  8014ac:	89 e9                	mov    %ebp,%ecx
  8014ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014b2:	8b 3c 24             	mov    (%esp),%edi
  8014b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8014b9:	89 d6                	mov    %edx,%esi
  8014bb:	d3 e7                	shl    %cl,%edi
  8014bd:	89 c1                	mov    %eax,%ecx
  8014bf:	89 3c 24             	mov    %edi,(%esp)
  8014c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014c6:	d3 ee                	shr    %cl,%esi
  8014c8:	89 e9                	mov    %ebp,%ecx
  8014ca:	d3 e2                	shl    %cl,%edx
  8014cc:	89 c1                	mov    %eax,%ecx
  8014ce:	d3 ef                	shr    %cl,%edi
  8014d0:	09 d7                	or     %edx,%edi
  8014d2:	89 f2                	mov    %esi,%edx
  8014d4:	89 f8                	mov    %edi,%eax
  8014d6:	f7 74 24 08          	divl   0x8(%esp)
  8014da:	89 d6                	mov    %edx,%esi
  8014dc:	89 c7                	mov    %eax,%edi
  8014de:	f7 24 24             	mull   (%esp)
  8014e1:	39 d6                	cmp    %edx,%esi
  8014e3:	89 14 24             	mov    %edx,(%esp)
  8014e6:	72 30                	jb     801518 <__udivdi3+0x118>
  8014e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014ec:	89 e9                	mov    %ebp,%ecx
  8014ee:	d3 e2                	shl    %cl,%edx
  8014f0:	39 c2                	cmp    %eax,%edx
  8014f2:	73 05                	jae    8014f9 <__udivdi3+0xf9>
  8014f4:	3b 34 24             	cmp    (%esp),%esi
  8014f7:	74 1f                	je     801518 <__udivdi3+0x118>
  8014f9:	89 f8                	mov    %edi,%eax
  8014fb:	31 d2                	xor    %edx,%edx
  8014fd:	e9 7a ff ff ff       	jmp    80147c <__udivdi3+0x7c>
  801502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801508:	31 d2                	xor    %edx,%edx
  80150a:	b8 01 00 00 00       	mov    $0x1,%eax
  80150f:	e9 68 ff ff ff       	jmp    80147c <__udivdi3+0x7c>
  801514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801518:	8d 47 ff             	lea    -0x1(%edi),%eax
  80151b:	31 d2                	xor    %edx,%edx
  80151d:	83 c4 0c             	add    $0xc,%esp
  801520:	5e                   	pop    %esi
  801521:	5f                   	pop    %edi
  801522:	5d                   	pop    %ebp
  801523:	c3                   	ret    
  801524:	66 90                	xchg   %ax,%ax
  801526:	66 90                	xchg   %ax,%ax
  801528:	66 90                	xchg   %ax,%ax
  80152a:	66 90                	xchg   %ax,%ax
  80152c:	66 90                	xchg   %ax,%ax
  80152e:	66 90                	xchg   %ax,%ax

00801530 <__umoddi3>:
  801530:	55                   	push   %ebp
  801531:	57                   	push   %edi
  801532:	56                   	push   %esi
  801533:	83 ec 14             	sub    $0x14,%esp
  801536:	8b 44 24 28          	mov    0x28(%esp),%eax
  80153a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80153e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801542:	89 c7                	mov    %eax,%edi
  801544:	89 44 24 04          	mov    %eax,0x4(%esp)
  801548:	8b 44 24 30          	mov    0x30(%esp),%eax
  80154c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801550:	89 34 24             	mov    %esi,(%esp)
  801553:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801557:	85 c0                	test   %eax,%eax
  801559:	89 c2                	mov    %eax,%edx
  80155b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80155f:	75 17                	jne    801578 <__umoddi3+0x48>
  801561:	39 fe                	cmp    %edi,%esi
  801563:	76 4b                	jbe    8015b0 <__umoddi3+0x80>
  801565:	89 c8                	mov    %ecx,%eax
  801567:	89 fa                	mov    %edi,%edx
  801569:	f7 f6                	div    %esi
  80156b:	89 d0                	mov    %edx,%eax
  80156d:	31 d2                	xor    %edx,%edx
  80156f:	83 c4 14             	add    $0x14,%esp
  801572:	5e                   	pop    %esi
  801573:	5f                   	pop    %edi
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    
  801576:	66 90                	xchg   %ax,%ax
  801578:	39 f8                	cmp    %edi,%eax
  80157a:	77 54                	ja     8015d0 <__umoddi3+0xa0>
  80157c:	0f bd e8             	bsr    %eax,%ebp
  80157f:	83 f5 1f             	xor    $0x1f,%ebp
  801582:	75 5c                	jne    8015e0 <__umoddi3+0xb0>
  801584:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801588:	39 3c 24             	cmp    %edi,(%esp)
  80158b:	0f 87 e7 00 00 00    	ja     801678 <__umoddi3+0x148>
  801591:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801595:	29 f1                	sub    %esi,%ecx
  801597:	19 c7                	sbb    %eax,%edi
  801599:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80159d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015a9:	83 c4 14             	add    $0x14,%esp
  8015ac:	5e                   	pop    %esi
  8015ad:	5f                   	pop    %edi
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    
  8015b0:	85 f6                	test   %esi,%esi
  8015b2:	89 f5                	mov    %esi,%ebp
  8015b4:	75 0b                	jne    8015c1 <__umoddi3+0x91>
  8015b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015bb:	31 d2                	xor    %edx,%edx
  8015bd:	f7 f6                	div    %esi
  8015bf:	89 c5                	mov    %eax,%ebp
  8015c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8015c5:	31 d2                	xor    %edx,%edx
  8015c7:	f7 f5                	div    %ebp
  8015c9:	89 c8                	mov    %ecx,%eax
  8015cb:	f7 f5                	div    %ebp
  8015cd:	eb 9c                	jmp    80156b <__umoddi3+0x3b>
  8015cf:	90                   	nop
  8015d0:	89 c8                	mov    %ecx,%eax
  8015d2:	89 fa                	mov    %edi,%edx
  8015d4:	83 c4 14             	add    $0x14,%esp
  8015d7:	5e                   	pop    %esi
  8015d8:	5f                   	pop    %edi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    
  8015db:	90                   	nop
  8015dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015e0:	8b 04 24             	mov    (%esp),%eax
  8015e3:	be 20 00 00 00       	mov    $0x20,%esi
  8015e8:	89 e9                	mov    %ebp,%ecx
  8015ea:	29 ee                	sub    %ebp,%esi
  8015ec:	d3 e2                	shl    %cl,%edx
  8015ee:	89 f1                	mov    %esi,%ecx
  8015f0:	d3 e8                	shr    %cl,%eax
  8015f2:	89 e9                	mov    %ebp,%ecx
  8015f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f8:	8b 04 24             	mov    (%esp),%eax
  8015fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8015ff:	89 fa                	mov    %edi,%edx
  801601:	d3 e0                	shl    %cl,%eax
  801603:	89 f1                	mov    %esi,%ecx
  801605:	89 44 24 08          	mov    %eax,0x8(%esp)
  801609:	8b 44 24 10          	mov    0x10(%esp),%eax
  80160d:	d3 ea                	shr    %cl,%edx
  80160f:	89 e9                	mov    %ebp,%ecx
  801611:	d3 e7                	shl    %cl,%edi
  801613:	89 f1                	mov    %esi,%ecx
  801615:	d3 e8                	shr    %cl,%eax
  801617:	89 e9                	mov    %ebp,%ecx
  801619:	09 f8                	or     %edi,%eax
  80161b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80161f:	f7 74 24 04          	divl   0x4(%esp)
  801623:	d3 e7                	shl    %cl,%edi
  801625:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801629:	89 d7                	mov    %edx,%edi
  80162b:	f7 64 24 08          	mull   0x8(%esp)
  80162f:	39 d7                	cmp    %edx,%edi
  801631:	89 c1                	mov    %eax,%ecx
  801633:	89 14 24             	mov    %edx,(%esp)
  801636:	72 2c                	jb     801664 <__umoddi3+0x134>
  801638:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80163c:	72 22                	jb     801660 <__umoddi3+0x130>
  80163e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801642:	29 c8                	sub    %ecx,%eax
  801644:	19 d7                	sbb    %edx,%edi
  801646:	89 e9                	mov    %ebp,%ecx
  801648:	89 fa                	mov    %edi,%edx
  80164a:	d3 e8                	shr    %cl,%eax
  80164c:	89 f1                	mov    %esi,%ecx
  80164e:	d3 e2                	shl    %cl,%edx
  801650:	89 e9                	mov    %ebp,%ecx
  801652:	d3 ef                	shr    %cl,%edi
  801654:	09 d0                	or     %edx,%eax
  801656:	89 fa                	mov    %edi,%edx
  801658:	83 c4 14             	add    $0x14,%esp
  80165b:	5e                   	pop    %esi
  80165c:	5f                   	pop    %edi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    
  80165f:	90                   	nop
  801660:	39 d7                	cmp    %edx,%edi
  801662:	75 da                	jne    80163e <__umoddi3+0x10e>
  801664:	8b 14 24             	mov    (%esp),%edx
  801667:	89 c1                	mov    %eax,%ecx
  801669:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80166d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801671:	eb cb                	jmp    80163e <__umoddi3+0x10e>
  801673:	90                   	nop
  801674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801678:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80167c:	0f 82 0f ff ff ff    	jb     801591 <__umoddi3+0x61>
  801682:	e9 1a ff ff ff       	jmp    8015a1 <__umoddi3+0x71>
