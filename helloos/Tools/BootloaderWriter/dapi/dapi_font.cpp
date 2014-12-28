#include "dapi_engine.h"

DAPI::CFont::CFont()
{
	DAPI_InitlizeObject(&(this->pDevice));

	this->nFontCount = 0;
}

DAPI::CFont::~CFont()
{
	for (int i = 0; i < this->nFontCount; i++)
	{
		if (this->hFont[i] != NULL) DeleteObject(this->hFont[i]);
	}
}

/*
public

@brief  �۲� ������ �ε��ϴ� �Լ�
@param  name �۲� �̸�
@param  size �۲� ũ��
@param  style �۲� �Ӽ�
@return ������ �۲��� index
*/
int DAPI::CFont::LoadFont(const LPCTSTR name, int size, int style)
{
	this->hFont[this->nFontCount] = CreateFont(size, 0, 0, 0, style, FALSE, FALSE, FALSE, 
		ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, 
		VARIABLE_PITCH | FF_ROMAN, name);

	return this->nFontCount++;
}

/*
public

@brief  ȭ�鿡 �۾��� ����ϴ� �Լ�
@param  wndIndex ����� ������ index
@param  fontIndex ����� �۲� �Ӽ� index
@param  text ����� �ؽ�Ʈ
@param  x ����� �ؽ�Ʈ x ��ǥ
@param  y ����� �ؽ�Ʈ y ��ǥ
@param  rgbFont �۾� ����
@param  rgbBackColor �۾� ��� ����
@return TRUE
*/
BOOL DAPI::CFont::Text(int wndIndex, int fontIndex, const LPCTSTR text, int x, int y, COLORREF rgbFont, COLORREF rgbBackColor)
{
	if (this->pDevice->GetDeviceStatus(wndIndex) == DAPI::D_INVALID) return FALSE;

	DAPI::DAPI_DeviceStruct * deviceinfo = this->pDevice->GetDeviceInfo(wndIndex);
	HFONT hOldFont = (HFONT)SelectObject(deviceinfo->hMemDC, this->hFont[fontIndex]);

	SetTextColor(deviceinfo->hMemDC, rgbFont);
	SetBkColor(deviceinfo->hMemDC, rgbBackColor);
	TextOut(deviceinfo->hMemDC, x, y, text, _tcsclen(text));
	SelectObject(deviceinfo->hMemDC, hOldFont);

	return TRUE;
}
