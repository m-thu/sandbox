module top (
	(* LOC = "P3" *) output y
);

	// LF oscillator (~ 1.73 kHz)
	GP_LFOSC #(
		.PWRDN_EN(0),
		.AUTO_PWRDN(0),
		.OUT_DIV(1)	// 1,2,4,16
	) lfosc (
		.PWRDN(1'b0),
		.CLKOUT(y)
	);	

endmodule
