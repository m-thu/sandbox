#include <iostream>
#include <systemc>
#include "sender.hpp"
#include "receiver.hpp"

using namespace std;
using namespace sc_core;

int sc_main(int argc, char *argv[])
{
	(void)argc;
	(void)argv;

	// Modules
	Sender   s("s");
	Receiver r("r");

	// Channels
	sc_clock      clock("clock", 10, SC_NS);
	sc_fifo<char> fifo ("fifo", 10);

	// Connect modules
	s.clock(clock);
	s.out  (fifo );
	r.clock(clock);
	r.in   (fifo );

	// Create VCD file
	sc_trace_file *fp;
	fp = sc_create_vcd_trace_file("main");
	sc_trace(fp, s.clock, "clock");
	sc_trace(fp, r.c, "c");

	// Run simulation
	sc_start(400, SC_NS);
	cout << endl;

	// Close VCD file
	sc_close_vcd_trace_file(fp);

	return 0;
}
