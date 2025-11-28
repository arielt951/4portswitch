module arbiter (
    input  logic clk,
    input  logic rst_n,
    input  logic [3:0] port0_dst,
    input  logic [3:0] port1_dst,
    input  logic [3:0] port2_dst,
    input  logic [3:0] port3_dst,
    output logic [3:0] grant_bus,
    output logic [1:0] mux_select0,
    output logic [1:0] mux_select1,
    output logic [1:0] mux_select2,       
    output logic [1:0] mux_select3       

  //TODO add arbiter logic
); 
endmodule