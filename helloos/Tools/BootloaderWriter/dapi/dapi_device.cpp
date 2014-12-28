#include "dapi_engine.h"

DAPI::CDevice::CDevice()
{
	// DAPI Engine Version
	this->lpcVer = L"DAPI_ENGINE_V.0.0.0";
	this->dwFPSCount = 0;
	this->dwFPSTimer = 0;
	this->dwSetTimer = 0;
	this->dwSetTryTimer = 0;
	this->bTryTimer = false;

	// NULL ������ �ʱ�ȭ �� ���� 1���� ����
	this->nWindowCount = 1;
	// ���� NULL ���� �ʿ��� ���� ���Ǳ� ���� �ʱ�ȭ
	ZeroMemory(&(this->dDeviceInfo), sizeof(this->dDeviceInfo));

	this->hInstance = GetModuleHandle(NULL);
	this->WinMain();

	// �ʱ�ȭ
	ZeroMemory(&(this->mMsg), sizeof(this->mMsg));
	this->mMsg.message = WM_NULL;
}

DAPI::CDevice::~CDevice()
{
}

/*
public

@brief  Ư�� �ε����� �ش��ϴ� Device�� ������ ��ȯ
@param  index ������ �������� index ��ȣ
@return ������ �ùٸ� Device ����, �ùٸ��� ���� Ȥ�� �������� ���� ������ ��ȣ�� : NULL
*/
DAPI::DAPI_DeviceStruct * DAPI::CDevice::GetDeviceInfo(int index)
{
	if (this->GetDeviceStatus(index) == DAPI::D_INVALID) return NULL;

	return (this->dDeviceInfo + index);
}

/*
public

@brief  ������ ����
@param  cpAppName ������ ����
@param  width ������ ���α���
@param  height ������ ���� ����
@param  x ������ x��ǥ
@param  y ������ y��ǥ
@return ������ ������ �ε��� ID
        ���� ���н� -1 ��ȯ
*/
int DAPI::CDevice::CreateDevice(const LPCTSTR cpAppName, int width, int height, int x, int y)
{
	if (this->nWindowCount >= MAX_WINDOWS) return -1;

	int index = this->nWindowCount;
	DAPI::DAPI_DeviceStruct * deviceinfo = this->dDeviceInfo + index;

	// Device ���� ����
	deviceinfo->width = width;
	deviceinfo->height = height;
	deviceinfo->x = x;
	deviceinfo->y = y;

	deviceinfo->hWnd = CreateWindowEx(0, this->lpcVer, cpAppName, WS_OVERLAPPEDWINDOW, x, y, width, height, NULL, NULL, this->hInstance, &this->nWindowCount);
	SetWindowPos(deviceinfo->hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
	//SetWindowLongPtr(deviceinfo->hWnd, GWL_STYLE, GetWindowLongPtr(deviceinfo->hWnd, GWL_STYLE) | WS_SYSMENU);
	//SetWindowLongPtr(deviceinfo->hWnd, GWL_EXSTYLE, GetWindowLongPtr(deviceinfo->hWnd, GWL_EXSTYLE) | WS_EX_ACCEPTFILES);

	if (deviceinfo->hWnd != NULL)
	{
		ShowWindow(deviceinfo->hWnd, SW_SHOW);
		UpdateWindow(deviceinfo->hWnd);
	}
	else
	{
		return -1;
	}
	return this->nWindowCount++;
}

/*
public

@brief  �޽��� ����
@param  index
		0 == ������ ��� �����쿡 ���� ó��
		0 <  index��° ������ �����쿡 ���� �޽��� ó��
@return ������ : TRUE, ���� : FALSE
*/
int DAPI::CDevice::Run(int index)
{
	// �ùٸ��� ���� index �� ������ ��� ���μ��� ���� ����
	if (this->GetDeviceStatus(index) == DAPI::D_INVALID) return FALSE;

	DAPI::DAPI_DeviceStruct * deviceinfo = this->dDeviceInfo + index;
	if (PeekMessage(&(this->mMsg), deviceinfo->hWnd, NULL, NULL, PM_REMOVE))
	{
		TranslateMessage(&(this->mMsg));
		DispatchMessage(&(this->mMsg));
	}
	else
	{
		// CPU�� 100% ����� ����
		Sleep(5);
	}
	return TRUE;
}

/*
public

@brief  �ʴ� ������ ������ Ƚ�� ����
@param  frameCount �ʴ� ������ �Ǵ� Ƚ��
@return 1���� ����� ������ �ϴµ� �ʿ��� �ð��� ����Ͽ� �������� ������ ������ ���
		��(true), �Ұ����� ��� ����(false) ��ȯ
*/
BOOL DAPI::CDevice::FPSCount(int frameCount)
{
	if (this->dwFPSTimer == 0) this->dwFPSTimer = GetTickCount();

	const DWORD fpsRenderTime = 1000 / frameCount;
	if (GetTickCount() > this->dwFPSTimer)
	{
		this->dwFPSTimer += fpsRenderTime;
		return TRUE;
	}
	return FALSE;
}

/*
public

@brief  Ư�� �ð��ʸ� �ֱ�� TRUE ���� ��ȯ�ϴ� �Լ�
@param  ms ���� TRUE ���� ������ �ð�(ms)
@param  ms ������ �ð�(ms)
@return ������ �ð���ŭ �귯���ٸ� TRUE �ƴ϶�� FALSE
*/
BOOL DAPI::CDevice::SetTimer(const DWORD startMS, const DWORD tryMS)
{
	if (this->dwSetTimer == 0) this->dwSetTimer = GetTickCount();

	if (startMS > 0 && this->bTryTimer == false && GetTickCount() - this->dwSetTimer > startMS)
	{
		this->dwSetTryTimer = GetTickCount();
		this->bTryTimer = true;

		return TRUE;
	}

	if (tryMS > 0 && this->bTryTimer == true && GetTickCount() - this->dwSetTryTimer > tryMS)
	{
		this->dwSetTimer = GetTickCount();
		this->bTryTimer = false;
	}

	if (tryMS > 0 && this->bTryTimer == true) return TRUE;
	return FALSE;
}

/*
public

@brief  Ư�� �ε����� �ش��ϴ� Device�� ���¸� ��ȯ�ϴ� �Լ�
@param  index ������ �������� index ��ȣ
@return ������ �ùٸ� �ε��� ��ȣ : D_OK, �ùٸ��� ���� Ȥ�� �������� ���� ������ ��ȣ�� : D_INVALID
*/
DWORD DAPI::CDevice::GetDeviceStatus(int index)
{
	if (index >= this->nWindowCount)
	{
		return DAPI::D_INVALID;
	}

	if (index > 0)
	{
		DAPI::DAPI_DeviceStruct * deviceinfo = this->dDeviceInfo + index;
		if (GetWindow(deviceinfo->hWnd, 0) == NULL)
		{
			return DAPI::D_INVALID;
		}
	}

	return DAPI::D_OK;
}

/*
public

@brief  ��� ������ ����
@param  index ������ �������� index ��ȣ
@return ��� �ʱ�ȭ ������ TRUE, ���н� FALSE
*/
BOOL DAPI::CDevice::BeginScene(int index)
{
	if (this->GetDeviceStatus(index) == DAPI::D_INVALID) return FALSE;

	DAPI::DAPI_DeviceStruct * deviceinfo = this->dDeviceInfo + index;

	// ��� �ٽ� �׸��� WM_PAINT ȣ��
	if (!InvalidateRect(deviceinfo->hWnd, NULL, FALSE))
		return FALSE;

	deviceinfo->hDC = BeginPaint(deviceinfo->hWnd, &(this->ps));

	// ���� ���۸� �ʱ�ȭ
	deviceinfo->hMemDC = CreateCompatibleDC(deviceinfo->hDC);

	deviceinfo->hBit = CreateCompatibleBitmap(deviceinfo->hDC, deviceinfo->width, deviceinfo->height);
	deviceinfo->hMemBit = (HBITMAP)SelectObject(deviceinfo->hMemDC, deviceinfo->hBit);

	return TRUE;
}

/*
public

@brief  ��� ������ ����
@param  index ������ �������� index ��ȣ
@return ������ TRUE, ���н� FALSE
*/
BOOL DAPI::CDevice::EndScene(int index)
{
	if (this->GetDeviceStatus(index) == DAPI::D_INVALID) return FALSE;
	
	DAPI::DAPI_DeviceStruct * deviceinfo = this->dDeviceInfo + index;
	
	// ���� ���۸� ó��
	BitBlt(deviceinfo->hDC, 0, 0, deviceinfo->width, deviceinfo->height, deviceinfo->hMemDC, 0, 0, SRCCOPY);

	SelectObject(deviceinfo->hMemDC, deviceinfo->hMemBit);
	DeleteObject(deviceinfo->hBit);
	DeleteDC(deviceinfo->hMemDC);

	return EndPaint(deviceinfo->hWnd, &(this->ps));
}

/*
public

@brief  ���ڷ� ���޵� DC�� �����Ͽ� ������
@param  index ������ �������� index ��ȣ
@param  hSrcDC ������ �����쿡 �׷��� ���� ����� �Ǵ� HDC ��ü
@param  rectSize HDC ���� �׸��� �� ������ ���� ��
@param  x ������ �󿡼� �׷����� �� X ��ǥ��
@param  y ������ �󿡼� �׷����� �� Y ��ǥ��
@return ������ TRUE, ���н� FALSE
*/
BOOL DAPI::CDevice::CopyDC(int index, const HDC hSrcDC, const RECT rectSize, int x, int y)
{
	if (this->GetDeviceStatus(index) == DAPI::D_INVALID) return FALSE;
	
	DAPI::DAPI_DeviceStruct * deviceinfo = this->dDeviceInfo + index;
	return BitBlt(deviceinfo->hMemDC, x, y, rectSize.right, rectSize.bottom, hSrcDC, rectSize.left, rectSize.top, SRCCOPY);
}

/*
public

@brief  Ư�� Ű�� ���°��� ��ȯ
@param  keyCode ���°��� ���� Ű�ڵ� ��
@return DAPI_KeyStatus�� enum ���·� ��ȯ
*/
DWORD DAPI::CDevice::GetKeyCodeState(int keyCode)
{
	if (GetAsyncKeyState(keyCode) & 0x8000)
		return DAPI::D_DOWN;

	return DAPI::D_UP;
}

/*
public

@brief  ���콺 ��ǥ�� ��� �Լ�
@return ���콺 ��ǥ ��ü
*/
POINTS DAPI::CDevice::GetMouseState()
{
	return DAPI::mMousePoint;
}

/*
public

@brief  �ش翵�� ���ο� ���콺�� Ŀ���� ��ġ�ߴ����� ���θ� �Ǵ�
@param  üũ�� ���� ��ġ
@return ��ġ�� ��� TRUE �ƴϸ� FALSE
*/
BOOL DAPI::CDevice::IsMouseOver(LPRECT rec) const
{
	POINTS pMousePoints = const_cast<DAPI::CDevice*>(this)->GetMouseState();

	if (pMousePoints.x >= rec->left && pMousePoints.x <= rec->right)
		if (pMousePoints.y >= rec->top && pMousePoints.y <= rec->bottom)
			return TRUE;

	return FALSE;
}

/*
public

@brief  �ش翵�� ���ο��� ���콺�� Ŭ���Ͽ����� ���θ� �Ǵ�(������ ��ø ����� �� ����)
@param  üũ�� ���� ��ġ
@return Ŭ���� ��� TRUE �ƴϸ� FALSE
*/
BOOL DAPI::CDevice::IsMouseClick(LPRECT rec) const
{
	if (this->IsMouseOver(rec) && DAPI::wMouseClick != 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
public

@brief  �ش翵�� ���ο��� ���콺�� Ŭ���Ͽ����� ���θ� �Ǵ�(�� �ѹ��� ����)
@param  üũ�� ���� ��ġ
@return Ŭ���� ��� TRUE �ƴϸ� FALSE
*/
BOOL DAPI::CDevice::IsMouseClickOnce(LPRECT rec) const
{
	if (this->IsMouseOver(rec) && DAPI::wMouseClickOnce != 0)
	{
		DAPI::wMouseClickOnce = 0;
		return TRUE;
	}
	return FALSE;
}
/*
public

@brief  Ư�� �̺�Ʈ �޽��� �ڵ鷯 �Լ� ���
@param  �̺�Ʈ ��ȣ��
@param  �ڵ鷯 �Լ� ������
*/
void DAPI::CDevice::AddEventHandler(UINT uMsg, DAPI::WindowMessageFunc wmFunc)
{
	DAPI::mMsgMap[uMsg] = wmFunc;
}

/*
public

@brief  ����� �̺�Ʈ �ڵ鷯 �Լ��� ����
@param  �̺�Ʈ ��ȣ��
*/
void DAPI::CDevice::DeleteEventHandler(UINT uMsg)
{
	DAPI::mMsgMap.erase(uMsg);
}

/*
private

@brief  WNDCLASS ���
*/
void DAPI::CDevice::WinMain()
{
	WNDCLASS wc;
	
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
	wc.hInstance = this->hInstance;
	wc.lpfnWndProc = this->WinProc;
	wc.lpszClassName = this->lpcVer;
	wc.lpszMenuName = NULL;
	wc.style = CS_HREDRAW | CS_VREDRAW;

	RegisterClass(&wc);
}

/*
private

@brief  ������ �޽��� ó��
@param  hWnd
@param  uMsg
@param  wParam
@param  lParam
@return DefWindowProc() ��ȯ��
*/
LRESULT CALLBACK DAPI::CDevice::WinProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	// ���� ��ϵ� �ڵ鷯 �Լ��� ������ ��� ����
	if (DAPI::mMsgMap[uMsg])
	{
		return DAPI::mMsgMap[uMsg](hWnd, wParam, lParam);
	}

	switch (uMsg)
	{
	case WM_MOUSEMOVE:
		DAPI::mMousePoint = MAKEPOINTS(lParam);
		break;
	case WM_LBUTTONDOWN:
		DAPI::wMouseClick = lParam;
		DAPI::wMouseClickOnce = 0;
		break;
	case WM_LBUTTONUP:
		DAPI::wMouseClick = 0;
		DAPI::wMouseClickOnce = lParam;
		break;
	}

	return DefWindowProc(hWnd, uMsg, wParam, lParam);
}
