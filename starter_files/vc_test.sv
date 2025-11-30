module vc_test;
import packet_pkg::*;

bit clk=0; 
always #5 clk=~clk; 
bit rst_n;

// Interface Instantiation
port_if port0(clk,rst_n);

initial begin
  // 1. DECLARATION MUST BE FIRST
  packet_vc vc0; 

  // 2. EXECUTABLE STATEMENTS
  rst_n=0; 
  repeat(3) @(posedge clk); 
  rst_n=1;

  // 3. OBJECT INSTANTIATION
  vc0 = new("vc0", null);
  
  // Note: Ensure vc0.configure accepts a 'virtual port_if'
  // You might need to cast port0 or assign it to a virtual interface variable first.
  vc0.configure(port0, 0); 
  
  vc0.run(3);

  // Add checker
  // Implement functional coverage

  #200 $finish;
end
endmodule