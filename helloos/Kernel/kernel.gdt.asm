;--------------------------------------------------------
; Global Descriptor Table
;--------------------------------------------------------
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
