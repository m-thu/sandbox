#include "toplevel.hpp"
#include "lowpass_tb.hpp"

int sc_main(int argc, char *argv[])
{
	(void)argc;
	(void)argv;

	Toplevel top("top");

	// Create VCD file
	sc_trace_file *fp;
	fp = sc_create_vcd_trace_file("lowpass");
	sc_trace(fp, top.tb.clk, "clk");
	sc_trace(fp, top.tb.reset, "rst");
	sc_trace(fp, top.tb.x, "x");
	sc_trace(fp, top.tb.y, "y");

	// Run simulation (250 ns)
	sc_start(250, SC_NS);

	// Close VCD file
	sc_close_vcd_trace_file(fp);

	return 0;
}
