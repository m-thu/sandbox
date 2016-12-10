module top (
	(* LOC = "P3" *) output x
);

	GP_RCOSC #(
		.AUTO_PWRDN(0),
		.OSC_FREQ("2M"), // 2M, 25k
		.HARDIP_DIV(1),	 // 1,2,4,8
		.FABRIC_DIV(1),  // 1,2,3,4,8,12,24,64
		.PWRDN_EN(0)
	) rcosc (
		.PWRDN(1'b0),
		.CLKOUT_FABRIC(x)
	);

endmodule
