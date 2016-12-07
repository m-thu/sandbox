#include "lowpass.hpp"

Lowpass::Lowpass(sc_module_name name)
{
	(void)name;

	SC_METHOD(state);
	sensitive << clk << reset;

	SC_METHOD(transition);
	sensitive << x << x_1 << x_2 << x_3;
}

void Lowpass::state()
{
	if (reset.read()) {
		x_1.write(0);
		x_2.write(0);
		x_3.write(0);
		y.write  (0);
	} else if (clk.posedge()) {
		x_1.write(x.read()      );
		x_2.write(x_1.read()    );
		x_3.write(x_2.read()    );
		y.write  (average.read());
	}
}

void Lowpass::transition()
{
	average.write(
		(x.read()
		 + x_1.read()
		 + x_2.read()
		 + x_3.read()
		) / 4);
}
