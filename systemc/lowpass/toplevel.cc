#include "toplevel.hpp"

Toplevel::Toplevel(sc_module_name name) :
	tb("tb"),
	lp("lp"),
	clock("clock", 10, SC_NS)
{
	(void)name;

	tb.clk  (clock       );
	tb.x    (signal_x    );
	tb.y    (signal_y    );
	tb.reset(signal_reset);

	lp.clk  (clock       );
	lp.x    (signal_x    );
	lp.y    (signal_y    );
	lp.reset(signal_reset);
}
