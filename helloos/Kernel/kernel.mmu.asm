; ����¡ �ʱ�ȭ �Լ�
_kernel_init_paging:
	mov ax, DataDescriptor
	mov es, ax

	;mov eax, _protect_entry.end_kernel
	;and eax, 0xFFFFF000
	;add eax, 0x1000
	mov eax, 0x00402000
	; �̺κ��� ���� kernel.memory_map.txt ������ �޸� �� ����
	mov dword [PageDirectory], eax
	; Ŀ���� ������ �κп� �ٷ�
	; ������ ���丮 ����

	; ����¡ ó���� ���� ���� ���
	; ������ ���� �޸� �ּ��� ���� �ȿ��� ��� �� �� �����Ƿ�
	; ����¡ ����� ���� ���� �޸𸮸� ����Ѵ�.
	;-----------------------------------------------------------
	; Page Directory init
	;-----------------------------------------------------------
	mov edi, dword [PageDirectory]
	; ������ ���丮�� ��ġ�� �޸� �ּ�
	mov eax, 0 | 2
	; ��������, �б�/����, ���翩��
	mov ecx, 1024
	; ������ ����
.page_directory_init:
	mov dword [edi], eax

	add edi, 4
	; ���� �ε����� ����Ű���� �Ѵ�.
	loop .page_directory_init

	;-----------------------------------------------------------
	; Page Table init
	;-----------------------------------------------------------
	mov edi, dword [PageDirectory]
	add edi, 0x1000
	; ������ ���丮 �ٷ� �ڿ� ������ ���̺��� ��ġ�Ѵ�.
	mov eax, 0
	mov ecx, 1024
	; ������ ����
.page_table_init:
	mov edx, eax
	or edx, 3
	; �Ӽ� �ο� : ���� ����, �б�/����, ���翩��
	mov dword [edi], edx

	add edi, 4
	add eax, 0x1000
	; ���� ������ ������ �ּҸ� ����Ű���� �Ѵ�.
	loop .page_table_init

	;-----------------------------------------------------------
	; ������ ���丮�� ù��° ������ ���̺� �ֱ�
	;-----------------------------------------------------------
	mov eax, 0x1000
	mov ecx, 0
	; ecx ��° ������ ���丮 �ּ� ���
	mul ecx
	add eax, dword [PageDirectory]
	add eax, 0x1000
	; ù��° ������ ���̺� �ּ�
	or eax, 3
	; �Ӽ��� �ο� : ���÷���, �б�/����, ���翩��
	mov edi, dword [PageDirectory]
	add edi, 0 * 4
	mov dword [edi], eax
	;-----------------------------------------------------------

	mov eax, dword [PageDirectory]
	mov cr3, eax
	; ������ ���丮 ���� �ּҸ� ���

	;-------------------------------------------
	; ��Ʈ�� Register Setting
	; PG, CD, NW, AM, WP, NE, ET, TS, EM, MP, PE
	;  1   ?   ?   ?   ?   ?   ?   ?   ?   ?   1
	;-------------------------------------------
	mov eax, cr0
	or eax, 0x80000000
	mov cr0, eax
	; ����¡�� �����ϱ� ���� ��Ʈ�� �������Ϳ���
	; �ֻ��� ��Ʈ�� 1�� ����

	push 3
	push 0x0A
	push Paging32SuccessMessage
	call _print32

	ret

PageDirectory:			dd 0x00000000
; ������ ���丮
