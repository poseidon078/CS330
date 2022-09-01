
user/_pipeline:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <pipelining>:
int pipefd[2];
int y;
int *p=&y;
int n;

void pipelining(){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
    if(n==0){
   a:	00001797          	auipc	a5,0x1
   e:	a7e7a783          	lw	a5,-1410(a5) # a88 <n>
  12:	c7d1                	beqz	a5,9e <pipelining+0x9e>
        exit(0);
    }
    if(fork()==0){
  14:	00000097          	auipc	ra,0x0
  18:	472080e7          	jalr	1138(ra) # 486 <fork>
  1c:	e161                	bnez	a0,dc <pipelining+0xdc>
        if (read(pipefd[0], &y, 4) < 0) {
  1e:	4611                	li	a2,4
  20:	00001597          	auipc	a1,0x1
  24:	a6c58593          	addi	a1,a1,-1428 # a8c <y>
  28:	00001517          	auipc	a0,0x1
  2c:	a6852503          	lw	a0,-1432(a0) # a90 <pipefd>
  30:	00000097          	auipc	ra,0x0
  34:	476080e7          	jalr	1142(ra) # 4a6 <read>
  38:	06054863          	bltz	a0,a8 <pipelining+0xa8>
			printf("Error: cannot read. Aborting...\n");
			exit(0);
		}
        else{
            y=y+getpid();
  3c:	00000097          	auipc	ra,0x0
  40:	4d2080e7          	jalr	1234(ra) # 50e <getpid>
  44:	00001497          	auipc	s1,0x1
  48:	a4848493          	addi	s1,s1,-1464 # a8c <y>
  4c:	409c                	lw	a5,0(s1)
  4e:	9fa9                	addw	a5,a5,a0
  50:	c09c                	sw	a5,0(s1)
            printf("%d: %d\n", getpid(), y);
  52:	00000097          	auipc	ra,0x0
  56:	4bc080e7          	jalr	1212(ra) # 50e <getpid>
  5a:	85aa                	mv	a1,a0
  5c:	4090                	lw	a2,0(s1)
  5e:	00001517          	auipc	a0,0x1
  62:	99250513          	addi	a0,a0,-1646 # 9f0 <malloc+0x10c>
  66:	00000097          	auipc	ra,0x0
  6a:	7c0080e7          	jalr	1984(ra) # 826 <printf>
            if (write(pipefd[1], &y, 4) < 0) {
  6e:	4611                	li	a2,4
  70:	85a6                	mv	a1,s1
  72:	00001517          	auipc	a0,0x1
  76:	a2252503          	lw	a0,-1502(a0) # a94 <pipefd+0x4>
  7a:	00000097          	auipc	ra,0x0
  7e:	434080e7          	jalr	1076(ra) # 4ae <write>
  82:	04054063          	bltz	a0,c2 <pipelining+0xc2>
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                n=n-1;
  86:	00001717          	auipc	a4,0x1
  8a:	a0270713          	addi	a4,a4,-1534 # a88 <n>
  8e:	431c                	lw	a5,0(a4)
  90:	37fd                	addiw	a5,a5,-1
  92:	c31c                	sw	a5,0(a4)
                pipelining();
  94:	00000097          	auipc	ra,0x0
  98:	f6c080e7          	jalr	-148(ra) # 0 <pipelining>
  9c:	a0b5                	j	108 <pipelining+0x108>
        exit(0);
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	3ee080e7          	jalr	1006(ra) # 48e <exit>
			printf("Error: cannot read. Aborting...\n");
  a8:	00001517          	auipc	a0,0x1
  ac:	92050513          	addi	a0,a0,-1760 # 9c8 <malloc+0xe4>
  b0:	00000097          	auipc	ra,0x0
  b4:	776080e7          	jalr	1910(ra) # 826 <printf>
			exit(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	3d4080e7          	jalr	980(ra) # 48e <exit>
                printf("Error: cannot write. Aborting...\n");
  c2:	00001517          	auipc	a0,0x1
  c6:	93650513          	addi	a0,a0,-1738 # 9f8 <malloc+0x114>
  ca:	00000097          	auipc	ra,0x0
  ce:	75c080e7          	jalr	1884(ra) # 826 <printf>
                exit(0);
  d2:	4501                	li	a0,0
  d4:	00000097          	auipc	ra,0x0
  d8:	3ba080e7          	jalr	954(ra) # 48e <exit>
            }
        }
    
    }
    else{
        close(pipefd[0]);
  dc:	00001497          	auipc	s1,0x1
  e0:	9b448493          	addi	s1,s1,-1612 # a90 <pipefd>
  e4:	4088                	lw	a0,0(s1)
  e6:	00000097          	auipc	ra,0x0
  ea:	3d0080e7          	jalr	976(ra) # 4b6 <close>
        close(pipefd[1]);
  ee:	40c8                	lw	a0,4(s1)
  f0:	00000097          	auipc	ra,0x0
  f4:	3c6080e7          	jalr	966(ra) # 4b6 <close>
        wait(p);
  f8:	00001517          	auipc	a0,0x1
  fc:	98853503          	ld	a0,-1656(a0) # a80 <p>
 100:	00000097          	auipc	ra,0x0
 104:	396080e7          	jalr	918(ra) # 496 <wait>
    }
}
 108:	60e2                	ld	ra,24(sp)
 10a:	6442                	ld	s0,16(sp)
 10c:	64a2                	ld	s1,8(sp)
 10e:	6105                	addi	sp,sp,32
 110:	8082                	ret

0000000000000112 <main>:

int
main(int argc, char **argv)
{
 112:	7179                	addi	sp,sp,-48
 114:	f406                	sd	ra,40(sp)
 116:	f022                	sd	s0,32(sp)
 118:	ec26                	sd	s1,24(sp)
 11a:	e84a                	sd	s2,16(sp)
 11c:	1800                	addi	s0,sp,48
 11e:	84ae                	mv	s1,a1
    n=atoi(argv[1]);
 120:	6588                	ld	a0,8(a1)
 122:	00000097          	auipc	ra,0x0
 126:	26c080e7          	jalr	620(ra) # 38e <atoi>
 12a:	00001917          	auipc	s2,0x1
 12e:	95e90913          	addi	s2,s2,-1698 # a88 <n>
 132:	00a92023          	sw	a0,0(s2)
    int x=atoi(argv[2]);
 136:	6888                	ld	a0,16(s1)
 138:	00000097          	auipc	ra,0x0
 13c:	256080e7          	jalr	598(ra) # 38e <atoi>
 140:	fca42e23          	sw	a0,-36(s0)
    
    if(n<1){
 144:	00092783          	lw	a5,0(s2)
 148:	08f05163          	blez	a5,1ca <main+0xb8>
        printf("m should be positive\n");
        exit(1);
    }
    if (pipe(pipefd) < 0) {
 14c:	00001517          	auipc	a0,0x1
 150:	94450513          	addi	a0,a0,-1724 # a90 <pipefd>
 154:	00000097          	auipc	ra,0x0
 158:	34a080e7          	jalr	842(ra) # 49e <pipe>
 15c:	08054463          	bltz	a0,1e4 <main+0xd2>
		exit(0);
	}
    

    if(1){
            x=x+getpid();
 160:	00000097          	auipc	ra,0x0
 164:	3ae080e7          	jalr	942(ra) # 50e <getpid>
 168:	fdc42783          	lw	a5,-36(s0)
 16c:	9fa9                	addw	a5,a5,a0
 16e:	fcf42e23          	sw	a5,-36(s0)
            printf("%d: %d\n", getpid(), x);
 172:	00000097          	auipc	ra,0x0
 176:	39c080e7          	jalr	924(ra) # 50e <getpid>
 17a:	85aa                	mv	a1,a0
 17c:	fdc42603          	lw	a2,-36(s0)
 180:	00001517          	auipc	a0,0x1
 184:	87050513          	addi	a0,a0,-1936 # 9f0 <malloc+0x10c>
 188:	00000097          	auipc	ra,0x0
 18c:	69e080e7          	jalr	1694(ra) # 826 <printf>
            if (write(pipefd[1], &x, 4) < 0) {
 190:	4611                	li	a2,4
 192:	fdc40593          	addi	a1,s0,-36
 196:	00001517          	auipc	a0,0x1
 19a:	8fe52503          	lw	a0,-1794(a0) # a94 <pipefd+0x4>
 19e:	00000097          	auipc	ra,0x0
 1a2:	310080e7          	jalr	784(ra) # 4ae <write>
 1a6:	04054c63          	bltz	a0,1fe <main+0xec>
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                n=n-1;
 1aa:	00001717          	auipc	a4,0x1
 1ae:	8de70713          	addi	a4,a4,-1826 # a88 <n>
 1b2:	431c                	lw	a5,0(a4)
 1b4:	37fd                	addiw	a5,a5,-1
 1b6:	c31c                	sw	a5,0(a4)
                pipelining();
 1b8:	00000097          	auipc	ra,0x0
 1bc:	e48080e7          	jalr	-440(ra) # 0 <pipelining>
            }           
    }
    exit(0);
 1c0:	4501                	li	a0,0
 1c2:	00000097          	auipc	ra,0x0
 1c6:	2cc080e7          	jalr	716(ra) # 48e <exit>
        printf("m should be positive\n");
 1ca:	00001517          	auipc	a0,0x1
 1ce:	85650513          	addi	a0,a0,-1962 # a20 <malloc+0x13c>
 1d2:	00000097          	auipc	ra,0x0
 1d6:	654080e7          	jalr	1620(ra) # 826 <printf>
        exit(1);
 1da:	4505                	li	a0,1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	2b2080e7          	jalr	690(ra) # 48e <exit>
		printf("Error: cannot create pipe. Aborting...\n");
 1e4:	00001517          	auipc	a0,0x1
 1e8:	85450513          	addi	a0,a0,-1964 # a38 <malloc+0x154>
 1ec:	00000097          	auipc	ra,0x0
 1f0:	63a080e7          	jalr	1594(ra) # 826 <printf>
		exit(0);
 1f4:	4501                	li	a0,0
 1f6:	00000097          	auipc	ra,0x0
 1fa:	298080e7          	jalr	664(ra) # 48e <exit>
                printf("Error: cannot write. Aborting...\n");
 1fe:	00000517          	auipc	a0,0x0
 202:	7fa50513          	addi	a0,a0,2042 # 9f8 <malloc+0x114>
 206:	00000097          	auipc	ra,0x0
 20a:	620080e7          	jalr	1568(ra) # 826 <printf>
                exit(0);
 20e:	4501                	li	a0,0
 210:	00000097          	auipc	ra,0x0
 214:	27e080e7          	jalr	638(ra) # 48e <exit>

0000000000000218 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 21e:	87aa                	mv	a5,a0
 220:	0585                	addi	a1,a1,1
 222:	0785                	addi	a5,a5,1
 224:	fff5c703          	lbu	a4,-1(a1)
 228:	fee78fa3          	sb	a4,-1(a5)
 22c:	fb75                	bnez	a4,220 <strcpy+0x8>
    ;
  return os;
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret

0000000000000234 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 23a:	00054783          	lbu	a5,0(a0)
 23e:	cb91                	beqz	a5,252 <strcmp+0x1e>
 240:	0005c703          	lbu	a4,0(a1)
 244:	00f71763          	bne	a4,a5,252 <strcmp+0x1e>
    p++, q++;
 248:	0505                	addi	a0,a0,1
 24a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 24c:	00054783          	lbu	a5,0(a0)
 250:	fbe5                	bnez	a5,240 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 252:	0005c503          	lbu	a0,0(a1)
}
 256:	40a7853b          	subw	a0,a5,a0
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret

0000000000000260 <strlen>:

uint
strlen(const char *s)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 266:	00054783          	lbu	a5,0(a0)
 26a:	cf91                	beqz	a5,286 <strlen+0x26>
 26c:	0505                	addi	a0,a0,1
 26e:	87aa                	mv	a5,a0
 270:	4685                	li	a3,1
 272:	9e89                	subw	a3,a3,a0
 274:	00f6853b          	addw	a0,a3,a5
 278:	0785                	addi	a5,a5,1
 27a:	fff7c703          	lbu	a4,-1(a5)
 27e:	fb7d                	bnez	a4,274 <strlen+0x14>
    ;
  return n;
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret
  for(n = 0; s[n]; n++)
 286:	4501                	li	a0,0
 288:	bfe5                	j	280 <strlen+0x20>

000000000000028a <memset>:

void*
memset(void *dst, int c, uint n)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 290:	ce09                	beqz	a2,2aa <memset+0x20>
 292:	87aa                	mv	a5,a0
 294:	fff6071b          	addiw	a4,a2,-1
 298:	1702                	slli	a4,a4,0x20
 29a:	9301                	srli	a4,a4,0x20
 29c:	0705                	addi	a4,a4,1
 29e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2a0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2a4:	0785                	addi	a5,a5,1
 2a6:	fee79de3          	bne	a5,a4,2a0 <memset+0x16>
  }
  return dst;
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret

00000000000002b0 <strchr>:

char*
strchr(const char *s, char c)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e422                	sd	s0,8(sp)
 2b4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2b6:	00054783          	lbu	a5,0(a0)
 2ba:	cb99                	beqz	a5,2d0 <strchr+0x20>
    if(*s == c)
 2bc:	00f58763          	beq	a1,a5,2ca <strchr+0x1a>
  for(; *s; s++)
 2c0:	0505                	addi	a0,a0,1
 2c2:	00054783          	lbu	a5,0(a0)
 2c6:	fbfd                	bnez	a5,2bc <strchr+0xc>
      return (char*)s;
  return 0;
 2c8:	4501                	li	a0,0
}
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
  return 0;
 2d0:	4501                	li	a0,0
 2d2:	bfe5                	j	2ca <strchr+0x1a>

00000000000002d4 <gets>:

char*
gets(char *buf, int max)
{
 2d4:	711d                	addi	sp,sp,-96
 2d6:	ec86                	sd	ra,88(sp)
 2d8:	e8a2                	sd	s0,80(sp)
 2da:	e4a6                	sd	s1,72(sp)
 2dc:	e0ca                	sd	s2,64(sp)
 2de:	fc4e                	sd	s3,56(sp)
 2e0:	f852                	sd	s4,48(sp)
 2e2:	f456                	sd	s5,40(sp)
 2e4:	f05a                	sd	s6,32(sp)
 2e6:	ec5e                	sd	s7,24(sp)
 2e8:	1080                	addi	s0,sp,96
 2ea:	8baa                	mv	s7,a0
 2ec:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ee:	892a                	mv	s2,a0
 2f0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2f2:	4aa9                	li	s5,10
 2f4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2f6:	89a6                	mv	s3,s1
 2f8:	2485                	addiw	s1,s1,1
 2fa:	0344d863          	bge	s1,s4,32a <gets+0x56>
    cc = read(0, &c, 1);
 2fe:	4605                	li	a2,1
 300:	faf40593          	addi	a1,s0,-81
 304:	4501                	li	a0,0
 306:	00000097          	auipc	ra,0x0
 30a:	1a0080e7          	jalr	416(ra) # 4a6 <read>
    if(cc < 1)
 30e:	00a05e63          	blez	a0,32a <gets+0x56>
    buf[i++] = c;
 312:	faf44783          	lbu	a5,-81(s0)
 316:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 31a:	01578763          	beq	a5,s5,328 <gets+0x54>
 31e:	0905                	addi	s2,s2,1
 320:	fd679be3          	bne	a5,s6,2f6 <gets+0x22>
  for(i=0; i+1 < max; ){
 324:	89a6                	mv	s3,s1
 326:	a011                	j	32a <gets+0x56>
 328:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 32a:	99de                	add	s3,s3,s7
 32c:	00098023          	sb	zero,0(s3)
  return buf;
}
 330:	855e                	mv	a0,s7
 332:	60e6                	ld	ra,88(sp)
 334:	6446                	ld	s0,80(sp)
 336:	64a6                	ld	s1,72(sp)
 338:	6906                	ld	s2,64(sp)
 33a:	79e2                	ld	s3,56(sp)
 33c:	7a42                	ld	s4,48(sp)
 33e:	7aa2                	ld	s5,40(sp)
 340:	7b02                	ld	s6,32(sp)
 342:	6be2                	ld	s7,24(sp)
 344:	6125                	addi	sp,sp,96
 346:	8082                	ret

0000000000000348 <stat>:

int
stat(const char *n, struct stat *st)
{
 348:	1101                	addi	sp,sp,-32
 34a:	ec06                	sd	ra,24(sp)
 34c:	e822                	sd	s0,16(sp)
 34e:	e426                	sd	s1,8(sp)
 350:	e04a                	sd	s2,0(sp)
 352:	1000                	addi	s0,sp,32
 354:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 356:	4581                	li	a1,0
 358:	00000097          	auipc	ra,0x0
 35c:	176080e7          	jalr	374(ra) # 4ce <open>
  if(fd < 0)
 360:	02054563          	bltz	a0,38a <stat+0x42>
 364:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 366:	85ca                	mv	a1,s2
 368:	00000097          	auipc	ra,0x0
 36c:	17e080e7          	jalr	382(ra) # 4e6 <fstat>
 370:	892a                	mv	s2,a0
  close(fd);
 372:	8526                	mv	a0,s1
 374:	00000097          	auipc	ra,0x0
 378:	142080e7          	jalr	322(ra) # 4b6 <close>
  return r;
}
 37c:	854a                	mv	a0,s2
 37e:	60e2                	ld	ra,24(sp)
 380:	6442                	ld	s0,16(sp)
 382:	64a2                	ld	s1,8(sp)
 384:	6902                	ld	s2,0(sp)
 386:	6105                	addi	sp,sp,32
 388:	8082                	ret
    return -1;
 38a:	597d                	li	s2,-1
 38c:	bfc5                	j	37c <stat+0x34>

000000000000038e <atoi>:

int
atoi(const char *s)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 394:	00054603          	lbu	a2,0(a0)
 398:	fd06079b          	addiw	a5,a2,-48
 39c:	0ff7f793          	andi	a5,a5,255
 3a0:	4725                	li	a4,9
 3a2:	02f76963          	bltu	a4,a5,3d4 <atoi+0x46>
 3a6:	86aa                	mv	a3,a0
  n = 0;
 3a8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3aa:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3ac:	0685                	addi	a3,a3,1
 3ae:	0025179b          	slliw	a5,a0,0x2
 3b2:	9fa9                	addw	a5,a5,a0
 3b4:	0017979b          	slliw	a5,a5,0x1
 3b8:	9fb1                	addw	a5,a5,a2
 3ba:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3be:	0006c603          	lbu	a2,0(a3)
 3c2:	fd06071b          	addiw	a4,a2,-48
 3c6:	0ff77713          	andi	a4,a4,255
 3ca:	fee5f1e3          	bgeu	a1,a4,3ac <atoi+0x1e>
  return n;
}
 3ce:	6422                	ld	s0,8(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret
  n = 0;
 3d4:	4501                	li	a0,0
 3d6:	bfe5                	j	3ce <atoi+0x40>

00000000000003d8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e422                	sd	s0,8(sp)
 3dc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3de:	02b57663          	bgeu	a0,a1,40a <memmove+0x32>
    while(n-- > 0)
 3e2:	02c05163          	blez	a2,404 <memmove+0x2c>
 3e6:	fff6079b          	addiw	a5,a2,-1
 3ea:	1782                	slli	a5,a5,0x20
 3ec:	9381                	srli	a5,a5,0x20
 3ee:	0785                	addi	a5,a5,1
 3f0:	97aa                	add	a5,a5,a0
  dst = vdst;
 3f2:	872a                	mv	a4,a0
      *dst++ = *src++;
 3f4:	0585                	addi	a1,a1,1
 3f6:	0705                	addi	a4,a4,1
 3f8:	fff5c683          	lbu	a3,-1(a1)
 3fc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 400:	fee79ae3          	bne	a5,a4,3f4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 404:	6422                	ld	s0,8(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret
    dst += n;
 40a:	00c50733          	add	a4,a0,a2
    src += n;
 40e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 410:	fec05ae3          	blez	a2,404 <memmove+0x2c>
 414:	fff6079b          	addiw	a5,a2,-1
 418:	1782                	slli	a5,a5,0x20
 41a:	9381                	srli	a5,a5,0x20
 41c:	fff7c793          	not	a5,a5
 420:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 422:	15fd                	addi	a1,a1,-1
 424:	177d                	addi	a4,a4,-1
 426:	0005c683          	lbu	a3,0(a1)
 42a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 42e:	fee79ae3          	bne	a5,a4,422 <memmove+0x4a>
 432:	bfc9                	j	404 <memmove+0x2c>

0000000000000434 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 434:	1141                	addi	sp,sp,-16
 436:	e422                	sd	s0,8(sp)
 438:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 43a:	ca05                	beqz	a2,46a <memcmp+0x36>
 43c:	fff6069b          	addiw	a3,a2,-1
 440:	1682                	slli	a3,a3,0x20
 442:	9281                	srli	a3,a3,0x20
 444:	0685                	addi	a3,a3,1
 446:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 448:	00054783          	lbu	a5,0(a0)
 44c:	0005c703          	lbu	a4,0(a1)
 450:	00e79863          	bne	a5,a4,460 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 454:	0505                	addi	a0,a0,1
    p2++;
 456:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 458:	fed518e3          	bne	a0,a3,448 <memcmp+0x14>
  }
  return 0;
 45c:	4501                	li	a0,0
 45e:	a019                	j	464 <memcmp+0x30>
      return *p1 - *p2;
 460:	40e7853b          	subw	a0,a5,a4
}
 464:	6422                	ld	s0,8(sp)
 466:	0141                	addi	sp,sp,16
 468:	8082                	ret
  return 0;
 46a:	4501                	li	a0,0
 46c:	bfe5                	j	464 <memcmp+0x30>

000000000000046e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 46e:	1141                	addi	sp,sp,-16
 470:	e406                	sd	ra,8(sp)
 472:	e022                	sd	s0,0(sp)
 474:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 476:	00000097          	auipc	ra,0x0
 47a:	f62080e7          	jalr	-158(ra) # 3d8 <memmove>
}
 47e:	60a2                	ld	ra,8(sp)
 480:	6402                	ld	s0,0(sp)
 482:	0141                	addi	sp,sp,16
 484:	8082                	ret

0000000000000486 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 486:	4885                	li	a7,1
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <exit>:
.global exit
exit:
 li a7, SYS_exit
 48e:	4889                	li	a7,2
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <wait>:
.global wait
wait:
 li a7, SYS_wait
 496:	488d                	li	a7,3
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 49e:	4891                	li	a7,4
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <read>:
.global read
read:
 li a7, SYS_read
 4a6:	4895                	li	a7,5
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <write>:
.global write
write:
 li a7, SYS_write
 4ae:	48c1                	li	a7,16
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <close>:
.global close
close:
 li a7, SYS_close
 4b6:	48d5                	li	a7,21
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <kill>:
.global kill
kill:
 li a7, SYS_kill
 4be:	4899                	li	a7,6
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c6:	489d                	li	a7,7
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <open>:
.global open
open:
 li a7, SYS_open
 4ce:	48bd                	li	a7,15
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d6:	48c5                	li	a7,17
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4de:	48c9                	li	a7,18
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e6:	48a1                	li	a7,8
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <link>:
.global link
link:
 li a7, SYS_link
 4ee:	48cd                	li	a7,19
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f6:	48d1                	li	a7,20
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4fe:	48a5                	li	a7,9
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <dup>:
.global dup
dup:
 li a7, SYS_dup
 506:	48a9                	li	a7,10
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 50e:	48ad                	li	a7,11
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 516:	48b1                	li	a7,12
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 51e:	48b5                	li	a7,13
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 526:	48b9                	li	a7,14
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 52e:	48d9                	li	a7,22
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <yield>:
.global yield
yield:
 li a7, SYS_yield
 536:	48dd                	li	a7,23
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 53e:	48e1                	li	a7,24
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 546:	48e5                	li	a7,25
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 54e:	1101                	addi	sp,sp,-32
 550:	ec06                	sd	ra,24(sp)
 552:	e822                	sd	s0,16(sp)
 554:	1000                	addi	s0,sp,32
 556:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 55a:	4605                	li	a2,1
 55c:	fef40593          	addi	a1,s0,-17
 560:	00000097          	auipc	ra,0x0
 564:	f4e080e7          	jalr	-178(ra) # 4ae <write>
}
 568:	60e2                	ld	ra,24(sp)
 56a:	6442                	ld	s0,16(sp)
 56c:	6105                	addi	sp,sp,32
 56e:	8082                	ret

0000000000000570 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 570:	7139                	addi	sp,sp,-64
 572:	fc06                	sd	ra,56(sp)
 574:	f822                	sd	s0,48(sp)
 576:	f426                	sd	s1,40(sp)
 578:	f04a                	sd	s2,32(sp)
 57a:	ec4e                	sd	s3,24(sp)
 57c:	0080                	addi	s0,sp,64
 57e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 580:	c299                	beqz	a3,586 <printint+0x16>
 582:	0805c863          	bltz	a1,612 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 586:	2581                	sext.w	a1,a1
  neg = 0;
 588:	4881                	li	a7,0
 58a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 58e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 590:	2601                	sext.w	a2,a2
 592:	00000517          	auipc	a0,0x0
 596:	4d650513          	addi	a0,a0,1238 # a68 <digits>
 59a:	883a                	mv	a6,a4
 59c:	2705                	addiw	a4,a4,1
 59e:	02c5f7bb          	remuw	a5,a1,a2
 5a2:	1782                	slli	a5,a5,0x20
 5a4:	9381                	srli	a5,a5,0x20
 5a6:	97aa                	add	a5,a5,a0
 5a8:	0007c783          	lbu	a5,0(a5)
 5ac:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5b0:	0005879b          	sext.w	a5,a1
 5b4:	02c5d5bb          	divuw	a1,a1,a2
 5b8:	0685                	addi	a3,a3,1
 5ba:	fec7f0e3          	bgeu	a5,a2,59a <printint+0x2a>
  if(neg)
 5be:	00088b63          	beqz	a7,5d4 <printint+0x64>
    buf[i++] = '-';
 5c2:	fd040793          	addi	a5,s0,-48
 5c6:	973e                	add	a4,a4,a5
 5c8:	02d00793          	li	a5,45
 5cc:	fef70823          	sb	a5,-16(a4)
 5d0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5d4:	02e05863          	blez	a4,604 <printint+0x94>
 5d8:	fc040793          	addi	a5,s0,-64
 5dc:	00e78933          	add	s2,a5,a4
 5e0:	fff78993          	addi	s3,a5,-1
 5e4:	99ba                	add	s3,s3,a4
 5e6:	377d                	addiw	a4,a4,-1
 5e8:	1702                	slli	a4,a4,0x20
 5ea:	9301                	srli	a4,a4,0x20
 5ec:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5f0:	fff94583          	lbu	a1,-1(s2)
 5f4:	8526                	mv	a0,s1
 5f6:	00000097          	auipc	ra,0x0
 5fa:	f58080e7          	jalr	-168(ra) # 54e <putc>
  while(--i >= 0)
 5fe:	197d                	addi	s2,s2,-1
 600:	ff3918e3          	bne	s2,s3,5f0 <printint+0x80>
}
 604:	70e2                	ld	ra,56(sp)
 606:	7442                	ld	s0,48(sp)
 608:	74a2                	ld	s1,40(sp)
 60a:	7902                	ld	s2,32(sp)
 60c:	69e2                	ld	s3,24(sp)
 60e:	6121                	addi	sp,sp,64
 610:	8082                	ret
    x = -xx;
 612:	40b005bb          	negw	a1,a1
    neg = 1;
 616:	4885                	li	a7,1
    x = -xx;
 618:	bf8d                	j	58a <printint+0x1a>

000000000000061a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 61a:	7119                	addi	sp,sp,-128
 61c:	fc86                	sd	ra,120(sp)
 61e:	f8a2                	sd	s0,112(sp)
 620:	f4a6                	sd	s1,104(sp)
 622:	f0ca                	sd	s2,96(sp)
 624:	ecce                	sd	s3,88(sp)
 626:	e8d2                	sd	s4,80(sp)
 628:	e4d6                	sd	s5,72(sp)
 62a:	e0da                	sd	s6,64(sp)
 62c:	fc5e                	sd	s7,56(sp)
 62e:	f862                	sd	s8,48(sp)
 630:	f466                	sd	s9,40(sp)
 632:	f06a                	sd	s10,32(sp)
 634:	ec6e                	sd	s11,24(sp)
 636:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 638:	0005c903          	lbu	s2,0(a1)
 63c:	18090f63          	beqz	s2,7da <vprintf+0x1c0>
 640:	8aaa                	mv	s5,a0
 642:	8b32                	mv	s6,a2
 644:	00158493          	addi	s1,a1,1
  state = 0;
 648:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 64a:	02500a13          	li	s4,37
      if(c == 'd'){
 64e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 652:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 656:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 65a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65e:	00000b97          	auipc	s7,0x0
 662:	40ab8b93          	addi	s7,s7,1034 # a68 <digits>
 666:	a839                	j	684 <vprintf+0x6a>
        putc(fd, c);
 668:	85ca                	mv	a1,s2
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	ee2080e7          	jalr	-286(ra) # 54e <putc>
 674:	a019                	j	67a <vprintf+0x60>
    } else if(state == '%'){
 676:	01498f63          	beq	s3,s4,694 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 67a:	0485                	addi	s1,s1,1
 67c:	fff4c903          	lbu	s2,-1(s1)
 680:	14090d63          	beqz	s2,7da <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 684:	0009079b          	sext.w	a5,s2
    if(state == 0){
 688:	fe0997e3          	bnez	s3,676 <vprintf+0x5c>
      if(c == '%'){
 68c:	fd479ee3          	bne	a5,s4,668 <vprintf+0x4e>
        state = '%';
 690:	89be                	mv	s3,a5
 692:	b7e5                	j	67a <vprintf+0x60>
      if(c == 'd'){
 694:	05878063          	beq	a5,s8,6d4 <vprintf+0xba>
      } else if(c == 'l') {
 698:	05978c63          	beq	a5,s9,6f0 <vprintf+0xd6>
      } else if(c == 'x') {
 69c:	07a78863          	beq	a5,s10,70c <vprintf+0xf2>
      } else if(c == 'p') {
 6a0:	09b78463          	beq	a5,s11,728 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6a4:	07300713          	li	a4,115
 6a8:	0ce78663          	beq	a5,a4,774 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ac:	06300713          	li	a4,99
 6b0:	0ee78e63          	beq	a5,a4,7ac <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6b4:	11478863          	beq	a5,s4,7c4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6b8:	85d2                	mv	a1,s4
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e92080e7          	jalr	-366(ra) # 54e <putc>
        putc(fd, c);
 6c4:	85ca                	mv	a1,s2
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e86080e7          	jalr	-378(ra) # 54e <putc>
      }
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b765                	j	67a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6d4:	008b0913          	addi	s2,s6,8
 6d8:	4685                	li	a3,1
 6da:	4629                	li	a2,10
 6dc:	000b2583          	lw	a1,0(s6)
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	e8e080e7          	jalr	-370(ra) # 570 <printint>
 6ea:	8b4a                	mv	s6,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b771                	j	67a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f0:	008b0913          	addi	s2,s6,8
 6f4:	4681                	li	a3,0
 6f6:	4629                	li	a2,10
 6f8:	000b2583          	lw	a1,0(s6)
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	e72080e7          	jalr	-398(ra) # 570 <printint>
 706:	8b4a                	mv	s6,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	bf85                	j	67a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 70c:	008b0913          	addi	s2,s6,8
 710:	4681                	li	a3,0
 712:	4641                	li	a2,16
 714:	000b2583          	lw	a1,0(s6)
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	e56080e7          	jalr	-426(ra) # 570 <printint>
 722:	8b4a                	mv	s6,s2
      state = 0;
 724:	4981                	li	s3,0
 726:	bf91                	j	67a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 728:	008b0793          	addi	a5,s6,8
 72c:	f8f43423          	sd	a5,-120(s0)
 730:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 734:	03000593          	li	a1,48
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	e14080e7          	jalr	-492(ra) # 54e <putc>
  putc(fd, 'x');
 742:	85ea                	mv	a1,s10
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	e08080e7          	jalr	-504(ra) # 54e <putc>
 74e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 750:	03c9d793          	srli	a5,s3,0x3c
 754:	97de                	add	a5,a5,s7
 756:	0007c583          	lbu	a1,0(a5)
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	df2080e7          	jalr	-526(ra) # 54e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 764:	0992                	slli	s3,s3,0x4
 766:	397d                	addiw	s2,s2,-1
 768:	fe0914e3          	bnez	s2,750 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 76c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 770:	4981                	li	s3,0
 772:	b721                	j	67a <vprintf+0x60>
        s = va_arg(ap, char*);
 774:	008b0993          	addi	s3,s6,8
 778:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 77c:	02090163          	beqz	s2,79e <vprintf+0x184>
        while(*s != 0){
 780:	00094583          	lbu	a1,0(s2)
 784:	c9a1                	beqz	a1,7d4 <vprintf+0x1ba>
          putc(fd, *s);
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	dc6080e7          	jalr	-570(ra) # 54e <putc>
          s++;
 790:	0905                	addi	s2,s2,1
        while(*s != 0){
 792:	00094583          	lbu	a1,0(s2)
 796:	f9e5                	bnez	a1,786 <vprintf+0x16c>
        s = va_arg(ap, char*);
 798:	8b4e                	mv	s6,s3
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bdf9                	j	67a <vprintf+0x60>
          s = "(null)";
 79e:	00000917          	auipc	s2,0x0
 7a2:	2c290913          	addi	s2,s2,706 # a60 <malloc+0x17c>
        while(*s != 0){
 7a6:	02800593          	li	a1,40
 7aa:	bff1                	j	786 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7ac:	008b0913          	addi	s2,s6,8
 7b0:	000b4583          	lbu	a1,0(s6)
 7b4:	8556                	mv	a0,s5
 7b6:	00000097          	auipc	ra,0x0
 7ba:	d98080e7          	jalr	-616(ra) # 54e <putc>
 7be:	8b4a                	mv	s6,s2
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	bd65                	j	67a <vprintf+0x60>
        putc(fd, c);
 7c4:	85d2                	mv	a1,s4
 7c6:	8556                	mv	a0,s5
 7c8:	00000097          	auipc	ra,0x0
 7cc:	d86080e7          	jalr	-634(ra) # 54e <putc>
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	b565                	j	67a <vprintf+0x60>
        s = va_arg(ap, char*);
 7d4:	8b4e                	mv	s6,s3
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	b54d                	j	67a <vprintf+0x60>
    }
  }
}
 7da:	70e6                	ld	ra,120(sp)
 7dc:	7446                	ld	s0,112(sp)
 7de:	74a6                	ld	s1,104(sp)
 7e0:	7906                	ld	s2,96(sp)
 7e2:	69e6                	ld	s3,88(sp)
 7e4:	6a46                	ld	s4,80(sp)
 7e6:	6aa6                	ld	s5,72(sp)
 7e8:	6b06                	ld	s6,64(sp)
 7ea:	7be2                	ld	s7,56(sp)
 7ec:	7c42                	ld	s8,48(sp)
 7ee:	7ca2                	ld	s9,40(sp)
 7f0:	7d02                	ld	s10,32(sp)
 7f2:	6de2                	ld	s11,24(sp)
 7f4:	6109                	addi	sp,sp,128
 7f6:	8082                	ret

00000000000007f8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7f8:	715d                	addi	sp,sp,-80
 7fa:	ec06                	sd	ra,24(sp)
 7fc:	e822                	sd	s0,16(sp)
 7fe:	1000                	addi	s0,sp,32
 800:	e010                	sd	a2,0(s0)
 802:	e414                	sd	a3,8(s0)
 804:	e818                	sd	a4,16(s0)
 806:	ec1c                	sd	a5,24(s0)
 808:	03043023          	sd	a6,32(s0)
 80c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 810:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 814:	8622                	mv	a2,s0
 816:	00000097          	auipc	ra,0x0
 81a:	e04080e7          	jalr	-508(ra) # 61a <vprintf>
}
 81e:	60e2                	ld	ra,24(sp)
 820:	6442                	ld	s0,16(sp)
 822:	6161                	addi	sp,sp,80
 824:	8082                	ret

0000000000000826 <printf>:

void
printf(const char *fmt, ...)
{
 826:	711d                	addi	sp,sp,-96
 828:	ec06                	sd	ra,24(sp)
 82a:	e822                	sd	s0,16(sp)
 82c:	1000                	addi	s0,sp,32
 82e:	e40c                	sd	a1,8(s0)
 830:	e810                	sd	a2,16(s0)
 832:	ec14                	sd	a3,24(s0)
 834:	f018                	sd	a4,32(s0)
 836:	f41c                	sd	a5,40(s0)
 838:	03043823          	sd	a6,48(s0)
 83c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 840:	00840613          	addi	a2,s0,8
 844:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 848:	85aa                	mv	a1,a0
 84a:	4505                	li	a0,1
 84c:	00000097          	auipc	ra,0x0
 850:	dce080e7          	jalr	-562(ra) # 61a <vprintf>
}
 854:	60e2                	ld	ra,24(sp)
 856:	6442                	ld	s0,16(sp)
 858:	6125                	addi	sp,sp,96
 85a:	8082                	ret

000000000000085c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 85c:	1141                	addi	sp,sp,-16
 85e:	e422                	sd	s0,8(sp)
 860:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 862:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 866:	00000797          	auipc	a5,0x0
 86a:	2327b783          	ld	a5,562(a5) # a98 <freep>
 86e:	a805                	j	89e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 870:	4618                	lw	a4,8(a2)
 872:	9db9                	addw	a1,a1,a4
 874:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 878:	6398                	ld	a4,0(a5)
 87a:	6318                	ld	a4,0(a4)
 87c:	fee53823          	sd	a4,-16(a0)
 880:	a091                	j	8c4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 882:	ff852703          	lw	a4,-8(a0)
 886:	9e39                	addw	a2,a2,a4
 888:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 88a:	ff053703          	ld	a4,-16(a0)
 88e:	e398                	sd	a4,0(a5)
 890:	a099                	j	8d6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 892:	6398                	ld	a4,0(a5)
 894:	00e7e463          	bltu	a5,a4,89c <free+0x40>
 898:	00e6ea63          	bltu	a3,a4,8ac <free+0x50>
{
 89c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89e:	fed7fae3          	bgeu	a5,a3,892 <free+0x36>
 8a2:	6398                	ld	a4,0(a5)
 8a4:	00e6e463          	bltu	a3,a4,8ac <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a8:	fee7eae3          	bltu	a5,a4,89c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8ac:	ff852583          	lw	a1,-8(a0)
 8b0:	6390                	ld	a2,0(a5)
 8b2:	02059713          	slli	a4,a1,0x20
 8b6:	9301                	srli	a4,a4,0x20
 8b8:	0712                	slli	a4,a4,0x4
 8ba:	9736                	add	a4,a4,a3
 8bc:	fae60ae3          	beq	a2,a4,870 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c4:	4790                	lw	a2,8(a5)
 8c6:	02061713          	slli	a4,a2,0x20
 8ca:	9301                	srli	a4,a4,0x20
 8cc:	0712                	slli	a4,a4,0x4
 8ce:	973e                	add	a4,a4,a5
 8d0:	fae689e3          	beq	a3,a4,882 <free+0x26>
  } else
    p->s.ptr = bp;
 8d4:	e394                	sd	a3,0(a5)
  freep = p;
 8d6:	00000717          	auipc	a4,0x0
 8da:	1cf73123          	sd	a5,450(a4) # a98 <freep>
}
 8de:	6422                	ld	s0,8(sp)
 8e0:	0141                	addi	sp,sp,16
 8e2:	8082                	ret

00000000000008e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e4:	7139                	addi	sp,sp,-64
 8e6:	fc06                	sd	ra,56(sp)
 8e8:	f822                	sd	s0,48(sp)
 8ea:	f426                	sd	s1,40(sp)
 8ec:	f04a                	sd	s2,32(sp)
 8ee:	ec4e                	sd	s3,24(sp)
 8f0:	e852                	sd	s4,16(sp)
 8f2:	e456                	sd	s5,8(sp)
 8f4:	e05a                	sd	s6,0(sp)
 8f6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f8:	02051493          	slli	s1,a0,0x20
 8fc:	9081                	srli	s1,s1,0x20
 8fe:	04bd                	addi	s1,s1,15
 900:	8091                	srli	s1,s1,0x4
 902:	0014899b          	addiw	s3,s1,1
 906:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 908:	00000517          	auipc	a0,0x0
 90c:	19053503          	ld	a0,400(a0) # a98 <freep>
 910:	c515                	beqz	a0,93c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 912:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 914:	4798                	lw	a4,8(a5)
 916:	02977f63          	bgeu	a4,s1,954 <malloc+0x70>
 91a:	8a4e                	mv	s4,s3
 91c:	0009871b          	sext.w	a4,s3
 920:	6685                	lui	a3,0x1
 922:	00d77363          	bgeu	a4,a3,928 <malloc+0x44>
 926:	6a05                	lui	s4,0x1
 928:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 930:	00000917          	auipc	s2,0x0
 934:	16890913          	addi	s2,s2,360 # a98 <freep>
  if(p == (char*)-1)
 938:	5afd                	li	s5,-1
 93a:	a88d                	j	9ac <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 93c:	00000797          	auipc	a5,0x0
 940:	16478793          	addi	a5,a5,356 # aa0 <base>
 944:	00000717          	auipc	a4,0x0
 948:	14f73a23          	sd	a5,340(a4) # a98 <freep>
 94c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 94e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 952:	b7e1                	j	91a <malloc+0x36>
      if(p->s.size == nunits)
 954:	02e48b63          	beq	s1,a4,98a <malloc+0xa6>
        p->s.size -= nunits;
 958:	4137073b          	subw	a4,a4,s3
 95c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 95e:	1702                	slli	a4,a4,0x20
 960:	9301                	srli	a4,a4,0x20
 962:	0712                	slli	a4,a4,0x4
 964:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 966:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96a:	00000717          	auipc	a4,0x0
 96e:	12a73723          	sd	a0,302(a4) # a98 <freep>
      return (void*)(p + 1);
 972:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 976:	70e2                	ld	ra,56(sp)
 978:	7442                	ld	s0,48(sp)
 97a:	74a2                	ld	s1,40(sp)
 97c:	7902                	ld	s2,32(sp)
 97e:	69e2                	ld	s3,24(sp)
 980:	6a42                	ld	s4,16(sp)
 982:	6aa2                	ld	s5,8(sp)
 984:	6b02                	ld	s6,0(sp)
 986:	6121                	addi	sp,sp,64
 988:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 98a:	6398                	ld	a4,0(a5)
 98c:	e118                	sd	a4,0(a0)
 98e:	bff1                	j	96a <malloc+0x86>
  hp->s.size = nu;
 990:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 994:	0541                	addi	a0,a0,16
 996:	00000097          	auipc	ra,0x0
 99a:	ec6080e7          	jalr	-314(ra) # 85c <free>
  return freep;
 99e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a2:	d971                	beqz	a0,976 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a6:	4798                	lw	a4,8(a5)
 9a8:	fa9776e3          	bgeu	a4,s1,954 <malloc+0x70>
    if(p == freep)
 9ac:	00093703          	ld	a4,0(s2)
 9b0:	853e                	mv	a0,a5
 9b2:	fef719e3          	bne	a4,a5,9a4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9b6:	8552                	mv	a0,s4
 9b8:	00000097          	auipc	ra,0x0
 9bc:	b5e080e7          	jalr	-1186(ra) # 516 <sbrk>
  if(p == (char*)-1)
 9c0:	fd5518e3          	bne	a0,s5,990 <malloc+0xac>
        return 0;
 9c4:	4501                	li	a0,0
 9c6:	bf45                	j	976 <malloc+0x92>
