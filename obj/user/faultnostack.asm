
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 28 00 00 00       	call   800059 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	c7 44 24 04 9b 03 80 	movl   $0x80039b,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 86 02 00 00       	call   8002d3 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004d:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800054:	00 00 00 
}
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	56                   	push   %esi
  80005d:	53                   	push   %ebx
  80005e:	83 ec 10             	sub    $0x10,%esp
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800067:	e8 dc 00 00 00       	call   800148 <sys_getenvid>
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	89 c2                	mov    %eax,%edx
  800073:	c1 e2 07             	shl    $0x7,%edx
  800076:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80007d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x34>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800091:	89 1c 24             	mov    %ebx,(%esp)
  800094:	e8 9a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800099:	e8 07 00 00 00       	call   8000a5 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    

008000a5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b2:	e8 3f 00 00 00       	call   8000f6 <sys_env_destroy>
}
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	57                   	push   %edi
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	89 c3                	mov    %eax,%ebx
  8000cc:	89 c7                	mov    %eax,%edi
  8000ce:	89 c6                	mov    %eax,%esi
  8000d0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e7:	89 d1                	mov    %edx,%ecx
  8000e9:	89 d3                	mov    %edx,%ebx
  8000eb:	89 d7                	mov    %edx,%edi
  8000ed:	89 d6                	mov    %edx,%esi
  8000ef:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    

008000f6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	57                   	push   %edi
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800104:	b8 03 00 00 00       	mov    $0x3,%eax
  800109:	8b 55 08             	mov    0x8(%ebp),%edx
  80010c:	89 cb                	mov    %ecx,%ebx
  80010e:	89 cf                	mov    %ecx,%edi
  800110:	89 ce                	mov    %ecx,%esi
  800112:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800114:	85 c0                	test   %eax,%eax
  800116:	7e 28                	jle    800140 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800118:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011c:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800123:	00 
  800124:	c7 44 24 08 2a 16 80 	movl   $0x80162a,0x8(%esp)
  80012b:	00 
  80012c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800133:	00 
  800134:	c7 04 24 47 16 80 00 	movl   $0x801647,(%esp)
  80013b:	e8 81 02 00 00       	call   8003c1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800140:	83 c4 2c             	add    $0x2c,%esp
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5f                   	pop    %edi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	57                   	push   %edi
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 02 00 00 00       	mov    $0x2,%eax
  800158:	89 d1                	mov    %edx,%ecx
  80015a:	89 d3                	mov    %edx,%ebx
  80015c:	89 d7                	mov    %edx,%edi
  80015e:	89 d6                	mov    %edx,%esi
  800160:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	5f                   	pop    %edi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_yield>:

void
sys_yield(void)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016d:	ba 00 00 00 00       	mov    $0x0,%edx
  800172:	b8 0a 00 00 00       	mov    $0xa,%eax
  800177:	89 d1                	mov    %edx,%ecx
  800179:	89 d3                	mov    %edx,%ebx
  80017b:	89 d7                	mov    %edx,%edi
  80017d:	89 d6                	mov    %edx,%esi
  80017f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	57                   	push   %edi
  80018a:	56                   	push   %esi
  80018b:	53                   	push   %ebx
  80018c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018f:	be 00 00 00 00       	mov    $0x0,%esi
  800194:	b8 04 00 00 00       	mov    $0x4,%eax
  800199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019c:	8b 55 08             	mov    0x8(%ebp),%edx
  80019f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a2:	89 f7                	mov    %esi,%edi
  8001a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a6:	85 c0                	test   %eax,%eax
  8001a8:	7e 28                	jle    8001d2 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ae:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b5:	00 
  8001b6:	c7 44 24 08 2a 16 80 	movl   $0x80162a,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 47 16 80 00 	movl   $0x801647,(%esp)
  8001cd:	e8 ef 01 00 00       	call   8003c1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d2:	83 c4 2c             	add    $0x2c,%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f4:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 28                	jle    800225 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800201:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800208:	00 
  800209:	c7 44 24 08 2a 16 80 	movl   $0x80162a,0x8(%esp)
  800210:	00 
  800211:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800218:	00 
  800219:	c7 04 24 47 16 80 00 	movl   $0x801647,(%esp)
  800220:	e8 9c 01 00 00       	call   8003c1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800225:	83 c4 2c             	add    $0x2c,%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 06 00 00 00       	mov    $0x6,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 28                	jle    800278 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	89 44 24 10          	mov    %eax,0x10(%esp)
  800254:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025b:	00 
  80025c:	c7 44 24 08 2a 16 80 	movl   $0x80162a,0x8(%esp)
  800263:	00 
  800264:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026b:	00 
  80026c:	c7 04 24 47 16 80 00 	movl   $0x801647,(%esp)
  800273:	e8 49 01 00 00       	call   8003c1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800278:	83 c4 2c             	add    $0x2c,%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800289:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028e:	b8 08 00 00 00       	mov    $0x8,%eax
  800293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800296:	8b 55 08             	mov    0x8(%ebp),%edx
  800299:	89 df                	mov    %ebx,%edi
  80029b:	89 de                	mov    %ebx,%esi
  80029d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029f:	85 c0                	test   %eax,%eax
  8002a1:	7e 28                	jle    8002cb <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a7:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002ae:	00 
  8002af:	c7 44 24 08 2a 16 80 	movl   $0x80162a,0x8(%esp)
  8002b6:	00 
  8002b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 47 16 80 00 	movl   $0x801647,(%esp)
  8002c6:	e8 f6 00 00 00       	call   8003c1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002cb:	83 c4 2c             	add    $0x2c,%esp
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	57                   	push   %edi
  8002d7:	56                   	push   %esi
  8002d8:	53                   	push   %ebx
  8002d9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e1:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 df                	mov    %ebx,%edi
  8002ee:	89 de                	mov    %ebx,%esi
  8002f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f2:	85 c0                	test   %eax,%eax
  8002f4:	7e 28                	jle    80031e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fa:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800301:	00 
  800302:	c7 44 24 08 2a 16 80 	movl   $0x80162a,0x8(%esp)
  800309:	00 
  80030a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800311:	00 
  800312:	c7 04 24 47 16 80 00 	movl   $0x801647,(%esp)
  800319:	e8 a3 00 00 00       	call   8003c1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80031e:	83 c4 2c             	add    $0x2c,%esp
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	57                   	push   %edi
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032c:	be 00 00 00 00       	mov    $0x0,%esi
  800331:	b8 0b 00 00 00       	mov    $0xb,%eax
  800336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800339:	8b 55 08             	mov    0x8(%ebp),%edx
  80033c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800342:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800344:	5b                   	pop    %ebx
  800345:	5e                   	pop    %esi
  800346:	5f                   	pop    %edi
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	57                   	push   %edi
  80034d:	56                   	push   %esi
  80034e:	53                   	push   %ebx
  80034f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
  800357:	b8 0c 00 00 00       	mov    $0xc,%eax
  80035c:	8b 55 08             	mov    0x8(%ebp),%edx
  80035f:	89 cb                	mov    %ecx,%ebx
  800361:	89 cf                	mov    %ecx,%edi
  800363:	89 ce                	mov    %ecx,%esi
  800365:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800367:	85 c0                	test   %eax,%eax
  800369:	7e 28                	jle    800393 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800376:	00 
  800377:	c7 44 24 08 2a 16 80 	movl   $0x80162a,0x8(%esp)
  80037e:	00 
  80037f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800386:	00 
  800387:	c7 04 24 47 16 80 00 	movl   $0x801647,(%esp)
  80038e:	e8 2e 00 00 00       	call   8003c1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800393:	83 c4 2c             	add    $0x2c,%esp
  800396:	5b                   	pop    %ebx
  800397:	5e                   	pop    %esi
  800398:	5f                   	pop    %edi
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80039b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80039c:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8003a1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003a3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp 
  8003a6:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp),%eax
  8003a9:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp),%ecx
  8003ad:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	subl $4 , %ecx	
  8003b1:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx,40(%esp)
  8003b4:	89 4c 24 28          	mov    %ecx,0x28(%esp)
	movl %eax,(%ecx)
  8003b8:	89 01                	mov    %eax,(%ecx)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal 
  8003ba:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp	
  8003bb:	83 c4 04             	add    $0x4,%esp
	popfl 	
  8003be:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8003bf:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8003c0:	c3                   	ret    

008003c1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	56                   	push   %esi
  8003c5:	53                   	push   %ebx
  8003c6:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003cc:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003d2:	e8 71 fd ff ff       	call   800148 <sys_getenvid>
  8003d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003da:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003de:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ed:	c7 04 24 58 16 80 00 	movl   $0x801658,(%esp)
  8003f4:	e8 c1 00 00 00       	call   8004ba <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 51 00 00 00       	call   800459 <vcprintf>
	cprintf("\n");
  800408:	c7 04 24 7c 16 80 00 	movl   $0x80167c,(%esp)
  80040f:	e8 a6 00 00 00       	call   8004ba <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800414:	cc                   	int3   
  800415:	eb fd                	jmp    800414 <_panic+0x53>

00800417 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	53                   	push   %ebx
  80041b:	83 ec 14             	sub    $0x14,%esp
  80041e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800421:	8b 13                	mov    (%ebx),%edx
  800423:	8d 42 01             	lea    0x1(%edx),%eax
  800426:	89 03                	mov    %eax,(%ebx)
  800428:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80042f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800434:	75 19                	jne    80044f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800436:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80043d:	00 
  80043e:	8d 43 08             	lea    0x8(%ebx),%eax
  800441:	89 04 24             	mov    %eax,(%esp)
  800444:	e8 70 fc ff ff       	call   8000b9 <sys_cputs>
		b->idx = 0;
  800449:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80044f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800453:	83 c4 14             	add    $0x14,%esp
  800456:	5b                   	pop    %ebx
  800457:	5d                   	pop    %ebp
  800458:	c3                   	ret    

00800459 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800459:	55                   	push   %ebp
  80045a:	89 e5                	mov    %esp,%ebp
  80045c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800462:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800469:	00 00 00 
	b.cnt = 0;
  80046c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800473:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	89 44 24 08          	mov    %eax,0x8(%esp)
  800484:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80048a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048e:	c7 04 24 17 04 80 00 	movl   $0x800417,(%esp)
  800495:	e8 b5 02 00 00       	call   80074f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80049a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004aa:	89 04 24             	mov    %eax,(%esp)
  8004ad:	e8 07 fc ff ff       	call   8000b9 <sys_cputs>

	return b.cnt;
}
  8004b2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004b8:	c9                   	leave  
  8004b9:	c3                   	ret    

008004ba <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004ba:	55                   	push   %ebp
  8004bb:	89 e5                	mov    %esp,%ebp
  8004bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004c0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ca:	89 04 24             	mov    %eax,(%esp)
  8004cd:	e8 87 ff ff ff       	call   800459 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    
  8004d4:	66 90                	xchg   %ax,%ax
  8004d6:	66 90                	xchg   %ax,%ax
  8004d8:	66 90                	xchg   %ax,%ax
  8004da:	66 90                	xchg   %ax,%ax
  8004dc:	66 90                	xchg   %ax,%ax
  8004de:	66 90                	xchg   %ax,%ax

008004e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 3c             	sub    $0x3c,%esp
  8004e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ec:	89 d7                	mov    %edx,%edi
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800502:	b9 00 00 00 00       	mov    $0x0,%ecx
  800507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80050d:	39 d9                	cmp    %ebx,%ecx
  80050f:	72 05                	jb     800516 <printnum+0x36>
  800511:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800514:	77 69                	ja     80057f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800516:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800519:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80051d:	83 ee 01             	sub    $0x1,%esi
  800520:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800524:	89 44 24 08          	mov    %eax,0x8(%esp)
  800528:	8b 44 24 08          	mov    0x8(%esp),%eax
  80052c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800530:	89 c3                	mov    %eax,%ebx
  800532:	89 d6                	mov    %edx,%esi
  800534:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800537:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80053e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800542:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80054b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054f:	e8 3c 0e 00 00       	call   801390 <__udivdi3>
  800554:	89 d9                	mov    %ebx,%ecx
  800556:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80055a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	89 54 24 04          	mov    %edx,0x4(%esp)
  800565:	89 fa                	mov    %edi,%edx
  800567:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056a:	e8 71 ff ff ff       	call   8004e0 <printnum>
  80056f:	eb 1b                	jmp    80058c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800571:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800575:	8b 45 18             	mov    0x18(%ebp),%eax
  800578:	89 04 24             	mov    %eax,(%esp)
  80057b:	ff d3                	call   *%ebx
  80057d:	eb 03                	jmp    800582 <printnum+0xa2>
  80057f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800582:	83 ee 01             	sub    $0x1,%esi
  800585:	85 f6                	test   %esi,%esi
  800587:	7f e8                	jg     800571 <printnum+0x91>
  800589:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800590:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a5:	89 04 24             	mov    %eax,(%esp)
  8005a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005af:	e8 0c 0f 00 00       	call   8014c0 <__umoddi3>
  8005b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b8:	0f be 80 7e 16 80 00 	movsbl 0x80167e(%eax),%eax
  8005bf:	89 04 24             	mov    %eax,(%esp)
  8005c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c5:	ff d0                	call   *%eax
}
  8005c7:	83 c4 3c             	add    $0x3c,%esp
  8005ca:	5b                   	pop    %ebx
  8005cb:	5e                   	pop    %esi
  8005cc:	5f                   	pop    %edi
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	57                   	push   %edi
  8005d3:	56                   	push   %esi
  8005d4:	53                   	push   %ebx
  8005d5:	83 ec 3c             	sub    $0x3c,%esp
  8005d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005db:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005de:	89 cf                	mov    %ecx,%edi
  8005e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e9:	89 c3                	mov    %eax,%ebx
  8005eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005ff:	39 d9                	cmp    %ebx,%ecx
  800601:	72 13                	jb     800616 <cprintnum+0x47>
  800603:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800606:	76 0e                	jbe    800616 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800608:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060b:	0b 45 18             	or     0x18(%ebp),%eax
  80060e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800611:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800614:	eb 6a                	jmp    800680 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800616:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800619:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80061d:	83 ee 01             	sub    $0x1,%esi
  800620:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800624:	89 44 24 08          	mov    %eax,0x8(%esp)
  800628:	8b 44 24 08          	mov    0x8(%esp),%eax
  80062c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800630:	89 c3                	mov    %eax,%ebx
  800632:	89 d6                	mov    %edx,%esi
  800634:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800637:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80063a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80063e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800642:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80064b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064f:	e8 3c 0d 00 00       	call   801390 <__udivdi3>
  800654:	89 d9                	mov    %ebx,%ecx
  800656:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80065a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80065e:	89 04 24             	mov    %eax,(%esp)
  800661:	89 54 24 04          	mov    %edx,0x4(%esp)
  800665:	89 f9                	mov    %edi,%ecx
  800667:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80066a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80066d:	e8 5d ff ff ff       	call   8005cf <cprintnum>
  800672:	eb 16                	jmp    80068a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800674:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800678:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800680:	83 ee 01             	sub    $0x1,%esi
  800683:	85 f6                	test   %esi,%esi
  800685:	7f ed                	jg     800674 <cprintnum+0xa5>
  800687:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80068a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800692:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800695:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800698:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006a3:	89 04 24             	mov    %eax,(%esp)
  8006a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	e8 0e 0e 00 00       	call   8014c0 <__umoddi3>
  8006b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b6:	0f be 80 7e 16 80 00 	movsbl 0x80167e(%eax),%eax
  8006bd:	0b 45 dc             	or     -0x24(%ebp),%eax
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006c6:	ff d0                	call   *%eax
}
  8006c8:	83 c4 3c             	add    $0x3c,%esp
  8006cb:	5b                   	pop    %ebx
  8006cc:	5e                   	pop    %esi
  8006cd:	5f                   	pop    %edi
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d3:	83 fa 01             	cmp    $0x1,%edx
  8006d6:	7e 0e                	jle    8006e6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006dd:	89 08                	mov    %ecx,(%eax)
  8006df:	8b 02                	mov    (%edx),%eax
  8006e1:	8b 52 04             	mov    0x4(%edx),%edx
  8006e4:	eb 22                	jmp    800708 <getuint+0x38>
	else if (lflag)
  8006e6:	85 d2                	test   %edx,%edx
  8006e8:	74 10                	je     8006fa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ef:	89 08                	mov    %ecx,(%eax)
  8006f1:	8b 02                	mov    (%edx),%eax
  8006f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f8:	eb 0e                	jmp    800708 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006fa:	8b 10                	mov    (%eax),%edx
  8006fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ff:	89 08                	mov    %ecx,(%eax)
  800701:	8b 02                	mov    (%edx),%eax
  800703:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800710:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800714:	8b 10                	mov    (%eax),%edx
  800716:	3b 50 04             	cmp    0x4(%eax),%edx
  800719:	73 0a                	jae    800725 <sprintputch+0x1b>
		*b->buf++ = ch;
  80071b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80071e:	89 08                	mov    %ecx,(%eax)
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	88 02                	mov    %al,(%edx)
}
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800730:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800734:	8b 45 10             	mov    0x10(%ebp),%eax
  800737:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	89 04 24             	mov    %eax,(%esp)
  800748:	e8 02 00 00 00       	call   80074f <vprintfmt>
	va_end(ap);
}
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	57                   	push   %edi
  800753:	56                   	push   %esi
  800754:	53                   	push   %ebx
  800755:	83 ec 3c             	sub    $0x3c,%esp
  800758:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80075b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80075e:	eb 14                	jmp    800774 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800760:	85 c0                	test   %eax,%eax
  800762:	0f 84 b3 03 00 00    	je     800b1b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800768:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800772:	89 f3                	mov    %esi,%ebx
  800774:	8d 73 01             	lea    0x1(%ebx),%esi
  800777:	0f b6 03             	movzbl (%ebx),%eax
  80077a:	83 f8 25             	cmp    $0x25,%eax
  80077d:	75 e1                	jne    800760 <vprintfmt+0x11>
  80077f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800783:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80078a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800791:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800798:	ba 00 00 00 00       	mov    $0x0,%edx
  80079d:	eb 1d                	jmp    8007bc <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007a1:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8007a5:	eb 15                	jmp    8007bc <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007a9:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8007ad:	eb 0d                	jmp    8007bc <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007b5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007bf:	0f b6 0e             	movzbl (%esi),%ecx
  8007c2:	0f b6 c1             	movzbl %cl,%eax
  8007c5:	83 e9 23             	sub    $0x23,%ecx
  8007c8:	80 f9 55             	cmp    $0x55,%cl
  8007cb:	0f 87 2a 03 00 00    	ja     800afb <vprintfmt+0x3ac>
  8007d1:	0f b6 c9             	movzbl %cl,%ecx
  8007d4:	ff 24 8d 40 17 80 00 	jmp    *0x801740(,%ecx,4)
  8007db:	89 de                	mov    %ebx,%esi
  8007dd:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007e2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8007e5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8007e9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007ec:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8007ef:	83 fb 09             	cmp    $0x9,%ebx
  8007f2:	77 36                	ja     80082a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007f4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007f7:	eb e9                	jmp    8007e2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8007ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800802:	8b 00                	mov    (%eax),%eax
  800804:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800807:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800809:	eb 22                	jmp    80082d <vprintfmt+0xde>
  80080b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80080e:	85 c9                	test   %ecx,%ecx
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	0f 49 c1             	cmovns %ecx,%eax
  800818:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081b:	89 de                	mov    %ebx,%esi
  80081d:	eb 9d                	jmp    8007bc <vprintfmt+0x6d>
  80081f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800821:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800828:	eb 92                	jmp    8007bc <vprintfmt+0x6d>
  80082a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80082d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800831:	79 89                	jns    8007bc <vprintfmt+0x6d>
  800833:	e9 77 ff ff ff       	jmp    8007af <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800838:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80083d:	e9 7a ff ff ff       	jmp    8007bc <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8d 50 04             	lea    0x4(%eax),%edx
  800848:	89 55 14             	mov    %edx,0x14(%ebp)
  80084b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084f:	8b 00                	mov    (%eax),%eax
  800851:	89 04 24             	mov    %eax,(%esp)
  800854:	ff 55 08             	call   *0x8(%ebp)
			break;
  800857:	e9 18 ff ff ff       	jmp    800774 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	8d 50 04             	lea    0x4(%eax),%edx
  800862:	89 55 14             	mov    %edx,0x14(%ebp)
  800865:	8b 00                	mov    (%eax),%eax
  800867:	99                   	cltd   
  800868:	31 d0                	xor    %edx,%eax
  80086a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80086c:	83 f8 09             	cmp    $0x9,%eax
  80086f:	7f 0b                	jg     80087c <vprintfmt+0x12d>
  800871:	8b 14 85 00 1a 80 00 	mov    0x801a00(,%eax,4),%edx
  800878:	85 d2                	test   %edx,%edx
  80087a:	75 20                	jne    80089c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80087c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800880:	c7 44 24 08 96 16 80 	movl   $0x801696,0x8(%esp)
  800887:	00 
  800888:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	89 04 24             	mov    %eax,(%esp)
  800892:	e8 90 fe ff ff       	call   800727 <printfmt>
  800897:	e9 d8 fe ff ff       	jmp    800774 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80089c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008a0:	c7 44 24 08 9f 16 80 	movl   $0x80169f,0x8(%esp)
  8008a7:	00 
  8008a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	89 04 24             	mov    %eax,(%esp)
  8008b2:	e8 70 fe ff ff       	call   800727 <printfmt>
  8008b7:	e9 b8 fe ff ff       	jmp    800774 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8008bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8d 50 04             	lea    0x4(%eax),%edx
  8008cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ce:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008d0:	85 f6                	test   %esi,%esi
  8008d2:	b8 8f 16 80 00       	mov    $0x80168f,%eax
  8008d7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8008da:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8008de:	0f 84 97 00 00 00    	je     80097b <vprintfmt+0x22c>
  8008e4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008e8:	0f 8e 9b 00 00 00    	jle    800989 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008f2:	89 34 24             	mov    %esi,(%esp)
  8008f5:	e8 ce 06 00 00       	call   800fc8 <strnlen>
  8008fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008fd:	29 c2                	sub    %eax,%edx
  8008ff:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800902:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800906:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800909:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80090c:	8b 75 08             	mov    0x8(%ebp),%esi
  80090f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800912:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800914:	eb 0f                	jmp    800925 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800916:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80091d:	89 04 24             	mov    %eax,(%esp)
  800920:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800922:	83 eb 01             	sub    $0x1,%ebx
  800925:	85 db                	test   %ebx,%ebx
  800927:	7f ed                	jg     800916 <vprintfmt+0x1c7>
  800929:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80092c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80092f:	85 d2                	test   %edx,%edx
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
  800936:	0f 49 c2             	cmovns %edx,%eax
  800939:	29 c2                	sub    %eax,%edx
  80093b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80093e:	89 d7                	mov    %edx,%edi
  800940:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800943:	eb 50                	jmp    800995 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800945:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800949:	74 1e                	je     800969 <vprintfmt+0x21a>
  80094b:	0f be d2             	movsbl %dl,%edx
  80094e:	83 ea 20             	sub    $0x20,%edx
  800951:	83 fa 5e             	cmp    $0x5e,%edx
  800954:	76 13                	jbe    800969 <vprintfmt+0x21a>
					putch('?', putdat);
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800964:	ff 55 08             	call   *0x8(%ebp)
  800967:	eb 0d                	jmp    800976 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800970:	89 04 24             	mov    %eax,(%esp)
  800973:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800976:	83 ef 01             	sub    $0x1,%edi
  800979:	eb 1a                	jmp    800995 <vprintfmt+0x246>
  80097b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80097e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800981:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800984:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800987:	eb 0c                	jmp    800995 <vprintfmt+0x246>
  800989:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80098c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80098f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800992:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800995:	83 c6 01             	add    $0x1,%esi
  800998:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80099c:	0f be c2             	movsbl %dl,%eax
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	74 27                	je     8009ca <vprintfmt+0x27b>
  8009a3:	85 db                	test   %ebx,%ebx
  8009a5:	78 9e                	js     800945 <vprintfmt+0x1f6>
  8009a7:	83 eb 01             	sub    $0x1,%ebx
  8009aa:	79 99                	jns    800945 <vprintfmt+0x1f6>
  8009ac:	89 f8                	mov    %edi,%eax
  8009ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b4:	89 c3                	mov    %eax,%ebx
  8009b6:	eb 1a                	jmp    8009d2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009bc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009c5:	83 eb 01             	sub    $0x1,%ebx
  8009c8:	eb 08                	jmp    8009d2 <vprintfmt+0x283>
  8009ca:	89 fb                	mov    %edi,%ebx
  8009cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009d2:	85 db                	test   %ebx,%ebx
  8009d4:	7f e2                	jg     8009b8 <vprintfmt+0x269>
  8009d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8009d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009dc:	e9 93 fd ff ff       	jmp    800774 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009e1:	83 fa 01             	cmp    $0x1,%edx
  8009e4:	7e 16                	jle    8009fc <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8009e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e9:	8d 50 08             	lea    0x8(%eax),%edx
  8009ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ef:	8b 50 04             	mov    0x4(%eax),%edx
  8009f2:	8b 00                	mov    (%eax),%eax
  8009f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009fa:	eb 32                	jmp    800a2e <vprintfmt+0x2df>
	else if (lflag)
  8009fc:	85 d2                	test   %edx,%edx
  8009fe:	74 18                	je     800a18 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800a00:	8b 45 14             	mov    0x14(%ebp),%eax
  800a03:	8d 50 04             	lea    0x4(%eax),%edx
  800a06:	89 55 14             	mov    %edx,0x14(%ebp)
  800a09:	8b 30                	mov    (%eax),%esi
  800a0b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a0e:	89 f0                	mov    %esi,%eax
  800a10:	c1 f8 1f             	sar    $0x1f,%eax
  800a13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a16:	eb 16                	jmp    800a2e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800a18:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1b:	8d 50 04             	lea    0x4(%eax),%edx
  800a1e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a21:	8b 30                	mov    (%eax),%esi
  800a23:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a26:	89 f0                	mov    %esi,%eax
  800a28:	c1 f8 1f             	sar    $0x1f,%eax
  800a2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a31:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a34:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a39:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a3d:	0f 89 80 00 00 00    	jns    800ac3 <vprintfmt+0x374>
				putch('-', putdat);
  800a43:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a47:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a4e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a51:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a57:	f7 d8                	neg    %eax
  800a59:	83 d2 00             	adc    $0x0,%edx
  800a5c:	f7 da                	neg    %edx
			}
			base = 10;
  800a5e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a63:	eb 5e                	jmp    800ac3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a65:	8d 45 14             	lea    0x14(%ebp),%eax
  800a68:	e8 63 fc ff ff       	call   8006d0 <getuint>
			base = 10;
  800a6d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a72:	eb 4f                	jmp    800ac3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800a74:	8d 45 14             	lea    0x14(%ebp),%eax
  800a77:	e8 54 fc ff ff       	call   8006d0 <getuint>
			base = 8 ;
  800a7c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800a81:	eb 40                	jmp    800ac3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800a83:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a87:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a8e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a91:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a95:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a9c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa2:	8d 50 04             	lea    0x4(%eax),%edx
  800aa5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800aa8:	8b 00                	mov    (%eax),%eax
  800aaa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800aaf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ab4:	eb 0d                	jmp    800ac3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ab6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab9:	e8 12 fc ff ff       	call   8006d0 <getuint>
			base = 16;
  800abe:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800ac7:	89 74 24 10          	mov    %esi,0x10(%esp)
  800acb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800ace:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ad2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ad6:	89 04 24             	mov    %eax,(%esp)
  800ad9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800add:	89 fa                	mov    %edi,%edx
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	e8 f9 f9 ff ff       	call   8004e0 <printnum>
			break;
  800ae7:	e9 88 fc ff ff       	jmp    800774 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800af0:	89 04 24             	mov    %eax,(%esp)
  800af3:	ff 55 08             	call   *0x8(%ebp)
			break;
  800af6:	e9 79 fc ff ff       	jmp    800774 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800afb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b06:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	eb 03                	jmp    800b10 <vprintfmt+0x3c1>
  800b0d:	83 eb 01             	sub    $0x1,%ebx
  800b10:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800b14:	75 f7                	jne    800b0d <vprintfmt+0x3be>
  800b16:	e9 59 fc ff ff       	jmp    800774 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800b1b:	83 c4 3c             	add    $0x3c,%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 3c             	sub    $0x3c,%esp
  800b2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  800b2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b32:	8d 50 04             	lea    0x4(%eax),%edx
  800b35:	89 55 14             	mov    %edx,0x14(%ebp)
  800b38:	8b 00                	mov    (%eax),%eax
  800b3a:	c1 e0 08             	shl    $0x8,%eax
  800b3d:	0f b7 c0             	movzwl %ax,%eax
  800b40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800b43:	83 c8 25             	or     $0x25,%eax
  800b46:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800b49:	eb 1a                	jmp    800b65 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	0f 84 a9 03 00 00    	je     800efc <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800b53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b5a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b5d:	89 04 24             	mov    %eax,(%esp)
  800b60:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b63:	89 fb                	mov    %edi,%ebx
  800b65:	8d 7b 01             	lea    0x1(%ebx),%edi
  800b68:	0f b6 03             	movzbl (%ebx),%eax
  800b6b:	83 f8 25             	cmp    $0x25,%eax
  800b6e:	75 db                	jne    800b4b <cvprintfmt+0x28>
  800b70:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800b74:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800b7b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800b80:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800b87:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8c:	eb 18                	jmp    800ba6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b8e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800b90:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800b94:	eb 10                	jmp    800ba6 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b96:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800b98:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800b9c:	eb 08                	jmp    800ba6 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800b9e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800ba1:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ba6:	8d 5f 01             	lea    0x1(%edi),%ebx
  800ba9:	0f b6 0f             	movzbl (%edi),%ecx
  800bac:	0f b6 c1             	movzbl %cl,%eax
  800baf:	83 e9 23             	sub    $0x23,%ecx
  800bb2:	80 f9 55             	cmp    $0x55,%cl
  800bb5:	0f 87 1f 03 00 00    	ja     800eda <cvprintfmt+0x3b7>
  800bbb:	0f b6 c9             	movzbl %cl,%ecx
  800bbe:	ff 24 8d 98 18 80 00 	jmp    *0x801898(,%ecx,4)
  800bc5:	89 df                	mov    %ebx,%edi
  800bc7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800bcc:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  800bcf:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800bd3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800bd6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800bd9:	83 f9 09             	cmp    $0x9,%ecx
  800bdc:	77 33                	ja     800c11 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800bde:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800be1:	eb e9                	jmp    800bcc <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800be3:	8b 45 14             	mov    0x14(%ebp),%eax
  800be6:	8d 48 04             	lea    0x4(%eax),%ecx
  800be9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bec:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bee:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800bf0:	eb 1f                	jmp    800c11 <cvprintfmt+0xee>
  800bf2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800bf5:	85 ff                	test   %edi,%edi
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfc:	0f 49 c7             	cmovns %edi,%eax
  800bff:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c02:	89 df                	mov    %ebx,%edi
  800c04:	eb a0                	jmp    800ba6 <cvprintfmt+0x83>
  800c06:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c08:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800c0f:	eb 95                	jmp    800ba6 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800c11:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c15:	79 8f                	jns    800ba6 <cvprintfmt+0x83>
  800c17:	eb 85                	jmp    800b9e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c19:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c1e:	66 90                	xchg   %ax,%ax
  800c20:	eb 84                	jmp    800ba6 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800c22:	8b 45 14             	mov    0x14(%ebp),%eax
  800c25:	8d 50 04             	lea    0x4(%eax),%edx
  800c28:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c32:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c35:	0b 10                	or     (%eax),%edx
  800c37:	89 14 24             	mov    %edx,(%esp)
  800c3a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c3d:	e9 23 ff ff ff       	jmp    800b65 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800c42:	8b 45 14             	mov    0x14(%ebp),%eax
  800c45:	8d 50 04             	lea    0x4(%eax),%edx
  800c48:	89 55 14             	mov    %edx,0x14(%ebp)
  800c4b:	8b 00                	mov    (%eax),%eax
  800c4d:	99                   	cltd   
  800c4e:	31 d0                	xor    %edx,%eax
  800c50:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800c52:	83 f8 09             	cmp    $0x9,%eax
  800c55:	7f 0b                	jg     800c62 <cvprintfmt+0x13f>
  800c57:	8b 14 85 00 1a 80 00 	mov    0x801a00(,%eax,4),%edx
  800c5e:	85 d2                	test   %edx,%edx
  800c60:	75 23                	jne    800c85 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800c62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c66:	c7 44 24 08 96 16 80 	movl   $0x801696,0x8(%esp)
  800c6d:	00 
  800c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	89 04 24             	mov    %eax,(%esp)
  800c7b:	e8 a7 fa ff ff       	call   800727 <printfmt>
  800c80:	e9 e0 fe ff ff       	jmp    800b65 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800c85:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c89:	c7 44 24 08 9f 16 80 	movl   $0x80169f,0x8(%esp)
  800c90:	00 
  800c91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	89 04 24             	mov    %eax,(%esp)
  800c9e:	e8 84 fa ff ff       	call   800727 <printfmt>
  800ca3:	e9 bd fe ff ff       	jmp    800b65 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800cab:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800cae:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb1:	8d 48 04             	lea    0x4(%eax),%ecx
  800cb4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cb7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800cb9:	85 ff                	test   %edi,%edi
  800cbb:	b8 8f 16 80 00       	mov    $0x80168f,%eax
  800cc0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800cc3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800cc7:	74 61                	je     800d2a <cvprintfmt+0x207>
  800cc9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800ccd:	7e 5b                	jle    800d2a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800ccf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd3:	89 3c 24             	mov    %edi,(%esp)
  800cd6:	e8 ed 02 00 00       	call   800fc8 <strnlen>
  800cdb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800cde:	29 c2                	sub    %eax,%edx
  800ce0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800ce3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800ce7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800cea:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800ced:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800cf0:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cf6:	89 d3                	mov    %edx,%ebx
  800cf8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800cfa:	eb 0f                	jmp    800d0b <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d03:	89 3c 24             	mov    %edi,(%esp)
  800d06:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d08:	83 eb 01             	sub    $0x1,%ebx
  800d0b:	85 db                	test   %ebx,%ebx
  800d0d:	7f ed                	jg     800cfc <cvprintfmt+0x1d9>
  800d0f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d12:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d18:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d1b:	85 d2                	test   %edx,%edx
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d22:	0f 49 c2             	cmovns %edx,%eax
  800d25:	29 c2                	sub    %eax,%edx
  800d27:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800d2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d2d:	83 c8 3f             	or     $0x3f,%eax
  800d30:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d33:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d36:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800d39:	eb 36                	jmp    800d71 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d3b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d3f:	74 1d                	je     800d5e <cvprintfmt+0x23b>
  800d41:	0f be d2             	movsbl %dl,%edx
  800d44:	83 ea 20             	sub    $0x20,%edx
  800d47:	83 fa 5e             	cmp    $0x5e,%edx
  800d4a:	76 12                	jbe    800d5e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d53:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d56:	89 04 24             	mov    %eax,(%esp)
  800d59:	ff 55 08             	call   *0x8(%ebp)
  800d5c:	eb 10                	jmp    800d6e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d61:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d65:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800d68:	89 04 24             	mov    %eax,(%esp)
  800d6b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d6e:	83 eb 01             	sub    $0x1,%ebx
  800d71:	83 c7 01             	add    $0x1,%edi
  800d74:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800d78:	0f be c2             	movsbl %dl,%eax
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	74 27                	je     800da6 <cvprintfmt+0x283>
  800d7f:	85 f6                	test   %esi,%esi
  800d81:	78 b8                	js     800d3b <cvprintfmt+0x218>
  800d83:	83 ee 01             	sub    $0x1,%esi
  800d86:	79 b3                	jns    800d3b <cvprintfmt+0x218>
  800d88:	89 d8                	mov    %ebx,%eax
  800d8a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d8d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	eb 18                	jmp    800dac <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800d94:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800d9f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800da1:	83 eb 01             	sub    $0x1,%ebx
  800da4:	eb 06                	jmp    800dac <cvprintfmt+0x289>
  800da6:	8b 75 08             	mov    0x8(%ebp),%esi
  800da9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dac:	85 db                	test   %ebx,%ebx
  800dae:	7f e4                	jg     800d94 <cvprintfmt+0x271>
  800db0:	89 75 08             	mov    %esi,0x8(%ebp)
  800db3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db9:	e9 a7 fd ff ff       	jmp    800b65 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800dbe:	83 fa 01             	cmp    $0x1,%edx
  800dc1:	7e 10                	jle    800dd3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800dc3:	8b 45 14             	mov    0x14(%ebp),%eax
  800dc6:	8d 50 08             	lea    0x8(%eax),%edx
  800dc9:	89 55 14             	mov    %edx,0x14(%ebp)
  800dcc:	8b 30                	mov    (%eax),%esi
  800dce:	8b 78 04             	mov    0x4(%eax),%edi
  800dd1:	eb 26                	jmp    800df9 <cvprintfmt+0x2d6>
	else if (lflag)
  800dd3:	85 d2                	test   %edx,%edx
  800dd5:	74 12                	je     800de9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800dd7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dda:	8d 50 04             	lea    0x4(%eax),%edx
  800ddd:	89 55 14             	mov    %edx,0x14(%ebp)
  800de0:	8b 30                	mov    (%eax),%esi
  800de2:	89 f7                	mov    %esi,%edi
  800de4:	c1 ff 1f             	sar    $0x1f,%edi
  800de7:	eb 10                	jmp    800df9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800de9:	8b 45 14             	mov    0x14(%ebp),%eax
  800dec:	8d 50 04             	lea    0x4(%eax),%edx
  800def:	89 55 14             	mov    %edx,0x14(%ebp)
  800df2:	8b 30                	mov    (%eax),%esi
  800df4:	89 f7                	mov    %esi,%edi
  800df6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800dfd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800e02:	85 ff                	test   %edi,%edi
  800e04:	0f 89 8e 00 00 00    	jns    800e98 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e14:	83 c8 2d             	or     $0x2d,%eax
  800e17:	89 04 24             	mov    %eax,(%esp)
  800e1a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e1d:	89 f0                	mov    %esi,%eax
  800e1f:	89 fa                	mov    %edi,%edx
  800e21:	f7 d8                	neg    %eax
  800e23:	83 d2 00             	adc    $0x0,%edx
  800e26:	f7 da                	neg    %edx
			}
			base = 10;
  800e28:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800e2d:	eb 69                	jmp    800e98 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e2f:	8d 45 14             	lea    0x14(%ebp),%eax
  800e32:	e8 99 f8 ff ff       	call   8006d0 <getuint>
			base = 10;
  800e37:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800e3c:	eb 5a                	jmp    800e98 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e3e:	8d 45 14             	lea    0x14(%ebp),%eax
  800e41:	e8 8a f8 ff ff       	call   8006d0 <getuint>
			base = 8 ;
  800e46:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800e4b:	eb 4b                	jmp    800e98 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e54:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800e57:	89 f0                	mov    %esi,%eax
  800e59:	83 c8 30             	or     $0x30,%eax
  800e5c:	89 04 24             	mov    %eax,(%esp)
  800e5f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800e62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e69:	89 f0                	mov    %esi,%eax
  800e6b:	83 c8 78             	or     $0x78,%eax
  800e6e:	89 04 24             	mov    %eax,(%esp)
  800e71:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e74:	8b 45 14             	mov    0x14(%ebp),%eax
  800e77:	8d 50 04             	lea    0x4(%eax),%edx
  800e7a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800e7d:	8b 00                	mov    (%eax),%eax
  800e7f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e84:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800e89:	eb 0d                	jmp    800e98 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e8b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e8e:	e8 3d f8 ff ff       	call   8006d0 <getuint>
			base = 16;
  800e93:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800e98:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800e9c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ea0:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800ea3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ea7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eab:	89 04 24             	mov    %eax,(%esp)
  800eae:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ebb:	e8 0f f7 ff ff       	call   8005cf <cprintnum>
			break;
  800ec0:	e9 a0 fc ff ff       	jmp    800b65 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800ec5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ecc:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800ecf:	89 04 24             	mov    %eax,(%esp)
  800ed2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ed5:	e9 8b fc ff ff       	jmp    800b65 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ee4:	89 04 24             	mov    %eax,(%esp)
  800ee7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800eea:	89 fb                	mov    %edi,%ebx
  800eec:	eb 03                	jmp    800ef1 <cvprintfmt+0x3ce>
  800eee:	83 eb 01             	sub    $0x1,%ebx
  800ef1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ef5:	75 f7                	jne    800eee <cvprintfmt+0x3cb>
  800ef7:	e9 69 fc ff ff       	jmp    800b65 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800efc:	83 c4 3c             	add    $0x3c,%esp
  800eff:	5b                   	pop    %ebx
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800f0a:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800f0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f11:	8b 45 10             	mov    0x10(%ebp),%eax
  800f14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	89 04 24             	mov    %eax,(%esp)
  800f25:	e8 f9 fb ff ff       	call   800b23 <cvprintfmt>
	va_end(ap);
}
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 28             	sub    $0x28,%esp
  800f32:	8b 45 08             	mov    0x8(%ebp),%eax
  800f35:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f38:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f3b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f3f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	74 30                	je     800f7d <vsnprintf+0x51>
  800f4d:	85 d2                	test   %edx,%edx
  800f4f:	7e 2c                	jle    800f7d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f51:	8b 45 14             	mov    0x14(%ebp),%eax
  800f54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f58:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f66:	c7 04 24 0a 07 80 00 	movl   $0x80070a,(%esp)
  800f6d:	e8 dd f7 ff ff       	call   80074f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f75:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7b:	eb 05                	jmp    800f82 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f8a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f91:	8b 45 10             	mov    0x10(%ebp),%eax
  800f94:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa2:	89 04 24             	mov    %eax,(%esp)
  800fa5:	e8 82 ff ff ff       	call   800f2c <vsnprintf>
	va_end(ap);

	return rc;
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    
  800fac:	66 90                	xchg   %ax,%ax
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbb:	eb 03                	jmp    800fc0 <strlen+0x10>
		n++;
  800fbd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800fc0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fc4:	75 f7                	jne    800fbd <strlen+0xd>
		n++;
	return n;
}
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    

00800fc8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd6:	eb 03                	jmp    800fdb <strnlen+0x13>
		n++;
  800fd8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fdb:	39 d0                	cmp    %edx,%eax
  800fdd:	74 06                	je     800fe5 <strnlen+0x1d>
  800fdf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fe3:	75 f3                	jne    800fd8 <strnlen+0x10>
		n++;
	return n;
}
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	53                   	push   %ebx
  800feb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ff1:	89 c2                	mov    %eax,%edx
  800ff3:	83 c2 01             	add    $0x1,%edx
  800ff6:	83 c1 01             	add    $0x1,%ecx
  800ff9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ffd:	88 5a ff             	mov    %bl,-0x1(%edx)
  801000:	84 db                	test   %bl,%bl
  801002:	75 ef                	jne    800ff3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801004:	5b                   	pop    %ebx
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	53                   	push   %ebx
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801011:	89 1c 24             	mov    %ebx,(%esp)
  801014:	e8 97 ff ff ff       	call   800fb0 <strlen>
	strcpy(dst + len, src);
  801019:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801020:	01 d8                	add    %ebx,%eax
  801022:	89 04 24             	mov    %eax,(%esp)
  801025:	e8 bd ff ff ff       	call   800fe7 <strcpy>
	return dst;
}
  80102a:	89 d8                	mov    %ebx,%eax
  80102c:	83 c4 08             	add    $0x8,%esp
  80102f:	5b                   	pop    %ebx
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
  801037:	8b 75 08             	mov    0x8(%ebp),%esi
  80103a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103d:	89 f3                	mov    %esi,%ebx
  80103f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801042:	89 f2                	mov    %esi,%edx
  801044:	eb 0f                	jmp    801055 <strncpy+0x23>
		*dst++ = *src;
  801046:	83 c2 01             	add    $0x1,%edx
  801049:	0f b6 01             	movzbl (%ecx),%eax
  80104c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80104f:	80 39 01             	cmpb   $0x1,(%ecx)
  801052:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801055:	39 da                	cmp    %ebx,%edx
  801057:	75 ed                	jne    801046 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801059:	89 f0                	mov    %esi,%eax
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    

0080105f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	8b 75 08             	mov    0x8(%ebp),%esi
  801067:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80106d:	89 f0                	mov    %esi,%eax
  80106f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801073:	85 c9                	test   %ecx,%ecx
  801075:	75 0b                	jne    801082 <strlcpy+0x23>
  801077:	eb 1d                	jmp    801096 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801079:	83 c0 01             	add    $0x1,%eax
  80107c:	83 c2 01             	add    $0x1,%edx
  80107f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801082:	39 d8                	cmp    %ebx,%eax
  801084:	74 0b                	je     801091 <strlcpy+0x32>
  801086:	0f b6 0a             	movzbl (%edx),%ecx
  801089:	84 c9                	test   %cl,%cl
  80108b:	75 ec                	jne    801079 <strlcpy+0x1a>
  80108d:	89 c2                	mov    %eax,%edx
  80108f:	eb 02                	jmp    801093 <strlcpy+0x34>
  801091:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801093:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801096:	29 f0                	sub    %esi,%eax
}
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8010a5:	eb 06                	jmp    8010ad <strcmp+0x11>
		p++, q++;
  8010a7:	83 c1 01             	add    $0x1,%ecx
  8010aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8010ad:	0f b6 01             	movzbl (%ecx),%eax
  8010b0:	84 c0                	test   %al,%al
  8010b2:	74 04                	je     8010b8 <strcmp+0x1c>
  8010b4:	3a 02                	cmp    (%edx),%al
  8010b6:	74 ef                	je     8010a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8010b8:	0f b6 c0             	movzbl %al,%eax
  8010bb:	0f b6 12             	movzbl (%edx),%edx
  8010be:	29 d0                	sub    %edx,%eax
}
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	53                   	push   %ebx
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010cc:	89 c3                	mov    %eax,%ebx
  8010ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8010d1:	eb 06                	jmp    8010d9 <strncmp+0x17>
		n--, p++, q++;
  8010d3:	83 c0 01             	add    $0x1,%eax
  8010d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8010d9:	39 d8                	cmp    %ebx,%eax
  8010db:	74 15                	je     8010f2 <strncmp+0x30>
  8010dd:	0f b6 08             	movzbl (%eax),%ecx
  8010e0:	84 c9                	test   %cl,%cl
  8010e2:	74 04                	je     8010e8 <strncmp+0x26>
  8010e4:	3a 0a                	cmp    (%edx),%cl
  8010e6:	74 eb                	je     8010d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010e8:	0f b6 00             	movzbl (%eax),%eax
  8010eb:	0f b6 12             	movzbl (%edx),%edx
  8010ee:	29 d0                	sub    %edx,%eax
  8010f0:	eb 05                	jmp    8010f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010f7:	5b                   	pop    %ebx
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801104:	eb 07                	jmp    80110d <strchr+0x13>
		if (*s == c)
  801106:	38 ca                	cmp    %cl,%dl
  801108:	74 0f                	je     801119 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80110a:	83 c0 01             	add    $0x1,%eax
  80110d:	0f b6 10             	movzbl (%eax),%edx
  801110:	84 d2                	test   %dl,%dl
  801112:	75 f2                	jne    801106 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801114:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
  801121:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801125:	eb 07                	jmp    80112e <strfind+0x13>
		if (*s == c)
  801127:	38 ca                	cmp    %cl,%dl
  801129:	74 0a                	je     801135 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80112b:	83 c0 01             	add    $0x1,%eax
  80112e:	0f b6 10             	movzbl (%eax),%edx
  801131:	84 d2                	test   %dl,%dl
  801133:	75 f2                	jne    801127 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801140:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801143:	85 c9                	test   %ecx,%ecx
  801145:	74 36                	je     80117d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801147:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80114d:	75 28                	jne    801177 <memset+0x40>
  80114f:	f6 c1 03             	test   $0x3,%cl
  801152:	75 23                	jne    801177 <memset+0x40>
		c &= 0xFF;
  801154:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801158:	89 d3                	mov    %edx,%ebx
  80115a:	c1 e3 08             	shl    $0x8,%ebx
  80115d:	89 d6                	mov    %edx,%esi
  80115f:	c1 e6 18             	shl    $0x18,%esi
  801162:	89 d0                	mov    %edx,%eax
  801164:	c1 e0 10             	shl    $0x10,%eax
  801167:	09 f0                	or     %esi,%eax
  801169:	09 c2                	or     %eax,%edx
  80116b:	89 d0                	mov    %edx,%eax
  80116d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80116f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801172:	fc                   	cld    
  801173:	f3 ab                	rep stos %eax,%es:(%edi)
  801175:	eb 06                	jmp    80117d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801177:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117a:	fc                   	cld    
  80117b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80117d:	89 f8                	mov    %edi,%eax
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	57                   	push   %edi
  801188:	56                   	push   %esi
  801189:	8b 45 08             	mov    0x8(%ebp),%eax
  80118c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80118f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801192:	39 c6                	cmp    %eax,%esi
  801194:	73 35                	jae    8011cb <memmove+0x47>
  801196:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801199:	39 d0                	cmp    %edx,%eax
  80119b:	73 2e                	jae    8011cb <memmove+0x47>
		s += n;
		d += n;
  80119d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8011a0:	89 d6                	mov    %edx,%esi
  8011a2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8011aa:	75 13                	jne    8011bf <memmove+0x3b>
  8011ac:	f6 c1 03             	test   $0x3,%cl
  8011af:	75 0e                	jne    8011bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8011b1:	83 ef 04             	sub    $0x4,%edi
  8011b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8011b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8011ba:	fd                   	std    
  8011bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011bd:	eb 09                	jmp    8011c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8011bf:	83 ef 01             	sub    $0x1,%edi
  8011c2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8011c5:	fd                   	std    
  8011c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8011c8:	fc                   	cld    
  8011c9:	eb 1d                	jmp    8011e8 <memmove+0x64>
  8011cb:	89 f2                	mov    %esi,%edx
  8011cd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011cf:	f6 c2 03             	test   $0x3,%dl
  8011d2:	75 0f                	jne    8011e3 <memmove+0x5f>
  8011d4:	f6 c1 03             	test   $0x3,%cl
  8011d7:	75 0a                	jne    8011e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8011d9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8011dc:	89 c7                	mov    %eax,%edi
  8011de:	fc                   	cld    
  8011df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011e1:	eb 05                	jmp    8011e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011e3:	89 c7                	mov    %eax,%edi
  8011e5:	fc                   	cld    
  8011e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	89 04 24             	mov    %eax,(%esp)
  801206:	e8 79 ff ff ff       	call   801184 <memmove>
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	56                   	push   %esi
  801211:	53                   	push   %ebx
  801212:	8b 55 08             	mov    0x8(%ebp),%edx
  801215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801218:	89 d6                	mov    %edx,%esi
  80121a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80121d:	eb 1a                	jmp    801239 <memcmp+0x2c>
		if (*s1 != *s2)
  80121f:	0f b6 02             	movzbl (%edx),%eax
  801222:	0f b6 19             	movzbl (%ecx),%ebx
  801225:	38 d8                	cmp    %bl,%al
  801227:	74 0a                	je     801233 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801229:	0f b6 c0             	movzbl %al,%eax
  80122c:	0f b6 db             	movzbl %bl,%ebx
  80122f:	29 d8                	sub    %ebx,%eax
  801231:	eb 0f                	jmp    801242 <memcmp+0x35>
		s1++, s2++;
  801233:	83 c2 01             	add    $0x1,%edx
  801236:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801239:	39 f2                	cmp    %esi,%edx
  80123b:	75 e2                	jne    80121f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801242:	5b                   	pop    %ebx
  801243:	5e                   	pop    %esi
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	8b 45 08             	mov    0x8(%ebp),%eax
  80124c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80124f:	89 c2                	mov    %eax,%edx
  801251:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801254:	eb 07                	jmp    80125d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801256:	38 08                	cmp    %cl,(%eax)
  801258:	74 07                	je     801261 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80125a:	83 c0 01             	add    $0x1,%eax
  80125d:	39 d0                	cmp    %edx,%eax
  80125f:	72 f5                	jb     801256 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	57                   	push   %edi
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	8b 55 08             	mov    0x8(%ebp),%edx
  80126c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80126f:	eb 03                	jmp    801274 <strtol+0x11>
		s++;
  801271:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801274:	0f b6 0a             	movzbl (%edx),%ecx
  801277:	80 f9 09             	cmp    $0x9,%cl
  80127a:	74 f5                	je     801271 <strtol+0xe>
  80127c:	80 f9 20             	cmp    $0x20,%cl
  80127f:	74 f0                	je     801271 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801281:	80 f9 2b             	cmp    $0x2b,%cl
  801284:	75 0a                	jne    801290 <strtol+0x2d>
		s++;
  801286:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801289:	bf 00 00 00 00       	mov    $0x0,%edi
  80128e:	eb 11                	jmp    8012a1 <strtol+0x3e>
  801290:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801295:	80 f9 2d             	cmp    $0x2d,%cl
  801298:	75 07                	jne    8012a1 <strtol+0x3e>
		s++, neg = 1;
  80129a:	8d 52 01             	lea    0x1(%edx),%edx
  80129d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012a1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  8012a6:	75 15                	jne    8012bd <strtol+0x5a>
  8012a8:	80 3a 30             	cmpb   $0x30,(%edx)
  8012ab:	75 10                	jne    8012bd <strtol+0x5a>
  8012ad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8012b1:	75 0a                	jne    8012bd <strtol+0x5a>
		s += 2, base = 16;
  8012b3:	83 c2 02             	add    $0x2,%edx
  8012b6:	b8 10 00 00 00       	mov    $0x10,%eax
  8012bb:	eb 10                	jmp    8012cd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	75 0c                	jne    8012cd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8012c1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8012c3:	80 3a 30             	cmpb   $0x30,(%edx)
  8012c6:	75 05                	jne    8012cd <strtol+0x6a>
		s++, base = 8;
  8012c8:	83 c2 01             	add    $0x1,%edx
  8012cb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  8012cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8012d5:	0f b6 0a             	movzbl (%edx),%ecx
  8012d8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8012db:	89 f0                	mov    %esi,%eax
  8012dd:	3c 09                	cmp    $0x9,%al
  8012df:	77 08                	ja     8012e9 <strtol+0x86>
			dig = *s - '0';
  8012e1:	0f be c9             	movsbl %cl,%ecx
  8012e4:	83 e9 30             	sub    $0x30,%ecx
  8012e7:	eb 20                	jmp    801309 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8012e9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8012ec:	89 f0                	mov    %esi,%eax
  8012ee:	3c 19                	cmp    $0x19,%al
  8012f0:	77 08                	ja     8012fa <strtol+0x97>
			dig = *s - 'a' + 10;
  8012f2:	0f be c9             	movsbl %cl,%ecx
  8012f5:	83 e9 57             	sub    $0x57,%ecx
  8012f8:	eb 0f                	jmp    801309 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8012fa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8012fd:	89 f0                	mov    %esi,%eax
  8012ff:	3c 19                	cmp    $0x19,%al
  801301:	77 16                	ja     801319 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801303:	0f be c9             	movsbl %cl,%ecx
  801306:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801309:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80130c:	7d 0f                	jge    80131d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80130e:	83 c2 01             	add    $0x1,%edx
  801311:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801315:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801317:	eb bc                	jmp    8012d5 <strtol+0x72>
  801319:	89 d8                	mov    %ebx,%eax
  80131b:	eb 02                	jmp    80131f <strtol+0xbc>
  80131d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80131f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801323:	74 05                	je     80132a <strtol+0xc7>
		*endptr = (char *) s;
  801325:	8b 75 0c             	mov    0xc(%ebp),%esi
  801328:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80132a:	f7 d8                	neg    %eax
  80132c:	85 ff                	test   %edi,%edi
  80132e:	0f 44 c3             	cmove  %ebx,%eax
}
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80133c:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801343:	75 32                	jne    801377 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc( sys_getenvid() , ( void * ) ( UXSTACKTOP - PGSIZE ) , PTE_U | PTE_W | PTE_P ) ;
  801345:	e8 fe ed ff ff       	call   800148 <sys_getenvid>
  80134a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801351:	00 
  801352:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801359:	ee 
  80135a:	89 04 24             	mov    %eax,(%esp)
  80135d:	e8 24 ee ff ff       	call   800186 <sys_page_alloc>
		sys_env_set_pgfault_upcall( sys_getenvid() , _pgfault_upcall ) ;  	
  801362:	e8 e1 ed ff ff       	call   800148 <sys_getenvid>
  801367:	c7 44 24 04 9b 03 80 	movl   $0x80039b,0x4(%esp)
  80136e:	00 
  80136f:	89 04 24             	mov    %eax,(%esp)
  801372:	e8 5c ef ff ff       	call   8002d3 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801377:	8b 45 08             	mov    0x8(%ebp),%eax
  80137a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    
  801381:	66 90                	xchg   %ax,%ax
  801383:	66 90                	xchg   %ax,%ax
  801385:	66 90                	xchg   %ax,%ax
  801387:	66 90                	xchg   %ax,%ax
  801389:	66 90                	xchg   %ax,%ax
  80138b:	66 90                	xchg   %ax,%ax
  80138d:	66 90                	xchg   %ax,%ax
  80138f:	90                   	nop

00801390 <__udivdi3>:
  801390:	55                   	push   %ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	8b 44 24 28          	mov    0x28(%esp),%eax
  80139a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80139e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013ac:	89 ea                	mov    %ebp,%edx
  8013ae:	89 0c 24             	mov    %ecx,(%esp)
  8013b1:	75 2d                	jne    8013e0 <__udivdi3+0x50>
  8013b3:	39 e9                	cmp    %ebp,%ecx
  8013b5:	77 61                	ja     801418 <__udivdi3+0x88>
  8013b7:	85 c9                	test   %ecx,%ecx
  8013b9:	89 ce                	mov    %ecx,%esi
  8013bb:	75 0b                	jne    8013c8 <__udivdi3+0x38>
  8013bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c2:	31 d2                	xor    %edx,%edx
  8013c4:	f7 f1                	div    %ecx
  8013c6:	89 c6                	mov    %eax,%esi
  8013c8:	31 d2                	xor    %edx,%edx
  8013ca:	89 e8                	mov    %ebp,%eax
  8013cc:	f7 f6                	div    %esi
  8013ce:	89 c5                	mov    %eax,%ebp
  8013d0:	89 f8                	mov    %edi,%eax
  8013d2:	f7 f6                	div    %esi
  8013d4:	89 ea                	mov    %ebp,%edx
  8013d6:	83 c4 0c             	add    $0xc,%esp
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    
  8013dd:	8d 76 00             	lea    0x0(%esi),%esi
  8013e0:	39 e8                	cmp    %ebp,%eax
  8013e2:	77 24                	ja     801408 <__udivdi3+0x78>
  8013e4:	0f bd e8             	bsr    %eax,%ebp
  8013e7:	83 f5 1f             	xor    $0x1f,%ebp
  8013ea:	75 3c                	jne    801428 <__udivdi3+0x98>
  8013ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013f0:	39 34 24             	cmp    %esi,(%esp)
  8013f3:	0f 86 9f 00 00 00    	jbe    801498 <__udivdi3+0x108>
  8013f9:	39 d0                	cmp    %edx,%eax
  8013fb:	0f 82 97 00 00 00    	jb     801498 <__udivdi3+0x108>
  801401:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801408:	31 d2                	xor    %edx,%edx
  80140a:	31 c0                	xor    %eax,%eax
  80140c:	83 c4 0c             	add    $0xc,%esp
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	89 f8                	mov    %edi,%eax
  80141a:	f7 f1                	div    %ecx
  80141c:	31 d2                	xor    %edx,%edx
  80141e:	83 c4 0c             	add    $0xc,%esp
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    
  801425:	8d 76 00             	lea    0x0(%esi),%esi
  801428:	89 e9                	mov    %ebp,%ecx
  80142a:	8b 3c 24             	mov    (%esp),%edi
  80142d:	d3 e0                	shl    %cl,%eax
  80142f:	89 c6                	mov    %eax,%esi
  801431:	b8 20 00 00 00       	mov    $0x20,%eax
  801436:	29 e8                	sub    %ebp,%eax
  801438:	89 c1                	mov    %eax,%ecx
  80143a:	d3 ef                	shr    %cl,%edi
  80143c:	89 e9                	mov    %ebp,%ecx
  80143e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801442:	8b 3c 24             	mov    (%esp),%edi
  801445:	09 74 24 08          	or     %esi,0x8(%esp)
  801449:	89 d6                	mov    %edx,%esi
  80144b:	d3 e7                	shl    %cl,%edi
  80144d:	89 c1                	mov    %eax,%ecx
  80144f:	89 3c 24             	mov    %edi,(%esp)
  801452:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801456:	d3 ee                	shr    %cl,%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	d3 e2                	shl    %cl,%edx
  80145c:	89 c1                	mov    %eax,%ecx
  80145e:	d3 ef                	shr    %cl,%edi
  801460:	09 d7                	or     %edx,%edi
  801462:	89 f2                	mov    %esi,%edx
  801464:	89 f8                	mov    %edi,%eax
  801466:	f7 74 24 08          	divl   0x8(%esp)
  80146a:	89 d6                	mov    %edx,%esi
  80146c:	89 c7                	mov    %eax,%edi
  80146e:	f7 24 24             	mull   (%esp)
  801471:	39 d6                	cmp    %edx,%esi
  801473:	89 14 24             	mov    %edx,(%esp)
  801476:	72 30                	jb     8014a8 <__udivdi3+0x118>
  801478:	8b 54 24 04          	mov    0x4(%esp),%edx
  80147c:	89 e9                	mov    %ebp,%ecx
  80147e:	d3 e2                	shl    %cl,%edx
  801480:	39 c2                	cmp    %eax,%edx
  801482:	73 05                	jae    801489 <__udivdi3+0xf9>
  801484:	3b 34 24             	cmp    (%esp),%esi
  801487:	74 1f                	je     8014a8 <__udivdi3+0x118>
  801489:	89 f8                	mov    %edi,%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	e9 7a ff ff ff       	jmp    80140c <__udivdi3+0x7c>
  801492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801498:	31 d2                	xor    %edx,%edx
  80149a:	b8 01 00 00 00       	mov    $0x1,%eax
  80149f:	e9 68 ff ff ff       	jmp    80140c <__udivdi3+0x7c>
  8014a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014ab:	31 d2                	xor    %edx,%edx
  8014ad:	83 c4 0c             	add    $0xc,%esp
  8014b0:	5e                   	pop    %esi
  8014b1:	5f                   	pop    %edi
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    
  8014b4:	66 90                	xchg   %ax,%ax
  8014b6:	66 90                	xchg   %ax,%ax
  8014b8:	66 90                	xchg   %ax,%ax
  8014ba:	66 90                	xchg   %ax,%ax
  8014bc:	66 90                	xchg   %ax,%ax
  8014be:	66 90                	xchg   %ax,%ax

008014c0 <__umoddi3>:
  8014c0:	55                   	push   %ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	83 ec 14             	sub    $0x14,%esp
  8014c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014d2:	89 c7                	mov    %eax,%edi
  8014d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014e0:	89 34 24             	mov    %esi,(%esp)
  8014e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014ef:	75 17                	jne    801508 <__umoddi3+0x48>
  8014f1:	39 fe                	cmp    %edi,%esi
  8014f3:	76 4b                	jbe    801540 <__umoddi3+0x80>
  8014f5:	89 c8                	mov    %ecx,%eax
  8014f7:	89 fa                	mov    %edi,%edx
  8014f9:	f7 f6                	div    %esi
  8014fb:	89 d0                	mov    %edx,%eax
  8014fd:	31 d2                	xor    %edx,%edx
  8014ff:	83 c4 14             	add    $0x14,%esp
  801502:	5e                   	pop    %esi
  801503:	5f                   	pop    %edi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    
  801506:	66 90                	xchg   %ax,%ax
  801508:	39 f8                	cmp    %edi,%eax
  80150a:	77 54                	ja     801560 <__umoddi3+0xa0>
  80150c:	0f bd e8             	bsr    %eax,%ebp
  80150f:	83 f5 1f             	xor    $0x1f,%ebp
  801512:	75 5c                	jne    801570 <__umoddi3+0xb0>
  801514:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801518:	39 3c 24             	cmp    %edi,(%esp)
  80151b:	0f 87 e7 00 00 00    	ja     801608 <__umoddi3+0x148>
  801521:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801525:	29 f1                	sub    %esi,%ecx
  801527:	19 c7                	sbb    %eax,%edi
  801529:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80152d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801531:	8b 44 24 08          	mov    0x8(%esp),%eax
  801535:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801539:	83 c4 14             	add    $0x14,%esp
  80153c:	5e                   	pop    %esi
  80153d:	5f                   	pop    %edi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    
  801540:	85 f6                	test   %esi,%esi
  801542:	89 f5                	mov    %esi,%ebp
  801544:	75 0b                	jne    801551 <__umoddi3+0x91>
  801546:	b8 01 00 00 00       	mov    $0x1,%eax
  80154b:	31 d2                	xor    %edx,%edx
  80154d:	f7 f6                	div    %esi
  80154f:	89 c5                	mov    %eax,%ebp
  801551:	8b 44 24 04          	mov    0x4(%esp),%eax
  801555:	31 d2                	xor    %edx,%edx
  801557:	f7 f5                	div    %ebp
  801559:	89 c8                	mov    %ecx,%eax
  80155b:	f7 f5                	div    %ebp
  80155d:	eb 9c                	jmp    8014fb <__umoddi3+0x3b>
  80155f:	90                   	nop
  801560:	89 c8                	mov    %ecx,%eax
  801562:	89 fa                	mov    %edi,%edx
  801564:	83 c4 14             	add    $0x14,%esp
  801567:	5e                   	pop    %esi
  801568:	5f                   	pop    %edi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    
  80156b:	90                   	nop
  80156c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801570:	8b 04 24             	mov    (%esp),%eax
  801573:	be 20 00 00 00       	mov    $0x20,%esi
  801578:	89 e9                	mov    %ebp,%ecx
  80157a:	29 ee                	sub    %ebp,%esi
  80157c:	d3 e2                	shl    %cl,%edx
  80157e:	89 f1                	mov    %esi,%ecx
  801580:	d3 e8                	shr    %cl,%eax
  801582:	89 e9                	mov    %ebp,%ecx
  801584:	89 44 24 04          	mov    %eax,0x4(%esp)
  801588:	8b 04 24             	mov    (%esp),%eax
  80158b:	09 54 24 04          	or     %edx,0x4(%esp)
  80158f:	89 fa                	mov    %edi,%edx
  801591:	d3 e0                	shl    %cl,%eax
  801593:	89 f1                	mov    %esi,%ecx
  801595:	89 44 24 08          	mov    %eax,0x8(%esp)
  801599:	8b 44 24 10          	mov    0x10(%esp),%eax
  80159d:	d3 ea                	shr    %cl,%edx
  80159f:	89 e9                	mov    %ebp,%ecx
  8015a1:	d3 e7                	shl    %cl,%edi
  8015a3:	89 f1                	mov    %esi,%ecx
  8015a5:	d3 e8                	shr    %cl,%eax
  8015a7:	89 e9                	mov    %ebp,%ecx
  8015a9:	09 f8                	or     %edi,%eax
  8015ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015af:	f7 74 24 04          	divl   0x4(%esp)
  8015b3:	d3 e7                	shl    %cl,%edi
  8015b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015b9:	89 d7                	mov    %edx,%edi
  8015bb:	f7 64 24 08          	mull   0x8(%esp)
  8015bf:	39 d7                	cmp    %edx,%edi
  8015c1:	89 c1                	mov    %eax,%ecx
  8015c3:	89 14 24             	mov    %edx,(%esp)
  8015c6:	72 2c                	jb     8015f4 <__umoddi3+0x134>
  8015c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8015cc:	72 22                	jb     8015f0 <__umoddi3+0x130>
  8015ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015d2:	29 c8                	sub    %ecx,%eax
  8015d4:	19 d7                	sbb    %edx,%edi
  8015d6:	89 e9                	mov    %ebp,%ecx
  8015d8:	89 fa                	mov    %edi,%edx
  8015da:	d3 e8                	shr    %cl,%eax
  8015dc:	89 f1                	mov    %esi,%ecx
  8015de:	d3 e2                	shl    %cl,%edx
  8015e0:	89 e9                	mov    %ebp,%ecx
  8015e2:	d3 ef                	shr    %cl,%edi
  8015e4:	09 d0                	or     %edx,%eax
  8015e6:	89 fa                	mov    %edi,%edx
  8015e8:	83 c4 14             	add    $0x14,%esp
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    
  8015ef:	90                   	nop
  8015f0:	39 d7                	cmp    %edx,%edi
  8015f2:	75 da                	jne    8015ce <__umoddi3+0x10e>
  8015f4:	8b 14 24             	mov    (%esp),%edx
  8015f7:	89 c1                	mov    %eax,%ecx
  8015f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8015fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801601:	eb cb                	jmp    8015ce <__umoddi3+0x10e>
  801603:	90                   	nop
  801604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801608:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80160c:	0f 82 0f ff ff ff    	jb     801521 <__umoddi3+0x61>
  801612:	e9 1a ff ff ff       	jmp    801531 <__umoddi3+0x71>
