module switch_4port (input logic clk, input logic rst_n,
  port_if port0, port_if port1, port_if port2, port_if port3);

// Use parameters and DEFINE
// Modular design with wiring

switch_port port0_i (
  .clk(clk),
  .rst_n(rst_n),
  .valid_in(port0.valid_in),
  .source_in(port0.source_in),
  .target_in(port0.target_in),
  .data_in(port0.data_in),
  .valid_out(port0.valid_out),
  .source_out(port0.source_out),
  .target_out(port0.target_out),
  .data_out(port0.data_out)
);

switch_port port1_i (
  .clk(clk),
  .rst_n(rst_n),
  .valid_in(port1.valid_in),
  .source_in(port1.source_in),
  .target_in(port1.target_in),
  .data_in(port1.data_in),
  .valid_out(port1.valid_out),
  .source_out(port1.source_out),
  .target_out(port1.target_out),
  .data_out(port1.data_out)
);

switch_port port2_i (
  .clk(clk),
  .rst_n(rst_n),
  .valid_in(port2.valid_in),
  .source_in(port2.source_in),
  .target_in(port2.target_in),
  .data_in(port2.data_in),
  .valid_out(port2.valid_out),
  .source_out(port2.source_out),
  .target_out(port2.target_out),
  .data_out(port2.data_out)
);

switch_port port3_i (
  .clk(clk),
  .rst_n(rst_n),
  .valid_in(port3.valid_in),
  .source_in(port3.source_in),
  .target_in(port3.target_in),
  .data_in(port3.data_in),
  .valid_out(port3.valid_out),
  .source_out(port3.source_out),
  .target_out(port3.target_out),
  .data_out(port3.data_out)
);  

arbiter top_arb_i (
  //TODO add arbiter interface
);


endmodule
