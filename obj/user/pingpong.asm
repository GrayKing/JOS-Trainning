
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 ca 00 00 00       	call   8000fb <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 2d 14 00 00       	call   80146e <fork>
  800041:	89 c3                	mov    %eax,%ebx
  800043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800046:	85 c0                	test   %eax,%eax
  800048:	75 05                	jne    80004f <umain+0x1c>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80004a:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004d:	eb 3e                	jmp    80008d <umain+0x5a>
{
	envid_t who;

	if ((who = fork()) != 0) {
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004f:	e8 b1 10 00 00       	call   801105 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 00 1c 80 00 	movl   $0x801c00,(%esp)
  800063:	e8 96 01 00 00       	call   8001fe <cprintf>
		ipc_send(who, 0, 0, 0);
  800068:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006f:	00 
  800070:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800077:	00 
  800078:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007f:	00 
  800080:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800083:	89 04 24             	mov    %eax,(%esp)
  800086:	e8 25 17 00 00       	call   8017b0 <ipc_send>
  80008b:	eb bd                	jmp    80004a <umain+0x17>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80008d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800094:	00 
  800095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009c:	00 
  80009d:	89 34 24             	mov    %esi,(%esp)
  8000a0:	e8 9b 16 00 00       	call   801740 <ipc_recv>
  8000a5:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000aa:	e8 56 10 00 00       	call   801105 <sys_getenvid>
  8000af:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bb:	c7 04 24 16 1c 80 00 	movl   $0x801c16,(%esp)
  8000c2:	e8 37 01 00 00       	call   8001fe <cprintf>
		if (i == 10)
  8000c7:	83 fb 0a             	cmp    $0xa,%ebx
  8000ca:	74 27                	je     8000f3 <umain+0xc0>
			return;
		i++;
  8000cc:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d6:	00 
  8000d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000de:	00 
  8000df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e6:	89 04 24             	mov    %eax,(%esp)
  8000e9:	e8 c2 16 00 00       	call   8017b0 <ipc_send>
		if (i == 10)
  8000ee:	83 fb 0a             	cmp    $0xa,%ebx
  8000f1:	75 9a                	jne    80008d <umain+0x5a>
			return;
	}

}
  8000f3:	83 c4 2c             	add    $0x2c,%esp
  8000f6:	5b                   	pop    %ebx
  8000f7:	5e                   	pop    %esi
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 10             	sub    $0x10,%esp
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800109:	e8 f7 0f 00 00       	call   801105 <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	89 c2                	mov    %eax,%edx
  800115:	c1 e2 07             	shl    $0x7,%edx
  800118:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80011f:	a3 04 30 80 00       	mov    %eax,0x803004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	85 db                	test   %ebx,%ebx
  800126:	7e 07                	jle    80012f <libmain+0x34>
		binaryname = argv[0];
  800128:	8b 06                	mov    (%esi),%eax
  80012a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800133:	89 1c 24             	mov    %ebx,(%esp)
  800136:	e8 f8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013b:	e8 07 00 00 00       	call   800147 <exit>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800154:	e8 5a 0f 00 00       	call   8010b3 <sys_env_destroy>
}
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 14             	sub    $0x14,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 19                	jne    800193 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80017a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800181:	00 
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 e9 0e 00 00       	call   801076 <sys_cputs>
		b->idx = 0;
  80018d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800193:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800197:	83 c4 14             	add    $0x14,%esp
  80019a:	5b                   	pop    %ebx
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d2:	c7 04 24 5b 01 80 00 	movl   $0x80015b,(%esp)
  8001d9:	e8 b1 02 00 00       	call   80048f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001de:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	e8 80 0e 00 00       	call   801076 <sys_cputs>

	return b.cnt;
}
  8001f6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    

008001fe <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800204:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020b:	8b 45 08             	mov    0x8(%ebp),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	e8 87 ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    
  800218:	66 90                	xchg   %ax,%ax
  80021a:	66 90                	xchg   %ax,%ax
  80021c:	66 90                	xchg   %ax,%ax
  80021e:	66 90                	xchg   %ax,%ax

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 c3                	mov    %eax,%ebx
  800239:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80023c:	8b 45 10             	mov    0x10(%ebp),%eax
  80023f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	b9 00 00 00 00       	mov    $0x0,%ecx
  800247:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024d:	39 d9                	cmp    %ebx,%ecx
  80024f:	72 05                	jb     800256 <printnum+0x36>
  800251:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800254:	77 69                	ja     8002bf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800259:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80025d:	83 ee 01             	sub    $0x1,%esi
  800260:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800264:	89 44 24 08          	mov    %eax,0x8(%esp)
  800268:	8b 44 24 08          	mov    0x8(%esp),%eax
  80026c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800270:	89 c3                	mov    %eax,%ebx
  800272:	89 d6                	mov    %edx,%esi
  800274:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800277:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80027a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80027e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	e8 dc 16 00 00       	call   801970 <__udivdi3>
  800294:	89 d9                	mov    %ebx,%ecx
  800296:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80029a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80029e:	89 04 24             	mov    %eax,(%esp)
  8002a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a5:	89 fa                	mov    %edi,%edx
  8002a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002aa:	e8 71 ff ff ff       	call   800220 <printnum>
  8002af:	eb 1b                	jmp    8002cc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	ff d3                	call   *%ebx
  8002bd:	eb 03                	jmp    8002c2 <printnum+0xa2>
  8002bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c2:	83 ee 01             	sub    $0x1,%esi
  8002c5:	85 f6                	test   %esi,%esi
  8002c7:	7f e8                	jg     8002b1 <printnum+0x91>
  8002c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 ac 17 00 00       	call   801aa0 <__umoddi3>
  8002f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f8:	0f be 80 33 1c 80 00 	movsbl 0x801c33(%eax),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800305:	ff d0                	call   *%eax
}
  800307:	83 c4 3c             	add    $0x3c,%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 3c             	sub    $0x3c,%esp
  800318:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80031b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	8b 45 08             	mov    0x8(%ebp),%eax
  800323:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
  800329:	89 c3                	mov    %eax,%ebx
  80032b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80032e:	8b 45 10             	mov    0x10(%ebp),%eax
  800331:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800334:	b9 00 00 00 00       	mov    $0x0,%ecx
  800339:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80033f:	39 d9                	cmp    %ebx,%ecx
  800341:	72 13                	jb     800356 <cprintnum+0x47>
  800343:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800346:	76 0e                	jbe    800356 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800348:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034b:	0b 45 18             	or     0x18(%ebp),%eax
  80034e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800351:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800354:	eb 6a                	jmp    8003c0 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800356:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800359:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80035d:	83 ee 01             	sub    $0x1,%esi
  800360:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800364:	89 44 24 08          	mov    %eax,0x8(%esp)
  800368:	8b 44 24 08          	mov    0x8(%esp),%eax
  80036c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800370:	89 c3                	mov    %eax,%ebx
  800372:	89 d6                	mov    %edx,%esi
  800374:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800377:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80037a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80037e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800382:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80038b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038f:	e8 dc 15 00 00       	call   801970 <__udivdi3>
  800394:	89 d9                	mov    %ebx,%ecx
  800396:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80039a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80039e:	89 04 24             	mov    %eax,(%esp)
  8003a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003a5:	89 f9                	mov    %edi,%ecx
  8003a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ad:	e8 5d ff ff ff       	call   80030f <cprintnum>
  8003b2:	eb 16                	jmp    8003ca <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8003b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003bb:	89 04 24             	mov    %eax,(%esp)
  8003be:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c0:	83 ee 01             	sub    $0x1,%esi
  8003c3:	85 f6                	test   %esi,%esi
  8003c5:	7f ed                	jg     8003b4 <cprintnum+0xa5>
  8003c7:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  8003ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ce:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e3:	89 04 24             	mov    %eax,(%esp)
  8003e6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ed:	e8 ae 16 00 00       	call   801aa0 <__umoddi3>
  8003f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f6:	0f be 80 33 1c 80 00 	movsbl 0x801c33(%eax),%eax
  8003fd:	0b 45 dc             	or     -0x24(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800406:	ff d0                	call   *%eax
}
  800408:	83 c4 3c             	add    $0x3c,%esp
  80040b:	5b                   	pop    %ebx
  80040c:	5e                   	pop    %esi
  80040d:	5f                   	pop    %edi
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800413:	83 fa 01             	cmp    $0x1,%edx
  800416:	7e 0e                	jle    800426 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800418:	8b 10                	mov    (%eax),%edx
  80041a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80041d:	89 08                	mov    %ecx,(%eax)
  80041f:	8b 02                	mov    (%edx),%eax
  800421:	8b 52 04             	mov    0x4(%edx),%edx
  800424:	eb 22                	jmp    800448 <getuint+0x38>
	else if (lflag)
  800426:	85 d2                	test   %edx,%edx
  800428:	74 10                	je     80043a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80042a:	8b 10                	mov    (%eax),%edx
  80042c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042f:	89 08                	mov    %ecx,(%eax)
  800431:	8b 02                	mov    (%edx),%eax
  800433:	ba 00 00 00 00       	mov    $0x0,%edx
  800438:	eb 0e                	jmp    800448 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80043a:	8b 10                	mov    (%eax),%edx
  80043c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043f:	89 08                	mov    %ecx,(%eax)
  800441:	8b 02                	mov    (%edx),%eax
  800443:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800448:	5d                   	pop    %ebp
  800449:	c3                   	ret    

0080044a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800450:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800454:	8b 10                	mov    (%eax),%edx
  800456:	3b 50 04             	cmp    0x4(%eax),%edx
  800459:	73 0a                	jae    800465 <sprintputch+0x1b>
		*b->buf++ = ch;
  80045b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80045e:	89 08                	mov    %ecx,(%eax)
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	88 02                	mov    %al,(%edx)
}
  800465:	5d                   	pop    %ebp
  800466:	c3                   	ret    

00800467 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80046d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800470:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800474:	8b 45 10             	mov    0x10(%ebp),%eax
  800477:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80047e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800482:	8b 45 08             	mov    0x8(%ebp),%eax
  800485:	89 04 24             	mov    %eax,(%esp)
  800488:	e8 02 00 00 00       	call   80048f <vprintfmt>
	va_end(ap);
}
  80048d:	c9                   	leave  
  80048e:	c3                   	ret    

0080048f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048f:	55                   	push   %ebp
  800490:	89 e5                	mov    %esp,%ebp
  800492:	57                   	push   %edi
  800493:	56                   	push   %esi
  800494:	53                   	push   %ebx
  800495:	83 ec 3c             	sub    $0x3c,%esp
  800498:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80049b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80049e:	eb 14                	jmp    8004b4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	0f 84 b3 03 00 00    	je     80085b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8004a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b2:	89 f3                	mov    %esi,%ebx
  8004b4:	8d 73 01             	lea    0x1(%ebx),%esi
  8004b7:	0f b6 03             	movzbl (%ebx),%eax
  8004ba:	83 f8 25             	cmp    $0x25,%eax
  8004bd:	75 e1                	jne    8004a0 <vprintfmt+0x11>
  8004bf:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004c3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004ca:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004d1:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004dd:	eb 1d                	jmp    8004fc <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004e5:	eb 15                	jmp    8004fc <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004e9:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004ed:	eb 0d                	jmp    8004fc <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004f5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004ff:	0f b6 0e             	movzbl (%esi),%ecx
  800502:	0f b6 c1             	movzbl %cl,%eax
  800505:	83 e9 23             	sub    $0x23,%ecx
  800508:	80 f9 55             	cmp    $0x55,%cl
  80050b:	0f 87 2a 03 00 00    	ja     80083b <vprintfmt+0x3ac>
  800511:	0f b6 c9             	movzbl %cl,%ecx
  800514:	ff 24 8d 00 1d 80 00 	jmp    *0x801d00(,%ecx,4)
  80051b:	89 de                	mov    %ebx,%esi
  80051d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800522:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800525:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800529:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80052c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80052f:	83 fb 09             	cmp    $0x9,%ebx
  800532:	77 36                	ja     80056a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800534:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800537:	eb e9                	jmp    800522 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 48 04             	lea    0x4(%eax),%ecx
  80053f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800549:	eb 22                	jmp    80056d <vprintfmt+0xde>
  80054b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054e:	85 c9                	test   %ecx,%ecx
  800550:	b8 00 00 00 00       	mov    $0x0,%eax
  800555:	0f 49 c1             	cmovns %ecx,%eax
  800558:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	89 de                	mov    %ebx,%esi
  80055d:	eb 9d                	jmp    8004fc <vprintfmt+0x6d>
  80055f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800561:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800568:	eb 92                	jmp    8004fc <vprintfmt+0x6d>
  80056a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80056d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800571:	79 89                	jns    8004fc <vprintfmt+0x6d>
  800573:	e9 77 ff ff ff       	jmp    8004ef <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800578:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80057d:	e9 7a ff ff ff       	jmp    8004fc <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 04 24             	mov    %eax,(%esp)
  800594:	ff 55 08             	call   *0x8(%ebp)
			break;
  800597:	e9 18 ff ff ff       	jmp    8004b4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	99                   	cltd   
  8005a8:	31 d0                	xor    %edx,%eax
  8005aa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ac:	83 f8 09             	cmp    $0x9,%eax
  8005af:	7f 0b                	jg     8005bc <vprintfmt+0x12d>
  8005b1:	8b 14 85 c0 1f 80 00 	mov    0x801fc0(,%eax,4),%edx
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	75 20                	jne    8005dc <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8005bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c0:	c7 44 24 08 4b 1c 80 	movl   $0x801c4b,0x8(%esp)
  8005c7:	00 
  8005c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	e8 90 fe ff ff       	call   800467 <printfmt>
  8005d7:	e9 d8 fe ff ff       	jmp    8004b4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e0:	c7 44 24 08 54 1c 80 	movl   $0x801c54,0x8(%esp)
  8005e7:	00 
  8005e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	e8 70 fe ff ff       	call   800467 <printfmt>
  8005f7:	e9 b8 fe ff ff       	jmp    8004b4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800602:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800610:	85 f6                	test   %esi,%esi
  800612:	b8 44 1c 80 00       	mov    $0x801c44,%eax
  800617:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80061a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80061e:	0f 84 97 00 00 00    	je     8006bb <vprintfmt+0x22c>
  800624:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800628:	0f 8e 9b 00 00 00    	jle    8006c9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80062e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800632:	89 34 24             	mov    %esi,(%esp)
  800635:	e8 ce 06 00 00       	call   800d08 <strnlen>
  80063a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80063d:	29 c2                	sub    %eax,%edx
  80063f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800642:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800646:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800649:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80064c:	8b 75 08             	mov    0x8(%ebp),%esi
  80064f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800652:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800654:	eb 0f                	jmp    800665 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800656:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80065d:	89 04 24             	mov    %eax,(%esp)
  800660:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800662:	83 eb 01             	sub    $0x1,%ebx
  800665:	85 db                	test   %ebx,%ebx
  800667:	7f ed                	jg     800656 <vprintfmt+0x1c7>
  800669:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80066c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80066f:	85 d2                	test   %edx,%edx
  800671:	b8 00 00 00 00       	mov    $0x0,%eax
  800676:	0f 49 c2             	cmovns %edx,%eax
  800679:	29 c2                	sub    %eax,%edx
  80067b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80067e:	89 d7                	mov    %edx,%edi
  800680:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800683:	eb 50                	jmp    8006d5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800685:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800689:	74 1e                	je     8006a9 <vprintfmt+0x21a>
  80068b:	0f be d2             	movsbl %dl,%edx
  80068e:	83 ea 20             	sub    $0x20,%edx
  800691:	83 fa 5e             	cmp    $0x5e,%edx
  800694:	76 13                	jbe    8006a9 <vprintfmt+0x21a>
					putch('?', putdat);
  800696:	8b 45 0c             	mov    0xc(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006a4:	ff 55 08             	call   *0x8(%ebp)
  8006a7:	eb 0d                	jmp    8006b6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8006a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b6:	83 ef 01             	sub    $0x1,%edi
  8006b9:	eb 1a                	jmp    8006d5 <vprintfmt+0x246>
  8006bb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006be:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006c1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006c4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006c7:	eb 0c                	jmp    8006d5 <vprintfmt+0x246>
  8006c9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006cc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006cf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006d5:	83 c6 01             	add    $0x1,%esi
  8006d8:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8006dc:	0f be c2             	movsbl %dl,%eax
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 27                	je     80070a <vprintfmt+0x27b>
  8006e3:	85 db                	test   %ebx,%ebx
  8006e5:	78 9e                	js     800685 <vprintfmt+0x1f6>
  8006e7:	83 eb 01             	sub    $0x1,%ebx
  8006ea:	79 99                	jns    800685 <vprintfmt+0x1f6>
  8006ec:	89 f8                	mov    %edi,%eax
  8006ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f4:	89 c3                	mov    %eax,%ebx
  8006f6:	eb 1a                	jmp    800712 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800703:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800705:	83 eb 01             	sub    $0x1,%ebx
  800708:	eb 08                	jmp    800712 <vprintfmt+0x283>
  80070a:	89 fb                	mov    %edi,%ebx
  80070c:	8b 75 08             	mov    0x8(%ebp),%esi
  80070f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800712:	85 db                	test   %ebx,%ebx
  800714:	7f e2                	jg     8006f8 <vprintfmt+0x269>
  800716:	89 75 08             	mov    %esi,0x8(%ebp)
  800719:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80071c:	e9 93 fd ff ff       	jmp    8004b4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800721:	83 fa 01             	cmp    $0x1,%edx
  800724:	7e 16                	jle    80073c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 08             	lea    0x8(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 50 04             	mov    0x4(%eax),%edx
  800732:	8b 00                	mov    (%eax),%eax
  800734:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800737:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80073a:	eb 32                	jmp    80076e <vprintfmt+0x2df>
	else if (lflag)
  80073c:	85 d2                	test   %edx,%edx
  80073e:	74 18                	je     800758 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 50 04             	lea    0x4(%eax),%edx
  800746:	89 55 14             	mov    %edx,0x14(%ebp)
  800749:	8b 30                	mov    (%eax),%esi
  80074b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80074e:	89 f0                	mov    %esi,%eax
  800750:	c1 f8 1f             	sar    $0x1f,%eax
  800753:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800756:	eb 16                	jmp    80076e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 50 04             	lea    0x4(%eax),%edx
  80075e:	89 55 14             	mov    %edx,0x14(%ebp)
  800761:	8b 30                	mov    (%eax),%esi
  800763:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800766:	89 f0                	mov    %esi,%eax
  800768:	c1 f8 1f             	sar    $0x1f,%eax
  80076b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80076e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800771:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800774:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800779:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80077d:	0f 89 80 00 00 00    	jns    800803 <vprintfmt+0x374>
				putch('-', putdat);
  800783:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800787:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80078e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800791:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800794:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800797:	f7 d8                	neg    %eax
  800799:	83 d2 00             	adc    $0x0,%edx
  80079c:	f7 da                	neg    %edx
			}
			base = 10;
  80079e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a3:	eb 5e                	jmp    800803 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a8:	e8 63 fc ff ff       	call   800410 <getuint>
			base = 10;
  8007ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007b2:	eb 4f                	jmp    800803 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b7:	e8 54 fc ff ff       	call   800410 <getuint>
			base = 8 ;
  8007bc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  8007c1:	eb 40                	jmp    800803 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ce:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007dc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ef:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007f4:	eb 0d                	jmp    800803 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	e8 12 fc ff ff       	call   800410 <getuint>
			base = 16;
  8007fe:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800803:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800807:	89 74 24 10          	mov    %esi,0x10(%esp)
  80080b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80080e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800812:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800816:	89 04 24             	mov    %eax,(%esp)
  800819:	89 54 24 04          	mov    %edx,0x4(%esp)
  80081d:	89 fa                	mov    %edi,%edx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	e8 f9 f9 ff ff       	call   800220 <printnum>
			break;
  800827:	e9 88 fc ff ff       	jmp    8004b4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80082c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	ff 55 08             	call   *0x8(%ebp)
			break;
  800836:	e9 79 fc ff ff       	jmp    8004b4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80083b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80083f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800846:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800849:	89 f3                	mov    %esi,%ebx
  80084b:	eb 03                	jmp    800850 <vprintfmt+0x3c1>
  80084d:	83 eb 01             	sub    $0x1,%ebx
  800850:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800854:	75 f7                	jne    80084d <vprintfmt+0x3be>
  800856:	e9 59 fc ff ff       	jmp    8004b4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80085b:	83 c4 3c             	add    $0x3c,%esp
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5f                   	pop    %edi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	57                   	push   %edi
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	83 ec 3c             	sub    $0x3c,%esp
  80086c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8d 50 04             	lea    0x4(%eax),%edx
  800875:	89 55 14             	mov    %edx,0x14(%ebp)
  800878:	8b 00                	mov    (%eax),%eax
  80087a:	c1 e0 08             	shl    $0x8,%eax
  80087d:	0f b7 c0             	movzwl %ax,%eax
  800880:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800883:	83 c8 25             	or     $0x25,%eax
  800886:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800889:	eb 1a                	jmp    8008a5 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80088b:	85 c0                	test   %eax,%eax
  80088d:	0f 84 a9 03 00 00    	je     800c3c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800893:	8b 75 0c             	mov    0xc(%ebp),%esi
  800896:	89 74 24 04          	mov    %esi,0x4(%esp)
  80089a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80089d:	89 04 24             	mov    %eax,(%esp)
  8008a0:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a3:	89 fb                	mov    %edi,%ebx
  8008a5:	8d 7b 01             	lea    0x1(%ebx),%edi
  8008a8:	0f b6 03             	movzbl (%ebx),%eax
  8008ab:	83 f8 25             	cmp    $0x25,%eax
  8008ae:	75 db                	jne    80088b <cvprintfmt+0x28>
  8008b0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8008b4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008bb:	be ff ff ff ff       	mov    $0xffffffff,%esi
  8008c0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8008c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008cc:	eb 18                	jmp    8008e6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ce:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008d0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8008d4:	eb 10                	jmp    8008e6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d6:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008d8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8008dc:	eb 08                	jmp    8008e6 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8008de:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8008e1:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e6:	8d 5f 01             	lea    0x1(%edi),%ebx
  8008e9:	0f b6 0f             	movzbl (%edi),%ecx
  8008ec:	0f b6 c1             	movzbl %cl,%eax
  8008ef:	83 e9 23             	sub    $0x23,%ecx
  8008f2:	80 f9 55             	cmp    $0x55,%cl
  8008f5:	0f 87 1f 03 00 00    	ja     800c1a <cvprintfmt+0x3b7>
  8008fb:	0f b6 c9             	movzbl %cl,%ecx
  8008fe:	ff 24 8d 58 1e 80 00 	jmp    *0x801e58(,%ecx,4)
  800905:	89 df                	mov    %ebx,%edi
  800907:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80090c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80090f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800913:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800916:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800919:	83 f9 09             	cmp    $0x9,%ecx
  80091c:	77 33                	ja     800951 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80091e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800921:	eb e9                	jmp    80090c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8d 48 04             	lea    0x4(%eax),%ecx
  800929:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80092c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800930:	eb 1f                	jmp    800951 <cvprintfmt+0xee>
  800932:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800935:	85 ff                	test   %edi,%edi
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
  80093c:	0f 49 c7             	cmovns %edi,%eax
  80093f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800942:	89 df                	mov    %ebx,%edi
  800944:	eb a0                	jmp    8008e6 <cvprintfmt+0x83>
  800946:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800948:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80094f:	eb 95                	jmp    8008e6 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800951:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800955:	79 8f                	jns    8008e6 <cvprintfmt+0x83>
  800957:	eb 85                	jmp    8008de <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800959:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80095e:	66 90                	xchg   %ax,%ax
  800960:	eb 84                	jmp    8008e6 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800962:	8b 45 14             	mov    0x14(%ebp),%eax
  800965:	8d 50 04             	lea    0x4(%eax),%edx
  800968:	89 55 14             	mov    %edx,0x14(%ebp)
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800972:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800975:	0b 10                	or     (%eax),%edx
  800977:	89 14 24             	mov    %edx,(%esp)
  80097a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80097d:	e9 23 ff ff ff       	jmp    8008a5 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8d 50 04             	lea    0x4(%eax),%edx
  800988:	89 55 14             	mov    %edx,0x14(%ebp)
  80098b:	8b 00                	mov    (%eax),%eax
  80098d:	99                   	cltd   
  80098e:	31 d0                	xor    %edx,%eax
  800990:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800992:	83 f8 09             	cmp    $0x9,%eax
  800995:	7f 0b                	jg     8009a2 <cvprintfmt+0x13f>
  800997:	8b 14 85 c0 1f 80 00 	mov    0x801fc0(,%eax,4),%edx
  80099e:	85 d2                	test   %edx,%edx
  8009a0:	75 23                	jne    8009c5 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  8009a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a6:	c7 44 24 08 4b 1c 80 	movl   $0x801c4b,0x8(%esp)
  8009ad:	00 
  8009ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	89 04 24             	mov    %eax,(%esp)
  8009bb:	e8 a7 fa ff ff       	call   800467 <printfmt>
  8009c0:	e9 e0 fe ff ff       	jmp    8008a5 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  8009c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009c9:	c7 44 24 08 54 1c 80 	movl   $0x801c54,0x8(%esp)
  8009d0:	00 
  8009d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	89 04 24             	mov    %eax,(%esp)
  8009de:	e8 84 fa ff ff       	call   800467 <printfmt>
  8009e3:	e9 bd fe ff ff       	jmp    8008a5 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  8009ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f1:	8d 48 04             	lea    0x4(%eax),%ecx
  8009f4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8009f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009f9:	85 ff                	test   %edi,%edi
  8009fb:	b8 44 1c 80 00       	mov    $0x801c44,%eax
  800a00:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a03:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a07:	74 61                	je     800a6a <cvprintfmt+0x207>
  800a09:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a0d:	7e 5b                	jle    800a6a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a13:	89 3c 24             	mov    %edi,(%esp)
  800a16:	e8 ed 02 00 00       	call   800d08 <strnlen>
  800a1b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a1e:	29 c2                	sub    %eax,%edx
  800a20:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800a23:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a27:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a2a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a2d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800a30:	8b 75 08             	mov    0x8(%ebp),%esi
  800a33:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a36:	89 d3                	mov    %edx,%ebx
  800a38:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a3a:	eb 0f                	jmp    800a4b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a43:	89 3c 24             	mov    %edi,(%esp)
  800a46:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a48:	83 eb 01             	sub    $0x1,%ebx
  800a4b:	85 db                	test   %ebx,%ebx
  800a4d:	7f ed                	jg     800a3c <cvprintfmt+0x1d9>
  800a4f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a52:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a58:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a5b:	85 d2                	test   %edx,%edx
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a62:	0f 49 c2             	cmovns %edx,%eax
  800a65:	29 c2                	sub    %eax,%edx
  800a67:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800a6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a6d:	83 c8 3f             	or     $0x3f,%eax
  800a70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a73:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a76:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800a79:	eb 36                	jmp    800ab1 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a7f:	74 1d                	je     800a9e <cvprintfmt+0x23b>
  800a81:	0f be d2             	movsbl %dl,%edx
  800a84:	83 ea 20             	sub    $0x20,%edx
  800a87:	83 fa 5e             	cmp    $0x5e,%edx
  800a8a:	76 12                	jbe    800a9e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a93:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a96:	89 04 24             	mov    %eax,(%esp)
  800a99:	ff 55 08             	call   *0x8(%ebp)
  800a9c:	eb 10                	jmp    800aae <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa5:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800aa8:	89 04 24             	mov    %eax,(%esp)
  800aab:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aae:	83 eb 01             	sub    $0x1,%ebx
  800ab1:	83 c7 01             	add    $0x1,%edi
  800ab4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800ab8:	0f be c2             	movsbl %dl,%eax
  800abb:	85 c0                	test   %eax,%eax
  800abd:	74 27                	je     800ae6 <cvprintfmt+0x283>
  800abf:	85 f6                	test   %esi,%esi
  800ac1:	78 b8                	js     800a7b <cvprintfmt+0x218>
  800ac3:	83 ee 01             	sub    $0x1,%esi
  800ac6:	79 b3                	jns    800a7b <cvprintfmt+0x218>
  800ac8:	89 d8                	mov    %ebx,%eax
  800aca:	8b 75 08             	mov    0x8(%ebp),%esi
  800acd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ad0:	89 c3                	mov    %eax,%ebx
  800ad2:	eb 18                	jmp    800aec <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800ad4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800adf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800ae1:	83 eb 01             	sub    $0x1,%ebx
  800ae4:	eb 06                	jmp    800aec <cvprintfmt+0x289>
  800ae6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	7f e4                	jg     800ad4 <cvprintfmt+0x271>
  800af0:	89 75 08             	mov    %esi,0x8(%ebp)
  800af3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800af6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800af9:	e9 a7 fd ff ff       	jmp    8008a5 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800afe:	83 fa 01             	cmp    $0x1,%edx
  800b01:	7e 10                	jle    800b13 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800b03:	8b 45 14             	mov    0x14(%ebp),%eax
  800b06:	8d 50 08             	lea    0x8(%eax),%edx
  800b09:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0c:	8b 30                	mov    (%eax),%esi
  800b0e:	8b 78 04             	mov    0x4(%eax),%edi
  800b11:	eb 26                	jmp    800b39 <cvprintfmt+0x2d6>
	else if (lflag)
  800b13:	85 d2                	test   %edx,%edx
  800b15:	74 12                	je     800b29 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800b17:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1a:	8d 50 04             	lea    0x4(%eax),%edx
  800b1d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b20:	8b 30                	mov    (%eax),%esi
  800b22:	89 f7                	mov    %esi,%edi
  800b24:	c1 ff 1f             	sar    $0x1f,%edi
  800b27:	eb 10                	jmp    800b39 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800b29:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2c:	8d 50 04             	lea    0x4(%eax),%edx
  800b2f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b32:	8b 30                	mov    (%eax),%esi
  800b34:	89 f7                	mov    %esi,%edi
  800b36:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b39:	89 f0                	mov    %esi,%eax
  800b3b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b3d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b42:	85 ff                	test   %edi,%edi
  800b44:	0f 89 8e 00 00 00    	jns    800bd8 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b54:	83 c8 2d             	or     $0x2d,%eax
  800b57:	89 04 24             	mov    %eax,(%esp)
  800b5a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b5d:	89 f0                	mov    %esi,%eax
  800b5f:	89 fa                	mov    %edi,%edx
  800b61:	f7 d8                	neg    %eax
  800b63:	83 d2 00             	adc    $0x0,%edx
  800b66:	f7 da                	neg    %edx
			}
			base = 10;
  800b68:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b6d:	eb 69                	jmp    800bd8 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b6f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b72:	e8 99 f8 ff ff       	call   800410 <getuint>
			base = 10;
  800b77:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b7c:	eb 5a                	jmp    800bd8 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b7e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b81:	e8 8a f8 ff ff       	call   800410 <getuint>
			base = 8 ;
  800b86:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800b8b:	eb 4b                	jmp    800bd8 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b90:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b94:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800b97:	89 f0                	mov    %esi,%eax
  800b99:	83 c8 30             	or     $0x30,%eax
  800b9c:	89 04 24             	mov    %eax,(%esp)
  800b9f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba9:	89 f0                	mov    %esi,%eax
  800bab:	83 c8 78             	or     $0x78,%eax
  800bae:	89 04 24             	mov    %eax,(%esp)
  800bb1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bb4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb7:	8d 50 04             	lea    0x4(%eax),%edx
  800bba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800bbd:	8b 00                	mov    (%eax),%eax
  800bbf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bc4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bc9:	eb 0d                	jmp    800bd8 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bcb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bce:	e8 3d f8 ff ff       	call   800410 <getuint>
			base = 16;
  800bd3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800bd8:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800bdc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800be0:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800be3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800be7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800beb:	89 04 24             	mov    %eax,(%esp)
  800bee:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bfb:	e8 0f f7 ff ff       	call   80030f <cprintnum>
			break;
  800c00:	e9 a0 fc ff ff       	jmp    8008a5 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800c05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c08:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c0c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800c0f:	89 04 24             	mov    %eax,(%esp)
  800c12:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c15:	e9 8b fc ff ff       	jmp    8008a5 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c24:	89 04 24             	mov    %eax,(%esp)
  800c27:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c2a:	89 fb                	mov    %edi,%ebx
  800c2c:	eb 03                	jmp    800c31 <cvprintfmt+0x3ce>
  800c2e:	83 eb 01             	sub    $0x1,%ebx
  800c31:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c35:	75 f7                	jne    800c2e <cvprintfmt+0x3cb>
  800c37:	e9 69 fc ff ff       	jmp    8008a5 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800c3c:	83 c4 3c             	add    $0x3c,%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c4a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800c4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c51:	8b 45 10             	mov    0x10(%ebp),%eax
  800c54:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c62:	89 04 24             	mov    %eax,(%esp)
  800c65:	e8 f9 fb ff ff       	call   800863 <cvprintfmt>
	va_end(ap);
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 28             	sub    $0x28,%esp
  800c72:	8b 45 08             	mov    0x8(%ebp),%eax
  800c75:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c78:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c7b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c7f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	74 30                	je     800cbd <vsnprintf+0x51>
  800c8d:	85 d2                	test   %edx,%edx
  800c8f:	7e 2c                	jle    800cbd <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c91:	8b 45 14             	mov    0x14(%ebp),%eax
  800c94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c98:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca6:	c7 04 24 4a 04 80 00 	movl   $0x80044a,(%esp)
  800cad:	e8 dd f7 ff ff       	call   80048f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cb5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbb:	eb 05                	jmp    800cc2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    

00800cc4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ccd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cd1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce2:	89 04 24             	mov    %eax,(%esp)
  800ce5:	e8 82 ff ff ff       	call   800c6c <vsnprintf>
	va_end(ap);

	return rc;
}
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    
  800cec:	66 90                	xchg   %ax,%ax
  800cee:	66 90                	xchg   %ax,%ax

00800cf0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfb:	eb 03                	jmp    800d00 <strlen+0x10>
		n++;
  800cfd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d00:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d04:	75 f7                	jne    800cfd <strlen+0xd>
		n++;
	return n;
}
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d11:	b8 00 00 00 00       	mov    $0x0,%eax
  800d16:	eb 03                	jmp    800d1b <strnlen+0x13>
		n++;
  800d18:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d1b:	39 d0                	cmp    %edx,%eax
  800d1d:	74 06                	je     800d25 <strnlen+0x1d>
  800d1f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d23:	75 f3                	jne    800d18 <strnlen+0x10>
		n++;
	return n;
}
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	53                   	push   %ebx
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d31:	89 c2                	mov    %eax,%edx
  800d33:	83 c2 01             	add    $0x1,%edx
  800d36:	83 c1 01             	add    $0x1,%ecx
  800d39:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d3d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d40:	84 db                	test   %bl,%bl
  800d42:	75 ef                	jne    800d33 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d44:	5b                   	pop    %ebx
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 08             	sub    $0x8,%esp
  800d4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d51:	89 1c 24             	mov    %ebx,(%esp)
  800d54:	e8 97 ff ff ff       	call   800cf0 <strlen>
	strcpy(dst + len, src);
  800d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d60:	01 d8                	add    %ebx,%eax
  800d62:	89 04 24             	mov    %eax,(%esp)
  800d65:	e8 bd ff ff ff       	call   800d27 <strcpy>
	return dst;
}
  800d6a:	89 d8                	mov    %ebx,%eax
  800d6c:	83 c4 08             	add    $0x8,%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
  800d77:	8b 75 08             	mov    0x8(%ebp),%esi
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	89 f3                	mov    %esi,%ebx
  800d7f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d82:	89 f2                	mov    %esi,%edx
  800d84:	eb 0f                	jmp    800d95 <strncpy+0x23>
		*dst++ = *src;
  800d86:	83 c2 01             	add    $0x1,%edx
  800d89:	0f b6 01             	movzbl (%ecx),%eax
  800d8c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d8f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d92:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d95:	39 da                	cmp    %ebx,%edx
  800d97:	75 ed                	jne    800d86 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d99:	89 f0                	mov    %esi,%eax
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 75 08             	mov    0x8(%ebp),%esi
  800da7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800daa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800dad:	89 f0                	mov    %esi,%eax
  800daf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800db3:	85 c9                	test   %ecx,%ecx
  800db5:	75 0b                	jne    800dc2 <strlcpy+0x23>
  800db7:	eb 1d                	jmp    800dd6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800db9:	83 c0 01             	add    $0x1,%eax
  800dbc:	83 c2 01             	add    $0x1,%edx
  800dbf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dc2:	39 d8                	cmp    %ebx,%eax
  800dc4:	74 0b                	je     800dd1 <strlcpy+0x32>
  800dc6:	0f b6 0a             	movzbl (%edx),%ecx
  800dc9:	84 c9                	test   %cl,%cl
  800dcb:	75 ec                	jne    800db9 <strlcpy+0x1a>
  800dcd:	89 c2                	mov    %eax,%edx
  800dcf:	eb 02                	jmp    800dd3 <strlcpy+0x34>
  800dd1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800dd3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800dd6:	29 f0                	sub    %esi,%eax
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de5:	eb 06                	jmp    800ded <strcmp+0x11>
		p++, q++;
  800de7:	83 c1 01             	add    $0x1,%ecx
  800dea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ded:	0f b6 01             	movzbl (%ecx),%eax
  800df0:	84 c0                	test   %al,%al
  800df2:	74 04                	je     800df8 <strcmp+0x1c>
  800df4:	3a 02                	cmp    (%edx),%al
  800df6:	74 ef                	je     800de7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800df8:	0f b6 c0             	movzbl %al,%eax
  800dfb:	0f b6 12             	movzbl (%edx),%edx
  800dfe:	29 d0                	sub    %edx,%eax
}
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	53                   	push   %ebx
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0c:	89 c3                	mov    %eax,%ebx
  800e0e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e11:	eb 06                	jmp    800e19 <strncmp+0x17>
		n--, p++, q++;
  800e13:	83 c0 01             	add    $0x1,%eax
  800e16:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e19:	39 d8                	cmp    %ebx,%eax
  800e1b:	74 15                	je     800e32 <strncmp+0x30>
  800e1d:	0f b6 08             	movzbl (%eax),%ecx
  800e20:	84 c9                	test   %cl,%cl
  800e22:	74 04                	je     800e28 <strncmp+0x26>
  800e24:	3a 0a                	cmp    (%edx),%cl
  800e26:	74 eb                	je     800e13 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e28:	0f b6 00             	movzbl (%eax),%eax
  800e2b:	0f b6 12             	movzbl (%edx),%edx
  800e2e:	29 d0                	sub    %edx,%eax
  800e30:	eb 05                	jmp    800e37 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e32:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e37:	5b                   	pop    %ebx
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e44:	eb 07                	jmp    800e4d <strchr+0x13>
		if (*s == c)
  800e46:	38 ca                	cmp    %cl,%dl
  800e48:	74 0f                	je     800e59 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e4a:	83 c0 01             	add    $0x1,%eax
  800e4d:	0f b6 10             	movzbl (%eax),%edx
  800e50:	84 d2                	test   %dl,%dl
  800e52:	75 f2                	jne    800e46 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e65:	eb 07                	jmp    800e6e <strfind+0x13>
		if (*s == c)
  800e67:	38 ca                	cmp    %cl,%dl
  800e69:	74 0a                	je     800e75 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e6b:	83 c0 01             	add    $0x1,%eax
  800e6e:	0f b6 10             	movzbl (%eax),%edx
  800e71:	84 d2                	test   %dl,%dl
  800e73:	75 f2                	jne    800e67 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e83:	85 c9                	test   %ecx,%ecx
  800e85:	74 36                	je     800ebd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e87:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e8d:	75 28                	jne    800eb7 <memset+0x40>
  800e8f:	f6 c1 03             	test   $0x3,%cl
  800e92:	75 23                	jne    800eb7 <memset+0x40>
		c &= 0xFF;
  800e94:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e98:	89 d3                	mov    %edx,%ebx
  800e9a:	c1 e3 08             	shl    $0x8,%ebx
  800e9d:	89 d6                	mov    %edx,%esi
  800e9f:	c1 e6 18             	shl    $0x18,%esi
  800ea2:	89 d0                	mov    %edx,%eax
  800ea4:	c1 e0 10             	shl    $0x10,%eax
  800ea7:	09 f0                	or     %esi,%eax
  800ea9:	09 c2                	or     %eax,%edx
  800eab:	89 d0                	mov    %edx,%eax
  800ead:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eaf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800eb2:	fc                   	cld    
  800eb3:	f3 ab                	rep stos %eax,%es:(%edi)
  800eb5:	eb 06                	jmp    800ebd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eba:	fc                   	cld    
  800ebb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ebd:	89 f8                	mov    %edi,%eax
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ecf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ed2:	39 c6                	cmp    %eax,%esi
  800ed4:	73 35                	jae    800f0b <memmove+0x47>
  800ed6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ed9:	39 d0                	cmp    %edx,%eax
  800edb:	73 2e                	jae    800f0b <memmove+0x47>
		s += n;
		d += n;
  800edd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ee0:	89 d6                	mov    %edx,%esi
  800ee2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eea:	75 13                	jne    800eff <memmove+0x3b>
  800eec:	f6 c1 03             	test   $0x3,%cl
  800eef:	75 0e                	jne    800eff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef1:	83 ef 04             	sub    $0x4,%edi
  800ef4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ef7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800efa:	fd                   	std    
  800efb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800efd:	eb 09                	jmp    800f08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eff:	83 ef 01             	sub    $0x1,%edi
  800f02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f05:	fd                   	std    
  800f06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f08:	fc                   	cld    
  800f09:	eb 1d                	jmp    800f28 <memmove+0x64>
  800f0b:	89 f2                	mov    %esi,%edx
  800f0d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f0f:	f6 c2 03             	test   $0x3,%dl
  800f12:	75 0f                	jne    800f23 <memmove+0x5f>
  800f14:	f6 c1 03             	test   $0x3,%cl
  800f17:	75 0a                	jne    800f23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f19:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f1c:	89 c7                	mov    %eax,%edi
  800f1e:	fc                   	cld    
  800f1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f21:	eb 05                	jmp    800f28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f23:	89 c7                	mov    %eax,%edi
  800f25:	fc                   	cld    
  800f26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f28:	5e                   	pop    %esi
  800f29:	5f                   	pop    %edi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f32:	8b 45 10             	mov    0x10(%ebp),%eax
  800f35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
  800f43:	89 04 24             	mov    %eax,(%esp)
  800f46:	e8 79 ff ff ff       	call   800ec4 <memmove>
}
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	8b 55 08             	mov    0x8(%ebp),%edx
  800f55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f58:	89 d6                	mov    %edx,%esi
  800f5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f5d:	eb 1a                	jmp    800f79 <memcmp+0x2c>
		if (*s1 != *s2)
  800f5f:	0f b6 02             	movzbl (%edx),%eax
  800f62:	0f b6 19             	movzbl (%ecx),%ebx
  800f65:	38 d8                	cmp    %bl,%al
  800f67:	74 0a                	je     800f73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f69:	0f b6 c0             	movzbl %al,%eax
  800f6c:	0f b6 db             	movzbl %bl,%ebx
  800f6f:	29 d8                	sub    %ebx,%eax
  800f71:	eb 0f                	jmp    800f82 <memcmp+0x35>
		s1++, s2++;
  800f73:	83 c2 01             	add    $0x1,%edx
  800f76:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f79:	39 f2                	cmp    %esi,%edx
  800f7b:	75 e2                	jne    800f5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f8f:	89 c2                	mov    %eax,%edx
  800f91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f94:	eb 07                	jmp    800f9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f96:	38 08                	cmp    %cl,(%eax)
  800f98:	74 07                	je     800fa1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f9a:	83 c0 01             	add    $0x1,%eax
  800f9d:	39 d0                	cmp    %edx,%eax
  800f9f:	72 f5                	jb     800f96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800faf:	eb 03                	jmp    800fb4 <strtol+0x11>
		s++;
  800fb1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fb4:	0f b6 0a             	movzbl (%edx),%ecx
  800fb7:	80 f9 09             	cmp    $0x9,%cl
  800fba:	74 f5                	je     800fb1 <strtol+0xe>
  800fbc:	80 f9 20             	cmp    $0x20,%cl
  800fbf:	74 f0                	je     800fb1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fc1:	80 f9 2b             	cmp    $0x2b,%cl
  800fc4:	75 0a                	jne    800fd0 <strtol+0x2d>
		s++;
  800fc6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fc9:	bf 00 00 00 00       	mov    $0x0,%edi
  800fce:	eb 11                	jmp    800fe1 <strtol+0x3e>
  800fd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fd5:	80 f9 2d             	cmp    $0x2d,%cl
  800fd8:	75 07                	jne    800fe1 <strtol+0x3e>
		s++, neg = 1;
  800fda:	8d 52 01             	lea    0x1(%edx),%edx
  800fdd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fe1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800fe6:	75 15                	jne    800ffd <strtol+0x5a>
  800fe8:	80 3a 30             	cmpb   $0x30,(%edx)
  800feb:	75 10                	jne    800ffd <strtol+0x5a>
  800fed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ff1:	75 0a                	jne    800ffd <strtol+0x5a>
		s += 2, base = 16;
  800ff3:	83 c2 02             	add    $0x2,%edx
  800ff6:	b8 10 00 00 00       	mov    $0x10,%eax
  800ffb:	eb 10                	jmp    80100d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	75 0c                	jne    80100d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801001:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801003:	80 3a 30             	cmpb   $0x30,(%edx)
  801006:	75 05                	jne    80100d <strtol+0x6a>
		s++, base = 8;
  801008:	83 c2 01             	add    $0x1,%edx
  80100b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80100d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801012:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801015:	0f b6 0a             	movzbl (%edx),%ecx
  801018:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80101b:	89 f0                	mov    %esi,%eax
  80101d:	3c 09                	cmp    $0x9,%al
  80101f:	77 08                	ja     801029 <strtol+0x86>
			dig = *s - '0';
  801021:	0f be c9             	movsbl %cl,%ecx
  801024:	83 e9 30             	sub    $0x30,%ecx
  801027:	eb 20                	jmp    801049 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801029:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80102c:	89 f0                	mov    %esi,%eax
  80102e:	3c 19                	cmp    $0x19,%al
  801030:	77 08                	ja     80103a <strtol+0x97>
			dig = *s - 'a' + 10;
  801032:	0f be c9             	movsbl %cl,%ecx
  801035:	83 e9 57             	sub    $0x57,%ecx
  801038:	eb 0f                	jmp    801049 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80103a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80103d:	89 f0                	mov    %esi,%eax
  80103f:	3c 19                	cmp    $0x19,%al
  801041:	77 16                	ja     801059 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801043:	0f be c9             	movsbl %cl,%ecx
  801046:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801049:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80104c:	7d 0f                	jge    80105d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80104e:	83 c2 01             	add    $0x1,%edx
  801051:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801055:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801057:	eb bc                	jmp    801015 <strtol+0x72>
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	eb 02                	jmp    80105f <strtol+0xbc>
  80105d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80105f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801063:	74 05                	je     80106a <strtol+0xc7>
		*endptr = (char *) s;
  801065:	8b 75 0c             	mov    0xc(%ebp),%esi
  801068:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80106a:	f7 d8                	neg    %eax
  80106c:	85 ff                	test   %edi,%edi
  80106e:	0f 44 c3             	cmove  %ebx,%eax
}
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
  801081:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801084:	8b 55 08             	mov    0x8(%ebp),%edx
  801087:	89 c3                	mov    %eax,%ebx
  801089:	89 c7                	mov    %eax,%edi
  80108b:	89 c6                	mov    %eax,%esi
  80108d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_cgetc>:

int
sys_cgetc(void)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109a:	ba 00 00 00 00       	mov    $0x0,%edx
  80109f:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a4:	89 d1                	mov    %edx,%ecx
  8010a6:	89 d3                	mov    %edx,%ebx
  8010a8:	89 d7                	mov    %edx,%edi
  8010aa:	89 d6                	mov    %edx,%esi
  8010ac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c9:	89 cb                	mov    %ecx,%ebx
  8010cb:	89 cf                	mov    %ecx,%edi
  8010cd:	89 ce                	mov    %ecx,%esi
  8010cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	7e 28                	jle    8010fd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8010f8:	e8 a9 07 00 00       	call   8018a6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010fd:	83 c4 2c             	add    $0x2c,%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5f                   	pop    %edi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110b:	ba 00 00 00 00       	mov    $0x0,%edx
  801110:	b8 02 00 00 00       	mov    $0x2,%eax
  801115:	89 d1                	mov    %edx,%ecx
  801117:	89 d3                	mov    %edx,%ebx
  801119:	89 d7                	mov    %edx,%edi
  80111b:	89 d6                	mov    %edx,%esi
  80111d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	5f                   	pop    %edi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <sys_yield>:

void
sys_yield(void)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	57                   	push   %edi
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112a:	ba 00 00 00 00       	mov    $0x0,%edx
  80112f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801134:	89 d1                	mov    %edx,%ecx
  801136:	89 d3                	mov    %edx,%ebx
  801138:	89 d7                	mov    %edx,%edi
  80113a:	89 d6                	mov    %edx,%esi
  80113c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114c:	be 00 00 00 00       	mov    $0x0,%esi
  801151:	b8 04 00 00 00       	mov    $0x4,%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80115f:	89 f7                	mov    %esi,%edi
  801161:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801163:	85 c0                	test   %eax,%eax
  801165:	7e 28                	jle    80118f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801167:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801172:	00 
  801173:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  80117a:	00 
  80117b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801182:	00 
  801183:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  80118a:	e8 17 07 00 00       	call   8018a6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80118f:	83 c4 2c             	add    $0x2c,%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8011a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011b1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	7e 28                	jle    8011e2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011be:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011c5:	00 
  8011c6:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  8011cd:	00 
  8011ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d5:	00 
  8011d6:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8011dd:	e8 c4 06 00 00       	call   8018a6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011e2:	83 c4 2c             	add    $0x2c,%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	57                   	push   %edi
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8011fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801200:	8b 55 08             	mov    0x8(%ebp),%edx
  801203:	89 df                	mov    %ebx,%edi
  801205:	89 de                	mov    %ebx,%esi
  801207:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801209:	85 c0                	test   %eax,%eax
  80120b:	7e 28                	jle    801235 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80120d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801211:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801218:	00 
  801219:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  801220:	00 
  801221:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801230:	e8 71 06 00 00       	call   8018a6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801235:	83 c4 2c             	add    $0x2c,%esp
  801238:	5b                   	pop    %ebx
  801239:	5e                   	pop    %esi
  80123a:	5f                   	pop    %edi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	57                   	push   %edi
  801241:	56                   	push   %esi
  801242:	53                   	push   %ebx
  801243:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124b:	b8 08 00 00 00       	mov    $0x8,%eax
  801250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801253:	8b 55 08             	mov    0x8(%ebp),%edx
  801256:	89 df                	mov    %ebx,%edi
  801258:	89 de                	mov    %ebx,%esi
  80125a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80125c:	85 c0                	test   %eax,%eax
  80125e:	7e 28                	jle    801288 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801260:	89 44 24 10          	mov    %eax,0x10(%esp)
  801264:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80126b:	00 
  80126c:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  801273:	00 
  801274:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80127b:	00 
  80127c:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801283:	e8 1e 06 00 00       	call   8018a6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801288:	83 c4 2c             	add    $0x2c,%esp
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5f                   	pop    %edi
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	57                   	push   %edi
  801294:	56                   	push   %esi
  801295:	53                   	push   %ebx
  801296:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801299:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129e:	b8 09 00 00 00       	mov    $0x9,%eax
  8012a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a9:	89 df                	mov    %ebx,%edi
  8012ab:	89 de                	mov    %ebx,%esi
  8012ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	7e 28                	jle    8012db <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012be:	00 
  8012bf:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  8012c6:	00 
  8012c7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012ce:	00 
  8012cf:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8012d6:	e8 cb 05 00 00       	call   8018a6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012db:	83 c4 2c             	add    $0x2c,%esp
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5f                   	pop    %edi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	57                   	push   %edi
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e9:	be 00 00 00 00       	mov    $0x0,%esi
  8012ee:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801301:	5b                   	pop    %ebx
  801302:	5e                   	pop    %esi
  801303:	5f                   	pop    %edi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	57                   	push   %edi
  80130a:	56                   	push   %esi
  80130b:	53                   	push   %ebx
  80130c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80130f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801314:	b8 0c 00 00 00       	mov    $0xc,%eax
  801319:	8b 55 08             	mov    0x8(%ebp),%edx
  80131c:	89 cb                	mov    %ecx,%ebx
  80131e:	89 cf                	mov    %ecx,%edi
  801320:	89 ce                	mov    %ecx,%esi
  801322:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801324:	85 c0                	test   %eax,%eax
  801326:	7e 28                	jle    801350 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801328:	89 44 24 10          	mov    %eax,0x10(%esp)
  80132c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801333:	00 
  801334:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  80133b:	00 
  80133c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801343:	00 
  801344:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  80134b:	e8 56 05 00 00       	call   8018a6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801350:	83 c4 2c             	add    $0x2c,%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    

00801358 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	57                   	push   %edi
  80135c:	56                   	push   %esi
  80135d:	53                   	push   %ebx
  80135e:	83 ec 2c             	sub    $0x2c,%esp
	void *addr = (void *) utf->utf_fault_va;
  801361:	8b 45 08             	mov    0x8(%ebp),%eax
  801364:	8b 30                	mov    (%eax),%esi
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf(" pgfault : fault va is  %08x\n", ( uint32_t ) addr ) ; 
	//cprintf(" pgfault : fault eip is  %08x\n", ( uint32_t ) utf->utf_eip ) ; 
	pde_t * pde_ptr = ( pde_t * ) ( UVPT + ( PDX(UVPT) << 12 ) + ( PDX(addr) << 2 ) ) ; 
  801366:	89 f0                	mov    %esi,%eax
  801368:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( UVPT + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  80136b:	89 c1                	mov    %eax,%ecx
  80136d:	c1 e1 0c             	shl    $0xc,%ecx
  801370:	89 f2                	mov    %esi,%edx
  801372:	c1 ea 0a             	shr    $0xa,%edx
  801375:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  80137b:	8d bc 11 00 00 40 ef 	lea    -0x10c00000(%ecx,%edx,1),%edi
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  801382:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  801389:	01 
  80138a:	75 1c                	jne    8013a8 <pgfault+0x50>
		panic(" in inc/fork.c <pgfault> : Page Directory Entry doesn't exsist!\n");
  80138c:	c7 44 24 08 14 20 80 	movl   $0x802014,0x8(%esp)
  801393:	00 
  801394:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80139b:	00 
  80139c:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8013a3:	e8 fe 04 00 00       	call   8018a6 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  8013a8:	8b 07                	mov    (%edi),%eax
  8013aa:	a8 01                	test   $0x1,%al
  8013ac:	75 1c                	jne    8013ca <pgfault+0x72>
		panic(" in inc/fork.c <pgfault> : Page Table Entry doesn't exsist!\n");
  8013ae:	c7 44 24 08 58 20 80 	movl   $0x802058,0x8(%esp)
  8013b5:	00 
  8013b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013bd:	00 
  8013be:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8013c5:	e8 dc 04 00 00       	call   8018a6 <_panic>
	if (!( ( ( *pte_ptr ) & PTE_W ) || ( ( *pte_ptr ) & PTE_COW ) ) )
  8013ca:	a9 02 08 00 00       	test   $0x802,%eax
  8013cf:	75 1c                	jne    8013ed <pgfault+0x95>
		panic(" in inc/fork.c <pgfault> : Invalid page!\n");
  8013d1:	c7 44 24 08 98 20 80 	movl   $0x802098,0x8(%esp)
  8013d8:	00 
  8013d9:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8013e0:	00 
  8013e1:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8013e8:	e8 b9 04 00 00       	call   8018a6 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid() ;
  8013ed:	e8 13 fd ff ff       	call   801105 <sys_getenvid>
  8013f2:	89 c3                	mov    %eax,%ebx
	//cprintf(" pgfault : %d\n %08x\n",envid , PFTEMP); 
	sys_page_alloc( envid , ( void * ) PFTEMP , (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W);  
  8013f4:	8b 07                	mov    (%edi),%eax
  8013f6:	25 05 06 00 00       	and    $0x605,%eax
  8013fb:	83 c8 02             	or     $0x2,%eax
  8013fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801402:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801409:	00 
  80140a:	89 1c 24             	mov    %ebx,(%esp)
  80140d:	e8 31 fd ff ff       	call   801143 <sys_page_alloc>
	//cprintf(" Did it reach here and made an alloc call?\n");
	memmove( ( void * ) PFTEMP , ( void * ) ROUNDDOWN( addr , PGSIZE ) , PGSIZE ) ; 
  801412:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801418:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80141f:	00 
  801420:	89 74 24 04          	mov    %esi,0x4(%esp)
  801424:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80142b:	e8 94 fa ff ff       	call   800ec4 <memmove>
	sys_page_map( envid , ( void * ) PFTEMP , envid , ( void * ) ROUNDDOWN( addr , PGSIZE ) ,  (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W );  
  801430:	8b 07                	mov    (%edi),%eax
  801432:	25 05 06 00 00       	and    $0x605,%eax
  801437:	83 c8 02             	or     $0x2,%eax
  80143a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80143e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801442:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801446:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80144d:	00 
  80144e:	89 1c 24             	mov    %ebx,(%esp)
  801451:	e8 41 fd ff ff       	call   801197 <sys_page_map>
	sys_page_unmap( envid , PFTEMP ) ; 
  801456:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80145d:	00 
  80145e:	89 1c 24             	mov    %ebx,(%esp)
  801461:	e8 84 fd ff ff       	call   8011ea <sys_page_unmap>
	//panic("pgfault not implemented");
}
  801466:	83 c4 2c             	add    $0x2c,%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	57                   	push   %edi
  801472:	56                   	push   %esi
  801473:	53                   	push   %ebx
  801474:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// First , set handler
	set_pgfault_handler(pgfault); 
  801477:	c7 04 24 58 13 80 00 	movl   $0x801358,(%esp)
  80147e:	e8 79 04 00 00       	call   8018fc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801483:	b8 07 00 00 00       	mov    $0x7,%eax
  801488:	cd 30                	int    $0x30
  80148a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80148d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
  801490:	85 c0                	test   %eax,%eax
  801492:	79 1c                	jns    8014b0 <fork+0x42>
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
  801494:	c7 44 24 08 c4 20 80 	movl   $0x8020c4,0x8(%esp)
  80149b:	00 
  80149c:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  8014a3:	00 
  8014a4:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8014ab:	e8 f6 03 00 00       	call   8018a6 <_panic>
	if ( childid == 0 ) {
  8014b0:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014b4:	74 17                	je     8014cd <fork+0x5f>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  8014b6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8014bb:	c1 e8 16             	shr    $0x16,%eax
  8014be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8014c1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8014c8:	e9 26 02 00 00       	jmp    8016f3 <fork+0x285>
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
	if ( childid == 0 ) {
		thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  8014cd:	e8 33 fc ff ff       	call   801105 <sys_getenvid>
  8014d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	c1 e2 07             	shl    $0x7,%edx
  8014dc:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8014e3:	a3 04 30 80 00       	mov    %eax,0x803004
		return 0 ;
  8014e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ed:	e9 22 02 00 00       	jmp    801714 <fork+0x2a6>
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
  8014f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014f5:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  8014fc:	01 
  8014fd:	0f 84 ec 01 00 00    	je     8016ef <fork+0x281>
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
  801503:	89 c6                	mov    %eax,%esi
  801505:	c1 e0 0c             	shl    $0xc,%eax
  801508:	8d b8 00 00 40 ef    	lea    -0x10c00000(%eax),%edi
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
			     ( ptx != PTX(UXSTACKTOP-PGSIZE) ) ) {
				//cprintf(" fork : pdx : %d , ptx : %d\n" , pdx , ptx ) ; 
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
  80150e:	c1 e6 16             	shl    $0x16,%esi
  801511:	bb 00 00 00 00       	mov    $0x0,%ebx
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
			if ( ! ( ( * pte_ptr ) & PTE_P ) )  continue ; 
  801516:	f6 04 9f 01          	testb  $0x1,(%edi,%ebx,4)
  80151a:	0f 84 ba 01 00 00    	je     8016da <fork+0x26c>
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
  801520:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  801526:	75 0d                	jne    801535 <fork+0xc7>
  801528:	81 7d dc ba 03 00 00 	cmpl   $0x3ba,-0x24(%ebp)
  80152f:	0f 84 8a 01 00 00    	je     8016bf <fork+0x251>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid() ; 
  801535:	e8 cb fb ff ff       	call   801105 <sys_getenvid>
  80153a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t addr = pn * PGSIZE ;
	//cprintf(" duppage : now envid is : %d\n", sys_getenvid() ) ;
	//cprintf(" duppage : page address is %08x %d %d\n" , addr,PDX(addr),PTX(addr) ) ;
	pde_t * pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd ) + ( PDX(addr) << 2 ) ) ; 
  80153d:	89 f0                	mov    %esi,%eax
  80153f:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  801542:	89 c1                	mov    %eax,%ecx
  801544:	c1 e1 0c             	shl    $0xc,%ecx
  801547:	81 c1 00 00 40 ef    	add    $0xef400000,%ecx
  80154d:	89 f2                	mov    %esi,%edx
  80154f:	c1 ea 0a             	shr    $0xa,%edx
  801552:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801558:	01 ca                	add    %ecx,%edx
	
	//cprintf(" duppage : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
	//cprintf(" duppage : pte_ptr's value is : %08x\n" , ( * pte_ptr ) ) ;
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  80155a:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  80155f:	f6 04 81 01          	testb  $0x1,(%ecx,%eax,4)
  801563:	75 1c                	jne    801581 <fork+0x113>
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
  801565:	c7 44 24 08 f8 20 80 	movl   $0x8020f8,0x8(%esp)
  80156c:	00 
  80156d:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801574:	00 
  801575:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  80157c:	e8 25 03 00 00       	call   8018a6 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  801581:	8b 02                	mov    (%edx),%eax
  801583:	a8 01                	test   $0x1,%al
  801585:	75 1c                	jne    8015a3 <fork+0x135>
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
  801587:	c7 44 24 08 3c 21 80 	movl   $0x80213c,0x8(%esp)
  80158e:	00 
  80158f:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801596:	00 
  801597:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  80159e:	e8 03 03 00 00       	call   8018a6 <_panic>
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	if ( perm & PTE_W ) {
  8015ab:	a8 02                	test   $0x2,%al
  8015ad:	0f 84 8b 00 00 00    	je     80163e <fork+0x1d0>
		if ( sys_page_map( curenvid , ( void * ) addr , 
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
  8015b3:	89 d0                	mov    %edx,%eax
  8015b5:	83 f0 02             	xor    $0x2,%eax
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
	if (!( ( * pte_ptr ) & PTE_P ) ) 
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
	if ( perm & PTE_W ) {
		if ( sys_page_map( curenvid , ( void * ) addr , 
  8015b8:	80 cc 08             	or     $0x8,%ah
  8015bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d4:	89 04 24             	mov    %eax,(%esp)
  8015d7:	e8 bb fb ff ff       	call   801197 <sys_page_map>
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	79 1c                	jns    8015fc <fork+0x18e>
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page! %e\n");
  8015e0:	c7 44 24 08 7c 21 80 	movl   $0x80217c,0x8(%esp)
  8015e7:	00 
  8015e8:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8015ef:	00 
  8015f0:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8015f7:	e8 aa 02 00 00       	call   8018a6 <_panic>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  8015fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801603:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801607:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80160e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801612:	89 04 24             	mov    %eax,(%esp)
  801615:	e8 7d fb ff ff       	call   801197 <sys_page_map>
  80161a:	85 c0                	test   %eax,%eax
  80161c:	0f 89 b8 00 00 00    	jns    8016da <fork+0x26c>
				   curenvid , ( void * ) addr , 
				   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  801622:	c7 44 24 08 b4 21 80 	movl   $0x8021b4,0x8(%esp)
  801629:	00 
  80162a:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  801631:	00 
  801632:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  801639:	e8 68 02 00 00       	call   8018a6 <_panic>
		return 0 ; 	
	}  
	if ( perm & PTE_COW ) {
  80163e:	f6 c4 08             	test   $0x8,%ah
  801641:	74 3e                	je     801681 <fork+0x213>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  801643:	89 54 24 10          	mov    %edx,0x10(%esp)
  801647:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80164b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80164e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801652:	89 74 24 04          	mov    %esi,0x4(%esp)
  801656:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801659:	89 04 24             	mov    %eax,(%esp)
  80165c:	e8 36 fb ff ff       	call   801197 <sys_page_map>
  801661:	85 c0                	test   %eax,%eax
  801663:	79 75                	jns    8016da <fork+0x26c>
                                   envid    , ( void * ) addr , 
                                   perm ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  801665:	c7 44 24 08 b4 21 80 	movl   $0x8021b4,0x8(%esp)
  80166c:	00 
  80166d:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801674:	00 
  801675:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  80167c:	e8 25 02 00 00       	call   8018a6 <_panic>
		return 0 ;
	}
	if ( sys_page_map( curenvid , ( void * ) addr , 
  801681:	89 54 24 10          	mov    %edx,0x10(%esp)
  801685:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801689:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80168c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801690:	89 74 24 04          	mov    %esi,0x4(%esp)
  801694:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	e8 f8 fa ff ff       	call   801197 <sys_page_map>
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	79 37                	jns    8016da <fork+0x26c>
		           envid    , ( void * ) addr , 
			   perm ) < 0 ) 
		panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  8016a3:	c7 44 24 08 b4 21 80 	movl   $0x8021b4,0x8(%esp)
  8016aa:	00 
  8016ab:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8016b2:	00 
  8016b3:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  8016ba:	e8 e7 01 00 00       	call   8018a6 <_panic>
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
  8016bf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016c6:	00 
  8016c7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016ce:	ee 
  8016cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016d2:	89 04 24             	mov    %eax,(%esp)
  8016d5:	e8 69 fa ff ff       	call   801143 <sys_page_alloc>
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
  8016da:	83 c3 01             	add    $0x1,%ebx
  8016dd:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8016e3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8016e9:	0f 85 27 fe ff ff    	jne    801516 <fork+0xa8>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  8016ef:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  8016f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016f6:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  8016f9:	0f 85 f3 fd ff ff    	jne    8014f2 <fork+0x84>
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
		}						
	}
	sys_env_set_status( childid , ENV_RUNNABLE ) ;
  8016ff:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801706:	00 
  801707:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80170a:	89 3c 24             	mov    %edi,(%esp)
  80170d:	e8 2b fb ff ff       	call   80123d <sys_env_set_status>
	return childid ;
  801712:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801714:	83 c4 3c             	add    $0x3c,%esp
  801717:	5b                   	pop    %ebx
  801718:	5e                   	pop    %esi
  801719:	5f                   	pop    %edi
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <sfork>:

// Challenge!
int
sfork(void)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801722:	c7 44 24 08 f3 21 80 	movl   $0x8021f3,0x8(%esp)
  801729:	00 
  80172a:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801731:	00 
  801732:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  801739:	e8 68 01 00 00       	call   8018a6 <_panic>
  80173e:	66 90                	xchg   %ax,%ax

00801740 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	56                   	push   %esi
  801744:	53                   	push   %ebx
  801745:	83 ec 10             	sub    $0x10,%esp
  801748:	8b 75 08             	mov    0x8(%ebp),%esi
  80174b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int result = 0 ; 
	if ( pg ) result = sys_ipc_recv(pg);	
  801751:	85 c0                	test   %eax,%eax
  801753:	74 0a                	je     80175f <ipc_recv+0x1f>
  801755:	89 04 24             	mov    %eax,(%esp)
  801758:	e8 a9 fb ff ff       	call   801306 <sys_ipc_recv>
  80175d:	eb 0c                	jmp    80176b <ipc_recv+0x2b>
	     else result = sys_ipc_recv((void*)UTOP);
  80175f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801766:	e8 9b fb ff ff       	call   801306 <sys_ipc_recv>
	if ( result < 0 ) {
  80176b:	85 c0                	test   %eax,%eax
  80176d:	79 16                	jns    801785 <ipc_recv+0x45>
		if ( from_env_store ) 
  80176f:	85 f6                	test   %esi,%esi
  801771:	74 06                	je     801779 <ipc_recv+0x39>
			(*from_env_store) = 0 ;
  801773:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if ( perm_store)
  801779:	85 db                	test   %ebx,%ebx
  80177b:	74 2c                	je     8017a9 <ipc_recv+0x69>
			(*perm_store) = 0 ;	
  80177d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801783:	eb 24                	jmp    8017a9 <ipc_recv+0x69>
		return result; 
	}
	if ( from_env_store ) 
  801785:	85 f6                	test   %esi,%esi
  801787:	74 0a                	je     801793 <ipc_recv+0x53>
		(*from_env_store) = thisenv->env_ipc_from ;
  801789:	a1 04 30 80 00       	mov    0x803004,%eax
  80178e:	8b 40 74             	mov    0x74(%eax),%eax
  801791:	89 06                	mov    %eax,(%esi)
	if ( perm_store)
  801793:	85 db                	test   %ebx,%ebx
  801795:	74 0a                	je     8017a1 <ipc_recv+0x61>
		(*perm_store) = thisenv->env_ipc_perm ;	
  801797:	a1 04 30 80 00       	mov    0x803004,%eax
  80179c:	8b 40 78             	mov    0x78(%eax),%eax
  80179f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8017a1:	a1 04 30 80 00       	mov    0x803004,%eax
  8017a6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	57                   	push   %edi
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 1c             	sub    $0x1c,%esp
  8017b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017bf:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	
	
	int result = -E_IPC_NOT_RECV ; 
	if ( pg ) 
  8017c2:	85 db                	test   %ebx,%ebx
  8017c4:	74 19                	je     8017df <ipc_send+0x2f>
		result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  8017c6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8017ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	e8 06 fb ff ff       	call   8012e3 <sys_ipc_try_send>
  8017dd:	eb 1b                	jmp    8017fa <ipc_send+0x4a>
	else
		result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  8017df:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8017e3:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8017ea:	ee 
  8017eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f2:	89 04 24             	mov    %eax,(%esp)
  8017f5:	e8 e9 fa ff ff       	call   8012e3 <sys_ipc_try_send>
	
	if ( result == 0 ) return ; 
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	74 61                	je     80185f <ipc_send+0xaf>
	if ( result == -E_IPC_NOT_RECV ) {
  8017fe:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801801:	75 3c                	jne    80183f <ipc_send+0x8f>
		if ( pg ) 
  801803:	85 db                	test   %ebx,%ebx
  801805:	74 19                	je     801820 <ipc_send+0x70>
			result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  801807:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80180b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80180f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	89 04 24             	mov    %eax,(%esp)
  801819:	e8 c5 fa ff ff       	call   8012e3 <sys_ipc_try_send>
  80181e:	eb 1b                	jmp    80183b <ipc_send+0x8b>
		else
			result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  801820:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801824:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80182b:	ee 
  80182c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	89 04 24             	mov    %eax,(%esp)
  801836:	e8 a8 fa ff ff       	call   8012e3 <sys_ipc_try_send>
		if ( result == 0 ) return ; 
  80183b:	85 c0                	test   %eax,%eax
  80183d:	74 20                	je     80185f <ipc_send+0xaf>
	}
	panic("ipc_send error %e.",result);
  80183f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801843:	c7 44 24 08 09 22 80 	movl   $0x802209,0x8(%esp)
  80184a:	00 
  80184b:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801852:	00 
  801853:	c7 04 24 1c 22 80 00 	movl   $0x80221c,(%esp)
  80185a:	e8 47 00 00 00       	call   8018a6 <_panic>
}
  80185f:	83 c4 1c             	add    $0x1c,%esp
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5f                   	pop    %edi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80186d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801872:	89 c2                	mov    %eax,%edx
  801874:	c1 e2 07             	shl    $0x7,%edx
  801877:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80187e:	8b 52 50             	mov    0x50(%edx),%edx
  801881:	39 ca                	cmp    %ecx,%edx
  801883:	75 11                	jne    801896 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801885:	89 c2                	mov    %eax,%edx
  801887:	c1 e2 07             	shl    $0x7,%edx
  80188a:	8d 84 c2 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,8),%eax
  801891:	8b 40 40             	mov    0x40(%eax),%eax
  801894:	eb 0e                	jmp    8018a4 <ipc_find_env+0x3d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801896:	83 c0 01             	add    $0x1,%eax
  801899:	3d 00 04 00 00       	cmp    $0x400,%eax
  80189e:	75 d2                	jne    801872 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8018a0:	66 b8 00 00          	mov    $0x0,%ax
}
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	56                   	push   %esi
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8018ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8018b7:	e8 49 f8 ff ff       	call   801105 <sys_getenvid>
  8018bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018bf:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8018c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018ca:	89 74 24 08          	mov    %esi,0x8(%esp)
  8018ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d2:	c7 04 24 28 22 80 00 	movl   $0x802228,(%esp)
  8018d9:	e8 20 e9 ff ff       	call   8001fe <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8018de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e5:	89 04 24             	mov    %eax,(%esp)
  8018e8:	e8 b0 e8 ff ff       	call   80019d <vcprintf>
	cprintf("\n");
  8018ed:	c7 04 24 27 1c 80 00 	movl   $0x801c27,(%esp)
  8018f4:	e8 05 e9 ff ff       	call   8001fe <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018f9:	cc                   	int3   
  8018fa:	eb fd                	jmp    8018f9 <_panic+0x53>

008018fc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801902:	83 3d 08 30 80 00 00 	cmpl   $0x0,0x803008
  801909:	75 32                	jne    80193d <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  80190b:	e8 f5 f7 ff ff       	call   801105 <sys_getenvid>
  801910:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801917:	00 
  801918:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80191f:	ee 
  801920:	89 04 24             	mov    %eax,(%esp)
  801923:	e8 1b f8 ff ff       	call   801143 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  801928:	e8 d8 f7 ff ff       	call   801105 <sys_getenvid>
  80192d:	c7 44 24 04 47 19 80 	movl   $0x801947,0x4(%esp)
  801934:	00 
  801935:	89 04 24             	mov    %eax,(%esp)
  801938:	e8 53 f9 ff ff       	call   801290 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	a3 08 30 80 00       	mov    %eax,0x803008
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801947:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801948:	a1 08 30 80 00       	mov    0x803008,%eax
	call *%eax
  80194d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80194f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  801952:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  801955:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  801959:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  80195d:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  801960:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  801964:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  801966:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  801967:	83 c4 04             	add    $0x4,%esp
	popfl 	
  80196a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80196b:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80196c:	c3                   	ret    
  80196d:	66 90                	xchg   %ax,%ax
  80196f:	90                   	nop

00801970 <__udivdi3>:
  801970:	55                   	push   %ebp
  801971:	57                   	push   %edi
  801972:	56                   	push   %esi
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	8b 44 24 28          	mov    0x28(%esp),%eax
  80197a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80197e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801982:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801986:	85 c0                	test   %eax,%eax
  801988:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80198c:	89 ea                	mov    %ebp,%edx
  80198e:	89 0c 24             	mov    %ecx,(%esp)
  801991:	75 2d                	jne    8019c0 <__udivdi3+0x50>
  801993:	39 e9                	cmp    %ebp,%ecx
  801995:	77 61                	ja     8019f8 <__udivdi3+0x88>
  801997:	85 c9                	test   %ecx,%ecx
  801999:	89 ce                	mov    %ecx,%esi
  80199b:	75 0b                	jne    8019a8 <__udivdi3+0x38>
  80199d:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a2:	31 d2                	xor    %edx,%edx
  8019a4:	f7 f1                	div    %ecx
  8019a6:	89 c6                	mov    %eax,%esi
  8019a8:	31 d2                	xor    %edx,%edx
  8019aa:	89 e8                	mov    %ebp,%eax
  8019ac:	f7 f6                	div    %esi
  8019ae:	89 c5                	mov    %eax,%ebp
  8019b0:	89 f8                	mov    %edi,%eax
  8019b2:	f7 f6                	div    %esi
  8019b4:	89 ea                	mov    %ebp,%edx
  8019b6:	83 c4 0c             	add    $0xc,%esp
  8019b9:	5e                   	pop    %esi
  8019ba:	5f                   	pop    %edi
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    
  8019bd:	8d 76 00             	lea    0x0(%esi),%esi
  8019c0:	39 e8                	cmp    %ebp,%eax
  8019c2:	77 24                	ja     8019e8 <__udivdi3+0x78>
  8019c4:	0f bd e8             	bsr    %eax,%ebp
  8019c7:	83 f5 1f             	xor    $0x1f,%ebp
  8019ca:	75 3c                	jne    801a08 <__udivdi3+0x98>
  8019cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8019d0:	39 34 24             	cmp    %esi,(%esp)
  8019d3:	0f 86 9f 00 00 00    	jbe    801a78 <__udivdi3+0x108>
  8019d9:	39 d0                	cmp    %edx,%eax
  8019db:	0f 82 97 00 00 00    	jb     801a78 <__udivdi3+0x108>
  8019e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8019e8:	31 d2                	xor    %edx,%edx
  8019ea:	31 c0                	xor    %eax,%eax
  8019ec:	83 c4 0c             	add    $0xc,%esp
  8019ef:	5e                   	pop    %esi
  8019f0:	5f                   	pop    %edi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    
  8019f3:	90                   	nop
  8019f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019f8:	89 f8                	mov    %edi,%eax
  8019fa:	f7 f1                	div    %ecx
  8019fc:	31 d2                	xor    %edx,%edx
  8019fe:	83 c4 0c             	add    $0xc,%esp
  801a01:	5e                   	pop    %esi
  801a02:	5f                   	pop    %edi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    
  801a05:	8d 76 00             	lea    0x0(%esi),%esi
  801a08:	89 e9                	mov    %ebp,%ecx
  801a0a:	8b 3c 24             	mov    (%esp),%edi
  801a0d:	d3 e0                	shl    %cl,%eax
  801a0f:	89 c6                	mov    %eax,%esi
  801a11:	b8 20 00 00 00       	mov    $0x20,%eax
  801a16:	29 e8                	sub    %ebp,%eax
  801a18:	89 c1                	mov    %eax,%ecx
  801a1a:	d3 ef                	shr    %cl,%edi
  801a1c:	89 e9                	mov    %ebp,%ecx
  801a1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a22:	8b 3c 24             	mov    (%esp),%edi
  801a25:	09 74 24 08          	or     %esi,0x8(%esp)
  801a29:	89 d6                	mov    %edx,%esi
  801a2b:	d3 e7                	shl    %cl,%edi
  801a2d:	89 c1                	mov    %eax,%ecx
  801a2f:	89 3c 24             	mov    %edi,(%esp)
  801a32:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a36:	d3 ee                	shr    %cl,%esi
  801a38:	89 e9                	mov    %ebp,%ecx
  801a3a:	d3 e2                	shl    %cl,%edx
  801a3c:	89 c1                	mov    %eax,%ecx
  801a3e:	d3 ef                	shr    %cl,%edi
  801a40:	09 d7                	or     %edx,%edi
  801a42:	89 f2                	mov    %esi,%edx
  801a44:	89 f8                	mov    %edi,%eax
  801a46:	f7 74 24 08          	divl   0x8(%esp)
  801a4a:	89 d6                	mov    %edx,%esi
  801a4c:	89 c7                	mov    %eax,%edi
  801a4e:	f7 24 24             	mull   (%esp)
  801a51:	39 d6                	cmp    %edx,%esi
  801a53:	89 14 24             	mov    %edx,(%esp)
  801a56:	72 30                	jb     801a88 <__udivdi3+0x118>
  801a58:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a5c:	89 e9                	mov    %ebp,%ecx
  801a5e:	d3 e2                	shl    %cl,%edx
  801a60:	39 c2                	cmp    %eax,%edx
  801a62:	73 05                	jae    801a69 <__udivdi3+0xf9>
  801a64:	3b 34 24             	cmp    (%esp),%esi
  801a67:	74 1f                	je     801a88 <__udivdi3+0x118>
  801a69:	89 f8                	mov    %edi,%eax
  801a6b:	31 d2                	xor    %edx,%edx
  801a6d:	e9 7a ff ff ff       	jmp    8019ec <__udivdi3+0x7c>
  801a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a78:	31 d2                	xor    %edx,%edx
  801a7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7f:	e9 68 ff ff ff       	jmp    8019ec <__udivdi3+0x7c>
  801a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a88:	8d 47 ff             	lea    -0x1(%edi),%eax
  801a8b:	31 d2                	xor    %edx,%edx
  801a8d:	83 c4 0c             	add    $0xc,%esp
  801a90:	5e                   	pop    %esi
  801a91:	5f                   	pop    %edi
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    
  801a94:	66 90                	xchg   %ax,%ax
  801a96:	66 90                	xchg   %ax,%ax
  801a98:	66 90                	xchg   %ax,%ax
  801a9a:	66 90                	xchg   %ax,%ax
  801a9c:	66 90                	xchg   %ax,%ax
  801a9e:	66 90                	xchg   %ax,%ax

00801aa0 <__umoddi3>:
  801aa0:	55                   	push   %ebp
  801aa1:	57                   	push   %edi
  801aa2:	56                   	push   %esi
  801aa3:	83 ec 14             	sub    $0x14,%esp
  801aa6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801aaa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801aae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801ab2:	89 c7                	mov    %eax,%edi
  801ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801abc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ac0:	89 34 24             	mov    %esi,(%esp)
  801ac3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	89 c2                	mov    %eax,%edx
  801acb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801acf:	75 17                	jne    801ae8 <__umoddi3+0x48>
  801ad1:	39 fe                	cmp    %edi,%esi
  801ad3:	76 4b                	jbe    801b20 <__umoddi3+0x80>
  801ad5:	89 c8                	mov    %ecx,%eax
  801ad7:	89 fa                	mov    %edi,%edx
  801ad9:	f7 f6                	div    %esi
  801adb:	89 d0                	mov    %edx,%eax
  801add:	31 d2                	xor    %edx,%edx
  801adf:	83 c4 14             	add    $0x14,%esp
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    
  801ae6:	66 90                	xchg   %ax,%ax
  801ae8:	39 f8                	cmp    %edi,%eax
  801aea:	77 54                	ja     801b40 <__umoddi3+0xa0>
  801aec:	0f bd e8             	bsr    %eax,%ebp
  801aef:	83 f5 1f             	xor    $0x1f,%ebp
  801af2:	75 5c                	jne    801b50 <__umoddi3+0xb0>
  801af4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801af8:	39 3c 24             	cmp    %edi,(%esp)
  801afb:	0f 87 e7 00 00 00    	ja     801be8 <__umoddi3+0x148>
  801b01:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b05:	29 f1                	sub    %esi,%ecx
  801b07:	19 c7                	sbb    %eax,%edi
  801b09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b0d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b11:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b15:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b19:	83 c4 14             	add    $0x14,%esp
  801b1c:	5e                   	pop    %esi
  801b1d:	5f                   	pop    %edi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    
  801b20:	85 f6                	test   %esi,%esi
  801b22:	89 f5                	mov    %esi,%ebp
  801b24:	75 0b                	jne    801b31 <__umoddi3+0x91>
  801b26:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2b:	31 d2                	xor    %edx,%edx
  801b2d:	f7 f6                	div    %esi
  801b2f:	89 c5                	mov    %eax,%ebp
  801b31:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b35:	31 d2                	xor    %edx,%edx
  801b37:	f7 f5                	div    %ebp
  801b39:	89 c8                	mov    %ecx,%eax
  801b3b:	f7 f5                	div    %ebp
  801b3d:	eb 9c                	jmp    801adb <__umoddi3+0x3b>
  801b3f:	90                   	nop
  801b40:	89 c8                	mov    %ecx,%eax
  801b42:	89 fa                	mov    %edi,%edx
  801b44:	83 c4 14             	add    $0x14,%esp
  801b47:	5e                   	pop    %esi
  801b48:	5f                   	pop    %edi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    
  801b4b:	90                   	nop
  801b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b50:	8b 04 24             	mov    (%esp),%eax
  801b53:	be 20 00 00 00       	mov    $0x20,%esi
  801b58:	89 e9                	mov    %ebp,%ecx
  801b5a:	29 ee                	sub    %ebp,%esi
  801b5c:	d3 e2                	shl    %cl,%edx
  801b5e:	89 f1                	mov    %esi,%ecx
  801b60:	d3 e8                	shr    %cl,%eax
  801b62:	89 e9                	mov    %ebp,%ecx
  801b64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b68:	8b 04 24             	mov    (%esp),%eax
  801b6b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b6f:	89 fa                	mov    %edi,%edx
  801b71:	d3 e0                	shl    %cl,%eax
  801b73:	89 f1                	mov    %esi,%ecx
  801b75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b79:	8b 44 24 10          	mov    0x10(%esp),%eax
  801b7d:	d3 ea                	shr    %cl,%edx
  801b7f:	89 e9                	mov    %ebp,%ecx
  801b81:	d3 e7                	shl    %cl,%edi
  801b83:	89 f1                	mov    %esi,%ecx
  801b85:	d3 e8                	shr    %cl,%eax
  801b87:	89 e9                	mov    %ebp,%ecx
  801b89:	09 f8                	or     %edi,%eax
  801b8b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801b8f:	f7 74 24 04          	divl   0x4(%esp)
  801b93:	d3 e7                	shl    %cl,%edi
  801b95:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b99:	89 d7                	mov    %edx,%edi
  801b9b:	f7 64 24 08          	mull   0x8(%esp)
  801b9f:	39 d7                	cmp    %edx,%edi
  801ba1:	89 c1                	mov    %eax,%ecx
  801ba3:	89 14 24             	mov    %edx,(%esp)
  801ba6:	72 2c                	jb     801bd4 <__umoddi3+0x134>
  801ba8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801bac:	72 22                	jb     801bd0 <__umoddi3+0x130>
  801bae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bb2:	29 c8                	sub    %ecx,%eax
  801bb4:	19 d7                	sbb    %edx,%edi
  801bb6:	89 e9                	mov    %ebp,%ecx
  801bb8:	89 fa                	mov    %edi,%edx
  801bba:	d3 e8                	shr    %cl,%eax
  801bbc:	89 f1                	mov    %esi,%ecx
  801bbe:	d3 e2                	shl    %cl,%edx
  801bc0:	89 e9                	mov    %ebp,%ecx
  801bc2:	d3 ef                	shr    %cl,%edi
  801bc4:	09 d0                	or     %edx,%eax
  801bc6:	89 fa                	mov    %edi,%edx
  801bc8:	83 c4 14             	add    $0x14,%esp
  801bcb:	5e                   	pop    %esi
  801bcc:	5f                   	pop    %edi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    
  801bcf:	90                   	nop
  801bd0:	39 d7                	cmp    %edx,%edi
  801bd2:	75 da                	jne    801bae <__umoddi3+0x10e>
  801bd4:	8b 14 24             	mov    (%esp),%edx
  801bd7:	89 c1                	mov    %eax,%ecx
  801bd9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801bdd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801be1:	eb cb                	jmp    801bae <__umoddi3+0x10e>
  801be3:	90                   	nop
  801be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801bec:	0f 82 0f ff ff ff    	jb     801b01 <__umoddi3+0x61>
  801bf2:	e9 1a ff ff ff       	jmp    801b11 <__umoddi3+0x71>
