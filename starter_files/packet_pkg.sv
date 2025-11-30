package packet_pkg;
//switch definitions
`define DATA_WIDTH 16
`define ADDR_WIDTH 4
`define DEPTH 8

// IDLE - 00 , ROUTE - 01 , ARB_WAIT - 10 , TRANSMIT - 11
typedef enum logic [1:0] {IDLE, ROUTE, ARB_WAIT, TRANSMIT} state;
// Packet Type Encoding ERR - 00 , SDP - 01 , MDP - 10 , BDP - 11
typedef enum logic [1:0] {ERR, SDP, MDP, BDP} p_type;

  //`include "packet_data.sv"
  //`include "component_base.sv"
  //`include "sequencer.sv"
  //`include "driver.sv"
  //`include "monitor.sv"
  //`include "agent.sv"
  //`include "packet_vc.sv"
  //`include "checker.sv"
endpackage
