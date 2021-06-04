%define DIRECTION [0x0500]
%define LENGTH [0x0502]
%define APPLE [0x0504]

org 0x7c00

setup:
    mov ax, 0x0000
    int 0x10

    mov ah, 0x01
    mov ch, 0x3f
    int 0x10

    mov DIRECTION, word 0x0001
    mov LENGTH, word 0
    mov APPLE, word 0x0c0b

    mov si, 0x0506
    mov di, 0x0506
    mov [esi], word 0x0c0a

draw_border:
    mov ax, 0x0ab2
    mov bh, 0
    mov cx, 40
    int 0x10

    mov ah, 0x02
    mov dx, 0x1800
    int 0x10

    mov ah, 0x0a
    int 0x10

    jmp tick

delay:
    mov ah, 0x86
    mov cx, 0x0002
    mov dx, 0x0000
    int 0x15

input:
    mov ah, 0x01
    int 0x16
    jz tick

    mov ah, 0x00
    int 0x16

    cmp ah, 0x48
    je up

    cmp ah, 0x4b
    je left

    cmp ah, 0x4d
    je right

    cmp ah, 0x50
    jne input

down:
    cmp DIRECTION, byte 0x00
    je input

    mov DIRECTION, word 0x0100
    jmp tick

up:
    cmp DIRECTION, byte 0x00
    je input

    mov DIRECTION, word 0xff00
    jmp tick

left:
    cmp DIRECTION, byte 0x00
    jne input

    mov DIRECTION, word 0xffff
    jmp tick

right:
    cmp DIRECTION, byte 0x00
    jne input

    mov DIRECTION, word 0x0001

tick:
    mov dx, [esi]
    add dx, DIRECTION

    cmp dl, -1
    jle gameover

    cmp dh, 0
    jle gameover

    cmp dl, 40
    jge gameover

    cmp dh, 24
    jge gameover

    mov ax, di

tick_loop:
    cmp dx, [eax]
    je gameover

    inc ax

    cmp ax, si
    jl tick_loop

    add si, 2
    mov [esi], dx

    cmp dx, APPLE
    jne render

    add word LENGTH, 2

    mov ah, 0x00
    int 0x1a

    and dl, 0x3f
    cmp dl, 40
    jl tick_a

    sub dl, 40

tick_a:
    and dh, 0x1f
    cmp dh, 23
    jl tick_b

    sub dh, 23

tick_b:
    inc dh

    mov APPLE, dx

    mov ah, 0x02
    int 0x10

    mov ax, 0x0e04
    int 0x10

render:
    mov ah, 0x02
    mov dx, [esi]
    int 0x10

    mov ax, 0x0edb
    int 0x10

    mov dx, si
    sub dx, di
    cmp dx, LENGTH
    jle delay

    mov ah, 0x02
    mov dx, [edi]
    int 0x10

    mov ax, 0x0e20
    int 0x10

    add di, 2
    jmp delay

gameover:
    mov ah, 0x02
    mov dx, 0x0c0f
    int 0x10

    mov dx, gameover_str
    mov ah, 0x0e

gameover_loop:
    mov al, [edx]

    cmp al, 0
    je gameover_end

    int 0x10

    inc dx
    jmp gameover_loop

gameover_end:
    jmp $

gameover_str db "Game Over!", 0

times 510-($-$$) db 0
db 0x55, 0xaa
