; I/O Port �Լ�
;
; o port byte
_out_port_byte:
	out dx, al
	ret

; o port word
_out_port_word:
	out dx, ax
	ret

; i port byte
_in_port_byte:
	in al, dx
	ret

; i port word
_in_port_word:
	in ax, dx
	ret

; PIC ���� Master�� Slave�� �ʱ�ȭ �����ϴ� �Լ�
_init_pic:
	mov dl, 0x20
	mov al, 0x11
	call _out_port_byte
	; LTIM : 0, SNGL : 0, IC4 : 1
	mov dl, 0x21
	mov al, 0x20
	call _out_port_byte
	; 0 ~ 31�� �ý��ۿ��� ���� ó���� ����Ϸ� ����� ���� �̹Ƿ�
	; 32�� ���� ���� ���
	mov dl, 0x21
	mov al, 0x04
	call _out_port_byte
	; �����̺� ��Ʈ�ѷ� -> ������ ��Ʈ�ѷ� PIC 2���� ����
	mov dl, 0x21
	mov al, 0x01
	call _out_port_byte
	; uPM : 1

	mov dl, 0xA0
	mov al, 0x11
	call _out_port_byte
	; LTIM : 0, SNGL : 0, IC4 : 1
	mov dl, 0xA1
	mov al, 0x20 + 8
	call _out_port_byte
	; ���ͷ�Ʈ ���͸� 40������ �Ҵ�
	mov dl, 0xA1
	mov al, 0x02
	call _out_port_byte
	; �����̺� ��Ʈ�ѷ� -> ������ ��Ʈ�ѷ� PIC 2���� ����
	mov dl, 0xA1
	mov al, 0x01
	call _out_port_byte
	; uPM : 1
	ret

; Ư�� ���ͷ�Ʈ�� �߻���Ű�� �ʵ��� �����ϴ� �Լ�
; eax : maks_int_num
_mask_pic:
	mov dl, 0x21
	call _out_port_byte
	; IRQ 0 ~ IRQ 7 ���� ����ũ ����
	; �ش� ��Ʈ�� 1�� ���õ� ��� ���ͷ�Ʈ�� ȣ����� �ʴ´�.
	; Master PIC

	shr ax, 8
	mov dl, 0xA1
	call _out_port_byte
	; IRQ 8 ~ IRQ 15
	; Slave PIC
	ret

; EOI ó���� �Լ�
; eoi : end of interrupt
; void send_eoi_to_pic(int eoi_int_num);
_send_eoi_to_pic:
	push ebp
	mov ebp, esp
	pusha

	mov eax, dword [ebp+8]

	mov dl, 0x20
	mov al, 0x20
	call _out_port_byte
	; Master PIC���� EOI ����

	cmp eax, 8
	jb .end
	; IRQ ��ȣ�� 8�̻��� ��� �����̺� PIC ���ͷ�Ʈ �̹Ƿ� �����̺� PIC���Ե�
	; EOI ����

	mov dl, 0xA0
	mov al, 0x20
	call _out_port_byte
	; Master PIC���� EOI ����
.end:
	popa
	mov esp, ebp
	pop ebp
	ret 4
