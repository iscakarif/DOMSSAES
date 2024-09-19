#ifndef OSC_PREAMBLE_H_
#define OSC_PREAMBLE_H_

#include <fstream>
#include <iomanip>
#include <iostream>

using namespace std;

class Osc_preamble {
public:

	char buffer[200];
	char format[3];
	char type[3];
	char points[12];
	char count[3];
	char xinc[20];
	char xori[20];
	char xref[12];
	char yinc[20];
	char yori[20];
	char yref[12];

	Osc_preamble();
	virtual ~Osc_preamble();

	void organize_data();
	void print_data();
	void save_data(ofstream &file);

};

#endif /* OSC_PREAMBLE_H_ */