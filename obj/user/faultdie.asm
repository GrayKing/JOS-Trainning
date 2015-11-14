
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 61 00 00 00       	call   800092 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 40 16 80 00 	movl   $0x801640,(%esp)
  800060:	e8 30 01 00 00       	call   800195 <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 2b 10 00 00       	call   801095 <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 d1 0f 00 00       	call   801043 <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 62 12 00 00       	call   8012e8 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	83 ec 10             	sub    $0x10,%esp
  80009a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80009d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  8000a0:	e8 f0 0f 00 00       	call   801095 <sys_getenvid>
  8000a5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000aa:	89 c2                	mov    %eax,%edx
  8000ac:	c1 e2 07             	shl    $0x7,%edx
  8000af:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000b6:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bb:	85 db                	test   %ebx,%ebx
  8000bd:	7e 07                	jle    8000c6 <libmain+0x34>
		binaryname = argv[0];
  8000bf:	8b 06                	mov    (%esi),%eax
  8000c1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ca:	89 1c 24             	mov    %ebx,(%esp)
  8000cd:	e8 a2 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000d2:	e8 07 00 00 00       	call   8000de <exit>
}
  8000d7:	83 c4 10             	add    $0x10,%esp
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	e8 53 0f 00 00       	call   801043 <sys_env_destroy>
}
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 14             	sub    $0x14,%esp
  8000f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fc:	8b 13                	mov    (%ebx),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 03                	mov    %eax,(%ebx)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	75 19                	jne    80012a <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800111:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800118:	00 
  800119:	8d 43 08             	lea    0x8(%ebx),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 e2 0e 00 00       	call   801006 <sys_cputs>
		b->idx = 0;
  800124:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80012a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012e:	83 c4 14             	add    $0x14,%esp
  800131:	5b                   	pop    %ebx
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	8b 45 0c             	mov    0xc(%ebp),%eax
  800154:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800158:	8b 45 08             	mov    0x8(%ebp),%eax
  80015b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	89 44 24 04          	mov    %eax,0x4(%esp)
  800169:	c7 04 24 f2 00 80 00 	movl   $0x8000f2,(%esp)
  800170:	e8 aa 02 00 00       	call   80041f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800175:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 79 0e 00 00       	call   801006 <sys_cputs>

	return b.cnt;
}
  80018d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a5:	89 04 24             	mov    %eax,(%esp)
  8001a8:	e8 87 ff ff ff       	call   800134 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    
  8001af:	90                   	nop

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 3c             	sub    $0x3c,%esp
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001bc:	89 d7                	mov    %edx,%edi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c7:	89 c3                	mov    %eax,%ebx
  8001c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001dd:	39 d9                	cmp    %ebx,%ecx
  8001df:	72 05                	jb     8001e6 <printnum+0x36>
  8001e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001e4:	77 69                	ja     80024f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001ed:	83 ee 01             	sub    $0x1,%esi
  8001f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800200:	89 c3                	mov    %eax,%ebx
  800202:	89 d6                	mov    %edx,%esi
  800204:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800207:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80020a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80020e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800212:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	e8 8c 11 00 00       	call   8013b0 <__udivdi3>
  800224:	89 d9                	mov    %ebx,%ecx
  800226:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80022a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	89 54 24 04          	mov    %edx,0x4(%esp)
  800235:	89 fa                	mov    %edi,%edx
  800237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023a:	e8 71 ff ff ff       	call   8001b0 <printnum>
  80023f:	eb 1b                	jmp    80025c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800241:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800245:	8b 45 18             	mov    0x18(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	ff d3                	call   *%ebx
  80024d:	eb 03                	jmp    800252 <printnum+0xa2>
  80024f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800252:	83 ee 01             	sub    $0x1,%esi
  800255:	85 f6                	test   %esi,%esi
  800257:	7f e8                	jg     800241 <printnum+0x91>
  800259:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800260:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800264:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800267:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	e8 5c 12 00 00       	call   8014e0 <__umoddi3>
  800284:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800288:	0f be 80 66 16 80 00 	movsbl 0x801666(%eax),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800295:	ff d0                	call   *%eax
}
  800297:	83 c4 3c             	add    $0x3c,%esp
  80029a:	5b                   	pop    %ebx
  80029b:	5e                   	pop    %esi
  80029c:	5f                   	pop    %edi
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	57                   	push   %edi
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 3c             	sub    $0x3c,%esp
  8002a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002ab:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ae:	89 cf                	mov    %ecx,%edi
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b9:	89 c3                	mov    %eax,%ebx
  8002bb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8002be:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002cc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002cf:	39 d9                	cmp    %ebx,%ecx
  8002d1:	72 13                	jb     8002e6 <cprintnum+0x47>
  8002d3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002d6:	76 0e                	jbe    8002e6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8002d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002db:	0b 45 18             	or     0x18(%ebp),%eax
  8002de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8002e4:	eb 6a                	jmp    800350 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8002e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ed:	83 ee 01             	sub    $0x1,%esi
  8002f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800300:	89 c3                	mov    %eax,%ebx
  800302:	89 d6                	mov    %edx,%esi
  800304:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800307:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80030a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80030e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800312:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80031b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031f:	e8 8c 10 00 00       	call   8013b0 <__udivdi3>
  800324:	89 d9                	mov    %ebx,%ecx
  800326:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80032a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80032e:	89 04 24             	mov    %eax,(%esp)
  800331:	89 54 24 04          	mov    %edx,0x4(%esp)
  800335:	89 f9                	mov    %edi,%ecx
  800337:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80033a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033d:	e8 5d ff ff ff       	call   80029f <cprintnum>
  800342:	eb 16                	jmp    80035a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034b:	89 04 24             	mov    %eax,(%esp)
  80034e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800350:	83 ee 01             	sub    $0x1,%esi
  800353:	85 f6                	test   %esi,%esi
  800355:	7f ed                	jg     800344 <cprintnum+0xa5>
  800357:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80035a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800362:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800365:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800368:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800370:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800373:	89 04 24             	mov    %eax,(%esp)
  800376:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037d:	e8 5e 11 00 00       	call   8014e0 <__umoddi3>
  800382:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800386:	0f be 80 66 16 80 00 	movsbl 0x801666(%eax),%eax
  80038d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800390:	89 04 24             	mov    %eax,(%esp)
  800393:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800396:	ff d0                	call   *%eax
}
  800398:	83 c4 3c             	add    $0x3c,%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a3:	83 fa 01             	cmp    $0x1,%edx
  8003a6:	7e 0e                	jle    8003b6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a8:	8b 10                	mov    (%eax),%edx
  8003aa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ad:	89 08                	mov    %ecx,(%eax)
  8003af:	8b 02                	mov    (%edx),%eax
  8003b1:	8b 52 04             	mov    0x4(%edx),%edx
  8003b4:	eb 22                	jmp    8003d8 <getuint+0x38>
	else if (lflag)
  8003b6:	85 d2                	test   %edx,%edx
  8003b8:	74 10                	je     8003ca <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003bf:	89 08                	mov    %ecx,(%eax)
  8003c1:	8b 02                	mov    (%edx),%eax
  8003c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c8:	eb 0e                	jmp    8003d8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ca:	8b 10                	mov    (%eax),%edx
  8003cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 02                	mov    (%edx),%eax
  8003d3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e4:	8b 10                	mov    (%eax),%edx
  8003e6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e9:	73 0a                	jae    8003f5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003eb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ee:	89 08                	mov    %ecx,(%eax)
  8003f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f3:	88 02                	mov    %al,(%edx)
}
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800400:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800404:	8b 45 10             	mov    0x10(%ebp),%eax
  800407:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80040e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800412:	8b 45 08             	mov    0x8(%ebp),%eax
  800415:	89 04 24             	mov    %eax,(%esp)
  800418:	e8 02 00 00 00       	call   80041f <vprintfmt>
	va_end(ap);
}
  80041d:	c9                   	leave  
  80041e:	c3                   	ret    

0080041f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	57                   	push   %edi
  800423:	56                   	push   %esi
  800424:	53                   	push   %ebx
  800425:	83 ec 3c             	sub    $0x3c,%esp
  800428:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80042b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80042e:	eb 14                	jmp    800444 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800430:	85 c0                	test   %eax,%eax
  800432:	0f 84 b3 03 00 00    	je     8007eb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800438:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043c:	89 04 24             	mov    %eax,(%esp)
  80043f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800442:	89 f3                	mov    %esi,%ebx
  800444:	8d 73 01             	lea    0x1(%ebx),%esi
  800447:	0f b6 03             	movzbl (%ebx),%eax
  80044a:	83 f8 25             	cmp    $0x25,%eax
  80044d:	75 e1                	jne    800430 <vprintfmt+0x11>
  80044f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800453:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80045a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800461:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800468:	ba 00 00 00 00       	mov    $0x0,%edx
  80046d:	eb 1d                	jmp    80048c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800471:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800475:	eb 15                	jmp    80048c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800479:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80047d:	eb 0d                	jmp    80048c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80047f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800482:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800485:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80048f:	0f b6 0e             	movzbl (%esi),%ecx
  800492:	0f b6 c1             	movzbl %cl,%eax
  800495:	83 e9 23             	sub    $0x23,%ecx
  800498:	80 f9 55             	cmp    $0x55,%cl
  80049b:	0f 87 2a 03 00 00    	ja     8007cb <vprintfmt+0x3ac>
  8004a1:	0f b6 c9             	movzbl %cl,%ecx
  8004a4:	ff 24 8d 20 17 80 00 	jmp    *0x801720(,%ecx,4)
  8004ab:	89 de                	mov    %ebx,%esi
  8004ad:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004b5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004b9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004bc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004bf:	83 fb 09             	cmp    $0x9,%ebx
  8004c2:	77 36                	ja     8004fa <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c7:	eb e9                	jmp    8004b2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004cf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d2:	8b 00                	mov    (%eax),%eax
  8004d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d9:	eb 22                	jmp    8004fd <vprintfmt+0xde>
  8004db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004de:	85 c9                	test   %ecx,%ecx
  8004e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e5:	0f 49 c1             	cmovns %ecx,%eax
  8004e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	89 de                	mov    %ebx,%esi
  8004ed:	eb 9d                	jmp    80048c <vprintfmt+0x6d>
  8004ef:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004f8:	eb 92                	jmp    80048c <vprintfmt+0x6d>
  8004fa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800501:	79 89                	jns    80048c <vprintfmt+0x6d>
  800503:	e9 77 ff ff ff       	jmp    80047f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800508:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050d:	e9 7a ff ff ff       	jmp    80048c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 04 24             	mov    %eax,(%esp)
  800524:	ff 55 08             	call   *0x8(%ebp)
			break;
  800527:	e9 18 ff ff ff       	jmp    800444 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 00                	mov    (%eax),%eax
  800537:	99                   	cltd   
  800538:	31 d0                	xor    %edx,%eax
  80053a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053c:	83 f8 09             	cmp    $0x9,%eax
  80053f:	7f 0b                	jg     80054c <vprintfmt+0x12d>
  800541:	8b 14 85 e0 19 80 00 	mov    0x8019e0(,%eax,4),%edx
  800548:	85 d2                	test   %edx,%edx
  80054a:	75 20                	jne    80056c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80054c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800550:	c7 44 24 08 7e 16 80 	movl   $0x80167e,0x8(%esp)
  800557:	00 
  800558:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055c:	8b 45 08             	mov    0x8(%ebp),%eax
  80055f:	89 04 24             	mov    %eax,(%esp)
  800562:	e8 90 fe ff ff       	call   8003f7 <printfmt>
  800567:	e9 d8 fe ff ff       	jmp    800444 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80056c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800570:	c7 44 24 08 87 16 80 	movl   $0x801687,0x8(%esp)
  800577:	00 
  800578:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057c:	8b 45 08             	mov    0x8(%ebp),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	e8 70 fe ff ff       	call   8003f7 <printfmt>
  800587:	e9 b8 fe ff ff       	jmp    800444 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80058f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800592:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 04             	lea    0x4(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005a0:	85 f6                	test   %esi,%esi
  8005a2:	b8 77 16 80 00       	mov    $0x801677,%eax
  8005a7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005aa:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005ae:	0f 84 97 00 00 00    	je     80064b <vprintfmt+0x22c>
  8005b4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005b8:	0f 8e 9b 00 00 00    	jle    800659 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c2:	89 34 24             	mov    %esi,(%esp)
  8005c5:	e8 ce 06 00 00       	call   800c98 <strnlen>
  8005ca:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005cd:	29 c2                	sub    %eax,%edx
  8005cf:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005d2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005d9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005df:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005e2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	eb 0f                	jmp    8005f5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ed:	89 04 24             	mov    %eax,(%esp)
  8005f0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f2:	83 eb 01             	sub    $0x1,%ebx
  8005f5:	85 db                	test   %ebx,%ebx
  8005f7:	7f ed                	jg     8005e6 <vprintfmt+0x1c7>
  8005f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005fc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ff:	85 d2                	test   %edx,%edx
  800601:	b8 00 00 00 00       	mov    $0x0,%eax
  800606:	0f 49 c2             	cmovns %edx,%eax
  800609:	29 c2                	sub    %eax,%edx
  80060b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80060e:	89 d7                	mov    %edx,%edi
  800610:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800613:	eb 50                	jmp    800665 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800615:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800619:	74 1e                	je     800639 <vprintfmt+0x21a>
  80061b:	0f be d2             	movsbl %dl,%edx
  80061e:	83 ea 20             	sub    $0x20,%edx
  800621:	83 fa 5e             	cmp    $0x5e,%edx
  800624:	76 13                	jbe    800639 <vprintfmt+0x21a>
					putch('?', putdat);
  800626:	8b 45 0c             	mov    0xc(%ebp),%eax
  800629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800634:	ff 55 08             	call   *0x8(%ebp)
  800637:	eb 0d                	jmp    800646 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800639:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 ef 01             	sub    $0x1,%edi
  800649:	eb 1a                	jmp    800665 <vprintfmt+0x246>
  80064b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80064e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800651:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800654:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800657:	eb 0c                	jmp    800665 <vprintfmt+0x246>
  800659:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80065c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80065f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800662:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800665:	83 c6 01             	add    $0x1,%esi
  800668:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80066c:	0f be c2             	movsbl %dl,%eax
  80066f:	85 c0                	test   %eax,%eax
  800671:	74 27                	je     80069a <vprintfmt+0x27b>
  800673:	85 db                	test   %ebx,%ebx
  800675:	78 9e                	js     800615 <vprintfmt+0x1f6>
  800677:	83 eb 01             	sub    $0x1,%ebx
  80067a:	79 99                	jns    800615 <vprintfmt+0x1f6>
  80067c:	89 f8                	mov    %edi,%eax
  80067e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800681:	8b 75 08             	mov    0x8(%ebp),%esi
  800684:	89 c3                	mov    %eax,%ebx
  800686:	eb 1a                	jmp    8006a2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800688:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800693:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800695:	83 eb 01             	sub    $0x1,%ebx
  800698:	eb 08                	jmp    8006a2 <vprintfmt+0x283>
  80069a:	89 fb                	mov    %edi,%ebx
  80069c:	8b 75 08             	mov    0x8(%ebp),%esi
  80069f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006a2:	85 db                	test   %ebx,%ebx
  8006a4:	7f e2                	jg     800688 <vprintfmt+0x269>
  8006a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006ac:	e9 93 fd ff ff       	jmp    800444 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b1:	83 fa 01             	cmp    $0x1,%edx
  8006b4:	7e 16                	jle    8006cc <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 50 08             	lea    0x8(%eax),%edx
  8006bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bf:	8b 50 04             	mov    0x4(%eax),%edx
  8006c2:	8b 00                	mov    (%eax),%eax
  8006c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006ca:	eb 32                	jmp    8006fe <vprintfmt+0x2df>
	else if (lflag)
  8006cc:	85 d2                	test   %edx,%edx
  8006ce:	74 18                	je     8006e8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 50 04             	lea    0x4(%eax),%edx
  8006d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d9:	8b 30                	mov    (%eax),%esi
  8006db:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006de:	89 f0                	mov    %esi,%eax
  8006e0:	c1 f8 1f             	sar    $0x1f,%eax
  8006e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e6:	eb 16                	jmp    8006fe <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 30                	mov    (%eax),%esi
  8006f3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006f6:	89 f0                	mov    %esi,%eax
  8006f8:	c1 f8 1f             	sar    $0x1f,%eax
  8006fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800701:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800704:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800709:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070d:	0f 89 80 00 00 00    	jns    800793 <vprintfmt+0x374>
				putch('-', putdat);
  800713:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800717:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800721:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800724:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800727:	f7 d8                	neg    %eax
  800729:	83 d2 00             	adc    $0x0,%edx
  80072c:	f7 da                	neg    %edx
			}
			base = 10;
  80072e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800733:	eb 5e                	jmp    800793 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
  800738:	e8 63 fc ff ff       	call   8003a0 <getuint>
			base = 10;
  80073d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800742:	eb 4f                	jmp    800793 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
  800747:	e8 54 fc ff ff       	call   8003a0 <getuint>
			base = 8 ;
  80074c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800751:	eb 40                	jmp    800793 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800753:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800757:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80075e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800761:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800765:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80076c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8d 50 04             	lea    0x4(%eax),%edx
  800775:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80077f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800784:	eb 0d                	jmp    800793 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
  800789:	e8 12 fc ff ff       	call   8003a0 <getuint>
			base = 16;
  80078e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800793:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800797:	89 74 24 10          	mov    %esi,0x10(%esp)
  80079b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80079e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007a6:	89 04 24             	mov    %eax,(%esp)
  8007a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ad:	89 fa                	mov    %edi,%edx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	e8 f9 f9 ff ff       	call   8001b0 <printnum>
			break;
  8007b7:	e9 88 fc ff ff       	jmp    800444 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c0:	89 04 24             	mov    %eax,(%esp)
  8007c3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007c6:	e9 79 fc ff ff       	jmp    800444 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007cf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d9:	89 f3                	mov    %esi,%ebx
  8007db:	eb 03                	jmp    8007e0 <vprintfmt+0x3c1>
  8007dd:	83 eb 01             	sub    $0x1,%ebx
  8007e0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x3be>
  8007e6:	e9 59 fc ff ff       	jmp    800444 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	83 c4 3c             	add    $0x3c,%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	57                   	push   %edi
  8007f7:	56                   	push   %esi
  8007f8:	53                   	push   %ebx
  8007f9:	83 ec 3c             	sub    $0x3c,%esp
  8007fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8d 50 04             	lea    0x4(%eax),%edx
  800805:	89 55 14             	mov    %edx,0x14(%ebp)
  800808:	8b 00                	mov    (%eax),%eax
  80080a:	c1 e0 08             	shl    $0x8,%eax
  80080d:	0f b7 c0             	movzwl %ax,%eax
  800810:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800813:	83 c8 25             	or     $0x25,%eax
  800816:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800819:	eb 1a                	jmp    800835 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80081b:	85 c0                	test   %eax,%eax
  80081d:	0f 84 a9 03 00 00    	je     800bcc <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800823:	8b 75 0c             	mov    0xc(%ebp),%esi
  800826:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80082d:	89 04 24             	mov    %eax,(%esp)
  800830:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800833:	89 fb                	mov    %edi,%ebx
  800835:	8d 7b 01             	lea    0x1(%ebx),%edi
  800838:	0f b6 03             	movzbl (%ebx),%eax
  80083b:	83 f8 25             	cmp    $0x25,%eax
  80083e:	75 db                	jne    80081b <cvprintfmt+0x28>
  800840:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800844:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80084b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800850:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
  80085c:	eb 18                	jmp    800876 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800860:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800864:	eb 10                	jmp    800876 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800866:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800868:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80086c:	eb 08                	jmp    800876 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80086e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800871:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800876:	8d 5f 01             	lea    0x1(%edi),%ebx
  800879:	0f b6 0f             	movzbl (%edi),%ecx
  80087c:	0f b6 c1             	movzbl %cl,%eax
  80087f:	83 e9 23             	sub    $0x23,%ecx
  800882:	80 f9 55             	cmp    $0x55,%cl
  800885:	0f 87 1f 03 00 00    	ja     800baa <cvprintfmt+0x3b7>
  80088b:	0f b6 c9             	movzbl %cl,%ecx
  80088e:	ff 24 8d 78 18 80 00 	jmp    *0x801878(,%ecx,4)
  800895:	89 df                	mov    %ebx,%edi
  800897:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80089c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80089f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  8008a3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8008a6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008a9:	83 f9 09             	cmp    $0x9,%ecx
  8008ac:	77 33                	ja     8008e1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008ae:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008b1:	eb e9                	jmp    80089c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8008b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008bc:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008c0:	eb 1f                	jmp    8008e1 <cvprintfmt+0xee>
  8008c2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8008c5:	85 ff                	test   %edi,%edi
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cc:	0f 49 c7             	cmovns %edi,%eax
  8008cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d2:	89 df                	mov    %ebx,%edi
  8008d4:	eb a0                	jmp    800876 <cvprintfmt+0x83>
  8008d6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8008df:	eb 95                	jmp    800876 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  8008e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008e5:	79 8f                	jns    800876 <cvprintfmt+0x83>
  8008e7:	eb 85                	jmp    80086e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008e9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ec:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008ee:	66 90                	xchg   %ax,%ax
  8008f0:	eb 84                	jmp    800876 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8d 50 04             	lea    0x4(%eax),%edx
  8008f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800902:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800905:	0b 10                	or     (%eax),%edx
  800907:	89 14 24             	mov    %edx,(%esp)
  80090a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80090d:	e9 23 ff ff ff       	jmp    800835 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8d 50 04             	lea    0x4(%eax),%edx
  800918:	89 55 14             	mov    %edx,0x14(%ebp)
  80091b:	8b 00                	mov    (%eax),%eax
  80091d:	99                   	cltd   
  80091e:	31 d0                	xor    %edx,%eax
  800920:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800922:	83 f8 09             	cmp    $0x9,%eax
  800925:	7f 0b                	jg     800932 <cvprintfmt+0x13f>
  800927:	8b 14 85 e0 19 80 00 	mov    0x8019e0(,%eax,4),%edx
  80092e:	85 d2                	test   %edx,%edx
  800930:	75 23                	jne    800955 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800932:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800936:	c7 44 24 08 7e 16 80 	movl   $0x80167e,0x8(%esp)
  80093d:	00 
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	89 44 24 04          	mov    %eax,0x4(%esp)
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	89 04 24             	mov    %eax,(%esp)
  80094b:	e8 a7 fa ff ff       	call   8003f7 <printfmt>
  800950:	e9 e0 fe ff ff       	jmp    800835 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800955:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800959:	c7 44 24 08 87 16 80 	movl   $0x801687,0x8(%esp)
  800960:	00 
  800961:	8b 45 0c             	mov    0xc(%ebp),%eax
  800964:	89 44 24 04          	mov    %eax,0x4(%esp)
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	89 04 24             	mov    %eax,(%esp)
  80096e:	e8 84 fa ff ff       	call   8003f7 <printfmt>
  800973:	e9 bd fe ff ff       	jmp    800835 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800978:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80097b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  80097e:	8b 45 14             	mov    0x14(%ebp),%eax
  800981:	8d 48 04             	lea    0x4(%eax),%ecx
  800984:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800987:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800989:	85 ff                	test   %edi,%edi
  80098b:	b8 77 16 80 00       	mov    $0x801677,%eax
  800990:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800993:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800997:	74 61                	je     8009fa <cvprintfmt+0x207>
  800999:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80099d:	7e 5b                	jle    8009fa <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  80099f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a3:	89 3c 24             	mov    %edi,(%esp)
  8009a6:	e8 ed 02 00 00       	call   800c98 <strnlen>
  8009ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009ae:	29 c2                	sub    %eax,%edx
  8009b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  8009b3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009b7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8009ba:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8009bd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009c6:	89 d3                	mov    %edx,%ebx
  8009c8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ca:	eb 0f                	jmp    8009db <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  8009cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d3:	89 3c 24             	mov    %edi,(%esp)
  8009d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d8:	83 eb 01             	sub    $0x1,%ebx
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	7f ed                	jg     8009cc <cvprintfmt+0x1d9>
  8009df:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8009e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009eb:	85 d2                	test   %edx,%edx
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f2:	0f 49 c2             	cmovns %edx,%eax
  8009f5:	29 c2                	sub    %eax,%edx
  8009f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  8009fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009fd:	83 c8 3f             	or     $0x3f,%eax
  800a00:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a03:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a06:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800a09:	eb 36                	jmp    800a41 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a0b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a0f:	74 1d                	je     800a2e <cvprintfmt+0x23b>
  800a11:	0f be d2             	movsbl %dl,%edx
  800a14:	83 ea 20             	sub    $0x20,%edx
  800a17:	83 fa 5e             	cmp    $0x5e,%edx
  800a1a:	76 12                	jbe    800a2e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a23:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a26:	89 04 24             	mov    %eax,(%esp)
  800a29:	ff 55 08             	call   *0x8(%ebp)
  800a2c:	eb 10                	jmp    800a3e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a31:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a35:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a38:	89 04 24             	mov    %eax,(%esp)
  800a3b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3e:	83 eb 01             	sub    $0x1,%ebx
  800a41:	83 c7 01             	add    $0x1,%edi
  800a44:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a48:	0f be c2             	movsbl %dl,%eax
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	74 27                	je     800a76 <cvprintfmt+0x283>
  800a4f:	85 f6                	test   %esi,%esi
  800a51:	78 b8                	js     800a0b <cvprintfmt+0x218>
  800a53:	83 ee 01             	sub    $0x1,%esi
  800a56:	79 b3                	jns    800a0b <cvprintfmt+0x218>
  800a58:	89 d8                	mov    %ebx,%eax
  800a5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a60:	89 c3                	mov    %eax,%ebx
  800a62:	eb 18                	jmp    800a7c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800a64:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a6f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800a71:	83 eb 01             	sub    $0x1,%ebx
  800a74:	eb 06                	jmp    800a7c <cvprintfmt+0x289>
  800a76:	8b 75 08             	mov    0x8(%ebp),%esi
  800a79:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	7f e4                	jg     800a64 <cvprintfmt+0x271>
  800a80:	89 75 08             	mov    %esi,0x8(%ebp)
  800a83:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a89:	e9 a7 fd ff ff       	jmp    800835 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8e:	83 fa 01             	cmp    $0x1,%edx
  800a91:	7e 10                	jle    800aa3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800a93:	8b 45 14             	mov    0x14(%ebp),%eax
  800a96:	8d 50 08             	lea    0x8(%eax),%edx
  800a99:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9c:	8b 30                	mov    (%eax),%esi
  800a9e:	8b 78 04             	mov    0x4(%eax),%edi
  800aa1:	eb 26                	jmp    800ac9 <cvprintfmt+0x2d6>
	else if (lflag)
  800aa3:	85 d2                	test   %edx,%edx
  800aa5:	74 12                	je     800ab9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800aa7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaa:	8d 50 04             	lea    0x4(%eax),%edx
  800aad:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab0:	8b 30                	mov    (%eax),%esi
  800ab2:	89 f7                	mov    %esi,%edi
  800ab4:	c1 ff 1f             	sar    $0x1f,%edi
  800ab7:	eb 10                	jmp    800ac9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800ab9:	8b 45 14             	mov    0x14(%ebp),%eax
  800abc:	8d 50 04             	lea    0x4(%eax),%edx
  800abf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac2:	8b 30                	mov    (%eax),%esi
  800ac4:	89 f7                	mov    %esi,%edi
  800ac6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ac9:	89 f0                	mov    %esi,%eax
  800acb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800acd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ad2:	85 ff                	test   %edi,%edi
  800ad4:	0f 89 8e 00 00 00    	jns    800b68 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ae4:	83 c8 2d             	or     $0x2d,%eax
  800ae7:	89 04 24             	mov    %eax,(%esp)
  800aea:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aed:	89 f0                	mov    %esi,%eax
  800aef:	89 fa                	mov    %edi,%edx
  800af1:	f7 d8                	neg    %eax
  800af3:	83 d2 00             	adc    $0x0,%edx
  800af6:	f7 da                	neg    %edx
			}
			base = 10;
  800af8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800afd:	eb 69                	jmp    800b68 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800aff:	8d 45 14             	lea    0x14(%ebp),%eax
  800b02:	e8 99 f8 ff ff       	call   8003a0 <getuint>
			base = 10;
  800b07:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b0c:	eb 5a                	jmp    800b68 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b0e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b11:	e8 8a f8 ff ff       	call   8003a0 <getuint>
			base = 8 ;
  800b16:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800b1b:	eb 4b                	jmp    800b68 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b24:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800b27:	89 f0                	mov    %esi,%eax
  800b29:	83 c8 30             	or     $0x30,%eax
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b39:	89 f0                	mov    %esi,%eax
  800b3b:	83 c8 78             	or     $0x78,%eax
  800b3e:	89 04 24             	mov    %eax,(%esp)
  800b41:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b44:	8b 45 14             	mov    0x14(%ebp),%eax
  800b47:	8d 50 04             	lea    0x4(%eax),%edx
  800b4a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800b4d:	8b 00                	mov    (%eax),%eax
  800b4f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b54:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b59:	eb 0d                	jmp    800b68 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5e:	e8 3d f8 ff ff       	call   8003a0 <getuint>
			base = 16;
  800b63:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800b68:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800b6c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b70:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800b73:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b77:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b7b:	89 04 24             	mov    %eax,(%esp)
  800b7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b85:	8b 55 08             	mov    0x8(%ebp),%edx
  800b88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b8b:	e8 0f f7 ff ff       	call   80029f <cprintnum>
			break;
  800b90:	e9 a0 fc ff ff       	jmp    800835 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800b95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b98:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b9c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b9f:	89 04 24             	mov    %eax,(%esp)
  800ba2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ba5:	e9 8b fc ff ff       	jmp    800835 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800bb4:	89 04 24             	mov    %eax,(%esp)
  800bb7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bba:	89 fb                	mov    %edi,%ebx
  800bbc:	eb 03                	jmp    800bc1 <cvprintfmt+0x3ce>
  800bbe:	83 eb 01             	sub    $0x1,%ebx
  800bc1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800bc5:	75 f7                	jne    800bbe <cvprintfmt+0x3cb>
  800bc7:	e9 69 fc ff ff       	jmp    800835 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800bcc:	83 c4 3c             	add    $0x3c,%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800bda:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800bdd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be1:	8b 45 10             	mov    0x10(%ebp),%eax
  800be4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	89 04 24             	mov    %eax,(%esp)
  800bf5:	e8 f9 fb ff ff       	call   8007f3 <cvprintfmt>
	va_end(ap);
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 28             	sub    $0x28,%esp
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c08:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c0b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c0f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	74 30                	je     800c4d <vsnprintf+0x51>
  800c1d:	85 d2                	test   %edx,%edx
  800c1f:	7e 2c                	jle    800c4d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c21:	8b 45 14             	mov    0x14(%ebp),%eax
  800c24:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c28:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c36:	c7 04 24 da 03 80 00 	movl   $0x8003da,(%esp)
  800c3d:	e8 dd f7 ff ff       	call   80041f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c45:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4b:	eb 05                	jmp    800c52 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c5a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c61:	8b 45 10             	mov    0x10(%ebp),%eax
  800c64:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	89 04 24             	mov    %eax,(%esp)
  800c75:	e8 82 ff ff ff       	call   800bfc <vsnprintf>
	va_end(ap);

	return rc;
}
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    
  800c7c:	66 90                	xchg   %ax,%ax
  800c7e:	66 90                	xchg   %ax,%ax

00800c80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c86:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8b:	eb 03                	jmp    800c90 <strlen+0x10>
		n++;
  800c8d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c90:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c94:	75 f7                	jne    800c8d <strlen+0xd>
		n++;
	return n;
}
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca6:	eb 03                	jmp    800cab <strnlen+0x13>
		n++;
  800ca8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cab:	39 d0                	cmp    %edx,%eax
  800cad:	74 06                	je     800cb5 <strnlen+0x1d>
  800caf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800cb3:	75 f3                	jne    800ca8 <strnlen+0x10>
		n++;
	return n;
}
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	53                   	push   %ebx
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cc1:	89 c2                	mov    %eax,%edx
  800cc3:	83 c2 01             	add    $0x1,%edx
  800cc6:	83 c1 01             	add    $0x1,%ecx
  800cc9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ccd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cd0:	84 db                	test   %bl,%bl
  800cd2:	75 ef                	jne    800cc3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 08             	sub    $0x8,%esp
  800cde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ce1:	89 1c 24             	mov    %ebx,(%esp)
  800ce4:	e8 97 ff ff ff       	call   800c80 <strlen>
	strcpy(dst + len, src);
  800ce9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cec:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cf0:	01 d8                	add    %ebx,%eax
  800cf2:	89 04 24             	mov    %eax,(%esp)
  800cf5:	e8 bd ff ff ff       	call   800cb7 <strcpy>
	return dst;
}
  800cfa:	89 d8                	mov    %ebx,%eax
  800cfc:	83 c4 08             	add    $0x8,%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	8b 75 08             	mov    0x8(%ebp),%esi
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	89 f3                	mov    %esi,%ebx
  800d0f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d12:	89 f2                	mov    %esi,%edx
  800d14:	eb 0f                	jmp    800d25 <strncpy+0x23>
		*dst++ = *src;
  800d16:	83 c2 01             	add    $0x1,%edx
  800d19:	0f b6 01             	movzbl (%ecx),%eax
  800d1c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d1f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d22:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d25:	39 da                	cmp    %ebx,%edx
  800d27:	75 ed                	jne    800d16 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d29:	89 f0                	mov    %esi,%eax
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	8b 75 08             	mov    0x8(%ebp),%esi
  800d37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d3d:	89 f0                	mov    %esi,%eax
  800d3f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d43:	85 c9                	test   %ecx,%ecx
  800d45:	75 0b                	jne    800d52 <strlcpy+0x23>
  800d47:	eb 1d                	jmp    800d66 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d49:	83 c0 01             	add    $0x1,%eax
  800d4c:	83 c2 01             	add    $0x1,%edx
  800d4f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d52:	39 d8                	cmp    %ebx,%eax
  800d54:	74 0b                	je     800d61 <strlcpy+0x32>
  800d56:	0f b6 0a             	movzbl (%edx),%ecx
  800d59:	84 c9                	test   %cl,%cl
  800d5b:	75 ec                	jne    800d49 <strlcpy+0x1a>
  800d5d:	89 c2                	mov    %eax,%edx
  800d5f:	eb 02                	jmp    800d63 <strlcpy+0x34>
  800d61:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d63:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d66:	29 f0                	sub    %esi,%eax
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d72:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d75:	eb 06                	jmp    800d7d <strcmp+0x11>
		p++, q++;
  800d77:	83 c1 01             	add    $0x1,%ecx
  800d7a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d7d:	0f b6 01             	movzbl (%ecx),%eax
  800d80:	84 c0                	test   %al,%al
  800d82:	74 04                	je     800d88 <strcmp+0x1c>
  800d84:	3a 02                	cmp    (%edx),%al
  800d86:	74 ef                	je     800d77 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d88:	0f b6 c0             	movzbl %al,%eax
  800d8b:	0f b6 12             	movzbl (%edx),%edx
  800d8e:	29 d0                	sub    %edx,%eax
}
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	53                   	push   %ebx
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9c:	89 c3                	mov    %eax,%ebx
  800d9e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800da1:	eb 06                	jmp    800da9 <strncmp+0x17>
		n--, p++, q++;
  800da3:	83 c0 01             	add    $0x1,%eax
  800da6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800da9:	39 d8                	cmp    %ebx,%eax
  800dab:	74 15                	je     800dc2 <strncmp+0x30>
  800dad:	0f b6 08             	movzbl (%eax),%ecx
  800db0:	84 c9                	test   %cl,%cl
  800db2:	74 04                	je     800db8 <strncmp+0x26>
  800db4:	3a 0a                	cmp    (%edx),%cl
  800db6:	74 eb                	je     800da3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800db8:	0f b6 00             	movzbl (%eax),%eax
  800dbb:	0f b6 12             	movzbl (%edx),%edx
  800dbe:	29 d0                	sub    %edx,%eax
  800dc0:	eb 05                	jmp    800dc7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dd4:	eb 07                	jmp    800ddd <strchr+0x13>
		if (*s == c)
  800dd6:	38 ca                	cmp    %cl,%dl
  800dd8:	74 0f                	je     800de9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dda:	83 c0 01             	add    $0x1,%eax
  800ddd:	0f b6 10             	movzbl (%eax),%edx
  800de0:	84 d2                	test   %dl,%dl
  800de2:	75 f2                	jne    800dd6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800de4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df5:	eb 07                	jmp    800dfe <strfind+0x13>
		if (*s == c)
  800df7:	38 ca                	cmp    %cl,%dl
  800df9:	74 0a                	je     800e05 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800dfb:	83 c0 01             	add    $0x1,%eax
  800dfe:	0f b6 10             	movzbl (%eax),%edx
  800e01:	84 d2                	test   %dl,%dl
  800e03:	75 f2                	jne    800df7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e13:	85 c9                	test   %ecx,%ecx
  800e15:	74 36                	je     800e4d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e17:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e1d:	75 28                	jne    800e47 <memset+0x40>
  800e1f:	f6 c1 03             	test   $0x3,%cl
  800e22:	75 23                	jne    800e47 <memset+0x40>
		c &= 0xFF;
  800e24:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e28:	89 d3                	mov    %edx,%ebx
  800e2a:	c1 e3 08             	shl    $0x8,%ebx
  800e2d:	89 d6                	mov    %edx,%esi
  800e2f:	c1 e6 18             	shl    $0x18,%esi
  800e32:	89 d0                	mov    %edx,%eax
  800e34:	c1 e0 10             	shl    $0x10,%eax
  800e37:	09 f0                	or     %esi,%eax
  800e39:	09 c2                	or     %eax,%edx
  800e3b:	89 d0                	mov    %edx,%eax
  800e3d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e3f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e42:	fc                   	cld    
  800e43:	f3 ab                	rep stos %eax,%es:(%edi)
  800e45:	eb 06                	jmp    800e4d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	fc                   	cld    
  800e4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e4d:	89 f8                	mov    %edi,%eax
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e62:	39 c6                	cmp    %eax,%esi
  800e64:	73 35                	jae    800e9b <memmove+0x47>
  800e66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e69:	39 d0                	cmp    %edx,%eax
  800e6b:	73 2e                	jae    800e9b <memmove+0x47>
		s += n;
		d += n;
  800e6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800e70:	89 d6                	mov    %edx,%esi
  800e72:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e74:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e7a:	75 13                	jne    800e8f <memmove+0x3b>
  800e7c:	f6 c1 03             	test   $0x3,%cl
  800e7f:	75 0e                	jne    800e8f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e81:	83 ef 04             	sub    $0x4,%edi
  800e84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e87:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e8a:	fd                   	std    
  800e8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e8d:	eb 09                	jmp    800e98 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e8f:	83 ef 01             	sub    $0x1,%edi
  800e92:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e95:	fd                   	std    
  800e96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e98:	fc                   	cld    
  800e99:	eb 1d                	jmp    800eb8 <memmove+0x64>
  800e9b:	89 f2                	mov    %esi,%edx
  800e9d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e9f:	f6 c2 03             	test   $0x3,%dl
  800ea2:	75 0f                	jne    800eb3 <memmove+0x5f>
  800ea4:	f6 c1 03             	test   $0x3,%cl
  800ea7:	75 0a                	jne    800eb3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ea9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800eac:	89 c7                	mov    %eax,%edi
  800eae:	fc                   	cld    
  800eaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eb1:	eb 05                	jmp    800eb8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800eb3:	89 c7                	mov    %eax,%edi
  800eb5:	fc                   	cld    
  800eb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ec2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	89 04 24             	mov    %eax,(%esp)
  800ed6:	e8 79 ff ff ff       	call   800e54 <memmove>
}
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee8:	89 d6                	mov    %edx,%esi
  800eea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eed:	eb 1a                	jmp    800f09 <memcmp+0x2c>
		if (*s1 != *s2)
  800eef:	0f b6 02             	movzbl (%edx),%eax
  800ef2:	0f b6 19             	movzbl (%ecx),%ebx
  800ef5:	38 d8                	cmp    %bl,%al
  800ef7:	74 0a                	je     800f03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ef9:	0f b6 c0             	movzbl %al,%eax
  800efc:	0f b6 db             	movzbl %bl,%ebx
  800eff:	29 d8                	sub    %ebx,%eax
  800f01:	eb 0f                	jmp    800f12 <memcmp+0x35>
		s1++, s2++;
  800f03:	83 c2 01             	add    $0x1,%edx
  800f06:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f09:	39 f2                	cmp    %esi,%edx
  800f0b:	75 e2                	jne    800eef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f1f:	89 c2                	mov    %eax,%edx
  800f21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f24:	eb 07                	jmp    800f2d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f26:	38 08                	cmp    %cl,(%eax)
  800f28:	74 07                	je     800f31 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f2a:	83 c0 01             	add    $0x1,%eax
  800f2d:	39 d0                	cmp    %edx,%eax
  800f2f:	72 f5                	jb     800f26 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f3f:	eb 03                	jmp    800f44 <strtol+0x11>
		s++;
  800f41:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f44:	0f b6 0a             	movzbl (%edx),%ecx
  800f47:	80 f9 09             	cmp    $0x9,%cl
  800f4a:	74 f5                	je     800f41 <strtol+0xe>
  800f4c:	80 f9 20             	cmp    $0x20,%cl
  800f4f:	74 f0                	je     800f41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f51:	80 f9 2b             	cmp    $0x2b,%cl
  800f54:	75 0a                	jne    800f60 <strtol+0x2d>
		s++;
  800f56:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f59:	bf 00 00 00 00       	mov    $0x0,%edi
  800f5e:	eb 11                	jmp    800f71 <strtol+0x3e>
  800f60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f65:	80 f9 2d             	cmp    $0x2d,%cl
  800f68:	75 07                	jne    800f71 <strtol+0x3e>
		s++, neg = 1;
  800f6a:	8d 52 01             	lea    0x1(%edx),%edx
  800f6d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f71:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800f76:	75 15                	jne    800f8d <strtol+0x5a>
  800f78:	80 3a 30             	cmpb   $0x30,(%edx)
  800f7b:	75 10                	jne    800f8d <strtol+0x5a>
  800f7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f81:	75 0a                	jne    800f8d <strtol+0x5a>
		s += 2, base = 16;
  800f83:	83 c2 02             	add    $0x2,%edx
  800f86:	b8 10 00 00 00       	mov    $0x10,%eax
  800f8b:	eb 10                	jmp    800f9d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	75 0c                	jne    800f9d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f91:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f93:	80 3a 30             	cmpb   $0x30,(%edx)
  800f96:	75 05                	jne    800f9d <strtol+0x6a>
		s++, base = 8;
  800f98:	83 c2 01             	add    $0x1,%edx
  800f9b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800f9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fa5:	0f b6 0a             	movzbl (%edx),%ecx
  800fa8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800fab:	89 f0                	mov    %esi,%eax
  800fad:	3c 09                	cmp    $0x9,%al
  800faf:	77 08                	ja     800fb9 <strtol+0x86>
			dig = *s - '0';
  800fb1:	0f be c9             	movsbl %cl,%ecx
  800fb4:	83 e9 30             	sub    $0x30,%ecx
  800fb7:	eb 20                	jmp    800fd9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800fb9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800fbc:	89 f0                	mov    %esi,%eax
  800fbe:	3c 19                	cmp    $0x19,%al
  800fc0:	77 08                	ja     800fca <strtol+0x97>
			dig = *s - 'a' + 10;
  800fc2:	0f be c9             	movsbl %cl,%ecx
  800fc5:	83 e9 57             	sub    $0x57,%ecx
  800fc8:	eb 0f                	jmp    800fd9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800fca:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800fcd:	89 f0                	mov    %esi,%eax
  800fcf:	3c 19                	cmp    $0x19,%al
  800fd1:	77 16                	ja     800fe9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800fd3:	0f be c9             	movsbl %cl,%ecx
  800fd6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fd9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800fdc:	7d 0f                	jge    800fed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800fde:	83 c2 01             	add    $0x1,%edx
  800fe1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800fe5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800fe7:	eb bc                	jmp    800fa5 <strtol+0x72>
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	eb 02                	jmp    800fef <strtol+0xbc>
  800fed:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800fef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ff3:	74 05                	je     800ffa <strtol+0xc7>
		*endptr = (char *) s;
  800ff5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ff8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800ffa:	f7 d8                	neg    %eax
  800ffc:	85 ff                	test   %edi,%edi
  800ffe:	0f 44 c3             	cmove  %ebx,%eax
}
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100c:	b8 00 00 00 00       	mov    $0x0,%eax
  801011:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801014:	8b 55 08             	mov    0x8(%ebp),%edx
  801017:	89 c3                	mov    %eax,%ebx
  801019:	89 c7                	mov    %eax,%edi
  80101b:	89 c6                	mov    %eax,%esi
  80101d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80101f:	5b                   	pop    %ebx
  801020:	5e                   	pop    %esi
  801021:	5f                   	pop    %edi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <sys_cgetc>:

int
sys_cgetc(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102a:	ba 00 00 00 00       	mov    $0x0,%edx
  80102f:	b8 01 00 00 00       	mov    $0x1,%eax
  801034:	89 d1                	mov    %edx,%ecx
  801036:	89 d3                	mov    %edx,%ebx
  801038:	89 d7                	mov    %edx,%edi
  80103a:	89 d6                	mov    %edx,%esi
  80103c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801051:	b8 03 00 00 00       	mov    $0x3,%eax
  801056:	8b 55 08             	mov    0x8(%ebp),%edx
  801059:	89 cb                	mov    %ecx,%ebx
  80105b:	89 cf                	mov    %ecx,%edi
  80105d:	89 ce                	mov    %ecx,%esi
  80105f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801061:	85 c0                	test   %eax,%eax
  801063:	7e 28                	jle    80108d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801065:	89 44 24 10          	mov    %eax,0x10(%esp)
  801069:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801070:	00 
  801071:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801078:	00 
  801079:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801080:	00 
  801081:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  801088:	e8 cc 02 00 00       	call   801359 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80108d:	83 c4 2c             	add    $0x2c,%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109b:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8010a5:	89 d1                	mov    %edx,%ecx
  8010a7:	89 d3                	mov    %edx,%ebx
  8010a9:	89 d7                	mov    %edx,%edi
  8010ab:	89 d6                	mov    %edx,%esi
  8010ad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_yield>:

void
sys_yield(void)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010c4:	89 d1                	mov    %edx,%ecx
  8010c6:	89 d3                	mov    %edx,%ebx
  8010c8:	89 d7                	mov    %edx,%edi
  8010ca:	89 d6                	mov    %edx,%esi
  8010cc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010dc:	be 00 00 00 00       	mov    $0x0,%esi
  8010e1:	b8 04 00 00 00       	mov    $0x4,%eax
  8010e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ef:	89 f7                	mov    %esi,%edi
  8010f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	7e 28                	jle    80111f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010fb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801102:	00 
  801103:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  80110a:	00 
  80110b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801112:	00 
  801113:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  80111a:	e8 3a 02 00 00       	call   801359 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80111f:	83 c4 2c             	add    $0x2c,%esp
  801122:	5b                   	pop    %ebx
  801123:	5e                   	pop    %esi
  801124:	5f                   	pop    %edi
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	57                   	push   %edi
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
  80112d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801130:	b8 05 00 00 00       	mov    $0x5,%eax
  801135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801138:	8b 55 08             	mov    0x8(%ebp),%edx
  80113b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80113e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801141:	8b 75 18             	mov    0x18(%ebp),%esi
  801144:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801146:	85 c0                	test   %eax,%eax
  801148:	7e 28                	jle    801172 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801155:	00 
  801156:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  80115d:	00 
  80115e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801165:	00 
  801166:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  80116d:	e8 e7 01 00 00       	call   801359 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801172:	83 c4 2c             	add    $0x2c,%esp
  801175:	5b                   	pop    %ebx
  801176:	5e                   	pop    %esi
  801177:	5f                   	pop    %edi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801183:	bb 00 00 00 00       	mov    $0x0,%ebx
  801188:	b8 06 00 00 00       	mov    $0x6,%eax
  80118d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801190:	8b 55 08             	mov    0x8(%ebp),%edx
  801193:	89 df                	mov    %ebx,%edi
  801195:	89 de                	mov    %ebx,%esi
  801197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801199:	85 c0                	test   %eax,%eax
  80119b:	7e 28                	jle    8011c5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011a8:	00 
  8011a9:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  8011b0:	00 
  8011b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b8:	00 
  8011b9:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  8011c0:	e8 94 01 00 00       	call   801359 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011c5:	83 c4 2c             	add    $0x2c,%esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	57                   	push   %edi
  8011d1:	56                   	push   %esi
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011db:	b8 08 00 00 00       	mov    $0x8,%eax
  8011e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e6:	89 df                	mov    %ebx,%edi
  8011e8:	89 de                	mov    %ebx,%esi
  8011ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	7e 28                	jle    801218 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8011fb:	00 
  8011fc:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801203:	00 
  801204:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80120b:	00 
  80120c:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  801213:	e8 41 01 00 00       	call   801359 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801218:	83 c4 2c             	add    $0x2c,%esp
  80121b:	5b                   	pop    %ebx
  80121c:	5e                   	pop    %esi
  80121d:	5f                   	pop    %edi
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122e:	b8 09 00 00 00       	mov    $0x9,%eax
  801233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801236:	8b 55 08             	mov    0x8(%ebp),%edx
  801239:	89 df                	mov    %ebx,%edi
  80123b:	89 de                	mov    %ebx,%esi
  80123d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80123f:	85 c0                	test   %eax,%eax
  801241:	7e 28                	jle    80126b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801243:	89 44 24 10          	mov    %eax,0x10(%esp)
  801247:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80124e:	00 
  80124f:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801256:	00 
  801257:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80125e:	00 
  80125f:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  801266:	e8 ee 00 00 00       	call   801359 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80126b:	83 c4 2c             	add    $0x2c,%esp
  80126e:	5b                   	pop    %ebx
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	57                   	push   %edi
  801277:	56                   	push   %esi
  801278:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801279:	be 00 00 00 00       	mov    $0x0,%esi
  80127e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801283:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801286:	8b 55 08             	mov    0x8(%ebp),%edx
  801289:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80128f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801291:	5b                   	pop    %ebx
  801292:	5e                   	pop    %esi
  801293:	5f                   	pop    %edi
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	57                   	push   %edi
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
  80129c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ac:	89 cb                	mov    %ecx,%ebx
  8012ae:	89 cf                	mov    %ecx,%edi
  8012b0:	89 ce                	mov    %ecx,%esi
  8012b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	7e 28                	jle    8012e0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012bc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8012c3:	00 
  8012c4:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d3:	00 
  8012d4:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  8012db:	e8 79 00 00 00       	call   801359 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012e0:	83 c4 2c             	add    $0x2c,%esp
  8012e3:	5b                   	pop    %ebx
  8012e4:	5e                   	pop    %esi
  8012e5:	5f                   	pop    %edi
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012ee:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8012f5:	75 32                	jne    801329 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  8012f7:	e8 99 fd ff ff       	call   801095 <sys_getenvid>
  8012fc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801303:	00 
  801304:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80130b:	ee 
  80130c:	89 04 24             	mov    %eax,(%esp)
  80130f:	e8 bf fd ff ff       	call   8010d3 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  801314:	e8 7c fd ff ff       	call   801095 <sys_getenvid>
  801319:	c7 44 24 04 33 13 80 	movl   $0x801333,0x4(%esp)
  801320:	00 
  801321:	89 04 24             	mov    %eax,(%esp)
  801324:	e8 f7 fe ff ff       	call   801220 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801333:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801334:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801339:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80133b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  80133e:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  801341:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  801345:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  801349:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  80134c:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  801350:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  801352:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  801353:	83 c4 04             	add    $0x4,%esp
	popfl 	
  801356:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801357:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801358:	c3                   	ret    

00801359 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	56                   	push   %esi
  80135d:	53                   	push   %ebx
  80135e:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801361:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801364:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80136a:	e8 26 fd ff ff       	call   801095 <sys_getenvid>
  80136f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801372:	89 54 24 10          	mov    %edx,0x10(%esp)
  801376:	8b 55 08             	mov    0x8(%ebp),%edx
  801379:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80137d:	89 74 24 08          	mov    %esi,0x8(%esp)
  801381:	89 44 24 04          	mov    %eax,0x4(%esp)
  801385:	c7 04 24 34 1a 80 00 	movl   $0x801a34,(%esp)
  80138c:	e8 04 ee ff ff       	call   800195 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801391:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801395:	8b 45 10             	mov    0x10(%ebp),%eax
  801398:	89 04 24             	mov    %eax,(%esp)
  80139b:	e8 94 ed ff ff       	call   800134 <vcprintf>
	cprintf("\n");
  8013a0:	c7 04 24 5a 16 80 00 	movl   $0x80165a,(%esp)
  8013a7:	e8 e9 ed ff ff       	call   800195 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013ac:	cc                   	int3   
  8013ad:	eb fd                	jmp    8013ac <_panic+0x53>
  8013af:	90                   	nop

008013b0 <__udivdi3>:
  8013b0:	55                   	push   %ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013cc:	89 ea                	mov    %ebp,%edx
  8013ce:	89 0c 24             	mov    %ecx,(%esp)
  8013d1:	75 2d                	jne    801400 <__udivdi3+0x50>
  8013d3:	39 e9                	cmp    %ebp,%ecx
  8013d5:	77 61                	ja     801438 <__udivdi3+0x88>
  8013d7:	85 c9                	test   %ecx,%ecx
  8013d9:	89 ce                	mov    %ecx,%esi
  8013db:	75 0b                	jne    8013e8 <__udivdi3+0x38>
  8013dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e2:	31 d2                	xor    %edx,%edx
  8013e4:	f7 f1                	div    %ecx
  8013e6:	89 c6                	mov    %eax,%esi
  8013e8:	31 d2                	xor    %edx,%edx
  8013ea:	89 e8                	mov    %ebp,%eax
  8013ec:	f7 f6                	div    %esi
  8013ee:	89 c5                	mov    %eax,%ebp
  8013f0:	89 f8                	mov    %edi,%eax
  8013f2:	f7 f6                	div    %esi
  8013f4:	89 ea                	mov    %ebp,%edx
  8013f6:	83 c4 0c             	add    $0xc,%esp
  8013f9:	5e                   	pop    %esi
  8013fa:	5f                   	pop    %edi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    
  8013fd:	8d 76 00             	lea    0x0(%esi),%esi
  801400:	39 e8                	cmp    %ebp,%eax
  801402:	77 24                	ja     801428 <__udivdi3+0x78>
  801404:	0f bd e8             	bsr    %eax,%ebp
  801407:	83 f5 1f             	xor    $0x1f,%ebp
  80140a:	75 3c                	jne    801448 <__udivdi3+0x98>
  80140c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801410:	39 34 24             	cmp    %esi,(%esp)
  801413:	0f 86 9f 00 00 00    	jbe    8014b8 <__udivdi3+0x108>
  801419:	39 d0                	cmp    %edx,%eax
  80141b:	0f 82 97 00 00 00    	jb     8014b8 <__udivdi3+0x108>
  801421:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801428:	31 d2                	xor    %edx,%edx
  80142a:	31 c0                	xor    %eax,%eax
  80142c:	83 c4 0c             	add    $0xc,%esp
  80142f:	5e                   	pop    %esi
  801430:	5f                   	pop    %edi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    
  801433:	90                   	nop
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	89 f8                	mov    %edi,%eax
  80143a:	f7 f1                	div    %ecx
  80143c:	31 d2                	xor    %edx,%edx
  80143e:	83 c4 0c             	add    $0xc,%esp
  801441:	5e                   	pop    %esi
  801442:	5f                   	pop    %edi
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    
  801445:	8d 76 00             	lea    0x0(%esi),%esi
  801448:	89 e9                	mov    %ebp,%ecx
  80144a:	8b 3c 24             	mov    (%esp),%edi
  80144d:	d3 e0                	shl    %cl,%eax
  80144f:	89 c6                	mov    %eax,%esi
  801451:	b8 20 00 00 00       	mov    $0x20,%eax
  801456:	29 e8                	sub    %ebp,%eax
  801458:	89 c1                	mov    %eax,%ecx
  80145a:	d3 ef                	shr    %cl,%edi
  80145c:	89 e9                	mov    %ebp,%ecx
  80145e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801462:	8b 3c 24             	mov    (%esp),%edi
  801465:	09 74 24 08          	or     %esi,0x8(%esp)
  801469:	89 d6                	mov    %edx,%esi
  80146b:	d3 e7                	shl    %cl,%edi
  80146d:	89 c1                	mov    %eax,%ecx
  80146f:	89 3c 24             	mov    %edi,(%esp)
  801472:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801476:	d3 ee                	shr    %cl,%esi
  801478:	89 e9                	mov    %ebp,%ecx
  80147a:	d3 e2                	shl    %cl,%edx
  80147c:	89 c1                	mov    %eax,%ecx
  80147e:	d3 ef                	shr    %cl,%edi
  801480:	09 d7                	or     %edx,%edi
  801482:	89 f2                	mov    %esi,%edx
  801484:	89 f8                	mov    %edi,%eax
  801486:	f7 74 24 08          	divl   0x8(%esp)
  80148a:	89 d6                	mov    %edx,%esi
  80148c:	89 c7                	mov    %eax,%edi
  80148e:	f7 24 24             	mull   (%esp)
  801491:	39 d6                	cmp    %edx,%esi
  801493:	89 14 24             	mov    %edx,(%esp)
  801496:	72 30                	jb     8014c8 <__udivdi3+0x118>
  801498:	8b 54 24 04          	mov    0x4(%esp),%edx
  80149c:	89 e9                	mov    %ebp,%ecx
  80149e:	d3 e2                	shl    %cl,%edx
  8014a0:	39 c2                	cmp    %eax,%edx
  8014a2:	73 05                	jae    8014a9 <__udivdi3+0xf9>
  8014a4:	3b 34 24             	cmp    (%esp),%esi
  8014a7:	74 1f                	je     8014c8 <__udivdi3+0x118>
  8014a9:	89 f8                	mov    %edi,%eax
  8014ab:	31 d2                	xor    %edx,%edx
  8014ad:	e9 7a ff ff ff       	jmp    80142c <__udivdi3+0x7c>
  8014b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014b8:	31 d2                	xor    %edx,%edx
  8014ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8014bf:	e9 68 ff ff ff       	jmp    80142c <__udivdi3+0x7c>
  8014c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	83 c4 0c             	add    $0xc,%esp
  8014d0:	5e                   	pop    %esi
  8014d1:	5f                   	pop    %edi
  8014d2:	5d                   	pop    %ebp
  8014d3:	c3                   	ret    
  8014d4:	66 90                	xchg   %ax,%ax
  8014d6:	66 90                	xchg   %ax,%ax
  8014d8:	66 90                	xchg   %ax,%ax
  8014da:	66 90                	xchg   %ax,%ax
  8014dc:	66 90                	xchg   %ax,%ax
  8014de:	66 90                	xchg   %ax,%ax

008014e0 <__umoddi3>:
  8014e0:	55                   	push   %ebp
  8014e1:	57                   	push   %edi
  8014e2:	56                   	push   %esi
  8014e3:	83 ec 14             	sub    $0x14,%esp
  8014e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014f2:	89 c7                	mov    %eax,%edi
  8014f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801500:	89 34 24             	mov    %esi,(%esp)
  801503:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801507:	85 c0                	test   %eax,%eax
  801509:	89 c2                	mov    %eax,%edx
  80150b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80150f:	75 17                	jne    801528 <__umoddi3+0x48>
  801511:	39 fe                	cmp    %edi,%esi
  801513:	76 4b                	jbe    801560 <__umoddi3+0x80>
  801515:	89 c8                	mov    %ecx,%eax
  801517:	89 fa                	mov    %edi,%edx
  801519:	f7 f6                	div    %esi
  80151b:	89 d0                	mov    %edx,%eax
  80151d:	31 d2                	xor    %edx,%edx
  80151f:	83 c4 14             	add    $0x14,%esp
  801522:	5e                   	pop    %esi
  801523:	5f                   	pop    %edi
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    
  801526:	66 90                	xchg   %ax,%ax
  801528:	39 f8                	cmp    %edi,%eax
  80152a:	77 54                	ja     801580 <__umoddi3+0xa0>
  80152c:	0f bd e8             	bsr    %eax,%ebp
  80152f:	83 f5 1f             	xor    $0x1f,%ebp
  801532:	75 5c                	jne    801590 <__umoddi3+0xb0>
  801534:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801538:	39 3c 24             	cmp    %edi,(%esp)
  80153b:	0f 87 e7 00 00 00    	ja     801628 <__umoddi3+0x148>
  801541:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801545:	29 f1                	sub    %esi,%ecx
  801547:	19 c7                	sbb    %eax,%edi
  801549:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80154d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801551:	8b 44 24 08          	mov    0x8(%esp),%eax
  801555:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801559:	83 c4 14             	add    $0x14,%esp
  80155c:	5e                   	pop    %esi
  80155d:	5f                   	pop    %edi
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    
  801560:	85 f6                	test   %esi,%esi
  801562:	89 f5                	mov    %esi,%ebp
  801564:	75 0b                	jne    801571 <__umoddi3+0x91>
  801566:	b8 01 00 00 00       	mov    $0x1,%eax
  80156b:	31 d2                	xor    %edx,%edx
  80156d:	f7 f6                	div    %esi
  80156f:	89 c5                	mov    %eax,%ebp
  801571:	8b 44 24 04          	mov    0x4(%esp),%eax
  801575:	31 d2                	xor    %edx,%edx
  801577:	f7 f5                	div    %ebp
  801579:	89 c8                	mov    %ecx,%eax
  80157b:	f7 f5                	div    %ebp
  80157d:	eb 9c                	jmp    80151b <__umoddi3+0x3b>
  80157f:	90                   	nop
  801580:	89 c8                	mov    %ecx,%eax
  801582:	89 fa                	mov    %edi,%edx
  801584:	83 c4 14             	add    $0x14,%esp
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    
  80158b:	90                   	nop
  80158c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801590:	8b 04 24             	mov    (%esp),%eax
  801593:	be 20 00 00 00       	mov    $0x20,%esi
  801598:	89 e9                	mov    %ebp,%ecx
  80159a:	29 ee                	sub    %ebp,%esi
  80159c:	d3 e2                	shl    %cl,%edx
  80159e:	89 f1                	mov    %esi,%ecx
  8015a0:	d3 e8                	shr    %cl,%eax
  8015a2:	89 e9                	mov    %ebp,%ecx
  8015a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a8:	8b 04 24             	mov    (%esp),%eax
  8015ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8015af:	89 fa                	mov    %edi,%edx
  8015b1:	d3 e0                	shl    %cl,%eax
  8015b3:	89 f1                	mov    %esi,%ecx
  8015b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8015bd:	d3 ea                	shr    %cl,%edx
  8015bf:	89 e9                	mov    %ebp,%ecx
  8015c1:	d3 e7                	shl    %cl,%edi
  8015c3:	89 f1                	mov    %esi,%ecx
  8015c5:	d3 e8                	shr    %cl,%eax
  8015c7:	89 e9                	mov    %ebp,%ecx
  8015c9:	09 f8                	or     %edi,%eax
  8015cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015cf:	f7 74 24 04          	divl   0x4(%esp)
  8015d3:	d3 e7                	shl    %cl,%edi
  8015d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015d9:	89 d7                	mov    %edx,%edi
  8015db:	f7 64 24 08          	mull   0x8(%esp)
  8015df:	39 d7                	cmp    %edx,%edi
  8015e1:	89 c1                	mov    %eax,%ecx
  8015e3:	89 14 24             	mov    %edx,(%esp)
  8015e6:	72 2c                	jb     801614 <__umoddi3+0x134>
  8015e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8015ec:	72 22                	jb     801610 <__umoddi3+0x130>
  8015ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015f2:	29 c8                	sub    %ecx,%eax
  8015f4:	19 d7                	sbb    %edx,%edi
  8015f6:	89 e9                	mov    %ebp,%ecx
  8015f8:	89 fa                	mov    %edi,%edx
  8015fa:	d3 e8                	shr    %cl,%eax
  8015fc:	89 f1                	mov    %esi,%ecx
  8015fe:	d3 e2                	shl    %cl,%edx
  801600:	89 e9                	mov    %ebp,%ecx
  801602:	d3 ef                	shr    %cl,%edi
  801604:	09 d0                	or     %edx,%eax
  801606:	89 fa                	mov    %edi,%edx
  801608:	83 c4 14             	add    $0x14,%esp
  80160b:	5e                   	pop    %esi
  80160c:	5f                   	pop    %edi
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    
  80160f:	90                   	nop
  801610:	39 d7                	cmp    %edx,%edi
  801612:	75 da                	jne    8015ee <__umoddi3+0x10e>
  801614:	8b 14 24             	mov    (%esp),%edx
  801617:	89 c1                	mov    %eax,%ecx
  801619:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80161d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801621:	eb cb                	jmp    8015ee <__umoddi3+0x10e>
  801623:	90                   	nop
  801624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801628:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80162c:	0f 82 0f ff ff ff    	jb     801541 <__umoddi3+0x61>
  801632:	e9 1a ff ff ff       	jmp    801551 <__umoddi3+0x71>
