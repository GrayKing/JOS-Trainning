
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
  80003c:	e8 2b 17 00 00       	call   80176c <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 5e                	je     8000a6 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  80004e:	e8 02 11 00 00       	call   801155 <sys_getenvid>
  800053:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005b:	c7 04 24 60 1c 80 00 	movl   $0x801c60,(%esp)
  800062:	e8 e3 01 00 00       	call   80024a <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800067:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006a:	e8 e6 10 00 00       	call   801155 <sys_getenvid>
  80006f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 7a 1c 80 00 	movl   $0x801c7a,(%esp)
  80007e:	e8 c7 01 00 00       	call   80024a <cprintf>
		ipc_send(who, 0, 0, 0);
  800083:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008a:	00 
  80008b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009a:	00 
  80009b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009e:	89 04 24             	mov    %eax,(%esp)
  8000a1:	e8 5a 17 00 00       	call   801800 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 cf 16 00 00       	call   801790 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c1:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  8000c7:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000ca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000cd:	a1 04 30 80 00       	mov    0x803004,%eax
  8000d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d5:	e8 7b 10 00 00       	call   801155 <sys_getenvid>
  8000da:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8000de:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000e9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	c7 04 24 90 1c 80 00 	movl   $0x801c90,(%esp)
  8000f8:	e8 4d 01 00 00       	call   80024a <cprintf>
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
  80012d:	e8 ce 16 00 00       	call   801800 <ipc_send>
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
  800155:	e8 fb 0f 00 00       	call   801155 <sys_getenvid>
  80015a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015f:	89 c2                	mov    %eax,%edx
  800161:	c1 e2 07             	shl    $0x7,%edx
  800164:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80016b:	a3 08 30 80 00       	mov    %eax,0x803008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800170:	85 db                	test   %ebx,%ebx
  800172:	7e 07                	jle    80017b <libmain+0x34>
		binaryname = argv[0];
  800174:	8b 06                	mov    (%esi),%eax
  800176:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80017b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017f:	89 1c 24             	mov    %ebx,(%esp)
  800182:	e8 ac fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800187:	e8 07 00 00 00       	call   800193 <exit>
}
  80018c:	83 c4 10             	add    $0x10,%esp
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    

00800193 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800199:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a0:	e8 5e 0f 00 00       	call   801103 <sys_env_destroy>
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 14             	sub    $0x14,%esp
  8001ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b1:	8b 13                	mov    (%ebx),%edx
  8001b3:	8d 42 01             	lea    0x1(%edx),%eax
  8001b6:	89 03                	mov    %eax,(%ebx)
  8001b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c4:	75 19                	jne    8001df <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cd:	00 
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 ed 0e 00 00       	call   8010c6 <sys_cputs>
		b->idx = 0;
  8001d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e3:	83 c4 14             	add    $0x14,%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f9:	00 00 00 
	b.cnt = 0;
  8001fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800203:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800206:	8b 45 0c             	mov    0xc(%ebp),%eax
  800209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 44 24 08          	mov    %eax,0x8(%esp)
  800214:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021e:	c7 04 24 a7 01 80 00 	movl   $0x8001a7,(%esp)
  800225:	e8 b5 02 00 00       	call   8004df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023a:	89 04 24             	mov    %eax,(%esp)
  80023d:	e8 84 0e 00 00       	call   8010c6 <sys_cputs>

	return b.cnt;
}
  800242:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800250:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800253:	89 44 24 04          	mov    %eax,0x4(%esp)
  800257:	8b 45 08             	mov    0x8(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	e8 87 ff ff ff       	call   8001e9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    
  800264:	66 90                	xchg   %ax,%ax
  800266:	66 90                	xchg   %ax,%ax
  800268:	66 90                	xchg   %ax,%ax
  80026a:	66 90                	xchg   %ax,%ax
  80026c:	66 90                	xchg   %ax,%ax
  80026e:	66 90                	xchg   %ax,%ax

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
  8002df:	e8 dc 16 00 00       	call   8019c0 <__udivdi3>
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
  80033f:	e8 ac 17 00 00       	call   801af0 <__umoddi3>
  800344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800348:	0f be 80 c0 1c 80 00 	movsbl 0x801cc0(%eax),%eax
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
  8003df:	e8 dc 15 00 00       	call   8019c0 <__udivdi3>
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
  80043d:	e8 ae 16 00 00       	call   801af0 <__umoddi3>
  800442:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800446:	0f be 80 c0 1c 80 00 	movsbl 0x801cc0(%eax),%eax
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
  800564:	ff 24 8d 80 1d 80 00 	jmp    *0x801d80(,%ecx,4)
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
  800601:	8b 14 85 40 20 80 00 	mov    0x802040(,%eax,4),%edx
  800608:	85 d2                	test   %edx,%edx
  80060a:	75 20                	jne    80062c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80060c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800610:	c7 44 24 08 d8 1c 80 	movl   $0x801cd8,0x8(%esp)
  800617:	00 
  800618:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	89 04 24             	mov    %eax,(%esp)
  800622:	e8 90 fe ff ff       	call   8004b7 <printfmt>
  800627:	e9 d8 fe ff ff       	jmp    800504 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80062c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800630:	c7 44 24 08 e1 1c 80 	movl   $0x801ce1,0x8(%esp)
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
  800662:	b8 d1 1c 80 00       	mov    $0x801cd1,%eax
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
  80094e:	ff 24 8d d8 1e 80 00 	jmp    *0x801ed8(,%ecx,4)
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
  8009e7:	8b 14 85 40 20 80 00 	mov    0x802040(,%eax,4),%edx
  8009ee:	85 d2                	test   %edx,%edx
  8009f0:	75 23                	jne    800a15 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  8009f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f6:	c7 44 24 08 d8 1c 80 	movl   $0x801cd8,0x8(%esp)
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
  800a19:	c7 44 24 08 e1 1c 80 	movl   $0x801ce1,0x8(%esp)
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
  800a4b:	b8 d1 1c 80 00       	mov    $0x801cd1,%eax
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
  801131:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  801138:	00 
  801139:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801140:	00 
  801141:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  801148:	e8 a9 07 00 00       	call   8018f6 <_panic>

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
  8011c3:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  8011da:	e8 17 07 00 00       	call   8018f6 <_panic>

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
  801216:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  80121d:	00 
  80121e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801225:	00 
  801226:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  80122d:	e8 c4 06 00 00       	call   8018f6 <_panic>

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
  801269:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  801270:	00 
  801271:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801278:	00 
  801279:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  801280:	e8 71 06 00 00       	call   8018f6 <_panic>

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
  8012bc:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  8012c3:	00 
  8012c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012cb:	00 
  8012cc:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  8012d3:	e8 1e 06 00 00       	call   8018f6 <_panic>

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
  80130f:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  801316:	00 
  801317:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80131e:	00 
  80131f:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  801326:	e8 cb 05 00 00       	call   8018f6 <_panic>

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
  801384:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  80138b:	00 
  80138c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801393:	00 
  801394:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  80139b:	e8 56 05 00 00       	call   8018f6 <_panic>

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

008013a8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	57                   	push   %edi
  8013ac:	56                   	push   %esi
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 2c             	sub    $0x2c,%esp
	void *addr = (void *) utf->utf_fault_va;
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b4:	8b 30                	mov    (%eax),%esi
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf(" pgfault : fault va is  %08x\n", ( uint32_t ) addr ) ; 
	//cprintf(" pgfault : fault eip is  %08x\n", ( uint32_t ) utf->utf_eip ) ; 
	pde_t * pde_ptr = ( pde_t * ) ( UVPT + ( PDX(UVPT) << 12 ) + ( PDX(addr) << 2 ) ) ; 
  8013b6:	89 f0                	mov    %esi,%eax
  8013b8:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( UVPT + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  8013bb:	89 c1                	mov    %eax,%ecx
  8013bd:	c1 e1 0c             	shl    $0xc,%ecx
  8013c0:	89 f2                	mov    %esi,%edx
  8013c2:	c1 ea 0a             	shr    $0xa,%edx
  8013c5:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8013cb:	8d bc 11 00 00 40 ef 	lea    -0x10c00000(%ecx,%edx,1),%edi
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  8013d2:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  8013d9:	01 
  8013da:	75 1c                	jne    8013f8 <pgfault+0x50>
		panic(" in inc/fork.c <pgfault> : Page Directory Entry doesn't exsist!\n");
  8013dc:	c7 44 24 08 94 20 80 	movl   $0x802094,0x8(%esp)
  8013e3:	00 
  8013e4:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8013eb:	00 
  8013ec:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  8013f3:	e8 fe 04 00 00       	call   8018f6 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  8013f8:	8b 07                	mov    (%edi),%eax
  8013fa:	a8 01                	test   $0x1,%al
  8013fc:	75 1c                	jne    80141a <pgfault+0x72>
		panic(" in inc/fork.c <pgfault> : Page Table Entry doesn't exsist!\n");
  8013fe:	c7 44 24 08 d8 20 80 	movl   $0x8020d8,0x8(%esp)
  801405:	00 
  801406:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80140d:	00 
  80140e:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  801415:	e8 dc 04 00 00       	call   8018f6 <_panic>
	if (!( ( ( *pte_ptr ) & PTE_W ) || ( ( *pte_ptr ) & PTE_COW ) ) )
  80141a:	a9 02 08 00 00       	test   $0x802,%eax
  80141f:	75 1c                	jne    80143d <pgfault+0x95>
		panic(" in inc/fork.c <pgfault> : Invalid page!\n");
  801421:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  801428:	00 
  801429:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801430:	00 
  801431:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  801438:	e8 b9 04 00 00       	call   8018f6 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid() ;
  80143d:	e8 13 fd ff ff       	call   801155 <sys_getenvid>
  801442:	89 c3                	mov    %eax,%ebx
	//cprintf(" pgfault : %d\n %08x\n",envid , PFTEMP); 
	sys_page_alloc( envid , ( void * ) PFTEMP , (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W);  
  801444:	8b 07                	mov    (%edi),%eax
  801446:	25 05 06 00 00       	and    $0x605,%eax
  80144b:	83 c8 02             	or     $0x2,%eax
  80144e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801452:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801459:	00 
  80145a:	89 1c 24             	mov    %ebx,(%esp)
  80145d:	e8 31 fd ff ff       	call   801193 <sys_page_alloc>
	//cprintf(" Did it reach here and made an alloc call?\n");
	memmove( ( void * ) PFTEMP , ( void * ) ROUNDDOWN( addr , PGSIZE ) , PGSIZE ) ; 
  801462:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801468:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80146f:	00 
  801470:	89 74 24 04          	mov    %esi,0x4(%esp)
  801474:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80147b:	e8 94 fa ff ff       	call   800f14 <memmove>
	sys_page_map( envid , ( void * ) PFTEMP , envid , ( void * ) ROUNDDOWN( addr , PGSIZE ) ,  (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W );  
  801480:	8b 07                	mov    (%edi),%eax
  801482:	25 05 06 00 00       	and    $0x605,%eax
  801487:	83 c8 02             	or     $0x2,%eax
  80148a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80148e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801492:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801496:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80149d:	00 
  80149e:	89 1c 24             	mov    %ebx,(%esp)
  8014a1:	e8 41 fd ff ff       	call   8011e7 <sys_page_map>
	sys_page_unmap( envid , PFTEMP ) ; 
  8014a6:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014ad:	00 
  8014ae:	89 1c 24             	mov    %ebx,(%esp)
  8014b1:	e8 84 fd ff ff       	call   80123a <sys_page_unmap>
	//panic("pgfault not implemented");
}
  8014b6:	83 c4 2c             	add    $0x2c,%esp
  8014b9:	5b                   	pop    %ebx
  8014ba:	5e                   	pop    %esi
  8014bb:	5f                   	pop    %edi
  8014bc:	5d                   	pop    %ebp
  8014bd:	c3                   	ret    

008014be <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// First , set handler
	set_pgfault_handler(pgfault); 
  8014c7:	c7 04 24 a8 13 80 00 	movl   $0x8013a8,(%esp)
  8014ce:	e8 79 04 00 00       	call   80194c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014d3:	b8 07 00 00 00       	mov    $0x7,%eax
  8014d8:	cd 30                	int    $0x30
  8014da:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8014dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	79 1c                	jns    801500 <fork+0x42>
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
  8014e4:	c7 44 24 08 44 21 80 	movl   $0x802144,0x8(%esp)
  8014eb:	00 
  8014ec:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  8014f3:	00 
  8014f4:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  8014fb:	e8 f6 03 00 00       	call   8018f6 <_panic>
	if ( childid == 0 ) {
  801500:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801504:	74 17                	je     80151d <fork+0x5f>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  801506:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80150b:	c1 e8 16             	shr    $0x16,%eax
  80150e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801511:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801518:	e9 26 02 00 00       	jmp    801743 <fork+0x285>
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
	if ( childid == 0 ) {
		thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80151d:	e8 33 fc ff ff       	call   801155 <sys_getenvid>
  801522:	25 ff 03 00 00       	and    $0x3ff,%eax
  801527:	89 c2                	mov    %eax,%edx
  801529:	c1 e2 07             	shl    $0x7,%edx
  80152c:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801533:	a3 08 30 80 00       	mov    %eax,0x803008
		return 0 ;
  801538:	b8 00 00 00 00       	mov    $0x0,%eax
  80153d:	e9 22 02 00 00       	jmp    801764 <fork+0x2a6>
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
  801542:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801545:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  80154c:	01 
  80154d:	0f 84 ec 01 00 00    	je     80173f <fork+0x281>
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
  801553:	89 c6                	mov    %eax,%esi
  801555:	c1 e0 0c             	shl    $0xc,%eax
  801558:	8d b8 00 00 40 ef    	lea    -0x10c00000(%eax),%edi
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
			     ( ptx != PTX(UXSTACKTOP-PGSIZE) ) ) {
				//cprintf(" fork : pdx : %d , ptx : %d\n" , pdx , ptx ) ; 
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
  80155e:	c1 e6 16             	shl    $0x16,%esi
  801561:	bb 00 00 00 00       	mov    $0x0,%ebx
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
			if ( ! ( ( * pte_ptr ) & PTE_P ) )  continue ; 
  801566:	f6 04 9f 01          	testb  $0x1,(%edi,%ebx,4)
  80156a:	0f 84 ba 01 00 00    	je     80172a <fork+0x26c>
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
  801570:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  801576:	75 0d                	jne    801585 <fork+0xc7>
  801578:	81 7d dc ba 03 00 00 	cmpl   $0x3ba,-0x24(%ebp)
  80157f:	0f 84 8a 01 00 00    	je     80170f <fork+0x251>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid() ; 
  801585:	e8 cb fb ff ff       	call   801155 <sys_getenvid>
  80158a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t addr = pn * PGSIZE ;
	//cprintf(" duppage : now envid is : %d\n", sys_getenvid() ) ;
	//cprintf(" duppage : page address is %08x %d %d\n" , addr,PDX(addr),PTX(addr) ) ;
	pde_t * pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd ) + ( PDX(addr) << 2 ) ) ; 
  80158d:	89 f0                	mov    %esi,%eax
  80158f:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  801592:	89 c1                	mov    %eax,%ecx
  801594:	c1 e1 0c             	shl    $0xc,%ecx
  801597:	81 c1 00 00 40 ef    	add    $0xef400000,%ecx
  80159d:	89 f2                	mov    %esi,%edx
  80159f:	c1 ea 0a             	shr    $0xa,%edx
  8015a2:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8015a8:	01 ca                	add    %ecx,%edx
	
	//cprintf(" duppage : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
	//cprintf(" duppage : pte_ptr's value is : %08x\n" , ( * pte_ptr ) ) ;
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  8015aa:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8015af:	f6 04 81 01          	testb  $0x1,(%ecx,%eax,4)
  8015b3:	75 1c                	jne    8015d1 <fork+0x113>
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
  8015b5:	c7 44 24 08 78 21 80 	movl   $0x802178,0x8(%esp)
  8015bc:	00 
  8015bd:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8015c4:	00 
  8015c5:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  8015cc:	e8 25 03 00 00       	call   8018f6 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  8015d1:	8b 02                	mov    (%edx),%eax
  8015d3:	a8 01                	test   $0x1,%al
  8015d5:	75 1c                	jne    8015f3 <fork+0x135>
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
  8015d7:	c7 44 24 08 bc 21 80 	movl   $0x8021bc,0x8(%esp)
  8015de:	00 
  8015df:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8015e6:	00 
  8015e7:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  8015ee:	e8 03 03 00 00       	call   8018f6 <_panic>
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
  8015f3:	89 c2                	mov    %eax,%edx
  8015f5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	if ( perm & PTE_W ) {
  8015fb:	a8 02                	test   $0x2,%al
  8015fd:	0f 84 8b 00 00 00    	je     80168e <fork+0x1d0>
		if ( sys_page_map( curenvid , ( void * ) addr , 
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
  801603:	89 d0                	mov    %edx,%eax
  801605:	83 f0 02             	xor    $0x2,%eax
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
	if (!( ( * pte_ptr ) & PTE_P ) ) 
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
	if ( perm & PTE_W ) {
		if ( sys_page_map( curenvid , ( void * ) addr , 
  801608:	80 cc 08             	or     $0x8,%ah
  80160b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80160e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801612:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801616:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801619:	89 44 24 08          	mov    %eax,0x8(%esp)
  80161d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801621:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801624:	89 04 24             	mov    %eax,(%esp)
  801627:	e8 bb fb ff ff       	call   8011e7 <sys_page_map>
  80162c:	85 c0                	test   %eax,%eax
  80162e:	79 1c                	jns    80164c <fork+0x18e>
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page! %e\n");
  801630:	c7 44 24 08 fc 21 80 	movl   $0x8021fc,0x8(%esp)
  801637:	00 
  801638:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80163f:	00 
  801640:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  801647:	e8 aa 02 00 00       	call   8018f6 <_panic>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  80164c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80164f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801653:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801657:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80165a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80165e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801662:	89 04 24             	mov    %eax,(%esp)
  801665:	e8 7d fb ff ff       	call   8011e7 <sys_page_map>
  80166a:	85 c0                	test   %eax,%eax
  80166c:	0f 89 b8 00 00 00    	jns    80172a <fork+0x26c>
				   curenvid , ( void * ) addr , 
				   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  801672:	c7 44 24 08 34 22 80 	movl   $0x802234,0x8(%esp)
  801679:	00 
  80167a:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  801681:	00 
  801682:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  801689:	e8 68 02 00 00       	call   8018f6 <_panic>
		return 0 ; 	
	}  
	if ( perm & PTE_COW ) {
  80168e:	f6 c4 08             	test   $0x8,%ah
  801691:	74 3e                	je     8016d1 <fork+0x213>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  801693:	89 54 24 10          	mov    %edx,0x10(%esp)
  801697:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80169b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80169e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a9:	89 04 24             	mov    %eax,(%esp)
  8016ac:	e8 36 fb ff ff       	call   8011e7 <sys_page_map>
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	79 75                	jns    80172a <fork+0x26c>
                                   envid    , ( void * ) addr , 
                                   perm ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  8016b5:	c7 44 24 08 34 22 80 	movl   $0x802234,0x8(%esp)
  8016bc:	00 
  8016bd:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  8016c4:	00 
  8016c5:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  8016cc:	e8 25 02 00 00       	call   8018f6 <_panic>
		return 0 ;
	}
	if ( sys_page_map( curenvid , ( void * ) addr , 
  8016d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e7:	89 04 24             	mov    %eax,(%esp)
  8016ea:	e8 f8 fa ff ff       	call   8011e7 <sys_page_map>
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	79 37                	jns    80172a <fork+0x26c>
		           envid    , ( void * ) addr , 
			   perm ) < 0 ) 
		panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  8016f3:	c7 44 24 08 34 22 80 	movl   $0x802234,0x8(%esp)
  8016fa:	00 
  8016fb:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801702:	00 
  801703:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  80170a:	e8 e7 01 00 00       	call   8018f6 <_panic>
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
  80170f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801716:	00 
  801717:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80171e:	ee 
  80171f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801722:	89 04 24             	mov    %eax,(%esp)
  801725:	e8 69 fa ff ff       	call   801193 <sys_page_alloc>
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
  80172a:	83 c3 01             	add    $0x1,%ebx
  80172d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801733:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801739:	0f 85 27 fe ff ff    	jne    801566 <fork+0xa8>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  80173f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  801743:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801746:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  801749:	0f 85 f3 fd ff ff    	jne    801542 <fork+0x84>
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
		}						
	}
	sys_env_set_status( childid , ENV_RUNNABLE ) ;
  80174f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801756:	00 
  801757:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80175a:	89 3c 24             	mov    %edi,(%esp)
  80175d:	e8 2b fb ff ff       	call   80128d <sys_env_set_status>
	return childid ;
  801762:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801764:	83 c4 3c             	add    $0x3c,%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5f                   	pop    %edi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <sfork>:

// Challenge!
int
sfork(void)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801772:	c7 44 24 08 73 22 80 	movl   $0x802273,0x8(%esp)
  801779:	00 
  80177a:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801781:	00 
  801782:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  801789:	e8 68 01 00 00       	call   8018f6 <_panic>
  80178e:	66 90                	xchg   %ax,%ax

00801790 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	83 ec 10             	sub    $0x10,%esp
  801798:	8b 75 08             	mov    0x8(%ebp),%esi
  80179b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int result = 0 ; 
	if ( pg ) result = sys_ipc_recv(pg);	
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	74 0a                	je     8017af <ipc_recv+0x1f>
  8017a5:	89 04 24             	mov    %eax,(%esp)
  8017a8:	e8 a9 fb ff ff       	call   801356 <sys_ipc_recv>
  8017ad:	eb 0c                	jmp    8017bb <ipc_recv+0x2b>
	     else result = sys_ipc_recv((void*)UTOP);
  8017af:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8017b6:	e8 9b fb ff ff       	call   801356 <sys_ipc_recv>
	if ( result < 0 ) {
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	79 16                	jns    8017d5 <ipc_recv+0x45>
		if ( from_env_store ) 
  8017bf:	85 f6                	test   %esi,%esi
  8017c1:	74 06                	je     8017c9 <ipc_recv+0x39>
			(*from_env_store) = 0 ;
  8017c3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if ( perm_store)
  8017c9:	85 db                	test   %ebx,%ebx
  8017cb:	74 2c                	je     8017f9 <ipc_recv+0x69>
			(*perm_store) = 0 ;	
  8017cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017d3:	eb 24                	jmp    8017f9 <ipc_recv+0x69>
		return result; 
	}
	if ( from_env_store ) 
  8017d5:	85 f6                	test   %esi,%esi
  8017d7:	74 0a                	je     8017e3 <ipc_recv+0x53>
		(*from_env_store) = thisenv->env_ipc_from ;
  8017d9:	a1 08 30 80 00       	mov    0x803008,%eax
  8017de:	8b 40 74             	mov    0x74(%eax),%eax
  8017e1:	89 06                	mov    %eax,(%esi)
	if ( perm_store)
  8017e3:	85 db                	test   %ebx,%ebx
  8017e5:	74 0a                	je     8017f1 <ipc_recv+0x61>
		(*perm_store) = thisenv->env_ipc_perm ;	
  8017e7:	a1 08 30 80 00       	mov    0x803008,%eax
  8017ec:	8b 40 78             	mov    0x78(%eax),%eax
  8017ef:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8017f1:	a1 08 30 80 00       	mov    0x803008,%eax
  8017f6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5e                   	pop    %esi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	57                   	push   %edi
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	83 ec 1c             	sub    $0x1c,%esp
  801809:	8b 75 0c             	mov    0xc(%ebp),%esi
  80180c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80180f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	
	
	int result = -E_IPC_NOT_RECV ; 
	if ( pg ) 
  801812:	85 db                	test   %ebx,%ebx
  801814:	74 19                	je     80182f <ipc_send+0x2f>
		result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  801816:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80181a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	89 04 24             	mov    %eax,(%esp)
  801828:	e8 06 fb ff ff       	call   801333 <sys_ipc_try_send>
  80182d:	eb 1b                	jmp    80184a <ipc_send+0x4a>
	else
		result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  80182f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801833:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80183a:	ee 
  80183b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80183f:	8b 45 08             	mov    0x8(%ebp),%eax
  801842:	89 04 24             	mov    %eax,(%esp)
  801845:	e8 e9 fa ff ff       	call   801333 <sys_ipc_try_send>
	
	if ( result == 0 ) return ; 
  80184a:	85 c0                	test   %eax,%eax
  80184c:	74 61                	je     8018af <ipc_send+0xaf>
	if ( result == -E_IPC_NOT_RECV ) {
  80184e:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801851:	75 3c                	jne    80188f <ipc_send+0x8f>
		if ( pg ) 
  801853:	85 db                	test   %ebx,%ebx
  801855:	74 19                	je     801870 <ipc_send+0x70>
			result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  801857:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80185b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80185f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	89 04 24             	mov    %eax,(%esp)
  801869:	e8 c5 fa ff ff       	call   801333 <sys_ipc_try_send>
  80186e:	eb 1b                	jmp    80188b <ipc_send+0x8b>
		else
			result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  801870:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801874:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80187b:	ee 
  80187c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 a8 fa ff ff       	call   801333 <sys_ipc_try_send>
		if ( result == 0 ) return ; 
  80188b:	85 c0                	test   %eax,%eax
  80188d:	74 20                	je     8018af <ipc_send+0xaf>
	}
	panic("ipc_send error %e.",result);
  80188f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801893:	c7 44 24 08 89 22 80 	movl   $0x802289,0x8(%esp)
  80189a:	00 
  80189b:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8018a2:	00 
  8018a3:	c7 04 24 9c 22 80 00 	movl   $0x80229c,(%esp)
  8018aa:	e8 47 00 00 00       	call   8018f6 <_panic>
}
  8018af:	83 c4 1c             	add    $0x1c,%esp
  8018b2:	5b                   	pop    %ebx
  8018b3:	5e                   	pop    %esi
  8018b4:	5f                   	pop    %edi
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8018bd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8018c2:	89 c2                	mov    %eax,%edx
  8018c4:	c1 e2 07             	shl    $0x7,%edx
  8018c7:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  8018ce:	8b 52 50             	mov    0x50(%edx),%edx
  8018d1:	39 ca                	cmp    %ecx,%edx
  8018d3:	75 11                	jne    8018e6 <ipc_find_env+0x2f>
			return envs[i].env_id;
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	c1 e2 07             	shl    $0x7,%edx
  8018da:	8d 84 c2 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,8),%eax
  8018e1:	8b 40 40             	mov    0x40(%eax),%eax
  8018e4:	eb 0e                	jmp    8018f4 <ipc_find_env+0x3d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018e6:	83 c0 01             	add    $0x1,%eax
  8018e9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8018ee:	75 d2                	jne    8018c2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8018f0:	66 b8 00 00          	mov    $0x0,%ax
}
  8018f4:	5d                   	pop    %ebp
  8018f5:	c3                   	ret    

008018f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	56                   	push   %esi
  8018fa:	53                   	push   %ebx
  8018fb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8018fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801901:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801907:	e8 49 f8 ff ff       	call   801155 <sys_getenvid>
  80190c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801913:	8b 55 08             	mov    0x8(%ebp),%edx
  801916:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80191a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80191e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801922:	c7 04 24 a8 22 80 00 	movl   $0x8022a8,(%esp)
  801929:	e8 1c e9 ff ff       	call   80024a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80192e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801932:	8b 45 10             	mov    0x10(%ebp),%eax
  801935:	89 04 24             	mov    %eax,(%esp)
  801938:	e8 ac e8 ff ff       	call   8001e9 <vcprintf>
	cprintf("\n");
  80193d:	c7 04 24 78 1c 80 00 	movl   $0x801c78,(%esp)
  801944:	e8 01 e9 ff ff       	call   80024a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801949:	cc                   	int3   
  80194a:	eb fd                	jmp    801949 <_panic+0x53>

0080194c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801952:	83 3d 0c 30 80 00 00 	cmpl   $0x0,0x80300c
  801959:	75 32                	jne    80198d <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  80195b:	e8 f5 f7 ff ff       	call   801155 <sys_getenvid>
  801960:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801967:	00 
  801968:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80196f:	ee 
  801970:	89 04 24             	mov    %eax,(%esp)
  801973:	e8 1b f8 ff ff       	call   801193 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  801978:	e8 d8 f7 ff ff       	call   801155 <sys_getenvid>
  80197d:	c7 44 24 04 97 19 80 	movl   $0x801997,0x4(%esp)
  801984:	00 
  801985:	89 04 24             	mov    %eax,(%esp)
  801988:	e8 53 f9 ff ff       	call   8012e0 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80198d:	8b 45 08             	mov    0x8(%ebp),%eax
  801990:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801997:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801998:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  80199d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80199f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  8019a2:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  8019a5:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  8019a9:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  8019ad:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  8019b0:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  8019b4:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  8019b6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  8019b7:	83 c4 04             	add    $0x4,%esp
	popfl 	
  8019ba:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8019bb:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8019bc:	c3                   	ret    
  8019bd:	66 90                	xchg   %ax,%ax
  8019bf:	90                   	nop

008019c0 <__udivdi3>:
  8019c0:	55                   	push   %ebp
  8019c1:	57                   	push   %edi
  8019c2:	56                   	push   %esi
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8019ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8019ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8019d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019dc:	89 ea                	mov    %ebp,%edx
  8019de:	89 0c 24             	mov    %ecx,(%esp)
  8019e1:	75 2d                	jne    801a10 <__udivdi3+0x50>
  8019e3:	39 e9                	cmp    %ebp,%ecx
  8019e5:	77 61                	ja     801a48 <__udivdi3+0x88>
  8019e7:	85 c9                	test   %ecx,%ecx
  8019e9:	89 ce                	mov    %ecx,%esi
  8019eb:	75 0b                	jne    8019f8 <__udivdi3+0x38>
  8019ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f2:	31 d2                	xor    %edx,%edx
  8019f4:	f7 f1                	div    %ecx
  8019f6:	89 c6                	mov    %eax,%esi
  8019f8:	31 d2                	xor    %edx,%edx
  8019fa:	89 e8                	mov    %ebp,%eax
  8019fc:	f7 f6                	div    %esi
  8019fe:	89 c5                	mov    %eax,%ebp
  801a00:	89 f8                	mov    %edi,%eax
  801a02:	f7 f6                	div    %esi
  801a04:	89 ea                	mov    %ebp,%edx
  801a06:	83 c4 0c             	add    $0xc,%esp
  801a09:	5e                   	pop    %esi
  801a0a:	5f                   	pop    %edi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    
  801a0d:	8d 76 00             	lea    0x0(%esi),%esi
  801a10:	39 e8                	cmp    %ebp,%eax
  801a12:	77 24                	ja     801a38 <__udivdi3+0x78>
  801a14:	0f bd e8             	bsr    %eax,%ebp
  801a17:	83 f5 1f             	xor    $0x1f,%ebp
  801a1a:	75 3c                	jne    801a58 <__udivdi3+0x98>
  801a1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a20:	39 34 24             	cmp    %esi,(%esp)
  801a23:	0f 86 9f 00 00 00    	jbe    801ac8 <__udivdi3+0x108>
  801a29:	39 d0                	cmp    %edx,%eax
  801a2b:	0f 82 97 00 00 00    	jb     801ac8 <__udivdi3+0x108>
  801a31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a38:	31 d2                	xor    %edx,%edx
  801a3a:	31 c0                	xor    %eax,%eax
  801a3c:	83 c4 0c             	add    $0xc,%esp
  801a3f:	5e                   	pop    %esi
  801a40:	5f                   	pop    %edi
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    
  801a43:	90                   	nop
  801a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a48:	89 f8                	mov    %edi,%eax
  801a4a:	f7 f1                	div    %ecx
  801a4c:	31 d2                	xor    %edx,%edx
  801a4e:	83 c4 0c             	add    $0xc,%esp
  801a51:	5e                   	pop    %esi
  801a52:	5f                   	pop    %edi
  801a53:	5d                   	pop    %ebp
  801a54:	c3                   	ret    
  801a55:	8d 76 00             	lea    0x0(%esi),%esi
  801a58:	89 e9                	mov    %ebp,%ecx
  801a5a:	8b 3c 24             	mov    (%esp),%edi
  801a5d:	d3 e0                	shl    %cl,%eax
  801a5f:	89 c6                	mov    %eax,%esi
  801a61:	b8 20 00 00 00       	mov    $0x20,%eax
  801a66:	29 e8                	sub    %ebp,%eax
  801a68:	89 c1                	mov    %eax,%ecx
  801a6a:	d3 ef                	shr    %cl,%edi
  801a6c:	89 e9                	mov    %ebp,%ecx
  801a6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a72:	8b 3c 24             	mov    (%esp),%edi
  801a75:	09 74 24 08          	or     %esi,0x8(%esp)
  801a79:	89 d6                	mov    %edx,%esi
  801a7b:	d3 e7                	shl    %cl,%edi
  801a7d:	89 c1                	mov    %eax,%ecx
  801a7f:	89 3c 24             	mov    %edi,(%esp)
  801a82:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a86:	d3 ee                	shr    %cl,%esi
  801a88:	89 e9                	mov    %ebp,%ecx
  801a8a:	d3 e2                	shl    %cl,%edx
  801a8c:	89 c1                	mov    %eax,%ecx
  801a8e:	d3 ef                	shr    %cl,%edi
  801a90:	09 d7                	or     %edx,%edi
  801a92:	89 f2                	mov    %esi,%edx
  801a94:	89 f8                	mov    %edi,%eax
  801a96:	f7 74 24 08          	divl   0x8(%esp)
  801a9a:	89 d6                	mov    %edx,%esi
  801a9c:	89 c7                	mov    %eax,%edi
  801a9e:	f7 24 24             	mull   (%esp)
  801aa1:	39 d6                	cmp    %edx,%esi
  801aa3:	89 14 24             	mov    %edx,(%esp)
  801aa6:	72 30                	jb     801ad8 <__udivdi3+0x118>
  801aa8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801aac:	89 e9                	mov    %ebp,%ecx
  801aae:	d3 e2                	shl    %cl,%edx
  801ab0:	39 c2                	cmp    %eax,%edx
  801ab2:	73 05                	jae    801ab9 <__udivdi3+0xf9>
  801ab4:	3b 34 24             	cmp    (%esp),%esi
  801ab7:	74 1f                	je     801ad8 <__udivdi3+0x118>
  801ab9:	89 f8                	mov    %edi,%eax
  801abb:	31 d2                	xor    %edx,%edx
  801abd:	e9 7a ff ff ff       	jmp    801a3c <__udivdi3+0x7c>
  801ac2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ac8:	31 d2                	xor    %edx,%edx
  801aca:	b8 01 00 00 00       	mov    $0x1,%eax
  801acf:	e9 68 ff ff ff       	jmp    801a3c <__udivdi3+0x7c>
  801ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ad8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801adb:	31 d2                	xor    %edx,%edx
  801add:	83 c4 0c             	add    $0xc,%esp
  801ae0:	5e                   	pop    %esi
  801ae1:	5f                   	pop    %edi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    
  801ae4:	66 90                	xchg   %ax,%ax
  801ae6:	66 90                	xchg   %ax,%ax
  801ae8:	66 90                	xchg   %ax,%ax
  801aea:	66 90                	xchg   %ax,%ax
  801aec:	66 90                	xchg   %ax,%ax
  801aee:	66 90                	xchg   %ax,%ax

00801af0 <__umoddi3>:
  801af0:	55                   	push   %ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	83 ec 14             	sub    $0x14,%esp
  801af6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801afa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801afe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801b02:	89 c7                	mov    %eax,%edi
  801b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b08:	8b 44 24 30          	mov    0x30(%esp),%eax
  801b0c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801b10:	89 34 24             	mov    %esi,(%esp)
  801b13:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b17:	85 c0                	test   %eax,%eax
  801b19:	89 c2                	mov    %eax,%edx
  801b1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b1f:	75 17                	jne    801b38 <__umoddi3+0x48>
  801b21:	39 fe                	cmp    %edi,%esi
  801b23:	76 4b                	jbe    801b70 <__umoddi3+0x80>
  801b25:	89 c8                	mov    %ecx,%eax
  801b27:	89 fa                	mov    %edi,%edx
  801b29:	f7 f6                	div    %esi
  801b2b:	89 d0                	mov    %edx,%eax
  801b2d:	31 d2                	xor    %edx,%edx
  801b2f:	83 c4 14             	add    $0x14,%esp
  801b32:	5e                   	pop    %esi
  801b33:	5f                   	pop    %edi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    
  801b36:	66 90                	xchg   %ax,%ax
  801b38:	39 f8                	cmp    %edi,%eax
  801b3a:	77 54                	ja     801b90 <__umoddi3+0xa0>
  801b3c:	0f bd e8             	bsr    %eax,%ebp
  801b3f:	83 f5 1f             	xor    $0x1f,%ebp
  801b42:	75 5c                	jne    801ba0 <__umoddi3+0xb0>
  801b44:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b48:	39 3c 24             	cmp    %edi,(%esp)
  801b4b:	0f 87 e7 00 00 00    	ja     801c38 <__umoddi3+0x148>
  801b51:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b55:	29 f1                	sub    %esi,%ecx
  801b57:	19 c7                	sbb    %eax,%edi
  801b59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b5d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b61:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b65:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b69:	83 c4 14             	add    $0x14,%esp
  801b6c:	5e                   	pop    %esi
  801b6d:	5f                   	pop    %edi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    
  801b70:	85 f6                	test   %esi,%esi
  801b72:	89 f5                	mov    %esi,%ebp
  801b74:	75 0b                	jne    801b81 <__umoddi3+0x91>
  801b76:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7b:	31 d2                	xor    %edx,%edx
  801b7d:	f7 f6                	div    %esi
  801b7f:	89 c5                	mov    %eax,%ebp
  801b81:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b85:	31 d2                	xor    %edx,%edx
  801b87:	f7 f5                	div    %ebp
  801b89:	89 c8                	mov    %ecx,%eax
  801b8b:	f7 f5                	div    %ebp
  801b8d:	eb 9c                	jmp    801b2b <__umoddi3+0x3b>
  801b8f:	90                   	nop
  801b90:	89 c8                	mov    %ecx,%eax
  801b92:	89 fa                	mov    %edi,%edx
  801b94:	83 c4 14             	add    $0x14,%esp
  801b97:	5e                   	pop    %esi
  801b98:	5f                   	pop    %edi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    
  801b9b:	90                   	nop
  801b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	8b 04 24             	mov    (%esp),%eax
  801ba3:	be 20 00 00 00       	mov    $0x20,%esi
  801ba8:	89 e9                	mov    %ebp,%ecx
  801baa:	29 ee                	sub    %ebp,%esi
  801bac:	d3 e2                	shl    %cl,%edx
  801bae:	89 f1                	mov    %esi,%ecx
  801bb0:	d3 e8                	shr    %cl,%eax
  801bb2:	89 e9                	mov    %ebp,%ecx
  801bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb8:	8b 04 24             	mov    (%esp),%eax
  801bbb:	09 54 24 04          	or     %edx,0x4(%esp)
  801bbf:	89 fa                	mov    %edi,%edx
  801bc1:	d3 e0                	shl    %cl,%eax
  801bc3:	89 f1                	mov    %esi,%ecx
  801bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bc9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bcd:	d3 ea                	shr    %cl,%edx
  801bcf:	89 e9                	mov    %ebp,%ecx
  801bd1:	d3 e7                	shl    %cl,%edi
  801bd3:	89 f1                	mov    %esi,%ecx
  801bd5:	d3 e8                	shr    %cl,%eax
  801bd7:	89 e9                	mov    %ebp,%ecx
  801bd9:	09 f8                	or     %edi,%eax
  801bdb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801bdf:	f7 74 24 04          	divl   0x4(%esp)
  801be3:	d3 e7                	shl    %cl,%edi
  801be5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801be9:	89 d7                	mov    %edx,%edi
  801beb:	f7 64 24 08          	mull   0x8(%esp)
  801bef:	39 d7                	cmp    %edx,%edi
  801bf1:	89 c1                	mov    %eax,%ecx
  801bf3:	89 14 24             	mov    %edx,(%esp)
  801bf6:	72 2c                	jb     801c24 <__umoddi3+0x134>
  801bf8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801bfc:	72 22                	jb     801c20 <__umoddi3+0x130>
  801bfe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801c02:	29 c8                	sub    %ecx,%eax
  801c04:	19 d7                	sbb    %edx,%edi
  801c06:	89 e9                	mov    %ebp,%ecx
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	d3 e8                	shr    %cl,%eax
  801c0c:	89 f1                	mov    %esi,%ecx
  801c0e:	d3 e2                	shl    %cl,%edx
  801c10:	89 e9                	mov    %ebp,%ecx
  801c12:	d3 ef                	shr    %cl,%edi
  801c14:	09 d0                	or     %edx,%eax
  801c16:	89 fa                	mov    %edi,%edx
  801c18:	83 c4 14             	add    $0x14,%esp
  801c1b:	5e                   	pop    %esi
  801c1c:	5f                   	pop    %edi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    
  801c1f:	90                   	nop
  801c20:	39 d7                	cmp    %edx,%edi
  801c22:	75 da                	jne    801bfe <__umoddi3+0x10e>
  801c24:	8b 14 24             	mov    (%esp),%edx
  801c27:	89 c1                	mov    %eax,%ecx
  801c29:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801c2d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801c31:	eb cb                	jmp    801bfe <__umoddi3+0x10e>
  801c33:	90                   	nop
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801c3c:	0f 82 0f ff ff ff    	jb     801b51 <__umoddi3+0x61>
  801c42:	e9 1a ff ff ff       	jmp    801b61 <__umoddi3+0x71>
