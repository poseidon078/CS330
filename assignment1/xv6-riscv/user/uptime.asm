
user/_uptime:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("%s\n", uptime());
   8:	00000097          	auipc	ra,0x0
   c:	332080e7          	jalr	818(ra) # 33a <uptime>
  10:	85aa                	mv	a1,a0
  12:	00000517          	auipc	a0,0x0
  16:	7ce50513          	addi	a0,a0,1998 # 7e0 <malloc+0xe8>
  1a:	00000097          	auipc	ra,0x0
  1e:	620080e7          	jalr	1568(ra) # 63a <printf>
  exit(0);
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	27e080e7          	jalr	638(ra) # 2a2 <exit>

000000000000002c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  2c:	1141                	addi	sp,sp,-16
  2e:	e422                	sd	s0,8(sp)
  30:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  32:	87aa                	mv	a5,a0
  34:	0585                	addi	a1,a1,1
  36:	0785                	addi	a5,a5,1
  38:	fff5c703          	lbu	a4,-1(a1)
  3c:	fee78fa3          	sb	a4,-1(a5)
  40:	fb75                	bnez	a4,34 <strcpy+0x8>
    ;
  return os;
}
  42:	6422                	ld	s0,8(sp)
  44:	0141                	addi	sp,sp,16
  46:	8082                	ret

0000000000000048 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  48:	1141                	addi	sp,sp,-16
  4a:	e422                	sd	s0,8(sp)
  4c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  4e:	00054783          	lbu	a5,0(a0)
  52:	cb91                	beqz	a5,66 <strcmp+0x1e>
  54:	0005c703          	lbu	a4,0(a1)
  58:	00f71763          	bne	a4,a5,66 <strcmp+0x1e>
    p++, q++;
  5c:	0505                	addi	a0,a0,1
  5e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  60:	00054783          	lbu	a5,0(a0)
  64:	fbe5                	bnez	a5,54 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  66:	0005c503          	lbu	a0,0(a1)
}
  6a:	40a7853b          	subw	a0,a5,a0
  6e:	6422                	ld	s0,8(sp)
  70:	0141                	addi	sp,sp,16
  72:	8082                	ret

0000000000000074 <strlen>:

uint
strlen(const char *s)
{
  74:	1141                	addi	sp,sp,-16
  76:	e422                	sd	s0,8(sp)
  78:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	cf91                	beqz	a5,9a <strlen+0x26>
  80:	0505                	addi	a0,a0,1
  82:	87aa                	mv	a5,a0
  84:	4685                	li	a3,1
  86:	9e89                	subw	a3,a3,a0
  88:	00f6853b          	addw	a0,a3,a5
  8c:	0785                	addi	a5,a5,1
  8e:	fff7c703          	lbu	a4,-1(a5)
  92:	fb7d                	bnez	a4,88 <strlen+0x14>
    ;
  return n;
}
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret
  for(n = 0; s[n]; n++)
  9a:	4501                	li	a0,0
  9c:	bfe5                	j	94 <strlen+0x20>

000000000000009e <memset>:

void*
memset(void *dst, int c, uint n)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a4:	ce09                	beqz	a2,be <memset+0x20>
  a6:	87aa                	mv	a5,a0
  a8:	fff6071b          	addiw	a4,a2,-1
  ac:	1702                	slli	a4,a4,0x20
  ae:	9301                	srli	a4,a4,0x20
  b0:	0705                	addi	a4,a4,1
  b2:	972a                	add	a4,a4,a0
    cdst[i] = c;
  b4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b8:	0785                	addi	a5,a5,1
  ba:	fee79de3          	bne	a5,a4,b4 <memset+0x16>
  }
  return dst;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strchr>:

char*
strchr(const char *s, char c)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  for(; *s; s++)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb99                	beqz	a5,e4 <strchr+0x20>
    if(*s == c)
  d0:	00f58763          	beq	a1,a5,de <strchr+0x1a>
  for(; *s; s++)
  d4:	0505                	addi	a0,a0,1
  d6:	00054783          	lbu	a5,0(a0)
  da:	fbfd                	bnez	a5,d0 <strchr+0xc>
      return (char*)s;
  return 0;
  dc:	4501                	li	a0,0
}
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret
  return 0;
  e4:	4501                	li	a0,0
  e6:	bfe5                	j	de <strchr+0x1a>

00000000000000e8 <gets>:

char*
gets(char *buf, int max)
{
  e8:	711d                	addi	sp,sp,-96
  ea:	ec86                	sd	ra,88(sp)
  ec:	e8a2                	sd	s0,80(sp)
  ee:	e4a6                	sd	s1,72(sp)
  f0:	e0ca                	sd	s2,64(sp)
  f2:	fc4e                	sd	s3,56(sp)
  f4:	f852                	sd	s4,48(sp)
  f6:	f456                	sd	s5,40(sp)
  f8:	f05a                	sd	s6,32(sp)
  fa:	ec5e                	sd	s7,24(sp)
  fc:	1080                	addi	s0,sp,96
  fe:	8baa                	mv	s7,a0
 100:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 102:	892a                	mv	s2,a0
 104:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 106:	4aa9                	li	s5,10
 108:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 10a:	89a6                	mv	s3,s1
 10c:	2485                	addiw	s1,s1,1
 10e:	0344d863          	bge	s1,s4,13e <gets+0x56>
    cc = read(0, &c, 1);
 112:	4605                	li	a2,1
 114:	faf40593          	addi	a1,s0,-81
 118:	4501                	li	a0,0
 11a:	00000097          	auipc	ra,0x0
 11e:	1a0080e7          	jalr	416(ra) # 2ba <read>
    if(cc < 1)
 122:	00a05e63          	blez	a0,13e <gets+0x56>
    buf[i++] = c;
 126:	faf44783          	lbu	a5,-81(s0)
 12a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 12e:	01578763          	beq	a5,s5,13c <gets+0x54>
 132:	0905                	addi	s2,s2,1
 134:	fd679be3          	bne	a5,s6,10a <gets+0x22>
  for(i=0; i+1 < max; ){
 138:	89a6                	mv	s3,s1
 13a:	a011                	j	13e <gets+0x56>
 13c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 13e:	99de                	add	s3,s3,s7
 140:	00098023          	sb	zero,0(s3)
  return buf;
}
 144:	855e                	mv	a0,s7
 146:	60e6                	ld	ra,88(sp)
 148:	6446                	ld	s0,80(sp)
 14a:	64a6                	ld	s1,72(sp)
 14c:	6906                	ld	s2,64(sp)
 14e:	79e2                	ld	s3,56(sp)
 150:	7a42                	ld	s4,48(sp)
 152:	7aa2                	ld	s5,40(sp)
 154:	7b02                	ld	s6,32(sp)
 156:	6be2                	ld	s7,24(sp)
 158:	6125                	addi	sp,sp,96
 15a:	8082                	ret

000000000000015c <stat>:

int
stat(const char *n, struct stat *st)
{
 15c:	1101                	addi	sp,sp,-32
 15e:	ec06                	sd	ra,24(sp)
 160:	e822                	sd	s0,16(sp)
 162:	e426                	sd	s1,8(sp)
 164:	e04a                	sd	s2,0(sp)
 166:	1000                	addi	s0,sp,32
 168:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 16a:	4581                	li	a1,0
 16c:	00000097          	auipc	ra,0x0
 170:	176080e7          	jalr	374(ra) # 2e2 <open>
  if(fd < 0)
 174:	02054563          	bltz	a0,19e <stat+0x42>
 178:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 17a:	85ca                	mv	a1,s2
 17c:	00000097          	auipc	ra,0x0
 180:	17e080e7          	jalr	382(ra) # 2fa <fstat>
 184:	892a                	mv	s2,a0
  close(fd);
 186:	8526                	mv	a0,s1
 188:	00000097          	auipc	ra,0x0
 18c:	142080e7          	jalr	322(ra) # 2ca <close>
  return r;
}
 190:	854a                	mv	a0,s2
 192:	60e2                	ld	ra,24(sp)
 194:	6442                	ld	s0,16(sp)
 196:	64a2                	ld	s1,8(sp)
 198:	6902                	ld	s2,0(sp)
 19a:	6105                	addi	sp,sp,32
 19c:	8082                	ret
    return -1;
 19e:	597d                	li	s2,-1
 1a0:	bfc5                	j	190 <stat+0x34>

00000000000001a2 <atoi>:

int
atoi(const char *s)
{
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e422                	sd	s0,8(sp)
 1a6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1a8:	00054603          	lbu	a2,0(a0)
 1ac:	fd06079b          	addiw	a5,a2,-48
 1b0:	0ff7f793          	andi	a5,a5,255
 1b4:	4725                	li	a4,9
 1b6:	02f76963          	bltu	a4,a5,1e8 <atoi+0x46>
 1ba:	86aa                	mv	a3,a0
  n = 0;
 1bc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1be:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1c0:	0685                	addi	a3,a3,1
 1c2:	0025179b          	slliw	a5,a0,0x2
 1c6:	9fa9                	addw	a5,a5,a0
 1c8:	0017979b          	slliw	a5,a5,0x1
 1cc:	9fb1                	addw	a5,a5,a2
 1ce:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d2:	0006c603          	lbu	a2,0(a3)
 1d6:	fd06071b          	addiw	a4,a2,-48
 1da:	0ff77713          	andi	a4,a4,255
 1de:	fee5f1e3          	bgeu	a1,a4,1c0 <atoi+0x1e>
  return n;
}
 1e2:	6422                	ld	s0,8(sp)
 1e4:	0141                	addi	sp,sp,16
 1e6:	8082                	ret
  n = 0;
 1e8:	4501                	li	a0,0
 1ea:	bfe5                	j	1e2 <atoi+0x40>

00000000000001ec <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f2:	02b57663          	bgeu	a0,a1,21e <memmove+0x32>
    while(n-- > 0)
 1f6:	02c05163          	blez	a2,218 <memmove+0x2c>
 1fa:	fff6079b          	addiw	a5,a2,-1
 1fe:	1782                	slli	a5,a5,0x20
 200:	9381                	srli	a5,a5,0x20
 202:	0785                	addi	a5,a5,1
 204:	97aa                	add	a5,a5,a0
  dst = vdst;
 206:	872a                	mv	a4,a0
      *dst++ = *src++;
 208:	0585                	addi	a1,a1,1
 20a:	0705                	addi	a4,a4,1
 20c:	fff5c683          	lbu	a3,-1(a1)
 210:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 214:	fee79ae3          	bne	a5,a4,208 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
    dst += n;
 21e:	00c50733          	add	a4,a0,a2
    src += n;
 222:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 224:	fec05ae3          	blez	a2,218 <memmove+0x2c>
 228:	fff6079b          	addiw	a5,a2,-1
 22c:	1782                	slli	a5,a5,0x20
 22e:	9381                	srli	a5,a5,0x20
 230:	fff7c793          	not	a5,a5
 234:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 236:	15fd                	addi	a1,a1,-1
 238:	177d                	addi	a4,a4,-1
 23a:	0005c683          	lbu	a3,0(a1)
 23e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 242:	fee79ae3          	bne	a5,a4,236 <memmove+0x4a>
 246:	bfc9                	j	218 <memmove+0x2c>

0000000000000248 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 24e:	ca05                	beqz	a2,27e <memcmp+0x36>
 250:	fff6069b          	addiw	a3,a2,-1
 254:	1682                	slli	a3,a3,0x20
 256:	9281                	srli	a3,a3,0x20
 258:	0685                	addi	a3,a3,1
 25a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 25c:	00054783          	lbu	a5,0(a0)
 260:	0005c703          	lbu	a4,0(a1)
 264:	00e79863          	bne	a5,a4,274 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 268:	0505                	addi	a0,a0,1
    p2++;
 26a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 26c:	fed518e3          	bne	a0,a3,25c <memcmp+0x14>
  }
  return 0;
 270:	4501                	li	a0,0
 272:	a019                	j	278 <memcmp+0x30>
      return *p1 - *p2;
 274:	40e7853b          	subw	a0,a5,a4
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
  return 0;
 27e:	4501                	li	a0,0
 280:	bfe5                	j	278 <memcmp+0x30>

0000000000000282 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 282:	1141                	addi	sp,sp,-16
 284:	e406                	sd	ra,8(sp)
 286:	e022                	sd	s0,0(sp)
 288:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 28a:	00000097          	auipc	ra,0x0
 28e:	f62080e7          	jalr	-158(ra) # 1ec <memmove>
}
 292:	60a2                	ld	ra,8(sp)
 294:	6402                	ld	s0,0(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret

000000000000029a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 29a:	4885                	li	a7,1
 ecall
 29c:	00000073          	ecall
 ret
 2a0:	8082                	ret

00000000000002a2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2a2:	4889                	li	a7,2
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <wait>:
.global wait
wait:
 li a7, SYS_wait
 2aa:	488d                	li	a7,3
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2b2:	4891                	li	a7,4
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <read>:
.global read
read:
 li a7, SYS_read
 2ba:	4895                	li	a7,5
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <write>:
.global write
write:
 li a7, SYS_write
 2c2:	48c1                	li	a7,16
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <close>:
.global close
close:
 li a7, SYS_close
 2ca:	48d5                	li	a7,21
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2d2:	4899                	li	a7,6
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <exec>:
.global exec
exec:
 li a7, SYS_exec
 2da:	489d                	li	a7,7
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <open>:
.global open
open:
 li a7, SYS_open
 2e2:	48bd                	li	a7,15
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2ea:	48c5                	li	a7,17
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2f2:	48c9                	li	a7,18
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2fa:	48a1                	li	a7,8
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <link>:
.global link
link:
 li a7, SYS_link
 302:	48cd                	li	a7,19
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 30a:	48d1                	li	a7,20
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 312:	48a5                	li	a7,9
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <dup>:
.global dup
dup:
 li a7, SYS_dup
 31a:	48a9                	li	a7,10
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 322:	48ad                	li	a7,11
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 32a:	48b1                	li	a7,12
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 332:	48b5                	li	a7,13
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 33a:	48b9                	li	a7,14
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 342:	48d9                	li	a7,22
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <yield>:
.global yield
yield:
 li a7, SYS_yield
 34a:	48dd                	li	a7,23
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 352:	48e1                	li	a7,24
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 35a:	48e5                	li	a7,25
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 362:	1101                	addi	sp,sp,-32
 364:	ec06                	sd	ra,24(sp)
 366:	e822                	sd	s0,16(sp)
 368:	1000                	addi	s0,sp,32
 36a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 36e:	4605                	li	a2,1
 370:	fef40593          	addi	a1,s0,-17
 374:	00000097          	auipc	ra,0x0
 378:	f4e080e7          	jalr	-178(ra) # 2c2 <write>
}
 37c:	60e2                	ld	ra,24(sp)
 37e:	6442                	ld	s0,16(sp)
 380:	6105                	addi	sp,sp,32
 382:	8082                	ret

0000000000000384 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 384:	7139                	addi	sp,sp,-64
 386:	fc06                	sd	ra,56(sp)
 388:	f822                	sd	s0,48(sp)
 38a:	f426                	sd	s1,40(sp)
 38c:	f04a                	sd	s2,32(sp)
 38e:	ec4e                	sd	s3,24(sp)
 390:	0080                	addi	s0,sp,64
 392:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 394:	c299                	beqz	a3,39a <printint+0x16>
 396:	0805c863          	bltz	a1,426 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 39a:	2581                	sext.w	a1,a1
  neg = 0;
 39c:	4881                	li	a7,0
 39e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3a2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3a4:	2601                	sext.w	a2,a2
 3a6:	00000517          	auipc	a0,0x0
 3aa:	44a50513          	addi	a0,a0,1098 # 7f0 <digits>
 3ae:	883a                	mv	a6,a4
 3b0:	2705                	addiw	a4,a4,1
 3b2:	02c5f7bb          	remuw	a5,a1,a2
 3b6:	1782                	slli	a5,a5,0x20
 3b8:	9381                	srli	a5,a5,0x20
 3ba:	97aa                	add	a5,a5,a0
 3bc:	0007c783          	lbu	a5,0(a5)
 3c0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3c4:	0005879b          	sext.w	a5,a1
 3c8:	02c5d5bb          	divuw	a1,a1,a2
 3cc:	0685                	addi	a3,a3,1
 3ce:	fec7f0e3          	bgeu	a5,a2,3ae <printint+0x2a>
  if(neg)
 3d2:	00088b63          	beqz	a7,3e8 <printint+0x64>
    buf[i++] = '-';
 3d6:	fd040793          	addi	a5,s0,-48
 3da:	973e                	add	a4,a4,a5
 3dc:	02d00793          	li	a5,45
 3e0:	fef70823          	sb	a5,-16(a4)
 3e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3e8:	02e05863          	blez	a4,418 <printint+0x94>
 3ec:	fc040793          	addi	a5,s0,-64
 3f0:	00e78933          	add	s2,a5,a4
 3f4:	fff78993          	addi	s3,a5,-1
 3f8:	99ba                	add	s3,s3,a4
 3fa:	377d                	addiw	a4,a4,-1
 3fc:	1702                	slli	a4,a4,0x20
 3fe:	9301                	srli	a4,a4,0x20
 400:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 404:	fff94583          	lbu	a1,-1(s2)
 408:	8526                	mv	a0,s1
 40a:	00000097          	auipc	ra,0x0
 40e:	f58080e7          	jalr	-168(ra) # 362 <putc>
  while(--i >= 0)
 412:	197d                	addi	s2,s2,-1
 414:	ff3918e3          	bne	s2,s3,404 <printint+0x80>
}
 418:	70e2                	ld	ra,56(sp)
 41a:	7442                	ld	s0,48(sp)
 41c:	74a2                	ld	s1,40(sp)
 41e:	7902                	ld	s2,32(sp)
 420:	69e2                	ld	s3,24(sp)
 422:	6121                	addi	sp,sp,64
 424:	8082                	ret
    x = -xx;
 426:	40b005bb          	negw	a1,a1
    neg = 1;
 42a:	4885                	li	a7,1
    x = -xx;
 42c:	bf8d                	j	39e <printint+0x1a>

000000000000042e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 42e:	7119                	addi	sp,sp,-128
 430:	fc86                	sd	ra,120(sp)
 432:	f8a2                	sd	s0,112(sp)
 434:	f4a6                	sd	s1,104(sp)
 436:	f0ca                	sd	s2,96(sp)
 438:	ecce                	sd	s3,88(sp)
 43a:	e8d2                	sd	s4,80(sp)
 43c:	e4d6                	sd	s5,72(sp)
 43e:	e0da                	sd	s6,64(sp)
 440:	fc5e                	sd	s7,56(sp)
 442:	f862                	sd	s8,48(sp)
 444:	f466                	sd	s9,40(sp)
 446:	f06a                	sd	s10,32(sp)
 448:	ec6e                	sd	s11,24(sp)
 44a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 44c:	0005c903          	lbu	s2,0(a1)
 450:	18090f63          	beqz	s2,5ee <vprintf+0x1c0>
 454:	8aaa                	mv	s5,a0
 456:	8b32                	mv	s6,a2
 458:	00158493          	addi	s1,a1,1
  state = 0;
 45c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 45e:	02500a13          	li	s4,37
      if(c == 'd'){
 462:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 466:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 46a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 46e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 472:	00000b97          	auipc	s7,0x0
 476:	37eb8b93          	addi	s7,s7,894 # 7f0 <digits>
 47a:	a839                	j	498 <vprintf+0x6a>
        putc(fd, c);
 47c:	85ca                	mv	a1,s2
 47e:	8556                	mv	a0,s5
 480:	00000097          	auipc	ra,0x0
 484:	ee2080e7          	jalr	-286(ra) # 362 <putc>
 488:	a019                	j	48e <vprintf+0x60>
    } else if(state == '%'){
 48a:	01498f63          	beq	s3,s4,4a8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 48e:	0485                	addi	s1,s1,1
 490:	fff4c903          	lbu	s2,-1(s1)
 494:	14090d63          	beqz	s2,5ee <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 498:	0009079b          	sext.w	a5,s2
    if(state == 0){
 49c:	fe0997e3          	bnez	s3,48a <vprintf+0x5c>
      if(c == '%'){
 4a0:	fd479ee3          	bne	a5,s4,47c <vprintf+0x4e>
        state = '%';
 4a4:	89be                	mv	s3,a5
 4a6:	b7e5                	j	48e <vprintf+0x60>
      if(c == 'd'){
 4a8:	05878063          	beq	a5,s8,4e8 <vprintf+0xba>
      } else if(c == 'l') {
 4ac:	05978c63          	beq	a5,s9,504 <vprintf+0xd6>
      } else if(c == 'x') {
 4b0:	07a78863          	beq	a5,s10,520 <vprintf+0xf2>
      } else if(c == 'p') {
 4b4:	09b78463          	beq	a5,s11,53c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4b8:	07300713          	li	a4,115
 4bc:	0ce78663          	beq	a5,a4,588 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4c0:	06300713          	li	a4,99
 4c4:	0ee78e63          	beq	a5,a4,5c0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4c8:	11478863          	beq	a5,s4,5d8 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4cc:	85d2                	mv	a1,s4
 4ce:	8556                	mv	a0,s5
 4d0:	00000097          	auipc	ra,0x0
 4d4:	e92080e7          	jalr	-366(ra) # 362 <putc>
        putc(fd, c);
 4d8:	85ca                	mv	a1,s2
 4da:	8556                	mv	a0,s5
 4dc:	00000097          	auipc	ra,0x0
 4e0:	e86080e7          	jalr	-378(ra) # 362 <putc>
      }
      state = 0;
 4e4:	4981                	li	s3,0
 4e6:	b765                	j	48e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4e8:	008b0913          	addi	s2,s6,8
 4ec:	4685                	li	a3,1
 4ee:	4629                	li	a2,10
 4f0:	000b2583          	lw	a1,0(s6)
 4f4:	8556                	mv	a0,s5
 4f6:	00000097          	auipc	ra,0x0
 4fa:	e8e080e7          	jalr	-370(ra) # 384 <printint>
 4fe:	8b4a                	mv	s6,s2
      state = 0;
 500:	4981                	li	s3,0
 502:	b771                	j	48e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 504:	008b0913          	addi	s2,s6,8
 508:	4681                	li	a3,0
 50a:	4629                	li	a2,10
 50c:	000b2583          	lw	a1,0(s6)
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	e72080e7          	jalr	-398(ra) # 384 <printint>
 51a:	8b4a                	mv	s6,s2
      state = 0;
 51c:	4981                	li	s3,0
 51e:	bf85                	j	48e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 520:	008b0913          	addi	s2,s6,8
 524:	4681                	li	a3,0
 526:	4641                	li	a2,16
 528:	000b2583          	lw	a1,0(s6)
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	e56080e7          	jalr	-426(ra) # 384 <printint>
 536:	8b4a                	mv	s6,s2
      state = 0;
 538:	4981                	li	s3,0
 53a:	bf91                	j	48e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 53c:	008b0793          	addi	a5,s6,8
 540:	f8f43423          	sd	a5,-120(s0)
 544:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 548:	03000593          	li	a1,48
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	e14080e7          	jalr	-492(ra) # 362 <putc>
  putc(fd, 'x');
 556:	85ea                	mv	a1,s10
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	e08080e7          	jalr	-504(ra) # 362 <putc>
 562:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 564:	03c9d793          	srli	a5,s3,0x3c
 568:	97de                	add	a5,a5,s7
 56a:	0007c583          	lbu	a1,0(a5)
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	df2080e7          	jalr	-526(ra) # 362 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 578:	0992                	slli	s3,s3,0x4
 57a:	397d                	addiw	s2,s2,-1
 57c:	fe0914e3          	bnez	s2,564 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 580:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 584:	4981                	li	s3,0
 586:	b721                	j	48e <vprintf+0x60>
        s = va_arg(ap, char*);
 588:	008b0993          	addi	s3,s6,8
 58c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 590:	02090163          	beqz	s2,5b2 <vprintf+0x184>
        while(*s != 0){
 594:	00094583          	lbu	a1,0(s2)
 598:	c9a1                	beqz	a1,5e8 <vprintf+0x1ba>
          putc(fd, *s);
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	dc6080e7          	jalr	-570(ra) # 362 <putc>
          s++;
 5a4:	0905                	addi	s2,s2,1
        while(*s != 0){
 5a6:	00094583          	lbu	a1,0(s2)
 5aa:	f9e5                	bnez	a1,59a <vprintf+0x16c>
        s = va_arg(ap, char*);
 5ac:	8b4e                	mv	s6,s3
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	bdf9                	j	48e <vprintf+0x60>
          s = "(null)";
 5b2:	00000917          	auipc	s2,0x0
 5b6:	23690913          	addi	s2,s2,566 # 7e8 <malloc+0xf0>
        while(*s != 0){
 5ba:	02800593          	li	a1,40
 5be:	bff1                	j	59a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5c0:	008b0913          	addi	s2,s6,8
 5c4:	000b4583          	lbu	a1,0(s6)
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	d98080e7          	jalr	-616(ra) # 362 <putc>
 5d2:	8b4a                	mv	s6,s2
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	bd65                	j	48e <vprintf+0x60>
        putc(fd, c);
 5d8:	85d2                	mv	a1,s4
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	d86080e7          	jalr	-634(ra) # 362 <putc>
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	b565                	j	48e <vprintf+0x60>
        s = va_arg(ap, char*);
 5e8:	8b4e                	mv	s6,s3
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b54d                	j	48e <vprintf+0x60>
    }
  }
}
 5ee:	70e6                	ld	ra,120(sp)
 5f0:	7446                	ld	s0,112(sp)
 5f2:	74a6                	ld	s1,104(sp)
 5f4:	7906                	ld	s2,96(sp)
 5f6:	69e6                	ld	s3,88(sp)
 5f8:	6a46                	ld	s4,80(sp)
 5fa:	6aa6                	ld	s5,72(sp)
 5fc:	6b06                	ld	s6,64(sp)
 5fe:	7be2                	ld	s7,56(sp)
 600:	7c42                	ld	s8,48(sp)
 602:	7ca2                	ld	s9,40(sp)
 604:	7d02                	ld	s10,32(sp)
 606:	6de2                	ld	s11,24(sp)
 608:	6109                	addi	sp,sp,128
 60a:	8082                	ret

000000000000060c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 60c:	715d                	addi	sp,sp,-80
 60e:	ec06                	sd	ra,24(sp)
 610:	e822                	sd	s0,16(sp)
 612:	1000                	addi	s0,sp,32
 614:	e010                	sd	a2,0(s0)
 616:	e414                	sd	a3,8(s0)
 618:	e818                	sd	a4,16(s0)
 61a:	ec1c                	sd	a5,24(s0)
 61c:	03043023          	sd	a6,32(s0)
 620:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 624:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 628:	8622                	mv	a2,s0
 62a:	00000097          	auipc	ra,0x0
 62e:	e04080e7          	jalr	-508(ra) # 42e <vprintf>
}
 632:	60e2                	ld	ra,24(sp)
 634:	6442                	ld	s0,16(sp)
 636:	6161                	addi	sp,sp,80
 638:	8082                	ret

000000000000063a <printf>:

void
printf(const char *fmt, ...)
{
 63a:	711d                	addi	sp,sp,-96
 63c:	ec06                	sd	ra,24(sp)
 63e:	e822                	sd	s0,16(sp)
 640:	1000                	addi	s0,sp,32
 642:	e40c                	sd	a1,8(s0)
 644:	e810                	sd	a2,16(s0)
 646:	ec14                	sd	a3,24(s0)
 648:	f018                	sd	a4,32(s0)
 64a:	f41c                	sd	a5,40(s0)
 64c:	03043823          	sd	a6,48(s0)
 650:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 654:	00840613          	addi	a2,s0,8
 658:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 65c:	85aa                	mv	a1,a0
 65e:	4505                	li	a0,1
 660:	00000097          	auipc	ra,0x0
 664:	dce080e7          	jalr	-562(ra) # 42e <vprintf>
}
 668:	60e2                	ld	ra,24(sp)
 66a:	6442                	ld	s0,16(sp)
 66c:	6125                	addi	sp,sp,96
 66e:	8082                	ret

0000000000000670 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 670:	1141                	addi	sp,sp,-16
 672:	e422                	sd	s0,8(sp)
 674:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 676:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 67a:	00000797          	auipc	a5,0x0
 67e:	18e7b783          	ld	a5,398(a5) # 808 <freep>
 682:	a805                	j	6b2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 684:	4618                	lw	a4,8(a2)
 686:	9db9                	addw	a1,a1,a4
 688:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 68c:	6398                	ld	a4,0(a5)
 68e:	6318                	ld	a4,0(a4)
 690:	fee53823          	sd	a4,-16(a0)
 694:	a091                	j	6d8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 696:	ff852703          	lw	a4,-8(a0)
 69a:	9e39                	addw	a2,a2,a4
 69c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 69e:	ff053703          	ld	a4,-16(a0)
 6a2:	e398                	sd	a4,0(a5)
 6a4:	a099                	j	6ea <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a6:	6398                	ld	a4,0(a5)
 6a8:	00e7e463          	bltu	a5,a4,6b0 <free+0x40>
 6ac:	00e6ea63          	bltu	a3,a4,6c0 <free+0x50>
{
 6b0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b2:	fed7fae3          	bgeu	a5,a3,6a6 <free+0x36>
 6b6:	6398                	ld	a4,0(a5)
 6b8:	00e6e463          	bltu	a3,a4,6c0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6bc:	fee7eae3          	bltu	a5,a4,6b0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6c0:	ff852583          	lw	a1,-8(a0)
 6c4:	6390                	ld	a2,0(a5)
 6c6:	02059713          	slli	a4,a1,0x20
 6ca:	9301                	srli	a4,a4,0x20
 6cc:	0712                	slli	a4,a4,0x4
 6ce:	9736                	add	a4,a4,a3
 6d0:	fae60ae3          	beq	a2,a4,684 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6d4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6d8:	4790                	lw	a2,8(a5)
 6da:	02061713          	slli	a4,a2,0x20
 6de:	9301                	srli	a4,a4,0x20
 6e0:	0712                	slli	a4,a4,0x4
 6e2:	973e                	add	a4,a4,a5
 6e4:	fae689e3          	beq	a3,a4,696 <free+0x26>
  } else
    p->s.ptr = bp;
 6e8:	e394                	sd	a3,0(a5)
  freep = p;
 6ea:	00000717          	auipc	a4,0x0
 6ee:	10f73f23          	sd	a5,286(a4) # 808 <freep>
}
 6f2:	6422                	ld	s0,8(sp)
 6f4:	0141                	addi	sp,sp,16
 6f6:	8082                	ret

00000000000006f8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6f8:	7139                	addi	sp,sp,-64
 6fa:	fc06                	sd	ra,56(sp)
 6fc:	f822                	sd	s0,48(sp)
 6fe:	f426                	sd	s1,40(sp)
 700:	f04a                	sd	s2,32(sp)
 702:	ec4e                	sd	s3,24(sp)
 704:	e852                	sd	s4,16(sp)
 706:	e456                	sd	s5,8(sp)
 708:	e05a                	sd	s6,0(sp)
 70a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 70c:	02051493          	slli	s1,a0,0x20
 710:	9081                	srli	s1,s1,0x20
 712:	04bd                	addi	s1,s1,15
 714:	8091                	srli	s1,s1,0x4
 716:	0014899b          	addiw	s3,s1,1
 71a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 71c:	00000517          	auipc	a0,0x0
 720:	0ec53503          	ld	a0,236(a0) # 808 <freep>
 724:	c515                	beqz	a0,750 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 726:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 728:	4798                	lw	a4,8(a5)
 72a:	02977f63          	bgeu	a4,s1,768 <malloc+0x70>
 72e:	8a4e                	mv	s4,s3
 730:	0009871b          	sext.w	a4,s3
 734:	6685                	lui	a3,0x1
 736:	00d77363          	bgeu	a4,a3,73c <malloc+0x44>
 73a:	6a05                	lui	s4,0x1
 73c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 740:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 744:	00000917          	auipc	s2,0x0
 748:	0c490913          	addi	s2,s2,196 # 808 <freep>
  if(p == (char*)-1)
 74c:	5afd                	li	s5,-1
 74e:	a88d                	j	7c0 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 750:	00000797          	auipc	a5,0x0
 754:	0c078793          	addi	a5,a5,192 # 810 <base>
 758:	00000717          	auipc	a4,0x0
 75c:	0af73823          	sd	a5,176(a4) # 808 <freep>
 760:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 762:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 766:	b7e1                	j	72e <malloc+0x36>
      if(p->s.size == nunits)
 768:	02e48b63          	beq	s1,a4,79e <malloc+0xa6>
        p->s.size -= nunits;
 76c:	4137073b          	subw	a4,a4,s3
 770:	c798                	sw	a4,8(a5)
        p += p->s.size;
 772:	1702                	slli	a4,a4,0x20
 774:	9301                	srli	a4,a4,0x20
 776:	0712                	slli	a4,a4,0x4
 778:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 77a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 77e:	00000717          	auipc	a4,0x0
 782:	08a73523          	sd	a0,138(a4) # 808 <freep>
      return (void*)(p + 1);
 786:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 78a:	70e2                	ld	ra,56(sp)
 78c:	7442                	ld	s0,48(sp)
 78e:	74a2                	ld	s1,40(sp)
 790:	7902                	ld	s2,32(sp)
 792:	69e2                	ld	s3,24(sp)
 794:	6a42                	ld	s4,16(sp)
 796:	6aa2                	ld	s5,8(sp)
 798:	6b02                	ld	s6,0(sp)
 79a:	6121                	addi	sp,sp,64
 79c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 79e:	6398                	ld	a4,0(a5)
 7a0:	e118                	sd	a4,0(a0)
 7a2:	bff1                	j	77e <malloc+0x86>
  hp->s.size = nu;
 7a4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7a8:	0541                	addi	a0,a0,16
 7aa:	00000097          	auipc	ra,0x0
 7ae:	ec6080e7          	jalr	-314(ra) # 670 <free>
  return freep;
 7b2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7b6:	d971                	beqz	a0,78a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ba:	4798                	lw	a4,8(a5)
 7bc:	fa9776e3          	bgeu	a4,s1,768 <malloc+0x70>
    if(p == freep)
 7c0:	00093703          	ld	a4,0(s2)
 7c4:	853e                	mv	a0,a5
 7c6:	fef719e3          	bne	a4,a5,7b8 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7ca:	8552                	mv	a0,s4
 7cc:	00000097          	auipc	ra,0x0
 7d0:	b5e080e7          	jalr	-1186(ra) # 32a <sbrk>
  if(p == (char*)-1)
 7d4:	fd5518e3          	bne	a0,s5,7a4 <malloc+0xac>
        return 0;
 7d8:	4501                	li	a0,0
 7da:	bf45                	j	78a <malloc+0x92>
