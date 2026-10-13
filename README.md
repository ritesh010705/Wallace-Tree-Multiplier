# Analysis of Wallace Multipliers: Variations, Area, Delay & Power Evaluation

[![Verilog HDL](https://img.shields.io/badge/Language-Verilog%20HDL-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![PDK](https://img.shields.io/badge/PDK-SkyWater%20130nm-green.svg)](https://github.com/google/skywater-pdk)
[![Synthesis](https://img.shields.io/badge/Synthesis-Yosys-orange.svg)](https://github.com/YosysHQ/yosys)
[![Backend Flow](https://img.shields.io/badge/Flow-OpenLANE%20%7C%20OpenROAD-purple.svg)](https://github.com/The-OpenROAD-Project/OpenLane)
[![Verification](https://img.shields.io/badge/Sim-ModelSim-red.svg)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-simulation.html)

This repository provides Register-Transfer Level (RTL) implementations, verification testbenches, and physical synthesis results for three architectural variants of the **Wallace Tree Multiplier**:
1. **Conventional Wallace Tree Multiplier** (Full Adder / Half Adder based)[cite: 1, 2]
2. **Reduced-Complexity Wallace Tree Multiplier (RCWM)** (Inverted-pyramid scheduling)[cite: 1, 2, 6]
3. **Compressor-Based Wallace Tree Multiplier** (4:2 compressor architecture)[cite: 1, 2, 6]

All designs are modeled in Verilog HDL and benchmarked using **Yosys**, **OpenSTA**, and the **OpenLANE** automated RTL-to-GDSII flow on the **SkyWater 130 nm (`sky130_fd_sc_hd`)** standard cell library[cite: 1, 2, 3].

---

## 📌 Architectural Variants

### 1. Conventional Wallace Tree Multiplier (`Wallace_summer`)
- **Reduction Strategy:** Classical multi-pass column compression utilizing standard full adders (3:2) and half adders (2:2).
- **Trade-offs:** Provides high parallel speedup over ripple-carry array multipliers but introduces irregular wiring congestion and higher half-adder count.

### 2. Reduced-Complexity Wallace Multiplier (`RCWM`)
- **Reduction Strategy:** Inverted-pyramid scheduling that prioritizes full-adder groupings to minimize half-adder instantiations in intermediate stages[cite: 2, 6].
- **Trade-offs:** Regularizes routing paths, suppresses spurious logic transitions/glitching, and achieves minimal dynamic power consumption[cite: 2, 6].

### 3. Compressor-Based Multiplier (`wallace_tree_4x4`)
- **Reduction Strategy:** Employs higher-order **4:2 compressors** chained column-wise to rapidly collapse tree height[cite: 2, 4, 6].
- **Trade-offs:** Contracts total cell count and routing layers, drastically reducing propagation delay down to sub-nanosecond speeds while minimizing silicon area[cite: 1, 2, 6].

---

## ⏱️ Synchronous Pipeline Architecture

To facilitate clean static timing analysis (STA) and evaluate critical path timing without pad-induced anomalies, each multiplier combinational core is enclosed in a **three-stage synchronous pipeline**:

```text
                                   CLK
                                    │
                               ┌────┴────┐          ┌───────────────────────────────────┐          ┌────┴────┐
                            A ─┤ DFF (A) ├─────────►│                                   │─────────►│ DFF (P) ├─► Product (P)
                               └─────────┘          │        Combinational Core         │          └─────────┘
                               ┌─────────┐          │   (PPG + Column Reduction Tree)   │
                            B ─┤ DFF (B) ├─────────►│                                   │
                               └─────────┘          └───────────────────────────────────┘
                             Stage 1 (Inputs)                 Stage 2 (Compute)                   Stage 3 (Outputs)



