module switch_test;
  import packet_pkg::*;
  bit clk=0; always #5 clk=~clk; bit rst_n;
  port_if port0(clk,rst_n), port1(clk,rst_n), port2(clk,rst_n), port3(clk,rst_n);
  switch_4port dut(.clk(clk),.rst_n(rst_n),.port0(port0),.port1(port1),.port2(port2),.port3(port3));
  initial begin
    rst_n=0; repeat(3) @(posedge clk); rst_n=1;

    packet_vc vc0=new("vc0",null);
    packet_vc vc1=new("vc1",null);
    packet_vc vc2=new("vc2",null);
    packet_vc vc3=new("vc3",null);
    vc0.configure(port0,0); vc1.configure(port1,1);
    vc2.configure(port2,2); vc3.configure(port3,3);

    // Add checker
    // Implement functional coverage

    fork vc0.run(1); vc1.run(1); vc2.run(1); vc3.run(1); join

    #500 $finish;
  end
endmodule
