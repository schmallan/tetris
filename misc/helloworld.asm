extern ExitProcess
extern GetStdHandle
extern WriteConsoleA
extern WriteFile
extern GetAsyncKeyState

section .data ;variables
;DB automatically allocates space for variables
        newline: db 10
        speed: equ  300000000

        blockL: equ 1570
        blockJ: equ 802
        blockS: equ 112
        blockZ: equ 1584
        blockT: equ 624
        blockI: equ 240
        blockO: equ 1632
        

      ;  49*3*10^10 cycles / 156
        tp: db "xxxxxxxxxxxxxxx"
        m: db 0
        pcx: dq 3
        pcy: dq 3
        space: equ 32
        width: equ 40
        height: equ 30
        playW: equ 10
        playH: equ 20
        playTl: equ playW*playH
        playX: equ 3
        playY: equ 4
        title: db "TETRIS",0
        tl: equ width*height
        colors: db ' ',176,177,178,0
        grid: db "a000000000b000000000c000000000d000000000e000000000f000000000g000000000h000000000i000000000j000000000k000000000l000000000m000000000n000000000o000000000p000000000q000000000r000000000s000000000t000000000!!!!!!!!!!!!!!!!!!!!!!!!",
        message: db "segfault more like schmegfault";

      ;  currentDig: db 0;

section .text           ; code section.
global main		; standard gcc entry point

;ascii reference
;250 ·
;176 ░
;177 ▒
;178 ▓ 

main:
        push rbp
        mov rbp, rsp
        sub rsp, 256*16

        call drawcanv
        
        call clearGrid

        mov r14, 0
        SupaLoop:

        call cwait
        inc r14

        push r14
        call body
        pop r14

        mov rcx, 'X'
        call GetAsyncKeyState
        cmp al, 0
        jnz quit

        jmp SupaLoop


        quit:
        mov rax, 8 
        mov rsp, rbp;
        pop rbp;
ret

drawcanv:

                mov rcx, 0 ;bg
                mov rdx, 0
                mov r8, width
                mov r10, height
                mov rbx, 249
                call fill

                mov rcx, playX ;playarea
                mov rdx, playY
                mov r8, playW
                add r8, r8
                mov r10, playH
                mov rbx, ' '
                call fill

                mov rcx, playX ;leftwall
                dec rcx
                mov rdx, playY
                mov r8, 1
                mov r10, playH
                mov rbx, 186
                call fill
                mov rcx, playW ;rightwall
                add rcx, rcx
                add rcx, playX
                mov rdx, playY
                mov r8, 1
                mov r10, playH
                mov rbx, 186
                call fill

                mov rcx, playX ;topwall
                mov rdx, playY
                dec rdx
                mov r8, playW
                add r8, r8
                mov r10, 1
                mov rbx, 196
                call fill
                mov r13, playX ;upleft
                dec r13
                mov r14, playY
                dec r14
                mov r15, 214
                call setpx
                mov r13, playW
                add r13, r13
                add r13, playX ;upright
                mov r14, playY
                dec r14
                mov r15, 183
                call setpx
                mov rcx, playX ;bottomwall
                mov rdx, playY
                add rdx, playH
                mov r8, 20
                mov r10, 1
                mov rbx, 196
                call fill
                mov r13, playX ;downleft
                dec r13
                mov r14, playY
                add r14, playH
                mov r15, 211
                call setpx
                mov r13, playW
                add r13, r13
                add r13, playX ;upright
                mov r14, playY
                add r14, playH
                mov r15, 189
                call setpx

                mov rcx, width
                dec rcx
                mov rdx, 0
                mov r8, 1
                mov r10, height
                mov rbx, 10
                call fill

                mov rcx, 0 ;cls
                mov rdx, 0
                mov r8, width
                mov r10, 1
                mov rbx, 10
               ; call fill

                mov r13, 1
                mov r14, 1
                mov rdx, title
                call ptoGrid

ret

cwait:
        push rbp
        mov rbp, rsp
        sub rsp, 4*16

        mov r13, speed
        mov r12, 0
        count:
        inc r12
        cmp r12, r13
        jl count

        mov rsp, rbp;
        pop rbp;
ret

;rbx rcx xy in, rdx block in
drawblock:
    push rbp
    mov rbp, rsp
    sub rsp, 64*16
       ; mov rdx, 65535
        mov r15, 3
        dbin:
                mov r12, 3
                dbout:
                        mov rax, rdx
                        push rcx
                        call popLS
                        pop rcx

                        cmp dl, 0
                        jz dbe
                                mov r13, r12
                                add r13, rbx
                                sub r13, 2
                                mov r14, r15
                                add r14, rcx
                                sub r14, 2
                                call calcAdrG
                                mov [r14], 178
                        dbe:
                        mov rdx, rax
                dec r12
                cmp r12, 0
                jnl dbout
        dec r15
        cmp r15, 0
        jnl dbin



    mov rsp, rbp;
    pop rbp;
ret

;pops the least significant bit
;rax in
;rdx out
popLS:
        mov rdx, 0
        mov rcx, 2
        div rcx
ret


body:
        mov rbx, 3
        mov rcx, 16
        mov rdx, blockT
        call drawblock
        
        call drawgrid



        ;print grid
        mov rdx, message
        mov r8, tl
        call print_
        ;call printg_

        
        mov rcx, 999
        call printNum
        mov r13, tp
        call printTz

ret

;r13 in
printTz:
    push rbp
    mov rbp, rsp
    sub rsp, 10*16
    push r13
    mov r15,0
        tzl:
                mov r14b, [r13]
                inc r15
                inc r13
                cmp r14b, 0
                jz tze

                ;call endl_
        jmp tzl

        tze:
        pop rdx
        mov r8, r15
        call print_
    mov rsp, rbp;
    pop rbp;
ret
;r13 r14 in, r14 out
calcAdrG:
                        ml2:
                        cmp r14, 0
                        jz eg
                        add r13, playW
                        dec r14
                        jmp ml2
                        eg:
                        mov r14, grid
                        inc r14
                        add r14, r13     
                        dec r14
ret

clearGrid:
        mov rax, 0
        cgo:
                mov rdx, grid
                add rdx, rax
                mov [rdx], 0
        inc rax
        cmp rax, playTl
        jl cgo
ret

drawgrid:
        push rbp
        mov rbp, rsp
        sub rsp, 256*16

        mov rax, 0
        drL:
                mov rbx, 0
                driL:
                        mov r13, rbx
                        mov r14, rax
                        call calcAdrG

                        mov r15, [r14]
                        cmp r15b, 0
                        jnz skip
                        mov r15, ' '
                        skip:
                        
                        mov r13, rbx
                        add r13, r13
                        add r13, playX
                        mov r14, rax
                        add r14, playY
                        call calcAdr
                        mov [r13], r15b
                        inc r13
                        mov [r13], r15b ;place two consequtive blocks

                inc rbx
                cmp rbx, playW
                jl driL


        inc rax
        cmp rax, playH
        jl drL
        
        mov rsp, rbp;
        pop rbp;
ret

;rcx in - startx
;rdx in - starty
;r8 in - width
;r10 in - height
;rbx in - tofill
fill:


        mov r13, r10
        
        mov r11, rcx
        mov r10, 0

        ml:
        cmp rdx, 0
        jz ol
        add r11, width
        dec rdx
        jmp ml
        
        ol:

        mov r12, 0
        il:

        mov rdx, message
        add rdx, r11
        add rdx, r12
        mov [rdx], bl

        inc r12
        cmp r12, r8
        jl il

        add r11, width
        inc r10
        cmp r10, r13
        jl ol


ret

setpx:
  call calcAdr
  mov [r13], r15b
ret

;r13, r14 x and y
;rdx zero terminated string
ptoGrid:
  push rdx
  call calcAdr
  pop rdx
  tzLoop:
  mov bl, [rdx]
  cmp bl, 0
  jz esc

  mov [r13], bl

  inc r13
  inc rdx
  jmp tzLoop
  esc:

ret

;r13 x
;r14 y
;r13 out
calcAdr:
  mloop:
  cmp r14, 0
  jz ae
  add r13, width
  dec r14
  jmp mloop


  ae:

  mov rdx, message
  add r13, rdx

 ret


printg_:
  push rbp
  mov rbp, rsp
  sub rsp, 16*10;

        mov r13, 0
        mov r14, message
        sloop:
        mov rdx, r14
        mov r8, width
        call print_
        call endl_
        inc r13
        add r14, width
        cmp r13, height
        jnz sloop

  mov rsp, rbp;
  pop rbp;
ret;

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

;rcx in - one byte number
printNum:
        push rbp
        mov rbp, rsp
        sub rsp, 32*16

        mov rax, rcx
        mov r13, 0
        nl:
        mov rdx, 0
        mov rbx, 10
        div rbx
        push rdx
        inc r13
        cmp rax,0
        jnz nl

        mov r14, 0
        pl:
        pop r11
        mov rdx, tp
        add rdx, r14
        mov [rdx], '0'
        add [rdx], r11
        dec r13
        inc r14
        cmp r13,0
        jg pl
        mov rdx,tp
        add rdx,r14
        mov [rdx], 0

        mov rsp, rbp;
        pop rbp;
ret