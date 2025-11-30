package packet_pkg;
	// -----------------------------------------------------------
	// 1. GLOBAL CONSTANTS
	// -----------------------------------------------------------
	parameter int DATA_WIDTH = 16;
	parameter int ADDR_WIDTH = 4;
	parameter int DEPTH      = 8;

	// -----------------------------------------------------------
	// 2. ENUMS
	// -----------------------------------------------------------
	typedef enum logic [1:0] {IDLE, ROUTE, ARB_WAIT, TRANSMIT} state_t;
	typedef enum logic [1:0] {ERR, SDP, MDP, BDP} p_type;

	// -----------------------------------------------------------
	// 3. PACKET CLASS
	// -----------------------------------------------------------
	class packet;
		rand logic [3:0] source;
		rand logic [3:0] target;
		rand logic [7:0] data;
		
		// Internal variables
		string name;
		p_type pkt_type; // Derived type

		function new(string name = "packet_obj");
			this.name = name;
			this.pkt_type = ERR; // Default
		endfunction

		// --- NEW: Print Method (Required by Driver/Monitor) ---
		function void print(string tag = "");
			$display("[%s] %s: Src=%b Tgt=%b Data=%h Type=%s", 
					 tag, name, source, target, data, pkt_type.name());
		endfunction

		// --- NEW: Calculate Type Method (Required by Monitor) ---
		function void calc_type();
			int ones;
			ones = $countones(target);
			if (ones == 1)      pkt_type = SDP;
			else if (ones > 1 && ones < 4) pkt_type = MDP;
			else if (ones == 4) pkt_type = BDP;
			else                pkt_type = ERR;
		endfunction

	endclass

	// -----------------------------------------------------------
	// 4. INCLUDES
	// -----------------------------------------------------------
//	`include "component_base.sv"
//	`include "sequencer.sv"
//	`include "driver.sv"
//	`include "monitor.sv"
//	`include "agent.sv"
//	`include "packet_vc.sv"
//	`include "checker.sv"

endpackage