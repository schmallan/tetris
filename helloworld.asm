extern ExitProcess
extern GetStdHandle
extern WriteConsoleA
extern WriteFile



section .data ;variables
;DB automatically allocates space for variables
        newline: db 10
        message: db "lHdeelo W",0;

        toPrint: db 0
      ;  currentDig: db 0;

section .text           ; code section.
global main		; standard gcc entry point

main:
push rbp
mov rbp, rsp
sub rsp, 10*16

mov r13, 900
mov r14, message
lab:
mov rdx, r14
mov r8, 128
call print_
call endl_
dec r13
add r14, 128
cmp r13, 0
jg lab

mov rsp, rbp;
pop rbp;
ret

printTZ_:
push rbp
mov rbp, rsp
sub rsp, 10*16

mov r12, rdx
loop:
; message is already in rdx
mov rbx, [r12]
mov rdx, r12
mov r8, 1
call print_
inc r12
cmp rbx, 0
jnz loop


mov rsp, rbp;
pop rbp;
ret

example:
push rbp
mov rbp, rsp
sub rsp, 10*16

;[] brackets are used for dereferencing
;treat the value inside the register as an address

mov rbx, message ;get the pointer to the message into rbx
mov rbx, [rbx] ;use pointer to get the value of first char into rbx
inc rbx
mov rdx, message
mov [rdx], rbx ;move the updated value into the first byte using the message pointer
mov r8, 1
call print_


mov rsp, rbp;
pop rbp;
ret

endl_:
        push rbp
        mov rbp, rsp
        sub rsp, 16*4;

                mov r8,1
                mov rdx, newline
                call print_
                        
        mov rsp, rbp;
        pop rbp;
        ret;
;

; RDX in: pointer to message 2 be written
; R8  in: number of char to write
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
