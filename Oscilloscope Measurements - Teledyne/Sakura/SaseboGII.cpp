#include "SaseboGII.h"
#include "../FTD2xx/FTD2XX.h"
#include "../FTD2xx/FTD2xxDev.h"

#include <stdio.h>
#include <stdlib.h>

SaseboGII::SaseboGII() {
	device= new FTD2xxDEV();
}

SaseboGII::~SaseboGII() {
	delete device;
}

int SaseboGII::openDevice(int dev,int baudrate) {

	int flag=device->openDevice(dev,baudrate);

	//Reset the sasebo port
	//write(ADDR_CONT,0x0004);
	//write(ADDR_CONT,0x0000);

	write(ADDR_CONT, IPRST);
	write(ADDR_CONT, ZERO);

	return flag;

}

void SaseboGII::closeDevice() {
	device->closeDevice();
}

void SaseboGII::write(int addr, int dat) {

	unsigned int BytesWritten=0;
	unsigned char buffer[5];
	buffer[0] = (char)0x01;
	buffer[1] = (char)((addr>>8)&0xFF);
	buffer[2] = (char)((addr   )&0xFF);
	buffer[3] = (char)((dat >>8)&0xFF);
	buffer[4] = (char)((dat    )&0xFF);

	device->write(buffer,5,&BytesWritten);


	#ifdef _VERBOSE_CHANNEL_
		printf("Write: ");
		for (int i=0;i<5;i++){
			printf("%d ",(unsigned char)buffer[i]);
		}
		printf("\n");
	#endif

}

void SaseboGII::writeBurst(int addr, char *dat, int len) {

	unsigned char *buffer;
	unsigned int BytesWritten;
	unsigned int length;

	if (len%2==1) {
		length = 5*(len+1)/2;
	}
	else {
		length = 5*(len)/2;
	}

	buffer = new unsigned char[length];

	for(unsigned int i=0;i<length;i++) {
		buffer[i] = 0;
	}

	for (unsigned int i=0; i<length/5; i++) {
		buffer[i*5+0] = 0x01;
		buffer[i*5+1] = (char)(((addr+i*2) >> 8) & 0xFF);
		buffer[i*5+2] = (char)(((addr+i*2)     ) & 0xFF);
		buffer[i*5+3] = dat[i*2];
		buffer[i*5+4] = dat[i*2+1];
	}

	// Write
	device->write(buffer,length,&BytesWritten);

	#ifdef _VERBOSE_CHANNEL_
		printf("Write: ");
		for (unsigned int i=0;i<length;i++) {
			printf("%d ",(unsigned char)buffer[i]);
		}
		printf("\n");
	#endif

	delete buffer;

}


int SaseboGII::read (int addr) {

	unsigned char buffer[3];
	unsigned int BytesWR;

	buffer[0] = (unsigned char) 0x00;
	buffer[1] = (unsigned char)((addr>>8)&0xFF);
	buffer[2] = (unsigned char)((addr   )&0xFF);

	// Write
	device->write(buffer,3,&BytesWR);

	#ifdef _VERBOSE_CHANNEL_
		printf("Write: ");
		for (int i=0;i<3;i++) {
			printf("%d ",(unsigned char)buffer[i]);
		}
		printf("\n");
	#endif

	device->setTimeout(5000,0);
	device->read(buffer,2,&BytesWR);

	if (device->statusOK()) {
		if (BytesWR == 2) {
			#ifdef _VERBOSE_CHANNEL_
				printf("Read: ");
				for (int i=0;i<2;i++) {
					printf("%d ",(unsigned char)buffer[i]);
				}
				printf("\n");
			#endif
			return ((int)buffer[0]<<8) + (int)buffer[1];
		}
		else {
			printf("Time out reached\n");
			throw 2;
		}
	}
	else {
		printf("Read failed\n");
		throw 1;
	}

	return 0;

}

void SaseboGII::readBurst(int addr, char *dat, int len) {

	unsigned char *buffer;
	unsigned int BytesWR;
	unsigned int length;

	if (len%2==1){
		length = 3*(len+1)/2;
	}
	else {
		length = 3*(len)/2;
	}

	buffer = new unsigned char[length];

	for(unsigned int i=0;i<length;i++) {
		buffer[i] = 0;
	}

	for (int i=0; i<len/2; i++) {
		buffer[i*3+0] = (unsigned char)0x00;
		buffer[i*3+1] = (unsigned char)(((addr+i*2) >> 8) & 0xFF);
		buffer[i*3+2] = (unsigned char)(((addr+i*2)     ) & 0xFF);
	}

	device->write(buffer,length,&BytesWR);

	if ( !device->statusOK() || BytesWR != length) {
		printf("Error asking for data\n");
	}

	device->setTimeout(5000,0);
	device->read((unsigned char *)dat,len,&BytesWR);

	#ifdef _VERBOSE_CHANNEL_
		printf("Write: ");
		for (unsigned int i=0;i<length;i++) {
			printf("%d ",(unsigned char)buffer[i]);
		}
		printf("\n");

		printf("Read: ");
		for (int i=0;i<len;i++) {
			printf("%d ",(unsigned char)dat[i]);
		}
		printf("\n");
	#endif

}


// Auxiliary function
// Todo: Move definition to this functions

int getAddField(string board_type, string field) {

	if(board_type==string("SaseboGII")){

	}

	return 0;
	
}