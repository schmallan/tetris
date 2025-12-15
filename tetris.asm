;include functions
    extern GetStdHandle
    extern WriteFile
    extern GetAsyncKeyState
;<

section .data
    title: db "TETRIS",0;

    printW: equ 40
    printH: equ 30
    printT: equ printW*printH
    printGrid: db printT dup '?';

    cursorX: dq 5
    cursorY: dq 3

    playX: equ 4
    playY: equ 4
    playW: equ 10
    playH: equ 20
    playT: equ playW*playH
    playGrid: db 15 dup playW dup 0,5 dup playW dup 1;
    ;playGrid: db "a000000000b000000000c000000000d000000000e000000000f000000000g000000000h000000000i000000000j000000000k000000000l000000000m000000000n000000000o000000000p000000000q000000000r000000000s000000000t000000000!!!!!!!!!!!!!!!!!!!!!!!!",
    
    cyclecount: dq 0

    pieceW: equ 5
    pieceH: equ 5
    pieceT: equ pieceW*pieceH
    pieceGrid: db pieceT dup 2;pieceW dup pieceH dup 0
    
    printBuffer: db 50 dup 's';

    colors: db ' ', 176, 177, 178, '?'

    message: db "helloworld", 0

    blockL: equ 1570
    blockJ: equ 802
    blockS: equ 112
    blockZ: equ 1584
    blockT: equ 624
    blockI: equ 240
    blockO: equ 1632

    cyclesPerTick: equ 6
    cycle: dq 0

    ;dup as you might guess repeats the expression!!! useful for defining large chunks of stuff.
;<

section .text
global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 10*16

    mov rdx, playGrid
    add rdx, 120
    mov [rdx], 1
    sub rdx, 26
    mov [rdx], 1        

    ;mov rcx, cyclecount
    ;mov [rcx], 0

    mainloop:
        
        mov rcx, cyclecount
        mov rdx, [rcx]
        inc rdx
        mov [rcx], rdx

        call wait_
        call body


        mov rcx, 'X'
        call GetAsyncKeyState
        cmp al, 0
    jz mainloop


    mov rax, 0
    mov rsp, rbp;
    pop rbp;
ret

wait_:
    mov rax, 100000000
    waitloop:
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
    dec rax
    cmp rax, 0
    jg waitloop
ret

movCursor: ;rabx in
    mov rcx, cursorX
    mov rdx, [rcx]
    add rdx, rax
    mov [rcx], rdx
    mov rcx, cursorY
    mov rdx, [rcx]
    add rdx, rbx
    mov [rcx], rdx
ret

cursorDraw: ;rcx color
    mov rax, cursorX
    mov rax, [rax]
    mov rbx, cursorY
    mov rbx, [rbx]
    call drawPiece
ret

updcursor: ;rabx in
    push rax
    push rbx
    mov rcx, 0
    call cursorDraw

    
    pop rbx
    pop rax
    push rax
    push rbx
    call movCursor
    
    call checkCollision
    pop r8
    pop r9

    cmp al,0
    jz ucs
        mov rax, r9
        mul rax, -1
        mov rbx, r8
        mul rbx, -1
        call movCursor
    ucs:

    mov rcx, 3
    call cursorDraw


ret

modTick:
    mov rax, cycle
    mov rbx, [rax]
    inc rbx
    mov rcx, 0
    cmp rbx, cyclesPerTick
    cmovnl rbx, rcx
    mov [rax], rbx
ret

movement:
    ;reserve stack space
        push rbp
        mov rbp, rsp
        sub rsp, 32*16
    ;

    mov r12, 0
    mov r13, 0

    mov rcx, 'A'
    call GetAsyncKeyState
    mov rbx, -1
    cmp al, 0
    cmovnz r12, rbx

    mov rcx, 'D'
    call GetAsyncKeyState
    mov rbx, 1
    cmp al, 0
    cmovnz r12, rbx

    mov rax, r12
    mov rbx, 0
    call updcursor

    ;return stack space
        mov rsp, rbp
        pop rbp
    ;
ret

checkCollision: ;al out
    push r12
    mov r12, 0

    mov r10, pieceGrid
    add r10, pieceT

    mov rax, cursorX
    mov rax, [rax]

    mov rbx, cursorY
    mov rbx, [rbx]

    sub rax, 3
    sub rbx, 3

    mov r9, pieceH
    cco:
        mov r8, pieceW
        cci:
        
            push rax
            push rbx
            add rax, r8
            add rbx, r9
            mov rcx, playW
            mov rdx, playGrid
            call calcAdr

            dec r10

            mov cl, [r10]
            cmp cl, 0
            jz ccs
                mov cl, [rdx]
                cmp cl, 0
                mov rbx, 1
                cmovnz r12, rbx
            ccs:
            pop rbx
            pop rax

        dec r8
        jg cci
    dec r9
    jg cco

    mov rax, r12
    pop r12
ret

body:    
    ;reserve stack space
        push rbp
        mov rbp, rsp
        sub rsp, 32*16
    ;
    call modTick

    mov rax, blockJ
    call loadPiece


    mov rax, cycle
    mov rax, [rax]
    cmp rax, 0
    jnz be
    mov rax, 0
    mov rbx, 1
    call updcursor

    be:

    call movement


    call drawcanv
    
   ; call checkCollision
    
    mov rcx, 0
    call int2String
    mov rax, 2
    mov rbx, 26
    mov rdx, printBuffer
    call printCanv

    call drawPlayGrid

    mov rdx, printGrid
    mov r8, printT
    call printConsole

    ;return stack space
        mov rsp, rbp
        pop rbp
    ;
ret

drawPiece: ;rabx x, y, rcx col
    mov r10, pieceGrid
    add r10, pieceT

    sub rax, 3
    sub rbx, 3

    mov r9, pieceH
    dpo:
        mov r8, pieceW
        dpi:
        
            push rax
            push rbx
            push rcx
            add rax, r8
            add rbx, r9
            mov rcx, playW
            mov rdx, playGrid
            call calcAdr
            pop rcx


            dec r10

            mov al, [r10]
            cmp al, 0
            jz dps
            mov [rdx], cl
            dps:

            pop rbx
            pop rax

        dec r8
        jg dpi
    dec r9
    jg dpo
ret

loadPiece: ;rax piece
    mov r8, pieceT
    lpf:
    dec r8
        mov rbx, pieceGrid
        add rbx, r8
        mov [rbx], 0
    cmp r8, 0
    jg lpf
    
    mov r9, 4
    lpo:
    dec r9
        mov r8, 4
        lpi:
            dec r8

            push rax

            mov rax, r8
            mov rbx, r9
            mov rcx, pieceW
            mov rdx, pieceGrid
            call calcAdr
            mov r10, rdx

            pop rax

            mov [r10], 0

            mov rdx, 0
            mov rbx, 2
            div rbx
            cmp rdx, 0
            jz lpz
                mov [r10], 2
            lpz:

        cmp r8, 0
        jg lpi

    cmp r9, 0
    jg lpo

ret

drawcanv:
    
    
    mov r8, 179
        mov rax, 0 ;vwalls
        mov rbx, 2
        mov rcx, printW-1
        mov rdx, printH-3
    call fill
    mov r8, 196
        mov rax, 1 ;hwalls
        mov rbx, 1
        mov rcx, printW-3
        mov rdx, printH-1
    call fill

    mov r8, 218
        mov rax, 0
        mov rbx, 1
        mov rcx, 1
        mov rdx, 1
    call fill
    mov r8, 192
        mov rax, 0
        mov rbx, printH-1
        mov rcx, 1
        mov rdx, 1
    call fill
    mov r8, 191
        mov rax, printW-2
        mov rbx, 1
        mov rcx, 1
        mov rdx, 1   
    call fill
    mov r8, 217
        mov rax, printW-2
        mov rbx, printH-1
        mov rcx, 1
        mov rdx, 1
    call fill

    
    mov r8, ' ' ;fill bg
        mov rax, 1
        mov rbx, 2
        mov rcx, printW-3
        mov rdx, printH-3
    call fill
    
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

    mov r8, 179
        mov rax, playX-1 ;wwalls
        mov rbx, playY
        mov rcx, playW*2+2
        mov rdx, playH
    call fill
    mov r8, 196
        mov rax, playX ;hwalls
        mov rbx, playY-1
        mov rcx, playW*2
        mov rdx, playH+2
    call fill


    mov r8, 218
        mov rax, playX-1
        mov rbx, playY-1
        mov rcx, 1
        mov rdx, 1
    call fill
    mov r8, 192
        mov rax, playX-1
        mov rbx, playY+playW*2
        mov rcx, 1
        mov rdx, 1
    call fill
    mov r8, 191
        mov rax, playX+playW*2
        mov rbx, playY-1
        mov rcx, 1
        mov rdx, 1
    call fill
    mov r8, 217
        mov rax, playX+playW*2
        mov rbx, playY+playW*2
        mov rcx, 1
        mov rdx, 1
    call fill

    mov rax, playX ;fill playarea
        mov rbx, playY
        mov rcx, playW*2
        mov rdx, playH
        mov r8, ' '
    call fill

    mov rax, 5
    mov rbx, 3
    mov rdx, title
    call printCanv

ret

printCanv: ;rdx msg in, rax rbx x y, 
    push rdx
    call calcTz

    mov rcx, printW
    mov rdx, printGrid
    call calcAdr
    pop r9
    ;rdx buffer loc, r8 print#, r9 string loc
    pcl:
        mov r10, [r9]
        mov [rdx], r10b
        inc rdx
        inc r9
    dec r8
    cmp r8, 0
    jg pcl
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
    mov rdx, printGrid
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

    push rdx
    call calcTz
    pop rdx

    call printConsole

    mov rax, 0
    mov rsp, rbp
    pop rbp
ret

drawPlayGrid:
    push rbp
    mov rbp, rsp
    sub rsp, 10*16

    mov r10, playGrid
    add r10, playT
    dec r10

    mov r8, playH
    dpgO:
        mov r9, playW
        dpgI:
            mov rax, r9
            dec rax
            add rax, rax
            add rax, playX
            mov rbx, r8
            dec rbx
            add rbx, playY

            mov rcx, printW
            mov rdx, printGrid
            call calcAdr

            mov al, [r10]
            ;sub al, '0'

            mov rcx, colors
            add cl, al
            mov al, [rcx]

            mov [rdx], al
            inc rdx
            mov [rdx], al

            dec r10

        dec r9
        cmp r9,0
        jg dpgI

    dec r8
    cmp r8,0
    jg dpgO

    mov rax, 0
    mov rsp, rbp;
    pop rbp;
ret

calcTz: ;in rdx, out r8

    mov r8, 0
    ptzl:
        mov cl, [rdx]
        inc rdx
        inc r8
    cmp cl, 0
    jnz ptzl
    dec r8

ret