`timescale 1ns/1ps
module top (
    input clk,            // 66 MHz clock
    input rst,            // async reset
    inout [3:0] rows,     // keypad row lines
    inout [3:0] cols,     // keypad column lines
    output reg [3:0] key  // stable key output (0-15)
);

    // FSM states
    parameter DRIVE_ROWS = 2'b00,
              READ_COLS  = 2'b01,
              DRIVE_COLS = 2'b10,
              READ_ROWS  = 2'b11;

    // Internal regs
    reg [3:0] drive_rows, drive_cols;
    reg [1:0] i, j;
    reg [1:0] state;
    reg [3:0] matrix [0:3][0:3];
    reg [19:0] debounce_cnt;
    reg [3:0] last_key;
    reg key_stable;

    integer x, y;

    // Tri-state handling
    assign rows = (state == DRIVE_ROWS || state == READ_COLS) ? drive_rows : 4'bzzzz;
    assign cols = (state == DRIVE_COLS || state == READ_ROWS) ? drive_cols : 4'bzzzz;

    // Initialize matrix (simple key code map)
    initial begin
        for (x = 0; x < 4; x = x + 1)
            for (y = 0; y < 4; y = y + 1)
                matrix[x][y] = x * 4 + y;
    end

    // Main FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= DRIVE_ROWS;
            i <= 2'bzz;
            j <= 2'bzz;
            key <= 4'b0000;
            drive_rows <= 4'b1111;
            drive_cols <= 4'bzzzz;
            debounce_cnt <= 0;
            key_stable <= 0;
            last_key <= 4'b1111;
        end else begin
            case (state)

                // Step 1: Drive all rows
                DRIVE_ROWS: begin
                    drive_rows <= 4'b1111;
                    drive_cols <= 4'bzzzz;
                    state <= READ_COLS;
                end

                // Step 2: Wait for valid column before moving on
                READ_COLS: begin
                    if (cols !== 4'bzzzz) begin
                        casez (cols)
                            4'b1???: j <= 2'b00;
                            4'b01??: j <= 2'b01;
                            4'b001?: j <= 2'b10;
                            4'b0001: j <= 2'b11;
                            default: j <= 2'bzz;
                        endcase
                    end else begin
                        j <= 2'bzz;
                    end

                    // Move only when a valid column is detected
                    if (j !== 2'bzz)
                        state <= DRIVE_COLS;
                    else
                        state <= READ_COLS;
                end

                // Step 3: Drive all columns
                DRIVE_COLS: begin
                    drive_cols <= 4'b1111;
                    drive_rows <= 4'bzzzz;
                    state <= READ_ROWS;
                end

                // Step 4: Wait for valid row, then debounce
                READ_ROWS: begin
                    if (rows !== 4'bzzzz) begin
                        casez (rows)
                            4'b1???: i <= 2'b00;
                            4'b01??: i <= 2'b01;
                            4'b001?: i <= 2'b10;
                            4'b0001: i <= 2'b11;
                            default: i <= 2'bzz;
                        endcase
                    end else begin
                        i <= 2'bzz;
                    end

                    // Only proceed if valid row detected
                    if (i !== 2'bzz && j !== 2'bzz) begin
                        // Retriggerable debounce logic
                        if (matrix[i][j] == last_key) begin
                            if (debounce_cnt < 20'd660_000) // ~10ms @66MHz
                                debounce_cnt <= debounce_cnt + 1;
                            else
                                key_stable <= 1;
                        end else begin
                            debounce_cnt <= 0;
                            key_stable <= 0;
                            last_key <= matrix[i][j];
                        end
                    end else begin
                        debounce_cnt <= 0;
                        key_stable <= 0;
                    end

                    // Update key once stable
                    if (key_stable)
                        key <= last_key;

                    // Only loop back once valid row detected
                    if (i !== 2'bzz)
                        state <= DRIVE_ROWS;
                    else
                        state <= READ_ROWS;
                end
            endcase
        end
    end

endmodule