#ifndef FTD2XXDEV_H_
#define FTD2XXDEV_H_

#include <iostream>
#include <stdio.h>

#include "ftd2xx.h"

using namespace std;

#define BUF_SIZE 0x10
#define MAX_DEVICES	10

class FTD2xxDEV {
public:
	// Localbus address of AIST LSI Version 1
	char serialNumbers[MAX_DEVICES][64]; // Serial number of all available devices
	int	iNumDevs; // Number of available devices
	char *serialNbr; // Serial number of the open device
	int idDev; // Position of the opened device
	FT_STATUS	ftStatus; // Status of the connection
	FT_HANDLE	ftHandle; // Device handle

	FTD2xxDEV();
	virtual ~FTD2xxDEV();
	int openDevice(int dev,int baudrate);
	void closeDevice();
	void write(unsigned char *buffer, unsigned int len, unsigned int *bytesWritten);
	void read(unsigned char *buffer, unsigned int reqBytes, unsigned int *readBytes);
	void setTimeout (unsigned int ReadTO, unsigned int WriteTO);
	int statusOK();

};

#endif /* FTD2XXDEV_H_ */