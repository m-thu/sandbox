// Compile with: iverilog -o ledstring_tb.vvp ledstring_tb.v ledstring.v ws2812_tx.v
// Run with: vvp ledstring_tb.vvp
// GTKWave: gtkwave ledstring.vcd

`default_nettype none
`timescale 1ns / 1ps

module ledstring_tb;
	reg  reset, clock;
	wire dout;

	initial begin
		reset <= 1'b1;
		clock <= 1'b0;
	end

	initial begin
		$dumpfile("ledstring.vcd");
		$dumpvars(0, uut);

		@(negedge clock);
		reset = 0;
		@(negedge clock);
		reset = 1;
		repeat (20000) @(posedge clock);

		$finish;
	end

	// Clock period: 1/48 MHz = 20.833 ns
	always #(20.833/2) clock = ~clock;

	ledstring uut (
		.clk(clock),
		.rst(reset),
		.dout(dout)
	);
endmodule
