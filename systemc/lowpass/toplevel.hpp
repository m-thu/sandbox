#ifndef TOPLEVEL_HPP
#define TOPLEVEL_HPP

#include "lowpass_tb.hpp"
#include "lowpass.hpp"
#include <systemc>

using namespace sc_core;

struct Toplevel : public sc_module
{
	// Modules
	Testbench tb;
	Lowpass   lp;

	// Constructor
	Toplevel(sc_module_name);

private:
	sc_clock        clock;
	sc_signal<int > signal_x, signal_y;
	sc_signal<bool> signal_reset;
};

#endif
