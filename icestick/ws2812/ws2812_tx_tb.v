// Compile with: iverilog -o ws2812_tx_tb.vvp ws2812_tx_tb.v ws2812_tx.v
// Run with: vvp ws2812_tx_tb.vvp
// GTKWave: gtkwave ws2812_tx.vcd

`default_nettype none
`timescale 1ns / 1ps

module ws2812_tx_tb;
	`define T_CLK 20.833

	reg  reset, clock, start;
	wire busy;
	reg  [23:0] data = 24'haaaaaa;

	initial begin
		reset <= 1'b1;
		clock <= 1'b0;
		start <= 1'b0;
	end

	initial begin
		$dumpfile("ws2812_tx.vcd");
		$dumpvars(0, uut);

		@(negedge clock);
		reset = 0;
		@(negedge clock);
		reset = 1;
		start = 1;
		@(negedge clock);
		start = 0;
		wait (busy == 1'b0);

		$finish;
	end

	// Clock period: 1/48 MHz = 20.833 ns
	always #(20.833/2) clock = ~clock;

	ws2812_tx uut (
		.clk(clock),
		.rst(reset),
		.start(start),
		.data(data),
		.bsy(busy)
	);
endmodule
