
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:

.section .text.init
.globl _start
.globl _end
_start:
  la sp, boot_stack_top
ffffffe000200000:	00005117          	auipc	sp,0x5
ffffffe000200004:	02010113          	addi	sp,sp,32 # ffffffe000205020 <task>

  li t0, 0x5000000
ffffffe000200008:	050002b7          	lui	t0,0x5000
  li t1, 1
ffffffe00020000c:	00100313          	li	t1,1
  sb t1, 0(t0) # enable icache
ffffffe000200010:	00628023          	sb	t1,0(t0) # 5000000 <_skernel-0xffffffdffb200000>
  sb t1, 8(t0) # enable dcache
ffffffe000200014:	00628423          	sb	t1,8(t0)

  call setup_vm
ffffffe000200018:	3a5000ef          	jal	ra,ffffffe000200bbc <setup_vm>
  call relocate
ffffffe00020001c:	068000ef          	jal	ra,ffffffe000200084 <relocate>

  la t0, _traps
ffffffe000200020:	00000297          	auipc	t0,0x0
ffffffe000200024:	12028293          	addi	t0,t0,288 # ffffffe000200140 <_traps>
  csrw stvec, t0
ffffffe000200028:	10529073          	csrw	stvec,t0
  csrr t0, sie
ffffffe00020002c:	104022f3          	csrr	t0,sie
  ori t0, t0, 0x20
ffffffe000200030:	0202e293          	ori	t0,t0,32
  csrw sie, t0
ffffffe000200034:	10429073          	csrw	sie,t0
  
  rdtime a0
ffffffe000200038:	c0102573          	rdtime	a0
  # li t0, 5000000
  li t0,6000000
ffffffe00020003c:	005b92b7          	lui	t0,0x5b9
ffffffe000200040:	d802829b          	addiw	t0,t0,-640 # 5b8d80 <_skernel-0xffffffdfffc47280>
  add a0, a0, t0
ffffffe000200044:	00550533          	add	a0,a0,t0

  xor a7, a7, a7
ffffffe000200048:	0118c8b3          	xor	a7,a7,a7
  xor a6, a6, a6
ffffffe00020004c:	01084833          	xor	a6,a6,a6
  xor a5, a5, a5
ffffffe000200050:	00f7c7b3          	xor	a5,a5,a5
  xor a4, a4, a4
ffffffe000200054:	00e74733          	xor	a4,a4,a4
  xor a3, a3, a3
ffffffe000200058:	00d6c6b3          	xor	a3,a3,a3
  xor a2, a2, a2
ffffffe00020005c:	00c64633          	xor	a2,a2,a2
  xor a1, a1, a1
ffffffe000200060:	00b5c5b3          	xor	a1,a1,a1
  ecall
ffffffe000200064:	00000073          	ecall

  csrr t0, sstatus
ffffffe000200068:	100022f3          	csrr	t0,sstatus
  ori t0, t0, 1<<1
ffffffe00020006c:	0022e293          	ori	t0,t0,2
  csrw sstatus, t0
ffffffe000200070:	10029073          	csrw	sstatus,t0

  call mm_init
ffffffe000200074:	3ac000ef          	jal	ra,ffffffe000200420 <mm_init>
  call setup_vm_final
ffffffe000200078:	3e9000ef          	jal	ra,ffffffe000200c60 <setup_vm_final>
  call task_init
ffffffe00020007c:	3f8000ef          	jal	ra,ffffffe000200474 <task_init>

  j start_kernel
ffffffe000200080:	75d0006f          	j	ffffffe000200fdc <start_kernel>

ffffffe000200084 <relocate>:

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    li t0, 0xffffffdf80000000
ffffffe000200084:	fbf0029b          	addiw	t0,zero,-65
ffffffe000200088:	01f29293          	slli	t0,t0,0x1f
    add ra, ra, t0
ffffffe00020008c:	005080b3          	add	ra,ra,t0
    add sp, sp, t0
ffffffe000200090:	00510133          	add	sp,sp,t0

    # la t0, _trap_vm
    # csrw stvec, t0

    # set satp with early_pgtbl
    li t1, 1
ffffffe000200094:	00100313          	li	t1,1
    slli t1, t1, 63
ffffffe000200098:	03f31313          	slli	t1,t1,0x3f
    la t2, early_pgtbl
ffffffe00020009c:	00006397          	auipc	t2,0x6
ffffffe0002000a0:	f6438393          	addi	t2,t2,-156 # ffffffe000206000 <early_pgtbl>
    srli t2, t2, 12
ffffffe0002000a4:	00c3d393          	srli	t2,t2,0xc
    or t1, t1, t2
ffffffe0002000a8:	00736333          	or	t1,t1,t2
    csrw satp, t1
ffffffe0002000ac:	18031073          	csrw	satp,t1

    # flush tlb
    sfence.vma zero, zero
ffffffe0002000b0:	12000073          	sfence.vma

    # flush icache
    fence.i
ffffffe0002000b4:	0000100f          	fence.i

    ret
ffffffe0002000b8:	00008067          	ret

ffffffe0002000bc <__switch_to>:
    .globl __switch_to

__switch_to:
    # save state to prev process
    # YOUR CODE HERE
    sd ra, 40(a0)
ffffffe0002000bc:	02153423          	sd	ra,40(a0)
    sd sp, 48(a0)
ffffffe0002000c0:	02253823          	sd	sp,48(a0)
    sd s0, 56(a0)
ffffffe0002000c4:	02853c23          	sd	s0,56(a0)
    sd s1, 64(a0)
ffffffe0002000c8:	04953023          	sd	s1,64(a0)
    sd s2, 72(a0)
ffffffe0002000cc:	05253423          	sd	s2,72(a0)
    sd s3, 80(a0)
ffffffe0002000d0:	05353823          	sd	s3,80(a0)
    sd s4, 88(a0)
ffffffe0002000d4:	05453c23          	sd	s4,88(a0)
    sd s5, 96(a0)
ffffffe0002000d8:	07553023          	sd	s5,96(a0)
    sd s6, 104(a0)
ffffffe0002000dc:	07653423          	sd	s6,104(a0)
    sd s7, 112(a0)
ffffffe0002000e0:	07753823          	sd	s7,112(a0)
    sd s8, 120(a0)
ffffffe0002000e4:	07853c23          	sd	s8,120(a0)
    sd s9, 128(a0)
ffffffe0002000e8:	09953023          	sd	s9,128(a0)
    sd s10, 136(a0)
ffffffe0002000ec:	09a53423          	sd	s10,136(a0)
    sd s11, 144(a0)
ffffffe0002000f0:	09b53823          	sd	s11,144(a0)
    # restore state from next process
    # YOUR CODE HERE
    ld ra, 40(a1)
ffffffe0002000f4:	0285b083          	ld	ra,40(a1)
    ld sp, 48(a1)
ffffffe0002000f8:	0305b103          	ld	sp,48(a1)
    ld s0, 56(a1)
ffffffe0002000fc:	0385b403          	ld	s0,56(a1)
    ld s1, 64(a1)
ffffffe000200100:	0405b483          	ld	s1,64(a1)
    ld s2, 72(a1)
ffffffe000200104:	0485b903          	ld	s2,72(a1)
    ld s3, 80(a1)
ffffffe000200108:	0505b983          	ld	s3,80(a1)
    ld s4, 88(a1)
ffffffe00020010c:	0585ba03          	ld	s4,88(a1)
    ld s5, 96(a1)
ffffffe000200110:	0605ba83          	ld	s5,96(a1)
    ld s6, 104(a1)
ffffffe000200114:	0685bb03          	ld	s6,104(a1)
    ld s7, 112(a1)
ffffffe000200118:	0705bb83          	ld	s7,112(a1)
    ld s8, 120(a1)
ffffffe00020011c:	0785bc03          	ld	s8,120(a1)
    ld s9, 128(a1)
ffffffe000200120:	0805bc83          	ld	s9,128(a1)
    ld s10, 136(a1)
ffffffe000200124:	0885bd03          	ld	s10,136(a1)
    ld s11, 144(a1)
ffffffe000200128:	0905bd83          	ld	s11,144(a1)
    ret
ffffffe00020012c:	00008067          	ret

ffffffe000200130 <__dummy>:

__dummy:
    # YOUR CODE HERE
    la t0, dummy
ffffffe000200130:	00000297          	auipc	t0,0x0
ffffffe000200134:	4c028293          	addi	t0,t0,1216 # ffffffe0002005f0 <dummy>
    csrw sepc, t0
ffffffe000200138:	14129073          	csrw	sepc,t0
    sret
ffffffe00020013c:	10200073          	sret

ffffffe000200140 <_traps>:

_traps:

    # 1. save 32 registers and sepc to stack
    sd sp, -8(sp)
ffffffe000200140:	fe213c23          	sd	sp,-8(sp)

    sd ra, -16(sp)
ffffffe000200144:	fe113823          	sd	ra,-16(sp)
    sd gp, -24(sp)
ffffffe000200148:	fe313423          	sd	gp,-24(sp)
    sd tp, -32(sp)
ffffffe00020014c:	fe413023          	sd	tp,-32(sp)
    sd t0, -40(sp)
ffffffe000200150:	fc513c23          	sd	t0,-40(sp)
    sd t1, -48(sp)
ffffffe000200154:	fc613823          	sd	t1,-48(sp)
    sd t2, -56(sp)
ffffffe000200158:	fc713423          	sd	t2,-56(sp)
    sd t3, -64(sp)
ffffffe00020015c:	fdc13023          	sd	t3,-64(sp)
    sd t4, -72(sp)
ffffffe000200160:	fbd13c23          	sd	t4,-72(sp)
    sd t5, -80(sp)
ffffffe000200164:	fbe13823          	sd	t5,-80(sp)
    sd t6, -88(sp)
ffffffe000200168:	fbf13423          	sd	t6,-88(sp)
    sd fp, -96(sp)
ffffffe00020016c:	fa813023          	sd	s0,-96(sp)
    sd s1, -104(sp)
ffffffe000200170:	f8913c23          	sd	s1,-104(sp)
    sd a0, -112(sp)
ffffffe000200174:	f8a13823          	sd	a0,-112(sp)
    sd a1, -120(sp)
ffffffe000200178:	f8b13423          	sd	a1,-120(sp)
    sd a2, -128(sp)
ffffffe00020017c:	f8c13023          	sd	a2,-128(sp)
    sd a3, -136(sp)
ffffffe000200180:	f6d13c23          	sd	a3,-136(sp)
    sd a4, -144(sp)
ffffffe000200184:	f6e13823          	sd	a4,-144(sp)
    sd a5, -152(sp)
ffffffe000200188:	f6f13423          	sd	a5,-152(sp)
    sd a6, -160(sp)
ffffffe00020018c:	f7013023          	sd	a6,-160(sp)
    sd a7, -168(sp)
ffffffe000200190:	f5113c23          	sd	a7,-168(sp)
    sd s2, -176(sp)
ffffffe000200194:	f5213823          	sd	s2,-176(sp)
    sd s3, -184(sp)
ffffffe000200198:	f5313423          	sd	s3,-184(sp)
    sd s4, -192(sp)
ffffffe00020019c:	f5413023          	sd	s4,-192(sp)
    sd s5, -200(sp)
ffffffe0002001a0:	f3513c23          	sd	s5,-200(sp)
    sd s6, -208(sp)
ffffffe0002001a4:	f3613823          	sd	s6,-208(sp)
    sd s7, -216(sp)
ffffffe0002001a8:	f3713423          	sd	s7,-216(sp)
    sd s8, -224(sp)
ffffffe0002001ac:	f3813023          	sd	s8,-224(sp)
    sd s9, -232(sp)
ffffffe0002001b0:	f1913c23          	sd	s9,-232(sp)
    sd s10, -240(sp)
ffffffe0002001b4:	f1a13823          	sd	s10,-240(sp)
    sd s11, -248(sp)
ffffffe0002001b8:	f1b13423          	sd	s11,-248(sp)

    csrr a0, sepc
ffffffe0002001bc:	14102573          	csrr	a0,sepc
    sd a0, -256(sp)
ffffffe0002001c0:	f0a13023          	sd	a0,-256(sp)
    addi sp, sp, -256
ffffffe0002001c4:	f0010113          	addi	sp,sp,-256
    # -----------
    # 2. call trap_handler
    csrr a0, scause
ffffffe0002001c8:	14202573          	csrr	a0,scause
    csrr a1, sepc
ffffffe0002001cc:	141025f3          	csrr	a1,sepc
    call trap_handler
ffffffe0002001d0:	179000ef          	jal	ra,ffffffe000200b48 <trap_handler>
    # -----------
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    ld a0, 0(sp)    #===
ffffffe0002001d4:	00013503          	ld	a0,0(sp)
    
    li t1, 0x8000000000000005
ffffffe0002001d8:	fff0031b          	addiw	t1,zero,-1
ffffffe0002001dc:	03f31313          	slli	t1,t1,0x3f
ffffffe0002001e0:	00530313          	addi	t1,t1,5
    csrr t0, scause
ffffffe0002001e4:	142022f3          	csrr	t0,scause
    beq t0, t1, _csrwrite
ffffffe0002001e8:	00628463          	beq	t0,t1,ffffffe0002001f0 <_csrwrite>
    addi a0, a0, 4
ffffffe0002001ec:	00450513          	addi	a0,a0,4

ffffffe0002001f0 <_csrwrite>:
_csrwrite:
    csrw sepc, a0   #===
ffffffe0002001f0:	14151073          	csrw	sepc,a0

    ld s11, 8(sp)
ffffffe0002001f4:	00813d83          	ld	s11,8(sp)
    ld s10, 16(sp)
ffffffe0002001f8:	01013d03          	ld	s10,16(sp)
    ld s9, 24(sp)
ffffffe0002001fc:	01813c83          	ld	s9,24(sp)
    ld s8, 32(sp)
ffffffe000200200:	02013c03          	ld	s8,32(sp)
    ld s7, 40(sp)
ffffffe000200204:	02813b83          	ld	s7,40(sp)
    ld s6, 48(sp)
ffffffe000200208:	03013b03          	ld	s6,48(sp)
    ld s5, 56(sp)
ffffffe00020020c:	03813a83          	ld	s5,56(sp)
    ld s4, 64(sp)
ffffffe000200210:	04013a03          	ld	s4,64(sp)
    ld s3, 72(sp)
ffffffe000200214:	04813983          	ld	s3,72(sp)
    ld s2, 80(sp)
ffffffe000200218:	05013903          	ld	s2,80(sp)
    ld a7, 88(sp)
ffffffe00020021c:	05813883          	ld	a7,88(sp)
    ld a6, 96(sp)
ffffffe000200220:	06013803          	ld	a6,96(sp)
    ld a5, 104(sp)
ffffffe000200224:	06813783          	ld	a5,104(sp)
    ld a4, 112(sp)
ffffffe000200228:	07013703          	ld	a4,112(sp)
    ld a3, 120(sp)
ffffffe00020022c:	07813683          	ld	a3,120(sp)
    ld a2, 128(sp)
ffffffe000200230:	08013603          	ld	a2,128(sp)
    ld a1, 136(sp)
ffffffe000200234:	08813583          	ld	a1,136(sp)
    ld a0, 144(sp)
ffffffe000200238:	09013503          	ld	a0,144(sp)
    ld s1, 152(sp)
ffffffe00020023c:	09813483          	ld	s1,152(sp)
    ld fp, 160(sp)
ffffffe000200240:	0a013403          	ld	s0,160(sp)
    ld t6, 168(sp)
ffffffe000200244:	0a813f83          	ld	t6,168(sp)
    ld t5, 176(sp)
ffffffe000200248:	0b013f03          	ld	t5,176(sp)
    ld t4, 184(sp)
ffffffe00020024c:	0b813e83          	ld	t4,184(sp)
    ld t3, 192(sp)
ffffffe000200250:	0c013e03          	ld	t3,192(sp)
    ld t2, 200(sp)
ffffffe000200254:	0c813383          	ld	t2,200(sp)
    ld t1, 208(sp)
ffffffe000200258:	0d013303          	ld	t1,208(sp)
    ld t0, 216(sp)
ffffffe00020025c:	0d813283          	ld	t0,216(sp)
    ld tp, 224(sp)
ffffffe000200260:	0e013203          	ld	tp,224(sp)
    ld gp, 232(sp)
ffffffe000200264:	0e813183          	ld	gp,232(sp)
    ld ra, 240(sp)
ffffffe000200268:	0f013083          	ld	ra,240(sp)
    ld sp, 248(sp)
ffffffe00020026c:	0f813103          	ld	sp,248(sp)
    # -----------
    # 4. return from trap
    sret
ffffffe000200270:	10200073          	sret

ffffffe000200274 <get_cycles>:
#include"sbi.h"


unsigned long TIMECLOCK = 3500000;

unsigned long get_cycles() {
ffffffe000200274:	fe010113          	addi	sp,sp,-32
ffffffe000200278:	00813c23          	sd	s0,24(sp)
ffffffe00020027c:	02010413          	addi	s0,sp,32
    unsigned long timer;
    __asm__ volatile(
ffffffe000200280:	c01027f3          	rdtime	a5
ffffffe000200284:	fef43423          	sd	a5,-24(s0)
        "rdtime %[timer]\n"
        :[timer]"=r"(timer)
        :
        :"memory"
    );
    return timer;
ffffffe000200288:	fe843783          	ld	a5,-24(s0)
}
ffffffe00020028c:	00078513          	mv	a0,a5
ffffffe000200290:	01813403          	ld	s0,24(sp)
ffffffe000200294:	02010113          	addi	sp,sp,32
ffffffe000200298:	00008067          	ret

ffffffe00020029c <clock_set_next_event>:

void clock_set_next_event() {
ffffffe00020029c:	fe010113          	addi	sp,sp,-32
ffffffe0002002a0:	00113c23          	sd	ra,24(sp)
ffffffe0002002a4:	00813823          	sd	s0,16(sp)
ffffffe0002002a8:	02010413          	addi	s0,sp,32
    // sbi_set_timer(TIMECLOCK);
    
    // 下一次 时钟中断 的时间点
    unsigned long next = get_cycles() + TIMECLOCK;
ffffffe0002002ac:	fc9ff0ef          	jal	ra,ffffffe000200274 <get_cycles>
ffffffe0002002b0:	00050713          	mv	a4,a0
ffffffe0002002b4:	00003797          	auipc	a5,0x3
ffffffe0002002b8:	d4c78793          	addi	a5,a5,-692 # ffffffe000203000 <TIMECLOCK>
ffffffe0002002bc:	0007b783          	ld	a5,0(a5)
ffffffe0002002c0:	00f707b3          	add	a5,a4,a5
ffffffe0002002c4:	fef43423          	sd	a5,-24(s0)
    // 使用 sbi_ecall 来完成对下一次时钟中断的设置
    sbi_ecall(0x00, 0, next, 0, 0, 0, 0, 0);
ffffffe0002002c8:	00000893          	li	a7,0
ffffffe0002002cc:	00000813          	li	a6,0
ffffffe0002002d0:	00000793          	li	a5,0
ffffffe0002002d4:	00000713          	li	a4,0
ffffffe0002002d8:	00000693          	li	a3,0
ffffffe0002002dc:	fe843603          	ld	a2,-24(s0)
ffffffe0002002e0:	00000593          	li	a1,0
ffffffe0002002e4:	00000513          	li	a0,0
ffffffe0002002e8:	770000ef          	jal	ra,ffffffe000200a58 <sbi_ecall>
} 
ffffffe0002002ec:	00000013          	nop
ffffffe0002002f0:	01813083          	ld	ra,24(sp)
ffffffe0002002f4:	01013403          	ld	s0,16(sp)
ffffffe0002002f8:	02010113          	addi	sp,sp,32
ffffffe0002002fc:	00008067          	ret

ffffffe000200300 <kalloc>:

struct {
    struct run *freelist;
} kmem;

uint64 kalloc() {
ffffffe000200300:	fe010113          	addi	sp,sp,-32
ffffffe000200304:	00813c23          	sd	s0,24(sp)
ffffffe000200308:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
ffffffe00020030c:	00004797          	auipc	a5,0x4
ffffffe000200310:	cf478793          	addi	a5,a5,-780 # ffffffe000204000 <kmem>
ffffffe000200314:	0007b783          	ld	a5,0(a5)
ffffffe000200318:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
ffffffe00020031c:	fe843783          	ld	a5,-24(s0)
ffffffe000200320:	0007b703          	ld	a4,0(a5)
ffffffe000200324:	00004797          	auipc	a5,0x4
ffffffe000200328:	cdc78793          	addi	a5,a5,-804 # ffffffe000204000 <kmem>
ffffffe00020032c:	00e7b023          	sd	a4,0(a5)
    
    // memset((void *)r, 0x0, PGSIZE);
    return (uint64) r;
ffffffe000200330:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200334:	00078513          	mv	a0,a5
ffffffe000200338:	01813403          	ld	s0,24(sp)
ffffffe00020033c:	02010113          	addi	sp,sp,32
ffffffe000200340:	00008067          	ret

ffffffe000200344 <kfree>:

void kfree(uint64 addr) {
ffffffe000200344:	fd010113          	addi	sp,sp,-48
ffffffe000200348:	02813423          	sd	s0,40(sp)
ffffffe00020034c:	03010413          	addi	s0,sp,48
ffffffe000200350:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    addr = addr & ~(PGSIZE - 1);
ffffffe000200354:	fd843703          	ld	a4,-40(s0)
ffffffe000200358:	fffff7b7          	lui	a5,0xfffff
ffffffe00020035c:	00f777b3          	and	a5,a4,a5
ffffffe000200360:	fcf43c23          	sd	a5,-40(s0)

    // memset((void *)addr, 0x0, (uint64)PGSIZE);

    r = (struct run *)addr;
ffffffe000200364:	fd843783          	ld	a5,-40(s0)
ffffffe000200368:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
ffffffe00020036c:	00004797          	auipc	a5,0x4
ffffffe000200370:	c9478793          	addi	a5,a5,-876 # ffffffe000204000 <kmem>
ffffffe000200374:	0007b703          	ld	a4,0(a5)
ffffffe000200378:	fe843783          	ld	a5,-24(s0)
ffffffe00020037c:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
ffffffe000200380:	00004797          	auipc	a5,0x4
ffffffe000200384:	c8078793          	addi	a5,a5,-896 # ffffffe000204000 <kmem>
ffffffe000200388:	fe843703          	ld	a4,-24(s0)
ffffffe00020038c:	00e7b023          	sd	a4,0(a5)

    return ;
ffffffe000200390:	00000013          	nop
}
ffffffe000200394:	02813403          	ld	s0,40(sp)
ffffffe000200398:	03010113          	addi	sp,sp,48
ffffffe00020039c:	00008067          	ret

ffffffe0002003a0 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe0002003a0:	fd010113          	addi	sp,sp,-48
ffffffe0002003a4:	02113423          	sd	ra,40(sp)
ffffffe0002003a8:	02813023          	sd	s0,32(sp)
ffffffe0002003ac:	03010413          	addi	s0,sp,48
ffffffe0002003b0:	fca43c23          	sd	a0,-40(s0)
ffffffe0002003b4:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uint64)start);
ffffffe0002003b8:	fd843703          	ld	a4,-40(s0)
ffffffe0002003bc:	000017b7          	lui	a5,0x1
ffffffe0002003c0:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0xffffffe0001ff001>
ffffffe0002003c4:	00f70733          	add	a4,a4,a5
ffffffe0002003c8:	fffff7b7          	lui	a5,0xfffff
ffffffe0002003cc:	00f777b3          	and	a5,a4,a5
ffffffe0002003d0:	fef43423          	sd	a5,-24(s0)
    for (; (uint64)(addr) + PGSIZE <= (uint64)end; addr += PGSIZE) {
ffffffe0002003d4:	0200006f          	j	ffffffe0002003f4 <kfreerange+0x54>
        kfree((uint64)addr);
ffffffe0002003d8:	fe843783          	ld	a5,-24(s0)
ffffffe0002003dc:	00078513          	mv	a0,a5
ffffffe0002003e0:	f65ff0ef          	jal	ra,ffffffe000200344 <kfree>
    for (; (uint64)(addr) + PGSIZE <= (uint64)end; addr += PGSIZE) {
ffffffe0002003e4:	fe843703          	ld	a4,-24(s0)
ffffffe0002003e8:	000017b7          	lui	a5,0x1
ffffffe0002003ec:	00f707b3          	add	a5,a4,a5
ffffffe0002003f0:	fef43423          	sd	a5,-24(s0)
ffffffe0002003f4:	fe843703          	ld	a4,-24(s0)
ffffffe0002003f8:	000017b7          	lui	a5,0x1
ffffffe0002003fc:	00f70733          	add	a4,a4,a5
ffffffe000200400:	fd043783          	ld	a5,-48(s0)
ffffffe000200404:	fce7fae3          	bgeu	a5,a4,ffffffe0002003d8 <kfreerange+0x38>
    }
}
ffffffe000200408:	00000013          	nop
ffffffe00020040c:	00000013          	nop
ffffffe000200410:	02813083          	ld	ra,40(sp)
ffffffe000200414:	02013403          	ld	s0,32(sp)
ffffffe000200418:	03010113          	addi	sp,sp,48
ffffffe00020041c:	00008067          	ret

ffffffe000200420 <mm_init>:

void mm_init(void) {
ffffffe000200420:	ff010113          	addi	sp,sp,-16
ffffffe000200424:	00113423          	sd	ra,8(sp)
ffffffe000200428:	00813023          	sd	s0,0(sp)
ffffffe00020042c:	01010413          	addi	s0,sp,16
    // kfreerange(_end, 0x0000000080210000);
    printk("mm_init in\n");
ffffffe000200430:	00002517          	auipc	a0,0x2
ffffffe000200434:	bd050513          	addi	a0,a0,-1072 # ffffffe000202000 <_srodata>
ffffffe000200438:	464010ef          	jal	ra,ffffffe00020189c <printk>
    kfreerange(_end, (char *)(PHY_END+PA2VA_OFFSET));
ffffffe00020043c:	ffe007b7          	lui	a5,0xffe00
ffffffe000200440:	02178793          	addi	a5,a5,33 # ffffffffffe00021 <_ekernel+0x1fffbf7021>
ffffffe000200444:	01079593          	slli	a1,a5,0x10
ffffffe000200448:	00005517          	auipc	a0,0x5
ffffffe00020044c:	bd850513          	addi	a0,a0,-1064 # ffffffe000205020 <task>
ffffffe000200450:	f51ff0ef          	jal	ra,ffffffe0002003a0 <kfreerange>
    printk("...mm_init\n");
ffffffe000200454:	00002517          	auipc	a0,0x2
ffffffe000200458:	bbc50513          	addi	a0,a0,-1092 # ffffffe000202010 <_srodata+0x10>
ffffffe00020045c:	440010ef          	jal	ra,ffffffe00020189c <printk>
}
ffffffe000200460:	00000013          	nop
ffffffe000200464:	00813083          	ld	ra,8(sp)
ffffffe000200468:	00013403          	ld	s0,0(sp)
ffffffe00020046c:	01010113          	addi	sp,sp,16
ffffffe000200470:	00008067          	ret

ffffffe000200474 <task_init>:

struct task_struct* idle;           // idle process
struct task_struct* current;        // 指向当前运行线程的 `task_struct`
struct task_struct* task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init() {
ffffffe000200474:	fe010113          	addi	sp,sp,-32
ffffffe000200478:	00113c23          	sd	ra,24(sp)
ffffffe00020047c:	00813823          	sd	s0,16(sp)
ffffffe000200480:	02010413          	addi	s0,sp,32
    // 1. 调用 kalloc() 为 idle 分配一个物理页
    // 2. 设置 state 为 TASK_RUNNING;
    // 3. 由于 idle 不参与调度 可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle
    printk("task_init in\n");
ffffffe000200484:	00002517          	auipc	a0,0x2
ffffffe000200488:	b9c50513          	addi	a0,a0,-1124 # ffffffe000202020 <_srodata+0x20>
ffffffe00020048c:	410010ef          	jal	ra,ffffffe00020189c <printk>
    idle = (struct task_struct*) kalloc();
ffffffe000200490:	e71ff0ef          	jal	ra,ffffffe000200300 <kalloc>
ffffffe000200494:	00050793          	mv	a5,a0
ffffffe000200498:	00078713          	mv	a4,a5
ffffffe00020049c:	00004797          	auipc	a5,0x4
ffffffe0002004a0:	b6c78793          	addi	a5,a5,-1172 # ffffffe000204008 <idle>
ffffffe0002004a4:	00e7b023          	sd	a4,0(a5)
    idle->state = TASK_RUNNING;
ffffffe0002004a8:	00004797          	auipc	a5,0x4
ffffffe0002004ac:	b6078793          	addi	a5,a5,-1184 # ffffffe000204008 <idle>
ffffffe0002004b0:	0007b783          	ld	a5,0(a5)
ffffffe0002004b4:	0007b423          	sd	zero,8(a5)
    idle->counter = 0;
ffffffe0002004b8:	00004797          	auipc	a5,0x4
ffffffe0002004bc:	b5078793          	addi	a5,a5,-1200 # ffffffe000204008 <idle>
ffffffe0002004c0:	0007b783          	ld	a5,0(a5)
ffffffe0002004c4:	0007b823          	sd	zero,16(a5)
    idle->priority = 0;
ffffffe0002004c8:	00004797          	auipc	a5,0x4
ffffffe0002004cc:	b4078793          	addi	a5,a5,-1216 # ffffffe000204008 <idle>
ffffffe0002004d0:	0007b783          	ld	a5,0(a5)
ffffffe0002004d4:	0007bc23          	sd	zero,24(a5)
    idle->pid = 0;
ffffffe0002004d8:	00004797          	auipc	a5,0x4
ffffffe0002004dc:	b3078793          	addi	a5,a5,-1232 # ffffffe000204008 <idle>
ffffffe0002004e0:	0007b783          	ld	a5,0(a5)
ffffffe0002004e4:	0207b023          	sd	zero,32(a5)

    current = idle;
ffffffe0002004e8:	00004797          	auipc	a5,0x4
ffffffe0002004ec:	b2078793          	addi	a5,a5,-1248 # ffffffe000204008 <idle>
ffffffe0002004f0:	0007b703          	ld	a4,0(a5)
ffffffe0002004f4:	00004797          	auipc	a5,0x4
ffffffe0002004f8:	b1c78793          	addi	a5,a5,-1252 # ffffffe000204010 <current>
ffffffe0002004fc:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000200500:	00004797          	auipc	a5,0x4
ffffffe000200504:	b0878793          	addi	a5,a5,-1272 # ffffffe000204008 <idle>
ffffffe000200508:	0007b703          	ld	a4,0(a5)
ffffffe00020050c:	00005797          	auipc	a5,0x5
ffffffe000200510:	b1478793          	addi	a5,a5,-1260 # ffffffe000205020 <task>
ffffffe000200514:	00e7b023          	sd	a4,0(a5)
    // 1. 参考 idle 的设置, 为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    // 2. 其中每个线程的 state 为 TASK_RUNNING, counter 为 0, priority 使用 rand() 来设置, pid 为该线程在线程数组中的下标。
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 `thread_struct` 中的 `ra` 和 `sp`, 
    // 4. 其中 `ra` 设置为 __dummy （见 4.3.2）的地址， `sp` 设置为 该线程申请的物理页的高地址
    
    for(int i = 1;i < NR_TASKS; i++){
ffffffe000200518:	00100793          	li	a5,1
ffffffe00020051c:	fef42623          	sw	a5,-20(s0)
ffffffe000200520:	0a00006f          	j	ffffffe0002005c0 <task_init+0x14c>
        struct task_struct * temp = (struct task_struct *)kalloc();
ffffffe000200524:	dddff0ef          	jal	ra,ffffffe000200300 <kalloc>
ffffffe000200528:	00050793          	mv	a5,a0
ffffffe00020052c:	fef43023          	sd	a5,-32(s0)
        temp->state = TASK_RUNNING;
ffffffe000200530:	fe043783          	ld	a5,-32(s0)
ffffffe000200534:	0007b423          	sd	zero,8(a5)
        temp->counter = 0;
ffffffe000200538:	fe043783          	ld	a5,-32(s0)
ffffffe00020053c:	0007b823          	sd	zero,16(a5)
        // temp->priority = (uint64)int_mod(i+4,(PRIORITY_MAX-PRIORITY_MIN+1))+PRIORITY_MIN;
        temp->priority = (uint64)int_mod(rand(),(PRIORITY_MAX-PRIORITY_MIN+1))+PRIORITY_MIN;
ffffffe000200540:	3dc010ef          	jal	ra,ffffffe00020191c <rand>
ffffffe000200544:	00050793          	mv	a5,a0
ffffffe000200548:	0007879b          	sext.w	a5,a5
ffffffe00020054c:	00500593          	li	a1,5
ffffffe000200550:	00078513          	mv	a0,a5
ffffffe000200554:	3d5000ef          	jal	ra,ffffffe000201128 <int_mod>
ffffffe000200558:	00050793          	mv	a5,a0
ffffffe00020055c:	00178713          	addi	a4,a5,1
ffffffe000200560:	fe043783          	ld	a5,-32(s0)
ffffffe000200564:	00e7bc23          	sd	a4,24(a5)
        // temp->priority = (uint64)(i + 2) % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
        temp->pid = i;
ffffffe000200568:	fec42703          	lw	a4,-20(s0)
ffffffe00020056c:	fe043783          	ld	a5,-32(s0)
ffffffe000200570:	02e7b023          	sd	a4,32(a5)
        (temp->thread).ra = (uint64)__dummy;
ffffffe000200574:	00000717          	auipc	a4,0x0
ffffffe000200578:	bbc70713          	addi	a4,a4,-1092 # ffffffe000200130 <__dummy>
ffffffe00020057c:	fe043783          	ld	a5,-32(s0)
ffffffe000200580:	02e7b423          	sd	a4,40(a5)
        (temp->thread).sp = (uint64)temp + PGSIZE;
ffffffe000200584:	fe043703          	ld	a4,-32(s0)
ffffffe000200588:	000017b7          	lui	a5,0x1
ffffffe00020058c:	00f70733          	add	a4,a4,a5
ffffffe000200590:	fe043783          	ld	a5,-32(s0)
ffffffe000200594:	02e7b823          	sd	a4,48(a5) # 1030 <_skernel-0xffffffe0001fefd0>
        task[i] = temp;
ffffffe000200598:	00005717          	auipc	a4,0x5
ffffffe00020059c:	a8870713          	addi	a4,a4,-1400 # ffffffe000205020 <task>
ffffffe0002005a0:	fec42783          	lw	a5,-20(s0)
ffffffe0002005a4:	00379793          	slli	a5,a5,0x3
ffffffe0002005a8:	00f707b3          	add	a5,a4,a5
ffffffe0002005ac:	fe043703          	ld	a4,-32(s0)
ffffffe0002005b0:	00e7b023          	sd	a4,0(a5)
    for(int i = 1;i < NR_TASKS; i++){
ffffffe0002005b4:	fec42783          	lw	a5,-20(s0)
ffffffe0002005b8:	0017879b          	addiw	a5,a5,1
ffffffe0002005bc:	fef42623          	sw	a5,-20(s0)
ffffffe0002005c0:	fec42783          	lw	a5,-20(s0)
ffffffe0002005c4:	0007871b          	sext.w	a4,a5
ffffffe0002005c8:	00300793          	li	a5,3
ffffffe0002005cc:	f4e7dce3          	bge	a5,a4,ffffffe000200524 <task_init+0xb0>
    }
    printk("...proc_init\n");
ffffffe0002005d0:	00002517          	auipc	a0,0x2
ffffffe0002005d4:	a6050513          	addi	a0,a0,-1440 # ffffffe000202030 <_srodata+0x30>
ffffffe0002005d8:	2c4010ef          	jal	ra,ffffffe00020189c <printk>
}
ffffffe0002005dc:	00000013          	nop
ffffffe0002005e0:	01813083          	ld	ra,24(sp)
ffffffe0002005e4:	01013403          	ld	s0,16(sp)
ffffffe0002005e8:	02010113          	addi	sp,sp,32
ffffffe0002005ec:	00008067          	ret

ffffffe0002005f0 <dummy>:

void dummy(){
ffffffe0002005f0:	fd010113          	addi	sp,sp,-48
ffffffe0002005f4:	02113423          	sd	ra,40(sp)
ffffffe0002005f8:	02813023          	sd	s0,32(sp)
ffffffe0002005fc:	03010413          	addi	s0,sp,48
    uint64 MOD = 1000000007;
ffffffe000200600:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000200604:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0xffffffdfc48535f9>
ffffffe000200608:	fcf43c23          	sd	a5,-40(s0)
    uint64 auto_inc_local_var = 0;
ffffffe00020060c:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1; // 记录上一个counter
ffffffe000200610:	fff00793          	li	a5,-1
ffffffe000200614:	fef42223          	sw	a5,-28(s0)
    int last_last_counter = -1; // 记录上上个counter
ffffffe000200618:	fff00793          	li	a5,-1
ffffffe00020061c:	fef42023          	sw	a5,-32(s0)
    while(1) {
        if (last_counter == -1 || current->counter != last_counter) {
ffffffe000200620:	fe442783          	lw	a5,-28(s0)
ffffffe000200624:	0007871b          	sext.w	a4,a5
ffffffe000200628:	fff00793          	li	a5,-1
ffffffe00020062c:	00f70e63          	beq	a4,a5,ffffffe000200648 <dummy+0x58>
ffffffe000200630:	00004797          	auipc	a5,0x4
ffffffe000200634:	9e078793          	addi	a5,a5,-1568 # ffffffe000204010 <current>
ffffffe000200638:	0007b783          	ld	a5,0(a5)
ffffffe00020063c:	0107b703          	ld	a4,16(a5)
ffffffe000200640:	fe442783          	lw	a5,-28(s0)
ffffffe000200644:	08f70863          	beq	a4,a5,ffffffe0002006d4 <dummy+0xe4>
            last_last_counter = last_counter;
ffffffe000200648:	fe442783          	lw	a5,-28(s0)
ffffffe00020064c:	fef42023          	sw	a5,-32(s0)
            last_counter = current->counter;
ffffffe000200650:	00004797          	auipc	a5,0x4
ffffffe000200654:	9c078793          	addi	a5,a5,-1600 # ffffffe000204010 <current>
ffffffe000200658:	0007b783          	ld	a5,0(a5)
ffffffe00020065c:	0107b783          	ld	a5,16(a5)
ffffffe000200660:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = int_mod((auto_inc_local_var + 1) , MOD);
ffffffe000200664:	fe843783          	ld	a5,-24(s0)
ffffffe000200668:	0007879b          	sext.w	a5,a5
ffffffe00020066c:	0017879b          	addiw	a5,a5,1
ffffffe000200670:	0007879b          	sext.w	a5,a5
ffffffe000200674:	fd843703          	ld	a4,-40(s0)
ffffffe000200678:	0007071b          	sext.w	a4,a4
ffffffe00020067c:	00070593          	mv	a1,a4
ffffffe000200680:	00078513          	mv	a0,a5
ffffffe000200684:	2a5000ef          	jal	ra,ffffffe000201128 <int_mod>
ffffffe000200688:	00050793          	mv	a5,a0
ffffffe00020068c:	fef43423          	sd	a5,-24(s0)
            // auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            // printk("[PID = %d] is running. auto_inc_local_var = %d. Thread space begin at %lx.\n", current->pid, auto_inc_local_var, current);
            printk("[PID = %d] auto_inc_local_val = %d.", current->pid, auto_inc_local_var); 
ffffffe000200690:	00004797          	auipc	a5,0x4
ffffffe000200694:	98078793          	addi	a5,a5,-1664 # ffffffe000204010 <current>
ffffffe000200698:	0007b783          	ld	a5,0(a5)
ffffffe00020069c:	0207b783          	ld	a5,32(a5)
ffffffe0002006a0:	fe843603          	ld	a2,-24(s0)
ffffffe0002006a4:	00078593          	mv	a1,a5
ffffffe0002006a8:	00002517          	auipc	a0,0x2
ffffffe0002006ac:	99850513          	addi	a0,a0,-1640 # ffffffe000202040 <_srodata+0x40>
ffffffe0002006b0:	1ec010ef          	jal	ra,ffffffe00020189c <printk>
            printk("Thread space addr : %lx\n", current);
ffffffe0002006b4:	00004797          	auipc	a5,0x4
ffffffe0002006b8:	95c78793          	addi	a5,a5,-1700 # ffffffe000204010 <current>
ffffffe0002006bc:	0007b783          	ld	a5,0(a5)
ffffffe0002006c0:	00078593          	mv	a1,a5
ffffffe0002006c4:	00002517          	auipc	a0,0x2
ffffffe0002006c8:	9a450513          	addi	a0,a0,-1628 # ffffffe000202068 <_srodata+0x68>
ffffffe0002006cc:	1d0010ef          	jal	ra,ffffffe00020189c <printk>
        if (last_counter == -1 || current->counter != last_counter) {
ffffffe0002006d0:	0440006f          	j	ffffffe000200714 <dummy+0x124>
        } else if((last_last_counter == 0 || last_last_counter == -1) && last_counter == 1) { // counter恒为1的情况
ffffffe0002006d4:	fe042783          	lw	a5,-32(s0)
ffffffe0002006d8:	0007879b          	sext.w	a5,a5
ffffffe0002006dc:	00078a63          	beqz	a5,ffffffe0002006f0 <dummy+0x100>
ffffffe0002006e0:	fe042783          	lw	a5,-32(s0)
ffffffe0002006e4:	0007871b          	sext.w	a4,a5
ffffffe0002006e8:	fff00793          	li	a5,-1
ffffffe0002006ec:	f2f71ae3          	bne	a4,a5,ffffffe000200620 <dummy+0x30>
ffffffe0002006f0:	fe442783          	lw	a5,-28(s0)
ffffffe0002006f4:	0007871b          	sext.w	a4,a5
ffffffe0002006f8:	00100793          	li	a5,1
ffffffe0002006fc:	f2f712e3          	bne	a4,a5,ffffffe000200620 <dummy+0x30>
            // 这里比较 tricky，不要求理解。
            last_counter = 0; 
ffffffe000200700:	fe042223          	sw	zero,-28(s0)
            current->counter = 0;
ffffffe000200704:	00004797          	auipc	a5,0x4
ffffffe000200708:	90c78793          	addi	a5,a5,-1780 # ffffffe000204010 <current>
ffffffe00020070c:	0007b783          	ld	a5,0(a5)
ffffffe000200710:	0007b823          	sd	zero,16(a5)
        if (last_counter == -1 || current->counter != last_counter) {
ffffffe000200714:	f0dff06f          	j	ffffffe000200620 <dummy+0x30>

ffffffe000200718 <switch_to>:
        }
    }
}

void switch_to(struct task_struct* next) {
ffffffe000200718:	fd010113          	addi	sp,sp,-48
ffffffe00020071c:	02113423          	sd	ra,40(sp)
ffffffe000200720:	02813023          	sd	s0,32(sp)
ffffffe000200724:	03010413          	addi	s0,sp,48
ffffffe000200728:	fca43c23          	sd	a0,-40(s0)
    if (next->pid != current->pid) 
ffffffe00020072c:	fd843783          	ld	a5,-40(s0)
ffffffe000200730:	0207b703          	ld	a4,32(a5)
ffffffe000200734:	00004797          	auipc	a5,0x4
ffffffe000200738:	8dc78793          	addi	a5,a5,-1828 # ffffffe000204010 <current>
ffffffe00020073c:	0007b783          	ld	a5,0(a5)
ffffffe000200740:	0207b783          	ld	a5,32(a5)
ffffffe000200744:	04f70e63          	beq	a4,a5,ffffffe0002007a0 <switch_to+0x88>
    {
        printk("switch to [PID = %d PRIORITY = %d COUNTER = %d]\n", next->pid, next->priority, next->counter);
ffffffe000200748:	fd843783          	ld	a5,-40(s0)
ffffffe00020074c:	0207b703          	ld	a4,32(a5)
ffffffe000200750:	fd843783          	ld	a5,-40(s0)
ffffffe000200754:	0187b603          	ld	a2,24(a5)
ffffffe000200758:	fd843783          	ld	a5,-40(s0)
ffffffe00020075c:	0107b783          	ld	a5,16(a5)
ffffffe000200760:	00078693          	mv	a3,a5
ffffffe000200764:	00070593          	mv	a1,a4
ffffffe000200768:	00002517          	auipc	a0,0x2
ffffffe00020076c:	92050513          	addi	a0,a0,-1760 # ffffffe000202088 <_srodata+0x88>
ffffffe000200770:	12c010ef          	jal	ra,ffffffe00020189c <printk>
        struct task_struct* prev = current;
ffffffe000200774:	00004797          	auipc	a5,0x4
ffffffe000200778:	89c78793          	addi	a5,a5,-1892 # ffffffe000204010 <current>
ffffffe00020077c:	0007b783          	ld	a5,0(a5)
ffffffe000200780:	fef43423          	sd	a5,-24(s0)
        current = next; // 切换
ffffffe000200784:	00004797          	auipc	a5,0x4
ffffffe000200788:	88c78793          	addi	a5,a5,-1908 # ffffffe000204010 <current>
ffffffe00020078c:	fd843703          	ld	a4,-40(s0)
ffffffe000200790:	00e7b023          	sd	a4,0(a5)
        __switch_to(prev, next);
ffffffe000200794:	fd843583          	ld	a1,-40(s0)
ffffffe000200798:	fe843503          	ld	a0,-24(s0)
ffffffe00020079c:	921ff0ef          	jal	ra,ffffffe0002000bc <__switch_to>
    }
}
ffffffe0002007a0:	00000013          	nop
ffffffe0002007a4:	02813083          	ld	ra,40(sp)
ffffffe0002007a8:	02013403          	ld	s0,32(sp)
ffffffe0002007ac:	03010113          	addi	sp,sp,48
ffffffe0002007b0:	00008067          	ret

ffffffe0002007b4 <do_timer>:

void do_timer(){
ffffffe0002007b4:	ff010113          	addi	sp,sp,-16
ffffffe0002007b8:	00113423          	sd	ra,8(sp)
ffffffe0002007bc:	00813023          	sd	s0,0(sp)
ffffffe0002007c0:	01010413          	addi	s0,sp,16
    if(current == idle || current -> counter == 0) 
ffffffe0002007c4:	00004797          	auipc	a5,0x4
ffffffe0002007c8:	84c78793          	addi	a5,a5,-1972 # ffffffe000204010 <current>
ffffffe0002007cc:	0007b703          	ld	a4,0(a5)
ffffffe0002007d0:	00004797          	auipc	a5,0x4
ffffffe0002007d4:	83878793          	addi	a5,a5,-1992 # ffffffe000204008 <idle>
ffffffe0002007d8:	0007b783          	ld	a5,0(a5)
ffffffe0002007dc:	00f70c63          	beq	a4,a5,ffffffe0002007f4 <do_timer+0x40>
ffffffe0002007e0:	00004797          	auipc	a5,0x4
ffffffe0002007e4:	83078793          	addi	a5,a5,-2000 # ffffffe000204010 <current>
ffffffe0002007e8:	0007b783          	ld	a5,0(a5)
ffffffe0002007ec:	0107b783          	ld	a5,16(a5)
ffffffe0002007f0:	00079663          	bnez	a5,ffffffe0002007fc <do_timer+0x48>
        schedule();
ffffffe0002007f4:	050000ef          	jal	ra,ffffffe000200844 <schedule>
ffffffe0002007f8:	03c0006f          	j	ffffffe000200834 <do_timer+0x80>
    else{
        current->counter--;
ffffffe0002007fc:	00004797          	auipc	a5,0x4
ffffffe000200800:	81478793          	addi	a5,a5,-2028 # ffffffe000204010 <current>
ffffffe000200804:	0007b783          	ld	a5,0(a5)
ffffffe000200808:	0107b703          	ld	a4,16(a5)
ffffffe00020080c:	fff70713          	addi	a4,a4,-1
ffffffe000200810:	00e7b823          	sd	a4,16(a5)
        if (current->counter > 0)
ffffffe000200814:	00003797          	auipc	a5,0x3
ffffffe000200818:	7fc78793          	addi	a5,a5,2044 # ffffffe000204010 <current>
ffffffe00020081c:	0007b783          	ld	a5,0(a5)
ffffffe000200820:	0107b783          	ld	a5,16(a5)
ffffffe000200824:	00079663          	bnez	a5,ffffffe000200830 <do_timer+0x7c>
            return;
        else
            schedule();
ffffffe000200828:	01c000ef          	jal	ra,ffffffe000200844 <schedule>
ffffffe00020082c:	0080006f          	j	ffffffe000200834 <do_timer+0x80>
            return;
ffffffe000200830:	00000013          	nop
    }
}
ffffffe000200834:	00813083          	ld	ra,8(sp)
ffffffe000200838:	00013403          	ld	s0,0(sp)
ffffffe00020083c:	01010113          	addi	sp,sp,16
ffffffe000200840:	00008067          	ret

ffffffe000200844 <schedule>:

void schedule(void)
{
ffffffe000200844:	fd010113          	addi	sp,sp,-48
ffffffe000200848:	02113423          	sd	ra,40(sp)
ffffffe00020084c:	02813023          	sd	s0,32(sp)
ffffffe000200850:	03010413          	addi	s0,sp,48
    struct task_struct *next = idle;
ffffffe000200854:	00003797          	auipc	a5,0x3
ffffffe000200858:	7b478793          	addi	a5,a5,1972 # ffffffe000204008 <idle>
ffffffe00020085c:	0007b783          	ld	a5,0(a5)
ffffffe000200860:	fef43423          	sd	a5,-24(s0)
    uint64 min_counter = 0xFFFFFFFF;
ffffffe000200864:	fff00793          	li	a5,-1
ffffffe000200868:	0207d793          	srli	a5,a5,0x20
ffffffe00020086c:	fef43023          	sd	a5,-32(s0)
    while (1)
    {
        for (int i = 1; i < NR_TASKS; i++)
ffffffe000200870:	00100793          	li	a5,1
ffffffe000200874:	fcf42e23          	sw	a5,-36(s0)
ffffffe000200878:	0d40006f          	j	ffffffe00020094c <schedule+0x108>
        {
            if (task[i]->state == TASK_RUNNING && task[i]->counter > 0 && task[i]->counter < min_counter)
ffffffe00020087c:	00004717          	auipc	a4,0x4
ffffffe000200880:	7a470713          	addi	a4,a4,1956 # ffffffe000205020 <task>
ffffffe000200884:	fdc42783          	lw	a5,-36(s0)
ffffffe000200888:	00379793          	slli	a5,a5,0x3
ffffffe00020088c:	00f707b3          	add	a5,a4,a5
ffffffe000200890:	0007b783          	ld	a5,0(a5)
ffffffe000200894:	0087b783          	ld	a5,8(a5)
ffffffe000200898:	0a079463          	bnez	a5,ffffffe000200940 <schedule+0xfc>
ffffffe00020089c:	00004717          	auipc	a4,0x4
ffffffe0002008a0:	78470713          	addi	a4,a4,1924 # ffffffe000205020 <task>
ffffffe0002008a4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002008a8:	00379793          	slli	a5,a5,0x3
ffffffe0002008ac:	00f707b3          	add	a5,a4,a5
ffffffe0002008b0:	0007b783          	ld	a5,0(a5)
ffffffe0002008b4:	0107b783          	ld	a5,16(a5)
ffffffe0002008b8:	08078463          	beqz	a5,ffffffe000200940 <schedule+0xfc>
ffffffe0002008bc:	00004717          	auipc	a4,0x4
ffffffe0002008c0:	76470713          	addi	a4,a4,1892 # ffffffe000205020 <task>
ffffffe0002008c4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002008c8:	00379793          	slli	a5,a5,0x3
ffffffe0002008cc:	00f707b3          	add	a5,a4,a5
ffffffe0002008d0:	0007b783          	ld	a5,0(a5)
ffffffe0002008d4:	0107b783          	ld	a5,16(a5)
ffffffe0002008d8:	fe043703          	ld	a4,-32(s0)
ffffffe0002008dc:	06e7f263          	bgeu	a5,a4,ffffffe000200940 <schedule+0xfc>
            {
                if (min_counter > task[i]->counter)
ffffffe0002008e0:	00004717          	auipc	a4,0x4
ffffffe0002008e4:	74070713          	addi	a4,a4,1856 # ffffffe000205020 <task>
ffffffe0002008e8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002008ec:	00379793          	slli	a5,a5,0x3
ffffffe0002008f0:	00f707b3          	add	a5,a4,a5
ffffffe0002008f4:	0007b783          	ld	a5,0(a5)
ffffffe0002008f8:	0107b783          	ld	a5,16(a5)
ffffffe0002008fc:	fe043703          	ld	a4,-32(s0)
ffffffe000200900:	04e7f063          	bgeu	a5,a4,ffffffe000200940 <schedule+0xfc>
                {
                    min_counter = task[i]->counter;
ffffffe000200904:	00004717          	auipc	a4,0x4
ffffffe000200908:	71c70713          	addi	a4,a4,1820 # ffffffe000205020 <task>
ffffffe00020090c:	fdc42783          	lw	a5,-36(s0)
ffffffe000200910:	00379793          	slli	a5,a5,0x3
ffffffe000200914:	00f707b3          	add	a5,a4,a5
ffffffe000200918:	0007b783          	ld	a5,0(a5)
ffffffe00020091c:	0107b783          	ld	a5,16(a5)
ffffffe000200920:	fef43023          	sd	a5,-32(s0)
                    next = task[i];
ffffffe000200924:	00004717          	auipc	a4,0x4
ffffffe000200928:	6fc70713          	addi	a4,a4,1788 # ffffffe000205020 <task>
ffffffe00020092c:	fdc42783          	lw	a5,-36(s0)
ffffffe000200930:	00379793          	slli	a5,a5,0x3
ffffffe000200934:	00f707b3          	add	a5,a4,a5
ffffffe000200938:	0007b783          	ld	a5,0(a5)
ffffffe00020093c:	fef43423          	sd	a5,-24(s0)
        for (int i = 1; i < NR_TASKS; i++)
ffffffe000200940:	fdc42783          	lw	a5,-36(s0)
ffffffe000200944:	0017879b          	addiw	a5,a5,1
ffffffe000200948:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020094c:	fdc42783          	lw	a5,-36(s0)
ffffffe000200950:	0007871b          	sext.w	a4,a5
ffffffe000200954:	00300793          	li	a5,3
ffffffe000200958:	f2e7d2e3          	bge	a5,a4,ffffffe00020087c <schedule+0x38>
                }
            }
        }
        if (next == idle)
ffffffe00020095c:	00003797          	auipc	a5,0x3
ffffffe000200960:	6ac78793          	addi	a5,a5,1708 # ffffffe000204008 <idle>
ffffffe000200964:	0007b783          	ld	a5,0(a5)
ffffffe000200968:	fe843703          	ld	a4,-24(s0)
ffffffe00020096c:	0cf71663          	bne	a4,a5,ffffffe000200a38 <schedule+0x1f4>
        {
            for (int i = 1; i < NR_TASKS; i++)
ffffffe000200970:	00100793          	li	a5,1
ffffffe000200974:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200978:	0ac0006f          	j	ffffffe000200a24 <schedule+0x1e0>
            {
                task[i]->counter = task[i]->priority;
ffffffe00020097c:	00004717          	auipc	a4,0x4
ffffffe000200980:	6a470713          	addi	a4,a4,1700 # ffffffe000205020 <task>
ffffffe000200984:	fd842783          	lw	a5,-40(s0)
ffffffe000200988:	00379793          	slli	a5,a5,0x3
ffffffe00020098c:	00f707b3          	add	a5,a4,a5
ffffffe000200990:	0007b703          	ld	a4,0(a5)
ffffffe000200994:	00004697          	auipc	a3,0x4
ffffffe000200998:	68c68693          	addi	a3,a3,1676 # ffffffe000205020 <task>
ffffffe00020099c:	fd842783          	lw	a5,-40(s0)
ffffffe0002009a0:	00379793          	slli	a5,a5,0x3
ffffffe0002009a4:	00f687b3          	add	a5,a3,a5
ffffffe0002009a8:	0007b783          	ld	a5,0(a5)
ffffffe0002009ac:	01873703          	ld	a4,24(a4)
ffffffe0002009b0:	00e7b823          	sd	a4,16(a5)
                printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
ffffffe0002009b4:	00004717          	auipc	a4,0x4
ffffffe0002009b8:	66c70713          	addi	a4,a4,1644 # ffffffe000205020 <task>
ffffffe0002009bc:	fd842783          	lw	a5,-40(s0)
ffffffe0002009c0:	00379793          	slli	a5,a5,0x3
ffffffe0002009c4:	00f707b3          	add	a5,a4,a5
ffffffe0002009c8:	0007b783          	ld	a5,0(a5)
ffffffe0002009cc:	0207b583          	ld	a1,32(a5)
ffffffe0002009d0:	00004717          	auipc	a4,0x4
ffffffe0002009d4:	65070713          	addi	a4,a4,1616 # ffffffe000205020 <task>
ffffffe0002009d8:	fd842783          	lw	a5,-40(s0)
ffffffe0002009dc:	00379793          	slli	a5,a5,0x3
ffffffe0002009e0:	00f707b3          	add	a5,a4,a5
ffffffe0002009e4:	0007b783          	ld	a5,0(a5)
ffffffe0002009e8:	0187b603          	ld	a2,24(a5)
ffffffe0002009ec:	00004717          	auipc	a4,0x4
ffffffe0002009f0:	63470713          	addi	a4,a4,1588 # ffffffe000205020 <task>
ffffffe0002009f4:	fd842783          	lw	a5,-40(s0)
ffffffe0002009f8:	00379793          	slli	a5,a5,0x3
ffffffe0002009fc:	00f707b3          	add	a5,a4,a5
ffffffe000200a00:	0007b783          	ld	a5,0(a5)
ffffffe000200a04:	0107b783          	ld	a5,16(a5)
ffffffe000200a08:	00078693          	mv	a3,a5
ffffffe000200a0c:	00001517          	auipc	a0,0x1
ffffffe000200a10:	6b450513          	addi	a0,a0,1716 # ffffffe0002020c0 <_srodata+0xc0>
ffffffe000200a14:	689000ef          	jal	ra,ffffffe00020189c <printk>
            for (int i = 1; i < NR_TASKS; i++)
ffffffe000200a18:	fd842783          	lw	a5,-40(s0)
ffffffe000200a1c:	0017879b          	addiw	a5,a5,1
ffffffe000200a20:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200a24:	fd842783          	lw	a5,-40(s0)
ffffffe000200a28:	0007871b          	sext.w	a4,a5
ffffffe000200a2c:	00300793          	li	a5,3
ffffffe000200a30:	f4e7d6e3          	bge	a5,a4,ffffffe00020097c <schedule+0x138>
        for (int i = 1; i < NR_TASKS; i++)
ffffffe000200a34:	e3dff06f          	j	ffffffe000200870 <schedule+0x2c>
            }
        }
        else
            break;
ffffffe000200a38:	00000013          	nop
    }
    switch_to(next);
ffffffe000200a3c:	fe843503          	ld	a0,-24(s0)
ffffffe000200a40:	cd9ff0ef          	jal	ra,ffffffe000200718 <switch_to>
}
ffffffe000200a44:	00000013          	nop
ffffffe000200a48:	02813083          	ld	ra,40(sp)
ffffffe000200a4c:	02013403          	ld	s0,32(sp)
ffffffe000200a50:	03010113          	addi	sp,sp,48
ffffffe000200a54:	00008067          	ret

ffffffe000200a58 <sbi_ecall>:

struct sbiret sbi_ecall(int ext, int fid, uint64 arg0,
                        uint64 arg1, uint64 arg2,
                        uint64 arg3, uint64 arg4,
                        uint64 arg5)
{
ffffffe000200a58:	f9010113          	addi	sp,sp,-112
ffffffe000200a5c:	06813423          	sd	s0,104(sp)
ffffffe000200a60:	07010413          	addi	s0,sp,112
ffffffe000200a64:	fcc43023          	sd	a2,-64(s0)
ffffffe000200a68:	fad43c23          	sd	a3,-72(s0)
ffffffe000200a6c:	fae43823          	sd	a4,-80(s0)
ffffffe000200a70:	faf43423          	sd	a5,-88(s0)
ffffffe000200a74:	fb043023          	sd	a6,-96(s0)
ffffffe000200a78:	f9143c23          	sd	a7,-104(s0)
ffffffe000200a7c:	00050793          	mv	a5,a0
ffffffe000200a80:	fcf42623          	sw	a5,-52(s0)
ffffffe000200a84:	00058793          	mv	a5,a1
ffffffe000200a88:	fcf42423          	sw	a5,-56(s0)
  // );
  // ret_str.error = err;
  // ret_str.value = value;
  // return ret_str;
  struct sbiret ret;
  register uint64 a0 asm("a0") = (uint64)(arg0);
ffffffe000200a8c:	fc043503          	ld	a0,-64(s0)
  register uint64 a1 asm("a1") = (uint64)(arg1);
ffffffe000200a90:	fb843583          	ld	a1,-72(s0)
  register uint64 a2 asm("a2") = (uint64)(arg2);
ffffffe000200a94:	fb043603          	ld	a2,-80(s0)
  register uint64 a3 asm("a3") = (uint64)(arg3);
ffffffe000200a98:	fa843683          	ld	a3,-88(s0)
  register uint64 a4 asm("a4") = (uint64)(arg4);
ffffffe000200a9c:	fa043703          	ld	a4,-96(s0)
  register uint64 a5 asm("a5") = (uint64)(arg5);
ffffffe000200aa0:	f9843783          	ld	a5,-104(s0)
  register uint64 a6 asm("a6") = (uint64)(fid);
ffffffe000200aa4:	fc842803          	lw	a6,-56(s0)
  register uint64 a7 asm("a7") = (uint64)(ext);
ffffffe000200aa8:	fcc42883          	lw	a7,-52(s0)
  asm volatile (
ffffffe000200aac:	00000073          	ecall
      "ecall"
      : "+r" (a0), "+r" (a1)
      : "r" (a2), "r" (a3), "r" (a4), "r" (a5), "r" (a6), "r" (a7)
      : "memory"
  );
  ret.error = a0;
ffffffe000200ab0:	00050793          	mv	a5,a0
ffffffe000200ab4:	fcf43823          	sd	a5,-48(s0)
  ret.value = a1;
ffffffe000200ab8:	00058793          	mv	a5,a1
ffffffe000200abc:	fcf43c23          	sd	a5,-40(s0)
  return ret;
ffffffe000200ac0:	fd043783          	ld	a5,-48(s0)
ffffffe000200ac4:	fef43023          	sd	a5,-32(s0)
ffffffe000200ac8:	fd843783          	ld	a5,-40(s0)
ffffffe000200acc:	fef43423          	sd	a5,-24(s0)
ffffffe000200ad0:	fe043703          	ld	a4,-32(s0)
ffffffe000200ad4:	fe843783          	ld	a5,-24(s0)
ffffffe000200ad8:	00070313          	mv	t1,a4
ffffffe000200adc:	00078393          	mv	t2,a5
ffffffe000200ae0:	00030713          	mv	a4,t1
ffffffe000200ae4:	00038793          	mv	a5,t2
}
ffffffe000200ae8:	00070513          	mv	a0,a4
ffffffe000200aec:	00078593          	mv	a1,a5
ffffffe000200af0:	06813403          	ld	s0,104(sp)
ffffffe000200af4:	07010113          	addi	sp,sp,112
ffffffe000200af8:	00008067          	ret

ffffffe000200afc <sbi_set_timer>:
void sbi_set_timer(uint64 time){
ffffffe000200afc:	fe010113          	addi	sp,sp,-32
ffffffe000200b00:	00113c23          	sd	ra,24(sp)
ffffffe000200b04:	00813823          	sd	s0,16(sp)
ffffffe000200b08:	02010413          	addi	s0,sp,32
ffffffe000200b0c:	fea43423          	sd	a0,-24(s0)
  sbi_ecall(0,0,time,0,0,0,0,0);
ffffffe000200b10:	00000893          	li	a7,0
ffffffe000200b14:	00000813          	li	a6,0
ffffffe000200b18:	00000793          	li	a5,0
ffffffe000200b1c:	00000713          	li	a4,0
ffffffe000200b20:	00000693          	li	a3,0
ffffffe000200b24:	fe843603          	ld	a2,-24(s0)
ffffffe000200b28:	00000593          	li	a1,0
ffffffe000200b2c:	00000513          	li	a0,0
ffffffe000200b30:	f29ff0ef          	jal	ra,ffffffe000200a58 <sbi_ecall>
ffffffe000200b34:	00000013          	nop
ffffffe000200b38:	01813083          	ld	ra,24(sp)
ffffffe000200b3c:	01013403          	ld	s0,16(sp)
ffffffe000200b40:	02010113          	addi	sp,sp,32
ffffffe000200b44:	00008067          	ret

ffffffe000200b48 <trap_handler>:
#include<printk.h>
#include"clock.h"
// trap.c 

void trap_handler(unsigned long scause, unsigned long sepc)
{
ffffffe000200b48:	fe010113          	addi	sp,sp,-32
ffffffe000200b4c:	00113c23          	sd	ra,24(sp)
ffffffe000200b50:	00813823          	sd	s0,16(sp)
ffffffe000200b54:	02010413          	addi	s0,sp,32
ffffffe000200b58:	fea43423          	sd	a0,-24(s0)
ffffffe000200b5c:	feb43023          	sd	a1,-32(s0)
    if ((scause >> 63 == 1) && ((scause & 0x7fffffffffffffff) == 5))
ffffffe000200b60:	fe843783          	ld	a5,-24(s0)
ffffffe000200b64:	03f7d713          	srli	a4,a5,0x3f
ffffffe000200b68:	00100793          	li	a5,1
ffffffe000200b6c:	02f71463          	bne	a4,a5,ffffffe000200b94 <trap_handler+0x4c>
ffffffe000200b70:	fe843703          	ld	a4,-24(s0)
ffffffe000200b74:	fff00793          	li	a5,-1
ffffffe000200b78:	0017d793          	srli	a5,a5,0x1
ffffffe000200b7c:	00f77733          	and	a4,a4,a5
ffffffe000200b80:	00500793          	li	a5,5
ffffffe000200b84:	00f71863          	bne	a4,a5,ffffffe000200b94 <trap_handler+0x4c>
    {
        // printk("[S] Supervisor Mode Timer Interrupt\n");
        clock_set_next_event();
ffffffe000200b88:	f14ff0ef          	jal	ra,ffffffe00020029c <clock_set_next_event>
        // sbi_ecall(0x00, 0, TIMECLOCK, 0, 0, 0, 0, 0);
        do_timer();
ffffffe000200b8c:	c29ff0ef          	jal	ra,ffffffe0002007b4 <do_timer>
    {
ffffffe000200b90:	0180006f          	j	ffffffe000200ba8 <trap_handler+0x60>
    }
    else {
        printk("trap handler: scause = %lx, sepc = %lx\n", scause, sepc);
ffffffe000200b94:	fe043603          	ld	a2,-32(s0)
ffffffe000200b98:	fe843583          	ld	a1,-24(s0)
ffffffe000200b9c:	00001517          	auipc	a0,0x1
ffffffe000200ba0:	55450513          	addi	a0,a0,1364 # ffffffe0002020f0 <_srodata+0xf0>
ffffffe000200ba4:	4f9000ef          	jal	ra,ffffffe00020189c <printk>
    }
    return;
ffffffe000200ba8:	00000013          	nop
ffffffe000200bac:	01813083          	ld	ra,24(sp)
ffffffe000200bb0:	01013403          	ld	s0,16(sp)
ffffffe000200bb4:	02010113          	addi	sp,sp,32
ffffffe000200bb8:	00008067          	ret

ffffffe000200bbc <setup_vm>:
unsigned long early_pgtbl[512] __attribute__((__aligned__(0x1000)));
/* swapper_pg_dir: kernel pagetable 根目录， 在 setup_vm_final 进行映射。 */
unsigned long  swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm(void)
{
ffffffe000200bbc:	fe010113          	addi	sp,sp,-32
ffffffe000200bc0:	00113c23          	sd	ra,24(sp)
ffffffe000200bc4:	00813823          	sd	s0,16(sp)
ffffffe000200bc8:	02010413          	addi	s0,sp,32
        high bit 可以忽略
        中间9 bit 作为 early_pgtbl 的 index
        低 30 bit 作为 页内偏移 这里注意到 30 = 9 + 9 + 12， 即我们只使用根页表， 根页表的每个 entry 都对应 1GB 的区域。
    3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    */
    printk("setup_vm in\n");
ffffffe000200bcc:	00001517          	auipc	a0,0x1
ffffffe000200bd0:	54c50513          	addi	a0,a0,1356 # ffffffe000202118 <_srodata+0x118>
ffffffe000200bd4:	4c9000ef          	jal	ra,ffffffe00020189c <printk>
    memset(early_pgtbl, 0, PGSIZE);
ffffffe000200bd8:	00001637          	lui	a2,0x1
ffffffe000200bdc:	00000593          	li	a1,0
ffffffe000200be0:	00005517          	auipc	a0,0x5
ffffffe000200be4:	42050513          	addi	a0,a0,1056 # ffffffe000206000 <early_pgtbl>
ffffffe000200be8:	57d000ef          	jal	ra,ffffffe000201964 <memset>
    uint64 index, entry;
    // entry[53:28] = PPN[2], entry[3:0] = XWRV
    // PA == VA
    index = ((uint64)PHY_START >> 30) & 0x01FF;
ffffffe000200bec:	00200793          	li	a5,2
ffffffe000200bf0:	fef43423          	sd	a5,-24(s0)
    entry = ((PHY_START & 0x00FFFFFFC0000000) >> 2) | 0xCF;
ffffffe000200bf4:	200007b7          	lui	a5,0x20000
ffffffe000200bf8:	0cf78793          	addi	a5,a5,207 # 200000cf <_skernel-0xffffffdfe01fff31>
ffffffe000200bfc:	fef43023          	sd	a5,-32(s0)
    early_pgtbl[index] = entry;
ffffffe000200c00:	00005717          	auipc	a4,0x5
ffffffe000200c04:	40070713          	addi	a4,a4,1024 # ffffffe000206000 <early_pgtbl>
ffffffe000200c08:	fe843783          	ld	a5,-24(s0)
ffffffe000200c0c:	00379793          	slli	a5,a5,0x3
ffffffe000200c10:	00f707b3          	add	a5,a4,a5
ffffffe000200c14:	fe043703          	ld	a4,-32(s0)
ffffffe000200c18:	00e7b023          	sd	a4,0(a5)
    // PA + PV2VA_OFFSET == VA
    index = ((uint64)VM_START >> 30) & 0x01FF;
ffffffe000200c1c:	18000793          	li	a5,384
ffffffe000200c20:	fef43423          	sd	a5,-24(s0)
    entry = ((PHY_START & 0x00FFFFFFC0000000) >> 2) | 0xCF;
ffffffe000200c24:	200007b7          	lui	a5,0x20000
ffffffe000200c28:	0cf78793          	addi	a5,a5,207 # 200000cf <_skernel-0xffffffdfe01fff31>
ffffffe000200c2c:	fef43023          	sd	a5,-32(s0)
    early_pgtbl[index] = entry;
ffffffe000200c30:	00005717          	auipc	a4,0x5
ffffffe000200c34:	3d070713          	addi	a4,a4,976 # ffffffe000206000 <early_pgtbl>
ffffffe000200c38:	fe843783          	ld	a5,-24(s0)
ffffffe000200c3c:	00379793          	slli	a5,a5,0x3
ffffffe000200c40:	00f707b3          	add	a5,a4,a5
ffffffe000200c44:	fe043703          	ld	a4,-32(s0)
ffffffe000200c48:	00e7b023          	sd	a4,0(a5)
    // printk("...setup_vm finish\n");
}
ffffffe000200c4c:	00000013          	nop
ffffffe000200c50:	01813083          	ld	ra,24(sp)
ffffffe000200c54:	01013403          	ld	s0,16(sp)
ffffffe000200c58:	02010113          	addi	sp,sp,32
ffffffe000200c5c:	00008067          	ret

ffffffe000200c60 <setup_vm_final>:
extern char _stext[];
extern char _srodata[];
extern char _sdata[];
extern char _sbss[];

void setup_vm_final(void) {
ffffffe000200c60:	fd010113          	addi	sp,sp,-48
ffffffe000200c64:	02113423          	sd	ra,40(sp)
ffffffe000200c68:	02813023          	sd	s0,32(sp)
ffffffe000200c6c:	03010413          	addi	s0,sp,48
    printk("setup_vm_final in\n");
ffffffe000200c70:	00001517          	auipc	a0,0x1
ffffffe000200c74:	4b850513          	addi	a0,a0,1208 # ffffffe000202128 <_srodata+0x128>
ffffffe000200c78:	425000ef          	jal	ra,ffffffe00020189c <printk>
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000200c7c:	00001637          	lui	a2,0x1
ffffffe000200c80:	00000593          	li	a1,0
ffffffe000200c84:	00006517          	auipc	a0,0x6
ffffffe000200c88:	37c50513          	addi	a0,a0,892 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200c8c:	4d9000ef          	jal	ra,ffffffe000201964 <memset>

    // No OpenSBI mapping required
    
    // mapping kernel text X|-|R|V
    uint64 va = (uint64)&_stext;
ffffffe000200c90:	fffff797          	auipc	a5,0xfffff
ffffffe000200c94:	37078793          	addi	a5,a5,880 # ffffffe000200000 <_skernel>
ffffffe000200c98:	fef43423          	sd	a5,-24(s0)
    uint64 pa = (uint64)(&_stext) - PA2VA_OFFSET;
ffffffe000200c9c:	fffff717          	auipc	a4,0xfffff
ffffffe000200ca0:	36470713          	addi	a4,a4,868 # ffffffe000200000 <_skernel>
ffffffe000200ca4:	04100793          	li	a5,65
ffffffe000200ca8:	01f79793          	slli	a5,a5,0x1f
ffffffe000200cac:	00f707b3          	add	a5,a4,a5
ffffffe000200cb0:	fef43023          	sd	a5,-32(s0)
    uint64 sz = (uint64)&_srodata - (uint64)(&_stext);
ffffffe000200cb4:	00001717          	auipc	a4,0x1
ffffffe000200cb8:	34c70713          	addi	a4,a4,844 # ffffffe000202000 <_srodata>
ffffffe000200cbc:	fffff797          	auipc	a5,0xfffff
ffffffe000200cc0:	34478793          	addi	a5,a5,836 # ffffffe000200000 <_skernel>
ffffffe000200cc4:	40f707b3          	sub	a5,a4,a5
ffffffe000200cc8:	fcf43c23          	sd	a5,-40(s0)
    create_mapping(swapper_pg_dir, va, pa, sz, 0xB | 0x40 | 0x80);
ffffffe000200ccc:	0cb00713          	li	a4,203
ffffffe000200cd0:	fd843683          	ld	a3,-40(s0)
ffffffe000200cd4:	fe043603          	ld	a2,-32(s0)
ffffffe000200cd8:	fe843583          	ld	a1,-24(s0)
ffffffe000200cdc:	00006517          	auipc	a0,0x6
ffffffe000200ce0:	32450513          	addi	a0,a0,804 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200ce4:	108000ef          	jal	ra,ffffffe000200dec <create_mapping>

    // mapping kernel rodata -|-|R|V
    va = (uint64)(&_srodata);
ffffffe000200ce8:	00001797          	auipc	a5,0x1
ffffffe000200cec:	31878793          	addi	a5,a5,792 # ffffffe000202000 <_srodata>
ffffffe000200cf0:	fef43423          	sd	a5,-24(s0)
    pa = (uint64)(&_srodata) - PA2VA_OFFSET;
ffffffe000200cf4:	00001717          	auipc	a4,0x1
ffffffe000200cf8:	30c70713          	addi	a4,a4,780 # ffffffe000202000 <_srodata>
ffffffe000200cfc:	04100793          	li	a5,65
ffffffe000200d00:	01f79793          	slli	a5,a5,0x1f
ffffffe000200d04:	00f707b3          	add	a5,a4,a5
ffffffe000200d08:	fef43023          	sd	a5,-32(s0)
    sz = (uint64)(&_sdata) - (uint64)(&_srodata);
ffffffe000200d0c:	00002717          	auipc	a4,0x2
ffffffe000200d10:	2f470713          	addi	a4,a4,756 # ffffffe000203000 <TIMECLOCK>
ffffffe000200d14:	00001797          	auipc	a5,0x1
ffffffe000200d18:	2ec78793          	addi	a5,a5,748 # ffffffe000202000 <_srodata>
ffffffe000200d1c:	40f707b3          	sub	a5,a4,a5
ffffffe000200d20:	fcf43c23          	sd	a5,-40(s0)
    create_mapping(swapper_pg_dir, va, pa, sz, 0x3 | 0x40 | 0x80);
ffffffe000200d24:	0c300713          	li	a4,195
ffffffe000200d28:	fd843683          	ld	a3,-40(s0)
ffffffe000200d2c:	fe043603          	ld	a2,-32(s0)
ffffffe000200d30:	fe843583          	ld	a1,-24(s0)
ffffffe000200d34:	00006517          	auipc	a0,0x6
ffffffe000200d38:	2cc50513          	addi	a0,a0,716 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200d3c:	0b0000ef          	jal	ra,ffffffe000200dec <create_mapping>
  
    // mapping other memory -|W|R|V
    va = (uint64)(&_sdata);
ffffffe000200d40:	00002797          	auipc	a5,0x2
ffffffe000200d44:	2c078793          	addi	a5,a5,704 # ffffffe000203000 <TIMECLOCK>
ffffffe000200d48:	fef43423          	sd	a5,-24(s0)
    pa = (uint64)(&_sdata) - PA2VA_OFFSET;
ffffffe000200d4c:	00002717          	auipc	a4,0x2
ffffffe000200d50:	2b470713          	addi	a4,a4,692 # ffffffe000203000 <TIMECLOCK>
ffffffe000200d54:	04100793          	li	a5,65
ffffffe000200d58:	01f79793          	slli	a5,a5,0x1f
ffffffe000200d5c:	00f707b3          	add	a5,a4,a5
ffffffe000200d60:	fef43023          	sd	a5,-32(s0)
    sz = PHY_SIZE - ((uint64)(&_sdata) - (uint64)&_stext);
ffffffe000200d64:	fffff717          	auipc	a4,0xfffff
ffffffe000200d68:	29c70713          	addi	a4,a4,668 # ffffffe000200000 <_skernel>
ffffffe000200d6c:	002107b7          	lui	a5,0x210
ffffffe000200d70:	00f70733          	add	a4,a4,a5
ffffffe000200d74:	00002797          	auipc	a5,0x2
ffffffe000200d78:	28c78793          	addi	a5,a5,652 # ffffffe000203000 <TIMECLOCK>
ffffffe000200d7c:	40f707b3          	sub	a5,a4,a5
ffffffe000200d80:	fcf43c23          	sd	a5,-40(s0)
    create_mapping(swapper_pg_dir, va, pa, sz, 0x7 | 0x80 | 0x40);
ffffffe000200d84:	0c700713          	li	a4,199
ffffffe000200d88:	fd843683          	ld	a3,-40(s0)
ffffffe000200d8c:	fe043603          	ld	a2,-32(s0)
ffffffe000200d90:	fe843583          	ld	a1,-24(s0)
ffffffe000200d94:	00006517          	auipc	a0,0x6
ffffffe000200d98:	26c50513          	addi	a0,a0,620 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200d9c:	050000ef          	jal	ra,ffffffe000200dec <create_mapping>
  
    // set satp with swapper_pg_dir

    // printk("...create_mapping\n");
    uint64 satp = (((uint64)(swapper_pg_dir) - PA2VA_OFFSET) >> 12) | (1L << 63);
ffffffe000200da0:	00006717          	auipc	a4,0x6
ffffffe000200da4:	26070713          	addi	a4,a4,608 # ffffffe000207000 <swapper_pg_dir>
ffffffe000200da8:	04100793          	li	a5,65
ffffffe000200dac:	01f79793          	slli	a5,a5,0x1f
ffffffe000200db0:	00f707b3          	add	a5,a4,a5
ffffffe000200db4:	00c7d713          	srli	a4,a5,0xc
ffffffe000200db8:	fff00793          	li	a5,-1
ffffffe000200dbc:	03f79793          	slli	a5,a5,0x3f
ffffffe000200dc0:	00f767b3          	or	a5,a4,a5
ffffffe000200dc4:	fcf43823          	sd	a5,-48(s0)
    // 一定要写成 1L，写 1 是过不了的
    __asm__ volatile("csrw satp, %[_satp]" ::[_satp] "r" (satp) :);
ffffffe000200dc8:	fd043783          	ld	a5,-48(s0)
ffffffe000200dcc:	18079073          	csrw	satp,a5

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000200dd0:	12000073          	sfence.vma

    // flush icache
    asm volatile("fence.i");
ffffffe000200dd4:	0000100f          	fence.i

    return;
ffffffe000200dd8:	00000013          	nop
}
ffffffe000200ddc:	02813083          	ld	ra,40(sp)
ffffffe000200de0:	02013403          	ld	s0,32(sp)
ffffffe000200de4:	03010113          	addi	sp,sp,48
ffffffe000200de8:	00008067          	ret

ffffffe000200dec <create_mapping>:


/* 创建多级页表映射关系 */
void create_mapping(uint64 *pgtbl, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
ffffffe000200dec:	f8010113          	addi	sp,sp,-128
ffffffe000200df0:	06113c23          	sd	ra,120(sp)
ffffffe000200df4:	06813823          	sd	s0,112(sp)
ffffffe000200df8:	08010413          	addi	s0,sp,128
ffffffe000200dfc:	faa43423          	sd	a0,-88(s0)
ffffffe000200e00:	fab43023          	sd	a1,-96(s0)
ffffffe000200e04:	f8c43c23          	sd	a2,-104(s0)
ffffffe000200e08:	f8d43823          	sd	a3,-112(s0)
ffffffe000200e0c:	f8e43423          	sd	a4,-120(s0)
    将给定的一段虚拟内存映射到物理内存上
    物理内存需要分页
    创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
    可以使用 V bit 来判断页表项是否存在
    */
   uint64 end = va + sz;
ffffffe000200e10:	fa043703          	ld	a4,-96(s0)
ffffffe000200e14:	f9043783          	ld	a5,-112(s0)
ffffffe000200e18:	00f707b3          	add	a5,a4,a5
ffffffe000200e1c:	fcf43c23          	sd	a5,-40(s0)
   uint64 vpn2, vpn1, vpn0;
   while (va < end)
ffffffe000200e20:	1980006f          	j	ffffffe000200fb8 <create_mapping+0x1cc>
   {
        vpn2 = (va & 0x7FC0000000) >> 30;
ffffffe000200e24:	fa043783          	ld	a5,-96(s0)
ffffffe000200e28:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200e2c:	1ff7f793          	andi	a5,a5,511
ffffffe000200e30:	fcf43823          	sd	a5,-48(s0)
        vpn1 = (va & 0x3FE00000) >> 21;
ffffffe000200e34:	fa043783          	ld	a5,-96(s0)
ffffffe000200e38:	0157d793          	srli	a5,a5,0x15
ffffffe000200e3c:	1ff7f793          	andi	a5,a5,511
ffffffe000200e40:	fcf43423          	sd	a5,-56(s0)
        vpn0 = (va & 0x1FF000) >> 12;
ffffffe000200e44:	fa043783          	ld	a5,-96(s0)
ffffffe000200e48:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e4c:	1ff7f793          	andi	a5,a5,511
ffffffe000200e50:	fcf43023          	sd	a5,-64(s0)

        uint64 *pgtbl_first = pgtbl;
ffffffe000200e54:	fa843783          	ld	a5,-88(s0)
ffffffe000200e58:	faf43c23          	sd	a5,-72(s0)
        uint64 *pgtbl_second;
        if(pgtbl_first[vpn2] & 0x1){
ffffffe000200e5c:	fd043783          	ld	a5,-48(s0)
ffffffe000200e60:	00379793          	slli	a5,a5,0x3
ffffffe000200e64:	fb843703          	ld	a4,-72(s0)
ffffffe000200e68:	00f707b3          	add	a5,a4,a5
ffffffe000200e6c:	0007b783          	ld	a5,0(a5)
ffffffe000200e70:	0017f793          	andi	a5,a5,1
ffffffe000200e74:	02078463          	beqz	a5,ffffffe000200e9c <create_mapping+0xb0>
            pgtbl_second = (uint64)((pgtbl[vpn2] >> 10) << 12);
ffffffe000200e78:	fd043783          	ld	a5,-48(s0)
ffffffe000200e7c:	00379793          	slli	a5,a5,0x3
ffffffe000200e80:	fa843703          	ld	a4,-88(s0)
ffffffe000200e84:	00f707b3          	add	a5,a4,a5
ffffffe000200e88:	0007b783          	ld	a5,0(a5)
ffffffe000200e8c:	00a7d793          	srli	a5,a5,0xa
ffffffe000200e90:	00c79793          	slli	a5,a5,0xc
ffffffe000200e94:	fef43423          	sd	a5,-24(s0)
ffffffe000200e98:	0400006f          	j	ffffffe000200ed8 <create_mapping+0xec>
        }else {
            pgtbl_second = (uint64)(kalloc() - PA2VA_OFFSET);
ffffffe000200e9c:	c64ff0ef          	jal	ra,ffffffe000200300 <kalloc>
ffffffe000200ea0:	00050793          	mv	a5,a0
ffffffe000200ea4:	00078713          	mv	a4,a5
ffffffe000200ea8:	04100793          	li	a5,65
ffffffe000200eac:	01f79793          	slli	a5,a5,0x1f
ffffffe000200eb0:	00f707b3          	add	a5,a4,a5
ffffffe000200eb4:	fef43423          	sd	a5,-24(s0)
            pgtbl_first[vpn2] = (((uint64)pgtbl_second >> 2) | 1);
ffffffe000200eb8:	fe843783          	ld	a5,-24(s0)
ffffffe000200ebc:	0027d713          	srli	a4,a5,0x2
ffffffe000200ec0:	fd043783          	ld	a5,-48(s0)
ffffffe000200ec4:	00379793          	slli	a5,a5,0x3
ffffffe000200ec8:	fb843683          	ld	a3,-72(s0)
ffffffe000200ecc:	00f687b3          	add	a5,a3,a5
ffffffe000200ed0:	00176713          	ori	a4,a4,1
ffffffe000200ed4:	00e7b023          	sd	a4,0(a5)
        }

        uint64 *pgtbl_third;
        if(pgtbl_second[vpn1] & 0x1){
ffffffe000200ed8:	fc843783          	ld	a5,-56(s0)
ffffffe000200edc:	00379793          	slli	a5,a5,0x3
ffffffe000200ee0:	fe843703          	ld	a4,-24(s0)
ffffffe000200ee4:	00f707b3          	add	a5,a4,a5
ffffffe000200ee8:	0007b783          	ld	a5,0(a5)
ffffffe000200eec:	0017f793          	andi	a5,a5,1
ffffffe000200ef0:	02078463          	beqz	a5,ffffffe000200f18 <create_mapping+0x12c>
            pgtbl_third = (uint64)((pgtbl_second[vpn1] >> 10) << 12);
ffffffe000200ef4:	fc843783          	ld	a5,-56(s0)
ffffffe000200ef8:	00379793          	slli	a5,a5,0x3
ffffffe000200efc:	fe843703          	ld	a4,-24(s0)
ffffffe000200f00:	00f707b3          	add	a5,a4,a5
ffffffe000200f04:	0007b783          	ld	a5,0(a5)
ffffffe000200f08:	00a7d793          	srli	a5,a5,0xa
ffffffe000200f0c:	00c79793          	slli	a5,a5,0xc
ffffffe000200f10:	fef43023          	sd	a5,-32(s0)
ffffffe000200f14:	0400006f          	j	ffffffe000200f54 <create_mapping+0x168>
        }else {
            pgtbl_third = (uint64)(kalloc() - PA2VA_OFFSET);
ffffffe000200f18:	be8ff0ef          	jal	ra,ffffffe000200300 <kalloc>
ffffffe000200f1c:	00050793          	mv	a5,a0
ffffffe000200f20:	00078713          	mv	a4,a5
ffffffe000200f24:	04100793          	li	a5,65
ffffffe000200f28:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f2c:	00f707b3          	add	a5,a4,a5
ffffffe000200f30:	fef43023          	sd	a5,-32(s0)
            pgtbl_second[vpn1] = (((uint64)pgtbl_third >> 2) | 1);
ffffffe000200f34:	fe043783          	ld	a5,-32(s0)
ffffffe000200f38:	0027d713          	srli	a4,a5,0x2
ffffffe000200f3c:	fc843783          	ld	a5,-56(s0)
ffffffe000200f40:	00379793          	slli	a5,a5,0x3
ffffffe000200f44:	fe843683          	ld	a3,-24(s0)
ffffffe000200f48:	00f687b3          	add	a5,a3,a5
ffffffe000200f4c:	00176713          	ori	a4,a4,1
ffffffe000200f50:	00e7b023          	sd	a4,0(a5)
        }

        if(!(pgtbl_third[vpn0] & 0x1)){
ffffffe000200f54:	fc043783          	ld	a5,-64(s0)
ffffffe000200f58:	00379793          	slli	a5,a5,0x3
ffffffe000200f5c:	fe043703          	ld	a4,-32(s0)
ffffffe000200f60:	00f707b3          	add	a5,a4,a5
ffffffe000200f64:	0007b783          	ld	a5,0(a5)
ffffffe000200f68:	0017f793          	andi	a5,a5,1
ffffffe000200f6c:	02079663          	bnez	a5,ffffffe000200f98 <create_mapping+0x1ac>
            pgtbl_third[vpn0] = (((pa >> 12) << 10) | perm);
ffffffe000200f70:	f9843783          	ld	a5,-104(s0)
ffffffe000200f74:	00c7d793          	srli	a5,a5,0xc
ffffffe000200f78:	00a79693          	slli	a3,a5,0xa
ffffffe000200f7c:	fc043783          	ld	a5,-64(s0)
ffffffe000200f80:	00379793          	slli	a5,a5,0x3
ffffffe000200f84:	fe043703          	ld	a4,-32(s0)
ffffffe000200f88:	00f707b3          	add	a5,a4,a5
ffffffe000200f8c:	f8843703          	ld	a4,-120(s0)
ffffffe000200f90:	00e6e733          	or	a4,a3,a4
ffffffe000200f94:	00e7b023          	sd	a4,0(a5)
        }

        va += PGSIZE;
ffffffe000200f98:	fa043703          	ld	a4,-96(s0)
ffffffe000200f9c:	000017b7          	lui	a5,0x1
ffffffe000200fa0:	00f707b3          	add	a5,a4,a5
ffffffe000200fa4:	faf43023          	sd	a5,-96(s0)
        pa += PGSIZE;
ffffffe000200fa8:	f9843703          	ld	a4,-104(s0)
ffffffe000200fac:	000017b7          	lui	a5,0x1
ffffffe000200fb0:	00f707b3          	add	a5,a4,a5
ffffffe000200fb4:	f8f43c23          	sd	a5,-104(s0)
   while (va < end)
ffffffe000200fb8:	fa043703          	ld	a4,-96(s0)
ffffffe000200fbc:	fd843783          	ld	a5,-40(s0)
ffffffe000200fc0:	e6f762e3          	bltu	a4,a5,ffffffe000200e24 <create_mapping+0x38>
   }
   
}
ffffffe000200fc4:	00000013          	nop
ffffffe000200fc8:	00000013          	nop
ffffffe000200fcc:	07813083          	ld	ra,120(sp)
ffffffe000200fd0:	07013403          	ld	s0,112(sp)
ffffffe000200fd4:	08010113          	addi	sp,sp,128
ffffffe000200fd8:	00008067          	ret

ffffffe000200fdc <start_kernel>:
extern char _srodata[];
extern char _sdata[];
extern char _sbss[];

int start_kernel() 
{
ffffffe000200fdc:	ff010113          	addi	sp,sp,-16
ffffffe000200fe0:	00113423          	sd	ra,8(sp)
ffffffe000200fe4:	00813023          	sd	s0,0(sp)
ffffffe000200fe8:	01010413          	addi	s0,sp,16
    // printk("%d", 2024);
    printk("2024 ZJU Computer System III\n");
ffffffe000200fec:	00001517          	auipc	a0,0x1
ffffffe000200ff0:	15450513          	addi	a0,a0,340 # ffffffe000202140 <_srodata+0x140>
ffffffe000200ff4:	0a9000ef          	jal	ra,ffffffe00020189c <printk>
    // *_srodata = 0;

    // printk("_stext = %ld\n", *_stext);
    // printk("_srodata = %ld\n", *_srodata);

    test(); // DO NOT DELETE !!!
ffffffe000200ff8:	01c000ef          	jal	ra,ffffffe000201014 <test>

	return 0;
ffffffe000200ffc:	00000793          	li	a5,0
}
ffffffe000201000:	00078513          	mv	a0,a5
ffffffe000201004:	00813083          	ld	ra,8(sp)
ffffffe000201008:	00013403          	ld	s0,0(sp)
ffffffe00020100c:	01010113          	addi	sp,sp,16
ffffffe000201010:	00008067          	ret

ffffffe000201014 <test>:
#include "defs.h"
#include "math.h"

// Please do not modify

void test() {
ffffffe000201014:	fe010113          	addi	sp,sp,-32
ffffffe000201018:	00813c23          	sd	s0,24(sp)
ffffffe00020101c:	02010413          	addi	s0,sp,32
   unsigned long record_time = 0; 
ffffffe000201020:	fe043423          	sd	zero,-24(s0)
    while (1) {
ffffffe000201024:	0000006f          	j	ffffffe000201024 <test+0x10>

ffffffe000201028 <__udivsi3>:
# define __divdi3 __divsi3
# define __moddi3 __modsi3
#else
FUNC_BEGIN (__udivsi3)
  /* Compute __udivdi3(a0 << 32, a1 << 32); cast result to uint32_t.  */
  sll    a0, a0, 32
ffffffe000201028:	02051513          	slli	a0,a0,0x20
  sll    a1, a1, 32
ffffffe00020102c:	02059593          	slli	a1,a1,0x20
  move   t0, ra
ffffffe000201030:	00008293          	mv	t0,ra
  jal    HIDDEN_JUMPTARGET(__udivdi3)
ffffffe000201034:	03c000ef          	jal	ra,ffffffe000201070 <__hidden___udivdi3>
  sext.w a0, a0
ffffffe000201038:	0005051b          	sext.w	a0,a0
  jr     t0
ffffffe00020103c:	00028067          	jr	t0

ffffffe000201040 <__umodsi3>:
FUNC_END (__udivsi3)

FUNC_BEGIN (__umodsi3)
  /* Compute __udivdi3((uint32_t)a0, (uint32_t)a1); cast a1 to uint32_t.  */
  sll    a0, a0, 32
ffffffe000201040:	02051513          	slli	a0,a0,0x20
  sll    a1, a1, 32
ffffffe000201044:	02059593          	slli	a1,a1,0x20
  srl    a0, a0, 32
ffffffe000201048:	02055513          	srli	a0,a0,0x20
  srl    a1, a1, 32
ffffffe00020104c:	0205d593          	srli	a1,a1,0x20
  move   t0, ra
ffffffe000201050:	00008293          	mv	t0,ra
  jal    HIDDEN_JUMPTARGET(__udivdi3)
ffffffe000201054:	01c000ef          	jal	ra,ffffffe000201070 <__hidden___udivdi3>
  sext.w a0, a1
ffffffe000201058:	0005851b          	sext.w	a0,a1
  jr     t0
ffffffe00020105c:	00028067          	jr	t0

ffffffe000201060 <__divsi3>:

FUNC_ALIAS (__modsi3, __moddi3)

FUNC_BEGIN( __divsi3)
  /* Check for special case of INT_MIN/-1. Otherwise, fall into __divdi3.  */
  li    t0, -1
ffffffe000201060:	fff00293          	li	t0,-1
  beq   a1, t0, .L20
ffffffe000201064:	0a558c63          	beq	a1,t0,ffffffe00020111c <__moddi3+0x30>

ffffffe000201068 <__divdi3>:
#endif

FUNC_BEGIN (__divdi3)
  bltz  a0, .L10
ffffffe000201068:	06054063          	bltz	a0,ffffffe0002010c8 <__umoddi3+0x10>
  bltz  a1, .L11
ffffffe00020106c:	0605c663          	bltz	a1,ffffffe0002010d8 <__umoddi3+0x20>

ffffffe000201070 <__hidden___udivdi3>:
  /* Since the quotient is positive, fall into __udivdi3.  */

FUNC_BEGIN (__udivdi3)
  mv    a2, a1
ffffffe000201070:	00058613          	mv	a2,a1
  mv    a1, a0
ffffffe000201074:	00050593          	mv	a1,a0
  li    a0, -1
ffffffe000201078:	fff00513          	li	a0,-1
  beqz  a2, .L5
ffffffe00020107c:	02060c63          	beqz	a2,ffffffe0002010b4 <__hidden___udivdi3+0x44>
  li    a3, 1
ffffffe000201080:	00100693          	li	a3,1
  bgeu  a2, a1, .L2
ffffffe000201084:	00b67a63          	bgeu	a2,a1,ffffffe000201098 <__hidden___udivdi3+0x28>
.L1:
  blez  a2, .L2
ffffffe000201088:	00c05863          	blez	a2,ffffffe000201098 <__hidden___udivdi3+0x28>
  slli  a2, a2, 1
ffffffe00020108c:	00161613          	slli	a2,a2,0x1
  slli  a3, a3, 1
ffffffe000201090:	00169693          	slli	a3,a3,0x1
  bgtu  a1, a2, .L1
ffffffe000201094:	feb66ae3          	bltu	a2,a1,ffffffe000201088 <__hidden___udivdi3+0x18>
.L2:
  li    a0, 0
ffffffe000201098:	00000513          	li	a0,0
.L3:
  bltu  a1, a2, .L4
ffffffe00020109c:	00c5e663          	bltu	a1,a2,ffffffe0002010a8 <__hidden___udivdi3+0x38>
  sub   a1, a1, a2
ffffffe0002010a0:	40c585b3          	sub	a1,a1,a2
  or    a0, a0, a3
ffffffe0002010a4:	00d56533          	or	a0,a0,a3
.L4:
  srli  a3, a3, 1
ffffffe0002010a8:	0016d693          	srli	a3,a3,0x1
  srli  a2, a2, 1
ffffffe0002010ac:	00165613          	srli	a2,a2,0x1
  bnez  a3, .L3
ffffffe0002010b0:	fe0696e3          	bnez	a3,ffffffe00020109c <__hidden___udivdi3+0x2c>
.L5:
  ret
ffffffe0002010b4:	00008067          	ret

ffffffe0002010b8 <__umoddi3>:
FUNC_END (__udivdi3)
HIDDEN_DEF (__udivdi3)

FUNC_BEGIN (__umoddi3)
  /* Call __udivdi3(a0, a1), then return the remainder, which is in a1.  */
  move  t0, ra
ffffffe0002010b8:	00008293          	mv	t0,ra
  jal   HIDDEN_JUMPTARGET(__udivdi3)
ffffffe0002010bc:	fb5ff0ef          	jal	ra,ffffffe000201070 <__hidden___udivdi3>
  move  a0, a1
ffffffe0002010c0:	00058513          	mv	a0,a1
  jr    t0
ffffffe0002010c4:	00028067          	jr	t0
FUNC_END (__umoddi3)

  /* Handle negative arguments to __divdi3.  */
.L10:
  neg   a0, a0
ffffffe0002010c8:	40a00533          	neg	a0,a0
  /* Zero is handled as a negative so that the result will not be inverted.  */
  bgtz  a1, .L12     /* Compute __udivdi3(-a0, a1), then negate the result.  */
ffffffe0002010cc:	00b04863          	bgtz	a1,ffffffe0002010dc <__umoddi3+0x24>

  neg   a1, a1
ffffffe0002010d0:	40b005b3          	neg	a1,a1
  j     HIDDEN_JUMPTARGET(__udivdi3)     /* Compute __udivdi3(-a0, -a1).  */
ffffffe0002010d4:	f9dff06f          	j	ffffffe000201070 <__hidden___udivdi3>
.L11:                /* Compute __udivdi3(a0, -a1), then negate the result.  */
  neg   a1, a1
ffffffe0002010d8:	40b005b3          	neg	a1,a1
.L12:
  move  t0, ra
ffffffe0002010dc:	00008293          	mv	t0,ra
  jal   HIDDEN_JUMPTARGET(__udivdi3)
ffffffe0002010e0:	f91ff0ef          	jal	ra,ffffffe000201070 <__hidden___udivdi3>
  neg   a0, a0
ffffffe0002010e4:	40a00533          	neg	a0,a0
  jr    t0
ffffffe0002010e8:	00028067          	jr	t0

ffffffe0002010ec <__moddi3>:
FUNC_END (__divdi3)

FUNC_BEGIN (__moddi3)
  move   t0, ra
ffffffe0002010ec:	00008293          	mv	t0,ra
  bltz   a1, .L31
ffffffe0002010f0:	0005ca63          	bltz	a1,ffffffe000201104 <__moddi3+0x18>
  bltz   a0, .L32
ffffffe0002010f4:	00054c63          	bltz	a0,ffffffe00020110c <__moddi3+0x20>
.L30:
  jal    HIDDEN_JUMPTARGET(__udivdi3)    /* The dividend is not negative.  */
ffffffe0002010f8:	f79ff0ef          	jal	ra,ffffffe000201070 <__hidden___udivdi3>
  move   a0, a1
ffffffe0002010fc:	00058513          	mv	a0,a1
  jr     t0
ffffffe000201100:	00028067          	jr	t0
.L31:
  neg    a1, a1
ffffffe000201104:	40b005b3          	neg	a1,a1
  bgez   a0, .L30
ffffffe000201108:	fe0558e3          	bgez	a0,ffffffe0002010f8 <__moddi3+0xc>
.L32:
  neg    a0, a0
ffffffe00020110c:	40a00533          	neg	a0,a0
  jal    HIDDEN_JUMPTARGET(__udivdi3)    /* The dividend is hella negative.  */
ffffffe000201110:	f61ff0ef          	jal	ra,ffffffe000201070 <__hidden___udivdi3>
  neg    a0, a1
ffffffe000201114:	40b00533          	neg	a0,a1
  jr     t0
ffffffe000201118:	00028067          	jr	t0
FUNC_END (__moddi3)

#if __riscv_xlen == 64
  /* continuation of __divsi3 */
.L20:
  sll   t0, t0, 31
ffffffe00020111c:	01f29293          	slli	t0,t0,0x1f
  bne   a0, t0, __divdi3
ffffffe000201120:	f45514e3          	bne	a0,t0,ffffffe000201068 <__divdi3>
  ret
ffffffe000201124:	00008067          	ret

ffffffe000201128 <int_mod>:
#include"math.h"
int int_mod(unsigned int v1,unsigned int v2){
ffffffe000201128:	fd010113          	addi	sp,sp,-48
ffffffe00020112c:	02813423          	sd	s0,40(sp)
ffffffe000201130:	03010413          	addi	s0,sp,48
ffffffe000201134:	00050793          	mv	a5,a0
ffffffe000201138:	00058713          	mv	a4,a1
ffffffe00020113c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201140:	00070793          	mv	a5,a4
ffffffe000201144:	fcf42c23          	sw	a5,-40(s0)
    unsigned long long m1=v1;
ffffffe000201148:	fdc46783          	lwu	a5,-36(s0)
ffffffe00020114c:	fef43423          	sd	a5,-24(s0)
    unsigned long long m2=v2;
ffffffe000201150:	fd846783          	lwu	a5,-40(s0)
ffffffe000201154:	fef43023          	sd	a5,-32(s0)
    m2<<=31;
ffffffe000201158:	fe043783          	ld	a5,-32(s0)
ffffffe00020115c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201160:	fef43023          	sd	a5,-32(s0)
    while(m1>=v2){
ffffffe000201164:	02c0006f          	j	ffffffe000201190 <int_mod+0x68>
        if(m2<m1){
ffffffe000201168:	fe043703          	ld	a4,-32(s0)
ffffffe00020116c:	fe843783          	ld	a5,-24(s0)
ffffffe000201170:	00f77a63          	bgeu	a4,a5,ffffffe000201184 <int_mod+0x5c>
            m1-=m2;
ffffffe000201174:	fe843703          	ld	a4,-24(s0)
ffffffe000201178:	fe043783          	ld	a5,-32(s0)
ffffffe00020117c:	40f707b3          	sub	a5,a4,a5
ffffffe000201180:	fef43423          	sd	a5,-24(s0)
        }
        m2>>=1;
ffffffe000201184:	fe043783          	ld	a5,-32(s0)
ffffffe000201188:	0017d793          	srli	a5,a5,0x1
ffffffe00020118c:	fef43023          	sd	a5,-32(s0)
    while(m1>=v2){
ffffffe000201190:	fd846783          	lwu	a5,-40(s0)
ffffffe000201194:	fe843703          	ld	a4,-24(s0)
ffffffe000201198:	fcf778e3          	bgeu	a4,a5,ffffffe000201168 <int_mod+0x40>
    }
    return m1;
ffffffe00020119c:	fe843783          	ld	a5,-24(s0)
ffffffe0002011a0:	0007879b          	sext.w	a5,a5
}
ffffffe0002011a4:	00078513          	mv	a0,a5
ffffffe0002011a8:	02813403          	ld	s0,40(sp)
ffffffe0002011ac:	03010113          	addi	sp,sp,48
ffffffe0002011b0:	00008067          	ret

ffffffe0002011b4 <int_mul>:

int int_mul(unsigned int v1,unsigned int v2){
ffffffe0002011b4:	fd010113          	addi	sp,sp,-48
ffffffe0002011b8:	02813423          	sd	s0,40(sp)
ffffffe0002011bc:	03010413          	addi	s0,sp,48
ffffffe0002011c0:	00050793          	mv	a5,a0
ffffffe0002011c4:	00058713          	mv	a4,a1
ffffffe0002011c8:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002011cc:	00070793          	mv	a5,a4
ffffffe0002011d0:	fcf42c23          	sw	a5,-40(s0)
    unsigned long long res=0;
ffffffe0002011d4:	fe043423          	sd	zero,-24(s0)
    while(v2&&v1){
ffffffe0002011d8:	03c0006f          	j	ffffffe000201214 <int_mul+0x60>
        if(v2&1){
ffffffe0002011dc:	fd842783          	lw	a5,-40(s0)
ffffffe0002011e0:	0017f793          	andi	a5,a5,1
ffffffe0002011e4:	0007879b          	sext.w	a5,a5
ffffffe0002011e8:	00078a63          	beqz	a5,ffffffe0002011fc <int_mul+0x48>
            res+=v1;
ffffffe0002011ec:	fdc46783          	lwu	a5,-36(s0)
ffffffe0002011f0:	fe843703          	ld	a4,-24(s0)
ffffffe0002011f4:	00f707b3          	add	a5,a4,a5
ffffffe0002011f8:	fef43423          	sd	a5,-24(s0)
        }
        v2>>=1;
ffffffe0002011fc:	fd842783          	lw	a5,-40(s0)
ffffffe000201200:	0017d79b          	srliw	a5,a5,0x1
ffffffe000201204:	fcf42c23          	sw	a5,-40(s0)
        v1<<=1;
ffffffe000201208:	fdc42783          	lw	a5,-36(s0)
ffffffe00020120c:	0017979b          	slliw	a5,a5,0x1
ffffffe000201210:	fcf42e23          	sw	a5,-36(s0)
    while(v2&&v1){
ffffffe000201214:	fd842783          	lw	a5,-40(s0)
ffffffe000201218:	0007879b          	sext.w	a5,a5
ffffffe00020121c:	00078863          	beqz	a5,ffffffe00020122c <int_mul+0x78>
ffffffe000201220:	fdc42783          	lw	a5,-36(s0)
ffffffe000201224:	0007879b          	sext.w	a5,a5
ffffffe000201228:	fa079ae3          	bnez	a5,ffffffe0002011dc <int_mul+0x28>
    }
    return res;
ffffffe00020122c:	fe843783          	ld	a5,-24(s0)
ffffffe000201230:	0007879b          	sext.w	a5,a5
}
ffffffe000201234:	00078513          	mv	a0,a5
ffffffe000201238:	02813403          	ld	s0,40(sp)
ffffffe00020123c:	03010113          	addi	sp,sp,48
ffffffe000201240:	00008067          	ret

ffffffe000201244 <int_div>:

int int_div(unsigned int v1,unsigned int v2){
ffffffe000201244:	fc010113          	addi	sp,sp,-64
ffffffe000201248:	02813c23          	sd	s0,56(sp)
ffffffe00020124c:	04010413          	addi	s0,sp,64
ffffffe000201250:	00050793          	mv	a5,a0
ffffffe000201254:	00058713          	mv	a4,a1
ffffffe000201258:	fcf42623          	sw	a5,-52(s0)
ffffffe00020125c:	00070793          	mv	a5,a4
ffffffe000201260:	fcf42423          	sw	a5,-56(s0)
    unsigned long long m1=v1;
ffffffe000201264:	fcc46783          	lwu	a5,-52(s0)
ffffffe000201268:	fef43423          	sd	a5,-24(s0)
    unsigned long long m2=v2;
ffffffe00020126c:	fc846783          	lwu	a5,-56(s0)
ffffffe000201270:	fef43023          	sd	a5,-32(s0)
    unsigned long long mask=(unsigned int)1<<31;
ffffffe000201274:	00100793          	li	a5,1
ffffffe000201278:	01f79793          	slli	a5,a5,0x1f
ffffffe00020127c:	fcf43c23          	sd	a5,-40(s0)
    m2<<=31;
ffffffe000201280:	fe043783          	ld	a5,-32(s0)
ffffffe000201284:	01f79793          	slli	a5,a5,0x1f
ffffffe000201288:	fef43023          	sd	a5,-32(s0)
    unsigned long long res=0;
ffffffe00020128c:	fc043823          	sd	zero,-48(s0)
    while(m1>=v2){
ffffffe000201290:	0480006f          	j	ffffffe0002012d8 <int_div+0x94>
        if(m2<m1){
ffffffe000201294:	fe043703          	ld	a4,-32(s0)
ffffffe000201298:	fe843783          	ld	a5,-24(s0)
ffffffe00020129c:	02f77263          	bgeu	a4,a5,ffffffe0002012c0 <int_div+0x7c>
            m1-=m2;
ffffffe0002012a0:	fe843703          	ld	a4,-24(s0)
ffffffe0002012a4:	fe043783          	ld	a5,-32(s0)
ffffffe0002012a8:	40f707b3          	sub	a5,a4,a5
ffffffe0002012ac:	fef43423          	sd	a5,-24(s0)
            res|=mask;
ffffffe0002012b0:	fd043703          	ld	a4,-48(s0)
ffffffe0002012b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002012b8:	00f767b3          	or	a5,a4,a5
ffffffe0002012bc:	fcf43823          	sd	a5,-48(s0)
        }
        m2>>=1;
ffffffe0002012c0:	fe043783          	ld	a5,-32(s0)
ffffffe0002012c4:	0017d793          	srli	a5,a5,0x1
ffffffe0002012c8:	fef43023          	sd	a5,-32(s0)
        mask>>=1;
ffffffe0002012cc:	fd843783          	ld	a5,-40(s0)
ffffffe0002012d0:	0017d793          	srli	a5,a5,0x1
ffffffe0002012d4:	fcf43c23          	sd	a5,-40(s0)
    while(m1>=v2){
ffffffe0002012d8:	fc846783          	lwu	a5,-56(s0)
ffffffe0002012dc:	fe843703          	ld	a4,-24(s0)
ffffffe0002012e0:	faf77ae3          	bgeu	a4,a5,ffffffe000201294 <int_div+0x50>
    }
    return res;
ffffffe0002012e4:	fd043783          	ld	a5,-48(s0)
ffffffe0002012e8:	0007879b          	sext.w	a5,a5
ffffffe0002012ec:	00078513          	mv	a0,a5
ffffffe0002012f0:	03813403          	ld	s0,56(sp)
ffffffe0002012f4:	04010113          	addi	sp,sp,64
ffffffe0002012f8:	00008067          	ret

ffffffe0002012fc <__muldi3>:
/* Our RV64 64-bit routine is equivalent to our RV32 32-bit routine.  */
# define __muldi3 __mulsi3
#endif

FUNC_BEGIN (__muldi3)
  mv     a2, a0
ffffffe0002012fc:	00050613          	mv	a2,a0
  li     a0, 0
ffffffe000201300:	00000513          	li	a0,0
.L1:
  andi   a3, a1, 1
ffffffe000201304:	0015f693          	andi	a3,a1,1
  beqz   a3, .L2
ffffffe000201308:	00068463          	beqz	a3,ffffffe000201310 <__muldi3+0x14>
  add    a0, a0, a2
ffffffe00020130c:	00c50533          	add	a0,a0,a2
.L2:
  srli   a1, a1, 1
ffffffe000201310:	0015d593          	srli	a1,a1,0x1
  slli   a2, a2, 1
ffffffe000201314:	00161613          	slli	a2,a2,0x1
  bnez   a1, .L1
ffffffe000201318:	fe0596e3          	bnez	a1,ffffffe000201304 <__muldi3+0x8>
  ret
ffffffe00020131c:	00008067          	ret

ffffffe000201320 <putc>:
#include "printk.h"
#include "sbi.h"
#include "math.h"

void putc(char c) {
ffffffe000201320:	fe010113          	addi	sp,sp,-32
ffffffe000201324:	00113c23          	sd	ra,24(sp)
ffffffe000201328:	00813823          	sd	s0,16(sp)
ffffffe00020132c:	02010413          	addi	s0,sp,32
ffffffe000201330:	00050793          	mv	a5,a0
ffffffe000201334:	fef407a3          	sb	a5,-17(s0)
  sbi_ecall(SBI_PUTCHAR, 0, c, 0, 0, 0, 0, 0);
ffffffe000201338:	fef44603          	lbu	a2,-17(s0)
ffffffe00020133c:	00000893          	li	a7,0
ffffffe000201340:	00000813          	li	a6,0
ffffffe000201344:	00000793          	li	a5,0
ffffffe000201348:	00000713          	li	a4,0
ffffffe00020134c:	00000693          	li	a3,0
ffffffe000201350:	00000593          	li	a1,0
ffffffe000201354:	00100513          	li	a0,1
ffffffe000201358:	f00ff0ef          	jal	ra,ffffffe000200a58 <sbi_ecall>
}
ffffffe00020135c:	00000013          	nop
ffffffe000201360:	01813083          	ld	ra,24(sp)
ffffffe000201364:	01013403          	ld	s0,16(sp)
ffffffe000201368:	02010113          	addi	sp,sp,32
ffffffe00020136c:	00008067          	ret

ffffffe000201370 <vprintfmt>:

static int vprintfmt(void(*putch)(char), const char *fmt, va_list vl) {
ffffffe000201370:	f2010113          	addi	sp,sp,-224
ffffffe000201374:	0c113c23          	sd	ra,216(sp)
ffffffe000201378:	0c813823          	sd	s0,208(sp)
ffffffe00020137c:	0e010413          	addi	s0,sp,224
ffffffe000201380:	f2a43c23          	sd	a0,-200(s0)
ffffffe000201384:	f2b43823          	sd	a1,-208(s0)
ffffffe000201388:	f2c43423          	sd	a2,-216(s0)
    int in_format = 0, longarg = 0;
ffffffe00020138c:	fe042623          	sw	zero,-20(s0)
ffffffe000201390:	fe042423          	sw	zero,-24(s0)
    size_t pos = 0;
ffffffe000201394:	fe043023          	sd	zero,-32(s0)
    for( ; *fmt; fmt++) {
ffffffe000201398:	4dc0006f          	j	ffffffe000201874 <vprintfmt+0x504>
        if (in_format) {
ffffffe00020139c:	fec42783          	lw	a5,-20(s0)
ffffffe0002013a0:	0007879b          	sext.w	a5,a5
ffffffe0002013a4:	46078e63          	beqz	a5,ffffffe000201820 <vprintfmt+0x4b0>
            switch(*fmt) {
ffffffe0002013a8:	f3043783          	ld	a5,-208(s0)
ffffffe0002013ac:	0007c783          	lbu	a5,0(a5) # 1000 <_skernel-0xffffffe0001ff000>
ffffffe0002013b0:	0007879b          	sext.w	a5,a5
ffffffe0002013b4:	f9d7869b          	addiw	a3,a5,-99
ffffffe0002013b8:	0006871b          	sext.w	a4,a3
ffffffe0002013bc:	01500793          	li	a5,21
ffffffe0002013c0:	4ae7e263          	bltu	a5,a4,ffffffe000201864 <vprintfmt+0x4f4>
ffffffe0002013c4:	02069793          	slli	a5,a3,0x20
ffffffe0002013c8:	0207d793          	srli	a5,a5,0x20
ffffffe0002013cc:	00279713          	slli	a4,a5,0x2
ffffffe0002013d0:	00001797          	auipc	a5,0x1
ffffffe0002013d4:	d9078793          	addi	a5,a5,-624 # ffffffe000202160 <_srodata+0x160>
ffffffe0002013d8:	00f707b3          	add	a5,a4,a5
ffffffe0002013dc:	0007a783          	lw	a5,0(a5)
ffffffe0002013e0:	0007871b          	sext.w	a4,a5
ffffffe0002013e4:	00001797          	auipc	a5,0x1
ffffffe0002013e8:	d7c78793          	addi	a5,a5,-644 # ffffffe000202160 <_srodata+0x160>
ffffffe0002013ec:	00f707b3          	add	a5,a4,a5
ffffffe0002013f0:	00078067          	jr	a5
                case 'l': { 
                    longarg = 1; 
ffffffe0002013f4:	00100793          	li	a5,1
ffffffe0002013f8:	fef42423          	sw	a5,-24(s0)
                    break; 
ffffffe0002013fc:	46c0006f          	j	ffffffe000201868 <vprintfmt+0x4f8>
                }
                
                case 'x': {
                    long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000201400:	fe842783          	lw	a5,-24(s0)
ffffffe000201404:	0007879b          	sext.w	a5,a5
ffffffe000201408:	00078c63          	beqz	a5,ffffffe000201420 <vprintfmt+0xb0>
ffffffe00020140c:	f2843783          	ld	a5,-216(s0)
ffffffe000201410:	00878713          	addi	a4,a5,8
ffffffe000201414:	f2e43423          	sd	a4,-216(s0)
ffffffe000201418:	0007b783          	ld	a5,0(a5)
ffffffe00020141c:	0140006f          	j	ffffffe000201430 <vprintfmt+0xc0>
ffffffe000201420:	f2843783          	ld	a5,-216(s0)
ffffffe000201424:	00878713          	addi	a4,a5,8
ffffffe000201428:	f2e43423          	sd	a4,-216(s0)
ffffffe00020142c:	0007a783          	lw	a5,0(a5)
ffffffe000201430:	f8f43c23          	sd	a5,-104(s0)

                    int hexdigits = int_mul(2, (longarg ? sizeof(long) : sizeof(int))) - 1;
ffffffe000201434:	fe842783          	lw	a5,-24(s0)
ffffffe000201438:	0007879b          	sext.w	a5,a5
ffffffe00020143c:	00078663          	beqz	a5,ffffffe000201448 <vprintfmt+0xd8>
ffffffe000201440:	00800793          	li	a5,8
ffffffe000201444:	0080006f          	j	ffffffe00020144c <vprintfmt+0xdc>
ffffffe000201448:	00400793          	li	a5,4
ffffffe00020144c:	00078593          	mv	a1,a5
ffffffe000201450:	00200513          	li	a0,2
ffffffe000201454:	d61ff0ef          	jal	ra,ffffffe0002011b4 <int_mul>
ffffffe000201458:	00050793          	mv	a5,a0
ffffffe00020145c:	fff7879b          	addiw	a5,a5,-1
ffffffe000201460:	f8f42a23          	sw	a5,-108(s0)
                    for(int halfbyte = hexdigits; halfbyte >= 0; halfbyte--) {
ffffffe000201464:	f9442783          	lw	a5,-108(s0)
ffffffe000201468:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020146c:	0900006f          	j	ffffffe0002014fc <vprintfmt+0x18c>
                        int hex = (num >> int_mul(4, halfbyte)) & 0xF;
ffffffe000201470:	fdc42783          	lw	a5,-36(s0)
ffffffe000201474:	00078593          	mv	a1,a5
ffffffe000201478:	00400513          	li	a0,4
ffffffe00020147c:	d39ff0ef          	jal	ra,ffffffe0002011b4 <int_mul>
ffffffe000201480:	00050793          	mv	a5,a0
ffffffe000201484:	00078713          	mv	a4,a5
ffffffe000201488:	f9843783          	ld	a5,-104(s0)
ffffffe00020148c:	40e7d7b3          	sra	a5,a5,a4
ffffffe000201490:	0007879b          	sext.w	a5,a5
ffffffe000201494:	00f7f793          	andi	a5,a5,15
ffffffe000201498:	f8f42823          	sw	a5,-112(s0)
                        char hexchar = (hex < 10 ? '0' + hex : 'a' + hex - 10);
ffffffe00020149c:	f9042783          	lw	a5,-112(s0)
ffffffe0002014a0:	0007871b          	sext.w	a4,a5
ffffffe0002014a4:	00900793          	li	a5,9
ffffffe0002014a8:	00e7cc63          	blt	a5,a4,ffffffe0002014c0 <vprintfmt+0x150>
ffffffe0002014ac:	f9042783          	lw	a5,-112(s0)
ffffffe0002014b0:	0ff7f793          	zext.b	a5,a5
ffffffe0002014b4:	0307879b          	addiw	a5,a5,48
ffffffe0002014b8:	0ff7f793          	zext.b	a5,a5
ffffffe0002014bc:	0140006f          	j	ffffffe0002014d0 <vprintfmt+0x160>
ffffffe0002014c0:	f9042783          	lw	a5,-112(s0)
ffffffe0002014c4:	0ff7f793          	zext.b	a5,a5
ffffffe0002014c8:	0577879b          	addiw	a5,a5,87
ffffffe0002014cc:	0ff7f793          	zext.b	a5,a5
ffffffe0002014d0:	f8f407a3          	sb	a5,-113(s0)
                        putch(hexchar);
ffffffe0002014d4:	f8f44703          	lbu	a4,-113(s0)
ffffffe0002014d8:	f3843783          	ld	a5,-200(s0)
ffffffe0002014dc:	00070513          	mv	a0,a4
ffffffe0002014e0:	000780e7          	jalr	a5
                        pos++;
ffffffe0002014e4:	fe043783          	ld	a5,-32(s0)
ffffffe0002014e8:	00178793          	addi	a5,a5,1
ffffffe0002014ec:	fef43023          	sd	a5,-32(s0)
                    for(int halfbyte = hexdigits; halfbyte >= 0; halfbyte--) {
ffffffe0002014f0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002014f4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002014f8:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002014fc:	fdc42783          	lw	a5,-36(s0)
ffffffe000201500:	0007879b          	sext.w	a5,a5
ffffffe000201504:	f607d6e3          	bgez	a5,ffffffe000201470 <vprintfmt+0x100>
                    }
                    longarg = 0; in_format = 0; 
ffffffe000201508:	fe042423          	sw	zero,-24(s0)
ffffffe00020150c:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe000201510:	3580006f          	j	ffffffe000201868 <vprintfmt+0x4f8>
                }
            
                case 'd': {
                    long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000201514:	fe842783          	lw	a5,-24(s0)
ffffffe000201518:	0007879b          	sext.w	a5,a5
ffffffe00020151c:	00078c63          	beqz	a5,ffffffe000201534 <vprintfmt+0x1c4>
ffffffe000201520:	f2843783          	ld	a5,-216(s0)
ffffffe000201524:	00878713          	addi	a4,a5,8
ffffffe000201528:	f2e43423          	sd	a4,-216(s0)
ffffffe00020152c:	0007b783          	ld	a5,0(a5)
ffffffe000201530:	0140006f          	j	ffffffe000201544 <vprintfmt+0x1d4>
ffffffe000201534:	f2843783          	ld	a5,-216(s0)
ffffffe000201538:	00878713          	addi	a4,a5,8
ffffffe00020153c:	f2e43423          	sd	a4,-216(s0)
ffffffe000201540:	0007a783          	lw	a5,0(a5)
ffffffe000201544:	fcf43823          	sd	a5,-48(s0)
                    if (num < 0) {
ffffffe000201548:	fd043783          	ld	a5,-48(s0)
ffffffe00020154c:	0207d463          	bgez	a5,ffffffe000201574 <vprintfmt+0x204>
                        num = -num; putch('-');
ffffffe000201550:	fd043783          	ld	a5,-48(s0)
ffffffe000201554:	40f007b3          	neg	a5,a5
ffffffe000201558:	fcf43823          	sd	a5,-48(s0)
ffffffe00020155c:	f3843783          	ld	a5,-200(s0)
ffffffe000201560:	02d00513          	li	a0,45
ffffffe000201564:	000780e7          	jalr	a5
                        pos++;
ffffffe000201568:	fe043783          	ld	a5,-32(s0)
ffffffe00020156c:	00178793          	addi	a5,a5,1
ffffffe000201570:	fef43023          	sd	a5,-32(s0)
                    }
                    int bits = 0;
ffffffe000201574:	fc042623          	sw	zero,-52(s0)
                    char decchar[25] = {'0', 0};
ffffffe000201578:	03000793          	li	a5,48
ffffffe00020157c:	f6f43023          	sd	a5,-160(s0)
ffffffe000201580:	f6043423          	sd	zero,-152(s0)
ffffffe000201584:	f6043823          	sd	zero,-144(s0)
ffffffe000201588:	f6040c23          	sb	zero,-136(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe00020158c:	fd043783          	ld	a5,-48(s0)
ffffffe000201590:	fcf43023          	sd	a5,-64(s0)
ffffffe000201594:	0600006f          	j	ffffffe0002015f4 <vprintfmt+0x284>
                        decchar[bits] = int_mod(tmp, 10) + '0';
ffffffe000201598:	fc043783          	ld	a5,-64(s0)
ffffffe00020159c:	0007879b          	sext.w	a5,a5
ffffffe0002015a0:	00a00593          	li	a1,10
ffffffe0002015a4:	00078513          	mv	a0,a5
ffffffe0002015a8:	b81ff0ef          	jal	ra,ffffffe000201128 <int_mod>
ffffffe0002015ac:	00050793          	mv	a5,a0
ffffffe0002015b0:	0ff7f793          	zext.b	a5,a5
ffffffe0002015b4:	0307879b          	addiw	a5,a5,48
ffffffe0002015b8:	0ff7f713          	zext.b	a4,a5
ffffffe0002015bc:	fcc42783          	lw	a5,-52(s0)
ffffffe0002015c0:	ff078793          	addi	a5,a5,-16
ffffffe0002015c4:	008787b3          	add	a5,a5,s0
ffffffe0002015c8:	f6e78823          	sb	a4,-144(a5)
                        tmp = int_div(tmp, 10);
ffffffe0002015cc:	fc043783          	ld	a5,-64(s0)
ffffffe0002015d0:	0007879b          	sext.w	a5,a5
ffffffe0002015d4:	00a00593          	li	a1,10
ffffffe0002015d8:	00078513          	mv	a0,a5
ffffffe0002015dc:	c69ff0ef          	jal	ra,ffffffe000201244 <int_div>
ffffffe0002015e0:	00050793          	mv	a5,a0
ffffffe0002015e4:	fcf43023          	sd	a5,-64(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe0002015e8:	fcc42783          	lw	a5,-52(s0)
ffffffe0002015ec:	0017879b          	addiw	a5,a5,1
ffffffe0002015f0:	fcf42623          	sw	a5,-52(s0)
ffffffe0002015f4:	fc043783          	ld	a5,-64(s0)
ffffffe0002015f8:	fa0790e3          	bnez	a5,ffffffe000201598 <vprintfmt+0x228>
                    }

                    for (int i = bits; i >= 0; i--) {
ffffffe0002015fc:	fcc42783          	lw	a5,-52(s0)
ffffffe000201600:	faf42e23          	sw	a5,-68(s0)
ffffffe000201604:	02c0006f          	j	ffffffe000201630 <vprintfmt+0x2c0>
                        putch(decchar[i]);
ffffffe000201608:	fbc42783          	lw	a5,-68(s0)
ffffffe00020160c:	ff078793          	addi	a5,a5,-16
ffffffe000201610:	008787b3          	add	a5,a5,s0
ffffffe000201614:	f707c703          	lbu	a4,-144(a5)
ffffffe000201618:	f3843783          	ld	a5,-200(s0)
ffffffe00020161c:	00070513          	mv	a0,a4
ffffffe000201620:	000780e7          	jalr	a5
                    for (int i = bits; i >= 0; i--) {
ffffffe000201624:	fbc42783          	lw	a5,-68(s0)
ffffffe000201628:	fff7879b          	addiw	a5,a5,-1
ffffffe00020162c:	faf42e23          	sw	a5,-68(s0)
ffffffe000201630:	fbc42783          	lw	a5,-68(s0)
ffffffe000201634:	0007879b          	sext.w	a5,a5
ffffffe000201638:	fc07d8e3          	bgez	a5,ffffffe000201608 <vprintfmt+0x298>
                    }
                    pos += bits + 1;
ffffffe00020163c:	fcc42783          	lw	a5,-52(s0)
ffffffe000201640:	0017879b          	addiw	a5,a5,1
ffffffe000201644:	0007879b          	sext.w	a5,a5
ffffffe000201648:	00078713          	mv	a4,a5
ffffffe00020164c:	fe043783          	ld	a5,-32(s0)
ffffffe000201650:	00e787b3          	add	a5,a5,a4
ffffffe000201654:	fef43023          	sd	a5,-32(s0)
                    longarg = 0; in_format = 0; 
ffffffe000201658:	fe042423          	sw	zero,-24(s0)
ffffffe00020165c:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe000201660:	2080006f          	j	ffffffe000201868 <vprintfmt+0x4f8>
                }

                case 'u': {
                    unsigned long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000201664:	fe842783          	lw	a5,-24(s0)
ffffffe000201668:	0007879b          	sext.w	a5,a5
ffffffe00020166c:	00078c63          	beqz	a5,ffffffe000201684 <vprintfmt+0x314>
ffffffe000201670:	f2843783          	ld	a5,-216(s0)
ffffffe000201674:	00878713          	addi	a4,a5,8
ffffffe000201678:	f2e43423          	sd	a4,-216(s0)
ffffffe00020167c:	0007b783          	ld	a5,0(a5)
ffffffe000201680:	0140006f          	j	ffffffe000201694 <vprintfmt+0x324>
ffffffe000201684:	f2843783          	ld	a5,-216(s0)
ffffffe000201688:	00878713          	addi	a4,a5,8
ffffffe00020168c:	f2e43423          	sd	a4,-216(s0)
ffffffe000201690:	0007a783          	lw	a5,0(a5)
ffffffe000201694:	f8f43023          	sd	a5,-128(s0)
                    int bits = 0;
ffffffe000201698:	fa042c23          	sw	zero,-72(s0)
                    char decchar[25] = {'0', 0};
ffffffe00020169c:	03000793          	li	a5,48
ffffffe0002016a0:	f4f43023          	sd	a5,-192(s0)
ffffffe0002016a4:	f4043423          	sd	zero,-184(s0)
ffffffe0002016a8:	f4043823          	sd	zero,-176(s0)
ffffffe0002016ac:	f4040c23          	sb	zero,-168(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe0002016b0:	f8043783          	ld	a5,-128(s0)
ffffffe0002016b4:	faf43823          	sd	a5,-80(s0)
ffffffe0002016b8:	0600006f          	j	ffffffe000201718 <vprintfmt+0x3a8>
                        decchar[bits] = int_mod(tmp, 10) + '0';
ffffffe0002016bc:	fb043783          	ld	a5,-80(s0)
ffffffe0002016c0:	0007879b          	sext.w	a5,a5
ffffffe0002016c4:	00a00593          	li	a1,10
ffffffe0002016c8:	00078513          	mv	a0,a5
ffffffe0002016cc:	a5dff0ef          	jal	ra,ffffffe000201128 <int_mod>
ffffffe0002016d0:	00050793          	mv	a5,a0
ffffffe0002016d4:	0ff7f793          	zext.b	a5,a5
ffffffe0002016d8:	0307879b          	addiw	a5,a5,48
ffffffe0002016dc:	0ff7f713          	zext.b	a4,a5
ffffffe0002016e0:	fb842783          	lw	a5,-72(s0)
ffffffe0002016e4:	ff078793          	addi	a5,a5,-16
ffffffe0002016e8:	008787b3          	add	a5,a5,s0
ffffffe0002016ec:	f4e78823          	sb	a4,-176(a5)
                        tmp = int_div(tmp, 10);
ffffffe0002016f0:	fb043783          	ld	a5,-80(s0)
ffffffe0002016f4:	0007879b          	sext.w	a5,a5
ffffffe0002016f8:	00a00593          	li	a1,10
ffffffe0002016fc:	00078513          	mv	a0,a5
ffffffe000201700:	b45ff0ef          	jal	ra,ffffffe000201244 <int_div>
ffffffe000201704:	00050793          	mv	a5,a0
ffffffe000201708:	faf43823          	sd	a5,-80(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe00020170c:	fb842783          	lw	a5,-72(s0)
ffffffe000201710:	0017879b          	addiw	a5,a5,1
ffffffe000201714:	faf42c23          	sw	a5,-72(s0)
ffffffe000201718:	fb043783          	ld	a5,-80(s0)
ffffffe00020171c:	fa0790e3          	bnez	a5,ffffffe0002016bc <vprintfmt+0x34c>
                    }

                    for (int i = bits; i >= 0; i--) {
ffffffe000201720:	fb842783          	lw	a5,-72(s0)
ffffffe000201724:	faf42623          	sw	a5,-84(s0)
ffffffe000201728:	02c0006f          	j	ffffffe000201754 <vprintfmt+0x3e4>
                        putch(decchar[i]);
ffffffe00020172c:	fac42783          	lw	a5,-84(s0)
ffffffe000201730:	ff078793          	addi	a5,a5,-16
ffffffe000201734:	008787b3          	add	a5,a5,s0
ffffffe000201738:	f507c703          	lbu	a4,-176(a5)
ffffffe00020173c:	f3843783          	ld	a5,-200(s0)
ffffffe000201740:	00070513          	mv	a0,a4
ffffffe000201744:	000780e7          	jalr	a5
                    for (int i = bits; i >= 0; i--) {
ffffffe000201748:	fac42783          	lw	a5,-84(s0)
ffffffe00020174c:	fff7879b          	addiw	a5,a5,-1
ffffffe000201750:	faf42623          	sw	a5,-84(s0)
ffffffe000201754:	fac42783          	lw	a5,-84(s0)
ffffffe000201758:	0007879b          	sext.w	a5,a5
ffffffe00020175c:	fc07d8e3          	bgez	a5,ffffffe00020172c <vprintfmt+0x3bc>
                    }
                    pos += bits + 1;
ffffffe000201760:	fb842783          	lw	a5,-72(s0)
ffffffe000201764:	0017879b          	addiw	a5,a5,1
ffffffe000201768:	0007879b          	sext.w	a5,a5
ffffffe00020176c:	00078713          	mv	a4,a5
ffffffe000201770:	fe043783          	ld	a5,-32(s0)
ffffffe000201774:	00e787b3          	add	a5,a5,a4
ffffffe000201778:	fef43023          	sd	a5,-32(s0)
                    longarg = 0; in_format = 0; 
ffffffe00020177c:	fe042423          	sw	zero,-24(s0)
ffffffe000201780:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe000201784:	0e40006f          	j	ffffffe000201868 <vprintfmt+0x4f8>
                }

                case 's': {
                    const char* str = va_arg(vl, const char*);
ffffffe000201788:	f2843783          	ld	a5,-216(s0)
ffffffe00020178c:	00878713          	addi	a4,a5,8
ffffffe000201790:	f2e43423          	sd	a4,-216(s0)
ffffffe000201794:	0007b783          	ld	a5,0(a5)
ffffffe000201798:	faf43023          	sd	a5,-96(s0)
                    while (*str) {
ffffffe00020179c:	0300006f          	j	ffffffe0002017cc <vprintfmt+0x45c>
                        putch(*str);
ffffffe0002017a0:	fa043783          	ld	a5,-96(s0)
ffffffe0002017a4:	0007c703          	lbu	a4,0(a5)
ffffffe0002017a8:	f3843783          	ld	a5,-200(s0)
ffffffe0002017ac:	00070513          	mv	a0,a4
ffffffe0002017b0:	000780e7          	jalr	a5
                        pos++; 
ffffffe0002017b4:	fe043783          	ld	a5,-32(s0)
ffffffe0002017b8:	00178793          	addi	a5,a5,1
ffffffe0002017bc:	fef43023          	sd	a5,-32(s0)
                        str++;
ffffffe0002017c0:	fa043783          	ld	a5,-96(s0)
ffffffe0002017c4:	00178793          	addi	a5,a5,1
ffffffe0002017c8:	faf43023          	sd	a5,-96(s0)
                    while (*str) {
ffffffe0002017cc:	fa043783          	ld	a5,-96(s0)
ffffffe0002017d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002017d4:	fc0796e3          	bnez	a5,ffffffe0002017a0 <vprintfmt+0x430>
                    }
                    longarg = 0; in_format = 0; 
ffffffe0002017d8:	fe042423          	sw	zero,-24(s0)
ffffffe0002017dc:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe0002017e0:	0880006f          	j	ffffffe000201868 <vprintfmt+0x4f8>
                }

                case 'c': {
                    char ch = (char)va_arg(vl,int);
ffffffe0002017e4:	f2843783          	ld	a5,-216(s0)
ffffffe0002017e8:	00878713          	addi	a4,a5,8
ffffffe0002017ec:	f2e43423          	sd	a4,-216(s0)
ffffffe0002017f0:	0007a783          	lw	a5,0(a5)
ffffffe0002017f4:	f6f40fa3          	sb	a5,-129(s0)
                    putch(ch);
ffffffe0002017f8:	f7f44703          	lbu	a4,-129(s0)
ffffffe0002017fc:	f3843783          	ld	a5,-200(s0)
ffffffe000201800:	00070513          	mv	a0,a4
ffffffe000201804:	000780e7          	jalr	a5
                    pos++;
ffffffe000201808:	fe043783          	ld	a5,-32(s0)
ffffffe00020180c:	00178793          	addi	a5,a5,1
ffffffe000201810:	fef43023          	sd	a5,-32(s0)
                    longarg = 0; in_format = 0; 
ffffffe000201814:	fe042423          	sw	zero,-24(s0)
ffffffe000201818:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe00020181c:	04c0006f          	j	ffffffe000201868 <vprintfmt+0x4f8>
                }
                default:
                    break;
            }
        }
        else if(*fmt == '%') {
ffffffe000201820:	f3043783          	ld	a5,-208(s0)
ffffffe000201824:	0007c783          	lbu	a5,0(a5)
ffffffe000201828:	00078713          	mv	a4,a5
ffffffe00020182c:	02500793          	li	a5,37
ffffffe000201830:	00f71863          	bne	a4,a5,ffffffe000201840 <vprintfmt+0x4d0>
          in_format = 1;
ffffffe000201834:	00100793          	li	a5,1
ffffffe000201838:	fef42623          	sw	a5,-20(s0)
ffffffe00020183c:	02c0006f          	j	ffffffe000201868 <vprintfmt+0x4f8>
        }
        else {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
            putch(*fmt);
ffffffe000201840:	f3043783          	ld	a5,-208(s0)
ffffffe000201844:	0007c703          	lbu	a4,0(a5)
ffffffe000201848:	f3843783          	ld	a5,-200(s0)
ffffffe00020184c:	00070513          	mv	a0,a4
ffffffe000201850:	000780e7          	jalr	a5
            pos++;
ffffffe000201854:	fe043783          	ld	a5,-32(s0)
ffffffe000201858:	00178793          	addi	a5,a5,1
ffffffe00020185c:	fef43023          	sd	a5,-32(s0)
ffffffe000201860:	0080006f          	j	ffffffe000201868 <vprintfmt+0x4f8>
                    break;
ffffffe000201864:	00000013          	nop
    for( ; *fmt; fmt++) {
ffffffe000201868:	f3043783          	ld	a5,-208(s0)
ffffffe00020186c:	00178793          	addi	a5,a5,1
ffffffe000201870:	f2f43823          	sd	a5,-208(s0)
ffffffe000201874:	f3043783          	ld	a5,-208(s0)
ffffffe000201878:	0007c783          	lbu	a5,0(a5)
ffffffe00020187c:	b20790e3          	bnez	a5,ffffffe00020139c <vprintfmt+0x2c>
        }
    }
    return pos;
ffffffe000201880:	fe043783          	ld	a5,-32(s0)
ffffffe000201884:	0007879b          	sext.w	a5,a5
}
ffffffe000201888:	00078513          	mv	a0,a5
ffffffe00020188c:	0d813083          	ld	ra,216(sp)
ffffffe000201890:	0d013403          	ld	s0,208(sp)
ffffffe000201894:	0e010113          	addi	sp,sp,224
ffffffe000201898:	00008067          	ret

ffffffe00020189c <printk>:



int printk(const char* s, ...) {
ffffffe00020189c:	f9010113          	addi	sp,sp,-112
ffffffe0002018a0:	02113423          	sd	ra,40(sp)
ffffffe0002018a4:	02813023          	sd	s0,32(sp)
ffffffe0002018a8:	03010413          	addi	s0,sp,48
ffffffe0002018ac:	fca43c23          	sd	a0,-40(s0)
ffffffe0002018b0:	00b43423          	sd	a1,8(s0)
ffffffe0002018b4:	00c43823          	sd	a2,16(s0)
ffffffe0002018b8:	00d43c23          	sd	a3,24(s0)
ffffffe0002018bc:	02e43023          	sd	a4,32(s0)
ffffffe0002018c0:	02f43423          	sd	a5,40(s0)
ffffffe0002018c4:	03043823          	sd	a6,48(s0)
ffffffe0002018c8:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe0002018cc:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe0002018d0:	04040793          	addi	a5,s0,64
ffffffe0002018d4:	fcf43823          	sd	a5,-48(s0)
ffffffe0002018d8:	fd043783          	ld	a5,-48(s0)
ffffffe0002018dc:	fc878793          	addi	a5,a5,-56
ffffffe0002018e0:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe0002018e4:	fe043783          	ld	a5,-32(s0)
ffffffe0002018e8:	00078613          	mv	a2,a5
ffffffe0002018ec:	fd843583          	ld	a1,-40(s0)
ffffffe0002018f0:	00000517          	auipc	a0,0x0
ffffffe0002018f4:	a3050513          	addi	a0,a0,-1488 # ffffffe000201320 <putc>
ffffffe0002018f8:	a79ff0ef          	jal	ra,ffffffe000201370 <vprintfmt>
ffffffe0002018fc:	00050793          	mv	a5,a0
ffffffe000201900:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000201904:	fec42783          	lw	a5,-20(s0)
}
ffffffe000201908:	00078513          	mv	a0,a5
ffffffe00020190c:	02813083          	ld	ra,40(sp)
ffffffe000201910:	02013403          	ld	s0,32(sp)
ffffffe000201914:	07010113          	addi	sp,sp,112
ffffffe000201918:	00008067          	ret

ffffffe00020191c <rand>:

int initialize = 0;
int r[1000];
int t = 0;

uint64 rand() {
ffffffe00020191c:	ff010113          	addi	sp,sp,-16
ffffffe000201920:	00813423          	sd	s0,8(sp)
ffffffe000201924:	01010413          	addi	s0,sp,16
    // // t = t % 656;
	// t = int_mod(t , 656);

    // r[t + 344] = r[t + 344 - 31] + r[t + 344 - 3];
    
	t++;
ffffffe000201928:	00002797          	auipc	a5,0x2
ffffffe00020192c:	6f478793          	addi	a5,a5,1780 # ffffffe00020401c <t>
ffffffe000201930:	0007a783          	lw	a5,0(a5)
ffffffe000201934:	0017879b          	addiw	a5,a5,1
ffffffe000201938:	0007871b          	sext.w	a4,a5
ffffffe00020193c:	00002797          	auipc	a5,0x2
ffffffe000201940:	6e078793          	addi	a5,a5,1760 # ffffffe00020401c <t>
ffffffe000201944:	00e7a023          	sw	a4,0(a5)
    return t;
ffffffe000201948:	00002797          	auipc	a5,0x2
ffffffe00020194c:	6d478793          	addi	a5,a5,1748 # ffffffe00020401c <t>
ffffffe000201950:	0007a783          	lw	a5,0(a5)

    // return (uint64)r[t - 1 + 344];
}
ffffffe000201954:	00078513          	mv	a0,a5
ffffffe000201958:	00813403          	ld	s0,8(sp)
ffffffe00020195c:	01010113          	addi	sp,sp,16
ffffffe000201960:	00008067          	ret

ffffffe000201964 <memset>:
#include "string.h"

void *memset(void *dst, int c, uint64 n) {
ffffffe000201964:	fc010113          	addi	sp,sp,-64
ffffffe000201968:	02813c23          	sd	s0,56(sp)
ffffffe00020196c:	04010413          	addi	s0,sp,64
ffffffe000201970:	fca43c23          	sd	a0,-40(s0)
ffffffe000201974:	00058793          	mv	a5,a1
ffffffe000201978:	fcc43423          	sd	a2,-56(s0)
ffffffe00020197c:	fcf42a23          	sw	a5,-44(s0)
    char *cdst = (char *)dst;
ffffffe000201980:	fd843783          	ld	a5,-40(s0)
ffffffe000201984:	fef43023          	sd	a5,-32(s0)
    for (uint64 i = 0; i < n; ++i)
ffffffe000201988:	fe043423          	sd	zero,-24(s0)
ffffffe00020198c:	0280006f          	j	ffffffe0002019b4 <memset+0x50>
        cdst[i] = c;
ffffffe000201990:	fe043703          	ld	a4,-32(s0)
ffffffe000201994:	fe843783          	ld	a5,-24(s0)
ffffffe000201998:	00f707b3          	add	a5,a4,a5
ffffffe00020199c:	fd442703          	lw	a4,-44(s0)
ffffffe0002019a0:	0ff77713          	zext.b	a4,a4
ffffffe0002019a4:	00e78023          	sb	a4,0(a5)
    for (uint64 i = 0; i < n; ++i)
ffffffe0002019a8:	fe843783          	ld	a5,-24(s0)
ffffffe0002019ac:	00178793          	addi	a5,a5,1
ffffffe0002019b0:	fef43423          	sd	a5,-24(s0)
ffffffe0002019b4:	fe843703          	ld	a4,-24(s0)
ffffffe0002019b8:	fc843783          	ld	a5,-56(s0)
ffffffe0002019bc:	fcf76ae3          	bltu	a4,a5,ffffffe000201990 <memset+0x2c>

    return dst;
ffffffe0002019c0:	fd843783          	ld	a5,-40(s0)
}
ffffffe0002019c4:	00078513          	mv	a0,a5
ffffffe0002019c8:	03813403          	ld	s0,56(sp)
ffffffe0002019cc:	04010113          	addi	sp,sp,64
ffffffe0002019d0:	00008067          	ret
