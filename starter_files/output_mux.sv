module output_mux (
    input logic [1:0]  mux_sel,
    input logic [15:0] data_in0,
    input logic [15:0] data_in1,
    input logic [15:0] data_in2,
    input logic [15:0] data_in3,
    input logic arb_active,
    output logic [15:0] data_out,
    output logic valid_out        
);
    // 4:1 MUX to select data output based on arbiter mux_select
    always_comb begin
        data_out     = '0; 
        valid_out    = 1'b0; // Default 0

        // Only open the gate if the Arbiter says we have a winner
        if (arb_active) begin
            case (mux_sel)
                    2'b00: begin 
                    data_out  = data_in0;
                    valid_out = 1'b1; 
                end
                    2'b01: begin 
                    data_out  = data_in1;
                    valid_out = 1'b1; 
                end
                    2'b10: begin 
                    data_out  = data_in2;
                    valid_out = 1'b1; 
                end
                    2'b11: begin 
                    data_out  = data_in3;
                    valid_out = 1'b1; 
                end
            endcase
        end else begin
            data_out  = 16'b0;
            valid_out = 1'b0; 
    end
    end
endmodule