`timescale 1ns / 1ps

module tb;

  // Parameters
  localparam CLK_PERIOD = 10; // 10 ns clock period (100 MHz)

  // Testbench Signals
  reg         clk;
  reg         reset;
  reg   [3:0] col;
  wire  [3:0] row;
  wire  [7:0] keycode;
  wire        keyValid;

  // Instantiate the Device Under Test (DUT)
  top dut (
    .clk(clk),
    .reset(reset),
    .col(col),
    .row(row),
    .keycode(keycode),
    .keyValid(keyValid)
  );

  // Clock Generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // Test Sequence
  initial begin
    $display("Time=%0t [TB] Starting simulation...", $time);

    // Dump waves for debugging
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    // 1. Initialize and Reset
    reset = 1;
    col   = 4'b0000; // No key pressed
    $display("Time=%0t [TB] Asserting reset.", $time);
    
    @(posedge clk);
    @(posedge clk); // Hold reset for 2 cycles
    
    reset = 0;
    $display("Time=%0t [TB] De-asserting reset. DUT should start scanning.", $time);
    
    @(posedge clk);
    if (row !== 4'b1000) $display("Time=%0t [TB] FAIL: Row not 1000 after reset.", $time);

    // 2. Test Case: No Key Press (let it scan)
    $display("Time=%0t [TB] TESTCASE 1: No key press. Checking scan cycle...", $time);
    
    @(posedge clk); // Scan logic runs
    if (row !== 4'b0100) $display("Time=%0t [TB] FAIL: Row did not scan to 0100.", $time);
    
    @(posedge clk); // Scan logic runs
    if (row !== 4'b0010) $display("Time=%0t [TB] FAIL: Row did not scan to 0010.", $time);
    
    @(posedge clk); // Scan logic runs
    if (row !== 4'b0001) $display("Time=%0t [TB] FAIL: Row did not scan to 0001.", $time);
    
    @(posedge clk); // Scan logic runs (wraps around)
    if (row !== 4'b1000) $display("Time=%0t [TB] FAIL: Row did not wrap to 1000.", $time);
    
    $display("Time=%0t [TB] TESTCASE 1: Scan OK.", $time);

    // 3. Test Case: Press Key (Row 2, Col 1)
    $display("Time=%0t [TB] TESTCASE 2: Pressing key (R2, C1)...", $time);
    
    @(posedge clk); // row=1000, next should be 0100
    // Current row is 4'b0100 (Row 2). Let's press Col 1.
    col = 4'b0001; 
    
    @(posedge clk); // DUT should detect the key press
    $display("Time=%0t [TB] Key pressed. keyValid=%b, keycode=%h, row=%b", $time, keyValid, keycode, row);
    if (keyValid !== 1) $display("Time=%0t [TB] FAIL: keyValid is not 1.", $time);
    if (keycode !== 8'h14) $display("Time=%0t [TB] FAIL: keycode is not 8'h14 ({0001, 0100}).", $time);
    if (row !== 4'b0100) $display("Time=%0t [TB] FAIL: Row did not pause scanning.", $time);

    // 4. Test Case: Hold Key
    $display("Time=%0t [TB] TESTCASE 3: Holding key for 3 cycles...", $time);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    if (keyValid !== 1) $display("Time=%0t [TB] FAIL: keyValid dropped while key held.", $time);
    if (row !== 4'b0100) $display("Time=%0t [TB] FAIL: Row did not stay paused.", $time);
    $display("Time=%0t [TB] TESTCASE 3: Key hold OK.", $time);

    // 5. Test Case: Release Key
    $display("Time=%0t [TB] TESTCASE 4: Releasing key...", $time);
    col = 4'b0000;
    
    @(posedge clk); // DUT should detect release and resume scan
    $display("Time=%0t [TB] Key released. keyValid=%b, row=%b", $time, keyValid, row);
    if (keyValid !== 0) $display("Time=%0t [TB] FAIL: keyValid did not go to 0.", $time);
    if (row !== 4'b0010) $display("Time=%0t [TB] FAIL: Row did not resume scan (expected 0010).", $time);
        
    @(posedge clk); // Continue scan
    if (row !== 4'b0001) $display("Time=%0t [TB] FAIL: Scan did not continue to 0001.", $time);
    $display("Time=%0t [TB] TESTCASE 4: Key release and resume OK.", $time);
    
    // 6. Test Case: Press Key (Row 4, Col 3)
    $display("Time=%0t [TB] TESTCASE 5: Pressing key (R4, C3)...", $time);
    // We are currently at row 4'b0001 (Row 4). Press Col 3.
    col = 4'b0100;
    
    @(posedge clk); // DUT should detect key press
    $display("Time=%0t [TB] Key pressed. keyValid=%b, keycode=%h, row=%b", $time, keyValid, keycode, row);
    if (keyValid !== 1) $display("Time=%0t [TB] FAIL: keyValid is not 1.", $time);
    if (keycode !== 8'h41) $display("Time=%0t [TB] FAIL: keycode is not 8'h41 ({0100, 0001}).", $time);
    if (row !== 4'b0001) $display("Time=%0t [TB] FAIL: Row did not pause scanning.", $time);

    // 7. Release key and finish
    col = 4'b0000;
    @(posedge clk);
    $display("Time=%0t [TB] Key released. keyValid=%b, row=%b", $time, keyValid, row);
    if (row !== 4'b1000) $display("Time=%0t [TB] FAIL: Row did not resume scan (expected 1000).", $time);
    
    #(CLK_PERIOD * 10); // Wait a few more cycles
    $display("Time=%0t [TB] Simulation finished.", $time);
    $stop;
  end

endmodule