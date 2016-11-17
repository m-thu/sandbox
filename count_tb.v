// count_tb.v
//
// Compile with: iverilog -o count_tb.vvp count_tb.v count.v
// Run with: vvp count_tb.vvp
// GTKWave: gtkwave count.vcd

`timescale 1 ns / 1 ps

module count_tb();
	localparam COUNTER_BITS = 3;

	reg reset;
	reg clock = 0;
	wire[COUNTER_BITS-1:0] counter;

	initial begin
		$display("initial time value: %d", $time);
		$dumpfile("count.vcd");
		$dumpvars(0, c);
		$monitor("reset: %b\tclock: %b\tcounter: %b",
		         reset, clock, counter);

		// pulse reset
		reset = 0;
		#1;
		reset = 1;
		#1;
		reset = 0;

		#24;
		$finish;
	end

	always #1 clock = ~clock;

	count #(
                .COUNTER_WIDTH(COUNTER_BITS))
	c (
		.rst(reset),
		.clk(clock),
		.cnt(counter)
	);
endmodule
