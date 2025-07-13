# median_filter_system
median filter system for  image pixels

# 🧮 Median Filter (3x3) in Verilog

This project implements a **median filter** for image processing using **Verilog HDL**.  
The filter receives 9 pixel values (3x3 window) and computes the **median** value in real time, useful for **noise reduction** in grayscale images.

---

## 📁 Files Included

- `median_filter.v` – Main Verilog module implementing the 3x3 median filter
- `median_tb.v` – Testbench verifying correctness with predefined pixel sets



---

## ⚙️ Features

- **Input**: 9 grayscale pixels `p0` to `p8` (each 8 bits)
- **Output**: Median value (8-bit)
- **Architecture**:
  - Pure combinational logic
  - Optimized sorting for 9 elements
- **Application**: Removes salt-and-pepper noise while preserving edges

---

## 🧪 Simulation

- Simulated in ModelSim (or compatible tool)
- Inputs tested with multiple noisy pixel sets
- Median output matches expected middle value
- Waveforms included for validation

---

## 📎 Documentation

- `rtl_diagram.pdf`: RTL architecture of the filter logic
- `simulation_waveform.pdf`: Timing and functional behavior
- `report.pdf`: Full project report in Hebrew, including:
  - Problem definition
  - Design flow
  - Verification results

---


