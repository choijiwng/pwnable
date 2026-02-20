## 프로그램 흐름
main함수에서 무한반복문으로 함수가 실행된다. 
1. menu함수 
- 3가지 항목을 단지 Print하는 함수다
2. 해당하는 번호를 scanf로 idx에 입력 받는다
ㄴ 크기를 제한하지 않는 scanf함수이다.
3. human_func()
- 구조체 변수를 동적할당 받고 weight,age변수를 입력받고 동적할당 받은 구조체 변수를 free한다. 그리고 main으로 돌아와서 break 프로그램이 꺼진다.
4. robot_func()
- 구조체 변수를 동적 할당받고 weight변수 입력 받고 fptr변수가 값이 있다면 함수를 실행하고 그렇지 않으면 print_name함수 주소를 받는다. 그리고 fptr로 함수를 실행하고 free로 구조체 변수가 해제된다. 
5. custom_func()
- c_idx 전역변수 제한이 있습니다. 크기를 입력 받고 그 만큼 custom[0]에 포인터 동적할당 받는다. 그리고 data를 입력 받고 출력도 시키고 custom[idx]가 값이 있다면 free로 해제되고 NULL로 초기화 된다.

## 보호기법
arch = amd64
relro = full relro
- 바이너리 .got .plt read only
- ret2plt 불가
canary found
nx enavled
- 스택 메모리 shellcode 공격 불가
pie enabled
- libc_base가 고정이 아니다
- 가젯 무의미

## 스택 구조
rip
rbp
canary          rbp-0x8         8바이트
idx             rbp-0xc         4바이트 9~c
패딩            rbp-10                

## 코드 분석 및 해석 + 취약점 찾기
전역 변수
struct Human {
  char name[16];
  int weight;
  long age;
};

struct Robot {
  char name[16];
  int weight;
  void (*fptr)();
};
- 동일한 두 구조체
- Human->age에 주소값을 입력하고 Robot 구조체로 재 할당 받은 Robot->fptr로 원하는 코드 흐름을 실행(jump)
struct Human *human;
struct Robot *robot;

char *custom[10];
int c_idx;
- 주소를 담는 custom 배열과 이를 참조하는 c_idx가 선언 

Human_func()
- idx변수 1번 입력 -> 해당 함수 실행 -> Human구조체 1개 동적할당 하고, weight와 age를 입력 받아 free()시킨다

robot_func()
- Robot구조체 1개 동적할당하고 weight를 입력 받아 데이터를 저장. fptr의 입력은 없지만 NULL이 아니라면 해당 주소로 jump한다.

- 위 두개의 함수를 통해 human->age에 공격 주소를 입력 해두고 robot_func를 실행하면 robot->ptr에 앞서 저장해준 Human->age값으로 fptr이 살행된다. 그러면 age에 oneshot gadget의 주소를 넣으면 셸을 얻을수 있다. 그전에 libc leak를 먼저 해야한다.

Custom_func()
- 우선 c_idx 전역변수 if문으로 10번으로 제한한다. 입력받은 size가 0x100보다 크면 custom[c_idx]에 size만큼 동적할당 받는다. 그리고 해당 인덱스에 입력을 받는다. 입력된 값 출력시키고 

## 취약점
human과 robot의 구조체 크기가 같고 초기화 과정이 없어서 human에 메모리를 할당 후 robot에 메모리를 할당한다면 use-after-free를 사용할수 있다
fptr에 hook또는 one_gadget을 넗는다면 flag를 얻을수 있다

## 알아야할것
```c
arena_offset = libc.symbols['__malloc_hook'] + 0x10 =>0x3ebc40
leak = u64(p.recvline()[:-1].ljust(8, b"\x00")) =>
arena_1byte = arena_offset & 0xff <-arena의 하위 1바이트
leak_1byte = leak & 0xff  <-유출된 fd의 하위 1바이트
libc_base = leak - arena_offset + (arena_1byte-leak_1byte) 
```
1. 유출 시킬 값 == fd,bk == main_arena + 0x60
                        == libc_base + arena_offset +0x60
                           libc_base + __malloc_hook + 0x10 + 0x60
                          =libc_base + 0x3ebc40 + 0x60
                      ->libc_base = fd(leak)-0x3ebc40-leak의lsb+arena_offset의lsb
                      ㄴ 하위바이트를 00으로 만드는 본래로 돌아가게 하는 수식
**arena_offset**구하는 방법
  1. glibc 2.23   0x3c4b20
     glibc 2.27   0x3ebc40
    glibc 2.29    0x1e4c40      암기
  2. 2.27버전에는 __malloc_hook 주소+0x10
  3. gdb로 바이너리 시작 주소를 구하고 main_arena주소를 구한 뒤 p/x 명령으로 -연산 -> gdb로 실제 값을 넣어 연산하면 0x32bcxx와 같은 값 입력한 값이 fd의 lsb부터 쓰기 시작하기 떄문이다.
**유출된 된 fd은 leak = libc_base+0x32bc42다,, libc_base = leak - 0x32bc42
    ㄴ arena_offset +0x60 이걸 통으로 0x32bc42로 보기 떄문이고 그 이유는 libc_base의 lsb 00 규칙이고 이건 libc 실행시 mmap으로 메모리에 로드되어 4kb=0x1000으로 정렬되기 때문이다. 

glibc 2.27
- unstored bin fd = main_arena+0x60
- __malloc_hook = main_arena-0x10
arena_offset = __malloc_hook + 0x10 <-알수있는것(바이너리 파일로)
unsorted fd = __malloc_hook + 0x10 + 0x60 <- 유출시킬것


알아내야하는것 -> libc_base
use after free 나오는 개념
arena_offset = libc.symbols['__malloc_hook'] + 0x10 **내부 offset**
fd,bk = libc_base + arena_offset + 0x60
unsorted bin = 
main arena

## 시나리오
1.  공격자가 원하는 주소로 jump시키기 위해 우선 libc_base를 알아야한다.
```c
int custom_func() {
  unsigned int size;
  unsigned int idx;
  if (c_idx > 9) {
    printf("Custom FULL!!\n");
    return 0;
  }
  printf("Size: ");
  scanf("%d", &size);
  if (size >= 0x100) { //사이즈가 일정 이상되어야 할당됨
    custom[c_idx] = malloc(size);
    printf("Data: ");
    read(0, custom[c_idx], size - 1);
    //단순 바이트 복사,문자열x,null x -> 마지막 null문자 없이 입력 가능

    printf("Data: %s\n", custom[c_idx]);  //입력된 데이터 출력, 주요 유출 취약점
    //입력된 데이터에 null이 없어서 다음 헤더 유출된다
    printf("Free idx: ");
    scanf("%d", &idx);

    if (idx < 10 && custom[idx]) {
      free(custom[idx]);//free 동작
      custom[idx] = NULL;
    }
  }

  c_idx++;
}
-  한번만 할당하고 바로 해제 후 재활용은 top청크만 확장되어 유출할 fd,bk가 없으니 최소 두번 할당하고 해제 후 재할당을 해야한다.
  ->custom(0x500, "AAAA", 100) #할당
    custom(0x500, "AAAA", 100) #할당
    custom(0x500, "AAAA", 0)   #해제
    custom(0x500, "B", 100)    #재활용

- libc_base = u64(p.recvline()[:-1].ljust(8,b'\x00'))-0x3ebc42
ㄴ 마지막 개행문자는 지우고 8바이트보다 작으면 오른쪽 0x00패딩
ㄴ 
2. 원격에 맞는 one_gadget를 찾아야한다
3. human(1,oneshot) + robot(1)로 쉘을 획득가능하다
- oneshot = libc_base + one_gadget