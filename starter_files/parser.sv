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
        end else begin
            pkt_type  = ERR;
            pkt_valid = 1'b0;
        end
    end

endmodule