
_thread3b:     file format elf32-i386


Disassembly of section .text:

00000000 <f>:
#include"types.h"
#include"user.h"

int shared = 1;

void f(void) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  while(shared<10000000) shared++;
   6:	eb 0d                	jmp    15 <f+0x15>
   8:	a1 68 0b 00 00       	mov    0xb68,%eax
   d:	83 c0 01             	add    $0x1,%eax
  10:	a3 68 0b 00 00       	mov    %eax,0xb68
  15:	a1 68 0b 00 00       	mov    0xb68,%eax
  1a:	3d 7f 96 98 00       	cmp    $0x98967f,%eax
  1f:	7e e7                	jle    8 <f+0x8>
  printf(1,"Done looping\n");
  21:	c7 44 24 04 c0 08 00 	movl   $0x8c0,0x4(%esp)
  28:	00 
  29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  30:	e8 bf 04 00 00       	call   4f4 <printf>

  // a little artificial wait to force the race condition to happen
  int i=1000000000;
  35:	c7 45 f4 00 ca 9a 3b 	movl   $0x3b9aca00,-0xc(%ebp)
  while(i--);
  3c:	90                   	nop
  3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  40:	8d 50 ff             	lea    -0x1(%eax),%edx
  43:	89 55 f4             	mov    %edx,-0xc(%ebp)
  46:	85 c0                	test   %eax,%eax
  48:	75 f3                	jne    3d <f+0x3d>
}
  4a:	c9                   	leave  
  4b:	c3                   	ret    

0000004c <main>:

int main(int argc, char** argv) {
  4c:	55                   	push   %ebp
  4d:	89 e5                	mov    %esp,%ebp
  4f:	83 e4 f0             	and    $0xfffffff0,%esp
  52:	83 ec 20             	sub    $0x20,%esp
  thread_create(f);
  55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  5c:	e8 b0 02 00 00       	call   311 <thread_create>
  thread_create(f);
  61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  68:	e8 a4 02 00 00       	call   311 <thread_create>
  
  int last = shared;
  6d:	a1 68 0b 00 00       	mov    0xb68,%eax
  72:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  while(shared<10000000) {
  76:	eb 14                	jmp    8c <main+0x40>
    if(last!=shared) {
  78:	a1 68 0b 00 00       	mov    0xb68,%eax
  7d:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  81:	74 09                	je     8c <main+0x40>
      last = shared;
  83:	a1 68 0b 00 00       	mov    0xb68,%eax
  88:	89 44 24 1c          	mov    %eax,0x1c(%esp)
int main(int argc, char** argv) {
  thread_create(f);
  thread_create(f);
  
  int last = shared;
  while(shared<10000000) {
  8c:	a1 68 0b 00 00       	mov    0xb68,%eax
  91:	3d 7f 96 98 00       	cmp    $0x98967f,%eax
  96:	7e e0                	jle    78 <main+0x2c>
    if(last!=shared) {
      last = shared;
//      printf(1,"shared = %d\n",last);
    }
  }
  printf(1,"Main is done!\n"); 
  98:	c7 44 24 04 ce 08 00 	movl   $0x8ce,0x4(%esp)
  9f:	00 
  a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a7:	e8 48 04 00 00       	call   4f4 <printf>

  exit();
  ac:	e8 ab 02 00 00       	call   35c <exit>

000000b1 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  b1:	55                   	push   %ebp
  b2:	89 e5                	mov    %esp,%ebp
  b4:	57                   	push   %edi
  b5:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  b9:	8b 55 10             	mov    0x10(%ebp),%edx
  bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  bf:	89 cb                	mov    %ecx,%ebx
  c1:	89 df                	mov    %ebx,%edi
  c3:	89 d1                	mov    %edx,%ecx
  c5:	fc                   	cld    
  c6:	f3 aa                	rep stos %al,%es:(%edi)
  c8:	89 ca                	mov    %ecx,%edx
  ca:	89 fb                	mov    %edi,%ebx
  cc:	89 5d 08             	mov    %ebx,0x8(%ebp)
  cf:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  d2:	5b                   	pop    %ebx
  d3:	5f                   	pop    %edi
  d4:	5d                   	pop    %ebp
  d5:	c3                   	ret    

000000d6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  d6:	55                   	push   %ebp
  d7:	89 e5                	mov    %esp,%ebp
  d9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  dc:	8b 45 08             	mov    0x8(%ebp),%eax
  df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  e2:	90                   	nop
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	8d 50 01             	lea    0x1(%eax),%edx
  e9:	89 55 08             	mov    %edx,0x8(%ebp)
  ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  f2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  f5:	0f b6 12             	movzbl (%edx),%edx
  f8:	88 10                	mov    %dl,(%eax)
  fa:	0f b6 00             	movzbl (%eax),%eax
  fd:	84 c0                	test   %al,%al
  ff:	75 e2                	jne    e3 <strcpy+0xd>
    ;
  return os;
 101:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 104:	c9                   	leave  
 105:	c3                   	ret    

00000106 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 106:	55                   	push   %ebp
 107:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 109:	eb 08                	jmp    113 <strcmp+0xd>
    p++, q++;
 10b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 10f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 113:	8b 45 08             	mov    0x8(%ebp),%eax
 116:	0f b6 00             	movzbl (%eax),%eax
 119:	84 c0                	test   %al,%al
 11b:	74 10                	je     12d <strcmp+0x27>
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	0f b6 10             	movzbl (%eax),%edx
 123:	8b 45 0c             	mov    0xc(%ebp),%eax
 126:	0f b6 00             	movzbl (%eax),%eax
 129:	38 c2                	cmp    %al,%dl
 12b:	74 de                	je     10b <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 12d:	8b 45 08             	mov    0x8(%ebp),%eax
 130:	0f b6 00             	movzbl (%eax),%eax
 133:	0f b6 d0             	movzbl %al,%edx
 136:	8b 45 0c             	mov    0xc(%ebp),%eax
 139:	0f b6 00             	movzbl (%eax),%eax
 13c:	0f b6 c0             	movzbl %al,%eax
 13f:	29 c2                	sub    %eax,%edx
 141:	89 d0                	mov    %edx,%eax
}
 143:	5d                   	pop    %ebp
 144:	c3                   	ret    

00000145 <strlen>:

uint
strlen(char *s)
{
 145:	55                   	push   %ebp
 146:	89 e5                	mov    %esp,%ebp
 148:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 14b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 152:	eb 04                	jmp    158 <strlen+0x13>
 154:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 158:	8b 55 fc             	mov    -0x4(%ebp),%edx
 15b:	8b 45 08             	mov    0x8(%ebp),%eax
 15e:	01 d0                	add    %edx,%eax
 160:	0f b6 00             	movzbl (%eax),%eax
 163:	84 c0                	test   %al,%al
 165:	75 ed                	jne    154 <strlen+0xf>
    ;
  return n;
 167:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 16a:	c9                   	leave  
 16b:	c3                   	ret    

0000016c <memset>:

void*
memset(void *dst, int c, uint n)
{
 16c:	55                   	push   %ebp
 16d:	89 e5                	mov    %esp,%ebp
 16f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 172:	8b 45 10             	mov    0x10(%ebp),%eax
 175:	89 44 24 08          	mov    %eax,0x8(%esp)
 179:	8b 45 0c             	mov    0xc(%ebp),%eax
 17c:	89 44 24 04          	mov    %eax,0x4(%esp)
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	89 04 24             	mov    %eax,(%esp)
 186:	e8 26 ff ff ff       	call   b1 <stosb>
  return dst;
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 18e:	c9                   	leave  
 18f:	c3                   	ret    

00000190 <strchr>:

char*
strchr(const char *s, char c)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	83 ec 04             	sub    $0x4,%esp
 196:	8b 45 0c             	mov    0xc(%ebp),%eax
 199:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 19c:	eb 14                	jmp    1b2 <strchr+0x22>
    if(*s == c)
 19e:	8b 45 08             	mov    0x8(%ebp),%eax
 1a1:	0f b6 00             	movzbl (%eax),%eax
 1a4:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1a7:	75 05                	jne    1ae <strchr+0x1e>
      return (char*)s;
 1a9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ac:	eb 13                	jmp    1c1 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1ae:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b2:	8b 45 08             	mov    0x8(%ebp),%eax
 1b5:	0f b6 00             	movzbl (%eax),%eax
 1b8:	84 c0                	test   %al,%al
 1ba:	75 e2                	jne    19e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1c1:	c9                   	leave  
 1c2:	c3                   	ret    

000001c3 <gets>:

char*
gets(char *buf, int max)
{
 1c3:	55                   	push   %ebp
 1c4:	89 e5                	mov    %esp,%ebp
 1c6:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1d0:	eb 4c                	jmp    21e <gets+0x5b>
    cc = read(0, &c, 1);
 1d2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1d9:	00 
 1da:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1dd:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1e8:	e8 87 01 00 00       	call   374 <read>
 1ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1f4:	7f 02                	jg     1f8 <gets+0x35>
      break;
 1f6:	eb 31                	jmp    229 <gets+0x66>
    buf[i++] = c;
 1f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fb:	8d 50 01             	lea    0x1(%eax),%edx
 1fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
 201:	89 c2                	mov    %eax,%edx
 203:	8b 45 08             	mov    0x8(%ebp),%eax
 206:	01 c2                	add    %eax,%edx
 208:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 20c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 20e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 212:	3c 0a                	cmp    $0xa,%al
 214:	74 13                	je     229 <gets+0x66>
 216:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 21a:	3c 0d                	cmp    $0xd,%al
 21c:	74 0b                	je     229 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 221:	83 c0 01             	add    $0x1,%eax
 224:	3b 45 0c             	cmp    0xc(%ebp),%eax
 227:	7c a9                	jl     1d2 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 229:	8b 55 f4             	mov    -0xc(%ebp),%edx
 22c:	8b 45 08             	mov    0x8(%ebp),%eax
 22f:	01 d0                	add    %edx,%eax
 231:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 234:	8b 45 08             	mov    0x8(%ebp),%eax
}
 237:	c9                   	leave  
 238:	c3                   	ret    

00000239 <stat>:

int
stat(char *n, struct stat *st)
{
 239:	55                   	push   %ebp
 23a:	89 e5                	mov    %esp,%ebp
 23c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 246:	00 
 247:	8b 45 08             	mov    0x8(%ebp),%eax
 24a:	89 04 24             	mov    %eax,(%esp)
 24d:	e8 4a 01 00 00       	call   39c <open>
 252:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 259:	79 07                	jns    262 <stat+0x29>
    return -1;
 25b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 260:	eb 23                	jmp    285 <stat+0x4c>
  r = fstat(fd, st);
 262:	8b 45 0c             	mov    0xc(%ebp),%eax
 265:	89 44 24 04          	mov    %eax,0x4(%esp)
 269:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26c:	89 04 24             	mov    %eax,(%esp)
 26f:	e8 40 01 00 00       	call   3b4 <fstat>
 274:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 277:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27a:	89 04 24             	mov    %eax,(%esp)
 27d:	e8 02 01 00 00       	call   384 <close>
  return r;
 282:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 285:	c9                   	leave  
 286:	c3                   	ret    

00000287 <atoi>:

int
atoi(const char *s)
{
 287:	55                   	push   %ebp
 288:	89 e5                	mov    %esp,%ebp
 28a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 28d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 294:	eb 25                	jmp    2bb <atoi+0x34>
    n = n*10 + *s++ - '0';
 296:	8b 55 fc             	mov    -0x4(%ebp),%edx
 299:	89 d0                	mov    %edx,%eax
 29b:	c1 e0 02             	shl    $0x2,%eax
 29e:	01 d0                	add    %edx,%eax
 2a0:	01 c0                	add    %eax,%eax
 2a2:	89 c1                	mov    %eax,%ecx
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
 2a7:	8d 50 01             	lea    0x1(%eax),%edx
 2aa:	89 55 08             	mov    %edx,0x8(%ebp)
 2ad:	0f b6 00             	movzbl (%eax),%eax
 2b0:	0f be c0             	movsbl %al,%eax
 2b3:	01 c8                	add    %ecx,%eax
 2b5:	83 e8 30             	sub    $0x30,%eax
 2b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	0f b6 00             	movzbl (%eax),%eax
 2c1:	3c 2f                	cmp    $0x2f,%al
 2c3:	7e 0a                	jle    2cf <atoi+0x48>
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
 2c8:	0f b6 00             	movzbl (%eax),%eax
 2cb:	3c 39                	cmp    $0x39,%al
 2cd:	7e c7                	jle    296 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2d2:	c9                   	leave  
 2d3:	c3                   	ret    

000002d4 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2d4:	55                   	push   %ebp
 2d5:	89 e5                	mov    %esp,%ebp
 2d7:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2da:	8b 45 08             	mov    0x8(%ebp),%eax
 2dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2e6:	eb 17                	jmp    2ff <memmove+0x2b>
    *dst++ = *src++;
 2e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2eb:	8d 50 01             	lea    0x1(%eax),%edx
 2ee:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2f1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2f4:	8d 4a 01             	lea    0x1(%edx),%ecx
 2f7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2fa:	0f b6 12             	movzbl (%edx),%edx
 2fd:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2ff:	8b 45 10             	mov    0x10(%ebp),%eax
 302:	8d 50 ff             	lea    -0x1(%eax),%edx
 305:	89 55 10             	mov    %edx,0x10(%ebp)
 308:	85 c0                	test   %eax,%eax
 30a:	7f dc                	jg     2e8 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 30c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 30f:	c9                   	leave  
 310:	c3                   	ret    

00000311 <thread_create>:

void* malloc(unsigned int);
int thread_create(void (*function)(void)) {
 311:	55                   	push   %ebp
 312:	89 e5                	mov    %esp,%ebp
 314:	83 ec 28             	sub    $0x28,%esp
  char* new_stack = malloc(1024*1024);
 317:	c7 04 24 00 00 10 00 	movl   $0x100000,(%esp)
 31e:	e8 bd 04 00 00       	call   7e0 <malloc>
 323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  char* sp = new_stack + 1024 * 1024 - 4;
 326:	8b 45 f4             	mov    -0xc(%ebp),%eax
 329:	05 fc ff 0f 00       	add    $0xffffc,%eax
 32e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // add thread exit to return value of new stack
  *(uint*)sp = (uint)&thread_exit;
 331:	ba 04 04 00 00       	mov    $0x404,%edx
 336:	8b 45 f0             	mov    -0x10(%ebp),%eax
 339:	89 10                	mov    %edx,(%eax)
  
  return clone(function,new_stack+1024*1024-4);
 33b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 33e:	05 fc ff 0f 00       	add    $0xffffc,%eax
 343:	89 44 24 04          	mov    %eax,0x4(%esp)
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	89 04 24             	mov    %eax,(%esp)
 34d:	e8 aa 00 00 00       	call   3fc <clone>
}
 352:	c9                   	leave  
 353:	c3                   	ret    

00000354 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 354:	b8 01 00 00 00       	mov    $0x1,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <exit>:
SYSCALL(exit)
 35c:	b8 02 00 00 00       	mov    $0x2,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <wait>:
SYSCALL(wait)
 364:	b8 03 00 00 00       	mov    $0x3,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <pipe>:
SYSCALL(pipe)
 36c:	b8 04 00 00 00       	mov    $0x4,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <read>:
SYSCALL(read)
 374:	b8 05 00 00 00       	mov    $0x5,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <write>:
SYSCALL(write)
 37c:	b8 10 00 00 00       	mov    $0x10,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <close>:
SYSCALL(close)
 384:	b8 15 00 00 00       	mov    $0x15,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <kill>:
SYSCALL(kill)
 38c:	b8 06 00 00 00       	mov    $0x6,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <exec>:
SYSCALL(exec)
 394:	b8 07 00 00 00       	mov    $0x7,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <open>:
SYSCALL(open)
 39c:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <mknod>:
SYSCALL(mknod)
 3a4:	b8 11 00 00 00       	mov    $0x11,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <unlink>:
SYSCALL(unlink)
 3ac:	b8 12 00 00 00       	mov    $0x12,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <fstat>:
SYSCALL(fstat)
 3b4:	b8 08 00 00 00       	mov    $0x8,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <link>:
SYSCALL(link)
 3bc:	b8 13 00 00 00       	mov    $0x13,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <mkdir>:
SYSCALL(mkdir)
 3c4:	b8 14 00 00 00       	mov    $0x14,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <chdir>:
SYSCALL(chdir)
 3cc:	b8 09 00 00 00       	mov    $0x9,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <dup>:
SYSCALL(dup)
 3d4:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <getpid>:
SYSCALL(getpid)
 3dc:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <sbrk>:
SYSCALL(sbrk)
 3e4:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <sleep>:
SYSCALL(sleep)
 3ec:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <uptime>:
SYSCALL(uptime)
 3f4:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <clone>:
SYSCALL(clone)
 3fc:	b8 16 00 00 00       	mov    $0x16,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <thread_exit>:
SYSCALL(thread_exit)
 404:	b8 17 00 00 00       	mov    $0x17,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <thread_join>:
SYSCALL(thread_join)
 40c:	b8 18 00 00 00       	mov    $0x18,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 414:	55                   	push   %ebp
 415:	89 e5                	mov    %esp,%ebp
 417:	83 ec 18             	sub    $0x18,%esp
 41a:	8b 45 0c             	mov    0xc(%ebp),%eax
 41d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 420:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 427:	00 
 428:	8d 45 f4             	lea    -0xc(%ebp),%eax
 42b:	89 44 24 04          	mov    %eax,0x4(%esp)
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
 432:	89 04 24             	mov    %eax,(%esp)
 435:	e8 42 ff ff ff       	call   37c <write>
}
 43a:	c9                   	leave  
 43b:	c3                   	ret    

0000043c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 43c:	55                   	push   %ebp
 43d:	89 e5                	mov    %esp,%ebp
 43f:	56                   	push   %esi
 440:	53                   	push   %ebx
 441:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 444:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 44b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 44f:	74 17                	je     468 <printint+0x2c>
 451:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 455:	79 11                	jns    468 <printint+0x2c>
    neg = 1;
 457:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 45e:	8b 45 0c             	mov    0xc(%ebp),%eax
 461:	f7 d8                	neg    %eax
 463:	89 45 ec             	mov    %eax,-0x14(%ebp)
 466:	eb 06                	jmp    46e <printint+0x32>
  } else {
    x = xx;
 468:	8b 45 0c             	mov    0xc(%ebp),%eax
 46b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 46e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 475:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 478:	8d 41 01             	lea    0x1(%ecx),%eax
 47b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 47e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 481:	8b 45 ec             	mov    -0x14(%ebp),%eax
 484:	ba 00 00 00 00       	mov    $0x0,%edx
 489:	f7 f3                	div    %ebx
 48b:	89 d0                	mov    %edx,%eax
 48d:	0f b6 80 6c 0b 00 00 	movzbl 0xb6c(%eax),%eax
 494:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 498:	8b 75 10             	mov    0x10(%ebp),%esi
 49b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 49e:	ba 00 00 00 00       	mov    $0x0,%edx
 4a3:	f7 f6                	div    %esi
 4a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ac:	75 c7                	jne    475 <printint+0x39>
  if(neg)
 4ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b2:	74 10                	je     4c4 <printint+0x88>
    buf[i++] = '-';
 4b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b7:	8d 50 01             	lea    0x1(%eax),%edx
 4ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4bd:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4c2:	eb 1f                	jmp    4e3 <printint+0xa7>
 4c4:	eb 1d                	jmp    4e3 <printint+0xa7>
    putc(fd, buf[i]);
 4c6:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4cc:	01 d0                	add    %edx,%eax
 4ce:	0f b6 00             	movzbl (%eax),%eax
 4d1:	0f be c0             	movsbl %al,%eax
 4d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d8:	8b 45 08             	mov    0x8(%ebp),%eax
 4db:	89 04 24             	mov    %eax,(%esp)
 4de:	e8 31 ff ff ff       	call   414 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4e3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4eb:	79 d9                	jns    4c6 <printint+0x8a>
    putc(fd, buf[i]);
}
 4ed:	83 c4 30             	add    $0x30,%esp
 4f0:	5b                   	pop    %ebx
 4f1:	5e                   	pop    %esi
 4f2:	5d                   	pop    %ebp
 4f3:	c3                   	ret    

000004f4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4f4:	55                   	push   %ebp
 4f5:	89 e5                	mov    %esp,%ebp
 4f7:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4fa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 501:	8d 45 0c             	lea    0xc(%ebp),%eax
 504:	83 c0 04             	add    $0x4,%eax
 507:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 50a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 511:	e9 7c 01 00 00       	jmp    692 <printf+0x19e>
    c = fmt[i] & 0xff;
 516:	8b 55 0c             	mov    0xc(%ebp),%edx
 519:	8b 45 f0             	mov    -0x10(%ebp),%eax
 51c:	01 d0                	add    %edx,%eax
 51e:	0f b6 00             	movzbl (%eax),%eax
 521:	0f be c0             	movsbl %al,%eax
 524:	25 ff 00 00 00       	and    $0xff,%eax
 529:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 52c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 530:	75 2c                	jne    55e <printf+0x6a>
      if(c == '%'){
 532:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 536:	75 0c                	jne    544 <printf+0x50>
        state = '%';
 538:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 53f:	e9 4a 01 00 00       	jmp    68e <printf+0x19a>
      } else {
        putc(fd, c);
 544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 547:	0f be c0             	movsbl %al,%eax
 54a:	89 44 24 04          	mov    %eax,0x4(%esp)
 54e:	8b 45 08             	mov    0x8(%ebp),%eax
 551:	89 04 24             	mov    %eax,(%esp)
 554:	e8 bb fe ff ff       	call   414 <putc>
 559:	e9 30 01 00 00       	jmp    68e <printf+0x19a>
      }
    } else if(state == '%'){
 55e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 562:	0f 85 26 01 00 00    	jne    68e <printf+0x19a>
      if(c == 'd'){
 568:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 56c:	75 2d                	jne    59b <printf+0xa7>
        printint(fd, *ap, 10, 1);
 56e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 571:	8b 00                	mov    (%eax),%eax
 573:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 57a:	00 
 57b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 582:	00 
 583:	89 44 24 04          	mov    %eax,0x4(%esp)
 587:	8b 45 08             	mov    0x8(%ebp),%eax
 58a:	89 04 24             	mov    %eax,(%esp)
 58d:	e8 aa fe ff ff       	call   43c <printint>
        ap++;
 592:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 596:	e9 ec 00 00 00       	jmp    687 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 59b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 59f:	74 06                	je     5a7 <printf+0xb3>
 5a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5a5:	75 2d                	jne    5d4 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5aa:	8b 00                	mov    (%eax),%eax
 5ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5b3:	00 
 5b4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5bb:	00 
 5bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c0:	8b 45 08             	mov    0x8(%ebp),%eax
 5c3:	89 04 24             	mov    %eax,(%esp)
 5c6:	e8 71 fe ff ff       	call   43c <printint>
        ap++;
 5cb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5cf:	e9 b3 00 00 00       	jmp    687 <printf+0x193>
      } else if(c == 's'){
 5d4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5d8:	75 45                	jne    61f <printf+0x12b>
        s = (char*)*ap;
 5da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5dd:	8b 00                	mov    (%eax),%eax
 5df:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ea:	75 09                	jne    5f5 <printf+0x101>
          s = "(null)";
 5ec:	c7 45 f4 dd 08 00 00 	movl   $0x8dd,-0xc(%ebp)
        while(*s != 0){
 5f3:	eb 1e                	jmp    613 <printf+0x11f>
 5f5:	eb 1c                	jmp    613 <printf+0x11f>
          putc(fd, *s);
 5f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fa:	0f b6 00             	movzbl (%eax),%eax
 5fd:	0f be c0             	movsbl %al,%eax
 600:	89 44 24 04          	mov    %eax,0x4(%esp)
 604:	8b 45 08             	mov    0x8(%ebp),%eax
 607:	89 04 24             	mov    %eax,(%esp)
 60a:	e8 05 fe ff ff       	call   414 <putc>
          s++;
 60f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 613:	8b 45 f4             	mov    -0xc(%ebp),%eax
 616:	0f b6 00             	movzbl (%eax),%eax
 619:	84 c0                	test   %al,%al
 61b:	75 da                	jne    5f7 <printf+0x103>
 61d:	eb 68                	jmp    687 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 61f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 623:	75 1d                	jne    642 <printf+0x14e>
        putc(fd, *ap);
 625:	8b 45 e8             	mov    -0x18(%ebp),%eax
 628:	8b 00                	mov    (%eax),%eax
 62a:	0f be c0             	movsbl %al,%eax
 62d:	89 44 24 04          	mov    %eax,0x4(%esp)
 631:	8b 45 08             	mov    0x8(%ebp),%eax
 634:	89 04 24             	mov    %eax,(%esp)
 637:	e8 d8 fd ff ff       	call   414 <putc>
        ap++;
 63c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 640:	eb 45                	jmp    687 <printf+0x193>
      } else if(c == '%'){
 642:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 646:	75 17                	jne    65f <printf+0x16b>
        putc(fd, c);
 648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64b:	0f be c0             	movsbl %al,%eax
 64e:	89 44 24 04          	mov    %eax,0x4(%esp)
 652:	8b 45 08             	mov    0x8(%ebp),%eax
 655:	89 04 24             	mov    %eax,(%esp)
 658:	e8 b7 fd ff ff       	call   414 <putc>
 65d:	eb 28                	jmp    687 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 65f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 666:	00 
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	89 04 24             	mov    %eax,(%esp)
 66d:	e8 a2 fd ff ff       	call   414 <putc>
        putc(fd, c);
 672:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 675:	0f be c0             	movsbl %al,%eax
 678:	89 44 24 04          	mov    %eax,0x4(%esp)
 67c:	8b 45 08             	mov    0x8(%ebp),%eax
 67f:	89 04 24             	mov    %eax,(%esp)
 682:	e8 8d fd ff ff       	call   414 <putc>
      }
      state = 0;
 687:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 68e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 692:	8b 55 0c             	mov    0xc(%ebp),%edx
 695:	8b 45 f0             	mov    -0x10(%ebp),%eax
 698:	01 d0                	add    %edx,%eax
 69a:	0f b6 00             	movzbl (%eax),%eax
 69d:	84 c0                	test   %al,%al
 69f:	0f 85 71 fe ff ff    	jne    516 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6a5:	c9                   	leave  
 6a6:	c3                   	ret    

000006a7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a7:	55                   	push   %ebp
 6a8:	89 e5                	mov    %esp,%ebp
 6aa:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ad:	8b 45 08             	mov    0x8(%ebp),%eax
 6b0:	83 e8 08             	sub    $0x8,%eax
 6b3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b6:	a1 88 0b 00 00       	mov    0xb88,%eax
 6bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6be:	eb 24                	jmp    6e4 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c3:	8b 00                	mov    (%eax),%eax
 6c5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c8:	77 12                	ja     6dc <free+0x35>
 6ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d0:	77 24                	ja     6f6 <free+0x4f>
 6d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d5:	8b 00                	mov    (%eax),%eax
 6d7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6da:	77 1a                	ja     6f6 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6df:	8b 00                	mov    (%eax),%eax
 6e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ea:	76 d4                	jbe    6c0 <free+0x19>
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	8b 00                	mov    (%eax),%eax
 6f1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f4:	76 ca                	jbe    6c0 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f9:	8b 40 04             	mov    0x4(%eax),%eax
 6fc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	01 c2                	add    %eax,%edx
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	8b 00                	mov    (%eax),%eax
 70d:	39 c2                	cmp    %eax,%edx
 70f:	75 24                	jne    735 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 711:	8b 45 f8             	mov    -0x8(%ebp),%eax
 714:	8b 50 04             	mov    0x4(%eax),%edx
 717:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71a:	8b 00                	mov    (%eax),%eax
 71c:	8b 40 04             	mov    0x4(%eax),%eax
 71f:	01 c2                	add    %eax,%edx
 721:	8b 45 f8             	mov    -0x8(%ebp),%eax
 724:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 727:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72a:	8b 00                	mov    (%eax),%eax
 72c:	8b 10                	mov    (%eax),%edx
 72e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 731:	89 10                	mov    %edx,(%eax)
 733:	eb 0a                	jmp    73f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 735:	8b 45 fc             	mov    -0x4(%ebp),%eax
 738:	8b 10                	mov    (%eax),%edx
 73a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 73f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 742:	8b 40 04             	mov    0x4(%eax),%eax
 745:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	01 d0                	add    %edx,%eax
 751:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 754:	75 20                	jne    776 <free+0xcf>
    p->s.size += bp->s.size;
 756:	8b 45 fc             	mov    -0x4(%ebp),%eax
 759:	8b 50 04             	mov    0x4(%eax),%edx
 75c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75f:	8b 40 04             	mov    0x4(%eax),%eax
 762:	01 c2                	add    %eax,%edx
 764:	8b 45 fc             	mov    -0x4(%ebp),%eax
 767:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 76a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76d:	8b 10                	mov    (%eax),%edx
 76f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 772:	89 10                	mov    %edx,(%eax)
 774:	eb 08                	jmp    77e <free+0xd7>
  } else
    p->s.ptr = bp;
 776:	8b 45 fc             	mov    -0x4(%ebp),%eax
 779:	8b 55 f8             	mov    -0x8(%ebp),%edx
 77c:	89 10                	mov    %edx,(%eax)
  freep = p;
 77e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 781:	a3 88 0b 00 00       	mov    %eax,0xb88
}
 786:	c9                   	leave  
 787:	c3                   	ret    

00000788 <morecore>:

static Header*
morecore(uint nu)
{
 788:	55                   	push   %ebp
 789:	89 e5                	mov    %esp,%ebp
 78b:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 78e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 795:	77 07                	ja     79e <morecore+0x16>
    nu = 4096;
 797:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 79e:	8b 45 08             	mov    0x8(%ebp),%eax
 7a1:	c1 e0 03             	shl    $0x3,%eax
 7a4:	89 04 24             	mov    %eax,(%esp)
 7a7:	e8 38 fc ff ff       	call   3e4 <sbrk>
 7ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7af:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7b3:	75 07                	jne    7bc <morecore+0x34>
    return 0;
 7b5:	b8 00 00 00 00       	mov    $0x0,%eax
 7ba:	eb 22                	jmp    7de <morecore+0x56>
  hp = (Header*)p;
 7bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c5:	8b 55 08             	mov    0x8(%ebp),%edx
 7c8:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ce:	83 c0 08             	add    $0x8,%eax
 7d1:	89 04 24             	mov    %eax,(%esp)
 7d4:	e8 ce fe ff ff       	call   6a7 <free>
  return freep;
 7d9:	a1 88 0b 00 00       	mov    0xb88,%eax
}
 7de:	c9                   	leave  
 7df:	c3                   	ret    

000007e0 <malloc>:

void*
malloc(uint nbytes)
{
 7e0:	55                   	push   %ebp
 7e1:	89 e5                	mov    %esp,%ebp
 7e3:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e6:	8b 45 08             	mov    0x8(%ebp),%eax
 7e9:	83 c0 07             	add    $0x7,%eax
 7ec:	c1 e8 03             	shr    $0x3,%eax
 7ef:	83 c0 01             	add    $0x1,%eax
 7f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7f5:	a1 88 0b 00 00       	mov    0xb88,%eax
 7fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 801:	75 23                	jne    826 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 803:	c7 45 f0 80 0b 00 00 	movl   $0xb80,-0x10(%ebp)
 80a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80d:	a3 88 0b 00 00       	mov    %eax,0xb88
 812:	a1 88 0b 00 00       	mov    0xb88,%eax
 817:	a3 80 0b 00 00       	mov    %eax,0xb80
    base.s.size = 0;
 81c:	c7 05 84 0b 00 00 00 	movl   $0x0,0xb84
 823:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 826:	8b 45 f0             	mov    -0x10(%ebp),%eax
 829:	8b 00                	mov    (%eax),%eax
 82b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 82e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 831:	8b 40 04             	mov    0x4(%eax),%eax
 834:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 837:	72 4d                	jb     886 <malloc+0xa6>
      if(p->s.size == nunits)
 839:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83c:	8b 40 04             	mov    0x4(%eax),%eax
 83f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 842:	75 0c                	jne    850 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	8b 10                	mov    (%eax),%edx
 849:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84c:	89 10                	mov    %edx,(%eax)
 84e:	eb 26                	jmp    876 <malloc+0x96>
      else {
        p->s.size -= nunits;
 850:	8b 45 f4             	mov    -0xc(%ebp),%eax
 853:	8b 40 04             	mov    0x4(%eax),%eax
 856:	2b 45 ec             	sub    -0x14(%ebp),%eax
 859:	89 c2                	mov    %eax,%edx
 85b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 861:	8b 45 f4             	mov    -0xc(%ebp),%eax
 864:	8b 40 04             	mov    0x4(%eax),%eax
 867:	c1 e0 03             	shl    $0x3,%eax
 86a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 86d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 870:	8b 55 ec             	mov    -0x14(%ebp),%edx
 873:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 876:	8b 45 f0             	mov    -0x10(%ebp),%eax
 879:	a3 88 0b 00 00       	mov    %eax,0xb88
      return (void*)(p + 1);
 87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 881:	83 c0 08             	add    $0x8,%eax
 884:	eb 38                	jmp    8be <malloc+0xde>
    }
    if(p == freep)
 886:	a1 88 0b 00 00       	mov    0xb88,%eax
 88b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 88e:	75 1b                	jne    8ab <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 890:	8b 45 ec             	mov    -0x14(%ebp),%eax
 893:	89 04 24             	mov    %eax,(%esp)
 896:	e8 ed fe ff ff       	call   788 <morecore>
 89b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 89e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8a2:	75 07                	jne    8ab <malloc+0xcb>
        return 0;
 8a4:	b8 00 00 00 00       	mov    $0x0,%eax
 8a9:	eb 13                	jmp    8be <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b4:	8b 00                	mov    (%eax),%eax
 8b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8b9:	e9 70 ff ff ff       	jmp    82e <malloc+0x4e>
}
 8be:	c9                   	leave  
 8bf:	c3                   	ret    
