#ifndef SASEBOGII_H_
#define SASEBOGII_H_

#include "../FTD2xx/FTD2xxDev.h"

#define BUF_SIZE 0x10
#define MAX_DEVICES 10

#define ZERO 0x0000
#define RUN  0x0001 // Start
#define KSET  0x0002 // Key has been set
#define IPRST  0x0004 // Internal reset

#define ADDR_CONT  0x0002
#define ADDR_MODE  0x0004
#define ADDR_N 0x0006
#define ADDR_S 0x0008
#define ADDR_KEY 0x0100
#define ADDR_DATA  0x0120
#define ADDR_OTEXT0  0x0140

#define ENC  0x0000
#define DEC  0x0001

#define WithLastMC 0x0000
#define WithoutLastMC 0x0001

class SaseboGII {
public:

	FTD2xxDEV * device;

	SaseboGII();
	virtual ~SaseboGII();
	int openDevice(int dev,int baudrate);
	void closeDevice();
	void write(int addr, int dat);
	void writeBurst(int addr, char *dat, int len);
	int read (int addr);
	void readBurst(int addr, char *dat, int len);

};

// ToDo: Make this function friend of board to read type
// Values in this function are hard coded based on board and algorithm configuration
int getAddField(string board_type, string field, string algo);

#endif /* SASEBOGII_H_ */