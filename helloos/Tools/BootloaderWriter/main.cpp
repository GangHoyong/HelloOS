#include <Windows.h>
#include <stdio.h>
#include <iostream>
#include <string>

// ������ ����
using namespace std;

const int FILE_SHARE_VALID_FLAGS = FILE_SHARE_WRITE | FILE_SHARE_READ;
const int SECTORSIZE = 512;

short ReadSector(const char* _dsk, BYTE* &_buff, UINT _nsect)
{
	DWORD dwRead = 0;
	HANDLE hDisk = NULL;

	hDisk = CreateFile(_dsk, GENERIC_WRITE | GENERIC_READ, FILE_SHARE_VALID_FLAGS, 0, OPEN_EXISTING, 0, 0);
	if (hDisk == INVALID_HANDLE_VALUE)
	{
		cout << "`" << _dsk << "` is INVALID_HANDLE_VALUE!!" << endl;
		CloseHandle(hDisk);

		return 1;
	}
	if (SetFilePointer(hDisk, _nsect * SECTORSIZE, 0, FILE_BEGIN) != INVALID_SET_FILE_POINTER)
	{
		if (ReadFile(hDisk, _buff, SECTORSIZE, &dwRead, 0) == FALSE)
		{
			int _errno = GetLastError();
			if (_errno == 5)
				cout << "ReadSector Denied Access!!" << endl;
			else
			{
				printf("ReadSector Error: %d\n", _errno);
			}
		}
	}
	CloseHandle(hDisk);

	return 0;
}

short WriteSector(const char* _dsk, BYTE* _buff, UINT _nsect)
{
	DWORD dwWrite = 0;
	HANDLE hDisk = NULL;

	hDisk = CreateFile(_dsk, GENERIC_WRITE | GENERIC_READ, FILE_SHARE_VALID_FLAGS, 0, OPEN_EXISTING, 0, 0);
	if (hDisk == INVALID_HANDLE_VALUE)
	{
		cout << "`" << _dsk << "` is INVALID_HANDLE_VALUE!!" << endl;
		CloseHandle(hDisk);

		return 1;
	}
	if (SetFilePointer(hDisk, _nsect * SECTORSIZE, 0, FILE_BEGIN) != INVALID_SET_FILE_POINTER)
	{
		if (WriteFile(hDisk, _buff, SECTORSIZE, &dwWrite, 0) == FALSE)
		{
			int _errno = GetLastError();
			if (_errno == 5)
				cout << "WriteSector Denied Access!!" << endl;
			else
			{
				printf("WriteSector Error: %d\n", _errno);
			}
		}
		else
		{
			cout << "WriteSector Success!!" << endl;
		}
	}
	CloseHandle(hDisk);

	return 0;
}

int main(int argc, char* argv[])
{
	char yesno = 'Y';
	string strDriveNumber, strFilePath;
	string strDisk = "\\\\.\\PhysicalDrive";

	// ����̺� ��ȣ �б�
	if (argc == 1)
	{
		cout << "���� ! : USB�� �ּ� �뷮�� 16GB�̾�� �ϸ� ������ ���� �̾�� �մϴ�" << endl;
		cout << "USB DriverNumber: ";
		cin >> strDriveNumber;
		cout << "USB Install FilePath: ";
		cin >> strFilePath;
	}
	else
	{
		strDriveNumber = argv[1];
		strFilePath = argv[2];
	}

	if (strDriveNumber.compare("0") == 0)
	{
		cout << "���� !" << endl;
		cout << "�ش� ����̺�� ���� HDD �̹Ƿ� ��Ʈ�δ� ���ε��" << endl;
		cout << "������ �Ұ��� �� �� �ֽ��ϴ�." << endl << endl;

		cout << "�۾��� ��� ���� �Ͻðڽ��ϱ�?(Y/n): ";
		cin >> yesno;
	}

	if (yesno == 'Y')
	{
		// ����̺� ����
		strDisk += strDriveNumber;
		strDisk = "\\\\.\\F:";

		// ��ġ ���� �о���̱�
		FILE* fp = NULL;
		int _errno = fopen_s(&fp, strFilePath.c_str(), "rb");
		if (_errno == 0)
		{
			BYTE* sectorData = new BYTE[SECTORSIZE];

			fread_s(sectorData, sizeof(BYTE)* SECTORSIZE, SECTORSIZE, 1, fp);
			fclose(fp);

			// Bootloader üũ
			if (sectorData[510] == 0x55 && sectorData[511] == 0xAA)
			{
				cout << "Bootloader Checking OK!!" << endl;
				// Bootloader Read!!
				WriteSector(strDisk.c_str(), sectorData, 0);
				//WriteSector(strDisk.c_str(), sectorData, 6);
			}
			else
			{
				// Bootloader �� �ƴѰ�� ��ġ�� ���н�Ų��.
				cout << "Bootloader Install Failure!!" << endl;
				cout << "`" << strFilePath << "` is Not Bootloader!!" << endl;
			}

			delete[] sectorData;
		}
		else
		{
			cout << "`" << strFilePath << "` is not exists!!" << endl;
		}
	}
	else
	{
		cout << "�۾��� ����մϴ�." << endl;
	}
	return 0;
}
