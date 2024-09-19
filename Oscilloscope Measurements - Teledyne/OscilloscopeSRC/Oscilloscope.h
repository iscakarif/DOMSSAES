#ifndef OSCILLOSCOPE_H_
#define OSCILLOSCOPE_H_

#include <fstream>
#include <iomanip>
#include <iostream>

#include <windows.h>

#include "visa.h" // Communication with oscilloscope

#include "Osc_preamble.h"
#include "Osc_config.h"

#define PRINT_DEC 1
#define PRINT_HEX 2
#define PRINT_DEC_ROW 3
#define PRINT_HEX_ROW 4

#define _DIGILENT_ 0
#define _LECROY_ 1

using namespace std;

class Oscilloscope {
public:

	ViSession defaultRM;
	ViSession instr;
	unsigned char *binary_block_data;

	unsigned char *binary_block_data_ave[10];
	int num_ave;
	int family; // 0 = Digilent (Default), 1 = Lecroy

	Osc_preamble preamble;
	Osc_config *config;

	Oscilloscope();
	Oscilloscope(int points, string port);
	virtual ~Oscilloscope();

	string readDevSystem();
	void configuration(Osc_config *conf, int print);
	void setPort(string port);
	void setNumpoints(int numpoints);
	void setFamily(int fam);
	void get_print_cfg(int print); // Needs to be executed with a signal in the screen
	void save_cfg(ofstream &file);

	void init();
	void init_Digilent();
	void init_LeCroy();

	void readdata();
	void readdata_LeCroy(int keep_signal);
	void readdata_Digilent(int keep_signal);
	void readdata(int keep_signal);
	void readdata_ch(int ch);
	void saveinfile(ofstream &file);
	void saveinfile(ofstream &file, int print, int type );
	void saveinfile_Digilent(ofstream &file, int print, int type);
	void saveinfile_LeCroy(ofstream &file, int print, int type);

	void printID();

	void print_acq_point();

	string compress_trigger();

	Osc_config * known_config(int conf_num);

	void create_var_ave();
	void create_ave(int x);
	void destroy_var_ave();

};

#endif /* OSCILLOSCOPE_H_ */