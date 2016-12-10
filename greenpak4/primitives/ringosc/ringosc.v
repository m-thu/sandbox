module top (
	(* LOC="P3" *) output y
);

	GP_RINGOSC #(
		.AUTO_PWRDN(0)
	) ringosc (
		.CLKOUT_FABRIC(y)
	);

endmodule
