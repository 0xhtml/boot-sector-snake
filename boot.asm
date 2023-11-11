%define DIRECTION 0x0500
%define APPLE 0x0502
%define LIST_START 0x0504
%define LIST_END 0x0506

org 0x7c00

start:
    mov [DIRECTION], word 0x0001  ; right
    mov [APPLE], word 0x0c0b
    mov [LIST_START], word 0x0508
    mov [LIST_END], word 0x0508
    mov [0x0508], word 0x0c0a

    mov ax, 0x0000  ; clear screen
    int 0x10

    mov ah, 0x01  ; disable cursor
    mov ch, 0x3f
    int 0x10

    mov ax, 0x0ab2  ; print repeated char, border char
    mov bh, 0
    mov cx, 40  ; repeat char 40 times
    int 0x10

    mov ah, 0x02  ; set cursor
    mov dx, 0x1800  ; lower left corner
    int 0x10

    mov ah, 0x0a  ; print repeated char
    int 0x10

tick:
    mov si, [LIST_END]
    mov dx, [si]
    add dx, [DIRECTION]

    cmp dl, -1
    jle gameover

    cmp dh, 0
    jle gameover

    cmp dl, 40
    jge gameover

    cmp dh, 24
    jge gameover

    mov si, [LIST_START]

tick_loop:
    cmp dx, [si]
    je gameover

    add si, 2

    cmp si, [LIST_END]
    jbe tick_loop

    mov ah, 0x02  ; set cursor
    int 0x10

    mov ax, 0x0edb  ; print char, snake char
    int 0x10

    mov [si], dx
    mov [LIST_END], si

    cmp dx, [APPLE]
    jne tick_end

    mov ah, 0x00  ; get time
    int 0x1a

    imul dx, 29
    add dx, 37

    cmp dl, 40
    jb tick_skip_l

tick_sub_l:
    sub dl, 40
    cmp dl, 40
    jae tick_sub_l

tick_skip_l:
    cmp dh, 23
    jb tick_skip_h

tick_sub_h:
    sub dh, 23
    cmp dh, 23
    jae tick_sub_h

tick_skip_h:
    inc dh

    mov [APPLE], dx

    mov ah, 0x02  ; set cursor
    int 0x10

    mov ax, 0x0e04  ; print char, apple char
    int 0x10

    jmp sleep

tick_end:
    mov si, [LIST_START]
    mov dx, [si]

    mov ah, 0x02  ; set cursor
    int 0x10

    mov ax, 0x0e20  ; print char, snake char
    int 0x10

    add word [LIST_START], 2

sleep:
    mov ah, 0x86  ; sleep
    mov cx, 0x0002
    mov dx, 0x0000
    int 0x15

input:
    mov ah, 0x01  ; get key queue length
    int 0x16
    jz tick

    mov ah, 0x00  ; get key
    int 0x16

    cmp ah, 0x48  ; up key
    je input_up

    cmp ah, 0x4b  ; left key
    je input_left

    cmp ah, 0x4d  ; right key
    je input_right

    cmp ah, 0x50  ; down key
    jne input

input_down:
    cmp [DIRECTION], byte 0x00
    je input

    mov [DIRECTION], word 0x0100
    jmp tick

input_up:
    cmp [DIRECTION], byte 0x00
    je input

    mov [DIRECTION], word 0xff00
    jmp tick

input_left:
    cmp [DIRECTION], byte 0x00
    jne input

    mov [DIRECTION], word 0xffff
    jmp tick

input_right:
    cmp [DIRECTION], byte 0x00
    jne input

    mov [DIRECTION], word 0x0001
    jmp tick

gameover:
    mov ah, 0x02  ; set cursor
    mov dx, 0x0c0f  ; position
    int 0x10

    mov ah, 0x0e  ; print char
    mov dx, 0  ; char index

gameover_loop:
    mov al, [gameover_str+edx]  ; char
    int 0x10

    inc dx

    cmp dx, gameover_str_len
    jb gameover_loop

    jmp $  ; halt

gameover_str db "Game Over!"
gameover_str_len equ $ - gameover_str

times 510-($-$$) db 0
db 0x55, 0xaa
