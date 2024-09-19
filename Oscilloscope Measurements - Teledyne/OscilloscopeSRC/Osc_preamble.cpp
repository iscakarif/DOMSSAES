#include "Osc_preamble.h"

Osc_preamble::Osc_preamble(){ }

Osc_preamble::~Osc_preamble(){ }

static void read_par(char *buffer, char *value, int *i ) {

	int rel_i = 0;
	int index =* i;

	while (buffer[index]!=',' && buffer[index]!=10) {
		value[rel_i] = buffer[index];
		index++;
		rel_i++;
	}

	index++;
	value[rel_i] = '\0';
	*i = index;

}

static string currentDateTime() {

	time_t now = time(0);
	struct tm tstruct;
	char buf[80];
	localtime_s(&tstruct,&now);
	strftime(buf, sizeof(buf), "%Y-%m-%d.%X", &tstruct);

	return string(buf);

}

void Osc_preamble::organize_data() {

	int i=0;

	read_par(buffer, format, &i);
	read_par(buffer, type, &i);
	read_par(buffer, points, &i);
	read_par(buffer, count, &i);
	read_par(buffer, xinc, &i);
	read_par(buffer, xori, &i);
	read_par(buffer, xref, &i);
	read_par(buffer, yinc, &i);
	read_par(buffer, yori, &i);
	read_par(buffer, yref, &i);

}

void Osc_preamble::print_data() {

	cout << "Format " << format << endl;
	cout << "Type " << type << endl;
	cout << "Points " << points << endl;
	cout << "Count " << count << endl;
	cout << "X_inc " << xinc << endl;
	cout << "X_xori " << xori << endl;
	cout << "X_xref " << xref << endl;
	cout << "Y_inc " << yinc << endl;
	cout << "Y_ori " << yori << endl;
	cout << "Y_yref " << yref << endl;

}

void Osc_preamble::save_data(ofstream &file) {

	file << "Format " << format << endl;
	file << "Type " << type << endl;
	file << "Points " << points << endl;
	file << "Count " << count << endl;
	file << "X_inc " << xinc << endl;
	file << "X_xori " << xori << endl;
	file << "X_xref " << xref << endl;
	file << "Y_inc " << yinc << endl;
	file << "Y_ori " << yori << endl;
	file << "Y_yref " << yref << endl;

	file << "Date " << currentDateTime().c_str() << endl;

}