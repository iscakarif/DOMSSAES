#include "ftd2xx.h"
#include "FTD2xxDev.h"

// Note: A program using this library must include the linking library ftd2xx

FTD2xxDEV::FTD2xxDEV() {

	int i;
	iNumDevs = 0;
	serialNbr=NULL;
	idDev=-1;
	ftHandle=NULL;

	// Check number of devices and list their characteristics
	char *serialNumbersPtr[MAX_DEVICES + 1];

	for (i = 0; i < MAX_DEVICES; i++) {
		serialNumbersPtr[i] = serialNumbers[i];
	}
	serialNumbersPtr[MAX_DEVICES] = NULL;

	ftStatus = FT_ListDevices(serialNumbersPtr, &iNumDevs, FT_LIST_ALL | FT_OPEN_BY_SERIAL_NUMBER);

	printf("\nAvailable devices %d\n",iNumDevs);

	if (ftStatus != FT_OK) {
		printf("Error: FT_ListDevices(%d)\n", (int)ftStatus);
		printf("Run script setupFTD.sh \n");
		throw 1;
	}

	for (i = 0; ( (i <MAX_DEVICES) && (i < iNumDevs) ); i++) {
		printf("Device %d Serial Number - %s\n", i, serialNumbers[i]);
	}
	printf("\n");

}

FTD2xxDEV::~FTD2xxDEV() {
	closeDevice();
}

int FTD2xxDEV::openDevice(int dev,int baudrate) {

	if (dev<0 || dev>=iNumDevs) {
		printf("Device does not exist\n");
		return 1;
	}

	if ((ftStatus = FT_OpenEx(serialNumbers[dev], FT_OPEN_BY_SERIAL_NUMBER, &ftHandle)) != FT_OK){
		//	This can fail if the ftdi_sio driver is loaded use lsmod to check this and rmmod ftdi_sio to remove also rmmod usbserial
		printf("Error FT_OpenEx(%d), device %d\n", (int)ftStatus, dev);
		printf("Use lsmod to check if ftdi_sio (and usbserial) are present.\n");
		printf("If so, unload them using rmmod, as they conflict with ftd2xx.\n");
		return 1;
	}
	else {
		serialNbr=(char *)&serialNumbers[dev];
		printf("Device %s opened\n",serialNbr);
	}

	if ((ftStatus = FT_SetBaudRate(ftHandle, baudrate)) != FT_OK) {
		printf("Error FT_SetBaudRate(%d), cBufLD[i] = %s\n", (int)ftStatus, serialNbr);
		return 1;
	}
	else {
		printf("Baudrate set to %d\n", baudrate);
	}

	idDev=dev;

	return 0;

}

void FTD2xxDEV::closeDevice() {
	if (idDev!=-1) {
		FT_Close(ftHandle);
		printf("Device %s closed\n", serialNbr);
		serialNbr=NULL;
		idDev=-1;
		ftHandle=NULL;
	}
}

void FTD2xxDEV::write(unsigned char *buffer, unsigned int len, unsigned int *bytesWritten) {

	// Write
	ftStatus = FT_Write(ftHandle, buffer, len, (LPDWORD)bytesWritten);
	if (ftStatus != FT_OK) {
		printf("Error FT_Write(%d)\n", (int)ftStatus);
	}
	if (*bytesWritten != len) {
		printf("FT_Write only wrote %d (of %d) bytes\n",*bytesWritten,len);
	}

}


void FTD2xxDEV::read(unsigned char *buffer, unsigned int reqBytes, unsigned int *readBytes) {

	ftStatus = FT_Read(ftHandle,buffer,reqBytes,(LPDWORD)readBytes);
	if (ftStatus == FT_OK) {
		if (*readBytes != reqBytes) {
			printf("Time out reached\n");
			throw 2;
		}
	}
	else {
		printf("Read failed\n");
		throw 1;
	}

}

int FTD2xxDEV::statusOK() {
	return (ftStatus == FT_OK);
}

void FTD2xxDEV::setTimeout (unsigned int ReadTO, unsigned int WriteTO) {
	FT_SetTimeouts(ftHandle,ReadTO,WriteTO);
}