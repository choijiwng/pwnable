## 프로그램 흐름
center_name변수에 입력에 bof가 가능하게 입력을 받고 cmd_ip변수가 초기화된 값이 같다면 system(cmp_ip)실행하고 그렇지 않다면 종료된다

## 보호 기법
arch = amd64
full relro
- 라이브러리에 .got,.plt영역이 r권한만 가능
no canary
nx enabled
- 스택메모리에 쉘코드 실행 불가
pie enabled
- libc_base 주소가 항시 변경

## 스택 구조
rip
rbp
dummy               rbp-0x8         
cmd_ip              rbp-0x110       256바이트 0x100
center_name         rbp-0x130       24바이트 0x18

## 취약점
	printf("Center name: ");
	read(0, center_name, 100);
- 여기서 cmd_ip까지 일정부분 overwrite가 가능하다
- 첫 8바이트는 ifconfig문자열이 와야하는것을 인지하자

	if( !strncmp(cmd_ip, "ifconfig", 8)) {
		system(cmd_ip);}
- ifconfig를 첫 8바이트로 넣어 조건문이 참이 되게 하고 메타문자를 활용해서 ;cat flag를 넣을수 있다.

## 시나리오
center_name 입력에 cmd_ip거리까지 패딩으로 채우고 ifconfig를 넣고;cat flag를 입력 시키면 쉘에서 끝까지 실행할려고 하니 앞에 명령은 그냥 not found상태이고 뒤에 명령어를 실행하게 된다.

