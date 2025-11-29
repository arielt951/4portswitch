

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
  input  logic        grant,
  input  logic [7:0]  data_in,
  input  logic [15:0]  data_in0,
  input  logic [15:0]  data_in1,
  input  logic [15:0]  data_in2,
  input  logic [15:0]  data_in3,
  //4:1 mux interface
  input  logic [1:0] mux_select,
  
  output logic [3:0] pkt_dst, //to arbiter
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

state current_state, next_state;

p_type Packet_Type;


// Internal signals for Parser connection
p_type pkt_type;
logic  pkt_valid;
// internal control wire which connects between the fifo, arbiter and FSM
logic fifo_pop;
    
// -----------------------------------------------------------
// Parser Instantiation
parser parser_inst (
    //inputs
    .source    (header_out[7:4]), // Connect to FIFO header output
    .target    (header_out[3:0]), // Connect to FIFO header output
    //outputs
    .pkt_type  (pkt_type),
    .pkt_valid (pkt_valid)
);
assign pkt_dst = header_out[3:0]; //target for arbiter

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


// 4:1 MUX to select data output based on arbiter mux_select
always_comb begin
    case (mux_select)
        2'b00: begin // Select data from port 0
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
            valid_out = 1'b1;       // Signal that data_out is valid
            fifo_pop = 1'b1; // Pop the packet from FIFO
            next_state = IDLE;      // Return to IDLE
        end

        default: next_state = IDLE;
    endcase
end
// Handle clock/reset
// Implement routing logic
// Add completion logic

endmodule

