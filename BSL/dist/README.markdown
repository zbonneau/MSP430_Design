# MSP430 Bootloader

This is a PC bootloader script for programming the MSP430FR6989 FPGA using an Intel HEX file over a serial connection.

## Overview

The `Bootloader` tool allows you to program an MSP430FR6989 FPGA by sending Intel HEX records over a serial port. It supports verbose output for debugging and logging to a file for record-keeping.

## Requirements

- **Hardware**:
  - A [Cmod A7-35T FPGA Development Board](https://digilent.com/shop/cmod-a7-35t-breadboardable-artix-7-fpga-module/?srsltid=AfmBOop6ieOslPBAixXAM7U2WZNOlozX6Gw4_Pvw3t5ALD5kQD-nw0FZ) configured with the `MSP430.bit` bitstream file
  - An [MSP-EXP430FR6989 Launchpad](https://www.ti.com/tool/MSP-EXP430FR6989?utm_source=google&utm_medium=cpc&utm_campaign=epd-msp-null-44700045336317338_prodfolderdynamic-cpc-pf-google-ww_en_int&utm_content=prodfolddynamic&ds_k=DYNAMIC+SEARCH+ADS&DCM=yes&gad_source=1&gad_campaignid=7213436380&gbraid=0AAAAAC068F0o6fPLlQFqTzWlrCjrw5405&gclid=Cj0KCQjw8cHABhC-ARIsAJnY12xYd9eWbhdXRpoOFrjWDeX7xPNmleZy_DN8tB3MNmMoQDEpsP8DKUkaAs2XEALw_wcB&gclsrc=aw.ds) configured with the `BSL_Interface.asm` firmware.
  - A Windows 10 PC.
- **Software**:
  - Windows operating system (the executable is built for Windows).
  - [Xilinx Vivado](https://www.xilinx.com/support/download.html) or other software capable of flashing the Cmod A7's Quad-SPI Flash memory
  - [Code Composer Studio](https://www.ti.com/tool/CCSTUDIO) (v12.8.1 recommended) or other software capable of flashing the MSP-EXP430 with the interface code (Ironic, right?)
- **Files**:
  - An Intel HEX file (e.g., `firmware.hex`) containing the firmware to program the device.
  - The bitstream file [MSP430.bit](MSP430.bit) (provided)
  - The Interface file [BSL_Interface.asm](BSL_Interface.asm) (provided)

## Installation

1. Download the `Bootloader.exe` executable and place it in a directory of your choice.
2. Ensure The Cmod A7 is flashed with `MSP430.bit`
3. Ensure the MSP-EXP430FR6989 is flashed with `BSL_Interface.asm`

## Usage

1. Connect the MSP430 FPGA, MSP-EXP430 Launchpad, and PC to establish the necessary serial communications. 
    | FPGA Target Pin | Cmod A7 Dev pin |
    |:-:|:-:|
    | TEST_pin | DIP 27 |
    | RST_pin | DIP 26 |
    | P2.1 | DIP 9 |
    | P2.0 | DIP 8 |
![alt text](image.png)
1. Find the MSP-EXP430 USB Application port (example shown from [MSP430FR6989 LaunchPad Development Kit (MSP-EXP430FR6989) User's Guide (Rev. A)](https://www.ti.com/lit/ug/slau627a/slau627a.pdf?ts=1692590917185&ref_url=https%253A%252F%252Fwww.google.com%252F))![alt text](image-1.png)
2. Run the `Bootloader.exe` from the command line with the required arguments.

### Generating Hex Files Using Code Composer Studio (v12.8.1)
To generate intel hex files from Code Composer Studio, configure your project with the following:
1. Right Click project directory, select properties![alt text](image-2.png)
2. Under Build->MSP430 Hex Utilit, Enable MSP430 Hex Utility ![alt text](image-3.png)
3. Under Build->MSP430 Hex Utility->Output Format Options, set the format to "Intel hex (--intel, -i)![alt text](image-4.png)
4. The hex file is located at *projectname*->Debug->*projectname*.hex![alt text](image-5.png)
### Command Syntax
```
Bootloader.exe -p <port> [-v] [-l <log_file>] <hex_file>
```

### Arguments
- `-p <port>` or `--port <port>`: **Required**. The serial port where the MSP430FR6989 is connected (e.g., `COM3`).
- `-v` or `--verbose`: Optional. Enable verbose output to the console for debugging.
- `-l <log_file>` or `--log-file <log_file>`: Optional. Log all output to a file. If no file name is specified, defaults to `BSL_log.txt`.
- `<hex_file>`: **Required**. Path to the Intel HEX file (e.g., `blink.hex`).

### Example Commands
- Program the device on COM3 with verbose output and logging to `test.log`:
  ```
  Bootloader.exe -p COM3 -v -l test.log blink.hex
  ```
- Program the device with minimal output (no verbose, no log file):
  ```
  Bootloader.exe -p COM3 blink.hex
  ```

### Expected Output
- With verbose mode enabled (`-v`):
  ```
  INFO: Starting bootloader process...
  Transmitting Data Record 1/3...DEBUG: Transaction attempt 1/3
  DEBUG: Received from device: 10
  Transmitting Data Record 2/3...DEBUG: Transaction attempt 1/3
  DEBUG: Received from device: 10
  Transmitting Data Record 3/3...DEBUG: Transaction attempt 1/3
  DEBUG: Received from device: 10
  DEBUG: Transmitted 3/3 records.
  INFO: Device Programmed. 18 bytes written.
  INFO: Programming process completed in 2.345 seconds.
  DEBUG: Closing serial port
  ```
- Without verbose mode, only errors (if any) and key messages are shown:
  ```
  Device Programmed. 18 bytes written.
  Programming process completed in 2.345 seconds.
  ```
- The log file (if specified) will contain detailed messages with timestamps.

## Troubleshooting

- **Error: "Serial Port is not open"**:
  - Ensure the specified port (e.g., `COM3`) is correct and the device is connected.
  - Check if another application is using the serial port.
- **Error: "No Target Detected by Interface"**:
  - Verify that the MSP430 FPGA enters bootloader mode (LED 1 is on).
  - Verify pin connections between the MSP-EXP430 and MSP430 FPGA
- **Error: "Value Error Encountered during hex parse"**:
  - The Intel HEX file is invalid. Verify the file format and contents.
- **No Output or Device Not Programmed**:
  - Run with verbose mode (`-v`) and check the log file for errors.
  - Ensure the HEX file contains valid firmware for the MSP430FR6989.

## Support

For issues or questions, contact the developer at [zackbonneau514@gmail.com](zackbonneau514@gmail.com)

## License

This software is provided as-is, with no warranty. Use at your own risk.