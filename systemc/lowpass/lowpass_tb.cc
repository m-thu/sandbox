#include "lowpass_tb.hpp"
#include <iostream>

using namespace std;

Testbench::Testbench(sc_module_name name)
{
	(void)name;

	SC_THREAD(genSignals);
	sensitive << clk.neg();
}

void Testbench::genSignals()
{
	// Pulse reset
	reset.write(true);
	x.write(0);
	wait();
	reset.write(false);

	// Ramp up input
	for (int i = 0; i <= 5; ++i) {
		x.write(i*10);
		wait();
	}
	
	// Keep input constant
	for (int i = 0; i < 5; ++i)
		wait();

	// Ramp down input
	for (int i = 5; i >= 0; --i) {
		x.write(i*10);
		wait();
	}
}
