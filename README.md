# Wallace-Tree-Multiplier
# High-Speed Wallace Tree Multiplier (Verilog HDL)

![Verilog](https://img.shields.io/badge/Language-Verilog%20HDL-blue.svg)
![EDA Tools](https://img.shields.io/badge/EDA-ModelSim%20%7C%20Xilinx%20Vivado%20%7C%20Cadence-orange.svg)
![Design Type](https://img.shields.io/badge/Architecture-Tree%20Multiplier-brightgreen.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

An RTL implementation of a high-speed **Wallace Tree Multiplier** designed in Verilog HDL. This project demonstrates column-compression arithmetic reduction using Carry-Save Addition (CSA) trees, minimizing propagation delay from $O(N)$ (linear array) down to $O(\log_{1.5} N)$.

---

## 📌 Architectural Overview

Standard array multipliers accumulate partial products linearly, accumulating delay with each row. The **Wallace Tree Multiplier** optimizes partial-product reduction into three distinct phases:

1. **Partial Product Generation (PPG):**  
   Simultaneous generation of $N \times N$ partial product bits via parallel bitwise `AND` gates ($a_i \cdot b_j$).
2. **Partial Product Reduction Tree (PPRT):**  
   Iterative column reduction using carry-save arithmetic:
   - **Full Adders (3:2 Compressors):** Compresses three bits of weight $2^k$ into one sum bit of weight $2^k$ and one carry bit of weight $2^{k+1}$.
   - **Half Adders (2:2 Compressors):** Compresses two bits of weight $2^k$ into one sum bit and one carry bit.
   - Operations occur concurrently without cross-column carry ripple.
3. **Vector Merge / Final Addition (CPA):**  
   The final pair of accumulated sum and carry vectors are added using a high-speed Carry-Propagate Adder (e.g., Carry Lookahead Adder / CLA or Carry-Select Adder) to produce the final $2N$-bit product.
