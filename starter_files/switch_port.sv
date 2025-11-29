

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
p_type parser_pkt_type;
logic  parser_valid;
// internal control wire which connects between the fifo, arbiter and FSM
logic fifo_pop;
    
// Wires to unpack the FIFO output
logic [3:0] fifo_source;
logic [3:0] fifo_target;
logic [7:0] fifo_payload;

// Unpack the FIFO data based on your write order: {source, target, data}
assign fifo_source  = fifo_data_out[3:0];
assign fifo_target  = fifo_data_out[7:4];
assign fifo_payload = fifo_data_out[15:8];

// -----------------------------------------------------------
// Parser Instantiation
// -----------------------------------------------------------
parser parser_inst (
    .source    (fifo_source),
    .target    (fifo_target),
    .pkt_type  (parser_pkt_type),
    .pkt_valid (parser_valid)
);




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
        if (current_state == ROUTE && parser_valid) begin
            Packet_Type <= parser_pkt_type;
        end
    end
end

// 2. Combinational Logic: Next State & Outputs
always_comb begin
    // Default assignments to prevent latches
    next_state  = current_state;
    port_fifo.rd_en = 1'b0; // Don't read from FIFO unless specified
    valid_out       = 1'b0; // Don't output data unless transmitting
    fifo_pop = 1'b0;
    
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
            if (parser_valid) begin
                // Valid packet: Move to Arbitration Wait
                next_state = ARB_WAIT; 
            end else begin
                // Invalid packet: Drop it!
                // We assert rd_en to 'pop' the bad data out of FIFO
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

module parser (
    input  logic [3:0] source,
    input  logic [3:0] target,
    
    output p_type      pkt_type,
    output logic       pkt_valid
);

    always_comb begin
        // 1. Default assignments
        pkt_type  = ERR;
        pkt_valid = 1'b0;

        // 2. Check Source Validity (Must be One-Hot)
        if ($countones(source) == 1 && target != 4'b0000) begin
            
            // 3. Classify Packet Type based on bit count
            case ($countones(target))
                1:       pkt_type = SDP; // Single
                2, 3:    pkt_type = MDP; // Multicast
                4:       pkt_type = BDP; // Broadcast
                default: pkt_type = ERR;
            endcase

            // 4. Validate Logic (The Fix)
            // Valid if: (No Overlap) OR (It is Broadcast)
            if ( ((target & source) == 0) || (pkt_type == BDP) ) begin
                // Ensure the classification didn't result in ERR
                if (pkt_type != ERR) begin
                    pkt_valid = 1'b1;
                end
            end
        end
    end

endmodule
