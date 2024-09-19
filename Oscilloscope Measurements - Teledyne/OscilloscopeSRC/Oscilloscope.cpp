#include "Oscilloscope.h"

static ViStatus status;
static ViUInt32 writeCount;
static ViUInt32 retCount;

Oscilloscope::Oscilloscope() {

	family = _DIGILENT_;

	config = new Osc_config(2);
	config->wave_points = 1000;
	binary_block_data = new unsigned char[config->wave_points+11];

	num_ave = 0;

}

Oscilloscope::Oscilloscope(int points, string port) {

	config = new Osc_config(2);
	config->wave_points = points;
	this->setPort(port);
	binary_block_data = new unsigned char[config->wave_points+11];

	num_ave = 0;

	family = _DIGILENT_;

}

Oscilloscope::~Oscilloscope() {

	status = viClose(instr);
	status = viClose(defaultRM); 

	delete binary_block_data;

}

void Oscilloscope::setPort(string port) {

	cout << "Opening port " << port.c_str() << endl;

	status = viOpenDefaultRM(&defaultRM);
	if (status < VI_SUCCESS) {
		cout << "Could not open a session to the VISA Resource Manager!" << endl;
		throw runtime_error("Error opening the port");
	}

	status = viOpen(defaultRM, (char *)port.c_str(), VI_NULL, VI_NULL, &instr);

	if (status < VI_SUCCESS) {
		throw runtime_error("Error opening the port");
	}

}

void Oscilloscope::setNumpoints(int numpoints) {

	config->wave_points=numpoints;

	delete binary_block_data;

	if (family == _DIGILENT_) {
		binary_block_data = new unsigned char[config->wave_points + 11];
		for (int i = 0; i < config->wave_points + 11; i++) {
			binary_block_data[i] = 0;
		}
	}

	if (family == _LECROY_) {
		binary_block_data = new unsigned char[config->wave_points + 369];
		cout << "Points " << numpoints << endl;
		for (int i = 0; i < config->wave_points + 369; i++) {
			binary_block_data[i] = 0;
		}
	}

}

void Oscilloscope::setFamily(int fam){

	family = fam;

	/*if (family==_LECROY_) {
		delete binary_block_data;
		binary_block_data = new unsigned char[config->wave_points+11];
	}*/

}


string Oscilloscope::readDevSystem() {

	char cmd[] = "USB?*INSTR";
	string port;

	static ViUInt32 numInstrs;
	static ViFindList findList;
	static char instrResourceString[VI_FIND_BUFLEN];
	static unsigned char buffer[100];
	static char stringinput[512];
	string fam;
	
	// 0 = Digilent (Default), 1 = Lecroy

	if (family == _DIGILENT_) {
		fam = "Digilent";
	}

	if (family == _LECROY_) {
		fam = "LECROY";
	}

	status = viOpenDefaultRM(&defaultRM);
	if (status < VI_SUCCESS) {
		cout << "Could not open a session to the VISA Resource Manager!" << endl;
		exit(EXIT_FAILURE);
	}

	// Find all the USB TMC VISA resources in our system and store the  number of resources in the system in numInstrs.
	status = viFindRsrc(defaultRM, cmd, &findList, &numInstrs, instrResourceString);

	if (status < VI_SUCCESS) {
		cout << "An error occurred while finding resources" << endl;
		viClose(defaultRM);
		exit(EXIT_FAILURE);
	}

	// Now we will open VISA sessions to all USB TMC instruments.
	// Choose the first device belonging to the correct family
	// ToDo: Extend to the case when many devices are connected

	for (unsigned int i = 0; i < numInstrs; i++) {
		if (i > 0) {
			viFindNext(findList, instrResourceString);
		}
		status = viOpen(defaultRM, instrResourceString, VI_NULL, VI_NULL, &instr);

		if (status < VI_SUCCESS) {
			cout << "Cannot open a session to the device " << i + 1 << endl;
			continue;
		}

		// Asking for the device's identification.

		strcpy_s(stringinput, "*IDN?\n");
		status = viWrite(instr, (ViBuf)stringinput, (ViUInt32)strlen(stringinput), &writeCount);
		if (status < VI_SUCCESS) {
			cout << "Error writing to the device " << i + 1 << endl;
			status = viClose(instr);
			continue;
		}

		status = viRead(instr, buffer, 100, &retCount);
		if (status < VI_SUCCESS) {
			cout << "Error reading a response from the device " << i + 1 << endl;
		}
		else {
			port = string((char *)buffer);
			cout << "port is " << port << endl;
			if (port.find(fam) != string::npos) {
				break;
			}
		}
		status = viClose(instr);
	}

	//Now we will close the session to the instrument using viClose. This operation frees all system resources.
	status = viClose(defaultRM);

	return string(instrResourceString);

}

void Oscilloscope::configuration(Osc_config *conf, int print) {

	delete config;
	config=conf;
	if (print==1) {
		config->print_cfg();
	}

}

void Oscilloscope::init() {

	switch(family) {
	case _DIGILENT_:
		init_Digilent();
		break;
	case _LECROY_:
		init_LeCroy();
		break;
	}

}

// Todo: Create a string with all commands and write all at once

void Oscilloscope::init_LeCroy() {

	string cmd;
	stringstream cmd_ss;

	int set_points[10]={1000,5000,10000,50000,100000,500000,1000000,5000000,10000000,20000000};
	char points_found;

	cmd_ss << fixed;

	cmd = "*CLS"; status = viWrite(instr, (ViBuf)cmd.c_str(), (ViUInt32)cmd.length(), &writeCount);
	Sleep(100);
	cmd = "*RST"; status = viWrite(instr, (ViBuf)cmd.c_str(), (ViUInt32)cmd.length(), &writeCount);
	Sleep(100);
	cmd = "TRMD STOP"; status = viWrite(instr, (ViBuf)cmd.c_str(), (ViUInt32)cmd.length(), &writeCount);
	Sleep(1000);

	// Configuring channels
	for (int ch=0;ch < config->num_ch;ch++ ) {

		cmd_ss << "C" << ch+1 << ":TRAce ";
		if (config->disp[ch]==1) {
			cmd_ss << "ON" << endl;
		}
		else {
			cmd_ss << "OFF" << endl;
		}
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");

		cmd_ss << "C" << ch + 1 << ":VDIV " << config->scale[ch] << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");

		cmd_ss << "C" << ch+1 << ":OFFSET " << config->offset[ch] << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");

	}

	Sleep(100);

	// Time
	
	cmd_ss << "TIME_DIV " << config->str_time( config->time_scale) << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	cmd_ss << "TRIG_DELAY " << config->str_time( config->time_delay) << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(500); // Wait until time is configure before configuring the number of points

	// Trigger
	switch(config->trig_src) {
	case SRC_CH1:
		cmd_ss << "TRig_Select EDGE,SR,C1,HT,OFF" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		cmd_ss << "C1:TRLV " << config->str_volt(config->trig_level).c_str() << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		break;
	case SRC_CH2:
		cmd_ss << "TRig_Select EDGE,SR,C2,HT,OFF" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		cmd_ss << "C2:TRLV " << config->str_volt(config->trig_level).c_str() << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		break;
	case SRC_CH3:
		cmd_ss << "TRig_Select EDGE,SR,C3,HT,OFF" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		cmd_ss << "C3:TRLV " << config->str_volt(config->trig_level).c_str() << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		break;
	case SRC_CH4:
		cmd_ss << "TRig_Select EDGE,SR,C4,HT,OFF" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		cmd_ss << "C4:TRLV " << config->str_volt(config->trig_level).c_str() << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		break;
	case SRC_EXT:
		cmd_ss << "TRig_Select EDGE,SR,EX,HT,OFF" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		cmd_ss << "EX:CPL D1M" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		cmd_ss << "EX:TRLV " << config->str_volt(config->trig_level).c_str() << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		break;
	default:
		break;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(100);

	// Waveform - Source is defined when reading the data

	if (config->wavef_Border==BYTE_ORDER_MSB) {
		cmd_ss << "COMM_ORDER " << "HI" << endl;
	}
	if (config->wavef_Border==BYTE_ORDER_LSB) {
		cmd_ss << "COMM_ORDER " << "LO" << endl;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(100);

	switch(config->wavef_for ) {
	case FMT_BYTE:
		cmd_ss << "COMM_FORMAT OFF," << "BYTE" << ",BIN " << endl;
		break;
	case FMT_WORD:
		cmd_ss << "COMM_FORMAT OFF," << "WORD" << ",BIN " << endl;
		break;
	case FMT_ASCII:
		cout << "WARNING: Chosen format is not available" << endl;
		break;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(100);

	// Points need to be set after the time/division and make sure the sampling rate will be less than 4 GS/s
	points_found = 0; 

	for (int i=0;i<10;i++) {
		if (config->wave_points==set_points[i]) {
			cmd_ss << "MEMORY_SIZE " << set_points[i] << endl;
			cout << "Number of points set to: " << set_points[i] << endl;
			points_found=1;
		}
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(100);

	if(points_found==0){
		cout << "ERROR: Invalid number of point" << endl;
		throw 1;
	}

	cmd_ss << "TRMD SINGLE" << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(1000);

}

// Todo: Make possible to use more than 2 channels

void Oscilloscope::init_Digilent() {

	stringstream cmd_ss;

	cmd_ss << fixed;
	cmd_ss << "*CLS" << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(30);

	//Channel 1
	cmd_ss << ":CHANnel1:DISPlay " << config->disp[0] << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	cmd_ss << ":CHANnel1:SCALe " << config->str_volt(0,config->scale).c_str() << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	cmd_ss << ":CHANnel1:OFFSet " << config->str_volt(0,config->offset).c_str() << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	//Channel 2
	cmd_ss << ":CHANnel2:DISPlay " << config->disp[1] << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	cmd_ss << ":CHANnel2:SCALe " << config->str_volt(1,config->scale).c_str() << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	cmd_ss << ":CHANnel2:OFFSet " << config->str_volt(1,config->offset).c_str() << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	// Time
	cmd_ss << ":TIMebase:MAIN:SCALe " << config->str_time( config->time_scale) << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	cmd_ss << ":TIMebase:MAIN:DELay " << config->str_time( config->time_delay) << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	//Trigger
	switch(config->trig_src) {
	case SRC_CH1:
		cmd_ss << ":TRIGger:EDGE:SOURce " << "CHANnel1" << endl;
		break;
	case SRC_CH2:
		cmd_ss << ":TRIGger:EDGE:SOURce " << "CHANnel2" << endl;
		break;
	case SRC_CH3:
		cmd_ss << ":TRIGger:EDGE:SOURce " << "CHANnel3" << endl;
		break;
	case SRC_CH4:
		cmd_ss << ":TRIGger:EDGE:SOURce " << "CHANnel4" << endl;
		break;
	case SRC_EXT:
		cmd_ss << ":TRIGger:EDGE:SOURce " << "EXTernal" << endl;
		break;
	default:
		break;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	cmd_ss << ":TRIGger:EDGE:LEVel " << config->str_volt(config->trig_level).c_str() << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	if (config->trig_mode==TRIG_MODE_EDGE) {
		cmd_ss << ":TRIGger:MODE " << "EDGE" << endl;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	// Acquire

	switch(config->acq_type) {
	case AQC_TYPE_NORM:
		cmd_ss << ":ACQuire:TYPE " << "NORMal" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		break;
	case AQC_TYPE_AVER:
		cmd_ss << ":ACQuire:TYPE " << "AVERage" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		cmd_ss << ":ACQuire:COUNT " << config->acq_count << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		break;
	case AQC_TYPE_PEAK:
		cmd_ss << ":ACQuire:TYPE " << "PEAK" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		cmd_ss << ":ACQuire:COUNT " << config->acq_count << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		break;
	case AQC_TYPE_HRES:
		cmd_ss << ":ACQuire:TYPE " << "HRES" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		cmd_ss << ":ACQuire:COUNT " << config->acq_count << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		break;
	}

	// Waveform
	switch(config->wavef_src) {
	case SRC_CH1:
		cmd_ss << ":WAVeform:SOURce " << "CHANnel1" << endl;
		break;
	case SRC_CH2:
		cmd_ss << ":WAVeform:SOURce " << "CHANnel2" << endl;
		break;
	case SRC_CH3:
		cmd_ss << ":WAVeform:SOURce " << "CHANnel3" << endl;
		break;
	case SRC_CH4:
		cmd_ss << ":WAVeform:SOURce " << "CHANnel4" << endl;
		break;
	case SRC_EXT:
		cmd_ss << ":WAVeform:SOURce " << "EXTernal" << endl;
		break;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	if (config->wavef_Border==BYTE_ORDER_MSB) {
		cmd_ss << ":WAVeform:BYTeorder " << "MSBFirst" << endl;
	}
	if (config->wavef_Border==BYTE_ORDER_LSB) {
		cmd_ss << ":WAVeform:BYTeorder " << "LSBFirst" << endl;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	switch(config->wavef_for ) {
	case FMT_BYTE:
		cmd_ss << ":WAVeform:FORMat " << "BYTE" << endl;
		break;
	case FMT_WORD:
		cmd_ss << ":WAVeform:FORMat " << "WORD" << endl;
		break;
	case FMT_ASCII:
		cmd_ss << ":WAVeform:FORMat " << "ASCII" << endl;
		break;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	switch(config->wave_points_m) {
	case PM_RAW:
		cmd_ss << ":WAVeform:POINts:MODE " << "RAW" << endl;
		break;
	case PM_NORMAL:
		cmd_ss << ":WAVeform:POINts:MODE " << "NORMal" << endl;
		break;
	case PM_MAXIMUM:
		cmd_ss << ":WAVeform:POINts:MODE " << "MAXimum" << endl;
		break;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	cmd_ss << ":WAVeform:POINts " << config->wave_points << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	cmd_ss << ":STOP" << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(1000);

	cmd_ss << ":SINGle" << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(1000);

}

void Oscilloscope::readdata(){
	readdata(0);
}

// Change configuration of the oscilloscope
// Purpose: Measure the other signal at the end of the experiment
// Modifies internal buffer of data

void Oscilloscope::readdata_ch(int ch) {

	stringstream cmd_ss;

	switch(ch) {
	case 1:
		cmd_ss << ":WAVeform:SOURce " << "CHANnel1" << endl;
		break;
	case 2:
		cmd_ss << ":WAVeform:SOURce " << "CHANnel2" << endl;
		break;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	Sleep(1000);

	readdata(1);

}

void Oscilloscope::readdata(int keep_signal) {

	switch(family) {
	case _DIGILENT_:
		readdata_Digilent(keep_signal);
		break;
	case _LECROY_:
		readdata_LeCroy(keep_signal);
		break;
	}

}

void Oscilloscope::readdata_LeCroy(int keep_signal) {

	stringstream cmd_ss;
	unsigned char opc;

	int tries = 0;
	static int rest = 0;

	switch(config->wavef_src) {
	case SRC_CH1:
		cmd_ss << "C1:WaveForm?" << endl;
		break;
	case SRC_CH2:
		cmd_ss << "C2:WaveForm?" << endl;
		break;
	case SRC_CH3:
		cmd_ss << "C3:WaveForm?" << endl;
		break;
	case SRC_CH4:
		cmd_ss << "C4:WaveForm?" << endl;
		break;
	case SRC_EXT:
		cout << "It is not possible to read the external signal" << endl;
		throw 1;
		break;
	}

	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	
	//cmd_ss << "*OPC?" << endl;
	//status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	//cmd_ss.str("");

	rest++;

	if (rest == 100) {
		Sleep(2000); // Give a longer rest every 100 traces
		rest = 0;
	}
	else {
		Sleep(200); // 200 // during some measurements (cfglut): 500
		// Sleep(6000); time for 5 MS
	}

	tries = 0;
	do{
		status = viRead(instr, binary_block_data, config->wave_points + 369, &retCount);
		Sleep(100); // This is the critical point //Dina hat von 100 auf 200 geändert.
		cout << "Reading status " << status << endl;
		tries++;

		if (tries == 30) {
			throw 10;
		}
	
	} while (status < VI_SUCCESS);

	if (keep_signal==0) {
		cmd_ss << "TRMD SINGLE" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		Sleep(100);
	}

}
void Oscilloscope::readdata_Digilent(int keep_signal) {

	char flag = 0;
	int aux=config->wave_points+11;
	int chunk_size = 5000;
	int counter = 0;

	stringstream cmd_ss;

	cmd_ss << ":WAVeform:DATA?" << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	cout << endl;

	Sleep(10);

	while (aux>0) {

		if (aux>chunk_size) {
			status = viRead(instr, &binary_block_data[counter], chunk_size, &retCount);
			counter+=chunk_size;
			aux-=chunk_size;
		}
		else {
			status = viRead(instr, &binary_block_data[counter], chunk_size, &retCount);
			counter+=aux;
			aux-=aux;
		}

		Sleep(10);

		cout << "." << std::flush;
	}
	cout << endl;

	Sleep(500);

	if (keep_signal==0) {
		cmd_ss << ":SINGle" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
	}

	while (flag==0) {

		Sleep(50);
		cmd_ss << ":AER?" << endl;
		status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
		cmd_ss.str("");
		status = viRead(instr, (unsigned char *)&flag, 1, &retCount);

	}

	cout << "Data read" << endl;

}

void Oscilloscope::saveinfile(ofstream &file) {
	saveinfile(file, 0,PRINT_DEC);
}

void Oscilloscope::saveinfile(ofstream &file, int print, int type) {

	if (family == _DIGILENT_) {
		saveinfile_Digilent(file, print, type);
	}
	if (family == _LECROY_) {
		saveinfile_LeCroy(file, print, type);
	}

}

static void resize_withoutinfo(char * str_in, unsigned char *number) {

	int len = 0;

	number[0] = str_in[0];
	number[1] = str_in[1];

	for (int i = 0; i < 9; i++) {
		number[i+2] = str_in[i + 2] - 48;
	}

	for (int i = 0; i <9; i++) {
		len = len * 10;
		len = len + number[i+2];
	}

	len = len - 346-2;

	for (int i = 8; i >= 0; i--) {
		number[i+2] = (len % 10)+48;
		len = len / 10;
	}

	cout << endl;
	for (int i = 0; i <11; i++) {
		cout << number[i] << " ";
	}
	cout << endl;

}

void Oscilloscope::saveinfile_LeCroy(ofstream &file, int print, int type) {

	unsigned char preamble[11];
	resize_withoutinfo((char*)&binary_block_data[10], preamble);

	switch (type) {
	case PRINT_DEC:
		for (int i = 0; i < 11; i++) {
			file << (int) preamble[i] << " \n";
		}
		for (int i = 369; i < config->wave_points +369 ; i++) {
			file << (int)((char)binary_block_data[i]) << " \n";
		}
		break;
	case PRINT_HEX:
		for (int i = 0; i < 11; i++) {
			file << (int)preamble[i] << " \n";
		}
		for (int i = 369; i < config->wave_points+369; i++) {
			file << setfill('0') << setw(2) << hex << (int)((char)binary_block_data[i]) << " \n";
		}
		break;
	case PRINT_DEC_ROW:
		for (int i = 0; i < 11; i++) {
			file << (int)preamble[i] << " " ;
		}
		for (int i = 369; i < config->wave_points+369; i++) {
			file << (int)((char)binary_block_data[i] ) << " " ;
		}
		break;
	case PRINT_HEX_ROW:
		for (int i = 0; i < 11; i++) {
			file << (int)preamble[i] << " ";
		}
		for (int i = 369; i < config->wave_points+369; i++) {
			file << setfill('0') << setw(2) << hex << (int)((char)binary_block_data[i]) << " " ;
		}
		break;
	}

	file << "10" << endl;

	if (print == 1) {
		for (int i = 0; i < 11; i++) {
			cout << preamble[i] << " \n";
		}
		for (int i = 369; i < config->wave_points; i++) {
			cout << +binary_block_data[i] << " \n";
		}
		cout << "10" << endl;
	}

}

void Oscilloscope::saveinfile_Digilent(ofstream &file, int print, int type ){

	switch(type) {
	case PRINT_DEC:
		for (int i=0;i<config->wave_points+11;i++) {
			file << +binary_block_data[i] << " " << endl;
		}
		break;
	case PRINT_HEX:
		for (int i=0;i<config->wave_points+11;i++) {
			file << setfill('0') << setw(2) << hex << +binary_block_data[i] << " " << endl;
		}
		break;
	case PRINT_DEC_ROW:
		for (int i=0;i<config->wave_points+11;i++) {
			file << +binary_block_data[i] << " ";
		}
		file << endl;
		break;
	case PRINT_HEX_ROW:
		for (int i=0;i<config->wave_points+11;i++) {
			file << setfill('0') << setw(2) << hex << +binary_block_data[i] << " ";
		}
		file << endl;
		break;
	}

	if (print == 1) {
		for (int i=0;i<config->wave_points+11;i++) {
			cout << +binary_block_data[i] << " ";
		}
		cout << endl;
	}

}

void Oscilloscope::print_acq_point() {

	char buffer[30];
	int buffer_len;

	const char NL = 10;
	char c = 0;
	int i;
	stringstream cmd_ss;

	// Read Acquire points
	cmd_ss << ":ACQuire:POINts?" << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	Sleep(10);

	i=0;
	while (c!=NL) {
		status = viRead(instr, (unsigned char *)&c, 1, &retCount);
		buffer[i]=c;
		i++;
	}

	buffer_len = i;

	cout << "Points to acquire ";
	for (i=0;i<buffer_len;i++) {
		cout << buffer[i];
	}
	cout << endl;

}

void Oscilloscope::get_print_cfg(int print) {

	const char NL = 10;
	char c = 0;
	int i;
	stringstream cmd_ss;

	// Read preamble
	cmd_ss << ":WAVeform:PREamble?" << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");
	Sleep(100);

	i = 0;
	c = 0;

	while (c!=NL) {
		status = viRead(instr, (unsigned char *)&c, 1, &retCount);
		preamble.buffer[i]=c;
		i++;
	}

	preamble.organize_data();

	if (print==1){
		preamble.print_data();
	}

}

void Oscilloscope::save_cfg(ofstream &file) {
	preamble.save_data(file);
}

// Assumes that the signal saved in binary_block_data is the trigger signal
// It represents the signal in binary, 0 less than the average, 1 more or equal than the average
// It compresses the signal in the format <bit_value1><number of repetitions1>...<bit_value_n><number of repetitions_n>

string Oscilloscope::compress_trigger(){

	unsigned char max = 0;
	unsigned char  min = 255;
	unsigned char mean = 0;
	unsigned char bit;
	unsigned char cmp;
	int counter = 0;
	string line;
	ostringstream oss;

	for (int i=10;i<config->wave_points+10;i++) {
		if (binary_block_data[i]>max) {
			max = binary_block_data[i];
		}
		if (binary_block_data[i]<min) {
			min= binary_block_data[i];
		}
		mean = (max/2)+(min/2);
	}

	bit = (binary_block_data[10]>=mean);
	counter = 1;

	for (int i=11;i<config->wave_points+10;i++) {

		cmp = binary_block_data[i]>=mean;
		if(bit==cmp) {
			counter++;
		}
		else {
			oss << (int)bit << " " << counter << " ";
			counter=1;
			bit=cmp;
		}
	}

	oss << (int)bit << " " << counter;

	line = oss.str();

	return line;

}


// Auxiliar function for saving know configuration

Osc_config * Oscilloscope::known_config(int conf_num) {

	int points_num=50000;

	// Device:Arduino
	// Shut resistor: 47 ohms connected in GND
	// Algorithm: LadderStepECC
	// Averaging: No
	Osc_config *ArdR47GND_LSECC_Nave= new Osc_config(2);
	ArdR47GND_LSECC_Nave->cfg_ch(1, 1, 40e-3, 720e-3, 0);
	ArdR47GND_LSECC_Nave->cfg_ch(2, 1, 1, 1.75, 0);
	ArdR47GND_LSECC_Nave->cfg_time(50e-6, 200e-6);
	ArdR47GND_LSECC_Nave->cfg_trigger(SRC_EXT, 1.5, TRIG_MODE_EDGE);
	ArdR47GND_LSECC_Nave->cfg_waveform(SRC_CH1,BYTE_ORDER_MSB, FMT_BYTE,points_num, PM_RAW);
	ArdR47GND_LSECC_Nave->cfg_acquire(AQC_TYPE_NORM, 0);

	// Device:Arduino
	// Shut resistor: 100 ohms conncted in GND
	// Algorithm: LadderStepECC
	// Averaging: No
	Osc_config *ArdR100GND_LSECC_Nave= new Osc_config(2);
	ArdR100GND_LSECC_Nave->cfg_ch(1, 1, 50e-3, 4.0, 0);
	ArdR100GND_LSECC_Nave->cfg_ch(2, 1, 1, 1.75, 0);
	ArdR100GND_LSECC_Nave->cfg_time(500e-6, 1.5e-3);
	ArdR100GND_LSECC_Nave->cfg_trigger(SRC_EXT, 1.5, TRIG_MODE_EDGE);
	ArdR100GND_LSECC_Nave->cfg_waveform(SRC_CH1,BYTE_ORDER_MSB, FMT_BYTE,points_num, PM_RAW);
	ArdR100GND_LSECC_Nave->cfg_acquire(AQC_TYPE_NORM, 0);

	// Device:Arduino
	// Shut resistor: 100 ohms
	// Algorithm: LadderStepECC
	// Averaging: No
	Osc_config *ArdR100_LSECC_Nave= new Osc_config(2);
	ArdR100_LSECC_Nave->cfg_ch(1, 1, 50e-3, 4.0, 0);
	ArdR100_LSECC_Nave->cfg_ch(2, 1, 1, 1.75, 0);
	ArdR100_LSECC_Nave->cfg_time(500e-6, 1.5e-3);
	ArdR100_LSECC_Nave->cfg_trigger(SRC_EXT, 1.5, TRIG_MODE_EDGE);
	ArdR100_LSECC_Nave->cfg_waveform(SRC_CH1,BYTE_ORDER_MSB, FMT_BYTE,points_num, PM_RAW);
	ArdR100_LSECC_Nave->cfg_acquire(AQC_TYPE_NORM, 0);

	// Device:Arduino
	// Shut resistor: 100 ohms
	// Algorithm: LadderStepECC
	// Averaging: 10
	Osc_config *ArdR100_LSECC_Ave= new Osc_config(2);
	ArdR100_LSECC_Ave->cfg_ch(1, 1, 20e-3, 4.0, 0);
	ArdR100_LSECC_Ave->cfg_ch(2, 1, 1, 1.75, 0);
	ArdR100_LSECC_Ave->cfg_time(500e-6, 1.5e-3);
	ArdR100_LSECC_Ave->cfg_trigger(SRC_EXT, 1.5, TRIG_MODE_EDGE);
	ArdR100_LSECC_Ave->cfg_waveform(SRC_CH1,BYTE_ORDER_MSB, FMT_BYTE,points_num, PM_RAW);
	ArdR100_LSECC_Ave->cfg_acquire(AQC_TYPE_AVER, 10);

	// Device:Arduino
	// Shut resistor: 47 ohms
	// Algorithm: LadderStepECC
	// Averaging: No
	Osc_config *ArdR47_LSECC_Nave= new Osc_config(2);
	ArdR47_LSECC_Nave->cfg_ch(1, 1, 30e-3, 3.9, 0);
	ArdR47_LSECC_Nave->cfg_ch(2, 1, 5, 0, 0);
	ArdR47_LSECC_Nave->cfg_time(500e-6, 1.5e-3);
	ArdR47_LSECC_Nave->cfg_trigger(SRC_EXT, 1.5, TRIG_MODE_EDGE);
	ArdR47_LSECC_Nave->cfg_waveform(SRC_CH1,BYTE_ORDER_MSB, FMT_BYTE,points_num, PM_RAW);
	ArdR47_LSECC_Nave->cfg_acquire(AQC_TYPE_NORM, 0);

	// Device:Arduino
	// Shut resistor: 1.5 ohms
	// Algorithm: LadderStepECC
	// Averaging: No
	Osc_config *ArdR1_5_LSECC_Nave= new Osc_config(2);
	ArdR1_5_LSECC_Nave->cfg_ch(1, 1, 50e-3, 4.94, 0);
	ArdR1_5_LSECC_Nave->cfg_ch(2, 1, 1, 1.75, 0);
	ArdR1_5_LSECC_Nave->cfg_time(300e-6, 1.5e-3);
	ArdR1_5_LSECC_Nave->cfg_trigger(SRC_EXT, 1.5, TRIG_MODE_EDGE);
	ArdR1_5_LSECC_Nave->cfg_waveform(SRC_CH1,BYTE_ORDER_MSB, FMT_BYTE,points_num, PM_RAW);
	ArdR1_5_LSECC_Nave->cfg_acquire(AQC_TYPE_NORM, 0);

	switch(conf_num) {
	case 1:
		return ArdR100_LSECC_Nave;
	case 2:
		return ArdR100_LSECC_Ave;
	case 3:
		return ArdR47_LSECC_Nave;
	case 4:
		return ArdR1_5_LSECC_Nave;
	case 5:
		return ArdR100GND_LSECC_Nave;
	case 6:
		return ArdR47GND_LSECC_Nave;
	default:
		return NULL;
	}

}

void Oscilloscope::create_var_ave() {

	for (int i=0;i<num_ave;i++) {
		binary_block_data_ave[i] = new unsigned char[config->wave_points+11];
	}

}

void Oscilloscope::create_ave(int x) {

	int i,j;
	int aux=0;

	for (i=0; i < config->wave_points+11; i++) {
		binary_block_data_ave[x][i]=binary_block_data[i];
	}

	if (x==(num_ave-1)) {
		for (i=10;i< config->wave_points+10;i++) {
			aux=0;
			for (j=0;j<num_ave;j++) {
				aux=binary_block_data_ave[j][i];
			}
			aux/=num_ave;
			binary_block_data[i]= (unsigned char) aux;
		}
	}

}

void Oscilloscope::destroy_var_ave() {

	for (int i=0;i<num_ave;i++) {
		delete binary_block_data_ave[i];
	}

}

void Oscilloscope::printID() {

	unsigned char answer[100];
	int tmp;
	stringstream cmd_ss;

	cmd_ss << "*IDN?" << endl;
	status = viWrite(instr, (ViBuf)cmd_ss.str().c_str(), (ViUInt32)cmd_ss.str().length(), &writeCount);
	cmd_ss.str("");

	Sleep(100);

	status = viRead(instr, (unsigned char *)&answer, 100, &retCount);

	cout << "Device ID " << endl;
	for (int i=0;i<100;i++) {
		tmp=answer[i];
		cout << tmp << " ";
	}
	cout << endl;

}