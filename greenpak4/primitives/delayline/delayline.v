module top (
	(* LOC = "P3" *) output wire x,
	(* LOC = "P4" *) output wire y
);

	// LF Oscillator (~ 1.73 kHz)
	GP_LFOSC #(
		.PWRDN_EN(0),
		.AUTO_PWRDN(0),
		.OUT_DIV(16)	// 1,2,4,16
	) lfosc (
		.PWRDN(1'b0),
		.CLKOUT(x)
	);

	// Delay line (~ 4*165 ns = 660 ns)
	GP_DELAY #(
		.DELAY_STEPS(4),
		.GLITCH_FILTER(0)
	) delayline (
		.IN(x),
		.OUT(y)
	);

endmodule
