`timescale 1ns / 1ps
module tb;

    reg clk, rst;
    wire [3:0] rows, cols;
    wire [3:0] key;

    // TB drivers
    reg [3:0] tb_rows, tb_cols;

    // Connect tri-state
    assign rows = tb_rows;
    assign cols = tb_cols;

    // Instantiate DUT
    top dut (
        .clk(clk),
        .rst(rst),
        .rows(rows),
        .cols(cols),
        .key(key)
    );

    // Clock generation (66 MHz ≈ 15 ns period)
    always #7.575 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        tb_rows = 4'bzzzz;
        tb_cols = 4'bzzzz;

        #50;
        rst = 0;
        #100;
        @(posedge clk);
        @(posedge clk);
        // === Key 0: row0-col0 ===
        // 1. DUT drives rows -> we respond by pulling col0 low
        @(posedge clk);
        tb_cols = 4'b1110;   // col0 = 0
        tb_rows = 4'bzzzz;   // let DUT drive rows
        @(posedge clk);

        // 2. DUT drives columns -> we now pull row0 low
        tb_cols = 4'bzzzz;   // let DUT drive cols
        tb_rows = 4'b1110;   // row0 = 0
        @(posedge clk);

        tb_rows = 4'bzzzz;   // release
        tb_cols = 4'bzzzz;
        #1000;

        // === Key 5: row1-col1 ===
        @(posedge clk);
        tb_cols = 4'b1101;   // col1 = 0
        tb_rows = 4'bzzzz;
        @(posedge clk);

        tb_cols = 4'bzzzz;
        tb_rows = 4'b1101;   // row1 = 0
        @(posedge clk);

        tb_rows = 4'bzzzz;
        tb_cols = 4'bzzzz;
        #1000;

        $display("Simulation done. Final key = %0d", key);
        $stop;
    end

endmodule