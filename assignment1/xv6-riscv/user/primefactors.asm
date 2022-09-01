
user/_primefactors:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <pipelining>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void pipelining(int i, int *primes, int *pipefd){
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	0880                	addi	s0,sp,80
  12:	89aa                	mv	s3,a0
  14:	8a2e                	mv	s4,a1
  16:	8ab2                	mv	s5,a2
    if(fork()==0){
  18:	00000097          	auipc	ra,0x0
  1c:	514080e7          	jalr	1300(ra) # 52c <fork>
  20:	12051063          	bnez	a0,140 <pipelining+0x140>
        int n;
        if (read(pipefd[0], &n, 4) < 0) {
  24:	4611                	li	a2,4
  26:	fb440593          	addi	a1,s0,-76
  2a:	000aa503          	lw	a0,0(s5)
  2e:	00000097          	auipc	ra,0x0
  32:	51e080e7          	jalr	1310(ra) # 54c <read>
  36:	0a054963          	bltz	a0,e8 <pipelining+0xe8>
			exit(0);
		}
        else{
            
            int pipefd1[2];
            if (pipe(pipefd1) < 0) {
  3a:	fb840513          	addi	a0,s0,-72
  3e:	00000097          	auipc	ra,0x0
  42:	506080e7          	jalr	1286(ra) # 544 <pipe>
  46:	0a054e63          	bltz	a0,102 <pipelining+0x102>
                exit(0);
            }            
            
            // while(n%primes[i]!=0)
            // i++;
            int x=primes[i];
  4a:	00299793          	slli	a5,s3,0x2
  4e:	97d2                	add	a5,a5,s4
  50:	4384                	lw	s1,0(a5)
            int flag=0;
            while(n%x==0){
  52:	fb442783          	lw	a5,-76(s0)
  56:	0297e73b          	remw	a4,a5,s1
  5a:	e329                	bnez	a4,9c <pipelining+0x9c>
                n=n/x;
                printf("%d, ", x);
  5c:	00001917          	auipc	s2,0x1
  60:	a6490913          	addi	s2,s2,-1436 # ac0 <malloc+0x136>
                n=n/x;
  64:	0297c7bb          	divw	a5,a5,s1
  68:	faf42a23          	sw	a5,-76(s0)
                printf("%d, ", x);
  6c:	85a6                	mv	a1,s1
  6e:	854a                	mv	a0,s2
  70:	00001097          	auipc	ra,0x1
  74:	85c080e7          	jalr	-1956(ra) # 8cc <printf>
            while(n%x==0){
  78:	fb442783          	lw	a5,-76(s0)
  7c:	0297e73b          	remw	a4,a5,s1
  80:	d375                	beqz	a4,64 <pipelining+0x64>
                flag=1;
            }
            if(flag)
            printf("[%d]\n", getpid());
  82:	00000097          	auipc	ra,0x0
  86:	532080e7          	jalr	1330(ra) # 5b4 <getpid>
  8a:	85aa                	mv	a1,a0
  8c:	00001517          	auipc	a0,0x1
  90:	a6450513          	addi	a0,a0,-1436 # af0 <malloc+0x166>
  94:	00001097          	auipc	ra,0x1
  98:	838080e7          	jalr	-1992(ra) # 8cc <printf>
            if(n==1){
  9c:	fb442703          	lw	a4,-76(s0)
  a0:	4785                	li	a5,1
  a2:	06f70d63          	beq	a4,a5,11c <pipelining+0x11c>
                exit(0);
            }
            if (write(pipefd1[1], &n, 4) < 0) {
  a6:	4611                	li	a2,4
  a8:	fb440593          	addi	a1,s0,-76
  ac:	fbc42503          	lw	a0,-68(s0)
  b0:	00000097          	auipc	ra,0x0
  b4:	4a4080e7          	jalr	1188(ra) # 554 <write>
  b8:	06054763          	bltz	a0,126 <pipelining+0x126>
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                close(pipefd[0]);
  bc:	000aa503          	lw	a0,0(s5)
  c0:	00000097          	auipc	ra,0x0
  c4:	49c080e7          	jalr	1180(ra) # 55c <close>
                close(pipefd1[1]);
  c8:	fbc42503          	lw	a0,-68(s0)
  cc:	00000097          	auipc	ra,0x0
  d0:	490080e7          	jalr	1168(ra) # 55c <close>
                pipelining(i+1,primes,pipefd1);
  d4:	fb840613          	addi	a2,s0,-72
  d8:	85d2                	mv	a1,s4
  da:	0019851b          	addiw	a0,s3,1
  de:	00000097          	auipc	ra,0x0
  e2:	f22080e7          	jalr	-222(ra) # 0 <pipelining>
  e6:	a0b5                	j	152 <pipelining+0x152>
			printf("Error: cannot read. Aborting...\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	98850513          	addi	a0,a0,-1656 # a70 <malloc+0xe6>
  f0:	00000097          	auipc	ra,0x0
  f4:	7dc080e7          	jalr	2012(ra) # 8cc <printf>
			exit(0);
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	43a080e7          	jalr	1082(ra) # 534 <exit>
                printf("Error: cannot create pipe. Aborting...\n");
 102:	00001517          	auipc	a0,0x1
 106:	99650513          	addi	a0,a0,-1642 # a98 <malloc+0x10e>
 10a:	00000097          	auipc	ra,0x0
 10e:	7c2080e7          	jalr	1986(ra) # 8cc <printf>
                exit(0);
 112:	4501                	li	a0,0
 114:	00000097          	auipc	ra,0x0
 118:	420080e7          	jalr	1056(ra) # 534 <exit>
                exit(0);
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	416080e7          	jalr	1046(ra) # 534 <exit>
                printf("Error: cannot write. Aborting...\n");
 126:	00001517          	auipc	a0,0x1
 12a:	9a250513          	addi	a0,a0,-1630 # ac8 <malloc+0x13e>
 12e:	00000097          	auipc	ra,0x0
 132:	79e080e7          	jalr	1950(ra) # 8cc <printf>
                exit(0);
 136:	4501                	li	a0,0
 138:	00000097          	auipc	ra,0x0
 13c:	3fc080e7          	jalr	1020(ra) # 534 <exit>
            }
        }
    
    }
    else{
        int a=5;
 140:	4795                	li	a5,5
 142:	faf42c23          	sw	a5,-72(s0)
        int *p=&a;
        wait(p);
 146:	fb840513          	addi	a0,s0,-72
 14a:	00000097          	auipc	ra,0x0
 14e:	3f2080e7          	jalr	1010(ra) # 53c <wait>
    }
}
 152:	60a6                	ld	ra,72(sp)
 154:	6406                	ld	s0,64(sp)
 156:	74e2                	ld	s1,56(sp)
 158:	7942                	ld	s2,48(sp)
 15a:	79a2                	ld	s3,40(sp)
 15c:	7a02                	ld	s4,32(sp)
 15e:	6ae2                	ld	s5,24(sp)
 160:	6161                	addi	sp,sp,80
 162:	8082                	ret

0000000000000164 <main>:

int
main(int argc, char **argv)
{
 164:	7175                	addi	sp,sp,-144
 166:	e506                	sd	ra,136(sp)
 168:	e122                	sd	s0,128(sp)
 16a:	fca6                	sd	s1,120(sp)
 16c:	f8ca                	sd	s2,112(sp)
 16e:	0900                	addi	s0,sp,144
    int n=atoi(argv[1]);
 170:	6588                	ld	a0,8(a1)
 172:	00000097          	auipc	ra,0x0
 176:	2c2080e7          	jalr	706(ra) # 434 <atoi>
 17a:	fca42e23          	sw	a0,-36(s0)
    int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};
 17e:	00001797          	auipc	a5,0x1
 182:	99278793          	addi	a5,a5,-1646 # b10 <malloc+0x186>
 186:	f7840713          	addi	a4,s0,-136
 18a:	00001897          	auipc	a7,0x1
 18e:	9e688893          	addi	a7,a7,-1562 # b70 <malloc+0x1e6>
 192:	0007b803          	ld	a6,0(a5)
 196:	678c                	ld	a1,8(a5)
 198:	6b90                	ld	a2,16(a5)
 19a:	6f94                	ld	a3,24(a5)
 19c:	01073023          	sd	a6,0(a4)
 1a0:	e70c                	sd	a1,8(a4)
 1a2:	eb10                	sd	a2,16(a4)
 1a4:	ef14                	sd	a3,24(a4)
 1a6:	02078793          	addi	a5,a5,32
 1aa:	02070713          	addi	a4,a4,32
 1ae:	ff1792e3          	bne	a5,a7,192 <main+0x2e>
 1b2:	439c                	lw	a5,0(a5)
 1b4:	c31c                	sw	a5,0(a4)
    int x=primes[0];
    int pipefd[2];
    if(n<2 || n>100){
 1b6:	3579                	addiw	a0,a0,-2
 1b8:	06200793          	li	a5,98
 1bc:	00a7ff63          	bgeu	a5,a0,1da <main+0x76>
        printf("n should be positive\n");
 1c0:	00001517          	auipc	a0,0x1
 1c4:	93850513          	addi	a0,a0,-1736 # af8 <malloc+0x16e>
 1c8:	00000097          	auipc	ra,0x0
 1cc:	704080e7          	jalr	1796(ra) # 8cc <printf>
        exit(1);
 1d0:	4505                	li	a0,1
 1d2:	00000097          	auipc	ra,0x0
 1d6:	362080e7          	jalr	866(ra) # 534 <exit>
    }
    if (pipe(pipefd) < 0) {
 1da:	f7040513          	addi	a0,s0,-144
 1de:	00000097          	auipc	ra,0x0
 1e2:	366080e7          	jalr	870(ra) # 544 <pipe>
 1e6:	08054d63          	bltz	a0,280 <main+0x11c>
    if(1){
            int i=0;
            // while(n%primes[i]!=0)
            // i++;
            int flag=0;
            x=primes[i];
 1ea:	f7842483          	lw	s1,-136(s0)
            while(n%x==0){
 1ee:	fdc42783          	lw	a5,-36(s0)
 1f2:	0297e73b          	remw	a4,a5,s1
 1f6:	e329                	bnez	a4,238 <main+0xd4>
                n=n/x;
                printf("%d, ", x);
 1f8:	00001917          	auipc	s2,0x1
 1fc:	8c890913          	addi	s2,s2,-1848 # ac0 <malloc+0x136>
                n=n/x;
 200:	0297c7bb          	divw	a5,a5,s1
 204:	fcf42e23          	sw	a5,-36(s0)
                printf("%d, ", x);
 208:	85a6                	mv	a1,s1
 20a:	854a                	mv	a0,s2
 20c:	00000097          	auipc	ra,0x0
 210:	6c0080e7          	jalr	1728(ra) # 8cc <printf>
            while(n%x==0){
 214:	fdc42783          	lw	a5,-36(s0)
 218:	0297e73b          	remw	a4,a5,s1
 21c:	d375                	beqz	a4,200 <main+0x9c>
                flag=1;
            }
            if(flag)
            printf("[%d]\n", getpid());
 21e:	00000097          	auipc	ra,0x0
 222:	396080e7          	jalr	918(ra) # 5b4 <getpid>
 226:	85aa                	mv	a1,a0
 228:	00001517          	auipc	a0,0x1
 22c:	8c850513          	addi	a0,a0,-1848 # af0 <malloc+0x166>
 230:	00000097          	auipc	ra,0x0
 234:	69c080e7          	jalr	1692(ra) # 8cc <printf>
            if(n==1){
 238:	fdc42703          	lw	a4,-36(s0)
 23c:	4785                	li	a5,1
 23e:	04f70e63          	beq	a4,a5,29a <main+0x136>
                exit(0);
            }
            if (write(pipefd[1], &n, 4) < 0) {
 242:	4611                	li	a2,4
 244:	fdc40593          	addi	a1,s0,-36
 248:	f7442503          	lw	a0,-140(s0)
 24c:	00000097          	auipc	ra,0x0
 250:	308080e7          	jalr	776(ra) # 554 <write>
 254:	04054863          	bltz	a0,2a4 <main+0x140>
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                close(pipefd[1]);
 258:	f7442503          	lw	a0,-140(s0)
 25c:	00000097          	auipc	ra,0x0
 260:	300080e7          	jalr	768(ra) # 55c <close>
            }
            pipelining(i+1,primes,pipefd);
 264:	f7040613          	addi	a2,s0,-144
 268:	f7840593          	addi	a1,s0,-136
 26c:	4505                	li	a0,1
 26e:	00000097          	auipc	ra,0x0
 272:	d92080e7          	jalr	-622(ra) # 0 <pipelining>
    }
    exit(0);
 276:	4501                	li	a0,0
 278:	00000097          	auipc	ra,0x0
 27c:	2bc080e7          	jalr	700(ra) # 534 <exit>
		printf("Error: cannot create pipe. Aborting...\n");
 280:	00001517          	auipc	a0,0x1
 284:	81850513          	addi	a0,a0,-2024 # a98 <malloc+0x10e>
 288:	00000097          	auipc	ra,0x0
 28c:	644080e7          	jalr	1604(ra) # 8cc <printf>
		exit(0);
 290:	4501                	li	a0,0
 292:	00000097          	auipc	ra,0x0
 296:	2a2080e7          	jalr	674(ra) # 534 <exit>
                exit(0);
 29a:	4501                	li	a0,0
 29c:	00000097          	auipc	ra,0x0
 2a0:	298080e7          	jalr	664(ra) # 534 <exit>
                printf("Error: cannot write. Aborting...\n");
 2a4:	00001517          	auipc	a0,0x1
 2a8:	82450513          	addi	a0,a0,-2012 # ac8 <malloc+0x13e>
 2ac:	00000097          	auipc	ra,0x0
 2b0:	620080e7          	jalr	1568(ra) # 8cc <printf>
                exit(0);
 2b4:	4501                	li	a0,0
 2b6:	00000097          	auipc	ra,0x0
 2ba:	27e080e7          	jalr	638(ra) # 534 <exit>

00000000000002be <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2c4:	87aa                	mv	a5,a0
 2c6:	0585                	addi	a1,a1,1
 2c8:	0785                	addi	a5,a5,1
 2ca:	fff5c703          	lbu	a4,-1(a1)
 2ce:	fee78fa3          	sb	a4,-1(a5)
 2d2:	fb75                	bnez	a4,2c6 <strcpy+0x8>
    ;
  return os;
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e422                	sd	s0,8(sp)
 2de:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2e0:	00054783          	lbu	a5,0(a0)
 2e4:	cb91                	beqz	a5,2f8 <strcmp+0x1e>
 2e6:	0005c703          	lbu	a4,0(a1)
 2ea:	00f71763          	bne	a4,a5,2f8 <strcmp+0x1e>
    p++, q++;
 2ee:	0505                	addi	a0,a0,1
 2f0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2f2:	00054783          	lbu	a5,0(a0)
 2f6:	fbe5                	bnez	a5,2e6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2f8:	0005c503          	lbu	a0,0(a1)
}
 2fc:	40a7853b          	subw	a0,a5,a0
 300:	6422                	ld	s0,8(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret

0000000000000306 <strlen>:

uint
strlen(const char *s)
{
 306:	1141                	addi	sp,sp,-16
 308:	e422                	sd	s0,8(sp)
 30a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 30c:	00054783          	lbu	a5,0(a0)
 310:	cf91                	beqz	a5,32c <strlen+0x26>
 312:	0505                	addi	a0,a0,1
 314:	87aa                	mv	a5,a0
 316:	4685                	li	a3,1
 318:	9e89                	subw	a3,a3,a0
 31a:	00f6853b          	addw	a0,a3,a5
 31e:	0785                	addi	a5,a5,1
 320:	fff7c703          	lbu	a4,-1(a5)
 324:	fb7d                	bnez	a4,31a <strlen+0x14>
    ;
  return n;
}
 326:	6422                	ld	s0,8(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret
  for(n = 0; s[n]; n++)
 32c:	4501                	li	a0,0
 32e:	bfe5                	j	326 <strlen+0x20>

0000000000000330 <memset>:

void*
memset(void *dst, int c, uint n)
{
 330:	1141                	addi	sp,sp,-16
 332:	e422                	sd	s0,8(sp)
 334:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 336:	ce09                	beqz	a2,350 <memset+0x20>
 338:	87aa                	mv	a5,a0
 33a:	fff6071b          	addiw	a4,a2,-1
 33e:	1702                	slli	a4,a4,0x20
 340:	9301                	srli	a4,a4,0x20
 342:	0705                	addi	a4,a4,1
 344:	972a                	add	a4,a4,a0
    cdst[i] = c;
 346:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 34a:	0785                	addi	a5,a5,1
 34c:	fee79de3          	bne	a5,a4,346 <memset+0x16>
  }
  return dst;
}
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret

0000000000000356 <strchr>:

char*
strchr(const char *s, char c)
{
 356:	1141                	addi	sp,sp,-16
 358:	e422                	sd	s0,8(sp)
 35a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 35c:	00054783          	lbu	a5,0(a0)
 360:	cb99                	beqz	a5,376 <strchr+0x20>
    if(*s == c)
 362:	00f58763          	beq	a1,a5,370 <strchr+0x1a>
  for(; *s; s++)
 366:	0505                	addi	a0,a0,1
 368:	00054783          	lbu	a5,0(a0)
 36c:	fbfd                	bnez	a5,362 <strchr+0xc>
      return (char*)s;
  return 0;
 36e:	4501                	li	a0,0
}
 370:	6422                	ld	s0,8(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret
  return 0;
 376:	4501                	li	a0,0
 378:	bfe5                	j	370 <strchr+0x1a>

000000000000037a <gets>:

char*
gets(char *buf, int max)
{
 37a:	711d                	addi	sp,sp,-96
 37c:	ec86                	sd	ra,88(sp)
 37e:	e8a2                	sd	s0,80(sp)
 380:	e4a6                	sd	s1,72(sp)
 382:	e0ca                	sd	s2,64(sp)
 384:	fc4e                	sd	s3,56(sp)
 386:	f852                	sd	s4,48(sp)
 388:	f456                	sd	s5,40(sp)
 38a:	f05a                	sd	s6,32(sp)
 38c:	ec5e                	sd	s7,24(sp)
 38e:	1080                	addi	s0,sp,96
 390:	8baa                	mv	s7,a0
 392:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 394:	892a                	mv	s2,a0
 396:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 398:	4aa9                	li	s5,10
 39a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 39c:	89a6                	mv	s3,s1
 39e:	2485                	addiw	s1,s1,1
 3a0:	0344d863          	bge	s1,s4,3d0 <gets+0x56>
    cc = read(0, &c, 1);
 3a4:	4605                	li	a2,1
 3a6:	faf40593          	addi	a1,s0,-81
 3aa:	4501                	li	a0,0
 3ac:	00000097          	auipc	ra,0x0
 3b0:	1a0080e7          	jalr	416(ra) # 54c <read>
    if(cc < 1)
 3b4:	00a05e63          	blez	a0,3d0 <gets+0x56>
    buf[i++] = c;
 3b8:	faf44783          	lbu	a5,-81(s0)
 3bc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3c0:	01578763          	beq	a5,s5,3ce <gets+0x54>
 3c4:	0905                	addi	s2,s2,1
 3c6:	fd679be3          	bne	a5,s6,39c <gets+0x22>
  for(i=0; i+1 < max; ){
 3ca:	89a6                	mv	s3,s1
 3cc:	a011                	j	3d0 <gets+0x56>
 3ce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3d0:	99de                	add	s3,s3,s7
 3d2:	00098023          	sb	zero,0(s3)
  return buf;
}
 3d6:	855e                	mv	a0,s7
 3d8:	60e6                	ld	ra,88(sp)
 3da:	6446                	ld	s0,80(sp)
 3dc:	64a6                	ld	s1,72(sp)
 3de:	6906                	ld	s2,64(sp)
 3e0:	79e2                	ld	s3,56(sp)
 3e2:	7a42                	ld	s4,48(sp)
 3e4:	7aa2                	ld	s5,40(sp)
 3e6:	7b02                	ld	s6,32(sp)
 3e8:	6be2                	ld	s7,24(sp)
 3ea:	6125                	addi	sp,sp,96
 3ec:	8082                	ret

00000000000003ee <stat>:

int
stat(const char *n, struct stat *st)
{
 3ee:	1101                	addi	sp,sp,-32
 3f0:	ec06                	sd	ra,24(sp)
 3f2:	e822                	sd	s0,16(sp)
 3f4:	e426                	sd	s1,8(sp)
 3f6:	e04a                	sd	s2,0(sp)
 3f8:	1000                	addi	s0,sp,32
 3fa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3fc:	4581                	li	a1,0
 3fe:	00000097          	auipc	ra,0x0
 402:	176080e7          	jalr	374(ra) # 574 <open>
  if(fd < 0)
 406:	02054563          	bltz	a0,430 <stat+0x42>
 40a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 40c:	85ca                	mv	a1,s2
 40e:	00000097          	auipc	ra,0x0
 412:	17e080e7          	jalr	382(ra) # 58c <fstat>
 416:	892a                	mv	s2,a0
  close(fd);
 418:	8526                	mv	a0,s1
 41a:	00000097          	auipc	ra,0x0
 41e:	142080e7          	jalr	322(ra) # 55c <close>
  return r;
}
 422:	854a                	mv	a0,s2
 424:	60e2                	ld	ra,24(sp)
 426:	6442                	ld	s0,16(sp)
 428:	64a2                	ld	s1,8(sp)
 42a:	6902                	ld	s2,0(sp)
 42c:	6105                	addi	sp,sp,32
 42e:	8082                	ret
    return -1;
 430:	597d                	li	s2,-1
 432:	bfc5                	j	422 <stat+0x34>

0000000000000434 <atoi>:

int
atoi(const char *s)
{
 434:	1141                	addi	sp,sp,-16
 436:	e422                	sd	s0,8(sp)
 438:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 43a:	00054603          	lbu	a2,0(a0)
 43e:	fd06079b          	addiw	a5,a2,-48
 442:	0ff7f793          	andi	a5,a5,255
 446:	4725                	li	a4,9
 448:	02f76963          	bltu	a4,a5,47a <atoi+0x46>
 44c:	86aa                	mv	a3,a0
  n = 0;
 44e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 450:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 452:	0685                	addi	a3,a3,1
 454:	0025179b          	slliw	a5,a0,0x2
 458:	9fa9                	addw	a5,a5,a0
 45a:	0017979b          	slliw	a5,a5,0x1
 45e:	9fb1                	addw	a5,a5,a2
 460:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 464:	0006c603          	lbu	a2,0(a3)
 468:	fd06071b          	addiw	a4,a2,-48
 46c:	0ff77713          	andi	a4,a4,255
 470:	fee5f1e3          	bgeu	a1,a4,452 <atoi+0x1e>
  return n;
}
 474:	6422                	ld	s0,8(sp)
 476:	0141                	addi	sp,sp,16
 478:	8082                	ret
  n = 0;
 47a:	4501                	li	a0,0
 47c:	bfe5                	j	474 <atoi+0x40>

000000000000047e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 484:	02b57663          	bgeu	a0,a1,4b0 <memmove+0x32>
    while(n-- > 0)
 488:	02c05163          	blez	a2,4aa <memmove+0x2c>
 48c:	fff6079b          	addiw	a5,a2,-1
 490:	1782                	slli	a5,a5,0x20
 492:	9381                	srli	a5,a5,0x20
 494:	0785                	addi	a5,a5,1
 496:	97aa                	add	a5,a5,a0
  dst = vdst;
 498:	872a                	mv	a4,a0
      *dst++ = *src++;
 49a:	0585                	addi	a1,a1,1
 49c:	0705                	addi	a4,a4,1
 49e:	fff5c683          	lbu	a3,-1(a1)
 4a2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4a6:	fee79ae3          	bne	a5,a4,49a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4aa:	6422                	ld	s0,8(sp)
 4ac:	0141                	addi	sp,sp,16
 4ae:	8082                	ret
    dst += n;
 4b0:	00c50733          	add	a4,a0,a2
    src += n;
 4b4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4b6:	fec05ae3          	blez	a2,4aa <memmove+0x2c>
 4ba:	fff6079b          	addiw	a5,a2,-1
 4be:	1782                	slli	a5,a5,0x20
 4c0:	9381                	srli	a5,a5,0x20
 4c2:	fff7c793          	not	a5,a5
 4c6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4c8:	15fd                	addi	a1,a1,-1
 4ca:	177d                	addi	a4,a4,-1
 4cc:	0005c683          	lbu	a3,0(a1)
 4d0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4d4:	fee79ae3          	bne	a5,a4,4c8 <memmove+0x4a>
 4d8:	bfc9                	j	4aa <memmove+0x2c>

00000000000004da <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4da:	1141                	addi	sp,sp,-16
 4dc:	e422                	sd	s0,8(sp)
 4de:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4e0:	ca05                	beqz	a2,510 <memcmp+0x36>
 4e2:	fff6069b          	addiw	a3,a2,-1
 4e6:	1682                	slli	a3,a3,0x20
 4e8:	9281                	srli	a3,a3,0x20
 4ea:	0685                	addi	a3,a3,1
 4ec:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4ee:	00054783          	lbu	a5,0(a0)
 4f2:	0005c703          	lbu	a4,0(a1)
 4f6:	00e79863          	bne	a5,a4,506 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4fa:	0505                	addi	a0,a0,1
    p2++;
 4fc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4fe:	fed518e3          	bne	a0,a3,4ee <memcmp+0x14>
  }
  return 0;
 502:	4501                	li	a0,0
 504:	a019                	j	50a <memcmp+0x30>
      return *p1 - *p2;
 506:	40e7853b          	subw	a0,a5,a4
}
 50a:	6422                	ld	s0,8(sp)
 50c:	0141                	addi	sp,sp,16
 50e:	8082                	ret
  return 0;
 510:	4501                	li	a0,0
 512:	bfe5                	j	50a <memcmp+0x30>

0000000000000514 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 514:	1141                	addi	sp,sp,-16
 516:	e406                	sd	ra,8(sp)
 518:	e022                	sd	s0,0(sp)
 51a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 51c:	00000097          	auipc	ra,0x0
 520:	f62080e7          	jalr	-158(ra) # 47e <memmove>
}
 524:	60a2                	ld	ra,8(sp)
 526:	6402                	ld	s0,0(sp)
 528:	0141                	addi	sp,sp,16
 52a:	8082                	ret

000000000000052c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 52c:	4885                	li	a7,1
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <exit>:
.global exit
exit:
 li a7, SYS_exit
 534:	4889                	li	a7,2
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <wait>:
.global wait
wait:
 li a7, SYS_wait
 53c:	488d                	li	a7,3
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 544:	4891                	li	a7,4
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <read>:
.global read
read:
 li a7, SYS_read
 54c:	4895                	li	a7,5
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <write>:
.global write
write:
 li a7, SYS_write
 554:	48c1                	li	a7,16
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <close>:
.global close
close:
 li a7, SYS_close
 55c:	48d5                	li	a7,21
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <kill>:
.global kill
kill:
 li a7, SYS_kill
 564:	4899                	li	a7,6
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <exec>:
.global exec
exec:
 li a7, SYS_exec
 56c:	489d                	li	a7,7
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <open>:
.global open
open:
 li a7, SYS_open
 574:	48bd                	li	a7,15
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 57c:	48c5                	li	a7,17
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 584:	48c9                	li	a7,18
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 58c:	48a1                	li	a7,8
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <link>:
.global link
link:
 li a7, SYS_link
 594:	48cd                	li	a7,19
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 59c:	48d1                	li	a7,20
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5a4:	48a5                	li	a7,9
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <dup>:
.global dup
dup:
 li a7, SYS_dup
 5ac:	48a9                	li	a7,10
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5b4:	48ad                	li	a7,11
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5bc:	48b1                	li	a7,12
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5c4:	48b5                	li	a7,13
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5cc:	48b9                	li	a7,14
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 5d4:	48d9                	li	a7,22
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <yield>:
.global yield
yield:
 li a7, SYS_yield
 5dc:	48dd                	li	a7,23
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 5e4:	48e1                	li	a7,24
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 5ec:	48e5                	li	a7,25
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5f4:	1101                	addi	sp,sp,-32
 5f6:	ec06                	sd	ra,24(sp)
 5f8:	e822                	sd	s0,16(sp)
 5fa:	1000                	addi	s0,sp,32
 5fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 600:	4605                	li	a2,1
 602:	fef40593          	addi	a1,s0,-17
 606:	00000097          	auipc	ra,0x0
 60a:	f4e080e7          	jalr	-178(ra) # 554 <write>
}
 60e:	60e2                	ld	ra,24(sp)
 610:	6442                	ld	s0,16(sp)
 612:	6105                	addi	sp,sp,32
 614:	8082                	ret

0000000000000616 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 616:	7139                	addi	sp,sp,-64
 618:	fc06                	sd	ra,56(sp)
 61a:	f822                	sd	s0,48(sp)
 61c:	f426                	sd	s1,40(sp)
 61e:	f04a                	sd	s2,32(sp)
 620:	ec4e                	sd	s3,24(sp)
 622:	0080                	addi	s0,sp,64
 624:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 626:	c299                	beqz	a3,62c <printint+0x16>
 628:	0805c863          	bltz	a1,6b8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 62c:	2581                	sext.w	a1,a1
  neg = 0;
 62e:	4881                	li	a7,0
 630:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 634:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 636:	2601                	sext.w	a2,a2
 638:	00000517          	auipc	a0,0x0
 63c:	54850513          	addi	a0,a0,1352 # b80 <digits>
 640:	883a                	mv	a6,a4
 642:	2705                	addiw	a4,a4,1
 644:	02c5f7bb          	remuw	a5,a1,a2
 648:	1782                	slli	a5,a5,0x20
 64a:	9381                	srli	a5,a5,0x20
 64c:	97aa                	add	a5,a5,a0
 64e:	0007c783          	lbu	a5,0(a5)
 652:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 656:	0005879b          	sext.w	a5,a1
 65a:	02c5d5bb          	divuw	a1,a1,a2
 65e:	0685                	addi	a3,a3,1
 660:	fec7f0e3          	bgeu	a5,a2,640 <printint+0x2a>
  if(neg)
 664:	00088b63          	beqz	a7,67a <printint+0x64>
    buf[i++] = '-';
 668:	fd040793          	addi	a5,s0,-48
 66c:	973e                	add	a4,a4,a5
 66e:	02d00793          	li	a5,45
 672:	fef70823          	sb	a5,-16(a4)
 676:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 67a:	02e05863          	blez	a4,6aa <printint+0x94>
 67e:	fc040793          	addi	a5,s0,-64
 682:	00e78933          	add	s2,a5,a4
 686:	fff78993          	addi	s3,a5,-1
 68a:	99ba                	add	s3,s3,a4
 68c:	377d                	addiw	a4,a4,-1
 68e:	1702                	slli	a4,a4,0x20
 690:	9301                	srli	a4,a4,0x20
 692:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 696:	fff94583          	lbu	a1,-1(s2)
 69a:	8526                	mv	a0,s1
 69c:	00000097          	auipc	ra,0x0
 6a0:	f58080e7          	jalr	-168(ra) # 5f4 <putc>
  while(--i >= 0)
 6a4:	197d                	addi	s2,s2,-1
 6a6:	ff3918e3          	bne	s2,s3,696 <printint+0x80>
}
 6aa:	70e2                	ld	ra,56(sp)
 6ac:	7442                	ld	s0,48(sp)
 6ae:	74a2                	ld	s1,40(sp)
 6b0:	7902                	ld	s2,32(sp)
 6b2:	69e2                	ld	s3,24(sp)
 6b4:	6121                	addi	sp,sp,64
 6b6:	8082                	ret
    x = -xx;
 6b8:	40b005bb          	negw	a1,a1
    neg = 1;
 6bc:	4885                	li	a7,1
    x = -xx;
 6be:	bf8d                	j	630 <printint+0x1a>

00000000000006c0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6c0:	7119                	addi	sp,sp,-128
 6c2:	fc86                	sd	ra,120(sp)
 6c4:	f8a2                	sd	s0,112(sp)
 6c6:	f4a6                	sd	s1,104(sp)
 6c8:	f0ca                	sd	s2,96(sp)
 6ca:	ecce                	sd	s3,88(sp)
 6cc:	e8d2                	sd	s4,80(sp)
 6ce:	e4d6                	sd	s5,72(sp)
 6d0:	e0da                	sd	s6,64(sp)
 6d2:	fc5e                	sd	s7,56(sp)
 6d4:	f862                	sd	s8,48(sp)
 6d6:	f466                	sd	s9,40(sp)
 6d8:	f06a                	sd	s10,32(sp)
 6da:	ec6e                	sd	s11,24(sp)
 6dc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6de:	0005c903          	lbu	s2,0(a1)
 6e2:	18090f63          	beqz	s2,880 <vprintf+0x1c0>
 6e6:	8aaa                	mv	s5,a0
 6e8:	8b32                	mv	s6,a2
 6ea:	00158493          	addi	s1,a1,1
  state = 0;
 6ee:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6f0:	02500a13          	li	s4,37
      if(c == 'd'){
 6f4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6f8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6fc:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 700:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 704:	00000b97          	auipc	s7,0x0
 708:	47cb8b93          	addi	s7,s7,1148 # b80 <digits>
 70c:	a839                	j	72a <vprintf+0x6a>
        putc(fd, c);
 70e:	85ca                	mv	a1,s2
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	ee2080e7          	jalr	-286(ra) # 5f4 <putc>
 71a:	a019                	j	720 <vprintf+0x60>
    } else if(state == '%'){
 71c:	01498f63          	beq	s3,s4,73a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 720:	0485                	addi	s1,s1,1
 722:	fff4c903          	lbu	s2,-1(s1)
 726:	14090d63          	beqz	s2,880 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 72a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 72e:	fe0997e3          	bnez	s3,71c <vprintf+0x5c>
      if(c == '%'){
 732:	fd479ee3          	bne	a5,s4,70e <vprintf+0x4e>
        state = '%';
 736:	89be                	mv	s3,a5
 738:	b7e5                	j	720 <vprintf+0x60>
      if(c == 'd'){
 73a:	05878063          	beq	a5,s8,77a <vprintf+0xba>
      } else if(c == 'l') {
 73e:	05978c63          	beq	a5,s9,796 <vprintf+0xd6>
      } else if(c == 'x') {
 742:	07a78863          	beq	a5,s10,7b2 <vprintf+0xf2>
      } else if(c == 'p') {
 746:	09b78463          	beq	a5,s11,7ce <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 74a:	07300713          	li	a4,115
 74e:	0ce78663          	beq	a5,a4,81a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 752:	06300713          	li	a4,99
 756:	0ee78e63          	beq	a5,a4,852 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 75a:	11478863          	beq	a5,s4,86a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 75e:	85d2                	mv	a1,s4
 760:	8556                	mv	a0,s5
 762:	00000097          	auipc	ra,0x0
 766:	e92080e7          	jalr	-366(ra) # 5f4 <putc>
        putc(fd, c);
 76a:	85ca                	mv	a1,s2
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	e86080e7          	jalr	-378(ra) # 5f4 <putc>
      }
      state = 0;
 776:	4981                	li	s3,0
 778:	b765                	j	720 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 77a:	008b0913          	addi	s2,s6,8
 77e:	4685                	li	a3,1
 780:	4629                	li	a2,10
 782:	000b2583          	lw	a1,0(s6)
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	e8e080e7          	jalr	-370(ra) # 616 <printint>
 790:	8b4a                	mv	s6,s2
      state = 0;
 792:	4981                	li	s3,0
 794:	b771                	j	720 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 796:	008b0913          	addi	s2,s6,8
 79a:	4681                	li	a3,0
 79c:	4629                	li	a2,10
 79e:	000b2583          	lw	a1,0(s6)
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	e72080e7          	jalr	-398(ra) # 616 <printint>
 7ac:	8b4a                	mv	s6,s2
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	bf85                	j	720 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7b2:	008b0913          	addi	s2,s6,8
 7b6:	4681                	li	a3,0
 7b8:	4641                	li	a2,16
 7ba:	000b2583          	lw	a1,0(s6)
 7be:	8556                	mv	a0,s5
 7c0:	00000097          	auipc	ra,0x0
 7c4:	e56080e7          	jalr	-426(ra) # 616 <printint>
 7c8:	8b4a                	mv	s6,s2
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	bf91                	j	720 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7ce:	008b0793          	addi	a5,s6,8
 7d2:	f8f43423          	sd	a5,-120(s0)
 7d6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7da:	03000593          	li	a1,48
 7de:	8556                	mv	a0,s5
 7e0:	00000097          	auipc	ra,0x0
 7e4:	e14080e7          	jalr	-492(ra) # 5f4 <putc>
  putc(fd, 'x');
 7e8:	85ea                	mv	a1,s10
 7ea:	8556                	mv	a0,s5
 7ec:	00000097          	auipc	ra,0x0
 7f0:	e08080e7          	jalr	-504(ra) # 5f4 <putc>
 7f4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f6:	03c9d793          	srli	a5,s3,0x3c
 7fa:	97de                	add	a5,a5,s7
 7fc:	0007c583          	lbu	a1,0(a5)
 800:	8556                	mv	a0,s5
 802:	00000097          	auipc	ra,0x0
 806:	df2080e7          	jalr	-526(ra) # 5f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 80a:	0992                	slli	s3,s3,0x4
 80c:	397d                	addiw	s2,s2,-1
 80e:	fe0914e3          	bnez	s2,7f6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 812:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 816:	4981                	li	s3,0
 818:	b721                	j	720 <vprintf+0x60>
        s = va_arg(ap, char*);
 81a:	008b0993          	addi	s3,s6,8
 81e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 822:	02090163          	beqz	s2,844 <vprintf+0x184>
        while(*s != 0){
 826:	00094583          	lbu	a1,0(s2)
 82a:	c9a1                	beqz	a1,87a <vprintf+0x1ba>
          putc(fd, *s);
 82c:	8556                	mv	a0,s5
 82e:	00000097          	auipc	ra,0x0
 832:	dc6080e7          	jalr	-570(ra) # 5f4 <putc>
          s++;
 836:	0905                	addi	s2,s2,1
        while(*s != 0){
 838:	00094583          	lbu	a1,0(s2)
 83c:	f9e5                	bnez	a1,82c <vprintf+0x16c>
        s = va_arg(ap, char*);
 83e:	8b4e                	mv	s6,s3
      state = 0;
 840:	4981                	li	s3,0
 842:	bdf9                	j	720 <vprintf+0x60>
          s = "(null)";
 844:	00000917          	auipc	s2,0x0
 848:	33490913          	addi	s2,s2,820 # b78 <malloc+0x1ee>
        while(*s != 0){
 84c:	02800593          	li	a1,40
 850:	bff1                	j	82c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 852:	008b0913          	addi	s2,s6,8
 856:	000b4583          	lbu	a1,0(s6)
 85a:	8556                	mv	a0,s5
 85c:	00000097          	auipc	ra,0x0
 860:	d98080e7          	jalr	-616(ra) # 5f4 <putc>
 864:	8b4a                	mv	s6,s2
      state = 0;
 866:	4981                	li	s3,0
 868:	bd65                	j	720 <vprintf+0x60>
        putc(fd, c);
 86a:	85d2                	mv	a1,s4
 86c:	8556                	mv	a0,s5
 86e:	00000097          	auipc	ra,0x0
 872:	d86080e7          	jalr	-634(ra) # 5f4 <putc>
      state = 0;
 876:	4981                	li	s3,0
 878:	b565                	j	720 <vprintf+0x60>
        s = va_arg(ap, char*);
 87a:	8b4e                	mv	s6,s3
      state = 0;
 87c:	4981                	li	s3,0
 87e:	b54d                	j	720 <vprintf+0x60>
    }
  }
}
 880:	70e6                	ld	ra,120(sp)
 882:	7446                	ld	s0,112(sp)
 884:	74a6                	ld	s1,104(sp)
 886:	7906                	ld	s2,96(sp)
 888:	69e6                	ld	s3,88(sp)
 88a:	6a46                	ld	s4,80(sp)
 88c:	6aa6                	ld	s5,72(sp)
 88e:	6b06                	ld	s6,64(sp)
 890:	7be2                	ld	s7,56(sp)
 892:	7c42                	ld	s8,48(sp)
 894:	7ca2                	ld	s9,40(sp)
 896:	7d02                	ld	s10,32(sp)
 898:	6de2                	ld	s11,24(sp)
 89a:	6109                	addi	sp,sp,128
 89c:	8082                	ret

000000000000089e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 89e:	715d                	addi	sp,sp,-80
 8a0:	ec06                	sd	ra,24(sp)
 8a2:	e822                	sd	s0,16(sp)
 8a4:	1000                	addi	s0,sp,32
 8a6:	e010                	sd	a2,0(s0)
 8a8:	e414                	sd	a3,8(s0)
 8aa:	e818                	sd	a4,16(s0)
 8ac:	ec1c                	sd	a5,24(s0)
 8ae:	03043023          	sd	a6,32(s0)
 8b2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8ba:	8622                	mv	a2,s0
 8bc:	00000097          	auipc	ra,0x0
 8c0:	e04080e7          	jalr	-508(ra) # 6c0 <vprintf>
}
 8c4:	60e2                	ld	ra,24(sp)
 8c6:	6442                	ld	s0,16(sp)
 8c8:	6161                	addi	sp,sp,80
 8ca:	8082                	ret

00000000000008cc <printf>:

void
printf(const char *fmt, ...)
{
 8cc:	711d                	addi	sp,sp,-96
 8ce:	ec06                	sd	ra,24(sp)
 8d0:	e822                	sd	s0,16(sp)
 8d2:	1000                	addi	s0,sp,32
 8d4:	e40c                	sd	a1,8(s0)
 8d6:	e810                	sd	a2,16(s0)
 8d8:	ec14                	sd	a3,24(s0)
 8da:	f018                	sd	a4,32(s0)
 8dc:	f41c                	sd	a5,40(s0)
 8de:	03043823          	sd	a6,48(s0)
 8e2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e6:	00840613          	addi	a2,s0,8
 8ea:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ee:	85aa                	mv	a1,a0
 8f0:	4505                	li	a0,1
 8f2:	00000097          	auipc	ra,0x0
 8f6:	dce080e7          	jalr	-562(ra) # 6c0 <vprintf>
}
 8fa:	60e2                	ld	ra,24(sp)
 8fc:	6442                	ld	s0,16(sp)
 8fe:	6125                	addi	sp,sp,96
 900:	8082                	ret

0000000000000902 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 902:	1141                	addi	sp,sp,-16
 904:	e422                	sd	s0,8(sp)
 906:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 908:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90c:	00000797          	auipc	a5,0x0
 910:	28c7b783          	ld	a5,652(a5) # b98 <freep>
 914:	a805                	j	944 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 916:	4618                	lw	a4,8(a2)
 918:	9db9                	addw	a1,a1,a4
 91a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91e:	6398                	ld	a4,0(a5)
 920:	6318                	ld	a4,0(a4)
 922:	fee53823          	sd	a4,-16(a0)
 926:	a091                	j	96a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 928:	ff852703          	lw	a4,-8(a0)
 92c:	9e39                	addw	a2,a2,a4
 92e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 930:	ff053703          	ld	a4,-16(a0)
 934:	e398                	sd	a4,0(a5)
 936:	a099                	j	97c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 938:	6398                	ld	a4,0(a5)
 93a:	00e7e463          	bltu	a5,a4,942 <free+0x40>
 93e:	00e6ea63          	bltu	a3,a4,952 <free+0x50>
{
 942:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 944:	fed7fae3          	bgeu	a5,a3,938 <free+0x36>
 948:	6398                	ld	a4,0(a5)
 94a:	00e6e463          	bltu	a3,a4,952 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94e:	fee7eae3          	bltu	a5,a4,942 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 952:	ff852583          	lw	a1,-8(a0)
 956:	6390                	ld	a2,0(a5)
 958:	02059713          	slli	a4,a1,0x20
 95c:	9301                	srli	a4,a4,0x20
 95e:	0712                	slli	a4,a4,0x4
 960:	9736                	add	a4,a4,a3
 962:	fae60ae3          	beq	a2,a4,916 <free+0x14>
    bp->s.ptr = p->s.ptr;
 966:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 96a:	4790                	lw	a2,8(a5)
 96c:	02061713          	slli	a4,a2,0x20
 970:	9301                	srli	a4,a4,0x20
 972:	0712                	slli	a4,a4,0x4
 974:	973e                	add	a4,a4,a5
 976:	fae689e3          	beq	a3,a4,928 <free+0x26>
  } else
    p->s.ptr = bp;
 97a:	e394                	sd	a3,0(a5)
  freep = p;
 97c:	00000717          	auipc	a4,0x0
 980:	20f73e23          	sd	a5,540(a4) # b98 <freep>
}
 984:	6422                	ld	s0,8(sp)
 986:	0141                	addi	sp,sp,16
 988:	8082                	ret

000000000000098a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 98a:	7139                	addi	sp,sp,-64
 98c:	fc06                	sd	ra,56(sp)
 98e:	f822                	sd	s0,48(sp)
 990:	f426                	sd	s1,40(sp)
 992:	f04a                	sd	s2,32(sp)
 994:	ec4e                	sd	s3,24(sp)
 996:	e852                	sd	s4,16(sp)
 998:	e456                	sd	s5,8(sp)
 99a:	e05a                	sd	s6,0(sp)
 99c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 99e:	02051493          	slli	s1,a0,0x20
 9a2:	9081                	srli	s1,s1,0x20
 9a4:	04bd                	addi	s1,s1,15
 9a6:	8091                	srli	s1,s1,0x4
 9a8:	0014899b          	addiw	s3,s1,1
 9ac:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9ae:	00000517          	auipc	a0,0x0
 9b2:	1ea53503          	ld	a0,490(a0) # b98 <freep>
 9b6:	c515                	beqz	a0,9e2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ba:	4798                	lw	a4,8(a5)
 9bc:	02977f63          	bgeu	a4,s1,9fa <malloc+0x70>
 9c0:	8a4e                	mv	s4,s3
 9c2:	0009871b          	sext.w	a4,s3
 9c6:	6685                	lui	a3,0x1
 9c8:	00d77363          	bgeu	a4,a3,9ce <malloc+0x44>
 9cc:	6a05                	lui	s4,0x1
 9ce:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9d2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9d6:	00000917          	auipc	s2,0x0
 9da:	1c290913          	addi	s2,s2,450 # b98 <freep>
  if(p == (char*)-1)
 9de:	5afd                	li	s5,-1
 9e0:	a88d                	j	a52 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 9e2:	00000797          	auipc	a5,0x0
 9e6:	1be78793          	addi	a5,a5,446 # ba0 <base>
 9ea:	00000717          	auipc	a4,0x0
 9ee:	1af73723          	sd	a5,430(a4) # b98 <freep>
 9f2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9f4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9f8:	b7e1                	j	9c0 <malloc+0x36>
      if(p->s.size == nunits)
 9fa:	02e48b63          	beq	s1,a4,a30 <malloc+0xa6>
        p->s.size -= nunits;
 9fe:	4137073b          	subw	a4,a4,s3
 a02:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a04:	1702                	slli	a4,a4,0x20
 a06:	9301                	srli	a4,a4,0x20
 a08:	0712                	slli	a4,a4,0x4
 a0a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a0c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a10:	00000717          	auipc	a4,0x0
 a14:	18a73423          	sd	a0,392(a4) # b98 <freep>
      return (void*)(p + 1);
 a18:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a1c:	70e2                	ld	ra,56(sp)
 a1e:	7442                	ld	s0,48(sp)
 a20:	74a2                	ld	s1,40(sp)
 a22:	7902                	ld	s2,32(sp)
 a24:	69e2                	ld	s3,24(sp)
 a26:	6a42                	ld	s4,16(sp)
 a28:	6aa2                	ld	s5,8(sp)
 a2a:	6b02                	ld	s6,0(sp)
 a2c:	6121                	addi	sp,sp,64
 a2e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a30:	6398                	ld	a4,0(a5)
 a32:	e118                	sd	a4,0(a0)
 a34:	bff1                	j	a10 <malloc+0x86>
  hp->s.size = nu;
 a36:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a3a:	0541                	addi	a0,a0,16
 a3c:	00000097          	auipc	ra,0x0
 a40:	ec6080e7          	jalr	-314(ra) # 902 <free>
  return freep;
 a44:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a48:	d971                	beqz	a0,a1c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a4c:	4798                	lw	a4,8(a5)
 a4e:	fa9776e3          	bgeu	a4,s1,9fa <malloc+0x70>
    if(p == freep)
 a52:	00093703          	ld	a4,0(s2)
 a56:	853e                	mv	a0,a5
 a58:	fef719e3          	bne	a4,a5,a4a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a5c:	8552                	mv	a0,s4
 a5e:	00000097          	auipc	ra,0x0
 a62:	b5e080e7          	jalr	-1186(ra) # 5bc <sbrk>
  if(p == (char*)-1)
 a66:	fd5518e3          	bne	a0,s5,a36 <malloc+0xac>
        return 0;
 a6a:	4501                	li	a0,0
 a6c:	bf45                	j	a1c <malloc+0x92>
