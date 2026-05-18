# Traffic Light System — SystemVerilog FSM

A two-road traffic light control system implemented in **SystemVerilog** using a **Mealy Finite State Machine** and a hierarchical nested down-counter timer. Synthesised and verified on an Intel Cyclone V FPGA using **Intel Quartus Prime**.

---

## Overview

This project implements a priority-based traffic light controller for two roads (Road A and Road B). Road A has default green priority; when traffic is detected on Road B, the FSM sequences through an amber transition before handing green to Road B, and returns after a fixed period.

---

## Architecture

### FSM — `traffic_light_system.sv`

A **4-state Mealy FSM** controlling the light outputs of both roads.

| State | Road A | Road B | Description |
|-------|--------|--------|-------------|
| **F0** | Green  | Red    | Road A default green; waits for Road B traffic |
| **F1** | Amber  | Red    | Road A amber transition; waits for 7.5 s timer |
| **F2** | Red    | Green  | Road B gets green; holds until no traffic |
| **F3** | Red    | Amber  | Road B amber transition; waits for 7.5 s timer |

**Inputs:**
- `clk` — system clock
- `rstn` — active-low reset
- `traffic_B` — sensor signal indicating vehicles on Road B
- `timer_done` — asserted by the down-counter timer after 7.5 seconds

**Outputs:**
- `red_light_A`, `amber_light_A`, `green_light_A` — Road A lights
- `red_light_B`, `amber_light_B`, `green_light_B` — Road B lights
- `amber_timer_en` — enables the amber timer on amber states

---

### Down-Counter Timer — `down_counter_timer.sv`

A **7.5-second amber timer** built from three chained down-counters.

```
amber_timer_en ──► cnt_tenth_p0 (÷6)  ──► cnt_tenth_p1 (÷10) ──► cnt_sec (÷8) ──► timer_done
                   [0.6 s phase]          [tenths counter]         [seconds counter]
```

Exposes `sec_count` and `tenth_count` outputs for optional display driving.

---

### Primitive Down-Counter — `down_counter.sv`

A parameterised N-count synchronous down-counter with:
- `en_in` — count enable
- `en_out` — terminal count pulse (used to chain counters)
- Generic `N` parameter sets the count modulus

---

### Top-Level Integration — `traffic_light_top.sv`

Instantiates and wires together `traffic_light_system` and `down_counter_timer`.

---

### Testbench — `tb_traffic_light_top.sv`

A self-checking testbench that:
- Drives the clock and reset
- Applies `traffic_B` stimulus at defined simulation time points
- Monitors and displays all light outputs and timer values
- Verifies correct FSM state sequencing

---

## File Structure

```
├── traffic_light_system.sv     # Mealy FSM (4-state)
├── traffic_light_top.sv        # Top-level integration module
├── down_counter_timer.sv       # 7.5 s hierarchical timer
├── down_counter.sv             # Parameterised primitive down-counter
├── tb_traffic_light_top.sv     # Self-checking testbench
├── Traffic_light_system.qpf    # Quartus project file
└── Traffic_light_system.qsf    # Quartus settings file
```

---

## Tools & Target

| Item | Detail |
|------|--------|
| HDL | SystemVerilog |
| Simulator | ModelSim / QuestaSim |
| Synthesis tool | Intel Quartus Prime |
| Target FPGA | Intel Cyclone V |

---

## Author

**Ransara Maldeniya**  
Digital Systems Design — Assignment 
