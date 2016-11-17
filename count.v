// count.v
//
// Lint: verilator --lint-only count.v

module count #(
	parameter COUNTER_WIDTH = 4
) (
	input rst,
	input clk,
	output reg[COUNTER_WIDTH-1:0] cnt
);

	always @(posedge clk) begin
		if (rst)
			cnt <= 0;
		else
			cnt <= cnt + 1;
	end
endmodule
