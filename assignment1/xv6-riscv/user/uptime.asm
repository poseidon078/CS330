
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
  16:	7ae50513          	addi	a0,a0,1966 # 7c0 <malloc+0xe8>
  1a:	00000097          	auipc	ra,0x0
  1e:	600080e7          	jalr	1536(ra) # 61a <printf>
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

0000000000000342 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 342:	1101                	addi	sp,sp,-32
 344:	ec06                	sd	ra,24(sp)
 346:	e822                	sd	s0,16(sp)
 348:	1000                	addi	s0,sp,32
 34a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 34e:	4605                	li	a2,1
 350:	fef40593          	addi	a1,s0,-17
 354:	00000097          	auipc	ra,0x0
 358:	f6e080e7          	jalr	-146(ra) # 2c2 <write>
}
 35c:	60e2                	ld	ra,24(sp)
 35e:	6442                	ld	s0,16(sp)
 360:	6105                	addi	sp,sp,32
 362:	8082                	ret

0000000000000364 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 364:	7139                	addi	sp,sp,-64
 366:	fc06                	sd	ra,56(sp)
 368:	f822                	sd	s0,48(sp)
 36a:	f426                	sd	s1,40(sp)
 36c:	f04a                	sd	s2,32(sp)
 36e:	ec4e                	sd	s3,24(sp)
 370:	0080                	addi	s0,sp,64
 372:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 374:	c299                	beqz	a3,37a <printint+0x16>
 376:	0805c863          	bltz	a1,406 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 37a:	2581                	sext.w	a1,a1
  neg = 0;
 37c:	4881                	li	a7,0
 37e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 382:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 384:	2601                	sext.w	a2,a2
 386:	00000517          	auipc	a0,0x0
 38a:	44a50513          	addi	a0,a0,1098 # 7d0 <digits>
 38e:	883a                	mv	a6,a4
 390:	2705                	addiw	a4,a4,1
 392:	02c5f7bb          	remuw	a5,a1,a2
 396:	1782                	slli	a5,a5,0x20
 398:	9381                	srli	a5,a5,0x20
 39a:	97aa                	add	a5,a5,a0
 39c:	0007c783          	lbu	a5,0(a5)
 3a0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3a4:	0005879b          	sext.w	a5,a1
 3a8:	02c5d5bb          	divuw	a1,a1,a2
 3ac:	0685                	addi	a3,a3,1
 3ae:	fec7f0e3          	bgeu	a5,a2,38e <printint+0x2a>
  if(neg)
 3b2:	00088b63          	beqz	a7,3c8 <printint+0x64>
    buf[i++] = '-';
 3b6:	fd040793          	addi	a5,s0,-48
 3ba:	973e                	add	a4,a4,a5
 3bc:	02d00793          	li	a5,45
 3c0:	fef70823          	sb	a5,-16(a4)
 3c4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3c8:	02e05863          	blez	a4,3f8 <printint+0x94>
 3cc:	fc040793          	addi	a5,s0,-64
 3d0:	00e78933          	add	s2,a5,a4
 3d4:	fff78993          	addi	s3,a5,-1
 3d8:	99ba                	add	s3,s3,a4
 3da:	377d                	addiw	a4,a4,-1
 3dc:	1702                	slli	a4,a4,0x20
 3de:	9301                	srli	a4,a4,0x20
 3e0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3e4:	fff94583          	lbu	a1,-1(s2)
 3e8:	8526                	mv	a0,s1
 3ea:	00000097          	auipc	ra,0x0
 3ee:	f58080e7          	jalr	-168(ra) # 342 <putc>
  while(--i >= 0)
 3f2:	197d                	addi	s2,s2,-1
 3f4:	ff3918e3          	bne	s2,s3,3e4 <printint+0x80>
}
 3f8:	70e2                	ld	ra,56(sp)
 3fa:	7442                	ld	s0,48(sp)
 3fc:	74a2                	ld	s1,40(sp)
 3fe:	7902                	ld	s2,32(sp)
 400:	69e2                	ld	s3,24(sp)
 402:	6121                	addi	sp,sp,64
 404:	8082                	ret
    x = -xx;
 406:	40b005bb          	negw	a1,a1
    neg = 1;
 40a:	4885                	li	a7,1
    x = -xx;
 40c:	bf8d                	j	37e <printint+0x1a>

000000000000040e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 40e:	7119                	addi	sp,sp,-128
 410:	fc86                	sd	ra,120(sp)
 412:	f8a2                	sd	s0,112(sp)
 414:	f4a6                	sd	s1,104(sp)
 416:	f0ca                	sd	s2,96(sp)
 418:	ecce                	sd	s3,88(sp)
 41a:	e8d2                	sd	s4,80(sp)
 41c:	e4d6                	sd	s5,72(sp)
 41e:	e0da                	sd	s6,64(sp)
 420:	fc5e                	sd	s7,56(sp)
 422:	f862                	sd	s8,48(sp)
 424:	f466                	sd	s9,40(sp)
 426:	f06a                	sd	s10,32(sp)
 428:	ec6e                	sd	s11,24(sp)
 42a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 42c:	0005c903          	lbu	s2,0(a1)
 430:	18090f63          	beqz	s2,5ce <vprintf+0x1c0>
 434:	8aaa                	mv	s5,a0
 436:	8b32                	mv	s6,a2
 438:	00158493          	addi	s1,a1,1
  state = 0;
 43c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 43e:	02500a13          	li	s4,37
      if(c == 'd'){
 442:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 446:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 44a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 44e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 452:	00000b97          	auipc	s7,0x0
 456:	37eb8b93          	addi	s7,s7,894 # 7d0 <digits>
 45a:	a839                	j	478 <vprintf+0x6a>
        putc(fd, c);
 45c:	85ca                	mv	a1,s2
 45e:	8556                	mv	a0,s5
 460:	00000097          	auipc	ra,0x0
 464:	ee2080e7          	jalr	-286(ra) # 342 <putc>
 468:	a019                	j	46e <vprintf+0x60>
    } else if(state == '%'){
 46a:	01498f63          	beq	s3,s4,488 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 46e:	0485                	addi	s1,s1,1
 470:	fff4c903          	lbu	s2,-1(s1)
 474:	14090d63          	beqz	s2,5ce <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 478:	0009079b          	sext.w	a5,s2
    if(state == 0){
 47c:	fe0997e3          	bnez	s3,46a <vprintf+0x5c>
      if(c == '%'){
 480:	fd479ee3          	bne	a5,s4,45c <vprintf+0x4e>
        state = '%';
 484:	89be                	mv	s3,a5
 486:	b7e5                	j	46e <vprintf+0x60>
      if(c == 'd'){
 488:	05878063          	beq	a5,s8,4c8 <vprintf+0xba>
      } else if(c == 'l') {
 48c:	05978c63          	beq	a5,s9,4e4 <vprintf+0xd6>
      } else if(c == 'x') {
 490:	07a78863          	beq	a5,s10,500 <vprintf+0xf2>
      } else if(c == 'p') {
 494:	09b78463          	beq	a5,s11,51c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 498:	07300713          	li	a4,115
 49c:	0ce78663          	beq	a5,a4,568 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4a0:	06300713          	li	a4,99
 4a4:	0ee78e63          	beq	a5,a4,5a0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4a8:	11478863          	beq	a5,s4,5b8 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4ac:	85d2                	mv	a1,s4
 4ae:	8556                	mv	a0,s5
 4b0:	00000097          	auipc	ra,0x0
 4b4:	e92080e7          	jalr	-366(ra) # 342 <putc>
        putc(fd, c);
 4b8:	85ca                	mv	a1,s2
 4ba:	8556                	mv	a0,s5
 4bc:	00000097          	auipc	ra,0x0
 4c0:	e86080e7          	jalr	-378(ra) # 342 <putc>
      }
      state = 0;
 4c4:	4981                	li	s3,0
 4c6:	b765                	j	46e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4c8:	008b0913          	addi	s2,s6,8
 4cc:	4685                	li	a3,1
 4ce:	4629                	li	a2,10
 4d0:	000b2583          	lw	a1,0(s6)
 4d4:	8556                	mv	a0,s5
 4d6:	00000097          	auipc	ra,0x0
 4da:	e8e080e7          	jalr	-370(ra) # 364 <printint>
 4de:	8b4a                	mv	s6,s2
      state = 0;
 4e0:	4981                	li	s3,0
 4e2:	b771                	j	46e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4e4:	008b0913          	addi	s2,s6,8
 4e8:	4681                	li	a3,0
 4ea:	4629                	li	a2,10
 4ec:	000b2583          	lw	a1,0(s6)
 4f0:	8556                	mv	a0,s5
 4f2:	00000097          	auipc	ra,0x0
 4f6:	e72080e7          	jalr	-398(ra) # 364 <printint>
 4fa:	8b4a                	mv	s6,s2
      state = 0;
 4fc:	4981                	li	s3,0
 4fe:	bf85                	j	46e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 500:	008b0913          	addi	s2,s6,8
 504:	4681                	li	a3,0
 506:	4641                	li	a2,16
 508:	000b2583          	lw	a1,0(s6)
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	e56080e7          	jalr	-426(ra) # 364 <printint>
 516:	8b4a                	mv	s6,s2
      state = 0;
 518:	4981                	li	s3,0
 51a:	bf91                	j	46e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 51c:	008b0793          	addi	a5,s6,8
 520:	f8f43423          	sd	a5,-120(s0)
 524:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 528:	03000593          	li	a1,48
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	e14080e7          	jalr	-492(ra) # 342 <putc>
  putc(fd, 'x');
 536:	85ea                	mv	a1,s10
 538:	8556                	mv	a0,s5
 53a:	00000097          	auipc	ra,0x0
 53e:	e08080e7          	jalr	-504(ra) # 342 <putc>
 542:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 544:	03c9d793          	srli	a5,s3,0x3c
 548:	97de                	add	a5,a5,s7
 54a:	0007c583          	lbu	a1,0(a5)
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	df2080e7          	jalr	-526(ra) # 342 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 558:	0992                	slli	s3,s3,0x4
 55a:	397d                	addiw	s2,s2,-1
 55c:	fe0914e3          	bnez	s2,544 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 560:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 564:	4981                	li	s3,0
 566:	b721                	j	46e <vprintf+0x60>
        s = va_arg(ap, char*);
 568:	008b0993          	addi	s3,s6,8
 56c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 570:	02090163          	beqz	s2,592 <vprintf+0x184>
        while(*s != 0){
 574:	00094583          	lbu	a1,0(s2)
 578:	c9a1                	beqz	a1,5c8 <vprintf+0x1ba>
          putc(fd, *s);
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	dc6080e7          	jalr	-570(ra) # 342 <putc>
          s++;
 584:	0905                	addi	s2,s2,1
        while(*s != 0){
 586:	00094583          	lbu	a1,0(s2)
 58a:	f9e5                	bnez	a1,57a <vprintf+0x16c>
        s = va_arg(ap, char*);
 58c:	8b4e                	mv	s6,s3
      state = 0;
 58e:	4981                	li	s3,0
 590:	bdf9                	j	46e <vprintf+0x60>
          s = "(null)";
 592:	00000917          	auipc	s2,0x0
 596:	23690913          	addi	s2,s2,566 # 7c8 <malloc+0xf0>
        while(*s != 0){
 59a:	02800593          	li	a1,40
 59e:	bff1                	j	57a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5a0:	008b0913          	addi	s2,s6,8
 5a4:	000b4583          	lbu	a1,0(s6)
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	d98080e7          	jalr	-616(ra) # 342 <putc>
 5b2:	8b4a                	mv	s6,s2
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	bd65                	j	46e <vprintf+0x60>
        putc(fd, c);
 5b8:	85d2                	mv	a1,s4
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	d86080e7          	jalr	-634(ra) # 342 <putc>
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b565                	j	46e <vprintf+0x60>
        s = va_arg(ap, char*);
 5c8:	8b4e                	mv	s6,s3
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b54d                	j	46e <vprintf+0x60>
    }
  }
}
 5ce:	70e6                	ld	ra,120(sp)
 5d0:	7446                	ld	s0,112(sp)
 5d2:	74a6                	ld	s1,104(sp)
 5d4:	7906                	ld	s2,96(sp)
 5d6:	69e6                	ld	s3,88(sp)
 5d8:	6a46                	ld	s4,80(sp)
 5da:	6aa6                	ld	s5,72(sp)
 5dc:	6b06                	ld	s6,64(sp)
 5de:	7be2                	ld	s7,56(sp)
 5e0:	7c42                	ld	s8,48(sp)
 5e2:	7ca2                	ld	s9,40(sp)
 5e4:	7d02                	ld	s10,32(sp)
 5e6:	6de2                	ld	s11,24(sp)
 5e8:	6109                	addi	sp,sp,128
 5ea:	8082                	ret

00000000000005ec <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5ec:	715d                	addi	sp,sp,-80
 5ee:	ec06                	sd	ra,24(sp)
 5f0:	e822                	sd	s0,16(sp)
 5f2:	1000                	addi	s0,sp,32
 5f4:	e010                	sd	a2,0(s0)
 5f6:	e414                	sd	a3,8(s0)
 5f8:	e818                	sd	a4,16(s0)
 5fa:	ec1c                	sd	a5,24(s0)
 5fc:	03043023          	sd	a6,32(s0)
 600:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 604:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 608:	8622                	mv	a2,s0
 60a:	00000097          	auipc	ra,0x0
 60e:	e04080e7          	jalr	-508(ra) # 40e <vprintf>
}
 612:	60e2                	ld	ra,24(sp)
 614:	6442                	ld	s0,16(sp)
 616:	6161                	addi	sp,sp,80
 618:	8082                	ret

000000000000061a <printf>:

void
printf(const char *fmt, ...)
{
 61a:	711d                	addi	sp,sp,-96
 61c:	ec06                	sd	ra,24(sp)
 61e:	e822                	sd	s0,16(sp)
 620:	1000                	addi	s0,sp,32
 622:	e40c                	sd	a1,8(s0)
 624:	e810                	sd	a2,16(s0)
 626:	ec14                	sd	a3,24(s0)
 628:	f018                	sd	a4,32(s0)
 62a:	f41c                	sd	a5,40(s0)
 62c:	03043823          	sd	a6,48(s0)
 630:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 634:	00840613          	addi	a2,s0,8
 638:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 63c:	85aa                	mv	a1,a0
 63e:	4505                	li	a0,1
 640:	00000097          	auipc	ra,0x0
 644:	dce080e7          	jalr	-562(ra) # 40e <vprintf>
}
 648:	60e2                	ld	ra,24(sp)
 64a:	6442                	ld	s0,16(sp)
 64c:	6125                	addi	sp,sp,96
 64e:	8082                	ret

0000000000000650 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 650:	1141                	addi	sp,sp,-16
 652:	e422                	sd	s0,8(sp)
 654:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 656:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 65a:	00000797          	auipc	a5,0x0
 65e:	18e7b783          	ld	a5,398(a5) # 7e8 <freep>
 662:	a805                	j	692 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 664:	4618                	lw	a4,8(a2)
 666:	9db9                	addw	a1,a1,a4
 668:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 66c:	6398                	ld	a4,0(a5)
 66e:	6318                	ld	a4,0(a4)
 670:	fee53823          	sd	a4,-16(a0)
 674:	a091                	j	6b8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 676:	ff852703          	lw	a4,-8(a0)
 67a:	9e39                	addw	a2,a2,a4
 67c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 67e:	ff053703          	ld	a4,-16(a0)
 682:	e398                	sd	a4,0(a5)
 684:	a099                	j	6ca <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 686:	6398                	ld	a4,0(a5)
 688:	00e7e463          	bltu	a5,a4,690 <free+0x40>
 68c:	00e6ea63          	bltu	a3,a4,6a0 <free+0x50>
{
 690:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 692:	fed7fae3          	bgeu	a5,a3,686 <free+0x36>
 696:	6398                	ld	a4,0(a5)
 698:	00e6e463          	bltu	a3,a4,6a0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 69c:	fee7eae3          	bltu	a5,a4,690 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6a0:	ff852583          	lw	a1,-8(a0)
 6a4:	6390                	ld	a2,0(a5)
 6a6:	02059713          	slli	a4,a1,0x20
 6aa:	9301                	srli	a4,a4,0x20
 6ac:	0712                	slli	a4,a4,0x4
 6ae:	9736                	add	a4,a4,a3
 6b0:	fae60ae3          	beq	a2,a4,664 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6b4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6b8:	4790                	lw	a2,8(a5)
 6ba:	02061713          	slli	a4,a2,0x20
 6be:	9301                	srli	a4,a4,0x20
 6c0:	0712                	slli	a4,a4,0x4
 6c2:	973e                	add	a4,a4,a5
 6c4:	fae689e3          	beq	a3,a4,676 <free+0x26>
  } else
    p->s.ptr = bp;
 6c8:	e394                	sd	a3,0(a5)
  freep = p;
 6ca:	00000717          	auipc	a4,0x0
 6ce:	10f73f23          	sd	a5,286(a4) # 7e8 <freep>
}
 6d2:	6422                	ld	s0,8(sp)
 6d4:	0141                	addi	sp,sp,16
 6d6:	8082                	ret

00000000000006d8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6d8:	7139                	addi	sp,sp,-64
 6da:	fc06                	sd	ra,56(sp)
 6dc:	f822                	sd	s0,48(sp)
 6de:	f426                	sd	s1,40(sp)
 6e0:	f04a                	sd	s2,32(sp)
 6e2:	ec4e                	sd	s3,24(sp)
 6e4:	e852                	sd	s4,16(sp)
 6e6:	e456                	sd	s5,8(sp)
 6e8:	e05a                	sd	s6,0(sp)
 6ea:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6ec:	02051493          	slli	s1,a0,0x20
 6f0:	9081                	srli	s1,s1,0x20
 6f2:	04bd                	addi	s1,s1,15
 6f4:	8091                	srli	s1,s1,0x4
 6f6:	0014899b          	addiw	s3,s1,1
 6fa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6fc:	00000517          	auipc	a0,0x0
 700:	0ec53503          	ld	a0,236(a0) # 7e8 <freep>
 704:	c515                	beqz	a0,730 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 706:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 708:	4798                	lw	a4,8(a5)
 70a:	02977f63          	bgeu	a4,s1,748 <malloc+0x70>
 70e:	8a4e                	mv	s4,s3
 710:	0009871b          	sext.w	a4,s3
 714:	6685                	lui	a3,0x1
 716:	00d77363          	bgeu	a4,a3,71c <malloc+0x44>
 71a:	6a05                	lui	s4,0x1
 71c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 720:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 724:	00000917          	auipc	s2,0x0
 728:	0c490913          	addi	s2,s2,196 # 7e8 <freep>
  if(p == (char*)-1)
 72c:	5afd                	li	s5,-1
 72e:	a88d                	j	7a0 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 730:	00000797          	auipc	a5,0x0
 734:	0c078793          	addi	a5,a5,192 # 7f0 <base>
 738:	00000717          	auipc	a4,0x0
 73c:	0af73823          	sd	a5,176(a4) # 7e8 <freep>
 740:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 742:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 746:	b7e1                	j	70e <malloc+0x36>
      if(p->s.size == nunits)
 748:	02e48b63          	beq	s1,a4,77e <malloc+0xa6>
        p->s.size -= nunits;
 74c:	4137073b          	subw	a4,a4,s3
 750:	c798                	sw	a4,8(a5)
        p += p->s.size;
 752:	1702                	slli	a4,a4,0x20
 754:	9301                	srli	a4,a4,0x20
 756:	0712                	slli	a4,a4,0x4
 758:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 75a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 75e:	00000717          	auipc	a4,0x0
 762:	08a73523          	sd	a0,138(a4) # 7e8 <freep>
      return (void*)(p + 1);
 766:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 76a:	70e2                	ld	ra,56(sp)
 76c:	7442                	ld	s0,48(sp)
 76e:	74a2                	ld	s1,40(sp)
 770:	7902                	ld	s2,32(sp)
 772:	69e2                	ld	s3,24(sp)
 774:	6a42                	ld	s4,16(sp)
 776:	6aa2                	ld	s5,8(sp)
 778:	6b02                	ld	s6,0(sp)
 77a:	6121                	addi	sp,sp,64
 77c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 77e:	6398                	ld	a4,0(a5)
 780:	e118                	sd	a4,0(a0)
 782:	bff1                	j	75e <malloc+0x86>
  hp->s.size = nu;
 784:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 788:	0541                	addi	a0,a0,16
 78a:	00000097          	auipc	ra,0x0
 78e:	ec6080e7          	jalr	-314(ra) # 650 <free>
  return freep;
 792:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 796:	d971                	beqz	a0,76a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 798:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 79a:	4798                	lw	a4,8(a5)
 79c:	fa9776e3          	bgeu	a4,s1,748 <malloc+0x70>
    if(p == freep)
 7a0:	00093703          	ld	a4,0(s2)
 7a4:	853e                	mv	a0,a5
 7a6:	fef719e3          	bne	a4,a5,798 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7aa:	8552                	mv	a0,s4
 7ac:	00000097          	auipc	ra,0x0
 7b0:	b7e080e7          	jalr	-1154(ra) # 32a <sbrk>
  if(p == (char*)-1)
 7b4:	fd5518e3          	bne	a0,s5,784 <malloc+0xac>
        return 0;
 7b8:	4501                	li	a0,0
 7ba:	bf45                	j	76a <malloc+0x92>
