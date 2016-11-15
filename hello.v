// hello.v
//
// Compile with: iverilog -o hello.vvp hello.v
// Run with: vvp hello.vvp
// Lint: verilator --lint-only hello.v

module hello();
	initial begin
		$display("Hello world!");
		$finish;
	end
endmodule
