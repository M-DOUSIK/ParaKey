`timescale 1ns/1ps
module top #(
    parameter R = 4,   // number of rows
    parameter C = 4    // number of columns
)(
    input  clk,
    input  rst,
    inout  [R-1:0] rows,
    inout  [C-1:0] cols,
    output reg [$clog2(R*C)-1:0] key
);

    // FSM states
    localparam DRIVE_ROWS   = 3'b000,
               READ_COLS    = 3'b001,
               RELEASE_ROWS = 3'b010,
               DRIVE_COLS   = 3'b011,
               READ_ROWS    = 3'b100,
               RELEASE_COLS = 3'b101,
               LATCH_KEY    = 3'b110;

    reg [R-1:0] drive_rows;
    reg [C-1:0] drive_cols;
    reg [$clog2(R)-1:0] i;
    reg [$clog2(C)-1:0] j;
    reg [2:0] state;

    // 2D key map
    reg [$clog2(R*C)-1:0] matrix [0:R-1][0:C-1];
    integer x, y;

    // open-drain style I/O (0 = drive low, Z = release)
    assign rows = ((state == DRIVE_ROWS) ? drive_rows : {R{1'bz}});
    assign cols = ((state == DRIVE_COLS) ? drive_cols : {C{1'bz}});

    // Matrix initialization
    initial begin
        for (x = 0; x < R; x = x + 1)
            for (y = 0; y < C; y = y + 1)
                matrix[x][y] = x * C + y;
    end

    // FSM core
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= DRIVE_ROWS;
            i           <= {($clog2(R)){1'b0}};
            j           <= {($clog2(C)){1'b0}};
            key         <= {($clog2(R*C)){1'b0}};
            drive_rows  <= {R{1'bz}};
            drive_cols  <= {C{1'bz}};
        end else begin
            case (state)
                // --- 1. Drive rows low ---
                DRIVE_ROWS: begin
                    drive_rows <= {R{1'b0}};
                    drive_cols <= {C{1'bz}};
                    state <= READ_COLS;
                end

                // --- 2. Read active column (which one went low) ---
                READ_COLS: begin
                    casez (cols)
                        4'b1110: begin j <= 2'b00; state <= RELEASE_ROWS; end
                        4'b1101: begin j <= 2'b01; state <= RELEASE_ROWS; end
                        4'b1011: begin j <= 2'b10; state <= RELEASE_ROWS; end
                        4'b0111: begin j <= 2'b11; state <= RELEASE_ROWS; end
                        default: state <= READ_COLS;
                    endcase
                end

                // --- 3. Release all rows before driving columns ---
                RELEASE_ROWS: begin
                    drive_rows <= {R{1'bz}};
                    state <= DRIVE_COLS;
                end

                // --- 4. Drive columns low ---
                DRIVE_COLS: begin
                    drive_cols <= {C{1'b0}};
                    state <= READ_ROWS;
                end

                // --- 5. Read active row (which one went low) ---
                READ_ROWS: begin
                    casez (rows)
                        4'b1110: begin i <= 2'b00; state <= RELEASE_COLS; end
                        4'b1101: begin i <= 2'b01; state <= RELEASE_COLS; end
                        4'b1011: begin i <= 2'b10; state <= RELEASE_COLS; end
                        4'b0111: begin i <= 2'b11; state <= RELEASE_COLS; end
                        default: state <= READ_ROWS;
                    endcase
                end

                // --- 6. Release all columns before next scan ---
                RELEASE_COLS: begin
                    drive_cols <= {C{1'bz}};
                    state <= LATCH_KEY;
                end

                // --- 7. Output detected key ---
                LATCH_KEY: begin
                    key   <= matrix[i][j];
                    state <= DRIVE_ROWS;
                end
            endcase
        end
    end
endmodule