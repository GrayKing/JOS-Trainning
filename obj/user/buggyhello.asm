
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1e 00 00 00       	call   80004f <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800048:	e8 62 00 00 00       	call   8000af <sys_cputs>
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    

0080004f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 10             	sub    $0x10,%esp
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  80005d:	e8 dc 00 00 00       	call   80013e <sys_getenvid>
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	89 c2                	mov    %eax,%edx
  800069:	c1 e2 07             	shl    $0x7,%edx
  80006c:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800073:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	85 db                	test   %ebx,%ebx
  80007a:	7e 07                	jle    800083 <libmain+0x34>
		binaryname = argv[0];
  80007c:	8b 06                	mov    (%esi),%eax
  80007e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800083:	89 74 24 04          	mov    %esi,0x4(%esp)
  800087:	89 1c 24             	mov    %ebx,(%esp)
  80008a:	e8 a4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008f:	e8 07 00 00 00       	call   80009b <exit>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    

0080009b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a8:	e8 3f 00 00 00       	call   8000ec <sys_env_destroy>
}
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    

008000af <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	89 c7                	mov    %eax,%edi
  8000c4:	89 c6                	mov    %eax,%esi
  8000c6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5f                   	pop    %edi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dd:	89 d1                	mov    %edx,%ecx
  8000df:	89 d3                	mov    %edx,%ebx
  8000e1:	89 d7                	mov    %edx,%edi
  8000e3:	89 d6                	mov    %edx,%esi
  8000e5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800102:	89 cb                	mov    %ecx,%ebx
  800104:	89 cf                	mov    %ecx,%edi
  800106:	89 ce                	mov    %ecx,%esi
  800108:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010a:	85 c0                	test   %eax,%eax
  80010c:	7e 28                	jle    800136 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800112:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800119:	00 
  80011a:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  800121:	00 
  800122:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800129:	00 
  80012a:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800131:	e8 5b 02 00 00       	call   800391 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800136:	83 c4 2c             	add    $0x2c,%esp
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5f                   	pop    %edi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	57                   	push   %edi
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800144:	ba 00 00 00 00       	mov    $0x0,%edx
  800149:	b8 02 00 00 00       	mov    $0x2,%eax
  80014e:	89 d1                	mov    %edx,%ecx
  800150:	89 d3                	mov    %edx,%ebx
  800152:	89 d7                	mov    %edx,%edi
  800154:	89 d6                	mov    %edx,%esi
  800156:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800158:	5b                   	pop    %ebx
  800159:	5e                   	pop    %esi
  80015a:	5f                   	pop    %edi
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <sys_yield>:

void
sys_yield(void)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	ba 00 00 00 00       	mov    $0x0,%edx
  800168:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016d:	89 d1                	mov    %edx,%ecx
  80016f:	89 d3                	mov    %edx,%ebx
  800171:	89 d7                	mov    %edx,%edi
  800173:	89 d6                	mov    %edx,%esi
  800175:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800177:	5b                   	pop    %ebx
  800178:	5e                   	pop    %esi
  800179:	5f                   	pop    %edi
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800185:	be 00 00 00 00       	mov    $0x0,%esi
  80018a:	b8 04 00 00 00       	mov    $0x4,%eax
  80018f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800198:	89 f7                	mov    %esi,%edi
  80019a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80019c:	85 c0                	test   %eax,%eax
  80019e:	7e 28                	jle    8001c8 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ab:	00 
  8001ac:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  8001b3:	00 
  8001b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bb:	00 
  8001bc:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  8001c3:	e8 c9 01 00 00       	call   800391 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c8:	83 c4 2c             	add    $0x2c,%esp
  8001cb:	5b                   	pop    %ebx
  8001cc:	5e                   	pop    %esi
  8001cd:	5f                   	pop    %edi
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    

008001d0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ea:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ef:	85 c0                	test   %eax,%eax
  8001f1:	7e 28                	jle    80021b <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fe:	00 
  8001ff:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  800206:	00 
  800207:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020e:	00 
  80020f:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800216:	e8 76 01 00 00       	call   800391 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021b:	83 c4 2c             	add    $0x2c,%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	b8 06 00 00 00       	mov    $0x6,%eax
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	8b 55 08             	mov    0x8(%ebp),%edx
  80023c:	89 df                	mov    %ebx,%edi
  80023e:	89 de                	mov    %ebx,%esi
  800240:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800242:	85 c0                	test   %eax,%eax
  800244:	7e 28                	jle    80026e <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800246:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800251:	00 
  800252:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  800259:	00 
  80025a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800261:	00 
  800262:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800269:	e8 23 01 00 00       	call   800391 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026e:	83 c4 2c             	add    $0x2c,%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	57                   	push   %edi
  80027a:	56                   	push   %esi
  80027b:	53                   	push   %ebx
  80027c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800284:	b8 08 00 00 00       	mov    $0x8,%eax
  800289:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028c:	8b 55 08             	mov    0x8(%ebp),%edx
  80028f:	89 df                	mov    %ebx,%edi
  800291:	89 de                	mov    %ebx,%esi
  800293:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800295:	85 c0                	test   %eax,%eax
  800297:	7e 28                	jle    8002c1 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800299:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a4:	00 
  8002a5:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  8002ac:	00 
  8002ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b4:	00 
  8002b5:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  8002bc:	e8 d0 00 00 00       	call   800391 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c1:	83 c4 2c             	add    $0x2c,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d7:	b8 09 00 00 00       	mov    $0x9,%eax
  8002dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002df:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e2:	89 df                	mov    %ebx,%edi
  8002e4:	89 de                	mov    %ebx,%esi
  8002e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	7e 28                	jle    800314 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f7:	00 
  8002f8:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  8002ff:	00 
  800300:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  80030f:	e8 7d 00 00 00       	call   800391 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800314:	83 c4 2c             	add    $0x2c,%esp
  800317:	5b                   	pop    %ebx
  800318:	5e                   	pop    %esi
  800319:	5f                   	pop    %edi
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800322:	be 00 00 00 00       	mov    $0x0,%esi
  800327:	b8 0b 00 00 00       	mov    $0xb,%eax
  80032c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800335:	8b 7d 14             	mov    0x14(%ebp),%edi
  800338:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800348:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800352:	8b 55 08             	mov    0x8(%ebp),%edx
  800355:	89 cb                	mov    %ecx,%ebx
  800357:	89 cf                	mov    %ecx,%edi
  800359:	89 ce                	mov    %ecx,%esi
  80035b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80035d:	85 c0                	test   %eax,%eax
  80035f:	7e 28                	jle    800389 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800361:	89 44 24 10          	mov    %eax,0x10(%esp)
  800365:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80036c:	00 
  80036d:	c7 44 24 08 aa 15 80 	movl   $0x8015aa,0x8(%esp)
  800374:	00 
  800375:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037c:	00 
  80037d:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800384:	e8 08 00 00 00       	call   800391 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800389:	83 c4 2c             	add    $0x2c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800399:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80039c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003a2:	e8 97 fd ff ff       	call   80013e <sys_getenvid>
  8003a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003aa:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	c7 04 24 d8 15 80 00 	movl   $0x8015d8,(%esp)
  8003c4:	e8 c1 00 00 00       	call   80048a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d0:	89 04 24             	mov    %eax,(%esp)
  8003d3:	e8 51 00 00 00       	call   800429 <vcprintf>
	cprintf("\n");
  8003d8:	c7 04 24 fc 15 80 00 	movl   $0x8015fc,(%esp)
  8003df:	e8 a6 00 00 00       	call   80048a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e4:	cc                   	int3   
  8003e5:	eb fd                	jmp    8003e4 <_panic+0x53>

008003e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	53                   	push   %ebx
  8003eb:	83 ec 14             	sub    $0x14,%esp
  8003ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f1:	8b 13                	mov    (%ebx),%edx
  8003f3:	8d 42 01             	lea    0x1(%edx),%eax
  8003f6:	89 03                	mov    %eax,(%ebx)
  8003f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003fb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800404:	75 19                	jne    80041f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800406:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80040d:	00 
  80040e:	8d 43 08             	lea    0x8(%ebx),%eax
  800411:	89 04 24             	mov    %eax,(%esp)
  800414:	e8 96 fc ff ff       	call   8000af <sys_cputs>
		b->idx = 0;
  800419:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800423:	83 c4 14             	add    $0x14,%esp
  800426:	5b                   	pop    %ebx
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800432:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800439:	00 00 00 
	b.cnt = 0;
  80043c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800443:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800446:	8b 45 0c             	mov    0xc(%ebp),%eax
  800449:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	89 44 24 08          	mov    %eax,0x8(%esp)
  800454:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80045a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045e:	c7 04 24 e7 03 80 00 	movl   $0x8003e7,(%esp)
  800465:	e8 b5 02 00 00       	call   80071f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80046a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800470:	89 44 24 04          	mov    %eax,0x4(%esp)
  800474:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80047a:	89 04 24             	mov    %eax,(%esp)
  80047d:	e8 2d fc ff ff       	call   8000af <sys_cputs>

	return b.cnt;
}
  800482:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800490:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800493:	89 44 24 04          	mov    %eax,0x4(%esp)
  800497:	8b 45 08             	mov    0x8(%ebp),%eax
  80049a:	89 04 24             	mov    %eax,(%esp)
  80049d:	e8 87 ff ff ff       	call   800429 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    
  8004a4:	66 90                	xchg   %ax,%ax
  8004a6:	66 90                	xchg   %ax,%ax
  8004a8:	66 90                	xchg   %ax,%ax
  8004aa:	66 90                	xchg   %ax,%ax
  8004ac:	66 90                	xchg   %ax,%ax
  8004ae:	66 90                	xchg   %ax,%ax

008004b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	57                   	push   %edi
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 3c             	sub    $0x3c,%esp
  8004b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bc:	89 d7                	mov    %edx,%edi
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	89 c3                	mov    %eax,%ebx
  8004c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004dd:	39 d9                	cmp    %ebx,%ecx
  8004df:	72 05                	jb     8004e6 <printnum+0x36>
  8004e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004e4:	77 69                	ja     80054f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004ed:	83 ee 01             	sub    $0x1,%esi
  8004f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800500:	89 c3                	mov    %eax,%ebx
  800502:	89 d6                	mov    %edx,%esi
  800504:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800507:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80050e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800512:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800515:	89 04 24             	mov    %eax,(%esp)
  800518:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	e8 ec 0d 00 00       	call   801310 <__udivdi3>
  800524:	89 d9                	mov    %ebx,%ecx
  800526:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80052a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	89 54 24 04          	mov    %edx,0x4(%esp)
  800535:	89 fa                	mov    %edi,%edx
  800537:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053a:	e8 71 ff ff ff       	call   8004b0 <printnum>
  80053f:	eb 1b                	jmp    80055c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800541:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800545:	8b 45 18             	mov    0x18(%ebp),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	ff d3                	call   *%ebx
  80054d:	eb 03                	jmp    800552 <printnum+0xa2>
  80054f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800552:	83 ee 01             	sub    $0x1,%esi
  800555:	85 f6                	test   %esi,%esi
  800557:	7f e8                	jg     800541 <printnum+0x91>
  800559:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80055c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800560:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800564:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800567:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80056a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80056e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800572:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800575:	89 04 24             	mov    %eax,(%esp)
  800578:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	e8 bc 0e 00 00       	call   801440 <__umoddi3>
  800584:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800588:	0f be 80 fe 15 80 00 	movsbl 0x8015fe(%eax),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800595:	ff d0                	call   *%eax
}
  800597:	83 c4 3c             	add    $0x3c,%esp
  80059a:	5b                   	pop    %ebx
  80059b:	5e                   	pop    %esi
  80059c:	5f                   	pop    %edi
  80059d:	5d                   	pop    %ebp
  80059e:	c3                   	ret    

0080059f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80059f:	55                   	push   %ebp
  8005a0:	89 e5                	mov    %esp,%ebp
  8005a2:	57                   	push   %edi
  8005a3:	56                   	push   %esi
  8005a4:	53                   	push   %ebx
  8005a5:	83 ec 3c             	sub    $0x3c,%esp
  8005a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005ab:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ae:	89 cf                	mov    %ecx,%edi
  8005b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b9:	89 c3                	mov    %eax,%ebx
  8005bb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005be:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005cc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005cf:	39 d9                	cmp    %ebx,%ecx
  8005d1:	72 13                	jb     8005e6 <cprintnum+0x47>
  8005d3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8005d6:	76 0e                	jbe    8005e6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8005d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005db:	0b 45 18             	or     0x18(%ebp),%eax
  8005de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e4:	eb 6a                	jmp    800650 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8005e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005ed:	83 ee 01             	sub    $0x1,%esi
  8005f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800600:	89 c3                	mov    %eax,%ebx
  800602:	89 d6                	mov    %edx,%esi
  800604:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800607:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80060a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80060e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	89 04 24             	mov    %eax,(%esp)
  800618:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80061b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061f:	e8 ec 0c 00 00       	call   801310 <__udivdi3>
  800624:	89 d9                	mov    %ebx,%ecx
  800626:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80062a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	89 54 24 04          	mov    %edx,0x4(%esp)
  800635:	89 f9                	mov    %edi,%ecx
  800637:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80063a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80063d:	e8 5d ff ff ff       	call   80059f <cprintnum>
  800642:	eb 16                	jmp    80065a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800644:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80064b:	89 04 24             	mov    %eax,(%esp)
  80064e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800650:	83 ee 01             	sub    $0x1,%esi
  800653:	85 f6                	test   %esi,%esi
  800655:	7f ed                	jg     800644 <cprintnum+0xa5>
  800657:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80065a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800662:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800665:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800668:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800670:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800673:	89 04 24             	mov    %eax,(%esp)
  800676:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067d:	e8 be 0d 00 00       	call   801440 <__umoddi3>
  800682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800686:	0f be 80 fe 15 80 00 	movsbl 0x8015fe(%eax),%eax
  80068d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800696:	ff d0                	call   *%eax
}
  800698:	83 c4 3c             	add    $0x3c,%esp
  80069b:	5b                   	pop    %ebx
  80069c:	5e                   	pop    %esi
  80069d:	5f                   	pop    %edi
  80069e:	5d                   	pop    %ebp
  80069f:	c3                   	ret    

008006a0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006a3:	83 fa 01             	cmp    $0x1,%edx
  8006a6:	7e 0e                	jle    8006b6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006ad:	89 08                	mov    %ecx,(%eax)
  8006af:	8b 02                	mov    (%edx),%eax
  8006b1:	8b 52 04             	mov    0x4(%edx),%edx
  8006b4:	eb 22                	jmp    8006d8 <getuint+0x38>
	else if (lflag)
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	74 10                	je     8006ca <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006bf:	89 08                	mov    %ecx,(%eax)
  8006c1:	8b 02                	mov    (%edx),%eax
  8006c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c8:	eb 0e                	jmp    8006d8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006cf:	89 08                	mov    %ecx,(%eax)
  8006d1:	8b 02                	mov    (%edx),%eax
  8006d3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006e0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006e4:	8b 10                	mov    (%eax),%edx
  8006e6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006e9:	73 0a                	jae    8006f5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006eb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ee:	89 08                	mov    %ecx,(%eax)
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	88 02                	mov    %al,(%edx)
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800700:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800704:	8b 45 10             	mov    0x10(%ebp),%eax
  800707:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	89 04 24             	mov    %eax,(%esp)
  800718:	e8 02 00 00 00       	call   80071f <vprintfmt>
	va_end(ap);
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	57                   	push   %edi
  800723:	56                   	push   %esi
  800724:	53                   	push   %ebx
  800725:	83 ec 3c             	sub    $0x3c,%esp
  800728:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80072b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80072e:	eb 14                	jmp    800744 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800730:	85 c0                	test   %eax,%eax
  800732:	0f 84 b3 03 00 00    	je     800aeb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800738:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800742:	89 f3                	mov    %esi,%ebx
  800744:	8d 73 01             	lea    0x1(%ebx),%esi
  800747:	0f b6 03             	movzbl (%ebx),%eax
  80074a:	83 f8 25             	cmp    $0x25,%eax
  80074d:	75 e1                	jne    800730 <vprintfmt+0x11>
  80074f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800753:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80075a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800761:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800768:	ba 00 00 00 00       	mov    $0x0,%edx
  80076d:	eb 1d                	jmp    80078c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800771:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800775:	eb 15                	jmp    80078c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800779:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80077d:	eb 0d                	jmp    80078c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80077f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800782:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800785:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80078f:	0f b6 0e             	movzbl (%esi),%ecx
  800792:	0f b6 c1             	movzbl %cl,%eax
  800795:	83 e9 23             	sub    $0x23,%ecx
  800798:	80 f9 55             	cmp    $0x55,%cl
  80079b:	0f 87 2a 03 00 00    	ja     800acb <vprintfmt+0x3ac>
  8007a1:	0f b6 c9             	movzbl %cl,%ecx
  8007a4:	ff 24 8d c0 16 80 00 	jmp    *0x8016c0(,%ecx,4)
  8007ab:	89 de                	mov    %ebx,%esi
  8007ad:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007b2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8007b5:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8007b9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007bc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8007bf:	83 fb 09             	cmp    $0x9,%ebx
  8007c2:	77 36                	ja     8007fa <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007c4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007c7:	eb e9                	jmp    8007b2 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 48 04             	lea    0x4(%eax),%ecx
  8007cf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007d2:	8b 00                	mov    (%eax),%eax
  8007d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007d9:	eb 22                	jmp    8007fd <vprintfmt+0xde>
  8007db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007de:	85 c9                	test   %ecx,%ecx
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e5:	0f 49 c1             	cmovns %ecx,%eax
  8007e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007eb:	89 de                	mov    %ebx,%esi
  8007ed:	eb 9d                	jmp    80078c <vprintfmt+0x6d>
  8007ef:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007f1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8007f8:	eb 92                	jmp    80078c <vprintfmt+0x6d>
  8007fa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8007fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800801:	79 89                	jns    80078c <vprintfmt+0x6d>
  800803:	e9 77 ff ff ff       	jmp    80077f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800808:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80080d:	e9 7a ff ff ff       	jmp    80078c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)
  80081b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	89 04 24             	mov    %eax,(%esp)
  800824:	ff 55 08             	call   *0x8(%ebp)
			break;
  800827:	e9 18 ff ff ff       	jmp    800744 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8d 50 04             	lea    0x4(%eax),%edx
  800832:	89 55 14             	mov    %edx,0x14(%ebp)
  800835:	8b 00                	mov    (%eax),%eax
  800837:	99                   	cltd   
  800838:	31 d0                	xor    %edx,%eax
  80083a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80083c:	83 f8 09             	cmp    $0x9,%eax
  80083f:	7f 0b                	jg     80084c <vprintfmt+0x12d>
  800841:	8b 14 85 80 19 80 00 	mov    0x801980(,%eax,4),%edx
  800848:	85 d2                	test   %edx,%edx
  80084a:	75 20                	jne    80086c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80084c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800850:	c7 44 24 08 16 16 80 	movl   $0x801616,0x8(%esp)
  800857:	00 
  800858:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	e8 90 fe ff ff       	call   8006f7 <printfmt>
  800867:	e9 d8 fe ff ff       	jmp    800744 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80086c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800870:	c7 44 24 08 1f 16 80 	movl   $0x80161f,0x8(%esp)
  800877:	00 
  800878:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	89 04 24             	mov    %eax,(%esp)
  800882:	e8 70 fe ff ff       	call   8006f7 <printfmt>
  800887:	e9 b8 fe ff ff       	jmp    800744 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80088f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800892:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	8d 50 04             	lea    0x4(%eax),%edx
  80089b:	89 55 14             	mov    %edx,0x14(%ebp)
  80089e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008a0:	85 f6                	test   %esi,%esi
  8008a2:	b8 0f 16 80 00       	mov    $0x80160f,%eax
  8008a7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8008aa:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8008ae:	0f 84 97 00 00 00    	je     80094b <vprintfmt+0x22c>
  8008b4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008b8:	0f 8e 9b 00 00 00    	jle    800959 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008c2:	89 34 24             	mov    %esi,(%esp)
  8008c5:	e8 ce 06 00 00       	call   800f98 <strnlen>
  8008ca:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008cd:	29 c2                	sub    %eax,%edx
  8008cf:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8008d2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008d9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008df:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008e2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e4:	eb 0f                	jmp    8008f5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8008e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008ed:	89 04 24             	mov    %eax,(%esp)
  8008f0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f2:	83 eb 01             	sub    $0x1,%ebx
  8008f5:	85 db                	test   %ebx,%ebx
  8008f7:	7f ed                	jg     8008e6 <vprintfmt+0x1c7>
  8008f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008fc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008ff:	85 d2                	test   %edx,%edx
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
  800906:	0f 49 c2             	cmovns %edx,%eax
  800909:	29 c2                	sub    %eax,%edx
  80090b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80090e:	89 d7                	mov    %edx,%edi
  800910:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800913:	eb 50                	jmp    800965 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800915:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800919:	74 1e                	je     800939 <vprintfmt+0x21a>
  80091b:	0f be d2             	movsbl %dl,%edx
  80091e:	83 ea 20             	sub    $0x20,%edx
  800921:	83 fa 5e             	cmp    $0x5e,%edx
  800924:	76 13                	jbe    800939 <vprintfmt+0x21a>
					putch('?', putdat);
  800926:	8b 45 0c             	mov    0xc(%ebp),%eax
  800929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800934:	ff 55 08             	call   *0x8(%ebp)
  800937:	eb 0d                	jmp    800946 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800946:	83 ef 01             	sub    $0x1,%edi
  800949:	eb 1a                	jmp    800965 <vprintfmt+0x246>
  80094b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80094e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800951:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800954:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800957:	eb 0c                	jmp    800965 <vprintfmt+0x246>
  800959:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80095c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80095f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800962:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800965:	83 c6 01             	add    $0x1,%esi
  800968:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80096c:	0f be c2             	movsbl %dl,%eax
  80096f:	85 c0                	test   %eax,%eax
  800971:	74 27                	je     80099a <vprintfmt+0x27b>
  800973:	85 db                	test   %ebx,%ebx
  800975:	78 9e                	js     800915 <vprintfmt+0x1f6>
  800977:	83 eb 01             	sub    $0x1,%ebx
  80097a:	79 99                	jns    800915 <vprintfmt+0x1f6>
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800981:	8b 75 08             	mov    0x8(%ebp),%esi
  800984:	89 c3                	mov    %eax,%ebx
  800986:	eb 1a                	jmp    8009a2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800988:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800993:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800995:	83 eb 01             	sub    $0x1,%ebx
  800998:	eb 08                	jmp    8009a2 <vprintfmt+0x283>
  80099a:	89 fb                	mov    %edi,%ebx
  80099c:	8b 75 08             	mov    0x8(%ebp),%esi
  80099f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009a2:	85 db                	test   %ebx,%ebx
  8009a4:	7f e2                	jg     800988 <vprintfmt+0x269>
  8009a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8009a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009ac:	e9 93 fd ff ff       	jmp    800744 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009b1:	83 fa 01             	cmp    $0x1,%edx
  8009b4:	7e 16                	jle    8009cc <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8009b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b9:	8d 50 08             	lea    0x8(%eax),%edx
  8009bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bf:	8b 50 04             	mov    0x4(%eax),%edx
  8009c2:	8b 00                	mov    (%eax),%eax
  8009c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009ca:	eb 32                	jmp    8009fe <vprintfmt+0x2df>
	else if (lflag)
  8009cc:	85 d2                	test   %edx,%edx
  8009ce:	74 18                	je     8009e8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8009d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d3:	8d 50 04             	lea    0x4(%eax),%edx
  8009d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d9:	8b 30                	mov    (%eax),%esi
  8009db:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009de:	89 f0                	mov    %esi,%eax
  8009e0:	c1 f8 1f             	sar    $0x1f,%eax
  8009e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009e6:	eb 16                	jmp    8009fe <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8009e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009eb:	8d 50 04             	lea    0x4(%eax),%edx
  8009ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f1:	8b 30                	mov    (%eax),%esi
  8009f3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009f6:	89 f0                	mov    %esi,%eax
  8009f8:	c1 f8 1f             	sar    $0x1f,%eax
  8009fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a01:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a04:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a0d:	0f 89 80 00 00 00    	jns    800a93 <vprintfmt+0x374>
				putch('-', putdat);
  800a13:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a17:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a1e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a21:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a27:	f7 d8                	neg    %eax
  800a29:	83 d2 00             	adc    $0x0,%edx
  800a2c:	f7 da                	neg    %edx
			}
			base = 10;
  800a2e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a33:	eb 5e                	jmp    800a93 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a35:	8d 45 14             	lea    0x14(%ebp),%eax
  800a38:	e8 63 fc ff ff       	call   8006a0 <getuint>
			base = 10;
  800a3d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a42:	eb 4f                	jmp    800a93 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800a44:	8d 45 14             	lea    0x14(%ebp),%eax
  800a47:	e8 54 fc ff ff       	call   8006a0 <getuint>
			base = 8 ;
  800a4c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800a51:	eb 40                	jmp    800a93 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800a53:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a57:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a5e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a61:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a65:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a6c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a72:	8d 50 04             	lea    0x4(%eax),%edx
  800a75:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a78:	8b 00                	mov    (%eax),%eax
  800a7a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a7f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a84:	eb 0d                	jmp    800a93 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a86:	8d 45 14             	lea    0x14(%ebp),%eax
  800a89:	e8 12 fc ff ff       	call   8006a0 <getuint>
			base = 16;
  800a8e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a93:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800a97:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a9b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a9e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800aa2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800aa6:	89 04 24             	mov    %eax,(%esp)
  800aa9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aad:	89 fa                	mov    %edi,%edx
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	e8 f9 f9 ff ff       	call   8004b0 <printnum>
			break;
  800ab7:	e9 88 fc ff ff       	jmp    800744 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800abc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ac0:	89 04 24             	mov    %eax,(%esp)
  800ac3:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ac6:	e9 79 fc ff ff       	jmp    800744 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800acb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800acf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ad6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	eb 03                	jmp    800ae0 <vprintfmt+0x3c1>
  800add:	83 eb 01             	sub    $0x1,%ebx
  800ae0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ae4:	75 f7                	jne    800add <vprintfmt+0x3be>
  800ae6:	e9 59 fc ff ff       	jmp    800744 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800aeb:	83 c4 3c             	add    $0x3c,%esp
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	83 ec 3c             	sub    $0x3c,%esp
  800afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  800aff:	8b 45 14             	mov    0x14(%ebp),%eax
  800b02:	8d 50 04             	lea    0x4(%eax),%edx
  800b05:	89 55 14             	mov    %edx,0x14(%ebp)
  800b08:	8b 00                	mov    (%eax),%eax
  800b0a:	c1 e0 08             	shl    $0x8,%eax
  800b0d:	0f b7 c0             	movzwl %ax,%eax
  800b10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800b13:	83 c8 25             	or     $0x25,%eax
  800b16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800b19:	eb 1a                	jmp    800b35 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	0f 84 a9 03 00 00    	je     800ecc <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800b23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b2a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b2d:	89 04 24             	mov    %eax,(%esp)
  800b30:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b33:	89 fb                	mov    %edi,%ebx
  800b35:	8d 7b 01             	lea    0x1(%ebx),%edi
  800b38:	0f b6 03             	movzbl (%ebx),%eax
  800b3b:	83 f8 25             	cmp    $0x25,%eax
  800b3e:	75 db                	jne    800b1b <cvprintfmt+0x28>
  800b40:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800b44:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800b4b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800b50:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	eb 18                	jmp    800b76 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b5e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800b60:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800b64:	eb 10                	jmp    800b76 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b66:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800b68:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800b6c:	eb 08                	jmp    800b76 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800b6e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800b71:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b76:	8d 5f 01             	lea    0x1(%edi),%ebx
  800b79:	0f b6 0f             	movzbl (%edi),%ecx
  800b7c:	0f b6 c1             	movzbl %cl,%eax
  800b7f:	83 e9 23             	sub    $0x23,%ecx
  800b82:	80 f9 55             	cmp    $0x55,%cl
  800b85:	0f 87 1f 03 00 00    	ja     800eaa <cvprintfmt+0x3b7>
  800b8b:	0f b6 c9             	movzbl %cl,%ecx
  800b8e:	ff 24 8d 18 18 80 00 	jmp    *0x801818(,%ecx,4)
  800b95:	89 df                	mov    %ebx,%edi
  800b97:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800b9c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  800b9f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800ba3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800ba6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800ba9:	83 f9 09             	cmp    $0x9,%ecx
  800bac:	77 33                	ja     800be1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800bae:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800bb1:	eb e9                	jmp    800b9c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800bb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb6:	8d 48 04             	lea    0x4(%eax),%ecx
  800bb9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bbc:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bbe:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800bc0:	eb 1f                	jmp    800be1 <cvprintfmt+0xee>
  800bc2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800bc5:	85 ff                	test   %edi,%edi
  800bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcc:	0f 49 c7             	cmovns %edi,%eax
  800bcf:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bd2:	89 df                	mov    %ebx,%edi
  800bd4:	eb a0                	jmp    800b76 <cvprintfmt+0x83>
  800bd6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800bd8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800bdf:	eb 95                	jmp    800b76 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800be1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800be5:	79 8f                	jns    800b76 <cvprintfmt+0x83>
  800be7:	eb 85                	jmp    800b6e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800be9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bec:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800bee:	66 90                	xchg   %ax,%ax
  800bf0:	eb 84                	jmp    800b76 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800bf2:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf5:	8d 50 04             	lea    0x4(%eax),%edx
  800bf8:	89 55 14             	mov    %edx,0x14(%ebp)
  800bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c02:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c05:	0b 10                	or     (%eax),%edx
  800c07:	89 14 24             	mov    %edx,(%esp)
  800c0a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c0d:	e9 23 ff ff ff       	jmp    800b35 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800c12:	8b 45 14             	mov    0x14(%ebp),%eax
  800c15:	8d 50 04             	lea    0x4(%eax),%edx
  800c18:	89 55 14             	mov    %edx,0x14(%ebp)
  800c1b:	8b 00                	mov    (%eax),%eax
  800c1d:	99                   	cltd   
  800c1e:	31 d0                	xor    %edx,%eax
  800c20:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800c22:	83 f8 09             	cmp    $0x9,%eax
  800c25:	7f 0b                	jg     800c32 <cvprintfmt+0x13f>
  800c27:	8b 14 85 80 19 80 00 	mov    0x801980(,%eax,4),%edx
  800c2e:	85 d2                	test   %edx,%edx
  800c30:	75 23                	jne    800c55 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800c32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c36:	c7 44 24 08 16 16 80 	movl   $0x801616,0x8(%esp)
  800c3d:	00 
  800c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	89 04 24             	mov    %eax,(%esp)
  800c4b:	e8 a7 fa ff ff       	call   8006f7 <printfmt>
  800c50:	e9 e0 fe ff ff       	jmp    800b35 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800c55:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c59:	c7 44 24 08 1f 16 80 	movl   $0x80161f,0x8(%esp)
  800c60:	00 
  800c61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	89 04 24             	mov    %eax,(%esp)
  800c6e:	e8 84 fa ff ff       	call   8006f7 <printfmt>
  800c73:	e9 bd fe ff ff       	jmp    800b35 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c78:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800c7b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800c7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c81:	8d 48 04             	lea    0x4(%eax),%ecx
  800c84:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c87:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800c89:	85 ff                	test   %edi,%edi
  800c8b:	b8 0f 16 80 00       	mov    $0x80160f,%eax
  800c90:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800c93:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800c97:	74 61                	je     800cfa <cvprintfmt+0x207>
  800c99:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800c9d:	7e 5b                	jle    800cfa <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800c9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca3:	89 3c 24             	mov    %edi,(%esp)
  800ca6:	e8 ed 02 00 00       	call   800f98 <strnlen>
  800cab:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800cae:	29 c2                	sub    %eax,%edx
  800cb0:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800cb3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800cb7:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800cba:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800cbd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800cc0:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cc6:	89 d3                	mov    %edx,%ebx
  800cc8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800cca:	eb 0f                	jmp    800cdb <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd3:	89 3c 24             	mov    %edi,(%esp)
  800cd6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800cd8:	83 eb 01             	sub    $0x1,%ebx
  800cdb:	85 db                	test   %ebx,%ebx
  800cdd:	7f ed                	jg     800ccc <cvprintfmt+0x1d9>
  800cdf:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800ce2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ceb:	85 d2                	test   %edx,%edx
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf2:	0f 49 c2             	cmovns %edx,%eax
  800cf5:	29 c2                	sub    %eax,%edx
  800cf7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800cfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cfd:	83 c8 3f             	or     $0x3f,%eax
  800d00:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d03:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d06:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800d09:	eb 36                	jmp    800d41 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d0b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d0f:	74 1d                	je     800d2e <cvprintfmt+0x23b>
  800d11:	0f be d2             	movsbl %dl,%edx
  800d14:	83 ea 20             	sub    $0x20,%edx
  800d17:	83 fa 5e             	cmp    $0x5e,%edx
  800d1a:	76 12                	jbe    800d2e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d23:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d26:	89 04 24             	mov    %eax,(%esp)
  800d29:	ff 55 08             	call   *0x8(%ebp)
  800d2c:	eb 10                	jmp    800d3e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800d2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d31:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d35:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800d38:	89 04 24             	mov    %eax,(%esp)
  800d3b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d3e:	83 eb 01             	sub    $0x1,%ebx
  800d41:	83 c7 01             	add    $0x1,%edi
  800d44:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800d48:	0f be c2             	movsbl %dl,%eax
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	74 27                	je     800d76 <cvprintfmt+0x283>
  800d4f:	85 f6                	test   %esi,%esi
  800d51:	78 b8                	js     800d0b <cvprintfmt+0x218>
  800d53:	83 ee 01             	sub    $0x1,%esi
  800d56:	79 b3                	jns    800d0b <cvprintfmt+0x218>
  800d58:	89 d8                	mov    %ebx,%eax
  800d5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d60:	89 c3                	mov    %eax,%ebx
  800d62:	eb 18                	jmp    800d7c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800d64:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800d6f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800d71:	83 eb 01             	sub    $0x1,%ebx
  800d74:	eb 06                	jmp    800d7c <cvprintfmt+0x289>
  800d76:	8b 75 08             	mov    0x8(%ebp),%esi
  800d79:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d7c:	85 db                	test   %ebx,%ebx
  800d7e:	7f e4                	jg     800d64 <cvprintfmt+0x271>
  800d80:	89 75 08             	mov    %esi,0x8(%ebp)
  800d83:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800d86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d89:	e9 a7 fd ff ff       	jmp    800b35 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d8e:	83 fa 01             	cmp    $0x1,%edx
  800d91:	7e 10                	jle    800da3 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800d93:	8b 45 14             	mov    0x14(%ebp),%eax
  800d96:	8d 50 08             	lea    0x8(%eax),%edx
  800d99:	89 55 14             	mov    %edx,0x14(%ebp)
  800d9c:	8b 30                	mov    (%eax),%esi
  800d9e:	8b 78 04             	mov    0x4(%eax),%edi
  800da1:	eb 26                	jmp    800dc9 <cvprintfmt+0x2d6>
	else if (lflag)
  800da3:	85 d2                	test   %edx,%edx
  800da5:	74 12                	je     800db9 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800da7:	8b 45 14             	mov    0x14(%ebp),%eax
  800daa:	8d 50 04             	lea    0x4(%eax),%edx
  800dad:	89 55 14             	mov    %edx,0x14(%ebp)
  800db0:	8b 30                	mov    (%eax),%esi
  800db2:	89 f7                	mov    %esi,%edi
  800db4:	c1 ff 1f             	sar    $0x1f,%edi
  800db7:	eb 10                	jmp    800dc9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800db9:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbc:	8d 50 04             	lea    0x4(%eax),%edx
  800dbf:	89 55 14             	mov    %edx,0x14(%ebp)
  800dc2:	8b 30                	mov    (%eax),%esi
  800dc4:	89 f7                	mov    %esi,%edi
  800dc6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800dcd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800dd2:	85 ff                	test   %edi,%edi
  800dd4:	0f 89 8e 00 00 00    	jns    800e68 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800de4:	83 c8 2d             	or     $0x2d,%eax
  800de7:	89 04 24             	mov    %eax,(%esp)
  800dea:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ded:	89 f0                	mov    %esi,%eax
  800def:	89 fa                	mov    %edi,%edx
  800df1:	f7 d8                	neg    %eax
  800df3:	83 d2 00             	adc    $0x0,%edx
  800df6:	f7 da                	neg    %edx
			}
			base = 10;
  800df8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800dfd:	eb 69                	jmp    800e68 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800dff:	8d 45 14             	lea    0x14(%ebp),%eax
  800e02:	e8 99 f8 ff ff       	call   8006a0 <getuint>
			base = 10;
  800e07:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800e0c:	eb 5a                	jmp    800e68 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800e0e:	8d 45 14             	lea    0x14(%ebp),%eax
  800e11:	e8 8a f8 ff ff       	call   8006a0 <getuint>
			base = 8 ;
  800e16:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800e1b:	eb 4b                	jmp    800e68 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e24:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800e27:	89 f0                	mov    %esi,%eax
  800e29:	83 c8 30             	or     $0x30,%eax
  800e2c:	89 04 24             	mov    %eax,(%esp)
  800e2f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800e32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e39:	89 f0                	mov    %esi,%eax
  800e3b:	83 c8 78             	or     $0x78,%eax
  800e3e:	89 04 24             	mov    %eax,(%esp)
  800e41:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e44:	8b 45 14             	mov    0x14(%ebp),%eax
  800e47:	8d 50 04             	lea    0x4(%eax),%edx
  800e4a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800e4d:	8b 00                	mov    (%eax),%eax
  800e4f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e54:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800e59:	eb 0d                	jmp    800e68 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e5e:	e8 3d f8 ff ff       	call   8006a0 <getuint>
			base = 16;
  800e63:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800e68:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800e6c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e70:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800e73:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e77:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e7b:	89 04 24             	mov    %eax,(%esp)
  800e7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e8b:	e8 0f f7 ff ff       	call   80059f <cprintnum>
			break;
  800e90:	e9 a0 fc ff ff       	jmp    800b35 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800e95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e98:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e9c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800e9f:	89 04 24             	mov    %eax,(%esp)
  800ea2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ea5:	e9 8b fc ff ff       	jmp    800b35 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ead:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800eb4:	89 04 24             	mov    %eax,(%esp)
  800eb7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800eba:	89 fb                	mov    %edi,%ebx
  800ebc:	eb 03                	jmp    800ec1 <cvprintfmt+0x3ce>
  800ebe:	83 eb 01             	sub    $0x1,%ebx
  800ec1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ec5:	75 f7                	jne    800ebe <cvprintfmt+0x3cb>
  800ec7:	e9 69 fc ff ff       	jmp    800b35 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800ecc:	83 c4 3c             	add    $0x3c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800eda:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800edd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef2:	89 04 24             	mov    %eax,(%esp)
  800ef5:	e8 f9 fb ff ff       	call   800af3 <cvprintfmt>
	va_end(ap);
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 28             	sub    $0x28,%esp
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
  800f05:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f08:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f0b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f0f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	74 30                	je     800f4d <vsnprintf+0x51>
  800f1d:	85 d2                	test   %edx,%edx
  800f1f:	7e 2c                	jle    800f4d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f21:	8b 45 14             	mov    0x14(%ebp),%eax
  800f24:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f28:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f2f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f36:	c7 04 24 da 06 80 00 	movl   $0x8006da,(%esp)
  800f3d:	e8 dd f7 ff ff       	call   80071f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f45:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4b:	eb 05                	jmp    800f52 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f5a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f61:	8b 45 10             	mov    0x10(%ebp),%eax
  800f64:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	89 04 24             	mov    %eax,(%esp)
  800f75:	e8 82 ff ff ff       	call   800efc <vsnprintf>
	va_end(ap);

	return rc;
}
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f86:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8b:	eb 03                	jmp    800f90 <strlen+0x10>
		n++;
  800f8d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f90:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f94:	75 f7                	jne    800f8d <strlen+0xd>
		n++;
	return n;
}
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa6:	eb 03                	jmp    800fab <strnlen+0x13>
		n++;
  800fa8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fab:	39 d0                	cmp    %edx,%eax
  800fad:	74 06                	je     800fb5 <strnlen+0x1d>
  800faf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fb3:	75 f3                	jne    800fa8 <strnlen+0x10>
		n++;
	return n;
}
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	53                   	push   %ebx
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fc1:	89 c2                	mov    %eax,%edx
  800fc3:	83 c2 01             	add    $0x1,%edx
  800fc6:	83 c1 01             	add    $0x1,%ecx
  800fc9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800fcd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800fd0:	84 db                	test   %bl,%bl
  800fd2:	75 ef                	jne    800fc3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	53                   	push   %ebx
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fe1:	89 1c 24             	mov    %ebx,(%esp)
  800fe4:	e8 97 ff ff ff       	call   800f80 <strlen>
	strcpy(dst + len, src);
  800fe9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fec:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ff0:	01 d8                	add    %ebx,%eax
  800ff2:	89 04 24             	mov    %eax,(%esp)
  800ff5:	e8 bd ff ff ff       	call   800fb7 <strcpy>
	return dst;
}
  800ffa:	89 d8                	mov    %ebx,%eax
  800ffc:	83 c4 08             	add    $0x8,%esp
  800fff:	5b                   	pop    %ebx
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	8b 75 08             	mov    0x8(%ebp),%esi
  80100a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100d:	89 f3                	mov    %esi,%ebx
  80100f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801012:	89 f2                	mov    %esi,%edx
  801014:	eb 0f                	jmp    801025 <strncpy+0x23>
		*dst++ = *src;
  801016:	83 c2 01             	add    $0x1,%edx
  801019:	0f b6 01             	movzbl (%ecx),%eax
  80101c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80101f:	80 39 01             	cmpb   $0x1,(%ecx)
  801022:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801025:	39 da                	cmp    %ebx,%edx
  801027:	75 ed                	jne    801016 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801029:	89 f0                	mov    %esi,%eax
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	8b 75 08             	mov    0x8(%ebp),%esi
  801037:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80103d:	89 f0                	mov    %esi,%eax
  80103f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801043:	85 c9                	test   %ecx,%ecx
  801045:	75 0b                	jne    801052 <strlcpy+0x23>
  801047:	eb 1d                	jmp    801066 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801049:	83 c0 01             	add    $0x1,%eax
  80104c:	83 c2 01             	add    $0x1,%edx
  80104f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801052:	39 d8                	cmp    %ebx,%eax
  801054:	74 0b                	je     801061 <strlcpy+0x32>
  801056:	0f b6 0a             	movzbl (%edx),%ecx
  801059:	84 c9                	test   %cl,%cl
  80105b:	75 ec                	jne    801049 <strlcpy+0x1a>
  80105d:	89 c2                	mov    %eax,%edx
  80105f:	eb 02                	jmp    801063 <strlcpy+0x34>
  801061:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801063:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801066:	29 f0                	sub    %esi,%eax
}
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801072:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801075:	eb 06                	jmp    80107d <strcmp+0x11>
		p++, q++;
  801077:	83 c1 01             	add    $0x1,%ecx
  80107a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80107d:	0f b6 01             	movzbl (%ecx),%eax
  801080:	84 c0                	test   %al,%al
  801082:	74 04                	je     801088 <strcmp+0x1c>
  801084:	3a 02                	cmp    (%edx),%al
  801086:	74 ef                	je     801077 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801088:	0f b6 c0             	movzbl %al,%eax
  80108b:	0f b6 12             	movzbl (%edx),%edx
  80108e:	29 d0                	sub    %edx,%eax
}
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	53                   	push   %ebx
  801096:	8b 45 08             	mov    0x8(%ebp),%eax
  801099:	8b 55 0c             	mov    0xc(%ebp),%edx
  80109c:	89 c3                	mov    %eax,%ebx
  80109e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8010a1:	eb 06                	jmp    8010a9 <strncmp+0x17>
		n--, p++, q++;
  8010a3:	83 c0 01             	add    $0x1,%eax
  8010a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8010a9:	39 d8                	cmp    %ebx,%eax
  8010ab:	74 15                	je     8010c2 <strncmp+0x30>
  8010ad:	0f b6 08             	movzbl (%eax),%ecx
  8010b0:	84 c9                	test   %cl,%cl
  8010b2:	74 04                	je     8010b8 <strncmp+0x26>
  8010b4:	3a 0a                	cmp    (%edx),%cl
  8010b6:	74 eb                	je     8010a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010b8:	0f b6 00             	movzbl (%eax),%eax
  8010bb:	0f b6 12             	movzbl (%edx),%edx
  8010be:	29 d0                	sub    %edx,%eax
  8010c0:	eb 05                	jmp    8010c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010c7:	5b                   	pop    %ebx
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8010d4:	eb 07                	jmp    8010dd <strchr+0x13>
		if (*s == c)
  8010d6:	38 ca                	cmp    %cl,%dl
  8010d8:	74 0f                	je     8010e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010da:	83 c0 01             	add    $0x1,%eax
  8010dd:	0f b6 10             	movzbl (%eax),%edx
  8010e0:	84 d2                	test   %dl,%dl
  8010e2:	75 f2                	jne    8010d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8010e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8010f5:	eb 07                	jmp    8010fe <strfind+0x13>
		if (*s == c)
  8010f7:	38 ca                	cmp    %cl,%dl
  8010f9:	74 0a                	je     801105 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010fb:	83 c0 01             	add    $0x1,%eax
  8010fe:	0f b6 10             	movzbl (%eax),%edx
  801101:	84 d2                	test   %dl,%dl
  801103:	75 f2                	jne    8010f7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801110:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801113:	85 c9                	test   %ecx,%ecx
  801115:	74 36                	je     80114d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801117:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80111d:	75 28                	jne    801147 <memset+0x40>
  80111f:	f6 c1 03             	test   $0x3,%cl
  801122:	75 23                	jne    801147 <memset+0x40>
		c &= 0xFF;
  801124:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801128:	89 d3                	mov    %edx,%ebx
  80112a:	c1 e3 08             	shl    $0x8,%ebx
  80112d:	89 d6                	mov    %edx,%esi
  80112f:	c1 e6 18             	shl    $0x18,%esi
  801132:	89 d0                	mov    %edx,%eax
  801134:	c1 e0 10             	shl    $0x10,%eax
  801137:	09 f0                	or     %esi,%eax
  801139:	09 c2                	or     %eax,%edx
  80113b:	89 d0                	mov    %edx,%eax
  80113d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80113f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801142:	fc                   	cld    
  801143:	f3 ab                	rep stos %eax,%es:(%edi)
  801145:	eb 06                	jmp    80114d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801147:	8b 45 0c             	mov    0xc(%ebp),%eax
  80114a:	fc                   	cld    
  80114b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80114d:	89 f8                	mov    %edi,%eax
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5f                   	pop    %edi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
  80115c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80115f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801162:	39 c6                	cmp    %eax,%esi
  801164:	73 35                	jae    80119b <memmove+0x47>
  801166:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801169:	39 d0                	cmp    %edx,%eax
  80116b:	73 2e                	jae    80119b <memmove+0x47>
		s += n;
		d += n;
  80116d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801170:	89 d6                	mov    %edx,%esi
  801172:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801174:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80117a:	75 13                	jne    80118f <memmove+0x3b>
  80117c:	f6 c1 03             	test   $0x3,%cl
  80117f:	75 0e                	jne    80118f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801181:	83 ef 04             	sub    $0x4,%edi
  801184:	8d 72 fc             	lea    -0x4(%edx),%esi
  801187:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80118a:	fd                   	std    
  80118b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80118d:	eb 09                	jmp    801198 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80118f:	83 ef 01             	sub    $0x1,%edi
  801192:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801195:	fd                   	std    
  801196:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801198:	fc                   	cld    
  801199:	eb 1d                	jmp    8011b8 <memmove+0x64>
  80119b:	89 f2                	mov    %esi,%edx
  80119d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80119f:	f6 c2 03             	test   $0x3,%dl
  8011a2:	75 0f                	jne    8011b3 <memmove+0x5f>
  8011a4:	f6 c1 03             	test   $0x3,%cl
  8011a7:	75 0a                	jne    8011b3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8011a9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8011ac:	89 c7                	mov    %eax,%edi
  8011ae:	fc                   	cld    
  8011af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011b1:	eb 05                	jmp    8011b8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011b3:	89 c7                	mov    %eax,%edi
  8011b5:	fc                   	cld    
  8011b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8011b8:	5e                   	pop    %esi
  8011b9:	5f                   	pop    %edi
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d3:	89 04 24             	mov    %eax,(%esp)
  8011d6:	e8 79 ff ff ff       	call   801154 <memmove>
}
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	56                   	push   %esi
  8011e1:	53                   	push   %ebx
  8011e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e8:	89 d6                	mov    %edx,%esi
  8011ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011ed:	eb 1a                	jmp    801209 <memcmp+0x2c>
		if (*s1 != *s2)
  8011ef:	0f b6 02             	movzbl (%edx),%eax
  8011f2:	0f b6 19             	movzbl (%ecx),%ebx
  8011f5:	38 d8                	cmp    %bl,%al
  8011f7:	74 0a                	je     801203 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8011f9:	0f b6 c0             	movzbl %al,%eax
  8011fc:	0f b6 db             	movzbl %bl,%ebx
  8011ff:	29 d8                	sub    %ebx,%eax
  801201:	eb 0f                	jmp    801212 <memcmp+0x35>
		s1++, s2++;
  801203:	83 c2 01             	add    $0x1,%edx
  801206:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801209:	39 f2                	cmp    %esi,%edx
  80120b:	75 e2                	jne    8011ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80120d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801212:	5b                   	pop    %ebx
  801213:	5e                   	pop    %esi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	8b 45 08             	mov    0x8(%ebp),%eax
  80121c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80121f:	89 c2                	mov    %eax,%edx
  801221:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801224:	eb 07                	jmp    80122d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801226:	38 08                	cmp    %cl,(%eax)
  801228:	74 07                	je     801231 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80122a:	83 c0 01             	add    $0x1,%eax
  80122d:	39 d0                	cmp    %edx,%eax
  80122f:	72 f5                	jb     801226 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	8b 55 08             	mov    0x8(%ebp),%edx
  80123c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80123f:	eb 03                	jmp    801244 <strtol+0x11>
		s++;
  801241:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801244:	0f b6 0a             	movzbl (%edx),%ecx
  801247:	80 f9 09             	cmp    $0x9,%cl
  80124a:	74 f5                	je     801241 <strtol+0xe>
  80124c:	80 f9 20             	cmp    $0x20,%cl
  80124f:	74 f0                	je     801241 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801251:	80 f9 2b             	cmp    $0x2b,%cl
  801254:	75 0a                	jne    801260 <strtol+0x2d>
		s++;
  801256:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801259:	bf 00 00 00 00       	mov    $0x0,%edi
  80125e:	eb 11                	jmp    801271 <strtol+0x3e>
  801260:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801265:	80 f9 2d             	cmp    $0x2d,%cl
  801268:	75 07                	jne    801271 <strtol+0x3e>
		s++, neg = 1;
  80126a:	8d 52 01             	lea    0x1(%edx),%edx
  80126d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801271:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801276:	75 15                	jne    80128d <strtol+0x5a>
  801278:	80 3a 30             	cmpb   $0x30,(%edx)
  80127b:	75 10                	jne    80128d <strtol+0x5a>
  80127d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801281:	75 0a                	jne    80128d <strtol+0x5a>
		s += 2, base = 16;
  801283:	83 c2 02             	add    $0x2,%edx
  801286:	b8 10 00 00 00       	mov    $0x10,%eax
  80128b:	eb 10                	jmp    80129d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80128d:	85 c0                	test   %eax,%eax
  80128f:	75 0c                	jne    80129d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801291:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801293:	80 3a 30             	cmpb   $0x30,(%edx)
  801296:	75 05                	jne    80129d <strtol+0x6a>
		s++, base = 8;
  801298:	83 c2 01             	add    $0x1,%edx
  80129b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80129d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8012a5:	0f b6 0a             	movzbl (%edx),%ecx
  8012a8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8012ab:	89 f0                	mov    %esi,%eax
  8012ad:	3c 09                	cmp    $0x9,%al
  8012af:	77 08                	ja     8012b9 <strtol+0x86>
			dig = *s - '0';
  8012b1:	0f be c9             	movsbl %cl,%ecx
  8012b4:	83 e9 30             	sub    $0x30,%ecx
  8012b7:	eb 20                	jmp    8012d9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8012b9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8012bc:	89 f0                	mov    %esi,%eax
  8012be:	3c 19                	cmp    $0x19,%al
  8012c0:	77 08                	ja     8012ca <strtol+0x97>
			dig = *s - 'a' + 10;
  8012c2:	0f be c9             	movsbl %cl,%ecx
  8012c5:	83 e9 57             	sub    $0x57,%ecx
  8012c8:	eb 0f                	jmp    8012d9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8012ca:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8012cd:	89 f0                	mov    %esi,%eax
  8012cf:	3c 19                	cmp    $0x19,%al
  8012d1:	77 16                	ja     8012e9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8012d3:	0f be c9             	movsbl %cl,%ecx
  8012d6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012d9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8012dc:	7d 0f                	jge    8012ed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8012de:	83 c2 01             	add    $0x1,%edx
  8012e1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8012e5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8012e7:	eb bc                	jmp    8012a5 <strtol+0x72>
  8012e9:	89 d8                	mov    %ebx,%eax
  8012eb:	eb 02                	jmp    8012ef <strtol+0xbc>
  8012ed:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8012ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012f3:	74 05                	je     8012fa <strtol+0xc7>
		*endptr = (char *) s;
  8012f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012f8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8012fa:	f7 d8                	neg    %eax
  8012fc:	85 ff                	test   %edi,%edi
  8012fe:	0f 44 c3             	cmove  %ebx,%eax
}
  801301:	5b                   	pop    %ebx
  801302:	5e                   	pop    %esi
  801303:	5f                   	pop    %edi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    
  801306:	66 90                	xchg   %ax,%ax
  801308:	66 90                	xchg   %ax,%ax
  80130a:	66 90                	xchg   %ax,%ax
  80130c:	66 90                	xchg   %ax,%ax
  80130e:	66 90                	xchg   %ax,%ax

00801310 <__udivdi3>:
  801310:	55                   	push   %ebp
  801311:	57                   	push   %edi
  801312:	56                   	push   %esi
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	8b 44 24 28          	mov    0x28(%esp),%eax
  80131a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80131e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801322:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801326:	85 c0                	test   %eax,%eax
  801328:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80132c:	89 ea                	mov    %ebp,%edx
  80132e:	89 0c 24             	mov    %ecx,(%esp)
  801331:	75 2d                	jne    801360 <__udivdi3+0x50>
  801333:	39 e9                	cmp    %ebp,%ecx
  801335:	77 61                	ja     801398 <__udivdi3+0x88>
  801337:	85 c9                	test   %ecx,%ecx
  801339:	89 ce                	mov    %ecx,%esi
  80133b:	75 0b                	jne    801348 <__udivdi3+0x38>
  80133d:	b8 01 00 00 00       	mov    $0x1,%eax
  801342:	31 d2                	xor    %edx,%edx
  801344:	f7 f1                	div    %ecx
  801346:	89 c6                	mov    %eax,%esi
  801348:	31 d2                	xor    %edx,%edx
  80134a:	89 e8                	mov    %ebp,%eax
  80134c:	f7 f6                	div    %esi
  80134e:	89 c5                	mov    %eax,%ebp
  801350:	89 f8                	mov    %edi,%eax
  801352:	f7 f6                	div    %esi
  801354:	89 ea                	mov    %ebp,%edx
  801356:	83 c4 0c             	add    $0xc,%esp
  801359:	5e                   	pop    %esi
  80135a:	5f                   	pop    %edi
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    
  80135d:	8d 76 00             	lea    0x0(%esi),%esi
  801360:	39 e8                	cmp    %ebp,%eax
  801362:	77 24                	ja     801388 <__udivdi3+0x78>
  801364:	0f bd e8             	bsr    %eax,%ebp
  801367:	83 f5 1f             	xor    $0x1f,%ebp
  80136a:	75 3c                	jne    8013a8 <__udivdi3+0x98>
  80136c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801370:	39 34 24             	cmp    %esi,(%esp)
  801373:	0f 86 9f 00 00 00    	jbe    801418 <__udivdi3+0x108>
  801379:	39 d0                	cmp    %edx,%eax
  80137b:	0f 82 97 00 00 00    	jb     801418 <__udivdi3+0x108>
  801381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801388:	31 d2                	xor    %edx,%edx
  80138a:	31 c0                	xor    %eax,%eax
  80138c:	83 c4 0c             	add    $0xc,%esp
  80138f:	5e                   	pop    %esi
  801390:	5f                   	pop    %edi
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    
  801393:	90                   	nop
  801394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801398:	89 f8                	mov    %edi,%eax
  80139a:	f7 f1                	div    %ecx
  80139c:	31 d2                	xor    %edx,%edx
  80139e:	83 c4 0c             	add    $0xc,%esp
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    
  8013a5:	8d 76 00             	lea    0x0(%esi),%esi
  8013a8:	89 e9                	mov    %ebp,%ecx
  8013aa:	8b 3c 24             	mov    (%esp),%edi
  8013ad:	d3 e0                	shl    %cl,%eax
  8013af:	89 c6                	mov    %eax,%esi
  8013b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013b6:	29 e8                	sub    %ebp,%eax
  8013b8:	89 c1                	mov    %eax,%ecx
  8013ba:	d3 ef                	shr    %cl,%edi
  8013bc:	89 e9                	mov    %ebp,%ecx
  8013be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013c2:	8b 3c 24             	mov    (%esp),%edi
  8013c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013c9:	89 d6                	mov    %edx,%esi
  8013cb:	d3 e7                	shl    %cl,%edi
  8013cd:	89 c1                	mov    %eax,%ecx
  8013cf:	89 3c 24             	mov    %edi,(%esp)
  8013d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013d6:	d3 ee                	shr    %cl,%esi
  8013d8:	89 e9                	mov    %ebp,%ecx
  8013da:	d3 e2                	shl    %cl,%edx
  8013dc:	89 c1                	mov    %eax,%ecx
  8013de:	d3 ef                	shr    %cl,%edi
  8013e0:	09 d7                	or     %edx,%edi
  8013e2:	89 f2                	mov    %esi,%edx
  8013e4:	89 f8                	mov    %edi,%eax
  8013e6:	f7 74 24 08          	divl   0x8(%esp)
  8013ea:	89 d6                	mov    %edx,%esi
  8013ec:	89 c7                	mov    %eax,%edi
  8013ee:	f7 24 24             	mull   (%esp)
  8013f1:	39 d6                	cmp    %edx,%esi
  8013f3:	89 14 24             	mov    %edx,(%esp)
  8013f6:	72 30                	jb     801428 <__udivdi3+0x118>
  8013f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013fc:	89 e9                	mov    %ebp,%ecx
  8013fe:	d3 e2                	shl    %cl,%edx
  801400:	39 c2                	cmp    %eax,%edx
  801402:	73 05                	jae    801409 <__udivdi3+0xf9>
  801404:	3b 34 24             	cmp    (%esp),%esi
  801407:	74 1f                	je     801428 <__udivdi3+0x118>
  801409:	89 f8                	mov    %edi,%eax
  80140b:	31 d2                	xor    %edx,%edx
  80140d:	e9 7a ff ff ff       	jmp    80138c <__udivdi3+0x7c>
  801412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801418:	31 d2                	xor    %edx,%edx
  80141a:	b8 01 00 00 00       	mov    $0x1,%eax
  80141f:	e9 68 ff ff ff       	jmp    80138c <__udivdi3+0x7c>
  801424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801428:	8d 47 ff             	lea    -0x1(%edi),%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	83 c4 0c             	add    $0xc,%esp
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    
  801434:	66 90                	xchg   %ax,%ax
  801436:	66 90                	xchg   %ax,%ax
  801438:	66 90                	xchg   %ax,%ax
  80143a:	66 90                	xchg   %ax,%ax
  80143c:	66 90                	xchg   %ax,%ax
  80143e:	66 90                	xchg   %ax,%ax

00801440 <__umoddi3>:
  801440:	55                   	push   %ebp
  801441:	57                   	push   %edi
  801442:	56                   	push   %esi
  801443:	83 ec 14             	sub    $0x14,%esp
  801446:	8b 44 24 28          	mov    0x28(%esp),%eax
  80144a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80144e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801452:	89 c7                	mov    %eax,%edi
  801454:	89 44 24 04          	mov    %eax,0x4(%esp)
  801458:	8b 44 24 30          	mov    0x30(%esp),%eax
  80145c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801460:	89 34 24             	mov    %esi,(%esp)
  801463:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801467:	85 c0                	test   %eax,%eax
  801469:	89 c2                	mov    %eax,%edx
  80146b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80146f:	75 17                	jne    801488 <__umoddi3+0x48>
  801471:	39 fe                	cmp    %edi,%esi
  801473:	76 4b                	jbe    8014c0 <__umoddi3+0x80>
  801475:	89 c8                	mov    %ecx,%eax
  801477:	89 fa                	mov    %edi,%edx
  801479:	f7 f6                	div    %esi
  80147b:	89 d0                	mov    %edx,%eax
  80147d:	31 d2                	xor    %edx,%edx
  80147f:	83 c4 14             	add    $0x14,%esp
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    
  801486:	66 90                	xchg   %ax,%ax
  801488:	39 f8                	cmp    %edi,%eax
  80148a:	77 54                	ja     8014e0 <__umoddi3+0xa0>
  80148c:	0f bd e8             	bsr    %eax,%ebp
  80148f:	83 f5 1f             	xor    $0x1f,%ebp
  801492:	75 5c                	jne    8014f0 <__umoddi3+0xb0>
  801494:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801498:	39 3c 24             	cmp    %edi,(%esp)
  80149b:	0f 87 e7 00 00 00    	ja     801588 <__umoddi3+0x148>
  8014a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014a5:	29 f1                	sub    %esi,%ecx
  8014a7:	19 c7                	sbb    %eax,%edi
  8014a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014b9:	83 c4 14             	add    $0x14,%esp
  8014bc:	5e                   	pop    %esi
  8014bd:	5f                   	pop    %edi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    
  8014c0:	85 f6                	test   %esi,%esi
  8014c2:	89 f5                	mov    %esi,%ebp
  8014c4:	75 0b                	jne    8014d1 <__umoddi3+0x91>
  8014c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	f7 f6                	div    %esi
  8014cf:	89 c5                	mov    %eax,%ebp
  8014d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014d5:	31 d2                	xor    %edx,%edx
  8014d7:	f7 f5                	div    %ebp
  8014d9:	89 c8                	mov    %ecx,%eax
  8014db:	f7 f5                	div    %ebp
  8014dd:	eb 9c                	jmp    80147b <__umoddi3+0x3b>
  8014df:	90                   	nop
  8014e0:	89 c8                	mov    %ecx,%eax
  8014e2:	89 fa                	mov    %edi,%edx
  8014e4:	83 c4 14             	add    $0x14,%esp
  8014e7:	5e                   	pop    %esi
  8014e8:	5f                   	pop    %edi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    
  8014eb:	90                   	nop
  8014ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014f0:	8b 04 24             	mov    (%esp),%eax
  8014f3:	be 20 00 00 00       	mov    $0x20,%esi
  8014f8:	89 e9                	mov    %ebp,%ecx
  8014fa:	29 ee                	sub    %ebp,%esi
  8014fc:	d3 e2                	shl    %cl,%edx
  8014fe:	89 f1                	mov    %esi,%ecx
  801500:	d3 e8                	shr    %cl,%eax
  801502:	89 e9                	mov    %ebp,%ecx
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	8b 04 24             	mov    (%esp),%eax
  80150b:	09 54 24 04          	or     %edx,0x4(%esp)
  80150f:	89 fa                	mov    %edi,%edx
  801511:	d3 e0                	shl    %cl,%eax
  801513:	89 f1                	mov    %esi,%ecx
  801515:	89 44 24 08          	mov    %eax,0x8(%esp)
  801519:	8b 44 24 10          	mov    0x10(%esp),%eax
  80151d:	d3 ea                	shr    %cl,%edx
  80151f:	89 e9                	mov    %ebp,%ecx
  801521:	d3 e7                	shl    %cl,%edi
  801523:	89 f1                	mov    %esi,%ecx
  801525:	d3 e8                	shr    %cl,%eax
  801527:	89 e9                	mov    %ebp,%ecx
  801529:	09 f8                	or     %edi,%eax
  80152b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80152f:	f7 74 24 04          	divl   0x4(%esp)
  801533:	d3 e7                	shl    %cl,%edi
  801535:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801539:	89 d7                	mov    %edx,%edi
  80153b:	f7 64 24 08          	mull   0x8(%esp)
  80153f:	39 d7                	cmp    %edx,%edi
  801541:	89 c1                	mov    %eax,%ecx
  801543:	89 14 24             	mov    %edx,(%esp)
  801546:	72 2c                	jb     801574 <__umoddi3+0x134>
  801548:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80154c:	72 22                	jb     801570 <__umoddi3+0x130>
  80154e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801552:	29 c8                	sub    %ecx,%eax
  801554:	19 d7                	sbb    %edx,%edi
  801556:	89 e9                	mov    %ebp,%ecx
  801558:	89 fa                	mov    %edi,%edx
  80155a:	d3 e8                	shr    %cl,%eax
  80155c:	89 f1                	mov    %esi,%ecx
  80155e:	d3 e2                	shl    %cl,%edx
  801560:	89 e9                	mov    %ebp,%ecx
  801562:	d3 ef                	shr    %cl,%edi
  801564:	09 d0                	or     %edx,%eax
  801566:	89 fa                	mov    %edi,%edx
  801568:	83 c4 14             	add    $0x14,%esp
  80156b:	5e                   	pop    %esi
  80156c:	5f                   	pop    %edi
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    
  80156f:	90                   	nop
  801570:	39 d7                	cmp    %edx,%edi
  801572:	75 da                	jne    80154e <__umoddi3+0x10e>
  801574:	8b 14 24             	mov    (%esp),%edx
  801577:	89 c1                	mov    %eax,%ecx
  801579:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80157d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801581:	eb cb                	jmp    80154e <__umoddi3+0x10e>
  801583:	90                   	nop
  801584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801588:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80158c:	0f 82 0f ff ff ff    	jb     8014a1 <__umoddi3+0x61>
  801592:	e9 1a ff ff ff       	jmp    8014b1 <__umoddi3+0x71>
