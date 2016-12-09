#ifndef SENDER_HPP
#define SENDER_HPP

#include <systemc>
using namespace sc_core;

struct Sender : public sc_module
{
	sc_in  <bool>                  clock;
	sc_port<sc_fifo_out_if<char> > out;

	// Constructor
	SC_HAS_PROCESS(Sender);
	Sender(sc_module_name name)
	{
		(void)name;

		SC_THREAD(send);
		sensitive << clock.pos();
	}

	// Sender thread
	void send()
	{
		const char *DATA = "Hello world!";

		// Send data on every second rising edge
		do {
			wait(2);
			out->write(*DATA);
		} while (*++DATA);
	}
};

#endif
