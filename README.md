# 🚦 Traffic Light System — SystemVerilog FSM

![HDL](https://img.shields.io/badge/HDL-SystemVerilog-blue)
![Tool](https://img.shields.io/badge/Tool-Intel%20Quartus%20Prime-0071C5)
![FPGA](https://img.shields.io/badge/FPGA-Intel%20Cyclone%20V-0071C5)
![Simulator](https://img.shields.io/badge/Simulator-ModelSim%20%2F%20QuestaSim-green)
![Course](https://img.shields.io/badge/Course-Fundamentals%20of%20Digital%20System%20Design-orange)

A two-road traffic light control system implemented in **SystemVerilog** using a **Mealy Finite State Machine** and a hierarchical nested down-counter timer. Synthesised and simulated using **Intel Quartus Prime** targeting an **Intel Cyclone V FPGA**.

---

## Overview

This project implements a priority-based traffic light controller for a two-road intersection. Road A has default green priority. When traffic is detected on Road B (and not on Road A), the FSM sequences Road A through an amber transition before handing green to Road B. Once Road B traffic clears, it sequences back through amber and returns priority to Road A — each amber phase held for exactly **7.5 seconds** by an integrated hardware timer.

---

## System Architecture

```
                        ┌─────────────────────────────┐
   clk  ───────────────►│                             │──► red_light_A
   rstn ───────────────►│   traffic_light_system.sv   │──► amber_light_A
   traffic_B ──────────►│      (Mealy FSM)            │──► green_light_A
   timer_done ─────────►│                             │──► red_light_B
                        │                             │──► amber_light_B
                        │                             │──► green_light_B
                        └──────────┬──────────────────┘
                                   │ amber_timer_en
                        ┌──────────▼──────────────────┐
                        │   down_counter_timer.sv      │──► timer_done
                        │   (7.5 s nested timer)       │──► sec_count
                        │                              │──► tenth_count
                        │  ┌────────┐  ┌────────────┐ │
                        │  │ cnt_p0 │─►│ cnt_tenth  │ │
                        │  │  (÷6)  │  │   (÷10)    │ │
                        │  └────────┘  └─────┬──────┘ │
                        │              ┌─────▼──────┐  │
                        │              │  cnt_sec   │  │
                        │              │   (÷8)     │  │
                        │              └────────────┘  │
                        └──────────────────────────────┘
```

---

## Modules

### `traffic_light_system.sv` — Mealy FSM

A **4-state Mealy FSM** that controls the light outputs of both roads. Outputs are combinational functions of both the current state and the current inputs, giving immediate response to traffic sensor and timer changes.

| State | Code | Road A | Road B | Condition to leave |
|-------|------|--------|--------|--------------------|
| **F0** | `00` | 🟢 Green  | 🔴 Red    | `traffic_B = 1` |
| **F1** | `01` | 🟡 Amber  | 🔴 Red    | `timer_done = 1` (7.5 s) |
| **F2** | `10` | 🔴 Red    | 🟢 Green  | `traffic_B = 0` |
| **F3** | `11` | 🔴 Red    | 🟡 Amber  | `timer_done = 1` (7.5 s) |

> `traffic_B` is ignored while the FSM is in an amber state (F1 or F3).

**Ports**

| Signal | Direction | Description |
|--------|-----------|-------------|
| `clk` | input | System clock (100 ms per pulse) |
| `rstn` | input | Active-low synchronous reset |
| `traffic_B` | input | High when vehicles are on Road B and not Road A |
| `timer_done` | input | Asserted by timer after 7.5 s in amber |
| `red/amber/green_light_A` | output | Road A light controls |
| `red/amber/green_light_B` | output | Road B light controls |
| `amber_timer_en` | output | Enables the amber timer in amber states |

---

### `down_counter_timer.sv` — 7.5-Second Nested Timer

A **7.5-second timer** built from three chained parameterised down-counters. Activated by `amber_timer_en`; asserts `timer_done` for exactly one clock cycle when the count expires.

```
amber_timer_en ──► cnt_tenth_p0 (÷6) ──► cnt_tenth_p1 (÷10) ──► cnt_sec (÷8) ──► timer_done
                   [ 0.6 s phase ]        [ tenths digit ]        [ seconds ]
```

Counting with a 100 ms clock:

| Stage | Counts | Time per step | Total |
|-------|--------|---------------|-------|
| `cnt_tenth_p0` | 6 | 100 ms | 0.6 s (initial half-second phase) |
| `cnt_tenth_p1` | 10 | 100 ms | 1.0 s per second tick |
| `cnt_sec` | 8 | 1 s | 8.0 s |

> `sec_count` and `tenth_count` are exposed as outputs and can drive a seven-segment display.

---

### `down_counter.sv` — Parameterised Primitive Counter

A generic synchronous down-counter used as the building block for the timer chain.

```systemverilog
module down_counter #(parameter N = 8) (
    input  logic clk,
    input  logic rstn,
    input  logic en_in,
    output logic en_out,           // terminal count pulse — chains to next counter
    output logic [$clog2(N)-1:0] count
);
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `N` | 8 | Modulus — counter counts N, N-1, …, 1, 0 then wraps |

---

### `traffic_light_top.sv` — Top-Level Integration

Instantiates `traffic_light_system` and `down_counter_timer` and wires `amber_timer_en` and `timer_done` between them. This is the synthesis top-level entity.

---

### `tb_traffic_light_top.sv` — Testbench

A self-checking testbench that:

- Generates the clock and applies active-low reset
- Drives `traffic_B` stimulus at defined simulation time points
- Monitors all six light outputs, `amber_timer_en`, `timer_done`, `sec_count`, and `tenth_count`
- Prints a timestamped log of every signal change
- Asserts correct FSM state sequencing at key checkpoints

---

## File Structure

```
Traffic_Light_System/
├── traffic_light_system.sv     # Mealy FSM — 4 states, all light outputs
├── down_counter.sv             # Parameterised primitive down-counter
├── down_counter_timer.sv       # 7.5 s hierarchical amber timer
├── traffic_light_top.sv        # Top-level integration module
├── tb_traffic_light_top.sv     # Self-checking testbench
├── Traffic_light_system.qpf    # Quartus Prime project file
└── Traffic_light_system.qsf    # Quartus settings and pin assignments
```

---

## Simulation

### Using QuestaSim / ModelSim (command line)

```bash
# Compile all sources
vlog down_counter.sv down_counter_timer.sv traffic_light_system.sv \
     traffic_light_top.sv tb_traffic_light_top.sv

# Run simulation
vsim -c work.tb_traffic_light_top -do "run -all; quit"
```

### Using the Quartus RTL Simulation flow

1. Open `Traffic_light_system.qpf` in Intel Quartus Prime
2. **Tools → Options → EDA Tool Options** — set the path to your QuestaSim/ModelSim binary
3. **Assignments → Settings → EDA Tool Settings → Simulation** — set tool to QuestaSim and format to SystemVerilog
4. **Tools → Run Simulation Tool → RTL Simulation**

---

## Tools & Target

| Item | Detail |
|------|--------|
| HDL | SystemVerilog |
| Simulator | ModelSim / QuestaSim (Intel FPGA Starter Edition) |
| Synthesis tool | Intel Quartus Prime |
| Target device | Intel Cyclone V |
| Clock input | 100 ms per pulse (10 Hz) |

---

## Author

**Ransara Maldeniya**
Fundamentals of Digital System Design
University of Moratuwa · IN23 Batch
