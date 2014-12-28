#include "dapi_engine.h"

/*
@brief  Device ��ü ����
@param  pObject DAPI_DEVICE��ü�� NULL ������
@return ������ DAPI_DEVICE ��ü ��ȯ
*/
void DAPI::DAPI_InitlizeObject(LPDAPI_DEVICE * pObject)
{
	if (DAPI::pDevice == NULL) DAPI::pDevice = new DAPI::DAPI_DEVICE;
	*pObject = DAPI::pDevice;
}
	
/*
@brief  Font ��ü ����
@param  pObject DAPI_FONT��ü�� NULL ������
@return ������ DAPI_FONT ��ü ��ȯ
*/
void DAPI::DAPI_InitlizeObject(LPDAPI_FONT * pObject)
{
	if (DAPI::pFont == NULL) DAPI::pFont = new DAPI::DAPI_FONT;
	*pObject = DAPI::pFont;
}
	
/*
@brief  ������ ��� DAPI ��ü �޸� ��ȯ
*/
void DAPI::DAPI_DeleteObject()
{
	if (DAPI::pDevice != NULL) delete DAPI::pDevice;
	if (DAPI::pFont != NULL) delete DAPI::pFont;
}