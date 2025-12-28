myFunction:
    push rbp
    mov rbp, rsp
    sub rsp, 10*16


    mov rax, 0
    mov rsp, rbp;
    pop rbp;
ret