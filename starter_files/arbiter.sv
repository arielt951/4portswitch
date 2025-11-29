module arbiter #(
    parameter dst_size = 4
)(
    input  logic       clk,
    input  logic       rst_n,

    // Inputs: One-hot target masks from each port
    // port0_dst[1] = 1 means Port 0 wants to go to Output 1
    input  logic [dst_size-1:0] port0_dst, 
    input  logic [dst_size-1:0] port1_dst,
    input  logic [dst_size-1:0] port2_dst,
    input  logic [dst_size-1:0] port3_dst,

    // Outputs: 1 Grant bit per port (All-or-Nothing)
    // [0]=Port0 Grant, [1]=Port1 Grant...
    output logic [3:0] grant_bus, 

    // Outputs: Mux controls for the Output Ports
    output logic [1:0] mux_sel0,
    output logic [1:0] mux_sel1,
    output logic [1:0] mux_sel2,
    output logic [1:0] mux_sel3,

    output logic active0, active1, active2, active3
);

    // =========================================================================
    // 1. STATE: Priority Pointers (One for each Output Port)
    // =========================================================================
    // ptr0 stores the Input Port index that has highest priority for Output 0.
    logic [1:0] ptr0, ptr1, ptr2, ptr3;

    // Internal wires: Who 'won' the local arbitration for each output?
    // win_out0[3] = 1 means Port 3 was selected for Output 0
    logic [3:0] win_out0, win_out1, win_out2, win_out3;
    
    // Request vectors (Transposed inputs)
    logic [3:0] reqs_out0, reqs_out1, reqs_out2, reqs_out3;

    // =========================================================================
    // 2. HELPER FUNCTION: Round Robin Selection
    // =========================================================================
    function automatic logic [3:0] pick_winner(input logic [3:0] req_vec, input logic [1:0] ptr);
        logic [3:0] winner = 4'b0000;
        case (ptr)
            2'd0: begin // Priority 0 -> 1 -> 2 -> 3
                if      (req_vec[0]) winner[0] = 1'b1;
                else if (req_vec[1]) winner[1] = 1'b1;
                else if (req_vec[2]) winner[2] = 1'b1;
                else if (req_vec[3]) winner[3] = 1'b1;
            end
            2'd1: begin // Priority 1 -> 2 -> 3 -> 0
                if      (req_vec[1]) winner[1] = 1'b1;
                else if (req_vec[2]) winner[2] = 1'b1;
                else if (req_vec[3]) winner[3] = 1'b1;
                else if (req_vec[0]) winner[0] = 1'b1;
            end
            2'd2: begin // Priority 2 -> 3 -> 0 -> 1
                if      (req_vec[2]) winner[2] = 1'b1;
                else if (req_vec[3]) winner[3] = 1'b1;
                else if (req_vec[0]) winner[0] = 1'b1;
                else if (req_vec[1]) winner[1] = 1'b1;
            end
            2'd3: begin // Priority 3 -> 0 -> 1 -> 2
                if      (req_vec[3]) winner[3] = 1'b1;
                else if (req_vec[0]) winner[0] = 1'b1;
                else if (req_vec[1]) winner[1] = 1'b1;
                else if (req_vec[2]) winner[2] = 1'b1;
            end
        endcase
        return winner;
    endfunction

    // =========================================================================
    // 3. COMBINATIONAL LOGIC: Determine Winners
    // =========================================================================
        // A. Transpose: Group requests by Output Port
    assign reqs_out0 = {port3_dst[0], port2_dst[0], port1_dst[0], port0_dst[0]};
    assign reqs_out1 = {port3_dst[1], port2_dst[1], port1_dst[1], port0_dst[1]};
    assign reqs_out2 = {port3_dst[2], port2_dst[2], port1_dst[2], port0_dst[2]};
    assign reqs_out3 = {port3_dst[3], port2_dst[3], port1_dst[3], port0_dst[3]};

    always @(*) begin
        // B. Pick Winner for each output independently
        win_out0 = pick_winner(reqs_out0, ptr0);
        win_out1 = pick_winner(reqs_out1, ptr1);
        win_out2 = pick_winner(reqs_out2, ptr2);
        win_out3 = pick_winner(reqs_out3, ptr3);

        active0 = |win_out0; // Reduction OR: returns 1 if any bit is 1
        active1 = |win_out1;
        active2 = |win_out2;
        active3 = |win_out3;

        // C. Encode Mux Selects (Map One-Hot to 2-bit Binary)
        mux_sel0 = (win_out0[1]) ? 2'd1 : (win_out0[2]) ? 2'd2 : (win_out0[3]) ? 2'd3 : 2'd0;
        mux_sel1 = (win_out1[1]) ? 2'd1 : (win_out1[2]) ? 2'd2 : (win_out1[3]) ? 2'd3 : 2'd0;
        mux_sel2 = (win_out2[1]) ? 2'd1 : (win_out2[2]) ? 2'd2 : (win_out2[3]) ? 2'd3 : 2'd0;
        mux_sel3 = (win_out3[1]) ? 2'd1 : (win_out3[2]) ? 2'd2 : (win_out3[3]) ? 2'd3 : 2'd0;
    end

    // =========================================================================
    // 4. COMBINATIONAL LOGIC: Grant Generation (All-or-Nothing)
    // =========================================================================
    // A Port gets a grant ONLY if it won ALL the outputs it asked for.
    // Logic: grant = (req_exists) AND ( (not_wanted_0 OR won_0) AND (not_wanted_1 OR won_1) ... )
    
    always @(*) begin
        // Port 0 Grant
        grant_bus[0] = (|port0_dst) &&
                       (!port0_dst[0] || win_out0[0]) &&
                       (!port0_dst[1] || win_out1[0]) &&
                       (!port0_dst[2] || win_out2[0]) &&
                       (!port0_dst[3] || win_out3[0]);

        // Port 1 Grant
        grant_bus[1] = (|port1_dst) &&
                       (!port1_dst[0] || win_out0[1]) &&
                       (!port1_dst[1] || win_out1[1]) &&
                       (!port1_dst[2] || win_out2[1]) &&
                       (!port1_dst[3] || win_out3[1]);

        // Port 2 Grant
        grant_bus[2] = (|port2_dst) &&
                       (!port2_dst[0] || win_out0[2]) &&
                       (!port2_dst[1] || win_out1[2]) &&
                       (!port2_dst[2] || win_out2[2]) &&
                       (!port2_dst[3] || win_out3[2]);

        // Port 3 Grant
        grant_bus[3] = (|port3_dst) &&
                       (!port3_dst[0] || win_out0[3]) &&
                       (!port3_dst[1] || win_out1[3]) &&
                       (!port3_dst[2] || win_out2[3]) &&
                       (!port3_dst[3] || win_out3[3]);
    end

    // =========================================================================
    // 5. SEQUENTIAL LOGIC: Update Pointers (Rotate Priority)
    // =========================================================================
    // We only rotate the pointer if the winner actually received the Grant.
    // If Port 0 won Output 1 but was denied the Grant (because it failed Output 2),
    // we do NOT rotate Output 1's pointer (Port 0 keeps priority for next retry).
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ptr0 <= 0; ptr1 <= 0; ptr2 <= 0; ptr3 <= 0;
        end else begin
            // Rotate Output 0 Pointer if winner used it
            if (win_out0[0] && grant_bus[0]) ptr0 <= 2'd1;
            if (win_out0[1] && grant_bus[1]) ptr0 <= 2'd2;
            if (win_out0[2] && grant_bus[2]) ptr0 <= 2'd3;
            if (win_out0[3] && grant_bus[3]) ptr0 <= 2'd0;

            // Rotate Output 1 Pointer
            if (win_out1[0] && grant_bus[0]) ptr1 <= 2'd1;
            if (win_out1[1] && grant_bus[1]) ptr1 <= 2'd2;
            if (win_out1[2] && grant_bus[2]) ptr1 <= 2'd3;
            if (win_out1[3] && grant_bus[3]) ptr1 <= 2'd0;

            // Rotate Output 2 Pointer
            if (win_out2[0] && grant_bus[0]) ptr2 <= 2'd1;
            if (win_out2[1] && grant_bus[1]) ptr2 <= 2'd2;
            if (win_out2[2] && grant_bus[2]) ptr2 <= 2'd3;
            if (win_out2[3] && grant_bus[3]) ptr2 <= 2'd0;

            // Rotate Output 3 Pointer
            if (win_out3[0] && grant_bus[0]) ptr3 <= 2'd1;
            if (win_out3[1] && grant_bus[1]) ptr3 <= 2'd2;
            if (win_out3[2] && grant_bus[2]) ptr3 <= 2'd3;
            if (win_out3[3] && grant_bus[3]) ptr3 <= 2'd0;
        end
    end

endmodule