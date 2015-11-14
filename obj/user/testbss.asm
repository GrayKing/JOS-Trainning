
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	c7 04 24 60 16 80 00 	movl   $0x801660,(%esp)
  800040:	e8 12 02 00 00       	call   800257 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800045:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004a:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800051:	00 
  800052:	74 20                	je     800074 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800054:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800058:	c7 44 24 08 db 16 80 	movl   $0x8016db,0x8(%esp)
  80005f:	00 
  800060:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800067:	00 
  800068:	c7 04 24 f8 16 80 00 	movl   $0x8016f8,(%esp)
  80006f:	e8 ea 00 00 00       	call   80015e <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800074:	83 c0 01             	add    $0x1,%eax
  800077:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007c:	75 cc                	jne    80004a <umain+0x17>
  80007e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800083:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008a:	83 c0 01             	add    $0x1,%eax
  80008d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800092:	75 ef                	jne    800083 <umain+0x50>
  800094:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800099:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  8000a0:	74 20                	je     8000c2 <umain+0x8f>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 80 16 80 	movl   $0x801680,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 f8 16 80 00 	movl   $0x8016f8,(%esp)
  8000bd:	e8 9c 00 00 00       	call   80015e <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000ca:	75 cd                	jne    800099 <umain+0x66>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000cc:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  8000d3:	e8 7f 01 00 00       	call   800257 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d8:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000df:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e2:	c7 44 24 08 07 17 80 	movl   $0x801707,0x8(%esp)
  8000e9:	00 
  8000ea:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000f1:	00 
  8000f2:	c7 04 24 f8 16 80 00 	movl   $0x8016f8,(%esp)
  8000f9:	e8 60 00 00 00       	call   80015e <_panic>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 10             	sub    $0x10,%esp
  800106:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800109:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80010c:	e8 54 10 00 00       	call   801165 <sys_getenvid>
  800111:	25 ff 03 00 00       	and    $0x3ff,%eax
  800116:	89 c2                	mov    %eax,%edx
  800118:	c1 e2 07             	shl    $0x7,%edx
  80011b:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800122:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800127:	85 db                	test   %ebx,%ebx
  800129:	7e 07                	jle    800132 <libmain+0x34>
		binaryname = argv[0];
  80012b:	8b 06                	mov    (%esi),%eax
  80012d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800132:	89 74 24 04          	mov    %esi,0x4(%esp)
  800136:	89 1c 24             	mov    %ebx,(%esp)
  800139:	e8 f5 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013e:	e8 07 00 00 00       	call   80014a <exit>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800150:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800157:	e8 b7 0f 00 00       	call   801113 <sys_env_destroy>
}
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800166:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800169:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80016f:	e8 f1 0f 00 00       	call   801165 <sys_getenvid>
  800174:	8b 55 0c             	mov    0xc(%ebp),%edx
  800177:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017b:	8b 55 08             	mov    0x8(%ebp),%edx
  80017e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800182:	89 74 24 08          	mov    %esi,0x8(%esp)
  800186:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018a:	c7 04 24 28 17 80 00 	movl   $0x801728,(%esp)
  800191:	e8 c1 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800196:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 51 00 00 00       	call   8001f6 <vcprintf>
	cprintf("\n");
  8001a5:	c7 04 24 f6 16 80 00 	movl   $0x8016f6,(%esp)
  8001ac:	e8 a6 00 00 00       	call   800257 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b1:	cc                   	int3   
  8001b2:	eb fd                	jmp    8001b1 <_panic+0x53>

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 14             	sub    $0x14,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 13                	mov    (%ebx),%edx
  8001c0:	8d 42 01             	lea    0x1(%edx),%eax
  8001c3:	89 03                	mov    %eax,(%ebx)
  8001c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d1:	75 19                	jne    8001ec <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001da:	00 
  8001db:	8d 43 08             	lea    0x8(%ebx),%eax
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	e8 f0 0e 00 00       	call   8010d6 <sys_cputs>
		b->idx = 0;
  8001e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f0:	83 c4 14             	add    $0x14,%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800206:	00 00 00 
	b.cnt = 0;
  800209:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800210:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
  800216:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800221:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022b:	c7 04 24 b4 01 80 00 	movl   $0x8001b4,(%esp)
  800232:	e8 b8 02 00 00       	call   8004ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800237:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 87 0e 00 00       	call   8010d6 <sys_cputs>

	return b.cnt;
}
  80024f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	e8 87 ff ff ff       	call   8001f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    
  800271:	66 90                	xchg   %ax,%ax
  800273:	66 90                	xchg   %ax,%ax
  800275:	66 90                	xchg   %ax,%ax
  800277:	66 90                	xchg   %ax,%ax
  800279:	66 90                	xchg   %ax,%ax
  80027b:	66 90                	xchg   %ax,%ax
  80027d:	66 90                	xchg   %ax,%ax
  80027f:	90                   	nop

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 c3                	mov    %eax,%ebx
  800299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80029c:	8b 45 10             	mov    0x10(%ebp),%eax
  80029f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ad:	39 d9                	cmp    %ebx,%ecx
  8002af:	72 05                	jb     8002b6 <printnum+0x36>
  8002b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002b4:	77 69                	ja     80031f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002bd:	83 ee 01             	sub    $0x1,%esi
  8002c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002d0:	89 c3                	mov    %eax,%ebx
  8002d2:	89 d6                	mov    %edx,%esi
  8002d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 cc 10 00 00       	call   8013c0 <__udivdi3>
  8002f4:	89 d9                	mov    %ebx,%ecx
  8002f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	89 54 24 04          	mov    %edx,0x4(%esp)
  800305:	89 fa                	mov    %edi,%edx
  800307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030a:	e8 71 ff ff ff       	call   800280 <printnum>
  80030f:	eb 1b                	jmp    80032c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	8b 45 18             	mov    0x18(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff d3                	call   *%ebx
  80031d:	eb 03                	jmp    800322 <printnum+0xa2>
  80031f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800322:	83 ee 01             	sub    $0x1,%esi
  800325:	85 f6                	test   %esi,%esi
  800327:	7f e8                	jg     800311 <printnum+0x91>
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800330:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800337:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80033a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 9c 11 00 00       	call   8014f0 <__umoddi3>
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	0f be 80 4c 17 80 00 	movsbl 0x80174c(%eax),%eax
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800365:	ff d0                	call   *%eax
}
  800367:	83 c4 3c             	add    $0x3c,%esp
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	57                   	push   %edi
  800373:	56                   	push   %esi
  800374:	53                   	push   %ebx
  800375:	83 ec 3c             	sub    $0x3c,%esp
  800378:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80037b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80037e:	89 cf                	mov    %ecx,%edi
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800386:	8b 45 0c             	mov    0xc(%ebp),%eax
  800389:	89 c3                	mov    %eax,%ebx
  80038b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80038e:	8b 45 10             	mov    0x10(%ebp),%eax
  800391:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800394:	b9 00 00 00 00       	mov    $0x0,%ecx
  800399:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80039f:	39 d9                	cmp    %ebx,%ecx
  8003a1:	72 13                	jb     8003b6 <cprintnum+0x47>
  8003a3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003a6:	76 0e                	jbe    8003b6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8003a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ab:	0b 45 18             	or     0x18(%ebp),%eax
  8003ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003b4:	eb 6a                	jmp    800420 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8003b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003bd:	83 ee 01             	sub    $0x1,%esi
  8003c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003d0:	89 c3                	mov    %eax,%ebx
  8003d2:	89 d6                	mov    %edx,%esi
  8003d4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003d7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8003da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e5:	89 04 24             	mov    %eax,(%esp)
  8003e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ef:	e8 cc 0f 00 00       	call   8013c0 <__udivdi3>
  8003f4:	89 d9                	mov    %ebx,%ecx
  8003f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003fe:	89 04 24             	mov    %eax,(%esp)
  800401:	89 54 24 04          	mov    %edx,0x4(%esp)
  800405:	89 f9                	mov    %edi,%ecx
  800407:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80040a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80040d:	e8 5d ff ff ff       	call   80036f <cprintnum>
  800412:	eb 16                	jmp    80042a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800414:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800418:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800420:	83 ee 01             	sub    $0x1,%esi
  800423:	85 f6                	test   %esi,%esi
  800425:	7f ed                	jg     800414 <cprintnum+0xa5>
  800427:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80042a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800432:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800435:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800438:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800440:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800449:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044d:	e8 9e 10 00 00       	call   8014f0 <__umoddi3>
  800452:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800456:	0f be 80 4c 17 80 00 	movsbl 0x80174c(%eax),%eax
  80045d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800466:	ff d0                	call   *%eax
}
  800468:	83 c4 3c             	add    $0x3c,%esp
  80046b:	5b                   	pop    %ebx
  80046c:	5e                   	pop    %esi
  80046d:	5f                   	pop    %edi
  80046e:	5d                   	pop    %ebp
  80046f:	c3                   	ret    

00800470 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800473:	83 fa 01             	cmp    $0x1,%edx
  800476:	7e 0e                	jle    800486 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80047d:	89 08                	mov    %ecx,(%eax)
  80047f:	8b 02                	mov    (%edx),%eax
  800481:	8b 52 04             	mov    0x4(%edx),%edx
  800484:	eb 22                	jmp    8004a8 <getuint+0x38>
	else if (lflag)
  800486:	85 d2                	test   %edx,%edx
  800488:	74 10                	je     80049a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048f:	89 08                	mov    %ecx,(%eax)
  800491:	8b 02                	mov    (%edx),%eax
  800493:	ba 00 00 00 00       	mov    $0x0,%edx
  800498:	eb 0e                	jmp    8004a8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80049a:	8b 10                	mov    (%eax),%edx
  80049c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049f:	89 08                	mov    %ecx,(%eax)
  8004a1:	8b 02                	mov    (%edx),%eax
  8004a3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a8:	5d                   	pop    %ebp
  8004a9:	c3                   	ret    

008004aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b4:	8b 10                	mov    (%eax),%edx
  8004b6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b9:	73 0a                	jae    8004c5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004be:	89 08                	mov    %ecx,(%eax)
  8004c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c3:	88 02                	mov    %al,(%edx)
}
  8004c5:	5d                   	pop    %ebp
  8004c6:	c3                   	ret    

008004c7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c7:	55                   	push   %ebp
  8004c8:	89 e5                	mov    %esp,%ebp
  8004ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004cd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	89 04 24             	mov    %eax,(%esp)
  8004e8:	e8 02 00 00 00       	call   8004ef <vprintfmt>
	va_end(ap);
}
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    

008004ef <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	57                   	push   %edi
  8004f3:	56                   	push   %esi
  8004f4:	53                   	push   %ebx
  8004f5:	83 ec 3c             	sub    $0x3c,%esp
  8004f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004fe:	eb 14                	jmp    800514 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800500:	85 c0                	test   %eax,%eax
  800502:	0f 84 b3 03 00 00    	je     8008bb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800508:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800512:	89 f3                	mov    %esi,%ebx
  800514:	8d 73 01             	lea    0x1(%ebx),%esi
  800517:	0f b6 03             	movzbl (%ebx),%eax
  80051a:	83 f8 25             	cmp    $0x25,%eax
  80051d:	75 e1                	jne    800500 <vprintfmt+0x11>
  80051f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800523:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80052a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800531:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800538:	ba 00 00 00 00       	mov    $0x0,%edx
  80053d:	eb 1d                	jmp    80055c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800541:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800545:	eb 15                	jmp    80055c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800549:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80054d:	eb 0d                	jmp    80055c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80054f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800552:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800555:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80055f:	0f b6 0e             	movzbl (%esi),%ecx
  800562:	0f b6 c1             	movzbl %cl,%eax
  800565:	83 e9 23             	sub    $0x23,%ecx
  800568:	80 f9 55             	cmp    $0x55,%cl
  80056b:	0f 87 2a 03 00 00    	ja     80089b <vprintfmt+0x3ac>
  800571:	0f b6 c9             	movzbl %cl,%ecx
  800574:	ff 24 8d 20 18 80 00 	jmp    *0x801820(,%ecx,4)
  80057b:	89 de                	mov    %ebx,%esi
  80057d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800582:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800585:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800589:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80058c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80058f:	83 fb 09             	cmp    $0x9,%ebx
  800592:	77 36                	ja     8005ca <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800594:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800597:	eb e9                	jmp    800582 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 48 04             	lea    0x4(%eax),%ecx
  80059f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a9:	eb 22                	jmp    8005cd <vprintfmt+0xde>
  8005ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ae:	85 c9                	test   %ecx,%ecx
  8005b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b5:	0f 49 c1             	cmovns %ecx,%eax
  8005b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	89 de                	mov    %ebx,%esi
  8005bd:	eb 9d                	jmp    80055c <vprintfmt+0x6d>
  8005bf:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005c8:	eb 92                	jmp    80055c <vprintfmt+0x6d>
  8005ca:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8005cd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d1:	79 89                	jns    80055c <vprintfmt+0x6d>
  8005d3:	e9 77 ff ff ff       	jmp    80054f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005dd:	e9 7a ff ff ff       	jmp    80055c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 04 24             	mov    %eax,(%esp)
  8005f4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005f7:	e9 18 ff ff ff       	jmp    800514 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	8b 00                	mov    (%eax),%eax
  800607:	99                   	cltd   
  800608:	31 d0                	xor    %edx,%eax
  80060a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060c:	83 f8 09             	cmp    $0x9,%eax
  80060f:	7f 0b                	jg     80061c <vprintfmt+0x12d>
  800611:	8b 14 85 e0 1a 80 00 	mov    0x801ae0(,%eax,4),%edx
  800618:	85 d2                	test   %edx,%edx
  80061a:	75 20                	jne    80063c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80061c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800620:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800627:	00 
  800628:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	e8 90 fe ff ff       	call   8004c7 <printfmt>
  800637:	e9 d8 fe ff ff       	jmp    800514 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80063c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800640:	c7 44 24 08 6d 17 80 	movl   $0x80176d,0x8(%esp)
  800647:	00 
  800648:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064c:	8b 45 08             	mov    0x8(%ebp),%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 70 fe ff ff       	call   8004c7 <printfmt>
  800657:	e9 b8 fe ff ff       	jmp    800514 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80065f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800662:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800670:	85 f6                	test   %esi,%esi
  800672:	b8 5d 17 80 00       	mov    $0x80175d,%eax
  800677:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80067a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80067e:	0f 84 97 00 00 00    	je     80071b <vprintfmt+0x22c>
  800684:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800688:	0f 8e 9b 00 00 00    	jle    800729 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800692:	89 34 24             	mov    %esi,(%esp)
  800695:	e8 ce 06 00 00       	call   800d68 <strnlen>
  80069a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80069d:	29 c2                	sub    %eax,%edx
  80069f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8006a2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006a6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006a9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8006af:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006b2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b4:	eb 0f                	jmp    8006c5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006bd:	89 04 24             	mov    %eax,(%esp)
  8006c0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c2:	83 eb 01             	sub    $0x1,%ebx
  8006c5:	85 db                	test   %ebx,%ebx
  8006c7:	7f ed                	jg     8006b6 <vprintfmt+0x1c7>
  8006c9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006cc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006cf:	85 d2                	test   %edx,%edx
  8006d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d6:	0f 49 c2             	cmovns %edx,%eax
  8006d9:	29 c2                	sub    %eax,%edx
  8006db:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006de:	89 d7                	mov    %edx,%edi
  8006e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006e3:	eb 50                	jmp    800735 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e9:	74 1e                	je     800709 <vprintfmt+0x21a>
  8006eb:	0f be d2             	movsbl %dl,%edx
  8006ee:	83 ea 20             	sub    $0x20,%edx
  8006f1:	83 fa 5e             	cmp    $0x5e,%edx
  8006f4:	76 13                	jbe    800709 <vprintfmt+0x21a>
					putch('?', putdat);
  8006f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800704:	ff 55 08             	call   *0x8(%ebp)
  800707:	eb 0d                	jmp    800716 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800709:	8b 55 0c             	mov    0xc(%ebp),%edx
  80070c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800716:	83 ef 01             	sub    $0x1,%edi
  800719:	eb 1a                	jmp    800735 <vprintfmt+0x246>
  80071b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80071e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800721:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800724:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800727:	eb 0c                	jmp    800735 <vprintfmt+0x246>
  800729:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80072c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80072f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800732:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800735:	83 c6 01             	add    $0x1,%esi
  800738:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80073c:	0f be c2             	movsbl %dl,%eax
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 27                	je     80076a <vprintfmt+0x27b>
  800743:	85 db                	test   %ebx,%ebx
  800745:	78 9e                	js     8006e5 <vprintfmt+0x1f6>
  800747:	83 eb 01             	sub    $0x1,%ebx
  80074a:	79 99                	jns    8006e5 <vprintfmt+0x1f6>
  80074c:	89 f8                	mov    %edi,%eax
  80074e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800751:	8b 75 08             	mov    0x8(%ebp),%esi
  800754:	89 c3                	mov    %eax,%ebx
  800756:	eb 1a                	jmp    800772 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800758:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800763:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800765:	83 eb 01             	sub    $0x1,%ebx
  800768:	eb 08                	jmp    800772 <vprintfmt+0x283>
  80076a:	89 fb                	mov    %edi,%ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800772:	85 db                	test   %ebx,%ebx
  800774:	7f e2                	jg     800758 <vprintfmt+0x269>
  800776:	89 75 08             	mov    %esi,0x8(%ebp)
  800779:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80077c:	e9 93 fd ff ff       	jmp    800514 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800781:	83 fa 01             	cmp    $0x1,%edx
  800784:	7e 16                	jle    80079c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 50 08             	lea    0x8(%eax),%edx
  80078c:	89 55 14             	mov    %edx,0x14(%ebp)
  80078f:	8b 50 04             	mov    0x4(%eax),%edx
  800792:	8b 00                	mov    (%eax),%eax
  800794:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800797:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80079a:	eb 32                	jmp    8007ce <vprintfmt+0x2df>
	else if (lflag)
  80079c:	85 d2                	test   %edx,%edx
  80079e:	74 18                	je     8007b8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8d 50 04             	lea    0x4(%eax),%edx
  8007a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a9:	8b 30                	mov    (%eax),%esi
  8007ab:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	c1 f8 1f             	sar    $0x1f,%eax
  8007b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007b6:	eb 16                	jmp    8007ce <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8d 50 04             	lea    0x4(%eax),%edx
  8007be:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c1:	8b 30                	mov    (%eax),%esi
  8007c3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007c6:	89 f0                	mov    %esi,%eax
  8007c8:	c1 f8 1f             	sar    $0x1f,%eax
  8007cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007dd:	0f 89 80 00 00 00    	jns    800863 <vprintfmt+0x374>
				putch('-', putdat);
  8007e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007f7:	f7 d8                	neg    %eax
  8007f9:	83 d2 00             	adc    $0x0,%edx
  8007fc:	f7 da                	neg    %edx
			}
			base = 10;
  8007fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800803:	eb 5e                	jmp    800863 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
  800808:	e8 63 fc ff ff       	call   800470 <getuint>
			base = 10;
  80080d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800812:	eb 4f                	jmp    800863 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800814:	8d 45 14             	lea    0x14(%ebp),%eax
  800817:	e8 54 fc ff ff       	call   800470 <getuint>
			base = 8 ;
  80081c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800821:	eb 40                	jmp    800863 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800823:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800827:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80082e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800831:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800835:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80083c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80083f:	8b 45 14             	mov    0x14(%ebp),%eax
  800842:	8d 50 04             	lea    0x4(%eax),%edx
  800845:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800848:	8b 00                	mov    (%eax),%eax
  80084a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80084f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800854:	eb 0d                	jmp    800863 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
  800859:	e8 12 fc ff ff       	call   800470 <getuint>
			base = 16;
  80085e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800863:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800867:	89 74 24 10          	mov    %esi,0x10(%esp)
  80086b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80086e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800872:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	89 54 24 04          	mov    %edx,0x4(%esp)
  80087d:	89 fa                	mov    %edi,%edx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	e8 f9 f9 ff ff       	call   800280 <printnum>
			break;
  800887:	e9 88 fc ff ff       	jmp    800514 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80088c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800890:	89 04 24             	mov    %eax,(%esp)
  800893:	ff 55 08             	call   *0x8(%ebp)
			break;
  800896:	e9 79 fc ff ff       	jmp    800514 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008a6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a9:	89 f3                	mov    %esi,%ebx
  8008ab:	eb 03                	jmp    8008b0 <vprintfmt+0x3c1>
  8008ad:	83 eb 01             	sub    $0x1,%ebx
  8008b0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008b4:	75 f7                	jne    8008ad <vprintfmt+0x3be>
  8008b6:	e9 59 fc ff ff       	jmp    800514 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008bb:	83 c4 3c             	add    $0x3c,%esp
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5f                   	pop    %edi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	57                   	push   %edi
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	83 ec 3c             	sub    $0x3c,%esp
  8008cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  8008cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d2:	8d 50 04             	lea    0x4(%eax),%edx
  8008d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d8:	8b 00                	mov    (%eax),%eax
  8008da:	c1 e0 08             	shl    $0x8,%eax
  8008dd:	0f b7 c0             	movzwl %ax,%eax
  8008e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  8008e3:	83 c8 25             	or     $0x25,%eax
  8008e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8008e9:	eb 1a                	jmp    800905 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	0f 84 a9 03 00 00    	je     800c9c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  8008f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008fa:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8008fd:	89 04 24             	mov    %eax,(%esp)
  800900:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800903:	89 fb                	mov    %edi,%ebx
  800905:	8d 7b 01             	lea    0x1(%ebx),%edi
  800908:	0f b6 03             	movzbl (%ebx),%eax
  80090b:	83 f8 25             	cmp    $0x25,%eax
  80090e:	75 db                	jne    8008eb <cvprintfmt+0x28>
  800910:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800914:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80091b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800920:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800927:	ba 00 00 00 00       	mov    $0x0,%edx
  80092c:	eb 18                	jmp    800946 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800930:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800934:	eb 10                	jmp    800946 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800936:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800938:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80093c:	eb 08                	jmp    800946 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80093e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800941:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800946:	8d 5f 01             	lea    0x1(%edi),%ebx
  800949:	0f b6 0f             	movzbl (%edi),%ecx
  80094c:	0f b6 c1             	movzbl %cl,%eax
  80094f:	83 e9 23             	sub    $0x23,%ecx
  800952:	80 f9 55             	cmp    $0x55,%cl
  800955:	0f 87 1f 03 00 00    	ja     800c7a <cvprintfmt+0x3b7>
  80095b:	0f b6 c9             	movzbl %cl,%ecx
  80095e:	ff 24 8d 78 19 80 00 	jmp    *0x801978(,%ecx,4)
  800965:	89 df                	mov    %ebx,%edi
  800967:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80096c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80096f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800973:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800976:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800979:	83 f9 09             	cmp    $0x9,%ecx
  80097c:	77 33                	ja     8009b1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80097e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800981:	eb e9                	jmp    80096c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800983:	8b 45 14             	mov    0x14(%ebp),%eax
  800986:	8d 48 04             	lea    0x4(%eax),%ecx
  800989:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80098c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800990:	eb 1f                	jmp    8009b1 <cvprintfmt+0xee>
  800992:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800995:	85 ff                	test   %edi,%edi
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
  80099c:	0f 49 c7             	cmovns %edi,%eax
  80099f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a2:	89 df                	mov    %ebx,%edi
  8009a4:	eb a0                	jmp    800946 <cvprintfmt+0x83>
  8009a6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8009a8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8009af:	eb 95                	jmp    800946 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  8009b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009b5:	79 8f                	jns    800946 <cvprintfmt+0x83>
  8009b7:	eb 85                	jmp    80093e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009bc:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009be:	66 90                	xchg   %ax,%ax
  8009c0:	eb 84                	jmp    800946 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	8d 50 04             	lea    0x4(%eax),%edx
  8009c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009d5:	0b 10                	or     (%eax),%edx
  8009d7:	89 14 24             	mov    %edx,(%esp)
  8009da:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009dd:	e9 23 ff ff ff       	jmp    800905 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e5:	8d 50 04             	lea    0x4(%eax),%edx
  8009e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009eb:	8b 00                	mov    (%eax),%eax
  8009ed:	99                   	cltd   
  8009ee:	31 d0                	xor    %edx,%eax
  8009f0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009f2:	83 f8 09             	cmp    $0x9,%eax
  8009f5:	7f 0b                	jg     800a02 <cvprintfmt+0x13f>
  8009f7:	8b 14 85 e0 1a 80 00 	mov    0x801ae0(,%eax,4),%edx
  8009fe:	85 d2                	test   %edx,%edx
  800a00:	75 23                	jne    800a25 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800a02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a06:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800a0d:	00 
  800a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	89 04 24             	mov    %eax,(%esp)
  800a1b:	e8 a7 fa ff ff       	call   8004c7 <printfmt>
  800a20:	e9 e0 fe ff ff       	jmp    800905 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800a25:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a29:	c7 44 24 08 6d 17 80 	movl   $0x80176d,0x8(%esp)
  800a30:	00 
  800a31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	89 04 24             	mov    %eax,(%esp)
  800a3e:	e8 84 fa ff ff       	call   8004c7 <printfmt>
  800a43:	e9 bd fe ff ff       	jmp    800905 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a48:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a4b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800a4e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a51:	8d 48 04             	lea    0x4(%eax),%ecx
  800a54:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a57:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a59:	85 ff                	test   %edi,%edi
  800a5b:	b8 5d 17 80 00       	mov    $0x80175d,%eax
  800a60:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a63:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a67:	74 61                	je     800aca <cvprintfmt+0x207>
  800a69:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a6d:	7e 5b                	jle    800aca <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a73:	89 3c 24             	mov    %edi,(%esp)
  800a76:	e8 ed 02 00 00       	call   800d68 <strnlen>
  800a7b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a7e:	29 c2                	sub    %eax,%edx
  800a80:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800a83:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a87:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a8a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a8d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800a90:	8b 75 08             	mov    0x8(%ebp),%esi
  800a93:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a96:	89 d3                	mov    %edx,%ebx
  800a98:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a9a:	eb 0f                	jmp    800aab <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa3:	89 3c 24             	mov    %edi,(%esp)
  800aa6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800aa8:	83 eb 01             	sub    $0x1,%ebx
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	7f ed                	jg     800a9c <cvprintfmt+0x1d9>
  800aaf:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800ab2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ab8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800abb:	85 d2                	test   %edx,%edx
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac2:	0f 49 c2             	cmovns %edx,%eax
  800ac5:	29 c2                	sub    %eax,%edx
  800ac7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800aca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800acd:	83 c8 3f             	or     $0x3f,%eax
  800ad0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ad3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ad9:	eb 36                	jmp    800b11 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800adb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800adf:	74 1d                	je     800afe <cvprintfmt+0x23b>
  800ae1:	0f be d2             	movsbl %dl,%edx
  800ae4:	83 ea 20             	sub    $0x20,%edx
  800ae7:	83 fa 5e             	cmp    $0x5e,%edx
  800aea:	76 12                	jbe    800afe <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aef:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800af6:	89 04 24             	mov    %eax,(%esp)
  800af9:	ff 55 08             	call   *0x8(%ebp)
  800afc:	eb 10                	jmp    800b0e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800afe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b01:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b05:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b08:	89 04 24             	mov    %eax,(%esp)
  800b0b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b0e:	83 eb 01             	sub    $0x1,%ebx
  800b11:	83 c7 01             	add    $0x1,%edi
  800b14:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800b18:	0f be c2             	movsbl %dl,%eax
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	74 27                	je     800b46 <cvprintfmt+0x283>
  800b1f:	85 f6                	test   %esi,%esi
  800b21:	78 b8                	js     800adb <cvprintfmt+0x218>
  800b23:	83 ee 01             	sub    $0x1,%esi
  800b26:	79 b3                	jns    800adb <cvprintfmt+0x218>
  800b28:	89 d8                	mov    %ebx,%eax
  800b2a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b2d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	eb 18                	jmp    800b4c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800b34:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b3f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800b41:	83 eb 01             	sub    $0x1,%ebx
  800b44:	eb 06                	jmp    800b4c <cvprintfmt+0x289>
  800b46:	8b 75 08             	mov    0x8(%ebp),%esi
  800b49:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b4c:	85 db                	test   %ebx,%ebx
  800b4e:	7f e4                	jg     800b34 <cvprintfmt+0x271>
  800b50:	89 75 08             	mov    %esi,0x8(%ebp)
  800b53:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b59:	e9 a7 fd ff ff       	jmp    800905 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b5e:	83 fa 01             	cmp    $0x1,%edx
  800b61:	7e 10                	jle    800b73 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800b63:	8b 45 14             	mov    0x14(%ebp),%eax
  800b66:	8d 50 08             	lea    0x8(%eax),%edx
  800b69:	89 55 14             	mov    %edx,0x14(%ebp)
  800b6c:	8b 30                	mov    (%eax),%esi
  800b6e:	8b 78 04             	mov    0x4(%eax),%edi
  800b71:	eb 26                	jmp    800b99 <cvprintfmt+0x2d6>
	else if (lflag)
  800b73:	85 d2                	test   %edx,%edx
  800b75:	74 12                	je     800b89 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800b77:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7a:	8d 50 04             	lea    0x4(%eax),%edx
  800b7d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b80:	8b 30                	mov    (%eax),%esi
  800b82:	89 f7                	mov    %esi,%edi
  800b84:	c1 ff 1f             	sar    $0x1f,%edi
  800b87:	eb 10                	jmp    800b99 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800b89:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8c:	8d 50 04             	lea    0x4(%eax),%edx
  800b8f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b92:	8b 30                	mov    (%eax),%esi
  800b94:	89 f7                	mov    %esi,%edi
  800b96:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b99:	89 f0                	mov    %esi,%eax
  800b9b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b9d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ba2:	85 ff                	test   %edi,%edi
  800ba4:	0f 89 8e 00 00 00    	jns    800c38 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bb4:	83 c8 2d             	or     $0x2d,%eax
  800bb7:	89 04 24             	mov    %eax,(%esp)
  800bba:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800bbd:	89 f0                	mov    %esi,%eax
  800bbf:	89 fa                	mov    %edi,%edx
  800bc1:	f7 d8                	neg    %eax
  800bc3:	83 d2 00             	adc    $0x0,%edx
  800bc6:	f7 da                	neg    %edx
			}
			base = 10;
  800bc8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bcd:	eb 69                	jmp    800c38 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bcf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd2:	e8 99 f8 ff ff       	call   800470 <getuint>
			base = 10;
  800bd7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bdc:	eb 5a                	jmp    800c38 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800bde:	8d 45 14             	lea    0x14(%ebp),%eax
  800be1:	e8 8a f8 ff ff       	call   800470 <getuint>
			base = 8 ;
  800be6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800beb:	eb 4b                	jmp    800c38 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800bf7:	89 f0                	mov    %esi,%eax
  800bf9:	83 c8 30             	or     $0x30,%eax
  800bfc:	89 04 24             	mov    %eax,(%esp)
  800bff:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c09:	89 f0                	mov    %esi,%eax
  800c0b:	83 c8 78             	or     $0x78,%eax
  800c0e:	89 04 24             	mov    %eax,(%esp)
  800c11:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c14:	8b 45 14             	mov    0x14(%ebp),%eax
  800c17:	8d 50 04             	lea    0x4(%eax),%edx
  800c1a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800c1d:	8b 00                	mov    (%eax),%eax
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c24:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c29:	eb 0d                	jmp    800c38 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c2b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c2e:	e8 3d f8 ff ff       	call   800470 <getuint>
			base = 16;
  800c33:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800c38:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800c3c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c40:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800c43:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c47:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c4b:	89 04 24             	mov    %eax,(%esp)
  800c4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c5b:	e8 0f f7 ff ff       	call   80036f <cprintnum>
			break;
  800c60:	e9 a0 fc ff ff       	jmp    800905 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800c65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c68:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c6c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800c6f:	89 04 24             	mov    %eax,(%esp)
  800c72:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c75:	e9 8b fc ff ff       	jmp    800905 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c84:	89 04 24             	mov    %eax,(%esp)
  800c87:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c8a:	89 fb                	mov    %edi,%ebx
  800c8c:	eb 03                	jmp    800c91 <cvprintfmt+0x3ce>
  800c8e:	83 eb 01             	sub    $0x1,%ebx
  800c91:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c95:	75 f7                	jne    800c8e <cvprintfmt+0x3cb>
  800c97:	e9 69 fc ff ff       	jmp    800905 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800c9c:	83 c4 3c             	add    $0x3c,%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800caa:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	89 04 24             	mov    %eax,(%esp)
  800cc5:	e8 f9 fb ff ff       	call   8008c3 <cvprintfmt>
	va_end(ap);
}
  800cca:	c9                   	leave  
  800ccb:	c3                   	ret    

00800ccc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 28             	sub    $0x28,%esp
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cdb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cdf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ce2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	74 30                	je     800d1d <vsnprintf+0x51>
  800ced:	85 d2                	test   %edx,%edx
  800cef:	7e 2c                	jle    800d1d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cf1:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d06:	c7 04 24 aa 04 80 00 	movl   $0x8004aa,(%esp)
  800d0d:	e8 dd f7 ff ff       	call   8004ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d15:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d1b:	eb 05                	jmp    800d22 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d22:	c9                   	leave  
  800d23:	c3                   	ret    

00800d24 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d2a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d31:	8b 45 10             	mov    0x10(%ebp),%eax
  800d34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	89 04 24             	mov    %eax,(%esp)
  800d45:	e8 82 ff ff ff       	call   800ccc <vsnprintf>
	va_end(ap);

	return rc;
}
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5b:	eb 03                	jmp    800d60 <strlen+0x10>
		n++;
  800d5d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d64:	75 f7                	jne    800d5d <strlen+0xd>
		n++;
	return n;
}
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
  800d76:	eb 03                	jmp    800d7b <strnlen+0x13>
		n++;
  800d78:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d7b:	39 d0                	cmp    %edx,%eax
  800d7d:	74 06                	je     800d85 <strnlen+0x1d>
  800d7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d83:	75 f3                	jne    800d78 <strnlen+0x10>
		n++;
	return n;
}
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	53                   	push   %ebx
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	83 c2 01             	add    $0x1,%edx
  800d96:	83 c1 01             	add    $0x1,%ecx
  800d99:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d9d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800da0:	84 db                	test   %bl,%bl
  800da2:	75 ef                	jne    800d93 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800da4:	5b                   	pop    %ebx
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	53                   	push   %ebx
  800dab:	83 ec 08             	sub    $0x8,%esp
  800dae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800db1:	89 1c 24             	mov    %ebx,(%esp)
  800db4:	e8 97 ff ff ff       	call   800d50 <strlen>
	strcpy(dst + len, src);
  800db9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dc0:	01 d8                	add    %ebx,%eax
  800dc2:	89 04 24             	mov    %eax,(%esp)
  800dc5:	e8 bd ff ff ff       	call   800d87 <strcpy>
	return dst;
}
  800dca:	89 d8                	mov    %ebx,%eax
  800dcc:	83 c4 08             	add    $0x8,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	8b 75 08             	mov    0x8(%ebp),%esi
  800dda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddd:	89 f3                	mov    %esi,%ebx
  800ddf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800de2:	89 f2                	mov    %esi,%edx
  800de4:	eb 0f                	jmp    800df5 <strncpy+0x23>
		*dst++ = *src;
  800de6:	83 c2 01             	add    $0x1,%edx
  800de9:	0f b6 01             	movzbl (%ecx),%eax
  800dec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800def:	80 39 01             	cmpb   $0x1,(%ecx)
  800df2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800df5:	39 da                	cmp    %ebx,%edx
  800df7:	75 ed                	jne    800de6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	8b 75 08             	mov    0x8(%ebp),%esi
  800e07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e13:	85 c9                	test   %ecx,%ecx
  800e15:	75 0b                	jne    800e22 <strlcpy+0x23>
  800e17:	eb 1d                	jmp    800e36 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e19:	83 c0 01             	add    $0x1,%eax
  800e1c:	83 c2 01             	add    $0x1,%edx
  800e1f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e22:	39 d8                	cmp    %ebx,%eax
  800e24:	74 0b                	je     800e31 <strlcpy+0x32>
  800e26:	0f b6 0a             	movzbl (%edx),%ecx
  800e29:	84 c9                	test   %cl,%cl
  800e2b:	75 ec                	jne    800e19 <strlcpy+0x1a>
  800e2d:	89 c2                	mov    %eax,%edx
  800e2f:	eb 02                	jmp    800e33 <strlcpy+0x34>
  800e31:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800e33:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800e36:	29 f0                	sub    %esi,%eax
}
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e45:	eb 06                	jmp    800e4d <strcmp+0x11>
		p++, q++;
  800e47:	83 c1 01             	add    $0x1,%ecx
  800e4a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e4d:	0f b6 01             	movzbl (%ecx),%eax
  800e50:	84 c0                	test   %al,%al
  800e52:	74 04                	je     800e58 <strcmp+0x1c>
  800e54:	3a 02                	cmp    (%edx),%al
  800e56:	74 ef                	je     800e47 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e58:	0f b6 c0             	movzbl %al,%eax
  800e5b:	0f b6 12             	movzbl (%edx),%edx
  800e5e:	29 d0                	sub    %edx,%eax
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	53                   	push   %ebx
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
  800e69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6c:	89 c3                	mov    %eax,%ebx
  800e6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e71:	eb 06                	jmp    800e79 <strncmp+0x17>
		n--, p++, q++;
  800e73:	83 c0 01             	add    $0x1,%eax
  800e76:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e79:	39 d8                	cmp    %ebx,%eax
  800e7b:	74 15                	je     800e92 <strncmp+0x30>
  800e7d:	0f b6 08             	movzbl (%eax),%ecx
  800e80:	84 c9                	test   %cl,%cl
  800e82:	74 04                	je     800e88 <strncmp+0x26>
  800e84:	3a 0a                	cmp    (%edx),%cl
  800e86:	74 eb                	je     800e73 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e88:	0f b6 00             	movzbl (%eax),%eax
  800e8b:	0f b6 12             	movzbl (%edx),%edx
  800e8e:	29 d0                	sub    %edx,%eax
  800e90:	eb 05                	jmp    800e97 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e97:	5b                   	pop    %ebx
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ea4:	eb 07                	jmp    800ead <strchr+0x13>
		if (*s == c)
  800ea6:	38 ca                	cmp    %cl,%dl
  800ea8:	74 0f                	je     800eb9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800eaa:	83 c0 01             	add    $0x1,%eax
  800ead:	0f b6 10             	movzbl (%eax),%edx
  800eb0:	84 d2                	test   %dl,%dl
  800eb2:	75 f2                	jne    800ea6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ec5:	eb 07                	jmp    800ece <strfind+0x13>
		if (*s == c)
  800ec7:	38 ca                	cmp    %cl,%dl
  800ec9:	74 0a                	je     800ed5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ecb:	83 c0 01             	add    $0x1,%eax
  800ece:	0f b6 10             	movzbl (%eax),%edx
  800ed1:	84 d2                	test   %dl,%dl
  800ed3:	75 f2                	jne    800ec7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ee0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ee3:	85 c9                	test   %ecx,%ecx
  800ee5:	74 36                	je     800f1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ee7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eed:	75 28                	jne    800f17 <memset+0x40>
  800eef:	f6 c1 03             	test   $0x3,%cl
  800ef2:	75 23                	jne    800f17 <memset+0x40>
		c &= 0xFF;
  800ef4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ef8:	89 d3                	mov    %edx,%ebx
  800efa:	c1 e3 08             	shl    $0x8,%ebx
  800efd:	89 d6                	mov    %edx,%esi
  800eff:	c1 e6 18             	shl    $0x18,%esi
  800f02:	89 d0                	mov    %edx,%eax
  800f04:	c1 e0 10             	shl    $0x10,%eax
  800f07:	09 f0                	or     %esi,%eax
  800f09:	09 c2                	or     %eax,%edx
  800f0b:	89 d0                	mov    %edx,%eax
  800f0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f0f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f12:	fc                   	cld    
  800f13:	f3 ab                	rep stos %eax,%es:(%edi)
  800f15:	eb 06                	jmp    800f1d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1a:	fc                   	cld    
  800f1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f1d:	89 f8                	mov    %edi,%eax
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    

00800f24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	57                   	push   %edi
  800f28:	56                   	push   %esi
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f32:	39 c6                	cmp    %eax,%esi
  800f34:	73 35                	jae    800f6b <memmove+0x47>
  800f36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f39:	39 d0                	cmp    %edx,%eax
  800f3b:	73 2e                	jae    800f6b <memmove+0x47>
		s += n;
		d += n;
  800f3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800f40:	89 d6                	mov    %edx,%esi
  800f42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f4a:	75 13                	jne    800f5f <memmove+0x3b>
  800f4c:	f6 c1 03             	test   $0x3,%cl
  800f4f:	75 0e                	jne    800f5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f51:	83 ef 04             	sub    $0x4,%edi
  800f54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f5a:	fd                   	std    
  800f5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f5d:	eb 09                	jmp    800f68 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f5f:	83 ef 01             	sub    $0x1,%edi
  800f62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f65:	fd                   	std    
  800f66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f68:	fc                   	cld    
  800f69:	eb 1d                	jmp    800f88 <memmove+0x64>
  800f6b:	89 f2                	mov    %esi,%edx
  800f6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f6f:	f6 c2 03             	test   $0x3,%dl
  800f72:	75 0f                	jne    800f83 <memmove+0x5f>
  800f74:	f6 c1 03             	test   $0x3,%cl
  800f77:	75 0a                	jne    800f83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f79:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f7c:	89 c7                	mov    %eax,%edi
  800f7e:	fc                   	cld    
  800f7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f81:	eb 05                	jmp    800f88 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f83:	89 c7                	mov    %eax,%edi
  800f85:	fc                   	cld    
  800f86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f92:	8b 45 10             	mov    0x10(%ebp),%eax
  800f95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa3:	89 04 24             	mov    %eax,(%esp)
  800fa6:	e8 79 ff ff ff       	call   800f24 <memmove>
}
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
  800fb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb8:	89 d6                	mov    %edx,%esi
  800fba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fbd:	eb 1a                	jmp    800fd9 <memcmp+0x2c>
		if (*s1 != *s2)
  800fbf:	0f b6 02             	movzbl (%edx),%eax
  800fc2:	0f b6 19             	movzbl (%ecx),%ebx
  800fc5:	38 d8                	cmp    %bl,%al
  800fc7:	74 0a                	je     800fd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800fc9:	0f b6 c0             	movzbl %al,%eax
  800fcc:	0f b6 db             	movzbl %bl,%ebx
  800fcf:	29 d8                	sub    %ebx,%eax
  800fd1:	eb 0f                	jmp    800fe2 <memcmp+0x35>
		s1++, s2++;
  800fd3:	83 c2 01             	add    $0x1,%edx
  800fd6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fd9:	39 f2                	cmp    %esi,%edx
  800fdb:	75 e2                	jne    800fbf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fef:	89 c2                	mov    %eax,%edx
  800ff1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ff4:	eb 07                	jmp    800ffd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ff6:	38 08                	cmp    %cl,(%eax)
  800ff8:	74 07                	je     801001 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ffa:	83 c0 01             	add    $0x1,%eax
  800ffd:	39 d0                	cmp    %edx,%eax
  800fff:	72 f5                	jb     800ff6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	57                   	push   %edi
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	8b 55 08             	mov    0x8(%ebp),%edx
  80100c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80100f:	eb 03                	jmp    801014 <strtol+0x11>
		s++;
  801011:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801014:	0f b6 0a             	movzbl (%edx),%ecx
  801017:	80 f9 09             	cmp    $0x9,%cl
  80101a:	74 f5                	je     801011 <strtol+0xe>
  80101c:	80 f9 20             	cmp    $0x20,%cl
  80101f:	74 f0                	je     801011 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801021:	80 f9 2b             	cmp    $0x2b,%cl
  801024:	75 0a                	jne    801030 <strtol+0x2d>
		s++;
  801026:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801029:	bf 00 00 00 00       	mov    $0x0,%edi
  80102e:	eb 11                	jmp    801041 <strtol+0x3e>
  801030:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801035:	80 f9 2d             	cmp    $0x2d,%cl
  801038:	75 07                	jne    801041 <strtol+0x3e>
		s++, neg = 1;
  80103a:	8d 52 01             	lea    0x1(%edx),%edx
  80103d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801041:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801046:	75 15                	jne    80105d <strtol+0x5a>
  801048:	80 3a 30             	cmpb   $0x30,(%edx)
  80104b:	75 10                	jne    80105d <strtol+0x5a>
  80104d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801051:	75 0a                	jne    80105d <strtol+0x5a>
		s += 2, base = 16;
  801053:	83 c2 02             	add    $0x2,%edx
  801056:	b8 10 00 00 00       	mov    $0x10,%eax
  80105b:	eb 10                	jmp    80106d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80105d:	85 c0                	test   %eax,%eax
  80105f:	75 0c                	jne    80106d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801061:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801063:	80 3a 30             	cmpb   $0x30,(%edx)
  801066:	75 05                	jne    80106d <strtol+0x6a>
		s++, base = 8;
  801068:	83 c2 01             	add    $0x1,%edx
  80106b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80106d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801072:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801075:	0f b6 0a             	movzbl (%edx),%ecx
  801078:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80107b:	89 f0                	mov    %esi,%eax
  80107d:	3c 09                	cmp    $0x9,%al
  80107f:	77 08                	ja     801089 <strtol+0x86>
			dig = *s - '0';
  801081:	0f be c9             	movsbl %cl,%ecx
  801084:	83 e9 30             	sub    $0x30,%ecx
  801087:	eb 20                	jmp    8010a9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801089:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80108c:	89 f0                	mov    %esi,%eax
  80108e:	3c 19                	cmp    $0x19,%al
  801090:	77 08                	ja     80109a <strtol+0x97>
			dig = *s - 'a' + 10;
  801092:	0f be c9             	movsbl %cl,%ecx
  801095:	83 e9 57             	sub    $0x57,%ecx
  801098:	eb 0f                	jmp    8010a9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80109a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80109d:	89 f0                	mov    %esi,%eax
  80109f:	3c 19                	cmp    $0x19,%al
  8010a1:	77 16                	ja     8010b9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8010a3:	0f be c9             	movsbl %cl,%ecx
  8010a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010a9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8010ac:	7d 0f                	jge    8010bd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8010ae:	83 c2 01             	add    $0x1,%edx
  8010b1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8010b5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8010b7:	eb bc                	jmp    801075 <strtol+0x72>
  8010b9:	89 d8                	mov    %ebx,%eax
  8010bb:	eb 02                	jmp    8010bf <strtol+0xbc>
  8010bd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8010bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010c3:	74 05                	je     8010ca <strtol+0xc7>
		*endptr = (char *) s;
  8010c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010c8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8010ca:	f7 d8                	neg    %eax
  8010cc:	85 ff                	test   %edi,%edi
  8010ce:	0f 44 c3             	cmove  %ebx,%eax
}
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	57                   	push   %edi
  8010da:	56                   	push   %esi
  8010db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e7:	89 c3                	mov    %eax,%ebx
  8010e9:	89 c7                	mov    %eax,%edi
  8010eb:	89 c6                	mov    %eax,%esi
  8010ed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801104:	89 d1                	mov    %edx,%ecx
  801106:	89 d3                	mov    %edx,%ebx
  801108:	89 d7                	mov    %edx,%edi
  80110a:	89 d6                	mov    %edx,%esi
  80110c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    

00801113 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	57                   	push   %edi
  801117:	56                   	push   %esi
  801118:	53                   	push   %ebx
  801119:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801121:	b8 03 00 00 00       	mov    $0x3,%eax
  801126:	8b 55 08             	mov    0x8(%ebp),%edx
  801129:	89 cb                	mov    %ecx,%ebx
  80112b:	89 cf                	mov    %ecx,%edi
  80112d:	89 ce                	mov    %ecx,%esi
  80112f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801131:	85 c0                	test   %eax,%eax
  801133:	7e 28                	jle    80115d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801135:	89 44 24 10          	mov    %eax,0x10(%esp)
  801139:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801140:	00 
  801141:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  801148:	00 
  801149:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801150:	00 
  801151:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  801158:	e8 01 f0 ff ff       	call   80015e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80115d:	83 c4 2c             	add    $0x2c,%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116b:	ba 00 00 00 00       	mov    $0x0,%edx
  801170:	b8 02 00 00 00       	mov    $0x2,%eax
  801175:	89 d1                	mov    %edx,%ecx
  801177:	89 d3                	mov    %edx,%ebx
  801179:	89 d7                	mov    %edx,%edi
  80117b:	89 d6                	mov    %edx,%esi
  80117d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <sys_yield>:

void
sys_yield(void)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	57                   	push   %edi
  801188:	56                   	push   %esi
  801189:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118a:	ba 00 00 00 00       	mov    $0x0,%edx
  80118f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801194:	89 d1                	mov    %edx,%ecx
  801196:	89 d3                	mov    %edx,%ebx
  801198:	89 d7                	mov    %edx,%edi
  80119a:	89 d6                	mov    %edx,%esi
  80119c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ac:	be 00 00 00 00       	mov    $0x0,%esi
  8011b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8011b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011bf:	89 f7                	mov    %esi,%edi
  8011c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	7e 28                	jle    8011ef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011cb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8011d2:	00 
  8011d3:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  8011da:	00 
  8011db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011e2:	00 
  8011e3:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8011ea:	e8 6f ef ff ff       	call   80015e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011ef:	83 c4 2c             	add    $0x2c,%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801200:	b8 05 00 00 00       	mov    $0x5,%eax
  801205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801208:	8b 55 08             	mov    0x8(%ebp),%edx
  80120b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80120e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801211:	8b 75 18             	mov    0x18(%ebp),%esi
  801214:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801216:	85 c0                	test   %eax,%eax
  801218:	7e 28                	jle    801242 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801225:	00 
  801226:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  80122d:	00 
  80122e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801235:	00 
  801236:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  80123d:	e8 1c ef ff ff       	call   80015e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801242:	83 c4 2c             	add    $0x2c,%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	57                   	push   %edi
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
  801250:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801253:	bb 00 00 00 00       	mov    $0x0,%ebx
  801258:	b8 06 00 00 00       	mov    $0x6,%eax
  80125d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801260:	8b 55 08             	mov    0x8(%ebp),%edx
  801263:	89 df                	mov    %ebx,%edi
  801265:	89 de                	mov    %ebx,%esi
  801267:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801269:	85 c0                	test   %eax,%eax
  80126b:	7e 28                	jle    801295 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80126d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801271:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801278:	00 
  801279:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  801280:	00 
  801281:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801288:	00 
  801289:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  801290:	e8 c9 ee ff ff       	call   80015e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801295:	83 c4 2c             	add    $0x2c,%esp
  801298:	5b                   	pop    %ebx
  801299:	5e                   	pop    %esi
  80129a:	5f                   	pop    %edi
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	57                   	push   %edi
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8012b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b6:	89 df                	mov    %ebx,%edi
  8012b8:	89 de                	mov    %ebx,%esi
  8012ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	7e 28                	jle    8012e8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  8012d3:	00 
  8012d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012db:	00 
  8012dc:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8012e3:	e8 76 ee ff ff       	call   80015e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012e8:	83 c4 2c             	add    $0x2c,%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5e                   	pop    %esi
  8012ed:	5f                   	pop    %edi
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	57                   	push   %edi
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801306:	8b 55 08             	mov    0x8(%ebp),%edx
  801309:	89 df                	mov    %ebx,%edi
  80130b:	89 de                	mov    %ebx,%esi
  80130d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80130f:	85 c0                	test   %eax,%eax
  801311:	7e 28                	jle    80133b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801313:	89 44 24 10          	mov    %eax,0x10(%esp)
  801317:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80131e:	00 
  80131f:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  801326:	00 
  801327:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80132e:	00 
  80132f:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  801336:	e8 23 ee ff ff       	call   80015e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80133b:	83 c4 2c             	add    $0x2c,%esp
  80133e:	5b                   	pop    %ebx
  80133f:	5e                   	pop    %esi
  801340:	5f                   	pop    %edi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	57                   	push   %edi
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801349:	be 00 00 00 00       	mov    $0x0,%esi
  80134e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801353:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801356:	8b 55 08             	mov    0x8(%ebp),%edx
  801359:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80135c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80135f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	57                   	push   %edi
  80136a:	56                   	push   %esi
  80136b:	53                   	push   %ebx
  80136c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80136f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801374:	b8 0c 00 00 00       	mov    $0xc,%eax
  801379:	8b 55 08             	mov    0x8(%ebp),%edx
  80137c:	89 cb                	mov    %ecx,%ebx
  80137e:	89 cf                	mov    %ecx,%edi
  801380:	89 ce                	mov    %ecx,%esi
  801382:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801384:	85 c0                	test   %eax,%eax
  801386:	7e 28                	jle    8013b0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801388:	89 44 24 10          	mov    %eax,0x10(%esp)
  80138c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801393:	00 
  801394:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  80139b:	00 
  80139c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013a3:	00 
  8013a4:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8013ab:	e8 ae ed ff ff       	call   80015e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013b0:	83 c4 2c             	add    $0x2c,%esp
  8013b3:	5b                   	pop    %ebx
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    
  8013b8:	66 90                	xchg   %ax,%ax
  8013ba:	66 90                	xchg   %ax,%ax
  8013bc:	66 90                	xchg   %ax,%ax
  8013be:	66 90                	xchg   %ax,%ax

008013c0 <__udivdi3>:
  8013c0:	55                   	push   %ebp
  8013c1:	57                   	push   %edi
  8013c2:	56                   	push   %esi
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013dc:	89 ea                	mov    %ebp,%edx
  8013de:	89 0c 24             	mov    %ecx,(%esp)
  8013e1:	75 2d                	jne    801410 <__udivdi3+0x50>
  8013e3:	39 e9                	cmp    %ebp,%ecx
  8013e5:	77 61                	ja     801448 <__udivdi3+0x88>
  8013e7:	85 c9                	test   %ecx,%ecx
  8013e9:	89 ce                	mov    %ecx,%esi
  8013eb:	75 0b                	jne    8013f8 <__udivdi3+0x38>
  8013ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f2:	31 d2                	xor    %edx,%edx
  8013f4:	f7 f1                	div    %ecx
  8013f6:	89 c6                	mov    %eax,%esi
  8013f8:	31 d2                	xor    %edx,%edx
  8013fa:	89 e8                	mov    %ebp,%eax
  8013fc:	f7 f6                	div    %esi
  8013fe:	89 c5                	mov    %eax,%ebp
  801400:	89 f8                	mov    %edi,%eax
  801402:	f7 f6                	div    %esi
  801404:	89 ea                	mov    %ebp,%edx
  801406:	83 c4 0c             	add    $0xc,%esp
  801409:	5e                   	pop    %esi
  80140a:	5f                   	pop    %edi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    
  80140d:	8d 76 00             	lea    0x0(%esi),%esi
  801410:	39 e8                	cmp    %ebp,%eax
  801412:	77 24                	ja     801438 <__udivdi3+0x78>
  801414:	0f bd e8             	bsr    %eax,%ebp
  801417:	83 f5 1f             	xor    $0x1f,%ebp
  80141a:	75 3c                	jne    801458 <__udivdi3+0x98>
  80141c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801420:	39 34 24             	cmp    %esi,(%esp)
  801423:	0f 86 9f 00 00 00    	jbe    8014c8 <__udivdi3+0x108>
  801429:	39 d0                	cmp    %edx,%eax
  80142b:	0f 82 97 00 00 00    	jb     8014c8 <__udivdi3+0x108>
  801431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801438:	31 d2                	xor    %edx,%edx
  80143a:	31 c0                	xor    %eax,%eax
  80143c:	83 c4 0c             	add    $0xc,%esp
  80143f:	5e                   	pop    %esi
  801440:	5f                   	pop    %edi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    
  801443:	90                   	nop
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	89 f8                	mov    %edi,%eax
  80144a:	f7 f1                	div    %ecx
  80144c:	31 d2                	xor    %edx,%edx
  80144e:	83 c4 0c             	add    $0xc,%esp
  801451:	5e                   	pop    %esi
  801452:	5f                   	pop    %edi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    
  801455:	8d 76 00             	lea    0x0(%esi),%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	8b 3c 24             	mov    (%esp),%edi
  80145d:	d3 e0                	shl    %cl,%eax
  80145f:	89 c6                	mov    %eax,%esi
  801461:	b8 20 00 00 00       	mov    $0x20,%eax
  801466:	29 e8                	sub    %ebp,%eax
  801468:	89 c1                	mov    %eax,%ecx
  80146a:	d3 ef                	shr    %cl,%edi
  80146c:	89 e9                	mov    %ebp,%ecx
  80146e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801472:	8b 3c 24             	mov    (%esp),%edi
  801475:	09 74 24 08          	or     %esi,0x8(%esp)
  801479:	89 d6                	mov    %edx,%esi
  80147b:	d3 e7                	shl    %cl,%edi
  80147d:	89 c1                	mov    %eax,%ecx
  80147f:	89 3c 24             	mov    %edi,(%esp)
  801482:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801486:	d3 ee                	shr    %cl,%esi
  801488:	89 e9                	mov    %ebp,%ecx
  80148a:	d3 e2                	shl    %cl,%edx
  80148c:	89 c1                	mov    %eax,%ecx
  80148e:	d3 ef                	shr    %cl,%edi
  801490:	09 d7                	or     %edx,%edi
  801492:	89 f2                	mov    %esi,%edx
  801494:	89 f8                	mov    %edi,%eax
  801496:	f7 74 24 08          	divl   0x8(%esp)
  80149a:	89 d6                	mov    %edx,%esi
  80149c:	89 c7                	mov    %eax,%edi
  80149e:	f7 24 24             	mull   (%esp)
  8014a1:	39 d6                	cmp    %edx,%esi
  8014a3:	89 14 24             	mov    %edx,(%esp)
  8014a6:	72 30                	jb     8014d8 <__udivdi3+0x118>
  8014a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014ac:	89 e9                	mov    %ebp,%ecx
  8014ae:	d3 e2                	shl    %cl,%edx
  8014b0:	39 c2                	cmp    %eax,%edx
  8014b2:	73 05                	jae    8014b9 <__udivdi3+0xf9>
  8014b4:	3b 34 24             	cmp    (%esp),%esi
  8014b7:	74 1f                	je     8014d8 <__udivdi3+0x118>
  8014b9:	89 f8                	mov    %edi,%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	e9 7a ff ff ff       	jmp    80143c <__udivdi3+0x7c>
  8014c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014c8:	31 d2                	xor    %edx,%edx
  8014ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cf:	e9 68 ff ff ff       	jmp    80143c <__udivdi3+0x7c>
  8014d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014db:	31 d2                	xor    %edx,%edx
  8014dd:	83 c4 0c             	add    $0xc,%esp
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    
  8014e4:	66 90                	xchg   %ax,%ax
  8014e6:	66 90                	xchg   %ax,%ax
  8014e8:	66 90                	xchg   %ax,%ax
  8014ea:	66 90                	xchg   %ax,%ax
  8014ec:	66 90                	xchg   %ax,%ax
  8014ee:	66 90                	xchg   %ax,%ax

008014f0 <__umoddi3>:
  8014f0:	55                   	push   %ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	83 ec 14             	sub    $0x14,%esp
  8014f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801502:	89 c7                	mov    %eax,%edi
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	8b 44 24 30          	mov    0x30(%esp),%eax
  80150c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801510:	89 34 24             	mov    %esi,(%esp)
  801513:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801517:	85 c0                	test   %eax,%eax
  801519:	89 c2                	mov    %eax,%edx
  80151b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80151f:	75 17                	jne    801538 <__umoddi3+0x48>
  801521:	39 fe                	cmp    %edi,%esi
  801523:	76 4b                	jbe    801570 <__umoddi3+0x80>
  801525:	89 c8                	mov    %ecx,%eax
  801527:	89 fa                	mov    %edi,%edx
  801529:	f7 f6                	div    %esi
  80152b:	89 d0                	mov    %edx,%eax
  80152d:	31 d2                	xor    %edx,%edx
  80152f:	83 c4 14             	add    $0x14,%esp
  801532:	5e                   	pop    %esi
  801533:	5f                   	pop    %edi
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    
  801536:	66 90                	xchg   %ax,%ax
  801538:	39 f8                	cmp    %edi,%eax
  80153a:	77 54                	ja     801590 <__umoddi3+0xa0>
  80153c:	0f bd e8             	bsr    %eax,%ebp
  80153f:	83 f5 1f             	xor    $0x1f,%ebp
  801542:	75 5c                	jne    8015a0 <__umoddi3+0xb0>
  801544:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801548:	39 3c 24             	cmp    %edi,(%esp)
  80154b:	0f 87 e7 00 00 00    	ja     801638 <__umoddi3+0x148>
  801551:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801555:	29 f1                	sub    %esi,%ecx
  801557:	19 c7                	sbb    %eax,%edi
  801559:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80155d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801561:	8b 44 24 08          	mov    0x8(%esp),%eax
  801565:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801569:	83 c4 14             	add    $0x14,%esp
  80156c:	5e                   	pop    %esi
  80156d:	5f                   	pop    %edi
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    
  801570:	85 f6                	test   %esi,%esi
  801572:	89 f5                	mov    %esi,%ebp
  801574:	75 0b                	jne    801581 <__umoddi3+0x91>
  801576:	b8 01 00 00 00       	mov    $0x1,%eax
  80157b:	31 d2                	xor    %edx,%edx
  80157d:	f7 f6                	div    %esi
  80157f:	89 c5                	mov    %eax,%ebp
  801581:	8b 44 24 04          	mov    0x4(%esp),%eax
  801585:	31 d2                	xor    %edx,%edx
  801587:	f7 f5                	div    %ebp
  801589:	89 c8                	mov    %ecx,%eax
  80158b:	f7 f5                	div    %ebp
  80158d:	eb 9c                	jmp    80152b <__umoddi3+0x3b>
  80158f:	90                   	nop
  801590:	89 c8                	mov    %ecx,%eax
  801592:	89 fa                	mov    %edi,%edx
  801594:	83 c4 14             	add    $0x14,%esp
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    
  80159b:	90                   	nop
  80159c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a0:	8b 04 24             	mov    (%esp),%eax
  8015a3:	be 20 00 00 00       	mov    $0x20,%esi
  8015a8:	89 e9                	mov    %ebp,%ecx
  8015aa:	29 ee                	sub    %ebp,%esi
  8015ac:	d3 e2                	shl    %cl,%edx
  8015ae:	89 f1                	mov    %esi,%ecx
  8015b0:	d3 e8                	shr    %cl,%eax
  8015b2:	89 e9                	mov    %ebp,%ecx
  8015b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b8:	8b 04 24             	mov    (%esp),%eax
  8015bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8015bf:	89 fa                	mov    %edi,%edx
  8015c1:	d3 e0                	shl    %cl,%eax
  8015c3:	89 f1                	mov    %esi,%ecx
  8015c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8015cd:	d3 ea                	shr    %cl,%edx
  8015cf:	89 e9                	mov    %ebp,%ecx
  8015d1:	d3 e7                	shl    %cl,%edi
  8015d3:	89 f1                	mov    %esi,%ecx
  8015d5:	d3 e8                	shr    %cl,%eax
  8015d7:	89 e9                	mov    %ebp,%ecx
  8015d9:	09 f8                	or     %edi,%eax
  8015db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015df:	f7 74 24 04          	divl   0x4(%esp)
  8015e3:	d3 e7                	shl    %cl,%edi
  8015e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015e9:	89 d7                	mov    %edx,%edi
  8015eb:	f7 64 24 08          	mull   0x8(%esp)
  8015ef:	39 d7                	cmp    %edx,%edi
  8015f1:	89 c1                	mov    %eax,%ecx
  8015f3:	89 14 24             	mov    %edx,(%esp)
  8015f6:	72 2c                	jb     801624 <__umoddi3+0x134>
  8015f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8015fc:	72 22                	jb     801620 <__umoddi3+0x130>
  8015fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801602:	29 c8                	sub    %ecx,%eax
  801604:	19 d7                	sbb    %edx,%edi
  801606:	89 e9                	mov    %ebp,%ecx
  801608:	89 fa                	mov    %edi,%edx
  80160a:	d3 e8                	shr    %cl,%eax
  80160c:	89 f1                	mov    %esi,%ecx
  80160e:	d3 e2                	shl    %cl,%edx
  801610:	89 e9                	mov    %ebp,%ecx
  801612:	d3 ef                	shr    %cl,%edi
  801614:	09 d0                	or     %edx,%eax
  801616:	89 fa                	mov    %edi,%edx
  801618:	83 c4 14             	add    $0x14,%esp
  80161b:	5e                   	pop    %esi
  80161c:	5f                   	pop    %edi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    
  80161f:	90                   	nop
  801620:	39 d7                	cmp    %edx,%edi
  801622:	75 da                	jne    8015fe <__umoddi3+0x10e>
  801624:	8b 14 24             	mov    (%esp),%edx
  801627:	89 c1                	mov    %eax,%ecx
  801629:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80162d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801631:	eb cb                	jmp    8015fe <__umoddi3+0x10e>
  801633:	90                   	nop
  801634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801638:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80163c:	0f 82 0f ff ff ff    	jb     801551 <__umoddi3+0x61>
  801642:	e9 1a ff ff ff       	jmp    801561 <__umoddi3+0x71>
