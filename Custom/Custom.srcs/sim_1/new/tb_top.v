`timescale 1ns/1ps
module tb_top;

    reg clk;
    reg rst;
    wire [3:0] rows;
    wire [3:0] cols;
    wire [3:0] key;

    reg [3:0] rows_drive;
    reg [3:0] cols_drive;
    reg [3:0] expected;

    integer i, j;

    // Connect inouts based on FSM drive direction
    assign rows = (uut.state == uut.DRIVE_ROWS || uut.state == uut.READ_COLS) ? uut.drive_rows : rows_drive;
    assign cols = (uut.state == uut.DRIVE_COLS || uut.state == uut.READ_ROWS) ? uut.drive_cols : cols_drive;

    // Instantiate DUT
    top uut (
        .clk(clk),
        .rst(rst),
        .rows(rows),
        .cols(cols),
        .key(key)
    );

    // 66 MHz clock → 15 ns period (7.5 ns half)
    always #7.5 clk = ~clk;

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        clk = 0;
        rst = 1;
        rows_drive = 4'bzzzz;
        cols_drive = 4'bzzzz;
        #45;  // Wait a few cycles
        rst = 0;

        // Loop over all 16 key positions
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                simulate_keypress(i, j);
            end
        end

        #200;
        $display("[%0t] ✅ All keys tested.", $time);
        $finish;
    end

    // Task to simulate one key press and release
    task simulate_keypress(input integer row, input integer col);
        begin
            expected = row * 4 + col;
            $display("\n[%0t] ▶ Testing key at Row=%0d, Col=%0d (Expected=%0d)", $time, row, col, expected);

            // During READ_COLS, drive the selected column
            force cols_drive = (4'b1000 >> col);
            #60; // allow time for FSM to detect col

            // During READ_ROWS, drive the selected row
            force rows_drive = (4'b1000 >> row);
            #60;

            // Release to simulate key release
            release cols_drive;
            release rows_drive;
            #60;

            // Wait for FSM to latch key
            #80;
            if (key === expected)
                $display("[%0t] ✅ Key detected correctly: %0d", $time, key);
            else
                $display("[%0t] ❌ ERROR: Got %0d, expected %0d", $time, key, expected);
        end
    endtask

endmodule