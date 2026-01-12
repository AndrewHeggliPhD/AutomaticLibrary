# Bespoke Data Automation Tool (ETL)

### 📄 Overview
This repository contains a production R-script (`Library.R`) developed **independently** post-PhD.

The project objective was to automate the processing of daily data extracts from a remote server, maintaining a persistent, updateable library (.csv).

### 🛠️ The Solution
I developed an **Automated Data Pipeline** in R that functions as a lightweight database engine.
1.  **Remote Extraction:** Utilizes the `sftp` package to authenticate and connect to a remote host, listing files and downloading new data packages (.zip).
2.  **State Management:** Checks a local manifest (`OverfortAllerede.txt`) to identify which files have already been processed (Incremental Load).
3.  **Stream Processing:** Uses `unz()` to read data streams directly from compressed `.zip` files. This extracts specific text files into R memory without extracting the full contents to a local folder.
4.  **Loading:** Updates the master dataset (`Bibliotek.csv`) by appending new records.

### ⚙️ Key Logic & Robustness
*   **Direct Archive Processing:** Reads data directly from `.zip` files into R memory using connections. This eliminates the need to unzip files to the hard drive, optimizing storage and I/O.
*   **Incremental Loading:** The script filters the remote file list against a local "processed" log to ensure only new data is computed (Delta Load).
*   **Data Parsing:** Handles text data (`read.delim2`) and parses unstructured string headers using regex logic (`gsub`/`substr`) to standardize variables.
*   **Flat-File Architecture:** Demonstrates robust data management using simple flat files (.csv/.txt) to maintain a persistent state between runs.

### 💻 Technologies
*   **Language:** R
*   **Key Libraries:** `sftp` (Remote Transfer), `zip` (Archive handling), `tidyverse` (Data Manipulation).
*   **Protocol:** SFTP / SSH.

---
**Note:** This script was coded **independently** to replace a manual data entry workflow.
