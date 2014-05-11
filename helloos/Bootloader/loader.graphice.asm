;-------------------------------------------------------
; VBE ���� ���� üũ
;-------------------------------------------------------
_get_vesa_version:
	mov cx, 0
	mov es, cx

	mov di, SuperVGAInfo
	mov ax, 0x4F00
	int 0x10
	; VBE ���� / ���� Ȯ��
	cmp ax, 0x004F
	jne .super_failure
	; �������� �ʰų� �������� ��⿡ ������ ���

	mov ax, word [VersionNumber]
	; ���� ������ ����
	jmp .end
.super_failure:
	xor ax, ax
.end:
	ret

;-------------------------------------------------------
; ȭ�� ��� ���� ���� �� ���� Ȯ��
;-------------------------------------------------------
_get_vesa_vga_info:
	mov di, VESASuperVGAInfo
	; ���� ��忡 ���� ������ ������� ����ü �ּ� ����
	mov ax, 0x4F01
	; Support check
	int 0x10
	; VESA SuperVGA BIOS
	; Get SuperVGA Mode Information
	cmp ax, 0x004F
	jne .end
	; �������� �ʰų� �������� ��⿡ ������ ���

	mov eax, dword [PhysBasePtr]
	mov word [si+2], ax
	shr eax, 16
	mov byte [si+4], al
	mov byte [si+7], ah
	; VGA memory Address Setting
	; VGA Descriptor ���� �ּ� ����

	jmp .end
.error:
	mov word [si+2], 0
	mov byte [si+4], 0
	mov byte [si+7], 0
.end:
	ret

;-------------------------------------------------------
; ȭ�� ��� ��ȯ
;-------------------------------------------------------
_set_vesa_vga_mode:
	mov ax, 0x4F02
	; �׷��� ���� ��ȯ
	mov bx, cx
	int 0x10
	ret

; �ػ󵵿� ���� ��尪�� �ڵ����� �˻��Ͽ� ��ȯ�ϴ� �Լ�
; si ������ ���ϰ��� �ϴ� �ػ󵵿� ���� ������ ��� ����ü�� ������ �ּҸ� ���ڷ� �޴´�.
;
; VirtualBox, VMWare, Machine �� 3���� ���� �׷��� ȭ�� ����� ���� ���������̹Ƿ�
; ���� �κ��� ������ ������ ��尪�� �ϳ��� ������Ű�鼭 Ȯ�� �� ��ġ �� ��� ��带 ��ȯ ��Ų��.
_auto_resolution_vesa_mode:
	;-------------------------------------------------------
	; VBE ���� ���� üũ
	;-------------------------------------------------------
	call _get_vesa_version
	; ���� ������ ���� ��� ax ���� �ش� ������ ���� ���� ����
	; �������� �ʰų� �������� ��⿡ ������ ���
	cmp ax, 0x0200
	jb .super_failure

	mov cx, 0x4100
	; 640*400,8bit LFB���� �˻� ����
.loop:
	;-------------------------------------------------------
	; ȭ�� ��� ���� ���� �� ���� Ȯ��
	;-------------------------------------------------------
	mov si, gdtr + 6 + VGADescriptor
	call _get_vesa_vga_info
	; ȭ�� ��� ���� ���� �� ������ Ȯ�� �� ������ ���
	; VGA ��ũ���� ���̺� �޸� �����ּҸ� ������Ʈ �Ѵ�.
	inc cx
	; ã���� �ϴ� �ػ󵵿� ������ �ƴѰ�� ���� ��尪��
	; üũ�ϱ� ���� ȭ���� ���� 1 ���� ��Ų��.

	mov ax, word [VesaResolutionInfo.XResolution]
	cmp word [XResolution], ax
	jne .loop
	mov ax, word [VesaResolutionInfo.YResolution]
	cmp word [YResolution], ax
	jne .loop
	mov al, byte [VesaResolutionInfo.BitsPerPixel]
	cmp byte [BitsPerPixel], al
	jne .loop
	; �ػ�, ���� ��ġ���� Ȯ��

	;-------------------------------------------------------
	; ȭ�� ��� ��ȯ
	;-------------------------------------------------------
	call _set_vesa_vga_mode
	; �׷��� ���� ��ȯ
	cmp ax, 0x004F
	jne .loop
	; ���ϴ� ��尪�� ã�� ���
	; ȭ���� ��ȯ

	mov ax, 0x4F06
	xor bx, bx
	mov cx, word [VesaResolutionInfo.XResolution]
	int 0x10
	; ��ĵ ���� ����(��) ����

	mov ax, 0x4F07
	xor bx, bx
	xor cx, cx
	xor dx, dx
	int 0x10
	; ���÷��� ��ŸƮ ����

	jmp .end
.super_failure:
	push 1
	push 0x04
	push NotSuperVideoModeMessage
	call _print
	; VBE 2.0 �̻� �������� �ʴ� ���
.end:
	ret

VesaResolutionInfo:
; �׷��� ��� ��ȯ�� ���õ� �ػ� ���� ����ü
	.XResolution:	dw 0
	.YResolution:	dw 0
	.BitsPerPixel:	db 0

SuperVGAInfo					equ 0x8000
	Signature					equ SuperVGAInfo + 00h
	VersionNumber				equ SuperVGAInfo + 04h
	PointerToOEMName			equ SuperVGAInfo + 06h
	CapabilitiesFlags			equ SuperVGAInfo + 0Ah
	OEMVideoModes				equ SuperVGAInfo + 0Eh
	TotalAmount					equ SuperVGAInfo + 12h
	; VBE v1.x

	OEMVersion					equ SuperVGAInfo + 14h
	PointerToVendorName			equ SuperVGAInfo + 16h
	PointerToProductName		equ SuperVGAInfo + 1Ah
	PointerToProductRevision	equ SuperVGAInfo + 1Eh
	VBEversion					equ SuperVGAInfo + 22h
	SupportedVideoModes			equ SuperVGAInfo + 24h
	;times 216	db 0
	; 216bytes reserved for VBE implementation
	;times 256	db 0
	; 256bytes OEM scratchpad
	; VBE v2.0

VESASuperVGAInfo				equ 0x8200
	ModeAttributes				equ VESASuperVGAInfo + 00h
	WinAttributesA				equ VESASuperVGAInfo + 02h
	WinAttributesB				equ VESASuperVGAInfo + 03h
	WinGranularity				equ VESASuperVGAInfo + 04h
	WinSize						equ VESASuperVGAInfo + 06h
	WinSegmentA					equ VESASuperVGAInfo + 08h
	WinSegmentB					equ VESASuperVGAInfo + 0Ah
	WinFuncPtr					equ VESASuperVGAInfo + 0Ch
	BytesPerScanLine			equ VESASuperVGAInfo + 10h
	; All VBE revisions

	XResolution					equ VESASuperVGAInfo + 12h
	YResolution					equ VESASuperVGAInfo + 14h
	XCharSize					equ VESASuperVGAInfo + 16h
	YCharSize					equ VESASuperVGAInfo + 17h
	NumberOfPlanes				equ VESASuperVGAInfo + 18h
	BitsPerPixel				equ VESASuperVGAInfo + 19h
	NumberOfBanks				equ VESASuperVGAInfo + 1Ah
	MemoryModel					equ VESASuperVGAInfo + 1Bh
	BankSize					equ VESASuperVGAInfo + 1Ch
	NumberOfImagePages			equ VESASuperVGAInfo + 1Dh
	Reserved0					equ VESASuperVGAInfo + 1Eh
	; VBE 1.2 and above

	RedMaskSize					equ VESASuperVGAInfo + 1Fh
	RedFieldPosition			equ VESASuperVGAInfo + 20h
	GreenMaskSize				equ VESASuperVGAInfo + 21h
	GreenFieldPosition			equ VESASuperVGAInfo + 22h
	BlueMaskSize				equ VESASuperVGAInfo + 23h
	BlueFieldPosition			equ VESASuperVGAInfo + 24h
	RsvdMaskSize				equ VESASuperVGAInfo + 25h
	RsvdFieldPosition			equ VESASuperVGAInfo + 26h
	DirectColorModeInfo			equ VESASuperVGAInfo + 27h
	; Direct color fields

	PhysBasePtr					equ VESASuperVGAInfo + 28h
	Reserved1					equ VESASuperVGAInfo + 2Ch
	Reserved2					equ VESASuperVGAInfo + 30h
	; VBE 2.0 and above

	LinBytesPerScanLine			equ VESASuperVGAInfo + 32h
	BnkNumberOfImagePages		equ VESASuperVGAInfo + 34h
	LinNumberOfImagePages		equ VESASuperVGAInfo + 35h
	LinRedMaskSize				equ VESASuperVGAInfo + 36h
	LinRedFieldPosition			equ VESASuperVGAInfo + 37h
	LinGreenMaskSize			equ VESASuperVGAInfo + 38h
	LinGreenFieldPosition		equ VESASuperVGAInfo + 39h
	LinBlueMaskSize				equ VESASuperVGAInfo + 3Ah
	LinBlueFieldPosition		equ VESASuperVGAInfo + 3Bh
	LinRsvdMaskSize				equ VESASuperVGAInfo + 3Ch
	LinRsvdFieldPosition		equ VESASuperVGAInfo + 3Dh
	MaxPixelClock				equ VESASuperVGAInfo + 3Eh
	; VBE 3.0 and above

	Reserved3					equ VESASuperVGAInfo + 42h
	; 190bytes remainder of ModelInfoBlock
