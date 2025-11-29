module switch_port (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        valid_in,
  input  logic [3:0]  source_in,
  input  logic [3:0]  target_in,
  input  logic        grant,
  input  logic [7:0]  data_in,
  input  logic [15:0]  data_in0,
  input  logic [15:0]  data_in1,
  input  logic [15:0]  data_in2,
  input  logic [15:0]  data_in3,
  //4:1 mux interface
  input  logic [1:0] mux_select,
  
  output logic        valid_out,
  output logic [3:0]  source_out,
  output logic [3:0]  target_out,
  output logic [7:0]  data_out
);
logic fifo_full;
logic fifo_empty;
logic [15:0] fifo_data_out;
logic [7:0] header_out;
logic [15:0] data_out_mux;

// State Encoding
// IDLE - 00 , ROUTE - 01 , ARB_WAIT - 10 , TRANSMIT - 11
typedef enum logic [1:0] {IDLE, ROUTE, ARB_WAIT, TRANSMIT} state;
state current_state, next_state;
// Packet Type Encoding ERR - 00 , SDP - 01 , MDP - 10 , BDP - 11
typedef enum logic [1:0] {ERR, SDP, MDP, BDP} p_type;
p_type Packet_Type;

module parser (
  //TODO add parser logic, reades header as input verify packet_type, drop invalid packets and output header (later integration to arbiter)
);
endmodule

//fifo instance
fifo #(.PKT_SIZE(16),.DEPTH(8)) port_fifo (
  //inputs
    .rst_n      (rst_n),
    .clk        (clk),
    .data_in    ({source_in, target_in, data_in}),
    .wr_en      (valid_in),
    .rd_en      (grant), // grant from arbiter enables read
    //outputs
    .data_out   (fifo_data_out),
    .fifo_full  (fifo_full),
    .header_out (header_out), // for parser
    .fifo_empty (fifo_empty)
);


// 4:1 MUX to select data output based on arbiter mux_select
always_comb begin
    case (mux_select)
        2'b00 begin // Select data from port 0
            data_out_mux = data_in0;
        end
        2'b01: begin // Select data from port 1
            data_out_mux = data_in1;
        end
        2'b10: begin // Select data from port 2
            data_out_mux = data_in2;
        end
        2'b11: begin // Select data from port 3
            data_out_mux = data_in3;
        end
        default: begin // Default value is low
            data_out_mux = '0;
        end
    endcase
end   



assign {source_out, target_out, data_out} = data_out_mux; 

// Implement FSM for packet flow
// Handle clock/reset
// Implement routing logic
// Add completion logic

endmodule
