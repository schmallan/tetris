extern ExitProcess
extern GetStdHandle
extern WriteConsoleA
extern WriteFile

section .data ;variables
;DB automatically allocates space for variables
        newline: db 10
        msg: db "000000",0
        tp: db 'x'
    

section .text           ; code section.
global main		; standard gcc entry point


main:
push rbp
mov rbp, rsp
sub rsp, 10*16

mov rax, 233
mov r13, 0
nl:
mov rdx, 0
mov rbx, 10
div rbx
push rdx
inc r13
cmp rax,0
jnz nl

pl:
pop r11
mov rdx, msg
mov [rdx], '0'
add [rdx], r11
mov r8, 1
call print_
dec r13
cmp r13,0
jg pl

mov rax, r12
mov rsp, rbp;
pop rbp;
ret


                  


print_:
        push rbp
        mov rbp, rsp
        sub rsp, 16*4;
                        
                mov rcx, -11;
                ; RCX in: enum for handle to get (-11 for std output handle)
                call GetStdHandle
                ; RAX out: handle
                mov rcx, rax;   
                ;mov rdx, msg;
                ;mov r8, len;
                ; RCX in: handle to output buffer
                ; RDX in: pointer to message 2 be written
                ; R8  in: number of char to write
                call WriteFile;

                ; mov rax, 99

        mov rsp, rbp;
        pop rbp;
        ret;
;