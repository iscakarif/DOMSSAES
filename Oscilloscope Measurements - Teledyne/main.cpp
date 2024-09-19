////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////// Small Scale AES 444 - Oscilloscope Measurement //////////////////////////
///////////////////////////////////// Creation Date: 01.07.2022 ////////////////////////////////////
///////////////////////////////////////// Author: Maël Gay /////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////// Special thanks to Felipe Andres for the original interface scripts ////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////
///////////////// Windows related ////////////////
//////////////////////////////////////////////////

#if defined(_MSC_VER) && !defined(_CRT_SECURE_NO_DEPRECATE)
	#define _CRT_SECURE_NO_DEPRECATE
#endif
// Functions like strcpy are technically not secure because they do not contain a 'length'. But we disable this warning for the VISA examples since we never copy more than the actual buffer size.

//////////////////////////////////////////////////
//////////////////// Includes ////////////////////
//////////////////////////////////////////////////

// Generic

#include <ctime>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <random>

// Oscilloscope

#include "./OscilloscopeSRC/Oscilloscope.h"
#include "./Sakura/SaseboGII.h"

//////////////////////////////////////////////////
//////////////////// Namespace ///////////////////
//////////////////////////////////////////////////

using namespace std;

//////////////////////////////////////////////////
///////////////////// Define /////////////////////
//////////////////////////////////////////////////

#define VERBOSE 0

//////////////////////////////////////////////////
//////////////////// Functions ///////////////////
//////////////////////////////////////////////////

void storeData(uint8_t *array, ofstream &file) {

	for (int i = 0; i < 16; i++) {
		file << hex << (int)array[i] << " ";
	}
	file << endl;

}

void GenerateManualKey(uint8_t* key) { // Defined this way for readability
	key[0] = 0X0F;
	key[1] = 0X0E;
	key[2] = 0X0D;
	key[3] = 0X0C;
	key[4] = 0X0B;
	key[5] = 0X0A;
	key[6] = 0X09;
	key[7] = 0X08;
	key[8] = 0X07;
	key[9] = 0X06;
	key[10] = 0X05;
	key[11] = 0X04;
	key[12] = 0X03;
	key[13] = 0X02;
	key[14] = 0X01;
	key[15] = 0X00;
}

void GenerateManualPlaintext(uint8_t* plaintext) { // Defined this way for readability
	plaintext[0] = 0X00;
	plaintext[1] = 0X00;
	plaintext[2] = 0X00;
	plaintext[3] = 0X00;
	plaintext[4] = 0X00;
	plaintext[5] = 0X00;
	plaintext[6] = 0X00;
	plaintext[7] = 0X00;
	plaintext[8] = 0X00;
	plaintext[9] = 0X00;
	plaintext[10] = 0X00;
	plaintext[11] = 0X00;
	plaintext[12] = 0X00;
	plaintext[13] = 0X00;
	plaintext[14] = 0X00;
	plaintext[15] = 0X00;
}

//////////////////////////////////////////////////
////////////////////// Main //////////////////////
//////////////////////////////////////////////////

int main() {

	// Variables

	uint8_t key[16] = {};
	uint8_t plaintext[16] = {};
	uint8_t ciphertext [16];

	// Generation

	GenerateManualKey(key);
	GenerateManualPlaintext(plaintext);

	// Output files

	ofstream plaintextFile, ciphertextFile, traceFile, parameterFile;

	// Numbers of iterations

	int initialised = 1000;  // Warmup
	int iterations = 100000; // Number of iterations

	// Oscilloscope parameters

	int ch1_disp = 1; // Display active
	double ch1_scale = 3e-3; // Scale: 3mV/div
	double ch1_offset = 0; // Offset: 0mV
	int ch1_ref = 0;

	int ch2_disp = 1; // Display active
	double ch2_scale = 1; // Scale: 1V/div
	double ch2_offset = 0; // Offset: 0V
	int ch2_ref = 0;

	int ch3_disp = 0; // Display inactive
	double ch3_scale = 0; // Scale: 0V/div
	double ch3_offset = 0; // Offset: 0V
	int ch3_ref = 0;

	int ch4_disp = 0; // Display inactive
	double ch4_scale = 0; // Scale: 0V/div
	double ch4_offset = 0; // Offset: 0V
	int ch4_ref = 0;

	double time_scale = 5e-6; // Time scale 5ms/div (check the available steps)
	double time_delay = -15e-6; // Delay -15ms

	double trigger_level = 2.5; // Trigger level 2.5V

	int num_points = 100000; // Defines the sampling rate (check the available steps)

	string port;
	stringstream cmd_ss;

	// Random seed

	srand(time(NULL));

	// RNG

	random_device dev;
	mt19937 rng(dev());
	uniform_int_distribution<> random(0, 15); // distribution in range [0, 15]

	// Initialisation of the Sakura board
	SaseboGII sasebo;
	sasebo.openDevice(0, 9600); // For sasebo use openDevice(1,9600)

	// Initialisation of the oscilloscope
	Oscilloscope WaveSurfer3024z;

	WaveSurfer3024z.setFamily(_LECROY_); // Digilent is default, this should be place before readDevSystem

	port = WaveSurfer3024z.readDevSystem();
	WaveSurfer3024z.setPort(port);
	WaveSurfer3024z.setFamily(_LECROY_); // Digilent is default

	Osc_config LeCroyCnf(3);
	LeCroyCnf.cfg_ch(1, ch1_disp, ch1_scale, ch1_offset, ch1_ref); // Channel 1 parameters: channel, display, scale, offset
	LeCroyCnf.cfg_ch(2, ch2_disp, ch2_scale, ch2_offset, ch2_ref); // Channel 2 parameters: channel, display, scale, offset
	LeCroyCnf.cfg_ch(3, ch3_disp, ch3_scale, ch3_offset, ch3_ref); // Channel 3 parameters: channel, display, scale, offset
	LeCroyCnf.cfg_ch(4, ch4_disp, ch4_scale, ch4_offset, ch4_ref); // Channel 4 parameters: channel, display, scale, offset
	LeCroyCnf.cfg_time(time_scale, time_delay); // Time parameters: scale, delay
	LeCroyCnf.cfg_trigger(SRC_CH2, trigger_level, TRIG_MODE_EDGE); // Trigger parameters: channel 2, level, mode edge
	LeCroyCnf.cfg_waveform(SRC_CH1, BYTE_ORDER_MSB, FMT_BYTE, num_points, PM_RAW); // Data transmission

	WaveSurfer3024z.configuration(&LeCroyCnf, 0);
	WaveSurfer3024z.setNumpoints(num_points); // Place after Configuration and before initialization to ensure effect
	WaveSurfer3024z.init();

	// Open files
	plaintextFile.open("plaintexts.txt", ios::out);
	ciphertextFile.open("ciphertexts.txt", ios::out);
	traceFile.open("traces.txt", ios::out);
	parameterFile.open("parameters.txt", ios::out);

	// Saves the oscilloscope parameters - Human readable
	parameterFile << "--------------------------------------------------" << endl;
	parameterFile << "------------- Oscilloscope Parameters ------------" << endl;
	parameterFile << "--------------------------------------------------" << endl << endl;
	parameterFile << "-------------------- Channel 1 -------------------" << endl;
	parameterFile << "Display:            " << dec << ch1_disp << endl;
	parameterFile << "Scale:              " << dec << ch1_scale << "V/div" << endl;
	parameterFile << "Offset:             " << dec << ch1_offset << "V" << endl << endl;
	parameterFile << "-------------------- Channel 2 -------------------" << endl;
	parameterFile << "Display:            " << dec << ch2_disp << endl;
	parameterFile << "Scale:              " << dec << ch2_scale << "V/div" << endl;
	parameterFile << "Offset:             " << dec << ch2_offset << "V" << endl << endl;
	parameterFile << "-------------------- Channel 3 -------------------" << endl;
	parameterFile << "Display:            " << dec << ch3_disp << endl;
	parameterFile << "Scale:              " << dec << ch3_scale << "V/div" << endl;
	parameterFile << "Offset:             " << dec << ch3_offset << "V" << endl << endl;
	parameterFile << "-------------------- Channel 4 -------------------" << endl;
	parameterFile << "Display:            " << dec << ch4_disp << endl;
	parameterFile << "Scale:              " << dec << ch4_scale << "V/div" << endl;
	parameterFile << "Offset:             " << dec << ch4_offset << "V" << endl << endl;
	parameterFile << "------------------- Time Scale -------------------" << endl;
	parameterFile << "Scale:              " << dec << time_scale << "s/div" << endl;
	parameterFile << "Delay:              " << dec << time_delay << "s" << endl << endl;
	parameterFile << "--------------------- Trigger --------------------" << endl;
	parameterFile << "Level:              " << dec << trigger_level << "V" << endl << endl;
	parameterFile << "--------------------- Points ---------------------" << endl;
	parameterFile << "Number of Points:   " << dec << num_points;

	for (int j = 0; j<initialised; j++) {

		// Start communication with board:
		
		sasebo.write(ADDR_CONT, ZERO);
		while (sasebo.read(ADDR_CONT) != 0) {
			// nop
		}
		sasebo.write(ADDR_CONT, ZERO);

		// Send parameters:
		sasebo.write(ADDR_MODE, ENC);

		// Send key:
		sasebo.writeBurst(ADDR_KEY, (char*)key, 16);
		sasebo.write(ADDR_CONT, KSET);
		while (sasebo.read(ADDR_CONT) != 0) {
			Sleep(0);
		}

		// Send plaintext:
		sasebo.writeBurst(ADDR_DATA, (char*)plaintext, 16);

		sasebo.write(ADDR_CONT, RUN); // Execute cipher processing
		// Wait till end of execution
		int counter = 0;
		while (sasebo.read(ADDR_MODE) != 0 && counter < 100) {
			counter++;
			Sleep(0);
		}

		//Sleep(100); // Wait for algorithm execution
		sasebo.readBurst(ADDR_OTEXT0, (char*)ciphertext, 16);

	}

	sasebo.write(ADDR_CONT, IPRST);

	for (int j = 0; j < iterations; j++) {

		cout << "Iteration " << dec << j << endl;
		
		// Plaintext generation

		for (int i = 0; i < 16; i++)
		{
			plaintext[i] = (byte)random(rng);
		}

		// Start communication with board:

		while (sasebo.read(ADDR_CONT) != 0) {
			//nop
		}
		sasebo.write(ADDR_CONT, ZERO);

		// Send parameters:
		sasebo.write(ADDR_MODE, ENC);

		// Send key:
		sasebo.writeBurst(ADDR_KEY, (char*)key, 16);
		sasebo.write(ADDR_CONT, KSET);
		while (sasebo.read(ADDR_CONT) != 0) {
			Sleep(0);
		}

		// Send plaintext:
		sasebo.writeBurst(ADDR_DATA, (char*)plaintext, 16);

		sasebo.write(ADDR_CONT, RUN); // Execute cipher processing
		// Wait till end of execution
		int counter = 0;
		while (sasebo.read(ADDR_MODE) != 0 && counter < 100) {
			counter++;
			Sleep(0);
		}

		//Sleep(100); // Wait for algorithm execution
		sasebo.readBurst(ADDR_OTEXT0, (char*)ciphertext, 16);

		try {
			WaveSurfer3024z.readdata();
			storeData(plaintext, plaintextFile);
			storeData(ciphertext, ciphertextFile);
			WaveSurfer3024z.saveinfile(traceFile, 0, PRINT_DEC_ROW);
		}
		catch (int e) {
			if (e == 10) {
				cout << "Timeout reading the trace. It will be ignored" << endl;
			}
			else {
				throw e;
			}
		}

		//Sleep(1000); // Wait for Debugging

		sasebo.write(ADDR_CONT, IPRST); // Reset signal
		//Sleep(10);

	}

	sasebo.closeDevice();
	plaintextFile.close();
	ciphertextFile.close();
	traceFile.close();
	parameterFile.close();

	return 0;

}