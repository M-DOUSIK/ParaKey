`timescale 1ns/1ps
module top (
    input clk,
    input rst,
    inout [3:0] rows,
    inout [3:0] cols,
    output reg [3:0] key
);

    // FSM states
    parameter DRIVE_ROWS = 3'b000,
              READ_COLS  = 3'b001,
              DRIVE_COLS = 3'b010,
              READ_ROWS  = 3'b011,
              LATCH_KEY  = 3'b100;

    // Internal regs
    reg [3:0] drive_rows, drive_cols;
    reg [1:0] i, j;
    reg [2:0] state;
    reg [3:0] matrix [0:3][0:3];
    integer x, y;

    // Tri-state bus handling
    assign rows = (state == DRIVE_ROWS || state == READ_COLS) ? drive_rows : 4'bzzzz;
    assign cols = (state == DRIVE_COLS || state == READ_ROWS) ? drive_cols : 4'bzzzz;

    // Matrix init
    initial begin
        for (x = 0; x < 4; x = x + 1)
            for (y = 0; y < 4; y = y + 1)
                matrix[x][y] = x * 4 + y;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= DRIVE_ROWS;
            i <= 2'bzz;
            j <= 2'bzz;
            key <= 4'bzzzz;
            drive_rows <= 4'b1111;
            drive_cols <= 4'bzzzz;
        end else begin
            case (state)

                DRIVE_ROWS: begin
                    drive_rows <= 4'b1111;
                    drive_cols <= 4'bzzzz;
                    state <= READ_COLS;
                end

                READ_COLS: begin
                    if (cols === 4'bzzzz) begin
                        j <= 2'bzz; state <= READ_COLS;
                    end else begin                 
                        casez (cols)
                            4'b1000: begin j <= 2'b00; state <= DRIVE_COLS; end
                            4'b0100: begin j <= 2'b01; state <= DRIVE_COLS; end
                            4'b0010: begin j <= 2'b10; state <= DRIVE_COLS; end
                            4'b0001: begin j <= 2'b11; state <= DRIVE_COLS; end
                            default: begin j <= 2'bzz; state <= READ_COLS; end         
                        endcase
                    end
                end

                DRIVE_COLS: begin
                    drive_cols <= 4'b1111;
                    drive_rows <= 4'bzzzz;
                    state <= READ_ROWS;
                end

                READ_ROWS: begin
                    if (rows === 4'bzzzz) begin
                        i <= 2'bzz; state <= READ_ROWS;
                    end else begin
                        casez (rows)
                            4'b1000: begin i <= 2'b00; state <= LATCH_KEY; end
                            4'b0100: begin i <= 2'b01; state <= LATCH_KEY; end
                            4'b0010: begin i <= 2'b10; state <= LATCH_KEY; end
                            4'b0001: begin i <= 2'b11; state <= LATCH_KEY; end
                            default: begin i <= 2'bzz; state <= READ_ROWS; end
                        endcase
                    end
                end

                LATCH_KEY: begin
                    if (i !== 2'bzz && j !== 2'bzz)
                        key <= matrix[i][j];
                    state <= DRIVE_ROWS;
                end
            endcase
        end
    end
endmodule