_kernel_init_gdt_table:
	mov ax, DataDescriptor
	mov es, ax

	mov esi, dword [gdtr_addr]
	mov word [esi], 0
	mov dword [esi+2], 0

	push NullDescriptor
	push 0x00000000
	push 0x00000000
	push 000000000000b
	call _kernel_set_gdt

	push CodeDescriptor
	push 0x000FFFFF
	push 0x00000000
	push 110010011010b
	call _kernel_set_gdt

	push DataDescriptor
	push 0x000FFFFF
	push 0x00000000
	push 110010010010b
	call _kernel_set_gdt

	push VideoDescriptor
	push 0x000FFFFF
	push 0x000B8000
	push 010010010010b
	call _kernel_set_gdt

	push VGADescriptor
	push 0x000FFFFF
	push 0x00000000
	push 110010010010b
	call _kernel_set_gdt

	push TSSDescriptor
	push 0x000FFFFF
	push 0x00400500
	push 100010001001b
	call _kernel_set_gdt

	ret

; void kernel_set_gdt(BYTE segment_number, DWORD size, DWORD base_addr, WORD options);
_kernel_set_gdt:
	push ebp
	mov ebp, esp
	pusha

	mov ax, DataDescriptor
	mov es, ax

	mov esi, dword [gdtr_addr]
	mov di, word [esi]
	add di, 8
	mov word [esi], di
	; GDT SIZE ����
	; GDT Entry Size ��ŭ �������ν� ��ü ũ�⸦ ���� ��Ų��.
	mov eax, esi
	add eax, 6
	mov dword [esi+2], eax
	; GDT ���� �ּ� ����
	add esi, 6
	; esi�� GDT ���� �κ����� �ּҰ� ����
	mov eax, dword [ebp+20]
	; �߰��Ϸ��� GDT ��Ʈ�� ������
	; �޸� ���� ��ġ �ּҰ� ���
	add esi, eax

	mov eax, dword [ebp+16]
	; segment size
	mov word [esi], ax
	shr eax, 16
	and al, 0x0F
	; segment size ���� 4��Ʈ ����
	mov byte [esi+6], al

	mov eax, dword [ebp+12]
	mov word [esi+2], ax
	; base addr ���� 2����Ʈ
	shr eax, 16
	mov byte [esi+4], al
	mov byte [esi+7], ah
	; base addr ���� ���� 1����Ʈ�� ����
	mov eax, dword [ebp+8]
	mov byte [esi+5], al
	mov al, byte [esi+6]
	; P DPL S TYPE : al
	and ah, 0xF0
	; ���� 4��Ʈ ����
	or ah, al
	mov byte [esi+6], ah
	; G D/B L AVL : ah
	; �ɼ� ����

	popa
	mov esp, ebp
	pop ebp
	ret 16

; GDT ���̺� ���
_kernel_load_gdt:
	mov esi, dword [gdtr_addr]
	lgdt [esi]
	ret

; TSS ���׸�Ʈ ����
_kernel_load_tss:
	ltr di
	ret

;--------------------------------------------------------
; Global Descriptor Table
;--------------------------------------------------------
gdtr_addr:		dd 0x00400000
gdtr:
	dw gdtEnd - gdt - 1	; GDT Table ��ü Size
	dd gdt				; GDT Table �� ���� ���� �ּ�
gdt:
	NullDescriptor equ 0x00
		dd 0, 0

	CodeDescriptor equ 0x08
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 10011010b
		db 11001111b
		db 0x00

	DataDescriptor equ 0x10
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 10010010b	; P DPL S TYPE
		db 11001111b	; G D/B L AVL SEGMENT_SIZE
		db 0x00

	VideoDescriptor equ 0x18
	; ���� ���׸�Ʈ
		dw 0xFFFF
		dw 0x8000
		db 0x0B
		db 10010010b	; P DPL S TYPE
		db 01001111b	; G D/B L AVL SEGMENT_SIZE
		db 0x00

	VGADescriptor equ 0x20
	; �׷���(VGA) ���׸�Ʈ
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 10010010b	; P DPL S TYPE
		db 11001111b	; G D/B L AVL SEGMENT_SIZE
		db 0x00

	TSSDescriptor equ 0x28
	; TSS ���׸�Ʈ ��ȣ ����
	; ���� ����� ���� _kernel_init_gdt_table(); �Լ��� �̿��Ͽ�
	; �ٽ� �� ����Ѵ�.
gdtEnd:
;-------------------------------------------------------------------
; {{Descriptor Description}}
;
; dw 0xFFFF
; [SEGMENT SIZE]
; 1111 1111 1111 1111
; �� �κ��� ���� �Ʒ� SEGMENT SIZE �� 4bit ���� ���Ͽ�
; �� 20bit�� ���׸�Ʈ�� ũ�⸦ ��Ÿ����
; [G] : 0 -> 0 byte ~ 1 Mbyte
; [G] : 1 -> 0 byte ~ 4 Gbyte ( * 4 Kbyte)

; dw 0x0000
; �����ּ� ���� 16 bit

; db 0x00
; �����ּ� ���� 8 bit

; db 10011010b
; [P] [DPL] [S] [TYPE]
;  1   00    1   1 010
; ��ȿ / ���۱��� / ���׸�Ʈ / �ڵ�:����,�б�

; db 11001111b
; [G] [D/B] [L] [AVL] [SEGMENT SIZE]
;  1    1    0    0        1111
; [G] : �ּ� ������ 0 ~ 4 Gbyte���� Ȯ��
; [D/B] : 32 bit Segment
; [AVL] : 64 bit Mode ���� 32 bit ȣȯ Segment ���� �ǹ�
; [SEGMENT SIZE] : ���׸�Ʈ ũ���� ���� 4 bit

; db 0x00
; ���� �ּ� �ֻ��� 8 bit
;-------------------------------------------------------------------
