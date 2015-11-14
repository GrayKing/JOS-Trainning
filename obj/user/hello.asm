
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2e 00 00 00       	call   80005f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  800039:	c7 04 24 a0 15 80 00 	movl   $0x8015a0,(%esp)
  800040:	e8 1d 01 00 00       	call   800162 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800045:	a1 04 20 80 00       	mov    0x802004,%eax
  80004a:	8b 40 48             	mov    0x48(%eax),%eax
  80004d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800051:	c7 04 24 ae 15 80 00 	movl   $0x8015ae,(%esp)
  800058:	e8 05 01 00 00       	call   800162 <cprintf>
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	83 ec 10             	sub    $0x10,%esp
  800067:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80006d:	e8 f3 0f 00 00       	call   801065 <sys_getenvid>
  800072:	25 ff 03 00 00       	and    $0x3ff,%eax
  800077:	89 c2                	mov    %eax,%edx
  800079:	c1 e2 07             	shl    $0x7,%edx
  80007c:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	85 db                	test   %ebx,%ebx
  80008a:	7e 07                	jle    800093 <libmain+0x34>
		binaryname = argv[0];
  80008c:	8b 06                	mov    (%esi),%eax
  80008e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800093:	89 74 24 04          	mov    %esi,0x4(%esp)
  800097:	89 1c 24             	mov    %ebx,(%esp)
  80009a:	e8 94 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009f:	e8 07 00 00 00       	call   8000ab <exit>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b8:	e8 56 0f 00 00       	call   801013 <sys_env_destroy>
}
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 14             	sub    $0x14,%esp
  8000c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c9:	8b 13                	mov    (%ebx),%edx
  8000cb:	8d 42 01             	lea    0x1(%edx),%eax
  8000ce:	89 03                	mov    %eax,(%ebx)
  8000d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dc:	75 19                	jne    8000f7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000de:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e5:	00 
  8000e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e9:	89 04 24             	mov    %eax,(%esp)
  8000ec:	e8 e5 0e 00 00       	call   800fd6 <sys_cputs>
		b->idx = 0;
  8000f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	83 c4 14             	add    $0x14,%esp
  8000fe:	5b                   	pop    %ebx
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800111:	00 00 00 
	b.cnt = 0;
  800114:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800121:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800125:	8b 45 08             	mov    0x8(%ebp),%eax
  800128:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800132:	89 44 24 04          	mov    %eax,0x4(%esp)
  800136:	c7 04 24 bf 00 80 00 	movl   $0x8000bf,(%esp)
  80013d:	e8 ad 02 00 00       	call   8003ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800142:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800152:	89 04 24             	mov    %eax,(%esp)
  800155:	e8 7c 0e 00 00       	call   800fd6 <sys_cputs>

	return b.cnt;
}
  80015a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800168:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	89 04 24             	mov    %eax,(%esp)
  800175:	e8 87 ff ff ff       	call   800101 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    
  80017c:	66 90                	xchg   %ax,%ax
  80017e:	66 90                	xchg   %ax,%ax

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 c3                	mov    %eax,%ebx
  800199:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80019c:	8b 45 10             	mov    0x10(%ebp),%eax
  80019f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ad:	39 d9                	cmp    %ebx,%ecx
  8001af:	72 05                	jb     8001b6 <printnum+0x36>
  8001b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b4:	77 69                	ja     80021f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001bd:	83 ee 01             	sub    $0x1,%esi
  8001c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001d0:	89 c3                	mov    %eax,%ebx
  8001d2:	89 d6                	mov    %edx,%esi
  8001d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ef:	e8 1c 11 00 00       	call   801310 <__udivdi3>
  8001f4:	89 d9                	mov    %ebx,%ecx
  8001f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001fe:	89 04 24             	mov    %eax,(%esp)
  800201:	89 54 24 04          	mov    %edx,0x4(%esp)
  800205:	89 fa                	mov    %edi,%edx
  800207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020a:	e8 71 ff ff ff       	call   800180 <printnum>
  80020f:	eb 1b                	jmp    80022c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800215:	8b 45 18             	mov    0x18(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	ff d3                	call   *%ebx
  80021d:	eb 03                	jmp    800222 <printnum+0xa2>
  80021f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800222:	83 ee 01             	sub    $0x1,%esi
  800225:	85 f6                	test   %esi,%esi
  800227:	7f e8                	jg     800211 <printnum+0x91>
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800230:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800234:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800237:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80023a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 ec 11 00 00       	call   801440 <__umoddi3>
  800254:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800258:	0f be 80 cf 15 80 00 	movsbl 0x8015cf(%eax),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800265:	ff d0                	call   *%eax
}
  800267:	83 c4 3c             	add    $0x3c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 3c             	sub    $0x3c,%esp
  800278:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80027b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80027e:	89 cf                	mov    %ecx,%edi
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800286:	8b 45 0c             	mov    0xc(%ebp),%eax
  800289:	89 c3                	mov    %eax,%ebx
  80028b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80028e:	8b 45 10             	mov    0x10(%ebp),%eax
  800291:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800294:	b9 00 00 00 00       	mov    $0x0,%ecx
  800299:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80029f:	39 d9                	cmp    %ebx,%ecx
  8002a1:	72 13                	jb     8002b6 <cprintnum+0x47>
  8002a3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002a6:	76 0e                	jbe    8002b6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8002a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ab:	0b 45 18             	or     0x18(%ebp),%eax
  8002ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8002b4:	eb 6a                	jmp    800320 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8002b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002bd:	83 ee 01             	sub    $0x1,%esi
  8002c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002d0:	89 c3                	mov    %eax,%ebx
  8002d2:	89 d6                	mov    %edx,%esi
  8002d4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8002d7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8002da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 1c 10 00 00       	call   801310 <__udivdi3>
  8002f4:	89 d9                	mov    %ebx,%ecx
  8002f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	89 54 24 04          	mov    %edx,0x4(%esp)
  800305:	89 f9                	mov    %edi,%ecx
  800307:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80030a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030d:	e8 5d ff ff ff       	call   80026f <cprintnum>
  800312:	eb 16                	jmp    80032a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800314:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800318:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800320:	83 ee 01             	sub    $0x1,%esi
  800323:	85 f6                	test   %esi,%esi
  800325:	7f ed                	jg     800314 <cprintnum+0xa5>
  800327:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80032a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800332:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800335:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800338:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800340:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800349:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034d:	e8 ee 10 00 00       	call   801440 <__umoddi3>
  800352:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800356:	0f be 80 cf 15 80 00 	movsbl 0x8015cf(%eax),%eax
  80035d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800366:	ff d0                	call   *%eax
}
  800368:	83 c4 3c             	add    $0x3c,%esp
  80036b:	5b                   	pop    %ebx
  80036c:	5e                   	pop    %esi
  80036d:	5f                   	pop    %edi
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800373:	83 fa 01             	cmp    $0x1,%edx
  800376:	7e 0e                	jle    800386 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 02                	mov    (%edx),%eax
  800381:	8b 52 04             	mov    0x4(%edx),%edx
  800384:	eb 22                	jmp    8003a8 <getuint+0x38>
	else if (lflag)
  800386:	85 d2                	test   %edx,%edx
  800388:	74 10                	je     80039a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038a:	8b 10                	mov    (%eax),%edx
  80038c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038f:	89 08                	mov    %ecx,(%eax)
  800391:	8b 02                	mov    (%edx),%eax
  800393:	ba 00 00 00 00       	mov    $0x0,%edx
  800398:	eb 0e                	jmp    8003a8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 02                	mov    (%edx),%eax
  8003a3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b4:	8b 10                	mov    (%eax),%edx
  8003b6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b9:	73 0a                	jae    8003c5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003bb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003be:	89 08                	mov    %ecx,(%eax)
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	88 02                	mov    %al,(%edx)
}
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    

008003c7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003cd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e5:	89 04 24             	mov    %eax,(%esp)
  8003e8:	e8 02 00 00 00       	call   8003ef <vprintfmt>
	va_end(ap);
}
  8003ed:	c9                   	leave  
  8003ee:	c3                   	ret    

008003ef <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	57                   	push   %edi
  8003f3:	56                   	push   %esi
  8003f4:	53                   	push   %ebx
  8003f5:	83 ec 3c             	sub    $0x3c,%esp
  8003f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003fe:	eb 14                	jmp    800414 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800400:	85 c0                	test   %eax,%eax
  800402:	0f 84 b3 03 00 00    	je     8007bb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800408:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800412:	89 f3                	mov    %esi,%ebx
  800414:	8d 73 01             	lea    0x1(%ebx),%esi
  800417:	0f b6 03             	movzbl (%ebx),%eax
  80041a:	83 f8 25             	cmp    $0x25,%eax
  80041d:	75 e1                	jne    800400 <vprintfmt+0x11>
  80041f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800423:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80042a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800431:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800438:	ba 00 00 00 00       	mov    $0x0,%edx
  80043d:	eb 1d                	jmp    80045c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800441:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800445:	eb 15                	jmp    80045c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800449:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80044d:	eb 0d                	jmp    80045c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80044f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800452:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800455:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80045f:	0f b6 0e             	movzbl (%esi),%ecx
  800462:	0f b6 c1             	movzbl %cl,%eax
  800465:	83 e9 23             	sub    $0x23,%ecx
  800468:	80 f9 55             	cmp    $0x55,%cl
  80046b:	0f 87 2a 03 00 00    	ja     80079b <vprintfmt+0x3ac>
  800471:	0f b6 c9             	movzbl %cl,%ecx
  800474:	ff 24 8d a0 16 80 00 	jmp    *0x8016a0(,%ecx,4)
  80047b:	89 de                	mov    %ebx,%esi
  80047d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800482:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800485:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800489:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80048c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80048f:	83 fb 09             	cmp    $0x9,%ebx
  800492:	77 36                	ja     8004ca <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800494:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800497:	eb e9                	jmp    800482 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 48 04             	lea    0x4(%eax),%ecx
  80049f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a2:	8b 00                	mov    (%eax),%eax
  8004a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a9:	eb 22                	jmp    8004cd <vprintfmt+0xde>
  8004ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ae:	85 c9                	test   %ecx,%ecx
  8004b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b5:	0f 49 c1             	cmovns %ecx,%eax
  8004b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	89 de                	mov    %ebx,%esi
  8004bd:	eb 9d                	jmp    80045c <vprintfmt+0x6d>
  8004bf:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004c8:	eb 92                	jmp    80045c <vprintfmt+0x6d>
  8004ca:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004cd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d1:	79 89                	jns    80045c <vprintfmt+0x6d>
  8004d3:	e9 77 ff ff ff       	jmp    80044f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004dd:	e9 7a ff ff ff       	jmp    80045c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 50 04             	lea    0x4(%eax),%edx
  8004e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 04 24             	mov    %eax,(%esp)
  8004f4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f7:	e9 18 ff ff ff       	jmp    800414 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 50 04             	lea    0x4(%eax),%edx
  800502:	89 55 14             	mov    %edx,0x14(%ebp)
  800505:	8b 00                	mov    (%eax),%eax
  800507:	99                   	cltd   
  800508:	31 d0                	xor    %edx,%eax
  80050a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050c:	83 f8 09             	cmp    $0x9,%eax
  80050f:	7f 0b                	jg     80051c <vprintfmt+0x12d>
  800511:	8b 14 85 60 19 80 00 	mov    0x801960(,%eax,4),%edx
  800518:	85 d2                	test   %edx,%edx
  80051a:	75 20                	jne    80053c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80051c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800520:	c7 44 24 08 e7 15 80 	movl   $0x8015e7,0x8(%esp)
  800527:	00 
  800528:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	e8 90 fe ff ff       	call   8003c7 <printfmt>
  800537:	e9 d8 fe ff ff       	jmp    800414 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80053c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800540:	c7 44 24 08 f0 15 80 	movl   $0x8015f0,0x8(%esp)
  800547:	00 
  800548:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054c:	8b 45 08             	mov    0x8(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 70 fe ff ff       	call   8003c7 <printfmt>
  800557:	e9 b8 fe ff ff       	jmp    800414 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80055f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800562:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800570:	85 f6                	test   %esi,%esi
  800572:	b8 e0 15 80 00       	mov    $0x8015e0,%eax
  800577:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80057a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80057e:	0f 84 97 00 00 00    	je     80061b <vprintfmt+0x22c>
  800584:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800588:	0f 8e 9b 00 00 00    	jle    800629 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800592:	89 34 24             	mov    %esi,(%esp)
  800595:	e8 ce 06 00 00       	call   800c68 <strnlen>
  80059a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80059d:	29 c2                	sub    %eax,%edx
  80059f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005a2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005a6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005b2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	eb 0f                	jmp    8005c5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005bd:	89 04 24             	mov    %eax,(%esp)
  8005c0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c2:	83 eb 01             	sub    $0x1,%ebx
  8005c5:	85 db                	test   %ebx,%ebx
  8005c7:	7f ed                	jg     8005b6 <vprintfmt+0x1c7>
  8005c9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005cc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005cf:	85 d2                	test   %edx,%edx
  8005d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d6:	0f 49 c2             	cmovns %edx,%eax
  8005d9:	29 c2                	sub    %eax,%edx
  8005db:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005de:	89 d7                	mov    %edx,%edi
  8005e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005e3:	eb 50                	jmp    800635 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e9:	74 1e                	je     800609 <vprintfmt+0x21a>
  8005eb:	0f be d2             	movsbl %dl,%edx
  8005ee:	83 ea 20             	sub    $0x20,%edx
  8005f1:	83 fa 5e             	cmp    $0x5e,%edx
  8005f4:	76 13                	jbe    800609 <vprintfmt+0x21a>
					putch('?', putdat);
  8005f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800604:	ff 55 08             	call   *0x8(%ebp)
  800607:	eb 0d                	jmp    800616 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800609:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800616:	83 ef 01             	sub    $0x1,%edi
  800619:	eb 1a                	jmp    800635 <vprintfmt+0x246>
  80061b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80061e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800621:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800624:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800627:	eb 0c                	jmp    800635 <vprintfmt+0x246>
  800629:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80062c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80062f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800632:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800635:	83 c6 01             	add    $0x1,%esi
  800638:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80063c:	0f be c2             	movsbl %dl,%eax
  80063f:	85 c0                	test   %eax,%eax
  800641:	74 27                	je     80066a <vprintfmt+0x27b>
  800643:	85 db                	test   %ebx,%ebx
  800645:	78 9e                	js     8005e5 <vprintfmt+0x1f6>
  800647:	83 eb 01             	sub    $0x1,%ebx
  80064a:	79 99                	jns    8005e5 <vprintfmt+0x1f6>
  80064c:	89 f8                	mov    %edi,%eax
  80064e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800651:	8b 75 08             	mov    0x8(%ebp),%esi
  800654:	89 c3                	mov    %eax,%ebx
  800656:	eb 1a                	jmp    800672 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800658:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800663:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800665:	83 eb 01             	sub    $0x1,%ebx
  800668:	eb 08                	jmp    800672 <vprintfmt+0x283>
  80066a:	89 fb                	mov    %edi,%ebx
  80066c:	8b 75 08             	mov    0x8(%ebp),%esi
  80066f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800672:	85 db                	test   %ebx,%ebx
  800674:	7f e2                	jg     800658 <vprintfmt+0x269>
  800676:	89 75 08             	mov    %esi,0x8(%ebp)
  800679:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80067c:	e9 93 fd ff ff       	jmp    800414 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800681:	83 fa 01             	cmp    $0x1,%edx
  800684:	7e 16                	jle    80069c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 08             	lea    0x8(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 50 04             	mov    0x4(%eax),%edx
  800692:	8b 00                	mov    (%eax),%eax
  800694:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800697:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80069a:	eb 32                	jmp    8006ce <vprintfmt+0x2df>
	else if (lflag)
  80069c:	85 d2                	test   %edx,%edx
  80069e:	74 18                	je     8006b8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 30                	mov    (%eax),%esi
  8006ab:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006ae:	89 f0                	mov    %esi,%eax
  8006b0:	c1 f8 1f             	sar    $0x1f,%eax
  8006b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b6:	eb 16                	jmp    8006ce <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 30                	mov    (%eax),%esi
  8006c3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006c6:	89 f0                	mov    %esi,%eax
  8006c8:	c1 f8 1f             	sar    $0x1f,%eax
  8006cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006dd:	0f 89 80 00 00 00    	jns    800763 <vprintfmt+0x374>
				putch('-', putdat);
  8006e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f7:	f7 d8                	neg    %eax
  8006f9:	83 d2 00             	adc    $0x0,%edx
  8006fc:	f7 da                	neg    %edx
			}
			base = 10;
  8006fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800703:	eb 5e                	jmp    800763 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
  800708:	e8 63 fc ff ff       	call   800370 <getuint>
			base = 10;
  80070d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800712:	eb 4f                	jmp    800763 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800714:	8d 45 14             	lea    0x14(%ebp),%eax
  800717:	e8 54 fc ff ff       	call   800370 <getuint>
			base = 8 ;
  80071c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800721:	eb 40                	jmp    800763 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800723:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800727:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800731:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800735:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8d 50 04             	lea    0x4(%eax),%edx
  800745:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800748:	8b 00                	mov    (%eax),%eax
  80074a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800754:	eb 0d                	jmp    800763 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 12 fc ff ff       	call   800370 <getuint>
			base = 16;
  80075e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800763:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800767:	89 74 24 10          	mov    %esi,0x10(%esp)
  80076b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80076e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800772:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800776:	89 04 24             	mov    %eax,(%esp)
  800779:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077d:	89 fa                	mov    %edi,%edx
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	e8 f9 f9 ff ff       	call   800180 <printnum>
			break;
  800787:	e9 88 fc ff ff       	jmp    800414 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80078c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
			break;
  800796:	e9 79 fc ff ff       	jmp    800414 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80079b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a9:	89 f3                	mov    %esi,%ebx
  8007ab:	eb 03                	jmp    8007b0 <vprintfmt+0x3c1>
  8007ad:	83 eb 01             	sub    $0x1,%ebx
  8007b0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007b4:	75 f7                	jne    8007ad <vprintfmt+0x3be>
  8007b6:	e9 59 fc ff ff       	jmp    800414 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007bb:	83 c4 3c             	add    $0x3c,%esp
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5f                   	pop    %edi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	57                   	push   %edi
  8007c7:	56                   	push   %esi
  8007c8:	53                   	push   %ebx
  8007c9:	83 ec 3c             	sub    $0x3c,%esp
  8007cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 50 04             	lea    0x4(%eax),%edx
  8007d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d8:	8b 00                	mov    (%eax),%eax
  8007da:	c1 e0 08             	shl    $0x8,%eax
  8007dd:	0f b7 c0             	movzwl %ax,%eax
  8007e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  8007e3:	83 c8 25             	or     $0x25,%eax
  8007e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007e9:	eb 1a                	jmp    800805 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	0f 84 a9 03 00 00    	je     800b9c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  8007f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007fa:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8007fd:	89 04 24             	mov    %eax,(%esp)
  800800:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800803:	89 fb                	mov    %edi,%ebx
  800805:	8d 7b 01             	lea    0x1(%ebx),%edi
  800808:	0f b6 03             	movzbl (%ebx),%eax
  80080b:	83 f8 25             	cmp    $0x25,%eax
  80080e:	75 db                	jne    8007eb <cvprintfmt+0x28>
  800810:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800814:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80081b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800820:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800827:	ba 00 00 00 00       	mov    $0x0,%edx
  80082c:	eb 18                	jmp    800846 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800830:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800834:	eb 10                	jmp    800846 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800836:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800838:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80083c:	eb 08                	jmp    800846 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80083e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800841:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8d 5f 01             	lea    0x1(%edi),%ebx
  800849:	0f b6 0f             	movzbl (%edi),%ecx
  80084c:	0f b6 c1             	movzbl %cl,%eax
  80084f:	83 e9 23             	sub    $0x23,%ecx
  800852:	80 f9 55             	cmp    $0x55,%cl
  800855:	0f 87 1f 03 00 00    	ja     800b7a <cvprintfmt+0x3b7>
  80085b:	0f b6 c9             	movzbl %cl,%ecx
  80085e:	ff 24 8d f8 17 80 00 	jmp    *0x8017f8(,%ecx,4)
  800865:	89 df                	mov    %ebx,%edi
  800867:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80086c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80086f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800873:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800876:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800879:	83 f9 09             	cmp    $0x9,%ecx
  80087c:	77 33                	ja     8008b1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80087e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800881:	eb e9                	jmp    80086c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8d 48 04             	lea    0x4(%eax),%ecx
  800889:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80088c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800890:	eb 1f                	jmp    8008b1 <cvprintfmt+0xee>
  800892:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800895:	85 ff                	test   %edi,%edi
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
  80089c:	0f 49 c7             	cmovns %edi,%eax
  80089f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a2:	89 df                	mov    %ebx,%edi
  8008a4:	eb a0                	jmp    800846 <cvprintfmt+0x83>
  8008a6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008a8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8008af:	eb 95                	jmp    800846 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  8008b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008b5:	79 8f                	jns    800846 <cvprintfmt+0x83>
  8008b7:	eb 85                	jmp    80083e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bc:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008be:	66 90                	xchg   %ax,%ax
  8008c0:	eb 84                	jmp    800846 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  8008c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c5:	8d 50 04             	lea    0x4(%eax),%edx
  8008c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008d5:	0b 10                	or     (%eax),%edx
  8008d7:	89 14 24             	mov    %edx,(%esp)
  8008da:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008dd:	e9 23 ff ff ff       	jmp    800805 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8d 50 04             	lea    0x4(%eax),%edx
  8008e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008eb:	8b 00                	mov    (%eax),%eax
  8008ed:	99                   	cltd   
  8008ee:	31 d0                	xor    %edx,%eax
  8008f0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008f2:	83 f8 09             	cmp    $0x9,%eax
  8008f5:	7f 0b                	jg     800902 <cvprintfmt+0x13f>
  8008f7:	8b 14 85 60 19 80 00 	mov    0x801960(,%eax,4),%edx
  8008fe:	85 d2                	test   %edx,%edx
  800900:	75 23                	jne    800925 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800902:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800906:	c7 44 24 08 e7 15 80 	movl   $0x8015e7,0x8(%esp)
  80090d:	00 
  80090e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800911:	89 44 24 04          	mov    %eax,0x4(%esp)
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	89 04 24             	mov    %eax,(%esp)
  80091b:	e8 a7 fa ff ff       	call   8003c7 <printfmt>
  800920:	e9 e0 fe ff ff       	jmp    800805 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800925:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800929:	c7 44 24 08 f0 15 80 	movl   $0x8015f0,0x8(%esp)
  800930:	00 
  800931:	8b 45 0c             	mov    0xc(%ebp),%eax
  800934:	89 44 24 04          	mov    %eax,0x4(%esp)
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	89 04 24             	mov    %eax,(%esp)
  80093e:	e8 84 fa ff ff       	call   8003c7 <printfmt>
  800943:	e9 bd fe ff ff       	jmp    800805 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800948:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80094b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  80094e:	8b 45 14             	mov    0x14(%ebp),%eax
  800951:	8d 48 04             	lea    0x4(%eax),%ecx
  800954:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800957:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800959:	85 ff                	test   %edi,%edi
  80095b:	b8 e0 15 80 00       	mov    $0x8015e0,%eax
  800960:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800963:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800967:	74 61                	je     8009ca <cvprintfmt+0x207>
  800969:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80096d:	7e 5b                	jle    8009ca <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  80096f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800973:	89 3c 24             	mov    %edi,(%esp)
  800976:	e8 ed 02 00 00       	call   800c68 <strnlen>
  80097b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80097e:	29 c2                	sub    %eax,%edx
  800980:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800983:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800987:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80098a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80098d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800990:	8b 75 08             	mov    0x8(%ebp),%esi
  800993:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800996:	89 d3                	mov    %edx,%ebx
  800998:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80099a:	eb 0f                	jmp    8009ab <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a3:	89 3c 24             	mov    %edi,(%esp)
  8009a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a8:	83 eb 01             	sub    $0x1,%ebx
  8009ab:	85 db                	test   %ebx,%ebx
  8009ad:	7f ed                	jg     80099c <cvprintfmt+0x1d9>
  8009af:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8009b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009bb:	85 d2                	test   %edx,%edx
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c2:	0f 49 c2             	cmovns %edx,%eax
  8009c5:	29 c2                	sub    %eax,%edx
  8009c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  8009ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009cd:	83 c8 3f             	or     $0x3f,%eax
  8009d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009d3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009d6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009d9:	eb 36                	jmp    800a11 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009df:	74 1d                	je     8009fe <cvprintfmt+0x23b>
  8009e1:	0f be d2             	movsbl %dl,%edx
  8009e4:	83 ea 20             	sub    $0x20,%edx
  8009e7:	83 fa 5e             	cmp    $0x5e,%edx
  8009ea:	76 12                	jbe    8009fe <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009f6:	89 04 24             	mov    %eax,(%esp)
  8009f9:	ff 55 08             	call   *0x8(%ebp)
  8009fc:	eb 10                	jmp    800a0e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a01:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a05:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0e:	83 eb 01             	sub    $0x1,%ebx
  800a11:	83 c7 01             	add    $0x1,%edi
  800a14:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a18:	0f be c2             	movsbl %dl,%eax
  800a1b:	85 c0                	test   %eax,%eax
  800a1d:	74 27                	je     800a46 <cvprintfmt+0x283>
  800a1f:	85 f6                	test   %esi,%esi
  800a21:	78 b8                	js     8009db <cvprintfmt+0x218>
  800a23:	83 ee 01             	sub    $0x1,%esi
  800a26:	79 b3                	jns    8009db <cvprintfmt+0x218>
  800a28:	89 d8                	mov    %ebx,%eax
  800a2a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	eb 18                	jmp    800a4c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800a34:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a3f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800a41:	83 eb 01             	sub    $0x1,%ebx
  800a44:	eb 06                	jmp    800a4c <cvprintfmt+0x289>
  800a46:	8b 75 08             	mov    0x8(%ebp),%esi
  800a49:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a4c:	85 db                	test   %ebx,%ebx
  800a4e:	7f e4                	jg     800a34 <cvprintfmt+0x271>
  800a50:	89 75 08             	mov    %esi,0x8(%ebp)
  800a53:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a59:	e9 a7 fd ff ff       	jmp    800805 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a5e:	83 fa 01             	cmp    $0x1,%edx
  800a61:	7e 10                	jle    800a73 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800a63:	8b 45 14             	mov    0x14(%ebp),%eax
  800a66:	8d 50 08             	lea    0x8(%eax),%edx
  800a69:	89 55 14             	mov    %edx,0x14(%ebp)
  800a6c:	8b 30                	mov    (%eax),%esi
  800a6e:	8b 78 04             	mov    0x4(%eax),%edi
  800a71:	eb 26                	jmp    800a99 <cvprintfmt+0x2d6>
	else if (lflag)
  800a73:	85 d2                	test   %edx,%edx
  800a75:	74 12                	je     800a89 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800a77:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7a:	8d 50 04             	lea    0x4(%eax),%edx
  800a7d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a80:	8b 30                	mov    (%eax),%esi
  800a82:	89 f7                	mov    %esi,%edi
  800a84:	c1 ff 1f             	sar    $0x1f,%edi
  800a87:	eb 10                	jmp    800a99 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800a89:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8c:	8d 50 04             	lea    0x4(%eax),%edx
  800a8f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a92:	8b 30                	mov    (%eax),%esi
  800a94:	89 f7                	mov    %esi,%edi
  800a96:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a99:	89 f0                	mov    %esi,%eax
  800a9b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a9d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800aa2:	85 ff                	test   %edi,%edi
  800aa4:	0f 89 8e 00 00 00    	jns    800b38 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ab4:	83 c8 2d             	or     $0x2d,%eax
  800ab7:	89 04 24             	mov    %eax,(%esp)
  800aba:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800abd:	89 f0                	mov    %esi,%eax
  800abf:	89 fa                	mov    %edi,%edx
  800ac1:	f7 d8                	neg    %eax
  800ac3:	83 d2 00             	adc    $0x0,%edx
  800ac6:	f7 da                	neg    %edx
			}
			base = 10;
  800ac8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800acd:	eb 69                	jmp    800b38 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800acf:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad2:	e8 99 f8 ff ff       	call   800370 <getuint>
			base = 10;
  800ad7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800adc:	eb 5a                	jmp    800b38 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ade:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae1:	e8 8a f8 ff ff       	call   800370 <getuint>
			base = 8 ;
  800ae6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800aeb:	eb 4b                	jmp    800b38 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800af7:	89 f0                	mov    %esi,%eax
  800af9:	83 c8 30             	or     $0x30,%eax
  800afc:	89 04 24             	mov    %eax,(%esp)
  800aff:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b09:	89 f0                	mov    %esi,%eax
  800b0b:	83 c8 78             	or     $0x78,%eax
  800b0e:	89 04 24             	mov    %eax,(%esp)
  800b11:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b14:	8b 45 14             	mov    0x14(%ebp),%eax
  800b17:	8d 50 04             	lea    0x4(%eax),%edx
  800b1a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800b1d:	8b 00                	mov    (%eax),%eax
  800b1f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b24:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b29:	eb 0d                	jmp    800b38 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b2b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b2e:	e8 3d f8 ff ff       	call   800370 <getuint>
			base = 16;
  800b33:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800b38:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800b3c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b40:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800b43:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b47:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b4b:	89 04 24             	mov    %eax,(%esp)
  800b4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b5b:	e8 0f f7 ff ff       	call   80026f <cprintnum>
			break;
  800b60:	e9 a0 fc ff ff       	jmp    800805 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800b65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b68:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b6c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b6f:	89 04 24             	mov    %eax,(%esp)
  800b72:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b75:	e9 8b fc ff ff       	jmp    800805 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b84:	89 04 24             	mov    %eax,(%esp)
  800b87:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b8a:	89 fb                	mov    %edi,%ebx
  800b8c:	eb 03                	jmp    800b91 <cvprintfmt+0x3ce>
  800b8e:	83 eb 01             	sub    $0x1,%ebx
  800b91:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800b95:	75 f7                	jne    800b8e <cvprintfmt+0x3cb>
  800b97:	e9 69 fc ff ff       	jmp    800805 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800b9c:	83 c4 3c             	add    $0x3c,%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800baa:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800bad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc2:	89 04 24             	mov    %eax,(%esp)
  800bc5:	e8 f9 fb ff ff       	call   8007c3 <cvprintfmt>
	va_end(ap);
}
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    

00800bcc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 28             	sub    $0x28,%esp
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bdb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bdf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800be2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800be9:	85 c0                	test   %eax,%eax
  800beb:	74 30                	je     800c1d <vsnprintf+0x51>
  800bed:	85 d2                	test   %edx,%edx
  800bef:	7e 2c                	jle    800c1d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bf1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bf8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c06:	c7 04 24 aa 03 80 00 	movl   $0x8003aa,(%esp)
  800c0d:	e8 dd f7 ff ff       	call   8003ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c15:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1b:	eb 05                	jmp    800c22 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c2a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c31:	8b 45 10             	mov    0x10(%ebp),%eax
  800c34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c42:	89 04 24             	mov    %eax,(%esp)
  800c45:	e8 82 ff ff ff       	call   800bcc <vsnprintf>
	va_end(ap);

	return rc;
}
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    
  800c4c:	66 90                	xchg   %ax,%ax
  800c4e:	66 90                	xchg   %ax,%ax

00800c50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c56:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5b:	eb 03                	jmp    800c60 <strlen+0x10>
		n++;
  800c5d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c64:	75 f7                	jne    800c5d <strlen+0xd>
		n++;
	return n;
}
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
  800c76:	eb 03                	jmp    800c7b <strnlen+0x13>
		n++;
  800c78:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c7b:	39 d0                	cmp    %edx,%eax
  800c7d:	74 06                	je     800c85 <strnlen+0x1d>
  800c7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c83:	75 f3                	jne    800c78 <strnlen+0x10>
		n++;
	return n;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	53                   	push   %ebx
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c91:	89 c2                	mov    %eax,%edx
  800c93:	83 c2 01             	add    $0x1,%edx
  800c96:	83 c1 01             	add    $0x1,%ecx
  800c99:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c9d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ca0:	84 db                	test   %bl,%bl
  800ca2:	75 ef                	jne    800c93 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	53                   	push   %ebx
  800cab:	83 ec 08             	sub    $0x8,%esp
  800cae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cb1:	89 1c 24             	mov    %ebx,(%esp)
  800cb4:	e8 97 ff ff ff       	call   800c50 <strlen>
	strcpy(dst + len, src);
  800cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cc0:	01 d8                	add    %ebx,%eax
  800cc2:	89 04 24             	mov    %eax,(%esp)
  800cc5:	e8 bd ff ff ff       	call   800c87 <strcpy>
	return dst;
}
  800cca:	89 d8                	mov    %ebx,%eax
  800ccc:	83 c4 08             	add    $0x8,%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	8b 75 08             	mov    0x8(%ebp),%esi
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	89 f3                	mov    %esi,%ebx
  800cdf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce2:	89 f2                	mov    %esi,%edx
  800ce4:	eb 0f                	jmp    800cf5 <strncpy+0x23>
		*dst++ = *src;
  800ce6:	83 c2 01             	add    $0x1,%edx
  800ce9:	0f b6 01             	movzbl (%ecx),%eax
  800cec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cef:	80 39 01             	cmpb   $0x1,(%ecx)
  800cf2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf5:	39 da                	cmp    %ebx,%edx
  800cf7:	75 ed                	jne    800ce6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cf9:	89 f0                	mov    %esi,%eax
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	8b 75 08             	mov    0x8(%ebp),%esi
  800d07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d0d:	89 f0                	mov    %esi,%eax
  800d0f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d13:	85 c9                	test   %ecx,%ecx
  800d15:	75 0b                	jne    800d22 <strlcpy+0x23>
  800d17:	eb 1d                	jmp    800d36 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d19:	83 c0 01             	add    $0x1,%eax
  800d1c:	83 c2 01             	add    $0x1,%edx
  800d1f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d22:	39 d8                	cmp    %ebx,%eax
  800d24:	74 0b                	je     800d31 <strlcpy+0x32>
  800d26:	0f b6 0a             	movzbl (%edx),%ecx
  800d29:	84 c9                	test   %cl,%cl
  800d2b:	75 ec                	jne    800d19 <strlcpy+0x1a>
  800d2d:	89 c2                	mov    %eax,%edx
  800d2f:	eb 02                	jmp    800d33 <strlcpy+0x34>
  800d31:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d33:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d36:	29 f0                	sub    %esi,%eax
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d45:	eb 06                	jmp    800d4d <strcmp+0x11>
		p++, q++;
  800d47:	83 c1 01             	add    $0x1,%ecx
  800d4a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d4d:	0f b6 01             	movzbl (%ecx),%eax
  800d50:	84 c0                	test   %al,%al
  800d52:	74 04                	je     800d58 <strcmp+0x1c>
  800d54:	3a 02                	cmp    (%edx),%al
  800d56:	74 ef                	je     800d47 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d58:	0f b6 c0             	movzbl %al,%eax
  800d5b:	0f b6 12             	movzbl (%edx),%edx
  800d5e:	29 d0                	sub    %edx,%eax
}
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	53                   	push   %ebx
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d6c:	89 c3                	mov    %eax,%ebx
  800d6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d71:	eb 06                	jmp    800d79 <strncmp+0x17>
		n--, p++, q++;
  800d73:	83 c0 01             	add    $0x1,%eax
  800d76:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d79:	39 d8                	cmp    %ebx,%eax
  800d7b:	74 15                	je     800d92 <strncmp+0x30>
  800d7d:	0f b6 08             	movzbl (%eax),%ecx
  800d80:	84 c9                	test   %cl,%cl
  800d82:	74 04                	je     800d88 <strncmp+0x26>
  800d84:	3a 0a                	cmp    (%edx),%cl
  800d86:	74 eb                	je     800d73 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d88:	0f b6 00             	movzbl (%eax),%eax
  800d8b:	0f b6 12             	movzbl (%edx),%edx
  800d8e:	29 d0                	sub    %edx,%eax
  800d90:	eb 05                	jmp    800d97 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d92:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d97:	5b                   	pop    %ebx
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800da4:	eb 07                	jmp    800dad <strchr+0x13>
		if (*s == c)
  800da6:	38 ca                	cmp    %cl,%dl
  800da8:	74 0f                	je     800db9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800daa:	83 c0 01             	add    $0x1,%eax
  800dad:	0f b6 10             	movzbl (%eax),%edx
  800db0:	84 d2                	test   %dl,%dl
  800db2:	75 f2                	jne    800da6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dc5:	eb 07                	jmp    800dce <strfind+0x13>
		if (*s == c)
  800dc7:	38 ca                	cmp    %cl,%dl
  800dc9:	74 0a                	je     800dd5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800dcb:	83 c0 01             	add    $0x1,%eax
  800dce:	0f b6 10             	movzbl (%eax),%edx
  800dd1:	84 d2                	test   %dl,%dl
  800dd3:	75 f2                	jne    800dc7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800de0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800de3:	85 c9                	test   %ecx,%ecx
  800de5:	74 36                	je     800e1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800de7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ded:	75 28                	jne    800e17 <memset+0x40>
  800def:	f6 c1 03             	test   $0x3,%cl
  800df2:	75 23                	jne    800e17 <memset+0x40>
		c &= 0xFF;
  800df4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800df8:	89 d3                	mov    %edx,%ebx
  800dfa:	c1 e3 08             	shl    $0x8,%ebx
  800dfd:	89 d6                	mov    %edx,%esi
  800dff:	c1 e6 18             	shl    $0x18,%esi
  800e02:	89 d0                	mov    %edx,%eax
  800e04:	c1 e0 10             	shl    $0x10,%eax
  800e07:	09 f0                	or     %esi,%eax
  800e09:	09 c2                	or     %eax,%edx
  800e0b:	89 d0                	mov    %edx,%eax
  800e0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e0f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e12:	fc                   	cld    
  800e13:	f3 ab                	rep stos %eax,%es:(%edi)
  800e15:	eb 06                	jmp    800e1d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1a:	fc                   	cld    
  800e1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e1d:	89 f8                	mov    %edi,%eax
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e32:	39 c6                	cmp    %eax,%esi
  800e34:	73 35                	jae    800e6b <memmove+0x47>
  800e36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e39:	39 d0                	cmp    %edx,%eax
  800e3b:	73 2e                	jae    800e6b <memmove+0x47>
		s += n;
		d += n;
  800e3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800e40:	89 d6                	mov    %edx,%esi
  800e42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e4a:	75 13                	jne    800e5f <memmove+0x3b>
  800e4c:	f6 c1 03             	test   $0x3,%cl
  800e4f:	75 0e                	jne    800e5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e51:	83 ef 04             	sub    $0x4,%edi
  800e54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e5a:	fd                   	std    
  800e5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e5d:	eb 09                	jmp    800e68 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e5f:	83 ef 01             	sub    $0x1,%edi
  800e62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e65:	fd                   	std    
  800e66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e68:	fc                   	cld    
  800e69:	eb 1d                	jmp    800e88 <memmove+0x64>
  800e6b:	89 f2                	mov    %esi,%edx
  800e6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e6f:	f6 c2 03             	test   $0x3,%dl
  800e72:	75 0f                	jne    800e83 <memmove+0x5f>
  800e74:	f6 c1 03             	test   $0x3,%cl
  800e77:	75 0a                	jne    800e83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e79:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e7c:	89 c7                	mov    %eax,%edi
  800e7e:	fc                   	cld    
  800e7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e81:	eb 05                	jmp    800e88 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e83:	89 c7                	mov    %eax,%edi
  800e85:	fc                   	cld    
  800e86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e92:	8b 45 10             	mov    0x10(%ebp),%eax
  800e95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	89 04 24             	mov    %eax,(%esp)
  800ea6:	e8 79 ff ff ff       	call   800e24 <memmove>
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb8:	89 d6                	mov    %edx,%esi
  800eba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ebd:	eb 1a                	jmp    800ed9 <memcmp+0x2c>
		if (*s1 != *s2)
  800ebf:	0f b6 02             	movzbl (%edx),%eax
  800ec2:	0f b6 19             	movzbl (%ecx),%ebx
  800ec5:	38 d8                	cmp    %bl,%al
  800ec7:	74 0a                	je     800ed3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ec9:	0f b6 c0             	movzbl %al,%eax
  800ecc:	0f b6 db             	movzbl %bl,%ebx
  800ecf:	29 d8                	sub    %ebx,%eax
  800ed1:	eb 0f                	jmp    800ee2 <memcmp+0x35>
		s1++, s2++;
  800ed3:	83 c2 01             	add    $0x1,%edx
  800ed6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ed9:	39 f2                	cmp    %esi,%edx
  800edb:	75 e2                	jne    800ebf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ef4:	eb 07                	jmp    800efd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ef6:	38 08                	cmp    %cl,(%eax)
  800ef8:	74 07                	je     800f01 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800efa:	83 c0 01             	add    $0x1,%eax
  800efd:	39 d0                	cmp    %edx,%eax
  800eff:	72 f5                	jb     800ef6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f0f:	eb 03                	jmp    800f14 <strtol+0x11>
		s++;
  800f11:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f14:	0f b6 0a             	movzbl (%edx),%ecx
  800f17:	80 f9 09             	cmp    $0x9,%cl
  800f1a:	74 f5                	je     800f11 <strtol+0xe>
  800f1c:	80 f9 20             	cmp    $0x20,%cl
  800f1f:	74 f0                	je     800f11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f21:	80 f9 2b             	cmp    $0x2b,%cl
  800f24:	75 0a                	jne    800f30 <strtol+0x2d>
		s++;
  800f26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f29:	bf 00 00 00 00       	mov    $0x0,%edi
  800f2e:	eb 11                	jmp    800f41 <strtol+0x3e>
  800f30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f35:	80 f9 2d             	cmp    $0x2d,%cl
  800f38:	75 07                	jne    800f41 <strtol+0x3e>
		s++, neg = 1;
  800f3a:	8d 52 01             	lea    0x1(%edx),%edx
  800f3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800f46:	75 15                	jne    800f5d <strtol+0x5a>
  800f48:	80 3a 30             	cmpb   $0x30,(%edx)
  800f4b:	75 10                	jne    800f5d <strtol+0x5a>
  800f4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f51:	75 0a                	jne    800f5d <strtol+0x5a>
		s += 2, base = 16;
  800f53:	83 c2 02             	add    $0x2,%edx
  800f56:	b8 10 00 00 00       	mov    $0x10,%eax
  800f5b:	eb 10                	jmp    800f6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	75 0c                	jne    800f6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f61:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f63:	80 3a 30             	cmpb   $0x30,(%edx)
  800f66:	75 05                	jne    800f6d <strtol+0x6a>
		s++, base = 8;
  800f68:	83 c2 01             	add    $0x1,%edx
  800f6b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800f6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f75:	0f b6 0a             	movzbl (%edx),%ecx
  800f78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800f7b:	89 f0                	mov    %esi,%eax
  800f7d:	3c 09                	cmp    $0x9,%al
  800f7f:	77 08                	ja     800f89 <strtol+0x86>
			dig = *s - '0';
  800f81:	0f be c9             	movsbl %cl,%ecx
  800f84:	83 e9 30             	sub    $0x30,%ecx
  800f87:	eb 20                	jmp    800fa9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800f89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800f8c:	89 f0                	mov    %esi,%eax
  800f8e:	3c 19                	cmp    $0x19,%al
  800f90:	77 08                	ja     800f9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800f92:	0f be c9             	movsbl %cl,%ecx
  800f95:	83 e9 57             	sub    $0x57,%ecx
  800f98:	eb 0f                	jmp    800fa9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800f9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800f9d:	89 f0                	mov    %esi,%eax
  800f9f:	3c 19                	cmp    $0x19,%al
  800fa1:	77 16                	ja     800fb9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800fa3:	0f be c9             	movsbl %cl,%ecx
  800fa6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fa9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800fac:	7d 0f                	jge    800fbd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800fae:	83 c2 01             	add    $0x1,%edx
  800fb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800fb5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800fb7:	eb bc                	jmp    800f75 <strtol+0x72>
  800fb9:	89 d8                	mov    %ebx,%eax
  800fbb:	eb 02                	jmp    800fbf <strtol+0xbc>
  800fbd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800fbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fc3:	74 05                	je     800fca <strtol+0xc7>
		*endptr = (char *) s;
  800fc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fc8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800fca:	f7 d8                	neg    %eax
  800fcc:	85 ff                	test   %edi,%edi
  800fce:	0f 44 c3             	cmove  %ebx,%eax
}
  800fd1:	5b                   	pop    %ebx
  800fd2:	5e                   	pop    %esi
  800fd3:	5f                   	pop    %edi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	57                   	push   %edi
  800fda:	56                   	push   %esi
  800fdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe7:	89 c3                	mov    %eax,%ebx
  800fe9:	89 c7                	mov    %eax,%edi
  800feb:	89 c6                	mov    %eax,%esi
  800fed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5f                   	pop    %edi
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    

00800ff4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffa:	ba 00 00 00 00       	mov    $0x0,%edx
  800fff:	b8 01 00 00 00       	mov    $0x1,%eax
  801004:	89 d1                	mov    %edx,%ecx
  801006:	89 d3                	mov    %edx,%ebx
  801008:	89 d7                	mov    %edx,%edi
  80100a:	89 d6                	mov    %edx,%esi
  80100c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
  801019:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801021:	b8 03 00 00 00       	mov    $0x3,%eax
  801026:	8b 55 08             	mov    0x8(%ebp),%edx
  801029:	89 cb                	mov    %ecx,%ebx
  80102b:	89 cf                	mov    %ecx,%edi
  80102d:	89 ce                	mov    %ecx,%esi
  80102f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	7e 28                	jle    80105d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801035:	89 44 24 10          	mov    %eax,0x10(%esp)
  801039:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801040:	00 
  801041:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801048:	00 
  801049:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801050:	00 
  801051:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801058:	e8 5b 02 00 00       	call   8012b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80105d:	83 c4 2c             	add    $0x2c,%esp
  801060:	5b                   	pop    %ebx
  801061:	5e                   	pop    %esi
  801062:	5f                   	pop    %edi
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	57                   	push   %edi
  801069:	56                   	push   %esi
  80106a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106b:	ba 00 00 00 00       	mov    $0x0,%edx
  801070:	b8 02 00 00 00       	mov    $0x2,%eax
  801075:	89 d1                	mov    %edx,%ecx
  801077:	89 d3                	mov    %edx,%ebx
  801079:	89 d7                	mov    %edx,%edi
  80107b:	89 d6                	mov    %edx,%esi
  80107d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5f                   	pop    %edi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sys_yield>:

void
sys_yield(void)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108a:	ba 00 00 00 00       	mov    $0x0,%edx
  80108f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801094:	89 d1                	mov    %edx,%ecx
  801096:	89 d3                	mov    %edx,%ebx
  801098:	89 d7                	mov    %edx,%edi
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	be 00 00 00 00       	mov    $0x0,%esi
  8010b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010bf:	89 f7                	mov    %esi,%edi
  8010c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	7e 28                	jle    8010ef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010cb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010d2:	00 
  8010d3:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  8010da:	00 
  8010db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e2:	00 
  8010e3:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  8010ea:	e8 c9 01 00 00       	call   8012b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010ef:	83 c4 2c             	add    $0x2c,%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	57                   	push   %edi
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801100:	b8 05 00 00 00       	mov    $0x5,%eax
  801105:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801111:	8b 75 18             	mov    0x18(%ebp),%esi
  801114:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801116:	85 c0                	test   %eax,%eax
  801118:	7e 28                	jle    801142 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801125:	00 
  801126:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  80112d:	00 
  80112e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801135:	00 
  801136:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  80113d:	e8 76 01 00 00       	call   8012b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801142:	83 c4 2c             	add    $0x2c,%esp
  801145:	5b                   	pop    %ebx
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	57                   	push   %edi
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801153:	bb 00 00 00 00       	mov    $0x0,%ebx
  801158:	b8 06 00 00 00       	mov    $0x6,%eax
  80115d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801160:	8b 55 08             	mov    0x8(%ebp),%edx
  801163:	89 df                	mov    %ebx,%edi
  801165:	89 de                	mov    %ebx,%esi
  801167:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801169:	85 c0                	test   %eax,%eax
  80116b:	7e 28                	jle    801195 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801171:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801178:	00 
  801179:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801180:	00 
  801181:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801188:	00 
  801189:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801190:	e8 23 01 00 00       	call   8012b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801195:	83 c4 2c             	add    $0x2c,%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	57                   	push   %edi
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b6:	89 df                	mov    %ebx,%edi
  8011b8:	89 de                	mov    %ebx,%esi
  8011ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	7e 28                	jle    8011e8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8011cb:	00 
  8011cc:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  8011d3:	00 
  8011d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011db:	00 
  8011dc:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  8011e3:	e8 d0 00 00 00       	call   8012b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011e8:	83 c4 2c             	add    $0x2c,%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	57                   	push   %edi
  8011f4:	56                   	push   %esi
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801206:	8b 55 08             	mov    0x8(%ebp),%edx
  801209:	89 df                	mov    %ebx,%edi
  80120b:	89 de                	mov    %ebx,%esi
  80120d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80120f:	85 c0                	test   %eax,%eax
  801211:	7e 28                	jle    80123b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801213:	89 44 24 10          	mov    %eax,0x10(%esp)
  801217:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80121e:	00 
  80121f:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  801226:	00 
  801227:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80122e:	00 
  80122f:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  801236:	e8 7d 00 00 00       	call   8012b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80123b:	83 c4 2c             	add    $0x2c,%esp
  80123e:	5b                   	pop    %ebx
  80123f:	5e                   	pop    %esi
  801240:	5f                   	pop    %edi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	57                   	push   %edi
  801247:	56                   	push   %esi
  801248:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801249:	be 00 00 00 00       	mov    $0x0,%esi
  80124e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801256:	8b 55 08             	mov    0x8(%ebp),%edx
  801259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80125c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80125f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801261:	5b                   	pop    %ebx
  801262:	5e                   	pop    %esi
  801263:	5f                   	pop    %edi
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	57                   	push   %edi
  80126a:	56                   	push   %esi
  80126b:	53                   	push   %ebx
  80126c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80126f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801274:	b8 0c 00 00 00       	mov    $0xc,%eax
  801279:	8b 55 08             	mov    0x8(%ebp),%edx
  80127c:	89 cb                	mov    %ecx,%ebx
  80127e:	89 cf                	mov    %ecx,%edi
  801280:	89 ce                	mov    %ecx,%esi
  801282:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801284:	85 c0                	test   %eax,%eax
  801286:	7e 28                	jle    8012b0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801288:	89 44 24 10          	mov    %eax,0x10(%esp)
  80128c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801293:	00 
  801294:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  80129b:	00 
  80129c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012a3:	00 
  8012a4:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  8012ab:	e8 08 00 00 00       	call   8012b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012b0:	83 c4 2c             	add    $0x2c,%esp
  8012b3:	5b                   	pop    %ebx
  8012b4:	5e                   	pop    %esi
  8012b5:	5f                   	pop    %edi
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
  8012bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012c0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012c3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8012c9:	e8 97 fd ff ff       	call   801065 <sys_getenvid>
  8012ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012dc:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e4:	c7 04 24 b4 19 80 00 	movl   $0x8019b4,(%esp)
  8012eb:	e8 72 ee ff ff       	call   800162 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8012f7:	89 04 24             	mov    %eax,(%esp)
  8012fa:	e8 02 ee ff ff       	call   800101 <vcprintf>
	cprintf("\n");
  8012ff:	c7 04 24 ac 15 80 00 	movl   $0x8015ac,(%esp)
  801306:	e8 57 ee ff ff       	call   800162 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80130b:	cc                   	int3   
  80130c:	eb fd                	jmp    80130b <_panic+0x53>
  80130e:	66 90                	xchg   %ax,%ax

00801310 <__udivdi3>:
  801310:	55                   	push   %ebp
  801311:	57                   	push   %edi
  801312:	56                   	push   %esi
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	8b 44 24 28          	mov    0x28(%esp),%eax
  80131a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80131e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801322:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801326:	85 c0                	test   %eax,%eax
  801328:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80132c:	89 ea                	mov    %ebp,%edx
  80132e:	89 0c 24             	mov    %ecx,(%esp)
  801331:	75 2d                	jne    801360 <__udivdi3+0x50>
  801333:	39 e9                	cmp    %ebp,%ecx
  801335:	77 61                	ja     801398 <__udivdi3+0x88>
  801337:	85 c9                	test   %ecx,%ecx
  801339:	89 ce                	mov    %ecx,%esi
  80133b:	75 0b                	jne    801348 <__udivdi3+0x38>
  80133d:	b8 01 00 00 00       	mov    $0x1,%eax
  801342:	31 d2                	xor    %edx,%edx
  801344:	f7 f1                	div    %ecx
  801346:	89 c6                	mov    %eax,%esi
  801348:	31 d2                	xor    %edx,%edx
  80134a:	89 e8                	mov    %ebp,%eax
  80134c:	f7 f6                	div    %esi
  80134e:	89 c5                	mov    %eax,%ebp
  801350:	89 f8                	mov    %edi,%eax
  801352:	f7 f6                	div    %esi
  801354:	89 ea                	mov    %ebp,%edx
  801356:	83 c4 0c             	add    $0xc,%esp
  801359:	5e                   	pop    %esi
  80135a:	5f                   	pop    %edi
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    
  80135d:	8d 76 00             	lea    0x0(%esi),%esi
  801360:	39 e8                	cmp    %ebp,%eax
  801362:	77 24                	ja     801388 <__udivdi3+0x78>
  801364:	0f bd e8             	bsr    %eax,%ebp
  801367:	83 f5 1f             	xor    $0x1f,%ebp
  80136a:	75 3c                	jne    8013a8 <__udivdi3+0x98>
  80136c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801370:	39 34 24             	cmp    %esi,(%esp)
  801373:	0f 86 9f 00 00 00    	jbe    801418 <__udivdi3+0x108>
  801379:	39 d0                	cmp    %edx,%eax
  80137b:	0f 82 97 00 00 00    	jb     801418 <__udivdi3+0x108>
  801381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801388:	31 d2                	xor    %edx,%edx
  80138a:	31 c0                	xor    %eax,%eax
  80138c:	83 c4 0c             	add    $0xc,%esp
  80138f:	5e                   	pop    %esi
  801390:	5f                   	pop    %edi
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    
  801393:	90                   	nop
  801394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801398:	89 f8                	mov    %edi,%eax
  80139a:	f7 f1                	div    %ecx
  80139c:	31 d2                	xor    %edx,%edx
  80139e:	83 c4 0c             	add    $0xc,%esp
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    
  8013a5:	8d 76 00             	lea    0x0(%esi),%esi
  8013a8:	89 e9                	mov    %ebp,%ecx
  8013aa:	8b 3c 24             	mov    (%esp),%edi
  8013ad:	d3 e0                	shl    %cl,%eax
  8013af:	89 c6                	mov    %eax,%esi
  8013b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013b6:	29 e8                	sub    %ebp,%eax
  8013b8:	89 c1                	mov    %eax,%ecx
  8013ba:	d3 ef                	shr    %cl,%edi
  8013bc:	89 e9                	mov    %ebp,%ecx
  8013be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013c2:	8b 3c 24             	mov    (%esp),%edi
  8013c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013c9:	89 d6                	mov    %edx,%esi
  8013cb:	d3 e7                	shl    %cl,%edi
  8013cd:	89 c1                	mov    %eax,%ecx
  8013cf:	89 3c 24             	mov    %edi,(%esp)
  8013d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013d6:	d3 ee                	shr    %cl,%esi
  8013d8:	89 e9                	mov    %ebp,%ecx
  8013da:	d3 e2                	shl    %cl,%edx
  8013dc:	89 c1                	mov    %eax,%ecx
  8013de:	d3 ef                	shr    %cl,%edi
  8013e0:	09 d7                	or     %edx,%edi
  8013e2:	89 f2                	mov    %esi,%edx
  8013e4:	89 f8                	mov    %edi,%eax
  8013e6:	f7 74 24 08          	divl   0x8(%esp)
  8013ea:	89 d6                	mov    %edx,%esi
  8013ec:	89 c7                	mov    %eax,%edi
  8013ee:	f7 24 24             	mull   (%esp)
  8013f1:	39 d6                	cmp    %edx,%esi
  8013f3:	89 14 24             	mov    %edx,(%esp)
  8013f6:	72 30                	jb     801428 <__udivdi3+0x118>
  8013f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013fc:	89 e9                	mov    %ebp,%ecx
  8013fe:	d3 e2                	shl    %cl,%edx
  801400:	39 c2                	cmp    %eax,%edx
  801402:	73 05                	jae    801409 <__udivdi3+0xf9>
  801404:	3b 34 24             	cmp    (%esp),%esi
  801407:	74 1f                	je     801428 <__udivdi3+0x118>
  801409:	89 f8                	mov    %edi,%eax
  80140b:	31 d2                	xor    %edx,%edx
  80140d:	e9 7a ff ff ff       	jmp    80138c <__udivdi3+0x7c>
  801412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801418:	31 d2                	xor    %edx,%edx
  80141a:	b8 01 00 00 00       	mov    $0x1,%eax
  80141f:	e9 68 ff ff ff       	jmp    80138c <__udivdi3+0x7c>
  801424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801428:	8d 47 ff             	lea    -0x1(%edi),%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	83 c4 0c             	add    $0xc,%esp
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    
  801434:	66 90                	xchg   %ax,%ax
  801436:	66 90                	xchg   %ax,%ax
  801438:	66 90                	xchg   %ax,%ax
  80143a:	66 90                	xchg   %ax,%ax
  80143c:	66 90                	xchg   %ax,%ax
  80143e:	66 90                	xchg   %ax,%ax

00801440 <__umoddi3>:
  801440:	55                   	push   %ebp
  801441:	57                   	push   %edi
  801442:	56                   	push   %esi
  801443:	83 ec 14             	sub    $0x14,%esp
  801446:	8b 44 24 28          	mov    0x28(%esp),%eax
  80144a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80144e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801452:	89 c7                	mov    %eax,%edi
  801454:	89 44 24 04          	mov    %eax,0x4(%esp)
  801458:	8b 44 24 30          	mov    0x30(%esp),%eax
  80145c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801460:	89 34 24             	mov    %esi,(%esp)
  801463:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801467:	85 c0                	test   %eax,%eax
  801469:	89 c2                	mov    %eax,%edx
  80146b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80146f:	75 17                	jne    801488 <__umoddi3+0x48>
  801471:	39 fe                	cmp    %edi,%esi
  801473:	76 4b                	jbe    8014c0 <__umoddi3+0x80>
  801475:	89 c8                	mov    %ecx,%eax
  801477:	89 fa                	mov    %edi,%edx
  801479:	f7 f6                	div    %esi
  80147b:	89 d0                	mov    %edx,%eax
  80147d:	31 d2                	xor    %edx,%edx
  80147f:	83 c4 14             	add    $0x14,%esp
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    
  801486:	66 90                	xchg   %ax,%ax
  801488:	39 f8                	cmp    %edi,%eax
  80148a:	77 54                	ja     8014e0 <__umoddi3+0xa0>
  80148c:	0f bd e8             	bsr    %eax,%ebp
  80148f:	83 f5 1f             	xor    $0x1f,%ebp
  801492:	75 5c                	jne    8014f0 <__umoddi3+0xb0>
  801494:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801498:	39 3c 24             	cmp    %edi,(%esp)
  80149b:	0f 87 e7 00 00 00    	ja     801588 <__umoddi3+0x148>
  8014a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014a5:	29 f1                	sub    %esi,%ecx
  8014a7:	19 c7                	sbb    %eax,%edi
  8014a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014b9:	83 c4 14             	add    $0x14,%esp
  8014bc:	5e                   	pop    %esi
  8014bd:	5f                   	pop    %edi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    
  8014c0:	85 f6                	test   %esi,%esi
  8014c2:	89 f5                	mov    %esi,%ebp
  8014c4:	75 0b                	jne    8014d1 <__umoddi3+0x91>
  8014c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	f7 f6                	div    %esi
  8014cf:	89 c5                	mov    %eax,%ebp
  8014d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014d5:	31 d2                	xor    %edx,%edx
  8014d7:	f7 f5                	div    %ebp
  8014d9:	89 c8                	mov    %ecx,%eax
  8014db:	f7 f5                	div    %ebp
  8014dd:	eb 9c                	jmp    80147b <__umoddi3+0x3b>
  8014df:	90                   	nop
  8014e0:	89 c8                	mov    %ecx,%eax
  8014e2:	89 fa                	mov    %edi,%edx
  8014e4:	83 c4 14             	add    $0x14,%esp
  8014e7:	5e                   	pop    %esi
  8014e8:	5f                   	pop    %edi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    
  8014eb:	90                   	nop
  8014ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014f0:	8b 04 24             	mov    (%esp),%eax
  8014f3:	be 20 00 00 00       	mov    $0x20,%esi
  8014f8:	89 e9                	mov    %ebp,%ecx
  8014fa:	29 ee                	sub    %ebp,%esi
  8014fc:	d3 e2                	shl    %cl,%edx
  8014fe:	89 f1                	mov    %esi,%ecx
  801500:	d3 e8                	shr    %cl,%eax
  801502:	89 e9                	mov    %ebp,%ecx
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	8b 04 24             	mov    (%esp),%eax
  80150b:	09 54 24 04          	or     %edx,0x4(%esp)
  80150f:	89 fa                	mov    %edi,%edx
  801511:	d3 e0                	shl    %cl,%eax
  801513:	89 f1                	mov    %esi,%ecx
  801515:	89 44 24 08          	mov    %eax,0x8(%esp)
  801519:	8b 44 24 10          	mov    0x10(%esp),%eax
  80151d:	d3 ea                	shr    %cl,%edx
  80151f:	89 e9                	mov    %ebp,%ecx
  801521:	d3 e7                	shl    %cl,%edi
  801523:	89 f1                	mov    %esi,%ecx
  801525:	d3 e8                	shr    %cl,%eax
  801527:	89 e9                	mov    %ebp,%ecx
  801529:	09 f8                	or     %edi,%eax
  80152b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80152f:	f7 74 24 04          	divl   0x4(%esp)
  801533:	d3 e7                	shl    %cl,%edi
  801535:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801539:	89 d7                	mov    %edx,%edi
  80153b:	f7 64 24 08          	mull   0x8(%esp)
  80153f:	39 d7                	cmp    %edx,%edi
  801541:	89 c1                	mov    %eax,%ecx
  801543:	89 14 24             	mov    %edx,(%esp)
  801546:	72 2c                	jb     801574 <__umoddi3+0x134>
  801548:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80154c:	72 22                	jb     801570 <__umoddi3+0x130>
  80154e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801552:	29 c8                	sub    %ecx,%eax
  801554:	19 d7                	sbb    %edx,%edi
  801556:	89 e9                	mov    %ebp,%ecx
  801558:	89 fa                	mov    %edi,%edx
  80155a:	d3 e8                	shr    %cl,%eax
  80155c:	89 f1                	mov    %esi,%ecx
  80155e:	d3 e2                	shl    %cl,%edx
  801560:	89 e9                	mov    %ebp,%ecx
  801562:	d3 ef                	shr    %cl,%edi
  801564:	09 d0                	or     %edx,%eax
  801566:	89 fa                	mov    %edi,%edx
  801568:	83 c4 14             	add    $0x14,%esp
  80156b:	5e                   	pop    %esi
  80156c:	5f                   	pop    %edi
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    
  80156f:	90                   	nop
  801570:	39 d7                	cmp    %edx,%edi
  801572:	75 da                	jne    80154e <__umoddi3+0x10e>
  801574:	8b 14 24             	mov    (%esp),%edx
  801577:	89 c1                	mov    %eax,%ecx
  801579:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80157d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801581:	eb cb                	jmp    80154e <__umoddi3+0x10e>
  801583:	90                   	nop
  801584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801588:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80158c:	0f 82 0f ff ff ff    	jb     8014a1 <__umoddi3+0x61>
  801592:	e9 1a ff ff ff       	jmp    8014b1 <__umoddi3+0x71>
