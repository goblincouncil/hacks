; boot-snake: a 512-byte boot sector snake. nasm -f bin snake.asm -o snake.bin
; No game grid: text video memory is the state. The cell under the head says
; food ('*'), body ('o') or empty. The body is a ring buffer of cell offsets.
; si=head offset  di=step (+-2, +-160)  bx=tail ptr  bp=head ptr
bits 16
org 0x7c00
    xor ax,ax
    mov ds,ax
    mov ax,3            ; 80x25 text, clears screen
    int 0x10
    mov ax,0xb800
    mov es,ax
    mov si,2000         ; row 12, col 40
    mov di,2            ; heading right
    xor bx,bx
    xor bp,bp
    mov [0x8000],si
    mov word [es:si],0x0a6f
    call food
main:
    mov cx,2            ; two BIOS ticks, about 110 ms
.d: hlt
    loop .d
    mov ah,1
    int 0x16
    jz nokey
    mov ah,0
    int 0x16
    cmp ah,0x48
    jne .a
    mov di,-160
.a: cmp ah,0x50
    jne .b
    mov di,160
.b: cmp ah,0x4b
    jne .c
    mov di,-2
.c: cmp ah,0x4d
    jne nokey
    mov di,2
nokey:
    add si,di
    cmp si,4000         ; unsigned: also catches going above the top
    jae dead
    mov ax,[es:si]
    cmp al,'o'
    je dead
    cmp al,'*'
    jne move
    call food           ; ate: grow, so leave the tail alone
    jmp short grow
move:
    push bx             ; erase the tail cell
    mov bx,[bx+0x8000]
    mov word [es:bx],0x0720
    pop bx
    add bx,2
    and bx,0xfff
grow:
    add bp,2
    and bp,0xfff
    mov [bp+0x8000],si
    mov word [es:si],0x0a6f
    jmp main
dead:
    int 0x19            ; game over: reboot into a fresh snake
food:
    rdtsc
    xor edx,edx
    mov ecx,2000
    div ecx
    add dx,dx
    xchg bx,dx
    cmp word [es:bx],0x0720
    jne .r
    mov word [es:bx],0x0c2a
.r: xchg bx,dx
    jne food
    ret
times 510-($-$$) db 0
dw 0xaa55
