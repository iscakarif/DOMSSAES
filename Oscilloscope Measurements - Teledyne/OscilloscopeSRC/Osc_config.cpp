#include "Osc_config.h"

// Constructor & Destructor

Osc_config::Osc_config(int num_ch) {

	this->num_ch = num_ch;
	scale = new float [num_ch];
	offset = new float [num_ch];
	ref = new float [num_ch];
	disp = new int [num_ch];

	// Load default values
	precision = 4;

	time_scale = 0;
	time_delay = 0;

	trig_src = SRC_EXT;
	trig_level = 1;
	trig_mode = TRIG_MODE_EDGE;

	wavef_src = SRC_CH1;
	wavef_Border = BYTE_ORDER_MSB;
	wavef_for = FMT_BYTE;
	wave_points = 1000;
	wave_points_m = PM_RAW;

	acq_type=AQC_TYPE_NORM;
	acq_count = 1;

}

Osc_config::~Osc_config() {

	delete scale;
	delete offset;
	delete ref;
	delete disp;

}

// Set configuration parameters

void Osc_config::cfg_ch(int ch, int disp, float scale, float offset, float ref) {

	ch = ch-1;
	this->disp[ch] = disp;
	this->scale[ch] = scale;
	this->offset[ch] = offset;
	this->ref[ch] = ref;

}

void Osc_config::cfg_time(float scale) {

	time_scale = scale;
	time_delay = scale*2/10;

}

void Osc_config::cfg_time(float scale, float delay) {

	time_scale = scale;
	time_delay = delay;

}
void Osc_config::cfg_trigger(int source, float level, int mode) {

	trig_src = source;
	trig_level = level;
	trig_mode = mode;

}

void Osc_config::cfg_waveform(int source, int Border, int format,int points, int points_m) {

	wavef_src = source;
	wavef_Border = Border;
	wavef_for = format;
	wave_points = points;
	wave_points_m = points_m;

}

void Osc_config::cfg_acquire(int type, int count) {

	acq_type = type;
	acq_count = count;

}

// Print configuration parameters

void Osc_config::print_cfg() {

	print_cfg_time();

	for (int i=1;i<=num_ch;i++) {
		this->print_cfg_ch(i);
	}

	print_trigger();
	print_waveform();

}

void Osc_config::print_cfg_ch(int ch) {

	ch = ch-1;

	cout << "Channel " << ch+1 << " configuration:" << endl;
	cout << fixed;

	if (disp[ch]==0) {
		cout << "-- Display off" << endl;
	}
	else {
		cout << "-- Display on " << endl;
	}

	cout << "-- Scale " << str_volt(ch, scale).c_str() << endl;
	cout << "-- Offset " << str_volt(ch, offset).c_str() << endl;
	cout << "-- Reference " << str_volt(ch, ref).c_str() << endl;

	cout << endl;

}

void Osc_config::print_cfg_time() {

	cout << "Time configuration:" << endl;
	cout << fixed;

	cout << "-- Time scale " << str_time( time_scale).c_str() << endl;
	cout << "-- Time delay " << str_time( time_delay).c_str() << endl;
	cout << endl;

}

void Osc_config::print_trigger() {

	cout << "Trigger configuration:" << endl;

	switch(trig_src) {
	case SRC_CH1:
		cout << "-- Trigger source " << "Channel 1" << endl;
		break;
	case SRC_CH2:
		cout << "-- Trigger source " << "Channel 2" << endl;
		break;
	case SRC_CH3:
		cout << "-- Trigger source " << "Channel 3" << endl;
		break;
	case SRC_CH4:
		cout << "-- Trigger source " << "Channel 4" << endl;
		break;
	case SRC_EXT:
		cout << "-- Trigger source " << "External" << endl;
		break;
	default:
		cout << "-- No configured source for trigger" << endl;
		break;
	}

	cout << "-- Trigger level " << str_volt(trig_level).c_str() << endl;

	if (trig_mode==TRIG_MODE_EDGE) {
		cout << "-- Trigger mode " << "Edge" << endl;
	}
	else {
		cout << "-- No configured mode for trigger" << endl;
	}

}

void Osc_config::print_waveform() {

	cout << "Waveform configuration:" << endl;

	switch(wavef_src) {
	case SRC_CH1:
		cout << "-- Source Channel 1" << endl;
		break;
	case SRC_CH2:
		cout << "-- Source Channel 2" << endl;
		break;
	case SRC_CH3:
		cout << "-- Source Channel 3" << endl;
		break;
	case SRC_CH4:
		cout << "-- Source Channel 4" << endl;
		break;
	case SRC_EXT:
		cout << "-- Source External" << endl;
		break;
	default:
		cout << "-- Source not configured" << endl;
		break;
	}

	if (wavef_Border==BYTE_ORDER_MSB) {
		cout << "-- Byte order MSB first" << endl;
	}
	if (wavef_Border==BYTE_ORDER_LSB) {
		cout << "-- Byte order LSB first" << endl;
	}

	switch(wave_points_m) {
	case FMT_BYTE:
		cout << "-- Format Byte" << endl;
		break;
	case FMT_WORD:
		cout << "-- Format Word" << endl;
		break;
	case FMT_ASCII:
		cout << "-- Format ASCII" << endl;
		break;
	default:
		cout << "-- Format not configured" << endl;
		break;
	}

	switch(wavef_for) {
	case PM_RAW:
		cout << "-- Points " << wave_points << " in mode RAW" << endl;
		break;
	case PM_NORMAL:
		cout << "-- Points " << wave_points << " in mode Normal" << endl;
		break;
	case PM_MAXIMUM:
		cout << "-- Points " << wave_points << " in mode Maximum" << endl;
		break;
	default:
		cout << "-- Points " << wave_points << ", mode not configured" << endl;
		break;
	}

}

void Osc_config::print_acquire(int type, int count) {

	cout << "Acquire configuration:" << endl;

	switch(acq_type) {
	case AQC_TYPE_NORM:
		cout << "-- Acquire type " << "Normal" << endl;
		break;
	case AQC_TYPE_AVER:
		cout << "-- Acquire type " << "Average" << " with counter in " << acq_count << endl;
				break;
	case AQC_TYPE_PEAK:
		cout << "-- Acquire type " << "Peak" << " with counter in " << acq_count << endl;
		break;
	case AQC_TYPE_HRES:
		cout << "-- Acquire type " << "High resolution" << " with counter in " << acq_count << endl;
		break;
	default:
		cout << "-- Acquire type " << "Not configured" << " with counter in " << acq_count << endl;
		break;
	}

}

// Convert parameters to string

string Osc_config::str_volt(int ch_in, float *val) {

	ostringstream oss;
	if (val[ch_in]<1 && val[ch_in]!=0 ) {
		oss << setprecision(precision) << val[ch_in]*1000 << " mV";
	}
	else {
		oss << setprecision(precision) << val[ch_in] << " V";
	}

	return oss.str();

}

string Osc_config::str_volt(float val) {

	ostringstream oss;
	if (val<1 && val!=0 ) {
		oss << setprecision(precision) << val*1000 << " mV";
	}
	else {
		oss << setprecision(precision) << val << " V";
	}

	return oss.str();

}

string Osc_config::str_time( float val) {

	ostringstream oss;
	float aux;

	if (val<0) {
		oss << "-";
		val=-val;
	}

	if (val>=1) {
		oss << setprecision(precision) << time_scale << " S";
	}
	else {
		aux=val*1000;
		if (aux>=1) {
			oss << setprecision(precision) << aux << " mS";
		}
		else {
			aux=aux*1000;
			oss << setprecision(precision) << aux << " uS";
		}
	}

	return oss.str();

}