## 프로그램 흐름
name변수 크기만큼 입력 받고 마지막에 system(command[idx])를 실행하기 위한 idx를 사용자 입력으로 받는다

## 보호 기법
arch = i386
partial relro
ㄴ .got .plt rw가능
canary found
ㄴ 스택 보호 기법 
nx enabled
ㄴ 스택 메모리 쉘코드 실행 불가
no pie
ㄴ 바이너리 기준 주소 고정

## 스택 구조
eip         4바이트
ebp         4바이트
canary      ebp-0xc         4바이트
idx         ebp-0x10        4바이트
패딩        ebp-0x14

## 취약점
    scanf("%d", &idx);
    system(command[idx]);
- 배열 인덱스 검증이 없어 command배열 바깥의 전역 메모리를 참조하게 만들수 있다.
  이를 통해 공격자가 제어한 문자열 주소를 전달하여 임의 명령을 실행한다.

## 시나리오
name과 command가 같은 전역변수임을 확인하여 name에 /bin/sh 혹은 cat flag를 입력하고 사전 준비된 name과 command와의 사이를 구해서 맞는 인덱스를 넣어  참조하게 되어 flag를 얻게 된다
- command의 시작 주소 : 0x804a060
- name의 주소 : 0x0804a0ac
- 차이는 76바이트다. command[]의 시작 인덱스 주소에서 +76이 된다면 name의 위치이다
  ㄴ 76이 떨어지니 char*배열이므로 76/4=19가 된다
- mov    eax,DWORD PTR [eax*4+0x804a060] 이에 따라 idx는 19이다

## 배운점
낮은 주소
────────────────────────
.text
.rodata
.data      ← command 있음
.bss       ← name 있음
────────────────────────
높은 주소

command[0]
command[1]
...
command[9]
name[0]
name[1]
...
name[15]
- 바이너리에서 이렇게 연결되어 name을 참조할수있다. 같은 전역변수이기에

**mov    eax,DWORD PTR [eax*4+0x804a060]**
- 어셈블리어 거부감만 느끼지 말고 최대한 아느대로 해석해보자
- system함수의 인자를 설정하는 과정인데 위에서 idx를 참조하고 char*이니 한칸에 4바이트하서 *4를 참조해서 command 배열 한칸 한칸 시작 주소에 접근한다.
- 아는것도 다시 system함수의 인자를 확인하는 마인드도 필요하다.