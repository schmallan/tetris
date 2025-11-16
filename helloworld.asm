extern ExitProcess
extern GetStdHandle
extern WriteConsoleA
extern WriteFile



section .data ;variables
;DB automatically allocates space for variables
        newline: db 10
        blah: db "aaaaaaaa",10,0
        char: db "x",10,0
        msg: db "Hello world!", 0 ;equ defines a byte (???)
        len: equ $ - msg ; equ defines constant for compiler
        digits: db "0123456789",0;

        currentDig: db 0;

section .text           ; code section.
global main		; standard gcc entry point

main:	
        push rbp
        mov rbp, rsp
        sub rsp, 10*16;
                

                mov rbx, 0;
                loop:               
                        inc rbx;
                        mov [rbp-50], rbx
                        mov rdx, rbp
                        sub rdx, 50
                        ;add rdx, rbx
                        mov r8, 1
                        call print_;
                        call endl_
            
                ;mov rcx, 'x';
                cmp rbx, 'l'
                jl loop
                


                ;call ExitProcess 
                ;add rsp, 48; //return stack space      
                ;mov rax, 99; //return code!! works!! when i do %errorlevel% it shows 99. interesting
                ;if i dont set an exit code myself, the exit code will be the last exit code (in this case from writefile)
              ;  call WriteConsoleA
              
                mov rax, 0;

        mov rsp, rbp;
        pop rbp;
        ret
;

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

        