# Analysis of Wallace Multipliers: Variations, Area, Delay & Power Evaluation

[![Verilog HDL](https://img.shields.io/badge/Language-Verilog%20HDL-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![PDK](https://img.shields.io/badge/PDK-SkyWater%20130nm-green.svg)](https://github.com/google/skywater-pdk)
[![Synthesis](https://img.shields.io/badge/Synthesis-Yosys-orange.svg)](https://github.com/YosysHQ/yosys)
[![Backend Flow](https://img.shields.io/badge/Flow-OpenLANE%20%7C%20OpenROAD-purple.svg)](https://github.com/The-OpenROAD-Project/OpenLane)
[![Verification](https://img.shields.io/badge/Sim-ModelSim-red.svg)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-simulation.html)

This repository contains Register-Transfer Level (RTL) implementations, verification testbenches, and synthesis benchmarks for three architectural topologies of the **Wallace Tree Multiplier**:
1. **Conventional Wallace Tree Multiplier** (Full Adder / Half Adder based)
2. **Reduced-Complexity Wallace Tree Multiplier (RCWM)** (Inverted-pyramid scheduling)
3. **Compressor-Based Wallace Tree Multiplier** (Utilizing higher-order 4:2 compressor cells)

All designs were synthesized and characterized using **Yosys**, **OpenSTA**, and the **OpenLANE** automated RTL-to-GDSII flow targeting the **SkyWater 130 nm (`sky130_fd_sc_hd`)** standard-cell library.

---

## 📌 Architectural Variants

### 1. Conventional Wallace Tree Multiplier (`Wallace_summer`)
- **Reduction Scheme:** Classical multi-pass column compression utilizing standard full adders (3:2) and half adders (2:2).
- **Characteristics:** Achieves high parallel speedup over array multipliers, but introduces wiring irregularity and a high half-adder count.

### 2. Reduced-Complexity Wallace Multiplier (`RCWM`)
- **Reduction Scheme:** Inverted-pyramid reduction schedule prioritizing 3:2 full-adder groupings and minimizing half-adder instantiation in intermediate layers.
- **Characteristics:** Enhances interconnect regularity and reduces spurious transitions/glitching, minimizing overall dynamic power dissipation at a modest area trade-off.

### 3. Compressor-Based Multiplier (`wallace_tree_4x4`)
- **Reduction Scheme:** Leverages modular **4:2 compressors** chained across columns to rapidly compress vertical bit-depth.
- **Characteristics:** Substantially contracts tree depth and gate count, lowering silicon cell area and slashing critical path delay down to sub-nanosecond scale.

---

## ⏱️ Synchronous Pipeline Architecture

To establish an industry-standard static timing analysis (STA) baseline and evaluate true critical path performance under physical constraints, each multiplier combinational core is enclosed in a **three-stage synchronous pipeline**:

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

##perfromance analysis report ##
<img width="756" height="532" alt="image" src="https://github.com/user-attachments/assets/34b9ddca-5cae-4740-bc4c-495cb7335c6f" />
