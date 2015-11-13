
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 16 01 00 00       	call   800147 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 17 17 00 00       	call   801758 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 5e                	je     8000a6 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  80004e:	e8 f2 10 00 00       	call   801145 <sys_getenvid>
  800053:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005b:	c7 04 24 e0 1b 80 00 	movl   $0x801be0,(%esp)
  800062:	e8 df 01 00 00       	call   800246 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800067:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006a:	e8 d6 10 00 00       	call   801145 <sys_getenvid>
  80006f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 fa 1b 80 00 	movl   $0x801bfa,(%esp)
  80007e:	e8 c3 01 00 00       	call   800246 <cprintf>
		ipc_send(who, 0, 0, 0);
  800083:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008a:	00 
  80008b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009a:	00 
  80009b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009e:	89 04 24             	mov    %eax,(%esp)
  8000a1:	e8 4a 17 00 00       	call   8017f0 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 bf 16 00 00       	call   801780 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c1:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  8000c7:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000ca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000cd:	a1 04 30 80 00       	mov    0x803004,%eax
  8000d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d5:	e8 6b 10 00 00       	call   801145 <sys_getenvid>
  8000da:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8000de:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000e9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	c7 04 24 10 1c 80 00 	movl   $0x801c10,(%esp)
  8000f8:	e8 49 01 00 00       	call   800246 <cprintf>
		if (val == 10)
  8000fd:	a1 04 30 80 00       	mov    0x803004,%eax
  800102:	83 f8 0a             	cmp    $0xa,%eax
  800105:	74 38                	je     80013f <umain+0x10c>
			return;
		++val;
  800107:	83 c0 01             	add    $0x1,%eax
  80010a:	a3 04 30 80 00       	mov    %eax,0x803004
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 be 16 00 00       	call   8017f0 <ipc_send>
		if (val == 10)
  800132:	83 3d 04 30 80 00 0a 	cmpl   $0xa,0x803004
  800139:	0f 85 67 ff ff ff    	jne    8000a6 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 3c             	add    $0x3c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	83 ec 10             	sub    $0x10,%esp
  80014f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800152:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800155:	e8 eb 0f 00 00       	call   801145 <sys_getenvid>
  80015a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800162:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800167:	a3 08 30 80 00       	mov    %eax,0x803008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016c:	85 db                	test   %ebx,%ebx
  80016e:	7e 07                	jle    800177 <libmain+0x30>
		binaryname = argv[0];
  800170:	8b 06                	mov    (%esi),%eax
  800172:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800177:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017b:	89 1c 24             	mov    %ebx,(%esp)
  80017e:	e8 b0 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800183:	e8 07 00 00 00       	call   80018f <exit>
}
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800195:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019c:	e8 52 0f 00 00       	call   8010f3 <sys_env_destroy>
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 14             	sub    $0x14,%esp
  8001aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ad:	8b 13                	mov    (%ebx),%edx
  8001af:	8d 42 01             	lea    0x1(%edx),%eax
  8001b2:	89 03                	mov    %eax,(%ebx)
  8001b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c0:	75 19                	jne    8001db <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c9:	00 
  8001ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 e1 0e 00 00       	call   8010b6 <sys_cputs>
		b->idx = 0;
  8001d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001df:	83 c4 14             	add    $0x14,%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f5:	00 00 00 
	b.cnt = 0;
  8001f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800202:	8b 45 0c             	mov    0xc(%ebp),%eax
  800205:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021a:	c7 04 24 a3 01 80 00 	movl   $0x8001a3,(%esp)
  800221:	e8 a9 02 00 00       	call   8004cf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800226:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	e8 78 0e 00 00       	call   8010b6 <sys_cputs>

	return b.cnt;
}
  80023e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	e8 87 ff ff ff       	call   8001e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

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
  8002cf:	e8 7c 16 00 00       	call   801950 <__udivdi3>
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
  80032f:	e8 4c 17 00 00       	call   801a80 <__umoddi3>
  800334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800338:	0f be 80 40 1c 80 00 	movsbl 0x801c40(%eax),%eax
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
  8003cf:	e8 7c 15 00 00       	call   801950 <__udivdi3>
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
  80042d:	e8 4e 16 00 00       	call   801a80 <__umoddi3>
  800432:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800436:	0f be 80 40 1c 80 00 	movsbl 0x801c40(%eax),%eax
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
  800554:	ff 24 8d 00 1d 80 00 	jmp    *0x801d00(,%ecx,4)
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
  8005f1:	8b 14 85 c0 1f 80 00 	mov    0x801fc0(,%eax,4),%edx
  8005f8:	85 d2                	test   %edx,%edx
  8005fa:	75 20                	jne    80061c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8005fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800600:	c7 44 24 08 58 1c 80 	movl   $0x801c58,0x8(%esp)
  800607:	00 
  800608:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060c:	8b 45 08             	mov    0x8(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	e8 90 fe ff ff       	call   8004a7 <printfmt>
  800617:	e9 d8 fe ff ff       	jmp    8004f4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80061c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800620:	c7 44 24 08 61 1c 80 	movl   $0x801c61,0x8(%esp)
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
  800652:	b8 51 1c 80 00       	mov    $0x801c51,%eax
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
  80093e:	ff 24 8d 58 1e 80 00 	jmp    *0x801e58(,%ecx,4)
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
  8009d7:	8b 14 85 c0 1f 80 00 	mov    0x801fc0(,%eax,4),%edx
  8009de:	85 d2                	test   %edx,%edx
  8009e0:	75 23                	jne    800a05 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  8009e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e6:	c7 44 24 08 58 1c 80 	movl   $0x801c58,0x8(%esp)
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
  800a09:	c7 44 24 08 61 1c 80 	movl   $0x801c61,0x8(%esp)
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
  800a3b:	b8 51 1c 80 00       	mov    $0x801c51,%eax
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
  801121:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  801128:	00 
  801129:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801130:	00 
  801131:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801138:	e8 49 07 00 00       	call   801886 <_panic>

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
  8011b3:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8011ca:	e8 b7 06 00 00       	call   801886 <_panic>

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
  801206:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  80120d:	00 
  80120e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801215:	00 
  801216:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  80121d:	e8 64 06 00 00       	call   801886 <_panic>

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
  801259:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  801260:	00 
  801261:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801270:	e8 11 06 00 00       	call   801886 <_panic>

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
  8012ac:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  8012b3:	00 
  8012b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012bb:	00 
  8012bc:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8012c3:	e8 be 05 00 00       	call   801886 <_panic>

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
  8012ff:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  801306:	00 
  801307:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80130e:	00 
  80130f:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801316:	e8 6b 05 00 00       	call   801886 <_panic>

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
  801374:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  80137b:	00 
  80137c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801383:	00 
  801384:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  80138b:	e8 f6 04 00 00       	call   801886 <_panic>

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

00801398 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	57                   	push   %edi
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
  80139e:	83 ec 2c             	sub    $0x2c,%esp
	void *addr = (void *) utf->utf_fault_va;
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a4:	8b 30                	mov    (%eax),%esi
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf(" pgfault : fault va is  %08x\n", ( uint32_t ) addr ) ; 
	//cprintf(" pgfault : fault eip is  %08x\n", ( uint32_t ) utf->utf_eip ) ; 
	pde_t * pde_ptr = ( pde_t * ) ( UVPT + ( PDX(UVPT) << 12 ) + ( PDX(addr) << 2 ) ) ; 
  8013a6:	89 f0                	mov    %esi,%eax
  8013a8:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( UVPT + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  8013ab:	89 c1                	mov    %eax,%ecx
  8013ad:	c1 e1 0c             	shl    $0xc,%ecx
  8013b0:	89 f2                	mov    %esi,%edx
  8013b2:	c1 ea 0a             	shr    $0xa,%edx
  8013b5:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8013bb:	8d bc 11 00 00 40 ef 	lea    -0x10c00000(%ecx,%edx,1),%edi
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  8013c2:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  8013c9:	01 
  8013ca:	75 1c                	jne    8013e8 <pgfault+0x50>
		panic(" in inc/fork.c <pgfault> : Page Directory Entry doesn't exsist!\n");
  8013cc:	c7 44 24 08 14 20 80 	movl   $0x802014,0x8(%esp)
  8013d3:	00 
  8013d4:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8013db:	00 
  8013dc:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8013e3:	e8 9e 04 00 00       	call   801886 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  8013e8:	8b 07                	mov    (%edi),%eax
  8013ea:	a8 01                	test   $0x1,%al
  8013ec:	75 1c                	jne    80140a <pgfault+0x72>
		panic(" in inc/fork.c <pgfault> : Page Table Entry doesn't exsist!\n");
  8013ee:	c7 44 24 08 58 20 80 	movl   $0x802058,0x8(%esp)
  8013f5:	00 
  8013f6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013fd:	00 
  8013fe:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  801405:	e8 7c 04 00 00       	call   801886 <_panic>
	if (!( ( ( *pte_ptr ) & PTE_W ) || ( ( *pte_ptr ) & PTE_COW ) ) )
  80140a:	a9 02 08 00 00       	test   $0x802,%eax
  80140f:	75 1c                	jne    80142d <pgfault+0x95>
		panic(" in inc/fork.c <pgfault> : Invalid page!\n");
  801411:	c7 44 24 08 98 20 80 	movl   $0x802098,0x8(%esp)
  801418:	00 
  801419:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801420:	00 
  801421:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  801428:	e8 59 04 00 00       	call   801886 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid() ;
  80142d:	e8 13 fd ff ff       	call   801145 <sys_getenvid>
  801432:	89 c3                	mov    %eax,%ebx
	//cprintf(" pgfault : %d\n %08x\n",envid , PFTEMP); 
	sys_page_alloc( envid , ( void * ) PFTEMP , (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W);  
  801434:	8b 07                	mov    (%edi),%eax
  801436:	25 05 06 00 00       	and    $0x605,%eax
  80143b:	83 c8 02             	or     $0x2,%eax
  80143e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801442:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801449:	00 
  80144a:	89 1c 24             	mov    %ebx,(%esp)
  80144d:	e8 31 fd ff ff       	call   801183 <sys_page_alloc>
	//cprintf(" Did it reach here and made an alloc call?\n");
	memmove( ( void * ) PFTEMP , ( void * ) ROUNDDOWN( addr , PGSIZE ) , PGSIZE ) ; 
  801452:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801458:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80145f:	00 
  801460:	89 74 24 04          	mov    %esi,0x4(%esp)
  801464:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80146b:	e8 94 fa ff ff       	call   800f04 <memmove>
	sys_page_map( envid , ( void * ) PFTEMP , envid , ( void * ) ROUNDDOWN( addr , PGSIZE ) ,  (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W );  
  801470:	8b 07                	mov    (%edi),%eax
  801472:	25 05 06 00 00       	and    $0x605,%eax
  801477:	83 c8 02             	or     $0x2,%eax
  80147a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80147e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801482:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801486:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80148d:	00 
  80148e:	89 1c 24             	mov    %ebx,(%esp)
  801491:	e8 41 fd ff ff       	call   8011d7 <sys_page_map>
	sys_page_unmap( envid , PFTEMP ) ; 
  801496:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80149d:	00 
  80149e:	89 1c 24             	mov    %ebx,(%esp)
  8014a1:	e8 84 fd ff ff       	call   80122a <sys_page_unmap>
	//panic("pgfault not implemented");
}
  8014a6:	83 c4 2c             	add    $0x2c,%esp
  8014a9:	5b                   	pop    %ebx
  8014aa:	5e                   	pop    %esi
  8014ab:	5f                   	pop    %edi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	57                   	push   %edi
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// First , set handler
	set_pgfault_handler(pgfault); 
  8014b7:	c7 04 24 98 13 80 00 	movl   $0x801398,(%esp)
  8014be:	e8 19 04 00 00       	call   8018dc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014c3:	b8 07 00 00 00       	mov    $0x7,%eax
  8014c8:	cd 30                	int    $0x30
  8014ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8014cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	79 1c                	jns    8014f0 <fork+0x42>
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
  8014d4:	c7 44 24 08 c4 20 80 	movl   $0x8020c4,0x8(%esp)
  8014db:	00 
  8014dc:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  8014e3:	00 
  8014e4:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8014eb:	e8 96 03 00 00       	call   801886 <_panic>
	if ( childid == 0 ) {
  8014f0:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014f4:	74 17                	je     80150d <fork+0x5f>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  8014f6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8014fb:	c1 e8 16             	shr    $0x16,%eax
  8014fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801501:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801508:	e9 22 02 00 00       	jmp    80172f <fork+0x281>
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
	if ( childid == 0 ) {
		thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80150d:	e8 33 fc ff ff       	call   801145 <sys_getenvid>
  801512:	25 ff 03 00 00       	and    $0x3ff,%eax
  801517:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80151a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80151f:	a3 08 30 80 00       	mov    %eax,0x803008
		return 0 ;
  801524:	b8 00 00 00 00       	mov    $0x0,%eax
  801529:	e9 22 02 00 00       	jmp    801750 <fork+0x2a2>
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
  80152e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801531:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  801538:	01 
  801539:	0f 84 ec 01 00 00    	je     80172b <fork+0x27d>
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
  80153f:	89 c6                	mov    %eax,%esi
  801541:	c1 e0 0c             	shl    $0xc,%eax
  801544:	8d b8 00 00 40 ef    	lea    -0x10c00000(%eax),%edi
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
			     ( ptx != PTX(UXSTACKTOP-PGSIZE) ) ) {
				//cprintf(" fork : pdx : %d , ptx : %d\n" , pdx , ptx ) ; 
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
  80154a:	c1 e6 16             	shl    $0x16,%esi
  80154d:	bb 00 00 00 00       	mov    $0x0,%ebx
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
			if ( ! ( ( * pte_ptr ) & PTE_P ) )  continue ; 
  801552:	f6 04 9f 01          	testb  $0x1,(%edi,%ebx,4)
  801556:	0f 84 ba 01 00 00    	je     801716 <fork+0x268>
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
  80155c:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  801562:	75 0d                	jne    801571 <fork+0xc3>
  801564:	81 7d dc ba 03 00 00 	cmpl   $0x3ba,-0x24(%ebp)
  80156b:	0f 84 8a 01 00 00    	je     8016fb <fork+0x24d>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid() ; 
  801571:	e8 cf fb ff ff       	call   801145 <sys_getenvid>
  801576:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t addr = pn * PGSIZE ;
	//cprintf(" duppage : now envid is : %d\n", sys_getenvid() ) ;
	//cprintf(" duppage : page address is %08x %d %d\n" , addr,PDX(addr),PTX(addr) ) ;
	pde_t * pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd ) + ( PDX(addr) << 2 ) ) ; 
  801579:	89 f0                	mov    %esi,%eax
  80157b:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  80157e:	89 c1                	mov    %eax,%ecx
  801580:	c1 e1 0c             	shl    $0xc,%ecx
  801583:	81 c1 00 00 40 ef    	add    $0xef400000,%ecx
  801589:	89 f2                	mov    %esi,%edx
  80158b:	c1 ea 0a             	shr    $0xa,%edx
  80158e:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801594:	01 ca                	add    %ecx,%edx
	
	//cprintf(" duppage : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
	//cprintf(" duppage : pte_ptr's value is : %08x\n" , ( * pte_ptr ) ) ;
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  801596:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  80159b:	f6 04 81 01          	testb  $0x1,(%ecx,%eax,4)
  80159f:	75 1c                	jne    8015bd <fork+0x10f>
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
  8015a1:	c7 44 24 08 f8 20 80 	movl   $0x8020f8,0x8(%esp)
  8015a8:	00 
  8015a9:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8015b0:	00 
  8015b1:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8015b8:	e8 c9 02 00 00       	call   801886 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  8015bd:	8b 02                	mov    (%edx),%eax
  8015bf:	a8 01                	test   $0x1,%al
  8015c1:	75 1c                	jne    8015df <fork+0x131>
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
  8015c3:	c7 44 24 08 3c 21 80 	movl   $0x80213c,0x8(%esp)
  8015ca:	00 
  8015cb:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8015d2:	00 
  8015d3:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8015da:	e8 a7 02 00 00       	call   801886 <_panic>
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	if ( perm & PTE_W ) {
  8015e7:	a8 02                	test   $0x2,%al
  8015e9:	0f 84 8b 00 00 00    	je     80167a <fork+0x1cc>
		if ( sys_page_map( curenvid , ( void * ) addr , 
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
  8015ef:	89 d0                	mov    %edx,%eax
  8015f1:	83 f0 02             	xor    $0x2,%eax
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
	if (!( ( * pte_ptr ) & PTE_P ) ) 
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
	if ( perm & PTE_W ) {
		if ( sys_page_map( curenvid , ( void * ) addr , 
  8015f4:	80 cc 08             	or     $0x8,%ah
  8015f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801602:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801605:	89 44 24 08          	mov    %eax,0x8(%esp)
  801609:	89 74 24 04          	mov    %esi,0x4(%esp)
  80160d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801610:	89 04 24             	mov    %eax,(%esp)
  801613:	e8 bf fb ff ff       	call   8011d7 <sys_page_map>
  801618:	85 c0                	test   %eax,%eax
  80161a:	79 1c                	jns    801638 <fork+0x18a>
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page! %e\n");
  80161c:	c7 44 24 08 7c 21 80 	movl   $0x80217c,0x8(%esp)
  801623:	00 
  801624:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80162b:	00 
  80162c:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  801633:	e8 4e 02 00 00       	call   801886 <_panic>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  801638:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80163b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80163f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801643:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801646:	89 44 24 08          	mov    %eax,0x8(%esp)
  80164a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164e:	89 04 24             	mov    %eax,(%esp)
  801651:	e8 81 fb ff ff       	call   8011d7 <sys_page_map>
  801656:	85 c0                	test   %eax,%eax
  801658:	0f 89 b8 00 00 00    	jns    801716 <fork+0x268>
				   curenvid , ( void * ) addr , 
				   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  80165e:	c7 44 24 08 b4 21 80 	movl   $0x8021b4,0x8(%esp)
  801665:	00 
  801666:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80166d:	00 
  80166e:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  801675:	e8 0c 02 00 00       	call   801886 <_panic>
		return 0 ; 	
	}  
	if ( perm & PTE_COW ) {
  80167a:	f6 c4 08             	test   $0x8,%ah
  80167d:	74 3e                	je     8016bd <fork+0x20f>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  80167f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801683:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801687:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80168a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80168e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801695:	89 04 24             	mov    %eax,(%esp)
  801698:	e8 3a fb ff ff       	call   8011d7 <sys_page_map>
  80169d:	85 c0                	test   %eax,%eax
  80169f:	79 75                	jns    801716 <fork+0x268>
                                   envid    , ( void * ) addr , 
                                   perm ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  8016a1:	c7 44 24 08 b4 21 80 	movl   $0x8021b4,0x8(%esp)
  8016a8:	00 
  8016a9:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  8016b0:	00 
  8016b1:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8016b8:	e8 c9 01 00 00       	call   801886 <_panic>
		return 0 ;
	}
	if ( sys_page_map( curenvid , ( void * ) addr , 
  8016bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016d3:	89 04 24             	mov    %eax,(%esp)
  8016d6:	e8 fc fa ff ff       	call   8011d7 <sys_page_map>
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	79 37                	jns    801716 <fork+0x268>
		           envid    , ( void * ) addr , 
			   perm ) < 0 ) 
		panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  8016df:	c7 44 24 08 b4 21 80 	movl   $0x8021b4,0x8(%esp)
  8016e6:	00 
  8016e7:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8016ee:	00 
  8016ef:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8016f6:	e8 8b 01 00 00       	call   801886 <_panic>
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
  8016fb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801702:	00 
  801703:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80170a:	ee 
  80170b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	e8 6d fa ff ff       	call   801183 <sys_page_alloc>
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
  801716:	83 c3 01             	add    $0x1,%ebx
  801719:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80171f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801725:	0f 85 27 fe ff ff    	jne    801552 <fork+0xa4>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  80172b:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  80172f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801732:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  801735:	0f 85 f3 fd ff ff    	jne    80152e <fork+0x80>
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
		}						
	}
	sys_env_set_status( childid , ENV_RUNNABLE ) ;
  80173b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801742:	00 
  801743:	8b 7d d0             	mov    -0x30(%ebp),%edi
  801746:	89 3c 24             	mov    %edi,(%esp)
  801749:	e8 2f fb ff ff       	call   80127d <sys_env_set_status>
	return childid ;
  80174e:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801750:	83 c4 3c             	add    $0x3c,%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5f                   	pop    %edi
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    

00801758 <sfork>:

// Challenge!
int
sfork(void)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80175e:	c7 44 24 08 f3 21 80 	movl   $0x8021f3,0x8(%esp)
  801765:	00 
  801766:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  80176d:	00 
  80176e:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  801775:	e8 0c 01 00 00       	call   801886 <_panic>
  80177a:	66 90                	xchg   %ax,%ax
  80177c:	66 90                	xchg   %ax,%ax
  80177e:	66 90                	xchg   %ax,%ax

00801780 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	83 ec 10             	sub    $0x10,%esp
  801788:	8b 75 08             	mov    0x8(%ebp),%esi
  80178b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int result = 0 ; 
	if ( pg ) result = sys_ipc_recv(pg);	
  801791:	85 c0                	test   %eax,%eax
  801793:	74 0a                	je     80179f <ipc_recv+0x1f>
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	e8 a9 fb ff ff       	call   801346 <sys_ipc_recv>
  80179d:	eb 0c                	jmp    8017ab <ipc_recv+0x2b>
	     else result = sys_ipc_recv((void*)UTOP);
  80179f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8017a6:	e8 9b fb ff ff       	call   801346 <sys_ipc_recv>
	if ( result < 0 ) {
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	79 16                	jns    8017c5 <ipc_recv+0x45>
		if ( from_env_store ) 
  8017af:	85 f6                	test   %esi,%esi
  8017b1:	74 06                	je     8017b9 <ipc_recv+0x39>
			(*from_env_store) = 0 ;
  8017b3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if ( perm_store)
  8017b9:	85 db                	test   %ebx,%ebx
  8017bb:	74 2c                	je     8017e9 <ipc_recv+0x69>
			(*perm_store) = 0 ;	
  8017bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017c3:	eb 24                	jmp    8017e9 <ipc_recv+0x69>
		return result; 
	}
	if ( from_env_store ) 
  8017c5:	85 f6                	test   %esi,%esi
  8017c7:	74 0a                	je     8017d3 <ipc_recv+0x53>
		(*from_env_store) = thisenv->env_ipc_from ;
  8017c9:	a1 08 30 80 00       	mov    0x803008,%eax
  8017ce:	8b 40 74             	mov    0x74(%eax),%eax
  8017d1:	89 06                	mov    %eax,(%esi)
	if ( perm_store)
  8017d3:	85 db                	test   %ebx,%ebx
  8017d5:	74 0a                	je     8017e1 <ipc_recv+0x61>
		(*perm_store) = thisenv->env_ipc_perm ;	
  8017d7:	a1 08 30 80 00       	mov    0x803008,%eax
  8017dc:	8b 40 78             	mov    0x78(%eax),%eax
  8017df:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8017e1:	a1 08 30 80 00       	mov    0x803008,%eax
  8017e6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	5b                   	pop    %ebx
  8017ed:	5e                   	pop    %esi
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	57                   	push   %edi
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 1c             	sub    $0x1c,%esp
  8017f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = -E_IPC_NOT_RECV ; 
	while ( result == -E_IPC_NOT_RECV ) { 
		if ( pg ) 
  801802:	85 db                	test   %ebx,%ebx
  801804:	74 19                	je     80181f <ipc_send+0x2f>
			result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  801806:	8b 45 14             	mov    0x14(%ebp),%eax
  801809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80180d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801811:	89 74 24 04          	mov    %esi,0x4(%esp)
  801815:	89 3c 24             	mov    %edi,(%esp)
  801818:	e8 06 fb ff ff       	call   801323 <sys_ipc_try_send>
  80181d:	eb 1b                	jmp    80183a <ipc_send+0x4a>
		else
			result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  80181f:	8b 45 14             	mov    0x14(%ebp),%eax
  801822:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801826:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80182d:	ee 
  80182e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801832:	89 3c 24             	mov    %edi,(%esp)
  801835:	e8 e9 fa ff ff       	call   801323 <sys_ipc_try_send>
		if ( result != -E_IPC_NOT_RECV ) break ; 
  80183a:	83 f8 f8             	cmp    $0xfffffff8,%eax
  80183d:	75 07                	jne    801846 <ipc_send+0x56>
		sys_yield();
  80183f:	e8 20 f9 ff ff       	call   801164 <sys_yield>
  801844:	eb bc                	jmp    801802 <ipc_send+0x12>
	}
	if ( result == 0 ) return ; 
	if ( result == -E_IPC_NOT_RECV ) return ;
	//panic("ipc_send not implemented");
}
  801846:	83 c4 1c             	add    $0x1c,%esp
  801849:	5b                   	pop    %ebx
  80184a:	5e                   	pop    %esi
  80184b:	5f                   	pop    %edi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801854:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801859:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80185c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801862:	8b 52 50             	mov    0x50(%edx),%edx
  801865:	39 ca                	cmp    %ecx,%edx
  801867:	75 0d                	jne    801876 <ipc_find_env+0x28>
			return envs[i].env_id;
  801869:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80186c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801871:	8b 40 40             	mov    0x40(%eax),%eax
  801874:	eb 0e                	jmp    801884 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801876:	83 c0 01             	add    $0x1,%eax
  801879:	3d 00 04 00 00       	cmp    $0x400,%eax
  80187e:	75 d9                	jne    801859 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801880:	66 b8 00 00          	mov    $0x0,%ax
}
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80188e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801891:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801897:	e8 a9 f8 ff ff       	call   801145 <sys_getenvid>
  80189c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189f:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8018a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8018ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b2:	c7 04 24 0c 22 80 00 	movl   $0x80220c,(%esp)
  8018b9:	e8 88 e9 ff ff       	call   800246 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8018be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c5:	89 04 24             	mov    %eax,(%esp)
  8018c8:	e8 18 e9 ff ff       	call   8001e5 <vcprintf>
	cprintf("\n");
  8018cd:	c7 04 24 f8 1b 80 00 	movl   $0x801bf8,(%esp)
  8018d4:	e8 6d e9 ff ff       	call   800246 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018d9:	cc                   	int3   
  8018da:	eb fd                	jmp    8018d9 <_panic+0x53>

008018dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8018e2:	83 3d 0c 30 80 00 00 	cmpl   $0x0,0x80300c
  8018e9:	75 32                	jne    80191d <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  8018eb:	e8 55 f8 ff ff       	call   801145 <sys_getenvid>
  8018f0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018f7:	00 
  8018f8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8018ff:	ee 
  801900:	89 04 24             	mov    %eax,(%esp)
  801903:	e8 7b f8 ff ff       	call   801183 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  801908:	e8 38 f8 ff ff       	call   801145 <sys_getenvid>
  80190d:	c7 44 24 04 27 19 80 	movl   $0x801927,0x4(%esp)
  801914:	00 
  801915:	89 04 24             	mov    %eax,(%esp)
  801918:	e8 b3 f9 ff ff       	call   8012d0 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801927:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801928:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  80192d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80192f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  801932:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  801935:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  801939:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  80193d:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  801940:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  801944:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  801946:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  801947:	83 c4 04             	add    $0x4,%esp
	popfl 	
  80194a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80194b:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80194c:	c3                   	ret    
  80194d:	66 90                	xchg   %ax,%ax
  80194f:	90                   	nop

00801950 <__udivdi3>:
  801950:	55                   	push   %ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	8b 44 24 28          	mov    0x28(%esp),%eax
  80195a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80195e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801962:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801966:	85 c0                	test   %eax,%eax
  801968:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80196c:	89 ea                	mov    %ebp,%edx
  80196e:	89 0c 24             	mov    %ecx,(%esp)
  801971:	75 2d                	jne    8019a0 <__udivdi3+0x50>
  801973:	39 e9                	cmp    %ebp,%ecx
  801975:	77 61                	ja     8019d8 <__udivdi3+0x88>
  801977:	85 c9                	test   %ecx,%ecx
  801979:	89 ce                	mov    %ecx,%esi
  80197b:	75 0b                	jne    801988 <__udivdi3+0x38>
  80197d:	b8 01 00 00 00       	mov    $0x1,%eax
  801982:	31 d2                	xor    %edx,%edx
  801984:	f7 f1                	div    %ecx
  801986:	89 c6                	mov    %eax,%esi
  801988:	31 d2                	xor    %edx,%edx
  80198a:	89 e8                	mov    %ebp,%eax
  80198c:	f7 f6                	div    %esi
  80198e:	89 c5                	mov    %eax,%ebp
  801990:	89 f8                	mov    %edi,%eax
  801992:	f7 f6                	div    %esi
  801994:	89 ea                	mov    %ebp,%edx
  801996:	83 c4 0c             	add    $0xc,%esp
  801999:	5e                   	pop    %esi
  80199a:	5f                   	pop    %edi
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    
  80199d:	8d 76 00             	lea    0x0(%esi),%esi
  8019a0:	39 e8                	cmp    %ebp,%eax
  8019a2:	77 24                	ja     8019c8 <__udivdi3+0x78>
  8019a4:	0f bd e8             	bsr    %eax,%ebp
  8019a7:	83 f5 1f             	xor    $0x1f,%ebp
  8019aa:	75 3c                	jne    8019e8 <__udivdi3+0x98>
  8019ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8019b0:	39 34 24             	cmp    %esi,(%esp)
  8019b3:	0f 86 9f 00 00 00    	jbe    801a58 <__udivdi3+0x108>
  8019b9:	39 d0                	cmp    %edx,%eax
  8019bb:	0f 82 97 00 00 00    	jb     801a58 <__udivdi3+0x108>
  8019c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8019c8:	31 d2                	xor    %edx,%edx
  8019ca:	31 c0                	xor    %eax,%eax
  8019cc:	83 c4 0c             	add    $0xc,%esp
  8019cf:	5e                   	pop    %esi
  8019d0:	5f                   	pop    %edi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    
  8019d3:	90                   	nop
  8019d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019d8:	89 f8                	mov    %edi,%eax
  8019da:	f7 f1                	div    %ecx
  8019dc:	31 d2                	xor    %edx,%edx
  8019de:	83 c4 0c             	add    $0xc,%esp
  8019e1:	5e                   	pop    %esi
  8019e2:	5f                   	pop    %edi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    
  8019e5:	8d 76 00             	lea    0x0(%esi),%esi
  8019e8:	89 e9                	mov    %ebp,%ecx
  8019ea:	8b 3c 24             	mov    (%esp),%edi
  8019ed:	d3 e0                	shl    %cl,%eax
  8019ef:	89 c6                	mov    %eax,%esi
  8019f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8019f6:	29 e8                	sub    %ebp,%eax
  8019f8:	89 c1                	mov    %eax,%ecx
  8019fa:	d3 ef                	shr    %cl,%edi
  8019fc:	89 e9                	mov    %ebp,%ecx
  8019fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a02:	8b 3c 24             	mov    (%esp),%edi
  801a05:	09 74 24 08          	or     %esi,0x8(%esp)
  801a09:	89 d6                	mov    %edx,%esi
  801a0b:	d3 e7                	shl    %cl,%edi
  801a0d:	89 c1                	mov    %eax,%ecx
  801a0f:	89 3c 24             	mov    %edi,(%esp)
  801a12:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a16:	d3 ee                	shr    %cl,%esi
  801a18:	89 e9                	mov    %ebp,%ecx
  801a1a:	d3 e2                	shl    %cl,%edx
  801a1c:	89 c1                	mov    %eax,%ecx
  801a1e:	d3 ef                	shr    %cl,%edi
  801a20:	09 d7                	or     %edx,%edi
  801a22:	89 f2                	mov    %esi,%edx
  801a24:	89 f8                	mov    %edi,%eax
  801a26:	f7 74 24 08          	divl   0x8(%esp)
  801a2a:	89 d6                	mov    %edx,%esi
  801a2c:	89 c7                	mov    %eax,%edi
  801a2e:	f7 24 24             	mull   (%esp)
  801a31:	39 d6                	cmp    %edx,%esi
  801a33:	89 14 24             	mov    %edx,(%esp)
  801a36:	72 30                	jb     801a68 <__udivdi3+0x118>
  801a38:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a3c:	89 e9                	mov    %ebp,%ecx
  801a3e:	d3 e2                	shl    %cl,%edx
  801a40:	39 c2                	cmp    %eax,%edx
  801a42:	73 05                	jae    801a49 <__udivdi3+0xf9>
  801a44:	3b 34 24             	cmp    (%esp),%esi
  801a47:	74 1f                	je     801a68 <__udivdi3+0x118>
  801a49:	89 f8                	mov    %edi,%eax
  801a4b:	31 d2                	xor    %edx,%edx
  801a4d:	e9 7a ff ff ff       	jmp    8019cc <__udivdi3+0x7c>
  801a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a58:	31 d2                	xor    %edx,%edx
  801a5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5f:	e9 68 ff ff ff       	jmp    8019cc <__udivdi3+0x7c>
  801a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a68:	8d 47 ff             	lea    -0x1(%edi),%eax
  801a6b:	31 d2                	xor    %edx,%edx
  801a6d:	83 c4 0c             	add    $0xc,%esp
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    
  801a74:	66 90                	xchg   %ax,%ax
  801a76:	66 90                	xchg   %ax,%ax
  801a78:	66 90                	xchg   %ax,%ax
  801a7a:	66 90                	xchg   %ax,%ax
  801a7c:	66 90                	xchg   %ax,%ax
  801a7e:	66 90                	xchg   %ax,%ax

00801a80 <__umoddi3>:
  801a80:	55                   	push   %ebp
  801a81:	57                   	push   %edi
  801a82:	56                   	push   %esi
  801a83:	83 ec 14             	sub    $0x14,%esp
  801a86:	8b 44 24 28          	mov    0x28(%esp),%eax
  801a8a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801a8e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801a92:	89 c7                	mov    %eax,%edi
  801a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a98:	8b 44 24 30          	mov    0x30(%esp),%eax
  801a9c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801aa0:	89 34 24             	mov    %esi,(%esp)
  801aa3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	89 c2                	mov    %eax,%edx
  801aab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801aaf:	75 17                	jne    801ac8 <__umoddi3+0x48>
  801ab1:	39 fe                	cmp    %edi,%esi
  801ab3:	76 4b                	jbe    801b00 <__umoddi3+0x80>
  801ab5:	89 c8                	mov    %ecx,%eax
  801ab7:	89 fa                	mov    %edi,%edx
  801ab9:	f7 f6                	div    %esi
  801abb:	89 d0                	mov    %edx,%eax
  801abd:	31 d2                	xor    %edx,%edx
  801abf:	83 c4 14             	add    $0x14,%esp
  801ac2:	5e                   	pop    %esi
  801ac3:	5f                   	pop    %edi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    
  801ac6:	66 90                	xchg   %ax,%ax
  801ac8:	39 f8                	cmp    %edi,%eax
  801aca:	77 54                	ja     801b20 <__umoddi3+0xa0>
  801acc:	0f bd e8             	bsr    %eax,%ebp
  801acf:	83 f5 1f             	xor    $0x1f,%ebp
  801ad2:	75 5c                	jne    801b30 <__umoddi3+0xb0>
  801ad4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ad8:	39 3c 24             	cmp    %edi,(%esp)
  801adb:	0f 87 e7 00 00 00    	ja     801bc8 <__umoddi3+0x148>
  801ae1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ae5:	29 f1                	sub    %esi,%ecx
  801ae7:	19 c7                	sbb    %eax,%edi
  801ae9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801af1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801af5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801af9:	83 c4 14             	add    $0x14,%esp
  801afc:	5e                   	pop    %esi
  801afd:	5f                   	pop    %edi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    
  801b00:	85 f6                	test   %esi,%esi
  801b02:	89 f5                	mov    %esi,%ebp
  801b04:	75 0b                	jne    801b11 <__umoddi3+0x91>
  801b06:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0b:	31 d2                	xor    %edx,%edx
  801b0d:	f7 f6                	div    %esi
  801b0f:	89 c5                	mov    %eax,%ebp
  801b11:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b15:	31 d2                	xor    %edx,%edx
  801b17:	f7 f5                	div    %ebp
  801b19:	89 c8                	mov    %ecx,%eax
  801b1b:	f7 f5                	div    %ebp
  801b1d:	eb 9c                	jmp    801abb <__umoddi3+0x3b>
  801b1f:	90                   	nop
  801b20:	89 c8                	mov    %ecx,%eax
  801b22:	89 fa                	mov    %edi,%edx
  801b24:	83 c4 14             	add    $0x14,%esp
  801b27:	5e                   	pop    %esi
  801b28:	5f                   	pop    %edi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    
  801b2b:	90                   	nop
  801b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b30:	8b 04 24             	mov    (%esp),%eax
  801b33:	be 20 00 00 00       	mov    $0x20,%esi
  801b38:	89 e9                	mov    %ebp,%ecx
  801b3a:	29 ee                	sub    %ebp,%esi
  801b3c:	d3 e2                	shl    %cl,%edx
  801b3e:	89 f1                	mov    %esi,%ecx
  801b40:	d3 e8                	shr    %cl,%eax
  801b42:	89 e9                	mov    %ebp,%ecx
  801b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b48:	8b 04 24             	mov    (%esp),%eax
  801b4b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b4f:	89 fa                	mov    %edi,%edx
  801b51:	d3 e0                	shl    %cl,%eax
  801b53:	89 f1                	mov    %esi,%ecx
  801b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b59:	8b 44 24 10          	mov    0x10(%esp),%eax
  801b5d:	d3 ea                	shr    %cl,%edx
  801b5f:	89 e9                	mov    %ebp,%ecx
  801b61:	d3 e7                	shl    %cl,%edi
  801b63:	89 f1                	mov    %esi,%ecx
  801b65:	d3 e8                	shr    %cl,%eax
  801b67:	89 e9                	mov    %ebp,%ecx
  801b69:	09 f8                	or     %edi,%eax
  801b6b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801b6f:	f7 74 24 04          	divl   0x4(%esp)
  801b73:	d3 e7                	shl    %cl,%edi
  801b75:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b79:	89 d7                	mov    %edx,%edi
  801b7b:	f7 64 24 08          	mull   0x8(%esp)
  801b7f:	39 d7                	cmp    %edx,%edi
  801b81:	89 c1                	mov    %eax,%ecx
  801b83:	89 14 24             	mov    %edx,(%esp)
  801b86:	72 2c                	jb     801bb4 <__umoddi3+0x134>
  801b88:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801b8c:	72 22                	jb     801bb0 <__umoddi3+0x130>
  801b8e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b92:	29 c8                	sub    %ecx,%eax
  801b94:	19 d7                	sbb    %edx,%edi
  801b96:	89 e9                	mov    %ebp,%ecx
  801b98:	89 fa                	mov    %edi,%edx
  801b9a:	d3 e8                	shr    %cl,%eax
  801b9c:	89 f1                	mov    %esi,%ecx
  801b9e:	d3 e2                	shl    %cl,%edx
  801ba0:	89 e9                	mov    %ebp,%ecx
  801ba2:	d3 ef                	shr    %cl,%edi
  801ba4:	09 d0                	or     %edx,%eax
  801ba6:	89 fa                	mov    %edi,%edx
  801ba8:	83 c4 14             	add    $0x14,%esp
  801bab:	5e                   	pop    %esi
  801bac:	5f                   	pop    %edi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    
  801baf:	90                   	nop
  801bb0:	39 d7                	cmp    %edx,%edi
  801bb2:	75 da                	jne    801b8e <__umoddi3+0x10e>
  801bb4:	8b 14 24             	mov    (%esp),%edx
  801bb7:	89 c1                	mov    %eax,%ecx
  801bb9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801bbd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801bc1:	eb cb                	jmp    801b8e <__umoddi3+0x10e>
  801bc3:	90                   	nop
  801bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bc8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801bcc:	0f 82 0f ff ff ff    	jb     801ae1 <__umoddi3+0x61>
  801bd2:	e9 1a ff ff ff       	jmp    801af1 <__umoddi3+0x71>
