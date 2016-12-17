module top (
	input wire clk,
	output wire led1,led2,led3,led4,led5
);

	reg [23:0] counter = 0;

	assign led1 = counter[23];
	assign {led2,led3,led4,led5} = 4'b0000;

	always @(posedge clk)
		counter <= counter + 24'b1;

endmodule
