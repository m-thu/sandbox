// Lint with: verilator --lint-only ledstring.v

`default_nettype none
`timescale 1ns / 1ps

module ledstring #(
	// Clock frequency / Hz
	parameter F_CLK = 48e6,
	// Number of LEDs - 1
	parameter N = 7
)(
	input  clk, rst,
	output dout
);
	// T_reset: > 50 us
	localparam T_WAIT = 250e-3;
	//localparam T_WAIT = 1e-6; // for testbench
	localparam N_WAIT = $ceil(T_WAIT * F_CLK);
	// Counter width for delay
	localparam CNT = $clog2($rtoi($ceil(T_WAIT * F_CLK)));

	// FSM states
	localparam WAIT      = 4'b0001,
	           LOAD_DATA = 4'b0010,
		   START     = 4'b0100,
		   BUSY      = 4'b1000;

	reg [3:0]             state, next_state;
	reg [$clog2(N+1)-1:0] led, next_led;
	reg [$clog2(N+1)-1:0] n, next_n;
	reg [CNT-1:0]         cnt, next_cnt;

	wire       busy;
	reg        start;
	reg [23:0] data;

	ws2812_tx #(
		.F_CLK(F_CLK)
	) ws2812 (
		.clk(clk),
		.rst(rst),
		.start(start),
		.bsy(busy),
		.dout(dout),
		.data(data)
	);

	// State register
	always @(posedge clk, negedge rst) begin
		if (!rst) begin
			state <= WAIT;
			cnt   <= 0;
			led   <= N;
		end
		else begin
			state <= next_state;
			cnt   <= next_cnt;
			n     <= next_n;
			led   <= next_led;
		end
	end

	// Next state logic
	always @* begin
		// Defaults
		next_state = state;
		next_cnt   = cnt;
		next_n     = n;
		next_led   = led;
		start      = 1'b0;

		/* verilator lint_off CASEINCOMPLETE */
		case (state)
		WAIT: begin
			if (cnt < N_WAIT)
				next_cnt = cnt + 1'b1;
			else begin
				// Reset counter
				next_cnt = 0;
				// Reset LED counter
				next_n = 0;
				// Light up next LED in the string
				if (led == N)
					next_led = 0;
				else
					next_led = led + 1'b1;
				// Refresh all LEDs in the string
				next_state = LOAD_DATA;
			end
		end

		LOAD_DATA: begin
			if (n == led)
				data = 24'h005500;
			else
				data = 24'h000000;
			// Start transmission
			start = 1'b1;
			next_state = START;
		end

		START: begin
			start = 1'b1;
			next_state = BUSY;
		end

		BUSY: begin
			start = 1'b0;

			if (busy == 1'b0) begin
				// Last LED in string?
				if (n == N)
					next_state = WAIT;
				else begin
					next_n = n + 1'b1;
					next_state = LOAD_DATA;
				end
			end
		end
		endcase
		/* verilator lint_on CASEINCOMPLETE */
	end
endmodule
