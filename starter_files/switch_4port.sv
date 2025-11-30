import packet_pkg::*;

module switch_4port (input logic clk, input logic rst_n,
  port_if port0, port_if port1, port_if port2, port_if port3);

  logic [ADDR_WIDTH - 1:0] grant;
  logic [$clog2(ADDR_WIDTH)-1:0] mux_sel0, mux_sel1, mux_sel2, mux_sel3;
  logic [ADDR_WIDTH - 1:0] port0_dst, port1_dst, port2_dst, port3_dst;
  logic arb_active;
  logic active0, active1, active2, active3; 
  logic valid_out0, valid_out1, valid_out2, valid_out3;
  logic [15:0] data_out_mux;

// Use parameters and DEFINE
// Modular design with wiring

switch_port port0_i (
  //inputs
  .clk          (clk),
  .rst_n        (rst_n),
  .valid_in     (port0.valid_in),
  .source_in    (port0.source_in),
  .target_in    (port0.target_in),
  .data_in      (port0.data_in),
  .grant        (grant[0]), 
  //outputs
  .pkt_dst      (port0_dst),
  .valid_out    (valid_out0),
  .source_out   (port0.source_out),
  .target_out   (port0.target_out),
  .data_out     (port0.data_out)
); 

switch_port port1_i (
  //inputs
  .clk          (clk),
  .rst_n        (rst_n),
  .valid_in     (port1.valid_in),
  .source_in    (port1.source_in),
  .target_in    (port1.target_in),
  .data_in      (port1.data_in),
  .grant        (grant[1]),
  //outputs
  .pkt_dst      (port1_dst),
  .valid_out    (valid_out1),
  .source_out   (port1.source_out),
  .target_out   (port1.target_out),
  .data_out     (port1.data_out)
); 

switch_port port2_i (
  //inputs
  .clk          (clk),
  .rst_n        (rst_n),
  .valid_in     (port2.valid_in),
  .source_in    (port2.source_in),
  .target_in    (port2.target_in),
  .data_in      (port2.data_in),
  .grant        (grant[2]),
  //outputs
  .pkt_dst      (port2_dst),
  .valid_out    (valid_out2),
  .source_out   (port2.source_out),
  .target_out   (port2.target_out),
  .data_out     (port2.data_out)
); 

switch_port port3_i (
  //inputs
  .clk          (clk),
  .rst_n        (rst_n),
  .valid_in     (port3.valid_in),
  .source_in    (port3.source_in),
  .target_in    (port3.target_in),
  .data_in      (port3.data_in),
  .grant        (grant[3]),
  //outputs
  .pkt_dst      (port3_dst),
  .valid_out    (valid_out3),
  .source_out   (port3.source_out),
  .target_out   (port3.target_out),
  .data_out     (port3.data_out)
); 

arbiter top_arb_i (
  //inputs
  .clk          (clk),
  .rst_n        (rst_n),
  .port0_dst    (port0_dst),
  .port1_dst    (port1_dst),
  .port2_dst    (port2_dst),
  .port3_dst    (port3_dst),
  //outputs
  .grant_bus    (grant),
  .mux_sel0     (mux_sel0),
  .mux_sel1     (mux_sel1),  
  .mux_sel2     (mux_sel2),
  .mux_sel3     (mux_sel3),
  .active0      (active0),
  .active1      (active1),
  .active2      (active2),
  .active3      (active3)

);

output_mux mux0_i (
  //inputs
    .mux_sel      (mux_sel0),
    .data_in0     ({port0.data_out, port0.target_out, port0.source_out}),
    .data_in1     ({port1.data_out, port1.target_out, port1.source_out}),
    .data_in2     ({port2.data_out, port2.target_out, port2.source_out}),
    .data_in3     ({port3.data_out, port3.target_out, port3.source_out}),
    .arb_active   (active0),
  //outputs
    .data_out     ({port0.data_out, port0.target_out, port0.source_out}),
    .valid_out    (port0.valid_out)
);

output_mux mux1_i (
  //inputs
    .mux_sel      (mux_sel1),
    .data_in0     ({port0.data_out, port0.target_out, port0.source_out}),
    .data_in1     ({port1.data_out, port1.target_out, port1.source_out}),
    .data_in2     ({port2.data_out, port2.target_out, port2.source_out}),
    .data_in3     ({port3.data_out, port3.target_out, port3.source_out}),
    .arb_active   (active1),
  //outputs
    .data_out     ({port1.data_out, port1.target_out, port1.source_out}),
    .valid_out    (port1.valid_out)
);

output_mux mux2_i (
  //inputs
    .mux_sel      (mux_sel2),
    .data_in0     ({port0.data_out, port0.target_out, port0.source_out}),
    .data_in1     ({port1.data_out, port1.target_out, port1.source_out}),
    .data_in2     ({port2.data_out, port2.target_out, port2.source_out}),
    .data_in3     ({port3.data_out, port3.target_out, port3.source_out}),
    .arb_active   (active2),
  //outputs
    .data_out     ({port2.data_out, port2.target_out, port2.source_out}),
    .valid_out    (port2.valid_out)
);

output_mux mux3_i (
  //inputs
    .mux_sel      (mux_sel3),
    .data_in0     ({port0.data_out, port0.target_out, port0.source_out}),
    .data_in1     ({port1.data_out, port1.target_out, port1.source_out}),
    .data_in2     ({port2.data_out, port2.target_out, port2.source_out}),
    .data_in3     ({port3.data_out, port3.target_out, port3.source_out}),
    .arb_active   (active3),
  //outputs
    .data_out     ({port3.data_out, port3.target_out, port3.source_out}),
    .valid_out    (port3.valid_out)
);

endmodule
