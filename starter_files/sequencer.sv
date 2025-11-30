class sequencer extends component_base;
	mailbox #(packet) mbx;
	int port_id;

	function new(string name, component_base parent);
		super.new(name, parent);
	endfunction

	function void configure(int port_id);
		this.port_id = port_id;
	endfunction

	task run(int num_packets);
		packet pkt;
		repeat(num_packets) begin
			pkt = new("pkt");
			// Basic Randomization
			if (!pkt.randomize()) $error("Randomization failed");
			
			// Force source to match this port (Critical for valid simulation)
			pkt.source = (1 << port_id); 
			
			// Send to driver
			mbx.put(pkt);
		end
	endtask
endclass