;include functions
    extern GetStdHandle
    extern WriteFile
    extern GetAsyncKeyState
;<

section .data
    printW: equ 40
    printH: equ 30
    printT: equ printW*printH
    printgrid: db printT dup '?';
    
    printBuffer: db 30 dup 'x';

    message: db "helloworld", 0

    ;dup as you might guess repeats the expression!!! useful for defining large chunks of stuff.
;<

section .text
global main

main:    
    ;reserve stack space
        push rbp
        mov rbp, rsp
        sub rsp, 32*16
    ;

    ;call drawcanv

    ;mov rdx, printgrid
    ;mov r8, printT
    ;call print
    mov r12, 0
    testl:
        mov rcx, r12
        call int2String
        mov rdx, printBuffer
        call printConsoleTz

        mov rdx, printBuffer
        push rdx
        mov [rdx], ' '
        inc rdx
        mov [rdx], r12
        inc rdx
        mov [rdx], 10
        pop rdx
        mov r8, 3
        call printConsole

        inc r12
        cmp r12, 255
    jng testl

    ;return stack space
        mov rsp, rbp
        pop rbp
    ;
ret

drawcanv:
    
    mov rax, printW-1 ;fill newlines on right
        mov rbx, 0
        mov rcx, 1
        mov rdx, printH
        mov r8, 10
    call fill
    mov rax, 0 ;fill newlines on top
        mov rbx, 0
        mov rcx, printW
        mov rdx, 1
        mov r8, 10
    call fill
    mov rax, 4 ;fill playarea
        mov rbx, 4
        mov rcx, 20
        mov rdx, 20
        mov r8, ' '
    call fill
    

ret

int2String: ;rcx in
    mov rbx, 0
    mov rax, rcx
    ;method without using the stack
    pil: ;first find how many digits 
    inc rbx
    mov rdx, 0
    mov r8, 10
    div r8
    cmp rax, 0
    jg pil

    mov rax, rcx
    mov rcx, printBuffer
    add rcx, rbx
    mov [rcx], 0
    dec rcx
    pil2: ;then move to printbuffer
    mov rdx, 0
    mov r8, 10
    div r8
    mov [rcx], '0'
    add [rcx], rdx
    dec rcx
    cmp rax, 0
    jg pil2

ret

fill: ;rabcdx X,Y,W,H r8 tofill
    ;reserve stack space
        push rbp
        mov rbp, rsp
        sub rsp, 32*16
    ;

    push rdx
    push rcx
    mov rcx, printW
    mov rdx, printgrid
    call calcAdr
    pop rcx
    mov r11, 0
    pop r12
    fO:
        mov r10, 0
        push rdx
        fI:
            mov [rdx], r8b
            inc rdx
            inc r10
        cmp r10, rcx
        jl fI
        pop rdx
        add rdx, printW
    inc r11
    cmp r11, r12
    jl fO

    ;return stack space
        mov rsp, rbp
        pop rbp
    ;
ret

calcAdr: ;rabc X,Y,W rdx base; rdx out (adr)
    mul rbx, rcx
    add rbx, rax
    add rdx, rbx
ret

printConsole:  ;rdx message pointer; r8 message length
    push rbp
    mov rbp, rsp
    sub rsp, 10*16

    mov rcx, -11
    call GetStdHandle
    mov rcx, rax
    call WriteFile

    mov rax, 0
    mov rsp, rbp
    pop rbp
ret

printConsoleTz:  ;rdx message pointer;
    push rbp
    mov rbp, rsp
    sub rsp, 10*16

    mov r8, 0
    push rdx
    ptzl:
        mov cl, [rdx]
        inc rdx
        inc r8
    cmp cl, 0
    jnz ptzl
    dec r8

    pop rdx
    call printConsole

    mov rax, 0
    mov rsp, rbp
    pop rbp
ret