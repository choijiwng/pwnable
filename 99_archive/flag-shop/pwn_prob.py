import sys
from pwn import *
context.log_level = 'debug' 

if len(sys.argv) != 3:
    print("how to use: python3 pwn_prob.py [HOST] [PORT]")
    exit()
r = remote(sys.argv[1], int(sys.argv[2]))
#python3 solver.py host8.dreamhack.games 12345

a=r.recvuntil(b"There are 50 rounds.\n")


for round in range(50):
    r.recvline()    #라운드 시작시 첫 개행 버림
    response = 0
    for i in range(10):
        if b"flag" in r.recvline(): #한문장씩 읽음
            response = i
            break
    r.sendlineafter(b"> ", str(response).encode()) #기다렸다가 전송

r.interactive()
