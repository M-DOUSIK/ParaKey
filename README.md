# ParaKey - A Modular Keypad Scanner (Custom FSM Design)

## Overview

This project implements a modular, bidirectional keypad scanner using an FPGA. Unlike conventional Arduino-style sequential scanners, this design uses a fully parallel finite state machine (FSM) to alternate between driving rows and columns, reducing latency and simplifying debouncing requirements.

The design is written in Verilog HDL and tested through a complete simulation testbench. It was later synthesized using Cadence Genus (gpdk045 library) for comparative analysis against a standard (default) keypad scanner.


## Design Objectives

1. **Modular Design:**

Parameterized `R` (rows) and `C` (columns) allow easy scaling for any matrix size.

2. **Bidirectional FSM Control:**

Alternates between driving rows and columns rather than scanning sequentially.

3. **Reduced Bounce Dependency:**

Since state control retains the detected key until transition, minor bounces are tolerated without explicit debounce delay.

4. **Open-Drain Bus Style:**

Implements realistic tri-state control compatible with FPGA I/O pins and external pull-ups.

5. **Synthesizable and Testbench Verified:**

The design was simulated and synthesized for area, power, and timing verification.


## Design Flow

### FSM Architecture

The FSM consists of five primary states:

| **State** | **Function** |
|------------|--------------|
| DRIVE_ROWS | Drives all row lines LOW (0) and floats columns. |
| READ_COLS | Reads which column line went LOW (via pull-ups). |
| DRIVE_COLS | Drives all column lines LOW and floats rows. |
| READ_ROWS | Reads which row line went LOW to identify pressed key. |
| LATCH_KEY | Captures final key value and restarts cycle. |


### Pull-up and Pull-down Logic

- External pull-up resistors (~10 kΩ) are connected to each line (rows and columns).

- When no key is pressed, all lines remain HIGH (logic ‘1’).

- A pressed key connects a row and column, pulling one LOW through the driven side.

- This ensures defined logic levels and prevents floating input noise.

### Open-Drain I/O Handling

Each I/O pin (row/column) operates in open-drain mode:

```verilog

assign rows = (state == DRIVE\_ROWS) ? drive\_rows : {R{1'bz}};

assign cols = (state == DRIVE\_COLS) ? drive\_cols : {C{1'bz}};

```

This avoids short circuits and enables safe bidirectional bus behavior.

## Simulation Environment

A custom testbench (`tb_top.v`) was developed to emulate keypresses for all possible `(row, col)` pairs.

**Simulation covered:**
- Sequential press and release of all 16 keys (4x4 matrix)
- Keypress verification using `$display` logs
- Timing modeled for a 66 MHz FPGA clock
- Expected vs detected key values automatically checked for correctness


## Synthesis Environment

**Tool:** Cadence Genus Synthesis Solution 21.14  
**Technology:** gpdk045bc (45 nm library)  
**Operating Condition:** Slow  
**Interconnect Mode:** Global  
**Area Mode:** Physical Library  

Two versions were synthesized:
1. Default Sequential Keypad Scanner  
2. Custom Parallel FSM Keypad Scanner (this design)

## Results Summary

### Custom FSM Keypad Scanner

| **Metric** | **Value** |
|-------------|------------|
| Total Cells | 111 |
| Cell Area | 576.749 µm² |
| Net Area | 101.061 µm² |
| **Total Area** | **677.810 µm²** |
| Sequential Cells | 5 (8.3 %) |
| Logic Cells | 58 (47.9 %) |
| Tri-State Buffers | 16 (28.8 %) |
| Inverters | 30 (13.9 %) |
| Timing Slack | −107 ps (1 path violated) |
| **Power (Total)** | **2.49 × 10⁻⁴ W** |

#### Power Breakdown

| **Category** | **Leakage (W)** | **Internal (W)** | **Switching (W)** | **Total (W)** | **Contribution** |
|---------------|----------------|------------------|-------------------|----------------|------------------|
| Register | 2.20e−09 | 5.79e−05 | 6.68e−06 | 6.46e−05 | 25.9 % |
| Logic | 3.88e−08 | 7.06e−05 | 1.10e−04 | 1.81e−04 | 72.6 % |
| Clock | 0.00 | 0.00 | 3.49e−06 | 3.49e−06 | 1.4 % |
| **Total** | **4.10e−08** | **1.29e−04** | **1.21e−04** | **2.49e−04** | **100 %** |


### Default Sequential Scanner (Reference)

| **Metric** | **Value** |
|-------------|-----------|
| Total Cells | 48 |
| Cell Area | 143.666 µm² |
| Net Area | 54.314 µm² |
| **Total Area** | **197.980 µm²** |
| Sequential Cells | 13 (54.8 %) |
| Logic Cells | 34 (44.8 %) |
| Timing Slack | +20 ps (All met) |
| **Power (Total)** | **1.74 × 10⁻⁴ W** |

#### Power Breakdown

| **Category** | **Leakage (W)** | **Internal (W)** | **Switching (W)** | **Total (W)** |
|---------------|----------------|------------------|-------------------|----------------|
| Register | 2.83e−09 | 1.17e−04 | 1.32e−05 | 1.30e−04 |
| Logic | 2.43e−09 | 9.94e−06 | 2.61e−05 | 3.60e−05 |
| Clock | 0.00 | 0.00 | 8.63e−06 | 8.63e−06 |


## Comparative Analysis

| **Parameter** | **Default Sequential** | **Custom FSM** | **Difference** |
|----------------|------------------------|----------------|----------------|
| Area (µm²) | 198 | 678 | ↑ 3.4× |
| Cell Count | 48 | 111 | ↑ 2.3× |
| Power (W) | 1.74e−4 | 2.49e−4 | ↑ 43 % |
| Slack | +20 ps | −107 ps | Slightly slower |
| Architecture | Row-sequential | Bidirectional FSM | More responsive |
| Debounce Dependency | High | Low | ✅ Advantage |
| Scalability | Fixed 4×4 | Modular (R×C) | ✅ Advantage |
| I/O Contention Safety | Partial | Full (open-drain) | ✅ Advantage |


## Interpretation

The custom design trades area and power for robustness, modularity, and parallel operation.

- Tri-state buffers dominate the area (28.8 %), necessary for safe bidirectional control.  
- Minor setup violation (−107 ps) under slow corner can be fixed with retiming or pipeline balancing.  
- The design achieves hardware-level debounce immunity by logically holding valid key states across scan cycles.


## Hardware Notes (FPGA Prototype)

- **Platform:** Terasic DE10-Lite (MAX10 FPGA)  
- **Recommended Resistors:** 10 kΩ pull-ups on both row and column lines  
- **Keypad Interface:** 8-bit bidirectional port (4 rows, 4 columns)  
- **Operating Frequency:** ≤ 50 MHz (tested safe)  
- **Expected Output:** 4-bit key index (0–15)


## Future Enhancements

- **I²C Interface Integration:** Add an IP block for I²C slave communication, exposing the detected key to a microcontroller.  
- **Timing Optimization:** Apply retiming or insert an intermediate buffer stage to eliminate setup violations.  
- **Low-Power Mode:** Use gated clock and selective scan modes for portable systems.  
- **Dynamic Matrix Scaling:** Extend to arbitrary R×C configurations (e.g., 3×4, 5×5).


## Conclusion

This project demonstrates a novel parallel FSM keypad scanner that:

- Removes the need for debounce filtering  
- Enables dynamic modular scaling  
- Uses safe open-drain FPGA interfacing  
- Operates with robust bidirectional logic  

While larger in area than standard row-scanners, it provides higher functional reliability and scalability — making it a potential candidate for intelligent keypad IPs or custom I²C peripheral integration.
