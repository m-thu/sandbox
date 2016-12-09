#ifndef RECEIVER_HPP
#define RECEIVER_HPP

#include <iostream>
#include <systemc>

using namespace std;
using namespace sc_core;

struct Receiver : public sc_module
{
	sc_in  <bool>                 clock;
	sc_port<sc_fifo_in_if<char> > in;

	char c;

	// Constructor
	SC_HAS_PROCESS(Receiver);
	Receiver(sc_module_name name)
	{
		(void)name;

		c = 'X';

		SC_THREAD(receive);
		sensitive << clock.pos();
	}

	// Receiver thread
	void receive()
	{
		for (;;) {
			wait();
			c = '*';
			// Non blocking read, doesn't overwrite c
			// if no data is available
			in->nb_read(c);

			cout << c;
		}
	}
};

#endif
