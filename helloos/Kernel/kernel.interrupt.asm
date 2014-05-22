; ���� �������Ϳ� ���׸�Ʈ ���¸� ����ϴ� ��ũ��
%macro SEG_REG_SAVE 0
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	push gs
	push fs
	mov ax, es
	push ax
	mov ax, ds
	push ax

	mov ax, DataDescriptor
	mov es, ax
%endmacro
; ���� �������Ϳ� ���׸�Ʈ ���¸� �����ϴ� ��ũ��
%macro SEG_REG_LOAD 0
	pop ax
	mov ds, ax
	pop ax
	mov es, ax
	pop fs
	pop gs

	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
%endmacro

; ���ͷ�Ʈ ���̺� �ʱ�ȭ
_kernel_init_idt_table:
	mov ax, DataDescriptor
	mov es, ax

	; IDT ������ �ö� ���� �޸� �ּ� ����
	; �⺻������ GDT ���� �ٷ� ������ �ö󰣴�.

	mov esi, dword [idtr]
	mov word [esi], 256*8-1
	; IDT ��ü ũ�� �ʱ�ȭ
	mov eax, esi
	add eax, 6
	mov dword [esi+2], eax
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	; IDT ���� ��ġ�� ����											   !
	; �̺κ��� �߸� �����Ǿ� �׵��� ���ͷ�Ʈ�� �ɸ��� ƨ��� ���̿���. !
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	;---------------------------------------------------------------
	; ���� �ڵ鷯 ���
	;---------------------------------------------------------------
	push 0
	push __int_devide_error
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 1
	push __int_debug
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 2
	push __int_nmi
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 3
	push __int_break_point
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 4
	push __int_overflow
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 5
	push __int_bound_range_exceeded
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 6
	push __int_invalid_opcode
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 7
	push __int_device_not_available
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 8
	push __int_double_fault
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 9
	push __int_coprocessor_segment_overrun
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 10
	push __int_invalid_tss
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 11
	push __int_segment_not_present
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 12
	push __int_stack_segment_fault
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 13
	push __int_general_protection
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 14
	push __int_page_fault
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 15
	push __int_reserved_15
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 16
	push __int_fpu_error
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 17
	push __int_alignment_check
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 18
	push __int_machine_check
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 19
	push __int_simd_floating_point_exception
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	; #20 ~ #31
	mov ecx, 31-20
.ETC_EXCEPTION_LOOP:
	mov eax, ecx
	add eax, 20

	push eax
	push __int_etc_exception
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	cmp ecx, 0
	dec ecx
	jne .ETC_EXCEPTION_LOOP

	;---------------------------------------------------------------
	; ���ͷ�Ʈ �ڵ鷯 ���
	;---------------------------------------------------------------
	push 32
	push __int_timer
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 33
	push __int_keyboard
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 34
	push __int_slave_pic
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 35
	push __int_serial_port_2
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 36
	push __int_serial_port_1
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 37
	push __int_parallel_port_2
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 38
	push __int_floppy
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 39
	push __int_parallel_port_1
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 40
	push __int_rtc
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 41
	push __int_reserved_41
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 42
	push __int_not_used_42
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 43
	push __int_not_used_43
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 44
	push __int_mouse
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 45
	push __int_coprocessor
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 46
	push __int_hdd_1
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	push 47
	push __int_hdd_2
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	mov ecx, 255-48
.ETC_INTERRUPT_LOOP:
	mov eax, ecx
	add eax, 48

	push eax
	push __int_etc_interrupt
	push CodeDescriptor
	push 0x8E00
	call _kernel_set_idt

	cmp ecx, 0
	dec ecx
	jne .ETC_INTERRUPT_LOOP
	; 256���� ���ͷ�Ʈ���� �ʱ�ȭ ó�� �Ѵ�.

	ret

; Ư�� ���ͷ�Ʈ�� ����ϴ� �Լ�
; void kernel_set_idt(WORD interrupt_number, void(*interrupt_handle)(), WORD segment, WORD options);
; i_interrupt_number ��°�� ���ͷ�Ʈ �Լ��� *interrupt_handle�� ����Ѵ�.
_kernel_set_idt:
	push ebp
	mov ebp, esp
	pusha

	mov ax, DataDescriptor
	mov es, ax

	mov eax, dword [idtr]
	mov esi, eax
	add eax, 6

	;mov ax, word [esi]
	;add ax, 8
	;mov word [esi], ax
	; IDT ��ü ũ�Ⱚ ����

	mov edi, dword [ebp+20]
	shl edi, 3
	add edi, eax
	; edi : �ش� ���ͷ�Ʈ�� ��� ���� �ּ�

	mov eax, dword [ebp+16]
	mov word [edi], ax
	; interrupt handler ���
	
	mov eax, dword [ebp+12]
	mov word [edi+2], ax
	; access segment ���

	mov eax, dword [ebp+8]
	mov al, 1 & 0x3
	mov word [edi+4], ax
	; interrupt options ���

	mov word [edi+6], 0
	; 64bit���� Ȯ�� �ּ�

	popa
	mov esp, ebp
	pop ebp
	ret 16

; IDT �ε� �Լ�
_kernel_load_idt:
	lidt [esi]
	ret

; ���ͷ�Ʈ ó�� �ڵ鷯
; edi : interrupt number
; esi : error code
_kernel_interrupt_handler:
	push 24
	push 0
	call _print32_gotoxy

	push 0x07
	push in_msg
	call _print32

	push 24
	push 12
	push edi
	call _print_hex32

	sub edi, 32
	push edi
	call _send_eoi_to_pic
	; PIC���� ���ͷ�Ʈ ���� ��ȣ ������
	ret

; ���� ó�� �ڵ鷯
; edi : exception number
; esi : error code
_kernel_exception_handler:
	push 23
	push 0
	call _print32_gotoxy

	push 0x07
	push er_msg
	call _print32

	push 23
	push 12
	push edi
	call _print_hex32

	push 23
	push 34
	push esi
	call _print_hex32

	mov eax, cr2
	push 23
	push 52
	push eax
	call _print_hex32
.L1:
	hlt
	jmp .L1
	; ���� �߻��� ������ Ŀ�ο����� ���� �̹Ƿ�
	; ���ѷ����� �����Ų��.

	ret

er_msg: db 'Exception :           , ErrorNo :           , CR2 :           ', 0x0A, 0
in_msg: db 'Interrupt :           ', 0x0A, 0

;-----------------------------------------------------
; Exception handler
;-----------------------------------------------------
; #0, Device Error ISR
__int_devide_error:
	SEG_REG_SAVE

	mov edi, 0
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #1, Debug ISR
__int_debug:
	SEG_REG_SAVE

	mov edi, 1
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #2, NMI ISR
__int_nmi:
	SEG_REG_SAVE

	mov edi, 2
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #3, BreakPoint ISR
__int_break_point:
	SEG_REG_SAVE

	mov edi, 3
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #4, Overflow ISR
__int_overflow:
	SEG_REG_SAVE

	mov edi, 4
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #5, Bound Range Exceeded ISR
__int_bound_range_exceeded:
	SEG_REG_SAVE

	mov edi, 5
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #6, Invalid Opcode ISR
__int_invalid_opcode:
	SEG_REG_SAVE

	mov edi, 6
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #7, Device not available ISR
__int_device_not_available:
	SEG_REG_SAVE

	mov edi, 7
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #8, Double Fault ISR
__int_double_fault:
	SEG_REG_SAVE

	mov edi, 8
	mov esi, dword [ebp+4]
	call _kernel_exception_handler

	SEG_REG_LOAD
	add ebp, 4
	; error code�� ���ÿ��� ����
	iretd

; #9, Coprocessor Segment Overrun ISR
__int_coprocessor_segment_overrun:
	SEG_REG_SAVE

	mov edi, 9
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #10, Invalid TSS ISR
__int_invalid_tss:
	SEG_REG_SAVE

	mov edi, 10
	mov esi, dword [ebp+4]
	call _kernel_exception_handler

	SEG_REG_LOAD
	add ebp, 4
	; error code�� ���ÿ��� ����
	iretd

; #11, Segment Not Present ISR
__int_segment_not_present:
	SEG_REG_SAVE

	mov edi, 11
	mov esi, dword [ebp+4]
	call _kernel_exception_handler

	SEG_REG_LOAD
	add ebp, 4
	; error code�� ���ÿ��� ����
	iretd

; #12, Stack Segment Fault ISR
__int_stack_segment_fault:
	SEG_REG_SAVE

	mov edi, 12
	mov esi, dword [ebp+4]
	call _kernel_exception_handler

	SEG_REG_LOAD
	add ebp, 4
	; error code�� ���ÿ��� ����
	iretd

; #13, General Protection ISR
__int_general_protection:
	SEG_REG_SAVE

	mov edi, 13
	mov esi, dword [ebp+4]
	call _kernel_exception_handler

	SEG_REG_LOAD
	add ebp, 4
	; error code�� ���ÿ��� ����
	iretd

; #14, Page Fault ISR
__int_page_fault:
	SEG_REG_SAVE

	mov edi, 14
	mov esi, dword [ebp+4]
	call _kernel_exception_handler

	SEG_REG_LOAD
	add ebp, 4
	; error code�� ���ÿ��� ����
	iretd

; #15, Reserved ISR
__int_reserved_15:
	SEG_REG_SAVE

	mov edi, 15
	mov esi, dword [ebp+4]
	call _kernel_exception_handler

	SEG_REG_LOAD
	add ebp, 4
	; error code�� ���ÿ��� ����
	iretd

; #16, FPU Error ISR
__int_fpu_error:
	SEG_REG_SAVE

	mov edi, 16
	mov esi, dword [ebp+4]
	call _kernel_exception_handler

	SEG_REG_LOAD
	add ebp, 4
	; error code�� ���ÿ��� ����
	iretd

; #17, Alignment Check ISR
__int_alignment_check:
	SEG_REG_SAVE

	mov edi, 17
	mov esi, dword [ebp+4]
	call _kernel_exception_handler

	SEG_REG_LOAD
	add ebp, 4
	; error code�� ���ÿ��� ����
	iretd

; #18, Machine Check ISR
__int_machine_check:
	SEG_REG_SAVE

	mov edi, 18
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #19, SIMD Floating Point Exception ISR
__int_simd_floating_point_exception:
	SEG_REG_SAVE

	mov edi, 19
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

; #20 ~ #31, Reserved ISR
__int_etc_exception:
	SEG_REG_SAVE

	mov edi, 20
	call _kernel_exception_handler

	SEG_REG_LOAD
	iretd

;-----------------------------------------------------
; interrupt handler
;-----------------------------------------------------
; #32, Timer ISR
__int_timer:
	SEG_REG_SAVE

	mov edi, 32
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #33, Keyboard ISR
__int_keyboard:
	SEG_REG_SAVE

	mov edi, 33
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #34, Slave PIC ISR
__int_slave_pic:
	SEG_REG_SAVE

	mov edi, 34
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #35, Serial Port 2 ISR
__int_serial_port_2:
	SEG_REG_SAVE

	mov edi, 35
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #36, Serial Port 1 ISR
__int_serial_port_1:
	SEG_REG_SAVE

	mov edi, 36
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #37, Parallel Port 2 ISR
__int_parallel_port_2:
	SEG_REG_SAVE

	mov edi, 37
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #38, floppy Disk Controller ISR
__int_floppy:
	SEG_REG_SAVE

	mov edi, 38
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #39, Parallel Port 1 ISR
__int_parallel_port_1:
	SEG_REG_SAVE

	mov edi, 39
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #40, RTC ISR
__int_rtc:
	SEG_REG_SAVE

	mov edi, 40
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #41, Reserved ISR
__int_reserved_41:
	SEG_REG_SAVE

	mov edi, 41
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #42, Not Used ISR
__int_not_used_42:
	SEG_REG_SAVE

	mov edi, 42
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #43, Not Used ISR
__int_not_used_43:
	SEG_REG_SAVE

	mov edi, 43
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #44, Mouse ISR
__int_mouse:
	SEG_REG_SAVE

	mov edi, 44
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #45, Coprocessor ISR
__int_coprocessor:
	SEG_REG_SAVE

	mov edi, 45
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #46, HardDisk 1 ISR
__int_hdd_1:
	SEG_REG_SAVE

	mov edi, 46
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #47, HardDisk 2 ISR
__int_hdd_2:
	SEG_REG_SAVE

	mov edi, 47
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

; #48, Etc Interrupt ... ISR
__int_etc_interrupt:
	SEG_REG_SAVE

	mov edi, 48
	call _kernel_interrupt_handler

	SEG_REG_LOAD
	iretd

;---------------------------------------
; -------------------------------
; | P | DPL | 0 | D | 1 | 1 | 0 |
; -------------------------------
; P : ���� ����
; DPL : Ư�� ����(2bit)
; D : 16bit ����? 32bit ����?
;---------------------------------------
idtr:			dd 0x00401000
;	dw 256 * 8 - 1
;	dd 0
;__idt_nothing:
;	dw __int_nothing	; Handler Address1
;	dw CodeDescriptor
;	dw 0x00, 0x8E		; 10001110b : ���� 1byte : Option Information
;	dw 0x0000			; Handler Address2
