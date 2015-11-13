
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	83 ec 10             	sub    $0x10,%esp
  800041:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800044:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ( ( struct Env * ) envs ) + ENVX(sys_getenvid());
  800047:	e8 d8 00 00 00       	call   800124 <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 db                	test   %ebx,%ebx
  800060:	7e 07                	jle    800069 <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 06                	mov    (%esi),%eax
  800064:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800069:	89 74 24 04          	mov    %esi,0x4(%esp)
  80006d:	89 1c 24             	mov    %ebx,(%esp)
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 07 00 00 00       	call   800081 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	5b                   	pop    %ebx
  80007e:	5e                   	pop    %esi
  80007f:	5d                   	pop    %ebp
  800080:	c3                   	ret    

00800081 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800081:	55                   	push   %ebp
  800082:	89 e5                	mov    %esp,%ebp
  800084:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800087:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80008e:	e8 3f 00 00 00       	call   8000d2 <sys_env_destroy>
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	57                   	push   %edi
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	5f                   	pop    %edi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000be:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c3:	89 d1                	mov    %edx,%ecx
  8000c5:	89 d3                	mov    %edx,%ebx
  8000c7:	89 d7                	mov    %edx,%edi
  8000c9:	89 d6                	mov    %edx,%esi
  8000cb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	89 cb                	mov    %ecx,%ebx
  8000ea:	89 cf                	mov    %ecx,%edi
  8000ec:	89 ce                	mov    %ecx,%esi
  8000ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	7e 28                	jle    80011c <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000f8:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8000ff:	00 
  800100:	c7 44 24 08 8a 15 80 	movl   $0x80158a,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 a7 15 80 00 	movl   $0x8015a7,(%esp)
  800117:	e8 5b 02 00 00       	call   800377 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	83 c4 2c             	add    $0x2c,%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 28                	jle    8001ae <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800191:	00 
  800192:	c7 44 24 08 8a 15 80 	movl   $0x80158a,0x8(%esp)
  800199:	00 
  80019a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a1:	00 
  8001a2:	c7 04 24 a7 15 80 00 	movl   $0x8015a7,(%esp)
  8001a9:	e8 c9 01 00 00       	call   800377 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ae:	83 c4 2c             	add    $0x2c,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5f                   	pop    %edi
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 28                	jle    800201 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 08 8a 15 80 	movl   $0x80158a,0x8(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f4:	00 
  8001f5:	c7 04 24 a7 15 80 00 	movl   $0x8015a7,(%esp)
  8001fc:	e8 76 01 00 00       	call   800377 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800201:	83 c4 2c             	add    $0x2c,%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800212:	bb 00 00 00 00       	mov    $0x0,%ebx
  800217:	b8 06 00 00 00       	mov    $0x6,%eax
  80021c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021f:	8b 55 08             	mov    0x8(%ebp),%edx
  800222:	89 df                	mov    %ebx,%edi
  800224:	89 de                	mov    %ebx,%esi
  800226:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 28                	jle    800254 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800230:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800237:	00 
  800238:	c7 44 24 08 8a 15 80 	movl   $0x80158a,0x8(%esp)
  80023f:	00 
  800240:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800247:	00 
  800248:	c7 04 24 a7 15 80 00 	movl   $0x8015a7,(%esp)
  80024f:	e8 23 01 00 00       	call   800377 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800254:	83 c4 2c             	add    $0x2c,%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    

0080025c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026a:	b8 08 00 00 00       	mov    $0x8,%eax
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	8b 55 08             	mov    0x8(%ebp),%edx
  800275:	89 df                	mov    %ebx,%edi
  800277:	89 de                	mov    %ebx,%esi
  800279:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027b:	85 c0                	test   %eax,%eax
  80027d:	7e 28                	jle    8002a7 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800283:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80028a:	00 
  80028b:	c7 44 24 08 8a 15 80 	movl   $0x80158a,0x8(%esp)
  800292:	00 
  800293:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029a:	00 
  80029b:	c7 04 24 a7 15 80 00 	movl   $0x8015a7,(%esp)
  8002a2:	e8 d0 00 00 00       	call   800377 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a7:	83 c4 2c             	add    $0x2c,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bd:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	89 df                	mov    %ebx,%edi
  8002ca:	89 de                	mov    %ebx,%esi
  8002cc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 28                	jle    8002fa <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002dd:	00 
  8002de:	c7 44 24 08 8a 15 80 	movl   $0x80158a,0x8(%esp)
  8002e5:	00 
  8002e6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ed:	00 
  8002ee:	c7 04 24 a7 15 80 00 	movl   $0x8015a7,(%esp)
  8002f5:	e8 7d 00 00 00       	call   800377 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fa:	83 c4 2c             	add    $0x2c,%esp
  8002fd:	5b                   	pop    %ebx
  8002fe:	5e                   	pop    %esi
  8002ff:	5f                   	pop    %edi
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    

00800302 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800308:	be 00 00 00 00       	mov    $0x0,%esi
  80030d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800312:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800315:	8b 55 08             	mov    0x8(%ebp),%edx
  800318:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80031e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800333:	b8 0c 00 00 00       	mov    $0xc,%eax
  800338:	8b 55 08             	mov    0x8(%ebp),%edx
  80033b:	89 cb                	mov    %ecx,%ebx
  80033d:	89 cf                	mov    %ecx,%edi
  80033f:	89 ce                	mov    %ecx,%esi
  800341:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800343:	85 c0                	test   %eax,%eax
  800345:	7e 28                	jle    80036f <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800347:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800352:	00 
  800353:	c7 44 24 08 8a 15 80 	movl   $0x80158a,0x8(%esp)
  80035a:	00 
  80035b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800362:	00 
  800363:	c7 04 24 a7 15 80 00 	movl   $0x8015a7,(%esp)
  80036a:	e8 08 00 00 00       	call   800377 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036f:	83 c4 2c             	add    $0x2c,%esp
  800372:	5b                   	pop    %ebx
  800373:	5e                   	pop    %esi
  800374:	5f                   	pop    %edi
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
  80037c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80037f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800382:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800388:	e8 97 fd ff ff       	call   800124 <sys_getenvid>
  80038d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800390:	89 54 24 10          	mov    %edx,0x10(%esp)
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80039b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80039f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a3:	c7 04 24 b8 15 80 00 	movl   $0x8015b8,(%esp)
  8003aa:	e8 c1 00 00 00       	call   800470 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b6:	89 04 24             	mov    %eax,(%esp)
  8003b9:	e8 51 00 00 00       	call   80040f <vcprintf>
	cprintf("\n");
  8003be:	c7 04 24 dc 15 80 00 	movl   $0x8015dc,(%esp)
  8003c5:	e8 a6 00 00 00       	call   800470 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ca:	cc                   	int3   
  8003cb:	eb fd                	jmp    8003ca <_panic+0x53>

008003cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	53                   	push   %ebx
  8003d1:	83 ec 14             	sub    $0x14,%esp
  8003d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d7:	8b 13                	mov    (%ebx),%edx
  8003d9:	8d 42 01             	lea    0x1(%edx),%eax
  8003dc:	89 03                	mov    %eax,(%ebx)
  8003de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ea:	75 19                	jne    800405 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003ec:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003f3:	00 
  8003f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f7:	89 04 24             	mov    %eax,(%esp)
  8003fa:	e8 96 fc ff ff       	call   800095 <sys_cputs>
		b->idx = 0;
  8003ff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800405:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800409:	83 c4 14             	add    $0x14,%esp
  80040c:	5b                   	pop    %ebx
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800418:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80041f:	00 00 00 
	b.cnt = 0;
  800422:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800429:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
  800436:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800440:	89 44 24 04          	mov    %eax,0x4(%esp)
  800444:	c7 04 24 cd 03 80 00 	movl   $0x8003cd,(%esp)
  80044b:	e8 af 02 00 00       	call   8006ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800450:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800456:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	e8 2d fc ff ff       	call   800095 <sys_cputs>

	return b.cnt;
}
  800468:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80046e:	c9                   	leave  
  80046f:	c3                   	ret    

00800470 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800476:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 87 ff ff ff       	call   80040f <vcprintf>
	va_end(ap);

	return cnt;
}
  800488:	c9                   	leave  
  800489:	c3                   	ret    
  80048a:	66 90                	xchg   %ax,%ax
  80048c:	66 90                	xchg   %ax,%ax
  80048e:	66 90                	xchg   %ax,%ax

00800490 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	57                   	push   %edi
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 3c             	sub    $0x3c,%esp
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049c:	89 d7                	mov    %edx,%edi
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 c3                	mov    %eax,%ebx
  8004a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8004af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004bd:	39 d9                	cmp    %ebx,%ecx
  8004bf:	72 05                	jb     8004c6 <printnum+0x36>
  8004c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004c4:	77 69                	ja     80052f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004cd:	83 ee 01             	sub    $0x1,%esi
  8004d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004e0:	89 c3                	mov    %eax,%ebx
  8004e2:	89 d6                	mov    %edx,%esi
  8004e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	89 04 24             	mov    %eax,(%esp)
  8004f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	e8 ec 0d 00 00       	call   8012f0 <__udivdi3>
  800504:	89 d9                	mov    %ebx,%ecx
  800506:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80050a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	89 54 24 04          	mov    %edx,0x4(%esp)
  800515:	89 fa                	mov    %edi,%edx
  800517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051a:	e8 71 ff ff ff       	call   800490 <printnum>
  80051f:	eb 1b                	jmp    80053c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800521:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800525:	8b 45 18             	mov    0x18(%ebp),%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	ff d3                	call   *%ebx
  80052d:	eb 03                	jmp    800532 <printnum+0xa2>
  80052f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800532:	83 ee 01             	sub    $0x1,%esi
  800535:	85 f6                	test   %esi,%esi
  800537:	7f e8                	jg     800521 <printnum+0x91>
  800539:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80053c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800540:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800544:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800547:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80054a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80055b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055f:	e8 bc 0e 00 00       	call   801420 <__umoddi3>
  800564:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800568:	0f be 80 de 15 80 00 	movsbl 0x8015de(%eax),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800575:	ff d0                	call   *%eax
}
  800577:	83 c4 3c             	add    $0x3c,%esp
  80057a:	5b                   	pop    %ebx
  80057b:	5e                   	pop    %esi
  80057c:	5f                   	pop    %edi
  80057d:	5d                   	pop    %ebp
  80057e:	c3                   	ret    

0080057f <cprintnum>:

static void
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	57                   	push   %edi
  800583:	56                   	push   %esi
  800584:	53                   	push   %ebx
  800585:	83 ec 3c             	sub    $0x3c,%esp
  800588:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80058b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058e:	89 cf                	mov    %ecx,%edi
  800590:	8b 45 08             	mov    0x8(%ebp),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	8b 45 0c             	mov    0xc(%ebp),%eax
  800599:	89 c3                	mov    %eax,%ebx
  80059b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80059e:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a1:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ac:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005af:	39 d9                	cmp    %ebx,%ecx
  8005b1:	72 13                	jb     8005c6 <cprintnum+0x47>
  8005b3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8005b6:	76 0e                	jbe    8005c6 <cprintnum+0x47>
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  8005b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005bb:	0b 45 18             	or     0x18(%ebp),%eax
  8005be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c4:	eb 6a                	jmp    800630 <cprintnum+0xb1>
cprintnum( int color , void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
  8005c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005cd:	83 ee 01             	sub    $0x1,%esi
  8005d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005e0:	89 c3                	mov    %eax,%ebx
  8005e2:	89 d6                	mov    %edx,%esi
  8005e4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005e7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8005ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8005f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f5:	89 04 24             	mov    %eax,(%esp)
  8005f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ff:	e8 ec 0c 00 00       	call   8012f0 <__udivdi3>
  800604:	89 d9                	mov    %ebx,%ecx
  800606:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80060a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	89 54 24 04          	mov    %edx,0x4(%esp)
  800615:	89 f9                	mov    %edi,%ecx
  800617:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80061a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061d:	e8 5d ff ff ff       	call   80057f <cprintnum>
  800622:	eb 16                	jmp    80063a <cprintnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch( color | padc, putdat);
  800624:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		cprintnum( color , putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800630:	83 ee 01             	sub    $0x1,%esi
  800633:	85 f6                	test   %esi,%esi
  800635:	7f ed                	jg     800624 <cprintnum+0xa5>
  800637:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			putch( color | padc, putdat);
	}

	// then print this (the least significant) digit
	putch( color | ( "0123456789abcdef"[num % base] ) , putdat);
  80063a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800642:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800645:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800648:	89 44 24 08          	mov    %eax,0x8(%esp)
  80064c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800650:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800653:	89 04 24             	mov    %eax,(%esp)
  800656:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065d:	e8 be 0d 00 00       	call   801420 <__umoddi3>
  800662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800666:	0f be 80 de 15 80 00 	movsbl 0x8015de(%eax),%eax
  80066d:	0b 45 dc             	or     -0x24(%ebp),%eax
  800670:	89 04 24             	mov    %eax,(%esp)
  800673:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800676:	ff d0                	call   *%eax
}
  800678:	83 c4 3c             	add    $0x3c,%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f5:	89 04 24             	mov    %eax,(%esp)
  8006f8:	e8 02 00 00 00       	call   8006ff <vprintfmt>
	va_end(ap);
}
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <vprintfmt>:
void cprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	57                   	push   %edi
  800703:	56                   	push   %esi
  800704:	53                   	push   %ebx
  800705:	83 ec 3c             	sub    $0x3c,%esp
  800708:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80070b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80070e:	eb 14                	jmp    800724 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800710:	85 c0                	test   %eax,%eax
  800712:	0f 84 b3 03 00 00    	je     800acb <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800718:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800722:	89 f3                	mov    %esi,%ebx
  800724:	8d 73 01             	lea    0x1(%ebx),%esi
  800727:	0f b6 03             	movzbl (%ebx),%eax
  80072a:	83 f8 25             	cmp    $0x25,%eax
  80072d:	75 e1                	jne    800710 <vprintfmt+0x11>
  80072f:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800733:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80073a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800741:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800748:	ba 00 00 00 00       	mov    $0x0,%edx
  80074d:	eb 1d                	jmp    80076c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800751:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800755:	eb 15                	jmp    80076c <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800757:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800759:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80075d:	eb 0d                	jmp    80076c <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80075f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800762:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800765:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80076f:	0f b6 0e             	movzbl (%esi),%ecx
  800772:	0f b6 c1             	movzbl %cl,%eax
  800775:	83 e9 23             	sub    $0x23,%ecx
  800778:	80 f9 55             	cmp    $0x55,%cl
  80077b:	0f 87 2a 03 00 00    	ja     800aab <vprintfmt+0x3ac>
  800781:	0f b6 c9             	movzbl %cl,%ecx
  800784:	ff 24 8d a0 16 80 00 	jmp    *0x8016a0(,%ecx,4)
  80078b:	89 de                	mov    %ebx,%esi
  80078d:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800792:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800795:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800799:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80079c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80079f:	83 fb 09             	cmp    $0x9,%ebx
  8007a2:	77 36                	ja     8007da <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007a4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007a7:	eb e9                	jmp    800792 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	8d 48 04             	lea    0x4(%eax),%ecx
  8007af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b2:	8b 00                	mov    (%eax),%eax
  8007b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007b9:	eb 22                	jmp    8007dd <vprintfmt+0xde>
  8007bb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007be:	85 c9                	test   %ecx,%ecx
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c5:	0f 49 c1             	cmovns %ecx,%eax
  8007c8:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cb:	89 de                	mov    %ebx,%esi
  8007cd:	eb 9d                	jmp    80076c <vprintfmt+0x6d>
  8007cf:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007d1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8007d8:	eb 92                	jmp    80076c <vprintfmt+0x6d>
  8007da:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8007dd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e1:	79 89                	jns    80076c <vprintfmt+0x6d>
  8007e3:	e9 77 ff ff ff       	jmp    80075f <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007eb:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ed:	e9 7a ff ff ff       	jmp    80076c <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	89 04 24             	mov    %eax,(%esp)
  800804:	ff 55 08             	call   *0x8(%ebp)
			break;
  800807:	e9 18 ff ff ff       	jmp    800724 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8d 50 04             	lea    0x4(%eax),%edx
  800812:	89 55 14             	mov    %edx,0x14(%ebp)
  800815:	8b 00                	mov    (%eax),%eax
  800817:	99                   	cltd   
  800818:	31 d0                	xor    %edx,%eax
  80081a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80081c:	83 f8 09             	cmp    $0x9,%eax
  80081f:	7f 0b                	jg     80082c <vprintfmt+0x12d>
  800821:	8b 14 85 60 19 80 00 	mov    0x801960(,%eax,4),%edx
  800828:	85 d2                	test   %edx,%edx
  80082a:	75 20                	jne    80084c <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80082c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800830:	c7 44 24 08 f6 15 80 	movl   $0x8015f6,0x8(%esp)
  800837:	00 
  800838:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	e8 90 fe ff ff       	call   8006d7 <printfmt>
  800847:	e9 d8 fe ff ff       	jmp    800724 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80084c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800850:	c7 44 24 08 ff 15 80 	movl   $0x8015ff,0x8(%esp)
  800857:	00 
  800858:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	e8 70 fe ff ff       	call   8006d7 <printfmt>
  800867:	e9 b8 fe ff ff       	jmp    800724 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80086f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800872:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8d 50 04             	lea    0x4(%eax),%edx
  80087b:	89 55 14             	mov    %edx,0x14(%ebp)
  80087e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800880:	85 f6                	test   %esi,%esi
  800882:	b8 ef 15 80 00       	mov    $0x8015ef,%eax
  800887:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80088a:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80088e:	0f 84 97 00 00 00    	je     80092b <vprintfmt+0x22c>
  800894:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800898:	0f 8e 9b 00 00 00    	jle    800939 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80089e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a2:	89 34 24             	mov    %esi,(%esp)
  8008a5:	e8 ce 06 00 00       	call   800f78 <strnlen>
  8008aa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008ad:	29 c2                	sub    %eax,%edx
  8008af:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8008b2:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008b6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008b9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008c2:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c4:	eb 0f                	jmp    8008d5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8008c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008cd:	89 04 24             	mov    %eax,(%esp)
  8008d0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d2:	83 eb 01             	sub    $0x1,%ebx
  8008d5:	85 db                	test   %ebx,%ebx
  8008d7:	7f ed                	jg     8008c6 <vprintfmt+0x1c7>
  8008d9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008dc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008df:	85 d2                	test   %edx,%edx
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e6:	0f 49 c2             	cmovns %edx,%eax
  8008e9:	29 c2                	sub    %eax,%edx
  8008eb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8008ee:	89 d7                	mov    %edx,%edi
  8008f0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8008f3:	eb 50                	jmp    800945 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008f9:	74 1e                	je     800919 <vprintfmt+0x21a>
  8008fb:	0f be d2             	movsbl %dl,%edx
  8008fe:	83 ea 20             	sub    $0x20,%edx
  800901:	83 fa 5e             	cmp    $0x5e,%edx
  800904:	76 13                	jbe    800919 <vprintfmt+0x21a>
					putch('?', putdat);
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
  800909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800914:	ff 55 08             	call   *0x8(%ebp)
  800917:	eb 0d                	jmp    800926 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800920:	89 04 24             	mov    %eax,(%esp)
  800923:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800926:	83 ef 01             	sub    $0x1,%edi
  800929:	eb 1a                	jmp    800945 <vprintfmt+0x246>
  80092b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80092e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800931:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800934:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800937:	eb 0c                	jmp    800945 <vprintfmt+0x246>
  800939:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80093c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80093f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800942:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800945:	83 c6 01             	add    $0x1,%esi
  800948:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80094c:	0f be c2             	movsbl %dl,%eax
  80094f:	85 c0                	test   %eax,%eax
  800951:	74 27                	je     80097a <vprintfmt+0x27b>
  800953:	85 db                	test   %ebx,%ebx
  800955:	78 9e                	js     8008f5 <vprintfmt+0x1f6>
  800957:	83 eb 01             	sub    $0x1,%ebx
  80095a:	79 99                	jns    8008f5 <vprintfmt+0x1f6>
  80095c:	89 f8                	mov    %edi,%eax
  80095e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800961:	8b 75 08             	mov    0x8(%ebp),%esi
  800964:	89 c3                	mov    %eax,%ebx
  800966:	eb 1a                	jmp    800982 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800968:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800973:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800975:	83 eb 01             	sub    $0x1,%ebx
  800978:	eb 08                	jmp    800982 <vprintfmt+0x283>
  80097a:	89 fb                	mov    %edi,%ebx
  80097c:	8b 75 08             	mov    0x8(%ebp),%esi
  80097f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800982:	85 db                	test   %ebx,%ebx
  800984:	7f e2                	jg     800968 <vprintfmt+0x269>
  800986:	89 75 08             	mov    %esi,0x8(%ebp)
  800989:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80098c:	e9 93 fd ff ff       	jmp    800724 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800991:	83 fa 01             	cmp    $0x1,%edx
  800994:	7e 16                	jle    8009ac <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800996:	8b 45 14             	mov    0x14(%ebp),%eax
  800999:	8d 50 08             	lea    0x8(%eax),%edx
  80099c:	89 55 14             	mov    %edx,0x14(%ebp)
  80099f:	8b 50 04             	mov    0x4(%eax),%edx
  8009a2:	8b 00                	mov    (%eax),%eax
  8009a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009a7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009aa:	eb 32                	jmp    8009de <vprintfmt+0x2df>
	else if (lflag)
  8009ac:	85 d2                	test   %edx,%edx
  8009ae:	74 18                	je     8009c8 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8009b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b3:	8d 50 04             	lea    0x4(%eax),%edx
  8009b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b9:	8b 30                	mov    (%eax),%esi
  8009bb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009be:	89 f0                	mov    %esi,%eax
  8009c0:	c1 f8 1f             	sar    $0x1f,%eax
  8009c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009c6:	eb 16                	jmp    8009de <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8009c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009cb:	8d 50 04             	lea    0x4(%eax),%edx
  8009ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d1:	8b 30                	mov    (%eax),%esi
  8009d3:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8009d6:	89 f0                	mov    %esi,%eax
  8009d8:	c1 f8 1f             	sar    $0x1f,%eax
  8009db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009ed:	0f 89 80 00 00 00    	jns    800a73 <vprintfmt+0x374>
				putch('-', putdat);
  8009f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009fe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a01:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a07:	f7 d8                	neg    %eax
  800a09:	83 d2 00             	adc    $0x0,%edx
  800a0c:	f7 da                	neg    %edx
			}
			base = 10;
  800a0e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800a13:	eb 5e                	jmp    800a73 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a15:	8d 45 14             	lea    0x14(%ebp),%eax
  800a18:	e8 63 fc ff ff       	call   800680 <getuint>
			base = 10;
  800a1d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a22:	eb 4f                	jmp    800a73 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800a24:	8d 45 14             	lea    0x14(%ebp),%eax
  800a27:	e8 54 fc ff ff       	call   800680 <getuint>
			base = 8 ;
  800a2c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800a31:	eb 40                	jmp    800a73 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800a33:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a37:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a3e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a41:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a45:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a4c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a4f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a52:	8d 50 04             	lea    0x4(%eax),%edx
  800a55:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a58:	8b 00                	mov    (%eax),%eax
  800a5a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a5f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a64:	eb 0d                	jmp    800a73 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a66:	8d 45 14             	lea    0x14(%ebp),%eax
  800a69:	e8 12 fc ff ff       	call   800680 <getuint>
			base = 16;
  800a6e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a73:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800a77:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a7b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a7e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a82:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a86:	89 04 24             	mov    %eax,(%esp)
  800a89:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a8d:	89 fa                	mov    %edi,%edx
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	e8 f9 f9 ff ff       	call   800490 <printnum>
			break;
  800a97:	e9 88 fc ff ff       	jmp    800724 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a9c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa0:	89 04 24             	mov    %eax,(%esp)
  800aa3:	ff 55 08             	call   *0x8(%ebp)
			break;
  800aa6:	e9 79 fc ff ff       	jmp    800724 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aaf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ab6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ab9:	89 f3                	mov    %esi,%ebx
  800abb:	eb 03                	jmp    800ac0 <vprintfmt+0x3c1>
  800abd:	83 eb 01             	sub    $0x1,%ebx
  800ac0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ac4:	75 f7                	jne    800abd <vprintfmt+0x3be>
  800ac6:	e9 59 fc ff ff       	jmp    800724 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800acb:	83 c4 3c             	add    $0x3c,%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <cvprintfmt>:

void
cvprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	83 ec 3c             	sub    $0x3c,%esp
  800adc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
  800adf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae2:	8d 50 04             	lea    0x4(%eax),%edx
  800ae5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae8:	8b 00                	mov    (%eax),%eax
  800aea:	c1 e0 08             	shl    $0x8,%eax
  800aed:	0f b7 c0             	movzwl %ax,%eax
  800af0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			putch(color | ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800af3:	83 c8 25             	or     $0x25,%eax
  800af6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800af9:	eb 1a                	jmp    800b15 <cvprintfmt+0x42>
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800afb:	85 c0                	test   %eax,%eax
  800afd:	0f 84 a9 03 00 00    	je     800eac <cvprintfmt+0x3d9>
				return;
			putch( color | ch, putdat);
  800b03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b06:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b0a:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800b0d:	89 04 24             	mov    %eax,(%esp)
  800b10:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int color = (( va_arg(ap,int)) << 8 ) & 0xFF00 ; 
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b13:	89 fb                	mov    %edi,%ebx
  800b15:	8d 7b 01             	lea    0x1(%ebx),%edi
  800b18:	0f b6 03             	movzbl (%ebx),%eax
  800b1b:	83 f8 25             	cmp    $0x25,%eax
  800b1e:	75 db                	jne    800afb <cvprintfmt+0x28>
  800b20:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800b24:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800b2b:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800b30:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3c:	eb 18                	jmp    800b56 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b3e:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800b40:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800b44:	eb 10                	jmp    800b56 <cvprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b46:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800b48:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800b4c:	eb 08                	jmp    800b56 <cvprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800b4e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800b51:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b56:	8d 5f 01             	lea    0x1(%edi),%ebx
  800b59:	0f b6 0f             	movzbl (%edi),%ecx
  800b5c:	0f b6 c1             	movzbl %cl,%eax
  800b5f:	83 e9 23             	sub    $0x23,%ecx
  800b62:	80 f9 55             	cmp    $0x55,%cl
  800b65:	0f 87 1f 03 00 00    	ja     800e8a <cvprintfmt+0x3b7>
  800b6b:	0f b6 c9             	movzbl %cl,%ecx
  800b6e:	ff 24 8d f8 17 80 00 	jmp    *0x8017f8(,%ecx,4)
  800b75:	89 df                	mov    %ebx,%edi
  800b77:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800b7c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  800b7f:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
  800b83:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800b86:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800b89:	83 f9 09             	cmp    $0x9,%ecx
  800b8c:	77 33                	ja     800bc1 <cvprintfmt+0xee>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800b8e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800b91:	eb e9                	jmp    800b7c <cvprintfmt+0xa9>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800b93:	8b 45 14             	mov    0x14(%ebp),%eax
  800b96:	8d 48 04             	lea    0x4(%eax),%ecx
  800b99:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b9c:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9e:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ba0:	eb 1f                	jmp    800bc1 <cvprintfmt+0xee>
  800ba2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ba5:	85 ff                	test   %edi,%edi
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bac:	0f 49 c7             	cmovns %edi,%eax
  800baf:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bb2:	89 df                	mov    %ebx,%edi
  800bb4:	eb a0                	jmp    800b56 <cvprintfmt+0x83>
  800bb6:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800bb8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800bbf:	eb 95                	jmp    800b56 <cvprintfmt+0x83>

		process_precision:
			if (width < 0)
  800bc1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800bc5:	79 8f                	jns    800b56 <cvprintfmt+0x83>
  800bc7:	eb 85                	jmp    800b4e <cvprintfmt+0x7b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800bc9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bcc:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800bce:	66 90                	xchg   %ax,%ax
  800bd0:	eb 84                	jmp    800b56 <cvprintfmt+0x83>

		// character
		case 'c':
			putch( color | va_arg(ap, int), putdat);
  800bd2:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd5:	8d 50 04             	lea    0x4(%eax),%edx
  800bd8:	89 55 14             	mov    %edx,0x14(%ebp)
  800bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bde:	89 54 24 04          	mov    %edx,0x4(%esp)
  800be2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800be5:	0b 10                	or     (%eax),%edx
  800be7:	89 14 24             	mov    %edx,(%esp)
  800bea:	ff 55 08             	call   *0x8(%ebp)
			break;
  800bed:	e9 23 ff ff ff       	jmp    800b15 <cvprintfmt+0x42>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800bf2:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf5:	8d 50 04             	lea    0x4(%eax),%edx
  800bf8:	89 55 14             	mov    %edx,0x14(%ebp)
  800bfb:	8b 00                	mov    (%eax),%eax
  800bfd:	99                   	cltd   
  800bfe:	31 d0                	xor    %edx,%eax
  800c00:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800c02:	83 f8 09             	cmp    $0x9,%eax
  800c05:	7f 0b                	jg     800c12 <cvprintfmt+0x13f>
  800c07:	8b 14 85 60 19 80 00 	mov    0x801960(,%eax,4),%edx
  800c0e:	85 d2                	test   %edx,%edx
  800c10:	75 23                	jne    800c35 <cvprintfmt+0x162>
				printfmt( putch, putdat, "error %d", err);
  800c12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c16:	c7 44 24 08 f6 15 80 	movl   $0x8015f6,0x8(%esp)
  800c1d:	00 
  800c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	89 04 24             	mov    %eax,(%esp)
  800c2b:	e8 a7 fa ff ff       	call   8006d7 <printfmt>
  800c30:	e9 e0 fe ff ff       	jmp    800b15 <cvprintfmt+0x42>
			else
				printfmt( putch, putdat, "%s", p);
  800c35:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c39:	c7 44 24 08 ff 15 80 	movl   $0x8015ff,0x8(%esp)
  800c40:	00 
  800c41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4b:	89 04 24             	mov    %eax,(%esp)
  800c4e:	e8 84 fa ff ff       	call   8006d7 <printfmt>
  800c53:	e9 bd fe ff ff       	jmp    800b15 <cvprintfmt+0x42>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c58:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800c5b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt( putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
  800c5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c61:	8d 48 04             	lea    0x4(%eax),%ecx
  800c64:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c67:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800c69:	85 ff                	test   %edi,%edi
  800c6b:	b8 ef 15 80 00       	mov    $0x8015ef,%eax
  800c70:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800c73:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800c77:	74 61                	je     800cda <cvprintfmt+0x207>
  800c79:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800c7d:	7e 5b                	jle    800cda <cvprintfmt+0x207>
				for (width -= strnlen(p, precision); width > 0; width--)
  800c7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c83:	89 3c 24             	mov    %edi,(%esp)
  800c86:	e8 ed 02 00 00       	call   800f78 <strnlen>
  800c8b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800c8e:	29 c2                	sub    %eax,%edx
  800c90:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
  800c93:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800c97:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800c9a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800c9d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ca0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ca3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ca6:	89 d3                	mov    %edx,%ebx
  800ca8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800caa:	eb 0f                	jmp    800cbb <cvprintfmt+0x1e8>
					putch(color | padc, putdat);
  800cac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb3:	89 3c 24             	mov    %edi,(%esp)
  800cb6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800cb8:	83 eb 01             	sub    $0x1,%ebx
  800cbb:	85 db                	test   %ebx,%ebx
  800cbd:	7f ed                	jg     800cac <cvprintfmt+0x1d9>
  800cbf:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800cc2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ccb:	85 d2                	test   %edx,%edx
  800ccd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd2:	0f 49 c2             	cmovns %edx,%eax
  800cd5:	29 c2                	sub    %eax,%edx
  800cd7:	89 55 dc             	mov    %edx,-0x24(%ebp)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
  800cda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cdd:	83 c8 3f             	or     $0x3f,%eax
  800ce0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ce3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ce6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ce9:	eb 36                	jmp    800d21 <cvprintfmt+0x24e>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ceb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cef:	74 1d                	je     800d0e <cvprintfmt+0x23b>
  800cf1:	0f be d2             	movsbl %dl,%edx
  800cf4:	83 ea 20             	sub    $0x20,%edx
  800cf7:	83 fa 5e             	cmp    $0x5e,%edx
  800cfa:	76 12                	jbe    800d0e <cvprintfmt+0x23b>
					putch(color | '?', putdat);
  800cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d03:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d06:	89 04 24             	mov    %eax,(%esp)
  800d09:	ff 55 08             	call   *0x8(%ebp)
  800d0c:	eb 10                	jmp    800d1e <cvprintfmt+0x24b>
				else
					putch(color | ch, putdat);
  800d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d11:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d15:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800d18:	89 04 24             	mov    %eax,(%esp)
  800d1b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg( ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(color | padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d1e:	83 eb 01             	sub    $0x1,%ebx
  800d21:	83 c7 01             	add    $0x1,%edi
  800d24:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800d28:	0f be c2             	movsbl %dl,%eax
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	74 27                	je     800d56 <cvprintfmt+0x283>
  800d2f:	85 f6                	test   %esi,%esi
  800d31:	78 b8                	js     800ceb <cvprintfmt+0x218>
  800d33:	83 ee 01             	sub    $0x1,%esi
  800d36:	79 b3                	jns    800ceb <cvprintfmt+0x218>
  800d38:	89 d8                	mov    %ebx,%eax
  800d3a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d3d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d40:	89 c3                	mov    %eax,%ebx
  800d42:	eb 18                	jmp    800d5c <cvprintfmt+0x289>
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
				putch(color || ' ', putdat);
  800d44:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800d4f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch(color | '?', putdat);
				else
					putch(color | ch, putdat);
			for (; width > 0; width--)
  800d51:	83 eb 01             	sub    $0x1,%ebx
  800d54:	eb 06                	jmp    800d5c <cvprintfmt+0x289>
  800d56:	8b 75 08             	mov    0x8(%ebp),%esi
  800d59:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d5c:	85 db                	test   %ebx,%ebx
  800d5e:	7f e4                	jg     800d44 <cvprintfmt+0x271>
  800d60:	89 75 08             	mov    %esi,0x8(%ebp)
  800d63:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d69:	e9 a7 fd ff ff       	jmp    800b15 <cvprintfmt+0x42>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d6e:	83 fa 01             	cmp    $0x1,%edx
  800d71:	7e 10                	jle    800d83 <cvprintfmt+0x2b0>
		return va_arg(*ap, long long);
  800d73:	8b 45 14             	mov    0x14(%ebp),%eax
  800d76:	8d 50 08             	lea    0x8(%eax),%edx
  800d79:	89 55 14             	mov    %edx,0x14(%ebp)
  800d7c:	8b 30                	mov    (%eax),%esi
  800d7e:	8b 78 04             	mov    0x4(%eax),%edi
  800d81:	eb 26                	jmp    800da9 <cvprintfmt+0x2d6>
	else if (lflag)
  800d83:	85 d2                	test   %edx,%edx
  800d85:	74 12                	je     800d99 <cvprintfmt+0x2c6>
		return va_arg(*ap, long);
  800d87:	8b 45 14             	mov    0x14(%ebp),%eax
  800d8a:	8d 50 04             	lea    0x4(%eax),%edx
  800d8d:	89 55 14             	mov    %edx,0x14(%ebp)
  800d90:	8b 30                	mov    (%eax),%esi
  800d92:	89 f7                	mov    %esi,%edi
  800d94:	c1 ff 1f             	sar    $0x1f,%edi
  800d97:	eb 10                	jmp    800da9 <cvprintfmt+0x2d6>
	else
		return va_arg(*ap, int);
  800d99:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9c:	8d 50 04             	lea    0x4(%eax),%edx
  800d9f:	89 55 14             	mov    %edx,0x14(%ebp)
  800da2:	8b 30                	mov    (%eax),%esi
  800da4:	89 f7                	mov    %esi,%edi
  800da6:	c1 ff 1f             	sar    $0x1f,%edi
				putch(color || ' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800da9:	89 f0                	mov    %esi,%eax
  800dab:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch(color | '-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800dad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800db2:	85 ff                	test   %edi,%edi
  800db4:	0f 89 8e 00 00 00    	jns    800e48 <cvprintfmt+0x375>
				putch(color | '-', putdat);
  800dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dc4:	83 c8 2d             	or     $0x2d,%eax
  800dc7:	89 04 24             	mov    %eax,(%esp)
  800dca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	89 fa                	mov    %edi,%edx
  800dd1:	f7 d8                	neg    %eax
  800dd3:	83 d2 00             	adc    $0x0,%edx
  800dd6:	f7 da                	neg    %edx
			}
			base = 10;
  800dd8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ddd:	eb 69                	jmp    800e48 <cvprintfmt+0x375>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ddf:	8d 45 14             	lea    0x14(%ebp),%eax
  800de2:	e8 99 f8 ff ff       	call   800680 <getuint>
			base = 10;
  800de7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800dec:	eb 5a                	jmp    800e48 <cvprintfmt+0x375>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800dee:	8d 45 14             	lea    0x14(%ebp),%eax
  800df1:	e8 8a f8 ff ff       	call   800680 <getuint>
			base = 8 ;
  800df6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number ; 
  800dfb:	eb 4b                	jmp    800e48 <cvprintfmt+0x375>

		// pointer
		case 'p':
			putch(color | '0', putdat);
  800dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e04:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800e07:	89 f0                	mov    %esi,%eax
  800e09:	83 c8 30             	or     $0x30,%eax
  800e0c:	89 04 24             	mov    %eax,(%esp)
  800e0f:	ff 55 08             	call   *0x8(%ebp)
			putch(color | 'x', putdat);
  800e12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e19:	89 f0                	mov    %esi,%eax
  800e1b:	83 c8 78             	or     $0x78,%eax
  800e1e:	89 04 24             	mov    %eax,(%esp)
  800e21:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e24:	8b 45 14             	mov    0x14(%ebp),%eax
  800e27:	8d 50 04             	lea    0x4(%eax),%edx
  800e2a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch(color | '0', putdat);
			putch(color | 'x', putdat);
			num = (unsigned long long)
  800e2d:	8b 00                	mov    (%eax),%eax
  800e2f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e34:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800e39:	eb 0d                	jmp    800e48 <cvprintfmt+0x375>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e3e:	e8 3d f8 ff ff       	call   800680 <getuint>
			base = 16;
  800e43:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			cprintnum( color , putch, putdat, num, base, width, padc);
  800e48:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800e4c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e50:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800e53:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e5b:	89 04 24             	mov    %eax,(%esp)
  800e5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	8b 55 08             	mov    0x8(%ebp),%edx
  800e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e6b:	e8 0f f7 ff ff       	call   80057f <cprintnum>
			break;
  800e70:	e9 a0 fc ff ff       	jmp    800b15 <cvprintfmt+0x42>

		// escaped '%' character
		case '%':
			putch(color | ch, putdat);
  800e75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e78:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e7c:	0b 45 e4             	or     -0x1c(%ebp),%eax
  800e7f:	89 04 24             	mov    %eax,(%esp)
  800e82:	ff 55 08             	call   *0x8(%ebp)
			break;
  800e85:	e9 8b fc ff ff       	jmp    800b15 <cvprintfmt+0x42>

		// unrecognized escape sequence - just print it literally
		default:
			putch(color | '%', putdat);
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800e94:	89 04 24             	mov    %eax,(%esp)
  800e97:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e9a:	89 fb                	mov    %edi,%ebx
  800e9c:	eb 03                	jmp    800ea1 <cvprintfmt+0x3ce>
  800e9e:	83 eb 01             	sub    $0x1,%ebx
  800ea1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ea5:	75 f7                	jne    800e9e <cvprintfmt+0x3cb>
  800ea7:	e9 69 fc ff ff       	jmp    800b15 <cvprintfmt+0x42>
				/* do nothing */;
			break;
		}
	}
}
  800eac:	83 c4 3c             	add    $0x3c,%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <cprintfmt>:
	va_end(ap);
}

void
cprintfmt( void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800eba:	8d 45 14             	lea    0x14(%ebp),%eax
	cvprintfmt( putch, putdat, fmt, ap);
  800ebd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	89 04 24             	mov    %eax,(%esp)
  800ed5:	e8 f9 fb ff ff       	call   800ad3 <cvprintfmt>
	va_end(ap);
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 28             	sub    $0x28,%esp
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ee8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800eeb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800eef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ef2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	74 30                	je     800f2d <vsnprintf+0x51>
  800efd:	85 d2                	test   %edx,%edx
  800eff:	7e 2c                	jle    800f2d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f01:	8b 45 14             	mov    0x14(%ebp),%eax
  800f04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f08:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f16:	c7 04 24 ba 06 80 00 	movl   $0x8006ba,(%esp)
  800f1d:	e8 dd f7 ff ff       	call   8006ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f25:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f2b:	eb 05                	jmp    800f32 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f3a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f41:	8b 45 10             	mov    0x10(%ebp),%eax
  800f44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	89 04 24             	mov    %eax,(%esp)
  800f55:	e8 82 ff ff ff       	call   800edc <vsnprintf>
	va_end(ap);

	return rc;
}
  800f5a:	c9                   	leave  
  800f5b:	c3                   	ret    
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6b:	eb 03                	jmp    800f70 <strlen+0x10>
		n++;
  800f6d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f74:	75 f7                	jne    800f6d <strlen+0xd>
		n++;
	return n;
}
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f81:	b8 00 00 00 00       	mov    $0x0,%eax
  800f86:	eb 03                	jmp    800f8b <strnlen+0x13>
		n++;
  800f88:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f8b:	39 d0                	cmp    %edx,%eax
  800f8d:	74 06                	je     800f95 <strnlen+0x1d>
  800f8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800f93:	75 f3                	jne    800f88 <strnlen+0x10>
		n++;
	return n;
}
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	53                   	push   %ebx
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fa1:	89 c2                	mov    %eax,%edx
  800fa3:	83 c2 01             	add    $0x1,%edx
  800fa6:	83 c1 01             	add    $0x1,%ecx
  800fa9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800fad:	88 5a ff             	mov    %bl,-0x1(%edx)
  800fb0:	84 db                	test   %bl,%bl
  800fb2:	75 ef                	jne    800fa3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800fb4:	5b                   	pop    %ebx
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fc1:	89 1c 24             	mov    %ebx,(%esp)
  800fc4:	e8 97 ff ff ff       	call   800f60 <strlen>
	strcpy(dst + len, src);
  800fc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fcc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd0:	01 d8                	add    %ebx,%eax
  800fd2:	89 04 24             	mov    %eax,(%esp)
  800fd5:	e8 bd ff ff ff       	call   800f97 <strcpy>
	return dst;
}
  800fda:	89 d8                	mov    %ebx,%eax
  800fdc:	83 c4 08             	add    $0x8,%esp
  800fdf:	5b                   	pop    %ebx
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
  800fe7:	8b 75 08             	mov    0x8(%ebp),%esi
  800fea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fed:	89 f3                	mov    %esi,%ebx
  800fef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	eb 0f                	jmp    801005 <strncpy+0x23>
		*dst++ = *src;
  800ff6:	83 c2 01             	add    $0x1,%edx
  800ff9:	0f b6 01             	movzbl (%ecx),%eax
  800ffc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800fff:	80 39 01             	cmpb   $0x1,(%ecx)
  801002:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801005:	39 da                	cmp    %ebx,%edx
  801007:	75 ed                	jne    800ff6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801009:	89 f0                	mov    %esi,%eax
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	8b 75 08             	mov    0x8(%ebp),%esi
  801017:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80101d:	89 f0                	mov    %esi,%eax
  80101f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801023:	85 c9                	test   %ecx,%ecx
  801025:	75 0b                	jne    801032 <strlcpy+0x23>
  801027:	eb 1d                	jmp    801046 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801029:	83 c0 01             	add    $0x1,%eax
  80102c:	83 c2 01             	add    $0x1,%edx
  80102f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801032:	39 d8                	cmp    %ebx,%eax
  801034:	74 0b                	je     801041 <strlcpy+0x32>
  801036:	0f b6 0a             	movzbl (%edx),%ecx
  801039:	84 c9                	test   %cl,%cl
  80103b:	75 ec                	jne    801029 <strlcpy+0x1a>
  80103d:	89 c2                	mov    %eax,%edx
  80103f:	eb 02                	jmp    801043 <strlcpy+0x34>
  801041:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801043:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801046:	29 f0                	sub    %esi,%eax
}
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801052:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801055:	eb 06                	jmp    80105d <strcmp+0x11>
		p++, q++;
  801057:	83 c1 01             	add    $0x1,%ecx
  80105a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80105d:	0f b6 01             	movzbl (%ecx),%eax
  801060:	84 c0                	test   %al,%al
  801062:	74 04                	je     801068 <strcmp+0x1c>
  801064:	3a 02                	cmp    (%edx),%al
  801066:	74 ef                	je     801057 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801068:	0f b6 c0             	movzbl %al,%eax
  80106b:	0f b6 12             	movzbl (%edx),%edx
  80106e:	29 d0                	sub    %edx,%eax
}
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	53                   	push   %ebx
  801076:	8b 45 08             	mov    0x8(%ebp),%eax
  801079:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107c:	89 c3                	mov    %eax,%ebx
  80107e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801081:	eb 06                	jmp    801089 <strncmp+0x17>
		n--, p++, q++;
  801083:	83 c0 01             	add    $0x1,%eax
  801086:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801089:	39 d8                	cmp    %ebx,%eax
  80108b:	74 15                	je     8010a2 <strncmp+0x30>
  80108d:	0f b6 08             	movzbl (%eax),%ecx
  801090:	84 c9                	test   %cl,%cl
  801092:	74 04                	je     801098 <strncmp+0x26>
  801094:	3a 0a                	cmp    (%edx),%cl
  801096:	74 eb                	je     801083 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801098:	0f b6 00             	movzbl (%eax),%eax
  80109b:	0f b6 12             	movzbl (%edx),%edx
  80109e:	29 d0                	sub    %edx,%eax
  8010a0:	eb 05                	jmp    8010a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8010a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010a7:	5b                   	pop    %ebx
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8010b4:	eb 07                	jmp    8010bd <strchr+0x13>
		if (*s == c)
  8010b6:	38 ca                	cmp    %cl,%dl
  8010b8:	74 0f                	je     8010c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8010ba:	83 c0 01             	add    $0x1,%eax
  8010bd:	0f b6 10             	movzbl (%eax),%edx
  8010c0:	84 d2                	test   %dl,%dl
  8010c2:	75 f2                	jne    8010b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8010c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8010d5:	eb 07                	jmp    8010de <strfind+0x13>
		if (*s == c)
  8010d7:	38 ca                	cmp    %cl,%dl
  8010d9:	74 0a                	je     8010e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010db:	83 c0 01             	add    $0x1,%eax
  8010de:	0f b6 10             	movzbl (%eax),%edx
  8010e1:	84 d2                	test   %dl,%dl
  8010e3:	75 f2                	jne    8010d7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	57                   	push   %edi
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010f3:	85 c9                	test   %ecx,%ecx
  8010f5:	74 36                	je     80112d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8010f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8010fd:	75 28                	jne    801127 <memset+0x40>
  8010ff:	f6 c1 03             	test   $0x3,%cl
  801102:	75 23                	jne    801127 <memset+0x40>
		c &= 0xFF;
  801104:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801108:	89 d3                	mov    %edx,%ebx
  80110a:	c1 e3 08             	shl    $0x8,%ebx
  80110d:	89 d6                	mov    %edx,%esi
  80110f:	c1 e6 18             	shl    $0x18,%esi
  801112:	89 d0                	mov    %edx,%eax
  801114:	c1 e0 10             	shl    $0x10,%eax
  801117:	09 f0                	or     %esi,%eax
  801119:	09 c2                	or     %eax,%edx
  80111b:	89 d0                	mov    %edx,%eax
  80111d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80111f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801122:	fc                   	cld    
  801123:	f3 ab                	rep stos %eax,%es:(%edi)
  801125:	eb 06                	jmp    80112d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801127:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112a:	fc                   	cld    
  80112b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80112d:	89 f8                	mov    %edi,%eax
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80113f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801142:	39 c6                	cmp    %eax,%esi
  801144:	73 35                	jae    80117b <memmove+0x47>
  801146:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801149:	39 d0                	cmp    %edx,%eax
  80114b:	73 2e                	jae    80117b <memmove+0x47>
		s += n;
		d += n;
  80114d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801150:	89 d6                	mov    %edx,%esi
  801152:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801154:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80115a:	75 13                	jne    80116f <memmove+0x3b>
  80115c:	f6 c1 03             	test   $0x3,%cl
  80115f:	75 0e                	jne    80116f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801161:	83 ef 04             	sub    $0x4,%edi
  801164:	8d 72 fc             	lea    -0x4(%edx),%esi
  801167:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80116a:	fd                   	std    
  80116b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80116d:	eb 09                	jmp    801178 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80116f:	83 ef 01             	sub    $0x1,%edi
  801172:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801175:	fd                   	std    
  801176:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801178:	fc                   	cld    
  801179:	eb 1d                	jmp    801198 <memmove+0x64>
  80117b:	89 f2                	mov    %esi,%edx
  80117d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80117f:	f6 c2 03             	test   $0x3,%dl
  801182:	75 0f                	jne    801193 <memmove+0x5f>
  801184:	f6 c1 03             	test   $0x3,%cl
  801187:	75 0a                	jne    801193 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801189:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80118c:	89 c7                	mov    %eax,%edi
  80118e:	fc                   	cld    
  80118f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801191:	eb 05                	jmp    801198 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801193:	89 c7                	mov    %eax,%edi
  801195:	fc                   	cld    
  801196:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b3:	89 04 24             	mov    %eax,(%esp)
  8011b6:	e8 79 ff ff ff       	call   801134 <memmove>
}
  8011bb:	c9                   	leave  
  8011bc:	c3                   	ret    

008011bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	56                   	push   %esi
  8011c1:	53                   	push   %ebx
  8011c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c8:	89 d6                	mov    %edx,%esi
  8011ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011cd:	eb 1a                	jmp    8011e9 <memcmp+0x2c>
		if (*s1 != *s2)
  8011cf:	0f b6 02             	movzbl (%edx),%eax
  8011d2:	0f b6 19             	movzbl (%ecx),%ebx
  8011d5:	38 d8                	cmp    %bl,%al
  8011d7:	74 0a                	je     8011e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8011d9:	0f b6 c0             	movzbl %al,%eax
  8011dc:	0f b6 db             	movzbl %bl,%ebx
  8011df:	29 d8                	sub    %ebx,%eax
  8011e1:	eb 0f                	jmp    8011f2 <memcmp+0x35>
		s1++, s2++;
  8011e3:	83 c2 01             	add    $0x1,%edx
  8011e6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011e9:	39 f2                	cmp    %esi,%edx
  8011eb:	75 e2                	jne    8011cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801204:	eb 07                	jmp    80120d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801206:	38 08                	cmp    %cl,(%eax)
  801208:	74 07                	je     801211 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80120a:	83 c0 01             	add    $0x1,%eax
  80120d:	39 d0                	cmp    %edx,%eax
  80120f:	72 f5                	jb     801206 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	57                   	push   %edi
  801217:	56                   	push   %esi
  801218:	53                   	push   %ebx
  801219:	8b 55 08             	mov    0x8(%ebp),%edx
  80121c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80121f:	eb 03                	jmp    801224 <strtol+0x11>
		s++;
  801221:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801224:	0f b6 0a             	movzbl (%edx),%ecx
  801227:	80 f9 09             	cmp    $0x9,%cl
  80122a:	74 f5                	je     801221 <strtol+0xe>
  80122c:	80 f9 20             	cmp    $0x20,%cl
  80122f:	74 f0                	je     801221 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801231:	80 f9 2b             	cmp    $0x2b,%cl
  801234:	75 0a                	jne    801240 <strtol+0x2d>
		s++;
  801236:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801239:	bf 00 00 00 00       	mov    $0x0,%edi
  80123e:	eb 11                	jmp    801251 <strtol+0x3e>
  801240:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801245:	80 f9 2d             	cmp    $0x2d,%cl
  801248:	75 07                	jne    801251 <strtol+0x3e>
		s++, neg = 1;
  80124a:	8d 52 01             	lea    0x1(%edx),%edx
  80124d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801251:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801256:	75 15                	jne    80126d <strtol+0x5a>
  801258:	80 3a 30             	cmpb   $0x30,(%edx)
  80125b:	75 10                	jne    80126d <strtol+0x5a>
  80125d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801261:	75 0a                	jne    80126d <strtol+0x5a>
		s += 2, base = 16;
  801263:	83 c2 02             	add    $0x2,%edx
  801266:	b8 10 00 00 00       	mov    $0x10,%eax
  80126b:	eb 10                	jmp    80127d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80126d:	85 c0                	test   %eax,%eax
  80126f:	75 0c                	jne    80127d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801271:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801273:	80 3a 30             	cmpb   $0x30,(%edx)
  801276:	75 05                	jne    80127d <strtol+0x6a>
		s++, base = 8;
  801278:	83 c2 01             	add    $0x1,%edx
  80127b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80127d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801282:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801285:	0f b6 0a             	movzbl (%edx),%ecx
  801288:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80128b:	89 f0                	mov    %esi,%eax
  80128d:	3c 09                	cmp    $0x9,%al
  80128f:	77 08                	ja     801299 <strtol+0x86>
			dig = *s - '0';
  801291:	0f be c9             	movsbl %cl,%ecx
  801294:	83 e9 30             	sub    $0x30,%ecx
  801297:	eb 20                	jmp    8012b9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801299:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80129c:	89 f0                	mov    %esi,%eax
  80129e:	3c 19                	cmp    $0x19,%al
  8012a0:	77 08                	ja     8012aa <strtol+0x97>
			dig = *s - 'a' + 10;
  8012a2:	0f be c9             	movsbl %cl,%ecx
  8012a5:	83 e9 57             	sub    $0x57,%ecx
  8012a8:	eb 0f                	jmp    8012b9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8012aa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8012ad:	89 f0                	mov    %esi,%eax
  8012af:	3c 19                	cmp    $0x19,%al
  8012b1:	77 16                	ja     8012c9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8012b3:	0f be c9             	movsbl %cl,%ecx
  8012b6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8012b9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8012bc:	7d 0f                	jge    8012cd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8012be:	83 c2 01             	add    $0x1,%edx
  8012c1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8012c5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8012c7:	eb bc                	jmp    801285 <strtol+0x72>
  8012c9:	89 d8                	mov    %ebx,%eax
  8012cb:	eb 02                	jmp    8012cf <strtol+0xbc>
  8012cd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8012cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012d3:	74 05                	je     8012da <strtol+0xc7>
		*endptr = (char *) s;
  8012d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012d8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8012da:	f7 d8                	neg    %eax
  8012dc:	85 ff                	test   %edi,%edi
  8012de:	0f 44 c3             	cmove  %ebx,%eax
}
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    
  8012e6:	66 90                	xchg   %ax,%ax
  8012e8:	66 90                	xchg   %ax,%ax
  8012ea:	66 90                	xchg   %ax,%ax
  8012ec:	66 90                	xchg   %ax,%ax
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <__udivdi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	83 ec 0c             	sub    $0xc,%esp
  8012f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801302:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801306:	85 c0                	test   %eax,%eax
  801308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80130c:	89 ea                	mov    %ebp,%edx
  80130e:	89 0c 24             	mov    %ecx,(%esp)
  801311:	75 2d                	jne    801340 <__udivdi3+0x50>
  801313:	39 e9                	cmp    %ebp,%ecx
  801315:	77 61                	ja     801378 <__udivdi3+0x88>
  801317:	85 c9                	test   %ecx,%ecx
  801319:	89 ce                	mov    %ecx,%esi
  80131b:	75 0b                	jne    801328 <__udivdi3+0x38>
  80131d:	b8 01 00 00 00       	mov    $0x1,%eax
  801322:	31 d2                	xor    %edx,%edx
  801324:	f7 f1                	div    %ecx
  801326:	89 c6                	mov    %eax,%esi
  801328:	31 d2                	xor    %edx,%edx
  80132a:	89 e8                	mov    %ebp,%eax
  80132c:	f7 f6                	div    %esi
  80132e:	89 c5                	mov    %eax,%ebp
  801330:	89 f8                	mov    %edi,%eax
  801332:	f7 f6                	div    %esi
  801334:	89 ea                	mov    %ebp,%edx
  801336:	83 c4 0c             	add    $0xc,%esp
  801339:	5e                   	pop    %esi
  80133a:	5f                   	pop    %edi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    
  80133d:	8d 76 00             	lea    0x0(%esi),%esi
  801340:	39 e8                	cmp    %ebp,%eax
  801342:	77 24                	ja     801368 <__udivdi3+0x78>
  801344:	0f bd e8             	bsr    %eax,%ebp
  801347:	83 f5 1f             	xor    $0x1f,%ebp
  80134a:	75 3c                	jne    801388 <__udivdi3+0x98>
  80134c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801350:	39 34 24             	cmp    %esi,(%esp)
  801353:	0f 86 9f 00 00 00    	jbe    8013f8 <__udivdi3+0x108>
  801359:	39 d0                	cmp    %edx,%eax
  80135b:	0f 82 97 00 00 00    	jb     8013f8 <__udivdi3+0x108>
  801361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801368:	31 d2                	xor    %edx,%edx
  80136a:	31 c0                	xor    %eax,%eax
  80136c:	83 c4 0c             	add    $0xc,%esp
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    
  801373:	90                   	nop
  801374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801378:	89 f8                	mov    %edi,%eax
  80137a:	f7 f1                	div    %ecx
  80137c:	31 d2                	xor    %edx,%edx
  80137e:	83 c4 0c             	add    $0xc,%esp
  801381:	5e                   	pop    %esi
  801382:	5f                   	pop    %edi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    
  801385:	8d 76 00             	lea    0x0(%esi),%esi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	8b 3c 24             	mov    (%esp),%edi
  80138d:	d3 e0                	shl    %cl,%eax
  80138f:	89 c6                	mov    %eax,%esi
  801391:	b8 20 00 00 00       	mov    $0x20,%eax
  801396:	29 e8                	sub    %ebp,%eax
  801398:	89 c1                	mov    %eax,%ecx
  80139a:	d3 ef                	shr    %cl,%edi
  80139c:	89 e9                	mov    %ebp,%ecx
  80139e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013a2:	8b 3c 24             	mov    (%esp),%edi
  8013a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013a9:	89 d6                	mov    %edx,%esi
  8013ab:	d3 e7                	shl    %cl,%edi
  8013ad:	89 c1                	mov    %eax,%ecx
  8013af:	89 3c 24             	mov    %edi,(%esp)
  8013b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b6:	d3 ee                	shr    %cl,%esi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	d3 e2                	shl    %cl,%edx
  8013bc:	89 c1                	mov    %eax,%ecx
  8013be:	d3 ef                	shr    %cl,%edi
  8013c0:	09 d7                	or     %edx,%edi
  8013c2:	89 f2                	mov    %esi,%edx
  8013c4:	89 f8                	mov    %edi,%eax
  8013c6:	f7 74 24 08          	divl   0x8(%esp)
  8013ca:	89 d6                	mov    %edx,%esi
  8013cc:	89 c7                	mov    %eax,%edi
  8013ce:	f7 24 24             	mull   (%esp)
  8013d1:	39 d6                	cmp    %edx,%esi
  8013d3:	89 14 24             	mov    %edx,(%esp)
  8013d6:	72 30                	jb     801408 <__udivdi3+0x118>
  8013d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013dc:	89 e9                	mov    %ebp,%ecx
  8013de:	d3 e2                	shl    %cl,%edx
  8013e0:	39 c2                	cmp    %eax,%edx
  8013e2:	73 05                	jae    8013e9 <__udivdi3+0xf9>
  8013e4:	3b 34 24             	cmp    (%esp),%esi
  8013e7:	74 1f                	je     801408 <__udivdi3+0x118>
  8013e9:	89 f8                	mov    %edi,%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	e9 7a ff ff ff       	jmp    80136c <__udivdi3+0x7c>
  8013f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013f8:	31 d2                	xor    %edx,%edx
  8013fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ff:	e9 68 ff ff ff       	jmp    80136c <__udivdi3+0x7c>
  801404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801408:	8d 47 ff             	lea    -0x1(%edi),%eax
  80140b:	31 d2                	xor    %edx,%edx
  80140d:	83 c4 0c             	add    $0xc,%esp
  801410:	5e                   	pop    %esi
  801411:	5f                   	pop    %edi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    
  801414:	66 90                	xchg   %ax,%ax
  801416:	66 90                	xchg   %ax,%ax
  801418:	66 90                	xchg   %ax,%ax
  80141a:	66 90                	xchg   %ax,%ax
  80141c:	66 90                	xchg   %ax,%ax
  80141e:	66 90                	xchg   %ax,%ax

00801420 <__umoddi3>:
  801420:	55                   	push   %ebp
  801421:	57                   	push   %edi
  801422:	56                   	push   %esi
  801423:	83 ec 14             	sub    $0x14,%esp
  801426:	8b 44 24 28          	mov    0x28(%esp),%eax
  80142a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80142e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801432:	89 c7                	mov    %eax,%edi
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	8b 44 24 30          	mov    0x30(%esp),%eax
  80143c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801440:	89 34 24             	mov    %esi,(%esp)
  801443:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801447:	85 c0                	test   %eax,%eax
  801449:	89 c2                	mov    %eax,%edx
  80144b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80144f:	75 17                	jne    801468 <__umoddi3+0x48>
  801451:	39 fe                	cmp    %edi,%esi
  801453:	76 4b                	jbe    8014a0 <__umoddi3+0x80>
  801455:	89 c8                	mov    %ecx,%eax
  801457:	89 fa                	mov    %edi,%edx
  801459:	f7 f6                	div    %esi
  80145b:	89 d0                	mov    %edx,%eax
  80145d:	31 d2                	xor    %edx,%edx
  80145f:	83 c4 14             	add    $0x14,%esp
  801462:	5e                   	pop    %esi
  801463:	5f                   	pop    %edi
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    
  801466:	66 90                	xchg   %ax,%ax
  801468:	39 f8                	cmp    %edi,%eax
  80146a:	77 54                	ja     8014c0 <__umoddi3+0xa0>
  80146c:	0f bd e8             	bsr    %eax,%ebp
  80146f:	83 f5 1f             	xor    $0x1f,%ebp
  801472:	75 5c                	jne    8014d0 <__umoddi3+0xb0>
  801474:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801478:	39 3c 24             	cmp    %edi,(%esp)
  80147b:	0f 87 e7 00 00 00    	ja     801568 <__umoddi3+0x148>
  801481:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801485:	29 f1                	sub    %esi,%ecx
  801487:	19 c7                	sbb    %eax,%edi
  801489:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80148d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801491:	8b 44 24 08          	mov    0x8(%esp),%eax
  801495:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801499:	83 c4 14             	add    $0x14,%esp
  80149c:	5e                   	pop    %esi
  80149d:	5f                   	pop    %edi
  80149e:	5d                   	pop    %ebp
  80149f:	c3                   	ret    
  8014a0:	85 f6                	test   %esi,%esi
  8014a2:	89 f5                	mov    %esi,%ebp
  8014a4:	75 0b                	jne    8014b1 <__umoddi3+0x91>
  8014a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ab:	31 d2                	xor    %edx,%edx
  8014ad:	f7 f6                	div    %esi
  8014af:	89 c5                	mov    %eax,%ebp
  8014b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014b5:	31 d2                	xor    %edx,%edx
  8014b7:	f7 f5                	div    %ebp
  8014b9:	89 c8                	mov    %ecx,%eax
  8014bb:	f7 f5                	div    %ebp
  8014bd:	eb 9c                	jmp    80145b <__umoddi3+0x3b>
  8014bf:	90                   	nop
  8014c0:	89 c8                	mov    %ecx,%eax
  8014c2:	89 fa                	mov    %edi,%edx
  8014c4:	83 c4 14             	add    $0x14,%esp
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    
  8014cb:	90                   	nop
  8014cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d0:	8b 04 24             	mov    (%esp),%eax
  8014d3:	be 20 00 00 00       	mov    $0x20,%esi
  8014d8:	89 e9                	mov    %ebp,%ecx
  8014da:	29 ee                	sub    %ebp,%esi
  8014dc:	d3 e2                	shl    %cl,%edx
  8014de:	89 f1                	mov    %esi,%ecx
  8014e0:	d3 e8                	shr    %cl,%eax
  8014e2:	89 e9                	mov    %ebp,%ecx
  8014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e8:	8b 04 24             	mov    (%esp),%eax
  8014eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8014ef:	89 fa                	mov    %edi,%edx
  8014f1:	d3 e0                	shl    %cl,%eax
  8014f3:	89 f1                	mov    %esi,%ecx
  8014f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8014fd:	d3 ea                	shr    %cl,%edx
  8014ff:	89 e9                	mov    %ebp,%ecx
  801501:	d3 e7                	shl    %cl,%edi
  801503:	89 f1                	mov    %esi,%ecx
  801505:	d3 e8                	shr    %cl,%eax
  801507:	89 e9                	mov    %ebp,%ecx
  801509:	09 f8                	or     %edi,%eax
  80150b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80150f:	f7 74 24 04          	divl   0x4(%esp)
  801513:	d3 e7                	shl    %cl,%edi
  801515:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801519:	89 d7                	mov    %edx,%edi
  80151b:	f7 64 24 08          	mull   0x8(%esp)
  80151f:	39 d7                	cmp    %edx,%edi
  801521:	89 c1                	mov    %eax,%ecx
  801523:	89 14 24             	mov    %edx,(%esp)
  801526:	72 2c                	jb     801554 <__umoddi3+0x134>
  801528:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80152c:	72 22                	jb     801550 <__umoddi3+0x130>
  80152e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801532:	29 c8                	sub    %ecx,%eax
  801534:	19 d7                	sbb    %edx,%edi
  801536:	89 e9                	mov    %ebp,%ecx
  801538:	89 fa                	mov    %edi,%edx
  80153a:	d3 e8                	shr    %cl,%eax
  80153c:	89 f1                	mov    %esi,%ecx
  80153e:	d3 e2                	shl    %cl,%edx
  801540:	89 e9                	mov    %ebp,%ecx
  801542:	d3 ef                	shr    %cl,%edi
  801544:	09 d0                	or     %edx,%eax
  801546:	89 fa                	mov    %edi,%edx
  801548:	83 c4 14             	add    $0x14,%esp
  80154b:	5e                   	pop    %esi
  80154c:	5f                   	pop    %edi
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    
  80154f:	90                   	nop
  801550:	39 d7                	cmp    %edx,%edi
  801552:	75 da                	jne    80152e <__umoddi3+0x10e>
  801554:	8b 14 24             	mov    (%esp),%edx
  801557:	89 c1                	mov    %eax,%ecx
  801559:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80155d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801561:	eb cb                	jmp    80152e <__umoddi3+0x10e>
  801563:	90                   	nop
  801564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801568:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80156c:	0f 82 0f ff ff ff    	jb     801481 <__umoddi3+0x61>
  801572:	e9 1a ff ff ff       	jmp    801491 <__umoddi3+0x71>
