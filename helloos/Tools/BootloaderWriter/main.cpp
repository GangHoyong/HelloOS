#include "dapi\dapi_engine.h"
#include "dapi\dapi_usb.h"

// ������ ����
using namespace std;
using namespace DAPI;

int main(int argc, char* argv[])
{
	LPDAPI_DEVICE dDev;
	LPDAPI_FONT dFont;
	DAPI_InitlizeObject(&dDev);
	DAPI_InitlizeObject(&dFont);

	int nDevHandle = dDev->CreateDevice(L"HelloOS Install", 450, 220, 0, 0);
	int nVerdana = dFont->LoadFont(L"Verdana", 15, FW_NORMAL);
	int nVerdanaBold = dFont->LoadFont(L"Verdana", 13, FW_BOLD);
	int nVerdanaBig = dFont->LoadFont(L"Verdana", 22, FW_BOLD);

	const int MBR_CODE_LENGTH = 512;

	while (dDev->Run(nDevHandle))
	{
		if (dDev->BeginScene(nDevHandle))
		{
			dFont->Text(nDevHandle, nVerdana, L"Welcome to HelloOS installer!", 10, 10);
			dFont->Text(nDevHandle, nVerdana, L"��ġ�� USB�� �νĵ� ��� �Ʒ� ��Ͽ� ǥ�� �˴ϴ�.", 10, 30, RGB(0x99, 0x99, 0x99));
			dFont->Text(nDevHandle, nVerdana, L"8GB or 16GB USB�� ��ġ�� �����մϴ�.", 10, 50, RGB(0x99, 0x99, 0x99));

			DWORD dwDevices = GetLogicalDrives();
			for (int i = 0, lineNumber = 3; i < 32; i++)
			{
				DWORD dwComp = (1 << i);
				if (dwDevices & dwComp)
				{
					string driveString = (char)('A' + i) + (string)":";
					UsbLibrary usb(driveString);

					string strBuffer = "";
					wstring convertString = L"";
					if (usb.isVolumeDevice() && usb.isUsbDevice())
					{
						int line = 10 + lineNumber * 25;

						// Drive �Ҵ� ���ĺ� ���ϱ�
						strBuffer = driveString + "\\";
						convertString.assign(strBuffer.begin(), strBuffer.end());
						dFont->Text(nDevHandle, nVerdanaBold, convertString.c_str(), 10, line, RGB(0xFF, 0x00, 0x00));

						// ����̺� �뷮
						char szDriveSize[10] = { 0, };
						long long nDriveSizeOfGB = usb.getDeviceSize() / 1000 / 1000 / 1000;
						sprintf_s(szDriveSize, "%d GB", nDriveSizeOfGB);
						// ����̺� �� �̸�
						strBuffer = usb.getVolumeLabel() + "(" + szDriveSize + ")";
						convertString.assign(strBuffer.begin(), strBuffer.end());
						convertString = convertString;
						dFont->Text(nDevHandle, nVerdanaBold, convertString.c_str(), 40, line);

						// ����̺� ���Ͻý��� �̸�
						strBuffer = usb.getFileSystemLabel();
						convertString.assign(strBuffer.begin(), strBuffer.end());
						convertString = convertString;
						dFont->Text(nDevHandle, nVerdanaBold, convertString.c_str(), 210, line);

						// 16GB or 8GB USB���� ��ġ ��ư ����
						if (nDriveSizeOfGB == 16 || nDriveSizeOfGB == 8)
						{
							RECT rectEvent = { 0, };
							COLORREF colorButtonBg = RGB(0x11, 0x99, 0x00);
							ifstream mbrImage("./loader.img", ios_base::binary);
							
							// ���콺 �̺�Ʈ ���� ����
							rectEvent.top = line - 3;
							rectEvent.bottom = line + 19;
							rectEvent.left = 280;
							rectEvent.right = 338;

							if (!mbrImage.fail())
							{
								// ���콺 ������
								if (dDev->IsMouseOver(&rectEvent))
								{
									colorButtonBg = RGB(0x44, 0xCC, 0x00);
								}
								// ���콺 Ŭ����
								if (dDev->IsMouseClick(&rectEvent))
								{
									colorButtonBg = RGB(0xAA, 0xFF, 0x00);
								}
								// ���콺 Ŭ���� ���ѹ� �߻�
								if (dDev->IsMouseClickOnce(&rectEvent))
								{
									BYTE* installMBR = new BYTE[MBR_CODE_LENGTH]();
									mbrImage.read((char*)installMBR, MBR_CODE_LENGTH);

									bool bInstalled = usb.writeMasterBootRecord((fat_extBS_32_t*)installMBR);
									cout << usb.getVolumeLabel().c_str() << "(" << nDriveSizeOfGB << ")" << endl;
									cout << "Master Boot Record : Install [" << ((bInstalled) ? "true" : "false") << "]" << endl;

									delete[] installMBR;
								}

								dFont->Text(nDevHandle, nVerdanaBig, L"         ", rectEvent.left + 1, rectEvent.top + 1, RGB(0xFF, 0xFF, 0xFF), RGB(0xFF, 0xFF, 0xFF));
								dFont->Text(nDevHandle, nVerdanaBig, L"         ", rectEvent.left, rectEvent.top, RGB(0xFF, 0xFF, 0xFF), colorButtonBg);
								dFont->Text(nDevHandle, nVerdanaBold, L"Install", rectEvent.left + 5, rectEvent.top + 3, RGB(0xFF, 0xFF, 0xFF), colorButtonBg);
							}
							else
							{
								dFont->Text(nDevHandle, nVerdanaBold, L"Can't ImageFile", rectEvent.left + 5, rectEvent.top + 3, RGB(0xFF, 0xFF, 0xFF));
							}
						}
						lineNumber++;
					}
				}
			}

			dDev->EndScene(nDevHandle);
		}
	}

	// release
	DAPI_DeleteObject();
	return 0;
}
