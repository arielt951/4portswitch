class agent extends component_base;
	
	// Components
	sequencer seq;
	driver    drv;
	monitor   mon;
	
	// Mailbox to connect Sequencer -> Driver
	mailbox #(packet) mbx;

	function new(string name, component_base parent);
		super.new(name, parent);
		seq = new("sequencer", this);
		drv = new("driver", this);
		mon = new("monitor", this);
		mbx = new(); // Unbounded mailbox
	endfunction

	function void configure(virtual port_if vif, int port_id);
		// Pass config to children
		seq.configure(port_id);
		drv.configure(vif, port_id);
		mon.configure(vif, port_id);
		
		// Connect the mailbox
		seq.mbx = this.mbx;
		drv.mbx = this.mbx;
	endfunction

	task run(int num_packets);
		// Start the Monitor in the background (it runs forever)
		fork
			mon.run();
		join_none

		// Start Sequencer and Driver in parallel and WAIT for them to finish
		fork
			seq.run(num_packets);
			drv.run(num_packets);
		join
		
		// When driver finishes, we return, allowing the testbench to proceed.
	endtask

endclass