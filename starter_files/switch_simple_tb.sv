module switch_simple_tb;
import packet_pkg::*;

// 1. Signals
logic clk;
logic rst_n;

// 2. Interfaces (instantiate 4 ports)
port_if port0(clk, rst_n);
port_if port1(clk, rst_n);
port_if port2(clk, rst_n);
port_if port3(clk, rst_n);

// 3. DUT Instantiation
switch_4port dut (
	.clk(clk),
	.rst_n(rst_n),
	.port0(port0),
	.port1(port1),
	.port2(port2),
	.port3(port3)
);

// 4. Clock Generation
initial begin
	clk = 0;
	forever #5 clk = ~clk; // 10ns period
end

// 5. Test Stimulus
initial begin
	// A. Initialization
	rst_n = 0;
	port0.valid_in = 0; port1.valid_in = 0; port2.valid_in = 0; port3.valid_in = 0;
	port0.data_in = 0;  port1.data_in = 0;  port2.data_in = 0;  port3.data_in = 0;
	
	$display("--- Starting Simulation ---");
	
	// B. Reset
	repeat(5) @(posedge clk);
	rst_n = 1;
	@(posedge clk);

	// C. Drive a Packet on Port 0 -> Destined for Port 1
	// Packet format: {Target(4), Source(4), Data(8)}
	// Source=Port0 (0001), Target=Port1 (0010), Data=0xAA
	$display("Time %0t: Driving Packet on Port 0 -> Port 1", $time);
	
	port0.valid_in = 1;
	port0.source_in = 4'b0001; // Source: Port 0
	port0.target_in = 4'b0010; // Target: Port 1
	port0.data_in   = 8'hAA;   // Payload
	
	@(posedge clk);
	port0.valid_in = 0; // Pulse valid for 1 cycle (Single Packet)

	// D. Wait and Observe
	repeat(20) @(posedge clk);
	
	$display("--- Simulation Finished ---");
	$finish;
end

// 6. Simple Monitor
always @(posedge clk) begin
	if (port1.valid_out) begin
		$display("SUCCESS: Time %0t: Packet Received at Port 1! Data=%h", $time, port1.data_out);
	end
	// Check for ghost packets on other ports
	if (port2.valid_out) $display("Time %0t: Packet at Port 2 (Unexpected?)", $time);
	if (port3.valid_out) $display("Time %0t: Packet at Port 3 (Unexpected?)", $time);
end

endmodule