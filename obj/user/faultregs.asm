
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 64 05 00 00       	call   800595 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	8b 45 08             	mov    0x8(%ebp),%eax
  800043:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800047:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004b:	c7 44 24 04 91 1b 80 	movl   $0x801b91,0x4(%esp)
  800052:	00 
  800053:	c7 04 24 60 1b 80 00 	movl   $0x801b60,(%esp)
  80005a:	e8 8b 06 00 00       	call   8006ea <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80005f:	8b 03                	mov    (%ebx),%eax
  800061:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800065:	8b 06                	mov    (%esi),%eax
  800067:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006b:	c7 44 24 04 70 1b 80 	movl   $0x801b70,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  80007a:	e8 6b 06 00 00       	call   8006ea <cprintf>
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	39 06                	cmp    %eax,(%esi)
  800083:	75 13                	jne    800098 <check_regs+0x65>
  800085:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  80008c:	e8 59 06 00 00       	call   8006ea <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800091:	bf 00 00 00 00       	mov    $0x0,%edi
  800096:	eb 11                	jmp    8000a9 <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800098:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  80009f:	e8 46 06 00 00       	call   8006ea <cprintf>
  8000a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000a9:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	8b 46 04             	mov    0x4(%esi),%eax
  8000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b7:	c7 44 24 04 92 1b 80 	movl   $0x801b92,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  8000c6:	e8 1f 06 00 00       	call   8006ea <cprintf>
  8000cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ce:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d1:	75 0e                	jne    8000e1 <check_regs+0xae>
  8000d3:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  8000da:	e8 0b 06 00 00       	call   8006ea <cprintf>
  8000df:	eb 11                	jmp    8000f2 <check_regs+0xbf>
  8000e1:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  8000e8:	e8 fd 05 00 00       	call   8006ea <cprintf>
  8000ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f9:	8b 46 08             	mov    0x8(%esi),%eax
  8000fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800100:	c7 44 24 04 96 1b 80 	movl   $0x801b96,0x4(%esp)
  800107:	00 
  800108:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  80010f:	e8 d6 05 00 00       	call   8006ea <cprintf>
  800114:	8b 43 08             	mov    0x8(%ebx),%eax
  800117:	39 46 08             	cmp    %eax,0x8(%esi)
  80011a:	75 0e                	jne    80012a <check_regs+0xf7>
  80011c:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  800123:	e8 c2 05 00 00       	call   8006ea <cprintf>
  800128:	eb 11                	jmp    80013b <check_regs+0x108>
  80012a:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  800131:	e8 b4 05 00 00       	call   8006ea <cprintf>
  800136:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013b:	8b 43 10             	mov    0x10(%ebx),%eax
  80013e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	c7 44 24 04 9a 1b 80 	movl   $0x801b9a,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  800158:	e8 8d 05 00 00       	call   8006ea <cprintf>
  80015d:	8b 43 10             	mov    0x10(%ebx),%eax
  800160:	39 46 10             	cmp    %eax,0x10(%esi)
  800163:	75 0e                	jne    800173 <check_regs+0x140>
  800165:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  80016c:	e8 79 05 00 00       	call   8006ea <cprintf>
  800171:	eb 11                	jmp    800184 <check_regs+0x151>
  800173:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  80017a:	e8 6b 05 00 00       	call   8006ea <cprintf>
  80017f:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800184:	8b 43 14             	mov    0x14(%ebx),%eax
  800187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018b:	8b 46 14             	mov    0x14(%esi),%eax
  80018e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800192:	c7 44 24 04 9e 1b 80 	movl   $0x801b9e,0x4(%esp)
  800199:	00 
  80019a:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  8001a1:	e8 44 05 00 00       	call   8006ea <cprintf>
  8001a6:	8b 43 14             	mov    0x14(%ebx),%eax
  8001a9:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ac:	75 0e                	jne    8001bc <check_regs+0x189>
  8001ae:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  8001b5:	e8 30 05 00 00       	call   8006ea <cprintf>
  8001ba:	eb 11                	jmp    8001cd <check_regs+0x19a>
  8001bc:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  8001c3:	e8 22 05 00 00       	call   8006ea <cprintf>
  8001c8:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001cd:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 46 18             	mov    0x18(%esi),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	c7 44 24 04 a2 1b 80 	movl   $0x801ba2,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  8001ea:	e8 fb 04 00 00       	call   8006ea <cprintf>
  8001ef:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f5:	75 0e                	jne    800205 <check_regs+0x1d2>
  8001f7:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  8001fe:	e8 e7 04 00 00       	call   8006ea <cprintf>
  800203:	eb 11                	jmp    800216 <check_regs+0x1e3>
  800205:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  80020c:	e8 d9 04 00 00       	call   8006ea <cprintf>
  800211:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021d:	8b 46 1c             	mov    0x1c(%esi),%eax
  800220:	89 44 24 08          	mov    %eax,0x8(%esp)
  800224:	c7 44 24 04 a6 1b 80 	movl   $0x801ba6,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  800233:	e8 b2 04 00 00       	call   8006ea <cprintf>
  800238:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023b:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023e:	75 0e                	jne    80024e <check_regs+0x21b>
  800240:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  800247:	e8 9e 04 00 00       	call   8006ea <cprintf>
  80024c:	eb 11                	jmp    80025f <check_regs+0x22c>
  80024e:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  800255:	e8 90 04 00 00       	call   8006ea <cprintf>
  80025a:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80025f:	8b 43 20             	mov    0x20(%ebx),%eax
  800262:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800266:	8b 46 20             	mov    0x20(%esi),%eax
  800269:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026d:	c7 44 24 04 aa 1b 80 	movl   $0x801baa,0x4(%esp)
  800274:	00 
  800275:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  80027c:	e8 69 04 00 00       	call   8006ea <cprintf>
  800281:	8b 43 20             	mov    0x20(%ebx),%eax
  800284:	39 46 20             	cmp    %eax,0x20(%esi)
  800287:	75 0e                	jne    800297 <check_regs+0x264>
  800289:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  800290:	e8 55 04 00 00       	call   8006ea <cprintf>
  800295:	eb 11                	jmp    8002a8 <check_regs+0x275>
  800297:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  80029e:	e8 47 04 00 00       	call   8006ea <cprintf>
  8002a3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a8:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 46 24             	mov    0x24(%esi),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	c7 44 24 04 ae 1b 80 	movl   $0x801bae,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  8002c5:	e8 20 04 00 00       	call   8006ea <cprintf>
  8002ca:	8b 43 24             	mov    0x24(%ebx),%eax
  8002cd:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d0:	75 0e                	jne    8002e0 <check_regs+0x2ad>
  8002d2:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  8002d9:	e8 0c 04 00 00       	call   8006ea <cprintf>
  8002de:	eb 11                	jmp    8002f1 <check_regs+0x2be>
  8002e0:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  8002e7:	e8 fe 03 00 00       	call   8006ea <cprintf>
  8002ec:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f8:	8b 46 28             	mov    0x28(%esi),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 04 b5 1b 80 	movl   $0x801bb5,0x4(%esp)
  800306:	00 
  800307:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  80030e:	e8 d7 03 00 00       	call   8006ea <cprintf>
  800313:	8b 43 28             	mov    0x28(%ebx),%eax
  800316:	39 46 28             	cmp    %eax,0x28(%esi)
  800319:	75 25                	jne    800340 <check_regs+0x30d>
  80031b:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  800322:	e8 c3 03 00 00       	call   8006ea <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 b9 1b 80 00 	movl   $0x801bb9,(%esp)
  800335:	e8 b0 03 00 00       	call   8006ea <cprintf>
	if (!mismatch)
  80033a:	85 ff                	test   %edi,%edi
  80033c:	74 23                	je     800361 <check_regs+0x32e>
  80033e:	eb 2f                	jmp    80036f <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800340:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  800347:	e8 9e 03 00 00       	call   8006ea <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	c7 04 24 b9 1b 80 00 	movl   $0x801bb9,(%esp)
  80035a:	e8 8b 03 00 00       	call   8006ea <cprintf>
  80035f:	eb 0e                	jmp    80036f <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800361:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  800368:	e8 7d 03 00 00       	call   8006ea <cprintf>
  80036d:	eb 0c                	jmp    80037b <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80036f:	c7 04 24 88 1b 80 00 	movl   $0x801b88,(%esp)
  800376:	e8 6f 03 00 00       	call   8006ea <cprintf>
}
  80037b:	83 c4 1c             	add    $0x1c,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	83 ec 28             	sub    $0x28,%esp
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800394:	74 27                	je     8003bd <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800396:	8b 40 28             	mov    0x28(%eax),%eax
  800399:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a1:	c7 44 24 08 20 1c 80 	movl   $0x801c20,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 c7 1b 80 00 	movl   $0x801bc7,(%esp)
  8003b8:	e8 34 02 00 00       	call   8005f1 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003bd:	8b 50 08             	mov    0x8(%eax),%edx
  8003c0:	89 15 60 30 80 00    	mov    %edx,0x803060
  8003c6:	8b 50 0c             	mov    0xc(%eax),%edx
  8003c9:	89 15 64 30 80 00    	mov    %edx,0x803064
  8003cf:	8b 50 10             	mov    0x10(%eax),%edx
  8003d2:	89 15 68 30 80 00    	mov    %edx,0x803068
  8003d8:	8b 50 14             	mov    0x14(%eax),%edx
  8003db:	89 15 6c 30 80 00    	mov    %edx,0x80306c
  8003e1:	8b 50 18             	mov    0x18(%eax),%edx
  8003e4:	89 15 70 30 80 00    	mov    %edx,0x803070
  8003ea:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ed:	89 15 74 30 80 00    	mov    %edx,0x803074
  8003f3:	8b 50 20             	mov    0x20(%eax),%edx
  8003f6:	89 15 78 30 80 00    	mov    %edx,0x803078
  8003fc:	8b 50 24             	mov    0x24(%eax),%edx
  8003ff:	89 15 7c 30 80 00    	mov    %edx,0x80307c
	during.eip = utf->utf_eip;
  800405:	8b 50 28             	mov    0x28(%eax),%edx
  800408:	89 15 80 30 80 00    	mov    %edx,0x803080
	during.eflags = utf->utf_eflags;
  80040e:	8b 50 2c             	mov    0x2c(%eax),%edx
  800411:	89 15 84 30 80 00    	mov    %edx,0x803084
	during.esp = utf->utf_esp;
  800417:	8b 40 30             	mov    0x30(%eax),%eax
  80041a:	a3 88 30 80 00       	mov    %eax,0x803088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80041f:	c7 44 24 04 df 1b 80 	movl   $0x801bdf,0x4(%esp)
  800426:	00 
  800427:	c7 04 24 ed 1b 80 00 	movl   $0x801bed,(%esp)
  80042e:	b9 60 30 80 00       	mov    $0x803060,%ecx
  800433:	ba d8 1b 80 00       	mov    $0x801bd8,%edx
  800438:	b8 a0 30 80 00       	mov    $0x8030a0,%eax
  80043d:	e8 f1 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800442:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800449:	00 
  80044a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800451:	00 
  800452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800459:	e8 d5 11 00 00       	call   801633 <sys_page_alloc>
  80045e:	85 c0                	test   %eax,%eax
  800460:	79 20                	jns    800482 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 f4 1b 80 	movl   $0x801bf4,0x8(%esp)
  80046d:	00 
  80046e:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800475:	00 
  800476:	c7 04 24 c7 1b 80 00 	movl   $0x801bc7,(%esp)
  80047d:	e8 6f 01 00 00       	call   8005f1 <_panic>
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <umain>:

void
umain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048a:	c7 04 24 83 03 80 00 	movl   $0x800383,(%esp)
  800491:	e8 b2 13 00 00       	call   801848 <set_pgfault_handler>

	__asm __volatile(
  800496:	50                   	push   %eax
  800497:	9c                   	pushf  
  800498:	58                   	pop    %eax
  800499:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049e:	50                   	push   %eax
  80049f:	9d                   	popf   
  8004a0:	a3 c4 30 80 00       	mov    %eax,0x8030c4
  8004a5:	8d 05 e0 04 80 00    	lea    0x8004e0,%eax
  8004ab:	a3 c0 30 80 00       	mov    %eax,0x8030c0
  8004b0:	58                   	pop    %eax
  8004b1:	89 3d a0 30 80 00    	mov    %edi,0x8030a0
  8004b7:	89 35 a4 30 80 00    	mov    %esi,0x8030a4
  8004bd:	89 2d a8 30 80 00    	mov    %ebp,0x8030a8
  8004c3:	89 1d b0 30 80 00    	mov    %ebx,0x8030b0
  8004c9:	89 15 b4 30 80 00    	mov    %edx,0x8030b4
  8004cf:	89 0d b8 30 80 00    	mov    %ecx,0x8030b8
  8004d5:	a3 bc 30 80 00       	mov    %eax,0x8030bc
  8004da:	89 25 c8 30 80 00    	mov    %esp,0x8030c8
  8004e0:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e7:	00 00 00 
  8004ea:	89 3d 20 30 80 00    	mov    %edi,0x803020
  8004f0:	89 35 24 30 80 00    	mov    %esi,0x803024
  8004f6:	89 2d 28 30 80 00    	mov    %ebp,0x803028
  8004fc:	89 1d 30 30 80 00    	mov    %ebx,0x803030
  800502:	89 15 34 30 80 00    	mov    %edx,0x803034
  800508:	89 0d 38 30 80 00    	mov    %ecx,0x803038
  80050e:	a3 3c 30 80 00       	mov    %eax,0x80303c
  800513:	89 25 48 30 80 00    	mov    %esp,0x803048
  800519:	8b 3d a0 30 80 00    	mov    0x8030a0,%edi
  80051f:	8b 35 a4 30 80 00    	mov    0x8030a4,%esi
  800525:	8b 2d a8 30 80 00    	mov    0x8030a8,%ebp
  80052b:	8b 1d b0 30 80 00    	mov    0x8030b0,%ebx
  800531:	8b 15 b4 30 80 00    	mov    0x8030b4,%edx
  800537:	8b 0d b8 30 80 00    	mov    0x8030b8,%ecx
  80053d:	a1 bc 30 80 00       	mov    0x8030bc,%eax
  800542:	8b 25 c8 30 80 00    	mov    0x8030c8,%esp
  800548:	50                   	push   %eax
  800549:	9c                   	pushf  
  80054a:	58                   	pop    %eax
  80054b:	a3 44 30 80 00       	mov    %eax,0x803044
  800550:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800551:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800558:	74 0c                	je     800566 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055a:	c7 04 24 54 1c 80 00 	movl   $0x801c54,(%esp)
  800561:	e8 84 01 00 00       	call   8006ea <cprintf>
	after.eip = before.eip;
  800566:	a1 c0 30 80 00       	mov    0x8030c0,%eax
  80056b:	a3 40 30 80 00       	mov    %eax,0x803040

	check_regs(&before, "before", &after, "after", "after page-fault");
  800570:	c7 44 24 04 07 1c 80 	movl   $0x801c07,0x4(%esp)
  800577:	00 
  800578:	c7 04 24 18 1c 80 00 	movl   $0x801c18,(%esp)
  80057f:	b9 20 30 80 00       	mov    $0x803020,%ecx
  800584:	ba d8 1b 80 00       	mov    $0x801bd8,%edx
  800589:	b8 a0 30 80 00       	mov    $0x8030a0,%eax
  80058e:	e8 a0 fa ff ff       	call   800033 <check_regs>
}
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	56                   	push   %esi
  800599:	53                   	push   %ebx
  80059a:	83 ec 10             	sub    $0x10,%esp
  80059d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  8005a3:	e8 4d 10 00 00       	call   8015f5 <sys_getenvid>
  8005a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b5:	a3 cc 30 80 00       	mov    %eax,0x8030cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005ba:	85 db                	test   %ebx,%ebx
  8005bc:	7e 07                	jle    8005c5 <libmain+0x30>
		binaryname = argv[0];
  8005be:	8b 06                	mov    (%esi),%eax
  8005c0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c9:	89 1c 24             	mov    %ebx,(%esp)
  8005cc:	e8 b3 fe ff ff       	call   800484 <umain>

	// exit gracefully
	exit();
  8005d1:	e8 07 00 00 00       	call   8005dd <exit>
}
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005ea:	e8 b4 0f 00 00       	call   8015a3 <sys_env_destroy>
}
  8005ef:	c9                   	leave  
  8005f0:	c3                   	ret    

008005f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
  8005f6:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005fc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800602:	e8 ee 0f 00 00       	call   8015f5 <sys_getenvid>
  800607:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80060e:	8b 55 08             	mov    0x8(%ebp),%edx
  800611:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800615:	89 74 24 08          	mov    %esi,0x8(%esp)
  800619:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061d:	c7 04 24 80 1c 80 00 	movl   $0x801c80,(%esp)
  800624:	e8 c1 00 00 00       	call   8006ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800629:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062d:	8b 45 10             	mov    0x10(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	e8 51 00 00 00       	call   800689 <vcprintf>
	cprintf("\n");
  800638:	c7 04 24 90 1b 80 00 	movl   $0x801b90,(%esp)
  80063f:	e8 a6 00 00 00       	call   8006ea <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800644:	cc                   	int3   
  800645:	eb fd                	jmp    800644 <_panic+0x53>

00800647 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800647:	55                   	push   %ebp
  800648:	89 e5                	mov    %esp,%ebp
  80064a:	53                   	push   %ebx
  80064b:	83 ec 14             	sub    $0x14,%esp
  80064e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800651:	8b 13                	mov    (%ebx),%edx
  800653:	8d 42 01             	lea    0x1(%edx),%eax
  800656:	89 03                	mov    %eax,(%ebx)
  800658:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80065b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80065f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800664:	75 19                	jne    80067f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800666:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80066d:	00 
  80066e:	8d 43 08             	lea    0x8(%ebx),%eax
  800671:	89 04 24             	mov    %eax,(%esp)
  800674:	e8 ed 0e 00 00       	call   801566 <sys_cputs>
		b->idx = 0;
  800679:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80067f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800683:	83 c4 14             	add    $0x14,%esp
  800686:	5b                   	pop    %ebx
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    

00800689 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800689:	55                   	push   %ebp
  80068a:	89 e5                	mov    %esp,%ebp
  80068c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800692:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800699:	00 00 00 
	b.cnt = 0;
  80069c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006be:	c7 04 24 47 06 80 00 	movl   $0x800647,(%esp)
  8006c5:	e8 b5 02 00 00       	call   80097f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ca:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	e8 84 0e 00 00       	call   801566 <sys_cputs>

	return b.cnt;
}
  8006e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	89 04 24             	mov    %eax,(%esp)
  8006fd:	e8 87 ff ff ff       	call   800689 <vcprintf>
	va_end(ap);

	return cnt;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    
  800704:	66 90                	xchg   %ax,%ax
  800706:	66 90                	xchg   %ax,%ax
  800708:	66 90                	xchg   %ax,%ax
  80070a:	66 90                	xchg   %ax,%ax
  80070c:	66 90                	xchg   %ax,%ax
  80070e:	66 90                	xchg   %ax,%ax

00800710 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	57                   	push   %edi
  800714:	56                   	push   %esi
  800715:	53                   	push   %ebx
  800716:	83 ec 3c             	sub    $0x3c,%esp
  800719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071c:	89 d7                	mov    %edx,%edi
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
  800727:	89 c3                	mov    %eax,%ebx
  800729:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80072c:	8b 45 10             	mov    0x10(%ebp),%eax
  80072f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800732:	b9 00 00 00 00       	mov    $0x0,%ecx
  800737:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80073d:	39 d9                	cmp    %ebx,%ecx
  80073f:	72 05                	jb     800746 <printnum+0x36>
  800741:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800744:	77 69                	ja     8007af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800746:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800749:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80074d:	83 ee 01             	sub    $0x1,%esi
  800750:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800754:	89 44 24 08          	mov    %eax,0x8(%esp)
  800758:	8b 44 24 08          	mov    0x8(%esp),%eax
  80075c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800760:	89 c3                	mov    %eax,%ebx
  800762:	89 d6                	mov    %edx,%esi
  800764:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800767:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80076a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80076e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800772:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80077b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077f:	e8 3c 11 00 00       	call   8018c0 <__udivdi3>
  800784:	89 d9                	mov    %ebx,%ecx
  800786:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	89 54 24 04          	mov    %edx,0x4(%esp)
  800795:	89 fa                	mov    %edi,%edx
  800797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80079a:	e8 71 ff ff ff       	call   800710 <printnum>
  80079f:	eb 1b                	jmp    8007bc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	ff d3                	call   *%ebx
  8007ad:	eb 03                	jmp    8007b2 <printnum+0xa2>
  8007af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007b2:	83 ee 01             	sub    $0x1,%esi
  8007b5:	85 f6                	test   %esi,%esi
  8007b7:	7f e8                	jg     8007a1 <printnum+0x91>
  8007b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d5:	89 04 24             	mov    %eax,(%esp)
  8007d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007df:	e8 0c 12 00 00       	call   8019f0 <__umoddi3>
  8007e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e8:	0f be 80 a4 1c 80 00 	movsbl 0x801ca4(%eax),%eax
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f5:	ff d0                	call   *%eax
}
  8007f7:	83 c4 3c             	add    $0x3c,%esp
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5f                   	pop    %edi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	57                   	push   %edi
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	83 ec 3c             	sub    $0x3c,%esp
  800808:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80080b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80080e:	89 cf                	mov    %ecx,%edi
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800816:	8b 45 0c             	mov    0xc(%ebp),%eax
  800819:	89 c3                	mov    %eax,%ebx
  80081b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80081e:	8b 45 10             	mov    0x10(%ebp),%eax
  800821:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800824:	b9 00 00 00 00       	mov    $0x0,%ecx
  800829:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80082c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80082f:	39 d9                	cmp    %ebx,%ecx
  800831:	72 13                	jb     800846 <cprintnum+0x47>
  800833:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800836:	76 0e                	jbe    800846 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800838:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80083b:	0b 45 18             	or     0x18(%ebp),%eax
  80083e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800841:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800844:	eb 6a                	jmp    8008b0 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800846:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800849:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80084d:	83 ee 01             	sub    $0x1,%esi
  800850:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800854:	89 44 24 08          	mov    %eax,0x8(%esp)
  800858:	8b 44 24 08          	mov    0x8(%esp),%eax
  80085c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800860:	89 c3                	mov    %eax,%ebx
  800862:	89 d6                	mov    %edx,%esi
  800864:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800867:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80086a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80086e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800872:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800875:	89 04 24             	mov    %eax,(%esp)
  800878:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80087b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087f:	e8 3c 10 00 00       	call   8018c0 <__udivdi3>
  800884:	89 d9                	mov    %ebx,%ecx
  800886:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80088a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80088e:	89 04 24             	mov    %eax,(%esp)
  800891:	89 54 24 04          	mov    %edx,0x4(%esp)
  800895:	89 f9                	mov    %edi,%ecx
  800897:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80089a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80089d:	e8 5d ff ff ff       	call   8007ff <cprintnum>
  8008a2:	eb 16                	jmp    8008ba <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8008a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008ab:	89 04 24             	mov    %eax,(%esp)
  8008ae:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008b0:	83 ee 01             	sub    $0x1,%esi
  8008b3:	85 f6                	test   %esi,%esi
  8008b5:	7f ed                	jg     8008a4 <cprintnum+0xa5>
  8008b7:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  8008ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008be:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8008c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008c5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dd:	e8 0e 11 00 00       	call   8019f0 <__umoddi3>
  8008e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008e6:	0f be 80 a4 1c 80 00 	movsbl 0x801ca4(%eax),%eax
  8008ed:	0b 45 dc             	or     -0x24(%ebp),%eax
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f6:	ff d0                	call   *%eax
}
  8008f8:	83 c4 3c             	add    $0x3c,%esp
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5f                   	pop    %edi
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800903:	83 fa 01             	cmp    $0x1,%edx
  800906:	7e 0e                	jle    800916 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800908:	8b 10                	mov    (%eax),%edx
  80090a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80090d:	89 08                	mov    %ecx,(%eax)
  80090f:	8b 02                	mov    (%edx),%eax
  800911:	8b 52 04             	mov    0x4(%edx),%edx
  800914:	eb 22                	jmp    800938 <getuint+0x38>
	else if (lflag)
  800916:	85 d2                	test   %edx,%edx
  800918:	74 10                	je     80092a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80091a:	8b 10                	mov    (%eax),%edx
  80091c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80091f:	89 08                	mov    %ecx,(%eax)
  800921:	8b 02                	mov    (%edx),%eax
  800923:	ba 00 00 00 00       	mov    $0x0,%edx
  800928:	eb 0e                	jmp    800938 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80092a:	8b 10                	mov    (%eax),%edx
  80092c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80092f:	89 08                	mov    %ecx,(%eax)
  800931:	8b 02                	mov    (%edx),%eax
  800933:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800940:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800944:	8b 10                	mov    (%eax),%edx
  800946:	3b 50 04             	cmp    0x4(%eax),%edx
  800949:	73 0a                	jae    800955 <sprintputch+0x1b>
		*b->buf++ = ch;
  80094b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80094e:	89 08                	mov    %ecx,(%eax)
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	88 02                	mov    %al,(%edx)
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80095d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800960:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800964:	8b 45 10             	mov    0x10(%ebp),%eax
  800967:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	89 04 24             	mov    %eax,(%esp)
  800978:	e8 02 00 00 00       	call   80097f <vprintfmt>
	va_end(ap);
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	83 ec 3c             	sub    $0x3c,%esp
  800988:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80098b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80098e:	eb 14                	jmp    8009a4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800990:	85 c0                	test   %eax,%eax
  800992:	0f 84 b3 03 00 00    	je     800d4b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800998:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099c:	89 04 24             	mov    %eax,(%esp)
  80099f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009a2:	89 f3                	mov    %esi,%ebx
  8009a4:	8d 73 01             	lea    0x1(%ebx),%esi
  8009a7:	0f b6 03             	movzbl (%ebx),%eax
  8009aa:	83 f8 25             	cmp    $0x25,%eax
  8009ad:	75 e1                	jne    800990 <vprintfmt+0x11>
  8009af:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8009b3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8009ba:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8009c1:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8009c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cd:	eb 1d                	jmp    8009ec <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009cf:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009d1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8009d5:	eb 15                	jmp    8009ec <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d7:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8009d9:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8009dd:	eb 0d                	jmp    8009ec <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8009df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8009e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8009e5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ec:	8d 5e 01             	lea    0x1(%esi),%ebx
  8009ef:	0f b6 0e             	movzbl (%esi),%ecx
  8009f2:	0f b6 c1             	movzbl %cl,%eax
  8009f5:	83 e9 23             	sub    $0x23,%ecx
  8009f8:	80 f9 55             	cmp    $0x55,%cl
  8009fb:	0f 87 2a 03 00 00    	ja     800d2b <vprintfmt+0x3ac>
  800a01:	0f b6 c9             	movzbl %cl,%ecx
  800a04:	ff 24 8d 60 1d 80 00 	jmp    *0x801d60(,%ecx,4)
  800a0b:	89 de                	mov    %ebx,%esi
  800a0d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a12:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800a15:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800a19:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a1c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800a1f:	83 fb 09             	cmp    $0x9,%ebx
  800a22:	77 36                	ja     800a5a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a24:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a27:	eb e9                	jmp    800a12 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a29:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2c:	8d 48 04             	lea    0x4(%eax),%ecx
  800a2f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a32:	8b 00                	mov    (%eax),%eax
  800a34:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a37:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a39:	eb 22                	jmp    800a5d <vprintfmt+0xde>
  800a3b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800a3e:	85 c9                	test   %ecx,%ecx
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
  800a45:	0f 49 c1             	cmovns %ecx,%eax
  800a48:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4b:	89 de                	mov    %ebx,%esi
  800a4d:	eb 9d                	jmp    8009ec <vprintfmt+0x6d>
  800a4f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a51:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800a58:	eb 92                	jmp    8009ec <vprintfmt+0x6d>
  800a5a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  800a5d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a61:	79 89                	jns    8009ec <vprintfmt+0x6d>
  800a63:	e9 77 ff ff ff       	jmp    8009df <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a68:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a6d:	e9 7a ff ff ff       	jmp    8009ec <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a72:	8b 45 14             	mov    0x14(%ebp),%eax
  800a75:	8d 50 04             	lea    0x4(%eax),%edx
  800a78:	89 55 14             	mov    %edx,0x14(%ebp)
  800a7b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a7f:	8b 00                	mov    (%eax),%eax
  800a81:	89 04 24             	mov    %eax,(%esp)
  800a84:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a87:	e9 18 ff ff ff       	jmp    8009a4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8f:	8d 50 04             	lea    0x4(%eax),%edx
  800a92:	89 55 14             	mov    %edx,0x14(%ebp)
  800a95:	8b 00                	mov    (%eax),%eax
  800a97:	99                   	cltd   
  800a98:	31 d0                	xor    %edx,%eax
  800a9a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a9c:	83 f8 09             	cmp    $0x9,%eax
  800a9f:	7f 0b                	jg     800aac <vprintfmt+0x12d>
  800aa1:	8b 14 85 20 20 80 00 	mov    0x802020(,%eax,4),%edx
  800aa8:	85 d2                	test   %edx,%edx
  800aaa:	75 20                	jne    800acc <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  800aac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ab0:	c7 44 24 08 bc 1c 80 	movl   $0x801cbc,0x8(%esp)
  800ab7:	00 
  800ab8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	89 04 24             	mov    %eax,(%esp)
  800ac2:	e8 90 fe ff ff       	call   800957 <printfmt>
  800ac7:	e9 d8 fe ff ff       	jmp    8009a4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800acc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ad0:	c7 44 24 08 c5 1c 80 	movl   $0x801cc5,0x8(%esp)
  800ad7:	00 
  800ad8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	89 04 24             	mov    %eax,(%esp)
  800ae2:	e8 70 fe ff ff       	call   800957 <printfmt>
  800ae7:	e9 b8 fe ff ff       	jmp    8009a4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800aef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800af2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800af5:	8b 45 14             	mov    0x14(%ebp),%eax
  800af8:	8d 50 04             	lea    0x4(%eax),%edx
  800afb:	89 55 14             	mov    %edx,0x14(%ebp)
  800afe:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800b00:	85 f6                	test   %esi,%esi
  800b02:	b8 b5 1c 80 00       	mov    $0x801cb5,%eax
  800b07:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800b0a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800b0e:	0f 84 97 00 00 00    	je     800bab <vprintfmt+0x22c>
  800b14:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800b18:	0f 8e 9b 00 00 00    	jle    800bb9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b1e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b22:	89 34 24             	mov    %esi,(%esp)
  800b25:	e8 ce 06 00 00       	call   8011f8 <strnlen>
  800b2a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800b2d:	29 c2                	sub    %eax,%edx
  800b2f:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800b32:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800b36:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b39:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800b3c:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b42:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b44:	eb 0f                	jmp    800b55 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800b46:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b4d:	89 04 24             	mov    %eax,(%esp)
  800b50:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b52:	83 eb 01             	sub    $0x1,%ebx
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	7f ed                	jg     800b46 <vprintfmt+0x1c7>
  800b59:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800b5c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800b5f:	85 d2                	test   %edx,%edx
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	0f 49 c2             	cmovns %edx,%eax
  800b69:	29 c2                	sub    %eax,%edx
  800b6b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800b73:	eb 50                	jmp    800bc5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b75:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b79:	74 1e                	je     800b99 <vprintfmt+0x21a>
  800b7b:	0f be d2             	movsbl %dl,%edx
  800b7e:	83 ea 20             	sub    $0x20,%edx
  800b81:	83 fa 5e             	cmp    $0x5e,%edx
  800b84:	76 13                	jbe    800b99 <vprintfmt+0x21a>
					putch('?', putdat);
  800b86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b94:	ff 55 08             	call   *0x8(%ebp)
  800b97:	eb 0d                	jmp    800ba6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800b99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ba0:	89 04 24             	mov    %eax,(%esp)
  800ba3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ba6:	83 ef 01             	sub    $0x1,%edi
  800ba9:	eb 1a                	jmp    800bc5 <vprintfmt+0x246>
  800bab:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800bae:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800bb1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bb4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800bb7:	eb 0c                	jmp    800bc5 <vprintfmt+0x246>
  800bb9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800bbc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800bbf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bc2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800bc5:	83 c6 01             	add    $0x1,%esi
  800bc8:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800bcc:	0f be c2             	movsbl %dl,%eax
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	74 27                	je     800bfa <vprintfmt+0x27b>
  800bd3:	85 db                	test   %ebx,%ebx
  800bd5:	78 9e                	js     800b75 <vprintfmt+0x1f6>
  800bd7:	83 eb 01             	sub    $0x1,%ebx
  800bda:	79 99                	jns    800b75 <vprintfmt+0x1f6>
  800bdc:	89 f8                	mov    %edi,%eax
  800bde:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800be1:	8b 75 08             	mov    0x8(%ebp),%esi
  800be4:	89 c3                	mov    %eax,%ebx
  800be6:	eb 1a                	jmp    800c02 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800be8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bec:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800bf3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bf5:	83 eb 01             	sub    $0x1,%ebx
  800bf8:	eb 08                	jmp    800c02 <vprintfmt+0x283>
  800bfa:	89 fb                	mov    %edi,%ebx
  800bfc:	8b 75 08             	mov    0x8(%ebp),%esi
  800bff:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c02:	85 db                	test   %ebx,%ebx
  800c04:	7f e2                	jg     800be8 <vprintfmt+0x269>
  800c06:	89 75 08             	mov    %esi,0x8(%ebp)
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	e9 93 fd ff ff       	jmp    8009a4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c11:	83 fa 01             	cmp    $0x1,%edx
  800c14:	7e 16                	jle    800c2c <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800c16:	8b 45 14             	mov    0x14(%ebp),%eax
  800c19:	8d 50 08             	lea    0x8(%eax),%edx
  800c1c:	89 55 14             	mov    %edx,0x14(%ebp)
  800c1f:	8b 50 04             	mov    0x4(%eax),%edx
  800c22:	8b 00                	mov    (%eax),%eax
  800c24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c27:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c2a:	eb 32                	jmp    800c5e <vprintfmt+0x2df>
	else if (lflag)
  800c2c:	85 d2                	test   %edx,%edx
  800c2e:	74 18                	je     800c48 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800c30:	8b 45 14             	mov    0x14(%ebp),%eax
  800c33:	8d 50 04             	lea    0x4(%eax),%edx
  800c36:	89 55 14             	mov    %edx,0x14(%ebp)
  800c39:	8b 30                	mov    (%eax),%esi
  800c3b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c3e:	89 f0                	mov    %esi,%eax
  800c40:	c1 f8 1f             	sar    $0x1f,%eax
  800c43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c46:	eb 16                	jmp    800c5e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800c48:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4b:	8d 50 04             	lea    0x4(%eax),%edx
  800c4e:	89 55 14             	mov    %edx,0x14(%ebp)
  800c51:	8b 30                	mov    (%eax),%esi
  800c53:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	c1 f8 1f             	sar    $0x1f,%eax
  800c5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c61:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c64:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c69:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c6d:	0f 89 80 00 00 00    	jns    800cf3 <vprintfmt+0x374>
				putch('-', putdat);
  800c73:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c77:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c7e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c81:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c87:	f7 d8                	neg    %eax
  800c89:	83 d2 00             	adc    $0x0,%edx
  800c8c:	f7 da                	neg    %edx
			}
			base = 10;
  800c8e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c93:	eb 5e                	jmp    800cf3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c95:	8d 45 14             	lea    0x14(%ebp),%eax
  800c98:	e8 63 fc ff ff       	call   800900 <getuint>
			base = 10;
  800c9d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ca2:	eb 4f                	jmp    800cf3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ca4:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca7:	e8 54 fc ff ff       	call   800900 <getuint>
			base = 8 ;
  800cac:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800cb1:	eb 40                	jmp    800cf3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800cb3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cb7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cbe:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cc1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cc5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ccc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ccf:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd2:	8d 50 04             	lea    0x4(%eax),%edx
  800cd5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cd8:	8b 00                	mov    (%eax),%eax
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cdf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ce4:	eb 0d                	jmp    800cf3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ce6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce9:	e8 12 fc ff ff       	call   800900 <getuint>
			base = 16;
  800cee:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cf3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800cf7:	89 74 24 10          	mov    %esi,0x10(%esp)
  800cfb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800cfe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d02:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d06:	89 04 24             	mov    %eax,(%esp)
  800d09:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d0d:	89 fa                	mov    %edi,%edx
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d12:	e8 f9 f9 ff ff       	call   800710 <printnum>
			break;
  800d17:	e9 88 fc ff ff       	jmp    8009a4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d1c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d20:	89 04 24             	mov    %eax,(%esp)
  800d23:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d26:	e9 79 fc ff ff       	jmp    8009a4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d2b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d2f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d36:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d39:	89 f3                	mov    %esi,%ebx
  800d3b:	eb 03                	jmp    800d40 <vprintfmt+0x3c1>
  800d3d:	83 eb 01             	sub    $0x1,%ebx
  800d40:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800d44:	75 f7                	jne    800d3d <vprintfmt+0x3be>
  800d46:	e9 59 fc ff ff       	jmp    8009a4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800d4b:	83 c4 3c             	add    $0x3c,%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 3c             	sub    $0x3c,%esp
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  800d5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d62:	8d 50 04             	lea    0x4(%eax),%edx
  800d65:	89 55 14             	mov    %edx,0x14(%ebp)
  800d68:	8b 00                	mov    (%eax),%eax
  800d6a:	c1 e0 08             	shl    $0x8,%eax
  800d6d:	0f b7 c0             	movzwl %ax,%eax
  800d70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800d73:	83 c8 25             	or     $0x25,%eax
  800d76:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800d79:	eb 1a                	jmp    800d95 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	0f 84 a9 03 00 00    	je     80112c <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800d83:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800d8d:	89 04 24             	mov    %eax,(%esp)
  800d90:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d93:	89 fb                	mov    %edi,%ebx
  800d95:	8d 7b 01             	lea    0x1(%ebx),%edi
  800d98:	0f b6 03             	movzbl (%ebx),%eax
  800d9b:	83 f8 25             	cmp    $0x25,%eax
  800d9e:	75 db                	jne    800d7b <cvprintfmt+0x28>
  800da0:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800da4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800dab:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800db0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800db7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbc:	eb 18                	jmp    800dd6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dbe:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800dc0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800dc4:	eb 10                	jmp    800dd6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dc6:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800dc8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800dcc:	eb 08                	jmp    800dd6 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800dce:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800dd1:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dd6:	8d 5f 01             	lea    0x1(%edi),%ebx
  800dd9:	0f b6 0f             	movzbl (%edi),%ecx
  800ddc:	0f b6 c1             	movzbl %cl,%eax
  800ddf:	83 e9 23             	sub    $0x23,%ecx
  800de2:	80 f9 55             	cmp    $0x55,%cl
  800de5:	0f 87 1f 03 00 00    	ja     80110a <cvprintfmt+0x3b7>
  800deb:	0f b6 c9             	movzbl %cl,%ecx
  800dee:	ff 24 8d b8 1e 80 00 	jmp    *0x801eb8(,%ecx,4)
  800df5:	89 df                	mov    %ebx,%edi
  800df7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800dfc:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  800dff:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800e03:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800e06:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800e09:	83 f9 09             	cmp    $0x9,%ecx
  800e0c:	77 33                	ja     800e41 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800e0e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800e11:	eb e9                	jmp    800dfc <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800e13:	8b 45 14             	mov    0x14(%ebp),%eax
  800e16:	8d 48 04             	lea    0x4(%eax),%ecx
  800e19:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800e1c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e1e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800e20:	eb 1f                	jmp    800e41 <cvprintfmt+0xee>
  800e22:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800e25:	85 ff                	test   %edi,%edi
  800e27:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2c:	0f 49 c7             	cmovns %edi,%eax
  800e2f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e32:	89 df                	mov    %ebx,%edi
  800e34:	eb a0                	jmp    800dd6 <cvprintfmt+0x83>
  800e36:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800e38:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800e3f:	eb 95                	jmp    800dd6 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800e41:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e45:	79 8f                	jns    800dd6 <cvprintfmt+0x83>
  800e47:	eb 85                	jmp    800dce <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800e49:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e4c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800e4e:	66 90                	xchg   %ax,%ax
  800e50:	eb 84                	jmp    800dd6 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800e52:	8b 45 14             	mov    0x14(%ebp),%eax
  800e55:	8d 50 04             	lea    0x4(%eax),%edx
  800e58:	89 55 14             	mov    %edx,0x14(%ebp)
  800e5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e65:	0b 10                	or     (%eax),%edx
  800e67:	89 14 24             	mov    %edx,(%esp)
  800e6a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800e6d:	e9 23 ff ff ff       	jmp    800d95 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800e72:	8b 45 14             	mov    0x14(%ebp),%eax
  800e75:	8d 50 04             	lea    0x4(%eax),%edx
  800e78:	89 55 14             	mov    %edx,0x14(%ebp)
  800e7b:	8b 00                	mov    (%eax),%eax
  800e7d:	99                   	cltd   
  800e7e:	31 d0                	xor    %edx,%eax
  800e80:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800e82:	83 f8 09             	cmp    $0x9,%eax
  800e85:	7f 0b                	jg     800e92 <cvprintfmt+0x13f>
  800e87:	8b 14 85 20 20 80 00 	mov    0x802020(,%eax,4),%edx
  800e8e:	85 d2                	test   %edx,%edx
  800e90:	75 23                	jne    800eb5 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800e92:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e96:	c7 44 24 08 bc 1c 80 	movl   $0x801cbc,0x8(%esp)
  800e9d:	00 
  800e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	89 04 24             	mov    %eax,(%esp)
  800eab:	e8 a7 fa ff ff       	call   800957 <printfmt>
  800eb0:	e9 e0 fe ff ff       	jmp    800d95 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800eb5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eb9:	c7 44 24 08 c5 1c 80 	movl   $0x801cc5,0x8(%esp)
  800ec0:	00 
  800ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	89 04 24             	mov    %eax,(%esp)
  800ece:	e8 84 fa ff ff       	call   800957 <printfmt>
  800ed3:	e9 bd fe ff ff       	jmp    800d95 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ed8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800edb:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800ede:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee1:	8d 48 04             	lea    0x4(%eax),%ecx
  800ee4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800ee7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800ee9:	85 ff                	test   %edi,%edi
  800eeb:	b8 b5 1c 80 00       	mov    $0x801cb5,%eax
  800ef0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800ef3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800ef7:	74 61                	je     800f5a <cvprintfmt+0x207>
  800ef9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800efd:	7e 5b                	jle    800f5a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800eff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f03:	89 3c 24             	mov    %edi,(%esp)
  800f06:	e8 ed 02 00 00       	call   8011f8 <strnlen>
  800f0b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800f0e:	29 c2                	sub    %eax,%edx
  800f10:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800f13:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800f17:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800f1a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800f1d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800f20:	8b 75 08             	mov    0x8(%ebp),%esi
  800f23:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f26:	89 d3                	mov    %edx,%ebx
  800f28:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800f2a:	eb 0f                	jmp    800f3b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800f2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f33:	89 3c 24             	mov    %edi,(%esp)
  800f36:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800f38:	83 eb 01             	sub    $0x1,%ebx
  800f3b:	85 db                	test   %ebx,%ebx
  800f3d:	7f ed                	jg     800f2c <cvprintfmt+0x1d9>
  800f3f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800f42:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800f45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f48:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f4b:	85 d2                	test   %edx,%edx
  800f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f52:	0f 49 c2             	cmovns %edx,%eax
  800f55:	29 c2                	sub    %eax,%edx
  800f57:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800f5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f5d:	83 c8 3f             	or     $0x3f,%eax
  800f60:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f63:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f66:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800f69:	eb 36                	jmp    800fa1 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800f6b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f6f:	74 1d                	je     800f8e <cvprintfmt+0x23b>
  800f71:	0f be d2             	movsbl %dl,%edx
  800f74:	83 ea 20             	sub    $0x20,%edx
  800f77:	83 fa 5e             	cmp    $0x5e,%edx
  800f7a:	76 12                	jbe    800f8e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f83:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f86:	89 04 24             	mov    %eax,(%esp)
  800f89:	ff 55 08             	call   *0x8(%ebp)
  800f8c:	eb 10                	jmp    800f9e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800f8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f91:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f95:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800f98:	89 04 24             	mov    %eax,(%esp)
  800f9b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800f9e:	83 eb 01             	sub    $0x1,%ebx
  800fa1:	83 c7 01             	add    $0x1,%edi
  800fa4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800fa8:	0f be c2             	movsbl %dl,%eax
  800fab:	85 c0                	test   %eax,%eax
  800fad:	74 27                	je     800fd6 <cvprintfmt+0x283>
  800faf:	85 f6                	test   %esi,%esi
  800fb1:	78 b8                	js     800f6b <cvprintfmt+0x218>
  800fb3:	83 ee 01             	sub    $0x1,%esi
  800fb6:	79 b3                	jns    800f6b <cvprintfmt+0x218>
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fc0:	89 c3                	mov    %eax,%ebx
  800fc2:	eb 18                	jmp    800fdc <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800fc4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800fcf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800fd1:	83 eb 01             	sub    $0x1,%ebx
  800fd4:	eb 06                	jmp    800fdc <cvprintfmt+0x289>
  800fd6:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fdc:	85 db                	test   %ebx,%ebx
  800fde:	7f e4                	jg     800fc4 <cvprintfmt+0x271>
  800fe0:	89 75 08             	mov    %esi,0x8(%ebp)
  800fe3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800fe6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe9:	e9 a7 fd ff ff       	jmp    800d95 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800fee:	83 fa 01             	cmp    $0x1,%edx
  800ff1:	7e 10                	jle    801003 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800ff3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff6:	8d 50 08             	lea    0x8(%eax),%edx
  800ff9:	89 55 14             	mov    %edx,0x14(%ebp)
  800ffc:	8b 30                	mov    (%eax),%esi
  800ffe:	8b 78 04             	mov    0x4(%eax),%edi
  801001:	eb 26                	jmp    801029 <cvprintfmt+0x2d6>
	else if (lflag)
  801003:	85 d2                	test   %edx,%edx
  801005:	74 12                	je     801019 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  801007:	8b 45 14             	mov    0x14(%ebp),%eax
  80100a:	8d 50 04             	lea    0x4(%eax),%edx
  80100d:	89 55 14             	mov    %edx,0x14(%ebp)
  801010:	8b 30                	mov    (%eax),%esi
  801012:	89 f7                	mov    %esi,%edi
  801014:	c1 ff 1f             	sar    $0x1f,%edi
  801017:	eb 10                	jmp    801029 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  801019:	8b 45 14             	mov    0x14(%ebp),%eax
  80101c:	8d 50 04             	lea    0x4(%eax),%edx
  80101f:	89 55 14             	mov    %edx,0x14(%ebp)
  801022:	8b 30                	mov    (%eax),%esi
  801024:	89 f7                	mov    %esi,%edi
  801026:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801029:	89 f0                	mov    %esi,%eax
  80102b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80102d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801032:	85 ff                	test   %edi,%edi
  801034:	0f 89 8e 00 00 00    	jns    8010c8 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  80103a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801041:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801044:	83 c8 2d             	or     $0x2d,%eax
  801047:	89 04 24             	mov    %eax,(%esp)
  80104a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80104d:	89 f0                	mov    %esi,%eax
  80104f:	89 fa                	mov    %edi,%edx
  801051:	f7 d8                	neg    %eax
  801053:	83 d2 00             	adc    $0x0,%edx
  801056:	f7 da                	neg    %edx
			}
			base = 10;
  801058:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80105d:	eb 69                	jmp    8010c8 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80105f:	8d 45 14             	lea    0x14(%ebp),%eax
  801062:	e8 99 f8 ff ff       	call   800900 <getuint>
			base = 10;
  801067:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80106c:	eb 5a                	jmp    8010c8 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80106e:	8d 45 14             	lea    0x14(%ebp),%eax
  801071:	e8 8a f8 ff ff       	call   800900 <getuint>
			base = 8 ;
  801076:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  80107b:	eb 4b                	jmp    8010c8 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  80107d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801080:	89 44 24 04          	mov    %eax,0x4(%esp)
  801084:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801087:	89 f0                	mov    %esi,%eax
  801089:	83 c8 30             	or     $0x30,%eax
  80108c:	89 04 24             	mov    %eax,(%esp)
  80108f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  801092:	8b 45 0c             	mov    0xc(%ebp),%eax
  801095:	89 44 24 04          	mov    %eax,0x4(%esp)
  801099:	89 f0                	mov    %esi,%eax
  80109b:	83 c8 78             	or     $0x78,%eax
  80109e:	89 04 24             	mov    %eax,(%esp)
  8010a1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8010a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8010a7:	8d 50 04             	lea    0x4(%eax),%edx
  8010aa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  8010ad:	8b 00                	mov    (%eax),%eax
  8010af:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8010b4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8010b9:	eb 0d                	jmp    8010c8 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8010bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8010be:	e8 3d f8 ff ff       	call   800900 <getuint>
			base = 16;
  8010c3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  8010c8:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8010cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010d0:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8010d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010db:	89 04 24             	mov    %eax,(%esp)
  8010de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010eb:	e8 0f f7 ff ff       	call   8007ff <cprintnum>
			break;
  8010f0:	e9 a0 fc ff ff       	jmp    800d95 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  8010f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010fc:	0b 45 e4             	or     -0x1c(%ebp),%eax
  8010ff:	89 04 24             	mov    %eax,(%esp)
  801102:	ff 55 08             	call   *0x8(%ebp)
			break;
  801105:	e9 8b fc ff ff       	jmp    800d95 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  80110a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801111:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801114:	89 04 24             	mov    %eax,(%esp)
  801117:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80111a:	89 fb                	mov    %edi,%ebx
  80111c:	eb 03                	jmp    801121 <cvprintfmt+0x3ce>
  80111e:	83 eb 01             	sub    $0x1,%ebx
  801121:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801125:	75 f7                	jne    80111e <cvprintfmt+0x3cb>
  801127:	e9 69 fc ff ff       	jmp    800d95 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  80112c:	83 c4 3c             	add    $0x3c,%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80113a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  80113d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801141:	8b 45 10             	mov    0x10(%ebp),%eax
  801144:	89 44 24 08          	mov    %eax,0x8(%esp)
  801148:	8b 45 0c             	mov    0xc(%ebp),%eax
  80114b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	89 04 24             	mov    %eax,(%esp)
  801155:	e8 f9 fb ff ff       	call   800d53 <cvprintfmt>
	va_end(ap);
}
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    

0080115c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 28             	sub    $0x28,%esp
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801168:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80116b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80116f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801172:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801179:	85 c0                	test   %eax,%eax
  80117b:	74 30                	je     8011ad <vsnprintf+0x51>
  80117d:	85 d2                	test   %edx,%edx
  80117f:	7e 2c                	jle    8011ad <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801181:	8b 45 14             	mov    0x14(%ebp),%eax
  801184:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801188:	8b 45 10             	mov    0x10(%ebp),%eax
  80118b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801192:	89 44 24 04          	mov    %eax,0x4(%esp)
  801196:	c7 04 24 3a 09 80 00 	movl   $0x80093a,(%esp)
  80119d:	e8 dd f7 ff ff       	call   80097f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8011a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8011a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ab:	eb 05                	jmp    8011b2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8011ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8011ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8011bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	89 04 24             	mov    %eax,(%esp)
  8011d5:	e8 82 ff ff ff       	call   80115c <vsnprintf>
	va_end(ap);

	return rc;
}
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    
  8011dc:	66 90                	xchg   %ax,%ax
  8011de:	66 90                	xchg   %ax,%ax

008011e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	eb 03                	jmp    8011f0 <strlen+0x10>
		n++;
  8011ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011f4:	75 f7                	jne    8011ed <strlen+0xd>
		n++;
	return n;
}
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801201:	b8 00 00 00 00       	mov    $0x0,%eax
  801206:	eb 03                	jmp    80120b <strnlen+0x13>
		n++;
  801208:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80120b:	39 d0                	cmp    %edx,%eax
  80120d:	74 06                	je     801215 <strnlen+0x1d>
  80120f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801213:	75 f3                	jne    801208 <strnlen+0x10>
		n++;
	return n;
}
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	53                   	push   %ebx
  80121b:	8b 45 08             	mov    0x8(%ebp),%eax
  80121e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801221:	89 c2                	mov    %eax,%edx
  801223:	83 c2 01             	add    $0x1,%edx
  801226:	83 c1 01             	add    $0x1,%ecx
  801229:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80122d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801230:	84 db                	test   %bl,%bl
  801232:	75 ef                	jne    801223 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801234:	5b                   	pop    %ebx
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	53                   	push   %ebx
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801241:	89 1c 24             	mov    %ebx,(%esp)
  801244:	e8 97 ff ff ff       	call   8011e0 <strlen>
	strcpy(dst + len, src);
  801249:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801250:	01 d8                	add    %ebx,%eax
  801252:	89 04 24             	mov    %eax,(%esp)
  801255:	e8 bd ff ff ff       	call   801217 <strcpy>
	return dst;
}
  80125a:	89 d8                	mov    %ebx,%eax
  80125c:	83 c4 08             	add    $0x8,%esp
  80125f:	5b                   	pop    %ebx
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	56                   	push   %esi
  801266:	53                   	push   %ebx
  801267:	8b 75 08             	mov    0x8(%ebp),%esi
  80126a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126d:	89 f3                	mov    %esi,%ebx
  80126f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801272:	89 f2                	mov    %esi,%edx
  801274:	eb 0f                	jmp    801285 <strncpy+0x23>
		*dst++ = *src;
  801276:	83 c2 01             	add    $0x1,%edx
  801279:	0f b6 01             	movzbl (%ecx),%eax
  80127c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80127f:	80 39 01             	cmpb   $0x1,(%ecx)
  801282:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801285:	39 da                	cmp    %ebx,%edx
  801287:	75 ed                	jne    801276 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801289:	89 f0                	mov    %esi,%eax
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
  801294:	8b 75 08             	mov    0x8(%ebp),%esi
  801297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80129d:	89 f0                	mov    %esi,%eax
  80129f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8012a3:	85 c9                	test   %ecx,%ecx
  8012a5:	75 0b                	jne    8012b2 <strlcpy+0x23>
  8012a7:	eb 1d                	jmp    8012c6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8012a9:	83 c0 01             	add    $0x1,%eax
  8012ac:	83 c2 01             	add    $0x1,%edx
  8012af:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8012b2:	39 d8                	cmp    %ebx,%eax
  8012b4:	74 0b                	je     8012c1 <strlcpy+0x32>
  8012b6:	0f b6 0a             	movzbl (%edx),%ecx
  8012b9:	84 c9                	test   %cl,%cl
  8012bb:	75 ec                	jne    8012a9 <strlcpy+0x1a>
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	eb 02                	jmp    8012c3 <strlcpy+0x34>
  8012c1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8012c3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8012c6:	29 f0                	sub    %esi,%eax
}
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012d5:	eb 06                	jmp    8012dd <strcmp+0x11>
		p++, q++;
  8012d7:	83 c1 01             	add    $0x1,%ecx
  8012da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012dd:	0f b6 01             	movzbl (%ecx),%eax
  8012e0:	84 c0                	test   %al,%al
  8012e2:	74 04                	je     8012e8 <strcmp+0x1c>
  8012e4:	3a 02                	cmp    (%edx),%al
  8012e6:	74 ef                	je     8012d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012e8:	0f b6 c0             	movzbl %al,%eax
  8012eb:	0f b6 12             	movzbl (%edx),%edx
  8012ee:	29 d0                	sub    %edx,%eax
}
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	53                   	push   %ebx
  8012f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fc:	89 c3                	mov    %eax,%ebx
  8012fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801301:	eb 06                	jmp    801309 <strncmp+0x17>
		n--, p++, q++;
  801303:	83 c0 01             	add    $0x1,%eax
  801306:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801309:	39 d8                	cmp    %ebx,%eax
  80130b:	74 15                	je     801322 <strncmp+0x30>
  80130d:	0f b6 08             	movzbl (%eax),%ecx
  801310:	84 c9                	test   %cl,%cl
  801312:	74 04                	je     801318 <strncmp+0x26>
  801314:	3a 0a                	cmp    (%edx),%cl
  801316:	74 eb                	je     801303 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801318:	0f b6 00             	movzbl (%eax),%eax
  80131b:	0f b6 12             	movzbl (%edx),%edx
  80131e:	29 d0                	sub    %edx,%eax
  801320:	eb 05                	jmp    801327 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801322:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801327:	5b                   	pop    %ebx
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
  801330:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801334:	eb 07                	jmp    80133d <strchr+0x13>
		if (*s == c)
  801336:	38 ca                	cmp    %cl,%dl
  801338:	74 0f                	je     801349 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80133a:	83 c0 01             	add    $0x1,%eax
  80133d:	0f b6 10             	movzbl (%eax),%edx
  801340:	84 d2                	test   %dl,%dl
  801342:	75 f2                	jne    801336 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801344:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	8b 45 08             	mov    0x8(%ebp),%eax
  801351:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801355:	eb 07                	jmp    80135e <strfind+0x13>
		if (*s == c)
  801357:	38 ca                	cmp    %cl,%dl
  801359:	74 0a                	je     801365 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80135b:	83 c0 01             	add    $0x1,%eax
  80135e:	0f b6 10             	movzbl (%eax),%edx
  801361:	84 d2                	test   %dl,%dl
  801363:	75 f2                	jne    801357 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	57                   	push   %edi
  80136b:	56                   	push   %esi
  80136c:	53                   	push   %ebx
  80136d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801370:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801373:	85 c9                	test   %ecx,%ecx
  801375:	74 36                	je     8013ad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801377:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80137d:	75 28                	jne    8013a7 <memset+0x40>
  80137f:	f6 c1 03             	test   $0x3,%cl
  801382:	75 23                	jne    8013a7 <memset+0x40>
		c &= 0xFF;
  801384:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801388:	89 d3                	mov    %edx,%ebx
  80138a:	c1 e3 08             	shl    $0x8,%ebx
  80138d:	89 d6                	mov    %edx,%esi
  80138f:	c1 e6 18             	shl    $0x18,%esi
  801392:	89 d0                	mov    %edx,%eax
  801394:	c1 e0 10             	shl    $0x10,%eax
  801397:	09 f0                	or     %esi,%eax
  801399:	09 c2                	or     %eax,%edx
  80139b:	89 d0                	mov    %edx,%eax
  80139d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80139f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8013a2:	fc                   	cld    
  8013a3:	f3 ab                	rep stos %eax,%es:(%edi)
  8013a5:	eb 06                	jmp    8013ad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8013a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013aa:	fc                   	cld    
  8013ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013ad:	89 f8                	mov    %edi,%eax
  8013af:	5b                   	pop    %ebx
  8013b0:	5e                   	pop    %esi
  8013b1:	5f                   	pop    %edi
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	57                   	push   %edi
  8013b8:	56                   	push   %esi
  8013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013c2:	39 c6                	cmp    %eax,%esi
  8013c4:	73 35                	jae    8013fb <memmove+0x47>
  8013c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013c9:	39 d0                	cmp    %edx,%eax
  8013cb:	73 2e                	jae    8013fb <memmove+0x47>
		s += n;
		d += n;
  8013cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8013d0:	89 d6                	mov    %edx,%esi
  8013d2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013da:	75 13                	jne    8013ef <memmove+0x3b>
  8013dc:	f6 c1 03             	test   $0x3,%cl
  8013df:	75 0e                	jne    8013ef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8013e1:	83 ef 04             	sub    $0x4,%edi
  8013e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013e7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8013ea:	fd                   	std    
  8013eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013ed:	eb 09                	jmp    8013f8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8013ef:	83 ef 01             	sub    $0x1,%edi
  8013f2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8013f5:	fd                   	std    
  8013f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013f8:	fc                   	cld    
  8013f9:	eb 1d                	jmp    801418 <memmove+0x64>
  8013fb:	89 f2                	mov    %esi,%edx
  8013fd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013ff:	f6 c2 03             	test   $0x3,%dl
  801402:	75 0f                	jne    801413 <memmove+0x5f>
  801404:	f6 c1 03             	test   $0x3,%cl
  801407:	75 0a                	jne    801413 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801409:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80140c:	89 c7                	mov    %eax,%edi
  80140e:	fc                   	cld    
  80140f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801411:	eb 05                	jmp    801418 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801413:	89 c7                	mov    %eax,%edi
  801415:	fc                   	cld    
  801416:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801418:	5e                   	pop    %esi
  801419:	5f                   	pop    %edi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801422:	8b 45 10             	mov    0x10(%ebp),%eax
  801425:	89 44 24 08          	mov    %eax,0x8(%esp)
  801429:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	89 04 24             	mov    %eax,(%esp)
  801436:	e8 79 ff ff ff       	call   8013b4 <memmove>
}
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	56                   	push   %esi
  801441:	53                   	push   %ebx
  801442:	8b 55 08             	mov    0x8(%ebp),%edx
  801445:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801448:	89 d6                	mov    %edx,%esi
  80144a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80144d:	eb 1a                	jmp    801469 <memcmp+0x2c>
		if (*s1 != *s2)
  80144f:	0f b6 02             	movzbl (%edx),%eax
  801452:	0f b6 19             	movzbl (%ecx),%ebx
  801455:	38 d8                	cmp    %bl,%al
  801457:	74 0a                	je     801463 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801459:	0f b6 c0             	movzbl %al,%eax
  80145c:	0f b6 db             	movzbl %bl,%ebx
  80145f:	29 d8                	sub    %ebx,%eax
  801461:	eb 0f                	jmp    801472 <memcmp+0x35>
		s1++, s2++;
  801463:	83 c2 01             	add    $0x1,%edx
  801466:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801469:	39 f2                	cmp    %esi,%edx
  80146b:	75 e2                	jne    80144f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80146d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801472:	5b                   	pop    %ebx
  801473:	5e                   	pop    %esi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80147f:	89 c2                	mov    %eax,%edx
  801481:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801484:	eb 07                	jmp    80148d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801486:	38 08                	cmp    %cl,(%eax)
  801488:	74 07                	je     801491 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80148a:	83 c0 01             	add    $0x1,%eax
  80148d:	39 d0                	cmp    %edx,%eax
  80148f:	72 f5                	jb     801486 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	57                   	push   %edi
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
  801499:	8b 55 08             	mov    0x8(%ebp),%edx
  80149c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80149f:	eb 03                	jmp    8014a4 <strtol+0x11>
		s++;
  8014a1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014a4:	0f b6 0a             	movzbl (%edx),%ecx
  8014a7:	80 f9 09             	cmp    $0x9,%cl
  8014aa:	74 f5                	je     8014a1 <strtol+0xe>
  8014ac:	80 f9 20             	cmp    $0x20,%cl
  8014af:	74 f0                	je     8014a1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8014b1:	80 f9 2b             	cmp    $0x2b,%cl
  8014b4:	75 0a                	jne    8014c0 <strtol+0x2d>
		s++;
  8014b6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8014b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8014be:	eb 11                	jmp    8014d1 <strtol+0x3e>
  8014c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8014c5:	80 f9 2d             	cmp    $0x2d,%cl
  8014c8:	75 07                	jne    8014d1 <strtol+0x3e>
		s++, neg = 1;
  8014ca:	8d 52 01             	lea    0x1(%edx),%edx
  8014cd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014d1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  8014d6:	75 15                	jne    8014ed <strtol+0x5a>
  8014d8:	80 3a 30             	cmpb   $0x30,(%edx)
  8014db:	75 10                	jne    8014ed <strtol+0x5a>
  8014dd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8014e1:	75 0a                	jne    8014ed <strtol+0x5a>
		s += 2, base = 16;
  8014e3:	83 c2 02             	add    $0x2,%edx
  8014e6:	b8 10 00 00 00       	mov    $0x10,%eax
  8014eb:	eb 10                	jmp    8014fd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	75 0c                	jne    8014fd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014f1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014f3:	80 3a 30             	cmpb   $0x30,(%edx)
  8014f6:	75 05                	jne    8014fd <strtol+0x6a>
		s++, base = 8;
  8014f8:	83 c2 01             	add    $0x1,%edx
  8014fb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  8014fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801502:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801505:	0f b6 0a             	movzbl (%edx),%ecx
  801508:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80150b:	89 f0                	mov    %esi,%eax
  80150d:	3c 09                	cmp    $0x9,%al
  80150f:	77 08                	ja     801519 <strtol+0x86>
			dig = *s - '0';
  801511:	0f be c9             	movsbl %cl,%ecx
  801514:	83 e9 30             	sub    $0x30,%ecx
  801517:	eb 20                	jmp    801539 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801519:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80151c:	89 f0                	mov    %esi,%eax
  80151e:	3c 19                	cmp    $0x19,%al
  801520:	77 08                	ja     80152a <strtol+0x97>
			dig = *s - 'a' + 10;
  801522:	0f be c9             	movsbl %cl,%ecx
  801525:	83 e9 57             	sub    $0x57,%ecx
  801528:	eb 0f                	jmp    801539 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80152a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80152d:	89 f0                	mov    %esi,%eax
  80152f:	3c 19                	cmp    $0x19,%al
  801531:	77 16                	ja     801549 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801533:	0f be c9             	movsbl %cl,%ecx
  801536:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801539:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80153c:	7d 0f                	jge    80154d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80153e:	83 c2 01             	add    $0x1,%edx
  801541:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801545:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801547:	eb bc                	jmp    801505 <strtol+0x72>
  801549:	89 d8                	mov    %ebx,%eax
  80154b:	eb 02                	jmp    80154f <strtol+0xbc>
  80154d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80154f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801553:	74 05                	je     80155a <strtol+0xc7>
		*endptr = (char *) s;
  801555:	8b 75 0c             	mov    0xc(%ebp),%esi
  801558:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80155a:	f7 d8                	neg    %eax
  80155c:	85 ff                	test   %edi,%edi
  80155e:	0f 44 c3             	cmove  %ebx,%eax
}
  801561:	5b                   	pop    %ebx
  801562:	5e                   	pop    %esi
  801563:	5f                   	pop    %edi
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	57                   	push   %edi
  80156a:	56                   	push   %esi
  80156b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80156c:	b8 00 00 00 00       	mov    $0x0,%eax
  801571:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801574:	8b 55 08             	mov    0x8(%ebp),%edx
  801577:	89 c3                	mov    %eax,%ebx
  801579:	89 c7                	mov    %eax,%edi
  80157b:	89 c6                	mov    %eax,%esi
  80157d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80157f:	5b                   	pop    %ebx
  801580:	5e                   	pop    %esi
  801581:	5f                   	pop    %edi
  801582:	5d                   	pop    %ebp
  801583:	c3                   	ret    

00801584 <sys_cgetc>:

int
sys_cgetc(void)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	57                   	push   %edi
  801588:	56                   	push   %esi
  801589:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80158a:	ba 00 00 00 00       	mov    $0x0,%edx
  80158f:	b8 01 00 00 00       	mov    $0x1,%eax
  801594:	89 d1                	mov    %edx,%ecx
  801596:	89 d3                	mov    %edx,%ebx
  801598:	89 d7                	mov    %edx,%edi
  80159a:	89 d6                	mov    %edx,%esi
  80159c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5f                   	pop    %edi
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    

008015a3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	57                   	push   %edi
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015b1:	b8 03 00 00 00       	mov    $0x3,%eax
  8015b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b9:	89 cb                	mov    %ecx,%ebx
  8015bb:	89 cf                	mov    %ecx,%edi
  8015bd:	89 ce                	mov    %ecx,%esi
  8015bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	7e 28                	jle    8015ed <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015c9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8015d0:	00 
  8015d1:	c7 44 24 08 48 20 80 	movl   $0x802048,0x8(%esp)
  8015d8:	00 
  8015d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015e0:	00 
  8015e1:	c7 04 24 65 20 80 00 	movl   $0x802065,(%esp)
  8015e8:	e8 04 f0 ff ff       	call   8005f1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015ed:	83 c4 2c             	add    $0x2c,%esp
  8015f0:	5b                   	pop    %ebx
  8015f1:	5e                   	pop    %esi
  8015f2:	5f                   	pop    %edi
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    

008015f5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	57                   	push   %edi
  8015f9:	56                   	push   %esi
  8015fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801600:	b8 02 00 00 00       	mov    $0x2,%eax
  801605:	89 d1                	mov    %edx,%ecx
  801607:	89 d3                	mov    %edx,%ebx
  801609:	89 d7                	mov    %edx,%edi
  80160b:	89 d6                	mov    %edx,%esi
  80160d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5f                   	pop    %edi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <sys_yield>:

void
sys_yield(void)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	57                   	push   %edi
  801618:	56                   	push   %esi
  801619:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80161a:	ba 00 00 00 00       	mov    $0x0,%edx
  80161f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801624:	89 d1                	mov    %edx,%ecx
  801626:	89 d3                	mov    %edx,%ebx
  801628:	89 d7                	mov    %edx,%edi
  80162a:	89 d6                	mov    %edx,%esi
  80162c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80162e:	5b                   	pop    %ebx
  80162f:	5e                   	pop    %esi
  801630:	5f                   	pop    %edi
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	57                   	push   %edi
  801637:	56                   	push   %esi
  801638:	53                   	push   %ebx
  801639:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80163c:	be 00 00 00 00       	mov    $0x0,%esi
  801641:	b8 04 00 00 00       	mov    $0x4,%eax
  801646:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801649:	8b 55 08             	mov    0x8(%ebp),%edx
  80164c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80164f:	89 f7                	mov    %esi,%edi
  801651:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801653:	85 c0                	test   %eax,%eax
  801655:	7e 28                	jle    80167f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801657:	89 44 24 10          	mov    %eax,0x10(%esp)
  80165b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801662:	00 
  801663:	c7 44 24 08 48 20 80 	movl   $0x802048,0x8(%esp)
  80166a:	00 
  80166b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801672:	00 
  801673:	c7 04 24 65 20 80 00 	movl   $0x802065,(%esp)
  80167a:	e8 72 ef ff ff       	call   8005f1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80167f:	83 c4 2c             	add    $0x2c,%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5f                   	pop    %edi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	57                   	push   %edi
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801690:	b8 05 00 00 00       	mov    $0x5,%eax
  801695:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801698:	8b 55 08             	mov    0x8(%ebp),%edx
  80169b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80169e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016a1:	8b 75 18             	mov    0x18(%ebp),%esi
  8016a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	7e 28                	jle    8016d2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8016b5:	00 
  8016b6:	c7 44 24 08 48 20 80 	movl   $0x802048,0x8(%esp)
  8016bd:	00 
  8016be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016c5:	00 
  8016c6:	c7 04 24 65 20 80 00 	movl   $0x802065,(%esp)
  8016cd:	e8 1f ef ff ff       	call   8005f1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8016d2:	83 c4 2c             	add    $0x2c,%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5f                   	pop    %edi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	57                   	push   %edi
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f3:	89 df                	mov    %ebx,%edi
  8016f5:	89 de                	mov    %ebx,%esi
  8016f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	7e 28                	jle    801725 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801701:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801708:	00 
  801709:	c7 44 24 08 48 20 80 	movl   $0x802048,0x8(%esp)
  801710:	00 
  801711:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801718:	00 
  801719:	c7 04 24 65 20 80 00 	movl   $0x802065,(%esp)
  801720:	e8 cc ee ff ff       	call   8005f1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801725:	83 c4 2c             	add    $0x2c,%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5f                   	pop    %edi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	57                   	push   %edi
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
  801733:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801736:	bb 00 00 00 00       	mov    $0x0,%ebx
  80173b:	b8 08 00 00 00       	mov    $0x8,%eax
  801740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801743:	8b 55 08             	mov    0x8(%ebp),%edx
  801746:	89 df                	mov    %ebx,%edi
  801748:	89 de                	mov    %ebx,%esi
  80174a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80174c:	85 c0                	test   %eax,%eax
  80174e:	7e 28                	jle    801778 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801750:	89 44 24 10          	mov    %eax,0x10(%esp)
  801754:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80175b:	00 
  80175c:	c7 44 24 08 48 20 80 	movl   $0x802048,0x8(%esp)
  801763:	00 
  801764:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80176b:	00 
  80176c:	c7 04 24 65 20 80 00 	movl   $0x802065,(%esp)
  801773:	e8 79 ee ff ff       	call   8005f1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801778:	83 c4 2c             	add    $0x2c,%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5f                   	pop    %edi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	57                   	push   %edi
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801789:	bb 00 00 00 00       	mov    $0x0,%ebx
  80178e:	b8 09 00 00 00       	mov    $0x9,%eax
  801793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801796:	8b 55 08             	mov    0x8(%ebp),%edx
  801799:	89 df                	mov    %ebx,%edi
  80179b:	89 de                	mov    %ebx,%esi
  80179d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	7e 28                	jle    8017cb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017a7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8017ae:	00 
  8017af:	c7 44 24 08 48 20 80 	movl   $0x802048,0x8(%esp)
  8017b6:	00 
  8017b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017be:	00 
  8017bf:	c7 04 24 65 20 80 00 	movl   $0x802065,(%esp)
  8017c6:	e8 26 ee ff ff       	call   8005f1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8017cb:	83 c4 2c             	add    $0x2c,%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5e                   	pop    %esi
  8017d0:	5f                   	pop    %edi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	57                   	push   %edi
  8017d7:	56                   	push   %esi
  8017d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017d9:	be 00 00 00 00       	mov    $0x0,%esi
  8017de:	b8 0b 00 00 00       	mov    $0xb,%eax
  8017e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017ec:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017ef:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017f1:	5b                   	pop    %ebx
  8017f2:	5e                   	pop    %esi
  8017f3:	5f                   	pop    %edi
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    

008017f6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	57                   	push   %edi
  8017fa:	56                   	push   %esi
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801804:	b8 0c 00 00 00       	mov    $0xc,%eax
  801809:	8b 55 08             	mov    0x8(%ebp),%edx
  80180c:	89 cb                	mov    %ecx,%ebx
  80180e:	89 cf                	mov    %ecx,%edi
  801810:	89 ce                	mov    %ecx,%esi
  801812:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801814:	85 c0                	test   %eax,%eax
  801816:	7e 28                	jle    801840 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801818:	89 44 24 10          	mov    %eax,0x10(%esp)
  80181c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801823:	00 
  801824:	c7 44 24 08 48 20 80 	movl   $0x802048,0x8(%esp)
  80182b:	00 
  80182c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801833:	00 
  801834:	c7 04 24 65 20 80 00 	movl   $0x802065,(%esp)
  80183b:	e8 b1 ed ff ff       	call   8005f1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801840:	83 c4 2c             	add    $0x2c,%esp
  801843:	5b                   	pop    %ebx
  801844:	5e                   	pop    %esi
  801845:	5f                   	pop    %edi
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80184e:	83 3d d0 30 80 00 00 	cmpl   $0x0,0x8030d0
  801855:	75 32                	jne    801889 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  801857:	e8 99 fd ff ff       	call   8015f5 <sys_getenvid>
  80185c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801863:	00 
  801864:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80186b:	ee 
  80186c:	89 04 24             	mov    %eax,(%esp)
  80186f:	e8 bf fd ff ff       	call   801633 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  801874:	e8 7c fd ff ff       	call   8015f5 <sys_getenvid>
  801879:	c7 44 24 04 93 18 80 	movl   $0x801893,0x4(%esp)
  801880:	00 
  801881:	89 04 24             	mov    %eax,(%esp)
  801884:	e8 f7 fe ff ff       	call   801780 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	a3 d0 30 80 00       	mov    %eax,0x8030d0
}
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801893:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801894:	a1 d0 30 80 00       	mov    0x8030d0,%eax
	call *%eax
  801899:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80189b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  80189e:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  8018a1:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  8018a5:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  8018a9:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  8018ac:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  8018b0:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  8018b2:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  8018b3:	83 c4 04             	add    $0x4,%esp
	popfl 	
  8018b6:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8018b7:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8018b8:	c3                   	ret    
  8018b9:	66 90                	xchg   %ax,%ax
  8018bb:	66 90                	xchg   %ax,%ax
  8018bd:	66 90                	xchg   %ax,%ax
  8018bf:	90                   	nop

008018c0 <__udivdi3>:
  8018c0:	55                   	push   %ebp
  8018c1:	57                   	push   %edi
  8018c2:	56                   	push   %esi
  8018c3:	83 ec 0c             	sub    $0xc,%esp
  8018c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8018ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8018ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8018d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018dc:	89 ea                	mov    %ebp,%edx
  8018de:	89 0c 24             	mov    %ecx,(%esp)
  8018e1:	75 2d                	jne    801910 <__udivdi3+0x50>
  8018e3:	39 e9                	cmp    %ebp,%ecx
  8018e5:	77 61                	ja     801948 <__udivdi3+0x88>
  8018e7:	85 c9                	test   %ecx,%ecx
  8018e9:	89 ce                	mov    %ecx,%esi
  8018eb:	75 0b                	jne    8018f8 <__udivdi3+0x38>
  8018ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f2:	31 d2                	xor    %edx,%edx
  8018f4:	f7 f1                	div    %ecx
  8018f6:	89 c6                	mov    %eax,%esi
  8018f8:	31 d2                	xor    %edx,%edx
  8018fa:	89 e8                	mov    %ebp,%eax
  8018fc:	f7 f6                	div    %esi
  8018fe:	89 c5                	mov    %eax,%ebp
  801900:	89 f8                	mov    %edi,%eax
  801902:	f7 f6                	div    %esi
  801904:	89 ea                	mov    %ebp,%edx
  801906:	83 c4 0c             	add    $0xc,%esp
  801909:	5e                   	pop    %esi
  80190a:	5f                   	pop    %edi
  80190b:	5d                   	pop    %ebp
  80190c:	c3                   	ret    
  80190d:	8d 76 00             	lea    0x0(%esi),%esi
  801910:	39 e8                	cmp    %ebp,%eax
  801912:	77 24                	ja     801938 <__udivdi3+0x78>
  801914:	0f bd e8             	bsr    %eax,%ebp
  801917:	83 f5 1f             	xor    $0x1f,%ebp
  80191a:	75 3c                	jne    801958 <__udivdi3+0x98>
  80191c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801920:	39 34 24             	cmp    %esi,(%esp)
  801923:	0f 86 9f 00 00 00    	jbe    8019c8 <__udivdi3+0x108>
  801929:	39 d0                	cmp    %edx,%eax
  80192b:	0f 82 97 00 00 00    	jb     8019c8 <__udivdi3+0x108>
  801931:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801938:	31 d2                	xor    %edx,%edx
  80193a:	31 c0                	xor    %eax,%eax
  80193c:	83 c4 0c             	add    $0xc,%esp
  80193f:	5e                   	pop    %esi
  801940:	5f                   	pop    %edi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    
  801943:	90                   	nop
  801944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801948:	89 f8                	mov    %edi,%eax
  80194a:	f7 f1                	div    %ecx
  80194c:	31 d2                	xor    %edx,%edx
  80194e:	83 c4 0c             	add    $0xc,%esp
  801951:	5e                   	pop    %esi
  801952:	5f                   	pop    %edi
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    
  801955:	8d 76 00             	lea    0x0(%esi),%esi
  801958:	89 e9                	mov    %ebp,%ecx
  80195a:	8b 3c 24             	mov    (%esp),%edi
  80195d:	d3 e0                	shl    %cl,%eax
  80195f:	89 c6                	mov    %eax,%esi
  801961:	b8 20 00 00 00       	mov    $0x20,%eax
  801966:	29 e8                	sub    %ebp,%eax
  801968:	89 c1                	mov    %eax,%ecx
  80196a:	d3 ef                	shr    %cl,%edi
  80196c:	89 e9                	mov    %ebp,%ecx
  80196e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801972:	8b 3c 24             	mov    (%esp),%edi
  801975:	09 74 24 08          	or     %esi,0x8(%esp)
  801979:	89 d6                	mov    %edx,%esi
  80197b:	d3 e7                	shl    %cl,%edi
  80197d:	89 c1                	mov    %eax,%ecx
  80197f:	89 3c 24             	mov    %edi,(%esp)
  801982:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801986:	d3 ee                	shr    %cl,%esi
  801988:	89 e9                	mov    %ebp,%ecx
  80198a:	d3 e2                	shl    %cl,%edx
  80198c:	89 c1                	mov    %eax,%ecx
  80198e:	d3 ef                	shr    %cl,%edi
  801990:	09 d7                	or     %edx,%edi
  801992:	89 f2                	mov    %esi,%edx
  801994:	89 f8                	mov    %edi,%eax
  801996:	f7 74 24 08          	divl   0x8(%esp)
  80199a:	89 d6                	mov    %edx,%esi
  80199c:	89 c7                	mov    %eax,%edi
  80199e:	f7 24 24             	mull   (%esp)
  8019a1:	39 d6                	cmp    %edx,%esi
  8019a3:	89 14 24             	mov    %edx,(%esp)
  8019a6:	72 30                	jb     8019d8 <__udivdi3+0x118>
  8019a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8019ac:	89 e9                	mov    %ebp,%ecx
  8019ae:	d3 e2                	shl    %cl,%edx
  8019b0:	39 c2                	cmp    %eax,%edx
  8019b2:	73 05                	jae    8019b9 <__udivdi3+0xf9>
  8019b4:	3b 34 24             	cmp    (%esp),%esi
  8019b7:	74 1f                	je     8019d8 <__udivdi3+0x118>
  8019b9:	89 f8                	mov    %edi,%eax
  8019bb:	31 d2                	xor    %edx,%edx
  8019bd:	e9 7a ff ff ff       	jmp    80193c <__udivdi3+0x7c>
  8019c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8019c8:	31 d2                	xor    %edx,%edx
  8019ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cf:	e9 68 ff ff ff       	jmp    80193c <__udivdi3+0x7c>
  8019d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8019db:	31 d2                	xor    %edx,%edx
  8019dd:	83 c4 0c             	add    $0xc,%esp
  8019e0:	5e                   	pop    %esi
  8019e1:	5f                   	pop    %edi
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    
  8019e4:	66 90                	xchg   %ax,%ax
  8019e6:	66 90                	xchg   %ax,%ax
  8019e8:	66 90                	xchg   %ax,%ax
  8019ea:	66 90                	xchg   %ax,%ax
  8019ec:	66 90                	xchg   %ax,%ax
  8019ee:	66 90                	xchg   %ax,%ax

008019f0 <__umoddi3>:
  8019f0:	55                   	push   %ebp
  8019f1:	57                   	push   %edi
  8019f2:	56                   	push   %esi
  8019f3:	83 ec 14             	sub    $0x14,%esp
  8019f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8019fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8019fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801a02:	89 c7                	mov    %eax,%edi
  801a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a08:	8b 44 24 30          	mov    0x30(%esp),%eax
  801a0c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801a10:	89 34 24             	mov    %esi,(%esp)
  801a13:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a17:	85 c0                	test   %eax,%eax
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a1f:	75 17                	jne    801a38 <__umoddi3+0x48>
  801a21:	39 fe                	cmp    %edi,%esi
  801a23:	76 4b                	jbe    801a70 <__umoddi3+0x80>
  801a25:	89 c8                	mov    %ecx,%eax
  801a27:	89 fa                	mov    %edi,%edx
  801a29:	f7 f6                	div    %esi
  801a2b:	89 d0                	mov    %edx,%eax
  801a2d:	31 d2                	xor    %edx,%edx
  801a2f:	83 c4 14             	add    $0x14,%esp
  801a32:	5e                   	pop    %esi
  801a33:	5f                   	pop    %edi
  801a34:	5d                   	pop    %ebp
  801a35:	c3                   	ret    
  801a36:	66 90                	xchg   %ax,%ax
  801a38:	39 f8                	cmp    %edi,%eax
  801a3a:	77 54                	ja     801a90 <__umoddi3+0xa0>
  801a3c:	0f bd e8             	bsr    %eax,%ebp
  801a3f:	83 f5 1f             	xor    $0x1f,%ebp
  801a42:	75 5c                	jne    801aa0 <__umoddi3+0xb0>
  801a44:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a48:	39 3c 24             	cmp    %edi,(%esp)
  801a4b:	0f 87 e7 00 00 00    	ja     801b38 <__umoddi3+0x148>
  801a51:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a55:	29 f1                	sub    %esi,%ecx
  801a57:	19 c7                	sbb    %eax,%edi
  801a59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a5d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a61:	8b 44 24 08          	mov    0x8(%esp),%eax
  801a65:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801a69:	83 c4 14             	add    $0x14,%esp
  801a6c:	5e                   	pop    %esi
  801a6d:	5f                   	pop    %edi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    
  801a70:	85 f6                	test   %esi,%esi
  801a72:	89 f5                	mov    %esi,%ebp
  801a74:	75 0b                	jne    801a81 <__umoddi3+0x91>
  801a76:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7b:	31 d2                	xor    %edx,%edx
  801a7d:	f7 f6                	div    %esi
  801a7f:	89 c5                	mov    %eax,%ebp
  801a81:	8b 44 24 04          	mov    0x4(%esp),%eax
  801a85:	31 d2                	xor    %edx,%edx
  801a87:	f7 f5                	div    %ebp
  801a89:	89 c8                	mov    %ecx,%eax
  801a8b:	f7 f5                	div    %ebp
  801a8d:	eb 9c                	jmp    801a2b <__umoddi3+0x3b>
  801a8f:	90                   	nop
  801a90:	89 c8                	mov    %ecx,%eax
  801a92:	89 fa                	mov    %edi,%edx
  801a94:	83 c4 14             	add    $0x14,%esp
  801a97:	5e                   	pop    %esi
  801a98:	5f                   	pop    %edi
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    
  801a9b:	90                   	nop
  801a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801aa0:	8b 04 24             	mov    (%esp),%eax
  801aa3:	be 20 00 00 00       	mov    $0x20,%esi
  801aa8:	89 e9                	mov    %ebp,%ecx
  801aaa:	29 ee                	sub    %ebp,%esi
  801aac:	d3 e2                	shl    %cl,%edx
  801aae:	89 f1                	mov    %esi,%ecx
  801ab0:	d3 e8                	shr    %cl,%eax
  801ab2:	89 e9                	mov    %ebp,%ecx
  801ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab8:	8b 04 24             	mov    (%esp),%eax
  801abb:	09 54 24 04          	or     %edx,0x4(%esp)
  801abf:	89 fa                	mov    %edi,%edx
  801ac1:	d3 e0                	shl    %cl,%eax
  801ac3:	89 f1                	mov    %esi,%ecx
  801ac5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801acd:	d3 ea                	shr    %cl,%edx
  801acf:	89 e9                	mov    %ebp,%ecx
  801ad1:	d3 e7                	shl    %cl,%edi
  801ad3:	89 f1                	mov    %esi,%ecx
  801ad5:	d3 e8                	shr    %cl,%eax
  801ad7:	89 e9                	mov    %ebp,%ecx
  801ad9:	09 f8                	or     %edi,%eax
  801adb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801adf:	f7 74 24 04          	divl   0x4(%esp)
  801ae3:	d3 e7                	shl    %cl,%edi
  801ae5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ae9:	89 d7                	mov    %edx,%edi
  801aeb:	f7 64 24 08          	mull   0x8(%esp)
  801aef:	39 d7                	cmp    %edx,%edi
  801af1:	89 c1                	mov    %eax,%ecx
  801af3:	89 14 24             	mov    %edx,(%esp)
  801af6:	72 2c                	jb     801b24 <__umoddi3+0x134>
  801af8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801afc:	72 22                	jb     801b20 <__umoddi3+0x130>
  801afe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b02:	29 c8                	sub    %ecx,%eax
  801b04:	19 d7                	sbb    %edx,%edi
  801b06:	89 e9                	mov    %ebp,%ecx
  801b08:	89 fa                	mov    %edi,%edx
  801b0a:	d3 e8                	shr    %cl,%eax
  801b0c:	89 f1                	mov    %esi,%ecx
  801b0e:	d3 e2                	shl    %cl,%edx
  801b10:	89 e9                	mov    %ebp,%ecx
  801b12:	d3 ef                	shr    %cl,%edi
  801b14:	09 d0                	or     %edx,%eax
  801b16:	89 fa                	mov    %edi,%edx
  801b18:	83 c4 14             	add    $0x14,%esp
  801b1b:	5e                   	pop    %esi
  801b1c:	5f                   	pop    %edi
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    
  801b1f:	90                   	nop
  801b20:	39 d7                	cmp    %edx,%edi
  801b22:	75 da                	jne    801afe <__umoddi3+0x10e>
  801b24:	8b 14 24             	mov    (%esp),%edx
  801b27:	89 c1                	mov    %eax,%ecx
  801b29:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801b2d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801b31:	eb cb                	jmp    801afe <__umoddi3+0x10e>
  801b33:	90                   	nop
  801b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801b3c:	0f 82 0f ff ff ff    	jb     801a51 <__umoddi3+0x61>
  801b42:	e9 1a ff ff ff       	jmp    801a61 <__umoddi3+0x71>
