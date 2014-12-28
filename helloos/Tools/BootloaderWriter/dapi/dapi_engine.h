/*
DAPI Engine (������ 2D �׷��� ó�� ����)

������ : �躴�� (quddnr145@naver.com)
��  �� : http://www.pj-room.com/
��  ũ : http://cafe.naver.com/mmorpgs
*/
#ifndef _DAPI_ENGINE_H_
#define _DAPI_ENGINE_H_

#include "dapi_global.h"
#include "dapi_device.h"
#include "dapi_font.h"

namespace DAPI
{
	// �̱��� ���Ͽ� ��ü ����
	static DAPI_DEVICE * pDevice = NULL;
	static DAPI_FONT * pFont = NULL;

	/*
	@brief  Device ��ü ����
	@param  pObject DAPI_DEVICE��ü�� NULL ������
	@return ������ DAPI_DEVICE ��ü ��ȯ
	*/
	void DAPI_InitlizeObject(LPDAPI_DEVICE * pObject);
	
	/*
	@brief  Font ��ü ����
	@param  pObject DAPI_FONT��ü�� NULL ������
	@return ������ DAPI_FONT ��ü ��ȯ
	*/
	void DAPI_InitlizeObject(LPDAPI_FONT * pObject);
	
	/*
	@brief  ������ ��� DAPI ��ü �޸� ��ȯ
	*/
	void DAPI_DeleteObject();
};

#endif
