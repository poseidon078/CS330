
user/_forksleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
   c:	84ae                	mv	s1,a1
    int m=atoi(argv[1]);
   e:	6588                	ld	a0,8(a1)
  10:	00000097          	auipc	ra,0x0
  14:	274080e7          	jalr	628(ra) # 284 <atoi>
  18:	892a                	mv	s2,a0
    int n=atoi(argv[2]);
  1a:	6888                	ld	a0,16(s1)
  1c:	00000097          	auipc	ra,0x0
  20:	268080e7          	jalr	616(ra) # 284 <atoi>
    int x;
    if(m<1){
  24:	03205563          	blez	s2,4e <main+0x4e>
  28:	84aa                	mv	s1,a0
        printf("m should be positive\n");
        exit(1);
    }
    if(n<0 || n>1){
  2a:	0005079b          	sext.w	a5,a0
  2e:	4705                	li	a4,1
  30:	02f77c63          	bgeu	a4,a5,68 <main+0x68>
        printf("n should be 0 or 1\n");
  34:	00001517          	auipc	a0,0x1
  38:	88450513          	addi	a0,a0,-1916 # 8b8 <malloc+0xfe>
  3c:	00000097          	auipc	ra,0x0
  40:	6c0080e7          	jalr	1728(ra) # 6fc <printf>
        exit(2);
  44:	4509                	li	a0,2
  46:	00000097          	auipc	ra,0x0
  4a:	33e080e7          	jalr	830(ra) # 384 <exit>
        printf("m should be positive\n");
  4e:	00001517          	auipc	a0,0x1
  52:	85250513          	addi	a0,a0,-1966 # 8a0 <malloc+0xe6>
  56:	00000097          	auipc	ra,0x0
  5a:	6a6080e7          	jalr	1702(ra) # 6fc <printf>
        exit(1);
  5e:	4505                	li	a0,1
  60:	00000097          	auipc	ra,0x0
  64:	324080e7          	jalr	804(ra) # 384 <exit>
    }
    if(fork()==0){
  68:	00000097          	auipc	ra,0x0
  6c:	314080e7          	jalr	788(ra) # 37c <fork>
  70:	e539                	bnez	a0,be <main+0xbe>
        if(n==0){
  72:	e885                	bnez	s1,a2 <main+0xa2>
            sleep(m);
  74:	854a                	mv	a0,s2
  76:	00000097          	auipc	ra,0x0
  7a:	39e080e7          	jalr	926(ra) # 414 <sleep>
            printf("%d: Child.\n", getpid());
  7e:	00000097          	auipc	ra,0x0
  82:	386080e7          	jalr	902(ra) # 404 <getpid>
  86:	85aa                	mv	a1,a0
  88:	00001517          	auipc	a0,0x1
  8c:	84850513          	addi	a0,a0,-1976 # 8d0 <malloc+0x116>
  90:	00000097          	auipc	ra,0x0
  94:	66c080e7          	jalr	1644(ra) # 6fc <printf>
        else{
            sleep(m);
            printf("%d: Parent.\n", getpid());
        }
    }
  exit(0);
  98:	4501                	li	a0,0
  9a:	00000097          	auipc	ra,0x0
  9e:	2ea080e7          	jalr	746(ra) # 384 <exit>
            printf("%d: Child.\n", getpid());
  a2:	00000097          	auipc	ra,0x0
  a6:	362080e7          	jalr	866(ra) # 404 <getpid>
  aa:	85aa                	mv	a1,a0
  ac:	00001517          	auipc	a0,0x1
  b0:	82450513          	addi	a0,a0,-2012 # 8d0 <malloc+0x116>
  b4:	00000097          	auipc	ra,0x0
  b8:	648080e7          	jalr	1608(ra) # 6fc <printf>
  bc:	bff1                	j	98 <main+0x98>
        if(n==0){
  be:	e48d                	bnez	s1,e8 <main+0xe8>
            printf("%d: Parent.\n", getpid());
  c0:	00000097          	auipc	ra,0x0
  c4:	344080e7          	jalr	836(ra) # 404 <getpid>
  c8:	85aa                	mv	a1,a0
  ca:	00001517          	auipc	a0,0x1
  ce:	81650513          	addi	a0,a0,-2026 # 8e0 <malloc+0x126>
  d2:	00000097          	auipc	ra,0x0
  d6:	62a080e7          	jalr	1578(ra) # 6fc <printf>
            wait(p);
  da:	fdc40513          	addi	a0,s0,-36
  de:	00000097          	auipc	ra,0x0
  e2:	2ae080e7          	jalr	686(ra) # 38c <wait>
  e6:	bf4d                	j	98 <main+0x98>
            sleep(m);
  e8:	854a                	mv	a0,s2
  ea:	00000097          	auipc	ra,0x0
  ee:	32a080e7          	jalr	810(ra) # 414 <sleep>
            printf("%d: Parent.\n", getpid());
  f2:	00000097          	auipc	ra,0x0
  f6:	312080e7          	jalr	786(ra) # 404 <getpid>
  fa:	85aa                	mv	a1,a0
  fc:	00000517          	auipc	a0,0x0
 100:	7e450513          	addi	a0,a0,2020 # 8e0 <malloc+0x126>
 104:	00000097          	auipc	ra,0x0
 108:	5f8080e7          	jalr	1528(ra) # 6fc <printf>
 10c:	b771                	j	98 <main+0x98>

000000000000010e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 10e:	1141                	addi	sp,sp,-16
 110:	e422                	sd	s0,8(sp)
 112:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 114:	87aa                	mv	a5,a0
 116:	0585                	addi	a1,a1,1
 118:	0785                	addi	a5,a5,1
 11a:	fff5c703          	lbu	a4,-1(a1)
 11e:	fee78fa3          	sb	a4,-1(a5)
 122:	fb75                	bnez	a4,116 <strcpy+0x8>
    ;
  return os;
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret

000000000000012a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12a:	1141                	addi	sp,sp,-16
 12c:	e422                	sd	s0,8(sp)
 12e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 130:	00054783          	lbu	a5,0(a0)
 134:	cb91                	beqz	a5,148 <strcmp+0x1e>
 136:	0005c703          	lbu	a4,0(a1)
 13a:	00f71763          	bne	a4,a5,148 <strcmp+0x1e>
    p++, q++;
 13e:	0505                	addi	a0,a0,1
 140:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 142:	00054783          	lbu	a5,0(a0)
 146:	fbe5                	bnez	a5,136 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 148:	0005c503          	lbu	a0,0(a1)
}
 14c:	40a7853b          	subw	a0,a5,a0
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret

0000000000000156 <strlen>:

uint
strlen(const char *s)
{
 156:	1141                	addi	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15c:	00054783          	lbu	a5,0(a0)
 160:	cf91                	beqz	a5,17c <strlen+0x26>
 162:	0505                	addi	a0,a0,1
 164:	87aa                	mv	a5,a0
 166:	4685                	li	a3,1
 168:	9e89                	subw	a3,a3,a0
 16a:	00f6853b          	addw	a0,a3,a5
 16e:	0785                	addi	a5,a5,1
 170:	fff7c703          	lbu	a4,-1(a5)
 174:	fb7d                	bnez	a4,16a <strlen+0x14>
    ;
  return n;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret
  for(n = 0; s[n]; n++)
 17c:	4501                	li	a0,0
 17e:	bfe5                	j	176 <strlen+0x20>

0000000000000180 <memset>:

void*
memset(void *dst, int c, uint n)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 186:	ce09                	beqz	a2,1a0 <memset+0x20>
 188:	87aa                	mv	a5,a0
 18a:	fff6071b          	addiw	a4,a2,-1
 18e:	1702                	slli	a4,a4,0x20
 190:	9301                	srli	a4,a4,0x20
 192:	0705                	addi	a4,a4,1
 194:	972a                	add	a4,a4,a0
    cdst[i] = c;
 196:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19a:	0785                	addi	a5,a5,1
 19c:	fee79de3          	bne	a5,a4,196 <memset+0x16>
  }
  return dst;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strchr>:

char*
strchr(const char *s, char c)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cb99                	beqz	a5,1c6 <strchr+0x20>
    if(*s == c)
 1b2:	00f58763          	beq	a1,a5,1c0 <strchr+0x1a>
  for(; *s; s++)
 1b6:	0505                	addi	a0,a0,1
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbfd                	bnez	a5,1b2 <strchr+0xc>
      return (char*)s;
  return 0;
 1be:	4501                	li	a0,0
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret
  return 0;
 1c6:	4501                	li	a0,0
 1c8:	bfe5                	j	1c0 <strchr+0x1a>

00000000000001ca <gets>:

char*
gets(char *buf, int max)
{
 1ca:	711d                	addi	sp,sp,-96
 1cc:	ec86                	sd	ra,88(sp)
 1ce:	e8a2                	sd	s0,80(sp)
 1d0:	e4a6                	sd	s1,72(sp)
 1d2:	e0ca                	sd	s2,64(sp)
 1d4:	fc4e                	sd	s3,56(sp)
 1d6:	f852                	sd	s4,48(sp)
 1d8:	f456                	sd	s5,40(sp)
 1da:	f05a                	sd	s6,32(sp)
 1dc:	ec5e                	sd	s7,24(sp)
 1de:	1080                	addi	s0,sp,96
 1e0:	8baa                	mv	s7,a0
 1e2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	892a                	mv	s2,a0
 1e6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e8:	4aa9                	li	s5,10
 1ea:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ec:	89a6                	mv	s3,s1
 1ee:	2485                	addiw	s1,s1,1
 1f0:	0344d863          	bge	s1,s4,220 <gets+0x56>
    cc = read(0, &c, 1);
 1f4:	4605                	li	a2,1
 1f6:	faf40593          	addi	a1,s0,-81
 1fa:	4501                	li	a0,0
 1fc:	00000097          	auipc	ra,0x0
 200:	1a0080e7          	jalr	416(ra) # 39c <read>
    if(cc < 1)
 204:	00a05e63          	blez	a0,220 <gets+0x56>
    buf[i++] = c;
 208:	faf44783          	lbu	a5,-81(s0)
 20c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 210:	01578763          	beq	a5,s5,21e <gets+0x54>
 214:	0905                	addi	s2,s2,1
 216:	fd679be3          	bne	a5,s6,1ec <gets+0x22>
  for(i=0; i+1 < max; ){
 21a:	89a6                	mv	s3,s1
 21c:	a011                	j	220 <gets+0x56>
 21e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 220:	99de                	add	s3,s3,s7
 222:	00098023          	sb	zero,0(s3)
  return buf;
}
 226:	855e                	mv	a0,s7
 228:	60e6                	ld	ra,88(sp)
 22a:	6446                	ld	s0,80(sp)
 22c:	64a6                	ld	s1,72(sp)
 22e:	6906                	ld	s2,64(sp)
 230:	79e2                	ld	s3,56(sp)
 232:	7a42                	ld	s4,48(sp)
 234:	7aa2                	ld	s5,40(sp)
 236:	7b02                	ld	s6,32(sp)
 238:	6be2                	ld	s7,24(sp)
 23a:	6125                	addi	sp,sp,96
 23c:	8082                	ret

000000000000023e <stat>:

int
stat(const char *n, struct stat *st)
{
 23e:	1101                	addi	sp,sp,-32
 240:	ec06                	sd	ra,24(sp)
 242:	e822                	sd	s0,16(sp)
 244:	e426                	sd	s1,8(sp)
 246:	e04a                	sd	s2,0(sp)
 248:	1000                	addi	s0,sp,32
 24a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24c:	4581                	li	a1,0
 24e:	00000097          	auipc	ra,0x0
 252:	176080e7          	jalr	374(ra) # 3c4 <open>
  if(fd < 0)
 256:	02054563          	bltz	a0,280 <stat+0x42>
 25a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25c:	85ca                	mv	a1,s2
 25e:	00000097          	auipc	ra,0x0
 262:	17e080e7          	jalr	382(ra) # 3dc <fstat>
 266:	892a                	mv	s2,a0
  close(fd);
 268:	8526                	mv	a0,s1
 26a:	00000097          	auipc	ra,0x0
 26e:	142080e7          	jalr	322(ra) # 3ac <close>
  return r;
}
 272:	854a                	mv	a0,s2
 274:	60e2                	ld	ra,24(sp)
 276:	6442                	ld	s0,16(sp)
 278:	64a2                	ld	s1,8(sp)
 27a:	6902                	ld	s2,0(sp)
 27c:	6105                	addi	sp,sp,32
 27e:	8082                	ret
    return -1;
 280:	597d                	li	s2,-1
 282:	bfc5                	j	272 <stat+0x34>

0000000000000284 <atoi>:

int
atoi(const char *s)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28a:	00054603          	lbu	a2,0(a0)
 28e:	fd06079b          	addiw	a5,a2,-48
 292:	0ff7f793          	andi	a5,a5,255
 296:	4725                	li	a4,9
 298:	02f76963          	bltu	a4,a5,2ca <atoi+0x46>
 29c:	86aa                	mv	a3,a0
  n = 0;
 29e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2a0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2a2:	0685                	addi	a3,a3,1
 2a4:	0025179b          	slliw	a5,a0,0x2
 2a8:	9fa9                	addw	a5,a5,a0
 2aa:	0017979b          	slliw	a5,a5,0x1
 2ae:	9fb1                	addw	a5,a5,a2
 2b0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b4:	0006c603          	lbu	a2,0(a3)
 2b8:	fd06071b          	addiw	a4,a2,-48
 2bc:	0ff77713          	andi	a4,a4,255
 2c0:	fee5f1e3          	bgeu	a1,a4,2a2 <atoi+0x1e>
  return n;
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
  n = 0;
 2ca:	4501                	li	a0,0
 2cc:	bfe5                	j	2c4 <atoi+0x40>

00000000000002ce <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d4:	02b57663          	bgeu	a0,a1,300 <memmove+0x32>
    while(n-- > 0)
 2d8:	02c05163          	blez	a2,2fa <memmove+0x2c>
 2dc:	fff6079b          	addiw	a5,a2,-1
 2e0:	1782                	slli	a5,a5,0x20
 2e2:	9381                	srli	a5,a5,0x20
 2e4:	0785                	addi	a5,a5,1
 2e6:	97aa                	add	a5,a5,a0
  dst = vdst;
 2e8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ea:	0585                	addi	a1,a1,1
 2ec:	0705                	addi	a4,a4,1
 2ee:	fff5c683          	lbu	a3,-1(a1)
 2f2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f6:	fee79ae3          	bne	a5,a4,2ea <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fa:	6422                	ld	s0,8(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret
    dst += n;
 300:	00c50733          	add	a4,a0,a2
    src += n;
 304:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 306:	fec05ae3          	blez	a2,2fa <memmove+0x2c>
 30a:	fff6079b          	addiw	a5,a2,-1
 30e:	1782                	slli	a5,a5,0x20
 310:	9381                	srli	a5,a5,0x20
 312:	fff7c793          	not	a5,a5
 316:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 318:	15fd                	addi	a1,a1,-1
 31a:	177d                	addi	a4,a4,-1
 31c:	0005c683          	lbu	a3,0(a1)
 320:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 324:	fee79ae3          	bne	a5,a4,318 <memmove+0x4a>
 328:	bfc9                	j	2fa <memmove+0x2c>

000000000000032a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 330:	ca05                	beqz	a2,360 <memcmp+0x36>
 332:	fff6069b          	addiw	a3,a2,-1
 336:	1682                	slli	a3,a3,0x20
 338:	9281                	srli	a3,a3,0x20
 33a:	0685                	addi	a3,a3,1
 33c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 33e:	00054783          	lbu	a5,0(a0)
 342:	0005c703          	lbu	a4,0(a1)
 346:	00e79863          	bne	a5,a4,356 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 34a:	0505                	addi	a0,a0,1
    p2++;
 34c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 34e:	fed518e3          	bne	a0,a3,33e <memcmp+0x14>
  }
  return 0;
 352:	4501                	li	a0,0
 354:	a019                	j	35a <memcmp+0x30>
      return *p1 - *p2;
 356:	40e7853b          	subw	a0,a5,a4
}
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
  return 0;
 360:	4501                	li	a0,0
 362:	bfe5                	j	35a <memcmp+0x30>

0000000000000364 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 364:	1141                	addi	sp,sp,-16
 366:	e406                	sd	ra,8(sp)
 368:	e022                	sd	s0,0(sp)
 36a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 36c:	00000097          	auipc	ra,0x0
 370:	f62080e7          	jalr	-158(ra) # 2ce <memmove>
}
 374:	60a2                	ld	ra,8(sp)
 376:	6402                	ld	s0,0(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret

000000000000037c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 37c:	4885                	li	a7,1
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <exit>:
.global exit
exit:
 li a7, SYS_exit
 384:	4889                	li	a7,2
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <wait>:
.global wait
wait:
 li a7, SYS_wait
 38c:	488d                	li	a7,3
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 394:	4891                	li	a7,4
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <read>:
.global read
read:
 li a7, SYS_read
 39c:	4895                	li	a7,5
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <write>:
.global write
write:
 li a7, SYS_write
 3a4:	48c1                	li	a7,16
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <close>:
.global close
close:
 li a7, SYS_close
 3ac:	48d5                	li	a7,21
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b4:	4899                	li	a7,6
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3bc:	489d                	li	a7,7
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <open>:
.global open
open:
 li a7, SYS_open
 3c4:	48bd                	li	a7,15
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3cc:	48c5                	li	a7,17
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d4:	48c9                	li	a7,18
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3dc:	48a1                	li	a7,8
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <link>:
.global link
link:
 li a7, SYS_link
 3e4:	48cd                	li	a7,19
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ec:	48d1                	li	a7,20
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f4:	48a5                	li	a7,9
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3fc:	48a9                	li	a7,10
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 404:	48ad                	li	a7,11
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 40c:	48b1                	li	a7,12
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 414:	48b5                	li	a7,13
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 41c:	48b9                	li	a7,14
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 424:	1101                	addi	sp,sp,-32
 426:	ec06                	sd	ra,24(sp)
 428:	e822                	sd	s0,16(sp)
 42a:	1000                	addi	s0,sp,32
 42c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 430:	4605                	li	a2,1
 432:	fef40593          	addi	a1,s0,-17
 436:	00000097          	auipc	ra,0x0
 43a:	f6e080e7          	jalr	-146(ra) # 3a4 <write>
}
 43e:	60e2                	ld	ra,24(sp)
 440:	6442                	ld	s0,16(sp)
 442:	6105                	addi	sp,sp,32
 444:	8082                	ret

0000000000000446 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 446:	7139                	addi	sp,sp,-64
 448:	fc06                	sd	ra,56(sp)
 44a:	f822                	sd	s0,48(sp)
 44c:	f426                	sd	s1,40(sp)
 44e:	f04a                	sd	s2,32(sp)
 450:	ec4e                	sd	s3,24(sp)
 452:	0080                	addi	s0,sp,64
 454:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 456:	c299                	beqz	a3,45c <printint+0x16>
 458:	0805c863          	bltz	a1,4e8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 45c:	2581                	sext.w	a1,a1
  neg = 0;
 45e:	4881                	li	a7,0
 460:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 464:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 466:	2601                	sext.w	a2,a2
 468:	00000517          	auipc	a0,0x0
 46c:	49050513          	addi	a0,a0,1168 # 8f8 <digits>
 470:	883a                	mv	a6,a4
 472:	2705                	addiw	a4,a4,1
 474:	02c5f7bb          	remuw	a5,a1,a2
 478:	1782                	slli	a5,a5,0x20
 47a:	9381                	srli	a5,a5,0x20
 47c:	97aa                	add	a5,a5,a0
 47e:	0007c783          	lbu	a5,0(a5)
 482:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 486:	0005879b          	sext.w	a5,a1
 48a:	02c5d5bb          	divuw	a1,a1,a2
 48e:	0685                	addi	a3,a3,1
 490:	fec7f0e3          	bgeu	a5,a2,470 <printint+0x2a>
  if(neg)
 494:	00088b63          	beqz	a7,4aa <printint+0x64>
    buf[i++] = '-';
 498:	fd040793          	addi	a5,s0,-48
 49c:	973e                	add	a4,a4,a5
 49e:	02d00793          	li	a5,45
 4a2:	fef70823          	sb	a5,-16(a4)
 4a6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4aa:	02e05863          	blez	a4,4da <printint+0x94>
 4ae:	fc040793          	addi	a5,s0,-64
 4b2:	00e78933          	add	s2,a5,a4
 4b6:	fff78993          	addi	s3,a5,-1
 4ba:	99ba                	add	s3,s3,a4
 4bc:	377d                	addiw	a4,a4,-1
 4be:	1702                	slli	a4,a4,0x20
 4c0:	9301                	srli	a4,a4,0x20
 4c2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4c6:	fff94583          	lbu	a1,-1(s2)
 4ca:	8526                	mv	a0,s1
 4cc:	00000097          	auipc	ra,0x0
 4d0:	f58080e7          	jalr	-168(ra) # 424 <putc>
  while(--i >= 0)
 4d4:	197d                	addi	s2,s2,-1
 4d6:	ff3918e3          	bne	s2,s3,4c6 <printint+0x80>
}
 4da:	70e2                	ld	ra,56(sp)
 4dc:	7442                	ld	s0,48(sp)
 4de:	74a2                	ld	s1,40(sp)
 4e0:	7902                	ld	s2,32(sp)
 4e2:	69e2                	ld	s3,24(sp)
 4e4:	6121                	addi	sp,sp,64
 4e6:	8082                	ret
    x = -xx;
 4e8:	40b005bb          	negw	a1,a1
    neg = 1;
 4ec:	4885                	li	a7,1
    x = -xx;
 4ee:	bf8d                	j	460 <printint+0x1a>

00000000000004f0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f0:	7119                	addi	sp,sp,-128
 4f2:	fc86                	sd	ra,120(sp)
 4f4:	f8a2                	sd	s0,112(sp)
 4f6:	f4a6                	sd	s1,104(sp)
 4f8:	f0ca                	sd	s2,96(sp)
 4fa:	ecce                	sd	s3,88(sp)
 4fc:	e8d2                	sd	s4,80(sp)
 4fe:	e4d6                	sd	s5,72(sp)
 500:	e0da                	sd	s6,64(sp)
 502:	fc5e                	sd	s7,56(sp)
 504:	f862                	sd	s8,48(sp)
 506:	f466                	sd	s9,40(sp)
 508:	f06a                	sd	s10,32(sp)
 50a:	ec6e                	sd	s11,24(sp)
 50c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 50e:	0005c903          	lbu	s2,0(a1)
 512:	18090f63          	beqz	s2,6b0 <vprintf+0x1c0>
 516:	8aaa                	mv	s5,a0
 518:	8b32                	mv	s6,a2
 51a:	00158493          	addi	s1,a1,1
  state = 0;
 51e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 520:	02500a13          	li	s4,37
      if(c == 'd'){
 524:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 528:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 52c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 530:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 534:	00000b97          	auipc	s7,0x0
 538:	3c4b8b93          	addi	s7,s7,964 # 8f8 <digits>
 53c:	a839                	j	55a <vprintf+0x6a>
        putc(fd, c);
 53e:	85ca                	mv	a1,s2
 540:	8556                	mv	a0,s5
 542:	00000097          	auipc	ra,0x0
 546:	ee2080e7          	jalr	-286(ra) # 424 <putc>
 54a:	a019                	j	550 <vprintf+0x60>
    } else if(state == '%'){
 54c:	01498f63          	beq	s3,s4,56a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 550:	0485                	addi	s1,s1,1
 552:	fff4c903          	lbu	s2,-1(s1)
 556:	14090d63          	beqz	s2,6b0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 55a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 55e:	fe0997e3          	bnez	s3,54c <vprintf+0x5c>
      if(c == '%'){
 562:	fd479ee3          	bne	a5,s4,53e <vprintf+0x4e>
        state = '%';
 566:	89be                	mv	s3,a5
 568:	b7e5                	j	550 <vprintf+0x60>
      if(c == 'd'){
 56a:	05878063          	beq	a5,s8,5aa <vprintf+0xba>
      } else if(c == 'l') {
 56e:	05978c63          	beq	a5,s9,5c6 <vprintf+0xd6>
      } else if(c == 'x') {
 572:	07a78863          	beq	a5,s10,5e2 <vprintf+0xf2>
      } else if(c == 'p') {
 576:	09b78463          	beq	a5,s11,5fe <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 57a:	07300713          	li	a4,115
 57e:	0ce78663          	beq	a5,a4,64a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 582:	06300713          	li	a4,99
 586:	0ee78e63          	beq	a5,a4,682 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 58a:	11478863          	beq	a5,s4,69a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 58e:	85d2                	mv	a1,s4
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	e92080e7          	jalr	-366(ra) # 424 <putc>
        putc(fd, c);
 59a:	85ca                	mv	a1,s2
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	e86080e7          	jalr	-378(ra) # 424 <putc>
      }
      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	b765                	j	550 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5aa:	008b0913          	addi	s2,s6,8
 5ae:	4685                	li	a3,1
 5b0:	4629                	li	a2,10
 5b2:	000b2583          	lw	a1,0(s6)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	e8e080e7          	jalr	-370(ra) # 446 <printint>
 5c0:	8b4a                	mv	s6,s2
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	b771                	j	550 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c6:	008b0913          	addi	s2,s6,8
 5ca:	4681                	li	a3,0
 5cc:	4629                	li	a2,10
 5ce:	000b2583          	lw	a1,0(s6)
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	e72080e7          	jalr	-398(ra) # 446 <printint>
 5dc:	8b4a                	mv	s6,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bf85                	j	550 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5e2:	008b0913          	addi	s2,s6,8
 5e6:	4681                	li	a3,0
 5e8:	4641                	li	a2,16
 5ea:	000b2583          	lw	a1,0(s6)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	e56080e7          	jalr	-426(ra) # 446 <printint>
 5f8:	8b4a                	mv	s6,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	bf91                	j	550 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5fe:	008b0793          	addi	a5,s6,8
 602:	f8f43423          	sd	a5,-120(s0)
 606:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 60a:	03000593          	li	a1,48
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e14080e7          	jalr	-492(ra) # 424 <putc>
  putc(fd, 'x');
 618:	85ea                	mv	a1,s10
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e08080e7          	jalr	-504(ra) # 424 <putc>
 624:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 626:	03c9d793          	srli	a5,s3,0x3c
 62a:	97de                	add	a5,a5,s7
 62c:	0007c583          	lbu	a1,0(a5)
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	df2080e7          	jalr	-526(ra) # 424 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 63a:	0992                	slli	s3,s3,0x4
 63c:	397d                	addiw	s2,s2,-1
 63e:	fe0914e3          	bnez	s2,626 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 642:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 646:	4981                	li	s3,0
 648:	b721                	j	550 <vprintf+0x60>
        s = va_arg(ap, char*);
 64a:	008b0993          	addi	s3,s6,8
 64e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 652:	02090163          	beqz	s2,674 <vprintf+0x184>
        while(*s != 0){
 656:	00094583          	lbu	a1,0(s2)
 65a:	c9a1                	beqz	a1,6aa <vprintf+0x1ba>
          putc(fd, *s);
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	dc6080e7          	jalr	-570(ra) # 424 <putc>
          s++;
 666:	0905                	addi	s2,s2,1
        while(*s != 0){
 668:	00094583          	lbu	a1,0(s2)
 66c:	f9e5                	bnez	a1,65c <vprintf+0x16c>
        s = va_arg(ap, char*);
 66e:	8b4e                	mv	s6,s3
      state = 0;
 670:	4981                	li	s3,0
 672:	bdf9                	j	550 <vprintf+0x60>
          s = "(null)";
 674:	00000917          	auipc	s2,0x0
 678:	27c90913          	addi	s2,s2,636 # 8f0 <malloc+0x136>
        while(*s != 0){
 67c:	02800593          	li	a1,40
 680:	bff1                	j	65c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 682:	008b0913          	addi	s2,s6,8
 686:	000b4583          	lbu	a1,0(s6)
 68a:	8556                	mv	a0,s5
 68c:	00000097          	auipc	ra,0x0
 690:	d98080e7          	jalr	-616(ra) # 424 <putc>
 694:	8b4a                	mv	s6,s2
      state = 0;
 696:	4981                	li	s3,0
 698:	bd65                	j	550 <vprintf+0x60>
        putc(fd, c);
 69a:	85d2                	mv	a1,s4
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	d86080e7          	jalr	-634(ra) # 424 <putc>
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b565                	j	550 <vprintf+0x60>
        s = va_arg(ap, char*);
 6aa:	8b4e                	mv	s6,s3
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b54d                	j	550 <vprintf+0x60>
    }
  }
}
 6b0:	70e6                	ld	ra,120(sp)
 6b2:	7446                	ld	s0,112(sp)
 6b4:	74a6                	ld	s1,104(sp)
 6b6:	7906                	ld	s2,96(sp)
 6b8:	69e6                	ld	s3,88(sp)
 6ba:	6a46                	ld	s4,80(sp)
 6bc:	6aa6                	ld	s5,72(sp)
 6be:	6b06                	ld	s6,64(sp)
 6c0:	7be2                	ld	s7,56(sp)
 6c2:	7c42                	ld	s8,48(sp)
 6c4:	7ca2                	ld	s9,40(sp)
 6c6:	7d02                	ld	s10,32(sp)
 6c8:	6de2                	ld	s11,24(sp)
 6ca:	6109                	addi	sp,sp,128
 6cc:	8082                	ret

00000000000006ce <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ce:	715d                	addi	sp,sp,-80
 6d0:	ec06                	sd	ra,24(sp)
 6d2:	e822                	sd	s0,16(sp)
 6d4:	1000                	addi	s0,sp,32
 6d6:	e010                	sd	a2,0(s0)
 6d8:	e414                	sd	a3,8(s0)
 6da:	e818                	sd	a4,16(s0)
 6dc:	ec1c                	sd	a5,24(s0)
 6de:	03043023          	sd	a6,32(s0)
 6e2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6e6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ea:	8622                	mv	a2,s0
 6ec:	00000097          	auipc	ra,0x0
 6f0:	e04080e7          	jalr	-508(ra) # 4f0 <vprintf>
}
 6f4:	60e2                	ld	ra,24(sp)
 6f6:	6442                	ld	s0,16(sp)
 6f8:	6161                	addi	sp,sp,80
 6fa:	8082                	ret

00000000000006fc <printf>:

void
printf(const char *fmt, ...)
{
 6fc:	711d                	addi	sp,sp,-96
 6fe:	ec06                	sd	ra,24(sp)
 700:	e822                	sd	s0,16(sp)
 702:	1000                	addi	s0,sp,32
 704:	e40c                	sd	a1,8(s0)
 706:	e810                	sd	a2,16(s0)
 708:	ec14                	sd	a3,24(s0)
 70a:	f018                	sd	a4,32(s0)
 70c:	f41c                	sd	a5,40(s0)
 70e:	03043823          	sd	a6,48(s0)
 712:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 716:	00840613          	addi	a2,s0,8
 71a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 71e:	85aa                	mv	a1,a0
 720:	4505                	li	a0,1
 722:	00000097          	auipc	ra,0x0
 726:	dce080e7          	jalr	-562(ra) # 4f0 <vprintf>
}
 72a:	60e2                	ld	ra,24(sp)
 72c:	6442                	ld	s0,16(sp)
 72e:	6125                	addi	sp,sp,96
 730:	8082                	ret

0000000000000732 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 732:	1141                	addi	sp,sp,-16
 734:	e422                	sd	s0,8(sp)
 736:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 738:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73c:	00000797          	auipc	a5,0x0
 740:	1d47b783          	ld	a5,468(a5) # 910 <freep>
 744:	a805                	j	774 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 746:	4618                	lw	a4,8(a2)
 748:	9db9                	addw	a1,a1,a4
 74a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 74e:	6398                	ld	a4,0(a5)
 750:	6318                	ld	a4,0(a4)
 752:	fee53823          	sd	a4,-16(a0)
 756:	a091                	j	79a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 758:	ff852703          	lw	a4,-8(a0)
 75c:	9e39                	addw	a2,a2,a4
 75e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 760:	ff053703          	ld	a4,-16(a0)
 764:	e398                	sd	a4,0(a5)
 766:	a099                	j	7ac <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 768:	6398                	ld	a4,0(a5)
 76a:	00e7e463          	bltu	a5,a4,772 <free+0x40>
 76e:	00e6ea63          	bltu	a3,a4,782 <free+0x50>
{
 772:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 774:	fed7fae3          	bgeu	a5,a3,768 <free+0x36>
 778:	6398                	ld	a4,0(a5)
 77a:	00e6e463          	bltu	a3,a4,782 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77e:	fee7eae3          	bltu	a5,a4,772 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 782:	ff852583          	lw	a1,-8(a0)
 786:	6390                	ld	a2,0(a5)
 788:	02059713          	slli	a4,a1,0x20
 78c:	9301                	srli	a4,a4,0x20
 78e:	0712                	slli	a4,a4,0x4
 790:	9736                	add	a4,a4,a3
 792:	fae60ae3          	beq	a2,a4,746 <free+0x14>
    bp->s.ptr = p->s.ptr;
 796:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 79a:	4790                	lw	a2,8(a5)
 79c:	02061713          	slli	a4,a2,0x20
 7a0:	9301                	srli	a4,a4,0x20
 7a2:	0712                	slli	a4,a4,0x4
 7a4:	973e                	add	a4,a4,a5
 7a6:	fae689e3          	beq	a3,a4,758 <free+0x26>
  } else
    p->s.ptr = bp;
 7aa:	e394                	sd	a3,0(a5)
  freep = p;
 7ac:	00000717          	auipc	a4,0x0
 7b0:	16f73223          	sd	a5,356(a4) # 910 <freep>
}
 7b4:	6422                	ld	s0,8(sp)
 7b6:	0141                	addi	sp,sp,16
 7b8:	8082                	ret

00000000000007ba <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ba:	7139                	addi	sp,sp,-64
 7bc:	fc06                	sd	ra,56(sp)
 7be:	f822                	sd	s0,48(sp)
 7c0:	f426                	sd	s1,40(sp)
 7c2:	f04a                	sd	s2,32(sp)
 7c4:	ec4e                	sd	s3,24(sp)
 7c6:	e852                	sd	s4,16(sp)
 7c8:	e456                	sd	s5,8(sp)
 7ca:	e05a                	sd	s6,0(sp)
 7cc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ce:	02051493          	slli	s1,a0,0x20
 7d2:	9081                	srli	s1,s1,0x20
 7d4:	04bd                	addi	s1,s1,15
 7d6:	8091                	srli	s1,s1,0x4
 7d8:	0014899b          	addiw	s3,s1,1
 7dc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7de:	00000517          	auipc	a0,0x0
 7e2:	13253503          	ld	a0,306(a0) # 910 <freep>
 7e6:	c515                	beqz	a0,812 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ea:	4798                	lw	a4,8(a5)
 7ec:	02977f63          	bgeu	a4,s1,82a <malloc+0x70>
 7f0:	8a4e                	mv	s4,s3
 7f2:	0009871b          	sext.w	a4,s3
 7f6:	6685                	lui	a3,0x1
 7f8:	00d77363          	bgeu	a4,a3,7fe <malloc+0x44>
 7fc:	6a05                	lui	s4,0x1
 7fe:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 802:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 806:	00000917          	auipc	s2,0x0
 80a:	10a90913          	addi	s2,s2,266 # 910 <freep>
  if(p == (char*)-1)
 80e:	5afd                	li	s5,-1
 810:	a88d                	j	882 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 812:	00000797          	auipc	a5,0x0
 816:	10678793          	addi	a5,a5,262 # 918 <base>
 81a:	00000717          	auipc	a4,0x0
 81e:	0ef73b23          	sd	a5,246(a4) # 910 <freep>
 822:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 824:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 828:	b7e1                	j	7f0 <malloc+0x36>
      if(p->s.size == nunits)
 82a:	02e48b63          	beq	s1,a4,860 <malloc+0xa6>
        p->s.size -= nunits;
 82e:	4137073b          	subw	a4,a4,s3
 832:	c798                	sw	a4,8(a5)
        p += p->s.size;
 834:	1702                	slli	a4,a4,0x20
 836:	9301                	srli	a4,a4,0x20
 838:	0712                	slli	a4,a4,0x4
 83a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 83c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 840:	00000717          	auipc	a4,0x0
 844:	0ca73823          	sd	a0,208(a4) # 910 <freep>
      return (void*)(p + 1);
 848:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 84c:	70e2                	ld	ra,56(sp)
 84e:	7442                	ld	s0,48(sp)
 850:	74a2                	ld	s1,40(sp)
 852:	7902                	ld	s2,32(sp)
 854:	69e2                	ld	s3,24(sp)
 856:	6a42                	ld	s4,16(sp)
 858:	6aa2                	ld	s5,8(sp)
 85a:	6b02                	ld	s6,0(sp)
 85c:	6121                	addi	sp,sp,64
 85e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 860:	6398                	ld	a4,0(a5)
 862:	e118                	sd	a4,0(a0)
 864:	bff1                	j	840 <malloc+0x86>
  hp->s.size = nu;
 866:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 86a:	0541                	addi	a0,a0,16
 86c:	00000097          	auipc	ra,0x0
 870:	ec6080e7          	jalr	-314(ra) # 732 <free>
  return freep;
 874:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 878:	d971                	beqz	a0,84c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87c:	4798                	lw	a4,8(a5)
 87e:	fa9776e3          	bgeu	a4,s1,82a <malloc+0x70>
    if(p == freep)
 882:	00093703          	ld	a4,0(s2)
 886:	853e                	mv	a0,a5
 888:	fef719e3          	bne	a4,a5,87a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 88c:	8552                	mv	a0,s4
 88e:	00000097          	auipc	ra,0x0
 892:	b7e080e7          	jalr	-1154(ra) # 40c <sbrk>
  if(p == (char*)-1)
 896:	fd5518e3          	bne	a0,s5,866 <malloc+0xac>
        return 0;
 89a:	4501                	li	a0,0
 89c:	bf45                	j	84c <malloc+0x92>
