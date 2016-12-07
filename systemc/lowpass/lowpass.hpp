#ifndef LOWPASS_HPP
#define LOWPASS_HPP

#include <systemc>
using namespace sc_core;

struct Lowpass : public sc_module
{
	// Ports
	sc_in <bool> clk, reset;
	sc_in <int > x;
	sc_out<int > y;

	// Processes
	void state();
	void transition();

	// Constructor
	SC_HAS_PROCESS(Lowpass);
	Lowpass(sc_module_name);

private:
	sc_signal<int> x_1, x_2, x_3, average;
};

#endif
