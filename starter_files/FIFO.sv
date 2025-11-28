module fifo#(
    parameter PKT_SIZE = 16, // Source(4) + Target(4) + Data(8)
    parameter DEPTH    = 8   // Minimum depth to handle 4 concurrent inputs (PKTSIZE x 4)
)(
    input logic rst_n,
    input logic clk,
    //write logic
    input logic [PKT_SIZE - 1 : 0] data_in,
    input logic wr_en,
    output logic fifo_full,
    //inspect logic - for packet patser
    output logic [(PKT_SIZE >> 1) - 1 : 0] header_out,
    //read logic
    input logic rd_en,
    output logic [PKT_SIZE - 1 : 0] data_out,
    output logic fifo_empty
);

localparam PTR_BWIDTH = $clog2(DEPTH); // pointer bit width

//memory array
logic [PKT_SIZE - 1 : 0] mem [ DEPTH - 1 : 0];
//FIFO pointers
logic [PTR_BWIDTH -1 : 0] wr_ptr, rd_ptr;
logic [PTR_BWIDTH : 0] fifo_count;

//inspection logic for packet parser no matter of arbitration granted
assign header_out = (!fifo_empty) ? mem[rd_ptr][PKT_SIZE-1 : PKT_SIZE-8] : '0;

//FIFO LOGIC    
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
    wr_ptr     <=  '0;
    rd_ptr     <=  '0;
    fifo_count <=  '0;
    data_out   <=  '0;
 end else begin
    // wrting logic
    if (wr_en && !fifo_full) begin
        mem[wr_ptr] <= data_in;
        wr_ptr <= wr_ptr + 1'b1;
    end
    //reading logic
    if (rd_en && !fifo_empty) begin
        data_out <= mem[rd_ptr];
        rd_ptr <= rd_ptr + 1'b1;
    end
// Both Read and Write: Count stays the same
    if (wr_en && !fifo_full && rd_en && !fifo_empty) begin 
                fifo_count <= fifo_count; 
            end else if (wr_en && !fifo_full) begin
                // Write only: Increment
                fifo_count <= fifo_count + 1'b1;
            end else if (rd_en && !fifo_empty) begin
                // Read only: Decrement
                fifo_count <= fifo_count - 1'b1;
            end
 end
end

//inspection logic for packet parser on every clock cycle not matter of arbitration granted


assign fifo_full  = (fifo_count == DEPTH);
assign fifo_empty = (fifo_count == 0);

endmodule
