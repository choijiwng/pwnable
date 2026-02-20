from pwn import *
context.log_level = 'debug'

address = "host8.dreamhack.games"
port = 13167
r=remote(address, port)

for i in range(50):
    first_num = int(r.recvuntil(b'+', drop=True))
    second_num = int(r.recvuntil(b'=?\n', drop=True))   #drop=true는 구분자를 제거
    r.sendline(str(first_num + second_num).encode())  #sendline은 자동으로 \n을 붙여준다,, scanf로 받으니 개행문자 필요
r.interactive()