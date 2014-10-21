; mov si, srcString
; mov di, dstString
; call _strcmp
; srcString �ּҸ� �������� dstString �� ���ڿ��� �Ϻ��� ��ġ�ϴ� ���
; ax register�� 0�� �����
_strcmp:
    push dx

    xor dx, dx
    xor ax, ax
    .L1:
        cmp byte [si], 0
        je .L1END

        mov dh, byte [di]
        cmp dh, byte [si]
        jne .notsame

        inc si
        inc di
        jmp .L1
    .L1END:
    jmp .end
.notsame:
    mov ax, 1
.end:
    pop dx
    ret

; use this!!
; mov cx, 8
; mov si, srcString
; mov di, dstString
; call _back_trim
; srcString �ּҸ� �������� 8��ŭ�� ũ���� ������ ����
; ������ ������ ��, dstString �ּҸ� �������� ���� ������ ���ŵ� ���ڿ��� ����˴ϴ�.
; ������ ���ŵ� ���ڿ��� ���̰��� ax register�� ����Ǿ� ���ϵ˴ϴ�.
; �ش� �Լ��� ������ �����ѵ� ���ڿ� �� �������� NULL ���ڸ� �����մϴ�.
_back_trim:
    push si
    push di
    push cx
    push dx

    xor dx, dx
    ; �޺κ� ������ ����
    add si, cx
    dec si
    ; void* src
    add di, cx
    dec di
    ; void* dst
    mov byte [di + 1], 0
.copy:
    mov al, byte [si]
    mov byte [di], 0

    cmp al, 0x20
    je .copy_end

    inc dx
    mov byte [di], al
.copy_end:
    dec di
    dec si
    loop .copy

    mov ax, dx
    pop dx
    pop cx
    pop di
    pop si
    ret
