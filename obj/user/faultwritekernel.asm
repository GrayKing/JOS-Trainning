
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	83 ec 10             	sub    $0x10,%esp
  80004a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800050:	e8 d8 00 00 00       	call   80012d <sys_getenvid>
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	89 74 24 04          	mov    %esi,0x4(%esp)
  800076:	89 1c 24             	mov    %ebx,(%esp)
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 07 00 00 00       	call   80008a <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	5d                   	pop    %ebp
  800089:	c3                   	ret    

0080008a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800090:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800097:	e8 3f 00 00 00       	call   8000db <sys_env_destroy>
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 28                	jle    800125 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800101:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800108:	00 
  800109:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  800110:	00 
  800111:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800118:	00 
  800119:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800120:	e8 5b 02 00 00       	call   800380 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800125:	83 c4 2c             	add    $0x2c,%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5f                   	pop    %edi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	57                   	push   %edi
  800131:	56                   	push   %esi
  800132:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800133:	ba 00 00 00 00       	mov    $0x0,%edx
  800138:	b8 02 00 00 00       	mov    $0x2,%eax
  80013d:	89 d1                	mov    %edx,%ecx
  80013f:	89 d3                	mov    %edx,%ebx
  800141:	89 d7                	mov    %edx,%edi
  800143:	89 d6                	mov    %edx,%esi
  800145:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <sys_yield>:

void
sys_yield(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800152:	ba 00 00 00 00       	mov    $0x0,%edx
  800157:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015c:	89 d1                	mov    %edx,%ecx
  80015e:	89 d3                	mov    %edx,%ebx
  800160:	89 d7                	mov    %edx,%edi
  800162:	89 d6                	mov    %edx,%esi
  800164:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800166:	5b                   	pop    %ebx
  800167:	5e                   	pop    %esi
  800168:	5f                   	pop    %edi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800174:	be 00 00 00 00       	mov    $0x0,%esi
  800179:	b8 04 00 00 00       	mov    $0x4,%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800187:	89 f7                	mov    %esi,%edi
  800189:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018b:	85 c0                	test   %eax,%eax
  80018d:	7e 28                	jle    8001b7 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800193:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019a:	00 
  80019b:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  8001a2:	00 
  8001a3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001aa:	00 
  8001ab:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  8001b2:	e8 c9 01 00 00       	call   800380 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b7:	83 c4 2c             	add    $0x2c,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5f                   	pop    %edi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    

008001bf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	57                   	push   %edi
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001de:	85 c0                	test   %eax,%eax
  8001e0:	7e 28                	jle    80020a <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e6:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001fd:	00 
  8001fe:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800205:	e8 76 01 00 00       	call   800380 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020a:	83 c4 2c             	add    $0x2c,%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	57                   	push   %edi
  800216:	56                   	push   %esi
  800217:	53                   	push   %ebx
  800218:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800220:	b8 06 00 00 00       	mov    $0x6,%eax
  800225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800228:	8b 55 08             	mov    0x8(%ebp),%edx
  80022b:	89 df                	mov    %ebx,%edi
  80022d:	89 de                	mov    %ebx,%esi
  80022f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800231:	85 c0                	test   %eax,%eax
  800233:	7e 28                	jle    80025d <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800235:	89 44 24 10          	mov    %eax,0x10(%esp)
  800239:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800240:	00 
  800241:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  800248:	00 
  800249:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800250:	00 
  800251:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800258:	e8 23 01 00 00       	call   800380 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025d:	83 c4 2c             	add    $0x2c,%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	b8 08 00 00 00       	mov    $0x8,%eax
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	8b 55 08             	mov    0x8(%ebp),%edx
  80027e:	89 df                	mov    %ebx,%edi
  800280:	89 de                	mov    %ebx,%esi
  800282:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7e 28                	jle    8002b0 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800288:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800293:	00 
  800294:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  80029b:	00 
  80029c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a3:	00 
  8002a4:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  8002ab:	e8 d0 00 00 00       	call   800380 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b0:	83 c4 2c             	add    $0x2c,%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c6:	b8 09 00 00 00       	mov    $0x9,%eax
  8002cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 df                	mov    %ebx,%edi
  8002d3:	89 de                	mov    %ebx,%esi
  8002d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	7e 28                	jle    800303 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002df:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e6:	00 
  8002e7:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  8002ee:	00 
  8002ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f6:	00 
  8002f7:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  8002fe:	e8 7d 00 00 00       	call   800380 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800303:	83 c4 2c             	add    $0x2c,%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5f                   	pop    %edi
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800311:	be 00 00 00 00       	mov    $0x0,%esi
  800316:	b8 0b 00 00 00       	mov    $0xb,%eax
  80031b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031e:	8b 55 08             	mov    0x8(%ebp),%edx
  800321:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800324:	8b 7d 14             	mov    0x14(%ebp),%edi
  800327:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800329:	5b                   	pop    %ebx
  80032a:	5e                   	pop    %esi
  80032b:	5f                   	pop    %edi
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800337:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800341:	8b 55 08             	mov    0x8(%ebp),%edx
  800344:	89 cb                	mov    %ecx,%ebx
  800346:	89 cf                	mov    %ecx,%edi
  800348:	89 ce                	mov    %ecx,%esi
  80034a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	7e 28                	jle    800378 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800350:	89 44 24 10          	mov    %eax,0x10(%esp)
  800354:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80035b:	00 
  80035c:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  800363:	00 
  800364:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036b:	00 
  80036c:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800373:	e8 08 00 00 00       	call   800380 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800378:	83 c4 2c             	add    $0x2c,%esp
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800388:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80038b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800391:	e8 97 fd ff ff       	call   80012d <sys_getenvid>
  800396:	8b 55 0c             	mov    0xc(%ebp),%edx
  800399:	89 54 24 10          	mov    %edx,0x10(%esp)
  80039d:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ac:	c7 04 24 d8 15 80 00 	movl   $0x8015d8,(%esp)
  8003b3:	e8 c1 00 00 00       	call   800479 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	e8 51 00 00 00       	call   800418 <vcprintf>
	cprintf("\n");
  8003c7:	c7 04 24 fc 15 80 00 	movl   $0x8015fc,(%esp)
  8003ce:	e8 a6 00 00 00       	call   800479 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003d3:	cc                   	int3   
  8003d4:	eb fd                	jmp    8003d3 <_panic+0x53>

008003d6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 14             	sub    $0x14,%esp
  8003dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e0:	8b 13                	mov    (%ebx),%edx
  8003e2:	8d 42 01             	lea    0x1(%edx),%eax
  8003e5:	89 03                	mov    %eax,(%ebx)
  8003e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f3:	75 19                	jne    80040e <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003f5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003fc:	00 
  8003fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 96 fc ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  800408:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80040e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800412:	83 c4 14             	add    $0x14,%esp
  800415:	5b                   	pop    %ebx
  800416:	5d                   	pop    %ebp
  800417:	c3                   	ret    

00800418 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800421:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800428:	00 00 00 
	b.cnt = 0;
  80042b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800432:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800435:	8b 45 0c             	mov    0xc(%ebp),%eax
  800438:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043c:	8b 45 08             	mov    0x8(%ebp),%eax
  80043f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800443:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800449:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044d:	c7 04 24 d6 03 80 00 	movl   $0x8003d6,(%esp)
  800454:	e8 b6 02 00 00       	call   80070f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800459:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80045f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800463:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	e8 2d fc ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  800471:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800477:	c9                   	leave  
  800478:	c3                   	ret    

00800479 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
  80047c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80047f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800482:	89 44 24 04          	mov    %eax,0x4(%esp)
  800486:	8b 45 08             	mov    0x8(%ebp),%eax
  800489:	89 04 24             	mov    %eax,(%esp)
  80048c:	e8 87 ff ff ff       	call   800418 <vcprintf>
	va_end(ap);

	return cnt;
}
  800491:	c9                   	leave  
  800492:	c3                   	ret    
  800493:	66 90                	xchg   %ax,%ax
  800495:	66 90                	xchg   %ax,%ax
  800497:	66 90                	xchg   %ax,%ax
  800499:	66 90                	xchg   %ax,%ax
  80049b:	66 90                	xchg   %ax,%ax
  80049d:	66 90                	xchg   %ax,%ax
  80049f:	90                   	nop

008004a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 3c             	sub    $0x3c,%esp
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	89 d7                	mov    %edx,%edi
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 c3                	mov    %eax,%ebx
  8004b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004cd:	39 d9                	cmp    %ebx,%ecx
  8004cf:	72 05                	jb     8004d6 <printnum+0x36>
  8004d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004d4:	77 69                	ja     80053f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004f0:	89 c3                	mov    %eax,%ebx
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	e8 ec 0d 00 00       	call   801300 <__udivdi3>
  800514:	89 d9                	mov    %ebx,%ecx
  800516:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80051a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	89 54 24 04          	mov    %edx,0x4(%esp)
  800525:	89 fa                	mov    %edi,%edx
  800527:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052a:	e8 71 ff ff ff       	call   8004a0 <printnum>
  80052f:	eb 1b                	jmp    80054c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800531:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800535:	8b 45 18             	mov    0x18(%ebp),%eax
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	ff d3                	call   *%ebx
  80053d:	eb 03                	jmp    800542 <printnum+0xa2>
  80053f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800542:	83 ee 01             	sub    $0x1,%esi
  800545:	85 f6                	test   %esi,%esi
  800547:	7f e8                	jg     800531 <printnum+0x91>
  800549:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80054c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800550:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800554:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80055a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800562:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	e8 bc 0e 00 00       	call   801430 <__umoddi3>
  800574:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800578:	0f be 80 fe 15 80 00 	movsbl 0x8015fe(%eax),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800585:	ff d0                	call   *%eax
}
  800587:	83 c4 3c             	add    $0x3c,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5f                   	pop    %edi
  80058d:	5d                   	pop    %ebp
  80058e:	c3                   	ret    

0080058f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	57                   	push   %edi
  800593:	56                   	push   %esi
  800594:	53                   	push   %ebx
  800595:	83 ec 3c             	sub    $0x3c,%esp
  800598:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80059b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80059e:	89 cf                	mov    %ecx,%edi
  8005a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a9:	89 c3                	mov    %eax,%ebx
  8005ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005bf:	39 d9                	cmp    %ebx,%ecx
  8005c1:	72 13                	jb     8005d6 <cprintnum+0x47>
  8005c3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8005c6:	76 0e                	jbe    8005d6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8005c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005cb:	0b 45 18             	or     0x18(%ebp),%eax
  8005ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	eb 6a                	jmp    800640 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8005d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005dd:	83 ee 01             	sub    $0x1,%esi
  8005e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005f0:	89 c3                	mov    %eax,%ebx
  8005f2:	89 d6                	mov    %edx,%esi
  8005f4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005f7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8005fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800602:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800605:	89 04 24             	mov    %eax,(%esp)
  800608:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80060b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060f:	e8 ec 0c 00 00       	call   801300 <__udivdi3>
  800614:	89 d9                	mov    %ebx,%ecx
  800616:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80061a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80061e:	89 04 24             	mov    %eax,(%esp)
  800621:	89 54 24 04          	mov    %edx,0x4(%esp)
  800625:	89 f9                	mov    %edi,%ecx
  800627:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80062a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80062d:	e8 5d ff ff ff       	call   80058f <cprintnum>
  800632:	eb 16                	jmp    80064a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800634:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800638:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800640:	83 ee 01             	sub    $0x1,%esi
  800643:	85 f6                	test   %esi,%esi
  800645:	7f ed                	jg     800634 <cprintnum+0xa5>
  800647:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80064a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800652:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800655:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800658:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800660:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800663:	89 04 24             	mov    %eax,(%esp)
  800666:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066d:	e8 be 0d 00 00       	call   801430 <__umoddi3>
  800672:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800676:	0f be 80 fe 15 80 00 	movsbl 0x8015fe(%eax),%eax
  80067d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800680:	89 04 24             	mov    %eax,(%esp)
  800683:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800686:	ff d0                	call   *%eax
}
  800688:	83 c4 3c             	add    $0x3c,%esp
  80068b:	5b                   	pop    %ebx
  80068c:	5e                   	pop    %esi
  80068d:	5f                   	pop    %edi
  80068e:	5d                   	pop    %ebp
  80068f:	c3                   	ret    

00800690 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800693:	83 fa 01             	cmp    $0x1,%edx
  800696:	7e 0e                	jle    8006a6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80069d:	89 08                	mov    %ecx,(%eax)
  80069f:	8b 02                	mov    (%edx),%eax
  8006a1:	8b 52 04             	mov    0x4(%edx),%edx
  8006a4:	eb 22                	jmp    8006c8 <getuint+0x38>
	else if (lflag)
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	74 10                	je     8006ba <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b8:	eb 0e                	jmp    8006c8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006bf:	89 08                	mov    %ecx,(%eax)
  8006c1:	8b 02                	mov    (%edx),%eax
  8006c3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006d9:	73 0a                	jae    8006e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006de:	89 08                	mov    %ecx,(%eax)
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	88 02                	mov    %al,(%edx)
}
  8006e5:	5d                   	pop    %ebp
  8006e6:	c3                   	ret    

008006e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	89 04 24             	mov    %eax,(%esp)
  800708:	e8 02 00 00 00       	call   80070f <vprintfmt>
	va_end(ap);
}
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	57                   	push   %edi
  800713:	56                   	push   %esi
  800714:	53                   	push   %ebx
  800715:	83 ec 3c             	sub    $0x3c,%esp
  800718:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80071b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80071e:	eb 14                	jmp    800734 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800720:	85 c0                	test   %eax,%eax
  800722:	0f 84 b3 03 00 00    	je     800adb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800728:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800732:	89 f3                	mov    %esi,%ebx
  800734:	8d 73 01             	lea    0x1(%ebx),%esi
  800737:	0f b6 03             	movzbl (%ebx),%eax
  80073a:	83 f8 25             	cmp    $0x25,%eax
  80073d:	75 e1                	jne    800720 <vprintfmt+0x11>
  80073f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800743:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80074a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800751:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800758:	ba 00 00 00 00       	mov    $0x0,%edx
  80075d:	eb 1d                	jmp    80077c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800761:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800765:	eb 15                	jmp    80077c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800767:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800769:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80076d:	eb 0d                	jmp    80077c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80076f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800772:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800775:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80077f:	0f b6 0e             	movzbl (%esi),%ecx
  800782:	0f b6 c1             	movzbl %cl,%eax
  800785:	83 e9 23             	sub    $0x23,%ecx
  800788:	80 f9 55             	cmp    $0x55,%cl
  80078b:	0f 87 2a 03 00 00    	ja     800abb <vprintfmt+0x3ac>
  800791:	0f b6 c9             	movzbl %cl,%ecx
  800794:	ff 24 8d c0 16 80 00 	jmp    *0x8016c0(,%ecx,4)
  80079b:	89 de                	mov    %ebx,%esi
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007a2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8007a5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8007a9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007ac:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8007af:	83 fb 09             	cmp    $0x9,%ebx
  8007b2:	77 36                	ja     8007ea <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007b4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007b7:	eb e9                	jmp    8007a2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8d 48 04             	lea    0x4(%eax),%ecx
  8007bf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007c2:	8b 00                	mov    (%eax),%eax
  8007c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007c9:	eb 22                	jmp    8007ed <vprintfmt+0xde>
  8007cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ce:	85 c9                	test   %ecx,%ecx
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d5:	0f 49 c1             	cmovns %ecx,%eax
  8007d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007db:	89 de                	mov    %ebx,%esi
  8007dd:	eb 9d                	jmp    80077c <vprintfmt+0x6d>
  8007df:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007e1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8007e8:	eb 92                	jmp    80077c <vprintfmt+0x6d>
  8007ea:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8007ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f1:	79 89                	jns    80077c <vprintfmt+0x6d>
  8007f3:	e9 77 ff ff ff       	jmp    80076f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fb:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007fd:	e9 7a ff ff ff       	jmp    80077c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	8d 50 04             	lea    0x4(%eax),%edx
  800808:	89 55 14             	mov    %edx,0x14(%ebp)
  80080b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80080f:	8b 00                	mov    (%eax),%eax
  800811:	89 04 24             	mov    %eax,(%esp)
  800814:	ff 55 08             	call   *0x8(%ebp)
			break;
  800817:	e9 18 ff ff ff       	jmp    800734 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80081c:	8b 45 14             	mov    0x14(%ebp),%eax
  80081f:	8d 50 04             	lea    0x4(%eax),%edx
  800822:	89 55 14             	mov    %edx,0x14(%ebp)
  800825:	8b 00                	mov    (%eax),%eax
  800827:	99                   	cltd   
  800828:	31 d0                	xor    %edx,%eax
  80082a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80082c:	83 f8 09             	cmp    $0x9,%eax
  80082f:	7f 0b                	jg     80083c <vprintfmt+0x12d>
  800831:	8b 14 85 80 19 80 00 	mov    0x801980(,%eax,4),%edx
  800838:	85 d2                	test   %edx,%edx
  80083a:	75 20                	jne    80085c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80083c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800840:	c7 44 24 08 16 16 80 	movl   $0x801616,0x8(%esp)
  800847:	00 
  800848:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 90 fe ff ff       	call   8006e7 <printfmt>
  800857:	e9 d8 fe ff ff       	jmp    800734 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80085c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800860:	c7 44 24 08 1f 16 80 	movl   $0x80161f,0x8(%esp)
  800867:	00 
  800868:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	89 04 24             	mov    %eax,(%esp)
  800872:	e8 70 fe ff ff       	call   8006e7 <printfmt>
  800877:	e9 b8 fe ff ff       	jmp    800734 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80087f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800882:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8d 50 04             	lea    0x4(%eax),%edx
  80088b:	89 55 14             	mov    %edx,0x14(%ebp)
  80088e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800890:	85 f6                	test   %esi,%esi
  800892:	b8 0f 16 80 00       	mov    $0x80160f,%eax
  800897:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80089a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80089e:	0f 84 97 00 00 00    	je     80093b <vprintfmt+0x22c>
  8008a4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008a8:	0f 8e 9b 00 00 00    	jle    800949 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008b2:	89 34 24             	mov    %esi,(%esp)
  8008b5:	e8 ce 06 00 00       	call   800f88 <strnlen>
  8008ba:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008bd:	29 c2                	sub    %eax,%edx
  8008bf:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8008c2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008c9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008d2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d4:	eb 0f                	jmp    8008e5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8008d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008dd:	89 04 24             	mov    %eax,(%esp)
  8008e0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e2:	83 eb 01             	sub    $0x1,%ebx
  8008e5:	85 db                	test   %ebx,%ebx
  8008e7:	7f ed                	jg     8008d6 <vprintfmt+0x1c7>
  8008e9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008ec:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008ef:	85 d2                	test   %edx,%edx
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	0f 49 c2             	cmovns %edx,%eax
  8008f9:	29 c2                	sub    %eax,%edx
  8008fb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8008fe:	89 d7                	mov    %edx,%edi
  800900:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800903:	eb 50                	jmp    800955 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800905:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800909:	74 1e                	je     800929 <vprintfmt+0x21a>
  80090b:	0f be d2             	movsbl %dl,%edx
  80090e:	83 ea 20             	sub    $0x20,%edx
  800911:	83 fa 5e             	cmp    $0x5e,%edx
  800914:	76 13                	jbe    800929 <vprintfmt+0x21a>
					putch('?', putdat);
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800924:	ff 55 08             	call   *0x8(%ebp)
  800927:	eb 0d                	jmp    800936 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800930:	89 04 24             	mov    %eax,(%esp)
  800933:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800936:	83 ef 01             	sub    $0x1,%edi
  800939:	eb 1a                	jmp    800955 <vprintfmt+0x246>
  80093b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80093e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800941:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800944:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800947:	eb 0c                	jmp    800955 <vprintfmt+0x246>
  800949:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80094c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80094f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800952:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800955:	83 c6 01             	add    $0x1,%esi
  800958:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80095c:	0f be c2             	movsbl %dl,%eax
  80095f:	85 c0                	test   %eax,%eax
  800961:	74 27                	je     80098a <vprintfmt+0x27b>
  800963:	85 db                	test   %ebx,%ebx
  800965:	78 9e                	js     800905 <vprintfmt+0x1f6>
  800967:	83 eb 01             	sub    $0x1,%ebx
  80096a:	79 99                	jns    800905 <vprintfmt+0x1f6>
  80096c:	89 f8                	mov    %edi,%eax
  80096e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800971:	8b 75 08             	mov    0x8(%ebp),%esi
  800974:	89 c3                	mov    %eax,%ebx
  800976:	eb 1a                	jmp    800992 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800978:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800983:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800985:	83 eb 01             	sub    $0x1,%ebx
  800988:	eb 08                	jmp    800992 <vprintfmt+0x283>
  80098a:	89 fb                	mov    %edi,%ebx
  80098c:	8b 75 08             	mov    0x8(%ebp),%esi
  80098f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800992:	85 db                	test   %ebx,%ebx
  800994:	7f e2                	jg     800978 <vprintfmt+0x269>
  800996:	89 75 08             	mov    %esi,0x8(%ebp)
  800999:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80099c:	e9 93 fd ff ff       	jmp    800734 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009a1:	83 fa 01             	cmp    $0x1,%edx
  8009a4:	7e 16                	jle    8009bc <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8009a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a9:	8d 50 08             	lea    0x8(%eax),%edx
  8009ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8009af:	8b 50 04             	mov    0x4(%eax),%edx
  8009b2:	8b 00                	mov    (%eax),%eax
  8009b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009ba:	eb 32                	jmp    8009ee <vprintfmt+0x2df>
	else if (lflag)
  8009bc:	85 d2                	test   %edx,%edx
  8009be:	74 18                	je     8009d8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8009c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c3:	8d 50 04             	lea    0x4(%eax),%edx
  8009c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c9:	8b 30                	mov    (%eax),%esi
  8009cb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009ce:	89 f0                	mov    %esi,%eax
  8009d0:	c1 f8 1f             	sar    $0x1f,%eax
  8009d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009d6:	eb 16                	jmp    8009ee <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8009d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009db:	8d 50 04             	lea    0x4(%eax),%edx
  8009de:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e1:	8b 30                	mov    (%eax),%esi
  8009e3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009e6:	89 f0                	mov    %esi,%eax
  8009e8:	c1 f8 1f             	sar    $0x1f,%eax
  8009eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009fd:	0f 89 80 00 00 00    	jns    800a83 <vprintfmt+0x374>
				putch('-', putdat);
  800a03:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a07:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a0e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a11:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a17:	f7 d8                	neg    %eax
  800a19:	83 d2 00             	adc    $0x0,%edx
  800a1c:	f7 da                	neg    %edx
			}
			base = 10;
  800a1e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a23:	eb 5e                	jmp    800a83 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a25:	8d 45 14             	lea    0x14(%ebp),%eax
  800a28:	e8 63 fc ff ff       	call   800690 <getuint>
			base = 10;
  800a2d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a32:	eb 4f                	jmp    800a83 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800a34:	8d 45 14             	lea    0x14(%ebp),%eax
  800a37:	e8 54 fc ff ff       	call   800690 <getuint>
			base = 8 ;
  800a3c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800a41:	eb 40                	jmp    800a83 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800a43:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a47:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a4e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a51:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a55:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a5c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a62:	8d 50 04             	lea    0x4(%eax),%edx
  800a65:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a68:	8b 00                	mov    (%eax),%eax
  800a6a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a6f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a74:	eb 0d                	jmp    800a83 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a76:	8d 45 14             	lea    0x14(%ebp),%eax
  800a79:	e8 12 fc ff ff       	call   800690 <getuint>
			base = 16;
  800a7e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a83:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800a87:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a8b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a8e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a92:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a96:	89 04 24             	mov    %eax,(%esp)
  800a99:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a9d:	89 fa                	mov    %edi,%edx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	e8 f9 f9 ff ff       	call   8004a0 <printnum>
			break;
  800aa7:	e9 88 fc ff ff       	jmp    800734 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ab0:	89 04 24             	mov    %eax,(%esp)
  800ab3:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ab6:	e9 79 fc ff ff       	jmp    800734 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800abb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800abf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ac6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	eb 03                	jmp    800ad0 <vprintfmt+0x3c1>
  800acd:	83 eb 01             	sub    $0x1,%ebx
  800ad0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ad4:	75 f7                	jne    800acd <vprintfmt+0x3be>
  800ad6:	e9 59 fc ff ff       	jmp    800734 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800adb:	83 c4 3c             	add    $0x3c,%esp
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 3c             	sub    $0x3c,%esp
  800aec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  800aef:	8b 45 14             	mov    0x14(%ebp),%eax
  800af2:	8d 50 04             	lea    0x4(%eax),%edx
  800af5:	89 55 14             	mov    %edx,0x14(%ebp)
  800af8:	8b 00                	mov    (%eax),%eax
  800afa:	c1 e0 08             	shl    $0x8,%eax
  800afd:	0f b7 c0             	movzwl %ax,%eax
  800b00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800b03:	83 c8 25             	or     $0x25,%eax
  800b06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800b09:	eb 1a                	jmp    800b25 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	0f 84 a9 03 00 00    	je     800ebc <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800b13:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b1a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b1d:	89 04 24             	mov    %eax,(%esp)
  800b20:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b23:	89 fb                	mov    %edi,%ebx
  800b25:	8d 7b 01             	lea    0x1(%ebx),%edi
  800b28:	0f b6 03             	movzbl (%ebx),%eax
  800b2b:	83 f8 25             	cmp    $0x25,%eax
  800b2e:	75 db                	jne    800b0b <cvprintfmt+0x28>
  800b30:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800b34:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800b3b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800b40:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	eb 18                	jmp    800b66 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b4e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800b50:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800b54:	eb 10                	jmp    800b66 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b56:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800b58:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800b5c:	eb 08                	jmp    800b66 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800b5e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800b61:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b66:	8d 5f 01             	lea    0x1(%edi),%ebx
  800b69:	0f b6 0f             	movzbl (%edi),%ecx
  800b6c:	0f b6 c1             	movzbl %cl,%eax
  800b6f:	83 e9 23             	sub    $0x23,%ecx
  800b72:	80 f9 55             	cmp    $0x55,%cl
  800b75:	0f 87 1f 03 00 00    	ja     800e9a <cvprintfmt+0x3b7>
  800b7b:	0f b6 c9             	movzbl %cl,%ecx
  800b7e:	ff 24 8d 18 18 80 00 	jmp    *0x801818(,%ecx,4)
  800b85:	89 df                	mov    %ebx,%edi
  800b87:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800b8c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  800b8f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800b93:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800b96:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800b99:	83 f9 09             	cmp    $0x9,%ecx
  800b9c:	77 33                	ja     800bd1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800b9e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ba1:	eb e9                	jmp    800b8c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ba3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba6:	8d 48 04             	lea    0x4(%eax),%ecx
  800ba9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bac:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bae:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800bb0:	eb 1f                	jmp    800bd1 <cvprintfmt+0xee>
  800bb2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800bb5:	85 ff                	test   %edi,%edi
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbc:	0f 49 c7             	cmovns %edi,%eax
  800bbf:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bc2:	89 df                	mov    %ebx,%edi
  800bc4:	eb a0                	jmp    800b66 <cvprintfmt+0x83>
  800bc6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800bc8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800bcf:	eb 95                	jmp    800b66 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800bd1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800bd5:	79 8f                	jns    800b66 <cvprintfmt+0x83>
  800bd7:	eb 85                	jmp    800b5e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800bd9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bdc:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800bde:	66 90                	xchg   %ax,%ax
  800be0:	eb 84                	jmp    800b66 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800be2:	8b 45 14             	mov    0x14(%ebp),%eax
  800be5:	8d 50 04             	lea    0x4(%eax),%edx
  800be8:	89 55 14             	mov    %edx,0x14(%ebp)
  800beb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bee:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bf2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bf5:	0b 10                	or     (%eax),%edx
  800bf7:	89 14 24             	mov    %edx,(%esp)
  800bfa:	ff 55 08             	call   *0x8(%ebp)
			break;
  800bfd:	e9 23 ff ff ff       	jmp    800b25 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800c02:	8b 45 14             	mov    0x14(%ebp),%eax
  800c05:	8d 50 04             	lea    0x4(%eax),%edx
  800c08:	89 55 14             	mov    %edx,0x14(%ebp)
  800c0b:	8b 00                	mov    (%eax),%eax
  800c0d:	99                   	cltd   
  800c0e:	31 d0                	xor    %edx,%eax
  800c10:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800c12:	83 f8 09             	cmp    $0x9,%eax
  800c15:	7f 0b                	jg     800c22 <cvprintfmt+0x13f>
  800c17:	8b 14 85 80 19 80 00 	mov    0x801980(,%eax,4),%edx
  800c1e:	85 d2                	test   %edx,%edx
  800c20:	75 23                	jne    800c45 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800c22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c26:	c7 44 24 08 16 16 80 	movl   $0x801616,0x8(%esp)
  800c2d:	00 
  800c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c35:	8b 45 08             	mov    0x8(%ebp),%eax
  800c38:	89 04 24             	mov    %eax,(%esp)
  800c3b:	e8 a7 fa ff ff       	call   8006e7 <printfmt>
  800c40:	e9 e0 fe ff ff       	jmp    800b25 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800c45:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c49:	c7 44 24 08 1f 16 80 	movl   $0x80161f,0x8(%esp)
  800c50:	00 
  800c51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	89 04 24             	mov    %eax,(%esp)
  800c5e:	e8 84 fa ff ff       	call   8006e7 <printfmt>
  800c63:	e9 bd fe ff ff       	jmp    800b25 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c68:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800c6b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800c6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c71:	8d 48 04             	lea    0x4(%eax),%ecx
  800c74:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c77:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800c79:	85 ff                	test   %edi,%edi
  800c7b:	b8 0f 16 80 00       	mov    $0x80160f,%eax
  800c80:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800c83:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800c87:	74 61                	je     800cea <cvprintfmt+0x207>
  800c89:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800c8d:	7e 5b                	jle    800cea <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800c8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c93:	89 3c 24             	mov    %edi,(%esp)
  800c96:	e8 ed 02 00 00       	call   800f88 <strnlen>
  800c9b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800c9e:	29 c2                	sub    %eax,%edx
  800ca0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800ca3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800ca7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800caa:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800cad:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800cb0:	8b 75 08             	mov    0x8(%ebp),%esi
  800cb3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800cba:	eb 0f                	jmp    800ccb <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc3:	89 3c 24             	mov    %edi,(%esp)
  800cc6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800cc8:	83 eb 01             	sub    $0x1,%ebx
  800ccb:	85 db                	test   %ebx,%ebx
  800ccd:	7f ed                	jg     800cbc <cvprintfmt+0x1d9>
  800ccf:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800cd2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800cdb:	85 d2                	test   %edx,%edx
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce2:	0f 49 c2             	cmovns %edx,%eax
  800ce5:	29 c2                	sub    %eax,%edx
  800ce7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800cea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ced:	83 c8 3f             	or     $0x3f,%eax
  800cf0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cf3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cf6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800cf9:	eb 36                	jmp    800d31 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800cfb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cff:	74 1d                	je     800d1e <cvprintfmt+0x23b>
  800d01:	0f be d2             	movsbl %dl,%edx
  800d04:	83 ea 20             	sub    $0x20,%edx
  800d07:	83 fa 5e             	cmp    $0x5e,%edx
  800d0a:	76 12                	jbe    800d1e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d13:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d16:	89 04 24             	mov    %eax,(%esp)
  800d19:	ff 55 08             	call   *0x8(%ebp)
  800d1c:	eb 10                	jmp    800d2e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d21:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d25:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800d28:	89 04 24             	mov    %eax,(%esp)
  800d2b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d2e:	83 eb 01             	sub    $0x1,%ebx
  800d31:	83 c7 01             	add    $0x1,%edi
  800d34:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800d38:	0f be c2             	movsbl %dl,%eax
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	74 27                	je     800d66 <cvprintfmt+0x283>
  800d3f:	85 f6                	test   %esi,%esi
  800d41:	78 b8                	js     800cfb <cvprintfmt+0x218>
  800d43:	83 ee 01             	sub    $0x1,%esi
  800d46:	79 b3                	jns    800cfb <cvprintfmt+0x218>
  800d48:	89 d8                	mov    %ebx,%eax
  800d4a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d4d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d50:	89 c3                	mov    %eax,%ebx
  800d52:	eb 18                	jmp    800d6c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800d54:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d58:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800d5f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800d61:	83 eb 01             	sub    $0x1,%ebx
  800d64:	eb 06                	jmp    800d6c <cvprintfmt+0x289>
  800d66:	8b 75 08             	mov    0x8(%ebp),%esi
  800d69:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d6c:	85 db                	test   %ebx,%ebx
  800d6e:	7f e4                	jg     800d54 <cvprintfmt+0x271>
  800d70:	89 75 08             	mov    %esi,0x8(%ebp)
  800d73:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d79:	e9 a7 fd ff ff       	jmp    800b25 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d7e:	83 fa 01             	cmp    $0x1,%edx
  800d81:	7e 10                	jle    800d93 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800d83:	8b 45 14             	mov    0x14(%ebp),%eax
  800d86:	8d 50 08             	lea    0x8(%eax),%edx
  800d89:	89 55 14             	mov    %edx,0x14(%ebp)
  800d8c:	8b 30                	mov    (%eax),%esi
  800d8e:	8b 78 04             	mov    0x4(%eax),%edi
  800d91:	eb 26                	jmp    800db9 <cvprintfmt+0x2d6>
	else if (lflag)
  800d93:	85 d2                	test   %edx,%edx
  800d95:	74 12                	je     800da9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800d97:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9a:	8d 50 04             	lea    0x4(%eax),%edx
  800d9d:	89 55 14             	mov    %edx,0x14(%ebp)
  800da0:	8b 30                	mov    (%eax),%esi
  800da2:	89 f7                	mov    %esi,%edi
  800da4:	c1 ff 1f             	sar    $0x1f,%edi
  800da7:	eb 10                	jmp    800db9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800da9:	8b 45 14             	mov    0x14(%ebp),%eax
  800dac:	8d 50 04             	lea    0x4(%eax),%edx
  800daf:	89 55 14             	mov    %edx,0x14(%ebp)
  800db2:	8b 30                	mov    (%eax),%esi
  800db4:	89 f7                	mov    %esi,%edi
  800db6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800dbd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800dc2:	85 ff                	test   %edi,%edi
  800dc4:	0f 89 8e 00 00 00    	jns    800e58 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800dca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd4:	83 c8 2d             	or     $0x2d,%eax
  800dd7:	89 04 24             	mov    %eax,(%esp)
  800dda:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	89 fa                	mov    %edi,%edx
  800de1:	f7 d8                	neg    %eax
  800de3:	83 d2 00             	adc    $0x0,%edx
  800de6:	f7 da                	neg    %edx
			}
			base = 10;
  800de8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ded:	eb 69                	jmp    800e58 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800def:	8d 45 14             	lea    0x14(%ebp),%eax
  800df2:	e8 99 f8 ff ff       	call   800690 <getuint>
			base = 10;
  800df7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800dfc:	eb 5a                	jmp    800e58 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800dfe:	8d 45 14             	lea    0x14(%ebp),%eax
  800e01:	e8 8a f8 ff ff       	call   800690 <getuint>
			base = 8 ;
  800e06:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800e0b:	eb 4b                	jmp    800e58 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e14:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800e17:	89 f0                	mov    %esi,%eax
  800e19:	83 c8 30             	or     $0x30,%eax
  800e1c:	89 04 24             	mov    %eax,(%esp)
  800e1f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e29:	89 f0                	mov    %esi,%eax
  800e2b:	83 c8 78             	or     $0x78,%eax
  800e2e:	89 04 24             	mov    %eax,(%esp)
  800e31:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e34:	8b 45 14             	mov    0x14(%ebp),%eax
  800e37:	8d 50 04             	lea    0x4(%eax),%edx
  800e3a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800e3d:	8b 00                	mov    (%eax),%eax
  800e3f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e44:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800e49:	eb 0d                	jmp    800e58 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e4b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e4e:	e8 3d f8 ff ff       	call   800690 <getuint>
			base = 16;
  800e53:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800e58:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800e5c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e60:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800e63:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e67:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e6b:	89 04 24             	mov    %eax,(%esp)
  800e6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e7b:	e8 0f f7 ff ff       	call   80058f <cprintnum>
			break;
  800e80:	e9 a0 fc ff ff       	jmp    800b25 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800e85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e88:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e8c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800e8f:	89 04 24             	mov    %eax,(%esp)
  800e92:	ff 55 08             	call   *0x8(%ebp)
			break;
  800e95:	e9 8b fc ff ff       	jmp    800b25 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ea4:	89 04 24             	mov    %eax,(%esp)
  800ea7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800eaa:	89 fb                	mov    %edi,%ebx
  800eac:	eb 03                	jmp    800eb1 <cvprintfmt+0x3ce>
  800eae:	83 eb 01             	sub    $0x1,%ebx
  800eb1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800eb5:	75 f7                	jne    800eae <cvprintfmt+0x3cb>
  800eb7:	e9 69 fc ff ff       	jmp    800b25 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800ebc:	83 c4 3c             	add    $0x3c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800eca:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800ecd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	89 04 24             	mov    %eax,(%esp)
  800ee5:	e8 f9 fb ff ff       	call   800ae3 <cvprintfmt>
	va_end(ap);
}
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 28             	sub    $0x28,%esp
  800ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ef8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800efb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800eff:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	74 30                	je     800f3d <vsnprintf+0x51>
  800f0d:	85 d2                	test   %edx,%edx
  800f0f:	7e 2c                	jle    800f3d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f11:	8b 45 14             	mov    0x14(%ebp),%eax
  800f14:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f18:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f1f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f26:	c7 04 24 ca 06 80 00 	movl   $0x8006ca,(%esp)
  800f2d:	e8 dd f7 ff ff       	call   80070f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f35:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f3b:	eb 05                	jmp    800f42 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f4a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f51:	8b 45 10             	mov    0x10(%ebp),%eax
  800f54:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	89 04 24             	mov    %eax,(%esp)
  800f65:	e8 82 ff ff ff       	call   800eec <vsnprintf>
	va_end(ap);

	return rc;
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7b:	eb 03                	jmp    800f80 <strlen+0x10>
		n++;
  800f7d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f80:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f84:	75 f7                	jne    800f7d <strlen+0xd>
		n++;
	return n;
}
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f8e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f91:	b8 00 00 00 00       	mov    $0x0,%eax
  800f96:	eb 03                	jmp    800f9b <strnlen+0x13>
		n++;
  800f98:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f9b:	39 d0                	cmp    %edx,%eax
  800f9d:	74 06                	je     800fa5 <strnlen+0x1d>
  800f9f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fa3:	75 f3                	jne    800f98 <strnlen+0x10>
		n++;
	return n;
}
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	53                   	push   %ebx
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
  800fae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fb1:	89 c2                	mov    %eax,%edx
  800fb3:	83 c2 01             	add    $0x1,%edx
  800fb6:	83 c1 01             	add    $0x1,%ecx
  800fb9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800fbd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800fc0:	84 db                	test   %bl,%bl
  800fc2:	75 ef                	jne    800fb3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800fc4:	5b                   	pop    %ebx
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 08             	sub    $0x8,%esp
  800fce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fd1:	89 1c 24             	mov    %ebx,(%esp)
  800fd4:	e8 97 ff ff ff       	call   800f70 <strlen>
	strcpy(dst + len, src);
  800fd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe0:	01 d8                	add    %ebx,%eax
  800fe2:	89 04 24             	mov    %eax,(%esp)
  800fe5:	e8 bd ff ff ff       	call   800fa7 <strcpy>
	return dst;
}
  800fea:	89 d8                	mov    %ebx,%eax
  800fec:	83 c4 08             	add    $0x8,%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	56                   	push   %esi
  800ff6:	53                   	push   %ebx
  800ff7:	8b 75 08             	mov    0x8(%ebp),%esi
  800ffa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffd:	89 f3                	mov    %esi,%ebx
  800fff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801002:	89 f2                	mov    %esi,%edx
  801004:	eb 0f                	jmp    801015 <strncpy+0x23>
		*dst++ = *src;
  801006:	83 c2 01             	add    $0x1,%edx
  801009:	0f b6 01             	movzbl (%ecx),%eax
  80100c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80100f:	80 39 01             	cmpb   $0x1,(%ecx)
  801012:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801015:	39 da                	cmp    %ebx,%edx
  801017:	75 ed                	jne    801006 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801019:	89 f0                	mov    %esi,%eax
  80101b:	5b                   	pop    %ebx
  80101c:	5e                   	pop    %esi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    

0080101f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	8b 75 08             	mov    0x8(%ebp),%esi
  801027:	8b 55 0c             	mov    0xc(%ebp),%edx
  80102a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801033:	85 c9                	test   %ecx,%ecx
  801035:	75 0b                	jne    801042 <strlcpy+0x23>
  801037:	eb 1d                	jmp    801056 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801039:	83 c0 01             	add    $0x1,%eax
  80103c:	83 c2 01             	add    $0x1,%edx
  80103f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801042:	39 d8                	cmp    %ebx,%eax
  801044:	74 0b                	je     801051 <strlcpy+0x32>
  801046:	0f b6 0a             	movzbl (%edx),%ecx
  801049:	84 c9                	test   %cl,%cl
  80104b:	75 ec                	jne    801039 <strlcpy+0x1a>
  80104d:	89 c2                	mov    %eax,%edx
  80104f:	eb 02                	jmp    801053 <strlcpy+0x34>
  801051:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801053:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801056:	29 f0                	sub    %esi,%eax
}
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801062:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801065:	eb 06                	jmp    80106d <strcmp+0x11>
		p++, q++;
  801067:	83 c1 01             	add    $0x1,%ecx
  80106a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80106d:	0f b6 01             	movzbl (%ecx),%eax
  801070:	84 c0                	test   %al,%al
  801072:	74 04                	je     801078 <strcmp+0x1c>
  801074:	3a 02                	cmp    (%edx),%al
  801076:	74 ef                	je     801067 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801078:	0f b6 c0             	movzbl %al,%eax
  80107b:	0f b6 12             	movzbl (%edx),%edx
  80107e:	29 d0                	sub    %edx,%eax
}
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	53                   	push   %ebx
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108c:	89 c3                	mov    %eax,%ebx
  80108e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801091:	eb 06                	jmp    801099 <strncmp+0x17>
		n--, p++, q++;
  801093:	83 c0 01             	add    $0x1,%eax
  801096:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801099:	39 d8                	cmp    %ebx,%eax
  80109b:	74 15                	je     8010b2 <strncmp+0x30>
  80109d:	0f b6 08             	movzbl (%eax),%ecx
  8010a0:	84 c9                	test   %cl,%cl
  8010a2:	74 04                	je     8010a8 <strncmp+0x26>
  8010a4:	3a 0a                	cmp    (%edx),%cl
  8010a6:	74 eb                	je     801093 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010a8:	0f b6 00             	movzbl (%eax),%eax
  8010ab:	0f b6 12             	movzbl (%edx),%edx
  8010ae:	29 d0                	sub    %edx,%eax
  8010b0:	eb 05                	jmp    8010b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010b7:	5b                   	pop    %ebx
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8010c4:	eb 07                	jmp    8010cd <strchr+0x13>
		if (*s == c)
  8010c6:	38 ca                	cmp    %cl,%dl
  8010c8:	74 0f                	je     8010d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010ca:	83 c0 01             	add    $0x1,%eax
  8010cd:	0f b6 10             	movzbl (%eax),%edx
  8010d0:	84 d2                	test   %dl,%dl
  8010d2:	75 f2                	jne    8010c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8010d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8010e5:	eb 07                	jmp    8010ee <strfind+0x13>
		if (*s == c)
  8010e7:	38 ca                	cmp    %cl,%dl
  8010e9:	74 0a                	je     8010f5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010eb:	83 c0 01             	add    $0x1,%eax
  8010ee:	0f b6 10             	movzbl (%eax),%edx
  8010f1:	84 d2                	test   %dl,%dl
  8010f3:	75 f2                	jne    8010e7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	57                   	push   %edi
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801100:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801103:	85 c9                	test   %ecx,%ecx
  801105:	74 36                	je     80113d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801107:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80110d:	75 28                	jne    801137 <memset+0x40>
  80110f:	f6 c1 03             	test   $0x3,%cl
  801112:	75 23                	jne    801137 <memset+0x40>
		c &= 0xFF;
  801114:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801118:	89 d3                	mov    %edx,%ebx
  80111a:	c1 e3 08             	shl    $0x8,%ebx
  80111d:	89 d6                	mov    %edx,%esi
  80111f:	c1 e6 18             	shl    $0x18,%esi
  801122:	89 d0                	mov    %edx,%eax
  801124:	c1 e0 10             	shl    $0x10,%eax
  801127:	09 f0                	or     %esi,%eax
  801129:	09 c2                	or     %eax,%edx
  80112b:	89 d0                	mov    %edx,%eax
  80112d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80112f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801132:	fc                   	cld    
  801133:	f3 ab                	rep stos %eax,%es:(%edi)
  801135:	eb 06                	jmp    80113d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801137:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113a:	fc                   	cld    
  80113b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80113d:	89 f8                	mov    %edi,%eax
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	57                   	push   %edi
  801148:	56                   	push   %esi
  801149:	8b 45 08             	mov    0x8(%ebp),%eax
  80114c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80114f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801152:	39 c6                	cmp    %eax,%esi
  801154:	73 35                	jae    80118b <memmove+0x47>
  801156:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801159:	39 d0                	cmp    %edx,%eax
  80115b:	73 2e                	jae    80118b <memmove+0x47>
		s += n;
		d += n;
  80115d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801160:	89 d6                	mov    %edx,%esi
  801162:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801164:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80116a:	75 13                	jne    80117f <memmove+0x3b>
  80116c:	f6 c1 03             	test   $0x3,%cl
  80116f:	75 0e                	jne    80117f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801171:	83 ef 04             	sub    $0x4,%edi
  801174:	8d 72 fc             	lea    -0x4(%edx),%esi
  801177:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80117a:	fd                   	std    
  80117b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80117d:	eb 09                	jmp    801188 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80117f:	83 ef 01             	sub    $0x1,%edi
  801182:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801185:	fd                   	std    
  801186:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801188:	fc                   	cld    
  801189:	eb 1d                	jmp    8011a8 <memmove+0x64>
  80118b:	89 f2                	mov    %esi,%edx
  80118d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80118f:	f6 c2 03             	test   $0x3,%dl
  801192:	75 0f                	jne    8011a3 <memmove+0x5f>
  801194:	f6 c1 03             	test   $0x3,%cl
  801197:	75 0a                	jne    8011a3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801199:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80119c:	89 c7                	mov    %eax,%edi
  80119e:	fc                   	cld    
  80119f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011a1:	eb 05                	jmp    8011a8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011a3:	89 c7                	mov    %eax,%edi
  8011a5:	fc                   	cld    
  8011a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c3:	89 04 24             	mov    %eax,(%esp)
  8011c6:	e8 79 ff ff ff       	call   801144 <memmove>
}
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	56                   	push   %esi
  8011d1:	53                   	push   %ebx
  8011d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d8:	89 d6                	mov    %edx,%esi
  8011da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011dd:	eb 1a                	jmp    8011f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8011df:	0f b6 02             	movzbl (%edx),%eax
  8011e2:	0f b6 19             	movzbl (%ecx),%ebx
  8011e5:	38 d8                	cmp    %bl,%al
  8011e7:	74 0a                	je     8011f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8011e9:	0f b6 c0             	movzbl %al,%eax
  8011ec:	0f b6 db             	movzbl %bl,%ebx
  8011ef:	29 d8                	sub    %ebx,%eax
  8011f1:	eb 0f                	jmp    801202 <memcmp+0x35>
		s1++, s2++;
  8011f3:	83 c2 01             	add    $0x1,%edx
  8011f6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011f9:	39 f2                	cmp    %esi,%edx
  8011fb:	75 e2                	jne    8011df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
  80120c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80120f:	89 c2                	mov    %eax,%edx
  801211:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801214:	eb 07                	jmp    80121d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801216:	38 08                	cmp    %cl,(%eax)
  801218:	74 07                	je     801221 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80121a:	83 c0 01             	add    $0x1,%eax
  80121d:	39 d0                	cmp    %edx,%eax
  80121f:	72 f5                	jb     801216 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	57                   	push   %edi
  801227:	56                   	push   %esi
  801228:	53                   	push   %ebx
  801229:	8b 55 08             	mov    0x8(%ebp),%edx
  80122c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80122f:	eb 03                	jmp    801234 <strtol+0x11>
		s++;
  801231:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801234:	0f b6 0a             	movzbl (%edx),%ecx
  801237:	80 f9 09             	cmp    $0x9,%cl
  80123a:	74 f5                	je     801231 <strtol+0xe>
  80123c:	80 f9 20             	cmp    $0x20,%cl
  80123f:	74 f0                	je     801231 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801241:	80 f9 2b             	cmp    $0x2b,%cl
  801244:	75 0a                	jne    801250 <strtol+0x2d>
		s++;
  801246:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801249:	bf 00 00 00 00       	mov    $0x0,%edi
  80124e:	eb 11                	jmp    801261 <strtol+0x3e>
  801250:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801255:	80 f9 2d             	cmp    $0x2d,%cl
  801258:	75 07                	jne    801261 <strtol+0x3e>
		s++, neg = 1;
  80125a:	8d 52 01             	lea    0x1(%edx),%edx
  80125d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801261:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801266:	75 15                	jne    80127d <strtol+0x5a>
  801268:	80 3a 30             	cmpb   $0x30,(%edx)
  80126b:	75 10                	jne    80127d <strtol+0x5a>
  80126d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801271:	75 0a                	jne    80127d <strtol+0x5a>
		s += 2, base = 16;
  801273:	83 c2 02             	add    $0x2,%edx
  801276:	b8 10 00 00 00       	mov    $0x10,%eax
  80127b:	eb 10                	jmp    80128d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80127d:	85 c0                	test   %eax,%eax
  80127f:	75 0c                	jne    80128d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801281:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801283:	80 3a 30             	cmpb   $0x30,(%edx)
  801286:	75 05                	jne    80128d <strtol+0x6a>
		s++, base = 8;
  801288:	83 c2 01             	add    $0x1,%edx
  80128b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80128d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801292:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801295:	0f b6 0a             	movzbl (%edx),%ecx
  801298:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80129b:	89 f0                	mov    %esi,%eax
  80129d:	3c 09                	cmp    $0x9,%al
  80129f:	77 08                	ja     8012a9 <strtol+0x86>
			dig = *s - '0';
  8012a1:	0f be c9             	movsbl %cl,%ecx
  8012a4:	83 e9 30             	sub    $0x30,%ecx
  8012a7:	eb 20                	jmp    8012c9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8012a9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8012ac:	89 f0                	mov    %esi,%eax
  8012ae:	3c 19                	cmp    $0x19,%al
  8012b0:	77 08                	ja     8012ba <strtol+0x97>
			dig = *s - 'a' + 10;
  8012b2:	0f be c9             	movsbl %cl,%ecx
  8012b5:	83 e9 57             	sub    $0x57,%ecx
  8012b8:	eb 0f                	jmp    8012c9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8012ba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8012bd:	89 f0                	mov    %esi,%eax
  8012bf:	3c 19                	cmp    $0x19,%al
  8012c1:	77 16                	ja     8012d9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8012c3:	0f be c9             	movsbl %cl,%ecx
  8012c6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012c9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8012cc:	7d 0f                	jge    8012dd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8012ce:	83 c2 01             	add    $0x1,%edx
  8012d1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8012d5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8012d7:	eb bc                	jmp    801295 <strtol+0x72>
  8012d9:	89 d8                	mov    %ebx,%eax
  8012db:	eb 02                	jmp    8012df <strtol+0xbc>
  8012dd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8012df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012e3:	74 05                	je     8012ea <strtol+0xc7>
		*endptr = (char *) s;
  8012e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012e8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8012ea:	f7 d8                	neg    %eax
  8012ec:	85 ff                	test   %edi,%edi
  8012ee:	0f 44 c3             	cmove  %ebx,%eax
}
  8012f1:	5b                   	pop    %ebx
  8012f2:	5e                   	pop    %esi
  8012f3:	5f                   	pop    %edi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    
  8012f6:	66 90                	xchg   %ax,%ax
  8012f8:	66 90                	xchg   %ax,%ax
  8012fa:	66 90                	xchg   %ax,%ax
  8012fc:	66 90                	xchg   %ax,%ax
  8012fe:	66 90                	xchg   %ax,%ax

00801300 <__udivdi3>:
  801300:	55                   	push   %ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	8b 44 24 28          	mov    0x28(%esp),%eax
  80130a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80130e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801312:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801316:	85 c0                	test   %eax,%eax
  801318:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80131c:	89 ea                	mov    %ebp,%edx
  80131e:	89 0c 24             	mov    %ecx,(%esp)
  801321:	75 2d                	jne    801350 <__udivdi3+0x50>
  801323:	39 e9                	cmp    %ebp,%ecx
  801325:	77 61                	ja     801388 <__udivdi3+0x88>
  801327:	85 c9                	test   %ecx,%ecx
  801329:	89 ce                	mov    %ecx,%esi
  80132b:	75 0b                	jne    801338 <__udivdi3+0x38>
  80132d:	b8 01 00 00 00       	mov    $0x1,%eax
  801332:	31 d2                	xor    %edx,%edx
  801334:	f7 f1                	div    %ecx
  801336:	89 c6                	mov    %eax,%esi
  801338:	31 d2                	xor    %edx,%edx
  80133a:	89 e8                	mov    %ebp,%eax
  80133c:	f7 f6                	div    %esi
  80133e:	89 c5                	mov    %eax,%ebp
  801340:	89 f8                	mov    %edi,%eax
  801342:	f7 f6                	div    %esi
  801344:	89 ea                	mov    %ebp,%edx
  801346:	83 c4 0c             	add    $0xc,%esp
  801349:	5e                   	pop    %esi
  80134a:	5f                   	pop    %edi
  80134b:	5d                   	pop    %ebp
  80134c:	c3                   	ret    
  80134d:	8d 76 00             	lea    0x0(%esi),%esi
  801350:	39 e8                	cmp    %ebp,%eax
  801352:	77 24                	ja     801378 <__udivdi3+0x78>
  801354:	0f bd e8             	bsr    %eax,%ebp
  801357:	83 f5 1f             	xor    $0x1f,%ebp
  80135a:	75 3c                	jne    801398 <__udivdi3+0x98>
  80135c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801360:	39 34 24             	cmp    %esi,(%esp)
  801363:	0f 86 9f 00 00 00    	jbe    801408 <__udivdi3+0x108>
  801369:	39 d0                	cmp    %edx,%eax
  80136b:	0f 82 97 00 00 00    	jb     801408 <__udivdi3+0x108>
  801371:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801378:	31 d2                	xor    %edx,%edx
  80137a:	31 c0                	xor    %eax,%eax
  80137c:	83 c4 0c             	add    $0xc,%esp
  80137f:	5e                   	pop    %esi
  801380:	5f                   	pop    %edi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    
  801383:	90                   	nop
  801384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801388:	89 f8                	mov    %edi,%eax
  80138a:	f7 f1                	div    %ecx
  80138c:	31 d2                	xor    %edx,%edx
  80138e:	83 c4 0c             	add    $0xc,%esp
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    
  801395:	8d 76 00             	lea    0x0(%esi),%esi
  801398:	89 e9                	mov    %ebp,%ecx
  80139a:	8b 3c 24             	mov    (%esp),%edi
  80139d:	d3 e0                	shl    %cl,%eax
  80139f:	89 c6                	mov    %eax,%esi
  8013a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013a6:	29 e8                	sub    %ebp,%eax
  8013a8:	89 c1                	mov    %eax,%ecx
  8013aa:	d3 ef                	shr    %cl,%edi
  8013ac:	89 e9                	mov    %ebp,%ecx
  8013ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013b2:	8b 3c 24             	mov    (%esp),%edi
  8013b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013b9:	89 d6                	mov    %edx,%esi
  8013bb:	d3 e7                	shl    %cl,%edi
  8013bd:	89 c1                	mov    %eax,%ecx
  8013bf:	89 3c 24             	mov    %edi,(%esp)
  8013c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013c6:	d3 ee                	shr    %cl,%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	d3 e2                	shl    %cl,%edx
  8013cc:	89 c1                	mov    %eax,%ecx
  8013ce:	d3 ef                	shr    %cl,%edi
  8013d0:	09 d7                	or     %edx,%edi
  8013d2:	89 f2                	mov    %esi,%edx
  8013d4:	89 f8                	mov    %edi,%eax
  8013d6:	f7 74 24 08          	divl   0x8(%esp)
  8013da:	89 d6                	mov    %edx,%esi
  8013dc:	89 c7                	mov    %eax,%edi
  8013de:	f7 24 24             	mull   (%esp)
  8013e1:	39 d6                	cmp    %edx,%esi
  8013e3:	89 14 24             	mov    %edx,(%esp)
  8013e6:	72 30                	jb     801418 <__udivdi3+0x118>
  8013e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013ec:	89 e9                	mov    %ebp,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	39 c2                	cmp    %eax,%edx
  8013f2:	73 05                	jae    8013f9 <__udivdi3+0xf9>
  8013f4:	3b 34 24             	cmp    (%esp),%esi
  8013f7:	74 1f                	je     801418 <__udivdi3+0x118>
  8013f9:	89 f8                	mov    %edi,%eax
  8013fb:	31 d2                	xor    %edx,%edx
  8013fd:	e9 7a ff ff ff       	jmp    80137c <__udivdi3+0x7c>
  801402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801408:	31 d2                	xor    %edx,%edx
  80140a:	b8 01 00 00 00       	mov    $0x1,%eax
  80140f:	e9 68 ff ff ff       	jmp    80137c <__udivdi3+0x7c>
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	8d 47 ff             	lea    -0x1(%edi),%eax
  80141b:	31 d2                	xor    %edx,%edx
  80141d:	83 c4 0c             	add    $0xc,%esp
  801420:	5e                   	pop    %esi
  801421:	5f                   	pop    %edi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    
  801424:	66 90                	xchg   %ax,%ax
  801426:	66 90                	xchg   %ax,%ax
  801428:	66 90                	xchg   %ax,%ax
  80142a:	66 90                	xchg   %ax,%ax
  80142c:	66 90                	xchg   %ax,%ax
  80142e:	66 90                	xchg   %ax,%ax

00801430 <__umoddi3>:
  801430:	55                   	push   %ebp
  801431:	57                   	push   %edi
  801432:	56                   	push   %esi
  801433:	83 ec 14             	sub    $0x14,%esp
  801436:	8b 44 24 28          	mov    0x28(%esp),%eax
  80143a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80143e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801442:	89 c7                	mov    %eax,%edi
  801444:	89 44 24 04          	mov    %eax,0x4(%esp)
  801448:	8b 44 24 30          	mov    0x30(%esp),%eax
  80144c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801450:	89 34 24             	mov    %esi,(%esp)
  801453:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801457:	85 c0                	test   %eax,%eax
  801459:	89 c2                	mov    %eax,%edx
  80145b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80145f:	75 17                	jne    801478 <__umoddi3+0x48>
  801461:	39 fe                	cmp    %edi,%esi
  801463:	76 4b                	jbe    8014b0 <__umoddi3+0x80>
  801465:	89 c8                	mov    %ecx,%eax
  801467:	89 fa                	mov    %edi,%edx
  801469:	f7 f6                	div    %esi
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	31 d2                	xor    %edx,%edx
  80146f:	83 c4 14             	add    $0x14,%esp
  801472:	5e                   	pop    %esi
  801473:	5f                   	pop    %edi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    
  801476:	66 90                	xchg   %ax,%ax
  801478:	39 f8                	cmp    %edi,%eax
  80147a:	77 54                	ja     8014d0 <__umoddi3+0xa0>
  80147c:	0f bd e8             	bsr    %eax,%ebp
  80147f:	83 f5 1f             	xor    $0x1f,%ebp
  801482:	75 5c                	jne    8014e0 <__umoddi3+0xb0>
  801484:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801488:	39 3c 24             	cmp    %edi,(%esp)
  80148b:	0f 87 e7 00 00 00    	ja     801578 <__umoddi3+0x148>
  801491:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801495:	29 f1                	sub    %esi,%ecx
  801497:	19 c7                	sbb    %eax,%edi
  801499:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80149d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014a9:	83 c4 14             	add    $0x14,%esp
  8014ac:	5e                   	pop    %esi
  8014ad:	5f                   	pop    %edi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    
  8014b0:	85 f6                	test   %esi,%esi
  8014b2:	89 f5                	mov    %esi,%ebp
  8014b4:	75 0b                	jne    8014c1 <__umoddi3+0x91>
  8014b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	f7 f6                	div    %esi
  8014bf:	89 c5                	mov    %eax,%ebp
  8014c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014c5:	31 d2                	xor    %edx,%edx
  8014c7:	f7 f5                	div    %ebp
  8014c9:	89 c8                	mov    %ecx,%eax
  8014cb:	f7 f5                	div    %ebp
  8014cd:	eb 9c                	jmp    80146b <__umoddi3+0x3b>
  8014cf:	90                   	nop
  8014d0:	89 c8                	mov    %ecx,%eax
  8014d2:	89 fa                	mov    %edi,%edx
  8014d4:	83 c4 14             	add    $0x14,%esp
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    
  8014db:	90                   	nop
  8014dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e0:	8b 04 24             	mov    (%esp),%eax
  8014e3:	be 20 00 00 00       	mov    $0x20,%esi
  8014e8:	89 e9                	mov    %ebp,%ecx
  8014ea:	29 ee                	sub    %ebp,%esi
  8014ec:	d3 e2                	shl    %cl,%edx
  8014ee:	89 f1                	mov    %esi,%ecx
  8014f0:	d3 e8                	shr    %cl,%eax
  8014f2:	89 e9                	mov    %ebp,%ecx
  8014f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f8:	8b 04 24             	mov    (%esp),%eax
  8014fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8014ff:	89 fa                	mov    %edi,%edx
  801501:	d3 e0                	shl    %cl,%eax
  801503:	89 f1                	mov    %esi,%ecx
  801505:	89 44 24 08          	mov    %eax,0x8(%esp)
  801509:	8b 44 24 10          	mov    0x10(%esp),%eax
  80150d:	d3 ea                	shr    %cl,%edx
  80150f:	89 e9                	mov    %ebp,%ecx
  801511:	d3 e7                	shl    %cl,%edi
  801513:	89 f1                	mov    %esi,%ecx
  801515:	d3 e8                	shr    %cl,%eax
  801517:	89 e9                	mov    %ebp,%ecx
  801519:	09 f8                	or     %edi,%eax
  80151b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80151f:	f7 74 24 04          	divl   0x4(%esp)
  801523:	d3 e7                	shl    %cl,%edi
  801525:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801529:	89 d7                	mov    %edx,%edi
  80152b:	f7 64 24 08          	mull   0x8(%esp)
  80152f:	39 d7                	cmp    %edx,%edi
  801531:	89 c1                	mov    %eax,%ecx
  801533:	89 14 24             	mov    %edx,(%esp)
  801536:	72 2c                	jb     801564 <__umoddi3+0x134>
  801538:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80153c:	72 22                	jb     801560 <__umoddi3+0x130>
  80153e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801542:	29 c8                	sub    %ecx,%eax
  801544:	19 d7                	sbb    %edx,%edi
  801546:	89 e9                	mov    %ebp,%ecx
  801548:	89 fa                	mov    %edi,%edx
  80154a:	d3 e8                	shr    %cl,%eax
  80154c:	89 f1                	mov    %esi,%ecx
  80154e:	d3 e2                	shl    %cl,%edx
  801550:	89 e9                	mov    %ebp,%ecx
  801552:	d3 ef                	shr    %cl,%edi
  801554:	09 d0                	or     %edx,%eax
  801556:	89 fa                	mov    %edi,%edx
  801558:	83 c4 14             	add    $0x14,%esp
  80155b:	5e                   	pop    %esi
  80155c:	5f                   	pop    %edi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    
  80155f:	90                   	nop
  801560:	39 d7                	cmp    %edx,%edi
  801562:	75 da                	jne    80153e <__umoddi3+0x10e>
  801564:	8b 14 24             	mov    (%esp),%edx
  801567:	89 c1                	mov    %eax,%ecx
  801569:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80156d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801571:	eb cb                	jmp    80153e <__umoddi3+0x10e>
  801573:	90                   	nop
  801574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801578:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80157c:	0f 82 0f ff ff ff    	jb     801491 <__umoddi3+0x61>
  801582:	e9 1a ff ff ff       	jmp    8014a1 <__umoddi3+0x71>
