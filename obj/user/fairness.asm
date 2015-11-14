
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 91 00 00 00       	call   8000c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 85 10 00 00       	call   8010c5 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 88 	cmpl   $0xeec00088,0x802004
  800049:	00 c0 ee 
  80004c:	75 34                	jne    800082 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800058:	00 
  800059:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800060:	00 
  800061:	89 34 24             	mov    %esi,(%esp)
  800064:	e8 b7 12 00 00       	call   801320 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  800069:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	c7 04 24 80 17 80 00 	movl   $0x801780,(%esp)
  80007b:	e8 45 01 00 00       	call   8001c5 <cprintf>
  800080:	eb cf                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800082:	a1 d0 00 c0 ee       	mov    0xeec000d0,%eax
  800087:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008f:	c7 04 24 91 17 80 00 	movl   $0x801791,(%esp)
  800096:	e8 2a 01 00 00       	call   8001c5 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009b:	a1 d0 00 c0 ee       	mov    0xeec000d0,%eax
  8000a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a7:	00 
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 04 24             	mov    %eax,(%esp)
  8000bb:	e8 d0 12 00 00       	call   801390 <ipc_send>
  8000c0:	eb d9                	jmp    80009b <umain+0x68>

008000c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 10             	sub    $0x10,%esp
  8000ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  8000d0:	e8 f0 0f 00 00       	call   8010c5 <sys_getenvid>
  8000d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000da:	89 c2                	mov    %eax,%edx
  8000dc:	c1 e2 07             	shl    $0x7,%edx
  8000df:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000e6:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000eb:	85 db                	test   %ebx,%ebx
  8000ed:	7e 07                	jle    8000f6 <libmain+0x34>
		binaryname = argv[0];
  8000ef:	8b 06                	mov    (%esi),%eax
  8000f1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000fa:	89 1c 24             	mov    %ebx,(%esp)
  8000fd:	e8 31 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800102:	e8 07 00 00 00       	call   80010e <exit>
}
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800114:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011b:	e8 53 0f 00 00       	call   801073 <sys_env_destroy>
}
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	53                   	push   %ebx
  800126:	83 ec 14             	sub    $0x14,%esp
  800129:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012c:	8b 13                	mov    (%ebx),%edx
  80012e:	8d 42 01             	lea    0x1(%edx),%eax
  800131:	89 03                	mov    %eax,(%ebx)
  800133:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800136:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013f:	75 19                	jne    80015a <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800141:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800148:	00 
  800149:	8d 43 08             	lea    0x8(%ebx),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 e2 0e 00 00       	call   801036 <sys_cputs>
		b->idx = 0;
  800154:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	83 c4 14             	add    $0x14,%esp
  800161:	5b                   	pop    %ebx
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800174:	00 00 00 
	b.cnt = 0;
  800177:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800181:	8b 45 0c             	mov    0xc(%ebp),%eax
  800184:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 22 01 80 00 	movl   $0x800122,(%esp)
  8001a0:	e8 aa 02 00 00       	call   80044f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b5:	89 04 24             	mov    %eax,(%esp)
  8001b8:	e8 79 0e 00 00       	call   801036 <sys_cputs>

	return b.cnt;
}
  8001bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 87 ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    
  8001df:	90                   	nop

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800202:	b9 00 00 00 00       	mov    $0x0,%ecx
  800207:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80020d:	39 d9                	cmp    %ebx,%ecx
  80020f:	72 05                	jb     800216 <printnum+0x36>
  800211:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800214:	77 69                	ja     80027f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800216:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800219:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80021d:	83 ee 01             	sub    $0x1,%esi
  800220:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	8b 44 24 08          	mov    0x8(%esp),%eax
  80022c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800230:	89 c3                	mov    %eax,%ebx
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800237:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80023a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80023e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 8c 12 00 00       	call   8014e0 <__udivdi3>
  800254:	89 d9                	mov    %ebx,%ecx
  800256:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	89 54 24 04          	mov    %edx,0x4(%esp)
  800265:	89 fa                	mov    %edi,%edx
  800267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026a:	e8 71 ff ff ff       	call   8001e0 <printnum>
  80026f:	eb 1b                	jmp    80028c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800271:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800275:	8b 45 18             	mov    0x18(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff d3                	call   *%ebx
  80027d:	eb 03                	jmp    800282 <printnum+0xa2>
  80027f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800282:	83 ee 01             	sub    $0x1,%esi
  800285:	85 f6                	test   %esi,%esi
  800287:	7f e8                	jg     800271 <printnum+0x91>
  800289:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800290:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800294:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800297:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	e8 5c 13 00 00       	call   801610 <__umoddi3>
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	0f be 80 b2 17 80 00 	movsbl 0x8017b2(%eax),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c5:	ff d0                	call   *%eax
}
  8002c7:	83 c4 3c             	add    $0x3c,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 3c             	sub    $0x3c,%esp
  8002d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002db:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002de:	89 cf                	mov    %ecx,%edi
  8002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e9:	89 c3                	mov    %eax,%ebx
  8002eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8002ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002fc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002ff:	39 d9                	cmp    %ebx,%ecx
  800301:	72 13                	jb     800316 <cprintnum+0x47>
  800303:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800306:	76 0e                	jbe    800316 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800308:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030b:	0b 45 18             	or     0x18(%ebp),%eax
  80030e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800311:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800314:	eb 6a                	jmp    800380 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800316:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800319:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80031d:	83 ee 01             	sub    $0x1,%esi
  800320:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800324:	89 44 24 08          	mov    %eax,0x8(%esp)
  800328:	8b 44 24 08          	mov    0x8(%esp),%eax
  80032c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800330:	89 c3                	mov    %eax,%ebx
  800332:	89 d6                	mov    %edx,%esi
  800334:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800337:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80033a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80033e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800342:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 8c 11 00 00       	call   8014e0 <__udivdi3>
  800354:	89 d9                	mov    %ebx,%ecx
  800356:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80035e:	89 04 24             	mov    %eax,(%esp)
  800361:	89 54 24 04          	mov    %edx,0x4(%esp)
  800365:	89 f9                	mov    %edi,%ecx
  800367:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80036a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036d:	e8 5d ff ff ff       	call   8002cf <cprintnum>
  800372:	eb 16                	jmp    80038a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800374:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800378:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800380:	83 ee 01             	sub    $0x1,%esi
  800383:	85 f6                	test   %esi,%esi
  800385:	7f ed                	jg     800374 <cprintnum+0xa5>
  800387:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80038a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800392:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800395:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800398:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a3:	89 04 24             	mov    %eax,(%esp)
  8003a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ad:	e8 5e 12 00 00       	call   801610 <__umoddi3>
  8003b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b6:	0f be 80 b2 17 80 00 	movsbl 0x8017b2(%eax),%eax
  8003bd:	0b 45 dc             	or     -0x24(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c6:	ff d0                	call   *%eax
}
  8003c8:	83 c4 3c             	add    $0x3c,%esp
  8003cb:	5b                   	pop    %ebx
  8003cc:	5e                   	pop    %esi
  8003cd:	5f                   	pop    %edi
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d3:	83 fa 01             	cmp    $0x1,%edx
  8003d6:	7e 0e                	jle    8003e6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d8:	8b 10                	mov    (%eax),%edx
  8003da:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003dd:	89 08                	mov    %ecx,(%eax)
  8003df:	8b 02                	mov    (%edx),%eax
  8003e1:	8b 52 04             	mov    0x4(%edx),%edx
  8003e4:	eb 22                	jmp    800408 <getuint+0x38>
	else if (lflag)
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	74 10                	je     8003fa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ef:	89 08                	mov    %ecx,(%eax)
  8003f1:	8b 02                	mov    (%edx),%eax
  8003f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f8:	eb 0e                	jmp    800408 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800408:	5d                   	pop    %ebp
  800409:	c3                   	ret    

0080040a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800410:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800414:	8b 10                	mov    (%eax),%edx
  800416:	3b 50 04             	cmp    0x4(%eax),%edx
  800419:	73 0a                	jae    800425 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80041e:	89 08                	mov    %ecx,(%eax)
  800420:	8b 45 08             	mov    0x8(%ebp),%eax
  800423:	88 02                	mov    %al,(%edx)
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80042d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800430:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800434:	8b 45 10             	mov    0x10(%ebp),%eax
  800437:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	89 04 24             	mov    %eax,(%esp)
  800448:	e8 02 00 00 00       	call   80044f <vprintfmt>
	va_end(ap);
}
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    

0080044f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	57                   	push   %edi
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	83 ec 3c             	sub    $0x3c,%esp
  800458:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80045b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80045e:	eb 14                	jmp    800474 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800460:	85 c0                	test   %eax,%eax
  800462:	0f 84 b3 03 00 00    	je     80081b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800468:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800472:	89 f3                	mov    %esi,%ebx
  800474:	8d 73 01             	lea    0x1(%ebx),%esi
  800477:	0f b6 03             	movzbl (%ebx),%eax
  80047a:	83 f8 25             	cmp    $0x25,%eax
  80047d:	75 e1                	jne    800460 <vprintfmt+0x11>
  80047f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800483:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80048a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800491:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800498:	ba 00 00 00 00       	mov    $0x0,%edx
  80049d:	eb 1d                	jmp    8004bc <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004a5:	eb 15                	jmp    8004bc <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a9:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004ad:	eb 0d                	jmp    8004bc <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004bf:	0f b6 0e             	movzbl (%esi),%ecx
  8004c2:	0f b6 c1             	movzbl %cl,%eax
  8004c5:	83 e9 23             	sub    $0x23,%ecx
  8004c8:	80 f9 55             	cmp    $0x55,%cl
  8004cb:	0f 87 2a 03 00 00    	ja     8007fb <vprintfmt+0x3ac>
  8004d1:	0f b6 c9             	movzbl %cl,%ecx
  8004d4:	ff 24 8d 80 18 80 00 	jmp    *0x801880(,%ecx,4)
  8004db:	89 de                	mov    %ebx,%esi
  8004dd:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004e5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004e9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ec:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ef:	83 fb 09             	cmp    $0x9,%ebx
  8004f2:	77 36                	ja     80052a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f7:	eb e9                	jmp    8004e2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800509:	eb 22                	jmp    80052d <vprintfmt+0xde>
  80050b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050e:	85 c9                	test   %ecx,%ecx
  800510:	b8 00 00 00 00       	mov    $0x0,%eax
  800515:	0f 49 c1             	cmovns %ecx,%eax
  800518:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	89 de                	mov    %ebx,%esi
  80051d:	eb 9d                	jmp    8004bc <vprintfmt+0x6d>
  80051f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800521:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800528:	eb 92                	jmp    8004bc <vprintfmt+0x6d>
  80052a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80052d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800531:	79 89                	jns    8004bc <vprintfmt+0x6d>
  800533:	e9 77 ff ff ff       	jmp    8004af <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800538:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053d:	e9 7a ff ff ff       	jmp    8004bc <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	ff 55 08             	call   *0x8(%ebp)
			break;
  800557:	e9 18 ff ff ff       	jmp    800474 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8d 50 04             	lea    0x4(%eax),%edx
  800562:	89 55 14             	mov    %edx,0x14(%ebp)
  800565:	8b 00                	mov    (%eax),%eax
  800567:	99                   	cltd   
  800568:	31 d0                	xor    %edx,%eax
  80056a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056c:	83 f8 09             	cmp    $0x9,%eax
  80056f:	7f 0b                	jg     80057c <vprintfmt+0x12d>
  800571:	8b 14 85 40 1b 80 00 	mov    0x801b40(,%eax,4),%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	75 20                	jne    80059c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80057c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800580:	c7 44 24 08 ca 17 80 	movl   $0x8017ca,0x8(%esp)
  800587:	00 
  800588:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058c:	8b 45 08             	mov    0x8(%ebp),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	e8 90 fe ff ff       	call   800427 <printfmt>
  800597:	e9 d8 fe ff ff       	jmp    800474 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80059c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a0:	c7 44 24 08 d3 17 80 	movl   $0x8017d3,0x8(%esp)
  8005a7:	00 
  8005a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	e8 70 fe ff ff       	call   800427 <printfmt>
  8005b7:	e9 b8 fe ff ff       	jmp    800474 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 04             	lea    0x4(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005d0:	85 f6                	test   %esi,%esi
  8005d2:	b8 c3 17 80 00       	mov    $0x8017c3,%eax
  8005d7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005da:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005de:	0f 84 97 00 00 00    	je     80067b <vprintfmt+0x22c>
  8005e4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005e8:	0f 8e 9b 00 00 00    	jle    800689 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f2:	89 34 24             	mov    %esi,(%esp)
  8005f5:	e8 ce 06 00 00       	call   800cc8 <strnlen>
  8005fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005fd:	29 c2                	sub    %eax,%edx
  8005ff:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800602:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800606:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800609:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80060c:	8b 75 08             	mov    0x8(%ebp),%esi
  80060f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800612:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	eb 0f                	jmp    800625 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800616:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800622:	83 eb 01             	sub    $0x1,%ebx
  800625:	85 db                	test   %ebx,%ebx
  800627:	7f ed                	jg     800616 <vprintfmt+0x1c7>
  800629:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80062f:	85 d2                	test   %edx,%edx
  800631:	b8 00 00 00 00       	mov    $0x0,%eax
  800636:	0f 49 c2             	cmovns %edx,%eax
  800639:	29 c2                	sub    %eax,%edx
  80063b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80063e:	89 d7                	mov    %edx,%edi
  800640:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800643:	eb 50                	jmp    800695 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800645:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800649:	74 1e                	je     800669 <vprintfmt+0x21a>
  80064b:	0f be d2             	movsbl %dl,%edx
  80064e:	83 ea 20             	sub    $0x20,%edx
  800651:	83 fa 5e             	cmp    $0x5e,%edx
  800654:	76 13                	jbe    800669 <vprintfmt+0x21a>
					putch('?', putdat);
  800656:	8b 45 0c             	mov    0xc(%ebp),%eax
  800659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800664:	ff 55 08             	call   *0x8(%ebp)
  800667:	eb 0d                	jmp    800676 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800669:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800670:	89 04 24             	mov    %eax,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800676:	83 ef 01             	sub    $0x1,%edi
  800679:	eb 1a                	jmp    800695 <vprintfmt+0x246>
  80067b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80067e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800681:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800684:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800687:	eb 0c                	jmp    800695 <vprintfmt+0x246>
  800689:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80068c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80068f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800692:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800695:	83 c6 01             	add    $0x1,%esi
  800698:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80069c:	0f be c2             	movsbl %dl,%eax
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	74 27                	je     8006ca <vprintfmt+0x27b>
  8006a3:	85 db                	test   %ebx,%ebx
  8006a5:	78 9e                	js     800645 <vprintfmt+0x1f6>
  8006a7:	83 eb 01             	sub    $0x1,%ebx
  8006aa:	79 99                	jns    800645 <vprintfmt+0x1f6>
  8006ac:	89 f8                	mov    %edi,%eax
  8006ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b4:	89 c3                	mov    %eax,%ebx
  8006b6:	eb 1a                	jmp    8006d2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006bc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c5:	83 eb 01             	sub    $0x1,%ebx
  8006c8:	eb 08                	jmp    8006d2 <vprintfmt+0x283>
  8006ca:	89 fb                	mov    %edi,%ebx
  8006cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006d2:	85 db                	test   %ebx,%ebx
  8006d4:	7f e2                	jg     8006b8 <vprintfmt+0x269>
  8006d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006dc:	e9 93 fd ff ff       	jmp    800474 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e1:	83 fa 01             	cmp    $0x1,%edx
  8006e4:	7e 16                	jle    8006fc <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 50 08             	lea    0x8(%eax),%edx
  8006ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ef:	8b 50 04             	mov    0x4(%eax),%edx
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006fa:	eb 32                	jmp    80072e <vprintfmt+0x2df>
	else if (lflag)
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	74 18                	je     800718 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8d 50 04             	lea    0x4(%eax),%edx
  800706:	89 55 14             	mov    %edx,0x14(%ebp)
  800709:	8b 30                	mov    (%eax),%esi
  80070b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80070e:	89 f0                	mov    %esi,%eax
  800710:	c1 f8 1f             	sar    $0x1f,%eax
  800713:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800716:	eb 16                	jmp    80072e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)
  800721:	8b 30                	mov    (%eax),%esi
  800723:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800726:	89 f0                	mov    %esi,%eax
  800728:	c1 f8 1f             	sar    $0x1f,%eax
  80072b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800731:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800734:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800739:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073d:	0f 89 80 00 00 00    	jns    8007c3 <vprintfmt+0x374>
				putch('-', putdat);
  800743:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800747:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800751:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800754:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800757:	f7 d8                	neg    %eax
  800759:	83 d2 00             	adc    $0x0,%edx
  80075c:	f7 da                	neg    %edx
			}
			base = 10;
  80075e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800763:	eb 5e                	jmp    8007c3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800765:	8d 45 14             	lea    0x14(%ebp),%eax
  800768:	e8 63 fc ff ff       	call   8003d0 <getuint>
			base = 10;
  80076d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800772:	eb 4f                	jmp    8007c3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800774:	8d 45 14             	lea    0x14(%ebp),%eax
  800777:	e8 54 fc ff ff       	call   8003d0 <getuint>
			base = 8 ;
  80077c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800781:	eb 40                	jmp    8007c3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800783:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800787:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80078e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800791:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800795:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80079c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 50 04             	lea    0x4(%eax),%edx
  8007a5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a8:	8b 00                	mov    (%eax),%eax
  8007aa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007af:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007b4:	eb 0d                	jmp    8007c3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 12 fc ff ff       	call   8003d0 <getuint>
			base = 16;
  8007be:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007c7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007cb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007d2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007d6:	89 04 24             	mov    %eax,(%esp)
  8007d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007dd:	89 fa                	mov    %edi,%edx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	e8 f9 f9 ff ff       	call   8001e0 <printnum>
			break;
  8007e7:	e9 88 fc ff ff       	jmp    800474 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007f6:	e9 79 fc ff ff       	jmp    800474 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800806:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800809:	89 f3                	mov    %esi,%ebx
  80080b:	eb 03                	jmp    800810 <vprintfmt+0x3c1>
  80080d:	83 eb 01             	sub    $0x1,%ebx
  800810:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800814:	75 f7                	jne    80080d <vprintfmt+0x3be>
  800816:	e9 59 fc ff ff       	jmp    800474 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80081b:	83 c4 3c             	add    $0x3c,%esp
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5f                   	pop    %edi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	57                   	push   %edi
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	83 ec 3c             	sub    $0x3c,%esp
  80082c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  80082f:	8b 45 14             	mov    0x14(%ebp),%eax
  800832:	8d 50 04             	lea    0x4(%eax),%edx
  800835:	89 55 14             	mov    %edx,0x14(%ebp)
  800838:	8b 00                	mov    (%eax),%eax
  80083a:	c1 e0 08             	shl    $0x8,%eax
  80083d:	0f b7 c0             	movzwl %ax,%eax
  800840:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800843:	83 c8 25             	or     $0x25,%eax
  800846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800849:	eb 1a                	jmp    800865 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80084b:	85 c0                	test   %eax,%eax
  80084d:	0f 84 a9 03 00 00    	je     800bfc <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800853:	8b 75 0c             	mov    0xc(%ebp),%esi
  800856:	89 74 24 04          	mov    %esi,0x4(%esp)
  80085a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80085d:	89 04 24             	mov    %eax,(%esp)
  800860:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800863:	89 fb                	mov    %edi,%ebx
  800865:	8d 7b 01             	lea    0x1(%ebx),%edi
  800868:	0f b6 03             	movzbl (%ebx),%eax
  80086b:	83 f8 25             	cmp    $0x25,%eax
  80086e:	75 db                	jne    80084b <cvprintfmt+0x28>
  800870:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800874:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80087b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800880:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800887:	ba 00 00 00 00       	mov    $0x0,%edx
  80088c:	eb 18                	jmp    8008a6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800890:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800894:	eb 10                	jmp    8008a6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800896:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800898:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80089c:	eb 08                	jmp    8008a6 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80089e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8008a1:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	8d 5f 01             	lea    0x1(%edi),%ebx
  8008a9:	0f b6 0f             	movzbl (%edi),%ecx
  8008ac:	0f b6 c1             	movzbl %cl,%eax
  8008af:	83 e9 23             	sub    $0x23,%ecx
  8008b2:	80 f9 55             	cmp    $0x55,%cl
  8008b5:	0f 87 1f 03 00 00    	ja     800bda <cvprintfmt+0x3b7>
  8008bb:	0f b6 c9             	movzbl %cl,%ecx
  8008be:	ff 24 8d d8 19 80 00 	jmp    *0x8019d8(,%ecx,4)
  8008c5:	89 df                	mov    %ebx,%edi
  8008c7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008cc:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  8008cf:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  8008d3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8008d6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008d9:	83 f9 09             	cmp    $0x9,%ecx
  8008dc:	77 33                	ja     800911 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008e1:	eb e9                	jmp    8008cc <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8008e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008ec:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ee:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008f0:	eb 1f                	jmp    800911 <cvprintfmt+0xee>
  8008f2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8008f5:	85 ff                	test   %edi,%edi
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fc:	0f 49 c7             	cmovns %edi,%eax
  8008ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800902:	89 df                	mov    %ebx,%edi
  800904:	eb a0                	jmp    8008a6 <cvprintfmt+0x83>
  800906:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800908:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80090f:	eb 95                	jmp    8008a6 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800911:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800915:	79 8f                	jns    8008a6 <cvprintfmt+0x83>
  800917:	eb 85                	jmp    80089e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800919:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80091e:	66 90                	xchg   %ax,%ax
  800920:	eb 84                	jmp    8008a6 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8d 50 04             	lea    0x4(%eax),%edx
  800928:	89 55 14             	mov    %edx,0x14(%ebp)
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800932:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800935:	0b 10                	or     (%eax),%edx
  800937:	89 14 24             	mov    %edx,(%esp)
  80093a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80093d:	e9 23 ff ff ff       	jmp    800865 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 50 04             	lea    0x4(%eax),%edx
  800948:	89 55 14             	mov    %edx,0x14(%ebp)
  80094b:	8b 00                	mov    (%eax),%eax
  80094d:	99                   	cltd   
  80094e:	31 d0                	xor    %edx,%eax
  800950:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800952:	83 f8 09             	cmp    $0x9,%eax
  800955:	7f 0b                	jg     800962 <cvprintfmt+0x13f>
  800957:	8b 14 85 40 1b 80 00 	mov    0x801b40(,%eax,4),%edx
  80095e:	85 d2                	test   %edx,%edx
  800960:	75 23                	jne    800985 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800962:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800966:	c7 44 24 08 ca 17 80 	movl   $0x8017ca,0x8(%esp)
  80096d:	00 
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	89 44 24 04          	mov    %eax,0x4(%esp)
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	89 04 24             	mov    %eax,(%esp)
  80097b:	e8 a7 fa ff ff       	call   800427 <printfmt>
  800980:	e9 e0 fe ff ff       	jmp    800865 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800985:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800989:	c7 44 24 08 d3 17 80 	movl   $0x8017d3,0x8(%esp)
  800990:	00 
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	89 44 24 04          	mov    %eax,0x4(%esp)
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	89 04 24             	mov    %eax,(%esp)
  80099e:	e8 84 fa ff ff       	call   800427 <printfmt>
  8009a3:	e9 bd fe ff ff       	jmp    800865 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  8009ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b1:	8d 48 04             	lea    0x4(%eax),%ecx
  8009b4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8009b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009b9:	85 ff                	test   %edi,%edi
  8009bb:	b8 c3 17 80 00       	mov    $0x8017c3,%eax
  8009c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009c3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009c7:	74 61                	je     800a2a <cvprintfmt+0x207>
  8009c9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8009cd:	7e 5b                	jle    800a2a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009d3:	89 3c 24             	mov    %edi,(%esp)
  8009d6:	e8 ed 02 00 00       	call   800cc8 <strnlen>
  8009db:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009de:	29 c2                	sub    %eax,%edx
  8009e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  8009e3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009e7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8009ea:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8009ed:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009f6:	89 d3                	mov    %edx,%ebx
  8009f8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009fa:	eb 0f                	jmp    800a0b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  8009fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a03:	89 3c 24             	mov    %edi,(%esp)
  800a06:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a08:	83 eb 01             	sub    $0x1,%ebx
  800a0b:	85 db                	test   %ebx,%ebx
  800a0d:	7f ed                	jg     8009fc <cvprintfmt+0x1d9>
  800a0f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a12:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a18:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a1b:	85 d2                	test   %edx,%edx
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a22:	0f 49 c2             	cmovns %edx,%eax
  800a25:	29 c2                	sub    %eax,%edx
  800a27:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800a2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a2d:	83 c8 3f             	or     $0x3f,%eax
  800a30:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a33:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a36:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800a39:	eb 36                	jmp    800a71 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a3b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a3f:	74 1d                	je     800a5e <cvprintfmt+0x23b>
  800a41:	0f be d2             	movsbl %dl,%edx
  800a44:	83 ea 20             	sub    $0x20,%edx
  800a47:	83 fa 5e             	cmp    $0x5e,%edx
  800a4a:	76 12                	jbe    800a5e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a53:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a56:	89 04 24             	mov    %eax,(%esp)
  800a59:	ff 55 08             	call   *0x8(%ebp)
  800a5c:	eb 10                	jmp    800a6e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a65:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a68:	89 04 24             	mov    %eax,(%esp)
  800a6b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a6e:	83 eb 01             	sub    $0x1,%ebx
  800a71:	83 c7 01             	add    $0x1,%edi
  800a74:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a78:	0f be c2             	movsbl %dl,%eax
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	74 27                	je     800aa6 <cvprintfmt+0x283>
  800a7f:	85 f6                	test   %esi,%esi
  800a81:	78 b8                	js     800a3b <cvprintfmt+0x218>
  800a83:	83 ee 01             	sub    $0x1,%esi
  800a86:	79 b3                	jns    800a3b <cvprintfmt+0x218>
  800a88:	89 d8                	mov    %ebx,%eax
  800a8a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a90:	89 c3                	mov    %eax,%ebx
  800a92:	eb 18                	jmp    800aac <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800a94:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a9f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800aa1:	83 eb 01             	sub    $0x1,%ebx
  800aa4:	eb 06                	jmp    800aac <cvprintfmt+0x289>
  800aa6:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	7f e4                	jg     800a94 <cvprintfmt+0x271>
  800ab0:	89 75 08             	mov    %esi,0x8(%ebp)
  800ab3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ab6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ab9:	e9 a7 fd ff ff       	jmp    800865 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800abe:	83 fa 01             	cmp    $0x1,%edx
  800ac1:	7e 10                	jle    800ad3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800ac3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac6:	8d 50 08             	lea    0x8(%eax),%edx
  800ac9:	89 55 14             	mov    %edx,0x14(%ebp)
  800acc:	8b 30                	mov    (%eax),%esi
  800ace:	8b 78 04             	mov    0x4(%eax),%edi
  800ad1:	eb 26                	jmp    800af9 <cvprintfmt+0x2d6>
	else if (lflag)
  800ad3:	85 d2                	test   %edx,%edx
  800ad5:	74 12                	je     800ae9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800ad7:	8b 45 14             	mov    0x14(%ebp),%eax
  800ada:	8d 50 04             	lea    0x4(%eax),%edx
  800add:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae0:	8b 30                	mov    (%eax),%esi
  800ae2:	89 f7                	mov    %esi,%edi
  800ae4:	c1 ff 1f             	sar    $0x1f,%edi
  800ae7:	eb 10                	jmp    800af9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800ae9:	8b 45 14             	mov    0x14(%ebp),%eax
  800aec:	8d 50 04             	lea    0x4(%eax),%edx
  800aef:	89 55 14             	mov    %edx,0x14(%ebp)
  800af2:	8b 30                	mov    (%eax),%esi
  800af4:	89 f7                	mov    %esi,%edi
  800af6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800af9:	89 f0                	mov    %esi,%eax
  800afb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800afd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b02:	85 ff                	test   %edi,%edi
  800b04:	0f 89 8e 00 00 00    	jns    800b98 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b14:	83 c8 2d             	or     $0x2d,%eax
  800b17:	89 04 24             	mov    %eax,(%esp)
  800b1a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b1d:	89 f0                	mov    %esi,%eax
  800b1f:	89 fa                	mov    %edi,%edx
  800b21:	f7 d8                	neg    %eax
  800b23:	83 d2 00             	adc    $0x0,%edx
  800b26:	f7 da                	neg    %edx
			}
			base = 10;
  800b28:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b2d:	eb 69                	jmp    800b98 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b2f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b32:	e8 99 f8 ff ff       	call   8003d0 <getuint>
			base = 10;
  800b37:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b3c:	eb 5a                	jmp    800b98 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b3e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b41:	e8 8a f8 ff ff       	call   8003d0 <getuint>
			base = 8 ;
  800b46:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800b4b:	eb 4b                	jmp    800b98 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b54:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800b57:	89 f0                	mov    %esi,%eax
  800b59:	83 c8 30             	or     $0x30,%eax
  800b5c:	89 04 24             	mov    %eax,(%esp)
  800b5f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b69:	89 f0                	mov    %esi,%eax
  800b6b:	83 c8 78             	or     $0x78,%eax
  800b6e:	89 04 24             	mov    %eax,(%esp)
  800b71:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b74:	8b 45 14             	mov    0x14(%ebp),%eax
  800b77:	8d 50 04             	lea    0x4(%eax),%edx
  800b7a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800b7d:	8b 00                	mov    (%eax),%eax
  800b7f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b84:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b89:	eb 0d                	jmp    800b98 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b8b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b8e:	e8 3d f8 ff ff       	call   8003d0 <getuint>
			base = 16;
  800b93:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800b98:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800b9c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ba0:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800ba3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ba7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bab:	89 04 24             	mov    %eax,(%esp)
  800bae:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bbb:	e8 0f f7 ff ff       	call   8002cf <cprintnum>
			break;
  800bc0:	e9 a0 fc ff ff       	jmp    800865 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800bc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bcc:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800bcf:	89 04 24             	mov    %eax,(%esp)
  800bd2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800bd5:	e9 8b fc ff ff       	jmp    800865 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800be4:	89 04 24             	mov    %eax,(%esp)
  800be7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bea:	89 fb                	mov    %edi,%ebx
  800bec:	eb 03                	jmp    800bf1 <cvprintfmt+0x3ce>
  800bee:	83 eb 01             	sub    $0x1,%ebx
  800bf1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800bf5:	75 f7                	jne    800bee <cvprintfmt+0x3cb>
  800bf7:	e9 69 fc ff ff       	jmp    800865 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800bfc:	83 c4 3c             	add    $0x3c,%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800c0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c11:	8b 45 10             	mov    0x10(%ebp),%eax
  800c14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c22:	89 04 24             	mov    %eax,(%esp)
  800c25:	e8 f9 fb ff ff       	call   800823 <cvprintfmt>
	va_end(ap);
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 28             	sub    $0x28,%esp
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c38:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c3b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c3f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	74 30                	je     800c7d <vsnprintf+0x51>
  800c4d:	85 d2                	test   %edx,%edx
  800c4f:	7e 2c                	jle    800c7d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c51:	8b 45 14             	mov    0x14(%ebp),%eax
  800c54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c58:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c66:	c7 04 24 0a 04 80 00 	movl   $0x80040a,(%esp)
  800c6d:	e8 dd f7 ff ff       	call   80044f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c75:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7b:	eb 05                	jmp    800c82 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c8a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c91:	8b 45 10             	mov    0x10(%ebp),%eax
  800c94:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca2:	89 04 24             	mov    %eax,(%esp)
  800ca5:	e8 82 ff ff ff       	call   800c2c <vsnprintf>
	va_end(ap);

	return rc;
}
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    
  800cac:	66 90                	xchg   %ax,%ax
  800cae:	66 90                	xchg   %ax,%ax

00800cb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbb:	eb 03                	jmp    800cc0 <strlen+0x10>
		n++;
  800cbd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cc0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cc4:	75 f7                	jne    800cbd <strlen+0xd>
		n++;
	return n;
}
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd6:	eb 03                	jmp    800cdb <strnlen+0x13>
		n++;
  800cd8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cdb:	39 d0                	cmp    %edx,%eax
  800cdd:	74 06                	je     800ce5 <strnlen+0x1d>
  800cdf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ce3:	75 f3                	jne    800cd8 <strnlen+0x10>
		n++;
	return n;
}
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	53                   	push   %ebx
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cf1:	89 c2                	mov    %eax,%edx
  800cf3:	83 c2 01             	add    $0x1,%edx
  800cf6:	83 c1 01             	add    $0x1,%ecx
  800cf9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cfd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d00:	84 db                	test   %bl,%bl
  800d02:	75 ef                	jne    800cf3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d04:	5b                   	pop    %ebx
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	53                   	push   %ebx
  800d0b:	83 ec 08             	sub    $0x8,%esp
  800d0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d11:	89 1c 24             	mov    %ebx,(%esp)
  800d14:	e8 97 ff ff ff       	call   800cb0 <strlen>
	strcpy(dst + len, src);
  800d19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d1c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d20:	01 d8                	add    %ebx,%eax
  800d22:	89 04 24             	mov    %eax,(%esp)
  800d25:	e8 bd ff ff ff       	call   800ce7 <strcpy>
	return dst;
}
  800d2a:	89 d8                	mov    %ebx,%eax
  800d2c:	83 c4 08             	add    $0x8,%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	8b 75 08             	mov    0x8(%ebp),%esi
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	89 f3                	mov    %esi,%ebx
  800d3f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d42:	89 f2                	mov    %esi,%edx
  800d44:	eb 0f                	jmp    800d55 <strncpy+0x23>
		*dst++ = *src;
  800d46:	83 c2 01             	add    $0x1,%edx
  800d49:	0f b6 01             	movzbl (%ecx),%eax
  800d4c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d4f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d52:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d55:	39 da                	cmp    %ebx,%edx
  800d57:	75 ed                	jne    800d46 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d59:	89 f0                	mov    %esi,%eax
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	8b 75 08             	mov    0x8(%ebp),%esi
  800d67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d6d:	89 f0                	mov    %esi,%eax
  800d6f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d73:	85 c9                	test   %ecx,%ecx
  800d75:	75 0b                	jne    800d82 <strlcpy+0x23>
  800d77:	eb 1d                	jmp    800d96 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d79:	83 c0 01             	add    $0x1,%eax
  800d7c:	83 c2 01             	add    $0x1,%edx
  800d7f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d82:	39 d8                	cmp    %ebx,%eax
  800d84:	74 0b                	je     800d91 <strlcpy+0x32>
  800d86:	0f b6 0a             	movzbl (%edx),%ecx
  800d89:	84 c9                	test   %cl,%cl
  800d8b:	75 ec                	jne    800d79 <strlcpy+0x1a>
  800d8d:	89 c2                	mov    %eax,%edx
  800d8f:	eb 02                	jmp    800d93 <strlcpy+0x34>
  800d91:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d93:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d96:	29 f0                	sub    %esi,%eax
}
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800da5:	eb 06                	jmp    800dad <strcmp+0x11>
		p++, q++;
  800da7:	83 c1 01             	add    $0x1,%ecx
  800daa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dad:	0f b6 01             	movzbl (%ecx),%eax
  800db0:	84 c0                	test   %al,%al
  800db2:	74 04                	je     800db8 <strcmp+0x1c>
  800db4:	3a 02                	cmp    (%edx),%al
  800db6:	74 ef                	je     800da7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800db8:	0f b6 c0             	movzbl %al,%eax
  800dbb:	0f b6 12             	movzbl (%edx),%edx
  800dbe:	29 d0                	sub    %edx,%eax
}
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	53                   	push   %ebx
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcc:	89 c3                	mov    %eax,%ebx
  800dce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dd1:	eb 06                	jmp    800dd9 <strncmp+0x17>
		n--, p++, q++;
  800dd3:	83 c0 01             	add    $0x1,%eax
  800dd6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dd9:	39 d8                	cmp    %ebx,%eax
  800ddb:	74 15                	je     800df2 <strncmp+0x30>
  800ddd:	0f b6 08             	movzbl (%eax),%ecx
  800de0:	84 c9                	test   %cl,%cl
  800de2:	74 04                	je     800de8 <strncmp+0x26>
  800de4:	3a 0a                	cmp    (%edx),%cl
  800de6:	74 eb                	je     800dd3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800de8:	0f b6 00             	movzbl (%eax),%eax
  800deb:	0f b6 12             	movzbl (%edx),%edx
  800dee:	29 d0                	sub    %edx,%eax
  800df0:	eb 05                	jmp    800df7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800df7:	5b                   	pop    %ebx
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e04:	eb 07                	jmp    800e0d <strchr+0x13>
		if (*s == c)
  800e06:	38 ca                	cmp    %cl,%dl
  800e08:	74 0f                	je     800e19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e0a:	83 c0 01             	add    $0x1,%eax
  800e0d:	0f b6 10             	movzbl (%eax),%edx
  800e10:	84 d2                	test   %dl,%dl
  800e12:	75 f2                	jne    800e06 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e25:	eb 07                	jmp    800e2e <strfind+0x13>
		if (*s == c)
  800e27:	38 ca                	cmp    %cl,%dl
  800e29:	74 0a                	je     800e35 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e2b:	83 c0 01             	add    $0x1,%eax
  800e2e:	0f b6 10             	movzbl (%eax),%edx
  800e31:	84 d2                	test   %dl,%dl
  800e33:	75 f2                	jne    800e27 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
  800e3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e43:	85 c9                	test   %ecx,%ecx
  800e45:	74 36                	je     800e7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e4d:	75 28                	jne    800e77 <memset+0x40>
  800e4f:	f6 c1 03             	test   $0x3,%cl
  800e52:	75 23                	jne    800e77 <memset+0x40>
		c &= 0xFF;
  800e54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e58:	89 d3                	mov    %edx,%ebx
  800e5a:	c1 e3 08             	shl    $0x8,%ebx
  800e5d:	89 d6                	mov    %edx,%esi
  800e5f:	c1 e6 18             	shl    $0x18,%esi
  800e62:	89 d0                	mov    %edx,%eax
  800e64:	c1 e0 10             	shl    $0x10,%eax
  800e67:	09 f0                	or     %esi,%eax
  800e69:	09 c2                	or     %eax,%edx
  800e6b:	89 d0                	mov    %edx,%eax
  800e6d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e6f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e72:	fc                   	cld    
  800e73:	f3 ab                	rep stos %eax,%es:(%edi)
  800e75:	eb 06                	jmp    800e7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7a:	fc                   	cld    
  800e7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e7d:	89 f8                	mov    %edi,%eax
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e92:	39 c6                	cmp    %eax,%esi
  800e94:	73 35                	jae    800ecb <memmove+0x47>
  800e96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e99:	39 d0                	cmp    %edx,%eax
  800e9b:	73 2e                	jae    800ecb <memmove+0x47>
		s += n;
		d += n;
  800e9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ea0:	89 d6                	mov    %edx,%esi
  800ea2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eaa:	75 13                	jne    800ebf <memmove+0x3b>
  800eac:	f6 c1 03             	test   $0x3,%cl
  800eaf:	75 0e                	jne    800ebf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eb1:	83 ef 04             	sub    $0x4,%edi
  800eb4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eb7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eba:	fd                   	std    
  800ebb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ebd:	eb 09                	jmp    800ec8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ebf:	83 ef 01             	sub    $0x1,%edi
  800ec2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ec5:	fd                   	std    
  800ec6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ec8:	fc                   	cld    
  800ec9:	eb 1d                	jmp    800ee8 <memmove+0x64>
  800ecb:	89 f2                	mov    %esi,%edx
  800ecd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ecf:	f6 c2 03             	test   $0x3,%dl
  800ed2:	75 0f                	jne    800ee3 <memmove+0x5f>
  800ed4:	f6 c1 03             	test   $0x3,%cl
  800ed7:	75 0a                	jne    800ee3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ed9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800edc:	89 c7                	mov    %eax,%edi
  800ede:	fc                   	cld    
  800edf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ee1:	eb 05                	jmp    800ee8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ee3:	89 c7                	mov    %eax,%edi
  800ee5:	fc                   	cld    
  800ee6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ef2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f00:	8b 45 08             	mov    0x8(%ebp),%eax
  800f03:	89 04 24             	mov    %eax,(%esp)
  800f06:	e8 79 ff ff ff       	call   800e84 <memmove>
}
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	8b 55 08             	mov    0x8(%ebp),%edx
  800f15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f18:	89 d6                	mov    %edx,%esi
  800f1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f1d:	eb 1a                	jmp    800f39 <memcmp+0x2c>
		if (*s1 != *s2)
  800f1f:	0f b6 02             	movzbl (%edx),%eax
  800f22:	0f b6 19             	movzbl (%ecx),%ebx
  800f25:	38 d8                	cmp    %bl,%al
  800f27:	74 0a                	je     800f33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f29:	0f b6 c0             	movzbl %al,%eax
  800f2c:	0f b6 db             	movzbl %bl,%ebx
  800f2f:	29 d8                	sub    %ebx,%eax
  800f31:	eb 0f                	jmp    800f42 <memcmp+0x35>
		s1++, s2++;
  800f33:	83 c2 01             	add    $0x1,%edx
  800f36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f39:	39 f2                	cmp    %esi,%edx
  800f3b:	75 e2                	jne    800f1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f4f:	89 c2                	mov    %eax,%edx
  800f51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f54:	eb 07                	jmp    800f5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f56:	38 08                	cmp    %cl,(%eax)
  800f58:	74 07                	je     800f61 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f5a:	83 c0 01             	add    $0x1,%eax
  800f5d:	39 d0                	cmp    %edx,%eax
  800f5f:	72 f5                	jb     800f56 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f6f:	eb 03                	jmp    800f74 <strtol+0x11>
		s++;
  800f71:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f74:	0f b6 0a             	movzbl (%edx),%ecx
  800f77:	80 f9 09             	cmp    $0x9,%cl
  800f7a:	74 f5                	je     800f71 <strtol+0xe>
  800f7c:	80 f9 20             	cmp    $0x20,%cl
  800f7f:	74 f0                	je     800f71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f81:	80 f9 2b             	cmp    $0x2b,%cl
  800f84:	75 0a                	jne    800f90 <strtol+0x2d>
		s++;
  800f86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f89:	bf 00 00 00 00       	mov    $0x0,%edi
  800f8e:	eb 11                	jmp    800fa1 <strtol+0x3e>
  800f90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f95:	80 f9 2d             	cmp    $0x2d,%cl
  800f98:	75 07                	jne    800fa1 <strtol+0x3e>
		s++, neg = 1;
  800f9a:	8d 52 01             	lea    0x1(%edx),%edx
  800f9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fa1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800fa6:	75 15                	jne    800fbd <strtol+0x5a>
  800fa8:	80 3a 30             	cmpb   $0x30,(%edx)
  800fab:	75 10                	jne    800fbd <strtol+0x5a>
  800fad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fb1:	75 0a                	jne    800fbd <strtol+0x5a>
		s += 2, base = 16;
  800fb3:	83 c2 02             	add    $0x2,%edx
  800fb6:	b8 10 00 00 00       	mov    $0x10,%eax
  800fbb:	eb 10                	jmp    800fcd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	75 0c                	jne    800fcd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fc1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800fc6:	75 05                	jne    800fcd <strtol+0x6a>
		s++, base = 8;
  800fc8:	83 c2 01             	add    $0x1,%edx
  800fcb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800fcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fd5:	0f b6 0a             	movzbl (%edx),%ecx
  800fd8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800fdb:	89 f0                	mov    %esi,%eax
  800fdd:	3c 09                	cmp    $0x9,%al
  800fdf:	77 08                	ja     800fe9 <strtol+0x86>
			dig = *s - '0';
  800fe1:	0f be c9             	movsbl %cl,%ecx
  800fe4:	83 e9 30             	sub    $0x30,%ecx
  800fe7:	eb 20                	jmp    801009 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800fe9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800fec:	89 f0                	mov    %esi,%eax
  800fee:	3c 19                	cmp    $0x19,%al
  800ff0:	77 08                	ja     800ffa <strtol+0x97>
			dig = *s - 'a' + 10;
  800ff2:	0f be c9             	movsbl %cl,%ecx
  800ff5:	83 e9 57             	sub    $0x57,%ecx
  800ff8:	eb 0f                	jmp    801009 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800ffa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ffd:	89 f0                	mov    %esi,%eax
  800fff:	3c 19                	cmp    $0x19,%al
  801001:	77 16                	ja     801019 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801003:	0f be c9             	movsbl %cl,%ecx
  801006:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801009:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80100c:	7d 0f                	jge    80101d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80100e:	83 c2 01             	add    $0x1,%edx
  801011:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801015:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801017:	eb bc                	jmp    800fd5 <strtol+0x72>
  801019:	89 d8                	mov    %ebx,%eax
  80101b:	eb 02                	jmp    80101f <strtol+0xbc>
  80101d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80101f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801023:	74 05                	je     80102a <strtol+0xc7>
		*endptr = (char *) s;
  801025:	8b 75 0c             	mov    0xc(%ebp),%esi
  801028:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80102a:	f7 d8                	neg    %eax
  80102c:	85 ff                	test   %edi,%edi
  80102e:	0f 44 c3             	cmove  %ebx,%eax
}
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	89 c3                	mov    %eax,%ebx
  801049:	89 c7                	mov    %eax,%edi
  80104b:	89 c6                	mov    %eax,%esi
  80104d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_cgetc>:

int
sys_cgetc(void)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105a:	ba 00 00 00 00       	mov    $0x0,%edx
  80105f:	b8 01 00 00 00       	mov    $0x1,%eax
  801064:	89 d1                	mov    %edx,%ecx
  801066:	89 d3                	mov    %edx,%ebx
  801068:	89 d7                	mov    %edx,%edi
  80106a:	89 d6                	mov    %edx,%esi
  80106c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80106e:	5b                   	pop    %ebx
  80106f:	5e                   	pop    %esi
  801070:	5f                   	pop    %edi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801081:	b8 03 00 00 00       	mov    $0x3,%eax
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	89 cb                	mov    %ecx,%ebx
  80108b:	89 cf                	mov    %ecx,%edi
  80108d:	89 ce                	mov    %ecx,%esi
  80108f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801091:	85 c0                	test   %eax,%eax
  801093:	7e 28                	jle    8010bd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801095:	89 44 24 10          	mov    %eax,0x10(%esp)
  801099:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  8010b8:	e8 c9 03 00 00       	call   801486 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010bd:	83 c4 2c             	add    $0x2c,%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5f                   	pop    %edi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8010d5:	89 d1                	mov    %edx,%ecx
  8010d7:	89 d3                	mov    %edx,%ebx
  8010d9:	89 d7                	mov    %edx,%edi
  8010db:	89 d6                	mov    %edx,%esi
  8010dd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <sys_yield>:

void
sys_yield(void)
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
  8010ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010f4:	89 d1                	mov    %edx,%ecx
  8010f6:	89 d3                	mov    %edx,%ebx
  8010f8:	89 d7                	mov    %edx,%edi
  8010fa:	89 d6                	mov    %edx,%esi
  8010fc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5f                   	pop    %edi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    

00801103 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  80110c:	be 00 00 00 00       	mov    $0x0,%esi
  801111:	b8 04 00 00 00       	mov    $0x4,%eax
  801116:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801119:	8b 55 08             	mov    0x8(%ebp),%edx
  80111c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80111f:	89 f7                	mov    %esi,%edi
  801121:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801123:	85 c0                	test   %eax,%eax
  801125:	7e 28                	jle    80114f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801127:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801132:	00 
  801133:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  80113a:	00 
  80113b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801142:	00 
  801143:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  80114a:	e8 37 03 00 00       	call   801486 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80114f:	83 c4 2c             	add    $0x2c,%esp
  801152:	5b                   	pop    %ebx
  801153:	5e                   	pop    %esi
  801154:	5f                   	pop    %edi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801160:	b8 05 00 00 00       	mov    $0x5,%eax
  801165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801168:	8b 55 08             	mov    0x8(%ebp),%edx
  80116b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80116e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801171:	8b 75 18             	mov    0x18(%ebp),%esi
  801174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801176:	85 c0                	test   %eax,%eax
  801178:	7e 28                	jle    8011a2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801185:	00 
  801186:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  80118d:	00 
  80118e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801195:	00 
  801196:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  80119d:	e8 e4 02 00 00       	call   801486 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011a2:	83 c4 2c             	add    $0x2c,%esp
  8011a5:	5b                   	pop    %ebx
  8011a6:	5e                   	pop    %esi
  8011a7:	5f                   	pop    %edi
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	57                   	push   %edi
  8011ae:	56                   	push   %esi
  8011af:	53                   	push   %ebx
  8011b0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8011bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c3:	89 df                	mov    %ebx,%edi
  8011c5:	89 de                	mov    %ebx,%esi
  8011c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	7e 28                	jle    8011f5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011d8:	00 
  8011d9:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  8011e0:	00 
  8011e1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011e8:	00 
  8011e9:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  8011f0:	e8 91 02 00 00       	call   801486 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011f5:	83 c4 2c             	add    $0x2c,%esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	57                   	push   %edi
  801201:	56                   	push   %esi
  801202:	53                   	push   %ebx
  801203:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801206:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120b:	b8 08 00 00 00       	mov    $0x8,%eax
  801210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801213:	8b 55 08             	mov    0x8(%ebp),%edx
  801216:	89 df                	mov    %ebx,%edi
  801218:	89 de                	mov    %ebx,%esi
  80121a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80121c:	85 c0                	test   %eax,%eax
  80121e:	7e 28                	jle    801248 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801220:	89 44 24 10          	mov    %eax,0x10(%esp)
  801224:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80122b:	00 
  80122c:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  801233:	00 
  801234:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80123b:	00 
  80123c:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  801243:	e8 3e 02 00 00       	call   801486 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801248:	83 c4 2c             	add    $0x2c,%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801259:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125e:	b8 09 00 00 00       	mov    $0x9,%eax
  801263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801266:	8b 55 08             	mov    0x8(%ebp),%edx
  801269:	89 df                	mov    %ebx,%edi
  80126b:	89 de                	mov    %ebx,%esi
  80126d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80126f:	85 c0                	test   %eax,%eax
  801271:	7e 28                	jle    80129b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801273:	89 44 24 10          	mov    %eax,0x10(%esp)
  801277:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80127e:	00 
  80127f:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  801286:	00 
  801287:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80128e:	00 
  80128f:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  801296:	e8 eb 01 00 00       	call   801486 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80129b:	83 c4 2c             	add    $0x2c,%esp
  80129e:	5b                   	pop    %ebx
  80129f:	5e                   	pop    %esi
  8012a0:	5f                   	pop    %edi
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	57                   	push   %edi
  8012a7:	56                   	push   %esi
  8012a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a9:	be 00 00 00 00       	mov    $0x0,%esi
  8012ae:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012bf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5f                   	pop    %edi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	57                   	push   %edi
  8012ca:	56                   	push   %esi
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012d4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012dc:	89 cb                	mov    %ecx,%ebx
  8012de:	89 cf                	mov    %ecx,%edi
  8012e0:	89 ce                	mov    %ecx,%esi
  8012e2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	7e 28                	jle    801310 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ec:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8012f3:	00 
  8012f4:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  8012fb:	00 
  8012fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801303:	00 
  801304:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  80130b:	e8 76 01 00 00       	call   801486 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801310:	83 c4 2c             	add    $0x2c,%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    
  801318:	66 90                	xchg   %ax,%ax
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	83 ec 10             	sub    $0x10,%esp
  801328:	8b 75 08             	mov    0x8(%ebp),%esi
  80132b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int result = 0 ; 
	if ( pg ) result = sys_ipc_recv(pg);	
  801331:	85 c0                	test   %eax,%eax
  801333:	74 0a                	je     80133f <ipc_recv+0x1f>
  801335:	89 04 24             	mov    %eax,(%esp)
  801338:	e8 89 ff ff ff       	call   8012c6 <sys_ipc_recv>
  80133d:	eb 0c                	jmp    80134b <ipc_recv+0x2b>
	     else result = sys_ipc_recv((void*)UTOP);
  80133f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801346:	e8 7b ff ff ff       	call   8012c6 <sys_ipc_recv>
	if ( result < 0 ) {
  80134b:	85 c0                	test   %eax,%eax
  80134d:	79 16                	jns    801365 <ipc_recv+0x45>
		if ( from_env_store ) 
  80134f:	85 f6                	test   %esi,%esi
  801351:	74 06                	je     801359 <ipc_recv+0x39>
			(*from_env_store) = 0 ;
  801353:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if ( perm_store)
  801359:	85 db                	test   %ebx,%ebx
  80135b:	74 2c                	je     801389 <ipc_recv+0x69>
			(*perm_store) = 0 ;	
  80135d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801363:	eb 24                	jmp    801389 <ipc_recv+0x69>
		return result; 
	}
	if ( from_env_store ) 
  801365:	85 f6                	test   %esi,%esi
  801367:	74 0a                	je     801373 <ipc_recv+0x53>
		(*from_env_store) = thisenv->env_ipc_from ;
  801369:	a1 04 20 80 00       	mov    0x802004,%eax
  80136e:	8b 40 74             	mov    0x74(%eax),%eax
  801371:	89 06                	mov    %eax,(%esi)
	if ( perm_store)
  801373:	85 db                	test   %ebx,%ebx
  801375:	74 0a                	je     801381 <ipc_recv+0x61>
		(*perm_store) = thisenv->env_ipc_perm ;	
  801377:	a1 04 20 80 00       	mov    0x802004,%eax
  80137c:	8b 40 78             	mov    0x78(%eax),%eax
  80137f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801381:	a1 04 20 80 00       	mov    0x802004,%eax
  801386:	8b 40 70             	mov    0x70(%eax),%eax
}
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	57                   	push   %edi
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
  801396:	83 ec 1c             	sub    $0x1c,%esp
  801399:	8b 75 0c             	mov    0xc(%ebp),%esi
  80139c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80139f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	
	
	int result = -E_IPC_NOT_RECV ; 
	if ( pg ) 
  8013a2:	85 db                	test   %ebx,%ebx
  8013a4:	74 19                	je     8013bf <ipc_send+0x2f>
		result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  8013a6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b5:	89 04 24             	mov    %eax,(%esp)
  8013b8:	e8 e6 fe ff ff       	call   8012a3 <sys_ipc_try_send>
  8013bd:	eb 1b                	jmp    8013da <ipc_send+0x4a>
	else
		result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  8013bf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013c3:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8013ca:	ee 
  8013cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d2:	89 04 24             	mov    %eax,(%esp)
  8013d5:	e8 c9 fe ff ff       	call   8012a3 <sys_ipc_try_send>
	
	if ( result == 0 ) return ; 
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	74 61                	je     80143f <ipc_send+0xaf>
	if ( result == -E_IPC_NOT_RECV ) {
  8013de:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8013e1:	75 3c                	jne    80141f <ipc_send+0x8f>
		if ( pg ) 
  8013e3:	85 db                	test   %ebx,%ebx
  8013e5:	74 19                	je     801400 <ipc_send+0x70>
			result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  8013e7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	e8 a5 fe ff ff       	call   8012a3 <sys_ipc_try_send>
  8013fe:	eb 1b                	jmp    80141b <ipc_send+0x8b>
		else
			result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  801400:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801404:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80140b:	ee 
  80140c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	89 04 24             	mov    %eax,(%esp)
  801416:	e8 88 fe ff ff       	call   8012a3 <sys_ipc_try_send>
		if ( result == 0 ) return ; 
  80141b:	85 c0                	test   %eax,%eax
  80141d:	74 20                	je     80143f <ipc_send+0xaf>
	}
	panic("ipc_send error %e.",result);
  80141f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801423:	c7 44 24 08 93 1b 80 	movl   $0x801b93,0x8(%esp)
  80142a:	00 
  80142b:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801432:	00 
  801433:	c7 04 24 a6 1b 80 00 	movl   $0x801ba6,(%esp)
  80143a:	e8 47 00 00 00       	call   801486 <_panic>
}
  80143f:	83 c4 1c             	add    $0x1c,%esp
  801442:	5b                   	pop    %ebx
  801443:	5e                   	pop    %esi
  801444:	5f                   	pop    %edi
  801445:	5d                   	pop    %ebp
  801446:	c3                   	ret    

00801447 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80144d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801452:	89 c2                	mov    %eax,%edx
  801454:	c1 e2 07             	shl    $0x7,%edx
  801457:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80145e:	8b 52 50             	mov    0x50(%edx),%edx
  801461:	39 ca                	cmp    %ecx,%edx
  801463:	75 11                	jne    801476 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801465:	89 c2                	mov    %eax,%edx
  801467:	c1 e2 07             	shl    $0x7,%edx
  80146a:	8d 84 c2 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,8),%eax
  801471:	8b 40 40             	mov    0x40(%eax),%eax
  801474:	eb 0e                	jmp    801484 <ipc_find_env+0x3d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801476:	83 c0 01             	add    $0x1,%eax
  801479:	3d 00 04 00 00       	cmp    $0x400,%eax
  80147e:	75 d2                	jne    801452 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801480:	66 b8 00 00          	mov    $0x0,%ax
}
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	56                   	push   %esi
  80148a:	53                   	push   %ebx
  80148b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80148e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801491:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801497:	e8 29 fc ff ff       	call   8010c5 <sys_getenvid>
  80149c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149f:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8014ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b2:	c7 04 24 b0 1b 80 00 	movl   $0x801bb0,(%esp)
  8014b9:	e8 07 ed ff ff       	call   8001c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8014c5:	89 04 24             	mov    %eax,(%esp)
  8014c8:	e8 97 ec ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  8014cd:	c7 04 24 8f 17 80 00 	movl   $0x80178f,(%esp)
  8014d4:	e8 ec ec ff ff       	call   8001c5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014d9:	cc                   	int3   
  8014da:	eb fd                	jmp    8014d9 <_panic+0x53>
  8014dc:	66 90                	xchg   %ax,%ax
  8014de:	66 90                	xchg   %ax,%ax

008014e0 <__udivdi3>:
  8014e0:	55                   	push   %ebp
  8014e1:	57                   	push   %edi
  8014e2:	56                   	push   %esi
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8014ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8014f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014fc:	89 ea                	mov    %ebp,%edx
  8014fe:	89 0c 24             	mov    %ecx,(%esp)
  801501:	75 2d                	jne    801530 <__udivdi3+0x50>
  801503:	39 e9                	cmp    %ebp,%ecx
  801505:	77 61                	ja     801568 <__udivdi3+0x88>
  801507:	85 c9                	test   %ecx,%ecx
  801509:	89 ce                	mov    %ecx,%esi
  80150b:	75 0b                	jne    801518 <__udivdi3+0x38>
  80150d:	b8 01 00 00 00       	mov    $0x1,%eax
  801512:	31 d2                	xor    %edx,%edx
  801514:	f7 f1                	div    %ecx
  801516:	89 c6                	mov    %eax,%esi
  801518:	31 d2                	xor    %edx,%edx
  80151a:	89 e8                	mov    %ebp,%eax
  80151c:	f7 f6                	div    %esi
  80151e:	89 c5                	mov    %eax,%ebp
  801520:	89 f8                	mov    %edi,%eax
  801522:	f7 f6                	div    %esi
  801524:	89 ea                	mov    %ebp,%edx
  801526:	83 c4 0c             	add    $0xc,%esp
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    
  80152d:	8d 76 00             	lea    0x0(%esi),%esi
  801530:	39 e8                	cmp    %ebp,%eax
  801532:	77 24                	ja     801558 <__udivdi3+0x78>
  801534:	0f bd e8             	bsr    %eax,%ebp
  801537:	83 f5 1f             	xor    $0x1f,%ebp
  80153a:	75 3c                	jne    801578 <__udivdi3+0x98>
  80153c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801540:	39 34 24             	cmp    %esi,(%esp)
  801543:	0f 86 9f 00 00 00    	jbe    8015e8 <__udivdi3+0x108>
  801549:	39 d0                	cmp    %edx,%eax
  80154b:	0f 82 97 00 00 00    	jb     8015e8 <__udivdi3+0x108>
  801551:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801558:	31 d2                	xor    %edx,%edx
  80155a:	31 c0                	xor    %eax,%eax
  80155c:	83 c4 0c             	add    $0xc,%esp
  80155f:	5e                   	pop    %esi
  801560:	5f                   	pop    %edi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    
  801563:	90                   	nop
  801564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801568:	89 f8                	mov    %edi,%eax
  80156a:	f7 f1                	div    %ecx
  80156c:	31 d2                	xor    %edx,%edx
  80156e:	83 c4 0c             	add    $0xc,%esp
  801571:	5e                   	pop    %esi
  801572:	5f                   	pop    %edi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    
  801575:	8d 76 00             	lea    0x0(%esi),%esi
  801578:	89 e9                	mov    %ebp,%ecx
  80157a:	8b 3c 24             	mov    (%esp),%edi
  80157d:	d3 e0                	shl    %cl,%eax
  80157f:	89 c6                	mov    %eax,%esi
  801581:	b8 20 00 00 00       	mov    $0x20,%eax
  801586:	29 e8                	sub    %ebp,%eax
  801588:	89 c1                	mov    %eax,%ecx
  80158a:	d3 ef                	shr    %cl,%edi
  80158c:	89 e9                	mov    %ebp,%ecx
  80158e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801592:	8b 3c 24             	mov    (%esp),%edi
  801595:	09 74 24 08          	or     %esi,0x8(%esp)
  801599:	89 d6                	mov    %edx,%esi
  80159b:	d3 e7                	shl    %cl,%edi
  80159d:	89 c1                	mov    %eax,%ecx
  80159f:	89 3c 24             	mov    %edi,(%esp)
  8015a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015a6:	d3 ee                	shr    %cl,%esi
  8015a8:	89 e9                	mov    %ebp,%ecx
  8015aa:	d3 e2                	shl    %cl,%edx
  8015ac:	89 c1                	mov    %eax,%ecx
  8015ae:	d3 ef                	shr    %cl,%edi
  8015b0:	09 d7                	or     %edx,%edi
  8015b2:	89 f2                	mov    %esi,%edx
  8015b4:	89 f8                	mov    %edi,%eax
  8015b6:	f7 74 24 08          	divl   0x8(%esp)
  8015ba:	89 d6                	mov    %edx,%esi
  8015bc:	89 c7                	mov    %eax,%edi
  8015be:	f7 24 24             	mull   (%esp)
  8015c1:	39 d6                	cmp    %edx,%esi
  8015c3:	89 14 24             	mov    %edx,(%esp)
  8015c6:	72 30                	jb     8015f8 <__udivdi3+0x118>
  8015c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015cc:	89 e9                	mov    %ebp,%ecx
  8015ce:	d3 e2                	shl    %cl,%edx
  8015d0:	39 c2                	cmp    %eax,%edx
  8015d2:	73 05                	jae    8015d9 <__udivdi3+0xf9>
  8015d4:	3b 34 24             	cmp    (%esp),%esi
  8015d7:	74 1f                	je     8015f8 <__udivdi3+0x118>
  8015d9:	89 f8                	mov    %edi,%eax
  8015db:	31 d2                	xor    %edx,%edx
  8015dd:	e9 7a ff ff ff       	jmp    80155c <__udivdi3+0x7c>
  8015e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8015e8:	31 d2                	xor    %edx,%edx
  8015ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ef:	e9 68 ff ff ff       	jmp    80155c <__udivdi3+0x7c>
  8015f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8015fb:	31 d2                	xor    %edx,%edx
  8015fd:	83 c4 0c             	add    $0xc,%esp
  801600:	5e                   	pop    %esi
  801601:	5f                   	pop    %edi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    
  801604:	66 90                	xchg   %ax,%ax
  801606:	66 90                	xchg   %ax,%ax
  801608:	66 90                	xchg   %ax,%ax
  80160a:	66 90                	xchg   %ax,%ax
  80160c:	66 90                	xchg   %ax,%ax
  80160e:	66 90                	xchg   %ax,%ax

00801610 <__umoddi3>:
  801610:	55                   	push   %ebp
  801611:	57                   	push   %edi
  801612:	56                   	push   %esi
  801613:	83 ec 14             	sub    $0x14,%esp
  801616:	8b 44 24 28          	mov    0x28(%esp),%eax
  80161a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80161e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801622:	89 c7                	mov    %eax,%edi
  801624:	89 44 24 04          	mov    %eax,0x4(%esp)
  801628:	8b 44 24 30          	mov    0x30(%esp),%eax
  80162c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801630:	89 34 24             	mov    %esi,(%esp)
  801633:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801637:	85 c0                	test   %eax,%eax
  801639:	89 c2                	mov    %eax,%edx
  80163b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80163f:	75 17                	jne    801658 <__umoddi3+0x48>
  801641:	39 fe                	cmp    %edi,%esi
  801643:	76 4b                	jbe    801690 <__umoddi3+0x80>
  801645:	89 c8                	mov    %ecx,%eax
  801647:	89 fa                	mov    %edi,%edx
  801649:	f7 f6                	div    %esi
  80164b:	89 d0                	mov    %edx,%eax
  80164d:	31 d2                	xor    %edx,%edx
  80164f:	83 c4 14             	add    $0x14,%esp
  801652:	5e                   	pop    %esi
  801653:	5f                   	pop    %edi
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    
  801656:	66 90                	xchg   %ax,%ax
  801658:	39 f8                	cmp    %edi,%eax
  80165a:	77 54                	ja     8016b0 <__umoddi3+0xa0>
  80165c:	0f bd e8             	bsr    %eax,%ebp
  80165f:	83 f5 1f             	xor    $0x1f,%ebp
  801662:	75 5c                	jne    8016c0 <__umoddi3+0xb0>
  801664:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801668:	39 3c 24             	cmp    %edi,(%esp)
  80166b:	0f 87 e7 00 00 00    	ja     801758 <__umoddi3+0x148>
  801671:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801675:	29 f1                	sub    %esi,%ecx
  801677:	19 c7                	sbb    %eax,%edi
  801679:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80167d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801681:	8b 44 24 08          	mov    0x8(%esp),%eax
  801685:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801689:	83 c4 14             	add    $0x14,%esp
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    
  801690:	85 f6                	test   %esi,%esi
  801692:	89 f5                	mov    %esi,%ebp
  801694:	75 0b                	jne    8016a1 <__umoddi3+0x91>
  801696:	b8 01 00 00 00       	mov    $0x1,%eax
  80169b:	31 d2                	xor    %edx,%edx
  80169d:	f7 f6                	div    %esi
  80169f:	89 c5                	mov    %eax,%ebp
  8016a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8016a5:	31 d2                	xor    %edx,%edx
  8016a7:	f7 f5                	div    %ebp
  8016a9:	89 c8                	mov    %ecx,%eax
  8016ab:	f7 f5                	div    %ebp
  8016ad:	eb 9c                	jmp    80164b <__umoddi3+0x3b>
  8016af:	90                   	nop
  8016b0:	89 c8                	mov    %ecx,%eax
  8016b2:	89 fa                	mov    %edi,%edx
  8016b4:	83 c4 14             	add    $0x14,%esp
  8016b7:	5e                   	pop    %esi
  8016b8:	5f                   	pop    %edi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    
  8016bb:	90                   	nop
  8016bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016c0:	8b 04 24             	mov    (%esp),%eax
  8016c3:	be 20 00 00 00       	mov    $0x20,%esi
  8016c8:	89 e9                	mov    %ebp,%ecx
  8016ca:	29 ee                	sub    %ebp,%esi
  8016cc:	d3 e2                	shl    %cl,%edx
  8016ce:	89 f1                	mov    %esi,%ecx
  8016d0:	d3 e8                	shr    %cl,%eax
  8016d2:	89 e9                	mov    %ebp,%ecx
  8016d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d8:	8b 04 24             	mov    (%esp),%eax
  8016db:	09 54 24 04          	or     %edx,0x4(%esp)
  8016df:	89 fa                	mov    %edi,%edx
  8016e1:	d3 e0                	shl    %cl,%eax
  8016e3:	89 f1                	mov    %esi,%ecx
  8016e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8016ed:	d3 ea                	shr    %cl,%edx
  8016ef:	89 e9                	mov    %ebp,%ecx
  8016f1:	d3 e7                	shl    %cl,%edi
  8016f3:	89 f1                	mov    %esi,%ecx
  8016f5:	d3 e8                	shr    %cl,%eax
  8016f7:	89 e9                	mov    %ebp,%ecx
  8016f9:	09 f8                	or     %edi,%eax
  8016fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8016ff:	f7 74 24 04          	divl   0x4(%esp)
  801703:	d3 e7                	shl    %cl,%edi
  801705:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801709:	89 d7                	mov    %edx,%edi
  80170b:	f7 64 24 08          	mull   0x8(%esp)
  80170f:	39 d7                	cmp    %edx,%edi
  801711:	89 c1                	mov    %eax,%ecx
  801713:	89 14 24             	mov    %edx,(%esp)
  801716:	72 2c                	jb     801744 <__umoddi3+0x134>
  801718:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80171c:	72 22                	jb     801740 <__umoddi3+0x130>
  80171e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801722:	29 c8                	sub    %ecx,%eax
  801724:	19 d7                	sbb    %edx,%edi
  801726:	89 e9                	mov    %ebp,%ecx
  801728:	89 fa                	mov    %edi,%edx
  80172a:	d3 e8                	shr    %cl,%eax
  80172c:	89 f1                	mov    %esi,%ecx
  80172e:	d3 e2                	shl    %cl,%edx
  801730:	89 e9                	mov    %ebp,%ecx
  801732:	d3 ef                	shr    %cl,%edi
  801734:	09 d0                	or     %edx,%eax
  801736:	89 fa                	mov    %edi,%edx
  801738:	83 c4 14             	add    $0x14,%esp
  80173b:	5e                   	pop    %esi
  80173c:	5f                   	pop    %edi
  80173d:	5d                   	pop    %ebp
  80173e:	c3                   	ret    
  80173f:	90                   	nop
  801740:	39 d7                	cmp    %edx,%edi
  801742:	75 da                	jne    80171e <__umoddi3+0x10e>
  801744:	8b 14 24             	mov    (%esp),%edx
  801747:	89 c1                	mov    %eax,%ecx
  801749:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80174d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801751:	eb cb                	jmp    80171e <__umoddi3+0x10e>
  801753:	90                   	nop
  801754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801758:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80175c:	0f 82 0f ff ff ff    	jb     801671 <__umoddi3+0x61>
  801762:	e9 1a ff ff ff       	jmp    801681 <__umoddi3+0x71>
