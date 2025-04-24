# Game of Dockers – Operating Systems Coursework

This repository contains a Bash script that simulates process scheduling using Docker containers. The script demonstrates key operating systems concepts like **Shortest Job Next (SJN)** sorting and **Round Robin scheduling** through manipulation of files within Docker containers.

## 📁 Contents

- `game_of_dockers.sh` — Main Bash script that:
  - Creates three Docker containers
  - Copies job files into each container
  - Sorts files in Docker 1 and 2 using SJN
  - Leaves Docker 3 files unsorted
  - Processes files across all containers using a Round Robin approach
  - Outputs the combined results into a single text file

- `output.txt` — Final output file containing the contents of the processed files in the correct execution order.

## 🐳 How It Works

1. **Containers** are created but not run initially.
2. **Files** are copied from the host into each container's directory.
3. **SJN Sorting** is applied to containers 1 and 2 using file size as the metric.
4. **Round Robin Loop** reads files two at a time from each container.
5. **Output** from the processed files is written to `output.txt` until all files are handled.

---
