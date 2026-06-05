FUNC print_hex
    mov ax, [bp+4]
    mov bx, HEXTABLE
    mov cx, 4
    mov ah, 0x0E

.loop:
    rol ax, 4
    and al, 0x0F
    xlat
    int 0x10
    loop .loop

    RETURN 1

HEXTABLE: db '0123456789ABCDEF'
