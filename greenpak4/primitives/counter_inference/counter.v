module top (
	(* LOC = "P3" *) output wire clk,
	(* LOC = "P4" *) output wire y
);

	// LF Oscillator (~ 1.73 kHz)
	GP_LFOSC #(
		.PWRDN_EN(0),
		.AUTO_PWRDN(0),
		.OUT_DIV(1)	// 1,2,4,16
	) lfosc (
		.PWRDN(1'b0),
		.CLKOUT(clk)
	);

	localparam CNT_WIDTH = 2;
	reg[CNT_WIDTH-1:0] cnt = 2**CNT_WIDTH - 1;

	assign y = (cnt == 0);

	// Down counter, no reset
	always @(posedge clk) begin
		if (cnt == 0)
			cnt <= 2**CNT_WIDTH - 1;
		else
			cnt <= cnt - 1;
	end

endmodule
