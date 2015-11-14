
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 e2 00 00 00       	call   800113 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 28 11 00 00       	call   801175 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 85 14 00 00       	call   8014de <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 1a                	jmp    800081 <umain+0x41>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 15                	je     800081 <umain+0x41>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	89 f0                	mov    %esi,%eax
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	89 c2                	mov    %eax,%edx
  800075:	c1 e2 07             	shl    $0x7,%edx
  800078:	8d 94 c2 04 00 c0 ee 	lea    -0x113ffffc(%edx,%eax,8),%edx
  80007f:	eb 0c                	jmp    80008d <umain+0x4d>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800081:	e8 0e 11 00 00       	call   801194 <sys_yield>
		return;
  800086:	e9 81 00 00 00       	jmp    80010c <umain+0xcc>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  80008b:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80008d:	8b 42 50             	mov    0x50(%edx),%eax
  800090:	85 c0                	test   %eax,%eax
  800092:	75 f7                	jne    80008b <umain+0x4b>
  800094:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800099:	e8 f6 10 00 00       	call   801194 <sys_yield>
  80009e:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000a3:	8b 15 04 30 80 00    	mov    0x803004,%edx
  8000a9:	83 c2 01             	add    $0x1,%edx
  8000ac:	89 15 04 30 80 00    	mov    %edx,0x803004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b2:	83 e8 01             	sub    $0x1,%eax
  8000b5:	75 ec                	jne    8000a3 <umain+0x63>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000b7:	83 eb 01             	sub    $0x1,%ebx
  8000ba:	75 dd                	jne    800099 <umain+0x59>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000bc:	a1 04 30 80 00       	mov    0x803004,%eax
  8000c1:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000c6:	74 25                	je     8000ed <umain+0xad>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000c8:	a1 04 30 80 00       	mov    0x803004,%eax
  8000cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d1:	c7 44 24 08 c0 1a 80 	movl   $0x801ac0,0x8(%esp)
  8000d8:	00 
  8000d9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 e8 1a 80 00 	movl   $0x801ae8,(%esp)
  8000e8:	e8 86 00 00 00       	call   800173 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ed:	a1 08 30 80 00       	mov    0x803008,%eax
  8000f2:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000f5:	8b 40 48             	mov    0x48(%eax),%eax
  8000f8:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800100:	c7 04 24 fb 1a 80 00 	movl   $0x801afb,(%esp)
  800107:	e8 60 01 00 00       	call   80026c <cprintf>

}
  80010c:	83 c4 10             	add    $0x10,%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
  800118:	83 ec 10             	sub    $0x10,%esp
  80011b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80011e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800121:	e8 4f 10 00 00       	call   801175 <sys_getenvid>
  800126:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012b:	89 c2                	mov    %eax,%edx
  80012d:	c1 e2 07             	shl    $0x7,%edx
  800130:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800137:	a3 08 30 80 00       	mov    %eax,0x803008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013c:	85 db                	test   %ebx,%ebx
  80013e:	7e 07                	jle    800147 <libmain+0x34>
		binaryname = argv[0];
  800140:	8b 06                	mov    (%esi),%eax
  800142:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800147:	89 74 24 04          	mov    %esi,0x4(%esp)
  80014b:	89 1c 24             	mov    %ebx,(%esp)
  80014e:	e8 ed fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800153:	e8 07 00 00 00       	call   80015f <exit>
}
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	5b                   	pop    %ebx
  80015c:	5e                   	pop    %esi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800165:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80016c:	e8 b2 0f 00 00       	call   801123 <sys_env_destroy>
}
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
  800178:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80017b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800184:	e8 ec 0f 00 00       	call   801175 <sys_getenvid>
  800189:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800190:	8b 55 08             	mov    0x8(%ebp),%edx
  800193:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800197:	89 74 24 08          	mov    %esi,0x8(%esp)
  80019b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019f:	c7 04 24 24 1b 80 00 	movl   $0x801b24,(%esp)
  8001a6:	e8 c1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001af:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b2:	89 04 24             	mov    %eax,(%esp)
  8001b5:	e8 51 00 00 00       	call   80020b <vcprintf>
	cprintf("\n");
  8001ba:	c7 04 24 17 1b 80 00 	movl   $0x801b17,(%esp)
  8001c1:	e8 a6 00 00 00       	call   80026c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c6:	cc                   	int3   
  8001c7:	eb fd                	jmp    8001c6 <_panic+0x53>

008001c9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 14             	sub    $0x14,%esp
  8001d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d3:	8b 13                	mov    (%ebx),%edx
  8001d5:	8d 42 01             	lea    0x1(%edx),%eax
  8001d8:	89 03                	mov    %eax,(%ebx)
  8001da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001e1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e6:	75 19                	jne    800201 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001e8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ef:	00 
  8001f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 eb 0e 00 00       	call   8010e6 <sys_cputs>
		b->idx = 0;
  8001fb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800201:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800205:	83 c4 14             	add    $0x14,%esp
  800208:	5b                   	pop    %ebx
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    

0080020b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800214:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021b:	00 00 00 
	b.cnt = 0;
  80021e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800225:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022f:	8b 45 08             	mov    0x8(%ebp),%eax
  800232:	89 44 24 08          	mov    %eax,0x8(%esp)
  800236:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800240:	c7 04 24 c9 01 80 00 	movl   $0x8001c9,(%esp)
  800247:	e8 b3 02 00 00       	call   8004ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800252:	89 44 24 04          	mov    %eax,0x4(%esp)
  800256:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 82 0e 00 00       	call   8010e6 <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	8b 45 08             	mov    0x8(%ebp),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	e8 87 ff ff ff       	call   80020b <vcprintf>
	va_end(ap);

	return cnt;
}
  800284:	c9                   	leave  
  800285:	c3                   	ret    
  800286:	66 90                	xchg   %ax,%ax
  800288:	66 90                	xchg   %ax,%ax
  80028a:	66 90                	xchg   %ax,%ax
  80028c:	66 90                	xchg   %ax,%ax
  80028e:	66 90                	xchg   %ax,%ax

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 3c             	sub    $0x3c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d7                	mov    %edx,%edi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	89 c3                	mov    %eax,%ebx
  8002a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8002af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002bd:	39 d9                	cmp    %ebx,%ecx
  8002bf:	72 05                	jb     8002c6 <printnum+0x36>
  8002c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002c4:	77 69                	ja     80032f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002cd:	83 ee 01             	sub    $0x1,%esi
  8002d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002e0:	89 c3                	mov    %eax,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ff:	e8 1c 15 00 00       	call   801820 <__udivdi3>
  800304:	89 d9                	mov    %ebx,%ecx
  800306:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	89 54 24 04          	mov    %edx,0x4(%esp)
  800315:	89 fa                	mov    %edi,%edx
  800317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031a:	e8 71 ff ff ff       	call   800290 <printnum>
  80031f:	eb 1b                	jmp    80033c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800321:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800325:	8b 45 18             	mov    0x18(%ebp),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff d3                	call   *%ebx
  80032d:	eb 03                	jmp    800332 <printnum+0xa2>
  80032f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800332:	83 ee 01             	sub    $0x1,%esi
  800335:	85 f6                	test   %esi,%esi
  800337:	7f e8                	jg     800321 <printnum+0x91>
  800339:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800340:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800344:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800347:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800355:	89 04 24             	mov    %eax,(%esp)
  800358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035f:	e8 ec 15 00 00       	call   801950 <__umoddi3>
  800364:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800368:	0f be 80 47 1b 80 00 	movsbl 0x801b47(%eax),%eax
  80036f:	89 04 24             	mov    %eax,(%esp)
  800372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800375:	ff d0                	call   *%eax
}
  800377:	83 c4 3c             	add    $0x3c,%esp
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	57                   	push   %edi
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	83 ec 3c             	sub    $0x3c,%esp
  800388:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80038b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80038e:	89 cf                	mov    %ecx,%edi
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  800393:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800396:	8b 45 0c             	mov    0xc(%ebp),%eax
  800399:	89 c3                	mov    %eax,%ebx
  80039b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80039e:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ac:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003af:	39 d9                	cmp    %ebx,%ecx
  8003b1:	72 13                	jb     8003c6 <cprintnum+0x47>
  8003b3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003b6:	76 0e                	jbe    8003c6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8003b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003bb:	0b 45 18             	or     0x18(%ebp),%eax
  8003be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003c4:	eb 6a                	jmp    800430 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8003c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003cd:	83 ee 01             	sub    $0x1,%esi
  8003d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003e0:	89 c3                	mov    %eax,%ebx
  8003e2:	89 d6                	mov    %edx,%esi
  8003e4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003e7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8003ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	e8 1c 14 00 00       	call   801820 <__udivdi3>
  800404:	89 d9                	mov    %ebx,%ecx
  800406:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80040a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80040e:	89 04 24             	mov    %eax,(%esp)
  800411:	89 54 24 04          	mov    %edx,0x4(%esp)
  800415:	89 f9                	mov    %edi,%ecx
  800417:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80041a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80041d:	e8 5d ff ff ff       	call   80037f <cprintnum>
  800422:	eb 16                	jmp    80043a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800424:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80042b:	89 04 24             	mov    %eax,(%esp)
  80042e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800430:	83 ee 01             	sub    $0x1,%esi
  800433:	85 f6                	test   %esi,%esi
  800435:	7f ed                	jg     800424 <cprintnum+0xa5>
  800437:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80043a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800442:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800445:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800448:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800450:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800453:	89 04 24             	mov    %eax,(%esp)
  800456:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045d:	e8 ee 14 00 00       	call   801950 <__umoddi3>
  800462:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800466:	0f be 80 47 1b 80 00 	movsbl 0x801b47(%eax),%eax
  80046d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800476:	ff d0                	call   *%eax
}
  800478:	83 c4 3c             	add    $0x3c,%esp
  80047b:	5b                   	pop    %ebx
  80047c:	5e                   	pop    %esi
  80047d:	5f                   	pop    %edi
  80047e:	5d                   	pop    %ebp
  80047f:	c3                   	ret    

00800480 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800483:	83 fa 01             	cmp    $0x1,%edx
  800486:	7e 0e                	jle    800496 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800488:	8b 10                	mov    (%eax),%edx
  80048a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048d:	89 08                	mov    %ecx,(%eax)
  80048f:	8b 02                	mov    (%edx),%eax
  800491:	8b 52 04             	mov    0x4(%edx),%edx
  800494:	eb 22                	jmp    8004b8 <getuint+0x38>
	else if (lflag)
  800496:	85 d2                	test   %edx,%edx
  800498:	74 10                	je     8004aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80049a:	8b 10                	mov    (%eax),%edx
  80049c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049f:	89 08                	mov    %ecx,(%eax)
  8004a1:	8b 02                	mov    (%edx),%eax
  8004a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a8:	eb 0e                	jmp    8004b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 02                	mov    (%edx),%eax
  8004b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b8:	5d                   	pop    %ebp
  8004b9:	c3                   	ret    

008004ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ba:	55                   	push   %ebp
  8004bb:	89 e5                	mov    %esp,%ebp
  8004bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c4:	8b 10                	mov    (%eax),%edx
  8004c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c9:	73 0a                	jae    8004d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ce:	89 08                	mov    %ecx,(%eax)
  8004d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d3:	88 02                	mov    %al,(%edx)
}
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    

008004d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f5:	89 04 24             	mov    %eax,(%esp)
  8004f8:	e8 02 00 00 00       	call   8004ff <vprintfmt>
	va_end(ap);
}
  8004fd:	c9                   	leave  
  8004fe:	c3                   	ret    

008004ff <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	57                   	push   %edi
  800503:	56                   	push   %esi
  800504:	53                   	push   %ebx
  800505:	83 ec 3c             	sub    $0x3c,%esp
  800508:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80050b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80050e:	eb 14                	jmp    800524 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800510:	85 c0                	test   %eax,%eax
  800512:	0f 84 b3 03 00 00    	je     8008cb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800518:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800522:	89 f3                	mov    %esi,%ebx
  800524:	8d 73 01             	lea    0x1(%ebx),%esi
  800527:	0f b6 03             	movzbl (%ebx),%eax
  80052a:	83 f8 25             	cmp    $0x25,%eax
  80052d:	75 e1                	jne    800510 <vprintfmt+0x11>
  80052f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800533:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80053a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800541:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800548:	ba 00 00 00 00       	mov    $0x0,%edx
  80054d:	eb 1d                	jmp    80056c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800551:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800555:	eb 15                	jmp    80056c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800559:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80055d:	eb 0d                	jmp    80056c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80055f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800562:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800565:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80056f:	0f b6 0e             	movzbl (%esi),%ecx
  800572:	0f b6 c1             	movzbl %cl,%eax
  800575:	83 e9 23             	sub    $0x23,%ecx
  800578:	80 f9 55             	cmp    $0x55,%cl
  80057b:	0f 87 2a 03 00 00    	ja     8008ab <vprintfmt+0x3ac>
  800581:	0f b6 c9             	movzbl %cl,%ecx
  800584:	ff 24 8d 00 1c 80 00 	jmp    *0x801c00(,%ecx,4)
  80058b:	89 de                	mov    %ebx,%esi
  80058d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800592:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800595:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800599:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80059c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80059f:	83 fb 09             	cmp    $0x9,%ebx
  8005a2:	77 36                	ja     8005da <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a7:	eb e9                	jmp    800592 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 48 04             	lea    0x4(%eax),%ecx
  8005af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b9:	eb 22                	jmp    8005dd <vprintfmt+0xde>
  8005bb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005be:	85 c9                	test   %ecx,%ecx
  8005c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c5:	0f 49 c1             	cmovns %ecx,%eax
  8005c8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	89 de                	mov    %ebx,%esi
  8005cd:	eb 9d                	jmp    80056c <vprintfmt+0x6d>
  8005cf:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005d8:	eb 92                	jmp    80056c <vprintfmt+0x6d>
  8005da:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8005dd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e1:	79 89                	jns    80056c <vprintfmt+0x6d>
  8005e3:	e9 77 ff ff ff       	jmp    80055f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ed:	e9 7a ff ff ff       	jmp    80056c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 04 24             	mov    %eax,(%esp)
  800604:	ff 55 08             	call   *0x8(%ebp)
			break;
  800607:	e9 18 ff ff ff       	jmp    800524 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 00                	mov    (%eax),%eax
  800617:	99                   	cltd   
  800618:	31 d0                	xor    %edx,%eax
  80061a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061c:	83 f8 09             	cmp    $0x9,%eax
  80061f:	7f 0b                	jg     80062c <vprintfmt+0x12d>
  800621:	8b 14 85 c0 1e 80 00 	mov    0x801ec0(,%eax,4),%edx
  800628:	85 d2                	test   %edx,%edx
  80062a:	75 20                	jne    80064c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80062c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800630:	c7 44 24 08 5f 1b 80 	movl   $0x801b5f,0x8(%esp)
  800637:	00 
  800638:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063c:	8b 45 08             	mov    0x8(%ebp),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	e8 90 fe ff ff       	call   8004d7 <printfmt>
  800647:	e9 d8 fe ff ff       	jmp    800524 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80064c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800650:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800657:	00 
  800658:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	e8 70 fe ff ff       	call   8004d7 <printfmt>
  800667:	e9 b8 fe ff ff       	jmp    800524 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80066f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800672:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 04             	lea    0x4(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800680:	85 f6                	test   %esi,%esi
  800682:	b8 58 1b 80 00       	mov    $0x801b58,%eax
  800687:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80068a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80068e:	0f 84 97 00 00 00    	je     80072b <vprintfmt+0x22c>
  800694:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800698:	0f 8e 9b 00 00 00    	jle    800739 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006a2:	89 34 24             	mov    %esi,(%esp)
  8006a5:	e8 ce 06 00 00       	call   800d78 <strnlen>
  8006aa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006ad:	29 c2                	sub    %eax,%edx
  8006af:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8006b2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006b6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006b9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006c2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c4:	eb 0f                	jmp    8006d5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d2:	83 eb 01             	sub    $0x1,%ebx
  8006d5:	85 db                	test   %ebx,%ebx
  8006d7:	7f ed                	jg     8006c6 <vprintfmt+0x1c7>
  8006d9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006dc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006df:	85 d2                	test   %edx,%edx
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	0f 49 c2             	cmovns %edx,%eax
  8006e9:	29 c2                	sub    %eax,%edx
  8006eb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006ee:	89 d7                	mov    %edx,%edi
  8006f0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006f3:	eb 50                	jmp    800745 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f9:	74 1e                	je     800719 <vprintfmt+0x21a>
  8006fb:	0f be d2             	movsbl %dl,%edx
  8006fe:	83 ea 20             	sub    $0x20,%edx
  800701:	83 fa 5e             	cmp    $0x5e,%edx
  800704:	76 13                	jbe    800719 <vprintfmt+0x21a>
					putch('?', putdat);
  800706:	8b 45 0c             	mov    0xc(%ebp),%eax
  800709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800714:	ff 55 08             	call   *0x8(%ebp)
  800717:	eb 0d                	jmp    800726 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800719:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800726:	83 ef 01             	sub    $0x1,%edi
  800729:	eb 1a                	jmp    800745 <vprintfmt+0x246>
  80072b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80072e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800731:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800734:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800737:	eb 0c                	jmp    800745 <vprintfmt+0x246>
  800739:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80073c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80073f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800742:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800745:	83 c6 01             	add    $0x1,%esi
  800748:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80074c:	0f be c2             	movsbl %dl,%eax
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 27                	je     80077a <vprintfmt+0x27b>
  800753:	85 db                	test   %ebx,%ebx
  800755:	78 9e                	js     8006f5 <vprintfmt+0x1f6>
  800757:	83 eb 01             	sub    $0x1,%ebx
  80075a:	79 99                	jns    8006f5 <vprintfmt+0x1f6>
  80075c:	89 f8                	mov    %edi,%eax
  80075e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800761:	8b 75 08             	mov    0x8(%ebp),%esi
  800764:	89 c3                	mov    %eax,%ebx
  800766:	eb 1a                	jmp    800782 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800768:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800773:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800775:	83 eb 01             	sub    $0x1,%ebx
  800778:	eb 08                	jmp    800782 <vprintfmt+0x283>
  80077a:	89 fb                	mov    %edi,%ebx
  80077c:	8b 75 08             	mov    0x8(%ebp),%esi
  80077f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800782:	85 db                	test   %ebx,%ebx
  800784:	7f e2                	jg     800768 <vprintfmt+0x269>
  800786:	89 75 08             	mov    %esi,0x8(%ebp)
  800789:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80078c:	e9 93 fd ff ff       	jmp    800524 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800791:	83 fa 01             	cmp    $0x1,%edx
  800794:	7e 16                	jle    8007ac <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8d 50 08             	lea    0x8(%eax),%edx
  80079c:	89 55 14             	mov    %edx,0x14(%ebp)
  80079f:	8b 50 04             	mov    0x4(%eax),%edx
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007a7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007aa:	eb 32                	jmp    8007de <vprintfmt+0x2df>
	else if (lflag)
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 18                	je     8007c8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 50 04             	lea    0x4(%eax),%edx
  8007b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b9:	8b 30                	mov    (%eax),%esi
  8007bb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007be:	89 f0                	mov    %esi,%eax
  8007c0:	c1 f8 1f             	sar    $0x1f,%eax
  8007c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007c6:	eb 16                	jmp    8007de <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d1:	8b 30                	mov    (%eax),%esi
  8007d3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007d6:	89 f0                	mov    %esi,%eax
  8007d8:	c1 f8 1f             	sar    $0x1f,%eax
  8007db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ed:	0f 89 80 00 00 00    	jns    800873 <vprintfmt+0x374>
				putch('-', putdat);
  8007f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007fe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800801:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800804:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800807:	f7 d8                	neg    %eax
  800809:	83 d2 00             	adc    $0x0,%edx
  80080c:	f7 da                	neg    %edx
			}
			base = 10;
  80080e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800813:	eb 5e                	jmp    800873 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800815:	8d 45 14             	lea    0x14(%ebp),%eax
  800818:	e8 63 fc ff ff       	call   800480 <getuint>
			base = 10;
  80081d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800822:	eb 4f                	jmp    800873 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800824:	8d 45 14             	lea    0x14(%ebp),%eax
  800827:	e8 54 fc ff ff       	call   800480 <getuint>
			base = 8 ;
  80082c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800831:	eb 40                	jmp    800873 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800833:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800837:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80083e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800841:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800845:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80084c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8d 50 04             	lea    0x4(%eax),%edx
  800855:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800858:	8b 00                	mov    (%eax),%eax
  80085a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80085f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800864:	eb 0d                	jmp    800873 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800866:	8d 45 14             	lea    0x14(%ebp),%eax
  800869:	e8 12 fc ff ff       	call   800480 <getuint>
			base = 16;
  80086e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800873:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800877:	89 74 24 10          	mov    %esi,0x10(%esp)
  80087b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80087e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800882:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088d:	89 fa                	mov    %edi,%edx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	e8 f9 f9 ff ff       	call   800290 <printnum>
			break;
  800897:	e9 88 fc ff ff       	jmp    800524 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a0:	89 04 24             	mov    %eax,(%esp)
  8008a3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008a6:	e9 79 fc ff ff       	jmp    800524 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008af:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008b6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b9:	89 f3                	mov    %esi,%ebx
  8008bb:	eb 03                	jmp    8008c0 <vprintfmt+0x3c1>
  8008bd:	83 eb 01             	sub    $0x1,%ebx
  8008c0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008c4:	75 f7                	jne    8008bd <vprintfmt+0x3be>
  8008c6:	e9 59 fc ff ff       	jmp    800524 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008cb:	83 c4 3c             	add    $0x3c,%esp
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5f                   	pop    %edi
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	57                   	push   %edi
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	83 ec 3c             	sub    $0x3c,%esp
  8008dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  8008df:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e2:	8d 50 04             	lea    0x4(%eax),%edx
  8008e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e8:	8b 00                	mov    (%eax),%eax
  8008ea:	c1 e0 08             	shl    $0x8,%eax
  8008ed:	0f b7 c0             	movzwl %ax,%eax
  8008f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  8008f3:	83 c8 25             	or     $0x25,%eax
  8008f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8008f9:	eb 1a                	jmp    800915 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	0f 84 a9 03 00 00    	je     800cac <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800903:	8b 75 0c             	mov    0xc(%ebp),%esi
  800906:	89 74 24 04          	mov    %esi,0x4(%esp)
  80090a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800913:	89 fb                	mov    %edi,%ebx
  800915:	8d 7b 01             	lea    0x1(%ebx),%edi
  800918:	0f b6 03             	movzbl (%ebx),%eax
  80091b:	83 f8 25             	cmp    $0x25,%eax
  80091e:	75 db                	jne    8008fb <cvprintfmt+0x28>
  800920:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800924:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80092b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800930:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800937:	ba 00 00 00 00       	mov    $0x0,%edx
  80093c:	eb 18                	jmp    800956 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800940:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800944:	eb 10                	jmp    800956 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800946:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800948:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80094c:	eb 08                	jmp    800956 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80094e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800951:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800956:	8d 5f 01             	lea    0x1(%edi),%ebx
  800959:	0f b6 0f             	movzbl (%edi),%ecx
  80095c:	0f b6 c1             	movzbl %cl,%eax
  80095f:	83 e9 23             	sub    $0x23,%ecx
  800962:	80 f9 55             	cmp    $0x55,%cl
  800965:	0f 87 1f 03 00 00    	ja     800c8a <cvprintfmt+0x3b7>
  80096b:	0f b6 c9             	movzbl %cl,%ecx
  80096e:	ff 24 8d 58 1d 80 00 	jmp    *0x801d58(,%ecx,4)
  800975:	89 df                	mov    %ebx,%edi
  800977:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80097c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80097f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800983:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800986:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800989:	83 f9 09             	cmp    $0x9,%ecx
  80098c:	77 33                	ja     8009c1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80098e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800991:	eb e9                	jmp    80097c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	8d 48 04             	lea    0x4(%eax),%ecx
  800999:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80099c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8009a0:	eb 1f                	jmp    8009c1 <cvprintfmt+0xee>
  8009a2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8009a5:	85 ff                	test   %edi,%edi
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ac:	0f 49 c7             	cmovns %edi,%eax
  8009af:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b2:	89 df                	mov    %ebx,%edi
  8009b4:	eb a0                	jmp    800956 <cvprintfmt+0x83>
  8009b6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8009b8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8009bf:	eb 95                	jmp    800956 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  8009c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009c5:	79 8f                	jns    800956 <cvprintfmt+0x83>
  8009c7:	eb 85                	jmp    80094e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009c9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009cc:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009ce:	66 90                	xchg   %ax,%ax
  8009d0:	eb 84                	jmp    800956 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  8009d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d5:	8d 50 04             	lea    0x4(%eax),%edx
  8009d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009e5:	0b 10                	or     (%eax),%edx
  8009e7:	89 14 24             	mov    %edx,(%esp)
  8009ea:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009ed:	e9 23 ff ff ff       	jmp    800915 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f5:	8d 50 04             	lea    0x4(%eax),%edx
  8009f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009fb:	8b 00                	mov    (%eax),%eax
  8009fd:	99                   	cltd   
  8009fe:	31 d0                	xor    %edx,%eax
  800a00:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a02:	83 f8 09             	cmp    $0x9,%eax
  800a05:	7f 0b                	jg     800a12 <cvprintfmt+0x13f>
  800a07:	8b 14 85 c0 1e 80 00 	mov    0x801ec0(,%eax,4),%edx
  800a0e:	85 d2                	test   %edx,%edx
  800a10:	75 23                	jne    800a35 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800a12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a16:	c7 44 24 08 5f 1b 80 	movl   $0x801b5f,0x8(%esp)
  800a1d:	00 
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	89 04 24             	mov    %eax,(%esp)
  800a2b:	e8 a7 fa ff ff       	call   8004d7 <printfmt>
  800a30:	e9 e0 fe ff ff       	jmp    800915 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800a35:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a39:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800a40:	00 
  800a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	89 04 24             	mov    %eax,(%esp)
  800a4e:	e8 84 fa ff ff       	call   8004d7 <printfmt>
  800a53:	e9 bd fe ff ff       	jmp    800915 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a58:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a5b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800a5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a61:	8d 48 04             	lea    0x4(%eax),%ecx
  800a64:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a67:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a69:	85 ff                	test   %edi,%edi
  800a6b:	b8 58 1b 80 00       	mov    $0x801b58,%eax
  800a70:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a73:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a77:	74 61                	je     800ada <cvprintfmt+0x207>
  800a79:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a7d:	7e 5b                	jle    800ada <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a83:	89 3c 24             	mov    %edi,(%esp)
  800a86:	e8 ed 02 00 00       	call   800d78 <strnlen>
  800a8b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a8e:	29 c2                	sub    %eax,%edx
  800a90:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800a93:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a97:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a9a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a9d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800aa0:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa6:	89 d3                	mov    %edx,%ebx
  800aa8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800aaa:	eb 0f                	jmp    800abb <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab3:	89 3c 24             	mov    %edi,(%esp)
  800ab6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ab8:	83 eb 01             	sub    $0x1,%ebx
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	7f ed                	jg     800aac <cvprintfmt+0x1d9>
  800abf:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800ac2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ac5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ac8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800acb:	85 d2                	test   %edx,%edx
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	0f 49 c2             	cmovns %edx,%eax
  800ad5:	29 c2                	sub    %eax,%edx
  800ad7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800ada:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800add:	83 c8 3f             	or     $0x3f,%eax
  800ae0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ae6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ae9:	eb 36                	jmp    800b21 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aeb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aef:	74 1d                	je     800b0e <cvprintfmt+0x23b>
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 20             	sub    $0x20,%edx
  800af7:	83 fa 5e             	cmp    $0x5e,%edx
  800afa:	76 12                	jbe    800b0e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b03:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b06:	89 04 24             	mov    %eax,(%esp)
  800b09:	ff 55 08             	call   *0x8(%ebp)
  800b0c:	eb 10                	jmp    800b1e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b11:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b15:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b18:	89 04 24             	mov    %eax,(%esp)
  800b1b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b1e:	83 eb 01             	sub    $0x1,%ebx
  800b21:	83 c7 01             	add    $0x1,%edi
  800b24:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800b28:	0f be c2             	movsbl %dl,%eax
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	74 27                	je     800b56 <cvprintfmt+0x283>
  800b2f:	85 f6                	test   %esi,%esi
  800b31:	78 b8                	js     800aeb <cvprintfmt+0x218>
  800b33:	83 ee 01             	sub    $0x1,%esi
  800b36:	79 b3                	jns    800aeb <cvprintfmt+0x218>
  800b38:	89 d8                	mov    %ebx,%eax
  800b3a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b40:	89 c3                	mov    %eax,%ebx
  800b42:	eb 18                	jmp    800b5c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800b44:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b4f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800b51:	83 eb 01             	sub    $0x1,%ebx
  800b54:	eb 06                	jmp    800b5c <cvprintfmt+0x289>
  800b56:	8b 75 08             	mov    0x8(%ebp),%esi
  800b59:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b5c:	85 db                	test   %ebx,%ebx
  800b5e:	7f e4                	jg     800b44 <cvprintfmt+0x271>
  800b60:	89 75 08             	mov    %esi,0x8(%ebp)
  800b63:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800b66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b69:	e9 a7 fd ff ff       	jmp    800915 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b6e:	83 fa 01             	cmp    $0x1,%edx
  800b71:	7e 10                	jle    800b83 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800b73:	8b 45 14             	mov    0x14(%ebp),%eax
  800b76:	8d 50 08             	lea    0x8(%eax),%edx
  800b79:	89 55 14             	mov    %edx,0x14(%ebp)
  800b7c:	8b 30                	mov    (%eax),%esi
  800b7e:	8b 78 04             	mov    0x4(%eax),%edi
  800b81:	eb 26                	jmp    800ba9 <cvprintfmt+0x2d6>
	else if (lflag)
  800b83:	85 d2                	test   %edx,%edx
  800b85:	74 12                	je     800b99 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800b87:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8a:	8d 50 04             	lea    0x4(%eax),%edx
  800b8d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b90:	8b 30                	mov    (%eax),%esi
  800b92:	89 f7                	mov    %esi,%edi
  800b94:	c1 ff 1f             	sar    $0x1f,%edi
  800b97:	eb 10                	jmp    800ba9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800b99:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9c:	8d 50 04             	lea    0x4(%eax),%edx
  800b9f:	89 55 14             	mov    %edx,0x14(%ebp)
  800ba2:	8b 30                	mov    (%eax),%esi
  800ba4:	89 f7                	mov    %esi,%edi
  800ba6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ba9:	89 f0                	mov    %esi,%eax
  800bab:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800bad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800bb2:	85 ff                	test   %edi,%edi
  800bb4:	0f 89 8e 00 00 00    	jns    800c48 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bc4:	83 c8 2d             	or     $0x2d,%eax
  800bc7:	89 04 24             	mov    %eax,(%esp)
  800bca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800bcd:	89 f0                	mov    %esi,%eax
  800bcf:	89 fa                	mov    %edi,%edx
  800bd1:	f7 d8                	neg    %eax
  800bd3:	83 d2 00             	adc    $0x0,%edx
  800bd6:	f7 da                	neg    %edx
			}
			base = 10;
  800bd8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bdd:	eb 69                	jmp    800c48 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bdf:	8d 45 14             	lea    0x14(%ebp),%eax
  800be2:	e8 99 f8 ff ff       	call   800480 <getuint>
			base = 10;
  800be7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bec:	eb 5a                	jmp    800c48 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800bee:	8d 45 14             	lea    0x14(%ebp),%eax
  800bf1:	e8 8a f8 ff ff       	call   800480 <getuint>
			base = 8 ;
  800bf6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800bfb:	eb 4b                	jmp    800c48 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c04:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800c07:	89 f0                	mov    %esi,%eax
  800c09:	83 c8 30             	or     $0x30,%eax
  800c0c:	89 04 24             	mov    %eax,(%esp)
  800c0f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c19:	89 f0                	mov    %esi,%eax
  800c1b:	83 c8 78             	or     $0x78,%eax
  800c1e:	89 04 24             	mov    %eax,(%esp)
  800c21:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c24:	8b 45 14             	mov    0x14(%ebp),%eax
  800c27:	8d 50 04             	lea    0x4(%eax),%edx
  800c2a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800c2d:	8b 00                	mov    (%eax),%eax
  800c2f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c34:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800c39:	eb 0d                	jmp    800c48 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c3e:	e8 3d f8 ff ff       	call   800480 <getuint>
			base = 16;
  800c43:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800c48:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800c4c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c50:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800c53:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c5b:	89 04 24             	mov    %eax,(%esp)
  800c5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c6b:	e8 0f f7 ff ff       	call   80037f <cprintnum>
			break;
  800c70:	e9 a0 fc ff ff       	jmp    800915 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800c75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c78:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c7c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800c7f:	89 04 24             	mov    %eax,(%esp)
  800c82:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c85:	e9 8b fc ff ff       	jmp    800915 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c94:	89 04 24             	mov    %eax,(%esp)
  800c97:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c9a:	89 fb                	mov    %edi,%ebx
  800c9c:	eb 03                	jmp    800ca1 <cvprintfmt+0x3ce>
  800c9e:	83 eb 01             	sub    $0x1,%ebx
  800ca1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ca5:	75 f7                	jne    800c9e <cvprintfmt+0x3cb>
  800ca7:	e9 69 fc ff ff       	jmp    800915 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800cac:	83 c4 3c             	add    $0x3c,%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800cba:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800cbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	89 04 24             	mov    %eax,(%esp)
  800cd5:	e8 f9 fb ff ff       	call   8008d3 <cvprintfmt>
	va_end(ap);
}
  800cda:	c9                   	leave  
  800cdb:	c3                   	ret    

00800cdc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 28             	sub    $0x28,%esp
  800ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ce8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ceb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cf2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	74 30                	je     800d2d <vsnprintf+0x51>
  800cfd:	85 d2                	test   %edx,%edx
  800cff:	7e 2c                	jle    800d2d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d01:	8b 45 14             	mov    0x14(%ebp),%eax
  800d04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d08:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d16:	c7 04 24 ba 04 80 00 	movl   $0x8004ba,(%esp)
  800d1d:	e8 dd f7 ff ff       	call   8004ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d25:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d2b:	eb 05                	jmp    800d32 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d32:	c9                   	leave  
  800d33:	c3                   	ret    

00800d34 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d3a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d41:	8b 45 10             	mov    0x10(%ebp),%eax
  800d44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	89 04 24             	mov    %eax,(%esp)
  800d55:	e8 82 ff ff ff       	call   800cdc <vsnprintf>
	va_end(ap);

	return rc;
}
  800d5a:	c9                   	leave  
  800d5b:	c3                   	ret    
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d66:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6b:	eb 03                	jmp    800d70 <strlen+0x10>
		n++;
  800d6d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d74:	75 f7                	jne    800d6d <strlen+0xd>
		n++;
	return n;
}
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
  800d86:	eb 03                	jmp    800d8b <strnlen+0x13>
		n++;
  800d88:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d8b:	39 d0                	cmp    %edx,%eax
  800d8d:	74 06                	je     800d95 <strnlen+0x1d>
  800d8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d93:	75 f3                	jne    800d88 <strnlen+0x10>
		n++;
	return n;
}
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	53                   	push   %ebx
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	83 c2 01             	add    $0x1,%edx
  800da6:	83 c1 01             	add    $0x1,%ecx
  800da9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800dad:	88 5a ff             	mov    %bl,-0x1(%edx)
  800db0:	84 db                	test   %bl,%bl
  800db2:	75 ef                	jne    800da3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800db4:	5b                   	pop    %ebx
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 08             	sub    $0x8,%esp
  800dbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800dc1:	89 1c 24             	mov    %ebx,(%esp)
  800dc4:	e8 97 ff ff ff       	call   800d60 <strlen>
	strcpy(dst + len, src);
  800dc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dd0:	01 d8                	add    %ebx,%eax
  800dd2:	89 04 24             	mov    %eax,(%esp)
  800dd5:	e8 bd ff ff ff       	call   800d97 <strcpy>
	return dst;
}
  800dda:	89 d8                	mov    %ebx,%eax
  800ddc:	83 c4 08             	add    $0x8,%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	8b 75 08             	mov    0x8(%ebp),%esi
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	89 f3                	mov    %esi,%ebx
  800def:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800df2:	89 f2                	mov    %esi,%edx
  800df4:	eb 0f                	jmp    800e05 <strncpy+0x23>
		*dst++ = *src;
  800df6:	83 c2 01             	add    $0x1,%edx
  800df9:	0f b6 01             	movzbl (%ecx),%eax
  800dfc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dff:	80 39 01             	cmpb   $0x1,(%ecx)
  800e02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e05:	39 da                	cmp    %ebx,%edx
  800e07:	75 ed                	jne    800df6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	8b 75 08             	mov    0x8(%ebp),%esi
  800e17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e1d:	89 f0                	mov    %esi,%eax
  800e1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e23:	85 c9                	test   %ecx,%ecx
  800e25:	75 0b                	jne    800e32 <strlcpy+0x23>
  800e27:	eb 1d                	jmp    800e46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e29:	83 c0 01             	add    $0x1,%eax
  800e2c:	83 c2 01             	add    $0x1,%edx
  800e2f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e32:	39 d8                	cmp    %ebx,%eax
  800e34:	74 0b                	je     800e41 <strlcpy+0x32>
  800e36:	0f b6 0a             	movzbl (%edx),%ecx
  800e39:	84 c9                	test   %cl,%cl
  800e3b:	75 ec                	jne    800e29 <strlcpy+0x1a>
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	eb 02                	jmp    800e43 <strlcpy+0x34>
  800e41:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800e43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800e46:	29 f0                	sub    %esi,%eax
}
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e55:	eb 06                	jmp    800e5d <strcmp+0x11>
		p++, q++;
  800e57:	83 c1 01             	add    $0x1,%ecx
  800e5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e5d:	0f b6 01             	movzbl (%ecx),%eax
  800e60:	84 c0                	test   %al,%al
  800e62:	74 04                	je     800e68 <strcmp+0x1c>
  800e64:	3a 02                	cmp    (%edx),%al
  800e66:	74 ef                	je     800e57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e68:	0f b6 c0             	movzbl %al,%eax
  800e6b:	0f b6 12             	movzbl (%edx),%edx
  800e6e:	29 d0                	sub    %edx,%eax
}
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	53                   	push   %ebx
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
  800e79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7c:	89 c3                	mov    %eax,%ebx
  800e7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e81:	eb 06                	jmp    800e89 <strncmp+0x17>
		n--, p++, q++;
  800e83:	83 c0 01             	add    $0x1,%eax
  800e86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e89:	39 d8                	cmp    %ebx,%eax
  800e8b:	74 15                	je     800ea2 <strncmp+0x30>
  800e8d:	0f b6 08             	movzbl (%eax),%ecx
  800e90:	84 c9                	test   %cl,%cl
  800e92:	74 04                	je     800e98 <strncmp+0x26>
  800e94:	3a 0a                	cmp    (%edx),%cl
  800e96:	74 eb                	je     800e83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e98:	0f b6 00             	movzbl (%eax),%eax
  800e9b:	0f b6 12             	movzbl (%edx),%edx
  800e9e:	29 d0                	sub    %edx,%eax
  800ea0:	eb 05                	jmp    800ea7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ea7:	5b                   	pop    %ebx
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800eb4:	eb 07                	jmp    800ebd <strchr+0x13>
		if (*s == c)
  800eb6:	38 ca                	cmp    %cl,%dl
  800eb8:	74 0f                	je     800ec9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800eba:	83 c0 01             	add    $0x1,%eax
  800ebd:	0f b6 10             	movzbl (%eax),%edx
  800ec0:	84 d2                	test   %dl,%dl
  800ec2:	75 f2                	jne    800eb6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ec4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ed5:	eb 07                	jmp    800ede <strfind+0x13>
		if (*s == c)
  800ed7:	38 ca                	cmp    %cl,%dl
  800ed9:	74 0a                	je     800ee5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800edb:	83 c0 01             	add    $0x1,%eax
  800ede:	0f b6 10             	movzbl (%eax),%edx
  800ee1:	84 d2                	test   %dl,%dl
  800ee3:	75 f2                	jne    800ed7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ef0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ef3:	85 c9                	test   %ecx,%ecx
  800ef5:	74 36                	je     800f2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ef7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800efd:	75 28                	jne    800f27 <memset+0x40>
  800eff:	f6 c1 03             	test   $0x3,%cl
  800f02:	75 23                	jne    800f27 <memset+0x40>
		c &= 0xFF;
  800f04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f08:	89 d3                	mov    %edx,%ebx
  800f0a:	c1 e3 08             	shl    $0x8,%ebx
  800f0d:	89 d6                	mov    %edx,%esi
  800f0f:	c1 e6 18             	shl    $0x18,%esi
  800f12:	89 d0                	mov    %edx,%eax
  800f14:	c1 e0 10             	shl    $0x10,%eax
  800f17:	09 f0                	or     %esi,%eax
  800f19:	09 c2                	or     %eax,%edx
  800f1b:	89 d0                	mov    %edx,%eax
  800f1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f1f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f22:	fc                   	cld    
  800f23:	f3 ab                	rep stos %eax,%es:(%edi)
  800f25:	eb 06                	jmp    800f2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2a:	fc                   	cld    
  800f2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f2d:	89 f8                	mov    %edi,%eax
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f42:	39 c6                	cmp    %eax,%esi
  800f44:	73 35                	jae    800f7b <memmove+0x47>
  800f46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f49:	39 d0                	cmp    %edx,%eax
  800f4b:	73 2e                	jae    800f7b <memmove+0x47>
		s += n;
		d += n;
  800f4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800f50:	89 d6                	mov    %edx,%esi
  800f52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f5a:	75 13                	jne    800f6f <memmove+0x3b>
  800f5c:	f6 c1 03             	test   $0x3,%cl
  800f5f:	75 0e                	jne    800f6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f61:	83 ef 04             	sub    $0x4,%edi
  800f64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f6a:	fd                   	std    
  800f6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f6d:	eb 09                	jmp    800f78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f6f:	83 ef 01             	sub    $0x1,%edi
  800f72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f75:	fd                   	std    
  800f76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f78:	fc                   	cld    
  800f79:	eb 1d                	jmp    800f98 <memmove+0x64>
  800f7b:	89 f2                	mov    %esi,%edx
  800f7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f7f:	f6 c2 03             	test   $0x3,%dl
  800f82:	75 0f                	jne    800f93 <memmove+0x5f>
  800f84:	f6 c1 03             	test   $0x3,%cl
  800f87:	75 0a                	jne    800f93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f89:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f8c:	89 c7                	mov    %eax,%edi
  800f8e:	fc                   	cld    
  800f8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f91:	eb 05                	jmp    800f98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f93:	89 c7                	mov    %eax,%edi
  800f95:	fc                   	cld    
  800f96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	89 04 24             	mov    %eax,(%esp)
  800fb6:	e8 79 ff ff ff       	call   800f34 <memmove>
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
  800fc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	89 d6                	mov    %edx,%esi
  800fca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fcd:	eb 1a                	jmp    800fe9 <memcmp+0x2c>
		if (*s1 != *s2)
  800fcf:	0f b6 02             	movzbl (%edx),%eax
  800fd2:	0f b6 19             	movzbl (%ecx),%ebx
  800fd5:	38 d8                	cmp    %bl,%al
  800fd7:	74 0a                	je     800fe3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800fd9:	0f b6 c0             	movzbl %al,%eax
  800fdc:	0f b6 db             	movzbl %bl,%ebx
  800fdf:	29 d8                	sub    %ebx,%eax
  800fe1:	eb 0f                	jmp    800ff2 <memcmp+0x35>
		s1++, s2++;
  800fe3:	83 c2 01             	add    $0x1,%edx
  800fe6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe9:	39 f2                	cmp    %esi,%edx
  800feb:	75 e2                	jne    800fcf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fff:	89 c2                	mov    %eax,%edx
  801001:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801004:	eb 07                	jmp    80100d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801006:	38 08                	cmp    %cl,(%eax)
  801008:	74 07                	je     801011 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80100a:	83 c0 01             	add    $0x1,%eax
  80100d:	39 d0                	cmp    %edx,%eax
  80100f:	72 f5                	jb     801006 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
  801019:	8b 55 08             	mov    0x8(%ebp),%edx
  80101c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80101f:	eb 03                	jmp    801024 <strtol+0x11>
		s++;
  801021:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801024:	0f b6 0a             	movzbl (%edx),%ecx
  801027:	80 f9 09             	cmp    $0x9,%cl
  80102a:	74 f5                	je     801021 <strtol+0xe>
  80102c:	80 f9 20             	cmp    $0x20,%cl
  80102f:	74 f0                	je     801021 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801031:	80 f9 2b             	cmp    $0x2b,%cl
  801034:	75 0a                	jne    801040 <strtol+0x2d>
		s++;
  801036:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801039:	bf 00 00 00 00       	mov    $0x0,%edi
  80103e:	eb 11                	jmp    801051 <strtol+0x3e>
  801040:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801045:	80 f9 2d             	cmp    $0x2d,%cl
  801048:	75 07                	jne    801051 <strtol+0x3e>
		s++, neg = 1;
  80104a:	8d 52 01             	lea    0x1(%edx),%edx
  80104d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801051:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801056:	75 15                	jne    80106d <strtol+0x5a>
  801058:	80 3a 30             	cmpb   $0x30,(%edx)
  80105b:	75 10                	jne    80106d <strtol+0x5a>
  80105d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801061:	75 0a                	jne    80106d <strtol+0x5a>
		s += 2, base = 16;
  801063:	83 c2 02             	add    $0x2,%edx
  801066:	b8 10 00 00 00       	mov    $0x10,%eax
  80106b:	eb 10                	jmp    80107d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80106d:	85 c0                	test   %eax,%eax
  80106f:	75 0c                	jne    80107d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801071:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801073:	80 3a 30             	cmpb   $0x30,(%edx)
  801076:	75 05                	jne    80107d <strtol+0x6a>
		s++, base = 8;
  801078:	83 c2 01             	add    $0x1,%edx
  80107b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80107d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801082:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801085:	0f b6 0a             	movzbl (%edx),%ecx
  801088:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80108b:	89 f0                	mov    %esi,%eax
  80108d:	3c 09                	cmp    $0x9,%al
  80108f:	77 08                	ja     801099 <strtol+0x86>
			dig = *s - '0';
  801091:	0f be c9             	movsbl %cl,%ecx
  801094:	83 e9 30             	sub    $0x30,%ecx
  801097:	eb 20                	jmp    8010b9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801099:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80109c:	89 f0                	mov    %esi,%eax
  80109e:	3c 19                	cmp    $0x19,%al
  8010a0:	77 08                	ja     8010aa <strtol+0x97>
			dig = *s - 'a' + 10;
  8010a2:	0f be c9             	movsbl %cl,%ecx
  8010a5:	83 e9 57             	sub    $0x57,%ecx
  8010a8:	eb 0f                	jmp    8010b9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8010aa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8010ad:	89 f0                	mov    %esi,%eax
  8010af:	3c 19                	cmp    $0x19,%al
  8010b1:	77 16                	ja     8010c9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8010b3:	0f be c9             	movsbl %cl,%ecx
  8010b6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010b9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8010bc:	7d 0f                	jge    8010cd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8010be:	83 c2 01             	add    $0x1,%edx
  8010c1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8010c5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8010c7:	eb bc                	jmp    801085 <strtol+0x72>
  8010c9:	89 d8                	mov    %ebx,%eax
  8010cb:	eb 02                	jmp    8010cf <strtol+0xbc>
  8010cd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8010cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010d3:	74 05                	je     8010da <strtol+0xc7>
		*endptr = (char *) s;
  8010d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8010da:	f7 d8                	neg    %eax
  8010dc:	85 ff                	test   %edi,%edi
  8010de:	0f 44 c3             	cmove  %ebx,%eax
}
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	57                   	push   %edi
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f7:	89 c3                	mov    %eax,%ebx
  8010f9:	89 c7                	mov    %eax,%edi
  8010fb:	89 c6                	mov    %eax,%esi
  8010fd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010ff:	5b                   	pop    %ebx
  801100:	5e                   	pop    %esi
  801101:	5f                   	pop    %edi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <sys_cgetc>:

int
sys_cgetc(void)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	57                   	push   %edi
  801108:	56                   	push   %esi
  801109:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110a:	ba 00 00 00 00       	mov    $0x0,%edx
  80110f:	b8 01 00 00 00       	mov    $0x1,%eax
  801114:	89 d1                	mov    %edx,%ecx
  801116:	89 d3                	mov    %edx,%ebx
  801118:	89 d7                	mov    %edx,%edi
  80111a:	89 d6                	mov    %edx,%esi
  80111c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801131:	b8 03 00 00 00       	mov    $0x3,%eax
  801136:	8b 55 08             	mov    0x8(%ebp),%edx
  801139:	89 cb                	mov    %ecx,%ebx
  80113b:	89 cf                	mov    %ecx,%edi
  80113d:	89 ce                	mov    %ecx,%esi
  80113f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801141:	85 c0                	test   %eax,%eax
  801143:	7e 28                	jle    80116d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801145:	89 44 24 10          	mov    %eax,0x10(%esp)
  801149:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801150:	00 
  801151:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  801158:	00 
  801159:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801160:	00 
  801161:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  801168:	e8 06 f0 ff ff       	call   800173 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80116d:	83 c4 2c             	add    $0x2c,%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	57                   	push   %edi
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117b:	ba 00 00 00 00       	mov    $0x0,%edx
  801180:	b8 02 00 00 00       	mov    $0x2,%eax
  801185:	89 d1                	mov    %edx,%ecx
  801187:	89 d3                	mov    %edx,%ebx
  801189:	89 d7                	mov    %edx,%edi
  80118b:	89 d6                	mov    %edx,%esi
  80118d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <sys_yield>:

void
sys_yield(void)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	57                   	push   %edi
  801198:	56                   	push   %esi
  801199:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119a:	ba 00 00 00 00       	mov    $0x0,%edx
  80119f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011a4:	89 d1                	mov    %edx,%ecx
  8011a6:	89 d3                	mov    %edx,%ebx
  8011a8:	89 d7                	mov    %edx,%edi
  8011aa:	89 d6                	mov    %edx,%esi
  8011ac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011ae:	5b                   	pop    %ebx
  8011af:	5e                   	pop    %esi
  8011b0:	5f                   	pop    %edi
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	57                   	push   %edi
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011bc:	be 00 00 00 00       	mov    $0x0,%esi
  8011c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8011c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011cf:	89 f7                	mov    %esi,%edi
  8011d1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	7e 28                	jle    8011ff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011db:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011f2:	00 
  8011f3:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  8011fa:	e8 74 ef ff ff       	call   800173 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011ff:	83 c4 2c             	add    $0x2c,%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	57                   	push   %edi
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801210:	b8 05 00 00 00       	mov    $0x5,%eax
  801215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801218:	8b 55 08             	mov    0x8(%ebp),%edx
  80121b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80121e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801221:	8b 75 18             	mov    0x18(%ebp),%esi
  801224:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801226:	85 c0                	test   %eax,%eax
  801228:	7e 28                	jle    801252 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801235:	00 
  801236:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  80123d:	00 
  80123e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801245:	00 
  801246:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  80124d:	e8 21 ef ff ff       	call   800173 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801252:	83 c4 2c             	add    $0x2c,%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	57                   	push   %edi
  80125e:	56                   	push   %esi
  80125f:	53                   	push   %ebx
  801260:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801263:	bb 00 00 00 00       	mov    $0x0,%ebx
  801268:	b8 06 00 00 00       	mov    $0x6,%eax
  80126d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801270:	8b 55 08             	mov    0x8(%ebp),%edx
  801273:	89 df                	mov    %ebx,%edi
  801275:	89 de                	mov    %ebx,%esi
  801277:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801279:	85 c0                	test   %eax,%eax
  80127b:	7e 28                	jle    8012a5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80127d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801281:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801288:	00 
  801289:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  801290:	00 
  801291:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801298:	00 
  801299:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  8012a0:	e8 ce ee ff ff       	call   800173 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012a5:	83 c4 2c             	add    $0x2c,%esp
  8012a8:	5b                   	pop    %ebx
  8012a9:	5e                   	pop    %esi
  8012aa:	5f                   	pop    %edi
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	57                   	push   %edi
  8012b1:	56                   	push   %esi
  8012b2:	53                   	push   %ebx
  8012b3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8012c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c6:	89 df                	mov    %ebx,%edi
  8012c8:	89 de                	mov    %ebx,%esi
  8012ca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	7e 28                	jle    8012f8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8012db:	00 
  8012dc:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  8012e3:	00 
  8012e4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012eb:	00 
  8012ec:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  8012f3:	e8 7b ee ff ff       	call   800173 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012f8:	83 c4 2c             	add    $0x2c,%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	57                   	push   %edi
  801304:	56                   	push   %esi
  801305:	53                   	push   %ebx
  801306:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801309:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130e:	b8 09 00 00 00       	mov    $0x9,%eax
  801313:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801316:	8b 55 08             	mov    0x8(%ebp),%edx
  801319:	89 df                	mov    %ebx,%edi
  80131b:	89 de                	mov    %ebx,%esi
  80131d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80131f:	85 c0                	test   %eax,%eax
  801321:	7e 28                	jle    80134b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801323:	89 44 24 10          	mov    %eax,0x10(%esp)
  801327:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80132e:	00 
  80132f:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  801336:	00 
  801337:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80133e:	00 
  80133f:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  801346:	e8 28 ee ff ff       	call   800173 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80134b:	83 c4 2c             	add    $0x2c,%esp
  80134e:	5b                   	pop    %ebx
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	57                   	push   %edi
  801357:	56                   	push   %esi
  801358:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801359:	be 00 00 00 00       	mov    $0x0,%esi
  80135e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801363:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801366:	8b 55 08             	mov    0x8(%ebp),%edx
  801369:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80136c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80136f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5f                   	pop    %edi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	57                   	push   %edi
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
  80137c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80137f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801384:	b8 0c 00 00 00       	mov    $0xc,%eax
  801389:	8b 55 08             	mov    0x8(%ebp),%edx
  80138c:	89 cb                	mov    %ecx,%ebx
  80138e:	89 cf                	mov    %ecx,%edi
  801390:	89 ce                	mov    %ecx,%esi
  801392:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801394:	85 c0                	test   %eax,%eax
  801396:	7e 28                	jle    8013c0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801398:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8013a3:	00 
  8013a4:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  8013ab:	00 
  8013ac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013b3:	00 
  8013b4:	c7 04 24 05 1f 80 00 	movl   $0x801f05,(%esp)
  8013bb:	e8 b3 ed ff ff       	call   800173 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013c0:	83 c4 2c             	add    $0x2c,%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5f                   	pop    %edi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	57                   	push   %edi
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 2c             	sub    $0x2c,%esp
	void *addr = (void *) utf->utf_fault_va;
  8013d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d4:	8b 30                	mov    (%eax),%esi
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf(" pgfault : fault va is  %08x\n", ( uint32_t ) addr ) ; 
	//cprintf(" pgfault : fault eip is  %08x\n", ( uint32_t ) utf->utf_eip ) ; 
	pde_t * pde_ptr = ( pde_t * ) ( UVPT + ( PDX(UVPT) << 12 ) + ( PDX(addr) << 2 ) ) ; 
  8013d6:	89 f0                	mov    %esi,%eax
  8013d8:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( UVPT + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  8013db:	89 c1                	mov    %eax,%ecx
  8013dd:	c1 e1 0c             	shl    $0xc,%ecx
  8013e0:	89 f2                	mov    %esi,%edx
  8013e2:	c1 ea 0a             	shr    $0xa,%edx
  8013e5:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8013eb:	8d bc 11 00 00 40 ef 	lea    -0x10c00000(%ecx,%edx,1),%edi
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  8013f2:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  8013f9:	01 
  8013fa:	75 1c                	jne    801418 <pgfault+0x50>
		panic(" in inc/fork.c <pgfault> : Page Directory Entry doesn't exsist!\n");
  8013fc:	c7 44 24 08 14 1f 80 	movl   $0x801f14,0x8(%esp)
  801403:	00 
  801404:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80140b:	00 
  80140c:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  801413:	e8 5b ed ff ff       	call   800173 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  801418:	8b 07                	mov    (%edi),%eax
  80141a:	a8 01                	test   $0x1,%al
  80141c:	75 1c                	jne    80143a <pgfault+0x72>
		panic(" in inc/fork.c <pgfault> : Page Table Entry doesn't exsist!\n");
  80141e:	c7 44 24 08 58 1f 80 	movl   $0x801f58,0x8(%esp)
  801425:	00 
  801426:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80142d:	00 
  80142e:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  801435:	e8 39 ed ff ff       	call   800173 <_panic>
	if (!( ( ( *pte_ptr ) & PTE_W ) || ( ( *pte_ptr ) & PTE_COW ) ) )
  80143a:	a9 02 08 00 00       	test   $0x802,%eax
  80143f:	75 1c                	jne    80145d <pgfault+0x95>
		panic(" in inc/fork.c <pgfault> : Invalid page!\n");
  801441:	c7 44 24 08 98 1f 80 	movl   $0x801f98,0x8(%esp)
  801448:	00 
  801449:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801450:	00 
  801451:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  801458:	e8 16 ed ff ff       	call   800173 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid() ;
  80145d:	e8 13 fd ff ff       	call   801175 <sys_getenvid>
  801462:	89 c3                	mov    %eax,%ebx
	//cprintf(" pgfault : %d\n %08x\n",envid , PFTEMP); 
	sys_page_alloc( envid , ( void * ) PFTEMP , (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W);  
  801464:	8b 07                	mov    (%edi),%eax
  801466:	25 05 06 00 00       	and    $0x605,%eax
  80146b:	83 c8 02             	or     $0x2,%eax
  80146e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801472:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801479:	00 
  80147a:	89 1c 24             	mov    %ebx,(%esp)
  80147d:	e8 31 fd ff ff       	call   8011b3 <sys_page_alloc>
	//cprintf(" Did it reach here and made an alloc call?\n");
	memmove( ( void * ) PFTEMP , ( void * ) ROUNDDOWN( addr , PGSIZE ) , PGSIZE ) ; 
  801482:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801488:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80148f:	00 
  801490:	89 74 24 04          	mov    %esi,0x4(%esp)
  801494:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80149b:	e8 94 fa ff ff       	call   800f34 <memmove>
	sys_page_map( envid , ( void * ) PFTEMP , envid , ( void * ) ROUNDDOWN( addr , PGSIZE ) ,  (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W );  
  8014a0:	8b 07                	mov    (%edi),%eax
  8014a2:	25 05 06 00 00       	and    $0x605,%eax
  8014a7:	83 c8 02             	or     $0x2,%eax
  8014aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014b6:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014bd:	00 
  8014be:	89 1c 24             	mov    %ebx,(%esp)
  8014c1:	e8 41 fd ff ff       	call   801207 <sys_page_map>
	sys_page_unmap( envid , PFTEMP ) ; 
  8014c6:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014cd:	00 
  8014ce:	89 1c 24             	mov    %ebx,(%esp)
  8014d1:	e8 84 fd ff ff       	call   80125a <sys_page_unmap>
	//panic("pgfault not implemented");
}
  8014d6:	83 c4 2c             	add    $0x2c,%esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5f                   	pop    %edi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	57                   	push   %edi
  8014e2:	56                   	push   %esi
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// First , set handler
	set_pgfault_handler(pgfault); 
  8014e7:	c7 04 24 c8 13 80 00 	movl   $0x8013c8,(%esp)
  8014ee:	e8 bb 02 00 00       	call   8017ae <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014f3:	b8 07 00 00 00       	mov    $0x7,%eax
  8014f8:	cd 30                	int    $0x30
  8014fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8014fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
  801500:	85 c0                	test   %eax,%eax
  801502:	79 1c                	jns    801520 <fork+0x42>
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
  801504:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  80150b:	00 
  80150c:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  801513:	00 
  801514:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  80151b:	e8 53 ec ff ff       	call   800173 <_panic>
	if ( childid == 0 ) {
  801520:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801524:	74 17                	je     80153d <fork+0x5f>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  801526:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80152b:	c1 e8 16             	shr    $0x16,%eax
  80152e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801531:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801538:	e9 26 02 00 00       	jmp    801763 <fork+0x285>
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
	if ( childid == 0 ) {
		thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80153d:	e8 33 fc ff ff       	call   801175 <sys_getenvid>
  801542:	25 ff 03 00 00       	and    $0x3ff,%eax
  801547:	89 c2                	mov    %eax,%edx
  801549:	c1 e2 07             	shl    $0x7,%edx
  80154c:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801553:	a3 08 30 80 00       	mov    %eax,0x803008
		return 0 ;
  801558:	b8 00 00 00 00       	mov    $0x0,%eax
  80155d:	e9 22 02 00 00       	jmp    801784 <fork+0x2a6>
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
  801562:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801565:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  80156c:	01 
  80156d:	0f 84 ec 01 00 00    	je     80175f <fork+0x281>
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
  801573:	89 c6                	mov    %eax,%esi
  801575:	c1 e0 0c             	shl    $0xc,%eax
  801578:	8d b8 00 00 40 ef    	lea    -0x10c00000(%eax),%edi
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
			     ( ptx != PTX(UXSTACKTOP-PGSIZE) ) ) {
				//cprintf(" fork : pdx : %d , ptx : %d\n" , pdx , ptx ) ; 
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
  80157e:	c1 e6 16             	shl    $0x16,%esi
  801581:	bb 00 00 00 00       	mov    $0x0,%ebx
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
			if ( ! ( ( * pte_ptr ) & PTE_P ) )  continue ; 
  801586:	f6 04 9f 01          	testb  $0x1,(%edi,%ebx,4)
  80158a:	0f 84 ba 01 00 00    	je     80174a <fork+0x26c>
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
  801590:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  801596:	75 0d                	jne    8015a5 <fork+0xc7>
  801598:	81 7d dc ba 03 00 00 	cmpl   $0x3ba,-0x24(%ebp)
  80159f:	0f 84 8a 01 00 00    	je     80172f <fork+0x251>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid() ; 
  8015a5:	e8 cb fb ff ff       	call   801175 <sys_getenvid>
  8015aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t addr = pn * PGSIZE ;
	//cprintf(" duppage : now envid is : %d\n", sys_getenvid() ) ;
	//cprintf(" duppage : page address is %08x %d %d\n" , addr,PDX(addr),PTX(addr) ) ;
	pde_t * pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd ) + ( PDX(addr) << 2 ) ) ; 
  8015ad:	89 f0                	mov    %esi,%eax
  8015af:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  8015b2:	89 c1                	mov    %eax,%ecx
  8015b4:	c1 e1 0c             	shl    $0xc,%ecx
  8015b7:	81 c1 00 00 40 ef    	add    $0xef400000,%ecx
  8015bd:	89 f2                	mov    %esi,%edx
  8015bf:	c1 ea 0a             	shr    $0xa,%edx
  8015c2:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8015c8:	01 ca                	add    %ecx,%edx
	
	//cprintf(" duppage : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
	//cprintf(" duppage : pte_ptr's value is : %08x\n" , ( * pte_ptr ) ) ;
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  8015ca:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8015cf:	f6 04 81 01          	testb  $0x1,(%ecx,%eax,4)
  8015d3:	75 1c                	jne    8015f1 <fork+0x113>
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
  8015d5:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  8015dc:	00 
  8015dd:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8015e4:	00 
  8015e5:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  8015ec:	e8 82 eb ff ff       	call   800173 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  8015f1:	8b 02                	mov    (%edx),%eax
  8015f3:	a8 01                	test   $0x1,%al
  8015f5:	75 1c                	jne    801613 <fork+0x135>
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
  8015f7:	c7 44 24 08 3c 20 80 	movl   $0x80203c,0x8(%esp)
  8015fe:	00 
  8015ff:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801606:	00 
  801607:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  80160e:	e8 60 eb ff ff       	call   800173 <_panic>
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
  801613:	89 c2                	mov    %eax,%edx
  801615:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	if ( perm & PTE_W ) {
  80161b:	a8 02                	test   $0x2,%al
  80161d:	0f 84 8b 00 00 00    	je     8016ae <fork+0x1d0>
		if ( sys_page_map( curenvid , ( void * ) addr , 
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
  801623:	89 d0                	mov    %edx,%eax
  801625:	83 f0 02             	xor    $0x2,%eax
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
	if (!( ( * pte_ptr ) & PTE_P ) ) 
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
	if ( perm & PTE_W ) {
		if ( sys_page_map( curenvid , ( void * ) addr , 
  801628:	80 cc 08             	or     $0x8,%ah
  80162b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80162e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801632:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801636:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801639:	89 44 24 08          	mov    %eax,0x8(%esp)
  80163d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801641:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801644:	89 04 24             	mov    %eax,(%esp)
  801647:	e8 bb fb ff ff       	call   801207 <sys_page_map>
  80164c:	85 c0                	test   %eax,%eax
  80164e:	79 1c                	jns    80166c <fork+0x18e>
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page! %e\n");
  801650:	c7 44 24 08 7c 20 80 	movl   $0x80207c,0x8(%esp)
  801657:	00 
  801658:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80165f:	00 
  801660:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  801667:	e8 07 eb ff ff       	call   800173 <_panic>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  80166c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80166f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801673:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801677:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80167e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801682:	89 04 24             	mov    %eax,(%esp)
  801685:	e8 7d fb ff ff       	call   801207 <sys_page_map>
  80168a:	85 c0                	test   %eax,%eax
  80168c:	0f 89 b8 00 00 00    	jns    80174a <fork+0x26c>
				   curenvid , ( void * ) addr , 
				   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  801692:	c7 44 24 08 b4 20 80 	movl   $0x8020b4,0x8(%esp)
  801699:	00 
  80169a:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  8016a1:	00 
  8016a2:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  8016a9:	e8 c5 ea ff ff       	call   800173 <_panic>
		return 0 ; 	
	}  
	if ( perm & PTE_COW ) {
  8016ae:	f6 c4 08             	test   $0x8,%ah
  8016b1:	74 3e                	je     8016f1 <fork+0x213>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  8016b3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016c9:	89 04 24             	mov    %eax,(%esp)
  8016cc:	e8 36 fb ff ff       	call   801207 <sys_page_map>
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	79 75                	jns    80174a <fork+0x26c>
                                   envid    , ( void * ) addr , 
                                   perm ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  8016d5:	c7 44 24 08 b4 20 80 	movl   $0x8020b4,0x8(%esp)
  8016dc:	00 
  8016dd:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  8016e4:	00 
  8016e5:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  8016ec:	e8 82 ea ff ff       	call   800173 <_panic>
		return 0 ;
	}
	if ( sys_page_map( curenvid , ( void * ) addr , 
  8016f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801700:	89 74 24 04          	mov    %esi,0x4(%esp)
  801704:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801707:	89 04 24             	mov    %eax,(%esp)
  80170a:	e8 f8 fa ff ff       	call   801207 <sys_page_map>
  80170f:	85 c0                	test   %eax,%eax
  801711:	79 37                	jns    80174a <fork+0x26c>
		           envid    , ( void * ) addr , 
			   perm ) < 0 ) 
		panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  801713:	c7 44 24 08 b4 20 80 	movl   $0x8020b4,0x8(%esp)
  80171a:	00 
  80171b:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801722:	00 
  801723:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  80172a:	e8 44 ea ff ff       	call   800173 <_panic>
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
  80172f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801736:	00 
  801737:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80173e:	ee 
  80173f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801742:	89 04 24             	mov    %eax,(%esp)
  801745:	e8 69 fa ff ff       	call   8011b3 <sys_page_alloc>
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
  80174a:	83 c3 01             	add    $0x1,%ebx
  80174d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801753:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801759:	0f 85 27 fe ff ff    	jne    801586 <fork+0xa8>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  80175f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  801763:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801766:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  801769:	0f 85 f3 fd ff ff    	jne    801562 <fork+0x84>
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
		}						
	}
	sys_env_set_status( childid , ENV_RUNNABLE ) ;
  80176f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801776:	00 
  801777:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80177a:	89 3c 24             	mov    %edi,(%esp)
  80177d:	e8 2b fb ff ff       	call   8012ad <sys_env_set_status>
	return childid ;
  801782:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801784:	83 c4 3c             	add    $0x3c,%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5f                   	pop    %edi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <sfork>:

// Challenge!
int
sfork(void)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801792:	c7 44 24 08 f3 20 80 	movl   $0x8020f3,0x8(%esp)
  801799:	00 
  80179a:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  8017a1:	00 
  8017a2:	c7 04 24 e8 20 80 00 	movl   $0x8020e8,(%esp)
  8017a9:	e8 c5 e9 ff ff       	call   800173 <_panic>

008017ae <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8017b4:	83 3d 0c 30 80 00 00 	cmpl   $0x0,0x80300c
  8017bb:	75 32                	jne    8017ef <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  8017bd:	e8 b3 f9 ff ff       	call   801175 <sys_getenvid>
  8017c2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017c9:	00 
  8017ca:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017d1:	ee 
  8017d2:	89 04 24             	mov    %eax,(%esp)
  8017d5:	e8 d9 f9 ff ff       	call   8011b3 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  8017da:	e8 96 f9 ff ff       	call   801175 <sys_getenvid>
  8017df:	c7 44 24 04 f9 17 80 	movl   $0x8017f9,0x4(%esp)
  8017e6:	00 
  8017e7:	89 04 24             	mov    %eax,(%esp)
  8017ea:	e8 11 fb ff ff       	call   801300 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8017ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f2:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8017f9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8017fa:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  8017ff:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801801:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  801804:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  801807:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  80180b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  80180f:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  801812:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  801816:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  801818:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  801819:	83 c4 04             	add    $0x4,%esp
	popfl 	
  80181c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80181d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80181e:	c3                   	ret    
  80181f:	90                   	nop

00801820 <__udivdi3>:
  801820:	55                   	push   %ebp
  801821:	57                   	push   %edi
  801822:	56                   	push   %esi
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	8b 44 24 28          	mov    0x28(%esp),%eax
  80182a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80182e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801832:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801836:	85 c0                	test   %eax,%eax
  801838:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80183c:	89 ea                	mov    %ebp,%edx
  80183e:	89 0c 24             	mov    %ecx,(%esp)
  801841:	75 2d                	jne    801870 <__udivdi3+0x50>
  801843:	39 e9                	cmp    %ebp,%ecx
  801845:	77 61                	ja     8018a8 <__udivdi3+0x88>
  801847:	85 c9                	test   %ecx,%ecx
  801849:	89 ce                	mov    %ecx,%esi
  80184b:	75 0b                	jne    801858 <__udivdi3+0x38>
  80184d:	b8 01 00 00 00       	mov    $0x1,%eax
  801852:	31 d2                	xor    %edx,%edx
  801854:	f7 f1                	div    %ecx
  801856:	89 c6                	mov    %eax,%esi
  801858:	31 d2                	xor    %edx,%edx
  80185a:	89 e8                	mov    %ebp,%eax
  80185c:	f7 f6                	div    %esi
  80185e:	89 c5                	mov    %eax,%ebp
  801860:	89 f8                	mov    %edi,%eax
  801862:	f7 f6                	div    %esi
  801864:	89 ea                	mov    %ebp,%edx
  801866:	83 c4 0c             	add    $0xc,%esp
  801869:	5e                   	pop    %esi
  80186a:	5f                   	pop    %edi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    
  80186d:	8d 76 00             	lea    0x0(%esi),%esi
  801870:	39 e8                	cmp    %ebp,%eax
  801872:	77 24                	ja     801898 <__udivdi3+0x78>
  801874:	0f bd e8             	bsr    %eax,%ebp
  801877:	83 f5 1f             	xor    $0x1f,%ebp
  80187a:	75 3c                	jne    8018b8 <__udivdi3+0x98>
  80187c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801880:	39 34 24             	cmp    %esi,(%esp)
  801883:	0f 86 9f 00 00 00    	jbe    801928 <__udivdi3+0x108>
  801889:	39 d0                	cmp    %edx,%eax
  80188b:	0f 82 97 00 00 00    	jb     801928 <__udivdi3+0x108>
  801891:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801898:	31 d2                	xor    %edx,%edx
  80189a:	31 c0                	xor    %eax,%eax
  80189c:	83 c4 0c             	add    $0xc,%esp
  80189f:	5e                   	pop    %esi
  8018a0:	5f                   	pop    %edi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    
  8018a3:	90                   	nop
  8018a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018a8:	89 f8                	mov    %edi,%eax
  8018aa:	f7 f1                	div    %ecx
  8018ac:	31 d2                	xor    %edx,%edx
  8018ae:	83 c4 0c             	add    $0xc,%esp
  8018b1:	5e                   	pop    %esi
  8018b2:	5f                   	pop    %edi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    
  8018b5:	8d 76 00             	lea    0x0(%esi),%esi
  8018b8:	89 e9                	mov    %ebp,%ecx
  8018ba:	8b 3c 24             	mov    (%esp),%edi
  8018bd:	d3 e0                	shl    %cl,%eax
  8018bf:	89 c6                	mov    %eax,%esi
  8018c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8018c6:	29 e8                	sub    %ebp,%eax
  8018c8:	89 c1                	mov    %eax,%ecx
  8018ca:	d3 ef                	shr    %cl,%edi
  8018cc:	89 e9                	mov    %ebp,%ecx
  8018ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8018d2:	8b 3c 24             	mov    (%esp),%edi
  8018d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8018d9:	89 d6                	mov    %edx,%esi
  8018db:	d3 e7                	shl    %cl,%edi
  8018dd:	89 c1                	mov    %eax,%ecx
  8018df:	89 3c 24             	mov    %edi,(%esp)
  8018e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018e6:	d3 ee                	shr    %cl,%esi
  8018e8:	89 e9                	mov    %ebp,%ecx
  8018ea:	d3 e2                	shl    %cl,%edx
  8018ec:	89 c1                	mov    %eax,%ecx
  8018ee:	d3 ef                	shr    %cl,%edi
  8018f0:	09 d7                	or     %edx,%edi
  8018f2:	89 f2                	mov    %esi,%edx
  8018f4:	89 f8                	mov    %edi,%eax
  8018f6:	f7 74 24 08          	divl   0x8(%esp)
  8018fa:	89 d6                	mov    %edx,%esi
  8018fc:	89 c7                	mov    %eax,%edi
  8018fe:	f7 24 24             	mull   (%esp)
  801901:	39 d6                	cmp    %edx,%esi
  801903:	89 14 24             	mov    %edx,(%esp)
  801906:	72 30                	jb     801938 <__udivdi3+0x118>
  801908:	8b 54 24 04          	mov    0x4(%esp),%edx
  80190c:	89 e9                	mov    %ebp,%ecx
  80190e:	d3 e2                	shl    %cl,%edx
  801910:	39 c2                	cmp    %eax,%edx
  801912:	73 05                	jae    801919 <__udivdi3+0xf9>
  801914:	3b 34 24             	cmp    (%esp),%esi
  801917:	74 1f                	je     801938 <__udivdi3+0x118>
  801919:	89 f8                	mov    %edi,%eax
  80191b:	31 d2                	xor    %edx,%edx
  80191d:	e9 7a ff ff ff       	jmp    80189c <__udivdi3+0x7c>
  801922:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801928:	31 d2                	xor    %edx,%edx
  80192a:	b8 01 00 00 00       	mov    $0x1,%eax
  80192f:	e9 68 ff ff ff       	jmp    80189c <__udivdi3+0x7c>
  801934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801938:	8d 47 ff             	lea    -0x1(%edi),%eax
  80193b:	31 d2                	xor    %edx,%edx
  80193d:	83 c4 0c             	add    $0xc,%esp
  801940:	5e                   	pop    %esi
  801941:	5f                   	pop    %edi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    
  801944:	66 90                	xchg   %ax,%ax
  801946:	66 90                	xchg   %ax,%ax
  801948:	66 90                	xchg   %ax,%ax
  80194a:	66 90                	xchg   %ax,%ax
  80194c:	66 90                	xchg   %ax,%ax
  80194e:	66 90                	xchg   %ax,%ax

00801950 <__umoddi3>:
  801950:	55                   	push   %ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	83 ec 14             	sub    $0x14,%esp
  801956:	8b 44 24 28          	mov    0x28(%esp),%eax
  80195a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80195e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801962:	89 c7                	mov    %eax,%edi
  801964:	89 44 24 04          	mov    %eax,0x4(%esp)
  801968:	8b 44 24 30          	mov    0x30(%esp),%eax
  80196c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801970:	89 34 24             	mov    %esi,(%esp)
  801973:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801977:	85 c0                	test   %eax,%eax
  801979:	89 c2                	mov    %eax,%edx
  80197b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80197f:	75 17                	jne    801998 <__umoddi3+0x48>
  801981:	39 fe                	cmp    %edi,%esi
  801983:	76 4b                	jbe    8019d0 <__umoddi3+0x80>
  801985:	89 c8                	mov    %ecx,%eax
  801987:	89 fa                	mov    %edi,%edx
  801989:	f7 f6                	div    %esi
  80198b:	89 d0                	mov    %edx,%eax
  80198d:	31 d2                	xor    %edx,%edx
  80198f:	83 c4 14             	add    $0x14,%esp
  801992:	5e                   	pop    %esi
  801993:	5f                   	pop    %edi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    
  801996:	66 90                	xchg   %ax,%ax
  801998:	39 f8                	cmp    %edi,%eax
  80199a:	77 54                	ja     8019f0 <__umoddi3+0xa0>
  80199c:	0f bd e8             	bsr    %eax,%ebp
  80199f:	83 f5 1f             	xor    $0x1f,%ebp
  8019a2:	75 5c                	jne    801a00 <__umoddi3+0xb0>
  8019a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8019a8:	39 3c 24             	cmp    %edi,(%esp)
  8019ab:	0f 87 e7 00 00 00    	ja     801a98 <__umoddi3+0x148>
  8019b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8019b5:	29 f1                	sub    %esi,%ecx
  8019b7:	19 c7                	sbb    %eax,%edi
  8019b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8019c9:	83 c4 14             	add    $0x14,%esp
  8019cc:	5e                   	pop    %esi
  8019cd:	5f                   	pop    %edi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    
  8019d0:	85 f6                	test   %esi,%esi
  8019d2:	89 f5                	mov    %esi,%ebp
  8019d4:	75 0b                	jne    8019e1 <__umoddi3+0x91>
  8019d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019db:	31 d2                	xor    %edx,%edx
  8019dd:	f7 f6                	div    %esi
  8019df:	89 c5                	mov    %eax,%ebp
  8019e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8019e5:	31 d2                	xor    %edx,%edx
  8019e7:	f7 f5                	div    %ebp
  8019e9:	89 c8                	mov    %ecx,%eax
  8019eb:	f7 f5                	div    %ebp
  8019ed:	eb 9c                	jmp    80198b <__umoddi3+0x3b>
  8019ef:	90                   	nop
  8019f0:	89 c8                	mov    %ecx,%eax
  8019f2:	89 fa                	mov    %edi,%edx
  8019f4:	83 c4 14             	add    $0x14,%esp
  8019f7:	5e                   	pop    %esi
  8019f8:	5f                   	pop    %edi
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    
  8019fb:	90                   	nop
  8019fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a00:	8b 04 24             	mov    (%esp),%eax
  801a03:	be 20 00 00 00       	mov    $0x20,%esi
  801a08:	89 e9                	mov    %ebp,%ecx
  801a0a:	29 ee                	sub    %ebp,%esi
  801a0c:	d3 e2                	shl    %cl,%edx
  801a0e:	89 f1                	mov    %esi,%ecx
  801a10:	d3 e8                	shr    %cl,%eax
  801a12:	89 e9                	mov    %ebp,%ecx
  801a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a18:	8b 04 24             	mov    (%esp),%eax
  801a1b:	09 54 24 04          	or     %edx,0x4(%esp)
  801a1f:	89 fa                	mov    %edi,%edx
  801a21:	d3 e0                	shl    %cl,%eax
  801a23:	89 f1                	mov    %esi,%ecx
  801a25:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a29:	8b 44 24 10          	mov    0x10(%esp),%eax
  801a2d:	d3 ea                	shr    %cl,%edx
  801a2f:	89 e9                	mov    %ebp,%ecx
  801a31:	d3 e7                	shl    %cl,%edi
  801a33:	89 f1                	mov    %esi,%ecx
  801a35:	d3 e8                	shr    %cl,%eax
  801a37:	89 e9                	mov    %ebp,%ecx
  801a39:	09 f8                	or     %edi,%eax
  801a3b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801a3f:	f7 74 24 04          	divl   0x4(%esp)
  801a43:	d3 e7                	shl    %cl,%edi
  801a45:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a49:	89 d7                	mov    %edx,%edi
  801a4b:	f7 64 24 08          	mull   0x8(%esp)
  801a4f:	39 d7                	cmp    %edx,%edi
  801a51:	89 c1                	mov    %eax,%ecx
  801a53:	89 14 24             	mov    %edx,(%esp)
  801a56:	72 2c                	jb     801a84 <__umoddi3+0x134>
  801a58:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801a5c:	72 22                	jb     801a80 <__umoddi3+0x130>
  801a5e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801a62:	29 c8                	sub    %ecx,%eax
  801a64:	19 d7                	sbb    %edx,%edi
  801a66:	89 e9                	mov    %ebp,%ecx
  801a68:	89 fa                	mov    %edi,%edx
  801a6a:	d3 e8                	shr    %cl,%eax
  801a6c:	89 f1                	mov    %esi,%ecx
  801a6e:	d3 e2                	shl    %cl,%edx
  801a70:	89 e9                	mov    %ebp,%ecx
  801a72:	d3 ef                	shr    %cl,%edi
  801a74:	09 d0                	or     %edx,%eax
  801a76:	89 fa                	mov    %edi,%edx
  801a78:	83 c4 14             	add    $0x14,%esp
  801a7b:	5e                   	pop    %esi
  801a7c:	5f                   	pop    %edi
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    
  801a7f:	90                   	nop
  801a80:	39 d7                	cmp    %edx,%edi
  801a82:	75 da                	jne    801a5e <__umoddi3+0x10e>
  801a84:	8b 14 24             	mov    (%esp),%edx
  801a87:	89 c1                	mov    %eax,%ecx
  801a89:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801a8d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801a91:	eb cb                	jmp    801a5e <__umoddi3+0x10e>
  801a93:	90                   	nop
  801a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a98:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801a9c:	0f 82 0f ff ff ff    	jb     8019b1 <__umoddi3+0x61>
  801aa2:	e9 1a ff ff ff       	jmp    8019c1 <__umoddi3+0x71>
