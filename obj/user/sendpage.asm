
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 10 15 00 00       	call   80154e <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 bd 00 00 00    	jne    800106 <umain+0xd3>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800050:	00 
  800051:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800058:	00 
  800059:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005c:	89 04 24             	mov    %eax,(%esp)
  80005f:	e8 bc 17 00 00       	call   801820 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800064:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006b:	00 
  80006c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800073:	c7 04 24 80 1c 80 00 	movl   $0x801c80,(%esp)
  80007a:	e8 60 02 00 00       	call   8002df <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80007f:	a1 04 30 80 00       	mov    0x803004,%eax
  800084:	89 04 24             	mov    %eax,(%esp)
  800087:	e8 44 0d 00 00       	call   800dd0 <strlen>
  80008c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800090:	a1 04 30 80 00       	mov    0x803004,%eax
  800095:	89 44 24 04          	mov    %eax,0x4(%esp)
  800099:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a0:	e8 3d 0e 00 00       	call   800ee2 <strncmp>
  8000a5:	85 c0                	test   %eax,%eax
  8000a7:	75 0c                	jne    8000b5 <umain+0x82>
			cprintf("child received correct message\n");
  8000a9:	c7 04 24 94 1c 80 00 	movl   $0x801c94,(%esp)
  8000b0:	e8 2a 02 00 00       	call   8002df <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b5:	a1 00 30 80 00       	mov    0x803000,%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 0e 0d 00 00       	call   800dd0 <strlen>
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c9:	a1 00 30 80 00       	mov    0x803000,%eax
  8000ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d2:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d9:	e8 2e 0f 00 00       	call   80100c <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000de:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ed:	00 
  8000ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f5:	00 
  8000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f9:	89 04 24             	mov    %eax,(%esp)
  8000fc:	e8 8f 17 00 00       	call   801890 <ipc_send>
		return;
  800101:	e9 d8 00 00 00       	jmp    8001de <umain+0x1ab>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800106:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80010b:	8b 40 48             	mov    0x48(%eax),%eax
  80010e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800115:	00 
  800116:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011d:	00 
  80011e:	89 04 24             	mov    %eax,(%esp)
  800121:	e8 fd 10 00 00       	call   801223 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800126:	a1 04 30 80 00       	mov    0x803004,%eax
  80012b:	89 04 24             	mov    %eax,(%esp)
  80012e:	e8 9d 0c 00 00       	call   800dd0 <strlen>
  800133:	83 c0 01             	add    $0x1,%eax
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	a1 04 30 80 00       	mov    0x803004,%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  80014a:	e8 bd 0e 00 00       	call   80100c <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800156:	00 
  800157:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015e:	00 
  80015f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800166:	00 
  800167:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80016a:	89 04 24             	mov    %eax,(%esp)
  80016d:	e8 1e 17 00 00       	call   801890 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800172:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800179:	00 
  80017a:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800181:	00 
  800182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 93 16 00 00       	call   801820 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018d:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800194:	00 
  800195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 80 1c 80 00 	movl   $0x801c80,(%esp)
  8001a3:	e8 37 01 00 00       	call   8002df <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a8:	a1 00 30 80 00       	mov    0x803000,%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 1b 0c 00 00       	call   800dd0 <strlen>
  8001b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b9:	a1 00 30 80 00       	mov    0x803000,%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c9:	e8 14 0d 00 00       	call   800ee2 <strncmp>
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	75 0c                	jne    8001de <umain+0x1ab>
		cprintf("parent received correct message\n");
  8001d2:	c7 04 24 b4 1c 80 00 	movl   $0x801cb4,(%esp)
  8001d9:	e8 01 01 00 00       	call   8002df <cprintf>
	return;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  8001ee:	e8 f2 0f 00 00       	call   8011e5 <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800200:	a3 0c 30 80 00       	mov    %eax,0x80300c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800205:	85 db                	test   %ebx,%ebx
  800207:	7e 07                	jle    800210 <libmain+0x30>
		binaryname = argv[0];
  800209:	8b 06                	mov    (%esi),%eax
  80020b:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  800210:	89 74 24 04          	mov    %esi,0x4(%esp)
  800214:	89 1c 24             	mov    %ebx,(%esp)
  800217:	e8 17 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021c:	e8 07 00 00 00       	call   800228 <exit>
}
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80022e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800235:	e8 59 0f 00 00       	call   801193 <sys_env_destroy>
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	53                   	push   %ebx
  800240:	83 ec 14             	sub    $0x14,%esp
  800243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800246:	8b 13                	mov    (%ebx),%edx
  800248:	8d 42 01             	lea    0x1(%edx),%eax
  80024b:	89 03                	mov    %eax,(%ebx)
  80024d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800250:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800254:	3d ff 00 00 00       	cmp    $0xff,%eax
  800259:	75 19                	jne    800274 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80025b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800262:	00 
  800263:	8d 43 08             	lea    0x8(%ebx),%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	e8 e8 0e 00 00       	call   801156 <sys_cputs>
		b->idx = 0;
  80026e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800274:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800278:	83 c4 14             	add    $0x14,%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800287:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028e:	00 00 00 
	b.cnt = 0;
  800291:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800298:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b3:	c7 04 24 3c 02 80 00 	movl   $0x80023c,(%esp)
  8002ba:	e8 b0 02 00 00       	call   80056f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002bf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	e8 7f 0e 00 00       	call   801156 <sys_cputs>

	return b.cnt;
}
  8002d7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	e8 87 ff ff ff       	call   80027e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f7:	c9                   	leave  
  8002f8:	c3                   	ret    
  8002f9:	66 90                	xchg   %ax,%ax
  8002fb:	66 90                	xchg   %ax,%ax
  8002fd:	66 90                	xchg   %ax,%ax
  8002ff:	90                   	nop

00800300 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 3c             	sub    $0x3c,%esp
  800309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030c:	89 d7                	mov    %edx,%edi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
  800317:	89 c3                	mov    %eax,%ebx
  800319:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80032d:	39 d9                	cmp    %ebx,%ecx
  80032f:	72 05                	jb     800336 <printnum+0x36>
  800331:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800334:	77 69                	ja     80039f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800336:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800339:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80033d:	83 ee 01             	sub    $0x1,%esi
  800340:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 44 24 08          	mov    0x8(%esp),%eax
  80034c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800350:	89 c3                	mov    %eax,%ebx
  800352:	89 d6                	mov    %edx,%esi
  800354:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800357:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80035a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80035e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036f:	e8 7c 16 00 00       	call   8019f0 <__udivdi3>
  800374:	89 d9                	mov    %ebx,%ecx
  800376:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80037a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80037e:	89 04 24             	mov    %eax,(%esp)
  800381:	89 54 24 04          	mov    %edx,0x4(%esp)
  800385:	89 fa                	mov    %edi,%edx
  800387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038a:	e8 71 ff ff ff       	call   800300 <printnum>
  80038f:	eb 1b                	jmp    8003ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800395:	8b 45 18             	mov    0x18(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff d3                	call   *%ebx
  80039d:	eb 03                	jmp    8003a2 <printnum+0xa2>
  80039f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a2:	83 ee 01             	sub    $0x1,%esi
  8003a5:	85 f6                	test   %esi,%esi
  8003a7:	7f e8                	jg     800391 <printnum+0x91>
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cf:	e8 4c 17 00 00       	call   801b20 <__umoddi3>
  8003d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d8:	0f be 80 2c 1d 80 00 	movsbl 0x801d2c(%eax),%eax
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003e5:	ff d0                	call   *%eax
}
  8003e7:	83 c4 3c             	add    $0x3c,%esp
  8003ea:	5b                   	pop    %ebx
  8003eb:	5e                   	pop    %esi
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	57                   	push   %edi
  8003f3:	56                   	push   %esi
  8003f4:	53                   	push   %ebx
  8003f5:	83 ec 3c             	sub    $0x3c,%esp
  8003f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003fe:	89 cf                	mov    %ecx,%edi
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
  800403:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800406:	8b 45 0c             	mov    0xc(%ebp),%eax
  800409:	89 c3                	mov    %eax,%ebx
  80040b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80040e:	8b 45 10             	mov    0x10(%ebp),%eax
  800411:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800414:	b9 00 00 00 00       	mov    $0x0,%ecx
  800419:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80041c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80041f:	39 d9                	cmp    %ebx,%ecx
  800421:	72 13                	jb     800436 <cprintnum+0x47>
  800423:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800426:	76 0e                	jbe    800436 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800428:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80042b:	0b 45 18             	or     0x18(%ebp),%eax
  80042e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800431:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800434:	eb 6a                	jmp    8004a0 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800436:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800439:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80043d:	83 ee 01             	sub    $0x1,%esi
  800440:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800444:	89 44 24 08          	mov    %eax,0x8(%esp)
  800448:	8b 44 24 08          	mov    0x8(%esp),%eax
  80044c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800450:	89 c3                	mov    %eax,%ebx
  800452:	89 d6                	mov    %edx,%esi
  800454:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800457:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80045a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80045e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800462:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80046b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046f:	e8 7c 15 00 00       	call   8019f0 <__udivdi3>
  800474:	89 d9                	mov    %ebx,%ecx
  800476:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80047a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80047e:	89 04 24             	mov    %eax,(%esp)
  800481:	89 54 24 04          	mov    %edx,0x4(%esp)
  800485:	89 f9                	mov    %edi,%ecx
  800487:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80048a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048d:	e8 5d ff ff ff       	call   8003ef <cprintnum>
  800492:	eb 16                	jmp    8004aa <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800494:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800498:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a0:	83 ee 01             	sub    $0x1,%esi
  8004a3:	85 f6                	test   %esi,%esi
  8004a5:	7f ed                	jg     800494 <cprintnum+0xa5>
  8004a7:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  8004aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ae:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004c3:	89 04 24             	mov    %eax,(%esp)
  8004c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004cd:	e8 4e 16 00 00       	call   801b20 <__umoddi3>
  8004d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d6:	0f be 80 2c 1d 80 00 	movsbl 0x801d2c(%eax),%eax
  8004dd:	0b 45 dc             	or     -0x24(%ebp),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e6:	ff d0                	call   *%eax
}
  8004e8:	83 c4 3c             	add    $0x3c,%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5f                   	pop    %edi
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004f3:	83 fa 01             	cmp    $0x1,%edx
  8004f6:	7e 0e                	jle    800506 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004f8:	8b 10                	mov    (%eax),%edx
  8004fa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004fd:	89 08                	mov    %ecx,(%eax)
  8004ff:	8b 02                	mov    (%edx),%eax
  800501:	8b 52 04             	mov    0x4(%edx),%edx
  800504:	eb 22                	jmp    800528 <getuint+0x38>
	else if (lflag)
  800506:	85 d2                	test   %edx,%edx
  800508:	74 10                	je     80051a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80050a:	8b 10                	mov    (%eax),%edx
  80050c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80050f:	89 08                	mov    %ecx,(%eax)
  800511:	8b 02                	mov    (%edx),%eax
  800513:	ba 00 00 00 00       	mov    $0x0,%edx
  800518:	eb 0e                	jmp    800528 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80051a:	8b 10                	mov    (%eax),%edx
  80051c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80051f:	89 08                	mov    %ecx,(%eax)
  800521:	8b 02                	mov    (%edx),%eax
  800523:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800528:	5d                   	pop    %ebp
  800529:	c3                   	ret    

0080052a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800530:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800534:	8b 10                	mov    (%eax),%edx
  800536:	3b 50 04             	cmp    0x4(%eax),%edx
  800539:	73 0a                	jae    800545 <sprintputch+0x1b>
		*b->buf++ = ch;
  80053b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80053e:	89 08                	mov    %ecx,(%eax)
  800540:	8b 45 08             	mov    0x8(%ebp),%eax
  800543:	88 02                	mov    %al,(%edx)
}
  800545:	5d                   	pop    %ebp
  800546:	c3                   	ret    

00800547 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80054d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800550:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800554:	8b 45 10             	mov    0x10(%ebp),%eax
  800557:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800562:	8b 45 08             	mov    0x8(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	e8 02 00 00 00       	call   80056f <vprintfmt>
	va_end(ap);
}
  80056d:	c9                   	leave  
  80056e:	c3                   	ret    

0080056f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	57                   	push   %edi
  800573:	56                   	push   %esi
  800574:	53                   	push   %ebx
  800575:	83 ec 3c             	sub    $0x3c,%esp
  800578:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80057b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80057e:	eb 14                	jmp    800594 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800580:	85 c0                	test   %eax,%eax
  800582:	0f 84 b3 03 00 00    	je     80093b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800588:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058c:	89 04 24             	mov    %eax,(%esp)
  80058f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800592:	89 f3                	mov    %esi,%ebx
  800594:	8d 73 01             	lea    0x1(%ebx),%esi
  800597:	0f b6 03             	movzbl (%ebx),%eax
  80059a:	83 f8 25             	cmp    $0x25,%eax
  80059d:	75 e1                	jne    800580 <vprintfmt+0x11>
  80059f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005a3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005aa:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8005b1:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bd:	eb 1d                	jmp    8005dc <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005c1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005c5:	eb 15                	jmp    8005dc <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c9:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005cd:	eb 0d                	jmp    8005dc <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005d5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005df:	0f b6 0e             	movzbl (%esi),%ecx
  8005e2:	0f b6 c1             	movzbl %cl,%eax
  8005e5:	83 e9 23             	sub    $0x23,%ecx
  8005e8:	80 f9 55             	cmp    $0x55,%cl
  8005eb:	0f 87 2a 03 00 00    	ja     80091b <vprintfmt+0x3ac>
  8005f1:	0f b6 c9             	movzbl %cl,%ecx
  8005f4:	ff 24 8d 00 1e 80 00 	jmp    *0x801e00(,%ecx,4)
  8005fb:	89 de                	mov    %ebx,%esi
  8005fd:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800602:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800605:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800609:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80060c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80060f:	83 fb 09             	cmp    $0x9,%ebx
  800612:	77 36                	ja     80064a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800614:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800617:	eb e9                	jmp    800602 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 48 04             	lea    0x4(%eax),%ecx
  80061f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800629:	eb 22                	jmp    80064d <vprintfmt+0xde>
  80062b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	b8 00 00 00 00       	mov    $0x0,%eax
  800635:	0f 49 c1             	cmovns %ecx,%eax
  800638:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	89 de                	mov    %ebx,%esi
  80063d:	eb 9d                	jmp    8005dc <vprintfmt+0x6d>
  80063f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800641:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800648:	eb 92                	jmp    8005dc <vprintfmt+0x6d>
  80064a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80064d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800651:	79 89                	jns    8005dc <vprintfmt+0x6d>
  800653:	e9 77 ff ff ff       	jmp    8005cf <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800658:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80065d:	e9 7a ff ff ff       	jmp    8005dc <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 04             	lea    0x4(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)
  80066b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 04 24             	mov    %eax,(%esp)
  800674:	ff 55 08             	call   *0x8(%ebp)
			break;
  800677:	e9 18 ff ff ff       	jmp    800594 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	8b 00                	mov    (%eax),%eax
  800687:	99                   	cltd   
  800688:	31 d0                	xor    %edx,%eax
  80068a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068c:	83 f8 09             	cmp    $0x9,%eax
  80068f:	7f 0b                	jg     80069c <vprintfmt+0x12d>
  800691:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  800698:	85 d2                	test   %edx,%edx
  80069a:	75 20                	jne    8006bc <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80069c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a0:	c7 44 24 08 44 1d 80 	movl   $0x801d44,0x8(%esp)
  8006a7:	00 
  8006a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	89 04 24             	mov    %eax,(%esp)
  8006b2:	e8 90 fe ff ff       	call   800547 <printfmt>
  8006b7:	e9 d8 fe ff ff       	jmp    800594 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8006bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c0:	c7 44 24 08 4d 1d 80 	movl   $0x801d4d,0x8(%esp)
  8006c7:	00 
  8006c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	89 04 24             	mov    %eax,(%esp)
  8006d2:	e8 70 fe ff ff       	call   800547 <printfmt>
  8006d7:	e9 b8 fe ff ff       	jmp    800594 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8d 50 04             	lea    0x4(%eax),%edx
  8006eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ee:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006f0:	85 f6                	test   %esi,%esi
  8006f2:	b8 3d 1d 80 00       	mov    $0x801d3d,%eax
  8006f7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006fa:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006fe:	0f 84 97 00 00 00    	je     80079b <vprintfmt+0x22c>
  800704:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800708:	0f 8e 9b 00 00 00    	jle    8007a9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80070e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800712:	89 34 24             	mov    %esi,(%esp)
  800715:	e8 ce 06 00 00       	call   800de8 <strnlen>
  80071a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80071d:	29 c2                	sub    %eax,%edx
  80071f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800722:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800726:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800729:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80072c:	8b 75 08             	mov    0x8(%ebp),%esi
  80072f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800732:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800734:	eb 0f                	jmp    800745 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800736:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80073d:	89 04 24             	mov    %eax,(%esp)
  800740:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800742:	83 eb 01             	sub    $0x1,%ebx
  800745:	85 db                	test   %ebx,%ebx
  800747:	7f ed                	jg     800736 <vprintfmt+0x1c7>
  800749:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80074c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80074f:	85 d2                	test   %edx,%edx
  800751:	b8 00 00 00 00       	mov    $0x0,%eax
  800756:	0f 49 c2             	cmovns %edx,%eax
  800759:	29 c2                	sub    %eax,%edx
  80075b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80075e:	89 d7                	mov    %edx,%edi
  800760:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800763:	eb 50                	jmp    8007b5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800765:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800769:	74 1e                	je     800789 <vprintfmt+0x21a>
  80076b:	0f be d2             	movsbl %dl,%edx
  80076e:	83 ea 20             	sub    $0x20,%edx
  800771:	83 fa 5e             	cmp    $0x5e,%edx
  800774:	76 13                	jbe    800789 <vprintfmt+0x21a>
					putch('?', putdat);
  800776:	8b 45 0c             	mov    0xc(%ebp),%eax
  800779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800784:	ff 55 08             	call   *0x8(%ebp)
  800787:	eb 0d                	jmp    800796 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800789:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800796:	83 ef 01             	sub    $0x1,%edi
  800799:	eb 1a                	jmp    8007b5 <vprintfmt+0x246>
  80079b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80079e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8007a1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007a7:	eb 0c                	jmp    8007b5 <vprintfmt+0x246>
  8007a9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007ac:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8007af:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007b2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007b5:	83 c6 01             	add    $0x1,%esi
  8007b8:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8007bc:	0f be c2             	movsbl %dl,%eax
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	74 27                	je     8007ea <vprintfmt+0x27b>
  8007c3:	85 db                	test   %ebx,%ebx
  8007c5:	78 9e                	js     800765 <vprintfmt+0x1f6>
  8007c7:	83 eb 01             	sub    $0x1,%ebx
  8007ca:	79 99                	jns    800765 <vprintfmt+0x1f6>
  8007cc:	89 f8                	mov    %edi,%eax
  8007ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	89 c3                	mov    %eax,%ebx
  8007d6:	eb 1a                	jmp    8007f2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007dc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007e3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007e5:	83 eb 01             	sub    $0x1,%ebx
  8007e8:	eb 08                	jmp    8007f2 <vprintfmt+0x283>
  8007ea:	89 fb                	mov    %edi,%ebx
  8007ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ef:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007f2:	85 db                	test   %ebx,%ebx
  8007f4:	7f e2                	jg     8007d8 <vprintfmt+0x269>
  8007f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8007f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007fc:	e9 93 fd ff ff       	jmp    800594 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800801:	83 fa 01             	cmp    $0x1,%edx
  800804:	7e 16                	jle    80081c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 08             	lea    0x8(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 50 04             	mov    0x4(%eax),%edx
  800812:	8b 00                	mov    (%eax),%eax
  800814:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800817:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80081a:	eb 32                	jmp    80084e <vprintfmt+0x2df>
	else if (lflag)
  80081c:	85 d2                	test   %edx,%edx
  80081e:	74 18                	je     800838 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8d 50 04             	lea    0x4(%eax),%edx
  800826:	89 55 14             	mov    %edx,0x14(%ebp)
  800829:	8b 30                	mov    (%eax),%esi
  80082b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80082e:	89 f0                	mov    %esi,%eax
  800830:	c1 f8 1f             	sar    $0x1f,%eax
  800833:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800836:	eb 16                	jmp    80084e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8d 50 04             	lea    0x4(%eax),%edx
  80083e:	89 55 14             	mov    %edx,0x14(%ebp)
  800841:	8b 30                	mov    (%eax),%esi
  800843:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800846:	89 f0                	mov    %esi,%eax
  800848:	c1 f8 1f             	sar    $0x1f,%eax
  80084b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80084e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800851:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800854:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800859:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80085d:	0f 89 80 00 00 00    	jns    8008e3 <vprintfmt+0x374>
				putch('-', putdat);
  800863:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800867:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80086e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800871:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800874:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800877:	f7 d8                	neg    %eax
  800879:	83 d2 00             	adc    $0x0,%edx
  80087c:	f7 da                	neg    %edx
			}
			base = 10;
  80087e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800883:	eb 5e                	jmp    8008e3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800885:	8d 45 14             	lea    0x14(%ebp),%eax
  800888:	e8 63 fc ff ff       	call   8004f0 <getuint>
			base = 10;
  80088d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800892:	eb 4f                	jmp    8008e3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800894:	8d 45 14             	lea    0x14(%ebp),%eax
  800897:	e8 54 fc ff ff       	call   8004f0 <getuint>
			base = 8 ;
  80089c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  8008a1:	eb 40                	jmp    8008e3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8008a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008ae:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008bc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c2:	8d 50 04             	lea    0x4(%eax),%edx
  8008c5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008c8:	8b 00                	mov    (%eax),%eax
  8008ca:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008cf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008d4:	eb 0d                	jmp    8008e3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d9:	e8 12 fc ff ff       	call   8004f0 <getuint>
			base = 16;
  8008de:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8008e7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8008eb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8008ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008fd:	89 fa                	mov    %edi,%edx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	e8 f9 f9 ff ff       	call   800300 <printnum>
			break;
  800907:	e9 88 fc ff ff       	jmp    800594 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80090c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800910:	89 04 24             	mov    %eax,(%esp)
  800913:	ff 55 08             	call   *0x8(%ebp)
			break;
  800916:	e9 79 fc ff ff       	jmp    800594 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80091b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800926:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800929:	89 f3                	mov    %esi,%ebx
  80092b:	eb 03                	jmp    800930 <vprintfmt+0x3c1>
  80092d:	83 eb 01             	sub    $0x1,%ebx
  800930:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800934:	75 f7                	jne    80092d <vprintfmt+0x3be>
  800936:	e9 59 fc ff ff       	jmp    800594 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80093b:	83 c4 3c             	add    $0x3c,%esp
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5f                   	pop    %edi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	83 ec 3c             	sub    $0x3c,%esp
  80094c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
  800952:	8d 50 04             	lea    0x4(%eax),%edx
  800955:	89 55 14             	mov    %edx,0x14(%ebp)
  800958:	8b 00                	mov    (%eax),%eax
  80095a:	c1 e0 08             	shl    $0x8,%eax
  80095d:	0f b7 c0             	movzwl %ax,%eax
  800960:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800963:	83 c8 25             	or     $0x25,%eax
  800966:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800969:	eb 1a                	jmp    800985 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80096b:	85 c0                	test   %eax,%eax
  80096d:	0f 84 a9 03 00 00    	je     800d1c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800973:	8b 75 0c             	mov    0xc(%ebp),%esi
  800976:	89 74 24 04          	mov    %esi,0x4(%esp)
  80097a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80097d:	89 04 24             	mov    %eax,(%esp)
  800980:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800983:	89 fb                	mov    %edi,%ebx
  800985:	8d 7b 01             	lea    0x1(%ebx),%edi
  800988:	0f b6 03             	movzbl (%ebx),%eax
  80098b:	83 f8 25             	cmp    $0x25,%eax
  80098e:	75 db                	jne    80096b <cvprintfmt+0x28>
  800990:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800994:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80099b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  8009a0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	eb 18                	jmp    8009c6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ae:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009b0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8009b4:	eb 10                	jmp    8009c6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b6:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8009b8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8009bc:	eb 08                	jmp    8009c6 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8009be:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8009c1:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c6:	8d 5f 01             	lea    0x1(%edi),%ebx
  8009c9:	0f b6 0f             	movzbl (%edi),%ecx
  8009cc:	0f b6 c1             	movzbl %cl,%eax
  8009cf:	83 e9 23             	sub    $0x23,%ecx
  8009d2:	80 f9 55             	cmp    $0x55,%cl
  8009d5:	0f 87 1f 03 00 00    	ja     800cfa <cvprintfmt+0x3b7>
  8009db:	0f b6 c9             	movzbl %cl,%ecx
  8009de:	ff 24 8d 58 1f 80 00 	jmp    *0x801f58(,%ecx,4)
  8009e5:	89 df                	mov    %ebx,%edi
  8009e7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8009ec:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  8009ef:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  8009f3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8009f6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8009f9:	83 f9 09             	cmp    $0x9,%ecx
  8009fc:	77 33                	ja     800a31 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8009fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a01:	eb e9                	jmp    8009ec <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a03:	8b 45 14             	mov    0x14(%ebp),%eax
  800a06:	8d 48 04             	lea    0x4(%eax),%ecx
  800a09:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a0c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a10:	eb 1f                	jmp    800a31 <cvprintfmt+0xee>
  800a12:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a15:	85 ff                	test   %edi,%edi
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	0f 49 c7             	cmovns %edi,%eax
  800a1f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a22:	89 df                	mov    %ebx,%edi
  800a24:	eb a0                	jmp    8009c6 <cvprintfmt+0x83>
  800a26:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a28:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800a2f:	eb 95                	jmp    8009c6 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800a31:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a35:	79 8f                	jns    8009c6 <cvprintfmt+0x83>
  800a37:	eb 85                	jmp    8009be <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a39:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a3c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a3e:	66 90                	xchg   %ax,%ax
  800a40:	eb 84                	jmp    8009c6 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800a42:	8b 45 14             	mov    0x14(%ebp),%eax
  800a45:	8d 50 04             	lea    0x4(%eax),%edx
  800a48:	89 55 14             	mov    %edx,0x14(%ebp)
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a52:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a55:	0b 10                	or     (%eax),%edx
  800a57:	89 14 24             	mov    %edx,(%esp)
  800a5a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a5d:	e9 23 ff ff ff       	jmp    800985 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a62:	8b 45 14             	mov    0x14(%ebp),%eax
  800a65:	8d 50 04             	lea    0x4(%eax),%edx
  800a68:	89 55 14             	mov    %edx,0x14(%ebp)
  800a6b:	8b 00                	mov    (%eax),%eax
  800a6d:	99                   	cltd   
  800a6e:	31 d0                	xor    %edx,%eax
  800a70:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a72:	83 f8 09             	cmp    $0x9,%eax
  800a75:	7f 0b                	jg     800a82 <cvprintfmt+0x13f>
  800a77:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  800a7e:	85 d2                	test   %edx,%edx
  800a80:	75 23                	jne    800aa5 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800a82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a86:	c7 44 24 08 44 1d 80 	movl   $0x801d44,0x8(%esp)
  800a8d:	00 
  800a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	89 04 24             	mov    %eax,(%esp)
  800a9b:	e8 a7 fa ff ff       	call   800547 <printfmt>
  800aa0:	e9 e0 fe ff ff       	jmp    800985 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800aa5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aa9:	c7 44 24 08 4d 1d 80 	movl   $0x801d4d,0x8(%esp)
  800ab0:	00 
  800ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 84 fa ff ff       	call   800547 <printfmt>
  800ac3:	e9 bd fe ff ff       	jmp    800985 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800acb:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800ace:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad1:	8d 48 04             	lea    0x4(%eax),%ecx
  800ad4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800ad7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800ad9:	85 ff                	test   %edi,%edi
  800adb:	b8 3d 1d 80 00       	mov    $0x801d3d,%eax
  800ae0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800ae3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800ae7:	74 61                	je     800b4a <cvprintfmt+0x207>
  800ae9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800aed:	7e 5b                	jle    800b4a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800aef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800af3:	89 3c 24             	mov    %edi,(%esp)
  800af6:	e8 ed 02 00 00       	call   800de8 <strnlen>
  800afb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800afe:	29 c2                	sub    %eax,%edx
  800b00:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800b03:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800b07:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b0a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800b0d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800b10:	8b 75 08             	mov    0x8(%ebp),%esi
  800b13:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b1a:	eb 0f                	jmp    800b2b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b23:	89 3c 24             	mov    %edi,(%esp)
  800b26:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b28:	83 eb 01             	sub    $0x1,%ebx
  800b2b:	85 db                	test   %ebx,%ebx
  800b2d:	7f ed                	jg     800b1c <cvprintfmt+0x1d9>
  800b2f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800b32:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b38:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b3b:	85 d2                	test   %edx,%edx
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b42:	0f 49 c2             	cmovns %edx,%eax
  800b45:	29 c2                	sub    %eax,%edx
  800b47:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800b4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b4d:	83 c8 3f             	or     $0x3f,%eax
  800b50:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b53:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b56:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800b59:	eb 36                	jmp    800b91 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b5b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b5f:	74 1d                	je     800b7e <cvprintfmt+0x23b>
  800b61:	0f be d2             	movsbl %dl,%edx
  800b64:	83 ea 20             	sub    $0x20,%edx
  800b67:	83 fa 5e             	cmp    $0x5e,%edx
  800b6a:	76 12                	jbe    800b7e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b73:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b76:	89 04 24             	mov    %eax,(%esp)
  800b79:	ff 55 08             	call   *0x8(%ebp)
  800b7c:	eb 10                	jmp    800b8e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800b7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b81:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b85:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b88:	89 04 24             	mov    %eax,(%esp)
  800b8b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b8e:	83 eb 01             	sub    $0x1,%ebx
  800b91:	83 c7 01             	add    $0x1,%edi
  800b94:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800b98:	0f be c2             	movsbl %dl,%eax
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	74 27                	je     800bc6 <cvprintfmt+0x283>
  800b9f:	85 f6                	test   %esi,%esi
  800ba1:	78 b8                	js     800b5b <cvprintfmt+0x218>
  800ba3:	83 ee 01             	sub    $0x1,%esi
  800ba6:	79 b3                	jns    800b5b <cvprintfmt+0x218>
  800ba8:	89 d8                	mov    %ebx,%eax
  800baa:	8b 75 08             	mov    0x8(%ebp),%esi
  800bad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bb0:	89 c3                	mov    %eax,%ebx
  800bb2:	eb 18                	jmp    800bcc <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800bb4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bb8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800bbf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800bc1:	83 eb 01             	sub    $0x1,%ebx
  800bc4:	eb 06                	jmp    800bcc <cvprintfmt+0x289>
  800bc6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bc9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bcc:	85 db                	test   %ebx,%ebx
  800bce:	7f e4                	jg     800bb4 <cvprintfmt+0x271>
  800bd0:	89 75 08             	mov    %esi,0x8(%ebp)
  800bd3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd9:	e9 a7 fd ff ff       	jmp    800985 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bde:	83 fa 01             	cmp    $0x1,%edx
  800be1:	7e 10                	jle    800bf3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800be3:	8b 45 14             	mov    0x14(%ebp),%eax
  800be6:	8d 50 08             	lea    0x8(%eax),%edx
  800be9:	89 55 14             	mov    %edx,0x14(%ebp)
  800bec:	8b 30                	mov    (%eax),%esi
  800bee:	8b 78 04             	mov    0x4(%eax),%edi
  800bf1:	eb 26                	jmp    800c19 <cvprintfmt+0x2d6>
	else if (lflag)
  800bf3:	85 d2                	test   %edx,%edx
  800bf5:	74 12                	je     800c09 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800bf7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bfa:	8d 50 04             	lea    0x4(%eax),%edx
  800bfd:	89 55 14             	mov    %edx,0x14(%ebp)
  800c00:	8b 30                	mov    (%eax),%esi
  800c02:	89 f7                	mov    %esi,%edi
  800c04:	c1 ff 1f             	sar    $0x1f,%edi
  800c07:	eb 10                	jmp    800c19 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800c09:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0c:	8d 50 04             	lea    0x4(%eax),%edx
  800c0f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c12:	8b 30                	mov    (%eax),%esi
  800c14:	89 f7                	mov    %esi,%edi
  800c16:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c19:	89 f0                	mov    %esi,%eax
  800c1b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c1d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c22:	85 ff                	test   %edi,%edi
  800c24:	0f 89 8e 00 00 00    	jns    800cb8 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c34:	83 c8 2d             	or     $0x2d,%eax
  800c37:	89 04 24             	mov    %eax,(%esp)
  800c3a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c3d:	89 f0                	mov    %esi,%eax
  800c3f:	89 fa                	mov    %edi,%edx
  800c41:	f7 d8                	neg    %eax
  800c43:	83 d2 00             	adc    $0x0,%edx
  800c46:	f7 da                	neg    %edx
			}
			base = 10;
  800c48:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c4d:	eb 69                	jmp    800cb8 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c4f:	8d 45 14             	lea    0x14(%ebp),%eax
  800c52:	e8 99 f8 ff ff       	call   8004f0 <getuint>
			base = 10;
  800c57:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800c5c:	eb 5a                	jmp    800cb8 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800c5e:	8d 45 14             	lea    0x14(%ebp),%eax
  800c61:	e8 8a f8 ff ff       	call   8004f0 <getuint>
			base = 8 ;
  800c66:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800c6b:	eb 4b                	jmp    800cb8 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c74:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800c77:	89 f0                	mov    %esi,%eax
  800c79:	83 c8 30             	or     $0x30,%eax
  800c7c:	89 04 24             	mov    %eax,(%esp)
  800c7f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c89:	89 f0                	mov    %esi,%eax
  800c8b:	83 c8 78             	or     $0x78,%eax
  800c8e:	89 04 24             	mov    %eax,(%esp)
  800c91:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c94:	8b 45 14             	mov    0x14(%ebp),%eax
  800c97:	8d 50 04             	lea    0x4(%eax),%edx
  800c9a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800c9d:	8b 00                	mov    (%eax),%eax
  800c9f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ca4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ca9:	eb 0d                	jmp    800cb8 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800cab:	8d 45 14             	lea    0x14(%ebp),%eax
  800cae:	e8 3d f8 ff ff       	call   8004f0 <getuint>
			base = 16;
  800cb3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800cb8:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800cbc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800cc0:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800cc3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800cc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ccb:	89 04 24             	mov    %eax,(%esp)
  800cce:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cdb:	e8 0f f7 ff ff       	call   8003ef <cprintnum>
			break;
  800ce0:	e9 a0 fc ff ff       	jmp    800985 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800ce5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cec:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800cef:	89 04 24             	mov    %eax,(%esp)
  800cf2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800cf5:	e9 8b fc ff ff       	jmp    800985 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d01:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d04:	89 04 24             	mov    %eax,(%esp)
  800d07:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d0a:	89 fb                	mov    %edi,%ebx
  800d0c:	eb 03                	jmp    800d11 <cvprintfmt+0x3ce>
  800d0e:	83 eb 01             	sub    $0x1,%ebx
  800d11:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d15:	75 f7                	jne    800d0e <cvprintfmt+0x3cb>
  800d17:	e9 69 fc ff ff       	jmp    800985 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800d1c:	83 c4 3c             	add    $0x3c,%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800d2a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800d2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d31:	8b 45 10             	mov    0x10(%ebp),%eax
  800d34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	89 04 24             	mov    %eax,(%esp)
  800d45:	e8 f9 fb ff ff       	call   800943 <cvprintfmt>
	va_end(ap);
}
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    

00800d4c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 28             	sub    $0x28,%esp
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d58:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d5b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d5f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	74 30                	je     800d9d <vsnprintf+0x51>
  800d6d:	85 d2                	test   %edx,%edx
  800d6f:	7e 2c                	jle    800d9d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d71:	8b 45 14             	mov    0x14(%ebp),%eax
  800d74:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d78:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d86:	c7 04 24 2a 05 80 00 	movl   $0x80052a,(%esp)
  800d8d:	e8 dd f7 ff ff       	call   80056f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d92:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d95:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d9b:	eb 05                	jmp    800da2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800da2:	c9                   	leave  
  800da3:	c3                   	ret    

00800da4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800daa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800dad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800db1:	8b 45 10             	mov    0x10(%ebp),%eax
  800db4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	89 04 24             	mov    %eax,(%esp)
  800dc5:	e8 82 ff ff ff       	call   800d4c <vsnprintf>
	va_end(ap);

	return rc;
}
  800dca:	c9                   	leave  
  800dcb:	c3                   	ret    
  800dcc:	66 90                	xchg   %ax,%ax
  800dce:	66 90                	xchg   %ax,%ax

00800dd0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddb:	eb 03                	jmp    800de0 <strlen+0x10>
		n++;
  800ddd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800de0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800de4:	75 f7                	jne    800ddd <strlen+0xd>
		n++;
	return n;
}
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
  800df6:	eb 03                	jmp    800dfb <strnlen+0x13>
		n++;
  800df8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dfb:	39 d0                	cmp    %edx,%eax
  800dfd:	74 06                	je     800e05 <strnlen+0x1d>
  800dff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800e03:	75 f3                	jne    800df8 <strnlen+0x10>
		n++;
	return n;
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	53                   	push   %ebx
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	83 c2 01             	add    $0x1,%edx
  800e16:	83 c1 01             	add    $0x1,%ecx
  800e19:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800e1d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800e20:	84 db                	test   %bl,%bl
  800e22:	75 ef                	jne    800e13 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800e24:	5b                   	pop    %ebx
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 08             	sub    $0x8,%esp
  800e2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e31:	89 1c 24             	mov    %ebx,(%esp)
  800e34:	e8 97 ff ff ff       	call   800dd0 <strlen>
	strcpy(dst + len, src);
  800e39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e40:	01 d8                	add    %ebx,%eax
  800e42:	89 04 24             	mov    %eax,(%esp)
  800e45:	e8 bd ff ff ff       	call   800e07 <strcpy>
	return dst;
}
  800e4a:	89 d8                	mov    %ebx,%eax
  800e4c:	83 c4 08             	add    $0x8,%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	8b 75 08             	mov    0x8(%ebp),%esi
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	89 f3                	mov    %esi,%ebx
  800e5f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e62:	89 f2                	mov    %esi,%edx
  800e64:	eb 0f                	jmp    800e75 <strncpy+0x23>
		*dst++ = *src;
  800e66:	83 c2 01             	add    $0x1,%edx
  800e69:	0f b6 01             	movzbl (%ecx),%eax
  800e6c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e6f:	80 39 01             	cmpb   $0x1,(%ecx)
  800e72:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e75:	39 da                	cmp    %ebx,%edx
  800e77:	75 ed                	jne    800e66 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	8b 75 08             	mov    0x8(%ebp),%esi
  800e87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e8d:	89 f0                	mov    %esi,%eax
  800e8f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e93:	85 c9                	test   %ecx,%ecx
  800e95:	75 0b                	jne    800ea2 <strlcpy+0x23>
  800e97:	eb 1d                	jmp    800eb6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e99:	83 c0 01             	add    $0x1,%eax
  800e9c:	83 c2 01             	add    $0x1,%edx
  800e9f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ea2:	39 d8                	cmp    %ebx,%eax
  800ea4:	74 0b                	je     800eb1 <strlcpy+0x32>
  800ea6:	0f b6 0a             	movzbl (%edx),%ecx
  800ea9:	84 c9                	test   %cl,%cl
  800eab:	75 ec                	jne    800e99 <strlcpy+0x1a>
  800ead:	89 c2                	mov    %eax,%edx
  800eaf:	eb 02                	jmp    800eb3 <strlcpy+0x34>
  800eb1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800eb3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800eb6:	29 f0                	sub    %esi,%eax
}
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ec5:	eb 06                	jmp    800ecd <strcmp+0x11>
		p++, q++;
  800ec7:	83 c1 01             	add    $0x1,%ecx
  800eca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ecd:	0f b6 01             	movzbl (%ecx),%eax
  800ed0:	84 c0                	test   %al,%al
  800ed2:	74 04                	je     800ed8 <strcmp+0x1c>
  800ed4:	3a 02                	cmp    (%edx),%al
  800ed6:	74 ef                	je     800ec7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ed8:	0f b6 c0             	movzbl %al,%eax
  800edb:	0f b6 12             	movzbl (%edx),%edx
  800ede:	29 d0                	sub    %edx,%eax
}
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	53                   	push   %ebx
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eec:	89 c3                	mov    %eax,%ebx
  800eee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ef1:	eb 06                	jmp    800ef9 <strncmp+0x17>
		n--, p++, q++;
  800ef3:	83 c0 01             	add    $0x1,%eax
  800ef6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ef9:	39 d8                	cmp    %ebx,%eax
  800efb:	74 15                	je     800f12 <strncmp+0x30>
  800efd:	0f b6 08             	movzbl (%eax),%ecx
  800f00:	84 c9                	test   %cl,%cl
  800f02:	74 04                	je     800f08 <strncmp+0x26>
  800f04:	3a 0a                	cmp    (%edx),%cl
  800f06:	74 eb                	je     800ef3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f08:	0f b6 00             	movzbl (%eax),%eax
  800f0b:	0f b6 12             	movzbl (%edx),%edx
  800f0e:	29 d0                	sub    %edx,%eax
  800f10:	eb 05                	jmp    800f17 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f17:	5b                   	pop    %ebx
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f24:	eb 07                	jmp    800f2d <strchr+0x13>
		if (*s == c)
  800f26:	38 ca                	cmp    %cl,%dl
  800f28:	74 0f                	je     800f39 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f2a:	83 c0 01             	add    $0x1,%eax
  800f2d:	0f b6 10             	movzbl (%eax),%edx
  800f30:	84 d2                	test   %dl,%dl
  800f32:	75 f2                	jne    800f26 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f45:	eb 07                	jmp    800f4e <strfind+0x13>
		if (*s == c)
  800f47:	38 ca                	cmp    %cl,%dl
  800f49:	74 0a                	je     800f55 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f4b:	83 c0 01             	add    $0x1,%eax
  800f4e:	0f b6 10             	movzbl (%eax),%edx
  800f51:	84 d2                	test   %dl,%dl
  800f53:	75 f2                	jne    800f47 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	57                   	push   %edi
  800f5b:	56                   	push   %esi
  800f5c:	53                   	push   %ebx
  800f5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f63:	85 c9                	test   %ecx,%ecx
  800f65:	74 36                	je     800f9d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f67:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f6d:	75 28                	jne    800f97 <memset+0x40>
  800f6f:	f6 c1 03             	test   $0x3,%cl
  800f72:	75 23                	jne    800f97 <memset+0x40>
		c &= 0xFF;
  800f74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f78:	89 d3                	mov    %edx,%ebx
  800f7a:	c1 e3 08             	shl    $0x8,%ebx
  800f7d:	89 d6                	mov    %edx,%esi
  800f7f:	c1 e6 18             	shl    $0x18,%esi
  800f82:	89 d0                	mov    %edx,%eax
  800f84:	c1 e0 10             	shl    $0x10,%eax
  800f87:	09 f0                	or     %esi,%eax
  800f89:	09 c2                	or     %eax,%edx
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f8f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f92:	fc                   	cld    
  800f93:	f3 ab                	rep stos %eax,%es:(%edi)
  800f95:	eb 06                	jmp    800f9d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9a:	fc                   	cld    
  800f9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f9d:	89 f8                	mov    %edi,%eax
  800f9f:	5b                   	pop    %ebx
  800fa0:	5e                   	pop    %esi
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800faf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800fb2:	39 c6                	cmp    %eax,%esi
  800fb4:	73 35                	jae    800feb <memmove+0x47>
  800fb6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800fb9:	39 d0                	cmp    %edx,%eax
  800fbb:	73 2e                	jae    800feb <memmove+0x47>
		s += n;
		d += n;
  800fbd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800fc0:	89 d6                	mov    %edx,%esi
  800fc2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fc4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fca:	75 13                	jne    800fdf <memmove+0x3b>
  800fcc:	f6 c1 03             	test   $0x3,%cl
  800fcf:	75 0e                	jne    800fdf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800fd1:	83 ef 04             	sub    $0x4,%edi
  800fd4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fd7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800fda:	fd                   	std    
  800fdb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fdd:	eb 09                	jmp    800fe8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800fdf:	83 ef 01             	sub    $0x1,%edi
  800fe2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fe5:	fd                   	std    
  800fe6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fe8:	fc                   	cld    
  800fe9:	eb 1d                	jmp    801008 <memmove+0x64>
  800feb:	89 f2                	mov    %esi,%edx
  800fed:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fef:	f6 c2 03             	test   $0x3,%dl
  800ff2:	75 0f                	jne    801003 <memmove+0x5f>
  800ff4:	f6 c1 03             	test   $0x3,%cl
  800ff7:	75 0a                	jne    801003 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ff9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ffc:	89 c7                	mov    %eax,%edi
  800ffe:	fc                   	cld    
  800fff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801001:	eb 05                	jmp    801008 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801003:	89 c7                	mov    %eax,%edi
  801005:	fc                   	cld    
  801006:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801012:	8b 45 10             	mov    0x10(%ebp),%eax
  801015:	89 44 24 08          	mov    %eax,0x8(%esp)
  801019:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801020:	8b 45 08             	mov    0x8(%ebp),%eax
  801023:	89 04 24             	mov    %eax,(%esp)
  801026:	e8 79 ff ff ff       	call   800fa4 <memmove>
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
  801032:	8b 55 08             	mov    0x8(%ebp),%edx
  801035:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801038:	89 d6                	mov    %edx,%esi
  80103a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80103d:	eb 1a                	jmp    801059 <memcmp+0x2c>
		if (*s1 != *s2)
  80103f:	0f b6 02             	movzbl (%edx),%eax
  801042:	0f b6 19             	movzbl (%ecx),%ebx
  801045:	38 d8                	cmp    %bl,%al
  801047:	74 0a                	je     801053 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801049:	0f b6 c0             	movzbl %al,%eax
  80104c:	0f b6 db             	movzbl %bl,%ebx
  80104f:	29 d8                	sub    %ebx,%eax
  801051:	eb 0f                	jmp    801062 <memcmp+0x35>
		s1++, s2++;
  801053:	83 c2 01             	add    $0x1,%edx
  801056:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801059:	39 f2                	cmp    %esi,%edx
  80105b:	75 e2                	jne    80103f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80105d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80106f:	89 c2                	mov    %eax,%edx
  801071:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801074:	eb 07                	jmp    80107d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801076:	38 08                	cmp    %cl,(%eax)
  801078:	74 07                	je     801081 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80107a:	83 c0 01             	add    $0x1,%eax
  80107d:	39 d0                	cmp    %edx,%eax
  80107f:	72 f5                	jb     801076 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	8b 55 08             	mov    0x8(%ebp),%edx
  80108c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80108f:	eb 03                	jmp    801094 <strtol+0x11>
		s++;
  801091:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801094:	0f b6 0a             	movzbl (%edx),%ecx
  801097:	80 f9 09             	cmp    $0x9,%cl
  80109a:	74 f5                	je     801091 <strtol+0xe>
  80109c:	80 f9 20             	cmp    $0x20,%cl
  80109f:	74 f0                	je     801091 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010a1:	80 f9 2b             	cmp    $0x2b,%cl
  8010a4:	75 0a                	jne    8010b0 <strtol+0x2d>
		s++;
  8010a6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010a9:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ae:	eb 11                	jmp    8010c1 <strtol+0x3e>
  8010b0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010b5:	80 f9 2d             	cmp    $0x2d,%cl
  8010b8:	75 07                	jne    8010c1 <strtol+0x3e>
		s++, neg = 1;
  8010ba:	8d 52 01             	lea    0x1(%edx),%edx
  8010bd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010c1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  8010c6:	75 15                	jne    8010dd <strtol+0x5a>
  8010c8:	80 3a 30             	cmpb   $0x30,(%edx)
  8010cb:	75 10                	jne    8010dd <strtol+0x5a>
  8010cd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8010d1:	75 0a                	jne    8010dd <strtol+0x5a>
		s += 2, base = 16;
  8010d3:	83 c2 02             	add    $0x2,%edx
  8010d6:	b8 10 00 00 00       	mov    $0x10,%eax
  8010db:	eb 10                	jmp    8010ed <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	75 0c                	jne    8010ed <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010e1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010e3:	80 3a 30             	cmpb   $0x30,(%edx)
  8010e6:	75 05                	jne    8010ed <strtol+0x6a>
		s++, base = 8;
  8010e8:	83 c2 01             	add    $0x1,%edx
  8010eb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010f5:	0f b6 0a             	movzbl (%edx),%ecx
  8010f8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8010fb:	89 f0                	mov    %esi,%eax
  8010fd:	3c 09                	cmp    $0x9,%al
  8010ff:	77 08                	ja     801109 <strtol+0x86>
			dig = *s - '0';
  801101:	0f be c9             	movsbl %cl,%ecx
  801104:	83 e9 30             	sub    $0x30,%ecx
  801107:	eb 20                	jmp    801129 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801109:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80110c:	89 f0                	mov    %esi,%eax
  80110e:	3c 19                	cmp    $0x19,%al
  801110:	77 08                	ja     80111a <strtol+0x97>
			dig = *s - 'a' + 10;
  801112:	0f be c9             	movsbl %cl,%ecx
  801115:	83 e9 57             	sub    $0x57,%ecx
  801118:	eb 0f                	jmp    801129 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80111a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80111d:	89 f0                	mov    %esi,%eax
  80111f:	3c 19                	cmp    $0x19,%al
  801121:	77 16                	ja     801139 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801123:	0f be c9             	movsbl %cl,%ecx
  801126:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801129:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80112c:	7d 0f                	jge    80113d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80112e:	83 c2 01             	add    $0x1,%edx
  801131:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801135:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801137:	eb bc                	jmp    8010f5 <strtol+0x72>
  801139:	89 d8                	mov    %ebx,%eax
  80113b:	eb 02                	jmp    80113f <strtol+0xbc>
  80113d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80113f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801143:	74 05                	je     80114a <strtol+0xc7>
		*endptr = (char *) s;
  801145:	8b 75 0c             	mov    0xc(%ebp),%esi
  801148:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80114a:	f7 d8                	neg    %eax
  80114c:	85 ff                	test   %edi,%edi
  80114e:	0f 44 c3             	cmove  %ebx,%eax
}
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	57                   	push   %edi
  80115a:	56                   	push   %esi
  80115b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115c:	b8 00 00 00 00       	mov    $0x0,%eax
  801161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801164:	8b 55 08             	mov    0x8(%ebp),%edx
  801167:	89 c3                	mov    %eax,%ebx
  801169:	89 c7                	mov    %eax,%edi
  80116b:	89 c6                	mov    %eax,%esi
  80116d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <sys_cgetc>:

int
sys_cgetc(void)
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
  80117f:	b8 01 00 00 00       	mov    $0x1,%eax
  801184:	89 d1                	mov    %edx,%ecx
  801186:	89 d3                	mov    %edx,%ebx
  801188:	89 d7                	mov    %edx,%edi
  80118a:	89 d6                	mov    %edx,%esi
  80118c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  80119c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a1:	b8 03 00 00 00       	mov    $0x3,%eax
  8011a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a9:	89 cb                	mov    %ecx,%ebx
  8011ab:	89 cf                	mov    %ecx,%edi
  8011ad:	89 ce                	mov    %ecx,%esi
  8011af:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	7e 28                	jle    8011dd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  8011c8:	00 
  8011c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d0:	00 
  8011d1:	c7 04 24 05 21 80 00 	movl   $0x802105,(%esp)
  8011d8:	e8 49 07 00 00       	call   801926 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011dd:	83 c4 2c             	add    $0x2c,%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8011f5:	89 d1                	mov    %edx,%ecx
  8011f7:	89 d3                	mov    %edx,%ebx
  8011f9:	89 d7                	mov    %edx,%edi
  8011fb:	89 d6                	mov    %edx,%esi
  8011fd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5f                   	pop    %edi
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <sys_yield>:

void
sys_yield(void)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	57                   	push   %edi
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120a:	ba 00 00 00 00       	mov    $0x0,%edx
  80120f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801214:	89 d1                	mov    %edx,%ecx
  801216:	89 d3                	mov    %edx,%ebx
  801218:	89 d7                	mov    %edx,%edi
  80121a:	89 d6                	mov    %edx,%esi
  80121c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80121e:	5b                   	pop    %ebx
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	57                   	push   %edi
  801227:	56                   	push   %esi
  801228:	53                   	push   %ebx
  801229:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122c:	be 00 00 00 00       	mov    $0x0,%esi
  801231:	b8 04 00 00 00       	mov    $0x4,%eax
  801236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801239:	8b 55 08             	mov    0x8(%ebp),%edx
  80123c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80123f:	89 f7                	mov    %esi,%edi
  801241:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801243:	85 c0                	test   %eax,%eax
  801245:	7e 28                	jle    80126f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801247:	89 44 24 10          	mov    %eax,0x10(%esp)
  80124b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801252:	00 
  801253:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  80125a:	00 
  80125b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801262:	00 
  801263:	c7 04 24 05 21 80 00 	movl   $0x802105,(%esp)
  80126a:	e8 b7 06 00 00       	call   801926 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80126f:	83 c4 2c             	add    $0x2c,%esp
  801272:	5b                   	pop    %ebx
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	57                   	push   %edi
  80127b:	56                   	push   %esi
  80127c:	53                   	push   %ebx
  80127d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801280:	b8 05 00 00 00       	mov    $0x5,%eax
  801285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801288:	8b 55 08             	mov    0x8(%ebp),%edx
  80128b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801291:	8b 75 18             	mov    0x18(%ebp),%esi
  801294:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801296:	85 c0                	test   %eax,%eax
  801298:	7e 28                	jle    8012c2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80129a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80129e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012a5:	00 
  8012a6:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  8012ad:	00 
  8012ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012b5:	00 
  8012b6:	c7 04 24 05 21 80 00 	movl   $0x802105,(%esp)
  8012bd:	e8 64 06 00 00       	call   801926 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8012c2:	83 c4 2c             	add    $0x2c,%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5e                   	pop    %esi
  8012c7:	5f                   	pop    %edi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	57                   	push   %edi
  8012ce:	56                   	push   %esi
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d8:	b8 06 00 00 00       	mov    $0x6,%eax
  8012dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e3:	89 df                	mov    %ebx,%edi
  8012e5:	89 de                	mov    %ebx,%esi
  8012e7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	7e 28                	jle    801315 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8012f8:	00 
  8012f9:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  801300:	00 
  801301:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801308:	00 
  801309:	c7 04 24 05 21 80 00 	movl   $0x802105,(%esp)
  801310:	e8 11 06 00 00       	call   801926 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801315:	83 c4 2c             	add    $0x2c,%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	57                   	push   %edi
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
  801323:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801326:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132b:	b8 08 00 00 00       	mov    $0x8,%eax
  801330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801333:	8b 55 08             	mov    0x8(%ebp),%edx
  801336:	89 df                	mov    %ebx,%edi
  801338:	89 de                	mov    %ebx,%esi
  80133a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80133c:	85 c0                	test   %eax,%eax
  80133e:	7e 28                	jle    801368 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801340:	89 44 24 10          	mov    %eax,0x10(%esp)
  801344:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80134b:	00 
  80134c:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  801353:	00 
  801354:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80135b:	00 
  80135c:	c7 04 24 05 21 80 00 	movl   $0x802105,(%esp)
  801363:	e8 be 05 00 00       	call   801926 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801368:	83 c4 2c             	add    $0x2c,%esp
  80136b:	5b                   	pop    %ebx
  80136c:	5e                   	pop    %esi
  80136d:	5f                   	pop    %edi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	57                   	push   %edi
  801374:	56                   	push   %esi
  801375:	53                   	push   %ebx
  801376:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801379:	bb 00 00 00 00       	mov    $0x0,%ebx
  80137e:	b8 09 00 00 00       	mov    $0x9,%eax
  801383:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801386:	8b 55 08             	mov    0x8(%ebp),%edx
  801389:	89 df                	mov    %ebx,%edi
  80138b:	89 de                	mov    %ebx,%esi
  80138d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80138f:	85 c0                	test   %eax,%eax
  801391:	7e 28                	jle    8013bb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801393:	89 44 24 10          	mov    %eax,0x10(%esp)
  801397:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80139e:	00 
  80139f:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  8013a6:	00 
  8013a7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013ae:	00 
  8013af:	c7 04 24 05 21 80 00 	movl   $0x802105,(%esp)
  8013b6:	e8 6b 05 00 00       	call   801926 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8013bb:	83 c4 2c             	add    $0x2c,%esp
  8013be:	5b                   	pop    %ebx
  8013bf:	5e                   	pop    %esi
  8013c0:	5f                   	pop    %edi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    

008013c3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	57                   	push   %edi
  8013c7:	56                   	push   %esi
  8013c8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c9:	be 00 00 00 00       	mov    $0x0,%esi
  8013ce:	b8 0b 00 00 00       	mov    $0xb,%eax
  8013d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013dc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013df:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	57                   	push   %edi
  8013ea:	56                   	push   %esi
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013f4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fc:	89 cb                	mov    %ecx,%ebx
  8013fe:	89 cf                	mov    %ecx,%edi
  801400:	89 ce                	mov    %ecx,%esi
  801402:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801404:	85 c0                	test   %eax,%eax
  801406:	7e 28                	jle    801430 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801408:	89 44 24 10          	mov    %eax,0x10(%esp)
  80140c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801413:	00 
  801414:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  80141b:	00 
  80141c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801423:	00 
  801424:	c7 04 24 05 21 80 00 	movl   $0x802105,(%esp)
  80142b:	e8 f6 04 00 00       	call   801926 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801430:	83 c4 2c             	add    $0x2c,%esp
  801433:	5b                   	pop    %ebx
  801434:	5e                   	pop    %esi
  801435:	5f                   	pop    %edi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	57                   	push   %edi
  80143c:	56                   	push   %esi
  80143d:	53                   	push   %ebx
  80143e:	83 ec 2c             	sub    $0x2c,%esp
	void *addr = (void *) utf->utf_fault_va;
  801441:	8b 45 08             	mov    0x8(%ebp),%eax
  801444:	8b 30                	mov    (%eax),%esi
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf(" pgfault : fault va is  %08x\n", ( uint32_t ) addr ) ; 
	//cprintf(" pgfault : fault eip is  %08x\n", ( uint32_t ) utf->utf_eip ) ; 
	pde_t * pde_ptr = ( pde_t * ) ( UVPT + ( PDX(UVPT) << 12 ) + ( PDX(addr) << 2 ) ) ; 
  801446:	89 f0                	mov    %esi,%eax
  801448:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( UVPT + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  80144b:	89 c1                	mov    %eax,%ecx
  80144d:	c1 e1 0c             	shl    $0xc,%ecx
  801450:	89 f2                	mov    %esi,%edx
  801452:	c1 ea 0a             	shr    $0xa,%edx
  801455:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  80145b:	8d bc 11 00 00 40 ef 	lea    -0x10c00000(%ecx,%edx,1),%edi
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  801462:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  801469:	01 
  80146a:	75 1c                	jne    801488 <pgfault+0x50>
		panic(" in inc/fork.c <pgfault> : Page Directory Entry doesn't exsist!\n");
  80146c:	c7 44 24 08 14 21 80 	movl   $0x802114,0x8(%esp)
  801473:	00 
  801474:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80147b:	00 
  80147c:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  801483:	e8 9e 04 00 00       	call   801926 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  801488:	8b 07                	mov    (%edi),%eax
  80148a:	a8 01                	test   $0x1,%al
  80148c:	75 1c                	jne    8014aa <pgfault+0x72>
		panic(" in inc/fork.c <pgfault> : Page Table Entry doesn't exsist!\n");
  80148e:	c7 44 24 08 58 21 80 	movl   $0x802158,0x8(%esp)
  801495:	00 
  801496:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80149d:	00 
  80149e:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  8014a5:	e8 7c 04 00 00       	call   801926 <_panic>
	if (!( ( ( *pte_ptr ) & PTE_W ) || ( ( *pte_ptr ) & PTE_COW ) ) )
  8014aa:	a9 02 08 00 00       	test   $0x802,%eax
  8014af:	75 1c                	jne    8014cd <pgfault+0x95>
		panic(" in inc/fork.c <pgfault> : Invalid page!\n");
  8014b1:	c7 44 24 08 98 21 80 	movl   $0x802198,0x8(%esp)
  8014b8:	00 
  8014b9:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8014c0:	00 
  8014c1:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  8014c8:	e8 59 04 00 00       	call   801926 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid() ;
  8014cd:	e8 13 fd ff ff       	call   8011e5 <sys_getenvid>
  8014d2:	89 c3                	mov    %eax,%ebx
	//cprintf(" pgfault : %d\n %08x\n",envid , PFTEMP); 
	sys_page_alloc( envid , ( void * ) PFTEMP , (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W);  
  8014d4:	8b 07                	mov    (%edi),%eax
  8014d6:	25 05 06 00 00       	and    $0x605,%eax
  8014db:	83 c8 02             	or     $0x2,%eax
  8014de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014e2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014e9:	00 
  8014ea:	89 1c 24             	mov    %ebx,(%esp)
  8014ed:	e8 31 fd ff ff       	call   801223 <sys_page_alloc>
	//cprintf(" Did it reach here and made an alloc call?\n");
	memmove( ( void * ) PFTEMP , ( void * ) ROUNDDOWN( addr , PGSIZE ) , PGSIZE ) ; 
  8014f2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8014f8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8014ff:	00 
  801500:	89 74 24 04          	mov    %esi,0x4(%esp)
  801504:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80150b:	e8 94 fa ff ff       	call   800fa4 <memmove>
	sys_page_map( envid , ( void * ) PFTEMP , envid , ( void * ) ROUNDDOWN( addr , PGSIZE ) ,  (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W );  
  801510:	8b 07                	mov    (%edi),%eax
  801512:	25 05 06 00 00       	and    $0x605,%eax
  801517:	83 c8 02             	or     $0x2,%eax
  80151a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80151e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801522:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801526:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80152d:	00 
  80152e:	89 1c 24             	mov    %ebx,(%esp)
  801531:	e8 41 fd ff ff       	call   801277 <sys_page_map>
	sys_page_unmap( envid , PFTEMP ) ; 
  801536:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80153d:	00 
  80153e:	89 1c 24             	mov    %ebx,(%esp)
  801541:	e8 84 fd ff ff       	call   8012ca <sys_page_unmap>
	//panic("pgfault not implemented");
}
  801546:	83 c4 2c             	add    $0x2c,%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5f                   	pop    %edi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	57                   	push   %edi
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
  801554:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// First , set handler
	set_pgfault_handler(pgfault); 
  801557:	c7 04 24 38 14 80 00 	movl   $0x801438,(%esp)
  80155e:	e8 19 04 00 00       	call   80197c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801563:	b8 07 00 00 00       	mov    $0x7,%eax
  801568:	cd 30                	int    $0x30
  80156a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80156d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
  801570:	85 c0                	test   %eax,%eax
  801572:	79 1c                	jns    801590 <fork+0x42>
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
  801574:	c7 44 24 08 c4 21 80 	movl   $0x8021c4,0x8(%esp)
  80157b:	00 
  80157c:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  801583:	00 
  801584:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  80158b:	e8 96 03 00 00       	call   801926 <_panic>
	if ( childid == 0 ) {
  801590:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801594:	74 17                	je     8015ad <fork+0x5f>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  801596:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80159b:	c1 e8 16             	shr    $0x16,%eax
  80159e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8015a1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8015a8:	e9 22 02 00 00       	jmp    8017cf <fork+0x281>
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
	if ( childid == 0 ) {
		thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  8015ad:	e8 33 fc ff ff       	call   8011e5 <sys_getenvid>
  8015b2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015b7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015bf:	a3 0c 30 80 00       	mov    %eax,0x80300c
		return 0 ;
  8015c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c9:	e9 22 02 00 00       	jmp    8017f0 <fork+0x2a2>
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
  8015ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015d1:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  8015d8:	01 
  8015d9:	0f 84 ec 01 00 00    	je     8017cb <fork+0x27d>
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
  8015df:	89 c6                	mov    %eax,%esi
  8015e1:	c1 e0 0c             	shl    $0xc,%eax
  8015e4:	8d b8 00 00 40 ef    	lea    -0x10c00000(%eax),%edi
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
			     ( ptx != PTX(UXSTACKTOP-PGSIZE) ) ) {
				//cprintf(" fork : pdx : %d , ptx : %d\n" , pdx , ptx ) ; 
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
  8015ea:	c1 e6 16             	shl    $0x16,%esi
  8015ed:	bb 00 00 00 00       	mov    $0x0,%ebx
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
			if ( ! ( ( * pte_ptr ) & PTE_P ) )  continue ; 
  8015f2:	f6 04 9f 01          	testb  $0x1,(%edi,%ebx,4)
  8015f6:	0f 84 ba 01 00 00    	je     8017b6 <fork+0x268>
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
  8015fc:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  801602:	75 0d                	jne    801611 <fork+0xc3>
  801604:	81 7d dc ba 03 00 00 	cmpl   $0x3ba,-0x24(%ebp)
  80160b:	0f 84 8a 01 00 00    	je     80179b <fork+0x24d>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid() ; 
  801611:	e8 cf fb ff ff       	call   8011e5 <sys_getenvid>
  801616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t addr = pn * PGSIZE ;
	//cprintf(" duppage : now envid is : %d\n", sys_getenvid() ) ;
	//cprintf(" duppage : page address is %08x %d %d\n" , addr,PDX(addr),PTX(addr) ) ;
	pde_t * pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd ) + ( PDX(addr) << 2 ) ) ; 
  801619:	89 f0                	mov    %esi,%eax
  80161b:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  80161e:	89 c1                	mov    %eax,%ecx
  801620:	c1 e1 0c             	shl    $0xc,%ecx
  801623:	81 c1 00 00 40 ef    	add    $0xef400000,%ecx
  801629:	89 f2                	mov    %esi,%edx
  80162b:	c1 ea 0a             	shr    $0xa,%edx
  80162e:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801634:	01 ca                	add    %ecx,%edx
	
	//cprintf(" duppage : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
	//cprintf(" duppage : pte_ptr's value is : %08x\n" , ( * pte_ptr ) ) ;
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  801636:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  80163b:	f6 04 81 01          	testb  $0x1,(%ecx,%eax,4)
  80163f:	75 1c                	jne    80165d <fork+0x10f>
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
  801641:	c7 44 24 08 f8 21 80 	movl   $0x8021f8,0x8(%esp)
  801648:	00 
  801649:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801650:	00 
  801651:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  801658:	e8 c9 02 00 00       	call   801926 <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  80165d:	8b 02                	mov    (%edx),%eax
  80165f:	a8 01                	test   $0x1,%al
  801661:	75 1c                	jne    80167f <fork+0x131>
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
  801663:	c7 44 24 08 3c 22 80 	movl   $0x80223c,0x8(%esp)
  80166a:	00 
  80166b:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801672:	00 
  801673:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  80167a:	e8 a7 02 00 00       	call   801926 <_panic>
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
  80167f:	89 c2                	mov    %eax,%edx
  801681:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	if ( perm & PTE_W ) {
  801687:	a8 02                	test   $0x2,%al
  801689:	0f 84 8b 00 00 00    	je     80171a <fork+0x1cc>
		if ( sys_page_map( curenvid , ( void * ) addr , 
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
  80168f:	89 d0                	mov    %edx,%eax
  801691:	83 f0 02             	xor    $0x2,%eax
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
	if (!( ( * pte_ptr ) & PTE_P ) ) 
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
	if ( perm & PTE_W ) {
		if ( sys_page_map( curenvid , ( void * ) addr , 
  801694:	80 cc 08             	or     $0x8,%ah
  801697:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80169a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80169e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	e8 bf fb ff ff       	call   801277 <sys_page_map>
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	79 1c                	jns    8016d8 <fork+0x18a>
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page! %e\n");
  8016bc:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  8016c3:	00 
  8016c4:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8016cb:	00 
  8016cc:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  8016d3:	e8 4e 02 00 00       	call   801926 <_panic>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  8016d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016df:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ee:	89 04 24             	mov    %eax,(%esp)
  8016f1:	e8 81 fb ff ff       	call   801277 <sys_page_map>
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	0f 89 b8 00 00 00    	jns    8017b6 <fork+0x268>
				   curenvid , ( void * ) addr , 
				   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  8016fe:	c7 44 24 08 b4 22 80 	movl   $0x8022b4,0x8(%esp)
  801705:	00 
  801706:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80170d:	00 
  80170e:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  801715:	e8 0c 02 00 00       	call   801926 <_panic>
		return 0 ; 	
	}  
	if ( perm & PTE_COW ) {
  80171a:	f6 c4 08             	test   $0x8,%ah
  80171d:	74 3e                	je     80175d <fork+0x20f>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  80171f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801723:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801727:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80172a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80172e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801735:	89 04 24             	mov    %eax,(%esp)
  801738:	e8 3a fb ff ff       	call   801277 <sys_page_map>
  80173d:	85 c0                	test   %eax,%eax
  80173f:	79 75                	jns    8017b6 <fork+0x268>
                                   envid    , ( void * ) addr , 
                                   perm ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  801741:	c7 44 24 08 b4 22 80 	movl   $0x8022b4,0x8(%esp)
  801748:	00 
  801749:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801750:	00 
  801751:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  801758:	e8 c9 01 00 00       	call   801926 <_panic>
		return 0 ;
	}
	if ( sys_page_map( curenvid , ( void * ) addr , 
  80175d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801761:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801765:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801768:	89 44 24 08          	mov    %eax,0x8(%esp)
  80176c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801770:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801773:	89 04 24             	mov    %eax,(%esp)
  801776:	e8 fc fa ff ff       	call   801277 <sys_page_map>
  80177b:	85 c0                	test   %eax,%eax
  80177d:	79 37                	jns    8017b6 <fork+0x268>
		           envid    , ( void * ) addr , 
			   perm ) < 0 ) 
		panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  80177f:	c7 44 24 08 b4 22 80 	movl   $0x8022b4,0x8(%esp)
  801786:	00 
  801787:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80178e:	00 
  80178f:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  801796:	e8 8b 01 00 00       	call   801926 <_panic>
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
  80179b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017a2:	00 
  8017a3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017aa:	ee 
  8017ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017ae:	89 04 24             	mov    %eax,(%esp)
  8017b1:	e8 6d fa ff ff       	call   801223 <sys_page_alloc>
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
  8017b6:	83 c3 01             	add    $0x1,%ebx
  8017b9:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8017bf:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8017c5:	0f 85 27 fe ff ff    	jne    8015f2 <fork+0xa4>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  8017cb:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  8017cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017d2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  8017d5:	0f 85 f3 fd ff ff    	jne    8015ce <fork+0x80>
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
		}						
	}
	sys_env_set_status( childid , ENV_RUNNABLE ) ;
  8017db:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8017e2:	00 
  8017e3:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8017e6:	89 3c 24             	mov    %edi,(%esp)
  8017e9:	e8 2f fb ff ff       	call   80131d <sys_env_set_status>
	return childid ;
  8017ee:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8017f0:	83 c4 3c             	add    $0x3c,%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5f                   	pop    %edi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <sfork>:

// Challenge!
int
sfork(void)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8017fe:	c7 44 24 08 f3 22 80 	movl   $0x8022f3,0x8(%esp)
  801805:	00 
  801806:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  80180d:	00 
  80180e:	c7 04 24 e8 22 80 00 	movl   $0x8022e8,(%esp)
  801815:	e8 0c 01 00 00       	call   801926 <_panic>
  80181a:	66 90                	xchg   %ax,%ax
  80181c:	66 90                	xchg   %ax,%ax
  80181e:	66 90                	xchg   %ax,%ax

00801820 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	56                   	push   %esi
  801824:	53                   	push   %ebx
  801825:	83 ec 10             	sub    $0x10,%esp
  801828:	8b 75 08             	mov    0x8(%ebp),%esi
  80182b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int result = 0 ; 
	if ( pg ) result = sys_ipc_recv(pg);	
  801831:	85 c0                	test   %eax,%eax
  801833:	74 0a                	je     80183f <ipc_recv+0x1f>
  801835:	89 04 24             	mov    %eax,(%esp)
  801838:	e8 a9 fb ff ff       	call   8013e6 <sys_ipc_recv>
  80183d:	eb 0c                	jmp    80184b <ipc_recv+0x2b>
	     else result = sys_ipc_recv((void*)UTOP);
  80183f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801846:	e8 9b fb ff ff       	call   8013e6 <sys_ipc_recv>
	if ( result < 0 ) {
  80184b:	85 c0                	test   %eax,%eax
  80184d:	79 16                	jns    801865 <ipc_recv+0x45>
		if ( from_env_store ) 
  80184f:	85 f6                	test   %esi,%esi
  801851:	74 06                	je     801859 <ipc_recv+0x39>
			(*from_env_store) = 0 ;
  801853:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if ( perm_store)
  801859:	85 db                	test   %ebx,%ebx
  80185b:	74 2c                	je     801889 <ipc_recv+0x69>
			(*perm_store) = 0 ;	
  80185d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801863:	eb 24                	jmp    801889 <ipc_recv+0x69>
		return result; 
	}
	if ( from_env_store ) 
  801865:	85 f6                	test   %esi,%esi
  801867:	74 0a                	je     801873 <ipc_recv+0x53>
		(*from_env_store) = thisenv->env_ipc_from ;
  801869:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80186e:	8b 40 74             	mov    0x74(%eax),%eax
  801871:	89 06                	mov    %eax,(%esi)
	if ( perm_store)
  801873:	85 db                	test   %ebx,%ebx
  801875:	74 0a                	je     801881 <ipc_recv+0x61>
		(*perm_store) = thisenv->env_ipc_perm ;	
  801877:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80187c:	8b 40 78             	mov    0x78(%eax),%eax
  80187f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801881:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801886:	8b 40 70             	mov    0x70(%eax),%eax
}
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	5b                   	pop    %ebx
  80188d:	5e                   	pop    %esi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	57                   	push   %edi
  801894:	56                   	push   %esi
  801895:	53                   	push   %ebx
  801896:	83 ec 1c             	sub    $0x1c,%esp
  801899:	8b 7d 08             	mov    0x8(%ebp),%edi
  80189c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80189f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = -E_IPC_NOT_RECV ; 
	while ( result == -E_IPC_NOT_RECV ) { 
		if ( pg ) 
  8018a2:	85 db                	test   %ebx,%ebx
  8018a4:	74 19                	je     8018bf <ipc_send+0x2f>
			result = sys_ipc_try_send( to_env , val , pg , perm ) ; 
  8018a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018ad:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018b5:	89 3c 24             	mov    %edi,(%esp)
  8018b8:	e8 06 fb ff ff       	call   8013c3 <sys_ipc_try_send>
  8018bd:	eb 1b                	jmp    8018da <ipc_send+0x4a>
		else
			result = sys_ipc_try_send( to_env , val , (void*)UTOP , perm ) ; 
  8018bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018c6:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8018cd:	ee 
  8018ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d2:	89 3c 24             	mov    %edi,(%esp)
  8018d5:	e8 e9 fa ff ff       	call   8013c3 <sys_ipc_try_send>
		if ( result != -E_IPC_NOT_RECV ) break ; 
  8018da:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8018dd:	75 07                	jne    8018e6 <ipc_send+0x56>
		sys_yield();
  8018df:	e8 20 f9 ff ff       	call   801204 <sys_yield>
  8018e4:	eb bc                	jmp    8018a2 <ipc_send+0x12>
	}
	if ( result == 0 ) return ; 
	if ( result == -E_IPC_NOT_RECV ) return ;
	//panic("ipc_send not implemented");
}
  8018e6:	83 c4 1c             	add    $0x1c,%esp
  8018e9:	5b                   	pop    %ebx
  8018ea:	5e                   	pop    %esi
  8018eb:	5f                   	pop    %edi
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    

008018ee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8018f4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8018f9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8018fc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801902:	8b 52 50             	mov    0x50(%edx),%edx
  801905:	39 ca                	cmp    %ecx,%edx
  801907:	75 0d                	jne    801916 <ipc_find_env+0x28>
			return envs[i].env_id;
  801909:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80190c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801911:	8b 40 40             	mov    0x40(%eax),%eax
  801914:	eb 0e                	jmp    801924 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801916:	83 c0 01             	add    $0x1,%eax
  801919:	3d 00 04 00 00       	cmp    $0x400,%eax
  80191e:	75 d9                	jne    8018f9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801920:	66 b8 00 00          	mov    $0x0,%ax
}
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80192e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801931:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801937:	e8 a9 f8 ff ff       	call   8011e5 <sys_getenvid>
  80193c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801943:	8b 55 08             	mov    0x8(%ebp),%edx
  801946:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80194a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80194e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801952:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  801959:	e8 81 e9 ff ff       	call   8002df <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80195e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801962:	8b 45 10             	mov    0x10(%ebp),%eax
  801965:	89 04 24             	mov    %eax,(%esp)
  801968:	e8 11 e9 ff ff       	call   80027e <vcprintf>
	cprintf("\n");
  80196d:	c7 04 24 92 1c 80 00 	movl   $0x801c92,(%esp)
  801974:	e8 66 e9 ff ff       	call   8002df <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801979:	cc                   	int3   
  80197a:	eb fd                	jmp    801979 <_panic+0x53>

0080197c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801982:	83 3d 10 30 80 00 00 	cmpl   $0x0,0x803010
  801989:	75 32                	jne    8019bd <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  80198b:	e8 55 f8 ff ff       	call   8011e5 <sys_getenvid>
  801990:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801997:	00 
  801998:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80199f:	ee 
  8019a0:	89 04 24             	mov    %eax,(%esp)
  8019a3:	e8 7b f8 ff ff       	call   801223 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  8019a8:	e8 38 f8 ff ff       	call   8011e5 <sys_getenvid>
  8019ad:	c7 44 24 04 c7 19 80 	movl   $0x8019c7,0x4(%esp)
  8019b4:	00 
  8019b5:	89 04 24             	mov    %eax,(%esp)
  8019b8:	e8 b3 f9 ff ff       	call   801370 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8019bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c0:	a3 10 30 80 00       	mov    %eax,0x803010
}
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    

008019c7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8019c7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8019c8:	a1 10 30 80 00       	mov    0x803010,%eax
	call *%eax
  8019cd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8019cf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  8019d2:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  8019d5:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  8019d9:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  8019dd:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  8019e0:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  8019e4:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  8019e6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  8019e7:	83 c4 04             	add    $0x4,%esp
	popfl 	
  8019ea:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8019eb:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8019ec:	c3                   	ret    
  8019ed:	66 90                	xchg   %ax,%ax
  8019ef:	90                   	nop

008019f0 <__udivdi3>:
  8019f0:	55                   	push   %ebp
  8019f1:	57                   	push   %edi
  8019f2:	56                   	push   %esi
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8019fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8019fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801a02:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a0c:	89 ea                	mov    %ebp,%edx
  801a0e:	89 0c 24             	mov    %ecx,(%esp)
  801a11:	75 2d                	jne    801a40 <__udivdi3+0x50>
  801a13:	39 e9                	cmp    %ebp,%ecx
  801a15:	77 61                	ja     801a78 <__udivdi3+0x88>
  801a17:	85 c9                	test   %ecx,%ecx
  801a19:	89 ce                	mov    %ecx,%esi
  801a1b:	75 0b                	jne    801a28 <__udivdi3+0x38>
  801a1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a22:	31 d2                	xor    %edx,%edx
  801a24:	f7 f1                	div    %ecx
  801a26:	89 c6                	mov    %eax,%esi
  801a28:	31 d2                	xor    %edx,%edx
  801a2a:	89 e8                	mov    %ebp,%eax
  801a2c:	f7 f6                	div    %esi
  801a2e:	89 c5                	mov    %eax,%ebp
  801a30:	89 f8                	mov    %edi,%eax
  801a32:	f7 f6                	div    %esi
  801a34:	89 ea                	mov    %ebp,%edx
  801a36:	83 c4 0c             	add    $0xc,%esp
  801a39:	5e                   	pop    %esi
  801a3a:	5f                   	pop    %edi
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    
  801a3d:	8d 76 00             	lea    0x0(%esi),%esi
  801a40:	39 e8                	cmp    %ebp,%eax
  801a42:	77 24                	ja     801a68 <__udivdi3+0x78>
  801a44:	0f bd e8             	bsr    %eax,%ebp
  801a47:	83 f5 1f             	xor    $0x1f,%ebp
  801a4a:	75 3c                	jne    801a88 <__udivdi3+0x98>
  801a4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a50:	39 34 24             	cmp    %esi,(%esp)
  801a53:	0f 86 9f 00 00 00    	jbe    801af8 <__udivdi3+0x108>
  801a59:	39 d0                	cmp    %edx,%eax
  801a5b:	0f 82 97 00 00 00    	jb     801af8 <__udivdi3+0x108>
  801a61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a68:	31 d2                	xor    %edx,%edx
  801a6a:	31 c0                	xor    %eax,%eax
  801a6c:	83 c4 0c             	add    $0xc,%esp
  801a6f:	5e                   	pop    %esi
  801a70:	5f                   	pop    %edi
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    
  801a73:	90                   	nop
  801a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a78:	89 f8                	mov    %edi,%eax
  801a7a:	f7 f1                	div    %ecx
  801a7c:	31 d2                	xor    %edx,%edx
  801a7e:	83 c4 0c             	add    $0xc,%esp
  801a81:	5e                   	pop    %esi
  801a82:	5f                   	pop    %edi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    
  801a85:	8d 76 00             	lea    0x0(%esi),%esi
  801a88:	89 e9                	mov    %ebp,%ecx
  801a8a:	8b 3c 24             	mov    (%esp),%edi
  801a8d:	d3 e0                	shl    %cl,%eax
  801a8f:	89 c6                	mov    %eax,%esi
  801a91:	b8 20 00 00 00       	mov    $0x20,%eax
  801a96:	29 e8                	sub    %ebp,%eax
  801a98:	89 c1                	mov    %eax,%ecx
  801a9a:	d3 ef                	shr    %cl,%edi
  801a9c:	89 e9                	mov    %ebp,%ecx
  801a9e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801aa2:	8b 3c 24             	mov    (%esp),%edi
  801aa5:	09 74 24 08          	or     %esi,0x8(%esp)
  801aa9:	89 d6                	mov    %edx,%esi
  801aab:	d3 e7                	shl    %cl,%edi
  801aad:	89 c1                	mov    %eax,%ecx
  801aaf:	89 3c 24             	mov    %edi,(%esp)
  801ab2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ab6:	d3 ee                	shr    %cl,%esi
  801ab8:	89 e9                	mov    %ebp,%ecx
  801aba:	d3 e2                	shl    %cl,%edx
  801abc:	89 c1                	mov    %eax,%ecx
  801abe:	d3 ef                	shr    %cl,%edi
  801ac0:	09 d7                	or     %edx,%edi
  801ac2:	89 f2                	mov    %esi,%edx
  801ac4:	89 f8                	mov    %edi,%eax
  801ac6:	f7 74 24 08          	divl   0x8(%esp)
  801aca:	89 d6                	mov    %edx,%esi
  801acc:	89 c7                	mov    %eax,%edi
  801ace:	f7 24 24             	mull   (%esp)
  801ad1:	39 d6                	cmp    %edx,%esi
  801ad3:	89 14 24             	mov    %edx,(%esp)
  801ad6:	72 30                	jb     801b08 <__udivdi3+0x118>
  801ad8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801adc:	89 e9                	mov    %ebp,%ecx
  801ade:	d3 e2                	shl    %cl,%edx
  801ae0:	39 c2                	cmp    %eax,%edx
  801ae2:	73 05                	jae    801ae9 <__udivdi3+0xf9>
  801ae4:	3b 34 24             	cmp    (%esp),%esi
  801ae7:	74 1f                	je     801b08 <__udivdi3+0x118>
  801ae9:	89 f8                	mov    %edi,%eax
  801aeb:	31 d2                	xor    %edx,%edx
  801aed:	e9 7a ff ff ff       	jmp    801a6c <__udivdi3+0x7c>
  801af2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801af8:	31 d2                	xor    %edx,%edx
  801afa:	b8 01 00 00 00       	mov    $0x1,%eax
  801aff:	e9 68 ff ff ff       	jmp    801a6c <__udivdi3+0x7c>
  801b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b08:	8d 47 ff             	lea    -0x1(%edi),%eax
  801b0b:	31 d2                	xor    %edx,%edx
  801b0d:	83 c4 0c             	add    $0xc,%esp
  801b10:	5e                   	pop    %esi
  801b11:	5f                   	pop    %edi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    
  801b14:	66 90                	xchg   %ax,%ax
  801b16:	66 90                	xchg   %ax,%ax
  801b18:	66 90                	xchg   %ax,%ax
  801b1a:	66 90                	xchg   %ax,%ax
  801b1c:	66 90                	xchg   %ax,%ax
  801b1e:	66 90                	xchg   %ax,%ax

00801b20 <__umoddi3>:
  801b20:	55                   	push   %ebp
  801b21:	57                   	push   %edi
  801b22:	56                   	push   %esi
  801b23:	83 ec 14             	sub    $0x14,%esp
  801b26:	8b 44 24 28          	mov    0x28(%esp),%eax
  801b2a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801b2e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801b32:	89 c7                	mov    %eax,%edi
  801b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b38:	8b 44 24 30          	mov    0x30(%esp),%eax
  801b3c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801b40:	89 34 24             	mov    %esi,(%esp)
  801b43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b47:	85 c0                	test   %eax,%eax
  801b49:	89 c2                	mov    %eax,%edx
  801b4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b4f:	75 17                	jne    801b68 <__umoddi3+0x48>
  801b51:	39 fe                	cmp    %edi,%esi
  801b53:	76 4b                	jbe    801ba0 <__umoddi3+0x80>
  801b55:	89 c8                	mov    %ecx,%eax
  801b57:	89 fa                	mov    %edi,%edx
  801b59:	f7 f6                	div    %esi
  801b5b:	89 d0                	mov    %edx,%eax
  801b5d:	31 d2                	xor    %edx,%edx
  801b5f:	83 c4 14             	add    $0x14,%esp
  801b62:	5e                   	pop    %esi
  801b63:	5f                   	pop    %edi
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    
  801b66:	66 90                	xchg   %ax,%ax
  801b68:	39 f8                	cmp    %edi,%eax
  801b6a:	77 54                	ja     801bc0 <__umoddi3+0xa0>
  801b6c:	0f bd e8             	bsr    %eax,%ebp
  801b6f:	83 f5 1f             	xor    $0x1f,%ebp
  801b72:	75 5c                	jne    801bd0 <__umoddi3+0xb0>
  801b74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b78:	39 3c 24             	cmp    %edi,(%esp)
  801b7b:	0f 87 e7 00 00 00    	ja     801c68 <__umoddi3+0x148>
  801b81:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b85:	29 f1                	sub    %esi,%ecx
  801b87:	19 c7                	sbb    %eax,%edi
  801b89:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b91:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b95:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b99:	83 c4 14             	add    $0x14,%esp
  801b9c:	5e                   	pop    %esi
  801b9d:	5f                   	pop    %edi
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    
  801ba0:	85 f6                	test   %esi,%esi
  801ba2:	89 f5                	mov    %esi,%ebp
  801ba4:	75 0b                	jne    801bb1 <__umoddi3+0x91>
  801ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bab:	31 d2                	xor    %edx,%edx
  801bad:	f7 f6                	div    %esi
  801baf:	89 c5                	mov    %eax,%ebp
  801bb1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bb5:	31 d2                	xor    %edx,%edx
  801bb7:	f7 f5                	div    %ebp
  801bb9:	89 c8                	mov    %ecx,%eax
  801bbb:	f7 f5                	div    %ebp
  801bbd:	eb 9c                	jmp    801b5b <__umoddi3+0x3b>
  801bbf:	90                   	nop
  801bc0:	89 c8                	mov    %ecx,%eax
  801bc2:	89 fa                	mov    %edi,%edx
  801bc4:	83 c4 14             	add    $0x14,%esp
  801bc7:	5e                   	pop    %esi
  801bc8:	5f                   	pop    %edi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    
  801bcb:	90                   	nop
  801bcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	8b 04 24             	mov    (%esp),%eax
  801bd3:	be 20 00 00 00       	mov    $0x20,%esi
  801bd8:	89 e9                	mov    %ebp,%ecx
  801bda:	29 ee                	sub    %ebp,%esi
  801bdc:	d3 e2                	shl    %cl,%edx
  801bde:	89 f1                	mov    %esi,%ecx
  801be0:	d3 e8                	shr    %cl,%eax
  801be2:	89 e9                	mov    %ebp,%ecx
  801be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be8:	8b 04 24             	mov    (%esp),%eax
  801beb:	09 54 24 04          	or     %edx,0x4(%esp)
  801bef:	89 fa                	mov    %edi,%edx
  801bf1:	d3 e0                	shl    %cl,%eax
  801bf3:	89 f1                	mov    %esi,%ecx
  801bf5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bfd:	d3 ea                	shr    %cl,%edx
  801bff:	89 e9                	mov    %ebp,%ecx
  801c01:	d3 e7                	shl    %cl,%edi
  801c03:	89 f1                	mov    %esi,%ecx
  801c05:	d3 e8                	shr    %cl,%eax
  801c07:	89 e9                	mov    %ebp,%ecx
  801c09:	09 f8                	or     %edi,%eax
  801c0b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801c0f:	f7 74 24 04          	divl   0x4(%esp)
  801c13:	d3 e7                	shl    %cl,%edi
  801c15:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c19:	89 d7                	mov    %edx,%edi
  801c1b:	f7 64 24 08          	mull   0x8(%esp)
  801c1f:	39 d7                	cmp    %edx,%edi
  801c21:	89 c1                	mov    %eax,%ecx
  801c23:	89 14 24             	mov    %edx,(%esp)
  801c26:	72 2c                	jb     801c54 <__umoddi3+0x134>
  801c28:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801c2c:	72 22                	jb     801c50 <__umoddi3+0x130>
  801c2e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801c32:	29 c8                	sub    %ecx,%eax
  801c34:	19 d7                	sbb    %edx,%edi
  801c36:	89 e9                	mov    %ebp,%ecx
  801c38:	89 fa                	mov    %edi,%edx
  801c3a:	d3 e8                	shr    %cl,%eax
  801c3c:	89 f1                	mov    %esi,%ecx
  801c3e:	d3 e2                	shl    %cl,%edx
  801c40:	89 e9                	mov    %ebp,%ecx
  801c42:	d3 ef                	shr    %cl,%edi
  801c44:	09 d0                	or     %edx,%eax
  801c46:	89 fa                	mov    %edi,%edx
  801c48:	83 c4 14             	add    $0x14,%esp
  801c4b:	5e                   	pop    %esi
  801c4c:	5f                   	pop    %edi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    
  801c4f:	90                   	nop
  801c50:	39 d7                	cmp    %edx,%edi
  801c52:	75 da                	jne    801c2e <__umoddi3+0x10e>
  801c54:	8b 14 24             	mov    (%esp),%edx
  801c57:	89 c1                	mov    %eax,%ecx
  801c59:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801c5d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801c61:	eb cb                	jmp    801c2e <__umoddi3+0x10e>
  801c63:	90                   	nop
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801c6c:	0f 82 0f ff ff ff    	jb     801b81 <__umoddi3+0x61>
  801c72:	e9 1a ff ff ff       	jmp    801b91 <__umoddi3+0x71>
