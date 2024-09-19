#ifndef OSC_CONFIG_H_
#define OSC_CONFIG_H_

#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>

using namespace std;

#define SRC_CH1 1
#define SRC_CH2 2
#define SRC_CH3 3
#define SRC_CH4 4

#define SRC_EXT 5

#define TRIG_MODE_EDGE 1

#define FMT_BYTE 1
#define FMT_WORD 2
#define FMT_ASCII 3

#define BYTE_ORDER_MSB 1 // MSBFirst
#define BYTE_ORDER_LSB 2

#define PM_RAW 1
#define PM_NORMAL 2
#define PM_MAXIMUM 3

#define AQC_TYPE_NORM 1
#define AQC_TYPE_AVER 2
#define AQC_TYPE_PEAK 3
#define AQC_TYPE_HRES 4

class Osc_config {
public:

	int num_ch;
	int precision;

	float *scale;
	float *offset;
	float *ref;
	int *disp;

	float time_scale;
	float time_delay;

	int trig_src;
	float trig_level;
	int trig_mode;

	int wavef_src;
	int wavef_Border;
	int wavef_for;
	int wave_points;
	int wave_points_m;

	int acq_type;
	int acq_count;

	Osc_config(int num_ch);
	virtual ~Osc_config();

	void cfg_ch(int ch, int disp, float scale, float offset, float ref);
	void cfg_time(float scale);
	void cfg_time(float scale, float delay);
	void cfg_trigger(int source, float level, int mode);
	void cfg_waveform(int source, int Border, int format,int points, int points_m);
	void cfg_acquire(int type, int count);

	void print_cfg();
	void print_cfg_ch(int ch);
	void print_cfg_time();
	void print_trigger();
	void print_waveform();
	void print_acquire(int type, int count);

	string str_volt(int ch_in, float *val);
	string str_volt(float val);
	string str_time(float val);

};

#endif /* OSC_CONFIG_H_ */