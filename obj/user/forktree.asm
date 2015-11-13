
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 c2 00 00 00       	call   8000f3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 b3 10 00 00       	call   8010f5 <sys_getenvid>
  800042:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 a0 1a 80 00 	movl   $0x801aa0,(%esp)
  800051:	e8 9c 01 00 00       	call   8001f2 <cprintf>

	forkchild(cur, '0');
  800056:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005d:	00 
  80005e:	89 1c 24             	mov    %ebx,(%esp)
  800061:	e8 16 00 00 00       	call   80007c <forkchild>
	forkchild(cur, '1');
  800066:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006d:	00 
  80006e:	89 1c 24             	mov    %ebx,(%esp)
  800071:	e8 06 00 00 00       	call   80007c <forkchild>
}
  800076:	83 c4 14             	add    $0x14,%esp
  800079:	5b                   	pop    %ebx
  80007a:	5d                   	pop    %ebp
  80007b:	c3                   	ret    

0080007c <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	83 ec 30             	sub    $0x30,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008a:	89 1c 24             	mov    %ebx,(%esp)
  80008d:	e8 4e 0c 00 00       	call   800ce0 <strlen>
  800092:	83 f8 02             	cmp    $0x2,%eax
  800095:	7f 41                	jg     8000d8 <forkchild+0x5c>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800097:	89 f0                	mov    %esi,%eax
  800099:	0f be f0             	movsbl %al,%esi
  80009c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a4:	c7 44 24 08 b1 1a 80 	movl   $0x801ab1,0x8(%esp)
  8000ab:	00 
  8000ac:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b3:	00 
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	89 04 24             	mov    %eax,(%esp)
  8000ba:	e8 f5 0b 00 00       	call   800cb4 <snprintf>
	if (fork() == 0) {
  8000bf:	e8 9a 13 00 00       	call   80145e <fork>
  8000c4:	85 c0                	test   %eax,%eax
  8000c6:	75 10                	jne    8000d8 <forkchild+0x5c>
		forktree(nxt);
  8000c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cb:	89 04 24             	mov    %eax,(%esp)
  8000ce:	e8 60 ff ff ff       	call   800033 <forktree>
		exit();
  8000d3:	e8 63 00 00 00       	call   80013b <exit>
	}
}
  8000d8:	83 c4 30             	add    $0x30,%esp
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e5:	c7 04 24 b0 1a 80 00 	movl   $0x801ab0,(%esp)
  8000ec:	e8 42 ff ff ff       	call   800033 <forktree>
}
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 10             	sub    $0x10,%esp
  8000fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800101:	e8 ef 0f 00 00       	call   8010f5 <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 04 30 80 00       	mov    %eax,0x803004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800118:	85 db                	test   %ebx,%ebx
  80011a:	7e 07                	jle    800123 <libmain+0x30>
		binaryname = argv[0];
  80011c:	8b 06                	mov    (%esi),%eax
  80011e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800123:	89 74 24 04          	mov    %esi,0x4(%esp)
  800127:	89 1c 24             	mov    %ebx,(%esp)
  80012a:	e8 b0 ff ff ff       	call   8000df <umain>

	// exit gracefully
	exit();
  80012f:	e8 07 00 00 00       	call   80013b <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 56 0f 00 00       	call   8010a3 <sys_env_destroy>
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	53                   	push   %ebx
  800153:	83 ec 14             	sub    $0x14,%esp
  800156:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800159:	8b 13                	mov    (%ebx),%edx
  80015b:	8d 42 01             	lea    0x1(%edx),%eax
  80015e:	89 03                	mov    %eax,(%ebx)
  800160:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800163:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800167:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016c:	75 19                	jne    800187 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80016e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800175:	00 
  800176:	8d 43 08             	lea    0x8(%ebx),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 e5 0e 00 00       	call   801066 <sys_cputs>
		b->idx = 0;
  800181:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800187:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018b:	83 c4 14             	add    $0x14,%esp
  80018e:	5b                   	pop    %ebx
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80019a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a1:	00 00 00 
	b.cnt = 0;
  8001a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c6:	c7 04 24 4f 01 80 00 	movl   $0x80014f,(%esp)
  8001cd:	e8 ad 02 00 00       	call   80047f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	e8 7c 0e 00 00       	call   801066 <sys_cputs>

	return b.cnt;
}
  8001ea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    

008001f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	e8 87 ff ff ff       	call   800191 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    
  80020c:	66 90                	xchg   %ax,%ax
  80020e:	66 90                	xchg   %ax,%ax

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 3c             	sub    $0x3c,%esp
  800219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80021c:	89 d7                	mov    %edx,%edi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 c3                	mov    %eax,%ebx
  800229:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80022c:	8b 45 10             	mov    0x10(%ebp),%eax
  80022f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	b9 00 00 00 00       	mov    $0x0,%ecx
  800237:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023d:	39 d9                	cmp    %ebx,%ecx
  80023f:	72 05                	jb     800246 <printnum+0x36>
  800241:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800244:	77 69                	ja     8002af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800246:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800249:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80024d:	83 ee 01             	sub    $0x1,%esi
  800250:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800254:	89 44 24 08          	mov    %eax,0x8(%esp)
  800258:	8b 44 24 08          	mov    0x8(%esp),%eax
  80025c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800260:	89 c3                	mov    %eax,%ebx
  800262:	89 d6                	mov    %edx,%esi
  800264:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800267:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80026a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80026e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	e8 7c 15 00 00       	call   801800 <__udivdi3>
  800284:	89 d9                	mov    %ebx,%ecx
  800286:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80028a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028e:	89 04 24             	mov    %eax,(%esp)
  800291:	89 54 24 04          	mov    %edx,0x4(%esp)
  800295:	89 fa                	mov    %edi,%edx
  800297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029a:	e8 71 ff ff ff       	call   800210 <printnum>
  80029f:	eb 1b                	jmp    8002bc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	ff d3                	call   *%ebx
  8002ad:	eb 03                	jmp    8002b2 <printnum+0xa2>
  8002af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 ee 01             	sub    $0x1,%esi
  8002b5:	85 f6                	test   %esi,%esi
  8002b7:	7f e8                	jg     8002a1 <printnum+0x91>
  8002b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 4c 16 00 00       	call   801930 <__umoddi3>
  8002e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e8:	0f be 80 c0 1a 80 00 	movsbl 0x801ac0(%eax),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f5:	ff d0                	call   *%eax
}
  8002f7:	83 c4 3c             	add    $0x3c,%esp
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
  800305:	83 ec 3c             	sub    $0x3c,%esp
  800308:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80030b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80030e:	89 cf                	mov    %ecx,%edi
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800316:	8b 45 0c             	mov    0xc(%ebp),%eax
  800319:	89 c3                	mov    %eax,%ebx
  80031b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80031e:	8b 45 10             	mov    0x10(%ebp),%eax
  800321:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800324:	b9 00 00 00 00       	mov    $0x0,%ecx
  800329:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80032c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80032f:	39 d9                	cmp    %ebx,%ecx
  800331:	72 13                	jb     800346 <cprintnum+0x47>
  800333:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800336:	76 0e                	jbe    800346 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800338:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033b:	0b 45 18             	or     0x18(%ebp),%eax
  80033e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800341:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800344:	eb 6a                	jmp    8003b0 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800346:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800349:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80034d:	83 ee 01             	sub    $0x1,%esi
  800350:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800354:	89 44 24 08          	mov    %eax,0x8(%esp)
  800358:	8b 44 24 08          	mov    0x8(%esp),%eax
  80035c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800360:	89 c3                	mov    %eax,%ebx
  800362:	89 d6                	mov    %edx,%esi
  800364:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800367:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80036a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80036e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800372:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80037b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037f:	e8 7c 14 00 00       	call   801800 <__udivdi3>
  800384:	89 d9                	mov    %ebx,%ecx
  800386:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80038a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80038e:	89 04 24             	mov    %eax,(%esp)
  800391:	89 54 24 04          	mov    %edx,0x4(%esp)
  800395:	89 f9                	mov    %edi,%ecx
  800397:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80039a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039d:	e8 5d ff ff ff       	call   8002ff <cprintnum>
  8003a2:	eb 16                	jmp    8003ba <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8003a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ab:	89 04 24             	mov    %eax,(%esp)
  8003ae:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b0:	83 ee 01             	sub    $0x1,%esi
  8003b3:	85 f6                	test   %esi,%esi
  8003b5:	7f ed                	jg     8003a4 <cprintnum+0xa5>
  8003b7:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  8003ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003be:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d3:	89 04 24             	mov    %eax,(%esp)
  8003d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003dd:	e8 4e 15 00 00       	call   801930 <__umoddi3>
  8003e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e6:	0f be 80 c0 1a 80 00 	movsbl 0x801ac0(%eax),%eax
  8003ed:	0b 45 dc             	or     -0x24(%ebp),%eax
  8003f0:	89 04 24             	mov    %eax,(%esp)
  8003f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f6:	ff d0                	call   *%eax
}
  8003f8:	83 c4 3c             	add    $0x3c,%esp
  8003fb:	5b                   	pop    %ebx
  8003fc:	5e                   	pop    %esi
  8003fd:	5f                   	pop    %edi
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800403:	83 fa 01             	cmp    $0x1,%edx
  800406:	7e 0e                	jle    800416 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800408:	8b 10                	mov    (%eax),%edx
  80040a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80040d:	89 08                	mov    %ecx,(%eax)
  80040f:	8b 02                	mov    (%edx),%eax
  800411:	8b 52 04             	mov    0x4(%edx),%edx
  800414:	eb 22                	jmp    800438 <getuint+0x38>
	else if (lflag)
  800416:	85 d2                	test   %edx,%edx
  800418:	74 10                	je     80042a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80041a:	8b 10                	mov    (%eax),%edx
  80041c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041f:	89 08                	mov    %ecx,(%eax)
  800421:	8b 02                	mov    (%edx),%eax
  800423:	ba 00 00 00 00       	mov    $0x0,%edx
  800428:	eb 0e                	jmp    800438 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80042a:	8b 10                	mov    (%eax),%edx
  80042c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042f:	89 08                	mov    %ecx,(%eax)
  800431:	8b 02                	mov    (%edx),%eax
  800433:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800440:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800444:	8b 10                	mov    (%eax),%edx
  800446:	3b 50 04             	cmp    0x4(%eax),%edx
  800449:	73 0a                	jae    800455 <sprintputch+0x1b>
		*b->buf++ = ch;
  80044b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 45 08             	mov    0x8(%ebp),%eax
  800453:	88 02                	mov    %al,(%edx)
}
  800455:	5d                   	pop    %ebp
  800456:	c3                   	ret    

00800457 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80045d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800460:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800464:	8b 45 10             	mov    0x10(%ebp),%eax
  800467:	89 44 24 08          	mov    %eax,0x8(%esp)
  80046b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800472:	8b 45 08             	mov    0x8(%ebp),%eax
  800475:	89 04 24             	mov    %eax,(%esp)
  800478:	e8 02 00 00 00       	call   80047f <vprintfmt>
	va_end(ap);
}
  80047d:	c9                   	leave  
  80047e:	c3                   	ret    

0080047f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	57                   	push   %edi
  800483:	56                   	push   %esi
  800484:	53                   	push   %ebx
  800485:	83 ec 3c             	sub    $0x3c,%esp
  800488:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80048b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80048e:	eb 14                	jmp    8004a4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800490:	85 c0                	test   %eax,%eax
  800492:	0f 84 b3 03 00 00    	je     80084b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800498:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a2:	89 f3                	mov    %esi,%ebx
  8004a4:	8d 73 01             	lea    0x1(%ebx),%esi
  8004a7:	0f b6 03             	movzbl (%ebx),%eax
  8004aa:	83 f8 25             	cmp    $0x25,%eax
  8004ad:	75 e1                	jne    800490 <vprintfmt+0x11>
  8004af:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004b3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004ba:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004c1:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cd:	eb 1d                	jmp    8004ec <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004d5:	eb 15                	jmp    8004ec <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d9:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004dd:	eb 0d                	jmp    8004ec <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004e5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004ef:	0f b6 0e             	movzbl (%esi),%ecx
  8004f2:	0f b6 c1             	movzbl %cl,%eax
  8004f5:	83 e9 23             	sub    $0x23,%ecx
  8004f8:	80 f9 55             	cmp    $0x55,%cl
  8004fb:	0f 87 2a 03 00 00    	ja     80082b <vprintfmt+0x3ac>
  800501:	0f b6 c9             	movzbl %cl,%ecx
  800504:	ff 24 8d 80 1b 80 00 	jmp    *0x801b80(,%ecx,4)
  80050b:	89 de                	mov    %ebx,%esi
  80050d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800512:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800515:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800519:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80051c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80051f:	83 fb 09             	cmp    $0x9,%ebx
  800522:	77 36                	ja     80055a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800524:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800527:	eb e9                	jmp    800512 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8d 48 04             	lea    0x4(%eax),%ecx
  80052f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800539:	eb 22                	jmp    80055d <vprintfmt+0xde>
  80053b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	b8 00 00 00 00       	mov    $0x0,%eax
  800545:	0f 49 c1             	cmovns %ecx,%eax
  800548:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	89 de                	mov    %ebx,%esi
  80054d:	eb 9d                	jmp    8004ec <vprintfmt+0x6d>
  80054f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800551:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800558:	eb 92                	jmp    8004ec <vprintfmt+0x6d>
  80055a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80055d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800561:	79 89                	jns    8004ec <vprintfmt+0x6d>
  800563:	e9 77 ff ff ff       	jmp    8004df <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800568:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056d:	e9 7a ff ff ff       	jmp    8004ec <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 04 24             	mov    %eax,(%esp)
  800584:	ff 55 08             	call   *0x8(%ebp)
			break;
  800587:	e9 18 ff ff ff       	jmp    8004a4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 00                	mov    (%eax),%eax
  800597:	99                   	cltd   
  800598:	31 d0                	xor    %edx,%eax
  80059a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059c:	83 f8 09             	cmp    $0x9,%eax
  80059f:	7f 0b                	jg     8005ac <vprintfmt+0x12d>
  8005a1:	8b 14 85 40 1e 80 00 	mov    0x801e40(,%eax,4),%edx
  8005a8:	85 d2                	test   %edx,%edx
  8005aa:	75 20                	jne    8005cc <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8005ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b0:	c7 44 24 08 d8 1a 80 	movl   $0x801ad8,0x8(%esp)
  8005b7:	00 
  8005b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bf:	89 04 24             	mov    %eax,(%esp)
  8005c2:	e8 90 fe ff ff       	call   800457 <printfmt>
  8005c7:	e9 d8 fe ff ff       	jmp    8004a4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005d0:	c7 44 24 08 e1 1a 80 	movl   $0x801ae1,0x8(%esp)
  8005d7:	00 
  8005d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	e8 70 fe ff ff       	call   800457 <printfmt>
  8005e7:	e9 b8 fe ff ff       	jmp    8004a4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800600:	85 f6                	test   %esi,%esi
  800602:	b8 d1 1a 80 00       	mov    $0x801ad1,%eax
  800607:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80060a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80060e:	0f 84 97 00 00 00    	je     8006ab <vprintfmt+0x22c>
  800614:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800618:	0f 8e 9b 00 00 00    	jle    8006b9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800622:	89 34 24             	mov    %esi,(%esp)
  800625:	e8 ce 06 00 00       	call   800cf8 <strnlen>
  80062a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80062d:	29 c2                	sub    %eax,%edx
  80062f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800632:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800636:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800639:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80063c:	8b 75 08             	mov    0x8(%ebp),%esi
  80063f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800642:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800644:	eb 0f                	jmp    800655 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800646:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80064d:	89 04 24             	mov    %eax,(%esp)
  800650:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800652:	83 eb 01             	sub    $0x1,%ebx
  800655:	85 db                	test   %ebx,%ebx
  800657:	7f ed                	jg     800646 <vprintfmt+0x1c7>
  800659:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80065c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80065f:	85 d2                	test   %edx,%edx
  800661:	b8 00 00 00 00       	mov    $0x0,%eax
  800666:	0f 49 c2             	cmovns %edx,%eax
  800669:	29 c2                	sub    %eax,%edx
  80066b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80066e:	89 d7                	mov    %edx,%edi
  800670:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800673:	eb 50                	jmp    8006c5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800675:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800679:	74 1e                	je     800699 <vprintfmt+0x21a>
  80067b:	0f be d2             	movsbl %dl,%edx
  80067e:	83 ea 20             	sub    $0x20,%edx
  800681:	83 fa 5e             	cmp    $0x5e,%edx
  800684:	76 13                	jbe    800699 <vprintfmt+0x21a>
					putch('?', putdat);
  800686:	8b 45 0c             	mov    0xc(%ebp),%eax
  800689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800694:	ff 55 08             	call   *0x8(%ebp)
  800697:	eb 0d                	jmp    8006a6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800699:	8b 55 0c             	mov    0xc(%ebp),%edx
  80069c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a0:	89 04 24             	mov    %eax,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a6:	83 ef 01             	sub    $0x1,%edi
  8006a9:	eb 1a                	jmp    8006c5 <vprintfmt+0x246>
  8006ab:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006ae:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006b1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006b4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006b7:	eb 0c                	jmp    8006c5 <vprintfmt+0x246>
  8006b9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006bc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006bf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006c5:	83 c6 01             	add    $0x1,%esi
  8006c8:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8006cc:	0f be c2             	movsbl %dl,%eax
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 27                	je     8006fa <vprintfmt+0x27b>
  8006d3:	85 db                	test   %ebx,%ebx
  8006d5:	78 9e                	js     800675 <vprintfmt+0x1f6>
  8006d7:	83 eb 01             	sub    $0x1,%ebx
  8006da:	79 99                	jns    800675 <vprintfmt+0x1f6>
  8006dc:	89 f8                	mov    %edi,%eax
  8006de:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e4:	89 c3                	mov    %eax,%ebx
  8006e6:	eb 1a                	jmp    800702 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ec:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006f3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f5:	83 eb 01             	sub    $0x1,%ebx
  8006f8:	eb 08                	jmp    800702 <vprintfmt+0x283>
  8006fa:	89 fb                	mov    %edi,%ebx
  8006fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800702:	85 db                	test   %ebx,%ebx
  800704:	7f e2                	jg     8006e8 <vprintfmt+0x269>
  800706:	89 75 08             	mov    %esi,0x8(%ebp)
  800709:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80070c:	e9 93 fd ff ff       	jmp    8004a4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800711:	83 fa 01             	cmp    $0x1,%edx
  800714:	7e 16                	jle    80072c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 50 08             	lea    0x8(%eax),%edx
  80071c:	89 55 14             	mov    %edx,0x14(%ebp)
  80071f:	8b 50 04             	mov    0x4(%eax),%edx
  800722:	8b 00                	mov    (%eax),%eax
  800724:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800727:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80072a:	eb 32                	jmp    80075e <vprintfmt+0x2df>
	else if (lflag)
  80072c:	85 d2                	test   %edx,%edx
  80072e:	74 18                	je     800748 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8d 50 04             	lea    0x4(%eax),%edx
  800736:	89 55 14             	mov    %edx,0x14(%ebp)
  800739:	8b 30                	mov    (%eax),%esi
  80073b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80073e:	89 f0                	mov    %esi,%eax
  800740:	c1 f8 1f             	sar    $0x1f,%eax
  800743:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800746:	eb 16                	jmp    80075e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8d 50 04             	lea    0x4(%eax),%edx
  80074e:	89 55 14             	mov    %edx,0x14(%ebp)
  800751:	8b 30                	mov    (%eax),%esi
  800753:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800756:	89 f0                	mov    %esi,%eax
  800758:	c1 f8 1f             	sar    $0x1f,%eax
  80075b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800761:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800764:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800769:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80076d:	0f 89 80 00 00 00    	jns    8007f3 <vprintfmt+0x374>
				putch('-', putdat);
  800773:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800777:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80077e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800781:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800784:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800787:	f7 d8                	neg    %eax
  800789:	83 d2 00             	adc    $0x0,%edx
  80078c:	f7 da                	neg    %edx
			}
			base = 10;
  80078e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800793:	eb 5e                	jmp    8007f3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800795:	8d 45 14             	lea    0x14(%ebp),%eax
  800798:	e8 63 fc ff ff       	call   800400 <getuint>
			base = 10;
  80079d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007a2:	eb 4f                	jmp    8007f3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a7:	e8 54 fc ff ff       	call   800400 <getuint>
			base = 8 ;
  8007ac:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  8007b1:	eb 40                	jmp    8007f3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8007b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007be:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007cc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 50 04             	lea    0x4(%eax),%edx
  8007d5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007d8:	8b 00                	mov    (%eax),%eax
  8007da:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007df:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007e4:	eb 0d                	jmp    8007f3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	e8 12 fc ff ff       	call   800400 <getuint>
			base = 16;
  8007ee:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007f7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007fb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800802:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800806:	89 04 24             	mov    %eax,(%esp)
  800809:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080d:	89 fa                	mov    %edi,%edx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	e8 f9 f9 ff ff       	call   800210 <printnum>
			break;
  800817:	e9 88 fc ff ff       	jmp    8004a4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800820:	89 04 24             	mov    %eax,(%esp)
  800823:	ff 55 08             	call   *0x8(%ebp)
			break;
  800826:	e9 79 fc ff ff       	jmp    8004a4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80082f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800836:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800839:	89 f3                	mov    %esi,%ebx
  80083b:	eb 03                	jmp    800840 <vprintfmt+0x3c1>
  80083d:	83 eb 01             	sub    $0x1,%ebx
  800840:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800844:	75 f7                	jne    80083d <vprintfmt+0x3be>
  800846:	e9 59 fc ff ff       	jmp    8004a4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80084b:	83 c4 3c             	add    $0x3c,%esp
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5f                   	pop    %edi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	57                   	push   %edi
  800857:	56                   	push   %esi
  800858:	53                   	push   %ebx
  800859:	83 ec 3c             	sub    $0x3c,%esp
  80085c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 50 04             	lea    0x4(%eax),%edx
  800865:	89 55 14             	mov    %edx,0x14(%ebp)
  800868:	8b 00                	mov    (%eax),%eax
  80086a:	c1 e0 08             	shl    $0x8,%eax
  80086d:	0f b7 c0             	movzwl %ax,%eax
  800870:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800873:	83 c8 25             	or     $0x25,%eax
  800876:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800879:	eb 1a                	jmp    800895 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80087b:	85 c0                	test   %eax,%eax
  80087d:	0f 84 a9 03 00 00    	je     800c2c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800883:	8b 75 0c             	mov    0xc(%ebp),%esi
  800886:	89 74 24 04          	mov    %esi,0x4(%esp)
  80088a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  80088d:	89 04 24             	mov    %eax,(%esp)
  800890:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800893:	89 fb                	mov    %edi,%ebx
  800895:	8d 7b 01             	lea    0x1(%ebx),%edi
  800898:	0f b6 03             	movzbl (%ebx),%eax
  80089b:	83 f8 25             	cmp    $0x25,%eax
  80089e:	75 db                	jne    80087b <cvprintfmt+0x28>
  8008a0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8008a4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008ab:	be ff ff ff ff       	mov    $0xffffffff,%esi
  8008b0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8008b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008bc:	eb 18                	jmp    8008d6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008c0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8008c4:	eb 10                	jmp    8008d6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c6:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8008cc:	eb 08                	jmp    8008d6 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8008ce:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8008d1:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d6:	8d 5f 01             	lea    0x1(%edi),%ebx
  8008d9:	0f b6 0f             	movzbl (%edi),%ecx
  8008dc:	0f b6 c1             	movzbl %cl,%eax
  8008df:	83 e9 23             	sub    $0x23,%ecx
  8008e2:	80 f9 55             	cmp    $0x55,%cl
  8008e5:	0f 87 1f 03 00 00    	ja     800c0a <cvprintfmt+0x3b7>
  8008eb:	0f b6 c9             	movzbl %cl,%ecx
  8008ee:	ff 24 8d d8 1c 80 00 	jmp    *0x801cd8(,%ecx,4)
  8008f5:	89 df                	mov    %ebx,%edi
  8008f7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008fc:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  8008ff:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800903:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800906:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800909:	83 f9 09             	cmp    $0x9,%ecx
  80090c:	77 33                	ja     800941 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80090e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800911:	eb e9                	jmp    8008fc <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800913:	8b 45 14             	mov    0x14(%ebp),%eax
  800916:	8d 48 04             	lea    0x4(%eax),%ecx
  800919:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80091c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800920:	eb 1f                	jmp    800941 <cvprintfmt+0xee>
  800922:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800925:	85 ff                	test   %edi,%edi
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
  80092c:	0f 49 c7             	cmovns %edi,%eax
  80092f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800932:	89 df                	mov    %ebx,%edi
  800934:	eb a0                	jmp    8008d6 <cvprintfmt+0x83>
  800936:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800938:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80093f:	eb 95                	jmp    8008d6 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800941:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800945:	79 8f                	jns    8008d6 <cvprintfmt+0x83>
  800947:	eb 85                	jmp    8008ce <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800949:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80094e:	66 90                	xchg   %ax,%ax
  800950:	eb 84                	jmp    8008d6 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800952:	8b 45 14             	mov    0x14(%ebp),%eax
  800955:	8d 50 04             	lea    0x4(%eax),%edx
  800958:	89 55 14             	mov    %edx,0x14(%ebp)
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800962:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800965:	0b 10                	or     (%eax),%edx
  800967:	89 14 24             	mov    %edx,(%esp)
  80096a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80096d:	e9 23 ff ff ff       	jmp    800895 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8d 50 04             	lea    0x4(%eax),%edx
  800978:	89 55 14             	mov    %edx,0x14(%ebp)
  80097b:	8b 00                	mov    (%eax),%eax
  80097d:	99                   	cltd   
  80097e:	31 d0                	xor    %edx,%eax
  800980:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800982:	83 f8 09             	cmp    $0x9,%eax
  800985:	7f 0b                	jg     800992 <cvprintfmt+0x13f>
  800987:	8b 14 85 40 1e 80 00 	mov    0x801e40(,%eax,4),%edx
  80098e:	85 d2                	test   %edx,%edx
  800990:	75 23                	jne    8009b5 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800992:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800996:	c7 44 24 08 d8 1a 80 	movl   $0x801ad8,0x8(%esp)
  80099d:	00 
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	89 04 24             	mov    %eax,(%esp)
  8009ab:	e8 a7 fa ff ff       	call   800457 <printfmt>
  8009b0:	e9 e0 fe ff ff       	jmp    800895 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  8009b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009b9:	c7 44 24 08 e1 1a 80 	movl   $0x801ae1,0x8(%esp)
  8009c0:	00 
  8009c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	89 04 24             	mov    %eax,(%esp)
  8009ce:	e8 84 fa ff ff       	call   800457 <printfmt>
  8009d3:	e9 bd fe ff ff       	jmp    800895 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009db:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  8009de:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e1:	8d 48 04             	lea    0x4(%eax),%ecx
  8009e4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8009e7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009e9:	85 ff                	test   %edi,%edi
  8009eb:	b8 d1 1a 80 00       	mov    $0x801ad1,%eax
  8009f0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009f3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009f7:	74 61                	je     800a5a <cvprintfmt+0x207>
  8009f9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8009fd:	7e 5b                	jle    800a5a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a03:	89 3c 24             	mov    %edi,(%esp)
  800a06:	e8 ed 02 00 00       	call   800cf8 <strnlen>
  800a0b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a0e:	29 c2                	sub    %eax,%edx
  800a10:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800a13:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a17:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a1a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a1d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800a20:	8b 75 08             	mov    0x8(%ebp),%esi
  800a23:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a26:	89 d3                	mov    %edx,%ebx
  800a28:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a2a:	eb 0f                	jmp    800a3b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a33:	89 3c 24             	mov    %edi,(%esp)
  800a36:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a38:	83 eb 01             	sub    $0x1,%ebx
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	7f ed                	jg     800a2c <cvprintfmt+0x1d9>
  800a3f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a42:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a48:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a4b:	85 d2                	test   %edx,%edx
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	0f 49 c2             	cmovns %edx,%eax
  800a55:	29 c2                	sub    %eax,%edx
  800a57:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800a5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a5d:	83 c8 3f             	or     $0x3f,%eax
  800a60:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a63:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a66:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800a69:	eb 36                	jmp    800aa1 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a6b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a6f:	74 1d                	je     800a8e <cvprintfmt+0x23b>
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 20             	sub    $0x20,%edx
  800a77:	83 fa 5e             	cmp    $0x5e,%edx
  800a7a:	76 12                	jbe    800a8e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a83:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a86:	89 04 24             	mov    %eax,(%esp)
  800a89:	ff 55 08             	call   *0x8(%ebp)
  800a8c:	eb 10                	jmp    800a9e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a91:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a95:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800a98:	89 04 24             	mov    %eax,(%esp)
  800a9b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a9e:	83 eb 01             	sub    $0x1,%ebx
  800aa1:	83 c7 01             	add    $0x1,%edi
  800aa4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800aa8:	0f be c2             	movsbl %dl,%eax
  800aab:	85 c0                	test   %eax,%eax
  800aad:	74 27                	je     800ad6 <cvprintfmt+0x283>
  800aaf:	85 f6                	test   %esi,%esi
  800ab1:	78 b8                	js     800a6b <cvprintfmt+0x218>
  800ab3:	83 ee 01             	sub    $0x1,%esi
  800ab6:	79 b3                	jns    800a6b <cvprintfmt+0x218>
  800ab8:	89 d8                	mov    %ebx,%eax
  800aba:	8b 75 08             	mov    0x8(%ebp),%esi
  800abd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ac0:	89 c3                	mov    %eax,%ebx
  800ac2:	eb 18                	jmp    800adc <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800ac4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ac8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800acf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800ad1:	83 eb 01             	sub    $0x1,%ebx
  800ad4:	eb 06                	jmp    800adc <cvprintfmt+0x289>
  800ad6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800adc:	85 db                	test   %ebx,%ebx
  800ade:	7f e4                	jg     800ac4 <cvprintfmt+0x271>
  800ae0:	89 75 08             	mov    %esi,0x8(%ebp)
  800ae3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ae6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ae9:	e9 a7 fd ff ff       	jmp    800895 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aee:	83 fa 01             	cmp    $0x1,%edx
  800af1:	7e 10                	jle    800b03 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800af3:	8b 45 14             	mov    0x14(%ebp),%eax
  800af6:	8d 50 08             	lea    0x8(%eax),%edx
  800af9:	89 55 14             	mov    %edx,0x14(%ebp)
  800afc:	8b 30                	mov    (%eax),%esi
  800afe:	8b 78 04             	mov    0x4(%eax),%edi
  800b01:	eb 26                	jmp    800b29 <cvprintfmt+0x2d6>
	else if (lflag)
  800b03:	85 d2                	test   %edx,%edx
  800b05:	74 12                	je     800b19 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800b07:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0a:	8d 50 04             	lea    0x4(%eax),%edx
  800b0d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b10:	8b 30                	mov    (%eax),%esi
  800b12:	89 f7                	mov    %esi,%edi
  800b14:	c1 ff 1f             	sar    $0x1f,%edi
  800b17:	eb 10                	jmp    800b29 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800b19:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1c:	8d 50 04             	lea    0x4(%eax),%edx
  800b1f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b22:	8b 30                	mov    (%eax),%esi
  800b24:	89 f7                	mov    %esi,%edi
  800b26:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b29:	89 f0                	mov    %esi,%eax
  800b2b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b2d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b32:	85 ff                	test   %edi,%edi
  800b34:	0f 89 8e 00 00 00    	jns    800bc8 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b44:	83 c8 2d             	or     $0x2d,%eax
  800b47:	89 04 24             	mov    %eax,(%esp)
  800b4a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b4d:	89 f0                	mov    %esi,%eax
  800b4f:	89 fa                	mov    %edi,%edx
  800b51:	f7 d8                	neg    %eax
  800b53:	83 d2 00             	adc    $0x0,%edx
  800b56:	f7 da                	neg    %edx
			}
			base = 10;
  800b58:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b5d:	eb 69                	jmp    800bc8 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b5f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b62:	e8 99 f8 ff ff       	call   800400 <getuint>
			base = 10;
  800b67:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b6c:	eb 5a                	jmp    800bc8 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b6e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b71:	e8 8a f8 ff ff       	call   800400 <getuint>
			base = 8 ;
  800b76:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800b7b:	eb 4b                	jmp    800bc8 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b84:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800b87:	89 f0                	mov    %esi,%eax
  800b89:	83 c8 30             	or     $0x30,%eax
  800b8c:	89 04 24             	mov    %eax,(%esp)
  800b8f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b99:	89 f0                	mov    %esi,%eax
  800b9b:	83 c8 78             	or     $0x78,%eax
  800b9e:	89 04 24             	mov    %eax,(%esp)
  800ba1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ba4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba7:	8d 50 04             	lea    0x4(%eax),%edx
  800baa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800bad:	8b 00                	mov    (%eax),%eax
  800baf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bb4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bb9:	eb 0d                	jmp    800bc8 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bbb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bbe:	e8 3d f8 ff ff       	call   800400 <getuint>
			base = 16;
  800bc3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800bc8:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800bcc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800bd0:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800bd3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bd7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bdb:	89 04 24             	mov    %eax,(%esp)
  800bde:	89 54 24 04          	mov    %edx,0x4(%esp)
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800beb:	e8 0f f7 ff ff       	call   8002ff <cprintnum>
			break;
  800bf0:	e9 a0 fc ff ff       	jmp    800895 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800bf5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bfc:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800bff:	89 04 24             	mov    %eax,(%esp)
  800c02:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c05:	e9 8b fc ff ff       	jmp    800895 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c14:	89 04 24             	mov    %eax,(%esp)
  800c17:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c1a:	89 fb                	mov    %edi,%ebx
  800c1c:	eb 03                	jmp    800c21 <cvprintfmt+0x3ce>
  800c1e:	83 eb 01             	sub    $0x1,%ebx
  800c21:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c25:	75 f7                	jne    800c1e <cvprintfmt+0x3cb>
  800c27:	e9 69 fc ff ff       	jmp    800895 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800c2c:	83 c4 3c             	add    $0x3c,%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c3a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800c3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c41:	8b 45 10             	mov    0x10(%ebp),%eax
  800c44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	89 04 24             	mov    %eax,(%esp)
  800c55:	e8 f9 fb ff ff       	call   800853 <cvprintfmt>
	va_end(ap);
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 28             	sub    $0x28,%esp
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c68:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c6b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c6f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	74 30                	je     800cad <vsnprintf+0x51>
  800c7d:	85 d2                	test   %edx,%edx
  800c7f:	7e 2c                	jle    800cad <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c81:	8b 45 14             	mov    0x14(%ebp),%eax
  800c84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c88:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c96:	c7 04 24 3a 04 80 00 	movl   $0x80043a,(%esp)
  800c9d:	e8 dd f7 ff ff       	call   80047f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cab:	eb 05                	jmp    800cb2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	89 04 24             	mov    %eax,(%esp)
  800cd5:	e8 82 ff ff ff       	call   800c5c <vsnprintf>
	va_end(ap);

	return rc;
}
  800cda:	c9                   	leave  
  800cdb:	c3                   	ret    
  800cdc:	66 90                	xchg   %ax,%ax
  800cde:	66 90                	xchg   %ax,%ax

00800ce0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ceb:	eb 03                	jmp    800cf0 <strlen+0x10>
		n++;
  800ced:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cf4:	75 f7                	jne    800ced <strlen+0xd>
		n++;
	return n;
}
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	eb 03                	jmp    800d0b <strnlen+0x13>
		n++;
  800d08:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0b:	39 d0                	cmp    %edx,%eax
  800d0d:	74 06                	je     800d15 <strnlen+0x1d>
  800d0f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d13:	75 f3                	jne    800d08 <strnlen+0x10>
		n++;
	return n;
}
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	53                   	push   %ebx
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d21:	89 c2                	mov    %eax,%edx
  800d23:	83 c2 01             	add    $0x1,%edx
  800d26:	83 c1 01             	add    $0x1,%ecx
  800d29:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d2d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d30:	84 db                	test   %bl,%bl
  800d32:	75 ef                	jne    800d23 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d34:	5b                   	pop    %ebx
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 08             	sub    $0x8,%esp
  800d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d41:	89 1c 24             	mov    %ebx,(%esp)
  800d44:	e8 97 ff ff ff       	call   800ce0 <strlen>
	strcpy(dst + len, src);
  800d49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d50:	01 d8                	add    %ebx,%eax
  800d52:	89 04 24             	mov    %eax,(%esp)
  800d55:	e8 bd ff ff ff       	call   800d17 <strcpy>
	return dst;
}
  800d5a:	89 d8                	mov    %ebx,%eax
  800d5c:	83 c4 08             	add    $0x8,%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	8b 75 08             	mov    0x8(%ebp),%esi
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	89 f3                	mov    %esi,%ebx
  800d6f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d72:	89 f2                	mov    %esi,%edx
  800d74:	eb 0f                	jmp    800d85 <strncpy+0x23>
		*dst++ = *src;
  800d76:	83 c2 01             	add    $0x1,%edx
  800d79:	0f b6 01             	movzbl (%ecx),%eax
  800d7c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d7f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d82:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d85:	39 da                	cmp    %ebx,%edx
  800d87:	75 ed                	jne    800d76 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d89:	89 f0                	mov    %esi,%eax
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	8b 75 08             	mov    0x8(%ebp),%esi
  800d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d9d:	89 f0                	mov    %esi,%eax
  800d9f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800da3:	85 c9                	test   %ecx,%ecx
  800da5:	75 0b                	jne    800db2 <strlcpy+0x23>
  800da7:	eb 1d                	jmp    800dc6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800da9:	83 c0 01             	add    $0x1,%eax
  800dac:	83 c2 01             	add    $0x1,%edx
  800daf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800db2:	39 d8                	cmp    %ebx,%eax
  800db4:	74 0b                	je     800dc1 <strlcpy+0x32>
  800db6:	0f b6 0a             	movzbl (%edx),%ecx
  800db9:	84 c9                	test   %cl,%cl
  800dbb:	75 ec                	jne    800da9 <strlcpy+0x1a>
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	eb 02                	jmp    800dc3 <strlcpy+0x34>
  800dc1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800dc3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800dc6:	29 f0                	sub    %esi,%eax
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dd5:	eb 06                	jmp    800ddd <strcmp+0x11>
		p++, q++;
  800dd7:	83 c1 01             	add    $0x1,%ecx
  800dda:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ddd:	0f b6 01             	movzbl (%ecx),%eax
  800de0:	84 c0                	test   %al,%al
  800de2:	74 04                	je     800de8 <strcmp+0x1c>
  800de4:	3a 02                	cmp    (%edx),%al
  800de6:	74 ef                	je     800dd7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800de8:	0f b6 c0             	movzbl %al,%eax
  800deb:	0f b6 12             	movzbl (%edx),%edx
  800dee:	29 d0                	sub    %edx,%eax
}
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	53                   	push   %ebx
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e01:	eb 06                	jmp    800e09 <strncmp+0x17>
		n--, p++, q++;
  800e03:	83 c0 01             	add    $0x1,%eax
  800e06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e09:	39 d8                	cmp    %ebx,%eax
  800e0b:	74 15                	je     800e22 <strncmp+0x30>
  800e0d:	0f b6 08             	movzbl (%eax),%ecx
  800e10:	84 c9                	test   %cl,%cl
  800e12:	74 04                	je     800e18 <strncmp+0x26>
  800e14:	3a 0a                	cmp    (%edx),%cl
  800e16:	74 eb                	je     800e03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e18:	0f b6 00             	movzbl (%eax),%eax
  800e1b:	0f b6 12             	movzbl (%edx),%edx
  800e1e:	29 d0                	sub    %edx,%eax
  800e20:	eb 05                	jmp    800e27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e34:	eb 07                	jmp    800e3d <strchr+0x13>
		if (*s == c)
  800e36:	38 ca                	cmp    %cl,%dl
  800e38:	74 0f                	je     800e49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e3a:	83 c0 01             	add    $0x1,%eax
  800e3d:	0f b6 10             	movzbl (%eax),%edx
  800e40:	84 d2                	test   %dl,%dl
  800e42:	75 f2                	jne    800e36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e55:	eb 07                	jmp    800e5e <strfind+0x13>
		if (*s == c)
  800e57:	38 ca                	cmp    %cl,%dl
  800e59:	74 0a                	je     800e65 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e5b:	83 c0 01             	add    $0x1,%eax
  800e5e:	0f b6 10             	movzbl (%eax),%edx
  800e61:	84 d2                	test   %dl,%dl
  800e63:	75 f2                	jne    800e57 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e73:	85 c9                	test   %ecx,%ecx
  800e75:	74 36                	je     800ead <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e7d:	75 28                	jne    800ea7 <memset+0x40>
  800e7f:	f6 c1 03             	test   $0x3,%cl
  800e82:	75 23                	jne    800ea7 <memset+0x40>
		c &= 0xFF;
  800e84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e88:	89 d3                	mov    %edx,%ebx
  800e8a:	c1 e3 08             	shl    $0x8,%ebx
  800e8d:	89 d6                	mov    %edx,%esi
  800e8f:	c1 e6 18             	shl    $0x18,%esi
  800e92:	89 d0                	mov    %edx,%eax
  800e94:	c1 e0 10             	shl    $0x10,%eax
  800e97:	09 f0                	or     %esi,%eax
  800e99:	09 c2                	or     %eax,%edx
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e9f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ea2:	fc                   	cld    
  800ea3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ea5:	eb 06                	jmp    800ead <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaa:	fc                   	cld    
  800eab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ead:	89 f8                	mov    %edi,%eax
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ebf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ec2:	39 c6                	cmp    %eax,%esi
  800ec4:	73 35                	jae    800efb <memmove+0x47>
  800ec6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ec9:	39 d0                	cmp    %edx,%eax
  800ecb:	73 2e                	jae    800efb <memmove+0x47>
		s += n;
		d += n;
  800ecd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ed0:	89 d6                	mov    %edx,%esi
  800ed2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eda:	75 13                	jne    800eef <memmove+0x3b>
  800edc:	f6 c1 03             	test   $0x3,%cl
  800edf:	75 0e                	jne    800eef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ee1:	83 ef 04             	sub    $0x4,%edi
  800ee4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ee7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eea:	fd                   	std    
  800eeb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eed:	eb 09                	jmp    800ef8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eef:	83 ef 01             	sub    $0x1,%edi
  800ef2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ef5:	fd                   	std    
  800ef6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef8:	fc                   	cld    
  800ef9:	eb 1d                	jmp    800f18 <memmove+0x64>
  800efb:	89 f2                	mov    %esi,%edx
  800efd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eff:	f6 c2 03             	test   $0x3,%dl
  800f02:	75 0f                	jne    800f13 <memmove+0x5f>
  800f04:	f6 c1 03             	test   $0x3,%cl
  800f07:	75 0a                	jne    800f13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f09:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f0c:	89 c7                	mov    %eax,%edi
  800f0e:	fc                   	cld    
  800f0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f11:	eb 05                	jmp    800f18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f13:	89 c7                	mov    %eax,%edi
  800f15:	fc                   	cld    
  800f16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f22:	8b 45 10             	mov    0x10(%ebp),%eax
  800f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	e8 79 ff ff ff       	call   800eb4 <memmove>
}
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	8b 55 08             	mov    0x8(%ebp),%edx
  800f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f48:	89 d6                	mov    %edx,%esi
  800f4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f4d:	eb 1a                	jmp    800f69 <memcmp+0x2c>
		if (*s1 != *s2)
  800f4f:	0f b6 02             	movzbl (%edx),%eax
  800f52:	0f b6 19             	movzbl (%ecx),%ebx
  800f55:	38 d8                	cmp    %bl,%al
  800f57:	74 0a                	je     800f63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f59:	0f b6 c0             	movzbl %al,%eax
  800f5c:	0f b6 db             	movzbl %bl,%ebx
  800f5f:	29 d8                	sub    %ebx,%eax
  800f61:	eb 0f                	jmp    800f72 <memcmp+0x35>
		s1++, s2++;
  800f63:	83 c2 01             	add    $0x1,%edx
  800f66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f69:	39 f2                	cmp    %esi,%edx
  800f6b:	75 e2                	jne    800f4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f7f:	89 c2                	mov    %eax,%edx
  800f81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f84:	eb 07                	jmp    800f8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f86:	38 08                	cmp    %cl,(%eax)
  800f88:	74 07                	je     800f91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f8a:	83 c0 01             	add    $0x1,%eax
  800f8d:	39 d0                	cmp    %edx,%eax
  800f8f:	72 f5                	jb     800f86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f9f:	eb 03                	jmp    800fa4 <strtol+0x11>
		s++;
  800fa1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fa4:	0f b6 0a             	movzbl (%edx),%ecx
  800fa7:	80 f9 09             	cmp    $0x9,%cl
  800faa:	74 f5                	je     800fa1 <strtol+0xe>
  800fac:	80 f9 20             	cmp    $0x20,%cl
  800faf:	74 f0                	je     800fa1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fb1:	80 f9 2b             	cmp    $0x2b,%cl
  800fb4:	75 0a                	jne    800fc0 <strtol+0x2d>
		s++;
  800fb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800fbe:	eb 11                	jmp    800fd1 <strtol+0x3e>
  800fc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fc5:	80 f9 2d             	cmp    $0x2d,%cl
  800fc8:	75 07                	jne    800fd1 <strtol+0x3e>
		s++, neg = 1;
  800fca:	8d 52 01             	lea    0x1(%edx),%edx
  800fcd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fd1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800fd6:	75 15                	jne    800fed <strtol+0x5a>
  800fd8:	80 3a 30             	cmpb   $0x30,(%edx)
  800fdb:	75 10                	jne    800fed <strtol+0x5a>
  800fdd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fe1:	75 0a                	jne    800fed <strtol+0x5a>
		s += 2, base = 16;
  800fe3:	83 c2 02             	add    $0x2,%edx
  800fe6:	b8 10 00 00 00       	mov    $0x10,%eax
  800feb:	eb 10                	jmp    800ffd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800fed:	85 c0                	test   %eax,%eax
  800fef:	75 0c                	jne    800ffd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ff1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ff3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ff6:	75 05                	jne    800ffd <strtol+0x6a>
		s++, base = 8;
  800ff8:	83 c2 01             	add    $0x1,%edx
  800ffb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800ffd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801002:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801005:	0f b6 0a             	movzbl (%edx),%ecx
  801008:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80100b:	89 f0                	mov    %esi,%eax
  80100d:	3c 09                	cmp    $0x9,%al
  80100f:	77 08                	ja     801019 <strtol+0x86>
			dig = *s - '0';
  801011:	0f be c9             	movsbl %cl,%ecx
  801014:	83 e9 30             	sub    $0x30,%ecx
  801017:	eb 20                	jmp    801039 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801019:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80101c:	89 f0                	mov    %esi,%eax
  80101e:	3c 19                	cmp    $0x19,%al
  801020:	77 08                	ja     80102a <strtol+0x97>
			dig = *s - 'a' + 10;
  801022:	0f be c9             	movsbl %cl,%ecx
  801025:	83 e9 57             	sub    $0x57,%ecx
  801028:	eb 0f                	jmp    801039 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80102a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	3c 19                	cmp    $0x19,%al
  801031:	77 16                	ja     801049 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801033:	0f be c9             	movsbl %cl,%ecx
  801036:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801039:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80103c:	7d 0f                	jge    80104d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80103e:	83 c2 01             	add    $0x1,%edx
  801041:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801045:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801047:	eb bc                	jmp    801005 <strtol+0x72>
  801049:	89 d8                	mov    %ebx,%eax
  80104b:	eb 02                	jmp    80104f <strtol+0xbc>
  80104d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80104f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801053:	74 05                	je     80105a <strtol+0xc7>
		*endptr = (char *) s;
  801055:	8b 75 0c             	mov    0xc(%ebp),%esi
  801058:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80105a:	f7 d8                	neg    %eax
  80105c:	85 ff                	test   %edi,%edi
  80105e:	0f 44 c3             	cmove  %ebx,%eax
}
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106c:	b8 00 00 00 00       	mov    $0x0,%eax
  801071:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801074:	8b 55 08             	mov    0x8(%ebp),%edx
  801077:	89 c3                	mov    %eax,%ebx
  801079:	89 c7                	mov    %eax,%edi
  80107b:	89 c6                	mov    %eax,%esi
  80107d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5f                   	pop    %edi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sys_cgetc>:

int
sys_cgetc(void)
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
  80108f:	b8 01 00 00 00       	mov    $0x1,%eax
  801094:	89 d1                	mov    %edx,%ecx
  801096:	89 d3                	mov    %edx,%ebx
  801098:	89 d7                	mov    %edx,%edi
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  8010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b1:	b8 03 00 00 00       	mov    $0x3,%eax
  8010b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b9:	89 cb                	mov    %ecx,%ebx
  8010bb:	89 cf                	mov    %ecx,%edi
  8010bd:	89 ce                	mov    %ecx,%esi
  8010bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	7e 28                	jle    8010ed <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 08 68 1e 80 	movl   $0x801e68,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e0:	00 
  8010e1:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  8010e8:	e8 3d 06 00 00       	call   80172a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010ed:	83 c4 2c             	add    $0x2c,%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801100:	b8 02 00 00 00       	mov    $0x2,%eax
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 d3                	mov    %edx,%ebx
  801109:	89 d7                	mov    %edx,%edi
  80110b:	89 d6                	mov    %edx,%esi
  80110d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_yield>:

void
sys_yield(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111a:	ba 00 00 00 00       	mov    $0x0,%edx
  80111f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801124:	89 d1                	mov    %edx,%ecx
  801126:	89 d3                	mov    %edx,%ebx
  801128:	89 d7                	mov    %edx,%edi
  80112a:	89 d6                	mov    %edx,%esi
  80112c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113c:	be 00 00 00 00       	mov    $0x0,%esi
  801141:	b8 04 00 00 00       	mov    $0x4,%eax
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114f:	89 f7                	mov    %esi,%edi
  801151:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 28                	jle    80117f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801157:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801162:	00 
  801163:	c7 44 24 08 68 1e 80 	movl   $0x801e68,0x8(%esp)
  80116a:	00 
  80116b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  80117a:	e8 ab 05 00 00       	call   80172a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80117f:	83 c4 2c             	add    $0x2c,%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801190:	b8 05 00 00 00       	mov    $0x5,%eax
  801195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801198:	8b 55 08             	mov    0x8(%ebp),%edx
  80119b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011a1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	7e 28                	jle    8011d2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011b5:	00 
  8011b6:	c7 44 24 08 68 1e 80 	movl   $0x801e68,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  8011cd:	e8 58 05 00 00       	call   80172a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011d2:	83 c4 2c             	add    $0x2c,%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	89 df                	mov    %ebx,%edi
  8011f5:	89 de                	mov    %ebx,%esi
  8011f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	7e 28                	jle    801225 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801201:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801208:	00 
  801209:	c7 44 24 08 68 1e 80 	movl   $0x801e68,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  801220:	e8 05 05 00 00       	call   80172a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801225:	83 c4 2c             	add    $0x2c,%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123b:	b8 08 00 00 00       	mov    $0x8,%eax
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
  801246:	89 df                	mov    %ebx,%edi
  801248:	89 de                	mov    %ebx,%esi
  80124a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	7e 28                	jle    801278 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801250:	89 44 24 10          	mov    %eax,0x10(%esp)
  801254:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80125b:	00 
  80125c:	c7 44 24 08 68 1e 80 	movl   $0x801e68,0x8(%esp)
  801263:	00 
  801264:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126b:	00 
  80126c:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  801273:	e8 b2 04 00 00       	call   80172a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801278:	83 c4 2c             	add    $0x2c,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801289:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128e:	b8 09 00 00 00       	mov    $0x9,%eax
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	8b 55 08             	mov    0x8(%ebp),%edx
  801299:	89 df                	mov    %ebx,%edi
  80129b:	89 de                	mov    %ebx,%esi
  80129d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	7e 28                	jle    8012cb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012ae:	00 
  8012af:	c7 44 24 08 68 1e 80 	movl   $0x801e68,0x8(%esp)
  8012b6:	00 
  8012b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012be:	00 
  8012bf:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  8012c6:	e8 5f 04 00 00       	call   80172a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012cb:	83 c4 2c             	add    $0x2c,%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5f                   	pop    %edi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	57                   	push   %edi
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d9:	be 00 00 00 00       	mov    $0x0,%esi
  8012de:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ec:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012ef:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012f1:	5b                   	pop    %ebx
  8012f2:	5e                   	pop    %esi
  8012f3:	5f                   	pop    %edi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801304:	b8 0c 00 00 00       	mov    $0xc,%eax
  801309:	8b 55 08             	mov    0x8(%ebp),%edx
  80130c:	89 cb                	mov    %ecx,%ebx
  80130e:	89 cf                	mov    %ecx,%edi
  801310:	89 ce                	mov    %ecx,%esi
  801312:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801314:	85 c0                	test   %eax,%eax
  801316:	7e 28                	jle    801340 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801318:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801323:	00 
  801324:	c7 44 24 08 68 1e 80 	movl   $0x801e68,0x8(%esp)
  80132b:	00 
  80132c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801333:	00 
  801334:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  80133b:	e8 ea 03 00 00       	call   80172a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801340:	83 c4 2c             	add    $0x2c,%esp
  801343:	5b                   	pop    %ebx
  801344:	5e                   	pop    %esi
  801345:	5f                   	pop    %edi
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    

00801348 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	57                   	push   %edi
  80134c:	56                   	push   %esi
  80134d:	53                   	push   %ebx
  80134e:	83 ec 2c             	sub    $0x2c,%esp
	void *addr = (void *) utf->utf_fault_va;
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
  801354:	8b 30                	mov    (%eax),%esi
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf(" pgfault : fault va is  %08x\n", ( uint32_t ) addr ) ; 
	//cprintf(" pgfault : fault eip is  %08x\n", ( uint32_t ) utf->utf_eip ) ; 
	pde_t * pde_ptr = ( pde_t * ) ( UVPT + ( PDX(UVPT) << 12 ) + ( PDX(addr) << 2 ) ) ; 
  801356:	89 f0                	mov    %esi,%eax
  801358:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( UVPT + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  80135b:	89 c1                	mov    %eax,%ecx
  80135d:	c1 e1 0c             	shl    $0xc,%ecx
  801360:	89 f2                	mov    %esi,%edx
  801362:	c1 ea 0a             	shr    $0xa,%edx
  801365:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  80136b:	8d bc 11 00 00 40 ef 	lea    -0x10c00000(%ecx,%edx,1),%edi
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  801372:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  801379:	01 
  80137a:	75 1c                	jne    801398 <pgfault+0x50>
		panic(" in inc/fork.c <pgfault> : Page Directory Entry doesn't exsist!\n");
  80137c:	c7 44 24 08 94 1e 80 	movl   $0x801e94,0x8(%esp)
  801383:	00 
  801384:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80138b:	00 
  80138c:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  801393:	e8 92 03 00 00       	call   80172a <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  801398:	8b 07                	mov    (%edi),%eax
  80139a:	a8 01                	test   $0x1,%al
  80139c:	75 1c                	jne    8013ba <pgfault+0x72>
		panic(" in inc/fork.c <pgfault> : Page Table Entry doesn't exsist!\n");
  80139e:	c7 44 24 08 d8 1e 80 	movl   $0x801ed8,0x8(%esp)
  8013a5:	00 
  8013a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013ad:	00 
  8013ae:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  8013b5:	e8 70 03 00 00       	call   80172a <_panic>
	if (!( ( ( *pte_ptr ) & PTE_W ) || ( ( *pte_ptr ) & PTE_COW ) ) )
  8013ba:	a9 02 08 00 00       	test   $0x802,%eax
  8013bf:	75 1c                	jne    8013dd <pgfault+0x95>
		panic(" in inc/fork.c <pgfault> : Invalid page!\n");
  8013c1:	c7 44 24 08 18 1f 80 	movl   $0x801f18,0x8(%esp)
  8013c8:	00 
  8013c9:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8013d0:	00 
  8013d1:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  8013d8:	e8 4d 03 00 00       	call   80172a <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid() ;
  8013dd:	e8 13 fd ff ff       	call   8010f5 <sys_getenvid>
  8013e2:	89 c3                	mov    %eax,%ebx
	//cprintf(" pgfault : %d\n %08x\n",envid , PFTEMP); 
	sys_page_alloc( envid , ( void * ) PFTEMP , (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W);  
  8013e4:	8b 07                	mov    (%edi),%eax
  8013e6:	25 05 06 00 00       	and    $0x605,%eax
  8013eb:	83 c8 02             	or     $0x2,%eax
  8013ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013f9:	00 
  8013fa:	89 1c 24             	mov    %ebx,(%esp)
  8013fd:	e8 31 fd ff ff       	call   801133 <sys_page_alloc>
	//cprintf(" Did it reach here and made an alloc call?\n");
	memmove( ( void * ) PFTEMP , ( void * ) ROUNDDOWN( addr , PGSIZE ) , PGSIZE ) ; 
  801402:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801408:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80140f:	00 
  801410:	89 74 24 04          	mov    %esi,0x4(%esp)
  801414:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80141b:	e8 94 fa ff ff       	call   800eb4 <memmove>
	sys_page_map( envid , ( void * ) PFTEMP , envid , ( void * ) ROUNDDOWN( addr , PGSIZE ) ,  (( * pte_ptr ) & ( PTE_SYSCALL ^ PTE_COW )) | PTE_W );  
  801420:	8b 07                	mov    (%edi),%eax
  801422:	25 05 06 00 00       	and    $0x605,%eax
  801427:	83 c8 02             	or     $0x2,%eax
  80142a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80142e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801432:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801436:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80143d:	00 
  80143e:	89 1c 24             	mov    %ebx,(%esp)
  801441:	e8 41 fd ff ff       	call   801187 <sys_page_map>
	sys_page_unmap( envid , PFTEMP ) ; 
  801446:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80144d:	00 
  80144e:	89 1c 24             	mov    %ebx,(%esp)
  801451:	e8 84 fd ff ff       	call   8011da <sys_page_unmap>
	//panic("pgfault not implemented");
}
  801456:	83 c4 2c             	add    $0x2c,%esp
  801459:	5b                   	pop    %ebx
  80145a:	5e                   	pop    %esi
  80145b:	5f                   	pop    %edi
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	53                   	push   %ebx
  801464:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// First , set handler
	set_pgfault_handler(pgfault); 
  801467:	c7 04 24 48 13 80 00 	movl   $0x801348,(%esp)
  80146e:	e8 0d 03 00 00       	call   801780 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801473:	b8 07 00 00 00       	mov    $0x7,%eax
  801478:	cd 30                	int    $0x30
  80147a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80147d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
  801480:	85 c0                	test   %eax,%eax
  801482:	79 1c                	jns    8014a0 <fork+0x42>
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
  801484:	c7 44 24 08 44 1f 80 	movl   $0x801f44,0x8(%esp)
  80148b:	00 
  80148c:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  801493:	00 
  801494:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  80149b:	e8 8a 02 00 00       	call   80172a <_panic>
	if ( childid == 0 ) {
  8014a0:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014a4:	74 17                	je     8014bd <fork+0x5f>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  8014a6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8014ab:	c1 e8 16             	shr    $0x16,%eax
  8014ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8014b1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8014b8:	e9 22 02 00 00       	jmp    8016df <fork+0x281>
	// Second , fork a child
	envid_t childid = sys_exofork() ;
	if ( childid < 0 ) 	
		panic(" in inc/fork.c <fork> : Unable to fork a child!\n");
	if ( childid == 0 ) {
		thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  8014bd:	e8 33 fc ff ff       	call   8010f5 <sys_getenvid>
  8014c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014cf:	a3 04 30 80 00       	mov    %eax,0x803004
		return 0 ;
  8014d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d9:	e9 22 02 00 00       	jmp    801700 <fork+0x2a2>
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
  8014de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014e1:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  8014e8:	01 
  8014e9:	0f 84 ec 01 00 00    	je     8016db <fork+0x27d>
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
  8014ef:	89 c6                	mov    %eax,%esi
  8014f1:	c1 e0 0c             	shl    $0xc,%eax
  8014f4:	8d b8 00 00 40 ef    	lea    -0x10c00000(%eax),%edi
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
			     ( ptx != PTX(UXSTACKTOP-PGSIZE) ) ) {
				//cprintf(" fork : pdx : %d , ptx : %d\n" , pdx , ptx ) ; 
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
  8014fa:	c1 e6 16             	shl    $0x16,%esi
  8014fd:	bb 00 00 00 00       	mov    $0x0,%ebx
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
			pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( pdx << 12 ) + ( ptx << 2 ) ) ; 
			if ( ! ( ( * pte_ptr ) & PTE_P ) )  continue ; 
  801502:	f6 04 9f 01          	testb  $0x1,(%edi,%ebx,4)
  801506:	0f 84 ba 01 00 00    	je     8016c6 <fork+0x268>
			if ( ( pdx != PDX(UXSTACKTOP-PGSIZE) ) ||
  80150c:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  801512:	75 0d                	jne    801521 <fork+0xc3>
  801514:	81 7d dc ba 03 00 00 	cmpl   $0x3ba,-0x24(%ebp)
  80151b:	0f 84 8a 01 00 00    	je     8016ab <fork+0x24d>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid() ; 
  801521:	e8 cf fb ff ff       	call   8010f5 <sys_getenvid>
  801526:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t addr = pn * PGSIZE ;
	//cprintf(" duppage : now envid is : %d\n", sys_getenvid() ) ;
	//cprintf(" duppage : page address is %08x %d %d\n" , addr,PDX(addr),PTX(addr) ) ;
	pde_t * pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd ) + ( PDX(addr) << 2 ) ) ; 
  801529:	89 f0                	mov    %esi,%eax
  80152b:	c1 e8 16             	shr    $0x16,%eax
	pte_t * pte_ptr = ( pte_t * ) ( ( ( uint32_t ) uvpt ) + ( PDX(addr) << 12 ) + ( PTX(addr) << 2 ) ) ; 
  80152e:	89 c1                	mov    %eax,%ecx
  801530:	c1 e1 0c             	shl    $0xc,%ecx
  801533:	81 c1 00 00 40 ef    	add    $0xef400000,%ecx
  801539:	89 f2                	mov    %esi,%edx
  80153b:	c1 ea 0a             	shr    $0xa,%edx
  80153e:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801544:	01 ca                	add    %ecx,%edx
	
	//cprintf(" duppage : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
	//cprintf(" duppage : pte_ptr's value is : %08x\n" , ( * pte_ptr ) ) ;
	if (!( ( * pde_ptr ) & PTE_P ) ) 
  801546:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  80154b:	f6 04 81 01          	testb  $0x1,(%ecx,%eax,4)
  80154f:	75 1c                	jne    80156d <fork+0x10f>
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
  801551:	c7 44 24 08 78 1f 80 	movl   $0x801f78,0x8(%esp)
  801558:	00 
  801559:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801560:	00 
  801561:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  801568:	e8 bd 01 00 00       	call   80172a <_panic>
	if (!( ( * pte_ptr ) & PTE_P ) ) 
  80156d:	8b 02                	mov    (%edx),%eax
  80156f:	a8 01                	test   $0x1,%al
  801571:	75 1c                	jne    80158f <fork+0x131>
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
  801573:	c7 44 24 08 bc 1f 80 	movl   $0x801fbc,0x8(%esp)
  80157a:	00 
  80157b:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801582:	00 
  801583:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  80158a:	e8 9b 01 00 00       	call   80172a <_panic>
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
  80158f:	89 c2                	mov    %eax,%edx
  801591:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	if ( perm & PTE_W ) {
  801597:	a8 02                	test   $0x2,%al
  801599:	0f 84 8b 00 00 00    	je     80162a <fork+0x1cc>
		if ( sys_page_map( curenvid , ( void * ) addr , 
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
  80159f:	89 d0                	mov    %edx,%eax
  8015a1:	83 f0 02             	xor    $0x2,%eax
		panic(" in inc/fork.c <duppage> : Page Directory Entry doesn't exsist!\n");
	if (!( ( * pte_ptr ) & PTE_P ) ) 
		panic(" in inc/fork.c <duppage> : Page Table Entry doesn't exsist!\n");
	int perm = (*pte_ptr) & PTE_SYSCALL ; 
	if ( perm & PTE_W ) {
		if ( sys_page_map( curenvid , ( void * ) addr , 
  8015a4:	80 cc 08             	or     $0x8,%ah
  8015a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c0:	89 04 24             	mov    %eax,(%esp)
  8015c3:	e8 bf fb ff ff       	call   801187 <sys_page_map>
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	79 1c                	jns    8015e8 <fork+0x18a>
                                   envid    , ( void * ) addr , 
                                   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page! %e\n");
  8015cc:	c7 44 24 08 fc 1f 80 	movl   $0x801ffc,0x8(%esp)
  8015d3:	00 
  8015d4:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8015db:	00 
  8015dc:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  8015e3:	e8 42 01 00 00       	call   80172a <_panic>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  8015e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015fe:	89 04 24             	mov    %eax,(%esp)
  801601:	e8 81 fb ff ff       	call   801187 <sys_page_map>
  801606:	85 c0                	test   %eax,%eax
  801608:	0f 89 b8 00 00 00    	jns    8016c6 <fork+0x268>
				   curenvid , ( void * ) addr , 
				   ( perm ^ PTE_W ) | PTE_COW ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  80160e:	c7 44 24 08 34 20 80 	movl   $0x802034,0x8(%esp)
  801615:	00 
  801616:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80161d:	00 
  80161e:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  801625:	e8 00 01 00 00       	call   80172a <_panic>
		return 0 ; 	
	}  
	if ( perm & PTE_COW ) {
  80162a:	f6 c4 08             	test   $0x8,%ah
  80162d:	74 3e                	je     80166d <fork+0x20f>
		if ( sys_page_map( curenvid , ( void * ) addr , 
  80162f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801633:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801637:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80163a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80163e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801645:	89 04 24             	mov    %eax,(%esp)
  801648:	e8 3a fb ff ff       	call   801187 <sys_page_map>
  80164d:	85 c0                	test   %eax,%eax
  80164f:	79 75                	jns    8016c6 <fork+0x268>
                                   envid    , ( void * ) addr , 
                                   perm ) < 0 ) 
			panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  801651:	c7 44 24 08 34 20 80 	movl   $0x802034,0x8(%esp)
  801658:	00 
  801659:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801660:	00 
  801661:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  801668:	e8 bd 00 00 00       	call   80172a <_panic>
		return 0 ;
	}
	if ( sys_page_map( curenvid , ( void * ) addr , 
  80166d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801671:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801675:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801678:	89 44 24 08          	mov    %eax,0x8(%esp)
  80167c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801680:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801683:	89 04 24             	mov    %eax,(%esp)
  801686:	e8 fc fa ff ff       	call   801187 <sys_page_map>
  80168b:	85 c0                	test   %eax,%eax
  80168d:	79 37                	jns    8016c6 <fork+0x268>
		           envid    , ( void * ) addr , 
			   perm ) < 0 ) 
		panic(" in inc/fork.c <duppage> : Unable to map the page!\n");
  80168f:	c7 44 24 08 34 20 80 	movl   $0x802034,0x8(%esp)
  801696:	00 
  801697:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80169e:	00 
  80169f:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  8016a6:	e8 7f 00 00 00       	call   80172a <_panic>
				//cprintf(" fork : pte_ptr's address is : %08x\n" , ( uint32_t) pte_ptr ) ;
				//cprintf(" fork : pte_ptr's value is : %08x\n" , (* pte_ptr ) ) ;
				duppage( childid , ( pdx << 10 ) + ptx ) ; 
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
  8016ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016b2:	00 
  8016b3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016ba:	ee 
  8016bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016be:	89 04 24             	mov    %eax,(%esp)
  8016c1:	e8 6d fa ff ff       	call   801133 <sys_page_alloc>
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
		pde_ptr = ( pde_t * ) ( ( ( uint32_t ) uvpd )  + ( pdx << 2 ) ) ; 
		if ( !( ( *pde_ptr ) & PTE_P ) ) continue ;
		for ( ptx = 0 ; ptx < NPTENTRIES ; ptx ++ ) {	 
  8016c6:	83 c3 01             	add    $0x1,%ebx
  8016c9:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8016cf:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8016d5:	0f 85 27 fe ff ff    	jne    801502 <fork+0xa4>
	//cprintf(" fork : now envid is : %d\n", sys_getenvid() ) ;
	// Third , move pages 
	uint32_t pdx = 0 , ptx = 0 ; 
	pde_t * pde_ptr ;
	pte_t * pte_ptr ; 
	for ( pdx = 0 ; pdx < PDX(envs) ; pdx ++ ) {
  8016db:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  8016df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016e2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  8016e5:	0f 85 f3 fd ff ff    	jne    8014de <fork+0x80>
				continue; 
			}
			sys_page_alloc( childid , (void*)( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ; 
		}						
	}
	sys_env_set_status( childid , ENV_RUNNABLE ) ;
  8016eb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016f2:	00 
  8016f3:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8016f6:	89 3c 24             	mov    %edi,(%esp)
  8016f9:	e8 2f fb ff ff       	call   80122d <sys_env_set_status>
	return childid ;
  8016fe:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801700:	83 c4 3c             	add    $0x3c,%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5f                   	pop    %edi
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <sfork>:

// Challenge!
int
sfork(void)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80170e:	c7 44 24 08 73 20 80 	movl   $0x802073,0x8(%esp)
  801715:	00 
  801716:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  80171d:	00 
  80171e:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  801725:	e8 00 00 00 00       	call   80172a <_panic>

0080172a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801732:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801735:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80173b:	e8 b5 f9 ff ff       	call   8010f5 <sys_getenvid>
  801740:	8b 55 0c             	mov    0xc(%ebp),%edx
  801743:	89 54 24 10          	mov    %edx,0x10(%esp)
  801747:	8b 55 08             	mov    0x8(%ebp),%edx
  80174a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80174e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801752:	89 44 24 04          	mov    %eax,0x4(%esp)
  801756:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  80175d:	e8 90 ea ff ff       	call   8001f2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801762:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801766:	8b 45 10             	mov    0x10(%ebp),%eax
  801769:	89 04 24             	mov    %eax,(%esp)
  80176c:	e8 20 ea ff ff       	call   800191 <vcprintf>
	cprintf("\n");
  801771:	c7 04 24 af 1a 80 00 	movl   $0x801aaf,(%esp)
  801778:	e8 75 ea ff ff       	call   8001f2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80177d:	cc                   	int3   
  80177e:	eb fd                	jmp    80177d <_panic+0x53>

00801780 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801786:	83 3d 08 30 80 00 00 	cmpl   $0x0,0x803008
  80178d:	75 32                	jne    8017c1 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  80178f:	e8 61 f9 ff ff       	call   8010f5 <sys_getenvid>
  801794:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80179b:	00 
  80179c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017a3:	ee 
  8017a4:	89 04 24             	mov    %eax,(%esp)
  8017a7:	e8 87 f9 ff ff       	call   801133 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  8017ac:	e8 44 f9 ff ff       	call   8010f5 <sys_getenvid>
  8017b1:	c7 44 24 04 cb 17 80 	movl   $0x8017cb,0x4(%esp)
  8017b8:	00 
  8017b9:	89 04 24             	mov    %eax,(%esp)
  8017bc:	e8 bf fa ff ff       	call   801280 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	a3 08 30 80 00       	mov    %eax,0x803008
}
  8017c9:	c9                   	leave  
  8017ca:	c3                   	ret    

008017cb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8017cb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8017cc:	a1 08 30 80 00       	mov    0x803008,%eax
	call *%eax
  8017d1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8017d3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  8017d6:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  8017d9:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  8017dd:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  8017e1:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  8017e4:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  8017e8:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  8017ea:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  8017eb:	83 c4 04             	add    $0x4,%esp
	popfl 	
  8017ee:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8017ef:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8017f0:	c3                   	ret    
  8017f1:	66 90                	xchg   %ax,%ax
  8017f3:	66 90                	xchg   %ax,%ax
  8017f5:	66 90                	xchg   %ax,%ax
  8017f7:	66 90                	xchg   %ax,%ax
  8017f9:	66 90                	xchg   %ax,%ax
  8017fb:	66 90                	xchg   %ax,%ax
  8017fd:	66 90                	xchg   %ax,%ax
  8017ff:	90                   	nop

00801800 <__udivdi3>:
  801800:	55                   	push   %ebp
  801801:	57                   	push   %edi
  801802:	56                   	push   %esi
  801803:	83 ec 0c             	sub    $0xc,%esp
  801806:	8b 44 24 28          	mov    0x28(%esp),%eax
  80180a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80180e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801812:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801816:	85 c0                	test   %eax,%eax
  801818:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80181c:	89 ea                	mov    %ebp,%edx
  80181e:	89 0c 24             	mov    %ecx,(%esp)
  801821:	75 2d                	jne    801850 <__udivdi3+0x50>
  801823:	39 e9                	cmp    %ebp,%ecx
  801825:	77 61                	ja     801888 <__udivdi3+0x88>
  801827:	85 c9                	test   %ecx,%ecx
  801829:	89 ce                	mov    %ecx,%esi
  80182b:	75 0b                	jne    801838 <__udivdi3+0x38>
  80182d:	b8 01 00 00 00       	mov    $0x1,%eax
  801832:	31 d2                	xor    %edx,%edx
  801834:	f7 f1                	div    %ecx
  801836:	89 c6                	mov    %eax,%esi
  801838:	31 d2                	xor    %edx,%edx
  80183a:	89 e8                	mov    %ebp,%eax
  80183c:	f7 f6                	div    %esi
  80183e:	89 c5                	mov    %eax,%ebp
  801840:	89 f8                	mov    %edi,%eax
  801842:	f7 f6                	div    %esi
  801844:	89 ea                	mov    %ebp,%edx
  801846:	83 c4 0c             	add    $0xc,%esp
  801849:	5e                   	pop    %esi
  80184a:	5f                   	pop    %edi
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    
  80184d:	8d 76 00             	lea    0x0(%esi),%esi
  801850:	39 e8                	cmp    %ebp,%eax
  801852:	77 24                	ja     801878 <__udivdi3+0x78>
  801854:	0f bd e8             	bsr    %eax,%ebp
  801857:	83 f5 1f             	xor    $0x1f,%ebp
  80185a:	75 3c                	jne    801898 <__udivdi3+0x98>
  80185c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801860:	39 34 24             	cmp    %esi,(%esp)
  801863:	0f 86 9f 00 00 00    	jbe    801908 <__udivdi3+0x108>
  801869:	39 d0                	cmp    %edx,%eax
  80186b:	0f 82 97 00 00 00    	jb     801908 <__udivdi3+0x108>
  801871:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801878:	31 d2                	xor    %edx,%edx
  80187a:	31 c0                	xor    %eax,%eax
  80187c:	83 c4 0c             	add    $0xc,%esp
  80187f:	5e                   	pop    %esi
  801880:	5f                   	pop    %edi
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    
  801883:	90                   	nop
  801884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801888:	89 f8                	mov    %edi,%eax
  80188a:	f7 f1                	div    %ecx
  80188c:	31 d2                	xor    %edx,%edx
  80188e:	83 c4 0c             	add    $0xc,%esp
  801891:	5e                   	pop    %esi
  801892:	5f                   	pop    %edi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    
  801895:	8d 76 00             	lea    0x0(%esi),%esi
  801898:	89 e9                	mov    %ebp,%ecx
  80189a:	8b 3c 24             	mov    (%esp),%edi
  80189d:	d3 e0                	shl    %cl,%eax
  80189f:	89 c6                	mov    %eax,%esi
  8018a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8018a6:	29 e8                	sub    %ebp,%eax
  8018a8:	89 c1                	mov    %eax,%ecx
  8018aa:	d3 ef                	shr    %cl,%edi
  8018ac:	89 e9                	mov    %ebp,%ecx
  8018ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8018b2:	8b 3c 24             	mov    (%esp),%edi
  8018b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8018b9:	89 d6                	mov    %edx,%esi
  8018bb:	d3 e7                	shl    %cl,%edi
  8018bd:	89 c1                	mov    %eax,%ecx
  8018bf:	89 3c 24             	mov    %edi,(%esp)
  8018c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018c6:	d3 ee                	shr    %cl,%esi
  8018c8:	89 e9                	mov    %ebp,%ecx
  8018ca:	d3 e2                	shl    %cl,%edx
  8018cc:	89 c1                	mov    %eax,%ecx
  8018ce:	d3 ef                	shr    %cl,%edi
  8018d0:	09 d7                	or     %edx,%edi
  8018d2:	89 f2                	mov    %esi,%edx
  8018d4:	89 f8                	mov    %edi,%eax
  8018d6:	f7 74 24 08          	divl   0x8(%esp)
  8018da:	89 d6                	mov    %edx,%esi
  8018dc:	89 c7                	mov    %eax,%edi
  8018de:	f7 24 24             	mull   (%esp)
  8018e1:	39 d6                	cmp    %edx,%esi
  8018e3:	89 14 24             	mov    %edx,(%esp)
  8018e6:	72 30                	jb     801918 <__udivdi3+0x118>
  8018e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8018ec:	89 e9                	mov    %ebp,%ecx
  8018ee:	d3 e2                	shl    %cl,%edx
  8018f0:	39 c2                	cmp    %eax,%edx
  8018f2:	73 05                	jae    8018f9 <__udivdi3+0xf9>
  8018f4:	3b 34 24             	cmp    (%esp),%esi
  8018f7:	74 1f                	je     801918 <__udivdi3+0x118>
  8018f9:	89 f8                	mov    %edi,%eax
  8018fb:	31 d2                	xor    %edx,%edx
  8018fd:	e9 7a ff ff ff       	jmp    80187c <__udivdi3+0x7c>
  801902:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801908:	31 d2                	xor    %edx,%edx
  80190a:	b8 01 00 00 00       	mov    $0x1,%eax
  80190f:	e9 68 ff ff ff       	jmp    80187c <__udivdi3+0x7c>
  801914:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801918:	8d 47 ff             	lea    -0x1(%edi),%eax
  80191b:	31 d2                	xor    %edx,%edx
  80191d:	83 c4 0c             	add    $0xc,%esp
  801920:	5e                   	pop    %esi
  801921:	5f                   	pop    %edi
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    
  801924:	66 90                	xchg   %ax,%ax
  801926:	66 90                	xchg   %ax,%ax
  801928:	66 90                	xchg   %ax,%ax
  80192a:	66 90                	xchg   %ax,%ax
  80192c:	66 90                	xchg   %ax,%ax
  80192e:	66 90                	xchg   %ax,%ax

00801930 <__umoddi3>:
  801930:	55                   	push   %ebp
  801931:	57                   	push   %edi
  801932:	56                   	push   %esi
  801933:	83 ec 14             	sub    $0x14,%esp
  801936:	8b 44 24 28          	mov    0x28(%esp),%eax
  80193a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80193e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801942:	89 c7                	mov    %eax,%edi
  801944:	89 44 24 04          	mov    %eax,0x4(%esp)
  801948:	8b 44 24 30          	mov    0x30(%esp),%eax
  80194c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801950:	89 34 24             	mov    %esi,(%esp)
  801953:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801957:	85 c0                	test   %eax,%eax
  801959:	89 c2                	mov    %eax,%edx
  80195b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80195f:	75 17                	jne    801978 <__umoddi3+0x48>
  801961:	39 fe                	cmp    %edi,%esi
  801963:	76 4b                	jbe    8019b0 <__umoddi3+0x80>
  801965:	89 c8                	mov    %ecx,%eax
  801967:	89 fa                	mov    %edi,%edx
  801969:	f7 f6                	div    %esi
  80196b:	89 d0                	mov    %edx,%eax
  80196d:	31 d2                	xor    %edx,%edx
  80196f:	83 c4 14             	add    $0x14,%esp
  801972:	5e                   	pop    %esi
  801973:	5f                   	pop    %edi
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    
  801976:	66 90                	xchg   %ax,%ax
  801978:	39 f8                	cmp    %edi,%eax
  80197a:	77 54                	ja     8019d0 <__umoddi3+0xa0>
  80197c:	0f bd e8             	bsr    %eax,%ebp
  80197f:	83 f5 1f             	xor    $0x1f,%ebp
  801982:	75 5c                	jne    8019e0 <__umoddi3+0xb0>
  801984:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801988:	39 3c 24             	cmp    %edi,(%esp)
  80198b:	0f 87 e7 00 00 00    	ja     801a78 <__umoddi3+0x148>
  801991:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801995:	29 f1                	sub    %esi,%ecx
  801997:	19 c7                	sbb    %eax,%edi
  801999:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80199d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8019a9:	83 c4 14             	add    $0x14,%esp
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    
  8019b0:	85 f6                	test   %esi,%esi
  8019b2:	89 f5                	mov    %esi,%ebp
  8019b4:	75 0b                	jne    8019c1 <__umoddi3+0x91>
  8019b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019bb:	31 d2                	xor    %edx,%edx
  8019bd:	f7 f6                	div    %esi
  8019bf:	89 c5                	mov    %eax,%ebp
  8019c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8019c5:	31 d2                	xor    %edx,%edx
  8019c7:	f7 f5                	div    %ebp
  8019c9:	89 c8                	mov    %ecx,%eax
  8019cb:	f7 f5                	div    %ebp
  8019cd:	eb 9c                	jmp    80196b <__umoddi3+0x3b>
  8019cf:	90                   	nop
  8019d0:	89 c8                	mov    %ecx,%eax
  8019d2:	89 fa                	mov    %edi,%edx
  8019d4:	83 c4 14             	add    $0x14,%esp
  8019d7:	5e                   	pop    %esi
  8019d8:	5f                   	pop    %edi
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    
  8019db:	90                   	nop
  8019dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019e0:	8b 04 24             	mov    (%esp),%eax
  8019e3:	be 20 00 00 00       	mov    $0x20,%esi
  8019e8:	89 e9                	mov    %ebp,%ecx
  8019ea:	29 ee                	sub    %ebp,%esi
  8019ec:	d3 e2                	shl    %cl,%edx
  8019ee:	89 f1                	mov    %esi,%ecx
  8019f0:	d3 e8                	shr    %cl,%eax
  8019f2:	89 e9                	mov    %ebp,%ecx
  8019f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f8:	8b 04 24             	mov    (%esp),%eax
  8019fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8019ff:	89 fa                	mov    %edi,%edx
  801a01:	d3 e0                	shl    %cl,%eax
  801a03:	89 f1                	mov    %esi,%ecx
  801a05:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a09:	8b 44 24 10          	mov    0x10(%esp),%eax
  801a0d:	d3 ea                	shr    %cl,%edx
  801a0f:	89 e9                	mov    %ebp,%ecx
  801a11:	d3 e7                	shl    %cl,%edi
  801a13:	89 f1                	mov    %esi,%ecx
  801a15:	d3 e8                	shr    %cl,%eax
  801a17:	89 e9                	mov    %ebp,%ecx
  801a19:	09 f8                	or     %edi,%eax
  801a1b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801a1f:	f7 74 24 04          	divl   0x4(%esp)
  801a23:	d3 e7                	shl    %cl,%edi
  801a25:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a29:	89 d7                	mov    %edx,%edi
  801a2b:	f7 64 24 08          	mull   0x8(%esp)
  801a2f:	39 d7                	cmp    %edx,%edi
  801a31:	89 c1                	mov    %eax,%ecx
  801a33:	89 14 24             	mov    %edx,(%esp)
  801a36:	72 2c                	jb     801a64 <__umoddi3+0x134>
  801a38:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801a3c:	72 22                	jb     801a60 <__umoddi3+0x130>
  801a3e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801a42:	29 c8                	sub    %ecx,%eax
  801a44:	19 d7                	sbb    %edx,%edi
  801a46:	89 e9                	mov    %ebp,%ecx
  801a48:	89 fa                	mov    %edi,%edx
  801a4a:	d3 e8                	shr    %cl,%eax
  801a4c:	89 f1                	mov    %esi,%ecx
  801a4e:	d3 e2                	shl    %cl,%edx
  801a50:	89 e9                	mov    %ebp,%ecx
  801a52:	d3 ef                	shr    %cl,%edi
  801a54:	09 d0                	or     %edx,%eax
  801a56:	89 fa                	mov    %edi,%edx
  801a58:	83 c4 14             	add    $0x14,%esp
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    
  801a5f:	90                   	nop
  801a60:	39 d7                	cmp    %edx,%edi
  801a62:	75 da                	jne    801a3e <__umoddi3+0x10e>
  801a64:	8b 14 24             	mov    (%esp),%edx
  801a67:	89 c1                	mov    %eax,%ecx
  801a69:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801a6d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801a71:	eb cb                	jmp    801a3e <__umoddi3+0x10e>
  801a73:	90                   	nop
  801a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a78:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801a7c:	0f 82 0f ff ff ff    	jb     801991 <__umoddi3+0x61>
  801a82:	e9 1a ff ff ff       	jmp    8019a1 <__umoddi3+0x71>
