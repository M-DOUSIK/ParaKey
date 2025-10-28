`timescale 1ns / 1ps
module tb;

    reg clk, rst;
    wire [3:0] rows, cols, key;
    
    top dut(.clk(clk), .rst(rst), .rows(rows), .cols(cols), .key(key));
    
    always #15 clk = ~clk;
    
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #40;
        rst = 1'b0;
    end
    
    
endmodule
