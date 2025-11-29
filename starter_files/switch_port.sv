`include "FIFO.sv"
`include "parser.sv"


// IDLE - 00 , ROUTE - 01 , ARB_WAIT - 10 , TRANSMIT - 11
typedef enum logic [1:0] {IDLE, ROUTE, ARB_WAIT, TRANSMIT} state;
// Packet Type Encoding ERR - 00 , SDP - 01 , MDP - 10 , BDP - 11
typedef enum logic [1:0] {ERR, SDP, MDP, BDP} p_type;


module switch_port (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        valid_in,
  input  logic [3:0]  source_in,
  input  logic [3:0]  target_in,
  input  logic [7:0]  data_in,
  input  logic        grant,
  //4:1 mux interface  
  output logic [3:0] pkt_dst, //to arbiter
  output logic [3:0]  source_out,
  output logic [3:0]  target_out,
  output logic [7:0]  data_out
); 
logic fifo_full;
logic fifo_empty;
logic [15:0] fifo_data_out;
logic [7:0] header_out;

// State Encoding
state current_state, next_state;
p_type Packet_Type;
// Internal signals for Parser connection
p_type pkt_type;
logic  pkt_valid;
// internal control wire which connects between the fifo, arbiter and FSM
logic fifo_pop;
    
// Parser Instantiation
parser parser_inst (
    //inputs
    .source    (header_out[7:4]), 
    .target    (header_out[3:0]), 
    //outputs
    .pkt_type  (pkt_type),
    .pkt_valid (pkt_valid)
);
assign pkt_dst = header_out[3:0]; //target for arbiter

assign fifo_pop = grant; // grant from arbiter enables read
assign fifo_data_out = {data_out, target_out, source_out};
//fifo instance
fifo #(.PKT_SIZE(16),.DEPTH(8)) port_fifo (
  //inputs
    .rst_n      (rst_n),
    .clk        (clk),
    .data_in    ({data_in, target_in, source_in}),
    .wr_en      (valid_in),
    .rd_en      (fifo_pop), // grant from arbiter enables read
    //outputs
    .data_out   (fifo_data_out),
    .fifo_full  (fifo_full),
    .header_out (header_out), // for parser
    .fifo_empty (fifo_empty)
);


// Implement FSM for packet flow
// -----------------------------------------------------------
// FSM LOGIC
// -----------------------------------------------------------
// 1. Sequential Logic: State Updates
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
        Packet_Type   <= ERR; // Reset packet type
    end else begin
        current_state <= next_state;
        // Latch Packet_Type only when we decide the packet is valid in ROUTE state
        if (current_state == ROUTE && pkt_valid) begin
            Packet_Type <= pkt_type;
        end
    end
end

// 2. Combinational Logic: Next State & Outputs
always_comb begin
    // Default assignments to prevent latches
    next_state      = current_state;
    valid_out       = 1'b0; // Don't output data unless transmitting
    fifo_pop        = 1'b0;
    
    case (current_state)
        
        // -----------------------------------------------------------------
        // STATE: IDLE
        // Wait for data to arrive in FIFO
        // -----------------------------------------------------------------
        IDLE: begin
            if (!fifo_empty) begin
                next_state = ROUTE;
            end else begin
                next_state = IDLE;
            end
        end

        // -----------------------------------------------------------------
        // STATE: ROUTE
        // Check Parser output. If valid -> Wait for Grant. If Bad -> Drop.
        // -----------------------------------------------------------------
        ROUTE: begin
            if (pkt_valid) begin
                // Valid packet: Move to Arbitration Wait
                next_state = ARB_WAIT; 
            end else begin
                // Invalid packet: Drop it!
                fifo_pop = 1'b1;
                next_state = IDLE;
            end
        end

        // -----------------------------------------------------------------
        // STATE: ARB_WAIT
        // Wait for external arbiter to grant permission
        // -----------------------------------------------------------------
        ARB_WAIT: begin
            // In Stage A (QA), you might force 'grant' to 1 in your testbench.
            if (grant) begin
                next_state = TRANSMIT;
            end
            else begin
                next_state = ARB_WAIT;
        end
        end
        // -----------------------------------------------------------------
        // STATE: TRANSMIT
        // Drive data out and pop FIFO
        // -----------------------------------------------------------------
        TRANSMIT: begin
            fifo_pop = grant; // Pop the packet from FIFO
            next_state = IDLE;      // Return to IDLE
        end 

        default: next_state = IDLE;
    endcase
end
// Handle clock/reset
// Implement routing logic
// Add completion logic

endmodule

