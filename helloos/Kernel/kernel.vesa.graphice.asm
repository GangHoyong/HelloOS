; Ư�� �������� ����� ���� ������ �ʱ�ȭ �ϴ� �Լ�
; void set_screen_clear(int rgbCode, sizeof(rgbCode));
_set_screen_clear:
	push ebp
	mov ebp, esp

	mov ecx, 1024*768*4
	; loop Ƚ�� ����

	mov ax, VGADescriptor
	mov es, ax
	; descriptor setting

	mov esi, 0
	mov eax, dword [ebp+8]
	mov ebx, dword [ebp+12]
.L1:
	mov dword [es:esi], eax
	; ȭ�� ������

	add esi, ebx
	loop .L1

	mov esp, ebp
	pop ebp
	ret 8
