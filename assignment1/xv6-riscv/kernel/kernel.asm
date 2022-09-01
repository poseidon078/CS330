
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	88013103          	ld	sp,-1920(sp) # 80008880 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	cbc78793          	addi	a5,a5,-836 # 80005d20 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de078793          	addi	a5,a5,-544 # 80000e8e <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	482080e7          	jalr	1154(ra) # 800025ae <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	78e080e7          	jalr	1934(ra) # 800008ca <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	ff450513          	addi	a0,a0,-12 # 80011180 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a50080e7          	jalr	-1456(ra) # 80000be4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	fe448493          	addi	s1,s1,-28 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	07290913          	addi	s2,s2,114 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405863          	blez	s4,80000224 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71463          	bne	a4,a5,800001e8 <consoleread+0x84>
      if(myproc()->killed){
    800001c4:	00001097          	auipc	ra,0x1
    800001c8:	7ec080e7          	jalr	2028(ra) # 800019b0 <myproc>
    800001cc:	551c                	lw	a5,40(a0)
    800001ce:	e7b5                	bnez	a5,8000023a <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001d0:	85ce                	mv	a1,s3
    800001d2:	854a                	mv	a0,s2
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	fe0080e7          	jalr	-32(ra) # 800021b4 <sleep>
    while(cons.r == cons.w){
    800001dc:	0984a783          	lw	a5,152(s1)
    800001e0:	09c4a703          	lw	a4,156(s1)
    800001e4:	fef700e3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e8:	0017871b          	addiw	a4,a5,1
    800001ec:	08e4ac23          	sw	a4,152(s1)
    800001f0:	07f7f713          	andi	a4,a5,127
    800001f4:	9726                	add	a4,a4,s1
    800001f6:	01874703          	lbu	a4,24(a4)
    800001fa:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001fe:	079c0663          	beq	s8,s9,8000026a <consoleread+0x106>
    cbuf = c;
    80000202:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	f8f40613          	addi	a2,s0,-113
    8000020c:	85d6                	mv	a1,s5
    8000020e:	855a                	mv	a0,s6
    80000210:	00002097          	auipc	ra,0x2
    80000214:	348080e7          	jalr	840(ra) # 80002558 <either_copyout>
    80000218:	01a50663          	beq	a0,s10,80000224 <consoleread+0xc0>
    dst++;
    8000021c:	0a85                	addi	s5,s5,1
    --n;
    8000021e:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000220:	f9bc1ae3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000224:	00011517          	auipc	a0,0x11
    80000228:	f5c50513          	addi	a0,a0,-164 # 80011180 <cons>
    8000022c:	00001097          	auipc	ra,0x1
    80000230:	a6c080e7          	jalr	-1428(ra) # 80000c98 <release>

  return target - n;
    80000234:	414b853b          	subw	a0,s7,s4
    80000238:	a811                	j	8000024c <consoleread+0xe8>
        release(&cons.lock);
    8000023a:	00011517          	auipc	a0,0x11
    8000023e:	f4650513          	addi	a0,a0,-186 # 80011180 <cons>
    80000242:	00001097          	auipc	ra,0x1
    80000246:	a56080e7          	jalr	-1450(ra) # 80000c98 <release>
        return -1;
    8000024a:	557d                	li	a0,-1
}
    8000024c:	70e6                	ld	ra,120(sp)
    8000024e:	7446                	ld	s0,112(sp)
    80000250:	74a6                	ld	s1,104(sp)
    80000252:	7906                	ld	s2,96(sp)
    80000254:	69e6                	ld	s3,88(sp)
    80000256:	6a46                	ld	s4,80(sp)
    80000258:	6aa6                	ld	s5,72(sp)
    8000025a:	6b06                	ld	s6,64(sp)
    8000025c:	7be2                	ld	s7,56(sp)
    8000025e:	7c42                	ld	s8,48(sp)
    80000260:	7ca2                	ld	s9,40(sp)
    80000262:	7d02                	ld	s10,32(sp)
    80000264:	6de2                	ld	s11,24(sp)
    80000266:	6109                	addi	sp,sp,128
    80000268:	8082                	ret
      if(n < target){
    8000026a:	000a071b          	sext.w	a4,s4
    8000026e:	fb777be3          	bgeu	a4,s7,80000224 <consoleread+0xc0>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	faf72323          	sw	a5,-90(a4) # 80011218 <cons+0x98>
    8000027a:	b76d                	j	80000224 <consoleread+0xc0>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	564080e7          	jalr	1380(ra) # 800007f0 <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	552080e7          	jalr	1362(ra) # 800007f0 <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	546080e7          	jalr	1350(ra) # 800007f0 <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	53c080e7          	jalr	1340(ra) # 800007f0 <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	eb450513          	addi	a0,a0,-332 # 80011180 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	910080e7          	jalr	-1776(ra) # 80000be4 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	312080e7          	jalr	786(ra) # 80002604 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	e8650513          	addi	a0,a0,-378 # 80011180 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	996080e7          	jalr	-1642(ra) # 80000c98 <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	e6270713          	addi	a4,a4,-414 # 80011180 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	e3878793          	addi	a5,a5,-456 # 80011180 <cons>
    80000350:	0a07a703          	lw	a4,160(a5)
    80000354:	0017069b          	addiw	a3,a4,1
    80000358:	0006861b          	sext.w	a2,a3
    8000035c:	0ad7a023          	sw	a3,160(a5)
    80000360:	07f77713          	andi	a4,a4,127
    80000364:	97ba                	add	a5,a5,a4
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	ea27a783          	lw	a5,-350(a5) # 80011218 <cons+0x98>
    8000037e:	0807879b          	addiw	a5,a5,128
    80000382:	f6f61ce3          	bne	a2,a5,800002fa <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000386:	863e                	mv	a2,a5
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	df670713          	addi	a4,a4,-522 # 80011180 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	de648493          	addi	s1,s1,-538 # 80011180 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	daa70713          	addi	a4,a4,-598 # 80011180 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	e2f72a23          	sw	a5,-460(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	d6e78793          	addi	a5,a5,-658 # 80011180 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	dec7a323          	sw	a2,-538(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	dda50513          	addi	a0,a0,-550 # 80011218 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	efa080e7          	jalr	-262(ra) # 80002340 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	d2050513          	addi	a0,a0,-736 # 80011180 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6ec080e7          	jalr	1772(ra) # 80000b54 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	330080e7          	jalr	816(ra) # 800007a0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	ea078793          	addi	a5,a5,-352 # 80021318 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00011797          	auipc	a5,0x11
    8000054e:	ce07ab23          	sw	zero,-778(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00009717          	auipc	a4,0x9
    80000582:	a8f72123          	sw	a5,-1406(a4) # 80009000 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00011d97          	auipc	s11,0x11
    800005be:	c86dad83          	lw	s11,-890(s11) # 80011240 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	16050263          	beqz	a0,8000073a <printf+0x1b2>
    800005da:	4481                	li	s1,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b13          	li	s6,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b97          	auipc	s7,0x8
    800005ea:	a5ab8b93          	addi	s7,s7,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00011517          	auipc	a0,0x11
    800005fc:	c3050513          	addi	a0,a0,-976 # 80011228 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5e4080e7          	jalr	1508(ra) # 80000be4 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2485                	addiw	s1,s1,1
    80000624:	009a07b3          	add	a5,s4,s1
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050763          	beqz	a0,8000073a <printf+0x1b2>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2485                	addiw	s1,s1,1
    80000636:	009a07b3          	add	a5,s4,s1
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000642:	cfe5                	beqz	a5,8000073a <printf+0x1b2>
    switch(c){
    80000644:	05678a63          	beq	a5,s6,80000698 <printf+0x110>
    80000648:	02fb7663          	bgeu	s6,a5,80000674 <printf+0xec>
    8000064c:	09978963          	beq	a5,s9,800006de <printf+0x156>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79863          	bne	a5,a4,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	0b578263          	beq	a5,s5,80000718 <printf+0x190>
    80000678:	0b879663          	bne	a5,s8,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c9d793          	srli	a5,s3,0x3c
    800006c6:	97de                	add	a5,a5,s7
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0992                	slli	s3,s3,0x4
    800006d6:	397d                	addiw	s2,s2,-1
    800006d8:	fe0915e3          	bnez	s2,800006c2 <printf+0x13a>
    800006dc:	b799                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	0007b903          	ld	s2,0(a5)
    800006ee:	00090e63          	beqz	s2,8000070a <printf+0x182>
      for(; *s; s++)
    800006f2:	00094503          	lbu	a0,0(s2)
    800006f6:	d515                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	b84080e7          	jalr	-1148(ra) # 8000027c <consputc>
      for(; *s; s++)
    80000700:	0905                	addi	s2,s2,1
    80000702:	00094503          	lbu	a0,0(s2)
    80000706:	f96d                	bnez	a0,800006f8 <printf+0x170>
    80000708:	bf29                	j	80000622 <printf+0x9a>
        s = "(null)";
    8000070a:	00008917          	auipc	s2,0x8
    8000070e:	91690913          	addi	s2,s2,-1770 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000712:	02800513          	li	a0,40
    80000716:	b7cd                	j	800006f8 <printf+0x170>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b62080e7          	jalr	-1182(ra) # 8000027c <consputc>
      break;
    80000722:	b701                	j	80000622 <printf+0x9a>
      consputc('%');
    80000724:	8556                	mv	a0,s5
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b56080e7          	jalr	-1194(ra) # 8000027c <consputc>
      consputc(c);
    8000072e:	854a                	mv	a0,s2
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b4c080e7          	jalr	-1204(ra) # 8000027c <consputc>
      break;
    80000738:	b5ed                	j	80000622 <printf+0x9a>
  if(locking)
    8000073a:	020d9163          	bnez	s11,8000075c <printf+0x1d4>
}
    8000073e:	70e6                	ld	ra,120(sp)
    80000740:	7446                	ld	s0,112(sp)
    80000742:	74a6                	ld	s1,104(sp)
    80000744:	7906                	ld	s2,96(sp)
    80000746:	69e6                	ld	s3,88(sp)
    80000748:	6a46                	ld	s4,80(sp)
    8000074a:	6aa6                	ld	s5,72(sp)
    8000074c:	6b06                	ld	s6,64(sp)
    8000074e:	7be2                	ld	s7,56(sp)
    80000750:	7c42                	ld	s8,48(sp)
    80000752:	7ca2                	ld	s9,40(sp)
    80000754:	7d02                	ld	s10,32(sp)
    80000756:	6de2                	ld	s11,24(sp)
    80000758:	6129                	addi	sp,sp,192
    8000075a:	8082                	ret
    release(&pr.lock);
    8000075c:	00011517          	auipc	a0,0x11
    80000760:	acc50513          	addi	a0,a0,-1332 # 80011228 <pr>
    80000764:	00000097          	auipc	ra,0x0
    80000768:	534080e7          	jalr	1332(ra) # 80000c98 <release>
}
    8000076c:	bfc9                	j	8000073e <printf+0x1b6>

000000008000076e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076e:	1101                	addi	sp,sp,-32
    80000770:	ec06                	sd	ra,24(sp)
    80000772:	e822                	sd	s0,16(sp)
    80000774:	e426                	sd	s1,8(sp)
    80000776:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000778:	00011497          	auipc	s1,0x11
    8000077c:	ab048493          	addi	s1,s1,-1360 # 80011228 <pr>
    80000780:	00008597          	auipc	a1,0x8
    80000784:	8b858593          	addi	a1,a1,-1864 # 80008038 <etext+0x38>
    80000788:	8526                	mv	a0,s1
    8000078a:	00000097          	auipc	ra,0x0
    8000078e:	3ca080e7          	jalr	970(ra) # 80000b54 <initlock>
  pr.locking = 1;
    80000792:	4785                	li	a5,1
    80000794:	cc9c                	sw	a5,24(s1)
}
    80000796:	60e2                	ld	ra,24(sp)
    80000798:	6442                	ld	s0,16(sp)
    8000079a:	64a2                	ld	s1,8(sp)
    8000079c:	6105                	addi	sp,sp,32
    8000079e:	8082                	ret

00000000800007a0 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a0:	1141                	addi	sp,sp,-16
    800007a2:	e406                	sd	ra,8(sp)
    800007a4:	e022                	sd	s0,0(sp)
    800007a6:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a8:	100007b7          	lui	a5,0x10000
    800007ac:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b0:	f8000713          	li	a4,-128
    800007b4:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b8:	470d                	li	a4,3
    800007ba:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007be:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c2:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c6:	469d                	li	a3,7
    800007c8:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007cc:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d0:	00008597          	auipc	a1,0x8
    800007d4:	88858593          	addi	a1,a1,-1912 # 80008058 <digits+0x18>
    800007d8:	00011517          	auipc	a0,0x11
    800007dc:	a7050513          	addi	a0,a0,-1424 # 80011248 <uart_tx_lock>
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	374080e7          	jalr	884(ra) # 80000b54 <initlock>
}
    800007e8:	60a2                	ld	ra,8(sp)
    800007ea:	6402                	ld	s0,0(sp)
    800007ec:	0141                	addi	sp,sp,16
    800007ee:	8082                	ret

00000000800007f0 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	1000                	addi	s0,sp,32
    800007fa:	84aa                	mv	s1,a0
  push_off();
    800007fc:	00000097          	auipc	ra,0x0
    80000800:	39c080e7          	jalr	924(ra) # 80000b98 <push_off>

  if(panicked){
    80000804:	00008797          	auipc	a5,0x8
    80000808:	7fc7a783          	lw	a5,2044(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	10000737          	lui	a4,0x10000
  if(panicked){
    80000810:	c391                	beqz	a5,80000814 <uartputc_sync+0x24>
    for(;;)
    80000812:	a001                	j	80000812 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000814:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000818:	0ff7f793          	andi	a5,a5,255
    8000081c:	0207f793          	andi	a5,a5,32
    80000820:	dbf5                	beqz	a5,80000814 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000822:	0ff4f793          	andi	a5,s1,255
    80000826:	10000737          	lui	a4,0x10000
    8000082a:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	40a080e7          	jalr	1034(ra) # 80000c38 <pop_off>
}
    80000836:	60e2                	ld	ra,24(sp)
    80000838:	6442                	ld	s0,16(sp)
    8000083a:	64a2                	ld	s1,8(sp)
    8000083c:	6105                	addi	sp,sp,32
    8000083e:	8082                	ret

0000000080000840 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000840:	00008717          	auipc	a4,0x8
    80000844:	7c873703          	ld	a4,1992(a4) # 80009008 <uart_tx_r>
    80000848:	00008797          	auipc	a5,0x8
    8000084c:	7c87b783          	ld	a5,1992(a5) # 80009010 <uart_tx_w>
    80000850:	06e78c63          	beq	a5,a4,800008c8 <uartstart+0x88>
{
    80000854:	7139                	addi	sp,sp,-64
    80000856:	fc06                	sd	ra,56(sp)
    80000858:	f822                	sd	s0,48(sp)
    8000085a:	f426                	sd	s1,40(sp)
    8000085c:	f04a                	sd	s2,32(sp)
    8000085e:	ec4e                	sd	s3,24(sp)
    80000860:	e852                	sd	s4,16(sp)
    80000862:	e456                	sd	s5,8(sp)
    80000864:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000866:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086a:	00011a17          	auipc	s4,0x11
    8000086e:	9dea0a13          	addi	s4,s4,-1570 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000872:	00008497          	auipc	s1,0x8
    80000876:	79648493          	addi	s1,s1,1942 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000087a:	00008997          	auipc	s3,0x8
    8000087e:	79698993          	addi	s3,s3,1942 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000882:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000886:	0ff7f793          	andi	a5,a5,255
    8000088a:	0207f793          	andi	a5,a5,32
    8000088e:	c785                	beqz	a5,800008b6 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000890:	01f77793          	andi	a5,a4,31
    80000894:	97d2                	add	a5,a5,s4
    80000896:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000089a:	0705                	addi	a4,a4,1
    8000089c:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000089e:	8526                	mv	a0,s1
    800008a0:	00002097          	auipc	ra,0x2
    800008a4:	aa0080e7          	jalr	-1376(ra) # 80002340 <wakeup>
    
    WriteReg(THR, c);
    800008a8:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ac:	6098                	ld	a4,0(s1)
    800008ae:	0009b783          	ld	a5,0(s3)
    800008b2:	fce798e3          	bne	a5,a4,80000882 <uartstart+0x42>
  }
}
    800008b6:	70e2                	ld	ra,56(sp)
    800008b8:	7442                	ld	s0,48(sp)
    800008ba:	74a2                	ld	s1,40(sp)
    800008bc:	7902                	ld	s2,32(sp)
    800008be:	69e2                	ld	s3,24(sp)
    800008c0:	6a42                	ld	s4,16(sp)
    800008c2:	6aa2                	ld	s5,8(sp)
    800008c4:	6121                	addi	sp,sp,64
    800008c6:	8082                	ret
    800008c8:	8082                	ret

00000000800008ca <uartputc>:
{
    800008ca:	7179                	addi	sp,sp,-48
    800008cc:	f406                	sd	ra,40(sp)
    800008ce:	f022                	sd	s0,32(sp)
    800008d0:	ec26                	sd	s1,24(sp)
    800008d2:	e84a                	sd	s2,16(sp)
    800008d4:	e44e                	sd	s3,8(sp)
    800008d6:	e052                	sd	s4,0(sp)
    800008d8:	1800                	addi	s0,sp,48
    800008da:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008dc:	00011517          	auipc	a0,0x11
    800008e0:	96c50513          	addi	a0,a0,-1684 # 80011248 <uart_tx_lock>
    800008e4:	00000097          	auipc	ra,0x0
    800008e8:	300080e7          	jalr	768(ra) # 80000be4 <acquire>
  if(panicked){
    800008ec:	00008797          	auipc	a5,0x8
    800008f0:	7147a783          	lw	a5,1812(a5) # 80009000 <panicked>
    800008f4:	c391                	beqz	a5,800008f8 <uartputc+0x2e>
    for(;;)
    800008f6:	a001                	j	800008f6 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f8:	00008797          	auipc	a5,0x8
    800008fc:	7187b783          	ld	a5,1816(a5) # 80009010 <uart_tx_w>
    80000900:	00008717          	auipc	a4,0x8
    80000904:	70873703          	ld	a4,1800(a4) # 80009008 <uart_tx_r>
    80000908:	02070713          	addi	a4,a4,32
    8000090c:	02f71b63          	bne	a4,a5,80000942 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00011a17          	auipc	s4,0x11
    80000914:	938a0a13          	addi	s4,s4,-1736 # 80011248 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	6f048493          	addi	s1,s1,1776 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	6f090913          	addi	s2,s2,1776 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000928:	85d2                	mv	a1,s4
    8000092a:	8526                	mv	a0,s1
    8000092c:	00002097          	auipc	ra,0x2
    80000930:	888080e7          	jalr	-1912(ra) # 800021b4 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000934:	00093783          	ld	a5,0(s2)
    80000938:	6098                	ld	a4,0(s1)
    8000093a:	02070713          	addi	a4,a4,32
    8000093e:	fef705e3          	beq	a4,a5,80000928 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000942:	00011497          	auipc	s1,0x11
    80000946:	90648493          	addi	s1,s1,-1786 # 80011248 <uart_tx_lock>
    8000094a:	01f7f713          	andi	a4,a5,31
    8000094e:	9726                	add	a4,a4,s1
    80000950:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000954:	0785                	addi	a5,a5,1
    80000956:	00008717          	auipc	a4,0x8
    8000095a:	6af73d23          	sd	a5,1722(a4) # 80009010 <uart_tx_w>
      uartstart();
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	ee2080e7          	jalr	-286(ra) # 80000840 <uartstart>
      release(&uart_tx_lock);
    80000966:	8526                	mv	a0,s1
    80000968:	00000097          	auipc	ra,0x0
    8000096c:	330080e7          	jalr	816(ra) # 80000c98 <release>
}
    80000970:	70a2                	ld	ra,40(sp)
    80000972:	7402                	ld	s0,32(sp)
    80000974:	64e2                	ld	s1,24(sp)
    80000976:	6942                	ld	s2,16(sp)
    80000978:	69a2                	ld	s3,8(sp)
    8000097a:	6a02                	ld	s4,0(sp)
    8000097c:	6145                	addi	sp,sp,48
    8000097e:	8082                	ret

0000000080000980 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000980:	1141                	addi	sp,sp,-16
    80000982:	e422                	sd	s0,8(sp)
    80000984:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000098e:	8b85                	andi	a5,a5,1
    80000990:	cb91                	beqz	a5,800009a4 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000992:	100007b7          	lui	a5,0x10000
    80000996:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000099a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000099e:	6422                	ld	s0,8(sp)
    800009a0:	0141                	addi	sp,sp,16
    800009a2:	8082                	ret
    return -1;
    800009a4:	557d                	li	a0,-1
    800009a6:	bfe5                	j	8000099e <uartgetc+0x1e>

00000000800009a8 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009a8:	1101                	addi	sp,sp,-32
    800009aa:	ec06                	sd	ra,24(sp)
    800009ac:	e822                	sd	s0,16(sp)
    800009ae:	e426                	sd	s1,8(sp)
    800009b0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b2:	54fd                	li	s1,-1
    int c = uartgetc();
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	fcc080e7          	jalr	-52(ra) # 80000980 <uartgetc>
    if(c == -1)
    800009bc:	00950763          	beq	a0,s1,800009ca <uartintr+0x22>
      break;
    consoleintr(c);
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	8fe080e7          	jalr	-1794(ra) # 800002be <consoleintr>
  while(1){
    800009c8:	b7f5                	j	800009b4 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ca:	00011497          	auipc	s1,0x11
    800009ce:	87e48493          	addi	s1,s1,-1922 # 80011248 <uart_tx_lock>
    800009d2:	8526                	mv	a0,s1
    800009d4:	00000097          	auipc	ra,0x0
    800009d8:	210080e7          	jalr	528(ra) # 80000be4 <acquire>
  uartstart();
    800009dc:	00000097          	auipc	ra,0x0
    800009e0:	e64080e7          	jalr	-412(ra) # 80000840 <uartstart>
  release(&uart_tx_lock);
    800009e4:	8526                	mv	a0,s1
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	2b2080e7          	jalr	690(ra) # 80000c98 <release>
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6105                	addi	sp,sp,32
    800009f6:	8082                	ret

00000000800009f8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	e04a                	sd	s2,0(sp)
    80000a02:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a04:	03451793          	slli	a5,a0,0x34
    80000a08:	ebb9                	bnez	a5,80000a5e <kfree+0x66>
    80000a0a:	84aa                	mv	s1,a0
    80000a0c:	00025797          	auipc	a5,0x25
    80000a10:	5f478793          	addi	a5,a5,1524 # 80026000 <end>
    80000a14:	04f56563          	bltu	a0,a5,80000a5e <kfree+0x66>
    80000a18:	47c5                	li	a5,17
    80000a1a:	07ee                	slli	a5,a5,0x1b
    80000a1c:	04f57163          	bgeu	a0,a5,80000a5e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a20:	6605                	lui	a2,0x1
    80000a22:	4585                	li	a1,1
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	2bc080e7          	jalr	700(ra) # 80000ce0 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a2c:	00011917          	auipc	s2,0x11
    80000a30:	85490913          	addi	s2,s2,-1964 # 80011280 <kmem>
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	1ae080e7          	jalr	430(ra) # 80000be4 <acquire>
  r->next = kmem.freelist;
    80000a3e:	01893783          	ld	a5,24(s2)
    80000a42:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a44:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a48:	854a                	mv	a0,s2
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	24e080e7          	jalr	590(ra) # 80000c98 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6902                	ld	s2,0(sp)
    80000a5a:	6105                	addi	sp,sp,32
    80000a5c:	8082                	ret
    panic("kfree");
    80000a5e:	00007517          	auipc	a0,0x7
    80000a62:	60250513          	addi	a0,a0,1538 # 80008060 <digits+0x20>
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	ad8080e7          	jalr	-1320(ra) # 8000053e <panic>

0000000080000a6e <freerange>:
{
    80000a6e:	7179                	addi	sp,sp,-48
    80000a70:	f406                	sd	ra,40(sp)
    80000a72:	f022                	sd	s0,32(sp)
    80000a74:	ec26                	sd	s1,24(sp)
    80000a76:	e84a                	sd	s2,16(sp)
    80000a78:	e44e                	sd	s3,8(sp)
    80000a7a:	e052                	sd	s4,0(sp)
    80000a7c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a7e:	6785                	lui	a5,0x1
    80000a80:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a84:	94aa                	add	s1,s1,a0
    80000a86:	757d                	lui	a0,0xfffff
    80000a88:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8a:	94be                	add	s1,s1,a5
    80000a8c:	0095ee63          	bltu	a1,s1,80000aa8 <freerange+0x3a>
    80000a90:	892e                	mv	s2,a1
    kfree(p);
    80000a92:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	6985                	lui	s3,0x1
    kfree(p);
    80000a96:	01448533          	add	a0,s1,s4
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	f5e080e7          	jalr	-162(ra) # 800009f8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa2:	94ce                	add	s1,s1,s3
    80000aa4:	fe9979e3          	bgeu	s2,s1,80000a96 <freerange+0x28>
}
    80000aa8:	70a2                	ld	ra,40(sp)
    80000aaa:	7402                	ld	s0,32(sp)
    80000aac:	64e2                	ld	s1,24(sp)
    80000aae:	6942                	ld	s2,16(sp)
    80000ab0:	69a2                	ld	s3,8(sp)
    80000ab2:	6a02                	ld	s4,0(sp)
    80000ab4:	6145                	addi	sp,sp,48
    80000ab6:	8082                	ret

0000000080000ab8 <kinit>:
{
    80000ab8:	1141                	addi	sp,sp,-16
    80000aba:	e406                	sd	ra,8(sp)
    80000abc:	e022                	sd	s0,0(sp)
    80000abe:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac0:	00007597          	auipc	a1,0x7
    80000ac4:	5a858593          	addi	a1,a1,1448 # 80008068 <digits+0x28>
    80000ac8:	00010517          	auipc	a0,0x10
    80000acc:	7b850513          	addi	a0,a0,1976 # 80011280 <kmem>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	084080e7          	jalr	132(ra) # 80000b54 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ad8:	45c5                	li	a1,17
    80000ada:	05ee                	slli	a1,a1,0x1b
    80000adc:	00025517          	auipc	a0,0x25
    80000ae0:	52450513          	addi	a0,a0,1316 # 80026000 <end>
    80000ae4:	00000097          	auipc	ra,0x0
    80000ae8:	f8a080e7          	jalr	-118(ra) # 80000a6e <freerange>
}
    80000aec:	60a2                	ld	ra,8(sp)
    80000aee:	6402                	ld	s0,0(sp)
    80000af0:	0141                	addi	sp,sp,16
    80000af2:	8082                	ret

0000000080000af4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000af4:	1101                	addi	sp,sp,-32
    80000af6:	ec06                	sd	ra,24(sp)
    80000af8:	e822                	sd	s0,16(sp)
    80000afa:	e426                	sd	s1,8(sp)
    80000afc:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000afe:	00010497          	auipc	s1,0x10
    80000b02:	78248493          	addi	s1,s1,1922 # 80011280 <kmem>
    80000b06:	8526                	mv	a0,s1
    80000b08:	00000097          	auipc	ra,0x0
    80000b0c:	0dc080e7          	jalr	220(ra) # 80000be4 <acquire>
  r = kmem.freelist;
    80000b10:	6c84                	ld	s1,24(s1)
  if(r)
    80000b12:	c885                	beqz	s1,80000b42 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b14:	609c                	ld	a5,0(s1)
    80000b16:	00010517          	auipc	a0,0x10
    80000b1a:	76a50513          	addi	a0,a0,1898 # 80011280 <kmem>
    80000b1e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	178080e7          	jalr	376(ra) # 80000c98 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b28:	6605                	lui	a2,0x1
    80000b2a:	4595                	li	a1,5
    80000b2c:	8526                	mv	a0,s1
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	1b2080e7          	jalr	434(ra) # 80000ce0 <memset>
  return (void*)r;
}
    80000b36:	8526                	mv	a0,s1
    80000b38:	60e2                	ld	ra,24(sp)
    80000b3a:	6442                	ld	s0,16(sp)
    80000b3c:	64a2                	ld	s1,8(sp)
    80000b3e:	6105                	addi	sp,sp,32
    80000b40:	8082                	ret
  release(&kmem.lock);
    80000b42:	00010517          	auipc	a0,0x10
    80000b46:	73e50513          	addi	a0,a0,1854 # 80011280 <kmem>
    80000b4a:	00000097          	auipc	ra,0x0
    80000b4e:	14e080e7          	jalr	334(ra) # 80000c98 <release>
  if(r)
    80000b52:	b7d5                	j	80000b36 <kalloc+0x42>

0000000080000b54 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b54:	1141                	addi	sp,sp,-16
    80000b56:	e422                	sd	s0,8(sp)
    80000b58:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b5a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b5c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b60:	00053823          	sd	zero,16(a0)
}
    80000b64:	6422                	ld	s0,8(sp)
    80000b66:	0141                	addi	sp,sp,16
    80000b68:	8082                	ret

0000000080000b6a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	411c                	lw	a5,0(a0)
    80000b6c:	e399                	bnez	a5,80000b72 <holding+0x8>
    80000b6e:	4501                	li	a0,0
  return r;
}
    80000b70:	8082                	ret
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b7c:	6904                	ld	s1,16(a0)
    80000b7e:	00001097          	auipc	ra,0x1
    80000b82:	e16080e7          	jalr	-490(ra) # 80001994 <mycpu>
    80000b86:	40a48533          	sub	a0,s1,a0
    80000b8a:	00153513          	seqz	a0,a0
}
    80000b8e:	60e2                	ld	ra,24(sp)
    80000b90:	6442                	ld	s0,16(sp)
    80000b92:	64a2                	ld	s1,8(sp)
    80000b94:	6105                	addi	sp,sp,32
    80000b96:	8082                	ret

0000000080000b98 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b98:	1101                	addi	sp,sp,-32
    80000b9a:	ec06                	sd	ra,24(sp)
    80000b9c:	e822                	sd	s0,16(sp)
    80000b9e:	e426                	sd	s1,8(sp)
    80000ba0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba2:	100024f3          	csrr	s1,sstatus
    80000ba6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000baa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bac:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb0:	00001097          	auipc	ra,0x1
    80000bb4:	de4080e7          	jalr	-540(ra) # 80001994 <mycpu>
    80000bb8:	5d3c                	lw	a5,120(a0)
    80000bba:	cf89                	beqz	a5,80000bd4 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bbc:	00001097          	auipc	ra,0x1
    80000bc0:	dd8080e7          	jalr	-552(ra) # 80001994 <mycpu>
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	2785                	addiw	a5,a5,1
    80000bc8:	dd3c                	sw	a5,120(a0)
}
    80000bca:	60e2                	ld	ra,24(sp)
    80000bcc:	6442                	ld	s0,16(sp)
    80000bce:	64a2                	ld	s1,8(sp)
    80000bd0:	6105                	addi	sp,sp,32
    80000bd2:	8082                	ret
    mycpu()->intena = old;
    80000bd4:	00001097          	auipc	ra,0x1
    80000bd8:	dc0080e7          	jalr	-576(ra) # 80001994 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bdc:	8085                	srli	s1,s1,0x1
    80000bde:	8885                	andi	s1,s1,1
    80000be0:	dd64                	sw	s1,124(a0)
    80000be2:	bfe9                	j	80000bbc <push_off+0x24>

0000000080000be4 <acquire>:
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
    80000bee:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf0:	00000097          	auipc	ra,0x0
    80000bf4:	fa8080e7          	jalr	-88(ra) # 80000b98 <push_off>
  if(holding(lk))
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	f70080e7          	jalr	-144(ra) # 80000b6a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c02:	4705                	li	a4,1
  if(holding(lk))
    80000c04:	e115                	bnez	a0,80000c28 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c06:	87ba                	mv	a5,a4
    80000c08:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c0c:	2781                	sext.w	a5,a5
    80000c0e:	ffe5                	bnez	a5,80000c06 <acquire+0x22>
  __sync_synchronize();
    80000c10:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	d80080e7          	jalr	-640(ra) # 80001994 <mycpu>
    80000c1c:	e888                	sd	a0,16(s1)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    panic("acquire");
    80000c28:	00007517          	auipc	a0,0x7
    80000c2c:	44850513          	addi	a0,a0,1096 # 80008070 <digits+0x30>
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	d54080e7          	jalr	-684(ra) # 80001994 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c48:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c4c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4e:	e78d                	bnez	a5,80000c78 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c50:	5d3c                	lw	a5,120(a0)
    80000c52:	02f05b63          	blez	a5,80000c88 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c56:	37fd                	addiw	a5,a5,-1
    80000c58:	0007871b          	sext.w	a4,a5
    80000c5c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5e:	eb09                	bnez	a4,80000c70 <pop_off+0x38>
    80000c60:	5d7c                	lw	a5,124(a0)
    80000c62:	c799                	beqz	a5,80000c70 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c64:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c68:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c70:	60a2                	ld	ra,8(sp)
    80000c72:	6402                	ld	s0,0(sp)
    80000c74:	0141                	addi	sp,sp,16
    80000c76:	8082                	ret
    panic("pop_off - interruptible");
    80000c78:	00007517          	auipc	a0,0x7
    80000c7c:	40050513          	addi	a0,a0,1024 # 80008078 <digits+0x38>
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	8be080e7          	jalr	-1858(ra) # 8000053e <panic>
    panic("pop_off");
    80000c88:	00007517          	auipc	a0,0x7
    80000c8c:	40850513          	addi	a0,a0,1032 # 80008090 <digits+0x50>
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	8ae080e7          	jalr	-1874(ra) # 8000053e <panic>

0000000080000c98 <release>:
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
    80000ca2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	ec6080e7          	jalr	-314(ra) # 80000b6a <holding>
    80000cac:	c115                	beqz	a0,80000cd0 <release+0x38>
  lk->cpu = 0;
    80000cae:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb6:	0f50000f          	fence	iorw,ow
    80000cba:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	f7a080e7          	jalr	-134(ra) # 80000c38 <pop_off>
}
    80000cc6:	60e2                	ld	ra,24(sp)
    80000cc8:	6442                	ld	s0,16(sp)
    80000cca:	64a2                	ld	s1,8(sp)
    80000ccc:	6105                	addi	sp,sp,32
    80000cce:	8082                	ret
    panic("release");
    80000cd0:	00007517          	auipc	a0,0x7
    80000cd4:	3c850513          	addi	a0,a0,968 # 80008098 <digits+0x58>
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	866080e7          	jalr	-1946(ra) # 8000053e <panic>

0000000080000ce0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ce6:	ce09                	beqz	a2,80000d00 <memset+0x20>
    80000ce8:	87aa                	mv	a5,a0
    80000cea:	fff6071b          	addiw	a4,a2,-1
    80000cee:	1702                	slli	a4,a4,0x20
    80000cf0:	9301                	srli	a4,a4,0x20
    80000cf2:	0705                	addi	a4,a4,1
    80000cf4:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cf6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cfa:	0785                	addi	a5,a5,1
    80000cfc:	fee79de3          	bne	a5,a4,80000cf6 <memset+0x16>
  }
  return dst;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0c:	ca05                	beqz	a2,80000d3c <memcmp+0x36>
    80000d0e:	fff6069b          	addiw	a3,a2,-1
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	0685                	addi	a3,a3,1
    80000d18:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d1a:	00054783          	lbu	a5,0(a0)
    80000d1e:	0005c703          	lbu	a4,0(a1)
    80000d22:	00e79863          	bne	a5,a4,80000d32 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d26:	0505                	addi	a0,a0,1
    80000d28:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d2a:	fed518e3          	bne	a0,a3,80000d1a <memcmp+0x14>
  }

  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	a019                	j	80000d36 <memcmp+0x30>
      return *s1 - *s2;
    80000d32:	40e7853b          	subw	a0,a5,a4
}
    80000d36:	6422                	ld	s0,8(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
  return 0;
    80000d3c:	4501                	li	a0,0
    80000d3e:	bfe5                	j	80000d36 <memcmp+0x30>

0000000080000d40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e422                	sd	s0,8(sp)
    80000d44:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d46:	ca0d                	beqz	a2,80000d78 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d48:	00a5f963          	bgeu	a1,a0,80000d5a <memmove+0x1a>
    80000d4c:	02061693          	slli	a3,a2,0x20
    80000d50:	9281                	srli	a3,a3,0x20
    80000d52:	00d58733          	add	a4,a1,a3
    80000d56:	02e56463          	bltu	a0,a4,80000d7e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d5a:	fff6079b          	addiw	a5,a2,-1
    80000d5e:	1782                	slli	a5,a5,0x20
    80000d60:	9381                	srli	a5,a5,0x20
    80000d62:	0785                	addi	a5,a5,1
    80000d64:	97ae                	add	a5,a5,a1
    80000d66:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d68:	0585                	addi	a1,a1,1
    80000d6a:	0705                	addi	a4,a4,1
    80000d6c:	fff5c683          	lbu	a3,-1(a1)
    80000d70:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d74:	fef59ae3          	bne	a1,a5,80000d68 <memmove+0x28>

  return dst;
}
    80000d78:	6422                	ld	s0,8(sp)
    80000d7a:	0141                	addi	sp,sp,16
    80000d7c:	8082                	ret
    d += n;
    80000d7e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d80:	fff6079b          	addiw	a5,a2,-1
    80000d84:	1782                	slli	a5,a5,0x20
    80000d86:	9381                	srli	a5,a5,0x20
    80000d88:	fff7c793          	not	a5,a5
    80000d8c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d8e:	177d                	addi	a4,a4,-1
    80000d90:	16fd                	addi	a3,a3,-1
    80000d92:	00074603          	lbu	a2,0(a4)
    80000d96:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d9a:	fef71ae3          	bne	a4,a5,80000d8e <memmove+0x4e>
    80000d9e:	bfe9                	j	80000d78 <memmove+0x38>

0000000080000da0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e406                	sd	ra,8(sp)
    80000da4:	e022                	sd	s0,0(sp)
    80000da6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da8:	00000097          	auipc	ra,0x0
    80000dac:	f98080e7          	jalr	-104(ra) # 80000d40 <memmove>
}
    80000db0:	60a2                	ld	ra,8(sp)
    80000db2:	6402                	ld	s0,0(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dbe:	ce11                	beqz	a2,80000dda <strncmp+0x22>
    80000dc0:	00054783          	lbu	a5,0(a0)
    80000dc4:	cf89                	beqz	a5,80000dde <strncmp+0x26>
    80000dc6:	0005c703          	lbu	a4,0(a1)
    80000dca:	00f71a63          	bne	a4,a5,80000dde <strncmp+0x26>
    n--, p++, q++;
    80000dce:	367d                	addiw	a2,a2,-1
    80000dd0:	0505                	addi	a0,a0,1
    80000dd2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd4:	f675                	bnez	a2,80000dc0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	a809                	j	80000dea <strncmp+0x32>
    80000dda:	4501                	li	a0,0
    80000ddc:	a039                	j	80000dea <strncmp+0x32>
  if(n == 0)
    80000dde:	ca09                	beqz	a2,80000df0 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de0:	00054503          	lbu	a0,0(a0)
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	9d1d                	subw	a0,a0,a5
}
    80000dea:	6422                	ld	s0,8(sp)
    80000dec:	0141                	addi	sp,sp,16
    80000dee:	8082                	ret
    return 0;
    80000df0:	4501                	li	a0,0
    80000df2:	bfe5                	j	80000dea <strncmp+0x32>

0000000080000df4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df4:	1141                	addi	sp,sp,-16
    80000df6:	e422                	sd	s0,8(sp)
    80000df8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dfa:	872a                	mv	a4,a0
    80000dfc:	8832                	mv	a6,a2
    80000dfe:	367d                	addiw	a2,a2,-1
    80000e00:	01005963          	blez	a6,80000e12 <strncpy+0x1e>
    80000e04:	0705                	addi	a4,a4,1
    80000e06:	0005c783          	lbu	a5,0(a1)
    80000e0a:	fef70fa3          	sb	a5,-1(a4)
    80000e0e:	0585                	addi	a1,a1,1
    80000e10:	f7f5                	bnez	a5,80000dfc <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e12:	00c05d63          	blez	a2,80000e2c <strncpy+0x38>
    80000e16:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e18:	0685                	addi	a3,a3,1
    80000e1a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e1e:	fff6c793          	not	a5,a3
    80000e22:	9fb9                	addw	a5,a5,a4
    80000e24:	010787bb          	addw	a5,a5,a6
    80000e28:	fef048e3          	bgtz	a5,80000e18 <strncpy+0x24>
  return os;
}
    80000e2c:	6422                	ld	s0,8(sp)
    80000e2e:	0141                	addi	sp,sp,16
    80000e30:	8082                	ret

0000000080000e32 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e422                	sd	s0,8(sp)
    80000e36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e38:	02c05363          	blez	a2,80000e5e <safestrcpy+0x2c>
    80000e3c:	fff6069b          	addiw	a3,a2,-1
    80000e40:	1682                	slli	a3,a3,0x20
    80000e42:	9281                	srli	a3,a3,0x20
    80000e44:	96ae                	add	a3,a3,a1
    80000e46:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e48:	00d58963          	beq	a1,a3,80000e5a <safestrcpy+0x28>
    80000e4c:	0585                	addi	a1,a1,1
    80000e4e:	0785                	addi	a5,a5,1
    80000e50:	fff5c703          	lbu	a4,-1(a1)
    80000e54:	fee78fa3          	sb	a4,-1(a5)
    80000e58:	fb65                	bnez	a4,80000e48 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e5a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e5e:	6422                	ld	s0,8(sp)
    80000e60:	0141                	addi	sp,sp,16
    80000e62:	8082                	ret

0000000080000e64 <strlen>:

int
strlen(const char *s)
{
    80000e64:	1141                	addi	sp,sp,-16
    80000e66:	e422                	sd	s0,8(sp)
    80000e68:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e6a:	00054783          	lbu	a5,0(a0)
    80000e6e:	cf91                	beqz	a5,80000e8a <strlen+0x26>
    80000e70:	0505                	addi	a0,a0,1
    80000e72:	87aa                	mv	a5,a0
    80000e74:	4685                	li	a3,1
    80000e76:	9e89                	subw	a3,a3,a0
    80000e78:	00f6853b          	addw	a0,a3,a5
    80000e7c:	0785                	addi	a5,a5,1
    80000e7e:	fff7c703          	lbu	a4,-1(a5)
    80000e82:	fb7d                	bnez	a4,80000e78 <strlen+0x14>
    ;
  return n;
}
    80000e84:	6422                	ld	s0,8(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e8a:	4501                	li	a0,0
    80000e8c:	bfe5                	j	80000e84 <strlen+0x20>

0000000080000e8e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	aee080e7          	jalr	-1298(ra) # 80001984 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e9e:	00008717          	auipc	a4,0x8
    80000ea2:	17a70713          	addi	a4,a4,378 # 80009018 <started>
  if(cpuid() == 0){
    80000ea6:	c139                	beqz	a0,80000eec <main+0x5e>
    while(started == 0)
    80000ea8:	431c                	lw	a5,0(a4)
    80000eaa:	2781                	sext.w	a5,a5
    80000eac:	dff5                	beqz	a5,80000ea8 <main+0x1a>
      ;
    __sync_synchronize();
    80000eae:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb2:	00001097          	auipc	ra,0x1
    80000eb6:	ad2080e7          	jalr	-1326(ra) # 80001984 <cpuid>
    80000eba:	85aa                	mv	a1,a0
    80000ebc:	00007517          	auipc	a0,0x7
    80000ec0:	1fc50513          	addi	a0,a0,508 # 800080b8 <digits+0x78>
    80000ec4:	fffff097          	auipc	ra,0xfffff
    80000ec8:	6c4080e7          	jalr	1732(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000ecc:	00000097          	auipc	ra,0x0
    80000ed0:	0d8080e7          	jalr	216(ra) # 80000fa4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed4:	00002097          	auipc	ra,0x2
    80000ed8:	870080e7          	jalr	-1936(ra) # 80002744 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000edc:	00005097          	auipc	ra,0x5
    80000ee0:	e84080e7          	jalr	-380(ra) # 80005d60 <plicinithart>
  }

  scheduler();        
    80000ee4:	00001097          	auipc	ra,0x1
    80000ee8:	11e080e7          	jalr	286(ra) # 80002002 <scheduler>
    consoleinit();
    80000eec:	fffff097          	auipc	ra,0xfffff
    80000ef0:	564080e7          	jalr	1380(ra) # 80000450 <consoleinit>
    printfinit();
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	87a080e7          	jalr	-1926(ra) # 8000076e <printfinit>
    printf("\n");
    80000efc:	00007517          	auipc	a0,0x7
    80000f00:	1cc50513          	addi	a0,a0,460 # 800080c8 <digits+0x88>
    80000f04:	fffff097          	auipc	ra,0xfffff
    80000f08:	684080e7          	jalr	1668(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000f0c:	00007517          	auipc	a0,0x7
    80000f10:	19450513          	addi	a0,a0,404 # 800080a0 <digits+0x60>
    80000f14:	fffff097          	auipc	ra,0xfffff
    80000f18:	674080e7          	jalr	1652(ra) # 80000588 <printf>
    printf("\n");
    80000f1c:	00007517          	auipc	a0,0x7
    80000f20:	1ac50513          	addi	a0,a0,428 # 800080c8 <digits+0x88>
    80000f24:	fffff097          	auipc	ra,0xfffff
    80000f28:	664080e7          	jalr	1636(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	b8c080e7          	jalr	-1140(ra) # 80000ab8 <kinit>
    kvminit();       // create kernel page table
    80000f34:	00000097          	auipc	ra,0x0
    80000f38:	322080e7          	jalr	802(ra) # 80001256 <kvminit>
    kvminithart();   // turn on paging
    80000f3c:	00000097          	auipc	ra,0x0
    80000f40:	068080e7          	jalr	104(ra) # 80000fa4 <kvminithart>
    procinit();      // process table
    80000f44:	00001097          	auipc	ra,0x1
    80000f48:	990080e7          	jalr	-1648(ra) # 800018d4 <procinit>
    trapinit();      // trap vectors
    80000f4c:	00001097          	auipc	ra,0x1
    80000f50:	7d0080e7          	jalr	2000(ra) # 8000271c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f54:	00001097          	auipc	ra,0x1
    80000f58:	7f0080e7          	jalr	2032(ra) # 80002744 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	dee080e7          	jalr	-530(ra) # 80005d4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f64:	00005097          	auipc	ra,0x5
    80000f68:	dfc080e7          	jalr	-516(ra) # 80005d60 <plicinithart>
    binit();         // buffer cache
    80000f6c:	00002097          	auipc	ra,0x2
    80000f70:	fd6080e7          	jalr	-42(ra) # 80002f42 <binit>
    iinit();         // inode table
    80000f74:	00002097          	auipc	ra,0x2
    80000f78:	666080e7          	jalr	1638(ra) # 800035da <iinit>
    fileinit();      // file table
    80000f7c:	00003097          	auipc	ra,0x3
    80000f80:	610080e7          	jalr	1552(ra) # 8000458c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	efe080e7          	jalr	-258(ra) # 80005e82 <virtio_disk_init>
    userinit();      // first user process
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	cfc080e7          	jalr	-772(ra) # 80001c88 <userinit>
    __sync_synchronize();
    80000f94:	0ff0000f          	fence
    started = 1;
    80000f98:	4785                	li	a5,1
    80000f9a:	00008717          	auipc	a4,0x8
    80000f9e:	06f72f23          	sw	a5,126(a4) # 80009018 <started>
    80000fa2:	b789                	j	80000ee4 <main+0x56>

0000000080000fa4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa4:	1141                	addi	sp,sp,-16
    80000fa6:	e422                	sd	s0,8(sp)
    80000fa8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000faa:	00008797          	auipc	a5,0x8
    80000fae:	0767b783          	ld	a5,118(a5) # 80009020 <kernel_pagetable>
    80000fb2:	83b1                	srli	a5,a5,0xc
    80000fb4:	577d                	li	a4,-1
    80000fb6:	177e                	slli	a4,a4,0x3f
    80000fb8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fba:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fbe:	12000073          	sfence.vma
  sfence_vma();
}
    80000fc2:	6422                	ld	s0,8(sp)
    80000fc4:	0141                	addi	sp,sp,16
    80000fc6:	8082                	ret

0000000080000fc8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc8:	7139                	addi	sp,sp,-64
    80000fca:	fc06                	sd	ra,56(sp)
    80000fcc:	f822                	sd	s0,48(sp)
    80000fce:	f426                	sd	s1,40(sp)
    80000fd0:	f04a                	sd	s2,32(sp)
    80000fd2:	ec4e                	sd	s3,24(sp)
    80000fd4:	e852                	sd	s4,16(sp)
    80000fd6:	e456                	sd	s5,8(sp)
    80000fd8:	e05a                	sd	s6,0(sp)
    80000fda:	0080                	addi	s0,sp,64
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	89ae                	mv	s3,a1
    80000fe0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe2:	57fd                	li	a5,-1
    80000fe4:	83e9                	srli	a5,a5,0x1a
    80000fe6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe8:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fea:	04b7f263          	bgeu	a5,a1,8000102e <walk+0x66>
    panic("walk");
    80000fee:	00007517          	auipc	a0,0x7
    80000ff2:	0e250513          	addi	a0,a0,226 # 800080d0 <digits+0x90>
    80000ff6:	fffff097          	auipc	ra,0xfffff
    80000ffa:	548080e7          	jalr	1352(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	060a8663          	beqz	s5,8000106a <walk+0xa2>
    80001002:	00000097          	auipc	ra,0x0
    80001006:	af2080e7          	jalr	-1294(ra) # 80000af4 <kalloc>
    8000100a:	84aa                	mv	s1,a0
    8000100c:	c529                	beqz	a0,80001056 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100e:	6605                	lui	a2,0x1
    80001010:	4581                	li	a1,0
    80001012:	00000097          	auipc	ra,0x0
    80001016:	cce080e7          	jalr	-818(ra) # 80000ce0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101a:	00c4d793          	srli	a5,s1,0xc
    8000101e:	07aa                	slli	a5,a5,0xa
    80001020:	0017e793          	ori	a5,a5,1
    80001024:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001028:	3a5d                	addiw	s4,s4,-9
    8000102a:	036a0063          	beq	s4,s6,8000104a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000102e:	0149d933          	srl	s2,s3,s4
    80001032:	1ff97913          	andi	s2,s2,511
    80001036:	090e                	slli	s2,s2,0x3
    80001038:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000103a:	00093483          	ld	s1,0(s2)
    8000103e:	0014f793          	andi	a5,s1,1
    80001042:	dfd5                	beqz	a5,80000ffe <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001044:	80a9                	srli	s1,s1,0xa
    80001046:	04b2                	slli	s1,s1,0xc
    80001048:	b7c5                	j	80001028 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000104a:	00c9d513          	srli	a0,s3,0xc
    8000104e:	1ff57513          	andi	a0,a0,511
    80001052:	050e                	slli	a0,a0,0x3
    80001054:	9526                	add	a0,a0,s1
}
    80001056:	70e2                	ld	ra,56(sp)
    80001058:	7442                	ld	s0,48(sp)
    8000105a:	74a2                	ld	s1,40(sp)
    8000105c:	7902                	ld	s2,32(sp)
    8000105e:	69e2                	ld	s3,24(sp)
    80001060:	6a42                	ld	s4,16(sp)
    80001062:	6aa2                	ld	s5,8(sp)
    80001064:	6b02                	ld	s6,0(sp)
    80001066:	6121                	addi	sp,sp,64
    80001068:	8082                	ret
        return 0;
    8000106a:	4501                	li	a0,0
    8000106c:	b7ed                	j	80001056 <walk+0x8e>

000000008000106e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000106e:	57fd                	li	a5,-1
    80001070:	83e9                	srli	a5,a5,0x1a
    80001072:	00b7f463          	bgeu	a5,a1,8000107a <walkaddr+0xc>
    return 0;
    80001076:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001078:	8082                	ret
{
    8000107a:	1141                	addi	sp,sp,-16
    8000107c:	e406                	sd	ra,8(sp)
    8000107e:	e022                	sd	s0,0(sp)
    80001080:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001082:	4601                	li	a2,0
    80001084:	00000097          	auipc	ra,0x0
    80001088:	f44080e7          	jalr	-188(ra) # 80000fc8 <walk>
  if(pte == 0)
    8000108c:	c105                	beqz	a0,800010ac <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000108e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001090:	0117f693          	andi	a3,a5,17
    80001094:	4745                	li	a4,17
    return 0;
    80001096:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001098:	00e68663          	beq	a3,a4,800010a4 <walkaddr+0x36>
}
    8000109c:	60a2                	ld	ra,8(sp)
    8000109e:	6402                	ld	s0,0(sp)
    800010a0:	0141                	addi	sp,sp,16
    800010a2:	8082                	ret
  pa = PTE2PA(*pte);
    800010a4:	00a7d513          	srli	a0,a5,0xa
    800010a8:	0532                	slli	a0,a0,0xc
  return pa;
    800010aa:	bfcd                	j	8000109c <walkaddr+0x2e>
    return 0;
    800010ac:	4501                	li	a0,0
    800010ae:	b7fd                	j	8000109c <walkaddr+0x2e>

00000000800010b0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b0:	715d                	addi	sp,sp,-80
    800010b2:	e486                	sd	ra,72(sp)
    800010b4:	e0a2                	sd	s0,64(sp)
    800010b6:	fc26                	sd	s1,56(sp)
    800010b8:	f84a                	sd	s2,48(sp)
    800010ba:	f44e                	sd	s3,40(sp)
    800010bc:	f052                	sd	s4,32(sp)
    800010be:	ec56                	sd	s5,24(sp)
    800010c0:	e85a                	sd	s6,16(sp)
    800010c2:	e45e                	sd	s7,8(sp)
    800010c4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010c6:	c205                	beqz	a2,800010e6 <mappages+0x36>
    800010c8:	8aaa                	mv	s5,a0
    800010ca:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010cc:	77fd                	lui	a5,0xfffff
    800010ce:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010d2:	15fd                	addi	a1,a1,-1
    800010d4:	00c589b3          	add	s3,a1,a2
    800010d8:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010dc:	8952                	mv	s2,s4
    800010de:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e2:	6b85                	lui	s7,0x1
    800010e4:	a015                	j	80001108 <mappages+0x58>
    panic("mappages: size");
    800010e6:	00007517          	auipc	a0,0x7
    800010ea:	ff250513          	addi	a0,a0,-14 # 800080d8 <digits+0x98>
    800010ee:	fffff097          	auipc	ra,0xfffff
    800010f2:	450080e7          	jalr	1104(ra) # 8000053e <panic>
      panic("mappages: remap");
    800010f6:	00007517          	auipc	a0,0x7
    800010fa:	ff250513          	addi	a0,a0,-14 # 800080e8 <digits+0xa8>
    800010fe:	fffff097          	auipc	ra,0xfffff
    80001102:	440080e7          	jalr	1088(ra) # 8000053e <panic>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
  for(;;){
    80001108:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110c:	4605                	li	a2,1
    8000110e:	85ca                	mv	a1,s2
    80001110:	8556                	mv	a0,s5
    80001112:	00000097          	auipc	ra,0x0
    80001116:	eb6080e7          	jalr	-330(ra) # 80000fc8 <walk>
    8000111a:	cd19                	beqz	a0,80001138 <mappages+0x88>
    if(*pte & PTE_V)
    8000111c:	611c                	ld	a5,0(a0)
    8000111e:	8b85                	andi	a5,a5,1
    80001120:	fbf9                	bnez	a5,800010f6 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001122:	80b1                	srli	s1,s1,0xc
    80001124:	04aa                	slli	s1,s1,0xa
    80001126:	0164e4b3          	or	s1,s1,s6
    8000112a:	0014e493          	ori	s1,s1,1
    8000112e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001130:	fd391be3          	bne	s2,s3,80001106 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	a011                	j	8000113a <mappages+0x8a>
      return -1;
    80001138:	557d                	li	a0,-1
}
    8000113a:	60a6                	ld	ra,72(sp)
    8000113c:	6406                	ld	s0,64(sp)
    8000113e:	74e2                	ld	s1,56(sp)
    80001140:	7942                	ld	s2,48(sp)
    80001142:	79a2                	ld	s3,40(sp)
    80001144:	7a02                	ld	s4,32(sp)
    80001146:	6ae2                	ld	s5,24(sp)
    80001148:	6b42                	ld	s6,16(sp)
    8000114a:	6ba2                	ld	s7,8(sp)
    8000114c:	6161                	addi	sp,sp,80
    8000114e:	8082                	ret

0000000080001150 <kvmmap>:
{
    80001150:	1141                	addi	sp,sp,-16
    80001152:	e406                	sd	ra,8(sp)
    80001154:	e022                	sd	s0,0(sp)
    80001156:	0800                	addi	s0,sp,16
    80001158:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000115a:	86b2                	mv	a3,a2
    8000115c:	863e                	mv	a2,a5
    8000115e:	00000097          	auipc	ra,0x0
    80001162:	f52080e7          	jalr	-174(ra) # 800010b0 <mappages>
    80001166:	e509                	bnez	a0,80001170 <kvmmap+0x20>
}
    80001168:	60a2                	ld	ra,8(sp)
    8000116a:	6402                	ld	s0,0(sp)
    8000116c:	0141                	addi	sp,sp,16
    8000116e:	8082                	ret
    panic("kvmmap");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	f8850513          	addi	a0,a0,-120 # 800080f8 <digits+0xb8>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	3c6080e7          	jalr	966(ra) # 8000053e <panic>

0000000080001180 <kvmmake>:
{
    80001180:	1101                	addi	sp,sp,-32
    80001182:	ec06                	sd	ra,24(sp)
    80001184:	e822                	sd	s0,16(sp)
    80001186:	e426                	sd	s1,8(sp)
    80001188:	e04a                	sd	s2,0(sp)
    8000118a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	968080e7          	jalr	-1688(ra) # 80000af4 <kalloc>
    80001194:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001196:	6605                	lui	a2,0x1
    80001198:	4581                	li	a1,0
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	b46080e7          	jalr	-1210(ra) # 80000ce0 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011a2:	4719                	li	a4,6
    800011a4:	6685                	lui	a3,0x1
    800011a6:	10000637          	lui	a2,0x10000
    800011aa:	100005b7          	lui	a1,0x10000
    800011ae:	8526                	mv	a0,s1
    800011b0:	00000097          	auipc	ra,0x0
    800011b4:	fa0080e7          	jalr	-96(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b8:	4719                	li	a4,6
    800011ba:	6685                	lui	a3,0x1
    800011bc:	10001637          	lui	a2,0x10001
    800011c0:	100015b7          	lui	a1,0x10001
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f8a080e7          	jalr	-118(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ce:	4719                	li	a4,6
    800011d0:	004006b7          	lui	a3,0x400
    800011d4:	0c000637          	lui	a2,0xc000
    800011d8:	0c0005b7          	lui	a1,0xc000
    800011dc:	8526                	mv	a0,s1
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	f72080e7          	jalr	-142(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e6:	00007917          	auipc	s2,0x7
    800011ea:	e1a90913          	addi	s2,s2,-486 # 80008000 <etext>
    800011ee:	4729                	li	a4,10
    800011f0:	80007697          	auipc	a3,0x80007
    800011f4:	e1068693          	addi	a3,a3,-496 # 8000 <_entry-0x7fff8000>
    800011f8:	4605                	li	a2,1
    800011fa:	067e                	slli	a2,a2,0x1f
    800011fc:	85b2                	mv	a1,a2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f50080e7          	jalr	-176(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001208:	4719                	li	a4,6
    8000120a:	46c5                	li	a3,17
    8000120c:	06ee                	slli	a3,a3,0x1b
    8000120e:	412686b3          	sub	a3,a3,s2
    80001212:	864a                	mv	a2,s2
    80001214:	85ca                	mv	a1,s2
    80001216:	8526                	mv	a0,s1
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	f38080e7          	jalr	-200(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001220:	4729                	li	a4,10
    80001222:	6685                	lui	a3,0x1
    80001224:	00006617          	auipc	a2,0x6
    80001228:	ddc60613          	addi	a2,a2,-548 # 80007000 <_trampoline>
    8000122c:	040005b7          	lui	a1,0x4000
    80001230:	15fd                	addi	a1,a1,-1
    80001232:	05b2                	slli	a1,a1,0xc
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	f1a080e7          	jalr	-230(ra) # 80001150 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	5fe080e7          	jalr	1534(ra) # 8000183e <proc_mapstacks>
}
    80001248:	8526                	mv	a0,s1
    8000124a:	60e2                	ld	ra,24(sp)
    8000124c:	6442                	ld	s0,16(sp)
    8000124e:	64a2                	ld	s1,8(sp)
    80001250:	6902                	ld	s2,0(sp)
    80001252:	6105                	addi	sp,sp,32
    80001254:	8082                	ret

0000000080001256 <kvminit>:
{
    80001256:	1141                	addi	sp,sp,-16
    80001258:	e406                	sd	ra,8(sp)
    8000125a:	e022                	sd	s0,0(sp)
    8000125c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f22080e7          	jalr	-222(ra) # 80001180 <kvmmake>
    80001266:	00008797          	auipc	a5,0x8
    8000126a:	daa7bd23          	sd	a0,-582(a5) # 80009020 <kernel_pagetable>
}
    8000126e:	60a2                	ld	ra,8(sp)
    80001270:	6402                	ld	s0,0(sp)
    80001272:	0141                	addi	sp,sp,16
    80001274:	8082                	ret

0000000080001276 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001276:	715d                	addi	sp,sp,-80
    80001278:	e486                	sd	ra,72(sp)
    8000127a:	e0a2                	sd	s0,64(sp)
    8000127c:	fc26                	sd	s1,56(sp)
    8000127e:	f84a                	sd	s2,48(sp)
    80001280:	f44e                	sd	s3,40(sp)
    80001282:	f052                	sd	s4,32(sp)
    80001284:	ec56                	sd	s5,24(sp)
    80001286:	e85a                	sd	s6,16(sp)
    80001288:	e45e                	sd	s7,8(sp)
    8000128a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000128c:	03459793          	slli	a5,a1,0x34
    80001290:	e795                	bnez	a5,800012bc <uvmunmap+0x46>
    80001292:	8a2a                	mv	s4,a0
    80001294:	892e                	mv	s2,a1
    80001296:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001298:	0632                	slli	a2,a2,0xc
    8000129a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000129e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a0:	6b05                	lui	s6,0x1
    800012a2:	0735e863          	bltu	a1,s3,80001312 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a6:	60a6                	ld	ra,72(sp)
    800012a8:	6406                	ld	s0,64(sp)
    800012aa:	74e2                	ld	s1,56(sp)
    800012ac:	7942                	ld	s2,48(sp)
    800012ae:	79a2                	ld	s3,40(sp)
    800012b0:	7a02                	ld	s4,32(sp)
    800012b2:	6ae2                	ld	s5,24(sp)
    800012b4:	6b42                	ld	s6,16(sp)
    800012b6:	6ba2                	ld	s7,8(sp)
    800012b8:	6161                	addi	sp,sp,80
    800012ba:	8082                	ret
    panic("uvmunmap: not aligned");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e4450513          	addi	a0,a0,-444 # 80008100 <digits+0xc0>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	27a080e7          	jalr	634(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e4c50513          	addi	a0,a0,-436 # 80008118 <digits+0xd8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	26a080e7          	jalr	618(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012dc:	00007517          	auipc	a0,0x7
    800012e0:	e4c50513          	addi	a0,a0,-436 # 80008128 <digits+0xe8>
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	25a080e7          	jalr	602(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012ec:	00007517          	auipc	a0,0x7
    800012f0:	e5450513          	addi	a0,a0,-428 # 80008140 <digits+0x100>
    800012f4:	fffff097          	auipc	ra,0xfffff
    800012f8:	24a080e7          	jalr	586(ra) # 8000053e <panic>
      uint64 pa = PTE2PA(*pte);
    800012fc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fe:	0532                	slli	a0,a0,0xc
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	6f8080e7          	jalr	1784(ra) # 800009f8 <kfree>
    *pte = 0;
    80001308:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	995a                	add	s2,s2,s6
    8000130e:	f9397ce3          	bgeu	s2,s3,800012a6 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001312:	4601                	li	a2,0
    80001314:	85ca                	mv	a1,s2
    80001316:	8552                	mv	a0,s4
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	cb0080e7          	jalr	-848(ra) # 80000fc8 <walk>
    80001320:	84aa                	mv	s1,a0
    80001322:	d54d                	beqz	a0,800012cc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001324:	6108                	ld	a0,0(a0)
    80001326:	00157793          	andi	a5,a0,1
    8000132a:	dbcd                	beqz	a5,800012dc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132c:	3ff57793          	andi	a5,a0,1023
    80001330:	fb778ee3          	beq	a5,s7,800012ec <uvmunmap+0x76>
    if(do_free){
    80001334:	fc0a8ae3          	beqz	s5,80001308 <uvmunmap+0x92>
    80001338:	b7d1                	j	800012fc <uvmunmap+0x86>

000000008000133a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000133a:	1101                	addi	sp,sp,-32
    8000133c:	ec06                	sd	ra,24(sp)
    8000133e:	e822                	sd	s0,16(sp)
    80001340:	e426                	sd	s1,8(sp)
    80001342:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	7b0080e7          	jalr	1968(ra) # 80000af4 <kalloc>
    8000134c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134e:	c519                	beqz	a0,8000135c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001350:	6605                	lui	a2,0x1
    80001352:	4581                	li	a1,0
    80001354:	00000097          	auipc	ra,0x0
    80001358:	98c080e7          	jalr	-1652(ra) # 80000ce0 <memset>
  return pagetable;
}
    8000135c:	8526                	mv	a0,s1
    8000135e:	60e2                	ld	ra,24(sp)
    80001360:	6442                	ld	s0,16(sp)
    80001362:	64a2                	ld	s1,8(sp)
    80001364:	6105                	addi	sp,sp,32
    80001366:	8082                	ret

0000000080001368 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001368:	7179                	addi	sp,sp,-48
    8000136a:	f406                	sd	ra,40(sp)
    8000136c:	f022                	sd	s0,32(sp)
    8000136e:	ec26                	sd	s1,24(sp)
    80001370:	e84a                	sd	s2,16(sp)
    80001372:	e44e                	sd	s3,8(sp)
    80001374:	e052                	sd	s4,0(sp)
    80001376:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001378:	6785                	lui	a5,0x1
    8000137a:	04f67863          	bgeu	a2,a5,800013ca <uvminit+0x62>
    8000137e:	8a2a                	mv	s4,a0
    80001380:	89ae                	mv	s3,a1
    80001382:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001384:	fffff097          	auipc	ra,0xfffff
    80001388:	770080e7          	jalr	1904(ra) # 80000af4 <kalloc>
    8000138c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	00000097          	auipc	ra,0x0
    80001396:	94e080e7          	jalr	-1714(ra) # 80000ce0 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000139a:	4779                	li	a4,30
    8000139c:	86ca                	mv	a3,s2
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	8552                	mv	a0,s4
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	d0c080e7          	jalr	-756(ra) # 800010b0 <mappages>
  memmove(mem, src, sz);
    800013ac:	8626                	mv	a2,s1
    800013ae:	85ce                	mv	a1,s3
    800013b0:	854a                	mv	a0,s2
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	98e080e7          	jalr	-1650(ra) # 80000d40 <memmove>
}
    800013ba:	70a2                	ld	ra,40(sp)
    800013bc:	7402                	ld	s0,32(sp)
    800013be:	64e2                	ld	s1,24(sp)
    800013c0:	6942                	ld	s2,16(sp)
    800013c2:	69a2                	ld	s3,8(sp)
    800013c4:	6a02                	ld	s4,0(sp)
    800013c6:	6145                	addi	sp,sp,48
    800013c8:	8082                	ret
    panic("inituvm: more than a page");
    800013ca:	00007517          	auipc	a0,0x7
    800013ce:	d8e50513          	addi	a0,a0,-626 # 80008158 <digits+0x118>
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	16c080e7          	jalr	364(ra) # 8000053e <panic>

00000000800013da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013da:	1101                	addi	sp,sp,-32
    800013dc:	ec06                	sd	ra,24(sp)
    800013de:	e822                	sd	s0,16(sp)
    800013e0:	e426                	sd	s1,8(sp)
    800013e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e6:	00b67d63          	bgeu	a2,a1,80001400 <uvmdealloc+0x26>
    800013ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ec:	6785                	lui	a5,0x1
    800013ee:	17fd                	addi	a5,a5,-1
    800013f0:	00f60733          	add	a4,a2,a5
    800013f4:	767d                	lui	a2,0xfffff
    800013f6:	8f71                	and	a4,a4,a2
    800013f8:	97ae                	add	a5,a5,a1
    800013fa:	8ff1                	and	a5,a5,a2
    800013fc:	00f76863          	bltu	a4,a5,8000140c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001400:	8526                	mv	a0,s1
    80001402:	60e2                	ld	ra,24(sp)
    80001404:	6442                	ld	s0,16(sp)
    80001406:	64a2                	ld	s1,8(sp)
    80001408:	6105                	addi	sp,sp,32
    8000140a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140c:	8f99                	sub	a5,a5,a4
    8000140e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001410:	4685                	li	a3,1
    80001412:	0007861b          	sext.w	a2,a5
    80001416:	85ba                	mv	a1,a4
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	e5e080e7          	jalr	-418(ra) # 80001276 <uvmunmap>
    80001420:	b7c5                	j	80001400 <uvmdealloc+0x26>

0000000080001422 <uvmalloc>:
  if(newsz < oldsz)
    80001422:	0ab66163          	bltu	a2,a1,800014c4 <uvmalloc+0xa2>
{
    80001426:	7139                	addi	sp,sp,-64
    80001428:	fc06                	sd	ra,56(sp)
    8000142a:	f822                	sd	s0,48(sp)
    8000142c:	f426                	sd	s1,40(sp)
    8000142e:	f04a                	sd	s2,32(sp)
    80001430:	ec4e                	sd	s3,24(sp)
    80001432:	e852                	sd	s4,16(sp)
    80001434:	e456                	sd	s5,8(sp)
    80001436:	0080                	addi	s0,sp,64
    80001438:	8aaa                	mv	s5,a0
    8000143a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143c:	6985                	lui	s3,0x1
    8000143e:	19fd                	addi	s3,s3,-1
    80001440:	95ce                	add	a1,a1,s3
    80001442:	79fd                	lui	s3,0xfffff
    80001444:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001448:	08c9f063          	bgeu	s3,a2,800014c8 <uvmalloc+0xa6>
    8000144c:	894e                	mv	s2,s3
    mem = kalloc();
    8000144e:	fffff097          	auipc	ra,0xfffff
    80001452:	6a6080e7          	jalr	1702(ra) # 80000af4 <kalloc>
    80001456:	84aa                	mv	s1,a0
    if(mem == 0){
    80001458:	c51d                	beqz	a0,80001486 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000145a:	6605                	lui	a2,0x1
    8000145c:	4581                	li	a1,0
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	882080e7          	jalr	-1918(ra) # 80000ce0 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001466:	4779                	li	a4,30
    80001468:	86a6                	mv	a3,s1
    8000146a:	6605                	lui	a2,0x1
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	c40080e7          	jalr	-960(ra) # 800010b0 <mappages>
    80001478:	e905                	bnez	a0,800014a8 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147a:	6785                	lui	a5,0x1
    8000147c:	993e                	add	s2,s2,a5
    8000147e:	fd4968e3          	bltu	s2,s4,8000144e <uvmalloc+0x2c>
  return newsz;
    80001482:	8552                	mv	a0,s4
    80001484:	a809                	j	80001496 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001486:	864e                	mv	a2,s3
    80001488:	85ca                	mv	a1,s2
    8000148a:	8556                	mv	a0,s5
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	f4e080e7          	jalr	-178(ra) # 800013da <uvmdealloc>
      return 0;
    80001494:	4501                	li	a0,0
}
    80001496:	70e2                	ld	ra,56(sp)
    80001498:	7442                	ld	s0,48(sp)
    8000149a:	74a2                	ld	s1,40(sp)
    8000149c:	7902                	ld	s2,32(sp)
    8000149e:	69e2                	ld	s3,24(sp)
    800014a0:	6a42                	ld	s4,16(sp)
    800014a2:	6aa2                	ld	s5,8(sp)
    800014a4:	6121                	addi	sp,sp,64
    800014a6:	8082                	ret
      kfree(mem);
    800014a8:	8526                	mv	a0,s1
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	54e080e7          	jalr	1358(ra) # 800009f8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f22080e7          	jalr	-222(ra) # 800013da <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	bfd1                	j	80001496 <uvmalloc+0x74>
    return oldsz;
    800014c4:	852e                	mv	a0,a1
}
    800014c6:	8082                	ret
  return newsz;
    800014c8:	8532                	mv	a0,a2
    800014ca:	b7f1                	j	80001496 <uvmalloc+0x74>

00000000800014cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014cc:	7179                	addi	sp,sp,-48
    800014ce:	f406                	sd	ra,40(sp)
    800014d0:	f022                	sd	s0,32(sp)
    800014d2:	ec26                	sd	s1,24(sp)
    800014d4:	e84a                	sd	s2,16(sp)
    800014d6:	e44e                	sd	s3,8(sp)
    800014d8:	e052                	sd	s4,0(sp)
    800014da:	1800                	addi	s0,sp,48
    800014dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014de:	84aa                	mv	s1,a0
    800014e0:	6905                	lui	s2,0x1
    800014e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	4985                	li	s3,1
    800014e6:	a821                	j	800014fe <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ea:	0532                	slli	a0,a0,0xc
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	fe0080e7          	jalr	-32(ra) # 800014cc <freewalk>
      pagetable[i] = 0;
    800014f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f8:	04a1                	addi	s1,s1,8
    800014fa:	03248163          	beq	s1,s2,8000151c <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014fe:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001500:	00f57793          	andi	a5,a0,15
    80001504:	ff3782e3          	beq	a5,s3,800014e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001508:	8905                	andi	a0,a0,1
    8000150a:	d57d                	beqz	a0,800014f8 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c6c50513          	addi	a0,a0,-916 # 80008178 <digits+0x138>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	02a080e7          	jalr	42(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    8000151c:	8552                	mv	a0,s4
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	4da080e7          	jalr	1242(ra) # 800009f8 <kfree>
}
    80001526:	70a2                	ld	ra,40(sp)
    80001528:	7402                	ld	s0,32(sp)
    8000152a:	64e2                	ld	s1,24(sp)
    8000152c:	6942                	ld	s2,16(sp)
    8000152e:	69a2                	ld	s3,8(sp)
    80001530:	6a02                	ld	s4,0(sp)
    80001532:	6145                	addi	sp,sp,48
    80001534:	8082                	ret

0000000080001536 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001536:	1101                	addi	sp,sp,-32
    80001538:	ec06                	sd	ra,24(sp)
    8000153a:	e822                	sd	s0,16(sp)
    8000153c:	e426                	sd	s1,8(sp)
    8000153e:	1000                	addi	s0,sp,32
    80001540:	84aa                	mv	s1,a0
  if(sz > 0)
    80001542:	e999                	bnez	a1,80001558 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001544:	8526                	mv	a0,s1
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f86080e7          	jalr	-122(ra) # 800014cc <freewalk>
}
    8000154e:	60e2                	ld	ra,24(sp)
    80001550:	6442                	ld	s0,16(sp)
    80001552:	64a2                	ld	s1,8(sp)
    80001554:	6105                	addi	sp,sp,32
    80001556:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001558:	6605                	lui	a2,0x1
    8000155a:	167d                	addi	a2,a2,-1
    8000155c:	962e                	add	a2,a2,a1
    8000155e:	4685                	li	a3,1
    80001560:	8231                	srli	a2,a2,0xc
    80001562:	4581                	li	a1,0
    80001564:	00000097          	auipc	ra,0x0
    80001568:	d12080e7          	jalr	-750(ra) # 80001276 <uvmunmap>
    8000156c:	bfe1                	j	80001544 <uvmfree+0xe>

000000008000156e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156e:	c679                	beqz	a2,8000163c <uvmcopy+0xce>
{
    80001570:	715d                	addi	sp,sp,-80
    80001572:	e486                	sd	ra,72(sp)
    80001574:	e0a2                	sd	s0,64(sp)
    80001576:	fc26                	sd	s1,56(sp)
    80001578:	f84a                	sd	s2,48(sp)
    8000157a:	f44e                	sd	s3,40(sp)
    8000157c:	f052                	sd	s4,32(sp)
    8000157e:	ec56                	sd	s5,24(sp)
    80001580:	e85a                	sd	s6,16(sp)
    80001582:	e45e                	sd	s7,8(sp)
    80001584:	0880                	addi	s0,sp,80
    80001586:	8b2a                	mv	s6,a0
    80001588:	8aae                	mv	s5,a1
    8000158a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158e:	4601                	li	a2,0
    80001590:	85ce                	mv	a1,s3
    80001592:	855a                	mv	a0,s6
    80001594:	00000097          	auipc	ra,0x0
    80001598:	a34080e7          	jalr	-1484(ra) # 80000fc8 <walk>
    8000159c:	c531                	beqz	a0,800015e8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159e:	6118                	ld	a4,0(a0)
    800015a0:	00177793          	andi	a5,a4,1
    800015a4:	cbb1                	beqz	a5,800015f8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a6:	00a75593          	srli	a1,a4,0xa
    800015aa:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ae:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	542080e7          	jalr	1346(ra) # 80000af4 <kalloc>
    800015ba:	892a                	mv	s2,a0
    800015bc:	c939                	beqz	a0,80001612 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015be:	6605                	lui	a2,0x1
    800015c0:	85de                	mv	a1,s7
    800015c2:	fffff097          	auipc	ra,0xfffff
    800015c6:	77e080e7          	jalr	1918(ra) # 80000d40 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ca:	8726                	mv	a4,s1
    800015cc:	86ca                	mv	a3,s2
    800015ce:	6605                	lui	a2,0x1
    800015d0:	85ce                	mv	a1,s3
    800015d2:	8556                	mv	a0,s5
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	adc080e7          	jalr	-1316(ra) # 800010b0 <mappages>
    800015dc:	e515                	bnez	a0,80001608 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015de:	6785                	lui	a5,0x1
    800015e0:	99be                	add	s3,s3,a5
    800015e2:	fb49e6e3          	bltu	s3,s4,8000158e <uvmcopy+0x20>
    800015e6:	a081                	j	80001626 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	ba050513          	addi	a0,a0,-1120 # 80008188 <digits+0x148>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f4e080e7          	jalr	-178(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015f8:	00007517          	auipc	a0,0x7
    800015fc:	bb050513          	addi	a0,a0,-1104 # 800081a8 <digits+0x168>
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	f3e080e7          	jalr	-194(ra) # 8000053e <panic>
      kfree(mem);
    80001608:	854a                	mv	a0,s2
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	3ee080e7          	jalr	1006(ra) # 800009f8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001612:	4685                	li	a3,1
    80001614:	00c9d613          	srli	a2,s3,0xc
    80001618:	4581                	li	a1,0
    8000161a:	8556                	mv	a0,s5
    8000161c:	00000097          	auipc	ra,0x0
    80001620:	c5a080e7          	jalr	-934(ra) # 80001276 <uvmunmap>
  return -1;
    80001624:	557d                	li	a0,-1
}
    80001626:	60a6                	ld	ra,72(sp)
    80001628:	6406                	ld	s0,64(sp)
    8000162a:	74e2                	ld	s1,56(sp)
    8000162c:	7942                	ld	s2,48(sp)
    8000162e:	79a2                	ld	s3,40(sp)
    80001630:	7a02                	ld	s4,32(sp)
    80001632:	6ae2                	ld	s5,24(sp)
    80001634:	6b42                	ld	s6,16(sp)
    80001636:	6ba2                	ld	s7,8(sp)
    80001638:	6161                	addi	sp,sp,80
    8000163a:	8082                	ret
  return 0;
    8000163c:	4501                	li	a0,0
}
    8000163e:	8082                	ret

0000000080001640 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001640:	1141                	addi	sp,sp,-16
    80001642:	e406                	sd	ra,8(sp)
    80001644:	e022                	sd	s0,0(sp)
    80001646:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001648:	4601                	li	a2,0
    8000164a:	00000097          	auipc	ra,0x0
    8000164e:	97e080e7          	jalr	-1666(ra) # 80000fc8 <walk>
  if(pte == 0)
    80001652:	c901                	beqz	a0,80001662 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001654:	611c                	ld	a5,0(a0)
    80001656:	9bbd                	andi	a5,a5,-17
    80001658:	e11c                	sd	a5,0(a0)
}
    8000165a:	60a2                	ld	ra,8(sp)
    8000165c:	6402                	ld	s0,0(sp)
    8000165e:	0141                	addi	sp,sp,16
    80001660:	8082                	ret
    panic("uvmclear");
    80001662:	00007517          	auipc	a0,0x7
    80001666:	b6650513          	addi	a0,a0,-1178 # 800081c8 <digits+0x188>
    8000166a:	fffff097          	auipc	ra,0xfffff
    8000166e:	ed4080e7          	jalr	-300(ra) # 8000053e <panic>

0000000080001672 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001672:	c6bd                	beqz	a3,800016e0 <copyout+0x6e>
{
    80001674:	715d                	addi	sp,sp,-80
    80001676:	e486                	sd	ra,72(sp)
    80001678:	e0a2                	sd	s0,64(sp)
    8000167a:	fc26                	sd	s1,56(sp)
    8000167c:	f84a                	sd	s2,48(sp)
    8000167e:	f44e                	sd	s3,40(sp)
    80001680:	f052                	sd	s4,32(sp)
    80001682:	ec56                	sd	s5,24(sp)
    80001684:	e85a                	sd	s6,16(sp)
    80001686:	e45e                	sd	s7,8(sp)
    80001688:	e062                	sd	s8,0(sp)
    8000168a:	0880                	addi	s0,sp,80
    8000168c:	8b2a                	mv	s6,a0
    8000168e:	8c2e                	mv	s8,a1
    80001690:	8a32                	mv	s4,a2
    80001692:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001694:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001696:	6a85                	lui	s5,0x1
    80001698:	a015                	j	800016bc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000169a:	9562                	add	a0,a0,s8
    8000169c:	0004861b          	sext.w	a2,s1
    800016a0:	85d2                	mv	a1,s4
    800016a2:	41250533          	sub	a0,a0,s2
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	69a080e7          	jalr	1690(ra) # 80000d40 <memmove>

    len -= n;
    800016ae:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b8:	02098263          	beqz	s3,800016dc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016bc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c0:	85ca                	mv	a1,s2
    800016c2:	855a                	mv	a0,s6
    800016c4:	00000097          	auipc	ra,0x0
    800016c8:	9aa080e7          	jalr	-1622(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800016cc:	cd01                	beqz	a0,800016e4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ce:	418904b3          	sub	s1,s2,s8
    800016d2:	94d6                	add	s1,s1,s5
    if(n > len)
    800016d4:	fc99f3e3          	bgeu	s3,s1,8000169a <copyout+0x28>
    800016d8:	84ce                	mv	s1,s3
    800016da:	b7c1                	j	8000169a <copyout+0x28>
  }
  return 0;
    800016dc:	4501                	li	a0,0
    800016de:	a021                	j	800016e6 <copyout+0x74>
    800016e0:	4501                	li	a0,0
}
    800016e2:	8082                	ret
      return -1;
    800016e4:	557d                	li	a0,-1
}
    800016e6:	60a6                	ld	ra,72(sp)
    800016e8:	6406                	ld	s0,64(sp)
    800016ea:	74e2                	ld	s1,56(sp)
    800016ec:	7942                	ld	s2,48(sp)
    800016ee:	79a2                	ld	s3,40(sp)
    800016f0:	7a02                	ld	s4,32(sp)
    800016f2:	6ae2                	ld	s5,24(sp)
    800016f4:	6b42                	ld	s6,16(sp)
    800016f6:	6ba2                	ld	s7,8(sp)
    800016f8:	6c02                	ld	s8,0(sp)
    800016fa:	6161                	addi	sp,sp,80
    800016fc:	8082                	ret

00000000800016fe <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fe:	c6bd                	beqz	a3,8000176c <copyin+0x6e>
{
    80001700:	715d                	addi	sp,sp,-80
    80001702:	e486                	sd	ra,72(sp)
    80001704:	e0a2                	sd	s0,64(sp)
    80001706:	fc26                	sd	s1,56(sp)
    80001708:	f84a                	sd	s2,48(sp)
    8000170a:	f44e                	sd	s3,40(sp)
    8000170c:	f052                	sd	s4,32(sp)
    8000170e:	ec56                	sd	s5,24(sp)
    80001710:	e85a                	sd	s6,16(sp)
    80001712:	e45e                	sd	s7,8(sp)
    80001714:	e062                	sd	s8,0(sp)
    80001716:	0880                	addi	s0,sp,80
    80001718:	8b2a                	mv	s6,a0
    8000171a:	8a2e                	mv	s4,a1
    8000171c:	8c32                	mv	s8,a2
    8000171e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001720:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001722:	6a85                	lui	s5,0x1
    80001724:	a015                	j	80001748 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001726:	9562                	add	a0,a0,s8
    80001728:	0004861b          	sext.w	a2,s1
    8000172c:	412505b3          	sub	a1,a0,s2
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	60e080e7          	jalr	1550(ra) # 80000d40 <memmove>

    len -= n;
    8000173a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001740:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001744:	02098263          	beqz	s3,80001768 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001748:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174c:	85ca                	mv	a1,s2
    8000174e:	855a                	mv	a0,s6
    80001750:	00000097          	auipc	ra,0x0
    80001754:	91e080e7          	jalr	-1762(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    80001758:	cd01                	beqz	a0,80001770 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000175a:	418904b3          	sub	s1,s2,s8
    8000175e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001760:	fc99f3e3          	bgeu	s3,s1,80001726 <copyin+0x28>
    80001764:	84ce                	mv	s1,s3
    80001766:	b7c1                	j	80001726 <copyin+0x28>
  }
  return 0;
    80001768:	4501                	li	a0,0
    8000176a:	a021                	j	80001772 <copyin+0x74>
    8000176c:	4501                	li	a0,0
}
    8000176e:	8082                	ret
      return -1;
    80001770:	557d                	li	a0,-1
}
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret

000000008000178a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178a:	c6c5                	beqz	a3,80001832 <copyinstr+0xa8>
{
    8000178c:	715d                	addi	sp,sp,-80
    8000178e:	e486                	sd	ra,72(sp)
    80001790:	e0a2                	sd	s0,64(sp)
    80001792:	fc26                	sd	s1,56(sp)
    80001794:	f84a                	sd	s2,48(sp)
    80001796:	f44e                	sd	s3,40(sp)
    80001798:	f052                	sd	s4,32(sp)
    8000179a:	ec56                	sd	s5,24(sp)
    8000179c:	e85a                	sd	s6,16(sp)
    8000179e:	e45e                	sd	s7,8(sp)
    800017a0:	0880                	addi	s0,sp,80
    800017a2:	8a2a                	mv	s4,a0
    800017a4:	8b2e                	mv	s6,a1
    800017a6:	8bb2                	mv	s7,a2
    800017a8:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017aa:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ac:	6985                	lui	s3,0x1
    800017ae:	a035                	j	800017da <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b0:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b6:	0017b793          	seqz	a5,a5
    800017ba:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6161                	addi	sp,sp,80
    800017d2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d8:	c8a9                	beqz	s1,8000182a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017da:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017de:	85ca                	mv	a1,s2
    800017e0:	8552                	mv	a0,s4
    800017e2:	00000097          	auipc	ra,0x0
    800017e6:	88c080e7          	jalr	-1908(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800017ea:	c131                	beqz	a0,8000182e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ec:	41790833          	sub	a6,s2,s7
    800017f0:	984e                	add	a6,a6,s3
    if(n > max)
    800017f2:	0104f363          	bgeu	s1,a6,800017f8 <copyinstr+0x6e>
    800017f6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f8:	955e                	add	a0,a0,s7
    800017fa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fe:	fc080be3          	beqz	a6,800017d4 <copyinstr+0x4a>
    80001802:	985a                	add	a6,a6,s6
    80001804:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001806:	41650633          	sub	a2,a0,s6
    8000180a:	14fd                	addi	s1,s1,-1
    8000180c:	9b26                	add	s6,s6,s1
    8000180e:	00f60733          	add	a4,a2,a5
    80001812:	00074703          	lbu	a4,0(a4)
    80001816:	df49                	beqz	a4,800017b0 <copyinstr+0x26>
        *dst = *p;
    80001818:	00e78023          	sb	a4,0(a5)
      --max;
    8000181c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001820:	0785                	addi	a5,a5,1
    while(n > 0){
    80001822:	ff0796e3          	bne	a5,a6,8000180e <copyinstr+0x84>
      dst++;
    80001826:	8b42                	mv	s6,a6
    80001828:	b775                	j	800017d4 <copyinstr+0x4a>
    8000182a:	4781                	li	a5,0
    8000182c:	b769                	j	800017b6 <copyinstr+0x2c>
      return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	b779                	j	800017be <copyinstr+0x34>
  int got_null = 0;
    80001832:	4781                	li	a5,0
  if(got_null){
    80001834:	0017b793          	seqz	a5,a5
    80001838:	40f00533          	neg	a0,a5
}
    8000183c:	8082                	ret

000000008000183e <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
    80001852:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	00010497          	auipc	s1,0x10
    80001858:	e7c48493          	addi	s1,s1,-388 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000185c:	8b26                	mv	s6,s1
    8000185e:	00006a97          	auipc	s5,0x6
    80001862:	7a2a8a93          	addi	s5,s5,1954 # 80008000 <etext>
    80001866:	04000937          	lui	s2,0x4000
    8000186a:	197d                	addi	s2,s2,-1
    8000186c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00016a17          	auipc	s4,0x16
    80001872:	862a0a13          	addi	s4,s4,-1950 # 800170d0 <tickslock>
    char *pa = kalloc();
    80001876:	fffff097          	auipc	ra,0xfffff
    8000187a:	27e080e7          	jalr	638(ra) # 80000af4 <kalloc>
    8000187e:	862a                	mv	a2,a0
    if(pa == 0)
    80001880:	c131                	beqz	a0,800018c4 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001882:	416485b3          	sub	a1,s1,s6
    80001886:	858d                	srai	a1,a1,0x3
    80001888:	000ab783          	ld	a5,0(s5)
    8000188c:	02f585b3          	mul	a1,a1,a5
    80001890:	2585                	addiw	a1,a1,1
    80001892:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001896:	4719                	li	a4,6
    80001898:	6685                	lui	a3,0x1
    8000189a:	40b905b3          	sub	a1,s2,a1
    8000189e:	854e                	mv	a0,s3
    800018a0:	00000097          	auipc	ra,0x0
    800018a4:	8b0080e7          	jalr	-1872(ra) # 80001150 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a8:	16848493          	addi	s1,s1,360
    800018ac:	fd4495e3          	bne	s1,s4,80001876 <proc_mapstacks+0x38>
  }
}
    800018b0:	70e2                	ld	ra,56(sp)
    800018b2:	7442                	ld	s0,48(sp)
    800018b4:	74a2                	ld	s1,40(sp)
    800018b6:	7902                	ld	s2,32(sp)
    800018b8:	69e2                	ld	s3,24(sp)
    800018ba:	6a42                	ld	s4,16(sp)
    800018bc:	6aa2                	ld	s5,8(sp)
    800018be:	6b02                	ld	s6,0(sp)
    800018c0:	6121                	addi	sp,sp,64
    800018c2:	8082                	ret
      panic("kalloc");
    800018c4:	00007517          	auipc	a0,0x7
    800018c8:	91450513          	addi	a0,a0,-1772 # 800081d8 <digits+0x198>
    800018cc:	fffff097          	auipc	ra,0xfffff
    800018d0:	c72080e7          	jalr	-910(ra) # 8000053e <panic>

00000000800018d4 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018d4:	7139                	addi	sp,sp,-64
    800018d6:	fc06                	sd	ra,56(sp)
    800018d8:	f822                	sd	s0,48(sp)
    800018da:	f426                	sd	s1,40(sp)
    800018dc:	f04a                	sd	s2,32(sp)
    800018de:	ec4e                	sd	s3,24(sp)
    800018e0:	e852                	sd	s4,16(sp)
    800018e2:	e456                	sd	s5,8(sp)
    800018e4:	e05a                	sd	s6,0(sp)
    800018e6:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e8:	00007597          	auipc	a1,0x7
    800018ec:	8f858593          	addi	a1,a1,-1800 # 800081e0 <digits+0x1a0>
    800018f0:	00010517          	auipc	a0,0x10
    800018f4:	9b050513          	addi	a0,a0,-1616 # 800112a0 <pid_lock>
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	25c080e7          	jalr	604(ra) # 80000b54 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001900:	00007597          	auipc	a1,0x7
    80001904:	8e858593          	addi	a1,a1,-1816 # 800081e8 <digits+0x1a8>
    80001908:	00010517          	auipc	a0,0x10
    8000190c:	9b050513          	addi	a0,a0,-1616 # 800112b8 <wait_lock>
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	244080e7          	jalr	580(ra) # 80000b54 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001918:	00010497          	auipc	s1,0x10
    8000191c:	db848493          	addi	s1,s1,-584 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001920:	00007b17          	auipc	s6,0x7
    80001924:	8d8b0b13          	addi	s6,s6,-1832 # 800081f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    80001928:	8aa6                	mv	s5,s1
    8000192a:	00006a17          	auipc	s4,0x6
    8000192e:	6d6a0a13          	addi	s4,s4,1750 # 80008000 <etext>
    80001932:	04000937          	lui	s2,0x4000
    80001936:	197d                	addi	s2,s2,-1
    80001938:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193a:	00015997          	auipc	s3,0x15
    8000193e:	79698993          	addi	s3,s3,1942 # 800170d0 <tickslock>
      initlock(&p->lock, "proc");
    80001942:	85da                	mv	a1,s6
    80001944:	8526                	mv	a0,s1
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	20e080e7          	jalr	526(ra) # 80000b54 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000194e:	415487b3          	sub	a5,s1,s5
    80001952:	878d                	srai	a5,a5,0x3
    80001954:	000a3703          	ld	a4,0(s4)
    80001958:	02e787b3          	mul	a5,a5,a4
    8000195c:	2785                	addiw	a5,a5,1
    8000195e:	00d7979b          	slliw	a5,a5,0xd
    80001962:	40f907b3          	sub	a5,s2,a5
    80001966:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001968:	16848493          	addi	s1,s1,360
    8000196c:	fd349be3          	bne	s1,s3,80001942 <procinit+0x6e>
  }
}
    80001970:	70e2                	ld	ra,56(sp)
    80001972:	7442                	ld	s0,48(sp)
    80001974:	74a2                	ld	s1,40(sp)
    80001976:	7902                	ld	s2,32(sp)
    80001978:	69e2                	ld	s3,24(sp)
    8000197a:	6a42                	ld	s4,16(sp)
    8000197c:	6aa2                	ld	s5,8(sp)
    8000197e:	6b02                	ld	s6,0(sp)
    80001980:	6121                	addi	sp,sp,64
    80001982:	8082                	ret

0000000080001984 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001984:	1141                	addi	sp,sp,-16
    80001986:	e422                	sd	s0,8(sp)
    80001988:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000198a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000198c:	2501                	sext.w	a0,a0
    8000198e:	6422                	ld	s0,8(sp)
    80001990:	0141                	addi	sp,sp,16
    80001992:	8082                	ret

0000000080001994 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001994:	1141                	addi	sp,sp,-16
    80001996:	e422                	sd	s0,8(sp)
    80001998:	0800                	addi	s0,sp,16
    8000199a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000199c:	2781                	sext.w	a5,a5
    8000199e:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a0:	00010517          	auipc	a0,0x10
    800019a4:	93050513          	addi	a0,a0,-1744 # 800112d0 <cpus>
    800019a8:	953e                	add	a0,a0,a5
    800019aa:	6422                	ld	s0,8(sp)
    800019ac:	0141                	addi	sp,sp,16
    800019ae:	8082                	ret

00000000800019b0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019b0:	1101                	addi	sp,sp,-32
    800019b2:	ec06                	sd	ra,24(sp)
    800019b4:	e822                	sd	s0,16(sp)
    800019b6:	e426                	sd	s1,8(sp)
    800019b8:	1000                	addi	s0,sp,32
  push_off();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	1de080e7          	jalr	478(ra) # 80000b98 <push_off>
    800019c2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c4:	2781                	sext.w	a5,a5
    800019c6:	079e                	slli	a5,a5,0x7
    800019c8:	00010717          	auipc	a4,0x10
    800019cc:	8d870713          	addi	a4,a4,-1832 # 800112a0 <pid_lock>
    800019d0:	97ba                	add	a5,a5,a4
    800019d2:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	264080e7          	jalr	612(ra) # 80000c38 <pop_off>
  return p;
}
    800019dc:	8526                	mv	a0,s1
    800019de:	60e2                	ld	ra,24(sp)
    800019e0:	6442                	ld	s0,16(sp)
    800019e2:	64a2                	ld	s1,8(sp)
    800019e4:	6105                	addi	sp,sp,32
    800019e6:	8082                	ret

00000000800019e8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e8:	1141                	addi	sp,sp,-16
    800019ea:	e406                	sd	ra,8(sp)
    800019ec:	e022                	sd	s0,0(sp)
    800019ee:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f0:	00000097          	auipc	ra,0x0
    800019f4:	fc0080e7          	jalr	-64(ra) # 800019b0 <myproc>
    800019f8:	fffff097          	auipc	ra,0xfffff
    800019fc:	2a0080e7          	jalr	672(ra) # 80000c98 <release>

  if (first) {
    80001a00:	00007797          	auipc	a5,0x7
    80001a04:	e307a783          	lw	a5,-464(a5) # 80008830 <first.1684>
    80001a08:	eb89                	bnez	a5,80001a1a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a0a:	00001097          	auipc	ra,0x1
    80001a0e:	d52080e7          	jalr	-686(ra) # 8000275c <usertrapret>
}
    80001a12:	60a2                	ld	ra,8(sp)
    80001a14:	6402                	ld	s0,0(sp)
    80001a16:	0141                	addi	sp,sp,16
    80001a18:	8082                	ret
    first = 0;
    80001a1a:	00007797          	auipc	a5,0x7
    80001a1e:	e007ab23          	sw	zero,-490(a5) # 80008830 <first.1684>
    fsinit(ROOTDEV);
    80001a22:	4505                	li	a0,1
    80001a24:	00002097          	auipc	ra,0x2
    80001a28:	b36080e7          	jalr	-1226(ra) # 8000355a <fsinit>
    80001a2c:	bff9                	j	80001a0a <forkret+0x22>

0000000080001a2e <allocpid>:
allocpid() {
    80001a2e:	1101                	addi	sp,sp,-32
    80001a30:	ec06                	sd	ra,24(sp)
    80001a32:	e822                	sd	s0,16(sp)
    80001a34:	e426                	sd	s1,8(sp)
    80001a36:	e04a                	sd	s2,0(sp)
    80001a38:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a3a:	00010917          	auipc	s2,0x10
    80001a3e:	86690913          	addi	s2,s2,-1946 # 800112a0 <pid_lock>
    80001a42:	854a                	mv	a0,s2
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	1a0080e7          	jalr	416(ra) # 80000be4 <acquire>
  pid = nextpid;
    80001a4c:	00007797          	auipc	a5,0x7
    80001a50:	de878793          	addi	a5,a5,-536 # 80008834 <nextpid>
    80001a54:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a56:	0014871b          	addiw	a4,s1,1
    80001a5a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a5c:	854a                	mv	a0,s2
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	23a080e7          	jalr	570(ra) # 80000c98 <release>
}
    80001a66:	8526                	mv	a0,s1
    80001a68:	60e2                	ld	ra,24(sp)
    80001a6a:	6442                	ld	s0,16(sp)
    80001a6c:	64a2                	ld	s1,8(sp)
    80001a6e:	6902                	ld	s2,0(sp)
    80001a70:	6105                	addi	sp,sp,32
    80001a72:	8082                	ret

0000000080001a74 <proc_pagetable>:
{
    80001a74:	1101                	addi	sp,sp,-32
    80001a76:	ec06                	sd	ra,24(sp)
    80001a78:	e822                	sd	s0,16(sp)
    80001a7a:	e426                	sd	s1,8(sp)
    80001a7c:	e04a                	sd	s2,0(sp)
    80001a7e:	1000                	addi	s0,sp,32
    80001a80:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a82:	00000097          	auipc	ra,0x0
    80001a86:	8b8080e7          	jalr	-1864(ra) # 8000133a <uvmcreate>
    80001a8a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a8c:	c121                	beqz	a0,80001acc <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8e:	4729                	li	a4,10
    80001a90:	00005697          	auipc	a3,0x5
    80001a94:	57068693          	addi	a3,a3,1392 # 80007000 <_trampoline>
    80001a98:	6605                	lui	a2,0x1
    80001a9a:	040005b7          	lui	a1,0x4000
    80001a9e:	15fd                	addi	a1,a1,-1
    80001aa0:	05b2                	slli	a1,a1,0xc
    80001aa2:	fffff097          	auipc	ra,0xfffff
    80001aa6:	60e080e7          	jalr	1550(ra) # 800010b0 <mappages>
    80001aaa:	02054863          	bltz	a0,80001ada <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aae:	4719                	li	a4,6
    80001ab0:	05893683          	ld	a3,88(s2)
    80001ab4:	6605                	lui	a2,0x1
    80001ab6:	020005b7          	lui	a1,0x2000
    80001aba:	15fd                	addi	a1,a1,-1
    80001abc:	05b6                	slli	a1,a1,0xd
    80001abe:	8526                	mv	a0,s1
    80001ac0:	fffff097          	auipc	ra,0xfffff
    80001ac4:	5f0080e7          	jalr	1520(ra) # 800010b0 <mappages>
    80001ac8:	02054163          	bltz	a0,80001aea <proc_pagetable+0x76>
}
    80001acc:	8526                	mv	a0,s1
    80001ace:	60e2                	ld	ra,24(sp)
    80001ad0:	6442                	ld	s0,16(sp)
    80001ad2:	64a2                	ld	s1,8(sp)
    80001ad4:	6902                	ld	s2,0(sp)
    80001ad6:	6105                	addi	sp,sp,32
    80001ad8:	8082                	ret
    uvmfree(pagetable, 0);
    80001ada:	4581                	li	a1,0
    80001adc:	8526                	mv	a0,s1
    80001ade:	00000097          	auipc	ra,0x0
    80001ae2:	a58080e7          	jalr	-1448(ra) # 80001536 <uvmfree>
    return 0;
    80001ae6:	4481                	li	s1,0
    80001ae8:	b7d5                	j	80001acc <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aea:	4681                	li	a3,0
    80001aec:	4605                	li	a2,1
    80001aee:	040005b7          	lui	a1,0x4000
    80001af2:	15fd                	addi	a1,a1,-1
    80001af4:	05b2                	slli	a1,a1,0xc
    80001af6:	8526                	mv	a0,s1
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	77e080e7          	jalr	1918(ra) # 80001276 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b00:	4581                	li	a1,0
    80001b02:	8526                	mv	a0,s1
    80001b04:	00000097          	auipc	ra,0x0
    80001b08:	a32080e7          	jalr	-1486(ra) # 80001536 <uvmfree>
    return 0;
    80001b0c:	4481                	li	s1,0
    80001b0e:	bf7d                	j	80001acc <proc_pagetable+0x58>

0000000080001b10 <proc_freepagetable>:
{
    80001b10:	1101                	addi	sp,sp,-32
    80001b12:	ec06                	sd	ra,24(sp)
    80001b14:	e822                	sd	s0,16(sp)
    80001b16:	e426                	sd	s1,8(sp)
    80001b18:	e04a                	sd	s2,0(sp)
    80001b1a:	1000                	addi	s0,sp,32
    80001b1c:	84aa                	mv	s1,a0
    80001b1e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b20:	4681                	li	a3,0
    80001b22:	4605                	li	a2,1
    80001b24:	040005b7          	lui	a1,0x4000
    80001b28:	15fd                	addi	a1,a1,-1
    80001b2a:	05b2                	slli	a1,a1,0xc
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	74a080e7          	jalr	1866(ra) # 80001276 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b34:	4681                	li	a3,0
    80001b36:	4605                	li	a2,1
    80001b38:	020005b7          	lui	a1,0x2000
    80001b3c:	15fd                	addi	a1,a1,-1
    80001b3e:	05b6                	slli	a1,a1,0xd
    80001b40:	8526                	mv	a0,s1
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	734080e7          	jalr	1844(ra) # 80001276 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b4a:	85ca                	mv	a1,s2
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	00000097          	auipc	ra,0x0
    80001b52:	9e8080e7          	jalr	-1560(ra) # 80001536 <uvmfree>
}
    80001b56:	60e2                	ld	ra,24(sp)
    80001b58:	6442                	ld	s0,16(sp)
    80001b5a:	64a2                	ld	s1,8(sp)
    80001b5c:	6902                	ld	s2,0(sp)
    80001b5e:	6105                	addi	sp,sp,32
    80001b60:	8082                	ret

0000000080001b62 <freeproc>:
{
    80001b62:	1101                	addi	sp,sp,-32
    80001b64:	ec06                	sd	ra,24(sp)
    80001b66:	e822                	sd	s0,16(sp)
    80001b68:	e426                	sd	s1,8(sp)
    80001b6a:	1000                	addi	s0,sp,32
    80001b6c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6e:	6d28                	ld	a0,88(a0)
    80001b70:	c509                	beqz	a0,80001b7a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	e86080e7          	jalr	-378(ra) # 800009f8 <kfree>
  p->trapframe = 0;
    80001b7a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7e:	68a8                	ld	a0,80(s1)
    80001b80:	c511                	beqz	a0,80001b8c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b82:	64ac                	ld	a1,72(s1)
    80001b84:	00000097          	auipc	ra,0x0
    80001b88:	f8c080e7          	jalr	-116(ra) # 80001b10 <proc_freepagetable>
  p->pagetable = 0;
    80001b8c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b90:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b94:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b98:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b9c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ba0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bac:	0004ac23          	sw	zero,24(s1)
}
    80001bb0:	60e2                	ld	ra,24(sp)
    80001bb2:	6442                	ld	s0,16(sp)
    80001bb4:	64a2                	ld	s1,8(sp)
    80001bb6:	6105                	addi	sp,sp,32
    80001bb8:	8082                	ret

0000000080001bba <allocproc>:
{
    80001bba:	1101                	addi	sp,sp,-32
    80001bbc:	ec06                	sd	ra,24(sp)
    80001bbe:	e822                	sd	s0,16(sp)
    80001bc0:	e426                	sd	s1,8(sp)
    80001bc2:	e04a                	sd	s2,0(sp)
    80001bc4:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc6:	00010497          	auipc	s1,0x10
    80001bca:	b0a48493          	addi	s1,s1,-1270 # 800116d0 <proc>
    80001bce:	00015917          	auipc	s2,0x15
    80001bd2:	50290913          	addi	s2,s2,1282 # 800170d0 <tickslock>
    acquire(&p->lock);
    80001bd6:	8526                	mv	a0,s1
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	00c080e7          	jalr	12(ra) # 80000be4 <acquire>
    if(p->state == UNUSED) {
    80001be0:	4c9c                	lw	a5,24(s1)
    80001be2:	cf81                	beqz	a5,80001bfa <allocproc+0x40>
      release(&p->lock);
    80001be4:	8526                	mv	a0,s1
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	0b2080e7          	jalr	178(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bee:	16848493          	addi	s1,s1,360
    80001bf2:	ff2492e3          	bne	s1,s2,80001bd6 <allocproc+0x1c>
  return 0;
    80001bf6:	4481                	li	s1,0
    80001bf8:	a889                	j	80001c4a <allocproc+0x90>
  p->pid = allocpid();
    80001bfa:	00000097          	auipc	ra,0x0
    80001bfe:	e34080e7          	jalr	-460(ra) # 80001a2e <allocpid>
    80001c02:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c04:	4785                	li	a5,1
    80001c06:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c08:	fffff097          	auipc	ra,0xfffff
    80001c0c:	eec080e7          	jalr	-276(ra) # 80000af4 <kalloc>
    80001c10:	892a                	mv	s2,a0
    80001c12:	eca8                	sd	a0,88(s1)
    80001c14:	c131                	beqz	a0,80001c58 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c16:	8526                	mv	a0,s1
    80001c18:	00000097          	auipc	ra,0x0
    80001c1c:	e5c080e7          	jalr	-420(ra) # 80001a74 <proc_pagetable>
    80001c20:	892a                	mv	s2,a0
    80001c22:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c24:	c531                	beqz	a0,80001c70 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c26:	07000613          	li	a2,112
    80001c2a:	4581                	li	a1,0
    80001c2c:	06048513          	addi	a0,s1,96
    80001c30:	fffff097          	auipc	ra,0xfffff
    80001c34:	0b0080e7          	jalr	176(ra) # 80000ce0 <memset>
  p->context.ra = (uint64)forkret;
    80001c38:	00000797          	auipc	a5,0x0
    80001c3c:	db078793          	addi	a5,a5,-592 # 800019e8 <forkret>
    80001c40:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c42:	60bc                	ld	a5,64(s1)
    80001c44:	6705                	lui	a4,0x1
    80001c46:	97ba                	add	a5,a5,a4
    80001c48:	f4bc                	sd	a5,104(s1)
}
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	60e2                	ld	ra,24(sp)
    80001c4e:	6442                	ld	s0,16(sp)
    80001c50:	64a2                	ld	s1,8(sp)
    80001c52:	6902                	ld	s2,0(sp)
    80001c54:	6105                	addi	sp,sp,32
    80001c56:	8082                	ret
    freeproc(p);
    80001c58:	8526                	mv	a0,s1
    80001c5a:	00000097          	auipc	ra,0x0
    80001c5e:	f08080e7          	jalr	-248(ra) # 80001b62 <freeproc>
    release(&p->lock);
    80001c62:	8526                	mv	a0,s1
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	034080e7          	jalr	52(ra) # 80000c98 <release>
    return 0;
    80001c6c:	84ca                	mv	s1,s2
    80001c6e:	bff1                	j	80001c4a <allocproc+0x90>
    freeproc(p);
    80001c70:	8526                	mv	a0,s1
    80001c72:	00000097          	auipc	ra,0x0
    80001c76:	ef0080e7          	jalr	-272(ra) # 80001b62 <freeproc>
    release(&p->lock);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	01c080e7          	jalr	28(ra) # 80000c98 <release>
    return 0;
    80001c84:	84ca                	mv	s1,s2
    80001c86:	b7d1                	j	80001c4a <allocproc+0x90>

0000000080001c88 <userinit>:
{
    80001c88:	1101                	addi	sp,sp,-32
    80001c8a:	ec06                	sd	ra,24(sp)
    80001c8c:	e822                	sd	s0,16(sp)
    80001c8e:	e426                	sd	s1,8(sp)
    80001c90:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c92:	00000097          	auipc	ra,0x0
    80001c96:	f28080e7          	jalr	-216(ra) # 80001bba <allocproc>
    80001c9a:	84aa                	mv	s1,a0
  initproc = p;
    80001c9c:	00007797          	auipc	a5,0x7
    80001ca0:	38a7b623          	sd	a0,908(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ca4:	03400613          	li	a2,52
    80001ca8:	00007597          	auipc	a1,0x7
    80001cac:	b9858593          	addi	a1,a1,-1128 # 80008840 <initcode>
    80001cb0:	6928                	ld	a0,80(a0)
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	6b6080e7          	jalr	1718(ra) # 80001368 <uvminit>
  p->sz = PGSIZE;
    80001cba:	6785                	lui	a5,0x1
    80001cbc:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cbe:	6cb8                	ld	a4,88(s1)
    80001cc0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc4:	6cb8                	ld	a4,88(s1)
    80001cc6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc8:	4641                	li	a2,16
    80001cca:	00006597          	auipc	a1,0x6
    80001cce:	53658593          	addi	a1,a1,1334 # 80008200 <digits+0x1c0>
    80001cd2:	15848513          	addi	a0,s1,344
    80001cd6:	fffff097          	auipc	ra,0xfffff
    80001cda:	15c080e7          	jalr	348(ra) # 80000e32 <safestrcpy>
  p->cwd = namei("/");
    80001cde:	00006517          	auipc	a0,0x6
    80001ce2:	53250513          	addi	a0,a0,1330 # 80008210 <digits+0x1d0>
    80001ce6:	00002097          	auipc	ra,0x2
    80001cea:	2a2080e7          	jalr	674(ra) # 80003f88 <namei>
    80001cee:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cf2:	478d                	li	a5,3
    80001cf4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	fa0080e7          	jalr	-96(ra) # 80000c98 <release>
}
    80001d00:	60e2                	ld	ra,24(sp)
    80001d02:	6442                	ld	s0,16(sp)
    80001d04:	64a2                	ld	s1,8(sp)
    80001d06:	6105                	addi	sp,sp,32
    80001d08:	8082                	ret

0000000080001d0a <growproc>:
{
    80001d0a:	1101                	addi	sp,sp,-32
    80001d0c:	ec06                	sd	ra,24(sp)
    80001d0e:	e822                	sd	s0,16(sp)
    80001d10:	e426                	sd	s1,8(sp)
    80001d12:	e04a                	sd	s2,0(sp)
    80001d14:	1000                	addi	s0,sp,32
    80001d16:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d18:	00000097          	auipc	ra,0x0
    80001d1c:	c98080e7          	jalr	-872(ra) # 800019b0 <myproc>
    80001d20:	892a                	mv	s2,a0
  sz = p->sz;
    80001d22:	652c                	ld	a1,72(a0)
    80001d24:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d28:	00904f63          	bgtz	s1,80001d46 <growproc+0x3c>
  } else if(n < 0){
    80001d2c:	0204cc63          	bltz	s1,80001d64 <growproc+0x5a>
  p->sz = sz;
    80001d30:	1602                	slli	a2,a2,0x20
    80001d32:	9201                	srli	a2,a2,0x20
    80001d34:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d38:	4501                	li	a0,0
}
    80001d3a:	60e2                	ld	ra,24(sp)
    80001d3c:	6442                	ld	s0,16(sp)
    80001d3e:	64a2                	ld	s1,8(sp)
    80001d40:	6902                	ld	s2,0(sp)
    80001d42:	6105                	addi	sp,sp,32
    80001d44:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d46:	9e25                	addw	a2,a2,s1
    80001d48:	1602                	slli	a2,a2,0x20
    80001d4a:	9201                	srli	a2,a2,0x20
    80001d4c:	1582                	slli	a1,a1,0x20
    80001d4e:	9181                	srli	a1,a1,0x20
    80001d50:	6928                	ld	a0,80(a0)
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	6d0080e7          	jalr	1744(ra) # 80001422 <uvmalloc>
    80001d5a:	0005061b          	sext.w	a2,a0
    80001d5e:	fa69                	bnez	a2,80001d30 <growproc+0x26>
      return -1;
    80001d60:	557d                	li	a0,-1
    80001d62:	bfe1                	j	80001d3a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d64:	9e25                	addw	a2,a2,s1
    80001d66:	1602                	slli	a2,a2,0x20
    80001d68:	9201                	srli	a2,a2,0x20
    80001d6a:	1582                	slli	a1,a1,0x20
    80001d6c:	9181                	srli	a1,a1,0x20
    80001d6e:	6928                	ld	a0,80(a0)
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	66a080e7          	jalr	1642(ra) # 800013da <uvmdealloc>
    80001d78:	0005061b          	sext.w	a2,a0
    80001d7c:	bf55                	j	80001d30 <growproc+0x26>

0000000080001d7e <fork>:
{
    80001d7e:	7179                	addi	sp,sp,-48
    80001d80:	f406                	sd	ra,40(sp)
    80001d82:	f022                	sd	s0,32(sp)
    80001d84:	ec26                	sd	s1,24(sp)
    80001d86:	e84a                	sd	s2,16(sp)
    80001d88:	e44e                	sd	s3,8(sp)
    80001d8a:	e052                	sd	s4,0(sp)
    80001d8c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d8e:	00000097          	auipc	ra,0x0
    80001d92:	c22080e7          	jalr	-990(ra) # 800019b0 <myproc>
    80001d96:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	e22080e7          	jalr	-478(ra) # 80001bba <allocproc>
    80001da0:	10050b63          	beqz	a0,80001eb6 <fork+0x138>
    80001da4:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001da6:	04893603          	ld	a2,72(s2)
    80001daa:	692c                	ld	a1,80(a0)
    80001dac:	05093503          	ld	a0,80(s2)
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	7be080e7          	jalr	1982(ra) # 8000156e <uvmcopy>
    80001db8:	04054663          	bltz	a0,80001e04 <fork+0x86>
  np->sz = p->sz;
    80001dbc:	04893783          	ld	a5,72(s2)
    80001dc0:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dc4:	05893683          	ld	a3,88(s2)
    80001dc8:	87b6                	mv	a5,a3
    80001dca:	0589b703          	ld	a4,88(s3)
    80001dce:	12068693          	addi	a3,a3,288
    80001dd2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dd6:	6788                	ld	a0,8(a5)
    80001dd8:	6b8c                	ld	a1,16(a5)
    80001dda:	6f90                	ld	a2,24(a5)
    80001ddc:	01073023          	sd	a6,0(a4)
    80001de0:	e708                	sd	a0,8(a4)
    80001de2:	eb0c                	sd	a1,16(a4)
    80001de4:	ef10                	sd	a2,24(a4)
    80001de6:	02078793          	addi	a5,a5,32
    80001dea:	02070713          	addi	a4,a4,32
    80001dee:	fed792e3          	bne	a5,a3,80001dd2 <fork+0x54>
  np->trapframe->a0 = 0;
    80001df2:	0589b783          	ld	a5,88(s3)
    80001df6:	0607b823          	sd	zero,112(a5)
    80001dfa:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001dfe:	15000a13          	li	s4,336
    80001e02:	a03d                	j	80001e30 <fork+0xb2>
    freeproc(np);
    80001e04:	854e                	mv	a0,s3
    80001e06:	00000097          	auipc	ra,0x0
    80001e0a:	d5c080e7          	jalr	-676(ra) # 80001b62 <freeproc>
    release(&np->lock);
    80001e0e:	854e                	mv	a0,s3
    80001e10:	fffff097          	auipc	ra,0xfffff
    80001e14:	e88080e7          	jalr	-376(ra) # 80000c98 <release>
    return -1;
    80001e18:	5a7d                	li	s4,-1
    80001e1a:	a069                	j	80001ea4 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e1c:	00003097          	auipc	ra,0x3
    80001e20:	802080e7          	jalr	-2046(ra) # 8000461e <filedup>
    80001e24:	009987b3          	add	a5,s3,s1
    80001e28:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e2a:	04a1                	addi	s1,s1,8
    80001e2c:	01448763          	beq	s1,s4,80001e3a <fork+0xbc>
    if(p->ofile[i])
    80001e30:	009907b3          	add	a5,s2,s1
    80001e34:	6388                	ld	a0,0(a5)
    80001e36:	f17d                	bnez	a0,80001e1c <fork+0x9e>
    80001e38:	bfcd                	j	80001e2a <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e3a:	15093503          	ld	a0,336(s2)
    80001e3e:	00002097          	auipc	ra,0x2
    80001e42:	956080e7          	jalr	-1706(ra) # 80003794 <idup>
    80001e46:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e4a:	4641                	li	a2,16
    80001e4c:	15890593          	addi	a1,s2,344
    80001e50:	15898513          	addi	a0,s3,344
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	fde080e7          	jalr	-34(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    80001e5c:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001e60:	854e                	mv	a0,s3
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	e36080e7          	jalr	-458(ra) # 80000c98 <release>
  acquire(&wait_lock);
    80001e6a:	0000f497          	auipc	s1,0xf
    80001e6e:	44e48493          	addi	s1,s1,1102 # 800112b8 <wait_lock>
    80001e72:	8526                	mv	a0,s1
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	d70080e7          	jalr	-656(ra) # 80000be4 <acquire>
  np->parent = p;
    80001e7c:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001e80:	8526                	mv	a0,s1
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	e16080e7          	jalr	-490(ra) # 80000c98 <release>
  acquire(&np->lock);
    80001e8a:	854e                	mv	a0,s3
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	d58080e7          	jalr	-680(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    80001e94:	478d                	li	a5,3
    80001e96:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e9a:	854e                	mv	a0,s3
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	dfc080e7          	jalr	-516(ra) # 80000c98 <release>
}
    80001ea4:	8552                	mv	a0,s4
    80001ea6:	70a2                	ld	ra,40(sp)
    80001ea8:	7402                	ld	s0,32(sp)
    80001eaa:	64e2                	ld	s1,24(sp)
    80001eac:	6942                	ld	s2,16(sp)
    80001eae:	69a2                	ld	s3,8(sp)
    80001eb0:	6a02                	ld	s4,0(sp)
    80001eb2:	6145                	addi	sp,sp,48
    80001eb4:	8082                	ret
    return -1;
    80001eb6:	5a7d                	li	s4,-1
    80001eb8:	b7f5                	j	80001ea4 <fork+0x126>

0000000080001eba <forkf>:
{
    80001eba:	7179                	addi	sp,sp,-48
    80001ebc:	f406                	sd	ra,40(sp)
    80001ebe:	f022                	sd	s0,32(sp)
    80001ec0:	ec26                	sd	s1,24(sp)
    80001ec2:	e84a                	sd	s2,16(sp)
    80001ec4:	e44e                	sd	s3,8(sp)
    80001ec6:	e052                	sd	s4,0(sp)
    80001ec8:	1800                	addi	s0,sp,48
    80001eca:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ecc:	00000097          	auipc	ra,0x0
    80001ed0:	ae4080e7          	jalr	-1308(ra) # 800019b0 <myproc>
    80001ed4:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001ed6:	00000097          	auipc	ra,0x0
    80001eda:	ce4080e7          	jalr	-796(ra) # 80001bba <allocproc>
    80001ede:	12050063          	beqz	a0,80001ffe <forkf+0x144>
    80001ee2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001ee4:	04893603          	ld	a2,72(s2)
    80001ee8:	692c                	ld	a1,80(a0)
    80001eea:	05093503          	ld	a0,80(s2)
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	680080e7          	jalr	1664(ra) # 8000156e <uvmcopy>
    80001ef6:	04054b63          	bltz	a0,80001f4c <forkf+0x92>
  np->sz = p->sz;
    80001efa:	04893783          	ld	a5,72(s2)
    80001efe:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f02:	05893683          	ld	a3,88(s2)
    80001f06:	87b6                	mv	a5,a3
    80001f08:	0589b703          	ld	a4,88(s3)
    80001f0c:	12068693          	addi	a3,a3,288
    80001f10:	0007b883          	ld	a7,0(a5)
    80001f14:	0087b803          	ld	a6,8(a5)
    80001f18:	6b8c                	ld	a1,16(a5)
    80001f1a:	6f90                	ld	a2,24(a5)
    80001f1c:	01173023          	sd	a7,0(a4)
    80001f20:	01073423          	sd	a6,8(a4)
    80001f24:	eb0c                	sd	a1,16(a4)
    80001f26:	ef10                	sd	a2,24(a4)
    80001f28:	02078793          	addi	a5,a5,32
    80001f2c:	02070713          	addi	a4,a4,32
    80001f30:	fed790e3          	bne	a5,a3,80001f10 <forkf+0x56>
  np->trapframe->a0 = 0;
    80001f34:	0589b783          	ld	a5,88(s3)
    80001f38:	0607b823          	sd	zero,112(a5)
  np->trapframe->epc = f;
    80001f3c:	0589b783          	ld	a5,88(s3)
    80001f40:	ef84                	sd	s1,24(a5)
    80001f42:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001f46:	15000a13          	li	s4,336
    80001f4a:	a03d                	j	80001f78 <forkf+0xbe>
    freeproc(np);
    80001f4c:	854e                	mv	a0,s3
    80001f4e:	00000097          	auipc	ra,0x0
    80001f52:	c14080e7          	jalr	-1004(ra) # 80001b62 <freeproc>
    release(&np->lock);
    80001f56:	854e                	mv	a0,s3
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	d40080e7          	jalr	-704(ra) # 80000c98 <release>
    return -1;
    80001f60:	5a7d                	li	s4,-1
    80001f62:	a069                	j	80001fec <forkf+0x132>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f64:	00002097          	auipc	ra,0x2
    80001f68:	6ba080e7          	jalr	1722(ra) # 8000461e <filedup>
    80001f6c:	009987b3          	add	a5,s3,s1
    80001f70:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001f72:	04a1                	addi	s1,s1,8
    80001f74:	01448763          	beq	s1,s4,80001f82 <forkf+0xc8>
    if(p->ofile[i])
    80001f78:	009907b3          	add	a5,s2,s1
    80001f7c:	6388                	ld	a0,0(a5)
    80001f7e:	f17d                	bnez	a0,80001f64 <forkf+0xaa>
    80001f80:	bfcd                	j	80001f72 <forkf+0xb8>
  np->cwd = idup(p->cwd);
    80001f82:	15093503          	ld	a0,336(s2)
    80001f86:	00002097          	auipc	ra,0x2
    80001f8a:	80e080e7          	jalr	-2034(ra) # 80003794 <idup>
    80001f8e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f92:	4641                	li	a2,16
    80001f94:	15890593          	addi	a1,s2,344
    80001f98:	15898513          	addi	a0,s3,344
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	e96080e7          	jalr	-362(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    80001fa4:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001fa8:	854e                	mv	a0,s3
    80001faa:	fffff097          	auipc	ra,0xfffff
    80001fae:	cee080e7          	jalr	-786(ra) # 80000c98 <release>
  acquire(&wait_lock);
    80001fb2:	0000f497          	auipc	s1,0xf
    80001fb6:	30648493          	addi	s1,s1,774 # 800112b8 <wait_lock>
    80001fba:	8526                	mv	a0,s1
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	c28080e7          	jalr	-984(ra) # 80000be4 <acquire>
  np->parent = p;
    80001fc4:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001fc8:	8526                	mv	a0,s1
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	cce080e7          	jalr	-818(ra) # 80000c98 <release>
  acquire(&np->lock);
    80001fd2:	854e                	mv	a0,s3
    80001fd4:	fffff097          	auipc	ra,0xfffff
    80001fd8:	c10080e7          	jalr	-1008(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    80001fdc:	478d                	li	a5,3
    80001fde:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001fe2:	854e                	mv	a0,s3
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	cb4080e7          	jalr	-844(ra) # 80000c98 <release>
}
    80001fec:	8552                	mv	a0,s4
    80001fee:	70a2                	ld	ra,40(sp)
    80001ff0:	7402                	ld	s0,32(sp)
    80001ff2:	64e2                	ld	s1,24(sp)
    80001ff4:	6942                	ld	s2,16(sp)
    80001ff6:	69a2                	ld	s3,8(sp)
    80001ff8:	6a02                	ld	s4,0(sp)
    80001ffa:	6145                	addi	sp,sp,48
    80001ffc:	8082                	ret
    return -1;
    80001ffe:	5a7d                	li	s4,-1
    80002000:	b7f5                	j	80001fec <forkf+0x132>

0000000080002002 <scheduler>:
{
    80002002:	7139                	addi	sp,sp,-64
    80002004:	fc06                	sd	ra,56(sp)
    80002006:	f822                	sd	s0,48(sp)
    80002008:	f426                	sd	s1,40(sp)
    8000200a:	f04a                	sd	s2,32(sp)
    8000200c:	ec4e                	sd	s3,24(sp)
    8000200e:	e852                	sd	s4,16(sp)
    80002010:	e456                	sd	s5,8(sp)
    80002012:	e05a                	sd	s6,0(sp)
    80002014:	0080                	addi	s0,sp,64
    80002016:	8792                	mv	a5,tp
  int id = r_tp();
    80002018:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000201a:	00779a93          	slli	s5,a5,0x7
    8000201e:	0000f717          	auipc	a4,0xf
    80002022:	28270713          	addi	a4,a4,642 # 800112a0 <pid_lock>
    80002026:	9756                	add	a4,a4,s5
    80002028:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000202c:	0000f717          	auipc	a4,0xf
    80002030:	2ac70713          	addi	a4,a4,684 # 800112d8 <cpus+0x8>
    80002034:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80002036:	498d                	li	s3,3
        p->state = RUNNING;
    80002038:	4b11                	li	s6,4
        c->proc = p;
    8000203a:	079e                	slli	a5,a5,0x7
    8000203c:	0000fa17          	auipc	s4,0xf
    80002040:	264a0a13          	addi	s4,s4,612 # 800112a0 <pid_lock>
    80002044:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002046:	00015917          	auipc	s2,0x15
    8000204a:	08a90913          	addi	s2,s2,138 # 800170d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000204e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002052:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002056:	10079073          	csrw	sstatus,a5
    8000205a:	0000f497          	auipc	s1,0xf
    8000205e:	67648493          	addi	s1,s1,1654 # 800116d0 <proc>
    80002062:	a03d                	j	80002090 <scheduler+0x8e>
        p->state = RUNNING;
    80002064:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002068:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000206c:	06048593          	addi	a1,s1,96
    80002070:	8556                	mv	a0,s5
    80002072:	00000097          	auipc	ra,0x0
    80002076:	640080e7          	jalr	1600(ra) # 800026b2 <swtch>
        c->proc = 0;
    8000207a:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    8000207e:	8526                	mv	a0,s1
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	c18080e7          	jalr	-1000(ra) # 80000c98 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002088:	16848493          	addi	s1,s1,360
    8000208c:	fd2481e3          	beq	s1,s2,8000204e <scheduler+0x4c>
      acquire(&p->lock);
    80002090:	8526                	mv	a0,s1
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	b52080e7          	jalr	-1198(ra) # 80000be4 <acquire>
      if(p->state == RUNNABLE) {
    8000209a:	4c9c                	lw	a5,24(s1)
    8000209c:	ff3791e3          	bne	a5,s3,8000207e <scheduler+0x7c>
    800020a0:	b7d1                	j	80002064 <scheduler+0x62>

00000000800020a2 <sched>:
{
    800020a2:	7179                	addi	sp,sp,-48
    800020a4:	f406                	sd	ra,40(sp)
    800020a6:	f022                	sd	s0,32(sp)
    800020a8:	ec26                	sd	s1,24(sp)
    800020aa:	e84a                	sd	s2,16(sp)
    800020ac:	e44e                	sd	s3,8(sp)
    800020ae:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020b0:	00000097          	auipc	ra,0x0
    800020b4:	900080e7          	jalr	-1792(ra) # 800019b0 <myproc>
    800020b8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020ba:	fffff097          	auipc	ra,0xfffff
    800020be:	ab0080e7          	jalr	-1360(ra) # 80000b6a <holding>
    800020c2:	c93d                	beqz	a0,80002138 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020c4:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020c6:	2781                	sext.w	a5,a5
    800020c8:	079e                	slli	a5,a5,0x7
    800020ca:	0000f717          	auipc	a4,0xf
    800020ce:	1d670713          	addi	a4,a4,470 # 800112a0 <pid_lock>
    800020d2:	97ba                	add	a5,a5,a4
    800020d4:	0a87a703          	lw	a4,168(a5)
    800020d8:	4785                	li	a5,1
    800020da:	06f71763          	bne	a4,a5,80002148 <sched+0xa6>
  if(p->state == RUNNING)
    800020de:	4c98                	lw	a4,24(s1)
    800020e0:	4791                	li	a5,4
    800020e2:	06f70b63          	beq	a4,a5,80002158 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020e6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020ea:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020ec:	efb5                	bnez	a5,80002168 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020ee:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020f0:	0000f917          	auipc	s2,0xf
    800020f4:	1b090913          	addi	s2,s2,432 # 800112a0 <pid_lock>
    800020f8:	2781                	sext.w	a5,a5
    800020fa:	079e                	slli	a5,a5,0x7
    800020fc:	97ca                	add	a5,a5,s2
    800020fe:	0ac7a983          	lw	s3,172(a5)
    80002102:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002104:	2781                	sext.w	a5,a5
    80002106:	079e                	slli	a5,a5,0x7
    80002108:	0000f597          	auipc	a1,0xf
    8000210c:	1d058593          	addi	a1,a1,464 # 800112d8 <cpus+0x8>
    80002110:	95be                	add	a1,a1,a5
    80002112:	06048513          	addi	a0,s1,96
    80002116:	00000097          	auipc	ra,0x0
    8000211a:	59c080e7          	jalr	1436(ra) # 800026b2 <swtch>
    8000211e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002120:	2781                	sext.w	a5,a5
    80002122:	079e                	slli	a5,a5,0x7
    80002124:	97ca                	add	a5,a5,s2
    80002126:	0b37a623          	sw	s3,172(a5)
}
    8000212a:	70a2                	ld	ra,40(sp)
    8000212c:	7402                	ld	s0,32(sp)
    8000212e:	64e2                	ld	s1,24(sp)
    80002130:	6942                	ld	s2,16(sp)
    80002132:	69a2                	ld	s3,8(sp)
    80002134:	6145                	addi	sp,sp,48
    80002136:	8082                	ret
    panic("sched p->lock");
    80002138:	00006517          	auipc	a0,0x6
    8000213c:	0e050513          	addi	a0,a0,224 # 80008218 <digits+0x1d8>
    80002140:	ffffe097          	auipc	ra,0xffffe
    80002144:	3fe080e7          	jalr	1022(ra) # 8000053e <panic>
    panic("sched locks");
    80002148:	00006517          	auipc	a0,0x6
    8000214c:	0e050513          	addi	a0,a0,224 # 80008228 <digits+0x1e8>
    80002150:	ffffe097          	auipc	ra,0xffffe
    80002154:	3ee080e7          	jalr	1006(ra) # 8000053e <panic>
    panic("sched running");
    80002158:	00006517          	auipc	a0,0x6
    8000215c:	0e050513          	addi	a0,a0,224 # 80008238 <digits+0x1f8>
    80002160:	ffffe097          	auipc	ra,0xffffe
    80002164:	3de080e7          	jalr	990(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002168:	00006517          	auipc	a0,0x6
    8000216c:	0e050513          	addi	a0,a0,224 # 80008248 <digits+0x208>
    80002170:	ffffe097          	auipc	ra,0xffffe
    80002174:	3ce080e7          	jalr	974(ra) # 8000053e <panic>

0000000080002178 <yield>:
{
    80002178:	1101                	addi	sp,sp,-32
    8000217a:	ec06                	sd	ra,24(sp)
    8000217c:	e822                	sd	s0,16(sp)
    8000217e:	e426                	sd	s1,8(sp)
    80002180:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002182:	00000097          	auipc	ra,0x0
    80002186:	82e080e7          	jalr	-2002(ra) # 800019b0 <myproc>
    8000218a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	a58080e7          	jalr	-1448(ra) # 80000be4 <acquire>
  p->state = RUNNABLE;
    80002194:	478d                	li	a5,3
    80002196:	cc9c                	sw	a5,24(s1)
  sched();
    80002198:	00000097          	auipc	ra,0x0
    8000219c:	f0a080e7          	jalr	-246(ra) # 800020a2 <sched>
  release(&p->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	af6080e7          	jalr	-1290(ra) # 80000c98 <release>
}
    800021aa:	60e2                	ld	ra,24(sp)
    800021ac:	6442                	ld	s0,16(sp)
    800021ae:	64a2                	ld	s1,8(sp)
    800021b0:	6105                	addi	sp,sp,32
    800021b2:	8082                	ret

00000000800021b4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800021b4:	7179                	addi	sp,sp,-48
    800021b6:	f406                	sd	ra,40(sp)
    800021b8:	f022                	sd	s0,32(sp)
    800021ba:	ec26                	sd	s1,24(sp)
    800021bc:	e84a                	sd	s2,16(sp)
    800021be:	e44e                	sd	s3,8(sp)
    800021c0:	1800                	addi	s0,sp,48
    800021c2:	89aa                	mv	s3,a0
    800021c4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	7ea080e7          	jalr	2026(ra) # 800019b0 <myproc>
    800021ce:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	a14080e7          	jalr	-1516(ra) # 80000be4 <acquire>
  release(lk);
    800021d8:	854a                	mv	a0,s2
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	abe080e7          	jalr	-1346(ra) # 80000c98 <release>

  // Go to sleep.
  p->chan = chan;
    800021e2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021e6:	4789                	li	a5,2
    800021e8:	cc9c                	sw	a5,24(s1)

  sched();
    800021ea:	00000097          	auipc	ra,0x0
    800021ee:	eb8080e7          	jalr	-328(ra) # 800020a2 <sched>

  // Tidy up.
  p->chan = 0;
    800021f2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021f6:	8526                	mv	a0,s1
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	aa0080e7          	jalr	-1376(ra) # 80000c98 <release>
  acquire(lk);
    80002200:	854a                	mv	a0,s2
    80002202:	fffff097          	auipc	ra,0xfffff
    80002206:	9e2080e7          	jalr	-1566(ra) # 80000be4 <acquire>
}
    8000220a:	70a2                	ld	ra,40(sp)
    8000220c:	7402                	ld	s0,32(sp)
    8000220e:	64e2                	ld	s1,24(sp)
    80002210:	6942                	ld	s2,16(sp)
    80002212:	69a2                	ld	s3,8(sp)
    80002214:	6145                	addi	sp,sp,48
    80002216:	8082                	ret

0000000080002218 <wait>:
{
    80002218:	715d                	addi	sp,sp,-80
    8000221a:	e486                	sd	ra,72(sp)
    8000221c:	e0a2                	sd	s0,64(sp)
    8000221e:	fc26                	sd	s1,56(sp)
    80002220:	f84a                	sd	s2,48(sp)
    80002222:	f44e                	sd	s3,40(sp)
    80002224:	f052                	sd	s4,32(sp)
    80002226:	ec56                	sd	s5,24(sp)
    80002228:	e85a                	sd	s6,16(sp)
    8000222a:	e45e                	sd	s7,8(sp)
    8000222c:	e062                	sd	s8,0(sp)
    8000222e:	0880                	addi	s0,sp,80
    80002230:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	77e080e7          	jalr	1918(ra) # 800019b0 <myproc>
    8000223a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000223c:	0000f517          	auipc	a0,0xf
    80002240:	07c50513          	addi	a0,a0,124 # 800112b8 <wait_lock>
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	9a0080e7          	jalr	-1632(ra) # 80000be4 <acquire>
    havekids = 0;
    8000224c:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000224e:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002250:	00015997          	auipc	s3,0x15
    80002254:	e8098993          	addi	s3,s3,-384 # 800170d0 <tickslock>
        havekids = 1;
    80002258:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000225a:	0000fc17          	auipc	s8,0xf
    8000225e:	05ec0c13          	addi	s8,s8,94 # 800112b8 <wait_lock>
    havekids = 0;
    80002262:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002264:	0000f497          	auipc	s1,0xf
    80002268:	46c48493          	addi	s1,s1,1132 # 800116d0 <proc>
    8000226c:	a0bd                	j	800022da <wait+0xc2>
          pid = np->pid;
    8000226e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002272:	000b0e63          	beqz	s6,8000228e <wait+0x76>
    80002276:	4691                	li	a3,4
    80002278:	02c48613          	addi	a2,s1,44
    8000227c:	85da                	mv	a1,s6
    8000227e:	05093503          	ld	a0,80(s2)
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	3f0080e7          	jalr	1008(ra) # 80001672 <copyout>
    8000228a:	02054563          	bltz	a0,800022b4 <wait+0x9c>
          freeproc(np);
    8000228e:	8526                	mv	a0,s1
    80002290:	00000097          	auipc	ra,0x0
    80002294:	8d2080e7          	jalr	-1838(ra) # 80001b62 <freeproc>
          release(&np->lock);
    80002298:	8526                	mv	a0,s1
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	9fe080e7          	jalr	-1538(ra) # 80000c98 <release>
          release(&wait_lock);
    800022a2:	0000f517          	auipc	a0,0xf
    800022a6:	01650513          	addi	a0,a0,22 # 800112b8 <wait_lock>
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	9ee080e7          	jalr	-1554(ra) # 80000c98 <release>
          return pid;
    800022b2:	a09d                	j	80002318 <wait+0x100>
            release(&np->lock);
    800022b4:	8526                	mv	a0,s1
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	9e2080e7          	jalr	-1566(ra) # 80000c98 <release>
            release(&wait_lock);
    800022be:	0000f517          	auipc	a0,0xf
    800022c2:	ffa50513          	addi	a0,a0,-6 # 800112b8 <wait_lock>
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	9d2080e7          	jalr	-1582(ra) # 80000c98 <release>
            return -1;
    800022ce:	59fd                	li	s3,-1
    800022d0:	a0a1                	j	80002318 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800022d2:	16848493          	addi	s1,s1,360
    800022d6:	03348463          	beq	s1,s3,800022fe <wait+0xe6>
      if(np->parent == p){
    800022da:	7c9c                	ld	a5,56(s1)
    800022dc:	ff279be3          	bne	a5,s2,800022d2 <wait+0xba>
        acquire(&np->lock);
    800022e0:	8526                	mv	a0,s1
    800022e2:	fffff097          	auipc	ra,0xfffff
    800022e6:	902080e7          	jalr	-1790(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    800022ea:	4c9c                	lw	a5,24(s1)
    800022ec:	f94781e3          	beq	a5,s4,8000226e <wait+0x56>
        release(&np->lock);
    800022f0:	8526                	mv	a0,s1
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	9a6080e7          	jalr	-1626(ra) # 80000c98 <release>
        havekids = 1;
    800022fa:	8756                	mv	a4,s5
    800022fc:	bfd9                	j	800022d2 <wait+0xba>
    if(!havekids || p->killed){
    800022fe:	c701                	beqz	a4,80002306 <wait+0xee>
    80002300:	02892783          	lw	a5,40(s2)
    80002304:	c79d                	beqz	a5,80002332 <wait+0x11a>
      release(&wait_lock);
    80002306:	0000f517          	auipc	a0,0xf
    8000230a:	fb250513          	addi	a0,a0,-78 # 800112b8 <wait_lock>
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	98a080e7          	jalr	-1654(ra) # 80000c98 <release>
      return -1;
    80002316:	59fd                	li	s3,-1
}
    80002318:	854e                	mv	a0,s3
    8000231a:	60a6                	ld	ra,72(sp)
    8000231c:	6406                	ld	s0,64(sp)
    8000231e:	74e2                	ld	s1,56(sp)
    80002320:	7942                	ld	s2,48(sp)
    80002322:	79a2                	ld	s3,40(sp)
    80002324:	7a02                	ld	s4,32(sp)
    80002326:	6ae2                	ld	s5,24(sp)
    80002328:	6b42                	ld	s6,16(sp)
    8000232a:	6ba2                	ld	s7,8(sp)
    8000232c:	6c02                	ld	s8,0(sp)
    8000232e:	6161                	addi	sp,sp,80
    80002330:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002332:	85e2                	mv	a1,s8
    80002334:	854a                	mv	a0,s2
    80002336:	00000097          	auipc	ra,0x0
    8000233a:	e7e080e7          	jalr	-386(ra) # 800021b4 <sleep>
    havekids = 0;
    8000233e:	b715                	j	80002262 <wait+0x4a>

0000000080002340 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002340:	7139                	addi	sp,sp,-64
    80002342:	fc06                	sd	ra,56(sp)
    80002344:	f822                	sd	s0,48(sp)
    80002346:	f426                	sd	s1,40(sp)
    80002348:	f04a                	sd	s2,32(sp)
    8000234a:	ec4e                	sd	s3,24(sp)
    8000234c:	e852                	sd	s4,16(sp)
    8000234e:	e456                	sd	s5,8(sp)
    80002350:	0080                	addi	s0,sp,64
    80002352:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002354:	0000f497          	auipc	s1,0xf
    80002358:	37c48493          	addi	s1,s1,892 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000235c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000235e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002360:	00015917          	auipc	s2,0x15
    80002364:	d7090913          	addi	s2,s2,-656 # 800170d0 <tickslock>
    80002368:	a821                	j	80002380 <wakeup+0x40>
        p->state = RUNNABLE;
    8000236a:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    8000236e:	8526                	mv	a0,s1
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	928080e7          	jalr	-1752(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002378:	16848493          	addi	s1,s1,360
    8000237c:	03248463          	beq	s1,s2,800023a4 <wakeup+0x64>
    if(p != myproc()){
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	630080e7          	jalr	1584(ra) # 800019b0 <myproc>
    80002388:	fea488e3          	beq	s1,a0,80002378 <wakeup+0x38>
      acquire(&p->lock);
    8000238c:	8526                	mv	a0,s1
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	856080e7          	jalr	-1962(ra) # 80000be4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002396:	4c9c                	lw	a5,24(s1)
    80002398:	fd379be3          	bne	a5,s3,8000236e <wakeup+0x2e>
    8000239c:	709c                	ld	a5,32(s1)
    8000239e:	fd4798e3          	bne	a5,s4,8000236e <wakeup+0x2e>
    800023a2:	b7e1                	j	8000236a <wakeup+0x2a>
    }
  }
}
    800023a4:	70e2                	ld	ra,56(sp)
    800023a6:	7442                	ld	s0,48(sp)
    800023a8:	74a2                	ld	s1,40(sp)
    800023aa:	7902                	ld	s2,32(sp)
    800023ac:	69e2                	ld	s3,24(sp)
    800023ae:	6a42                	ld	s4,16(sp)
    800023b0:	6aa2                	ld	s5,8(sp)
    800023b2:	6121                	addi	sp,sp,64
    800023b4:	8082                	ret

00000000800023b6 <reparent>:
{
    800023b6:	7179                	addi	sp,sp,-48
    800023b8:	f406                	sd	ra,40(sp)
    800023ba:	f022                	sd	s0,32(sp)
    800023bc:	ec26                	sd	s1,24(sp)
    800023be:	e84a                	sd	s2,16(sp)
    800023c0:	e44e                	sd	s3,8(sp)
    800023c2:	e052                	sd	s4,0(sp)
    800023c4:	1800                	addi	s0,sp,48
    800023c6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023c8:	0000f497          	auipc	s1,0xf
    800023cc:	30848493          	addi	s1,s1,776 # 800116d0 <proc>
      pp->parent = initproc;
    800023d0:	00007a17          	auipc	s4,0x7
    800023d4:	c58a0a13          	addi	s4,s4,-936 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023d8:	00015997          	auipc	s3,0x15
    800023dc:	cf898993          	addi	s3,s3,-776 # 800170d0 <tickslock>
    800023e0:	a029                	j	800023ea <reparent+0x34>
    800023e2:	16848493          	addi	s1,s1,360
    800023e6:	01348d63          	beq	s1,s3,80002400 <reparent+0x4a>
    if(pp->parent == p){
    800023ea:	7c9c                	ld	a5,56(s1)
    800023ec:	ff279be3          	bne	a5,s2,800023e2 <reparent+0x2c>
      pp->parent = initproc;
    800023f0:	000a3503          	ld	a0,0(s4)
    800023f4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023f6:	00000097          	auipc	ra,0x0
    800023fa:	f4a080e7          	jalr	-182(ra) # 80002340 <wakeup>
    800023fe:	b7d5                	j	800023e2 <reparent+0x2c>
}
    80002400:	70a2                	ld	ra,40(sp)
    80002402:	7402                	ld	s0,32(sp)
    80002404:	64e2                	ld	s1,24(sp)
    80002406:	6942                	ld	s2,16(sp)
    80002408:	69a2                	ld	s3,8(sp)
    8000240a:	6a02                	ld	s4,0(sp)
    8000240c:	6145                	addi	sp,sp,48
    8000240e:	8082                	ret

0000000080002410 <exit>:
{
    80002410:	7179                	addi	sp,sp,-48
    80002412:	f406                	sd	ra,40(sp)
    80002414:	f022                	sd	s0,32(sp)
    80002416:	ec26                	sd	s1,24(sp)
    80002418:	e84a                	sd	s2,16(sp)
    8000241a:	e44e                	sd	s3,8(sp)
    8000241c:	e052                	sd	s4,0(sp)
    8000241e:	1800                	addi	s0,sp,48
    80002420:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002422:	fffff097          	auipc	ra,0xfffff
    80002426:	58e080e7          	jalr	1422(ra) # 800019b0 <myproc>
    8000242a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000242c:	00007797          	auipc	a5,0x7
    80002430:	bfc7b783          	ld	a5,-1028(a5) # 80009028 <initproc>
    80002434:	0d050493          	addi	s1,a0,208
    80002438:	15050913          	addi	s2,a0,336
    8000243c:	02a79363          	bne	a5,a0,80002462 <exit+0x52>
    panic("init exiting");
    80002440:	00006517          	auipc	a0,0x6
    80002444:	e2050513          	addi	a0,a0,-480 # 80008260 <digits+0x220>
    80002448:	ffffe097          	auipc	ra,0xffffe
    8000244c:	0f6080e7          	jalr	246(ra) # 8000053e <panic>
      fileclose(f);
    80002450:	00002097          	auipc	ra,0x2
    80002454:	220080e7          	jalr	544(ra) # 80004670 <fileclose>
      p->ofile[fd] = 0;
    80002458:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000245c:	04a1                	addi	s1,s1,8
    8000245e:	01248563          	beq	s1,s2,80002468 <exit+0x58>
    if(p->ofile[fd]){
    80002462:	6088                	ld	a0,0(s1)
    80002464:	f575                	bnez	a0,80002450 <exit+0x40>
    80002466:	bfdd                	j	8000245c <exit+0x4c>
  begin_op();
    80002468:	00002097          	auipc	ra,0x2
    8000246c:	d3c080e7          	jalr	-708(ra) # 800041a4 <begin_op>
  iput(p->cwd);
    80002470:	1509b503          	ld	a0,336(s3)
    80002474:	00001097          	auipc	ra,0x1
    80002478:	518080e7          	jalr	1304(ra) # 8000398c <iput>
  end_op();
    8000247c:	00002097          	auipc	ra,0x2
    80002480:	da8080e7          	jalr	-600(ra) # 80004224 <end_op>
  p->cwd = 0;
    80002484:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002488:	0000f497          	auipc	s1,0xf
    8000248c:	e3048493          	addi	s1,s1,-464 # 800112b8 <wait_lock>
    80002490:	8526                	mv	a0,s1
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	752080e7          	jalr	1874(ra) # 80000be4 <acquire>
  reparent(p);
    8000249a:	854e                	mv	a0,s3
    8000249c:	00000097          	auipc	ra,0x0
    800024a0:	f1a080e7          	jalr	-230(ra) # 800023b6 <reparent>
  wakeup(p->parent);
    800024a4:	0389b503          	ld	a0,56(s3)
    800024a8:	00000097          	auipc	ra,0x0
    800024ac:	e98080e7          	jalr	-360(ra) # 80002340 <wakeup>
  acquire(&p->lock);
    800024b0:	854e                	mv	a0,s3
    800024b2:	ffffe097          	auipc	ra,0xffffe
    800024b6:	732080e7          	jalr	1842(ra) # 80000be4 <acquire>
  p->xstate = status;
    800024ba:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800024be:	4795                	li	a5,5
    800024c0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	ffffe097          	auipc	ra,0xffffe
    800024ca:	7d2080e7          	jalr	2002(ra) # 80000c98 <release>
  sched();
    800024ce:	00000097          	auipc	ra,0x0
    800024d2:	bd4080e7          	jalr	-1068(ra) # 800020a2 <sched>
  panic("zombie exit");
    800024d6:	00006517          	auipc	a0,0x6
    800024da:	d9a50513          	addi	a0,a0,-614 # 80008270 <digits+0x230>
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	060080e7          	jalr	96(ra) # 8000053e <panic>

00000000800024e6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024e6:	7179                	addi	sp,sp,-48
    800024e8:	f406                	sd	ra,40(sp)
    800024ea:	f022                	sd	s0,32(sp)
    800024ec:	ec26                	sd	s1,24(sp)
    800024ee:	e84a                	sd	s2,16(sp)
    800024f0:	e44e                	sd	s3,8(sp)
    800024f2:	1800                	addi	s0,sp,48
    800024f4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024f6:	0000f497          	auipc	s1,0xf
    800024fa:	1da48493          	addi	s1,s1,474 # 800116d0 <proc>
    800024fe:	00015997          	auipc	s3,0x15
    80002502:	bd298993          	addi	s3,s3,-1070 # 800170d0 <tickslock>
    acquire(&p->lock);
    80002506:	8526                	mv	a0,s1
    80002508:	ffffe097          	auipc	ra,0xffffe
    8000250c:	6dc080e7          	jalr	1756(ra) # 80000be4 <acquire>
    if(p->pid == pid){
    80002510:	589c                	lw	a5,48(s1)
    80002512:	01278d63          	beq	a5,s2,8000252c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002516:	8526                	mv	a0,s1
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	780080e7          	jalr	1920(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002520:	16848493          	addi	s1,s1,360
    80002524:	ff3491e3          	bne	s1,s3,80002506 <kill+0x20>
  }
  return -1;
    80002528:	557d                	li	a0,-1
    8000252a:	a829                	j	80002544 <kill+0x5e>
      p->killed = 1;
    8000252c:	4785                	li	a5,1
    8000252e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002530:	4c98                	lw	a4,24(s1)
    80002532:	4789                	li	a5,2
    80002534:	00f70f63          	beq	a4,a5,80002552 <kill+0x6c>
      release(&p->lock);
    80002538:	8526                	mv	a0,s1
    8000253a:	ffffe097          	auipc	ra,0xffffe
    8000253e:	75e080e7          	jalr	1886(ra) # 80000c98 <release>
      return 0;
    80002542:	4501                	li	a0,0
}
    80002544:	70a2                	ld	ra,40(sp)
    80002546:	7402                	ld	s0,32(sp)
    80002548:	64e2                	ld	s1,24(sp)
    8000254a:	6942                	ld	s2,16(sp)
    8000254c:	69a2                	ld	s3,8(sp)
    8000254e:	6145                	addi	sp,sp,48
    80002550:	8082                	ret
        p->state = RUNNABLE;
    80002552:	478d                	li	a5,3
    80002554:	cc9c                	sw	a5,24(s1)
    80002556:	b7cd                	j	80002538 <kill+0x52>

0000000080002558 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002558:	7179                	addi	sp,sp,-48
    8000255a:	f406                	sd	ra,40(sp)
    8000255c:	f022                	sd	s0,32(sp)
    8000255e:	ec26                	sd	s1,24(sp)
    80002560:	e84a                	sd	s2,16(sp)
    80002562:	e44e                	sd	s3,8(sp)
    80002564:	e052                	sd	s4,0(sp)
    80002566:	1800                	addi	s0,sp,48
    80002568:	84aa                	mv	s1,a0
    8000256a:	892e                	mv	s2,a1
    8000256c:	89b2                	mv	s3,a2
    8000256e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002570:	fffff097          	auipc	ra,0xfffff
    80002574:	440080e7          	jalr	1088(ra) # 800019b0 <myproc>
  if(user_dst){
    80002578:	c08d                	beqz	s1,8000259a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000257a:	86d2                	mv	a3,s4
    8000257c:	864e                	mv	a2,s3
    8000257e:	85ca                	mv	a1,s2
    80002580:	6928                	ld	a0,80(a0)
    80002582:	fffff097          	auipc	ra,0xfffff
    80002586:	0f0080e7          	jalr	240(ra) # 80001672 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000258a:	70a2                	ld	ra,40(sp)
    8000258c:	7402                	ld	s0,32(sp)
    8000258e:	64e2                	ld	s1,24(sp)
    80002590:	6942                	ld	s2,16(sp)
    80002592:	69a2                	ld	s3,8(sp)
    80002594:	6a02                	ld	s4,0(sp)
    80002596:	6145                	addi	sp,sp,48
    80002598:	8082                	ret
    memmove((char *)dst, src, len);
    8000259a:	000a061b          	sext.w	a2,s4
    8000259e:	85ce                	mv	a1,s3
    800025a0:	854a                	mv	a0,s2
    800025a2:	ffffe097          	auipc	ra,0xffffe
    800025a6:	79e080e7          	jalr	1950(ra) # 80000d40 <memmove>
    return 0;
    800025aa:	8526                	mv	a0,s1
    800025ac:	bff9                	j	8000258a <either_copyout+0x32>

00000000800025ae <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025ae:	7179                	addi	sp,sp,-48
    800025b0:	f406                	sd	ra,40(sp)
    800025b2:	f022                	sd	s0,32(sp)
    800025b4:	ec26                	sd	s1,24(sp)
    800025b6:	e84a                	sd	s2,16(sp)
    800025b8:	e44e                	sd	s3,8(sp)
    800025ba:	e052                	sd	s4,0(sp)
    800025bc:	1800                	addi	s0,sp,48
    800025be:	892a                	mv	s2,a0
    800025c0:	84ae                	mv	s1,a1
    800025c2:	89b2                	mv	s3,a2
    800025c4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025c6:	fffff097          	auipc	ra,0xfffff
    800025ca:	3ea080e7          	jalr	1002(ra) # 800019b0 <myproc>
  if(user_src){
    800025ce:	c08d                	beqz	s1,800025f0 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025d0:	86d2                	mv	a3,s4
    800025d2:	864e                	mv	a2,s3
    800025d4:	85ca                	mv	a1,s2
    800025d6:	6928                	ld	a0,80(a0)
    800025d8:	fffff097          	auipc	ra,0xfffff
    800025dc:	126080e7          	jalr	294(ra) # 800016fe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025e0:	70a2                	ld	ra,40(sp)
    800025e2:	7402                	ld	s0,32(sp)
    800025e4:	64e2                	ld	s1,24(sp)
    800025e6:	6942                	ld	s2,16(sp)
    800025e8:	69a2                	ld	s3,8(sp)
    800025ea:	6a02                	ld	s4,0(sp)
    800025ec:	6145                	addi	sp,sp,48
    800025ee:	8082                	ret
    memmove(dst, (char*)src, len);
    800025f0:	000a061b          	sext.w	a2,s4
    800025f4:	85ce                	mv	a1,s3
    800025f6:	854a                	mv	a0,s2
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	748080e7          	jalr	1864(ra) # 80000d40 <memmove>
    return 0;
    80002600:	8526                	mv	a0,s1
    80002602:	bff9                	j	800025e0 <either_copyin+0x32>

0000000080002604 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002604:	715d                	addi	sp,sp,-80
    80002606:	e486                	sd	ra,72(sp)
    80002608:	e0a2                	sd	s0,64(sp)
    8000260a:	fc26                	sd	s1,56(sp)
    8000260c:	f84a                	sd	s2,48(sp)
    8000260e:	f44e                	sd	s3,40(sp)
    80002610:	f052                	sd	s4,32(sp)
    80002612:	ec56                	sd	s5,24(sp)
    80002614:	e85a                	sd	s6,16(sp)
    80002616:	e45e                	sd	s7,8(sp)
    80002618:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000261a:	00006517          	auipc	a0,0x6
    8000261e:	aae50513          	addi	a0,a0,-1362 # 800080c8 <digits+0x88>
    80002622:	ffffe097          	auipc	ra,0xffffe
    80002626:	f66080e7          	jalr	-154(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000262a:	0000f497          	auipc	s1,0xf
    8000262e:	1fe48493          	addi	s1,s1,510 # 80011828 <proc+0x158>
    80002632:	00015917          	auipc	s2,0x15
    80002636:	bf690913          	addi	s2,s2,-1034 # 80017228 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000263a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000263c:	00006997          	auipc	s3,0x6
    80002640:	c4498993          	addi	s3,s3,-956 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002644:	00006a97          	auipc	s5,0x6
    80002648:	c44a8a93          	addi	s5,s5,-956 # 80008288 <digits+0x248>
    printf("\n");
    8000264c:	00006a17          	auipc	s4,0x6
    80002650:	a7ca0a13          	addi	s4,s4,-1412 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002654:	00006b97          	auipc	s7,0x6
    80002658:	c6cb8b93          	addi	s7,s7,-916 # 800082c0 <states.1721>
    8000265c:	a00d                	j	8000267e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000265e:	ed86a583          	lw	a1,-296(a3)
    80002662:	8556                	mv	a0,s5
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	f24080e7          	jalr	-220(ra) # 80000588 <printf>
    printf("\n");
    8000266c:	8552                	mv	a0,s4
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	f1a080e7          	jalr	-230(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002676:	16848493          	addi	s1,s1,360
    8000267a:	03248163          	beq	s1,s2,8000269c <procdump+0x98>
    if(p->state == UNUSED)
    8000267e:	86a6                	mv	a3,s1
    80002680:	ec04a783          	lw	a5,-320(s1)
    80002684:	dbed                	beqz	a5,80002676 <procdump+0x72>
      state = "???";
    80002686:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002688:	fcfb6be3          	bltu	s6,a5,8000265e <procdump+0x5a>
    8000268c:	1782                	slli	a5,a5,0x20
    8000268e:	9381                	srli	a5,a5,0x20
    80002690:	078e                	slli	a5,a5,0x3
    80002692:	97de                	add	a5,a5,s7
    80002694:	6390                	ld	a2,0(a5)
    80002696:	f661                	bnez	a2,8000265e <procdump+0x5a>
      state = "???";
    80002698:	864e                	mv	a2,s3
    8000269a:	b7d1                	j	8000265e <procdump+0x5a>
  }
}
    8000269c:	60a6                	ld	ra,72(sp)
    8000269e:	6406                	ld	s0,64(sp)
    800026a0:	74e2                	ld	s1,56(sp)
    800026a2:	7942                	ld	s2,48(sp)
    800026a4:	79a2                	ld	s3,40(sp)
    800026a6:	7a02                	ld	s4,32(sp)
    800026a8:	6ae2                	ld	s5,24(sp)
    800026aa:	6b42                	ld	s6,16(sp)
    800026ac:	6ba2                	ld	s7,8(sp)
    800026ae:	6161                	addi	sp,sp,80
    800026b0:	8082                	ret

00000000800026b2 <swtch>:
    800026b2:	00153023          	sd	ra,0(a0)
    800026b6:	00253423          	sd	sp,8(a0)
    800026ba:	e900                	sd	s0,16(a0)
    800026bc:	ed04                	sd	s1,24(a0)
    800026be:	03253023          	sd	s2,32(a0)
    800026c2:	03353423          	sd	s3,40(a0)
    800026c6:	03453823          	sd	s4,48(a0)
    800026ca:	03553c23          	sd	s5,56(a0)
    800026ce:	05653023          	sd	s6,64(a0)
    800026d2:	05753423          	sd	s7,72(a0)
    800026d6:	05853823          	sd	s8,80(a0)
    800026da:	05953c23          	sd	s9,88(a0)
    800026de:	07a53023          	sd	s10,96(a0)
    800026e2:	07b53423          	sd	s11,104(a0)
    800026e6:	0005b083          	ld	ra,0(a1)
    800026ea:	0085b103          	ld	sp,8(a1)
    800026ee:	6980                	ld	s0,16(a1)
    800026f0:	6d84                	ld	s1,24(a1)
    800026f2:	0205b903          	ld	s2,32(a1)
    800026f6:	0285b983          	ld	s3,40(a1)
    800026fa:	0305ba03          	ld	s4,48(a1)
    800026fe:	0385ba83          	ld	s5,56(a1)
    80002702:	0405bb03          	ld	s6,64(a1)
    80002706:	0485bb83          	ld	s7,72(a1)
    8000270a:	0505bc03          	ld	s8,80(a1)
    8000270e:	0585bc83          	ld	s9,88(a1)
    80002712:	0605bd03          	ld	s10,96(a1)
    80002716:	0685bd83          	ld	s11,104(a1)
    8000271a:	8082                	ret

000000008000271c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000271c:	1141                	addi	sp,sp,-16
    8000271e:	e406                	sd	ra,8(sp)
    80002720:	e022                	sd	s0,0(sp)
    80002722:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002724:	00006597          	auipc	a1,0x6
    80002728:	bcc58593          	addi	a1,a1,-1076 # 800082f0 <states.1721+0x30>
    8000272c:	00015517          	auipc	a0,0x15
    80002730:	9a450513          	addi	a0,a0,-1628 # 800170d0 <tickslock>
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	420080e7          	jalr	1056(ra) # 80000b54 <initlock>
}
    8000273c:	60a2                	ld	ra,8(sp)
    8000273e:	6402                	ld	s0,0(sp)
    80002740:	0141                	addi	sp,sp,16
    80002742:	8082                	ret

0000000080002744 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002744:	1141                	addi	sp,sp,-16
    80002746:	e422                	sd	s0,8(sp)
    80002748:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000274a:	00003797          	auipc	a5,0x3
    8000274e:	54678793          	addi	a5,a5,1350 # 80005c90 <kernelvec>
    80002752:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002756:	6422                	ld	s0,8(sp)
    80002758:	0141                	addi	sp,sp,16
    8000275a:	8082                	ret

000000008000275c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000275c:	1141                	addi	sp,sp,-16
    8000275e:	e406                	sd	ra,8(sp)
    80002760:	e022                	sd	s0,0(sp)
    80002762:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002764:	fffff097          	auipc	ra,0xfffff
    80002768:	24c080e7          	jalr	588(ra) # 800019b0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000276c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002770:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002772:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002776:	00005617          	auipc	a2,0x5
    8000277a:	88a60613          	addi	a2,a2,-1910 # 80007000 <_trampoline>
    8000277e:	00005697          	auipc	a3,0x5
    80002782:	88268693          	addi	a3,a3,-1918 # 80007000 <_trampoline>
    80002786:	8e91                	sub	a3,a3,a2
    80002788:	040007b7          	lui	a5,0x4000
    8000278c:	17fd                	addi	a5,a5,-1
    8000278e:	07b2                	slli	a5,a5,0xc
    80002790:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002792:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002796:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002798:	180026f3          	csrr	a3,satp
    8000279c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000279e:	6d38                	ld	a4,88(a0)
    800027a0:	6134                	ld	a3,64(a0)
    800027a2:	6585                	lui	a1,0x1
    800027a4:	96ae                	add	a3,a3,a1
    800027a6:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027a8:	6d38                	ld	a4,88(a0)
    800027aa:	00000697          	auipc	a3,0x0
    800027ae:	13868693          	addi	a3,a3,312 # 800028e2 <usertrap>
    800027b2:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027b4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027b6:	8692                	mv	a3,tp
    800027b8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ba:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027be:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027c2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027c6:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027ca:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027cc:	6f18                	ld	a4,24(a4)
    800027ce:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027d2:	692c                	ld	a1,80(a0)
    800027d4:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800027d6:	00005717          	auipc	a4,0x5
    800027da:	8ba70713          	addi	a4,a4,-1862 # 80007090 <userret>
    800027de:	8f11                	sub	a4,a4,a2
    800027e0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800027e2:	577d                	li	a4,-1
    800027e4:	177e                	slli	a4,a4,0x3f
    800027e6:	8dd9                	or	a1,a1,a4
    800027e8:	02000537          	lui	a0,0x2000
    800027ec:	157d                	addi	a0,a0,-1
    800027ee:	0536                	slli	a0,a0,0xd
    800027f0:	9782                	jalr	a5
}
    800027f2:	60a2                	ld	ra,8(sp)
    800027f4:	6402                	ld	s0,0(sp)
    800027f6:	0141                	addi	sp,sp,16
    800027f8:	8082                	ret

00000000800027fa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027fa:	1101                	addi	sp,sp,-32
    800027fc:	ec06                	sd	ra,24(sp)
    800027fe:	e822                	sd	s0,16(sp)
    80002800:	e426                	sd	s1,8(sp)
    80002802:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002804:	00015497          	auipc	s1,0x15
    80002808:	8cc48493          	addi	s1,s1,-1844 # 800170d0 <tickslock>
    8000280c:	8526                	mv	a0,s1
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	3d6080e7          	jalr	982(ra) # 80000be4 <acquire>
  ticks++;
    80002816:	00007517          	auipc	a0,0x7
    8000281a:	81a50513          	addi	a0,a0,-2022 # 80009030 <ticks>
    8000281e:	411c                	lw	a5,0(a0)
    80002820:	2785                	addiw	a5,a5,1
    80002822:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002824:	00000097          	auipc	ra,0x0
    80002828:	b1c080e7          	jalr	-1252(ra) # 80002340 <wakeup>
  release(&tickslock);
    8000282c:	8526                	mv	a0,s1
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	46a080e7          	jalr	1130(ra) # 80000c98 <release>
}
    80002836:	60e2                	ld	ra,24(sp)
    80002838:	6442                	ld	s0,16(sp)
    8000283a:	64a2                	ld	s1,8(sp)
    8000283c:	6105                	addi	sp,sp,32
    8000283e:	8082                	ret

0000000080002840 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	e426                	sd	s1,8(sp)
    80002848:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000284a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000284e:	00074d63          	bltz	a4,80002868 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002852:	57fd                	li	a5,-1
    80002854:	17fe                	slli	a5,a5,0x3f
    80002856:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002858:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000285a:	06f70363          	beq	a4,a5,800028c0 <devintr+0x80>
  }
}
    8000285e:	60e2                	ld	ra,24(sp)
    80002860:	6442                	ld	s0,16(sp)
    80002862:	64a2                	ld	s1,8(sp)
    80002864:	6105                	addi	sp,sp,32
    80002866:	8082                	ret
     (scause & 0xff) == 9){
    80002868:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000286c:	46a5                	li	a3,9
    8000286e:	fed792e3          	bne	a5,a3,80002852 <devintr+0x12>
    int irq = plic_claim();
    80002872:	00003097          	auipc	ra,0x3
    80002876:	526080e7          	jalr	1318(ra) # 80005d98 <plic_claim>
    8000287a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000287c:	47a9                	li	a5,10
    8000287e:	02f50763          	beq	a0,a5,800028ac <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002882:	4785                	li	a5,1
    80002884:	02f50963          	beq	a0,a5,800028b6 <devintr+0x76>
    return 1;
    80002888:	4505                	li	a0,1
    } else if(irq){
    8000288a:	d8f1                	beqz	s1,8000285e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000288c:	85a6                	mv	a1,s1
    8000288e:	00006517          	auipc	a0,0x6
    80002892:	a6a50513          	addi	a0,a0,-1430 # 800082f8 <states.1721+0x38>
    80002896:	ffffe097          	auipc	ra,0xffffe
    8000289a:	cf2080e7          	jalr	-782(ra) # 80000588 <printf>
      plic_complete(irq);
    8000289e:	8526                	mv	a0,s1
    800028a0:	00003097          	auipc	ra,0x3
    800028a4:	51c080e7          	jalr	1308(ra) # 80005dbc <plic_complete>
    return 1;
    800028a8:	4505                	li	a0,1
    800028aa:	bf55                	j	8000285e <devintr+0x1e>
      uartintr();
    800028ac:	ffffe097          	auipc	ra,0xffffe
    800028b0:	0fc080e7          	jalr	252(ra) # 800009a8 <uartintr>
    800028b4:	b7ed                	j	8000289e <devintr+0x5e>
      virtio_disk_intr();
    800028b6:	00004097          	auipc	ra,0x4
    800028ba:	9e6080e7          	jalr	-1562(ra) # 8000629c <virtio_disk_intr>
    800028be:	b7c5                	j	8000289e <devintr+0x5e>
    if(cpuid() == 0){
    800028c0:	fffff097          	auipc	ra,0xfffff
    800028c4:	0c4080e7          	jalr	196(ra) # 80001984 <cpuid>
    800028c8:	c901                	beqz	a0,800028d8 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028ca:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028ce:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028d0:	14479073          	csrw	sip,a5
    return 2;
    800028d4:	4509                	li	a0,2
    800028d6:	b761                	j	8000285e <devintr+0x1e>
      clockintr();
    800028d8:	00000097          	auipc	ra,0x0
    800028dc:	f22080e7          	jalr	-222(ra) # 800027fa <clockintr>
    800028e0:	b7ed                	j	800028ca <devintr+0x8a>

00000000800028e2 <usertrap>:
{
    800028e2:	1101                	addi	sp,sp,-32
    800028e4:	ec06                	sd	ra,24(sp)
    800028e6:	e822                	sd	s0,16(sp)
    800028e8:	e426                	sd	s1,8(sp)
    800028ea:	e04a                	sd	s2,0(sp)
    800028ec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ee:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028f2:	1007f793          	andi	a5,a5,256
    800028f6:	e3ad                	bnez	a5,80002958 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f8:	00003797          	auipc	a5,0x3
    800028fc:	39878793          	addi	a5,a5,920 # 80005c90 <kernelvec>
    80002900:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002904:	fffff097          	auipc	ra,0xfffff
    80002908:	0ac080e7          	jalr	172(ra) # 800019b0 <myproc>
    8000290c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000290e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002910:	14102773          	csrr	a4,sepc
    80002914:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002916:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000291a:	47a1                	li	a5,8
    8000291c:	04f71c63          	bne	a4,a5,80002974 <usertrap+0x92>
    if(p->killed)
    80002920:	551c                	lw	a5,40(a0)
    80002922:	e3b9                	bnez	a5,80002968 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002924:	6cb8                	ld	a4,88(s1)
    80002926:	6f1c                	ld	a5,24(a4)
    80002928:	0791                	addi	a5,a5,4
    8000292a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000292c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002930:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002934:	10079073          	csrw	sstatus,a5
    syscall();
    80002938:	00000097          	auipc	ra,0x0
    8000293c:	2e0080e7          	jalr	736(ra) # 80002c18 <syscall>
  if(p->killed)
    80002940:	549c                	lw	a5,40(s1)
    80002942:	ebc1                	bnez	a5,800029d2 <usertrap+0xf0>
  usertrapret();
    80002944:	00000097          	auipc	ra,0x0
    80002948:	e18080e7          	jalr	-488(ra) # 8000275c <usertrapret>
}
    8000294c:	60e2                	ld	ra,24(sp)
    8000294e:	6442                	ld	s0,16(sp)
    80002950:	64a2                	ld	s1,8(sp)
    80002952:	6902                	ld	s2,0(sp)
    80002954:	6105                	addi	sp,sp,32
    80002956:	8082                	ret
    panic("usertrap: not from user mode");
    80002958:	00006517          	auipc	a0,0x6
    8000295c:	9c050513          	addi	a0,a0,-1600 # 80008318 <states.1721+0x58>
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	bde080e7          	jalr	-1058(ra) # 8000053e <panic>
      exit(-1);
    80002968:	557d                	li	a0,-1
    8000296a:	00000097          	auipc	ra,0x0
    8000296e:	aa6080e7          	jalr	-1370(ra) # 80002410 <exit>
    80002972:	bf4d                	j	80002924 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002974:	00000097          	auipc	ra,0x0
    80002978:	ecc080e7          	jalr	-308(ra) # 80002840 <devintr>
    8000297c:	892a                	mv	s2,a0
    8000297e:	c501                	beqz	a0,80002986 <usertrap+0xa4>
  if(p->killed)
    80002980:	549c                	lw	a5,40(s1)
    80002982:	c3a1                	beqz	a5,800029c2 <usertrap+0xe0>
    80002984:	a815                	j	800029b8 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002986:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000298a:	5890                	lw	a2,48(s1)
    8000298c:	00006517          	auipc	a0,0x6
    80002990:	9ac50513          	addi	a0,a0,-1620 # 80008338 <states.1721+0x78>
    80002994:	ffffe097          	auipc	ra,0xffffe
    80002998:	bf4080e7          	jalr	-1036(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000299c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029a0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029a4:	00006517          	auipc	a0,0x6
    800029a8:	9c450513          	addi	a0,a0,-1596 # 80008368 <states.1721+0xa8>
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	bdc080e7          	jalr	-1060(ra) # 80000588 <printf>
    p->killed = 1;
    800029b4:	4785                	li	a5,1
    800029b6:	d49c                	sw	a5,40(s1)
    exit(-1);
    800029b8:	557d                	li	a0,-1
    800029ba:	00000097          	auipc	ra,0x0
    800029be:	a56080e7          	jalr	-1450(ra) # 80002410 <exit>
  if(which_dev == 2)
    800029c2:	4789                	li	a5,2
    800029c4:	f8f910e3          	bne	s2,a5,80002944 <usertrap+0x62>
    yield();
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	7b0080e7          	jalr	1968(ra) # 80002178 <yield>
    800029d0:	bf95                	j	80002944 <usertrap+0x62>
  int which_dev = 0;
    800029d2:	4901                	li	s2,0
    800029d4:	b7d5                	j	800029b8 <usertrap+0xd6>

00000000800029d6 <kerneltrap>:
{
    800029d6:	7179                	addi	sp,sp,-48
    800029d8:	f406                	sd	ra,40(sp)
    800029da:	f022                	sd	s0,32(sp)
    800029dc:	ec26                	sd	s1,24(sp)
    800029de:	e84a                	sd	s2,16(sp)
    800029e0:	e44e                	sd	s3,8(sp)
    800029e2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029e4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ec:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029f0:	1004f793          	andi	a5,s1,256
    800029f4:	cb85                	beqz	a5,80002a24 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029f6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029fa:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029fc:	ef85                	bnez	a5,80002a34 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029fe:	00000097          	auipc	ra,0x0
    80002a02:	e42080e7          	jalr	-446(ra) # 80002840 <devintr>
    80002a06:	cd1d                	beqz	a0,80002a44 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a08:	4789                	li	a5,2
    80002a0a:	06f50a63          	beq	a0,a5,80002a7e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a0e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a12:	10049073          	csrw	sstatus,s1
}
    80002a16:	70a2                	ld	ra,40(sp)
    80002a18:	7402                	ld	s0,32(sp)
    80002a1a:	64e2                	ld	s1,24(sp)
    80002a1c:	6942                	ld	s2,16(sp)
    80002a1e:	69a2                	ld	s3,8(sp)
    80002a20:	6145                	addi	sp,sp,48
    80002a22:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a24:	00006517          	auipc	a0,0x6
    80002a28:	96450513          	addi	a0,a0,-1692 # 80008388 <states.1721+0xc8>
    80002a2c:	ffffe097          	auipc	ra,0xffffe
    80002a30:	b12080e7          	jalr	-1262(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002a34:	00006517          	auipc	a0,0x6
    80002a38:	97c50513          	addi	a0,a0,-1668 # 800083b0 <states.1721+0xf0>
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	b02080e7          	jalr	-1278(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002a44:	85ce                	mv	a1,s3
    80002a46:	00006517          	auipc	a0,0x6
    80002a4a:	98a50513          	addi	a0,a0,-1654 # 800083d0 <states.1721+0x110>
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	b3a080e7          	jalr	-1222(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a56:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a5a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a5e:	00006517          	auipc	a0,0x6
    80002a62:	98250513          	addi	a0,a0,-1662 # 800083e0 <states.1721+0x120>
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	b22080e7          	jalr	-1246(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002a6e:	00006517          	auipc	a0,0x6
    80002a72:	98a50513          	addi	a0,a0,-1654 # 800083f8 <states.1721+0x138>
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	ac8080e7          	jalr	-1336(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a7e:	fffff097          	auipc	ra,0xfffff
    80002a82:	f32080e7          	jalr	-206(ra) # 800019b0 <myproc>
    80002a86:	d541                	beqz	a0,80002a0e <kerneltrap+0x38>
    80002a88:	fffff097          	auipc	ra,0xfffff
    80002a8c:	f28080e7          	jalr	-216(ra) # 800019b0 <myproc>
    80002a90:	4d18                	lw	a4,24(a0)
    80002a92:	4791                	li	a5,4
    80002a94:	f6f71de3          	bne	a4,a5,80002a0e <kerneltrap+0x38>
    yield();
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	6e0080e7          	jalr	1760(ra) # 80002178 <yield>
    80002aa0:	b7bd                	j	80002a0e <kerneltrap+0x38>

0000000080002aa2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002aa2:	1101                	addi	sp,sp,-32
    80002aa4:	ec06                	sd	ra,24(sp)
    80002aa6:	e822                	sd	s0,16(sp)
    80002aa8:	e426                	sd	s1,8(sp)
    80002aaa:	1000                	addi	s0,sp,32
    80002aac:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002aae:	fffff097          	auipc	ra,0xfffff
    80002ab2:	f02080e7          	jalr	-254(ra) # 800019b0 <myproc>
  switch (n) {
    80002ab6:	4795                	li	a5,5
    80002ab8:	0497e163          	bltu	a5,s1,80002afa <argraw+0x58>
    80002abc:	048a                	slli	s1,s1,0x2
    80002abe:	00006717          	auipc	a4,0x6
    80002ac2:	97270713          	addi	a4,a4,-1678 # 80008430 <states.1721+0x170>
    80002ac6:	94ba                	add	s1,s1,a4
    80002ac8:	409c                	lw	a5,0(s1)
    80002aca:	97ba                	add	a5,a5,a4
    80002acc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ace:	6d3c                	ld	a5,88(a0)
    80002ad0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ad2:	60e2                	ld	ra,24(sp)
    80002ad4:	6442                	ld	s0,16(sp)
    80002ad6:	64a2                	ld	s1,8(sp)
    80002ad8:	6105                	addi	sp,sp,32
    80002ada:	8082                	ret
    return p->trapframe->a1;
    80002adc:	6d3c                	ld	a5,88(a0)
    80002ade:	7fa8                	ld	a0,120(a5)
    80002ae0:	bfcd                	j	80002ad2 <argraw+0x30>
    return p->trapframe->a2;
    80002ae2:	6d3c                	ld	a5,88(a0)
    80002ae4:	63c8                	ld	a0,128(a5)
    80002ae6:	b7f5                	j	80002ad2 <argraw+0x30>
    return p->trapframe->a3;
    80002ae8:	6d3c                	ld	a5,88(a0)
    80002aea:	67c8                	ld	a0,136(a5)
    80002aec:	b7dd                	j	80002ad2 <argraw+0x30>
    return p->trapframe->a4;
    80002aee:	6d3c                	ld	a5,88(a0)
    80002af0:	6bc8                	ld	a0,144(a5)
    80002af2:	b7c5                	j	80002ad2 <argraw+0x30>
    return p->trapframe->a5;
    80002af4:	6d3c                	ld	a5,88(a0)
    80002af6:	6fc8                	ld	a0,152(a5)
    80002af8:	bfe9                	j	80002ad2 <argraw+0x30>
  panic("argraw");
    80002afa:	00006517          	auipc	a0,0x6
    80002afe:	90e50513          	addi	a0,a0,-1778 # 80008408 <states.1721+0x148>
    80002b02:	ffffe097          	auipc	ra,0xffffe
    80002b06:	a3c080e7          	jalr	-1476(ra) # 8000053e <panic>

0000000080002b0a <fetchaddr>:
{
    80002b0a:	1101                	addi	sp,sp,-32
    80002b0c:	ec06                	sd	ra,24(sp)
    80002b0e:	e822                	sd	s0,16(sp)
    80002b10:	e426                	sd	s1,8(sp)
    80002b12:	e04a                	sd	s2,0(sp)
    80002b14:	1000                	addi	s0,sp,32
    80002b16:	84aa                	mv	s1,a0
    80002b18:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b1a:	fffff097          	auipc	ra,0xfffff
    80002b1e:	e96080e7          	jalr	-362(ra) # 800019b0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b22:	653c                	ld	a5,72(a0)
    80002b24:	02f4f863          	bgeu	s1,a5,80002b54 <fetchaddr+0x4a>
    80002b28:	00848713          	addi	a4,s1,8
    80002b2c:	02e7e663          	bltu	a5,a4,80002b58 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b30:	46a1                	li	a3,8
    80002b32:	8626                	mv	a2,s1
    80002b34:	85ca                	mv	a1,s2
    80002b36:	6928                	ld	a0,80(a0)
    80002b38:	fffff097          	auipc	ra,0xfffff
    80002b3c:	bc6080e7          	jalr	-1082(ra) # 800016fe <copyin>
    80002b40:	00a03533          	snez	a0,a0
    80002b44:	40a00533          	neg	a0,a0
}
    80002b48:	60e2                	ld	ra,24(sp)
    80002b4a:	6442                	ld	s0,16(sp)
    80002b4c:	64a2                	ld	s1,8(sp)
    80002b4e:	6902                	ld	s2,0(sp)
    80002b50:	6105                	addi	sp,sp,32
    80002b52:	8082                	ret
    return -1;
    80002b54:	557d                	li	a0,-1
    80002b56:	bfcd                	j	80002b48 <fetchaddr+0x3e>
    80002b58:	557d                	li	a0,-1
    80002b5a:	b7fd                	j	80002b48 <fetchaddr+0x3e>

0000000080002b5c <fetchstr>:
{
    80002b5c:	7179                	addi	sp,sp,-48
    80002b5e:	f406                	sd	ra,40(sp)
    80002b60:	f022                	sd	s0,32(sp)
    80002b62:	ec26                	sd	s1,24(sp)
    80002b64:	e84a                	sd	s2,16(sp)
    80002b66:	e44e                	sd	s3,8(sp)
    80002b68:	1800                	addi	s0,sp,48
    80002b6a:	892a                	mv	s2,a0
    80002b6c:	84ae                	mv	s1,a1
    80002b6e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b70:	fffff097          	auipc	ra,0xfffff
    80002b74:	e40080e7          	jalr	-448(ra) # 800019b0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b78:	86ce                	mv	a3,s3
    80002b7a:	864a                	mv	a2,s2
    80002b7c:	85a6                	mv	a1,s1
    80002b7e:	6928                	ld	a0,80(a0)
    80002b80:	fffff097          	auipc	ra,0xfffff
    80002b84:	c0a080e7          	jalr	-1014(ra) # 8000178a <copyinstr>
  if(err < 0)
    80002b88:	00054763          	bltz	a0,80002b96 <fetchstr+0x3a>
  return strlen(buf);
    80002b8c:	8526                	mv	a0,s1
    80002b8e:	ffffe097          	auipc	ra,0xffffe
    80002b92:	2d6080e7          	jalr	726(ra) # 80000e64 <strlen>
}
    80002b96:	70a2                	ld	ra,40(sp)
    80002b98:	7402                	ld	s0,32(sp)
    80002b9a:	64e2                	ld	s1,24(sp)
    80002b9c:	6942                	ld	s2,16(sp)
    80002b9e:	69a2                	ld	s3,8(sp)
    80002ba0:	6145                	addi	sp,sp,48
    80002ba2:	8082                	ret

0000000080002ba4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002ba4:	1101                	addi	sp,sp,-32
    80002ba6:	ec06                	sd	ra,24(sp)
    80002ba8:	e822                	sd	s0,16(sp)
    80002baa:	e426                	sd	s1,8(sp)
    80002bac:	1000                	addi	s0,sp,32
    80002bae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bb0:	00000097          	auipc	ra,0x0
    80002bb4:	ef2080e7          	jalr	-270(ra) # 80002aa2 <argraw>
    80002bb8:	c088                	sw	a0,0(s1)
  return 0;
}
    80002bba:	4501                	li	a0,0
    80002bbc:	60e2                	ld	ra,24(sp)
    80002bbe:	6442                	ld	s0,16(sp)
    80002bc0:	64a2                	ld	s1,8(sp)
    80002bc2:	6105                	addi	sp,sp,32
    80002bc4:	8082                	ret

0000000080002bc6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002bc6:	1101                	addi	sp,sp,-32
    80002bc8:	ec06                	sd	ra,24(sp)
    80002bca:	e822                	sd	s0,16(sp)
    80002bcc:	e426                	sd	s1,8(sp)
    80002bce:	1000                	addi	s0,sp,32
    80002bd0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bd2:	00000097          	auipc	ra,0x0
    80002bd6:	ed0080e7          	jalr	-304(ra) # 80002aa2 <argraw>
    80002bda:	e088                	sd	a0,0(s1)
  return 0;
}
    80002bdc:	4501                	li	a0,0
    80002bde:	60e2                	ld	ra,24(sp)
    80002be0:	6442                	ld	s0,16(sp)
    80002be2:	64a2                	ld	s1,8(sp)
    80002be4:	6105                	addi	sp,sp,32
    80002be6:	8082                	ret

0000000080002be8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002be8:	1101                	addi	sp,sp,-32
    80002bea:	ec06                	sd	ra,24(sp)
    80002bec:	e822                	sd	s0,16(sp)
    80002bee:	e426                	sd	s1,8(sp)
    80002bf0:	e04a                	sd	s2,0(sp)
    80002bf2:	1000                	addi	s0,sp,32
    80002bf4:	84ae                	mv	s1,a1
    80002bf6:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002bf8:	00000097          	auipc	ra,0x0
    80002bfc:	eaa080e7          	jalr	-342(ra) # 80002aa2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c00:	864a                	mv	a2,s2
    80002c02:	85a6                	mv	a1,s1
    80002c04:	00000097          	auipc	ra,0x0
    80002c08:	f58080e7          	jalr	-168(ra) # 80002b5c <fetchstr>
}
    80002c0c:	60e2                	ld	ra,24(sp)
    80002c0e:	6442                	ld	s0,16(sp)
    80002c10:	64a2                	ld	s1,8(sp)
    80002c12:	6902                	ld	s2,0(sp)
    80002c14:	6105                	addi	sp,sp,32
    80002c16:	8082                	ret

0000000080002c18 <syscall>:

};

void
syscall(void)
{
    80002c18:	1101                	addi	sp,sp,-32
    80002c1a:	ec06                	sd	ra,24(sp)
    80002c1c:	e822                	sd	s0,16(sp)
    80002c1e:	e426                	sd	s1,8(sp)
    80002c20:	e04a                	sd	s2,0(sp)
    80002c22:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	d8c080e7          	jalr	-628(ra) # 800019b0 <myproc>
    80002c2c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c2e:	05853903          	ld	s2,88(a0)
    80002c32:	0a893783          	ld	a5,168(s2)
    80002c36:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c3a:	37fd                	addiw	a5,a5,-1
    80002c3c:	4761                	li	a4,24
    80002c3e:	00f76f63          	bltu	a4,a5,80002c5c <syscall+0x44>
    80002c42:	00369713          	slli	a4,a3,0x3
    80002c46:	00006797          	auipc	a5,0x6
    80002c4a:	80278793          	addi	a5,a5,-2046 # 80008448 <syscalls>
    80002c4e:	97ba                	add	a5,a5,a4
    80002c50:	639c                	ld	a5,0(a5)
    80002c52:	c789                	beqz	a5,80002c5c <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002c54:	9782                	jalr	a5
    80002c56:	06a93823          	sd	a0,112(s2)
    80002c5a:	a839                	j	80002c78 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c5c:	15848613          	addi	a2,s1,344
    80002c60:	588c                	lw	a1,48(s1)
    80002c62:	00005517          	auipc	a0,0x5
    80002c66:	7ae50513          	addi	a0,a0,1966 # 80008410 <states.1721+0x150>
    80002c6a:	ffffe097          	auipc	ra,0xffffe
    80002c6e:	91e080e7          	jalr	-1762(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c72:	6cbc                	ld	a5,88(s1)
    80002c74:	577d                	li	a4,-1
    80002c76:	fbb8                	sd	a4,112(a5)
  }
}
    80002c78:	60e2                	ld	ra,24(sp)
    80002c7a:	6442                	ld	s0,16(sp)
    80002c7c:	64a2                	ld	s1,8(sp)
    80002c7e:	6902                	ld	s2,0(sp)
    80002c80:	6105                	addi	sp,sp,32
    80002c82:	8082                	ret

0000000080002c84 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c84:	1101                	addi	sp,sp,-32
    80002c86:	ec06                	sd	ra,24(sp)
    80002c88:	e822                	sd	s0,16(sp)
    80002c8a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c8c:	fec40593          	addi	a1,s0,-20
    80002c90:	4501                	li	a0,0
    80002c92:	00000097          	auipc	ra,0x0
    80002c96:	f12080e7          	jalr	-238(ra) # 80002ba4 <argint>
    return -1;
    80002c9a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c9c:	00054963          	bltz	a0,80002cae <sys_exit+0x2a>
  exit(n);
    80002ca0:	fec42503          	lw	a0,-20(s0)
    80002ca4:	fffff097          	auipc	ra,0xfffff
    80002ca8:	76c080e7          	jalr	1900(ra) # 80002410 <exit>
  return 0;  // not reached
    80002cac:	4781                	li	a5,0
}
    80002cae:	853e                	mv	a0,a5
    80002cb0:	60e2                	ld	ra,24(sp)
    80002cb2:	6442                	ld	s0,16(sp)
    80002cb4:	6105                	addi	sp,sp,32
    80002cb6:	8082                	ret

0000000080002cb8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cb8:	1141                	addi	sp,sp,-16
    80002cba:	e406                	sd	ra,8(sp)
    80002cbc:	e022                	sd	s0,0(sp)
    80002cbe:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	cf0080e7          	jalr	-784(ra) # 800019b0 <myproc>
}
    80002cc8:	5908                	lw	a0,48(a0)
    80002cca:	60a2                	ld	ra,8(sp)
    80002ccc:	6402                	ld	s0,0(sp)
    80002cce:	0141                	addi	sp,sp,16
    80002cd0:	8082                	ret

0000000080002cd2 <sys_getppid>:

uint64
sys_getppid(void)
{
    80002cd2:	1141                	addi	sp,sp,-16
    80002cd4:	e406                	sd	ra,8(sp)
    80002cd6:	e022                	sd	s0,0(sp)
    80002cd8:	0800                	addi	s0,sp,16
  if(myproc()->parent){
    80002cda:	fffff097          	auipc	ra,0xfffff
    80002cde:	cd6080e7          	jalr	-810(ra) # 800019b0 <myproc>
    80002ce2:	7d1c                	ld	a5,56(a0)
    return myproc()->parent->pid;
  }
  return -1;
    80002ce4:	557d                	li	a0,-1
  if(myproc()->parent){
    80002ce6:	c799                	beqz	a5,80002cf4 <sys_getppid+0x22>
    return myproc()->parent->pid;
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	cc8080e7          	jalr	-824(ra) # 800019b0 <myproc>
    80002cf0:	7d1c                	ld	a5,56(a0)
    80002cf2:	5b88                	lw	a0,48(a5)
}
    80002cf4:	60a2                	ld	ra,8(sp)
    80002cf6:	6402                	ld	s0,0(sp)
    80002cf8:	0141                	addi	sp,sp,16
    80002cfa:	8082                	ret

0000000080002cfc <sys_yield>:

uint64
sys_yield(void)
{
    80002cfc:	1141                	addi	sp,sp,-16
    80002cfe:	e406                	sd	ra,8(sp)
    80002d00:	e022                	sd	s0,0(sp)
    80002d02:	0800                	addi	s0,sp,16
  yield();
    80002d04:	fffff097          	auipc	ra,0xfffff
    80002d08:	474080e7          	jalr	1140(ra) # 80002178 <yield>
  return 0;
}
    80002d0c:	4501                	li	a0,0
    80002d0e:	60a2                	ld	ra,8(sp)
    80002d10:	6402                	ld	s0,0(sp)
    80002d12:	0141                	addi	sp,sp,16
    80002d14:	8082                	ret

0000000080002d16 <sys_getpa>:

uint64
sys_getpa(void){
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	1000                	addi	s0,sp,32
  uint64 A;
  if(argaddr(0, &A) < 0){
    80002d1e:	fe840593          	addi	a1,s0,-24
    80002d22:	4501                	li	a0,0
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	ea2080e7          	jalr	-350(ra) # 80002bc6 <argaddr>
    80002d2c:	87aa                	mv	a5,a0
    // printf("%p\n", &p);
    return -1;
    80002d2e:	557d                	li	a0,-1
  if(argaddr(0, &A) < 0){
    80002d30:	0207c263          	bltz	a5,80002d54 <sys_getpa+0x3e>
  }
  // printf("%p %p\n", (void*)A, (void*)(uint64)(walkaddr(myproc()->pagetable, A) + ((A) & (uint64)(PGSIZE-1))));
  return (uint64)(walkaddr(myproc()->pagetable, A) + ((A) & (uint64)(PGSIZE-1)));
    80002d34:	fffff097          	auipc	ra,0xfffff
    80002d38:	c7c080e7          	jalr	-900(ra) # 800019b0 <myproc>
    80002d3c:	fe843583          	ld	a1,-24(s0)
    80002d40:	6928                	ld	a0,80(a0)
    80002d42:	ffffe097          	auipc	ra,0xffffe
    80002d46:	32c080e7          	jalr	812(ra) # 8000106e <walkaddr>
    80002d4a:	fe843783          	ld	a5,-24(s0)
    80002d4e:	17d2                	slli	a5,a5,0x34
    80002d50:	93d1                	srli	a5,a5,0x34
    80002d52:	953e                	add	a0,a0,a5
}
    80002d54:	60e2                	ld	ra,24(sp)
    80002d56:	6442                	ld	s0,16(sp)
    80002d58:	6105                	addi	sp,sp,32
    80002d5a:	8082                	ret

0000000080002d5c <sys_forkf>:


uint64
sys_forkf(void)
{
    80002d5c:	1101                	addi	sp,sp,-32
    80002d5e:	ec06                	sd	ra,24(sp)
    80002d60:	e822                	sd	s0,16(sp)
    80002d62:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0){
    80002d64:	fe840593          	addi	a1,s0,-24
    80002d68:	4501                	li	a0,0
    80002d6a:	00000097          	auipc	ra,0x0
    80002d6e:	e5c080e7          	jalr	-420(ra) # 80002bc6 <argaddr>
    80002d72:	87aa                	mv	a5,a0
    // printf("%p\n", &p);
    return -1;
    80002d74:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0){
    80002d76:	0007c863          	bltz	a5,80002d86 <sys_forkf+0x2a>
  }
  // printf("%d\n", p);
  return forkf(p);
    80002d7a:	fe843503          	ld	a0,-24(s0)
    80002d7e:	fffff097          	auipc	ra,0xfffff
    80002d82:	13c080e7          	jalr	316(ra) # 80001eba <forkf>
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret

0000000080002d8e <sys_fork>:

uint64
sys_fork(void)
{
    80002d8e:	1141                	addi	sp,sp,-16
    80002d90:	e406                	sd	ra,8(sp)
    80002d92:	e022                	sd	s0,0(sp)
    80002d94:	0800                	addi	s0,sp,16
  return fork();
    80002d96:	fffff097          	auipc	ra,0xfffff
    80002d9a:	fe8080e7          	jalr	-24(ra) # 80001d7e <fork>
}
    80002d9e:	60a2                	ld	ra,8(sp)
    80002da0:	6402                	ld	s0,0(sp)
    80002da2:	0141                	addi	sp,sp,16
    80002da4:	8082                	ret

0000000080002da6 <sys_wait>:

uint64
sys_wait(void)
{
    80002da6:	1101                	addi	sp,sp,-32
    80002da8:	ec06                	sd	ra,24(sp)
    80002daa:	e822                	sd	s0,16(sp)
    80002dac:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002dae:	fe840593          	addi	a1,s0,-24
    80002db2:	4501                	li	a0,0
    80002db4:	00000097          	auipc	ra,0x0
    80002db8:	e12080e7          	jalr	-494(ra) # 80002bc6 <argaddr>
    80002dbc:	87aa                	mv	a5,a0
    return -1;
    80002dbe:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002dc0:	0007c863          	bltz	a5,80002dd0 <sys_wait+0x2a>
  return wait(p);
    80002dc4:	fe843503          	ld	a0,-24(s0)
    80002dc8:	fffff097          	auipc	ra,0xfffff
    80002dcc:	450080e7          	jalr	1104(ra) # 80002218 <wait>
}
    80002dd0:	60e2                	ld	ra,24(sp)
    80002dd2:	6442                	ld	s0,16(sp)
    80002dd4:	6105                	addi	sp,sp,32
    80002dd6:	8082                	ret

0000000080002dd8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002dd8:	7179                	addi	sp,sp,-48
    80002dda:	f406                	sd	ra,40(sp)
    80002ddc:	f022                	sd	s0,32(sp)
    80002dde:	ec26                	sd	s1,24(sp)
    80002de0:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002de2:	fdc40593          	addi	a1,s0,-36
    80002de6:	4501                	li	a0,0
    80002de8:	00000097          	auipc	ra,0x0
    80002dec:	dbc080e7          	jalr	-580(ra) # 80002ba4 <argint>
    80002df0:	87aa                	mv	a5,a0
    return -1;
    80002df2:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002df4:	0207c063          	bltz	a5,80002e14 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002df8:	fffff097          	auipc	ra,0xfffff
    80002dfc:	bb8080e7          	jalr	-1096(ra) # 800019b0 <myproc>
    80002e00:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002e02:	fdc42503          	lw	a0,-36(s0)
    80002e06:	fffff097          	auipc	ra,0xfffff
    80002e0a:	f04080e7          	jalr	-252(ra) # 80001d0a <growproc>
    80002e0e:	00054863          	bltz	a0,80002e1e <sys_sbrk+0x46>
    return -1;
  return addr;
    80002e12:	8526                	mv	a0,s1
}
    80002e14:	70a2                	ld	ra,40(sp)
    80002e16:	7402                	ld	s0,32(sp)
    80002e18:	64e2                	ld	s1,24(sp)
    80002e1a:	6145                	addi	sp,sp,48
    80002e1c:	8082                	ret
    return -1;
    80002e1e:	557d                	li	a0,-1
    80002e20:	bfd5                	j	80002e14 <sys_sbrk+0x3c>

0000000080002e22 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e22:	7139                	addi	sp,sp,-64
    80002e24:	fc06                	sd	ra,56(sp)
    80002e26:	f822                	sd	s0,48(sp)
    80002e28:	f426                	sd	s1,40(sp)
    80002e2a:	f04a                	sd	s2,32(sp)
    80002e2c:	ec4e                	sd	s3,24(sp)
    80002e2e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002e30:	fcc40593          	addi	a1,s0,-52
    80002e34:	4501                	li	a0,0
    80002e36:	00000097          	auipc	ra,0x0
    80002e3a:	d6e080e7          	jalr	-658(ra) # 80002ba4 <argint>
    return -1;
    80002e3e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e40:	06054563          	bltz	a0,80002eaa <sys_sleep+0x88>
  acquire(&tickslock);
    80002e44:	00014517          	auipc	a0,0x14
    80002e48:	28c50513          	addi	a0,a0,652 # 800170d0 <tickslock>
    80002e4c:	ffffe097          	auipc	ra,0xffffe
    80002e50:	d98080e7          	jalr	-616(ra) # 80000be4 <acquire>
  ticks0 = ticks;
    80002e54:	00006917          	auipc	s2,0x6
    80002e58:	1dc92903          	lw	s2,476(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002e5c:	fcc42783          	lw	a5,-52(s0)
    80002e60:	cf85                	beqz	a5,80002e98 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e62:	00014997          	auipc	s3,0x14
    80002e66:	26e98993          	addi	s3,s3,622 # 800170d0 <tickslock>
    80002e6a:	00006497          	auipc	s1,0x6
    80002e6e:	1c648493          	addi	s1,s1,454 # 80009030 <ticks>
    if(myproc()->killed){
    80002e72:	fffff097          	auipc	ra,0xfffff
    80002e76:	b3e080e7          	jalr	-1218(ra) # 800019b0 <myproc>
    80002e7a:	551c                	lw	a5,40(a0)
    80002e7c:	ef9d                	bnez	a5,80002eba <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002e7e:	85ce                	mv	a1,s3
    80002e80:	8526                	mv	a0,s1
    80002e82:	fffff097          	auipc	ra,0xfffff
    80002e86:	332080e7          	jalr	818(ra) # 800021b4 <sleep>
  while(ticks - ticks0 < n){
    80002e8a:	409c                	lw	a5,0(s1)
    80002e8c:	412787bb          	subw	a5,a5,s2
    80002e90:	fcc42703          	lw	a4,-52(s0)
    80002e94:	fce7efe3          	bltu	a5,a4,80002e72 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e98:	00014517          	auipc	a0,0x14
    80002e9c:	23850513          	addi	a0,a0,568 # 800170d0 <tickslock>
    80002ea0:	ffffe097          	auipc	ra,0xffffe
    80002ea4:	df8080e7          	jalr	-520(ra) # 80000c98 <release>
  return 0;
    80002ea8:	4781                	li	a5,0
}
    80002eaa:	853e                	mv	a0,a5
    80002eac:	70e2                	ld	ra,56(sp)
    80002eae:	7442                	ld	s0,48(sp)
    80002eb0:	74a2                	ld	s1,40(sp)
    80002eb2:	7902                	ld	s2,32(sp)
    80002eb4:	69e2                	ld	s3,24(sp)
    80002eb6:	6121                	addi	sp,sp,64
    80002eb8:	8082                	ret
      release(&tickslock);
    80002eba:	00014517          	auipc	a0,0x14
    80002ebe:	21650513          	addi	a0,a0,534 # 800170d0 <tickslock>
    80002ec2:	ffffe097          	auipc	ra,0xffffe
    80002ec6:	dd6080e7          	jalr	-554(ra) # 80000c98 <release>
      return -1;
    80002eca:	57fd                	li	a5,-1
    80002ecc:	bff9                	j	80002eaa <sys_sleep+0x88>

0000000080002ece <sys_kill>:

uint64
sys_kill(void)
{
    80002ece:	1101                	addi	sp,sp,-32
    80002ed0:	ec06                	sd	ra,24(sp)
    80002ed2:	e822                	sd	s0,16(sp)
    80002ed4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002ed6:	fec40593          	addi	a1,s0,-20
    80002eda:	4501                	li	a0,0
    80002edc:	00000097          	auipc	ra,0x0
    80002ee0:	cc8080e7          	jalr	-824(ra) # 80002ba4 <argint>
    80002ee4:	87aa                	mv	a5,a0
    return -1;
    80002ee6:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002ee8:	0007c863          	bltz	a5,80002ef8 <sys_kill+0x2a>
  return kill(pid);
    80002eec:	fec42503          	lw	a0,-20(s0)
    80002ef0:	fffff097          	auipc	ra,0xfffff
    80002ef4:	5f6080e7          	jalr	1526(ra) # 800024e6 <kill>
}
    80002ef8:	60e2                	ld	ra,24(sp)
    80002efa:	6442                	ld	s0,16(sp)
    80002efc:	6105                	addi	sp,sp,32
    80002efe:	8082                	ret

0000000080002f00 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f00:	1101                	addi	sp,sp,-32
    80002f02:	ec06                	sd	ra,24(sp)
    80002f04:	e822                	sd	s0,16(sp)
    80002f06:	e426                	sd	s1,8(sp)
    80002f08:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f0a:	00014517          	auipc	a0,0x14
    80002f0e:	1c650513          	addi	a0,a0,454 # 800170d0 <tickslock>
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	cd2080e7          	jalr	-814(ra) # 80000be4 <acquire>
  xticks = ticks;
    80002f1a:	00006497          	auipc	s1,0x6
    80002f1e:	1164a483          	lw	s1,278(s1) # 80009030 <ticks>
  release(&tickslock);
    80002f22:	00014517          	auipc	a0,0x14
    80002f26:	1ae50513          	addi	a0,a0,430 # 800170d0 <tickslock>
    80002f2a:	ffffe097          	auipc	ra,0xffffe
    80002f2e:	d6e080e7          	jalr	-658(ra) # 80000c98 <release>
  return xticks;
}
    80002f32:	02049513          	slli	a0,s1,0x20
    80002f36:	9101                	srli	a0,a0,0x20
    80002f38:	60e2                	ld	ra,24(sp)
    80002f3a:	6442                	ld	s0,16(sp)
    80002f3c:	64a2                	ld	s1,8(sp)
    80002f3e:	6105                	addi	sp,sp,32
    80002f40:	8082                	ret

0000000080002f42 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f42:	7179                	addi	sp,sp,-48
    80002f44:	f406                	sd	ra,40(sp)
    80002f46:	f022                	sd	s0,32(sp)
    80002f48:	ec26                	sd	s1,24(sp)
    80002f4a:	e84a                	sd	s2,16(sp)
    80002f4c:	e44e                	sd	s3,8(sp)
    80002f4e:	e052                	sd	s4,0(sp)
    80002f50:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f52:	00005597          	auipc	a1,0x5
    80002f56:	5c658593          	addi	a1,a1,1478 # 80008518 <syscalls+0xd0>
    80002f5a:	00014517          	auipc	a0,0x14
    80002f5e:	18e50513          	addi	a0,a0,398 # 800170e8 <bcache>
    80002f62:	ffffe097          	auipc	ra,0xffffe
    80002f66:	bf2080e7          	jalr	-1038(ra) # 80000b54 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f6a:	0001c797          	auipc	a5,0x1c
    80002f6e:	17e78793          	addi	a5,a5,382 # 8001f0e8 <bcache+0x8000>
    80002f72:	0001c717          	auipc	a4,0x1c
    80002f76:	3de70713          	addi	a4,a4,990 # 8001f350 <bcache+0x8268>
    80002f7a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f7e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f82:	00014497          	auipc	s1,0x14
    80002f86:	17e48493          	addi	s1,s1,382 # 80017100 <bcache+0x18>
    b->next = bcache.head.next;
    80002f8a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f8c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f8e:	00005a17          	auipc	s4,0x5
    80002f92:	592a0a13          	addi	s4,s4,1426 # 80008520 <syscalls+0xd8>
    b->next = bcache.head.next;
    80002f96:	2b893783          	ld	a5,696(s2)
    80002f9a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f9c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002fa0:	85d2                	mv	a1,s4
    80002fa2:	01048513          	addi	a0,s1,16
    80002fa6:	00001097          	auipc	ra,0x1
    80002faa:	4bc080e7          	jalr	1212(ra) # 80004462 <initsleeplock>
    bcache.head.next->prev = b;
    80002fae:	2b893783          	ld	a5,696(s2)
    80002fb2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002fb4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fb8:	45848493          	addi	s1,s1,1112
    80002fbc:	fd349de3          	bne	s1,s3,80002f96 <binit+0x54>
  }
}
    80002fc0:	70a2                	ld	ra,40(sp)
    80002fc2:	7402                	ld	s0,32(sp)
    80002fc4:	64e2                	ld	s1,24(sp)
    80002fc6:	6942                	ld	s2,16(sp)
    80002fc8:	69a2                	ld	s3,8(sp)
    80002fca:	6a02                	ld	s4,0(sp)
    80002fcc:	6145                	addi	sp,sp,48
    80002fce:	8082                	ret

0000000080002fd0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002fd0:	7179                	addi	sp,sp,-48
    80002fd2:	f406                	sd	ra,40(sp)
    80002fd4:	f022                	sd	s0,32(sp)
    80002fd6:	ec26                	sd	s1,24(sp)
    80002fd8:	e84a                	sd	s2,16(sp)
    80002fda:	e44e                	sd	s3,8(sp)
    80002fdc:	1800                	addi	s0,sp,48
    80002fde:	89aa                	mv	s3,a0
    80002fe0:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002fe2:	00014517          	auipc	a0,0x14
    80002fe6:	10650513          	addi	a0,a0,262 # 800170e8 <bcache>
    80002fea:	ffffe097          	auipc	ra,0xffffe
    80002fee:	bfa080e7          	jalr	-1030(ra) # 80000be4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ff2:	0001c497          	auipc	s1,0x1c
    80002ff6:	3ae4b483          	ld	s1,942(s1) # 8001f3a0 <bcache+0x82b8>
    80002ffa:	0001c797          	auipc	a5,0x1c
    80002ffe:	35678793          	addi	a5,a5,854 # 8001f350 <bcache+0x8268>
    80003002:	02f48f63          	beq	s1,a5,80003040 <bread+0x70>
    80003006:	873e                	mv	a4,a5
    80003008:	a021                	j	80003010 <bread+0x40>
    8000300a:	68a4                	ld	s1,80(s1)
    8000300c:	02e48a63          	beq	s1,a4,80003040 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003010:	449c                	lw	a5,8(s1)
    80003012:	ff379ce3          	bne	a5,s3,8000300a <bread+0x3a>
    80003016:	44dc                	lw	a5,12(s1)
    80003018:	ff2799e3          	bne	a5,s2,8000300a <bread+0x3a>
      b->refcnt++;
    8000301c:	40bc                	lw	a5,64(s1)
    8000301e:	2785                	addiw	a5,a5,1
    80003020:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003022:	00014517          	auipc	a0,0x14
    80003026:	0c650513          	addi	a0,a0,198 # 800170e8 <bcache>
    8000302a:	ffffe097          	auipc	ra,0xffffe
    8000302e:	c6e080e7          	jalr	-914(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    80003032:	01048513          	addi	a0,s1,16
    80003036:	00001097          	auipc	ra,0x1
    8000303a:	466080e7          	jalr	1126(ra) # 8000449c <acquiresleep>
      return b;
    8000303e:	a8b9                	j	8000309c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003040:	0001c497          	auipc	s1,0x1c
    80003044:	3584b483          	ld	s1,856(s1) # 8001f398 <bcache+0x82b0>
    80003048:	0001c797          	auipc	a5,0x1c
    8000304c:	30878793          	addi	a5,a5,776 # 8001f350 <bcache+0x8268>
    80003050:	00f48863          	beq	s1,a5,80003060 <bread+0x90>
    80003054:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003056:	40bc                	lw	a5,64(s1)
    80003058:	cf81                	beqz	a5,80003070 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000305a:	64a4                	ld	s1,72(s1)
    8000305c:	fee49de3          	bne	s1,a4,80003056 <bread+0x86>
  panic("bget: no buffers");
    80003060:	00005517          	auipc	a0,0x5
    80003064:	4c850513          	addi	a0,a0,1224 # 80008528 <syscalls+0xe0>
    80003068:	ffffd097          	auipc	ra,0xffffd
    8000306c:	4d6080e7          	jalr	1238(ra) # 8000053e <panic>
      b->dev = dev;
    80003070:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003074:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003078:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000307c:	4785                	li	a5,1
    8000307e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003080:	00014517          	auipc	a0,0x14
    80003084:	06850513          	addi	a0,a0,104 # 800170e8 <bcache>
    80003088:	ffffe097          	auipc	ra,0xffffe
    8000308c:	c10080e7          	jalr	-1008(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    80003090:	01048513          	addi	a0,s1,16
    80003094:	00001097          	auipc	ra,0x1
    80003098:	408080e7          	jalr	1032(ra) # 8000449c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000309c:	409c                	lw	a5,0(s1)
    8000309e:	cb89                	beqz	a5,800030b0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030a0:	8526                	mv	a0,s1
    800030a2:	70a2                	ld	ra,40(sp)
    800030a4:	7402                	ld	s0,32(sp)
    800030a6:	64e2                	ld	s1,24(sp)
    800030a8:	6942                	ld	s2,16(sp)
    800030aa:	69a2                	ld	s3,8(sp)
    800030ac:	6145                	addi	sp,sp,48
    800030ae:	8082                	ret
    virtio_disk_rw(b, 0);
    800030b0:	4581                	li	a1,0
    800030b2:	8526                	mv	a0,s1
    800030b4:	00003097          	auipc	ra,0x3
    800030b8:	f12080e7          	jalr	-238(ra) # 80005fc6 <virtio_disk_rw>
    b->valid = 1;
    800030bc:	4785                	li	a5,1
    800030be:	c09c                	sw	a5,0(s1)
  return b;
    800030c0:	b7c5                	j	800030a0 <bread+0xd0>

00000000800030c2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030c2:	1101                	addi	sp,sp,-32
    800030c4:	ec06                	sd	ra,24(sp)
    800030c6:	e822                	sd	s0,16(sp)
    800030c8:	e426                	sd	s1,8(sp)
    800030ca:	1000                	addi	s0,sp,32
    800030cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030ce:	0541                	addi	a0,a0,16
    800030d0:	00001097          	auipc	ra,0x1
    800030d4:	466080e7          	jalr	1126(ra) # 80004536 <holdingsleep>
    800030d8:	cd01                	beqz	a0,800030f0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030da:	4585                	li	a1,1
    800030dc:	8526                	mv	a0,s1
    800030de:	00003097          	auipc	ra,0x3
    800030e2:	ee8080e7          	jalr	-280(ra) # 80005fc6 <virtio_disk_rw>
}
    800030e6:	60e2                	ld	ra,24(sp)
    800030e8:	6442                	ld	s0,16(sp)
    800030ea:	64a2                	ld	s1,8(sp)
    800030ec:	6105                	addi	sp,sp,32
    800030ee:	8082                	ret
    panic("bwrite");
    800030f0:	00005517          	auipc	a0,0x5
    800030f4:	45050513          	addi	a0,a0,1104 # 80008540 <syscalls+0xf8>
    800030f8:	ffffd097          	auipc	ra,0xffffd
    800030fc:	446080e7          	jalr	1094(ra) # 8000053e <panic>

0000000080003100 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003100:	1101                	addi	sp,sp,-32
    80003102:	ec06                	sd	ra,24(sp)
    80003104:	e822                	sd	s0,16(sp)
    80003106:	e426                	sd	s1,8(sp)
    80003108:	e04a                	sd	s2,0(sp)
    8000310a:	1000                	addi	s0,sp,32
    8000310c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000310e:	01050913          	addi	s2,a0,16
    80003112:	854a                	mv	a0,s2
    80003114:	00001097          	auipc	ra,0x1
    80003118:	422080e7          	jalr	1058(ra) # 80004536 <holdingsleep>
    8000311c:	c92d                	beqz	a0,8000318e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000311e:	854a                	mv	a0,s2
    80003120:	00001097          	auipc	ra,0x1
    80003124:	3d2080e7          	jalr	978(ra) # 800044f2 <releasesleep>

  acquire(&bcache.lock);
    80003128:	00014517          	auipc	a0,0x14
    8000312c:	fc050513          	addi	a0,a0,-64 # 800170e8 <bcache>
    80003130:	ffffe097          	auipc	ra,0xffffe
    80003134:	ab4080e7          	jalr	-1356(ra) # 80000be4 <acquire>
  b->refcnt--;
    80003138:	40bc                	lw	a5,64(s1)
    8000313a:	37fd                	addiw	a5,a5,-1
    8000313c:	0007871b          	sext.w	a4,a5
    80003140:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003142:	eb05                	bnez	a4,80003172 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003144:	68bc                	ld	a5,80(s1)
    80003146:	64b8                	ld	a4,72(s1)
    80003148:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000314a:	64bc                	ld	a5,72(s1)
    8000314c:	68b8                	ld	a4,80(s1)
    8000314e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003150:	0001c797          	auipc	a5,0x1c
    80003154:	f9878793          	addi	a5,a5,-104 # 8001f0e8 <bcache+0x8000>
    80003158:	2b87b703          	ld	a4,696(a5)
    8000315c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000315e:	0001c717          	auipc	a4,0x1c
    80003162:	1f270713          	addi	a4,a4,498 # 8001f350 <bcache+0x8268>
    80003166:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003168:	2b87b703          	ld	a4,696(a5)
    8000316c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000316e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003172:	00014517          	auipc	a0,0x14
    80003176:	f7650513          	addi	a0,a0,-138 # 800170e8 <bcache>
    8000317a:	ffffe097          	auipc	ra,0xffffe
    8000317e:	b1e080e7          	jalr	-1250(ra) # 80000c98 <release>
}
    80003182:	60e2                	ld	ra,24(sp)
    80003184:	6442                	ld	s0,16(sp)
    80003186:	64a2                	ld	s1,8(sp)
    80003188:	6902                	ld	s2,0(sp)
    8000318a:	6105                	addi	sp,sp,32
    8000318c:	8082                	ret
    panic("brelse");
    8000318e:	00005517          	auipc	a0,0x5
    80003192:	3ba50513          	addi	a0,a0,954 # 80008548 <syscalls+0x100>
    80003196:	ffffd097          	auipc	ra,0xffffd
    8000319a:	3a8080e7          	jalr	936(ra) # 8000053e <panic>

000000008000319e <bpin>:

void
bpin(struct buf *b) {
    8000319e:	1101                	addi	sp,sp,-32
    800031a0:	ec06                	sd	ra,24(sp)
    800031a2:	e822                	sd	s0,16(sp)
    800031a4:	e426                	sd	s1,8(sp)
    800031a6:	1000                	addi	s0,sp,32
    800031a8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031aa:	00014517          	auipc	a0,0x14
    800031ae:	f3e50513          	addi	a0,a0,-194 # 800170e8 <bcache>
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	a32080e7          	jalr	-1486(ra) # 80000be4 <acquire>
  b->refcnt++;
    800031ba:	40bc                	lw	a5,64(s1)
    800031bc:	2785                	addiw	a5,a5,1
    800031be:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031c0:	00014517          	auipc	a0,0x14
    800031c4:	f2850513          	addi	a0,a0,-216 # 800170e8 <bcache>
    800031c8:	ffffe097          	auipc	ra,0xffffe
    800031cc:	ad0080e7          	jalr	-1328(ra) # 80000c98 <release>
}
    800031d0:	60e2                	ld	ra,24(sp)
    800031d2:	6442                	ld	s0,16(sp)
    800031d4:	64a2                	ld	s1,8(sp)
    800031d6:	6105                	addi	sp,sp,32
    800031d8:	8082                	ret

00000000800031da <bunpin>:

void
bunpin(struct buf *b) {
    800031da:	1101                	addi	sp,sp,-32
    800031dc:	ec06                	sd	ra,24(sp)
    800031de:	e822                	sd	s0,16(sp)
    800031e0:	e426                	sd	s1,8(sp)
    800031e2:	1000                	addi	s0,sp,32
    800031e4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031e6:	00014517          	auipc	a0,0x14
    800031ea:	f0250513          	addi	a0,a0,-254 # 800170e8 <bcache>
    800031ee:	ffffe097          	auipc	ra,0xffffe
    800031f2:	9f6080e7          	jalr	-1546(ra) # 80000be4 <acquire>
  b->refcnt--;
    800031f6:	40bc                	lw	a5,64(s1)
    800031f8:	37fd                	addiw	a5,a5,-1
    800031fa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031fc:	00014517          	auipc	a0,0x14
    80003200:	eec50513          	addi	a0,a0,-276 # 800170e8 <bcache>
    80003204:	ffffe097          	auipc	ra,0xffffe
    80003208:	a94080e7          	jalr	-1388(ra) # 80000c98 <release>
}
    8000320c:	60e2                	ld	ra,24(sp)
    8000320e:	6442                	ld	s0,16(sp)
    80003210:	64a2                	ld	s1,8(sp)
    80003212:	6105                	addi	sp,sp,32
    80003214:	8082                	ret

0000000080003216 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003216:	1101                	addi	sp,sp,-32
    80003218:	ec06                	sd	ra,24(sp)
    8000321a:	e822                	sd	s0,16(sp)
    8000321c:	e426                	sd	s1,8(sp)
    8000321e:	e04a                	sd	s2,0(sp)
    80003220:	1000                	addi	s0,sp,32
    80003222:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003224:	00d5d59b          	srliw	a1,a1,0xd
    80003228:	0001c797          	auipc	a5,0x1c
    8000322c:	59c7a783          	lw	a5,1436(a5) # 8001f7c4 <sb+0x1c>
    80003230:	9dbd                	addw	a1,a1,a5
    80003232:	00000097          	auipc	ra,0x0
    80003236:	d9e080e7          	jalr	-610(ra) # 80002fd0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000323a:	0074f713          	andi	a4,s1,7
    8000323e:	4785                	li	a5,1
    80003240:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003244:	14ce                	slli	s1,s1,0x33
    80003246:	90d9                	srli	s1,s1,0x36
    80003248:	00950733          	add	a4,a0,s1
    8000324c:	05874703          	lbu	a4,88(a4)
    80003250:	00e7f6b3          	and	a3,a5,a4
    80003254:	c69d                	beqz	a3,80003282 <bfree+0x6c>
    80003256:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003258:	94aa                	add	s1,s1,a0
    8000325a:	fff7c793          	not	a5,a5
    8000325e:	8ff9                	and	a5,a5,a4
    80003260:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003264:	00001097          	auipc	ra,0x1
    80003268:	118080e7          	jalr	280(ra) # 8000437c <log_write>
  brelse(bp);
    8000326c:	854a                	mv	a0,s2
    8000326e:	00000097          	auipc	ra,0x0
    80003272:	e92080e7          	jalr	-366(ra) # 80003100 <brelse>
}
    80003276:	60e2                	ld	ra,24(sp)
    80003278:	6442                	ld	s0,16(sp)
    8000327a:	64a2                	ld	s1,8(sp)
    8000327c:	6902                	ld	s2,0(sp)
    8000327e:	6105                	addi	sp,sp,32
    80003280:	8082                	ret
    panic("freeing free block");
    80003282:	00005517          	auipc	a0,0x5
    80003286:	2ce50513          	addi	a0,a0,718 # 80008550 <syscalls+0x108>
    8000328a:	ffffd097          	auipc	ra,0xffffd
    8000328e:	2b4080e7          	jalr	692(ra) # 8000053e <panic>

0000000080003292 <balloc>:
{
    80003292:	711d                	addi	sp,sp,-96
    80003294:	ec86                	sd	ra,88(sp)
    80003296:	e8a2                	sd	s0,80(sp)
    80003298:	e4a6                	sd	s1,72(sp)
    8000329a:	e0ca                	sd	s2,64(sp)
    8000329c:	fc4e                	sd	s3,56(sp)
    8000329e:	f852                	sd	s4,48(sp)
    800032a0:	f456                	sd	s5,40(sp)
    800032a2:	f05a                	sd	s6,32(sp)
    800032a4:	ec5e                	sd	s7,24(sp)
    800032a6:	e862                	sd	s8,16(sp)
    800032a8:	e466                	sd	s9,8(sp)
    800032aa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032ac:	0001c797          	auipc	a5,0x1c
    800032b0:	5007a783          	lw	a5,1280(a5) # 8001f7ac <sb+0x4>
    800032b4:	cbd1                	beqz	a5,80003348 <balloc+0xb6>
    800032b6:	8baa                	mv	s7,a0
    800032b8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032ba:	0001cb17          	auipc	s6,0x1c
    800032be:	4eeb0b13          	addi	s6,s6,1262 # 8001f7a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800032c4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032c8:	6c89                	lui	s9,0x2
    800032ca:	a831                	j	800032e6 <balloc+0x54>
    brelse(bp);
    800032cc:	854a                	mv	a0,s2
    800032ce:	00000097          	auipc	ra,0x0
    800032d2:	e32080e7          	jalr	-462(ra) # 80003100 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032d6:	015c87bb          	addw	a5,s9,s5
    800032da:	00078a9b          	sext.w	s5,a5
    800032de:	004b2703          	lw	a4,4(s6)
    800032e2:	06eaf363          	bgeu	s5,a4,80003348 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800032e6:	41fad79b          	sraiw	a5,s5,0x1f
    800032ea:	0137d79b          	srliw	a5,a5,0x13
    800032ee:	015787bb          	addw	a5,a5,s5
    800032f2:	40d7d79b          	sraiw	a5,a5,0xd
    800032f6:	01cb2583          	lw	a1,28(s6)
    800032fa:	9dbd                	addw	a1,a1,a5
    800032fc:	855e                	mv	a0,s7
    800032fe:	00000097          	auipc	ra,0x0
    80003302:	cd2080e7          	jalr	-814(ra) # 80002fd0 <bread>
    80003306:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003308:	004b2503          	lw	a0,4(s6)
    8000330c:	000a849b          	sext.w	s1,s5
    80003310:	8662                	mv	a2,s8
    80003312:	faa4fde3          	bgeu	s1,a0,800032cc <balloc+0x3a>
      m = 1 << (bi % 8);
    80003316:	41f6579b          	sraiw	a5,a2,0x1f
    8000331a:	01d7d69b          	srliw	a3,a5,0x1d
    8000331e:	00c6873b          	addw	a4,a3,a2
    80003322:	00777793          	andi	a5,a4,7
    80003326:	9f95                	subw	a5,a5,a3
    80003328:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000332c:	4037571b          	sraiw	a4,a4,0x3
    80003330:	00e906b3          	add	a3,s2,a4
    80003334:	0586c683          	lbu	a3,88(a3)
    80003338:	00d7f5b3          	and	a1,a5,a3
    8000333c:	cd91                	beqz	a1,80003358 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000333e:	2605                	addiw	a2,a2,1
    80003340:	2485                	addiw	s1,s1,1
    80003342:	fd4618e3          	bne	a2,s4,80003312 <balloc+0x80>
    80003346:	b759                	j	800032cc <balloc+0x3a>
  panic("balloc: out of blocks");
    80003348:	00005517          	auipc	a0,0x5
    8000334c:	22050513          	addi	a0,a0,544 # 80008568 <syscalls+0x120>
    80003350:	ffffd097          	auipc	ra,0xffffd
    80003354:	1ee080e7          	jalr	494(ra) # 8000053e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003358:	974a                	add	a4,a4,s2
    8000335a:	8fd5                	or	a5,a5,a3
    8000335c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003360:	854a                	mv	a0,s2
    80003362:	00001097          	auipc	ra,0x1
    80003366:	01a080e7          	jalr	26(ra) # 8000437c <log_write>
        brelse(bp);
    8000336a:	854a                	mv	a0,s2
    8000336c:	00000097          	auipc	ra,0x0
    80003370:	d94080e7          	jalr	-620(ra) # 80003100 <brelse>
  bp = bread(dev, bno);
    80003374:	85a6                	mv	a1,s1
    80003376:	855e                	mv	a0,s7
    80003378:	00000097          	auipc	ra,0x0
    8000337c:	c58080e7          	jalr	-936(ra) # 80002fd0 <bread>
    80003380:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003382:	40000613          	li	a2,1024
    80003386:	4581                	li	a1,0
    80003388:	05850513          	addi	a0,a0,88
    8000338c:	ffffe097          	auipc	ra,0xffffe
    80003390:	954080e7          	jalr	-1708(ra) # 80000ce0 <memset>
  log_write(bp);
    80003394:	854a                	mv	a0,s2
    80003396:	00001097          	auipc	ra,0x1
    8000339a:	fe6080e7          	jalr	-26(ra) # 8000437c <log_write>
  brelse(bp);
    8000339e:	854a                	mv	a0,s2
    800033a0:	00000097          	auipc	ra,0x0
    800033a4:	d60080e7          	jalr	-672(ra) # 80003100 <brelse>
}
    800033a8:	8526                	mv	a0,s1
    800033aa:	60e6                	ld	ra,88(sp)
    800033ac:	6446                	ld	s0,80(sp)
    800033ae:	64a6                	ld	s1,72(sp)
    800033b0:	6906                	ld	s2,64(sp)
    800033b2:	79e2                	ld	s3,56(sp)
    800033b4:	7a42                	ld	s4,48(sp)
    800033b6:	7aa2                	ld	s5,40(sp)
    800033b8:	7b02                	ld	s6,32(sp)
    800033ba:	6be2                	ld	s7,24(sp)
    800033bc:	6c42                	ld	s8,16(sp)
    800033be:	6ca2                	ld	s9,8(sp)
    800033c0:	6125                	addi	sp,sp,96
    800033c2:	8082                	ret

00000000800033c4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800033c4:	7179                	addi	sp,sp,-48
    800033c6:	f406                	sd	ra,40(sp)
    800033c8:	f022                	sd	s0,32(sp)
    800033ca:	ec26                	sd	s1,24(sp)
    800033cc:	e84a                	sd	s2,16(sp)
    800033ce:	e44e                	sd	s3,8(sp)
    800033d0:	e052                	sd	s4,0(sp)
    800033d2:	1800                	addi	s0,sp,48
    800033d4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033d6:	47ad                	li	a5,11
    800033d8:	04b7fe63          	bgeu	a5,a1,80003434 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800033dc:	ff45849b          	addiw	s1,a1,-12
    800033e0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033e4:	0ff00793          	li	a5,255
    800033e8:	0ae7e363          	bltu	a5,a4,8000348e <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800033ec:	08052583          	lw	a1,128(a0)
    800033f0:	c5ad                	beqz	a1,8000345a <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800033f2:	00092503          	lw	a0,0(s2)
    800033f6:	00000097          	auipc	ra,0x0
    800033fa:	bda080e7          	jalr	-1062(ra) # 80002fd0 <bread>
    800033fe:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003400:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003404:	02049593          	slli	a1,s1,0x20
    80003408:	9181                	srli	a1,a1,0x20
    8000340a:	058a                	slli	a1,a1,0x2
    8000340c:	00b784b3          	add	s1,a5,a1
    80003410:	0004a983          	lw	s3,0(s1)
    80003414:	04098d63          	beqz	s3,8000346e <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003418:	8552                	mv	a0,s4
    8000341a:	00000097          	auipc	ra,0x0
    8000341e:	ce6080e7          	jalr	-794(ra) # 80003100 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003422:	854e                	mv	a0,s3
    80003424:	70a2                	ld	ra,40(sp)
    80003426:	7402                	ld	s0,32(sp)
    80003428:	64e2                	ld	s1,24(sp)
    8000342a:	6942                	ld	s2,16(sp)
    8000342c:	69a2                	ld	s3,8(sp)
    8000342e:	6a02                	ld	s4,0(sp)
    80003430:	6145                	addi	sp,sp,48
    80003432:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003434:	02059493          	slli	s1,a1,0x20
    80003438:	9081                	srli	s1,s1,0x20
    8000343a:	048a                	slli	s1,s1,0x2
    8000343c:	94aa                	add	s1,s1,a0
    8000343e:	0504a983          	lw	s3,80(s1)
    80003442:	fe0990e3          	bnez	s3,80003422 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003446:	4108                	lw	a0,0(a0)
    80003448:	00000097          	auipc	ra,0x0
    8000344c:	e4a080e7          	jalr	-438(ra) # 80003292 <balloc>
    80003450:	0005099b          	sext.w	s3,a0
    80003454:	0534a823          	sw	s3,80(s1)
    80003458:	b7e9                	j	80003422 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000345a:	4108                	lw	a0,0(a0)
    8000345c:	00000097          	auipc	ra,0x0
    80003460:	e36080e7          	jalr	-458(ra) # 80003292 <balloc>
    80003464:	0005059b          	sext.w	a1,a0
    80003468:	08b92023          	sw	a1,128(s2)
    8000346c:	b759                	j	800033f2 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000346e:	00092503          	lw	a0,0(s2)
    80003472:	00000097          	auipc	ra,0x0
    80003476:	e20080e7          	jalr	-480(ra) # 80003292 <balloc>
    8000347a:	0005099b          	sext.w	s3,a0
    8000347e:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003482:	8552                	mv	a0,s4
    80003484:	00001097          	auipc	ra,0x1
    80003488:	ef8080e7          	jalr	-264(ra) # 8000437c <log_write>
    8000348c:	b771                	j	80003418 <bmap+0x54>
  panic("bmap: out of range");
    8000348e:	00005517          	auipc	a0,0x5
    80003492:	0f250513          	addi	a0,a0,242 # 80008580 <syscalls+0x138>
    80003496:	ffffd097          	auipc	ra,0xffffd
    8000349a:	0a8080e7          	jalr	168(ra) # 8000053e <panic>

000000008000349e <iget>:
{
    8000349e:	7179                	addi	sp,sp,-48
    800034a0:	f406                	sd	ra,40(sp)
    800034a2:	f022                	sd	s0,32(sp)
    800034a4:	ec26                	sd	s1,24(sp)
    800034a6:	e84a                	sd	s2,16(sp)
    800034a8:	e44e                	sd	s3,8(sp)
    800034aa:	e052                	sd	s4,0(sp)
    800034ac:	1800                	addi	s0,sp,48
    800034ae:	89aa                	mv	s3,a0
    800034b0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800034b2:	0001c517          	auipc	a0,0x1c
    800034b6:	31650513          	addi	a0,a0,790 # 8001f7c8 <itable>
    800034ba:	ffffd097          	auipc	ra,0xffffd
    800034be:	72a080e7          	jalr	1834(ra) # 80000be4 <acquire>
  empty = 0;
    800034c2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034c4:	0001c497          	auipc	s1,0x1c
    800034c8:	31c48493          	addi	s1,s1,796 # 8001f7e0 <itable+0x18>
    800034cc:	0001e697          	auipc	a3,0x1e
    800034d0:	da468693          	addi	a3,a3,-604 # 80021270 <log>
    800034d4:	a039                	j	800034e2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034d6:	02090b63          	beqz	s2,8000350c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034da:	08848493          	addi	s1,s1,136
    800034de:	02d48a63          	beq	s1,a3,80003512 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034e2:	449c                	lw	a5,8(s1)
    800034e4:	fef059e3          	blez	a5,800034d6 <iget+0x38>
    800034e8:	4098                	lw	a4,0(s1)
    800034ea:	ff3716e3          	bne	a4,s3,800034d6 <iget+0x38>
    800034ee:	40d8                	lw	a4,4(s1)
    800034f0:	ff4713e3          	bne	a4,s4,800034d6 <iget+0x38>
      ip->ref++;
    800034f4:	2785                	addiw	a5,a5,1
    800034f6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034f8:	0001c517          	auipc	a0,0x1c
    800034fc:	2d050513          	addi	a0,a0,720 # 8001f7c8 <itable>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	798080e7          	jalr	1944(ra) # 80000c98 <release>
      return ip;
    80003508:	8926                	mv	s2,s1
    8000350a:	a03d                	j	80003538 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000350c:	f7f9                	bnez	a5,800034da <iget+0x3c>
    8000350e:	8926                	mv	s2,s1
    80003510:	b7e9                	j	800034da <iget+0x3c>
  if(empty == 0)
    80003512:	02090c63          	beqz	s2,8000354a <iget+0xac>
  ip->dev = dev;
    80003516:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000351a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000351e:	4785                	li	a5,1
    80003520:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003524:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003528:	0001c517          	auipc	a0,0x1c
    8000352c:	2a050513          	addi	a0,a0,672 # 8001f7c8 <itable>
    80003530:	ffffd097          	auipc	ra,0xffffd
    80003534:	768080e7          	jalr	1896(ra) # 80000c98 <release>
}
    80003538:	854a                	mv	a0,s2
    8000353a:	70a2                	ld	ra,40(sp)
    8000353c:	7402                	ld	s0,32(sp)
    8000353e:	64e2                	ld	s1,24(sp)
    80003540:	6942                	ld	s2,16(sp)
    80003542:	69a2                	ld	s3,8(sp)
    80003544:	6a02                	ld	s4,0(sp)
    80003546:	6145                	addi	sp,sp,48
    80003548:	8082                	ret
    panic("iget: no inodes");
    8000354a:	00005517          	auipc	a0,0x5
    8000354e:	04e50513          	addi	a0,a0,78 # 80008598 <syscalls+0x150>
    80003552:	ffffd097          	auipc	ra,0xffffd
    80003556:	fec080e7          	jalr	-20(ra) # 8000053e <panic>

000000008000355a <fsinit>:
fsinit(int dev) {
    8000355a:	7179                	addi	sp,sp,-48
    8000355c:	f406                	sd	ra,40(sp)
    8000355e:	f022                	sd	s0,32(sp)
    80003560:	ec26                	sd	s1,24(sp)
    80003562:	e84a                	sd	s2,16(sp)
    80003564:	e44e                	sd	s3,8(sp)
    80003566:	1800                	addi	s0,sp,48
    80003568:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000356a:	4585                	li	a1,1
    8000356c:	00000097          	auipc	ra,0x0
    80003570:	a64080e7          	jalr	-1436(ra) # 80002fd0 <bread>
    80003574:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003576:	0001c997          	auipc	s3,0x1c
    8000357a:	23298993          	addi	s3,s3,562 # 8001f7a8 <sb>
    8000357e:	02000613          	li	a2,32
    80003582:	05850593          	addi	a1,a0,88
    80003586:	854e                	mv	a0,s3
    80003588:	ffffd097          	auipc	ra,0xffffd
    8000358c:	7b8080e7          	jalr	1976(ra) # 80000d40 <memmove>
  brelse(bp);
    80003590:	8526                	mv	a0,s1
    80003592:	00000097          	auipc	ra,0x0
    80003596:	b6e080e7          	jalr	-1170(ra) # 80003100 <brelse>
  if(sb.magic != FSMAGIC)
    8000359a:	0009a703          	lw	a4,0(s3)
    8000359e:	102037b7          	lui	a5,0x10203
    800035a2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035a6:	02f71263          	bne	a4,a5,800035ca <fsinit+0x70>
  initlog(dev, &sb);
    800035aa:	0001c597          	auipc	a1,0x1c
    800035ae:	1fe58593          	addi	a1,a1,510 # 8001f7a8 <sb>
    800035b2:	854a                	mv	a0,s2
    800035b4:	00001097          	auipc	ra,0x1
    800035b8:	b4c080e7          	jalr	-1204(ra) # 80004100 <initlog>
}
    800035bc:	70a2                	ld	ra,40(sp)
    800035be:	7402                	ld	s0,32(sp)
    800035c0:	64e2                	ld	s1,24(sp)
    800035c2:	6942                	ld	s2,16(sp)
    800035c4:	69a2                	ld	s3,8(sp)
    800035c6:	6145                	addi	sp,sp,48
    800035c8:	8082                	ret
    panic("invalid file system");
    800035ca:	00005517          	auipc	a0,0x5
    800035ce:	fde50513          	addi	a0,a0,-34 # 800085a8 <syscalls+0x160>
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	f6c080e7          	jalr	-148(ra) # 8000053e <panic>

00000000800035da <iinit>:
{
    800035da:	7179                	addi	sp,sp,-48
    800035dc:	f406                	sd	ra,40(sp)
    800035de:	f022                	sd	s0,32(sp)
    800035e0:	ec26                	sd	s1,24(sp)
    800035e2:	e84a                	sd	s2,16(sp)
    800035e4:	e44e                	sd	s3,8(sp)
    800035e6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800035e8:	00005597          	auipc	a1,0x5
    800035ec:	fd858593          	addi	a1,a1,-40 # 800085c0 <syscalls+0x178>
    800035f0:	0001c517          	auipc	a0,0x1c
    800035f4:	1d850513          	addi	a0,a0,472 # 8001f7c8 <itable>
    800035f8:	ffffd097          	auipc	ra,0xffffd
    800035fc:	55c080e7          	jalr	1372(ra) # 80000b54 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003600:	0001c497          	auipc	s1,0x1c
    80003604:	1f048493          	addi	s1,s1,496 # 8001f7f0 <itable+0x28>
    80003608:	0001e997          	auipc	s3,0x1e
    8000360c:	c7898993          	addi	s3,s3,-904 # 80021280 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003610:	00005917          	auipc	s2,0x5
    80003614:	fb890913          	addi	s2,s2,-72 # 800085c8 <syscalls+0x180>
    80003618:	85ca                	mv	a1,s2
    8000361a:	8526                	mv	a0,s1
    8000361c:	00001097          	auipc	ra,0x1
    80003620:	e46080e7          	jalr	-442(ra) # 80004462 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003624:	08848493          	addi	s1,s1,136
    80003628:	ff3498e3          	bne	s1,s3,80003618 <iinit+0x3e>
}
    8000362c:	70a2                	ld	ra,40(sp)
    8000362e:	7402                	ld	s0,32(sp)
    80003630:	64e2                	ld	s1,24(sp)
    80003632:	6942                	ld	s2,16(sp)
    80003634:	69a2                	ld	s3,8(sp)
    80003636:	6145                	addi	sp,sp,48
    80003638:	8082                	ret

000000008000363a <ialloc>:
{
    8000363a:	715d                	addi	sp,sp,-80
    8000363c:	e486                	sd	ra,72(sp)
    8000363e:	e0a2                	sd	s0,64(sp)
    80003640:	fc26                	sd	s1,56(sp)
    80003642:	f84a                	sd	s2,48(sp)
    80003644:	f44e                	sd	s3,40(sp)
    80003646:	f052                	sd	s4,32(sp)
    80003648:	ec56                	sd	s5,24(sp)
    8000364a:	e85a                	sd	s6,16(sp)
    8000364c:	e45e                	sd	s7,8(sp)
    8000364e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003650:	0001c717          	auipc	a4,0x1c
    80003654:	16472703          	lw	a4,356(a4) # 8001f7b4 <sb+0xc>
    80003658:	4785                	li	a5,1
    8000365a:	04e7fa63          	bgeu	a5,a4,800036ae <ialloc+0x74>
    8000365e:	8aaa                	mv	s5,a0
    80003660:	8bae                	mv	s7,a1
    80003662:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003664:	0001ca17          	auipc	s4,0x1c
    80003668:	144a0a13          	addi	s4,s4,324 # 8001f7a8 <sb>
    8000366c:	00048b1b          	sext.w	s6,s1
    80003670:	0044d593          	srli	a1,s1,0x4
    80003674:	018a2783          	lw	a5,24(s4)
    80003678:	9dbd                	addw	a1,a1,a5
    8000367a:	8556                	mv	a0,s5
    8000367c:	00000097          	auipc	ra,0x0
    80003680:	954080e7          	jalr	-1708(ra) # 80002fd0 <bread>
    80003684:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003686:	05850993          	addi	s3,a0,88
    8000368a:	00f4f793          	andi	a5,s1,15
    8000368e:	079a                	slli	a5,a5,0x6
    80003690:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003692:	00099783          	lh	a5,0(s3)
    80003696:	c785                	beqz	a5,800036be <ialloc+0x84>
    brelse(bp);
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	a68080e7          	jalr	-1432(ra) # 80003100 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036a0:	0485                	addi	s1,s1,1
    800036a2:	00ca2703          	lw	a4,12(s4)
    800036a6:	0004879b          	sext.w	a5,s1
    800036aa:	fce7e1e3          	bltu	a5,a4,8000366c <ialloc+0x32>
  panic("ialloc: no inodes");
    800036ae:	00005517          	auipc	a0,0x5
    800036b2:	f2250513          	addi	a0,a0,-222 # 800085d0 <syscalls+0x188>
    800036b6:	ffffd097          	auipc	ra,0xffffd
    800036ba:	e88080e7          	jalr	-376(ra) # 8000053e <panic>
      memset(dip, 0, sizeof(*dip));
    800036be:	04000613          	li	a2,64
    800036c2:	4581                	li	a1,0
    800036c4:	854e                	mv	a0,s3
    800036c6:	ffffd097          	auipc	ra,0xffffd
    800036ca:	61a080e7          	jalr	1562(ra) # 80000ce0 <memset>
      dip->type = type;
    800036ce:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036d2:	854a                	mv	a0,s2
    800036d4:	00001097          	auipc	ra,0x1
    800036d8:	ca8080e7          	jalr	-856(ra) # 8000437c <log_write>
      brelse(bp);
    800036dc:	854a                	mv	a0,s2
    800036de:	00000097          	auipc	ra,0x0
    800036e2:	a22080e7          	jalr	-1502(ra) # 80003100 <brelse>
      return iget(dev, inum);
    800036e6:	85da                	mv	a1,s6
    800036e8:	8556                	mv	a0,s5
    800036ea:	00000097          	auipc	ra,0x0
    800036ee:	db4080e7          	jalr	-588(ra) # 8000349e <iget>
}
    800036f2:	60a6                	ld	ra,72(sp)
    800036f4:	6406                	ld	s0,64(sp)
    800036f6:	74e2                	ld	s1,56(sp)
    800036f8:	7942                	ld	s2,48(sp)
    800036fa:	79a2                	ld	s3,40(sp)
    800036fc:	7a02                	ld	s4,32(sp)
    800036fe:	6ae2                	ld	s5,24(sp)
    80003700:	6b42                	ld	s6,16(sp)
    80003702:	6ba2                	ld	s7,8(sp)
    80003704:	6161                	addi	sp,sp,80
    80003706:	8082                	ret

0000000080003708 <iupdate>:
{
    80003708:	1101                	addi	sp,sp,-32
    8000370a:	ec06                	sd	ra,24(sp)
    8000370c:	e822                	sd	s0,16(sp)
    8000370e:	e426                	sd	s1,8(sp)
    80003710:	e04a                	sd	s2,0(sp)
    80003712:	1000                	addi	s0,sp,32
    80003714:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003716:	415c                	lw	a5,4(a0)
    80003718:	0047d79b          	srliw	a5,a5,0x4
    8000371c:	0001c597          	auipc	a1,0x1c
    80003720:	0a45a583          	lw	a1,164(a1) # 8001f7c0 <sb+0x18>
    80003724:	9dbd                	addw	a1,a1,a5
    80003726:	4108                	lw	a0,0(a0)
    80003728:	00000097          	auipc	ra,0x0
    8000372c:	8a8080e7          	jalr	-1880(ra) # 80002fd0 <bread>
    80003730:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003732:	05850793          	addi	a5,a0,88
    80003736:	40c8                	lw	a0,4(s1)
    80003738:	893d                	andi	a0,a0,15
    8000373a:	051a                	slli	a0,a0,0x6
    8000373c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000373e:	04449703          	lh	a4,68(s1)
    80003742:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003746:	04649703          	lh	a4,70(s1)
    8000374a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000374e:	04849703          	lh	a4,72(s1)
    80003752:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003756:	04a49703          	lh	a4,74(s1)
    8000375a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000375e:	44f8                	lw	a4,76(s1)
    80003760:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003762:	03400613          	li	a2,52
    80003766:	05048593          	addi	a1,s1,80
    8000376a:	0531                	addi	a0,a0,12
    8000376c:	ffffd097          	auipc	ra,0xffffd
    80003770:	5d4080e7          	jalr	1492(ra) # 80000d40 <memmove>
  log_write(bp);
    80003774:	854a                	mv	a0,s2
    80003776:	00001097          	auipc	ra,0x1
    8000377a:	c06080e7          	jalr	-1018(ra) # 8000437c <log_write>
  brelse(bp);
    8000377e:	854a                	mv	a0,s2
    80003780:	00000097          	auipc	ra,0x0
    80003784:	980080e7          	jalr	-1664(ra) # 80003100 <brelse>
}
    80003788:	60e2                	ld	ra,24(sp)
    8000378a:	6442                	ld	s0,16(sp)
    8000378c:	64a2                	ld	s1,8(sp)
    8000378e:	6902                	ld	s2,0(sp)
    80003790:	6105                	addi	sp,sp,32
    80003792:	8082                	ret

0000000080003794 <idup>:
{
    80003794:	1101                	addi	sp,sp,-32
    80003796:	ec06                	sd	ra,24(sp)
    80003798:	e822                	sd	s0,16(sp)
    8000379a:	e426                	sd	s1,8(sp)
    8000379c:	1000                	addi	s0,sp,32
    8000379e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037a0:	0001c517          	auipc	a0,0x1c
    800037a4:	02850513          	addi	a0,a0,40 # 8001f7c8 <itable>
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	43c080e7          	jalr	1084(ra) # 80000be4 <acquire>
  ip->ref++;
    800037b0:	449c                	lw	a5,8(s1)
    800037b2:	2785                	addiw	a5,a5,1
    800037b4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037b6:	0001c517          	auipc	a0,0x1c
    800037ba:	01250513          	addi	a0,a0,18 # 8001f7c8 <itable>
    800037be:	ffffd097          	auipc	ra,0xffffd
    800037c2:	4da080e7          	jalr	1242(ra) # 80000c98 <release>
}
    800037c6:	8526                	mv	a0,s1
    800037c8:	60e2                	ld	ra,24(sp)
    800037ca:	6442                	ld	s0,16(sp)
    800037cc:	64a2                	ld	s1,8(sp)
    800037ce:	6105                	addi	sp,sp,32
    800037d0:	8082                	ret

00000000800037d2 <ilock>:
{
    800037d2:	1101                	addi	sp,sp,-32
    800037d4:	ec06                	sd	ra,24(sp)
    800037d6:	e822                	sd	s0,16(sp)
    800037d8:	e426                	sd	s1,8(sp)
    800037da:	e04a                	sd	s2,0(sp)
    800037dc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037de:	c115                	beqz	a0,80003802 <ilock+0x30>
    800037e0:	84aa                	mv	s1,a0
    800037e2:	451c                	lw	a5,8(a0)
    800037e4:	00f05f63          	blez	a5,80003802 <ilock+0x30>
  acquiresleep(&ip->lock);
    800037e8:	0541                	addi	a0,a0,16
    800037ea:	00001097          	auipc	ra,0x1
    800037ee:	cb2080e7          	jalr	-846(ra) # 8000449c <acquiresleep>
  if(ip->valid == 0){
    800037f2:	40bc                	lw	a5,64(s1)
    800037f4:	cf99                	beqz	a5,80003812 <ilock+0x40>
}
    800037f6:	60e2                	ld	ra,24(sp)
    800037f8:	6442                	ld	s0,16(sp)
    800037fa:	64a2                	ld	s1,8(sp)
    800037fc:	6902                	ld	s2,0(sp)
    800037fe:	6105                	addi	sp,sp,32
    80003800:	8082                	ret
    panic("ilock");
    80003802:	00005517          	auipc	a0,0x5
    80003806:	de650513          	addi	a0,a0,-538 # 800085e8 <syscalls+0x1a0>
    8000380a:	ffffd097          	auipc	ra,0xffffd
    8000380e:	d34080e7          	jalr	-716(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003812:	40dc                	lw	a5,4(s1)
    80003814:	0047d79b          	srliw	a5,a5,0x4
    80003818:	0001c597          	auipc	a1,0x1c
    8000381c:	fa85a583          	lw	a1,-88(a1) # 8001f7c0 <sb+0x18>
    80003820:	9dbd                	addw	a1,a1,a5
    80003822:	4088                	lw	a0,0(s1)
    80003824:	fffff097          	auipc	ra,0xfffff
    80003828:	7ac080e7          	jalr	1964(ra) # 80002fd0 <bread>
    8000382c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000382e:	05850593          	addi	a1,a0,88
    80003832:	40dc                	lw	a5,4(s1)
    80003834:	8bbd                	andi	a5,a5,15
    80003836:	079a                	slli	a5,a5,0x6
    80003838:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000383a:	00059783          	lh	a5,0(a1)
    8000383e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003842:	00259783          	lh	a5,2(a1)
    80003846:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000384a:	00459783          	lh	a5,4(a1)
    8000384e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003852:	00659783          	lh	a5,6(a1)
    80003856:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000385a:	459c                	lw	a5,8(a1)
    8000385c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000385e:	03400613          	li	a2,52
    80003862:	05b1                	addi	a1,a1,12
    80003864:	05048513          	addi	a0,s1,80
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	4d8080e7          	jalr	1240(ra) # 80000d40 <memmove>
    brelse(bp);
    80003870:	854a                	mv	a0,s2
    80003872:	00000097          	auipc	ra,0x0
    80003876:	88e080e7          	jalr	-1906(ra) # 80003100 <brelse>
    ip->valid = 1;
    8000387a:	4785                	li	a5,1
    8000387c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000387e:	04449783          	lh	a5,68(s1)
    80003882:	fbb5                	bnez	a5,800037f6 <ilock+0x24>
      panic("ilock: no type");
    80003884:	00005517          	auipc	a0,0x5
    80003888:	d6c50513          	addi	a0,a0,-660 # 800085f0 <syscalls+0x1a8>
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	cb2080e7          	jalr	-846(ra) # 8000053e <panic>

0000000080003894 <iunlock>:
{
    80003894:	1101                	addi	sp,sp,-32
    80003896:	ec06                	sd	ra,24(sp)
    80003898:	e822                	sd	s0,16(sp)
    8000389a:	e426                	sd	s1,8(sp)
    8000389c:	e04a                	sd	s2,0(sp)
    8000389e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038a0:	c905                	beqz	a0,800038d0 <iunlock+0x3c>
    800038a2:	84aa                	mv	s1,a0
    800038a4:	01050913          	addi	s2,a0,16
    800038a8:	854a                	mv	a0,s2
    800038aa:	00001097          	auipc	ra,0x1
    800038ae:	c8c080e7          	jalr	-884(ra) # 80004536 <holdingsleep>
    800038b2:	cd19                	beqz	a0,800038d0 <iunlock+0x3c>
    800038b4:	449c                	lw	a5,8(s1)
    800038b6:	00f05d63          	blez	a5,800038d0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800038ba:	854a                	mv	a0,s2
    800038bc:	00001097          	auipc	ra,0x1
    800038c0:	c36080e7          	jalr	-970(ra) # 800044f2 <releasesleep>
}
    800038c4:	60e2                	ld	ra,24(sp)
    800038c6:	6442                	ld	s0,16(sp)
    800038c8:	64a2                	ld	s1,8(sp)
    800038ca:	6902                	ld	s2,0(sp)
    800038cc:	6105                	addi	sp,sp,32
    800038ce:	8082                	ret
    panic("iunlock");
    800038d0:	00005517          	auipc	a0,0x5
    800038d4:	d3050513          	addi	a0,a0,-720 # 80008600 <syscalls+0x1b8>
    800038d8:	ffffd097          	auipc	ra,0xffffd
    800038dc:	c66080e7          	jalr	-922(ra) # 8000053e <panic>

00000000800038e0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038e0:	7179                	addi	sp,sp,-48
    800038e2:	f406                	sd	ra,40(sp)
    800038e4:	f022                	sd	s0,32(sp)
    800038e6:	ec26                	sd	s1,24(sp)
    800038e8:	e84a                	sd	s2,16(sp)
    800038ea:	e44e                	sd	s3,8(sp)
    800038ec:	e052                	sd	s4,0(sp)
    800038ee:	1800                	addi	s0,sp,48
    800038f0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038f2:	05050493          	addi	s1,a0,80
    800038f6:	08050913          	addi	s2,a0,128
    800038fa:	a021                	j	80003902 <itrunc+0x22>
    800038fc:	0491                	addi	s1,s1,4
    800038fe:	01248d63          	beq	s1,s2,80003918 <itrunc+0x38>
    if(ip->addrs[i]){
    80003902:	408c                	lw	a1,0(s1)
    80003904:	dde5                	beqz	a1,800038fc <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003906:	0009a503          	lw	a0,0(s3)
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	90c080e7          	jalr	-1780(ra) # 80003216 <bfree>
      ip->addrs[i] = 0;
    80003912:	0004a023          	sw	zero,0(s1)
    80003916:	b7dd                	j	800038fc <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003918:	0809a583          	lw	a1,128(s3)
    8000391c:	e185                	bnez	a1,8000393c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000391e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003922:	854e                	mv	a0,s3
    80003924:	00000097          	auipc	ra,0x0
    80003928:	de4080e7          	jalr	-540(ra) # 80003708 <iupdate>
}
    8000392c:	70a2                	ld	ra,40(sp)
    8000392e:	7402                	ld	s0,32(sp)
    80003930:	64e2                	ld	s1,24(sp)
    80003932:	6942                	ld	s2,16(sp)
    80003934:	69a2                	ld	s3,8(sp)
    80003936:	6a02                	ld	s4,0(sp)
    80003938:	6145                	addi	sp,sp,48
    8000393a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000393c:	0009a503          	lw	a0,0(s3)
    80003940:	fffff097          	auipc	ra,0xfffff
    80003944:	690080e7          	jalr	1680(ra) # 80002fd0 <bread>
    80003948:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000394a:	05850493          	addi	s1,a0,88
    8000394e:	45850913          	addi	s2,a0,1112
    80003952:	a811                	j	80003966 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003954:	0009a503          	lw	a0,0(s3)
    80003958:	00000097          	auipc	ra,0x0
    8000395c:	8be080e7          	jalr	-1858(ra) # 80003216 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003960:	0491                	addi	s1,s1,4
    80003962:	01248563          	beq	s1,s2,8000396c <itrunc+0x8c>
      if(a[j])
    80003966:	408c                	lw	a1,0(s1)
    80003968:	dde5                	beqz	a1,80003960 <itrunc+0x80>
    8000396a:	b7ed                	j	80003954 <itrunc+0x74>
    brelse(bp);
    8000396c:	8552                	mv	a0,s4
    8000396e:	fffff097          	auipc	ra,0xfffff
    80003972:	792080e7          	jalr	1938(ra) # 80003100 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003976:	0809a583          	lw	a1,128(s3)
    8000397a:	0009a503          	lw	a0,0(s3)
    8000397e:	00000097          	auipc	ra,0x0
    80003982:	898080e7          	jalr	-1896(ra) # 80003216 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003986:	0809a023          	sw	zero,128(s3)
    8000398a:	bf51                	j	8000391e <itrunc+0x3e>

000000008000398c <iput>:
{
    8000398c:	1101                	addi	sp,sp,-32
    8000398e:	ec06                	sd	ra,24(sp)
    80003990:	e822                	sd	s0,16(sp)
    80003992:	e426                	sd	s1,8(sp)
    80003994:	e04a                	sd	s2,0(sp)
    80003996:	1000                	addi	s0,sp,32
    80003998:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000399a:	0001c517          	auipc	a0,0x1c
    8000399e:	e2e50513          	addi	a0,a0,-466 # 8001f7c8 <itable>
    800039a2:	ffffd097          	auipc	ra,0xffffd
    800039a6:	242080e7          	jalr	578(ra) # 80000be4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039aa:	4498                	lw	a4,8(s1)
    800039ac:	4785                	li	a5,1
    800039ae:	02f70363          	beq	a4,a5,800039d4 <iput+0x48>
  ip->ref--;
    800039b2:	449c                	lw	a5,8(s1)
    800039b4:	37fd                	addiw	a5,a5,-1
    800039b6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039b8:	0001c517          	auipc	a0,0x1c
    800039bc:	e1050513          	addi	a0,a0,-496 # 8001f7c8 <itable>
    800039c0:	ffffd097          	auipc	ra,0xffffd
    800039c4:	2d8080e7          	jalr	728(ra) # 80000c98 <release>
}
    800039c8:	60e2                	ld	ra,24(sp)
    800039ca:	6442                	ld	s0,16(sp)
    800039cc:	64a2                	ld	s1,8(sp)
    800039ce:	6902                	ld	s2,0(sp)
    800039d0:	6105                	addi	sp,sp,32
    800039d2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039d4:	40bc                	lw	a5,64(s1)
    800039d6:	dff1                	beqz	a5,800039b2 <iput+0x26>
    800039d8:	04a49783          	lh	a5,74(s1)
    800039dc:	fbf9                	bnez	a5,800039b2 <iput+0x26>
    acquiresleep(&ip->lock);
    800039de:	01048913          	addi	s2,s1,16
    800039e2:	854a                	mv	a0,s2
    800039e4:	00001097          	auipc	ra,0x1
    800039e8:	ab8080e7          	jalr	-1352(ra) # 8000449c <acquiresleep>
    release(&itable.lock);
    800039ec:	0001c517          	auipc	a0,0x1c
    800039f0:	ddc50513          	addi	a0,a0,-548 # 8001f7c8 <itable>
    800039f4:	ffffd097          	auipc	ra,0xffffd
    800039f8:	2a4080e7          	jalr	676(ra) # 80000c98 <release>
    itrunc(ip);
    800039fc:	8526                	mv	a0,s1
    800039fe:	00000097          	auipc	ra,0x0
    80003a02:	ee2080e7          	jalr	-286(ra) # 800038e0 <itrunc>
    ip->type = 0;
    80003a06:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a0a:	8526                	mv	a0,s1
    80003a0c:	00000097          	auipc	ra,0x0
    80003a10:	cfc080e7          	jalr	-772(ra) # 80003708 <iupdate>
    ip->valid = 0;
    80003a14:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a18:	854a                	mv	a0,s2
    80003a1a:	00001097          	auipc	ra,0x1
    80003a1e:	ad8080e7          	jalr	-1320(ra) # 800044f2 <releasesleep>
    acquire(&itable.lock);
    80003a22:	0001c517          	auipc	a0,0x1c
    80003a26:	da650513          	addi	a0,a0,-602 # 8001f7c8 <itable>
    80003a2a:	ffffd097          	auipc	ra,0xffffd
    80003a2e:	1ba080e7          	jalr	442(ra) # 80000be4 <acquire>
    80003a32:	b741                	j	800039b2 <iput+0x26>

0000000080003a34 <iunlockput>:
{
    80003a34:	1101                	addi	sp,sp,-32
    80003a36:	ec06                	sd	ra,24(sp)
    80003a38:	e822                	sd	s0,16(sp)
    80003a3a:	e426                	sd	s1,8(sp)
    80003a3c:	1000                	addi	s0,sp,32
    80003a3e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a40:	00000097          	auipc	ra,0x0
    80003a44:	e54080e7          	jalr	-428(ra) # 80003894 <iunlock>
  iput(ip);
    80003a48:	8526                	mv	a0,s1
    80003a4a:	00000097          	auipc	ra,0x0
    80003a4e:	f42080e7          	jalr	-190(ra) # 8000398c <iput>
}
    80003a52:	60e2                	ld	ra,24(sp)
    80003a54:	6442                	ld	s0,16(sp)
    80003a56:	64a2                	ld	s1,8(sp)
    80003a58:	6105                	addi	sp,sp,32
    80003a5a:	8082                	ret

0000000080003a5c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a5c:	1141                	addi	sp,sp,-16
    80003a5e:	e422                	sd	s0,8(sp)
    80003a60:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a62:	411c                	lw	a5,0(a0)
    80003a64:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a66:	415c                	lw	a5,4(a0)
    80003a68:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a6a:	04451783          	lh	a5,68(a0)
    80003a6e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a72:	04a51783          	lh	a5,74(a0)
    80003a76:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a7a:	04c56783          	lwu	a5,76(a0)
    80003a7e:	e99c                	sd	a5,16(a1)
}
    80003a80:	6422                	ld	s0,8(sp)
    80003a82:	0141                	addi	sp,sp,16
    80003a84:	8082                	ret

0000000080003a86 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a86:	457c                	lw	a5,76(a0)
    80003a88:	0ed7e963          	bltu	a5,a3,80003b7a <readi+0xf4>
{
    80003a8c:	7159                	addi	sp,sp,-112
    80003a8e:	f486                	sd	ra,104(sp)
    80003a90:	f0a2                	sd	s0,96(sp)
    80003a92:	eca6                	sd	s1,88(sp)
    80003a94:	e8ca                	sd	s2,80(sp)
    80003a96:	e4ce                	sd	s3,72(sp)
    80003a98:	e0d2                	sd	s4,64(sp)
    80003a9a:	fc56                	sd	s5,56(sp)
    80003a9c:	f85a                	sd	s6,48(sp)
    80003a9e:	f45e                	sd	s7,40(sp)
    80003aa0:	f062                	sd	s8,32(sp)
    80003aa2:	ec66                	sd	s9,24(sp)
    80003aa4:	e86a                	sd	s10,16(sp)
    80003aa6:	e46e                	sd	s11,8(sp)
    80003aa8:	1880                	addi	s0,sp,112
    80003aaa:	8baa                	mv	s7,a0
    80003aac:	8c2e                	mv	s8,a1
    80003aae:	8ab2                	mv	s5,a2
    80003ab0:	84b6                	mv	s1,a3
    80003ab2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ab4:	9f35                	addw	a4,a4,a3
    return 0;
    80003ab6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ab8:	0ad76063          	bltu	a4,a3,80003b58 <readi+0xd2>
  if(off + n > ip->size)
    80003abc:	00e7f463          	bgeu	a5,a4,80003ac4 <readi+0x3e>
    n = ip->size - off;
    80003ac0:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ac4:	0a0b0963          	beqz	s6,80003b76 <readi+0xf0>
    80003ac8:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aca:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ace:	5cfd                	li	s9,-1
    80003ad0:	a82d                	j	80003b0a <readi+0x84>
    80003ad2:	020a1d93          	slli	s11,s4,0x20
    80003ad6:	020ddd93          	srli	s11,s11,0x20
    80003ada:	05890613          	addi	a2,s2,88
    80003ade:	86ee                	mv	a3,s11
    80003ae0:	963a                	add	a2,a2,a4
    80003ae2:	85d6                	mv	a1,s5
    80003ae4:	8562                	mv	a0,s8
    80003ae6:	fffff097          	auipc	ra,0xfffff
    80003aea:	a72080e7          	jalr	-1422(ra) # 80002558 <either_copyout>
    80003aee:	05950d63          	beq	a0,s9,80003b48 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003af2:	854a                	mv	a0,s2
    80003af4:	fffff097          	auipc	ra,0xfffff
    80003af8:	60c080e7          	jalr	1548(ra) # 80003100 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003afc:	013a09bb          	addw	s3,s4,s3
    80003b00:	009a04bb          	addw	s1,s4,s1
    80003b04:	9aee                	add	s5,s5,s11
    80003b06:	0569f763          	bgeu	s3,s6,80003b54 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b0a:	000ba903          	lw	s2,0(s7)
    80003b0e:	00a4d59b          	srliw	a1,s1,0xa
    80003b12:	855e                	mv	a0,s7
    80003b14:	00000097          	auipc	ra,0x0
    80003b18:	8b0080e7          	jalr	-1872(ra) # 800033c4 <bmap>
    80003b1c:	0005059b          	sext.w	a1,a0
    80003b20:	854a                	mv	a0,s2
    80003b22:	fffff097          	auipc	ra,0xfffff
    80003b26:	4ae080e7          	jalr	1198(ra) # 80002fd0 <bread>
    80003b2a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b2c:	3ff4f713          	andi	a4,s1,1023
    80003b30:	40ed07bb          	subw	a5,s10,a4
    80003b34:	413b06bb          	subw	a3,s6,s3
    80003b38:	8a3e                	mv	s4,a5
    80003b3a:	2781                	sext.w	a5,a5
    80003b3c:	0006861b          	sext.w	a2,a3
    80003b40:	f8f679e3          	bgeu	a2,a5,80003ad2 <readi+0x4c>
    80003b44:	8a36                	mv	s4,a3
    80003b46:	b771                	j	80003ad2 <readi+0x4c>
      brelse(bp);
    80003b48:	854a                	mv	a0,s2
    80003b4a:	fffff097          	auipc	ra,0xfffff
    80003b4e:	5b6080e7          	jalr	1462(ra) # 80003100 <brelse>
      tot = -1;
    80003b52:	59fd                	li	s3,-1
  }
  return tot;
    80003b54:	0009851b          	sext.w	a0,s3
}
    80003b58:	70a6                	ld	ra,104(sp)
    80003b5a:	7406                	ld	s0,96(sp)
    80003b5c:	64e6                	ld	s1,88(sp)
    80003b5e:	6946                	ld	s2,80(sp)
    80003b60:	69a6                	ld	s3,72(sp)
    80003b62:	6a06                	ld	s4,64(sp)
    80003b64:	7ae2                	ld	s5,56(sp)
    80003b66:	7b42                	ld	s6,48(sp)
    80003b68:	7ba2                	ld	s7,40(sp)
    80003b6a:	7c02                	ld	s8,32(sp)
    80003b6c:	6ce2                	ld	s9,24(sp)
    80003b6e:	6d42                	ld	s10,16(sp)
    80003b70:	6da2                	ld	s11,8(sp)
    80003b72:	6165                	addi	sp,sp,112
    80003b74:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b76:	89da                	mv	s3,s6
    80003b78:	bff1                	j	80003b54 <readi+0xce>
    return 0;
    80003b7a:	4501                	li	a0,0
}
    80003b7c:	8082                	ret

0000000080003b7e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b7e:	457c                	lw	a5,76(a0)
    80003b80:	10d7e863          	bltu	a5,a3,80003c90 <writei+0x112>
{
    80003b84:	7159                	addi	sp,sp,-112
    80003b86:	f486                	sd	ra,104(sp)
    80003b88:	f0a2                	sd	s0,96(sp)
    80003b8a:	eca6                	sd	s1,88(sp)
    80003b8c:	e8ca                	sd	s2,80(sp)
    80003b8e:	e4ce                	sd	s3,72(sp)
    80003b90:	e0d2                	sd	s4,64(sp)
    80003b92:	fc56                	sd	s5,56(sp)
    80003b94:	f85a                	sd	s6,48(sp)
    80003b96:	f45e                	sd	s7,40(sp)
    80003b98:	f062                	sd	s8,32(sp)
    80003b9a:	ec66                	sd	s9,24(sp)
    80003b9c:	e86a                	sd	s10,16(sp)
    80003b9e:	e46e                	sd	s11,8(sp)
    80003ba0:	1880                	addi	s0,sp,112
    80003ba2:	8b2a                	mv	s6,a0
    80003ba4:	8c2e                	mv	s8,a1
    80003ba6:	8ab2                	mv	s5,a2
    80003ba8:	8936                	mv	s2,a3
    80003baa:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003bac:	00e687bb          	addw	a5,a3,a4
    80003bb0:	0ed7e263          	bltu	a5,a3,80003c94 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003bb4:	00043737          	lui	a4,0x43
    80003bb8:	0ef76063          	bltu	a4,a5,80003c98 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bbc:	0c0b8863          	beqz	s7,80003c8c <writei+0x10e>
    80003bc0:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bc2:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003bc6:	5cfd                	li	s9,-1
    80003bc8:	a091                	j	80003c0c <writei+0x8e>
    80003bca:	02099d93          	slli	s11,s3,0x20
    80003bce:	020ddd93          	srli	s11,s11,0x20
    80003bd2:	05848513          	addi	a0,s1,88
    80003bd6:	86ee                	mv	a3,s11
    80003bd8:	8656                	mv	a2,s5
    80003bda:	85e2                	mv	a1,s8
    80003bdc:	953a                	add	a0,a0,a4
    80003bde:	fffff097          	auipc	ra,0xfffff
    80003be2:	9d0080e7          	jalr	-1584(ra) # 800025ae <either_copyin>
    80003be6:	07950263          	beq	a0,s9,80003c4a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003bea:	8526                	mv	a0,s1
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	790080e7          	jalr	1936(ra) # 8000437c <log_write>
    brelse(bp);
    80003bf4:	8526                	mv	a0,s1
    80003bf6:	fffff097          	auipc	ra,0xfffff
    80003bfa:	50a080e7          	jalr	1290(ra) # 80003100 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bfe:	01498a3b          	addw	s4,s3,s4
    80003c02:	0129893b          	addw	s2,s3,s2
    80003c06:	9aee                	add	s5,s5,s11
    80003c08:	057a7663          	bgeu	s4,s7,80003c54 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c0c:	000b2483          	lw	s1,0(s6)
    80003c10:	00a9559b          	srliw	a1,s2,0xa
    80003c14:	855a                	mv	a0,s6
    80003c16:	fffff097          	auipc	ra,0xfffff
    80003c1a:	7ae080e7          	jalr	1966(ra) # 800033c4 <bmap>
    80003c1e:	0005059b          	sext.w	a1,a0
    80003c22:	8526                	mv	a0,s1
    80003c24:	fffff097          	auipc	ra,0xfffff
    80003c28:	3ac080e7          	jalr	940(ra) # 80002fd0 <bread>
    80003c2c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c2e:	3ff97713          	andi	a4,s2,1023
    80003c32:	40ed07bb          	subw	a5,s10,a4
    80003c36:	414b86bb          	subw	a3,s7,s4
    80003c3a:	89be                	mv	s3,a5
    80003c3c:	2781                	sext.w	a5,a5
    80003c3e:	0006861b          	sext.w	a2,a3
    80003c42:	f8f674e3          	bgeu	a2,a5,80003bca <writei+0x4c>
    80003c46:	89b6                	mv	s3,a3
    80003c48:	b749                	j	80003bca <writei+0x4c>
      brelse(bp);
    80003c4a:	8526                	mv	a0,s1
    80003c4c:	fffff097          	auipc	ra,0xfffff
    80003c50:	4b4080e7          	jalr	1204(ra) # 80003100 <brelse>
  }

  if(off > ip->size)
    80003c54:	04cb2783          	lw	a5,76(s6)
    80003c58:	0127f463          	bgeu	a5,s2,80003c60 <writei+0xe2>
    ip->size = off;
    80003c5c:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c60:	855a                	mv	a0,s6
    80003c62:	00000097          	auipc	ra,0x0
    80003c66:	aa6080e7          	jalr	-1370(ra) # 80003708 <iupdate>

  return tot;
    80003c6a:	000a051b          	sext.w	a0,s4
}
    80003c6e:	70a6                	ld	ra,104(sp)
    80003c70:	7406                	ld	s0,96(sp)
    80003c72:	64e6                	ld	s1,88(sp)
    80003c74:	6946                	ld	s2,80(sp)
    80003c76:	69a6                	ld	s3,72(sp)
    80003c78:	6a06                	ld	s4,64(sp)
    80003c7a:	7ae2                	ld	s5,56(sp)
    80003c7c:	7b42                	ld	s6,48(sp)
    80003c7e:	7ba2                	ld	s7,40(sp)
    80003c80:	7c02                	ld	s8,32(sp)
    80003c82:	6ce2                	ld	s9,24(sp)
    80003c84:	6d42                	ld	s10,16(sp)
    80003c86:	6da2                	ld	s11,8(sp)
    80003c88:	6165                	addi	sp,sp,112
    80003c8a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c8c:	8a5e                	mv	s4,s7
    80003c8e:	bfc9                	j	80003c60 <writei+0xe2>
    return -1;
    80003c90:	557d                	li	a0,-1
}
    80003c92:	8082                	ret
    return -1;
    80003c94:	557d                	li	a0,-1
    80003c96:	bfe1                	j	80003c6e <writei+0xf0>
    return -1;
    80003c98:	557d                	li	a0,-1
    80003c9a:	bfd1                	j	80003c6e <writei+0xf0>

0000000080003c9c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c9c:	1141                	addi	sp,sp,-16
    80003c9e:	e406                	sd	ra,8(sp)
    80003ca0:	e022                	sd	s0,0(sp)
    80003ca2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ca4:	4639                	li	a2,14
    80003ca6:	ffffd097          	auipc	ra,0xffffd
    80003caa:	112080e7          	jalr	274(ra) # 80000db8 <strncmp>
}
    80003cae:	60a2                	ld	ra,8(sp)
    80003cb0:	6402                	ld	s0,0(sp)
    80003cb2:	0141                	addi	sp,sp,16
    80003cb4:	8082                	ret

0000000080003cb6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cb6:	7139                	addi	sp,sp,-64
    80003cb8:	fc06                	sd	ra,56(sp)
    80003cba:	f822                	sd	s0,48(sp)
    80003cbc:	f426                	sd	s1,40(sp)
    80003cbe:	f04a                	sd	s2,32(sp)
    80003cc0:	ec4e                	sd	s3,24(sp)
    80003cc2:	e852                	sd	s4,16(sp)
    80003cc4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003cc6:	04451703          	lh	a4,68(a0)
    80003cca:	4785                	li	a5,1
    80003ccc:	00f71a63          	bne	a4,a5,80003ce0 <dirlookup+0x2a>
    80003cd0:	892a                	mv	s2,a0
    80003cd2:	89ae                	mv	s3,a1
    80003cd4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cd6:	457c                	lw	a5,76(a0)
    80003cd8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003cda:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cdc:	e79d                	bnez	a5,80003d0a <dirlookup+0x54>
    80003cde:	a8a5                	j	80003d56 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ce0:	00005517          	auipc	a0,0x5
    80003ce4:	92850513          	addi	a0,a0,-1752 # 80008608 <syscalls+0x1c0>
    80003ce8:	ffffd097          	auipc	ra,0xffffd
    80003cec:	856080e7          	jalr	-1962(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003cf0:	00005517          	auipc	a0,0x5
    80003cf4:	93050513          	addi	a0,a0,-1744 # 80008620 <syscalls+0x1d8>
    80003cf8:	ffffd097          	auipc	ra,0xffffd
    80003cfc:	846080e7          	jalr	-1978(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d00:	24c1                	addiw	s1,s1,16
    80003d02:	04c92783          	lw	a5,76(s2)
    80003d06:	04f4f763          	bgeu	s1,a5,80003d54 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d0a:	4741                	li	a4,16
    80003d0c:	86a6                	mv	a3,s1
    80003d0e:	fc040613          	addi	a2,s0,-64
    80003d12:	4581                	li	a1,0
    80003d14:	854a                	mv	a0,s2
    80003d16:	00000097          	auipc	ra,0x0
    80003d1a:	d70080e7          	jalr	-656(ra) # 80003a86 <readi>
    80003d1e:	47c1                	li	a5,16
    80003d20:	fcf518e3          	bne	a0,a5,80003cf0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003d24:	fc045783          	lhu	a5,-64(s0)
    80003d28:	dfe1                	beqz	a5,80003d00 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d2a:	fc240593          	addi	a1,s0,-62
    80003d2e:	854e                	mv	a0,s3
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	f6c080e7          	jalr	-148(ra) # 80003c9c <namecmp>
    80003d38:	f561                	bnez	a0,80003d00 <dirlookup+0x4a>
      if(poff)
    80003d3a:	000a0463          	beqz	s4,80003d42 <dirlookup+0x8c>
        *poff = off;
    80003d3e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d42:	fc045583          	lhu	a1,-64(s0)
    80003d46:	00092503          	lw	a0,0(s2)
    80003d4a:	fffff097          	auipc	ra,0xfffff
    80003d4e:	754080e7          	jalr	1876(ra) # 8000349e <iget>
    80003d52:	a011                	j	80003d56 <dirlookup+0xa0>
  return 0;
    80003d54:	4501                	li	a0,0
}
    80003d56:	70e2                	ld	ra,56(sp)
    80003d58:	7442                	ld	s0,48(sp)
    80003d5a:	74a2                	ld	s1,40(sp)
    80003d5c:	7902                	ld	s2,32(sp)
    80003d5e:	69e2                	ld	s3,24(sp)
    80003d60:	6a42                	ld	s4,16(sp)
    80003d62:	6121                	addi	sp,sp,64
    80003d64:	8082                	ret

0000000080003d66 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d66:	711d                	addi	sp,sp,-96
    80003d68:	ec86                	sd	ra,88(sp)
    80003d6a:	e8a2                	sd	s0,80(sp)
    80003d6c:	e4a6                	sd	s1,72(sp)
    80003d6e:	e0ca                	sd	s2,64(sp)
    80003d70:	fc4e                	sd	s3,56(sp)
    80003d72:	f852                	sd	s4,48(sp)
    80003d74:	f456                	sd	s5,40(sp)
    80003d76:	f05a                	sd	s6,32(sp)
    80003d78:	ec5e                	sd	s7,24(sp)
    80003d7a:	e862                	sd	s8,16(sp)
    80003d7c:	e466                	sd	s9,8(sp)
    80003d7e:	1080                	addi	s0,sp,96
    80003d80:	84aa                	mv	s1,a0
    80003d82:	8b2e                	mv	s6,a1
    80003d84:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d86:	00054703          	lbu	a4,0(a0)
    80003d8a:	02f00793          	li	a5,47
    80003d8e:	02f70363          	beq	a4,a5,80003db4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d92:	ffffe097          	auipc	ra,0xffffe
    80003d96:	c1e080e7          	jalr	-994(ra) # 800019b0 <myproc>
    80003d9a:	15053503          	ld	a0,336(a0)
    80003d9e:	00000097          	auipc	ra,0x0
    80003da2:	9f6080e7          	jalr	-1546(ra) # 80003794 <idup>
    80003da6:	89aa                	mv	s3,a0
  while(*path == '/')
    80003da8:	02f00913          	li	s2,47
  len = path - s;
    80003dac:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003dae:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003db0:	4c05                	li	s8,1
    80003db2:	a865                	j	80003e6a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003db4:	4585                	li	a1,1
    80003db6:	4505                	li	a0,1
    80003db8:	fffff097          	auipc	ra,0xfffff
    80003dbc:	6e6080e7          	jalr	1766(ra) # 8000349e <iget>
    80003dc0:	89aa                	mv	s3,a0
    80003dc2:	b7dd                	j	80003da8 <namex+0x42>
      iunlockput(ip);
    80003dc4:	854e                	mv	a0,s3
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	c6e080e7          	jalr	-914(ra) # 80003a34 <iunlockput>
      return 0;
    80003dce:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003dd0:	854e                	mv	a0,s3
    80003dd2:	60e6                	ld	ra,88(sp)
    80003dd4:	6446                	ld	s0,80(sp)
    80003dd6:	64a6                	ld	s1,72(sp)
    80003dd8:	6906                	ld	s2,64(sp)
    80003dda:	79e2                	ld	s3,56(sp)
    80003ddc:	7a42                	ld	s4,48(sp)
    80003dde:	7aa2                	ld	s5,40(sp)
    80003de0:	7b02                	ld	s6,32(sp)
    80003de2:	6be2                	ld	s7,24(sp)
    80003de4:	6c42                	ld	s8,16(sp)
    80003de6:	6ca2                	ld	s9,8(sp)
    80003de8:	6125                	addi	sp,sp,96
    80003dea:	8082                	ret
      iunlock(ip);
    80003dec:	854e                	mv	a0,s3
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	aa6080e7          	jalr	-1370(ra) # 80003894 <iunlock>
      return ip;
    80003df6:	bfe9                	j	80003dd0 <namex+0x6a>
      iunlockput(ip);
    80003df8:	854e                	mv	a0,s3
    80003dfa:	00000097          	auipc	ra,0x0
    80003dfe:	c3a080e7          	jalr	-966(ra) # 80003a34 <iunlockput>
      return 0;
    80003e02:	89d2                	mv	s3,s4
    80003e04:	b7f1                	j	80003dd0 <namex+0x6a>
  len = path - s;
    80003e06:	40b48633          	sub	a2,s1,a1
    80003e0a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003e0e:	094cd463          	bge	s9,s4,80003e96 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003e12:	4639                	li	a2,14
    80003e14:	8556                	mv	a0,s5
    80003e16:	ffffd097          	auipc	ra,0xffffd
    80003e1a:	f2a080e7          	jalr	-214(ra) # 80000d40 <memmove>
  while(*path == '/')
    80003e1e:	0004c783          	lbu	a5,0(s1)
    80003e22:	01279763          	bne	a5,s2,80003e30 <namex+0xca>
    path++;
    80003e26:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e28:	0004c783          	lbu	a5,0(s1)
    80003e2c:	ff278de3          	beq	a5,s2,80003e26 <namex+0xc0>
    ilock(ip);
    80003e30:	854e                	mv	a0,s3
    80003e32:	00000097          	auipc	ra,0x0
    80003e36:	9a0080e7          	jalr	-1632(ra) # 800037d2 <ilock>
    if(ip->type != T_DIR){
    80003e3a:	04499783          	lh	a5,68(s3)
    80003e3e:	f98793e3          	bne	a5,s8,80003dc4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003e42:	000b0563          	beqz	s6,80003e4c <namex+0xe6>
    80003e46:	0004c783          	lbu	a5,0(s1)
    80003e4a:	d3cd                	beqz	a5,80003dec <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e4c:	865e                	mv	a2,s7
    80003e4e:	85d6                	mv	a1,s5
    80003e50:	854e                	mv	a0,s3
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	e64080e7          	jalr	-412(ra) # 80003cb6 <dirlookup>
    80003e5a:	8a2a                	mv	s4,a0
    80003e5c:	dd51                	beqz	a0,80003df8 <namex+0x92>
    iunlockput(ip);
    80003e5e:	854e                	mv	a0,s3
    80003e60:	00000097          	auipc	ra,0x0
    80003e64:	bd4080e7          	jalr	-1068(ra) # 80003a34 <iunlockput>
    ip = next;
    80003e68:	89d2                	mv	s3,s4
  while(*path == '/')
    80003e6a:	0004c783          	lbu	a5,0(s1)
    80003e6e:	05279763          	bne	a5,s2,80003ebc <namex+0x156>
    path++;
    80003e72:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e74:	0004c783          	lbu	a5,0(s1)
    80003e78:	ff278de3          	beq	a5,s2,80003e72 <namex+0x10c>
  if(*path == 0)
    80003e7c:	c79d                	beqz	a5,80003eaa <namex+0x144>
    path++;
    80003e7e:	85a6                	mv	a1,s1
  len = path - s;
    80003e80:	8a5e                	mv	s4,s7
    80003e82:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003e84:	01278963          	beq	a5,s2,80003e96 <namex+0x130>
    80003e88:	dfbd                	beqz	a5,80003e06 <namex+0xa0>
    path++;
    80003e8a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003e8c:	0004c783          	lbu	a5,0(s1)
    80003e90:	ff279ce3          	bne	a5,s2,80003e88 <namex+0x122>
    80003e94:	bf8d                	j	80003e06 <namex+0xa0>
    memmove(name, s, len);
    80003e96:	2601                	sext.w	a2,a2
    80003e98:	8556                	mv	a0,s5
    80003e9a:	ffffd097          	auipc	ra,0xffffd
    80003e9e:	ea6080e7          	jalr	-346(ra) # 80000d40 <memmove>
    name[len] = 0;
    80003ea2:	9a56                	add	s4,s4,s5
    80003ea4:	000a0023          	sb	zero,0(s4)
    80003ea8:	bf9d                	j	80003e1e <namex+0xb8>
  if(nameiparent){
    80003eaa:	f20b03e3          	beqz	s6,80003dd0 <namex+0x6a>
    iput(ip);
    80003eae:	854e                	mv	a0,s3
    80003eb0:	00000097          	auipc	ra,0x0
    80003eb4:	adc080e7          	jalr	-1316(ra) # 8000398c <iput>
    return 0;
    80003eb8:	4981                	li	s3,0
    80003eba:	bf19                	j	80003dd0 <namex+0x6a>
  if(*path == 0)
    80003ebc:	d7fd                	beqz	a5,80003eaa <namex+0x144>
  while(*path != '/' && *path != 0)
    80003ebe:	0004c783          	lbu	a5,0(s1)
    80003ec2:	85a6                	mv	a1,s1
    80003ec4:	b7d1                	j	80003e88 <namex+0x122>

0000000080003ec6 <dirlink>:
{
    80003ec6:	7139                	addi	sp,sp,-64
    80003ec8:	fc06                	sd	ra,56(sp)
    80003eca:	f822                	sd	s0,48(sp)
    80003ecc:	f426                	sd	s1,40(sp)
    80003ece:	f04a                	sd	s2,32(sp)
    80003ed0:	ec4e                	sd	s3,24(sp)
    80003ed2:	e852                	sd	s4,16(sp)
    80003ed4:	0080                	addi	s0,sp,64
    80003ed6:	892a                	mv	s2,a0
    80003ed8:	8a2e                	mv	s4,a1
    80003eda:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003edc:	4601                	li	a2,0
    80003ede:	00000097          	auipc	ra,0x0
    80003ee2:	dd8080e7          	jalr	-552(ra) # 80003cb6 <dirlookup>
    80003ee6:	e93d                	bnez	a0,80003f5c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee8:	04c92483          	lw	s1,76(s2)
    80003eec:	c49d                	beqz	s1,80003f1a <dirlink+0x54>
    80003eee:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ef0:	4741                	li	a4,16
    80003ef2:	86a6                	mv	a3,s1
    80003ef4:	fc040613          	addi	a2,s0,-64
    80003ef8:	4581                	li	a1,0
    80003efa:	854a                	mv	a0,s2
    80003efc:	00000097          	auipc	ra,0x0
    80003f00:	b8a080e7          	jalr	-1142(ra) # 80003a86 <readi>
    80003f04:	47c1                	li	a5,16
    80003f06:	06f51163          	bne	a0,a5,80003f68 <dirlink+0xa2>
    if(de.inum == 0)
    80003f0a:	fc045783          	lhu	a5,-64(s0)
    80003f0e:	c791                	beqz	a5,80003f1a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f10:	24c1                	addiw	s1,s1,16
    80003f12:	04c92783          	lw	a5,76(s2)
    80003f16:	fcf4ede3          	bltu	s1,a5,80003ef0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f1a:	4639                	li	a2,14
    80003f1c:	85d2                	mv	a1,s4
    80003f1e:	fc240513          	addi	a0,s0,-62
    80003f22:	ffffd097          	auipc	ra,0xffffd
    80003f26:	ed2080e7          	jalr	-302(ra) # 80000df4 <strncpy>
  de.inum = inum;
    80003f2a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f2e:	4741                	li	a4,16
    80003f30:	86a6                	mv	a3,s1
    80003f32:	fc040613          	addi	a2,s0,-64
    80003f36:	4581                	li	a1,0
    80003f38:	854a                	mv	a0,s2
    80003f3a:	00000097          	auipc	ra,0x0
    80003f3e:	c44080e7          	jalr	-956(ra) # 80003b7e <writei>
    80003f42:	872a                	mv	a4,a0
    80003f44:	47c1                	li	a5,16
  return 0;
    80003f46:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f48:	02f71863          	bne	a4,a5,80003f78 <dirlink+0xb2>
}
    80003f4c:	70e2                	ld	ra,56(sp)
    80003f4e:	7442                	ld	s0,48(sp)
    80003f50:	74a2                	ld	s1,40(sp)
    80003f52:	7902                	ld	s2,32(sp)
    80003f54:	69e2                	ld	s3,24(sp)
    80003f56:	6a42                	ld	s4,16(sp)
    80003f58:	6121                	addi	sp,sp,64
    80003f5a:	8082                	ret
    iput(ip);
    80003f5c:	00000097          	auipc	ra,0x0
    80003f60:	a30080e7          	jalr	-1488(ra) # 8000398c <iput>
    return -1;
    80003f64:	557d                	li	a0,-1
    80003f66:	b7dd                	j	80003f4c <dirlink+0x86>
      panic("dirlink read");
    80003f68:	00004517          	auipc	a0,0x4
    80003f6c:	6c850513          	addi	a0,a0,1736 # 80008630 <syscalls+0x1e8>
    80003f70:	ffffc097          	auipc	ra,0xffffc
    80003f74:	5ce080e7          	jalr	1486(ra) # 8000053e <panic>
    panic("dirlink");
    80003f78:	00004517          	auipc	a0,0x4
    80003f7c:	7c850513          	addi	a0,a0,1992 # 80008740 <syscalls+0x2f8>
    80003f80:	ffffc097          	auipc	ra,0xffffc
    80003f84:	5be080e7          	jalr	1470(ra) # 8000053e <panic>

0000000080003f88 <namei>:

struct inode*
namei(char *path)
{
    80003f88:	1101                	addi	sp,sp,-32
    80003f8a:	ec06                	sd	ra,24(sp)
    80003f8c:	e822                	sd	s0,16(sp)
    80003f8e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f90:	fe040613          	addi	a2,s0,-32
    80003f94:	4581                	li	a1,0
    80003f96:	00000097          	auipc	ra,0x0
    80003f9a:	dd0080e7          	jalr	-560(ra) # 80003d66 <namex>
}
    80003f9e:	60e2                	ld	ra,24(sp)
    80003fa0:	6442                	ld	s0,16(sp)
    80003fa2:	6105                	addi	sp,sp,32
    80003fa4:	8082                	ret

0000000080003fa6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fa6:	1141                	addi	sp,sp,-16
    80003fa8:	e406                	sd	ra,8(sp)
    80003faa:	e022                	sd	s0,0(sp)
    80003fac:	0800                	addi	s0,sp,16
    80003fae:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003fb0:	4585                	li	a1,1
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	db4080e7          	jalr	-588(ra) # 80003d66 <namex>
}
    80003fba:	60a2                	ld	ra,8(sp)
    80003fbc:	6402                	ld	s0,0(sp)
    80003fbe:	0141                	addi	sp,sp,16
    80003fc0:	8082                	ret

0000000080003fc2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fc2:	1101                	addi	sp,sp,-32
    80003fc4:	ec06                	sd	ra,24(sp)
    80003fc6:	e822                	sd	s0,16(sp)
    80003fc8:	e426                	sd	s1,8(sp)
    80003fca:	e04a                	sd	s2,0(sp)
    80003fcc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003fce:	0001d917          	auipc	s2,0x1d
    80003fd2:	2a290913          	addi	s2,s2,674 # 80021270 <log>
    80003fd6:	01892583          	lw	a1,24(s2)
    80003fda:	02892503          	lw	a0,40(s2)
    80003fde:	fffff097          	auipc	ra,0xfffff
    80003fe2:	ff2080e7          	jalr	-14(ra) # 80002fd0 <bread>
    80003fe6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003fe8:	02c92683          	lw	a3,44(s2)
    80003fec:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003fee:	02d05763          	blez	a3,8000401c <write_head+0x5a>
    80003ff2:	0001d797          	auipc	a5,0x1d
    80003ff6:	2ae78793          	addi	a5,a5,686 # 800212a0 <log+0x30>
    80003ffa:	05c50713          	addi	a4,a0,92
    80003ffe:	36fd                	addiw	a3,a3,-1
    80004000:	1682                	slli	a3,a3,0x20
    80004002:	9281                	srli	a3,a3,0x20
    80004004:	068a                	slli	a3,a3,0x2
    80004006:	0001d617          	auipc	a2,0x1d
    8000400a:	29e60613          	addi	a2,a2,670 # 800212a4 <log+0x34>
    8000400e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004010:	4390                	lw	a2,0(a5)
    80004012:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004014:	0791                	addi	a5,a5,4
    80004016:	0711                	addi	a4,a4,4
    80004018:	fed79ce3          	bne	a5,a3,80004010 <write_head+0x4e>
  }
  bwrite(buf);
    8000401c:	8526                	mv	a0,s1
    8000401e:	fffff097          	auipc	ra,0xfffff
    80004022:	0a4080e7          	jalr	164(ra) # 800030c2 <bwrite>
  brelse(buf);
    80004026:	8526                	mv	a0,s1
    80004028:	fffff097          	auipc	ra,0xfffff
    8000402c:	0d8080e7          	jalr	216(ra) # 80003100 <brelse>
}
    80004030:	60e2                	ld	ra,24(sp)
    80004032:	6442                	ld	s0,16(sp)
    80004034:	64a2                	ld	s1,8(sp)
    80004036:	6902                	ld	s2,0(sp)
    80004038:	6105                	addi	sp,sp,32
    8000403a:	8082                	ret

000000008000403c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000403c:	0001d797          	auipc	a5,0x1d
    80004040:	2607a783          	lw	a5,608(a5) # 8002129c <log+0x2c>
    80004044:	0af05d63          	blez	a5,800040fe <install_trans+0xc2>
{
    80004048:	7139                	addi	sp,sp,-64
    8000404a:	fc06                	sd	ra,56(sp)
    8000404c:	f822                	sd	s0,48(sp)
    8000404e:	f426                	sd	s1,40(sp)
    80004050:	f04a                	sd	s2,32(sp)
    80004052:	ec4e                	sd	s3,24(sp)
    80004054:	e852                	sd	s4,16(sp)
    80004056:	e456                	sd	s5,8(sp)
    80004058:	e05a                	sd	s6,0(sp)
    8000405a:	0080                	addi	s0,sp,64
    8000405c:	8b2a                	mv	s6,a0
    8000405e:	0001da97          	auipc	s5,0x1d
    80004062:	242a8a93          	addi	s5,s5,578 # 800212a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004066:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004068:	0001d997          	auipc	s3,0x1d
    8000406c:	20898993          	addi	s3,s3,520 # 80021270 <log>
    80004070:	a035                	j	8000409c <install_trans+0x60>
      bunpin(dbuf);
    80004072:	8526                	mv	a0,s1
    80004074:	fffff097          	auipc	ra,0xfffff
    80004078:	166080e7          	jalr	358(ra) # 800031da <bunpin>
    brelse(lbuf);
    8000407c:	854a                	mv	a0,s2
    8000407e:	fffff097          	auipc	ra,0xfffff
    80004082:	082080e7          	jalr	130(ra) # 80003100 <brelse>
    brelse(dbuf);
    80004086:	8526                	mv	a0,s1
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	078080e7          	jalr	120(ra) # 80003100 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004090:	2a05                	addiw	s4,s4,1
    80004092:	0a91                	addi	s5,s5,4
    80004094:	02c9a783          	lw	a5,44(s3)
    80004098:	04fa5963          	bge	s4,a5,800040ea <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000409c:	0189a583          	lw	a1,24(s3)
    800040a0:	014585bb          	addw	a1,a1,s4
    800040a4:	2585                	addiw	a1,a1,1
    800040a6:	0289a503          	lw	a0,40(s3)
    800040aa:	fffff097          	auipc	ra,0xfffff
    800040ae:	f26080e7          	jalr	-218(ra) # 80002fd0 <bread>
    800040b2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040b4:	000aa583          	lw	a1,0(s5)
    800040b8:	0289a503          	lw	a0,40(s3)
    800040bc:	fffff097          	auipc	ra,0xfffff
    800040c0:	f14080e7          	jalr	-236(ra) # 80002fd0 <bread>
    800040c4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040c6:	40000613          	li	a2,1024
    800040ca:	05890593          	addi	a1,s2,88
    800040ce:	05850513          	addi	a0,a0,88
    800040d2:	ffffd097          	auipc	ra,0xffffd
    800040d6:	c6e080e7          	jalr	-914(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    800040da:	8526                	mv	a0,s1
    800040dc:	fffff097          	auipc	ra,0xfffff
    800040e0:	fe6080e7          	jalr	-26(ra) # 800030c2 <bwrite>
    if(recovering == 0)
    800040e4:	f80b1ce3          	bnez	s6,8000407c <install_trans+0x40>
    800040e8:	b769                	j	80004072 <install_trans+0x36>
}
    800040ea:	70e2                	ld	ra,56(sp)
    800040ec:	7442                	ld	s0,48(sp)
    800040ee:	74a2                	ld	s1,40(sp)
    800040f0:	7902                	ld	s2,32(sp)
    800040f2:	69e2                	ld	s3,24(sp)
    800040f4:	6a42                	ld	s4,16(sp)
    800040f6:	6aa2                	ld	s5,8(sp)
    800040f8:	6b02                	ld	s6,0(sp)
    800040fa:	6121                	addi	sp,sp,64
    800040fc:	8082                	ret
    800040fe:	8082                	ret

0000000080004100 <initlog>:
{
    80004100:	7179                	addi	sp,sp,-48
    80004102:	f406                	sd	ra,40(sp)
    80004104:	f022                	sd	s0,32(sp)
    80004106:	ec26                	sd	s1,24(sp)
    80004108:	e84a                	sd	s2,16(sp)
    8000410a:	e44e                	sd	s3,8(sp)
    8000410c:	1800                	addi	s0,sp,48
    8000410e:	892a                	mv	s2,a0
    80004110:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004112:	0001d497          	auipc	s1,0x1d
    80004116:	15e48493          	addi	s1,s1,350 # 80021270 <log>
    8000411a:	00004597          	auipc	a1,0x4
    8000411e:	52658593          	addi	a1,a1,1318 # 80008640 <syscalls+0x1f8>
    80004122:	8526                	mv	a0,s1
    80004124:	ffffd097          	auipc	ra,0xffffd
    80004128:	a30080e7          	jalr	-1488(ra) # 80000b54 <initlock>
  log.start = sb->logstart;
    8000412c:	0149a583          	lw	a1,20(s3)
    80004130:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004132:	0109a783          	lw	a5,16(s3)
    80004136:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004138:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000413c:	854a                	mv	a0,s2
    8000413e:	fffff097          	auipc	ra,0xfffff
    80004142:	e92080e7          	jalr	-366(ra) # 80002fd0 <bread>
  log.lh.n = lh->n;
    80004146:	4d3c                	lw	a5,88(a0)
    80004148:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000414a:	02f05563          	blez	a5,80004174 <initlog+0x74>
    8000414e:	05c50713          	addi	a4,a0,92
    80004152:	0001d697          	auipc	a3,0x1d
    80004156:	14e68693          	addi	a3,a3,334 # 800212a0 <log+0x30>
    8000415a:	37fd                	addiw	a5,a5,-1
    8000415c:	1782                	slli	a5,a5,0x20
    8000415e:	9381                	srli	a5,a5,0x20
    80004160:	078a                	slli	a5,a5,0x2
    80004162:	06050613          	addi	a2,a0,96
    80004166:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004168:	4310                	lw	a2,0(a4)
    8000416a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000416c:	0711                	addi	a4,a4,4
    8000416e:	0691                	addi	a3,a3,4
    80004170:	fef71ce3          	bne	a4,a5,80004168 <initlog+0x68>
  brelse(buf);
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	f8c080e7          	jalr	-116(ra) # 80003100 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000417c:	4505                	li	a0,1
    8000417e:	00000097          	auipc	ra,0x0
    80004182:	ebe080e7          	jalr	-322(ra) # 8000403c <install_trans>
  log.lh.n = 0;
    80004186:	0001d797          	auipc	a5,0x1d
    8000418a:	1007ab23          	sw	zero,278(a5) # 8002129c <log+0x2c>
  write_head(); // clear the log
    8000418e:	00000097          	auipc	ra,0x0
    80004192:	e34080e7          	jalr	-460(ra) # 80003fc2 <write_head>
}
    80004196:	70a2                	ld	ra,40(sp)
    80004198:	7402                	ld	s0,32(sp)
    8000419a:	64e2                	ld	s1,24(sp)
    8000419c:	6942                	ld	s2,16(sp)
    8000419e:	69a2                	ld	s3,8(sp)
    800041a0:	6145                	addi	sp,sp,48
    800041a2:	8082                	ret

00000000800041a4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041a4:	1101                	addi	sp,sp,-32
    800041a6:	ec06                	sd	ra,24(sp)
    800041a8:	e822                	sd	s0,16(sp)
    800041aa:	e426                	sd	s1,8(sp)
    800041ac:	e04a                	sd	s2,0(sp)
    800041ae:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041b0:	0001d517          	auipc	a0,0x1d
    800041b4:	0c050513          	addi	a0,a0,192 # 80021270 <log>
    800041b8:	ffffd097          	auipc	ra,0xffffd
    800041bc:	a2c080e7          	jalr	-1492(ra) # 80000be4 <acquire>
  while(1){
    if(log.committing){
    800041c0:	0001d497          	auipc	s1,0x1d
    800041c4:	0b048493          	addi	s1,s1,176 # 80021270 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041c8:	4979                	li	s2,30
    800041ca:	a039                	j	800041d8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800041cc:	85a6                	mv	a1,s1
    800041ce:	8526                	mv	a0,s1
    800041d0:	ffffe097          	auipc	ra,0xffffe
    800041d4:	fe4080e7          	jalr	-28(ra) # 800021b4 <sleep>
    if(log.committing){
    800041d8:	50dc                	lw	a5,36(s1)
    800041da:	fbed                	bnez	a5,800041cc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041dc:	509c                	lw	a5,32(s1)
    800041de:	0017871b          	addiw	a4,a5,1
    800041e2:	0007069b          	sext.w	a3,a4
    800041e6:	0027179b          	slliw	a5,a4,0x2
    800041ea:	9fb9                	addw	a5,a5,a4
    800041ec:	0017979b          	slliw	a5,a5,0x1
    800041f0:	54d8                	lw	a4,44(s1)
    800041f2:	9fb9                	addw	a5,a5,a4
    800041f4:	00f95963          	bge	s2,a5,80004206 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800041f8:	85a6                	mv	a1,s1
    800041fa:	8526                	mv	a0,s1
    800041fc:	ffffe097          	auipc	ra,0xffffe
    80004200:	fb8080e7          	jalr	-72(ra) # 800021b4 <sleep>
    80004204:	bfd1                	j	800041d8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004206:	0001d517          	auipc	a0,0x1d
    8000420a:	06a50513          	addi	a0,a0,106 # 80021270 <log>
    8000420e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004210:	ffffd097          	auipc	ra,0xffffd
    80004214:	a88080e7          	jalr	-1400(ra) # 80000c98 <release>
      break;
    }
  }
}
    80004218:	60e2                	ld	ra,24(sp)
    8000421a:	6442                	ld	s0,16(sp)
    8000421c:	64a2                	ld	s1,8(sp)
    8000421e:	6902                	ld	s2,0(sp)
    80004220:	6105                	addi	sp,sp,32
    80004222:	8082                	ret

0000000080004224 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004224:	7139                	addi	sp,sp,-64
    80004226:	fc06                	sd	ra,56(sp)
    80004228:	f822                	sd	s0,48(sp)
    8000422a:	f426                	sd	s1,40(sp)
    8000422c:	f04a                	sd	s2,32(sp)
    8000422e:	ec4e                	sd	s3,24(sp)
    80004230:	e852                	sd	s4,16(sp)
    80004232:	e456                	sd	s5,8(sp)
    80004234:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004236:	0001d497          	auipc	s1,0x1d
    8000423a:	03a48493          	addi	s1,s1,58 # 80021270 <log>
    8000423e:	8526                	mv	a0,s1
    80004240:	ffffd097          	auipc	ra,0xffffd
    80004244:	9a4080e7          	jalr	-1628(ra) # 80000be4 <acquire>
  log.outstanding -= 1;
    80004248:	509c                	lw	a5,32(s1)
    8000424a:	37fd                	addiw	a5,a5,-1
    8000424c:	0007891b          	sext.w	s2,a5
    80004250:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004252:	50dc                	lw	a5,36(s1)
    80004254:	efb9                	bnez	a5,800042b2 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004256:	06091663          	bnez	s2,800042c2 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000425a:	0001d497          	auipc	s1,0x1d
    8000425e:	01648493          	addi	s1,s1,22 # 80021270 <log>
    80004262:	4785                	li	a5,1
    80004264:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004266:	8526                	mv	a0,s1
    80004268:	ffffd097          	auipc	ra,0xffffd
    8000426c:	a30080e7          	jalr	-1488(ra) # 80000c98 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004270:	54dc                	lw	a5,44(s1)
    80004272:	06f04763          	bgtz	a5,800042e0 <end_op+0xbc>
    acquire(&log.lock);
    80004276:	0001d497          	auipc	s1,0x1d
    8000427a:	ffa48493          	addi	s1,s1,-6 # 80021270 <log>
    8000427e:	8526                	mv	a0,s1
    80004280:	ffffd097          	auipc	ra,0xffffd
    80004284:	964080e7          	jalr	-1692(ra) # 80000be4 <acquire>
    log.committing = 0;
    80004288:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000428c:	8526                	mv	a0,s1
    8000428e:	ffffe097          	auipc	ra,0xffffe
    80004292:	0b2080e7          	jalr	178(ra) # 80002340 <wakeup>
    release(&log.lock);
    80004296:	8526                	mv	a0,s1
    80004298:	ffffd097          	auipc	ra,0xffffd
    8000429c:	a00080e7          	jalr	-1536(ra) # 80000c98 <release>
}
    800042a0:	70e2                	ld	ra,56(sp)
    800042a2:	7442                	ld	s0,48(sp)
    800042a4:	74a2                	ld	s1,40(sp)
    800042a6:	7902                	ld	s2,32(sp)
    800042a8:	69e2                	ld	s3,24(sp)
    800042aa:	6a42                	ld	s4,16(sp)
    800042ac:	6aa2                	ld	s5,8(sp)
    800042ae:	6121                	addi	sp,sp,64
    800042b0:	8082                	ret
    panic("log.committing");
    800042b2:	00004517          	auipc	a0,0x4
    800042b6:	39650513          	addi	a0,a0,918 # 80008648 <syscalls+0x200>
    800042ba:	ffffc097          	auipc	ra,0xffffc
    800042be:	284080e7          	jalr	644(ra) # 8000053e <panic>
    wakeup(&log);
    800042c2:	0001d497          	auipc	s1,0x1d
    800042c6:	fae48493          	addi	s1,s1,-82 # 80021270 <log>
    800042ca:	8526                	mv	a0,s1
    800042cc:	ffffe097          	auipc	ra,0xffffe
    800042d0:	074080e7          	jalr	116(ra) # 80002340 <wakeup>
  release(&log.lock);
    800042d4:	8526                	mv	a0,s1
    800042d6:	ffffd097          	auipc	ra,0xffffd
    800042da:	9c2080e7          	jalr	-1598(ra) # 80000c98 <release>
  if(do_commit){
    800042de:	b7c9                	j	800042a0 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042e0:	0001da97          	auipc	s5,0x1d
    800042e4:	fc0a8a93          	addi	s5,s5,-64 # 800212a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042e8:	0001da17          	auipc	s4,0x1d
    800042ec:	f88a0a13          	addi	s4,s4,-120 # 80021270 <log>
    800042f0:	018a2583          	lw	a1,24(s4)
    800042f4:	012585bb          	addw	a1,a1,s2
    800042f8:	2585                	addiw	a1,a1,1
    800042fa:	028a2503          	lw	a0,40(s4)
    800042fe:	fffff097          	auipc	ra,0xfffff
    80004302:	cd2080e7          	jalr	-814(ra) # 80002fd0 <bread>
    80004306:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004308:	000aa583          	lw	a1,0(s5)
    8000430c:	028a2503          	lw	a0,40(s4)
    80004310:	fffff097          	auipc	ra,0xfffff
    80004314:	cc0080e7          	jalr	-832(ra) # 80002fd0 <bread>
    80004318:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000431a:	40000613          	li	a2,1024
    8000431e:	05850593          	addi	a1,a0,88
    80004322:	05848513          	addi	a0,s1,88
    80004326:	ffffd097          	auipc	ra,0xffffd
    8000432a:	a1a080e7          	jalr	-1510(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    8000432e:	8526                	mv	a0,s1
    80004330:	fffff097          	auipc	ra,0xfffff
    80004334:	d92080e7          	jalr	-622(ra) # 800030c2 <bwrite>
    brelse(from);
    80004338:	854e                	mv	a0,s3
    8000433a:	fffff097          	auipc	ra,0xfffff
    8000433e:	dc6080e7          	jalr	-570(ra) # 80003100 <brelse>
    brelse(to);
    80004342:	8526                	mv	a0,s1
    80004344:	fffff097          	auipc	ra,0xfffff
    80004348:	dbc080e7          	jalr	-580(ra) # 80003100 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000434c:	2905                	addiw	s2,s2,1
    8000434e:	0a91                	addi	s5,s5,4
    80004350:	02ca2783          	lw	a5,44(s4)
    80004354:	f8f94ee3          	blt	s2,a5,800042f0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004358:	00000097          	auipc	ra,0x0
    8000435c:	c6a080e7          	jalr	-918(ra) # 80003fc2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004360:	4501                	li	a0,0
    80004362:	00000097          	auipc	ra,0x0
    80004366:	cda080e7          	jalr	-806(ra) # 8000403c <install_trans>
    log.lh.n = 0;
    8000436a:	0001d797          	auipc	a5,0x1d
    8000436e:	f207a923          	sw	zero,-206(a5) # 8002129c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004372:	00000097          	auipc	ra,0x0
    80004376:	c50080e7          	jalr	-944(ra) # 80003fc2 <write_head>
    8000437a:	bdf5                	j	80004276 <end_op+0x52>

000000008000437c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000437c:	1101                	addi	sp,sp,-32
    8000437e:	ec06                	sd	ra,24(sp)
    80004380:	e822                	sd	s0,16(sp)
    80004382:	e426                	sd	s1,8(sp)
    80004384:	e04a                	sd	s2,0(sp)
    80004386:	1000                	addi	s0,sp,32
    80004388:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000438a:	0001d917          	auipc	s2,0x1d
    8000438e:	ee690913          	addi	s2,s2,-282 # 80021270 <log>
    80004392:	854a                	mv	a0,s2
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	850080e7          	jalr	-1968(ra) # 80000be4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000439c:	02c92603          	lw	a2,44(s2)
    800043a0:	47f5                	li	a5,29
    800043a2:	06c7c563          	blt	a5,a2,8000440c <log_write+0x90>
    800043a6:	0001d797          	auipc	a5,0x1d
    800043aa:	ee67a783          	lw	a5,-282(a5) # 8002128c <log+0x1c>
    800043ae:	37fd                	addiw	a5,a5,-1
    800043b0:	04f65e63          	bge	a2,a5,8000440c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043b4:	0001d797          	auipc	a5,0x1d
    800043b8:	edc7a783          	lw	a5,-292(a5) # 80021290 <log+0x20>
    800043bc:	06f05063          	blez	a5,8000441c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043c0:	4781                	li	a5,0
    800043c2:	06c05563          	blez	a2,8000442c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043c6:	44cc                	lw	a1,12(s1)
    800043c8:	0001d717          	auipc	a4,0x1d
    800043cc:	ed870713          	addi	a4,a4,-296 # 800212a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800043d0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043d2:	4314                	lw	a3,0(a4)
    800043d4:	04b68c63          	beq	a3,a1,8000442c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800043d8:	2785                	addiw	a5,a5,1
    800043da:	0711                	addi	a4,a4,4
    800043dc:	fef61be3          	bne	a2,a5,800043d2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043e0:	0621                	addi	a2,a2,8
    800043e2:	060a                	slli	a2,a2,0x2
    800043e4:	0001d797          	auipc	a5,0x1d
    800043e8:	e8c78793          	addi	a5,a5,-372 # 80021270 <log>
    800043ec:	963e                	add	a2,a2,a5
    800043ee:	44dc                	lw	a5,12(s1)
    800043f0:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043f2:	8526                	mv	a0,s1
    800043f4:	fffff097          	auipc	ra,0xfffff
    800043f8:	daa080e7          	jalr	-598(ra) # 8000319e <bpin>
    log.lh.n++;
    800043fc:	0001d717          	auipc	a4,0x1d
    80004400:	e7470713          	addi	a4,a4,-396 # 80021270 <log>
    80004404:	575c                	lw	a5,44(a4)
    80004406:	2785                	addiw	a5,a5,1
    80004408:	d75c                	sw	a5,44(a4)
    8000440a:	a835                	j	80004446 <log_write+0xca>
    panic("too big a transaction");
    8000440c:	00004517          	auipc	a0,0x4
    80004410:	24c50513          	addi	a0,a0,588 # 80008658 <syscalls+0x210>
    80004414:	ffffc097          	auipc	ra,0xffffc
    80004418:	12a080e7          	jalr	298(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000441c:	00004517          	auipc	a0,0x4
    80004420:	25450513          	addi	a0,a0,596 # 80008670 <syscalls+0x228>
    80004424:	ffffc097          	auipc	ra,0xffffc
    80004428:	11a080e7          	jalr	282(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000442c:	00878713          	addi	a4,a5,8
    80004430:	00271693          	slli	a3,a4,0x2
    80004434:	0001d717          	auipc	a4,0x1d
    80004438:	e3c70713          	addi	a4,a4,-452 # 80021270 <log>
    8000443c:	9736                	add	a4,a4,a3
    8000443e:	44d4                	lw	a3,12(s1)
    80004440:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004442:	faf608e3          	beq	a2,a5,800043f2 <log_write+0x76>
  }
  release(&log.lock);
    80004446:	0001d517          	auipc	a0,0x1d
    8000444a:	e2a50513          	addi	a0,a0,-470 # 80021270 <log>
    8000444e:	ffffd097          	auipc	ra,0xffffd
    80004452:	84a080e7          	jalr	-1974(ra) # 80000c98 <release>
}
    80004456:	60e2                	ld	ra,24(sp)
    80004458:	6442                	ld	s0,16(sp)
    8000445a:	64a2                	ld	s1,8(sp)
    8000445c:	6902                	ld	s2,0(sp)
    8000445e:	6105                	addi	sp,sp,32
    80004460:	8082                	ret

0000000080004462 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004462:	1101                	addi	sp,sp,-32
    80004464:	ec06                	sd	ra,24(sp)
    80004466:	e822                	sd	s0,16(sp)
    80004468:	e426                	sd	s1,8(sp)
    8000446a:	e04a                	sd	s2,0(sp)
    8000446c:	1000                	addi	s0,sp,32
    8000446e:	84aa                	mv	s1,a0
    80004470:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004472:	00004597          	auipc	a1,0x4
    80004476:	21e58593          	addi	a1,a1,542 # 80008690 <syscalls+0x248>
    8000447a:	0521                	addi	a0,a0,8
    8000447c:	ffffc097          	auipc	ra,0xffffc
    80004480:	6d8080e7          	jalr	1752(ra) # 80000b54 <initlock>
  lk->name = name;
    80004484:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004488:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000448c:	0204a423          	sw	zero,40(s1)
}
    80004490:	60e2                	ld	ra,24(sp)
    80004492:	6442                	ld	s0,16(sp)
    80004494:	64a2                	ld	s1,8(sp)
    80004496:	6902                	ld	s2,0(sp)
    80004498:	6105                	addi	sp,sp,32
    8000449a:	8082                	ret

000000008000449c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000449c:	1101                	addi	sp,sp,-32
    8000449e:	ec06                	sd	ra,24(sp)
    800044a0:	e822                	sd	s0,16(sp)
    800044a2:	e426                	sd	s1,8(sp)
    800044a4:	e04a                	sd	s2,0(sp)
    800044a6:	1000                	addi	s0,sp,32
    800044a8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044aa:	00850913          	addi	s2,a0,8
    800044ae:	854a                	mv	a0,s2
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	734080e7          	jalr	1844(ra) # 80000be4 <acquire>
  while (lk->locked) {
    800044b8:	409c                	lw	a5,0(s1)
    800044ba:	cb89                	beqz	a5,800044cc <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044bc:	85ca                	mv	a1,s2
    800044be:	8526                	mv	a0,s1
    800044c0:	ffffe097          	auipc	ra,0xffffe
    800044c4:	cf4080e7          	jalr	-780(ra) # 800021b4 <sleep>
  while (lk->locked) {
    800044c8:	409c                	lw	a5,0(s1)
    800044ca:	fbed                	bnez	a5,800044bc <acquiresleep+0x20>
  }
  lk->locked = 1;
    800044cc:	4785                	li	a5,1
    800044ce:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044d0:	ffffd097          	auipc	ra,0xffffd
    800044d4:	4e0080e7          	jalr	1248(ra) # 800019b0 <myproc>
    800044d8:	591c                	lw	a5,48(a0)
    800044da:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800044dc:	854a                	mv	a0,s2
    800044de:	ffffc097          	auipc	ra,0xffffc
    800044e2:	7ba080e7          	jalr	1978(ra) # 80000c98 <release>
}
    800044e6:	60e2                	ld	ra,24(sp)
    800044e8:	6442                	ld	s0,16(sp)
    800044ea:	64a2                	ld	s1,8(sp)
    800044ec:	6902                	ld	s2,0(sp)
    800044ee:	6105                	addi	sp,sp,32
    800044f0:	8082                	ret

00000000800044f2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044f2:	1101                	addi	sp,sp,-32
    800044f4:	ec06                	sd	ra,24(sp)
    800044f6:	e822                	sd	s0,16(sp)
    800044f8:	e426                	sd	s1,8(sp)
    800044fa:	e04a                	sd	s2,0(sp)
    800044fc:	1000                	addi	s0,sp,32
    800044fe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004500:	00850913          	addi	s2,a0,8
    80004504:	854a                	mv	a0,s2
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	6de080e7          	jalr	1758(ra) # 80000be4 <acquire>
  lk->locked = 0;
    8000450e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004512:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004516:	8526                	mv	a0,s1
    80004518:	ffffe097          	auipc	ra,0xffffe
    8000451c:	e28080e7          	jalr	-472(ra) # 80002340 <wakeup>
  release(&lk->lk);
    80004520:	854a                	mv	a0,s2
    80004522:	ffffc097          	auipc	ra,0xffffc
    80004526:	776080e7          	jalr	1910(ra) # 80000c98 <release>
}
    8000452a:	60e2                	ld	ra,24(sp)
    8000452c:	6442                	ld	s0,16(sp)
    8000452e:	64a2                	ld	s1,8(sp)
    80004530:	6902                	ld	s2,0(sp)
    80004532:	6105                	addi	sp,sp,32
    80004534:	8082                	ret

0000000080004536 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004536:	7179                	addi	sp,sp,-48
    80004538:	f406                	sd	ra,40(sp)
    8000453a:	f022                	sd	s0,32(sp)
    8000453c:	ec26                	sd	s1,24(sp)
    8000453e:	e84a                	sd	s2,16(sp)
    80004540:	e44e                	sd	s3,8(sp)
    80004542:	1800                	addi	s0,sp,48
    80004544:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004546:	00850913          	addi	s2,a0,8
    8000454a:	854a                	mv	a0,s2
    8000454c:	ffffc097          	auipc	ra,0xffffc
    80004550:	698080e7          	jalr	1688(ra) # 80000be4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004554:	409c                	lw	a5,0(s1)
    80004556:	ef99                	bnez	a5,80004574 <holdingsleep+0x3e>
    80004558:	4481                	li	s1,0
  release(&lk->lk);
    8000455a:	854a                	mv	a0,s2
    8000455c:	ffffc097          	auipc	ra,0xffffc
    80004560:	73c080e7          	jalr	1852(ra) # 80000c98 <release>
  return r;
}
    80004564:	8526                	mv	a0,s1
    80004566:	70a2                	ld	ra,40(sp)
    80004568:	7402                	ld	s0,32(sp)
    8000456a:	64e2                	ld	s1,24(sp)
    8000456c:	6942                	ld	s2,16(sp)
    8000456e:	69a2                	ld	s3,8(sp)
    80004570:	6145                	addi	sp,sp,48
    80004572:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004574:	0284a983          	lw	s3,40(s1)
    80004578:	ffffd097          	auipc	ra,0xffffd
    8000457c:	438080e7          	jalr	1080(ra) # 800019b0 <myproc>
    80004580:	5904                	lw	s1,48(a0)
    80004582:	413484b3          	sub	s1,s1,s3
    80004586:	0014b493          	seqz	s1,s1
    8000458a:	bfc1                	j	8000455a <holdingsleep+0x24>

000000008000458c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000458c:	1141                	addi	sp,sp,-16
    8000458e:	e406                	sd	ra,8(sp)
    80004590:	e022                	sd	s0,0(sp)
    80004592:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004594:	00004597          	auipc	a1,0x4
    80004598:	10c58593          	addi	a1,a1,268 # 800086a0 <syscalls+0x258>
    8000459c:	0001d517          	auipc	a0,0x1d
    800045a0:	e1c50513          	addi	a0,a0,-484 # 800213b8 <ftable>
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	5b0080e7          	jalr	1456(ra) # 80000b54 <initlock>
}
    800045ac:	60a2                	ld	ra,8(sp)
    800045ae:	6402                	ld	s0,0(sp)
    800045b0:	0141                	addi	sp,sp,16
    800045b2:	8082                	ret

00000000800045b4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045b4:	1101                	addi	sp,sp,-32
    800045b6:	ec06                	sd	ra,24(sp)
    800045b8:	e822                	sd	s0,16(sp)
    800045ba:	e426                	sd	s1,8(sp)
    800045bc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045be:	0001d517          	auipc	a0,0x1d
    800045c2:	dfa50513          	addi	a0,a0,-518 # 800213b8 <ftable>
    800045c6:	ffffc097          	auipc	ra,0xffffc
    800045ca:	61e080e7          	jalr	1566(ra) # 80000be4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045ce:	0001d497          	auipc	s1,0x1d
    800045d2:	e0248493          	addi	s1,s1,-510 # 800213d0 <ftable+0x18>
    800045d6:	0001e717          	auipc	a4,0x1e
    800045da:	d9a70713          	addi	a4,a4,-614 # 80022370 <ftable+0xfb8>
    if(f->ref == 0){
    800045de:	40dc                	lw	a5,4(s1)
    800045e0:	cf99                	beqz	a5,800045fe <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045e2:	02848493          	addi	s1,s1,40
    800045e6:	fee49ce3          	bne	s1,a4,800045de <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045ea:	0001d517          	auipc	a0,0x1d
    800045ee:	dce50513          	addi	a0,a0,-562 # 800213b8 <ftable>
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	6a6080e7          	jalr	1702(ra) # 80000c98 <release>
  return 0;
    800045fa:	4481                	li	s1,0
    800045fc:	a819                	j	80004612 <filealloc+0x5e>
      f->ref = 1;
    800045fe:	4785                	li	a5,1
    80004600:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004602:	0001d517          	auipc	a0,0x1d
    80004606:	db650513          	addi	a0,a0,-586 # 800213b8 <ftable>
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	68e080e7          	jalr	1678(ra) # 80000c98 <release>
}
    80004612:	8526                	mv	a0,s1
    80004614:	60e2                	ld	ra,24(sp)
    80004616:	6442                	ld	s0,16(sp)
    80004618:	64a2                	ld	s1,8(sp)
    8000461a:	6105                	addi	sp,sp,32
    8000461c:	8082                	ret

000000008000461e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000461e:	1101                	addi	sp,sp,-32
    80004620:	ec06                	sd	ra,24(sp)
    80004622:	e822                	sd	s0,16(sp)
    80004624:	e426                	sd	s1,8(sp)
    80004626:	1000                	addi	s0,sp,32
    80004628:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000462a:	0001d517          	auipc	a0,0x1d
    8000462e:	d8e50513          	addi	a0,a0,-626 # 800213b8 <ftable>
    80004632:	ffffc097          	auipc	ra,0xffffc
    80004636:	5b2080e7          	jalr	1458(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    8000463a:	40dc                	lw	a5,4(s1)
    8000463c:	02f05263          	blez	a5,80004660 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004640:	2785                	addiw	a5,a5,1
    80004642:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004644:	0001d517          	auipc	a0,0x1d
    80004648:	d7450513          	addi	a0,a0,-652 # 800213b8 <ftable>
    8000464c:	ffffc097          	auipc	ra,0xffffc
    80004650:	64c080e7          	jalr	1612(ra) # 80000c98 <release>
  return f;
}
    80004654:	8526                	mv	a0,s1
    80004656:	60e2                	ld	ra,24(sp)
    80004658:	6442                	ld	s0,16(sp)
    8000465a:	64a2                	ld	s1,8(sp)
    8000465c:	6105                	addi	sp,sp,32
    8000465e:	8082                	ret
    panic("filedup");
    80004660:	00004517          	auipc	a0,0x4
    80004664:	04850513          	addi	a0,a0,72 # 800086a8 <syscalls+0x260>
    80004668:	ffffc097          	auipc	ra,0xffffc
    8000466c:	ed6080e7          	jalr	-298(ra) # 8000053e <panic>

0000000080004670 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004670:	7139                	addi	sp,sp,-64
    80004672:	fc06                	sd	ra,56(sp)
    80004674:	f822                	sd	s0,48(sp)
    80004676:	f426                	sd	s1,40(sp)
    80004678:	f04a                	sd	s2,32(sp)
    8000467a:	ec4e                	sd	s3,24(sp)
    8000467c:	e852                	sd	s4,16(sp)
    8000467e:	e456                	sd	s5,8(sp)
    80004680:	0080                	addi	s0,sp,64
    80004682:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004684:	0001d517          	auipc	a0,0x1d
    80004688:	d3450513          	addi	a0,a0,-716 # 800213b8 <ftable>
    8000468c:	ffffc097          	auipc	ra,0xffffc
    80004690:	558080e7          	jalr	1368(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    80004694:	40dc                	lw	a5,4(s1)
    80004696:	06f05163          	blez	a5,800046f8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000469a:	37fd                	addiw	a5,a5,-1
    8000469c:	0007871b          	sext.w	a4,a5
    800046a0:	c0dc                	sw	a5,4(s1)
    800046a2:	06e04363          	bgtz	a4,80004708 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046a6:	0004a903          	lw	s2,0(s1)
    800046aa:	0094ca83          	lbu	s5,9(s1)
    800046ae:	0104ba03          	ld	s4,16(s1)
    800046b2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046b6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046ba:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046be:	0001d517          	auipc	a0,0x1d
    800046c2:	cfa50513          	addi	a0,a0,-774 # 800213b8 <ftable>
    800046c6:	ffffc097          	auipc	ra,0xffffc
    800046ca:	5d2080e7          	jalr	1490(ra) # 80000c98 <release>

  if(ff.type == FD_PIPE){
    800046ce:	4785                	li	a5,1
    800046d0:	04f90d63          	beq	s2,a5,8000472a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046d4:	3979                	addiw	s2,s2,-2
    800046d6:	4785                	li	a5,1
    800046d8:	0527e063          	bltu	a5,s2,80004718 <fileclose+0xa8>
    begin_op();
    800046dc:	00000097          	auipc	ra,0x0
    800046e0:	ac8080e7          	jalr	-1336(ra) # 800041a4 <begin_op>
    iput(ff.ip);
    800046e4:	854e                	mv	a0,s3
    800046e6:	fffff097          	auipc	ra,0xfffff
    800046ea:	2a6080e7          	jalr	678(ra) # 8000398c <iput>
    end_op();
    800046ee:	00000097          	auipc	ra,0x0
    800046f2:	b36080e7          	jalr	-1226(ra) # 80004224 <end_op>
    800046f6:	a00d                	j	80004718 <fileclose+0xa8>
    panic("fileclose");
    800046f8:	00004517          	auipc	a0,0x4
    800046fc:	fb850513          	addi	a0,a0,-72 # 800086b0 <syscalls+0x268>
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	e3e080e7          	jalr	-450(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004708:	0001d517          	auipc	a0,0x1d
    8000470c:	cb050513          	addi	a0,a0,-848 # 800213b8 <ftable>
    80004710:	ffffc097          	auipc	ra,0xffffc
    80004714:	588080e7          	jalr	1416(ra) # 80000c98 <release>
  }
}
    80004718:	70e2                	ld	ra,56(sp)
    8000471a:	7442                	ld	s0,48(sp)
    8000471c:	74a2                	ld	s1,40(sp)
    8000471e:	7902                	ld	s2,32(sp)
    80004720:	69e2                	ld	s3,24(sp)
    80004722:	6a42                	ld	s4,16(sp)
    80004724:	6aa2                	ld	s5,8(sp)
    80004726:	6121                	addi	sp,sp,64
    80004728:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000472a:	85d6                	mv	a1,s5
    8000472c:	8552                	mv	a0,s4
    8000472e:	00000097          	auipc	ra,0x0
    80004732:	34c080e7          	jalr	844(ra) # 80004a7a <pipeclose>
    80004736:	b7cd                	j	80004718 <fileclose+0xa8>

0000000080004738 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004738:	715d                	addi	sp,sp,-80
    8000473a:	e486                	sd	ra,72(sp)
    8000473c:	e0a2                	sd	s0,64(sp)
    8000473e:	fc26                	sd	s1,56(sp)
    80004740:	f84a                	sd	s2,48(sp)
    80004742:	f44e                	sd	s3,40(sp)
    80004744:	0880                	addi	s0,sp,80
    80004746:	84aa                	mv	s1,a0
    80004748:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000474a:	ffffd097          	auipc	ra,0xffffd
    8000474e:	266080e7          	jalr	614(ra) # 800019b0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004752:	409c                	lw	a5,0(s1)
    80004754:	37f9                	addiw	a5,a5,-2
    80004756:	4705                	li	a4,1
    80004758:	04f76763          	bltu	a4,a5,800047a6 <filestat+0x6e>
    8000475c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000475e:	6c88                	ld	a0,24(s1)
    80004760:	fffff097          	auipc	ra,0xfffff
    80004764:	072080e7          	jalr	114(ra) # 800037d2 <ilock>
    stati(f->ip, &st);
    80004768:	fb840593          	addi	a1,s0,-72
    8000476c:	6c88                	ld	a0,24(s1)
    8000476e:	fffff097          	auipc	ra,0xfffff
    80004772:	2ee080e7          	jalr	750(ra) # 80003a5c <stati>
    iunlock(f->ip);
    80004776:	6c88                	ld	a0,24(s1)
    80004778:	fffff097          	auipc	ra,0xfffff
    8000477c:	11c080e7          	jalr	284(ra) # 80003894 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004780:	46e1                	li	a3,24
    80004782:	fb840613          	addi	a2,s0,-72
    80004786:	85ce                	mv	a1,s3
    80004788:	05093503          	ld	a0,80(s2)
    8000478c:	ffffd097          	auipc	ra,0xffffd
    80004790:	ee6080e7          	jalr	-282(ra) # 80001672 <copyout>
    80004794:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004798:	60a6                	ld	ra,72(sp)
    8000479a:	6406                	ld	s0,64(sp)
    8000479c:	74e2                	ld	s1,56(sp)
    8000479e:	7942                	ld	s2,48(sp)
    800047a0:	79a2                	ld	s3,40(sp)
    800047a2:	6161                	addi	sp,sp,80
    800047a4:	8082                	ret
  return -1;
    800047a6:	557d                	li	a0,-1
    800047a8:	bfc5                	j	80004798 <filestat+0x60>

00000000800047aa <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047aa:	7179                	addi	sp,sp,-48
    800047ac:	f406                	sd	ra,40(sp)
    800047ae:	f022                	sd	s0,32(sp)
    800047b0:	ec26                	sd	s1,24(sp)
    800047b2:	e84a                	sd	s2,16(sp)
    800047b4:	e44e                	sd	s3,8(sp)
    800047b6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047b8:	00854783          	lbu	a5,8(a0)
    800047bc:	c3d5                	beqz	a5,80004860 <fileread+0xb6>
    800047be:	84aa                	mv	s1,a0
    800047c0:	89ae                	mv	s3,a1
    800047c2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800047c4:	411c                	lw	a5,0(a0)
    800047c6:	4705                	li	a4,1
    800047c8:	04e78963          	beq	a5,a4,8000481a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047cc:	470d                	li	a4,3
    800047ce:	04e78d63          	beq	a5,a4,80004828 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800047d2:	4709                	li	a4,2
    800047d4:	06e79e63          	bne	a5,a4,80004850 <fileread+0xa6>
    ilock(f->ip);
    800047d8:	6d08                	ld	a0,24(a0)
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	ff8080e7          	jalr	-8(ra) # 800037d2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047e2:	874a                	mv	a4,s2
    800047e4:	5094                	lw	a3,32(s1)
    800047e6:	864e                	mv	a2,s3
    800047e8:	4585                	li	a1,1
    800047ea:	6c88                	ld	a0,24(s1)
    800047ec:	fffff097          	auipc	ra,0xfffff
    800047f0:	29a080e7          	jalr	666(ra) # 80003a86 <readi>
    800047f4:	892a                	mv	s2,a0
    800047f6:	00a05563          	blez	a0,80004800 <fileread+0x56>
      f->off += r;
    800047fa:	509c                	lw	a5,32(s1)
    800047fc:	9fa9                	addw	a5,a5,a0
    800047fe:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004800:	6c88                	ld	a0,24(s1)
    80004802:	fffff097          	auipc	ra,0xfffff
    80004806:	092080e7          	jalr	146(ra) # 80003894 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000480a:	854a                	mv	a0,s2
    8000480c:	70a2                	ld	ra,40(sp)
    8000480e:	7402                	ld	s0,32(sp)
    80004810:	64e2                	ld	s1,24(sp)
    80004812:	6942                	ld	s2,16(sp)
    80004814:	69a2                	ld	s3,8(sp)
    80004816:	6145                	addi	sp,sp,48
    80004818:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000481a:	6908                	ld	a0,16(a0)
    8000481c:	00000097          	auipc	ra,0x0
    80004820:	3c8080e7          	jalr	968(ra) # 80004be4 <piperead>
    80004824:	892a                	mv	s2,a0
    80004826:	b7d5                	j	8000480a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004828:	02451783          	lh	a5,36(a0)
    8000482c:	03079693          	slli	a3,a5,0x30
    80004830:	92c1                	srli	a3,a3,0x30
    80004832:	4725                	li	a4,9
    80004834:	02d76863          	bltu	a4,a3,80004864 <fileread+0xba>
    80004838:	0792                	slli	a5,a5,0x4
    8000483a:	0001d717          	auipc	a4,0x1d
    8000483e:	ade70713          	addi	a4,a4,-1314 # 80021318 <devsw>
    80004842:	97ba                	add	a5,a5,a4
    80004844:	639c                	ld	a5,0(a5)
    80004846:	c38d                	beqz	a5,80004868 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004848:	4505                	li	a0,1
    8000484a:	9782                	jalr	a5
    8000484c:	892a                	mv	s2,a0
    8000484e:	bf75                	j	8000480a <fileread+0x60>
    panic("fileread");
    80004850:	00004517          	auipc	a0,0x4
    80004854:	e7050513          	addi	a0,a0,-400 # 800086c0 <syscalls+0x278>
    80004858:	ffffc097          	auipc	ra,0xffffc
    8000485c:	ce6080e7          	jalr	-794(ra) # 8000053e <panic>
    return -1;
    80004860:	597d                	li	s2,-1
    80004862:	b765                	j	8000480a <fileread+0x60>
      return -1;
    80004864:	597d                	li	s2,-1
    80004866:	b755                	j	8000480a <fileread+0x60>
    80004868:	597d                	li	s2,-1
    8000486a:	b745                	j	8000480a <fileread+0x60>

000000008000486c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000486c:	715d                	addi	sp,sp,-80
    8000486e:	e486                	sd	ra,72(sp)
    80004870:	e0a2                	sd	s0,64(sp)
    80004872:	fc26                	sd	s1,56(sp)
    80004874:	f84a                	sd	s2,48(sp)
    80004876:	f44e                	sd	s3,40(sp)
    80004878:	f052                	sd	s4,32(sp)
    8000487a:	ec56                	sd	s5,24(sp)
    8000487c:	e85a                	sd	s6,16(sp)
    8000487e:	e45e                	sd	s7,8(sp)
    80004880:	e062                	sd	s8,0(sp)
    80004882:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004884:	00954783          	lbu	a5,9(a0)
    80004888:	10078663          	beqz	a5,80004994 <filewrite+0x128>
    8000488c:	892a                	mv	s2,a0
    8000488e:	8aae                	mv	s5,a1
    80004890:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004892:	411c                	lw	a5,0(a0)
    80004894:	4705                	li	a4,1
    80004896:	02e78263          	beq	a5,a4,800048ba <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000489a:	470d                	li	a4,3
    8000489c:	02e78663          	beq	a5,a4,800048c8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800048a0:	4709                	li	a4,2
    800048a2:	0ee79163          	bne	a5,a4,80004984 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048a6:	0ac05d63          	blez	a2,80004960 <filewrite+0xf4>
    int i = 0;
    800048aa:	4981                	li	s3,0
    800048ac:	6b05                	lui	s6,0x1
    800048ae:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800048b2:	6b85                	lui	s7,0x1
    800048b4:	c00b8b9b          	addiw	s7,s7,-1024
    800048b8:	a861                	j	80004950 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800048ba:	6908                	ld	a0,16(a0)
    800048bc:	00000097          	auipc	ra,0x0
    800048c0:	22e080e7          	jalr	558(ra) # 80004aea <pipewrite>
    800048c4:	8a2a                	mv	s4,a0
    800048c6:	a045                	j	80004966 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048c8:	02451783          	lh	a5,36(a0)
    800048cc:	03079693          	slli	a3,a5,0x30
    800048d0:	92c1                	srli	a3,a3,0x30
    800048d2:	4725                	li	a4,9
    800048d4:	0cd76263          	bltu	a4,a3,80004998 <filewrite+0x12c>
    800048d8:	0792                	slli	a5,a5,0x4
    800048da:	0001d717          	auipc	a4,0x1d
    800048de:	a3e70713          	addi	a4,a4,-1474 # 80021318 <devsw>
    800048e2:	97ba                	add	a5,a5,a4
    800048e4:	679c                	ld	a5,8(a5)
    800048e6:	cbdd                	beqz	a5,8000499c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800048e8:	4505                	li	a0,1
    800048ea:	9782                	jalr	a5
    800048ec:	8a2a                	mv	s4,a0
    800048ee:	a8a5                	j	80004966 <filewrite+0xfa>
    800048f0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800048f4:	00000097          	auipc	ra,0x0
    800048f8:	8b0080e7          	jalr	-1872(ra) # 800041a4 <begin_op>
      ilock(f->ip);
    800048fc:	01893503          	ld	a0,24(s2)
    80004900:	fffff097          	auipc	ra,0xfffff
    80004904:	ed2080e7          	jalr	-302(ra) # 800037d2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004908:	8762                	mv	a4,s8
    8000490a:	02092683          	lw	a3,32(s2)
    8000490e:	01598633          	add	a2,s3,s5
    80004912:	4585                	li	a1,1
    80004914:	01893503          	ld	a0,24(s2)
    80004918:	fffff097          	auipc	ra,0xfffff
    8000491c:	266080e7          	jalr	614(ra) # 80003b7e <writei>
    80004920:	84aa                	mv	s1,a0
    80004922:	00a05763          	blez	a0,80004930 <filewrite+0xc4>
        f->off += r;
    80004926:	02092783          	lw	a5,32(s2)
    8000492a:	9fa9                	addw	a5,a5,a0
    8000492c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004930:	01893503          	ld	a0,24(s2)
    80004934:	fffff097          	auipc	ra,0xfffff
    80004938:	f60080e7          	jalr	-160(ra) # 80003894 <iunlock>
      end_op();
    8000493c:	00000097          	auipc	ra,0x0
    80004940:	8e8080e7          	jalr	-1816(ra) # 80004224 <end_op>

      if(r != n1){
    80004944:	009c1f63          	bne	s8,s1,80004962 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004948:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000494c:	0149db63          	bge	s3,s4,80004962 <filewrite+0xf6>
      int n1 = n - i;
    80004950:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004954:	84be                	mv	s1,a5
    80004956:	2781                	sext.w	a5,a5
    80004958:	f8fb5ce3          	bge	s6,a5,800048f0 <filewrite+0x84>
    8000495c:	84de                	mv	s1,s7
    8000495e:	bf49                	j	800048f0 <filewrite+0x84>
    int i = 0;
    80004960:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004962:	013a1f63          	bne	s4,s3,80004980 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004966:	8552                	mv	a0,s4
    80004968:	60a6                	ld	ra,72(sp)
    8000496a:	6406                	ld	s0,64(sp)
    8000496c:	74e2                	ld	s1,56(sp)
    8000496e:	7942                	ld	s2,48(sp)
    80004970:	79a2                	ld	s3,40(sp)
    80004972:	7a02                	ld	s4,32(sp)
    80004974:	6ae2                	ld	s5,24(sp)
    80004976:	6b42                	ld	s6,16(sp)
    80004978:	6ba2                	ld	s7,8(sp)
    8000497a:	6c02                	ld	s8,0(sp)
    8000497c:	6161                	addi	sp,sp,80
    8000497e:	8082                	ret
    ret = (i == n ? n : -1);
    80004980:	5a7d                	li	s4,-1
    80004982:	b7d5                	j	80004966 <filewrite+0xfa>
    panic("filewrite");
    80004984:	00004517          	auipc	a0,0x4
    80004988:	d4c50513          	addi	a0,a0,-692 # 800086d0 <syscalls+0x288>
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	bb2080e7          	jalr	-1102(ra) # 8000053e <panic>
    return -1;
    80004994:	5a7d                	li	s4,-1
    80004996:	bfc1                	j	80004966 <filewrite+0xfa>
      return -1;
    80004998:	5a7d                	li	s4,-1
    8000499a:	b7f1                	j	80004966 <filewrite+0xfa>
    8000499c:	5a7d                	li	s4,-1
    8000499e:	b7e1                	j	80004966 <filewrite+0xfa>

00000000800049a0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049a0:	7179                	addi	sp,sp,-48
    800049a2:	f406                	sd	ra,40(sp)
    800049a4:	f022                	sd	s0,32(sp)
    800049a6:	ec26                	sd	s1,24(sp)
    800049a8:	e84a                	sd	s2,16(sp)
    800049aa:	e44e                	sd	s3,8(sp)
    800049ac:	e052                	sd	s4,0(sp)
    800049ae:	1800                	addi	s0,sp,48
    800049b0:	84aa                	mv	s1,a0
    800049b2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049b4:	0005b023          	sd	zero,0(a1)
    800049b8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800049bc:	00000097          	auipc	ra,0x0
    800049c0:	bf8080e7          	jalr	-1032(ra) # 800045b4 <filealloc>
    800049c4:	e088                	sd	a0,0(s1)
    800049c6:	c551                	beqz	a0,80004a52 <pipealloc+0xb2>
    800049c8:	00000097          	auipc	ra,0x0
    800049cc:	bec080e7          	jalr	-1044(ra) # 800045b4 <filealloc>
    800049d0:	00aa3023          	sd	a0,0(s4)
    800049d4:	c92d                	beqz	a0,80004a46 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800049d6:	ffffc097          	auipc	ra,0xffffc
    800049da:	11e080e7          	jalr	286(ra) # 80000af4 <kalloc>
    800049de:	892a                	mv	s2,a0
    800049e0:	c125                	beqz	a0,80004a40 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800049e2:	4985                	li	s3,1
    800049e4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049e8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049ec:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049f0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049f4:	00004597          	auipc	a1,0x4
    800049f8:	cec58593          	addi	a1,a1,-788 # 800086e0 <syscalls+0x298>
    800049fc:	ffffc097          	auipc	ra,0xffffc
    80004a00:	158080e7          	jalr	344(ra) # 80000b54 <initlock>
  (*f0)->type = FD_PIPE;
    80004a04:	609c                	ld	a5,0(s1)
    80004a06:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a0a:	609c                	ld	a5,0(s1)
    80004a0c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a10:	609c                	ld	a5,0(s1)
    80004a12:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a16:	609c                	ld	a5,0(s1)
    80004a18:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a1c:	000a3783          	ld	a5,0(s4)
    80004a20:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a24:	000a3783          	ld	a5,0(s4)
    80004a28:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a2c:	000a3783          	ld	a5,0(s4)
    80004a30:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a34:	000a3783          	ld	a5,0(s4)
    80004a38:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a3c:	4501                	li	a0,0
    80004a3e:	a025                	j	80004a66 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a40:	6088                	ld	a0,0(s1)
    80004a42:	e501                	bnez	a0,80004a4a <pipealloc+0xaa>
    80004a44:	a039                	j	80004a52 <pipealloc+0xb2>
    80004a46:	6088                	ld	a0,0(s1)
    80004a48:	c51d                	beqz	a0,80004a76 <pipealloc+0xd6>
    fileclose(*f0);
    80004a4a:	00000097          	auipc	ra,0x0
    80004a4e:	c26080e7          	jalr	-986(ra) # 80004670 <fileclose>
  if(*f1)
    80004a52:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a56:	557d                	li	a0,-1
  if(*f1)
    80004a58:	c799                	beqz	a5,80004a66 <pipealloc+0xc6>
    fileclose(*f1);
    80004a5a:	853e                	mv	a0,a5
    80004a5c:	00000097          	auipc	ra,0x0
    80004a60:	c14080e7          	jalr	-1004(ra) # 80004670 <fileclose>
  return -1;
    80004a64:	557d                	li	a0,-1
}
    80004a66:	70a2                	ld	ra,40(sp)
    80004a68:	7402                	ld	s0,32(sp)
    80004a6a:	64e2                	ld	s1,24(sp)
    80004a6c:	6942                	ld	s2,16(sp)
    80004a6e:	69a2                	ld	s3,8(sp)
    80004a70:	6a02                	ld	s4,0(sp)
    80004a72:	6145                	addi	sp,sp,48
    80004a74:	8082                	ret
  return -1;
    80004a76:	557d                	li	a0,-1
    80004a78:	b7fd                	j	80004a66 <pipealloc+0xc6>

0000000080004a7a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a7a:	1101                	addi	sp,sp,-32
    80004a7c:	ec06                	sd	ra,24(sp)
    80004a7e:	e822                	sd	s0,16(sp)
    80004a80:	e426                	sd	s1,8(sp)
    80004a82:	e04a                	sd	s2,0(sp)
    80004a84:	1000                	addi	s0,sp,32
    80004a86:	84aa                	mv	s1,a0
    80004a88:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a8a:	ffffc097          	auipc	ra,0xffffc
    80004a8e:	15a080e7          	jalr	346(ra) # 80000be4 <acquire>
  if(writable){
    80004a92:	02090d63          	beqz	s2,80004acc <pipeclose+0x52>
    pi->writeopen = 0;
    80004a96:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a9a:	21848513          	addi	a0,s1,536
    80004a9e:	ffffe097          	auipc	ra,0xffffe
    80004aa2:	8a2080e7          	jalr	-1886(ra) # 80002340 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004aa6:	2204b783          	ld	a5,544(s1)
    80004aaa:	eb95                	bnez	a5,80004ade <pipeclose+0x64>
    release(&pi->lock);
    80004aac:	8526                	mv	a0,s1
    80004aae:	ffffc097          	auipc	ra,0xffffc
    80004ab2:	1ea080e7          	jalr	490(ra) # 80000c98 <release>
    kfree((char*)pi);
    80004ab6:	8526                	mv	a0,s1
    80004ab8:	ffffc097          	auipc	ra,0xffffc
    80004abc:	f40080e7          	jalr	-192(ra) # 800009f8 <kfree>
  } else
    release(&pi->lock);
}
    80004ac0:	60e2                	ld	ra,24(sp)
    80004ac2:	6442                	ld	s0,16(sp)
    80004ac4:	64a2                	ld	s1,8(sp)
    80004ac6:	6902                	ld	s2,0(sp)
    80004ac8:	6105                	addi	sp,sp,32
    80004aca:	8082                	ret
    pi->readopen = 0;
    80004acc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ad0:	21c48513          	addi	a0,s1,540
    80004ad4:	ffffe097          	auipc	ra,0xffffe
    80004ad8:	86c080e7          	jalr	-1940(ra) # 80002340 <wakeup>
    80004adc:	b7e9                	j	80004aa6 <pipeclose+0x2c>
    release(&pi->lock);
    80004ade:	8526                	mv	a0,s1
    80004ae0:	ffffc097          	auipc	ra,0xffffc
    80004ae4:	1b8080e7          	jalr	440(ra) # 80000c98 <release>
}
    80004ae8:	bfe1                	j	80004ac0 <pipeclose+0x46>

0000000080004aea <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004aea:	7159                	addi	sp,sp,-112
    80004aec:	f486                	sd	ra,104(sp)
    80004aee:	f0a2                	sd	s0,96(sp)
    80004af0:	eca6                	sd	s1,88(sp)
    80004af2:	e8ca                	sd	s2,80(sp)
    80004af4:	e4ce                	sd	s3,72(sp)
    80004af6:	e0d2                	sd	s4,64(sp)
    80004af8:	fc56                	sd	s5,56(sp)
    80004afa:	f85a                	sd	s6,48(sp)
    80004afc:	f45e                	sd	s7,40(sp)
    80004afe:	f062                	sd	s8,32(sp)
    80004b00:	ec66                	sd	s9,24(sp)
    80004b02:	1880                	addi	s0,sp,112
    80004b04:	84aa                	mv	s1,a0
    80004b06:	8aae                	mv	s5,a1
    80004b08:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b0a:	ffffd097          	auipc	ra,0xffffd
    80004b0e:	ea6080e7          	jalr	-346(ra) # 800019b0 <myproc>
    80004b12:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004b14:	8526                	mv	a0,s1
    80004b16:	ffffc097          	auipc	ra,0xffffc
    80004b1a:	0ce080e7          	jalr	206(ra) # 80000be4 <acquire>
  while(i < n){
    80004b1e:	0d405163          	blez	s4,80004be0 <pipewrite+0xf6>
    80004b22:	8ba6                	mv	s7,s1
  int i = 0;
    80004b24:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b26:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004b28:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b2c:	21c48c13          	addi	s8,s1,540
    80004b30:	a08d                	j	80004b92 <pipewrite+0xa8>
      release(&pi->lock);
    80004b32:	8526                	mv	a0,s1
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	164080e7          	jalr	356(ra) # 80000c98 <release>
      return -1;
    80004b3c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b3e:	854a                	mv	a0,s2
    80004b40:	70a6                	ld	ra,104(sp)
    80004b42:	7406                	ld	s0,96(sp)
    80004b44:	64e6                	ld	s1,88(sp)
    80004b46:	6946                	ld	s2,80(sp)
    80004b48:	69a6                	ld	s3,72(sp)
    80004b4a:	6a06                	ld	s4,64(sp)
    80004b4c:	7ae2                	ld	s5,56(sp)
    80004b4e:	7b42                	ld	s6,48(sp)
    80004b50:	7ba2                	ld	s7,40(sp)
    80004b52:	7c02                	ld	s8,32(sp)
    80004b54:	6ce2                	ld	s9,24(sp)
    80004b56:	6165                	addi	sp,sp,112
    80004b58:	8082                	ret
      wakeup(&pi->nread);
    80004b5a:	8566                	mv	a0,s9
    80004b5c:	ffffd097          	auipc	ra,0xffffd
    80004b60:	7e4080e7          	jalr	2020(ra) # 80002340 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b64:	85de                	mv	a1,s7
    80004b66:	8562                	mv	a0,s8
    80004b68:	ffffd097          	auipc	ra,0xffffd
    80004b6c:	64c080e7          	jalr	1612(ra) # 800021b4 <sleep>
    80004b70:	a839                	j	80004b8e <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b72:	21c4a783          	lw	a5,540(s1)
    80004b76:	0017871b          	addiw	a4,a5,1
    80004b7a:	20e4ae23          	sw	a4,540(s1)
    80004b7e:	1ff7f793          	andi	a5,a5,511
    80004b82:	97a6                	add	a5,a5,s1
    80004b84:	f9f44703          	lbu	a4,-97(s0)
    80004b88:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b8c:	2905                	addiw	s2,s2,1
  while(i < n){
    80004b8e:	03495d63          	bge	s2,s4,80004bc8 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004b92:	2204a783          	lw	a5,544(s1)
    80004b96:	dfd1                	beqz	a5,80004b32 <pipewrite+0x48>
    80004b98:	0289a783          	lw	a5,40(s3)
    80004b9c:	fbd9                	bnez	a5,80004b32 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b9e:	2184a783          	lw	a5,536(s1)
    80004ba2:	21c4a703          	lw	a4,540(s1)
    80004ba6:	2007879b          	addiw	a5,a5,512
    80004baa:	faf708e3          	beq	a4,a5,80004b5a <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bae:	4685                	li	a3,1
    80004bb0:	01590633          	add	a2,s2,s5
    80004bb4:	f9f40593          	addi	a1,s0,-97
    80004bb8:	0509b503          	ld	a0,80(s3)
    80004bbc:	ffffd097          	auipc	ra,0xffffd
    80004bc0:	b42080e7          	jalr	-1214(ra) # 800016fe <copyin>
    80004bc4:	fb6517e3          	bne	a0,s6,80004b72 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004bc8:	21848513          	addi	a0,s1,536
    80004bcc:	ffffd097          	auipc	ra,0xffffd
    80004bd0:	774080e7          	jalr	1908(ra) # 80002340 <wakeup>
  release(&pi->lock);
    80004bd4:	8526                	mv	a0,s1
    80004bd6:	ffffc097          	auipc	ra,0xffffc
    80004bda:	0c2080e7          	jalr	194(ra) # 80000c98 <release>
  return i;
    80004bde:	b785                	j	80004b3e <pipewrite+0x54>
  int i = 0;
    80004be0:	4901                	li	s2,0
    80004be2:	b7dd                	j	80004bc8 <pipewrite+0xde>

0000000080004be4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004be4:	715d                	addi	sp,sp,-80
    80004be6:	e486                	sd	ra,72(sp)
    80004be8:	e0a2                	sd	s0,64(sp)
    80004bea:	fc26                	sd	s1,56(sp)
    80004bec:	f84a                	sd	s2,48(sp)
    80004bee:	f44e                	sd	s3,40(sp)
    80004bf0:	f052                	sd	s4,32(sp)
    80004bf2:	ec56                	sd	s5,24(sp)
    80004bf4:	e85a                	sd	s6,16(sp)
    80004bf6:	0880                	addi	s0,sp,80
    80004bf8:	84aa                	mv	s1,a0
    80004bfa:	892e                	mv	s2,a1
    80004bfc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004bfe:	ffffd097          	auipc	ra,0xffffd
    80004c02:	db2080e7          	jalr	-590(ra) # 800019b0 <myproc>
    80004c06:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c08:	8b26                	mv	s6,s1
    80004c0a:	8526                	mv	a0,s1
    80004c0c:	ffffc097          	auipc	ra,0xffffc
    80004c10:	fd8080e7          	jalr	-40(ra) # 80000be4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c14:	2184a703          	lw	a4,536(s1)
    80004c18:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c1c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c20:	02f71463          	bne	a4,a5,80004c48 <piperead+0x64>
    80004c24:	2244a783          	lw	a5,548(s1)
    80004c28:	c385                	beqz	a5,80004c48 <piperead+0x64>
    if(pr->killed){
    80004c2a:	028a2783          	lw	a5,40(s4)
    80004c2e:	ebc1                	bnez	a5,80004cbe <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c30:	85da                	mv	a1,s6
    80004c32:	854e                	mv	a0,s3
    80004c34:	ffffd097          	auipc	ra,0xffffd
    80004c38:	580080e7          	jalr	1408(ra) # 800021b4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c3c:	2184a703          	lw	a4,536(s1)
    80004c40:	21c4a783          	lw	a5,540(s1)
    80004c44:	fef700e3          	beq	a4,a5,80004c24 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c48:	09505263          	blez	s5,80004ccc <piperead+0xe8>
    80004c4c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c4e:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004c50:	2184a783          	lw	a5,536(s1)
    80004c54:	21c4a703          	lw	a4,540(s1)
    80004c58:	02f70d63          	beq	a4,a5,80004c92 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c5c:	0017871b          	addiw	a4,a5,1
    80004c60:	20e4ac23          	sw	a4,536(s1)
    80004c64:	1ff7f793          	andi	a5,a5,511
    80004c68:	97a6                	add	a5,a5,s1
    80004c6a:	0187c783          	lbu	a5,24(a5)
    80004c6e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c72:	4685                	li	a3,1
    80004c74:	fbf40613          	addi	a2,s0,-65
    80004c78:	85ca                	mv	a1,s2
    80004c7a:	050a3503          	ld	a0,80(s4)
    80004c7e:	ffffd097          	auipc	ra,0xffffd
    80004c82:	9f4080e7          	jalr	-1548(ra) # 80001672 <copyout>
    80004c86:	01650663          	beq	a0,s6,80004c92 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c8a:	2985                	addiw	s3,s3,1
    80004c8c:	0905                	addi	s2,s2,1
    80004c8e:	fd3a91e3          	bne	s5,s3,80004c50 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c92:	21c48513          	addi	a0,s1,540
    80004c96:	ffffd097          	auipc	ra,0xffffd
    80004c9a:	6aa080e7          	jalr	1706(ra) # 80002340 <wakeup>
  release(&pi->lock);
    80004c9e:	8526                	mv	a0,s1
    80004ca0:	ffffc097          	auipc	ra,0xffffc
    80004ca4:	ff8080e7          	jalr	-8(ra) # 80000c98 <release>
  return i;
}
    80004ca8:	854e                	mv	a0,s3
    80004caa:	60a6                	ld	ra,72(sp)
    80004cac:	6406                	ld	s0,64(sp)
    80004cae:	74e2                	ld	s1,56(sp)
    80004cb0:	7942                	ld	s2,48(sp)
    80004cb2:	79a2                	ld	s3,40(sp)
    80004cb4:	7a02                	ld	s4,32(sp)
    80004cb6:	6ae2                	ld	s5,24(sp)
    80004cb8:	6b42                	ld	s6,16(sp)
    80004cba:	6161                	addi	sp,sp,80
    80004cbc:	8082                	ret
      release(&pi->lock);
    80004cbe:	8526                	mv	a0,s1
    80004cc0:	ffffc097          	auipc	ra,0xffffc
    80004cc4:	fd8080e7          	jalr	-40(ra) # 80000c98 <release>
      return -1;
    80004cc8:	59fd                	li	s3,-1
    80004cca:	bff9                	j	80004ca8 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ccc:	4981                	li	s3,0
    80004cce:	b7d1                	j	80004c92 <piperead+0xae>

0000000080004cd0 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004cd0:	df010113          	addi	sp,sp,-528
    80004cd4:	20113423          	sd	ra,520(sp)
    80004cd8:	20813023          	sd	s0,512(sp)
    80004cdc:	ffa6                	sd	s1,504(sp)
    80004cde:	fbca                	sd	s2,496(sp)
    80004ce0:	f7ce                	sd	s3,488(sp)
    80004ce2:	f3d2                	sd	s4,480(sp)
    80004ce4:	efd6                	sd	s5,472(sp)
    80004ce6:	ebda                	sd	s6,464(sp)
    80004ce8:	e7de                	sd	s7,456(sp)
    80004cea:	e3e2                	sd	s8,448(sp)
    80004cec:	ff66                	sd	s9,440(sp)
    80004cee:	fb6a                	sd	s10,432(sp)
    80004cf0:	f76e                	sd	s11,424(sp)
    80004cf2:	0c00                	addi	s0,sp,528
    80004cf4:	84aa                	mv	s1,a0
    80004cf6:	dea43c23          	sd	a0,-520(s0)
    80004cfa:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004cfe:	ffffd097          	auipc	ra,0xffffd
    80004d02:	cb2080e7          	jalr	-846(ra) # 800019b0 <myproc>
    80004d06:	892a                	mv	s2,a0

  begin_op();
    80004d08:	fffff097          	auipc	ra,0xfffff
    80004d0c:	49c080e7          	jalr	1180(ra) # 800041a4 <begin_op>

  if((ip = namei(path)) == 0){
    80004d10:	8526                	mv	a0,s1
    80004d12:	fffff097          	auipc	ra,0xfffff
    80004d16:	276080e7          	jalr	630(ra) # 80003f88 <namei>
    80004d1a:	c92d                	beqz	a0,80004d8c <exec+0xbc>
    80004d1c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d1e:	fffff097          	auipc	ra,0xfffff
    80004d22:	ab4080e7          	jalr	-1356(ra) # 800037d2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d26:	04000713          	li	a4,64
    80004d2a:	4681                	li	a3,0
    80004d2c:	e5040613          	addi	a2,s0,-432
    80004d30:	4581                	li	a1,0
    80004d32:	8526                	mv	a0,s1
    80004d34:	fffff097          	auipc	ra,0xfffff
    80004d38:	d52080e7          	jalr	-686(ra) # 80003a86 <readi>
    80004d3c:	04000793          	li	a5,64
    80004d40:	00f51a63          	bne	a0,a5,80004d54 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d44:	e5042703          	lw	a4,-432(s0)
    80004d48:	464c47b7          	lui	a5,0x464c4
    80004d4c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d50:	04f70463          	beq	a4,a5,80004d98 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d54:	8526                	mv	a0,s1
    80004d56:	fffff097          	auipc	ra,0xfffff
    80004d5a:	cde080e7          	jalr	-802(ra) # 80003a34 <iunlockput>
    end_op();
    80004d5e:	fffff097          	auipc	ra,0xfffff
    80004d62:	4c6080e7          	jalr	1222(ra) # 80004224 <end_op>
  }
  return -1;
    80004d66:	557d                	li	a0,-1
}
    80004d68:	20813083          	ld	ra,520(sp)
    80004d6c:	20013403          	ld	s0,512(sp)
    80004d70:	74fe                	ld	s1,504(sp)
    80004d72:	795e                	ld	s2,496(sp)
    80004d74:	79be                	ld	s3,488(sp)
    80004d76:	7a1e                	ld	s4,480(sp)
    80004d78:	6afe                	ld	s5,472(sp)
    80004d7a:	6b5e                	ld	s6,464(sp)
    80004d7c:	6bbe                	ld	s7,456(sp)
    80004d7e:	6c1e                	ld	s8,448(sp)
    80004d80:	7cfa                	ld	s9,440(sp)
    80004d82:	7d5a                	ld	s10,432(sp)
    80004d84:	7dba                	ld	s11,424(sp)
    80004d86:	21010113          	addi	sp,sp,528
    80004d8a:	8082                	ret
    end_op();
    80004d8c:	fffff097          	auipc	ra,0xfffff
    80004d90:	498080e7          	jalr	1176(ra) # 80004224 <end_op>
    return -1;
    80004d94:	557d                	li	a0,-1
    80004d96:	bfc9                	j	80004d68 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d98:	854a                	mv	a0,s2
    80004d9a:	ffffd097          	auipc	ra,0xffffd
    80004d9e:	cda080e7          	jalr	-806(ra) # 80001a74 <proc_pagetable>
    80004da2:	8baa                	mv	s7,a0
    80004da4:	d945                	beqz	a0,80004d54 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004da6:	e7042983          	lw	s3,-400(s0)
    80004daa:	e8845783          	lhu	a5,-376(s0)
    80004dae:	c7ad                	beqz	a5,80004e18 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004db0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004db2:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80004db4:	6c85                	lui	s9,0x1
    80004db6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004dba:	def43823          	sd	a5,-528(s0)
    80004dbe:	a42d                	j	80004fe8 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004dc0:	00004517          	auipc	a0,0x4
    80004dc4:	92850513          	addi	a0,a0,-1752 # 800086e8 <syscalls+0x2a0>
    80004dc8:	ffffb097          	auipc	ra,0xffffb
    80004dcc:	776080e7          	jalr	1910(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004dd0:	8756                	mv	a4,s5
    80004dd2:	012d86bb          	addw	a3,s11,s2
    80004dd6:	4581                	li	a1,0
    80004dd8:	8526                	mv	a0,s1
    80004dda:	fffff097          	auipc	ra,0xfffff
    80004dde:	cac080e7          	jalr	-852(ra) # 80003a86 <readi>
    80004de2:	2501                	sext.w	a0,a0
    80004de4:	1aaa9963          	bne	s5,a0,80004f96 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004de8:	6785                	lui	a5,0x1
    80004dea:	0127893b          	addw	s2,a5,s2
    80004dee:	77fd                	lui	a5,0xfffff
    80004df0:	01478a3b          	addw	s4,a5,s4
    80004df4:	1f897163          	bgeu	s2,s8,80004fd6 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004df8:	02091593          	slli	a1,s2,0x20
    80004dfc:	9181                	srli	a1,a1,0x20
    80004dfe:	95ea                	add	a1,a1,s10
    80004e00:	855e                	mv	a0,s7
    80004e02:	ffffc097          	auipc	ra,0xffffc
    80004e06:	26c080e7          	jalr	620(ra) # 8000106e <walkaddr>
    80004e0a:	862a                	mv	a2,a0
    if(pa == 0)
    80004e0c:	d955                	beqz	a0,80004dc0 <exec+0xf0>
      n = PGSIZE;
    80004e0e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004e10:	fd9a70e3          	bgeu	s4,s9,80004dd0 <exec+0x100>
      n = sz - i;
    80004e14:	8ad2                	mv	s5,s4
    80004e16:	bf6d                	j	80004dd0 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e18:	4901                	li	s2,0
  iunlockput(ip);
    80004e1a:	8526                	mv	a0,s1
    80004e1c:	fffff097          	auipc	ra,0xfffff
    80004e20:	c18080e7          	jalr	-1000(ra) # 80003a34 <iunlockput>
  end_op();
    80004e24:	fffff097          	auipc	ra,0xfffff
    80004e28:	400080e7          	jalr	1024(ra) # 80004224 <end_op>
  p = myproc();
    80004e2c:	ffffd097          	auipc	ra,0xffffd
    80004e30:	b84080e7          	jalr	-1148(ra) # 800019b0 <myproc>
    80004e34:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e36:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e3a:	6785                	lui	a5,0x1
    80004e3c:	17fd                	addi	a5,a5,-1
    80004e3e:	993e                	add	s2,s2,a5
    80004e40:	757d                	lui	a0,0xfffff
    80004e42:	00a977b3          	and	a5,s2,a0
    80004e46:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e4a:	6609                	lui	a2,0x2
    80004e4c:	963e                	add	a2,a2,a5
    80004e4e:	85be                	mv	a1,a5
    80004e50:	855e                	mv	a0,s7
    80004e52:	ffffc097          	auipc	ra,0xffffc
    80004e56:	5d0080e7          	jalr	1488(ra) # 80001422 <uvmalloc>
    80004e5a:	8b2a                	mv	s6,a0
  ip = 0;
    80004e5c:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e5e:	12050c63          	beqz	a0,80004f96 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e62:	75f9                	lui	a1,0xffffe
    80004e64:	95aa                	add	a1,a1,a0
    80004e66:	855e                	mv	a0,s7
    80004e68:	ffffc097          	auipc	ra,0xffffc
    80004e6c:	7d8080e7          	jalr	2008(ra) # 80001640 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e70:	7c7d                	lui	s8,0xfffff
    80004e72:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004e74:	e0043783          	ld	a5,-512(s0)
    80004e78:	6388                	ld	a0,0(a5)
    80004e7a:	c535                	beqz	a0,80004ee6 <exec+0x216>
    80004e7c:	e9040993          	addi	s3,s0,-368
    80004e80:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004e84:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	fde080e7          	jalr	-34(ra) # 80000e64 <strlen>
    80004e8e:	2505                	addiw	a0,a0,1
    80004e90:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e94:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e98:	13896363          	bltu	s2,s8,80004fbe <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e9c:	e0043d83          	ld	s11,-512(s0)
    80004ea0:	000dba03          	ld	s4,0(s11)
    80004ea4:	8552                	mv	a0,s4
    80004ea6:	ffffc097          	auipc	ra,0xffffc
    80004eaa:	fbe080e7          	jalr	-66(ra) # 80000e64 <strlen>
    80004eae:	0015069b          	addiw	a3,a0,1
    80004eb2:	8652                	mv	a2,s4
    80004eb4:	85ca                	mv	a1,s2
    80004eb6:	855e                	mv	a0,s7
    80004eb8:	ffffc097          	auipc	ra,0xffffc
    80004ebc:	7ba080e7          	jalr	1978(ra) # 80001672 <copyout>
    80004ec0:	10054363          	bltz	a0,80004fc6 <exec+0x2f6>
    ustack[argc] = sp;
    80004ec4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004ec8:	0485                	addi	s1,s1,1
    80004eca:	008d8793          	addi	a5,s11,8
    80004ece:	e0f43023          	sd	a5,-512(s0)
    80004ed2:	008db503          	ld	a0,8(s11)
    80004ed6:	c911                	beqz	a0,80004eea <exec+0x21a>
    if(argc >= MAXARG)
    80004ed8:	09a1                	addi	s3,s3,8
    80004eda:	fb3c96e3          	bne	s9,s3,80004e86 <exec+0x1b6>
  sz = sz1;
    80004ede:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ee2:	4481                	li	s1,0
    80004ee4:	a84d                	j	80004f96 <exec+0x2c6>
  sp = sz;
    80004ee6:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004ee8:	4481                	li	s1,0
  ustack[argc] = 0;
    80004eea:	00349793          	slli	a5,s1,0x3
    80004eee:	f9040713          	addi	a4,s0,-112
    80004ef2:	97ba                	add	a5,a5,a4
    80004ef4:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80004ef8:	00148693          	addi	a3,s1,1
    80004efc:	068e                	slli	a3,a3,0x3
    80004efe:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f02:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004f06:	01897663          	bgeu	s2,s8,80004f12 <exec+0x242>
  sz = sz1;
    80004f0a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f0e:	4481                	li	s1,0
    80004f10:	a059                	j	80004f96 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f12:	e9040613          	addi	a2,s0,-368
    80004f16:	85ca                	mv	a1,s2
    80004f18:	855e                	mv	a0,s7
    80004f1a:	ffffc097          	auipc	ra,0xffffc
    80004f1e:	758080e7          	jalr	1880(ra) # 80001672 <copyout>
    80004f22:	0a054663          	bltz	a0,80004fce <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004f26:	058ab783          	ld	a5,88(s5)
    80004f2a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f2e:	df843783          	ld	a5,-520(s0)
    80004f32:	0007c703          	lbu	a4,0(a5)
    80004f36:	cf11                	beqz	a4,80004f52 <exec+0x282>
    80004f38:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f3a:	02f00693          	li	a3,47
    80004f3e:	a039                	j	80004f4c <exec+0x27c>
      last = s+1;
    80004f40:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004f44:	0785                	addi	a5,a5,1
    80004f46:	fff7c703          	lbu	a4,-1(a5)
    80004f4a:	c701                	beqz	a4,80004f52 <exec+0x282>
    if(*s == '/')
    80004f4c:	fed71ce3          	bne	a4,a3,80004f44 <exec+0x274>
    80004f50:	bfc5                	j	80004f40 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f52:	4641                	li	a2,16
    80004f54:	df843583          	ld	a1,-520(s0)
    80004f58:	158a8513          	addi	a0,s5,344
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	ed6080e7          	jalr	-298(ra) # 80000e32 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f64:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f68:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004f6c:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f70:	058ab783          	ld	a5,88(s5)
    80004f74:	e6843703          	ld	a4,-408(s0)
    80004f78:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f7a:	058ab783          	ld	a5,88(s5)
    80004f7e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f82:	85ea                	mv	a1,s10
    80004f84:	ffffd097          	auipc	ra,0xffffd
    80004f88:	b8c080e7          	jalr	-1140(ra) # 80001b10 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f8c:	0004851b          	sext.w	a0,s1
    80004f90:	bbe1                	j	80004d68 <exec+0x98>
    80004f92:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004f96:	e0843583          	ld	a1,-504(s0)
    80004f9a:	855e                	mv	a0,s7
    80004f9c:	ffffd097          	auipc	ra,0xffffd
    80004fa0:	b74080e7          	jalr	-1164(ra) # 80001b10 <proc_freepagetable>
  if(ip){
    80004fa4:	da0498e3          	bnez	s1,80004d54 <exec+0x84>
  return -1;
    80004fa8:	557d                	li	a0,-1
    80004faa:	bb7d                	j	80004d68 <exec+0x98>
    80004fac:	e1243423          	sd	s2,-504(s0)
    80004fb0:	b7dd                	j	80004f96 <exec+0x2c6>
    80004fb2:	e1243423          	sd	s2,-504(s0)
    80004fb6:	b7c5                	j	80004f96 <exec+0x2c6>
    80004fb8:	e1243423          	sd	s2,-504(s0)
    80004fbc:	bfe9                	j	80004f96 <exec+0x2c6>
  sz = sz1;
    80004fbe:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fc2:	4481                	li	s1,0
    80004fc4:	bfc9                	j	80004f96 <exec+0x2c6>
  sz = sz1;
    80004fc6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fca:	4481                	li	s1,0
    80004fcc:	b7e9                	j	80004f96 <exec+0x2c6>
  sz = sz1;
    80004fce:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fd2:	4481                	li	s1,0
    80004fd4:	b7c9                	j	80004f96 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fd6:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fda:	2b05                	addiw	s6,s6,1
    80004fdc:	0389899b          	addiw	s3,s3,56
    80004fe0:	e8845783          	lhu	a5,-376(s0)
    80004fe4:	e2fb5be3          	bge	s6,a5,80004e1a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fe8:	2981                	sext.w	s3,s3
    80004fea:	03800713          	li	a4,56
    80004fee:	86ce                	mv	a3,s3
    80004ff0:	e1840613          	addi	a2,s0,-488
    80004ff4:	4581                	li	a1,0
    80004ff6:	8526                	mv	a0,s1
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	a8e080e7          	jalr	-1394(ra) # 80003a86 <readi>
    80005000:	03800793          	li	a5,56
    80005004:	f8f517e3          	bne	a0,a5,80004f92 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005008:	e1842783          	lw	a5,-488(s0)
    8000500c:	4705                	li	a4,1
    8000500e:	fce796e3          	bne	a5,a4,80004fda <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80005012:	e4043603          	ld	a2,-448(s0)
    80005016:	e3843783          	ld	a5,-456(s0)
    8000501a:	f8f669e3          	bltu	a2,a5,80004fac <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000501e:	e2843783          	ld	a5,-472(s0)
    80005022:	963e                	add	a2,a2,a5
    80005024:	f8f667e3          	bltu	a2,a5,80004fb2 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005028:	85ca                	mv	a1,s2
    8000502a:	855e                	mv	a0,s7
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	3f6080e7          	jalr	1014(ra) # 80001422 <uvmalloc>
    80005034:	e0a43423          	sd	a0,-504(s0)
    80005038:	d141                	beqz	a0,80004fb8 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    8000503a:	e2843d03          	ld	s10,-472(s0)
    8000503e:	df043783          	ld	a5,-528(s0)
    80005042:	00fd77b3          	and	a5,s10,a5
    80005046:	fba1                	bnez	a5,80004f96 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005048:	e2042d83          	lw	s11,-480(s0)
    8000504c:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005050:	f80c03e3          	beqz	s8,80004fd6 <exec+0x306>
    80005054:	8a62                	mv	s4,s8
    80005056:	4901                	li	s2,0
    80005058:	b345                	j	80004df8 <exec+0x128>

000000008000505a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000505a:	7179                	addi	sp,sp,-48
    8000505c:	f406                	sd	ra,40(sp)
    8000505e:	f022                	sd	s0,32(sp)
    80005060:	ec26                	sd	s1,24(sp)
    80005062:	e84a                	sd	s2,16(sp)
    80005064:	1800                	addi	s0,sp,48
    80005066:	892e                	mv	s2,a1
    80005068:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000506a:	fdc40593          	addi	a1,s0,-36
    8000506e:	ffffe097          	auipc	ra,0xffffe
    80005072:	b36080e7          	jalr	-1226(ra) # 80002ba4 <argint>
    80005076:	04054063          	bltz	a0,800050b6 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000507a:	fdc42703          	lw	a4,-36(s0)
    8000507e:	47bd                	li	a5,15
    80005080:	02e7ed63          	bltu	a5,a4,800050ba <argfd+0x60>
    80005084:	ffffd097          	auipc	ra,0xffffd
    80005088:	92c080e7          	jalr	-1748(ra) # 800019b0 <myproc>
    8000508c:	fdc42703          	lw	a4,-36(s0)
    80005090:	01a70793          	addi	a5,a4,26
    80005094:	078e                	slli	a5,a5,0x3
    80005096:	953e                	add	a0,a0,a5
    80005098:	611c                	ld	a5,0(a0)
    8000509a:	c395                	beqz	a5,800050be <argfd+0x64>
    return -1;
  if(pfd)
    8000509c:	00090463          	beqz	s2,800050a4 <argfd+0x4a>
    *pfd = fd;
    800050a0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800050a4:	4501                	li	a0,0
  if(pf)
    800050a6:	c091                	beqz	s1,800050aa <argfd+0x50>
    *pf = f;
    800050a8:	e09c                	sd	a5,0(s1)
}
    800050aa:	70a2                	ld	ra,40(sp)
    800050ac:	7402                	ld	s0,32(sp)
    800050ae:	64e2                	ld	s1,24(sp)
    800050b0:	6942                	ld	s2,16(sp)
    800050b2:	6145                	addi	sp,sp,48
    800050b4:	8082                	ret
    return -1;
    800050b6:	557d                	li	a0,-1
    800050b8:	bfcd                	j	800050aa <argfd+0x50>
    return -1;
    800050ba:	557d                	li	a0,-1
    800050bc:	b7fd                	j	800050aa <argfd+0x50>
    800050be:	557d                	li	a0,-1
    800050c0:	b7ed                	j	800050aa <argfd+0x50>

00000000800050c2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050c2:	1101                	addi	sp,sp,-32
    800050c4:	ec06                	sd	ra,24(sp)
    800050c6:	e822                	sd	s0,16(sp)
    800050c8:	e426                	sd	s1,8(sp)
    800050ca:	1000                	addi	s0,sp,32
    800050cc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050ce:	ffffd097          	auipc	ra,0xffffd
    800050d2:	8e2080e7          	jalr	-1822(ra) # 800019b0 <myproc>
    800050d6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050d8:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    800050dc:	4501                	li	a0,0
    800050de:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050e0:	6398                	ld	a4,0(a5)
    800050e2:	cb19                	beqz	a4,800050f8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050e4:	2505                	addiw	a0,a0,1
    800050e6:	07a1                	addi	a5,a5,8
    800050e8:	fed51ce3          	bne	a0,a3,800050e0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050ec:	557d                	li	a0,-1
}
    800050ee:	60e2                	ld	ra,24(sp)
    800050f0:	6442                	ld	s0,16(sp)
    800050f2:	64a2                	ld	s1,8(sp)
    800050f4:	6105                	addi	sp,sp,32
    800050f6:	8082                	ret
      p->ofile[fd] = f;
    800050f8:	01a50793          	addi	a5,a0,26
    800050fc:	078e                	slli	a5,a5,0x3
    800050fe:	963e                	add	a2,a2,a5
    80005100:	e204                	sd	s1,0(a2)
      return fd;
    80005102:	b7f5                	j	800050ee <fdalloc+0x2c>

0000000080005104 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005104:	715d                	addi	sp,sp,-80
    80005106:	e486                	sd	ra,72(sp)
    80005108:	e0a2                	sd	s0,64(sp)
    8000510a:	fc26                	sd	s1,56(sp)
    8000510c:	f84a                	sd	s2,48(sp)
    8000510e:	f44e                	sd	s3,40(sp)
    80005110:	f052                	sd	s4,32(sp)
    80005112:	ec56                	sd	s5,24(sp)
    80005114:	0880                	addi	s0,sp,80
    80005116:	89ae                	mv	s3,a1
    80005118:	8ab2                	mv	s5,a2
    8000511a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000511c:	fb040593          	addi	a1,s0,-80
    80005120:	fffff097          	auipc	ra,0xfffff
    80005124:	e86080e7          	jalr	-378(ra) # 80003fa6 <nameiparent>
    80005128:	892a                	mv	s2,a0
    8000512a:	12050f63          	beqz	a0,80005268 <create+0x164>
    return 0;

  ilock(dp);
    8000512e:	ffffe097          	auipc	ra,0xffffe
    80005132:	6a4080e7          	jalr	1700(ra) # 800037d2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005136:	4601                	li	a2,0
    80005138:	fb040593          	addi	a1,s0,-80
    8000513c:	854a                	mv	a0,s2
    8000513e:	fffff097          	auipc	ra,0xfffff
    80005142:	b78080e7          	jalr	-1160(ra) # 80003cb6 <dirlookup>
    80005146:	84aa                	mv	s1,a0
    80005148:	c921                	beqz	a0,80005198 <create+0x94>
    iunlockput(dp);
    8000514a:	854a                	mv	a0,s2
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	8e8080e7          	jalr	-1816(ra) # 80003a34 <iunlockput>
    ilock(ip);
    80005154:	8526                	mv	a0,s1
    80005156:	ffffe097          	auipc	ra,0xffffe
    8000515a:	67c080e7          	jalr	1660(ra) # 800037d2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000515e:	2981                	sext.w	s3,s3
    80005160:	4789                	li	a5,2
    80005162:	02f99463          	bne	s3,a5,8000518a <create+0x86>
    80005166:	0444d783          	lhu	a5,68(s1)
    8000516a:	37f9                	addiw	a5,a5,-2
    8000516c:	17c2                	slli	a5,a5,0x30
    8000516e:	93c1                	srli	a5,a5,0x30
    80005170:	4705                	li	a4,1
    80005172:	00f76c63          	bltu	a4,a5,8000518a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005176:	8526                	mv	a0,s1
    80005178:	60a6                	ld	ra,72(sp)
    8000517a:	6406                	ld	s0,64(sp)
    8000517c:	74e2                	ld	s1,56(sp)
    8000517e:	7942                	ld	s2,48(sp)
    80005180:	79a2                	ld	s3,40(sp)
    80005182:	7a02                	ld	s4,32(sp)
    80005184:	6ae2                	ld	s5,24(sp)
    80005186:	6161                	addi	sp,sp,80
    80005188:	8082                	ret
    iunlockput(ip);
    8000518a:	8526                	mv	a0,s1
    8000518c:	fffff097          	auipc	ra,0xfffff
    80005190:	8a8080e7          	jalr	-1880(ra) # 80003a34 <iunlockput>
    return 0;
    80005194:	4481                	li	s1,0
    80005196:	b7c5                	j	80005176 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005198:	85ce                	mv	a1,s3
    8000519a:	00092503          	lw	a0,0(s2)
    8000519e:	ffffe097          	auipc	ra,0xffffe
    800051a2:	49c080e7          	jalr	1180(ra) # 8000363a <ialloc>
    800051a6:	84aa                	mv	s1,a0
    800051a8:	c529                	beqz	a0,800051f2 <create+0xee>
  ilock(ip);
    800051aa:	ffffe097          	auipc	ra,0xffffe
    800051ae:	628080e7          	jalr	1576(ra) # 800037d2 <ilock>
  ip->major = major;
    800051b2:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800051b6:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800051ba:	4785                	li	a5,1
    800051bc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051c0:	8526                	mv	a0,s1
    800051c2:	ffffe097          	auipc	ra,0xffffe
    800051c6:	546080e7          	jalr	1350(ra) # 80003708 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800051ca:	2981                	sext.w	s3,s3
    800051cc:	4785                	li	a5,1
    800051ce:	02f98a63          	beq	s3,a5,80005202 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800051d2:	40d0                	lw	a2,4(s1)
    800051d4:	fb040593          	addi	a1,s0,-80
    800051d8:	854a                	mv	a0,s2
    800051da:	fffff097          	auipc	ra,0xfffff
    800051de:	cec080e7          	jalr	-788(ra) # 80003ec6 <dirlink>
    800051e2:	06054b63          	bltz	a0,80005258 <create+0x154>
  iunlockput(dp);
    800051e6:	854a                	mv	a0,s2
    800051e8:	fffff097          	auipc	ra,0xfffff
    800051ec:	84c080e7          	jalr	-1972(ra) # 80003a34 <iunlockput>
  return ip;
    800051f0:	b759                	j	80005176 <create+0x72>
    panic("create: ialloc");
    800051f2:	00003517          	auipc	a0,0x3
    800051f6:	51650513          	addi	a0,a0,1302 # 80008708 <syscalls+0x2c0>
    800051fa:	ffffb097          	auipc	ra,0xffffb
    800051fe:	344080e7          	jalr	836(ra) # 8000053e <panic>
    dp->nlink++;  // for ".."
    80005202:	04a95783          	lhu	a5,74(s2)
    80005206:	2785                	addiw	a5,a5,1
    80005208:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000520c:	854a                	mv	a0,s2
    8000520e:	ffffe097          	auipc	ra,0xffffe
    80005212:	4fa080e7          	jalr	1274(ra) # 80003708 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005216:	40d0                	lw	a2,4(s1)
    80005218:	00003597          	auipc	a1,0x3
    8000521c:	50058593          	addi	a1,a1,1280 # 80008718 <syscalls+0x2d0>
    80005220:	8526                	mv	a0,s1
    80005222:	fffff097          	auipc	ra,0xfffff
    80005226:	ca4080e7          	jalr	-860(ra) # 80003ec6 <dirlink>
    8000522a:	00054f63          	bltz	a0,80005248 <create+0x144>
    8000522e:	00492603          	lw	a2,4(s2)
    80005232:	00003597          	auipc	a1,0x3
    80005236:	4ee58593          	addi	a1,a1,1262 # 80008720 <syscalls+0x2d8>
    8000523a:	8526                	mv	a0,s1
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	c8a080e7          	jalr	-886(ra) # 80003ec6 <dirlink>
    80005244:	f80557e3          	bgez	a0,800051d2 <create+0xce>
      panic("create dots");
    80005248:	00003517          	auipc	a0,0x3
    8000524c:	4e050513          	addi	a0,a0,1248 # 80008728 <syscalls+0x2e0>
    80005250:	ffffb097          	auipc	ra,0xffffb
    80005254:	2ee080e7          	jalr	750(ra) # 8000053e <panic>
    panic("create: dirlink");
    80005258:	00003517          	auipc	a0,0x3
    8000525c:	4e050513          	addi	a0,a0,1248 # 80008738 <syscalls+0x2f0>
    80005260:	ffffb097          	auipc	ra,0xffffb
    80005264:	2de080e7          	jalr	734(ra) # 8000053e <panic>
    return 0;
    80005268:	84aa                	mv	s1,a0
    8000526a:	b731                	j	80005176 <create+0x72>

000000008000526c <sys_dup>:
{
    8000526c:	7179                	addi	sp,sp,-48
    8000526e:	f406                	sd	ra,40(sp)
    80005270:	f022                	sd	s0,32(sp)
    80005272:	ec26                	sd	s1,24(sp)
    80005274:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005276:	fd840613          	addi	a2,s0,-40
    8000527a:	4581                	li	a1,0
    8000527c:	4501                	li	a0,0
    8000527e:	00000097          	auipc	ra,0x0
    80005282:	ddc080e7          	jalr	-548(ra) # 8000505a <argfd>
    return -1;
    80005286:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005288:	02054363          	bltz	a0,800052ae <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000528c:	fd843503          	ld	a0,-40(s0)
    80005290:	00000097          	auipc	ra,0x0
    80005294:	e32080e7          	jalr	-462(ra) # 800050c2 <fdalloc>
    80005298:	84aa                	mv	s1,a0
    return -1;
    8000529a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000529c:	00054963          	bltz	a0,800052ae <sys_dup+0x42>
  filedup(f);
    800052a0:	fd843503          	ld	a0,-40(s0)
    800052a4:	fffff097          	auipc	ra,0xfffff
    800052a8:	37a080e7          	jalr	890(ra) # 8000461e <filedup>
  return fd;
    800052ac:	87a6                	mv	a5,s1
}
    800052ae:	853e                	mv	a0,a5
    800052b0:	70a2                	ld	ra,40(sp)
    800052b2:	7402                	ld	s0,32(sp)
    800052b4:	64e2                	ld	s1,24(sp)
    800052b6:	6145                	addi	sp,sp,48
    800052b8:	8082                	ret

00000000800052ba <sys_read>:
{
    800052ba:	7179                	addi	sp,sp,-48
    800052bc:	f406                	sd	ra,40(sp)
    800052be:	f022                	sd	s0,32(sp)
    800052c0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052c2:	fe840613          	addi	a2,s0,-24
    800052c6:	4581                	li	a1,0
    800052c8:	4501                	li	a0,0
    800052ca:	00000097          	auipc	ra,0x0
    800052ce:	d90080e7          	jalr	-624(ra) # 8000505a <argfd>
    return -1;
    800052d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052d4:	04054163          	bltz	a0,80005316 <sys_read+0x5c>
    800052d8:	fe440593          	addi	a1,s0,-28
    800052dc:	4509                	li	a0,2
    800052de:	ffffe097          	auipc	ra,0xffffe
    800052e2:	8c6080e7          	jalr	-1850(ra) # 80002ba4 <argint>
    return -1;
    800052e6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052e8:	02054763          	bltz	a0,80005316 <sys_read+0x5c>
    800052ec:	fd840593          	addi	a1,s0,-40
    800052f0:	4505                	li	a0,1
    800052f2:	ffffe097          	auipc	ra,0xffffe
    800052f6:	8d4080e7          	jalr	-1836(ra) # 80002bc6 <argaddr>
    return -1;
    800052fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052fc:	00054d63          	bltz	a0,80005316 <sys_read+0x5c>
  return fileread(f, p, n);
    80005300:	fe442603          	lw	a2,-28(s0)
    80005304:	fd843583          	ld	a1,-40(s0)
    80005308:	fe843503          	ld	a0,-24(s0)
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	49e080e7          	jalr	1182(ra) # 800047aa <fileread>
    80005314:	87aa                	mv	a5,a0
}
    80005316:	853e                	mv	a0,a5
    80005318:	70a2                	ld	ra,40(sp)
    8000531a:	7402                	ld	s0,32(sp)
    8000531c:	6145                	addi	sp,sp,48
    8000531e:	8082                	ret

0000000080005320 <sys_write>:
{
    80005320:	7179                	addi	sp,sp,-48
    80005322:	f406                	sd	ra,40(sp)
    80005324:	f022                	sd	s0,32(sp)
    80005326:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005328:	fe840613          	addi	a2,s0,-24
    8000532c:	4581                	li	a1,0
    8000532e:	4501                	li	a0,0
    80005330:	00000097          	auipc	ra,0x0
    80005334:	d2a080e7          	jalr	-726(ra) # 8000505a <argfd>
    return -1;
    80005338:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000533a:	04054163          	bltz	a0,8000537c <sys_write+0x5c>
    8000533e:	fe440593          	addi	a1,s0,-28
    80005342:	4509                	li	a0,2
    80005344:	ffffe097          	auipc	ra,0xffffe
    80005348:	860080e7          	jalr	-1952(ra) # 80002ba4 <argint>
    return -1;
    8000534c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000534e:	02054763          	bltz	a0,8000537c <sys_write+0x5c>
    80005352:	fd840593          	addi	a1,s0,-40
    80005356:	4505                	li	a0,1
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	86e080e7          	jalr	-1938(ra) # 80002bc6 <argaddr>
    return -1;
    80005360:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005362:	00054d63          	bltz	a0,8000537c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005366:	fe442603          	lw	a2,-28(s0)
    8000536a:	fd843583          	ld	a1,-40(s0)
    8000536e:	fe843503          	ld	a0,-24(s0)
    80005372:	fffff097          	auipc	ra,0xfffff
    80005376:	4fa080e7          	jalr	1274(ra) # 8000486c <filewrite>
    8000537a:	87aa                	mv	a5,a0
}
    8000537c:	853e                	mv	a0,a5
    8000537e:	70a2                	ld	ra,40(sp)
    80005380:	7402                	ld	s0,32(sp)
    80005382:	6145                	addi	sp,sp,48
    80005384:	8082                	ret

0000000080005386 <sys_close>:
{
    80005386:	1101                	addi	sp,sp,-32
    80005388:	ec06                	sd	ra,24(sp)
    8000538a:	e822                	sd	s0,16(sp)
    8000538c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000538e:	fe040613          	addi	a2,s0,-32
    80005392:	fec40593          	addi	a1,s0,-20
    80005396:	4501                	li	a0,0
    80005398:	00000097          	auipc	ra,0x0
    8000539c:	cc2080e7          	jalr	-830(ra) # 8000505a <argfd>
    return -1;
    800053a0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053a2:	02054463          	bltz	a0,800053ca <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800053a6:	ffffc097          	auipc	ra,0xffffc
    800053aa:	60a080e7          	jalr	1546(ra) # 800019b0 <myproc>
    800053ae:	fec42783          	lw	a5,-20(s0)
    800053b2:	07e9                	addi	a5,a5,26
    800053b4:	078e                	slli	a5,a5,0x3
    800053b6:	97aa                	add	a5,a5,a0
    800053b8:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800053bc:	fe043503          	ld	a0,-32(s0)
    800053c0:	fffff097          	auipc	ra,0xfffff
    800053c4:	2b0080e7          	jalr	688(ra) # 80004670 <fileclose>
  return 0;
    800053c8:	4781                	li	a5,0
}
    800053ca:	853e                	mv	a0,a5
    800053cc:	60e2                	ld	ra,24(sp)
    800053ce:	6442                	ld	s0,16(sp)
    800053d0:	6105                	addi	sp,sp,32
    800053d2:	8082                	ret

00000000800053d4 <sys_fstat>:
{
    800053d4:	1101                	addi	sp,sp,-32
    800053d6:	ec06                	sd	ra,24(sp)
    800053d8:	e822                	sd	s0,16(sp)
    800053da:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053dc:	fe840613          	addi	a2,s0,-24
    800053e0:	4581                	li	a1,0
    800053e2:	4501                	li	a0,0
    800053e4:	00000097          	auipc	ra,0x0
    800053e8:	c76080e7          	jalr	-906(ra) # 8000505a <argfd>
    return -1;
    800053ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053ee:	02054563          	bltz	a0,80005418 <sys_fstat+0x44>
    800053f2:	fe040593          	addi	a1,s0,-32
    800053f6:	4505                	li	a0,1
    800053f8:	ffffd097          	auipc	ra,0xffffd
    800053fc:	7ce080e7          	jalr	1998(ra) # 80002bc6 <argaddr>
    return -1;
    80005400:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005402:	00054b63          	bltz	a0,80005418 <sys_fstat+0x44>
  return filestat(f, st);
    80005406:	fe043583          	ld	a1,-32(s0)
    8000540a:	fe843503          	ld	a0,-24(s0)
    8000540e:	fffff097          	auipc	ra,0xfffff
    80005412:	32a080e7          	jalr	810(ra) # 80004738 <filestat>
    80005416:	87aa                	mv	a5,a0
}
    80005418:	853e                	mv	a0,a5
    8000541a:	60e2                	ld	ra,24(sp)
    8000541c:	6442                	ld	s0,16(sp)
    8000541e:	6105                	addi	sp,sp,32
    80005420:	8082                	ret

0000000080005422 <sys_link>:
{
    80005422:	7169                	addi	sp,sp,-304
    80005424:	f606                	sd	ra,296(sp)
    80005426:	f222                	sd	s0,288(sp)
    80005428:	ee26                	sd	s1,280(sp)
    8000542a:	ea4a                	sd	s2,272(sp)
    8000542c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000542e:	08000613          	li	a2,128
    80005432:	ed040593          	addi	a1,s0,-304
    80005436:	4501                	li	a0,0
    80005438:	ffffd097          	auipc	ra,0xffffd
    8000543c:	7b0080e7          	jalr	1968(ra) # 80002be8 <argstr>
    return -1;
    80005440:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005442:	10054e63          	bltz	a0,8000555e <sys_link+0x13c>
    80005446:	08000613          	li	a2,128
    8000544a:	f5040593          	addi	a1,s0,-176
    8000544e:	4505                	li	a0,1
    80005450:	ffffd097          	auipc	ra,0xffffd
    80005454:	798080e7          	jalr	1944(ra) # 80002be8 <argstr>
    return -1;
    80005458:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000545a:	10054263          	bltz	a0,8000555e <sys_link+0x13c>
  begin_op();
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	d46080e7          	jalr	-698(ra) # 800041a4 <begin_op>
  if((ip = namei(old)) == 0){
    80005466:	ed040513          	addi	a0,s0,-304
    8000546a:	fffff097          	auipc	ra,0xfffff
    8000546e:	b1e080e7          	jalr	-1250(ra) # 80003f88 <namei>
    80005472:	84aa                	mv	s1,a0
    80005474:	c551                	beqz	a0,80005500 <sys_link+0xde>
  ilock(ip);
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	35c080e7          	jalr	860(ra) # 800037d2 <ilock>
  if(ip->type == T_DIR){
    8000547e:	04449703          	lh	a4,68(s1)
    80005482:	4785                	li	a5,1
    80005484:	08f70463          	beq	a4,a5,8000550c <sys_link+0xea>
  ip->nlink++;
    80005488:	04a4d783          	lhu	a5,74(s1)
    8000548c:	2785                	addiw	a5,a5,1
    8000548e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005492:	8526                	mv	a0,s1
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	274080e7          	jalr	628(ra) # 80003708 <iupdate>
  iunlock(ip);
    8000549c:	8526                	mv	a0,s1
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	3f6080e7          	jalr	1014(ra) # 80003894 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800054a6:	fd040593          	addi	a1,s0,-48
    800054aa:	f5040513          	addi	a0,s0,-176
    800054ae:	fffff097          	auipc	ra,0xfffff
    800054b2:	af8080e7          	jalr	-1288(ra) # 80003fa6 <nameiparent>
    800054b6:	892a                	mv	s2,a0
    800054b8:	c935                	beqz	a0,8000552c <sys_link+0x10a>
  ilock(dp);
    800054ba:	ffffe097          	auipc	ra,0xffffe
    800054be:	318080e7          	jalr	792(ra) # 800037d2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054c2:	00092703          	lw	a4,0(s2)
    800054c6:	409c                	lw	a5,0(s1)
    800054c8:	04f71d63          	bne	a4,a5,80005522 <sys_link+0x100>
    800054cc:	40d0                	lw	a2,4(s1)
    800054ce:	fd040593          	addi	a1,s0,-48
    800054d2:	854a                	mv	a0,s2
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	9f2080e7          	jalr	-1550(ra) # 80003ec6 <dirlink>
    800054dc:	04054363          	bltz	a0,80005522 <sys_link+0x100>
  iunlockput(dp);
    800054e0:	854a                	mv	a0,s2
    800054e2:	ffffe097          	auipc	ra,0xffffe
    800054e6:	552080e7          	jalr	1362(ra) # 80003a34 <iunlockput>
  iput(ip);
    800054ea:	8526                	mv	a0,s1
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	4a0080e7          	jalr	1184(ra) # 8000398c <iput>
  end_op();
    800054f4:	fffff097          	auipc	ra,0xfffff
    800054f8:	d30080e7          	jalr	-720(ra) # 80004224 <end_op>
  return 0;
    800054fc:	4781                	li	a5,0
    800054fe:	a085                	j	8000555e <sys_link+0x13c>
    end_op();
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	d24080e7          	jalr	-732(ra) # 80004224 <end_op>
    return -1;
    80005508:	57fd                	li	a5,-1
    8000550a:	a891                	j	8000555e <sys_link+0x13c>
    iunlockput(ip);
    8000550c:	8526                	mv	a0,s1
    8000550e:	ffffe097          	auipc	ra,0xffffe
    80005512:	526080e7          	jalr	1318(ra) # 80003a34 <iunlockput>
    end_op();
    80005516:	fffff097          	auipc	ra,0xfffff
    8000551a:	d0e080e7          	jalr	-754(ra) # 80004224 <end_op>
    return -1;
    8000551e:	57fd                	li	a5,-1
    80005520:	a83d                	j	8000555e <sys_link+0x13c>
    iunlockput(dp);
    80005522:	854a                	mv	a0,s2
    80005524:	ffffe097          	auipc	ra,0xffffe
    80005528:	510080e7          	jalr	1296(ra) # 80003a34 <iunlockput>
  ilock(ip);
    8000552c:	8526                	mv	a0,s1
    8000552e:	ffffe097          	auipc	ra,0xffffe
    80005532:	2a4080e7          	jalr	676(ra) # 800037d2 <ilock>
  ip->nlink--;
    80005536:	04a4d783          	lhu	a5,74(s1)
    8000553a:	37fd                	addiw	a5,a5,-1
    8000553c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005540:	8526                	mv	a0,s1
    80005542:	ffffe097          	auipc	ra,0xffffe
    80005546:	1c6080e7          	jalr	454(ra) # 80003708 <iupdate>
  iunlockput(ip);
    8000554a:	8526                	mv	a0,s1
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	4e8080e7          	jalr	1256(ra) # 80003a34 <iunlockput>
  end_op();
    80005554:	fffff097          	auipc	ra,0xfffff
    80005558:	cd0080e7          	jalr	-816(ra) # 80004224 <end_op>
  return -1;
    8000555c:	57fd                	li	a5,-1
}
    8000555e:	853e                	mv	a0,a5
    80005560:	70b2                	ld	ra,296(sp)
    80005562:	7412                	ld	s0,288(sp)
    80005564:	64f2                	ld	s1,280(sp)
    80005566:	6952                	ld	s2,272(sp)
    80005568:	6155                	addi	sp,sp,304
    8000556a:	8082                	ret

000000008000556c <sys_unlink>:
{
    8000556c:	7151                	addi	sp,sp,-240
    8000556e:	f586                	sd	ra,232(sp)
    80005570:	f1a2                	sd	s0,224(sp)
    80005572:	eda6                	sd	s1,216(sp)
    80005574:	e9ca                	sd	s2,208(sp)
    80005576:	e5ce                	sd	s3,200(sp)
    80005578:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000557a:	08000613          	li	a2,128
    8000557e:	f3040593          	addi	a1,s0,-208
    80005582:	4501                	li	a0,0
    80005584:	ffffd097          	auipc	ra,0xffffd
    80005588:	664080e7          	jalr	1636(ra) # 80002be8 <argstr>
    8000558c:	18054163          	bltz	a0,8000570e <sys_unlink+0x1a2>
  begin_op();
    80005590:	fffff097          	auipc	ra,0xfffff
    80005594:	c14080e7          	jalr	-1004(ra) # 800041a4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005598:	fb040593          	addi	a1,s0,-80
    8000559c:	f3040513          	addi	a0,s0,-208
    800055a0:	fffff097          	auipc	ra,0xfffff
    800055a4:	a06080e7          	jalr	-1530(ra) # 80003fa6 <nameiparent>
    800055a8:	84aa                	mv	s1,a0
    800055aa:	c979                	beqz	a0,80005680 <sys_unlink+0x114>
  ilock(dp);
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	226080e7          	jalr	550(ra) # 800037d2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055b4:	00003597          	auipc	a1,0x3
    800055b8:	16458593          	addi	a1,a1,356 # 80008718 <syscalls+0x2d0>
    800055bc:	fb040513          	addi	a0,s0,-80
    800055c0:	ffffe097          	auipc	ra,0xffffe
    800055c4:	6dc080e7          	jalr	1756(ra) # 80003c9c <namecmp>
    800055c8:	14050a63          	beqz	a0,8000571c <sys_unlink+0x1b0>
    800055cc:	00003597          	auipc	a1,0x3
    800055d0:	15458593          	addi	a1,a1,340 # 80008720 <syscalls+0x2d8>
    800055d4:	fb040513          	addi	a0,s0,-80
    800055d8:	ffffe097          	auipc	ra,0xffffe
    800055dc:	6c4080e7          	jalr	1732(ra) # 80003c9c <namecmp>
    800055e0:	12050e63          	beqz	a0,8000571c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055e4:	f2c40613          	addi	a2,s0,-212
    800055e8:	fb040593          	addi	a1,s0,-80
    800055ec:	8526                	mv	a0,s1
    800055ee:	ffffe097          	auipc	ra,0xffffe
    800055f2:	6c8080e7          	jalr	1736(ra) # 80003cb6 <dirlookup>
    800055f6:	892a                	mv	s2,a0
    800055f8:	12050263          	beqz	a0,8000571c <sys_unlink+0x1b0>
  ilock(ip);
    800055fc:	ffffe097          	auipc	ra,0xffffe
    80005600:	1d6080e7          	jalr	470(ra) # 800037d2 <ilock>
  if(ip->nlink < 1)
    80005604:	04a91783          	lh	a5,74(s2)
    80005608:	08f05263          	blez	a5,8000568c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000560c:	04491703          	lh	a4,68(s2)
    80005610:	4785                	li	a5,1
    80005612:	08f70563          	beq	a4,a5,8000569c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005616:	4641                	li	a2,16
    80005618:	4581                	li	a1,0
    8000561a:	fc040513          	addi	a0,s0,-64
    8000561e:	ffffb097          	auipc	ra,0xffffb
    80005622:	6c2080e7          	jalr	1730(ra) # 80000ce0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005626:	4741                	li	a4,16
    80005628:	f2c42683          	lw	a3,-212(s0)
    8000562c:	fc040613          	addi	a2,s0,-64
    80005630:	4581                	li	a1,0
    80005632:	8526                	mv	a0,s1
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	54a080e7          	jalr	1354(ra) # 80003b7e <writei>
    8000563c:	47c1                	li	a5,16
    8000563e:	0af51563          	bne	a0,a5,800056e8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005642:	04491703          	lh	a4,68(s2)
    80005646:	4785                	li	a5,1
    80005648:	0af70863          	beq	a4,a5,800056f8 <sys_unlink+0x18c>
  iunlockput(dp);
    8000564c:	8526                	mv	a0,s1
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	3e6080e7          	jalr	998(ra) # 80003a34 <iunlockput>
  ip->nlink--;
    80005656:	04a95783          	lhu	a5,74(s2)
    8000565a:	37fd                	addiw	a5,a5,-1
    8000565c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005660:	854a                	mv	a0,s2
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	0a6080e7          	jalr	166(ra) # 80003708 <iupdate>
  iunlockput(ip);
    8000566a:	854a                	mv	a0,s2
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	3c8080e7          	jalr	968(ra) # 80003a34 <iunlockput>
  end_op();
    80005674:	fffff097          	auipc	ra,0xfffff
    80005678:	bb0080e7          	jalr	-1104(ra) # 80004224 <end_op>
  return 0;
    8000567c:	4501                	li	a0,0
    8000567e:	a84d                	j	80005730 <sys_unlink+0x1c4>
    end_op();
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	ba4080e7          	jalr	-1116(ra) # 80004224 <end_op>
    return -1;
    80005688:	557d                	li	a0,-1
    8000568a:	a05d                	j	80005730 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000568c:	00003517          	auipc	a0,0x3
    80005690:	0bc50513          	addi	a0,a0,188 # 80008748 <syscalls+0x300>
    80005694:	ffffb097          	auipc	ra,0xffffb
    80005698:	eaa080e7          	jalr	-342(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000569c:	04c92703          	lw	a4,76(s2)
    800056a0:	02000793          	li	a5,32
    800056a4:	f6e7f9e3          	bgeu	a5,a4,80005616 <sys_unlink+0xaa>
    800056a8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056ac:	4741                	li	a4,16
    800056ae:	86ce                	mv	a3,s3
    800056b0:	f1840613          	addi	a2,s0,-232
    800056b4:	4581                	li	a1,0
    800056b6:	854a                	mv	a0,s2
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	3ce080e7          	jalr	974(ra) # 80003a86 <readi>
    800056c0:	47c1                	li	a5,16
    800056c2:	00f51b63          	bne	a0,a5,800056d8 <sys_unlink+0x16c>
    if(de.inum != 0)
    800056c6:	f1845783          	lhu	a5,-232(s0)
    800056ca:	e7a1                	bnez	a5,80005712 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056cc:	29c1                	addiw	s3,s3,16
    800056ce:	04c92783          	lw	a5,76(s2)
    800056d2:	fcf9ede3          	bltu	s3,a5,800056ac <sys_unlink+0x140>
    800056d6:	b781                	j	80005616 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800056d8:	00003517          	auipc	a0,0x3
    800056dc:	08850513          	addi	a0,a0,136 # 80008760 <syscalls+0x318>
    800056e0:	ffffb097          	auipc	ra,0xffffb
    800056e4:	e5e080e7          	jalr	-418(ra) # 8000053e <panic>
    panic("unlink: writei");
    800056e8:	00003517          	auipc	a0,0x3
    800056ec:	09050513          	addi	a0,a0,144 # 80008778 <syscalls+0x330>
    800056f0:	ffffb097          	auipc	ra,0xffffb
    800056f4:	e4e080e7          	jalr	-434(ra) # 8000053e <panic>
    dp->nlink--;
    800056f8:	04a4d783          	lhu	a5,74(s1)
    800056fc:	37fd                	addiw	a5,a5,-1
    800056fe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005702:	8526                	mv	a0,s1
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	004080e7          	jalr	4(ra) # 80003708 <iupdate>
    8000570c:	b781                	j	8000564c <sys_unlink+0xe0>
    return -1;
    8000570e:	557d                	li	a0,-1
    80005710:	a005                	j	80005730 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005712:	854a                	mv	a0,s2
    80005714:	ffffe097          	auipc	ra,0xffffe
    80005718:	320080e7          	jalr	800(ra) # 80003a34 <iunlockput>
  iunlockput(dp);
    8000571c:	8526                	mv	a0,s1
    8000571e:	ffffe097          	auipc	ra,0xffffe
    80005722:	316080e7          	jalr	790(ra) # 80003a34 <iunlockput>
  end_op();
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	afe080e7          	jalr	-1282(ra) # 80004224 <end_op>
  return -1;
    8000572e:	557d                	li	a0,-1
}
    80005730:	70ae                	ld	ra,232(sp)
    80005732:	740e                	ld	s0,224(sp)
    80005734:	64ee                	ld	s1,216(sp)
    80005736:	694e                	ld	s2,208(sp)
    80005738:	69ae                	ld	s3,200(sp)
    8000573a:	616d                	addi	sp,sp,240
    8000573c:	8082                	ret

000000008000573e <sys_open>:

uint64
sys_open(void)
{
    8000573e:	7131                	addi	sp,sp,-192
    80005740:	fd06                	sd	ra,184(sp)
    80005742:	f922                	sd	s0,176(sp)
    80005744:	f526                	sd	s1,168(sp)
    80005746:	f14a                	sd	s2,160(sp)
    80005748:	ed4e                	sd	s3,152(sp)
    8000574a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000574c:	08000613          	li	a2,128
    80005750:	f5040593          	addi	a1,s0,-176
    80005754:	4501                	li	a0,0
    80005756:	ffffd097          	auipc	ra,0xffffd
    8000575a:	492080e7          	jalr	1170(ra) # 80002be8 <argstr>
    return -1;
    8000575e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005760:	0c054163          	bltz	a0,80005822 <sys_open+0xe4>
    80005764:	f4c40593          	addi	a1,s0,-180
    80005768:	4505                	li	a0,1
    8000576a:	ffffd097          	auipc	ra,0xffffd
    8000576e:	43a080e7          	jalr	1082(ra) # 80002ba4 <argint>
    80005772:	0a054863          	bltz	a0,80005822 <sys_open+0xe4>

  begin_op();
    80005776:	fffff097          	auipc	ra,0xfffff
    8000577a:	a2e080e7          	jalr	-1490(ra) # 800041a4 <begin_op>

  if(omode & O_CREATE){
    8000577e:	f4c42783          	lw	a5,-180(s0)
    80005782:	2007f793          	andi	a5,a5,512
    80005786:	cbdd                	beqz	a5,8000583c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005788:	4681                	li	a3,0
    8000578a:	4601                	li	a2,0
    8000578c:	4589                	li	a1,2
    8000578e:	f5040513          	addi	a0,s0,-176
    80005792:	00000097          	auipc	ra,0x0
    80005796:	972080e7          	jalr	-1678(ra) # 80005104 <create>
    8000579a:	892a                	mv	s2,a0
    if(ip == 0){
    8000579c:	c959                	beqz	a0,80005832 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000579e:	04491703          	lh	a4,68(s2)
    800057a2:	478d                	li	a5,3
    800057a4:	00f71763          	bne	a4,a5,800057b2 <sys_open+0x74>
    800057a8:	04695703          	lhu	a4,70(s2)
    800057ac:	47a5                	li	a5,9
    800057ae:	0ce7ec63          	bltu	a5,a4,80005886 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	e02080e7          	jalr	-510(ra) # 800045b4 <filealloc>
    800057ba:	89aa                	mv	s3,a0
    800057bc:	10050263          	beqz	a0,800058c0 <sys_open+0x182>
    800057c0:	00000097          	auipc	ra,0x0
    800057c4:	902080e7          	jalr	-1790(ra) # 800050c2 <fdalloc>
    800057c8:	84aa                	mv	s1,a0
    800057ca:	0e054663          	bltz	a0,800058b6 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057ce:	04491703          	lh	a4,68(s2)
    800057d2:	478d                	li	a5,3
    800057d4:	0cf70463          	beq	a4,a5,8000589c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057d8:	4789                	li	a5,2
    800057da:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800057de:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800057e2:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800057e6:	f4c42783          	lw	a5,-180(s0)
    800057ea:	0017c713          	xori	a4,a5,1
    800057ee:	8b05                	andi	a4,a4,1
    800057f0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057f4:	0037f713          	andi	a4,a5,3
    800057f8:	00e03733          	snez	a4,a4
    800057fc:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005800:	4007f793          	andi	a5,a5,1024
    80005804:	c791                	beqz	a5,80005810 <sys_open+0xd2>
    80005806:	04491703          	lh	a4,68(s2)
    8000580a:	4789                	li	a5,2
    8000580c:	08f70f63          	beq	a4,a5,800058aa <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005810:	854a                	mv	a0,s2
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	082080e7          	jalr	130(ra) # 80003894 <iunlock>
  end_op();
    8000581a:	fffff097          	auipc	ra,0xfffff
    8000581e:	a0a080e7          	jalr	-1526(ra) # 80004224 <end_op>

  return fd;
}
    80005822:	8526                	mv	a0,s1
    80005824:	70ea                	ld	ra,184(sp)
    80005826:	744a                	ld	s0,176(sp)
    80005828:	74aa                	ld	s1,168(sp)
    8000582a:	790a                	ld	s2,160(sp)
    8000582c:	69ea                	ld	s3,152(sp)
    8000582e:	6129                	addi	sp,sp,192
    80005830:	8082                	ret
      end_op();
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	9f2080e7          	jalr	-1550(ra) # 80004224 <end_op>
      return -1;
    8000583a:	b7e5                	j	80005822 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000583c:	f5040513          	addi	a0,s0,-176
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	748080e7          	jalr	1864(ra) # 80003f88 <namei>
    80005848:	892a                	mv	s2,a0
    8000584a:	c905                	beqz	a0,8000587a <sys_open+0x13c>
    ilock(ip);
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	f86080e7          	jalr	-122(ra) # 800037d2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005854:	04491703          	lh	a4,68(s2)
    80005858:	4785                	li	a5,1
    8000585a:	f4f712e3          	bne	a4,a5,8000579e <sys_open+0x60>
    8000585e:	f4c42783          	lw	a5,-180(s0)
    80005862:	dba1                	beqz	a5,800057b2 <sys_open+0x74>
      iunlockput(ip);
    80005864:	854a                	mv	a0,s2
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	1ce080e7          	jalr	462(ra) # 80003a34 <iunlockput>
      end_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	9b6080e7          	jalr	-1610(ra) # 80004224 <end_op>
      return -1;
    80005876:	54fd                	li	s1,-1
    80005878:	b76d                	j	80005822 <sys_open+0xe4>
      end_op();
    8000587a:	fffff097          	auipc	ra,0xfffff
    8000587e:	9aa080e7          	jalr	-1622(ra) # 80004224 <end_op>
      return -1;
    80005882:	54fd                	li	s1,-1
    80005884:	bf79                	j	80005822 <sys_open+0xe4>
    iunlockput(ip);
    80005886:	854a                	mv	a0,s2
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	1ac080e7          	jalr	428(ra) # 80003a34 <iunlockput>
    end_op();
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	994080e7          	jalr	-1644(ra) # 80004224 <end_op>
    return -1;
    80005898:	54fd                	li	s1,-1
    8000589a:	b761                	j	80005822 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000589c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800058a0:	04691783          	lh	a5,70(s2)
    800058a4:	02f99223          	sh	a5,36(s3)
    800058a8:	bf2d                	j	800057e2 <sys_open+0xa4>
    itrunc(ip);
    800058aa:	854a                	mv	a0,s2
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	034080e7          	jalr	52(ra) # 800038e0 <itrunc>
    800058b4:	bfb1                	j	80005810 <sys_open+0xd2>
      fileclose(f);
    800058b6:	854e                	mv	a0,s3
    800058b8:	fffff097          	auipc	ra,0xfffff
    800058bc:	db8080e7          	jalr	-584(ra) # 80004670 <fileclose>
    iunlockput(ip);
    800058c0:	854a                	mv	a0,s2
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	172080e7          	jalr	370(ra) # 80003a34 <iunlockput>
    end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	95a080e7          	jalr	-1702(ra) # 80004224 <end_op>
    return -1;
    800058d2:	54fd                	li	s1,-1
    800058d4:	b7b9                	j	80005822 <sys_open+0xe4>

00000000800058d6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058d6:	7175                	addi	sp,sp,-144
    800058d8:	e506                	sd	ra,136(sp)
    800058da:	e122                	sd	s0,128(sp)
    800058dc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058de:	fffff097          	auipc	ra,0xfffff
    800058e2:	8c6080e7          	jalr	-1850(ra) # 800041a4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058e6:	08000613          	li	a2,128
    800058ea:	f7040593          	addi	a1,s0,-144
    800058ee:	4501                	li	a0,0
    800058f0:	ffffd097          	auipc	ra,0xffffd
    800058f4:	2f8080e7          	jalr	760(ra) # 80002be8 <argstr>
    800058f8:	02054963          	bltz	a0,8000592a <sys_mkdir+0x54>
    800058fc:	4681                	li	a3,0
    800058fe:	4601                	li	a2,0
    80005900:	4585                	li	a1,1
    80005902:	f7040513          	addi	a0,s0,-144
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	7fe080e7          	jalr	2046(ra) # 80005104 <create>
    8000590e:	cd11                	beqz	a0,8000592a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005910:	ffffe097          	auipc	ra,0xffffe
    80005914:	124080e7          	jalr	292(ra) # 80003a34 <iunlockput>
  end_op();
    80005918:	fffff097          	auipc	ra,0xfffff
    8000591c:	90c080e7          	jalr	-1780(ra) # 80004224 <end_op>
  return 0;
    80005920:	4501                	li	a0,0
}
    80005922:	60aa                	ld	ra,136(sp)
    80005924:	640a                	ld	s0,128(sp)
    80005926:	6149                	addi	sp,sp,144
    80005928:	8082                	ret
    end_op();
    8000592a:	fffff097          	auipc	ra,0xfffff
    8000592e:	8fa080e7          	jalr	-1798(ra) # 80004224 <end_op>
    return -1;
    80005932:	557d                	li	a0,-1
    80005934:	b7fd                	j	80005922 <sys_mkdir+0x4c>

0000000080005936 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005936:	7135                	addi	sp,sp,-160
    80005938:	ed06                	sd	ra,152(sp)
    8000593a:	e922                	sd	s0,144(sp)
    8000593c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000593e:	fffff097          	auipc	ra,0xfffff
    80005942:	866080e7          	jalr	-1946(ra) # 800041a4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005946:	08000613          	li	a2,128
    8000594a:	f7040593          	addi	a1,s0,-144
    8000594e:	4501                	li	a0,0
    80005950:	ffffd097          	auipc	ra,0xffffd
    80005954:	298080e7          	jalr	664(ra) # 80002be8 <argstr>
    80005958:	04054a63          	bltz	a0,800059ac <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000595c:	f6c40593          	addi	a1,s0,-148
    80005960:	4505                	li	a0,1
    80005962:	ffffd097          	auipc	ra,0xffffd
    80005966:	242080e7          	jalr	578(ra) # 80002ba4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000596a:	04054163          	bltz	a0,800059ac <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000596e:	f6840593          	addi	a1,s0,-152
    80005972:	4509                	li	a0,2
    80005974:	ffffd097          	auipc	ra,0xffffd
    80005978:	230080e7          	jalr	560(ra) # 80002ba4 <argint>
     argint(1, &major) < 0 ||
    8000597c:	02054863          	bltz	a0,800059ac <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005980:	f6841683          	lh	a3,-152(s0)
    80005984:	f6c41603          	lh	a2,-148(s0)
    80005988:	458d                	li	a1,3
    8000598a:	f7040513          	addi	a0,s0,-144
    8000598e:	fffff097          	auipc	ra,0xfffff
    80005992:	776080e7          	jalr	1910(ra) # 80005104 <create>
     argint(2, &minor) < 0 ||
    80005996:	c919                	beqz	a0,800059ac <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	09c080e7          	jalr	156(ra) # 80003a34 <iunlockput>
  end_op();
    800059a0:	fffff097          	auipc	ra,0xfffff
    800059a4:	884080e7          	jalr	-1916(ra) # 80004224 <end_op>
  return 0;
    800059a8:	4501                	li	a0,0
    800059aa:	a031                	j	800059b6 <sys_mknod+0x80>
    end_op();
    800059ac:	fffff097          	auipc	ra,0xfffff
    800059b0:	878080e7          	jalr	-1928(ra) # 80004224 <end_op>
    return -1;
    800059b4:	557d                	li	a0,-1
}
    800059b6:	60ea                	ld	ra,152(sp)
    800059b8:	644a                	ld	s0,144(sp)
    800059ba:	610d                	addi	sp,sp,160
    800059bc:	8082                	ret

00000000800059be <sys_chdir>:

uint64
sys_chdir(void)
{
    800059be:	7135                	addi	sp,sp,-160
    800059c0:	ed06                	sd	ra,152(sp)
    800059c2:	e922                	sd	s0,144(sp)
    800059c4:	e526                	sd	s1,136(sp)
    800059c6:	e14a                	sd	s2,128(sp)
    800059c8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059ca:	ffffc097          	auipc	ra,0xffffc
    800059ce:	fe6080e7          	jalr	-26(ra) # 800019b0 <myproc>
    800059d2:	892a                	mv	s2,a0
  
  begin_op();
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	7d0080e7          	jalr	2000(ra) # 800041a4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059dc:	08000613          	li	a2,128
    800059e0:	f6040593          	addi	a1,s0,-160
    800059e4:	4501                	li	a0,0
    800059e6:	ffffd097          	auipc	ra,0xffffd
    800059ea:	202080e7          	jalr	514(ra) # 80002be8 <argstr>
    800059ee:	04054b63          	bltz	a0,80005a44 <sys_chdir+0x86>
    800059f2:	f6040513          	addi	a0,s0,-160
    800059f6:	ffffe097          	auipc	ra,0xffffe
    800059fa:	592080e7          	jalr	1426(ra) # 80003f88 <namei>
    800059fe:	84aa                	mv	s1,a0
    80005a00:	c131                	beqz	a0,80005a44 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a02:	ffffe097          	auipc	ra,0xffffe
    80005a06:	dd0080e7          	jalr	-560(ra) # 800037d2 <ilock>
  if(ip->type != T_DIR){
    80005a0a:	04449703          	lh	a4,68(s1)
    80005a0e:	4785                	li	a5,1
    80005a10:	04f71063          	bne	a4,a5,80005a50 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a14:	8526                	mv	a0,s1
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	e7e080e7          	jalr	-386(ra) # 80003894 <iunlock>
  iput(p->cwd);
    80005a1e:	15093503          	ld	a0,336(s2)
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	f6a080e7          	jalr	-150(ra) # 8000398c <iput>
  end_op();
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	7fa080e7          	jalr	2042(ra) # 80004224 <end_op>
  p->cwd = ip;
    80005a32:	14993823          	sd	s1,336(s2)
  return 0;
    80005a36:	4501                	li	a0,0
}
    80005a38:	60ea                	ld	ra,152(sp)
    80005a3a:	644a                	ld	s0,144(sp)
    80005a3c:	64aa                	ld	s1,136(sp)
    80005a3e:	690a                	ld	s2,128(sp)
    80005a40:	610d                	addi	sp,sp,160
    80005a42:	8082                	ret
    end_op();
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	7e0080e7          	jalr	2016(ra) # 80004224 <end_op>
    return -1;
    80005a4c:	557d                	li	a0,-1
    80005a4e:	b7ed                	j	80005a38 <sys_chdir+0x7a>
    iunlockput(ip);
    80005a50:	8526                	mv	a0,s1
    80005a52:	ffffe097          	auipc	ra,0xffffe
    80005a56:	fe2080e7          	jalr	-30(ra) # 80003a34 <iunlockput>
    end_op();
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	7ca080e7          	jalr	1994(ra) # 80004224 <end_op>
    return -1;
    80005a62:	557d                	li	a0,-1
    80005a64:	bfd1                	j	80005a38 <sys_chdir+0x7a>

0000000080005a66 <sys_exec>:

uint64
sys_exec(void)
{
    80005a66:	7145                	addi	sp,sp,-464
    80005a68:	e786                	sd	ra,456(sp)
    80005a6a:	e3a2                	sd	s0,448(sp)
    80005a6c:	ff26                	sd	s1,440(sp)
    80005a6e:	fb4a                	sd	s2,432(sp)
    80005a70:	f74e                	sd	s3,424(sp)
    80005a72:	f352                	sd	s4,416(sp)
    80005a74:	ef56                	sd	s5,408(sp)
    80005a76:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a78:	08000613          	li	a2,128
    80005a7c:	f4040593          	addi	a1,s0,-192
    80005a80:	4501                	li	a0,0
    80005a82:	ffffd097          	auipc	ra,0xffffd
    80005a86:	166080e7          	jalr	358(ra) # 80002be8 <argstr>
    return -1;
    80005a8a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a8c:	0c054a63          	bltz	a0,80005b60 <sys_exec+0xfa>
    80005a90:	e3840593          	addi	a1,s0,-456
    80005a94:	4505                	li	a0,1
    80005a96:	ffffd097          	auipc	ra,0xffffd
    80005a9a:	130080e7          	jalr	304(ra) # 80002bc6 <argaddr>
    80005a9e:	0c054163          	bltz	a0,80005b60 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005aa2:	10000613          	li	a2,256
    80005aa6:	4581                	li	a1,0
    80005aa8:	e4040513          	addi	a0,s0,-448
    80005aac:	ffffb097          	auipc	ra,0xffffb
    80005ab0:	234080e7          	jalr	564(ra) # 80000ce0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ab4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ab8:	89a6                	mv	s3,s1
    80005aba:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005abc:	02000a13          	li	s4,32
    80005ac0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ac4:	00391513          	slli	a0,s2,0x3
    80005ac8:	e3040593          	addi	a1,s0,-464
    80005acc:	e3843783          	ld	a5,-456(s0)
    80005ad0:	953e                	add	a0,a0,a5
    80005ad2:	ffffd097          	auipc	ra,0xffffd
    80005ad6:	038080e7          	jalr	56(ra) # 80002b0a <fetchaddr>
    80005ada:	02054a63          	bltz	a0,80005b0e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005ade:	e3043783          	ld	a5,-464(s0)
    80005ae2:	c3b9                	beqz	a5,80005b28 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ae4:	ffffb097          	auipc	ra,0xffffb
    80005ae8:	010080e7          	jalr	16(ra) # 80000af4 <kalloc>
    80005aec:	85aa                	mv	a1,a0
    80005aee:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005af2:	cd11                	beqz	a0,80005b0e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005af4:	6605                	lui	a2,0x1
    80005af6:	e3043503          	ld	a0,-464(s0)
    80005afa:	ffffd097          	auipc	ra,0xffffd
    80005afe:	062080e7          	jalr	98(ra) # 80002b5c <fetchstr>
    80005b02:	00054663          	bltz	a0,80005b0e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005b06:	0905                	addi	s2,s2,1
    80005b08:	09a1                	addi	s3,s3,8
    80005b0a:	fb491be3          	bne	s2,s4,80005ac0 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b0e:	10048913          	addi	s2,s1,256
    80005b12:	6088                	ld	a0,0(s1)
    80005b14:	c529                	beqz	a0,80005b5e <sys_exec+0xf8>
    kfree(argv[i]);
    80005b16:	ffffb097          	auipc	ra,0xffffb
    80005b1a:	ee2080e7          	jalr	-286(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b1e:	04a1                	addi	s1,s1,8
    80005b20:	ff2499e3          	bne	s1,s2,80005b12 <sys_exec+0xac>
  return -1;
    80005b24:	597d                	li	s2,-1
    80005b26:	a82d                	j	80005b60 <sys_exec+0xfa>
      argv[i] = 0;
    80005b28:	0a8e                	slli	s5,s5,0x3
    80005b2a:	fc040793          	addi	a5,s0,-64
    80005b2e:	9abe                	add	s5,s5,a5
    80005b30:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005b34:	e4040593          	addi	a1,s0,-448
    80005b38:	f4040513          	addi	a0,s0,-192
    80005b3c:	fffff097          	auipc	ra,0xfffff
    80005b40:	194080e7          	jalr	404(ra) # 80004cd0 <exec>
    80005b44:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b46:	10048993          	addi	s3,s1,256
    80005b4a:	6088                	ld	a0,0(s1)
    80005b4c:	c911                	beqz	a0,80005b60 <sys_exec+0xfa>
    kfree(argv[i]);
    80005b4e:	ffffb097          	auipc	ra,0xffffb
    80005b52:	eaa080e7          	jalr	-342(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b56:	04a1                	addi	s1,s1,8
    80005b58:	ff3499e3          	bne	s1,s3,80005b4a <sys_exec+0xe4>
    80005b5c:	a011                	j	80005b60 <sys_exec+0xfa>
  return -1;
    80005b5e:	597d                	li	s2,-1
}
    80005b60:	854a                	mv	a0,s2
    80005b62:	60be                	ld	ra,456(sp)
    80005b64:	641e                	ld	s0,448(sp)
    80005b66:	74fa                	ld	s1,440(sp)
    80005b68:	795a                	ld	s2,432(sp)
    80005b6a:	79ba                	ld	s3,424(sp)
    80005b6c:	7a1a                	ld	s4,416(sp)
    80005b6e:	6afa                	ld	s5,408(sp)
    80005b70:	6179                	addi	sp,sp,464
    80005b72:	8082                	ret

0000000080005b74 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b74:	7139                	addi	sp,sp,-64
    80005b76:	fc06                	sd	ra,56(sp)
    80005b78:	f822                	sd	s0,48(sp)
    80005b7a:	f426                	sd	s1,40(sp)
    80005b7c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b7e:	ffffc097          	auipc	ra,0xffffc
    80005b82:	e32080e7          	jalr	-462(ra) # 800019b0 <myproc>
    80005b86:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b88:	fd840593          	addi	a1,s0,-40
    80005b8c:	4501                	li	a0,0
    80005b8e:	ffffd097          	auipc	ra,0xffffd
    80005b92:	038080e7          	jalr	56(ra) # 80002bc6 <argaddr>
    return -1;
    80005b96:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b98:	0e054063          	bltz	a0,80005c78 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b9c:	fc840593          	addi	a1,s0,-56
    80005ba0:	fd040513          	addi	a0,s0,-48
    80005ba4:	fffff097          	auipc	ra,0xfffff
    80005ba8:	dfc080e7          	jalr	-516(ra) # 800049a0 <pipealloc>
    return -1;
    80005bac:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005bae:	0c054563          	bltz	a0,80005c78 <sys_pipe+0x104>
  fd0 = -1;
    80005bb2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005bb6:	fd043503          	ld	a0,-48(s0)
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	508080e7          	jalr	1288(ra) # 800050c2 <fdalloc>
    80005bc2:	fca42223          	sw	a0,-60(s0)
    80005bc6:	08054c63          	bltz	a0,80005c5e <sys_pipe+0xea>
    80005bca:	fc843503          	ld	a0,-56(s0)
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	4f4080e7          	jalr	1268(ra) # 800050c2 <fdalloc>
    80005bd6:	fca42023          	sw	a0,-64(s0)
    80005bda:	06054863          	bltz	a0,80005c4a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bde:	4691                	li	a3,4
    80005be0:	fc440613          	addi	a2,s0,-60
    80005be4:	fd843583          	ld	a1,-40(s0)
    80005be8:	68a8                	ld	a0,80(s1)
    80005bea:	ffffc097          	auipc	ra,0xffffc
    80005bee:	a88080e7          	jalr	-1400(ra) # 80001672 <copyout>
    80005bf2:	02054063          	bltz	a0,80005c12 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bf6:	4691                	li	a3,4
    80005bf8:	fc040613          	addi	a2,s0,-64
    80005bfc:	fd843583          	ld	a1,-40(s0)
    80005c00:	0591                	addi	a1,a1,4
    80005c02:	68a8                	ld	a0,80(s1)
    80005c04:	ffffc097          	auipc	ra,0xffffc
    80005c08:	a6e080e7          	jalr	-1426(ra) # 80001672 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c0c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c0e:	06055563          	bgez	a0,80005c78 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c12:	fc442783          	lw	a5,-60(s0)
    80005c16:	07e9                	addi	a5,a5,26
    80005c18:	078e                	slli	a5,a5,0x3
    80005c1a:	97a6                	add	a5,a5,s1
    80005c1c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c20:	fc042503          	lw	a0,-64(s0)
    80005c24:	0569                	addi	a0,a0,26
    80005c26:	050e                	slli	a0,a0,0x3
    80005c28:	9526                	add	a0,a0,s1
    80005c2a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c2e:	fd043503          	ld	a0,-48(s0)
    80005c32:	fffff097          	auipc	ra,0xfffff
    80005c36:	a3e080e7          	jalr	-1474(ra) # 80004670 <fileclose>
    fileclose(wf);
    80005c3a:	fc843503          	ld	a0,-56(s0)
    80005c3e:	fffff097          	auipc	ra,0xfffff
    80005c42:	a32080e7          	jalr	-1486(ra) # 80004670 <fileclose>
    return -1;
    80005c46:	57fd                	li	a5,-1
    80005c48:	a805                	j	80005c78 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c4a:	fc442783          	lw	a5,-60(s0)
    80005c4e:	0007c863          	bltz	a5,80005c5e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c52:	01a78513          	addi	a0,a5,26
    80005c56:	050e                	slli	a0,a0,0x3
    80005c58:	9526                	add	a0,a0,s1
    80005c5a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c5e:	fd043503          	ld	a0,-48(s0)
    80005c62:	fffff097          	auipc	ra,0xfffff
    80005c66:	a0e080e7          	jalr	-1522(ra) # 80004670 <fileclose>
    fileclose(wf);
    80005c6a:	fc843503          	ld	a0,-56(s0)
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	a02080e7          	jalr	-1534(ra) # 80004670 <fileclose>
    return -1;
    80005c76:	57fd                	li	a5,-1
}
    80005c78:	853e                	mv	a0,a5
    80005c7a:	70e2                	ld	ra,56(sp)
    80005c7c:	7442                	ld	s0,48(sp)
    80005c7e:	74a2                	ld	s1,40(sp)
    80005c80:	6121                	addi	sp,sp,64
    80005c82:	8082                	ret
	...

0000000080005c90 <kernelvec>:
    80005c90:	7111                	addi	sp,sp,-256
    80005c92:	e006                	sd	ra,0(sp)
    80005c94:	e40a                	sd	sp,8(sp)
    80005c96:	e80e                	sd	gp,16(sp)
    80005c98:	ec12                	sd	tp,24(sp)
    80005c9a:	f016                	sd	t0,32(sp)
    80005c9c:	f41a                	sd	t1,40(sp)
    80005c9e:	f81e                	sd	t2,48(sp)
    80005ca0:	fc22                	sd	s0,56(sp)
    80005ca2:	e0a6                	sd	s1,64(sp)
    80005ca4:	e4aa                	sd	a0,72(sp)
    80005ca6:	e8ae                	sd	a1,80(sp)
    80005ca8:	ecb2                	sd	a2,88(sp)
    80005caa:	f0b6                	sd	a3,96(sp)
    80005cac:	f4ba                	sd	a4,104(sp)
    80005cae:	f8be                	sd	a5,112(sp)
    80005cb0:	fcc2                	sd	a6,120(sp)
    80005cb2:	e146                	sd	a7,128(sp)
    80005cb4:	e54a                	sd	s2,136(sp)
    80005cb6:	e94e                	sd	s3,144(sp)
    80005cb8:	ed52                	sd	s4,152(sp)
    80005cba:	f156                	sd	s5,160(sp)
    80005cbc:	f55a                	sd	s6,168(sp)
    80005cbe:	f95e                	sd	s7,176(sp)
    80005cc0:	fd62                	sd	s8,184(sp)
    80005cc2:	e1e6                	sd	s9,192(sp)
    80005cc4:	e5ea                	sd	s10,200(sp)
    80005cc6:	e9ee                	sd	s11,208(sp)
    80005cc8:	edf2                	sd	t3,216(sp)
    80005cca:	f1f6                	sd	t4,224(sp)
    80005ccc:	f5fa                	sd	t5,232(sp)
    80005cce:	f9fe                	sd	t6,240(sp)
    80005cd0:	d07fc0ef          	jal	ra,800029d6 <kerneltrap>
    80005cd4:	6082                	ld	ra,0(sp)
    80005cd6:	6122                	ld	sp,8(sp)
    80005cd8:	61c2                	ld	gp,16(sp)
    80005cda:	7282                	ld	t0,32(sp)
    80005cdc:	7322                	ld	t1,40(sp)
    80005cde:	73c2                	ld	t2,48(sp)
    80005ce0:	7462                	ld	s0,56(sp)
    80005ce2:	6486                	ld	s1,64(sp)
    80005ce4:	6526                	ld	a0,72(sp)
    80005ce6:	65c6                	ld	a1,80(sp)
    80005ce8:	6666                	ld	a2,88(sp)
    80005cea:	7686                	ld	a3,96(sp)
    80005cec:	7726                	ld	a4,104(sp)
    80005cee:	77c6                	ld	a5,112(sp)
    80005cf0:	7866                	ld	a6,120(sp)
    80005cf2:	688a                	ld	a7,128(sp)
    80005cf4:	692a                	ld	s2,136(sp)
    80005cf6:	69ca                	ld	s3,144(sp)
    80005cf8:	6a6a                	ld	s4,152(sp)
    80005cfa:	7a8a                	ld	s5,160(sp)
    80005cfc:	7b2a                	ld	s6,168(sp)
    80005cfe:	7bca                	ld	s7,176(sp)
    80005d00:	7c6a                	ld	s8,184(sp)
    80005d02:	6c8e                	ld	s9,192(sp)
    80005d04:	6d2e                	ld	s10,200(sp)
    80005d06:	6dce                	ld	s11,208(sp)
    80005d08:	6e6e                	ld	t3,216(sp)
    80005d0a:	7e8e                	ld	t4,224(sp)
    80005d0c:	7f2e                	ld	t5,232(sp)
    80005d0e:	7fce                	ld	t6,240(sp)
    80005d10:	6111                	addi	sp,sp,256
    80005d12:	10200073          	sret
    80005d16:	00000013          	nop
    80005d1a:	00000013          	nop
    80005d1e:	0001                	nop

0000000080005d20 <timervec>:
    80005d20:	34051573          	csrrw	a0,mscratch,a0
    80005d24:	e10c                	sd	a1,0(a0)
    80005d26:	e510                	sd	a2,8(a0)
    80005d28:	e914                	sd	a3,16(a0)
    80005d2a:	6d0c                	ld	a1,24(a0)
    80005d2c:	7110                	ld	a2,32(a0)
    80005d2e:	6194                	ld	a3,0(a1)
    80005d30:	96b2                	add	a3,a3,a2
    80005d32:	e194                	sd	a3,0(a1)
    80005d34:	4589                	li	a1,2
    80005d36:	14459073          	csrw	sip,a1
    80005d3a:	6914                	ld	a3,16(a0)
    80005d3c:	6510                	ld	a2,8(a0)
    80005d3e:	610c                	ld	a1,0(a0)
    80005d40:	34051573          	csrrw	a0,mscratch,a0
    80005d44:	30200073          	mret
	...

0000000080005d4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d4a:	1141                	addi	sp,sp,-16
    80005d4c:	e422                	sd	s0,8(sp)
    80005d4e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d50:	0c0007b7          	lui	a5,0xc000
    80005d54:	4705                	li	a4,1
    80005d56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d58:	c3d8                	sw	a4,4(a5)
}
    80005d5a:	6422                	ld	s0,8(sp)
    80005d5c:	0141                	addi	sp,sp,16
    80005d5e:	8082                	ret

0000000080005d60 <plicinithart>:

void
plicinithart(void)
{
    80005d60:	1141                	addi	sp,sp,-16
    80005d62:	e406                	sd	ra,8(sp)
    80005d64:	e022                	sd	s0,0(sp)
    80005d66:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d68:	ffffc097          	auipc	ra,0xffffc
    80005d6c:	c1c080e7          	jalr	-996(ra) # 80001984 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d70:	0085171b          	slliw	a4,a0,0x8
    80005d74:	0c0027b7          	lui	a5,0xc002
    80005d78:	97ba                	add	a5,a5,a4
    80005d7a:	40200713          	li	a4,1026
    80005d7e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d82:	00d5151b          	slliw	a0,a0,0xd
    80005d86:	0c2017b7          	lui	a5,0xc201
    80005d8a:	953e                	add	a0,a0,a5
    80005d8c:	00052023          	sw	zero,0(a0)
}
    80005d90:	60a2                	ld	ra,8(sp)
    80005d92:	6402                	ld	s0,0(sp)
    80005d94:	0141                	addi	sp,sp,16
    80005d96:	8082                	ret

0000000080005d98 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d98:	1141                	addi	sp,sp,-16
    80005d9a:	e406                	sd	ra,8(sp)
    80005d9c:	e022                	sd	s0,0(sp)
    80005d9e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005da0:	ffffc097          	auipc	ra,0xffffc
    80005da4:	be4080e7          	jalr	-1052(ra) # 80001984 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005da8:	00d5179b          	slliw	a5,a0,0xd
    80005dac:	0c201537          	lui	a0,0xc201
    80005db0:	953e                	add	a0,a0,a5
  return irq;
}
    80005db2:	4148                	lw	a0,4(a0)
    80005db4:	60a2                	ld	ra,8(sp)
    80005db6:	6402                	ld	s0,0(sp)
    80005db8:	0141                	addi	sp,sp,16
    80005dba:	8082                	ret

0000000080005dbc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005dbc:	1101                	addi	sp,sp,-32
    80005dbe:	ec06                	sd	ra,24(sp)
    80005dc0:	e822                	sd	s0,16(sp)
    80005dc2:	e426                	sd	s1,8(sp)
    80005dc4:	1000                	addi	s0,sp,32
    80005dc6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005dc8:	ffffc097          	auipc	ra,0xffffc
    80005dcc:	bbc080e7          	jalr	-1092(ra) # 80001984 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005dd0:	00d5151b          	slliw	a0,a0,0xd
    80005dd4:	0c2017b7          	lui	a5,0xc201
    80005dd8:	97aa                	add	a5,a5,a0
    80005dda:	c3c4                	sw	s1,4(a5)
}
    80005ddc:	60e2                	ld	ra,24(sp)
    80005dde:	6442                	ld	s0,16(sp)
    80005de0:	64a2                	ld	s1,8(sp)
    80005de2:	6105                	addi	sp,sp,32
    80005de4:	8082                	ret

0000000080005de6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005de6:	1141                	addi	sp,sp,-16
    80005de8:	e406                	sd	ra,8(sp)
    80005dea:	e022                	sd	s0,0(sp)
    80005dec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dee:	479d                	li	a5,7
    80005df0:	06a7c963          	blt	a5,a0,80005e62 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80005df4:	0001d797          	auipc	a5,0x1d
    80005df8:	20c78793          	addi	a5,a5,524 # 80023000 <disk>
    80005dfc:	00a78733          	add	a4,a5,a0
    80005e00:	6789                	lui	a5,0x2
    80005e02:	97ba                	add	a5,a5,a4
    80005e04:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005e08:	e7ad                	bnez	a5,80005e72 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e0a:	00451793          	slli	a5,a0,0x4
    80005e0e:	0001f717          	auipc	a4,0x1f
    80005e12:	1f270713          	addi	a4,a4,498 # 80025000 <disk+0x2000>
    80005e16:	6314                	ld	a3,0(a4)
    80005e18:	96be                	add	a3,a3,a5
    80005e1a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005e1e:	6314                	ld	a3,0(a4)
    80005e20:	96be                	add	a3,a3,a5
    80005e22:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005e26:	6314                	ld	a3,0(a4)
    80005e28:	96be                	add	a3,a3,a5
    80005e2a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005e2e:	6318                	ld	a4,0(a4)
    80005e30:	97ba                	add	a5,a5,a4
    80005e32:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005e36:	0001d797          	auipc	a5,0x1d
    80005e3a:	1ca78793          	addi	a5,a5,458 # 80023000 <disk>
    80005e3e:	97aa                	add	a5,a5,a0
    80005e40:	6509                	lui	a0,0x2
    80005e42:	953e                	add	a0,a0,a5
    80005e44:	4785                	li	a5,1
    80005e46:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005e4a:	0001f517          	auipc	a0,0x1f
    80005e4e:	1ce50513          	addi	a0,a0,462 # 80025018 <disk+0x2018>
    80005e52:	ffffc097          	auipc	ra,0xffffc
    80005e56:	4ee080e7          	jalr	1262(ra) # 80002340 <wakeup>
}
    80005e5a:	60a2                	ld	ra,8(sp)
    80005e5c:	6402                	ld	s0,0(sp)
    80005e5e:	0141                	addi	sp,sp,16
    80005e60:	8082                	ret
    panic("free_desc 1");
    80005e62:	00003517          	auipc	a0,0x3
    80005e66:	92650513          	addi	a0,a0,-1754 # 80008788 <syscalls+0x340>
    80005e6a:	ffffa097          	auipc	ra,0xffffa
    80005e6e:	6d4080e7          	jalr	1748(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005e72:	00003517          	auipc	a0,0x3
    80005e76:	92650513          	addi	a0,a0,-1754 # 80008798 <syscalls+0x350>
    80005e7a:	ffffa097          	auipc	ra,0xffffa
    80005e7e:	6c4080e7          	jalr	1732(ra) # 8000053e <panic>

0000000080005e82 <virtio_disk_init>:
{
    80005e82:	1101                	addi	sp,sp,-32
    80005e84:	ec06                	sd	ra,24(sp)
    80005e86:	e822                	sd	s0,16(sp)
    80005e88:	e426                	sd	s1,8(sp)
    80005e8a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e8c:	00003597          	auipc	a1,0x3
    80005e90:	91c58593          	addi	a1,a1,-1764 # 800087a8 <syscalls+0x360>
    80005e94:	0001f517          	auipc	a0,0x1f
    80005e98:	29450513          	addi	a0,a0,660 # 80025128 <disk+0x2128>
    80005e9c:	ffffb097          	auipc	ra,0xffffb
    80005ea0:	cb8080e7          	jalr	-840(ra) # 80000b54 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ea4:	100017b7          	lui	a5,0x10001
    80005ea8:	4398                	lw	a4,0(a5)
    80005eaa:	2701                	sext.w	a4,a4
    80005eac:	747277b7          	lui	a5,0x74727
    80005eb0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005eb4:	0ef71163          	bne	a4,a5,80005f96 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005eb8:	100017b7          	lui	a5,0x10001
    80005ebc:	43dc                	lw	a5,4(a5)
    80005ebe:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ec0:	4705                	li	a4,1
    80005ec2:	0ce79a63          	bne	a5,a4,80005f96 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ec6:	100017b7          	lui	a5,0x10001
    80005eca:	479c                	lw	a5,8(a5)
    80005ecc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005ece:	4709                	li	a4,2
    80005ed0:	0ce79363          	bne	a5,a4,80005f96 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005ed4:	100017b7          	lui	a5,0x10001
    80005ed8:	47d8                	lw	a4,12(a5)
    80005eda:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005edc:	554d47b7          	lui	a5,0x554d4
    80005ee0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005ee4:	0af71963          	bne	a4,a5,80005f96 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ee8:	100017b7          	lui	a5,0x10001
    80005eec:	4705                	li	a4,1
    80005eee:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ef0:	470d                	li	a4,3
    80005ef2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005ef4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005ef6:	c7ffe737          	lui	a4,0xc7ffe
    80005efa:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005efe:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f00:	2701                	sext.w	a4,a4
    80005f02:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f04:	472d                	li	a4,11
    80005f06:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f08:	473d                	li	a4,15
    80005f0a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005f0c:	6705                	lui	a4,0x1
    80005f0e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f10:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f14:	5bdc                	lw	a5,52(a5)
    80005f16:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f18:	c7d9                	beqz	a5,80005fa6 <virtio_disk_init+0x124>
  if(max < NUM)
    80005f1a:	471d                	li	a4,7
    80005f1c:	08f77d63          	bgeu	a4,a5,80005fb6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f20:	100014b7          	lui	s1,0x10001
    80005f24:	47a1                	li	a5,8
    80005f26:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005f28:	6609                	lui	a2,0x2
    80005f2a:	4581                	li	a1,0
    80005f2c:	0001d517          	auipc	a0,0x1d
    80005f30:	0d450513          	addi	a0,a0,212 # 80023000 <disk>
    80005f34:	ffffb097          	auipc	ra,0xffffb
    80005f38:	dac080e7          	jalr	-596(ra) # 80000ce0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005f3c:	0001d717          	auipc	a4,0x1d
    80005f40:	0c470713          	addi	a4,a4,196 # 80023000 <disk>
    80005f44:	00c75793          	srli	a5,a4,0xc
    80005f48:	2781                	sext.w	a5,a5
    80005f4a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005f4c:	0001f797          	auipc	a5,0x1f
    80005f50:	0b478793          	addi	a5,a5,180 # 80025000 <disk+0x2000>
    80005f54:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005f56:	0001d717          	auipc	a4,0x1d
    80005f5a:	12a70713          	addi	a4,a4,298 # 80023080 <disk+0x80>
    80005f5e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005f60:	0001e717          	auipc	a4,0x1e
    80005f64:	0a070713          	addi	a4,a4,160 # 80024000 <disk+0x1000>
    80005f68:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005f6a:	4705                	li	a4,1
    80005f6c:	00e78c23          	sb	a4,24(a5)
    80005f70:	00e78ca3          	sb	a4,25(a5)
    80005f74:	00e78d23          	sb	a4,26(a5)
    80005f78:	00e78da3          	sb	a4,27(a5)
    80005f7c:	00e78e23          	sb	a4,28(a5)
    80005f80:	00e78ea3          	sb	a4,29(a5)
    80005f84:	00e78f23          	sb	a4,30(a5)
    80005f88:	00e78fa3          	sb	a4,31(a5)
}
    80005f8c:	60e2                	ld	ra,24(sp)
    80005f8e:	6442                	ld	s0,16(sp)
    80005f90:	64a2                	ld	s1,8(sp)
    80005f92:	6105                	addi	sp,sp,32
    80005f94:	8082                	ret
    panic("could not find virtio disk");
    80005f96:	00003517          	auipc	a0,0x3
    80005f9a:	82250513          	addi	a0,a0,-2014 # 800087b8 <syscalls+0x370>
    80005f9e:	ffffa097          	auipc	ra,0xffffa
    80005fa2:	5a0080e7          	jalr	1440(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80005fa6:	00003517          	auipc	a0,0x3
    80005faa:	83250513          	addi	a0,a0,-1998 # 800087d8 <syscalls+0x390>
    80005fae:	ffffa097          	auipc	ra,0xffffa
    80005fb2:	590080e7          	jalr	1424(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80005fb6:	00003517          	auipc	a0,0x3
    80005fba:	84250513          	addi	a0,a0,-1982 # 800087f8 <syscalls+0x3b0>
    80005fbe:	ffffa097          	auipc	ra,0xffffa
    80005fc2:	580080e7          	jalr	1408(ra) # 8000053e <panic>

0000000080005fc6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fc6:	7159                	addi	sp,sp,-112
    80005fc8:	f486                	sd	ra,104(sp)
    80005fca:	f0a2                	sd	s0,96(sp)
    80005fcc:	eca6                	sd	s1,88(sp)
    80005fce:	e8ca                	sd	s2,80(sp)
    80005fd0:	e4ce                	sd	s3,72(sp)
    80005fd2:	e0d2                	sd	s4,64(sp)
    80005fd4:	fc56                	sd	s5,56(sp)
    80005fd6:	f85a                	sd	s6,48(sp)
    80005fd8:	f45e                	sd	s7,40(sp)
    80005fda:	f062                	sd	s8,32(sp)
    80005fdc:	ec66                	sd	s9,24(sp)
    80005fde:	e86a                	sd	s10,16(sp)
    80005fe0:	1880                	addi	s0,sp,112
    80005fe2:	892a                	mv	s2,a0
    80005fe4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fe6:	00c52c83          	lw	s9,12(a0)
    80005fea:	001c9c9b          	slliw	s9,s9,0x1
    80005fee:	1c82                	slli	s9,s9,0x20
    80005ff0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005ff4:	0001f517          	auipc	a0,0x1f
    80005ff8:	13450513          	addi	a0,a0,308 # 80025128 <disk+0x2128>
    80005ffc:	ffffb097          	auipc	ra,0xffffb
    80006000:	be8080e7          	jalr	-1048(ra) # 80000be4 <acquire>
  for(int i = 0; i < 3; i++){
    80006004:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006006:	4c21                	li	s8,8
      disk.free[i] = 0;
    80006008:	0001db97          	auipc	s7,0x1d
    8000600c:	ff8b8b93          	addi	s7,s7,-8 # 80023000 <disk>
    80006010:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006012:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006014:	8a4e                	mv	s4,s3
    80006016:	a051                	j	8000609a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80006018:	00fb86b3          	add	a3,s7,a5
    8000601c:	96da                	add	a3,a3,s6
    8000601e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006022:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006024:	0207c563          	bltz	a5,8000604e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006028:	2485                	addiw	s1,s1,1
    8000602a:	0711                	addi	a4,a4,4
    8000602c:	25548063          	beq	s1,s5,8000626c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006030:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006032:	0001f697          	auipc	a3,0x1f
    80006036:	fe668693          	addi	a3,a3,-26 # 80025018 <disk+0x2018>
    8000603a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000603c:	0006c583          	lbu	a1,0(a3)
    80006040:	fde1                	bnez	a1,80006018 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006042:	2785                	addiw	a5,a5,1
    80006044:	0685                	addi	a3,a3,1
    80006046:	ff879be3          	bne	a5,s8,8000603c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000604a:	57fd                	li	a5,-1
    8000604c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000604e:	02905a63          	blez	s1,80006082 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006052:	f9042503          	lw	a0,-112(s0)
    80006056:	00000097          	auipc	ra,0x0
    8000605a:	d90080e7          	jalr	-624(ra) # 80005de6 <free_desc>
      for(int j = 0; j < i; j++)
    8000605e:	4785                	li	a5,1
    80006060:	0297d163          	bge	a5,s1,80006082 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006064:	f9442503          	lw	a0,-108(s0)
    80006068:	00000097          	auipc	ra,0x0
    8000606c:	d7e080e7          	jalr	-642(ra) # 80005de6 <free_desc>
      for(int j = 0; j < i; j++)
    80006070:	4789                	li	a5,2
    80006072:	0097d863          	bge	a5,s1,80006082 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006076:	f9842503          	lw	a0,-104(s0)
    8000607a:	00000097          	auipc	ra,0x0
    8000607e:	d6c080e7          	jalr	-660(ra) # 80005de6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006082:	0001f597          	auipc	a1,0x1f
    80006086:	0a658593          	addi	a1,a1,166 # 80025128 <disk+0x2128>
    8000608a:	0001f517          	auipc	a0,0x1f
    8000608e:	f8e50513          	addi	a0,a0,-114 # 80025018 <disk+0x2018>
    80006092:	ffffc097          	auipc	ra,0xffffc
    80006096:	122080e7          	jalr	290(ra) # 800021b4 <sleep>
  for(int i = 0; i < 3; i++){
    8000609a:	f9040713          	addi	a4,s0,-112
    8000609e:	84ce                	mv	s1,s3
    800060a0:	bf41                	j	80006030 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800060a2:	20058713          	addi	a4,a1,512
    800060a6:	00471693          	slli	a3,a4,0x4
    800060aa:	0001d717          	auipc	a4,0x1d
    800060ae:	f5670713          	addi	a4,a4,-170 # 80023000 <disk>
    800060b2:	9736                	add	a4,a4,a3
    800060b4:	4685                	li	a3,1
    800060b6:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060ba:	20058713          	addi	a4,a1,512
    800060be:	00471693          	slli	a3,a4,0x4
    800060c2:	0001d717          	auipc	a4,0x1d
    800060c6:	f3e70713          	addi	a4,a4,-194 # 80023000 <disk>
    800060ca:	9736                	add	a4,a4,a3
    800060cc:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800060d0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060d4:	7679                	lui	a2,0xffffe
    800060d6:	963e                	add	a2,a2,a5
    800060d8:	0001f697          	auipc	a3,0x1f
    800060dc:	f2868693          	addi	a3,a3,-216 # 80025000 <disk+0x2000>
    800060e0:	6298                	ld	a4,0(a3)
    800060e2:	9732                	add	a4,a4,a2
    800060e4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060e6:	6298                	ld	a4,0(a3)
    800060e8:	9732                	add	a4,a4,a2
    800060ea:	4541                	li	a0,16
    800060ec:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060ee:	6298                	ld	a4,0(a3)
    800060f0:	9732                	add	a4,a4,a2
    800060f2:	4505                	li	a0,1
    800060f4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800060f8:	f9442703          	lw	a4,-108(s0)
    800060fc:	6288                	ld	a0,0(a3)
    800060fe:	962a                	add	a2,a2,a0
    80006100:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006104:	0712                	slli	a4,a4,0x4
    80006106:	6290                	ld	a2,0(a3)
    80006108:	963a                	add	a2,a2,a4
    8000610a:	05890513          	addi	a0,s2,88
    8000610e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006110:	6294                	ld	a3,0(a3)
    80006112:	96ba                	add	a3,a3,a4
    80006114:	40000613          	li	a2,1024
    80006118:	c690                	sw	a2,8(a3)
  if(write)
    8000611a:	140d0063          	beqz	s10,8000625a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000611e:	0001f697          	auipc	a3,0x1f
    80006122:	ee26b683          	ld	a3,-286(a3) # 80025000 <disk+0x2000>
    80006126:	96ba                	add	a3,a3,a4
    80006128:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000612c:	0001d817          	auipc	a6,0x1d
    80006130:	ed480813          	addi	a6,a6,-300 # 80023000 <disk>
    80006134:	0001f517          	auipc	a0,0x1f
    80006138:	ecc50513          	addi	a0,a0,-308 # 80025000 <disk+0x2000>
    8000613c:	6114                	ld	a3,0(a0)
    8000613e:	96ba                	add	a3,a3,a4
    80006140:	00c6d603          	lhu	a2,12(a3)
    80006144:	00166613          	ori	a2,a2,1
    80006148:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000614c:	f9842683          	lw	a3,-104(s0)
    80006150:	6110                	ld	a2,0(a0)
    80006152:	9732                	add	a4,a4,a2
    80006154:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006158:	20058613          	addi	a2,a1,512
    8000615c:	0612                	slli	a2,a2,0x4
    8000615e:	9642                	add	a2,a2,a6
    80006160:	577d                	li	a4,-1
    80006162:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006166:	00469713          	slli	a4,a3,0x4
    8000616a:	6114                	ld	a3,0(a0)
    8000616c:	96ba                	add	a3,a3,a4
    8000616e:	03078793          	addi	a5,a5,48
    80006172:	97c2                	add	a5,a5,a6
    80006174:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80006176:	611c                	ld	a5,0(a0)
    80006178:	97ba                	add	a5,a5,a4
    8000617a:	4685                	li	a3,1
    8000617c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000617e:	611c                	ld	a5,0(a0)
    80006180:	97ba                	add	a5,a5,a4
    80006182:	4809                	li	a6,2
    80006184:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006188:	611c                	ld	a5,0(a0)
    8000618a:	973e                	add	a4,a4,a5
    8000618c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006190:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006194:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006198:	6518                	ld	a4,8(a0)
    8000619a:	00275783          	lhu	a5,2(a4)
    8000619e:	8b9d                	andi	a5,a5,7
    800061a0:	0786                	slli	a5,a5,0x1
    800061a2:	97ba                	add	a5,a5,a4
    800061a4:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800061a8:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800061ac:	6518                	ld	a4,8(a0)
    800061ae:	00275783          	lhu	a5,2(a4)
    800061b2:	2785                	addiw	a5,a5,1
    800061b4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800061b8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800061bc:	100017b7          	lui	a5,0x10001
    800061c0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800061c4:	00492703          	lw	a4,4(s2)
    800061c8:	4785                	li	a5,1
    800061ca:	02f71163          	bne	a4,a5,800061ec <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    800061ce:	0001f997          	auipc	s3,0x1f
    800061d2:	f5a98993          	addi	s3,s3,-166 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    800061d6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800061d8:	85ce                	mv	a1,s3
    800061da:	854a                	mv	a0,s2
    800061dc:	ffffc097          	auipc	ra,0xffffc
    800061e0:	fd8080e7          	jalr	-40(ra) # 800021b4 <sleep>
  while(b->disk == 1) {
    800061e4:	00492783          	lw	a5,4(s2)
    800061e8:	fe9788e3          	beq	a5,s1,800061d8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800061ec:	f9042903          	lw	s2,-112(s0)
    800061f0:	20090793          	addi	a5,s2,512
    800061f4:	00479713          	slli	a4,a5,0x4
    800061f8:	0001d797          	auipc	a5,0x1d
    800061fc:	e0878793          	addi	a5,a5,-504 # 80023000 <disk>
    80006200:	97ba                	add	a5,a5,a4
    80006202:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006206:	0001f997          	auipc	s3,0x1f
    8000620a:	dfa98993          	addi	s3,s3,-518 # 80025000 <disk+0x2000>
    8000620e:	00491713          	slli	a4,s2,0x4
    80006212:	0009b783          	ld	a5,0(s3)
    80006216:	97ba                	add	a5,a5,a4
    80006218:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000621c:	854a                	mv	a0,s2
    8000621e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006222:	00000097          	auipc	ra,0x0
    80006226:	bc4080e7          	jalr	-1084(ra) # 80005de6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000622a:	8885                	andi	s1,s1,1
    8000622c:	f0ed                	bnez	s1,8000620e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000622e:	0001f517          	auipc	a0,0x1f
    80006232:	efa50513          	addi	a0,a0,-262 # 80025128 <disk+0x2128>
    80006236:	ffffb097          	auipc	ra,0xffffb
    8000623a:	a62080e7          	jalr	-1438(ra) # 80000c98 <release>
}
    8000623e:	70a6                	ld	ra,104(sp)
    80006240:	7406                	ld	s0,96(sp)
    80006242:	64e6                	ld	s1,88(sp)
    80006244:	6946                	ld	s2,80(sp)
    80006246:	69a6                	ld	s3,72(sp)
    80006248:	6a06                	ld	s4,64(sp)
    8000624a:	7ae2                	ld	s5,56(sp)
    8000624c:	7b42                	ld	s6,48(sp)
    8000624e:	7ba2                	ld	s7,40(sp)
    80006250:	7c02                	ld	s8,32(sp)
    80006252:	6ce2                	ld	s9,24(sp)
    80006254:	6d42                	ld	s10,16(sp)
    80006256:	6165                	addi	sp,sp,112
    80006258:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000625a:	0001f697          	auipc	a3,0x1f
    8000625e:	da66b683          	ld	a3,-602(a3) # 80025000 <disk+0x2000>
    80006262:	96ba                	add	a3,a3,a4
    80006264:	4609                	li	a2,2
    80006266:	00c69623          	sh	a2,12(a3)
    8000626a:	b5c9                	j	8000612c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000626c:	f9042583          	lw	a1,-112(s0)
    80006270:	20058793          	addi	a5,a1,512
    80006274:	0792                	slli	a5,a5,0x4
    80006276:	0001d517          	auipc	a0,0x1d
    8000627a:	e3250513          	addi	a0,a0,-462 # 800230a8 <disk+0xa8>
    8000627e:	953e                	add	a0,a0,a5
  if(write)
    80006280:	e20d11e3          	bnez	s10,800060a2 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006284:	20058713          	addi	a4,a1,512
    80006288:	00471693          	slli	a3,a4,0x4
    8000628c:	0001d717          	auipc	a4,0x1d
    80006290:	d7470713          	addi	a4,a4,-652 # 80023000 <disk>
    80006294:	9736                	add	a4,a4,a3
    80006296:	0a072423          	sw	zero,168(a4)
    8000629a:	b505                	j	800060ba <virtio_disk_rw+0xf4>

000000008000629c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000629c:	1101                	addi	sp,sp,-32
    8000629e:	ec06                	sd	ra,24(sp)
    800062a0:	e822                	sd	s0,16(sp)
    800062a2:	e426                	sd	s1,8(sp)
    800062a4:	e04a                	sd	s2,0(sp)
    800062a6:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800062a8:	0001f517          	auipc	a0,0x1f
    800062ac:	e8050513          	addi	a0,a0,-384 # 80025128 <disk+0x2128>
    800062b0:	ffffb097          	auipc	ra,0xffffb
    800062b4:	934080e7          	jalr	-1740(ra) # 80000be4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800062b8:	10001737          	lui	a4,0x10001
    800062bc:	533c                	lw	a5,96(a4)
    800062be:	8b8d                	andi	a5,a5,3
    800062c0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800062c2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800062c6:	0001f797          	auipc	a5,0x1f
    800062ca:	d3a78793          	addi	a5,a5,-710 # 80025000 <disk+0x2000>
    800062ce:	6b94                	ld	a3,16(a5)
    800062d0:	0207d703          	lhu	a4,32(a5)
    800062d4:	0026d783          	lhu	a5,2(a3)
    800062d8:	06f70163          	beq	a4,a5,8000633a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800062dc:	0001d917          	auipc	s2,0x1d
    800062e0:	d2490913          	addi	s2,s2,-732 # 80023000 <disk>
    800062e4:	0001f497          	auipc	s1,0x1f
    800062e8:	d1c48493          	addi	s1,s1,-740 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800062ec:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800062f0:	6898                	ld	a4,16(s1)
    800062f2:	0204d783          	lhu	a5,32(s1)
    800062f6:	8b9d                	andi	a5,a5,7
    800062f8:	078e                	slli	a5,a5,0x3
    800062fa:	97ba                	add	a5,a5,a4
    800062fc:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800062fe:	20078713          	addi	a4,a5,512
    80006302:	0712                	slli	a4,a4,0x4
    80006304:	974a                	add	a4,a4,s2
    80006306:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000630a:	e731                	bnez	a4,80006356 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000630c:	20078793          	addi	a5,a5,512
    80006310:	0792                	slli	a5,a5,0x4
    80006312:	97ca                	add	a5,a5,s2
    80006314:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006316:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000631a:	ffffc097          	auipc	ra,0xffffc
    8000631e:	026080e7          	jalr	38(ra) # 80002340 <wakeup>

    disk.used_idx += 1;
    80006322:	0204d783          	lhu	a5,32(s1)
    80006326:	2785                	addiw	a5,a5,1
    80006328:	17c2                	slli	a5,a5,0x30
    8000632a:	93c1                	srli	a5,a5,0x30
    8000632c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006330:	6898                	ld	a4,16(s1)
    80006332:	00275703          	lhu	a4,2(a4)
    80006336:	faf71be3          	bne	a4,a5,800062ec <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000633a:	0001f517          	auipc	a0,0x1f
    8000633e:	dee50513          	addi	a0,a0,-530 # 80025128 <disk+0x2128>
    80006342:	ffffb097          	auipc	ra,0xffffb
    80006346:	956080e7          	jalr	-1706(ra) # 80000c98 <release>
}
    8000634a:	60e2                	ld	ra,24(sp)
    8000634c:	6442                	ld	s0,16(sp)
    8000634e:	64a2                	ld	s1,8(sp)
    80006350:	6902                	ld	s2,0(sp)
    80006352:	6105                	addi	sp,sp,32
    80006354:	8082                	ret
      panic("virtio_disk_intr status");
    80006356:	00002517          	auipc	a0,0x2
    8000635a:	4c250513          	addi	a0,a0,1218 # 80008818 <syscalls+0x3d0>
    8000635e:	ffffa097          	auipc	ra,0xffffa
    80006362:	1e0080e7          	jalr	480(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
