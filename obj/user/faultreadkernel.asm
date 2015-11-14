
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 a0 15 80 00 	movl   $0x8015a0,(%esp)
  800049:	e8 05 01 00 00       	call   800153 <cprintf>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80005e:	e8 f2 0f 00 00       	call   801055 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	89 c2                	mov    %eax,%edx
  80006a:	c1 e2 07             	shl    $0x7,%edx
  80006d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800074:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 db                	test   %ebx,%ebx
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 06                	mov    (%esi),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	89 74 24 04          	mov    %esi,0x4(%esp)
  800088:	89 1c 24             	mov    %ebx,(%esp)
  80008b:	e8 a3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800090:	e8 07 00 00 00       	call   80009c <exit>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a9:	e8 55 0f 00 00       	call   801003 <sys_env_destroy>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 14             	sub    $0x14,%esp
  8000b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ba:	8b 13                	mov    (%ebx),%edx
  8000bc:	8d 42 01             	lea    0x1(%edx),%eax
  8000bf:	89 03                	mov    %eax,(%ebx)
  8000c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cd:	75 19                	jne    8000e8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000cf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d6:	00 
  8000d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000da:	89 04 24             	mov    %eax,(%esp)
  8000dd:	e8 e4 0e 00 00       	call   800fc6 <sys_cputs>
		b->idx = 0;
  8000e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ec:	83 c4 14             	add    $0x14,%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800102:	00 00 00 
	b.cnt = 0;
  800105:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800112:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800116:	8b 45 08             	mov    0x8(%ebp),%eax
  800119:	89 44 24 08          	mov    %eax,0x8(%esp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	89 44 24 04          	mov    %eax,0x4(%esp)
  800127:	c7 04 24 b0 00 80 00 	movl   $0x8000b0,(%esp)
  80012e:	e8 ac 02 00 00       	call   8003df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800133:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800139:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 7b 0e 00 00       	call   800fc6 <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800160:	8b 45 08             	mov    0x8(%ebp),%eax
  800163:	89 04 24             	mov    %eax,(%esp)
  800166:	e8 87 ff ff ff       	call   8000f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    
  80016d:	66 90                	xchg   %ax,%ax
  80016f:	90                   	nop

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 3c             	sub    $0x3c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800184:	8b 45 0c             	mov    0xc(%ebp),%eax
  800187:	89 c3                	mov    %eax,%ebx
  800189:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800192:	b9 00 00 00 00       	mov    $0x0,%ecx
  800197:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019d:	39 d9                	cmp    %ebx,%ecx
  80019f:	72 05                	jb     8001a6 <printnum+0x36>
  8001a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001a4:	77 69                	ja     80020f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001ad:	83 ee 01             	sub    $0x1,%esi
  8001b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001c0:	89 c3                	mov    %eax,%ebx
  8001c2:	89 d6                	mov    %edx,%esi
  8001c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001df:	e8 1c 11 00 00       	call   801300 <__udivdi3>
  8001e4:	89 d9                	mov    %ebx,%ecx
  8001e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f5:	89 fa                	mov    %edi,%edx
  8001f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fa:	e8 71 ff ff ff       	call   800170 <printnum>
  8001ff:	eb 1b                	jmp    80021c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800201:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800205:	8b 45 18             	mov    0x18(%ebp),%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	ff d3                	call   *%ebx
  80020d:	eb 03                	jmp    800212 <printnum+0xa2>
  80020f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800212:	83 ee 01             	sub    $0x1,%esi
  800215:	85 f6                	test   %esi,%esi
  800217:	7f e8                	jg     800201 <printnum+0x91>
  800219:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800220:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800224:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800227:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	e8 ec 11 00 00       	call   801430 <__umoddi3>
  800244:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800248:	0f be 80 d1 15 80 00 	movsbl 0x8015d1(%eax),%eax
  80024f:	89 04 24             	mov    %eax,(%esp)
  800252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800255:	ff d0                	call   *%eax
}
  800257:	83 c4 3c             	add    $0x3c,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 3c             	sub    $0x3c,%esp
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80026e:	89 cf                	mov    %ecx,%edi
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800276:	8b 45 0c             	mov    0xc(%ebp),%eax
  800279:	89 c3                	mov    %eax,%ebx
  80027b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80027e:	8b 45 10             	mov    0x10(%ebp),%eax
  800281:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800284:	b9 00 00 00 00       	mov    $0x0,%ecx
  800289:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80028c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80028f:	39 d9                	cmp    %ebx,%ecx
  800291:	72 13                	jb     8002a6 <cprintnum+0x47>
  800293:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800296:	76 0e                	jbe    8002a6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029b:	0b 45 18             	or     0x18(%ebp),%eax
  80029e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8002a4:	eb 6a                	jmp    800310 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8002a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ad:	83 ee 01             	sub    $0x1,%esi
  8002b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002c0:	89 c3                	mov    %eax,%ebx
  8002c2:	89 d6                	mov    %edx,%esi
  8002c4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8002c7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8002ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 1c 10 00 00       	call   801300 <__udivdi3>
  8002e4:	89 d9                	mov    %ebx,%ecx
  8002e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f5:	89 f9                	mov    %edi,%ecx
  8002f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fd:	e8 5d ff ff ff       	call   80025f <cprintnum>
  800302:	eb 16                	jmp    80031a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800304:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800308:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800310:	83 ee 01             	sub    $0x1,%esi
  800313:	85 f6                	test   %esi,%esi
  800315:	7f ed                	jg     800304 <cprintnum+0xa5>
  800317:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80031a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800322:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800325:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800328:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800330:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800333:	89 04 24             	mov    %eax,(%esp)
  800336:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	e8 ee 10 00 00       	call   801430 <__umoddi3>
  800342:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800346:	0f be 80 d1 15 80 00 	movsbl 0x8015d1(%eax),%eax
  80034d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800350:	89 04 24             	mov    %eax,(%esp)
  800353:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800356:	ff d0                	call   *%eax
}
  800358:	83 c4 3c             	add    $0x3c,%esp
  80035b:	5b                   	pop    %ebx
  80035c:	5e                   	pop    %esi
  80035d:	5f                   	pop    %edi
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800363:	83 fa 01             	cmp    $0x1,%edx
  800366:	7e 0e                	jle    800376 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	8b 52 04             	mov    0x4(%edx),%edx
  800374:	eb 22                	jmp    800398 <getuint+0x38>
	else if (lflag)
  800376:	85 d2                	test   %edx,%edx
  800378:	74 10                	je     80038a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80037a:	8b 10                	mov    (%eax),%edx
  80037c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037f:	89 08                	mov    %ecx,(%eax)
  800381:	8b 02                	mov    (%edx),%eax
  800383:	ba 00 00 00 00       	mov    $0x0,%edx
  800388:	eb 0e                	jmp    800398 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80038a:	8b 10                	mov    (%eax),%edx
  80038c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038f:	89 08                	mov    %ecx,(%eax)
  800391:	8b 02                	mov    (%edx),%eax
  800393:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a4:	8b 10                	mov    (%eax),%edx
  8003a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a9:	73 0a                	jae    8003b5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	88 02                	mov    %al,(%edx)
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d5:	89 04 24             	mov    %eax,(%esp)
  8003d8:	e8 02 00 00 00       	call   8003df <vprintfmt>
	va_end(ap);
}
  8003dd:	c9                   	leave  
  8003de:	c3                   	ret    

008003df <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	57                   	push   %edi
  8003e3:	56                   	push   %esi
  8003e4:	53                   	push   %ebx
  8003e5:	83 ec 3c             	sub    $0x3c,%esp
  8003e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ee:	eb 14                	jmp    800404 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	0f 84 b3 03 00 00    	je     8007ab <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8003f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800402:	89 f3                	mov    %esi,%ebx
  800404:	8d 73 01             	lea    0x1(%ebx),%esi
  800407:	0f b6 03             	movzbl (%ebx),%eax
  80040a:	83 f8 25             	cmp    $0x25,%eax
  80040d:	75 e1                	jne    8003f0 <vprintfmt+0x11>
  80040f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800413:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80041a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800421:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800428:	ba 00 00 00 00       	mov    $0x0,%edx
  80042d:	eb 1d                	jmp    80044c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800431:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800435:	eb 15                	jmp    80044c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800439:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80043d:	eb 0d                	jmp    80044c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800442:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800445:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80044f:	0f b6 0e             	movzbl (%esi),%ecx
  800452:	0f b6 c1             	movzbl %cl,%eax
  800455:	83 e9 23             	sub    $0x23,%ecx
  800458:	80 f9 55             	cmp    $0x55,%cl
  80045b:	0f 87 2a 03 00 00    	ja     80078b <vprintfmt+0x3ac>
  800461:	0f b6 c9             	movzbl %cl,%ecx
  800464:	ff 24 8d a0 16 80 00 	jmp    *0x8016a0(,%ecx,4)
  80046b:	89 de                	mov    %ebx,%esi
  80046d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800472:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800475:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800479:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80047c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80047f:	83 fb 09             	cmp    $0x9,%ebx
  800482:	77 36                	ja     8004ba <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800484:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800487:	eb e9                	jmp    800472 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 48 04             	lea    0x4(%eax),%ecx
  80048f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800492:	8b 00                	mov    (%eax),%eax
  800494:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800499:	eb 22                	jmp    8004bd <vprintfmt+0xde>
  80049b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80049e:	85 c9                	test   %ecx,%ecx
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	0f 49 c1             	cmovns %ecx,%eax
  8004a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	89 de                	mov    %ebx,%esi
  8004ad:	eb 9d                	jmp    80044c <vprintfmt+0x6d>
  8004af:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004b8:	eb 92                	jmp    80044c <vprintfmt+0x6d>
  8004ba:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004bd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c1:	79 89                	jns    80044c <vprintfmt+0x6d>
  8004c3:	e9 77 ff ff ff       	jmp    80043f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004cd:	e9 7a ff ff ff       	jmp    80044c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	89 04 24             	mov    %eax,(%esp)
  8004e4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004e7:	e9 18 ff ff ff       	jmp    800404 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	99                   	cltd   
  8004f8:	31 d0                	xor    %edx,%eax
  8004fa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fc:	83 f8 09             	cmp    $0x9,%eax
  8004ff:	7f 0b                	jg     80050c <vprintfmt+0x12d>
  800501:	8b 14 85 60 19 80 00 	mov    0x801960(,%eax,4),%edx
  800508:	85 d2                	test   %edx,%edx
  80050a:	75 20                	jne    80052c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80050c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800510:	c7 44 24 08 e9 15 80 	movl   $0x8015e9,0x8(%esp)
  800517:	00 
  800518:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051c:	8b 45 08             	mov    0x8(%ebp),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	e8 90 fe ff ff       	call   8003b7 <printfmt>
  800527:	e9 d8 fe ff ff       	jmp    800404 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80052c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800530:	c7 44 24 08 f2 15 80 	movl   $0x8015f2,0x8(%esp)
  800537:	00 
  800538:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	e8 70 fe ff ff       	call   8003b7 <printfmt>
  800547:	e9 b8 fe ff ff       	jmp    800404 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80054f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800552:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 50 04             	lea    0x4(%eax),%edx
  80055b:	89 55 14             	mov    %edx,0x14(%ebp)
  80055e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800560:	85 f6                	test   %esi,%esi
  800562:	b8 e2 15 80 00       	mov    $0x8015e2,%eax
  800567:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80056a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80056e:	0f 84 97 00 00 00    	je     80060b <vprintfmt+0x22c>
  800574:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800578:	0f 8e 9b 00 00 00    	jle    800619 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80057e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800582:	89 34 24             	mov    %esi,(%esp)
  800585:	e8 ce 06 00 00       	call   800c58 <strnlen>
  80058a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058d:	29 c2                	sub    %eax,%edx
  80058f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800592:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800596:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800599:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80059c:	8b 75 08             	mov    0x8(%ebp),%esi
  80059f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005a2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a4:	eb 0f                	jmp    8005b5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ad:	89 04 24             	mov    %eax,(%esp)
  8005b0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b2:	83 eb 01             	sub    $0x1,%ebx
  8005b5:	85 db                	test   %ebx,%ebx
  8005b7:	7f ed                	jg     8005a6 <vprintfmt+0x1c7>
  8005b9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005bc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c6:	0f 49 c2             	cmovns %edx,%eax
  8005c9:	29 c2                	sub    %eax,%edx
  8005cb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ce:	89 d7                	mov    %edx,%edi
  8005d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005d3:	eb 50                	jmp    800625 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d9:	74 1e                	je     8005f9 <vprintfmt+0x21a>
  8005db:	0f be d2             	movsbl %dl,%edx
  8005de:	83 ea 20             	sub    $0x20,%edx
  8005e1:	83 fa 5e             	cmp    $0x5e,%edx
  8005e4:	76 13                	jbe    8005f9 <vprintfmt+0x21a>
					putch('?', putdat);
  8005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ed:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f4:	ff 55 08             	call   *0x8(%ebp)
  8005f7:	eb 0d                	jmp    800606 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800600:	89 04 24             	mov    %eax,(%esp)
  800603:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800606:	83 ef 01             	sub    $0x1,%edi
  800609:	eb 1a                	jmp    800625 <vprintfmt+0x246>
  80060b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80060e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800611:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800614:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800617:	eb 0c                	jmp    800625 <vprintfmt+0x246>
  800619:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80061c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80061f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800622:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800625:	83 c6 01             	add    $0x1,%esi
  800628:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80062c:	0f be c2             	movsbl %dl,%eax
  80062f:	85 c0                	test   %eax,%eax
  800631:	74 27                	je     80065a <vprintfmt+0x27b>
  800633:	85 db                	test   %ebx,%ebx
  800635:	78 9e                	js     8005d5 <vprintfmt+0x1f6>
  800637:	83 eb 01             	sub    $0x1,%ebx
  80063a:	79 99                	jns    8005d5 <vprintfmt+0x1f6>
  80063c:	89 f8                	mov    %edi,%eax
  80063e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800641:	8b 75 08             	mov    0x8(%ebp),%esi
  800644:	89 c3                	mov    %eax,%ebx
  800646:	eb 1a                	jmp    800662 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800648:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800653:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800655:	83 eb 01             	sub    $0x1,%ebx
  800658:	eb 08                	jmp    800662 <vprintfmt+0x283>
  80065a:	89 fb                	mov    %edi,%ebx
  80065c:	8b 75 08             	mov    0x8(%ebp),%esi
  80065f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800662:	85 db                	test   %ebx,%ebx
  800664:	7f e2                	jg     800648 <vprintfmt+0x269>
  800666:	89 75 08             	mov    %esi,0x8(%ebp)
  800669:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80066c:	e9 93 fd ff ff       	jmp    800404 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800671:	83 fa 01             	cmp    $0x1,%edx
  800674:	7e 16                	jle    80068c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 50 08             	lea    0x8(%eax),%edx
  80067c:	89 55 14             	mov    %edx,0x14(%ebp)
  80067f:	8b 50 04             	mov    0x4(%eax),%edx
  800682:	8b 00                	mov    (%eax),%eax
  800684:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800687:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80068a:	eb 32                	jmp    8006be <vprintfmt+0x2df>
	else if (lflag)
  80068c:	85 d2                	test   %edx,%edx
  80068e:	74 18                	je     8006a8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 30                	mov    (%eax),%esi
  80069b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80069e:	89 f0                	mov    %esi,%eax
  8006a0:	c1 f8 1f             	sar    $0x1f,%eax
  8006a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a6:	eb 16                	jmp    8006be <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 50 04             	lea    0x4(%eax),%edx
  8006ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b1:	8b 30                	mov    (%eax),%esi
  8006b3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006b6:	89 f0                	mov    %esi,%eax
  8006b8:	c1 f8 1f             	sar    $0x1f,%eax
  8006bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006cd:	0f 89 80 00 00 00    	jns    800753 <vprintfmt+0x374>
				putch('-', putdat);
  8006d3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006de:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e7:	f7 d8                	neg    %eax
  8006e9:	83 d2 00             	adc    $0x0,%edx
  8006ec:	f7 da                	neg    %edx
			}
			base = 10;
  8006ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f3:	eb 5e                	jmp    800753 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f8:	e8 63 fc ff ff       	call   800360 <getuint>
			base = 10;
  8006fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800702:	eb 4f                	jmp    800753 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800704:	8d 45 14             	lea    0x14(%ebp),%eax
  800707:	e8 54 fc ff ff       	call   800360 <getuint>
			base = 8 ;
  80070c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800711:	eb 40                	jmp    800753 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800713:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800717:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800721:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800725:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8d 50 04             	lea    0x4(%eax),%edx
  800735:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800738:	8b 00                	mov    (%eax),%eax
  80073a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800744:	eb 0d                	jmp    800753 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 12 fc ff ff       	call   800360 <getuint>
			base = 16;
  80074e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800753:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800757:	89 74 24 10          	mov    %esi,0x10(%esp)
  80075b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80075e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800762:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800766:	89 04 24             	mov    %eax,(%esp)
  800769:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076d:	89 fa                	mov    %edi,%edx
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	e8 f9 f9 ff ff       	call   800170 <printnum>
			break;
  800777:	e9 88 fc ff ff       	jmp    800404 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
			break;
  800786:	e9 79 fc ff ff       	jmp    800404 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800796:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800799:	89 f3                	mov    %esi,%ebx
  80079b:	eb 03                	jmp    8007a0 <vprintfmt+0x3c1>
  80079d:	83 eb 01             	sub    $0x1,%ebx
  8007a0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007a4:	75 f7                	jne    80079d <vprintfmt+0x3be>
  8007a6:	e9 59 fc ff ff       	jmp    800404 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007ab:	83 c4 3c             	add    $0x3c,%esp
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5f                   	pop    %edi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	57                   	push   %edi
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	83 ec 3c             	sub    $0x3c,%esp
  8007bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 50 04             	lea    0x4(%eax),%edx
  8007c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c8:	8b 00                	mov    (%eax),%eax
  8007ca:	c1 e0 08             	shl    $0x8,%eax
  8007cd:	0f b7 c0             	movzwl %ax,%eax
  8007d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  8007d3:	83 c8 25             	or     $0x25,%eax
  8007d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007d9:	eb 1a                	jmp    8007f5 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	0f 84 a9 03 00 00    	je     800b8c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  8007e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ea:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8007ed:	89 04 24             	mov    %eax,(%esp)
  8007f0:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f3:	89 fb                	mov    %edi,%ebx
  8007f5:	8d 7b 01             	lea    0x1(%ebx),%edi
  8007f8:	0f b6 03             	movzbl (%ebx),%eax
  8007fb:	83 f8 25             	cmp    $0x25,%eax
  8007fe:	75 db                	jne    8007db <cvprintfmt+0x28>
  800800:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800804:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80080b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800810:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800817:	ba 00 00 00 00       	mov    $0x0,%edx
  80081c:	eb 18                	jmp    800836 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800820:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800824:	eb 10                	jmp    800836 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800828:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80082c:	eb 08                	jmp    800836 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80082e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800831:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800836:	8d 5f 01             	lea    0x1(%edi),%ebx
  800839:	0f b6 0f             	movzbl (%edi),%ecx
  80083c:	0f b6 c1             	movzbl %cl,%eax
  80083f:	83 e9 23             	sub    $0x23,%ecx
  800842:	80 f9 55             	cmp    $0x55,%cl
  800845:	0f 87 1f 03 00 00    	ja     800b6a <cvprintfmt+0x3b7>
  80084b:	0f b6 c9             	movzbl %cl,%ecx
  80084e:	ff 24 8d f8 17 80 00 	jmp    *0x8017f8(,%ecx,4)
  800855:	89 df                	mov    %ebx,%edi
  800857:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80085c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80085f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800863:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800866:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800869:	83 f9 09             	cmp    $0x9,%ecx
  80086c:	77 33                	ja     8008a1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80086e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800871:	eb e9                	jmp    80085c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8d 48 04             	lea    0x4(%eax),%ecx
  800879:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80087c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800880:	eb 1f                	jmp    8008a1 <cvprintfmt+0xee>
  800882:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800885:	85 ff                	test   %edi,%edi
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	0f 49 c7             	cmovns %edi,%eax
  80088f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800892:	89 df                	mov    %ebx,%edi
  800894:	eb a0                	jmp    800836 <cvprintfmt+0x83>
  800896:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800898:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80089f:	eb 95                	jmp    800836 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  8008a1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008a5:	79 8f                	jns    800836 <cvprintfmt+0x83>
  8008a7:	eb 85                	jmp    80082e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ac:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008ae:	66 90                	xchg   %ax,%ax
  8008b0:	eb 84                	jmp    800836 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008c5:	0b 10                	or     (%eax),%edx
  8008c7:	89 14 24             	mov    %edx,(%esp)
  8008ca:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008cd:	e9 23 ff ff ff       	jmp    8007f5 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8d 50 04             	lea    0x4(%eax),%edx
  8008d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008db:	8b 00                	mov    (%eax),%eax
  8008dd:	99                   	cltd   
  8008de:	31 d0                	xor    %edx,%eax
  8008e0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008e2:	83 f8 09             	cmp    $0x9,%eax
  8008e5:	7f 0b                	jg     8008f2 <cvprintfmt+0x13f>
  8008e7:	8b 14 85 60 19 80 00 	mov    0x801960(,%eax,4),%edx
  8008ee:	85 d2                	test   %edx,%edx
  8008f0:	75 23                	jne    800915 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  8008f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f6:	c7 44 24 08 e9 15 80 	movl   $0x8015e9,0x8(%esp)
  8008fd:	00 
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800901:	89 44 24 04          	mov    %eax,0x4(%esp)
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	89 04 24             	mov    %eax,(%esp)
  80090b:	e8 a7 fa ff ff       	call   8003b7 <printfmt>
  800910:	e9 e0 fe ff ff       	jmp    8007f5 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800915:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800919:	c7 44 24 08 f2 15 80 	movl   $0x8015f2,0x8(%esp)
  800920:	00 
  800921:	8b 45 0c             	mov    0xc(%ebp),%eax
  800924:	89 44 24 04          	mov    %eax,0x4(%esp)
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	89 04 24             	mov    %eax,(%esp)
  80092e:	e8 84 fa ff ff       	call   8003b7 <printfmt>
  800933:	e9 bd fe ff ff       	jmp    8007f5 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800938:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80093b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 48 04             	lea    0x4(%eax),%ecx
  800944:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800947:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800949:	85 ff                	test   %edi,%edi
  80094b:	b8 e2 15 80 00       	mov    $0x8015e2,%eax
  800950:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800953:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800957:	74 61                	je     8009ba <cvprintfmt+0x207>
  800959:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80095d:	7e 5b                	jle    8009ba <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  80095f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800963:	89 3c 24             	mov    %edi,(%esp)
  800966:	e8 ed 02 00 00       	call   800c58 <strnlen>
  80096b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80096e:	29 c2                	sub    %eax,%edx
  800970:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800973:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800977:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80097a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80097d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800980:	8b 75 08             	mov    0x8(%ebp),%esi
  800983:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800986:	89 d3                	mov    %edx,%ebx
  800988:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80098a:	eb 0f                	jmp    80099b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800993:	89 3c 24             	mov    %edi,(%esp)
  800996:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800998:	83 eb 01             	sub    $0x1,%ebx
  80099b:	85 db                	test   %ebx,%ebx
  80099d:	7f ed                	jg     80098c <cvprintfmt+0x1d9>
  80099f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8009a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009ab:	85 d2                	test   %edx,%edx
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b2:	0f 49 c2             	cmovns %edx,%eax
  8009b5:	29 c2                	sub    %eax,%edx
  8009b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  8009ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009bd:	83 c8 3f             	or     $0x3f,%eax
  8009c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009c3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009c6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009c9:	eb 36                	jmp    800a01 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009cf:	74 1d                	je     8009ee <cvprintfmt+0x23b>
  8009d1:	0f be d2             	movsbl %dl,%edx
  8009d4:	83 ea 20             	sub    $0x20,%edx
  8009d7:	83 fa 5e             	cmp    $0x5e,%edx
  8009da:	76 12                	jbe    8009ee <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  8009dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e6:	89 04 24             	mov    %eax,(%esp)
  8009e9:	ff 55 08             	call   *0x8(%ebp)
  8009ec:	eb 10                	jmp    8009fe <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009f5:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8009f8:	89 04 24             	mov    %eax,(%esp)
  8009fb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009fe:	83 eb 01             	sub    $0x1,%ebx
  800a01:	83 c7 01             	add    $0x1,%edi
  800a04:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a08:	0f be c2             	movsbl %dl,%eax
  800a0b:	85 c0                	test   %eax,%eax
  800a0d:	74 27                	je     800a36 <cvprintfmt+0x283>
  800a0f:	85 f6                	test   %esi,%esi
  800a11:	78 b8                	js     8009cb <cvprintfmt+0x218>
  800a13:	83 ee 01             	sub    $0x1,%esi
  800a16:	79 b3                	jns    8009cb <cvprintfmt+0x218>
  800a18:	89 d8                	mov    %ebx,%eax
  800a1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a20:	89 c3                	mov    %eax,%ebx
  800a22:	eb 18                	jmp    800a3c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800a24:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a2f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800a31:	83 eb 01             	sub    $0x1,%ebx
  800a34:	eb 06                	jmp    800a3c <cvprintfmt+0x289>
  800a36:	8b 75 08             	mov    0x8(%ebp),%esi
  800a39:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	7f e4                	jg     800a24 <cvprintfmt+0x271>
  800a40:	89 75 08             	mov    %esi,0x8(%ebp)
  800a43:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a49:	e9 a7 fd ff ff       	jmp    8007f5 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a4e:	83 fa 01             	cmp    $0x1,%edx
  800a51:	7e 10                	jle    800a63 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800a53:	8b 45 14             	mov    0x14(%ebp),%eax
  800a56:	8d 50 08             	lea    0x8(%eax),%edx
  800a59:	89 55 14             	mov    %edx,0x14(%ebp)
  800a5c:	8b 30                	mov    (%eax),%esi
  800a5e:	8b 78 04             	mov    0x4(%eax),%edi
  800a61:	eb 26                	jmp    800a89 <cvprintfmt+0x2d6>
	else if (lflag)
  800a63:	85 d2                	test   %edx,%edx
  800a65:	74 12                	je     800a79 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800a67:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6a:	8d 50 04             	lea    0x4(%eax),%edx
  800a6d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a70:	8b 30                	mov    (%eax),%esi
  800a72:	89 f7                	mov    %esi,%edi
  800a74:	c1 ff 1f             	sar    $0x1f,%edi
  800a77:	eb 10                	jmp    800a89 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800a79:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7c:	8d 50 04             	lea    0x4(%eax),%edx
  800a7f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a82:	8b 30                	mov    (%eax),%esi
  800a84:	89 f7                	mov    %esi,%edi
  800a86:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a89:	89 f0                	mov    %esi,%eax
  800a8b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a8d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a92:	85 ff                	test   %edi,%edi
  800a94:	0f 89 8e 00 00 00    	jns    800b28 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aa4:	83 c8 2d             	or     $0x2d,%eax
  800aa7:	89 04 24             	mov    %eax,(%esp)
  800aaa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aad:	89 f0                	mov    %esi,%eax
  800aaf:	89 fa                	mov    %edi,%edx
  800ab1:	f7 d8                	neg    %eax
  800ab3:	83 d2 00             	adc    $0x0,%edx
  800ab6:	f7 da                	neg    %edx
			}
			base = 10;
  800ab8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800abd:	eb 69                	jmp    800b28 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800abf:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac2:	e8 99 f8 ff ff       	call   800360 <getuint>
			base = 10;
  800ac7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800acc:	eb 5a                	jmp    800b28 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ace:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad1:	e8 8a f8 ff ff       	call   800360 <getuint>
			base = 8 ;
  800ad6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800adb:	eb 4b                	jmp    800b28 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800ae7:	89 f0                	mov    %esi,%eax
  800ae9:	83 c8 30             	or     $0x30,%eax
  800aec:	89 04 24             	mov    %eax,(%esp)
  800aef:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af9:	89 f0                	mov    %esi,%eax
  800afb:	83 c8 78             	or     $0x78,%eax
  800afe:	89 04 24             	mov    %eax,(%esp)
  800b01:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b04:	8b 45 14             	mov    0x14(%ebp),%eax
  800b07:	8d 50 04             	lea    0x4(%eax),%edx
  800b0a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800b0d:	8b 00                	mov    (%eax),%eax
  800b0f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b14:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b19:	eb 0d                	jmp    800b28 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1e:	e8 3d f8 ff ff       	call   800360 <getuint>
			base = 16;
  800b23:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800b28:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800b2c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b30:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800b33:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b37:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b3b:	89 04 24             	mov    %eax,(%esp)
  800b3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	8b 55 08             	mov    0x8(%ebp),%edx
  800b48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b4b:	e8 0f f7 ff ff       	call   80025f <cprintnum>
			break;
  800b50:	e9 a0 fc ff ff       	jmp    8007f5 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800b55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b58:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b5c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b5f:	89 04 24             	mov    %eax,(%esp)
  800b62:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b65:	e9 8b fc ff ff       	jmp    8007f5 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b71:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b74:	89 04 24             	mov    %eax,(%esp)
  800b77:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b7a:	89 fb                	mov    %edi,%ebx
  800b7c:	eb 03                	jmp    800b81 <cvprintfmt+0x3ce>
  800b7e:	83 eb 01             	sub    $0x1,%ebx
  800b81:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800b85:	75 f7                	jne    800b7e <cvprintfmt+0x3cb>
  800b87:	e9 69 fc ff ff       	jmp    8007f5 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800b8c:	83 c4 3c             	add    $0x3c,%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b9a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800b9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	89 04 24             	mov    %eax,(%esp)
  800bb5:	e8 f9 fb ff ff       	call   8007b3 <cvprintfmt>
	va_end(ap);
}
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	83 ec 28             	sub    $0x28,%esp
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bcb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bcf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	74 30                	je     800c0d <vsnprintf+0x51>
  800bdd:	85 d2                	test   %edx,%edx
  800bdf:	7e 2c                	jle    800c0d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800be1:	8b 45 14             	mov    0x14(%ebp),%eax
  800be4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be8:	8b 45 10             	mov    0x10(%ebp),%eax
  800beb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf6:	c7 04 24 9a 03 80 00 	movl   $0x80039a,(%esp)
  800bfd:	e8 dd f7 ff ff       	call   8003df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c02:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c05:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0b:	eb 05                	jmp    800c12 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c1a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c21:	8b 45 10             	mov    0x10(%ebp),%eax
  800c24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c32:	89 04 24             	mov    %eax,(%esp)
  800c35:	e8 82 ff ff ff       	call   800bbc <vsnprintf>
	va_end(ap);

	return rc;
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    
  800c3c:	66 90                	xchg   %ax,%ax
  800c3e:	66 90                	xchg   %ax,%ax

00800c40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4b:	eb 03                	jmp    800c50 <strlen+0x10>
		n++;
  800c4d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c50:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c54:	75 f7                	jne    800c4d <strlen+0xd>
		n++;
	return n;
}
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c61:	b8 00 00 00 00       	mov    $0x0,%eax
  800c66:	eb 03                	jmp    800c6b <strnlen+0x13>
		n++;
  800c68:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6b:	39 d0                	cmp    %edx,%eax
  800c6d:	74 06                	je     800c75 <strnlen+0x1d>
  800c6f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c73:	75 f3                	jne    800c68 <strnlen+0x10>
		n++;
	return n;
}
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	53                   	push   %ebx
  800c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c81:	89 c2                	mov    %eax,%edx
  800c83:	83 c2 01             	add    $0x1,%edx
  800c86:	83 c1 01             	add    $0x1,%ecx
  800c89:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c8d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c90:	84 db                	test   %bl,%bl
  800c92:	75 ef                	jne    800c83 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c94:	5b                   	pop    %ebx
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 08             	sub    $0x8,%esp
  800c9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ca1:	89 1c 24             	mov    %ebx,(%esp)
  800ca4:	e8 97 ff ff ff       	call   800c40 <strlen>
	strcpy(dst + len, src);
  800ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cac:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cb0:	01 d8                	add    %ebx,%eax
  800cb2:	89 04 24             	mov    %eax,(%esp)
  800cb5:	e8 bd ff ff ff       	call   800c77 <strcpy>
	return dst;
}
  800cba:	89 d8                	mov    %ebx,%eax
  800cbc:	83 c4 08             	add    $0x8,%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	8b 75 08             	mov    0x8(%ebp),%esi
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	89 f3                	mov    %esi,%ebx
  800ccf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd2:	89 f2                	mov    %esi,%edx
  800cd4:	eb 0f                	jmp    800ce5 <strncpy+0x23>
		*dst++ = *src;
  800cd6:	83 c2 01             	add    $0x1,%edx
  800cd9:	0f b6 01             	movzbl (%ecx),%eax
  800cdc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cdf:	80 39 01             	cmpb   $0x1,(%ecx)
  800ce2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce5:	39 da                	cmp    %ebx,%edx
  800ce7:	75 ed                	jne    800cd6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ce9:	89 f0                	mov    %esi,%eax
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cfd:	89 f0                	mov    %esi,%eax
  800cff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d03:	85 c9                	test   %ecx,%ecx
  800d05:	75 0b                	jne    800d12 <strlcpy+0x23>
  800d07:	eb 1d                	jmp    800d26 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d09:	83 c0 01             	add    $0x1,%eax
  800d0c:	83 c2 01             	add    $0x1,%edx
  800d0f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d12:	39 d8                	cmp    %ebx,%eax
  800d14:	74 0b                	je     800d21 <strlcpy+0x32>
  800d16:	0f b6 0a             	movzbl (%edx),%ecx
  800d19:	84 c9                	test   %cl,%cl
  800d1b:	75 ec                	jne    800d09 <strlcpy+0x1a>
  800d1d:	89 c2                	mov    %eax,%edx
  800d1f:	eb 02                	jmp    800d23 <strlcpy+0x34>
  800d21:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d23:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d26:	29 f0                	sub    %esi,%eax
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d35:	eb 06                	jmp    800d3d <strcmp+0x11>
		p++, q++;
  800d37:	83 c1 01             	add    $0x1,%ecx
  800d3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d3d:	0f b6 01             	movzbl (%ecx),%eax
  800d40:	84 c0                	test   %al,%al
  800d42:	74 04                	je     800d48 <strcmp+0x1c>
  800d44:	3a 02                	cmp    (%edx),%al
  800d46:	74 ef                	je     800d37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d48:	0f b6 c0             	movzbl %al,%eax
  800d4b:	0f b6 12             	movzbl (%edx),%edx
  800d4e:	29 d0                	sub    %edx,%eax
}
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	53                   	push   %ebx
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5c:	89 c3                	mov    %eax,%ebx
  800d5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d61:	eb 06                	jmp    800d69 <strncmp+0x17>
		n--, p++, q++;
  800d63:	83 c0 01             	add    $0x1,%eax
  800d66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d69:	39 d8                	cmp    %ebx,%eax
  800d6b:	74 15                	je     800d82 <strncmp+0x30>
  800d6d:	0f b6 08             	movzbl (%eax),%ecx
  800d70:	84 c9                	test   %cl,%cl
  800d72:	74 04                	je     800d78 <strncmp+0x26>
  800d74:	3a 0a                	cmp    (%edx),%cl
  800d76:	74 eb                	je     800d63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d78:	0f b6 00             	movzbl (%eax),%eax
  800d7b:	0f b6 12             	movzbl (%edx),%edx
  800d7e:	29 d0                	sub    %edx,%eax
  800d80:	eb 05                	jmp    800d87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d87:	5b                   	pop    %ebx
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d94:	eb 07                	jmp    800d9d <strchr+0x13>
		if (*s == c)
  800d96:	38 ca                	cmp    %cl,%dl
  800d98:	74 0f                	je     800da9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d9a:	83 c0 01             	add    $0x1,%eax
  800d9d:	0f b6 10             	movzbl (%eax),%edx
  800da0:	84 d2                	test   %dl,%dl
  800da2:	75 f2                	jne    800d96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
  800db1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800db5:	eb 07                	jmp    800dbe <strfind+0x13>
		if (*s == c)
  800db7:	38 ca                	cmp    %cl,%dl
  800db9:	74 0a                	je     800dc5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800dbb:	83 c0 01             	add    $0x1,%eax
  800dbe:	0f b6 10             	movzbl (%eax),%edx
  800dc1:	84 d2                	test   %dl,%dl
  800dc3:	75 f2                	jne    800db7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
  800dcd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dd3:	85 c9                	test   %ecx,%ecx
  800dd5:	74 36                	je     800e0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dd7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ddd:	75 28                	jne    800e07 <memset+0x40>
  800ddf:	f6 c1 03             	test   $0x3,%cl
  800de2:	75 23                	jne    800e07 <memset+0x40>
		c &= 0xFF;
  800de4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800de8:	89 d3                	mov    %edx,%ebx
  800dea:	c1 e3 08             	shl    $0x8,%ebx
  800ded:	89 d6                	mov    %edx,%esi
  800def:	c1 e6 18             	shl    $0x18,%esi
  800df2:	89 d0                	mov    %edx,%eax
  800df4:	c1 e0 10             	shl    $0x10,%eax
  800df7:	09 f0                	or     %esi,%eax
  800df9:	09 c2                	or     %eax,%edx
  800dfb:	89 d0                	mov    %edx,%eax
  800dfd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e02:	fc                   	cld    
  800e03:	f3 ab                	rep stos %eax,%es:(%edi)
  800e05:	eb 06                	jmp    800e0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0a:	fc                   	cld    
  800e0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e0d:	89 f8                	mov    %edi,%eax
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e22:	39 c6                	cmp    %eax,%esi
  800e24:	73 35                	jae    800e5b <memmove+0x47>
  800e26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e29:	39 d0                	cmp    %edx,%eax
  800e2b:	73 2e                	jae    800e5b <memmove+0x47>
		s += n;
		d += n;
  800e2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800e30:	89 d6                	mov    %edx,%esi
  800e32:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e3a:	75 13                	jne    800e4f <memmove+0x3b>
  800e3c:	f6 c1 03             	test   $0x3,%cl
  800e3f:	75 0e                	jne    800e4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e41:	83 ef 04             	sub    $0x4,%edi
  800e44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e4a:	fd                   	std    
  800e4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e4d:	eb 09                	jmp    800e58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e4f:	83 ef 01             	sub    $0x1,%edi
  800e52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e55:	fd                   	std    
  800e56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e58:	fc                   	cld    
  800e59:	eb 1d                	jmp    800e78 <memmove+0x64>
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e5f:	f6 c2 03             	test   $0x3,%dl
  800e62:	75 0f                	jne    800e73 <memmove+0x5f>
  800e64:	f6 c1 03             	test   $0x3,%cl
  800e67:	75 0a                	jne    800e73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e69:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e6c:	89 c7                	mov    %eax,%edi
  800e6e:	fc                   	cld    
  800e6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e71:	eb 05                	jmp    800e78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e73:	89 c7                	mov    %eax,%edi
  800e75:	fc                   	cld    
  800e76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e82:	8b 45 10             	mov    0x10(%ebp),%eax
  800e85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	89 04 24             	mov    %eax,(%esp)
  800e96:	e8 79 ff ff ff       	call   800e14 <memmove>
}
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    

00800e9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea8:	89 d6                	mov    %edx,%esi
  800eaa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ead:	eb 1a                	jmp    800ec9 <memcmp+0x2c>
		if (*s1 != *s2)
  800eaf:	0f b6 02             	movzbl (%edx),%eax
  800eb2:	0f b6 19             	movzbl (%ecx),%ebx
  800eb5:	38 d8                	cmp    %bl,%al
  800eb7:	74 0a                	je     800ec3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800eb9:	0f b6 c0             	movzbl %al,%eax
  800ebc:	0f b6 db             	movzbl %bl,%ebx
  800ebf:	29 d8                	sub    %ebx,%eax
  800ec1:	eb 0f                	jmp    800ed2 <memcmp+0x35>
		s1++, s2++;
  800ec3:	83 c2 01             	add    $0x1,%edx
  800ec6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ec9:	39 f2                	cmp    %esi,%edx
  800ecb:	75 e2                	jne    800eaf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed2:	5b                   	pop    %ebx
  800ed3:	5e                   	pop    %esi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  800edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800edf:	89 c2                	mov    %eax,%edx
  800ee1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ee4:	eb 07                	jmp    800eed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ee6:	38 08                	cmp    %cl,(%eax)
  800ee8:	74 07                	je     800ef1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eea:	83 c0 01             	add    $0x1,%eax
  800eed:	39 d0                	cmp    %edx,%eax
  800eef:	72 f5                	jb     800ee6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eff:	eb 03                	jmp    800f04 <strtol+0x11>
		s++;
  800f01:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f04:	0f b6 0a             	movzbl (%edx),%ecx
  800f07:	80 f9 09             	cmp    $0x9,%cl
  800f0a:	74 f5                	je     800f01 <strtol+0xe>
  800f0c:	80 f9 20             	cmp    $0x20,%cl
  800f0f:	74 f0                	je     800f01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f11:	80 f9 2b             	cmp    $0x2b,%cl
  800f14:	75 0a                	jne    800f20 <strtol+0x2d>
		s++;
  800f16:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f19:	bf 00 00 00 00       	mov    $0x0,%edi
  800f1e:	eb 11                	jmp    800f31 <strtol+0x3e>
  800f20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f25:	80 f9 2d             	cmp    $0x2d,%cl
  800f28:	75 07                	jne    800f31 <strtol+0x3e>
		s++, neg = 1;
  800f2a:	8d 52 01             	lea    0x1(%edx),%edx
  800f2d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800f36:	75 15                	jne    800f4d <strtol+0x5a>
  800f38:	80 3a 30             	cmpb   $0x30,(%edx)
  800f3b:	75 10                	jne    800f4d <strtol+0x5a>
  800f3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f41:	75 0a                	jne    800f4d <strtol+0x5a>
		s += 2, base = 16;
  800f43:	83 c2 02             	add    $0x2,%edx
  800f46:	b8 10 00 00 00       	mov    $0x10,%eax
  800f4b:	eb 10                	jmp    800f5d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	75 0c                	jne    800f5d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f51:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f53:	80 3a 30             	cmpb   $0x30,(%edx)
  800f56:	75 05                	jne    800f5d <strtol+0x6a>
		s++, base = 8;
  800f58:	83 c2 01             	add    $0x1,%edx
  800f5b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800f5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f62:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f65:	0f b6 0a             	movzbl (%edx),%ecx
  800f68:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800f6b:	89 f0                	mov    %esi,%eax
  800f6d:	3c 09                	cmp    $0x9,%al
  800f6f:	77 08                	ja     800f79 <strtol+0x86>
			dig = *s - '0';
  800f71:	0f be c9             	movsbl %cl,%ecx
  800f74:	83 e9 30             	sub    $0x30,%ecx
  800f77:	eb 20                	jmp    800f99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800f79:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800f7c:	89 f0                	mov    %esi,%eax
  800f7e:	3c 19                	cmp    $0x19,%al
  800f80:	77 08                	ja     800f8a <strtol+0x97>
			dig = *s - 'a' + 10;
  800f82:	0f be c9             	movsbl %cl,%ecx
  800f85:	83 e9 57             	sub    $0x57,%ecx
  800f88:	eb 0f                	jmp    800f99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800f8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800f8d:	89 f0                	mov    %esi,%eax
  800f8f:	3c 19                	cmp    $0x19,%al
  800f91:	77 16                	ja     800fa9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800f93:	0f be c9             	movsbl %cl,%ecx
  800f96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800f9c:	7d 0f                	jge    800fad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800f9e:	83 c2 01             	add    $0x1,%edx
  800fa1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800fa5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800fa7:	eb bc                	jmp    800f65 <strtol+0x72>
  800fa9:	89 d8                	mov    %ebx,%eax
  800fab:	eb 02                	jmp    800faf <strtol+0xbc>
  800fad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800faf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fb3:	74 05                	je     800fba <strtol+0xc7>
		*endptr = (char *) s;
  800fb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fb8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800fba:	f7 d8                	neg    %eax
  800fbc:	85 ff                	test   %edi,%edi
  800fbe:	0f 44 c3             	cmove  %ebx,%eax
}
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	57                   	push   %edi
  800fca:	56                   	push   %esi
  800fcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd7:	89 c3                	mov    %eax,%ebx
  800fd9:	89 c7                	mov    %eax,%edi
  800fdb:	89 c6                	mov    %eax,%esi
  800fdd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fea:	ba 00 00 00 00       	mov    $0x0,%edx
  800fef:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff4:	89 d1                	mov    %edx,%ecx
  800ff6:	89 d3                	mov    %edx,%ebx
  800ff8:	89 d7                	mov    %edx,%edi
  800ffa:	89 d6                	mov    %edx,%esi
  800ffc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	57                   	push   %edi
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801011:	b8 03 00 00 00       	mov    $0x3,%eax
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	89 cb                	mov    %ecx,%ebx
  80101b:	89 cf                	mov    %ecx,%edi
  80101d:	89 ce                	mov    %ecx,%esi
  80101f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801021:	85 c0                	test   %eax,%eax
  801023:	7e 28                	jle    80104d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801025:	89 44 24 10          	mov    %eax,0x10(%esp)
  801029:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801030:	00 
  801031:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801040:	00 
  801041:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801048:	e8 5b 02 00 00       	call   8012a8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80104d:	83 c4 2c             	add    $0x2c,%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	57                   	push   %edi
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	ba 00 00 00 00       	mov    $0x0,%edx
  801060:	b8 02 00 00 00       	mov    $0x2,%eax
  801065:	89 d1                	mov    %edx,%ecx
  801067:	89 d3                	mov    %edx,%ebx
  801069:	89 d7                	mov    %edx,%edi
  80106b:	89 d6                	mov    %edx,%esi
  80106d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <sys_yield>:

void
sys_yield(void)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107a:	ba 00 00 00 00       	mov    $0x0,%edx
  80107f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801084:	89 d1                	mov    %edx,%ecx
  801086:	89 d3                	mov    %edx,%ebx
  801088:	89 d7                	mov    %edx,%edi
  80108a:	89 d6                	mov    %edx,%esi
  80108c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
  801099:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109c:	be 00 00 00 00       	mov    $0x0,%esi
  8010a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8010a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010af:	89 f7                	mov    %esi,%edi
  8010b1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	7e 28                	jle    8010df <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010bb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010c2:	00 
  8010c3:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  8010ca:	00 
  8010cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010d2:	00 
  8010d3:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  8010da:	e8 c9 01 00 00       	call   8012a8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010df:	83 c4 2c             	add    $0x2c,%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5e                   	pop    %esi
  8010e4:	5f                   	pop    %edi
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	57                   	push   %edi
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8010f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  801101:	8b 75 18             	mov    0x18(%ebp),%esi
  801104:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801106:	85 c0                	test   %eax,%eax
  801108:	7e 28                	jle    801132 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801115:	00 
  801116:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  80111d:	00 
  80111e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801125:	00 
  801126:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  80112d:	e8 76 01 00 00       	call   8012a8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801132:	83 c4 2c             	add    $0x2c,%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	57                   	push   %edi
  80113e:	56                   	push   %esi
  80113f:	53                   	push   %ebx
  801140:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801143:	bb 00 00 00 00       	mov    $0x0,%ebx
  801148:	b8 06 00 00 00       	mov    $0x6,%eax
  80114d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801150:	8b 55 08             	mov    0x8(%ebp),%edx
  801153:	89 df                	mov    %ebx,%edi
  801155:	89 de                	mov    %ebx,%esi
  801157:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801159:	85 c0                	test   %eax,%eax
  80115b:	7e 28                	jle    801185 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801161:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801168:	00 
  801169:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801170:	00 
  801171:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801178:	00 
  801179:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801180:	e8 23 01 00 00       	call   8012a8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801185:	83 c4 2c             	add    $0x2c,%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5f                   	pop    %edi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	57                   	push   %edi
  801191:	56                   	push   %esi
  801192:	53                   	push   %ebx
  801193:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801196:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119b:	b8 08 00 00 00       	mov    $0x8,%eax
  8011a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a6:	89 df                	mov    %ebx,%edi
  8011a8:	89 de                	mov    %ebx,%esi
  8011aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	7e 28                	jle    8011d8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8011bb:	00 
  8011bc:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  8011c3:	00 
  8011c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011cb:	00 
  8011cc:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  8011d3:	e8 d0 00 00 00       	call   8012a8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011d8:	83 c4 2c             	add    $0x2c,%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5f                   	pop    %edi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ee:	b8 09 00 00 00       	mov    $0x9,%eax
  8011f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f9:	89 df                	mov    %ebx,%edi
  8011fb:	89 de                	mov    %ebx,%esi
  8011fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ff:	85 c0                	test   %eax,%eax
  801201:	7e 28                	jle    80122b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801203:	89 44 24 10          	mov    %eax,0x10(%esp)
  801207:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80120e:	00 
  80120f:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801216:	00 
  801217:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80121e:	00 
  80121f:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801226:	e8 7d 00 00 00       	call   8012a8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80122b:	83 c4 2c             	add    $0x2c,%esp
  80122e:	5b                   	pop    %ebx
  80122f:	5e                   	pop    %esi
  801230:	5f                   	pop    %edi
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801239:	be 00 00 00 00       	mov    $0x0,%esi
  80123e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	8b 55 08             	mov    0x8(%ebp),%edx
  801249:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80124f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5f                   	pop    %edi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	57                   	push   %edi
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
  80125c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801264:	b8 0c 00 00 00       	mov    $0xc,%eax
  801269:	8b 55 08             	mov    0x8(%ebp),%edx
  80126c:	89 cb                	mov    %ecx,%ebx
  80126e:	89 cf                	mov    %ecx,%edi
  801270:	89 ce                	mov    %ecx,%esi
  801272:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801274:	85 c0                	test   %eax,%eax
  801276:	7e 28                	jle    8012a0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801278:	89 44 24 10          	mov    %eax,0x10(%esp)
  80127c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801283:	00 
  801284:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  80128b:	00 
  80128c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801293:	00 
  801294:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  80129b:	e8 08 00 00 00       	call   8012a8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012a0:	83 c4 2c             	add    $0x2c,%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5f                   	pop    %edi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	56                   	push   %esi
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012b0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012b3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8012b9:	e8 97 fd ff ff       	call   801055 <sys_getenvid>
  8012be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012cc:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d4:	c7 04 24 b4 19 80 00 	movl   $0x8019b4,(%esp)
  8012db:	e8 73 ee ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	e8 03 ee ff ff       	call   8000f2 <vcprintf>
	cprintf("\n");
  8012ef:	c7 04 24 d8 19 80 00 	movl   $0x8019d8,(%esp)
  8012f6:	e8 58 ee ff ff       	call   800153 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012fb:	cc                   	int3   
  8012fc:	eb fd                	jmp    8012fb <_panic+0x53>
  8012fe:	66 90                	xchg   %ax,%ax

00801300 <__udivdi3>:
  801300:	55                   	push   %ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	8b 44 24 28          	mov    0x28(%esp),%eax
  80130a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80130e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801312:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801316:	85 c0                	test   %eax,%eax
  801318:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80131c:	89 ea                	mov    %ebp,%edx
  80131e:	89 0c 24             	mov    %ecx,(%esp)
  801321:	75 2d                	jne    801350 <__udivdi3+0x50>
  801323:	39 e9                	cmp    %ebp,%ecx
  801325:	77 61                	ja     801388 <__udivdi3+0x88>
  801327:	85 c9                	test   %ecx,%ecx
  801329:	89 ce                	mov    %ecx,%esi
  80132b:	75 0b                	jne    801338 <__udivdi3+0x38>
  80132d:	b8 01 00 00 00       	mov    $0x1,%eax
  801332:	31 d2                	xor    %edx,%edx
  801334:	f7 f1                	div    %ecx
  801336:	89 c6                	mov    %eax,%esi
  801338:	31 d2                	xor    %edx,%edx
  80133a:	89 e8                	mov    %ebp,%eax
  80133c:	f7 f6                	div    %esi
  80133e:	89 c5                	mov    %eax,%ebp
  801340:	89 f8                	mov    %edi,%eax
  801342:	f7 f6                	div    %esi
  801344:	89 ea                	mov    %ebp,%edx
  801346:	83 c4 0c             	add    $0xc,%esp
  801349:	5e                   	pop    %esi
  80134a:	5f                   	pop    %edi
  80134b:	5d                   	pop    %ebp
  80134c:	c3                   	ret    
  80134d:	8d 76 00             	lea    0x0(%esi),%esi
  801350:	39 e8                	cmp    %ebp,%eax
  801352:	77 24                	ja     801378 <__udivdi3+0x78>
  801354:	0f bd e8             	bsr    %eax,%ebp
  801357:	83 f5 1f             	xor    $0x1f,%ebp
  80135a:	75 3c                	jne    801398 <__udivdi3+0x98>
  80135c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801360:	39 34 24             	cmp    %esi,(%esp)
  801363:	0f 86 9f 00 00 00    	jbe    801408 <__udivdi3+0x108>
  801369:	39 d0                	cmp    %edx,%eax
  80136b:	0f 82 97 00 00 00    	jb     801408 <__udivdi3+0x108>
  801371:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801378:	31 d2                	xor    %edx,%edx
  80137a:	31 c0                	xor    %eax,%eax
  80137c:	83 c4 0c             	add    $0xc,%esp
  80137f:	5e                   	pop    %esi
  801380:	5f                   	pop    %edi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    
  801383:	90                   	nop
  801384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801388:	89 f8                	mov    %edi,%eax
  80138a:	f7 f1                	div    %ecx
  80138c:	31 d2                	xor    %edx,%edx
  80138e:	83 c4 0c             	add    $0xc,%esp
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    
  801395:	8d 76 00             	lea    0x0(%esi),%esi
  801398:	89 e9                	mov    %ebp,%ecx
  80139a:	8b 3c 24             	mov    (%esp),%edi
  80139d:	d3 e0                	shl    %cl,%eax
  80139f:	89 c6                	mov    %eax,%esi
  8013a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013a6:	29 e8                	sub    %ebp,%eax
  8013a8:	89 c1                	mov    %eax,%ecx
  8013aa:	d3 ef                	shr    %cl,%edi
  8013ac:	89 e9                	mov    %ebp,%ecx
  8013ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013b2:	8b 3c 24             	mov    (%esp),%edi
  8013b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013b9:	89 d6                	mov    %edx,%esi
  8013bb:	d3 e7                	shl    %cl,%edi
  8013bd:	89 c1                	mov    %eax,%ecx
  8013bf:	89 3c 24             	mov    %edi,(%esp)
  8013c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013c6:	d3 ee                	shr    %cl,%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	d3 e2                	shl    %cl,%edx
  8013cc:	89 c1                	mov    %eax,%ecx
  8013ce:	d3 ef                	shr    %cl,%edi
  8013d0:	09 d7                	or     %edx,%edi
  8013d2:	89 f2                	mov    %esi,%edx
  8013d4:	89 f8                	mov    %edi,%eax
  8013d6:	f7 74 24 08          	divl   0x8(%esp)
  8013da:	89 d6                	mov    %edx,%esi
  8013dc:	89 c7                	mov    %eax,%edi
  8013de:	f7 24 24             	mull   (%esp)
  8013e1:	39 d6                	cmp    %edx,%esi
  8013e3:	89 14 24             	mov    %edx,(%esp)
  8013e6:	72 30                	jb     801418 <__udivdi3+0x118>
  8013e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013ec:	89 e9                	mov    %ebp,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	39 c2                	cmp    %eax,%edx
  8013f2:	73 05                	jae    8013f9 <__udivdi3+0xf9>
  8013f4:	3b 34 24             	cmp    (%esp),%esi
  8013f7:	74 1f                	je     801418 <__udivdi3+0x118>
  8013f9:	89 f8                	mov    %edi,%eax
  8013fb:	31 d2                	xor    %edx,%edx
  8013fd:	e9 7a ff ff ff       	jmp    80137c <__udivdi3+0x7c>
  801402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801408:	31 d2                	xor    %edx,%edx
  80140a:	b8 01 00 00 00       	mov    $0x1,%eax
  80140f:	e9 68 ff ff ff       	jmp    80137c <__udivdi3+0x7c>
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	8d 47 ff             	lea    -0x1(%edi),%eax
  80141b:	31 d2                	xor    %edx,%edx
  80141d:	83 c4 0c             	add    $0xc,%esp
  801420:	5e                   	pop    %esi
  801421:	5f                   	pop    %edi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    
  801424:	66 90                	xchg   %ax,%ax
  801426:	66 90                	xchg   %ax,%ax
  801428:	66 90                	xchg   %ax,%ax
  80142a:	66 90                	xchg   %ax,%ax
  80142c:	66 90                	xchg   %ax,%ax
  80142e:	66 90                	xchg   %ax,%ax

00801430 <__umoddi3>:
  801430:	55                   	push   %ebp
  801431:	57                   	push   %edi
  801432:	56                   	push   %esi
  801433:	83 ec 14             	sub    $0x14,%esp
  801436:	8b 44 24 28          	mov    0x28(%esp),%eax
  80143a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80143e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801442:	89 c7                	mov    %eax,%edi
  801444:	89 44 24 04          	mov    %eax,0x4(%esp)
  801448:	8b 44 24 30          	mov    0x30(%esp),%eax
  80144c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801450:	89 34 24             	mov    %esi,(%esp)
  801453:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801457:	85 c0                	test   %eax,%eax
  801459:	89 c2                	mov    %eax,%edx
  80145b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80145f:	75 17                	jne    801478 <__umoddi3+0x48>
  801461:	39 fe                	cmp    %edi,%esi
  801463:	76 4b                	jbe    8014b0 <__umoddi3+0x80>
  801465:	89 c8                	mov    %ecx,%eax
  801467:	89 fa                	mov    %edi,%edx
  801469:	f7 f6                	div    %esi
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	31 d2                	xor    %edx,%edx
  80146f:	83 c4 14             	add    $0x14,%esp
  801472:	5e                   	pop    %esi
  801473:	5f                   	pop    %edi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    
  801476:	66 90                	xchg   %ax,%ax
  801478:	39 f8                	cmp    %edi,%eax
  80147a:	77 54                	ja     8014d0 <__umoddi3+0xa0>
  80147c:	0f bd e8             	bsr    %eax,%ebp
  80147f:	83 f5 1f             	xor    $0x1f,%ebp
  801482:	75 5c                	jne    8014e0 <__umoddi3+0xb0>
  801484:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801488:	39 3c 24             	cmp    %edi,(%esp)
  80148b:	0f 87 e7 00 00 00    	ja     801578 <__umoddi3+0x148>
  801491:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801495:	29 f1                	sub    %esi,%ecx
  801497:	19 c7                	sbb    %eax,%edi
  801499:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80149d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014a9:	83 c4 14             	add    $0x14,%esp
  8014ac:	5e                   	pop    %esi
  8014ad:	5f                   	pop    %edi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    
  8014b0:	85 f6                	test   %esi,%esi
  8014b2:	89 f5                	mov    %esi,%ebp
  8014b4:	75 0b                	jne    8014c1 <__umoddi3+0x91>
  8014b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	f7 f6                	div    %esi
  8014bf:	89 c5                	mov    %eax,%ebp
  8014c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014c5:	31 d2                	xor    %edx,%edx
  8014c7:	f7 f5                	div    %ebp
  8014c9:	89 c8                	mov    %ecx,%eax
  8014cb:	f7 f5                	div    %ebp
  8014cd:	eb 9c                	jmp    80146b <__umoddi3+0x3b>
  8014cf:	90                   	nop
  8014d0:	89 c8                	mov    %ecx,%eax
  8014d2:	89 fa                	mov    %edi,%edx
  8014d4:	83 c4 14             	add    $0x14,%esp
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    
  8014db:	90                   	nop
  8014dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e0:	8b 04 24             	mov    (%esp),%eax
  8014e3:	be 20 00 00 00       	mov    $0x20,%esi
  8014e8:	89 e9                	mov    %ebp,%ecx
  8014ea:	29 ee                	sub    %ebp,%esi
  8014ec:	d3 e2                	shl    %cl,%edx
  8014ee:	89 f1                	mov    %esi,%ecx
  8014f0:	d3 e8                	shr    %cl,%eax
  8014f2:	89 e9                	mov    %ebp,%ecx
  8014f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f8:	8b 04 24             	mov    (%esp),%eax
  8014fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8014ff:	89 fa                	mov    %edi,%edx
  801501:	d3 e0                	shl    %cl,%eax
  801503:	89 f1                	mov    %esi,%ecx
  801505:	89 44 24 08          	mov    %eax,0x8(%esp)
  801509:	8b 44 24 10          	mov    0x10(%esp),%eax
  80150d:	d3 ea                	shr    %cl,%edx
  80150f:	89 e9                	mov    %ebp,%ecx
  801511:	d3 e7                	shl    %cl,%edi
  801513:	89 f1                	mov    %esi,%ecx
  801515:	d3 e8                	shr    %cl,%eax
  801517:	89 e9                	mov    %ebp,%ecx
  801519:	09 f8                	or     %edi,%eax
  80151b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80151f:	f7 74 24 04          	divl   0x4(%esp)
  801523:	d3 e7                	shl    %cl,%edi
  801525:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801529:	89 d7                	mov    %edx,%edi
  80152b:	f7 64 24 08          	mull   0x8(%esp)
  80152f:	39 d7                	cmp    %edx,%edi
  801531:	89 c1                	mov    %eax,%ecx
  801533:	89 14 24             	mov    %edx,(%esp)
  801536:	72 2c                	jb     801564 <__umoddi3+0x134>
  801538:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80153c:	72 22                	jb     801560 <__umoddi3+0x130>
  80153e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801542:	29 c8                	sub    %ecx,%eax
  801544:	19 d7                	sbb    %edx,%edi
  801546:	89 e9                	mov    %ebp,%ecx
  801548:	89 fa                	mov    %edi,%edx
  80154a:	d3 e8                	shr    %cl,%eax
  80154c:	89 f1                	mov    %esi,%ecx
  80154e:	d3 e2                	shl    %cl,%edx
  801550:	89 e9                	mov    %ebp,%ecx
  801552:	d3 ef                	shr    %cl,%edi
  801554:	09 d0                	or     %edx,%eax
  801556:	89 fa                	mov    %edi,%edx
  801558:	83 c4 14             	add    $0x14,%esp
  80155b:	5e                   	pop    %esi
  80155c:	5f                   	pop    %edi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    
  80155f:	90                   	nop
  801560:	39 d7                	cmp    %edx,%edi
  801562:	75 da                	jne    80153e <__umoddi3+0x10e>
  801564:	8b 14 24             	mov    (%esp),%edx
  801567:	89 c1                	mov    %eax,%ecx
  801569:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80156d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801571:	eb cb                	jmp    80153e <__umoddi3+0x10e>
  801573:	90                   	nop
  801574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801578:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80157c:	0f 82 0f ff ff ff    	jb     801491 <__umoddi3+0x61>
  801582:	e9 1a ff ff ff       	jmp    8014a1 <__umoddi3+0x71>
