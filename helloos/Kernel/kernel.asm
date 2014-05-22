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
	; Ŀ�� ���̺귯��
_start:
	; Kernel Entry Point

	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	; ���� �ӽŻ󿡼� ���׸�Ʈ �ʱ�ȭ �۾��� �������� ���� ���
	; int 0x0D #13 General protection fault ������ �߻� ��Ų��.
	; �̴� GDT ������ �ε�Ǹ鼭 ���׸�Ʈ���� ������ gs, fs ���� ���׸�Ʈ�� �����ϸ鼭
	; ��ϵ��� ���� GDT ������ �����ϱ⿡ �߻��Ǵ� ���ܵ��̴�.
	;
	; �� ��� �ʱ�ȭ �۾��� ������� �ָ� �ȴ�.
	; ���� : http://www.joinc.co.kr/modules/moniwiki/wiki.php/%BA%B8%C8%A3%B8%F0%B5%E5
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	xor eax, eax
	mov es, eax
	mov ds, eax
	mov fs, eax
	mov gs, eax
	; segment init

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
	mov cr0, eax
	; ��ȣ���� ��ȯ

	jmp $+2
	nop
	nop
	; Ȥ�� ���� ������ �� 16bit ��ɾ���� ����

	jmp dword CodeDescriptor:_protect_entry

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
	InfoTrueMessage:			db ' O K ', 0
	InfoFalseMessage:			db 'FALSE', 0
	; TRUE/ FALSE
	KernelProtectModeMessage:	db 'Switching Kernel Protected Mode -- [     ]', 0x0A, 0
	; Ŀ�� ��ȣ��� ���� �Ϸ� �޽���
	A20SwitchingCheckMessage:	db 'A20 Switching Check -------------- [     ]', 0x0A, 0
	; A20 ����Ī ���� ���ο� ���� �޽���
	EnoughMemoryCheckMessage:	db '64MiB Physical Memory Check ------ [     ]', 0x0A, 0
	; �ּ� 64MiB �̻��� �����޸��ΰ��� ���� �޽���
	Paging32ModeMessage:		db '32bit None-PAE Paging Mode ------- [     ]', 0x0A, 0
	; 32bit ����¡ ó�� �Ϸ� �޽���
	;------------------------------------------------------------------------------------

_protect_entry:
	; 32bit Protected Mode ���� ��Ʈ�� ����Ʈ ����
	push 0x07
	push KernelProtectModeMessage
	call _print32
	; ��ȣ��� ��ȯ �޽���

	mov esi, 0
	mov edi, .chk_pm_true
	jmp .info_true
.chk_pm_true:
	; ��ȣ��� ��ȯ ����

	;-------------------------------------------------------------
	; A20 Ȱ��ȭ �� �޸� üũ
	;-------------------------------------------------------------
	call _set_a20_mode
	; A20 ����� Ȱ��ȭ �Ѵ�.

	call _test_a20_mode
	; �� �κп��� A20 ����� Ȱ��ȭ ���θ� �׽�Ʈ

	push 0x07
	push A20SwitchingCheckMessage
	call _print32
	; A20 ����Ī ó�� �޽���

	cmp ax, 0
	je .info_false
	; A20 ��ȯ ������ ��� �̹Ƿ�
	; �ý����� ���� ��Ų��.

	mov esi, 1
	mov edi, .chk_a20_true
	jmp .info_true
.chk_a20_true:
	; A20 ����� Ȱ��ȭ �Ǿ�����

	call _kernel_is_enough_memory
	; OS ���࿡ �ʿ��� �ּ����� 64MB �޸𸮰� �����ϴ��� üũ

	push 0x07
	push EnoughMemoryCheckMessage
	call _print32

	cmp ax, 0
	je .info_false
	; �޸� �������� ���� ������ ��� �̹Ƿ�
	; �ý����� ���� ��Ų��.

	mov esi, 2
	mov edi, .chk_mem_true
	jmp .info_true
.chk_mem_true:
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
	; ����� ���� ��� �ּҴ� ���ּҷ� �ؼ���...

	push 0x07
	push Paging32ModeMessage
	call _print32
	; ����¡ ���� �޽���

	mov esi, 3
	mov edi, .chk_paging_true
	jmp .info_true
.chk_paging_true:
	; ����¡ ��� Ȱ��ȭ �Ϸ�

	mov ax, 0
	call _mask_pic
	; ��� PIC Ȱ��ȭ

	sti
	; ���ͷ�Ʈ Ȱ��ȭ

	mov di, TSSDescriptor
	call _kernel_load_tss
	; TSS ����

;	;-------------------------------------------------------------
;	; ���ͷ�Ʈ �߻� �׽�Ʈ
;	; �������� ���ͷ�Ʈ ���ܸ� ���������� �߻���Ų��.
;	;-------------------------------------------------------------
;	; devide error!!
;	mov eax, 10
;	mov ecx, 0
;	div ecx

;	;-----------------------------------------------------------------------
;	; 0xF0000000�� �� �ּҸ� 0x01000000�� ���� �޸� �ּҷ� Mapping
;	; Ŀ�� �޸� �Ҵ� �׽�Ʈ
;	;-----------------------------------------------------------------------
;	push 0xF0000000
;	push 0x01000000
;	push (0xF0001000-0xF0000000)/0x1000
;	call _kernel_alloc
;
;	; page fault!!
;	mov ecx, 0x12345678
;	mov dword [0xF0000000], ecx
	;-------------------------------------------------------------

;	push 0xE0000000
;	push 0x00900000
;	push (0xE0001000-0xE0000000)/0x1000
;	call _kernel_alloc
;	; Ŀ�� ������ ���� �޸� �Ҵ�
;
;	mov ecx, 0x12345678
;	mov dword [0xE0000000], ecx
.end_kernel:
	hlt
	jmp .end_kernel

.info_false:
	push esi
	push 36
	call _print32_gotoxy

	push 0x04
	push InfoFalseMessage
	call _print32
	jmp .end_kernel

.info_true:
	push esi
	push 36
	call _print32_gotoxy

	push 0x0A
	push InfoTrueMessage
	call _print32

	inc esi
	push esi
	push 0
	call _print32_gotoxy
	; �����ٷ� ������ �̵�
	jmp edi
