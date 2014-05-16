[bits	16]
[org	0x8000]

jmp _entry
nop
; nop ��ɾ ���� �ùٸ� Ŀ������ �ƴ����� üũ�ϹǷ�
; Ŀ�� �������� 3byte �κ��� ���� ������ nop ��ɾ� �ڵ尡
; ��ġ�ؾ� �Ѵ�.

_entry:
	jmp _start
	; �� �κп� ���� ���̺귯�� �Լ� ���ϵ��� include �ȴ�.

	%include "../Bootloader/loader.print.asm"
	%include "../Bootloader/loader.debug.dump.asm"
	; �⺻ ���̺귯���� ��� ��Ʈ�δ����� �Լ��� �״�� ������ ����Ѵ�.
	%include "../Bootloader/loader.graphice.asm"
	; vesa ���� bios �Լ� ���̺귯��
	%include "../Bootloader/loader.vesa.mode.asm"
	; vesa ���� ��� ��� ����
	; Ŀ�� ���̺귯��
_start:
	; Kernel Entry Point
	push 0
	push 0x0A
	push KernelLoadingMessage
	call _print

	; ��ȯ�� �ػ� ���� ����
	mov word [VesaResolutionInfo.XResolution], 1024
	mov word [VesaResolutionInfo.YResolution], 768
	mov byte [VesaResolutionInfo.BitsPerPixel], 32

	;call _auto_resolution_vesa_mode
	; �׷��� ���� �ػ� ����

	cli
	; �� �κп��� 32bit Protected Mode �� ��ȯ�� �غ� �Ѵ�.

	lgdt [gdtr]
	; GDT ���� �ε�

	;-------------------------------------------
	; ��Ʈ�� Register Setting
	; PG, CD, NW, AM, WP, NE, ET, TS, EM, MP, PE
	;  0   1   0   0   0   1   1   1   0   1   1
	;-------------------------------------------
	mov eax, cr0
	or eax, 0x00000001
	;mov eax, 0x4000003B
	mov cr0, eax
	; ��ȣ���� ��ȯ

	jmp $+2
	nop
	nop
	; Ȥ�� ���� ������ �� 16bit ��ɾ���� ����

	jmp dword CodeDescriptor:_protect_entry

.super_failure:
	push 1
	push 0x04
	push NotSuperVideoModeMessage
	call _print
	; VBE 2.0 �̻� �������� �ʴ� ���
.end_loader:
	hlt
	jmp .end_loader

;----------------------------------------------
; ��ȣ��� ����
;----------------------------------------------
[bits	32]
[org	0x8000]

_library:
	%include "kernel.print.asm"
	%include "kernel.debug.dump.asm"
	; ȭ�� ��� �Լ�
	%include "kernel.gdt.asm"
	; gdt table ����
	;%include "kernel.file.asm"
	; ���ϰ�θ� ���ڷ� �Ͽ� �ش� ������ ������ �����ϴ� �Լ�
	%include "kernel.vesa.graphice.asm"
	; 32bit Ŀ�ο� �׷��� ��� ��ȯ ���̺귯��
	; ���� ī�� ǥ�ؿ� ���� VESA ó���� ���� ���̺귯��
	%include "kernel.a20.mode.asm"
	; 32bit ���� 64KB ������ �޸𸮸� ���� ������ ������ Ǯ�� ����
	; A20 ��� Ȱ��ȭ ���̺귯��
	%include "kernel.mmu.asm"
	; �޸� ���� �Լ�(����¡ ó��)
	%include "kernel.interrupt.asm"
	; ���ͷ�Ʈ ���� ó�� �Լ�
	%include "kernel.pic.asm"
	; pic ���� �Լ� ���̺귯��

_global_variables:
	;------------------------------------------------------------------------------------
	; ���� ó��
	KernelLoadingMessage:			db 'Kernel Load Success', 0
	; Ŀ�� �ε� �Ϸ� �޽���
	KernelProtectModeMessage:		db 'Switching Kernel Protected Mode', 0
	; Ŀ�� ��ȣ��� ���� �Ϸ� �޽���
	NotSuperVideoModeMessage:		db 'This computer doesn`t support VBE 2.0.', 0
	; �ش� �ػ��� ���� ��� ���� �Ұ� �޽���
	A20SwitchingFailureMessage:		db 'A20 Switching failure', 0
	A20SwitchingSuccessMessage:		db 'A20 Switching success', 0
	; A20 ����Ī ���� ���ο� ���� �޽���
	EnoughMemoryFailureMessage:		db '64MiB Physical Memory check failure', 0
	EnoughMemorySuccessMessage:		db '64MiB Physical Memory check success', 0
	; �ּ� 64MiB �̻��� �����޸��ΰ��� ���� �޽���
	Paging32SuccessMessage:			db '32bit None-PAE Paging Success', 0
	; 32bit ����¡ ó�� �Ϸ� �޽���
	;------------------------------------------------------------------------------------

_protect_entry:
	; 32bit Protected Mode ���� ��Ʈ�� ����Ʈ ����
	push 1
	push 0x0A
	push KernelProtectModeMessage
	call _print32
	; ��ȣ��� ��ȯ ���� �޽���

	;-------------------------------------------------------------
	; A20 Ȱ��ȭ �� �޸� üũ
	;-------------------------------------------------------------
	call _set_a20_mode
	; A20 ����� Ȱ��ȭ �Ѵ�.

	call _test_a20_mode
	; �� �κп��� A20 ����� Ȱ��ȭ ���θ� �׽�Ʈ

	cmp ax, 0
	je .a20_switching_failure
	; A20 ��ȯ ���� Ȥ�� �޸� �������� ���� ������ ��� �̹Ƿ�
	; �ý����� ���� ��Ų��.

	push 2
	push 0x0A
	push A20SwitchingSuccessMessage
	call _print32
	; A20 ����Ī ó�� ����

	call _kernel_is_enough_memory
	; OS ���࿡ �ʿ��� �ּ����� 64MB �޸𸮰� �����ϴ��� üũ

	cmp ax, 0
	je .mem_enough_failure
	; A20 ��ȯ ���� Ȥ�� �޸� �������� ���� ������ ��� �̹Ƿ�
	; �ý����� ���� ��Ų��.
	
	push 3
	push 0x0A
	push EnoughMemorySuccessMessage
	call _print32
	; 64MiB �̻��� �޸𸮰� Ȯ���Ǿ� ����

	call _init_pic
	; pic �ʱ�ȭ ����

	;-------------------------------------------------------------
	; GDT, TSS �ʱ�ȭ
	;-------------------------------------------------------------
	call _kernel_init_gdt_table
	; GDT ���ο� �޸� �ּҿ� ���

	call _kernel_load_gdt
	; GDT �ε�

	;-------------------------------------------------------------
	; ����¡ �� ���ͷ�Ʈ �ʱ�ȭ
	;-------------------------------------------------------------
	call _kernel_init_idt_table
	; ���ͷ�Ʈ ���̺��� �ʱ�ȭ ó�� �� �ش�.

	mov esi, dword [idtr]
	call _kernel_load_idt
	; ���ͷ�Ʈ ��ũ���� ���̺� ���

	call _kernel_init_paging
	; ����¡ �ʱ�ȭ, Ȱ��ȭ
	; �̳��� ����� ���� ��� �ּҴ� ���ּҷ� �ؼ���...

	mov ax, 0
	call _mask_pic
	; ��� PIC Ȱ��ȭ

	sti
	; ���ͷ�Ʈ Ȱ��ȭ

	mov di, TSSDescriptor
	call _kernel_load_tss
	; TSS ����

	;-------------------------------------------------------------
	; ���ͷ�Ʈ �߻� �׽�Ʈ
	; �������� ���ͷ�Ʈ ���ܸ� ���������� �߻���Ų��.
	;-------------------------------------------------------------
	; devide error!!
	mov eax, 10
	mov ecx, 0
	div ecx

	; page fault!!
	;mov ecx, 0x12345678
	;mov dword [0xF0000000], ecx
	;-------------------------------------------------------------

	;push 4
	;push 0x00FF0000
	;call _set_screen_clear
	; ȭ���� ���� �������� �ʱ�ȭ ��
.end_kernel:
	hlt
	jmp .end_kernel

.a20_switching_failure:
	push 2
	push 0x04
	push A20SwitchingFailureMessage
	call _print32
	; A20 ��ȯ ���� Ȥ�� �޸� �������� ���� ����
	jmp .end_kernel

.mem_enough_failure:
	push 3
	push 0x04
	push EnoughMemoryFailureMessage
	call _print32
	; �����޸𸮰� �ּ� 64MiB�� ���� ����
	jmp .end_kernel
	