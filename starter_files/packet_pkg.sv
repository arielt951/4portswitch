package packet_pkg;
//switch definitions
`define DATA_WIDTH 16
`define ADDR_WIDTH 4
`define DEPTH 8

// IDLE - 00 , ROUTE - 01 , ARB_WAIT - 10 , TRANSMIT - 11
typedef enum logic [1:0] {IDLE, ROUTE, ARB_WAIT, TRANSMIT} state;
// Packet Type Encoding ERR - 00 , SDP - 01 , MDP - 10 , BDP - 11
typedef enum logic [1:0] {ERR, SDP, MDP, BDP} p_type;


    // --- Packet Class (For Verification/Testbench Only) ---
    // This matches the usage in port_if.sv
    class packet;
        rand logic [3:0] source;
        rand logic [3:0] target;
        rand logic [7:0] data;
        string name;

        // Constructor required because port_if calls new("monitored")
        function new(string name = "packet_obj");
            this.name = name;
        endfunction
    endclass

  //`include "packet_data.sv"
  //`include "component_base.sv"
  //`include "sequencer.sv"
  //`include "driver.sv"
  //`include "monitor.sv"
  //`include "agent.sv"
  //`include "packet_vc.sv"
  //`include "checker.sv"
endpackage
