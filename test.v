module counter(
    input clk,
    input reset,
    output reg [3:0] count
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 4'b0000;
        else
            count <= count + 1;
    end
endmodule

`timescale 1ns/1ns

module counter_tb;
    reg clk;
    reg reset;
    wire [3:0] count;

    // Instantiate the design
    counter uut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5ns
    end

    // Test sequence
    initial begin
        // REQUIRED FOR WAVEFORMS:
        $dumpfile("waves.vcd");      // Name of the output file
        $dumpvars(0, counter_tb);    // Dump all variables in this module

        reset = 1;
        #10;
        reset = 0;
    #100;
        $finish; // Stop simulation
    end
endmodule