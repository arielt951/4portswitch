class packet_vc extends component_base;

	// 1. Components
	agent agt;

	// 2. Constructor
	function new(string name, component_base parent = null);
		super.new(name, parent);
		// Build the agent hierarchy
		agt = new("agent", this);
	endfunction

	// 3. Configuration Method
	// The testbench calls this to pass the physical interface and ID
	function void configure(virtual port_if vif, int port_id);
		// Pass the configuration down to the Agent
		agt.configure(vif, port_id);
	endfunction

	// 4. Run Task
	// The testbench calls this to start simulation
	task run(int num_packets);
		// Start the Agent's run process
		agt.run(num_packets);
	endtask

endclass