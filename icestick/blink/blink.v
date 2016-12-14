module top (
	input wire clk,
	output wire led1,
	output wire led2,
	output wire led3,
	output wire led4,
	output wire led5
);

	reg [23:0] counter = 0;

	assign led1 = counter[23];
	assign led2 = 1'b0;
	assign led3 = 1'b0;
	assign led4 = 1'b0;
	assign led5 = 1'b0;

	always @(posedge clk)
		counter <= counter + 1;

endmodule
