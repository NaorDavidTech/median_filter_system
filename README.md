# 🖼️ Median Filter System in Verilog

This project implements a **complete image processing pipeline** using a **3×3 median filter** in **Verilog HDL**.  
The system receives an **8×8 grayscale image** and processes each pixel using a **sliding 3×3 window**, computing the **median** to reduce noise (e.g., salt-and-pepper).  
Edge handling is performed via **zero-padding**, ensuring a consistent frame size.

---

## 📁 Files Included

- `median_filter_system.v` – Top module integrating all submodules  
- `median_filter.v` – Core 3×3 median filter logic  
- `zero_edge_handler.v` – Adds zero-padding and controls output sequence  
- `median_filter_system_tb.v` – Full system testbench  
- `test_image.txt` – 8×8 input image (grayscale hex format)  
- `output_image.txt` – Output image after filtering  

---

## ⚙️ Features

- **Input**:  
  - 8-bit grayscale pixels (`data_in`)  
  - Control signals: `clk`, `rst_n`, `data_valid`  
- **Output**:  
  - Filtered pixel (`data_out`)  
  - `data_valid_out`, `frame_complete` indicators  
- **System behavior**:  
  - Real-time 3×3 median filtering  
  - Zero-padding around edges  
  - Fully synchronous pipeline  
- **Application**: Noise reduction in small grayscale images

---

## 🧪 Simulation

- Simulated in ModelSim  
- Input image: 8×8 grayscale values from file  
- Output image stored in `output_image.txt`  
- `frame_complete` indicates image processing end  


---





