class driver extends component_base;
	mailbox #(packet) mbx;
	virtual port_if vif;
	int port_id;

	function new(string name, component_base parent);
		super.new(name, parent);
	endfunction

	function void configure(virtual port_if vif, int port_id);
		this.vif = vif;
		this.port_id = port_id;
	endfunction

	task run(int num_packets);
		packet pkt;
		repeat(num_packets) begin
			// 1. Get packet from sequencer
			mbx.get(pkt);
			
			// 2. Print/Log
			pkt.print($sformatf("Driver_%0d", port_id));
			
			// 3. Drive to DUT (using interface task)
			vif.drive_packet(pkt);
		end
	endtask
endclass