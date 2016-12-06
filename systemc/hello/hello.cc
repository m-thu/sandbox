#include "systemc.h"

SC_MODULE (hello_world)
{
	SC_CTOR (hello_world)
	{
	}

	void hello()
	{
		cout << "Hello world!" << endl;
	}
};

int sc_main(int argc, char *argv[])
{
	(void)argc; (void)argv;

	hello_world hello("HELLO");
	hello.hello();

	return 0;
}
