// Lint with: verilator --lint-only ws2812_tx.v

`default_nettype none
`timescale 1ns / 1ps

module ws2812_tx #(
	// Clock frequency / Hz
	parameter F_CLK = 48e6
)(
	input  [23:0] data,
	input         clk, rst, start,
	output reg    dout,
	output wire   bsy
);
	// FSM states
	localparam IDLE = 5'b00001,
	           T0H  = 5'b00010,
	           T0L  = 5'b00100,
	           T1H  = 5'b01000,
	           T1L  = 5'b10000;

	localparam
	           // Bit 0, high time
	           T_T0H = 350e-9, // s
	           // Bit 0, low time
	           T_T0L = 800e-9, // s
	           // Bit 1, high time
	           T_T1H = 700e-9, // s
	           // Bit 1, low time
	           T_T1L = 600e-9; // S

	localparam
	           // Bit 0, cycles high time
	           N_T0H = $ceil(T_T0H * F_CLK),
	           // Bit 0, cycles low time
	           N_T0L = $ceil(T_T0L * F_CLK),
	           // Bit 1, cycles high time
	           N_T1H = $ceil(T_T1H * F_CLK),
	           // Bit 1, cycles low time
	           N_T1L = $ceil(T_T1L * F_CLK);

	// Counter width for delay
	localparam CNT = $clog2($rtoi($ceil(T_T0L * F_CLK)));

	reg [4:0]     state, next_state;
	reg [4:0]     n, next_n;
	reg [CNT-1:0] cnt, next_cnt;

	// State register
	always @(posedge clk, negedge rst) begin
		if (!rst)
			state <= IDLE;
		else begin
			state <= next_state;
			n     <= next_n;
			cnt   <= next_cnt;
		end
	end

	// Next state logic
	always @* begin
		// Defaults
		next_state = state;
		next_n     = n;
		next_cnt   = cnt;
		dout       = 1'b0;

		/* verilator lint_off CASEINCOMPLETE */
		case (state)
		IDLE: begin
			// Begin transmission when start signal gets asserted
			if (start)
				// MSB is transmitted first
				if (data[23] == 1'b1)
					next_state = T1H;
				else
					next_state = T0H;
			next_n   = 5'd23;
			next_cnt = 0;
			dout     = 1'b0;
		end

		T0H: begin
			if (cnt < N_T0H)
				next_cnt = cnt + 1'b1;
			else begin
				// Reset counter
				next_cnt   = 0;
				next_state = T0L;
			end

			dout = 1'b1;
		end

		T0L: begin
			if (cnt < N_T0L)
				next_cnt = cnt + 1'b1;
			else begin
				// Reset counter
				next_cnt = 0;

				// Jump to idle state if this was the last bit
				if (n == 0)
					next_state = IDLE;
				else begin
					// Determine if next bit is 1 or 0
					next_n = n - 1'b1;
					if (data[next_n] == 1'b1)
						next_state = T1H;
					else
						next_state = T0H;
				end

			end

			dout = 1'b0;
		end

		T1H: begin
			if (cnt < N_T1H)
				next_cnt = cnt + 1'b1;
			else begin
				// Reset counter
				next_cnt = 0;
				next_state = T1L;
			end

			dout = 1'b1;
		end

		T1L: begin
			if (cnt < N_T1L)
				next_cnt = cnt + 1'b1;
			else begin
				// Reset counter
				next_cnt = 0;

				// Jump to idle state if this was the last bit
				if (n == 0)
					next_state = IDLE;
				else begin
					// Determine if next bit is 1 or 0
					next_n = n - 1'b1;
					if (data[next_n] == 1'b1)
						next_state = T1H;
					else
						next_state = T0H;
				end
			end

			dout = 1'b0;
		end
		endcase
		/* verilator lint_on CASEINCOMPLETE */
	end

	assign bsy = !(state == IDLE);
endmodule
