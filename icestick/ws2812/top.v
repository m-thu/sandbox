`default_nettype none
`timescale 1ns / 1ps

module top (
	input  wire clk,
	output wire dout
);
	//$ icepll -o 48
	//
	//F_PLLIN:    12.000 MHz (given)
	//F_PLLOUT:   48.000 MHz (requested)
	//F_PLLOUT:   48.000 MHz (achieved)
	//
	//FEEDBACK: SIMPLE
	//F_PFD:   12.000 MHz
	//F_VCO:  768.000 MHz
	//
	//DIVR:  0 (4'b0000)
	//DIVF: 63 (7'b0111111)
	//DIVQ:  4 (3'b100)
	//
	//FILTER_RANGE: 1 (3'b001)

	wire lock, clkout;

	SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.PLLOUT_SELECT("GENCLK"),
		.DIVR(4'b0000),
		.DIVF(7'b0111111),
		.DIVQ(3'b100),
		.FILTER_RANGE(3'b001)
	) pll (
		.LOCK(lock),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clk),
		.PLLOUTCORE(clkout)
	);

	reg [3:0] cnt   = 4'hf;
	reg       reset = 1'b1;

	always @(posedge clk) begin
		if (lock)
			if (|cnt) begin
				cnt <= cnt - 1'b1;
				reset <= 1'b0;
			end
			else begin
				cnt <= 1'b0;
				reset <= 1'b1;
			end
	end

	ledstring leds (
		.clk(clkout),
		.rst(reset),
		.dout(dout)
	);
endmodule
