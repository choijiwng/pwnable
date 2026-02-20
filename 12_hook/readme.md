## 보호기법
arch : amd64
full RELRO
- .got .plt read-only
- libc 전역변수 rw
canary found
- 스택 보호 기법
no pie
- 전역변수 주소 항상동일 + base 고정

## 프로그램 흐름
stdout의 주소가 노출되고 8바이트 size변수를 입력한다
해당 size만큼 ptr변수가 동적할당되고 size만큼 ptr 입력 받는다
ptr[0]에 ptr[1]의 값을 덮어써라
double free가 되고 system함수를 실행한다.

## 스택구조
rip
rbp
canary      rbp-0x8     8바이트
ptr         rbp-0x10    8바이트
size        rbp-0x18    8바이트
패딩        4바이트
edi(argc)         rbp-0x24  4바이트
패딩 8바이트
rsi(argv)         rbp-0x30(48바이트)    8바이트

## 취약점
- __free_hook에 main에 있는 system()주소를 넣거나 one_gadget주소를 넣는다
ㄴ free()함수가 실행하면 free_hook변수에 one_gadget이 들어가 실제로 one_gadget이 실행된다
ㄴ 코드에 system()함수를 이용해서 hook변수에 넣어 쉘을 획득할 방법도 있다.
- one_gadget=0x4527a,0xf03a4,0xf1247

## hook 공격 정리(glibc 버전 의존)
stdout leak -> libc_base 계산 가능
write-what-where -> free_hook 덮기
ㄴ*(long *)*ptr = *(ptr+1);
    ㄴ hook주소에 공격자가 원하는 one_gadget을 넣기
__free_hook = system 또는 one_gadget
free(ptr) 호출 시 hook 트리거
malloc / realloc / free 같은 libc 함수의 hook 변수에
one_gadget을 넣을지, system을 넣을지 선택하는 문제다.