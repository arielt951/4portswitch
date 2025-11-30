class monitor extends component_base;
	virtual port_if vif;
	int port_id;

	function new(string name, component_base parent);
		super.new(name, parent);
	endfunction

	function void configure(virtual port_if vif, int port_id);
		this.vif = vif;
		this.port_id = port_id;
	endfunction

	task run();
		packet pkt;
		// Monitor runs forever; the testbench kills it via $finish
		forever begin
			vif.collect_packet(pkt);
			// Calculate type (Unicast/Broadcast) for debugging
			pkt.calc_type(); 
			pkt.print($sformatf("Monitor_%0d", port_id));
		end
	endtask
endclass