#ifndef LOWPASS_TB_HPP
#define LOWPASS_TB_HPP

#include <systemc>
using namespace sc_core;

struct Testbench : public sc_module
{
	// Ports
	sc_in <bool> clk;
	sc_in <int > y;
	sc_out<bool> reset;
	sc_out<int > x;

	// Processes
	void genSignals();

	// Constructor
	SC_HAS_PROCESS(Testbench);
	Testbench(sc_module_name);
};

#endif
