;include functions
    extern GetStdHandle
    extern WriteFile
    extern GetAsyncKeyState
;<

section .data
    title: db "TETRIS",0;

    printW: equ 100
    printH: equ 30
    printT: equ printW*printH
    printGrid: db printT dup '?';

    score: dq 99999
    scoreMsg: db "SCORE:",0

    numPieces: equ 7

    cursorX: dq 5
    cursorY: dq 3

    well: dq 4
    bagLeft: db numPieces

    playX: equ 4
    playY: equ 4
    simPlayW: equ 10
    playW: equ simPlayW+2
    simPlayH: equ 20
    playH: equ simPlayH+5+1
    simPlayT: equ simPlayH*simPlayW
    playT: equ playW*playH
    playGrid: db playT dup 0;
    ;playGrid: db "a000000000b000000000c000000000d000000000e000000000f000000000g000000000h000000000i000000000j000000000k000000000l000000000m000000000n000000000o000000000p000000000q000000000r000000000s000000000t000000000!!!!!!!!!!!!!!!!!!!!!!!!",
    ghostGrid: db simPlayT dup 0;

    bag: db "0123456",0

    currentPiece: db 0

    cyclecount: dq 0

    pieceW: equ 5
    pieceH: equ 5
    pieceT: equ pieceW*pieceH
    pieceGrid: db pieceT dup 2;pieceW dup pieceH dup 0
    
    printBuffer: db 50 dup 's';

    colors: db ' ', 176, 177, 178, '?'

    message: db "helloworld", 0

    ;blockL: equ 1570
    ;blockJ: equ 802
    ;blockS: equ 112 ???
    ;blockZ: equ 1584
    ;blockT: dd 624
    ;blockI: equ 240
    ;blockO: equ 1632
    ;blockE: equ 32
    blocks: dd 1570, 802, 54, 1584, 624, 240, 1632, 32

    currentColor: db 1

    cyclesPerTick: equ 12
    cycle: dq 0

    ;dup as you might guess repeats the expression!!! useful for defining large chunks of stuff.
;<

section .text
global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 10*16

    call resetBlock 
     call drawcanv
    ;mov rcx, cyclecount
    ;mov [rcx], 0
    call clearPlayGrid

    mov rax, 3
    mov rbx, 5
    mov rcx, 1
    mov rdx, playH
    
    call drawcanv

    mainloop: 
        mov rcx, cyclecount
        mov rdx, [rcx]
        inc rdx
        mov [rcx], rdx

        
        mov rax, playX ;fill playarea
            mov rbx, playY
            mov rcx, simPlayW*2
            mov rdx, simPlayH
            mov r8, ' '
        call fill

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

checkRows:

    mov r8, 6
    cro:
        mov rax, 1
        mov rbx, r8
        sub rbx, 1
        mov rcx, playW
        mov rdx, playGrid
        call calcAdr

        mov rbx, 0
        mov rcx, 0
        cri:
            mov al, [rdx]
            cmp al, 0
            jnz cris
                inc rcx
            cris:
        inc rdx
        inc rbx
        cmp rbx, simPlayW
        jl cri
        
        cmp rcx, 0
        jnz crz
            ;fall rows here
            push r8
            sub r8, 2
            call rowFall
            
            pop r8
            
        crz:

        inc r8
    cmp r8, playH
    jl cro
ret

debug:

            call drawPlayGrid
            mov rdx, printGrid
            mov r8, printT
            call printConsole    
    
ret

shiftRow: ;r8 row in
    mov rax, 1
    mov rbx, r8
    mov rcx, playW
    mov rdx, playGrid
    call calcAdr

    mov r8, rdx
    add r8, playW

    mov rax, 0
    sro:
        mov r10b, [rdx]
        mov [r8], r10b
        mov [rdx], 0
        
        inc r8
        inc rdx
    inc rax
    cmp rax, simPlayW
    jl sro
ret

rowFall:
    mov r11, r8

    rfo:
        mov r8, r11
        call shiftRow
    dec r11
    cmp r11, 1
    jg rfo

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

coloredCD:
    mov rdx, currentColor
    mov rcx, [rdx]
    call cursorDraw

ret

modColor:
    mov rdx, currentColor
    mov cl, [rdx]
    inc cl
    
    mov rbx, 1
    cmp cl, 3
    cmovg rcx, rbx

    mov [rdx], cl
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
    
    push rax
    cmp al,0
    jz ucs
        mov rax, r9
        mul rax, -1
        mov rbx, r8
        mul rbx, -1
        call movCursor
    ucs:

    call coloredCD


    pop rax
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

flipI:

    mov rbx, pieceH
    fio:
    dec rbx

        mov rax, pieceW/2
        fii:
        dec rax
            push rax
            push rbx
            
            mov rdx, pieceGrid
            mov rcx, pieceW
            call calcAdr
            mov r8, rdx

            pop rbx
            pop rax
            push rax
            push rbx

            mul rax, -1
            add rax, pieceW-1
            mov rcx, pieceW
            mov rdx, pieceGrid
            call calcAdr

            mov r9b, [r8]
            mov r10b, [rdx]
            mov [rdx], r9b
            mov [r8], r10b

            pop rbx
            pop rax
        cmp rax, 0
        jg fii

    cmp rbx, 0
    jg fio
    
ret

flipZ:

    mov rbx, pieceH
    mov rax, pieceW-1
    fzo:
    dec rbx
        push rax
        fzi:
        dec rax
            push rax
            push rbx
            
            mov rdx, pieceGrid
            mov rcx, pieceW
            call calcAdr
            mov r8, rdx

            pop rax  ;notice how i pop in the "wrong" order to flip the axis on purpose!!!
            pop rbx
            push rbx
            push rax

            mov rdx, pieceGrid
            mov rcx, pieceW
            call calcAdr
            
            mov r9b, [rdx]
            mov r10b, [r8]
            mov [r8], r9b
            mov [rdx], r10b
            
            pop rbx
            pop rax

        cmp rax, 0
        jg fzi
        pop rax
        dec rax

    cmp rbx, 0
    jg fzo
    
ret

movement:
    ;reserve stack space
        push rbp
        mov rbp, rsp
        sub rsp, 32*16
    ;
    
    mov rcx, ' '
    call GetAsyncKeyState
    mov rbx, 1
    cmp al, 0
    jz mdtsp
        spaceL:
            mov rax, 6
            call addWell
            
            call downtick
        cmp rax, 0
        jz spaceL
    mdtsp:

    mov r12, 0
    mov r13, 0

    mov rcx, 'A'
    call GetAsyncKeyState
    mov rbx, -1
    cmp al, 0
    jz manz
        mov r12, rbx
        mov rax, 3
        call addWell
    manz:


    mov rcx, 'D'
    call GetAsyncKeyState
    mov rbx, 1
    cmp al, 0
    jz mdnz
        mov r12, rbx
        mov rax, 2
        call addWell
    mdnz:

    mov rax, r12
    mov rbx, 0
    call updcursor

    mov rcx, 'S'
    call GetAsyncKeyState
    cmp al, 0
    jz mdts
        call downtick
        mov rdx, cycle
        mov [rdx], 1;
        mov rax, 5
        call addWell
    mdts:
    

    mov rcx, 'Q'
    call GetAsyncKeyState
    mov rbx, 1
    cmp al, 0
    jz mdtq
        mov rcx, 0
        call cursorDraw
        call flipCCW
        call checkCollision
        cmp al, 0
        jz ccwe
            call flipCW
        ccwe:
        call coloredCD
    mdtq:

    mov rcx, 'E'
    call GetAsyncKeyState
    mov rbx, 1
    cmp al, 0
    jz mdte
        mov rcx, 0
        call cursorDraw
        call flipCW
        call checkCollision
        cmp al, 0
        jz cwe
            call flipCCW
        cwe:
        call coloredCD
    mdte:


    ;return stack space
        mov rsp, rbp
        pop rbp
    ;
ret

flipCCW:
    call flipI
    call flipZ
ret
flipCW:
    call flipZ
    call flipI
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

downtick:
    call genericDowntick
    cmp al, 0
    jz dtr
        
        call resetBlock
        call checkRows
        mov rax, 1
    dtr:
ret

genericDowntick:

    mov rax, 0
    mov rbx, 1
    call updcursor
ret

resetBlock:
    
    mov rdx, cycle
    mov [rdx], 1;

    ;mov rbx, currentPiece
    call bagRandomize
    ;mov [rbx], al
    ;mov rax, 3
    call loadPiece

    call modColor

    mov rdx, cursorX
    mov [rdx], 5
    mov rdx, cursorY
    mov [rdx], 5

ret

clearPlayGrid:
    mov rax, 0
    mov rbx, 0
    mov rcx, playW
    mov rdx, playH
    mov r8, 0
    call playfill

    mov rax, 0
    mov rbx, playH-1
    mov rcx, playW
    mov rdx, 1
    mov r8, 1
    call playfill
    
    mov rax, 0
    mov rbx, 0
    mov rcx, 1
    mov rdx, playH-1
    mov r8, 1
    call playfill

    mov rax, playW-1
    mov rbx, 0
    mov rcx, 1
    mov rdx, playH-1
    mov r8, 1
    call playfill
    

ret

randInt: ;rbx max (randint 0, n noninclusive)  rdx out
    mov rdx, well
    mov rax, [rdx]
    mov rdx, 0
    div rbx
ret

bagRandomize:
    mov rdx, bagLeft
    mov rbx, 0
    mov bl, [rdx]
    dec bl ;dec bagLeft
        ;if neg
        cmp bl, 0
        jnl brr
            call resetBag
        brr:
        mov [rdx], bl
    inc bl
    call randInt

    mov rax, -1

    brL:
        
        inc rax

        mov rbx, bag
        add rbx, rax
        mov bl, [rbx]

        cmp bl, 'X'
        jz brs
            dec rdx
        brs:

        cmp rdx, 0
    jnl brL
    brE:


    mov rcx, bag
    add rcx, rax
    mov [rcx], 'X'

    ;raxout
ret

resetBag:
    mov rdx, bagLeft
    mov [rdx], numPieces-1

    mov rdx, bag
    mov rax, 0

    rbl:
    mov [rdx], rax
    add [rdx], '0'
    inc rdx
    inc rax
    cmp rax, numPieces
    jl rbl

    
    mov rdx, bagLeft
    mov rbx, 0
    mov bl, [rdx]
ret

addWell: ;rax in toadd
    mov rbx, well
    add rax, [rbx]
    mov [rbx], rax
ret

body:    
    ;reserve stack space
        push rbp
        mov rbp, rsp
        sub rsp, 32*16
    ;
    call modTick

    mov rax, 1
    call addWell
    
    mov rax, cycle
    mov rax, [rax]
    cmp rax, 0
    jnz be
        call downtick
    be:
    
    call movement
    call drawGhost
    
    mov rax, 27
        mov rbx, 4
        mov rdx, scoreMsg
    ; call printCanv

        mov rcx, score
        mov rcx, [rcx]
        call int2String

        mov rax, 27
        mov rbx, 5
        mov rdx, printBuffer
        ;call printCanv
        
        mov rax, 2
        mov rbx, 25
        mov rdx, bag
        call printCanv
        
        mov rdx, bagLeft
        mov rcx, 0
        mov cl, [rdx]
        call int2String
        mov rax, 2
        mov rbx, 26
        mov rdx, printBuffer
    call printCanv

    call drawGhostGrid

    
    call drawPlayGrid

    mov rdx, printGrid
    mov r8, printT
    call printConsole

    ;return stack space
        mov rsp, rbp
        pop rbp
    ;
ret

drawGhost:

    mov rax, cursorY
    mov rax, [rax]
    push rax

    bodyL:
        call genericDowntick
    cmp rax, 0
    jz bodyL

    mov rcx, 0
    call cursorDraw

    ;clear ghost grid - abcd 8 13 14
    mov rax, 0
    mov rbx, 0
    mov rcx, simPlayW
    mov rdx, simPlayH
    
    mov r8, 0
    mov r13, simPlayW
    mov r14, ghostGrid
    call genericfill
    

    mov rax, cursorX
    mov rax, [rax]
    dec rax
    mov rbx, cursorY
    mov rbx, [rbx]
    sub rbx, 5
    mov r12, simPlayW
    mov r13, ghostGrid
    mov rcx, 91
    call genericDrawPiece

    pop rax
    mov rbx, cursorY
    mov [rbx], rax
    call coloredCD

ret

drawPiece:
    mov r12, playW
    mov r13, playGrid
    call genericDrawPiece
ret

genericDrawPiece: ;rabx x, y, rcx col
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
            mov rcx, r12;playW
            mov rdx, r13;playGrid
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


loadPiece: ;rax piecenum

    mul rax, 4
    mov rbx, blocks
    add rbx, rax
    mov rax, [rbx]
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
        mov rcx, playW*2+2-2*2
        mov rdx, playH-6
    call fill
    mov r8, 196
        mov rax, playX ;hwalls
        mov rbx, playY-1
        mov rcx, playW*2-2*2
        mov rdx, playH+2-6
    call fill


    mov r8, 218
        mov rax, playX-1
        mov rbx, playY-1
        mov rcx, 1
        mov rdx, 1
    call fill
    mov r8, 192
        mov rax, playX-1
        mov rbx, playY+playH-6
        mov rcx, 1
        mov rdx, 1
    call fill
    mov r8, 191
        mov rax, playX+playW*2-2*2
        mov rbx, playY-1
        mov rcx, 1
        mov rdx, 1
    call fill
    mov r8, 217
        mov rax, playX+playW*2-2*2
        mov rbx, playY+playH-6
        mov rcx, 1
        mov rdx, 1
    call fill


    mov rax, playX
    mov rbx, playY-1
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
    pil2: ;then move to printBuffer
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
    push r13
    push r14

    mov r13, printW
    mov r14, printGrid
    call genericfill

    pop r14
    pop r13
    ;return stack space
        mov rsp, rbp
        pop rbp
    ;
ret

playfill: ;rabcdx X,Y,W,H r8 tofill
    ;reserve stack space
        push rbp
        mov rbp, rsp
        sub rsp, 32*16
    ;
    push r13
    push r14

    mov r13, playW
    mov r14, playGrid
    call genericfill

    pop r14
    pop r13
    ;return stack space
        mov rsp, rbp
        pop rbp
    ;
ret

genericfill: ;r13 W, r14 adr

    push rdx
    push rcx
    mov rcx, r13
    mov rdx, r14
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
        add rdx, r13
    inc r11
    cmp r11, r12
    jl fO
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
    sub rsp, 16*16


    mov r8, playH-1
    dpgO:
        mov r9, playW-2
        dpgI:
            inc r9

            mov rax, r9
            dec rax
            mov rbx, r8
            dec rbx
            mov rcx, playW
            mov rdx, playGrid
            call calcAdr
            mov r10,rdx

            mov rax, r9
            dec rax
            add rax, rax
            add rax, playX-2
            mov rbx, r8
            dec rbx
            add rbx, playY-5

            mov rcx, printW
            mov rdx, printGrid
            call calcAdr

            mov bl, [r10]
            ;sub al, '0'

            mov rcx, colors
            add cl, bl
            mov al, [rcx]

            cmp bl, 0
            jz dpgs
            mov [rdx], al
            inc rdx
            mov [rdx], al
            dpgs:

            dec r9

        dec r9
        cmp r9,0
        jg dpgI
    dec r8
    cmp r8,5
    jg dpgO

    mov rax, 0
    mov rsp, rbp;
    pop rbp;
ret

drawGhostGrid:
    mov rax, playX
    mov rbx, playY
    mov rcx, printW
    mov rdx, printGrid
    call calcAdr

    mov rax, ghostGrid

    mov r8, 0
    dggo:
        mov r10, 0
        push rdx
        dggi:
            mov bl, [rax]
            cmp bl, 0
            jz dggs
                mov [rdx], bl
                inc rdx
                add bl, 2
                mov [rdx], bl
                dec rdx
                
            dggs:
            inc rax
            inc r10
            add rdx, 2
        cmp r10, simPlayW
        jl dggi
        pop rdx
        add rdx, printW

        inc r8
    cmp r8, simPlayH
    jl dggo
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