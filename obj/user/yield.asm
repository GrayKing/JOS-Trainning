
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6d 00 00 00       	call   80009e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 e0 15 80 00 	movl   $0x8015e0,(%esp)
  80004d:	e8 4f 01 00 00       	call   8001a1 <cprintf>
	for (i = 0; i < 5; i++) {
  800052:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800057:	e8 68 10 00 00       	call   8010c4 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005c:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800061:	8b 40 48             	mov    0x48(%eax),%eax
  800064:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	c7 04 24 00 16 80 00 	movl   $0x801600,(%esp)
  800073:	e8 29 01 00 00       	call   8001a1 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800078:	83 c3 01             	add    $0x1,%ebx
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d7                	jne    800057 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	c7 04 24 2c 16 80 00 	movl   $0x80162c,(%esp)
  800093:	e8 09 01 00 00       	call   8001a1 <cprintf>
}
  800098:	83 c4 14             	add    $0x14,%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 10             	sub    $0x10,%esp
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  8000ac:	e8 f4 0f 00 00       	call   8010a5 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	89 c2                	mov    %eax,%edx
  8000b8:	c1 e2 07             	shl    $0x7,%edx
  8000bb:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000c2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c7:	85 db                	test   %ebx,%ebx
  8000c9:	7e 07                	jle    8000d2 <libmain+0x34>
		binaryname = argv[0];
  8000cb:	8b 06                	mov    (%esi),%eax
  8000cd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d6:	89 1c 24             	mov    %ebx,(%esp)
  8000d9:	e8 55 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000de:	e8 07 00 00 00       	call   8000ea <exit>
}
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f7:	e8 57 0f 00 00       	call   801053 <sys_env_destroy>
}
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    

008000fe <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	53                   	push   %ebx
  800102:	83 ec 14             	sub    $0x14,%esp
  800105:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800108:	8b 13                	mov    (%ebx),%edx
  80010a:	8d 42 01             	lea    0x1(%edx),%eax
  80010d:	89 03                	mov    %eax,(%ebx)
  80010f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800112:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800116:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011b:	75 19                	jne    800136 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80011d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800124:	00 
  800125:	8d 43 08             	lea    0x8(%ebx),%eax
  800128:	89 04 24             	mov    %eax,(%esp)
  80012b:	e8 e6 0e 00 00       	call   801016 <sys_cputs>
		b->idx = 0;
  800130:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800136:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013a:	83 c4 14             	add    $0x14,%esp
  80013d:	5b                   	pop    %ebx
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800149:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800150:	00 00 00 
	b.cnt = 0;
  800153:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800160:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800164:	8b 45 08             	mov    0x8(%ebp),%eax
  800167:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800171:	89 44 24 04          	mov    %eax,0x4(%esp)
  800175:	c7 04 24 fe 00 80 00 	movl   $0x8000fe,(%esp)
  80017c:	e8 ae 02 00 00       	call   80042f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800181:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800191:	89 04 24             	mov    %eax,(%esp)
  800194:	e8 7d 0e 00 00       	call   801016 <sys_cputs>

	return b.cnt;
}
  800199:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 87 ff ff ff       	call   800140 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    
  8001bb:	66 90                	xchg   %ax,%ax
  8001bd:	66 90                	xchg   %ax,%ax
  8001bf:	90                   	nop

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 3c             	sub    $0x3c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	89 c3                	mov    %eax,%ebx
  8001d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ed:	39 d9                	cmp    %ebx,%ecx
  8001ef:	72 05                	jb     8001f6 <printnum+0x36>
  8001f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001f4:	77 69                	ja     80025f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001fd:	83 ee 01             	sub    $0x1,%esi
  800200:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800204:	89 44 24 08          	mov    %eax,0x8(%esp)
  800208:	8b 44 24 08          	mov    0x8(%esp),%eax
  80020c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800210:	89 c3                	mov    %eax,%ebx
  800212:	89 d6                	mov    %edx,%esi
  800214:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800217:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80021a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80021e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800222:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	e8 1c 11 00 00       	call   801350 <__udivdi3>
  800234:	89 d9                	mov    %ebx,%ecx
  800236:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80023a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	89 54 24 04          	mov    %edx,0x4(%esp)
  800245:	89 fa                	mov    %edi,%edx
  800247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024a:	e8 71 ff ff ff       	call   8001c0 <printnum>
  80024f:	eb 1b                	jmp    80026c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800251:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800255:	8b 45 18             	mov    0x18(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	ff d3                	call   *%ebx
  80025d:	eb 03                	jmp    800262 <printnum+0xa2>
  80025f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800262:	83 ee 01             	sub    $0x1,%esi
  800265:	85 f6                	test   %esi,%esi
  800267:	7f e8                	jg     800251 <printnum+0x91>
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800270:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800274:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800277:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80027a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	e8 ec 11 00 00       	call   801480 <__umoddi3>
  800294:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800298:	0f be 80 55 16 80 00 	movsbl 0x801655(%eax),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a5:	ff d0                	call   *%eax
}
  8002a7:	83 c4 3c             	add    $0x3c,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 3c             	sub    $0x3c,%esp
  8002b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002bb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002be:	89 cf                	mov    %ecx,%edi
  8002c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c9:	89 c3                	mov    %eax,%ebx
  8002cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8002ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002dc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002df:	39 d9                	cmp    %ebx,%ecx
  8002e1:	72 13                	jb     8002f6 <cprintnum+0x47>
  8002e3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002e6:	76 0e                	jbe    8002f6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8002e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002eb:	0b 45 18             	or     0x18(%ebp),%eax
  8002ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8002f4:	eb 6a                	jmp    800360 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8002f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002fd:	83 ee 01             	sub    $0x1,%esi
  800300:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 44 24 08          	mov    0x8(%esp),%eax
  80030c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800310:	89 c3                	mov    %eax,%ebx
  800312:	89 d6                	mov    %edx,%esi
  800314:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800317:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80031a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80031e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800322:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 1c 10 00 00       	call   801350 <__udivdi3>
  800334:	89 d9                	mov    %ebx,%ecx
  800336:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033e:	89 04 24             	mov    %eax,(%esp)
  800341:	89 54 24 04          	mov    %edx,0x4(%esp)
  800345:	89 f9                	mov    %edi,%ecx
  800347:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80034a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034d:	e8 5d ff ff ff       	call   8002af <cprintnum>
  800352:	eb 16                	jmp    80036a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035b:	89 04 24             	mov    %eax,(%esp)
  80035e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800360:	83 ee 01             	sub    $0x1,%esi
  800363:	85 f6                	test   %esi,%esi
  800365:	7f ed                	jg     800354 <cprintnum+0xa5>
  800367:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80036a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800372:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800375:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800378:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800380:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800383:	89 04 24             	mov    %eax,(%esp)
  800386:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038d:	e8 ee 10 00 00       	call   801480 <__umoddi3>
  800392:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800396:	0f be 80 55 16 80 00 	movsbl 0x801655(%eax),%eax
  80039d:	0b 45 dc             	or     -0x24(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a6:	ff d0                	call   *%eax
}
  8003a8:	83 c4 3c             	add    $0x3c,%esp
  8003ab:	5b                   	pop    %ebx
  8003ac:	5e                   	pop    %esi
  8003ad:	5f                   	pop    %edi
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    

008003b0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b3:	83 fa 01             	cmp    $0x1,%edx
  8003b6:	7e 0e                	jle    8003c6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 02                	mov    (%edx),%eax
  8003c1:	8b 52 04             	mov    0x4(%edx),%edx
  8003c4:	eb 22                	jmp    8003e8 <getuint+0x38>
	else if (lflag)
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	74 10                	je     8003da <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ca:	8b 10                	mov    (%eax),%edx
  8003cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 02                	mov    (%edx),%eax
  8003d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d8:	eb 0e                	jmp    8003e8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f9:	73 0a                	jae    800405 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fe:	89 08                	mov    %ecx,(%eax)
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
  800403:	88 02                	mov    %al,(%edx)
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80040d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800410:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800414:	8b 45 10             	mov    0x10(%ebp),%eax
  800417:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	89 04 24             	mov    %eax,(%esp)
  800428:	e8 02 00 00 00       	call   80042f <vprintfmt>
	va_end(ap);
}
  80042d:	c9                   	leave  
  80042e:	c3                   	ret    

0080042f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	57                   	push   %edi
  800433:	56                   	push   %esi
  800434:	53                   	push   %ebx
  800435:	83 ec 3c             	sub    $0x3c,%esp
  800438:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80043b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80043e:	eb 14                	jmp    800454 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800440:	85 c0                	test   %eax,%eax
  800442:	0f 84 b3 03 00 00    	je     8007fb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800448:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044c:	89 04 24             	mov    %eax,(%esp)
  80044f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800452:	89 f3                	mov    %esi,%ebx
  800454:	8d 73 01             	lea    0x1(%ebx),%esi
  800457:	0f b6 03             	movzbl (%ebx),%eax
  80045a:	83 f8 25             	cmp    $0x25,%eax
  80045d:	75 e1                	jne    800440 <vprintfmt+0x11>
  80045f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800463:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80046a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800471:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800478:	ba 00 00 00 00       	mov    $0x0,%edx
  80047d:	eb 1d                	jmp    80049c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800481:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800485:	eb 15                	jmp    80049c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800489:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80048d:	eb 0d                	jmp    80049c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80048f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800492:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800495:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80049f:	0f b6 0e             	movzbl (%esi),%ecx
  8004a2:	0f b6 c1             	movzbl %cl,%eax
  8004a5:	83 e9 23             	sub    $0x23,%ecx
  8004a8:	80 f9 55             	cmp    $0x55,%cl
  8004ab:	0f 87 2a 03 00 00    	ja     8007db <vprintfmt+0x3ac>
  8004b1:	0f b6 c9             	movzbl %cl,%ecx
  8004b4:	ff 24 8d 20 17 80 00 	jmp    *0x801720(,%ecx,4)
  8004bb:	89 de                	mov    %ebx,%esi
  8004bd:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004c5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004c9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004cc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004cf:	83 fb 09             	cmp    $0x9,%ebx
  8004d2:	77 36                	ja     80050a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d7:	eb e9                	jmp    8004c2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e2:	8b 00                	mov    (%eax),%eax
  8004e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e9:	eb 22                	jmp    80050d <vprintfmt+0xde>
  8004eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ee:	85 c9                	test   %ecx,%ecx
  8004f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f5:	0f 49 c1             	cmovns %ecx,%eax
  8004f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	89 de                	mov    %ebx,%esi
  8004fd:	eb 9d                	jmp    80049c <vprintfmt+0x6d>
  8004ff:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800501:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800508:	eb 92                	jmp    80049c <vprintfmt+0x6d>
  80050a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80050d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800511:	79 89                	jns    80049c <vprintfmt+0x6d>
  800513:	e9 77 ff ff ff       	jmp    80048f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800518:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80051d:	e9 7a ff ff ff       	jmp    80049c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	89 04 24             	mov    %eax,(%esp)
  800534:	ff 55 08             	call   *0x8(%ebp)
			break;
  800537:	e9 18 ff ff ff       	jmp    800454 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 50 04             	lea    0x4(%eax),%edx
  800542:	89 55 14             	mov    %edx,0x14(%ebp)
  800545:	8b 00                	mov    (%eax),%eax
  800547:	99                   	cltd   
  800548:	31 d0                	xor    %edx,%eax
  80054a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054c:	83 f8 09             	cmp    $0x9,%eax
  80054f:	7f 0b                	jg     80055c <vprintfmt+0x12d>
  800551:	8b 14 85 e0 19 80 00 	mov    0x8019e0(,%eax,4),%edx
  800558:	85 d2                	test   %edx,%edx
  80055a:	75 20                	jne    80057c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80055c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800560:	c7 44 24 08 6d 16 80 	movl   $0x80166d,0x8(%esp)
  800567:	00 
  800568:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056c:	8b 45 08             	mov    0x8(%ebp),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	e8 90 fe ff ff       	call   800407 <printfmt>
  800577:	e9 d8 fe ff ff       	jmp    800454 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80057c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800580:	c7 44 24 08 76 16 80 	movl   $0x801676,0x8(%esp)
  800587:	00 
  800588:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058c:	8b 45 08             	mov    0x8(%ebp),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	e8 70 fe ff ff       	call   800407 <printfmt>
  800597:	e9 b8 fe ff ff       	jmp    800454 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80059f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005b0:	85 f6                	test   %esi,%esi
  8005b2:	b8 66 16 80 00       	mov    $0x801666,%eax
  8005b7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005ba:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005be:	0f 84 97 00 00 00    	je     80065b <vprintfmt+0x22c>
  8005c4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005c8:	0f 8e 9b 00 00 00    	jle    800669 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d2:	89 34 24             	mov    %esi,(%esp)
  8005d5:	e8 ce 06 00 00       	call   800ca8 <strnlen>
  8005da:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005dd:	29 c2                	sub    %eax,%edx
  8005df:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005e2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005e9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ef:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005f2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f4:	eb 0f                	jmp    800605 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005fd:	89 04 24             	mov    %eax,(%esp)
  800600:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800602:	83 eb 01             	sub    $0x1,%ebx
  800605:	85 db                	test   %ebx,%ebx
  800607:	7f ed                	jg     8005f6 <vprintfmt+0x1c7>
  800609:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80060f:	85 d2                	test   %edx,%edx
  800611:	b8 00 00 00 00       	mov    $0x0,%eax
  800616:	0f 49 c2             	cmovns %edx,%eax
  800619:	29 c2                	sub    %eax,%edx
  80061b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80061e:	89 d7                	mov    %edx,%edi
  800620:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800623:	eb 50                	jmp    800675 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800625:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800629:	74 1e                	je     800649 <vprintfmt+0x21a>
  80062b:	0f be d2             	movsbl %dl,%edx
  80062e:	83 ea 20             	sub    $0x20,%edx
  800631:	83 fa 5e             	cmp    $0x5e,%edx
  800634:	76 13                	jbe    800649 <vprintfmt+0x21a>
					putch('?', putdat);
  800636:	8b 45 0c             	mov    0xc(%ebp),%eax
  800639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800644:	ff 55 08             	call   *0x8(%ebp)
  800647:	eb 0d                	jmp    800656 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800649:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800656:	83 ef 01             	sub    $0x1,%edi
  800659:	eb 1a                	jmp    800675 <vprintfmt+0x246>
  80065b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80065e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800661:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800664:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800667:	eb 0c                	jmp    800675 <vprintfmt+0x246>
  800669:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80066c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80066f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800672:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800675:	83 c6 01             	add    $0x1,%esi
  800678:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80067c:	0f be c2             	movsbl %dl,%eax
  80067f:	85 c0                	test   %eax,%eax
  800681:	74 27                	je     8006aa <vprintfmt+0x27b>
  800683:	85 db                	test   %ebx,%ebx
  800685:	78 9e                	js     800625 <vprintfmt+0x1f6>
  800687:	83 eb 01             	sub    $0x1,%ebx
  80068a:	79 99                	jns    800625 <vprintfmt+0x1f6>
  80068c:	89 f8                	mov    %edi,%eax
  80068e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800691:	8b 75 08             	mov    0x8(%ebp),%esi
  800694:	89 c3                	mov    %eax,%ebx
  800696:	eb 1a                	jmp    8006b2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800698:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a5:	83 eb 01             	sub    $0x1,%ebx
  8006a8:	eb 08                	jmp    8006b2 <vprintfmt+0x283>
  8006aa:	89 fb                	mov    %edi,%ebx
  8006ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8006af:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006b2:	85 db                	test   %ebx,%ebx
  8006b4:	7f e2                	jg     800698 <vprintfmt+0x269>
  8006b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006bc:	e9 93 fd ff ff       	jmp    800454 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c1:	83 fa 01             	cmp    $0x1,%edx
  8006c4:	7e 16                	jle    8006dc <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 08             	lea    0x8(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 50 04             	mov    0x4(%eax),%edx
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006da:	eb 32                	jmp    80070e <vprintfmt+0x2df>
	else if (lflag)
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	74 18                	je     8006f8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 04             	lea    0x4(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 30                	mov    (%eax),%esi
  8006eb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006ee:	89 f0                	mov    %esi,%eax
  8006f0:	c1 f8 1f             	sar    $0x1f,%eax
  8006f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f6:	eb 16                	jmp    80070e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 30                	mov    (%eax),%esi
  800703:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800706:	89 f0                	mov    %esi,%eax
  800708:	c1 f8 1f             	sar    $0x1f,%eax
  80070b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800711:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800714:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800719:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80071d:	0f 89 80 00 00 00    	jns    8007a3 <vprintfmt+0x374>
				putch('-', putdat);
  800723:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800727:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800731:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800734:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800737:	f7 d8                	neg    %eax
  800739:	83 d2 00             	adc    $0x0,%edx
  80073c:	f7 da                	neg    %edx
			}
			base = 10;
  80073e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800743:	eb 5e                	jmp    8007a3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800745:	8d 45 14             	lea    0x14(%ebp),%eax
  800748:	e8 63 fc ff ff       	call   8003b0 <getuint>
			base = 10;
  80074d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800752:	eb 4f                	jmp    8007a3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800754:	8d 45 14             	lea    0x14(%ebp),%eax
  800757:	e8 54 fc ff ff       	call   8003b0 <getuint>
			base = 8 ;
  80075c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800761:	eb 40                	jmp    8007a3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800763:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800767:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80076e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800771:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800775:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80077c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800794:	eb 0d                	jmp    8007a3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
  800799:	e8 12 fc ff ff       	call   8003b0 <getuint>
			base = 16;
  80079e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007a7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007ab:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007b6:	89 04 24             	mov    %eax,(%esp)
  8007b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007bd:	89 fa                	mov    %edi,%edx
  8007bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c2:	e8 f9 f9 ff ff       	call   8001c0 <printnum>
			break;
  8007c7:	e9 88 fc ff ff       	jmp    800454 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d0:	89 04 24             	mov    %eax,(%esp)
  8007d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007d6:	e9 79 fc ff ff       	jmp    800454 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e9:	89 f3                	mov    %esi,%ebx
  8007eb:	eb 03                	jmp    8007f0 <vprintfmt+0x3c1>
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007f4:	75 f7                	jne    8007ed <vprintfmt+0x3be>
  8007f6:	e9 59 fc ff ff       	jmp    800454 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007fb:	83 c4 3c             	add    $0x3c,%esp
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5f                   	pop    %edi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	57                   	push   %edi
  800807:	56                   	push   %esi
  800808:	53                   	push   %ebx
  800809:	83 ec 3c             	sub    $0x3c,%esp
  80080c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8d 50 04             	lea    0x4(%eax),%edx
  800815:	89 55 14             	mov    %edx,0x14(%ebp)
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	c1 e0 08             	shl    $0x8,%eax
  80081d:	0f b7 c0             	movzwl %ax,%eax
  800820:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800823:	83 c8 25             	or     $0x25,%eax
  800826:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800829:	eb 1a                	jmp    800845 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80082b:	85 c0                	test   %eax,%eax
  80082d:	0f 84 a9 03 00 00    	je     800bdc <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800833:	8b 75 0c             	mov    0xc(%ebp),%esi
  800836:	89 74 24 04          	mov    %esi,0x4(%esp)
  80083a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80083d:	89 04 24             	mov    %eax,(%esp)
  800840:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800843:	89 fb                	mov    %edi,%ebx
  800845:	8d 7b 01             	lea    0x1(%ebx),%edi
  800848:	0f b6 03             	movzbl (%ebx),%eax
  80084b:	83 f8 25             	cmp    $0x25,%eax
  80084e:	75 db                	jne    80082b <cvprintfmt+0x28>
  800850:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800854:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80085b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800860:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800867:	ba 00 00 00 00       	mov    $0x0,%edx
  80086c:	eb 18                	jmp    800886 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800870:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800874:	eb 10                	jmp    800886 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800876:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800878:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80087c:	eb 08                	jmp    800886 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80087e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800881:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800886:	8d 5f 01             	lea    0x1(%edi),%ebx
  800889:	0f b6 0f             	movzbl (%edi),%ecx
  80088c:	0f b6 c1             	movzbl %cl,%eax
  80088f:	83 e9 23             	sub    $0x23,%ecx
  800892:	80 f9 55             	cmp    $0x55,%cl
  800895:	0f 87 1f 03 00 00    	ja     800bba <cvprintfmt+0x3b7>
  80089b:	0f b6 c9             	movzbl %cl,%ecx
  80089e:	ff 24 8d 78 18 80 00 	jmp    *0x801878(,%ecx,4)
  8008a5:	89 df                	mov    %ebx,%edi
  8008a7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008ac:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  8008af:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  8008b3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8008b6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008b9:	83 f9 09             	cmp    $0x9,%ecx
  8008bc:	77 33                	ja     8008f1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008be:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008c1:	eb e9                	jmp    8008ac <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	8d 48 04             	lea    0x4(%eax),%ecx
  8008c9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008cc:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ce:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008d0:	eb 1f                	jmp    8008f1 <cvprintfmt+0xee>
  8008d2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8008d5:	85 ff                	test   %edi,%edi
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dc:	0f 49 c7             	cmovns %edi,%eax
  8008df:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e2:	89 df                	mov    %ebx,%edi
  8008e4:	eb a0                	jmp    800886 <cvprintfmt+0x83>
  8008e6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008e8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8008ef:	eb 95                	jmp    800886 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  8008f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008f5:	79 8f                	jns    800886 <cvprintfmt+0x83>
  8008f7:	eb 85                	jmp    80087e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fc:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008fe:	66 90                	xchg   %ax,%ax
  800900:	eb 84                	jmp    800886 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8d 50 04             	lea    0x4(%eax),%edx
  800908:	89 55 14             	mov    %edx,0x14(%ebp)
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800912:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800915:	0b 10                	or     (%eax),%edx
  800917:	89 14 24             	mov    %edx,(%esp)
  80091a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80091d:	e9 23 ff ff ff       	jmp    800845 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8d 50 04             	lea    0x4(%eax),%edx
  800928:	89 55 14             	mov    %edx,0x14(%ebp)
  80092b:	8b 00                	mov    (%eax),%eax
  80092d:	99                   	cltd   
  80092e:	31 d0                	xor    %edx,%eax
  800930:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800932:	83 f8 09             	cmp    $0x9,%eax
  800935:	7f 0b                	jg     800942 <cvprintfmt+0x13f>
  800937:	8b 14 85 e0 19 80 00 	mov    0x8019e0(,%eax,4),%edx
  80093e:	85 d2                	test   %edx,%edx
  800940:	75 23                	jne    800965 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800942:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800946:	c7 44 24 08 6d 16 80 	movl   $0x80166d,0x8(%esp)
  80094d:	00 
  80094e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800951:	89 44 24 04          	mov    %eax,0x4(%esp)
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	89 04 24             	mov    %eax,(%esp)
  80095b:	e8 a7 fa ff ff       	call   800407 <printfmt>
  800960:	e9 e0 fe ff ff       	jmp    800845 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800965:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800969:	c7 44 24 08 76 16 80 	movl   $0x801676,0x8(%esp)
  800970:	00 
  800971:	8b 45 0c             	mov    0xc(%ebp),%eax
  800974:	89 44 24 04          	mov    %eax,0x4(%esp)
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	89 04 24             	mov    %eax,(%esp)
  80097e:	e8 84 fa ff ff       	call   800407 <printfmt>
  800983:	e9 bd fe ff ff       	jmp    800845 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800988:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80098b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  80098e:	8b 45 14             	mov    0x14(%ebp),%eax
  800991:	8d 48 04             	lea    0x4(%eax),%ecx
  800994:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800997:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800999:	85 ff                	test   %edi,%edi
  80099b:	b8 66 16 80 00       	mov    $0x801666,%eax
  8009a0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009a3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009a7:	74 61                	je     800a0a <cvprintfmt+0x207>
  8009a9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8009ad:	7e 5b                	jle    800a0a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b3:	89 3c 24             	mov    %edi,(%esp)
  8009b6:	e8 ed 02 00 00       	call   800ca8 <strnlen>
  8009bb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009be:	29 c2                	sub    %eax,%edx
  8009c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  8009c3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009c7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8009ca:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8009cd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009d6:	89 d3                	mov    %edx,%ebx
  8009d8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009da:	eb 0f                	jmp    8009eb <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  8009dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e3:	89 3c 24             	mov    %edi,(%esp)
  8009e6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e8:	83 eb 01             	sub    $0x1,%ebx
  8009eb:	85 db                	test   %ebx,%ebx
  8009ed:	7f ed                	jg     8009dc <cvprintfmt+0x1d9>
  8009ef:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8009f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009fb:	85 d2                	test   %edx,%edx
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800a02:	0f 49 c2             	cmovns %edx,%eax
  800a05:	29 c2                	sub    %eax,%edx
  800a07:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800a0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a0d:	83 c8 3f             	or     $0x3f,%eax
  800a10:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a13:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a16:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800a19:	eb 36                	jmp    800a51 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a1b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a1f:	74 1d                	je     800a3e <cvprintfmt+0x23b>
  800a21:	0f be d2             	movsbl %dl,%edx
  800a24:	83 ea 20             	sub    $0x20,%edx
  800a27:	83 fa 5e             	cmp    $0x5e,%edx
  800a2a:	76 12                	jbe    800a3e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a33:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a36:	89 04 24             	mov    %eax,(%esp)
  800a39:	ff 55 08             	call   *0x8(%ebp)
  800a3c:	eb 10                	jmp    800a4e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a41:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a45:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a48:	89 04 24             	mov    %eax,(%esp)
  800a4b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4e:	83 eb 01             	sub    $0x1,%ebx
  800a51:	83 c7 01             	add    $0x1,%edi
  800a54:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a58:	0f be c2             	movsbl %dl,%eax
  800a5b:	85 c0                	test   %eax,%eax
  800a5d:	74 27                	je     800a86 <cvprintfmt+0x283>
  800a5f:	85 f6                	test   %esi,%esi
  800a61:	78 b8                	js     800a1b <cvprintfmt+0x218>
  800a63:	83 ee 01             	sub    $0x1,%esi
  800a66:	79 b3                	jns    800a1b <cvprintfmt+0x218>
  800a68:	89 d8                	mov    %ebx,%eax
  800a6a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a70:	89 c3                	mov    %eax,%ebx
  800a72:	eb 18                	jmp    800a8c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800a74:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a78:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a7f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800a81:	83 eb 01             	sub    $0x1,%ebx
  800a84:	eb 06                	jmp    800a8c <cvprintfmt+0x289>
  800a86:	8b 75 08             	mov    0x8(%ebp),%esi
  800a89:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	7f e4                	jg     800a74 <cvprintfmt+0x271>
  800a90:	89 75 08             	mov    %esi,0x8(%ebp)
  800a93:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a99:	e9 a7 fd ff ff       	jmp    800845 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a9e:	83 fa 01             	cmp    $0x1,%edx
  800aa1:	7e 10                	jle    800ab3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800aa3:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa6:	8d 50 08             	lea    0x8(%eax),%edx
  800aa9:	89 55 14             	mov    %edx,0x14(%ebp)
  800aac:	8b 30                	mov    (%eax),%esi
  800aae:	8b 78 04             	mov    0x4(%eax),%edi
  800ab1:	eb 26                	jmp    800ad9 <cvprintfmt+0x2d6>
	else if (lflag)
  800ab3:	85 d2                	test   %edx,%edx
  800ab5:	74 12                	je     800ac9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800ab7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aba:	8d 50 04             	lea    0x4(%eax),%edx
  800abd:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac0:	8b 30                	mov    (%eax),%esi
  800ac2:	89 f7                	mov    %esi,%edi
  800ac4:	c1 ff 1f             	sar    $0x1f,%edi
  800ac7:	eb 10                	jmp    800ad9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800ac9:	8b 45 14             	mov    0x14(%ebp),%eax
  800acc:	8d 50 04             	lea    0x4(%eax),%edx
  800acf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad2:	8b 30                	mov    (%eax),%esi
  800ad4:	89 f7                	mov    %esi,%edi
  800ad6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad9:	89 f0                	mov    %esi,%eax
  800adb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800add:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	0f 89 8e 00 00 00    	jns    800b78 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800af4:	83 c8 2d             	or     $0x2d,%eax
  800af7:	89 04 24             	mov    %eax,(%esp)
  800afa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800afd:	89 f0                	mov    %esi,%eax
  800aff:	89 fa                	mov    %edi,%edx
  800b01:	f7 d8                	neg    %eax
  800b03:	83 d2 00             	adc    $0x0,%edx
  800b06:	f7 da                	neg    %edx
			}
			base = 10;
  800b08:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b0d:	eb 69                	jmp    800b78 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b12:	e8 99 f8 ff ff       	call   8003b0 <getuint>
			base = 10;
  800b17:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b1c:	eb 5a                	jmp    800b78 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b1e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b21:	e8 8a f8 ff ff       	call   8003b0 <getuint>
			base = 8 ;
  800b26:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800b2b:	eb 4b                	jmp    800b78 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b34:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800b37:	89 f0                	mov    %esi,%eax
  800b39:	83 c8 30             	or     $0x30,%eax
  800b3c:	89 04 24             	mov    %eax,(%esp)
  800b3f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b49:	89 f0                	mov    %esi,%eax
  800b4b:	83 c8 78             	or     $0x78,%eax
  800b4e:	89 04 24             	mov    %eax,(%esp)
  800b51:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b54:	8b 45 14             	mov    0x14(%ebp),%eax
  800b57:	8d 50 04             	lea    0x4(%eax),%edx
  800b5a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800b5d:	8b 00                	mov    (%eax),%eax
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b64:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b69:	eb 0d                	jmp    800b78 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6e:	e8 3d f8 ff ff       	call   8003b0 <getuint>
			base = 16;
  800b73:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800b78:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800b7c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b80:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800b83:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b8b:	89 04 24             	mov    %eax,(%esp)
  800b8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b9b:	e8 0f f7 ff ff       	call   8002af <cprintnum>
			break;
  800ba0:	e9 a0 fc ff ff       	jmp    800845 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bac:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800baf:	89 04 24             	mov    %eax,(%esp)
  800bb2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800bb5:	e9 8b fc ff ff       	jmp    800845 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800bc4:	89 04 24             	mov    %eax,(%esp)
  800bc7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bca:	89 fb                	mov    %edi,%ebx
  800bcc:	eb 03                	jmp    800bd1 <cvprintfmt+0x3ce>
  800bce:	83 eb 01             	sub    $0x1,%ebx
  800bd1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800bd5:	75 f7                	jne    800bce <cvprintfmt+0x3cb>
  800bd7:	e9 69 fc ff ff       	jmp    800845 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800bdc:	83 c4 3c             	add    $0x3c,%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800bea:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800bed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bf1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	89 04 24             	mov    %eax,(%esp)
  800c05:	e8 f9 fb ff ff       	call   800803 <cvprintfmt>
	va_end(ap);
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 28             	sub    $0x28,%esp
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c18:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c1b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c1f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	74 30                	je     800c5d <vsnprintf+0x51>
  800c2d:	85 d2                	test   %edx,%edx
  800c2f:	7e 2c                	jle    800c5d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c31:	8b 45 14             	mov    0x14(%ebp),%eax
  800c34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c38:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c46:	c7 04 24 ea 03 80 00 	movl   $0x8003ea,(%esp)
  800c4d:	e8 dd f7 ff ff       	call   80042f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c55:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5b:	eb 05                	jmp    800c62 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c6a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c71:	8b 45 10             	mov    0x10(%ebp),%eax
  800c74:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	89 04 24             	mov    %eax,(%esp)
  800c85:	e8 82 ff ff ff       	call   800c0c <vsnprintf>
	va_end(ap);

	return rc;
}
  800c8a:	c9                   	leave  
  800c8b:	c3                   	ret    
  800c8c:	66 90                	xchg   %ax,%ax
  800c8e:	66 90                	xchg   %ax,%ax

00800c90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9b:	eb 03                	jmp    800ca0 <strlen+0x10>
		n++;
  800c9d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ca0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ca4:	75 f7                	jne    800c9d <strlen+0xd>
		n++;
	return n;
}
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	eb 03                	jmp    800cbb <strnlen+0x13>
		n++;
  800cb8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbb:	39 d0                	cmp    %edx,%eax
  800cbd:	74 06                	je     800cc5 <strnlen+0x1d>
  800cbf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800cc3:	75 f3                	jne    800cb8 <strnlen+0x10>
		n++;
	return n;
}
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	53                   	push   %ebx
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cd1:	89 c2                	mov    %eax,%edx
  800cd3:	83 c2 01             	add    $0x1,%edx
  800cd6:	83 c1 01             	add    $0x1,%ecx
  800cd9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cdd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ce0:	84 db                	test   %bl,%bl
  800ce2:	75 ef                	jne    800cd3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 08             	sub    $0x8,%esp
  800cee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cf1:	89 1c 24             	mov    %ebx,(%esp)
  800cf4:	e8 97 ff ff ff       	call   800c90 <strlen>
	strcpy(dst + len, src);
  800cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d00:	01 d8                	add    %ebx,%eax
  800d02:	89 04 24             	mov    %eax,(%esp)
  800d05:	e8 bd ff ff ff       	call   800cc7 <strcpy>
	return dst;
}
  800d0a:	89 d8                	mov    %ebx,%eax
  800d0c:	83 c4 08             	add    $0x8,%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	89 f3                	mov    %esi,%ebx
  800d1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d22:	89 f2                	mov    %esi,%edx
  800d24:	eb 0f                	jmp    800d35 <strncpy+0x23>
		*dst++ = *src;
  800d26:	83 c2 01             	add    $0x1,%edx
  800d29:	0f b6 01             	movzbl (%ecx),%eax
  800d2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d2f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d32:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d35:	39 da                	cmp    %ebx,%edx
  800d37:	75 ed                	jne    800d26 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d39:	89 f0                	mov    %esi,%eax
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	8b 75 08             	mov    0x8(%ebp),%esi
  800d47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d4d:	89 f0                	mov    %esi,%eax
  800d4f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d53:	85 c9                	test   %ecx,%ecx
  800d55:	75 0b                	jne    800d62 <strlcpy+0x23>
  800d57:	eb 1d                	jmp    800d76 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d59:	83 c0 01             	add    $0x1,%eax
  800d5c:	83 c2 01             	add    $0x1,%edx
  800d5f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d62:	39 d8                	cmp    %ebx,%eax
  800d64:	74 0b                	je     800d71 <strlcpy+0x32>
  800d66:	0f b6 0a             	movzbl (%edx),%ecx
  800d69:	84 c9                	test   %cl,%cl
  800d6b:	75 ec                	jne    800d59 <strlcpy+0x1a>
  800d6d:	89 c2                	mov    %eax,%edx
  800d6f:	eb 02                	jmp    800d73 <strlcpy+0x34>
  800d71:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d73:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d76:	29 f0                	sub    %esi,%eax
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d85:	eb 06                	jmp    800d8d <strcmp+0x11>
		p++, q++;
  800d87:	83 c1 01             	add    $0x1,%ecx
  800d8a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d8d:	0f b6 01             	movzbl (%ecx),%eax
  800d90:	84 c0                	test   %al,%al
  800d92:	74 04                	je     800d98 <strcmp+0x1c>
  800d94:	3a 02                	cmp    (%edx),%al
  800d96:	74 ef                	je     800d87 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d98:	0f b6 c0             	movzbl %al,%eax
  800d9b:	0f b6 12             	movzbl (%edx),%edx
  800d9e:	29 d0                	sub    %edx,%eax
}
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	53                   	push   %ebx
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
  800da9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dac:	89 c3                	mov    %eax,%ebx
  800dae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800db1:	eb 06                	jmp    800db9 <strncmp+0x17>
		n--, p++, q++;
  800db3:	83 c0 01             	add    $0x1,%eax
  800db6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800db9:	39 d8                	cmp    %ebx,%eax
  800dbb:	74 15                	je     800dd2 <strncmp+0x30>
  800dbd:	0f b6 08             	movzbl (%eax),%ecx
  800dc0:	84 c9                	test   %cl,%cl
  800dc2:	74 04                	je     800dc8 <strncmp+0x26>
  800dc4:	3a 0a                	cmp    (%edx),%cl
  800dc6:	74 eb                	je     800db3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc8:	0f b6 00             	movzbl (%eax),%eax
  800dcb:	0f b6 12             	movzbl (%edx),%edx
  800dce:	29 d0                	sub    %edx,%eax
  800dd0:	eb 05                	jmp    800dd7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de4:	eb 07                	jmp    800ded <strchr+0x13>
		if (*s == c)
  800de6:	38 ca                	cmp    %cl,%dl
  800de8:	74 0f                	je     800df9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dea:	83 c0 01             	add    $0x1,%eax
  800ded:	0f b6 10             	movzbl (%eax),%edx
  800df0:	84 d2                	test   %dl,%dl
  800df2:	75 f2                	jne    800de6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800df4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e05:	eb 07                	jmp    800e0e <strfind+0x13>
		if (*s == c)
  800e07:	38 ca                	cmp    %cl,%dl
  800e09:	74 0a                	je     800e15 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e0b:	83 c0 01             	add    $0x1,%eax
  800e0e:	0f b6 10             	movzbl (%eax),%edx
  800e11:	84 d2                	test   %dl,%dl
  800e13:	75 f2                	jne    800e07 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e23:	85 c9                	test   %ecx,%ecx
  800e25:	74 36                	je     800e5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e2d:	75 28                	jne    800e57 <memset+0x40>
  800e2f:	f6 c1 03             	test   $0x3,%cl
  800e32:	75 23                	jne    800e57 <memset+0x40>
		c &= 0xFF;
  800e34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e38:	89 d3                	mov    %edx,%ebx
  800e3a:	c1 e3 08             	shl    $0x8,%ebx
  800e3d:	89 d6                	mov    %edx,%esi
  800e3f:	c1 e6 18             	shl    $0x18,%esi
  800e42:	89 d0                	mov    %edx,%eax
  800e44:	c1 e0 10             	shl    $0x10,%eax
  800e47:	09 f0                	or     %esi,%eax
  800e49:	09 c2                	or     %eax,%edx
  800e4b:	89 d0                	mov    %edx,%eax
  800e4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e4f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e52:	fc                   	cld    
  800e53:	f3 ab                	rep stos %eax,%es:(%edi)
  800e55:	eb 06                	jmp    800e5d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	fc                   	cld    
  800e5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e5d:	89 f8                	mov    %edi,%eax
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e72:	39 c6                	cmp    %eax,%esi
  800e74:	73 35                	jae    800eab <memmove+0x47>
  800e76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e79:	39 d0                	cmp    %edx,%eax
  800e7b:	73 2e                	jae    800eab <memmove+0x47>
		s += n;
		d += n;
  800e7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e8a:	75 13                	jne    800e9f <memmove+0x3b>
  800e8c:	f6 c1 03             	test   $0x3,%cl
  800e8f:	75 0e                	jne    800e9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e91:	83 ef 04             	sub    $0x4,%edi
  800e94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e9a:	fd                   	std    
  800e9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e9d:	eb 09                	jmp    800ea8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e9f:	83 ef 01             	sub    $0x1,%edi
  800ea2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ea5:	fd                   	std    
  800ea6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ea8:	fc                   	cld    
  800ea9:	eb 1d                	jmp    800ec8 <memmove+0x64>
  800eab:	89 f2                	mov    %esi,%edx
  800ead:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eaf:	f6 c2 03             	test   $0x3,%dl
  800eb2:	75 0f                	jne    800ec3 <memmove+0x5f>
  800eb4:	f6 c1 03             	test   $0x3,%cl
  800eb7:	75 0a                	jne    800ec3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800eb9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ebc:	89 c7                	mov    %eax,%edi
  800ebe:	fc                   	cld    
  800ebf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec1:	eb 05                	jmp    800ec8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ec3:	89 c7                	mov    %eax,%edi
  800ec5:	fc                   	cld    
  800ec6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ed2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	89 04 24             	mov    %eax,(%esp)
  800ee6:	e8 79 ff ff ff       	call   800e64 <memmove>
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    

00800eed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef8:	89 d6                	mov    %edx,%esi
  800efa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800efd:	eb 1a                	jmp    800f19 <memcmp+0x2c>
		if (*s1 != *s2)
  800eff:	0f b6 02             	movzbl (%edx),%eax
  800f02:	0f b6 19             	movzbl (%ecx),%ebx
  800f05:	38 d8                	cmp    %bl,%al
  800f07:	74 0a                	je     800f13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f09:	0f b6 c0             	movzbl %al,%eax
  800f0c:	0f b6 db             	movzbl %bl,%ebx
  800f0f:	29 d8                	sub    %ebx,%eax
  800f11:	eb 0f                	jmp    800f22 <memcmp+0x35>
		s1++, s2++;
  800f13:	83 c2 01             	add    $0x1,%edx
  800f16:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f19:	39 f2                	cmp    %esi,%edx
  800f1b:	75 e2                	jne    800eff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f2f:	89 c2                	mov    %eax,%edx
  800f31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f34:	eb 07                	jmp    800f3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f36:	38 08                	cmp    %cl,(%eax)
  800f38:	74 07                	je     800f41 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f3a:	83 c0 01             	add    $0x1,%eax
  800f3d:	39 d0                	cmp    %edx,%eax
  800f3f:	72 f5                	jb     800f36 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f4f:	eb 03                	jmp    800f54 <strtol+0x11>
		s++;
  800f51:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f54:	0f b6 0a             	movzbl (%edx),%ecx
  800f57:	80 f9 09             	cmp    $0x9,%cl
  800f5a:	74 f5                	je     800f51 <strtol+0xe>
  800f5c:	80 f9 20             	cmp    $0x20,%cl
  800f5f:	74 f0                	je     800f51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f61:	80 f9 2b             	cmp    $0x2b,%cl
  800f64:	75 0a                	jne    800f70 <strtol+0x2d>
		s++;
  800f66:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f69:	bf 00 00 00 00       	mov    $0x0,%edi
  800f6e:	eb 11                	jmp    800f81 <strtol+0x3e>
  800f70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f75:	80 f9 2d             	cmp    $0x2d,%cl
  800f78:	75 07                	jne    800f81 <strtol+0x3e>
		s++, neg = 1;
  800f7a:	8d 52 01             	lea    0x1(%edx),%edx
  800f7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800f86:	75 15                	jne    800f9d <strtol+0x5a>
  800f88:	80 3a 30             	cmpb   $0x30,(%edx)
  800f8b:	75 10                	jne    800f9d <strtol+0x5a>
  800f8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f91:	75 0a                	jne    800f9d <strtol+0x5a>
		s += 2, base = 16;
  800f93:	83 c2 02             	add    $0x2,%edx
  800f96:	b8 10 00 00 00       	mov    $0x10,%eax
  800f9b:	eb 10                	jmp    800fad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	75 0c                	jne    800fad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fa1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fa3:	80 3a 30             	cmpb   $0x30,(%edx)
  800fa6:	75 05                	jne    800fad <strtol+0x6a>
		s++, base = 8;
  800fa8:	83 c2 01             	add    $0x1,%edx
  800fab:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800fad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fb5:	0f b6 0a             	movzbl (%edx),%ecx
  800fb8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800fbb:	89 f0                	mov    %esi,%eax
  800fbd:	3c 09                	cmp    $0x9,%al
  800fbf:	77 08                	ja     800fc9 <strtol+0x86>
			dig = *s - '0';
  800fc1:	0f be c9             	movsbl %cl,%ecx
  800fc4:	83 e9 30             	sub    $0x30,%ecx
  800fc7:	eb 20                	jmp    800fe9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800fc9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800fcc:	89 f0                	mov    %esi,%eax
  800fce:	3c 19                	cmp    $0x19,%al
  800fd0:	77 08                	ja     800fda <strtol+0x97>
			dig = *s - 'a' + 10;
  800fd2:	0f be c9             	movsbl %cl,%ecx
  800fd5:	83 e9 57             	sub    $0x57,%ecx
  800fd8:	eb 0f                	jmp    800fe9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800fda:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800fdd:	89 f0                	mov    %esi,%eax
  800fdf:	3c 19                	cmp    $0x19,%al
  800fe1:	77 16                	ja     800ff9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800fe3:	0f be c9             	movsbl %cl,%ecx
  800fe6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fe9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800fec:	7d 0f                	jge    800ffd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800fee:	83 c2 01             	add    $0x1,%edx
  800ff1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ff5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ff7:	eb bc                	jmp    800fb5 <strtol+0x72>
  800ff9:	89 d8                	mov    %ebx,%eax
  800ffb:	eb 02                	jmp    800fff <strtol+0xbc>
  800ffd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800fff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801003:	74 05                	je     80100a <strtol+0xc7>
		*endptr = (char *) s;
  801005:	8b 75 0c             	mov    0xc(%ebp),%esi
  801008:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80100a:	f7 d8                	neg    %eax
  80100c:	85 ff                	test   %edi,%edi
  80100e:	0f 44 c3             	cmove  %ebx,%eax
}
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101c:	b8 00 00 00 00       	mov    $0x0,%eax
  801021:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	89 c3                	mov    %eax,%ebx
  801029:	89 c7                	mov    %eax,%edi
  80102b:	89 c6                	mov    %eax,%esi
  80102d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_cgetc>:

int
sys_cgetc(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	b8 01 00 00 00       	mov    $0x1,%eax
  801044:	89 d1                	mov    %edx,%ecx
  801046:	89 d3                	mov    %edx,%ebx
  801048:	89 d7                	mov    %edx,%edi
  80104a:	89 d6                	mov    %edx,%esi
  80104c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801061:	b8 03 00 00 00       	mov    $0x3,%eax
  801066:	8b 55 08             	mov    0x8(%ebp),%edx
  801069:	89 cb                	mov    %ecx,%ebx
  80106b:	89 cf                	mov    %ecx,%edi
  80106d:	89 ce                	mov    %ecx,%esi
  80106f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	7e 28                	jle    80109d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801075:	89 44 24 10          	mov    %eax,0x10(%esp)
  801079:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801080:	00 
  801081:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  801098:	e8 5b 02 00 00       	call   8012f8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80109d:	83 c4 2c             	add    $0x2c,%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5f                   	pop    %edi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	57                   	push   %edi
  8010a9:	56                   	push   %esi
  8010aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8010b5:	89 d1                	mov    %edx,%ecx
  8010b7:	89 d3                	mov    %edx,%ebx
  8010b9:	89 d7                	mov    %edx,%edi
  8010bb:	89 d6                	mov    %edx,%esi
  8010bd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_yield>:

void
sys_yield(void)
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
  8010cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010d4:	89 d1                	mov    %edx,%ecx
  8010d6:	89 d3                	mov    %edx,%ebx
  8010d8:	89 d7                	mov    %edx,%edi
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  8010ec:	be 00 00 00 00       	mov    $0x0,%esi
  8010f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8010f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ff:	89 f7                	mov    %esi,%edi
  801101:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801103:	85 c0                	test   %eax,%eax
  801105:	7e 28                	jle    80112f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801112:	00 
  801113:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  80111a:	00 
  80111b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801122:	00 
  801123:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  80112a:	e8 c9 01 00 00       	call   8012f8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80112f:	83 c4 2c             	add    $0x2c,%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801140:	b8 05 00 00 00       	mov    $0x5,%eax
  801145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801148:	8b 55 08             	mov    0x8(%ebp),%edx
  80114b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801151:	8b 75 18             	mov    0x18(%ebp),%esi
  801154:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801156:	85 c0                	test   %eax,%eax
  801158:	7e 28                	jle    801182 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801165:	00 
  801166:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  80117d:	e8 76 01 00 00       	call   8012f8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801182:	83 c4 2c             	add    $0x2c,%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	57                   	push   %edi
  80118e:	56                   	push   %esi
  80118f:	53                   	push   %ebx
  801190:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801193:	bb 00 00 00 00       	mov    $0x0,%ebx
  801198:	b8 06 00 00 00       	mov    $0x6,%eax
  80119d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a3:	89 df                	mov    %ebx,%edi
  8011a5:	89 de                	mov    %ebx,%esi
  8011a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	7e 28                	jle    8011d5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c8:	00 
  8011c9:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  8011d0:	e8 23 01 00 00       	call   8012f8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011d5:	83 c4 2c             	add    $0x2c,%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8011f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f6:	89 df                	mov    %ebx,%edi
  8011f8:	89 de                	mov    %ebx,%esi
  8011fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	7e 28                	jle    801228 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801200:	89 44 24 10          	mov    %eax,0x10(%esp)
  801204:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80120b:	00 
  80120c:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801213:	00 
  801214:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80121b:	00 
  80121c:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  801223:	e8 d0 00 00 00       	call   8012f8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801228:	83 c4 2c             	add    $0x2c,%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123e:	b8 09 00 00 00       	mov    $0x9,%eax
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	8b 55 08             	mov    0x8(%ebp),%edx
  801249:	89 df                	mov    %ebx,%edi
  80124b:	89 de                	mov    %ebx,%esi
  80124d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80124f:	85 c0                	test   %eax,%eax
  801251:	7e 28                	jle    80127b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801253:	89 44 24 10          	mov    %eax,0x10(%esp)
  801257:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80125e:	00 
  80125f:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126e:	00 
  80126f:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  801276:	e8 7d 00 00 00       	call   8012f8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80127b:	83 c4 2c             	add    $0x2c,%esp
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	57                   	push   %edi
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801289:	be 00 00 00 00       	mov    $0x0,%esi
  80128e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	8b 55 08             	mov    0x8(%ebp),%edx
  801299:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80129c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80129f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012a1:	5b                   	pop    %ebx
  8012a2:	5e                   	pop    %esi
  8012a3:	5f                   	pop    %edi
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	57                   	push   %edi
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bc:	89 cb                	mov    %ecx,%ebx
  8012be:	89 cf                	mov    %ecx,%edi
  8012c0:	89 ce                	mov    %ecx,%esi
  8012c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	7e 28                	jle    8012f0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012cc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8012d3:	00 
  8012d4:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  8012db:	00 
  8012dc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012e3:	00 
  8012e4:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  8012eb:	e8 08 00 00 00       	call   8012f8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012f0:	83 c4 2c             	add    $0x2c,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801300:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801303:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801309:	e8 97 fd ff ff       	call   8010a5 <sys_getenvid>
  80130e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801311:	89 54 24 10          	mov    %edx,0x10(%esp)
  801315:	8b 55 08             	mov    0x8(%ebp),%edx
  801318:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80131c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801320:	89 44 24 04          	mov    %eax,0x4(%esp)
  801324:	c7 04 24 34 1a 80 00 	movl   $0x801a34,(%esp)
  80132b:	e8 71 ee ff ff       	call   8001a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801330:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801334:	8b 45 10             	mov    0x10(%ebp),%eax
  801337:	89 04 24             	mov    %eax,(%esp)
  80133a:	e8 01 ee ff ff       	call   800140 <vcprintf>
	cprintf("\n");
  80133f:	c7 04 24 58 1a 80 00 	movl   $0x801a58,(%esp)
  801346:	e8 56 ee ff ff       	call   8001a1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80134b:	cc                   	int3   
  80134c:	eb fd                	jmp    80134b <_panic+0x53>
  80134e:	66 90                	xchg   %ax,%ax

00801350 <__udivdi3>:
  801350:	55                   	push   %ebp
  801351:	57                   	push   %edi
  801352:	56                   	push   %esi
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	8b 44 24 28          	mov    0x28(%esp),%eax
  80135a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80135e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801362:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801366:	85 c0                	test   %eax,%eax
  801368:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80136c:	89 ea                	mov    %ebp,%edx
  80136e:	89 0c 24             	mov    %ecx,(%esp)
  801371:	75 2d                	jne    8013a0 <__udivdi3+0x50>
  801373:	39 e9                	cmp    %ebp,%ecx
  801375:	77 61                	ja     8013d8 <__udivdi3+0x88>
  801377:	85 c9                	test   %ecx,%ecx
  801379:	89 ce                	mov    %ecx,%esi
  80137b:	75 0b                	jne    801388 <__udivdi3+0x38>
  80137d:	b8 01 00 00 00       	mov    $0x1,%eax
  801382:	31 d2                	xor    %edx,%edx
  801384:	f7 f1                	div    %ecx
  801386:	89 c6                	mov    %eax,%esi
  801388:	31 d2                	xor    %edx,%edx
  80138a:	89 e8                	mov    %ebp,%eax
  80138c:	f7 f6                	div    %esi
  80138e:	89 c5                	mov    %eax,%ebp
  801390:	89 f8                	mov    %edi,%eax
  801392:	f7 f6                	div    %esi
  801394:	89 ea                	mov    %ebp,%edx
  801396:	83 c4 0c             	add    $0xc,%esp
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    
  80139d:	8d 76 00             	lea    0x0(%esi),%esi
  8013a0:	39 e8                	cmp    %ebp,%eax
  8013a2:	77 24                	ja     8013c8 <__udivdi3+0x78>
  8013a4:	0f bd e8             	bsr    %eax,%ebp
  8013a7:	83 f5 1f             	xor    $0x1f,%ebp
  8013aa:	75 3c                	jne    8013e8 <__udivdi3+0x98>
  8013ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013b0:	39 34 24             	cmp    %esi,(%esp)
  8013b3:	0f 86 9f 00 00 00    	jbe    801458 <__udivdi3+0x108>
  8013b9:	39 d0                	cmp    %edx,%eax
  8013bb:	0f 82 97 00 00 00    	jb     801458 <__udivdi3+0x108>
  8013c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	31 d2                	xor    %edx,%edx
  8013ca:	31 c0                	xor    %eax,%eax
  8013cc:	83 c4 0c             	add    $0xc,%esp
  8013cf:	5e                   	pop    %esi
  8013d0:	5f                   	pop    %edi
  8013d1:	5d                   	pop    %ebp
  8013d2:	c3                   	ret    
  8013d3:	90                   	nop
  8013d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d8:	89 f8                	mov    %edi,%eax
  8013da:	f7 f1                	div    %ecx
  8013dc:	31 d2                	xor    %edx,%edx
  8013de:	83 c4 0c             	add    $0xc,%esp
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    
  8013e5:	8d 76 00             	lea    0x0(%esi),%esi
  8013e8:	89 e9                	mov    %ebp,%ecx
  8013ea:	8b 3c 24             	mov    (%esp),%edi
  8013ed:	d3 e0                	shl    %cl,%eax
  8013ef:	89 c6                	mov    %eax,%esi
  8013f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013f6:	29 e8                	sub    %ebp,%eax
  8013f8:	89 c1                	mov    %eax,%ecx
  8013fa:	d3 ef                	shr    %cl,%edi
  8013fc:	89 e9                	mov    %ebp,%ecx
  8013fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801402:	8b 3c 24             	mov    (%esp),%edi
  801405:	09 74 24 08          	or     %esi,0x8(%esp)
  801409:	89 d6                	mov    %edx,%esi
  80140b:	d3 e7                	shl    %cl,%edi
  80140d:	89 c1                	mov    %eax,%ecx
  80140f:	89 3c 24             	mov    %edi,(%esp)
  801412:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801416:	d3 ee                	shr    %cl,%esi
  801418:	89 e9                	mov    %ebp,%ecx
  80141a:	d3 e2                	shl    %cl,%edx
  80141c:	89 c1                	mov    %eax,%ecx
  80141e:	d3 ef                	shr    %cl,%edi
  801420:	09 d7                	or     %edx,%edi
  801422:	89 f2                	mov    %esi,%edx
  801424:	89 f8                	mov    %edi,%eax
  801426:	f7 74 24 08          	divl   0x8(%esp)
  80142a:	89 d6                	mov    %edx,%esi
  80142c:	89 c7                	mov    %eax,%edi
  80142e:	f7 24 24             	mull   (%esp)
  801431:	39 d6                	cmp    %edx,%esi
  801433:	89 14 24             	mov    %edx,(%esp)
  801436:	72 30                	jb     801468 <__udivdi3+0x118>
  801438:	8b 54 24 04          	mov    0x4(%esp),%edx
  80143c:	89 e9                	mov    %ebp,%ecx
  80143e:	d3 e2                	shl    %cl,%edx
  801440:	39 c2                	cmp    %eax,%edx
  801442:	73 05                	jae    801449 <__udivdi3+0xf9>
  801444:	3b 34 24             	cmp    (%esp),%esi
  801447:	74 1f                	je     801468 <__udivdi3+0x118>
  801449:	89 f8                	mov    %edi,%eax
  80144b:	31 d2                	xor    %edx,%edx
  80144d:	e9 7a ff ff ff       	jmp    8013cc <__udivdi3+0x7c>
  801452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801458:	31 d2                	xor    %edx,%edx
  80145a:	b8 01 00 00 00       	mov    $0x1,%eax
  80145f:	e9 68 ff ff ff       	jmp    8013cc <__udivdi3+0x7c>
  801464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801468:	8d 47 ff             	lea    -0x1(%edi),%eax
  80146b:	31 d2                	xor    %edx,%edx
  80146d:	83 c4 0c             	add    $0xc,%esp
  801470:	5e                   	pop    %esi
  801471:	5f                   	pop    %edi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    
  801474:	66 90                	xchg   %ax,%ax
  801476:	66 90                	xchg   %ax,%ax
  801478:	66 90                	xchg   %ax,%ax
  80147a:	66 90                	xchg   %ax,%ax
  80147c:	66 90                	xchg   %ax,%ax
  80147e:	66 90                	xchg   %ax,%ax

00801480 <__umoddi3>:
  801480:	55                   	push   %ebp
  801481:	57                   	push   %edi
  801482:	56                   	push   %esi
  801483:	83 ec 14             	sub    $0x14,%esp
  801486:	8b 44 24 28          	mov    0x28(%esp),%eax
  80148a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80148e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801492:	89 c7                	mov    %eax,%edi
  801494:	89 44 24 04          	mov    %eax,0x4(%esp)
  801498:	8b 44 24 30          	mov    0x30(%esp),%eax
  80149c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014a0:	89 34 24             	mov    %esi,(%esp)
  8014a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014af:	75 17                	jne    8014c8 <__umoddi3+0x48>
  8014b1:	39 fe                	cmp    %edi,%esi
  8014b3:	76 4b                	jbe    801500 <__umoddi3+0x80>
  8014b5:	89 c8                	mov    %ecx,%eax
  8014b7:	89 fa                	mov    %edi,%edx
  8014b9:	f7 f6                	div    %esi
  8014bb:	89 d0                	mov    %edx,%eax
  8014bd:	31 d2                	xor    %edx,%edx
  8014bf:	83 c4 14             	add    $0x14,%esp
  8014c2:	5e                   	pop    %esi
  8014c3:	5f                   	pop    %edi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    
  8014c6:	66 90                	xchg   %ax,%ax
  8014c8:	39 f8                	cmp    %edi,%eax
  8014ca:	77 54                	ja     801520 <__umoddi3+0xa0>
  8014cc:	0f bd e8             	bsr    %eax,%ebp
  8014cf:	83 f5 1f             	xor    $0x1f,%ebp
  8014d2:	75 5c                	jne    801530 <__umoddi3+0xb0>
  8014d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014d8:	39 3c 24             	cmp    %edi,(%esp)
  8014db:	0f 87 e7 00 00 00    	ja     8015c8 <__umoddi3+0x148>
  8014e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014e5:	29 f1                	sub    %esi,%ecx
  8014e7:	19 c7                	sbb    %eax,%edi
  8014e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014f1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014f9:	83 c4 14             	add    $0x14,%esp
  8014fc:	5e                   	pop    %esi
  8014fd:	5f                   	pop    %edi
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    
  801500:	85 f6                	test   %esi,%esi
  801502:	89 f5                	mov    %esi,%ebp
  801504:	75 0b                	jne    801511 <__umoddi3+0x91>
  801506:	b8 01 00 00 00       	mov    $0x1,%eax
  80150b:	31 d2                	xor    %edx,%edx
  80150d:	f7 f6                	div    %esi
  80150f:	89 c5                	mov    %eax,%ebp
  801511:	8b 44 24 04          	mov    0x4(%esp),%eax
  801515:	31 d2                	xor    %edx,%edx
  801517:	f7 f5                	div    %ebp
  801519:	89 c8                	mov    %ecx,%eax
  80151b:	f7 f5                	div    %ebp
  80151d:	eb 9c                	jmp    8014bb <__umoddi3+0x3b>
  80151f:	90                   	nop
  801520:	89 c8                	mov    %ecx,%eax
  801522:	89 fa                	mov    %edi,%edx
  801524:	83 c4 14             	add    $0x14,%esp
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    
  80152b:	90                   	nop
  80152c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801530:	8b 04 24             	mov    (%esp),%eax
  801533:	be 20 00 00 00       	mov    $0x20,%esi
  801538:	89 e9                	mov    %ebp,%ecx
  80153a:	29 ee                	sub    %ebp,%esi
  80153c:	d3 e2                	shl    %cl,%edx
  80153e:	89 f1                	mov    %esi,%ecx
  801540:	d3 e8                	shr    %cl,%eax
  801542:	89 e9                	mov    %ebp,%ecx
  801544:	89 44 24 04          	mov    %eax,0x4(%esp)
  801548:	8b 04 24             	mov    (%esp),%eax
  80154b:	09 54 24 04          	or     %edx,0x4(%esp)
  80154f:	89 fa                	mov    %edi,%edx
  801551:	d3 e0                	shl    %cl,%eax
  801553:	89 f1                	mov    %esi,%ecx
  801555:	89 44 24 08          	mov    %eax,0x8(%esp)
  801559:	8b 44 24 10          	mov    0x10(%esp),%eax
  80155d:	d3 ea                	shr    %cl,%edx
  80155f:	89 e9                	mov    %ebp,%ecx
  801561:	d3 e7                	shl    %cl,%edi
  801563:	89 f1                	mov    %esi,%ecx
  801565:	d3 e8                	shr    %cl,%eax
  801567:	89 e9                	mov    %ebp,%ecx
  801569:	09 f8                	or     %edi,%eax
  80156b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80156f:	f7 74 24 04          	divl   0x4(%esp)
  801573:	d3 e7                	shl    %cl,%edi
  801575:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801579:	89 d7                	mov    %edx,%edi
  80157b:	f7 64 24 08          	mull   0x8(%esp)
  80157f:	39 d7                	cmp    %edx,%edi
  801581:	89 c1                	mov    %eax,%ecx
  801583:	89 14 24             	mov    %edx,(%esp)
  801586:	72 2c                	jb     8015b4 <__umoddi3+0x134>
  801588:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80158c:	72 22                	jb     8015b0 <__umoddi3+0x130>
  80158e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801592:	29 c8                	sub    %ecx,%eax
  801594:	19 d7                	sbb    %edx,%edi
  801596:	89 e9                	mov    %ebp,%ecx
  801598:	89 fa                	mov    %edi,%edx
  80159a:	d3 e8                	shr    %cl,%eax
  80159c:	89 f1                	mov    %esi,%ecx
  80159e:	d3 e2                	shl    %cl,%edx
  8015a0:	89 e9                	mov    %ebp,%ecx
  8015a2:	d3 ef                	shr    %cl,%edi
  8015a4:	09 d0                	or     %edx,%eax
  8015a6:	89 fa                	mov    %edi,%edx
  8015a8:	83 c4 14             	add    $0x14,%esp
  8015ab:	5e                   	pop    %esi
  8015ac:	5f                   	pop    %edi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    
  8015af:	90                   	nop
  8015b0:	39 d7                	cmp    %edx,%edi
  8015b2:	75 da                	jne    80158e <__umoddi3+0x10e>
  8015b4:	8b 14 24             	mov    (%esp),%edx
  8015b7:	89 c1                	mov    %eax,%ecx
  8015b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8015bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8015c1:	eb cb                	jmp    80158e <__umoddi3+0x10e>
  8015c3:	90                   	nop
  8015c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8015cc:	0f 82 0f ff ff ff    	jb     8014e1 <__umoddi3+0x61>
  8015d2:	e9 1a ff ff ff       	jmp    8014f1 <__umoddi3+0x71>
