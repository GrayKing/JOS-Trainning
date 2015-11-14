
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800046:	00 
  800047:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004e:	00 
  80004f:	89 34 24             	mov    %esi,(%esp)
  800052:	e8 89 17 00 00       	call   8017e0 <ipc_recv>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800059:	a1 04 30 80 00       	mov    0x803004,%eax
  80005e:	8b 40 5c             	mov    0x5c(%eax),%eax
  800061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	c7 04 24 60 1c 80 00 	movl   $0x801c60,(%esp)
  800070:	e8 2c 02 00 00       	call   8002a1 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800075:	e8 94 14 00 00       	call   80150e <fork>
  80007a:	89 c7                	mov    %eax,%edi
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 20                	jns    8000a0 <primeproc+0x6d>
		panic("fork: %e", id);
  800080:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800084:	c7 44 24 08 6c 1c 80 	movl   $0x801c6c,0x8(%esp)
  80008b:	00 
  80008c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800093:	00 
  800094:	c7 04 24 75 1c 80 00 	movl   $0x801c75,(%esp)
  80009b:	e8 08 01 00 00       	call   8001a8 <_panic>
	if (id == 0)
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	74 9b                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a4:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	89 34 24             	mov    %esi,(%esp)
  8000ba:	e8 21 17 00 00       	call   8017e0 <ipc_recv>
  8000bf:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c1:	99                   	cltd   
  8000c2:	f7 fb                	idiv   %ebx
  8000c4:	85 d2                	test   %edx,%edx
  8000c6:	74 df                	je     8000a7 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000cf:	00 
  8000d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d7:	00 
  8000d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dc:	89 3c 24             	mov    %edi,(%esp)
  8000df:	e8 6c 17 00 00       	call   801850 <ipc_send>
  8000e4:	eb c1                	jmp    8000a7 <primeproc+0x74>

008000e6 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ee:	e8 1b 14 00 00       	call   80150e <fork>
  8000f3:	89 c6                	mov    %eax,%esi
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	79 20                	jns    800119 <umain+0x33>
		panic("fork: %e", id);
  8000f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fd:	c7 44 24 08 6c 1c 80 	movl   $0x801c6c,0x8(%esp)
  800104:	00 
  800105:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 75 1c 80 00 	movl   $0x801c75,(%esp)
  800114:	e8 8f 00 00 00       	call   8001a8 <_panic>
	if (id == 0)
  800119:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011e:	85 c0                	test   %eax,%eax
  800120:	75 05                	jne    800127 <umain+0x41>
		primeproc();
  800122:	e8 0c ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800127:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800136:	00 
  800137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013b:	89 34 24             	mov    %esi,(%esp)
  80013e:	e8 0d 17 00 00       	call   801850 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	eb df                	jmp    800127 <umain+0x41>

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800153:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800156:	e8 4a 10 00 00       	call   8011a5 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	89 c2                	mov    %eax,%edx
  800162:	c1 e2 07             	shl    $0x7,%edx
  800165:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80016c:	a3 04 30 80 00       	mov    %eax,0x803004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800171:	85 db                	test   %ebx,%ebx
  800173:	7e 07                	jle    80017c <libmain+0x34>
		binaryname = argv[0];
  800175:	8b 06                	mov    (%esi),%eax
  800177:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80017c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800180:	89 1c 24             	mov    %ebx,(%esp)
  800183:	e8 5e ff ff ff       	call   8000e6 <umain>

	// exit gracefully
	exit();
  800188:	e8 07 00 00 00       	call   800194 <exit>
}
  80018d:	83 c4 10             	add    $0x10,%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    

00800194 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80019a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a1:	e8 ad 0f 00 00       	call   801153 <sys_env_destroy>
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001b0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001b9:	e8 e7 0f 00 00       	call   8011a5 <sys_getenvid>
  8001be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001cc:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d4:	c7 04 24 90 1c 80 00 	movl   $0x801c90,(%esp)
  8001db:	e8 c1 00 00 00       	call   8002a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e7:	89 04 24             	mov    %eax,(%esp)
  8001ea:	e8 51 00 00 00       	call   800240 <vcprintf>
	cprintf("\n");
  8001ef:	c7 04 24 b3 1c 80 00 	movl   $0x801cb3,(%esp)
  8001f6:	e8 a6 00 00 00       	call   8002a1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fb:	cc                   	int3   
  8001fc:	eb fd                	jmp    8001fb <_panic+0x53>

008001fe <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	53                   	push   %ebx
  800202:	83 ec 14             	sub    $0x14,%esp
  800205:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800208:	8b 13                	mov    (%ebx),%edx
  80020a:	8d 42 01             	lea    0x1(%edx),%eax
  80020d:	89 03                	mov    %eax,(%ebx)
  80020f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800212:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800216:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021b:	75 19                	jne    800236 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80021d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800224:	00 
  800225:	8d 43 08             	lea    0x8(%ebx),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 e6 0e 00 00       	call   801116 <sys_cputs>
		b->idx = 0;
  800230:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800236:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023a:	83 c4 14             	add    $0x14,%esp
  80023d:	5b                   	pop    %ebx
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800249:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800250:	00 00 00 
	b.cnt = 0;
  800253:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800260:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	c7 04 24 fe 01 80 00 	movl   $0x8001fe,(%esp)
  80027c:	e8 ae 02 00 00       	call   80052f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800281:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	e8 7d 0e 00 00       	call   801116 <sys_cputs>

	return b.cnt;
}
  800299:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 87 ff ff ff       	call   800240 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    
  8002bb:	66 90                	xchg   %ax,%ax
  8002bd:	66 90                	xchg   %ax,%ax
  8002bf:	90                   	nop

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d7:	89 c3                	mov    %eax,%ebx
  8002d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ed:	39 d9                	cmp    %ebx,%ecx
  8002ef:	72 05                	jb     8002f6 <printnum+0x36>
  8002f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002f4:	77 69                	ja     80035f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002fd:	83 ee 01             	sub    $0x1,%esi
  800300:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 44 24 08          	mov    0x8(%esp),%eax
  80030c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800310:	89 c3                	mov    %eax,%ebx
  800312:	89 d6                	mov    %edx,%esi
  800314:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800317:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80031a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80031e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 8c 16 00 00       	call   8019c0 <__udivdi3>
  800334:	89 d9                	mov    %ebx,%ecx
  800336:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033e:	89 04 24             	mov    %eax,(%esp)
  800341:	89 54 24 04          	mov    %edx,0x4(%esp)
  800345:	89 fa                	mov    %edi,%edx
  800347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034a:	e8 71 ff ff ff       	call   8002c0 <printnum>
  80034f:	eb 1b                	jmp    80036c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800351:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800355:	8b 45 18             	mov    0x18(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	ff d3                	call   *%ebx
  80035d:	eb 03                	jmp    800362 <printnum+0xa2>
  80035f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800362:	83 ee 01             	sub    $0x1,%esi
  800365:	85 f6                	test   %esi,%esi
  800367:	7f e8                	jg     800351 <printnum+0x91>
  800369:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800370:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800374:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800377:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80037a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038f:	e8 5c 17 00 00       	call   801af0 <__umoddi3>
  800394:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800398:	0f be 80 b5 1c 80 00 	movsbl 0x801cb5(%eax),%eax
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003a5:	ff d0                	call   *%eax
}
  8003a7:	83 c4 3c             	add    $0x3c,%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	57                   	push   %edi
  8003b3:	56                   	push   %esi
  8003b4:	53                   	push   %ebx
  8003b5:	83 ec 3c             	sub    $0x3c,%esp
  8003b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003bb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003be:	89 cf                	mov    %ecx,%edi
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c9:	89 c3                	mov    %eax,%ebx
  8003cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003dc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003df:	39 d9                	cmp    %ebx,%ecx
  8003e1:	72 13                	jb     8003f6 <cprintnum+0x47>
  8003e3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003e6:	76 0e                	jbe    8003f6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8003e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003eb:	0b 45 18             	or     0x18(%ebp),%eax
  8003ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003f4:	eb 6a                	jmp    800460 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8003f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003fd:	83 ee 01             	sub    $0x1,%esi
  800400:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800404:	89 44 24 08          	mov    %eax,0x8(%esp)
  800408:	8b 44 24 08          	mov    0x8(%esp),%eax
  80040c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800410:	89 c3                	mov    %eax,%ebx
  800412:	89 d6                	mov    %edx,%esi
  800414:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800417:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80041a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80041e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800422:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800425:	89 04 24             	mov    %eax,(%esp)
  800428:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80042b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042f:	e8 8c 15 00 00       	call   8019c0 <__udivdi3>
  800434:	89 d9                	mov    %ebx,%ecx
  800436:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80043a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80043e:	89 04 24             	mov    %eax,(%esp)
  800441:	89 54 24 04          	mov    %edx,0x4(%esp)
  800445:	89 f9                	mov    %edi,%ecx
  800447:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80044a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80044d:	e8 5d ff ff ff       	call   8003af <cprintnum>
  800452:	eb 16                	jmp    80046a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800454:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800458:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800460:	83 ee 01             	sub    $0x1,%esi
  800463:	85 f6                	test   %esi,%esi
  800465:	7f ed                	jg     800454 <cprintnum+0xa5>
  800467:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80046a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800472:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800475:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800478:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800480:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800483:	89 04 24             	mov    %eax,(%esp)
  800486:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	e8 5e 16 00 00       	call   801af0 <__umoddi3>
  800492:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800496:	0f be 80 b5 1c 80 00 	movsbl 0x801cb5(%eax),%eax
  80049d:	0b 45 dc             	or     -0x24(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a6:	ff d0                	call   *%eax
}
  8004a8:	83 c4 3c             	add    $0x3c,%esp
  8004ab:	5b                   	pop    %ebx
  8004ac:	5e                   	pop    %esi
  8004ad:	5f                   	pop    %edi
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    

008004b0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b3:	83 fa 01             	cmp    $0x1,%edx
  8004b6:	7e 0e                	jle    8004c6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bd:	89 08                	mov    %ecx,(%eax)
  8004bf:	8b 02                	mov    (%edx),%eax
  8004c1:	8b 52 04             	mov    0x4(%edx),%edx
  8004c4:	eb 22                	jmp    8004e8 <getuint+0x38>
	else if (lflag)
  8004c6:	85 d2                	test   %edx,%edx
  8004c8:	74 10                	je     8004da <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ca:	8b 10                	mov    (%eax),%edx
  8004cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cf:	89 08                	mov    %ecx,(%eax)
  8004d1:	8b 02                	mov    (%edx),%eax
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	eb 0e                	jmp    8004e8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f9:	73 0a                	jae    800505 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fe:	89 08                	mov    %ecx,(%eax)
  800500:	8b 45 08             	mov    0x8(%ebp),%eax
  800503:	88 02                	mov    %al,(%edx)
}
  800505:	5d                   	pop    %ebp
  800506:	c3                   	ret    

00800507 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80050d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800510:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800514:	8b 45 10             	mov    0x10(%ebp),%eax
  800517:	89 44 24 08          	mov    %eax,0x8(%esp)
  80051b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800522:	8b 45 08             	mov    0x8(%ebp),%eax
  800525:	89 04 24             	mov    %eax,(%esp)
  800528:	e8 02 00 00 00       	call   80052f <vprintfmt>
	va_end(ap);
}
  80052d:	c9                   	leave  
  80052e:	c3                   	ret    

0080052f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	57                   	push   %edi
  800533:	56                   	push   %esi
  800534:	53                   	push   %ebx
  800535:	83 ec 3c             	sub    $0x3c,%esp
  800538:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80053b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80053e:	eb 14                	jmp    800554 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800540:	85 c0                	test   %eax,%eax
  800542:	0f 84 b3 03 00 00    	je     8008fb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800548:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054c:	89 04 24             	mov    %eax,(%esp)
  80054f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800552:	89 f3                	mov    %esi,%ebx
  800554:	8d 73 01             	lea    0x1(%ebx),%esi
  800557:	0f b6 03             	movzbl (%ebx),%eax
  80055a:	83 f8 25             	cmp    $0x25,%eax
  80055d:	75 e1                	jne    800540 <vprintfmt+0x11>
  80055f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800563:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80056a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800571:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800578:	ba 00 00 00 00       	mov    $0x0,%edx
  80057d:	eb 1d                	jmp    80059c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800581:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800585:	eb 15                	jmp    80059c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800589:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80058d:	eb 0d                	jmp    80059c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80058f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800592:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800595:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80059f:	0f b6 0e             	movzbl (%esi),%ecx
  8005a2:	0f b6 c1             	movzbl %cl,%eax
  8005a5:	83 e9 23             	sub    $0x23,%ecx
  8005a8:	80 f9 55             	cmp    $0x55,%cl
  8005ab:	0f 87 2a 03 00 00    	ja     8008db <vprintfmt+0x3ac>
  8005b1:	0f b6 c9             	movzbl %cl,%ecx
  8005b4:	ff 24 8d 80 1d 80 00 	jmp    *0x801d80(,%ecx,4)
  8005bb:	89 de                	mov    %ebx,%esi
  8005bd:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005c5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8005c9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005cc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005cf:	83 fb 09             	cmp    $0x9,%ebx
  8005d2:	77 36                	ja     80060a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d7:	eb e9                	jmp    8005c2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e9:	eb 22                	jmp    80060d <vprintfmt+0xde>
  8005eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f5:	0f 49 c1             	cmovns %ecx,%eax
  8005f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	89 de                	mov    %ebx,%esi
  8005fd:	eb 9d                	jmp    80059c <vprintfmt+0x6d>
  8005ff:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800601:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800608:	eb 92                	jmp    80059c <vprintfmt+0x6d>
  80060a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80060d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800611:	79 89                	jns    80059c <vprintfmt+0x6d>
  800613:	e9 77 ff ff ff       	jmp    80058f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800618:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061d:	e9 7a ff ff ff       	jmp    80059c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 04 24             	mov    %eax,(%esp)
  800634:	ff 55 08             	call   *0x8(%ebp)
			break;
  800637:	e9 18 ff ff ff       	jmp    800554 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	8b 00                	mov    (%eax),%eax
  800647:	99                   	cltd   
  800648:	31 d0                	xor    %edx,%eax
  80064a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064c:	83 f8 09             	cmp    $0x9,%eax
  80064f:	7f 0b                	jg     80065c <vprintfmt+0x12d>
  800651:	8b 14 85 40 20 80 00 	mov    0x802040(,%eax,4),%edx
  800658:	85 d2                	test   %edx,%edx
  80065a:	75 20                	jne    80067c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80065c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800660:	c7 44 24 08 cd 1c 80 	movl   $0x801ccd,0x8(%esp)
  800667:	00 
  800668:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066c:	8b 45 08             	mov    0x8(%ebp),%eax
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	e8 90 fe ff ff       	call   800507 <printfmt>
  800677:	e9 d8 fe ff ff       	jmp    800554 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80067c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800680:	c7 44 24 08 d6 1c 80 	movl   $0x801cd6,0x8(%esp)
  800687:	00 
  800688:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	89 04 24             	mov    %eax,(%esp)
  800692:	e8 70 fe ff ff       	call   800507 <printfmt>
  800697:	e9 b8 fe ff ff       	jmp    800554 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80069f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 04             	lea    0x4(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ae:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006b0:	85 f6                	test   %esi,%esi
  8006b2:	b8 c6 1c 80 00       	mov    $0x801cc6,%eax
  8006b7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006ba:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006be:	0f 84 97 00 00 00    	je     80075b <vprintfmt+0x22c>
  8006c4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006c8:	0f 8e 9b 00 00 00    	jle    800769 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006d2:	89 34 24             	mov    %esi,(%esp)
  8006d5:	e8 ce 06 00 00       	call   800da8 <strnlen>
  8006da:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006dd:	29 c2                	sub    %eax,%edx
  8006df:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8006e2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ef:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006f2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f4:	eb 0f                	jmp    800705 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006fd:	89 04 24             	mov    %eax,(%esp)
  800700:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800702:	83 eb 01             	sub    $0x1,%ebx
  800705:	85 db                	test   %ebx,%ebx
  800707:	7f ed                	jg     8006f6 <vprintfmt+0x1c7>
  800709:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80070c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80070f:	85 d2                	test   %edx,%edx
  800711:	b8 00 00 00 00       	mov    $0x0,%eax
  800716:	0f 49 c2             	cmovns %edx,%eax
  800719:	29 c2                	sub    %eax,%edx
  80071b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80071e:	89 d7                	mov    %edx,%edi
  800720:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800723:	eb 50                	jmp    800775 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800725:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800729:	74 1e                	je     800749 <vprintfmt+0x21a>
  80072b:	0f be d2             	movsbl %dl,%edx
  80072e:	83 ea 20             	sub    $0x20,%edx
  800731:	83 fa 5e             	cmp    $0x5e,%edx
  800734:	76 13                	jbe    800749 <vprintfmt+0x21a>
					putch('?', putdat);
  800736:	8b 45 0c             	mov    0xc(%ebp),%eax
  800739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800744:	ff 55 08             	call   *0x8(%ebp)
  800747:	eb 0d                	jmp    800756 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800749:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800756:	83 ef 01             	sub    $0x1,%edi
  800759:	eb 1a                	jmp    800775 <vprintfmt+0x246>
  80075b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80075e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800761:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800764:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800767:	eb 0c                	jmp    800775 <vprintfmt+0x246>
  800769:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80076c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80076f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800772:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800775:	83 c6 01             	add    $0x1,%esi
  800778:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80077c:	0f be c2             	movsbl %dl,%eax
  80077f:	85 c0                	test   %eax,%eax
  800781:	74 27                	je     8007aa <vprintfmt+0x27b>
  800783:	85 db                	test   %ebx,%ebx
  800785:	78 9e                	js     800725 <vprintfmt+0x1f6>
  800787:	83 eb 01             	sub    $0x1,%ebx
  80078a:	79 99                	jns    800725 <vprintfmt+0x1f6>
  80078c:	89 f8                	mov    %edi,%eax
  80078e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	89 c3                	mov    %eax,%ebx
  800796:	eb 1a                	jmp    8007b2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800798:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a5:	83 eb 01             	sub    $0x1,%ebx
  8007a8:	eb 08                	jmp    8007b2 <vprintfmt+0x283>
  8007aa:	89 fb                	mov    %edi,%ebx
  8007ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8007af:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007b2:	85 db                	test   %ebx,%ebx
  8007b4:	7f e2                	jg     800798 <vprintfmt+0x269>
  8007b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007bc:	e9 93 fd ff ff       	jmp    800554 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c1:	83 fa 01             	cmp    $0x1,%edx
  8007c4:	7e 16                	jle    8007dc <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 50 08             	lea    0x8(%eax),%edx
  8007cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cf:	8b 50 04             	mov    0x4(%eax),%edx
  8007d2:	8b 00                	mov    (%eax),%eax
  8007d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007da:	eb 32                	jmp    80080e <vprintfmt+0x2df>
	else if (lflag)
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	74 18                	je     8007f8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 04             	lea    0x4(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 30                	mov    (%eax),%esi
  8007eb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	c1 f8 1f             	sar    $0x1f,%eax
  8007f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f6:	eb 16                	jmp    80080e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 50 04             	lea    0x4(%eax),%edx
  8007fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800801:	8b 30                	mov    (%eax),%esi
  800803:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800806:	89 f0                	mov    %esi,%eax
  800808:	c1 f8 1f             	sar    $0x1f,%eax
  80080b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800811:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800814:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800819:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80081d:	0f 89 80 00 00 00    	jns    8008a3 <vprintfmt+0x374>
				putch('-', putdat);
  800823:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800827:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80082e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800831:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800834:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800837:	f7 d8                	neg    %eax
  800839:	83 d2 00             	adc    $0x0,%edx
  80083c:	f7 da                	neg    %edx
			}
			base = 10;
  80083e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800843:	eb 5e                	jmp    8008a3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800845:	8d 45 14             	lea    0x14(%ebp),%eax
  800848:	e8 63 fc ff ff       	call   8004b0 <getuint>
			base = 10;
  80084d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800852:	eb 4f                	jmp    8008a3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800854:	8d 45 14             	lea    0x14(%ebp),%eax
  800857:	e8 54 fc ff ff       	call   8004b0 <getuint>
			base = 8 ;
  80085c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800861:	eb 40                	jmp    8008a3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800863:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800867:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80086e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800871:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800875:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80087c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087f:	8b 45 14             	mov    0x14(%ebp),%eax
  800882:	8d 50 04             	lea    0x4(%eax),%edx
  800885:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800888:	8b 00                	mov    (%eax),%eax
  80088a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800894:	eb 0d                	jmp    8008a3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
  800899:	e8 12 fc ff ff       	call   8004b0 <getuint>
			base = 16;
  80089e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8008a7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8008ab:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8008ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008bd:	89 fa                	mov    %edi,%edx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	e8 f9 f9 ff ff       	call   8002c0 <printnum>
			break;
  8008c7:	e9 88 fc ff ff       	jmp    800554 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008d0:	89 04 24             	mov    %eax,(%esp)
  8008d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008d6:	e9 79 fc ff ff       	jmp    800554 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e9:	89 f3                	mov    %esi,%ebx
  8008eb:	eb 03                	jmp    8008f0 <vprintfmt+0x3c1>
  8008ed:	83 eb 01             	sub    $0x1,%ebx
  8008f0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008f4:	75 f7                	jne    8008ed <vprintfmt+0x3be>
  8008f6:	e9 59 fc ff ff       	jmp    800554 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008fb:	83 c4 3c             	add    $0x3c,%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5f                   	pop    %edi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	57                   	push   %edi
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	83 ec 3c             	sub    $0x3c,%esp
  80090c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8d 50 04             	lea    0x4(%eax),%edx
  800915:	89 55 14             	mov    %edx,0x14(%ebp)
  800918:	8b 00                	mov    (%eax),%eax
  80091a:	c1 e0 08             	shl    $0x8,%eax
  80091d:	0f b7 c0             	movzwl %ax,%eax
  800920:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800923:	83 c8 25             	or     $0x25,%eax
  800926:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800929:	eb 1a                	jmp    800945 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80092b:	85 c0                	test   %eax,%eax
  80092d:	0f 84 a9 03 00 00    	je     800cdc <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800933:	8b 75 0c             	mov    0xc(%ebp),%esi
  800936:	89 74 24 04          	mov    %esi,0x4(%esp)
  80093a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80093d:	89 04 24             	mov    %eax,(%esp)
  800940:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800943:	89 fb                	mov    %edi,%ebx
  800945:	8d 7b 01             	lea    0x1(%ebx),%edi
  800948:	0f b6 03             	movzbl (%ebx),%eax
  80094b:	83 f8 25             	cmp    $0x25,%eax
  80094e:	75 db                	jne    80092b <cvprintfmt+0x28>
  800950:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800954:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80095b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800960:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	eb 18                	jmp    800986 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800970:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800974:	eb 10                	jmp    800986 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800976:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800978:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80097c:	eb 08                	jmp    800986 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80097e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800981:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800986:	8d 5f 01             	lea    0x1(%edi),%ebx
  800989:	0f b6 0f             	movzbl (%edi),%ecx
  80098c:	0f b6 c1             	movzbl %cl,%eax
  80098f:	83 e9 23             	sub    $0x23,%ecx
  800992:	80 f9 55             	cmp    $0x55,%cl
  800995:	0f 87 1f 03 00 00    	ja     800cba <cvprintfmt+0x3b7>
  80099b:	0f b6 c9             	movzbl %cl,%ecx
  80099e:	ff 24 8d d8 1e 80 00 	jmp    *0x801ed8(,%ecx,4)
  8009a5:	89 df                	mov    %ebx,%edi
  8009a7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8009ac:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  8009af:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  8009b3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8009b6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8009b9:	83 f9 09             	cmp    $0x9,%ecx
  8009bc:	77 33                	ja     8009f1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8009be:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8009c1:	eb e9                	jmp    8009ac <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	8d 48 04             	lea    0x4(%eax),%ecx
  8009c9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8009cc:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ce:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8009d0:	eb 1f                	jmp    8009f1 <cvprintfmt+0xee>
  8009d2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8009d5:	85 ff                	test   %edi,%edi
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	0f 49 c7             	cmovns %edi,%eax
  8009df:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009e2:	89 df                	mov    %ebx,%edi
  8009e4:	eb a0                	jmp    800986 <cvprintfmt+0x83>
  8009e6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8009e8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8009ef:	eb 95                	jmp    800986 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  8009f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009f5:	79 8f                	jns    800986 <cvprintfmt+0x83>
  8009f7:	eb 85                	jmp    80097e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fc:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009fe:	66 90                	xchg   %ax,%ax
  800a00:	eb 84                	jmp    800986 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800a02:	8b 45 14             	mov    0x14(%ebp),%eax
  800a05:	8d 50 04             	lea    0x4(%eax),%edx
  800a08:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a15:	0b 10                	or     (%eax),%edx
  800a17:	89 14 24             	mov    %edx,(%esp)
  800a1a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a1d:	e9 23 ff ff ff       	jmp    800945 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a22:	8b 45 14             	mov    0x14(%ebp),%eax
  800a25:	8d 50 04             	lea    0x4(%eax),%edx
  800a28:	89 55 14             	mov    %edx,0x14(%ebp)
  800a2b:	8b 00                	mov    (%eax),%eax
  800a2d:	99                   	cltd   
  800a2e:	31 d0                	xor    %edx,%eax
  800a30:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a32:	83 f8 09             	cmp    $0x9,%eax
  800a35:	7f 0b                	jg     800a42 <cvprintfmt+0x13f>
  800a37:	8b 14 85 40 20 80 00 	mov    0x802040(,%eax,4),%edx
  800a3e:	85 d2                	test   %edx,%edx
  800a40:	75 23                	jne    800a65 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800a42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a46:	c7 44 24 08 cd 1c 80 	movl   $0x801ccd,0x8(%esp)
  800a4d:	00 
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	89 04 24             	mov    %eax,(%esp)
  800a5b:	e8 a7 fa ff ff       	call   800507 <printfmt>
  800a60:	e9 e0 fe ff ff       	jmp    800945 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800a65:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a69:	c7 44 24 08 d6 1c 80 	movl   $0x801cd6,0x8(%esp)
  800a70:	00 
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	89 04 24             	mov    %eax,(%esp)
  800a7e:	e8 84 fa ff ff       	call   800507 <printfmt>
  800a83:	e9 bd fe ff ff       	jmp    800945 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a88:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a8b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800a8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a91:	8d 48 04             	lea    0x4(%eax),%ecx
  800a94:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a97:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a99:	85 ff                	test   %edi,%edi
  800a9b:	b8 c6 1c 80 00       	mov    $0x801cc6,%eax
  800aa0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800aa3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800aa7:	74 61                	je     800b0a <cvprintfmt+0x207>
  800aa9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800aad:	7e 5b                	jle    800b0a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800aaf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ab3:	89 3c 24             	mov    %edi,(%esp)
  800ab6:	e8 ed 02 00 00       	call   800da8 <strnlen>
  800abb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800abe:	29 c2                	sub    %eax,%edx
  800ac0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800ac3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800ac7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800aca:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800acd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ad0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ada:	eb 0f                	jmp    800aeb <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae3:	89 3c 24             	mov    %edi,(%esp)
  800ae6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ae8:	83 eb 01             	sub    $0x1,%ebx
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	7f ed                	jg     800adc <cvprintfmt+0x1d9>
  800aef:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800af2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800af5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800af8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800afb:	85 d2                	test   %edx,%edx
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
  800b02:	0f 49 c2             	cmovns %edx,%eax
  800b05:	29 c2                	sub    %eax,%edx
  800b07:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800b0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b0d:	83 c8 3f             	or     $0x3f,%eax
  800b10:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b13:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b16:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800b19:	eb 36                	jmp    800b51 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b1b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b1f:	74 1d                	je     800b3e <cvprintfmt+0x23b>
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 20             	sub    $0x20,%edx
  800b27:	83 fa 5e             	cmp    $0x5e,%edx
  800b2a:	76 12                	jbe    800b3e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b33:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b36:	89 04 24             	mov    %eax,(%esp)
  800b39:	ff 55 08             	call   *0x8(%ebp)
  800b3c:	eb 10                	jmp    800b4e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b41:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b45:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b48:	89 04 24             	mov    %eax,(%esp)
  800b4b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b4e:	83 eb 01             	sub    $0x1,%ebx
  800b51:	83 c7 01             	add    $0x1,%edi
  800b54:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800b58:	0f be c2             	movsbl %dl,%eax
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	74 27                	je     800b86 <cvprintfmt+0x283>
  800b5f:	85 f6                	test   %esi,%esi
  800b61:	78 b8                	js     800b1b <cvprintfmt+0x218>
  800b63:	83 ee 01             	sub    $0x1,%esi
  800b66:	79 b3                	jns    800b1b <cvprintfmt+0x218>
  800b68:	89 d8                	mov    %ebx,%eax
  800b6a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b70:	89 c3                	mov    %eax,%ebx
  800b72:	eb 18                	jmp    800b8c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800b74:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b78:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b7f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800b81:	83 eb 01             	sub    $0x1,%ebx
  800b84:	eb 06                	jmp    800b8c <cvprintfmt+0x289>
  800b86:	8b 75 08             	mov    0x8(%ebp),%esi
  800b89:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b8c:	85 db                	test   %ebx,%ebx
  800b8e:	7f e4                	jg     800b74 <cvprintfmt+0x271>
  800b90:	89 75 08             	mov    %esi,0x8(%ebp)
  800b93:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b99:	e9 a7 fd ff ff       	jmp    800945 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b9e:	83 fa 01             	cmp    $0x1,%edx
  800ba1:	7e 10                	jle    800bb3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800ba3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba6:	8d 50 08             	lea    0x8(%eax),%edx
  800ba9:	89 55 14             	mov    %edx,0x14(%ebp)
  800bac:	8b 30                	mov    (%eax),%esi
  800bae:	8b 78 04             	mov    0x4(%eax),%edi
  800bb1:	eb 26                	jmp    800bd9 <cvprintfmt+0x2d6>
	else if (lflag)
  800bb3:	85 d2                	test   %edx,%edx
  800bb5:	74 12                	je     800bc9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800bb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bba:	8d 50 04             	lea    0x4(%eax),%edx
  800bbd:	89 55 14             	mov    %edx,0x14(%ebp)
  800bc0:	8b 30                	mov    (%eax),%esi
  800bc2:	89 f7                	mov    %esi,%edi
  800bc4:	c1 ff 1f             	sar    $0x1f,%edi
  800bc7:	eb 10                	jmp    800bd9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800bc9:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcc:	8d 50 04             	lea    0x4(%eax),%edx
  800bcf:	89 55 14             	mov    %edx,0x14(%ebp)
  800bd2:	8b 30                	mov    (%eax),%esi
  800bd4:	89 f7                	mov    %esi,%edi
  800bd6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800bd9:	89 f0                	mov    %esi,%eax
  800bdb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800bdd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800be2:	85 ff                	test   %edi,%edi
  800be4:	0f 89 8e 00 00 00    	jns    800c78 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bf4:	83 c8 2d             	or     $0x2d,%eax
  800bf7:	89 04 24             	mov    %eax,(%esp)
  800bfa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800bfd:	89 f0                	mov    %esi,%eax
  800bff:	89 fa                	mov    %edi,%edx
  800c01:	f7 d8                	neg    %eax
  800c03:	83 d2 00             	adc    $0x0,%edx
  800c06:	f7 da                	neg    %edx
			}
			base = 10;
  800c08:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c0d:	eb 69                	jmp    800c78 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800c12:	e8 99 f8 ff ff       	call   8004b0 <getuint>
			base = 10;
  800c17:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800c1c:	eb 5a                	jmp    800c78 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800c1e:	8d 45 14             	lea    0x14(%ebp),%eax
  800c21:	e8 8a f8 ff ff       	call   8004b0 <getuint>
			base = 8 ;
  800c26:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800c2b:	eb 4b                	jmp    800c78 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c34:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800c37:	89 f0                	mov    %esi,%eax
  800c39:	83 c8 30             	or     $0x30,%eax
  800c3c:	89 04 24             	mov    %eax,(%esp)
  800c3f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800c42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c49:	89 f0                	mov    %esi,%eax
  800c4b:	83 c8 78             	or     $0x78,%eax
  800c4e:	89 04 24             	mov    %eax,(%esp)
  800c51:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c54:	8b 45 14             	mov    0x14(%ebp),%eax
  800c57:	8d 50 04             	lea    0x4(%eax),%edx
  800c5a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800c5d:	8b 00                	mov    (%eax),%eax
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c64:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c69:	eb 0d                	jmp    800c78 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c6e:	e8 3d f8 ff ff       	call   8004b0 <getuint>
			base = 16;
  800c73:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800c78:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800c7c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c80:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800c83:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c8b:	89 04 24             	mov    %eax,(%esp)
  800c8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c9b:	e8 0f f7 ff ff       	call   8003af <cprintnum>
			break;
  800ca0:	e9 a0 fc ff ff       	jmp    800945 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800ca5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cac:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800caf:	89 04 24             	mov    %eax,(%esp)
  800cb2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800cb5:	e9 8b fc ff ff       	jmp    800945 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800cba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800cc4:	89 04 24             	mov    %eax,(%esp)
  800cc7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800cca:	89 fb                	mov    %edi,%ebx
  800ccc:	eb 03                	jmp    800cd1 <cvprintfmt+0x3ce>
  800cce:	83 eb 01             	sub    $0x1,%ebx
  800cd1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800cd5:	75 f7                	jne    800cce <cvprintfmt+0x3cb>
  800cd7:	e9 69 fc ff ff       	jmp    800945 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800cdc:	83 c4 3c             	add    $0x3c,%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800cea:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800ced:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cff:	8b 45 08             	mov    0x8(%ebp),%eax
  800d02:	89 04 24             	mov    %eax,(%esp)
  800d05:	e8 f9 fb ff ff       	call   800903 <cvprintfmt>
	va_end(ap);
}
  800d0a:	c9                   	leave  
  800d0b:	c3                   	ret    

00800d0c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 28             	sub    $0x28,%esp
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d18:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d1b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d1f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	74 30                	je     800d5d <vsnprintf+0x51>
  800d2d:	85 d2                	test   %edx,%edx
  800d2f:	7e 2c                	jle    800d5d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d31:	8b 45 14             	mov    0x14(%ebp),%eax
  800d34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d38:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d3f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d46:	c7 04 24 ea 04 80 00 	movl   $0x8004ea,(%esp)
  800d4d:	e8 dd f7 ff ff       	call   80052f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d55:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d5b:	eb 05                	jmp    800d62 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d62:	c9                   	leave  
  800d63:	c3                   	ret    

00800d64 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d6a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d71:	8b 45 10             	mov    0x10(%ebp),%eax
  800d74:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	89 04 24             	mov    %eax,(%esp)
  800d85:	e8 82 ff ff ff       	call   800d0c <vsnprintf>
	va_end(ap);

	return rc;
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    
  800d8c:	66 90                	xchg   %ax,%ax
  800d8e:	66 90                	xchg   %ax,%ax

00800d90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d96:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9b:	eb 03                	jmp    800da0 <strlen+0x10>
		n++;
  800d9d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800da0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800da4:	75 f7                	jne    800d9d <strlen+0xd>
		n++;
	return n;
}
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800db1:	b8 00 00 00 00       	mov    $0x0,%eax
  800db6:	eb 03                	jmp    800dbb <strnlen+0x13>
		n++;
  800db8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dbb:	39 d0                	cmp    %edx,%eax
  800dbd:	74 06                	je     800dc5 <strnlen+0x1d>
  800dbf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800dc3:	75 f3                	jne    800db8 <strnlen+0x10>
		n++;
	return n;
}
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	53                   	push   %ebx
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800dd1:	89 c2                	mov    %eax,%edx
  800dd3:	83 c2 01             	add    $0x1,%edx
  800dd6:	83 c1 01             	add    $0x1,%ecx
  800dd9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ddd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800de0:	84 db                	test   %bl,%bl
  800de2:	75 ef                	jne    800dd3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800de4:	5b                   	pop    %ebx
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	53                   	push   %ebx
  800deb:	83 ec 08             	sub    $0x8,%esp
  800dee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800df1:	89 1c 24             	mov    %ebx,(%esp)
  800df4:	e8 97 ff ff ff       	call   800d90 <strlen>
	strcpy(dst + len, src);
  800df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e00:	01 d8                	add    %ebx,%eax
  800e02:	89 04 24             	mov    %eax,(%esp)
  800e05:	e8 bd ff ff ff       	call   800dc7 <strcpy>
	return dst;
}
  800e0a:	89 d8                	mov    %ebx,%eax
  800e0c:	83 c4 08             	add    $0x8,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
  800e17:	8b 75 08             	mov    0x8(%ebp),%esi
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	89 f3                	mov    %esi,%ebx
  800e1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e22:	89 f2                	mov    %esi,%edx
  800e24:	eb 0f                	jmp    800e35 <strncpy+0x23>
		*dst++ = *src;
  800e26:	83 c2 01             	add    $0x1,%edx
  800e29:	0f b6 01             	movzbl (%ecx),%eax
  800e2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e2f:	80 39 01             	cmpb   $0x1,(%ecx)
  800e32:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e35:	39 da                	cmp    %ebx,%edx
  800e37:	75 ed                	jne    800e26 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e39:	89 f0                	mov    %esi,%eax
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	8b 75 08             	mov    0x8(%ebp),%esi
  800e47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e4d:	89 f0                	mov    %esi,%eax
  800e4f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e53:	85 c9                	test   %ecx,%ecx
  800e55:	75 0b                	jne    800e62 <strlcpy+0x23>
  800e57:	eb 1d                	jmp    800e76 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e59:	83 c0 01             	add    $0x1,%eax
  800e5c:	83 c2 01             	add    $0x1,%edx
  800e5f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e62:	39 d8                	cmp    %ebx,%eax
  800e64:	74 0b                	je     800e71 <strlcpy+0x32>
  800e66:	0f b6 0a             	movzbl (%edx),%ecx
  800e69:	84 c9                	test   %cl,%cl
  800e6b:	75 ec                	jne    800e59 <strlcpy+0x1a>
  800e6d:	89 c2                	mov    %eax,%edx
  800e6f:	eb 02                	jmp    800e73 <strlcpy+0x34>
  800e71:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800e73:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800e76:	29 f0                	sub    %esi,%eax
}
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e85:	eb 06                	jmp    800e8d <strcmp+0x11>
		p++, q++;
  800e87:	83 c1 01             	add    $0x1,%ecx
  800e8a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e8d:	0f b6 01             	movzbl (%ecx),%eax
  800e90:	84 c0                	test   %al,%al
  800e92:	74 04                	je     800e98 <strcmp+0x1c>
  800e94:	3a 02                	cmp    (%edx),%al
  800e96:	74 ef                	je     800e87 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e98:	0f b6 c0             	movzbl %al,%eax
  800e9b:	0f b6 12             	movzbl (%edx),%edx
  800e9e:	29 d0                	sub    %edx,%eax
}
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	53                   	push   %ebx
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eac:	89 c3                	mov    %eax,%ebx
  800eae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800eb1:	eb 06                	jmp    800eb9 <strncmp+0x17>
		n--, p++, q++;
  800eb3:	83 c0 01             	add    $0x1,%eax
  800eb6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800eb9:	39 d8                	cmp    %ebx,%eax
  800ebb:	74 15                	je     800ed2 <strncmp+0x30>
  800ebd:	0f b6 08             	movzbl (%eax),%ecx
  800ec0:	84 c9                	test   %cl,%cl
  800ec2:	74 04                	je     800ec8 <strncmp+0x26>
  800ec4:	3a 0a                	cmp    (%edx),%cl
  800ec6:	74 eb                	je     800eb3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ec8:	0f b6 00             	movzbl (%eax),%eax
  800ecb:	0f b6 12             	movzbl (%edx),%edx
  800ece:	29 d0                	sub    %edx,%eax
  800ed0:	eb 05                	jmp    800ed7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ed2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ed7:	5b                   	pop    %ebx
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ee4:	eb 07                	jmp    800eed <strchr+0x13>
		if (*s == c)
  800ee6:	38 ca                	cmp    %cl,%dl
  800ee8:	74 0f                	je     800ef9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800eea:	83 c0 01             	add    $0x1,%eax
  800eed:	0f b6 10             	movzbl (%eax),%edx
  800ef0:	84 d2                	test   %dl,%dl
  800ef2:	75 f2                	jne    800ee6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	8b 45 08             	mov    0x8(%ebp),%eax
  800f01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f05:	eb 07                	jmp    800f0e <strfind+0x13>
		if (*s == c)
  800f07:	38 ca                	cmp    %cl,%dl
  800f09:	74 0a                	je     800f15 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f0b:	83 c0 01             	add    $0x1,%eax
  800f0e:	0f b6 10             	movzbl (%eax),%edx
  800f11:	84 d2                	test   %dl,%dl
  800f13:	75 f2                	jne    800f07 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f23:	85 c9                	test   %ecx,%ecx
  800f25:	74 36                	je     800f5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f2d:	75 28                	jne    800f57 <memset+0x40>
  800f2f:	f6 c1 03             	test   $0x3,%cl
  800f32:	75 23                	jne    800f57 <memset+0x40>
		c &= 0xFF;
  800f34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	c1 e3 08             	shl    $0x8,%ebx
  800f3d:	89 d6                	mov    %edx,%esi
  800f3f:	c1 e6 18             	shl    $0x18,%esi
  800f42:	89 d0                	mov    %edx,%eax
  800f44:	c1 e0 10             	shl    $0x10,%eax
  800f47:	09 f0                	or     %esi,%eax
  800f49:	09 c2                	or     %eax,%edx
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f4f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f52:	fc                   	cld    
  800f53:	f3 ab                	rep stos %eax,%es:(%edi)
  800f55:	eb 06                	jmp    800f5d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5a:	fc                   	cld    
  800f5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f5d:	89 f8                	mov    %edi,%eax
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f72:	39 c6                	cmp    %eax,%esi
  800f74:	73 35                	jae    800fab <memmove+0x47>
  800f76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f79:	39 d0                	cmp    %edx,%eax
  800f7b:	73 2e                	jae    800fab <memmove+0x47>
		s += n;
		d += n;
  800f7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800f80:	89 d6                	mov    %edx,%esi
  800f82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f8a:	75 13                	jne    800f9f <memmove+0x3b>
  800f8c:	f6 c1 03             	test   $0x3,%cl
  800f8f:	75 0e                	jne    800f9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f91:	83 ef 04             	sub    $0x4,%edi
  800f94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f9a:	fd                   	std    
  800f9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9d:	eb 09                	jmp    800fa8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f9f:	83 ef 01             	sub    $0x1,%edi
  800fa2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fa5:	fd                   	std    
  800fa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fa8:	fc                   	cld    
  800fa9:	eb 1d                	jmp    800fc8 <memmove+0x64>
  800fab:	89 f2                	mov    %esi,%edx
  800fad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800faf:	f6 c2 03             	test   $0x3,%dl
  800fb2:	75 0f                	jne    800fc3 <memmove+0x5f>
  800fb4:	f6 c1 03             	test   $0x3,%cl
  800fb7:	75 0a                	jne    800fc3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fb9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fbc:	89 c7                	mov    %eax,%edi
  800fbe:	fc                   	cld    
  800fbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fc1:	eb 05                	jmp    800fc8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fc3:	89 c7                	mov    %eax,%edi
  800fc5:	fc                   	cld    
  800fc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fc8:	5e                   	pop    %esi
  800fc9:	5f                   	pop    %edi
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe3:	89 04 24             	mov    %eax,(%esp)
  800fe6:	e8 79 ff ff ff       	call   800f64 <memmove>
}
  800feb:	c9                   	leave  
  800fec:	c3                   	ret    

00800fed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	56                   	push   %esi
  800ff1:	53                   	push   %ebx
  800ff2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff8:	89 d6                	mov    %edx,%esi
  800ffa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ffd:	eb 1a                	jmp    801019 <memcmp+0x2c>
		if (*s1 != *s2)
  800fff:	0f b6 02             	movzbl (%edx),%eax
  801002:	0f b6 19             	movzbl (%ecx),%ebx
  801005:	38 d8                	cmp    %bl,%al
  801007:	74 0a                	je     801013 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801009:	0f b6 c0             	movzbl %al,%eax
  80100c:	0f b6 db             	movzbl %bl,%ebx
  80100f:	29 d8                	sub    %ebx,%eax
  801011:	eb 0f                	jmp    801022 <memcmp+0x35>
		s1++, s2++;
  801013:	83 c2 01             	add    $0x1,%edx
  801016:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801019:	39 f2                	cmp    %esi,%edx
  80101b:	75 e2                	jne    800fff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80101d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801022:	5b                   	pop    %ebx
  801023:	5e                   	pop    %esi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	8b 45 08             	mov    0x8(%ebp),%eax
  80102c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80102f:	89 c2                	mov    %eax,%edx
  801031:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801034:	eb 07                	jmp    80103d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801036:	38 08                	cmp    %cl,(%eax)
  801038:	74 07                	je     801041 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80103a:	83 c0 01             	add    $0x1,%eax
  80103d:	39 d0                	cmp    %edx,%eax
  80103f:	72 f5                	jb     801036 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	8b 55 08             	mov    0x8(%ebp),%edx
  80104c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80104f:	eb 03                	jmp    801054 <strtol+0x11>
		s++;
  801051:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801054:	0f b6 0a             	movzbl (%edx),%ecx
  801057:	80 f9 09             	cmp    $0x9,%cl
  80105a:	74 f5                	je     801051 <strtol+0xe>
  80105c:	80 f9 20             	cmp    $0x20,%cl
  80105f:	74 f0                	je     801051 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801061:	80 f9 2b             	cmp    $0x2b,%cl
  801064:	75 0a                	jne    801070 <strtol+0x2d>
		s++;
  801066:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801069:	bf 00 00 00 00       	mov    $0x0,%edi
  80106e:	eb 11                	jmp    801081 <strtol+0x3e>
  801070:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801075:	80 f9 2d             	cmp    $0x2d,%cl
  801078:	75 07                	jne    801081 <strtol+0x3e>
		s++, neg = 1;
  80107a:	8d 52 01             	lea    0x1(%edx),%edx
  80107d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801081:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801086:	75 15                	jne    80109d <strtol+0x5a>
  801088:	80 3a 30             	cmpb   $0x30,(%edx)
  80108b:	75 10                	jne    80109d <strtol+0x5a>
  80108d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801091:	75 0a                	jne    80109d <strtol+0x5a>
		s += 2, base = 16;
  801093:	83 c2 02             	add    $0x2,%edx
  801096:	b8 10 00 00 00       	mov    $0x10,%eax
  80109b:	eb 10                	jmp    8010ad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80109d:	85 c0                	test   %eax,%eax
  80109f:	75 0c                	jne    8010ad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010a1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010a3:	80 3a 30             	cmpb   $0x30,(%edx)
  8010a6:	75 05                	jne    8010ad <strtol+0x6a>
		s++, base = 8;
  8010a8:	83 c2 01             	add    $0x1,%edx
  8010ab:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  8010ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010b5:	0f b6 0a             	movzbl (%edx),%ecx
  8010b8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8010bb:	89 f0                	mov    %esi,%eax
  8010bd:	3c 09                	cmp    $0x9,%al
  8010bf:	77 08                	ja     8010c9 <strtol+0x86>
			dig = *s - '0';
  8010c1:	0f be c9             	movsbl %cl,%ecx
  8010c4:	83 e9 30             	sub    $0x30,%ecx
  8010c7:	eb 20                	jmp    8010e9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8010c9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8010cc:	89 f0                	mov    %esi,%eax
  8010ce:	3c 19                	cmp    $0x19,%al
  8010d0:	77 08                	ja     8010da <strtol+0x97>
			dig = *s - 'a' + 10;
  8010d2:	0f be c9             	movsbl %cl,%ecx
  8010d5:	83 e9 57             	sub    $0x57,%ecx
  8010d8:	eb 0f                	jmp    8010e9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8010da:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8010dd:	89 f0                	mov    %esi,%eax
  8010df:	3c 19                	cmp    $0x19,%al
  8010e1:	77 16                	ja     8010f9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8010e3:	0f be c9             	movsbl %cl,%ecx
  8010e6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010e9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8010ec:	7d 0f                	jge    8010fd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8010ee:	83 c2 01             	add    $0x1,%edx
  8010f1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8010f5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8010f7:	eb bc                	jmp    8010b5 <strtol+0x72>
  8010f9:	89 d8                	mov    %ebx,%eax
  8010fb:	eb 02                	jmp    8010ff <strtol+0xbc>
  8010fd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8010ff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801103:	74 05                	je     80110a <strtol+0xc7>
		*endptr = (char *) s;
  801105:	8b 75 0c             	mov    0xc(%ebp),%esi
  801108:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80110a:	f7 d8                	neg    %eax
  80110c:	85 ff                	test   %edi,%edi
  80110e:	0f 44 c3             	cmove  %ebx,%eax
}
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111c:	b8 00 00 00 00       	mov    $0x0,%eax
  801121:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801124:	8b 55 08             	mov    0x8(%ebp),%edx
  801127:	89 c3                	mov    %eax,%ebx
  801129:	89 c7                	mov    %eax,%edi
  80112b:	89 c6                	mov    %eax,%esi
  80112d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <sys_cgetc>:

int
sys_cgetc(void)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113a:	ba 00 00 00 00       	mov    $0x0,%edx
  80113f:	b8 01 00 00 00       	mov    $0x1,%eax
  801144:	89 d1                	mov    %edx,%ecx
  801146:	89 d3                	mov    %edx,%ebx
  801148:	89 d7                	mov    %edx,%edi
  80114a:	89 d6                	mov    %edx,%esi
  80114c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801161:	b8 03 00 00 00       	mov    $0x3,%eax
  801166:	8b 55 08             	mov    0x8(%ebp),%edx
  801169:	89 cb                	mov    %ecx,%ebx
  80116b:	89 cf                	mov    %ecx,%edi
  80116d:	89 ce                	mov    %ecx,%esi
  80116f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801171:	85 c0                	test   %eax,%eax
  801173:	7e 28                	jle    80119d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801175:	89 44 24 10          	mov    %eax,0x10(%esp)
  801179:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801180:	00 
  801181:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  801188:	00 
  801189:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801190:	00 
  801191:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  801198:	e8 0b f0 ff ff       	call   8001a8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80119d:	83 c4 2c             	add    $0x2c,%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	57                   	push   %edi
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8011b5:	89 d1                	mov    %edx,%ecx
  8011b7:	89 d3                	mov    %edx,%ebx
  8011b9:	89 d7                	mov    %edx,%edi
  8011bb:	89 d6                	mov    %edx,%esi
  8011bd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <sys_yield>:

void
sys_yield(void)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	57                   	push   %edi
  8011c8:	56                   	push   %esi
  8011c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011d4:	89 d1                	mov    %edx,%ecx
  8011d6:	89 d3                	mov    %edx,%ebx
  8011d8:	89 d7                	mov    %edx,%edi
  8011da:	89 d6                	mov    %edx,%esi
  8011dc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	5f                   	pop    %edi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	57                   	push   %edi
  8011e7:	56                   	push   %esi
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ec:	be 00 00 00 00       	mov    $0x0,%esi
  8011f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8011f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ff:	89 f7                	mov    %esi,%edi
  801201:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801203:	85 c0                	test   %eax,%eax
  801205:	7e 28                	jle    80122f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801207:	89 44 24 10          	mov    %eax,0x10(%esp)
  80120b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801212:	00 
  801213:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  80121a:	00 
  80121b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  80122a:	e8 79 ef ff ff       	call   8001a8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80122f:	83 c4 2c             	add    $0x2c,%esp
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801240:	b8 05 00 00 00       	mov    $0x5,%eax
  801245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801248:	8b 55 08             	mov    0x8(%ebp),%edx
  80124b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801251:	8b 75 18             	mov    0x18(%ebp),%esi
  801254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801256:	85 c0                	test   %eax,%eax
  801258:	7e 28                	jle    801282 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801265:	00 
  801266:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  80126d:	00 
  80126e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801275:	00 
  801276:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  80127d:	e8 26 ef ff ff       	call   8001a8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801282:	83 c4 2c             	add    $0x2c,%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5f                   	pop    %edi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	57                   	push   %edi
  80128e:	56                   	push   %esi
  80128f:	53                   	push   %ebx
  801290:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801293:	bb 00 00 00 00       	mov    $0x0,%ebx
  801298:	b8 06 00 00 00       	mov    $0x6,%eax
  80129d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a3:	89 df                	mov    %ebx,%edi
  8012a5:	89 de                	mov    %ebx,%esi
  8012a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	7e 28                	jle    8012d5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  8012c0:	00 
  8012c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012c8:	00 
  8012c9:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  8012d0:	e8 d3 ee ff ff       	call   8001a8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012d5:	83 c4 2c             	add    $0x2c,%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5f                   	pop    %edi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    

008012dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	57                   	push   %edi
  8012e1:	56                   	push   %esi
  8012e2:	53                   	push   %ebx
  8012e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8012f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f6:	89 df                	mov    %ebx,%edi
  8012f8:	89 de                	mov    %ebx,%esi
  8012fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	7e 28                	jle    801328 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801300:	89 44 24 10          	mov    %eax,0x10(%esp)
  801304:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80130b:	00 
  80130c:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  801313:	00 
  801314:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80131b:	00 
  80131c:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  801323:	e8 80 ee ff ff       	call   8001a8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801328:	83 c4 2c             	add    $0x2c,%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5f                   	pop    %edi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	57                   	push   %edi
  801334:	56                   	push   %esi
  801335:	53                   	push   %ebx
  801336:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801339:	bb 00 00 00 00       	mov    $0x0,%ebx
  80133e:	b8 09 00 00 00       	mov    $0x9,%eax
  801343:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801346:	8b 55 08             	mov    0x8(%ebp),%edx
  801349:	89 df                	mov    %ebx,%edi
  80134b:	89 de                	mov    %ebx,%esi
  80134d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80134f:	85 c0                	test   %eax,%eax
  801351:	7e 28                	jle    80137b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801353:	89 44 24 10          	mov    %eax,0x10(%esp)
  801357:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80135e:	00 
  80135f:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  801366:	00 
  801367:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80136e:	00 
  80136f:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  801376:	e8 2d ee ff ff       	call   8001a8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80137b:	83 c4 2c             	add    $0x2c,%esp
  80137e:	5b                   	pop    %ebx
  80137f:	5e                   	pop    %esi
  801380:	5f                   	pop    %edi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	57                   	push   %edi
  801387:	56                   	push   %esi
  801388:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801389:	be 00 00 00 00       	mov    $0x0,%esi
  80138e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801393:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801396:	8b 55 08             	mov    0x8(%ebp),%edx
  801399:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80139c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80139f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8013a1:	5b                   	pop    %ebx
  8013a2:	5e                   	pop    %esi
  8013a3:	5f                   	pop    %edi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	57                   	push   %edi
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013b4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013bc:	89 cb                	mov    %ecx,%ebx
  8013be:	89 cf                	mov    %ecx,%edi
  8013c0:	89 ce                	mov    %ecx,%esi
  8013c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	7e 28                	jle    8013f0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013cc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8013d3:	00 
  8013d4:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  8013db:	00 
  8013dc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013e3:	00 
  8013e4:	c7 04 24 85 20 80 00 	movl   $0x802085,(%esp)
  8013eb:	e8 b8 ed ff ff       	call   8001a8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013f0:	83 c4 2c             	add    $0x2c,%esp
  8013f3:	5b                   	pop    %ebx
  8013f4:	5e                   	pop    %esi
  8013f5:	5f                   	pop    %edi
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    

008013f8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	57                   	push   %edi
  8013fc:	56                   	push   %esi
  8013fd:	53                   	push   %ebx
  8013fe:	83 ec 2c             	sub    $0x2c,%esp
	void *addr = (void *) utf->utf_fault_va;
  801401:	8b 45 08             	mov    0x8(%ebp),%eax
  801404:	8b 30                	mov    (%eax),%esi
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf(" pgfault : fault va is  %08x\n", ( uint32_t ) addr ) ; 
	//cprintf(" pgfault : fault eip is  %08x\n", ( uint32_t ) utf->utf_eip ) ; 
	pde_t * pde_ptr = ( pde_t * ) ( UVPT + ( PDX(UVPT) << 12 ) + ( PDX(addr) << 2 ) ) ; 
  801406:	89 f0                	mov    %esi,%eax
  801408:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( UVPT + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  80140b:	89 c1                	mov    %eax,%ecx
  80140d:	c1 e1 0c             	shl    $0xc,%ecx
  801410:	89 f2                	mov    %esi,%edx
  801412:	c1 ea 0a             	shr    $0xa,%edx
  801415:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  80141b:	8d bc 11 00 00 40 ef 	lea    -0x10c00000(%ecx,%edx,1),%edi
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  801422:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  801429:	01 
  80142a:	75 1c                	jne    801448 <pgfault+0x50>
		panic(" in inc/fork.c <pgfault> : Page Directory Entry doesn't exsist!\n");
  80142c:	c7 44 24 08 94 20 80 	movl   $0x802094,0x8(%esp)
  801433:	00 
  801434:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80143b:	00 
  80143c:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  801443:	e8 60 ed ff ff       	call   8001a8 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  801448:	8b 07                	mov    (%edi),%eax
  80144a:	a8 01                	test   $0x1,%al
  80144c:	75 1c                	jne    80146a <pgfault+0x72>
		panic(" in inc/fork.c <pgfault> : Page Table Entry doesn't exsist!\n");
  80144e:	c7 44 24 08 d8 20 80 	movl   $0x8020d8,0x8(%esp)
  801455:	00 
  801456:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80145d:	00 
  80145e:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  801465:	e8 3e ed ff ff       	call   8001a8 <_panic>
	if (!( ( ( *pte_ptr ) & PTE_W ) || ( ( *pte_ptr ) & PTE_COW ) ) )
  80146a:	a9 02 08 00 00       	test   $0x802,%eax
  80146f:	75 1c                	jne    80148d <pgfault+0x95>
		panic(" in inc/fork.c <pgfault> : Invalid page!\n");
  801471:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  801478:	00 
  801479:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801480:	00 
  801481:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  801488:	e8 1b ed ff ff       	call   8001a8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid() ;
  80148d:	e8 13 fd ff ff       	call   8011a5 <sys_getenvid>
  801492:	89 c3                	mov    %eax,%ebx
	//cprintf(" pgfault : %d\n %08x\n",envid , PFTEMP); 
	sys_page_alloc( envid , ( void * ) PFTEMP , (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W);  
  801494:	8b 07                	mov    (%edi),%eax
  801496:	25 05 06 00 00       	and    $0x605,%eax
  80149b:	83 c8 02             	or     $0x2,%eax
  80149e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014a9:	00 
  8014aa:	89 1c 24             	mov    %ebx,(%esp)
  8014ad:	e8 31 fd ff ff       	call   8011e3 <sys_page_alloc>
	//cprintf(" Did it reach here and made an alloc call?\n");
	memmove( ( void * ) PFTEMP , ( void * ) ROUNDDOWN( addr , PGSIZE ) , PGSIZE ) ; 
  8014b2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8014b8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8014bf:	00 
  8014c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014c4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8014cb:	e8 94 fa ff ff       	call   800f64 <memmove>
	sys_page_map( envid , ( void * ) PFTEMP , envid , ( void * ) ROUNDDOWN( addr , PGSIZE ) ,  (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W );  
  8014d0:	8b 07                	mov    (%edi),%eax
  8014d2:	25 05 06 00 00       	and    $0x605,%eax
  8014d7:	83 c8 02             	or     $0x2,%eax
  8014da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e6:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014ed:	00 
  8014ee:	89 1c 24             	mov    %ebx,(%esp)
  8014f1:	e8 41 fd ff ff       	call   801237 <sys_page_map>
	sys_page_unmap( envid , PFTEMP ) ; 
  8014f6:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014fd:	00 
  8014fe:	89 1c 24             	mov    %ebx,(%esp)
  801501:	e8 84 fd ff ff       	call   80128a <sys_page_unmap>
	//panic("pgfault not implemented");
}
  801506:	83 c4 2c             	add    $0x2c,%esp
  801509:	5b                   	pop    %ebx
  80150a:	5e                   	pop    %esi
  80150b:	5f                   	pop    %edi
  80150c:	5d                   	pop    %ebp
  80150d:	c3                   	ret    

0080150e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// First , set handler
	set_pgfault_handler(pgfault); 
  801517:	c7 04 24 f8 13 80 00 	movl   $0x8013f8,(%esp)
  80151e:	e8 23 04 00 00       	call   801946 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801523:	b8 07 00 00 00       	mov    $0x7,%eax
  801528:	cd 30                	int    $0x30
  80152a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80152d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
  801530:	85 c0                	test   %eax,%eax
  801532:	79 1c                	jns    801550 <fork+0x42>
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
  801534:	c7 44 24 08 44 21 80 	movl   $0x802144,0x8(%esp)
  80153b:	00 
  80153c:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  801543:	00 
  801544:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  80154b:	e8 58 ec ff ff       	call   8001a8 <_panic>
	if ( childid == 0 ) {
  801550:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801554:	74 17                	je     80156d <fork+0x5f>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  801556:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80155b:	c1 e8 16             	shr    $0x16,%eax
  80155e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801561:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801568:	e9 26 02 00 00       	jmp    801793 <fork+0x285>
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
	if ( childid == 0 ) {
		thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80156d:	e8 33 fc ff ff       	call   8011a5 <sys_getenvid>
  801572:	25 ff 03 00 00       	and    $0x3ff,%eax
  801577:	89 c2                	mov    %eax,%edx
  801579:	c1 e2 07             	shl    $0x7,%edx
  80157c:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801583:	a3 04 30 80 00       	mov    %eax,0x803004
		return 0 ;
  801588:	b8 00 00 00 00       	mov    $0x0,%eax
  80158d:	e9 22 02 00 00       	jmp    8017b4 <fork+0x2a6>
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
  801592:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801595:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  80159c:	01 
  80159d:	0f 84 ec 01 00 00    	je     80178f <fork+0x281>
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
  8015a3:	89 c6                	mov    %eax,%esi
  8015a5:	c1 e0 0c             	shl    $0xc,%eax
  8015a8:	8d b8 00 00 40 ef    	lea    -0x10c00000(%eax),%edi
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
			     ( ptx != PTX(UXSTACKTOP-PGSIZE) ) ) {
				//cprintf(" fork : pdx : %d , ptx : %d\n" , pdx , ptx ) ; 
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
  8015ae:	c1 e6 16             	shl    $0x16,%esi
  8015b1:	bb 00 00 00 00       	mov    $0x0,%ebx
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
			if ( ! ( ( * pte_ptr ) & PTE_P ) )  continue ; 
  8015b6:	f6 04 9f 01          	testb  $0x1,(%edi,%ebx,4)
  8015ba:	0f 84 ba 01 00 00    	je     80177a <fork+0x26c>
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
  8015c0:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  8015c6:	75 0d                	jne    8015d5 <fork+0xc7>
  8015c8:	81 7d dc ba 03 00 00 	cmpl   $0x3ba,-0x24(%ebp)
  8015cf:	0f 84 8a 01 00 00    	je     80175f <fork+0x251>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid() ; 
  8015d5:	e8 cb fb ff ff       	call   8011a5 <sys_getenvid>
  8015da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t addr = pn * PGSIZE ;
	//cprintf(" duppage : now envid is : %d\n", sys_getenvid() ) ;
	//cprintf(" duppage : page address is %08x %d %d\n" , addr,PDX(addr),PTX(addr) ) ;
	pde_t * pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd ) + ( PDX(addr) << 2 ) ) ; 
  8015dd:	89 f0                	mov    %esi,%eax
  8015df:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  8015e2:	89 c1                	mov    %eax,%ecx
  8015e4:	c1 e1 0c             	shl    $0xc,%ecx
  8015e7:	81 c1 00 00 40 ef    	add    $0xef400000,%ecx
  8015ed:	89 f2                	mov    %esi,%edx
  8015ef:	c1 ea 0a             	shr    $0xa,%edx
  8015f2:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8015f8:	01 ca                	add    %ecx,%edx
	
	//cprintf(" duppage : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
	//cprintf(" duppage : pte_ptr's value is : %08x\n" , ( * pte_ptr ) ) ;
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  8015fa:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8015ff:	f6 04 81 01          	testb  $0x1,(%ecx,%eax,4)
  801603:	75 1c                	jne    801621 <fork+0x113>
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
  801605:	c7 44 24 08 78 21 80 	movl   $0x802178,0x8(%esp)
  80160c:	00 
  80160d:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801614:	00 
  801615:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  80161c:	e8 87 eb ff ff       	call   8001a8 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  801621:	8b 02                	mov    (%edx),%eax
  801623:	a8 01                	test   $0x1,%al
  801625:	75 1c                	jne    801643 <fork+0x135>
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
  801627:	c7 44 24 08 bc 21 80 	movl   $0x8021bc,0x8(%esp)
  80162e:	00 
  80162f:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801636:	00 
  801637:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  80163e:	e8 65 eb ff ff       	call   8001a8 <_panic>
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
  801643:	89 c2                	mov    %eax,%edx
  801645:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	if ( perm & PTE_W ) {
  80164b:	a8 02                	test   $0x2,%al
  80164d:	0f 84 8b 00 00 00    	je     8016de <fork+0x1d0>
		if ( sys_page_map( curenvid , ( void * ) addr , 
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
  801653:	89 d0                	mov    %edx,%eax
  801655:	83 f0 02             	xor    $0x2,%eax
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
	if (!( ( * pte_ptr ) & PTE_P ) ) 
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
	if ( perm & PTE_W ) {
		if ( sys_page_map( curenvid , ( void * ) addr , 
  801658:	80 cc 08             	or     $0x8,%ah
  80165b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80165e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801662:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801666:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801669:	89 44 24 08          	mov    %eax,0x8(%esp)
  80166d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801674:	89 04 24             	mov    %eax,(%esp)
  801677:	e8 bb fb ff ff       	call   801237 <sys_page_map>
  80167c:	85 c0                	test   %eax,%eax
  80167e:	79 1c                	jns    80169c <fork+0x18e>
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page! %e\n");
  801680:	c7 44 24 08 fc 21 80 	movl   $0x8021fc,0x8(%esp)
  801687:	00 
  801688:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80168f:	00 
  801690:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  801697:	e8 0c eb ff ff       	call   8001a8 <_panic>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  80169c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80169f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016a3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016b2:	89 04 24             	mov    %eax,(%esp)
  8016b5:	e8 7d fb ff ff       	call   801237 <sys_page_map>
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	0f 89 b8 00 00 00    	jns    80177a <fork+0x26c>
				   curenvid , ( void * ) addr , 
				   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  8016c2:	c7 44 24 08 34 22 80 	movl   $0x802234,0x8(%esp)
  8016c9:	00 
  8016ca:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  8016d1:	00 
  8016d2:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  8016d9:	e8 ca ea ff ff       	call   8001a8 <_panic>
		return 0 ; 	
	}  
	if ( perm & PTE_COW ) {
  8016de:	f6 c4 08             	test   $0x8,%ah
  8016e1:	74 3e                	je     801721 <fork+0x213>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  8016e3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f9:	89 04 24             	mov    %eax,(%esp)
  8016fc:	e8 36 fb ff ff       	call   801237 <sys_page_map>
  801701:	85 c0                	test   %eax,%eax
  801703:	79 75                	jns    80177a <fork+0x26c>
                                   envid    , ( void * ) addr , 
                                   perm ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  801705:	c7 44 24 08 34 22 80 	movl   $0x802234,0x8(%esp)
  80170c:	00 
  80170d:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801714:	00 
  801715:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  80171c:	e8 87 ea ff ff       	call   8001a8 <_panic>
		return 0 ;
	}
	if ( sys_page_map( curenvid , ( void * ) addr , 
  801721:	89 54 24 10          	mov    %edx,0x10(%esp)
  801725:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801729:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80172c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801730:	89 74 24 04          	mov    %esi,0x4(%esp)
  801734:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801737:	89 04 24             	mov    %eax,(%esp)
  80173a:	e8 f8 fa ff ff       	call   801237 <sys_page_map>
  80173f:	85 c0                	test   %eax,%eax
  801741:	79 37                	jns    80177a <fork+0x26c>
		           envid    , ( void * ) addr , 
			   perm ) < 0 ) 
		panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  801743:	c7 44 24 08 34 22 80 	movl   $0x802234,0x8(%esp)
  80174a:	00 
  80174b:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801752:	00 
  801753:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  80175a:	e8 49 ea ff ff       	call   8001a8 <_panic>
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
  80175f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801766:	00 
  801767:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80176e:	ee 
  80176f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801772:	89 04 24             	mov    %eax,(%esp)
  801775:	e8 69 fa ff ff       	call   8011e3 <sys_page_alloc>
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
  80177a:	83 c3 01             	add    $0x1,%ebx
  80177d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801783:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801789:	0f 85 27 fe ff ff    	jne    8015b6 <fork+0xa8>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  80178f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  801793:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801796:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  801799:	0f 85 f3 fd ff ff    	jne    801592 <fork+0x84>
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
		}						
	}
	sys_env_set_status( childid , ENV_RUNNABLE ) ;
  80179f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8017a6:	00 
  8017a7:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8017aa:	89 3c 24             	mov    %edi,(%esp)
  8017ad:	e8 2b fb ff ff       	call   8012dd <sys_env_set_status>
	return childid ;
  8017b2:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8017b4:	83 c4 3c             	add    $0x3c,%esp
  8017b7:	5b                   	pop    %ebx
  8017b8:	5e                   	pop    %esi
  8017b9:	5f                   	pop    %edi
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <sfork>:

// Challenge!
int
sfork(void)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8017c2:	c7 44 24 08 73 22 80 	movl   $0x802273,0x8(%esp)
  8017c9:	00 
  8017ca:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  8017d1:	00 
  8017d2:	c7 04 24 68 22 80 00 	movl   $0x802268,(%esp)
  8017d9:	e8 ca e9 ff ff       	call   8001a8 <_panic>
  8017de:	66 90                	xchg   %ax,%ax

008017e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	56                   	push   %esi
  8017e4:	53                   	push   %ebx
  8017e5:	83 ec 10             	sub    $0x10,%esp
  8017e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8017eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int result = 0 ; 
	if ( pg ) result = sys_ipc_recv(pg);	
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	74 0a                	je     8017ff <ipc_recv+0x1f>
  8017f5:	89 04 24             	mov    %eax,(%esp)
  8017f8:	e8 a9 fb ff ff       	call   8013a6 <sys_ipc_recv>
  8017fd:	eb 0c                	jmp    80180b <ipc_recv+0x2b>
	     else result = sys_ipc_recv((void*)UTOP);
  8017ff:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801806:	e8 9b fb ff ff       	call   8013a6 <sys_ipc_recv>
	if ( result < 0 ) {
  80180b:	85 c0                	test   %eax,%eax
  80180d:	79 16                	jns    801825 <ipc_recv+0x45>
		if ( from_env_store ) 
  80180f:	85 f6                	test   %esi,%esi
  801811:	74 06                	je     801819 <ipc_recv+0x39>
			(*from_env_store) = 0 ;
  801813:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if ( perm_store)
  801819:	85 db                	test   %ebx,%ebx
  80181b:	74 2c                	je     801849 <ipc_recv+0x69>
			(*perm_store) = 0 ;	
  80181d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801823:	eb 24                	jmp    801849 <ipc_recv+0x69>
		return result; 
	}
	if ( from_env_store ) 
  801825:	85 f6                	test   %esi,%esi
  801827:	74 0a                	je     801833 <ipc_recv+0x53>
		(*from_env_store) = thisenv->env_ipc_from ;
  801829:	a1 04 30 80 00       	mov    0x803004,%eax
  80182e:	8b 40 74             	mov    0x74(%eax),%eax
  801831:	89 06                	mov    %eax,(%esi)
	if ( perm_store)
  801833:	85 db                	test   %ebx,%ebx
  801835:	74 0a                	je     801841 <ipc_recv+0x61>
		(*perm_store) = thisenv->env_ipc_perm ;	
  801837:	a1 04 30 80 00       	mov    0x803004,%eax
  80183c:	8b 40 78             	mov    0x78(%eax),%eax
  80183f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801841:	a1 04 30 80 00       	mov    0x803004,%eax
  801846:	8b 40 70             	mov    0x70(%eax),%eax
}
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	5b                   	pop    %ebx
  80184d:	5e                   	pop    %esi
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	57                   	push   %edi
  801854:	56                   	push   %esi
  801855:	53                   	push   %ebx
  801856:	83 ec 1c             	sub    $0x1c,%esp
  801859:	8b 75 0c             	mov    0xc(%ebp),%esi
  80185c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80185f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	
	
	int result = -E_IPC_NOT_RECV ; 
	if ( pg ) 
  801862:	85 db                	test   %ebx,%ebx
  801864:	74 19                	je     80187f <ipc_send+0x2f>
		result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  801866:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80186a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80186e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801872:	8b 45 08             	mov    0x8(%ebp),%eax
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 06 fb ff ff       	call   801383 <sys_ipc_try_send>
  80187d:	eb 1b                	jmp    80189a <ipc_send+0x4a>
	else
		result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  80187f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801883:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80188a:	ee 
  80188b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80188f:	8b 45 08             	mov    0x8(%ebp),%eax
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 e9 fa ff ff       	call   801383 <sys_ipc_try_send>
	
	if ( result == 0 ) return ; 
  80189a:	85 c0                	test   %eax,%eax
  80189c:	74 61                	je     8018ff <ipc_send+0xaf>
	if ( result == -E_IPC_NOT_RECV ) {
  80189e:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8018a1:	75 3c                	jne    8018df <ipc_send+0x8f>
		if ( pg ) 
  8018a3:	85 db                	test   %ebx,%ebx
  8018a5:	74 19                	je     8018c0 <ipc_send+0x70>
			result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  8018a7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b6:	89 04 24             	mov    %eax,(%esp)
  8018b9:	e8 c5 fa ff ff       	call   801383 <sys_ipc_try_send>
  8018be:	eb 1b                	jmp    8018db <ipc_send+0x8b>
		else
			result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  8018c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018c4:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8018cb:	ee 
  8018cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d3:	89 04 24             	mov    %eax,(%esp)
  8018d6:	e8 a8 fa ff ff       	call   801383 <sys_ipc_try_send>
		if ( result == 0 ) return ; 
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	74 20                	je     8018ff <ipc_send+0xaf>
	}
	panic("ipc_send error %e.",result);
  8018df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e3:	c7 44 24 08 89 22 80 	movl   $0x802289,0x8(%esp)
  8018ea:	00 
  8018eb:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8018f2:	00 
  8018f3:	c7 04 24 9c 22 80 00 	movl   $0x80229c,(%esp)
  8018fa:	e8 a9 e8 ff ff       	call   8001a8 <_panic>
}
  8018ff:	83 c4 1c             	add    $0x1c,%esp
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	5f                   	pop    %edi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80190d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801912:	89 c2                	mov    %eax,%edx
  801914:	c1 e2 07             	shl    $0x7,%edx
  801917:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80191e:	8b 52 50             	mov    0x50(%edx),%edx
  801921:	39 ca                	cmp    %ecx,%edx
  801923:	75 11                	jne    801936 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801925:	89 c2                	mov    %eax,%edx
  801927:	c1 e2 07             	shl    $0x7,%edx
  80192a:	8d 84 c2 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,8),%eax
  801931:	8b 40 40             	mov    0x40(%eax),%eax
  801934:	eb 0e                	jmp    801944 <ipc_find_env+0x3d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801936:	83 c0 01             	add    $0x1,%eax
  801939:	3d 00 04 00 00       	cmp    $0x400,%eax
  80193e:	75 d2                	jne    801912 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801940:	66 b8 00 00          	mov    $0x0,%ax
}
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    

00801946 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80194c:	83 3d 08 30 80 00 00 	cmpl   $0x0,0x803008
  801953:	75 32                	jne    801987 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  801955:	e8 4b f8 ff ff       	call   8011a5 <sys_getenvid>
  80195a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801961:	00 
  801962:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801969:	ee 
  80196a:	89 04 24             	mov    %eax,(%esp)
  80196d:	e8 71 f8 ff ff       	call   8011e3 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  801972:	e8 2e f8 ff ff       	call   8011a5 <sys_getenvid>
  801977:	c7 44 24 04 91 19 80 	movl   $0x801991,0x4(%esp)
  80197e:	00 
  80197f:	89 04 24             	mov    %eax,(%esp)
  801982:	e8 a9 f9 ff ff       	call   801330 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801987:	8b 45 08             	mov    0x8(%ebp),%eax
  80198a:	a3 08 30 80 00       	mov    %eax,0x803008
}
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801991:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801992:	a1 08 30 80 00       	mov    0x803008,%eax
	call *%eax
  801997:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801999:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  80199c:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  80199f:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  8019a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  8019a7:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  8019aa:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  8019ae:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  8019b0:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  8019b1:	83 c4 04             	add    $0x4,%esp
	popfl 	
  8019b4:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8019b5:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8019b6:	c3                   	ret    
  8019b7:	66 90                	xchg   %ax,%ax
  8019b9:	66 90                	xchg   %ax,%ax
  8019bb:	66 90                	xchg   %ax,%ax
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
