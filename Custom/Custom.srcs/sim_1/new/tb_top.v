`timescale 1ns/1ps
module tb_top;

    parameter R = 4;
    parameter C = 4;

    reg clk;
    reg rst;
    wire [R-1:0] rows;
    wire [C-1:0] cols;
    wire [$clog2(R*C)-1:0] key;

    reg [R-1:0] rows_drive;
    reg [C-1:0] cols_drive;
    integer i, j;
    reg [$clog2(R*C)-1:0] expected;

    // I/O connection emulation (open drain)
    assign rows = (uut.state == uut.DRIVE_ROWS) ? uut.drive_rows : rows_drive;
    assign cols = (uut.state == uut.DRIVE_COLS) ? uut.drive_cols : cols_drive;

    // Instantiate DUT
    top #(R, C) uut (
        .clk(clk),
        .rst(rst),
        .rows(rows),
        .cols(cols),
        .key(key)
    );

    // 66 MHz clock (15 ns period)
    always #7.5 clk = ~clk;

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        clk = 0;
        rst = 1;
        rows_drive = {R{1'bz}};
        cols_drive = {C{1'bz}};
        #45;
        rst = 0;

        // Simulate all keypresses
        for (i = 0; i < R; i = i + 1) begin
            for (j = 0; j < C; j = j + 1) begin
                simulate_keypress(i, j);
            end
        end

        #200;
        $display("[%0t] ✅ All keys tested.", $time);
        $finish;
    end

    // Task to simulate key press/release
    task simulate_keypress(input integer row, input integer col);
        begin
            expected = row * C + col;
            $display("\n[%0t] ▶ Testing key at Row=%0d, Col=%0d (Expected=%0d)", 
                      $time, row, col, expected);

            // During READ_COLS phase
            force cols_drive = ~(4'b0001 << col);
            #60;

            // During READ_ROWS phase
            force rows_drive = ~(4'b0001 << row);
            #60;

            // Release both
            release cols_drive;
            release rows_drive;
            #80;

            if (key === expected)
                $display("[%0t] ✅ Correct key %0d detected", $time, key);
            else
                $display("[%0t] ❌ ERROR: Got %0d, expected %0d", $time, key, expected);
        end
    endtask
endmodule