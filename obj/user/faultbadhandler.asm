
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800048:	ee 
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 4d 01 00 00       	call   8001a2 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800055:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005c:	de 
  80005d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800064:	e8 86 02 00 00       	call   8002ef <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800069:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800070:	00 00 00 
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	83 ec 10             	sub    $0x10,%esp
  80007d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800080:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800083:	e8 dc 00 00 00       	call   800164 <sys_getenvid>
  800088:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008d:	89 c2                	mov    %eax,%edx
  80008f:	c1 e2 07             	shl    $0x7,%edx
  800092:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800099:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009e:	85 db                	test   %ebx,%ebx
  8000a0:	7e 07                	jle    8000a9 <libmain+0x34>
		binaryname = argv[0];
  8000a2:	8b 06                	mov    (%esi),%eax
  8000a4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ad:	89 1c 24             	mov    %ebx,(%esp)
  8000b0:	e8 7e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b5:	e8 07 00 00 00       	call   8000c1 <exit>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ce:	e8 3f 00 00 00       	call   800112 <sys_env_destroy>
}
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    

008000d5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000db:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e6:	89 c3                	mov    %eax,%ebx
  8000e8:	89 c7                	mov    %eax,%edi
  8000ea:	89 c6                	mov    %eax,%esi
  8000ec:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fe:	b8 01 00 00 00       	mov    $0x1,%eax
  800103:	89 d1                	mov    %edx,%ecx
  800105:	89 d3                	mov    %edx,%ebx
  800107:	89 d7                	mov    %edx,%edi
  800109:	89 d6                	mov    %edx,%esi
  80010b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5f                   	pop    %edi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    

00800112 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	57                   	push   %edi
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
  800118:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800120:	b8 03 00 00 00       	mov    $0x3,%eax
  800125:	8b 55 08             	mov    0x8(%ebp),%edx
  800128:	89 cb                	mov    %ecx,%ebx
  80012a:	89 cf                	mov    %ecx,%edi
  80012c:	89 ce                	mov    %ecx,%esi
  80012e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800130:	85 c0                	test   %eax,%eax
  800132:	7e 28                	jle    80015c <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800134:	89 44 24 10          	mov    %eax,0x10(%esp)
  800138:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013f:	00 
  800140:	c7 44 24 08 ca 15 80 	movl   $0x8015ca,0x8(%esp)
  800147:	00 
  800148:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014f:	00 
  800150:	c7 04 24 e7 15 80 00 	movl   $0x8015e7,(%esp)
  800157:	e8 5b 02 00 00       	call   8003b7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015c:	83 c4 2c             	add    $0x2c,%esp
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5f                   	pop    %edi
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	57                   	push   %edi
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016a:	ba 00 00 00 00       	mov    $0x0,%edx
  80016f:	b8 02 00 00 00       	mov    $0x2,%eax
  800174:	89 d1                	mov    %edx,%ecx
  800176:	89 d3                	mov    %edx,%ebx
  800178:	89 d7                	mov    %edx,%edi
  80017a:	89 d6                	mov    %edx,%esi
  80017c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017e:	5b                   	pop    %ebx
  80017f:	5e                   	pop    %esi
  800180:	5f                   	pop    %edi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <sys_yield>:

void
sys_yield(void)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800189:	ba 00 00 00 00       	mov    $0x0,%edx
  80018e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800193:	89 d1                	mov    %edx,%ecx
  800195:	89 d3                	mov    %edx,%ebx
  800197:	89 d7                	mov    %edx,%edi
  800199:	89 d6                	mov    %edx,%esi
  80019b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80019d:	5b                   	pop    %ebx
  80019e:	5e                   	pop    %esi
  80019f:	5f                   	pop    %edi
  8001a0:	5d                   	pop    %ebp
  8001a1:	c3                   	ret    

008001a2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	57                   	push   %edi
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ab:	be 00 00 00 00       	mov    $0x0,%esi
  8001b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001be:	89 f7                	mov    %esi,%edi
  8001c0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	7e 28                	jle    8001ee <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ca:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001d1:	00 
  8001d2:	c7 44 24 08 ca 15 80 	movl   $0x8015ca,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 e7 15 80 00 	movl   $0x8015e7,(%esp)
  8001e9:	e8 c9 01 00 00       	call   8003b7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ee:	83 c4 2c             	add    $0x2c,%esp
  8001f1:	5b                   	pop    %ebx
  8001f2:	5e                   	pop    %esi
  8001f3:	5f                   	pop    %edi
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	57                   	push   %edi
  8001fa:	56                   	push   %esi
  8001fb:	53                   	push   %ebx
  8001fc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ff:	b8 05 00 00 00       	mov    $0x5,%eax
  800204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800207:	8b 55 08             	mov    0x8(%ebp),%edx
  80020a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800210:	8b 75 18             	mov    0x18(%ebp),%esi
  800213:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800215:	85 c0                	test   %eax,%eax
  800217:	7e 28                	jle    800241 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800219:	89 44 24 10          	mov    %eax,0x10(%esp)
  80021d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800224:	00 
  800225:	c7 44 24 08 ca 15 80 	movl   $0x8015ca,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 e7 15 80 00 	movl   $0x8015e7,(%esp)
  80023c:	e8 76 01 00 00       	call   8003b7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800241:	83 c4 2c             	add    $0x2c,%esp
  800244:	5b                   	pop    %ebx
  800245:	5e                   	pop    %esi
  800246:	5f                   	pop    %edi
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    

00800249 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	57                   	push   %edi
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800252:	bb 00 00 00 00       	mov    $0x0,%ebx
  800257:	b8 06 00 00 00       	mov    $0x6,%eax
  80025c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025f:	8b 55 08             	mov    0x8(%ebp),%edx
  800262:	89 df                	mov    %ebx,%edi
  800264:	89 de                	mov    %ebx,%esi
  800266:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800268:	85 c0                	test   %eax,%eax
  80026a:	7e 28                	jle    800294 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800270:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800277:	00 
  800278:	c7 44 24 08 ca 15 80 	movl   $0x8015ca,0x8(%esp)
  80027f:	00 
  800280:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800287:	00 
  800288:	c7 04 24 e7 15 80 00 	movl   $0x8015e7,(%esp)
  80028f:	e8 23 01 00 00       	call   8003b7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800294:	83 c4 2c             	add    $0x2c,%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    

0080029c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8002af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b5:	89 df                	mov    %ebx,%edi
  8002b7:	89 de                	mov    %ebx,%esi
  8002b9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002bb:	85 c0                	test   %eax,%eax
  8002bd:	7e 28                	jle    8002e7 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c3:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002ca:	00 
  8002cb:	c7 44 24 08 ca 15 80 	movl   $0x8015ca,0x8(%esp)
  8002d2:	00 
  8002d3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002da:	00 
  8002db:	c7 04 24 e7 15 80 00 	movl   $0x8015e7,(%esp)
  8002e2:	e8 d0 00 00 00       	call   8003b7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002e7:	83 c4 2c             	add    $0x2c,%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	57                   	push   %edi
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fd:	b8 09 00 00 00       	mov    $0x9,%eax
  800302:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	89 df                	mov    %ebx,%edi
  80030a:	89 de                	mov    %ebx,%esi
  80030c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80030e:	85 c0                	test   %eax,%eax
  800310:	7e 28                	jle    80033a <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800312:	89 44 24 10          	mov    %eax,0x10(%esp)
  800316:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80031d:	00 
  80031e:	c7 44 24 08 ca 15 80 	movl   $0x8015ca,0x8(%esp)
  800325:	00 
  800326:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032d:	00 
  80032e:	c7 04 24 e7 15 80 00 	movl   $0x8015e7,(%esp)
  800335:	e8 7d 00 00 00       	call   8003b7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80033a:	83 c4 2c             	add    $0x2c,%esp
  80033d:	5b                   	pop    %ebx
  80033e:	5e                   	pop    %esi
  80033f:	5f                   	pop    %edi
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	57                   	push   %edi
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800348:	be 00 00 00 00       	mov    $0x0,%esi
  80034d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800352:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800355:	8b 55 08             	mov    0x8(%ebp),%edx
  800358:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80035e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	57                   	push   %edi
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
  80036b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800373:	b8 0c 00 00 00       	mov    $0xc,%eax
  800378:	8b 55 08             	mov    0x8(%ebp),%edx
  80037b:	89 cb                	mov    %ecx,%ebx
  80037d:	89 cf                	mov    %ecx,%edi
  80037f:	89 ce                	mov    %ecx,%esi
  800381:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800383:	85 c0                	test   %eax,%eax
  800385:	7e 28                	jle    8003af <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800387:	89 44 24 10          	mov    %eax,0x10(%esp)
  80038b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800392:	00 
  800393:	c7 44 24 08 ca 15 80 	movl   $0x8015ca,0x8(%esp)
  80039a:	00 
  80039b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003a2:	00 
  8003a3:	c7 04 24 e7 15 80 00 	movl   $0x8015e7,(%esp)
  8003aa:	e8 08 00 00 00       	call   8003b7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003af:	83 c4 2c             	add    $0x2c,%esp
  8003b2:	5b                   	pop    %ebx
  8003b3:	5e                   	pop    %esi
  8003b4:	5f                   	pop    %edi
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	56                   	push   %esi
  8003bb:	53                   	push   %ebx
  8003bc:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003bf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003c2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003c8:	e8 97 fd ff ff       	call   800164 <sys_getenvid>
  8003cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003db:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e3:	c7 04 24 f8 15 80 00 	movl   $0x8015f8,(%esp)
  8003ea:	e8 c1 00 00 00       	call   8004b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f6:	89 04 24             	mov    %eax,(%esp)
  8003f9:	e8 51 00 00 00       	call   80044f <vcprintf>
	cprintf("\n");
  8003fe:	c7 04 24 1c 16 80 00 	movl   $0x80161c,(%esp)
  800405:	e8 a6 00 00 00       	call   8004b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80040a:	cc                   	int3   
  80040b:	eb fd                	jmp    80040a <_panic+0x53>

0080040d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	53                   	push   %ebx
  800411:	83 ec 14             	sub    $0x14,%esp
  800414:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800417:	8b 13                	mov    (%ebx),%edx
  800419:	8d 42 01             	lea    0x1(%edx),%eax
  80041c:	89 03                	mov    %eax,(%ebx)
  80041e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800421:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800425:	3d ff 00 00 00       	cmp    $0xff,%eax
  80042a:	75 19                	jne    800445 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80042c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800433:	00 
  800434:	8d 43 08             	lea    0x8(%ebx),%eax
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	e8 96 fc ff ff       	call   8000d5 <sys_cputs>
		b->idx = 0;
  80043f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800445:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800449:	83 c4 14             	add    $0x14,%esp
  80044c:	5b                   	pop    %ebx
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800458:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80045f:	00 00 00 
	b.cnt = 0;
  800462:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800469:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80046c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800473:	8b 45 08             	mov    0x8(%ebp),%eax
  800476:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800480:	89 44 24 04          	mov    %eax,0x4(%esp)
  800484:	c7 04 24 0d 04 80 00 	movl   $0x80040d,(%esp)
  80048b:	e8 af 02 00 00       	call   80073f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800490:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 2d fc ff ff       	call   8000d5 <sys_cputs>

	return b.cnt;
}
  8004a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c0:	89 04 24             	mov    %eax,(%esp)
  8004c3:	e8 87 ff ff ff       	call   80044f <vcprintf>
	va_end(ap);

	return cnt;
}
  8004c8:	c9                   	leave  
  8004c9:	c3                   	ret    
  8004ca:	66 90                	xchg   %ax,%ax
  8004cc:	66 90                	xchg   %ax,%ax
  8004ce:	66 90                	xchg   %ax,%ax

008004d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	57                   	push   %edi
  8004d4:	56                   	push   %esi
  8004d5:	53                   	push   %ebx
  8004d6:	83 ec 3c             	sub    $0x3c,%esp
  8004d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004dc:	89 d7                	mov    %edx,%edi
  8004de:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e7:	89 c3                	mov    %eax,%ebx
  8004e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004fd:	39 d9                	cmp    %ebx,%ecx
  8004ff:	72 05                	jb     800506 <printnum+0x36>
  800501:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800504:	77 69                	ja     80056f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800506:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800509:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80050d:	83 ee 01             	sub    $0x1,%esi
  800510:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800514:	89 44 24 08          	mov    %eax,0x8(%esp)
  800518:	8b 44 24 08          	mov    0x8(%esp),%eax
  80051c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800520:	89 c3                	mov    %eax,%ebx
  800522:	89 d6                	mov    %edx,%esi
  800524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80052e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80053b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053f:	e8 ec 0d 00 00       	call   801330 <__udivdi3>
  800544:	89 d9                	mov    %ebx,%ecx
  800546:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80054a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	89 54 24 04          	mov    %edx,0x4(%esp)
  800555:	89 fa                	mov    %edi,%edx
  800557:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80055a:	e8 71 ff ff ff       	call   8004d0 <printnum>
  80055f:	eb 1b                	jmp    80057c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800561:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800565:	8b 45 18             	mov    0x18(%ebp),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff d3                	call   *%ebx
  80056d:	eb 03                	jmp    800572 <printnum+0xa2>
  80056f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800572:	83 ee 01             	sub    $0x1,%esi
  800575:	85 f6                	test   %esi,%esi
  800577:	7f e8                	jg     800561 <printnum+0x91>
  800579:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80057c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800580:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800584:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800587:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800592:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800595:	89 04 24             	mov    %eax,(%esp)
  800598:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80059b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059f:	e8 bc 0e 00 00       	call   801460 <__umoddi3>
  8005a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a8:	0f be 80 1e 16 80 00 	movsbl 0x80161e(%eax),%eax
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b5:	ff d0                	call   *%eax
}
  8005b7:	83 c4 3c             	add    $0x3c,%esp
  8005ba:	5b                   	pop    %ebx
  8005bb:	5e                   	pop    %esi
  8005bc:	5f                   	pop    %edi
  8005bd:	5d                   	pop    %ebp
  8005be:	c3                   	ret    

008005bf <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	57                   	push   %edi
  8005c3:	56                   	push   %esi
  8005c4:	53                   	push   %ebx
  8005c5:	83 ec 3c             	sub    $0x3c,%esp
  8005c8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005cb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ce:	89 cf                	mov    %ecx,%edi
  8005d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d9:	89 c3                	mov    %eax,%ebx
  8005db:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005de:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ec:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005ef:	39 d9                	cmp    %ebx,%ecx
  8005f1:	72 13                	jb     800606 <cprintnum+0x47>
  8005f3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8005f6:	76 0e                	jbe    800606 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8005f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005fb:	0b 45 18             	or     0x18(%ebp),%eax
  8005fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800601:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800604:	eb 6a                	jmp    800670 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  800606:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800609:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80060d:	83 ee 01             	sub    $0x1,%esi
  800610:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800614:	89 44 24 08          	mov    %eax,0x8(%esp)
  800618:	8b 44 24 08          	mov    0x8(%esp),%eax
  80061c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800620:	89 c3                	mov    %eax,%ebx
  800622:	89 d6                	mov    %edx,%esi
  800624:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800627:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80062a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80062e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800632:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80063b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063f:	e8 ec 0c 00 00       	call   801330 <__udivdi3>
  800644:	89 d9                	mov    %ebx,%ecx
  800646:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80064a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80064e:	89 04 24             	mov    %eax,(%esp)
  800651:	89 54 24 04          	mov    %edx,0x4(%esp)
  800655:	89 f9                	mov    %edi,%ecx
  800657:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80065a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80065d:	e8 5d ff ff ff       	call   8005bf <cprintnum>
  800662:	eb 16                	jmp    80067a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800664:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800670:	83 ee 01             	sub    $0x1,%esi
  800673:	85 f6                	test   %esi,%esi
  800675:	7f ed                	jg     800664 <cprintnum+0xa5>
  800677:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80067a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800682:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800685:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800688:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800690:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	e8 be 0d 00 00       	call   801460 <__umoddi3>
  8006a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a6:	0f be 80 1e 16 80 00 	movsbl 0x80161e(%eax),%eax
  8006ad:	0b 45 dc             	or     -0x24(%ebp),%eax
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006b6:	ff d0                	call   *%eax
}
  8006b8:	83 c4 3c             	add    $0x3c,%esp
  8006bb:	5b                   	pop    %ebx
  8006bc:	5e                   	pop    %esi
  8006bd:	5f                   	pop    %edi
  8006be:	5d                   	pop    %ebp
  8006bf:	c3                   	ret    

008006c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006c3:	83 fa 01             	cmp    $0x1,%edx
  8006c6:	7e 0e                	jle    8006d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006cd:	89 08                	mov    %ecx,(%eax)
  8006cf:	8b 02                	mov    (%edx),%eax
  8006d1:	8b 52 04             	mov    0x4(%edx),%edx
  8006d4:	eb 22                	jmp    8006f8 <getuint+0x38>
	else if (lflag)
  8006d6:	85 d2                	test   %edx,%edx
  8006d8:	74 10                	je     8006ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006da:	8b 10                	mov    (%eax),%edx
  8006dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006df:	89 08                	mov    %ecx,(%eax)
  8006e1:	8b 02                	mov    (%edx),%eax
  8006e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e8:	eb 0e                	jmp    8006f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ef:	89 08                	mov    %ecx,(%eax)
  8006f1:	8b 02                	mov    (%edx),%eax
  8006f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800700:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800704:	8b 10                	mov    (%eax),%edx
  800706:	3b 50 04             	cmp    0x4(%eax),%edx
  800709:	73 0a                	jae    800715 <sprintputch+0x1b>
		*b->buf++ = ch;
  80070b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80070e:	89 08                	mov    %ecx,(%eax)
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	88 02                	mov    %al,(%edx)
}
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80071d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800720:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800724:	8b 45 10             	mov    0x10(%ebp),%eax
  800727:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	89 04 24             	mov    %eax,(%esp)
  800738:	e8 02 00 00 00       	call   80073f <vprintfmt>
	va_end(ap);
}
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	57                   	push   %edi
  800743:	56                   	push   %esi
  800744:	53                   	push   %ebx
  800745:	83 ec 3c             	sub    $0x3c,%esp
  800748:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80074b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80074e:	eb 14                	jmp    800764 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800750:	85 c0                	test   %eax,%eax
  800752:	0f 84 b3 03 00 00    	je     800b0b <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800758:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075c:	89 04 24             	mov    %eax,(%esp)
  80075f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800762:	89 f3                	mov    %esi,%ebx
  800764:	8d 73 01             	lea    0x1(%ebx),%esi
  800767:	0f b6 03             	movzbl (%ebx),%eax
  80076a:	83 f8 25             	cmp    $0x25,%eax
  80076d:	75 e1                	jne    800750 <vprintfmt+0x11>
  80076f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800773:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80077a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800781:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800788:	ba 00 00 00 00       	mov    $0x0,%edx
  80078d:	eb 1d                	jmp    8007ac <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800791:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800795:	eb 15                	jmp    8007ac <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800797:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800799:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80079d:	eb 0d                	jmp    8007ac <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80079f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007a5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ac:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007af:	0f b6 0e             	movzbl (%esi),%ecx
  8007b2:	0f b6 c1             	movzbl %cl,%eax
  8007b5:	83 e9 23             	sub    $0x23,%ecx
  8007b8:	80 f9 55             	cmp    $0x55,%cl
  8007bb:	0f 87 2a 03 00 00    	ja     800aeb <vprintfmt+0x3ac>
  8007c1:	0f b6 c9             	movzbl %cl,%ecx
  8007c4:	ff 24 8d e0 16 80 00 	jmp    *0x8016e0(,%ecx,4)
  8007cb:	89 de                	mov    %ebx,%esi
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007d2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8007d5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8007d9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007dc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8007df:	83 fb 09             	cmp    $0x9,%ebx
  8007e2:	77 36                	ja     80081a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007e4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007e7:	eb e9                	jmp    8007d2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8d 48 04             	lea    0x4(%eax),%ecx
  8007ef:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007f2:	8b 00                	mov    (%eax),%eax
  8007f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007f9:	eb 22                	jmp    80081d <vprintfmt+0xde>
  8007fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007fe:	85 c9                	test   %ecx,%ecx
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
  800805:	0f 49 c1             	cmovns %ecx,%eax
  800808:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080b:	89 de                	mov    %ebx,%esi
  80080d:	eb 9d                	jmp    8007ac <vprintfmt+0x6d>
  80080f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800811:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800818:	eb 92                	jmp    8007ac <vprintfmt+0x6d>
  80081a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80081d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800821:	79 89                	jns    8007ac <vprintfmt+0x6d>
  800823:	e9 77 ff ff ff       	jmp    80079f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800828:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80082d:	e9 7a ff ff ff       	jmp    8007ac <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8d 50 04             	lea    0x4(%eax),%edx
  800838:	89 55 14             	mov    %edx,0x14(%ebp)
  80083b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80083f:	8b 00                	mov    (%eax),%eax
  800841:	89 04 24             	mov    %eax,(%esp)
  800844:	ff 55 08             	call   *0x8(%ebp)
			break;
  800847:	e9 18 ff ff ff       	jmp    800764 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 04             	lea    0x4(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 00                	mov    (%eax),%eax
  800857:	99                   	cltd   
  800858:	31 d0                	xor    %edx,%eax
  80085a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80085c:	83 f8 09             	cmp    $0x9,%eax
  80085f:	7f 0b                	jg     80086c <vprintfmt+0x12d>
  800861:	8b 14 85 a0 19 80 00 	mov    0x8019a0(,%eax,4),%edx
  800868:	85 d2                	test   %edx,%edx
  80086a:	75 20                	jne    80088c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80086c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800870:	c7 44 24 08 36 16 80 	movl   $0x801636,0x8(%esp)
  800877:	00 
  800878:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	89 04 24             	mov    %eax,(%esp)
  800882:	e8 90 fe ff ff       	call   800717 <printfmt>
  800887:	e9 d8 fe ff ff       	jmp    800764 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80088c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800890:	c7 44 24 08 3f 16 80 	movl   $0x80163f,0x8(%esp)
  800897:	00 
  800898:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	89 04 24             	mov    %eax,(%esp)
  8008a2:	e8 70 fe ff ff       	call   800717 <printfmt>
  8008a7:	e9 b8 fe ff ff       	jmp    800764 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ac:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8008af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b8:	8d 50 04             	lea    0x4(%eax),%edx
  8008bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008be:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008c0:	85 f6                	test   %esi,%esi
  8008c2:	b8 2f 16 80 00       	mov    $0x80162f,%eax
  8008c7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8008ca:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8008ce:	0f 84 97 00 00 00    	je     80096b <vprintfmt+0x22c>
  8008d4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008d8:	0f 8e 9b 00 00 00    	jle    800979 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008e2:	89 34 24             	mov    %esi,(%esp)
  8008e5:	e8 ce 06 00 00       	call   800fb8 <strnlen>
  8008ea:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008ed:	29 c2                	sub    %eax,%edx
  8008ef:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8008f2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008f6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008f9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ff:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800902:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800904:	eb 0f                	jmp    800915 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800906:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80090a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800912:	83 eb 01             	sub    $0x1,%ebx
  800915:	85 db                	test   %ebx,%ebx
  800917:	7f ed                	jg     800906 <vprintfmt+0x1c7>
  800919:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80091c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80091f:	85 d2                	test   %edx,%edx
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	0f 49 c2             	cmovns %edx,%eax
  800929:	29 c2                	sub    %eax,%edx
  80092b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80092e:	89 d7                	mov    %edx,%edi
  800930:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800933:	eb 50                	jmp    800985 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800935:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800939:	74 1e                	je     800959 <vprintfmt+0x21a>
  80093b:	0f be d2             	movsbl %dl,%edx
  80093e:	83 ea 20             	sub    $0x20,%edx
  800941:	83 fa 5e             	cmp    $0x5e,%edx
  800944:	76 13                	jbe    800959 <vprintfmt+0x21a>
					putch('?', putdat);
  800946:	8b 45 0c             	mov    0xc(%ebp),%eax
  800949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800954:	ff 55 08             	call   *0x8(%ebp)
  800957:	eb 0d                	jmp    800966 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800960:	89 04 24             	mov    %eax,(%esp)
  800963:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800966:	83 ef 01             	sub    $0x1,%edi
  800969:	eb 1a                	jmp    800985 <vprintfmt+0x246>
  80096b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80096e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800971:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800974:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800977:	eb 0c                	jmp    800985 <vprintfmt+0x246>
  800979:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80097c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80097f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800982:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800985:	83 c6 01             	add    $0x1,%esi
  800988:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80098c:	0f be c2             	movsbl %dl,%eax
  80098f:	85 c0                	test   %eax,%eax
  800991:	74 27                	je     8009ba <vprintfmt+0x27b>
  800993:	85 db                	test   %ebx,%ebx
  800995:	78 9e                	js     800935 <vprintfmt+0x1f6>
  800997:	83 eb 01             	sub    $0x1,%ebx
  80099a:	79 99                	jns    800935 <vprintfmt+0x1f6>
  80099c:	89 f8                	mov    %edi,%eax
  80099e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a4:	89 c3                	mov    %eax,%ebx
  8009a6:	eb 1a                	jmp    8009c2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ac:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009b3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009b5:	83 eb 01             	sub    $0x1,%ebx
  8009b8:	eb 08                	jmp    8009c2 <vprintfmt+0x283>
  8009ba:	89 fb                	mov    %edi,%ebx
  8009bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bf:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009c2:	85 db                	test   %ebx,%ebx
  8009c4:	7f e2                	jg     8009a8 <vprintfmt+0x269>
  8009c6:	89 75 08             	mov    %esi,0x8(%ebp)
  8009c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009cc:	e9 93 fd ff ff       	jmp    800764 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009d1:	83 fa 01             	cmp    $0x1,%edx
  8009d4:	7e 16                	jle    8009ec <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8009d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d9:	8d 50 08             	lea    0x8(%eax),%edx
  8009dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8009df:	8b 50 04             	mov    0x4(%eax),%edx
  8009e2:	8b 00                	mov    (%eax),%eax
  8009e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009e7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009ea:	eb 32                	jmp    800a1e <vprintfmt+0x2df>
	else if (lflag)
  8009ec:	85 d2                	test   %edx,%edx
  8009ee:	74 18                	je     800a08 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8009f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f3:	8d 50 04             	lea    0x4(%eax),%edx
  8009f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f9:	8b 30                	mov    (%eax),%esi
  8009fb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009fe:	89 f0                	mov    %esi,%eax
  800a00:	c1 f8 1f             	sar    $0x1f,%eax
  800a03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a06:	eb 16                	jmp    800a1e <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800a08:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0b:	8d 50 04             	lea    0x4(%eax),%edx
  800a0e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a11:	8b 30                	mov    (%eax),%esi
  800a13:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a16:	89 f0                	mov    %esi,%eax
  800a18:	c1 f8 1f             	sar    $0x1f,%eax
  800a1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a24:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a29:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a2d:	0f 89 80 00 00 00    	jns    800ab3 <vprintfmt+0x374>
				putch('-', putdat);
  800a33:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a37:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a3e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a41:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a47:	f7 d8                	neg    %eax
  800a49:	83 d2 00             	adc    $0x0,%edx
  800a4c:	f7 da                	neg    %edx
			}
			base = 10;
  800a4e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a53:	eb 5e                	jmp    800ab3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a55:	8d 45 14             	lea    0x14(%ebp),%eax
  800a58:	e8 63 fc ff ff       	call   8006c0 <getuint>
			base = 10;
  800a5d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a62:	eb 4f                	jmp    800ab3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800a64:	8d 45 14             	lea    0x14(%ebp),%eax
  800a67:	e8 54 fc ff ff       	call   8006c0 <getuint>
			base = 8 ;
  800a6c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800a71:	eb 40                	jmp    800ab3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800a73:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a77:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a7e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a81:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a85:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a8c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a92:	8d 50 04             	lea    0x4(%eax),%edx
  800a95:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a98:	8b 00                	mov    (%eax),%eax
  800a9a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a9f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800aa4:	eb 0d                	jmp    800ab3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aa6:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa9:	e8 12 fc ff ff       	call   8006c0 <getuint>
			base = 16;
  800aae:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab3:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800ab7:	89 74 24 10          	mov    %esi,0x10(%esp)
  800abb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800abe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ac2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ac6:	89 04 24             	mov    %eax,(%esp)
  800ac9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800acd:	89 fa                	mov    %edi,%edx
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	e8 f9 f9 ff ff       	call   8004d0 <printnum>
			break;
  800ad7:	e9 88 fc ff ff       	jmp    800764 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800adc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae0:	89 04 24             	mov    %eax,(%esp)
  800ae3:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ae6:	e9 79 fc ff ff       	jmp    800764 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aeb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aef:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800af6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	eb 03                	jmp    800b00 <vprintfmt+0x3c1>
  800afd:	83 eb 01             	sub    $0x1,%ebx
  800b00:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800b04:	75 f7                	jne    800afd <vprintfmt+0x3be>
  800b06:	e9 59 fc ff ff       	jmp    800764 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800b0b:	83 c4 3c             	add    $0x3c,%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	83 ec 3c             	sub    $0x3c,%esp
  800b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  800b1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b22:	8d 50 04             	lea    0x4(%eax),%edx
  800b25:	89 55 14             	mov    %edx,0x14(%ebp)
  800b28:	8b 00                	mov    (%eax),%eax
  800b2a:	c1 e0 08             	shl    $0x8,%eax
  800b2d:	0f b7 c0             	movzwl %ax,%eax
  800b30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800b33:	83 c8 25             	or     $0x25,%eax
  800b36:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800b39:	eb 1a                	jmp    800b55 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	0f 84 a9 03 00 00    	je     800eec <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800b43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b4a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b4d:	89 04 24             	mov    %eax,(%esp)
  800b50:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b53:	89 fb                	mov    %edi,%ebx
  800b55:	8d 7b 01             	lea    0x1(%ebx),%edi
  800b58:	0f b6 03             	movzbl (%ebx),%eax
  800b5b:	83 f8 25             	cmp    $0x25,%eax
  800b5e:	75 db                	jne    800b3b <cvprintfmt+0x28>
  800b60:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800b64:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800b6b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800b70:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	eb 18                	jmp    800b96 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b7e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800b80:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800b84:	eb 10                	jmp    800b96 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b86:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800b88:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800b8c:	eb 08                	jmp    800b96 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800b8e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800b91:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b96:	8d 5f 01             	lea    0x1(%edi),%ebx
  800b99:	0f b6 0f             	movzbl (%edi),%ecx
  800b9c:	0f b6 c1             	movzbl %cl,%eax
  800b9f:	83 e9 23             	sub    $0x23,%ecx
  800ba2:	80 f9 55             	cmp    $0x55,%cl
  800ba5:	0f 87 1f 03 00 00    	ja     800eca <cvprintfmt+0x3b7>
  800bab:	0f b6 c9             	movzbl %cl,%ecx
  800bae:	ff 24 8d 38 18 80 00 	jmp    *0x801838(,%ecx,4)
  800bb5:	89 df                	mov    %ebx,%edi
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800bbc:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  800bbf:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800bc3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800bc6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800bc9:	83 f9 09             	cmp    $0x9,%ecx
  800bcc:	77 33                	ja     800c01 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800bce:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800bd1:	eb e9                	jmp    800bbc <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800bd3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd6:	8d 48 04             	lea    0x4(%eax),%ecx
  800bd9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bdc:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bde:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800be0:	eb 1f                	jmp    800c01 <cvprintfmt+0xee>
  800be2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800be5:	85 ff                	test   %edi,%edi
  800be7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bec:	0f 49 c7             	cmovns %edi,%eax
  800bef:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf2:	89 df                	mov    %ebx,%edi
  800bf4:	eb a0                	jmp    800b96 <cvprintfmt+0x83>
  800bf6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800bf8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800bff:	eb 95                	jmp    800b96 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800c01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c05:	79 8f                	jns    800b96 <cvprintfmt+0x83>
  800c07:	eb 85                	jmp    800b8e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c09:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c0c:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c0e:	66 90                	xchg   %ax,%ax
  800c10:	eb 84                	jmp    800b96 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800c12:	8b 45 14             	mov    0x14(%ebp),%eax
  800c15:	8d 50 04             	lea    0x4(%eax),%edx
  800c18:	89 55 14             	mov    %edx,0x14(%ebp)
  800c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c25:	0b 10                	or     (%eax),%edx
  800c27:	89 14 24             	mov    %edx,(%esp)
  800c2a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c2d:	e9 23 ff ff ff       	jmp    800b55 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800c32:	8b 45 14             	mov    0x14(%ebp),%eax
  800c35:	8d 50 04             	lea    0x4(%eax),%edx
  800c38:	89 55 14             	mov    %edx,0x14(%ebp)
  800c3b:	8b 00                	mov    (%eax),%eax
  800c3d:	99                   	cltd   
  800c3e:	31 d0                	xor    %edx,%eax
  800c40:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800c42:	83 f8 09             	cmp    $0x9,%eax
  800c45:	7f 0b                	jg     800c52 <cvprintfmt+0x13f>
  800c47:	8b 14 85 a0 19 80 00 	mov    0x8019a0(,%eax,4),%edx
  800c4e:	85 d2                	test   %edx,%edx
  800c50:	75 23                	jne    800c75 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800c52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c56:	c7 44 24 08 36 16 80 	movl   $0x801636,0x8(%esp)
  800c5d:	00 
  800c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c65:	8b 45 08             	mov    0x8(%ebp),%eax
  800c68:	89 04 24             	mov    %eax,(%esp)
  800c6b:	e8 a7 fa ff ff       	call   800717 <printfmt>
  800c70:	e9 e0 fe ff ff       	jmp    800b55 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800c75:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c79:	c7 44 24 08 3f 16 80 	movl   $0x80163f,0x8(%esp)
  800c80:	00 
  800c81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	89 04 24             	mov    %eax,(%esp)
  800c8e:	e8 84 fa ff ff       	call   800717 <printfmt>
  800c93:	e9 bd fe ff ff       	jmp    800b55 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c98:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800c9b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800c9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca1:	8d 48 04             	lea    0x4(%eax),%ecx
  800ca4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800ca7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800ca9:	85 ff                	test   %edi,%edi
  800cab:	b8 2f 16 80 00       	mov    $0x80162f,%eax
  800cb0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800cb3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800cb7:	74 61                	je     800d1a <cvprintfmt+0x207>
  800cb9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800cbd:	7e 5b                	jle    800d1a <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800cbf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cc3:	89 3c 24             	mov    %edi,(%esp)
  800cc6:	e8 ed 02 00 00       	call   800fb8 <strnlen>
  800ccb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800cce:	29 c2                	sub    %eax,%edx
  800cd0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800cd3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800cd7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800cda:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800cdd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ce0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ce6:	89 d3                	mov    %edx,%ebx
  800ce8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800cea:	eb 0f                	jmp    800cfb <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cef:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf3:	89 3c 24             	mov    %edi,(%esp)
  800cf6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800cf8:	83 eb 01             	sub    $0x1,%ebx
  800cfb:	85 db                	test   %ebx,%ebx
  800cfd:	7f ed                	jg     800cec <cvprintfmt+0x1d9>
  800cff:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d02:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d08:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d0b:	85 d2                	test   %edx,%edx
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d12:	0f 49 c2             	cmovns %edx,%eax
  800d15:	29 c2                	sub    %eax,%edx
  800d17:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800d1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d1d:	83 c8 3f             	or     $0x3f,%eax
  800d20:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d23:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d26:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800d29:	eb 36                	jmp    800d61 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d2f:	74 1d                	je     800d4e <cvprintfmt+0x23b>
  800d31:	0f be d2             	movsbl %dl,%edx
  800d34:	83 ea 20             	sub    $0x20,%edx
  800d37:	83 fa 5e             	cmp    $0x5e,%edx
  800d3a:	76 12                	jbe    800d4e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d43:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d46:	89 04 24             	mov    %eax,(%esp)
  800d49:	ff 55 08             	call   *0x8(%ebp)
  800d4c:	eb 10                	jmp    800d5e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800d4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d51:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d55:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800d58:	89 04 24             	mov    %eax,(%esp)
  800d5b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d5e:	83 eb 01             	sub    $0x1,%ebx
  800d61:	83 c7 01             	add    $0x1,%edi
  800d64:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800d68:	0f be c2             	movsbl %dl,%eax
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	74 27                	je     800d96 <cvprintfmt+0x283>
  800d6f:	85 f6                	test   %esi,%esi
  800d71:	78 b8                	js     800d2b <cvprintfmt+0x218>
  800d73:	83 ee 01             	sub    $0x1,%esi
  800d76:	79 b3                	jns    800d2b <cvprintfmt+0x218>
  800d78:	89 d8                	mov    %ebx,%eax
  800d7a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d80:	89 c3                	mov    %eax,%ebx
  800d82:	eb 18                	jmp    800d9c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800d84:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800d8f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800d91:	83 eb 01             	sub    $0x1,%ebx
  800d94:	eb 06                	jmp    800d9c <cvprintfmt+0x289>
  800d96:	8b 75 08             	mov    0x8(%ebp),%esi
  800d99:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d9c:	85 db                	test   %ebx,%ebx
  800d9e:	7f e4                	jg     800d84 <cvprintfmt+0x271>
  800da0:	89 75 08             	mov    %esi,0x8(%ebp)
  800da3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800da6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da9:	e9 a7 fd ff ff       	jmp    800b55 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800dae:	83 fa 01             	cmp    $0x1,%edx
  800db1:	7e 10                	jle    800dc3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800db3:	8b 45 14             	mov    0x14(%ebp),%eax
  800db6:	8d 50 08             	lea    0x8(%eax),%edx
  800db9:	89 55 14             	mov    %edx,0x14(%ebp)
  800dbc:	8b 30                	mov    (%eax),%esi
  800dbe:	8b 78 04             	mov    0x4(%eax),%edi
  800dc1:	eb 26                	jmp    800de9 <cvprintfmt+0x2d6>
	else if (lflag)
  800dc3:	85 d2                	test   %edx,%edx
  800dc5:	74 12                	je     800dd9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800dc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dca:	8d 50 04             	lea    0x4(%eax),%edx
  800dcd:	89 55 14             	mov    %edx,0x14(%ebp)
  800dd0:	8b 30                	mov    (%eax),%esi
  800dd2:	89 f7                	mov    %esi,%edi
  800dd4:	c1 ff 1f             	sar    $0x1f,%edi
  800dd7:	eb 10                	jmp    800de9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800dd9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ddc:	8d 50 04             	lea    0x4(%eax),%edx
  800ddf:	89 55 14             	mov    %edx,0x14(%ebp)
  800de2:	8b 30                	mov    (%eax),%esi
  800de4:	89 f7                	mov    %esi,%edi
  800de6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ded:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800df2:	85 ff                	test   %edi,%edi
  800df4:	0f 89 8e 00 00 00    	jns    800e88 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e04:	83 c8 2d             	or     $0x2d,%eax
  800e07:	89 04 24             	mov    %eax,(%esp)
  800e0a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	89 fa                	mov    %edi,%edx
  800e11:	f7 d8                	neg    %eax
  800e13:	83 d2 00             	adc    $0x0,%edx
  800e16:	f7 da                	neg    %edx
			}
			base = 10;
  800e18:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800e1d:	eb 69                	jmp    800e88 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e1f:	8d 45 14             	lea    0x14(%ebp),%eax
  800e22:	e8 99 f8 ff ff       	call   8006c0 <getuint>
			base = 10;
  800e27:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800e2c:	eb 5a                	jmp    800e88 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e2e:	8d 45 14             	lea    0x14(%ebp),%eax
  800e31:	e8 8a f8 ff ff       	call   8006c0 <getuint>
			base = 8 ;
  800e36:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800e3b:	eb 4b                	jmp    800e88 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e44:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800e47:	89 f0                	mov    %esi,%eax
  800e49:	83 c8 30             	or     $0x30,%eax
  800e4c:	89 04 24             	mov    %eax,(%esp)
  800e4f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800e52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e59:	89 f0                	mov    %esi,%eax
  800e5b:	83 c8 78             	or     $0x78,%eax
  800e5e:	89 04 24             	mov    %eax,(%esp)
  800e61:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e64:	8b 45 14             	mov    0x14(%ebp),%eax
  800e67:	8d 50 04             	lea    0x4(%eax),%edx
  800e6a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800e6d:	8b 00                	mov    (%eax),%eax
  800e6f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e74:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800e79:	eb 0d                	jmp    800e88 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e7b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e7e:	e8 3d f8 ff ff       	call   8006c0 <getuint>
			base = 16;
  800e83:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800e88:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800e8c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e90:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800e93:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e97:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e9b:	89 04 24             	mov    %eax,(%esp)
  800e9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ea2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eab:	e8 0f f7 ff ff       	call   8005bf <cprintnum>
			break;
  800eb0:	e9 a0 fc ff ff       	jmp    800b55 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800eb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ebc:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800ebf:	89 04 24             	mov    %eax,(%esp)
  800ec2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ec5:	e9 8b fc ff ff       	jmp    800b55 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ed4:	89 04 24             	mov    %eax,(%esp)
  800ed7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800eda:	89 fb                	mov    %edi,%ebx
  800edc:	eb 03                	jmp    800ee1 <cvprintfmt+0x3ce>
  800ede:	83 eb 01             	sub    $0x1,%ebx
  800ee1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ee5:	75 f7                	jne    800ede <cvprintfmt+0x3cb>
  800ee7:	e9 69 fc ff ff       	jmp    800b55 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800eec:	83 c4 3c             	add    $0x3c,%esp
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800efa:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800efd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f01:	8b 45 10             	mov    0x10(%ebp),%eax
  800f04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f12:	89 04 24             	mov    %eax,(%esp)
  800f15:	e8 f9 fb ff ff       	call   800b13 <cvprintfmt>
	va_end(ap);
}
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 28             	sub    $0x28,%esp
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
  800f25:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f28:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f2b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f2f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	74 30                	je     800f6d <vsnprintf+0x51>
  800f3d:	85 d2                	test   %edx,%edx
  800f3f:	7e 2c                	jle    800f6d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f41:	8b 45 14             	mov    0x14(%ebp),%eax
  800f44:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f48:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f56:	c7 04 24 fa 06 80 00 	movl   $0x8006fa,(%esp)
  800f5d:	e8 dd f7 ff ff       	call   80073f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f65:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6b:	eb 05                	jmp    800f72 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f7a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f81:	8b 45 10             	mov    0x10(%ebp),%eax
  800f84:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	89 04 24             	mov    %eax,(%esp)
  800f95:	e8 82 ff ff ff       	call   800f1c <vsnprintf>
	va_end(ap);

	return rc;
}
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    
  800f9c:	66 90                	xchg   %ax,%ax
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fab:	eb 03                	jmp    800fb0 <strlen+0x10>
		n++;
  800fad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800fb0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fb4:	75 f7                	jne    800fad <strlen+0xd>
		n++;
	return n;
}
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    

00800fb8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fbe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc6:	eb 03                	jmp    800fcb <strnlen+0x13>
		n++;
  800fc8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fcb:	39 d0                	cmp    %edx,%eax
  800fcd:	74 06                	je     800fd5 <strnlen+0x1d>
  800fcf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fd3:	75 f3                	jne    800fc8 <strnlen+0x10>
		n++;
	return n;
}
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	53                   	push   %ebx
  800fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fe1:	89 c2                	mov    %eax,%edx
  800fe3:	83 c2 01             	add    $0x1,%edx
  800fe6:	83 c1 01             	add    $0x1,%ecx
  800fe9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800fed:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ff0:	84 db                	test   %bl,%bl
  800ff2:	75 ef                	jne    800fe3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ff4:	5b                   	pop    %ebx
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 08             	sub    $0x8,%esp
  800ffe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801001:	89 1c 24             	mov    %ebx,(%esp)
  801004:	e8 97 ff ff ff       	call   800fa0 <strlen>
	strcpy(dst + len, src);
  801009:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801010:	01 d8                	add    %ebx,%eax
  801012:	89 04 24             	mov    %eax,(%esp)
  801015:	e8 bd ff ff ff       	call   800fd7 <strcpy>
	return dst;
}
  80101a:	89 d8                	mov    %ebx,%eax
  80101c:	83 c4 08             	add    $0x8,%esp
  80101f:	5b                   	pop    %ebx
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	8b 75 08             	mov    0x8(%ebp),%esi
  80102a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102d:	89 f3                	mov    %esi,%ebx
  80102f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801032:	89 f2                	mov    %esi,%edx
  801034:	eb 0f                	jmp    801045 <strncpy+0x23>
		*dst++ = *src;
  801036:	83 c2 01             	add    $0x1,%edx
  801039:	0f b6 01             	movzbl (%ecx),%eax
  80103c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80103f:	80 39 01             	cmpb   $0x1,(%ecx)
  801042:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801045:	39 da                	cmp    %ebx,%edx
  801047:	75 ed                	jne    801036 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801049:	89 f0                	mov    %esi,%eax
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	8b 75 08             	mov    0x8(%ebp),%esi
  801057:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80105d:	89 f0                	mov    %esi,%eax
  80105f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801063:	85 c9                	test   %ecx,%ecx
  801065:	75 0b                	jne    801072 <strlcpy+0x23>
  801067:	eb 1d                	jmp    801086 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801069:	83 c0 01             	add    $0x1,%eax
  80106c:	83 c2 01             	add    $0x1,%edx
  80106f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801072:	39 d8                	cmp    %ebx,%eax
  801074:	74 0b                	je     801081 <strlcpy+0x32>
  801076:	0f b6 0a             	movzbl (%edx),%ecx
  801079:	84 c9                	test   %cl,%cl
  80107b:	75 ec                	jne    801069 <strlcpy+0x1a>
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	eb 02                	jmp    801083 <strlcpy+0x34>
  801081:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801083:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801086:	29 f0                	sub    %esi,%eax
}
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801092:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801095:	eb 06                	jmp    80109d <strcmp+0x11>
		p++, q++;
  801097:	83 c1 01             	add    $0x1,%ecx
  80109a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80109d:	0f b6 01             	movzbl (%ecx),%eax
  8010a0:	84 c0                	test   %al,%al
  8010a2:	74 04                	je     8010a8 <strcmp+0x1c>
  8010a4:	3a 02                	cmp    (%edx),%al
  8010a6:	74 ef                	je     801097 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8010a8:	0f b6 c0             	movzbl %al,%eax
  8010ab:	0f b6 12             	movzbl (%edx),%edx
  8010ae:	29 d0                	sub    %edx,%eax
}
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	53                   	push   %ebx
  8010b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010bc:	89 c3                	mov    %eax,%ebx
  8010be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8010c1:	eb 06                	jmp    8010c9 <strncmp+0x17>
		n--, p++, q++;
  8010c3:	83 c0 01             	add    $0x1,%eax
  8010c6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8010c9:	39 d8                	cmp    %ebx,%eax
  8010cb:	74 15                	je     8010e2 <strncmp+0x30>
  8010cd:	0f b6 08             	movzbl (%eax),%ecx
  8010d0:	84 c9                	test   %cl,%cl
  8010d2:	74 04                	je     8010d8 <strncmp+0x26>
  8010d4:	3a 0a                	cmp    (%edx),%cl
  8010d6:	74 eb                	je     8010c3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010d8:	0f b6 00             	movzbl (%eax),%eax
  8010db:	0f b6 12             	movzbl (%edx),%edx
  8010de:	29 d0                	sub    %edx,%eax
  8010e0:	eb 05                	jmp    8010e7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010e2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010e7:	5b                   	pop    %ebx
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8010f4:	eb 07                	jmp    8010fd <strchr+0x13>
		if (*s == c)
  8010f6:	38 ca                	cmp    %cl,%dl
  8010f8:	74 0f                	je     801109 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010fa:	83 c0 01             	add    $0x1,%eax
  8010fd:	0f b6 10             	movzbl (%eax),%edx
  801100:	84 d2                	test   %dl,%dl
  801102:	75 f2                	jne    8010f6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801104:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801115:	eb 07                	jmp    80111e <strfind+0x13>
		if (*s == c)
  801117:	38 ca                	cmp    %cl,%dl
  801119:	74 0a                	je     801125 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80111b:	83 c0 01             	add    $0x1,%eax
  80111e:	0f b6 10             	movzbl (%eax),%edx
  801121:	84 d2                	test   %dl,%dl
  801123:	75 f2                	jne    801117 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	57                   	push   %edi
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
  80112d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801130:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801133:	85 c9                	test   %ecx,%ecx
  801135:	74 36                	je     80116d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801137:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80113d:	75 28                	jne    801167 <memset+0x40>
  80113f:	f6 c1 03             	test   $0x3,%cl
  801142:	75 23                	jne    801167 <memset+0x40>
		c &= 0xFF;
  801144:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801148:	89 d3                	mov    %edx,%ebx
  80114a:	c1 e3 08             	shl    $0x8,%ebx
  80114d:	89 d6                	mov    %edx,%esi
  80114f:	c1 e6 18             	shl    $0x18,%esi
  801152:	89 d0                	mov    %edx,%eax
  801154:	c1 e0 10             	shl    $0x10,%eax
  801157:	09 f0                	or     %esi,%eax
  801159:	09 c2                	or     %eax,%edx
  80115b:	89 d0                	mov    %edx,%eax
  80115d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80115f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801162:	fc                   	cld    
  801163:	f3 ab                	rep stos %eax,%es:(%edi)
  801165:	eb 06                	jmp    80116d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116a:	fc                   	cld    
  80116b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80116d:	89 f8                	mov    %edi,%eax
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	8b 45 08             	mov    0x8(%ebp),%eax
  80117c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80117f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801182:	39 c6                	cmp    %eax,%esi
  801184:	73 35                	jae    8011bb <memmove+0x47>
  801186:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801189:	39 d0                	cmp    %edx,%eax
  80118b:	73 2e                	jae    8011bb <memmove+0x47>
		s += n;
		d += n;
  80118d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801190:	89 d6                	mov    %edx,%esi
  801192:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801194:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80119a:	75 13                	jne    8011af <memmove+0x3b>
  80119c:	f6 c1 03             	test   $0x3,%cl
  80119f:	75 0e                	jne    8011af <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8011a1:	83 ef 04             	sub    $0x4,%edi
  8011a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8011a7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8011aa:	fd                   	std    
  8011ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011ad:	eb 09                	jmp    8011b8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8011af:	83 ef 01             	sub    $0x1,%edi
  8011b2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8011b5:	fd                   	std    
  8011b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8011b8:	fc                   	cld    
  8011b9:	eb 1d                	jmp    8011d8 <memmove+0x64>
  8011bb:	89 f2                	mov    %esi,%edx
  8011bd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011bf:	f6 c2 03             	test   $0x3,%dl
  8011c2:	75 0f                	jne    8011d3 <memmove+0x5f>
  8011c4:	f6 c1 03             	test   $0x3,%cl
  8011c7:	75 0a                	jne    8011d3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8011c9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8011cc:	89 c7                	mov    %eax,%edi
  8011ce:	fc                   	cld    
  8011cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011d1:	eb 05                	jmp    8011d8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011d3:	89 c7                	mov    %eax,%edi
  8011d5:	fc                   	cld    
  8011d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f3:	89 04 24             	mov    %eax,(%esp)
  8011f6:	e8 79 ff ff ff       	call   801174 <memmove>
}
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	56                   	push   %esi
  801201:	53                   	push   %ebx
  801202:	8b 55 08             	mov    0x8(%ebp),%edx
  801205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801208:	89 d6                	mov    %edx,%esi
  80120a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80120d:	eb 1a                	jmp    801229 <memcmp+0x2c>
		if (*s1 != *s2)
  80120f:	0f b6 02             	movzbl (%edx),%eax
  801212:	0f b6 19             	movzbl (%ecx),%ebx
  801215:	38 d8                	cmp    %bl,%al
  801217:	74 0a                	je     801223 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801219:	0f b6 c0             	movzbl %al,%eax
  80121c:	0f b6 db             	movzbl %bl,%ebx
  80121f:	29 d8                	sub    %ebx,%eax
  801221:	eb 0f                	jmp    801232 <memcmp+0x35>
		s1++, s2++;
  801223:	83 c2 01             	add    $0x1,%edx
  801226:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801229:	39 f2                	cmp    %esi,%edx
  80122b:	75 e2                	jne    80120f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	8b 45 08             	mov    0x8(%ebp),%eax
  80123c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80123f:	89 c2                	mov    %eax,%edx
  801241:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801244:	eb 07                	jmp    80124d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801246:	38 08                	cmp    %cl,(%eax)
  801248:	74 07                	je     801251 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80124a:	83 c0 01             	add    $0x1,%eax
  80124d:	39 d0                	cmp    %edx,%eax
  80124f:	72 f5                	jb     801246 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	57                   	push   %edi
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	8b 55 08             	mov    0x8(%ebp),%edx
  80125c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80125f:	eb 03                	jmp    801264 <strtol+0x11>
		s++;
  801261:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801264:	0f b6 0a             	movzbl (%edx),%ecx
  801267:	80 f9 09             	cmp    $0x9,%cl
  80126a:	74 f5                	je     801261 <strtol+0xe>
  80126c:	80 f9 20             	cmp    $0x20,%cl
  80126f:	74 f0                	je     801261 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801271:	80 f9 2b             	cmp    $0x2b,%cl
  801274:	75 0a                	jne    801280 <strtol+0x2d>
		s++;
  801276:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801279:	bf 00 00 00 00       	mov    $0x0,%edi
  80127e:	eb 11                	jmp    801291 <strtol+0x3e>
  801280:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801285:	80 f9 2d             	cmp    $0x2d,%cl
  801288:	75 07                	jne    801291 <strtol+0x3e>
		s++, neg = 1;
  80128a:	8d 52 01             	lea    0x1(%edx),%edx
  80128d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801291:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801296:	75 15                	jne    8012ad <strtol+0x5a>
  801298:	80 3a 30             	cmpb   $0x30,(%edx)
  80129b:	75 10                	jne    8012ad <strtol+0x5a>
  80129d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8012a1:	75 0a                	jne    8012ad <strtol+0x5a>
		s += 2, base = 16;
  8012a3:	83 c2 02             	add    $0x2,%edx
  8012a6:	b8 10 00 00 00       	mov    $0x10,%eax
  8012ab:	eb 10                	jmp    8012bd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	75 0c                	jne    8012bd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8012b1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8012b3:	80 3a 30             	cmpb   $0x30,(%edx)
  8012b6:	75 05                	jne    8012bd <strtol+0x6a>
		s++, base = 8;
  8012b8:	83 c2 01             	add    $0x1,%edx
  8012bb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  8012bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8012c5:	0f b6 0a             	movzbl (%edx),%ecx
  8012c8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8012cb:	89 f0                	mov    %esi,%eax
  8012cd:	3c 09                	cmp    $0x9,%al
  8012cf:	77 08                	ja     8012d9 <strtol+0x86>
			dig = *s - '0';
  8012d1:	0f be c9             	movsbl %cl,%ecx
  8012d4:	83 e9 30             	sub    $0x30,%ecx
  8012d7:	eb 20                	jmp    8012f9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8012d9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8012dc:	89 f0                	mov    %esi,%eax
  8012de:	3c 19                	cmp    $0x19,%al
  8012e0:	77 08                	ja     8012ea <strtol+0x97>
			dig = *s - 'a' + 10;
  8012e2:	0f be c9             	movsbl %cl,%ecx
  8012e5:	83 e9 57             	sub    $0x57,%ecx
  8012e8:	eb 0f                	jmp    8012f9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8012ea:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8012ed:	89 f0                	mov    %esi,%eax
  8012ef:	3c 19                	cmp    $0x19,%al
  8012f1:	77 16                	ja     801309 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8012f3:	0f be c9             	movsbl %cl,%ecx
  8012f6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012f9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8012fc:	7d 0f                	jge    80130d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8012fe:	83 c2 01             	add    $0x1,%edx
  801301:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801305:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801307:	eb bc                	jmp    8012c5 <strtol+0x72>
  801309:	89 d8                	mov    %ebx,%eax
  80130b:	eb 02                	jmp    80130f <strtol+0xbc>
  80130d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80130f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801313:	74 05                	je     80131a <strtol+0xc7>
		*endptr = (char *) s;
  801315:	8b 75 0c             	mov    0xc(%ebp),%esi
  801318:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80131a:	f7 d8                	neg    %eax
  80131c:	85 ff                	test   %edi,%edi
  80131e:	0f 44 c3             	cmove  %ebx,%eax
}
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    
  801326:	66 90                	xchg   %ax,%ax
  801328:	66 90                	xchg   %ax,%ax
  80132a:	66 90                	xchg   %ax,%ax
  80132c:	66 90                	xchg   %ax,%ax
  80132e:	66 90                	xchg   %ax,%ax

00801330 <__udivdi3>:
  801330:	55                   	push   %ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	8b 44 24 28          	mov    0x28(%esp),%eax
  80133a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80133e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801342:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801346:	85 c0                	test   %eax,%eax
  801348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80134c:	89 ea                	mov    %ebp,%edx
  80134e:	89 0c 24             	mov    %ecx,(%esp)
  801351:	75 2d                	jne    801380 <__udivdi3+0x50>
  801353:	39 e9                	cmp    %ebp,%ecx
  801355:	77 61                	ja     8013b8 <__udivdi3+0x88>
  801357:	85 c9                	test   %ecx,%ecx
  801359:	89 ce                	mov    %ecx,%esi
  80135b:	75 0b                	jne    801368 <__udivdi3+0x38>
  80135d:	b8 01 00 00 00       	mov    $0x1,%eax
  801362:	31 d2                	xor    %edx,%edx
  801364:	f7 f1                	div    %ecx
  801366:	89 c6                	mov    %eax,%esi
  801368:	31 d2                	xor    %edx,%edx
  80136a:	89 e8                	mov    %ebp,%eax
  80136c:	f7 f6                	div    %esi
  80136e:	89 c5                	mov    %eax,%ebp
  801370:	89 f8                	mov    %edi,%eax
  801372:	f7 f6                	div    %esi
  801374:	89 ea                	mov    %ebp,%edx
  801376:	83 c4 0c             	add    $0xc,%esp
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    
  80137d:	8d 76 00             	lea    0x0(%esi),%esi
  801380:	39 e8                	cmp    %ebp,%eax
  801382:	77 24                	ja     8013a8 <__udivdi3+0x78>
  801384:	0f bd e8             	bsr    %eax,%ebp
  801387:	83 f5 1f             	xor    $0x1f,%ebp
  80138a:	75 3c                	jne    8013c8 <__udivdi3+0x98>
  80138c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801390:	39 34 24             	cmp    %esi,(%esp)
  801393:	0f 86 9f 00 00 00    	jbe    801438 <__udivdi3+0x108>
  801399:	39 d0                	cmp    %edx,%eax
  80139b:	0f 82 97 00 00 00    	jb     801438 <__udivdi3+0x108>
  8013a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	31 d2                	xor    %edx,%edx
  8013aa:	31 c0                	xor    %eax,%eax
  8013ac:	83 c4 0c             	add    $0xc,%esp
  8013af:	5e                   	pop    %esi
  8013b0:	5f                   	pop    %edi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    
  8013b3:	90                   	nop
  8013b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b8:	89 f8                	mov    %edi,%eax
  8013ba:	f7 f1                	div    %ecx
  8013bc:	31 d2                	xor    %edx,%edx
  8013be:	83 c4 0c             	add    $0xc,%esp
  8013c1:	5e                   	pop    %esi
  8013c2:	5f                   	pop    %edi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    
  8013c5:	8d 76 00             	lea    0x0(%esi),%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	8b 3c 24             	mov    (%esp),%edi
  8013cd:	d3 e0                	shl    %cl,%eax
  8013cf:	89 c6                	mov    %eax,%esi
  8013d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013d6:	29 e8                	sub    %ebp,%eax
  8013d8:	89 c1                	mov    %eax,%ecx
  8013da:	d3 ef                	shr    %cl,%edi
  8013dc:	89 e9                	mov    %ebp,%ecx
  8013de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013e2:	8b 3c 24             	mov    (%esp),%edi
  8013e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013e9:	89 d6                	mov    %edx,%esi
  8013eb:	d3 e7                	shl    %cl,%edi
  8013ed:	89 c1                	mov    %eax,%ecx
  8013ef:	89 3c 24             	mov    %edi,(%esp)
  8013f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013f6:	d3 ee                	shr    %cl,%esi
  8013f8:	89 e9                	mov    %ebp,%ecx
  8013fa:	d3 e2                	shl    %cl,%edx
  8013fc:	89 c1                	mov    %eax,%ecx
  8013fe:	d3 ef                	shr    %cl,%edi
  801400:	09 d7                	or     %edx,%edi
  801402:	89 f2                	mov    %esi,%edx
  801404:	89 f8                	mov    %edi,%eax
  801406:	f7 74 24 08          	divl   0x8(%esp)
  80140a:	89 d6                	mov    %edx,%esi
  80140c:	89 c7                	mov    %eax,%edi
  80140e:	f7 24 24             	mull   (%esp)
  801411:	39 d6                	cmp    %edx,%esi
  801413:	89 14 24             	mov    %edx,(%esp)
  801416:	72 30                	jb     801448 <__udivdi3+0x118>
  801418:	8b 54 24 04          	mov    0x4(%esp),%edx
  80141c:	89 e9                	mov    %ebp,%ecx
  80141e:	d3 e2                	shl    %cl,%edx
  801420:	39 c2                	cmp    %eax,%edx
  801422:	73 05                	jae    801429 <__udivdi3+0xf9>
  801424:	3b 34 24             	cmp    (%esp),%esi
  801427:	74 1f                	je     801448 <__udivdi3+0x118>
  801429:	89 f8                	mov    %edi,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	e9 7a ff ff ff       	jmp    8013ac <__udivdi3+0x7c>
  801432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801438:	31 d2                	xor    %edx,%edx
  80143a:	b8 01 00 00 00       	mov    $0x1,%eax
  80143f:	e9 68 ff ff ff       	jmp    8013ac <__udivdi3+0x7c>
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	8d 47 ff             	lea    -0x1(%edi),%eax
  80144b:	31 d2                	xor    %edx,%edx
  80144d:	83 c4 0c             	add    $0xc,%esp
  801450:	5e                   	pop    %esi
  801451:	5f                   	pop    %edi
  801452:	5d                   	pop    %ebp
  801453:	c3                   	ret    
  801454:	66 90                	xchg   %ax,%ax
  801456:	66 90                	xchg   %ax,%ax
  801458:	66 90                	xchg   %ax,%ax
  80145a:	66 90                	xchg   %ax,%ax
  80145c:	66 90                	xchg   %ax,%ax
  80145e:	66 90                	xchg   %ax,%ax

00801460 <__umoddi3>:
  801460:	55                   	push   %ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	83 ec 14             	sub    $0x14,%esp
  801466:	8b 44 24 28          	mov    0x28(%esp),%eax
  80146a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80146e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801472:	89 c7                	mov    %eax,%edi
  801474:	89 44 24 04          	mov    %eax,0x4(%esp)
  801478:	8b 44 24 30          	mov    0x30(%esp),%eax
  80147c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801480:	89 34 24             	mov    %esi,(%esp)
  801483:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801487:	85 c0                	test   %eax,%eax
  801489:	89 c2                	mov    %eax,%edx
  80148b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80148f:	75 17                	jne    8014a8 <__umoddi3+0x48>
  801491:	39 fe                	cmp    %edi,%esi
  801493:	76 4b                	jbe    8014e0 <__umoddi3+0x80>
  801495:	89 c8                	mov    %ecx,%eax
  801497:	89 fa                	mov    %edi,%edx
  801499:	f7 f6                	div    %esi
  80149b:	89 d0                	mov    %edx,%eax
  80149d:	31 d2                	xor    %edx,%edx
  80149f:	83 c4 14             	add    $0x14,%esp
  8014a2:	5e                   	pop    %esi
  8014a3:	5f                   	pop    %edi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    
  8014a6:	66 90                	xchg   %ax,%ax
  8014a8:	39 f8                	cmp    %edi,%eax
  8014aa:	77 54                	ja     801500 <__umoddi3+0xa0>
  8014ac:	0f bd e8             	bsr    %eax,%ebp
  8014af:	83 f5 1f             	xor    $0x1f,%ebp
  8014b2:	75 5c                	jne    801510 <__umoddi3+0xb0>
  8014b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014b8:	39 3c 24             	cmp    %edi,(%esp)
  8014bb:	0f 87 e7 00 00 00    	ja     8015a8 <__umoddi3+0x148>
  8014c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014c5:	29 f1                	sub    %esi,%ecx
  8014c7:	19 c7                	sbb    %eax,%edi
  8014c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014d9:	83 c4 14             	add    $0x14,%esp
  8014dc:	5e                   	pop    %esi
  8014dd:	5f                   	pop    %edi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    
  8014e0:	85 f6                	test   %esi,%esi
  8014e2:	89 f5                	mov    %esi,%ebp
  8014e4:	75 0b                	jne    8014f1 <__umoddi3+0x91>
  8014e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014eb:	31 d2                	xor    %edx,%edx
  8014ed:	f7 f6                	div    %esi
  8014ef:	89 c5                	mov    %eax,%ebp
  8014f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014f5:	31 d2                	xor    %edx,%edx
  8014f7:	f7 f5                	div    %ebp
  8014f9:	89 c8                	mov    %ecx,%eax
  8014fb:	f7 f5                	div    %ebp
  8014fd:	eb 9c                	jmp    80149b <__umoddi3+0x3b>
  8014ff:	90                   	nop
  801500:	89 c8                	mov    %ecx,%eax
  801502:	89 fa                	mov    %edi,%edx
  801504:	83 c4 14             	add    $0x14,%esp
  801507:	5e                   	pop    %esi
  801508:	5f                   	pop    %edi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    
  80150b:	90                   	nop
  80150c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801510:	8b 04 24             	mov    (%esp),%eax
  801513:	be 20 00 00 00       	mov    $0x20,%esi
  801518:	89 e9                	mov    %ebp,%ecx
  80151a:	29 ee                	sub    %ebp,%esi
  80151c:	d3 e2                	shl    %cl,%edx
  80151e:	89 f1                	mov    %esi,%ecx
  801520:	d3 e8                	shr    %cl,%eax
  801522:	89 e9                	mov    %ebp,%ecx
  801524:	89 44 24 04          	mov    %eax,0x4(%esp)
  801528:	8b 04 24             	mov    (%esp),%eax
  80152b:	09 54 24 04          	or     %edx,0x4(%esp)
  80152f:	89 fa                	mov    %edi,%edx
  801531:	d3 e0                	shl    %cl,%eax
  801533:	89 f1                	mov    %esi,%ecx
  801535:	89 44 24 08          	mov    %eax,0x8(%esp)
  801539:	8b 44 24 10          	mov    0x10(%esp),%eax
  80153d:	d3 ea                	shr    %cl,%edx
  80153f:	89 e9                	mov    %ebp,%ecx
  801541:	d3 e7                	shl    %cl,%edi
  801543:	89 f1                	mov    %esi,%ecx
  801545:	d3 e8                	shr    %cl,%eax
  801547:	89 e9                	mov    %ebp,%ecx
  801549:	09 f8                	or     %edi,%eax
  80154b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80154f:	f7 74 24 04          	divl   0x4(%esp)
  801553:	d3 e7                	shl    %cl,%edi
  801555:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801559:	89 d7                	mov    %edx,%edi
  80155b:	f7 64 24 08          	mull   0x8(%esp)
  80155f:	39 d7                	cmp    %edx,%edi
  801561:	89 c1                	mov    %eax,%ecx
  801563:	89 14 24             	mov    %edx,(%esp)
  801566:	72 2c                	jb     801594 <__umoddi3+0x134>
  801568:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80156c:	72 22                	jb     801590 <__umoddi3+0x130>
  80156e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801572:	29 c8                	sub    %ecx,%eax
  801574:	19 d7                	sbb    %edx,%edi
  801576:	89 e9                	mov    %ebp,%ecx
  801578:	89 fa                	mov    %edi,%edx
  80157a:	d3 e8                	shr    %cl,%eax
  80157c:	89 f1                	mov    %esi,%ecx
  80157e:	d3 e2                	shl    %cl,%edx
  801580:	89 e9                	mov    %ebp,%ecx
  801582:	d3 ef                	shr    %cl,%edi
  801584:	09 d0                	or     %edx,%eax
  801586:	89 fa                	mov    %edi,%edx
  801588:	83 c4 14             	add    $0x14,%esp
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    
  80158f:	90                   	nop
  801590:	39 d7                	cmp    %edx,%edi
  801592:	75 da                	jne    80156e <__umoddi3+0x10e>
  801594:	8b 14 24             	mov    (%esp),%edx
  801597:	89 c1                	mov    %eax,%ecx
  801599:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80159d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8015a1:	eb cb                	jmp    80156e <__umoddi3+0x10e>
  8015a3:	90                   	nop
  8015a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8015ac:	0f 82 0f ff ff ff    	jb     8014c1 <__umoddi3+0x61>
  8015b2:	e9 1a ff ff ff       	jmp    8014d1 <__umoddi3+0x71>
